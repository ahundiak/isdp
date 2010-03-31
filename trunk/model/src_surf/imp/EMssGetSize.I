/* 
  DESCRIPTION
  
  This method returns the size in bytes of the internal
  format (B-spline surface) of the geometry of the object.


  HISTORY

   07/10/86 : rlw : The beginning
   09/21/86 : rlw : OM 4.0 conversion
   03/26/87 : rlw : Rewritten to use macro I wrote
   04/04/95 : SS  : Rewritten for speed.
*/  

class implementation EMSsubbs;

#include "EMSssprops.h"
#include "EMSsubbs.h"
#include "EMScmacros.h"

method GRgetsize
(
  IGRlong *msg; 
  IGRshort *mat_type; 
  IGRmatrix matrix;
  IGRlong *size
)
{
  IGRboolean rational;
  IGRshort u_order, v_order;
  IGRlong u_num_poles, v_num_poles;
  IGRlong stat_OM=OM_S_SUCCESS;
  struct EMSbsplineSurfaceHeader *bspsf_hdr;

  *msg = EMS_S_Success;

  bspsf_hdr = (struct EMSbsplineSurfaceHeader *) ME.EMSsubbs->packed_data;
  u_order = bspsf_hdr->u_order;
  v_order = bspsf_hdr->v_order;
  u_num_poles = bspsf_hdr->u_num_poles;
  v_num_poles = bspsf_hdr->v_num_poles;
  rational = bspsf_hdr->bs_props & EMSIS_RATIONAL;

  EMSbs_size (u_order, v_order, u_num_poles, v_num_poles, rational,
              0, (IGRlong *) NULL, *size);

  return (stat_OM);
}

end implementation EMSsubbs;
