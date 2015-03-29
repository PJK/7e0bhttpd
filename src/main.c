#include <stdio.h>
#include <stdlib.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <err.h>
#include <unistd.h>
#include <string.h>
#include <sys/fcntl.h>
#include <sys/ioctl.h>
#include <sys/poll.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "http.h"

int main( int argc, char **argv )
{
	int listen_sd = socket(AF_INET6, SOCK_STREAM, 0);
	if (listen_sd < 0)
		perror("socket()");
	struct sockaddr_in6 addr;

	int on = 1;
	int rc = setsockopt(listen_sd, SOL_SOCKET, SO_REUSEADDR, (char *)&on, sizeof(on));
	if (rc < 0)
	{
		perror("setsockopt() failed");
		close(listen_sd);
		exit(-1);
	}

	/*************************************************************/
	/* Bind the socket                                           */
	/*************************************************************/
	memset(&addr, 0, sizeof(addr));
	addr.sin6_family      = AF_INET6;
	memcpy(&addr.sin6_addr, &in6addr_any, sizeof(in6addr_any));
	addr.sin6_port        = htons(1337);
	//rc = setsockopt(listen_sd, IPPROTO_IPV6, IPV6_V6ONLY, &on, sizeof(on));
	if (rc < 0)
	{
		perror("setsockopt() failed");
		close(listen_sd);
		exit(-1);
	}
	rc = bind(listen_sd, (struct sockaddr *)&addr, sizeof(addr));

	if (rc < 0)
	{
		perror("setsockopt() failed");
		close(listen_sd);
		exit(-1);
	}

	listen(listen_sd, 0);

	struct sockaddr_storage client_addr;
	socklen_t addr_len = sizeof(client_addr);
	char numeric_addr[INET6_ADDRSTRLEN];
	int fd = accept(listen_sd, (struct sockaddr*)&client_addr, &addr_len);
	if (fd < 0)
		perror("accept()");
	if(client_addr.ss_family == AF_INET)
		printf("New client from %s\n",inet_ntop(client_addr.ss_family,((struct sockaddr_in*)&client_addr)->sin_addr.s_addr ,numeric_addr,sizeof numeric_addr));
	else if(client_addr.ss_family == AF_INET6)
		printf("New client from %s\n",inet_ntop(client_addr.ss_family,&((struct sockaddr_in6*)&client_addr)->sin6_addr, numeric_addr,sizeof numeric_addr));
	close(listen_sd);
}
