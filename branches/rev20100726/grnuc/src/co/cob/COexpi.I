class implementation COexp;



#include "coimport.h"
#include "codebug.h"
#include "grerr.h"
#include "codef.h"
#include "dedef.h"
#include "maerr.h"
#include "igr.h"
#include "msdef.h"
#include "igrmacros.h"
#include "coniarray.h"
#include "griomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "comiscmac.h"
#include "lcmacros.h"
#include <tools.h>
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "referr.h"
#include "exmacros.h"
#include "comnmacros.h"

from GRgraphics  import  GRxform,
                         GRdelete,
                         GRdisplay,
                         GRgetrang;
from GRvg        import  GRgetgeom,
                         GRgetsize,
                         EMintplane;



method filter ( int filter ; int * response ; char * response_data )
{
  int		  status = OM_S_SUCCESS;

    IGRint     sts;

    _m_debug_str( "COexp.filter." );

    sts = OM_S_SUCCESS;
    status = OM_S_SUCCESS;

    status = om$send( mode = OM_e_wrt_message,
                      msg = message CEO_GSLOCATE.filter( filter,
                                                         response,
                                                         response_data ),
                      targetid = my_id );
    _m_checkp( status, "COexp.filter - failed default.filter" );
    _m_checkq( status );
quit:
  return OM_S_SUCCESS;
}

method set_manual_explode ( int     *sts;
                           int      flag )
{
  int		  status = OM_S_SUCCESS;

   if( flag == 0 )
     me->manual_mode = FALSE;
   else
     me->manual_mode = TRUE;
quit:
  return OM_S_SUCCESS;
}

method check_manual_explode ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   if( me->manual_mode == TRUE )
     *sts = MSSUCC;
   else
     *sts = MSFAIL;
quit:
  return OM_S_SUCCESS;
}

method move_along_vec ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong             msg;
    IGRdouble           t_parm,
                        delta[3],               /* translation vector */
                        point[3],
                        proj_pt[3],
                        vector1[3],
                        vector2[3],
                        t_matrix[16];
    IGRboolean          b_status;
    struct IGRline      line;
    struct GRevent     *events[4];
    extern IGRboolean   MAptlnproj(),
                        MAtrlmx();

    msg = MSSUCC;
    _m_debug_str( "COexp.move_along_vec." );

    events[0] = &me->first_event;     /* vector start point */
    events[1] = &me->second_event;    /* vector end point   */
    events[2] = &me->third_event;     /* element from point */
    events[3] = &me->fourth_event;    /* element to point   */

    /* get the delta of the vector points */
    delta[0] = events[1]->event.button.x - events[0]->event.button.x;
    delta[1] = events[1]->event.button.y - events[0]->event.button.y;
    delta[2] = events[1]->event.button.z - events[0]->event.button.z;

    /* add the delta of the vector to the from point to generate
     * a infinite line to project the to point onto
     */
    vector1[0] = events[2]->event.button.x;
    vector1[1] = events[2]->event.button.y;
    vector1[2] = events[2]->event.button.z;
    vector2[0] = events[2]->event.button.x + delta[0];
    vector2[1] = events[2]->event.button.y + delta[1];
    vector2[2] = events[2]->event.button.z + delta[2];

    point[0] = events[3]->event.button.x;
    point[1] = events[3]->event.button.y;
    point[2] = events[3]->event.button.z;

    line.point1 = &vector1[0];
    line.point2 = &vector2[0];

    /* project to point on the direction vector */
    b_status = MAptlnproj(&msg,
                          &point[0],
                          &line,
                          &proj_pt[0],
                          &t_parm );

    /* get the vector between the to and from points on vector */
    delta[0] = proj_pt[0] - events[2]->event.button.x;
    delta[1] = proj_pt[1] - events[2]->event.button.y;
    delta[2] = proj_pt[2] - events[2]->event.button.z;

    /* get a transformation matrix */
    b_status = MAtrlmx(&msg, 
                        delta, 
                        t_matrix );
    _m_checkp(msg,"COexp - move_along_vec.MAtrlmx failed");

    /* translate objects on located channel */
    status = co$tform( msg    = &msg,
                       module = &me->ModuleInfo,
                       matrix =  t_matrix,
                       gschan = &me->located_chansel );
    _m_check2p(status,msg,"COexp - move_along_vec.tform failed");
quit:
  return OM_S_SUCCESS;
}

method DYmove_vector ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong         msg;
    extern IGRint   DYmv_along_vec();

    status = OM_S_SUCCESS;
    *sts = MSSUCC;

    if( vsd_and_queue_empty )
    {
       ex$message( in_buff       = me->prompt,
                   field         = PROMPT_FIELD,
                   justification = RIGHT_JUS );
    }

    status = DYmv_along_vec( &msg,
                              my_id,
                              OM_Gw_current_OS,
                             &me->first_event.event.button,
                             &me->second_event.event.button,
                             &me->third_event.event.button,
                             &me->ModuleInfo,
                             &me->located_chansel,
                              NULL );
quit:
  return OM_S_SUCCESS;
}

method get_stationary ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint               loop,
                        loop2,
                        num_pnts,
                        num_ovl_pnts;
   IGRlong              msg,
                        size,
                        which_err,
                        segment_num,
                        ret_size;
   OMuint               num_objects_found;
   IGRpoint             proj_point,
                        lo_point,
                        hi_point,
                        point_on_viewplane;
   IGRdouble            t_parm,
                        lo_parm = 0.0,
                        hi_parm = 0.0,
                        dir_points[6];
   IGRvector            dir_vector,
                        view_vector,
                        norm_to_cut_plane;
   IGRboolean           b_status,
                        bad_object,
                        range_process;
   GRclassid            elem_classid;
   struct GRid          located_object,
                        window_grid;
   struct IGRplane      viewplane,
                        cutting_plane;
   struct IGRpolyline   expl_axis;
   struct var_list      var_list[2];
   struct GRobj_env    *object_list = 0;
   OM_S_OBJECT_LINKAGE  channel_linkage[1];
   extern IGRboolean    MAunitvc(),
                        MAcrossvc(),
                        MAptpyproj(),
                        BSpl_cv_int();


   /* initialize instance data */
   me->stationary_guy.lo_parm = 100.0;
   me->stationary_guy.hi_parm = -1.0;

   bad_object = FALSE;

   /* load direction vector points (world coordinates) */
   dir_points[0] = me->first_event.event.button.x;
   dir_points[1] = me->first_event.event.button.y;
   dir_points[2] = me->first_event.event.button.z;

   dir_points[3] = me->second_event.event.button.x;
   dir_points[4] = me->second_event.event.button.y;
   dir_points[5] = me->second_event.event.button.z;

   /* unitize direction vector */
   dir_vector[0] = dir_points[3] - dir_points[0];
   dir_vector[1] = dir_points[4] - dir_points[1];
   dir_vector[2] = dir_points[5] - dir_points[2];

   b_status = MAunitvc(&msg,
                       &dir_vector[0],
                       &dir_vector[0] );

   expl_axis.num_points = 2;
   expl_axis.points = dir_points;
  
   window_grid.osnum = me->first_event.event.button.osnum;
   window_grid.objid = me->first_event.event.button.objid;

   viewplane.point  = point_on_viewplane;
   viewplane.normal = view_vector;
  
   var_list[0].var            =  VIEW_PLANE;
   var_list[0].var_ptr        = (IGRchar *)&viewplane;
   var_list[0].num_bytes      =  sizeof ( struct IGRplane );
   var_list[0].bytes_returned = &ret_size;
  
   var_list[1].var = END_PARAM;
  
   status = dp$inq_set_gragad( msg          = &msg,
                               osnum        =  window_grid.osnum,
                               gragad_objid =  window_grid.objid,
                               which_error  = &which_err,
                               var_list     =  var_list );

   b_status = MAcrossvc(&msg,
                         dir_vector,
                         viewplane.normal,
                         norm_to_cut_plane );
 

   status = om$get_channel_objects( objid        =  my_id,
                                    p_chanselect = &me->located_chansel,
                                    list         =  channel_linkage,
                                    size         =  1,
                                    count        = &num_objects_found );

   located_object.objid = channel_linkage[0].S_objid;
   located_object.osnum = channel_linkage[0].osnum;

   status = gr$gsis_graphics_set( msg       = &msg,
                                  object_id = &located_object );
   if( (status & 1) & (msg & 1) )
   {
      gr$gsremove_fence( msg       = &msg,
                         object_id = &located_object );
        
      gr$gsflatten_owners( msg              = &msg,
                           attributes       = &me->attributes,
                           eligible_classes = &me->locate_eligible_thing,
                           owner_properties =  NULL,
                           object_id        = &located_object );

      gr$gsinqcount( msg       = &msg,
                     count     = &size,
                     object_id = &located_object );

      object_list = (struct GRobj_env *) om$malloc( size =
                                        sizeof( struct GRobj_env ) * size );
      if( !object_list )
      {
         msg = MANOMEMORY;
        *sts = MSFAIL;
         goto quit;
      }
        
      gr$gsget_objects( msg       = &msg,
                        array     =  object_list,
                        size      = (sizeof( struct GRobj_env ) * size ),
                        count     = &num_objects_found,
                        object_id = &located_object );
      _m_check2p( status, msg, "COexp.get_stationary failed in grget_obj" );
      _m_check2q( status, msg );
   }
   else
   {
      status = lc$get_channel_objects( objid        =  my_id,
                                       p_chanselect = &me->located_chansel,
                                       list         =  channel_linkage,
                                       size         =  1,
                                       count        = &num_objects_found );
      _m_checkp( status, "COexp.get_stationary fail in get_chan_obj" );
      _m_checkq( status );

      object_list = (struct GRobj_env *) om$malloc( size =
                                        sizeof( struct GRobj_env ) );

      if( !object_list )
      {
         msg = MANOMEMORY;
         goto quit;
      }
        
      object_list[0].obj_id.objid = channel_linkage[0].S_objid;
      object_list[0].obj_id.osnum = channel_linkage[0].osnum;
   }

   for( loop = 0; loop < num_objects_found; loop++ )
   {
      range_process = FALSE;

      om$get_classid( objid     = object_list[loop].obj_id.objid,
                      osnum     = object_list[loop].obj_id.osnum,
                      p_classid = &elem_classid );

      /* check for locally bounded systems */
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "GRlbsys" );

      if( status == OM_S_SUCCESS )     /* locally bounded system */
         range_process = TRUE;

      /* check for graphic groups */
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "GRgrgrp" );

      if( status == OM_S_SUCCESS )     /* graphics group */
         range_process = TRUE;

      /* check for GRparts */
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "GRpart" );

      /***********************************************
       ***         GRlbsys  GRgrgrp  GRpart        ***
       ***********************************************/

      if( status == OM_S_SUCCESS )     /* GRpart */
         range_process = TRUE;
 
      if( range_process ) 
      {
         IGRpoint         min_rng,
                          max_rng,
                          int_pts[6];     /* intersection pl vs. rngbx */
         IGRdouble        range[6];       /* range of pattern element  */
         IGRboolean       world;          /* flag for getrang          */
         extern void      BSrgbxplint();

         world = TRUE;
         status = om$send( msg = message GRgraphics.GRgetrang(
                               &msg,
                               &object_list[loop].mod_env.md_env.matrix_type,
                                object_list[loop].mod_env.md_env.matrix,
                               &world,
                                range ),
                           senderid = my_id,
                           targetos = object_list[loop].obj_id.osnum,
                           targetid = object_list[loop].obj_id.objid );

         min_rng[0] = range[0];
         min_rng[1] = range[1];
         min_rng[2] = range[2];
         max_rng[0] = range[3];
         max_rng[1] = range[4];
         max_rng[2] = range[5];

         BSrgbxplint(&range[0],
                     &range[3],
                     &dir_points[0],
                      norm_to_cut_plane,
                      1.0,
                     &num_pnts,
                      int_pts[0],
                     &msg );

         if( num_pnts == 0 )
         {
             /* In this case the graphic object found does not lie in
                the plane of the explosion vector.  Therefore we set
                a boolean flag to reject this object and continue
                processing to perform a normal clean-up.
              */
             bad_object = TRUE;
         }

         lo_parm = 100.0;
         hi_parm = -1.0;
         for( loop2 = 0; loop2 < num_pnts; loop2++ )
         {
            b_status = MAptpyproj(&msg,
                                   int_pts[loop2],
                                  &expl_axis,
                                   proj_point,
                                  &t_parm,
                                  &segment_num );

            /* store high point */
            if( t_parm > hi_parm )
            {
               hi_parm = t_parm;
               hi_point[0] = proj_point[0];
               hi_point[1] = proj_point[1];
               hi_point[2] = proj_point[2];
            }

            /* store low point */
            if( t_parm < lo_parm )
            {
               lo_parm = t_parm;
               lo_point[0] = proj_point[0];
               lo_point[1] = proj_point[1];
               lo_point[2] = proj_point[2];
            }
         }
      }


      /***********************************************
       ***              EMSsurface                 ***
       ***********************************************/
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "EMSsurface" );

      if(status == OM_S_SUCCESS)       /* solids & surfaces */
      {
         IGRlong                num_bytes,
                                num_bytes_ret;
         IGRint                 num_intersects;
         IGRshort               is_line,
                                local_level;
         IGRpoint               expl_axis_point1,
                                temp_point,
                                tmp_lo_point,
                                tmp_hi_point;
         IGRdouble              temp_parm,
                                tmp_hi_parm,
                                tmp_lo_parm;
         short unsigned         dpb_properties;
         struct IGRdisplay      local_symbology;
         struct IGRbsp_curve   *proj_bsp_curve = 0;
         struct GRid           *resulting_grids = 0;
         struct GRmd_env        local_module;
         struct GRlc_info       lc_info;
         struct GRvg_construct  vg_construct;
         extern IGRboolean      BSfreecv(),
                                BSprj_cv_pl();
         extern void            BSallocv(),
                                BStstcvfln();


         num_bytes = sizeof( local_symbology );
         gr$get_active_display( msg    = &msg,
                                sizbuf = &num_bytes,
                                buffer = &local_symbology,
                                nret   = &num_bytes_ret );

         num_bytes = sizeof( local_level );
         gr$get_active_level( msg    = &msg,
                              sizbuf = &num_bytes,
                              buffer = &local_level,
                              nret   = &num_bytes_ret );

         num_bytes = sizeof( IGRshort );
         gr$get_active_prop( msg    = &msg,
                             sizbuf = &num_bytes,
                             buffer = &dpb_properties,
                             nret   = &num_bytes_ret );

         local_module = me->ModuleInfo;
         local_module.md_id.objid = NULL_OBJID;

         vg_construct.msg        = &msg;
         vg_construct.env_info   = &local_module;
         vg_construct.newflag    =  FALSE;
         vg_construct.level      =  local_level;
         vg_construct.properties =  dpb_properties;
         vg_construct.geometry   =  NULL;
         vg_construct.display    = &local_symbology;
         vg_construct.class_attr =  NULL;
         vg_construct.name       =  NULL; 

         expl_axis_point1[0] = dir_points[0];
         expl_axis_point1[1] = dir_points[1];
         expl_axis_point1[2] = dir_points[2];

         cutting_plane.point  = &dir_points[0];
         cutting_plane.normal =  norm_to_cut_plane;

         lc_info.module_info       = object_list[loop].mod_env;
         lc_info.located_obj.objid = object_list[loop].obj_id.objid;
         lc_info.located_obj.osnum = object_list[loop].obj_id.osnum;

         status = om$send( msg = message GRvg.EMintplane(&vg_construct,
                                                         &cutting_plane,
                                                         &lc_info,
                                                         &num_intersects,
                                                         &resulting_grids,
                                                         (IGRint *)&msg ),
                           senderid = my_id,
                           targetos = object_list[loop].obj_id.osnum,
                           targetid = object_list[loop].obj_id.objid );
         _m_check2p( status, msg, "COexp.get_stationary - failed EMintplane" );

         if( num_intersects == 0 )
         {
             /* In this case the graphic object found does not lie in
                the plane of the explosion vector.  Therefore we set
                a boolean flag to reject this object and continue
                processing to perform a normal clean-up.
              */
             bad_object = TRUE;
         }

         lo_parm = 100.0;
         hi_parm = -1.0;

         for( loop2 = 0; loop2 < num_intersects; loop2++ )
         {
            struct IGRbsp_curve  *bsp_curve = 0;

            /* get geometry of curves returned */
            status = om$send( msg = message GRvg.GRgetsize(
                                           &msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix,
                                           &size ),
                              senderid = my_id,
                              targetos = resulting_grids[loop2].osnum,
                              targetid = resulting_grids[loop2].objid );
            _m_check2p(status,msg,"COexp.get_stationary - failed GRgetsize");

            if( status & msg & 1 )
            {
               bsp_curve = (struct IGRbsp_curve *) om$malloc( size = size );
               if( !bsp_curve )
               {
                  msg = MANOMEMORY;
                  goto quit;
               }

               status = om$send( msg = message GRvg.GRgetgeom(
                                          &msg,
                                          &me->ModuleInfo.md_env.matrix_type,
                                           me->ModuleInfo.md_env.matrix,
                                           (IGRchar *)bsp_curve ),
                                 senderid = my_id,
                                 targetos = resulting_grids[loop2].osnum,
                                 targetid = resulting_grids[loop2].objid );
               _m_check2p(status,msg,"COexp.get_stationary - failed GRgetgeom");

               BSalloccv( bsp_curve->order,
                          bsp_curve->num_poles,
                          bsp_curve->rational,
                          bsp_curve->num_boundaries,
                         &proj_bsp_curve,
                         &msg );

               b_status = BSprj_cv_pl(&msg,
                                       bsp_curve,
                                       expl_axis_point1,
                                       view_vector,
                                       view_vector,
                                       proj_bsp_curve );
          
               BStstcvfln( proj_bsp_curve,
                          &is_line,
                           tmp_hi_point,
                           tmp_lo_point,
                          &msg );

               b_status = MAptpyproj(&msg,
                                      tmp_hi_point,
                                     &expl_axis,
                                      tmp_hi_point,
                                     &tmp_hi_parm,
                                     &segment_num );

               b_status = MAptpyproj(&msg,
                                      tmp_lo_point,
                                     &expl_axis,
                                      tmp_lo_point,
                                     &tmp_lo_parm,
                                     &segment_num );
   
               /* flip parms if needed */
               if( tmp_hi_parm < tmp_lo_parm )
               {
                  temp_parm = tmp_lo_parm;
                  tmp_lo_parm = tmp_hi_parm;
                  tmp_hi_parm = temp_parm;

                  temp_point[0] = tmp_lo_point[0];
                  tmp_lo_point[0] = tmp_hi_point[0];
                  tmp_hi_point[0] = temp_point[0];

                  temp_point[1] = tmp_lo_point[1];
                  tmp_lo_point[1] = tmp_hi_point[1];
                  tmp_hi_point[1] = temp_point[1];

                  temp_point[2] = tmp_lo_point[2];
                  tmp_lo_point[2] = tmp_hi_point[2];
                  tmp_hi_point[2] = temp_point[2];
               }

               /* store high point */
               if( hi_parm < tmp_hi_parm )
               {
                  hi_parm = tmp_hi_parm;
                  hi_point[0] = tmp_hi_point[0];
                  hi_point[1] = tmp_hi_point[1];
                  hi_point[2] = tmp_hi_point[2];
               }

               /* store low point */
               if( lo_parm > tmp_lo_parm )
               {
                  lo_parm = tmp_lo_parm;
                  lo_point[0] = tmp_lo_point[0];
                  lo_point[1] = tmp_lo_point[1];
                  lo_point[2] = tmp_lo_point[2];
               }


               if( bsp_curve )  om$dealloc( ptr = bsp_curve );
               b_status = BSfreecv(&msg,
                                    proj_bsp_curve );
            }
            else
            {
               GRclassid  new_elem_classid;

               om$get_classid( objid     = resulting_grids[loop2].objid,
                               osnum     = resulting_grids[loop2].osnum,
                               p_classid = &new_elem_classid );

               /* check for graphic groups */
               status = om$is_ancestry_valid( subclassid     = new_elem_classid,
                                              superclassname = "GRgrgrp" );

               if( status == OM_S_SUCCESS ) 
               {
                  IGRpoint         min_rng,
                                   max_rng,
                                   int_pts[6];   /* intersect pl vs. rngbx */
                  IGRdouble        range[6];     /* range of pattern elem  */
                  IGRboolean       world;        /* flag for getrang       */
                  extern void      BSrgbxplint();

                  world = TRUE;
                  status = om$send( msg = message GRgraphics.GRgetrang(
                               &msg,
                               &object_list[loop].mod_env.md_env.matrix_type,
                                object_list[loop].mod_env.md_env.matrix,
                               &world,
                                range ),
                                    senderid = my_id,
                                    targetos = object_list[loop].obj_id.osnum,
                                    targetid = object_list[loop].obj_id.objid );

                  min_rng[0] = range[0];
                  min_rng[1] = range[1];
                  min_rng[2] = range[2];
                  max_rng[0] = range[3];
                  max_rng[1] = range[4];
                  max_rng[2] = range[5];

                  BSrgbxplint(&range[0],
                              &range[3],
                              &dir_points[0],
                               norm_to_cut_plane,
                               1.0,
                              &num_pnts,
                               int_pts[0],
                              &msg );

                  lo_parm = 100.0;
                  hi_parm = -1.0;
                  for( loop2 = 0; loop2 < num_pnts; loop2++ )
                  {
                     b_status = MAptpyproj(&msg,
                                            int_pts[loop2],
                                           &expl_axis,
                                            proj_point,
                                           &t_parm,
                                           &segment_num );

                     /* store high point */
                     if( t_parm > hi_parm )
                     {
                        hi_parm = t_parm;
                        hi_point[0] = proj_point[0];
                        hi_point[1] = proj_point[1];
                        hi_point[2] = proj_point[2];
                     }

                     /* store low point */
                     if( t_parm < lo_parm )
                     {
                        lo_parm = t_parm;
                        lo_point[0] = proj_point[0];
                        lo_point[1] = proj_point[1];
                        lo_point[2] = proj_point[2];
                     }
                  }
               }
            }

            status = om$send( msg = message GRgraphics.GRdelete(
                                                     &msg,
                                                     &local_module ),
                              senderid = my_id,
                              targetos = resulting_grids[loop2].osnum,
                              targetid = resulting_grids[loop2].objid );

         }
         if( resulting_grids )    om$dealloc( ptr = resulting_grids );
      }

      /***********************************************
       ***                GRcurve                  ***
       ***********************************************/
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "GRcurve" );

      if( status == OM_S_SUCCESS )        /* wireframe curve */
      { 
         IGRdouble            *int_pnts = 0,
                              *u_parms = 0,
                              *ovl_start_parms = 0,
                              *ovl_end_parms = 0;
         struct IGRbsp_curve  *bsp_curve = 0;


         /* get geometry of wireframe element */
         status = om$send( msg = message GRvg.GRgetsize(
                                           &msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix,
                                           &size ),
                           senderid = my_id,
                           targetos = object_list[loop].obj_id.osnum,
                           targetid = object_list[loop].obj_id.objid );
         _m_check2p( status, msg, "COexp.get_stationary - failed GRgetsize" );

         bsp_curve = (struct IGRbsp_curve *) om$malloc( size = size );
         if( !bsp_curve )
         {
            msg = MANOMEMORY;
            goto quit;
         }

         status = om$send( msg = message GRvg.GRgetgeom(
                                           &msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix,
                                            (IGRchar *)bsp_curve ),
                           senderid = my_id,
                           targetos = object_list[loop].obj_id.osnum,
                           targetid = object_list[loop].obj_id.objid );
         _m_check2p( status, msg, "COexp.get_stationary - failed GRgetgeom" );

         int_pnts = (IGRdouble *) om$malloc( size =
                              sizeof( IGRdouble ) * bsp_curve->num_poles * 3 );
         u_parms = (IGRdouble *) om$malloc( size =
                              sizeof( IGRdouble ) * bsp_curve->num_poles );
         ovl_start_parms = (IGRdouble *) om$malloc( size =
                              sizeof( IGRdouble ) * bsp_curve->num_poles );
         ovl_end_parms = (IGRdouble *) om$malloc( size =
                              sizeof( IGRdouble ) * bsp_curve->num_poles );
         if( !int_pnts || !u_parms || !ovl_start_parms || !ovl_end_parms )
         {
            msg = MANOMEMORY;
            goto quit;
         }

         b_status = BSpl_cv_int(&msg,
                                 bsp_curve,
                                &dir_points[0],
                                 norm_to_cut_plane,
                                &num_pnts,
                                 int_pnts,
                                 u_parms,
                                &num_ovl_pnts,
                                 ovl_start_parms,
                                 ovl_end_parms );

         if( num_pnts == 0 )
         {
             /* In this case the graphic object found does not lie in
                the plane of the explosion vector.  Therefore we set
                a boolean flag to reject this object and continue
                processing to perform a normal clean-up.
              */
             bad_object = TRUE; 
         }


         /**********************************************************
          ***  Project points returned onto explosion vector     ***
          ***  Take highest and lowest u_parms after projection  ***
          ***  Put points in array to keep around                ***
          **********************************************************/
         lo_parm = 100.0;
         hi_parm = -1.0;
         for( loop2 = 0; loop2 < num_pnts; loop2++ )
         {
            /****************************************************
             ***        What about ovl_points                 ***
             ****************************************************/
            b_status = MAptpyproj(&msg,
                                  &int_pnts[loop2 * 3],
                                  &expl_axis,
                                   proj_point,
                                  &t_parm,
                                  &segment_num );

            /* store high point */
            if( t_parm > hi_parm )
            {
               hi_parm = t_parm;
               hi_point[0] = proj_point[0];
               hi_point[1] = proj_point[1];
               hi_point[2] = proj_point[2];
            }

            /* store low point */
            if( t_parm < lo_parm )
            {
               lo_parm = t_parm;
               lo_point[0] = proj_point[0];
               lo_point[1] = proj_point[1];
               lo_point[2] = proj_point[2];
            }
         }

         if( bsp_curve )        om$dealloc( ptr = bsp_curve );
         if( int_pnts )         om$dealloc( ptr = int_pnts );
         if( u_parms )          om$dealloc( ptr = u_parms );
         if( ovl_start_parms )  om$dealloc( ptr = ovl_start_parms );
         if( ovl_end_parms )    om$dealloc( ptr = ovl_end_parms );
      }

      /* store high point */
      if( hi_parm > me->stationary_guy.hi_parm )
      {
          me->stationary_guy.grid = object_list[loop].obj_id;
          me->stationary_guy.hi_parm  = hi_parm;
          me->stationary_guy.hi_point[0] = hi_point[0];
          me->stationary_guy.hi_point[1] = hi_point[1];
          me->stationary_guy.hi_point[2] = hi_point[2];
      }

      /* store low point */
      if( lo_parm < me->stationary_guy.lo_parm )
      {
           me->stationary_guy.lo_parm  = lo_parm;
           me->stationary_guy.lo_point[0] = lo_point[0];
           me->stationary_guy.lo_point[1] = lo_point[1];
           me->stationary_guy.lo_point[2] = lo_point[2];
      }
   }

   if( bad_object )  *sts = MSFAIL;

   if( object_list )  om$dealloc( ptr = object_list );
quit:
  return OM_S_SUCCESS;
}

method explode_view ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint                 loop,
                          loop2,
                          lo_list_counter,
                          hi_list_counter,
                          num_pnts,
                          num_ovl_pnts;
   IGRlong                msg,
                          size,
                          which_err,
                          segment_num,
                          ret_size;
   OMuint                 num_objects_found;
   IGRshort               t_matrix_type;
   IGRpoint               proj_point,
                          projected_pt,
                          point_on_viewplane,
                          lo_point,
                          hi_point,
                          pts[10],
                          delta,
                          delta_placement,
                         *alloc_pts = 0;
   IGRdouble              t_parm,
                          lo_parm = 0.0,
                          hi_parm = 0.0,
                          spacing_dist,
                          dir_points[6],
                          view_pl_pnts[6],
                          poles[6],
                          knots[4],
                          t_matrix[16];
   IGRvector              dir_vector,
                          view_vector,
                          norm_to_cut_plane,
                          xform_vector,
                          expl_view_pl_vec;
   IGRboolean             b_status,
                          range_process,
                          allocation_flag,
                          low_list;
   GRobjid                new_id;
   GRclassid              elem_classid;
   enum GRdpmode          display_mode;
   struct GRid            located_object,
                          window_grid,
                          module_grid;
   struct IGRline         expl_line,
                          view_pl_line;
   struct IGRplane        viewplane,
                          cutting_plane;
   struct IGRpolyline     expl_axis,
                          view_pl_polyline;
   struct IGRbsp_curve    view_pl_bsp_curve;
   struct var_list        var_list[2];
   struct GRobj_env      *object_list = 0;

   struct Explode_list
   {
      struct GRid   grid;
      IGRdouble     lo_parm,
                    hi_parm,
                    lo_point[3],
                    hi_point[3];
   }                    tmp_expl,
                       *lo_expl_list = 0,
                       *hi_expl_list = 0;

   OM_S_OBJECT_LINKAGE  channel_linkage[1];
   extern IGRdouble     fabs();
   extern IGRboolean    MAtrlmx(),
                        MAtypemx(),
                        MAunitvc(),
                        MApytobc(),
                        MAcrossvc(),
                        MAptpyproj(),
                        MAptlnproj(),
                        BSproj1(),
                        BSpl_cv_int();
   extern void          BSeqdptscv();
  


   /* load direction vector points (world coordinates) */
   dir_points[0] = me->first_event.event.button.x;
   dir_points[1] = me->first_event.event.button.y;
   dir_points[2] = me->first_event.event.button.z;

   dir_points[3] = me->second_event.event.button.x;
   dir_points[4] = me->second_event.event.button.y;
   dir_points[5] = me->second_event.event.button.z;

   /* unitize direction vector */
   dir_vector[0] = dir_points[3] - dir_points[0];
   dir_vector[1] = dir_points[4] - dir_points[1];
   dir_vector[2] = dir_points[5] - dir_points[2];

   b_status = MAunitvc(&msg,
                        dir_vector,
                        dir_vector );

   /* explosion axis in IGRpolyline format */
   expl_axis.num_points = 2;
   expl_axis.points = dir_points;

   /* explosion axis in IGRline format */
   expl_line.point1 = &dir_points[0];
   expl_line.point2 = &dir_points[3];
  
   window_grid.osnum = me->first_event.event.button.osnum;
   window_grid.objid = me->first_event.event.button.objid;

   viewplane.point  = point_on_viewplane;
   viewplane.normal = view_vector;
  
   var_list[0].var            =  VIEW_PLANE;
   var_list[0].var_ptr        = (IGRchar *)&viewplane;
   var_list[0].num_bytes      =  sizeof ( struct IGRplane );
   var_list[0].bytes_returned = &ret_size;
  
   var_list[1].var = END_PARAM;
  
   status = dp$inq_set_gragad( msg          = &msg,
                               osnum        =  window_grid.osnum,
                               gragad_objid =  window_grid.objid,
                               which_error  = &which_err,
                               var_list     =  var_list );

   b_status = MAcrossvc(&msg,
                         dir_vector,
                         viewplane.normal,
                         norm_to_cut_plane );

   status = om$get_channel_objects( objid        =  my_id,
                                    p_chanselect = &me->located_chansel,
                                    list         =  channel_linkage,
                                    size         =  1,
                                    count        = &num_objects_found );

   located_object.objid = channel_linkage[0].S_objid;
   located_object.osnum = channel_linkage[0].osnum;

   status = gr$gsis_graphics_set( msg       = &msg,
                                  object_id = &located_object );
   if( (status & 1) & (msg & 1) )
   {
      gr$gsremove_fence( msg       = &msg,
                         object_id = &located_object );
        
      gr$gsflatten_owners( msg              = &msg,
                           attributes       = &me->attributes,
                           eligible_classes = &me->locate_eligible_thing,
                           owner_properties =  NULL,
                           object_id        = &located_object );

      gr$gsinqcount( msg       = &msg,
                     count     = &size,
                     object_id = &located_object );

      object_list = (struct GRobj_env *) om$malloc( size =
                                        sizeof( struct GRobj_env ) * size );
      if( !object_list )
      {
         msg = MANOMEMORY;
         goto quit;
      }
        
      gr$gsget_objects( msg       = &msg,
                        array     =  object_list,
                        size      = (sizeof( struct GRobj_env ) * size ),
                        count     = &num_objects_found,
                        object_id = &located_object );
      _m_check2p( status, msg, "COexp.explode_view failed in grget_obj" );
      _m_check2q( status, msg );
   }
   else
   {
      status = lc$get_channel_objects( objid        =  my_id,
                                       p_chanselect = &me->located_chansel,
                                       list         =  channel_linkage,
                                       size         =  1,
                                       count        = &num_objects_found );
      _m_checkp( status, "COexp.explode_view fail in get_chan_obj" );
      _m_checkq( status );

      object_list = (struct GRobj_env *) om$malloc( size =
                                        sizeof( struct GRobj_env ) );

      if( !object_list )
      {
         msg = MANOMEMORY;
         goto quit;
      }

      object_list[0].obj_id.objid = channel_linkage[0].S_objid;
      object_list[0].obj_id.osnum = channel_linkage[0].osnum;
   }

   lo_list_counter = 0;
   hi_list_counter = 0;
   lo_expl_list = (struct Explode_list *) 
           om$malloc( size = sizeof(struct Explode_list) * num_objects_found );
   hi_expl_list = (struct Explode_list *) 
           om$malloc( size = sizeof(struct Explode_list) * num_objects_found );

   for( loop = 0; loop < num_objects_found; loop++ )
   {
      range_process = FALSE;

      om$get_classid( objid     = object_list[loop].obj_id.objid,
                      osnum     = object_list[loop].obj_id.osnum,
                      p_classid = &elem_classid );

      /* check for locally bounded systems */
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "GRlbsys" );

      if( status == OM_S_SUCCESS )     /* locally bounded system */
         range_process = TRUE;

      /* check for graphic groups */
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "GRgrgrp" );

      if( status == OM_S_SUCCESS )     /* graphic group */
         range_process = TRUE;

      /* check for GRparts */
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "GRpart" );

      /***********************************************
       ***         GRlbsys  GRgrgrp  GRpart        ***
       ***********************************************/
      if( status == OM_S_SUCCESS )     /* GRpart */
         range_process = TRUE;
 
      if( range_process )
      {
         IGRpoint         min_rng,
                          max_rng,
                          int_pts[6];     /* intersection pl vs. rngbx */
         IGRdouble        range[6];       /* range of pattern element  */
         IGRboolean       world;          /* flag for getrang          */
         extern void      BSrgbxplint();

         world = TRUE;
         status = om$send( msg = message GRgraphics.GRgetrang(
                               &msg,
                               &object_list[loop].mod_env.md_env.matrix_type,
                                object_list[loop].mod_env.md_env.matrix,
                               &world,
                                range ),
                           senderid = my_id,
                           targetos = object_list[loop].obj_id.osnum,
                           targetid = object_list[loop].obj_id.objid );

         min_rng[0] = range[0];
         min_rng[1] = range[1];
         min_rng[2] = range[2];
         max_rng[0] = range[3];
         max_rng[1] = range[4];
         max_rng[2] = range[5];

         BSrgbxplint(&range[0],
                     &range[3],
                     &dir_points[0],
                      norm_to_cut_plane,
                      1.0,
                     &num_pnts,
                      int_pts[0],
                     &msg );

         lo_parm = 100.0;
         hi_parm = -1.0;

         if( num_pnts == 0 )
         {
             /* In this case the graphic object found does not lie in
                the plane of the explosion vector.  Therefore we set
                the parms to be high to avoid unnessessary sorting and
                set the object's grid to be that of the stationary
                object.  This is so later processing will not transform
                this ineligible object.
              */
             lo_parm = 1.1;
             hi_parm = 1.2;
             object_list[loop].obj_id.osnum = me->stationary_guy.grid.osnum;
             object_list[loop].obj_id.objid = me->stationary_guy.grid.objid;
         }

         for( loop2 = 0; loop2 < num_pnts; loop2++ )
         {
            b_status = MAptpyproj(&msg,
                                   int_pts[loop2],
                                  &expl_axis,
                                   proj_point,
                                  &t_parm,
                                  &segment_num );

            /* store high point */
            if( t_parm > hi_parm )
            {
               hi_parm = t_parm;
               hi_point[0] = proj_point[0];
               hi_point[1] = proj_point[1];
               hi_point[2] = proj_point[2];
            }

            /* store low point */
            if( t_parm < lo_parm )
            {
               lo_parm = t_parm;
               lo_point[0] = proj_point[0];
               lo_point[1] = proj_point[1];
               lo_point[2] = proj_point[2];
            }
         }
      }

      /***********************************************
       ***              EMSsurface                 ***
       ***********************************************/
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "EMSsurface" );

      if(status == OM_S_SUCCESS)       /* solids & surfaces */
      {
         IGRlong                num_bytes,
                                num_bytes_ret;
         IGRint                 num_intersects;
         IGRshort               is_line,
                                local_level;
         IGRpoint               expl_axis_point1,
                                temp_point,
                                tmp_lo_point,
                                tmp_hi_point;
         IGRdouble              temp_parm,
                                tmp_hi_parm,
                                tmp_lo_parm;
         short unsigned         dpb_properties;
         struct IGRdisplay      local_symbology;
         struct IGRbsp_curve   *proj_bsp_curve = 0;
         struct GRid           *resulting_grids = 0;
         struct GRmd_env        local_module;
         struct GRlc_info       lc_info;
         struct GRvg_construct  vg_construct;
         extern IGRboolean      BSfreecv(),
                                BSprj_cv_pl();
         extern void            BSallocv(),
                                BStstcvfln();

         num_bytes = sizeof( local_symbology );
         gr$get_active_display( msg    = &msg,
                                sizbuf = &num_bytes,
                                buffer = &local_symbology,
                                nret   = &num_bytes_ret );

         num_bytes = sizeof( local_level );
         gr$get_active_level( msg    = &msg,
                              sizbuf = &num_bytes,
                              buffer = &local_level,
                              nret   = &num_bytes_ret );

         num_bytes = sizeof( IGRshort );
         gr$get_active_prop( msg    = &msg,
                             sizbuf = &num_bytes,
                             buffer = &dpb_properties,
                             nret   = &num_bytes_ret );

         local_module = me->ModuleInfo;
         local_module.md_id.objid = NULL_OBJID;

         vg_construct.msg        = &msg;
         vg_construct.env_info   = &local_module;
         vg_construct.newflag    =  FALSE;
         vg_construct.level      =  local_level;
         vg_construct.properties =  dpb_properties;
         vg_construct.geometry   =  NULL;
         vg_construct.display    = &local_symbology;
         vg_construct.class_attr =  NULL;
         vg_construct.name       =  NULL; 

         expl_axis_point1[0] = dir_points[0];
         expl_axis_point1[1] = dir_points[1];
         expl_axis_point1[2] = dir_points[2];

         cutting_plane.point  = &dir_points[0];
         cutting_plane.normal =  norm_to_cut_plane;

         lc_info.module_info       = object_list[loop].mod_env;
         lc_info.located_obj.objid = object_list[loop].obj_id.objid;
         lc_info.located_obj.osnum = object_list[loop].obj_id.osnum;

         status = om$send( msg = message GRvg.EMintplane(&vg_construct,
                                                         &cutting_plane,
                                                         &lc_info,
                                                         &num_intersects,
                                                         &resulting_grids,
                                                         (IGRint *)&msg ),
                           senderid = my_id,
                           targetos = object_list[loop].obj_id.osnum,
                           targetid = object_list[loop].obj_id.objid );
         _m_check2p( status, msg, "COexp.explode_view - failed EMintplane" );

         lo_parm = 100.0;
         hi_parm = -1.0;

         if( num_intersects == 0 )
         {
             /* In this case the graphic object found does not lie in
                the plane of the explosion vector.  Therefore we set
                the parms to be high to avoid unnessessary sorting and
                set the object's grid to be that of the stationary
                object.  This is so later processing will not transform
                this ineligible object.
              */
             lo_parm = 1.3;
             hi_parm = 1.4;
             object_list[loop].obj_id.osnum = me->stationary_guy.grid.osnum;
             object_list[loop].obj_id.objid = me->stationary_guy.grid.objid;
         }

         for( loop2 = 0; loop2 < num_intersects; loop2++ )
         {
            struct IGRbsp_curve  *bsp_curve = 0;

            /* get geometry of curves returned */
            status = om$send( msg = message GRvg.GRgetsize(
                                           &msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix,
                                           &size ),
                              senderid = my_id,
                              targetos = resulting_grids[loop2].osnum,
                              targetid = resulting_grids[loop2].objid );
            _m_check2p( status, msg, "COexp.explode_view - failed GRgetsize" );

            if( status & msg & 1 )
            {
               bsp_curve = (struct IGRbsp_curve *) om$malloc( size = size );
               if( !bsp_curve )
               {
                  msg = MANOMEMORY;
                  goto quit;
               }

               status = om$send( msg = message GRvg.GRgetgeom(
                                           &msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix,
                                            (IGRchar *)bsp_curve ),
                                 senderid = my_id,
                                 targetos = resulting_grids[loop2].osnum,
                                 targetid = resulting_grids[loop2].objid );
               _m_check2p(status,msg,"COexp.explode_view - failed GRgetgeom");

               BSalloccv( bsp_curve->order,
                          bsp_curve->num_poles,
                          bsp_curve->rational,
                          bsp_curve->num_boundaries,
                         &proj_bsp_curve,
                         &msg );

               b_status = BSprj_cv_pl(&msg,
                                       bsp_curve,
                                       expl_axis_point1,
                                       view_vector,
                                       view_vector,
                                       proj_bsp_curve );
          
               BStstcvfln( proj_bsp_curve,
                          &is_line,
                           tmp_hi_point,
                           tmp_lo_point,
                          &msg );

               b_status = MAptpyproj(&msg,
                                      tmp_hi_point,
                                     &expl_axis,
                                      tmp_hi_point,
                                     &tmp_hi_parm,
                                     &segment_num );

               b_status = MAptpyproj(&msg,
                                      tmp_lo_point,
                                     &expl_axis,
                                      tmp_lo_point,
                                     &tmp_lo_parm,
                                     &segment_num );

               /* flip parms if needed */
               if( tmp_hi_parm < tmp_lo_parm )
               {
                  temp_parm = tmp_lo_parm;
                  tmp_lo_parm = tmp_hi_parm;
                  tmp_hi_parm = temp_parm;

                  temp_point[0] = tmp_lo_point[0];
                  tmp_lo_point[0] = tmp_hi_point[0];
                  tmp_hi_point[0] = temp_point[0];
   
                  temp_point[1] = tmp_lo_point[1];
                  tmp_lo_point[1] = tmp_hi_point[1];
                  tmp_hi_point[1] = temp_point[1];
   
                  temp_point[2] = tmp_lo_point[2];
                  tmp_lo_point[2] = tmp_hi_point[2];
                  tmp_hi_point[2] = temp_point[2];
               }

               /* store high point */
               if( hi_parm < tmp_hi_parm )
               {
                  hi_parm = tmp_hi_parm;
                  hi_point[0] = tmp_hi_point[0];
                  hi_point[1] = tmp_hi_point[1];
                  hi_point[2] = tmp_hi_point[2];
               }

               /* store low point */
               if( lo_parm > tmp_lo_parm )
               {
                  lo_parm = tmp_lo_parm;
                  lo_point[0] = tmp_lo_point[0];
                  lo_point[1] = tmp_lo_point[1];
                  lo_point[2] = tmp_lo_point[2];
               }


               if( bsp_curve )  om$dealloc( ptr = bsp_curve );
               b_status = BSfreecv(&msg,
                                    proj_bsp_curve );
            }
            else
            {
               GRclassid  new_elem_classid;

               om$get_classid( objid     = resulting_grids[loop2].objid,
                               osnum     = resulting_grids[loop2].osnum,
                               p_classid = &new_elem_classid );

               /* check for graphic groups */
               status = om$is_ancestry_valid( subclassid     = new_elem_classid,
                                              superclassname = "GRgrgrp" );

               if( status == OM_S_SUCCESS ) 
               {
                  IGRpoint         min_rng,
                                   max_rng,
                                   int_pts[6];   /* intersect pl vs. rngbx */
                  IGRdouble        range[6];     /* range of pattern elem  */
                  IGRboolean       world;        /* flag for getrang       */
                  extern void      BSrgbxplint();

                  world = TRUE;
                  status = om$send( msg = message GRgraphics.GRgetrang(
                               &msg,
                               &object_list[loop].mod_env.md_env.matrix_type,
                                object_list[loop].mod_env.md_env.matrix,
                               &world,
                                range ),
                                    senderid = my_id,
                                    targetos = object_list[loop].obj_id.osnum,
                                    targetid = object_list[loop].obj_id.objid );

                  min_rng[0] = range[0];
                  min_rng[1] = range[1];
                  min_rng[2] = range[2];
                  max_rng[0] = range[3];
                  max_rng[1] = range[4];
                  max_rng[2] = range[5];

                  BSrgbxplint(&range[0],
                              &range[3],
                              &dir_points[0],
                               norm_to_cut_plane,
                               1.0,
                              &num_pnts,
                               int_pts[0],
                              &msg );

                  lo_parm = 100.0;
                  hi_parm = -1.0;

                  for( loop2 = 0; loop2 < num_pnts; loop2++ )
                  {
                     b_status = MAptpyproj(&msg,
                                            int_pts[loop2],
                                           &expl_axis,
                                            proj_point,
                                           &t_parm,
                                           &segment_num );

                     /* store high point */
                     if( t_parm > hi_parm )
                     {
                        hi_parm = t_parm;
                        hi_point[0] = proj_point[0];
                        hi_point[1] = proj_point[1];
                        hi_point[2] = proj_point[2];
                     }

                     /* store low point */
                     if( t_parm < lo_parm )
                     {
                        lo_parm = t_parm;
                        lo_point[0] = proj_point[0];
                        lo_point[1] = proj_point[1];
                        lo_point[2] = proj_point[2];
                     }
                  }
               }
            }

            status = om$send( msg = message GRgraphics.GRdelete(
                                                     &msg,
                                                     &local_module ),
                              senderid = my_id,
                              targetos = resulting_grids[loop2].osnum,
                              targetid = resulting_grids[loop2].objid );
         }
         if( resulting_grids )    om$dealloc( ptr = resulting_grids );
      }

      /***********************************************
       ***                GRcurve                  ***
       ***********************************************/
      status = om$is_ancestry_valid( subclassid     = elem_classid,
                                     superclassname = "GRcurve" );

      if( status == OM_S_SUCCESS )        /* wireframe curve */
      { 
         IGRdouble            *int_pnts = 0,
                              *u_parms = 0,
                              *ovl_start_parms = 0,
                              *ovl_end_parms = 0;
         struct IGRbsp_curve  *bsp_curve = 0;


         /* get geometry of wireframe element */
         status = om$send( msg = message GRvg.GRgetsize(
                                           &msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix,
                                           &size ),
                           senderid = my_id,
                           targetos = object_list[loop].obj_id.osnum,
                           targetid = object_list[loop].obj_id.objid );
         _m_check2p( status, msg, "COexp.explode_view - failed GRgetsize" );

         bsp_curve = (struct IGRbsp_curve *) om$malloc( size = size );
         if( !bsp_curve )
         {
            msg = MANOMEMORY;
            goto quit;
         }

         status = om$send( msg = message GRvg.GRgetgeom(
                                           &msg,
                                           &me->ModuleInfo.md_env.matrix_type,
                                            me->ModuleInfo.md_env.matrix,
                                            (IGRchar *)bsp_curve ),
                           senderid = my_id,
                           targetos = object_list[loop].obj_id.osnum,
                           targetid = object_list[loop].obj_id.objid );
         _m_check2p( status, msg, "COexp.explode_view - failed GRgetgeom" );

         int_pnts = (IGRdouble *) om$malloc( size =
                              sizeof( IGRdouble ) * bsp_curve->num_poles * 3 );
         u_parms = (IGRdouble *) om$malloc( size =
                              sizeof( IGRdouble ) * bsp_curve->num_poles );
         ovl_start_parms = (IGRdouble *) om$malloc( size =
                              sizeof( IGRdouble ) * bsp_curve->num_poles );
         ovl_end_parms = (IGRdouble *) om$malloc( size =
                              sizeof( IGRdouble ) * bsp_curve->num_poles );
         if( !int_pnts || !u_parms || !ovl_start_parms || !ovl_end_parms )
         {
            msg = MANOMEMORY;
            goto quit;
         }

         b_status = BSpl_cv_int(&msg,
                                 bsp_curve,
                                &dir_points[0],
                                 norm_to_cut_plane,
                                &num_pnts,
                                 int_pnts,
                                 u_parms,
                                &num_ovl_pnts,
                                 ovl_start_parms,
                                 ovl_end_parms );

         lo_parm = 100.0;
         hi_parm = -1.0;

         if( num_pnts == 0 )
         {
             /* In this case the graphic object found does not lie in
                the plane of the explosion vector.  Therefore we set
                the parms to be high to avoid unnessessary sorting and
                set the object's grid to be that of the stationary
                object.  This is so later processing will not transform
                this ineligible object.
              */
             lo_parm = 1.5;
             hi_parm = 1.6;
             object_list[loop].obj_id.osnum = me->stationary_guy.grid.osnum;
             object_list[loop].obj_id.objid = me->stationary_guy.grid.objid;
         }

         /**********************************************************
          ***  Project points returned onto explosion vector     ***
          ***  Take highest and lowest u_parms after projection  ***
          ***  Put points in array to keep around                ***
          **********************************************************/
         for( loop2 = 0; loop2 < num_pnts; loop2++ )
         {
            b_status = MAptpyproj(&msg,
                                  &int_pnts[loop2 * 3],
                                  &expl_axis,
                                   proj_point,
                                  &t_parm,
                                  &segment_num );

            /* store high point */
            if( t_parm > hi_parm )
            {
               hi_parm = t_parm;
               hi_point[0] = proj_point[0];
               hi_point[1] = proj_point[1];
               hi_point[2] = proj_point[2];
            }

            /* store low point */
            if( t_parm < lo_parm )
            {
               lo_parm = t_parm;
               lo_point[0] = proj_point[0];
               lo_point[1] = proj_point[1];
               lo_point[2] = proj_point[2];
            }
         }

         if( bsp_curve )        om$dealloc( ptr = bsp_curve );
         if( int_pnts )         om$dealloc( ptr = int_pnts );
         if( u_parms )          om$dealloc( ptr = u_parms );
         if( ovl_start_parms )  om$dealloc( ptr = ovl_start_parms );
         if( ovl_end_parms )    om$dealloc( ptr = ovl_end_parms );
      }

      if( hi_parm < me->stationary_guy.lo_parm )  
          low_list = TRUE;
      else if( lo_parm > me->stationary_guy.hi_parm )  
          low_list = FALSE;
      else if( hi_parm < me->stationary_guy.hi_parm &&
               lo_parm < me->stationary_guy.lo_parm )  
          low_list = TRUE;
      else if( hi_parm > me->stationary_guy.hi_parm &&
               lo_parm > me->stationary_guy.lo_parm )  
          low_list = FALSE;
      else if(( hi_parm < me->stationary_guy.hi_parm &&
                lo_parm > me->stationary_guy.lo_parm ) ||
              ( hi_parm > me->stationary_guy.hi_parm &&
                lo_parm < me->stationary_guy.lo_parm ))
      {
         if( fabs( hi_parm - me->stationary_guy.hi_parm ) >
             fabs( me->stationary_guy.lo_parm - lo_parm ))
               low_list = TRUE;
         else  low_list = FALSE;
      }
      else if(( hi_parm == me->stationary_guy.lo_parm ) &&
              ( lo_parm < me->stationary_guy.lo_parm ))
         low_list = TRUE;
      else if(( lo_parm == me->stationary_guy.hi_parm ) &&
              ( hi_parm > me->stationary_guy.hi_parm ))
         low_list = FALSE;
      else
         low_list = FALSE;
       
    if ( num_pnts )
    { 
      if( low_list )
      {
         lo_expl_list[lo_list_counter].grid        = object_list[loop].obj_id;
         lo_expl_list[lo_list_counter].lo_parm     = lo_parm;
         lo_expl_list[lo_list_counter].hi_parm     = hi_parm;
         lo_expl_list[lo_list_counter].lo_point[0] = lo_point[0];
         lo_expl_list[lo_list_counter].lo_point[1] = lo_point[1];
         lo_expl_list[lo_list_counter].lo_point[2] = lo_point[2];
         lo_expl_list[lo_list_counter].hi_point[0] = hi_point[0];
         lo_expl_list[lo_list_counter].hi_point[1] = hi_point[1];
         lo_expl_list[lo_list_counter].hi_point[2] = hi_point[2];
         lo_list_counter++;
      }
      else
      {
         hi_expl_list[hi_list_counter].grid        = object_list[loop].obj_id;
         hi_expl_list[hi_list_counter].lo_parm     = lo_parm;
         hi_expl_list[hi_list_counter].hi_parm     = hi_parm;
         hi_expl_list[hi_list_counter].lo_point[0] = lo_point[0];
         hi_expl_list[hi_list_counter].lo_point[1] = lo_point[1];
         hi_expl_list[hi_list_counter].lo_point[2] = lo_point[2];
         hi_expl_list[hi_list_counter].hi_point[0] = hi_point[0];
         hi_expl_list[hi_list_counter].hi_point[1] = hi_point[1];
         hi_expl_list[hi_list_counter].hi_point[2] = hi_point[2];
         hi_list_counter++;
      }
    } 
   }

   if( object_list )   om$dealloc( ptr = object_list );

   /*****************************************************************
    ***  order point from smallest to largest until I get to the  ***
    ***  stationary small point,  Then order from largest to      ***
    ***  smallest until I get to the stationary largest point.    ***
    *****************************************************************/

   /* hi_expl_list ordering */
   if( hi_list_counter > 1 )
   {
     IGRboolean flip;

     flip = FALSE;
     for( loop = 0; loop < (hi_list_counter - 1); ++loop )
     {
       for( loop2 = (hi_list_counter - 1); loop < loop2; --loop2 )
       {
         if( hi_expl_list[loop2 - 1].hi_parm > hi_expl_list[loop2].hi_parm )
             flip = TRUE;

         if(( hi_expl_list[loop2 - 1].lo_parm == hi_expl_list[loop2].lo_parm )
            && ( hi_expl_list[loop2 - 1].hi_parm > 
                 hi_expl_list[loop2].hi_parm ))
                   flip = TRUE;

         if( flip )
         {
            tmp_expl = hi_expl_list[loop2 - 1];
            hi_expl_list[loop2 - 1] = hi_expl_list[loop2];
            hi_expl_list[loop2] = tmp_expl;
            flip = FALSE;
         }
       }
     }
   }

   /* lo_expl_list ordering */
   if( lo_list_counter > 1 )
   {
     IGRboolean flip;

     flip = FALSE;
     for( loop = 0; loop < (lo_list_counter - 1); ++loop )
     {
       for( loop2 = (lo_list_counter - 1); loop < loop2; --loop2 )
       {
         if( lo_expl_list[loop2 - 1].lo_parm > lo_expl_list[loop2].lo_parm )
             flip = TRUE;

         if(( lo_expl_list[loop2 - 1].hi_parm == lo_expl_list[loop2].hi_parm )
           && ( lo_expl_list[loop2 - 1].lo_parm > 
                lo_expl_list[loop2].lo_parm ))
                   flip = TRUE;

         if( flip )
         {
            tmp_expl = lo_expl_list[loop2 - 1];
            lo_expl_list[loop2 - 1] = lo_expl_list[loop2];
            lo_expl_list[loop2] = tmp_expl;
            flip = FALSE;
         }
       }
     }
   }


   /* project explode axis on to the view plane */
   b_status = BSproj1(&msg, 
                      &dir_points[0],
                       viewplane.normal,
                       viewplane.point,
                      &view_pl_pnts[0] );

   b_status = BSproj1(&msg,
                      &dir_points[3],
                       viewplane.normal,
                       viewplane.point,
                      &view_pl_pnts[3] );

   /* unitize explosion vector in the view plane */
   expl_view_pl_vec[0] = view_pl_pnts[3] - view_pl_pnts[0];
   expl_view_pl_vec[1] = view_pl_pnts[4] - view_pl_pnts[1];
   expl_view_pl_vec[2] = view_pl_pnts[5] - view_pl_pnts[2];

   b_status = MAunitvc(&msg,
                        expl_view_pl_vec,
                        expl_view_pl_vec );

   view_pl_polyline.num_points = 2;
   view_pl_polyline.points = view_pl_pnts;

   view_pl_bsp_curve.poles = poles;  /* array of 6 doubles */
   view_pl_bsp_curve.knots = knots;  /* array of 4 doubles */


   b_status = MApytobc(&msg,
                       &view_pl_polyline,
                       &view_pl_bsp_curve );

   /* convert distance to working units */
   status = co$cvt_imp_to_wrk( msg       = &msg,
                               unit_type =  GRIO_DISTANCE,
                               osnum     =  me->stationary_guy.grid.osnum,
                               primary   =  me->third_event.event.value,
                               result    = &spacing_dist );
   _m_check2p(status,msg,"COexp - explode_view.cvt_imp_to_wrk failed");

   BSeqdptscv(&view_pl_bsp_curve,
               0.0,                      /* start parm of line    */
               0.5,                      /* midpoint parm of line */
               1.0,                      /* end parm of line      */
               spacing_dist,
               10,
               pts,
              &allocation_flag,
              &num_pnts,
              &alloc_pts,
              &msg );

   view_pl_line.point1 = &view_pl_pnts[0];
   view_pl_line.point2 = &view_pl_pnts[3];

   if(allocation_flag) 
   {
      pts[1][0] = alloc_pts[1][0];
      pts[1][1] = alloc_pts[1][1];
      pts[1][2] = alloc_pts[1][2];
      if( alloc_pts )   om$dealloc( ptr = alloc_pts );
   }

   b_status = MAptlnproj(&msg,
                          pts[1],
                         &view_pl_line,
                          projected_pt,
                         &t_parm );
                         
   b_status = MAptattparm(&msg,
                          &t_parm,
                          &expl_line,
                           projected_pt );

   xform_vector[0] = projected_pt[0] - dir_points[0];
   xform_vector[1] = projected_pt[1] - dir_points[1];
   xform_vector[2] = projected_pt[2] - dir_points[2];

   status = ex$get_cur_mod( id    = &module_grid.objid,
                            osnum = &module_grid.osnum );

  
   /* erase the part */
   display_mode = GRbehe;
   for( loop = 0; loop < hi_list_counter; loop++ )
   {
      status = om$send( msg = message GRgraphics.GRdisplay(
                                         &msg,
                                         &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                         &display_mode,
                                         &module_grid ),
                        senderid = my_id,
                        targetos = hi_expl_list[loop].grid.osnum,
                        targetid = hi_expl_list[loop].grid.objid ); 
   }

   for( loop = 0; loop < lo_list_counter; loop++ )
   {
      status = om$send( msg = message GRgraphics.GRdisplay(
                                         &msg,
                                         &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                         &display_mode,
                                         &module_grid ),
                        senderid = my_id,
                        targetos = lo_expl_list[loop].grid.osnum,
                        targetid = lo_expl_list[loop].grid.objid ); 
   }

   delta_placement[0] = me->stationary_guy.hi_point[0] + xform_vector[0];
   delta_placement[1] = me->stationary_guy.hi_point[1] + xform_vector[1];
   delta_placement[2] = me->stationary_guy.hi_point[2] + xform_vector[2];

   for( loop = 0; loop < hi_list_counter; loop++ )
   {
      if( !(( hi_expl_list[loop].grid.osnum == 
              me->stationary_guy.grid.osnum ) &&
            ( hi_expl_list[loop].grid.objid ==
              me->stationary_guy.grid.objid )))
      {
         /* get the vector between the to and from points on vector */
         delta[0] = delta_placement[0] - hi_expl_list[loop].lo_point[0];
         delta[1] = delta_placement[1] - hi_expl_list[loop].lo_point[1];
         delta[2] = delta_placement[2] - hi_expl_list[loop].lo_point[2];

         /* get a transformation matrix */
         b_status = MAtrlmx(&msg,
                             delta,
                             t_matrix );

         /* get matrix type */
         b_status = MAtypemx(&msg,
                              t_matrix,
                             &t_matrix_type );

         /* transform part */
         status = om$send( msg = message GRgraphics.GRxform(&msg,
                                                            &me->ModuleInfo,
                                                            &t_matrix_type,
                                                             t_matrix,
                                                            &new_id ),
                           senderid = my_id,
                           targetos = hi_expl_list[loop].grid.osnum,
                           targetid = hi_expl_list[loop].grid.objid );

         delta_placement[0] = delta_placement[0] + xform_vector[0] +
             (hi_expl_list[loop].hi_point[0] - hi_expl_list[loop].lo_point[0]);
         delta_placement[1] = delta_placement[1] + xform_vector[1] +
             (hi_expl_list[loop].hi_point[1] - hi_expl_list[loop].lo_point[1]);
         delta_placement[2] = delta_placement[2] + xform_vector[2] +
             (hi_expl_list[loop].hi_point[2] - hi_expl_list[loop].lo_point[2]);
      }
   }

   delta_placement[0] = me->stationary_guy.lo_point[0] - xform_vector[0];
   delta_placement[1] = me->stationary_guy.lo_point[1] - xform_vector[1];
   delta_placement[2] = me->stationary_guy.lo_point[2] - xform_vector[2];

   for( loop = (lo_list_counter - 1); loop >= 0; loop-- )
   {
      if( !(( lo_expl_list[loop].grid.osnum ==
              me->stationary_guy.grid.osnum ) &&
            ( lo_expl_list[loop].grid.objid ==
              me->stationary_guy.grid.objid )))
 
      {
         /* get the vector between the to and from points on vector */
         delta[0] = delta_placement[0] - lo_expl_list[loop].hi_point[0];
         delta[1] = delta_placement[1] - lo_expl_list[loop].hi_point[1];
         delta[2] = delta_placement[2] - lo_expl_list[loop].hi_point[2];

         /* get a transformation matrix */
         b_status = MAtrlmx(&msg,
                             delta,
                             t_matrix );

         /* get matrix type */
         b_status = MAtypemx(&msg,
                              t_matrix,
                             &t_matrix_type );

         /* transform part */
         status = om$send( msg = message GRgraphics.GRxform(&msg,
                                                            &me->ModuleInfo,
                                                            &t_matrix_type,
                                                             t_matrix,
                                                            &new_id ),
                           senderid = my_id,
                           targetos = lo_expl_list[loop].grid.osnum,
                           targetid = lo_expl_list[loop].grid.objid ); 

         delta_placement[0] = delta_placement[0] - xform_vector[0] -
             (lo_expl_list[loop].hi_point[0] - lo_expl_list[loop].lo_point[0]);
         delta_placement[1] = delta_placement[1] - xform_vector[1] -
             (lo_expl_list[loop].hi_point[1] - lo_expl_list[loop].lo_point[1]);
         delta_placement[2] = delta_placement[2] - xform_vector[2] -
             (lo_expl_list[loop].hi_point[2] - lo_expl_list[loop].lo_point[2]);
      }
   }
  
   /* display the transformed part */
   display_mode = GRbd;
   for( loop = 0; loop < hi_list_counter; loop++ )
   {
      status = om$send( msg = message GRgraphics.GRdisplay(
                                         &msg,
                                         &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                         &display_mode,
                                         &module_grid ),
                        senderid = my_id,
                        targetos = hi_expl_list[loop].grid.osnum,
                        targetid = hi_expl_list[loop].grid.objid ); 
   }

   for( loop = 0; loop < lo_list_counter; loop++ )
   {
      status = om$send( msg = message GRgraphics.GRdisplay(
                                         &msg,
                                         &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                         &display_mode,
                                         &module_grid ),
                        senderid = my_id,
                        targetos = lo_expl_list[loop].grid.osnum,
                        targetid = lo_expl_list[loop].grid.objid ); 
   }

   if( lo_expl_list )  om$dealloc( ptr = lo_expl_list );
   if( hi_expl_list )  om$dealloc( ptr = hi_expl_list );
quit:
  return OM_S_SUCCESS;
}

end implementation COexp;
