#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MSGstruct.h"

MSGptr NFMRmsg_ptr = {0, "/dev/console", 0, ""};
extern MSGptr NFMmsg_ptr;

 _NFMS_num (str, var)
  char  *str;
  long  var;
  {
    FILE   *NFMdbg_ptr, *fopen ();

    if (NFMmsg_ptr.debug_on)
     {
       NFMdbg_ptr = fopen (NFMmsg_ptr.debug_file, "a");
       if (NFMdbg_ptr)
        {
          fprintf (NFMdbg_ptr, "NFMS : ");
          fprintf (NFMdbg_ptr, str, var);
          fprintf (NFMdbg_ptr, "\n");
          fclose  (NFMdbg_ptr);
        }
     }
  }

 _NFMS_str (str, var)
  char  *str, *var;
  {
    FILE   *NFMdbg_ptr, *fopen ();

    if (NFMmsg_ptr.debug_on)
     {
       NFMdbg_ptr = fopen (NFMmsg_ptr.debug_file, "a");
       if (NFMdbg_ptr)
        {
          fprintf (NFMdbg_ptr, "NFMS : ");
          fprintf (NFMdbg_ptr, str, var);
          fprintf (NFMdbg_ptr, "\n");
          fclose  (NFMdbg_ptr);
        }
     }
  }

