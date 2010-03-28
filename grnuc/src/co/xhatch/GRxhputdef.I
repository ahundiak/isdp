/* #######################    APOGEE COMPILED   ######################## */
class implementation  GRcoxhatch;

#include "coimport.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "exdef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#define   _xh_check_win()\
{\
  status = \
  om$is_objid_valid(osnum=me->window_grid.osnum, objid=me->window_grid.objid);\
  if(status == OM_E_NOSUCHOBJ ||  status == OM_E_NO_OBJECT_SPACE)\
    {\
      me->associative_flag = FALSE;\
      return(OM_S_SUCCESS);\
    }\
}\

method GRxhput_definition(IGRlong                *msg; 
                          IGRshort               *alt_color;
                          IGRdouble              *alt_angle;
                          IGRdouble              *alt_spacing;
                          IGRboolean             *associative_flag;
                          IGRdouble              *origin;
                          struct GRxhatchpat     *pattern_def)
{
  IGRlong status;

  *msg = MSSUCC;
  _xh_check_win();
  me->xhatch_color = *alt_color; 
  me->xhatch_angle = *alt_angle;
  me->xhatch_spacing = *alt_spacing;
  me->associative_flag = *associative_flag;
  me->origin[0] = origin[0]; 
  me->origin[1] = origin[1];
  me->origin[2] = origin[2];
  me->pattern_def = *pattern_def;

  return(OM_S_SUCCESS);
}
end implementation GRcoxhatch;




