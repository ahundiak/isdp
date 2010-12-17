#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "NFMflag.h"
#include "ERR.h"
#include "DEBUG.h"

#define  PROJECT_ARCHIVE  1
#define  PROJECT_BACKUP   2
#define  PROJECT_RESTORE  3
#define  PROJECT_CANCEL   4


char	flag_s[512];
int     archive_no;
int     max_version;
int	project_no;
int	catalog_no;
int     item_no;
int     cit_no;

/*
 Doc:	NFMflag_project_archive

 Abstract:
     These functions flag projects for archive, backup or restore utilities.

 History:
     Jill McCutcheon  June 11, 1991 - Creation
 */

long NFMflag_project_archive (user_id, project_name )
  long	user_id;
  char  *project_name;
  {
	long	status;
	char	flag[4];
	
	MEMptr  attr_list=NULL;
  	MEMptr  data_list=NULL;

	static  char *fname = "NFMflag_project_archive";

	_NFMdebug(( fname, "user_id  = <%ld>\n", user_id ));
	_NFMdebug(( fname, "project  = <%s>\n", project_name ));

	/*  Get project members */

	status = _NFMquery_project_members( user_id, project_name,
					   &attr_list, &data_list );
	if( status != NFM_S_SUCCESS )
	{
 	    _NFMdebug(( fname, "_NFMquery_project_members <0x%.8x>\n",
		status ));
            ERRload_struct( NFM, NFM_E_FLAG_PROJECT, "%s",project_name );
            return( NFM_E_FLAG_PROJECT );
	}

	if((data_list == NULL) || (data_list->rows == 0))
	{
            ERRload_struct (NFM, NFM_E_NO_MEMBERS_IN_PROJECT, "%s",
		 	    project_name) ;
            return (NFM_E_NO_MEMBERS_IN_PROJECT) ;
	}
	else 
	{
	    _NFMdebug ((fname, "No. of rows in datalist = %d\n", 
				data_list->rows)); 
	}

	MEMclose( &attr_list );

	if(_NFMdebug_st.NFMdebug_on)
	{
		MEMprint_buffers("Data list", data_list, 
				 _NFMdebug_st.NFMdebug_file);
	}
        status = MEMbuild_array( data_list );
        if( status != MEM_S_SUCCESS )
        {
             ERRload_struct (NFM, NFM_E_MEM, "", NULL);
             _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
                 status));
             return (NFM_E_MEM);
        }
	strcpy( flag, "PA" );

	/*  Validate the Project Members */

	status = NFMvalidate_project_flagging( flag, data_list );
	if( status != NFM_S_SUCCESS )
	{
	    _NFMdebug(( fname, "<0x%.8x>\n", status ));
	    return (status);
	}

	/*  Flag the Project Members */

	status = NFMflag_project( flag, data_list );
	MEMclose( &data_list );
	if((status != NFM_S_SUCCESS ) && (status != NFM_I_NO_PROJ_MEMBERS))
	{
	    _NFMdebug(( fname, "<0x%.8x>\n", status ));
	    return (status);
	}

        sprintf( flag_s, 
		  "UPDATE nfmprojects SET n_pendingflag = 'A' WHERE n_projectname = '%s'",project_name);

	if(status != NFM_I_NO_PROJ_MEMBERS)
	{
        	status = SQLstmt( flag_s );
        	if( status != SQL_S_SUCCESS )
		{
            		_NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
   	    		ERRload_struct( NFM, NFM_E_FLAG_PROJECT, "%s", 
								project_name );
 	    		return( NFM_E_FLAG_PROJECT );	
		}
	}
	else
	{
		ERRload_struct(NFM, status, "%s%s", project_name, "ARCHIVE");
		return(status);
	}

	_NFMdebug(( fname, "%s\n", "Successful Project Flagging" ));

	return( NFM_S_SUCCESS );
}

long NFMflag_project_backup (user_id, project_name )
  long	user_id;
  char  *project_name;
  {
	long	status;
	char	flag[4];
	
	MEMptr  attr_list;
  	MEMptr  data_list;

	static  char *fname = "NFMflag_project_backup";

	_NFMdebug(( fname, "user_id  = <%ld>\n", user_id ));
	_NFMdebug(( fname, "project  = <%s>\n", project_name ));

	/*  Get project members */

	status = _NFMquery_project_members( user_id, project_name, &attr_list,
					   &data_list );
	if( status != NFM_S_SUCCESS )
	{
 	    _NFMdebug(( fname, "_NFMquery_project_members <0x%.8x>\n",
		status ));
            ERRload_struct( NFM, NFM_E_FLAG_PROJECT, "%s",project_name );
            return( NFM_E_FLAG_PROJECT );
	}
	
	if((data_list == NULL) || (data_list->rows == 0))
	{
            ERRload_struct (NFM, NFM_E_NO_MEMBERS_IN_PROJECT, "%s",
		 	    project_name) ;
            return (NFM_E_NO_MEMBERS_IN_PROJECT) ;
	}
	else 
	{
	    _NFMdebug ((fname, "No. of rows in datalist = %d\n", 
				data_list->rows)); 
	}

	MEMclose( &attr_list );
	strcpy( flag, "PB" );

        status = MEMbuild_array( data_list );
        if( status != MEM_S_SUCCESS )
        {
             ERRload_struct (NFM, NFM_E_MEM, "", NULL);
             _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
                 status));
             return (NFM_E_MEM);
        }

	/*  Validate the Project Members */

	status = NFMvalidate_project_flagging( flag, data_list );
	if( status != NFM_S_SUCCESS )
	{
	    _NFMdebug(( fname, "<0x%.8x>\n", status ));
	    return (status);
	}

	/*  Flag the Project Members */

	status = NFMflag_project( flag, data_list );
	MEMclose( &data_list );
	if((status != NFM_S_SUCCESS) && (status != NFM_I_NO_PROJ_MEMBERS ))
	{
	    _NFMdebug(( fname, "<0x%.8x>\n", status ));
	    return (status);
	}

        sprintf( flag_s,"UPDATE nfmprojects SET n_pendingflag = 'B' WHERE n_projectname = '%s'",project_name);

	if(status != NFM_I_NO_PROJ_MEMBERS)
	{
		status = SQLstmt( flag_s );
		if( status != SQL_S_SUCCESS )
		{
		    _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		    ERRload_struct(NFM,NFM_E_FLAG_PROJECT, "%s", project_name );
		    return( NFM_E_FLAG_PROJECT );
		}
	}
	else
	{
		ERRload_struct(NFM, status, "%s%s", project_name, "BACKUP");
		return(status);
	}

	_NFMdebug(( fname, "%s\n", "Successful Project Flagging" ));

	return( NFM_S_SUCCESS );
}

long NFMflag_project_restore (user_id, project_name )
  long	user_id;
  char  *project_name;
  {
	long	status;
	char	flag[4];
	
	MEMptr  attr_list;
  	MEMptr  data_list;

	static  char *fname = "NFMflag_project_restore";

	_NFMdebug(( fname, "user_id  = <%ld>\n", user_id ));
	_NFMdebug(( fname, "project  = <%s>\n", project_name ));

	/*  Get project members */

	status = _NFMquery_project_members( user_id, project_name, &attr_list,
					   &data_list );
	if( status != NFM_S_SUCCESS )
	{
 	    _NFMdebug(( fname, "_NFMquery_project_members <0x%.8x>\n",
		status ));
            ERRload_struct( NFM, NFM_E_FLAG_PROJECT, "%s",project_name );
            return( NFM_E_FLAG_PROJECT );
	}
	
	if((data_list == NULL) || (data_list->rows == 0))
	{
            ERRload_struct (NFM, NFM_E_NO_MEMBERS_IN_PROJECT, "%s",
		 	    project_name) ;
            return (NFM_E_NO_MEMBERS_IN_PROJECT) ;
	}
	else 
	{
	    _NFMdebug ((fname, "No. of rows in datalist = %d\n", 
				data_list->rows)); 
	}

	MEMclose( &attr_list );
	strcpy( flag, "PR" );

        status = MEMbuild_array( data_list );
        if( status != MEM_S_SUCCESS )
        {
             ERRload_struct (NFM, NFM_E_MEM, "", NULL);
             _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
                 status));
             return (NFM_E_MEM);
        }

	/*  Validate the Project Members */

	status = NFMvalidate_project_flagging( flag, data_list );
	if( status != NFM_S_SUCCESS )
	{
	    _NFMdebug(( fname, "<0x%.8x>\n", status ));
	    return (status);
	}

	/*  Flag the Project Members */

	status = NFMflag_project( flag, data_list );
	MEMclose( &data_list );
	if((status != NFM_S_SUCCESS) && (status != NFM_I_NO_PROJ_MEMBERS ))
	{
	    _NFMdebug(( fname, "<0x%.8x>\n", status ));
	    return (status);
	}

        sprintf( flag_s, "UPDATE nfmprojects SET n_pendingflag = 'R' WHERE n_projectname = '%s'",project_name);

	if(status != NFM_I_NO_PROJ_MEMBERS)
	{
           status = SQLstmt( flag_s );
           if( status != SQL_S_SUCCESS )
           {
             _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
             ERRload_struct( NFM, NFM_E_FLAG_PROJECT, "%s", project_name );
             return( NFM_E_FLAG_PROJECT );
           }
	}
	else
	{
		_NFMdebug((fname, "No members found to flag for restore\n"));
		ERRload_struct(NFM, status, "%s%s", project_name, "RESTORE");
		return(status);
	}

	_NFMdebug(( fname, "%s\n", "Successful Project Flagging" ));

	return( NFM_S_SUCCESS );
}

NFMvalidate_project_flagging( flag, data_list )
    char    *flag;
    MEMptr  data_list;
{
    long    status;

    int	    i;
    int     tot_data;

    char    **r_data;
    char    **n_data;

    MEMptr  buffer = NULL;
    
    static  char *fname = "NFMvalidate_project_flagging";

    _NFMdebug(( fname, "Flag <%s>\n", flag ));

    r_data     = (char**) data_list->data_ptr;
    tot_data = data_list->rows * data_list->columns;

    /*  Get project number */
		
    sprintf( flag_s, "SELECT n_projectno FROM nfmprojects WHERE n_projectname = '%s'", r_data[2] );
    if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
    {
        _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
	MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_FLAG_PROJECT, "%s", r_data[2] );
        return( NFM_E_FLAG_PROJECT );
    }
    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
    {
	_NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
	MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    n_data = (char **) buffer->data_ptr;
    project_no = atoi( n_data[0] );
    MEMclose( &buffer );

    /*  For each project member, validate it in the F_catalog */
    for( i=0; i<tot_data; i+=data_list->columns )
    {
        /* Get catalog number */
        sprintf( flag_s, "SELECT n_catalogno FROM nfmcatalogs WHERE n_catalogname = '%s'", r_data[i+3] );
        if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
        {
	    _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
            MEMclose (&buffer);
            ERRload_struct( NFM, NFM_E_FLAG_PROJECT, "%s", r_data[2] );
            return( NFM_E_FLAG_PROJECT );
        }
        if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
        {
            _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
            MEMclose (&buffer);
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return( NFM_E_MEM );
        }

        n_data = (char **) buffer->data_ptr;
	catalog_no = atoi( n_data[0] );
        MEMclose( &buffer );

	status = NFMvalidate_project_member( flag, r_data[i+6], r_data[i+3],
					     r_data[i+4], r_data[i+5] );
	if( status != NFM_S_SUCCESS )
	{
	    _NFMdebug(( fname, "NFMvalidate_proj_members <0x%.8x>\n",status));
	    return( status );
	}
    }

    _NFMdebug(( fname, "%s\n", "Successful Validation" ));

    return( NFM_S_SUCCESS );
}

NFMflag_project( flag, data_list )
    char    *flag;
    MEMptr  data_list;
{
    long    status, ret_status;

    int	    i;
    int     tot_data;
    int     validated, members_exist;

    char    **r_data;
    char    **n_data;
    char    checkin_status[10];

    MEMptr  buffer = NULL;
    
    static  char *fname = "NFMflag_project";

    _NFMdebug(( fname, "Flag <%s>\n", flag ));

    if (_NFMdebug_st.NFMdebug_on)
    {
    	MEMprint_buffer ("Flag data_list", data_list, 
			  _NFMdebug_st.NFMdebug_file);
    }
    
    status = MEMbuild_array (data_list);
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
        MEMclose (&buffer);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    r_data     = (char**) data_list->data_ptr;
    tot_data = data_list->rows * data_list->columns;

    ret_status = NFM_S_SUCCESS;
    members_exist = 0;

    /*  For each project member, flag it in the catalog */
    for( i=0; i<tot_data; i+=data_list->columns )
    {
	/**members_exist = 1;**/
        /* Get catalog number */
        sprintf( flag_s, "SELECT n_catalogno FROM nfmcatalogs WHERE n_catalogname = '%s'", r_data[i+3] );
        if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
        {
	    _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
            MEMclose (&buffer);
            ERRload_struct( NFM, NFM_E_FLAG_PROJECT, "%s", r_data[i+2] );
            return( NFM_E_FLAG_PROJECT );
        }
        if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
        {
            _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
            MEMclose (&buffer);
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return( NFM_E_MEM );
        }

        n_data = (char **) buffer->data_ptr;
	catalog_no = atoi( n_data[0] );
        MEMclose( &buffer );

	/*  Get the item number */

        sprintf (flag_s, "SELECT n_itemno, n_status FROM %s WHERE n_itemname = '%s' and n_itemrev = '%s'", r_data[i+3], r_data[i+4], r_data[i+5] );
        if( (status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
        {
	    _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
	    MEMclose (&buffer);
	    ERRload_struct( NFM, NFM_E_GET_ITEM_NO, "%s", r_data[i+4] );
	    return( NFM_E_GET_ITEM_NO );
        }
        if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
        {
	    _NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
	    MEMclose (&buffer);
	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    return( NFM_E_MEM );
        }

        n_data = (char **) buffer->data_ptr;
        item_no = atoi( n_data[0] );
        strcpy(checkin_status,n_data[1]);

        validated = TRUE;
	MEMclose( &buffer );

	cit_no = atoi(r_data[i+1]);

	/** 
	    Global variables project_no, catalog_no, item_no , cit_no
	    are set in various functions for the sake of the function
	    NFMflag_project_member 
	**/
	if((strcmp(checkin_status, "") == 0)       || 
           (strncmp(checkin_status, "ON", 2) == 0) ||
           (strncmp(checkin_status, "MN", 2) == 0) ||
           (strncmp(checkin_status, "SN", 2) == 0))
    	{
        	_NFMdebug((fname,"Item <%s.%s> does not have files: Skipping\n",
		r_data[i+4], r_data[i+5]));
    	}
	else
	{

		status =NFMflag_project_member( flag, r_data[i+6], r_data[i+3],
					     	     r_data[i+4], r_data[i+5] );
		if( status != NFM_S_SUCCESS )
		{
	    		_NFMdebug(( fname, "NFMflag_project_member <0x%.8x>\n", 
								status ));
	    		return( status );
		}
	/*******
		if((strcmp(flag,"PR")!=0) && (strcmp(r_data[i+6], "R")))
			members_exist = 1;
	*******/

		if((strcmp(flag,"CR")==0) && (strcmp(r_data[i+6], "R")!=0))
			members_exist = 1;
		else if((strcmp(flag,"PR")==0) && (strcmp(r_data[i+6], "R")!=0))
			members_exist = 1;
		else if(strcmp(flag, "PR") != 0)
			members_exist = 1;
	}
    }

    _NFMdebug((fname,"%s status:<0x%.8x>\n","Successful Flagging",ret_status ));

    if(members_exist)
    	return( NFM_S_SUCCESS );
    else
    {
	ret_status = NFM_I_NO_PROJ_MEMBERS;
        _NFMdebug((fname,"No members in project\n"));
	return(ret_status);
    }
}

NFMvalidate_project_member( flag, type, catalog, item, rev )
    char *flag;
    char *type;
    char *catalog;
    char *item;
    char *rev;
{
    long status, status1;

    int  i, nofilesattached;
    int  utility_flag = 0;
    int  validated;

    char **data;

    MEMptr buffer = NULL, buffer2 = NULL;

    static char *fname = "NFMvalidate_project_member";

    _NFMdebug(( fname, "Flag     <%s>\n", flag ));
    _NFMdebug(( fname, "Catalog  <%s>\n", catalog ));
    _NFMdebug(( fname, "Item     <%s>\n", item ));
    _NFMdebug(( fname, "Revision <%s>\n", rev ));

    if( strcmp( flag, "PA" ) == 0 )
    	utility_flag = PROJECT_ARCHIVE;
	
    else if( strcmp( flag, "PB" ) == 0 )
	utility_flag = PROJECT_BACKUP;

    else if( strcmp( flag, "PR" ) == 0 )
	utility_flag = PROJECT_RESTORE;

/*  Check nfmprojectcit that member is not already flagged */

    sprintf( flag_s, "SELECT n_archiveflag FROM nfmprojectcit WHERE n_projectno = %d", project_no );
    if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
    {
        _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
	MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_SQL_QUERY , NULL, NULL );
	return( NFM_E_SQL_QUERY );
    }
    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
    {
	_NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
	MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data = (char **) buffer->data_ptr;
    validated = TRUE;
    for( i=0; i<buffer->rows; ++i )
    {
	if( strcmp( data[i], "" ) == 0 )
	    continue;
	switch( utility_flag )
	{
	    case  PROJECT_ARCHIVE :
		if( ( strcmp( data[i], "PA" ) == 0 ) ||
		    ( strcmp( data[i], "PR" ) == 0 ) )
	        {
	     	   validated = FALSE;
	           status = NFM_E_PROJECT_MEMBER_FLAGGED;
		}
		else if( ( strcmp( data[i], "PB" ) == 0 ) &&
			 ( strcmp( type, "O" ) == 0 ) )
	        {
	     	   validated = FALSE;
	           status = NFM_E_PROJECT_MEMBER_FLAGGED;
		}
	        break;

	    case  PROJECT_BACKUP :
		if( ( strcmp( data[i], "PA" ) == 0 ) ||
		    ( strcmp( data[i], "PR" ) == 0 ) )
	        {
	     	   validated = FALSE;
	           status = NFM_E_PROJECT_MEMBER_FLAGGED;
		}
		else if( ( strcmp( data[i], "PB" ) == 0 ) &&
			 ( strcmp( type, "O" ) == 0 ) )
	        {
	     	   validated = FALSE;
	           status = NFM_E_PROJECT_MEMBER_FLAGGED;
		}
		break;

	    case  PROJECT_RESTORE :
		if( ( strcmp( data[i], "PA" ) == 0 ) ||
		    ( strcmp( data[i], "PR" ) == 0 ) )
	        {
	     	   validated = FALSE;
	           status = NFM_E_PROJECT_MEMBER_FLAGGED;
		}
		else if( ( strcmp( data[i], "PB" ) == 0 ) &&
			 ( strcmp( type, "O" ) == 0 ) )
	        {
	     	   validated = FALSE;
	           status = NFM_E_PROJECT_MEMBER_FLAGGED;
		}
		break;

	    default :
	        _NFMdebug(( fname, "%s\n", "Illegal Flag" ));
	        validated = FALSE;
	        status = NFM_E_ILLEGAL_PROJECT_FLAG;
		break;
	}
    }    
    MEMclose( &buffer );

    if( !validated )
    {
	_NFMdebug(( fname, "Could not Validate %s.%s.%s\n",
		    catalog, item, rev ));
	ERRload_struct( NFM, status, "%s%s%s", catalog, item, rev );
	return( status );
    }

    sprintf (flag_s, "SELECT n_itemno,n_archivestate,n_status,n_pendingflag FROM %s WHERE n_itemname = '%s' and n_itemrev = '%s'", catalog, item, rev);
    if( (status = SQLquery (flag_s, &buffer, MEM_SIZE)) != SQL_S_SUCCESS)
    {
	_NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
	MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_GET_ITEM_NO, "%s", item);
	return( NFM_E_GET_ITEM_NO );
    }

    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
    {
	_NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
	MEMclose (&buffer);
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data = (char **) buffer->data_ptr;
    item_no = atoi( data[0] );
    validated = TRUE;

    switch( utility_flag )
    {
	case  PROJECT_ARCHIVE :
 	    /* Check Archive State */
       	    if( strcmp( data[1], "A") == 0 )
	    {
	        validated = FALSE;
	        status = NFM_E_PROJECT_MEMBER_ARCHIVED;
	    }

    	    /* Check Checkout Flag */
	    if( strcmp( data[2], "O") == 0 )
	    {
	        validated = FALSE;
    	        status = NFM_E_PROJECT_MEMBER_CHECKED_OU;
	    }
	
	    /* Check Pending Flag */
	    if( strcmp( flag, data[3] ) == 0 )
	    {
		status = NFM_E_PROJECT_MEMBER_FLAGGED;
		validated = FALSE;
	    }
	    break;

	case  PROJECT_BACKUP :

 	    /* Check Archive State */
	    if( strcmp( data[1], "A") == 0 )
	    {
	        validated = FALSE;
	        status = NFM_E_PROJECT_MEMBER_ARCHIVED;
	    }

 	    /* Check Checkout Flag */
	    if( strcmp( data[2], "O") == 0 )
	    {
	        validated = FALSE;
	        status = NFM_E_PROJECT_MEMBER_CHECKED_OU;
	    }

            /* Check Pending Flag */
            if( strcmp( flag, data[3] ) == 0 )
            {
                status = NFM_E_PROJECT_MEMBER_FLAGGED;
                validated = FALSE;
            }
	    break;

        case  PROJECT_RESTORE :
	    /* Check Archive State */
	    nofilesattached = 0;
	    if( ( strcmp( data[1], "A") == 0 ) ||
	        ( strcmp( data[1], "B") == 0 ) )
	        validated = TRUE;
	    else
	    {

		sprintf(flag_s, "SELECT n_fileno FROM f_%s WHERE n_itemnum=%d AND n_fileversion IN (SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum=%d) AND n_fileversion > 0", catalog, item_no, catalog, item_no);

    		status = SQLquery (flag_s, &buffer2, MEM_SIZE);

	/** If the project member has no files archived, 
				validate is successuful**/

		if(status == SQL_I_NO_ROWS_FOUND) 
		{
	        	validated = TRUE;
			nofilesattached = 1;
		}
		else if(status == SQL_S_SUCCESS)
		{
	        	validated = FALSE;
	        	status = NFM_E_PROJECT_MEMBER_NOT_ARCHIV;
		}
		else
    		{
			_NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
			MEMclose (&buffer);
			ERRload_struct( NFM, NFM_E_GET_ITEM_NO, "%s", item);
			return( NFM_E_GET_ITEM_NO );
    		}
		MEMclose(&buffer2);

	    }

 	    /* Check Checkout Flag */
	    if( strcmp( data[2], "O") == 0 )
	    {
  	        validated = FALSE;
	        status = NFM_E_PROJECT_MEMBER_CHECKED_OU;
	    }

            /* Check Pending Flag */
            if( strcmp( flag, data[3] ) == 0 )
            {
                status = NFM_E_PROJECT_MEMBER_FLAGGED;
                validated = FALSE;
            }

   	/*  Need to make sure this entry has an archive_no in the nfmprojectcit
	 *  table.
	 */		

            MEMclose (&buffer);

	    sprintf( flag_s, "SELECT n_archiveno FROM nfmprojectcit WHERE n_projectno = %d AND n_catalogno = %d AND n_itemno = %d", 
		project_no, catalog_no, item_no );

            status1=SQLquery( flag_s, &buffer, MEM_SIZE );

	/** If the item doesn't have files and no archive entry, it is OK **/
            if((status1 == SQL_I_NO_ROWS_FOUND) && nofilesattached)
			;
            else if(status1 != SQL_S_SUCCESS)
	    {
	        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status1));
                MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	   	return( NFM_E_SQL_QUERY );
 	    }
  	    if ((status1 = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
            {
	        _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status1));
                MEMclose (&buffer);
       		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		return( NFM_E_MEM );
            }

	    data = (char **) buffer->data_ptr;
	    archive_no = atoi( data[0] );
	    if( (archive_no < 1) && (nofilesattached==0))
	    {
		_NFMdebug(( fname, "Archive Number <%d>\n", archive_no ));
		validated = FALSE;
		status = NFM_E_PROJECT_MEMBER_NOT_ARCHIV;
	    }
  	    break;

	default :
	    _NFMdebug(( fname, "%s\n", "Illegal Flag" ));
	    validated = FALSE;
	    status = NFM_E_ILLEGAL_PROJECT_FLAG;
	    break;
        }

    MEMclose (&buffer);

    if( !validated )
    {
	_NFMdebug(( fname, "Could not Validate %s.%s.%s: Status <0x%.8x>\n",
		    catalog, item, rev, status ));
	ERRload_struct( NFM, status, "%s%s%s", catalog, item, rev );
	return( status );
    }
    _NFMdebug(( fname, "%s\n", "Successful Validation" ));

    return( NFM_S_SUCCESS );
}

NFMflag_project_member( flag, type, catalog, item, rev )
    char *flag;
    char *type;
    char *catalog;
    char *item;
    char *rev;
{
    long status;

    int  utility_flag = 0;
    int  i;

    char tmp_flag[5];
    char tmp_pflag[5];

    char **data;

    MEMptr buffer  = NULL;

    static char *fname = "NFMflag_project_member";

    _NFMdebug(( fname, "Flag     <%s>\n", flag ));
    _NFMdebug(( fname, "Type     <%s>\n", type ));
    _NFMdebug(( fname, "Catalog  <%s>\n", catalog ));
    _NFMdebug(( fname, "Item     <%s>\n", item ));
    _NFMdebug(( fname, "Revision <%s>\n", rev ));

    strcpy( tmp_pflag, "" );

    if( strcmp( flag, "PA" ) == 0 )
    {
    	utility_flag = PROJECT_ARCHIVE;
	strcpy( tmp_pflag, "A" );
    }
	
    else if( strcmp( flag, "PB" ) == 0 )
    {
	utility_flag = PROJECT_BACKUP;
	strcpy( tmp_pflag, "B" );
    }

    else if( strcmp( flag, "PR" ) == 0 )
    {
	utility_flag = PROJECT_RESTORE;
	strcpy( tmp_pflag, "R" );
    }
 
    else if( ( strcmp( flag, "" ) == 0 ) || 
	     ( strcmp (flag, "CR") == 0 ) )   /** Internal flag, indicates 
				                  cancel restore flag, 
						  nothing to do with the 
						  database **/
    {
	utility_flag = PROJECT_CANCEL;
   	strcpy( tmp_pflag, "" );
    }

    strcpy( tmp_flag, flag );

    switch( utility_flag )
    {
	case  PROJECT_ARCHIVE :
	/*  If the project member is referenced instead of owned --
	 *  flag it for backup
 	 */
	    if( strcmp( type, "R" ) == 0 )
	    {
		strcpy( tmp_flag, "PB" );
		strcpy( tmp_pflag, "B" );
	    }

	    sprintf( flag_s, 
		     "UPDATE %s SET n_pendingflag = '%s' WHERE n_itemno = %d",
		catalog, tmp_flag, item_no );

	    status = SQLstmt( flag_s );
	    if( status != SQL_S_SUCCESS )
	    {
	        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_PROJECT_MEMBER, "%s%s%s",
				catalog, item, rev );
                return( NFM_E_FLAG_PROJECT_MEMBER );
	    }

	    sprintf( flag_s, 
 		     "UPDATE nfmprojectcit SET n_archiveflag = '%s' WHERE n_projectno = %d AND n_catalogno = %d AND n_itemno = %d",
		tmp_pflag, project_no, catalog_no, item_no );
	break;

 	case  PROJECT_BACKUP :
	    sprintf( flag_s, 
		     "UPDATE %s SET n_pendingflag = '%s' WHERE n_itemno = %d",
		catalog, tmp_flag, item_no );

 	    status = SQLstmt( flag_s );
	    if( status != SQL_S_SUCCESS )
	    {
	        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_PROJECT_MEMBER, "%s%s%s",
				catalog, item, rev );
                return( NFM_E_FLAG_PROJECT_MEMBER );
	    }

	    sprintf( flag_s, 
 		     "UPDATE nfmprojectcit SET n_archiveflag = '%s' WHERE n_projectno = %d AND n_catalogno = %d AND n_itemno = %d",
		tmp_pflag, project_no, catalog_no, item_no );
	break;

	case  PROJECT_RESTORE :

	/*  If the project member is "Referenced", we don't flag it */ 

	    if(strcmp(type, "R") ==0)
		return(NFM_S_SUCCESS);

   	/*  Need to get the archive_no in the nfmprojectcit  table.
	 */		
	    sprintf( flag_s, "SELECT n_archiveno FROM nfmprojectcit WHERE n_projectno = %d AND n_catalogno = %d AND n_itemno = %d", 
		project_no, catalog_no, item_no );
            if((status=SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
	    {
	        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
                MEMclose (&buffer);
                ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
	        return( NFM_E_SQL_QUERY );
 	    }
  	    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
            {
	        _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
                MEMclose (&buffer);
	 	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		return( NFM_E_MEM );
            }

	    data = (char **) buffer->data_ptr;
	    archive_no = atoi( data[0] );
	    MEMclose( &buffer );

	    /*  Get ALL fileno's from nfmsavesets where catalog, item
	     *  and archive numbers match.
	     */
	    sprintf( flag_s, "SELECT n_fileno FROM nfmsavesets WHERE n_catalogno = %d AND n_itemno = %d AND n_archiveno = %d", 
		catalog_no, item_no, archive_no );
            if(( status = SQLquery( flag_s, &buffer, MEM_SIZE )) != SQL_S_SUCCESS)
	    {
	        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
                MEMclose (&buffer);
		ERRload_struct( NFM, NFM_E_SQL_QUERY, NULL, NULL );
		return( NFM_E_SQL_QUERY );
 	    }
  	    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
            {
	        _NFMdebug(( fname, "MEMbuild_array = <0x%.8x>\n", status));
                MEMclose (&buffer);
       		ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
		return( NFM_E_MEM );
            }

	    data = (char **) buffer->data_ptr;
	    for( i=0; i<buffer->rows; ++i )
	    {
		sprintf( flag_s, "UPDATE f_%s SET n_restoreflag = '%s' WHERE n_fileno = %s AND n_itemnum = %d AND n_archiveno = %d", 
			catalog, tmp_flag, data[i], item_no, archive_no );

	        status = SQLstmt( flag_s );
	        if( status != SQL_S_SUCCESS )
	        {
	            _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
	   	    ERRload_struct( NFM, NFM_E_FLAG_PROJECT_MEMBER, "%s%s%s",
		 	  	    catalog, item, rev );
		    return( NFM_E_FLAG_PROJECT_MEMBER );	
	        }
	    }

	    MEMclose( &buffer );

	    sprintf( flag_s, 
 		     "UPDATE %s SET n_pendingflag = '%s' WHERE n_itemno = %d",
		     catalog, tmp_flag, item_no );
	    status = SQLstmt( flag_s );
	    if( status != SQL_S_SUCCESS )
	    {
	        _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_PROJECT_MEMBER, "%s%s%s",
				catalog, item, rev );
		return( NFM_E_FLAG_PROJECT_MEMBER );	
	    }

	    sprintf( flag_s, 
 		     "UPDATE nfmprojectcit SET n_archiveflag = '%s' WHERE n_projectno = %d AND n_catalogno = %d AND n_itemno = %d",
		tmp_pflag, project_no, catalog_no, item_no );
	break;

 	case  PROJECT_CANCEL :

	    /** Don't cancel Restore flag if the member is referenced **/

	    if((strcmp(type, "R") ==0) && (strcmp(flag, "CR")==0))
		return(NFM_S_SUCCESS);

	    sprintf( flag_s, 
		     "UPDATE %s SET n_pendingflag = '' WHERE n_itemno = %d",
		catalog, item_no );

 	    status = SQLstmt( flag_s );
	    if( status != SQL_S_SUCCESS )
	    {
	        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_PROJECT_MEMBER, "%s%s%s",
				catalog, item, rev );
		return( NFM_E_FLAG_PROJECT_MEMBER );	
	    }

	    sprintf( flag_s,
		     "UPDATE f_%s SET n_restoreflag= '' where n_itemnum = %d",
			 catalog, item_no );
 	    status = SQLstmt( flag_s );
	    if( status != SQL_S_SUCCESS )
	    {
	        _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
		ERRload_struct( NFM, NFM_E_FLAG_PROJECT_MEMBER, "%s%s%s",
				catalog, item, rev );
		return( NFM_E_FLAG_PROJECT_MEMBER );	
	    }

/*********    sprintf( flag_s, 
 		     "UPDATE nfmprojectcit SET n_archiveflag = '' WHERE n_projectno = %d AND n_catalogno = %d AND n_itemno = %d",
		project_no, catalog_no, item_no );
*********/
	    sprintf( flag_s, 
 	    "UPDATE nfmprojectcit SET n_archiveflag = '' WHERE n_citno = %d", 
		   cit_no );

	break;
    }    

    status = SQLstmt( flag_s );
    if( status != SQL_S_SUCCESS )
    {
        _NFMdebug(( fname, "SQLquery = <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_FLAG_PROJECT_MEMBER, "%s%s%s",
			catalog, item, rev );
	return( NFM_E_FLAG_PROJECT_MEMBER );	
    }

    _NFMdebug(( fname, "%s\n", "Successful Flagging" ));

    return( NFM_S_SUCCESS );
}
