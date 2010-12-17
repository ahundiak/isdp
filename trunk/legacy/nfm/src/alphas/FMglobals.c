#include "machine.h"
#include <stdio.h>
#include "MSGstruct.h"
#include "NFMapi.h"

int NETprotocol;

long sqlstatus;
long   NFMuser_id  = 0;
int    NFMitem_loc = 0;
int    NFMrev_loc  = 1;
int    NFMset_ind  = 0;
int    NFMlist_driven = 0;

char   NFMnode[NFM_NODENAME+1]         = {"\0"};
char   NFMstorage[NFM_SANAME+1]        = {"\0"};
char   NFMworking[NFM_SANAME+1]        = {"\0"};
char   NFMloc[NFM_CATALOGNAME+1]       = {"\0"};
char   NFMproject[NFM_PROJECTNAME+1]   = {"\0"};
char   NFMcatalog[NFM_CATALOGNAME+1]   = {"\0"};
char   NFMitem[NFM_ITEMNAME+1]         = {"\0"};
char   NFMrev[NFM_ITEMREV+1]           = {"\0"};
char   NFMset_cat[NFM_CATALOGNAME+1]   = {"\0"};
char   NFMset[NFM_ITEMNAME+1]          = {"\0"};
char   NFMset_rev[NFM_ITEMREV+1]       = {"\0"};
char   NFMsearch_name[NFM_REPORTNAME+1]= {"\0"};
char   NFMsort_name[NFM_REPORTNAME+1]  = {"\0"};
char   NFMserver[15]                   = {"\0"};
char   NFMenv[15]                      = {"\0"};
char   NFMuser[NFM_USERNAME+1]         = {"\0"};
char   NFMpasswd[NFM_PASSWD+1]         = {"\0"};
char   NFMworkflow[NFM_WORKFLOWNAME+1] = {"\0"};
char   NFMacl[NFM_ACLNAME+1]           = {"\0"};
char   NFMprint_file[40]               = {"\0"};
char   msg[256];
char   SCexec[30]   = {""};
char   SCuser_cmd_file[150]= {"/usr/ip32/nfm/config/english/commands/user.dat"};
char   SCadmin_cmd_file[150]= {"/usr/ip32/nfm/config/english/commands/alpha.dat"};

struct NFMwf_info   NFAwf_info;
struct NFMoperation NFAoperation;

int    NFAtoggles[15] = {0};
char   NFAfiles[15][80] = {
"/dev/console","/dev/console","/dev/console","/dev/console","/dev/console",
"/dev/console","/dev/ttn00","/dev/ttn00","/dev/ttn00","/dev/ttn00",
"/dev/ttn00","/dev/ttn00","/dev/ttn00","/dev/ttn00","/dev/ttn00"};
