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

method GRxhget_definition(IGRlong               *msg; 
                          IGRshort              *alt_color;
                          IGRdouble             *alt_angle;
                          IGRdouble             *alt_spacing;
                          IGRboolean            *associative_flag;
                          IGRdouble             *origin;
                          struct GRxhatchpat    *pattern_def)
{
  *msg = MSSUCC;

  *alt_color = me->xhatch_color;
  *alt_angle = me->xhatch_angle;
  *alt_spacing = me->xhatch_spacing;
  *associative_flag = me->associative_flag;
  origin[0] = me->origin[0];
  origin[1] = me->origin[1];
  origin[2] = me->origin[2];
  *pattern_def = me->pattern_def;
  
  return(OM_S_SUCCESS);
}

method GRxhget_addl_info(IGRlong        *msg;
                         struct GRid    *window_id)
{
  *msg = MSSUCC;
  *window_id = me->window_grid;

  return(OM_S_SUCCESS);
}

end implementation GRcoxhatch;
