/* $Revision: 1.1 $ */
/* dba_comm.h */
/* Author:  Tim Thompson */

#define DBA_EXEC	1
#define DBA_DESC	2
#define DBA_SELECT	3
#define DBA_FETCH	4
#define DBA_CLOSE	5
#define DBA_ERROR	6
#define DBA_LOGIN	10
#define DBA_RESPONSE	50
#define DBA_SQLDA	51
#define DBA_DATA	52
#define DBA_QUIT	99

#define MAX_SELECT_BUF_SIZE 29696
#define DBA_MSG_SIZE 16

/* Message header for all client/server communication */
typedef struct dba_msg {
    long cmd;
    long size;
    long key;
    long dummy;
    char buf[4];
} dba_msg;

/* Data buffer containing info returned from a select */
/* buf should be used as an array of sqlvar's */
typedef struct dba_fetch_buf {
    long sqlcode;
    long more;
    long curr_row;
    long rows;
    long row_size;
    long dummy;
    sqlda sqlda_buf;
    char buf[4];
} dba_fetch_buf;

/* Contains SQLCODE variable after execution of a DBA_EXEC and the
   text of an error message (if any). */
typedef struct dba_sqlcode {
    long sqlcode;
    char buf[4];
} dba_sqlcode;
