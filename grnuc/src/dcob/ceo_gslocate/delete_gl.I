/* ceo_gslocate/delete.I */
/*
	Created:  8-24-87  
	Purpose:  To delete the CEO_GSLOCATE class object, along with
		  its associated graphic set object
	Modified:
*/
class implementation CEO_GSLOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <COBint.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif


method delete ( int f_defer_flag )  /* f_defer_flag is no longer used */
{
  int	  status,sts;


  _bugprint(bflag=TFLAG, str = "+CEO_GSLOCATE.delete:\n" )

	/***  empty the graphic set object ***/
  status = gr$gsempty ( msg = &sts,
	p_chanselect = &me->located_chansel );
  _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After gr$gsempty():  status = %d, sts = %d\n",
	 var = `status, sts` )
#ifdef DEBUG
  _cob_check2 ( status, sts, \
		"CEO_GSLOCATE.delete:  gr$gsempty() failed." );
#endif

	/***  delete the graphic set object ***/
  /**********  this is now done in gr$gsempty --JAJ:06-02-88 ***********
  status = gr$gsdissolve ( msg = &sts,
	p_chanselect = &me->located_chansel );
  _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After gr$gsdissolve():  status = %d, sts = %d\n",
	 var = `status, sts` )
  _cob_check2 ( status, sts, "" );
  *********************************************************************/

	/*** send my parent's delete message ***/
  _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"Sending my_id CEO_LOCATE.delete( 0 )\n" )
  status = om$send ( targetid = my_id,
		     mode = OM_e_wrt_message,
		     msg = message CEO_LOCATE.delete ( 0 ));
#ifdef DEBUG
  _cob_check ( status, \
	"CEO_GSLOCATE.delete:  CEO_LOCATE.delete() failed." );
#endif

quit:
  _bugprint(bflag=TFLAG,str="-CEO_GSLOCATE.delete: status[local]=%d\n",
	var = status)
  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}
end implementation CEO_GSLOCATE;
