/* $Revision: 1.1 $ */
#ifndef dba_nfm_global
#define dba_nfm_global
#include "dbn_defs.h"
/*
	NFM connection id's
*/
int dba_nfm_netid, dba_nfm_userid;
/*
	NFM data from the control file
*/
char dba_nfm_server[64], dba_nfm_user[64], 
     dba_nfm_passwd[64], dba_nfm_env[64];
int dba_nfm_dbg = 0;
/*
	NFM Mode Active Flag
*/
int dba_nfm_active = 0;
int dba_nfm_connected = 0;
int dba_nfm_message_init = 0;
/*
	Data storage for the functions that build
        up a list and then act on the list.

	Checkin Multiple files per item
*/
char *dba_nfm_filelist = NULL;
int  dba_nfm_num_files = 0;
/*
	Create Catalog with user defined columns, and
	Add Item when user defined columns are present
*/
char *dba_nfm_c_names = NULL, *dba_nfm_c_types = NULL, 
     *dba_nfm_c_synonyms = NULL, *dba_nfm_values = NULL;

int dba_nfm_num_columns = 0;
/*
	Add list of items to a set
*/
struct NFMmember_info *dba_nfm_member_info;
int dba_nfm_num_items = 0;

char dba_nfm_error_message[1024] = {'\0'};

/*
    Workflow and Local File Manager Flags
*/
int dba_nfm_lfm = 1;
extern int dba_nfm_workflow;

#endif
