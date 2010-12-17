#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMtypes.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "ERR.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000

extern	UTIpending  UTIflist;

long UTIdelete_files( server, env, user, password, file_info )
    MEMptr	file_info;
{
    int		i, first_time=0;
    int		link_cnt;
    int		link_no;

    long	status;
    long	cmd_status;
 
    char	**data_ptr;

    UTIpending  link, prev;
    UTIpending  savedlist;
    UTIpending  listend;
    UTIpending  UTImake_list();
    UTIpending  savedflist;

    static	char *fname = "UTIdelete_files";

    savedlist = listend = NULL;
    UTI_ERR_BUFFER	= NULL;
    UTI_MSG_BUFFER      = NULL;

/*  Set some global information */
    NFMload_user_info ("nfmadmin");

    status = MEMbuild_array( file_info );
    if (status != MEM_S_SUCCESS)
    {
        _UTIdebug(( fname, "MEMbuild_array(file_info) : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char**)file_info->data_ptr;

    link_cnt = file_info->rows;
    if( link_cnt == 0 )
    {
	_UTIdebug(( fname, "%s\n", "NO FILES CHOSEN : " ));
	ERRload_struct( UTI, UTI_E_NO_FILES_CHOSEN, "%s", "DELETE" );
	return( UTI_E_NO_FILES_CHOSEN );
    }
/*  Now match chosen link numbers with the original linked list of
 *  flagged files.
 */
    savedflist = UTIflist;
    for( i=0; i<link_cnt; ++i )
    {
	prev = NULL;
	first_time = 0;
	link_no = atoi( data_ptr[i] );
	while( UTIflist != NULL )
	{
	    _UTIdebug((fname, "Flist->state = <%d>\n", UTIflist->state));
	    
            if((link_no == UTIflist->state) ||

	          ((first_time == 1) &&
                  (prev != NULL) &&
                  (UTIflist->cat.val == prev->cat.val) &&
                  (UTIflist->item.val == prev->item.val))
                  /******(UTIflist->ver == prev->ver)********/
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
            } /* end if */
	    prev = UTIflist;
            UTIflist = UTIflist->next;
	} /* end while */
    } /* end for */

    MEMclose(&file_info);
    status = UTIopen_buffers();
    if( status != UTI_S_SUCCESS )
	return( status );

    UTIflist = savedlist;
    cmd_status = UTIprocess_delete( savedlist );
    _UTIdebug(( fname, "UTIprocess_delete : <0x%.8x>\n", cmd_status));


    MEMclose( &UTI_ERR_BUFFER );
    MEMclose( &UTI_MSG_BUFFER );

    UTIfree_pending_list( &UTIflist );
    UTIfree_pending_list( &savedflist );

    _UTIdebug(( fname, "%s\n", "Exiting" ));
    
    if( cmd_status != UTI_S_SUCCESS )
	return( cmd_status );

    return (UTI_S_SUCCESS); 
}
