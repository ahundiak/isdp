/*
  DESCRIPTION

    This file contains the declaration and definition of the system variable 
    that stands for the debug level. This controls some error handling 
    characteristics and the in-built tracing functionality. "Get" and "Set" 
    functions are provided to access this value. The following is the
    interpretation of the debug levels:

    0  =  No error messages printed. 
          No trace. 
          Error codes being stacked up on the error-handler stack for
           retrieval and interpretation by the GUI or anyone else.

          This is the default setting at the time of delivery of the product. 
   
    1  =  Error messages are printed. 
          No trace. 
          Error codes are being stacked as always. 

          This is the default setting for development.

    2  =  Error messages are printed. 
          Trace is turned on. This means that even on no-error every function
           on exit will print itself, thus giving an idea of the calling
           sequence at runtime. 
          Error-handler stack is being processed as usual.

    3  =  Same as 2.
          In addition, specific debug statement embedded within the code by
           the programmer will be activated to give a finer granularity of the
           trace. More information at various critical points within the code
           can be printed. Control may even be hijacked by certain kinds of
           embedded debug code which allow for the programmer to look at the
           state of the system more fully (eg: invoking EMS_PMS() at certain
           points, etc).
*/

#include "PWminimum.h"
#include "PWerror.h"

static int DebugLevel = 0;

/*
 * Function that obtains the current setting of the debug level.
 */
int pwGetDebugLevel
(
)
{
  return (DebugLevel);
}

/*
 * Function that sets the debug level.
 */
void pwSetDebugLevel
(
  int level
)
{
  if (level < 0)
    level = 0;
  else if (level > PW_K_MaxDebugLevel)
    level = PW_K_MaxDebugLevel;

  DebugLevel = level;

  return;
}
