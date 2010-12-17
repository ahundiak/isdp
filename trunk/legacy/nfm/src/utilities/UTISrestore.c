#include "machine.h"
#include "NFMschema.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMtypes.h"
#include "NFMsysstruct.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "ERR.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000

extern  UTIpending UTIflist;
extern  struct NFMuser_info_struct  NFMuser_info;

long UTIrestore_files( server, env, user, password, file_info, out_list )
    char	*server;
    char	*env;
    char 	*user;
    char 	*password;
    MEMptr	file_info;
    MEMptr	*out_list;
{
    int		i;
    int		link_cnt, first_time=0;
    int		link_no;

    long	status;
    long	cmd_status;
 
    char	*passwd;

    char	**data_ptr;

    UTIpending  link;
    UTIpending  savedlist, prev;
    UTIpending  listend;
    UTIpending  UTImake_list();
    UTIpending  savedflist;

    static	char *fname = "UTIrestore_files";

    savedlist = listend = NULL;
    UTI_ERR_BUFFER	= NULL;
    UTI_MSG_BUFFER      = NULL;

    _UTIdebug(( fname, "Server <%s>\n", server ));
    _UTIdebug(( fname, "Env    <%s>\n", env ));
    _UTIdebug(( fname, "User   <%s>\n", user ));
    _UTIdebug(( fname, "Passwd <%s>\n", password ));

    UTIuser_id  = 0;
    UTIserver= strcpy( (char*)malloc(strlen(server)+1), server );
    UTIenv   = strcpy( (char*)malloc(strlen(env)+1), env );
    UTIuser  = strcpy( (char*)malloc(strlen(user)+1), user );
    passwd   = strcpy( (char*)malloc(strlen(password)+1), password );
    UTIpasswd= (char*)malloc(30);
    NFMencrypt( passwd, UTIpasswd );

    _UTIdebug(( fname, "NFMuser_info.dir <%s>, UTIenv <%s>\n", 
			NFMuser_info.dir, UTIenv ));
/**************
    if(strcmp(NFMuser_info.dir,"") == 0)
       sprintf( UTI_SERVER_PATH, "/usr/nfmadmin/%s/utilities/", UTIenv );
    else
       sprintf( UTI_SERVER_PATH, "%s/%s/utilities/", NFMuser_info.dir, UTIenv );
**************/

    _UTIdebug(( fname, "UTI_SERVER_PATH <%s>\n", UTI_SERVER_PATH ));

    _UTIdebug(( fname, "server : <%s>\n", UTIserver ));
    _UTIdebug(( fname, "env : <%s>\n", UTIenv ));
    _UTIdebug(( fname, "user : <%s>\n", UTIuser ));
    _UTIdebug(( fname, "passwd : <%s>\n", UTIpasswd ));

/*  Set some global information */
    NFMload_user_info ("nfmadmin");

    status = MEMbuild_array( file_info );
    if (status != MEM_S_SUCCESS)
    {
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _UTIdebug(( fname, "MEMbuild : <0x%.8x>\n", status));
        return (NFM_E_MEM);
    }

    data_ptr = (char**)file_info->data_ptr;
    _UTIdebug(( fname, "file links : <%d>\n", file_info->rows ));
    link_cnt = file_info->rows;
    if( link_cnt == 0 )
    {
	_UTIdebug(( fname, "%s\n", "NO FILES CHOSEN" ));
	ERRload_struct( UTI, UTI_E_NO_FILES_CHOSEN, "%s", "RESTORE" );
	MEMclose( &file_info );
	return( UTI_E_NO_FILES_CHOSEN );
    }

/*  Now match chosen link numbers with the original linked list of
 *  flagged files.
 */
    savedflist = UTIflist;
    for( i=0; i<link_cnt; ++i )
    {
	prev = NULL;
	first_time = 0; /* Inside the big If for the first time */
	link_no = atoi( data_ptr[i] );
	UTIflist = savedflist;
	while( UTIflist != NULL )
	{
	    _UTIdebug((fname, "Flist->state = <%d>\n", UTIflist->state));
	    if( (link_no == UTIflist->state) ||

		((first_time==1) &&
		(prev != NULL) &&
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
                    savedlist = listend = link; /* first link */
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
	} /* end while */
    } /* end for */

    status = UTIopen_buffers();
    if( status != UTI_S_SUCCESS )
	return( status );
    
    UTIflist = savedlist;
    cmd_status = UTIprocess_restore( savedlist );
    _UTIdebug(( fname, "UTIprocess_restore : <0x%.8x>\n", cmd_status));

    if( MSG )
    {
        if(_NFMdebug_st.UTIdebug_on)
            MEMprint_buffers("Message Buffers", UTI_MSG_BUFFER, 
					       _NFMdebug_st.UTIdebug_file);

        status = MEMsplit_copy_buffer( UTI_MSG_BUFFER, out_list, 1 );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &UTI_ERR_BUFFER );
	    MEMclose( &UTI_MSG_BUFFER );
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            _UTIdebug(( fname, "MEMsplit_copy : <0x%.8x>\n", status));
            return (NFM_E_MEM);
        }
    }

    MEMclose( &UTI_MSG_BUFFER );
    MEMclose( &UTI_ERR_BUFFER );
    UTIfree_pending_list( &UTIflist );
    UTIfree_pending_list( &savedflist );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    if( cmd_status != UTI_S_SUCCESS )
   	return( cmd_status );

    return (UTI_S_SUCCESS); 
}
