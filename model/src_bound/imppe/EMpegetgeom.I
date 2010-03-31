/* ###################   APOGEE COMPILED   ################## */
class implementation EMSpartedge;

#include "EMS.h"
#include "emsmacros.h"		/* for EMWRAPUP */
#include "bstypes.h"		/* for BSrc */
#include "OMmacros.h"

method EMget_bcxyz_geom (
  IGRlong		*EMmsg;
  struct GRmdenv_info  	*mdenv;
  struct GRid		*srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRint		from_spaninx;
  IGRint		num_spans;
  IGRboolean		reverse;
  struct EMSpartedinfo  *partinfo;
  struct IGRbsp_curve 	*curve)

/*
Notes

    This method gets the model space bspline geometry of the part edge.  
    If the poles, weights, knots fields in bsgeom are set to null, 
    the method appropriately allocated memory for the same.  Otherwise 
    it assumes that memory has been allocated.  

*mdenv - input-  is the environment info the surface, 
         the edge is a part of. If the srf_geom is sent, 
         it can be set to NULL

*srf_id - input - if not known, the caller should set it 
          to NULL. If the srf_geom is sent, the caller can
          set it to NULL.

srf_geom - input - if not known, it should be set to NULL.

*curve - output - the curve containing the B-spline (xyz) space
         geometry of the edge. The caller should allocate memory
         for the struct IGRbsp_curve. If caller allocates memory
         for curve->poles, knots, weights, it should be enough.
         Otherwise curve->poles, knots and weights should be 
         initailized to NULL.
         
         The caller has the responsibility of deallocating memory
         for curve->poles, curve->knots and curve->weights.

History
	RC	: 03/18/87	Creation Date
        RC        11/03/87      Modified for version 1.1.0
       Jack      25-Jan-93      Added code to catch an empty to_comps
                                channel and return an error.
                                

Description
	This method evaluates the edge in the (xyz) space
	and returns its geometry in a B-spline format.

*/		

{
   IGRlong                OM_stat;
   IGRlong                mthd_stat = EMS_S_Success;
   OM_S_CHANSELECT        pe_ed_chan;
   struct EMSpartedinfo   mypartinfo;
  
   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   pe_ed_chan.type = OM_e_addr;
   pe_ed_chan.u_sel.addr = &ME.EMSbd_owner->to_comps;

   if (!partinfo)
   {
      EMput_partinfo (mypartinfo);
      partinfo = &mypartinfo;
    }
       
    OM_stat = om$send (msg = message EMSedge.EMget_bcxyz_geom (
                        &mthd_stat, mdenv, srf_id, srf_geom, from_spaninx,
                         num_spans, reverse,  partinfo, curve),
                       p_chanselect = &pe_ed_chan);
    if(OM_stat == OM_I_CHAN_EMPTY)
       OM_stat = OM_E_INVCHAN;
  
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

wrapup:
  EMWRAPUP (*EMmsg,OM_stat,"In EMSpartedge.EMget_bcxyz_geom");

  return (OM_stat);

}
end implementation EMSpartedge;
