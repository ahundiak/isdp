/*                                      

$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:33 $
$Locker:  $

                  HScraform - Copy Rendering Attributes

		This command object allows the user to copy phong shading 
	parameters in a variety of ways. For example, one may copy the active 
	shading parameters to elements which the user will be prompted to 
	"locate".  Also, an element located upon bringing up the form may be 
	used as the source from which to copy shading parameters to be used as 
	the active set.

		The parameters may be copied in whole or exclusively. That
	is, certain of the parameters may be turned off to preserve that
	existing parameter in the destination.


HISTORY: 08/07/89	Created as "Copy Shading Parameters"	 Trevor Mink

	 07/02/91	Updated to "Copy Rendering Attributes"   Yvonne Chu 

	 ??/??/92	Updated to "Copy Shading Attributes" 
			All user references to rendering removed.
								Yvonne Chu
*/

class              HScraform
super_class        HSsaraform 
command_string     HSM_M_CopyRenAttr,0,HSCpRnAt
form               "HSRenderAttr",0,0,"-1","-1"
form               "HSSetSurfTex",1,0,590,105
product_name       "$MODEL"
start_state        start

specification

#include <FI.h>
#include "wl.h"
#include "igecolor.h"

#define RGB_XMAX 128
#define RGB_YMAX 128 

instance
	{
	IGRboolean to_other_elements, to_original_element, to_active_parms;

	IGRint MsgNum;
	
	OM_S_OBJID	objid_orig;
	OMuword		osnum_orig;

	/* To which places to copy the current symbology parameters */
		
	/* Whether or not each of the corresponding sliders will be copied  */
	/* to the destination */
	IGRboolean DiffuseToggle, TransToggle, SpecToggle, FinishToggle;
	IGRboolean TextureToggle, ColorToggle;
	}

implementation

#define DISPLAY_COLOR   4008
#define DISPLAY_TEXTURE 4006
#define DRAW_COMPOSITE  4007
#define RESET_COMPOSITE 4009
#define FINISH_MAX       128
#define HS_I_RendImgChanges 0

#define MAIN_FORM          0
#define TEXTURE_FORM       1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alloca.h>

#include <FI.h>

#include "exsysdep.h"
#include "dpgraphics.h"

#ifdef BIG_ENDIAN
#include <fcntl.h>
#endif

#include "HSsara.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "godef.h"

#include "hsmsg.h"
#include "msmacros.h"
#include "msdef.h"

#include "HSsaraform.h"
#include "exmacros.h"
#include "exdef.h"

#include "hsurf.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hstex_table.h"
#include "hstexmacros.h"

#include "dpmacros.h"
#include "grdpbmacros.h"

#include "gr.h"
#include "growner.h"

#include "grgs.h"
#include "grgsmacros.h"

#include "OMminimum.h"
#include "OMmacros.h"
#include "igewindef.h"
#include "igrtypedef.h"
#include "igecolordef.h"
#include "igecolmacros.h"
#include "HSrle.h"
#include "hsanimate.h"
#include "hsmachine.h"
#include "igewindow.h"
#include "igewinmacros.h"


#define COPY_TO_OTHER_ELEMENTS		0x00000001
#define COPY_TO_ACTIVE_PARMS		0x00000002

from GRowner    import GRget_number_components;
from GRowner    import GRget_components;
from GRowner    import GRget_matrix;

#define IS_A_SUBCLASS( sclass, pclass )  \
        (om$is_ancestry_valid( subclassid = sclass, superclassid = pclass ) == OM_S_SUCCESS)


extern OMuword OPP_EMScomposite_class_id;

from GRvg import GRgetsymb, GRchgcolor;

#ifdef X11

/*--- HSwindow_event_routine ------------------------------------------------*/

static void HSwindow_event_routine(label, event, fp)
	int label;
	int event;
	Form fp;
/*
NAME
        HSwindow_event_routine

DESCRIPTION
        Redisplays sphere if form is updated.

PARAMETERS
        label (IN) - gadget label
        event (IN) - form event
        fp (IN)    - form pointer

GLOBALS USED
        none

HISTORY
        ??/??/92    Yvonne Chu
           Created
*/
{
        unsigned int            cmd_oid;
        unsigned short          cmd_os;
	long			msg;

	if (event == FI_DISPLAY)
	{
            FIf_get_cmd_oid_os ( fp, &cmd_oid, &cmd_os );

            om$send (   senderid        = cmd_oid,
                        targetid        = cmd_oid,
                        targetos        = cmd_os,
                        msg             = 
				message HScraform.display_sphere_init(&msg)  );

            om$send (   senderid        = cmd_oid,
                        targetid        = cmd_oid,
                        targetos        = cmd_os,
                        msg             = 
				message HScraform.display_sphere(&msg)  );
	}
}

#endif

state_table
#include "hsmsg.h"
#include "exdef.h"

#define COPY_TO_OTHER_ELEMENTS		0x00000001
#define COPY_TO_ACTIVE_PARMS		0x00000002

#define DISPLAY_TEXTURE 4006
#define DISPLAY_COLOR   4008
#define DRAW_COMPOSITE  4007
#define RESET_COMPOSITE 4009

at wakeup 
	do HS_wakeup

at sleep
	do restore_color_table  /* do this here in case of command stacking */
	do delete_highlight
/*
	do write_msg
*/

at delete
 	do free_buffers	

state *        /* default transitions for all states */
  on EX_DATA       state .
  on EX_BACK_UP    state .
  on EX_RJT_MOVEON state .
  on EX_RESTART    state .

state get_elements
   prompt_key		 	HS_P_Locate
   accept_key			HS_P_Accept
   relocate_key			HS_I_Relocate
   gslocate_spec_prompt1_key	HS_P_AcceptFence
   locate_display		"ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | LC_ACCEPT_CURSOR"
   locate_properties		"LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY"
   locate_owner			"LC_RIGID_OWNER | LC_RIGID_COMP | LC_FLEX_OWNER | LC_FLEX_COMP"
   locate_regex			"LC_REGEX_ON"
   locate_mask			"GRm_DATA | GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_OBJID"
   locate_eligible              "+EMSsurface"
   unhilight_mode		"GRhhd"
   accept_mask			"GRm_DATA | GRm_TEXT_VALUE"
   gslocate_spec_mask		"GRm_DATA | GRm_RESET | GRm_RJT_MOVEON"
   gslocate_spec_mask1		"GRm_DATA | GRm_RESET | GRm_RJT_MOVEON"
   gslocate_num_inputs		1
   filter			gs_locate_noauto

      on EX_STRING.GRst_DEFAULT
	 do process_elements
	 state .

      on EX_DATA or EX_OBJID or EX_STRING
         do process_elements
         do chain_locate
         state .

      on MOVE_ON or EX_RJT_MOVEON
	 state terminate

state form_display
   prompt		""
   filter		wfi

   on MOVE_ON
      do which_state 
         on RETURN_CODE=DISPLAY_COLOR
            do process_color_form
            state .
         on RETURN_CODE=DISPLAY_TEXTURE
	    state texture_form
	 on RETURN_CODE = DRAW_COMPOSITE
	    do display_sphere
	    state .
         on RETURN_CODE = RESET_COMPOSITE
	    do display_sphere_init
	    do display_sphere
	    state .
         on RETURN_CODE = COPY_TO_OTHER_ELEMENTS
            do erase_form	0
            state get_elements
         on RETURN_CODE = COPY_TO_ACTIVE_PARMS
            do set_active_sym
            do erase_form	0
	    do write_msg
	    state terminate
	 on RETURN_CODE = 3
	    do set_active_sym
	    do erase_form	0
	    do write_msg
	    state get_elements
         on RETURN_CODE = 0
	    do erase_form	0
	    do write_msg
            state terminate
      state .

state texture_form
  display_form 1
  filter  wfi
  on MOVE_ON
     do erase_form 1
     do display_sphere
     state form_display
  on ELSE
     state .

state start
   message_key	  	HSM_M_CopyRenAttr
   prompt_key		HS_P_SelectMoveOn
   accept_key		HS_P_SingleAccept
   relocate_key		HS_I_Relocate
   locate_display	"ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | LC_ACCEPT_CURSOR"
   locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_WRITE_ONLY"
   locate_owner		"LC_RIGID_OWNER | LC_RIGID_COMP | LC_FLEX_COMP"
   locate_regex		"LC_REGEX_ON"
   locate_mask		"GRm_DATA | GRm_RJT_MOVEON"
   locate_eligible      "+EMSsubbs"
   unhilight_mode	"GRhhd"
   accept_mask		"GRm_DATA"
   gslocate_spec_mask	"GRm_DATA | GRm_RESET | GRm_RJT_MOVEON"
   gslocate_spec_mask1	"GRm_DATA | GRm_RESET | GRm_RJT_MOVEON"
   gslocate_num_inputs	1
   filter		gs_locate_noauto

      on EX_DATA or EX_OBJID
	 do get_element_sym
	 do set_form_defaults
	 do read_spheres
	 do display_form		0
	 do display_sphere_init
	 do display_sphere
	 state form_display

      on MOVE_ON or EX_RJT_MOVEON
	 do get_active_sym
	 do set_form_defaults
	 do read_spheres
	 do display_form        0
	 do display_sphere_init
	 do display_sphere
	 state form_display

/*--- write_msg -------------------------------------------------------------*/

action write_msg
/*
NAME
	HScraform.write_msg

DESCRIPTION
 	Checks to see which message needs to be displayed. It then displays 
	the appropriate one.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY 
	08/16/89    Trevor Mink
	   Created
*/
{
	if ( me->MsgNum ) 
	{
		ex$message(	msgnumb       = me->MsgNum,
		          	field         = KEYIN_FIELD,
				justification = CENTER_JUS );
		sleep( 3 );
		ex$message( in_buff = "", field = ERROR_FIELD );
		ex$message( in_buff = "", field = KEYIN_FIELD );
		me->MsgNum = 0;
	}
} /* write_msg */

/*--- write_msg_fast --------------------------------------------------------*/

action write_msg_fast
/*
NAME
	HScraform.write_msg_fast

DESCRIPTION
	Same as write_msg except does not sleep.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY 
	??/??/91    Yvonne Chu
	   Created
*/
{
	if ( me->MsgNum ) 
	{
		ex$message(	msgnumb       = me->MsgNum,
		          	field         = KEYIN_FIELD,
				justification = CENTER_JUS );
		ex$message( in_buff = "", field = ERROR_FIELD );
		me->MsgNum = 0;
	}

} /* write_msg_fast */


/*--- delete_highlight ----------------------------------------------------*/

action delete_highlight
/*
NAME
	HScraform.delete_highlight

DESCRIPTION
	Un-highlight highlighted objects.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/92    Steve Rogers
	   Created
*/
{
	IGRlong msg;

	*sts = dp$erase_hilite( msg = &msg );

} /* delete_highlight */

/*--- get_active_sym ------------------------------------------------------*/

action get_active_sym
/*
NAME
	HScraform.get_active_sym

DESCRIPTION
	Gets the active shading parameters from the dpb and places
 	these values in the instance data.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	08/10/89    Trevor Mink
	   Created
*/
{
	Form form_ptr;
        int  msg; 
        long sizbuf, nret;
        struct IGRdisplay disbuf;

	form_ptr = me -> forms[0].form_ptr;
	
	/* Disable the to_original toggle */
	FIg_disable ( form_ptr, TO_ORIGINAL_BOX );

	/* Get shading information from the selected element */
	*sts = hs$get_active_shading_symb( finish = &me->finish,
					   spec_refl = &me->spec_refl,
					   diff_refl = &me->diff_refl,
					   transparency = &me->transparency,
                                           tex_orient = &me->orient,
                                           tex_index = &me->textindex );

        sizbuf = sizeof( struct IGRdisplay );
        gr$get_active_display(  msg     = &msg,
			        sizbuf = &sizbuf,
			        buffer = &disbuf,
			        nret   = &nret );

        me->sph_index = disbuf.color;
	me->from_active = TRUE;

} /* get_active_sym */


/*--- set_active_sym --------------------------------------------------------*/

action set_active_sym
/*
NAME
	HScraform.set_active_sym

DESCRIPTION
	First gets the current active shading parameters from the dpb. 
	It then overwrites the ones indicated by the toggles.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	08/10/89    Trevor Mink
	   Created
*/
{
	IGRint Finish, msg;
	IGRdouble Transparency, spec_reflectance, diff_reflectance;
	IGRuchar Orient;
	unsigned short text_index;
	IGRchar filname[300];
	long sizbuf, nret;
  	struct IGRdisplay disbuf;
	IGRuint flags;

	*sts = hs$get_active_shading_symb(	finish = &Finish,
						spec_refl = &spec_reflectance,
						diff_refl = &diff_reflectance,
						transparency = &Transparency,
						tex_orient = &Orient,
						tex_index = &text_index	);

	/* Set the active specular reflectance */
	if ( me->SpecToggle )
		if ( me->spec_refl != spec_reflectance ) {
			spec_reflectance = me->spec_refl;
			if( me->MsgNum == 0 )
			{
				me->MsgNum = HS_I_RendImgChanges;
			}
		}

	/* Set the active diffuse reflectance */
	if ( me->DiffuseToggle )
		if ( me->diff_refl != diff_reflectance ) {
			diff_reflectance = me->diff_refl;
			if( me->MsgNum == 0 )
			{
				me->MsgNum = HS_I_RendImgChanges;
			}
		}

	/* Set the active finish */
	if ( me->FinishToggle )
		if ( me->finish != Finish ) {
			Finish = me->finish;
			if( me->MsgNum == 0 )
			{
				me->MsgNum = HS_I_RendImgChanges;
			}
		}

	/* Set the active transparency */
	if ( me->TransToggle )
		if ( me->transparency != Transparency ) {
			Transparency = me->transparency;
			me->MsgNum = HS_I_UpdShdWin;
		}
	
	/* Set the active texture orientation and index */
        if ( me->TextureToggle )
        {
	   if ( me->texture_active )
   	   {
                if (me->textfname[0] != NULL)
                {
        	   sprintf(filname, "%s/%s", me->curr_dname, me->textfname);
        	   hs$add_texture_file( filename = filname,
			  	        active = 1,
                   		        index = &me->textindex,
                                        mod_osnum = me->ModuleInfo.md_id.osnum);
		}

		if ( me->textindex != text_index )
		{
			text_index = me->textindex;
			me->MsgNum = HS_I_RendImgChanges;
		}

	   }
   	   else
	   {
 	   	text_index = 0;
 	   }

	   if ( me->orient != Orient )
	   {
	   	Orient = me->orient;
		me->MsgNum = HS_I_RendImgChanges;
	   }
	}
   	else
	{
 	   text_index = me->textindex;
 	}

	flags = 0;
        flags |= me->DiffuseToggle? HS_REND_ATTR_COPY_DIFFUSE:0;
        flags |= me->TransToggle? HS_REND_ATTR_COPY_TRANS: 0;
        flags |= me->SpecToggle? HS_REND_ATTR_COPY_SPECULAR: 0;
        flags |= me->FinishToggle? HS_REND_ATTR_COPY_FINISH: 0;
        flags |= me->TextureToggle? HS_REND_ATTR_COPY_TEXTURE:0;
        flags |= me->ColorToggle ? HS_REND_ATTR_COPY_COLOR: 0;
        flags |= me->to_active_parms? HS_REND_ATTR_COPY_TO_ACTIVE : 0;
	flags |= me->to_original_element? HS_REND_ATTR_COPY_TO_ORIG : 0;
        flags |= me->to_other_elements? HS_REND_ATTR_COPY_TO_OTHER : 0;
        flags |= me->linear_rng? 0 : HS_REND_ATTR_FINISH_RANGE;

        hs$put_shading_flags( rend_attr_flags = &flags );

      	hs$set_active_shading_symb( finish       = &Finish,
	       			    spec_refl    = &spec_reflectance,
	          		    diff_refl    = &diff_reflectance,
	          		    transparency = &Transparency,
		  		    tex_orient   = &Orient,
		  		    tex_index    = &text_index );

	if ( me->ColorToggle )
	{
           sizbuf = sizeof( struct IGRdisplay );
           gr$get_active_display(  msg     = &msg,
                                   sizbuf = &sizbuf,
                                   buffer = &disbuf,
                                   nret   = &nret );

	   if (disbuf.color != me->sph_index)
	   {
		me->MsgNum = HS_I_RendImgChanges;
	        disbuf.color = me->sph_index;

                gr$put_active_display(  msg    = &msg,
                                        sizbuf = &sizbuf,
                                        buffer = &disbuf );
	   }
	}

} /* set_active_sym */


/*--- get_element_sym -------------------------------------------------------*/

action get_element_sym
/*
NAME
	HScraform.get_element_sym	

DESCRIPTION
	Gets the shading parameters from the element selected by the user 
	and places them in the instance data. The object id and its OS
	number are saved in the instance data also.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	08/10/89    Trevor Mink
	   Created
*/
{
	IGRlong             sts;            /* function call return status  */
	IGRlong             msg;            /* GO processing message        */
	IGRint              object_count;
	IGRint              num_ret;
	struct GRobj_env    obj_info;
        struct GRsymbology  symb;

	/* find out how many objects were located */
	sts = gr$gsinqcount(	msg          = &msg,
	                     	count        = &object_count,
	                     	p_chanselect = &me->located_chansel );

	sts = gr$gsget_objects(	msg          = &msg,
				array        = &obj_info,
				size         = sizeof( struct GRobj_env ),
				count        = &num_ret,
				from_obj     = 0,
				to_obj       = 0,
				p_chanselect = &me->located_chansel );

	/* Save the id of the original located object */
	me->objid_orig = obj_info.obj_id.objid;
	me->osnum_orig = obj_info.obj_id.osnum;

	/* Get shading information from the selected element */
	sts = hs$get_element_shading_symb( objid = me->objid_orig,
                                           osnum = me->osnum_orig,
					   finish = &me->finish,
					   spec_refl = &me->spec_refl,
					   diff_refl = &me->diff_refl,
					   transparency = &me->transparency,
					   tex_orient = &me->orient,
					   tex_index = &me->textindex );

        status = om$send( targetid = me->objid_orig,
                          targetos = me->osnum_orig,
                          msg = message GRvg.GRgetsymb(&msg, &symb) );

	me->sph_index = symb.display_attr.color;
	me->from_active = FALSE;       

	/* empty the graphics set channel */
	sts = gr$gsempty(	msg		= &msg,
				p_chanselect	= &me->located_chansel );

} /* get_element_sym */


/*--- chain_locate --------------------------------------------------------*/

action chain_locate
/*
NAME
	HScraform.chain_locate

DESCRIPTION
 	Puts the previous accept data point on the locate stack so that it 
	will be used as the next locate point.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/??    Trevor Mink
	   Created
*/

{
	IGRlong		size;
	IGRlong		msg;
	int		response;

	me->event1.num_id = 0;

	if ( me->event1.response == EX_DATA )
	   {
	   size = sizeof(struct EX_button);
	   response = EX_DATA;
	   }
	else if ( me->event1.response == EX_STRING )
	   {
	   size = GR_MAX_CHAR;
	   response = EX_STRING;
	   }

	ex$putque( msg      = &msg,
	           byte     = &size,
	           response = &response,
	           buffer   = (IGRchar *)&me->event1.event );

	return( OM_S_SUCCESS );
}

/*--- copy_to_element ---------------------------------------------------*/

action copy_to_element( OM_S_OBJID elem_id; OMuword elem_os )
/*
NAME
	HScraform.copy_to_element

DESCRIPTION
	Copies phong shading attributes to element.

PARAMETERS
	elem_id (IN) - object id of element to be copied to
	elem_os (IN) - object os of element to be copied to
	Instance data
	
GLOBALS USED
	none

HISTORY
	??/??/??    Trevor Mink
	   Created
*/
{
	IGRlong             sts;            /* function call return status  */
	IGRlong             msg;            /* GO processing message        */
	IGRuint  	    ii, rgb_value;
	IGRint		    Finish;
	IGRdouble	    spec_reflectance, diff_reflectance, Transparency;
	IGRuchar            Orient;
	unsigned short	    text_index;
	IGRchar  	    filname[300];	
	IGRuint 	    flags;
        struct GRsymbology  symb;
	OMuword             elem_classid;
        struct GRid         *comp_ids;
        struct GRmd_env     master_env;
        IGRint              nret;
        IGRint              size;
        IGRint              buf_size, num_components;

	om$get_classid( objid     = elem_id,
	                osnum     = elem_os,
	                p_classid = &elem_classid );

	if ( IS_A_SUBCLASS(elem_classid, OPP_EMScomposite_class_id) )
	   {
	   num_components = 0;
	   sts = om$send( mode= OM_e_wrt_object,
	                  msg = message GRowner.GRget_number_components( &msg, 
				&num_components ),
	                  senderid = NULL_OBJID,
	                  targetid = elem_id,
	                  targetos = elem_os );

	   /* allocate array for component ids */
	   buf_size = num_components;
           comp_ids = (struct GRid *) 
		alloca( num_components * sizeof( struct GRid) );
	   size = sizeof( struct GRmd_env );
           gr$get_module_env( msg    = &msg,
                              sizbuf = &size,
                              buffer = &master_env,
                              nret   = &nret );

	   sts = om$send( mode = OM_e_wrt_object,
                          msg  = message GRowner.GRget_components( &msg,
	                                                        &master_env,
	                                                        comp_ids,
	                                                        buf_size,
	                                                        &num_components,
	                                                        0, 99999 ),
	                  senderid = NULL_OBJID,
	                  targetid = elem_id,
	                  targetos = elem_os);
	   }
	else
	   {
	   num_components = 1;
	   comp_ids = (struct GRid *) alloca( num_components 
		* sizeof(struct GRid) );
	   comp_ids[0].osnum = elem_os;
	   comp_ids[0].objid = elem_id;
	   }

	for ( ii = 0; ii < num_components; ii++ )
	   {
	   sts = hs$get_element_shading_symb( objid = comp_ids[ii].objid,
	                                      osnum = comp_ids[ii].osnum,
	                                      finish = &Finish,
	                                      spec_refl = &spec_reflectance,
	                                      diff_refl = &diff_reflectance,
	                                      transparency = &Transparency,
	                                      tex_orient = &Orient,
	                                      tex_index = &text_index );

	   /* Change the specular reflectance */
	   if ( me->SpecToggle )
	      if ( me->spec_refl != spec_reflectance )
	         {
	         spec_reflectance = me->spec_refl;
	         if( me->MsgNum == 0 )
	            me->MsgNum = HS_I_RendImgChanges;
	         }

	   /* Change the diffuse reflectance */
	   if ( me->DiffuseToggle )
	      if ( me->diff_refl != diff_reflectance )
	         {
	         diff_reflectance = me->diff_refl;
	         if( me->MsgNum == 0 )
	            me->MsgNum = HS_I_RendImgChanges;
	         }

	   /* Change the finish */
	   if ( me->FinishToggle )
	      if ( me->finish != Finish )
	         {
	         Finish = me->finish;
	         if( me->MsgNum == 0 )
	            me->MsgNum = HS_I_RendImgChanges;
	         }

	   /* Change the texture orientation and index */
	   if ( me->TextureToggle )
	      {
	      if ( me->texture_active )
	         {
	         if (me->textfname[0] != '\0')
	            {
	            sprintf(filname, "%s/%s", me->curr_dname,me->textfname);
	            hs$add_texture_file( filename = filname,
	                                 active = 0,
	                                 index = &me->textindex,
	                                 mod_osnum =  comp_ids[ii].osnum );
	            }

	         if ( me->textindex != text_index )
	            {
	            text_index = me->textindex;
	            if ( me->MsgNum == 0 )
	               me->MsgNum = HS_I_RendImgChanges;
	            }
	         }
	      else
	         {
	         text_index = 0;
	         }

	      if ( me->orient != Orient )
	         {
	         Orient = me->orient;
	         if( me->MsgNum == 0 )
	            me->MsgNum = HS_I_RendImgChanges;
	         }
	      }
	   else
	      {
	      text_index = me->textindex;
	      }

	   /* Change the transparency */
	   if (me->TransToggle)
	      if ( me->transparency != Transparency )
	         {
	         Transparency = me->transparency;
	         me->MsgNum = HS_I_UpdShdWin;
	         }

	   flags = 0;
	   flags |= me->DiffuseToggle ? HS_REND_ATTR_COPY_DIFFUSE : 0;
	   flags |= me->TransToggle ? HS_REND_ATTR_COPY_TRANS : 0;
	   flags |= me->SpecToggle ? HS_REND_ATTR_COPY_SPECULAR : 0;
	   flags |= me->FinishToggle ? HS_REND_ATTR_COPY_FINISH : 0;
	   flags |= me->TextureToggle ? HS_REND_ATTR_COPY_TEXTURE : 0;
	   flags |= me->ColorToggle ? HS_REND_ATTR_COPY_COLOR : 0;
	   flags |= me->to_active_parms ? HS_REND_ATTR_COPY_TO_ACTIVE : 0;
	   flags |= me->to_original_element ? HS_REND_ATTR_COPY_TO_ORIG : 0;
	   flags |= me->to_other_elements ? HS_REND_ATTR_COPY_TO_OTHER : 0;
	   flags |= me->linear_rng ? 0 : HS_REND_ATTR_FINISH_RANGE;

	   hs$put_shading_flags( rend_attr_flags = &flags );

	   sts = hs$set_element_shading_symb( objid = comp_ids[ii].objid,
	                                      osnum = comp_ids[ii].osnum,
	                                      finish     = &Finish,
	                                      spec_refl  = &spec_reflectance,
	                                      diff_refl  = &diff_reflectance,
	                                      transparency = &Transparency,
	                                      tex_orient = &Orient,
	                                      tex_index  = &text_index );

	   if ( me->ColorToggle )
	      {
	      status = om$send( targetid = comp_ids[ii].objid,
	                        targetos = comp_ids[ii].osnum,
	                        msg = message GRvg.GRgetsymb( &msg, &symb) );

	      if (me->sph_index != symb.display_attr.color)
	         {
	         rgb_value = 0;
	         status = om$send( targetid = comp_ids[ii].objid,
	                           targetos = comp_ids[ii].osnum,
	            		   msg = message GRvg.GRchgcolor(&msg, 
					&rgb_value, &me->sph_index) );

	         me->MsgNum = HS_I_UpdShdWin;
	         }
	      }

	   }  /* for ii */

}  /* copy_to_element */


/*--- process_elements ----------------------------------------------------*/

action process_elements
/*
NAME
	HScraform.process_elements

DESCRIPTION
	Get each located object individually and change the appropriate 
	symbology.

PARAMETERS
	Instance dataa	

GLOBALS USED
	none

HISTORY
	??/??/??    Trevor Mink
	   Created
*/
{
	IGRlong          sts;            /* function call return status  */
	IGRlong          msg;            /* GO processing message        */
	IGRuint          i;
	IGRint           object_count;
	IGRint           num_ret;
	struct GRobj_env obj_info;


	/* find out how many objects were located */
	sts = gr$gsinqcount(	msg          = &msg,
	                     	count        = &object_count,
	                     	p_chanselect = &me->located_chansel );

	/* get each located object individually and change the appropriate 
	symbology */

	for ( i = 0; i < object_count; i++ ) {

	   	sts = gr$gsget_objects(	msg          = &msg,
	                           	array        = &obj_info,
	                           	size         = sizeof(struct GRobj_env),
	                           	count        = &num_ret,
	                           	from_obj     = i,
	                           	to_obj       = i,
	                           	p_chanselect = &me->located_chansel );
                

		sts = om$send( msg = message HScraform.copy_to_element( 
				obj_info.obj_id.objid, obj_info.obj_id.osnum ),
	                       	targetid = my_id );

		sts = om$send( targetid = my_id,
				msg = message HScraform.write_msg_fast( &msg ));
	}  /* end: for */

	/* empty the graphics set channel */
	sts = gr$gsempty(	msg		= &msg,
				p_chanselect	= &me->located_chansel );

	return( OM_S_SUCCESS );

} /* process_elements */


/*--- set_form_defaults --------------------------------------------------*/

action set_form_defaults
/*
NAME
	HScraform.set_form_defaults

DESCRIPTION
	Initializes some of the instance data and sets most of the form 
	sliders and toggles to their initial values.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
	??/??/91    Trevor Mink
 	    Copied from HSsaspform.sl
*/
{
	long         msg;
	Form         form_ptr;
	double       percentage;
	IGRuint      flags;
        GRspacenum   tex_os;
	GRobjid      mod_id;

	form_ptr = me -> forms[MAIN_FORM].form_ptr;

	me->transparency *= 100.0;
	me->spec_refl *= 100.0;
	me->diff_refl *= 100.0;

	/* Make correct buttons and text for this form be shown */
	*sts = om$send(	targetid = my_id,
			msg = message HScraform.adjust_form_buttons( &msg ) );

	hs$get_shading_flags( rend_attr_flags = &flags );

	me->DiffuseToggle = flags & HS_REND_ATTR_COPY_DIFFUSE ? TRUE : FALSE;
	me->TransToggle = flags & HS_REND_ATTR_COPY_TRANS ? TRUE : FALSE;
	me->SpecToggle = flags & HS_REND_ATTR_COPY_SPECULAR ? TRUE : FALSE;
	me->FinishToggle = flags & HS_REND_ATTR_COPY_FINISH ? TRUE : FALSE;
	me->TextureToggle = flags & HS_REND_ATTR_COPY_TEXTURE ? TRUE : FALSE;
	me->ColorToggle = flags & HS_REND_ATTR_COPY_COLOR ? TRUE : FALSE;

	if (me->DiffuseToggle) FIg_set_state_off( form_ptr, DIFFUSE_TOGGLE );
	else FIg_set_state_on( form_ptr, DIFFUSE_TOGGLE );

	if (me->TransToggle) FIg_set_state_off( form_ptr, TRANS_TOGGLE );
	else FIg_set_state_on( form_ptr, TRANS_TOGGLE );

	if (me->SpecToggle) FIg_set_state_off( form_ptr, SPECULAR_TOGGLE );
	else FIg_set_state_on( form_ptr, SPECULAR_TOGGLE );

	if (me->FinishToggle) FIg_set_state_off( form_ptr, FINISH_TOGGLE );
	else FIg_set_state_on( form_ptr, FINISH_TOGGLE );

	if (me->TextureToggle) FIg_set_state_off( form_ptr, TEXTURE_TOGGLE );
	else FIg_set_state_on( form_ptr, TEXTURE_TOGGLE );

	if (me->ColorToggle) FIg_set_state_off( form_ptr, COLOR_TOGGLE );
	else FIg_set_state_on( form_ptr, COLOR_TOGGLE );

	me->update_color = FALSE;
	me->hwin_no = 65535;

	me->MsgNum = 0;

	/* Set the slider values on the form */

/*--- Modified to get rid of rendering ---*/
/*
	FIg_set_value( form_ptr, TRANS_SLIDER, me->transparency );
*/
	if (me->transparency > 0.0)
	    FIg_set_state_off(form_ptr, TRANS_SLIDER);
	else
	    FIg_set_state_on(form_ptr, TRANS_SLIDER);

/*----------------------------------------*/

	FIg_set_value( form_ptr, SPECULAR_SLIDER, me->spec_refl );
	FIg_set_value( form_ptr, DIFFUSE_SLIDER, me->diff_refl );

        percentage = (double)(HSexp_to_lin(me->finish));
        me->linear_rng = flags & HS_REND_ATTR_FINISH_RANGE ? FALSE : TRUE;
	if (me->linear_rng)
	{
           FIg_erase( form_ptr, EXP_MIN );
           FIg_erase( form_ptr, EXP_MAX );
           FIg_display( form_ptr, LINEAR_MIN );
           FIg_display( form_ptr, LINEAR_MAX );

           FIg_set_low_value( form_ptr, FINISH_SLIDER, 0.0 );
           FIg_set_high_value( form_ptr, FINISH_SLIDER, 100.0 );
	   FIg_set_value( form_ptr, FINISH_SLIDER, percentage );

	   FIg_set_state_off( form_ptr, RANGE_TOGGLE );
	}
	else
	{
           FIg_erase( form_ptr, LINEAR_MIN );
           FIg_erase( form_ptr, LINEAR_MAX );
           FIg_display( form_ptr, EXP_MIN );
           FIg_display( form_ptr, EXP_MAX );

           FIg_set_low_value( form_ptr, FINISH_SLIDER, 1.0 );
           FIg_set_high_value( form_ptr, FINISH_SLIDER, 128.0 );
	   FIg_set_value( form_ptr, FINISH_SLIDER, (double)me->finish );

	   FIg_set_state_on( form_ptr, RANGE_TOGGLE );
	}

	FIg_activate( form_ptr, FINISH_SLIDER );
	FIg_display( form_ptr, FINISH_SLIDER );

	me->to_active_parms = flags & HS_REND_ATTR_COPY_TO_ACTIVE ? TRUE: FALSE;
	me->to_original_element= flags & HS_REND_ATTR_COPY_TO_ORIG? TRUE: FALSE;
	me->to_other_elements = flags & HS_REND_ATTR_COPY_TO_OTHER? TRUE: FALSE;

	if (me->to_active_parms) FIg_set_state_on( form_ptr, TO_ACTIVE_BOX );
	else FIg_set_state_off( form_ptr, TO_ACTIVE_BOX );

        if ((me->to_original_element) && (!me->from_active))
        {
           FIg_set_state_on( form_ptr,TO_ORIGINAL_BOX );
        }
        else
	{
	   me->to_original_element = FALSE;
           FIg_set_state_off( form_ptr, TO_ORIGINAL_BOX );
	}

	if (me->to_other_elements) FIg_set_state_on( form_ptr, TO_OTHERS_BOX );
	else FIg_set_state_off( form_ptr, TO_OTHERS_BOX );

        me->SR_active  = TRUE;
        me->slider_reset = TRUE;
	me->trans_active_msg = FALSE;
        me->no_transparency = TRUE;
        me->no_texture = TRUE;

        if (percentage < 100/2.0)
        {
          me->no_fin0 = FALSE; me->no_fin1 = TRUE;
        }
        else
        {
          me->no_fin0 = TRUE; me->no_fin1 = FALSE;
        }
        if (me->from_active)
        {
             ex$get_cur_mod(id = &mod_id,osnum = &tex_os);
        }
        else
             tex_os = me->osnum_orig;

        *sts = om$send( targetid = my_id,
                        msg = message HScraform.texture_form_defaults((int *)&msg,tex_os));

#ifdef X11
	FIf_set_window_event_routine(form_ptr, HSwindow_event_routine);
#endif

}  /* set_form_defaults */


/*--- adjust_form_buttons --------------------------------------------------*/

action adjust_form_buttons
/*
NAME
	HScraform.adjust_form_buttons

DESCRIPTION
	Places the appropriate buttons and gadgets on the form.

PARAMETERS
	Instance data

GLOBALS USED
	none

HISTORY
 	08/15/89    Trevor Mink
	   Created
*/
{
	Form form_ptr;

	form_ptr = me -> forms[MAIN_FORM].form_ptr;

	FIg_erase( form_ptr, SARA_TITLE );
	FIg_display( form_ptr, CRA_TITLE );

        FIg_display( form_ptr, COPY_OPTIONS_TEXT);
        FIg_display( form_ptr, TO_ORIGINAL_BOX );
        FIg_display( form_ptr, TO_OTHERS_BOX );
        FIg_display( form_ptr, TO_ACTIVE_BOX );

	FIg_display( form_ptr, TRANS_TOGGLE );
	FIg_display( form_ptr, SPECULAR_TOGGLE );
	FIg_display( form_ptr, DIFFUSE_TOGGLE );
	FIg_display( form_ptr, FINISH_TOGGLE);

        FIg_display( form_ptr, COLOR_TOGGLE );
/*--- Modified to get rid of rendering ---*/
        FIg_erase( form_ptr, TEXTURE_TOGGLE );
/*
        FIg_display( form_ptr, TEXTURE_TOGGLE );
*/
/*----------------------------------------*/

        FIg_display( form_ptr, RANGE_TOGGLE );

} /* adjust_form_buttons */


action form_notification
/*
NAME
	HScraform.form_notification

DESCRIPTION
	This routine is where the Forms Interface sends back data from
 	the user hitting a data point on an object on the form.  The
 	gadget number is returned in the form_data structure.
 	Note: gadget labels are stored in the include file HSsaraform.h

PARAMETERS
	form_label (IN)   - s.e.
        gadget_label (IN) - s.e.
        value (IN)        - value of gadget selected
        form_pointer (IN) - s.e.

GLOBALS USED
	none

HISTORY
	??/??/91    Yvonne Chu
	   Created
*/
{
      IGRlong              sts;
      IGRlong              msg;
      IGRint               VERT;
      Form                 main_form_ptr, texture_form_ptr;
      char                 msgbuf[40], filname[300];
      struct HEADER_BLOCK  hdr;
      FILE                 *fp;

#ifdef BIG_ENDIAN
      int                  fd;
#endif
      int                  vs_num, depth, wno;
      char                 modelpath[256];
      double               percentage, exponent;
      WLuint32		   context_no;
      OMuword		   mod_os;

      main_form_ptr=me->forms[MAIN_FORM].form_ptr;
      texture_form_ptr=me->forms[TEXTURE_FORM].form_ptr;

      switch( form_label )
      {
        case MAIN_FORM:

	   switch ( gadget_label )
	   {
	    case CVRT_TO_WINDOW:

               me->SR_active = FALSE;

               FIf_get_window(form_ptr,&wno);
               if( (WLhwin_no)wno != me->hwin_no )
                   {
                   if( me->hwin_no != 65535 )
                       CMremove_form_from_wl( me->lscreen_no, me->lwin_no, me->context_no );
                
                   me->hwin_no = (WLhwin_no)wno;
                   ex$get_cur_mod( osnum = &mod_os );
                   CMadd_form_to_wl( me->hwin_no,
                                     TRUE, /* Share */
                                     NULL_OBJID,
                                     mod_os,
                                     me->SR_active,
                                     &me->lscreen_no,
                                     &me->context_no,
                                     &me->lwin_no );
                                     
                   WLget_context_depth( me->context_no, &me->color_plane );
                   }

               /*
                *  There was a bunch of code here to get the number of
                *  planes and initialize the RGB colortable.  But since
                *  this is now the normal mode, there is nothing to do (ML)
                */

	       me->init_rgb_called = TRUE;

               status = om$send( targetid = my_id,
                               msg = message HScraform.display_sphere(&msg));
	        break;

	   case TRANS_SLIDER:

/*--- Modified to get rid of rendering ---*/
/*
		me->transparency = value;
*/
		me->transparency = value > 0.0 ? 0.0 : 50.0;
/*----------------------------------------*/

		if (me->no_transparency)
		{
		       me->no_transparency = FALSE;

  		       get_modtype_data("Model",NULL,NULL,NULL,NULL, modelpath);
     		       sprintf(filname, "%s/%s", modelpath,
					"config/spheres/sphtrn.rgb");

		       fp = (FILE*) fopen(filname, "r");
 		       hdr.app_type_code = -1;
 		       hdr.data_type_code = -1;

		       if (fp!=NULL)
		       {
#ifdef BIG_ENDIAN
                          fclose(fp);

                          if ((fd = open(filname, O_RDONLY, 0)) != -1);
                          {
                             HSread_rasterfile_header(&fd, &hdr.data_type_code,
                                &hdr.app_type_code, &hdr.num_cols,
                                &hdr.num_rows);
                             close(fd);
                          }
#else
                          fread(&hdr,sizeof(struct HEADER_BLOCK),1,fp);
                          fclose(fp);
#endif

    	    		  if(hdr.app_type_code==9)
        		     VERT = 0;
    	    		  else
        	             VERT = 1;

	    		  if (hdr.data_type_code == TYPE_27)
			  {
		             fp = (FILE*) fopen(filname, "r");
			     fseek(fp, 1024, 0);

                             HSsphmem_man(&me->sph_trn, SPH_TRN, MEM_GET);

			     HSread_type27(fp,hdr.num_rows,hdr.num_cols,
				 SPH_XMIN,SPH_YMIN,SPH_XMAX,SPH_YMAX,
                                 VERT, me->sph_trn);

			     fclose(fp);
			  }
	    		  else
			  {
			     ex$message( msgnumb = HS_E_NotType27,
				 	 buff = msgbuf );
                             FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
			  }
		       }
	    	       else
	 	       {
			  ex$message( msgnumb = HS_E_FindSphTrn,
				      buff = msgbuf );
                          FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
	               }
		}

		me->trans_active_msg = TRUE;
		me->switch1 = DRAW_COMPOSITE;
		_move_on

		break;

	   case SPECULAR_SLIDER:

		me->spec_refl = value;

		me->switch1 = DRAW_COMPOSITE;
		_move_on

		break;

	   case DIFFUSE_SLIDER:

		me->diff_refl = value;

		me->switch1 = DRAW_COMPOSITE;
		_move_on

		break;

	   case FINISH_SLIDER:

		me->finish = (int)value;

		me->slider_reset = TRUE;

		if (me->linear_rng)		/* linear finish range */
		{
		      percentage = value;
		      exponent = HSlin_to_exp((int)percentage);
		      me->finish = exponent;
		}
		else				/* exponential finish range */
		{
		      me->finish = (int)value;
		}

		if (me->no_fin0 || me->no_fin1)
		{
		      percentage = HSexp_to_lin(me->finish);

		      if (percentage < 100/2.0)
		      {
		        if (me->no_fin0)
			{
			   me->no_fin0 = FALSE;

  			   get_modtype_data("Model",NULL,NULL,NULL,NULL,
								modelpath);
     			   sprintf(filname, "%s/%s", modelpath,
					"config/spheres/sphfin000.rgb");

		           fp = (FILE*) fopen(filname, "r");
 		           hdr.app_type_code = -1;
 		           hdr.data_type_code = -1;

		           if (fp!=NULL)
		           {
#ifdef BIG_ENDIAN
                          fclose(fp);

                          if ((fd = open(filname, O_RDONLY, 0)) != -1);
                          {
                             HSread_rasterfile_header(&fd, &hdr.data_type_code,
                                &hdr.app_type_code, &hdr.num_cols,
                                &hdr.num_rows);
                             close(fd);
                          }
#else
                          fread(&hdr,sizeof(struct HEADER_BLOCK),1,fp);
                          fclose(fp);
#endif

    	    		      if(hdr.app_type_code==9)
        		         VERT = 0;
    	    		      else
        	                 VERT = 1;

	    		      if (hdr.data_type_code == TYPE_27)
			      {
		                 fp = (FILE*) fopen(filname, "r");
				 fseek(fp, 1024, 0);

                                 HSsphmem_man(&me->sph_fin000, SPH_FIN000, 
					MEM_GET);

			         HSread_type27(fp,hdr.num_rows,hdr.num_cols,
                                    SPH_XMIN,SPH_YMIN,SPH_XMAX,SPH_YMAX,
                                    VERT, me->sph_fin000);

				 fclose(fp);
			      }
	    		      else
			      {
			     	 ex$message( msgnumb = HS_E_NotType27,
				 	     buff = msgbuf );
                             	 FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,
					FALSE);
			      }
		           }
	    		   else
			   {
			      ex$message( msgnumb = HS_E_FindSphFin00,
				          buff = msgbuf );
                              FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
			   }
			}
		      }
		      else
		      {
		        if (me->no_fin1)
			{
			   me->no_fin1 = FALSE;

  			   get_modtype_data("Model",NULL,NULL,NULL,NULL,
								modelpath);
     			   sprintf(filname, "%s/%s", modelpath,
					"config/spheres/sphfin100.rgb");

		           fp = (FILE*) fopen(filname, "r");
 		           hdr.app_type_code = -1;
 		           hdr.data_type_code = -1;

		           if (fp!=NULL)
		           {
#ifdef BIG_ENDIAN
                          fclose(fp);

                          if ((fd = open(filname, O_RDONLY, 0)) != -1);
                          {
                             HSread_rasterfile_header(&fd, &hdr.data_type_code,
                                &hdr.app_type_code, &hdr.num_cols,
                                &hdr.num_rows);
                             close(fd);
                          }
#else
                          fread(&hdr,sizeof(struct HEADER_BLOCK),1,fp);
                          fclose(fp);
#endif

    	    		      if(hdr.app_type_code==9)
        		         VERT = 0;
    	    		      else
        	                 VERT = 1;

	    		      if (hdr.data_type_code == TYPE_27)
			      {
		           	 fp = (FILE*) fopen(filname, "r");
			         fseek(fp, 1024, 0);

                                 HSsphmem_man(&me->sph_fin100, SPH_FIN100, 
					MEM_GET);

			         HSread_type27(fp,hdr.num_rows,hdr.num_cols,
                                    SPH_XMIN,SPH_YMIN,SPH_XMAX,SPH_YMAX,
                                    VERT, me->sph_fin100);

				 fclose(fp);
			      }
	    		      else
			      {
			         ex$message( msgnumb = HS_E_NotType27,
				 	     buff = msgbuf );
                                 FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,
					FALSE);
			      }
		           }
	    		   else
			   {
			      ex$message( msgnumb = HS_E_FindSphFin10,
				          buff = msgbuf );
                              FIfld_set_text(form_ptr,STATUS1,0,0,msgbuf,FALSE);
			   }
			}
		      }
		}

		me->switch1 = DRAW_COMPOSITE;
		_move_on

		break;

	   case TO_OTHERS_BOX:

		me->to_other_elements = (me->to_other_elements) ? FALSE : TRUE;
		break;

	   case TO_ORIGINAL_BOX:

		me->to_original_element = (me->to_original_element) ? 
								FALSE : TRUE;
		break;

	   case TO_ACTIVE_BOX:

		me->to_active_parms = (me->to_active_parms) ? FALSE : TRUE;
		break;

	   case TRANS_TOGGLE:

		me->TransToggle = ( me->TransToggle ) ? FALSE : TRUE;
		break;

	   case SPECULAR_TOGGLE:

		me->SpecToggle = ( me->SpecToggle ) ? FALSE : TRUE;
		break;

	   case DIFFUSE_TOGGLE:

		me->DiffuseToggle = ( me->DiffuseToggle ) ? FALSE : TRUE;
		break;

	   case FINISH_TOGGLE:

		me->FinishToggle = ( me->FinishToggle ) ? FALSE : TRUE;
		break;

	   case TEXTURE_TOGGLE:

		me->TextureToggle = ( me->TextureToggle ) ? FALSE : TRUE;
		break;

	   case COLOR_TOGGLE:

		me->ColorToggle = ( me->ColorToggle ) ? FALSE : TRUE;
		break;

	   case RANGE_TOGGLE:

		me->linear_rng= !me->linear_rng;

		if (me->linear_rng)
         	{
	              FIg_get_value(form_ptr, FINISH_SLIDER, &exponent);
		      me->exp_save = exponent;
		      me->slider_reset = FALSE;
	   	      percentage = (double)(HSexp_to_lin((int)exponent));

                      FIg_erase( form_ptr, FINISH_SLIDER );
                      FIg_set_low_value( form_ptr, FINISH_SLIDER, 0.0 );
                      FIg_set_high_value( form_ptr, FINISH_SLIDER, 100.0 );
                      FIg_activate( form_ptr, FINISH_SLIDER );

                      FIg_set_value(form_ptr, FINISH_SLIDER, percentage);
                      FIg_display( form_ptr, FINISH_SLIDER );

                      FIg_erase( form_ptr, EXP_MIN);
                      FIg_erase( form_ptr, EXP_MAX);
                      FIg_display( form_ptr, LINEAR_MIN);
                      FIg_display( form_ptr, LINEAR_MAX);
         	}
         	else
         	{
		      if ( !me->slider_reset )
			exponent = me->exp_save;
  		      else
		      {
	                FIg_get_value(form_ptr, FINISH_SLIDER, &percentage);
	   	        exponent = (double)(HSlin_to_exp((int)percentage));
		      }

                      FIg_erase( form_ptr, FINISH_SLIDER );
                      FIg_set_low_value( form_ptr, FINISH_SLIDER, 1.0 );
                      FIg_set_high_value( form_ptr, FINISH_SLIDER,
                                                        (double)FINISH_MAX );
                      FIg_activate( form_ptr, FINISH_SLIDER );

                      FIg_set_value(form_ptr, FINISH_SLIDER, exponent);
                      FIg_display( form_ptr, FINISH_SLIDER );

                      FIg_erase( form_ptr, LINEAR_MIN);
                      FIg_erase( form_ptr, LINEAR_MAX);
                      FIg_display( form_ptr, EXP_MIN);
                      FIg_display( form_ptr, EXP_MAX);
         	}
		break;

           case TEXTURE:

              me->switch1 = DISPLAY_TEXTURE;
              _move_on
              break;

           case COLOR:

              me->switch1 = DISPLAY_COLOR;
              _move_on
              break;

	   case CANCEL:

	       om$send( msg = message HSsaraform.restore_color_table( &msg ),
	                targetid = my_id );
/*
	       me->switch1 = EXIT;
*/
	       me->switch1 = 0;
	       _move_on
	       FIf_erase( form_ptr );
	       break;

	   case SAVE:

		/* Scale these back down to 0.0 -> 1.0 range */
		me->transparency /= 100.0;
		me->spec_refl  /= 100.0;
		me->diff_refl  /= 100.0;

		me->switch1 = 0;

		if ( me->to_other_elements )
			me->switch1 |= COPY_TO_OTHER_ELEMENTS;

		if ( me->to_active_parms )
			me->switch1 |= COPY_TO_ACTIVE_PARMS;

		if ( me->to_original_element )
		{
			om$send( msg = message HScraform.copy_to_element( 
					me->objid_orig, me->osnum_orig ),
	  			 targetid = my_id );
/*
	                me->switch1 = 0;
*/
		}
		else
		{
			sts = dp$erase_hilite( msg = &msg );
		}

	       om$send( msg = message HSsaraform.restore_color_table( &msg ),
	                targetid = my_id );

	        _move_on;
		FIf_erase( form_ptr );
	        break;

	   }  /* end: switch MAIN_FORM */
	   break;

        case TEXTURE_FORM:

	   status = om$send(targetid = my_id,
		  msg = message HScraform.texture_form_notification(form_label,
		  gadget_label,value,form_ptr));
	   break;
	}

} /* form_notification */
