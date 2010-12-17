
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>
#include <errno.h>

#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"

/*In the below line 'if UNIX' is replaced by 'ifdef OS_UNIX' - SSRS 28 Dec 93*/
#ifdef OS_UNIX
#include <pwd.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

#include "NETstruct.h"

#define BUFFER_SIZE 1000


long NFMSquery_cancel_archive (in_list, out_list)
    MEMptr in_list;
    MEMptr *out_list;
{
    long status;
    long user_id;
    char **data_ptr;
    static char *fname = "NFMSquery_cancel_archive";

    _NFMSdebug(( fname, "%s\n", "Entering ..."));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

   _NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));

   user_id = atol (data_ptr[0]);
   
   status = NFMquery_cancel_archive (user_id, data_ptr[1], out_list );

   _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));

   if( status != NFM_S_SUCCESS )
	return( status );
 
   return (NFM_S_SUCCESS);
}


long NFMSquery_cancel_backup (in_list, out_list)
    MEMptr in_list;
    MEMptr *out_list;
{
    long status;
    long user_id;
    char **data_ptr;
    static char *fname = "NFMSquery_cancel_backup";
 
    _NFMSdebug(( fname, "%s\n", "Entering ..."));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));

    user_id = atol (data_ptr[0]);

    status = NFMquery_cancel_backup (user_id, data_ptr[1], out_list );

    _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));

    if( status != NFM_S_SUCCESS )
	return( status );
 
    return (NFM_S_SUCCESS);
}


long NFMSquery_cancel_restore (in_list, out_list)
    MEMptr in_list;
    MEMptr *out_list;
{
    long status;
    long user_id;
    char **data_ptr;
    static char *fname = "NFMSquery_cancel_restore";

    _NFMSdebug(( fname, "%s\n", "Entering ..."));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));

    user_id = atol (data_ptr[0]);

    status = NFMquery_cancel_restore (user_id, data_ptr[1], out_list );

    _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));

    if( status != NFM_S_SUCCESS )
	return( status );
 
    return (NFM_S_SUCCESS);
}


long NFMSquery_cancel_delete (in_list, out_list)
    MEMptr in_list;
    MEMptr *out_list;
{
    long status;
    long user_id;
    char **data_ptr;
    static char *fname = "NFMSquery_cancel_delete";

    _NFMSdebug(( fname, "%s\n", "Entering  ..."));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));
    user_id = atol (data_ptr[0]);

    status = NFMquery_cancel_delete (user_id, data_ptr[1], out_list );

    _NFMSdebug(( fname, "Status -> <0x%.8x>\n", status));

    if( status != NFM_S_SUCCESS )
	return( status );
 
    return (NFM_S_SUCCESS);
}




