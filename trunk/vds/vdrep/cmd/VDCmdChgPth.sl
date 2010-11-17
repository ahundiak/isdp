/* $Id: VDCmdChgPth.sl,v 1.3.4.1 2003/08/25 17:57:07 ylong Exp $  */
/*-------------------------------------------------------------------------*
 * I/VDS
 *
 * File:        VDCmdChgPth.sl
 *
 * Description:
 *
 *	COB Command Object to Changing Element Path. 
 *
 * Dependencies:
 * 	None.
 *
 * Revision History:
 *	$Log: VDCmdChgPth.sl,v $
 *	Revision 1.3.4.1  2003/08/25 17:57:07  ylong
 *	Fix for TR7926
 *
 *	Revision 1.3  2001/10/24 21:12:04  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/19 23:01:12  jayadev
 *	*** empty log message ***
 *	
# Revision 1.1  2000/05/11  15:20:26  pinnacle
# Created: vds/vdrep/cmd/VDCmdChgPth.sl by rchennup for Service Pack
#
# Revision 1.2  1999/10/14  15:16:46  pinnacle
# tr179900803
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/26  09:17:46  pinnacle
# Replaced: vdrep/cmd/VDCmdChgPth.sl for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1996/04/15  04:58:32  pinnacle
# Replaced: vdrep/cmd/VDCmdChgPth.sl for:  by rgade for vds.240
#
# Revision 1.7  1996/04/02  05:13:58  pinnacle
# Replaced: vdrep/cmd/VDCmdChgPth.sl for:  by rgade for vds.240
#
# Revision 1.6  1996/03/08  23:32:40  pinnacle
# Replaced: ./vdrep/cmd/VDCmdChgPth.sl for:  by azuurhou for vds.240
#
# Revision 1.3  1996/02/05  07:19:30  pinnacle
# Replaced: vdrep/cmd/VDCmdChgPth.sl for:  by rchennup for vds.240
#
# Revision 1.2  1995/08/10  05:36:34  pinnacle
# Replaced: vdrep/cmd/VDCmdChgPth.sl for:  by msbraju for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/19/92        Jim Hanson      ch_el_path.u
 *      04/05/94        Yuhang Zhu      change .u file to COB file
 *	08/10/95	Ravi		Added EX_STRING case after locate
 *					( fix for TR#179423699 )
 *	03/06/96	adz		Inproper Naming TR#179600841.
 *	04/24/98	vini		TR#179702106
 *	10/11/99	          Ravi	          Added EX_DATA.GRst_KEYPOINT case
 *          ( fix for TR#179900803 )		to handle tentative snap and accept
 *      05/10/00        Jayadev         CR#179901429 
 *      10/24/01        Jayadev         TR#MP 5258 
 *--------------------------------------------------------------------------*/
/****************************************************************************
 *                                                                          *
 *                    class specification area                              *
 *                                                                          *
 ****************************************************************************/
command_string		VDC_M_ChElemPt, 0, VDChElPt
class			VDCmdChgPth
super_class		VDS_LOCATE
command_table		"vds.cmd"
product_name		"$VDS_PATH"

start_state		start
form			"VDChgElePath", 0, 0, "-1", "-1"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
 *          specification area                *
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
specification
/*-----------------------------------------------------------------------+cmd
 * Command Object Class: VDChElPt
 *
 * Superclass
 *     CEO_LOCATE
 *
 * Abstract
 *     A command object used to change the path and symbology of objects.
 *     
 *     User Interface:
 *
 *		1) my_init
 *                 -    display form.
 *		   -	get the current symbology and current working
 *			directory of the design file and set them in the form
 * 
 *		2) start
 *		   -	Give prompt to select objects to modify.
 *
 *			First:	"Locate Element(s) to Change Path"
 *
 *                      After located an object: 
 *                             "Accept(locate next object)/Reject"
 *                        	  --Mid button for accept
 *                          	  --Right button for reject
 *                               
 *			On Accept:
 *                             if no other object:
 *                                "Identify Other Element / Move-on"
 *                                                   
 *		        On MOVE_ON: 
 *			       - set prompt: 
 *                               "Run Form to Change Element(s) Path"
 *
 *			On Reject: "Locate Element(s) to Change Path"
 *
 *		   -    Get object(s) and set them in list.
 *			(object from reference files will not be accepted).
 *
 *		3) form_info
 *		   -	let user to change form information.
 *
 *		        on COPY_ATTRIBUTES:
 *
 *			     goto state copy_info and ask to select object.
 *
 *		        on HILIGHT_SELECTION
 *
 *			     hilight the selected objects.
 *
 *		        on EXECUTE
 *
 *			     run the form information to change the symbology 
 *                           of selected objects and still keep form.
 *
 *		        on ACCEPT
 *
 *			     run the form information to change the symbology 
 *                            of selected objects and erase form.
 *
 *		        on RESET
 *
 *			     reset to default values.
 *
 *		        on CANCEL
 *
 *			     leave the command without any actions.
 *
 *		4) copy_info
 *
 *		   	get a selected object symbology, path and name, set
 *                      in  form and go back state form_info.
 *
 * Design Reference
 *     None
 *
 * Methods
 *     set_prompt	      	Private		change prompts 
 *     my_init			Private 	find default path and symblogy	
 *     locate_process		Private		locate object and fence
 *     run_process              Private         change objects path and symb.
 *     copy_process             Private         get path and symb from object
 *
 * Overridden Methods
 *     form_notification		Manipulate changing path form	
 *
 * Forms
 *     VDcep_FORM_NAME	VDChgElePath     Change layer, color, weight, style
 *                                       path and name of objects
 * Notes/Remarks
 *     Form is erased on state table by using errase form.
 *----------------------------------------------------------------------cmd*/
/* Include files from parent classes:
 * 	CEO_LOCATED:	<igr.h>, <igrdp.h>, <gr.h>, <godef.h>, <griodef.h>
 *       		<go.h>, <grio.h>, <dp.h>, <grdpbdef.h>, <grdpb.h>
 *                      <lcdef.h>, <lc.h>
 *      CEO :		<ODE.h>, <COBstructs.h>,<igetypedef.h>,<exmacros.h> 
 *      super_cmd:   	<OMerrordef.h>, <igrtypedef.h>, <exdef.h>, <ex.h>
 *                      <msdef.h>, <exms.h>, <mamacros.h>
 *      Root:         	<stddef.h>, OMminimum.h, OMprimitives.h   
 */
#include <stdio.h>			/* define standard I/O */
#include "FI.h"                         /* define Form para     */
#include "FEI.h"
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"
#include "nddef.h"
#include "ACrg_collect.h"
#include "acrepdef.h"
#include "VDChElPt.h"			/* define form labels 	*/


instance 
{
    IGRint	         rep_label;	            /* Form return status   */
    struct GRsymbology   defaultsymb; 		    /* default  symbology   */
    variable struct GRid symb_id[0];      	    /* list of located obj  */
    WLuint32             context_no;                /* used for change color*/
    IGRint               copy_flag;                 /* used for copy_process*/
    IGRint               reset_flag;                /* used for FI_RESET    */
    IGRint	 	 pre_weight;                /* pre_weight in form   */
    IGRint               pre_style;                 /* pre_style  in form   */
    IGRint               pre_color;                 /* pre_color  in form   */
    IGRshort		 pre_level;                 /* pre_level  in form   */
    IGRchar		 pre_colorname[VDcep_MAX_TEXT]; /* pre color name   */
    IGRchar 		 pre_layername[VDcep_MAX_TEXT]; /* pre layer name   */
}

/****************************************************************************
 *                                                                          *
 * 			implementation area                                 *
 *                                                                          *
 ****************************************************************************/
implementation

#include <stdio.h>			/* define standard I/O */
#include <string.h>
#include "FI.h"
#include "OMparameters.h"
#include "OMmacros.h"   
#include "OMlimits.h"   
#include "OMprimindex.h"
#include "igrmacros.h"
#include "dpsetdsp.h"    		/* define DPinq_style  */
#include "grdpbmacros.h"		/* define gr$get_active_* macro */
#include "dpmacros.h"                   /* define dp$levels_*              */
#include "coparamac.h"                  /* define as$start_fence           */
#include "grmacros.h"                   /* define gr$get_symbology         */
#include "igrtypedef.h"                 /* needed by igecolmacros.h        */
#include "igecolor.h"                   /* define color parameters         */
#include "OMminimum.h"                  /* needed by igecolmacros.h        */
#include "igewindef.h"                  /* needed by igecolmacros.h        */
#include "igecolordef.h"                /* needed by igecolmacros.h        */
#include "wl.h"                         /* needed by igecolmacros.h        */
#include "igecolmacros.h"               /* define ige$get_abs_color_index  */
#include "DIdef.h"                      /* required by DIprims.h           */ 
#include "DItypedef.h"			/* required by DIprims.h           */
#include "DIglob.h" 			/* required by DIprims.h           */
#include "DIprims.h"			/* define di$pwd di$split, di$cd   */
#include "VDmsg.h"		        /* define commnad key              */
#include "VDmem.h"
#include "VDChElPt.h"                   /* define constant for this code   */
#include "AS_status.h"                  /* define as$status                */

#include "growner.h"
#include "grgsmacros.h"
#include "msdef.h"
#include "exdef.h"
#include "igr.h"
#include "exmacros.h"
#include "ASmessages.h"
#include "AS_debug.h"
#include "VDobj.h"
#include "v_dbgmacros.h"

#define VDcep_DIRECTORY 26 //gadget change: field -> assoc list CR179901429
extern GRclassid OPP_DIrectory_class_id;
/*-----------------------------------------------------------------------*
 * Internal Function  VDSrep_GetActiveSymb
 *
 * Abstract 
 *	get default symbology (active symbology) witch include layer, 
 *      color, weight, style
 *	     
 * Algorithm
 *
 * Note/Remark
 *	This function is used in my_int and form_notification.
 *      gr$get_active_layer and gr$get_active_display are included
 *      in grdpbmacros.h
 *
 * Examples
 *	VDSrep_GetActiveSymb(&me->defaultsymb.display_attr,
 *                           &me->defaultsymb.level) 
 *
 * Returns
 *      OM_S_SUCCESS, MSFAIL
 *
 *-----------------------------------------------------------------------*/
int
VDSrep_GetActiveSymb(
                long    *sts,                       /* input from method */
		struct IGRdisplay *display_attr,    /* output            */
                IGRshort *level)                    /* output            */
{
   IGRlong 	buffersize;

  	buffersize = sizeof( struct IGRdisplay );
  	if (!gr$get_active_display (msg	         = sts,
                                    sizbuf	 = &buffersize,
                                    buffer       = (IGRchar *) display_attr))
        return(MSFAIL);
 
  	buffersize = sizeof( IGRshort );
  	if(! gr$get_active_layer (msg	  = sts,
                                  sizbuf  = &buffersize,
                                  buffer  = (IGRchar *) level))
        return(MSFAIL);

         #ifdef DEBUG
           printf("VDSrep_GetActiveSymb work well \n");
         #endif
  
         return  OM_S_SUCCESS;
}

/* #define  DEBUG    	 1 */
#define  GRCOLOR_OFFSET  10000  /* defined within co/adpco/GRdynclrpal.c */

from	 GRvg            import GRputsymb, GRgetsymb;
from     GRgraphics      import GRgetname;
extern   DB_debug();            /* Function to print debug */
extern   IGRushort 	 dp_bit_pattern[VDcep_MAX_STYLE];
extern   OMuword         OPP_GRreffile_class_id;


/**************************************************************************
 *                          state table area                              *
 **************************************************************************/
state_table

#include "VDSFilter.h"
#include "VDmsg.h"			     /* VDS messages and commands */
#include "VDChElPt.h"			     /* define form labels 	  */

at init		do my_init

state start
	/*
	 * In this state, set message and prompt, ask the user to locate 
         * something, if a reject is the first input, assume it does not work.
	 * if an object is located, go through EX_DATA
         * if an fence is located, go through EX_OBJID
         * on MOVE_ON(not first input), go to state form_info
         */

	message_key		VD_M_ChElemPt
        execute	  		set_prompt
	locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER |
	         		 LC_FLEX_COMP  | LC_FLEX_OWNER  | 
                                 LC_REF_OBJECTS "
	accept			"Accept (locate next object) / Reject" 
	filter  		locate

	on EX_RJT_MOVEON                                
                do return_form( &me->ret) 
                   on RETURN_CODE = VD_FORM_DISPLAY    
							do enable_gadget
								state form_info 
								state . 
  /*************Ravi***********************/
  /**************fix for TR179900803*********************/
  on EX_DATA.GRst_KEYPOINT
          state .

 	on EX_DATA              
	        do locate_process			
					state .   
                                              

	on EX_OBJID   
                do locate_process
                        on ELSE                       	state -
                                                        state terminate

	on GR_UNKNOWN_TYPE.VD_REP_FORM_INFO
		do return_form( &me->ret )
		    on RETURN_CODE = VD_FORM_EXECUTE 	state start
		    on RETURN_CODE = VD_FORM_CANCEL
			do erase_form 0			state terminate
		    on RETURN_CODE = VD_FORM_ACCEPT
			do erase_form 0			state terminate
                                                        state .

	on EX_STRING					state .


state form_info
        /*
         * In this state, set prompt to "Run Form to Change Element(s) Path",
         * ask user to change the path and symbology, if selecting COPY
         * button, goto state copy_infor.
         */
  
	message_key		VD_M_ChElemPt
	prompt_key     		VD_P_ChPtByForm
	dynamics        	off               
	filter          	get_event
	on EX_RJT_MOVEON				state .

	on GR_UNKNOWN_TYPE.VD_REP_FORM_INFO
		do return_form( &me->ret )
		    on RETURN_CODE = VD_FORM_EXECUTE	state start
                    on RETURN_CODE = VD_FORM_CANCEL
		        do erase_form 0			state terminate
	            on RETURN_CODE = VD_FORM_ACCEPT
		        do erase_form 0			state terminate
                    on RETURN_CODE = VD_FORM_COPY 	state copy_info
 							state .

state copy_info
        /*
         * In this state, set prompt as"Identify Another Element to get 
         * Symboloy from", ask user to locate an element for getting 
         * symbology from it, set it to form using copy_process, then go to
         * state form_info.
         */

	message_key      	VD_M_ChElemPt
	prompt           	"Identify Another Element to get Symboloy from"
	dynamics            	off
        accept			"Accept/ Reject" 
	filter               	locate

	on EX_DATA
        	do copy_process
	            on ERROR				state .
	                                                state form_info
        on ELSE                                         state .

/*****************************************************************************
 *                                message area                               *
 *****************************************************************************/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*				METHOD: set_prompt                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
/*-------------------------------------------------------------------------+mi
 * Private Message set_prompt
 *
 * Abstract
 *     It is called at execute keyword and used to change the prompt info
 *     according different conditions.
 *
 * Algorithm
 *     if dimension of me->symb_id = 0, 
 *           prompt = "Locate Element(s) to Change Path"
 *     else
 *           prompt = "Identify Next Element/Move On"
 *
 * Arguments
 *    <Data Type>	<Name>  <I/O>	<Description>
 *
 * Notes/Remarks
 *
 * Examples
 *
 *
 * Status/Return Code 
 *     status == OM_S_SUCCESS	if success;
 *
 *------------------------------------------------------------------------mi*/
action set_prompt
{

  IGRint	nb_list = 0;
  IGRchar	buffer[DI_PATH_MAX];

	  nb_list = om$dimension_of( varray = me->symb_id );
	  if( ! nb_list )
             {
		ex$message( msgnumb = VD_P_SelObChPt,
	 		    buff    = buffer );
	     }  
	  else
             {
	        ex$message( msgnumb = VD_P_NextorMvon,
	 		    buff    = buffer );
	        me->rep_label =  VD_FORM_DISPLAY;
	     }
          status = 
	  om$send(msg      = message CEO.prompt( buffer ),
		  targetid = my_id );
	  as$status( action = RET_STATUS );

	  *sts = OM_S_SUCCESS;
	  goto quit;

} /* end set_prompt */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*			METHOD: my_init  				     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	

action my_init
{
  /*
   * gadget label definition is put in VDChElPt.h
   */
  
  GRobjid	cur_id;                		/* current object id        */
  GRspacenum	cur_os;		          	/* current object space     */
  IGRlong	buffersize, msg;
  IGRint	sel_flag = FALSE;
  IGRint        num_levels;                     /* used for levels change   */
  IGRint        num_color;                      /* used for color change    */
  IGRint        num_style;			/* used for style change    */
  IGRchar	dir_name[DI_PATH_MAX];
  IGRchar	change_int_to_char[DI_PATH_MAX];
  IGRchar       inText[VDcep_MAX_TEXT];
  IGRshort	abs_color;			/* physic color             */
  WLhwin_no	win_no;				/* window number            */
  WLuint16	screen_no; 			/* screen number	    */	
  
  char          **ExpressionNames = NULL, StartDirectory [DI_PATH_MAX];
  char          **dirNames = NULL;
  int           Count = 0,ii,dir_count =0;
  DIgrid        *Grids=NULL;
  GRclassid     ClassId;

        *sts = OM_S_SUCCESS;
        strcpy ( StartDirectory, "." );

  	#ifdef DEBUG
   	   printf( " my_init method \n");
  	#endif
  
  	/*--- find current id and osnum ---*/
	status = ex$get_cur_mod( id    = &cur_id,
                  	         osnum = &cur_os );

	/*--- get current directory name ---*/

	di$pwd(dirname = dir_name);

     	/*--- get default symbology values (active symbology) ---*/
       
	VDSrep_GetActiveSymb( sts,
                              &me->defaultsymb.display_attr,
                              &me->defaultsymb.level);

        /* erase sample gadget */
        FIg_erase ( me->forms[0].form_ptr , VDcep_SAMPLE_LINE); 

	/* disable copy_attributes gadget */
	FIg_disable(me->forms[0].form_ptr, VDcep_COPY_ATTRIBUTES );

   	/*--- set the default display for gadgets ---*/
  	FIg_set_state_on( me->forms[0].form_ptr , VDcep_LAYER_BUTTON  );
  	FIg_set_state_on( me->forms[0].form_ptr , VDcep_COLOR_BUTTON  );
  	FIg_set_state_on( me->forms[0].form_ptr , VDcep_WEIGHT_BUTTON );
  	FIg_set_state_on( me->forms[0].form_ptr , VDcep_STYLE_BUTTON  );
  	FIg_set_state_on( me->forms[0].form_ptr , VDcep_DIR_BUTTON    );
  	FIg_set_state_on( me->forms[0].form_ptr , VDcep_NAME_BUTTON   );

  	/*-----------------------------*/
        /* set default values on form  */
        /*-----------------------------*/

  	/* set weight number */
  	sprintf( change_int_to_char, "%d",me->defaultsymb.display_attr.weight);
  	FIfld_set_text( me->forms[0].form_ptr, VDcep_WEIGHT, 0, 0,
		         	                  change_int_to_char,sel_flag);

  	/* set style number */
  	sprintf( change_int_to_char, "%d",me->defaultsymb.display_attr.style );
  	FIfld_set_text( me->forms[0].form_ptr, VDcep_STYLE, 0, 0,
	         	       		         change_int_to_char,sel_flag );

  	/* set color number */
  	sprintf( change_int_to_char, "%d", me->defaultsymb.display_attr.color);
  	FIfld_set_text( me->forms[0].form_ptr, VDcep_COLOR, 0, 0,
                  		                 change_int_to_char, sel_flag);

  	/* set layer number */
  	sprintf( change_int_to_char, "%d", me->defaultsymb.level);
  	FIfld_set_text( me->forms[0].form_ptr, VDcep_LAYER, 0, 0,
	           		                 change_int_to_char,sel_flag );

  	/* set directory name */
  	FIfld_set_text( me->forms[0].form_ptr, VDcep_DIRECTORY, 0, 0,
	                 	                     dir_name, sel_flag);
/**********             changes for CR179901429 begin           **********/
        UI_status("Finding directories under current working directory");

        di$find (start_dir=StartDirectory, ptr=&Count, lines=&ExpressionNames, grids = &Grids, options = NULL );
        if(Count > 0) {
                dirNames = _MALLOC(Count,char *);
                for(ii=0;ii<Count;ii++)dirNames[ii]= _MALLOC(DI_PATH_MAX,char);

                // find out the DIrectory objects from the expression list
                for(ii=0;ii<Count;ii++)
                {
                   if (om$get_classid ( osnum = Grids [ii].osnum,objid = Grids [ii].objid, p_classid = &ClassId )==OM_S_SUCCESS)
                   if (om$is_ancestry_valid ( superclassid = OPP_DIrectory_class_id, subclassid = ClassId ) == OM_S_SUCCESS)
                        {
                          strcpy(dirNames[dir_count],ExpressionNames[ii]);
                          dir_count++;
                        }
                }
#ifdef DEBUG
  printf("\n count of directories %d \n",dir_count);
  for(ii=0;ii<dir_count;ii++) printf("\n directoryName[%d]= %s \n",ii,dirNames[i
i]);
#endif
                if(dir_count != 0)
                  FIfld_set_list_num_rows( me->forms[0].form_ptr, VDcep_DIRECTORY, 0, dir_count ) ;

          for(ii=0;ii<dir_count;ii++)
            FIfld_set_list_text( me->forms[0].form_ptr, VDcep_DIRECTORY,ii, 0, (unsigned char *) dirNames[ii], FALSE ) ;
        }

/**********             changes for CR179901429 end             **********/
  	/* set VDcep_NAME_ADD_MOVE_TOG button on */
  	FIg_set_state( me->forms[0].form_ptr, VDcep_NAME_ADD_MOVE_TOG, 1);

  	/* get default level name from default level number*/
  	buffersize = VDcep_MAX_TEXT;
  	dp$levels_number_to_name(msg 		   = &msg,
                                 name    	   = inText,
                                 number 	   = me->defaultsymb.level,
                                 ret_num_lev       = &num_levels,
                                 size_name_buffer  = &buffersize,
                                 mod_objid         = cur_id,
                                 osnum             = cur_os);

  	/*--- set the default level name to form ---*/
	FIfld_set_text( me->forms[0].form_ptr, VDcep_LAYER_NAME, 0, 0,
                    		                          inText, sel_flag);
        /*  save previous  level in instance */ 
	strcpy( me->pre_layername,inText);

	/*--- get default color name from default color number ---*/
	buffersize = VDcep_MAX_TEXT;
	status=
	ige$get_name_from_color(color = me->defaultsymb.display_attr.color,
							    name  = inText);
 
	/* ---set the default color name to form ---*/
	FIfld_set_text( me->forms[0].form_ptr, VDcep_COLOR_NAME, 0, 0,
                  	            	                  inText, sel_flag);

        /*  save previous  color in instance */
        strcpy(me->pre_colorname, inText); 

	/*---------------------------*/
        /*    set sample             */
        /*---------------------------*/

        /*---   set sample weight ---*/
        FIg_set_line_weight (me->forms[0].form_ptr, VDcep_SAMPLE_LINE,
                                       me->defaultsymb.display_attr.weight);

 
        /*--- get abs_color ---*/
        FIf_get_window(me->forms[0].form_ptr, &win_no);

        WLget_logical_screen_from_window(win_no, &screen_no);

        CMget_active_context(screen_no, &me->context_no);

        num_color = me->defaultsymb.display_attr.color;

        ige$get_abs_color_index(context_no = me->context_no,
                                log_color  = (IGRshort) num_color,
                                abs_color  = &abs_color);

        num_color = abs_color + GRCOLOR_OFFSET;
 
     	/*--- set sample color ---*/
        FIg_set_color(me->forms[0].form_ptr, VDcep_SAMPLE_LINE, num_color);

   	/*--- get line style ---*/
        num_style = me->defaultsymb.display_attr.style; 
        DPinq_style(num_style,&dp_bit_pattern[num_style]);
 
        /*--- set style field with the corresponding style ---*/
        FIg_set_line_style (me->forms[0].form_ptr, VDcep_SAMPLE_LINE,
                                                 dp_bit_pattern[num_style]);
        
 	/* display sample gadget */
           FIg_display (me->forms[0].form_ptr , VDcep_SAMPLE_LINE);

	/*--- at FI_RESET case, not display form and set array zero---*/	
        if (me->reset_flag != VD_FORM_RESET) 
          {
           /*--- display form ---*/
           FIf_display( me->forms[0].form_ptr); 

           /*--- set the list to zero ---*/
           status = om$vla_set_dimension(varray = me->symb_id,
                                                      size   = 0 );
  	   as$status ( action = RET_STATUS );
          }

        /*--- save previous values in instance ---*/

 	me->pre_weight = me->defaultsymb.display_attr.weight;
        me->pre_style  = me->defaultsymb.display_attr.style;
        me->pre_color  = me->defaultsymb.display_attr.color;
        me->pre_level  = me->defaultsymb.level;

        // free up the memory
        if(ExpressionNames){
                for(ii=0;ii<Count;ii++){
                        _FREE(ExpressionNames[ii]);
                        ExpressionNames[ii] = NULL;
                }
                _FREE(ExpressionNames);
        }
        if(dirNames){
                for(ii=0;ii<Count;ii++){
                        _FREE(dirNames[ii]);
                        dirNames[ii] = NULL;
                }
                _FREE(dirNames);
        }
  	goto quit;

} /* end my_init */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*			METHOD: locate_process 				     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
action locate_process   
/*---------------------------------------------------------------------------*
 *Purpose: get all the located objects' ids and store them into instance     *
 *         symb_id.                                                          *
 *---------------------------------------------------------------------------*/
{
  IGRint            i;				/* index counter	   */
  IGRint            nb_list, nb_objects;	/* fence/list ojects	   */
  struct GRid       *buffer;
  IGRlong   	    size = sizeof(struct GRevent) - sizeof( long )*2; 
                                                /* for chain locate        */
  IGRlong           sts1;                       /* for chain locate        */
  IGRint            response ;		        /* for chain locate        */  
  
  GRclassid             classid;

	/*A Initioalization */


	nb_objects = 0;
	nb_list = 0;

	/* get the fence contents*/

	as$start_fence(set      = &me->event1.located_object[0].located_obj,
		  nb_obj        = &nb_objects,
                  p_obj         = &buffer,
		  response      = me->response, 
		  response_data = me->response_data);
	as$status();

	if ( *me->response != EX_OBJID )
	  {    
            response = *me->response;

	    sts1 = ex$putque( msg      = &sts1,
                              byte     = &size,
                              response = &response,
                              buffer   = (IGRchar *) &me->event1.event);
          }

            /*----------------------------------------------*
             * note: using  me->response, me->response_data *
             *       not  &me->response, &me->response_data *
             * as$start_fence:/usr2/ip32/grnucdp/src/assoc  *
             *                /include_priv/coparamac.h     *
             * where: int *response, char *response_data    *
             *----------------------------------------------*/
  
	/*------------------------------------------------------------------*
         * if any object found.(nb_objects != 0), find the dimention of     *
         * symb_id which is number of elements currently allocated for      *
         * array symb_id .                                                  *
         *------------------------------------------------------------------*/ 
	if ( nb_objects )                     
	  {
            /* find dimension */

						nb_list = 0; //initializing the variable 
            nb_list = om$dimension_of( varray = me->symb_id );
    
            /* increase the list with the new objects. */
  	    nb_objects += nb_list ;
	    status = om$vla_set_dimension(varray = me->symb_id,
                                   size   = nb_objects );
	    as$status ( action = RET_STATUS );

            #ifdef DEBUG
               printf(" at located_process nb_objects = %d, nb_list = %d \n",
                                                        nb_objects, nb_list);
            #endif
 
            /* save the objects in the instance */
            
	    for (i = nb_list; i < nb_objects; i++ )
              {
	    /* Reference files are not allowed -TR179702106*/
	    om$get_classid(  osnum     = buffer[i - nb_list].osnum,
			     objid     = buffer[i - nb_list].objid,
			     p_classid = &classid );

											      if( om$is_ancestry_valid(
			subclassid = classid,
			superclassid = OPP_GRreffile_class_id) == OM_S_SUCCESS )
		{
		  UI_status(" Can not change Path of Reference file"); 
		  ASend_fence(); 
		  status = 0; 
		  goto quit; 
		}

                me->symb_id[i] = buffer[i - nb_list];

	        #ifdef	DEBUG
	           printf(" at located_process symb_id[%d] : %d,%d\n", i, 
                            me->symb_id[i].objid, me->symb_id[i].osnum );
                #endif
              }
          }
	/* free the memory for the fence locate.*/

	ASend_fence();

        status = OM_S_SUCCESS;
        goto quit;

} /* end action locate_process */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*			METHOD: run_process  				     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
action run_process
/*---------------------------------------------------------------------------*/
/*  - get symbologys for each located object, if some of them needed to      */
/*    be changed, get the change values from the form.                       */
/*  - get dirctory name for each located object. if some of them needed      */
/*    to be changed, get value from the form.                                */
/*  - get name of each located object. if it has, use it. otherwise set      */
/*    it as active filename + def. (original code did not consider this case)*/
/*  - get prefix from form if we want to add the prefix                      */
/*    (original code make choise between original name and prefix name, that */
/*     is not same as the discreption on menus                               */
/*                                                                           */
/*---------------------------------------------------------------------------*/

{
  IGRlong            	msg;
  IGRint                sel_flag = FALSE;
  IGRint                pos;
  IGRboolean		LayerState = FALSE,
			ColorState = FALSE,
			WeightState = FALSE,
			StyleState = FALSE,
			DirState = FALSE,
			NameState = FALSE,
			MoveAddState = FALSE;
  IGRint                i, nb_objects;
  IGRint                inState;
  double                value;
  IGRchar		PrefixName[DI_PATH_MAX];
  IGRchar            	objectname[DI_PATH_MAX];
  IGRchar            	dir_name[DI_PATH_MAX];
  IGRchar               working_dir[DI_PATH_MAX];
  IGRchar		path_name[DI_PATH_MAX];
  IGRchar            	grname[DI_PATH_MAX];
  IGRchar            	inText[VDcep_MAX_TEXT];
  IGRchar            	grdir[DI_PATH_MAX];
  struct GRsymbology 	grsymb, symb;
  struct GRid           tempsymb_id;


  	*sts = OM_S_SUCCESS;

        __DBGpr_com(" run_process method : Begin");
	#ifdef	DEBUG
	   printf(" at run_process \n");
	#endif
        *working_dir = '\0';
  	di$pwd(dirname = working_dir);
  	__DBGpr_str(" working_dir ", working_dir);

  	nb_objects = om$dimension_of( varray = me->symb_id );

	#ifdef	DEBUG
	   printf(" at run_process nb_objects = %d\n", nb_objects);
	#endif

  	if ( nb_objects )
    	  {
	    /*--- get values from form ---*/
      	    status =
      	    FIg_get_state(me->forms[0].form_ptr, VDcep_LAYER_BUTTON, 
                                                                &inState );
            __DBGpr_int(" VDcep_LAYER_BUTTON: inState ", inState);

            if( inState == 1 )
              {
                FIfld_get_value(me->forms[0].form_ptr, VDcep_LAYER, 0, 0, 
                                                 &value, &sel_flag, &pos );
                grsymb.level = (int) value;
	        LayerState = TRUE;
                __DBGpr_int(" grsymb.level ", grsymb.level);
                __DBGpr_int(" LayerState ", LayerState); 
              }

            status =
            FIg_get_state(me->forms[0].form_ptr, VDcep_COLOR_BUTTON, 
                                                                &inState );
            __DBGpr_int(" VDcep_COLOR_BUTTON: inState ", inState);

            if( inState == 1 )
              {
                FIfld_get_value(me->forms[0].form_ptr, VDcep_COLOR, 0, 0, 
                                                 &value, &sel_flag, &pos );
                grsymb.display_attr.color = (int) value;
	        ColorState = TRUE;
                __DBGpr_int(" display_attr.color ", grsymb.display_attr.color);
      		__DBGpr_int(" ColorState ", ColorState);
              }

            status =
            FIg_get_state(me->forms[0].form_ptr, VDcep_WEIGHT_BUTTON, 
                                                                 &inState);
            __DBGpr_int(" VDcep_WEIGHT_BUTTON: inState ", inState);

            if( inState == 1 )
              {
                FIfld_get_value(me->forms[0].form_ptr, VDcep_WEIGHT, 0, 0, 
   						 &value, &sel_flag, &pos );
                grsymb.display_attr.weight = (int) value;
	        WeightState = TRUE;
                __DBGpr_int("display_attr.weight ",grsymb.display_attr.weight);
                __DBGpr_int(" WeightState ", WeightState);
              }

            status =
            FIg_get_state( me->forms[0].form_ptr, VDcep_STYLE_BUTTON, 
                                                                 &inState);
            __DBGpr_int(" VDcep_STYLE_BUTTON: inState ", inState);

            if( inState == 1 )
              {
                FIfld_get_value(me->forms[0].form_ptr, VDcep_STYLE, 0, 0,
 						 &value, &sel_flag, &pos );
                grsymb.display_attr.style = (int) value;
	        StyleState = TRUE;
                __DBGpr_int("display_attr.style ", grsymb.display_attr.style);
      		__DBGpr_int(" StyleState ", StyleState);
              }

            status =
            FIg_get_state( me->forms[0].form_ptr, VDcep_DIR_BUTTON, 
                                                                &inState );
            __DBGpr_int(" VDcep_DIR_BUTTON: inState ", inState);

            if( inState == 1 )
              {
                FIfld_get_text (me->forms[0].form_ptr,VDcep_DIRECTORY,0,0,
                                     VDcep_MAX_TEXT,inText,&sel_flag,&pos);
	        strcpy( grdir, inText );
	        DirState = TRUE;

                __DBGpr_str(" grdir ",grdir);
      		__DBGpr_int(" DirState ",DirState);

            	status =
            	FIg_get_state( me->forms[0].form_ptr, VDcep_NAME_BUTTON, 
        							&inState );
                __DBGpr_int(" VDcep_NAME_BUTTON: inState ", inState);

            	if( inState == 1 )
                  {
                    NameState = TRUE;
                    __DBGpr_int(" NameState ",NameState);

                    status =
                    FIg_get_state(me->forms[0].form_ptr,
                                       VDcep_NAME_ADD_MOVE_TOG, &inState );
                    __DBGpr_int(" VDcep_NAME_ADD_MOVE_TOG: inState ", inState);

                    if ( inState == 1)
                      {
                        /*--- remove the names from a sub_system ---*/
                        strcpy( PrefixName, "\0");
		        MoveAddState = TRUE;
                        __DBGpr_int(" MoveAddState ",MoveAddState);
		      }
              	    else
                      {
                        FIfld_get_text(me->forms[0].form_ptr,
                                          VDcep_NAME_PREFIX_TXT, 0, 0,
                                    VDcep_MAX_TEXT,inText,&sel_flag, &pos);
                        strcpy( PrefixName, inText);
                        __DBGpr_str(" PrefixName ",PrefixName);
                      }
	      	  }
              }
          } /* if any objects in list */

        __DBGpr_com(" loop through the list and modify the elements ");

  	/*
   	 *  loop through the list and modify the elements
   	 */
  	for( i = 0; i < nb_objects; i++ )
    	  {

      	    /* set id and osnum to tempsymb_id*/

            tempsymb_id.objid = me->symb_id[i].objid;
            tempsymb_id.osnum = me->symb_id[i].osnum;

            __DBGpr_obj(" Attempting to modify object ", tempsymb_id);

      	    /* get symbology*/
            gr$get_symbology( object_id = &tempsymb_id,
                              symb      = &symb);

            if( LayerState  ) symb.level  = grsymb.level ;
            if( ColorState  ) symb.display_attr.color  
                                            = grsymb.display_attr.color ;
            if( WeightState ) symb.display_attr.weight 
                                            = grsymb.display_attr.weight;
            if( StyleState  ) symb.display_attr.style  
                                            = grsymb.display_attr.style ;
      	    if( DirState )
              {
                /*--- get pathname using GRgetname ---*/
		*path_name  = '\0' ;
		*dir_name   = '\0' ;
		*objectname = '\0' ;
		*inText     = '\0' ;
                __DBGpr_com(" get pathname using GRgetname ");

                status =
                om$send( msg  = message GRvg.GRgetname ( &msg, path_name),
                     targetid = tempsymb_id.objid,
                     targetos = tempsymb_id.osnum);
      		if( !(status&msg&1 ))
      		{ __DBGpr_obj("GRvg.GRgetname failed for ",tempsymb_id);
            	  goto no_name ;
      		}
      		if( !strlen(path_name))
      		{ __DBGpr_obj("GRvg.GRgetname failed for ",tempsymb_id);
      		  goto no_name ;
      		}
                __DBGpr_obj(" object ", tempsymb_id);
      		__DBGpr_str(" path_name ",path_name);

                /* split the pathanme to directory name and objectname*/
                status =
                di$split(pathname  = path_name,
                         dirname   = dir_name,
                         name      = objectname );
		if( !strlen( objectname ))	goto no_name ;
                __DBGpr_str(" dir_name ", dir_name);
      		__DBGpr_str(" objectname ", objectname);

                /*--- change to directory name accepted from form ---*/
                __DBGpr_str(" change to dir name accepted from form ", grdir);
                status = di$cd( dirname = grdir);
                if(!(status&1)) __DBGpr_str(" Failed change to dir ",grdir);

                if (MoveAddState)
             	 {
                   /*--- using previous name ---*/
                   strcpy( grname, objectname);
   
                 }
                else 
                 {
                   /*--- using prefix and increment number as new name ---*/
                   FIfld_get_text(me->forms[0].form_ptr,VDcep_NAME_PREFIX_TXT,
                                0,0, VDcep_MAX_TEXT, inText, &sel_flag, &pos);
                   strcpy( grname, objectname);
                   strcat( inText,grname);
                   strcpy( grname, inText);
  
                 }

                /*--- chnage name of object TR#MP 5258---*/
      		__DBGpr_obj(" change name of object ", tempsymb_id);
      		__DBGpr_str(" grname ", grname);
      		{
        	  IGRchar myBuf[DI_PATH_MAX];
        	  sprintf(myBuf, "%s:%s", grdir, grname  );
        	  __DBGpr_str(" new fullName ", myBuf);

        	  status = vdobj$ChgName( msg     = &msg,
                 	                  objID   = &tempsymb_id,
                                          name    = grname,
                                          keepDir = 0 );
                                          /*
					  name    = myBuf,
                                          keepDir = 1 );
					  */
        	  /*
           	    status =
                	gr$put_name( msg       = &msg,
                   		     object_id = &tempsymb_id,
                   		     name      = myBuf);
         	  */
        	    if( !(status&msg&1)){
                        __DBGpr_int(" Msg ", msg );
                	__DBGpr_int(" Sts ", status );
        	    }
       		}
              } /* if DirState */

no_name:
      
	    /*
             * change working directory back. Acoording menu, the working 
             * dirctory should not be changed. In .u file, it was changed.
             */

            /*
       	     *  erase background and hilight
             */
            gr$display_object(object_id = &tempsymb_id,
                              md_env    = NULL,
                              mode      = GRbehe);

            /*
             * put the symbology back to the obejct.
             */
      	    gr$put_symbology( object_id = &tempsymb_id,
                        symb      = &symb);

            /*
             * display background color
             */
            gr$display_object(object_id = &tempsymb_id,
                              md_env    = NULL,
                              mode      = GRbd);
          } /* end i loop */
   __DBGpr_str(" change working directory back ", working_dir);
   status = di$cd( dirname = working_dir);
   __DBGpr_com(" run_process method : End");

   goto quit;


} /* end action run_process */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*			METHOD: copy_process 				     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/	
action copy_process   
/*---------------------------------------------------------------------------*
 *Purpose:                                                                   *
 *-- to select an existing object and copy this object's                     *
 *symbology to other element being changed to the active                     *
 *path.                                                                      *
 *-- also can get directory name and prefix name if the                      *
 *directory button and prefix button are on                                  *
 *---------------------------------------------------------------------------*/
{
  IGRlong              msg;
  IGRint               inState, i;
  IGRint               sel_flag = TRUE;
  IGRint               buffersize;
  IGRint               num_levels;
  IGRint               active_number; 
  GRobjid	       cur_id;                	/* current object id        */
  GRspacenum	       cur_os;		        /* current object space     */
  IGRchar              inText[VDcep_MAX_TEXT];
  IGRchar              change_int_to_char[VDcep_MAX_TEXT];
  IGRchar              prefix[VDcep_MAX_TEXT];
  IGRchar              dir_name[DI_PATH_MAX];
  IGRchar              objectname[DI_PATH_MAX];
  IGRchar              path_name[DI_PATH_MAX];
  struct GRid          tempsymb_id;
  struct GRsymbology   tempsymb;
  IGRshort 	       abs_color;		/* physic color             */
 
  	*sts = OM_S_SUCCESS;

	*path_name  = '\0' ;
	*prefix     = '\0' ;
	*dir_name   = '\0' ;
	*objectname = '\0' ;
	*inText     = '\0' ;


	#ifdef	DEBUG
  	   printf(" copy process at begining \n");
	#endif

  	/*--- write message to message field ---*/
  	FIfld_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, 0,0,
					 "Identify Element", FALSE);

        /*---get the element id and space number ---*/
  	tempsymb_id.objid = me->event1.located_object[0].located_obj.objid;
  	tempsymb_id.osnum = me->event1.located_object[0].located_obj.osnum;

	#ifdef	DEBUG
	   printf(" at copy_process tempsymb_id: %d,%d\n", 
                                            tempsymb_id.objid,
					    tempsymb_id.osnum );
	#endif
  
  	/*--- get the symbology of the object ---*/
  	gr$get_symbology( object_id = &tempsymb_id,
                      	  symb      = &tempsymb );
  	as$status( action = RET_STATUS );

        /*--- get full path name of object ----*/
  	status =
  	om$send(msg      = message GRvg.GRgetname( &msg, path_name ),
	  	targetid = tempsymb_id.objid,
	  	targetos = tempsymb_id.osnum);

        if( !status )
            {
              /* set message filed as " No Path for This Object " */
              FIfld_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, 0, 0, 
                                      " No Path for This Object", sel_flag);
            }                 

  	/*--- get directory name and object name from pathname ---*/
  	status =
  	di$split (pathname = path_name,
            	  dirname  = dir_name,
            	  name     = objectname );
	if( status != DIR_S_SUCCESS )
        {
    	    printf(" Error in di$split\n");
    	    goto quit;
  	}
  	/*--- set the object symbology to form and grsymb ---*/
	
	#ifdef	DEBUG
  	   printf(" level  = %d \n", tempsymb.level);
  	   printf(" color  = %d \n", tempsymb.display_attr.color);
  	   printf(" weight = %d \n", tempsymb.display_attr.weight);
  	   printf(" style  = %d \n", tempsymb.display_attr.style);
  	   printf(" path   = %s \n", path_name);
  	   printf(" dir    = %s \n", dir_name);
  	   printf(" name   = %s \n", objectname);
	#endif

  	/*--- set level to form ---*/
  	status =
  	FIg_get_state( me->forms[0].form_ptr, VDcep_LAYER_BUTTON, &inState );
 
 	if( inState == 1 )
    	  {
     	    sprintf(change_int_to_char, "%d", tempsymb.level);
     	    FIfld_set_text( me->forms[0].form_ptr, VDcep_LAYER, 0,0,
                                                   change_int_to_char,FALSE);
            /*--- find current id and osnum ---*/
	    status = ex$get_cur_mod( id    = &cur_id,
                  	             osnum = &cur_os );

     	    /*--- get name from level number ---*/
     	    buffersize = VDcep_MAX_TEXT;
     	    dp$levels_number_to_name(msg              = &msg,
                              name    	       = inText,
                              number 	       = tempsymb.level,
                              ret_num_lev      = &num_levels,
                              size_name_buffer = &buffersize,
                              mod_objid        = cur_id,
                              osnum            = cur_os);

           /*--- save layer name in instance ---*/
  
            strcpy( me->pre_layername,inText);
              
     	    FIfld_set_text( me->forms[0].form_ptr, VDcep_LAYER_NAME, 0, 0,
                  		                              inText, FALSE);
    	  }
  	/*--- set color to form ---*/
  	status =
  	FIg_get_state( me->forms[0].form_ptr, VDcep_COLOR_BUTTON, &inState );
  	if( inState == 1 )
    	  {
     	    sprintf(change_int_to_char, "%d", tempsymb.display_attr.color);
     	    FIfld_set_text( me->forms[0].form_ptr, VDcep_COLOR, 0,0,
                                                   change_int_to_char,FALSE);

     	    /*--- get color name from color number---*/
      	    buffersize = VDcep_MAX_TEXT;
     	    status =
     	    ige$get_name_from_color(color = tempsymb.display_attr.color,
                                    name  = inText);

            /*--- save color name in instance ---*/
            strcpy(me->pre_colorname, inText);

      	    /*--- set the color name to form ---*/
     	    if ( status == TRUE )
              {
                FIfld_set_text( me->forms[0].form_ptr, VDcep_COLOR_NAME,0,0,
                                                           inText, sel_flag);
                /*--- set message field ---*/
                FIfld_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, 0, 0, 
                                                               "", sel_flag);
             }       
      	    else
              {
                FIfld_set_text( me->forms[0].form_ptr, VDcep_COLOR_NAME,0,0,
                                                              " ", sel_flag);
                /*--- set message field ---*/
                FIfld_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, 0, 0, 
                                                " No COLOR Name ", sel_flag);
              }       
         
            /*--- erase old sample ---*/
	    FIg_erase(  me->forms[0].form_ptr,VDcep_SAMPLE_LINE  );

       	    /*---  get absolutely color value ---*/
            active_number = tempsymb.display_attr.color;
            status =            
            ige$get_abs_color_index(context_no = me->context_no,
                                    log_color  = (IGRshort) active_number,
                                    abs_color  = &abs_color);
 	    if (!status)
               { 
                printf( " get_abs_color_index fail\n");
	       }

            active_number = abs_color+ GRCOLOR_OFFSET;
            FIg_set_color(me->forms[0].form_ptr, VDcep_SAMPLE_LINE, 
                                                              active_number);

            /*--- display new sample gadget ---*/
            FIg_display(  me->forms[0].form_ptr,VDcep_SAMPLE_LINE  );

       	  }

  	/*--- set weight to form ---*/
  	status =
  	FIg_get_state(me->forms[0].form_ptr, VDcep_WEIGHT_BUTTON, &inState );
  
	if( inState == 1 )
    	  {
     	    sprintf(change_int_to_char, "%d", tempsymb.display_attr.weight);
            FIfld_set_text( me->forms[0].form_ptr, VDcep_WEIGHT,0,0,
                                                   change_int_to_char,FALSE);
 
            /*--- erase old sample ---*/
	    FIg_erase(  me->forms[0].form_ptr,VDcep_SAMPLE_LINE  );

       	    /*---  set sample weight value ---*/
            active_number = tempsymb.display_attr.weight;              
            FIg_set_line_weight ( me->forms[0].form_ptr, 
				           VDcep_SAMPLE_LINE, active_number);

            /*--- display new sample gadget ---*/
            FIg_display(  me->forms[0].form_ptr,VDcep_SAMPLE_LINE  );
          }

  	/*--- about style ---*/
  	status =
  	FIg_get_state( me->forms[0].form_ptr, VDcep_STYLE_BUTTON, &inState );

  	if( inState == 1 )
    	  {
     	    sprintf(change_int_to_char, "%d", tempsymb.display_attr.style);
     	    FIfld_set_text( me->forms[0].form_ptr, VDcep_STYLE, 0,0,
                                                   change_int_to_char,FALSE);
          
            /*--- erase old sample ---*/
	    FIg_erase(  me->forms[0].form_ptr,VDcep_SAMPLE_LINE  );

       	    /*---  change style number to real style index ---*/
            active_number = tempsymb.display_attr.style; 
            DPinq_style(active_number,&dp_bit_pattern[active_number]);
             
            /*--- set style field with the corresponding style ---*/
            FIg_set_line_style (me->forms[0].form_ptr, VDcep_SAMPLE_LINE,
                                              dp_bit_pattern[active_number]);
 
            /*--- display new sample gadget ---*/
            FIg_display(  me->forms[0].form_ptr,VDcep_SAMPLE_LINE  );
     	  }

  	/*--- set the object directory name to form ---*/
   	status =
   	FIg_get_state( me->forms[0].form_ptr, VDcep_DIR_BUTTON, &inState );
   
	if( inState == 1 )
    	  {
            /* using directory name of selected object */
     	    FIfld_set_text( me->forms[0].form_ptr, VDcep_DIRECTORY, 0,0,
                                                          dir_name, FALSE);

     	    /*--- get prefix of the name and set it to form ---*/
     	    status =
     	    FIg_get_state(me->forms[0].form_ptr,VDcep_NAME_BUTTON, &inState);
     	    if( inState == 1 )
              {
                status =
                FIg_get_state( me->forms[0].form_ptr, VDcep_NAME_ADD_MOVE_TOG,
                                                                  &inState );
                if( inState != 1 )
                  {
                    /* get the prefix of the name */

            	    for(i=0; i<VDcep_MAX_TEXT; i = i +1) prefix[i] = 0;
            	    for (i = strlen(objectname) - 1;i >0; i = i - 1)
                      {
                        if(!isdigit(objectname[i])) break;
                      }
            	    strncpy( prefix, objectname, i+1);
            	    FIfld_set_text( me->forms[0].form_ptr, 
                                  VDcep_NAME_PREFIX_TXT, 0, 0,prefix, FALSE);
                  }
                else
                  {
                    /* not set prefix if tog button = 0 */
                    FIfld_set_text( me->forms[0].form_ptr, 
                                      VDcep_NAME_PREFIX_TXT, 0, 0,"", FALSE);
                  }
              }
     	    FIfld_set_text(me->forms[0].form_ptr,FI_MSG_FIELD, 0,0,"",FALSE);
     	  }


        /*--- save previous values in instance ---*/

 	me->pre_weight = tempsymb.display_attr.weight;
        me->pre_style  = tempsymb.display_attr.style;
        me->pre_color  = tempsymb.display_attr.color;
        me->pre_level  = tempsymb.level;

     	#ifdef	DEBUG
          printf(" copy process \n");
        #endif

        /* set flag for copy procee finished */
        me->copy_flag = VD_FORM_COPY_END;
     	goto quit;

} /* end of copy process */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        form_notification function                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action form_notification
/*----------------------------------------------------------------------------*
 * --If following VDcep_*_BUTTON are in the state "on"                        *
 * (default), the user is allowed to change the values.                       *
 * Option of the VDcep_*_BUTTON: on->off  or off->on                          *
 * --if select wrong field values, go back to default                         *
 * value.                                                                     *
 * --if type blank, go back to previous values                                *
 *----------------------------------------------------------------------------*/
{
  IGRint		row = 0;
  IGRint		col = 0;
  IGRint		sel_flag;
  IGRint		pos;
  GRobjid	        cur_id;                	/* current object id        */
  GRspacenum	        cur_os;		        /* current object space     */
  IGRint		use_prevalue;           /* flag for case zeor/blank */
  IGRlong               msg;
  IGRint                active_number;            /* used for macros        */
  IGRshort              active_color; 
  IGRlong               buffersize;
  IGRint                dpnumber;
  IGRint		inState,i;		  /* used for FIg_get_state */
  IGRint                nb_list;
  IGRint 		num_levels;
  IGRlong               sts;
  double	        value;                    /* used for Fig_get_state */
  IGRchar		inText[VDcep_MAX_TEXT];   /* used for FIg_get_text  */
  IGRchar               change_int_to_char[VDcep_MAX_TEXT];
  IGRshort 	        abs_color;		  /* physic color           */
 
	switch ( gadget_label )
       	  {
                                     
     	    case FI_CANCEL:      		 /*--- exit no save ---*/      
              	 dp$erase_hilite (msg = &sts);
              	 me->rep_label = VD_FORM_CANCEL;
              	 _put_response (resp = VD_REP_FORM_INFO);
              	 break;

            case FI_RESET:	/*--- set form using default values ---*/
                      me->reset_flag = VD_FORM_RESET;
                      dp$erase_hilite (msg = &sts);
                      status =
       	              om$send( msg      = message VDCmdChgPth.my_init( &msg ),
                	 mode     = OM_e_wrt_message,
                	 targetid = my_id );
     		      as$status( action = RET_STATUS );

                      if (me->copy_flag == VD_FORM_COPY)
                        {
                         FIg_set_state_on ( form_ptr,VDcep_COPY_ATTRIBUTES);
                        }
                      
              	      me->rep_label = VD_FORM_RESET;
              	      _put_response (resp = VD_REP_FORM_INFO);
      		 break;

	    case FI_EXECUTE: 		/*-- run without erase form --*/
                 if (me->copy_flag != VD_FORM_COPY)
                    {
                      status =
       		      om$send( msg = message VDCmdChgPth.run_process( &msg ),
                	 mode     = OM_e_wrt_message,
                	 targetid = my_id );
       		      as$status( action = RET_STATUS );

		      /*--- set the list to zero ---*/
       		      status = om$vla_set_dimension(varray = me->symb_id,
                           	              size   = 0 );
       		      as$status ( action = RET_STATUS );
                      FIg_set_state_off ( form_ptr,VDcep_COPY_ATTRIBUTES);
                    }

       		  me->rep_label = VD_FORM_EXECUTE;
                  _put_response (resp = VD_REP_FORM_INFO);

       		 break;


     	    case FI_ACCEPT:            	/* run and erase form */
                 if (me->copy_flag != VD_FORM_COPY)
                    {
                      dp$erase_hilite (msg = &sts);
             	      status =
       		      om$send( msg      = message VDCmdChgPth.run_process(&msg),
                	       mode     = OM_e_wrt_message,
                	       targetid = my_id );
                     }
		 me->rep_label = VD_FORM_ACCEPT;
       		 _put_response (resp = VD_REP_FORM_INFO);
        	 break;
 
     	    case VDcep_COPY_ATTRIBUTES:   
                /*--- copy element values to form using copy_process --*/ 
                /*--- here give out the label used in state table   ---*/
       		status =
       		FIg_get_state( form_ptr,VDcep_COPY_ATTRIBUTES, &inState);
                if ( inState == 1 )
                  {
                    me->copy_flag = VD_FORM_COPY;
       		    me->rep_label  = VD_FORM_COPY;
       		    _put_response (resp = VD_REP_FORM_INFO);
                  }
                else
                  {
                    dp$erase_hilite (msg = &sts);
                  }  
         	break;

     	    case VDcep_HILIGHT_SELECTION:
       		status =
       		FIg_get_state( form_ptr,VDcep_HILIGHT_SELECTION, &inState);

       		if( inState == 1)
		  {
              	    nb_list = om$dimension_of( varray = me->symb_id );
                    for (i = 0; i < nb_list; i++)
                      {
		  	gr$display_object( object_id = &me->symb_id[i],
					   md_env    = NULL,
					   mode      = GRhd);
                      }
		  }
       		else
		  {
            	    nb_list = om$dimension_of( varray = me->symb_id );
                    for (i = 0; i < nb_list; i++)
                      {
         	  	gr$display_object( object_id = &me->symb_id[i],
			                   md_env    = NULL,
			                   mode      = GRhe);
                      }
		  }
       		break;

      	    case VDcep_LAYER_BUTTON:
		status =
        	FIg_get_state( form_ptr, gadget_label, &inState );
		
                if( inState == 1 )
         	  {
	  	    /* --- Allow to change layer value used ---
                       --- to defind object path            ---*/
	  	    FIg_display ( form_ptr, VDcep_LAYER );
	  	    FIg_display ( form_ptr, VDcep_LAYER_NAME );
	 	  }
		else
         	  {
	  	    /*--- No change on Layer ---*/
	  	    FIg_erase  ( form_ptr, VDcep_LAYER );
	  	    FIg_erase  ( form_ptr, VDcep_LAYER_NAME );
	 	  }

      	    case VDcep_LAYER:
                       
          	FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", sel_flag);
  
         	FIfld_get_text (form_ptr, VDcep_LAYER, row, col,
                                     VDcep_MAX_TEXT,inText,&sel_flag,&pos);
                if ( inText[0] == '\0')
                         use_prevalue = 1;
                else 
                         use_prevalue = 0;

		/*--- get the level value from form and check value ---*/
        	FIfld_get_value(form_ptr, VDcep_LAYER, 0, 0, &value, 
                                                         &sel_flag, &pos );
  
		if (value >= VDcep_MIN_LAYER && value <= VDcep_MAX_LAYER)
                  {
                    /*--- level value is within ( 0 .. 1023 ) ---*/

                    if ( use_prevalue == 1 )
                        {
                           /* set previous value */
                           value = (double)me->pre_level;
                           FIfld_set_value(form_ptr, VDcep_LAYER, 0, 0, 
                                                             value, sel_flag);
                        }
                        
                    /*--- find current id and osnum ---*/
	            status = ex$get_cur_mod( id    = &cur_id,
                  	                      osnum = &cur_os );
                    /* dp$levels_number_to_name: in grnuc/include/dpmacros.h*/
          	    buffersize = VDcep_MAX_TEXT;
          	    dp$levels_number_to_name(msg         = &msg,
                                             name    	      = inText,
                                             number 	      = (int)value,
                                             ret_num_lev      = &num_levels,
                                   	     size_name_buffer = &buffersize,
                                   	     mod_objid        = cur_id,
                                   	     osnum            = cur_os);

          	    FIfld_set_text(form_ptr, VDcep_LAYER_NAME, 
                                                    0, 0, inText, sel_flag);
                       
         	  }
        	else
         	  {
          	    /*--- level is not in (0 to 1023), give information ---
                      --- in message field and still use the default value-*/
          
          	    FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0,
                         "Invalid Layer Entered, Set Default Value",sel_flag);
                 
                    /*--- get default level ---*/
		    VDSrep_GetActiveSymb( &sts,
                              &me->defaultsymb.display_attr,
                              &me->defaultsymb.level);
                   
                    value = (double) me->defaultsymb.level;
          	    FIfld_set_value( form_ptr,VDcep_LAYER,0,0,
                                                             value, sel_flag);

           	    /*--- find current id and osnum ---*/
	    	    status = ex$get_cur_mod( id    = &cur_id,
                  	                     osnum = &cur_os );
                   
                    buffersize = VDcep_MAX_TEXT;
  	            dp$levels_number_to_name(msg   = &msg,
                                 name    	   = inText,
                                 number 	   = me->defaultsymb.level,
                                 ret_num_lev       = &num_levels,
                                 size_name_buffer  = &buffersize,
                                 mod_objid         = cur_id,
                                 osnum             = cur_os);

	            /*--- set the default level name to form ---*/
	       
          	    FIfld_set_text( me->forms[0].form_ptr, VDcep_LAYER_NAME, 
                                                    0, 0, inText, sel_flag);
        	  }

                /* save previous layer into instance */
                me->pre_level = (int) value;
        	strcpy( me->pre_layername,inText);
        	break;

      	    case VDcep_LAYER_NAME:
	      
          	 FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0,"",sel_flag);
    
         	/*--- get LAYER name and convert it to layer number ---*/
        	FIfld_get_text (form_ptr, VDcep_LAYER_NAME, row, col,
                                        VDcep_MAX_TEXT,inText,&sel_flag,&pos);
  
                if ( inText[0] == '\0')
                      {    
                         use_prevalue = 1;
                         strcpy(inText,  me->pre_layername);
                      }
                else
                       use_prevalue = 0;
                /*--- find current id and osnum ---*/
	        status = ex$get_cur_mod( id    = &cur_id,
                  	                 osnum = &cur_os );
                /*--- get number from level name ---*/
                dpnumber = NULL;
                status=
        	dp$levels_name_to_number (msg       = &msg,
                                  	  name      = inText,
                                  	  number    = &dpnumber,
                                  	  mod_objid = cur_id,
                                          osnum     = cur_os);
                /*--- check if the number is relative to the level name ---*/   
           	if( msg & 1)
                  {
                    /*--- ok to set  layel number  ---*/
         	    sprintf(change_int_to_char, "%d", dpnumber);
        	    FIfld_set_text( form_ptr, VDcep_LAYER, row, col,
                                                 change_int_to_char,sel_flag);

        	    FIfld_set_text( form_ptr, VDcep_LAYER_NAME, row, col,
                                                         inText,sel_flag);

                    value = (double)dpnumber;  
 
                  }
            	else if ( dpnumber == NULL )
                  {
                    /*--- invalid level name ---*/
              	    FIfld_set_text(form_ptr, FI_MSG_FIELD, 0,0,
                            "Invalid Level Name, Set Default Name", sel_flag);
       
                    /*--- get default level ---*/
		    VDSrep_GetActiveSymb( &sts,
                              &me->defaultsymb.display_attr,
                              &me->defaultsymb.level);
                   
                    value = (double) me->defaultsymb.level;
          	    FIfld_set_value( form_ptr,VDcep_LAYER,0,0,
                                                             value, sel_flag);

           	    /*--- find current id and osnum ---*/
	    	    status = ex$get_cur_mod( id    = &cur_id,
                  	                     osnum = &cur_os );
                   
                    buffersize = VDcep_MAX_TEXT;
  	            dp$levels_number_to_name(msg   = &msg,
                                 name    	   = inText,
                                 number 	   = me->defaultsymb.level,
                                 ret_num_lev       = &num_levels,
                                 size_name_buffer  = &buffersize,
                                 mod_objid         = cur_id,
                                 osnum             = cur_os);

	            /*--- set the default level name to form ---*/
	       
          	    FIfld_set_text( me->forms[0].form_ptr, VDcep_LAYER_NAME, 
                                                    0, 0, inText, sel_flag);
       
                  }
                else
                  {
                    /*--- activer level has multiple names ---*/
                    /*   FIfld_set_text(form_ptr, FI_MSG_FIELD, 0,0,
                         " Active layer has multiple names", sel_flag);
                     */                  
                    FIfld_set_text(form_ptr, FI_MSG_FIELD, 0,0,"",sel_flag);
                      
                    /*--- get default level ---*/                  
		    VDSrep_GetActiveSymb( &sts,
                              &me->defaultsymb.display_attr,
                              &me->defaultsymb.level);
                   
                    value = (double) me->defaultsymb.level;
          	    FIfld_set_value( form_ptr,VDcep_LAYER,0,0,
                                                           value, sel_flag);

           	    /*--- find current id and osnum ---*/
	    	    status = ex$get_cur_mod( id    = &cur_id,
                  	                     osnum = &cur_os );
                   
                    buffersize = VDcep_MAX_TEXT;
  	            dp$levels_number_to_name(msg   = &msg,
                                 name    	   = inText,
                                 number 	   = me->defaultsymb.level,
                                 ret_num_lev       = &num_levels,
                                 size_name_buffer  = &buffersize,
                                 mod_objid         = cur_id,
                                 osnum             = cur_os);

	            /*--- set the default level name to form ---*/
	       
          	    FIfld_set_text( me->forms[0].form_ptr, VDcep_LAYER_NAME, 
                                                    0, 0, inText, sel_flag);
 
                  }

                /* save previous layer into instance */
                me->pre_level = dpnumber;
                strcpy( me->pre_layername,inText);
           	break;


      	    case VDcep_COLOR_BUTTON:
		status =
        	FIg_get_state( form_ptr, gadget_label, &inState );
		
		if( inState == 1 )
                  {
	  	    /*---Allow to change color value ---*/
	  	    FIg_display ( form_ptr, VDcep_COLOR );
	  	    FIg_display ( form_ptr, VDcep_COLOR_NAME );
		  }
		else
                  { 
                    /*--- No change on color ---*/
	  	    FIg_erase  ( form_ptr, VDcep_COLOR );
	  	    FIg_erase  ( form_ptr, VDcep_COLOR_NAME );
		  }

      	    case VDcep_COLOR:

                /* to distinguish zero/blank values */    
         	FIfld_get_text (form_ptr, VDcep_COLOR, row, col,
                                     VDcep_MAX_TEXT,inText,&sel_flag,&pos);
                if ( inText[0] == '\0')
                      {    
                         use_prevalue = 1;
                      }
                else
                         use_prevalue = 0;

        	FIfld_get_value (form_ptr, VDcep_COLOR,0,0, &value, 
                                                             &sel_flag,&pos );
                 
		if ((value > VDcep_MIN_COLOR && value <= VDcep_MAX_COLOR)
                    ||( use_prevalue == 1 )) 
         	  {
          	    /*--- color value is within ( 1 to 255) ---*/
                    /*--- get color name from color number ---*/
                              
                    if ( use_prevalue == 1 )
                        {
                           /* set previous value */
                           value = (double)me->pre_color;
                           FIfld_set_value(form_ptr, VDcep_COLOR, 0, 0, 
                                                             value, sel_flag);
                        }
                    
          	    inText[0] = '\0';
          	    buffersize = VDcep_MAX_TEXT;
          	    status = 
          	    ige$get_name_from_color(color = (int) value,
                                  	    name  = inText);

                    /*--- set the color name to form ---*/
          	    if ( status == TRUE )
             	      {
             		FIfld_set_text( form_ptr, VDcep_COLOR_NAME, 0, 0,
                                                            inText, sel_flag);
                        /*-- set message field ---*/
             	        FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", 
                                                                    sel_flag);
             	      }       
          	    else
                      {
              	    	FIfld_set_text( form_ptr, VDcep_COLOR_NAME, 0, 0,
                                                               " ", sel_flag);
                    	/*-- set message field ---*/
             	    	FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, 
                                                         "No Name", sel_flag);
             	      }
       
               	    /*---  get absolutely color ---*/
                    active_number = (int) value;                
                    status =
            	    ige$get_abs_color_index(context_no = me->context_no,
                                log_color  = (IGRshort) active_number,
                                abs_color  = &abs_color);

                    if (!status) 
                        {
                         printf( " get_abs_color_index fail\n");
	                }
                    
                    /*--- erase the old sample gadget ---*/
                    FIg_erase( form_ptr, VDcep_SAMPLE_LINE);           
  
                    /* set sample color */
            	    active_number = abs_color+ GRCOLOR_OFFSET;
           	    FIg_set_color(form_ptr, VDcep_SAMPLE_LINE, active_number);

                    /*--- display teh new sample gadget ---*/
                    FIg_display( form_ptr, VDcep_SAMPLE_LINE);            
         	  }
        	else
                  {
          	    FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0,
                         "Invalid Color Entered, Set Default Value",sel_flag);

                    /* get default color */
                    VDSrep_GetActiveSymb( &sts,
                              &me->defaultsymb.display_attr,
                              &me->defaultsymb.level);
                  
                    value = (double) me->defaultsymb.display_attr.color;
         	    FIfld_set_value( form_ptr,VDcep_COLOR,0,0,
                                                             value,sel_flag);


	           /*--- get default color name from color number ---*/
	           buffersize = VDcep_MAX_TEXT;
	           status=
	           ige$get_name_from_color(
                                   color = me->defaultsymb.display_attr.color,
                                   name  = inText);

	           /*--- set the default color name to form ---*/

          	    FIfld_set_text( me->forms[0].form_ptr, VDcep_COLOR_NAME, 
                                                     0, 0, inText,sel_flag);
   
                    /* change sample */
                    /*               */

               	    /*---  get absolutely color ---*/
                    active_number = me->defaultsymb.display_attr.color;
                    status =
            	    ige$get_abs_color_index(context_no = me->context_no,
                                log_color  = (IGRshort) active_number,
                                abs_color  = &abs_color);

                    if (!status) 
                        {
                         printf( " get_abs_color_index fail\n");
	                }
                    
                    /*--- erase the old sample gadget ---*/
                    FIg_erase( form_ptr, VDcep_SAMPLE_LINE);           
  
                    /* set sample color */
            	    active_number = abs_color+ GRCOLOR_OFFSET;
           	    FIg_set_color(form_ptr, VDcep_SAMPLE_LINE, active_number);

                    /*--- display the new sample gadget ---*/
                    FIg_display( form_ptr, VDcep_SAMPLE_LINE);            
                   
                    /*--- change color name on form---*/   
         
          	    inText[0] = '\0';
          	    status = 
          	    ige$get_name_from_color(
                                   color =me->defaultsymb.display_attr.color,
                                   name  = inText);

           	    FIfld_set_text( form_ptr, VDcep_COLOR_NAME, 0, 0,
                                                            inText, sel_flag);
          	  }
 
                /* save previous color into instance */
                me->pre_color = (int) value;
                strcpy(me->pre_colorname, inText); 
        	break;


	    case VDcep_COLOR_NAME:
              	FIfld_set_text(form_ptr, FI_MSG_FIELD, 0,0, "", sel_flag);

	    	/*--- get COLOR name and convert it to layer number ---*/

             	FIfld_get_text (form_ptr, VDcep_COLOR_NAME, row, col,
                                        VDcep_MAX_TEXT,inText,&sel_flag,&pos);
                if ( inText[0] == '\0')
                      {    
                         use_prevalue = 1;
                         strcpy(inText, me->pre_colorname);
                      }
                else
                         use_prevalue = 0;

            	status =
              	ige$get_color_from_name( color = &active_color,
                                         name  = inText);
                active_number = active_color; 
          	if( status == TRUE)
              	  {
                    /*--- ok to set  color number  ---*/
               	    sprintf(change_int_to_char, "%d", active_number);
                    FIfld_set_text( form_ptr, VDcep_COLOR, row, col,
                                                  change_int_to_char,sel_flag);

                    FIfld_set_text( form_ptr, VDcep_COLOR_NAME, row, col,
                                                              inText,sel_flag);

                    value = (double) active_number;
 
                    /* change sample */
                    /*               */
               	    /*---  get absolutely color ---*/
      
                    status =
            	    ige$get_abs_color_index(context_no = me->context_no,
                                log_color  = (IGRshort) active_number,
                                abs_color  = &abs_color);

                    if (!status) 
                        {
                         printf( " get_abs_color_index fail\n");
	                }
                    
                    /*--- erase the old sample gadget ---*/
                    FIg_erase( form_ptr, VDcep_SAMPLE_LINE);           
  
                    /* set sample color */
            	    active_number = abs_color+ GRCOLOR_OFFSET;
           	    FIg_set_color(form_ptr, VDcep_SAMPLE_LINE, active_number);

                    /*--- display the new sample gadget ---*/
                    FIg_display( form_ptr, VDcep_SAMPLE_LINE);            
                  }
            	else
                  {
                    /*--- invalid color name ---*/
              	    FIfld_set_text(form_ptr, FI_MSG_FIELD, 0,0,
                             "Invalid Color Name, Set Default Name", sel_flag);

                    /*--- set color and name as default value ---*/

                    /* get default color */
                    VDSrep_GetActiveSymb( &sts,
                              &me->defaultsymb.display_attr,
                              &me->defaultsymb.level);
                  
                    value = (double) me->defaultsymb.display_attr.color;
         	    FIfld_set_value( form_ptr,VDcep_COLOR,0,0,
                                                             value,sel_flag);


    	            /*--- get default color name from color number ---*/
	            buffersize = VDcep_MAX_TEXT;
	            status=
	            ige$get_name_from_color(
                                   color = me->defaultsymb.display_attr.color,
                                   name  = inText);

	            /*--- set the default color name to form ---*/

          	    FIfld_set_text( me->forms[0].form_ptr, VDcep_COLOR_NAME, 
                                                     0, 0, inText,sel_flag);
    
                  }

                /* save previous color into instance */
                me->pre_color = (int) value;
                strcpy(me->pre_colorname, inText); 

        	break;


	    case VDcep_WEIGHT_BUTTON:
	    	status =
              	FIg_get_state( form_ptr, gadget_label, &inState );

            	if( inState == 1 )
                  {
	            /*--- Allow to give weight value ---*/
	       	    FIg_display ( form_ptr, VDcep_WEIGHT );
	          }
	    	else
                  {
	            /*--- No change on weight ---*/
	            FIg_erase  ( form_ptr, VDcep_WEIGHT );
	          }
	    	break;

	    case VDcep_WEIGHT:

                /* to distinguish zero/blank values */    
         	FIfld_get_text (form_ptr, VDcep_WEIGHT, row, col,
                                     VDcep_MAX_TEXT,inText,&sel_flag,&pos);
                if ( inText[0] == '\0')
                      {    
                         use_prevalue = 1;
                      }
                else
                         use_prevalue = 0;
            	status = 
                FIfld_get_value (form_ptr, VDcep_WEIGHT, 0, 0, &value, 
                                                            &sel_flag, &pos);

            	if (value >= VDcep_MIN_WEIGHT && value <= VDcep_MAX_WEIGHT)
                  {
                    /*---  weight value is within ( 0 to 31) ---*/
               	    FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", 
                                                                 sel_flag  );
               
                    /*--- erase the old sample gadget ---*/
                    FIg_erase( form_ptr, VDcep_SAMPLE_LINE);           
  
                    /*---  set sample weight value ---*/
       
                    if ( use_prevalue == 1 )
                        {
                           /* set previous value */
                           value = (double)me->pre_weight;
                           FIfld_set_value(form_ptr, VDcep_WEIGHT, 0, 0, 
                                                             value, sel_flag);
                        }
               
                    active_number = (int) value;              
            	    FIg_set_line_weight(form_ptr, VDcep_SAMPLE_LINE, 
                                                              active_number);

                    /*--- display teh new sample gadget ---*/
                    FIg_display( form_ptr, VDcep_SAMPLE_LINE);            
                  }
            	else
                  {
                    FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0,
                       "Invalid Weight Entered, Set Default Value",sel_flag);

 
                    /* get default weight */
                    VDSrep_GetActiveSymb( &sts,
                             &me->defaultsymb.display_attr,
                              &me->defaultsymb.level);

                    value =  (double) me->defaultsymb.display_attr.weight;
               	    FIfld_set_value( form_ptr,VDcep_WEIGHT,0,0,
                                                            value, sel_flag);
                   
                    /*--- change sample ---*/
              
                    /*--- erase the old sample gadget ---*/
                    FIg_erase( form_ptr, VDcep_SAMPLE_LINE);           
  
                    /*---  set sample weight value ---*/
                    active_number = me->defaultsymb.display_attr.weight;
            	    FIg_set_line_weight(form_ptr, VDcep_SAMPLE_LINE, 
                                                              active_number);

                    /*--- display teh new sample gadget ---*/
                    FIg_display( form_ptr, VDcep_SAMPLE_LINE);            
  
                  }
          
                /* save previous weight into instance */
                me->pre_weight = (int) value;
        	break;

   	    case VDcep_STYLE_BUTTON:
		status =
                FIg_get_state( form_ptr, gadget_label, &inState );
	
	       	if( inState == 1 )
                  {
	            /*--- Allow to give style value ---*/
	  	    FIg_display ( form_ptr, VDcep_STYLE );
	  	   
	          }
		else
                  {
	            /*--- No change on style ---*/
	  	    FIg_erase  ( form_ptr, VDcep_STYLE );
                  }
		break;

    	    case VDcep_STYLE:

                /* to distinguish zero/blank values */    
         	FIfld_get_text (form_ptr, VDcep_STYLE, row, col,
                                     VDcep_MAX_TEXT,inText,&sel_flag,&pos);
                if ( inText[0] == '\0')
                      {    
                         use_prevalue = 1;
                      }
                else
                         use_prevalue = 0;
        	FIfld_get_value (form_ptr, VDcep_STYLE,0,0,&value, 
                                                            &sel_flag, &pos);
        	
		if (value >= VDcep_MIN_STYLE && value <= VDcep_MAX_STYLE)
         	  {
                    /*--- style  value is within ( 0 to 255) ---*/
          	    FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0, "", 
                                                                   sel_flag);
               
                    /*--- erase the old sample gadget ---*/
                    FIg_erase( form_ptr, VDcep_SAMPLE_LINE);           
  
                    /*---  set sample style value ---*/
                    if ( use_prevalue == 1 )
                        {
                           /* set previous value */
                           value = (double)me->pre_style;
                           FIfld_set_value(form_ptr, VDcep_STYLE, 0, 0, 
                                                             value, sel_flag);
                        }
                    /*--- erase the old sample gadget ---*/
                    FIg_erase( form_ptr, VDcep_SAMPLE_LINE);           
       
                    active_number = (int) value;              
                    DPinq_style(active_number,&dp_bit_pattern[active_number]);
             
                    /*--- set style field with the corresponding style ---*/
                    FIg_set_line_style (form_ptr, VDcep_SAMPLE_LINE,
                                              dp_bit_pattern[active_number]);
 
                    /*--- display teh new sample gadget ---*/
                    FIg_display( form_ptr, VDcep_SAMPLE_LINE);            
                 }
        	else
         	  {
          	    FIfld_set_text( form_ptr, FI_MSG_FIELD, 0, 0,
                       "Invalid Style Entered, Set Default Value", sel_flag);

                    /* get default style */
                    VDSrep_GetActiveSymb( &sts,
                              &me->defaultsymb.display_attr,
                              &me->defaultsymb.level);
                    
                    value =   (double) me->defaultsymb.display_attr.style;
          	    FIfld_set_value( form_ptr,VDcep_STYLE,0,0,
                                                            value, sel_flag);
                  
                    /* change sample */
                    /*--- erase the old sample gadget ---*/
                    FIg_erase( form_ptr, VDcep_SAMPLE_LINE);           
  
                    /*---  get sample style value ---*/
                    active_number = me->defaultsymb.display_attr.style;    
                    DPinq_style(active_number,&dp_bit_pattern[active_number]);
             
                    /*--- set style field with the corresponding style ---*/
                    FIg_set_line_style (form_ptr, VDcep_SAMPLE_LINE,
                                              dp_bit_pattern[active_number]);
 
                    /*--- display teh new sample gadget ---*/
                    FIg_display( form_ptr, VDcep_SAMPLE_LINE);            
          	  }
          
                /* save previous style into instance */
                me->pre_style = (int) value;
        	break;


      	    case VDcep_DIR_BUTTON:
		status = FIg_get_state( form_ptr, gadget_label, &inState );

		if( inState == 1 )
        	  {
	            /*--- Allow to change directory ---*/
	  	    FIg_display ( form_ptr, VDcep_DIRECTORY );
          	    FIg_display ( form_ptr, VDcep_NAME_BUTTON);
           	    FIg_set_state_on(form_ptr , VDcep_NAME_BUTTON);
          	    FIg_display ( form_ptr, VDcep_NAME_ADD_MOVE_TOG);
	          }
		else
                  {
	  	    /*--- No change on directory ---*/
          	    FIg_erase  ( form_ptr, VDcep_NAME_BUTTON);
	  	    FIg_erase  ( form_ptr, VDcep_DIRECTORY);
          	    FIg_erase  ( form_ptr, VDcep_NAME_ADD_MOVE_TOG);
          	    FIg_erase  ( form_ptr, VDcep_NAME_PREFIX);
          	    FIg_erase  ( form_ptr, VDcep_NAME_PREFIX_TXT);
	 	  }
		break;

      	    case VDcep_DIRECTORY:
                /*--- write directory name in form used by FI_EXECUTE
                  --- or FI_ACCEPT cases                             ---*/
        	break;

      	    case VDcep_NAME_BUTTON:
	        status =
        	FIg_get_state( form_ptr,  gadget_label, &inState );

		if( inState == 1 )
                  {
	            /*--- Allow to change name ---*/
	  	    FIg_display ( form_ptr, VDcep_NAME_ADD_MOVE_TOG );

          	    status =
          	    FIg_get_state( form_ptr, VDcep_NAME_ADD_MOVE_TOG, 
                                                                  &inState );

          	    if(inState == 0)
                      {
             	        FIg_display ( form_ptr,  VDcep_NAME_PREFIX);
             	        FIg_display ( form_ptr,  VDcep_NAME_PREFIX_TXT);
            	      }
	  	    else
            	      {
             	        FIg_erase ( form_ptr,  VDcep_NAME_PREFIX);
                        FIg_erase ( form_ptr,  VDcep_NAME_PREFIX_TXT);
	              }
         	  }
        	else
                  {
	            /*--- No change on directory ---*/
	            FIg_erase ( form_ptr,  VDcep_NAME_ADD_MOVE_TOG);
          	    FIg_erase ( form_ptr,  VDcep_NAME_PREFIX);
          	    FIg_erase ( form_ptr,  VDcep_NAME_PREFIX_TXT);
	  	  }
		break;

      	    case VDcep_NAME_ADD_MOVE_TOG:
        	status =
        	FIg_get_state( form_ptr,VDcep_NAME_ADD_MOVE_TOG, &inState);
     
	   	if(inState == 1)
         	  {
           	    FIg_erase(form_ptr,  VDcep_NAME_PREFIX);
           	    FIg_erase(form_ptr,  VDcep_NAME_PREFIX_TXT);
                  }
        	else
                  {
           	    FIg_display(form_ptr,  VDcep_NAME_PREFIX);
           	    FIg_display(form_ptr,  VDcep_NAME_PREFIX_TXT);
                  }
        	break;

      	    case VDcep_NAME_PREFIX_TXT:
        	/*---  write the prefix in form ---*/
        	break;

      	    default:
        	break;

    	  }  /*end switch gadget _label */

}  /* end switch form_lable */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              return_form method                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action return_form
/*----------------------------------------------------------------------------*
 * status field in CEO_LOCATE to get return value of the
 * routine form_notification; sts is used in state table
 *----------------------------------------------------------------------------*/
{
  	*sts = me->rep_label;
  	status = OM_S_SUCCESS;
  	goto quit;
}

action enable_gadget
{
	FIg_enable(me->forms[0].form_ptr, VDcep_COPY_ATTRIBUTES );
	*sts = OM_S_SUCCESS;
	goto quit;
}

