/* ceo_gslocate/wakeup_l.I */
class implementation CEO_GSLOCATE;

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif

from CDO import get;

method wakeup ( int position )
{
  int	 status, sts;
  int	 count;

  _bugprint(bflag=TFLAG, str = "+CEO_GSLOCATE.wakeup:  position = %d\n",
		var = position )

  sts = status = OM_S_SUCCESS;
  if ( ! position )
    {
      status = om$send (
          targetid = my_id,
          msg = message CEO_LOCATE.wakeup ( position ),
          mode = OM_e_wrt_message );
      _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"Sent CEO_LOCATE.wakeup:  status = %d\n", var = status )
      if ( ! ( status & 1 )) goto quit;
    }

  /*** see if the graphic set contains any objects ***/

  status = gr$gsinqcount ( msg = &sts, count = &count,
			   p_chanselect = &me->located_chansel );
  _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After gr$gsinqcount:  status = %d, sts = %d\n, count = %d",
	var = `status, sts, count`  )
  _check2 ( status, sts );

  if ( count )
    {
      status = gr$gsdisplay ( msg = &sts, dpmode = GRbdhd,
			   p_chanselect = &me->located_chansel );
      _check2 ( status, sts );
    }

quit:
  _bugprint(bflag=TFLAG, str = "-CEO_GSLOCATE.wakeup:  status = %d, sts = %d\n",
	var = `status, sts`  )
  if ( status == OM_S_SUCCESS && sts != OM_S_SUCCESS ) status = sts;
  return status;
}
end implementation CEO_GSLOCATE;
