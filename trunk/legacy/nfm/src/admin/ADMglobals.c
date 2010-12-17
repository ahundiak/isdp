#include "machine.h"
#include <stdio.h>
#include "MSGstruct.h"

MSGptr NFMRmsg_ptr = {0, "/dev/console", 0, ""};

char   SCexec[30]   = {"Admin Utility"};
char   SCuser_cmd_file[150]= {"/usr/ip32/nfm/config/english/commands/env.dat"};
char   SCadmin_cmd_file[150]= {"/usr/ip32/nfm/config/english/commands/env.dat"};

char   NFMprint_file[40]   = {"\0"};
char   msg[250];

char   NFMnode[31]         = {"\0"};
char   NFMstorage[15]      = {"\0"};
char   NFMcatalog[21]      = {"\0"};
char   NFMitem[61]         = {"\0"};
char   NFMrev[41]          = {"\0"};
char   NFMworkflow[21]     = {"\0"};
char   NFMacl[21]          = {"\0"};
char   NFMprogram_num[21]  = {"\0"};
char   NFMserver[15]       = {"\0"};
char   NFMprogram[21]      = {"\0"};
char   NFMpasswd[15]       = {"\0"};
char   NFMenv[15]          = {"\0"};
