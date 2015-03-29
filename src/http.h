#include <stdbool.h>

typedef enum {
	GET, POST, HEAD, PUT, PATCH, DELETE, TRACE, CONNECT, OPTIONS
} http_verb;

typedef enum {
	KEEPALIVE, CLOSE
} http_connection_header;

struct http_request {
	http_verb verb;
	char * path;
	http_connection_header connection;
};

int parse(char *data);
