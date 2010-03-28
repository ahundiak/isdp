/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/init_l.I */
class implementation CEO_LOCATE;


#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <grdpbmacros.h>  /** need this for gr$get_active_xxx **/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


method init (
  int	  type;
  char	* str_ptr )
{
  int	  status, size;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_LOCATE_instance	* p_CEO_LOCATE = ME.CEO_LOCATE;

  _bugprint(bflag=TFLAG, str =
	"+CEO_LOCATE.init:  type = %d, str_ptr = '%s'\n",
	var = `type, str_ptr ? str_ptr : ""` )
  
  status = OM_S_SUCCESS;

  if ( str_ptr && ! ME.CEO->ceo_version )
    {
      status = om$send ( targetid = my_id,
		          msg = message CEO.init ( type, str_ptr ),
		          mode = OM_e_wrt_message );
      _bugprint(bflag=CEO_LOCATE_debug, str =
	"After CEO.init:  status = %d\n", var = status )
#ifdef DEBUG
      _cob_check ( status, "CEO_LOCATE.init:  CEO.init() failed." );
#endif
    }

  p_CEO_LOCATE->acc_prompt [0] = NULL;
  p_CEO_LOCATE->reloc_prompt [0] = NULL;
  p_CEO_LOCATE->event_mask2 = GRm_DATA;
  p_CEO_LOCATE->attributes.properties = LC_LC_ONLY | LC_DP_ONLY; /*JAJ:02-03-88*/
  p_CEO_LOCATE->attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP ; /* =6 */
  p_CEO_LOCATE->stack.num_entries = 0;
  p_CEO_LOCATE->action_handler = NULL;
  p_CEO_LOCATE->action_args = NULL;
  p_CEO_LOCATE->locate_eligible = NULL;
  p_CEO_LOCATE->locate_rtree = NULL;
  p_CEO_LOCATE->display_flag = ELEM_HILIGHT;
  p_CEO_LOCATE->dyn = NULL;
  p_CEO_LOCATE->type = 0;
  p_CEO_LOCATE->regex = LC_REGEX_OFF;	/*** JAJ:08-19-87 ***/
  p_CEO_LOCATE->stack_size = 1;		/***  and below   ***/
  p_CEO_LOCATE->select = NULL;
  p_CEO_LOCATE->select_args = NULL;
  p_CEO_LOCATE->HilightMode = GRhd;	/*** JAJ: 02-14-88 ***/
  p_CEO_LOCATE->UnhilightMode = GRhd;	/*** 	" " " "    ***/
  p_CEO_LOCATE->DisplayMode = GRbdhe;	/*** JAJ: 08-08-88 ***/
  p_CEO_LOCATE->range_handler = NULL;	/*** JAJ: 11-01-88 ***/
  p_CEO_LOCATE->range_args = NULL;	/*** 	" " " "    ***/

  p_CEO_LOCATE->value_type = NULL;	/*** JAJ: 12-19-88 ***/
  p_CEO_LOCATE->value_type_locate = NULL;	/*** 	" " " "    ***/
  p_CEO_LOCATE->value_type_accept = NULL;	/*** 	" " " "    ***/

		/** moved from CEO.init--JAJ:10-19-87 **/
  p_CEO_LOCATE->event_mask1 = -1;
  p_CEO_LOCATE->event_size = sizeof ( p_CEO_LOCATE->event1 );

  /**** set this back to NULL when the locate filter is fixed ***/
  /****  strcpy( me->attributes.classes, "GRgraphics" ); ****/
  p_CEO_LOCATE->attributes.classes[0] = NULL;	/*** JAJ:09-21-87 ***/

  p_CEO_LOCATE->scale_flag = GRIO_X_SCALE;	/*** JAJ:05-22-89 ***/
  
	/*** moved gr$get_module_env from wakeup-- JAJ:09-17-87 ***/
  size = sizeof ( p_CEO_LOCATE->ModuleInfo );
  _bugprint(bflag=CEO_LOCATE_debug,
	str = "Calling gr$get_module_env(locate_ModuleInfo)\n")
  gr$get_module_env ( msg = & status,
		      sizbuf = & size,
		      buffer = & p_CEO_LOCATE->ModuleInfo,
		      nret = & size );
#ifdef DEBUG
  _cob_check ( status, "CEO_LOCATE.init:  gr$get_module_env() failed.");
#endif

	/*** added  -- JAJ:10-02-89 ***/
  size = sizeof ( p_CEO_LOCATE->locate_ModuleInfo );
  _bugprint(bflag=CEO_LOCATE_debug, str = "Calling gr$get_module_env()\n")
  gr$get_module_env ( msg = & status,
		      sizbuf = & size,
		      buffer = & p_CEO_LOCATE->locate_ModuleInfo,
		      nret = & size );
#ifdef DEBUG
  _cob_check ( status, "CEO_LOCATE.init:  gr$get_module_env() failed.");
#endif

  status = om$make_chanselect (
      channame = "CEO_LOCATE.located_graphics",
      p_chanselect = & p_CEO_LOCATE->located_chansel );
  _bugprint(bflag=CEO_LOCATE_debug, str =
	"After om$mk_chnslct(CEO_LOCATE.located_graphics):  status = %d\n",
	var = status )
#ifdef DEBUG
  _cob_check( status, "CEO_LOCATE.init:  om$make_chanselect() failed.");
#endif


  _bugprint(bflag=TFLAG, str = "-CEO_LOCATE.init:  status = %d\n",
	var = status )
  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}
end implementation CEO_LOCATE;
