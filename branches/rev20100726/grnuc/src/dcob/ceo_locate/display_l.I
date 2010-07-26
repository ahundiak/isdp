/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/display_l.I */
class implementation CEO_LOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <lcmacros.h>	/*** need this for lc$get_channel_count() ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif

from GRgraphics import GRdisplay;

method display_located ( int * sts ) 
{
  int	status;
  int	count = 0;

  
  _bugprint(bflag=TFLAG, str = "+CEO_LOCATE.display_located:\n")

  *sts = OM_S_SUCCESS;

  /***** replaced om$get_channel_count() --	JAJ:09-09-87 **********/
  status = lc$get_channel_count ( p_chanselect = & me->located_chansel,
					count = & count );
  _bugprint(bflag=CEO_LOCATE_debug, str =
    "After lc$get_channel_count(me->located_chansel)=%d:  status=%d\n",
    var = `count, status` )

  if ( ! ( status & 1 ) )	/*** JAJ:04-16-89 ***/
    {
#ifdef DEBUG
      fprintf(stderr,
	"CEO_LOCATE.display_located:  lc$get_channel_count (me->located_chansel) failed.\n\n");
      om$report_error (sts=status);
#endif
      *sts = status;
      goto quit;
    }

  if ( count > 0 )
    {
      _bugprint(bflag=CEO_LOCATE_debug, str =
	"Sending down me->located_chansel GRgraphics.GRdisplay()\n")
      _bugprint(bflag=CEO_LOCATE_debug, str = "me->Displaymode = %d\n",
	var = `me->DisplayMode` )
      _bugprint(bflag=CEO_LOCATE_debug, str =
	"me->located_ModuleInfo.md_id.osnum[.objid]=%d,%d\n",
	var = `me->locate_ModuleInfo.md_id.osnum,me->locate_ModuleInfo.md_id.objid` )

       status = om$send ( msg = message GRgraphics.GRdisplay (
		   (IGRlong *) sts,
                 & ME.CEO_LOCATE->locate_ModuleInfo.md_env.matrix_type,
                   ME.CEO_LOCATE->locate_ModuleInfo.md_env.matrix,
                 & ME.CEO_LOCATE->DisplayMode,
                 & ME.CEO_LOCATE->locate_ModuleInfo.md_id ),
                p_chanselect = & ME.CEO_LOCATE->located_chansel );

      /***********************  -- JAJ:10-02-89  ***********************
       status = om$send ( msg = message GRgraphics.GRdisplay ( sts,
           &me->event1.located_object[0].module_info.md_env.matrix_type,
            me->event1.located_object[0].module_info.md_env.matrix,
           &me->DisplayMode,
           &me->ModuleInfo.md_id ),
            p_chanselect = &me->located_chansel);
      ****************************************************************/

      /******* old way -- JAJ:08-02-88 *********************************
      _sendc ( me->located_chansel, GRgraphics.GRdisplay (
         sts, & me->ModuleInfo.md_env.matrix_type,
          me->ModuleInfo.md_env.matrix, & me->DisplayMode,
          & me->ModuleInfo.md_id ));
      *****************************************************************/

      if ( ! ( status & *sts & 1 ) )	/*** JAJ:04-16-89 ***/
        {
#ifdef DEBUG
          fprintf(stderr,
	     "CEO_LOCATE.display_located:  GRgraphics.GRdisplay() failed\n\n" );
	  if ( ! ( 1 & status ) ) 
            om$report_error (sts=status);
	  if ( ! ( 1 & *sts ) ) 
            om$report_error (sts=*sts);
#endif
	  if ( ! ( 1 & status ) ) 
            *sts = status;
          /*** goto quit; ********** don't need this here ***/
        }
    }
         
quit:
  _bugprint(bflag=TFLAG, str =
	"-CEO_LOCATE.display_located:  status = %d, *sts = %d\n",
	var = `status,*sts` )
  return OM_S_SUCCESS;
}
end implementation CEO_LOCATE;
