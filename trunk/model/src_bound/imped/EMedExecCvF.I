/* ###################   APOGEE COMPILED   ################## */
/*
  SM    20-Jan-88       Added argument 'eligible_edge_type'. If the edge is not
                        of the specified type, exit.
                        see file include/emseligible.h
  SM    02-Jun-88       Pass edge type to the callers function.
  SM    13-Sep-89       Try to get intelligent curve type for iso edges.
                        Also, upon any error set the return code to 
                        EMS_I_Fail instead of aborting.
  SM    22-Sep-89       Instead of checking explicit classids (like GR3dlineseg
                         ) check for GRlinear being in the ancestry for the
                        edgetype of an iso edge.
  Jack  02-Oct-92       Added code to just exit if this edge is marked tangent
                        and tangent edges are supressed.
*/

class implementation EMSedge;

# include "OMmacros.h"
# include "emseligible.h"
# include "emsdef.h"
# include "emsedgedef.h"
# include "emssfcvs.h"
# include "EMSlcdef.h"

#ifndef DEBUG
#define DEBUG 0
#endif

from EMSlinedge import EMsetIsoType;

extern IGRint   EFrule_lines_on_off();
extern void     EMSsubbs_get_locate_window();
extern void     GRdv_tangent_edge_display();

extern OMuword    OPP_EMSpartedge_class_id,
                  OPP_EMSptedge_class_id,
                  OPP_EMSgraloop_class_id;

method EMexecuteCurveFunction(IGRlong *EMmsg;struct IGRbsp_surface *surf;
                              IGRshort *mx_type; IGRmatrix mx;
                              GRobjid surf_id;IGRint (*f)();IGRchar *args;
                              IGRboolean *first_edge;
                              IGRushort eligible_edge_type)
{
  IGRlong               sts;
  struct IGRbsp_curve   edge_geometry;
  struct IGRpolyline    poly;
  GRobjid               window_id;
  GRspacenum            window_os;
  GRobjid               topedge=NULL_OBJID;
  struct EMSedgebound   par,
                        two_par[2];
  struct EMSpartolbasis partol_basis;
  OMuint                count=0;  
  OM_S_OBJECT_LINKAGE  *channel_objects = NULL;
  IGRint                cnt=0,
                        graloop_edge=0;
  OMuword               my_classid;
  OM_S_CHANSELECT       chan_to_owner;
  IGRint                inquire_only,
                        turn_on,
                        display_on;




  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * Initialize
   */

  edge_geometry.poles = NULL;
  edge_geometry.weights = NULL;
  edge_geometry.knots = NULL;
  edge_geometry.num_boundaries = 0;
  edge_geometry.bdrys = NULL;
  poly.points = NULL;
  poly.num_points = 0;

  if(me->ed_props & EMED_NO_DISPLAY) goto wrapup;

  EMSsubbs_get_locate_window(&window_id, &window_os);
  if((me->ed_props & EMED_SEAM) && (me->ed_props & EMED_TANGENT))
    if(! EFrule_lines_on_off(window_id, window_os)) goto wrapup;


  /*
   * determine if this edge is in a graphic loop.  if so,
   * don't suppress display if tangent and tangent edge display is off.
   */

  sts = om$get_classid( object = me,
                        p_classid = &my_classid );
  if(! (1 & sts)) goto wrapup;

  /*
   * if I am an EMSptedge, I will be the topedge
   */
  if((sts = om$is_ancestry_valid(subclassid = my_classid,
                  superclassid = OPP_EMSptedge_class_id)) !=
                                                      OM_S_SUCCESS)
  {
    
  /*
   * if I am an EMSpartedge, use instance data for parameter on edge
   */
  if((sts = om$is_ancestry_valid(subclassid = my_classid,
                  superclassid = OPP_EMSpartedge_class_id)) ==
                                                      OM_S_SUCCESS)
   {
    sts = om$send(msg = message EMSedge.EMgetbounds(
                                EMmsg,
                                two_par),
                 targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;
    par=two_par[0]; 
   }
  else
   {
    sts = OM_S_SUCCESS;  /* reset sts */
    par.param = 0.0;
    par.span_inx = 0;
   }

   
   partol_basis.tol = NULL;
   partol_basis.is_valid = FALSE;
   partol_basis.in_world = FALSE;
   partol_basis.mattyp = mx_type;
   partol_basis.mat = mx;

   /* first, get the top edge for this edge */
   sts = om$send(msg = message EMSedge.EMgettopedge(
                              EMmsg,
                             &par,
                             &partol_basis,
                             &topedge),
                 targetid = my_id);
   if(! (1 & *EMmsg & sts)) goto wrapup;

   /*
    * topedge above was initialized to NULL_OBJID.  if it is
    * still NULL_OBJID, then Sunit said that I can assume I 
    * am the top edge.
    */
   if(topedge==NULL_OBJID)
     topedge = my_id;
  
  } /* end if not EMSptedge */
 else topedge = my_id;

   EMmake_chanselect (EMSedge_to_owner, &chan_to_owner);

   sts = om$get_channel_count(objid = topedge,
                              p_chanselect = &chan_to_owner,
                              count = &count);
   if(! (1 & sts)) goto wrapup;
   
  if(count)
   {
    channel_objects = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(
                                             OM_S_OBJECT_LINKAGE) * count);

    sts = om$get_channel_objects(objid = topedge,
                                 p_chanselect = &chan_to_owner,
                                 list = channel_objects,
                                 size = count,
                                 count = &count);
    if(! (1 & sts)) goto wrapup;

    graloop_edge = 0;
    for(cnt=0;cnt<count;cnt++)
     {
      sts = om$get_classid( osnum = channel_objects[cnt].osnum,
                            objid = channel_objects[cnt].S_objid,
                            p_classid = &my_classid );
      if(! (1 & sts)) goto wrapup;

      if((sts = om$is_ancestry_valid(subclassid = my_classid,
                      superclassid = OPP_EMSgraloop_class_id)) ==
                                                          OM_S_SUCCESS)
        graloop_edge=1;
      else
        sts = OM_S_SUCCESS;  /* reset sts */

     }     
     
   }  


 if(!graloop_edge)
  if(me->ed_props & EMED_TANGENT)
   {
     inquire_only=1;
     turn_on=1; /* won't be used */
     GRdv_tangent_edge_display(inquire_only,
                               turn_on,
                              &display_on);
     if(!display_on)
       goto wrapup;          /* if this edge is tangent and tangent edge
                              * display is toggled off, just exit
                              */
   }



  /* block */
  {
    IGRchar               *geom;
    IGRuchar      cvtype;
    struct GRmdenv_info   env;
    extern IGRboolean     EFisEdgeTypeLinear();
    struct EMSinvoker_info my_info;
    IGRboolean            msc_exists;
    OM_S_CHANSELECT       to_common;
    extern IGRint         EMmake_chanselect();
    OM_S_OBJID            MSCid;

    cvtype = ME.EMSedge->curve_type;
    if(mx_type) env.matrix_type = *mx_type;
    if(mx) OM_BLOCK_MOVE(mx, env.matrix, sizeof(IGRmatrix));
    my_info.flags = EMSexecCvF_Edge;
    my_info.obj.objid = my_id;
    my_info.obj.osnum = OM_Gw_current_OS;
    msc_exists = ME.EMSedge->ed_props & EMED_MSCEXISTS ? TRUE : FALSE;

    sts = om$send(msg = message EMSboundary.EMgetxyzobj(EMmsg,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &MSCid),
                  targetid = my_id);
    if(!(1 & sts & *EMmsg)) goto wrapup;

    msc_exists = *EMmsg == EMS_I_NotFound ? FALSE : TRUE;

    if(!msc_exists)
     {
      IGRushort   com_props = NULL;
      EMmake_chanselect(EMSedge_to_common_edge, &to_common);

      sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &com_props), 
                          p_chanselect = &to_common);
      msc_exists = com_props & EMED_MSCEXISTS ? TRUE : FALSE;

      sts = om$send(msg = message EMSboundary.EMgetxyzobj(EMmsg,
                                                    EMSlcopt_existingmsc,
                                                    NULL, NULL, NULL,
                                                    NULL, NULL,
                                                    OM_Gw_current_OS, &MSCid),
                    p_chanselect = &to_common);
      if(!(1 & sts & *EMmsg)) goto wrapup;

      msc_exists = *EMmsg == EMS_I_NotFound ? FALSE : TRUE;
     }

    if( (eligible_edge_type & EMSeligible_NonSubEdge) &&
        (ME.EMSedge->ed_props & EMED_SUBORDINATE)) goto wrapup;

    if( (eligible_edge_type & EMSeligible_NonNatEdge) &&
        (ME.EMSedge->ed_props & EMED_NATURAL)) goto wrapup;
    
    if( (eligible_edge_type & EMSeligible_NonSeamEdge) &&
        ( (ME.EMSedge->ed_props & EMED_SEAM) && 
          (ME.EMSedge->ed_props & EMED_SUBORDINATE))) goto wrapup;

    if( (eligible_edge_type & EMSeligible_NonDegenerateEdge) &&
        (ME.EMSedge->ed_props & EMED_DEGENERATE)) goto wrapup;

    if( (eligible_edge_type & EMSeligible_NonMscEdge) &&
        msc_exists) goto wrapup;

    if( (eligible_edge_type & EMSeligible_MscEdge) &&
        !msc_exists) goto wrapup;

    if(eligible_edge_type & EMSeligible_ParametricGeom)
     {
       if(eligible_edge_type & EMSeligible_BSplineGeom)
        {
          sts = om$send(msg = message EMSedge.EMgetbcgeom(EMmsg, 0, MAXINT, 
                                          FALSE, NULL, &edge_geometry, NULL, 
                                          NULL), 
                                          targetid = my_id);
          if(!(1&sts&*EMmsg)) goto wrapup;
          geom = (IGRchar *) &edge_geometry;      
        }
       else
        {
          sts = om$send(msg = message EMSedge.EMgetpygeom(EMmsg, 0, MAXINT, 
                                          FALSE, NULL, &poly, NULL, NULL), 
                                          targetid = my_id);
          if(!(1&sts&*EMmsg)) goto wrapup;
          geom = (IGRchar *) &poly;       
        }
     }
    else
     {
       struct GRid surf_grid;

       surf_grid.objid = surf_id;
       surf_grid.osnum = OM_Gw_current_OS;

       sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(EMmsg, 
                    mx_type && mx ? &env : NULL,
                    &surf_grid, surf, 0, MAXINT, FALSE, NULL, &edge_geometry),
                    targetid = my_id);
       if(! (1 & *EMmsg & sts)) goto wrapup;
       geom = (IGRchar *) &edge_geometry;

  
       /* If iso curve type is linear or general bspline curve, try to get
          an intelligent curve type.
       */
       if( (ME.EMSedge->ed_props & EMED_ISO) &&
           (EFisEdgeTypeLinear(cvtype) || (cvtype == EMfreeform_curve)))
        {
         /* Get iso curve type. Do not update instance data with that curve
            type.
         */
         sts = om$send(msg = message EMSlinedge.EMsetIsoType(EMmsg, surf_id, 
                          &cvtype, NULL, NULL, FALSE), targetid = my_id);
         sts = OM_S_SUCCESS;
         *EMmsg = EMS_S_Success;
        }

     }

    if(*first_edge) 
     { my_info.flags |= EMSexecCvF_FirstEdge; *first_edge = FALSE; }
    my_info.cvtype = &cvtype;
    *EMmsg = (*f)(geom, args, &my_info);

    /* upon failure try constructing free form curve.
    */
    if(!(1&*EMmsg) && (cvtype != EMfreeform_curve))
     {
      IGRuchar loc_cvtype = EMfreeform_curve;

#if DEBUG
      printf("Failure with curve type %d\n", cvtype);
#endif
      my_info.cvtype = &loc_cvtype;
      *EMmsg = (*f)(geom, args, &my_info);
     }

    if(*EMmsg IS EMS_I_Stop) sts = OM_I_STOP_SENDING;
  }

wrapup:
  if(edge_geometry.poles) om$dealloc(ptr = edge_geometry.poles);
  if(edge_geometry.weights) om$dealloc(ptr = edge_geometry.weights);
  if(edge_geometry.knots) om$dealloc(ptr = edge_geometry.knots);
  if(poly.points) om$dealloc(ptr = poly.points);

  EMWRAPUP(*EMmsg, sts, "In EMSedge.EMexecuteCurveFunction")

  if(!(1&*EMmsg)) *EMmsg = EMS_I_Fail;
  if(sts != OM_I_STOP_SENDING) sts = OM_S_SUCCESS;
  return(sts);
}

end implementation EMSedge;
