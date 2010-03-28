/* ceo_gslocate/init_l.I */
class implementation CEO_GSLOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif

method init (
  int	  type;
  char	* str_ptr )
{
  int	  status;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_LOCATE_instance	* p_CEO_LOCATE   = ME.CEO_LOCATE;
  struct CEO_GSLOCATE_instance	* p_CEO_GSLOCATE = ME.CEO_GSLOCATE;

  _bugprint(bflag=TFLAG, str =
	"+CEO_GSLOCATE.init:  type = %d, str_ptr = '%s'\n",
	var = `type, str_ptr ? str_ptr : ""` )
  
  if ( str_ptr )
    {
      status = om$send (
          targetid = my_id,
          msg = message CEO_LOCATE.init ( type, str_ptr ),
          mode = OM_e_wrt_message );
      _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After CEO.init:  status = %d\n", var = status )
#ifdef DEBUG
      _cob_check ( status, \
		"CEO_GSLOCATE.init:  CEO_LOCATE.init() failed." );
#endif
    }

  p_CEO_GSLOCATE->locate_state = 0;
  p_CEO_GSLOCATE->num_inputs = 1;
  p_CEO_GSLOCATE->spec_mask1 = 0;
  p_CEO_GSLOCATE->spec_mask2 = 0;
  p_CEO_GSLOCATE->spec_prompt1[0] = '\0';
  p_CEO_GSLOCATE->spec_prompt2[0] = '\0';
  /*** these were set in CEO_LOCATE.init, but they need adjustment  ***/
  p_CEO_LOCATE->regex = LC_REGEX_ON;
  p_CEO_LOCATE->display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
  p_CEO_LOCATE->attributes.properties = LC_LC_ONLY | LC_DP_ONLY;
  p_CEO_LOCATE->attributes.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP  |
		LC_FLEX_OWNER |	LC_REF_HEADER  | LC_REF_OBJECTS ;

quit:
  _bugprint(bflag=TFLAG, str = "-CEO_GSLOCATE.init:  status = %d\n",
	var = status )
  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}
end implementation CEO_GSLOCATE;
