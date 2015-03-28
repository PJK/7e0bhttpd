%%{
	machine http;

	main := req_head @ { result = 42; }

	req_head := 'GET ' . /\w+/ . 'HTTP/1.1'
}%%

%% write data;

int parse(char * data) {
    int cs = 0, result = -1;
    char *p = data;
    char *pe = p + strlen(p) + 1;
    %% write init;
    %% write exec;

    printf("result = %i\n", res );
}
