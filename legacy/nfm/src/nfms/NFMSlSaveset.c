
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

/*In the below line 'if UNIX' is replaced by 'ifdef OS_UNIX' - SSRS 28 Dec 93 */
#ifdef OS_UNIX
#include <pwd.h>
#include <sys/types.h>
#include <sys/stat.h>
#endif

#include "NETstruct.h"

#define BUFFER_SIZE 1000


long NFMSlist_savesets (in_list, out_list)

MEMptr in_list;
MEMptr *out_list;

{
long ret_status;
long user_id;
int  type;
int  buff_flag;
char **data_ptr;
static char *fname = "NFMSlist_savesets";

_NFMSdebug(( fname, "%s\n", "Entering ..." ));

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID          : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

ret_status = NFMlist_savesets (user_id, out_list);

_NFMSdebug(( fname, "Status : <0x%.8x>\n", ret_status));

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

_NFMSdebug(( fname, "%s\n", "Exiting ..." ));

return (NFM_S_SUCCESS);
}
