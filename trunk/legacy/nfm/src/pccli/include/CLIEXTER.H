extern  char   CLIserver[15];
extern  char   CLIenv[15];
extern  char   CLIuser[15];
extern  char   CLIpasswd[15];
extern  char   CLIcatalog[21];
extern  char   CLIitem[61];
extern  char   CLIrev[61];
extern  char   CLIstorage[15];
extern  char   CLIpcid[40];
extern  char   CLIcmd_file[60];
extern  char   CLIhostsfile[60];
extern  short  CLIoverwrite;
extern  char   CLIsearch [100];
extern  char   CLIsort [100];
extern  char   CLIdisplay_file [258] ;
extern char    CLIadd_item_file [258] ;
extern char    CLIdefaults_file [258] ;
extern  char   CLI_ERR_MSG[200];
extern  char   CLIcisaname [50];
extern  char    CLIlistpath[300] ;
extern  char   CLIparent [16] ;
extern  char   CLIparent_rev [16] ;
#ifdef UNIX
extern  MSGptr CLImsg_ptr;
#else
extern  CLIptr CLImsg_ptr;
#endif

extern  FILE   *CLIout_file;

extern  struct NFMoperation CLIoperation;
extern  struct NFMwf_info   CLIwf_info;
