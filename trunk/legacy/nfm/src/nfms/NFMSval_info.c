#include "machine.h"
#include <stdio.h>
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000

/* 
 Doc: NFMSvalidate_info
 
 Abstract:
     This function will validate a specific type of information
     depending on the input case.  Currently supported cases are :

	NFM_VALIDATE_PROJECT
	NFM_VALIDATE_CATALOG
	NFM_VALIDATE_ITEM
	NFM_VALIDATE_SET_ITEM
	NFM_VALIDATE_SET_REV
	NFM_VALIDATE_REVISION     
	NFM_VALIDATE_SEARCH
	NFM_VALIDATE_SORT
	NFM_VALIDATE_REPORT
	NFM_VALIDATE_ST_AREA
	NFM_VALIDATE_NODE
	NFM_VALIDATE_WORKFLOW
	NFM_VALIDATE_ACL
	NFM_VALIDATE_USER

 */
 
long NFMSvalidate_info (in_list)
    MEMptr in_list;
{
    int  valid_case;
    int  flag;			/* returned flag to tell if item is a set */

    long status;
    long ret_status;

    char str[100];  
    char owner[NFM_USERNAME+1];
    char **data_ptr;
    MEMptr data_list = NULL;

    static char *fname = "NFMSvalidate_info";

    flag = 0;
    sprintf( str, "%d\1", flag );
    
    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char **) in_list->data_ptr;

    _NFMSdebug(( fname, "Case    : <%s>\n", data_ptr[0]));
    valid_case = atoi (data_ptr[0]);

    switch( valid_case )
    {
	case NFM_VALIDATE_PROJECT :
    	    ret_status = NFMvalidate_project( data_ptr[1] );
	    break;

	case NFM_VALIDATE_CATALOG :
    	    ret_status = NFMvalidate_catalog( data_ptr[1] );
	    break;

	case NFM_VALIDATE_ITEM :
    	    ret_status = NFMvalidate_item( data_ptr[1], data_ptr[2]);

	    break;

	case NFM_VALIDATE_REVISION :
    	    ret_status = NFMvalidate_revision( data_ptr[1],data_ptr[2],
					data_ptr[3], &flag );
	    sprintf( str, "%d\1", flag );
	    break;

	case NFM_VALIDATE_SEARCH :
    	    ret_status = NFMvalidate_search( data_ptr[1], owner );
	    sprintf( str, "%s\1", owner );
	    break;

	case NFM_VALIDATE_SORT :
    	    ret_status = NFMvalidate_sort( data_ptr[1], owner );
	    sprintf( str, "%s\1", owner );
	    break;

	case NFM_VALIDATE_ST_AREA :
    	    ret_status = NFMvalidate_st_area( data_ptr[1] );
	    break;

	case NFM_VALIDATE_WK_AREA :
    	    ret_status = NFMvalidate_working_area( data_ptr[1], owner );
	    sprintf( str, "%s\1", owner );
	    break;

	case NFM_VALIDATE_NODE :
    	    ret_status = NFMvalidate_node( data_ptr[1] );
	    break;

	case NFM_VALIDATE_SET_ITEM :
    	    ret_status = NFMvalidate_set_item( data_ptr[1],data_ptr[2] );
	    break;

	case NFM_VALIDATE_SET_REV :
    	    ret_status = NFMvalidate_set_rev( data_ptr[1],data_ptr[2],
					       data_ptr[3] );
	    break;

	case NFM_VALIDATE_WORKFLOW :
    	    ret_status = NFMvalidate_workflow( data_ptr[1] );
	    break;

	case NFM_VALIDATE_ACL :
    	    ret_status = NFMvalidate_acl( data_ptr[1], data_ptr[2] );
	    break;

	case NFM_VALIDATE_USER :
    	    ret_status = NFMvalidate_user( data_ptr[1] );
	    break;
	
	default :
	    ret_status = NFM_E_FAILURE;
    }

    _NFMSdebug(( fname, "Return Status <0x%.8x>\n", ret_status ));

    status = MEMopen (&data_list, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (data_list, "out_str", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite (data_list, str);
    if (status != MEM_S_SUCCESS)
        {
        _NFMSdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
 
    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &data_list );

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status);

    return (NFM_S_SUCCESS);
}
