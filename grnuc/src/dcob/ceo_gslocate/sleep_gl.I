/* ceo_gslocate/sleep_l.I */
/*
  erase located objects 
*/
class implementation CEO_GSLOCATE;

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif
 
method sleep ( int position )
{
  int	status = OM_S_SUCCESS, sts;

  _bugprint(bflag=TFLAG, str = "+CEO_GSLOCATE.sleep:  position = %d\n",
		var = position )
  
  status = om$send (
      targetid = my_id,
      msg = message CEO_LOCATE.sleep ( position ),
      mode = OM_e_wrt_message );
  _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"Sent CEO.sleep:  status = %d\n", var = status )
  _check ( status );

  status = gr$gsdisplay ( msg = &sts, dpmode = GRbdhe,
			  p_chanselect = &me->located_chansel );
  _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After gr$gsdisplay:  status = %d, sts = %d\n",
	var = `status,sts` )
  _check2 ( status, sts );

quit:
  _bugprint(bflag=TFLAG, str = "-CEO_GSLOCATE.sleep:  status = %d\n",
		var = status )
  return status;
}
end implementation CEO_GSLOCATE;
