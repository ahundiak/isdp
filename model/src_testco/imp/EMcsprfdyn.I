class implementation ECprfsksf;

%safe
#include <math.h>
%endsafe

#include "ems_m_inc.h"          /* Includes everything */
#include "OMmacros.h"           /* OM_BLOCK_MOVE macro */
#include "igrdef.h"             /* IGRBC definition */
#include "dpdef.h"
#include "dpstruct.h"
#include "dpezmac.h"            /* dp$inq_window */
#include "fontdef.h"
#include "font.h"
#include "gotext.h"             /* struct extents */
#include "bsvalues.h"           /* M_PI */
#include "bsbdlnplint.h"
#include "bsattxsect.h"
#include "marang2vc.h"

#define BASTOL 1e-5
#define DEG_TO_RAD M_PI/180.
#define RAD_TO_DEG 180./M_PI
from GRfm import GRfm_retdata;

/* globals used */
IGRdouble rot_wld_vw[16];
IGRdouble step_size;

/*
 Name
  perform_dyn

 Abstract
  This method performs the dynamics for the Place Surface Cross
  Section cmd

 Parameters
 dyn_event (IN) - event of invoking this method (to get the right window
                  for the local bounded system generation)


 History
  08/02/94 R.Burkhart

*/
method perform_dyn(struct GRevent dyn_event)
{
 struct IGRdisplay      *my_display;
 IGRboolean              dyn_on;         
 IGRboolean              inquire = 1;    
 IGRlong                 NumberOfBytes, BytesReceived, size;
 struct DYrotang_info    dyn_info = {0,NULL,NULL,NULL,NULL};         
 struct IGResbc          specific;
 struct IGResintx        text_attr;       /* text specific attributes    */
 struct IGRestx          estx1;           /* text element specific attributes */
 struct IGRlbsys         text1;           /* LBS geometry                */
 struct GRdpb_text_symb  text_symb;       /* 'active' text parameters    */
 struct extents          text_extents;    /* extents of text string      */
 OM_S_OBJID              cur_mod_id;      /* current module's object id  */
 OMuword                 cur_mod_osnum;   /* current module's osnum      */
 struct GRid             fontmgr_obj;     /* objid/osnum of font manager */
 struct vfont_entry      font_info;       /* original font information   */
 IGRchar                 angle_text[20];
 struct IGRbsp_curve     crv1;
 IGRpoint                pt1;
 IGRvector               vec1;
 IGRchar                 response_data[1024];
 IGRint                  pos, response;
 IGRlong                 i, sts, msg;
 IGRdouble               count, dyn_angle;
 IGRdouble               ActiveAngle, vwvolume[6], origin_point[3], rot_mat_txt[16];
 
 msg = MSSUCC;

 /* do dynamics only for angle input */
 if (! (me->state == CROSS_CURVES && me->substate == SET_ANGLE))
    goto wrapup;

 /* Compiler optimization */
 my_display = &me->display;

 /* set up element specific display for bsplines */
 specific.is_polydis = FALSE;
 specific.is_curvedis = TRUE;

 /* set up dyn_info */
 dyn_info.num_buffs = 2;
 dyn_info.display_buffers = (struct DPele_header *)om$malloc
                            (size = (sizeof (struct DPele_header) * dyn_info.num_buffs) );
  if(!dyn_info.display_buffers){msg = MSFAIL; goto wrapup;}

 /* get the geometry of bscurve */
 dyn_info.bscurve = &crv1;
 dyn_info.bscurve->order            = (me->wrk.css_geom)->order;
 dyn_info.bscurve->periodic         = (me->wrk.css_geom)->periodic;
 dyn_info.bscurve->non_uniform      = (me->wrk.css_geom)->non_uniform;
 dyn_info.bscurve->num_poles        = (me->wrk.css_geom)->num_poles;
 dyn_info.bscurve->poles            = (IGRdouble *) om$malloc (size = (sizeof (IGRpoint) * dyn_info.bscurve->num_poles));
 if(!dyn_info.bscurve->poles){msg =  MSFAIL; goto wrapup;}

 for(i=0;i<dyn_info.bscurve->num_poles*3;i=i+3)
 {
    dyn_info.bscurve->poles[i]   = (me->wrk.css_geom)->poles[i];
    dyn_info.bscurve->poles[i+1] = (me->wrk.css_geom)->poles[i+1];
    dyn_info.bscurve->poles[i+2] = (me->wrk.css_geom)->poles[i+2];
 }
 dyn_info.bscurve->num_knots        = (me->wrk.css_geom)->num_knots;
 dyn_info.bscurve->knots            = (me->wrk.css_geom)->knots;

 dyn_info.bscurve->rational         = (me->wrk.css_geom)->rational;
 if (dyn_info.bscurve->rational == TRUE)
 {
    dyn_info.bscurve->weights       = (me->wrk.css_geom)->weights;
 }
 else
 {
    dyn_info.bscurve->weights       = NULL;
 }
 dyn_info.bscurve->planar           = (me->wrk.css_geom)->planar;
 dyn_info.bscurve->phy_closed       = (me->wrk.css_geom)->phy_closed;
 dyn_info.bscurve->num_boundaries   = (me->wrk.css_geom)->num_boundaries;
 dyn_info.bscurve->bdrys            = (me->wrk.css_geom)->bdrys;

 /* coordsys_case 3 is not implemented yet */
 dyn_info.bs_case = me->coordsys_case;
 if (me->coordsys_case == 3)
 dyn_info.bs_case = 4;

 dyn_info.plane.point = (IGRdouble *)pt1;
 dyn_info.plane.normal =(IGRdouble *)vec1;
 OM_BLOCK_MOVE (&me->wrk.dyn_csys[9], dyn_info.plane.point, sizeof(IGRdouble) * 3  );
 OM_BLOCK_MOVE (&me->wrk.dyn_csys[6], dyn_info.plane.normal, sizeof(IGRdouble) * 3 );
 OM_BLOCK_MOVE (&me->wrk.dyn_csys[0], &dyn_info.start_vec, sizeof(IGRvector) );

 /* get the trace geometry */
 sts = EMget_the_geometry(&me->trcobj[0], TRUE, TRUE, FALSE,
                          me->trcobj[0].located_obj.objid, &dyn_info.trace, &msg);
 if (!(1&sts)){msg = MSFAIL; goto wrapup;}
 if (me->coordsys_case == 3)
 {
    /* get the surface geometry */
    sts = EMget_the_geometry(&me->orient_surface, FALSE, FALSE, FALSE,
                             me->orient_surface.located_obj.objid, &dyn_info.srf, &msg);
    if (!(1&sts)){msg = MSFAIL; goto wrapup;}
 }
 else
 {
    dyn_info.srf = NULL;
 }

 OM_BLOCK_MOVE (&me->wrk.refpln, dyn_info.refplane, sizeof(IGRdouble) * 12 );
 OM_BLOCK_MOVE (&me->wrk.orig_sect, dyn_info.orig_xsect, sizeof(IGRpoint) );
 dyn_info.param = me->crsloc[me->num_cross];
 OM_BLOCK_MOVE (&me->wrk.parpln, dyn_info.vec, sizeof(IGRvector) );
 dyn_info.mirror = me->wrk.mirror_case;
 dyn_info.mirr_toggle = 1;
 if (me->wrk.mirror_case == 1 || me->wrk.mirror_case == 2)
    dyn_info.mirr_toggle = -1;

 /* fill the buffer with geometry of unmapped cs (same size) */
 sts = EMget_the_geometry(&me->crsobj[me->num_cross], TRUE, TRUE, FALSE,
                          me->crsobj[me->num_cross].located_obj.objid,
                          &dyn_info.display_buffers->geometry.bspcurve, &msg);
 if (!(1&sts)){msg = MSFAIL; goto wrapup;}

 dp$build_dis_buffer( buffer = dyn_info.display_buffers,
                      type = IGRBC,
                      display_att = my_display, 
                      ele_spec_att = &specific,
                      geometry = dyn_info.display_buffers->geometry.bspcurve );

 /* build text buffer */
 dyn_info.display_buffers[1].geometry.lbsys = &text1;
 /* get the text specific default parameter data from the DPB */
 NumberOfBytes = sizeof(struct GRdpb_text_symb);
 gr$get_text_symb(msg = &msg,
               sizbuf = &NumberOfBytes,
               buffer = &text_symb,
                 nret = &BytesReceived);

 NumberOfBytes = sizeof(IGRdouble);
 gr$get_active_angle(msg = &msg,
                  sizbuf = &NumberOfBytes,
                  buffer = &ActiveAngle,
                    nret = &BytesReceived);

 /* get the objid of the font manager using its named object */
 sts = ex$get_cur_mod(osnum = &cur_mod_osnum,
                         id = &cur_mod_id);
  if (!(1&sts)){msg = MSFAIL; goto wrapup;}

 sts = ex$get_super(mod_id = cur_mod_id,
                 mod_osnum = cur_mod_osnum,
                super_name = FONTMGR_NO_NAME,
                    create = TRUE,
               super_class = "GRfm",
                  super_id = &fontmgr_obj.objid,
               super_osnum = &fontmgr_obj.osnum);
  if (!(1&sts)){msg = MSFAIL; goto wrapup;}

 /* get font information about specified font */
 sts = om$send( msg = message GRfm.GRfm_retdata (&msg, &text_symb.Active_font, &font_info),
               mode = OM_e_wrt_object,
           senderid = NULL_OBJID,
           targetid = fontmgr_obj.objid,
           targetos = fontmgr_obj.osnum);
  if (!(1&sts)){msg = MSFAIL; goto wrapup;}

 /* allocate space for struct IGRestx */
 text_attr.estx = &estx1;

 text_attr.font_id = fontmgr_obj.osnum;
 text_attr.flags = 0;
 text_attr.prev_font = text_symb.Active_font;
 text_attr.estx->font = text_symb.Active_font;
 text_attr.estx->just = text_symb.Active_just;
 text_attr.estx->width = text_symb.Active_width;
 text_attr.estx->height = text_symb.Active_height;
 text_attr.estx->flag = text_symb.Active_flags;
 text_attr.estx->num_char = 0;
 text_attr.estx->line_spac = text_symb.Active_linespac;
 text_attr.estx->char_spac = text_symb.Active_charspac;
 text_attr.estx->text_length = 13;
 text_attr.text_string = angle_text;

 dyn_angle = 0.;
 sprintf(angle_text,"%9.2f deg",dyn_angle);

 /* create a dummy local bounded system of the text object */
 dp$inq_window_info( msg = &msg,
                   osnum = dyn_event.event.button.osnum,
            window_objid = dyn_event.event.button.objid,
             view_origin = origin_point,
               vw_volume = vwvolume,
           view_rotation = rot_mat_txt);

  text_extents.left   = vwvolume[0] * .1;
  text_extents.bottom = vwvolume[1] * .1;
  text_extents.base   = 0;
  text_extents.right  = vwvolume[3] * .1;
  text_extents.top    = vwvolume[4] * .1;
  text_extents.cap    = 0;

 sts = GRcreate_lbs (&msg, &ActiveAngle, rot_mat_txt,
                    origin_point, &text_extents,
                    dyn_info.display_buffers[1].geometry.lbsys);
  if (!(1&sts)){msg = MSFAIL; goto wrapup;}

 dp$build_dis_buffer (buffer = &dyn_info.display_buffers[1],
                      type = IGRLB,
                      display_att = my_display,
                      ele_spec_att = &text_attr,
                      geometry = dyn_info.display_buffers[1].geometry.lbsys);

 step_size = me->wrk.dyn_step * DEG_TO_RAD;

 DPdynflags (&msg, &inquire, &dyn_on, NULL);

 if (dyn_on) 
     dp$dynamics (dyn_fun = DYrotang_dyn, information = &dyn_info);

 /* get the input  */
 size = 1024;
 msg = ex$wait_for_input ( response = &response,  
                            buffer = response_data,
                            byte = (int *)&size );

 /* if this is a data point, get the angle */
 if ( (msg & 1) && (response == EX_DATA) )
 {
     EFcalc_turn_angle ( &msg, &((struct EX_button *)response_data)->x,
                        &dyn_info.plane, rot_wld_vw, dyn_info.start_vec,
                        dyn_info.mirr_toggle, &dyn_angle);

     /* fit angle into step size range */
     if (dyn_angle < 0.)
        modf(((dyn_angle - (.5 * step_size) - BASTOL) /  step_size), & count);
     else
        modf(((dyn_angle + (.5 * step_size) + BASTOL) /  step_size), & count);
     me->crsang[me->num_cross] = (IGRint)count * step_size; 

     response = EX_STRING;
     sprintf(response_data,"%f radians",me->crsang[me->num_cross]);
     size = strlen(response_data) + 1;

     /* syncronize angle orientation data */
     if (dyn_info.mirr_toggle == -1)
        me->wrk.toggle_case = -1;
 }
 /* push the input back on the queue  */
 ex$putque ( msg = &msg,
        response = &response,
            byte = &size,
          buffer = response_data );

 /* redraw any objects in the hilite plane */
 pos = EX_suspend;
 sts = om$send( msg = message super_cmd.wakeup(pos),
           targetid = my_id);
 if (!(1&sts)){msg = MSFAIL; goto wrapup;}

 wrapup:
  if (dyn_info.bscurve->poles)
     om$dealloc(ptr=dyn_info.bscurve->poles);
  if (dyn_info.display_buffers)
     om$dealloc(ptr=dyn_info.display_buffers);

  if (1 & msg)
   return(OM_S_SUCCESS);
  else
   return(OM_E_ABORT);
}

#argsused
IGRint DYrotang_dyn (struct DYrotang_info *dyn_info, struct EX_button *to_point, IGRdouble *mtx,
                     struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers,
                     IGRint *num_buffers, IGRchar *in_dummy1, IGRchar *in_dummy2, IGRchar *in_dummy3,
                     IGRchar **out_dummy1, IGRchar **out_dummy2, IGRchar **out_dummy3)
/*
NAME
        DYrotang_dyn

DESCRIPTION
        This function will perform the dynamics for angle input. It is an argument
        of the dp$dynamics function and will be called every time the mouse is moved.

PARAMETERS
   *dyn_info     (IN) - information structure
   *to_point     (IN) - cursor pos in wld coords
   *mtx          (IN) - rot. matrix of cursor window
   **objects     (IN) - objects in dynamics (not used because of displaying buffers)
   *num_objects  (IN) - number of objects (initialized to zero)
   **buffers     (IN) - buffered elements
   *num_buffers  (IN) - number of buffered elements

RETURN VALUES
        TRUE -- Successful,
        FALSE -- Failed.
NOTES
HISTORY
        08/02/94    Ralf Burkhart
*/


{
 IGRlong        msg = MSSUCC;
 IGRdouble      count, angle;
 IGRdouble      coord_sys[12];
 IGRpoint       point;
 IGRuchar      *info_text_string;  /* shortened name of text string   */
 BSrc           rc;

 info_text_string = (IGRuchar *) dyn_info->display_buffers[1].ele_spec_att.text->text_string;

 point[0] = to_point->x;
 point[1] = to_point->y;
 point[2] = to_point->z;

 dp$inq_window_info( msg = &msg,
                   osnum = to_point->osnum,
            window_objid = to_point->objid,
           world_to_view = rot_wld_vw);

 EFcalc_turn_angle (&msg, point, &dyn_info->plane, rot_wld_vw, dyn_info->start_vec,
                    dyn_info->mirr_toggle, &angle);
  if (msg == MSFAIL) goto wrapup;

 /* fit angle into step size range */
 if (angle < 0.)
    modf(((angle - (.5 * step_size) - BASTOL) /  step_size), & count);
 else
    modf(((angle + (.5 * step_size) + BASTOL) /  step_size), & count);
 angle = (IGRint)count * step_size;

 sprintf(info_text_string,"%9.2f deg", angle * RAD_TO_DEG);

 /* update the local bounded system geometry's origin point to the
 current cursor point so text will be displayed at the correct (current) position */
 dyn_info->display_buffers[1].geometry.lbsys->matrix[3]  = point[0];
 dyn_info->display_buffers[1].geometry.lbsys->matrix[7]  = point[1];
 dyn_info->display_buffers[1].geometry.lbsys->matrix[11] = point[2];

 BSattxsect ( dyn_info->refplane, dyn_info->bscurve, dyn_info->orig_xsect, dyn_info->trace,
              dyn_info->param, dyn_info->bs_case, dyn_info->vec, NULL, dyn_info->srf,
              dyn_info->mirror, angle, dyn_info->display_buffers->geometry.bspcurve,
              coord_sys, &rc);
  if (rc != BSSUCC){msg = MSFAIL; goto wrapup;}

 if (buffers)
 {
     *num_buffers = dyn_info->num_buffs;
     *buffers = dyn_info->display_buffers;
     return (MSSUCC);
 }

wrapup:
 return (msg);
}

void EFcalc_turn_angle (IGRlong *msg, IGRpoint point, struct IGRplane *plane,
                        IGRmatrix view, IGRvector start_vec, IGRint mirr_toggle,
                        IGRdouble *angle)

/*
NAME
        EFcalc_turn_angle 

DESCRIPTION
        This function will calculate the turn angle of cross-section
        dependent of current cursor position.

PARAMETERS
   point     (IN) - cursor position
   plane     (IN) - xy-plane of local coord_sys at trace
   start_vec (IN) - pos x_axis     -"-
   view      (IN) - view matrix
   mirr_toggle (IN) - switch angle orientation
   angle    (OUT) - turn angle

ALGORITHM
   * create boreline at cursor position
   * find intersection of boreline and xy-plane at trace position
   * get turn angle (angle between local x-axis and cursor position) 

HISTORY
        08/02/94    Ralf Burkhart
*/

{
   IGRdouble   loc_angle[3], end_vec[3];
   IGRpoint    boreline[2], int_pt[2];
   IGRint      numint;
   BSrc        rc;

   /* create boreline */
   boreline[0][0] = (point[0] + 1000 * view[8]);        /* copy point to line point1  */
   boreline[0][1] = (point[1] + 1000 * view[9]);
   boreline[0][2] = (point[2] + 1000 * view[10]);

   boreline[1][0] = (point[0] - 1000 * view[8]);        /* copy point to line point2 */
   boreline[1][1] = (point[1] - 1000 * view[9]);
   boreline[1][2] = (point[2] - 1000 * view[10]);

   /* find intersection of boreline and xy-plane */
   BSbdlnplint( boreline, plane->point, plane->normal, &numint, int_pt, &rc );

   if ((rc == BSSUCC) && (numint == 1))
   {
       /* Determine the end vector  */
       end_vec[0] = int_pt[0][0] - plane->point[0];
       end_vec[1] = int_pt[0][1] - plane->point[1];
       end_vec[2] = int_pt[0][2] - plane->point[2];

       /* Get the angle between the start vector and the end vector  */
       MArang2vc (msg, start_vec, end_vec, plane->normal, loc_angle);

       if (*msg & 1)
       {
          *angle = loc_angle[0];
          if (*angle > M_PI) 
             *angle = -(2.0*M_PI - *angle);
          *angle = mirr_toggle * (*angle);
       }
       else
          *msg = MSFAIL;
   }
   else
      *msg = MSFAIL;

   return;
}

end implementation ECprfsksf;

