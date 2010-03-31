class implementation HSdisplmode;



#define CHECK_RETURN_CODES 0
#define TOGGLE_WINDOW	4000

/*#include "hsurf_import.h"*/
#include <stdlib.h>
#include <math.h>
#include "igrtypedef.h"

#include "tools.h"
#include "stdio.h"
#include "OMerrordef.h"
#include "OMtypes.h"
#include "msdef.h"

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
#include "msmacros.h"

#include "FI.h"
#include "HSswdmform.h"
#include "exmacros.h"
#include "exdef.h"

#include "hsurferrpriv.h"
#include "hsmsg.h"
#include "hsmacdef.h"
#include "hswinmacros.h"
#include "hsurf.h"
#include "hsdef.h"
#include "hsmacros.h"

extern OMuword OPP_HSgragad_class_id;


#define _get_window 0
#define _toggle_window 1

method display_shad_symb ( long * sts )
{
  int		  status = OM_S_SUCCESS;

        Form       form_ptr;
        IGRint     display_status;
	IGRint     msg_no = 0;

        form_ptr = me->status_display_form_ptr;
        FIf_is_displayed( form_ptr, &display_status );

        if (!display_status)
	    hs$get_last_styles(	last_shading_style = &me->style,
			  	last_region_style = NULL );

	switch ( me->style )
	   {
	   case HS_STYLE_CONSTANT:

   	      msg_no = HS_P_SelForConst;
	      break;

	   case HS_STYLE_SMOOTH:

	      msg_no = HS_P_SelForSmooth;
	      break;

	   case HS_STYLE_WIREFRAME:

	      msg_no = HS_P_SelForWire;
	      break;

	   case HS_STYLE_RASTER:

	      msg_no = HS_P_SelForRHL;
	      break;

	   case HS_STYLE_FILLED_RASTER :

	      msg_no = HS_P_SelForFRHL;
	      break;

	   }

	ex$message( msgnumb = msg_no, buff=me->prompt );
	ex$message( in_buff=me->prompt, field = PROMPT_FIELD, 
	            justification = RIGHT_JUS );
	quit:
  return OM_S_SUCCESS;
}

method set_form_defaults ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong  msg;
	char     *form_ptr;

	form_ptr = me->status_display_form_ptr;

	/* Make correct buttons and text for this form be shown */
	FIg_erase( form_ptr, DR_TITLE );
	FIg_display( form_ptr, SWDM_TITLE );

	FIg_erase( form_ptr, STEREO_TOG );

	/* update the check marks to reflect the instance variable */
	*sts = om$send( targetid = my_id,
                msg = message HSdisplmode.set_check_marks( &msg ) );

	quit:
  return OM_S_SUCCESS;
}

method set_check_marks ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRlong		msg;
	Form		form_ptr;	

        form_ptr = me->status_display_form_ptr;

	if (me->style == HS_STYLE_CONSTANT)
	   FIg_set_state_on( form_ptr, CONST_CYL );
	else
	   FIg_set_state_off( form_ptr, CONST_CYL);

	if (me->style == HS_STYLE_SMOOTH)
	   FIg_set_state_on( form_ptr, SMOOTH_CYL );
	else
	   FIg_set_state_off( form_ptr, SMOOTH_CYL );

	if (me->style == HS_STYLE_RASTER)
	   FIg_set_state_on( form_ptr, RAST_CYL );
	else
	   FIg_set_state_off( form_ptr, RAST_CYL );

	if (me->style == HS_STYLE_FILLED_RASTER)
	   FIg_set_state_on( form_ptr, RVRAST_CYL );
	else
	   FIg_set_state_off( form_ptr, RVRAST_CYL );

	if (me->style == HS_STYLE_WIREFRAME)
	   FIg_set_state_on( form_ptr, WIRE_CYL );
	else
	   FIg_set_state_off( form_ptr, WIRE_CYL );

	if (!me->save_restore)
           status = om$send( targetid = my_id,
                          msg = message HSdisplmode.display_shad_symb(&msg) );

	quit:
  return OM_S_SUCCESS;
}

method adjust_form_buttons ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

	IGRlong  msg;
	char     *form_ptr;

	form_ptr = me->status_display_form_ptr;

	switch ( gadget_label )
	   {
	   case CVRT_TO_WINDOW:

	      me->save_restore = FALSE;

	      status = om$send( targetid = my_id,
	       	          msg = message HSdisplmode.display_shad_symb(&msg));
	      break;

	   case CONST_CYL:

	      me->style = HS_STYLE_CONSTANT;

	      status = om$send( targetid = my_id,
	       	          msg      = message HSdisplmode.set_check_marks(&msg));
	      break;

	   case SMOOTH_CYL:

	      me->style = HS_STYLE_SMOOTH;

	      status = om$send( targetid = my_id,
		          msg      = message HSdisplmode.set_check_marks(&msg));
	      break;
      
	   case WIRE_CYL:

	      me->style = HS_STYLE_WIREFRAME;

	      status = om$send( targetid = my_id,
		          msg      = message HSdisplmode.set_check_marks(&msg));
	      break;

	   case RAST_CYL:

	      me->style = HS_STYLE_RASTER;

	      status = om$send( targetid = my_id,
		          msg      = message HSdisplmode.set_check_marks(&msg));
	      break; 

	   case RVRAST_CYL:

	      me->style = HS_STYLE_FILLED_RASTER;

	      status = om$send( targetid = my_id,
		          msg      = message HSdisplmode.set_check_marks(&msg));
	      break;

	   case CANCEL:

	     FIg_set_state_off( form_ptr, SAVE );
	     FIg_set_state_off( form_ptr, CANCEL );

	     hs$get_last_styles(last_shading_style = &me->style,
			  	last_region_style = NULL );

             _put_response( resp=EX_FORM_FINISHED );
	     FIf_erase( form_ptr );
	     break;

	   case SAVE:

	     hs$set_last_styles( last_shading_style = &me->style, 
				 last_region_style = NULL);

	     FIg_set_state_off( form_ptr, SAVE );
	     FIg_set_state_off( form_ptr, CANCEL );

             _put_response( resp=EX_FORM_FINISHED );
	     FIf_erase( form_ptr );
	     break;

	   }  /* end: switch */

	quit:
  return OM_S_SUCCESS;
}

method update_display_mode ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRint		     msg;
	OMuword              classid;
        IGRint               ii;
	struct var_list	     hs_var_list[2];
	IGRlong		     ret_bytes;
	IGRlong		     which_error;
	struct HStotal_window_instance	total_instance;
	Form		     form_ptr;
        int		     display_status;
 
	*sts = 0;

	form_ptr = me->status_display_form_ptr;
	FIf_is_displayed( form_ptr, &display_status ); 

	if (!display_status)	/* form is not up */	
          hs$get_last_styles(   last_shading_style = &me->style,
				last_region_style = NULL);

	for ( ii = 0; ii < me->num_win_ids; ii++ )
	   {
	   om$get_classid( p_classid = &classid,
	                   objid     = me->win_ids[ii].objid,
	                   osnum     = me->win_ids[ii].osnum );

	   /* check if original display mode is shading */

	   if ( om$is_ancestry_valid( subclassid = classid,
	               superclassid = OPP_HSgragad_class_id ) == OM_S_SUCCESS )
	      {
	      /* check if new display mode is wireframe */

	      if ( me->style == HS_STYLE_WIREFRAME )
		{

	   	/* window display mode changed from shading to wireframe */

	        hs$convert_shading_window_to_wireframe( msg = &msg,
	                                      win_id = me->win_ids[ii].objid,
	                                      win_os = me->win_ids[ii].osnum );
		}
	      else
		{
	   	/* update shading window if shading style is changed */

        	hs_var_list[0].var             = HS_TOTAL_INSTANCE;
        	hs_var_list[0].var_ptr         = (IGRchar *) &total_instance;
        	hs_var_list[0].num_bytes       = sizeof( struct HStotal_window_instance);
        	hs_var_list[0].bytes_returned  = &ret_bytes;
        	hs_var_list[1].var             = END_PARAM;

	   	hs$get_window_instance_data( msg = &msg,
	                                win_id = me->win_ids[ii].objid,
	                                win_os = me->win_ids[ii].osnum,
	                                which_error = &which_error,
	                                var_list = hs_var_list );

		if( total_instance.shading_style == me->style )
		  {
        	       if (me->num_win_ids > 1)
		       {
           	           *sts=0;
		           ex$message( msgnumb = HS_I_DsMdUnChg, 
				field = ERROR_FIELD );
		           sleep(2);
		       }
        	       else
		       {
           		   *sts=TOGGLE_WINDOW;
		       }
		  }
		else
		  {
	   	  total_instance.shading_style = me->style;

	   	  hs$set_window_instance_data( msg = &msg,
	                                win_id = me->win_ids[ii].objid,
	                                win_os = me->win_ids[ii].osnum,
	                                which_error = &which_error,
	                                var_list = hs_var_list );

		  dp$gen_update( msg   = &msg,
	                   	 osnum = me->win_ids[ii].osnum,
	                   	 objid = me->win_ids[ii].objid );

		  } /* else update shading window if style is changed */	

		} /* else new display mode is shading */

	      } /* if original display mode is shading */

	   else /* original display mode is wireframe */
	      {
	      /* check if new display mode is shading */

	      if ( me->style != HS_STYLE_WIREFRAME )
	        {
	        hs$convert_wireframe_window_to_shading( msg = &msg,
	                                     win_id = me->win_ids[ii].objid,
	                                     win_os = me->win_ids[ii].osnum,
					     shading_style = me->style );
	 	}
	      else
		{
		  ex$message( msgnumb = HS_I_DsMdUnChg, field = ERROR_FIELD );
		  sleep(2);
		}
	      }  /* end: else (not a VE window) */

	   } /* for ii=0 ii<me->num_win_ids */

	quit:
  return OM_S_SUCCESS;
}

method cvrt_to_wireframe ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	IGRint msg;

	hs$convert_shading_window_to_wireframe( msg = &msg,
	                                     win_id = me->win_ids[0].objid,
	                                     win_os = me->win_ids[0].osnum );
	quit:
  return OM_S_SUCCESS;
}

method print_message ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	ex$message( msgnumb = HS_I_DsMdUnChg, field = ERROR_FIELD );
	sleep(2);
	quit:
  return OM_S_SUCCESS;
}

method initialize_instance ( long * sts )
{
  int		  status = OM_S_SUCCESS;

	me->save_restore = TRUE;
	quit:
  return OM_S_SUCCESS;
}

end implementation HSdisplmode;
