/*
  OVERVIEW

  This file consists of functions related to Curve Entity's properties.


  HISTORY

  SS    : 07/28/95  :  Creation
*/

class implementation GRcurve;

#include "EMSmsgdef.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/cvprops.h" 

/*
  ABSTRACT
 
  Function that outputs a Boolean flag indicating whether the given curve
  entity (composite, simple curve) is flagged as open. Note that this is
  not a geometric check for end-points within tolerance. This function simply
  queries the topological property stored within the curve.
*/

PWboolean pwIsCvOpen 
(
  PWobjid cvobj,
  PWosnum os
)
{
  short mattyp=MAIDMX;
  long msg=EMS_S_Success;
  PWmatrix idmx;
  struct GRprops props;

  pwIdMx (idmx);
  om$send (msg = message GRvg.GRgeomprops (&msg, &mattyp, idmx, &props),
   targetid = cvobj, targetos = os, senderid = cvobj);
 
  return (! props.phy_closed);
}

end implementation GRcurve;

