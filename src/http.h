typedef enum {
	GET, POST, HEAD, PUT, PATCH, DELETE, TRACE, CONNECT, OPTIONS
} http_verb;

struct http_request {
	http_verb verb;
	char * path;
};

int parse(char *data);
