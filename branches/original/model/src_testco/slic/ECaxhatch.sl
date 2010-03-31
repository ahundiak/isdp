/* #######################    APOGEE COMPILED   ######################## */
command_string  "crosshatch",0,ECaxhatch
class            ECaxhatch
super_class      CEO_GSLOCATE
super_class      COnpt
spec_path        "$GRNUC/co/spec"
product_name     "$GRNUC",2
start_state      terminate

specification


instance
 {
  IGRdouble               save_spacing;
  IGRdouble               save_angle;
  IGRshort                save_color;
  struct GRIOvar_def      save_xh_pattern_type;
  struct GRIOvar_def      act_xh_pattern_type;
  IGRdouble               act_xhatch_angle;
  IGRdouble               act_xhatch_spacing;
  IGRshort                act_xhatch_color;
  channel {(rel_ordered)} to_collection;
 }

implementation

%safe
#include <math.h>
%endsafe

#include <alloca.h>
#include "codebug.h"
#include "grerr.h"
#include "codef.h"
#include "msdef.h"
#include "dpdef.h"
#include "griodef.h"
#include "comiscmac.h"
#include "coniarray.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "msmacros.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "igrmacros.h"
#include "coniindex.h"  
#include "lcdef.h"
#include "lcmacros.h"
#include "exfi.h"
#include "FI.h"
#include "coreadout.h"
#include "comeasure.h"
#include "grmessage.h"
#include <stdio.h>
#include "grxhatch.h"
#include "grxhdef.h"
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "referr.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "GRaxhatch.h"
#include "OMmacros.h"
#include "csdef.h"
#include "csmacros.h"
#include "EMSasopts.h"
#include "nddef.h"

#define FIELD_DIM 30

/* from FIform import put_by_value;
from FIform import erase_form; */
from GRcoxhatch import GRxhget_definition;
from GRcoxhatch import GRxhget_addl_info;
from GRgraphics import GRdisplay;
from GRgraphics import GRgetprops;
from GRcoords   import GRcvt_to_wld_coords;
from EMSassoc   import EMinit_associative;
from GRvg       import GRgetsymb;
from NDnode     import NDget_objects;
from NDnode     import ASreturn_go;
from GRaxhatch  import GRxhadd_bdry;
from GRaxhatch  import GRxhremove_bdry;
from GRaxhatch  import GRxhcompute;
from GRaxhatch  import GRxhget_gg;
from GRaxhatch  import GRxhget_definition;
from GRaxhatch  import GRxhput_definition;


extern OMuword OPP_GRaxhatch_class_id;
extern OMuword OPP_GRcoxhatch_class_id;
extern OMuword OPP_ASsource_class_id;
extern OMuword OPP_EMSpointer_class_id;

action init
{
  IGRlong               sts;
  struct GRid           module_grid;
  struct GRIOvar_def    xh_pattern_type;
  extern IGRint         GRcvt_to_var();
  extern IGRint         GRaddvar();
  
  /*
   *  	send to our parent to its stuff done
   */	
  _m_debug_str( "COnpt.init - sending init to parent locate." );
  status = om$send(mode = OM_e_wrt_message,
		   msg = message COnpt.init( type, str_ptr ),
		   targetid = my_id );
  
  status = ex$get_cur_mod( id    = &module_grid.objid,
 			  osnum = &module_grid.osnum );
  
  status = co$cvtvar(msg = &sts,
		     alias = "COXH_PATTERN_TYPE",
		     osnum = module_grid.osnum,
		     var = &xh_pattern_type);
  
  if( !(status & sts & 1))
    {
      xh_pattern_type.type = GRIO_VAR_INT;
      xh_pattern_type.contents.ivalue = GRXH_ANSI_IRON;
      me->act_xh_pattern_type.type = xh_pattern_type.type;
      me->act_xh_pattern_type.contents.ivalue=xh_pattern_type.contents.ivalue; 
      status = co$addvar(msg = &sts,
			 input_alias = "COXH_PATTERN_TYPE",
			 osnum = module_grid.osnum,
			 input_string = &xh_pattern_type);
    }
  else
    {
      me->act_xh_pattern_type.type = xh_pattern_type.type;
      me->act_xh_pattern_type.contents.ivalue=xh_pattern_type.contents.ivalue; 
    }
  
}

action wakeup
{
  IGRint                 sts;

  _m_debug_str( "ECaxhatch.wakeup");  

  status = om$send ( msg = message COnpt.wakeup ( pos ),
		    targetid = my_id,
		    mode = OM_e_wrt_message );
  status = om$send (msg = message ECaxhatch.update_form ((IGRlong *) &sts),
		    targetid = my_id);

}

action status_disp
{
  IGRint                 sts;

  _m_debug_str( "ECaxhatch.status_disp");  

  status = om$send ( msg = message CEO.status_disp ( ),
		    targetid = my_id,
		    mode = OM_e_wrt_message );

  status = om$send (msg = message ECaxhatch.retieve_active_parms ((IGRlong *) &sts),
		    targetid = my_id);

  status = om$send (msg = message ECaxhatch.update_form ((IGRlong *) &sts),
		    targetid = my_id);

  me->save_spacing = me->act_xhatch_spacing;
  me->save_angle = me->act_xhatch_angle;
  me->save_xh_pattern_type = me->act_xh_pattern_type;
}

action form_notification
{
  IGRlong                 msg;
  struct GRid             module_grid;
  IGRshort                field_size = 25;
  IGRshort                num_alias = 3;
  IGRdouble               angle;
  IGRint                  index;
  Form                    xhatch_form_ptr;
  IGRchar	          form_text[FIELD_DIM];
  IGRint	          sel_flag;
  IGRint	          r_pos;
  OM_S_CHANSELECT         to_second_chanselect;
  extern int FIg_set_state_on();
  extern int FIg_set_state_off();
  extern int FIfld_set_text();
  extern int FIfld_get_text();

  _m_debug_str( "ECaxhatch.form_notification");  

  switch (gadget_label)
    {
    case HELP_BUTTON:
      {
	_m_debug_str( "ECaxhatch.HELP_BUTTON");  
	status = om$send(mode = OM_e_wrt_message,
			 msg = message super_cmd.help(),
			 targetid = my_id );
	FIg_set_state_off(form_ptr, HELP_BUTTON);
	break;
      }
    case EXIT_BUTTON:
      {
	_m_debug_str( "ECaxhatch.EXIT_BUTTON");  
	me->act_xhatch_spacing = me->save_spacing;
	me->act_xhatch_angle = me->save_angle;
	me->act_xh_pattern_type = me->save_xh_pattern_type;
	FIg_set_state_off(form_ptr, EXIT_BUTTON);
	me->form_requested = FALSE;
	status= om$send(msg = message CEO.erase_form_by_label(form_label,
							      0,
							      (int *)&msg),
			targetid = my_id);
	break;
      }
    case ACCEPT_BUTTON:
      {
	_m_debug_str( "ECaxhatch.ACCEPT_BUTTON");  
	FIg_set_state_off(form_ptr, ACCEPT_BUTTON);
	me->form_requested = FALSE;
	status= om$send(msg = message CEO.erase_form_by_label(form_label,
							      0,
							      (int *)&msg),
			targetid = my_id);	

	status = om$send(msg = message CEO.get_form_ptr(XHATCH_REV_FORM,
							&xhatch_form_ptr,
							&index,
							(int *)&msg),
			 targetid = my_id ); 
	if(xhatch_form_ptr != NULL)
	  {
	    if((me->save_color != me->act_xhatch_color) || 
 	       (me->save_angle != me->act_xhatch_angle) ||
	       (me->save_spacing != me->act_xhatch_spacing) )
	      {
		me->DisplayMode = GRbehe;
		status = om$send(msg = 
				 message COnpt.display_second_located_object(
                                      (long *)&msg),
				 targetid = my_id);


   	       ex$message( msgnumb = GR_P_GenCrosHat,
                           field   = ERROR_FIELD,
                           justification = CENTER_JUS );
				 
		status = om$send(msg = 
				 message ECaxhatch.update_xh_element((long *)&msg),
				 targetid = my_id);
		
		me->DisplayMode = GRbd;
		status = om$send(msg = 
				 message COnpt.display_second_located_object(
                                      (long *)&msg),
				 targetid = my_id);
                status = om$make_chanselect( chanaddr  = &me->ToSecondLocated,
                              p_chanselect = &to_second_chanselect );

				 
                 /* clean out channel */
                 status = lc$wild_disconnect( p_chanselect =
                                                &to_second_chanselect );
 
   	       ex$message( msgnumb = GR_I_DpCmpl,
                           field   = ERROR_FIELD,
                           justification = CENTER_JUS );
				 				 
	      }
	    
	  }
	else
	  {
	    status = om$send (msg = message ECaxhatch.save_active_parms ((long *)&msg),
			      targetid = my_id);
	  }
	break;
      }
      
    case ASSOC_FLAG_TOGGLE:
      {
	_m_debug_str( "ECaxhatch.ASSOC_FLAG_TOGGLE");  
	break;
      }
      
    case ANGLE_FIELD:
      {
	_m_debug_str( "ECaxhatch.ANGLE_FIELD");  
	status = FIfld_get_text(form_ptr, ANGLE_FIELD, 0, 0, 
				FIELD_DIM, form_text, &sel_flag, &r_pos);

	status = co$expreval(msg = &msg,
			     expression = form_text,
			     unit_type = "UOM_ANGLE",
			     result = &me->act_xhatch_angle);

        status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
	    	          targetid = my_id);

	break;
      }
      
    case SPACING_FIELD:
      {
	_m_debug_str( "ECaxhatch.SPACING_FIELD");  
	status = FIfld_get_text(form_ptr, SPACING_FIELD, 0, 0, 
				FIELD_DIM, form_text, &sel_flag, &r_pos);

	status = co$expreval(msg = &msg,
			     expression = form_text,
			     unit_type = "UOM_DISTANCE",
			     result = &me->act_xhatch_spacing);

        status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
	    	          targetid = my_id);

	break;
      }

    case COLOR_FIELD:
      {
	_m_debug_str( "ECaxhatch.COLOR_FIELD");  
	status = ex$get_cur_mod(id = &module_grid.objid,
				osnum = &module_grid.osnum );

	status = FIfld_get_text(form_ptr, COLOR_FIELD, 0, 0, 
				FIELD_DIM, form_text, &sel_flag, &r_pos);
    
        status = ige$get_color_from_name(name = form_text,
					 color = &me->act_xhatch_color,
					 mod_id = module_grid.objid,
					 mod_osnum = module_grid.osnum);
        if(!(status&1))
	  {
	    _m_debug_str( "ECaxhatch.COLOR_FIELD digit entered");  
            me->act_xhatch_color = atoi(form_text);
	  }
	
	status = om$send(msg = message CEO.get_form_ptr(XHATCH_REV_FORM,
							&xhatch_form_ptr,
							&index,
							(int *)&msg),
			 targetid = my_id ); 
	
	if(me->forms[index].displayed)
	  {
	    _m_debug_str("ECaxhatch.COLOR_FIELD updating color keyin field");  
	    ige$get_name_from_color(color = me->act_xhatch_color,      
				    name =  form_text,
				    mod_id = module_grid.objid,
				    mod_osnum = module_grid.osnum);

	    status = FIfld_set_text(xhatch_form_ptr,COLOR_FIELD,0,0,form_text,
				    0);
	  }
	
	break;
      }

    case ANGLE_DIAL:
      {
	_m_debug_str( "ECaxhatch.ANGLE_DIAL");  
        angle=(IGRdouble)((IGRint)(value + .5));
        MAdegrad(&msg,&angle,&me->act_xhatch_angle);

	status = ex$get_cur_mod(id = &module_grid.objid,
				osnum = &module_grid.osnum );

	status = co$cvt_imp_to_alias(msg = &msg,
				     unit_type = "UOM_ANGLE",
				     osnum = module_grid.osnum,
				     working_units = &me->act_xhatch_angle,
				     num_alias = &num_alias,
				     field_size = &field_size,
				     cvt_list = form_text);

	status = om$send(msg = message CEO.get_form_ptr(XHATCH_REV_FORM,
							&xhatch_form_ptr,
							&index,
							(int *)&msg),
			 targetid = my_id ); 
	
	if(me->forms[index].displayed)
	  {
	    _m_debug_str( "ECaxhatch.ANGLE_DIAL updating angle keyin field");  
            FIfld_set_text(xhatch_form_ptr,ANGLE_FIELD,0,0,form_text,0);
	  }
	
	break;
      }

    case GRXH_ANSI_IRON:
      {
	_m_debug_str( "ECaxhatch.GRXH_ANSI_IRON");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_ANSI_IRON;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_DIN_STEEL:
      {
	_m_debug_str( "ECaxhatch.GRXH_DIN_STEEL");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_DIN_STEEL;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_DIN_CAST_STEEL:
      {
	_m_debug_str( "ECaxhatch.GRXH_DIN_CAST_STEEL");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_DIN_CAST_STEEL;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_DIN_COPPER:
      {
	_m_debug_str( "ECaxhatch.GRXH_DIN_COPPER");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_DIN_COPPER;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }
      
    case GRXH_DIN_BRASS:
      {
	_m_debug_str( "ECaxhatch.GRXH_DIN_BRASS");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_DIN_BRASS;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_DIN_BRONZE:
      {
	_m_debug_str( "ECaxhatch.GRXH_DIN_BRONZE");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_DIN_BRONZE;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_DIN_ZINC_LEAD:
      {
	_m_debug_str( "ECaxhatch.GRXH_DIN_ZINC");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_DIN_ZINC_LEAD;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_DIN_LIGHT_METAL:
      {
	_m_debug_str( "ECaxhatch.GRXH_DIN_LIGHT_METAL");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_DIN_LIGHT_METAL;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_DIN_SEAL_INSULAT:
      {
	_m_debug_str( "ECaxhatch.GRXH_DIN_SEAL_INSULAT");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_DIN_SEAL_INSULAT;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_DIN_HARD_RUBBER:
      {
	_m_debug_str( "ECaxhatch.GRXH_DIN_HARD_RUBBER");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_DIN_HARD_RUBBER;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_ANSI_PLASTIC:
      {
	_m_debug_str( "ECaxhatch.GRXH_ANSI_PLASTIC");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_ANSI_PLASTIC;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    case GRXH_ANSI_TITANIUM:
      {
	_m_debug_str( "ECaxhatch.GRXH_ANSI_TITANIUM");  
	me->act_xh_pattern_type.type = GRIO_VAR_INT;
	me->act_xh_pattern_type.contents.ivalue = GRXH_ANSI_TITANIUM;
	status = om$send (msg = message ECaxhatch.update_form ((long *)&msg),
			  targetid = my_id);
	break;
      }

    default:
	_m_debug_str( "ECaxhatch.default");  
      break;
    }   
} /* end action */



action form_input
{
} /* end action */

action update_form
{
  struct GRid           module_grid;
  IGRshort              field_size = 25;
  IGRshort              num_alias = 3;
  Form                  xhatch_form_ptr;
  IGRdouble             angle;
  IGRint                index;
  IGRchar               form_text[FIELD_DIM];
  extern int FIg_set_state_on();
  extern int FIg_set_state_off();
  extern int FIfld_set_text();
  extern int FIfld_get_text();
  
  *sts = MSSUCC;
  status = OM_S_SUCCESS;
  
  _m_debug_str( "ECaxhatch.update_form"); 

  status = ex$get_cur_mod(id = &module_grid.objid,
			  osnum = &module_grid.osnum );
  
  status = om$send(msg = message CEO.get_form_ptr(XHATCH_REV_FORM,
						  &xhatch_form_ptr,
						  &index,
						  (int *) sts),
		   targetid = my_id ); 
  
  if(xhatch_form_ptr != NULL) /* rev xhatch command */
    {
      ige$get_name_from_color(color = me->act_xhatch_color,      
			      name =  form_text,
			      mod_id = module_grid.objid,
			      mod_osnum = module_grid.osnum);
      status = FIfld_set_text(xhatch_form_ptr,COLOR_FIELD,0,0,form_text,0); 
      
      MAraddeg(sts,&me->act_xhatch_angle,&angle);
      FIg_set_value(xhatch_form_ptr,ANGLE_DIAL,(angle+.5));
    }
  else if(me->status_display_form_ptr != NULL) /* create xhatch command */
    {     
      xhatch_form_ptr = me->status_display_form_ptr;
      FIg_set_state_off(me->status_display_form_ptr,GRXH_ANSI_IRON);
      FIg_set_state_off(me->status_display_form_ptr,GRXH_DIN_STEEL);
      FIg_set_state_off(me->status_display_form_ptr,GRXH_DIN_CAST_STEEL);
      FIg_set_state_off(me->status_display_form_ptr,GRXH_DIN_COPPER); 
      FIg_set_state_off(me->status_display_form_ptr,GRXH_DIN_BRASS);
      FIg_set_state_off(me->status_display_form_ptr,GRXH_DIN_BRONZE);
      FIg_set_state_off(me->status_display_form_ptr,GRXH_DIN_ZINC_LEAD);
      FIg_set_state_off(me->status_display_form_ptr,GRXH_DIN_LIGHT_METAL);
      FIg_set_state_off(me->status_display_form_ptr,GRXH_DIN_SEAL_INSULAT); 
      FIg_set_state_off(me->status_display_form_ptr,GRXH_DIN_HARD_RUBBER);
      FIg_set_state_off(me->status_display_form_ptr,GRXH_ANSI_PLASTIC);
      FIg_set_state_off(me->status_display_form_ptr,GRXH_ANSI_TITANIUM);
      FIg_set_state_on(me->status_display_form_ptr,
		       me->act_xh_pattern_type.contents.ivalue);
    }

  if(xhatch_form_ptr != NULL)
    {
      /* update fields common to both forms */
      FIg_set_state_on(xhatch_form_ptr,ASSOC_FLAG_TOGGLE);
      
      status = co$cvt_imp_to_alias(msg = sts,
				   unit_type = "UOM_DISTANCE",
				   working_units = &me->act_xhatch_spacing,
				   num_alias = &num_alias,
				   field_size = &field_size,
				   osnum = module_grid.osnum,
				   cvt_list = form_text);
      status = FIfld_set_text(xhatch_form_ptr,SPACING_FIELD,0,0,form_text,0);
      
      status = co$cvt_imp_to_alias(msg = sts,
				   unit_type = "UOM_ANGLE",
				   osnum = module_grid.osnum,
				   working_units = &me->act_xhatch_angle,
				   num_alias = &num_alias,
				   field_size = &field_size,
				   cvt_list = form_text);
      status = FIfld_set_text(xhatch_form_ptr,ANGLE_FIELD,0,0,form_text,0);
    }
}

action locate_two_and_construct
{
    struct GRevent       *events[NUMBER_OF_EVENTS];
    struct GRid           module_grid,
                          object_grid,
                          active_cs;
    struct EMSobject_info *parents;
    struct GRaxhatch_info xhatch_info;
    struct GRvg_construct construct_list;
    struct GRIOvar_def    xh_pattern_type;
    struct IGRdisplay     display_attr;
    OM_S_CHANSELECT       my_channel;
    OMuint		  chan_count;
    IGRint		  num_bytes, num_bytes_ret, index,
                          num_parents, ret_name_size, ret_desc_size,
                          name_size = 80, desc_size = 80;
    IGRlong		  ptn_type, ssts;
    OM_S_CHANSELECT       MyChannelStruct;
    extern IGRint         GRcvt_to_var();
    IGRdouble             world_origin[3];
    IGRshort              active_layer;
    IGRchar               act_cs_name[80],
                          act_cs_desc[80];

    declare_multi;

    status = OM_S_SUCCESS;
    *sts = MSSUCC;

    status = om$make_chanselect( chanaddr     = &me->to_collection,
				p_chanselect = &my_channel );
    /*
     *  get myself to set up some data structures
     */
    set_up_multi2;
    status = om$send(mode = OM_e_wrt_message,
                    msg = message COnpt.set_up_n_elements(grids ),
                    targetid = my_id );
    _m_checkp(status,"COnpt.locate_two_and_construct - failed set up two." );
    _m_checkq( status );

    /*
     *  get the active module
     */
    status = ex$get_cur_mod( id    = &module_grid.objid,
                             osnum = &module_grid.osnum );

    num_bytes  = sizeof(IGRdouble);
    status = gr$get_xhatch_spacing(msg = sts,
                          sizbuf = &num_bytes,
                          buffer = (IGRchar *) &xhatch_info.xhatch_spacing,
                          nret = &num_bytes_ret);
    if(!(status & *sts & 1)) {
	printf("COnpt.locate_two_and_construct - failed to get xhatch_spacing\n" );
    }

    status = gr$get_xhatch_angle(msg = sts,
                        sizbuf = &num_bytes,
                        buffer = (IGRchar *) &xhatch_info.xhatch_angle,
                        nret = &num_bytes_ret);
    if(!(status & *sts & 1)) {
	printf("COnpt.locate_two_and_construct - failed to get xhatch_angle\n" );
    }

    if (me->mytype != 1)
    {
        status = co$cvtvar(msg = &ssts,
                           alias = "COXH_PATTERN_TYPE",
                           osnum = module_grid.osnum,
                           var = (IGRchar *) &xh_pattern_type);
        if(!(status & ssts & 1)) {
    	    printf("COnpt.locate_two_and_construct - failed to cvtvar\n" );
            xh_pattern_type.contents.ivalue = GRXH_ANSI_IRON;
        }
    
        ptn_type = (IGRlong) xh_pattern_type.contents.ivalue;
    }
    else  /* the command type indicates we're to use the empty pattern */
        ptn_type = GRXH_EMPTY;

    status = GRxh_load_pattern(ptn_type, xhatch_info.xhatch_spacing,
                               &xhatch_info.pattern_def);

    object_grid.osnum = module_grid.osnum;

    /* get the parents of crosshatch element; the first parent should be the
     * object to be crosshatched (which is the first object in "grids") and
     * the rest of the parents are internal boundaries, which will be the
     * objects connected on the to_collection channel
     */

    status = om$get_channel_count(objid = my_id,
                                  p_chanselect = &my_channel,
                                  count = &chan_count);
    if (! (1 & status))
    {
#ifdef DEBUG
        printf("ECaxhatch.locate_two_and_construct - failed to get channel count\n");
#endif
        goto quit;
    }

    num_parents = 1 + chan_count;

    parents = NULL;
    parents = (struct EMSobject_info *) alloca(num_parents *
                                               sizeof(struct EMSobject_info));

    if (! parents)
    {
#ifdef DEBUG
        printf("ECaxhatch.locate_two_and_construct - failed allocate memory\n");
#endif
        goto quit;
    }

    parents[0].grid.osnum = grids[0]->osnum;
    parents[0].grid.objid = grids[0]->objid;
    OM_BLOCK_MOVE(modules[0], &parents[0].env, sizeof(struct GRmd_env));

    for (index = 0; index < chan_count; index++)
    {
        om$get_objid_at_index(objid = my_id,
                              p_chanselect = &my_channel,
                              index = index,
                              objidaddr = &parents[index + 1].grid.objid,
                              osnumaddr = &parents[index + 1].grid.osnum);

        OM_BLOCK_MOVE(modules[0], &parents[index + 1].env,
                      sizeof(struct GRmd_env));
    }

    active_cs.osnum = module_grid.osnum;

    status = cs$get_active_info(msg = sts,
		                osnum = module_grid.osnum,
                                namebuf_size = name_size,
                                name = act_cs_name,
                                namebytes_ret = &ret_name_size,
                                descbuf_size = desc_size,
                                desc = act_cs_desc,
                                descbytes_ret = &ret_desc_size,
                                objid = &active_cs.objid);

    if (! (status & *sts & 1))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    world_origin[0] = 0.0;
    world_origin[1] = 0.0;
    world_origin[2] = 0.0;

     status = om$send(msg = message GRcoords.GRcvt_to_wld_coords(&ssts,
		                                 Rectangular, 1, world_origin,
     		                                 xhatch_info.origin),
                     targetos = active_cs.osnum,
                     targetid = active_cs.objid);

    if (! (status & ssts & 1))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }
 
    construct_list.msg = &ssts;
    construct_list.env_info = modules[0];
    construct_list.newflag = FALSE;
    gr$get_active_layer(buffer = &active_layer);
    construct_list.level = active_layer;
    construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    construct_list.geometry = NULL;
    gr$get_active_display(buffer = &display_attr);
    construct_list.display = &display_attr;
    construct_list.class_attr = NULL;
    construct_list.name = NULL;

    xhatch_info.window_grid.osnum = events[0]->event.button.osnum;
    xhatch_info.window_grid.objid = events[0]->event.button.objid;
    xhatch_info.xhatch_color = display_attr.color;

    status = om$construct(classid = OPP_GRaxhatch_class_id,
                          p_objid = &object_grid.objid,
                          msg = message EMSassoc.EMinit_associative(&ssts,
                                                NULL, num_parents, parents,
                                                GR_axhatch_elem,
                                                sizeof (struct GRaxhatch_info),
                                                (IGRchar *) &xhatch_info,
                                                &construct_list),
                          osnum = module_grid.osnum);
    if(!(status & *sts & 1)) {
	printf("COnpt.locate_two_and_construct - failed to construct_xhatch\n" );
    }
                                              /* change chan. *****/
    status = om$make_chanselect(chanaddr     = &me->ToFirstLocated,
				p_chanselect = &MyChannelStruct );

    status = lc$wild_disconnect(p_chanselect = &MyChannelStruct);

    lc$connect(p_chanselect = &MyChannelStruct,
	       go_objid =  object_grid.objid,
	       go_osnum =  object_grid.osnum );

    if ( *sts == GRILLDEFINITION )
      {
	ex$message( msgnumb = GR_E_IllDef,
                   field   = ERROR_FIELD,
                   justification = LEFT_JUS );
	*sts = MSSUCC;
	goto quit;
      }
    if ( *sts == GRNOTIMPLEMENTED )
      {
	ex$message( msgnumb = GR_E_ConstNotImp,
                   field   = ERROR_FIELD,
                   justification = LEFT_JUS );
        *sts = MSSUCC;
      }
  }

action add_to_collection
{
    OM_S_CHANSELECT              channel_select;
    OM_S_OBJECT_LINKAGE          channel_linkage[1];
    struct GRobj_env            *object_list = 0;
    OMuint                       num_objects;
    IGRlong                      i,count;
    OM_S_CLASSLIST               owner_classes;
    GRclassid                    owner_classid;
    struct GRid                  located_object;

    *sts = MSSUCC;

    _m_debug_str( "ECaxhatch.add_to_collection");  
    om$get_classid(classname = "GRgrgrp",
		   p_classid = &owner_classid);

    owner_classes.w_count = 1;
    owner_classes.w_flags = OM_CLST_subclass;
    owner_classes.p_classes = &owner_classid;

    status = om$make_chanselect( chanaddr     = &me->to_collection,
				p_chanselect = &channel_select );

    status = om$get_channel_objects(objid = my_id,
                                    p_chanselect = &me->located_chansel,
                                    list = channel_linkage,
                                    size = 1,
                                    count = &num_objects);

    located_object.objid = channel_linkage[0].S_objid,
    located_object.osnum = channel_linkage[0].osnum,

    status = gr$gsis_graphics_set(msg = sts,
				  senderid = NULL_OBJID,
				  object_id = &located_object);
    if( (status&1) & (*sts&1))
      {
	gr$gsremove_fence(msg = sts,
			  object_id = &located_object);

	gr$gsflatten_owners(msg = sts,
			    attributes = &me->attributes,
			    eligible_classes = &me->locate_eligible_thing,
			    owner_classes = &owner_classes,
			    owner_properties = NULL,
			    object_id = &located_object);

	gr$gsinqcount(msg = sts,
		      count = &count, 
		      object_id = &located_object);

	object_list = (struct GRobj_env *)om$malloc(
			    size = sizeof(struct GRobj_env) * count);
	if(object_list == NULL)
	  {
	    *sts = MSFAIL;
	    goto quit;
	  }
	gr$gsget_objects(msg = sts,
			 array = object_list,
			 size = (sizeof(struct GRobj_env) * count),
			 count = &count,
			 object_id = &located_object);

	for(i=0; i<count; i++)
	  {
	    status = lc$connect(p_chanselect = &channel_select,
				go_objid = object_list[i].obj_id.objid,
				go_osnum = object_list[i].obj_id.osnum);
	  }
      }
    else  
      {
	status = lc$get_channel_objects(objid = my_id,
					p_chanselect = &me->located_chansel,
					list = channel_linkage,
					size = 1,
					count = &num_objects);
	if (num_objects > 0 )
	  {
	    status = lc$connect(p_chanselect = &channel_select,
				go_objid = channel_linkage[0].S_objid,
				go_osnum = channel_linkage[0].osnum);
	  }
      }

    if (object_list)
      om$dealloc(ptr = object_list);
}

action delete_last_entry_collection
{
    OM_S_CHANSELECT      channel_select;
    OMuint               num_objects;

    *sts = MSSUCC;
    _m_debug_str( "ECaxhatch.delete_last_entry_collection");  
    status = om$make_chanselect( chanaddr     = &me->to_collection,
                                 p_chanselect = &channel_select );

    status = lc$get_channel_count(p_chanselect = &me->located_chansel,
                                  count = &num_objects);

    if(num_objects > 0)
      {
	lc$range_disconnect(p_chanselect = &channel_select,
			    low_index = num_objects-1, 
			    high_index = num_objects-1);
      }
}

action delete_collection
{
    OM_S_CHANSELECT      channel_select;
    *sts = MSSUCC;
    
    _m_debug_str( "ECaxhatch.delete_collection");  
    status = om$make_chanselect( chanaddr     = &me->to_collection,
                                 p_chanselect = &channel_select );

    lc$wild_disconnect(p_chanselect = &channel_select);
}

action change_crosshatch_spacing
{
  IGRint              num_bytes;
  
  *sts = MSSUCC;
  _m_debug_str( "ECaxhatch.change_crosshatch_spacing");  
  
  if (me->event1.subtype != GRst_DEFAULT)
    {
      me->act_xhatch_spacing = me->event1.event.value;
      num_bytes  = sizeof(IGRdouble);
      gr$put_xhatch_spacing(msg = sts,
			    sizbuf = &num_bytes,
			    buffer = (IGRchar *) &me->act_xhatch_spacing);
    }
}

action change_crosshatch_angle
{
  IGRint              num_bytes;
  
  *sts = MSSUCC;
  _m_debug_str( "ECaxhatch.change_crosshatch_angle");  
  
  if (me->event1.subtype != GRst_DEFAULT)
    {
      me->act_xhatch_angle = me->event1.event.value;
      num_bytes  = sizeof(IGRdouble);
      gr$put_xhatch_angle(msg = sts,
			  sizbuf = &num_bytes,
			  buffer = (IGRchar *) &me->act_xhatch_angle);
    }
}

action get_xhatch_objects
{
  IGRdouble            matrix[16];
  IGRlong              count,ssts;
  OMuint               num_objects,
                       num_parents;
  IGRint               parents_size = 0,
                       i,
                       index,
                       index2,
                       index3,
                       num_children,
                       num_ptr_children;
  struct  GRid         located_object,
                       object_grid,
                       *children,
                       *ptr_children,
                       go_grid;
  OM_S_CHANSELECT      to_second_chanselect,
                       notify_chanselect,
                       father_chansel,
                       chanselect;
  OM_S_OBJECT_LINKAGE  *notify_list = NULL,
                       channel_linkage[1];
  IGRboolean           found_flag = FALSE,
                       xhatch_assoc_flag;
  OMuword              classid;
  IGRshort             matrix_type;
  struct EMSobject_info *parents = NULL;
  struct GRobj_env     *wireframe_element=NULL;
  struct GRaxhatch_info xhatch_info;
  struct GRvg_construct construct_list;
  struct IGRdisplay     display_attr;

  _m_debug_str( "ECaxhatch.get_xhatch_objects");  

  status = om$get_channel_objects(objid = my_id,
				  p_chanselect = &me->located_chansel,
				  list = channel_linkage,
				  size = 1,
				  count = &num_objects);

  located_object.objid = channel_linkage[0].S_objid,
  located_object.osnum = channel_linkage[0].osnum,

  gr$gsinqcount(msg = sts,
                      count = &count,
                      object_id = &located_object);
 
  wireframe_element = (struct GRobj_env *)om$malloc(
                            size = sizeof(struct GRobj_env) * count);
  if(wireframe_element == NULL)
    {
      *sts = MSFAIL;
      goto quit;
    }

  gr$gsget_objects(msg = sts,
		   array = wireframe_element,
		   size = (sizeof(struct GRobj_env) * count),
		   count = &count,
		   object_id = &located_object);

  /* init ToSecondLocated channel struct */
  status = om$make_chanselect( chanaddr     = &me->ToSecondLocated,
			      p_chanselect = &to_second_chanselect );

  /* clean out channel if not 'edit crosshatch geom command' */
  if(strcmp(ME.super_cmd->cmd_key,"GRRvCrGm"))
    status = lc$wild_disconnect( p_chanselect = &to_second_chanselect );
  

  /* set up structure for wireframe object's notify channel */
  status = om$make_chanselect( channame     = "GRnotify.notification",
			      p_chanselect = &notify_chanselect );

  /* how many objects are on the notify channel? */
  status = om$get_channel_count(objid = wireframe_element[0].obj_id.objid,
				osnum = wireframe_element[0].obj_id.osnum,
				p_chanselect = &notify_chanselect,
				count = &num_objects);

  if (num_objects > 0 )
  {
      /* allocate space for the list of xhatch objects coming off the 
         channel, currently */
      notify_list = (OM_S_OBJECT_LINKAGE *) alloca(num_objects *
                                               (sizeof(OM_S_OBJECT_LINKAGE)));
      if(notify_list == NULL)
	{
	  *sts = MSFAIL;
	  goto quit;
	}

  
      /* get xhatch objects off the channel */
      status = om$get_channel_objects(objid=wireframe_element[0].obj_id.objid,
				      osnum=wireframe_element[0].obj_id.osnum,
				      p_chanselect = &notify_chanselect,
				      list  =  notify_list,
				      size  =  num_objects,
				      count = &num_objects );

      /* add each xhatch object to the ToSecondLocated channel */

      status = om$make_chanselect(channame     = "GRcoxhatch.to_notify",
				  p_chanselect = &notify_chanselect );
      for (i=0; i<num_objects; i++)
      {
	  /* check class id */
          status = om$get_classid(p_classid = &classid,
                                  objid = notify_list[i].S_objid,
                                  osnum = notify_list[i].osnum);
          if (classid == OPP_GRcoxhatch_class_id)
	  {
              /* this is an "old" crosshatch object; convert it to a new
               * crosshatch object (one that uses the associative
               * subsystem)
               */

              status = om$get_channel_count(objid = notify_list[i].S_objid,
	   			            osnum = notify_list[i].osnum,
				            p_chanselect = &notify_chanselect,
				            count = &num_parents);

              if ((1 & status) &&
                  (num_parents > 0 ))
              {
                  /* allocate space for the list of xhatch objects coming
                     off the  channel, currently */

                  if (parents_size < num_parents)
                  {
                      parents = (struct EMSobject_info *) alloca(num_parents *
                                             (sizeof(struct EMSobject_info)));
                      if (parents == NULL)
                      {
	                  *sts = MSFAIL;
	                  goto quit;
	              }

                      parents_size = num_parents;
                   }

                   for (index = 0; index < num_parents; index++)
                   {
                       om$get_objid_at_index(objid = notify_list[i].S_objid,
                                             osnum = notify_list[i].osnum,
                                             p_chanselect = &notify_chanselect,
                                             index = index,
                                             objidaddr = &parents[index].grid.objid,
                                             osnumaddr = &parents[index].grid.osnum);

                       OM_BLOCK_MOVE(&wireframe_element[0].mod_env,
                                     &parents[index].env,
                                     sizeof(struct GRmd_env));
                   }

                   /* get the element specific data of the crosshatch object */

                   status = om$send (msg = message GRcoxhatch.GRxhget_definition(
                                              &ssts,
                                              &xhatch_info.xhatch_color,
                                              &xhatch_info.xhatch_angle,
					      &xhatch_info.xhatch_spacing,
					      &xhatch_assoc_flag,
					      xhatch_info.origin,
					      &xhatch_info.pattern_def),
        			     targetid = notify_list[i].S_objid,
			             targetos = notify_list[i].osnum);
                   if (! (1 & status & ssts))
                   {
	               *sts = MSFAIL;
                       goto quit;
                   }

                   status = om$send (msg = message GRcoxhatch.GRxhget_addl_info(
                                              &ssts,
                                              &xhatch_info.window_grid),
        			     targetid = notify_list[i].S_objid,
			             targetos = notify_list[i].osnum);
                   if (! (1 & status & ssts))
                   {
	               *sts = MSFAIL;
                       goto quit;
                   }

                   construct_list.msg = &ssts;
                   construct_list.env_info = &wireframe_element[0].mod_env;
                   construct_list.newflag = FALSE;
                   construct_list.level = 1;
                   construct_list.geometry = NULL;
                   construct_list.display = &display_attr;
                   construct_list.class_attr = NULL;
                   construct_list.name = NULL;
                   object_grid.osnum = wireframe_element[0].mod_env.md_id.osnum;

                   status = om$construct(classid = OPP_GRaxhatch_class_id,
                                         p_objid = &object_grid.objid,
                                         msg = message EMSassoc.EMinit_associative(
                                                &ssts, EMS_no_const_assoc,
                                                num_parents, parents,
                                                GR_axhatch_elem,
                                                sizeof (struct GRaxhatch_info),
                                                (IGRchar *) &xhatch_info,
                                                &construct_list),
                                         osnum = object_grid.osnum);
                   if (! (1 & status & ssts))
                   {
	               *sts = MSFAIL;
                       goto quit;
                   }

                   /* move the to_components channel connections from the
                    * old crosshatch object to the new one (which should
                    * include the crosshatch graphic group GRxhgg), then
                    * delete the old crosshatch object
                    */

                   status = om$make_chanselect(channame = "GRcmpowner.to_components",
				  p_chanselect = &chanselect);

                   status = om$send (msg = message Root.move_chan(
                                                    chanselect,
                                                    notify_list[i].S_objid,
                                                    notify_list[i].osnum,
                                                    chanselect),
        			     targetid = object_grid.objid,
			             targetos = object_grid.osnum);
                   if (! (1 & status))
                   {
	               *sts = MSFAIL;
                       goto quit;
                   }

                   status = om$send (msg = message Root.delete(FALSE),
        			     targetid = notify_list[i].S_objid,
			             targetos = notify_list[i].osnum);
                   if (! (1 & status))
                   {
	               *sts = MSFAIL;
                       goto quit;
                   }

                   /* make sure the user did not locate a hole */

                   if((parents[0].grid.objid == wireframe_element[0].obj_id.objid) &&
                      (parents[0].grid.osnum == wireframe_element[0].obj_id.osnum) )
 	   	   {
		       found_flag = TRUE;

   		       lc$connect(p_chanselect = &to_second_chanselect,
		                  go_objid = object_grid.objid,
			          go_osnum = object_grid.osnum);
		   }
                }
	    }
            else
            {
                /* check to see if an ASsource (or subclass) object is on the
                 * the notification channel and if one is, see if its attached
                 * to a GRaxhatch object
                 */

                status = om$is_ancestry_valid(subclassid = classid,
                                        superclassid = OPP_ASsource_class_id);

                if (status == OM_S_SUCCESS)
                {
                    status = om$send(msg = message NDnode.NDget_objects(
                                              ND_CHILDREN | ND_IN_BUF,
                                              NULL, 0, &children,
                                              0, OM_K_MAXINT, &num_children),
        			     targetid = notify_list[i].S_objid,
			             targetos = notify_list[i].osnum);
                    if (! (1 & status))
                    {
 	                *sts = MSFAIL;
                        goto quit;
                    }

                    for (index = 0; index < num_children; index++)
                    {
                        om$get_classid(p_classid = &classid,
                                       objid = children[index].objid,
                                       osnum = children[index].osnum);

                        if (classid == OPP_GRaxhatch_class_id)
                        {
		            found_flag = TRUE;

   		            lc$connect(p_chanselect = &to_second_chanselect,
		                       go_objid = children[index].objid,
			               go_osnum = children[index].osnum);
                        }
                    }
                }
            }
	}
    }

    if (! found_flag)
    {
        /* haven't found either an old or new crosshatch object out the
         * located object's notification channel; if the located object is
         * associative, check out its children channel to see if a crosshatch
         * object is connected
         */

        om$make_chanselect(channame = "NDchildren.children",
                           p_chanselect = &chanselect );

        status = om$get_channel_count(objid = wireframe_element[0].obj_id.objid,
                                      osnum = wireframe_element[0].obj_id.osnum,
			              p_chanselect = &chanselect,
				      count = &num_objects);

        if ((1 & status) &&
            (num_objects > 0))
        {
            notify_list = NULL;
            notify_list = (OM_S_OBJECT_LINKAGE *) alloca(num_objects *
                                           (sizeof(OM_S_OBJECT_LINKAGE)));
            if(notify_list == NULL)
            {
	        *sts = MSFAIL;
	        goto quit;
	    }

            status = om$get_channel_objects(
                                   objid=wireframe_element[0].obj_id.objid,
	    			   osnum=wireframe_element[0].obj_id.osnum,
				   p_chanselect = &chanselect,
				   list  =  notify_list,
				   size  =  num_objects,
				   count = &num_objects );

            for (i = 0; i < num_objects; i++)
            {
                status = om$get_classid(p_classid = &classid,
                                        objid = notify_list[i].S_objid,
                                        osnum = notify_list[i].osnum);
                if (classid == OPP_GRaxhatch_class_id)
   	        {
                    found_flag = TRUE;

                    lc$connect(p_chanselect = &to_second_chanselect,
                               go_objid = notify_list[i].S_objid,
                               go_osnum = notify_list[i].osnum);
                    break;
                }
            }
        }

        if (! found_flag)
        {
            /* lastly, check out the object's to_owners channel since it may be
             * owned by an associative object through which it is attached to a
             * (new) crosshatch object via an EMSpointer object
             */

            om$make_chanselect(channame = "GRconnector.to_owners",
                               p_chanselect = &chanselect );

            om$make_chanselect(channame = "NDfather.father",
                               p_chanselect = &father_chansel);

            status = om$get_channel_count(
                                 objid = wireframe_element[0].obj_id.objid,
                                 osnum = wireframe_element[0].obj_id.osnum,
			         p_chanselect = &chanselect,
				 count = &num_objects);

            if ((1 & status) &&
                (num_objects > 0))
            {
                for (index = 0; index < num_objects; index++)
                {
                    status = om$send(msg = message NDnode.NDget_objects(
                                              ND_CHILDREN | ND_IN_BUF,
                                              NULL, 0, &children,
                                              0, OM_K_MAXINT, &num_children),
                                     senderid = wireframe_element[0].obj_id.objid,
                                     p_chanselect = &chanselect,
                                     from = index,
                                     to = index,
			             targetos = wireframe_element[0].obj_id.osnum);
                    if (status == OM_S_SUCCESS)
                    {
                        for (index2 = 0; index2 < num_children; index2++)
                        {
                            om$get_classid(p_classid = &classid,
                                           objid = children[index2].objid,
                                           osnum = children[index2].osnum);

                            if (classid == OPP_EMSpointer_class_id)
                            {
                                status = om$send(msg = message NDnode.NDget_objects(
                                           ND_CHILDREN | ND_IN_BUF,
                                           NULL, 0, &ptr_children,
                                           0, OM_K_MAXINT, &num_ptr_children),
                                     targetid = children[index2].objid,
    		    	             targetos = children[index2].osnum);

                                if (status == OM_S_SUCCESS)
                                {
                                    for (index3 = 0; index3 < num_ptr_children; index3++)
                                    {
                                        om$get_classid(p_classid = &classid,
                                                   objid = ptr_children[index3].objid,
                                                   osnum = ptr_children[index3].osnum);

                                        if (classid == OPP_GRaxhatch_class_id)
                                        {
                                            status = om$send(msg = message NDnode.ASreturn_go(
                                                                   &go_grid,
                                                                   &matrix_type,
                                                                   matrix),
                    		                             senderid = ptr_children[index3].objid,
                                                             p_chanselect = &father_chansel,
                                                             from = 0,
                                                             to = 0,
			                                     targetos = ptr_children[index3].osnum);
                                            if (! (1 & status))
                                            {
 	                                        *sts = MSFAIL;
                                                goto quit;
                                            }

                                            if ((go_grid.objid == wireframe_element[0].obj_id.objid) &&
                                                (go_grid.osnum == wireframe_element[0].obj_id.osnum))
                                            {
		                                found_flag = TRUE;

           		                        lc$connect(p_chanselect = &to_second_chanselect,
	        	                                   go_objid = ptr_children[index3].objid,
		        	                           go_osnum = ptr_children[index3].osnum);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if (! (1 & status) &&
                             (status != OM_W_UNKNOWN_MSG))
                    {
                        *sts = MSFAIL;
                        goto quit;
                    }
                }
            }
        }
    }

    if (found_flag == FALSE )
      *sts = MSFAIL;
    else
      me->SecondContext = me->ModuleInfo;
}

action is_this_a_hole
{
  IGRdouble            matrix[16];
  OM_S_OBJECT_LINKAGE *channel_linkage=NULL;
  OM_S_OBJECT_LINKAGE  locate_list[1];
  IGRint               num_elements_located;
  OMuint               num_objects;
  OMuint               num_holes_in_xhatch;
  struct GRid          located_object;
  struct GRid          xhatch_ele;
  struct GRid          go_grid;
  IGRint               i,j;                  /* a simple counter */
  OM_S_CHANSELECT      chanselect;
  OM_S_CHANSELECT      to_second_chanselect;
  struct GRobj_env    *hole_list = 0;  
  IGRshort             matrix_type;

  _m_debug_str( "ECaxhatch.is_this_a_hole" );
  status = om$get_channel_objects(objid = my_id,
				  p_chanselect = &me->located_chansel,
				  list = locate_list,
				  size = 1,
				  count = &num_objects);

  located_object.objid = locate_list[0].S_objid,
  located_object.osnum = locate_list[0].osnum,

  gr$gsinqcount(msg = sts,
		count = &num_elements_located, 
		object_id = &located_object);

  hole_list = NULL;
  hole_list = (struct GRobj_env *)alloca(sizeof(struct GRobj_env) * 
					 num_elements_located);
  if(hole_list == NULL)
    {
      *sts = MSFAIL;
      goto quit;
    }

  gr$gsget_objects(msg = sts,
		   array = hole_list,
		   size = (sizeof(struct GRobj_env) * num_elements_located),
		   count = &num_elements_located,
		   object_id = &located_object);

  /* init ToSecondLocated channel struct */
  status = om$make_chanselect(chanaddr     = &me->ToSecondLocated,
			      p_chanselect = &to_second_chanselect );

  /* how many xhatch objects? should only be one*/
  status = lc$get_channel_count(p_chanselect = &to_second_chanselect,
				count = &num_objects);

  channel_linkage = (OM_S_OBJECT_LINKAGE *) alloca(num_objects *
   			                   (sizeof(OM_S_OBJECT_LINKAGE)));
  if(channel_linkage == NULL)
    {
      *sts = MSFAIL;
      goto quit;
    }

  status = lc$get_channel_objects(objid = my_id,
				  p_chanselect = &to_second_chanselect,
				  list = channel_linkage,
				  size =  num_objects,
				  count = &num_objects);

  xhatch_ele.objid = channel_linkage[0].S_objid;
  xhatch_ele.osnum = channel_linkage[0].osnum;

  status = om$make_chanselect( channame = "NDfather.father",
			      p_chanselect = &chanselect );

  /* how many hole are assoc. with this xhatch object ? */
  status = om$get_channel_count(p_chanselect = &chanselect,
				count = &num_holes_in_xhatch,
				objid = xhatch_ele.objid,
                                osnum = xhatch_ele.osnum);

  channel_linkage = NULL;
  channel_linkage = (OM_S_OBJECT_LINKAGE *) alloca(num_holes_in_xhatch *
        			              (sizeof(OM_S_OBJECT_LINKAGE)));
  if(channel_linkage == NULL)
    {
      *sts = MSFAIL;
      goto quit;
    }

  status = om$get_channel_objects(objid = xhatch_ele.objid,
                                  osnum = xhatch_ele.osnum,
				  p_chanselect = &chanselect,
				  list = channel_linkage,
				  size =  num_holes_in_xhatch,
				  count = &num_holes_in_xhatch);

  *sts = MSFAIL;

  for(j=0; j<num_elements_located; j++)
    {
      for (i=1; i<num_holes_in_xhatch; i++)
	{
          status = om$send(msg = message NDnode.ASreturn_go(&go_grid,
                                                            &matrix_type,
                                                            matrix),
                           targetid = channel_linkage[i].S_objid,
                           targetos = channel_linkage[i].osnum);

	  if((hole_list[j].obj_id.objid == go_grid.objid) &&
	     (hole_list[j].obj_id.osnum == go_grid.osnum))
	    {
	      *sts = MSSUCC;
	      break;
	    }
	}  
    }
}

action add_remove_holes(IGRint add)
{
  IGRdouble            matrix[16];
  OM_S_CHANSELECT      to_collection_chanselect;
  OM_S_CHANSELECT      to_second_chanselect;
  OM_S_CHANSELECT      chansel;
  struct  GRid         my_grid;
  struct  GRaxhatch_info xhatch_info;
  IGRint               num_xhatch_objects;
  IGRint               i;
  OMuint               num_boundaries;
  IGRint               boundaries_size,
                       index;
  struct EMSobject_info *object_info;
  OM_S_OBJECT_LINKAGE  *xhatch_objects = 0,
                       *hole_objects;
  struct GRid          xhatch_gg,
                      *boundaries = NULL,
                      *holes;
  IGRint               num_holes;
  IGRshort             matrix_type;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
  boundaries_size = 0;
  _m_debug_str( "ECaxhatch.remove_holes");

  status = om$make_chanselect( chanaddr     = &me->to_collection,
			      p_chanselect = &to_collection_chanselect );

  status = om$make_chanselect( chanaddr     = &me->ToSecondLocated,
			      p_chanselect = &to_second_chanselect );

  status = lc$get_channel_count(objid = my_id,
                                p_chanselect = &to_second_chanselect,
			        count = &num_xhatch_objects);

  if (num_xhatch_objects > 0 )
  {
      xhatch_objects = (OM_S_OBJECT_LINKAGE *) alloca(num_xhatch_objects *
                                              sizeof(OM_S_OBJECT_LINKAGE));
      if(xhatch_objects == NULL)
      {
	  me->ret = MSFAIL;
	  goto quit;
      }

      status = lc$get_channel_objects(objid = my_id,
   			              p_chanselect = &to_second_chanselect,
				      list = xhatch_objects,
				      size = num_xhatch_objects,
				      count = &num_xhatch_objects);

      status = lc$get_channel_count(objid = my_id,
				    p_chanselect = &to_collection_chanselect,
				    count = &num_holes);

      if(num_holes > 0)
      {
          holes = NULL;
          holes = (struct GRid *) alloca(num_holes *
                                              sizeof(struct GRid));
          if (! holes)
          {
              me->ret = MSFAIL;
              goto quit;
          }

          hole_objects = NULL;
          hole_objects = (OM_S_OBJECT_LINKAGE *) alloca(num_holes *
                                               sizeof(OM_S_OBJECT_LINKAGE));
          if (! hole_objects)
          {
              me->ret = MSFAIL;
              goto quit;
          }

          status = lc$get_channel_objects(objid = my_id,
    			                  p_chanselect = &to_collection_chanselect,
				          list = hole_objects,
				          size = num_holes,
				          count = &num_holes);

          for (index = 0; index < num_holes; index++)
          {
              holes[index].objid = hole_objects[index].S_objid;
              holes[index].osnum = hole_objects[index].osnum;
          }

	  for (i = 0; i < num_xhatch_objects; i++)
          {
              status = om$send(msg = message GRaxhatch.GRxhget_gg(&me->ret,
     						                  &xhatch_gg),
	                       targetid = xhatch_objects[i].S_objid,
			       targetos = xhatch_objects[i].osnum);

              if (! (1 & status & me->ret))
              {
                  me->ret = MSFAIL;
                  goto quit;
              }

              if (add)
              {
                  object_info = NULL;
                  object_info = (struct EMSobject_info *) alloca(num_holes *
                                        sizeof(struct EMSobject_info));

                  if (! object_info)
                  {
                      me->ret = MSFAIL;
                      goto quit;
                  }

                  for (index = 0; index < num_holes; index++)
                  {
                      object_info[index].grid = holes[index];
                      OM_BLOCK_MOVE(&me->ModuleInfo, &object_info[index].env,
                                    sizeof(struct GRmd_env));
                  }

                  status = om$send(msg = message GRaxhatch.GRxhadd_bdry(&me->ret,
    						             num_holes,
    						             object_info),
    	                           targetid = xhatch_objects[i].S_objid,
			           targetos = xhatch_objects[i].osnum);

                  if (! (1 & status & me->ret))
                  {
                      me->ret = MSFAIL;
                      goto quit;
                  }
              }
              else
              {
                  status = om$send(msg = message GRaxhatch.GRxhremove_bdry(
                                                             &me->ret,
    						             num_holes,
    						             holes),
    	                           targetid = xhatch_objects[i].S_objid,
			           targetos = xhatch_objects[i].osnum);

                  if (! (1 & status & me->ret))
                  {
                      me->ret = MSFAIL;
                      goto quit;
                  }
              }

              /* get the crosshatch object's current boundary objects which
               * are necessary to recompute the crosshatch object
               */

              om$make_chanselect(channame = "NDfather.father",
	                         p_chanselect = &chansel);

              status = om$get_channel_count(objid = xhatch_objects[i].S_objid,
                                            osnum = xhatch_objects[i].osnum,
                                            p_chanselect = &chansel,
				            count = &num_boundaries);

              if (! (1 & status) ||
                  (! num_boundaries))
              {
                  me->ret = MSFAIL;
                  goto quit;
              }

              if (boundaries_size < num_boundaries)
              {
                  boundaries = NULL;
                  boundaries = (struct GRid *) alloca(num_boundaries *
                                                      sizeof(struct GRid));

                  if (! boundaries)
                  {
                      me->ret = MSFAIL;
                      goto quit;
                  }

                  boundaries_size = num_boundaries;
              }

              for (index = 0; index < num_boundaries; index++)
              {
                  status = om$send(msg = message NDnode.ASreturn_go(
                                                        &boundaries[index],
 				                        &matrix_type, matrix),
  	                           senderid = xhatch_objects[i].S_objid,
                                   p_chanselect = &chansel,
                                   from = index,
                                   to = index,
		  	           targetos = xhatch_objects[i].osnum);
              }

              status = om$send(msg = message GRaxhatch.GRxhget_definition(
                                             &me->ret,
                                             &xhatch_info.xhatch_color,
                                             &xhatch_info.xhatch_angle,
                                             &xhatch_info.xhatch_spacing,
                                             xhatch_info.origin,
                                             &xhatch_info.pattern_def,
                                             &xhatch_info.window_grid),
			       targetid = xhatch_objects[i].S_objid,
			       targetos = xhatch_objects[i].osnum);

              status = om$send(msg = message GRaxhatch.GRxhcompute(&me->ret,
                                                            boundaries,
							    &me->ModuleInfo,
                                                            num_boundaries - 1,
                                                            &boundaries[1],
                                                            &xhatch_info,
							    &xhatch_gg),
			       targetid = xhatch_objects[i].S_objid,
			       targetos = xhatch_objects[i].osnum);

              status = lc$connect(p_chanselect = &to_second_chanselect,
	                          go_objid = xhatch_objects[i].S_objid,
                                  go_osnum = xhatch_objects[i].osnum);
	    }
	}
    }
}

action display_collection
{
  OM_S_CHANSELECT      to_collection_chanselect;
  struct GRid          ModuleGrid;
  long   msg;
  
  _m_debug_str( "ECaxhatch.display_collection" );  
  status = ex$get_cur_mod(id  = &ModuleGrid.objid,
			  osnum = &ModuleGrid.osnum );
  _m_print_grid("ECaxhatch.display_collection - ModuleGrid", &ModuleGrid );
    
  status = om$make_chanselect( chanaddr     = &me->to_collection,
			      p_chanselect = &to_collection_chanselect );
  
  _m_print_grid( "ECaxhatch.display_collection - ModuleGrid", &ModuleGrid );
  
  status = om$send(msg = message GRgraphics.GRdisplay(&msg,
				      &me->ModuleInfo.md_env.matrix_type,
				      me->ModuleInfo.md_env.matrix,
						      &me->DisplayMode,
						      &ModuleGrid ),
		   p_chanselect = &to_collection_chanselect );
  
  *sts = MSSUCC;
  status = OM_S_SUCCESS;
}

action retieve_active_parms
{
  IGRint              num_bytes, num_bytes_ret;
  struct GRid          module_grid;

  _m_debug_str( "ECaxhatch.retieve_active_parms" );
  num_bytes  = sizeof(IGRdouble);
  gr$get_xhatch_spacing(msg = sts,
                        sizbuf = &num_bytes,
                        buffer = (IGRchar *) &me->act_xhatch_spacing,
                        nret = &num_bytes_ret);

  gr$get_xhatch_angle(msg = sts,
                      sizbuf = &num_bytes,
                      buffer = (IGRchar *) &me->act_xhatch_angle,
                      nret = &num_bytes_ret);

  status = ex$get_cur_mod(id    = &module_grid.objid,
 			  osnum = &module_grid.osnum );

  status = co$cvtvar(msg = sts,
		     alias = "COXH_PATTERN_TYPE",
		     osnum = module_grid.osnum,
		     var = (IGRchar *) &me->act_xh_pattern_type);

                        
}

action save_active_parms
{
  IGRint              num_bytes;
  struct GRid          module_grid;

  _m_debug_str( "ECaxhatch.save_active_parms" );
  num_bytes  = sizeof(IGRdouble);
  gr$put_xhatch_spacing(msg = sts,
                        sizbuf = &num_bytes,
                        buffer = (IGRchar *) &me->act_xhatch_spacing);
  
  gr$put_xhatch_angle(msg = sts,
		      sizbuf = &num_bytes,
		      buffer = (IGRchar *) &me->act_xhatch_angle);

  status = ex$get_cur_mod(id    = &module_grid.objid,
 			  osnum = &module_grid.osnum );

  status = co$addvar(msg = sts,
		     input_alias = "COXH_PATTERN_TYPE",
		     osnum = module_grid.osnum,
		     input_string = (IGRchar *) &me->act_xh_pattern_type);


}

action display_review_form
{
  IGRint                  index;
  Form                    xhatch_form_ptr;

  _m_debug_str( "ECaxhatch.display_review_form" );
  if(me->number_of_forms > 0)
    {
      status = om$send(msg = message CEO.get_form_ptr(XHATCH_REV_FORM,
						      &xhatch_form_ptr,
						      &index,
						      (int *) sts),
		       targetid = my_id ); 

      if(xhatch_form_ptr != NULL)
	{
	  
	  status = om$send (msg = message CEO.display_form_by_label
			    ( XHATCH_REV_FORM, (int *) sts ),
			    targetid = my_id );
	  
	  status = om$send(msg = message ECaxhatch.load_pattern_from_element(
									 sts),
			   targetid = my_id ); 

	  status = om$send(msg = message ECaxhatch.update_form(sts),
			   targetid = my_id ); 

	  status = lc$wild_disconnect( p_chanselect = &me->located_chansel );

	  me->save_spacing = me->act_xhatch_spacing;
	  me->save_angle = me->act_xhatch_angle;
	  me->save_color = me->act_xhatch_color;
	}
    }
  
}

action load_pattern_from_element
{
  IGRint                     num_objects;
  IGRshort                   alt_color;
  IGRdouble                  alt_angle;
  IGRdouble                  alt_spacing;
  IGRdouble                  origin[3];
  struct GRxhatchpat         pattern_def;
  struct GRid                window_grid;
  OM_S_CHANSELECT            channel_select;
  OM_S_OBJECT_LINKAGE       *channel_linkage=0;
  long                       msg;

  _m_debug_str( "ECaxhatch.load_pattern_from_element" );

/*
  status = om$send (msg = message ECaxhatch.get_xhatch_objects(sts),
		    targetid = my_id);
*/

  status = om$make_chanselect( chanaddr     = &me->ToSecondLocated,
			      p_chanselect = &channel_select );
  
  status = lc$get_channel_count(p_chanselect = &channel_select,
				count = &num_objects);

  if (num_objects > 0 )
    {
      channel_linkage = (OM_S_OBJECT_LINKAGE *) alloca(num_objects *
                                            (sizeof(OM_S_OBJECT_LINKAGE)));
      if(channel_linkage == NULL)
	{
	  *sts = MSFAIL;
	  goto quit;
	}

      status = lc$get_channel_objects(objid = my_id,
				      p_chanselect = &channel_select,
				      list = channel_linkage,
				      size = num_objects,
				      count = &num_objects);
 
      status = om$send (msg = message GRaxhatch.GRxhget_definition(&msg,
                                                              &alt_color,
							      &alt_angle,
							      &alt_spacing,
							      origin,
							      &pattern_def,
                                                              &window_grid),
			targetid = channel_linkage[0].S_objid,
			targetos = channel_linkage[0].osnum);

      me->act_xhatch_angle = alt_angle;
      me->act_xhatch_spacing = alt_spacing;
      me->act_xhatch_color = pattern_def.pass[0].lines[0].line_symbology.color;
    }

}


action filter
{
  _m_debug_str( "ECaxhatch.filter." );
  status = om$send( mode = OM_e_wrt_message,
		   msg = message CEO_GSLOCATE.filter( filter,
						     response,
						     response_data ),
		   targetid = my_id );
  
}

action update_xh_element
{
  IGRdouble                  matrix[16];
  OMuint                     num_objects,
                             num_boundaries;
  IGRint                     ii,index;
  struct GRid               *boundaries;
  struct GRaxhatch_info      xhatch_info;
  OM_S_CHANSELECT            channel_select;
  OM_S_OBJECT_LINKAGE       *channel_linkage=0;
  OM_S_OBJECT_LINKAGE        xhatch_gg_list[1];
  struct GRid                xhatch_gg;
  OMuint                     one = 1;
  OM_S_CHANSELECT            to_components_chanselect;
  IGRint                     num_angles,num_lines;
  IGRshort                   matrix_type;
  long                       msg;

  _m_debug_str( "ECaxhatch.update_xh_element" );

  status = om$make_chanselect( chanaddr     = &me->ToSecondLocated,
			      p_chanselect = &channel_select );
  
  status = lc$get_channel_count(p_chanselect = &channel_select,
				count = &num_objects);

  if( num_objects > 0 )
    {
      channel_linkage = (OM_S_OBJECT_LINKAGE *) alloca(num_objects *
   				         (sizeof(OM_S_OBJECT_LINKAGE)));
      if(channel_linkage == NULL)
	{
	  *sts = MSFAIL;
	  goto quit;
	}

      status = lc$get_channel_objects(objid = my_id,
				      p_chanselect = &channel_select,
				      list = channel_linkage,
				      size = num_objects,
				      count = &num_objects);

for(ii = 0; ii < num_objects ; ii++)
  {
      status = om$send (msg = message GRaxhatch.GRxhget_definition(&msg,
		                               &xhatch_info.xhatch_color,
	                                       &xhatch_info.xhatch_angle,
					       &xhatch_info.xhatch_spacing,
			                       xhatch_info.origin,
					       &xhatch_info.pattern_def,
                                               &xhatch_info.window_grid),
			targetid = channel_linkage[ii].S_objid,
			targetos = channel_linkage[ii].osnum);

      xhatch_info.xhatch_angle = me->act_xhatch_angle;
      xhatch_info.xhatch_spacing = me->act_xhatch_spacing;

      for(num_angles = 0; num_angles < xhatch_info.pattern_def.num_angles; num_angles++)
      {
	  for(num_lines=0; num_lines < xhatch_info.pattern_def.pass[num_angles].num_lines; 
              num_lines++)
          {
            xhatch_info.pattern_def.pass[num_angles].lines[num_lines].line_symbology.color= 
	   	me->act_xhatch_color;
          }
      }

      status = om$send (msg = message GRaxhatch.GRxhput_definition(&msg,
		                               &xhatch_info.xhatch_color,
	                                       &xhatch_info.xhatch_angle,
					       &xhatch_info.xhatch_spacing,
			                       xhatch_info.origin,
					       &xhatch_info.pattern_def,
                                               &xhatch_info.window_grid),
			targetid = channel_linkage[ii].S_objid,
			targetos = channel_linkage[ii].osnum);
  
      status = om$make_chanselect( channame     = "GRcmpowner.to_components",
				  p_chanselect = &to_components_chanselect );

      status = om$get_channel_objects(objid = channel_linkage[ii].S_objid,
				      osnum = channel_linkage[ii].osnum,
				      p_chanselect = &to_components_chanselect,
				      list  =  xhatch_gg_list,
				      size  =  one,
				      count = &one );

      xhatch_gg.objid = xhatch_gg_list[0].S_objid;
      xhatch_gg.osnum = xhatch_gg_list[0].osnum;

      /* get the crosshatch object's current boundary objects which
       * are necessary to recompute the crosshatch object
       */

      om$make_chanselect(channame = "NDfather.father",
                  p_chanselect = &channel_select);

      status = om$get_channel_count(objid = channel_linkage[ii].S_objid,
                                    osnum = channel_linkage[ii].osnum,
                                    p_chanselect = &channel_select,
                                    count = &num_boundaries);

      if (! (1 & status) ||
          (! num_boundaries))
      {
          me->ret = MSFAIL;
          goto quit;
      }

      boundaries = NULL;
      boundaries = (struct GRid *) alloca(num_boundaries *
                                          sizeof(struct GRid));
      if (! boundaries)
      {
          me->ret = MSFAIL;
          goto quit;
      }

      for (index = 0; index < num_boundaries; index++)
      {
          status = om$send(msg = message NDnode.ASreturn_go(
                                                &boundaries[index],
                                                &matrix_type, matrix),
                           senderid = channel_linkage[ii].S_objid,
                           p_chanselect = &channel_select,
                           from = index,
                           to = index,
                           targetos = channel_linkage[ii].osnum);
      }

      status = om$send(msg = message GRaxhatch.GRxhcompute(&msg,
                                                          boundaries,
							  &me->ModuleInfo,
                                                          num_boundaries - 1,
                                                          &boundaries[1],
                                                          &xhatch_info,
							  &xhatch_gg),
		       targetid = channel_linkage[ii].S_objid,
		       targetos = channel_linkage[ii].osnum);
    } /* for all cross hatch objects connected */
  }
}

action store_pattern_type
{
    struct GRIOvar_def      xh_pattern_type;
    struct GRid             module_grid;
    extern IGRint           GRaddvar();

    _m_debug_str( "ECaxhatch. store_pattern_type");

    *sts = MSSUCC;
    status = OM_S_SUCCESS;

    xh_pattern_type.type = GRIO_VAR_INT;
    xh_pattern_type.contents.ivalue = me->event1.event.value;

    status = ex$get_cur_mod( id    = &module_grid.objid,
                             osnum = &module_grid.osnum );

    status = co$addvar(msg = sts,
                       input_alias = "COXH_PATTERN_TYPE",
                       osnum = module_grid.osnum,
                       input_string = &xh_pattern_type);

}

action save_first_element
{
    OMuint               NumberObjectsFound;
    struct GRobj_env     object_list[1];
    OM_S_CHANSELECT      MyChannelStruct;
    struct GRid          located_object;
    OM_S_CLASSLIST       owner_classes;
    GRclassid            owner_classid;

    OM_S_OBJECT_LINKAGE  channel_linkage[1];

    _m_debug_str( "ECaxhatch.save_first_element." );

    om$get_classid(classname = "GRgrgrp",
		   p_classid = &owner_classid);
    
    owner_classes.w_count = 1;
    owner_classes.w_flags = OM_CLST_subclass;
    owner_classes.p_classes = &owner_classid;
    
    /*
     *  initialize the channel structure
     */
    status = om$make_chanselect(chanaddr     = &me->ToFirstLocated,
				p_chanselect = &MyChannelStruct );

    status = lc$wild_disconnect(p_chanselect = &MyChannelStruct );
    _m_checkp( status, "COnpt.save_first_element - failed lc$wild." );
    _m_checkq( status );

    status = om$get_channel_objects(objid = my_id,
                                    p_chanselect = &me->located_chansel,
                                    list = channel_linkage,
                                    size = 1,
                                    count = &NumberObjectsFound);

    located_object.objid = channel_linkage[0].S_objid;
    located_object.osnum = channel_linkage[0].osnum;

    status = gr$gsis_graphics_set(msg = sts,
				  senderid = NULL_OBJID,
				  object_id = &located_object);
     if( (status&1) & (*sts&1))
       {
	gr$gsremove_fence(msg = sts,
			  object_id = &located_object);
	
	gr$gsflatten_owners(msg = sts,
			    attributes = &me->attributes,
			    eligible_classes = &me->locate_eligible_thing,
			    owner_classes = &owner_classes,
			    owner_properties = NULL,
			    object_id = &located_object);
	
	 gr$gsget_objects(msg = sts,
			  array = object_list,
			  size = (sizeof(struct GRobj_env)),
			  count = &NumberObjectsFound,
			  object_id = &located_object);
	 _m_checkp( status,"ECaxhatch.save_first_element failed in grget_obj");
	 _m_checkq( status );
	 
	 lc$connect(p_chanselect = &MyChannelStruct,
		    go_objid =  object_list[0].obj_id.objid,
		    go_osnum =  object_list[0].obj_id.osnum);

	 me->FirstContext = object_list[0].mod_env;
       }
     else
       {
	 status = lc$get_channel_objects(objid = my_id,
					 p_chanselect = &me->located_chansel,
					 list = channel_linkage,
					 size = 1,
					 count = &NumberObjectsFound );
	 _m_checkp(status,"ECaxhatch.save_first_element fail in get_chan_obj");
	 _m_checkq( status );
	 
	 lc$connect(p_chanselect = &MyChannelStruct,
		    go_objid =  channel_linkage[0].S_objid,
		    go_osnum =  channel_linkage[0].osnum);
	 me->FirstContext = me->event1.located_object[0].module_info; 	 
       }
     
     /*
      *  record the fact that an object is on this channel (for wakeup)
      */
     me->ObjectOnFirstLocated = TRUE;
     me->ObjectWasLocated = FALSE;
   } /* save_first_element */

action save_second_element
{
    OMuint               NumberObjectsFound;
    struct GRobj_env     object_list[1];
    OM_S_CHANSELECT      MyChannelStruct;
    struct GRid          located_object;
    OM_S_CLASSLIST       owner_classes;
    GRclassid            owner_classid;
    OM_S_OBJECT_LINKAGE  channel_linkage[1];

    _m_debug_str( "ECaxhatch.save_second_element." );

    om$get_classid(classname = "GRgrgrp",
		   p_classid = &owner_classid);
    
    owner_classes.w_count = 1;
    owner_classes.w_flags = OM_CLST_subclass;
    owner_classes.p_classes = &owner_classid;
    
    /*
     *  initialize the channel structure
     */
    status = om$make_chanselect(chanaddr     = &me->ToSecondLocated,
				p_chanselect = &MyChannelStruct );

    status = lc$wild_disconnect(p_chanselect = &MyChannelStruct );
    _m_checkp( status, "COnpt.save_second_element - failed lc$wild." );
    _m_checkq( status );

    status = om$get_channel_objects(objid = my_id,
                                    p_chanselect = &me->located_chansel,
                                    list = channel_linkage,
                                    size = 1,
                                    count = &NumberObjectsFound);

    located_object.objid = channel_linkage[0].S_objid,
    located_object.osnum = channel_linkage[0].osnum,
    status = gr$gsis_graphics_set(msg = sts,
				  senderid = NULL_OBJID,
				  object_id = &located_object);
     if( (status&1) & (*sts&1))
       {
	gr$gsremove_fence(msg = sts,
			  object_id = &located_object);

	gr$gsflatten_owners(msg = sts,
			    attributes = &me->attributes,
			    eligible_classes = &me->locate_eligible_thing,
			    owner_classes = &owner_classes,
			    owner_properties = NULL,
			    object_id = &located_object);

	 gr$gsget_objects(msg = sts,
			  array = object_list,
			  size = (sizeof(struct GRobj_env)),
			  count = &NumberObjectsFound,
			  object_id = &located_object);
	 _m_checkp( status,"ECaxhatch.save_second_element failed in grget_obj");
	 _m_checkq( status );
	 
	 lc$connect(p_chanselect = &MyChannelStruct,
		    go_objid =  object_list[0].obj_id.objid,
		    go_osnum =  object_list[0].obj_id.osnum);

	 me->SecondContext = object_list[0].mod_env;
       }
     else
       {
	 status = lc$get_channel_objects(objid = my_id,
					 p_chanselect = &me->located_chansel,
					 list = channel_linkage,
					 size = 1,
					 count = &NumberObjectsFound );
	 _m_checkp(status,"ECaxhatch.save_second_element fail in get_chan_obj");
	 _m_checkq( status );
	 
	 lc$connect(p_chanselect = &MyChannelStruct,
		    go_objid =  channel_linkage[0].S_objid,
		    go_osnum =  channel_linkage[0].osnum);
	 
	 me->SecondContext = me->event1.located_object[0].module_info; 	 
       }
     
     me->ObjectOnSecondLocated = TRUE;
     me->ObjectWasLocated = FALSE;
   } /* save_second_element */

action display_xh_spacing
{
  IGRint	       num_bytes;
  IGRdouble            xhatch_spacing;
  IGRint	       num_bytes_ret;
  struct GRid          module_grid;
  IGRshort             field_size = 45;
  IGRshort             num_alias = 3;
  IGRchar              string[45];

  _m_debug_str( "ECaxhatch.display_xh_spacing" );
  num_bytes  = sizeof(IGRdouble);
  gr$get_xhatch_spacing(msg = sts,
			sizbuf = &num_bytes,
			buffer = (IGRchar *) &xhatch_spacing,
			nret = &num_bytes_ret);
  
  status = ex$get_cur_mod(id = &module_grid.objid,
			  osnum = &module_grid.osnum );
  
  status = co$cvt_imp_to_alias(msg = sts,
			       unit_type = "UOM_DISTANCE",
			       working_units = &xhatch_spacing,
			       num_alias = &num_alias,
			       field_size = &field_size,
			       osnum = module_grid.osnum,
			       cvt_list = string);
  ex$message(in_buff = string,
	     field   = ERROR_FIELD,
	     justification = CENTER_JUS );
}

action display_xh_angle
{
  IGRint	       num_bytes;
  IGRdouble            angle;
  IGRint	       num_bytes_ret;
  struct GRid          module_grid;
  IGRshort             field_size = 45;
  IGRshort             num_alias = 3;
  IGRchar              string[45];

  _m_debug_str( "ECaxhatch.display_xh_angle" );
  num_bytes  = sizeof(IGRdouble);
  gr$get_xhatch_angle(msg = sts,
                      sizbuf = &num_bytes,
                      buffer = (IGRchar *) &angle,
                      nret = &num_bytes_ret);

  status = ex$get_cur_mod(id = &module_grid.objid,
			  osnum = &module_grid.osnum );

  status = co$cvt_imp_to_alias(msg = sts,
			       unit_type = "UOM_ANGLE",
			       working_units = &angle,
			       num_alias = &num_alias,
			       field_size = &field_size,
			       osnum = module_grid.osnum,
			       cvt_list = string);
  ex$message(in_buff = string,
	     field   = ERROR_FIELD,
	     justification = CENTER_JUS );
}

action  auto_load_boundaries
{
  struct GRid          window;
  IGRlong              num_entries;
  IGRlong              i;
  struct GRlc_info    *ret_objects = 0;
  IGRint               num_objects;
  OM_S_CHANSELECT      channel_select;
  OM_S_OBJECT_LINKAGE  channel_linkage[1];
  struct GRlc_info     lc_info;
  
  ret_objects = NULL;
  
  window.objid = me->first_event.event.button.objid;
  window.osnum = me->first_event.event.button.osnum;

  status = om$make_chanselect( chanaddr     = &me->ToFirstLocated,
			      p_chanselect = &channel_select );

  status = lc$get_channel_objects(objid = my_id,
				  p_chanselect = &channel_select,
				  list = channel_linkage,
				  size = 1,
				  count = &num_objects);
  
  lc_info.located_obj.objid = channel_linkage[0].S_objid;
  lc_info.located_obj.osnum = channel_linkage[0].osnum;
  lc_info.module_info = me->FirstContext;
    
  status = GRauto_nester(sts, 
			 &lc_info,
			 window, 
                         &me->attributes,
                         &me->locate_eligible_thing,
			 &ret_objects, 
			 &num_entries);
  
  if((1&status) && (1&*sts))
    {
      status = om$make_chanselect( chanaddr     = &me->to_collection,
				  p_chanselect = &channel_select );
      for(i=0; i<num_entries; i++)
	{
	  status = lc$connect(p_chanselect = &channel_select,
			      go_objid = ret_objects[i].located_obj.objid,
			      go_osnum = ret_objects[i].located_obj.osnum);
	}
    }
  if(ret_objects) om$dealloc(ptr = ret_objects);
}
