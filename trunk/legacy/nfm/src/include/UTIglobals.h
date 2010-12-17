int  UTIarchive;
int  UTIbackup;
int  UTIdelete;
int  UTIrestore;
int  UTIarchive_p;
int  UTIbackup_p;
int  UTIrestore_p;
int  UTI_HDISK;
int  UTI_FDISK;
int  UTI_ODISK;
int  UTI_JBOX;
int  UTI_MTAPE;
int  UTI_CTAPE;
int  UTI_UTAPE;
int  UTI_CACHE;
int  UTI_MEDIA;
int  UTI_SS_ALLOCATED;
int  UTI_GROUP_NO;
int  ON_LINE;
int  OFF_LINE;
int  MSG;

long UTI_CLIENT_SA;
long UTI_RES_SA;
long UTIuser_id;

char *UTI_UTILITY;
char *strcpy();
char *strncpy();
char *strcmp();
char *strchr();
char *UTI_WRK_NODE;
char *UTIload();
char *UTIgood_path();
char *UTI_OP_SYS;
char *UTIserver;
char *UTIenv;
char *UTIuser;
char *UTIpasswd;

char UTImsg[256];
char UTI_RSTR_NAME[80];
char UTI_SCRIPT[80];
char UTI_PENDING_FLAGS[3][3];
char UTI_CLIENT_PATH[51];
char UTI_SERVER_PATH[51];
char UTI_ARCHIVE_OPSYS[10];
char UTI_CONFIG[132];

MEMptr UTI_MSG_BUFFER;
MEMptr UTI_ERR_BUFFER;

FILE *fopen();
