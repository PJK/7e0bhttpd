#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include "http.h"

int main( int argc, char **argv )
{
	FILE *fp;
	fp = fopen(argv[1], "r");
	fseek(fp, 0, SEEK_END);
	long fsize = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	char *string = malloc(fsize + 1);
	fread(string, fsize, 1, fp);
	fclose(fp);
	string[fsize] = 0;

	parse(string);
	return 0;
}
