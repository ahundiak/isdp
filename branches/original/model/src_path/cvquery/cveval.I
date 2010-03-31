/*
  OVERVIEW

  This file consists of functions related to getting plane of a Curve Entity.


  HISTORY

  Satya    : 12/01/96  :  Creation
*/

class implementation GRbspline;

#include "bs.h"
#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWerror.h"

 
PWresult pwGetCvPlane
(
  PWobjid cvid,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  struct PWplane *plane
)
{
 
     PWresult PWsts = PW_K_Success;
     long OMsts,OMmsg;
     struct IGRplane igr_plane;
 
     igr_plane.point = plane->pt;
     igr_plane.normal = plane->normal;
 
     OMsts = om$send (msg = message GRvg.GRdetplane(&OMmsg,
                                              &mattyp,
                                              mat,
                                              &igr_plane),
                                              senderid = NULL_OBJID,
                                              targetid = cvid,
                                              targetos = os);
     OnErrorState( !(1 & OMsts & OMmsg), PWsts,
             SetError( PW_K_Pathway, PW_K_Error), wrapup);
 
wrapup:
     return(PWsts);
 
}
 
end implementation GRbspline;
