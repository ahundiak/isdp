extern char	*sni_accept();
extern char	*sni_connect();
extern char	*sni_txw();
extern char	*sni_rxw();
extern char	*sni_close();

#define MAGIC		0x53414E45
#define	TIMEOUT		0

#define RBSIZE	(62 * 1024)	/* size of the reply buffer below */
#define NETSIZE	(16 * 1024)

#define PRINTERR	fprintf(stderr,
#ifndef MAX
#define MAX(x, y)	((x) > (y) ? (x) : (y))
#endif
#ifndef MIN
#define MIN(x, y)	((x) < (y) ? (x) : (y))
#endif

#define RECEIVE_FILE		0
#define GET_LOAD_KEY		1
#define VERIFY_LOAD_KEY		2
#define DEFINE_USER		3
#define SEND_LOAD_KEY_FILENAME	4
#define GET_VERSION		5
#define INSTALL_PRODUCTS	6
#define END_CONNECTION		9

typedef struct {
	int	req_len;
	int	req_type;
	char	prodpath[OLD_DIR_LEN];
	char	prodname[PRODNAME_LEN];
	char	prodnum[OLD_PRODNUM_LEN];
	char	prodflags[FLAGS_LEN];
	char	loadkey[OLD_KEY_LEN];
	int	iproc;
	char	pad[344];
	unsigned short	revision;
} OLD_REQ;

typedef struct {
	int	req_len;
	int	req_type;
	char	prodpath[DIR_LEN];
	char	prodname[PRODNAME_LEN];
	char	prodnum[PRODNUM_LEN];
	char	prodflags[FLAGS_LEN];
	char	loadkey[KEY_LEN];
	int	iproc;
	char	prodver[VERSION_LEN];
	char	custid[CUSTID_LEN];	/*66*/
	unsigned short authtyp;
	char	pad[180];	/*char	pad[248]; before custid,authtyp*/
	unsigned short	revision;
} REQUEST;


typedef struct {
	int	rep_type;
#define NORMAL		0
#define REPLY_ERROR	1
#define LAST_BUFFER	2
	int	error;
	unsigned int	size;
	unsigned int	cksum;
	int	mode;
	int	owner;
	int	group;
	int	atime;
	int	mtime;
/* 9 ints above this line = 36 bytes leaving 988 bytes to pad up to 1kbyte */
	int	str[247];	/* 247 ints = 988 bytes -- pad out to 1k */
	int	buf[15872];	/* 15872 ints = 62 kbytes of data */
} REPLY;

/*
 * ascii strings for errval are declared in net.c
 */

#define	ERR_RREQ	0
#define	ERR_MOUNT	1
#define	ERR_OPEN	2
#define	ERR_STAT	3
#define	ERR_READ	4
#define	ERR_NOKEY	5
#define	ERR_NABDR	6
#define	ERR_USER	7
#define	ERR_NOKEYFILE	8
#define	ERR_NOSUCHREQUEST	9
#define	ERR_ZERO	10
#define ERR_PERM	11
#define	ERR_NOSNFILE	12
