#define		MAXSTR		256
#define 	UTI_HDR_UTILITY   1
#define		UTI_HDR_LOCATION  2
#define		UTI_HDR_SAVESET   3
#define		UTI_HDR_SERVER 	  4
#define		UTI_HDR_ENV	  5
#define		UTI_HDR_USERNAME  6
#define		UTI_HDR_PASSWD	  7
#define		UTI_HDR_PROTOCOL  8
#define		UTI_HDR_SA_NUMBER 9
#define		UTI_HDR_DEVICE   10
#define		UTI_HDR_LABEL	 11
#define		UTI_HDR_GROUP    12

/*  CLIENT ERROR CODES */
/*#define UTI_S_SUCCESS		2000*/
/*#define UTI_E_FAILURE		2010*/
#define UTI_S_SUCCESS           0x080b8009
#define UTI_E_FAILURE		0x080b802a
#define UTI_E_INVALIDUSER	2020
#define UTI_E_BADSCRIPT		2040
#define UTI_E_OPENSCRIPT	2050
#define UTI_E_EXESCRIPT		2060
#define UTI_E_SCONNECT		2070
#define UTI_E_SLOGIN		2080
#define UTI_E_MEMBUILD		2090
#define UTI_E_MEMOPEN		2100
#define UTI_E_MEMWRITEDATA	2110
#define UTI_E_MEMWRITE		2114
#define UTI_E_MEMWRITEFORMAT	2112
#define UTI_E_MEMSPLIT		2116
#define UTI_E_MEMRESET		2118
#define UTI_E_SENDBUFFER	2120
#define UTI_E_RECEIVEBUFFER	2130
#define UTI_E_NOTUPDATED	2140
#define UTI_E_MERGE_SCRIPT	2150

#if UNIX
#define         NFM_SERVER_DEBUG_FILE    "./uti_dbg"
#define         UTILITY_DEBUG_FILE	 "/dev/console"
#endif

#if VMS
#define         NFM_SERVER_DEBUG_FILE    "[]uti.dbg"
#define         UTILITY_DEBUG_FILE	 "[]utidbg.out"
#endif

int		UTILITY;

typedef struct strstruct
{
    char *str;
    struct strstruct *next;
} *strptr;

typedef struct server_dbg
{
    int	   val;
    char   file_name[50];
    struct server_dbg *next;
} *srvdbg;

typedef struct header
{
    char   utility[5];
    char   location[5];
    char   saveset[50];
    char   server[20];
    char   env[20];
    char   username[20];
    char   passwd[50];
    char   protocol[3];
    char   sa_number[5];
    char   device[30];
    char   label[10];
    char   group[10];
}*script_header;

char		*strcpy();
