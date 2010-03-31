/* ###################   APOGEE COMPILED   ################## */
class implementation EMSplane;

# include "msdef.h"
# include "maerr.h"
# include "bserr.h"
# include "bsparameters.h"
# include "OMerrordef.h"
# include "EMSerrordef.h"
# include "EMSbnddef.h"
# include "emsmacros.h"
# include "emsmapdef.h" /* For mapping options */
# include "emsedgedef.h" /* for edge type declarations */
# include <stdio.h>
# include "EMSprop.h"

# define TRUE    1
# define FALSE   0
# define NULL    0

from EMSloop import EMget_props;
from EMSloop import EMreverse;
from EMSloop import EMmake_lb_loop;
from EMSloop import EMset_props;
from EMSgradata import EMinit;

extern OMuword OPP_EMSloopset_class_id;
extern OMuword OPP_EMSloop_class_id;
extern OMuword OPP_EMSbsedge_class_id;
extern OMuword OPP_EMSgradata_class_id;

method EMplane_of_curve( IGRlong *EMmsg;
       struct GRvg_construct *arglist;
       struct GRlc_info *curve_lcinfo;
       struct IGRbsp_curve *incurve; 
       IGRuchar *curve_type;
       IGRboolean test_degeneracy;
       IGRboolean construct_loopset;
       IGRpoint point_in_solid;
       GRobjid *edgeids)
/* ********************************************************************
Description
        This method constructs a plane which encompasses a specific
        planar curve. This could either be a simple or a composite
        curve. 

Arguments
   Input
     *arglist     construct argument
     *curve_lcinfo locate information for the curve
     *incurve     the geometry of the curve. So the
                  calling method could either send in a curve
                  id, curve_md_info and set incurve to NULL or
                  and in the curve geometry and set curve_id
                  and curve_md_info to NULL
     test_degeneracy The method checks to see if the incoming
                     curve is degenerate if this is set to true
     construct_loopset If this is set to true, the method shall
                       impose this curve as a boundary on the
                       plane. If it is false, the method only
                       constructs the plane encompassing the 
                       curve 
     point_in_solid    If the orientation of the plane needs to
                       be set  then a point is sent in by the
                       caller else it is set to NULL
   Output
     *edgeids          If the caller is interested in the edgeids
                       he needs to send in a pointer to a preallocated 
                       array form returning the edgeids. If not
                       interseted the same may be set to NULL.
                                  
Warning
     No support for return of edgeids when an input is a
     composite curve.
     No support for an array of curve buffers.

Notes:
      Upon exit the completion message will have one of the following
      values:

                EMS_S_Success : if successful
                EMS_E_MAerror : If there was an error in calling one of
                                the MA routines.
                EMS_E_Fail -    if failure. A catch all error. Usually this
                                error should be less frequent. 
                EMS_E_InvalidCase : if the mapping routine returned
                                    something other than a 3d uv curve.
                EMS_E_InvalidArg  - if input curve is non-planar
                                    if the input curve is not closed
                                    if there are tolerance problems
                                     while closing in parametric space.
                EMS_E_LoopError : if there was an error in either getloops
                                  for imposition or EMmapcvxyz_to_uv.
                                  Getting or setting the properties of the
                                  loop.
                EMS_E_DynamicMemoryAllocated - if no memory could be allocated
                EMS_E_BSerror - if there is math error
                EMS_E_OMerror - if there was an error in calling an OM
                                routine
                EMS_E_SurfaceError - if there was an error in getting
                                the parametric tolerance.
                EMS_I_Degenerate - if the curve for which the plane is
                                   being determined is degenerate

        Note that if an error occurs then the object is deleted.

History
       NP       19-Aug-92		Modified for ANSI compliance. Changed
					"unsigned IGRxxx" to "IGRuxxx".
       DLB      06-Jun-92               Modified to call EMorient_plane to
                                        ensure a consistently oriented
                                        plane.
       Jack     05-June-91              Modified so the loopset is constructed
                                        and connected to its object before
                                        the GRconstruct is sent.  2.0.1 
                                        Horizon Loops.
       Inasu:   05/01/91                The new function EMmapcvxyz_to_uv()
                                       is used instead of old EMmapxyzcv_uvcv()
                                        (which no longer exists).
        SM      28-Mar-89               Argument change in 
                                        EMget_loops_for_imposition.
                                        Renamed function as EMget_mapped_data()
        PP      02/26/89                Added additional check to detect
                                        the creation of open loops.
        PP      09/21/88                Fixed a cleanup problem during
                                        failure condition while imposing
                                        a composite curve. Calling
                                        EMmapxyzcvto_uvcv instead of 
                                        EMgetbsbnds in order to be
                                        consistent with other impose
                                        boundary routines.
        PP      09/17/88                Constructs a better plane for
                                        conics than one obtained by taking
                                        the range box of the curve. 
        PP      01/26/88                Made changes to handle
                                        composite curves. The composite
                                        curve intelligence is maintained
                                        at the topology level.
        PP      12/01/87                Made modifications to support 
                                        setting of edge types
        PP      09/24/87                Added an option to test degeneracy.
                                        So if the curve being imposed is
                                        degenerate, no plane would
                                        be constructed.
        PP      06/11/87                Increased the dimensions of the plane
                                        that was being created by bleed_factor
                                        to avoid bleeding.
        PP      04/12/87                Changed the routine so that it
                                        accepts a incoming curve geometry as
                                        an alternative input to curveid. Also
                                        the method constructs a loopset if
                                        the flag is set to true and if the 
                                        incoming curve is closed
        LST     10/08/86                the beginning

************************************************************************ */

{
    IGRdouble   poles[4][3], u_knots[4], v_knots[4];
    IGRpoint    ufactor,
                vfactor;  /* factors to increase the plane dimensions */
    struct      IGRbsp_curve *curve;
    struct      GRprops geo_props;
    struct      IGRbsp_surface plane;
    struct EMSdataselect xyzcv, uvcv;
    GRobjid *loop_id_ptr;
    IGRboolean  nat_side;
    IGRboolean  is_degenerate = FALSE;
    IGRboolean  plane_posted = FALSE;
    IGRboolean  special_case = TRUE;
    IGRlong     rc;
    IGRint num_out_loops = 0;

    struct GRid *curve_id; 
    struct GRmd_env *curve_md_info ;
    OM_S_OBJID          loopset_id,
                        frtobjid,
                        loop_id;
    IGRshort            i;
    IGRlong     num_bytes,status;
    IGRlong     dummsg;
    IGRuchar    default_curve_type;
    IGRdouble   bleed_factor;
    extern     void        BSptonnsdsf ();
    extern     void        free();
    extern     char        *malloc();
    extern     IGRboolean  BSpl_of_cv();
    IGRlong    EFsspbtol_by_geom();

/*
 *  Initialization
 */
    *EMmsg = EMS_S_Success;
    status = OM_S_SUCCESS;
    curve = NULL;
    uvcv.data.curve = NULL;
    loop_id = NULL_OBJID;
    loopset_id = NULL_OBJID;
    frtobjid = NULL_OBJID;
    loop_id_ptr = &loop_id;

/*
 * The bleed factor is to take into account numerical problems while
 * mapping which might generate points lying outside the parametric
 * space.
 */

  BSEXTRACTPAR (&rc, BSTOLBASIS, bleed_factor);

  bleed_factor *= 100;

  if (curve_lcinfo)
  {
    curve_id = &curve_lcinfo->located_obj;
    curve_md_info = &curve_lcinfo->module_info;
  }
  else if (incurve)
  {
    curve_id = NULL;
    curve_md_info = NULL;
  }
  else
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

  if (curve_id)
  {
    status = om$send(msg = message GRvg.GRgeomprops(EMmsg,
                                   &curve_md_info->md_env.matrix_type,
                                   curve_md_info->md_env.matrix,
                                   &geo_props),
                     targetid = curve_id->objid,
                     targetos = curve_id->osnum);
    EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (geo_props.subtype == GRCC)
    special_case = FALSE;
   else
    special_case = TRUE;
  }

  if (curve_id && special_case)
  {
    status = EFget_the_edge_type_for_an_object (curve_id->objid,
                              curve_id->osnum, NULL, &default_curve_type);
    EMerr_hndlr (!status, *EMmsg, EMS_E_Fail, wrapup);
  }
  else
  {
   if (curve_type)
    default_curve_type = *curve_type;
   else
    default_curve_type = EMfreeform_curve;
  }


/*
 *  Get the curve definition
 */
    if (incurve)
      curve = incurve;
    else 
    {
    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetsize(
             EMmsg, &curve_md_info->md_env.matrix_type,
             curve_md_info->md_env.matrix, &num_bytes ),
                     senderid = my_id,
                     targetid = curve_id->objid,
                     targetos = curve_id->osnum );
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    curve = (struct IGRbsp_curve *) malloc( num_bytes );
    if( ! curve )
    {
        *(EMmsg) = EMS_E_DynamicMemoryAllocated; 
        return( OM_E_ABORT ); 
    }
    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetgeom(
             EMmsg, &curve_md_info->md_env.matrix_type,
             curve_md_info->md_env.matrix, (IGRchar *)curve ),
                     senderid = my_id,
                     targetid = curve_id->objid,
                     targetos = curve_id->osnum );
    EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    }
/*
 *  Get the surface definition
 */
    plane.poles = (IGRdouble *) poles;
    plane.weights = NULL;
    plane.u_knots = (IGRdouble *) u_knots;
    plane.v_knots = (IGRdouble *) v_knots;

    if (test_degeneracy)
    {
     BStstcvdegn (curve, &is_degenerate, &rc);
     EMerr_hndlr ((rc != BSSUCC), *EMmsg, EMS_E_BSerror, wrapup);
    }

    if (is_degenerate)
    {
     *EMmsg = EMS_I_Degenerate;
     goto wrapup;
    }

    EFpl_of_cv( EMmsg, curve, default_curve_type, &plane );
    EMerr_hndlr(!(1&*EMmsg), *EMmsg, *EMmsg, wrapup);

    (void) EMorient_plane(EMmsg, NULL, &plane, curve);  /*DLB 6/26/92*/

   plane.pos_orient = 0;  /*fix for umr */
    if (point_in_solid) /* if there is an orientation point coming in then
                           orient the surface */
    {
     (void) BSptonnsdsf (&plane, point_in_solid, &nat_side, EMmsg);
     EMerr_hndlr (BSERROR(*EMmsg), *EMmsg, EMS_E_BSerror,wrapup);

     *EMmsg = EMS_S_Success;

     if (! nat_side)
      plane.pos_orient = 0;
     else 
      plane.pos_orient = 1;
    }
/*
 * Increase the dimensions of the plane by a factor to avoid bleed problems
 * in display
 */

    for (i=0 ; i < 3; i++)
    {
     ufactor[i] = (plane.poles[3*1 + i] - plane.poles[3*0 + i]) * bleed_factor;
     vfactor[i] = (plane.poles[3*2 + i] - plane.poles[3*0 + i]) * bleed_factor;
    }
    
    
    for (i=0; i < 3; i++)
    {
     plane.poles[3*0 + i] = plane.poles[3*0 + i] - ufactor[i] - vfactor[i];
     plane.poles[3*1 + i] = plane.poles[3*1 + i] + ufactor[i] - vfactor[i];
     plane.poles[3*2 + i] = plane.poles[3*2 + i] - ufactor[i] + vfactor[i];
     plane.poles[3*3 + i] = plane.poles[3*3 + i] + ufactor[i] + vfactor[i]; 
    }

    arglist->geometry = (IGRchar *) &plane;
 
if (construct_loopset)
{
  IGRlong               msg_loc;

  IGRboolean            world;
  OM_S_CHANSELECT       to_surface,
                        to_loopset,
                        to_outter,
                        to_loops;

  IGRdouble             cht;
  IGRshort              is_planar;
  IGRboolean            all_points_on_srf;
  struct EMSpartolbasis partolbasis;

  IGRushort     props;
  struct IGRbsp_curve   *dummy;

 
  if (!curve->phy_closed)
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

  world = TRUE;

  BSEXTRACTPAR (&rc, BSTOLCHRDHT, cht);

  status = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = EMmake_chanselect (EMSloopset_to_surface, &to_surface);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = om$construct (classid = OPP_EMSloopset_class_id,
                         p_objid = &loopset_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = EMmake_chanselect (EMSloop_to_outter, &to_outter);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  status = EMmake_chanselect (EMSloopset_to_loops, &to_loops);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  /* connect the loopset to the plane */
  status = om$send (msg = message Root.connect (to_surface, 0,
                          my_id, OM_Gw_current_OS, to_loopset, 0),
                    targetid = loopset_id);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  /* get partolbasis */
  status = EFsspbtol_by_geom(EMmsg, &plane, &partolbasis);
  EMerr_hndlr (!status, *EMmsg, EMS_E_SurfaceError, wrapup);

  partolbasis.is_valid = TRUE;

  

  if (special_case)
  {
   IGRushort options = 0;

    xyzcv.datatype = EMSdata_curve3d;
    xyzcv.data.curve = curve;

    is_planar = EMS_O_Planar;

    EMmapcvxyz_to_uv(&msg_loc, options, &plane, &xyzcv, cht, partolbasis.tol,
                     &is_planar, &uvcv, &all_points_on_srf);
    EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_LoopError, wrapup);

    if (uvcv.datatype == EMSdata_curve3d)
      dummy = uvcv.data.curve;
    else
    {
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
     }

    status =om$construct (classid = OPP_EMSloop_class_id,
                          p_objid = loop_id_ptr);
    EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

    props = EMLP_EXTERNAL ; /* We initilaize the properties */

    status = om$send (msg = message EMSloop.EMmake_lb_loop (EMmsg, props, 1,
                            &dummy, &default_curve_type, &partolbasis, edgeids),
                      targetid = *loop_id_ptr);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    num_out_loops = 1;
 }
 else
 {
  struct GRid clip_ls;
  IGRushort options;

  clip_ls.objid = NULL_OBJID;

   options = EMMapBnd_NoValidate | EMMapBnd_StrokeIfNeeded 
            | EMMapBnd_WantBadCurves | EMMapBnd_NoClip | EMMapBnd_SurfIsPlane;

   loop_id_ptr = NULL;

   {
    struct EMSgetlp_output      junk;

    junk.num_objs = 0;
    junk.objs = NULL;

    EMget_mapped_data(1, /* Number of objects */
               NULL, /* input curve */
               curve_lcinfo, /* object information */
               arglist, /* construct list NUll because do not
                                    want xyz curves */
               &plane, /* surface */
               &partolbasis.tol, /* parametric tolerance */
               arglist->env_info, /* env */
               NULL, /* Do not want bad curves */
               NULL, /* No bad points */
               &junk, /* loop */
               NULL, /* Do not want xyz curves */
               clip_ls, /* Set to NULL_OBJID */
               options,
               NULL, /* No in planar info */
               EMmsg);
   loop_id_ptr = junk.objs;
   num_out_loops = junk.num_objs;
   EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_LoopError, wrapup);
  }

  if (num_out_loops != 1)
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }

  props = EMLP_EXTERNAL;

  status = om$send (msg = message EMSloop.EMset_props (EMmsg,props,1),
                    targetid = *loop_id_ptr);
  EMerr_hndlr (!(1&*EMmsg), *EMmsg, EMS_E_LoopError, wrapup);

 }


  /* connect the loop to the loopset */
  status = om$send(msg = message Root.connect(to_outter, 0, loopset_id,
                         OM_Gw_current_OS, to_loops, 0), 
                   senderid = loopset_id,
                   targetid = *loop_id_ptr);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  /*
   *  Fill the instance data and such
   */
  status = om$send(mode = OM_e_wrt_object,
                   msg  = message
           GRgraphics.GRconstruct(arglist),
                   senderid = my_id,
                   targetid = my_id );
  EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  plane_posted = TRUE;



/*
 * Construct and initialise frt object 
 */

   status = om$construct (classid = OPP_EMSgradata_class_id,
                          p_objid = &frtobjid,
                          msg = message EMSgradata.EMinit (EMmsg, my_id,
                                *loop_id_ptr));
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  

/*
 * Toggle the type of the loop and make it a p loop
 */

    props = 0;

    status = om$send (msg = message EMSloop.EMget_props(EMmsg, &props),
                      targetid = *loop_id_ptr);
    EMerr_hndlr(!(1&*EMmsg&status),*EMmsg,EMS_E_LoopError,wrapup);

    if (props & EMLP_OPEN)
    {
     *EMmsg = EMS_E_InvalidArg;
     goto wrapup;
    }

    if(!(props & EMLP_PLOOP))
     {
        status = om$send(msg=message EMSloop.EMreverse(EMmsg),
                        targetid = *loop_id_ptr);
        EMerr_hndlr(!(1&*EMmsg&status),*EMmsg,EMS_E_LoopError,wrapup);
     }
 }
else
 {
   /*
    *  Fill the instance data and such
    */
       status = om$send(mode = OM_e_wrt_object,
                        msg  = message
                GRgraphics.GRconstruct(arglist),
                    senderid = my_id,
                    targetid = my_id );
       EMerr_hndlr (!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

       plane_posted = TRUE;
 } 
 
 
                        
/*
 *  End of routine
 */
wrapup:

    if (!incurve) /* only if there is no incoming geometry coming in should
                     the memory be freed */
    {
     if (curve) free (curve);
    }

    if (uvcv.data.curve)
    {
     /* fix for mlk */
      if (uvcv.datatype == EMSdata_curve2d  || uvcv.datatype == EMSdata_curve3d)
      {
        BSfreecv (&rc, uvcv.data.curve);
      }
      else
      {
        om$dealloc(ptr = uvcv.data.poly);
      }
    }

    if ((! (1 & status & *EMmsg)) || (*EMmsg == EMS_I_Degenerate))
    {
     IGRlong cln_sts;

     if (plane_posted)
     {
     cln_sts = om$send (msg = message GRgraphics.GRdelete (&dummsg,
                              arglist->env_info),
                        targetid = my_id);
     }
     else
     {
       cln_sts = om$send (msg = message Root.delete (1),
                               targetid = my_id);
     }

       cln_sts = om$send (msg = message Root.delete (1),
                               targetid = loopset_id);

     for (i=0;i<num_out_loops;i++)
     {
       cln_sts = om$send (msg = message Root.delete (1),
                               targetid = loop_id_ptr[i]);
     }

    }
/*
 * If more than one loop was created because of tolerance problem then 
 * loop_id_ptr  will not be equal to the address of loop_id, which means 
 * has been malloced.
 */

    if ((loop_id_ptr) && (loop_id_ptr != (&loop_id)))
    {
      om$dealloc(ptr = loop_id_ptr);
    }

    EMWRAPUP (*EMmsg, status, "In EMSplane:EMplane_of_crv error");
    return( status );
 }

end implementation EMSplane;
