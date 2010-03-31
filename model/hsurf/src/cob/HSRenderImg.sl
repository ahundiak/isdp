/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $‚
$Locker:  $
*/

class              HSRenderImg
super_class        HSwindow
command_string     HSM_M_RenderImage,0,HSRnIm
product_name       "$MODEL"
status_display     "HSRenderImage","-1","-1"
start_state        validate_virtual_screen

specification
#include "FI.h"

instance
	{
	/* information about the graphic gadget constructed */
	struct GRid window;
	struct GRid rendering_gragad;
	IGRchar     gragad_name[200];

	/* information about the hardware window that will */
	/* be used to display the rendering image          */
	IGRint      max_width;
	IGRint      max_height;
	IGRint      dest_x_dits;
	IGRint      dest_y_dits;
	IGRint      dest_wno;
	IGRint      dest_vs;

	/* form instance data */
	IGRint      width;
	IGRint      height;
	IGRint      curr_win_width;
	IGRint      curr_win_height;
	IGRdouble   media_width;
        IGRdouble   media_height;
        IGRint      anti_alias;
	IGRint	    image_size;
	IGRdouble   devic_resol;
	IGRint      image_resol;
	IGRchar     media_size[200];
        IGRchar     image_name[200];
	IGRdouble   fact;
        IGRchar     text_devic_resol[200];

	/* control instance data */
	IGRint      switch1;
	IGRboolean  write_file;
	Form        form_ptr;


  
        /*data for restoring old values */
        IGRint      image_size_row;
        IGRint      image_resol_row;
	}




state_table

#include "hsmsg.h"

#define SAVE_AND_EXECUTE    4000
#define SAVE_AND_EXIT       4001
#define IGNORE_AND_EXIT     4002
#define STATUS_FORM         ((int) 0x7fffffff)

implementation

#define CHECK_RETURN_CODES 1

#define SAVE_AND_EXECUTE    4000
#define SAVE_AND_EXIT       4001
#define IGNORE_AND_EXIT     4002

#define HS_RI_CHECK             1
#define HS_RI_EXECUTE           2
#define HS_RI_CANCEL            4
#define HS_RI_CVRT_TO_WINDOW    5


#define HS_RI_WINDOW_NAME       13
#define HS_RI_IMAGE_FILE_NAME   15
#define HS_RI_IMAGE_SIZE        17
#define HS_RI_DEVICE_RESOL      19
#define HS_RI_MEDIA_SIZE        21
#define HS_RI_WIDTH             25
#define HS_RI_HEIGHT            26
#define HS_RI_IMAGE_RESOL       29
#define HS_RI_MSG_AREA          10
#define HS_RI_ANTI_ALIAS        30
#define HS_RI_GROUP              27

#define MAX_SACLE               4
#define MIN_PIXEL_VALUE         10

#define HS_RI_FULL_RESOL        1
#define HS_RI_MEDIUM_RESOL      2
#define HS_RI_LOW_RESOL         3



#define HS_RI_ERROR             0
#define HS_RI_OK                1


#define MAX_DIM                 5461
/*16 Meg */
#define MAX_PROD                16777216
#define MIN_WIDTH               10
#define MIN_HEIGHT              10
#define MAX(x,y)                (x > y) ? (x) : (y)
#define MIN(x,y)                (x < y) ? (x) : (y)

/*#include "hsurf_import.h"*/
#include <stdlib.h>
#include "igrtypedef.h"
#include <math.h>
#include "tools.h"

#include "stdio.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <ctype.h>

#include "OMminimum.h"
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

#include "msdef.h"
#include "ms.h"
#include "msmacros.h"

#include "griodef.h"
#include "griomacros.h"

#include "exdef.h"
#include "ex.h"
#include "comiscmac.h"

#include "fidef.h"
#include "fi.h"
#include "FI.h"

#include "exmacros.h"

#include "hsurferrpriv.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsmsg.h"
#include "hswinmacros.h"
#include "hsmacros.h"
#include "dpgraphics.h"

#include "HSpr_co_imp.h"

/*-------------------------
 *  for fucntions
 *     HRdelete_rendering_window
 *     HRinit_rendering_window
 *     HRrender_image
 */
 
#include "gr.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "HSpr_render.h"

/*---------------------------
 *  for functions
 *     HFI_confirm_box
 *     HSnot_enough_planes_to_render
 */
 
#include <EG.h>
#include "igrdp.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

%safe
#include "HSpr_co_func.h"
%endsafe

/*-------------------------------*/

from IGEgadget import add_gadget, activate;
from IGEgragad import gragad_cons;

 
/*-------------------------FUNCTIONS--------------------------------------*/


static void HSriprocess_image_size(choice,form_ptr)

Form form_ptr;
int choice;

{
    FIg_erase(form_ptr,HS_RI_GROUP);
    if (choice == HS_RENDER_SIZE_USER)
     {
        FIfld_set_list_num_rows(form_ptr,HS_RI_DEVICE_RESOL,0,1);
        FIfld_set_list_text(form_ptr,HS_RI_DEVICE_RESOL,0,0,"200 DPI",0);

        FIfld_set_list_num_rows(form_ptr,HS_RI_MEDIA_SIZE,0,1);
        FIfld_set_list_text(form_ptr,HS_RI_MEDIA_SIZE,0,0,"8.5x11",0);
        FIg_set_text(form_ptr, HS_RI_DEVICE_RESOL, "200 DPI");
        FIg_set_text(form_ptr, HS_RI_MEDIA_SIZE, "8.5x11");
        FIfld_set_mode(form_ptr, HS_RI_DEVICE_RESOL, 0, FI_INSERT);
        FIfld_set_mode(form_ptr, HS_RI_MEDIA_SIZE, 0, FI_INSERT);
      }
    else
      {
	FIfld_set_list_num_rows(form_ptr,HS_RI_DEVICE_RESOL,0,3);
        FIfld_set_list_text(form_ptr,HS_RI_DEVICE_RESOL,0,0,"200 DPI",0);
        FIfld_set_list_text(form_ptr,HS_RI_DEVICE_RESOL,1,0,"300 DPI",0);
        FIfld_set_list_text(form_ptr,HS_RI_DEVICE_RESOL,2,0,"400 DPI",0);

        FIfld_set_list_num_rows(form_ptr,HS_RI_MEDIA_SIZE,0,5);
        FIfld_set_list_text(form_ptr,HS_RI_MEDIA_SIZE,0,0,"A",0);
        FIfld_set_list_text(form_ptr,HS_RI_MEDIA_SIZE,1,0,"B",0);
        FIfld_set_list_text(form_ptr,HS_RI_MEDIA_SIZE,2,0,"A3",0);
        FIfld_set_list_text(form_ptr,HS_RI_MEDIA_SIZE,3,0,"A4",0);
        FIfld_set_list_text(form_ptr,HS_RI_MEDIA_SIZE,4,0,"11x14",0);
        FIg_set_text(form_ptr, HS_RI_DEVICE_RESOL, "200 DPI");
        FIg_set_text(form_ptr, HS_RI_MEDIA_SIZE, "A");
        FIfld_set_mode(form_ptr, HS_RI_DEVICE_RESOL, 0, FI_REVIEW);
        FIfld_set_mode(form_ptr, HS_RI_MEDIA_SIZE, 0, FI_REVIEW);
       }
       FIfld_set_list_mode(form_ptr, HS_RI_DEVICE_RESOL, 0, FI_SINGLE_SELECT);
       FIfld_set_list_mode(form_ptr, HS_RI_MEDIA_SIZE, 0, FI_SINGLE_SELECT);
       FIg_display(form_ptr,HS_RI_GROUP);
}



/*---------------------------------------------------------------------*/


/*----------HSprocess_dimension---------------------------------------*/

static void HSprocess_dimension(dimension,width,height)
IGRchar *dimension;
IGRdouble *width;
IGRdouble *height;

  {
    int i,count,dim_specified[2];
    char temp2[200],temp1[200],output_alias[20],str1[45],str2[45];
    IGRdouble result[2], result_inch[2];
    IGRlong   msg;
    GRobjid  mod_id;
    GRspacenum   mod_os;

       ex$get_cur_mod(id = &mod_id, osnum = &mod_os);
       dim_specified[0]=0;
       dim_specified[1]=0;
       strcpy (temp1,dimension);
       *width = 0.0;
       *height = 0.0; 
       count = strlen(temp1);
       for(i=0;i<count;i++)
        {
          if(temp1[i]=='x')
            {
               /*CALL CO$CVT functions here */
               temp1[i]='\0';
               strcpy(temp2,&temp1[i+1]);
            }
        }
        for (i=0;i<strlen(temp1);i++)
        {
           if (isalpha(temp1[i]))
           {
               dim_specified[0]=1;
               break;
           }
        }
        for (i=0;i<strlen(temp2);i++)
        {
           if (isalpha(temp2[i]))
           {
               dim_specified[1]=1;
               break;
           }
        }
            
               
       
        co$expreval(msg = &msg,
        	   scale_flag = GRIO_NO_SCALE,
                   expression = temp1,
                   unit_type = GRIO_DISTANCE,
                   result = &result[0]);

       co$expreval(msg = &msg,
		   scale_flag = GRIO_NO_SCALE,
		   expression = temp2,
		   unit_type = GRIO_DISTANCE,
		   result = &result[1]);
       if (!dim_specified[0])
           convert_working_to_alias(result[0],str1,TRUE);
       else
           strcpy(str1,temp1);
       if (!dim_specified[1])
           convert_working_to_alias(result[1],str2,TRUE);
       else
           strcpy(str2,temp2);
       sprintf(dimension,"%sx%s",str1,str2);
  
       strcpy(output_alias,"inches");              
       co$cvt_value_to_value(msg =  &msg,
			  osnum = mod_os,
			  unit_type = GRIO_DISTANCE ,
			  alias_to_cvt_to =output_alias,
			  num_vals = 2,
			  values_in = result,
			  values_out = result_inch);



       *width = result_inch[0];
       *height = result_inch[1];
    
        
   }



/*---------------------------------------------------------------------------*/



/*-----------------HScheck_dim_validity---------------------------------------*/



static void HScheck_dim_validity(form_ptr,width,height,status,image_resol,fact)
Form form_ptr;
int *width;
int *height;
int *status;
int *image_resol;
double *fact;
    
 {
   int product,i,sel_flag;
   char  text[10],msgbuf[200];
     *status = HS_RI_OK; 
     product =  (*width) * (*height);
     if ((*width < MIN_PIXEL_VALUE) || (*height <MIN_PIXEL_VALUE))
        *status = HS_RI_ERROR;
     else
     {
    
       if ((*width) > MAX_DIM || (*height) > MAX_DIM || product > MAX_PROD) 
       {
          if (*image_resol == HS_RI_LOW_RESOL)
              *status = HS_RI_ERROR;
          else
          { 
            if (*image_resol == HS_RI_MEDIUM_RESOL)
            {
              if ((*width / 2) >  MAX_DIM || (*height / 2) > MAX_DIM || (product / 4) > MAX_PROD)       
                   *status = HS_RI_ERROR;
              else
               {
	         ex$message(msgnumb = HS_W_ImgResize, buff = msgbuf);
                 FIg_set_text(form_ptr, HS_RI_MSG_AREA, msgbuf);
                 sleep(3);
                 FIg_set_text(form_ptr, HS_RI_MSG_AREA, "");
                 *width = *width /2;
                 *height = *height /2;  
                 *status = HS_RI_OK;
                 *image_resol = HS_RI_LOW_RESOL;
	         *fact = 0.25;
                 for (i=0;i<3;i++)
                 {
                      FIfld_get_list_text(form_ptr,HS_RI_IMAGE_RESOL,
                                          i,0,10,text,&sel_flag);
                      if (strcmp(text,"Low")==0)
                      {
                        FIfld_set_list_select(form_ptr,HS_RI_IMAGE_RESOL,i,0,1);
	                FIg_set_text(form_ptr,HS_RI_IMAGE_RESOL,text);
                      }
                 }
                    
               }
            }
            else
            {
              if ((*width / 4) >  MAX_DIM || (*height / 4) > MAX_DIM || (product /16) > MAX_PROD)
                 *status = HS_RI_ERROR;
              else
              {
                if ((*width / 2) >  MAX_DIM || (*height / 2) > MAX_DIM || (product /4) > MAX_PROD)
                {
	           ex$message(msgnumb = HS_W_ImgResize, buff = msgbuf);
                   FIg_set_text(form_ptr, HS_RI_MSG_AREA, msgbuf);
                   sleep(3);
                   FIg_set_text(form_ptr, HS_RI_MSG_AREA, "");
                   *width = *width /4;
                   *height = *height /4;
                   *status = HS_RI_OK; 
                   *image_resol = HS_RI_LOW_RESOL;
                   *fact = 0.25;
                   for (i=0;i<3;i++)
			 {
			      FIfld_get_list_text(form_ptr,HS_RI_IMAGE_RESOL,
                                                  i,0,10,text,&sel_flag);
			      if (strcmp(text,"Low")==0)
                              {
				FIfld_set_list_select(form_ptr,
                                                      HS_RI_IMAGE_RESOL,i,0,1);
	                        FIg_set_text(form_ptr,HS_RI_IMAGE_RESOL,text);
                              }
			 }
                }
               else
                {
	           ex$message(msgnumb = HS_W_ImgResize, buff = msgbuf);
                   FIg_set_text(form_ptr, HS_RI_MSG_AREA, msgbuf);
                   sleep(3);
                   FIg_set_text(form_ptr, HS_RI_MSG_AREA, "");
                   *width = *width /2;
                   *height = *height /2;
                   *status = HS_RI_OK;
                   *image_resol = HS_RI_MEDIUM_RESOL; 
	           *fact = 0.5;
			 for (i=0;i<3;i++)
			 {
			      FIfld_get_list_text(form_ptr,HS_RI_IMAGE_RESOL,
                                                  i,0,10,text,&sel_flag);
			      if (strcmp(text,"Medium")==0)
                              {
				FIfld_set_list_select(form_ptr,
                                                      HS_RI_IMAGE_RESOL,i,0,1);
	                        FIg_set_text(form_ptr,HS_RI_IMAGE_RESOL,text);
                               }
			 }
                 }
              }
           }
         }
      }
   }
 } 
                 
 /*--------convert_working_to_alias-----------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	convert_working_to_alias( IGRdouble first_dim,
				    IGRchar *first_str,
				     IGRint display_unit )
#else
	convert_working_to_alias(first_dim,first_str,display_unit)

	IGRdouble first_dim;
	IGRchar   *first_str;
	IGRint    display_unit;
#endif


{
 GRobjid  mod_id;
 GRspacenum   mod_os;
 struct    GRIOreadout_spec readout;
 IGRint    num_alias, conversions, field_size;
 IGRlong msg;



        ex$get_cur_mod(id = &mod_id, osnum = &mod_os);    

	num_alias = 1;

	readout.justification     = GRIO_LEFT_JUSTIFY;
	readout.mode              = GRIO_DECIMAL;
	readout.precision         = 4;
	readout.case_type         = GRIO_DEFAULT_CASE;
	readout.leading_zeros     = TRUE;
	readout.trailing_zeros    = FALSE;
	readout.decimal_char      = GRIO_PERIOD;
	readout.thousands_char    = GRIO_NONE;
	readout.intermeas_spacing = 1;
	readout.intrameas_spacing = 0;
	readout.left_fill_char    = ' ';
	readout.alias_displayed   = display_unit;
	field_size = 40;
	conversions =1;

	co$cvt_imp_to_alias(msg = &msg,
			    osnum = mod_os,
			    unit_type = GRIO_DISTANCE,
			    working_units = &first_dim,
			    num_alias =&num_alias,
			    num_conversions = conversions,
			    readout_spec = &readout,
			    field_size = &field_size,
			    cvt_list = first_str);
	

	return(1);
}

/*--------------------END FUNCTIONS------------------------------------------*/



at init
   do initialize_instance

at delete
   do delete_rendering_gragad

state *			/* default transitions for all states */
   on EX_RJT_MOVEON state .
   on EX_RESTART    state sel_window
   on EX_BACK_UP    state -


state validate_virtual_screen
   message_key HSM_M_RenderImage
   execute check_virtual_screen
 
      on SUCCESS
          state sel_window
      on ELSE
          state terminate

state sel_window
   prompt_key  HS_P_SelWin
   filter      get_event
   execute     save_form_ptr

      on EX_DATA or EX_STRING
         do get_selected_window( sts, 0, 1, 0, 0 )
            on SUCCESS
	       do set_form_defaults
	       state sel_grp_elements
      on ELSE
               state .
         state .

      on EX_BACK_UP
         state .

state sel_grp_elements
   prompt_key               HS_P_SelEle
   status_key               HS_I_ChgOption
   accept_key               HS_P_SingleAccept
   filter		    get_event

      on EX_STRING = "" or EX_RJT_MOVEON
           do get_elements_in_view
           on SUCCESS
               state sel_elements 
           on ELSE
               state .
           state .


     on EX_DATA or EX_OBJID or EX_STRING
           do put_event_back_on_queue
    	   state sel_elements
     on EX_FORM_FINISHED
         do which_state
             on  RETURN_CODE =SAVE_AND_EXECUTE
                  do  erase_form STATUS_FORM
                  do  set_render_info
                  state .
             on RETURN_CODE = IGNORE_AND_EXIT
                  do erase_form STATUS_FORM
                  state .
         state .


state sel_elements
   prompt_key               HS_P_SelEle
   status_key               HS_I_ChgOption
   accept_key               HS_P_SingleAccept
   relocate_key             HS_I_Relocate
   locate_display           "ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
   locate_properties        "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
   locate_owner             "LC_READ | LC_REF_OBJECTS"
   gslocate_num_inputs      0
   unhilight_mode           "GRhe"
   locate_class             "GRgraphics"
   filter                   gs_locate_noauto

      on EX_DATA or EX_OBJID
         do create_rendering_gragad
         do render
         state wait_for_event
      on EX_FORM_FINISHED
         do which_state
             on  RETURN_CODE =SAVE_AND_EXECUTE
                  do  erase_form STATUS_FORM
                  do  set_render_info
                  state .
             on RETURN_CODE = IGNORE_AND_EXIT
                  do erase_form STATUS_FORM
                  state .
         state .




state wait_for_event
   prompt_key  HS_I_MoveOnToContinue
   filter   get_event

      on EX_BACK_UP or EX_RJT_MOVEON or ELSE
         state terminate


/*----------------ACTIONS------------------------------------------------------*/

action put_event_back_on_queue

  {
  IGRlong msg;

 
  ex$putque(msg = &msg,
            response = (int *)&me->event1.response,
            byte = (IGRlong *)&me->event1.nbytes,
            buffer = (IGRchar *)me->response_data);

 }


action get_elements_in_view

{
   IGRlong msg;
   IGRlong size;
   int      response;
   IGRchar command_key[30];
   IGRint status_form_displayed;

   status_form_displayed = FALSE;
   if ( me->status_display_form_ptr )
         FIf_is_displayed( me->status_display_form_ptr, &status_form_displayed );
   if ( status_form_displayed )
           *sts = OM_W_WARNING;
  else
   {
           *sts = OM_S_SUCCESS;
	   size = strlen (me->gragad_name) + 1;

	   response = EX_STRING;

	   ex$putque(msg = &msg,
		     response = &response,
		     byte = &size,
		     buffer = me->gragad_name);


	   strcpy(command_key, "GRSlEInV");

	   size = strlen(command_key) +1;

	   response = EX_CMD_KEY;

	   ex$putque(msg = &msg,
		     response = &response,
		     byte = &size,
		     buffer = (IGRchar *)command_key);
   }

}

/*--- initialize_instance ------------------------------------------------------*/

action initialize_instance

/*
DESCRIPTION
	Initialize the instance data used in this command.
*/

	{
	struct scr_info    screen_info[MAX_SCREENS];
        IGRint             msg_strip_ht,msg_value;
        IGRchar            *msg_str;
        IGRint             ss;
        IGRlong		msg;

	*sts = OM_S_SUCCESS;
     
        msg_strip_ht = 0;
        msg_value = 0;
        msg_str = getenv("HS_RENDER_SMALL_SCREEN");
        if (msg_str)
        {
            sscanf(msg_str,"%d",&msg_value);
            if (msg_value)
            {
               msg_strip_ht = 54;
            }
        }
#ifdef X11
        me->dest_vs = EXscreen;
        me->max_width = DisplayWidth(EXdisplay, EXscreen);
        me->max_height = DisplayHeight(EXdisplay, EXscreen)-msg_strip_ht;
#else
	Inq_displayed_vs( &me->dest_vs );
	Inq_screen_info( screen_info );

	me->max_width = screen_info[me->dest_vs].vsi_x;
	me->max_height = screen_info[me->dest_vs].vsi_y - msg_strip_ht;
#endif


        ss = om$send(msg = message HSRenderImg.get_render_info(&msg),
                      targetid = my_id);

	me->window.objid = me->rendering_gragad.objid = NULL_OBJID;

	me->dest_wno = -1;

	/* turn cell component locate on */
	GRclcomplocon( 1 );

	}  /* initialize_instance */


/*--- check_virtual_screen -----------------------------------------------------------*/

action check_virtual_screen

/*
DESCRIPTION
	This action checks to see if the virtual screen that was active when the command
	started has enough bit planes to support rendering (i.e., at least 3).  If it 
	doesn't have enough bit planes, an error box is displayed and *sts is set to 
	OM_W_WARNING.  If the virtual screen has enough bit planes, *sts is set to 
	OM_S_SUCCESS.
*/

	{

/*	struct scr_info screen_info[MAX_SCREENS]; */
        int     planes;

	*sts = OM_S_SUCCESS;

/*	Inq_screen_info( screen_info );

	if ( screen_info[me->dest_vs].vsi_num_planes < 3 ) */
        ige$inq_term_info(num_of_planes = &planes);
        if (planes < 3)
	   {
	   HSnot_enough_planes_to_render();
	   *sts = OM_W_WARNING;
	   }

	return( OM_S_SUCCESS );
	}


/*-------which_state----------------------------------------------------*/

action	which_state

	{
	*sts = me->switch1;
	}  /* which_state */

action save_form_ptr
       {
         if (me->status_display_form_ptr)
         {
            me->form_ptr = (Form) me->status_display_form_ptr;
            me->status_display_form_ptr = NULL;
         }
       }

/*----set_form_defaults------------------------------------------------------*/

action set_form_defaults

/*
DESCRIPTION
	Set the values on the form based on my instance data and
	the window that was selected.
*/

	{
	Form            form_ptr;
	IGRlong         ret_bytes;
	IGRint		which_error;
	IGRchar         text[100];
	struct var_list inq_list[3];
	struct EX_var_list var_list[2];
	IGRlong         msg;
	IGRint          dep_extents[4];
	IGRint          num_rows,i,num_char,sel_flag;
        IGRchar         *msg_str;
        IGRint          msg_strip_ht, msg_val,vs_num,valid_file_name,flags;
        IGRchar         temp_file[200],*first_period;

        struct scr_info screen_info[MAX_SCREENS];


        *sts = om$send(msg= message HSRenderImg.get_render_info(&msg),
                       targetid = my_id);
        me->status_display_form_ptr = (Form) me->form_ptr;
	form_ptr = (Form )me->status_display_form_ptr;

	inq_list[0].var = GRAGAD_NAME;
	inq_list[0].var_ptr =  me->gragad_name;
	inq_list[0].num_bytes = sizeof(me->gragad_name);
	inq_list[0].bytes_returned = &ret_bytes;

	inq_list[1].var = GRAGAD_DEP;
	inq_list[1].var_ptr = (IGRchar *) dep_extents;
	inq_list[1].num_bytes = sizeof(IGRint)*6;
	inq_list[1].bytes_returned = &ret_bytes;

	inq_list[2].var = END_PARAM;

	status = dp$inq_set_gragad( msg          = &msg,
	                            osnum        = me->win_ids[0].osnum,
	                            gragad_objid = me->win_ids[0].objid,
	                            which_error	 = &which_error,
	                            var_list	 = inq_list );
				
	FIg_set_text( form_ptr, HS_RI_WINDOW_NAME, me->gragad_name);

	/* set default number of pixels to the size of the window */
	me->curr_win_width =( dep_extents[2] - dep_extents[0] + 1);
	if ( me->curr_win_width > me->max_width )
	   me->curr_win_width = me->max_width;

	me->curr_win_height = (dep_extents[3] - dep_extents[1] + 1);
	if ( me->curr_win_height > me->max_height )
	   me->curr_win_height = me->max_height;

        hs$get_shading_flags(rendering_flags = &flags);
        valid_file_name = flags & HS_RENDER_VALID_FILE;
        if (!valid_file_name)
        {
                if (strlen(me->image_name) == 0)
                {
			ret_bytes = sizeof( temp_file );

                        var_list[0].var       = EX_CUR_FILENAME;
                        var_list[0].var_value = temp_file;
                        var_list[0].num_bytes = (IGRint *)&ret_bytes;
                        var_list[1].var       = EX_END_PARAM;

                        *sts = ex$global( var = var_list, which_error = &which_error );

                        /* truncate file name to 10 characters */
                        if ( strlen( temp_file ) > 10 )
                           temp_file[10] = '\0';

                        /* truncate file name to before the first period */
                        first_period = (char *)strchr( temp_file, '.' );
                        if ( first_period )
                           *first_period = '\0';

                        sprintf( me->image_name, "/usr/tmp/%s.rgb", temp_file );
                }
        }

        if (me->image_size == HS_RENDER_SIZE_WINDOW)
        {
		me->width = me->curr_win_width * me->fact;
		me->height = me->curr_win_height * me->fact;

             /*Needed because if the form is not displayed and the selection
               is Current Window the size should be correct */


                hs$set_render_image_info(width = me->width, 
                                         height = me->height,
                                         image_filename = me->image_name,
                                         device_res = me->text_devic_resol,
                                         media_size= me->media_size);
        }
        if (me->image_size == HS_RENDER_SIZE_SCREEN)
        {
                msg_strip_ht = 0;
                msg_val =0;
                msg_str = getenv("HS_RENDER_SMALL_SCREEN");
                if (msg_str)
                {
                    sscanf(msg_str,"%d",&msg_val);
                    if (msg_val)
                    {
                        msg_strip_ht = 54;
                    }
                }
#ifdef X11
                vs_num = EXscreen;
                me->width = DisplayWidth(EXdisplay, vs_num) * me->fact;
                me->height = (DisplayHeight(EXdisplay,vs_num) -msg_strip_ht) * me->fact;
#else
	        Inq_displayed_vs(&vs_num);
                Inq_screen_info(screen_info);
                me->width = screen_info[vs_num].vsi_x * me->fact;
                me->height = (screen_info[vs_num].vsi_y - msg_strip_ht) * me->fact;
#endif
        }

	sprintf(text,"%d",me->width);
	FIg_set_text( form_ptr, HS_RI_WIDTH, text);

	sprintf(text,"%d",me->height);
	FIg_set_text( form_ptr, HS_RI_HEIGHT, text);


	FIg_set_text( form_ptr, HS_RI_IMAGE_FILE_NAME, me->image_name);

        FIfld_get_list_num_rows(form_ptr,HS_RI_IMAGE_SIZE,0,&num_rows);
 
   
        FIfld_set_list_text(form_ptr,HS_RI_IMAGE_SIZE,3,0,"User Defined",0);

        switch (me->image_size)
        {
            case HS_RENDER_SIZE_WINDOW:
                      FIg_set_text(form_ptr, HS_RI_IMAGE_SIZE,"Current Window");
                      FIfld_set_list_select(form_ptr,HS_RI_IMAGE_SIZE,0,0,TRUE);
                      break;
            case HS_RENDER_SIZE_SCREEN:
                      FIg_set_text(form_ptr, HS_RI_IMAGE_SIZE,"Screen");
                      FIfld_set_list_select(form_ptr,HS_RI_IMAGE_SIZE,1,0,TRUE);
                      break;
            case HS_RENDER_SIZE_OTHER:
                      FIg_set_text(form_ptr, HS_RI_IMAGE_SIZE,"Other Output Devices");
                      FIfld_set_list_select(form_ptr,HS_RI_IMAGE_SIZE,2,0,TRUE);
                      break;
            case HS_RENDER_SIZE_USER:
                      FIg_set_text(form_ptr, HS_RI_IMAGE_SIZE,"User Defined");
                      FIfld_set_list_select(form_ptr,HS_RI_IMAGE_SIZE,3,0,TRUE);
                      break;
            default:
                      break;
         }

         switch(me->image_resol)
         {
            case HS_RI_FULL_RESOL:
                     FIg_set_text(form_ptr, HS_RI_IMAGE_RESOL,"Full");
                     FIfld_set_list_select(form_ptr,HS_RI_IMAGE_RESOL,0,0,TRUE);
                     break;
            case HS_RI_MEDIUM_RESOL:
                     FIg_set_text(form_ptr, HS_RI_IMAGE_RESOL,"Medium");
                     FIfld_set_list_select(form_ptr,HS_RI_IMAGE_RESOL,1,0,TRUE);
                     break;
            case HS_RI_LOW_RESOL:
                     FIg_set_text(form_ptr, HS_RI_IMAGE_RESOL,"Low");
                     FIfld_set_list_select(form_ptr,HS_RI_IMAGE_RESOL,2,0,TRUE);
                     break;
            default:
                     break;
         }
           
           

	FIfld_set_mode(form_ptr, HS_RI_DEVICE_RESOL, 0, FI_REVIEW);
	FIfld_set_mode(form_ptr, HS_RI_MEDIA_SIZE, 0, FI_REVIEW);
	FIfld_set_list_mode(form_ptr, HS_RI_DEVICE_RESOL, 0, FI_SINGLE_SELECT);
	FIfld_set_list_mode(form_ptr, HS_RI_MEDIA_SIZE, 0, FI_SINGLE_SELECT);
	FIg_erase(form_ptr,HS_RI_ANTI_ALIAS);
        if (me->image_size == HS_RENDER_SIZE_WINDOW || me->image_size == HS_RENDER_SIZE_SCREEN)
        {
            FIg_erase(form_ptr,HS_RI_GROUP);
        }
        else
        {
               HSriprocess_image_size(me->image_size, form_ptr);
               num_char = 20;
               FIfld_get_list_num_rows(form_ptr, HS_RI_MEDIA_SIZE,0, &num_rows);
	       for(i=0;i<num_rows;i++)
	       {
		     FIfld_get_list_text(form_ptr, HS_RI_MEDIA_SIZE, i, 
					 0, num_char, text, &sel_flag);
		     if (strcmp(me->media_size , text)==0)
			FIfld_set_list_select(form_ptr, HS_RI_MEDIA_SIZE, 
					      i, 0,TRUE);
	       }
	       FIfld_get_list_num_rows(form_ptr, HS_RI_DEVICE_RESOL,0, &num_rows);
	       for(i=0;i<num_rows;i++)
	       {
		     FIfld_get_list_text(form_ptr, HS_RI_DEVICE_RESOL,i, 
					 0, num_char, text, &sel_flag);
		     if (strcmp(me->text_devic_resol , text)==0)
			FIfld_set_list_select(form_ptr, HS_RI_DEVICE_RESOL,
					      i, 0,TRUE);
	       }
               FIg_set_text(form_ptr, HS_RI_MEDIA_SIZE, me->media_size);
               FIg_set_text(form_ptr, HS_RI_DEVICE_RESOL, 
                           me->text_devic_resol);
            
            
            
        }
            
            



	}  /* set_form_defaults */


/*----form_notification---------------------------------------------------*/

action form_notification

	{
	Form	  form_ptr;
	int       vs_num;
        struct scr_info screen_info[10];
	IGRchar	  text[200],msgbuf[200];
	IGRint    i,stat;
	IGRint    sel_flag;
        IGRint    old_image_size,old_image_resol;
        IGRchar   name[30], old_media_size[200];
        IGRdouble old_devic_resol,new_dim[2],values_out[2];
	IGRdouble fact;
        IGRchar   temp_str1[40],temp_str2[40];
        IGRlong   msg;
        GRobjid  mod_id;
        GRspacenum   mod_os;

 
        /*Temporary variables */
 
        IGRint    temp_width, temp_height;
        IGRdouble temp_media_width, temp_media_height,temp_devic_resol;
        IGRchar   old_text_devic_resol[200];
        
        /*Need to Handle environment variables*/
        IGRchar   *msg_str;
        IGRint    msg_strip_ht, msg_val;

	form_ptr = (Form) me->status_display_form_ptr;

        FIg_set_text(form_ptr, HS_RI_MSG_AREA, "");
	switch( gadget_label )
	   {	
	   case HS_RI_IMAGE_FILE_NAME:

		FIg_get_text( form_ptr, HS_RI_IMAGE_FILE_NAME, text );
                strcpy(me->image_name,text);
		if ( (strlen(text) == 0) || (!strcmp(text, "none")) )
		   {
	   	   /* user entered NULL string or "none" => don't write RGB file */
		   strcpy( me->image_name, text );
		   me->write_file = FALSE;
		   }
		else
	 	   me->write_file = TRUE;
		break;

	   case HS_RI_IMAGE_SIZE:
                   FIg_get_text(form_ptr,HS_RI_IMAGE_SIZE,text);
                   switch(text[0])
                     {
                      case 'C':
                              me->image_size= HS_RENDER_SIZE_WINDOW;
	                      FIg_erase(form_ptr,HS_RI_GROUP);
                              me->width = me->curr_win_width * me->fact + 0.5;
                              me->height = me->curr_win_height * me->fact + 0.5;
                              sprintf(text,"%d",me->width);
                              FIg_set_text( form_ptr, HS_RI_WIDTH, text);
                              sprintf(text,"%d",me->height);
                              FIg_set_text( form_ptr, HS_RI_HEIGHT, text);
                              break;
                      case 'S':
	                      FIg_erase(form_ptr,HS_RI_GROUP);
                              me->image_size= HS_RENDER_SIZE_SCREEN;
                              msg_strip_ht = 0;
                              msg_val =0;
                              msg_str = getenv("HS_RENDER_SMALL_SCREEN");
                              if (msg_str)
                              {
                                  sscanf(msg_str,"%d",&msg_val);
                                  if (msg_val)
                                  {
                                     msg_strip_ht = 54;
                                  }
                              }
#ifdef X11
                              vs_num = EXscreen;
                              me->width = DisplayWidth(EXdisplay, vs_num)* me->fact;
                              me->height= (DisplayHeight(EXdisplay, vs_num) - msg_strip_ht)* me->fact;
#else
	                      Inq_displayed_vs(&vs_num);
                              Inq_screen_info(screen_info);
                              me->width = screen_info[vs_num].vsi_x * me->fact;
                              me->height = (screen_info[vs_num].vsi_y - msg_strip_ht) * me->fact;
#endif
                              sprintf(text,"%d",me->width);
                              FIg_set_text( form_ptr, HS_RI_WIDTH, text);
                              sprintf(text,"%d",me->height);
                              FIg_set_text( form_ptr, HS_RI_HEIGHT, text);
                              break;
                      case 'O':
	                      old_image_size = me->image_size;
                              me->image_size= HS_RENDER_SIZE_OTHER;
                              temp_media_width = 8.5;
                              temp_media_height = 11.0;
	                      temp_devic_resol = 200.0;
                              temp_width = temp_devic_resol * temp_media_width * me->fact + 0.5;
                              temp_height = temp_devic_resol * temp_media_height * me->fact + 0.5;


                              HScheck_dim_validity(form_ptr, &temp_width,
                                                   &temp_height,&stat,
                                                   &me->image_resol, &me->fact);
                              if (stat == HS_RI_ERROR)
                              {
                                 ex$message(msgnumb = HS_E_ImgBig, buff = msgbuf);
                                 FIg_set_text(form_ptr, HS_RI_MSG_AREA, msgbuf);
                                              
                                 sleep(3);
                                 FIg_set_text(form_ptr, HS_RI_MSG_AREA,"");
                                 me->image_size =  old_image_size;
                                 FIfld_set_list_select(form_ptr,
                                                       HS_RI_IMAGE_SIZE, 
                                                       me->image_size_row,0,
                                                       TRUE);
                                 FIfld_get_list_select(form_ptr, 
                                                       HS_RI_IMAGE_SIZE,
                                                       me->image_size_row,
                                                       0,&sel_flag);
                                 FIg_set_text(form_ptr,HS_RI_IMAGE_SIZE,name);
                                 
                              }
                                 
                              else
                               {
				      me->width = temp_width;
				      me->height = temp_height;
				      me->media_width = temp_media_width;
				      me->media_height = temp_media_height;
                                      strcpy(me->text_devic_resol,"200 DPI");
	                              me->devic_resol = temp_devic_resol;
	                              strcpy(me->media_size,"A");


				      sprintf(text,"%d",me->width);
				      FIg_set_text( form_ptr, HS_RI_WIDTH, text);
				      sprintf(text,"%d",me->height);
				      FIg_set_text( form_ptr, HS_RI_HEIGHT, 
                                                    text);
				      HSriprocess_image_size(me->image_size,
            					             form_ptr);

                    		      FIfld_set_list_select(form_ptr,
                                                            HS_RI_DEVICE_RESOL,
                                                            0,0,1);
                                      FIfld_set_list_select(form_ptr,
                                                            HS_RI_MEDIA_SIZE,
                                                            0,0,1);

                               
				      for (i=0;i<4;i++)
				      { 
				       FIfld_get_list_select(form_ptr, 
							     HS_RI_IMAGE_SIZE,
							       i,0,&sel_flag);
				       if (sel_flag ==TRUE)
					    me->image_size_row =i;
				       }
                               }
                              break;
                      case 'U':
	                      old_image_size = me->image_size;
                              me->image_size= HS_RENDER_SIZE_USER;
                              temp_media_width = 8.5;
                              temp_media_height = 11.0;
	                      temp_devic_resol = 200.0;
                              temp_width = temp_devic_resol * temp_media_width * me->fact + 0.5;
                              temp_height = temp_devic_resol * temp_media_height * me->fact + 0.5;

                              HScheck_dim_validity(form_ptr, &temp_width,
						   &temp_height,&stat,
						   &me->image_resol, &me->fact);
			      if (stat == HS_RI_ERROR)
                              {
                                 ex$message(msgnumb = HS_E_ImgBig, buff = msgbuf);
                                 FIg_set_text(form_ptr, HS_RI_MSG_AREA, msgbuf);
                                 sleep(3);
                                 FIg_set_text(form_ptr, HS_RI_MSG_AREA,"");
                                 me->image_size =  old_image_size;
                                 FIfld_set_list_select(form_ptr,
                                                       HS_RI_IMAGE_SIZE,
                                                       me->image_size_row,0,
                                                       TRUE);
                                 FIfld_get_list_select(form_ptr,
                                                       HS_RI_IMAGE_SIZE,
                                                       me->image_size_row,
                                                       0,&sel_flag);
                                 FIg_set_text(form_ptr,HS_RI_IMAGE_SIZE,name);

                              }

                              else
                              {
				      me->media_width = temp_media_width;
				      me->media_height = temp_media_height;
				      me->width = temp_width;
				      me->height = temp_height;
				      strcpy(me->text_devic_resol,"200 DPI");
	                              me->devic_resol = temp_devic_resol;
                                      strcpy(me->media_size,"8.5x11");
				      sprintf(text,"%d",me->width);
				      FIg_set_text( form_ptr, HS_RI_WIDTH, text);
				      sprintf(text,"%d",me->height);
				      FIg_set_text( form_ptr, HS_RI_HEIGHT, 
					       	    text);
				      HSriprocess_image_size(me->image_size,
							     form_ptr);
	                              FIfld_set_list_select(form_ptr,
                                                            HS_RI_DEVICE_RESOL,
                                  			    0,0,1);
	                              FIfld_set_list_select(form_ptr,
                                                            HS_RI_MEDIA_SIZE,
                                  			    0,0,1);
				      for (i=0;i<4;i++)
				      {
				       FIfld_get_list_select(form_ptr, HS_RI_IMAGE_SIZE,
							       i,0,&sel_flag);
				       if (sel_flag ==TRUE)
					    me->image_size_row =i;
				      }
                              }

                              break;
                     }
                   break;
            case HS_RI_IMAGE_RESOL:
	                old_image_resol = me->image_resol;
	                fact = 1.0;
                        FIg_get_text(form_ptr,HS_RI_IMAGE_RESOL,text);
                        switch(text[0])
                          {
                           case 'F':
                                   me->image_resol= HS_RI_FULL_RESOL;
                                   fact = 1.0;
                                   break;
                           case 'M':
                                   me->image_resol= HS_RI_MEDIUM_RESOL;
                                   fact = 0.5;
                                   break;
                           case 'L':
                                   me->image_resol= HS_RI_LOW_RESOL;
                                   fact = 0.25;
                                   break;
                          }
	                  if (me->image_size == HS_RENDER_SIZE_WINDOW || me->image_size == HS_RENDER_SIZE_SCREEN)
                          {
	                        temp_width =  (fact  * me->width) / me->fact + 0.5;
	                        temp_height =  (fact * me->height) / me->fact + 0.5;
                          }
                          else
                          {
	                        temp_width =  fact  * me->devic_resol * me->media_width + 0.5;
	                        temp_height =  fact * me->devic_resol * me->media_height + 0.5;
                          }
                          HScheck_dim_validity(form_ptr, &temp_width,
					   &temp_height,&stat,
					   &me->image_resol, &fact);
                          if (stat == HS_RI_ERROR)
                          {
                             ex$message(msgnumb = HS_E_ImgBig, buff = msgbuf);
                             FIg_set_text(form_ptr, HS_RI_MSG_AREA, msgbuf);
                             sleep(3);
                             FIg_set_text(form_ptr, HS_RI_MSG_AREA,"");
                             me->image_resol = old_image_resol;
                             FIfld_set_list_select(form_ptr, HS_RI_IMAGE_RESOL,
                                                   me->image_resol_row,0, 1);
                             FIfld_get_list_text(form_ptr,HS_RI_IMAGE_RESOL,
                                                 me->image_resol_row,0,30,
 					         name,&sel_flag);
                             FIg_set_text(form_ptr,HS_RI_IMAGE_RESOL,name);
                          }
                          else
                          {
                             me->width = temp_width;
                             me->height = temp_height;
                             me->fact   = fact;
			     sprintf(text,"%d",me->width);
			     FIg_set_text( form_ptr, HS_RI_WIDTH, text);
			     sprintf(text,"%d",me->height);
			     FIg_set_text( form_ptr, HS_RI_HEIGHT, text);
                          }
                          for (i=0;i<4;i++)
                          {
				       FIfld_get_list_select(form_ptr, 
						    	     HS_RI_IMAGE_RESOL,
							     i,0,&sel_flag);
				       if (sel_flag ==TRUE)
					    me->image_resol_row =i;
                          }
                             
                        break;

           case HS_RI_DEVICE_RESOL:
	               old_devic_resol = me->devic_resol;
                       strcpy(old_text_devic_resol, me->text_devic_resol);
                       FIg_get_text(form_ptr,HS_RI_DEVICE_RESOL,text);
                       strcpy(me->text_devic_resol,text);
	               for(i=0;i<197;i++)
                       if (text[i] ==  'D' && text[i+1] == 'P' && text[i+2] == 'I')
                          {
                              text[i-1] = '\0';
                          }
                       sscanf(text,"%lf",&me->devic_resol);
	               if (me->devic_resol > 4000.0)
                        {
                            ex$message(msgnumb = HS_W_DevResol, buff = msgbuf);
                            FIg_set_text(form_ptr, HS_RI_MSG_AREA, msgbuf);
                            sleep(3);
                            FIg_set_text(form_ptr, HS_RI_MSG_AREA, "");
                            me->devic_resol = 4000.0;
	                    strcpy(text,"4000 DPI");
                            strcpy(me->text_devic_resol,text);
                            FIg_set_text(form_ptr,HS_RI_DEVICE_RESOL,text);
                        } 

	               temp_width = me->devic_resol * me->media_width  * me->fact + 0.5;
	               temp_height = me->devic_resol * me->media_height *  me->fact + 0.5;

                       HScheck_dim_validity(form_ptr, &temp_width,&temp_height,
                                            &stat,&me->image_resol, &me->fact);
	               if (stat == HS_RI_ERROR)
                       {
	                 ex$message (msgnumb = HS_E_ImgBig, buff = msgbuf);
                         FIg_set_text(form_ptr, HS_RI_MSG_AREA,  msgbuf);
                         sleep(3);
                         FIg_set_text(form_ptr, HS_RI_MSG_AREA,""); 

                         me->devic_resol = old_devic_resol;
                         strcpy(me->text_devic_resol, old_text_devic_resol);
                         FIg_set_text(form_ptr,HS_RI_DEVICE_RESOL,me->text_devic_resol);
	                 for (i=0;i<3;i++)
                         {
                           FIfld_get_list_text(form_ptr, HS_RI_DEVICE_RESOL,
                                               i,0,30,name,&sel_flag);
                           if (strcmp(text,name)==0)
                              FIfld_set_list_select(form_ptr,HS_RI_DEVICE_RESOL,
                                               i,0,TRUE);
                         }
                       }
                       else
                       {
			       me->width = temp_width;
			       me->height = temp_height;


			       sprintf(text,"%d",me->width);
			       FIg_set_text( form_ptr, HS_RI_WIDTH, text);
			       sprintf(text,"%d",me->height);
			       FIg_set_text( form_ptr, HS_RI_HEIGHT, text);
                       } 
                       break;
          
           case HS_RI_MEDIA_SIZE:
	               strcpy(old_media_size,me->media_size);
         	       FIg_get_text(form_ptr, HS_RI_MEDIA_SIZE,text);
                       strcpy(me->media_size,text);
	               switch (me->media_size[0])
                       {
                         case 'A':
	                       switch (me->media_size[1])
                               {
                                 case '3':  
                                         temp_media_width = 16.53;
                                         temp_media_height = 11.69;
                                         break;
   
                                 case '4':
                                         temp_media_width = 11.69;
                                         temp_media_height = 8.26;
                                         break;

                                 default:
                                         temp_media_width = 8.5;
                                         temp_media_height = 11.0;
	                                 break;
                                }
                                break;
                        case 'B':
                               temp_media_width = 11.0;
                               temp_media_height = 17.0;
                               break;
	                default:
                               HSprocess_dimension(me->media_size,
                                                   &temp_media_width,
                                                   &temp_media_height);
                               FIg_set_text(form_ptr,HS_RI_MEDIA_SIZE,me->media_size);
                               break;
                       }
                       temp_width = me->devic_resol * temp_media_width * me->fact + 0.5;
                       temp_height = me->devic_resol * temp_media_height * me->fact + 0.5;

                       HScheck_dim_validity(form_ptr, &temp_width,&temp_height,
                                            &stat,&me->image_resol, &me->fact);
                      
                       if (stat == HS_RI_ERROR)
    
                       {
                              ex$message(msgnumb = HS_E_Resize1,buff = msgbuf);
                              FIg_set_text(form_ptr, HS_RI_MSG_AREA, msgbuf);
			      if (me->image_size == HS_RENDER_SIZE_USER)
				{
                                 if (temp_width < MIN_WIDTH)
                                 {
                                     temp_width = me->width = MIN_WIDTH;
                                     temp_height = me->height = me->width / (1.0 * me->curr_win_width / me->curr_win_height) + 0.5;
                                 }
                                 if (temp_height < MIN_HEIGHT)
                                 {
                                     temp_height = me->height = MIN_HEIGHT;
                                     temp_width = me->width  = 1.0 * me->height * (1.0 * me->curr_win_width / me->curr_win_height) + 0.5;
                                 }
                                
				 if ((temp_width * temp_height > MAX_PROD) || (temp_width > MAX_DIM) || (temp_height > MAX_DIM))
				 {
				     me->width = sqrt( 1.0 * MAX_PROD * me->curr_win_width /me->curr_win_height);
				     me->height = sqrt( 1.0 * MAX_PROD * me->curr_win_height/me->curr_win_width);
				 }
				 if (me->width > MAX_DIM)
				 {
				     me->width = MAX_DIM;
				     me->height = MAX_DIM * me->curr_win_height/me->curr_win_width + 0.5;
				 }
				 if (me->height > MAX_DIM)
				 {
				     me->height = MAX_DIM;
				     me->width = MAX_DIM * me->curr_win_width/me->curr_win_height + 0.5;
				 }
                                 
                                 /*Setting to the max and min values as permitted by the window */

                                 new_dim[0] = me->width/(me->fact * me->devic_resol);
                                 new_dim[1] = me->height /(me->fact * me->devic_resol);
                                 ex$get_cur_mod(id = &mod_id, osnum = &mod_os);    
                                 co$cvt_value_to_value(msg = &msg,
                                                       osnum = mod_os,
                                                       unit_type = GRIO_DISTANCE ,
                                                       alias_to_cvt_from ="inches",
                                                       num_vals = 2,
                                                       values_in = new_dim,
                                                       values_out = values_out);

                                 convert_working_to_alias(values_out[0],temp_str1,TRUE);
                                 convert_working_to_alias(values_out[1],temp_str2,TRUE);
                                 sprintf(me->media_size,"%s x %s",temp_str1,temp_str2);
                                 HSprocess_dimension(me->media_size,&me->media_width,&me->media_height);
                                 FIg_set_text(form_ptr,HS_RI_MEDIA_SIZE,me->media_size);  
			         sprintf(text,"%d",me->width);
			         FIg_set_text( form_ptr, HS_RI_WIDTH, text);
			         sprintf(text,"%d",me->height);
			         FIg_set_text( form_ptr, HS_RI_HEIGHT, text);
				}
				else
			    
				{
				 ex$message(msgnumb = HS_E_ImgBig, buff = msgbuf);
				 FIg_set_text(form_ptr, HS_RI_MSG_AREA,  msgbuf);
				 sleep(3);
				 FIg_set_text(form_ptr, HS_RI_MSG_AREA,"");
				 strcpy(me->media_size, old_media_size);
				 FIg_set_text(form_ptr,HS_RI_MEDIA_SIZE,me->media_size);
				 for (i=0;i<3;i++)
				 {
				   FIfld_get_list_text(form_ptr, HS_RI_MEDIA_SIZE,
						       i,0,30,name,&sel_flag);
				   if (strcmp(me->media_size,name)==0)
				      FIfld_set_list_select(form_ptr,HS_RI_MEDIA_SIZE,
						       i,0,TRUE);
				 }
				 
				}
                       }     
       
	               else
                       {
			       me->media_width = temp_media_width;
			       me->media_height = temp_media_height;
			       me->width = temp_width;
			       me->height = temp_height;
			       sprintf(text,"%d",me->width);
			       FIg_set_text( form_ptr, HS_RI_WIDTH, text);
			       sprintf(text,"%d",me->height);
			       FIg_set_text( form_ptr, HS_RI_HEIGHT, text);
                       }
                       break;


	   case HS_RI_CANCEL:
		me->switch1 = IGNORE_AND_EXIT;
                FIg_set_state_off(form_ptr, HS_RI_CANCEL);
		_put_response(resp = EX_FORM_FINISHED);

		break;
           case HS_RI_CHECK:
                FIg_set_state_off(form_ptr, HS_RI_CHECK);
		me->switch1 = SAVE_AND_EXECUTE;
		_put_response(resp = EX_FORM_FINISHED);
                  break; 

	   default:

		break;

	   } /* end_switch */


	}/* form_notification */


/*--- create_rendering_gragad --------------------------------------------------*/

action create_rendering_gragad

/*
DESCRIPTION
	This action creates the full screen EnvironV window required for rendering.
*/

	{
	
        me->form_ptr = (Form) me->status_display_form_ptr;
        me->status_display_form_ptr = NULL;

	HRinit_rendering_window( me->dest_vs, &me->dest_wno, &me->dest_x_dits, &me->dest_y_dits, 0 );
	}  /* create_rendering_window */


/*--- delete_rendering_gragad ---------------------------------------*/

action delete_rendering_gragad

/*
DESCRIPTION
	Delete the windows that were created for rendering
*/

	{
	*sts = OM_S_SUCCESS;

 	/* delete the window that contains the rendered image */
	if ( me->dest_wno != -1 )
	   HRdelete_rendering_window( me->dest_wno, TRUE );

	/* turn cell component locate on */
	GRclcomplocon( 0 );

	}  /* delete_rendering_gragad */


/*--- render --------------------------------------------------------*/

action render

/*
DESCRIPTION
	Send the HSrender_image to the HSgragad to create the rendered image
*/

	{
	IGRlong          msg;
	struct GRid  my_GRid;
        int          file_status;
        char         HSmessage[100],HSmsg1[30], HSmsg2[70];
	FILE         *fp;
#ifdef CLIX
        struct statl buf;
#else
        struct stat  buf;
#endif

	my_GRid.objid = my_id;
	my_GRid.osnum = OM_Gw_current_OS;
    

        *sts = om$send(msg = message HSRenderImg.get_render_info(&msg),
                      targetid = my_id);

        if ( (strlen(me->image_name) == 0) || (!strcmp(me->image_name,"none")))
           me->write_file=FALSE;
        else
           {
#ifdef CLIX
           file_status = statl(me->image_name,&buf);
#else
           file_status = stat(me->image_name,&buf);
#endif
           if (file_status == -1)
               me->write_file=TRUE;
           else
             {
               ex$message ( msgnumb = HS_W_RenderFileExists1, buff = HSmsg1 );
               ex$message ( msgnumb = HS_W_RenderFileExists2, buff = HSmsg2 );

               sprintf(HSmessage,"%s %s %s",HSmsg1,me->image_name, HSmsg2);

               ex$message ( msgnumb = HS_W_WarnTitle, buff = HSmsg1 );
#ifdef X11
               if (HFI_confirm_box( FI_CURRENT_SCREEN, -1, -1,
                         HSmsg1, FI_RED, "swiss742", 36.0,
                         HSmessage, FI_BLACK, "swiss742", 18.0,
                         FI_LEFT_JUSTIFIED, FI_ACCEPT | FI_CANCEL, 40 ))
#else
               if (FI_confirm_box( FI_CURRENT_SCREEN, -1, -1,
                         HSmsg1, FI_RED, "swiss742", 36.0,
                         HSmessage, FI_BLACK, "swiss742", 18.0,
                         FI_LEFT_JUSTIFIED, FI_ACCEPT | FI_CANCEL, 40 ))
#endif
                   me->write_file = TRUE;
               else
                   me->write_file = FALSE;

             }
           }
           if (me->write_file)
           {
    	   /* validate file name */
	    fp = (FILE *)fopen( me->image_name, "w" );
	    if ( fp == NULL )
	      {
	      ex$message( msgnumb = HS_E_CantOpenForWriting );
	      sleep(3);
              me->write_file = FALSE;
	      }
	   else
	      {
	      fclose( fp );
	      }
	   }




	HRrender_image( &msg, &my_GRid, &me->located_chansel, me->image_name,
	                me->width, me->height,
	                me->dest_wno, me->dest_x_dits, me->dest_y_dits, me->write_file,
	                &me->win_ids[0] );

	}  /* render */

action set_render_info
{
IGRint  flags;
 

	hs$set_render_image_info(image_filename = me->image_name, 
                                 device_res = me->text_devic_resol,
				 width = me->width, height = me->height, 
				 media_size= me->media_size);
	flags = 0;
	if (me->image_resol == HS_RI_FULL_RESOL)
	   flags = flags | HS_RENDER_FULL_RES;
	if (me->image_resol == HS_RI_MEDIUM_RESOL)
	   flags = flags | HS_RENDER_MEDIUM_RES;
	if (me->image_resol == HS_RI_LOW_RESOL)
	   flags = flags | HS_RENDER_LOW_RES;
	flags |= (HS_RENDER_IMAGE_SIZE & me->image_size);
        flags | = HS_RENDER_VALID_FILE;
	hs$put_shading_flags(rendering_flags = &flags);
}



action get_render_info
{
IGRint flags,i;
IGRchar text[200];

     hs$get_shading_flags (rendering_flags = &flags);
     hs$get_render_image_info(image_filename = me->image_name, 
                              device_res = text,
			      width = &me->width, height = &me->height, 
			      media_size= me->media_size);
     strcpy(me->text_devic_resol, text);
     me->image_size = flags & HS_RENDER_IMAGE_SIZE;

     for (i=0;i<197;i++)
     {
       if (text[i]=='D' && text[i+1]=='P' && text[i+2]=='I')
           text[i] ='\0';
     }
     sscanf(text,"%lf",&me->devic_resol);
     


     if (flags & HS_RENDER_FULL_RES)
     {
         me->image_resol = HS_RI_FULL_RESOL;
         me->fact= 1.0;
     }
     if (flags & HS_RENDER_MEDIUM_RES)
     {
         me->image_resol = HS_RI_MEDIUM_RESOL;
         me->fact= 0.5;
     }
     if (flags & HS_RENDER_LOW_RES)
     {
         me->image_resol = HS_RI_LOW_RESOL;
         me->fact= 0.25;
     }
     if (strlen(me->media_size) == 0)

     {
         strcpy(me->media_size,"A");
     }
     if (strlen(me->text_devic_resol) == 0)
     {
         strcpy(me->text_devic_resol,"200 DPI");
         me->devic_resol = 200.0;
     } 
     switch(me->media_size[0])
     {
         case 'A':
                 switch (me->media_size[1])
                 {
                    case '3':
                             me->media_width = 16.53;
                             me->media_height = 11.69;
                             break;
                    case '4':
                             me->media_width = 11.69;
                             me->media_height = 8.26;
                             break;
                    default:
                             me->media_width = 8.5;
                             me->media_height = 11.0;
                             break;
                 }
                 break;
         case 'B':
                 me->media_width = 11.0;
                 me->media_height = 17.0;
                 break;
         default:
                 HSprocess_dimension(me->media_size,
                                     &me->media_width,
                                     &me->media_height);
                 break;
      }
#ifdef DEBUG
      printf("Instance data values\n");
      printf("Width  = %d\n", me->width);
      printf("Height = %d\n", me->height);
      printf("media_width = %f\n", me->media_width);
      printf("media_height = %f\n", me->media_height);
      printf("Image_size = %d\n", me->image_size);
      printf("Devic resol = %s %f\n", me->text_devic_resol, me->devic_resol);
      printf("Image_resol = %d\n", me->image_resol);
      printf("Media_size = %s\n", me->media_size);
      printf("Image_name = %s\n", me->image_name);
#endif
}

