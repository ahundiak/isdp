/* Report Sub System Debug Include File */

#include <stdio.h>
#include "MSGstruct.h"

FILE	*fopen ();
extern	FILE *NFMdbg_ptr;
extern	MSGptr NFMmsg_ptr;

#define _RPS_dbg(str, var) \
        if (NFMmsg_ptr.debug_on) \
         { \
           NFMdbg_ptr = fopen (NFMmsg_ptr.debug_file, "a"); \
           if (NFMdbg_ptr) \
            { \
              fprintf (NFMdbg_ptr, "RPS : "); \
              fprintf (NFMdbg_ptr, (str), (var)); \
              fprintf (NFMdbg_ptr, "\n"); \
              fclose  (NFMdbg_ptr); \
            } \
         }
