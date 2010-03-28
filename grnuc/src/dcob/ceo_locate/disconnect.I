/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/disconnect.I */	   /** moved from CEO-- JAJ:10-19-87 **/
class implementation CEO_LOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <lcmacros.h>

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


method disconnect_constructed ( int * sts ) 
{
  /**** int count = 0; ***/

  _bugprint(bflag=TFLAG, str =
	"+CEO_LOCATE.disconnect_constructed:  *sts = %d\n", var = *sts )

  /***** replaced om$get_channel_count():   JAJ:09-09-87 **************/
/******  don't check this anymore --JAJ:06-02-88  **********************
  * sts = lc$get_channel_count ( p_chanselect = & me->const_chansel,
				count = & count );
  _cob_check ( *sts, \
     "CEO_LOCATE.disconnect:  lc$get_channel_count() failed." );

  _bugprint(bflag=CEO_LOCATE_debug, str =
	"After lc$get_channel_count(=%d) of me->const_chansel\n",
	var = count )
  if ( count )
    {
***********************************************************************/
      /***** replaced Root.wild_disconnect():   JAJ:09-09-87 **********/
      _bugprint(bflag=CEO_LOCATE_debug, str =
	   "Doing lc$wild_disconnect(me->const_chansel)\n" )
      * sts = lc$wild_disconnect ( p_chanselect = &me->const_chansel );

#ifdef DEBUG
      if ( !(*sts & 1) )
	{
	  fprintf(stderr,
	    "CEO_LOCATE.disconnect_constructed:  lc$wild_disconnect( &me->const_chansel) return status = %d\n", * sts );
	  /*** goto quit; ***/
	}
#endif
/**** } ****/


  _bugprint(bflag=TFLAG, str =
	"-CEO_LOCATE.disconnect_constructed:  *sts = %d\n", var = *sts )
  return OM_S_SUCCESS;
}
end implementation CEO_LOCATE;
