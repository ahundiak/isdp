class              COSetWinShp
super_class        CEO_GSLOCATE
command_string     GRC_M_SetWinShp,0,GRStWnSh
product_name       "$GRNUC"
form               "GRSetWinShap",0,0,0,0
start_state        sel_window

specification
#include "wl.h"
#include "FI.h"

instance
{
        /* information about the graphic gadget constructed */
        struct GRid window;
        struct GRid gragad_ids[100];
        OM_S_OBJID  window_id;
        IGRchar     gragad_name[200];
        WLuint32    lwin_no;
        IGRint      dep_extents[6];
        IGRint      width;
        IGRint      height;

        WLuint16    lscreen_no;
        IGRint      screen_width;
        IGRint      screen_height;
        IGRint      max_width;
        IGRint      max_height;

        IGRdouble   aspect_ratio;
        IGRint      std_shp_row;
        IGRchar     standard_shape[200];
        IGRchar     std_name[25][25];
        IGRdouble   aspect[25];
        IGRint      switch1;
        Form        form_ptr;
        IGRint      num_gragad_ids;
        IGRint      previous_check;
        IGRint      previous_check_list;
        }


state_table

#include "grmessage.h"

#define SAVE_AND_EXECUTE    4000
#define SAVE_AND_EXIT       4001
#define IGNORE_AND_EXIT     4002
#define RETURN_ERROR        4003
#define RETURN_SUCCESS      4004
#define STATUS_FORM         ((int) 0x7fffffff)

implementation

#define CHECK_RETURN_CODES 1

#define SAVE_AND_EXECUTE    4000
#define SAVE_AND_EXIT       4001
#define IGNORE_AND_EXIT     4002
#define RETURN_ERROR        4003
#define RETURN_SUCCESS      4004

#define GR_SWS_CHECK        1
#define GR_SWS_CANCEL       4
#define GR_SWS_CVT          5
#define GR_SWS_WINDOW       15
#define GR_SWS_WIDTH        19
#define GR_SWS_HEIGHT       20
#define GR_SWS_ASPECT       21
#define GR_SWS_MSG_AREA     10
#define GR_SWS_STD_SHAPE    22
#define GR_SWS_WIDTH_CHECK  16
#define GR_SWS_HEIGHT_CHECK 17
#define GR_SWS_ASPECT_CHECK 18
#define MIN_WIDTH           32
#define MIN_HEIGHT          10

#include <stdio.h>
#include <string.h>

#include "dpgraphics.h"
#include "OMerrordef.h"
#include "msdef.h"

#include "igetypedef.h"
#include "igewindow.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igr.h"

#include "fontdef.h"
#include "font.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "godef.h"
#include "dpcomacros.h"
#include "dpcodef.h"

#include "msdef.h"
#include "msmacros.h"

#include "griodef.h"
#include "griomacros.h"

#include "exdef.h"
#include "ex.h"
#include "comiscmac.h"

#include "FI.h"

#include "exmacros.h"

#include "grmessage.h"

/* prototype files */
#include "DPgetggid.h"
#include "DPsetinq.h"
#include "DPcodpbi.h"

#if defined( X11 )
#define MESSAGE_STRIP_HEIGHT 55
#endif

from IGEgadget import change_gadget_size;


state *                        /* default transitions for all states */
   on EX_RJT_MOVEON state .
   on EX_RESTART    state sel_window
   on EX_BACK_UP    state -



state sel_window
   message_key GRC_M_SetWinShp
   prompt_key  GR_P_SelWin
   filter      get_event

      on EX_DATA or EX_STRING
         do get_selected_window( sts, 1 )
            on SUCCESS
               do initialize_instance
               do set_form_defaults
               state form_display
      on ELSE
               state .
         state .

      on EX_BACK_UP
         state .



state form_display
   message_key GRC_M_SetWinShp
   prompt      ""
   display_form 0
   filter   get_event

      on EX_FORM_FINISHED
         do which_state
           on RETURN_CODE = IGNORE_AND_EXIT
               state terminate
           on RETURN_CODE = SAVE_AND_EXIT
               do erase_form 0
               do set_data
               do which_state
                    on RETURN_CODE = RETURN_ERROR
                      do print_error
                      state  sel_window
                    on RETURN_CODE = RETURN_SUCCESS
                      state terminate 
               state terminate
           on ELSE
               state terminate
         state .



action print_error
{
ex$message(msgnumb = GR_E_InsMemResize, field= ERROR_FIELD);
sleep(3);
ex$message(in_buff = "",field = ERROR_FIELD);
}

action set_data
{
        IGRlong msg;
        IGRdouble xdmin, xdmax, ydmin, ydmax;
        IGRint xmin, xmax, ymin, ymax;
        IGRdouble cx, cy;
        int ss;
        IGRint left_border, top_border, right_border, bottom_border;
        struct WLbounds bounds, area_bounds;

        cx = 1.0 * (me->dep_extents[0] + me->dep_extents[2])/2;
        cy = 1.0 * (me->dep_extents[1] + me->dep_extents[3])/2;
        xmin = (IGRint) (cx - ( 1.0 * (me->width -1)  /2));
        ymin = (IGRint) (cy - ( 1.0 * (me->height-1) /2)); 
        xmax = (IGRint) (cx + ( 1.0 * (me->width -1)  /2));
        ymax = (IGRint) (cy + ( 1.0 * (me->height-1) /2)); 
 
        xdmin = (IGRdouble) xmin;
        xdmax = (IGRdouble) xmax;
        ydmin = (IGRdouble) ymin;
        ydmax = (IGRdouble) ymax;

        /* get the sizes of the borders (decorations) of the window */
        WLget_window_bounds( me->lwin_no, &bounds, &area_bounds );
        left_border = area_bounds.x -bounds.x;
        top_border = area_bounds.y - bounds.y;
        right_border = (bounds.x + bounds.width) - (area_bounds.x + area_bounds.width);
        bottom_border = (bounds.y + bounds.height) - (area_bounds.y + area_bounds.height);

        if ( (xdmin - left_border) < 0 )
        {
            xdmax = xdmax + (left_border - xdmin);
            xdmin = left_border;
        }

        if ( (ydmin - top_border) < MESSAGE_STRIP_HEIGHT )
        {
            ydmax = ydmax + ((MESSAGE_STRIP_HEIGHT + top_border) - ydmin); 
            ydmin = top_border + MESSAGE_STRIP_HEIGHT;
        }

        if ( (xdmax + right_border) > me->screen_width )
        {
            xdmin = xdmin - (xdmax + right_border - me->screen_width);
            xdmax = me->screen_width - right_border;
        }

        if ( (ydmax + bottom_border) > me->screen_height )
        {
            ydmin = ydmin - (ydmax + bottom_border - me->screen_height);
            ydmax = me->screen_height - bottom_border ;
        }

        ss = om$send( msg = message IGEgadget.change_gadget_size(&msg,
                                                                IGE_DEPENDENT,
                                                                xdmin, ydmin,
                                                                xdmax, ydmax),
                      targetid = me->window_id,
                      targetos  = me->gragad_ids[0].osnum);
        if (!ss)
           me->switch1 = RETURN_ERROR;
        else
           me->switch1 = RETURN_SUCCESS;
}


action initialize_instance
{
        IGRushort          fixed_flags;
        IGRchar            text[100];

        struct var_list  gg_inq_list[4];
        struct win_var_list  win_inq_list[4];
        IGRlong              msg;
        IGRlong              ret_bytes;
        IGRint               sts;
        IGRlong              which_error;
        OM_S_CHANSELECT      chansel;
        OM_S_OBJECT_LINKAGE  list[10];
        OMuint               count;

        sts = om$make_chanselect(channame = "IGEgadget.to_parent",
                                 p_chanselect = &chansel);

        sts = om$get_channel_objects(osnum = me->gragad_ids[0].osnum,
                                     objid = me->gragad_ids[0].objid,
                                     p_chanselect = &chansel,
                                     list = list,
                                     size = 10,
                                     count = &count);

        me->window_id = list[0].S_objid;

        win_inq_list[0].var = HW_WIN_NO;
        win_inq_list[0].var_ptr = (IGRchar *)&me->lwin_no;
        win_inq_list[0].num_bytes = sizeof(WLuint32);
        win_inq_list[0].bytes_returned = &ret_bytes;

        win_inq_list[1].var = WINDOW_DEP;
        win_inq_list[1].var_ptr = (IGRchar *)me->dep_extents;
        win_inq_list[1].num_bytes = sizeof(IGRint)*6;
        win_inq_list[1].bytes_returned = &ret_bytes;

        win_inq_list[2].var = END_PARAM;

        status = ige$inq_set_window( msg          = &msg,
                                     osnum        = list[0].osnum,
                                     window_objid = list[0].S_objid,
                                     which_error  = &which_error,
                                     var_list     = win_inq_list );

        gg_inq_list[0].var = GRAGAD_NAME;
        gg_inq_list[0].var_ptr =  me->gragad_name;
        gg_inq_list[0].num_bytes = sizeof(me->gragad_name);
        gg_inq_list[0].bytes_returned = &ret_bytes;

        gg_inq_list[1].var = END_PARAM;

        status = dp$inq_set_gragad( msg          = &msg,
                                    osnum        = me->gragad_ids[0].osnum,
                                    gragad_objid = me->gragad_ids[0].objid,
                                    which_error  = &which_error,
                                    var_list     = gg_inq_list );
                                
        WLget_window_screen( me->lwin_no, &me->lscreen_no );
        WLget_screen_size( me->lscreen_no, &me->screen_width, &me->screen_height );

        me->max_width = me->screen_width;
        me->max_height = me->screen_height;

        dp$codpb_get_sws_flags(sws_flags = &fixed_flags);
        
        fixed_flags = fixed_flags & SWS_FIXED_MASK;
        if (fixed_flags & SWS_WIDTH_FIXED) 
        {
                me->previous_check = GR_SWS_WIDTH;
                me->previous_check_list = GR_SWS_WIDTH_CHECK;
        }

        if (fixed_flags & SWS_HEIGHT_FIXED) 
        {
                me->previous_check = GR_SWS_HEIGHT;
                me->previous_check_list = GR_SWS_HEIGHT_CHECK;
        }

        if (fixed_flags & SWS_ASPECT_FIXED) 
        {
                me->previous_check = GR_SWS_ASPECT;
                me->previous_check_list = GR_SWS_ASPECT_CHECK;
        }
        
        me->std_shp_row = 22;
        ex$message(buff = text, msgnumb = GR_I_NonStand);
        strcpy(me->standard_shape,text);

        ex$message(buff = me->std_name[0], msgnumb = GR_I_ALand);
        me->aspect[0]= 11.0/8.5;
        ex$message(buff = me->std_name[1], msgnumb = GR_I_APort);
        me->aspect[1]= 1/me->aspect[0];
        ex$message(buff = me->std_name[2], msgnumb = GR_I_BLand);
        me->aspect[2]= 17.0/11.0;
        ex$message(buff = me->std_name[3], msgnumb = GR_I_BPort);
        me->aspect[3]= 1/me->aspect[2];
        ex$message(buff = me->std_name[4], msgnumb = GR_I_CLand);
        me->aspect[4]= 22.0/17.0;
        ex$message(buff = me->std_name[5], msgnumb = GR_I_CPort);
        me->aspect[5]= 1/me->aspect[4];
        ex$message(buff = me->std_name[6], msgnumb = GR_I_DLand);
        me->aspect[6]= 34.0/22.0;
        ex$message(buff = me->std_name[7], msgnumb = GR_I_DPort);
        me->aspect[7]= 1/me->aspect[6];
        ex$message(buff = me->std_name[8], msgnumb = GR_I_ELand);
        me->aspect[8]= 44.0/34.0;
        ex$message(buff = me->std_name[9], msgnumb = GR_I_EPort);
        me->aspect[9]= 1/me->aspect[8];
        ex$message(buff = me->std_name[10], msgnumb = GR_I_A0Land);
        me->aspect[10]= 1189.0/841.0;
        ex$message(buff = me->std_name[11], msgnumb = GR_I_A0Port);
        me->aspect[11]= 1/me->aspect[10];
        ex$message(buff = me->std_name[12], msgnumb = GR_I_A1Land);
        me->aspect[12]= 841.0/594.0;
        ex$message(buff = me->std_name[13], msgnumb = GR_I_A1Port);
        me->aspect[13]= 1/me->aspect[12];
        ex$message(buff = me->std_name[14], msgnumb = GR_I_A2Land);
        me->aspect[14]= 594.0/420.0;
        ex$message(buff = me->std_name[15], msgnumb = GR_I_A2Port);
        me->aspect[15]= 1/me->aspect[14];
        ex$message(buff = me->std_name[16], msgnumb = GR_I_A3Land);
        me->aspect[16]= 420.0/297.0;
        ex$message(buff = me->std_name[17], msgnumb = GR_I_A3Port);
        me->aspect[17]= 1/me->aspect[16];
        ex$message(buff = me->std_name[18], msgnumb = GR_I_A4Land);
        me->aspect[18]= 297.0/210.0;
        ex$message(buff = me->std_name[19], msgnumb = GR_I_A4Port);
        me->aspect[19]= 1/me->aspect[18];
        ex$message(buff = me->std_name[20], msgnumb = GR_I_ScrLand);
        me->aspect[20]= 1.0 * me->screen_width/me->screen_height;
        ex$message(buff = me->std_name[21], msgnumb = GR_I_ScrPort);
        me->aspect[21]= 1/me->aspect[20];
        ex$message(buff = me->std_name[22], msgnumb = GR_I_NonStand);
        me->aspect[22]= 0;
}


action which_state
{
        *sts = me->switch1;
}


action set_form_defaults
{
        Form            form_ptr;
        IGRchar         text[100];
        IGRint          found, index,i;


        form_ptr = me->forms[0].form_ptr;

        FIg_set_text( form_ptr, GR_SWS_WINDOW, me->gragad_name);

        /* set default number of pixels to the size of the window */
        me->width =( me->dep_extents[2] - me->dep_extents[0] + 1);
        if ( me->width > me->max_width )
           me->width = me->max_width;

        me->height = (me->dep_extents[3] - me->dep_extents[1] + 1) ;
        if ( me->height > me->max_height )
           me->height = me->max_height;

        sprintf(text,"%d",me->width);
        FIg_set_text( form_ptr, GR_SWS_WIDTH, text);

        sprintf(text,"%d",me->height);
        FIg_set_text( form_ptr, GR_SWS_HEIGHT, text);

        me->aspect_ratio = 1.0 *  me->width/me->height;
        sprintf(text,"%f",me->aspect_ratio);
        FIg_set_text( form_ptr, GR_SWS_ASPECT, text);
        FIg_set_state_off(form_ptr,GR_SWS_WIDTH_CHECK);
        FIg_set_state_on(form_ptr,me->previous_check_list);
        FIfld_set_mode(form_ptr, me->previous_check, 0, FI_REVIEW); 
        if (me->previous_check == GR_SWS_ASPECT)
                FIg_disable(form_ptr, GR_SWS_STD_SHAPE);

        FIfld_set_list_num_rows(form_ptr,GR_SWS_STD_SHAPE,0,23);
        ex$message(buff = text, msgnumb = GR_I_ALand);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,0,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_APort);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,1,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_BLand);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,2,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_BPort);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,3,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_CLand);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,4,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_CPort);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,5,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_DLand);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,6,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_DPort);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,7,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_ELand);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,8,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_EPort);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,9,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A0Land);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,10,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A0Port);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,11,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A1Land);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,12,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A1Port);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,13,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A2Land);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,14,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A2Port);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,15,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A3Land);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,16,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A3Port);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,17,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A4Land);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,18,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_A4Port);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,19,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_ScrLand);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,20,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_ScrPort);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,21,0,text,0);
        ex$message(buff = text, msgnumb = GR_I_NonStand);
        FIfld_set_list_text(form_ptr,GR_SWS_STD_SHAPE,22,0,text,0);
        FIfld_set_list_mode(form_ptr, GR_SWS_STD_SHAPE, 0, FI_SINGLE_SELECT);
        found =0;
        index = 0;
        for (i=0;i< 22;i++)
        {
           /*Approximating floating point comparison */
           if ( (me->aspect[i] < (1.0 *(me->width + 1)/(me->height-1))) && 
                (me->aspect[i] > (1.0 *(me->width - 1)/(me->height+1))) )
           {
               found =1;
               index = i;
           }
        }

        if (!found)
           index = 22;

        FIfld_set_list_select(form_ptr, GR_SWS_STD_SHAPE, index, 0, TRUE);
        FIg_set_text(form_ptr, GR_SWS_STD_SHAPE, me->std_name[index]);
}


action form_notification 
{
        Form       form_ptr;
        char       text[100], msgbuf[100], temp_std_shp[200];
        int        found, i, sel_flag;
        int        temp_width, temp_height, fixed_flags=0, error_displayed;
        IGRdouble  temp_aspect_ratio, t_aspect_ratio;

        error_displayed = 0;
        temp_aspect_ratio = 0;
        form_ptr=me->forms[0].form_ptr; 
        switch( gadget_label )
           {        
           case GR_SWS_WIDTH_CHECK:
                FIfld_set_mode(form_ptr,me->previous_check,0,FI_INSERT);
                FIfld_set_mode(form_ptr,GR_SWS_WIDTH,0,FI_REVIEW);
                FIg_display(form_ptr,me->previous_check);
                FIg_display(form_ptr,GR_SWS_WIDTH);
                FIg_set_state_off(form_ptr,me->previous_check_list);
                me->previous_check = GR_SWS_WIDTH;
                me->previous_check_list = GR_SWS_WIDTH_CHECK;
                FIg_enable(form_ptr, GR_SWS_STD_SHAPE);
                break;

           case GR_SWS_HEIGHT_CHECK:
                FIfld_set_mode(form_ptr,me->previous_check,0,FI_INSERT);
                FIfld_set_mode(form_ptr,GR_SWS_HEIGHT,0,FI_REVIEW);
                FIg_display(form_ptr,me->previous_check);
                FIg_display(form_ptr,GR_SWS_HEIGHT);
                FIg_set_state_off(form_ptr,me->previous_check_list);
                me->previous_check = GR_SWS_HEIGHT;
                me->previous_check_list = GR_SWS_HEIGHT_CHECK;
                FIg_enable(form_ptr, GR_SWS_STD_SHAPE);
                break;

           case GR_SWS_ASPECT_CHECK:
                FIfld_set_mode(form_ptr,me->previous_check,0,FI_INSERT);
                FIfld_set_mode(form_ptr,GR_SWS_ASPECT,0,FI_REVIEW);
                FIg_display(form_ptr,me->previous_check);
                FIg_display(form_ptr,GR_SWS_ASPECT);
                FIg_set_state_off(form_ptr,me->previous_check_list);
                me->previous_check_list = GR_SWS_ASPECT_CHECK;
                me->previous_check = GR_SWS_ASPECT;
                FIg_disable(form_ptr, GR_SWS_STD_SHAPE);
                break;

           case GR_SWS_WIDTH:
                FIg_get_text(form_ptr,GR_SWS_WIDTH,text);
                temp_width = me->width;
                sscanf(text,"%d",&me->width);
                if (me->width > me->max_width)
                {
                   ex$message(msgnumb=GR_E_Big_Resize, buff = msgbuf);
                   FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                   sleep(3);
                   error_displayed =1;
                   FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                   me->width = me->max_width;
                }

                if (me->width < MIN_WIDTH)
                {
                   ex$message(msgnumb=GR_E_Small_Resize, buff = msgbuf);
                   FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                   sleep(3);
                   error_displayed =1;
                   FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                   me->width = MIN_WIDTH;
                }

                switch(me->previous_check)
                {
                    case GR_SWS_HEIGHT:
                          me->aspect_ratio = 1.0 * me->width /me->height;
                          sprintf(text,"%f",me->aspect_ratio);
                          FIg_set_text(form_ptr,GR_SWS_ASPECT,text);
                          FIfld_set_list_select(form_ptr, GR_SWS_STD_SHAPE,
                                                22,0,TRUE);
                          ex$message(buff = text, msgnumb = GR_I_NonStand);
                          FIg_set_text(form_ptr, GR_SWS_STD_SHAPE, text);
                          strcpy(me->standard_shape,text);
                          me->std_shp_row = 22;
                          break;
                    case GR_SWS_ASPECT:
                          temp_height = me->height;
                          me->height =  me->width / me->aspect_ratio + 0.5; 
                          if (me->height > me->max_height)
                          {
                              if (!error_displayed)
                              {
                                 ex$message(msgnumb=GR_E_Big_Resize,buff=msgbuf);
                                 FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                                 sleep(3);
                                 FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                                 error_displayed =0;
                              }
                              me->height = me->max_height;
                              me->width = me->height * me->aspect_ratio + 0.5;
                          }
                          if (me->height < MIN_HEIGHT)
                          {
                              if (!error_displayed)
                              {
                                 ex$message(msgnumb=GR_E_Small_Resize,buff=msgbuf);
                                 FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                                 sleep(3);
                                 FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                                 error_displayed =0;
                              }
                              me->height = MIN_HEIGHT;
                              me->width = me->height * me->aspect_ratio + 0.5;
                          }

                              
                          sprintf(text,"%d",me->height);
                          FIg_set_text(form_ptr,GR_SWS_HEIGHT,text);
                          break;
                    default:
                          break;
                  }
                  sprintf(text,"%d",me->width);
                  FIg_set_text(form_ptr,GR_SWS_WIDTH,text);
                break;

           case GR_SWS_HEIGHT:
                FIg_get_text(form_ptr,GR_SWS_HEIGHT, text);
                temp_height = me->height;
                sscanf(text,"%d",&me->height);
                if (me->height > me->max_height)
                {
                   ex$message(msgnumb=GR_E_Big_Resize, buff = msgbuf);
                   FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                   sleep(3);
                   error_displayed = 1;
                   FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                   me->height = me->max_height;
                }

                if (me->height < MIN_HEIGHT)
                {
                   ex$message(msgnumb=GR_E_Small_Resize, buff = msgbuf);
                   FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                   sleep(3);
                   error_displayed = 1;
                   FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                   me->height = MIN_HEIGHT;
                }

                switch(me->previous_check)
                {
                    case GR_SWS_WIDTH:
                          me->aspect_ratio =  1.0 * me->width /me->height;
                          sprintf(text,"%f",me->aspect_ratio);
                          FIg_set_text(form_ptr,GR_SWS_ASPECT,text);
                          FIfld_set_list_select(form_ptr, GR_SWS_STD_SHAPE,
                                                22,0,TRUE);
                          ex$message(buff = text, msgnumb = GR_I_NonStand);
                          FIg_set_text(form_ptr, GR_SWS_STD_SHAPE, text);
                          strcpy(me->standard_shape,text);
                          me->std_shp_row = 22;
                          break;

                    case GR_SWS_ASPECT:
                          temp_width = me->width;
                          me->width = me->height * me->aspect_ratio + 0.5;
                          if (me->width > me->max_width)
                          {
                             if (!error_displayed)
                             {
                                ex$message(msgnumb=GR_E_Big_Resize, buff=msgbuf);
                                FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                                sleep(3);
                                FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                                error_displayed = 0;
                             }
                             me->width = me->max_width;
                             me->height = me->width/me->aspect_ratio + 0.5;
                          }
                          if (me->width < MIN_WIDTH)
                          {
                             if (!error_displayed)
                             {
                                ex$message(msgnumb=GR_E_Small_Resize, buff=msgbuf);
                                FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                                sleep(3);
                                FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                                error_displayed = 0;
                             }
                             me->width = MIN_WIDTH;
                             me->height = me->width/me->aspect_ratio + 0.5;
                          }

                          sprintf(text,"%d",me->width);
                          FIg_set_text(form_ptr,GR_SWS_WIDTH,text);
                          break;
                    default:
                          break;
                 }

                sprintf(text,"%d",me->height);
                FIg_set_text(form_ptr,GR_SWS_HEIGHT,text);
                break;

           case GR_SWS_ASPECT:
                t_aspect_ratio = me->aspect_ratio;
                FIg_get_text(form_ptr,GR_SWS_ASPECT,text);
                sscanf(text,"%lf",&me->aspect_ratio);
                switch(me->previous_check)
                {
                   case GR_SWS_WIDTH:
                          temp_height = me->height;
                          me->height = me->width / me->aspect_ratio + 0.5;
                          if (me->height > me->max_height)
                          {
                             ex$message(msgnumb=GR_E_SizeTooLarge,buff = msgbuf);
                             FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                             sleep(3);
                             FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                             me->aspect_ratio = t_aspect_ratio;
                             sprintf(text,"%lf",me->aspect_ratio);
                             FIg_set_text(form_ptr,GR_SWS_ASPECT,text);
                             me->height= temp_height;
                          }
                          sprintf(text,"%d",me->height);
                          FIg_set_text(form_ptr,GR_SWS_HEIGHT,text);
                          break;

                   case GR_SWS_HEIGHT: 
                          temp_width = me->width;
                          me->width = me->height * me->aspect_ratio + 0.5;
                          if (me->width > me->max_width)
                          {
                                ex$message(msgnumb=GR_E_SizeTooLarge,buff= msgbuf);
                             FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                             sleep(3);
                             FIg_set_text(form_ptr,GR_SWS_MSG_AREA,"");
                             me->aspect_ratio = t_aspect_ratio;
                             sprintf(text,"%lf",me->aspect_ratio);
                             FIg_set_text(form_ptr,GR_SWS_ASPECT,text);
                             me->width= temp_width;
                          }

                          sprintf(text,"%d",me->width);
                          FIg_set_text(form_ptr,GR_SWS_WIDTH,text);
                          break;

                   default:
                          break;
                 }

                 FIfld_set_list_select(form_ptr, GR_SWS_STD_SHAPE,22,0,TRUE);
                 ex$message(buff = text, msgnumb = GR_I_NonStand);
                 FIg_set_text(form_ptr, GR_SWS_STD_SHAPE, text);
                 strcpy(me->standard_shape,text);
                 me->std_shp_row = 22;
                 break;
 
           case GR_SWS_STD_SHAPE:
                strcpy(temp_std_shp, me->standard_shape);
                FIg_get_text(form_ptr,GR_SWS_STD_SHAPE,text);
                found = 0;
                for(i=0;i<22;i++)
                {
                   if(strcmp(me->std_name[i],text)==0)
                   {
                     found=1;
                     temp_aspect_ratio = me->aspect[i];
                   }
                }
                if (found)
                {
                    switch(me->previous_check)
                    {
                        case GR_SWS_WIDTH:
                             t_aspect_ratio = me->aspect_ratio;
                             temp_height = me->height;
                             me->aspect_ratio = temp_aspect_ratio;
                             me->height = me->width/me->aspect_ratio + 0.5;
                             if (me->height > me->max_height)
                             {
                                  ex$message(msgnumb=GR_E_SizeTooLarge,
                                             buff = msgbuf);
                                  FIg_set_text(form_ptr, GR_SWS_MSG_AREA,
                                                                   msgbuf);
                                  sleep(3);
                                  FIg_set_text(form_ptr, GR_SWS_MSG_AREA, "");
                                  me->aspect_ratio = t_aspect_ratio;
                                  me->height = temp_height;
                                  strcpy(text, temp_std_shp);
                                  FIg_set_text(form_ptr,GR_SWS_STD_SHAPE,text);
                                  FIfld_set_list_select(form_ptr, 
                                                        GR_SWS_STD_SHAPE,
                                                        me->std_shp_row,0,TRUE);
                             }
                            
                             strcpy(me->standard_shape,text);
                             sprintf(text,"%f",me->aspect_ratio);
                             FIg_set_text(form_ptr,GR_SWS_ASPECT,text);
                             sprintf(text,"%d",me->height);
                             FIg_set_text(form_ptr,GR_SWS_HEIGHT,text);
                             break;

                        case GR_SWS_HEIGHT:
                             t_aspect_ratio = me->aspect_ratio;
                             temp_width = me->width;
                             me->aspect_ratio = temp_aspect_ratio;
                             me->width = me->aspect_ratio * me->height + 0.5;
                             if (me->width > me->max_width)
                             {
                                  ex$message(msgnumb=GR_E_SizeTooLarge,
                                             buff = msgbuf);
                                  FIg_set_text(form_ptr,GR_SWS_MSG_AREA,msgbuf);
                                  sleep(3);
                                  FIg_set_text(form_ptr, GR_SWS_MSG_AREA, "");

                                  me->aspect_ratio = t_aspect_ratio;
                                  me->width = temp_width;
                                  strcpy(text, temp_std_shp);

                                  FIg_set_text(form_ptr,GR_SWS_STD_SHAPE, text);
                                  FIfld_set_list_select(form_ptr, 
                                                        GR_SWS_STD_SHAPE,
                                                        me->std_shp_row,0,TRUE);
                             }

                             strcpy(me->standard_shape,text);
                             sprintf(text,"%f",me->aspect_ratio);
                             FIg_set_text(form_ptr,GR_SWS_ASPECT,text);
                             sprintf(text,"%d", me->width);
                             FIg_set_text(form_ptr,GR_SWS_WIDTH,text);
                             break;
     
                        default:
                             break;
                    }
                }
                else
                    strcpy(me->standard_shape,text);
                for (i=0;i<22;i++)
                {
                    FIfld_get_list_select(form_ptr, GR_SWS_STD_SHAPE, i,0,&sel_flag);
                    if (sel_flag==TRUE)
                         me->std_shp_row = i;
                }
                break;

           case GR_SWS_CANCEL:
                me->switch1 = IGNORE_AND_EXIT;
                _put_response(resp = EX_FORM_FINISHED);
                FIf_erase(form_ptr);
                break;

           case GR_SWS_CHECK:
                if (me->previous_check==GR_SWS_WIDTH)
                   fixed_flags = SWS_WIDTH_FIXED & SWS_FIXED_MASK;
                if (me->previous_check==GR_SWS_HEIGHT)
                   fixed_flags = SWS_HEIGHT_FIXED & SWS_FIXED_MASK;
                if (me->previous_check==GR_SWS_ASPECT)
                   fixed_flags = SWS_ASPECT_FIXED & SWS_FIXED_MASK;
                dp$codpb_set_sws_flags(sws_flags = fixed_flags);
                
                FIg_set_state_off(form_ptr , GR_SWS_CHECK);
                me->switch1 = SAVE_AND_EXIT;
                _put_response(resp = EX_FORM_FINISHED);
                FIf_erase(form_ptr);
                  break; 

           default:
                break;

           } /* end_switch */

        FIg_set_text( form_ptr, GR_SWS_MSG_AREA," ");

}

action get_selected_window( IGRint *sts; IGRint single_window ) 
{
        IGRlong         msg;
        IGRint          total_found;
        IGRint          num_ids;
        IGRint          keep_count;
        IGRint          ii;
        IGRint          message_no = 0;
        struct GRid     window_ids[40];
        IGRlong         ret_bytes;
        IGRlong         which_error;
        struct var_list var_list[2];
        IGRchar         gragad_name[GRNAME_SIZE];


        *sts = OM_S_SUCCESS;

        if ( me->event1.response == EX_DATA )
           {
           /* user hit a data button in a window */
           num_ids = 1;
           window_ids[0].objid = me->event1.event.button.objid;
           window_ids[0].osnum = me->event1.event.button.osnum;
           }
        else
           {
           /* user keyed in a window name */
           if ( strlen( me->event1.event.keyin ) == 0 )
               {
               /* Invalid window */
               *sts = OM_W_WARNING;
               message_no = GR_E_WinNotFound;
               }
           else
               {
               num_ids = 0;

               /* get the window id(s) from the string */
               dp$get_gragad_id( msg         = &msg,
                                 name        = me->event1.event.keyin,
                                 array_size  = 40,
                                 total_num   = &total_found,
                                 numberofids = &num_ids,
                                 found_GRids = window_ids,
                                 type_gragad = ALL_TYPES );

              if ( num_ids == 0 )
                 {
                 /* Invalid window */
                 *sts = OM_W_WARNING;
                 message_no = GR_E_WinNotFound;
                 }

              }

           }  /* end: else */

        if ( *sts == OM_S_SUCCESS )
           {
           /* keep all selected windows */
           me->num_gragad_ids = num_ids;
           for ( ii = 0; ii < num_ids; ii++ )
              me->gragad_ids[ii] = window_ids[ii];

           /* throw out the default view if it was selected */
           var_list[0].var            = GRAGAD_NAME;
           var_list[0].var_ptr        = gragad_name;
           var_list[0].num_bytes      = sizeof( gragad_name );
           var_list[0].bytes_returned = &ret_bytes;
           var_list[1].var            = END_PARAM;

           for ( keep_count = ii = 0; ii < me->num_gragad_ids; ii++ )
              {
              dp$inq_set_gragad( msg          = &msg,
                                 inq0_set1    = 0,
                                 osnum        = me->gragad_ids[ii].osnum,
                                 gragad_objid = me->gragad_ids[ii].objid,
                                 which_error  = &which_error,
                                 var_list     = var_list );

              if ( strcmp( gragad_name, ".GRdefaultview" ) )
                 me->gragad_ids[keep_count++] = me->gragad_ids[ii];
              }

           me->num_gragad_ids = keep_count;

           if ( me->num_gragad_ids == 0 )
              {
              *sts = OM_W_WARNING;
              message_no = GR_E_InvWin;
              }
           else if ( (single_window) && (me->num_gragad_ids > 1) )
              {
              *sts = OM_W_WARNING;
              message_no = GR_E_WinAmbig;
              }

           }  /* end: if ( *sts == OM_S_SUCCESS ) */

        if ( *sts == OM_W_WARNING )
           {
           ex$message( msgnumb = message_no );
           sleep( 3 );
           ex$message( in_buff = "", field = ERROR_FIELD );
           }
}

