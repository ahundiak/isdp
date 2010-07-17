/*
	I/STRUCT
*/
class implementation VSmergeExpCv ;

#include <stdio.h>
#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
#include "vsvecmxproto.h"

/*----------------------------------------------------------------------------*/
method NDdelete( struct GRmd_env *myEnv )
{
  long			sts,	   /* OM return code.		      */
			msg ;	   /* OM completion code.	      */
  int			i,	   /* Loop index.		      */
			count ;    /* Count of my parents.	      */
  struct GRid		expCv[2] ; /* Expanded curves parents.	      */
  struct GRmd_env 	md_env ;   /* Module env of expanded curves.  */

  SetProc( VSmergeExpCv_NDdelete ) ; Begin ; __DBGpr_me() ;

  __enterMethod ( name = "NDdelete" //, argfmt = "", args = ``
  );

  /*
   * Get my expanded curves parents.
   */
  sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
                                                        expCv,
                                                        2,
                                                        NULL,
                                                        1,
                                                        2,
                                                        &count ),
                 targetid = my_id ) ;

  __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

  __DBGpr_int( "Count of expanded curves parents", count-1 ) ;

  /*
   * Unconsume and redisplay my expanded curves parents.
   */
  for( i=0; i<count-1; i++ )
  {
    __DBGpr_obj( "Expanded curve parent", expCv[i] ) ;

    sts = VSgetVirtualInfo( &msg,
                            expCv +i,
                            &md_env,
                            expCv +i ) ;

    __CheckRC( sts, msg, "VSgetVirtualInfo", wrapup ) ;

    VSmulmx( myEnv->_MATRIX,
             md_env._MATRIX,
             md_env._MATRIX,
             &md_env._MATRIX_TYPE ) ;

    __DBGpr_mat( "Matrix of expanded curve", md_env._MATRIX ) ;

    sts = vs$unconsume( msg 	= &msg,
                        object	= expCv +i,
                        mod_env	= &md_env ) ;

    __CheckRC( sts, msg, "vs$unconsume", wrapup ) ;

    if (VDcomment)
    {
      sts = vs$bulk_display( dpmode	= GRbd,
                             grids	= expCv +i,
                             theEnv	= &md_env ) ;

      __CheckRC( sts, 1, "vs$bulk_display", wrapup ) ;
    }
    else
    {
      sts = om$send( msg      = message VSmergeExpCv.NDdelete( &md_env ),
                     targetos = expCv[i].osnum,
                     targetid = expCv[i].objid ) ;
    }
  }

  /*
   * Delete myself.
   */
  sts = om$send( msg	= message VSexpandedCv.NDdelete( myEnv ),
                 mode	= OM_e_wrt_message,
                 targetid = my_id ) ;

wrapup :

    __exitMethod ( name = "NDdelete", argfmt = "sts = %d, msg = %#x", args = `sts, msg` );

  End
  return sts ;

} /* NDdelete */
/*----------------------------------------------------------------------------*/

end implementation VSmergeExpCv ;
