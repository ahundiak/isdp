/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/display_c.I */	  /** moved from CEO -- JAJ:10-19-87 **/
class implementation CEO_LOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <lcmacros.h>	/*** need this for lc$get_channel_count() ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif

from GRgraphics  import GRdisplay;


method display_constructed ( int * sts )
{
  int	status;
  int	count = 0;


  _bugprint(bflag=TFLAG, str =
	"+CEO_LOCATE.display_constructed:  *sts = %d\n", var = *sts )

  * sts = OM_S_SUCCESS;

  /*******  replaced om$get_channel_count -- JAJ:09-09-87 *************/
  status = lc$get_channel_count ( p_chanselect = & me->const_chansel,
					count = & count );
  _bugprint(bflag=CEO_LOCATE_debug, str =
        "After lc$get_channel_count(=%d) of me->const_chansel: status = %d\n",
        var = `count, status` )
  _cob_check ( status, "CEO_LOCATE.display_constructed:  lc$get_channel_count failed");

  if ( count > 0 )
    {
      _bugprint(bflag=CEO_LOCATE_debug, str =
            "Sending down channel me->const_chansel GRgraphics.GRdisplay()\n" )
      _sendc ( me->const_chansel, GRgraphics.GRdisplay (
          (IGRlong *) sts, & me->ModuleInfo.md_env.matrix_type,
          me->ModuleInfo.md_env.matrix, & me->DisplayMode,
          & me->ModuleInfo.md_id ));
      _cob_check2( status,*sts, "CEO_LOCATE.display_constructed:  GRgraphics.GRdisplay() failed" );
    }
         
quit:
  _bugprint(bflag=TFLAG, str =
	"-CEO_LOCATE.display_constructed:  *sts = %d\n", var = *sts )
  return OM_S_SUCCESS;
}
end implementation CEO_LOCATE;
