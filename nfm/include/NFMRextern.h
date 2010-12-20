#include <stdio.h>
#include "MSGstruct.h"
#include "NFIerrordef.h"
#include "NFMRinclude.h"
#include "NDXstruct.h"
#include "NFMschema.h"

extern FILE *CLout;

extern int NETprotocol;

extern long sqlstatus;

extern int  NFMlist_driven;
extern int  NFMset_ind;
extern int  NFMitem_loc;
extern int  NFMrev_loc;
extern char NFMnode[NFM_NODENAME+1];
extern char NFMstorage[NFM_SANAME+1];
extern char NFMworking[NFM_SANAME+1];
extern char NFMloc[NFM_CATALOGNAME+1];
extern char NFMproject[NFM_PROJECTNAME+1];
extern char NFMcatalog[NFM_CATALOGNAME+1];
extern char NFMitem[NFM_ITEMNAME+1];
extern char NFMrev[NFM_ITEMREV+1];
extern char NFMset_cat[NFM_CATALOGNAME+1];
extern char NFMset[NFM_ITEMNAME+1];
extern char NFMset_rev[NFM_ITEMREV+1];
extern char NFMver[NFM_FILEVERSION+1];
extern long NFMuser_id;
extern char NFMsearch_name[NFM_REPORTNAME+1];
extern char NFMsort_name[NFM_REPORTNAME+1];
extern char NFMserver[15];
extern char NFMenv[15];
extern char NFMuser[NFM_USERNAME+1];
extern char NFMpasswd[NFM_PASSWD+1];
extern char NFMworkflow[NFM_WORKFLOWNAME+1];
extern char NFMacl[NFM_ACLNAME+1];
extern char NFMprint_file[40];
extern char msg[256];
extern int  NFAtoggles[NFM_DEBUG_SUBSYSTEMS];
extern char NFAfiles[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];

extern MSGptr NFMRmsg_ptr;
extern MSGptr NFMmsg_ptr;
extern MSGptr MEMmsg_ptr;

extern struct NFMRglobal_st NFMRglobal;
