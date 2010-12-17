/* $Revision: 1.1 $ */
#define DBA_NET_BUFFER_SIZE 13312

#define DBA_SERVER_EXIT -1
#define DBA_SQL_STATEMENT 1
#define DBA_SQL_REPORT_ERROR 2
#define DBA_SQL_PREPARE 3
#define DBA_SQL_DECLARE 4
#define DBA_SQL_DESCRIBE 5
#define DBA_SQL_OPEN 6
#define DBA_SQL_FETCH 7
#define DBA_SQL_CLOSE 8
#define DBA_SQL_CLEAR 9

#define DBA_NET_SUCCESS 0
#define DBA_NET_UNKNOWN_HOST 0x1000
#define DBA_NET_NO_SOCKET 0x1001
#define DBA_NET_NO_CONNECT 0x1002
#define DBA_NET_WRITE_FAILED 0x1003
#define DBA_NET_READ_FAILED 0x1004
#define DBA_NET_UNKNOWN_REQUEST 0x1005
#define DBA_NET_NO_SUCH_CURSOR 0x1006

#define ALIGN_OFFSET(offset, type, len) {long mod;if (type != RIS_CHARACTER){if(mod=offset%len) {offset=offset+len-mod;}}}

typedef struct dba_nfm_args_struct
{
    int type;
    char *ptr;
} dba_nfm_args_struct;

#define DBA_NFM_MAXARGS 10
#define DBA_NFM_CHAR 1
#define DBA_NFM_INT 2
