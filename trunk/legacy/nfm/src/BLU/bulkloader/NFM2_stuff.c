#include <stdio.h>
#include <string.h>

#include "DEBUG.h"
#include "ERR.h"
#include "ERRerrordef.h"
#include "ERRproto.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "NETerrordef.h"
#include "NFMerrordef.h"
#include "NFMschema.h"
#include "SQLerrordef.h"

#include "NFMapi.h"
#include "NFIerrordef.h"
#include "MDSstruct.h"
#include "WFcommands.h"
#include "NFM2_errors.h"

#include "UMS.h"
#include "BLdefs.h"


#define	RED_MODIF_COMP	"redline modification complete"
#define	RED_APPROVAL	"redline approval"
#define	COMPLETE	"complete"
#define	REJECTED	"rejected"

long	NFM2_find_matching_filename();

#define	MAX_NFM_CURSORS		50
long	NumberOfRowsRetrieved[MAX_NFM_CURSORS]={0};
long	SpecifiedRowCount[MAX_NFM_CURSORS]={0};
char	*CursorSpecificSqlStatement[MAX_NFM_CURSORS]={0};
long	Number_Of_Rows_Retrieved={0};
long	Specified_Row_Count={0};

MEMptr  sql_buffer = NULL;

MEMptr	data_list = NULL,	page_list = NULL,	title_list = NULL,
	header_list = NULL,	footer_list = NULL,	select_list = NULL,
	grp_begin_list = NULL,	grp_text_list = NULL,	eop_text_list = NULL,
	eor_text_list = NULL,	attr_list = NULL,	value_list = NULL,
	info = NULL,		syn_list  = NULL;

#define	STORAGE_AREA_NO		0L
#define	STORAGE_AREA_NAME	1L

#define	NFM_SUCCESS		0L
#define	MEM_SUCCESS		1L
#define	SQL_SUCCESS		4L
#define	NET_SUCCESS		5L
#define	ERR_SUCCESS		6L
#define	MAX_SUCCESS_CODES	7L
long	SUCCESS_CODE[MAX_SUCCESS_CODES]={0,0,0,0,0,0,0};
char	SUCCESS_CODES[MAX_SUCCESS_CODES][8]={"NFM","MEM","","","SQL","NET","ERR"};

long	status2;

long	IssueAutoCommitStatement={1};

long DSUSERID, DSdebug, NetId;

char		xns_address[80],tcp_address[80],Nodename[80];
char		properties[15][80];
char             DSerror_msg[80];     /* the error message */

extern struct	_ERRstruct	_ERRstruct;

#define	MaxFileNames		50
#define	MAX_NFM_MESSAGES	10
char	NFM_Error_Messages[MAX_NFM_MESSAGES][512];
long	NFM_Messages={0};
long	Initialize_NFM_Messages={1};
long	Number_Of_Rows_From_Sql={0};

long	NFM2_clear_messages();
long	NFM2_check_status();
long	SS_load_sql_statement();
long	Previous_SQL_Rows();

FILE	*nfm2dbg={NULL};

static char *manditory_ddl="set transaction autocommit on";

/* Pre-declare the functions */
long    NFMa_login();
long    NFM2_login();
long    NFM2_logout();
long    NFMa_checkin_mult_item();
long    NFM2_checkin_item();
long    NFM2_checkin_mult_item();
long    MY_NFM2_checkin_mult_item();
long    NFMa_simple_checkin_item();
long    NFMa_create_default_wa();
long    NFMa_add_file_entry();
long    NFMa_remove_file_entry();
long    NFMa_change_file_entry();
long    NFM2_checkout_item();
long    MY_NFM2_checkout_mult_item();
long    NFMa_simple_checkout_item();
long    NFM2_list_catalogs();
long    NFM2_list_items();
int     NFM2_list_generic();
int     NFM2_copy_item();
long    NFMa_simple_copy_item();
long    NFMa_add_item();
long    NFM2_add_item();
int     NFM2_properties();
int     NFM2_schema_password();
int     NFM2_schema_definition();
long    NFMa_delete_catalog();
long    NFM2_query_catalog_template();
long    NFM2_query_catalog_definition();
int     NFM2_copy_item_validation();
long    NFM2_load_workflow();
long    NFM2_add_acl();
long    NFM2_add_acl_user();
long    NFM2_delete_acl_user();
long    NFM2_add_user();
long    NFM2_add_storage_area();
long    NFM2_add_node();
long    Previous_SQL_Rows();
long    SS_sql();
long    NFM2_close_buffers();
long    NFM2_print_separation();
long    NFM2_clear_messages();
long    NFM2_get_current_message();
long    NFM2_check_status();
long    get_nfm_error_message();
int     NFM2_set_to_state();
int     NFM2_dmd_set_to_state();
int     NFM2_debug_message();
int     NFM2_open_nfm2_debug_file();
int     NFM2_generic_item_transition();
int     NFM2_transition_yes();
int     NFM2_transition_no();
long    NFM2_generic_cancel();
long    NFM2_find_matching_filename();
long    SS_sql_statement();
long    NFMa_add_set();
long    NFMa_flag_item_delete();
long    NFMa_delete_item();
int     NFMa_add_project_item();
int     NFMa_add_item_set();
long    NFMa_update_item();
long    NFMa_find_cifilename();
long    NFMa_sa_information();
long    NFMa_storage_area_names();
int     NFMa_create_d_();
int     NFMa_create_ref_doc();
int     NFMa_create_table();
int     NFMa_make_index();
long    NFMa_single_select();
long    NFMa_multi_select();
int     NFMa_write_d_();
int     lowcase();
long    NFM2_create_catalog();
int     NFM2_build_new_cat_field();
int     NFM2_modify_cat_field();
int     NFM2_modify_catalog();
char*	NFMa_ticked();
long	SQL_get_valid_cursor_number();
long	SQL_Free_Cursor();
long	SQL_Check_For_Select();


/*
  Note:  The following functions were made non-functional by NFM 3.0.x.  They
           have been saved for historic purposes.  The old prefix of NFM2 or
           NFMa was replaced by NFMb.
         They should never be called although NFM claims they still work.

long NFMb_checkout_item();
int  NFMb_copy_item();
long NFMb_checkin_mult_item();
*/


/******************************************************************************

Doc:    NFM2_login

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_login(server,
                              environment,
                              user,
                              password,
                              debuglevel
                              client_id);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_login(server,environment,user,password,debuglevel,client_id)
   char	*server;      /* I - NFM server to login to */
   char *environment; /* I - NFM environment to login to */ 
   char *user;        /* I - NFM user to login as */
   char *password;    /* I - NFM password to user */
   long	debuglevel;   /* I - Level of debug to use (0-9) 0=off */
   long client_id;    /* I - ?? */
{
   return(NFMa_login(server,environment,user,password,debuglevel,client_id));
}


/******************************************************************************

Doc:    NFM2_logout

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Disconnects and logs out of NFM

Examples:
          status = NFM2_logout();

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_logout()
{
	long	status;
	if (DSUSERID > 0)
		{
		NFM2_clear_messages("NFM2_logout");
		NFM2_format_debug_message("NFM2_logout - Calling NFMRlogout - UserId %d",DSUSERID);
		NFMRlogout(DSUSERID);
		NFM2_debug_message("NFM2_logout - Calling NFMRterminate");
		status = NFMRterminate();
		NFM2_format_debug_message("NFM2_logout - Status From NFMRterminate - %d",status);

		NFMRget_host_info(DSUSERID,1);

		return status;
		}
	else			{return 0;}
}


/******************************************************************************

Doc:    NFM2_checkin_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Checks in a single file to an item, or a single item to a set.
        If using to check in to a set, subsitute set information where item
           info is now.
        You must enter EITHER the storage area OR the node/user/password/path
           that the file will come from.  Both sets of information are not
           needed.

Examples:
          status = NFM_checkin_item(catalog_name,
                                    item_name,
                                    item_revision,
                                    storage_area,
                                    temporary_node,
                                    temporary_user,
                                    temporary_password,
                                    temporary_path,
                                    co_filename,
                                    checkin_type);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_checkin_item(catalog_name,item_name,item_revision,storage_area,
                       temporary_node,temporary_user,temporary_password,
                       temporary_path,file_name,checkin_type)
   char *catalog_name;       /* I - NFM catalog containing the item */
   char *item_name;          /* I - item name check in */
   char *item_revision;      /* I - item revision to check in */
   char *storage_area;       /* I - storage area that the file comes from */
   char *temporary_node;     /* I - node that file comes from */
   char *temporary_user;     /* I - user on the node that the file comes from */
   char *temporary_password; /* I - password of above user */
   char *temporary_path;     /* I - path to the file */
   char *file_name;          /* I - file to check in */
   char *checkin_type;       /* I - flag indicating item or set
                                    values are: CHECKIN_ITEM
                                                CHECKIN_SET */
{
   return(NFMa_checkin_mult_item(catalog_name
                                ,item_name
                                ,item_revision
                                ,storage_area
                                ,temporary_node
                                ,temporary_user
                                ,temporary_password
                                ,temporary_path
                                ,1
                                ,&file_name
                                ,NULL
                                ,NULL
                                ,NULL
                                ,NULL
                                ,checkin_type));
}


/******************************************************************************

Doc:    NFMb_checkout_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Checks out the files in an item.
        The default filenames can be changed for each file by supplying them
           in the parameter 'filename'.  Format for 'file_name' is:
                #<num_of_files>~<file_name1>~<file_name2>...~<file_nameX>~

Examples:
          status = NFMb_checkout_item(catalog_name,
                                      item_name,
                                      item_revision,
                                      storage_area,
                                      filename);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers
  02/16/92  wrw  -replaced by new NFM routines.  Left here for historic
                    perspective.

******************************************************************************/
long NFMb_checkout_item(catalog_name,item_name,item_revision,storage_area
                       ,filename)
   char *catalog_name;   /* I - name of the NFM catalog */
   char *item_name;      /* I - item name to checkout */
   char *item_revision;  /* I - item revision to checkout */
   char *storage_area;   /* I - storage area to put files in */
   char *filename;       /* I - replacements for the default file names */
{
	/* Local declarations */

	char      **attributes;    /* Attribute list */
	long      i;               /* Counter */
	long      num_attrs;       /* Number of attributes */
	long      status;          /* Return status */
	long	loop,numfiles;
	char	file_name[2048],*token=NULL;
	char	*FileNames[MaxFileNames];

	NFM2_clear_messages("NFMb_checkout_item");
	NFM2_format_debug_message("NFMb_checkout_item -\tCatalog <%s> Item <%s> Revision <%s> SA <%s>\n\t\t\tFile Name(s) <%s>",
		catalog_name,item_name,item_revision,storage_area,filename);

	strcpy(file_name,filename);
	if (strcmp(file_name,"") != 0)
		{
		for (loop = 0; loop < MaxFileNames; loop++)	{FileNames[loop] = (char *)NULL;}
		if (file_name[0] == '#')
			{
			token = (char *)strtok(file_name,"~");
			token = (char *)strtok((char *)NULL,"~");
                        numfiles = atoi(token);
                        FileNames[0] = token = (char *)strtok((char *)NULL,"~");
                        for (loop = 1; loop < numfiles; loop++) {FileNames[loop] = (char *)strtok((char *)NULL,"~");}
			}
		else
			{
			strcat(file_name,"~");
			FileNames[0] = token = (char *)strtok(file_name,"~");
			}
		}

	status = NFMRvalidate_user_access ( DSUSERID, CHECKOUT_ITEM, "", "", catalog_name, item_name, item_revision );
	NFM2_format_debug_message("DScheckout_item After NFMRvalidate - status = %D", status );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end;
	status = NFMRprepare_item_checkout ( DSUSERID, catalog_name, item_name, item_revision, &attr_list, &data_list );
	NFM2_format_debug_message("DScheckout_item After NFMRprepare - status = %D", status );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRprepare_item_checkout") ) goto end;

	if ( DSdebug > 4 )	{MEMprint_buffer("ATTRIBUTE LIST ", attr_list,  NULL);	MEMprint_buffer("DATA LIST", data_list,  NULL);}

	/**********************************************
    * Fill in the data buffer with the necessary *
    * checkout item information.                 *
    **********************************************/

	attributes = (char **) data_list->column_ptr;
	num_attrs = data_list->columns;

	if ( DSdebug > 3 )	{ for ( i = 0; i < num_attrs; ++i ) { NFM2_format_debug_message("attribute[%d] = %s", i, attributes[i] ); }	}

	for ( i = 0; i < num_attrs; ++i )
	{
		if ( DSdebug > 3) NFM2_format_debug_message("Attribute[%d] = %s", i, attributes[i] );
		if ( !strcmp ( attributes[i], "n_cofilename" ) )
		{
			if (strcmp(filename,"") != 0)
				{
				for (loop = 1; loop <= data_list->rows; loop++)
					{
					if (strcmp(token,"") != 0)
						{
						NFM2_format_debug_message("NFMb_checkout_item - File %d of %d is <%s>",(loop+1),data_list->rows,token);
						status = MEMwrite_data ( data_list, token, loop, i+1);
						if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
						token = FileNames[loop];
						}
					}
				}
		}
	}

	if ( DSdebug > 4 ) MEMprint_buffer("DATA LIST after MDMwrite data", data_list,  NULL);

	/**************************************
    * Do the actual checkout of the item. *
    **************************************/

	status = NFMRcomplete_item_checkout ( DSUSERID, storage_area, "", "", "", "", attr_list, data_list );
	NFM2_format_debug_message("DScheckout_item After NFMRcomplete - status = %D", status );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRcomplete_item_checkout") ) goto end;
	status = 0;
	NFM2_set_to_state ( );
	NFM2_format_debug_message("Exiting NFMb_checkout_item - status = %D", status );
	return ( status );

end:
	/*********************************
    * Tell NFM how everything went. *
    *********************************/
	if ( status != NFM_S_SUCCESS ) 
		{
		status = NFMRcancel_item_checkout ( DSUSERID, attr_list, data_list );
		NFM2_check_status(status,NFM_SUCCESS,"NFMRcancel_item_checkout");
		}
	NFM2_set_to_state ( );
	NFM2_format_debug_message("Exiting NFMb_checkout_item - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_checkout_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Checks out the files in an item.
        The default filenames can be changed for each file by supplying them
           in the parameter 'filename'.  Format for 'file_name' is:
                #~<num_of_files>~<file_name1>~<file_name2>...~<file_nameX>~

Examples:
          status = NFM2_checkout_item(catalog_name,
                                      item_name,
                                      item_revision,
                                      storage_area,
                                      filename);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers
  02/10/92  wrw  -rewritten to use new NFM functions.

******************************************************************************/
long NFM2_checkout_item(catalog_name,item_name,item_revision,storage_area
                       ,filename)
   char *catalog_name;   /* I - name of the NFM catalog */
   char *item_name;      /* I - item name to checkout */
   char *item_revision;  /* I - item revision to checkout */
   char *storage_area;   /* I - storage area to put files in */
   char *filename;       /* I - replacements for the default file names */
{
long   i;               /* Counter */
long   status;          /* Return status */
long   loop,db_files,numfiles;
char   sql_line[500],value[80],*error_m;
char   version[40];
char   file_name[2048],*token;
char  *FileNames[MaxFileNames];
char  *my_buff;

   NFM2_clear_messages("NFM2_checkout_item");
   NFM2_format_debug_message("NFM2_checkout_item -\tCatalog <%s> Item <%s> Revision <%s> SA <%s>\n\t\t\tFile Name(s) <%s>",
                   catalog_name,item_name,item_revision,storage_area,filename);

   my_buff = (char *) malloc(5000*sizeof(char));
   if (!my_buff) return(1);

	numfiles=0;
   strcpy(file_name,filename);
   if (filename && file_name[0]) {
		for (loop = 0; loop < MaxFileNames; loop++) {
			FileNames[loop] = (char *)NULL;
			}

		if (file_name[0] == '#') {
			token = (char *)strtok(file_name,"~");
			token = (char *)strtok((char *)NULL,"~");
			numfiles = atoi(token);
			FileNames[0] = token = (char *)strtok((char *)NULL,"~");
			for (loop = 1; loop < numfiles; loop++) {
				FileNames[loop] = (char *)strtok((char *)NULL,"~");
				}
			}
		else {
			numfiles=1;
			strcat(file_name,"~");
			FileNames[0] = token = (char *)strtok(file_name,"~");
			}
		}

/* look at files that are currently found in this record */
   db_files=0;
/*
   sprintf(sql_line,"select n_fileversion,n_fileno,n_cofilename,n_cifilename,n_cosano,n_cisano from %s,f_%s where n_itemname='%s' and n_itemrev='%s' and n_itemno=n_itemnum order by n_fileversion desc, n_fileno asc"
*/
   sprintf(sql_line,"select n_fileversion,n_fileno,n_cofilename,n_cifilename,n_cosano,n_cisano from %s,f_%s where n_itemname='%s' and n_itemrev='%s' and n_itemno=n_itemnum and n_cofilename is not NULL and n_fileversion=(select max(n_fileversion) from f_%s where n_itemnum=n_itemno)"
          ,catalog_name,catalog_name,NFMa_ticked(item_name)
          ,NFMa_ticked(item_revision),catalog_name);
   status = NFMa_multi_select(sql_line,5000,my_buff,"n_fileversion",1,value
                             ,&error_m);
   if (status && status!=-1) return (status);

/* find number of files in database */
   strcpy(version,value);
   while (!status) {
      status=NFMa_multi_select(NULL,0,my_buff,"n_fileversion",db_files+1,value
                              ,&error_m);
      if (status || strcmp(version,value))
         break;
      db_files++;
      }

/* see if any files need information changed in the database */
   for (i=0;i<numfiles && i<db_files;i++) {
      NFMa_multi_select(NULL,0,my_buff,"n_cofilename",i+1,value,&error_m);
      if (!strcmp(FileNames[i],value))
         continue;
      status=NFMa_change_file_entry(catalog_name,item_name,item_revision
                                   ,value,FileNames[i],NULL,NULL,NULL,NULL);
      if (status) return(status);
      }

   status = NFMa_simple_checkout_item(catalog_name,item_name,item_revision
                                     ,storage_area);
   return(status);
}


/******************************************************************************

Doc:    NFMa_simple_checkout_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   January 23, 1992

Description:
        Checks out an item that already has all file information provided 
           correctly.

Examples:
          status = NFMa_simple_checkout_item(catalog_name,
                                             item_name,
                                             item_revision,
                                             storage_area);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:

******************************************************************************/
long NFMa_simple_checkout_item(catalog_name,item_name,item_revision,storage_area)
   char *catalog_name;   /* I - name of catalog to user */
   char *item_name;      /* I - name of item to checkin */
   char *item_revision;  /* I - revsion of item to checkin */
   char *storage_area;   /* I - storage area the files will come from */
{
long status;
struct NFMwf_info wf_info;
struct NFMoperation operation;
   
   NFM2_clear_messages("NFMa_simple_checkout_item");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s>",catalog_name,item_name
                            ,item_revision,storage_area);

   wf_info.workflow=NFM_WORKFLOW;
   strcpy(wf_info.command,CHECKOUT_ITEM);
   wf_info.workflow_name[0]=0;
   wf_info.project_name[0]=0;
   wf_info.app_name[0]=0;

   operation.transfer=NFM_TRANSFER;
   operation.delete=NFM_DELETE_FILES;
   operation.purge=NFM_PURGE;

   status = NFMRcheckout_item(catalog_name,-1,NFMa_ticked(item_name)
                             ,NFMa_ticked(item_revision)
                            ,storage_area,wf_info,operation);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRcheckout_item");
   NFM2_format_debug_message("Status After NFMRcheckout_item %D",status);

   if (status == NFM_S_SUCCESS)
      status = 0;

   return(status);
}


/******************************************************************************

Doc:    NFM2_list_catalogs

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_list_catalogs(num_columns,
                                      num_catalogs,
                                      columns,
                                      catalogs);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_list_catalogs ( num_columns, num_catalogs, columns, catalogs )
   long   *num_columns;       /* O - Number of columns */
   long   *num_catalogs;      /* O - Number of catalogs */
   char   ***columns;         /* O - Column names */
   char   ***catalogs;        /* O - Catalog names */
{
	long      status;          /* Return status */

	NFM2_clear_messages("NFM2_list_catalogs");
	status = NFMRdisplay_catalogs("","",NFM_FULL_DISPLAY,&syn_list
                                     ,&data_list);
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRlist_catalogs") ) goto end;
	status = MEMbuild_array ( data_list );
	if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
	*catalogs = (char **) data_list->data_ptr;
	*columns = (char **) data_list->column_ptr;
	*num_catalogs = data_list->rows * data_list->columns;
	*num_columns = data_list->columns;
	status = 0;

end:
	NFM2_format_debug_message("Exiting NFM2_list_catalogs - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_list_items

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_list_items(catalog_name,
                                   num_columns,
                                   num_items,
                                   columns,
                                   items);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_list_items ( catalog_name, num_columns, num_items, columns, items )
   char   *catalog_name;      /* Catalog name */
   long   *num_columns;       /* Number of columns */
   long   *num_items;         /* Number of items */
   char   ***columns;         /* Column names */
   char   ***items;           /* Item names and revisions */
{
	long      status;          /* Return status */

	NFM2_clear_messages("NFM2_list_items");
	status = NFMRdisplay_items(catalog_name,"","",NFM_FULL_DISPLAY
                                  ,&syn_list,&data_list);
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRdisplay_items") ) goto end;
	if ( DSdebug > 4 ) MEMprint_buffers ("DATA LIST after MDMwrite data", data_list,  NULL);
	status = MEMbuild_array ( data_list );
	if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
	*columns = (char **) data_list->column_ptr;
	*items = (char **) data_list->data_ptr;
	*num_items = data_list->rows * data_list->columns;
	*num_columns = data_list->columns;
	status = 0;
end:
	NFM2_format_debug_message("Exiting NFM2_list_items - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_list_generic

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_list_generic(option,
                                     num_columns,
                                     num_items,
                                     columns,
                                     values);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFM2_list_generic ( option, num_columns, num_items, columns, values )
   int   option;      /* I - 0=Storage Areas; 1=Nodes; 2=Users; 3=Workflows*/
   long *num_columns; /* O - Number of columns names */
   long *num_items;   /* O - Number of rows */
   char ***columns;   /* O - Column names */
   char ***values;    /* O - Data values */
{
	long      status;          /* Return status */

	NFM2_clear_messages("NFM2_list_generic");
	switch (option)
	{
	case 0:	status = NFMRdisplay_storage_areas("","",NFM_FULL_DISPLAY
                                                  ,&syn_list,&data_list);
                break;
	case 1:	status = NFMRdisplay_nodes("","",NFM_FULL_DISPLAY,&syn_list
                                          ,&data_list );
                break;
	case 2:	status = NFMRdisplay_users("","",NFM_FULL_DISPLAY,&syn_list
                                          ,&data_list);
                break;
	case 3:	status = NFMRdisplay_workflows("", "",NFM_FULL_DISPLAY
                                              ,&syn_list,&data_list );
                break;
	default:status = NFMRdisplay_storage_areas("","",NFM_FULL_DISPLAY
                                                  ,&syn_list,&data_list);
                         break;
	}
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRlist_<generic>") ) goto end;
	status = MEMbuild_array ( data_list );
	if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
	*columns = (char **) data_list->column_ptr;
	*values = (char **) data_list->data_ptr;
	*num_items = data_list->rows * data_list->columns;
	*num_columns = data_list->columns;
	status = 0;
end:
	NFM2_format_debug_message("Exiting NFM2_list_generic - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFMb_copy_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Copies out the files in an item.
        The default filenames can be changed for each file by supplying them
           in the parameter 'filename'.  Format for 'file_name' is:
                #<num_of_files>~<file_name1>~<file_name2>...~<file_nameX>~

Examples:
          status = NFMb_copy_item(catalog_name,
                                      item_name,
                                      item_revision,
                                      storage_area,
                                      filename);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers
  02/25/92  wrw  -replaced by new NFM routines.  Left here for historic
                    perspective.

******************************************************************************/
int NFMb_copy_item(catalog_name,item_name,item_revision,storage_area,filename)
   char *catalog_name;   /* I - name of the NFM catalog */
   char *item_name;      /* I - item name to checkout */
   char *item_revision;  /* I - item revision to checkout */
   char *storage_area;   /* I - storage area to put files in */
   char *filename;       /* I - replacements for the default file names */
{
	char      **attributes;    /* Attribute list */
	long      i;               /* Counter */
	long      num_attrs;       /* Number of attributes */
	long      status;          /* Return status */
	long	loop,numfiles;
	char	file_name[2048],*token=NULL;
	char	*FileNames[MaxFileNames];

	NFM2_clear_messages("NFMb_copy_item");
	strcpy(file_name,filename);
	if (strcmp(file_name,"") != 0)
		{
		for (loop = 0; loop < MaxFileNames; loop++)	{FileNames[loop] = (char *)NULL;}
		if (file_name[0] == '#')
			{
			token = (char *)strtok(file_name,"~");
			token = (char *)strtok((char *)NULL,"~");
			numfiles = atoi(token);
			FileNames[0] = token = (char *)strtok((char *)NULL,"~");
			for (loop = 1; loop < numfiles; loop++)	{FileNames[loop] = (char *)strtok((char *)NULL,"~");}
			}
		else
			{
			strcat(file_name,"~");
			FileNames[0] = token = (char *)strtok(file_name,"~");
			}
		}

	/****************************************
    * See if the user has the authority to *
    * copy an item.                        *
    ****************************************/

	status = NFMRvalidate_user_access ( DSUSERID, COPY_ITEM_FILES, "", "", catalog_name, item_name, item_revision );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end;

	/******************************
    * Prepare the item for copy. *
    ******************************/

	status = NFMRprepare_item_copy ( DSUSERID, catalog_name, item_name, item_revision, &attr_list, &data_list );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRprepare_item_copy") ) goto end;
	if ( DSdebug > 4 )	{MEMprint_buffer("ATTRIBUTE LIST ", attr_list,  NULL); MEMprint_buffer("DATA LIST", data_list,  NULL);}

	/**********************************************
    * Fill in the data buffer with the necessary *
    * copy item information.                     *
    **********************************************/

/*
status = MEMbuild_array ( data_list );
if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
status = MEMbuild_array ( attr_list );
if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
ptr1 = (char **) data_list->data_ptr;
ptr2 = (char **) data_list->column_ptr;
ptr3 = (char **) attr_list->data_ptr;
ptr4 = (char **) attr_list->column_ptr;
*/


	attributes = (char **) data_list->column_ptr;
	num_attrs = data_list->columns;

	if ( DSdebug > 3 )	{for ( i = 0; i < num_attrs; ++i )	{NFM2_format_debug_message("attribute[%d] = %s", i, attributes[i] );}}
	for ( i = 0; i < num_attrs; ++i )
	{
		if ( DSdebug > 3)	NFM2_format_debug_message("Attribute[%d] = %s", i, attributes[i] );
		if ( !strcmp ( attributes[i], "n_cofilename" ) )
		{
			if (strcmp(filename,"") != 0)
				{
				for (loop = 1; loop <= data_list->rows; loop++)
					{
					if (strcmp(token,"") != 0)
						{
						NFM2_format_debug_message("NFMb_copy_item - File %d of %d is <%s>",loop,data_list->rows,token);
						status = MEMwrite_data ( data_list, token, loop, i+1);
						if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
/*
	strcpy(current_name,token);NFM2_find_matching_filename(cofiles[loop],filename,current_name,external_name);
*/
						token = FileNames[loop];
						}
					}
				}
		}

	} /* END FOR ( i = 0; i < num_attrs; ++i ) */

	if ( DSdebug > 4 )	MEMprint_buffer("DATA LIST after MDMwrite data", data_list,  NULL);

	/**************************************
    * Do the actual copying of the item. *
    **************************************/

	status = NFMRcomplete_item_copy ( DSUSERID, storage_area, "", "", "", "", attr_list, data_list );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRcomplete_item_copy") ) goto end;
	status = 0;
	NFM2_format_debug_message("Exiting NFMb_copy_item - status = %D", status );
	NFM2_set_to_state ( );
	return ( status );
end:
	status = NFMRcancel_item_copy ( DSUSERID, attr_list, data_list );
	NFM2_check_status(status,NFM_SUCCESS,"NFMRcancel_item_copy");
	NFM2_format_debug_message("Exiting NFMb_copy_item - status = %D", status );
	NFM2_set_to_state ( );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_copy_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Copies out the files in an item.
        The default filenames can be changed for each file by supplying them
           in the parameter 'filename'.  Format for 'file_name' is:
                #<num_of_files>~<file_name1>~<file_name2>...~<file_nameX>~

Examples:
          status = NFM2_copy_item(catalog_name,
                                      item_name,
                                      item_revision,
                                      storage_area,
                                      filename);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers
  02/25/92  wrw  -rewrote to use new NFM3.0.x functionality.

******************************************************************************/
int NFM2_copy_item(catalog_name,item_name,item_revision,storage_area,filename)
   char *catalog_name;   /* I - name of the NFM catalog */
   char *item_name;      /* I - item name to checkout */
   char *item_revision;  /* I - item revision to checkout */
   char *storage_area;   /* I - storage area to put files in */
   char *filename;       /* I - replacements for the default file names */
{
long   i;               /* Counter */
long   status;          /* Return status */
long   loop,db_files,numfiles=0;
char   sql_line[500],value[80],*error_m;
char   version[40];
char   file_name[2048],*token;
char  *FileNames[MaxFileNames];
char  *my_buff;

   NFM2_clear_messages("NFM2_checkout_item");
   NFM2_format_debug_message("NFM2_checkout_item -\tCatalog <%s> Item <%s> Revision <%s> SA <%s>\n\t\t\tFile Name(s) <%s>",
                   catalog_name,item_name,item_revision,storage_area,filename);

   my_buff = (char *) malloc(5000*sizeof(char));
   if (!my_buff) return(1);

   strcpy(file_name,filename);
   if (strcmp(file_name,"") != 0) {
     for (loop = 0; loop < MaxFileNames; loop++) {
        FileNames[loop] = (char *)NULL;
        }

     if (file_name[0] == '#') {
        token = (char *)strtok(file_name,"~");
        token = (char *)strtok((char *)NULL,"~");
        numfiles = atoi(token);
        FileNames[0] = token = (char *)strtok((char *)NULL,"~");
        for (loop = 1; loop < numfiles; loop++) {
           FileNames[loop] = (char *)strtok((char *)NULL,"~");
           }
        }
     else {
        strcat(file_name,"~");
        FileNames[0] = token = (char *)strtok(file_name,"~");
        }
     }

/* look at files that are currently found in this record */
   db_files=0;
/*
   sprintf(sql_line,"select n_fileversion,n_fileno,n_cofilename,n_cifilename,n_cosano,n_cisano from %s,f_%s where n_itemname='%s' and n_itemrev='%s' and n_itemno=n_itemnum order by n_fileversion desc, n_fileno asc"
*/
   sprintf(sql_line,"select n_fileversion,n_fileno,n_cofilename,n_cifilename,n_cosano,n_cisano from %s,f_%s where n_itemname='%s' and n_itemrev='%s' and n_itemno=n_itemnum and n_cofilename is not NULL and n_fileversion=(select max(n_fileversion) from f_%s where n_itemnum=n_itemno)"
          ,catalog_name,catalog_name,NFMa_ticked(item_name)
          ,NFMa_ticked(item_revision),catalog_name);
   status = NFMa_multi_select(sql_line,5000,my_buff,"n_fileversion",1,value
                             ,&error_m);
   if (status && status!=-1) return (status);

/* find number of files in database */
   strcpy(version,value);
   while (!status) {
      status=NFMa_multi_select(NULL,0,my_buff,"n_fileversion",db_files+1,value
                              ,&error_m);
      if (status || strcmp(version,value))
         break;
      db_files++;
      }

/* see if any files need information changed in the database */
   for (i=0;i<numfiles && i<db_files;i++) {
      NFMa_multi_select(NULL,0,my_buff,"n_cofilename",i+1,value,&error_m);
      if (!strcmp(FileNames[i],value))
         continue;
      status=NFMa_change_file_entry(catalog_name,item_name,item_revision
                                   ,value,FileNames[i],NULL,NULL,NULL,NULL);
      if (status) return(status);
      }

   status = NFMa_simple_copy_item(catalog_name,item_name,item_revision
                                     ,storage_area);
   return(status);
}


/******************************************************************************

Doc:    NFMa_simple_copy_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   January 23, 1992

Description:
        Copys out an item that already has all file information provided 
           correctly.

Examples:
          status = NFMa_simple_copy_item(catalog_name,
                                             item_name,
                                             item_revision,
                                             storage_area);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:

******************************************************************************/
long NFMa_simple_copy_item(catalog_name,item_name,item_revision,storage_area)
   char *catalog_name;   /* I - name of catalog to user */
   char *item_name;      /* I - name of item to checkin */
   char *item_revision;  /* I - revsion of item to checkin */
   char *storage_area;   /* I - storage area the files will come from */
{
long status;
struct NFMwf_info wf_info;
struct NFMoperation operation;
   
   NFM2_clear_messages("NFMa_simple_copy_item");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s>",catalog_name,item_name
                            ,item_revision,storage_area);

   wf_info.workflow=NFM_WORKFLOW;
   strcpy(wf_info.command,COPY_ITEM_FILES);
   wf_info.workflow_name[0]=0;
   wf_info.project_name[0]=0;
   wf_info.app_name[0]=0;

   operation.transfer=NFM_TRANSFER;
   operation.delete=NFM_DELETE_FILES;
   operation.purge=NFM_PURGE;

   status = NFMRcopy_item_files(catalog_name,-1,NFMa_ticked(item_name)
                               ,NFMa_ticked(item_revision)
                            ,storage_area,wf_info,operation);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRcopy_item_files");
   NFM2_format_debug_message("Status After NFMRcopy_item_files %D",status);

   if (status == NFM_S_SUCCESS)
      status = 0;

   return(status);
}


/******************************************************************************

Doc:    NFM2_add_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
          Adds an item to the database with the given values.

Examples:
          status = NFM2_add_item(catalog_name,
                                 item_name,
                                 item_revision,
                                 item_description,
                                 item_aclno,
                                 item_versionlimit,
                                 item_cisano);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_add_item(catalog_name,item_name,item_revision,item_description
                  ,item_aclno,item_versionlimit,item_cisano)
   char *catalog_name;      /* I - catalog to add item to */
   char *item_name;         /* I - item name to add */
   char *item_revision;     /* I - item revision to add */
   char *item_description;  /* I - item description to add */
   char *item_aclno;        /* I - access control level to apply */
   char *item_versionlimit; /* I - version limit to apply */
   char *item_cisano;       /* I - default check in storage area to apply */
{
   char cols[5][15],*atts[5],*vals[5];

   strcpy(cols[0],"n_itemdesc");    atts[0]=cols[0];vals[0]=item_description;
   strcpy(cols[1],"n_versionlimit");atts[1]=cols[1];vals[1]=item_versionlimit;
   strcpy(cols[2],"n_cisano");      atts[2]=cols[2];vals[2]=item_cisano;

   return(NFMa_add_item(catalog_name,item_name,item_revision,item_aclno
                       ,atts,vals,3));
}


/******************************************************************************

Doc:    NFM2_properties

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        NFM2_properties(object);

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
NFM2_properties(object)
   char *object;  /* O - ?? */
{
	char	encrypted[80], prop[80];
	long	i, status;
	NFM2_debug_message("NFM Environment Properties");
	memset(Nodename,'\0',80); memset(xns_address,'\0',80); memset(tcp_address,'\0',80);
	status = clh_vbyop(object,"Address",xns_address,80);
	status = clh_vbyop(object,"tcp_address",tcp_address,80);
	status = clh_vbyop(object,"Nodename",Nodename,80);
	for (i=11; i<26; i++)
	{
		memset(encrypted,'\0',80); memset(properties[i-11],'\0',80);
		sprintf(prop,"NETPROP%2d",i);
		status = clh_vbyop(object,prop,encrypted,80);
		NFM2_format_debug_message("After clh_vbyop For <%s> Is %d <%s>",prop,status,encrypted);
		if (i < 13 | i > 14)
			{
			NFM2_format_debug_message("Calling   NFMdecrypt with   <%s>",encrypted);
			NFMdecrypt(encrypted,properties[i-11]);
/*
			NFM2_format_debug_message("Back From NFMdecrypt with   <%s>",properties[i-11]);
*/
			}
		else
			{
			NFM2_format_debug_message("NFMdecrypt Not Required For <%s>",encrypted);
			strcpy(properties[i-11],encrypted);
			}
/*
	NFM2_format_debug_message("%s  %s  <%s>  <%s>",object,prop,encrypted,properties[i-11]);
*/
	}
	NFM2_debug_message(" ");
}


/******************************************************************************

Doc:    NFM2_schema_password

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Returns the schema name and password.

Examples:
        NFM2_schema_password(schema_name,
                             password);

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
NFM2_schema_password(schema,password)
char	*schema, *password;
{strcpy(schema,properties[9]); strcpy(password,properties[10]);}


/******************************************************************************

Doc:    NFM2_schema_definition

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        NFM2_schema_definition(schema_definition);

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
NFM2_schema_definition(schema_definition)
   char *schema_definition; /* O - the current schema definition */
{
	char	definition[256];
	memset(definition,'\0',256);
	strcpy(definition,"define schema ");
	strcat(definition,properties[13]);	strcat(definition,".");
	strcat(definition,properties[14]);	
	strcat(definition," on database (");
	strcat(definition,properties[0]);
	strcat(definition,", dir ");
	strcat(definition,properties[2]);
	strcat(definition,", dbname ");
	strcat(definition,properties[3]);
	if (strcmp(properties[4],"") != 0)
		{
		strcat(definition,", ");
		strcat(definition,"remote ");
		strcat(definition,properties[5]);
		strcat(definition," ");
		strcat(definition,properties[4]);
		}
	else
		{
		strcat(definition,", ");
		strcat(definition,"remote ");
		strcat(definition,properties[5]);
		strcat(definition," ");
		strcat(definition,Nodename);
/*
		if (strcmp(properties[5],"XNS") == 0)	strcat(definition,xns_address);
		else					strcat(definition,tcp_address);
*/
		}
	strcat(definition,") user ");
	strcat(definition,properties[6]);	strcat(definition,".");
	strcat(definition,properties[7]);
	strcpy(schema_definition,definition);
	NFM2_format_debug_message("The Schema Definition Is\n<%s>",definition);
}


/******************************************************************************

Doc:    MY_NFM2_checkin_mult_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Checks in multiple files to an item, or multiple items to a set.
        If using to check in to a set, subsitute set information where item
           info is now.
        You must enter EITHER the storage area OR the node/user/password/path
           that the file will come from.  Both sets of information are not
           needed.

Examples:
          status = MY_NFM2_checkin_mult_item(catalog_name,
                                             item_name,
                                             item_revision,
                                             storage_area,
                                             temporary_node,
                                             temporary_user,
                                             temporary_password,
                                             temporary_path,
                                             num_files,
                                             file_names,
                                             checkin_type);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long MY_NFM2_checkin_mult_item(catalog_name,item_name,item_revision,
                               storage_area,temporary_node,temporary_user,
                               temporary_password,temporary_path,num_files,
                               file_name,checkin_type)
   char *catalog_name;       /* I - NFM catalog */
   char *item_name;          /* I - item name to check in */
   char *item_revision;      /* I - item revision to check in */
   char *storage_area;       /* I - storage area the files will come from */
   char *temporary_node;     /* I - node the files will come from */
   char *temporary_user;     /* I - user the files will come from */
   char *temporary_password; /* I - password for above user */
   char *temporary_path;     /* I - directory the files will come from */
   long  num_files;          /* I - number of files in list of names */
   char  file_name[][14];    /* I - list of file names to check in */
   char *checkin_type;       /* I - flag indicating item or set
                                    values are: CHECKIN_ITEM
                                                CHECKIN_SET */
{
char **files;
long i,status;

   files = (char **) malloc(num_files*sizeof(char *));
   for (i=0;i<num_files;i++) 
      files[i]=file_name[i];

   status=NFMa_checkin_mult_item(catalog_name
                                ,item_name
                                ,item_revision
                                ,storage_area
                                ,temporary_node
                                ,temporary_user
                                ,temporary_password
                                ,temporary_path
                                ,num_files
                                ,files
                                ,NULL
                                ,NULL
                                ,NULL
                                ,NULL
                                ,checkin_type);
   free(files);
   return(status);
}


/******************************************************************************

Doc:    MY_NFM2_checkout_mult_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Checks out an item.  
        The default checkout names can be overridden by supplying them in the
            list of filenames.

Examples:
          status = MY_NFM2_checkout_mult_item(catalog_name,
                                             item_name,
                                             item_revision,
                                             storage_area,
                                             num_files,
                                             file_names);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long MY_NFM2_checkout_mult_item(catalog_name,item_name,item_revision,
                                storage_area,num_files,file_name)
   char *catalog_name;       /* I - NFM catalog */
   char *item_name;          /* I - item name to check out */
   char *item_revision;      /* I - item revision to check out */
   char *storage_area;       /* I - storage area the files will go to */
   long  num_files;          /* I - number of files in list of names */
   char  file_name[][14];    /* I - list of file names to check out */
{
long  status;
char *file_names;
   
   file_names = (char *) malloc (sizeof(char)*num_files*20);
   if (!file_names) return(1);

   file_names[0]=0;

   if (num_files) {
      sprintf(file_names,"#~%d~",num_files);
      for (status=0;status<num_files;status++) {
         strcat(file_names,file_name[status]);
         strcat(file_names,"~");
         }
      }

   status = NFM2_checkout_item(catalog_name,
                               item_name,
                               item_revision,
                               storage_area,
                               file_names);

   free(file_names);
   return(status);
}


/******************************************************************************

Doc:    NFM2_query_catalog_template

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Unknown

Description:
        ??

Examples:
        status = NFM2_query_catalog_template(catalog_name,
                                               rows,
                                               cols,
                                               data,
                                               format);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
/*ARGSUSED*/
long NFM2_query_catalog_template( application, rows, cols, data, format)
   char   *application; /* I - NFM application */
   long   *rows;       /* O - ?? */
   long   *cols;       /* O - ?? */
   char ***data;       /* O - ?? */
   char ***format;     /* O - ?? */
{
  int status;

        NFM2_format_debug_message("NFM2_query_catalog_template");
        status = NFMRquery_catalog_template(DSUSERID,&attr_list,&data_list
                                           ,&value_list);
        if (status != NFM2_check_status(status,NFM_SUCCESS
                                       ,"NFMRquery_catalog_template")) return 1;
        status = MEMbuild_array(attr_list);
        if ( status == NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") )
                {
                *rows = attr_list->rows;
                *cols = attr_list->columns;
                *data = (char **) attr_list->data_ptr;
                *format = (char **) attr_list->column_ptr;
                status = 0;
                }
        NFM2_format_debug_message("NFM2_query_catalog_template - Returning status %D",status);
        return status;
}


/******************************************************************************

Doc:    NFM2_query_catalog_definition

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        status = NFM2_query_catalog_definition(catalog_name,
                                               rows,
                                               cols,
                                               data,
                                               format);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_query_catalog_definition( catalog_name, rows, cols, data, format)
   char	*catalog_name; /* I - NFM catalog name */
   long   *rows;       /* O - ?? */
   long   *cols;       /* O - ?? */
   char ***data;       /* O - ?? */
   char ***format;     /* O - ?? */
{
  int status;

	NFM2_format_debug_message("NFM2_query_catalog_definition - %s",catalog_name);
	status = NFMRquery_catalog_definition(DSUSERID,catalog_name,&attr_list);
	if (status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_catalog_definition"))	return 1;
	status = MEMbuild_array(attr_list);
	if ( status == NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") )
		{
		*rows = attr_list->rows;
		*cols = attr_list->columns;
		*data = (char **) attr_list->data_ptr;
		*format = (char **) attr_list->column_ptr;
		status = 0;
		}
	NFM2_format_debug_message("NFM2_query_catalog_definition - Returning status %D",status);
	return status;
}


/******************************************************************************

Doc:    NFM2_copy_item_validation

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        status = NFM2_copy_item_validation(catalog_name,
                                           item_name,
                                           item_revision);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFM2_copy_item_validation ( catalog_name, item_name, item_revision )
char  *catalog_name;   /* I - NFM catalog name */
char  *item_name;      /* I - item name to ?? */
char  *item_revision;  /* I - item revsion to ?? */
{

	long      status;          /* Return status */

	NFM2_clear_messages("NFM2_copy_item_validation");

	/****************************************
    * See if the user has the authority to *
    * copy an item.                        *
    ****************************************/

	status = NFMRvalidate_user_access ( DSUSERID, COPY_ITEM_FILES, "", "", catalog_name, item_name, item_revision );
	NFM2_format_debug_message("Validate User Access Status = %D",status);
	if (status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access"))	return (status);
/*
	status = NFMRcancel_item_copy ( DSUSERID, attr_list, data_list );
	NFM2_format_debug_message("NFMRcancel_item_copy Status = %D",status);
	if (status != NFM2_check_status(status,NFM_SUCCESS,"NFMRcancel_item_copy"))	return (status);
*/
	status = 0;
	NFM2_set_to_state();
	NFM2_format_debug_message("Exiting NFM2_copy_item_validation - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_load_workflow

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_load_workflow(application,
                                      workflowname);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_load_workflow ( application, workflowname )
   char *application;  /* I - ?? */
   char *workflowname; /* I - ?? */
{
	long      status;          /* Return status */

	NFM2_clear_messages("NFM2_load_workflow");
	NFM2_format_debug_message("Application = <%s>  Workflow = <%s>",application, workflowname);

   /****************************************
    * See if the user has the authority to *
    * load a workflow.                     *
    ****************************************/

	status = NFMRvalidate_user_access ( DSUSERID, LOAD_WORKFLOW, "", "", "", "", "" );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end;

   /**************************************
    * Load the workflow.                 *
    **************************************/

        status = NFMRload_workflow( DSUSERID, application, workflowname);
	NFM2_format_debug_message("NFMRload_workflow status = %D",status);
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRload_workflow") ) goto end;
	status = 0;

end:

   /*********************************
    * Tell NFM how everything went. *
    *********************************/

	NFM2_dmd_set_to_state ();
	NFM2_format_debug_message("Exiting NFM2_load_workflow - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_add_acl

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_add_acl(workflowno,
                                aclname);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_add_acl ( workflowno, aclname )
   long workflowno; /* I - ?? */
   char *aclname;   /* I - ?? */
{
	/* Local declarations */

        long      i;
	long      status;          /* Return status */
        char      workflowno_char[15];
        char      **attributes;
        long      num_attrs=0;
        extern int strcmp();

	NFM2_clear_messages("NFM2_add_acl");
	NFM2_format_debug_message("Workflow # = %d  ACL name = <%s>",workflowno, aclname);

        /*
         * See if the user has the authority to 
         * add an ACL.
         */

	status = NFMRvalidate_user_access ( DSUSERID, ADD_ACL, "", "", "", "", "" );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end;

        /*
         * Setup pointers.
         */

        status = NFMRquery_acl_attributes( DSUSERID, &attr_list, &data_list, &value_list );
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_acl_attributes") ) goto end;

        status = MEMbuild_array(attr_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        if (DSdebug > 4)
           {
           printf("Before the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Locate the attributes and write the data into the
         * data_list at that column number.
         */

        attributes = (char **) data_list->column_ptr;
        num_attrs = data_list->columns;

        for (i=0; i < num_attrs; i++)
           {
           if (!strcmp(attributes[i], "n_aclname"))
              {
              status = MEMwrite_data(data_list, aclname, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_workflowno"))
              {
              sprintf(workflowno_char, "%d", workflowno);
              status = MEMwrite_data(data_list, workflowno_char, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           }

        if (DSdebug > 4)
           {
           printf("After the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Now that the data_list is filled,
         * add the ACL to the database.
         */

        status = NFMRadd_acl ( DSUSERID, attr_list, data_list );
	NFM2_format_debug_message("Status After Add ACL %D",status);
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRadd_acl") ) goto end;
	status = 0;

end:

        /*
         * Tell NFM how everything went.
         */

	NFM2_dmd_set_to_state ();
	NFM2_format_debug_message("Exiting NFM2_add_acl - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_add_acl_user

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_add_acl_user(aclname,
                                     aclno,
                                     classno,
                                     userno);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_add_acl_user ( aclname, aclno, classno, userno )
   char *aclname; /* I - ?? */
   long aclno;    /* I - ?? */
   long classno;  /* I - ?? */
   long userno;   /* I - ?? */
{
        long      i;
	long      status;          /* Return status */
        char      str[100];
        char      num_char[20];
        char      **attributes;
        long      num_attrs=0;
        extern int strcmp();

	NFM2_clear_messages("NFM2_add_acl_user");
	NFM2_format_debug_message("ACL name = <%s>  ACL no = %d  Class no = %d  User no = %d", aclname, aclno, classno, userno);

        /*
         * See if the user has the authority to 
         * add a user to an ACL.
         */

	status = NFMRvalidate_user_access ( DSUSERID, ADD_ACL_USER, "", "", "", "", "" );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end;

        /*
         * Setup pointers.
         */

        status = NFMRquery_acl_class_users( DSUSERID, aclname, &attr_list, &data_list, &value_list );
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_acl_class_users") ) goto end;

        status = MEMbuild_array(attr_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        if (DSdebug > 4)
           {
           printf("Before the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Locate the attributes and write the data into the
         * bottom of the data_list.
         */

        attributes = (char **) data_list->column_ptr;
        num_attrs = data_list->columns;

        str[0] = 0;

        for (i=0; i < num_attrs; ++i)
           {
           if (!strcmp(attributes[i], "n_aclno"))
              {
              sprintf(num_char, "%d", aclno);
              strcat(str, num_char);
              }
           else if (!strcmp(attributes[i], "n_classno"))
              {
              sprintf(num_char, "%d", classno);
              strcat(str, num_char);
              }
           else if (!strcmp(attributes[i], "n_userno"))
              {
              sprintf(num_char, "%d", userno);
              strcat(str, num_char);
              }
           else if (!strcmp(attributes[i], "n_status"))
              {
              strcat(str, "ADD");
              }

           strcat(str, "\1");
           }

        if (DSdebug > 4) NFM2_format_debug_message("<%s>", str);

        status = MEMwrite(data_list, str);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite") ) goto end;
        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        if (DSdebug > 4)
           {
           printf("After the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Now that the data_list is filled,
         * add the user to the ACL in the database.
         */

        status = NFMRupdate_acl_class_users ( DSUSERID, attr_list, data_list );
	NFM2_format_debug_message("NFMRupdate_acl_users - status =  %D",status);
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRupdate_acl_class_users") ) goto end;
	status = 0;

end:

        /*
         * Tell NFM how everything went.
         */

	NFM2_dmd_set_to_state ();
	NFM2_format_debug_message("Exiting NFM2_add_acl_user - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_delete_acl_user

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_delete_acl_user(aclname,
                                        aclno,
                                        classno,
                                        userno);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_delete_acl_user ( aclname, aclno, classno, userno )
   char *aclname; /* I - ?? */
   long aclno;    /* I - ?? */
   long classno;  /* I - ?? */
   long userno;   /* I - ?? */
{
	/* Local declarations */

        long      i;
	long      status;          /* Return status */
        char      aclno_char[20];
        char      classno_char[20];
        char      userno_char[20];
        long      status_col=0;
        long      userno_col=0;
	long      classno_col=0;
	long      aclno_col=0;
        char      **attributes, **value;
        long      num_attrs=0, num_rows=0;
        extern int strcmp();

	NFM2_clear_messages("NFM2_delete_acl_user");
	NFM2_format_debug_message("ACL name = %s ACL no = %d  Class no = %d  User no = %d",aclname, aclno,classno, userno);

        /*
         * See if the user has the authority to 
         * add a user to an ACL.
         */

	status = NFMRvalidate_user_access ( DSUSERID, DELETE_ACL_USER, "", "", "", "", "" );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end;

        /*
         * Setup pointers.
         */

        status = NFMRquery_acl_class_users( DSUSERID, aclname, &attr_list, &data_list, &value_list );
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_acl_class_users") ) goto end;

        status = MEMbuild_array(attr_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        status = MEMbuild_array(data_list);
        if ( status!= NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        if (DSdebug > 4)
           {
           printf("Before the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Locate the attributes and write DROP into the
         * status column of the data_list.
         */

        attributes = (char **) data_list->column_ptr;
        value = (char **) data_list->data_ptr;
        num_attrs = data_list->columns;
        num_rows  = data_list->rows;

        for (i=0; i < num_attrs; i++)
           {
           if (!strcmp(attributes[i], "n_aclno"))		aclno_col = i;
           else if (!strcmp(attributes[i], "n_classno"))	classno_col = i;
           else if (!strcmp(attributes[i], "n_userno"))		userno_col = i;
           else if (!strcmp(attributes[i], "n_status"))		status_col = i+1;
           }

        /*
         * Convert numbers to character strings for comparison.
         */

        sprintf(aclno_char, "%d", aclno);
        sprintf(classno_char, "%d", classno);
        sprintf(userno_char, "%d", userno);

        /*
         * Find the row that matches the input arguments and
         * put "DROP" in the status column.
         */

        for (i=0; i < num_rows; i++)
           {
           if (DSdebug > 4)
              {
              printf("ACL no. = <%s>\n", value[i*num_attrs+aclno_col]);
              printf("Class no. = <%s>\n", value[i*num_attrs+classno_col]);
              printf("User no. = <%s>\n", value[i*num_attrs+userno_col]);
              }

           if (!strcmp(value[i*num_attrs+aclno_col], aclno_char) &&
               !strcmp(value[i*num_attrs+classno_col], classno_char) &&
               !strcmp(value[i*num_attrs+userno_col], userno_char))
              {
              status = MEMwrite_data(data_list, "DROP", i+1, status_col);
	        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              break;
              }
           }

        NFM2_debug_message("string written to data_list");

        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        if (DSdebug > 4)
           {
           printf("After the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Now that the data_list is filled,
         * delete the user to the ACL in the database.
         */

        status = NFMRupdate_acl_class_users ( DSUSERID, attr_list, data_list );
	NFM2_format_debug_message("NFMRupdate_acl_class_users - status = %D",status);
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRupdate_acl_class_users") ) goto end;
	status = 0;

end:

        /*
         * Tell NFM how everything went.
         */

	NFM2_dmd_set_to_state ();
	NFM2_format_debug_message("Exiting NFM2_delete_acl_user - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_add_user

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_add_user(username,
                                 password,
                                 desc,
                                 mailpath,
                                 application);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_add_user ( username, password, desc, mailpath, application )
   char *username;    /* I - NFM user to add */
   char *password;    /* I - password for the user */
   char *desc;        /* I - ?? */
   char *mailpath;    /* I - ?? */
   char *application; /* I - ?? */
{
        long      i;
	long      status;
        char      **attributes;
        long      num_attrs=0;
        extern int strcmp();

	NFM2_clear_messages("NFM2_add_user");
	NFM2_format_debug_message("User name = %s, Password = %s, Desc = %s, Mail = %s, App = %s", username, password, desc, mailpath, application);
	status = NFMRvalidate_user_access ( DSUSERID, ADD_USER, "", "", "", "", "" );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end;
        status = NFMRquery_add_user_attributes( DSUSERID, &attr_list, &data_list, &value_list );
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_add_user_attributes") ) goto end;
        status = MEMbuild_array(attr_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
        if (DSdebug > 4)
           {
           printf("Before the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }
        attributes = (char **) data_list->column_ptr;
        num_attrs = data_list->columns;
        for (i=0; i < num_attrs; i++)
           {
           if (!strcmp(attributes[i], "n_username"))
              {
              status = MEMwrite_data(data_list, username, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_passwd"))
              {
              status = MEMwrite_data(data_list, password, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_userdesc"))
              {
              status = MEMwrite_data(data_list, desc, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_emailaddr"))
              {
              status = MEMwrite_data(data_list, mailpath, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_application"))
              {
              status = MEMwrite_data(data_list, application, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           }
        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
        if (DSdebug > 4)
           {
           printf("After the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }
        status = NFMRadd_user ( DSUSERID, attr_list, data_list );
	NFM2_format_debug_message("Status After Add User %D",status);
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRadd_user") ) goto end;
	status = 0;
end:
	NFM2_dmd_set_to_state ( );
	NFM2_format_debug_message("Exiting NFM2_add_user - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_add_storage_area

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_add_storage_area(saname,
                                         node_number,
                                         username,
                                         password,
                                         path,
                                         device_type);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_add_storage_area(saname,node_number,username,password,path,
                           device_type)
   char *saname;      /* I - ?? */
   char *node_number; /* I - ?? */
   char *username;    /* I - ?? */
   char *password;    /* I - ?? */
   char *path;        /* I - ?? */
   char *device_type; /* I - ?? */
{
        long      i;
	long      status;
        char      **attributes;
        long      num_attrs=0;
        extern int strcmp();

	NFM2_clear_messages("NFM2_add_storage_area");
	NFM2_format_debug_message("SA name = %s, Node Number = %s, device type = %s, path = %s, User name = %s, Password = %s", saname, node_number, device_type, path, username, password);
	status = NFMRvalidate_user_access ( DSUSERID, ADD_SA, "", "", "", "", "" );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end;
        status = NFMRquery_add_st_area_attributes( DSUSERID, &attr_list, &data_list, &value_list );
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_add_st_area_attributes") ) goto end;
        status = MEMbuild_array(attr_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
        if (DSdebug > 4)
           {
           printf("Before the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Locate the attributes and write the data into the
         * bottom of the data_list.
         */

        attributes = (char **) data_list->column_ptr;
        num_attrs = data_list->columns;

        for (i=0; i < num_attrs; i++)
           {
           if (!strcmp(attributes[i], "n_saname"))
              {
              status = MEMwrite_data(data_list, saname, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_nodeno"))
              {
              status = MEMwrite_data(data_list, node_number, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_username"))
              {
              status = MEMwrite_data(data_list, username, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_passwd"))
              {
              status = MEMwrite_data(data_list, password, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_pathname"))
              {
              status = MEMwrite_data(data_list, path, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_devicetype"))
              {
              status = MEMwrite_data(data_list, device_type, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           }

        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        if (DSdebug > 4)
           {
           printf("After the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Now that the data_list is filled,
         * add the user to the database.
         */

        status = NFMRadd_storage_area ( DSUSERID, attr_list, data_list );
	NFM2_format_debug_message("NFMRadd_storage_area - status =  %D",status);
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRadd_storage_area") ) goto end;
	status = 0;

end:
        /*
         * Tell NFM how everything went.
         */

	NFM2_dmd_set_to_state ();
	NFM2_format_debug_message("Exiting NFM2_add_storage_area - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_add_node

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_add_node(nodename,
                                 nodedesc,
                                 tcpip,
                                 xns);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFM2_add_node ( nodename, nodedesc, tcpip, xns)
   char *nodename; /* I - ?? */
   char *nodedesc; /* I - ?? */
   char *tcpip;    /* I - ?? */
   char *xns;      /* I - ?? */
{
        long      i;
	long      status;
        char      **attributes;
        long      num_attrs=0;
        extern int strcmp();

	NFM2_clear_messages("NFM2_add_node");
	NFM2_format_debug_message("Node Name = %s, TCP = %s, XNS = %s\nDescription = %s", nodename, tcpip, xns, nodedesc);
	status = NFMRvalidate_user_access ( DSUSERID, ADD_NODE, "", "", "", "", "" );
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end;
        status = NFMRquery_add_node_attributes( DSUSERID, &attr_list, &data_list, &value_list );
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_add_node_attributes") ) goto end;
        status = MEMbuild_array(attr_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;
        if (DSdebug > 4)
           {
           printf("Before the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Locate the attributes and write the data into the
         * bottom of the data_list.
         */

        attributes = (char **) data_list->column_ptr;
        num_attrs = data_list->columns;

        for (i=0; i < num_attrs; i++)
           {
           if (!strcmp(attributes[i], "n_nodename"))
              {
              status = MEMwrite_data(data_list, nodename, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_nodedesc"))
              {
              status = MEMwrite_data(data_list, nodedesc, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_tcpip"))
              {
              status = MEMwrite_data(data_list, tcpip, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           else if (!strcmp(attributes[i], "n_xns"))
              {
              status = MEMwrite_data(data_list, xns, 1, i+1);
              if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              }
           }

        status = MEMbuild_array(data_list);
        if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array") ) goto end;

        if (DSdebug > 4)
           {
           printf("After the DATA LIST writes.\n");
           MEMprint_buffers ("ATTR LIST", attr_list, NULL);
           MEMprint_buffers ("DATA LIST", data_list, NULL);
           }

        /*
         * Now that the data_list is filled,
         * add the node to the database.
         */

        status = NFMRadd_node ( DSUSERID, attr_list, data_list );
	NFM2_format_debug_message("NFMRadd_node - status =  %D",status);
        if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRadd_node") ) goto end;
	status = 0;

end:
        /*
         * Tell NFM how everything went.
         */

	NFM2_dmd_set_to_state ();
	NFM2_format_debug_message("Exiting NFM2_add_node - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    Previous_SQL_Rows

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = Previous_SQL_Rows();

Return Status:
          number of rows from sql

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	Previous_SQL_Rows()	
{
   return Number_Of_Rows_From_Sql;
}


#ifndef	BLOCKED_SQL
/******************************************************************************

Doc:    SS_sql

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        This function performs any desired sql statement.
        Any results are returned in 'buffer', bound by 'max_rows'.
        If an error ocurrs, 'error_message' is allocated and contains text
           explaining the error.

Examples:
          status = SS_sql(buffer,
                          sql_stmt,
                          buffsize,
                          max_rows,
                          error_message);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	SS_sql(buf,sql_stmt,bufsize,maximum_rows,Error_Message)
   char *buf;            /* O - buffer to return results in */
   char *sql_stmt;       /* I - sql statement to perform */
   long *bufsize;        /* ?? */
   long  maximum_rows;   /* I - maximum # of rows returned */
   char **Error_Message; /* O - error text message returned */
{
	MEMptr	sql_buffer = NULL;
	long	status, *loc, items,value,index,dindex,loop,rows;
	char	*dup, *data, **ptr, token[132], expected_bufsize[12],sqlline[32768];
	short	*sptr;

	NFM2_clear_messages("SS_sql");
	Number_Of_Rows_From_Sql = 0;
	if (sql_stmt[0] == '@')	{memset(sqlline,32,sizeof(sqlline));sqlline[sizeof(sqlline)-1]=0;SS_load_sql_statement(&sql_stmt[1],sqlline);}
	else			strcpy(sqlline,sql_stmt);
	if (*bufsize > 0)	sprintf(expected_bufsize,"%d",*bufsize);
	else			strcpy(expected_bufsize,"1024");
	index = dindex = *bufsize = 0;	value = 0;
	loc = (long *) buf; *(loc++) = 0; *(loc++) = 0; *(loc++) = 0;
	*bufsize = 3*sizeof(long);
	strcpy(token,strtok(dup=(char *)strdup(sqlline)," ")); free(dup);
	for (loop = 0; loop < strlen(token); loop++)	{token[loop] = (char)(toupper(token[loop]));}
	NFM2_format_debug_message("sql = <%s>\nExpected Size = %s, token = <%s>",sqlline,expected_bufsize,token);
	if (strcmp(token,"SELECT") != 0)
		{
		status = NFMRsqlstmt(sqlline);
		NFM2_format_debug_message("status after NFMRsqlstmt = %D\nsql = <%s>",status,sqlline);
		if (status != NFM2_check_status(status,NFM_SUCCESS,"NFMRsqlstmt"))
			{
			*(long *)buf = status;
			*Error_Message = (char *)NFM_Error_Messages[(NFM_Messages-1)];
			return value;
			}
		else
			{
			*Error_Message = (char *)NFM_Error_Messages[(NFM_Messages-1)];
			return 0;
			}
		}
	else
		{
		status = NFMRsqlquery(sqlline,expected_bufsize,&sql_buffer);
		NFM2_format_debug_message("status after NFMRsqlquery = %D\nsql = <%s>",status,sqlline);
		*(long *)buf = status;
		if (status != NFM2_check_status(status,NFM_SUCCESS,"NFMRsqlquery"))
			{
			*Error_Message = (char *)NFM_Error_Messages[(NFM_Messages-1)];
			return status;
			}
		status = MEMbuild_array(sql_buffer);
		*(long *)buf = status;
		if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array"))
			{
			*Error_Message = (char *)NFM_Error_Messages[(NFM_Messages-1)];
			return value;
			}
		Number_Of_Rows_From_Sql = sql_buffer->rows;
		if (sql_buffer->rows > maximum_rows)	rows = maximum_rows;
		else					rows = sql_buffer->rows;
		*bufsize = 0;
		loc = (long *) buf;
		*(loc++) = 0;
		*(loc++) = rows * sql_buffer->columns;
		*(loc++) = sql_buffer->columns;
		items = (rows * sql_buffer->columns) + sql_buffer->columns;
		sptr = (short *) loc;
		data = (char *)((long)sptr + (items * sizeof(short)));
		NFM2_format_debug_message("items = %d rows = %d out of %d (max %d)   columns = %d",items,rows,sql_buffer->rows,maximum_rows,sql_buffer->columns);
		ptr = (char **) sql_buffer->column_ptr;
		*bufsize = (sizeof(long) * 3) + (items * sizeof(short));
		for (loop = 0; loop < sql_buffer->columns; loop++)
			{
			*sptr = strlen(ptr[loop]);
			strcpy(data,ptr[loop]);	*bufsize += (*sptr + 1); data += (*sptr + 1); sptr++;
			}
		ptr = (char **) sql_buffer->data_ptr;
		for (loop = 0; loop < (rows * sql_buffer->columns); loop++)
			{
			*sptr = strlen(ptr[loop]);
			strcpy(data,ptr[loop]);	*bufsize += (*sptr + 1); data += (*sptr + 1); sptr++;
			}
		*Error_Message = (char *)NFM_Error_Messages;
		status = MEMclose(&sql_buffer);	NFM2_check_status(status,MEM_SUCCESS,"MEMclose");
		return 0;
		}
}
#endif


/******************************************************************************

Doc:    NFM2_close_buffers

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        NFM2_close_buffers();

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	NFM2_close_buffers()
{
	NFM2_debug_message("NFM2_close_buffers");
	if (data_list != NULL)		MEMclose(&data_list);
	if (page_list != NULL)		MEMclose(&page_list);
	if (title_list != NULL)		MEMclose(&title_list);
	if (header_list != NULL)	MEMclose(&header_list);
	if (footer_list != NULL)	MEMclose(&footer_list);
	if (select_list != NULL)	MEMclose(&select_list);
	if (grp_begin_list != NULL)	MEMclose(&grp_begin_list);
	if (grp_text_list != NULL)	MEMclose(&grp_text_list);
	if (eop_text_list != NULL)	MEMclose(&eop_text_list);
	if (eor_text_list != NULL)	MEMclose(&eor_text_list);
	if (attr_list != NULL)		MEMclose(&attr_list);
	if (value_list != NULL)		MEMclose(&value_list);
	if (info != NULL)		MEMclose(&info);
   return(0);
}


/******************************************************************************

Doc:    NFM2_print_separation

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        NFM2_print_separation();

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	NFM2_print_separation()
{NFM2_debug_message("--------------------------------------------------");
 return(0);}


/******************************************************************************

Doc:    NFM2_clear_messages

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        NFM2_clear_messages(text);

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	NFM2_clear_messages(text)
   char *text; /* I - ?? */
{
	long	loop;
	NFM2_close_buffers();
	if (NFM_Messages > 0)
		{
		NFM2_print_separation();
		for (loop = 0; loop < NFM_Messages; loop++)	{NFM2_format_debug_message("%s",NFM_Error_Messages[loop]);}
		NFM2_print_separation();
		}
	ERRreset_struct();
	NFM2_print_separation();
	sprintf(NFM_Error_Messages[0],"{ %s }",text);
	NFM_Messages = 1;
	NFM2_format_debug_message("NFM2_clear_messages - %s",text);
   return(0);
}


/******************************************************************************

Doc:    NFM2_get_current_message

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        NFM2_get_current_message(nfmstatus,
                                 msg);

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	NFM2_get_current_message(nfmstatus,msg)
   long nfmstatus; /*  ?? */
   char *msg;      /* ?? */
{
	long	status;
	char	message[512];
	NFM2_debug_message("Entering NFM2_get_current_message");
	if (NFM_Messages < MAX_NFM_MESSAGES)
		{
		status = ERRget_message(message);
		sprintf(NFM_Error_Messages[NFM_Messages],"{%xx} - %s - %s",nfmstatus,msg,message);
		NFM2_format_debug_message("<< %s >>",NFM_Error_Messages[NFM_Messages]);
		NFM_Messages++;
		}
   return(0);
}


/******************************************************************************

Doc:    NFM2_check_status

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        status = NFM2_check_status(status,
                                   type,
                                   msg);

Return Status:
        ??

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	NFM2_check_status(status,type,msg)
   long status;  /* ?? */
   long type;    /* ?? */
   char *msg;    /* ?? */
{
	char	mesg[132];

	if (type >= 0 && type < MAX_SUCCESS_CODES)
		{
		sprintf(mesg,"[%s] <%s>",SUCCESS_CODES[type],msg);
		if (status != SUCCESS_CODE[type])
			{
			if (type == MEM_SUCCESS)	ERRload_struct(NFM,NFM_E_MEM,NULL);	/* Only When Its a MEM Failure */
			NFM2_get_current_message(status,mesg);
			}
		return	SUCCESS_CODE[type];
		}
	return	status;
}


/******************************************************************************

Doc:    get_nfm_error_message

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        get_nfm_error_message(buf,
                              bufsize);

Return Status:
         none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	get_nfm_error_message(buf,bufsize)
   char *buf;     /* ?? */
   long *bufsize; /* ?? */
{
	char	*header={"NFM Error Message"};
	long	value,index,dindex,loop;
	short	size;
	NFM2_debug_message("Entering get_nfm_error_message");
	index = value = dindex = *bufsize = 0;
	memcpy(&buf[index],&value,sizeof(value));	index += sizeof(value);
	value = NFM_Messages;	memcpy(&buf[index],&value,sizeof(value));	index += sizeof(value);
	value = 1;		memcpy(&buf[index],&value,sizeof(value));	index += sizeof(value);
	dindex = index + (NFM_Messages * sizeof(size)) + sizeof(size);
	size = (short) strlen(header);
	memcpy(&buf[index],&size,sizeof(size));	index += sizeof(size);	size++;
	memcpy(&buf[dindex],header,size);	dindex += size;
	for (loop = 0; loop < NFM_Messages; loop++)
		{
		size = (short) strlen(NFM_Error_Messages[loop]);
		memcpy(&buf[index],&size,sizeof(size));	index += sizeof(size); size++;
		memcpy(&buf[dindex],NFM_Error_Messages[loop],size); dindex += size;
		}
	*bufsize = dindex;
       return(0);
}


/******************************************************************************

Doc:    NFM2_set_to_state

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        NFM2_set_to_state();

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
NFM2_set_to_state()
{
	long	sts;
	sts = NFMRset_to_state ( DSUSERID,  "nfm");
	NFM2_check_status(sts,NFM_SUCCESS,"NFMRset_to_state");
}


/******************************************************************************

Doc:    NFM2_dmd_set_to_state

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        NFM2_dmd_set_to_state();

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
NFM2_dmd_set_to_state()
{
	long	sts;
	sts = NFMRset_to_state ( DSUSERID,  "DMD");
	NFM2_check_status(sts,NFM_SUCCESS,"NFMRset_to_state");
}


/******************************************************************************

Doc:    NFM2_debug_message

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        Prints a given message to the debug file.

Examples:
        NFM2_debug_message(text);

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
NFM2_debug_message(text)
   char*text; /* I - text message to print */
{	if (DSdebug) fprintf(nfm2dbg,"%s\n",text);	}


/******************************************************************************

Doc:    NFM2_open_nfm2_debug_file

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
        NFM2_open_nfm2_debug_file(client_id,
                             level);

Return Status:
        none

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
NFM2_open_nfm2_debug_file(client_id,level)
long	client_id,level;
{
	char	dbgfilename[80];
	if (nfm2dbg == NULL && level > 0)
		{
		sprintf(dbgfilename,"/usr/tmp/nfm_%7.7d",client_id);
		nfm2dbg = fopen(dbgfilename,"w");
		if (nfm2dbg == NULL)	{DSdebug = 0;}
		else			{setbuf(nfm2dbg, 0); if (DSdebug < 1) DSdebug = 1;}
		}
	return;
}



/*
	The following functions are NOT currently supported by DMANDS, since
	DMANDS does NOT currently use any of these functions.  This is intended
	to reduce maintenance.  They could be supported at a later date, if
	there is a NEED.	Sukumar
*/

long	NFM2_list_sets()
{	return 1;	}

long	NFM2_list_set_members()
{	return 1;	}

long	NFM2_add_set()
{	return 1;	}

long	NFM2_checkout_set()
{	return 1;	}

long	NFM2_copy_set()
{	return 1;	}


/******************************************************************************

Doc:    NFM2_generic_item_transition

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   November 20, 1992

Description:	
        This routine moves the item to the next complete state specified
        by the NFM default workflow.  The next state could either be
        modification complete, approval complete, or released.    

Examples:
          status = NFM2_generic_item_transition(catalog_name,
                                       item_name,
                                       item_revision,
                                       to_state);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  11/20/92  Initial version

******************************************************************************/
int NFM2_generic_item_transition ( catalog_name, item_name, item_revision, to_state )
   char  *catalog_name;  /* I - NFM catalog name */
   char  *item_name;     /* I - item name to transition */
   char  *item_revision; /* I - item revision to transition */
   char  *to_state;      /* I - Transition to state */
{
    char      **attributes;    /* Attribute list */
    char      **datas;         /* data list */
    long      i;               /* Counter */
    long      num_attrs=0;     /* Number of attributes */
    long      num_rows=0;      /* Number of rows in the data buffer */
    long      name_col=0;      /* Column number of state name */
    long      stat_col=0;      /* Column number of state status */
    long      curr_row;        /* Row number of curent state */     
    long      found;           /* Flag */
    long      temp;            /* Temporary variable */ 
    long      status;          /* Return status */
    
/* ------------------- Start of Executable Code --------------------- */

	NFM2_clear_messages("NFM2_generic_item_transition");

   /****************************************
    * See if the user has the authority to *
    * make transition on the item.         *
    ****************************************/
    
    status = NFMRvalidate_user_access ( DSUSERID, MAKE_TRANSITION, "", "", catalog_name, item_name, item_revision );
    if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end; 

   /*******************************************
    * Get the necessary buffers for this call *
    *******************************************/

    status = NFMRquery_make_transition ( DSUSERID, &attr_list, &data_list );
    if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_make_transition") ) goto end;

    if ( DSdebug > 4 )
      {
        MEMprint_buffer("ATTRIBUTE LIST ", attr_list,  NULL);
        MEMprint_buffer("DATA LIST", data_list,  NULL);
      }
  
   /*************************************************
    * Search the data buffer attributes to find the *
    * position of the state name and status.        *
    *************************************************/

    attributes = (char **) data_list->column_ptr;        
    num_attrs = data_list->columns;                     
                                                     
    i = 0;
    while ( i < num_attrs )
    {
      if ( !strcmp ( attributes[i], "n_status" ) )	        stat_col = i;
      else if ( !strcmp ( attributes[i], "n_statename" ) )	name_col = i;
      ++i;
    }  

	NFM2_format_debug_message("The n_status column = %d  n_statename column = %d", stat_col, name_col);

   /********************************************
    * Search the data buffer to find the state *
    * in question and set its status.          *
    ********************************************/
 
    datas = (char **) data_list->data_ptr;
    num_rows  = data_list->rows;

    for (found=0, curr_row=0; !found && curr_row < num_rows; curr_row++ )
    {
      temp = curr_row * num_attrs;
      NFM2_format_debug_message("\ttemp namecol = %d  %d  \tName <%s> State <%s>", temp, name_col, datas[temp+name_col],datas[temp+stat_col]);

      if (!strcmp (datas[temp+name_col], to_state)) 
         {
            status = MEMwrite_data (data_list, "next", curr_row+1, stat_col+1);
	    if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
	    found = 1;
         }
    }

    if ( DSdebug > 4 )      MEMprint_buffer("DATA LIST (AFTER) ", data_list,  NULL);

   /*****************************************
    * Do the actual transition on the item. *
    *****************************************/

   if ( !found )      status = DS_TRANS_NOT_FOUND;
   else			
	{
	status = NFMRmake_transition ( DSUSERID, attr_list, data_list );
	NFM2_format_debug_message("\tNFMRmake_transition status %D",status);
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRmake_transition") ) goto end;
	status = 0;
	}

   /*********************************************
    * Tell NFM how everything went, and get the *
    * error message loaded in the mesasge var   * 
    ********************************************/

end:

	NFM2_set_to_state ();
	NFM2_format_debug_message("Exiting NFM2_generic_item_transition - status = %D", status );
	return ( status );
}

/******************************************************************************

Doc:    NFM2_transition_yes

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:	
        This routine moves the item to the next complete state specified
        by the NFM default workflow.  The next state could either be
        modification complete, approval complete, or released.    

Examples:
          status = NFM2_transition_yes(catalog_name,
                                       item_name,
                                       item_revision);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFM2_transition_yes ( catalog_name, item_name, item_revision )
   char  *catalog_name;  /* I - NFM catalog name */
   char  *item_name;     /* I - item name to transition */
   char  *item_revision; /* I - item revision to transition */
{
    char      **attributes;    /* Attribute list */
    char      **datas;         /* data list */
    char      *ptr;
    long      i;               /* Counter */
    long      num_attrs=0;     /* Number of attributes */
    long      num_rows=0;      /* Number of rows in the data buffer */
    long      name_col=0;      /* Column number of state name */
    long      stat_col=0;      /* Column number of state status */
    long      curr_row;        /* Row number of curent state */     
    long      found;           /* Flag */
    long      temp;            /* Temporary variable */ 
    long      status;          /* Return status */
    
/* ------------------- Start of Executable Code --------------------- */

	NFM2_clear_messages("NFM2_transition_yes");

   /****************************************
    * See if the user has the authority to *
    * make transition on the item.         *
    ****************************************/
    
    status = NFMRvalidate_user_access ( DSUSERID, MAKE_TRANSITION, "", "", catalog_name, item_name, item_revision );
    if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end; 

   /*******************************************
    * Get the necessary buffers for this call *
    *******************************************/

    status = NFMRquery_make_transition ( DSUSERID, &attr_list, &data_list );
    if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_make_transition") ) goto end;

    if ( DSdebug > 4 )
      {
        MEMprint_buffer("ATTRIBUTE LIST ", attr_list,  NULL);
        MEMprint_buffer("DATA LIST", data_list,  NULL);
      }
  
   /*************************************************
    * Search the data buffer attributes to find the *
    * position of the state name and status.        *
    *************************************************/

    attributes = (char **) data_list->column_ptr;        
    num_attrs = data_list->columns;                     
                                                     
    i = 0;
    while ( i < num_attrs )
    {
      if ( !strcmp ( attributes[i], "n_status" ) )	        stat_col = i;
      else if ( !strcmp ( attributes[i], "n_statename" ) )	name_col = i;
      ++i;
    }  

	NFM2_format_debug_message("The n_status column = %d  n_statename column = %d", stat_col, name_col);

   /********************************************
    * Search the data buffer to find the state *
    * in question and set its status.          *
    ********************************************/
 
    datas = (char **) data_list->data_ptr;
    num_rows  = data_list->rows;

    for (found=0, curr_row=0; !found && curr_row < num_rows; curr_row++ )
    {
      temp = curr_row * num_attrs;
	NFM2_format_debug_message("\ttemp namecol = %d  %d  \t<%s>", temp, name_col, datas[temp+name_col]);

      if (!strncmp(datas[temp+name_col], RED_APPROVAL, strlen(RED_APPROVAL)) &&
           strcmp (datas[temp+stat_col], "CURRENT STATE")) 
         {
         ptr = strrchr(datas[temp+name_col], ' ');
         if (!strcmp(ptr+1, COMPLETE))
            {
            status = MEMwrite_data (data_list, "next", curr_row+1, stat_col+1);
	    if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
            found = 1;
            }
         }
      else if (!strcmp(datas[temp+name_col], RED_MODIF_COMP) &&
                strcmp(datas[temp+stat_col], "CURRENT STATE"))
              {
              status = MEMwrite_data ( data_list, "next", curr_row+1, stat_col+1 );
	    if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
              found = 1;
              }
    }
	if (DSdebug > 4) NFM2_format_debug_message("\tFound = %d",found);

    if ( DSdebug > 4 )      MEMprint_buffer("DATA LIST (AFTER) ", data_list,  NULL);

   /*****************************************
    * Do the actual transition on the item. *
    *****************************************/

   if ( !found )      status = DS_TRANS_NOT_FOUND;
   else			
	{
	status = NFMRmake_transition ( DSUSERID, attr_list, data_list );
	NFM2_format_debug_message("\tNFMRmake_transition status %D",status);
	if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRmake_transition") ) goto end;
	status = 0;
	}

   /*********************************************
    * Tell NFM how everything went, and get the *
    * error message loaded in the mesasge var   * 
    ********************************************/

end:

	NFM2_set_to_state ();
	NFM2_format_debug_message("Exiting NFM2_transition_yes - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_transition_no

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:	
        This routine rejects the item to the state specified by
        the NFM default workflow.  The possible states are
        approval reject, or release reject.

Examples:
          status = NFM2_transition_no(catalog_name,
                                      item_name,
                                      item_revision);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFM2_transition_no ( catalog_name, item_name, item_revision )
   char  *catalog_name;  /* I - NFM catalog name */
   char  *item_name;     /* I - item name to transition */
   char  *item_revision; /* I - item revision to transition */
{
    char      **attributes;    /* Attribute list */
    char      **datas;         /* data list */
    long      i;               /* Counter */
    long      num_attrs=0;     /* Number of attributes */
    long      num_rows=0;      /* Number of rows in the data buffer */
    long      name_col=0;      /* Column number of state name */
    long      stat_col=0;      /* Column number of state status */
    long      curr_row;        /* Row number of curent state */     
    long      found;           /* Flag */
    long      temp;            /* Temporary variable */ 
    long      status;          /* Return status */
    

	NFM2_clear_messages("NFM2_transition_no");

/* ------------------- Start of Executable Code --------------------- */

   /****************************************
    * See if the user has the authority to *
    * make transition on the item.         *
    ****************************************/
    
    status = NFMRvalidate_user_access ( DSUSERID, MAKE_TRANSITION, "", "", catalog_name, item_name, item_revision );
    if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access") ) goto end; 

   /*******************************************
    * Get the necessary buffers for this call *
    *******************************************/

    status = NFMRquery_make_transition ( DSUSERID, &attr_list, &data_list );
    if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_make_transition") ) goto end;

    if ( DSdebug > 4 )	{MEMprint_buffer("ATTRIBUTE LIST ", attr_list,  NULL); MEMprint_buffer("DATA LIST", data_list,  NULL);}
  
   /*************************************************
    * Search the data buffer attributes to find the *
    * position of the state name and status.        *
    *************************************************/

    attributes = (char **) data_list->column_ptr;        
    num_attrs = data_list->columns;                     
                                                     
    i = 0;
    while ( i < num_attrs )
    {
      if ( !strcmp ( attributes[i], "n_status" ) )		stat_col = i;
      else if ( !strcmp ( attributes[i], "n_statename" ) )	name_col = i;
      ++i;
    }  

   /********************************************
    * Search the data buffer to find the state *
    * in question and set its status.          *
    ********************************************/
 
    datas = (char **) data_list->data_ptr;
    num_rows  = data_list->rows;

    for (found=0, curr_row=0; !found && curr_row < num_rows; curr_row++ )
    {
	temp = curr_row * num_attrs;
	if (!strcmp(datas[temp+name_col], "creation complete"))
	    {
		status = MEMwrite_data (data_list, "next", curr_row+1, stat_col+1);
		if ( status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data") ) goto end;
		found = 1;
            }
    }

    if ( DSdebug > 4 )      MEMprint_buffer("DATA LIST (AFTER) ", data_list,  NULL);

   /*****************************************
    * Do the actual transition on the item. *
    *****************************************/

   if ( !found )	status = DS_TRANS_NOT_FOUND;
   else
		{
		status = NFMRmake_transition ( DSUSERID, attr_list, data_list );
		NFM2_format_debug_message("\tNFMRmake_transition status %D",status);
		if ( status != NFM2_check_status(status,NFM_SUCCESS,"NFMRmake_transition") ) goto end;
		status = 0;
		}


   /*********************************************
    * Tell NFM how everything went, and get the *
    * error message loaded in the mesasge var   * 
    ********************************************/

end:

	NFM2_set_to_state ();
	NFM2_format_debug_message("Exiting NFM2_transition_no - status = %D", status );
	return ( status );
}


/******************************************************************************

Doc:    NFM2_generic_cancel

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_generic_cancel(operation,
                                       catalog_name,
                                       item_name,
                                       item_rev);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	NFM2_generic_cancel(operation,catalog,item_name,item_rev)
   long operation;  /* I - ?? */
   char *catalog;   /* I - NFM catalog name */
   char *item_name; /* I - ?? */
   char *item_rev;  /* I - ?? */
{
	long	status;
	NFM2_clear_messages("NFM2_generic_cancel");
	NFM2_format_debug_message("Generic cancel - %d  Catalog <%s> Item <%s> Revision <%s>",operation,catalog,item_name,item_rev);
	switch (operation)
		{
		case 1:
			status = NFMRcancel_item_backup_flag(DSUSERID,catalog,item_name,item_rev);
			NFM2_format_debug_message("\tNFMRcancel_item_backup_flag status %D",status);
			if (status == NFM2_check_status(status,NFM_SUCCESS,"NFMRcancel_item_backup_flag")) status = 0;
			break;
		case 2:
			status = NFMRcancel_item_archive_flag(DSUSERID,catalog,item_name,item_rev);
			NFM2_format_debug_message("\tNFMRcancel_item_archive_flag status %D",status);
			if (status == NFM2_check_status(status,NFM_SUCCESS,"NFMRcancel_item_archive_flag")) status = 0;
			break;
		default:
			status = NFMRcancel_co_item(DSUSERID,catalog,item_name,item_rev);
			NFM2_format_debug_message("\tNFMRcancel_co_item status %D",status);
			if (status == NFM2_check_status(status,NFM_SUCCESS,"NFMRcancel_co_item")) status = 0;
			break;
		}
   return(status);
}


/******************************************************************************

Doc:    NFM2_find_matching_filename

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = NFM2_find_matching_filename(datalist,
                                               string,
                                               filename,
                                               matching_name);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	NFM2_find_matching_filename(datalist,string,filename,matching_name)
   char *datalist;      /* I - ?? */
   char *string;        /* I - ?? */
   char *filename;      /* I - ?? */
   char *matching_name; /* O - ?? */
{
	char	*ptr,original[2048],new[2048],*token;
	long	names,loop,loop2;
	NFM2_format_debug_message("<%s>\n<%s>\n<%s>",datalist,filename,string);
	ptr = strrchr(string,'#');
	if (ptr == NULL)	{strcpy(matching_name,filename);return 1;}
	strcpy(matching_name,"");	strcpy(original,"");	strcpy(new,"");
	strcpy(original,ptr);
	*ptr = 0;	strcpy(new,string);
	NFM2_format_debug_message("<%s>\n<%s>",original,new);
	token = (char *)strtok(original,"~");
	names = atoi((char *)strtok((char *)NULL,"~"));
	for (loop = 0; loop < names; loop++)
		{
		token = (char *)strtok((char *)NULL,"~");
		if (strcmp(token,filename) == 0)
			{
			token = (char *)strtok(new,"~");
			loop2 = atoi((char *)strtok((char *)NULL,"~"));
			if (loop2 != names)	NFM2_format_debug_message("File Name Specification Has A Problem - # Of Original Names %d Does Not Match # Of External File Names %d",names,loop2);
			for (loop2 = 0; loop2 <= loop; loop2++)	{token = (char *)strtok(new,"~");}
			strcpy(matching_name,token);
			NFM2_format_debug_message("<%s>",matching_name);
			return 0;
			}
		}
	strcpy(matching_name,filename);
	NFM2_format_debug_message("Can't Find Match For <%s> - Returning <%s>",filename,matching_name);
	return -1;
}


/******************************************************************************

Doc:    SS_load_sql_statement

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   Unknown

Description:
        ??

Examples:
          status = SS_load_sql_statement(filename,
                                         sqlline);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	SS_load_sql_statement(filename,sqlline)
   char *filename;  /* I - ?? */
   char *sqlline;   /* I - ?? */
{
	FILE	*sqlfile={NULL};
	char	*pointer;
	long	length,index;
	NFM2_format_debug_message("SS_load_sql_statement - From File <%s>",filename);
	sqlfile = fopen(filename,"r");	if (sqlfile == NULL)	{NFM2_format_debug_message("Unable To Open File <%s>",filename);strcpy(sqlline,filename);	return -1;}
	length = strlen(sqlline);	index = 0;
	while (fgets(&sqlline[index],length,sqlfile) != (char *)NULL)
		{
		pointer = strchr(&sqlline[index],'\n');
		if (pointer != NULL) {*pointer = 32; pointer++; *pointer = '\0';}
		index = strlen(sqlline);	length -= index;
		}
	fclose(sqlfile);
	return 0;
}


/* ---------------------Rob's stuff------------------------------------------*/


/******************************************************************************

Doc:    NFMa_login

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This login function turns on all available forms of nfm debug.  Both
           old and new if the debug level is > 1.

Examples:
          status = NFMa_login(server,
                              environment,
                              user,
                              password,
                              debuglevel,
                              client_id);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers
  07/21/92  wrw  -modified to use the login supplied by NFM 3.0 dp.

******************************************************************************/
long int NFMa_login(server,environment,user,password,debuglevel,client_id)
   char *server;      /* I - NFM server to use */
   char *environment; /* I - NFM environment to use */
   char *user;        /* I - NFM user to login as */
   char *password;    /* I - password of the user */
   long debuglevel;   /* I - level of programmer debug 0-9, 0=off */
   long client_id;    /* I - client Id to connect with */
{
char	dbgfilename[80], server_name[80], env_name[80], app_id[12];
int     i,toggle[NFM_DEBUG_SUBSYSTEMS];
char    files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
long	status,term_status,loop;
int	flag1, flag2, flag3, flag4;
MEMptr	login_attr=NULL, login_data=NULL, login_value=NULL, login_wflist=NULL;

	sprintf(dbgfilename,"/usr/tmp/nfm_%d",client_id);
	flag1 = flag2 = flag3 = flag4 = 0;
	DSdebug = debuglevel;
	if (DSdebug > 6) DSdebug = 6;
	if (debuglevel > 5) flag1 = 1;	if (debuglevel > 6) flag2 = 1;
	if (debuglevel > 7) flag3 = 1;	if (debuglevel > 8) flag4 = 1;
	if (debuglevel > 0) NFM2_open_nfm2_debug_file(client_id,debuglevel);

        memset(NumberOfRowsRetrieved,'\0',sizeof(NumberOfRowsRetrieved));
        memset(SpecifiedRowCount,'\0',sizeof(SpecifiedRowCount));
        memset(CursorSpecificSqlStatement,'\0',sizeof(CursorSpecificSqlStatement));

	SUCCESS_CODE[NFM_SUCCESS] = NFM_S_SUCCESS;
	SUCCESS_CODE[MEM_SUCCESS] = MEM_S_SUCCESS;
	SUCCESS_CODE[SQL_SUCCESS] = SQL_S_SUCCESS;
	SUCCESS_CODE[NET_SUCCESS] = NET_S_SUCCESS;
	SUCCESS_CODE[ERR_SUCCESS] = ERR_S_SUCCESS;
	if (DSdebug)
		for (loop = 0; loop < MAX_SUCCESS_CODES; loop++)
			NFM2_format_debug_message("Success Code For %s = %D"
												,SUCCESS_CODES[loop],SUCCESS_CODE[loop]);

	NFM2_clear_messages("NFMa_login");
	NFM2_format_debug_message("\tParameters - serv <%s> env <%s> usr <%s> pw <notshown> dbg <%d> id <%d>",server,environment,user,debuglevel,client_id);

	if (!strncmp(server,"nfms_",5))
		strcpy(server_name,server);
	else
		sprintf(server_name,"nfms_%s",server);
	if (!strncmp(environment,"nfme_",5))
		strcpy(env_name,environment);
	else
		sprintf(env_name,"nfme_%s",environment);
	strcpy(app_id,"NFM");

	if (Initialize_NFM_Messages == 1) {
		status=ERRinit_messages("/usr/ip32/nfm/config/english/messages"
										,UMS_INDEX);
		if (status != SUCCESS_CODE[ERR_SUCCESS]) {
			NFM2_format_debug_message("Status From ERRinit_messages - Status = %D"
												,status);
			return -9998;
			}
		else
			Initialize_NFM_Messages = 0;
		}

	status = NFMRconnect ( server_name );
	if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRconnect")) 
		NFM2_format_debug_message("NFMa_Login - Status from NFMRconnect with server_name %s is %D",server_name,status);

	if (debuglevel) {
		for (i=0;i<NFM_DEBUG_SUBSYSTEMS;i++) {
			toggle[i] = 0;
			files[i][0]=0;
			}
		toggle[2] =  1; strcpy(files[2],"/usr/tmp/nfm.dbg");
		toggle[3] =  1; strcpy(files[3],"/usr/tmp/nfm.dbg");
		toggle[4] =  1; strcpy(files[4],"/usr/tmp/nfm.dbg");
		toggle[6] =  1; strcpy(files[6],"/usr/tmp/nfm.dbg");
		toggle[7] =  1; strcpy(files[7],"/usr/tmp/NFMS.dbg");
		toggle[8] =  1; strcpy(files[8],"/usr/tmp/NFMS.dbg");
		toggle[9] =  1; strcpy(files[9],"/usr/tmp/NFMS.dbg");
		toggle[10] = 1; strcpy(files[10],"/usr/tmp/NFMS.dbg");
		toggle[14] = 1; strcpy(files[14],"/usr/tmp/nfm.dbg");
		}

	status  = NFMRlog_in(user,password,env_name,app_id);
	DSUSERID=abs(client_id); if (!DSUSERID) DSUSERID=1;
	if (status != NFM2_check_status(status,NFM_SUCCESS,"NFMRlogin")) {
		NFM2_format_debug_message("NFMa_Login - NFMRlogin is status = %D UserID = %d",status, DSUSERID);
		term_status = NFMRterminate();
		if (term_status!=NFM2_check_status(term_status,NFM_SUCCESS
                                         ,"NFMRterminate"))	
			NFM2_format_debug_message("NFMRterminate Status %D NetId = %D - Network Terminate Failure",term_status,NetId);
		return(-1);
		}

	if (debuglevel)
		NFMRall_debug(toggle,files);

	if (DSUSERID > 0 && DSdebug > 5)
		status = NFMRdebug(flag1,"/usr/tmp/NFM_server.dbg"
								,flag2,"/usr/tmp/NFM_server.dbg"
								,flag3,"/usr/tmp/NFM_server.dbg"
								,flag4,"/usr/tmp/NFM_server.dbg");

	NFMRget_host_info(DSUSERID,0);

	NFM2_properties(env_name);
	MEMclose(&login_attr);	MEMclose(&login_data);
	MEMclose(&login_value);	MEMclose(&login_wflist);

	NFM2_format_debug_message("Out Of NFMRlogin - DSUSERID <%d>",DSUSERID);
	return DSUSERID;
}


/******************************************************************************

Doc:    NFMa_add_set

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This function adds a set to the NFM catalog of your choice.

Examples:
          status = NFMa_add_set(catalog_name,
                                set_name,
                                set_revsion,
                                set_aclno);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFMa_add_set (catalog_name, set_name, set_revision, set_aclno)
   char *catalog_name;   /* I - NFM catalog name */
   char *set_name;       /* I - set name to add */
   char *set_revision;   /* I - revision of the set to add */
   char *set_aclno;      /* I - acl of the set to add */
{
char      **attributes;    /* Attribute list */
long      i;               /* Counter */
long      num_attrs;       /* Number of attributes */
long      status;          /* Return status */

   NFM2_clear_messages("NFMa_add_set");
   NFM2_debug_message("Entering DSadd_set");
   status = NFMRvalidate_user_access(DSUSERID,ADD_ITEM,"","",catalog_name
                                             ,"","");
   if (status != NFM2_check_status(status,NFM_SUCCESS
                                   ,"NFMRvalidate_user_access")) goto end;

    /********************************************
    * Query the add setattributes to get the  *
    * buffers set up they way they need to be. *
    ********************************************/

   status = NFMRquery_add_set_attributes(DSUSERID,catalog_name,&attr_list
                                          ,&data_list,&value_list);
   if (status != NFM2_check_status(status,NFM_SUCCESS
                                  ,"NFMRquery_add_set_attributes")) goto end;
   if ( DSdebug > 4 ) {
      MEMprint_buffer("ATTRIBUTE LIST ", attr_list,  NULL);
      MEMprint_buffer("DATA LIST", data_list,  NULL);
      MEMprint_buffer("VALUE LIST", value_list,  NULL);
      }

    /**********************************************
    * Fill in the data buffer with the necessary *
    * add set information.                      *
    **********************************************/

   attributes = (char **) data_list->column_ptr;
   num_attrs = data_list->columns;
   for ( i = 0; i < num_attrs; ++i ) {
      if (DSdebug > 3) 
         printf ( "Attribute[%d] = %s\n", i, attributes[i] );
   
      if (!strcmp(attributes[i],P_ITEM_NAME)) {
         status = MEMwrite_data ( data_list, set_name, 1, i+1);
         if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
            goto end;
         continue;
         }

      if (!strcmp(attributes[i],P_ITEM_REV)) {
         status = MEMwrite_data ( data_list, set_revision, 1, i+1);
         if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data")) 
            goto end;
         continue;
         }

      if (!strcmp(attributes[i],P_ACL_NO)) {
         status = MEMwrite_data ( data_list, set_aclno, 1, i+1);
         if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data")) 
            goto end;
         continue;
         }
      } /* major for */

   if ( DSdebug > 4 ) { 
      MEMprint_buffer("DATA LIST after MDMwrite data", data_list,  NULL);
      }

   /* check for "'" in data list */
   if (data_list) NFMRtic_it(data_list);

    /***************************
    * Do the actual add set. *
    ***************************/

   status = NFMRadd_item ( DSUSERID, catalog_name, attr_list, data_list );
   if ( status == NFM2_check_status(status,NFM_SUCCESS,"NFMRadd_item")) 
      status = 0;
end:
   NFM2_set_to_state();
   NFM2_format_debug_message("Exiting NFMa_add_set - status = %D", status );
   return ( status );
}


/******************************************************************************

Doc:    NFMa_add_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This function adds an item to the catalog.
        Item name, revision and acl number are supplied as parameters.
        Other attributes (including user defined attributes) may be supplied
            in the 'attributes' parameter.

Examples:
          status = NFMa_add_item(catalog_name,
                                 item_name,
                                 item_revision,
                                 item_aclno,
                                 attributes,
                                 values,
                                 num_of_attr);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFMa_add_item (catalog_name, item_name, item_revision, item_aclno
                   ,attrs,values,num_of_attr)
   char  *catalog_name;   /* I - NFM catalog name */
   char  *item_name;      /* I - name to add */
   char  *item_revision;  /* I - revision to add */
   char  *item_aclno;     /* I - access control list to put item in */
   char **attrs;          /* I - array of additional attributes */
   char **values;         /* I - array of values for above additional attrs. */
   int    num_of_attr;    /* I - number of additional attributes supplied. */
{
char      **attributes;    /* Attribute list */
int       j;
long      i;               /* Counter */
long      num_attrs;       /* Number of attributes */
long      status;          /* Return status */

   NFM2_clear_messages("NFMa_add_item");
   NFM2_debug_message("Entering DSadd_item");
   status = NFMRvalidate_user_access(DSUSERID,ADD_ITEM,"","",catalog_name
                                             ,"","");
   if (status != NFM2_check_status(status,NFM_SUCCESS
                                   ,"NFMRvalidate_user_access")) goto end;

    /********************************************
    * Query the add itemattributes to get the  *
    * buffers set up they way they need to be. *
    ********************************************/

   status = NFMRquery_add_item_attributes(DSUSERID,catalog_name,&attr_list
                                          ,&data_list,&value_list);
   if (status != NFM2_check_status(status,NFM_SUCCESS
                                  ,"NFMRquery_add_item_attributes")) goto end;
   if ( DSdebug > 4 ) {
      MEMprint_buffer("ATTRIBUTE LIST ", attr_list,  NULL);
      MEMprint_buffer("DATA LIST", data_list,  NULL);
      MEMprint_buffer("VALUE LIST", value_list,  NULL);
      }

    /**********************************************
    * Fill in the data buffer with the necessary *
    * add item information.                      *
    **********************************************/

   attributes = (char **) data_list->column_ptr;
   num_attrs = data_list->columns;
   for ( i = 0; i < num_attrs; ++i ) {
      if (DSdebug > 3) 
         printf ( "Attribute[%d] = %s\n", i, attributes[i] );
   
      if (!strcmp(attributes[i],P_ITEM_NAME)) {
         status = MEMwrite_data ( data_list, item_name, 1, i+1);
         if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
            goto end;
         continue;
         }

      if (!strcmp(attributes[i],P_ITEM_REV)) {
         status = MEMwrite_data ( data_list, item_revision, 1, i+1);
         if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data")) 
            goto end;
         continue;
         }

      if (!strcmp(attributes[i],P_ACL_NO)) {
         status = MEMwrite_data ( data_list, item_aclno, 1, i+1);
         if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data")) 
            goto end;
         continue;
         }

      for (j=0;j<num_of_attr;j++) {
         if (!strcmp(attributes[i],attrs[j])) {
            status = MEMwrite_data(data_list,values[j],1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               goto end;
            break;
            }
         } /* inner for */
      } /* major for */

   if ( DSdebug > 4 ) { 
      MEMprint_buffer("DATA LIST after MDMwrite data", data_list,  NULL);
      }

   /* check for "'" in data list */
   if (data_list) NFMRtic_it(data_list);

    /***************************
    * Do the actual add item. *
    ***************************/

   status = NFMRadd_item ( DSUSERID, catalog_name, attr_list, data_list );
   if ( status == NFM2_check_status(status,NFM_SUCCESS,"NFMRadd_item")) 
      status = 0;
end:
   NFM2_set_to_state();
   NFM2_format_debug_message("Exiting NFMa_add_item - status = %D", status );
   return ( status );
}


long NFMa_validate_for_checkout(catalog,item,rev)
	char *catalog;
	char *item;
	char *rev;
{
long status;
   status = NFMRvalidate_user_access(DSUSERID,CHECKOUT_ITEM,"","",catalog,item
													,rev);
   if (status == NFM2_check_status(status,NFM_SUCCESS
                                   ,"NFMRvalidate_user_access"))
		status=0;
	ERRload_struct(NFI,NFI_W_COMMAND_CANCELLED,NULL,NULL);
	NFMRset_wf_state("NFM",NFI_W_COMMAND_CANCELLED,"");
	return(status);
}


/******************************************************************************

Doc:    NFMa_create_default_wa

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   October 23, 1992

Description:
        Creates a default local working area.

Examples:
          status = NFMa_create_default_wa(path,wa_area_name);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:

******************************************************************************/
long NFMa_create_default_wa(my_path,wa_name)
	char *my_path;      /* I - path to use for the wa */
   char *wa_name;   /* 0 - name of the default working area */
{
long status;
char node[64];
char user[64];
char path[256];
char work[256];
char *em;
MEMptr node_info;
MEMptr sa_info;
   
   NFM2_clear_messages("NFMa_create_default_wa");
   NFM2_format_debug_message("users path <%s>",my_path);

	status=_NFMget_wa_system_info(node,user,path,&node_info,&sa_info);

   NFM2_check_status(status,NFM_SUCCESS,"NFMget_wa_system_info");
   NFM2_format_debug_message("Status After NFMget_wa_system_info %D",status);

	if (my_path && my_path[0])
		strcpy(path,my_path);

   NFM2_format_debug_message(
				"Calling NFMRadd_default_working_area: node <%s> user <%s> path <%>"
				,node,user,path);

	status=NFMRadd_default_working_area(node,user,path,wa_name
													,node_info,sa_info);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRadd_default_working_area");
   NFM2_format_debug_message("Status After NFMRadd_default_working_area %D"
										,status);

   if (status==NFM_S_SUCCESS) {
      status = 0;
		if (wa_name[0]==0) {
			sprintf(work,"select n_saname from nfmstoragearea,nfmnodes where n_username='%s' and n_pathname='%s' and nfmstoragearea.n_nodeno=nfmnodes.n_nodeno and n_nodename='%s'",user,path,node);
			NFMa_single_select(work,wa_name,&em);
			}
		}
	else
		wa_name[0]=0;
  	NFM2_format_debug_message("NFMRadd_default_working_area: wa_name <%s>"
										,wa_name);

   return(status);
}


/******************************************************************************

Doc:    NFMa_add_file_entry

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   January 23, 1992

Description:
        Adds a file to an item.

Examples:
        status = NFMa_add_file_entry(catalog_name,
                                     item_name,
                                     item_revision,
                                     cofile,
                                     cifile,
                                     cisano,
                                     file_type,
                                     comment);

Return Status:
       0         - success
       any error status returned by NFMR functions on failure.

History:

******************************************************************************/
long NFMa_add_file_entry(catalog_name,item_name,item_revision,cofile,cifile,cisano,file_type,comment)
   char *catalog_name;     /* I - catalog name to work with */
   char *item_name;        /* I - item name to remove file from */
   char *item_revision;    /* I - item revison */
   char *cofile;           /* I - file add */
   char *cifile;           /* I - internal name */
   char *cisano;           /* I - checkin storage area number */
   char *file_type;        /* I - file type to add */
   char *comment;          /* I - comment to add */
{
char   **attributes;    /* Attribute list */
char   **value;
long   num_rows,num_attrs;
char   str[1024];
long   status;
char   name[50];
int    i,tmp;

   NFM2_clear_messages("NFMa_add_file_entry");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s> <%s> <%s> <%s> <%s>"
                            ,catalog_name,item_name,item_revision,cofile,cifile
                            ,cisano,file_type,comment);

   tmp=atoi(cisano);
   name[0]=0;
   status=NFMa_storage_area_names(name,&tmp);
   if (status) name[0]=0;

   status=NFMRget_file_information(catalog_name,NFMa_ticked(item_name)
                                  ,NFMa_ticked(item_revision)
                                  ,NFM_ADD_FILE_TO_ITEM,&attr_list,&data_list
                                  ,&value_list);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRget_file_information");
   NFM2_format_debug_message("Status After NFMRget_file_information %D",status);

   if (status != NFM_S_SUCCESS) return (status);
   attributes = (char **) data_list->column_ptr;
   value = (char **) data_list->data_ptr;
   num_rows = data_list->rows;
   num_attrs = data_list->columns;
   str[0]=0;
 
   for (i=0;i<num_attrs;++i) {
      if (!strcmp(attributes[i],P_CO_FILE) && cofile && strlen(cofile))
         strcat(str,cofile);
      else if (!strcmp(attributes[i],P_CI_FILE) && cifile && strlen(cifile))
         strcat(str,cifile);
      else if (!strcmp(attributes[i],"n_cisaname") && cisano && strlen(cisano)){
         if (name[0])
            strcat(str,name);
         else
            strcat(str,value[i]);
         }
      else if (!strcmp(attributes[i],P_FILE_TYPE)&&file_type&&strlen(file_type))
         strcat(str,file_type);
      else if (!strcmp(attributes[i],P_CO_COMM) &&  comment &&  strlen(comment))
         strcat(str,comment);
      else 
         strcat(str,value[i]);

      strcat(str, "\1");
      }

   status = MEMwrite(data_list, str);
   if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite")) {
      NFMRreset_file_information(catalog_name,item_name,item_revision);
      return(status);
      }

   status = MEMbuild_array(data_list);
   if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array")) {
      NFMRreset_file_information(catalog_name,item_name,item_revision);
      return(status);
      }

   attributes = (char **) data_list->column_ptr;
   value = (char **) data_list->data_ptr;

   if (data_list) NFMRtic_it(data_list);
   status = NFMRdefine_file_information(catalog_name,NFMa_ticked(item_name)
                                       ,NFMa_ticked(item_revision)
                                       ,NFM_ADD_FILE_TO_ITEM,data_list);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRdefine_file_information");
   NFM2_format_debug_message("Status After NFMRdefine_file_information %D"
                            ,status);

   if (status != NFM_S_SUCCESS)
      return(status);

   return(0);
}


/******************************************************************************

Doc:    NFMa_change_file_entry

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   January 23, 1992

Description:
        Adds a file to an item.

Examples:
        status = NFMa_change_file_entry(catalog_name,
                                        item_name,
                                        item_revision,
                                        oldfile,
                                        cofile,
                                        cifile,
                                        cisano,
                                        file_type,
                                        comment);

Return Status:
       0         - success
       any error status returned by NFMR functions on failure.

History:

******************************************************************************/
long NFMa_change_file_entry(catalog_name,item_name,item_revision,oldfile,cofile,cifile,cisano,file_type,comment)
   char *catalog_name;     /* I - catalog name to work with */
   char *item_name;        /* I - item name to remove file from */
   char *item_revision;    /* I - item revison */
   char *oldfile;          /* I - old cofilename */
   char *cofile;           /* I - file add */
   char *cifile;           /* I - internal name */
   char *cisano;           /* I - checkin storage area number */
   char *file_type;        /* I - file type to add */
   char *comment;          /* I - comment to add */
{
char   **attributes;    /* Attribute list */
char   **value;
long   num_rows,num_attrs;
long   status,co_attr;
int    i,row;
char   name[50];
int    tmp;

   NFM2_clear_messages("NFMa_change_file_entry");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s> <%s> <%s> <%s> <%s> <%s>"
                            ,catalog_name,item_name,item_revision,oldfile
                            ,cofile,cifile,cisano,file_type,comment);

   tmp=atoi(cisano);
   name[0]=0;
   status=NFMa_storage_area_names(name,&tmp);
   if (status) name[0]=0;

   status=NFMRget_file_information(catalog_name,NFMa_ticked(item_name)
                                  ,NFMa_ticked(item_revision)
                                  ,NFM_CHANGE_FILE_INFORMATION,&attr_list
                                  ,&data_list,&value_list);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRget_file_information");
   NFM2_format_debug_message("Status After NFMRget_file_information %D",status);

   if (status != NFM_S_SUCCESS) return (status);
   attributes = (char **) data_list->column_ptr;
   value = (char **) data_list->data_ptr;
   num_rows = data_list->rows;
   num_attrs = data_list->columns;
 
   co_attr=0;
   for (i=0;i<num_attrs;i++) {
      if (!strcmp(attributes[i],"n_cofilename")) {
         co_attr=i;
         break;
         }
      }
  
   for (row=0;row<num_rows;row++)
      if (!strcmp(value[row*num_attrs+co_attr],oldfile))
         break;
   if (row==num_rows) row--;

   for (i=0;i<num_attrs;i++) {
      if (!strcmp(attributes[i],"n_status")) {
         status = MEMwrite_data(data_list,"Y",row+1,i+1);
         if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
            return(status);
         }
      else if (!strcmp(attributes[i],"n_cofilename")) {
         if (cofile && strlen(cofile)) {
            status = MEMwrite_data(data_list,cofile,row+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               return(status);
            }
         }
      else if (!strcmp(attributes[i],"n_cifilename")) {
         if (cifile && strlen(cifile)) {
            status = MEMwrite_data(data_list,cifile,row+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               return(status);
            }
         }
      else if (!strcmp(attributes[i],"n_cisaname")) {
         if (cisano && strlen(cisano) && name[0]) {
            status = MEMwrite_data(data_list,name,row+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               return(status);
            }
         }
      else if (!strcmp(attributes[i],"n_filetype")) {
         if (file_type && strlen(file_type)) {
            status = MEMwrite_data(data_list,file_type,row+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               return(status);
            }
         }
      else if (!strcmp(attributes[i],"n_cocomment")) {
         if (comment && strlen(comment)) {
            status = MEMwrite_data(data_list,comment,row+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               return(status);
            }
         }
      }
  
   if (data_list) NFMRtic_it(data_list);
   status = NFMRdefine_file_information(catalog_name,NFMa_ticked(item_name)
                                       ,NFMa_ticked(item_revision)
                                       ,NFM_CHANGE_FILE_INFORMATION,data_list);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRdefine_file_information");
   NFM2_format_debug_message("Status After NFMRdefine_file_information %D"
                            ,status);

   if (status != NFM_S_SUCCESS)
      return(status);

   return(0);
}


/******************************************************************************

Doc:    NFMa_remove_file_entry

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   January 23, 1992

Description:
        Removes a file from an item.

Examples:
          status = NFMa_remove_file_entry(catalog_name,
                                          item_name,
                                          item_revision,
                                          co_file);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:

******************************************************************************/
long NFMa_remove_file_entry(catalog_name,item_name,item_revision,co_filename)
   char *catalog_name;     /* I - catalog name to work with */
   char *item_name;        /* I - item name to remove file from */
   char *item_revision;    /* I - item revison */
   char *co_filename;      /* I - file to remove */
{
char   **attributes;    /* Attribute list */
char   **value;
long   num_rows,num_attrs;
long   status,co_attr,sts_attr;
int    i;

   NFM2_clear_messages("NFMa_remove_file_entry");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s>",catalog_name,item_name
                            ,item_revision,co_filename);

   status=NFMRget_file_information(catalog_name,NFMa_ticked(item_name)
                                  ,NFMa_ticked(item_revision)
                                  ,NFM_DELETE_FILE_FROM_ITEM,&attr_list
                                  ,&data_list,&value_list);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRget_file_information");
   NFM2_format_debug_message("Status After NFMRget_file_information %D",status);

   if (status != NFM_S_SUCCESS) return (status);
   attributes = (char **) data_list->column_ptr;
   value = (char **) data_list->data_ptr;
   num_rows = data_list->rows;
   num_attrs = data_list->columns;
 
   co_attr=sts_attr=0;
   for (i=0;i<num_attrs;i++) {
      if (!strcmp(attributes[i],"n_cofilename"))
         co_attr=i;
      if (!strcmp(attributes[i],"n_status"))
         sts_attr=i;
      }
  
   for (i=0;i<num_rows;i++)
      if (!strcmp(value[i*num_attrs+co_attr],co_filename))
         break;
   if (i==num_rows) i--;

   status = MEMwrite_data(data_list,"Y",i+1,sts_attr+1);
   if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
      return(status);

   if (data_list) NFMRtic_it(data_list);
   status = NFMRdefine_file_information(catalog_name,NFMa_ticked(item_name)
                                       ,NFMa_ticked(item_revision)
                                       ,NFM_DELETE_FILE_FROM_ITEM,data_list);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRdefine_file_information");
   NFM2_format_debug_message("Status After NFMRdefine_file_information %D"
                            ,status);

   if (status != NFM_S_SUCCESS)
      return(status);

   return(0);
}


/******************************************************************************

Doc:    NFMa_set_out

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   September 21, 1994

Description:
        Checks out an set that already has all file and item information
            provided correctly.

Examples:
          status = NFMa_set_out(catalog_name,
                               set_name,
                               set_revision,
                               storage_area);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
   11/08/94  wrw  -added a memeset to clear out the operation buffer.

******************************************************************************/
long NFMa_set_out(catalog_name,set_name,set_revision,storage_area)
   char *catalog_name;   /* I - name of catalog to user */
   char *set_name;      /* I - name of set to checkout */
   char *set_revision;  /* I - revsion of set to checkout */
   char *storage_area;   /* I - storage area the files will come from */
{
long status;
struct NFMwf_info wf_info;
struct NFMoperation operation;
   
   NFM2_clear_messages("NFMa_set_out");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s>",catalog_name,set_name
                            ,set_revision,storage_area);

   wf_info.workflow=NFM_WORKFLOW;
   strcpy(wf_info.command,CHECKOUT_SET);
   wf_info.workflow_name[0]=0;
   wf_info.project_name[0]=0;
   wf_info.app_name[0]=0;

	memset(&operation,0,sizeof(struct NFMoperation));
   operation.transfer=NFM_TRANSFER;
   operation.delete=NFM_DELETE_FILES;
   operation.purge=NFM_PURGE;

   status = NFMRcheckout_set(catalog_name,-1,NFMa_ticked(set_name)
                            ,NFMa_ticked(set_revision),-1
                            ,storage_area,wf_info,NFM_SAME_OPERATION
                            ,&operation,0);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRcheckout_set");
   NFM2_format_debug_message("Status After NFMRcheckout_set %D",status);

   if (status==NFM_S_SUCCESS || status==NFM_I_ITEM_PROMOTED_TO_MS_SET
		|| status == NFM_W_INVALID_VERSION_LIMIT)
      status = 0;

   return(status);
}


/******************************************************************************

Doc:    NFMa_set_in

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   September 21, 1994

Description:
        Checks in an set that already has all file and item information
            provided correctly.

Examples:
          status = NFMa_set_in(catalog_name,
                               set_name,
                               set_revision,
                               storage_area);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:

******************************************************************************/
long NFMa_set_in(catalog_name,set_name,set_revision,storage_area)
   char *catalog_name;   /* I - name of catalog to user */
   char *set_name;      /* I - name of set to checkin */
   char *set_revision;  /* I - revsion of set to checkin */
   char *storage_area;   /* I - storage area the files will come from */
{
long status;
struct NFMwf_info wf_info;
struct NFMoperation operation;
   
   NFM2_clear_messages("NFMa_set_in");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s>",catalog_name,set_name
                            ,set_revision,storage_area);

   wf_info.workflow=NFM_WORKFLOW;
   strcpy(wf_info.command,CHECKIN_SET);
   wf_info.workflow_name[0]=0;
   wf_info.project_name[0]=0;
   wf_info.app_name[0]=0;

	memset(&operation,0,sizeof(struct NFMoperation));
   operation.transfer=NFM_TRANSFER;
   operation.delete=NFM_DELETE_FILES;
   operation.purge=NFM_PURGE;

   status = NFMRcheckin_set(catalog_name,-1,NFMa_ticked(set_name)
                            ,NFMa_ticked(set_revision),-1
                            ,storage_area,wf_info,NFM_SAME_OPERATION
                            ,&operation,0);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRcheckin_set");
   NFM2_format_debug_message("Status After NFMRcheckin_set %D",status);

   if (status==NFM_S_SUCCESS || status==NFM_I_ITEM_PROMOTED_TO_MS_SET
		|| status == NFM_W_INVALID_VERSION_LIMIT)
      status = 0;

   return(status);
}


/******************************************************************************

Doc:    NFMa_simple_checkin_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   January 23, 1992

Description:
        Checks in an item that already has all file information provided 
           correctly.

Examples:
          status = NFMa_simple_checkin_item(catalog_name,
                                       item_name,
                                       item_revision,
                                       storage_area);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:

******************************************************************************/
long NFMa_simple_checkin_item(catalog_name,item_name,item_revision,storage_area)
   char *catalog_name;   /* I - name of catalog to user */
   char *item_name;      /* I - name of item to checkin */
   char *item_revision;  /* I - revsion of item to checkin */
   char *storage_area;   /* I - storage area the files will come from */
{
long status;
struct NFMwf_info wf_info;
struct NFMoperation operation;
   
   NFM2_clear_messages("NFMa_simple_checkin_item");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s>",catalog_name,item_name
                            ,item_revision,storage_area);

   wf_info.workflow=NFM_WORKFLOW;
   strcpy(wf_info.command,CHECKIN_ITEM);
   wf_info.workflow_name[0]=0;
   wf_info.project_name[0]=0;
   wf_info.app_name[0]=0;

   operation.transfer=NFM_TRANSFER;
   operation.delete=NFM_DELETE_FILES;
   operation.purge=NFM_PURGE;

   status = NFMRcheckin_item(catalog_name,-1,NFMa_ticked(item_name)
                            ,NFMa_ticked(item_revision)
                            ,storage_area,wf_info,operation);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRcheckin_item");
   NFM2_format_debug_message("Status After NFMRcheckin_item %D",status);

   if (status==NFM_S_SUCCESS || status==NFM_I_ITEM_PROMOTED_TO_MS_SET
		|| status == NFM_W_INVALID_VERSION_LIMIT)
      status = 0;

   return(status);
}


long	NFMa_get_default_security(cat,item,rev,file,out)
	char *cat;
	char *item;
	char *rev;
	char *file;
	char *out;
{
char sql[1024];
char work[64];
char *error_m;
long status;

	NFM2_clear_messages("NFMa_get_default_security");
	NFM2_format_debug_message("<%s> <%s> <%s> <%s>",cat,item,rev,file);

	out[0]=0;

	sprintf(sql,"select n_cocomment,n_fileversion from %s,f_%s where n_itemname='%s' and n_itemrev='%s' and n_cofilename='%s' and n_cocomment like '%%00000000' and n_itemno=n_itemnum order by n_fileversion desc",cat,cat,item,rev,file);
	status=NFMa_single_select(sql,work,&error_m);
	if (!status && work[0]) {
		NFM2_format_debug_message("returning default of <%s>",work);
		strcpy(out,work);
		return(0);
		}
	
/*
	this part of the code would add the default security level as the current
   security level of a new item.  it was decided that this was not where it
   should be handled.

                      wrw 1/94


	sprintf(sql,"select d_accesslevel from dmands_users,nfmcatalogs where d_userno=-1 and nfmcatalogs.n_catalogno=d_catalogno and n_catalogname='%s'",cat);
	status=NFMa_single_select(sql,work,&error_m);
	if (!status && work[0]) {
		NFM2_format_debug_message("returning default of <%s>",work);
		strcpy(out,work);
		return(0);
		}
*/
	
	NFM2_format_debug_message("returning default of <>");
	return(1);
}


/******************************************************************************

Doc:    NFMa_checkin_mult_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        Checks in multiple files to an item, or multiple items into a set
        Allows the user to supply all attributes that are allowed at checkin
           time.  
        If using to check in to a set, subsitute set information where item
           info is now.
        You must enter EITHER the storage area OR the node/user/password/path
           that the file will come from.  Both sets of information are not
           needed.
        All file attribute arrays must be in 1-to-1 correspondence. 
           i.e. ci_files[1] goes with co_files[1] and file_types[1].

Examples:
          status = NFMa_checkin_mult_item(catalog_name,
                                          item_name,
                                          item_revision,
                                          storage_area,
                                          temprorary_node,
                                          temprorary_user,
                                          temprorary_password,
                                          temprorary_path,
                                          num_files,
                                          co_files,
                                          ci_files,
                                          cisas,
                                          file_types,
                                          co_comms);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers
  01/21/92  wrw  -completely re-written to use NFM 3.? calls, yet provide
                     same functionality.
  09/04/93  wrw  -changed the way the add/delete/change files works since NFM
                     'fixed' a 'bug' that allowed deletion and changing of 
                     n_cofilenames

******************************************************************************/
/*ARGSUSED*/
long NFMa_checkin_mult_item (catalog_name,item_name,item_revision,storage_area,
	       temporary_node,temporary_user,temporary_password,temporary_path,
	       num_files,co_files,ci_files,cisas,file_types,co_comms)
   char *catalog_name;       /* I - NFM catalog */
   char *item_name;          /* I - item name to check in */
   char *item_revision;      /* I - item revision to check in */
   char *storage_area;       /* I - storage area the files will come from */
   char *temporary_node;     /* I - node the files will come from */
   char *temporary_user;     /* I - user the files will come from */
   char *temporary_password; /* I - password for above user */
   char *temporary_path;     /* I - directory the files will come from */
   long  num_files;          /* I - number of files in list of names */
   char  **co_files;         /* I - list of file names to check in */
   char  **ci_files;         /* I - list of file names to store as */
   char  **cisas;            /* I - list of storage areas to pull files from */
   char  **file_types;       /* I - list of file types for the files */
   char  **co_comms;         /* I - list of check out comments for the files */
{
char sql_line[600];
char value[100];
char v1[100];
char v2[100];
char v3[100];
char v4[100];
char *error_m;
int   db_files,j,i,a;
long  status;
char version[5];
char *p1,*p2,*p3,*p4,*p5;
char *my_buff;
char def[64];

   NFM2_clear_messages("NFMa_checkin_mult_item");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s> num_files<%d>",catalog_name
									,item_name,item_revision,storage_area,num_files);

   my_buff = (char *) malloc(5000*sizeof(char));
   if (!my_buff) return(1);

   sprintf(sql_line,"select n_fileversion,n_fileno,n_cofilename,n_cifilename,n_cosano,n_cisano from %s,f_%s where n_itemname='%s' and n_itemrev='%s' and n_itemno=n_itemnum and n_cofilename is not NULL and n_fileversion=(select max(n_fileversion) from f_%s where n_itemnum=n_itemno)"
          ,catalog_name,catalog_name,NFMa_ticked(item_name)
          ,NFMa_ticked(item_revision),catalog_name);
   status = NFMa_multi_select(sql_line,5000,my_buff,"n_fileversion",1,value
                             ,&error_m);
   if (status && status!=-1) {
      free(my_buff);
      return (status);
      }

	db_files=(status==(-1))?0:1;

/* find number of files in database */
   strcpy(version,value);
   while (!status) {
      status=NFMa_multi_select(NULL,0,my_buff,"n_fileversion",db_files+1,value
                              ,&error_m);
      if (status || strcmp(version,value))
         break;
      db_files++;
      }

/* check for changes and additions that are allowed */
	if (co_files)
		for (a=i=0;i<num_files;i++) {
			p1=co_files[i];
         p2 = (ci_files)?ci_files[i]:NULL;
         p3=cisas[i];
         p4 = (file_types)?file_types[i]:NULL;
         p5 = (co_comms)?co_comms[i]:NULL;
			for (j=0;j<db_files;j++) {
  	    		NFMa_multi_select(NULL,0,my_buff,"n_cofilename",j+1,value,&error_m);
				if (!strcmp(value,co_files[i])) break;
				}
			if (j<db_files) {  /* file entry exists, check other values */
      	   NFMa_multi_select(NULL,0,my_buff,"n_cifilename",j+1,v1,&error_m);
            NFMa_multi_select(NULL,0,my_buff,"n_cisano",j+1,v2,&error_m);
            NFMa_multi_select(NULL,0,my_buff,"n_filetype",j+1,v3,&error_m);
            NFMa_multi_select(NULL,0,my_buff,"n_cocomment",i+1,v4,&error_m);
				if (		(p2 && strcmp(p2,v1))
						|| (p3 && strcmp(p3,v2))
						|| (p4 && strcmp(p4,v3))
						|| (p5 && strcmp(p5,v4))) {
	      		status=NFMa_change_file_entry(catalog_name,item_name
															,item_revision,p1,p1,p2,p3,p4,p5);
					if (status) {
            		free(my_buff);
            		return(status);
						}
					}
				}
			else { /* file not found, add if this will not violate rules */
				if (num_files<=(db_files+a)) {
					continue; /* cannot delete from, or change the cofilename
                            this checkin is probably doomed to fail,
                            but we will let NFM worry about the error message */
					}
				a++;
         	status=NFMa_add_file_entry(catalog_name,item_name,item_revision,p1
													,p2,p3,p4,p5);
	         if (status) {
	            free(my_buff);
	            return(status);
	            }
				}
			}

   if (my_buff) free(my_buff);

   status=NFMa_simple_checkin_item(catalog_name,item_name,item_revision
                                  ,storage_area);

	for (a=i=0;i<num_files;i++) {
		p1=co_files[i];
      p5 = (co_comms)?co_comms[i]:NULL;
		if (!p5 || !p5[0]) {
			if (NFMa_get_default_security(catalog_name,item_name,item_revision,p1
											,def)) return (status);

			sprintf(sql_line,"select max(n_fileversion) from f_%s,%s where n_itemno=n_itemnum and n_itemname='%s' and n_itemrev='%s'"
						,catalog_name,catalog_name,item_name,item_revision);
			NFMa_single_select(sql_line,value,&error_m);

			sprintf(sql_line,"update f_%s set n_cocomment='%s' where n_itemnum=(select n_itemno from %s where n_itemname='%s' and n_itemrev='%s') and n_cofilename='%s' and n_fileversion=%s"
						,catalog_name,def,catalog_name,item_name,item_revision,p1
						,value);
			NFMa_single_select(sql_line,def,&error_m);
			}
		}
   return(status);
}


/******************************************************************************

Doc:    NFMa_delete_catalog

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   March 12, 1992

Description:
        Deletes a catalog if it is empty.  
        No check made to see if it is empty.

Examples:
          status = NFMa_delete_catalog(catalog_name);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:

******************************************************************************/
long NFMa_delete_catalog (catalog_name)
   char *catalog_name;       /* I - NFM catalog */
{
long status;

   NFM2_clear_messages("NFMa_delete_catalog");
   NFM2_format_debug_message("Catalog Name = %s",catalog_name);

   NFM2_format_debug_message("Ensuring closed cursors <%s>",manditory_ddl);
	NFMRsqlstmt(manditory_ddl);

   status = NFMRdelete_catalog(DSUSERID,catalog_name);
   NFM2_format_debug_message("Status After NFMRdelete_catalog %D",status);

   if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRdelete_catalog"))
      return(status);
   else
      return(0);
}


/******************************************************************************

Doc:    NFMb_checkin_mult_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        Checks in multiple files to an item, or multiple items into a set
        Allows the user to supply all attributes that are allowed at checkin
           time.  
        If using to check in to a set, subsitute set information where item
           info is now.
        You must enter EITHER the storage area OR the node/user/password/path
           that the file will come from.  Both sets of information are not
           needed.
        All file attribute arrays must be in 1-to-1 correspondence. 
           i.e. ci_files[1] goes with co_files[1] and file_types[1].

Examples:
          status = NFMb_checkin_mult_item(catalog_name,
                                          item_name,
                                          item_revision,
                                          storage_area,
                                          temprorary_node,
                                          temprorary_user,
                                          temprorary_password,
                                          temprorary_path,
                                          num_files,
                                          co_files,
                                          ci_files,
                                          cisas,
                                          file_types,
                                          co_comms,
                                          checkin_type);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers
  01/21/92  wrw  -replaced by new NFM routines.  Left here for historic
                    perspective.

******************************************************************************/
long NFMb_checkin_mult_item (catalog_name,item_name,item_revision,storage_area,
	       temporary_node,temporary_user,temporary_password,temporary_path,
	       num_files,co_files,ci_files,cisas,file_types,co_comms
               ,checkin_type)
   char *catalog_name;       /* I - NFM catalog */
   char *item_name;          /* I - item name to check in */
   char *item_revision;      /* I - item revision to check in */
   char *storage_area;       /* I - storage area the files will come from */
   char *temporary_node;     /* I - node the files will come from */
   char *temporary_user;     /* I - user the files will come from */
   char *temporary_password; /* I - password for above user */
   char *temporary_path;     /* I - directory the files will come from */
   long  num_files;          /* I - number of files in list of names */
   char  **co_files;         /* I - list of file names to check in */
   char  **ci_files;         /* I - list of file names to store as */
   char  **cisas;            /* I - list of storage areas to pull files from */
   char  **file_types;       /* I - list of file types for the files */
   char  **co_comms;         /* I - list of check out comments for the files */
   char *checkin_type;       /* I - flag indicating item or set
                                    values are: CHECKIN_ITEM
                                                CHECKIN_SET */
{
/* Local declarations */
char   **attributes;    /* Attribute list */
char   **value;
char  str[1028];
int   tried_checkin=0;
long  i,j;               /* Counter */
long  num_attrs;       /* Number of attributes */
long  num_rows;        /* Number of rows */
long  status;          /* Return status */

   NFM2_clear_messages("NFMb_checkin_mult_item");
   NFM2_format_debug_message("Checkin Type = %s",checkin_type);
   NFM2_format_debug_message("\tCHECKIN_ITEM CHECKIN_SET  %s %s"
                            ,CHECKIN_ITEM, CHECKIN_SET);
   NFM2_format_debug_message("catalog_name, item_name, item_revision, storage_area, temporary_node\ntemporary_user, temporary_password, temporary_path");
   NFM2_format_debug_message("<%s> <%s> <%s> <%s> <%s> <%s> <%s> <%s>"
                            ,catalog_name,item_name,item_revision,storage_area
                            ,temporary_node,temporary_user,temporary_password
                            ,temporary_path);

    /****************************************
    * See if the user has the authority to *
    * checkin an item.                     *
    ****************************************/

   status = NFMRvalidate_user_access(DSUSERID,checkin_type,"","",catalog_name
                                    ,item_name,item_revision);
   if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access"))
      goto end;

    /*********************************
    * Prepare the item for checkin. *
    *********************************/
   if (strcmp(checkin_type,CHECKIN_ITEM) == 0) {
      status = NFMRprepare_item_checkin(DSUSERID,catalog_name,item_name
                                       ,item_revision,&attr_list,&data_list);
      }
   else {
      status = NFMRprepare_set_checkin(DSUSERID,catalog_name,item_name
                                      ,item_revision,&attr_list,&data_list);
      }

   NFM2_format_debug_message("Status After NFMRprepare_item/set_checkin %D"
                            ,status);
   if (status!=NFM2_check_status(status,NFM_SUCCESS
                                ,"NFMRprepare_item/set_checkin")) 
      goto end;
   if ( DSdebug > 4 ) {
     MEMprint_buffer("ATTRIBUTE LIST ",attr_list,NULL);
     MEMprint_buffer("DATA LIST", data_list,  NULL);
     }

    /**********************************************
    * Fill in the data buffer with the necessary *
    * checkin item information.                  *
    **********************************************/

   attributes = (char **) data_list->column_ptr;
   value = (char **) data_list->data_ptr;
   num_rows = data_list->rows;
   num_attrs = data_list->columns;

   if (num_files < num_rows) {
      /* attempted to checkin less files now than were currently there. */
      status = 9999;
      goto end;
      }

   if ( DSdebug > 3 ) { 
      for (i = 0; i < num_attrs; ++i) { 
         NFM2_format_debug_message("attribute[%d] = %s\tvalue[%d] = %s",i
                                   ,attributes[i],i,value[i]);
         }
      }

 for (j=0; j<num_rows; j++) { 
   if (j >= num_files)
      break;
   for ( i = 0; i < num_attrs; ++i ) {
      if (!strcmp(attributes[i],P_CO_FILE)) {
         if (co_files && strlen(co_files[j])) {
            status = MEMwrite_data(data_list,co_files[j],j+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               goto end;
            }
         continue;
         }

      if (!strcmp(attributes[i],P_CI_FILE)) {
         if (ci_files && strlen(ci_files[j])) {
            status = MEMwrite_data(data_list,ci_files[j],j+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               goto end;
            }
         continue;
         }

      if (!strcmp(attributes[i],P_CI_SA)) {
         if (cisas && strlen(cisas[j])) {
            status = MEMwrite_data(data_list,cisas[j],j+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               goto end;
            }
         continue;
         }

      if (!strcmp(attributes[i],P_FILE_TYPE)) {
         if (file_types && strlen(file_types[j])) {
            status = MEMwrite_data(data_list,file_types[j],j+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               goto end;
            }
         continue;
         }

      if (!strcmp(attributes[i],P_CO_COMM)) {
         if (co_comms && strlen(co_comms[j])) {
            status = MEMwrite_data(data_list,co_comms[j],j+1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               goto end;
            }
         continue;
         }
      }
   }
   
   for (j = num_rows; j < num_files; ++j) {
      str[0]=0;
      for ( i = 0; i < num_attrs; ++i ) {
         if (   !strcmp(attributes[i],P_CO_FILE)
                  &&  co_files 
                  && strlen(co_files[j])) {
            strcat(str,co_files[j]);
            }
         else if (   !strcmp(attributes[i],P_CI_FILE)
                  &&  ci_files
                  &&  strlen(ci_files[j])) {
            strcat(str,ci_files[j]);
            }
         else if (   !strcmp(attributes[i],P_CI_SA)
                  &&  cisas
                  &&  strlen(cisas[j])) {
            strcat(str,cisas[j]);
            }
         else if (   !strcmp(attributes[i],P_FILE_TYPE)
                  &&  file_types
                  &&  strlen(file_types[j])) {
            strcat(str,file_types[j]);
            }
         else if (   !strcmp(attributes[i],P_CO_COMM)
                  &&  co_comms
                  &&  strlen(co_comms[j])) {
            strcat(str,co_comms[j]);
            }
         else if (value[i][0]) {
            strcat(str, value[i]);
            }
         strcat(str, "\1");
         }

      status = MEMwrite(data_list, str);
      if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMwrite")) {
         goto end;
         }

      if ( DSdebug > 4 ) {
         MEMprint_buffer("DATA LIST after MEMwrite data", data_list,  NULL);
         }
      
      status = MEMbuild_array(data_list);
      if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array")) {
         goto end;
         }
      attributes = (char **) data_list->column_ptr;
      value = (char **) data_list->data_ptr;
      }

   /* check for "'" in data list */
   if (data_list) NFMRtic_it(data_list);

    /**************************************
    * Do the actual checkin of the item. *
    **************************************/
   if (strcmp(checkin_type,CHECKIN_ITEM) == 0) {
      NFM2_debug_message("Calling NFMRcomplete_item_checkin");
      status = NFMRcomplete_item_checkin(DSUSERID,storage_area,temporary_node
                           ,temporary_user,temporary_password,temporary_path
                           ,attr_list,data_list);
      NFM2_check_status(status,NFM_SUCCESS,"NFMRcomplete_item_checkin");
      tried_checkin = 1;
      }
   else {
      NFM2_debug_message("Calling NFMRcomplete_set_checkin");
      status = NFMRcomplete_set_checkin(DSUSERID,storage_area,temporary_node
                           ,temporary_user,temporary_password,temporary_path
                           ,attr_list,data_list);
      NFM2_check_status(status,NFM_SUCCESS,"NFMRcomplete_set_checkin");
      tried_checkin = 1;
      }
   NFM2_format_debug_message("Status After NFMRcomplete_item/set_checkin %D"
                             ,status);
end:

   /*********************************
    * Tell NFM how everything went. *
    *********************************/

   if (status == 9999) {
      /* attempted to checkin less files that were currently in buffer */
/* 
this call requires the NFI .h file to be uncommented.
      ERRload_struct(NFI,NFI_W_FORM_CANCELED,NULL,NULL);
*/
      NFMRcancel_item_checkin ( DSUSERID, attr_list, data_list );
      }
   else if ( !tried_checkin && status != NFM_S_SUCCESS) {
      if (strcmp(checkin_type,CHECKIN_ITEM) == 0) {
         NFM2_debug_message("Calling NFMRcancel_item_checkin");
         status = NFMRcancel_item_checkin ( DSUSERID, attr_list, data_list );
         }
      else {
         NFM2_debug_message("Calling NFMRcancel_set_checkin");
         status = NFMRcancel_set_checkin ( DSUSERID, attr_list, data_list );
         }
      }
   else if (status == NFM_S_SUCCESS) {
      status = 0;
      }
   NFM2_set_to_state ( );
   NFM2_format_debug_message("Exiting NFMb_checkin_mult_item - status = %D"
                             , status );
   return(status);
}


/******************************************************************************

Doc:    NFMa_flag_item_delete

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This routine flags an item's files for deletion.
        To actually delete the files you must run their delete utility.

Examples:
          status = NFMa_flag_item_delete(catalog_name,
                                         item_name,
                                         item_revision);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFMa_flag_item_delete (catalog_name,item_name,item_revision)
   char *catalog_name;   /* I - NFM catalog name */
   char *item_name;      /* I - Item name to flag for deletion */
   char *item_revision;  /* I - Item revision to flag for deletion */
{

/* Local declarations */
long  status;          /* Return status */

   NFM2_clear_messages("NFMa_flag_item_delete");

    /****************************************
    * See if the user has the authority to *
    * to flag an item for deletion         *
    ****************************************/

   status = NFMRvalidate_user_access(DSUSERID,FLAG_ITEM_DELETE,"",""
                                    ,catalog_name,item_name,item_revision);
   if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access"))
      goto end;

    /**************************************
    * Do the actual flag for deletion of the item. *
    **************************************/
    NFM2_debug_message("Calling NFMRflag_item_delete");
    status = NFMRflag_item_delete(DSUSERID,catalog_name,item_name
                                 ,item_revision);
    NFM2_check_status(status,NFM_SUCCESS,"NFMRflag_item_delete");

    NFM2_format_debug_message("Status After NFMRflag_item_delete %D",status);

end:

   /*********************************
    * Tell NFM how everything went. *
    *********************************/

   if (status == NFM_S_SUCCESS)
      status = 0;
   NFM2_set_to_state ( );
   NFM2_format_debug_message("Exiting NFMa_flag_item_delete - status = %D"
                             , status );
   return(status);
}


/******************************************************************************

Doc:    NFMa_delete_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This routine deletes an item from the database.  To be deleted, the
           item must have no files associated with it.

Examples:
          status = NFMa_delete_item(catalog_name,
                                    item_name,
                                    item_revision);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFMa_delete_item (catalog_name,item_name,item_revision)
   char *catalog_name;    /* I - NFM catalog name */
   char *item_name;       /* I - item to delete */
   char *item_revision;   /* I - item revision to delete */
{

/* Local declarations */
long  status;          /* Return status */

   NFM2_clear_messages("NFMa_delete_item");

    /****************************************
    * See if the user has the authority to  *
    * to delete an item                     *
    ****************************************/

   status = NFMRvalidate_user_access(DSUSERID,DELETE_ITEM,"","",catalog_name
                                    ,item_name,item_revision);
   if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access"))
      goto end;

    /**************************************
    * Do the actual deletion of the item. *
    **************************************/
    NFM2_debug_message("Calling NFMRdelete_item");
    status = NFMRdelete_item(DSUSERID,catalog_name,item_name,item_revision);
    NFM2_check_status(status,NFM_SUCCESS,"NFMRdelete_item");

    NFM2_format_debug_message("Status After NFMRdelete_item %D",status);

end:

   /*********************************
    * Tell NFM how everything went. *
    *********************************/

   if (status == NFM_S_SUCCESS)
      status = 0;
   NFM2_set_to_state ( );
   NFM2_format_debug_message("Exiting NFMa_delete_item - status = %D"
                             , status );
   return(status);
}


/******************************************************************************

Doc:    NFMa_add_project_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This routine adds an item to a project.

Examples:
          status = NFMa_add_project_item(project_name,
                                        item_catalog,
                                        item_name,
                                        item_revision,
                                        type);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFMa_add_project_item (project_name,item_catalog,item_name,item_revision
                          ,type)
   char *project_name;   /* I - name of the project to add to */
   char *item_catalog;   /* I - NFM catalog that item is in */
   char *item_name;      /* I - name of the item to add */
   char *item_revision;  /* I - revision of the item to add */
   char *type;           /* I - project type: 'O'=owened 'R'=referenced */
{ /* Begin program */

char  **attributes;    /* Attribute list */
char  buffstr [1024];   /* data buffer size */

long  i;               /* Counter */
long  num_attrs=0;     /* Number of attributes */
long  status;          /* Return status */


   NFM2_clear_messages("NFMa_add_project_item");
   NFM2_debug_message("Entering DSadd_project_item");


	/****************************************
    * See if the user has the authority to *
    * update a project.                        *
    ****************************************/

   status = NFMRvalidate_user_access(DSUSERID,DEFINE_PROJECT_MEMBERS,""
                                    ,project_name,"","","");

   if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access"))
      goto end;

	/********************************************
    * Query the project members to get the buffers *
    * set up the  way they need to be.         *
    ********************************************/

   status = NFMRquery_project_members(DSUSERID,project_name,&attr_list
                                     ,&data_list );

   if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_project_members")) 
      goto end;

   if ( DSdebug > 4 ) {
      MEMprint_buffer("ATTRIBUTE LIST ", attr_list,  NULL);
      MEMprint_buffer("DATA LIST", data_list,  NULL);
      }

	/*************************************************
    * Build a data buffer row placing the item info * 
    * in the corresponding columns.                 *
    ************************************************/

   attributes = (char **) data_list->column_ptr;
   num_attrs = data_list->columns;

   buffstr[0] = 0;
   for ( i = 0 ; i < num_attrs ; ++i ) {
      if (!strcmp(attributes[i],P_CATALOG)) 
         strcat(buffstr,item_catalog);

      else if ( !strcmp ( attributes[i],P_PROJECT) ) 
         strcat(buffstr,project_name);

      else if ( !strcmp ( attributes[i],P_STATUS) ) 
         strcat(buffstr,"ADD");

      else if ( !strcmp ( attributes[i],P_ITEM_NAME) ) 
         strcat(buffstr,item_name);

      else if ( !strcmp ( attributes[i],P_ITEM_REV) ) 
         strcat(buffstr,item_revision);

      else if ( !strcmp ( attributes[i],P_TYPE) ) 
         strcat(buffstr,type);

      strcat(buffstr,"\1");
      }

   status = MEMwrite(data_list,buffstr);
   if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite")) {
      goto end;
      }

   if ( DSdebug > 4 )
      MEMprint_buffer("DATA LIST after MEMwrite data", data_list,  NULL);


	/**************************************
    * Do the actual add item to the project. *
    **************************************/

   status = NFMRupdate_project_members ( DSUSERID, attr_list, data_list );

   if (status==NFM2_check_status(status,NFM_SUCCESS,"NFMRupdate_project_members"))
      status=0;

end:

	/*********************************
    * Tell NFM how everything went. *
    *********************************/

   NFM2_set_to_state();
   NFM2_format_debug_message("Exiting DSadd_project_item - status = %d\n",status);
   return ( status );
}


/******************************************************************************

Doc:    NFMa_add_item_set

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This function adds an item to a set.

Examples:
          status = NFMa_add_set_item(set_catalog,
                                     set_name,
                                     set_revision,
                                     item_catalog,
                                     item_name,
                                     item_revision,
                                     item_type);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFMa_add_set_item (catalog_name,set_name,set_revision,item_catalog,
                       item_name,item_revision,item_type)
   char *catalog_name;  /* I - NFM catalog that the set is in */
   char *set_name;      /* I - name of the set */
   char *set_revision;  /* I - revision of the set */
   char *item_catalog;  /* I - NFM catalog the item is in */
   char *item_name;     /* I - name of the item to add to the set */
   char *item_revision; /* I - revision of the item to add to the set */
   char *item_type;     /* I - set type: 'P'=primary or 'S'=secondary */
{ /* Begin program */

char  **attributes;    /* Attribute list */
char  buffstr [1024];   /* data buffer size */

long  i;               /* Counter */
long  num_attrs=0;     /* Number of attributes */
long  status;          /* Return status */


   NFM2_clear_messages("NFMa_add_set_item");
   NFM2_debug_message("Entering DSadd_set_item");


	/****************************************
    * See if the user has the authority to *
    * update a set.                        *
    ****************************************/

   status = NFMRvalidate_user_access(DSUSERID,DEFINE_SET_MEMBERS,"",""
                                    ,catalog_name,set_name,set_revision);

   if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access"))
      goto end;

	/********************************************
    * Query the set members to get the buffers *
    * set up the  way they need to be.         *
    ********************************************/

   status = NFMRquery_set_members(DSUSERID,catalog_name,set_name,set_revision
                                 ,1,0,&attr_list,&data_list );

   if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRquery_set_members")) 
      goto end;

   if ( DSdebug > 4 ) {
      MEMprint_buffer("ATTRIBUTE LIST ", attr_list,  NULL);
      MEMprint_buffer("DATA LIST", data_list,  NULL);
      }

	/*************************************************
    * Build a data buffer row placing the item info * 
    * in the corresponding columns.                 *
    ************************************************/

   attributes = (char **) data_list->column_ptr;
   num_attrs = data_list->columns;

   buffstr[0] = '\0';
   for ( i = 0 ; i < num_attrs ; ++i ) {
      if (!strcmp(attributes[i],P_CATALOG)) 
         strcat(buffstr,item_catalog);

      else if ( !strcmp ( attributes[i],P_ITEM_NAME) ) 
         strcat(buffstr,item_name);

      else if ( !strcmp (attributes[i],P_ITEM_REV)) 
         strcat(buffstr,item_revision);

      else if ( !strcmp ( attributes[i],P_TYPE) ) 
         strcat(buffstr,item_type);

      strcat(buffstr,"\1");
      }

   status = MEMwrite(data_list,buffstr);
   if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite")) {
      goto end;
      }

   if ( DSdebug > 4 )
      MEMprint_buffer("DATA LIST after MEMwrite data", data_list,  NULL);


	/**************************************
    * Do the actual add item to the set. *
    **************************************/

   status = NFMRupdate_set_members ( DSUSERID, attr_list, data_list );


   if (status==NFM2_check_status(status,NFM_SUCCESS,"NFMRupdate_set_members"))
      status=0;

end:

	/*********************************
    * Tell NFM how everything went. *
    *********************************/

   NFM2_set_to_state();
   NFM2_format_debug_message("Exiting DSadd_set_item - status = %d\n",status);
   return ( status );
}


/******************************************************************************

Doc:    NFMa_update_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
          This function will update attributes of an item.
          If force is 0, this function honors NFM protections.

Examples:
          status = NFMa_update_item(catalog_name,
                                    item_name,
                                    item_revision,
                                    attributes,
                                    values,
                                    num_of_attributes
                                    force);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long NFMa_update_item (catalog_name,item_name,item_revision,attrs,values
                       ,num,force)
   char  *catalog_name;    /* I - NFM catalog name */
   char  *item_name;       /* I - name of the item to modify */
   char  *item_revision;   /* I - revision of the item to modify */
   char **attrs;           /* I - list of attributes to modify */
   char **values;          /* I - list of values for the attributes */
   int    num;             /* I - number of attributes to modify */
   int    force;           /* I - if     0 :update only if NFM allows.
                                     non-0 :force the attribute to change */
{

/* Local declarations */
char   **attributes;    /* Attribute list */
char   **nfm_attr;      /* Attribute list */
char   **value;
int   tried_update=0;
int   force_ind=0;
long  i,j;               /* Counter */
long  num_attrs;       /* Number of attributes */
long  num_rows;        /* Number of rows */
long  status;          /* Return status */

   NFM2_clear_messages("NFMa_update_item");
   NFM2_format_debug_message("catalog_name, item_name, item_revision");
   NFM2_format_debug_message("<%s> <%s> <%s>",catalog_name,item_name
                                             ,item_revision);

    /****************************************
    * See if the user has the authority to *
    * update an item.                      *
    ****************************************/

   status = NFMRvalidate_user_access(DSUSERID,CHANGE_ITEM,"","",catalog_name
                                    ,item_name,item_revision);
   if (status!=NFM2_check_status(status,NFM_SUCCESS,"NFMRvalidate_user_access"))
      goto end;

    /*********************************
    * Prepare the item for update. *
    *********************************/
   status = NFMRprepare_update_item(DSUSERID,catalog_name,item_name
                             ,item_revision,&attr_list,&data_list,&value_list);

   NFM2_format_debug_message("Status After NFMRprepare_update_item %D"
                            ,status);
   if (status!=NFM2_check_status(status,NFM_SUCCESS
                                ,"NFMRprepare_update_item")) 
      goto end;
   if ( DSdebug > 4 ) {
     MEMprint_buffer("ATTRIBUTE LIST ",attr_list,NULL);
     MEMprint_buffer("DATA LIST", data_list,  NULL);
     MEMprint_buffer("VALUE LIST", value_list,  NULL);
     }

    /**********************************************
    * Fill in the data buffer with the necessary *
    * update item information.                   *
    **********************************************/

   attributes = (char **) data_list->column_ptr;
   value = (char **) data_list->data_ptr;

   if (force) {
      nfm_attr = (char **) attr_list->column_ptr;
      num_attrs = attr_list->columns;
      for (force_ind=0;   force_ind<num_attrs
                       && strcmp(nfm_attr[force_ind],P_UPDATE);force_ind++);
      if (force_ind >= num_attrs)
         force = 0;
      force_ind++;
      }

   num_rows = data_list->rows;
   num_attrs = data_list->columns;

   if ( DSdebug > 3 ) { 
      for (i = 0; i < num_attrs; ++i) { 
         NFM2_format_debug_message("attribute[%d] = %s\tvalue[%d] = %s",i
                                   ,attributes[i],i,value[i]);
         }
      }

   for ( i = 0; i < num_attrs; ++i ) {
      for (j=0;j<num;j++) 
         if (!strcmp(attributes[i],attrs[j])) {
            status = MEMwrite_data(data_list,values[j],1,i+1);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               goto end;
            if (force)
               status = MEMwrite_data(attr_list,"Y",i+1,force_ind);
            if (status!=NFM2_check_status(status,MEM_SUCCESS,"MEMwrite_data"))
               goto end;
            }
      }

   /* check for "'" in data list */
   if (data_list) NFMRtic_it(data_list);

    /**************************************
    * Do the actual update of the item. *
    **************************************/

   NFM2_debug_message("Calling NFMRupdate_item");

   status = NFMRupdate_item(DSUSERID,catalog_name,attr_list,data_list);
   NFM2_check_status(status,NFM_SUCCESS,"NFMRupdate_item");
   tried_update = 1;

   NFM2_format_debug_message("Status After NFMRupdate_item %D"
                             ,status);
end:

   /*********************************
    * Tell NFM how everything went. *
    *********************************/

   if ( !tried_update && status != NFM_S_SUCCESS) {
      NFM2_debug_message("Calling NFMRcancel_update_item");
      status = NFMRcancel_update_item ( DSUSERID, attr_list, data_list );
      }
   else if (status == NFM_S_SUCCESS) {
      status = 0;
      }
   NFM2_set_to_state ( );
   NFM2_format_debug_message("Exiting NFMa_update_item - status = %D"
                             , status );
   return(status);
}


/******************************************************************************

Doc:    NFMa_find_cifilename

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFMa_stuff.c

Author: Rob Whitesell

Date:   09-SEPTEMBER-1991

Description:
        This function returns checkin filename that NFM selected for a file
           that has been checked in.
        If an error occured the text from RIS will be put in the error_m 
           parameter.  Space for it is allocated by RIS.


Examples:
          status = NFMa_find_cifilename(catalog_name,
                                        item_number,
                                        co_filename,
                                        ci_filename,
                                        &error_m);

Return Status:
         0         - success
         any error status returned by SS_sql() on failure.

History:

******************************************************************************/
/*ARGSUSED*/
long NFMa_find_cifilename (cat_name,item_no,co_file,ci_file,error_m)
   char  *cat_name; /* I - name of the catalog */
   long   item_no;  /* I - the item number of the item where the file exists */
   char  *co_file;  /* I - the name of the check out file */
   char  *ci_file;  /* O - address of a place to put the ci_filename */
   char **error_m;  /* O - address of a char ptr to allocate to hold errors */
{
char  sql_line[500];
long buff_size, max_rows;
char data_buff[2000],tmp[50];
long cat_no, file_no;
long  i,status;
long rows_cols,rows,cols;
long *src;
short *size;
char *data;

   sprintf(sql_line,"select n_catalogno,n_fileno from nfmcatalogs,f_%s where n_catalogname='%s' and n_itemnum=%d and n_cofilename='%s' and n_fileversion=any (select max(n_fileversion) from f_%s where n_itemnum=%d and n_cofilename='%s')"
                   ,cat_name,cat_name,item_no,NFMa_ticked(co_file),cat_name
                   ,item_no,NFMa_ticked(co_file));

   max_rows = 10;
   buff_size= 2000;

   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);
   if (status) {
      return(status);
      }
   else {
      src = (long *)data_buff;
      status = (*src++);
      rows_cols = (*src++);
      cols = (*src++);
      rows = rows_cols/cols;
      size = (short *)src;
      data = (char *)((long)size+((rows_cols + cols)*sizeof(short)));
      if (status)
         return(status);
      if (rows == 0) 
         return(0);
      /* move data pointer past column names */
      for (i=1;i<=cols;i++) {
         data += (*size+1);
         size++;
         }
      strcpy(tmp,data);
      cat_no=atol(tmp);
      data += (*size +1); size++;
      strcpy(tmp,data);
      file_no=atol(tmp);
      }

   NFMget_file_name(DSUSERID,cat_no,file_no,ci_file);
   return(0);
} /* end NFMa_find_cifilename */


/******************************************************************************

Doc:    NFMa_storage_area_names

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFMa_stuff.c

Author: Rob Whitesell

Date:   09-SEPTEMBER-1991

Description:
        This function returns the storage area name associated with a certain
           number, or vice-versa.
        If you want the number, pass in a -1 for storage area number, and give
           a name.
        If you want the name, pass in a valid number.

Examples:
          status = NFMa_storage_area_names(sa_name,sa_number);

Return Status:
         0         - success
         any error status returned by SS_sql() on failure.

History:

******************************************************************************/

long NFMa_storage_area_names (sa_name,sa_no)
   char  *sa_name;  /* I/O the storage area name */
   long  *sa_no;    /* I/O - the storage area number to look for. */
{
char  sql_line[200];
char  value[100];
long  status;
char  *error_m;
int  i,count,slot;
static char **names;
static int    found=0;

   if (*sa_no>=0)
      sa_name[0]=0;
      
   if (!found || *sa_no>=found) {
      sprintf(sql_line,"select max(n_sano) from nfmstoragearea");
      status=NFMa_single_select(sql_line,value,&error_m);
      if (status) return (status);
      count=atoi(value)+2;
      if (count>found) {
         if (found)
            names=(char **) realloc(names,count*sizeof(char **));
         else
            names=(char **) malloc(count*sizeof(char **));
         if (!names) return(1);
         for (i=found;i<count;i++) {
            names[i]=(char *)malloc(50*sizeof(char *));
            if (!names[i]) return (1);
            names[i][0]=0;
            }
         found=count;
         }  
      sprintf(sql_line,"select n_saname,n_sano from nfmstoragearea");
      status=NFMa_multi_select(sql_line,count*60+100,NULL,NULL,0,value,&error_m);
      if (status) return (status);
      for (i=1;i<=count;i++) {
          status=NFMa_multi_select(NULL,1,NULL,"n_sano",i,value,&error_m);
          if (status<0) break;
          slot=atoi(value);
          NFMa_multi_select(NULL,1,NULL,"n_saname",i,value,&error_m);
          strcpy(names[slot],value);
          }
      }

   if (*sa_no<0) {
      for (i=0;i<found;i++)
         if (!strcmp(names[i],sa_name)) {
            *sa_no=i;
            return(0);
            }
      /* not found */
      sprintf(sql_line,"select n_sano from nfmstoragearea where n_saname='%s'"
             ,sa_name);
      status=NFMa_single_select(sql_line,value,&error_m);
      if (status) return(status);
      if (value[0]) {
         *sa_no=atoi(value);
         if (*sa_no<found) strcpy(names[*sa_no],sa_name);
         return(0);
         }
      else
         return(1);
      }
   else {
      if (names[*sa_no][0]) {
         strcpy(sa_name,names[*sa_no]);
         return(0);
         }
      /* not found */
      sprintf(sql_line,"select n_saname from nfmstoragearea where n_sano=%d"
             ,*sa_no);
      status=NFMa_single_select(sql_line,value,&error_m);
      if (status) return(status);
      if (value[0]) {
         strcpy(names[*sa_no],value);
         strcpy(sa_name,names[*sa_no]);
         return(0);
         }
      else
         return(1);
      }
} /* end NFMa_sa_information */




/******************************************************************************

Doc:    NFMa_sa_information

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFMa_stuff.c

Author: Rob Whitesell

Date:   09-SEPTEMBER-1991

Description:
        This function returns the node, path, and login associated with a
           storage area number.
        If an error occured the text from RIS will be put in the error_m 
           parameter.  Space for it is allocated by RIS.


Examples:
          status = NFMa_sa_information(sa_number,
                                       node_name,
                                       path,
                                       user_name,
                                       password,
                                       &error_m);

Return Status:
         0         - success
         any error status returned by SS_sql() on failure.

History:

******************************************************************************/

long NFMa_sa_information (sa_no,node,path,user,passwd,error_m)
   long   sa_no;    /* I - the storage area number to look for. */
   char  *node;     /* O - address of a place to put the node name */
   char  *path;     /* O - address of a place to put the path */
   char  *user;     /* O - address of a place to put the user name */
   char  *passwd;   /* O - address of a place to put the password */
   char **error_m;  /* O - address of a char ptr to allocate to hold errors */
{
char  sql_line[200];
long buff_size, max_rows;
char data_buff[2000],tmppass[50];
int  i,status;
long rows_cols,rows,cols;
long *src;
short *size;
char *data;
long deep_status;

   strcpy(node,"");
   strcpy(path,"");
   strcpy(user,"");
   strcpy(passwd,"");

   sprintf(sql_line,"select n_nodename,n_pathname,n_username,n_passwd from nfmstoragearea,nfmnodes where n_sano=%d and nfmstoragearea.n_nodeno=nfmnodes.n_nodeno"
                   ,sa_no);

   max_rows = 10;
   buff_size= 2000;

   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);
   if (status) {
		ERRget_specific_number(SQL,&deep_status);
      if (status==SQL_I_NO_ROWS_FOUND || deep_status==SQL_I_NO_ROWS_FOUND)
         return(0);
      else
         return(status);
      }
   else {
      src = (long *)data_buff;
      status = (*src++);
      rows_cols = (*src++);
      cols = (*src++);
      rows = rows_cols/cols;
      size = (short *)src;
      data = (char *)((long)size+((rows_cols + cols)*sizeof(short)));
      if (status)
         return(status);
      if (rows == 0) 
         return(0);
      /* move data pointer past column names */
      for (i=1;i<=cols;i++) {
         data += (*size+1);
         size++;
         }
      strcpy(node,data);
      data += (*size +1); size++;
      strcpy(path,data);
      data += (*size +1); size++;
      strcpy(user,data);
      data += (*size +1); size++;
      strcpy(tmppass,data);
      }

   NFMdecrypt(tmppass,passwd);
   return(0);
} /* end NFMa_sa_information */


/******************************************************************************

Doc:    NFMa_create_d_

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This function creates a DMANDS d_ catalog for an NFM catalog.

Examples:
          status = NFMa_create_d_(d_catalog_name,
                                  &error_m);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFMa_create_d_ (table_name,error_m)
   char *table_name;  /* I - name of the d_table */
   char **error_m;    /* O - text error message if one occurred. */
{
char sql_line[1024];
long buff_size, max_rows;
char data_buff[200];
int   status;

   sprintf(sql_line,"create table %s (%s integer,%s integer,%s integer,%s integer,%s integer,%s integer,%s char(80))"
          ,table_name,D_ITEM_NO,D_FILE_VER,D_FILE_NO,D_MULT_PAGE,D_REDUCED
          ,D_MIRROR,D_DESC);

   max_rows = 10;
   buff_size= 200;

   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);

   return(status);
} /* end NFMa_create_d_ */


/******************************************************************************

Doc:    NFMa_create_ref_doc

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This function creates the DMANDS ref_doc table.

Examples:
          status = NFMa_create_ref_doc(&error_m);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFMa_create_ref_doc (error_m)
   char **error_m; /* O - text error message if one occurred */
{
char sql_line[1024];
long buff_size, max_rows;
char data_buff[200];
int   status;

   sprintf(sql_line,"create table ref_doc (cat_name char(20), item_name char(54), item_rev char(54), ref_doc_name char(54), ref_doc_rev char(54))");

   max_rows = 10;
   buff_size= 200;

   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);

   return(status);
} /* end NFMa_create_ref_doc */


/******************************************************************************

Doc:    NFMa_create_table

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This function creates a ris table.
        Column names and types are specified in 'buffer' parameter.

Examples:
          status = NFMa_create_table(name,
                                     buffer,
                                     num_of_attrs,
                                     size,
                                     &error_m);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
/* works with a buffer that is exactly the same as the buffer for  */
/* NFM2_create_catalog                                             */
int NFMa_create_table (name,buffer,attrs,size,error_m)
   char  *name;    /* I - name of the table to create */
   char  *buffer;  /* I - column information buffer. Format:
                                  col_name \n type \n synonym 
                          synonym is ignored */
   int    attrs;   /* I - number of attributes in the buffer */
   long   size;    /* I - size of the buffer (# of chars) */
   char **error_m; /* O - RIS error text if any occured. */
{
char *sql_line,*spot,*start;
long buff_size, max_rows;
char data_buff[200];
int  i,status;

   sql_line = (char *) malloc((size+300)*sizeof(char));
   if (!sql_line)
      return(1);

   sprintf(sql_line,"create table %s (",name);
   start = buffer;
   for (i=0;i<attrs;i++) {
      /* get column name */
      if ( !(spot = strchr(start,'\n'))) {
         free(sql_line);
         return(1);
         }
      *spot=0;
      strcat(sql_line,start);
      strcat(sql_line," ");
      
      /* get type */
      start = spot+1;
      if ( !(spot = strchr(start,'\n'))) {
         free(sql_line);
         return(1);
         }
      *spot=0;
      strcat(sql_line,start);

      if (i<(attrs-1)) {
         /* skip over synonym */
         strcat(sql_line,",");
         start = spot+1;
         if ( !(spot = strchr(start,'\n'))) {
            free(sql_line);
            return(1);
            }
         *spot=0;
         start = spot+1;
         }
      }

   strcat(sql_line,")");

   max_rows = 10;
   buff_size= 200;

   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);

   free(sql_line);
   return(status);
} /* end NFMa_create_table */


/******************************************************************************

Doc:    NFMa_make_index

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This function will create an index on a RIS table.
        It expects the 'columns' parameter in the form: col1,col2,col3,...
        It will index however many columns you want to.

Examples:
          status = NFMa_make_index(ind_name,
                                   catalog,
                                   columns,
                                   &error_m);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFMa_make_index (ind_name,catalog,columns,error_m)
   char  *ind_name; /* I - name for the index */
   char  *catalog;  /* I - name of the table to be indexed */
   char  *columns;  /* I - column names to index */
   char **error_m;  /* O - RIS error if one occurred. */
{
char sql_line[1024];
long buff_size, max_rows;
char data_buff[200];
int   status;

   sprintf(sql_line,"create index %s on %s (%s)",ind_name,catalog,columns);

   max_rows = 10;
   buff_size= 200;

   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);

   return(status);
} /* end NFMa_make_index */


/******************************************************************************

Doc:    NFMa_single_select

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: NFMa_stuff.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function executes a given line of SQL.
        It was originally intended for this funtion to perform selects that
           were sure to return only one value.  It can also be used to do
           inserts, updates, etc.
        It returns a single value (first column, first row) in the parameter
           'value'.  Space to hold this value must be allocated by calling
           function.
        It returns the RIS provided error message in 'error_m'

Examples:
          NFMa_single_select(sql_line,
                        value,
                        &error_m_char_ptr);

Return Status:
          0    - success
          any error status returned by SS_sql() on a failure.

History:
     09/03/91  wrw  -added standard header
     09/20/91  wrw  -cleaned up the processing of non-select statements.
     09/23/91  wrw  -moved to NFMa_stuff.c and renamed.

******************************************************************************/

long NFMa_single_select (sql_line,value,error_m)
char *sql_line;      /* I - char ptr to a line of SQL to submit */
char *value;         /* O - char ptr to a place to store the value returned */
char **error_m;      /* O - address of char ptr to allocate to store error
                              messages from RIS.  Space allocated by RIS */
{
long    k;
long   buff_size, max_rows;
char   data_buff[3072];
long    status;
long   rows_cols, rows, cols;
long  *src;
short *size;
char  *data;
long  deep_status;

   value[0]=0;

   buff_size=3072;
   max_rows=5;
   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);

   /* check if the sql was not a select */
   if (strncmp(sql_line,"select",6)) {
      if (status)
         return(status);
      else
         return(0);
      }

   if (status) {
		ERRget_specific_number(SQL,&deep_status);
      if (status==SQL_I_NO_ROWS_FOUND || deep_status==SQL_I_NO_ROWS_FOUND)
         return(0);
      return(status);
      }
   else {
      src = (long *)data_buff;
      status = (*src++);
      rows_cols = (*src++);
      cols = (*src++);
      rows = rows_cols/cols;
      size = (short *)src;
      data = (char *)((long)size+((rows_cols + cols)*sizeof(short)));
      if (status || rows == 0) {
         if (status)
            return(status);
         else
            return(0);
         }
      else {
         /* move data pointer past column names */
         for (k=1;k<=cols;k++) {
            data += (*size+1);
            size++;
            }
         strcpy(value,data);
         }
      }
   return(0);
} /* end single_select () */


/******************************************************************************

Doc:    NFMa_multi_select

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: NFMa_stuff.c

Author: Rob Whitesell

Date:   21-JANUARY-1992

Description:
        This function executes a given select statement.
        It returns the value for the row of the column name asked for.  You 
           may continue to return data from the same select by putting a null
           in the sql_statement field.
        If column_name is NULL or row==0, statement is executed, but no data
           is returned.  (Data is available for future calls)

Examples:
        NFMa_multi_select(sql_line,
                          buffer_size,
                          my_buffer,
                          column_name,
                          row,
                          value,
                          &error_m);

Return Status:
         -1    - row requested is greater than max returned.
          0    - success
          any error status returned by SS_sql() on a failure.

History:

******************************************************************************/

long NFMa_multi_select (sql_line,return_size,their_buff,column_name,row,value
                       ,error_m)
char *sql_line;      /* I - char ptr to a line of SQL to submit
                          - NULL if returning a value from previous SQL */
int   return_size;   /* I - max character length of data returned for SQL
                          - 0 if working with a previous SQL */
char *their_buff;    /* I/O - buffer to use if default is not desired.
                              send in NULL for default. */
char *column_name;   /* I - name of column to return in value field */
int   row;           /* I - row of data (of above column) to return */
char *value;         /* O - char ptr to a place to store the value returned */
char **error_m;      /* O - address of char ptr to allocate to store error
                              messages from RIS.  Space allocated by RIS */
{
static long  alloc_size=0;
static char *data_buff=NULL;
static long  status=1;
long    buff_size=0;
long    k,approx;
long    max_rows;
long   rows_cols, rows, cols,column;
long   deep_status;
long  *src;
short *size;
char  *data;

   value[0]=0;

   if (sql_line) {
      approx=(long) ((float)return_size * 1.2);
      if (!their_buff) {
         if (approx>alloc_size) {
            if (data_buff)
               data_buff=(char *) realloc(data_buff,return_size*sizeof(char));
            else
               data_buff=(char *) malloc(return_size*sizeof(char));
            alloc_size=buff_size=approx;
            }
         }
     
      max_rows=100000;
      if (!their_buff)
         status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);
      else
         status = SS_sql(their_buff,sql_line,&buff_size,max_rows,error_m);
      }

   if (status) {
		ERRget_specific_number(SQL,&deep_status);
      if (status==SQL_I_NO_ROWS_FOUND || deep_status==SQL_I_NO_ROWS_FOUND) {
         if (row) return(-1);
         else return(0);
         }
      return(status);
      }
   else if ((!data_buff && !their_buff) || !column_name || !row) {
      return(0);
      }
   else {
      if (!their_buff)
         src = (long *)data_buff;
      else
         src = (long *)their_buff;
      status = (*src++);
      rows_cols = (*src++);
      cols = (*src++);
      rows = rows_cols/cols;
      size = (short *)src;
      data = (char *)((long)size+((rows_cols + cols)*sizeof(short)));
      if (status)
         return(status);
      else if (row>rows) 
         return(-1);
      else {
         /* move data pointer past column names */
         column=0;
         for (k=0;k<cols;k++) {
            if (!strcmp(data,column_name))
               column=k;
            data += (*size+1);
            size++;
            }
         for (k=0;k<((row-1)*cols)+column;k++) {
            data += (*size+1);
            size++;
            }
         strcpy(value,data);
         }
      }
   return(0);
} /* end NFMa_multi_select () */


/******************************************************************************

Doc:    NFMa_write_d_

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   Spring 1991

Description:
        This function writes the correct information to the DMANDS d_ table
           after a checkin has been performed.

Examples:
          status = NFMa_write_d_(catalog_name,
                                 item_name,
                                 item_revision,
                                 co_file,
                                 multi_page,
                                 mirror_archive,
                                 reduced_exists,
                                 file_description,
                                 &error_m);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
int NFMa_write_d_ (catalog,item_name,item_rev,co_file,mult_page,mirror,reduced
                  ,desc,error_m)
   char *catalog;    /* I - catalog that the item is in */
   char *item_name;  /* I - name of the item */
   char *item_rev;   /* I - revision of the item */
   char *co_file;    /* I - name of the file */
   int   mult_page;  /* I - number of pages in the file */
   int   mirror;     /* I - mirror archive node (if it exists, 0 else) */
   int   reduced;    /* I - file number of reduced resolution file,
                                      0 if none exists */
   char *desc;       /* I - description of the detail file */
   char **error_m;   /* O - RIS error message if on is returned */
{
char sql_line[1024];
long buff_size, max_rows;
char data_buff[200];
int   status;
char work[MAX_ASCII_LINE_LEN];

   sprintf(sql_line
          ,"select n_itemno from %s where n_itemname='%s' and n_itemrev='%s'"
          ,catalog,NFMa_ticked(item_name),NFMa_ticked(item_rev));
   status=NFMa_single_select(sql_line,work,error_m);
   if (status)
      return(status);

  sprintf(sql_line,"insert into d_%s (item_no,file_no,file_version,multi_page_no,mirror_archive,reduced_exist,description) select %s ,n_fileno,n_fileversion, %d, %d, %d, '%s' from f_%s where n_itemnum=%s and n_cofilename='%s' and n_fileversion=any (select max(n_fileversion) from f_%s where n_itemnum=%s and n_cofilename='%s')"
                 ,catalog,work,mult_page,mirror,reduced
						,NFMa_ticked(((desc)?desc:""))
						,catalog
                 ,work,NFMa_ticked(co_file),catalog,work,NFMa_ticked(co_file));
 
   max_rows = 10;
   buff_size= 200;

   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);

   return(status);
} /* end NFMa_write_d_ */


/*------------------------ Jim's stuff -------------------------------------*/
long jwa_dbg=0;
FILE *jwa_dbg_ptr=NULL;

/******************************************************************************

Doc: MDSget_index

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: MDSget_index.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number:

Description: This routine fills the NDXstruct with the indexes to the
             formats of the catalog attributes

Examples: MDSget_index( format, number, attr_index)

Return Status: None

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header

******************************************************************************/

extern FILE *jwa_dbg_ptr;
extern long   jwa_dbg;

NFM2fill_index( attr_list, number, attr_index)

MEMptr attr_list; /* I - array of column formats */
int number;   /* I - number of columns */
CATptr *attr_index; /* O - MDSstruct to fill */

{
  long i;
  char **format;
 
  format = (char **) attr_list->column_ptr;
  for (i=0;i<number;i++)
    if (jwa_dbg) fprintf(jwa_dbg_ptr,"format[%d]=%s.\n", i, format[i]);

  for (i=0;i<number;i++)
  {
    if (strcmp(format[i], "n_name")==0)
    {
      attr_index->name=i;
    }
    else
    if (strcmp(format[i], "n_datatype")==0)
    {
      attr_index->dt=i;
    }
    else
      if (strcmp(format[i], "n_synonym")==0)
      {
        attr_index->syn=i;
      }
      else
      if (strcmp(format[i], "n_application")==0)
      {
        attr_index->app=i;
      }
      else
      if (strcmp(format[i], "n_read")==0)
      {
        attr_index->r=i;
        if (jwa_dbg) fprintf(jwa_dbg_ptr,"read i=%d\n", i);
      }
      else
      if (strcmp(format[i], "n_write")==0)
      {
        attr_index->w=i;
        if (jwa_dbg) fprintf(jwa_dbg_ptr,"write i=%d\n", i);
      }
      else
      if (strcmp(format[i], "n_update")==0)
      {
        attr_index->u=i;
        if (jwa_dbg) fprintf(jwa_dbg_ptr,"update i=%d\n", i);
      }
      else
      if (strcmp(format[i], "n_delete")==0)
      {
        attr_index->d=i;
      }
      else
      if (strcmp(format[i], "n_checkin")==0)
      {
        attr_index->in=i;
      }
      else
      if (strcmp(format[i], "n_checkout")==0)
      {
        attr_index->out=i;
      }
      else
      if (strcmp(format[i], "n_seqno")==0)
      {
        attr_index->seq=i;
        if (jwa_dbg) fprintf(jwa_dbg_ptr,"seq i=%d\n", i);
      }
      else
      if (strcmp(format[i], "n_attrno")==0)
      {
        attr_index->attrno=i;
      }
      else
      if (strcmp(format[i], "n_tableno")==0)
      {
        attr_index->tableno=i;
      }
      else
      if (strcmp(format[i], "n_valueno")==0)
      {
        attr_index->valueno=i;
        if (jwa_dbg) fprintf(jwa_dbg_ptr,"value i=%d\n", i);
      }
      else
      if (strcmp(format[i], "n_adviceno")==0)
      {
        attr_index->adviceno=i;
        if (jwa_dbg) fprintf(jwa_dbg_ptr,"advice i=%d\n", i);
      }
  }
}

/******************************************************************************

Doc: lowcase

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_new.c

Author: James Albersheim

Date: Sept. 19, 1991

SDM Number:

Description: This routine translates the input string to lower case.

Examples: lowcase(string)

Return Status: None

History: 6/7/90 - JWA - original code
         9/19/91 - JWA - added header

******************************************************************************/

lowcase (str)
    char *str; /* I/O - string to translate to lower */
{
/* Translate the string into lowercase. 
 */

    int i;
    char c;

    for (i=0; ; ++i)
    {
    c = *(str + i);

    if (c == (char) 0)
        break;
    else if ((c >= 'A') && (c <= 'Z'))
        *(str + i) = c - 'A' + 'a';
    }
}

/******************************************************************************

Doc: NFM2_create_catalog

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_new.c

Author: James Albersheim

Date: Sept. 19, 1991

SDM Number:

Description: This routine makes the calls necessary to add a new catalog
             to the NFM database.

Examples: status = NFM2_create_catalog (catalog_name, buffer, numofattrs, size)

Return Status: 0 = success
               non-zero = failure

History: 6/7/90 - JWA - original code
         9/19/91 - JWA - added header
08/10/92  wrw  -changed code so that buffer passed in was not modified.

******************************************************************************/

long NFM2_create_catalog (catalog_name, buff, numofattrs, size)

char *catalog_name; /* I - name of the new catalog */
char *buff;       /* I - buffer containing the attributes, datatypes,
                           and synonyms of the new catalog */
long numofattrs;    /* I - number of attributes in the new catalog */
long size;          /* I - size of the buffer */

{
long   status;
long   attr_index=0;
int    i, j, k;
int    attr_no;
int    cols;
int    found=0;
int    count = 0;
int    numfilledattrs = 0;
int    old_rows;
char   **n_data_ptr;
char   **data_ptr;
char   **column_ptr;
char   **value_ptr;
char   *end_ptr;
char   *start_ptr;
char   str[1028];
char   seqno[10];
char   loc_name[21]; 
MEMptr loc_attr = NULL;
MEMptr loc_data = NULL;
MEMptr loc_value = NULL;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr value_list = NULL;
CATptr index;
char attributes[100][80];
char datatypes[100][80];
char synonyms[100][80];
/*---------------------------WRW-F: needed for a fix-------------------------*/
int used[100];
/*---------------------------------------------------------------------------*/
char *buffer;

   NFM2_clear_messages("NFMa_create_catalog");
   NFM2_format_debug_message("Catalog Name = %s",catalog_name);

   NFM2_format_debug_message("Ensuring closed cursors <%s>",manditory_ddl);
	NFMRsqlstmt(manditory_ddl);

	buffer = strdup(buff);

  if ((getenv("JWADBG"))&&(!jwa_dbg_ptr))
  {
    jwa_dbg_ptr=fopen("/usr/tmp/jwa_demo.dbg","w");
    if (jwa_dbg_ptr!=NULL)
      jwa_dbg=1;
    else
      jwa_dbg=0;
  }

  if (jwa_dbg) printf( "size=%d\n",size);
  if (jwa_dbg) printf( "numofattrs=%d\n",numofattrs);
  if (jwa_dbg) printf("catalog=%s\n",catalog_name);
  start_ptr = end_ptr = buffer;

  while ((start_ptr<buffer+size-1)&&(attr_index<numofattrs))
  {
    if (jwa_dbg) printf( "in loop\n");
    if (jwa_dbg) printf( "size=%d\n",size);
    if (jwa_dbg) printf( "numofattrs=%d\n",numofattrs);
    start_ptr = end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(attributes[attr_index],start_ptr);
    if (jwa_dbg) printf("attr=%s\n",attributes[attr_index]);
    end_ptr++;

    start_ptr = end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(datatypes[attr_index],start_ptr);
    if (jwa_dbg) printf("type=%s\n",datatypes[attr_index]);
    end_ptr++;

    start_ptr = end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(synonyms[attr_index],start_ptr);
    if (jwa_dbg) printf("syn=%s\n",synonyms[attr_index]);

/*-------------------WRW-F: no attributes have been initially written--------*/
    used[attr_index]=0;
/*---------------------------------------------------------------------------*/

    if (end_ptr<buffer+size-1) end_ptr++;
    else break;
    if (datatypes[attr_index][0]!=0)
      attr_index++;
    if ((attr_index>=numofattrs)||(end_ptr>=buffer+size)) break;
  }

    status=NFMRvalidate_user_access(DSUSERID,"Create Catalog","","","","","");

    if (status != NFM_S_SUCCESS)
    {
      if (jwa_dbg) printf("User does not have privilege to create catalogs\n");
      if (jwa_dbg) printf("validate user access error code = %x\n", status);
		free(buffer);
      return(status);
    }

    if (jwa_dbg) printf("DSUSERID=%d\n",DSUSERID);

    if (jwa_dbg) printf("just before addto_loc_attrs\n");
    status = NFMRquery_addto_loc_attributes (DSUSERID, loc_name,
                                             &loc_attr, &loc_data, &loc_value);

    if (jwa_dbg) printf("just after addto_loc_attrs\n");

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
			free(buffer);
        return (status);
        }
   
    if (jwa_dbg) printf("after addto_loc_attrs, before cat template\n");

    status = NFMRquery_catalog_template (DSUSERID, &attr_list, &data_list,
                                         &value_list);

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&loc_attr);
        MEMclose (&loc_data);
        MEMclose (&loc_value);
        MEMclose (&attr_list);
        MEMclose (&data_list);
        MEMclose (&value_list);
			free(buffer);
        return (status);
        }

     if (jwa_dbg) printf("before building loc_attr\n");

    status = MEMbuild_array (loc_attr);

    data_ptr = (char **) loc_attr->data_ptr;
    column_ptr = (char **) loc_attr->column_ptr;

    status = MEMbuild_array (loc_value);

    value_ptr = (char **) loc_value->data_ptr;

    if (jwa_dbg) printf("filling index\n");
    NFM2fill_index (loc_attr, loc_attr->columns, &index);

    count = 0;
    for (i=0; i<loc_attr->rows*loc_attr->columns; i+=loc_attr->columns)
        {
        if ((strcmp (data_ptr[i+index.r], "Y") == 0) ||
            (strcmp (data_ptr[i+index.w], "Y") == 0))
            ++count;
        }

    status = MEMbuild_array (loc_data);

    n_data_ptr = (char **) loc_data->data_ptr;

    for (j=0, k=0; k<loc_data->columns; j+=loc_attr->columns, ++k)
        {
        if (strcmp (data_ptr[j+index.w], "Y") == 0)
            {
            if (jwa_dbg) printf("writeable attr=%s\n",data_ptr[j+index.name]);
            /* save new catalog name */
            if (strcmp (data_ptr[j+index.name], "n_catalogname") == 0)
                {
                  /* Aug. 6, 1990 - To fix catalog with caps problem */
                  lowcase(catalog_name);
                  if (jwa_dbg) printf("write_data with catalog=%s,k+1=%d\n",catalog_name,k+1);
                  status = MEMwrite_data (loc_data, catalog_name, 1, k+1);
                  if (status != MEM_S_SUCCESS)
                  {
                    MEMclose (&loc_attr);
                    MEMclose (&loc_data);
                    MEMclose (&loc_value);
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
							free(buffer);
                    return (status);
                  }
                }

            if (strcmp (data_ptr[j+index.name], "n_catalogdesc") == 0)
                {
                  /* Aug. 6, 1990 - To fix catalog with caps problem */
                  if (jwa_dbg) printf("write_data with desc\n");
                  status = MEMwrite_data (loc_data, "DMANDS catalog", 1, k+1);
                  if (status != MEM_S_SUCCESS)
                  {
                    MEMclose (&loc_attr);
                    MEMclose (&loc_data);
                    MEMclose (&loc_value);
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
							free(buffer);
                    return (status);
                  }
                }

            if (strcmp (data_ptr[j+index.name], "n_application") == 0)
                {
                  /* Aug. 6, 1990 - To fix catalog with caps problem */
                  status = MEMwrite_data (loc_data, "NFM", 1, k+1);
                  if (status != MEM_S_SUCCESS)
                  {
                    MEMclose (&loc_attr);
                    MEMclose (&loc_data);
                    MEMclose (&loc_value);
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
							free(buffer);
                    return (status);
                  }
                }

            if (strcmp (data_ptr[j+index.name], "n_type") == 0)
                {
                  /* Aug. 6, 1990 - To fix catalog with caps problem */
                  status = MEMwrite_data (loc_data, "NFM", 1, k+1);
                  if (status != MEM_S_SUCCESS)
                  {
                    MEMclose (&loc_attr);
                    MEMclose (&loc_data);
                    MEMclose (&loc_value);
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
							free(buffer);
                    return (status);
                  }
                }

            if (strcmp (data_ptr[j+index.name], "n_aclno") == 0)
                {
                  status = MEMwrite_data (loc_data, "3", 1, k+1);
                  if (status != MEM_S_SUCCESS)
                  {
                    MEMclose (&loc_attr);
                    MEMclose (&loc_data);
                    MEMclose (&loc_value);
                    MEMclose (&attr_list);
                    MEMclose (&data_list);
                    MEMclose (&value_list);
							free(buffer);
                    return (status);
                  }
                }

            }
        }

/*********************************************************************
  Enter Attribute Information - Attribute Name, Data Type, and Synonym
**********************************************************************/

     if (jwa_dbg) printf("building attr_list\n");
    status = MEMbuild_array (attr_list);

    data_ptr = (char **) attr_list->data_ptr;
    column_ptr = (char **) attr_list->column_ptr;
    cols = attr_list->columns;
    old_rows = attr_list->rows;
    
    NFM2fill_index (attr_list, cols, &index);

    status = MEMbuild_array (data_list);

    n_data_ptr = (char **) data_list->data_ptr;

    /* fill buffer with old/new attributes, data types, synonyms */
    
    for (i=0, j=0; j<attr_list->rows; ++j)
    {
      if (jwa_dbg) printf("cols=%d\n",cols);
      if (jwa_dbg) printf("name=%s\n",data_ptr[(j)*cols+index.name]);
      if (jwa_dbg) printf("write=%s\n",data_ptr[(j)*cols+index.w]);
      if (jwa_dbg) printf("read=%s\n",data_ptr[(j)*cols+index.r]);
/* change write flag for n_cocomment */
      if (strcmp(data_ptr[j*cols+index.name],"n_cocomment")==0)
      {
        status = MEMwrite_data (attr_list, "Y", j+1, index.w+1);
        if (status != MEM_S_SUCCESS)
        {
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_value);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          MEMclose (&value_list);
			free(buffer);
          return (status);
        }
        status = MEMwrite_data (attr_list, "Y", j+1, index.u+1);
        if (status != MEM_S_SUCCESS)
        {
          MEMclose (&loc_attr);
          MEMclose (&loc_data);
          MEMclose (&loc_value);
          MEMclose (&attr_list);
          MEMclose (&data_list);
          MEMclose (&value_list);
			free(buffer);
          return (status);
        }
      }
      else
      if ((strcmp(data_ptr[j*cols+index.w],"Y") == 0) &&
          (strcmp(data_ptr[j*cols+index.r],"Y") == 0))
      {
        attr_no=0;
        found=0;
        while ((!found)&&(attr_no<numofattrs))
        {
          if (strcmp(data_ptr[j*cols+index.name],attributes[attr_no])!=0) 
            attr_no++;
          else
            found=1;
        }
        if (attr_no<numofattrs)
        {
/*--------------------WRW-F: this attribute is written-----------------------*/
          used[attr_no]=1;
/*---------------------------------------------------------------------------*/
          i=attr_no;
          numfilledattrs++;
          if (jwa_dbg) printf("write data for %s\n",attributes[i]);
          status = MEMwrite_data (attr_list, attributes[i], j+1, index.name+1);
          if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
				free(buffer);
            return (status);
            }

          status = MEMwrite_data (attr_list, datatypes[i], j+1, index.dt+1);
          if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
				free(buffer);
            return (status);
            }

          status = MEMwrite_data (attr_list, synonyms[i++], j+1, index.syn+1);
          if (status != MEM_S_SUCCESS)
            {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
				free(buffer);
            return (status);
            }
        }
      }
    }  /* end for filling new attribute, data type synonym values */

    /* fill buffer with old/new attributes, data types, synonyms */
    
    if (jwa_dbg) printf("# filled=%d\n",numfilledattrs);

    if (numofattrs > numfilledattrs)
    {
        /* user attributes have been added */
        /* add the new rows to the attribute buffer */
/*------------------WRW-F: loop through all now, replace with below---------
        for (i=numfilledattrs; i<numofattrs; ++i)
---------------------------------------------------------------------------*/
        for (i=0;i<numofattrs;i++)
/*---------------------------------------------------------------------------*/
        {
/*---------------WRW-F: see if this has already been written-----------------*/
            if (used[i]) continue;
/*---------------------------------------------------------------------------*/
            str[0] = 0;
            found=0;
            for (j=0; ((j<attr_list->rows)&&(!found)); ++j)
            {
              if (jwa_dbg) printf("name=%s\n",data_ptr[(j)*cols+index.name]);
              if (strcmp(data_ptr[j*cols+index.name],attributes[i])==0)
                found=1;
            }
            if (!found)
            {
              for (j=0; j<attr_list->columns; ++j)
              {
                     if (strcmp (column_ptr[j], "n_name") == 0)
                         strcat (str, attributes[i]);
                else if (strcmp (column_ptr[j], "n_datatype") == 0)
                         strcat (str, datatypes[i]);
                else if (strcmp (column_ptr[j], "n_synonym") == 0)
                         strcat (str, synonyms[i]);
                else if (strcmp (column_ptr[j], "n_nfmname") == 0)
                         strcat (str, attributes[i]);
                else if (strcmp (column_ptr[j], "n_opentonfm") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_application") == 0)
                         strcat (str, "USR");
                else if (strcmp (column_ptr[j], "n_read") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_write") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_update") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_delete") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_null") == 0)
                         strcat (str, "Y");
                else if (strcmp (column_ptr[j], "n_keyin") == 0)
                         strcat (str, "0");
                else if (strcmp (column_ptr[j], "n_checkin") == 0)
                         strcat (str, "N");
                else if (strcmp (column_ptr[j], "n_checkout") == 0)
                         strcat (str, "N");
                else if (strcmp (column_ptr[j], "n_seqno") == 0)
                         {
                         sprintf (seqno, "%d", 
                                  attr_list->rows);
                         strcat (str, seqno);
                         }
                else if (strcmp (column_ptr[j], "n_listno") == 0)
                         strcat (str, "0");
                else
                         strcat (str, "");

                strcat (str, "\1");

              }  /* end for */

              if (jwa_dbg) printf("write for %s\n",str);
              status = MEMwrite (attr_list, str);
              if (status != MEM_S_SUCCESS)
              {
                MEMclose (&loc_attr);
                MEMclose (&loc_data);
                MEMclose (&loc_value);
                MEMclose (&attr_list);
                MEMclose (&data_list);
                MEMclose (&value_list);
					free(buffer);
                return (status);
              }

              status = MEMbuild_array (attr_list);

              data_ptr = (char **) attr_list->data_ptr;
              column_ptr = (char **) attr_list->column_ptr;
            }

        }  /* end for */

        /* build a new data buffer with all old attributes plus new ones */

        if (jwa_dbg) printf("rebuilding\n");
        status = NFMRrebuild_data_buffer (attr_list, &data_list);
        if (status != NFM_S_SUCCESS)
        {
            MEMclose (&loc_attr);
            MEMclose (&loc_data);
            MEMclose (&loc_value);
            MEMclose (&attr_list);
            MEMclose (&data_list);
            MEMclose (&value_list);
				free(buffer);
            return (status);
        }

    }  /* end if old_row_count < data.num_of_rows */

    status = MEMbuild_array (attr_list);

    if (jwa_dbg)
    {
      MEMprint_buffer( "attr_list", attr_list, "mod_attr_list");
      MEMprint_buffer( "loc_attr", loc_attr, "mod_loc_attr");
      MEMprint_buffer( "loc_data", loc_data, "mod_loc_data");
      MEMprint_buffer( "data_list", data_list, "mod_data_list");
      MEMprint_buffer( "value_list", value_list, "mod_value_list");
    }

    if (loc_attr) NFMRtic_it(loc_attr);
    if (loc_data) NFMRtic_it(loc_data);
    if (data_list) NFMRtic_it(data_list);
    if (attr_list) NFMRtic_it(attr_list);
    if (value_list) NFMRtic_it(value_list);

    if (jwa_dbg) printf("before create catalog\n");
    status = NFMRcreate_catalog (DSUSERID, loc_attr, loc_data,
                                 attr_list, data_list, value_list);
    if (jwa_dbg) printf("after create catalog with status=%x\n",status);

    NFMRset_to_state( DSUSERID, "nfm" );

    MEMclose (&loc_attr);
    MEMclose (&loc_data);
    MEMclose (&loc_value);
    MEMclose (&attr_list);
    MEMclose (&data_list);
    MEMclose (&value_list);

	free(buffer);
    if (status==NFM_S_SUCCESS)
      return(0);    
    return (status);
}

/******************************************************************************

Doc: NFM2_build_new_cat_field

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_new.c

Author: James Albersheim

Date: Sept. 19, 1991

SDM Number:

Description: This routine builds a buffer in the proper format for the
             attribute buffer in NFM and writes it into that buffer.

Examples: status = NFM2_build_new_cat_field(name,type,syn,num,attr_list)

Return Status: 0 = success
               non-zero = failure

History: 6/7/90 - JWA - original code
         9/19/91 - JWA - added header

******************************************************************************/

int NFM2_build_new_cat_field(name,type,syn,attr_list)
char *name; /* I - name of the attribute */
char *type; /* I - type of the attribute */
char *syn;  /* I - synonym of the attribute */
MEMptr attr_list; /* I/O - attribute buffer */

{
  char seqno[5],str[1028], table[5];
  char **data_ptr;
  CATptr attr_index;
  int sts, cols, col_index, row_ctr;
  int rows, sequence, tableno, new_seq;

  str[0] = 0;
  cols = attr_list->columns;
  rows = attr_list->rows;
  data_ptr = (char **) attr_list->data_ptr;
  NFM2fill_index( attr_list, cols, &attr_index);

  tableno = atoi(data_ptr[attr_index.tableno]);
  if (jwa_dbg) printf("tableno=%d\n",tableno);
  sprintf(table,"%d",tableno);

  /* get max sequence number and add one for correct seqno for new attribute */

  sequence = -1;
  for (row_ctr=0;row_ctr<rows;row_ctr++)
  {
    new_seq = atoi(data_ptr[row_ctr*cols+attr_index.seq]);
    if (new_seq>sequence) sequence=new_seq;
  }
  sequence++;

  str[0]=0;
  if (jwa_dbg) printf("cols=%d\n",cols);
  for (col_index=0;col_index<cols;col_index++)
  {
      if (col_index==attr_index.name) strcat(str, name);
      else if (col_index==attr_index.dt  ) strcat(str, type);
      else if (col_index==attr_index.syn ) strcat(str, syn);
      else if (col_index==attr_index.app ) strcat(str, "USR");
      else if (col_index==attr_index.r   ) strcat(str, "Y");
      else if (col_index==attr_index.w   ) strcat(str, "Y");
      else if (col_index==attr_index.u   ) strcat(str, "Y");
      else if (col_index==attr_index.d   ) strcat(str, "Y");
      else if (col_index==attr_index.nul ) strcat(str, "Y");
      else if (col_index==attr_index.in  ) strcat(str, "N");
      else if (col_index==attr_index.out ) strcat(str, "N");
      else if (col_index==attr_index.seq )
      {
        sprintf(seqno,"%d",sequence);strcat(str,seqno);
      }
      else if (col_index==attr_index.attrno) strcat(str, "");
      else if (col_index==attr_index.tableno) strcat(str, table);
      else if (col_index==attr_index.valueno) strcat(str, "");
      else if (col_index==attr_index.adviceno) strcat(str, "");
      strcat(str, "\1");
  }
  if (jwa_dbg) printf("new str=%s\n",str);
  sts = MEMwrite( attr_list, str);
  if (jwa_dbg) printf("sts from new_cat=%x\n",sts);
  if (sts!=MEM_S_SUCCESS)
    return(sts);
  else
    return(0);

}/* NFM2_build_new_cat_field */

/******************************************************************************

Doc: NFM2_modify_cat_field

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_new.c

Author: James Albersheim

Date: Sept. 19, 1991

SDM Number:

Description: This routine makes the changes to the attribute buffer
             of an existing catalog for a particular attribute

Examples: status = NFM2_modify_cat_field(name,type,syn,num,attr_list)

Return Status: 0 = success
               non-zero = failure

History: 6/7/90 - JWA - original code
         9/19/91 - JWA - added header

******************************************************************************/

int NFM2_modify_cat_field(name,type,syn,attr_list)
char *name; /* I - name of the attribute */
char *type; /* I - type of the attribute */
char *syn;  /* I - synonym of the attribute */
MEMptr attr_list; /* I/O - attribute buffer */

{
  char str[1028];
  CATptr attr_index;
  int total_cols;
  int cols;
  int sts;
  int row_ctr;
  int rows;
  char **data_ptr;
  int sequence;

  strcpy(str,type);
  str[0] = 0;

  total_cols = attr_list->columns;
  cols = (total_cols+1)/2;
  rows = attr_list->rows;
  data_ptr = (char **)attr_list->data_ptr;
  NFM2fill_index( attr_list, cols, &attr_index);

  row_ctr=0;
  sequence = -1;
  while ((sequence==-1)&&(row_ctr<rows))
  {
    if (strcmp(data_ptr[row_ctr*total_cols+attr_index.name], name)==0)
      sequence=row_ctr;
    else
      row_ctr++;
  }

  strcpy(str,syn);/* syn name */
  sts = MEMwrite_data( attr_list, str, sequence+1, attr_index.syn+cols+1);
  if (sts!=MEM_S_SUCCESS)
    return(sts);

  return(0);
}/* NFM2_modify_cat_field */

/******************************************************************************

Doc: NFM2_modify_catalog

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_new.c

Author: James Albersheim

Date: Sept. 19, 1991

SDM Number:

Description: This routine is the notification routine behind the Create
             Catalog form. It contains the main switch statement with the
             code behind each gadget on the form.

Examples: status = NFM2_modify_catalog(cat_name, buffer, numofoldattrs, numofnewattrs, size)

Return Status: 0 = success
               non-zero = failure

History: 6/7/90 - JWA - original code
         9/19/91 - JWA - added header

******************************************************************************/

int NFM2_modify_catalog(cat_name, buffer, numofoldattrs, numofnewattrs, size)

char *cat_name;     /* I - name of the catalog */
char *buffer;       /* I - buffer of attributes, datatypes, and synonyms */
long numofoldattrs; /* I - old number of attributes */
long numofnewattrs; /* I - new number of attributes */
long size;          /* I - size of buffer */

{
  MEMptr	attr_list = NULL;
  MEMptr	data_list = NULL;
  MEMptr        value_list = NULL;
  MEMptr        loc_attr = NULL;
  MEMptr        loc_data = NULL;
  MEMptr        loc_value = NULL;
  char          mess[80];
  char          loc_name[21];
  char          attrib[80];
  char          dtype[80];
  char          syn[80];
  char          **data_ptr,**column;
  int	        sts,cols,rows;
  int           attr_index;
  char          *start_ptr,*end_ptr;
  char attributes[200][80];
  char datatypes[200][80];
  char synonyms[200][80];

   NFM2_clear_messages("NFMa_modify_catalog");
   NFM2_format_debug_message("Catalog Name = %s",cat_name);

   NFM2_format_debug_message("Ensuring closed cursors <%s>",manditory_ddl);
	NFMRsqlstmt(manditory_ddl);

  if (getenv("JWADBG"))
  {
    jwa_dbg_ptr=fopen("/usr/tmp/jwa_demo.dbg","w");
    if (jwa_dbg_ptr!=NULL)
      jwa_dbg=1;
    else
      jwa_dbg=0;
  }

  sts = NFMRvalidate_user_access(DSUSERID,"Create Catalog","","","","","");
  if (sts != NFM_S_SUCCESS)
  {
    if (jwa_dbg) printf(  "User does not have privilege to modify catalogs\n");
    if (jwa_dbg) printf(  "validate user access error code = %x\n", sts);
  }
  else
  {
    sts = NFMRquery_changeto_loc_attributes( DSUSERID, loc_name, cat_name, 
                                             &loc_attr, &loc_data, &loc_value);

    if (sts != NFM_S_SUCCESS)
    {
      strcpy(mess,"** NFMRquery_changeto_loc_attributes failed **");
      ERRreset_struct();
      return(sts);
    }
    if (jwa_dbg) printf( "past query_changeto_loc_attribs\n");
    sts = MEMbuild_array(loc_attr);
    if (sts != MEM_S_SUCCESS)
    {
      strcpy(mess,"** MEMbuild_array for loc_attr failed **");
      ERRreset_struct();
      return(sts);
    }
    
    if (jwa_dbg) printf( "past build loc_attr\n");
    sts = MEMbuild_array(loc_data);
    if (sts != MEM_S_SUCCESS)    
    {
      strcpy(mess,"** MEMbuild_array for loc_data failed **");
      ERRreset_struct();
      return(sts);
    }

    if (jwa_dbg) printf( "past build loc_data\n");
    column = (char **) loc_attr->column_ptr;
    cols   = loc_attr->columns;
    rows   = loc_attr->rows;
    data_ptr = (char **) loc_attr->data_ptr;
 
    if (jwa_dbg) printf("before qry change cat attrs\n");
    sts = NFMRquery_change_catalog_attributes( DSUSERID, cat_name, &attr_list, 
                                               &data_list, &value_list);

    if (sts != NFM_S_SUCCESS)
    {
      strcpy(mess,"** NFMRquery_change_catalog_attributes failed **");
      ERRreset_struct();
      return(sts);
    }
    if (jwa_dbg) printf( "past query change cat_attribs\n");

    sts = MEMbuild_array(attr_list);
    if (sts != MEM_S_SUCCESS)
    {
      strcpy(mess,"** MEMbuild_array for attr_list failed **");
      ERRreset_struct();
      return(sts);
    }
    if (jwa_dbg) printf("past bld attr list\n");
    sts = MEMbuild_array(data_list);
    if (sts != MEM_S_SUCCESS)
    {
      strcpy(mess,"** MEMbuild_array for data_list failed **");
      ERRreset_struct();
      return(sts);
    }
    if (jwa_dbg) printf("past bld data list\n");

    data_ptr = (char **) attr_list->data_ptr;
    column = (char **) attr_list->column_ptr;
    rows = attr_list->rows;
    cols = attr_list->columns;

    end_ptr=start_ptr=buffer;
    attr_index=0;

  while (end_ptr<buffer+size-1)
  {
    if (jwa_dbg) printf( "in loop\n");
    start_ptr=end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(attributes[attr_index],start_ptr);
    end_ptr++;
    if (jwa_dbg) printf( "attr=%s\n",attributes[attr_index]);

    start_ptr=end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(datatypes[attr_index],start_ptr);
    if (jwa_dbg) printf( "type=%s\n",datatypes[attr_index]);
    end_ptr++;

    start_ptr=end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(synonyms[attr_index],start_ptr);
    if (jwa_dbg) printf( "syn=%s\n",synonyms[attr_index]);
    if (end_ptr<buffer+size-1) end_ptr++;
    else break;

    if (datatypes[attr_index][0]!=0)
      attr_index++;

    if (end_ptr>=buffer+size-1) break;
  }

    for (attr_index=0;attr_index<numofnewattrs;attr_index++)
      if (jwa_dbg) printf( "%s, %s, %s\n",attributes[attr_index], 
             datatypes[attr_index],synonyms[attr_index]);

    if (jwa_dbg) printf( "after printing attrs\n");

    for (attr_index=0;attr_index<numofnewattrs;attr_index++)
    {
      strcpy(attrib, attributes[attr_index]);
      strcpy(dtype, datatypes[attr_index]);
      strcpy(syn, synonyms[attr_index]);
      if (jwa_dbg) printf( "before mod cat\n");
      if (attr_index<numofoldattrs)
      {
        MEMbuild_array(attr_list);
        sts = NFM2_modify_cat_field(attrib, dtype, syn, attr_list);
        if ((sts != 0) && (sts != MEM_E_NULL_ROWS))
        {
          sprintf(mess,"** mod_cat for %s failed **", attrib);
          ERRreset_struct();
          return(sts);
        }
        else
          if (sts==MEM_E_NULL_ROWS)
          {
/* 12/3/91 - JWA - commented out this section because was getting 
             MEM_E_NULL_ROWS with all user defined attributes */
/*          
            MEMbuild_array(attr_list);
            if (jwa_dbg) 
             printf("before bld new cat,attrib=%s,syn=%s,dtype=%s\n",
                    attrib, syn, dtype);
            sts=NFM2_build_new_cat_field(attrib,dtype,syn,attr_list);
            if (sts!=0)
            {
              sprintf(mess,"** bld_new_cat for %s failed **", attrib);
              ERRreset_struct();
              return(sts);
            }
            else
            {
              if (jwa_dbg) printf("after build_new_cat\n");
            }
*/    
          }
      }
      else
      {
        MEMbuild_array(attr_list);
      if (jwa_dbg) 
       printf("before bld new cat,attrib=%s,syn=%s,dtype=%s\n",
               attrib, syn, dtype);
        sts = NFM2_build_new_cat_field(attrib,dtype,syn,attr_list);
        if ((sts!=0)&&(sts!=MEM_S_SUCCESS))
        {
          sprintf(mess,"** bld_new_cat for %s failed **", attrib);
          ERRreset_struct();
          return(sts);
        }
        if (jwa_dbg) printf("past build new cat\n");
      }
      sts = MEMbuild_array(attr_list);
      if (sts != MEM_S_SUCCESS)
      {
        strcpy(mess,"** MEMbuild_array for attr_list failed **");
        ERRreset_struct();
        return(sts);
      }
      if (jwa_dbg) printf( "after mod cat\n");
    }

      if (jwa_dbg) printf( "before rebuild\n");
    sts = NFMRrebuild_data_buffer( attr_list, &data_list);
    if (sts != NFM_S_SUCCESS)
    {
      strcpy(mess, "** rebuild_data_buffer failed **");
      ERRreset_struct();
      return(sts);
    }
    if (jwa_dbg)
    {
      printf("after rebuild\n");
      MEMprint_buffer( "attr_list", attr_list, "mod_attr_list");
      MEMprint_buffer( "loc_attr", loc_attr, "mod_loc_attr");
      MEMprint_buffer( "loc_data", loc_data, "mod_loc_data");
      MEMprint_buffer( "data_list", data_list, "mod_data_list");
      MEMprint_buffer( "value_list", value_list, "mod_value_list");
    }
    if (jwa_dbg) 
      printf( "before change cat with userid=%d\n",DSUSERID);
    sts = NFMRchange_catalog( DSUSERID, loc_attr, loc_data, 
                            attr_list, data_list, value_list);
    if (jwa_dbg) printf( "after change cat with sts=%x\n",sts);
    if (sts != NFM_S_SUCCESS)
    {
      if (sts == NFM_E_DUP_CATALOG)
        if (jwa_dbg) printf( "** Catalog %s already exists **\n",cat_name);
      else
      {
        if (jwa_dbg) printf("** modify catalog failed **\n");
      }
    }
    else
    {
      if (jwa_dbg) printf( "past modify catalog with status=%x\n",sts);
    }

    NFMRset_to_state( DSUSERID, "nfm" );

  }
  if( attr_list )
    MEMclose( &attr_list );
  if( data_list )
    MEMclose( &data_list);
  if( value_list )
    MEMclose( &value_list);
  if( loc_attr )
    MEMclose( &loc_attr);
  if( loc_data )
    MEMclose( &loc_data);
  if (sts==NFM_S_SUCCESS)
    return(0);    
  return (sts);
}

/******************************************************************************

Doc: NFM2_checkin_mult_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_new.c

Author: James Albersheim

Date: Sept. 19, 1991

SDM Number:

Description: This routine checks multiple files into an item in a NFM catalog.

Examples: status = NFM2_checkin_mult_item ( catalog_name, item_name, 
                                       item_revision, storage_area, num_files, 
                                            files_buffer, buffer_size)

Return Status: NFM_S_SUCCESS = success
               anything else = failure

History: 6/7/90 - JWA - original code
         9/19/91 - JWA - added header

******************************************************************************/

long NFM2_checkin_mult_item ( catalog_name, item_name, item_revision, 
	storage_area, num_files, files_buffer, buffer_size)
	
char   *catalog_name;  /* I - name of the catalog */
char   *item_name;     /* I - name of the item */
char   *item_revision; /* I - revision of the item */
char   *storage_area;  /* I - checkout storage area */
char   *files_buffer;  /* I - list of checkin file names, checkout file names,
                              file types, and file comments to checkin */
long   num_files;      /* I - number of files */
long   buffer_size;    /* I - size of buffer */
{
	/* Local declarations */

	char      **attributes;    /* Attribute list */
	char	  **value;
	char	  str[5000];
	long      i,j;               /* Counter */
	long      num_attrs;       /* Number of attributes */
	long      status;          /* Return status */
	MEMptr    attr_list = NULL, data_list = NULL;
    char      file_conames[100][15];
    char      file_cinames[100][15];
    char      file_types[100][6];
    char      file_cisas[100][5];
    char      file_comments[100][100];
    char      *end_ptr;
    char      *start_ptr;
    long      file_index;

/* separate names,types,cosas,cisas,comments in buffer */

  printf("in checkin multifile\n");
  if (getenv("JWADBG"))
    jwa_dbg=1;
  else
    jwa_dbg=0;

  if (jwa_dbg) printf("debug on\n");
  else printf("debug off\n");

  start_ptr = end_ptr = files_buffer;
  file_index=0;

  if (jwa_dbg) printf("buffer_size=%d\n",buffer_size);
  if (jwa_dbg) printf("num_files=%d\n",num_files);
  while ((start_ptr<files_buffer+buffer_size-1)&&(file_index<num_files))
  {
    start_ptr = end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(file_conames[file_index],start_ptr);
    if (jwa_dbg) printf("file_conames[%d]=%s\n",file_index,start_ptr);
    end_ptr++;

    start_ptr = end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(file_cinames[file_index],start_ptr);
    if (jwa_dbg) printf("file_cinames[%d]=%s\n",file_index,start_ptr);
    end_ptr++;

    start_ptr = end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(file_types[file_index],start_ptr);
    if (jwa_dbg) printf("file_types[%d]=%s\n",file_index,start_ptr);
    end_ptr++;

    start_ptr = end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(file_comments[file_index],start_ptr);
    if (jwa_dbg) printf("file_comments[%d]=%s\n",file_index,start_ptr);
    end_ptr++;

    start_ptr = end_ptr;
    if ((end_ptr = strchr(start_ptr,'\n'))!=NULL)
      *end_ptr=0;
    else
      break;
    strcpy(file_cisas[file_index],start_ptr);
    if (jwa_dbg) printf("file_cisas[%d]=%s\n",file_index,start_ptr);

    if (end_ptr<files_buffer+buffer_size-1) end_ptr++;
    else break;
    if (file_types[file_index][0]!=0)
      file_index++;
    if ((file_index>=num_files)||(end_ptr>=files_buffer+buffer_size-1)) break;
  }

    if (jwa_dbg) printf("past parsing buffer\n");

	/****************************************
    * See if the user has the authority to *
    * checkin an item.                     *
    ****************************************/

	status = NFMRvalidate_user_access ( DSUSERID, "Check In Item",
	    "", "", catalog_name, item_name, item_revision );
	if (jwa_dbg) fprintf(jwa_dbg_ptr, "status from validate=%x\n", status);
	if ( status != NFM_S_SUCCESS ) goto end;

	/*********************************
    * Prepare the item for checkin. *
    *********************************/

	status = NFMRprepare_item_checkin ( DSUSERID, catalog_name, 
		    item_name, item_revision, &attr_list, &data_list );

	if ( status != NFM_S_SUCCESS ) goto end;
	status = MEMbuild_array(data_list);
	if ( status != MEM_S_SUCCESS ) goto end;
	status = MEMbuild_array(attr_list);
	if (status != MEM_S_SUCCESS) goto end;

	/**********************************************
    * Fill in the data buffer with the necessary *
    * checkin item information.                  *
    **********************************************/

	attributes = (char **) data_list->column_ptr;
	value = (char **) data_list->data_ptr;
	num_attrs = data_list->columns;

    for ( i = 0; i < num_attrs; ++i )
	{
      if ( !strcmp ( attributes[i], "n_cofilename" ) )
	  {
	    status = MEMwrite_data ( data_list, file_conames[0], 1, i+1);
	    if ( status != MEM_S_SUCCESS ) goto end;
      }
      if ( !strcmp ( attributes[i], "n_cifilename" ) )
	  {
	    status = MEMwrite_data ( data_list, file_cinames[0], 1, i+1);
	    if ( status != MEM_S_SUCCESS ) goto end;
      }
      if ( !strcmp ( attributes[i], "n_filetype" ) )
	  {
	    status = MEMwrite_data ( data_list, file_types[0], 1, i+1);
	    if ( status != MEM_S_SUCCESS ) goto end;
      }
      if ( !strcmp ( attributes[i], "n_cisano" ) )
	  {
	    status = MEMwrite_data ( data_list, file_cisas[0], 1, i+1);
	    if ( status != MEM_S_SUCCESS ) goto end;
      }
      if ( !strcmp ( attributes[i], "n_cocomment" ) )
	  {
	    status = MEMwrite_data ( data_list, file_comments[0], 1, i+1);
	    if ( status != MEM_S_SUCCESS ) goto end;
      }
	}

	for (j = 1; j < num_files; ++j)
	{
	   str[0]=0;
       for (i = 0; i < num_attrs; ++i)
       {
          if ( !strcmp( attributes[i], "n_cofilename" ) )
          {
   		     strcat(str, file_conames[j]);
	      }
          else
          if ( !strcmp( attributes[i], "n_cifilename" ) )
          {
   		     strcat(str, file_cinames[j]);
	      }
	      else
          if ( !strcmp( attributes[i], "n_filetype" ) )
	      {
            strcat(str, file_types[j]);
	      }
	      else
          if ( !strcmp( attributes[i], "n_cisano" ) )
	      {
  		    strcat(str, file_cisas[j]);
	      }
	      else
          if ( !strcmp( attributes[i], "n_cocomment" ) )
	      {
  		    strcat(str, file_comments[j]);
	      }
	      else
	      {
     		if (value[i][0]) strcat(str, value[i]);
          }
          strcat(str, "\1");
	   }

       status = MEMwrite(data_list, str);
	   if ( status != MEM_S_SUCCESS )
	      goto end;

       status = MEMbuild_array(data_list);
       if ( status != MEM_S_SUCCESS )
         goto end;

       attributes = (char **) data_list->column_ptr;
	   value = (char **) data_list->data_ptr;
     }

	/**************************************
    * Do the actual checkin of the item. *
    **************************************/

    status = NFMRcomplete_item_checkin ( DSUSERID, storage_area, "", "",
		                                 "", "", attr_list, data_list );

end:

	/*********************************
    * Tell NFM how everything went. *
    *********************************/

	if ( status != NFM_S_SUCCESS )
	{
		if (jwa_dbg) fprintf(jwa_dbg_ptr,"\nCalling NFMRcancel_item_checkin\n");
		status = NFMRcancel_item_checkin ( DSUSERID, attr_list, data_list );
	}
	NFMRset_to_state ( DSUSERID, "nfm" );

    if ( status == NFM_S_SUCCESS) return(0);
	return ( status );
}


/******************************************************************************

Doc:    NFMa_ticked

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   May 19, 1992

Description:
        Returns a character pointer to a string that is a duplicate of the
          string you passed in.
        The catch is that all ticks (') are doubled so that ris statements
          work ok.


Examples:
          new_string = NFMa_ticked(string)

Return Status:
        char *    -to the new string

History:

******************************************************************************/

char *NFMa_ticked(string)
   char *string;
{
static char *new[5];
static long  size[5]={0,0,0,0,0};
static long  seq=0;
long i,j;

   seq++; if (seq>=5) seq=0;

   if ((2*(strlen(string)+1))>size[seq]) {
      if (size[seq])
         new[seq]=(char *)realloc(new[seq],(size[seq]=2*(strlen(string)+1)*sizeof(char)));
      else
         new[seq]=(char *)malloc((size[seq]=2*(strlen(string)+1)*sizeof(char)));
      }
   for (j=i=0;i<strlen(string);i++,j++) {
      new[seq][j]=string[i];
      if (string[i]=='\'') new[seq][++j]='\'';
      }
   new[seq][j]=0;
   return(new[seq]);
}


/******************************************************************************
Doc:    NFMa_simple_add_item

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   July 27, 1992

Description:
		Performs the same function as NFMa_add_item but without the double
			pointers that give some people so much trouble.
		'buffer' should be of the following form:
			attribute1\1value1\1attribute2\value2...attributeN\1valueN


Examples:
		status = NFMa_simple_add_item(catalog,count,buffer)

Return Status:
		0			success
		<non 0>	NFM error code
		-1			required info (item name&rev. or acl no) not found
		-2       other error occurred

History:

******************************************************************************/

long	NFMa_simple_add_item(catalog,count,buffer)
	char *catalog;		/* I - catalog to add to. */
	long  count;		/* I - number of attribute/value paires */
	char *buffer;		/* I - attribute and value pairs. */
{
char *item_name=NULL;
char *item_rev=NULL;
char *acl_no=NULL;
char **attributes, **values;
long i,status;
char *buff,*s;

   NFM2_clear_messages("NFMa_simple_add_item");

	attributes = (char **) malloc (count * sizeof(char*));
	values = (char **) malloc (count * sizeof(char*));

   if (!attributes || !values) {
   	NFM2_debug_message("Exiting NFMa_simple_add_item - status = -2");
		return(-2);
		}

	s=buff=strdup(buffer);
	for (i=0;i<count;i++) {
		attributes[i]=s;
		s=strchr(s,'\1'); if (s) {*s=0;s++;}
		values[i]=s;
		s=strchr(s,'\1'); if (s) {*s=0;s++;}
		if (!strcmp(attributes[i],"n_itemname")) item_name=values[i];
		if (!strcmp(attributes[i],"n_itemrev")) item_rev=values[i];
		if (!strcmp(attributes[i],"n_aclno")) acl_no=values[i];
		}

	if (!item_name || !item_rev || ! acl_no) {
		free(attributes); free(values); free(buff);
   	NFM2_debug_message("Exiting NFMa_simple_add_item - status = -1");
		return(-1);
		}

	status = NFMa_add_item(catalog,item_name,item_rev,acl_no,attributes
                         ,values,(int)count);
	free(attributes); free(values); free(buff);
  	NFM2_format_debug_message("Exiting NFMa_simple_add_item - status = %D"
                            ,status);
	return(status);
}


long NFMa_base_cvt( in, out, base, digits )
long in;	/* I - decimal number */
char *out;	/* O - Output base number */
long base;	/* I - Base to convert to */
long digits;	/* I - Number of digits to generate */
{
int x;
int powers[10];
static char *xlate="0123456789abcdefghijklmnopqrstuvwxyz";

powers[0] = 1;
for( x = 1; x < digits; x++ ) powers[x] = powers[x-1] * base;

while( digits-- )
{
  x = in / powers[ digits ];
  *(out++) = xlate[ x ];
  in = in - ( x * powers[ digits ] );
}

*out = 0;
return(0);
}


/******************************************************************************

Doc:    NFMa_upd_redlines

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcheckin.c

Author: Rob Whitesell

Date:   12-JULY-1991

Description:
        This function checks a give item_no for multiple versions.  If there
           are multiple versions, it checks to see if the previous version 
           had redlines on its files.  If the n_cofilename of the old file with
           redlines match the new co_filename, the redlines are transfered to
           the new version.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.
  
Examples:
          status = NFMa_upd_redlines(catalog,name,rev);

Return Status:
          DMD_F_INTERN_ERR      - bad information given
          DMD_F_BAD_SELECT      - select statement failed.
          DMD_S_SUCCESS 	- Success
          any error status returned by NFMa_update_item() on failure

History:
     09/03/91  wrw  -added standard header
     04/16/93  wrw  -added code to change isam file names for XDMANDS redlines.
     09/06/93  wrw  -changed breaks to continues so that all redlines in the
                     list will be reassociated if possible.  It was returning
                     at the first sign of error.

******************************************************************************/

long NFMa_upd_redlines(catalog,name,rev)
	char *catalog;
	char *name;
	char *rev;
{
long item_no;
long hold_old,hold_new,hold_cat;
char oldred[16],redfile[16];
long  file_ver,redlines,file_no;
char  sql_line[1000];
char *error_m;
char  red_file[25],tmp[50],attr_name[20],cat_name[MAX_CAT_NAME_LEN];
char **old_red,new_red[25];
char **old_rev;
char  *tmp1[2],*tmp2[2];
long   buff_size, max_rows;
char   *data_buff;
long    status,i,j;
long   rows_cols, rows, cols;
long  *src;
short *size;
char  *data;

   NFM2_clear_messages("NFMa_upd_redlines");

   sprintf(sql_line
				,"select n_itemno from %s where n_itemname='%s' and n_itemrev='%s'"
				,catalog,name,rev);
   status = NFMa_single_select(sql_line,tmp,&error_m);
   if (status)
      return(status);
   item_no = atoi(tmp);

   sprintf(sql_line,"select max(n_fileversion) from f_%s where n_itemnum=%d"
				,catalog,item_no);
   status = NFMa_single_select(sql_line,tmp,&error_m);
   if (status)
      return(status);
   file_ver = atoi(tmp);
   
   /* check if multiple versions exist */
   if (file_ver <= 1)
      return(0);

   /* redlines have item name: IIIIII|FFFFFFF|PPPLLL               */
   /*    I - item no;  F - file no;  P - page no;  L - layer no    */
   /* and revision = same as associated item's revision            */

  sprintf(sql_line,"select count(*) from %s_rl where n_itemname like '%.6d|%%'"
          ,catalog,item_no);
   status = NFMa_single_select(sql_line,tmp,&error_m);
   if (status)
      return(status);
   redlines = atoi(tmp);

   /* check if any redlines exist */
   if (redlines <= 0)
      return(0);

   buff_size = 2048 + (25 * redlines);
   data_buff = (char *) malloc (buff_size*sizeof(char));
   if (!data_buff) {
      return(1);
      }
   max_rows = redlines +10;
   sprintf(sql_line,"select n_itemname,n_itemrev from %s_rl where n_itemname like '%.6d|%%'"
				,catalog,item_no);
   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,&error_m);
   if (status) {
      free(data_buff);
      return(status);
      }
   else {
      src = (long *)data_buff;
      status = (*src++);
      rows_cols = (*src++);
      cols = (*src++);
      rows = rows_cols/cols;
      size = (short *)src;
      data = (char *)((long)size+((rows_cols + cols)*sizeof(short)));
      if (status || rows == 0) {
         free(data_buff);
         return(status);
         }
      else {
         /* allocate space for the redline names */
         old_red = (char **) malloc(redlines*sizeof(char *));
         old_rev = (char **) malloc(redlines*sizeof(char *));
         if (!old_red || !old_rev) {
            free(data_buff);
            return(2);
            }
         for (i=0;i<redlines;i++) {
            old_red[i] = (char *) malloc(25*sizeof(char));
            old_rev[i] = (char *) malloc(128*sizeof(char));
            if (!old_red[i] || !old_rev[i]) {
               free(data_buff);
               return(3);
               }
            }

         /* move data pointer past column names */
         for (i=1;i<=cols;i++) {
            data += (*size+1);
            size++;
            }
         /* FINALLY! load names in name array */
         for (i=0;i<rows_cols;i++) {
            if (i>=redlines) {
               break;
               }
            strcpy(old_red[i],data);
            data += (*size+1);
            size++;

            strcpy(old_rev[i],data);
            data += (*size+1);
            size++;
            }
         if (rows_cols<redlines) {
            for (i=rows_cols;i<redlines;i++) {
               free(old_red[i]);
					free(old_rev[i]);
					}
            redlines = rows_cols;
            }
         }
      }

   free(data_buff);

   /* process the list of redlines -fix as we go. */
   strcpy(attr_name,P_ITEM_NAME);
   sprintf(cat_name,"%s_rl",catalog);
   for (i=0; i<redlines; i++) {
	  	NFM2_format_debug_message("NFMa_upd_redlines - update redl <%s> rev <%s>"
  	                          ,old_red[i],old_rev[i]);
      strncpy(tmp,&old_red[i][7],7);
      tmp[7]=0;
      hold_old=file_no = atoi(tmp);
 
      /* find the file name -used for future selects and diagnostics */
      sprintf(sql_line,"select n_cofilename from f_%s where n_itemnum=%d and n_fileversion=%d and n_fileno=%d"
                      ,catalog,item_no,(file_ver-1),file_no);
      status = NFMa_single_select(sql_line,red_file,&error_m);
      if (status || !red_file[0]) {
	  		if (!red_file[0]) {
				NFM2_format_debug_message("NFMa_upd_redlines - no file info on item no <%d> file no <%d> version <%d>"
  	                          ,item_no,file_no,file_ver-1);
				status=4;
				}
         continue; /* changed from break 9/6/93 - WRW */
         }

      /* find the new file number */
      sprintf(sql_line
             ,"select n_fileno from f_%s where n_itemnum=%d and n_fileversion=%d and n_cofilename='%s'"
             ,catalog,item_no,file_ver,NFMa_ticked(red_file));
      status = NFMa_single_select(sql_line,tmp,&error_m);
      if (status)
         continue; /* changed from break 9/6/93 - WRW */
      /* check if the file was found. */
      if (!tmp[0]) {
			NFM2_format_debug_message("NFMa_upd_redlines - lost redline: no file info on item no <%d> file name <%s> version <%d>"
                            ,item_no,red_file,file_ver);
         continue;
         }
      
      /* find new file number and create new redline item name */
      hold_new=file_no = atoi(tmp);
      tmp[0]=0;
      sprintf(tmp,"%.7d",file_no);
      strcpy(new_red,old_red[i]);
      for (j=0;j<7;j++)
         new_red[j+7]=tmp[j];
   
      /* do nfm update */
		sprintf(tmp,"%d",file_no);
      tmp1[0]=attr_name; tmp2[0]=new_red;
      tmp1[1]="n_detfileno"; tmp2[1]=tmp;
      status = NFMa_update_item(cat_name,old_red[i],old_rev[i],tmp1,tmp2,2,1);
			/* the following code was added to handle redlines generated by
            XDMANDS.  File names must also change. */
      if (!status && !strcmp(&new_red[15],"000000")) {
			sprintf(sql_line,"select n_catalogno from nfmcatalogs where n_catalogname='%s'",catalog);
			status=NFMa_single_select(sql_line,tmp,&error_m);
			hold_cat=atol(tmp);
			NFMa_base_cvt(hold_old,oldred,(long)36,(long)5);
			NFMa_base_cvt(hold_cat,tmp,(long)36,(long)5);
			strcat(oldred,tmp); strcat(oldred,".dat");
			NFMa_base_cvt(hold_new,redfile,(long)36,(long)5);
			strcat(redfile,tmp); strcat(redfile,".dat");
			status=NFMa_change_file_entry(cat_name,new_red,rev
													,oldred,redfile,redfile,(char*)NULL
													,(char*)NULL,(char*)NULL);
      	if (!status) {
				NFMa_base_cvt(hold_old,oldred,(long)36,(long)5);
				NFMa_base_cvt(hold_cat,tmp,(long)36,(long)5);
				strcat(oldred,tmp); strcat(oldred,".idx");
				NFMa_base_cvt(hold_new,redfile,(long)36,(long)5);
				strcat(redfile,tmp); strcat(redfile,".idx");
				status=NFMa_change_file_entry(cat_name,new_red
												,rev,oldred,redfile,redfile
												,(char*)NULL,(char*)NULL,(char*)NULL);
				}
			}
      }

   for (i=0;i<redlines;i++) {
      free(old_red[i]);
      free(old_rev[i]);
		}
   free(old_red);
   free(old_rev);
   return(status);
}


/******************************************************************************
Doc:    NFMa_dmd_checkin

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Rob Whitesell

Date:   July 27, 1992

Description:
		Performs the same function as NFMa_checkin_mult_item but without the 
			double pointers that give some people so much trouble.
		This also updates the d_ table that is so important in the DMANDS world.
		'buffer' should be of the following form:
			attributeA\1valueA1\1valueA2\1valueAN\1..attributeN\1valueN1\n..valueNN


Examples:
		status = NFMa_dmd_checkin(catalog,co_sa_name,att_count,file_count,buffer)

Return Status:
		0			success
		<non 0>	NFM error code
		-1			required info (co file names, ci sa nums, file types, item name,
                              item_rev) not found
		-2       other error occurred

History:
  08/28/92  wrw  -fixed bug with d_ table, added 'desc' to order by on fileno
                    selection of rr file.
  09/01/93  wrw  -removed a check that was causing the checkin to show failure
                    if the d_ table was not present.

******************************************************************************/

long	NFMa_dmd_checkin(catalog,item_name,item_rev,co_sa_name,att_count
                      ,file_count,buffer)
	char *catalog;		/* I - catalog to checkin to. */
	char *item_name;	/* I - name of the item to checkin */
	char *item_rev;	/* I - revision of the item to checkin */
	char *co_sa_name;	/* I - name of checkout storage area */
	long  att_count;	/* I - number of attribute/value clumps */
	long  file_count;	/* I - number of value per attribute */
	char *buffer;		/* I - attribute and value clumps. */
{
char **co_files=NULL;
char **ci_files=NULL;
char **cisanos=NULL;
char **file_types=NULL;
char **descriptions=NULL;
long i,j,status,refno;
char *buff,*s,*att,*error_m;
char sql[256],value[32];

   NFM2_clear_messages("NFMa_dmd_checkin");

	co_files = (char **) malloc (file_count * sizeof(char*));
	ci_files = (char **) malloc (file_count * sizeof(char*));
	cisanos = (char **) malloc (file_count * sizeof(char*));
	file_types = (char **) malloc (file_count * sizeof(char*));
	descriptions = (char **) malloc (file_count * sizeof(char*));

   if (!co_files || !ci_files || !cisanos || !file_types || !descriptions) {
   	NFM2_debug_message("Exiting NFMa_dmd_checkin - status = -2");
		return(-2);
		}

	for (i=0;i<file_count;i++)
		co_files[i]=ci_files[i]=cisanos[i]=file_types[i]=descriptions[i]=0;

	s=buff=strdup(buffer);
	for (i=0;i<att_count;i++) {
		att=s;
		s=strchr(s,'\1'); if (s) {*s=0;s++;}
		for (j=0;j<file_count;j++) {
			if (!strcmp(att,"n_cofilename")) co_files[j]=s;
			else if (!strcmp(att,"n_cifilename")) ci_files[j]=s;
			else if (!strcmp(att,"n_cisano")) cisanos[j]=s;
			else if (!strcmp(att,"n_filetype")) file_types[j]=s;
			else if (!strcmp(att,"description")) descriptions[j]=s;
			s=strchr(s,'\1'); if (s) {*s=0;s++;}
			}
		}

	if (!co_files[0] || !cisanos[0]) {
		free(co_files); free(ci_files); free(cisanos); free(file_types);
		free(descriptions);free(buff);
   	NFM2_debug_message("Exiting NFMa_dmd_checkin - status = -1");
		return(-1);
		}

	status = NFMa_checkin_mult_item(catalog,item_name,item_rev,co_sa_name
							,(char*)NULL,(char*)NULL,(char*)NULL,(char*)NULL,file_count
							,((co_files[0])?co_files:(char**)NULL)
							,((ci_files[0])?ci_files:(char**)NULL)
							,((cisanos[0])?cisanos:(char**)NULL)
							,((file_types[0])?file_types:(char**)NULL)
							,(char**)NULL);

	if (status) {
		free(co_files); free(ci_files); free(cisanos); free(file_types);
		free(descriptions);free(buff);
	  	NFM2_format_debug_message("Exiting NFMa_dmd_checkin - status = %D"
  	                          ,status);
		return(status);
		}

	for (i=0;i<file_count;i++) {
		refno=0;
		if (file_types[i]) {
			if (!strcmp(file_types[i],"BLKRR") || !strcmp(file_types[i],"CLRRR"))
				continue;
			if (!strcmp(file_types[i],"BLKIM"))
				if ((i+1)<file_count && file_types[i+1] 
											&& !strcmp(file_types[i+1],"BLKRR")) {
               /* set refno to file no */
					sprintf(sql,"select n_fileno,n_fileversion from f_%s,%s where n_itemno=n_itemnum and n_itemname='%s' and n_itemrev='%s' and n_cofilename='%s' order by n_fileversion desc"
							,catalog,catalog,NFMa_ticked(item_name)
							,NFMa_ticked(item_rev),NFMa_ticked(co_files[i+1]));
					status=NFMa_single_select(sql,value,&error_m);
					refno=atol(value);
					}
			if (!strcmp(file_types[i],"CLRIM"))
				if ((i+1)<file_count && file_types[i+1] 
											&& !strcmp(file_types[i+1],"CLRRR")) {
               /* set refno to file no */
					sprintf(sql,"select n_fileno,n_fileversion from f_%s,%s where n_itemno=n_itemnum and n_itemname='%s' and n_itemrev='%s' and n_cofilename='%s' order by n_fileversion desc"
							,catalog,catalog,NFMa_ticked(item_name)
							,NFMa_ticked(item_rev),NFMa_ticked(co_files[i+1]));
					status=NFMa_single_select(sql,value,&error_m);
					refno=atol(value);
					}
			if (status) {
				free(co_files); free(ci_files); free(cisanos); free(file_types);
				free(descriptions);free(buff);
	  			NFM2_format_debug_message("Exiting NFMa_dmd_checkin - status = %D"
  	     	                     	,status);
				return(status);
				}
			}
		status = NFMa_write_d_(catalog,item_name,item_rev,co_files[i],1,0
                            ,(int)refno,descriptions[i],&error_m);
/* 
  removing this check as d_ is not a requirement, and checkin should not 
fail as a result of this failure
wrw-9/1/93

		if (status) {
			free(co_files); free(ci_files); free(cisanos); free(file_types);
			free(descriptions);free(buff);
	  		NFM2_format_debug_message("Exiting NFMa_dmd_checkin - status = %D"
  	                          	,status);
			return(status);
			}
*/
		}

	status=NFMa_upd_redlines(catalog,item_name,item_rev);

	free(co_files); free(ci_files); free(cisanos); free(file_types);
	free(descriptions);free(buff);

	NFM2_format_debug_message("Exiting NFMa_dmd_checkin - status = %D"
  	                          	,0);
	return(0);
}

#ifdef	BLOCKED_SQL
/******************************************************************************

Doc:    SS_sql

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: NFM2_stuff.c

Author: Sukumar Devineni

Date:   July 30, 1992

Description:
        This function performs any desired sql statement.
        Any results are returned in 'buffer', bound by 'max_rows'.
        If an error ocurrs, 'error_message' is allocated and contains text
           explaining the error.

	This function supports fully automatic Blocking cursor management.
	All previous functionality is supported.

	To use the blocking mechanism, the leading characters in the SQL
	statement are checked for
		"#?"	Where ? is the Cursor Number 1 - 26.  This opens
			the specified cursor for initial data retrieval.
		"+?"	Where ? is the Cursor Number 1 - 26.  This retrieves
			additional data from specified cursor.
		"!"	Closes all active cursors.
		"??"	Returns Cursor Information for specified cursor.
		

Examples:
          status = SS_sql(buffer,
                          sql_stmt,
                          buffsize,
                          max_rows,
                          error_message);

Return Status:
         0         - success
         any error status returned by NFMR functions on failure.

History:
  12/05/91  wrw  -all NFM functs consolidated and given standard headers

******************************************************************************/
long	SS_sql(buf,sql_statement,bufsize,maximum_rows,Error_Message)
char	*sql_statement;
long	*bufsize, maximum_rows;
char	*buf;
char	**Error_Message;
{
	long	NoMore,select,status,*loc,items,value,index,dindex,loop,rows,CursorNumber;
	char	*pointer,*a, *data, **ptr, expected_bufsize[12], sql_stmt[32768];
	short	*sptr;
	NFM2_clear_messages("SS_sql");
	sprintf(expected_bufsize,"%d",(long)(*bufsize * 1));
	index = dindex = *bufsize = 0;	value = 0;	loc = (long *) buf;	*(loc++) = 0;	*(loc++) = 0;	*(loc++) = 0;	*bufsize = 3*sizeof(long);
	if (sql_statement[0] == '@')	{memset(sql_stmt,32,sizeof(sql_stmt));sql_stmt[sizeof(sql_stmt)-1]=0;SS_load_sql_statement(&sql_statement[1],sql_stmt);}
	else				{strcpy(sql_stmt,sql_statement);}
	select = SQL_Check_For_Select(sql_stmt);
	if (sql_stmt[0] == '+')
		{
		pointer = (char *)strchr(sql_stmt,' ');	if (pointer != NULL) *pointer = '\0';	pointer++;	sscanf(&sql_stmt[1],"%d",&CursorNumber);
		NFM2_format_debug_message("SS_sql - Requesting Additional Data From Specified Cursor Number - %d",CursorNumber);
		CursorNumber = SQL_get_valid_cursor_number(CursorNumber);
		if (CursorSpecificSqlStatement[CursorNumber] != (char *)NULL)
			{
			NFM2_format_debug_message("Cursor %d Is Open - Additional Data May Be Available",CursorNumber);
			if (sql_buffer != NULL)		{MEMclose(&sql_buffer);	NFM2_check_status(status,MEM_SUCCESS,"MEMclose");}
			IssueAutoCommitStatement = 1;
			NFM2_format_debug_message("Calling NFMRsql_query_cursor with Cursor %d For %d Additional Rows - Expected Size Of Buffer <%s>",CursorNumber,SpecifiedRowCount[CursorNumber],expected_bufsize);
			status = NFMRsqlquery_cursor("",expected_bufsize,SpecifiedRowCount[CursorNumber],CursorNumber,&sql_buffer);
			}
		else
			{
			NFM2_format_debug_message("Cursor %d Is Currently Closed - Request For Additional Data Ignored - Returning -1",CursorNumber);
			index = dindex = *bufsize = 0;	value = 0;	loc = (long *) buf; *(loc++) = 0; *(loc++) = 0; *(loc++) = 0;	*bufsize = 3*sizeof(long);
			*(long *)buf = -1;	return -1L;
			}
		}
	else if (sql_stmt[0] == '?')
		{
		pointer = (char *)strchr(sql_stmt,' ');	if (pointer != NULL) *pointer = '\0';	pointer++;	sscanf(&sql_stmt[1],"%d",&CursorNumber);
		NFM2_format_debug_message("SS_sql - Requesting Status Of Cursor Number - %d",CursorNumber);
		CursorNumber = SQL_get_valid_cursor_number(CursorNumber);
		index = dindex = *bufsize = 0;	value = 0;	loc = (long *) buf; *(loc++) = 0; *(loc++) = 0; *(loc++) = 0;	*bufsize = 3*sizeof(long);
		if (CursorSpecificSqlStatement[CursorNumber] != (char *)NULL)
			{
			NFM2_format_debug_message("Cursor %d Is Currently Open - Returning 0",CursorNumber);
			*(long *)buf = 0;	return 0L;
			}
		else
			{
			NFM2_format_debug_message("Cursor %d Is Currently Closed - Returning -2",CursorNumber);
			*(long *)buf = -2;	return -2L;
			}
		}
	else if (sql_stmt[0] == '#')
		{
		pointer = (char *)strchr(sql_stmt,' ');	if (pointer != NULL) *pointer = '\0';	pointer++;	sscanf(&sql_stmt[1],"%d",&CursorNumber);
		NFM2_format_debug_message("SS_sql - Requesting Data From Specified Cursor Number - %d",CursorNumber);
		CursorNumber = SQL_get_valid_cursor_number(CursorNumber);
		SQL_Free_Cursor(CursorNumber);
		if (sql_buffer != NULL)		{MEMclose(&sql_buffer);	NFM2_check_status(status,MEM_SUCCESS,"MEMclose");}
		IssueAutoCommitStatement = 1;
		NFM2_format_debug_message("Calling NFMRsql_query_cursor With Cursor %d For <%d> Rows - Expected Size Of Buffer <%s>",CursorNumber,maximum_rows,expected_bufsize);
		NFM2_format_debug_message("SS_sql - SQL Statement <%s>",pointer);
		status = NFMRsqlquery_cursor(pointer,expected_bufsize,maximum_rows,CursorNumber,&sql_buffer);
		NFM2_format_debug_message("Status From NFMRsqlquery_cursor - %D",status);
		SpecifiedRowCount[CursorNumber] = maximum_rows;
		}
	else if (sql_stmt[0] == '!')
		{
		for (loop = 0; loop <= 26; loop++)	{SQL_Free_Cursor(SQL_get_valid_cursor_number(loop));}
		if (sql_buffer != NULL)			{MEMclose(&sql_buffer);	NFM2_check_status(status,MEM_SUCCESS,"MEMclose");}
		IssueAutoCommitStatement = 1;
		index = dindex = *bufsize = 0;	value = 0;	loc = (long *) buf; *(loc++) = 0; *(loc++) = 0; *(loc++) = 0;	*bufsize = 3*sizeof(long);
		status = -7777L;	*(long *)buf = status;	*Error_Message = (char *)NULL;
		return status;
		}
	else if (select == 0)
		{
		CursorNumber = SQL_get_valid_cursor_number(0);	pointer = (char *)sql_stmt;	SQL_Free_Cursor(CursorNumber);
		if (sql_buffer != NULL)		{MEMclose(&sql_buffer);	NFM2_check_status(status,MEM_SUCCESS,"MEMclose");}
		IssueAutoCommitStatement = 1;
		NFM2_format_debug_message("Calling NFMRsql_query_cursor With Cursor %d For <%d> Rows - Expected Size Of Buffer <%s>",CursorNumber,maximum_rows,expected_bufsize);
		NFM2_format_debug_message("SS_sql - SQL Statement <%s>",pointer);
		status = NFMRsqlquery_cursor(sql_stmt,expected_bufsize,maximum_rows,CursorNumber,&sql_buffer);
		SpecifiedRowCount[CursorNumber] = maximum_rows;
		}
	else
		{
		index = dindex = *bufsize = 0;	value = 0;	loc = (long *) buf; *(loc++) = 0; *(loc++) = 0; *(loc++) = 0;	*bufsize = 3*sizeof(long);
		if (IssueAutoCommitStatement != 0)
			{
			for (loop = 0; loop <= 26; loop++)	{SQL_Free_Cursor(SQL_get_valid_cursor_number(loop));}
			if (sql_buffer != NULL)			{MEMclose(&sql_buffer);	NFM2_check_status(status,MEM_SUCCESS,"MEMclose");}
			status = NFMRsqlstmt("set transaction autocommit on");
			NFM2_format_debug_message("status after NFMRsqlstmt = %D\nsql = <set transaction autocommit on>",status);
			IssueAutoCommitStatement = 0;
			}
		status = NFMRsqlstmt(sql_stmt);
		NFM2_format_debug_message("status after NFMRsqlstmt = %D\nsql = <%s>",status,sql_stmt);
		if (status != NFM2_check_status(status,NFM_SUCCESS,"NFMRsqlstmt"))	{*(long *)buf = status;	*Error_Message = (char *)NFM_Error_Messages[(NFM_Messages-1)];	return status;}
		else									{*Error_Message = (char *)NFM_Error_Messages[(NFM_Messages-1)];	return 0L;}
		}
	NFM2_format_debug_message("SS_sql - Status From NFMRsqlquery_cursor - %D",status);
	index = dindex = *bufsize = 0;	value = 0;	loc = (long *) buf; *(loc++) = 0; *(loc++) = 0; *(loc++) = 0;	*bufsize = 3*sizeof(long);
	NumberOfRowsRetrieved[CursorNumber] = 0;	*(long *)buf = status;	NoMore = 0;
	if (status == NFM_I_NO_MORE_BUFFERS)
		{
		NFM2_format_debug_message("SS_sql - Status %D From NFMRsqlquery_cursor Indicates NO MORE BUFFERS - Resetting To Successful",status);
		status = SUCCESS_CODE[NFM_SUCCESS];	NoMore = 1;
		}
	if (status != NFM2_check_status(status,NFM_SUCCESS,"NFMRsqlquery"))	{*Error_Message = (char *)NFM_Error_Messages[(NFM_Messages-1)];	return status;}
	status = MEMbuild_array(sql_buffer);	*(long *)buf = status;
	if (status != NFM2_check_status(status,MEM_SUCCESS,"MEMbuild_array"))	{*Error_Message = (char *)NFM_Error_Messages[(NFM_Messages-1)];	return value;}
	CursorSpecificSqlStatement[CursorNumber] = (char *)strdup(sql_stmt);
	rows = sql_buffer->rows;	NumberOfRowsRetrieved[CursorNumber] += sql_buffer->rows;
	*bufsize = 0;	loc = (long *) buf;	*(loc++) = 0;	*(loc++) = rows * sql_buffer->columns;	*(loc++) = sql_buffer->columns;
	items = (rows * sql_buffer->columns) + sql_buffer->columns;	sptr = (short *) loc;
	data = (char *)((long)sptr + (items * sizeof(short)));
	NFM2_format_debug_message("items = %d rows = %d out of %d (max %d)   columns = %d",items,rows,sql_buffer->rows,maximum_rows,sql_buffer->columns);
	ptr = (char **) sql_buffer->column_ptr;	*bufsize = (sizeof(long) * 3) + (items * sizeof(short));
	for (loop = 0; loop < sql_buffer->columns; loop++)		{*sptr = strlen(ptr[loop]); strcpy(data,ptr[loop]); *bufsize += (*sptr + 1); data += (*sptr + 1); sptr++;}
	ptr = (char **) sql_buffer->data_ptr;
	for (loop = 0; loop < (rows * sql_buffer->columns); loop++)	{*sptr = strlen(ptr[loop]); strcpy(data,ptr[loop]); *bufsize += (*sptr + 1); data += (*sptr + 1); sptr++;}
	*Error_Message = (char *)NFM_Error_Messages;
	if (NoMore != 0)	SQL_Free_Cursor(CursorNumber);
	return 0L;
}
#endif

long	NFM2_left_justify(str,justified)
char	*str,*justified;
{
	char	*in;
	long	loop,len;
	in = (char *)strdup(str);	len = strlen(in);
	for (loop = 0; loop < len; loop++)	{if (in[loop] != 32)    {strcpy(justified,&in[loop]);	free(in);	return 0;}}
	strcpy(justified,in);	free(in);
	return 0;
}


#ifdef	BLOCKED_SQL
long	SQL_get_valid_cursor_number(cursor)
long	cursor;
{
	if ((cursor >= 1) && (cursor <= 26))
		{
		NFM2_format_debug_message("SQL_get_valid_cursor_number - Returning %d for %d",(cursor+10),cursor);
		return (cursor+10);
		}
	else
		{
		NFM2_format_debug_message("SQL_get_valid_cursor_number - Returning 40 for %d",cursor);
		return 40L;
		}
}
#endif

#ifdef	BLOCKED_SQL
long	SQL_Free_Cursor(cursor)
long	cursor;
{
	long	status;
	NFM2_format_debug_message("SQL_Free_Cursor - %d",cursor);
	if (CursorSpecificSqlStatement[cursor] != (char *)NULL)
		{
		NFM2_format_debug_message("SS_sql - Freeing Cursor %d",cursor);
		if (sql_buffer != NULL)		{status=MEMclose(&sql_buffer);	NFM2_check_status(status,MEM_SUCCESS,"MEMclose");}
		status = NFMRsqlquery_cursor("","0",0L,cursor,&sql_buffer);
		NFM2_check_status(status,NFM_SUCCESS,"NFMRsqlquery_cursor");
		free(CursorSpecificSqlStatement[cursor]);
		CursorSpecificSqlStatement[cursor] = (char *)NULL;
		NumberOfRowsRetrieved[cursor] = 0;
		NFM2_format_debug_message("SS_sql - Cursor %d Freed",cursor);
		}
	else
		{
		NFM2_format_debug_message("SS_sql - Cursor %d Not Active - Freeing Not Required",cursor);
		CursorSpecificSqlStatement[cursor] = (char *)NULL;
		NumberOfRowsRetrieved[cursor] = 0;
		}
	return 0;
}
#endif


long	SQL_Check_For_Select(sql_stmt)
char	*sql_stmt;
{
	char	*dup,token[512];
	long	loop;
	strcpy(token,strtok(dup=(char *)strdup(sql_stmt)," ")); free(dup);
	for (loop = 0; loop < strlen(token); loop++)	{token[loop] = (char)(toupper(token[loop]));}
	NFM2_format_debug_message("SQL_Check_For_Select - <%s>",token); 
	if (strcmp(token,"SELECT") == 0)	return 0L;
	else					return 1L;
}

