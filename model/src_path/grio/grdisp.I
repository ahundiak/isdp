/*
  OVERVIEW
  
  This file contains the set of APIs that deal with display of a GRgraphics
  object(s).

  
  HISTORY

  SS   :  03/20/96   :   Creation
*/

class implementation GRgraphics;

#include "exmacros.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/grdisp.h" 
#include "PWapi/mx.h"

void pwDisplayObj
(
  PWobjid grobj,
  PWosnum os,
  PWboolean erase,
  PWboolean highlight
)
{
  long msg;
  short mattyp=MAIDMX;
  PWmatrix mx;
  struct GRid md_id;
  enum GRdpmode dpmode;

  if (erase && highlight)
    dpmode = GRhe;
  else if (erase && !highlight)
    dpmode = GRbe;
  else if (!erase && highlight)
    dpmode = GRhd;
  else
    dpmode = GRbd;

  md_id.osnum = os;
  ex$get_modid (mod_osnum = os, mod_id = &md_id.objid);

  om$send (msg = message GRgraphics.GRdisplay (&msg, &mattyp, pwIdMx(mx),
   &dpmode, &md_id), targetid = grobj, targetos = os, 
   senderid = PW_K_NullObjid);

  return;
}

end implementation GRgraphics;
