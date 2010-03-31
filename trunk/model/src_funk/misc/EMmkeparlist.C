/* ###################   APOGEE COMPILED   ################## */
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
  
    eplist		- Input/Output: If eplist is NULL (by value) then
			  no action takes place, else if (*eplist) is NULL
			  the list is started, else the list is extended
			  depending on the 'positioned' flag.
    intloc, edgeid,	- Input: are used to initialize the appropriate fields
    spaninx, param,	  of the EMSsfintedpar structure.
    point, info
    positioned		- Input: If TRUE, the eplist is positioned, else
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
    SS  :  10/07/87  :  Added the argument to initialize the info field.
    SCW :  02/13/97  :  Included emsmacros_c.h rather than emsmacros.h
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

#include <math.h>

#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSerrnumdef.h"
#include "EMSerrordef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfint.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros_c.h"

struct EMSsfintedpar *EMmkeparlist (msg, eplist, intloc, edgeid, spaninx, 
                                    param, point, info, positioned)
IGRlong *msg;
struct EMSsfintedpar **eplist;
enum EMScvinttype intloc;
GRobjid edgeid;
IGRint spaninx;
IGRdouble param;
IGRdouble point[2];
IGRchar *info;
IGRboolean positioned;
{
  IGRboolean empty_exists;
  IGRlong msg_loc;
  struct EMSsfintedpar *epptr;
  struct EMSsfintedpar *EMsfintedpar_malloc();
  IGRboolean EFextract_par();

  *msg = EMS_S_Success;
  if (!eplist)
    goto ret_end;

  /*
   * Positioning and allocating
   * if necessary.
   */

  if (!positioned)
    {
    if (*eplist)
      {
      epptr = *eplist;
      empty_exists = FALSE;
      while (!(empty_exists = epptr->edgepar.span_inx < 0) && epptr->next)
        epptr = epptr->next;
      if (!empty_exists)
        {
        epptr->next = EMsfintedpar_malloc (&msg_loc, 1);
        EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);
        epptr = epptr->next;
        }
      }
    else
      {
      *eplist = EMsfintedpar_malloc (&msg_loc, 1);
      EMerr_hndlr (EMis_error (msg_loc), *msg, msg_loc, ret_end);
      epptr = *eplist;
      }
    }
  else
    {
    EMerr_hndlr (! *eplist, *msg, EMS_E_InvalidArg, ret_end);
    epptr = *eplist;
    }
  
  /* 
   * Initializing the element.
   */

  epptr->intloc = intloc;
  epptr->edgeid = edgeid;
  epptr->edgepar.span_inx = spaninx;
  epptr->edgepar.param = param;
  epptr->info = info;
  OM_BLOCK_MOVE (point, epptr->point, 2 * sizeof (IGRdouble));
  epptr->next = NULL;

ret_end:
  return (epptr);
}

