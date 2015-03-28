#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <stdbool.h>
#include "http.h"

%%{
    machine http;

    newline = '\r\n';

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

    path = ('/' . header_value)   >{ string_start = p; }
                                            %{ strncpy(req.path, string_start, p - string_start); };

    req_head = verb  ' '  path  ' HTTP/1.1';

    host = 'Host: ' . header_value    >{ /* virtual hosts not implemented */ };

    header = (alnum | '_' | '-')+
             . ': ' . header_value         %{ printf("HEADER"); };

    header_line = header newline;

    main := (req_head newline
             host newline
             header_line*) %eof{ printf("Done!\n"); };

}%%

%% write data;

void print_request(const struct http_request req)
{
    if (req.verb == GET)
        printf("GET %s HTTP/1.1\n", req.path);
}

int parse(char * data) {
    int cs = 0;
    char *p = data, *string_start;
    char *pe = p + strlen(p);
    char *eof = pe;


    struct http_request req;
    req.path = malloc(128);
    bzero(req.path, 128);

    %% write init;
    %% write exec;

    print_request(req);
}
