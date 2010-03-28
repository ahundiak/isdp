/* ceo_locate/action_gl.I */
class implementation CEO_GSLOCATE;
/*
  perform indicated action
*/

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif

method action (
  int	  selector;
  int	  int_or_str_ptr;
  int	* sts )
{
  int		status;
  long		spec_mask = NULL;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_LOCATE_instance	* p_CEO_LOCATE   = ME.CEO_LOCATE;
  struct CEO_GSLOCATE_instance	* p_CEO_GSLOCATE = ME.CEO_GSLOCATE;

  
  _bugprint(bflag=TFLAG, str =
	"+CEO_GSLOCATE.action:  sel=%d, int_or_str_ptr=[%d], *sts=%d\n",
	var = `selector, int_or_str_ptr, *sts` )
/*
  _bugprint(bflag=TFLAG, str =
	"+CEO_GSLOCATE.action:  sel=%d, int_or_str_ptr=[%d | '%s'], *sts=%d\n",
	var = `selector, int_or_str_ptr, int_or_str_ptr >=0 ? (char *)int_or_str_ptr : "" , *sts` )
*/

  * sts = OM_S_SUCCESS;

  switch ( selector )
    {
      case _discon_located:
	/*** this case overridden from ceo_locate JAJ:06-02-88  ******/
	/***  empty the graphic set object ***/
	status = gr$gsempty ( msg = sts,
			p_chanselect = &p_CEO_LOCATE->located_chansel );
	_bugprint(bflag=CEO_GSLOCATE_debug, str =
		"After gr$gsempty():  status = %d, *sts = %d\n",
		 var = `status, *sts` )
#ifdef DEBUG
	_cob_check2 ( status, *sts, \
			"CEO_GSLOCATE.action:  gr$gsempty() failed." );
#endif
        break;

      case  _gsloc_num_inputs:
        _bugprint(bflag=CEO_GSLOCATE_debug, str =
	    "selector = _gsloc_num_inputs; = %d\n",
	    var = int_or_str_ptr )
	p_CEO_GSLOCATE->num_inputs = int_or_str_ptr;
        break;

      case  _gsloc_spec_mask:
      case  _gsloc_spec_mask1:
      case  _gsloc_spec_mask2:
        _bugprint(bflag=CEO_GSLOCATE_debug, str =
	    "selector = _gsloc_spec_mask(_1/2); = %d\n",
	    var = int_or_str_ptr )
	spec_mask = int_or_str_ptr;

       if ( spec_mask & GRm_ANGLE )
          {
            spec_mask ^= GRm_ANGLE;
            spec_mask |= GRm_VALUE;
            p_CEO_LOCATE->value_type = GRIO_ANGLE;
          }
        if ( spec_mask & GRm_DIST )
          {
            spec_mask ^= GRm_DIST;
            spec_mask |= GRm_VALUE;
            p_CEO_LOCATE->value_type = GRIO_DISTANCE;
          }
        if ( spec_mask & GRm_SCALAR )
          {
            spec_mask ^= GRm_SCALAR;
            spec_mask |= GRm_VALUE;
            p_CEO_LOCATE->value_type = GRIO_SCALAR;
          }

	if ( selector == _gsloc_spec_mask1 )
	  {
	    _bugprint(bflag=CEO_GSLOCATE_debug, str =
		"selector = _gsloc_spec_mask1; = %d\n",
		var = spec_mask )
	    p_CEO_GSLOCATE->spec_mask1 = spec_mask;
	  }
	else if ( selector == _gsloc_spec_mask2 )
	  {
	    _bugprint(bflag=CEO_GSLOCATE_debug, str =
		"selector = _gsloc_spec_mask2; = %d\n",
		var = spec_mask )
	    p_CEO_GSLOCATE->spec_mask2 = spec_mask;
	  }
	else	/*** set them both ***/
	  {
	    p_CEO_GSLOCATE->spec_mask1 = spec_mask;
	    p_CEO_GSLOCATE->spec_mask2 = spec_mask;
	  }
        break;

      case _gsloc_spec_prompt1:
        _bugprint(bflag=CEO_GSLOCATE_debug, str =
	    "selector = _gsloc_spec_prompt1; '%s'\n",
	    var = `(char *) int_or_str_ptr` )
        if ( ( (char *) int_or_str_ptr)[0] )
	    strcpy ( p_CEO_GSLOCATE->spec_prompt1, (char *)int_or_str_ptr );
        break;

      case _gsloc_spec_prompt2:
        _bugprint(bflag=CEO_GSLOCATE_debug, str =
	    "selector = _gsloc_spec_prompt2; '%s'\n",
	    var = `(char *) int_or_str_ptr` )
        if ( ( (char *) int_or_str_ptr)[0] )
	    strcpy ( p_CEO_GSLOCATE->spec_prompt2, (char *)int_or_str_ptr );
        break;

      case  _gsloc_spec_prompt1_key:
        _bugprint(bflag=CEO_GSLOCATE_debug, str =
	    "selector = _gsloc_spec_prompt1_key; key = %d\n",
	    var = int_or_str_ptr )
        ex$message ( msgnumb = int_or_str_ptr,
            buff = p_CEO_GSLOCATE->spec_prompt1);
        break;
	
      case  _gsloc_spec_prompt2_key:
        _bugprint(bflag=CEO_GSLOCATE_debug, str =
	    "selector = _gsloc_spec_prompt2_key; key = %d\n",
	    var = int_or_str_ptr )
        ex$message ( msgnumb = int_or_str_ptr,
            buff = p_CEO_GSLOCATE->spec_prompt2);
        break;

      default:
	_bugprint(bflag=CEO_GSLOCATE_debug, str =
            "Burping action selector = %d back to CEO_LOCATE.action\n",
	    var = selector)
        status = om$send ( targetid = my_id,
            msg = message CEO_LOCATE.action ( selector,
						int_or_str_ptr, sts ),
            mode = OM_e_wrt_message );
#ifdef DEBUG
        _cob_check ( status, \
		"CEO_GSLOCATE.action:  CEO_LOCATE.action() failed." );
#endif
        break;
    }
quit:
  _bugprint(bflag=TFLAG, str = "-CEO_GSLOCATE.action:  selector = %d, sts = %d\n",
		var = `selector, *sts` )
  return OM_S_SUCCESS;
}
end implementation CEO_GSLOCATE;
