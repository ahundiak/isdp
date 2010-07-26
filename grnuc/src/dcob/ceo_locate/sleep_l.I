/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/sleep_l.I */
/*
  erase located objects 
*/
class implementation CEO_LOCATE;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif
 
method sleep ( int position )
{
  int	status;

  _bugprint(bflag=TFLAG, str = "+CEO_LOCATE.sleep:  position = %d\n",
		var = position )
  
  status = om$send (
      targetid = my_id,
      msg = message CEO.sleep ( position ),
      mode = OM_e_wrt_message );
  _bugprint(bflag=CEO_LOCATE_debug, str =
	"Sent CEO.sleep:  status = %d\n", var = status )
#ifdef DEBUG
  _cob_check ( status, "CEO_LOCATE.sleep:  CEO.sleep failed." );
#endif

  /*********************************************   JAJ:06-07-89 ******
  if ( position == EX_suspend )
    {
      me->DisplayMode = GRhe;

      _send ( my_id, CEO_LOCATE.display_located ( & sts ));
      _bugprint(bflag=CEO_LOCATE_debug, str =
	"Sent CEO_LOCATE.display_located:  status = %d, sts = %d\n",
	var = `status,sts` )
      #ifdef DEBUG
      _cob_check2 ( status, sts, \
	  "CEO_LOCATE.sleep:  CEO_LOCATE.display_located failed." );
      #endif
    }
  ********************************************************************/


  _bugprint(bflag=TFLAG, str = "-CEO_LOCATE.sleep:  status = %d\n",
		var = status )
  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}
end implementation CEO_LOCATE;
