#include <stdio.h>

#ifdef UNIX
# include "CLI.h"
#else
# include "CLIstruct.h"
# include "proto.h"
# include <memcheck.h>
#endif

/*
int    CLI_FATAL_ERROR = 0;
*/

char   CLIserver[15];
char   CLIenv[15];
char   CLIuser[15];
char   CLIpasswd[15];
char   CLIcatalog[21];
char   CLIitem[61];
char   CLIrev[61];
char   CLIstorage[15]={"\0"};
char   CLIpcid[40]={"\0"};
char   CLIdisplay_file[258] ;
char   CLIadd_item_file[258] ;
char   CLIdefaults_file[258] ;
char   CLIsort [100] ;
char   CLIsearch[100] ;
char   CLIcmd_file[60];
char   CLIhostsfile[60]={"C:\\hosts"};
short  CLIoverwrite=0;
char   CLI_ERR_MSG[200]      = {"\0"};
char   CLIcisaname [50] ;
char   CLIlistpath [300] ;
char   CLIparent [16] ;
char   CLIparent_rev [16] ;

#ifdef UNIX
   MSGptr CLImsg_ptr = {0, "/dev/console", 0, ""}; 
#else
   CLIptr CLImsg_ptr = {0, "/dev/console", 0, ""};
#endif

#ifdef UNIX
struct NFMoperation CLIoperation = {1,1,1};
#else
struct NFMoperation CLIoperation = {0};
#endif
struct NFMwf_info   CLIwf_info   = {0};

FILE   *CLIout_file;
