#include "machine.h"
#include "DEBUG.h"

#ifndef NFM_DEBUG_SUBSYSTEMS
#define NFM_DEBUG_SUBSYSTEMS 15
#endif

long NFMall_debug ( toggles, files )

int  toggles[NFM_DEBUG_SUBSYSTEMS];
                 /* i - array of subsystem debugs on (1) or off (0) */
char files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];
                 /* i - array of subsystem debug filenames */
{
    return( _NFMall_debug( toggles, files ) );
}
