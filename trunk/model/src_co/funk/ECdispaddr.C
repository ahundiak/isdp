#include "OMminimum.h"
#include "ems_m_inc.h"      /* Includes everything */
#include "igrdef.h"         /* IGRPY, IGRPS */
#include "EMSmsgdef.h"      /* EMS_S_Success */
#include "emserr.h"

IGRlong ECdisplayPointSetByBuffer_passing_by_addr(
        msg, thisActiveDisplay, thisModuleInfo, thisId, num_pnts,
        pnts, draw_background)
IGRlong             *msg;
IGRlong             num_pnts;
IGRpoint            pnts[];
IGRboolean          draw_background;
struct IGRdisplay   *thisActiveDisplay;
struct GRmd_env     *thisModuleInfo;
OM_S_OBJID          thisId;
{
  IGRlong ECdisplayPointSetByBuffer();

  return(ECdisplayPointSetByBuffer(msg, *thisActiveDisplay, *thisModuleInfo,
         thisId, num_pnts, pnts, draw_background));
}
