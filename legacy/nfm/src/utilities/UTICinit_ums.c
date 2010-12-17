#include "machine.h"
#include <stdio.h>
#include <UMS.h>
#include "UTIclient.h"
#include "UTImacros.h"
#include "ERR.h"

extern   char* strrchr();

long UTICinit_ums(program_name)
    char  *program_name;
{
    long   status;
    char   *p;
    char   path[256];

    strcpy (path, whence (program_name, NULL));

    /*  Remove executable name  */

    p = strrchr (path, '/');
    *p = NULL;

    /*  Remove "/bin"  */

    p = strrchr (path, '/');
    *p = NULL;

    strcat( path, "/config/english/messages" );

    status = ERRinit_messages (path, UMS_INDEX);
    if( status != ERR_S_SUCCESS )
	return( UTI_E_FAILURE );
    return( UTI_S_SUCCESS );
}
