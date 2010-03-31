/*
   FILE DESCRIPTION

     This file contains all the trivial implementations of this class.
     Typically, those implementations that are basically, passons or
     are implementations that compute and/or return something trivially
     known by this object. 
*/

class implementation EMSsubbs;

#include "bserr.h"
#include "bsparameters.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/sfgeom.h"
#include "PWapi/partol.h"

from EMSloopset import EMchksliver;

/*
  ABSTRACT

  EMS_O_External:
  This option is relevant to the surface's implementation. When this is
  set, a check is made to see if the surface itself is degenerate. In this
  case, no edges are returned. There is no look-up of the boundary either.
  The only meaningful output in this case is a return code of EMS_I_Found.
  'num_slivers' and 'sliver_edges' is ignored.

  EMS_O_Internal:
  When this option is set, the boundaries are searched for overlapping 
  edges that form true slivers. In this case, there is a traversal 
  of the loopset.

  EMS_O_External | EMS_O_Internal:
  The only meaningful output in this case is a return code of EMS_I_Found.
  'num_slivers' and 'sliver_edges' is ignored. The degeneracy could be
  from either source -- the natural surface itself or an overlapping edge.
*/

method EMchksliver (IGRlong *msg; IGRushort options;
                    IGRshort *mattyp; IGRmatrix mat;
                    IGRdouble xyztol;
                    IGRint num_samplepts_edge;
                    IGRint *num_slivers;
                    GRobjid (**sliver_edges)[2])
{
  PWresult result=PW_K_Success;
  IGRlong msg_loc;
  IGRdouble maxlen;
  struct IGRbsp_surface *srf=NULL;
  OM_S_CHANSELECT chan_to_loopset;

  *msg = EMS_S_Success;

  if (options & EMS_O_External)
  {
    num_slivers = NULL;
    sliver_edges = NULL;
  }

  result = PW_GetSfBspsfStack (my_id, OS, *mattyp, mat, srf);
  OnErrorState (IsError (result), *msg, EMS_E_Fail, wrapup);

  if (options & EMS_O_External)
  {
    BSsfplsdist (&msg_loc, &srf->u_num_poles, &srf->v_num_poles, srf->poles,
     srf->weights, &maxlen);
    OnErrorState (msg_loc != BSSUCC, *msg, EMS_E_Fail, wrapup);

    if (maxlen < xyztol)
    {
      *msg = EMS_I_Found;
      goto wrapup;
    }
  }

  EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  om$send (msg = message EMSloopset.EMchksliver (msg, options, 
   pwGetParTolSf (srf, xyztol), num_samplepts_edge, num_slivers, sliver_edges),
   p_chanselect = &chan_to_loopset);

wrapup:
  return (OM_S_SUCCESS);
}

end implementation EMSsubbs;

