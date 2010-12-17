#include "machine.h"
#include <stdio.h>
#include <errno.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMtypes.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "ERR.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000

/** DELETE THESE 
#define UTI_E_QUERY_LABEL 999
#define UTI_E_ACTIVE_ARCHIVE 998
#define UTI_E_UPDATE_F_CATALOG 997**/

long UTIdelete_label(label_buf)
MEMptr label_buf;
{
	char *fname="UTIdelete_label"; 	
	char sql_str[1024];
	char item_name[512], catalog[512], **ar_data, **cat_data, **item_data;
	char label[512], table_name[512];
	char **label_data;
	int total_elems=0, i, count;
	long status;
	MEMptr ar_buffer=NULL, cat_buffer=NULL, item_buffer=NULL;
    
	_UTIdebug(( fname, "%s\n", "Entering ..." ));

	status = MEMbuild_array(label_buf);
	if(status != MEM_S_SUCCESS)
	{
	      _UTIdebug(( fname, "MEMbuild failed <0x%.8x>", status));
	      return(status);
	}

	label_data = (char **)label_buf->data_ptr;

    for(count=0;count<label_buf->rows;count++)
    {

	strcpy(label, label_data[count]);

	_UTIdebug(( fname, "label  : <%s>\n", label ));

	sprintf(sql_str, "SELECT DISTINCT b.n_itemstate, b.n_itemno, b.n_catalogno, b.n_restoredate FROM nfmarchives a, nfmsavesets b WHERE a.n_label='%s' AND a.n_archiveno=b.n_archiveno", label);
	status = SQLquery(sql_str, &ar_buffer, BUFFER_SIZE);

	if( status != SQL_S_SUCCESS )
	{
		ERRload_struct( UTI, UTI_E_QUERY_LABEL, "%s", label );
		MEMclose( &ar_buffer );
		return( UTI_E_QUERY_LABEL);
	}

	status = MEMbuild_array( ar_buffer );
	if( status != MEM_S_SUCCESS )
	{
		_UTIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		return( NFM_E_MEM );
	}
	ar_data = (char**)ar_buffer->data_ptr;

	total_elems = ar_buffer->rows * ar_buffer->columns ;

	strcpy(item_name, "");
	strcpy(catalog, "");
	for(i=0;i< total_elems;i+= ar_buffer->columns)
	{
	/**  If the label has ARCHIVED items active OR
			      PENDING archives to be done OR
			      RESTORE date is NULL i.e., archive/backup
			      has never been restored
	     then 	ERROR out
	***/
		
	     if((strcmp(ar_data[i],"A") == 0) || 		
	     	(strcmp(ar_data[i],"P") == 0) || 		
		(strlen(ar_data[i+3]) == 0))
	     {
		/** Get catalog name **/
		sprintf(sql_str,"SELECT n_catalogname FROM nfmcatalogs WHERE n_catalogno = %s", ar_data[i+2]);
		status = SQLquery(sql_str, &cat_buffer, BUFFER_SIZE);
		status = MEMbuild_array( cat_buffer );
		if( status != MEM_S_SUCCESS )
		{
		     _UTIdebug(( fname,"MEMbuild failed<0x%.8x>\n", status));
		     /**ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		      return( NFM_E_MEM );**/
		} 
		else
		{
		     cat_data = (char **)cat_buffer->data_ptr;
		     strcpy(catalog, cat_data[0]);
		     MEMclose(&cat_buffer);
	 	}
			
	   /** Get the item name from catalog and report the error **/

	        if(strcmp(catalog, "") != 0)
		{
		     sprintf(sql_str,"SELECT n_itemname FROM %s WHERE n_itemno = %s", catalog, ar_data[i+1]);
		     status = SQLquery(sql_str, &item_buffer, BUFFER_SIZE);
		     status = MEMbuild_array( item_buffer );
		     if( status != MEM_S_SUCCESS )
		     {
			_UTIdebug(( fname,"MEMbuild failed<0x%.8x>\n", status));
			/**ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
			   return( NFM_E_MEM );**/
		     }
		     else
		     {
			item_data = (char **)item_buffer->data_ptr;
			strcpy(item_name, item_data[0]);
		    	MEMclose(&item_buffer);
		     }
		}
			
		ERRload_struct( NFM, UTI_E_ACTIVE_ARCHIVE, "%s%s",
							catalog,item_name);
		MEMclose(&ar_buffer);
		return(UTI_E_ACTIVE_ARCHIVE);
	    }
	}
	MEMclose(&ar_buffer);

	sprintf(sql_str, "SELECT DISTINCT c.n_catalogname, c.n_catalogno FROM nfmarchives a, nfmsavesets b,nfmcatalogs c WHERE a.n_label='%s' AND a.n_archiveno=b.n_archiveno AND b.n_catalogno=c.n_catalogno", label);

	status = SQLquery(sql_str, &ar_buffer, BUFFER_SIZE);

	if( status != SQL_S_SUCCESS )
	{
		ERRload_struct( UTI, UTI_E_QUERY_LABEL, "%s", label );
		MEMclose( &ar_buffer );
		return( UTI_E_QUERY_LABEL);
	}

	status = MEMbuild_array( ar_buffer );
	if( status != MEM_S_SUCCESS )
	{
		_UTIdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		return( NFM_E_MEM );
	}
	ar_data = (char**)ar_buffer->data_ptr;

	total_elems = ar_buffer->rows * ar_buffer->columns ;

/*** SET AUTO COMMIT OFF **/
	status = NFMset_autocommit_off(0);
	if(status != NFM_S_SUCCESS)
	{
		_UTIdebug((fname, "NFMset_autocommit_off, <0x%.8x>\n", status));
		return( status );
	}
	
	for(i=0;i< total_elems;i+= ar_buffer->columns)
	{
		/**LOCK TABLE **/
		sprintf(table_name, "f_%s", ar_data[i]);
		status = NFMlock_table(table_name);
		if(status != NFM_S_SUCCESS)
		{
    			_UTIdebug(( fname, "Lock f_%s failed\n", ar_data[i]));
			NFMrollback_transaction(0);
			MEMclose(&ar_buffer);
			return(status);
		}
		sprintf(sql_str, "UPDATE f_%s SET n_archiveno = NULL WHERE n_archiveno IN (SELECT n_archiveno FROM nfmarchives WHERE n_label='%s')", 
		ar_data[i], label);  
		status = SQLstmt(sql_str);
		if((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
		{
			/** ROLL BACK TRANSACTION**/
    			_UTIdebug((fname, "Update failed in f_%s, status <0x%.8x>\n",ar_data[i], status));
			NFMrollback_transaction(0);
			ERRload_struct( UTI, UTI_E_UPDATE_F_CATALOG, 
							"f_%s", ar_data[i] );
			MEMclose( &ar_buffer );
			return( UTI_E_UPDATE_F_CATALOG);
		}
	}  
	sprintf(sql_str, "DELETE FROM nfmsavesets WHERE n_archiveno IN (SELECT n_archiveno FROM nfmarchives WHERE n_label='%s')", label);  
	status = SQLstmt(sql_str);
	if((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
		/** ROLL BACK TRANSACTION**/
    		_UTIdebug((fname,"Delete failed for nfmsavesets, status <0x.%8x>\n", status));
		NFMrollback_transaction(0);
		ERRload_struct( UTI, UTI_E_UPDSAV, "", NULL);
		MEMclose( &ar_buffer );
		return( UTI_E_UPDSAV);
	}
	sprintf(sql_str, "DELETE FROM nfmarchives WHERE n_label='%s'",label); 
	status = SQLstmt(sql_str);
	if((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
    		_UTIdebug((fname,"Delete failed for nfmarchives, status <0x.%8x>\n", status));
		/** ROLL BACK TRANSACTION**/
		NFMrollback_transaction(0);
		ERRload_struct( UTI, UTI_E_UPDARCHIVES, "", NULL );
		MEMclose( &ar_buffer );
		return( UTI_E_UPDARCHIVES);
	}

        /** COMMIT WORK ***/
        status = NFMset_autocommit_on (0) ;
        if (status != NFM_S_SUCCESS)
        {
               MEMclose (&ar_buffer);
               NFMrollback_transaction (0);
               return (status) ;
       }	
   }/** For all labels **/

    	_UTIdebug(( fname, "%s\n", "Returning SUCCESS ... " ));
    	return (UTI_S_SUCCESS); 
}
/*******************************
long UTIarchive_files( server, env, user, password, sa_num, label, file_info,
		       out_list )
    char 	*server;
    char	*env;
    char 	*user;
    char	*password;
    char 	*sa_num;
    char	*label;
    MEMptr	file_info;
    MEMptr	*out_list;
{
    int		i;
    int		sa_no;
    int		link_cnt;
    int		link_no;
    int		first_time=0;

    long	status;
    long	cmd_status;
 
    char	**data_ptr;
    char 	*passwd;

    UTIpending  link;
    UTIpending  savedlist;
    UTIpending  listend;
    UTIpending  prev;
    UTIpending  UTImake_list();
    UTIpending  savedflist;

    static char *fname = "UTIarchive_files";

    savedlist = listend = NULL;
    UTI_ERR_BUFFER	= NULL;
    UTI_MSG_BUFFER      = NULL;

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    UTIuser_id  = 0;
    UTIserver= strcpy( (char*)malloc(strlen(server)+1), server );
    UTIenv   = strcpy( (char*)malloc(strlen(env)+1), env );
    UTIuser  = strcpy( (char*)malloc(strlen(user)+1), user );
    passwd   = strcpy( (char*)malloc(strlen(password)+1), password );
    UTIpasswd= (char*)malloc(50);
    NFMencrypt( passwd, UTIpasswd );
    sa_no    = atoi( sa_num );

    _UTIdebug(( fname, "server : <%s>\n", UTIserver ));
    _UTIdebug(( fname, "env    : <%s>\n", UTIenv ));
    _UTIdebug(( fname, "user   : <%s>\n", UTIuser ));
    _UTIdebug(( fname, "passwd : <%s>\n", UTIpasswd ));
    _UTIdebug(( fname, "sa num : <%d>\n", sa_no ));
    _UTIdebug(( fname, "label  : <%s>\n", label ));

/ *  Set some global information * /
    NFMload_user_info ("nfmadmin");

    status = MEMbuild_array( file_info );
    if (status != MEM_S_SUCCESS)
    {
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    data_ptr = (char**)file_info->data_ptr;
    _UTIdebug(( fname, "file links : <%d>\n", file_info->rows ));
    link_cnt = file_info->rows;
    if( link_cnt == 0 )
    {
	ERRload_struct( UTI, UTI_E_NO_FILES_CHOSEN, "%s", "ARCHIVE" );
	return( UTI_E_NO_FILES_CHOSEN );
    }
/ *  Now match chosen link numbers with the original linked list of
 *  flagged files.
 * /
    savedflist = UTIflist;
    for( i=0; i<link_cnt; ++i )
    {
	prev = NULL;
	first_time = 0; / * Inside the big If for the first time * /
	link_no = atoi( data_ptr[i] );
	UTIflist = savedflist;
	while( UTIflist != NULL )
	{
	    _UTIdebug((fname, "Flist->state = <%d>\n", UTIflist->state));
	    if( (link_no == UTIflist->state) ||

		 ((prev != NULL) &&
		  (UTIflist->cat.val == prev->cat.val) &&
	 	  (UTIflist->item.val == prev->item.val) &&
		  (UTIflist->ver == prev->ver))
	      )
	    {
		_UTIdebug((fname, "Match found: at<%d>\n", UTIflist->state));
		if((prev != NULL) && (link_no != UTIflist->state))
		    _UTIdebug((fname, "Because of Prev <%d>\n", prev->state));
		link = UTImake_list();
		UTIcopy_link( link, UTIflist );
                if( savedlist == NULL )
                    savedlist = listend = link; / * first link * /
                else
                {
                    listend->next = link;
                    listend = link;
                }
		first_time = 1;
	    } 
	    else if(first_time == 1)
	    {
		first_time = 0;
		break;
	    }
	    prev = UTIflist;
            UTIflist = UTIflist->next;
	} / * end while * /
    } / * end for * /

    status = UTIopen_buffers();
    if( status != UTI_S_SUCCESS )
	return( status );

    _UTIdebug(( fname, "Call Process_request sano <%d>, label <%s>\n", 
			sa_no, label));
    cmd_status = UTIprocess_archive( sa_no, label, savedlist );
    _UTIdebug(( fname, "UTIprocess_request : <0x%.8x>\n", cmd_status));

    if( MSG )
    {
        _UTIdebug(( fname, "Inside (MSG) \n"));
        status = MEMsplit_copy_buffer( UTI_MSG_BUFFER, out_list, 1 );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &UTI_ERR_BUFFER );
	    MEMclose( &UTI_MSG_BUFFER );
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            _UTIdebug(( fname, "MEMsplit_copy : <0x%.8x>\n", status));
            return (NFM_E_MEM);
         }
         _UTIdebug(( fname, "MEMsplit_copy : <0x%.8x>, SUCCESSFUL\n", status));
    }

    MEMclose( &UTI_MSG_BUFFER );
    MEMclose( &UTI_ERR_BUFFER );
    _UTIdebug(( fname, "Before Free UTIflist\n"));

    free( UTIflist );

    _UTIdebug(( fname, "%s\n", "Exiting ... " ));
    
    if( cmd_status != UTI_S_SUCCESS )
	return( cmd_status );

    return (NFM_S_SUCCESS); 
}
******************************************************/
