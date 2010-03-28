/* ceo_gslocate/display_l_gl.I */
class implementation CEO_GSLOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_GSLOCATE_debug )
#endif

method display_located ( int * sts ) 
{
  int	status;
/* int	count = 0; */

  * sts = OM_S_SUCCESS;
  
  _bugprint(bflag=TFLAG, str = "+CEO_GSLOCATE.display_located:\n")

  /******  don't check this anymore --JAJ:06-02-88  ********************
  /*** see if the graphic set contains any objects --JAJ:05-26-88 ***
  status = gr$gsinqcount ( msg = sts, count = &count,
			   p_chanselect = &me->located_chansel );
  if ( count > 0 )
    {
  *********************************************************************/

      _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"Sending down me->located_chansel gr$gsdisplay(me->DisplayMode)\n")
      				/**** dpmode = GRbdhe, JAJ:05-26-88 ***/
      status = gr$gsdisplay ( msg =   sts,
			   dpmode =   ME.CEO_LOCATE->DisplayMode,
		     p_chanselect = & ME.CEO_LOCATE->located_chansel,
                       display_id = & ME.CEO_LOCATE->locate_ModuleInfo.md_id );

      _bugprint(bflag=CEO_GSLOCATE_debug, str =
	"After gr$gsdisplay:  status = %d, *sts = %d\n",
	var = `status,*sts` )

#ifdef DEBUG
      if ( !(1 & status & *sts) )
	{
	  fprintf(stderr,
	    "CEO_GSLOCATE.display_located:  gr$gsdisplay() return status = %d, sts = %d\n",
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
	"-CEO_GSLOCATE.display_located: status = %d, *sts =%d\n",
	var = `status,*sts` )
  return OM_S_SUCCESS;
}
end implementation CEO_GSLOCATE;
