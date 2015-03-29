#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include "http.h"

%%{
    machine http;

    newline = '\r\n' @{ line++; };

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

    header_value = (any - cntrl - space)+;

    path = ('/' . header_value)   >{ MARK(); }
                                  %{ CAPTURE(req.path); };

    req_head = verb  ' '  path  ' HTTP/1.1';

    host = 'Host: ' . header_value    >{ /* virtual hosts not implemented */ };

    host_line = host newline;

    connection_values = (
                            'keep-alive' @{ req.connection = KEEPALIVE; } |
                            'close'
                        );

    connection = 'Connection: ' connection_values;

    connection_line = connection newline;

    generic_header = (alnum | '_' | '-')+;

    header = generic_header >{ MARK(); }
                            %{ CAPTURE(header); printf("Unknown header: '%s: ", header); }
                ': '
                header_value    >{ MARK(); }
                                %{ CAPTURE(header); printf("%s'\n", header); };

    header_line =   (header newline) > 1 |
                    connection_line > 2;

    main := (req_head newline
             host_line
             header_line*)  %eof{ success = true; printf("DONE\n"); }
                            $err { printf("Parse error near character %d (line %d)\n", p - data, line); };

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
#define CAPTURE(buffer) { strncpy(buffer, string_start, p - string_start); } while (0)

int parse(char * data) {
    int cs = 0, line = 0;
    char *p = data, *string_start;
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
