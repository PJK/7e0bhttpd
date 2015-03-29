#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "http.h"

%%{
    machine http;

    newline = '\r\n' @{ line++; line_chars = p; };

    verb = (
                'GET'       @{ req.verb = GET; }        |
                'POST'      @{ req.verb = POST; }       |
                'HEAD'      @{ req.verb = HEAD; }       |
                'PUT'       @{ req.verb = PUT; }        |
                'DELETE'    @{ req.verb = DELETE; }     |
                'TRACE'     @{ req.verb = TRACE; }      |
                'OPTIONS'   @{ req.verb = OPTIONS; }    |
                'CONNECT'   @{ req.verb = CONNECT; }    |
                'PATCH'     @{ req.verb = PATCH; }
           );

    header_value = (any - cntrl - [\n\r])*;

    path = ('/' . header_value?)   >{ MARK(); /* allow '/' */ }
                                   %{ CAPTURE(req.path); };

    req_head = verb  ' '  path  ' HTTP/1.1';

    host = 'Host: ' . header_value      >{ MARK(); /* virtual hosts not implemented */ }
                                        %{ CAPTURE(header); printf("Host: %s\n", header); };

    connection_values = (
                            'keep-alive' @{ req.connection = KEEPALIVE; } |
                            'close'
                        );

    connection = 'Connection: ' connection_values;

    generic_header = (alnum | '_' | '-')+;

    header = generic_header >{ MARK(); }
                            %{ CAPTURE(header); printf("Unknown header: '%s: ", header); }
                ': '
                header_value    >{ MARK(); }
                                %{ CAPTURE(header); printf("%s'\n", header); };

    header_line =   header              |
                    host                |
                    connection         ;

    main := (req_head newline
             (header_line newline)*
             newline?
            )                           %eof{ success = true; printf("DONE\n"); }
                                        $err { printf("Parse error near %d:%d. State: %d\n", line, p - line_chars, cs); };

}%%

%% write data;

void print_request(const struct http_request req)
{
    if (req.verb == GET)
        printf("GET %s HTTP/1.1\n", req.path);
    printf("Connection: %s\n", req.connection == CLOSE ? "close" : "keep-alive");
}

#define MARK() { string_start = p; } while (0)
// TODO handle overflows
#define CAPTURE(buffer) { bzero(header, 128); strncpy(buffer, string_start, p - string_start); } while (0)

int parse(char * data) {
    char *p = data, *string_start;
    int cs = 0, line = 1, line_chars = p;
    char *pe = p + strlen(p);
    char *eof = pe;
    bool success = false;


    struct http_request req = { .connection = CLOSE };
    req.path = malloc(128);
    bzero(req.path, 128);

    char * header = malloc(128);
    bzero(header, 128);

    %% write init;
    %% write exec;

    print_request(req);
}
