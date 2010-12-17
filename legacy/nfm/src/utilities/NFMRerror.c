#include "machine.h"
#include <stdio.h>
#include <inc.h>
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NETstruct.h"
#include "NETdef.h"
#include "NETdef.h"
#include "NFMtypes.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"

extern long NETid;

MSGptr NFMRmsg_ptr = {0, "/dev/console", 0, ""};

extern MSGptr NFMmsg_ptr;
extern MSGptr SQLmsg_ptr;
extern MSGptr DBmsg_ptr;
extern MSGptr NETmsg_ptr;
extern MSGptr MEMmsg_ptr;

/* 
 Doc: _NFMR_num
 
 Abstract:
     This function will output a debug string with an integer variable.
     The output file is NFMRmsg_ptr.debug_file.

     Ex.   _NFMR_num ("value for attr_num = %d", attr_num);
     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    8-31-1989    Creation
     
 */
 
 _NFMR_num (str, var)
  char  *str;  /* i - input string */
  long  var;   /* i - long variable for input string */

  {
    FILE   *NFMdbg_ptr, *fopen ();

    if (NFMRmsg_ptr.debug_on)
     {
       NFMdbg_ptr = fopen (NFMRmsg_ptr.debug_file, "a");
       if (NFMdbg_ptr)
        {
          fprintf (NFMdbg_ptr, "NFMR : ");
          fprintf (NFMdbg_ptr, str, var);
          fprintf (NFMdbg_ptr, "\n");
          fclose  (NFMdbg_ptr);
        }
     }
  }

/* 
 Doc: _NFMR_str
 
 Abstract:
     This function will output a debug string with a string variable.
     The output file is NFMRmsg_ptr.debug_file.

     Ex.   _NFMR_str ("value of input string = %s", string);
     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    8-31-1989    Creation
     
 */
 
 _NFMR_str (str, var)
  char  *str;  /* i - input string */
  char  *var;  /* i - string variable for input string */

  {
    FILE   *NFMdbg_ptr, *fopen ();

    if (NFMRmsg_ptr.debug_on)
     {
       NFMdbg_ptr = fopen (NFMRmsg_ptr.debug_file, "a");
       if (NFMdbg_ptr)
        {
          fprintf (NFMdbg_ptr, "NFMR : ");
          fprintf (NFMdbg_ptr, str, var);
          fprintf (NFMdbg_ptr, "\n");
          fclose  (NFMdbg_ptr);
        }
     }
  }

