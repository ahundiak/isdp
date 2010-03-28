class          COtxalel
super_class    COtext
product_name   "$SOURCE"
start_state    terminate
options        "SItc"

specification

instance 
{
IGRint              num_pts;          /* # of origins and matrices */
IGRint              out_flags;
IGRint              text_direction;   /* 1 -> preferred direction,
                                         0 -> opposite direction   */
IGRpoint            side_pt;
variable IGRpoint   text_origin[];
variable IGRmatrix  orient_matrix[];
variable IGRchar    curve_memory[];
struct IGRbsp_curve *curve_ptr;
}

implementation

#include "exsysdep.h"
#include "coimport.h"
#include <alloca.h>
#include "OMprimitives.h"
#include "msmacros.h"
#include "grmessage.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "exmacros.h"
#include "griomacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "igrdef.h"
#include "igr.h"
#include "dpstruct.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "gotextdef.h"
#include "copltxdef.h"

#include "igrtypedef.h"
#include "gr.h"
#include "ex.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "lcdef.h"
#include "cotxmacros.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "griodef.h"
#include "grio.h"
#include "gotext.h"
#include "OMmacros.h"
#include "FS.h"
#include "FSOutl.h"

#define PREALLOC_SIZE  1000



from GRgraphics import GRptproject,
                       GRconstruct,
                       GRlnproject;
from GRgrgrp import GRadd_components;
from GRvg  import GRgetsize,
                  GRgetgeom,
                  GRgeomprops;
from IGEgragad import DPinrot;

from GRfm import GRfm_retdata;


action wakeup
{
    om$send(mode = OM_e_wrt_message,
            msg= message COtext.wakeup(pos),
            targetid = my_id);
 
    me^^COtext.text_symb.Active_just = LEFT_BASE;
}

action get_construct_attr
{
        om$send(mode = OM_e_wrt_message,
            msg= message COtext.get_construct_attr(),
            targetid = my_id);

    me^^COtext.text_symb.Active_just = LEFT_BASE;
}


action save_point1()
{
    IGRlong         temp_msg;
    IGRpoint        point,points[2];
    IGRdouble       t;
    struct IGRline  line;
    struct GRparms  proj_parms;

    me^^COtext.origin_button = me->event2.event.button;

    point[0]=me->event2.event.button.x;
    point[1]=me->event2.event.button.y;
    point[2]=me->event2.event.button.z;

    om$send(mode = OM_e_wrt_object,
            msg = message IGEgragad.DPinrot(&temp_msg, me^^COtext.rot_matrix),
            senderid = my_id,
            targetid = me->event2.event.button.objid,
            targetos = me->event2.event.button.osnum);

    line.point1=points[0];
    line.point2=points[1];

    MAbrlnconstr(&temp_msg,point,me^^COtext.rot_matrix, &line);

    om$send(mode = OM_e_wrt_object,
            msg = message GRgraphics.GRlnproject(&temp_msg,
            &me->event1.located_object[0].module_info.md_env.matrix_type,
            me->event1.located_object[0].module_info.md_env.matrix,
            &line, point, me^^COtext.origin, &t, &proj_parms),
            senderid = my_id,
            targetid=me->event1.located_object[0].located_obj.objid,
            targetos = me->event1.located_object[0].located_obj.osnum);
}


action save_side_point()
{
    me^^COtxalel.side_pt[0] = me->event1.event.button.x;
    me^^COtxalel.side_pt[1] = me->event1.event.button.y;
    me^^COtxalel.side_pt[2] = me->event1.event.button.z;
}

/*                                           */
/*  Action put_pt_on_queue()                 */
/*                                           */
/*  places an event on the software queue    */
/*                                           */

action put_pt_on_queue()
{
   IGRlong  size; 
   IGRlong  msg;


   size = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);

   status = ex$putque(msg = &msg,
                      response = &me->event1.response,
	              byte = &size,
                      buffer = (IGRchar *) &me->event1.event);
}



action construct_text_along()
{
    IGRlong         temp_msg;
    IGRlong         nbytes_in_buffer;
    IGRlong         nbytes_transferred;
    IGRint          index;
    IGRmatrix       *matr[1];  /* pointer to matrix for display */
    struct GRid     buffer;
    struct GRmd_env display_env;
    OM_S_OBJID      grp_objid;
    IGRint          num_objs=1; 
    struct GRobj_env text_object;
    IGRshort        text_length,str_index,esc_seq_size,num_chars;
    IGRchar         *temp_string;
    struct GRdpb_text_symb text_symb;
    struct IGRestx  text_attr;
    IGRdouble       wk_origin[2];
    IGRdouble       base_line;
    IGRshort        prev_font;
    struct just_info just_info;
    struct extents  unjust_extents;
    struct vfont_entry font_info;
    IGRint          points;
    IGRboolean      leave;
    IGRint          index_size;
    struct IGRdisplay cur_disp_attr;
    IGRint          chars_processed;

    

    OM_BLOCK_MOVE(&me->ActiveDisplay,&cur_disp_attr,sizeof(struct IGRdisplay));

    if (me^^COtxalel.num_pts==0) return OM_S_SUCCESS;

    text_symb.Active_font=text_attr.font=me^^COtext.text_symb.Active_font;
    text_symb.Active_fraction_font=me^^COtext.text_symb.Active_fraction_font;
    text_symb.Active_symbol_font=me^^COtext.text_symb.Active_symbol_font;
    text_symb.Active_ascii_font=me^^COtext.text_symb.Active_ascii_font;
    text_symb.Active_just=text_attr.just=me^^COtext.text_symb.Active_just;
    text_symb.Active_width=text_attr.width=me^^COtext.text_symb.Active_width;
    text_symb.Active_height=text_attr.height=me^^COtext.text_symb.Active_height;
    text_symb.Active_charspac=text_attr.char_spac=me^^COtext.text_symb.Active_charspac;
    text_symb.Active_linespac=text_attr.line_spac=me^^COtext.text_symb.Active_linespac;
    text_symb.Active_flags=me^^COtext.text_symb.Active_flags;

    OM_BLOCK_MOVE(&me^^COtext.font_info,&font_info,sizeof(struct vfont_entry));

    wk_origin[0]=wk_origin[1]=base_line=0.0;
    

    temp_string=(char *)alloca(2);

    if (me^^COtxalel.num_pts > 1)
    {
        status = om$construct(classname = "GRgrgrp",
                              osnum = me^^COtext.cur_mod_osnum,
                              p_objid = &grp_objid);
    }

    nbytes_in_buffer = sizeof(me->ModuleInfo);
    gr$get_construct_env(msg = &temp_msg,
                         point = &me^^COtext.origin_button,
                         sizbuf = &nbytes_in_buffer,
                         buffer = &me->ModuleInfo,
                         nret = &nbytes_transferred);
    text_object.mod_env = me->ModuleInfo;

    if (me^^COtext.font_info.flags & SIXTEEN_BIT) text_length = 2;
    else text_length=1;

    if (me^^COtxalel.out_flags & GRTX_REV_SIDE)
        text_symb.Active_just = CENTER_CAP;
    else
        text_symb.Active_just = CENTER_BASE;

    esc_seq_size=0;
    str_index=0;
    chars_processed=0;
    str_index=0;
    num_chars=0;
    leave=FALSE;
    points=0;

    for (;;)
    {

    /* find and process escape sequences */

    for (;;){
    GRfind_esc_char(&temp_msg,&(me^^COtext.text_string[str_index]),
            (IGRshort)me^^COtext.text_length - str_index,font_info.flags,
            &num_chars);

    if (num_chars) /* there are displayable characters */
    {
       if (font_info.flags & SIXTEEN_BIT) index_size = 2;
       else index_size = 1;
       num_chars*=index_size;
       chars_processed += num_chars;
       str_index+=num_chars;
       if (points >= me^^COtxalel.num_pts) leave=TRUE;
       break;
    }
    else  /* handle escape sequence */
    {
        /* initializing the structures just_info and unjust extents
         * to take care of UMRs reported by Purify; the values
         * returned are relative to the beginning of the escape
         * sequence that is processed, i.e. the returned values
         * are NOT relative to the beginning of the text string
         */

        just_info.num_lines = 1;
        just_info.just_esc_pos = 0;
        just_info.cur_line_left = just_info.cur_line_right = 0.0;
        unjust_extents.right = unjust_extents.left = 0.0;
        unjust_extents.bottom = -(text_attr.height / 
                                  (font_info.bodysize - font_info.descent)) *
                                   font_info.descent;
        unjust_extents.base = 0.0;
        unjust_extents.top = text_attr.height - unjust_extents.bottom;
        unjust_extents.cap = text_attr.height;

	GResc_handler(&temp_msg,me^^COtext.text_string,str_index+1,&text_attr,
		      wk_origin, &base_line,&font_info,&prev_font,
		      &cur_disp_attr,&just_info,
		      &unjust_extents,&num_chars);

	text_symb.Active_font=text_attr.font;
	text_symb.Active_width=text_attr.width;
	text_symb.Active_height=text_attr.height;
	text_symb.Active_linespac=text_attr.line_spac;
	text_symb.Active_charspac=text_attr.char_spac;
	str_index+=num_chars+1;

    }
    }
    for (index = 0; index < num_chars/index_size; index++) 
    {

        text_length=index_size;

        temp_string[0]=me^^COtext.text_string[str_index-num_chars+index*index_size];
        if (font_info.flags & SIXTEEN_BIT) temp_string[1]=me^^COtext.text_string[str_index-num_chars+index*index_size+1];
        
        co$place_text(msg = &temp_msg,
                      text_string = temp_string,
                      text_length = &text_length,
                      origin = me^^COtxalel.text_origin[points],
                      TextSymb = &text_symb,
                      ActiveDisplay = &cur_disp_attr,
                      lbs_matrix = me^^COtxalel.orient_matrix[points],
                      buffer = &buffer);

        if (++points==me^^COtxalel.num_pts) leave=TRUE;

        if (! (temp_msg & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

        if (me^^COtxalel.num_pts > 1)
        {
            text_object.obj_id.objid = buffer.objid;
            text_object.obj_id.osnum = buffer.osnum;

            status = om$send(mode = OM_e_wrt_object,
                             msg = message GRgrgrp.GRadd_components(&temp_msg,
                                   &me->ModuleInfo, &num_objs, &text_object,
                                   NULL, NULL),
                             senderid = my_id,
                             targetid = grp_objid,
                             targetos = me^^COtext.cur_mod_osnum);
        }

        /*
         * display object
         */

        nbytes_in_buffer = sizeof(display_env);
        gr$get_display_env(msg = &temp_msg,
                           sizbuf = &nbytes_in_buffer,
                           buffer = &display_env,
                           nret = &nbytes_transferred);

        matr[0] = (IGRmatrix *) display_env.md_env.matrix;

        status = dp$display(msg = &temp_msg,
                            osnum = me^^COtext.cur_mod_osnum,
                            mode = GRbd,
                            oids = &buffer,
                            num_elem = 1,
                            mtx_type = &display_env.md_env.matrix_type,
                            matrix = matr);

        if (leave) break;

        if (!(status & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }
        if (leave) break;
        } /* for (;;) */
    if (leave) break;
    }
}

action get_curve_geom()
{
    IGRlong  geom_size, msg;

    status = om$send(msg = message GRvg.GRgetsize(&msg,
                        &me->event1.located_object[0].module_info.md_env.matrix_type,
                        me->event1.located_object[0].module_info.md_env.matrix,
                        &geom_size),
                     targetid = me->event1.located_object[0].located_obj.objid,
                     targetos = me->event1.located_object[0].located_obj.osnum);

    if (!(status & msg & 1))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    om$vla_set_dimension(varray = me^^COtxalel.curve_memory,
                         size = geom_size);

    if (! me^^COtxalel.curve_memory)
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    me^^COtxalel.curve_ptr = (struct IGRbsp_curve *) me^^COtxalel.curve_memory;

    om$send(msg = message GRvg.GRgetgeom(&msg,
                 &me->event1.located_object[0].module_info.md_env.matrix_type,
                 me->event1.located_object[0].module_info.md_env.matrix,
                 (IGRchar *) me^^COtxalel.curve_ptr),
            targetid = me->event1.located_object[0].located_obj.objid,
            targetos = me->event1.located_object[0].located_obj.osnum);
}

action get_text_along(int preferred_dir)
{
    IGRlong  temp_msg;
    IGRshort text_length;


    if (preferred_dir == 2)
        me^^COtxalel.text_direction ^= 0x1; /* reverse current direction */
    else
        me^^COtxalel.text_direction = preferred_dir;

    om$vla_set_dimension(varray = me^^COtxalel.text_origin,
                         size = me^^COtext.text_length);

    if (! me^^COtxalel.text_origin)
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    om$vla_set_dimension(varray = me^^COtxalel.orient_matrix,
                         size = me^^COtext.text_length);

    if (! me^^COtxalel.orient_matrix)
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    text_length = me^^COtext.text_length;


    GRtext_along_curve(&temp_msg, me^^COtxalel.curve_ptr, me^^COtext.origin,
                       me^^COtxalel.side_pt, me^^COtxalel.text_direction,
                       me^^COtext.rot_matrix, me^^COtext.text_string,
                       &me^^COtext.font_info,
                       me^^COtext.text_symb.Active_width,
                       me^^COtext.text_symb.Active_height,
                       me^^COtext.text_symb.Active_charspac,
                       me^^COtext.text_symb.Active_linespac,
                       &text_length, &me^^COtxalel.num_pts,
                       me^^COtxalel.text_origin, me^^COtxalel.orient_matrix,
                       &me^^COtxalel.out_flags);
}

action erase_highlight()
{
    IGRlong  msg;

    dp$erase_hilite(msg = &msg);
}

action highlight_text_along()
{
    struct DPele_header  text_buffer;
    struct IGRlbsys      lbsys;
    OutlCharInfo         charinfo;
    IGRdouble            just_value, char_size_factor;
    IGRlong              temp_msg;
    IGRint               index;
    CharId               charid;
    struct IGRestx       text_attr;
    IGRdouble            wk_origin[2];
    IGRdouble            base_line;
    IGRshort             prev_font;
    struct just_info     just_info;
    struct extents       unjust_extents;
    struct vfont_entry   font_info;
    IGRint               points;
    IGRboolean           leave;
    IGRint               index_size;
    struct IGRdisplay    cur_disp_attr;
    IGRint               chars_processed;
    IGRshort             text_length,str_index,esc_seq_size,num_chars;

    if (me^^COtxalel.num_pts==0) return OM_S_SUCCESS;

    text_attr.font=me^^COtext.text_symb.Active_font;
    text_attr.just=me^^COtext.text_symb.Active_just;
    text_attr.width=me^^COtext.text_symb.Active_width;
    text_attr.height=me^^COtext.text_symb.Active_height;
    text_attr.char_spac=me^^COtext.text_symb.Active_charspac;
    text_attr.line_spac=me^^COtext.text_symb.Active_linespac;

    OM_BLOCK_MOVE(&me->ActiveDisplay,&cur_disp_attr,sizeof(struct IGRdisplay));

    OM_BLOCK_MOVE(&me^^COtext.font_info,&font_info,sizeof(struct vfont_entry));
  
    wk_origin[0]=wk_origin[1]=base_line=0.0;

    text_buffer.ele_spec_att.text=&me^^COtext.tx_attr;

    text_buffer.ele_spec_att.text->flags = 1;

    if (font_info.flags & SIXTEEN_BIT) text_attr.text_length = 2;
    else text_attr.text_length = 1;

    if (me^^COtxalel.out_flags & GRTX_REV_SIDE)
        me^^COtext.text_attr.just = CENTER_CAP;
    else
        me^^COtext.text_attr.just = CENTER_BASE;

    me^^COtext.tx_attr.just_moves[0] = ESC;
    me^^COtext.tx_attr.just_moves[1] = 'j';
    me^^COtext.tx_attr.just_moves[10] = ESC;
    me^^COtext.tx_attr.just_moves[11] = 'h';

    if ((me^^COtext.text_attr.just % 5) == 3)  /* cap vertical just. */
        just_value = 1.0;
    else                   /* base vertical justification */
        just_value = 0.0;

    OM_BLOCK_MOVE(&just_value, &me^^COtext.tx_attr.just_moves[2], 8);

    char_size_factor = me^^COtext.text_attr.width / 
              (me^^COtext.font_info.bodysize - me^^COtext.font_info.descent);

    esc_seq_size=0;
    str_index=0;
    chars_processed=0;
    str_index=0;
    num_chars=0;
    leave=FALSE;
    points=0;

    for (;;)
    {
    /* find and process escape sequences */
    for (;;){
    GRfind_esc_char(&temp_msg,&(me^^COtext.text_string[str_index]),
            (IGRshort)me^^COtext.text_length - str_index,font_info.flags,
            &num_chars);

    if (num_chars) /* there are displayable characters */
    {
       if (font_info.flags & SIXTEEN_BIT) index_size = 2;
       else index_size = 1;
       num_chars*=index_size;
       chars_processed += num_chars;
       str_index+=num_chars;
       if (points >= me^^COtxalel.num_pts) leave=TRUE;
       break;
    }
    else  /* handle escape sequence */
    {
    /* initializing the structures just_info and unjust extents
     * to take care of UMRs reported by Purify; the values
     * returned are relative to the beginning of the escape
     * sequence that is processed, i.e. the returned values
     * are NOT relative to the beginning of the text string
     */

    just_info.num_lines = 1;
    just_info.just_esc_pos = 0;
    just_info.cur_line_left = just_info.cur_line_right = 0.0;
    unjust_extents.right = unjust_extents.left = 0.0;
    unjust_extents.bottom = -(text_attr.height / 
                              (font_info.bodysize - font_info.descent)) *
                               font_info.descent;
    unjust_extents.base = 0.0;
    unjust_extents.top = text_attr.height - unjust_extents.bottom;
    unjust_extents.cap = text_attr.height;

    GResc_handler(&temp_msg,me^^COtext.text_string,str_index+1,&text_attr,
                  wk_origin, &base_line,&font_info,&prev_font,
                  &cur_disp_attr,&just_info,
                  &unjust_extents,&num_chars);

    if (font_info.flags & SIXTEEN_BIT) text_attr.text_length = 2;
    else text_attr.text_length = 1;

    str_index+=num_chars+1;

    }
    }

    dp$build_dis_buffer(buffer = &text_buffer,
                        type = IGRLB,
                        display_att = &cur_disp_attr,
                        ele_spec_att = &me^^COtext.tx_attr,
                        geometry = &lbsys); 
    

    for (index = 0; index < num_chars/index_size; index++)
    {


        text_length=index_size;



        text_buffer.ele_spec_att.text->text_string =
                       (IGRchar *) &me^^COtext.text_string[str_index-num_chars+index*index_size];


        OM_BLOCK_MOVE(me^^COtxalel.orient_matrix[points], lbsys.matrix, 128);

        lbsys.matrix[3] = me^^COtxalel.text_origin[points][0];
        lbsys.matrix[7] = me^^COtxalel.text_origin[points][1];
        lbsys.matrix[11] = me^^COtxalel.text_origin[points][2];


    if (font_info.flags & SIXTEEN_BIT)
#ifdef LITTLE_ENDIAN
   swab(&me^^COtext.text_string[str_index-num_chars+index*index_size],&charid,2);
#else
   memcpy((char *)&charid,
          (char *)&me^^COtext.text_string[str_index-num_chars+index*index_size],
          2);
#endif
    else charid = (CharId) me^^COtext.text_string[str_index-num_chars+index*index_size];

        if (FSGetOutlCharInfo(font_info.fontid, charid, &charinfo) ==
                                                              FS_NO_ERROR)
            just_value = -(((char_size_factor * charinfo.xMax) / 2) /
                            me^^COtext.text_attr.width);
        else
            just_value = -0.5;

        OM_BLOCK_MOVE(&just_value, &text_buffer.ele_spec_att.text->just_moves[12], 8);

    text_buffer.ele_spec_att.text->estx= &text_attr;

        status = dp$display(msg = &temp_msg,
                            mode = GRhd,
                            buffer = &text_buffer);

        if (!(status & 1))
        {
            me->ret = OM_E_ABORT;
            goto quit;
        }

        if (++points==me^^COtxalel.num_pts) leave=TRUE;

        if (leave) break;
        } /* for (;;) */
    if (leave) break;
    }
}

