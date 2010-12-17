/* DISPLAY Server commands */
#define ACCEPTED	10	/* Returned to client if command was accepted */
#define ERROR 		11	/* Returned to client if an error was encountered */

/* WS-PC values definition */
#define IS_WS	701
#define IS_PC	702

/* Size of SPONSOR server's storage buffer. */
#define MAXBUFSIZE 		204800	/* 200k bytes */

/* Size of communication buffer, Clipper and DOS respectively. */
#define WS_MAX_BYTES	32000	/* 32000 bytes, size of communication buffer */
#define PC_MAX_BYTES	8000	/* 8000 bytes, size of communication buffer */

/* Format of data packet header */
typedef struct	mail_msg
{
	long	_from_id;	/* 32 bit integer of who sent message */
	long	_cmd;		/* command */
	long	_size;		/* length of this structure + message */
	long	_parms;		/* Command modifier */
} mail_msg;
