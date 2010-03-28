/* ceo_gslocate/display_c_gl.I */
class implementation CEO_GSLOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif

method display_constructed ( int * sts ) 
{
  int	status;
/****
  int	count = 0;
****/

  
  _bugprint(bflag=TFLAG, str = "+CEO_GSLOCATE.display_constructed:\n")

  /*** see if the graphic set contains any objects --JAJ:05-26-88 ***/
/******  don't check this anymore --JAJ:06-02-88  **********************
  status = gr$gsinqcount ( msg = sts, count = &count,
			   p_chanselect = &me->const_chansel );
  _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After gr$gsinqcount(me->const_chansel):  status=%d, *sts=%d, count=%d\n",
	var = `status, *sts, count`  )
  _cob_check2 ( status, *sts, "" );

  if ( count > 0 )
    {
***********************************************************************/
      _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"Sending down me->const_chansel gr$gsdisplay( GRhe )\n")
      status = gr$gsdisplay ( msg = sts, dpmode = me->DisplayMode,
			  p_chanselect = &me->const_chansel );
      _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After gr$gsdisplay:  status = %d, *sts = %d\n",
	var = `status,*sts` )

#ifdef DEBUG
      if ( !(1 & *sts & status) )
	{
	  fprintf(stderr,
	    "CEO_GSLOCATE.display_constructed:  gr$gsdisplay() return status = %d, sts = %d\n",
	    status, *sts );
	  /*** *sts = status; ***/
	  /*** goto quit; ***/
	}
#endif
/*******
    }
*******/
         
quit:
  _bugprint(bflag=TFLAG, str =
	"-CEO_GSLOCATE.display_constructed: status = %d, *sts = %d\n",
	var = `status,*sts` )
  return OM_S_SUCCESS;
}
end implementation CEO_GSLOCATE;
