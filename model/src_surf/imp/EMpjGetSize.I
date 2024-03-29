/* 
  DESCRIPTION
  
  This method returns the size in bytes of the internal
  format (B-spline surface) of the geometry of the object.


  HISTORY

  SS  :  04/04/95  :  Creation
*/  

class implementation EMSproject;

#include "EMSssprops.h"
#include "EMSsubbs.h"
#include "EMSproject.h"
#include "EMScmacros.h"

#define V_ORDER 2
#define V_NUM_POLES 2

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
  struct EMSprojectedSurfaceHeader *prjsf_hdr;

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
  else if ((ss_props & EMSformat) == EMSprojectedFormat)
  {
    prjsf_hdr = (struct EMSprojectedSurfaceHeader *) ME.EMSsubbs->packed_data;
    u_order = prjsf_hdr->order;
    v_order = V_ORDER;
    u_num_poles = prjsf_hdr->num_poles;
    v_num_poles = V_NUM_POLES;
    rational = prjsf_hdr->pj_props & EMSIS_PJ_RATIONAL;
  }
  else
  {
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);
  }

  EMSbs_size (u_order, v_order, u_num_poles, v_num_poles, rational,
              0, (IGRlong *) NULL, *size);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMpjGetSize");
  return (stat_OM);
}

end implementation EMSproject;
