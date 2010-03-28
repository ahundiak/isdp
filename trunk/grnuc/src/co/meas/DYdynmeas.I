class implementation Root;

#define DP_DONT_ERASE 0x00000008
#define THETA1   0.174
#define THETA2   -0.174

#include "stdio.h"
#include "string.h"
#include "gotextdef.h"
#include "math.h"
#include "coimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gotext.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "griomacros.h"
#include "var.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "comeasure.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "exmacros.h"

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "dpgraphics.h"


#include "bsvalues.h"
#include "codynmeas.h"

#include "wl.h"

extern          MATH_rotate_vector();


struct dyn_info 
{
  struct disp_val_info disp_info;
};


static struct display_info
{
  IGRshort    num_entries;
  IGRshort    *offset_array;
  IGRchar     **string_array;
  IGRint      font_descr;
}  text_list;

/*-------------------------------------------------------------------
 *
 *
 *-------------------------------------------------------------------
*/

#argsused
IGRint DYrasdisp(dynm_data,pnt2,mtx,objects,num_objects,buffers,num_buffers,
                       inflag1,inflag2,inflag3,outflag4,outflag5,outflag6)
  struct dyn_info     *dynm_data;
  struct EX_button    *pnt2;
  IGRdouble           *mtx;
  struct GRid         **objects;
  IGRint              *num_objects;
  struct DPele_header **buffers;
  IGRint              *num_buffers;
  IGRchar             *inflag1;
  IGRchar             *inflag2;
  IGRchar             *inflag3;
  IGRint              *outflag4;
  IGRchar             **outflag5;
  IGRchar             **outflag6;
{
  IGRshort         i,temp_value;
  IGRshort         num_alias = 3;
  IGRshort         field_size = sizeof(IGRchar) * 80;
  IGRchar          *str_ptr[3];
  IGRchar          view_fields[3][80];
  IGRlong          msg;
  IGRint           status=OM_S_SUCCESS;
  IGRdouble        delta[3];
  IGRint           sts=MSSUCC;
  struct GRIOreadout_spec  readout_spec;

  extern IGRlong   DYdisp_triad1();
  extern IGRlong   DYdisp_triad2();
  extern IGRlong   DYdisp_line();
  extern IGRlong   DYdisp_hdr();

  int              xdit,ydit;
  int              in_win, key_buttons;
  int              wl_sts;

  IGRlong          long_rc;
  WLcolorref       color_ref;

  *outflag4 |= DP_DONT_ERASE;

  WLmouse_position( pnt2->window, &xdit, &ydit, &in_win, &key_buttons );

  dp$erase_hilite(msg = &msg);

  WLset_dynamics_drawing_mode ( pnt2->window, WL_DYN_DRAW_MODE );
  WLset_drawing_mode ( pnt2->window, (WL_BASE_NOOP | WL_HILITE_DRAW) );


  if(dynm_data->disp_info.mode_flag != NO_DRAW) 
  {
    status = (IGRint) DYdisp_line(&long_rc,dynm_data,pnt2,mtx);
  }/* NO DRAW check */

  WLhide_cursor( pnt2->window, 1 );

  if (!dynm_data->disp_info.disp_fld_flag) 
  {
    WLflush( pnt2->window );
    return(TRUE);
  }

  if (dynm_data->disp_info.disp_dist_flag)
  {
    temp_value = 1;
  }
  else
  {
    temp_value = 3;
  }
/* Just making sure, the mode is set properly for TR119421269 */  
  WLset_drawing_mode ( pnt2->window, (WL_BASE_NOOP | WL_HILITE_DRAW) );
  for( i=0; i<temp_value; i++) 
  {
    WLdraw_text( pnt2->window, 
		 xdit+text_list.offset_array[i*2],
                 ydit+text_list.offset_array[i*2+1],
                 text_list.string_array[i],
                 strlen( text_list.string_array[i] ) );
  }

  if (dynm_data->disp_info.supr_act_flag)
  {
    temp_value = 3;
  }
  else 
  {
    temp_value = text_list.num_entries;
    DYdisp_hdr(&long_rc,pnt2,xdit,ydit,2);
  }

  for( i=3; i<temp_value; i++) 
  {
    WLdraw_text( pnt2->window,
		 xdit+text_list.offset_array[i*2],
                 ydit+text_list.offset_array[i*2+1],
                 text_list.string_array[i],
                 strlen( text_list.string_array[i] ) );
  }

  temp_value = (dynm_data->disp_info.supr_dz_flag) ? 2 : 3;
     
  status = (IGRint) DYdisp_triad1(&long_rc,pnt2,xdit,ydit);
                   
  if (!(dynm_data->disp_info.supr_dz_flag))
  {
    status = (IGRint) DYdisp_triad2(&long_rc,pnt2,xdit,ydit);
  }

  status = (IGRint) DYdisp_hdr(&long_rc,pnt2,xdit,ydit,1);
  if(dynm_data->disp_info.change_flag) 
  {
    status = COmeasure_view_values(&msg,
                                    delta,
                                    pnt2->objid,
                                    pnt2->osnum,
                                    dynm_data->disp_info.events);

    for( i = 0; i < 3; i++)
    {
      str_ptr[i] = &view_fields[i][0];
    }

    status = co$update_readout_spec(msg = &sts,
                                  unit_type = dynm_data->disp_info.units,
                                  osnum = dynm_data->disp_info.ModuleGrid.osnum,
                                  update_flag = FALSE,
                                  readout_spec = &readout_spec);
    readout_spec.justification = GRIO_LEFT_JUSTIFY;
 

    status = co$cvt_imp_to_alias(msg = &sts,
                                 unit_type =dynm_data->disp_info.units,
                                 working_units = delta,
                                 num_alias = &num_alias,
                                 field_size = &field_size,
                                 readout_spec = &readout_spec,
                                 inverse_scale_flag = GRIO_NO_SCALE,
                                 osnum = dynm_data->disp_info.ModuleGrid.osnum,
                                 num_conversions = 3,
                                 cvt_list = str_ptr);

    for( i=6; i<temp_value+6; i++) 
    {
      WLdraw_text( pnt2->window,
		   xdit+text_list.offset_array[i*2],
                   ydit+text_list.offset_array[i*2+1],
                   str_ptr[i-6],
                   strlen( str_ptr[i-6] ) );
    }
  }
  else 
  {
    for( i=6; i<temp_value+6; i++) 
    {
      WLdraw_text( pnt2->window, 
		   xdit+text_list.offset_array[i*2],
                   ydit+text_list.offset_array[i*2+1],
                   text_list.string_array[i],
                   strlen( text_list.string_array[i] ) );
    }
  }

  WLflush( pnt2->window );
  *num_buffers = 0;

  return(TRUE);
}


/*-----------------------------------------------------------------------
 *
 *
 *-----------------------------------------------------------------------
*/ 


IGRlong DYrbrasdisp( num_entries, offset_array,string_array,disp_va_inf)
  IGRshort              *num_entries;
  IGRshort              *offset_array;
  IGRchar               **string_array;
  struct disp_val_info  *disp_va_inf;
 
{

  struct dyn_info              dyn_data;
  
  IGRlong                      msg;          /* return message               */
  IGRboolean                   inq_flag=1;
  IGRboolean                   set_flag=0;
  IGRboolean                   dyn_flag;
  IGRboolean                   turn_on=1;
  IGRint                       status=OM_S_SUCCESS;
  IGRlong               NumberOfBytes;
  IGRlong               BytesReceived;
  IGRint                   sts = MSSUCC;

#if 0
#ifdef X11
  Font                         font_info;
#endif
#define TEXT_FONT "-adobe-helvetica-medium-r-normal--18-180-75-75-p-98-iso8859-1"
#ifndef X11
  Load_symbol_file("/usr/ip32/resrc/rfont/drake.10",
                    &text_list.font_descr);
#else
  font_info = XLoadFont ( EXdisplay,TEXT_FONT );
  XSetFont ( EXdisplay,EXgc[EXenter_screen],font_info);
#endif
#endif

  dyn_data.disp_info = *disp_va_inf;

  text_list.num_entries  = *num_entries;

  text_list.offset_array = offset_array;

  if(*num_entries > 1)
  {
    text_list.string_array = string_array;
  }
  else if(*num_entries == 1)
  {
    text_list.string_array = (IGRchar **)&string_array;
  }
   
  NumberOfBytes = sizeof( struct IGRdisplay );

  status = gr$get_active_display( msg = &sts,
                                  sizbuf = &NumberOfBytes,
                                  buffer = &dyn_data.disp_info.active_display,
                                  nret = &BytesReceived );

          
   
  DPdynflags(&msg,&inq_flag,&dyn_flag,NULL);
  if(!dyn_flag)
  {
    DPdynflags(&msg,&set_flag,&turn_on,NULL);
  }

  dp$dynamics(dyn_fun =  DYrasdisp,
              information = &dyn_data);
  
  if(!dyn_flag)
  {
    DPdynflags(&msg,&set_flag,&dyn_flag,NULL);
  }
  
  return(TRUE);
}

IGRlong DYdisp_triad1(msg,pnt2,xdit,ydit)
IGRlong *msg;
struct EX_button *pnt2;
IGRint  xdit;
IGRint  ydit;
{
  struct WLpoint   pts[3];

  *msg = MSSUCC;

  pts[0].x = xdit+75;
  pts[0].y = ydit+2;
  pts[1].x = xdit+80;
  pts[1].y = ydit;
  pts[2].x = xdit+75;
  pts[2].y = ydit-2;
  WLdraw_2D_line_string( pnt2->window, 3, pts );

  pts[0].x = xdit+80;
  pts[0].y = ydit;
  pts[1].x = xdit+50;
  pts[1].y = ydit;
  pts[2].x = xdit+50;
  pts[2].y = ydit-30;
  WLdraw_2D_line_string( pnt2->window, 3, pts );

  pts[0].x = xdit+48;
  pts[0].y = ydit-25;
  pts[1].x = xdit+50;
  pts[1].y = ydit-30;
  pts[2].x = xdit+52;
  pts[2].y = ydit-25;
  WLdraw_2D_line_string( pnt2->window, 3, pts );

  return(TRUE);
}

IGRlong DYdisp_triad2(msg,pnt2,xdit,ydit)
IGRlong *msg;
struct EX_button    *pnt2;
IGRint  xdit;
IGRint  ydit;
{
  struct WLpoint  pts[3];

  *msg = MSSUCC;
  pts[0].x = xdit+50;
  pts[0].y = ydit;
  pts[1].x = xdit+35;
  pts[1].y = ydit+16;
  pts[2].x = xdit+37;
  pts[2].y = ydit+11;
  WLdraw_2D_line_string( pnt2->window, 3, pts );

  pts[0].x = xdit+35;
  pts[0].y = ydit+16;
  pts[1].x = xdit+40;
  pts[1].y = ydit+14;
  WLdraw_2D_line_string( pnt2->window, 2, pts );

  return(TRUE);
}


IGRlong DYdisp_line(msg,dynm_data,pnt2,mtx)
IGRlong   *msg;
struct dyn_info   *dynm_data;
struct EX_button  *pnt2;
IGRdouble         *mtx;
{
  struct DPele_header  ele_header;
  struct IGRpolyline   line;
  IGRdouble            points[15];
  IGRvector            vector;
  IGRdouble            rot_vec1[3];
  struct GRvar_list    list_var[2];
  IGRdouble            vvscale,scale;
  IGRlong              long_rc;
  IGRint               status=OM_S_SUCCESS;
  IGRint               sts=MSSUCC;
  IGRint               i;

  *msg = MSSUCC;


  points[0]= dynm_data->disp_info.events[0].event.button.x;
  points[1]= dynm_data->disp_info.events[0].event.button.y;
  points[2]= dynm_data->disp_info.events[0].event.button.z;

  if(dynm_data->disp_info.disp_fld_flag) 
  {
    points[3]= points[9]  =dynm_data->disp_info.events[1].event.button.x;
    points[4]= points[10] =dynm_data->disp_info.events[1].event.button.y;
    points[5]= points[11] =dynm_data->disp_info.events[1].event.button.z;
  }
  else 
  {
    points[3] = points[9]  = pnt2->x;
    points[4] = points[10] = pnt2->y;
    points[5] = points[11] = pnt2->z;
  }

  
  list_var[0].var = VVOL_VIEWPORT_SCALE;
  list_var[0].var_ptr = (char *)&vvscale;
  list_var[0].num_bytes = sizeof (double);
  list_var[0].bytes_returned = (IGRlong *)&long_rc;

  list_var[1].var = END_PARAM;
  list_var[1].var_ptr = NULL;
  list_var[1].num_bytes = 0;
  list_var[1].bytes_returned = NULL;

  sts= dp$inq_set_gragad (msg = &long_rc,
                          osnum = pnt2->osnum,
                          gragad_objid = pnt2->objid,
                          which_error = &long_rc,
                          var_list = list_var);
  scale = 10.0/vvscale;
  BSmkvec(&long_rc,vector,points,&points[3]);
  BSnorvec(&long_rc,vector);

  MATH_rotate_vector(&long_rc,vector,THETA1,mtx,rot_vec1);
    
  for (i=0;i<3;i++) 
  {
    points[i+6] = points[i+3] - rot_vec1[i]*scale;
  }
  MATH_rotate_vector(&long_rc,vector,THETA2,mtx,rot_vec1);
  for (i=0;i<3;i++) 
  {
    points[i+12] = points[i+3] - rot_vec1[i]*scale;
  }
    
  line.num_points = 5;
  line.points = points;

  dp$build_dis_buffer( buffer      = &ele_header,
                       type        =  IGRPY,
                       display_att = &dynm_data->disp_info.active_display,
                       geometry    = (struct IGRpolyline *) &line  );

  status = dp$display(msg = &sts,
                      mode = GRhd,
                      objid = pnt2->objid,
                      osnum = dynm_data->disp_info.ModuleGrid.osnum,
                      buffer = &ele_header);

  return(TRUE);
}

IGRlong DYdisp_hdr(msg,pnt2,xdit,ydit,val)
IGRlong *msg;
struct EX_button    *pnt2;
IGRint  xdit;
IGRint  ydit;
int     val;
{
  IGRint index;

  *msg = MSSUCC;

  index = (val == 1) ? 9 : 10;

  WLdraw_text( pnt2->window,
	       xdit+text_list.offset_array[index*2],
               ydit+text_list.offset_array[index*2+1],
               text_list.string_array[index],
               strlen( text_list.string_array[index] ) );

  return(TRUE);
}

end implementation Root;
