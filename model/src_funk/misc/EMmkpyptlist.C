/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
  DESCRIPTION

    This function is to be used when extending an existing list or starting
    of a list (input list pointer is NULL). The element added is intialized
    with the input passed in. 

    The "positioned" option requires some elaboration. If this is set to TRUE,
    it is being implied that the list-pointer being input is set to
    the node that simply requires initialization. A NULL-pointer with
    this option is therefore an invalid argument. 
    If this option is set to FALSE, this function does one of the following
    - i) allocates a new node which might start off the list when the list is
         currently empty)
    - ii) starting from the head of this list search for the first node
          marked with a negative span_inx value and use that. This way
	  the list can be malloced in anyway the user wishes.
    - iii) on hitting a NULL "next" pointer (failing the above two) allocate
           a new node and use that.

  ARGUMENTS
  
    pylist		- Input/Output: If pylist is NULL (by value) then
			  no action takes place, else if (*pylist) is NULL
			  the list is started, else the list is extended
			  depending on the 'positioned' flag.
    spaninx, param	- Input: These arguments initialize the fields
    point, props	  of the EMpypoint structure.
    dim			- Input: The dimension of the point.
    positioned		- Input: If TRUE, the pylist is positioned, else
			  the list is traversed until the NULL-terminated
			  node is found and this new node is appended to it.

  RETURN VALUE

    This function returns the address of the structure that was to used
    to store the information. It could be a newly malloced node or an existing
    empty one or the one at which the list is currently positioned. The
    message code returned is one of the following:

    Success
    - EMS_S_Success
       All went well
    
    Error condition
    - EMS_E_NoDynamicMemory
       Failure when trying to allocate dynamic memory
    - EMS_E_InvalidArg
       The 'position' flag was TRUE but the input list was a NULL-pointer

  HISTORY

    SS  :  03/01/87  :  Creation
    SS  :  10/07/87  :  Added the arguments "props and info" to initialize
                        the new fields in the EMSpypoint structure.
*/
  
#include "OMmacros.h"

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */

#include "OMerrordef.h"
#include <math.h>
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"
#include "EMSbnddef.h"
#include "emsdattyp.h"
#include "emsdef.h"
#include "emserr.h"

/* ***************************************************************
 
History
      PP : 02/23/88 : Changed the code so that the props are orred and
                      EMS_PYPT_EMPTY bit is turned off when a node
                      is filled

  **************************************************************** */


struct EMSpypoint *EMmkpyptlist (msg, pylist, spaninx, param, point, props,
                                 info, dim, positioned)
IGRlong *msg;
struct EMSpypoint **pylist;
IGRlong spaninx;
IGRdouble param, *point;
IGRushort props;
IGRchar *info;
IGRshort dim;
IGRboolean positioned;
{
  IGRboolean empty_exists;
  IGRint stat_func;
  IGRlong msg_loc;
  struct EMSpypoint *pyptr;
  struct EMSpypoint *EMpypoint_malloc();

  *msg = EMS_S_Success;
  if (!pylist)
    goto ret_end;
 
  /*
   * Positioning and allocating
   * if necessary.
   */

  if (!positioned)
    {
    if (*pylist)
      {
      pyptr = *pylist;
      empty_exists = FALSE;
      while (!(empty_exists = pyptr->span_inx < 0) && pyptr->next)
        pyptr = pyptr->next;
      if (!empty_exists)
        {
        pyptr->next = EMpypoint_malloc (&msg_loc, 1);
        EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);
        pyptr = pyptr->next;
        }
      }
    else
      {
      *pylist = EMpypoint_malloc (&msg_loc, 1);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      pyptr = *pylist;
      }
    }
  else
    {
    EMerr_hndlr (! *pylist, *msg, EMS_E_InvalidArg, ret_end);
    pyptr = *pylist;
    }
  
  /* 
   * Initializing the element.
   */

  pyptr->span_inx = spaninx;
  pyptr->param = param;
  pyptr->props |= props;
  pyptr->props &= ~EMS_PYPT_EMPTY;
  pyptr->info = info;
  OM_BLOCK_MOVE (point, pyptr->point, dim * sizeof (IGRdouble));

ret_end:
  stat_func = TRUE;
  EMWRAPUP (*msg, stat_func, "EMmkpyptlist");
  return (pyptr);
}

