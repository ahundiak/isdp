#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMflag.h"
#include "ERR.h"
#include "DEBUG.h"

char	flag_s[512];

long NFMcancel_project_archive_flag (project)
  char	*project;
  {
	long	status;
	long    user_id = 0;
	char    **data;
        MEMptr  attr_list = NULL;
        MEMptr  data_list = NULL;

	static  char *fname = "NFMcancel_project_archive_flag";

	_NFMdebug(( fname, "Project  <%s>\n", project));

        /*  See if the project is flagged */

        sprintf( flag_s,"SELECT n_pendingflag FROM nfmprojects WHERE n_projectname = '%s'",project);
        if(( status = SQLquery( flag_s, &data_list, MEM_SIZE )) != SQL_S_SUCCESS)
        {
            _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
  	    MEMclose (&data_list);
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s", project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
        }
        if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
        {
	    _NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
  	    MEMclose (&data_list);
 	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
  	    return( NFM_E_MEM );
        }

        data = (char **) data_list->data_ptr;
        if( strcmp( data[0], "A" ) != 0 )
        {
  	   MEMclose( &data_list );
  	   _NFMdebug(( fname, "%s\n", "Project is not flagged for ARCHIVE" ));
	   ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s", project );
	   return( NFM_E_CANCEL_PROJECT_FLAG );
        }

        MEMclose( &data_list );

        /*  Get project members */

        status = _NFMquery_project_members( user_id, project,
				   &attr_list, &data_list );
        if( status != NFM_S_SUCCESS )
        {
 	    _NFMdebug(( fname, "_NFMquery_project_members <0x%.8x>\n",
		status ));
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s",project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
        }

        MEMclose( &attr_list );

	/* Cancel the flag for Project Members */

	status = NFMflag_project( "", data_list );
	MEMclose( &data_list );
	if( status != NFM_S_SUCCESS )
	{
	    _NFMdebug(( fname, "<0x%.8x>\n", status ));
	    return (status);
	}

        sprintf( flag_s,"UPDATE nfmprojects SET n_pendingflag = '' WHERE n_projectname = '%s'",project);

        status = SQLstmt( flag_s );
        if( status != SQL_S_SUCCESS )
        {
            _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s", project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
        }

	_NFMdebug(( fname, "%s\n", "Successful Project Archive Cancelling" ));

	return (NFM_S_SUCCESS);
  }

long NFMcancel_project_backup_flag (project)
  char	*project;
  {
	long	status;
	long    user_id = 0;
 	char    **data;
        MEMptr  attr_list = NULL;
        MEMptr  data_list = NULL;

	static  char *fname = "NFMcancel_project_backup_flag";

	_NFMdebug(( fname, "Project  <%s>\n", project));


        sprintf( flag_s,"SELECT n_pendingflag FROM nfmprojects WHERE n_projectname = '%s'",project);
        if(( status = SQLquery( flag_s, &data_list, MEM_SIZE )) != SQL_S_SUCCESS)
        {
            _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
  	    MEMclose (&data_list);
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s", project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
        }
        if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
        {
	    _NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
  	    MEMclose (&data_list);
 	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
  	    return( NFM_E_MEM );
        }

        data = (char **) data_list->data_ptr;
        if( strcmp( data[0], "B" ) != 0 )
        {
  	   MEMclose( &data_list );
  	   _NFMdebug(( fname, "%s\n", "Project is not flagged for ARCHIVE" ));
	   ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s", project );
	   return( NFM_E_CANCEL_PROJECT_FLAG );
        }

        MEMclose( &data_list );

	/*  Get project members */

	status = _NFMquery_project_members( user_id, project,
					   &attr_list, &data_list );
	if( status != NFM_S_SUCCESS )
	{
 	    _NFMdebug(( fname, "_NFMquery_project_members <0x%.8x>\n",
		status ));
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s",project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
	}

	MEMclose( &attr_list );

	/* Cancel the flag for Project Members */

	status = NFMflag_project( "", data_list );
	MEMclose( &data_list );
	if( status != NFM_S_SUCCESS )
	{
	    _NFMdebug(( fname, "<0x%.8x>\n", status ));
	    return (status);
	}

        sprintf( flag_s,"UPDATE nfmprojects SET n_pendingflag = '' WHERE n_projectname = '%s'",project);

        status = SQLstmt( flag_s );
        if( status != SQL_S_SUCCESS )
        {
            _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s",project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
        }

	_NFMdebug(( fname, "%s\n", "Successful Project Backup Cancelling" ));

	return (NFM_S_SUCCESS);
  }

long NFMcancel_project_restore_flag (project)
  char	*project;
  {
	long	status;
	long    user_id = 0;
	char    **data;
        MEMptr  attr_list = NULL;
        MEMptr  data_list = NULL;

	static  char *fname = "NFMcancel_project_restore_flag";

	_NFMdebug(( fname, "Project  <%s>\n", project));


        sprintf( flag_s,"SELECT n_pendingflag FROM nfmprojects WHERE n_projectname = '%s'",project);
        if(( status = SQLquery( flag_s, &data_list, MEM_SIZE )) != SQL_S_SUCCESS)
        {
            _NFMdebug((fname, "SQLquery = <0x%.8x>\n", status));
  	    MEMclose (&data_list);
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s", project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
        }
        if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
        {
	    _NFMdebug((fname, "MEMbuild_array = <0x%.8x>\n", status));
  	    MEMclose (&data_list);
 	    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
  	    return( NFM_E_MEM );
        }

        data = (char **) data_list->data_ptr;
        if( strcmp( data[0], "R" ) != 0 )
        {
  	   MEMclose( &data_list );
  	   _NFMdebug(( fname, "%s\n", "Project is not flagged for RESTORE" ));
	   ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s", project );
	   return( NFM_E_CANCEL_PROJECT_FLAG );
        }

        MEMclose( &data_list );

	/*  Get project members */

	status = _NFMquery_project_members( user_id, project,
					   &attr_list, &data_list );
	if( status != NFM_S_SUCCESS )
	{
 	    _NFMdebug(( fname, "_NFMquery_project_members <0x%.8x>\n",
		status ));
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s",project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
	}

	MEMclose( &attr_list );

	/* Cancel the flag for Project Members */

	status = NFMflag_project( "CR", data_list ); /** Special flag CR,nothing
							 to do with the database
						     **/
	MEMclose( &data_list );
	if( ( status != NFM_S_SUCCESS ) &&
	    ( status != NFM_I_NO_PROJ_MEMBERS) )
	{
	    _NFMdebug(( fname, "<0x%.8x>\n", status ));
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s",project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
	}
	else if(status == NFM_I_NO_PROJ_MEMBERS) 
	{
	    _NFMdebug(( fname, "No members to cancel restore flag\n"));
            ERRload_struct(NFM, status, "%s%s", project, "Cancel RESTORE");
	    return(status);
	}

        sprintf( flag_s,"UPDATE nfmprojects SET n_pendingflag = '' WHERE n_projectname = '%s'",project);

        status = SQLstmt( flag_s );
        if( status != SQL_S_SUCCESS )
        {
            _NFMdebug(( fname, "SQLstmt = <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_CANCEL_PROJECT_FLAG, "%s",project );
            return( NFM_E_CANCEL_PROJECT_FLAG );
        }

	_NFMdebug(( fname, "%s\n", "Successful Project Restore Cancelling" ));

	return (NFM_S_SUCCESS);
  }


NFMcancel_project_flag( data_list )
    MEMptr  data_list;
{
    long    status;

    int	    i;
    int     tot_data;

    char    flag[3];
    char    **r_data;
    
    static  char *fname = "NFMcancel_project_flag";

    strcpy( flag, "" );

    status = MEMbuild_array( data_list );
    if( status != MEM_S_SUCCESS )
    {
         ERRload_struct (NFM, NFM_E_MEM, "", NULL);
         _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
                 status));
         return (NFM_E_MEM);
    }

    r_data     = (char**) data_list->data_ptr;
    tot_data = data_list->rows * data_list->columns;

    /*  For each project member, cancel it in the catalog and projectcit*/
    for( i=0; i<tot_data; i+=data_list->columns )
    {
	status = NFMflag_project_member( flag, r_data[i+6], r_data[i+3],
					     r_data[i+4], r_data[i+5] );
	if( status != NFM_S_SUCCESS )
	{
	    _NFMdebug(( fname, "NFMflag_members <0x%.8x>\n", status ));
	    return( status );
	}
    }

    _NFMdebug(( fname, "%s\n", "Successful Canceling" ));

    return( NFM_S_SUCCESS );
}
