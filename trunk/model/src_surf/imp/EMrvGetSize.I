/* 
  DESCRIPTION
  
  This method returns the size in bytes of the internal
  format (B-spline surface) of the geometry of the object.


  HISTORY

  SS  :  04/04/95  :  Creation
*/  

class implementation EMSrevol;

#include "bsconic.h"
#include "EMSssprops.h"
#include "EMSsubbs.h"
#include "EMSrevol.h"
#include "EMScmacros.h"

#define V_ORDER     BSCIRCLE_ORDER
#define V_NUM_POLES BSCIRCLE_NUM_POLES_MAX

method GRgetsize
(
  IGRlong *msg; 
  IGRshort *mat_type; 
  IGRmatrix matrix;
  IGRlong *size
)
{
  IGRboolean rational;
  IGRuchar ss_props;
  IGRshort u_order, v_order;
  IGRlong u_num_poles, v_num_poles;
  IGRlong stat_OM=OM_S_SUCCESS;
  struct EMSbsplineSurfaceHeader *bspsf_hdr;
  struct EMSrevolvedSurfaceHeader *revsf_hdr;

  *msg = EMS_S_Success;

  ss_props = ME.EMSsubbs->ss_props;
  if ((ss_props & EMSformat) == EMSbsplineFormat)
  {
    bspsf_hdr = (struct EMSbsplineSurfaceHeader *) ME.EMSsubbs->packed_data;
    u_order = bspsf_hdr->u_order;
    v_order = bspsf_hdr->v_order;
    u_num_poles = bspsf_hdr->u_num_poles;
    v_num_poles = bspsf_hdr->v_num_poles;
    rational = bspsf_hdr->bs_props & EMSIS_RATIONAL;
  }
  else if ((ss_props & EMSformat) == EMSrevolvedFormat)
  {
    revsf_hdr = (struct EMSrevolvedSurfaceHeader *) ME.EMSsubbs->packed_data;
    u_order = revsf_hdr->order;
    v_order = V_ORDER;
    u_num_poles = revsf_hdr->num_poles;
    v_num_poles = V_NUM_POLES;
    rational = TRUE;
  }
  else
  {
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);
  }

  EMSbs_size (u_order, v_order, u_num_poles, v_num_poles, rational,
              0, (IGRlong *) NULL, *size);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMrvGetSize");
  return (stat_OM);
}

end implementation EMSrevol;
