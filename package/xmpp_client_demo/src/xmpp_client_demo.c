/*
* file name: xmpp_client_demo.c
*/
/******************************************************
 *               INCLUDE
 ******************************************************/
#include <stdio.h>  
#include <strings.h>  
#include <unistd.h>  
#include <sys/types.h>  
#include <sys/socket.h>  
//#include <linux/in.h>  
#include <stdlib.h>  
#include <memory.h>  
#include <arpa/inet.h>  
#include <netinet/in.h>  
#include <stdio.h>

/******************************************************
 *               Function Definitions
 ******************************************************/

static char *xmppstream = "<?xml version='1.0'?><stream:stream to = '192.168.100.1' xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0'>";

static char *xmppuser = "<auth xmlns=\"urn:ietf:params:xml:ns:xmpp-sasl\" mechanism=\"PLAIN\">aHVpemhvdTAxADEyMzQ1Ng==</auth>";

static char *newstream = "<?xml version='1.0'?><stream:stream to = '192.168.100.1' xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' version='1.0'>";

static char *bind = "<iq id=\"cF25i-0\" type=\"set\"><bind xmlns=\"urn:ietf:params:xml:ns:xmpp-bind\"><resource>Gent.3</resource></bind></iq>";

static char *session = "<iq xmlns=\"jabber:client\" id=\"cF25i-1\" type=\"set\"><session xmlns=\"urn:ietf:params:xml:ns:xmpp-session\"/></iq>";

static char *online = "<presence id=\"cF25i-32\"><status>Online</status><priority>1</priority></presence>";
int main(int argc, char *argv[])
{
    printf("Programe: xmpp_client_demo start!\n");
    int sockfd;
    char buffer[1024];
    struct sockaddr_in server_addr;
    int portnumber, nbytes;
    if(argc != 3){
        fprintf(stderr, "Usage: %s hostname portnumber\n\a", argv[0]);
        exit(1);
    }
    if(inet_aton(argv[1], &server_addr.sin_addr)==0){
        fprintf(stderr, "the hostip is not right!\n\a");
        exit(1);
    }
    if ((portnumber = atoi(argv[2])) < 0){
    	fprintf(stderr, "Usage: %s hostname portnumber\n\a", argv[0]);
    	exit(1);
    }
    //创建套接字
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
    {
    	fprintf(stderr, "Socket Error:%s\n\a", strerror(errno));   
        exit(1); 
    }
     // 填充服务器的地址信息   
    server_addr.sin_family = AF_INET;   
    server_addr.sin_port = htons(portnumber);   
    // 向服务器发起连接   
    if (connect(sockfd, (struct sockaddr *)&server_addr, sizeof(struct sockaddr)) == -1) {   
        fprintf(stderr, "Connect Error:%s\n\a", strerror(errno));   
        exit(1);   
    }   
    // 连接成功后，从服务器接收信息   
    if ((nbytes = read(sockfd, buffer, 1024)) == -1) {   
        fprintf(stderr, "Read Error:%s\n", strerror(errno));   
        exit(1);   
    }   
    buffer[nbytes] = '\0';   
    printf("I have received:%s\n", buffer);       
    close(sockfd);   
    exit(0); 
    //return 0;
}

