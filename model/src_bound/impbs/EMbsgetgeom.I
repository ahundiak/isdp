/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include "emsmacros.h"		/* for EMWRAPUP */
#include "bserr.h"
#include "bstypes.h"		/* for BSrc */
#include "bsparameters.h"

/*
 * This constant is a measure of the maximum number of poles that may
 * be found in most bspline edges. This estimate is used to make room for
 * local arrays to hold these poles.
 */

#define LOCAL_NUM_POLES  20

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
        Upon exit, the return code may be
        - EMS_S_Success        if successfull
        - EMS_E_EdgeError      if failure occurs when an edge 
                               method is invoked.
        - EMS_E_SurfaceError   error when a surface method is invoked.
        - EMS_E_NoDnamicMemory
        - EMS_E_BSerror

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
        RC      : 05/25/87      Creation Date
        RC      : 11/03/87      Modified for version 1.1.0
        RC      : 03/16/88      Modified to test if the edge
                                is degenerate.
	SS	: 05/19/88      Removed code to check if the
                                partedge is degenerate. Some attempt
				optimization.

Description
	This method evaluates the edge in the (xyz) space
	and returns its geometry in a B-spline format.

Algorithm
	o find out if the surface geometry is passed in by
	  the caller.

	o If not, find out if the surface GRid is passed in
	  by the caller.

    	o If not, get the surface GRid and then get its geometry.

	o Evaluate the edge in the (u,v) space and then
	  convert it into (xyz) space by evaluating it on the
	  surface.
*/		

{
    IGRlong                OM_stat;
IGRlong   mthd_stat;
    IGRint                 i, j, k, num_poles;
    IGRushort      ed_props;
    IGRdouble		   poles2dmem[LOCAL_NUM_POLES][2], *poles2d;
    IGRdouble		   *genptr1, *genptr2;
    GRobjid                user_id;
    BSrc                   rc;
    IGRboolean             status, EFmap_uv_to_xyz_for_planes();
    struct IGRbsp_surface  *surface;
    IGRdouble              cht_tol;
	
    *EMmsg = EMS_S_Success;
    OM_stat = OM_S_SUCCESS;

    poles2d = NULL;
    num_poles = 0;
    surface = srf_geom;

    if (partinfo) user_id = partinfo->edid;
    else user_id = my_id;


    /*
     * find out if the surface is passed along
     */

    if (!surface )
    {
          struct GRid loc_srfid;

          if (!srf_id)
          {
            OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info 
                       (&mthd_stat, &loc_srfid.objid, NULL), 
                       targetid = user_id);
            EMerr_hndlr (EMSerror (OM_stat & mthd_stat), *EMmsg, 
             EMS_E_EdgeError, wrapup);
            loc_srfid.osnum = OM_Gw_current_OS;
          }
          else
          {
            loc_srfid = *srf_id;
          }

          OM_stat = EMgetvggeom (&mthd_stat, &mdenv->matrix_type,
                     mdenv->matrix, &loc_srfid, &surface, NULL);
          EMerr_hndlr (EMSerror (OM_stat & mthd_stat), *EMmsg, 
           EMS_E_SurfaceError, wrapup);
    }

    /*
     * make sure that the surface satisfies the linear mapping
     * criterion. If not something is messed up.
     */

    if (!( (surface->u_order == 2) && (surface->v_order == 2) &&
           (surface->planar) && (!surface->rational) ))
    {
       *EMmsg = EMS_E_InvalidArg;
       goto wrapup;
    }

    /*
     * get (u,v) space geomtery of the edge
     */

    OM_stat = om$send (msg = message EMSedge.EMgetbcgeom ( &mthd_stat, 
                        from_spaninx, num_spans, reverse, partinfo, 
                        curve, NULL, NULL),
                       targetid = my_id);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

    /*
     * convert the Poles from (u,v) space to (x,y,z) space
     * Since B-spline edges are placed on the plane,
     * a faster routine is invoked for evaluation.
     */

    num_poles = curve->num_poles;
    if (num_poles > LOCAL_NUM_POLES)
      {
      poles2d = (IGRdouble *) om$malloc (size = num_poles * 2 *
                 sizeof (IGRdouble));
      EMerr_hndlr (!poles2d, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      }
    else
      poles2d = (IGRdouble *)poles2dmem;
	
    genptr1 = curve->poles;
    genptr2 = curve->weights;
    for (i = 0, j = 0, k = 0; i < num_poles; i++, j+=2, k+=3)
    {
        poles2d[j] = genptr1[k];
        poles2d[j+1] = genptr1[k+1];

        if (curve->rational)
        {
           poles2d[j] /= genptr2[i];
           poles2d[j+1] /= genptr2[i];
        }

    } /* for (i = 0; i < curve->num_poles; i++) */

    status = BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht_tol); 

    status =  EFmap_uv_to_xyz_for_planes( &mthd_stat, surface, cht_tol,
                   num_poles, poles2d, curve->poles);
    EMerr_hndlr(!status || !(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

    if (curve->rational)
      {
      genptr1 = curve->poles;
      genptr2 = curve->weights;
      for ( i = 0, k = 0; i < num_poles; i++, k+=3)
          for (j = 0; j < 3; j++)
              genptr1[k+j] *= genptr2[i];
      }

    /*
     * Removed the code that checked for degeneracy. Replaced it instead
     * with a check in the property bits.
     */

    if (partinfo)
      ed_props = partinfo->edprops;
    else
      ed_props = ME.EMSedge->ed_props;

    if (ed_props & EMED_DEGENERATE)
      *EMmsg = EMS_I_DegenerateEdge;

wrapup:

  if (!srf_geom) om$dealloc (ptr = surface);
  if (poles2d && num_poles > LOCAL_NUM_POLES) om$dealloc (ptr = poles2d);

  EMWRAPUP (*EMmsg,OM_stat,"In EMSbsedge.EMget_bcxyz_geom");

  return (OM_stat);

}

end implementation EMSbsedge;




/*
  Piece of code removed from above. Left verbatim except fro slashes.

   *
    * It may be possible that the edge/part_edge is 
    * degenerate in model space but is not flagged in
    * properties. 
    *

   if (!partinfo)
     ed_props = me->ed_props;
   else
   {
     OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                         &ed_props),
                        targetid = user_id);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

   } * if (!partinfo) *

   if (!(ed_props & EMED_DEGENERATE))
   {
     OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
     EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);
 
     OM_stat = om$get_channel_count (objid = user_id,  
                      p_chanselect = &cm_ed_chan, count = &num_cm_ed);
     EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

     if (!num_cm_ed)
     {
       (void) BStstcvdegn (curve, &is_degn, &rc);
       EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

       if (is_degn)
       {

         *EMmsg = EMS_I_DegenerateEdge;

       } * if (is_degn) *
     
     } * if (!num_cm_ed) *

   } * if (!(ed_props & EMED_DEGENERATE)) *
*/
