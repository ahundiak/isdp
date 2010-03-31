/*
  An edge-parameter (struct EMedgebound) is input along with the
  start and stop-parameters of the edge. The input edge-parameter has
  been computed as if the edges parameterization started at [0, 0.0] but
  not at the start-parameter. The objective here is to convert 
  this input parameter by this function so that it is now relative to the
  edges start and stop-parameters. The start and stop parameters need
  not be in ascending order.

  The assumption made here is that the parameterization on
  a given span is linear. 
*/

# include <math.h>
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "OMminimum.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "msdef.h"
# include "EMSbnddef.h"
# include "emsdattyp.h"
# include "emsinter.h"
# include "emsdef.h"
# include "emserr.h"
# include "EMSbnd.h"
# include "EMSerrnumdef.h"
# include "EMSerrordef.h"

void EMcnvtedpar (msg, startpar, stoppar, inpar, outpar)
IGRlong *msg;
struct EMSedgebound *startpar, *stoppar, *inpar, *outpar;
{
  struct EMSedgebound *loc_startpar, *loc_stoppar;

  *msg = EMS_S_Success;

  if (startpar->span_inx + startpar->param > 
      stoppar->span_inx + stoppar->param)
    {
    loc_startpar = stoppar;
    loc_stoppar = startpar;
    }
  else
    {
    loc_startpar = startpar;
    loc_stoppar = stoppar;
    }

  if (loc_startpar->span_inx == loc_stoppar->span_inx)
    outpar->span_inx = loc_startpar->span_inx;
  else
    outpar->span_inx = inpar->span_inx + loc_startpar->span_inx +
                        (loc_startpar->param == 1.0 ? 1 : 0);

  if (loc_startpar->span_inx == loc_stoppar->span_inx)
    outpar->param = loc_startpar->param + inpar->param * 
                     (loc_stoppar->param - loc_startpar->param);
  else if (outpar->span_inx == loc_startpar->span_inx)
    outpar->param = loc_startpar->param + inpar->param *
                     (1.0 - loc_startpar->param);
  else if (outpar->span_inx == loc_stoppar->span_inx)
    outpar->param = inpar->param * loc_stoppar->param;
  else
    outpar->param = inpar->param;
}
