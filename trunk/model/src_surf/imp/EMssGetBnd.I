/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
# include "gocmacros.h"     /* GRgetabsg    */
# include "EMSmsgdef.h"
# include "EMSlogic.h"
# include "EMStypedef.h"
# include "EMScmacros.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"

from EMSloopset import EMpack;

method EMget_boundaries(IGRlong *EMmsg;
                        IGRshort *matrix_type;
                        IGRmatrix matrix;
                        IGRboolean *on_off;
                        IGRshort *num_boundaries;
                        struct IGRbsp_bdry_pts **bdrys)
{
  IGRlong               sts;
  IGRint                num_bdrys;
  OM_S_CHANSELECT       to_loopset;
  struct EMSpartolbasis ptol, *ptol_arg = NULL;
  struct IGRbsp_surface *surface = NULL;
  struct EMSdataselect	surf_data;
  IGRushort	pack_options = NULL;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  to_loopset.type = OM_e_addr;
  to_loopset.u_sel.addr = &ME.EMSsubbs->to_loopset;
  num_bdrys = 0;

  if(matrix_type && matrix)
  {
    /*
     * Get the surface geometry
     */
    GRgetabsg(EMmsg, matrix_type, matrix, (IGRchar **) &surface, 1);

    /*
     * Get the parametric tolerance
     */
    sts = EFsspbtol_by_geom(EMmsg, surface, &ptol.tol);
    if(! (1 & *EMmsg & sts)) goto wrapup;
    ptol.in_world = TRUE;
    ptol.is_valid = TRUE;
    ptol.mattyp = matrix_type;
    ptol.mat = matrix;

    ptol_arg = &ptol;
    surf_data.datatype = EMSdata_surface;
    surf_data.data.surface = (struct IGRbsp_surface *) surface;
  }
 else {*EMmsg = EMS_E_InvalidArg; goto wrapup;}
	
  /*
   * Pack
   */
  sts = om$send(msg = message EMSloopset.EMpack(EMmsg, on_off,
                &num_bdrys, bdrys, &surf_data, matrix_type, matrix, 
		pack_options, ptol_arg), p_chanselect = &to_loopset);
  *num_boundaries = (IGRshort) num_bdrys;

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsubbs.EMget_boundaries")
  return(sts);
}

end implementation EMSsubbs;
