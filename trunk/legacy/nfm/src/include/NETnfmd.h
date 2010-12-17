#define MSG_SIZE	128
#define MAXLINE		1024

#define NET_E_BAD_SERVER_TYPE	-1
#define NET_E_NO_SERVER_ENTRY	-2
#define NET_E_BAD_CONFIG_ENTRY	-3
#define NET_E_NO_SERVER_PATH	-4
#define NET_E_MALLOC_ERROR	-5
#define NET_E_NO_CONFIG_FILE	-6
#define SUCCESS			1

FILE *nfmd_err,*nfmd_config ;
char *nfmd_errfile="/dev/console" ;
char *nfmd_configfile="/etc/nfmd.conf" ;

