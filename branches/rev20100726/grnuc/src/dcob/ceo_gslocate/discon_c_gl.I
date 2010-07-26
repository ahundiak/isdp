/* ceo_gslocate/discon_c_gl.I --JAJ:06-02-88 */
class implementation CEO_GSLOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif

method disconnect_constructed ( int * sts ) 
{
  int	status;
  /* int count = 0; */

  
  _bugprint(bflag=TFLAG, str= "+CEO_GSLOCATE.disconnect_constructed:\n")

  /*** see if the graphic set contains any objects --JAJ:05-26-88 ***/
/******  don't check this anymore --JAJ:06-02-88  **********************
  status = gr$gsinqcount ( msg = sts, count = &count,
			   p_chanselect = &me->const_chansel );
  _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After gr$gsinqcount(me->const_chansel):  status=%d, *sts=%d, count=%d\n",
	var = `status, *sts, count`  )
  _cob_check2 ( status, *sts, \
	"CEO_GSLOCATE.action:  gr$gsinqcount() failed." );

  if ( count > 0 )
    {
***********************************************************************/
      _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"Sending down me->const_chansel gr$gsempty( )\n")
      status = gr$gsempty ( msg = sts,
			  p_chanselect = &me->const_chansel );
      _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After gr$gsempty:  status = %d, *sts = %d\n",
	var = `status,*sts` )

#ifdef DEBUG
      if ( !(1 & *sts & status) )
	{
	  fprintf(stderr,
	    "CEO_GSLOCATE.disconnect_constructed:  gr$gsempty() return status = %d, sts = %d\n",
	    status, *sts );
	  /*** *sts = status; ***/
	  /*** goto quit; ***/
	}
#endif
/******
    }
******/
         
quit:
  _bugprint(bflag=TFLAG, str =
    "-CEO_GSLOCATE.disconnect_constructed: status = %d, *sts = %d\n",
	var = `status,*sts` )
  return OM_S_SUCCESS;
}
end implementation CEO_GSLOCATE;
