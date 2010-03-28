/* #######################    APOGEE COMPILED   ######################## */
/* Command definition section */

product_name		"$GRNUC"
class			COcolors
super_class	        CEO_LOCATE
command_string		GRMAtchClrTbl,0,GRAtClTb
synonym			GRMSvClrTbl,1,GRSvClTb
form			"GRAttClrTbl",0,0,0,0
start_state             strt_state	

/* OPP section */
/* Specification section .. code for .S file */

specification

#include "griodef.h"

instance 
{
	IGRchar	    file_nme[GR_MAX_CHAR];
	IGRshort    valid_name;
	IGRshort    ld_clr_tbl;
	IGRint      type_of_file;
}

/* implementation section - code for .I file */

implementation


#define    EXIT_BUTTON	1
#define    QUIT_BUTTON  4
#define    FILE_NAME    23
#define    IGE_FILE_TYPE    25
#define    IGDS_FILE_TYPE    26
#define	   CANVAS_FILE_TYPE   12
#define    MSG_AREA     10

#define    TRUE  1
#define    FALSE  0

#define    FileExists      112

#include  <stdio.h>
#include  <string.h>

#include  "griodef.h" 
#include  "OMmacros.h"
#include  "wl.h"
#include  "igecolor.h"
#include  "igecolordef.h"
#include  "igecolmacros.h"
#include  "msdef.h"
#include  "msmacros.h"
#include  "execmsg.h"
#include  "grmessage.h"
#include  "griodef.h"
#include  "msdef.h"
#include  "dpdef.h"
#include  "dpmacros.h"

#include  "FI.h"
#include  "FIdyn.h"
#include  "dpcodef.h"
#include  "dpcomacros.h"
#include  "pi.h"
#include  "cctspec.h"

%safe
#include "DPcolors.h"
#include "DPcodpbi.h"
#include "COspmain.h"
#include "dpmacerahil.h"
%endsafe

extern char EX_runname[];

state_table

#define    FileExists      112

#include 	"grmessage.h"

at init do init_act

state *

	on EX_RESTART 	state 	strt_state
	on EX_BACK_UP 	state 	previous_state

	on NULL_STRING  state .

state  strt_state

	on  CMD_TYPE = 0  state load_tbl
	on  CMD_TYPE = 1  state save_tbl

state  load_tbl

	msg_key         GRC_M_AtchClrTbl
        prompt_key      GR_P_SelFrForm

        display_form     0

	filter          wfi

        on  FORM_FINISHED	 state  term1
	on MOVE_ON		state loc_canvas


state   term1

	on ELSE   do loadclrtbl  state terminate

state loc_canvas

	prompt_key 	GR_P_LocCan
	
	erase_form	0

	locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"

	locate_properties "LC_LC_ONLY | LC_RW | LC_DP_ONLY"

	locate_eligible "+GRrg"

	filter locate
	
	on EX_DATA

		on RETURN_CODE = LC_OBJ_LOCATED 
			do ld_can_ctb state terminate

	state terminate

state  save_tbl

	msg_key         GRC_M_SvClrTbl
        prompt_key      GR_P_EntNmeFile
	filter          get_event

	on STRING   do get_file
                       on FileExists  state  file_exsts
		       on SUCCESS state save_file
	            state terminate
	
state  file_exsts

        prompt_key      GR_P_FlExOv
	filter          get_event

	on EX_STRING = "y" state save_file

	on EX_STRING = "n" state save_tbl

state save_file

	on ELSE    do save_file   
                   state terminate

action init_act
{

	IGRchar    logo_ptr[12];
        IGRushort  flags;
        IGRchar    filename[256];

	me->valid_name = FALSE;
	me->type_of_file = FALSE;
	me->ld_clr_tbl = FALSE;
 
		/*Reading the previously stored form attributes */

        filename[0]='\0';
        dp$codpb_get_cct_data(cct_flags = &flags, ctable_filename = filename);
        
		/* if image is running I need to display the canvas chk */

	get_modtype_data(EX_runname,logo_ptr,NULL,NULL,NULL,NULL);
	if (!(strcmp (logo_ptr,"I/IMAGE"))) 
	{
	    FIg_display(me->forms[0].form_ptr,CANVAS_FILE_TYPE);
	}

		/*Restoring the form to the saved  values */

          if (flags & CCT_FILE_TYPE)
           {
 	      status = FIg_set_state_on(me->forms[0].form_ptr,IGDS_FILE_TYPE);
 	      status = FIg_set_state_off(me->forms[0].form_ptr,IGE_FILE_TYPE);
           }
          else
           {
 	      status = FIg_set_state_on(me->forms[0].form_ptr,IGE_FILE_TYPE);
 	      status = FIg_set_state_off(me->forms[0].form_ptr,IGDS_FILE_TYPE);
           }
          if (strlen(filename)!=0)
           {
              strcpy(me->file_nme,filename);
              me->valid_name=TRUE;
              me->ld_clr_tbl=TRUE;
              FIfld_set_text(me->forms[0].form_ptr,FILE_NAME,0,0,filename,TRUE);
           }
}

action form_notification
{

	IGRint      sel_flag;
	IGRint      r_pos;
	IGRint      file_len;
	IGRint      sts;
	IGRint      chk_state;
	IGRchar     buf[256];
        IGRushort   flags;
        IGRchar     filename[256];

	switch(gadget_label) {

	case FILE_NAME :

		FIfld_get_text ( me->forms[0].form_ptr,FILE_NAME,0,0,
				GR_MAX_CHAR,me->file_nme,&sel_flag,&r_pos);
	
	        file_len = strlen(me->file_nme);
		if(!DPchek_clr_tbl(me->file_nme) || file_len == 0)
		{
			me->valid_name = FALSE;
	    		ex$message( msgnumb = GR_E_FlNotFnd,
					buff = buf);

		  	status = FIfld_set_text (me->forms[0].form_ptr,MSG_AREA,
						0,0,buf,0);
		}
		else
                {
			me->valid_name = TRUE;
		  	status = FIfld_set_text (me->forms[0].form_ptr,MSG_AREA,
						0,0,"",0);
		}
		break;

        case IGE_FILE_TYPE :

		break;

        case IGDS_FILE_TYPE :

		break;
#ifndef IDRAW
        case CANVAS_FILE_TYPE :

		break;
#endif
  	case EXIT_BUTTON :	

	 	  status = FIg_set_state_off(me->forms[0].form_ptr,
								EXIT_BUTTON);

	  	  status = FIg_get_state(me->forms[0].form_ptr,IGE_FILE_TYPE,&chk_state);

		  if (chk_state)
		  {
			me->type_of_file = IGE_COLORS; 
		  }
		  else
		  {
			me->type_of_file = IGDS_COLORS; 
		  }
	  	  status = FIg_get_state(me->forms[0].form_ptr,CANVAS_FILE_TYPE,&chk_state);

	    if (chk_state)
	    {
		_move_on;
	    }
	    else
	    {
		if (me->valid_name)
		{
		    me->ld_clr_tbl = TRUE;
                    dp$codpb_get_cct_data(cct_flags = &flags,ctable_filename=filename);
                    if (me->type_of_file==IGE_COLORS)
                         flags = flags & (~CCT_FILE_TYPE);
                    else
                         flags = flags | CCT_FILE_TYPE;
                    strcpy(filename,me->file_nme);
                    dp$codpb_set_cct_data(cct_flags = flags,ctable_filename= filename);
                    
		}
	    	_put_response(resp = FORM_FINISHED);
	    }
 	    status = om$send(targetid = my_id,
			msg = message CEO.erase_form_by_label
					( 0,0,&sts));
            
	     break;
	
	case QUIT_BUTTON :

	     status = om$send(targetid = my_id,
			msg = message CEO.erase_form_by_label
					( 0,0,&sts));
              me->ld_clr_tbl=FALSE;
              me->valid_name=FALSE;
	      me->type_of_file = FALSE;

	     _put_response(resp = FORM_FINISHED);

	     break;
		
	default :
		
		break;

        }  /* eof switch    */
}

action loadclrtbl
{
	if(me->ld_clr_tbl)
	{
             DPload_clr_tbl(me->file_nme,&me->type_of_file);
	}
}
action ld_can_ctb
{
#ifndef IDRAW
	if (GRrsloadctb((int *)sts,&me->event1.located_object[0].located_obj.objid,
			    &me->event1.located_object[0].located_obj.osnum))
	{
	    ige$configure_color_table();
	}
	dp$erase_hilite (msg=sts,osnum=me->event1.located_object[0].located_obj.osnum);
#endif
}
action save_file
{

	     if(DPsave_clr_tbl(me->file_nme))
             {
	    	ex$message(msgnumb = GR_I_ClTbSv);
             }
	     else
             {
	    	ex$message(msgnumb = GR_I_ClTbSvFl);
	     }
}

action get_file
{
	FILE   *fp;

	*sts = OM_S_SUCCESS;
	OM_BLOCK_MOVE(me->event1.event.keyin,me->file_nme,
		(strlen(me->event1.event.keyin)+1));
	fp = NULL;
        fp = (FILE *)fopen(me->file_nme,"r");
        if(fp) 
        {
	    fclose(fp);
	    *sts = FileExists;
	} 
}
