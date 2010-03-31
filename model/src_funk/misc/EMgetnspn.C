/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"

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
#include "bserr.h"
#include "bsparameters.h"
#include <math.h>
#include "emsmacros_c.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbstrim.h"
#include "bsspn_t_bz.h"

EMget_next_span (EMmsg, span_info, getadjseg, adjbs_info, next_span)

IGRlong *EMmsg;
struct EMthis_spaninfo *span_info;
IGRlong (*getadjseg) ();
struct EMSgetadjgeom *adjbs_info;
struct IGRbsp_curve *next_span;

{
/* *****************************************************************
   
   This function gets the next span geometry for use in trimming. It is
   expected that the memory for the next span is already allocated in the
   field next_span. The amount of memory that
   needs to be allocated is equivalent to storing a bezier span of order 16.

   On exit the completion code will be one of the following:
      EMS_S_Success : if all goes well
      EMS_E_BSerror : if there is a math error
      EMS_E_InvalidArg : if getadjseg is not NULL and adjbs_info is NULL.

   History:
    SCW     02/13/97    included emsmacros_c.h rather than emsmacros.h
    Sudha   07/08/93    Modified for BSprototypes ansification
       PP : 05/08/88    Support for handling the case when there is no
                        next span
       PP : 01/13/88    Changed the argument list.Added next_span field.
       PP : 08/22/87    Creation

   ***************************************************************** */


  IGRint num_spans;
  IGRint this_spanindex;
  IGRboolean found_span = FALSE;
  IGRdouble this_knottol;
  IGRboolean status;
  IGRlong tmp_status;

  struct IGRbsp_curve *this_geom;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 if (span_info)
 {
  this_geom = span_info->this_geom;
  this_spanindex = span_info->this_spanindex;
  this_knottol = span_info->knot_tol;

  num_spans = this_geom->num_poles - this_geom->order + 1;

  if ((this_spanindex + 1) < num_spans) /* a span exists in this geometry */
  {
   getnextnondegeneratespan(EMmsg, this_spanindex, this_geom,
                            this_knottol, &found_span,
                            next_span);
   EMerr_hndlr (EMis_error (*EMmsg), *EMmsg, *EMmsg, ret_end);
  }

  if (!found_span)
  {
    if (this_geom->phy_closed)
    {
     getnextnondegeneratespan(EMmsg, -1, this_geom, this_knottol, 
                              &found_span, next_span);
     EMerr_hndlr (EMis_error (*EMmsg), *EMmsg, *EMmsg, ret_end);
    }
  }
 }
 
 if (!found_span)
 {
  if (getadjseg)
  {
    EMerr_hndlr (!adjbs_info, *EMmsg, EMS_E_InvalidArg, ret_end);

    adjbs_info->adjdata.data.curve = next_span;
    status = (*getadjseg) (adjbs_info);
    if (!(1&status)) goto ret_end;
    if (adjbs_info->msg == EMS_I_OutOfBounds) *EMmsg = EMS_I_NotFound;
  }
  else
   *EMmsg = EMS_I_NotFound;
 }

 
ret_end :
  tmp_status = (IGRlong)status;

  EMWRAPUP (*EMmsg, tmp_status, "EMget_next_span");
  return ;
}

getnextnondegeneratespan(msg, this_spanindex,this_geom, knot_tol,
                         found_span, next_span)

IGRlong *msg;
IGRint this_spanindex;
struct IGRbsp_curve *this_geom;
IGRdouble knot_tol;
IGRboolean *found_span;
struct IGRbsp_curve *next_span;

/* ****************************************************************

   This function gets the next non degenerate bezier span when supplied with
   the geometry of bspline from which the span needs to be extracted,
   the span index, the knot tolerance for the geometry. This function
   then returns found_span as true if it was able to find the next span
   and the geometry in the next_span variable. It is expected that
   the memory for the next span is already allocated.

   On completion the return code will be one of the following:

     EMS_S_Success : if all goes well
     EMS_E_BSerror : if there is a math error in determining the span

   History
        PP : 08/21/87          Creation

   **************************************************************** */

{
  IGRint cntr, temp;
  IGRint num_spans;
  IGRlong rc;
  IGRboolean degenerate;


  *msg = EMS_S_Success;
  *found_span = FALSE;

  num_spans = this_geom->num_poles - this_geom->order + 1;
  cntr = this_spanindex + 1;
  temp = cntr + this_geom->order - 1;

  next_span->phy_closed = 0;
  next_span->planar = 1;

   while (!(*found_span) && (cntr < num_spans))
   {
     degenerate = (this_geom->knots[temp + 1] -
                    this_geom->knots[temp] ) < knot_tol;

     if (!degenerate)
     {
      (void) BSspn_t_bz (&rc, temp, this_geom, next_span, FALSE, FALSE);
      EMerr_hndlr (BSERROR(rc), *msg, EMS_E_BSerror, ret_end);

      *found_span = TRUE;
     }
     ++cntr;
     ++temp;
    }
   
 ret_end:
   return;
 }

