/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/delete.I */
/*
	Created:  09-16-87  
	Purpose:  To do a lc$wild_disconnect on the locate channel of
		  the CEO_LOCATE class object
*/
class implementation CEO_LOCATE;


#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <griomacros.h>	    /*** need this for clear_vsd ***/
#include <lcmacros.h>	    /*** need this for lc$wild_disconnect ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


method delete ( int f_defer_flag )  /* f_defer_flag is no longer used */
{
  int	  status;


  _bugprint(bflag=TFLAG, str = "+CEO_LOCATE.delete:\n" )

  /*** clear out the Variable String Descriptor ***/
  clear_vsd;

  /*** disconnect the stuff on the const channel -- JAJ:09-16-87  ***/
  status = lc$wild_disconnect ( p_chanselect = & me->const_chansel );
  _bugprint(bflag = CEO_LOCATE_debug, str =
    "After lc$wild_disconnect:  status = %d\n", var = status )
#ifdef DEBUG
  _cob_check ( status, \
	  "CEO_LOCATE.delete:  lc$wild_disconnect( me->const_chansel ) failed." );
#endif

	/*** disconnect the stuff on the located channel  ***/
  status = lc$wild_disconnect ( p_chanselect = & me->located_chansel );
  _bugprint(bflag = CEO_LOCATE_debug, str =
    "After lc$wild_disconnect:  status = %d\n", var = status )
#ifdef DEBUG
  _cob_check ( status, \
	  "CEO_LOCATE.delete:  lc$wild_disconnect( me->located_chansel ) failed." );
#endif


	/*** send my parent's delete message ***/
  _bugprint(bflag=CEO_LOCATE_debug, str =
	"Sending my_id CEO.delete( 0 )\n" )
  status = om$send ( targetid = my_id,
		     mode = OM_e_wrt_message,
		     msg = message CEO.delete ( 0 ));
#ifdef DEBUG
  _cob_check ( status, "CEO_LOCATE.delete:  CEO.delete() failed." );
#endif


  _bugprint(bflag=TFLAG,str="-CEO_LOCATE.delete: status[local]=%d\n",
	var = status)
  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}
end implementation CEO_LOCATE;
