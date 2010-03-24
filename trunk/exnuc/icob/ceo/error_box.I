/* ceo/error_box.I --JAJ:08-08-88 */
/*
  if argument key is non-null, retrieve char string from message system.
  display current error_box chars in Environ V error_box
*/
class implementation CEO;


#include <stdio.h>
#include <OMmacros.h>	/*** need this for OM_SET_DIMENSION ***/
#include <execmsg.h>	/*** need this for EX_F_Var1 ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_debug )
#endif


method error_box ( char * error_box_string )
{
  int status;

  _bugprint(bflag=TFLAG, str =
     "+CEO.error_box:  error_box_string = '%s'; me->error_box = '%s'\n",
	var = `error_box_string, me->error_box` )

  if ( error_box_string )
    {
	status = om$vla_set_dimension
		( varray = ME.CEO->error_box,
		    size = strlen ( error_box_string ) + 1 );
	_cob_check ( status, \
		 "CEO.error_box:  om$vla_set_dimension failed" );

	strcpy ( me->error_box, error_box_string );
    }

  ex$message( msgnumb = EX_F_Var1,
	      type = "%s",
	      var = `me->error_box` );

quit:
  _bugprint(bflag=TFLAG, str =
     "-CEO.error_box:  error_box_string = '%s'; me->error_box = '%s'\n",
	var = `error_box_string, me->error_box` )
  return OM_S_SUCCESS;
}
end implementation CEO;
