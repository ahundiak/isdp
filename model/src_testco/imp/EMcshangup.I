class implementation ECprfsksf;

#include "ems_m_inc.h"
#include "EMSmsgdef.h"		        /* EMS_I_NotFound */

#ifndef ECmsg_include
#define ECmsg_include
#include "ECmsg.h"
#endif

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#include "EMSdpb.h"
#include "emsdef.h"
#include "EMSifmacros.h"
#include "grmacros.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "grwireframe.h"
#include "dpdef.h"
#include "bsmdstptcv.h"
#include "bsvalues.h"
#include "bserr.h"
#include "bsattxsect.h"

from GRcompcurve import EMpratpt;
from GRvg import GRconstruct;
from GRgraphics import GRlnproject;
from EMSdatpln import EMget_pln_info;
from GRlinear import GRgetpolyline;

#define BIG_SURFACE 5
#define RANGE_DIV 0.4

extern OMuword OPP_EMSdatpln_class_id;
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_GRcurve_class_id;
extern OMuword OPP_GRpoint_class_id;
extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_SKcompcurve_class_id;

/*
Name
 display_on_site

Abstract
 Displays the transformed cross-section at the trace curve

Synopsis

Description
 Generates a bsp_curve object from IGRbsp_curve data of bsattxsect (this will be allow to estimate position by view dynamics)
 and displays it.

History
 03/10/94	R.Burkhart
    Creation date.

*/
method display_on_site ()
{
 IGRint		bs_case, error_var, i;
 IGRlong        BytesReceived, NumberOfBytes, sts, msg, status;
 IGRdouble	loc_csys[12], vwvolume[6];
 struct         IGRdisplay display_attr, arrow_display;
 IGRshort       active_layer;
 struct         GRvg_construct list;
 struct         IGRbsp_curve curv3;
 struct		var_list inq_array[2];
 IGRpoint       point;
 IGRvector      vector;
 GRrange	range;

 status = OM_S_SUCCESS;

 /* copy curve data from cross-section to attached curve */

 curv3.order		= (me->wrk.css_geom)->order;
 curv3.periodic		= (me->wrk.css_geom)->periodic;
 curv3.non_uniform	= (me->wrk.css_geom)->non_uniform;
 curv3.num_poles	= (me->wrk.css_geom)->num_poles;
 curv3.poles 		= (IGRdouble *) om$malloc (size = (sizeof (IGRpoint) * curv3.num_poles)); 
 if(!curv3.poles){status = OM_E_ABORT; goto wrapup;}

 curv3.num_knots	= (me->wrk.css_geom)->num_knots;
 curv3.knots 		= (me->wrk.css_geom)->knots; 

 curv3.rational		= (me->wrk.css_geom)->rational;
 if (curv3.rational == TRUE)
 {
    curv3.weights	= (me->wrk.css_geom)->weights; 
 }
 else
 {
    curv3.weights	= NULL;
 }
 curv3.planar		= (me->wrk.css_geom)->planar;
 curv3.phy_closed	= (me->wrk.css_geom)->phy_closed;
 curv3.num_boundaries	= (me->wrk.css_geom)->num_boundaries;
 curv3.bdrys		= (me->wrk.css_geom)->bdrys;

 /* coordsys_case 3 is not implemented yet */
 bs_case = me->coordsys_case;
 if (me->coordsys_case == 3)
 bs_case = 4;

 BSattxsect ( me->wrk.refpln, me->wrk.css_geom, me->wrk.orig_sect, me->wrk.trace_geom,
              me->crsloc[me->num_cross], bs_case, me->wrk.parpln, NULL,
              me->wrk.srf_geom, me->wrk.mirror_case, me->crsang[me->num_cross], &curv3,
              &loc_csys[0], &msg);
 if (msg != BSSUCC){status = OM_E_ABORT; goto wrapup;}

 me->wrk.tmp_crv.objid = NULL;
 me->wrk.tmp_crv.osnum = me->crsobj[me->num_cross].located_obj.osnum;

 /* save current coordsys data for dynamics */
 OM_BLOCK_MOVE(loc_csys, me->wrk.dyn_csys, sizeof(IGRdouble)*12 );

 NumberOfBytes = sizeof(struct IGRdisplay);
 gr$get_active_display(msg = &msg,
                    sizbuf = &NumberOfBytes,
                    buffer = &display_attr,
                      nret = &BytesReceived );
 if (!(1&msg)){status = OM_E_ABORT; goto wrapup;}

 NumberOfBytes = sizeof(IGRshort);
 gr$get_active_level(msg = &msg,
                  sizbuf = &NumberOfBytes,
                  buffer = &active_layer,
                    nret = &BytesReceived );
 if (!(1&msg)){status = OM_E_ABORT; goto wrapup;}

 /* display trace curve coordinate system at first cs_position */
 if (me->num_cross == 0 && me->wrk.loc_coord)
 {
    /* define display attributes (would be better to get them from options form) */
    arrow_display.color = 4; /* yellow */
    arrow_display.style = display_attr.style;
 
    /* determine range box */
    inq_array[0].var = VW_VOLUME;
    inq_array[0].var_ptr = (IGRchar *)vwvolume;
    inq_array[0].num_bytes = sizeof(IGRdouble) * 6;
    inq_array[0].bytes_returned = &BytesReceived;
    inq_array[1].var = END_PARAM;

    /*get view volume */
    sts = dp$inq_set_gragad(msg = &msg,
                               gragad_objid = me->locate_stack.window.objid,
                               osnum = me->locate_stack.window.osnum,
                               which_error = &error_var,
                               var_list = inq_array);
      if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

    OM_BLOCK_MOVE(&vwvolume[0], &range[0], sizeof(IGRpoint) );
    OM_BLOCK_MOVE(&vwvolume[3], &range[3], sizeof(IGRpoint) );

    /* compute range, arrow length should be 1/10 of the window diagonal
    EFdraw_vector.. already takes 1/4 of diagonal, so multiply upper corner by RANGE_DIV */

    range[3] = range[0] + ((range[3] - range[0]) * RANGE_DIV);
    range[4] = range[1] + ((range[4] - range[1]) * RANGE_DIV);
    range[2] = range[5] = 0.0;
    range[5] = range[2] + ((range[5] - range[2]) * RANGE_DIV);

    /* display coordinate system */
    for (i=0; i<3; i++)
    {
       if (i==0) 
       {
          arrow_display.weight = display_attr.weight + 2;
          OM_BLOCK_MOVE(&loc_csys[9], &point, sizeof(IGRpoint) );
       }
       else
          arrow_display.weight = display_attr.weight;

       OM_BLOCK_MOVE(&loc_csys[i*3], &vector, sizeof(IGRvector) );
       EFdraw_vector_on_screen (my_id, &arrow_display, &me->crsobj[me->num_cross].module_info,
                                GRbd, FALSE, point, vector, range, &msg); 

       /* remember all the data of coordinate system (struct of me->wrk) for erasing */
       OM_BLOCK_MOVE(range, me->wrk.coords.range, sizeof(GRrange) );
       OM_BLOCK_MOVE(&arrow_display, &me->wrk.coords.display, sizeof(struct IGRdisplay) );
       OM_BLOCK_MOVE(loc_csys, me->wrk.coords.csys, sizeof(IGRdouble)*12 );
    }
    me->wrk.loc_coord = FALSE;
 } /* end of display trace curve coordinate system */

 list.msg = &msg;
 list.env_info = &me->crsobj[me->num_cross].module_info;
 list.newflag = FALSE;
 list.level = active_layer;
 list.properties = GRIS_NEW | GRIS_DISPLAYABLE | GRIS_LOCATABLE;
 list.geometry = (IGRchar *) &curv3;
 list.display = &display_attr;
 list.class_attr = NULL;
 list.name = NULL;

 sts = om$construct ( classid = OPP_GRbcsubbc_class_id,
                      p_objid =  &me->wrk.tmp_crv.objid,
                      osnum   =  me->wrk.tmp_crv.osnum,
                      msg = message GRvg.GRconstruct (&list));
 if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

 gr$display_object (object_id = &me->wrk.tmp_crv,
                     mode = GRbd );

wrapup:
   if( curv3.poles )   om$dealloc( ptr = curv3.poles );

   return (status);

}

/*
Name
 hang_up_section

Abstract
 Performs the positioning of the cross-section at the trace.

Synopsis
 IGRboolean *backup;
 int *myevent_resp;
 int *response;
 char *response_data;

Description
 Every cross-section has to be positioned at the trace.
 User determines origin of cross-section, position at trace curve,
 mirroring and rotation about the trace. The cross-section displayed
 at the trace is only a temporary element to check the selections.
 The original cross-sections also used for recomputation is still
 located on the reference plane.

Parameters
 backup (OUT) - FALSE, if response eq. BACKUP or input does not fit the rules
 myevent_resp (OUT) - event.response for checking by caller

History
 03/10/94       R.Burkhart
    Creation date.


*/
method hang_up_section (IGRboolean *backup; int *myevent_resp; int *response; char *response_data)
{
 OMuword        r_classes[2], e_classes[2];
 OM_S_CLASSLIST rtree_classes, eligible_classes;
 IGRboolean     use_default, crv_reversed;
 IGRpoint       pt, pt1, pnt1, pnt2, ln_pt, proj_point;
 struct         IGRpolyline poly;
 IGRint         action, on_curve;
 IGRdouble      t, points[3];
 IGRlong        sts, msg, status;
 IGRlong        object_was_located, display_flag;
 struct         GRid linear_object, id;
 struct         GRlc_locate attributes;
 struct         GRevent event, accept_event;
 IGRchar        locate_prompt[52], acc_prompt[52], relocate_prompt[52];
 struct         IGRline boreline;
 struct         GRparms proj_parms;
 struct         GRsymbology symb;
 short unsigned pnt_color = COLOR;
 IGRuchar       pnt_weight = WEIGHT;
%safe
 static		struct GRlc_info orig_info;
%endsafe

 IGRboolean has_plane = TRUE, cs_exit = FALSE;

 action = 1;
 status = OM_S_SUCCESS;
 *backup = TRUE;

 /* define substate, if cmd was gone to sleep during hangup and this is the wakeup.
    Otherwise start from top of hangup_method. */
 if (! me->sleep_in_hangup)
 {
    me->substate = 999;
    /* set start_case for mirror */
    if (me->num_cross == 0)
       me->wrk.mirror_case = 0; 
 }
 else
    me->sleep_in_hangup = FALSE;

 switch (me->substate)
 {
   default:
   case SET_ORIGIN:
      me->substate = SET_ORIGIN;
      do
      {
         /* Select origin of cross-section */
         display_flag = 
          ALL_WINDOWS              |       /* Hilite in all windows */
          ELEM_HILIGHT             |       /* Hilite the whole element */
          NO_PROJ_ACCEPT_POINT     |       /* Don't project the accept point */
     /*     ACC_REJ_CYCLE            |  */     /* Run through accept reject cycle */
          LC_ACC_ONE_ELEMENT |
          RELOCATE                 |       /* Relocate if none found */
          LC_REGULAR_HIGHLIGHT     |       /* Use regular hilite not 1/2 */
          LC_ERASE_LOC_ELEMENT;            /* unhilite only rejected element */
         attributes.properties = 
          LC_LC_ONLY               |       /* Locate locatable objects */
          LC_DP_ONLY               |       /* Locate displayable objects */
          IGN_MOD_BIT              |       /* Ignore modified and new props */
          LC_PLANAR_NON_PLANAR     |       /* Planar or not */
          LC_RW;                           /* This is a read operation */
         attributes.owner_action = LC_RIGID_OWNER | LC_RIGID_COMP  |
                                   LC_FLEX_OWNER  | LC_FLEX_COMP   |
                                   LC_REF_OBJECTS | LC_NO_REF_HEADER; 
         rtree_classes.w_count = 1;
         rtree_classes.w_flags = OM_CLST_subclass;
         rtree_classes.p_classes = &r_classes[0];
         r_classes[0] = OPP_GRbspline_class_id;
         eligible_classes.w_count = 1;
         eligible_classes.w_flags = OM_CLST_subclass;
         eligible_classes.p_classes = &e_classes[0];
         e_classes[0] = OPP_GRpoint_class_id;

         ex$message(msgnumb = EMS_P_IdRefPt, buff = locate_prompt);
         ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
         ex$message(msgnumb = EMS_I_00013, buff = relocate_prompt);  

         sts = lc$locate( rc = &object_was_located,
                      event1 = &event,
                      event2 = &accept_event,
                       mask1 = GRm_DATA | GRm_BACK_UP,
                       mask2 = GRm_DATA,
                display_flag = display_flag,
              unhilight_mode = (enum GRdpmode ) GRhd,  /* Don't unhilite */
                    response = response,
               response_data = response_data,
               locate_prompt = locate_prompt,
                  acc_prompt = acc_prompt,
             relocate_prompt = relocate_prompt,
                  attributes = &attributes,
                       stack = &me->locate_stack,
               rtree_classes = &rtree_classes,
            eligible_classes = &eligible_classes);
           if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

         *myevent_resp =  event.response;
         ex$message(msgnumb = EMS_P_ClearPromptField);
         ex$message(msgnumb = EMS_S_ClearStatusField); 

         if (!object_was_located)
         {
           if (event.response == EX_BACK_UP)  *backup = FALSE;
           return(OM_S_SUCCESS);
         }

         id = accept_event.located_object[0].located_obj;

         /* unhighlight the selected point */
         sts = gr$display_object( object_id = &id, mode = GRhe ); 
         if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

         /* Check if one of the origins parent is member of class EMSdatpln */
         sts = om$send( msg = message ECprfsksf.check_ref_plane( FALSE, 
                                            &accept_event.located_object[0], &has_plane), 
                   targetid = my_id);
         if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

         if (! has_plane)
            ex$message( msgnumb =EMS_S_RefPntOnRefPln) /* Origin must lie on reference plane of cross-section */
         else
         { 
            orig_info = accept_event.located_object[0];
            cs_exit = TRUE;
            me->substate = SET_LOCATION;
         }
      }  while (!cs_exit);
      /* end case SET_ORIGIN */

   case SET_LOCATION:
      cs_exit = FALSE;
      do
      {
         if (! me->select_screen_pos)
         {
            /* Select position at trace curve by existing point  */
            display_flag =
             ALL_WINDOWS              |       /* Hilite in all windows */
             ELEM_HILIGHT             |       /* Hilite the whole element */
             NO_PROJ_ACCEPT_POINT     |       /* Don't project the accept point */
             ACC_REJ_CYCLE            |       /* Run through accept reject cycle */
             RELOCATE                 |       /* Relocate if none found */
             LC_REGULAR_HIGHLIGHT     |       /* Use regular hilite not 1/2 */
             LC_ERASE_LOC_ELEMENT;            /* unhilite only rejected element */
            attributes.properties =
             LC_LC_ONLY               |       /* Locate locatable objects */
             LC_DP_ONLY               |       /* Locate displayable objects */
             IGN_MOD_BIT              |       /* Ignore modified and new props */
             LC_PLANAR_NON_PLANAR     |       /* Planar or not */
             LC_RW;                           /* This is a read operation */
            attributes.owner_action = LC_RIGID_OWNER | LC_RIGID_COMP  |
                                      LC_FLEX_OWNER  | LC_FLEX_COMP   |
                                      LC_REF_OBJECTS | LC_NO_REF_HEADER;
            rtree_classes.w_count = 1;
            rtree_classes.w_flags = OM_CLST_subclass;
            rtree_classes.p_classes = &r_classes[0];
            r_classes[0] = OPP_GRbspline_class_id;
            eligible_classes.w_count = 1;
            eligible_classes.w_flags = OM_CLST_subclass;
            eligible_classes.p_classes = &e_classes[0];
            e_classes[0] = OPP_GRpoint_class_id;

            ex$message(msgnumb = EMS_P_SelectPntOnTrc, buff = locate_prompt);
            ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
            ex$message(msgnumb = EMS_I_00013, buff = relocate_prompt);
            sts = lc$locate( rc = &object_was_located,
                         event1 = &event,
                         event2 = &accept_event,
                          mask1 = GRm_DATA | GRm_BACK_UP,
                          mask2 = GRm_DATA,
                   display_flag = display_flag,
                 unhilight_mode = (enum GRdpmode ) GRhd,  
                       response = response,
                  response_data = response_data,
                  locate_prompt = locate_prompt,
                     acc_prompt = acc_prompt,
                relocate_prompt = relocate_prompt,
                     attributes = &attributes,
                          stack = &me->locate_stack,
                  rtree_classes = &rtree_classes,
               eligible_classes = &eligible_classes);
              if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}
      
            *myevent_resp =  event.response;
            ex$message(msgnumb = EMS_P_ClearPromptField);
            ex$message(msgnumb = EMS_S_ClearStatusField);

            if (!object_was_located)
            {
              if (event.response == EX_BACK_UP)  *backup = FALSE;
              return(OM_S_SUCCESS);
            }
            id = accept_event.located_object[0].located_obj;
            sts = gr$display_object( object_id = &id, mode = GRhe );
            if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

            /* we store the unprojected point, because we need lc_info and
            it will be projected again in the recomputation function */
            me->trcloc[me->num_cross] = accept_event.located_object[0];

            poly.points = pt;  /* allocates storage */

            sts = om$send ( msg = message GRlinear.GRgetpolyline ( &msg,
                                     &accept_event.located_object[0].module_info.md_env.matrix_type,  
                                     accept_event.located_object[0].module_info.md_env.matrix, &action,
                                     &poly),
                       targetid = id.objid,
                       targetos = id.osnum );
            if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

            gr$project_pnt_on_element( msg = &msg,
                                    md_env = &me->trcobj[0].module_info,
                                object_id  = &me->trcobj[0].located_obj,
                                     point = pt,
                                   proj_pt = proj_point,
                                   u_parm  = &me->crsloc[me->num_cross],
                                   v_parm  = &t);

            cs_exit = TRUE;
         }
         else
         {
            /* create boreline */
            sts = co$getevent ( msg = &msg,
                         event_mask = GRm_DATA | GRm_BACK_UP,
                             msgnum = EMS_P_SelectPosOnTrc,
                           response = response,
                      response_data = response_data,
                              event = &event);
            if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

            ex$message(msgnumb = EMS_P_ClearPromptField);
            ex$message(msgnumb = EMS_S_ClearStatusField);
            *myevent_resp =  event.response;

            if (event.response == EX_BACK_UP)
            {
              *backup = FALSE;
              return(OM_S_SUCCESS);
            }
            else if (event.response == GR_UNKNOWN_TYPE)
              return(OM_S_SUCCESS);
            else
            {
              boreline.point1 = pnt1;  /* allocates storage for */
              boreline.point2 = pnt2;  /* the boreline          */

              EFboreline(&msg, my_id, &event, &boreline);

              /* find parameter on curve */
              sts = om$send(msg = message GRgraphics.GRlnproject(&msg,
                                  &me->trcobj[0].module_info.md_env.matrix_type,
                                  me->trcobj[0].module_info.md_env.matrix,
                                  &boreline, ln_pt, proj_point, &t, &proj_parms),
                       senderid = my_id,
                       targetid = me->trcobj[0].located_obj.objid,
                       targetos = me->trcobj[0].located_obj.osnum);
              if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

              me->crsloc[me->num_cross] = proj_parms.u;

              /* we also have to create a point for recomputation */

              points[0] = proj_point[0];
              points[1] = proj_point[1];
              points[2] = proj_point[2];

              gr$place_linear_object( msg = &msg,
                                   md_env = &me->trcobj[0].module_info,
                               num_points = 1,
                                   points = points,
                                object_id = &linear_object,
                             display_flag = 0);
              if (!(1&msg)){status = OM_E_ABORT; goto wrapup;}

              /* change the color and weight of point, to better find it */
              gr$get_symbology (object_id = &linear_object,
                                     symb = &symb);
              symb.display_attr.color  = pnt_color;
              symb.display_attr.weight = pnt_weight;
              gr$put_symbology (object_id = &linear_object,
                                     symb = &symb);

              gr$display_object (object_id = &linear_object,
                                      mode = GRbd );

              /* create the lc_info structure */
              me->trcloc[me->num_cross] = me->trcobj[0];
              me->trcloc[me->num_cross].located_obj.objid = linear_object.objid;
              me->trcloc[me->num_cross].geom_parms.leaf_id.objid = NULL;
              me->trcloc[me->num_cross].geom_parms.leaf_id.osnum = NULL;
              me->trcloc[me->num_cross].geom_parms.polygon_inx = 3;

              cs_exit = TRUE;
            }  /* end if (event.response ..) */
         }     /* end if (! me->select_screen_pos */

         /* parameter me->crsloc[me->num_cross] is correct for non-composites only, e.g. for profiles a relative
         parameter dependend on subcurve_count has to be computed, p = ((curve_num -1) + u )/ curve_count */

         /* check, if composite curve */
         if (EFisAncestryValid(&msg, me->trcobj[0].located_obj.objid,
                               me->trcobj[0].located_obj.osnum,
                               OPP_SKcompcurve_class_id, FALSE))
         {
            /* get parameter on composite curve */
            sts = om$send(msg = message GRcompcurve.EMpratpt (&msg,
                                &me->trcobj[0].module_info.md_env.matrix_type,
                                me->trcobj[0].module_info.md_env.matrix,
                                proj_point, &me->crsloc[me->num_cross], &on_curve),
                     targetid = me->trcobj[0].located_obj.objid,
                     targetos = me->trcobj[0].located_obj.osnum);
            if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}
         }

         /* check, if curve is reversed */
         crv_reversed = (&me->trcobj[0])->geom_parms.polygon_inx;
         if (crv_reversed) 
         me->crsloc[me->num_cross] = 1.0 - me->crsloc[me->num_cross];

         me->substate = SET_MIRROR_CASE;
      } while (! cs_exit);
      /* end case SET_LOCATION */

   case SET_MIRROR_CASE:

      /* Display the cross-section at the position and ask for mirroring, if first cs */
      if(me->num_cross == 0)
      {
         /* allocate storage */ 
         /* get the trace geometry */
         sts = EMget_the_geometry(&me->trcobj[0], TRUE, TRUE, FALSE,
                                  me->trcobj[0].located_obj.objid, &me->wrk.trace_geom, &msg);
         if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}
         if (me->coordsys_case == 3)
         {
         /* get the surface geometry */
            sts = EMget_the_geometry(&me->orient_surface, FALSE, FALSE, FALSE,
                                     me->orient_surface.located_obj.objid, &me->wrk.srf_geom, &msg);
            if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}
         }
         else
         {
            me->wrk.srf_geom = NULL;
         }
      }

      /* get the cross-section geometry */
      sts = EMget_the_geometry(&me->crsobj[me->num_cross], TRUE, TRUE, FALSE,
                               me->crsobj[me->num_cross].located_obj.objid, &me->wrk.css_geom, &msg);
      if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

      /* get css origin data */
      poly.points = pt1;  /* allocates storage */

      sts = om$send ( msg = message GRlinear.GRgetpolyline ( &msg,
                                    &orig_info.module_info.md_env.matrix_type,  
                                    orig_info.module_info.md_env.matrix, &action,
                                    &poly),
                 targetid = orig_info.located_obj.objid,
                 targetos = orig_info.located_obj.osnum );
      if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

      OM_BLOCK_MOVE( &pt1[0], &me->wrk.orig_sect[0], sizeof(IGRpoint));
      OM_BLOCK_MOVE( &pt1[0], &me->crsopt[me->num_cross][0], sizeof(IGRpoint));

  
      if(me->num_cross == 0)
      {
         /* set angle to 0 degree */
         me->crsang[me->num_cross] = NULL;
         cs_exit = FALSE;
         do
         {
            gr$delete_object (msg = &msg, object_id = &me->wrk.tmp_crv);
            sts = om$send (msg = message ECprfsksf.display_on_site(),
                      targetid = my_id);
            if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

            /* Ask for correct orientation */
            sts = co$getevent ( msg = &msg,
                         event_mask = GRm_DATA | GRm_RJT_MOVEON |
                                      GRm_BACK_UP,
                             msgnum = EMS_P_AccSiteMvOnForMir,      /* Accept orientation of cross-section/Move on for mirror */
                           response = response,
                      response_data = response_data,
                              event = &event);
            if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

            ex$message(msgnumb = EMS_P_ClearPromptField);
            ex$message(msgnumb = EMS_S_ClearStatusField);
            *myevent_resp =  event.response;
            if (event.response == EX_BACK_UP)
            {
              *backup = FALSE;
              gr$delete_object (msg = &msg, object_id = &me->wrk.tmp_crv);
              return(OM_S_SUCCESS);
            }
            else if (event.response == GR_UNKNOWN_TYPE)
            {
               return(OM_S_SUCCESS);
            }
            else if (event.response == EX_RJT_MOVEON )
            {
               /* mirror cross-section */
	       me->wrk.mirror_case = (me->wrk.mirror_case +1) % 4; 
            }
            else
            {
               /* orientation is o.k. */
               cs_exit = TRUE;
            }
         } while (! cs_exit);
      }    /* end if num_cross = 0 */
      else if ((me->num_cross > 0) && (! me->angle_constant))
      {
         /* set angle to 0 degree */
         me->crsang[me->num_cross] = NULL;
         sts = om$send (msg = message ECprfsksf.display_on_site(),
                   targetid = my_id);
         if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}
      }
      me->substate = SET_ANGLE;
      /* end of case SET_MIRROR_CASE */

   case SET_ANGLE:
      cs_exit = FALSE;

      if ( (me->num_cross == 0) || ((me->num_cross > 0) && (! me->angle_constant)) )
      { 
         IGRlong    event_mask, key;
         IGRchar    prompt[80];
         IGRboolean inquire = 1;
         IGRboolean dyn_on;
         int        dyn_response;

         DPdynflags (&msg, &inquire, &dyn_on, NULL);

         do
         {
            if (dyn_on)
            {
               key = EMS_P_EntAngRotTrcDyn; /*Enter angle to rotate section (-PI,+PI)[0]/Move on for dynamics*/
               event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
            }
            else
            {
               key = EMS_P_EntAngRotTrc;    /*Enter angle to rotate section (-PI,+PI)[0]*/
               event_mask = GRm_VALUE | GRm_BACK_UP;
            }
            ex$message (msgnumb = key, buff = prompt); 

            /* Ask for Rotation */
            sts = co$getevent ( msg = &msg,
                         event_mask = event_mask,
                            prompt  = prompt,
                         value_type = GRIO_ANGLE,
                           response = response,
                      response_data = response_data,
                              event = &event);
            if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}
            ex$message(msgnumb = EMS_P_ClearPromptField);
            ex$message(msgnumb = EMS_S_ClearStatusField);
            *myevent_resp =  event.response;
   
            if (event.response == EX_BACK_UP)
            {
              *backup = FALSE;
              gr$delete_object (msg = &msg, object_id = &me->wrk.tmp_crv);
              return(OM_S_SUCCESS);
            }
            else if (event.response == EX_RJT_MOVEON)
            {
               sts = om$send( msg = message ECprfsksf.perform_dyn(event),
                         targetid = my_id);
                if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

               ex$peek_event_queue ( resp = &dyn_response );
               if (dyn_response == EX_STRING)
                  *myevent_resp = EX_VALUE;
               else
                  *myevent_resp = GR_UNKNOWN_TYPE;

               gr$delete_object (msg = &msg, object_id = &me->wrk.tmp_crv);
               sts = om$send (msg = message ECprfsksf.display_on_site(),
                         targetid = my_id);
                if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

                return(OM_S_SUCCESS);
            }
            else if (event.response == GR_UNKNOWN_TYPE)
            {
               if (*response == EX_DATA || *response == EX_RJT_MOVEON) 
               {
                  me->crsang[me->num_cross] = NULL;
                  *myevent_resp = EX_VALUE;
                  cs_exit = TRUE;
               }
               else
               {
                  return(OM_S_SUCCESS);
               }
            } 
            else if (event.response == EX_VALUE)
            {
               use_default = (me->msg == GRw_no_value); 
               if (use_default)
               {
                  me->crsang[me->num_cross] = NULL;
                  cs_exit = TRUE;
               }
               else if (event.event.value < -M_PI || event.event.value > M_PI)
               {
                  ex$message (msgnumb = EMS_E_InvalidAngle);
               }
               else
               {
                  me->crsang[me->num_cross] = event.event.value;
                  cs_exit = TRUE;
               }
            }    /* end if EX_VALUE */
         } while (! cs_exit);
      }
      else
      {
         /* angle_constant */
         me->crsang[me->num_cross] = me->crsang[0];
         sts = om$send (msg = message ECprfsksf.display_on_site(),
                   targetid = my_id);
          if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}
      }  /* endif ! me->angle_constant */
      me->substate = SET_ORIENTATION;
      /* end of case SET_ANGLE */

   case SET_ORIENTATION:
   {
      IGRdouble test;
      IGRlong i;
 
      test = 0.0;
      for (i=0; i < me->num_cross; i++)
         test += me->crsang[i];

      if( (me->num_cross == 0) ||
          ( (me->num_cross > 0) && (!me->angle_constant) && (test == 0.0) ) )
      {
         me->wrk.toggle_case = 1;
         if( me->crsang[me->num_cross] != 0.0)
         {
            cs_exit = FALSE;
            do
            {
               gr$delete_object (msg = &msg, object_id = &me->wrk.tmp_crv);
               sts = om$send (msg = message ECprfsksf.display_on_site(),
                         targetid = my_id);
               if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

               /* Ask for correct angle orientation */
               sts = co$getevent ( msg = &msg,
                            event_mask = GRm_DATA | GRm_RJT_MOVEON |
                                         GRm_BACK_UP,
                                msgnum = EMS_P_AccAngOrMvOnTgl,      /* Accept orientation of angle/Move on for toggle */
                              response = response,
                         response_data = response_data,
                                 event = &event);
               if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

               ex$message(msgnumb = EMS_P_ClearPromptField);
               ex$message(msgnumb = EMS_S_ClearStatusField);
               *myevent_resp =  event.response;
               if (event.response == EX_BACK_UP)
               {
                  *backup = FALSE;
                  gr$delete_object (msg = &msg, object_id = &me->wrk.tmp_crv);
                  return(OM_S_SUCCESS);
               }
               else if (event.response == GR_UNKNOWN_TYPE)
               {
                  return(OM_S_SUCCESS);
               } 
               else if (event.response == EX_RJT_MOVEON )
               {
                  /* toogle angle orientation */
                  me->crsang[me->num_cross] = - (me->crsang[me->num_cross]);
                  me->wrk.toggle_case = - me->wrk.toggle_case;
               }
               else
               {
                  /* orientation is o.k. */
                  cs_exit = TRUE;
               }
            } while (! cs_exit);
         }    /* end if crs_ang != 0.0 */
      }
      else
      {
         /* do not ask for toggle orientation, but change orientation only if variable angle */
         if (!me->angle_constant)               
         me->crsang[me->num_cross] = (me->wrk.toggle_case) * me->crsang[me->num_cross];

         gr$delete_object (msg = &msg, object_id = &me->wrk.tmp_crv);
         sts = om$send (msg = message ECprfsksf.display_on_site(),
                   targetid = my_id);
          if (!(1&sts)){status = OM_E_ABORT; goto wrapup;}

       }  /* end if num_cross == 0 */
    }   /* end of case SET_ORIENTATION */
 } /* end of switch me->substate */

wrapup:

   return (status);
}

/*
Name
 check_ref_plane

Abstract
 Investigates the reference plane of a cross-section.

Synopsis
 IGRboolean testcase;
 struct GRlc_info *check_info;
 IGRboolean *on plane;

Description
 All cross-sections and their origin points have to lie on one reference plane, which must
 be a parent of the owner of every cross-section and origin point. This will be checked.
 If the first cross-section meets these case then the informations about the reference
 plane will be extracted.

Parameters
 testcase (IN)   -  if TRUE, check the cross-section
 check_info (IN) -  objid and osnum of element to be checked
 on_plane (OUT)  -  object fits all restrictions (TRUE) or not (FALSE)
*/
method check_ref_plane (IGRboolean testcase; struct GRlc_info *check_info; IGRboolean *on_plane)
{
   IGRboolean found_plane, composite_case;
   IGRuint type, info_size;
   IGRint num_parents, owner_count;
   OMuint count;
   struct GRid check_GRid,*ids = NULL;
   char *info = NULL;
   struct GRid *parents = NULL;
   IGRlong status, msg, i, sts, ii;
   GRspacenum found_osnum;
   GRobjid    found_id;
   GRclassid  classid;
   OM_S_CHANSELECT   owner_chansel;
   OM_p_OBJECT_LINKAGE list_ids = NULL;

   status = OM_S_SUCCESS;
   *on_plane = TRUE;

   check_GRid = check_info->located_obj;
   found_id = NULL;
   found_osnum = NULL;
   found_plane = FALSE;
   owner_count = NULL;
   composite_case = FALSE;

second_time:

   /* get the owner (which is the profile) because only the owner knows the parents */
   GRget_to_owner_info ( &owner_chansel, check_GRid.osnum, check_GRid.objid, &owner_count );

   if (owner_count)
   {
      list_ids = (OM_p_OBJECT_LINKAGE) om$malloc
                 (size = (sizeof (OM_S_OBJECT_LINKAGE) * owner_count) );
      if(!list_ids){status = OM_E_ABORT; goto wrapup;}

      sts = om$get_channel_objects (osnum = check_GRid.osnum,
                                    objid = check_GRid.objid,
                             p_chanselect = &owner_chansel,
                                     list = list_ids,
                                     size = owner_count,
                                    count = &count);
      if(!(1&sts)){status = OM_E_ABORT; goto wrapup;}

      ids = (struct GRid *) om$malloc (size = (sizeof (struct GRid) * owner_count) );
      if(!ids){status = OM_E_ABORT; goto wrapup;}

      for (ii = 0; ii < owner_count; ii++)
      {
         ids[ii].objid = list_ids[ii].S_objid;
         ids[ii].osnum = list_ids[ii].osnum;
   
         /* handle components of composites */
         if (! composite_case)
         {
            /* Check the class of the selected element.  If its a composite,
            get the owner of the composite */
            om$get_classid ( osnum = list_ids[ii].osnum,
                             objid = list_ids[ii].S_objid,
                         p_classid = &classid );

            if (om$is_ancestry_valid (subclassid = classid,
                                superclassid = OPP_SKcompcurve_class_id) == OM_S_SUCCESS)
            {
               check_GRid.osnum = list_ids[ii].osnum;
               check_GRid.objid = list_ids[ii].S_objid;
               composite_case = TRUE;
               goto second_time; 
            }
         }
         /* get parent count */
         EFget_parents_and_info(&msg, &ids[ii], &type, &info_size,
                                 NULL, &num_parents, NULL);
         if(!(1&msg)){status = OM_E_ABORT; goto wrapup;}
      
         if (num_parents)
         {
          parents = (struct GRid *) om$malloc (size = (sizeof (struct GRid) * num_parents) );
          if(!parents){status = OM_E_ABORT; goto wrapup;}
         }
         else
         {
          *on_plane = FALSE;
          goto wrapup;
         }
      
         if (info_size)
         {
          info = (char *) om$malloc (size = (info_size) );
          if(!info){status = OM_E_ABORT; goto wrapup;}
         }
      
         /* get parent info */
         EFget_parents_and_info (&msg, &ids[ii], &type, &info_size, info,
                                 &num_parents, parents);
         if(!(1&msg)){status = OM_E_ABORT; goto wrapup;}

         /* check if one of parents belongs to EMSdatpln */
         for (i=0;i<num_parents;i++)
         {
            if (EFisAncestryValid(&msg, parents[i].objid, parents[i].osnum,
                                  OPP_EMSdatpln_class_id, FALSE))
            {
               found_plane  = TRUE;
               found_id     = parents[i].objid;
               found_osnum  = parents[i].osnum;
               break;
            }
         } /* end for num_parents */
         if(found_plane) break;
      }    /* end for owner_count */
   }       /* end if owner_count */

   if(!found_plane)
   {
      *on_plane = FALSE;
      goto wrapup;
   } 

   if (me->num_cross == 0 && testcase)
   {
     me->wrk.crs_refpl_id = found_id;
     for (i=0;i<11;i++){ me->wrk.refpln[i] = 0.0;}

     /* get the reference plane info */
     sts = om$send (msg = message EMSdatpln.EMget_pln_info(&msg, NULL, NULL,
                                            &(me->wrk.refpln[0]), &(me->wrk.refpln[3]),
                                            &(me->wrk.refpln[6]), &(me->wrk.refpln[9]), NULL),
               senderid = NULL_OBJID,
               targetid = found_id,
               targetos = found_osnum);
     if (!(1&sts&msg)){status = OM_E_ABORT; goto wrapup;}
   }
   else
   {
   /* check if the reference plane is the same for all cross-sections and 
      origins of cross_sections */
      if(! (found_id == me->wrk.crs_refpl_id))
      {
         *on_plane = FALSE;
         goto wrapup;
      }
   }

wrapup:

   if(ids) om$dealloc (ptr=ids);
   if(list_ids) om$dealloc (ptr=list_ids);
   if(parents) om$dealloc (ptr=parents);
   if(info) om$dealloc (ptr=info);
   return (status);
}

end implementation ECprfsksf;
