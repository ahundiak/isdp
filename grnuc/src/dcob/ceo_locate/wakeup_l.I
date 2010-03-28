/* #######################    APOGEE COMPILED   ######################## */
/* ceo_locate/wakeup_l.I */
class implementation CEO_LOCATE;

#include <coimport.h>	/* must be 1st for shared libs-- JAJ:11-01-88 */
#include <stdio.h>
#include <grdpbmacros.h>  /*** need this for gr$get_active_xxx ***/

#ifdef DEBUG
#include <COB_DBflags.h>
#define TFLAG ( COBtrace || CEO_LOCATE_debug )
#endif


method wakeup ( int position )
{
  int	  NumberOfBytes, BytesReceived;
  int	  status, sts;

	/*** Replace all references to non-VLA instance data	    ***/
	/*** with local pointers, to reduce .o size -- JAJ:01-21-89 ***/
  struct CEO_LOCATE_instance	* p_CEO_LOCATE = ME.CEO_LOCATE;

  _bugprint(bflag=TFLAG, str = "+CEO_LOCATE.wakeup:  position = %d\n",
		var = position )

  sts = OM_S_SUCCESS;

  status = om$send (
          targetid = my_id,
          msg = message CEO.wakeup ( position ),
          mode = OM_e_wrt_message );
  _bugprint(bflag=CEO_LOCATE_debug, str =
	"Sent CEO.wakeup:  status = %d\n", var = status )
#ifdef DEBUG
  _cob_check ( status, "CEO_LOCATE.wakeup:  CEO.wakeup failed." );
#endif

  /***************************************  JAJ:06-07-89 *************
  if ( position == EX_suspend )
    {
      p_CEO_LOCATE->DisplayMode = GRhd;

      _send ( my_id, CEO_LOCATE.display_located ( & sts ));
      _bugprint(bflag=CEO_LOCATE_debug, str =
	"Sent CEO_LOCATE.display_located:  status = %d, sts = %d\n",
	var = `status, sts`  )
      #ifdef DEBUG
      _cob_check2 ( status, sts, \
	  "CEO_LOCATE.wakeup:  CEO_LOCATE.display_located() failed." );
      #endif
    }
  *******************************************************************/

  /****** Start of stuff moved from CEO--JAJ:10-19-87 *****************/
  _bugprint(bflag=CEO_LOCATE_debug, str = "Calling gr$get_active_scale()\n" )
  NumberOfBytes = sizeof( p_CEO_LOCATE->ActiveScale );
  gr$get_active_scale(
          msg = &status,
          sizbuf = &NumberOfBytes,
          buffer = &p_CEO_LOCATE->ActiveScale,
          nret = &BytesReceived );
  if ( !( 1 & status ) )
  {
      _bugprint(bflag = 1,
	str = "CEO_LOCATE.wakeup:  Call to  gr$get_ActiveScale() failed:  status = 0x%x\n",
	var = status )
      goto quit;
  }

  _bugprint(bflag=CEO_LOCATE_debug, str = "Calling gr$get_active_angle()\n" )
  NumberOfBytes = sizeof( p_CEO_LOCATE->ActiveAngle );
  gr$get_active_angle(
          msg = &status,
          sizbuf = &NumberOfBytes,
          buffer = &p_CEO_LOCATE->ActiveAngle,
          nret = &BytesReceived );
  if ( !( 1 & status ) )
  {
      _bugprint(bflag = 1,
	str = "CEO_LOCATE.wakeup:  Call to  gr$get_ActiveAngle() failed:  status = 0x%x\n",
	var = status )
      goto quit;
  }

  _bugprint(bflag=CEO_LOCATE_debug, str = "Calling gr$get_active_display()\n" )
  NumberOfBytes = sizeof( p_CEO_LOCATE->ActiveDisplay );
  gr$get_active_display(
          msg = &status,
          sizbuf = &NumberOfBytes,
          buffer = &p_CEO_LOCATE->ActiveDisplay,
          nret = &BytesReceived );
  if ( !( 1 & status ) )
  {
      _bugprint(bflag = 1,
	str = "CEO_LOCATE.wakeup:  Call to  gr$get_active_display() failed:  status = 0x%x\n",
	var = status )
      goto quit;
  }

  _bugprint(bflag=CEO_LOCATE_debug, str = "Calling gr$get_active_level()\n" )
  NumberOfBytes = sizeof( p_CEO_LOCATE->ActiveLevel );
  gr$get_active_level(
          msg = &status,
          sizbuf = &NumberOfBytes,
          buffer = &p_CEO_LOCATE->ActiveLevel,
          nret = &BytesReceived );
  if ( !( 1 & status ) )
  {
      _bugprint(bflag = 1,
	str = "CEO_LOCATE.wakeup:  Call to  gr$get_active_level() failed:  status = 0x%x\n",
	var = status )
      goto quit;
  }

  _bugprint(bflag=CEO_LOCATE_debug, str = "Calling gr$get_database_type()\n" )
  NumberOfBytes = MAX_DB_TYPE_SIZE;
  gr$get_database_type(
              msg = &status,
              sizbuf = &NumberOfBytes,
              buffer =  p_CEO_LOCATE->DatabaseType,
              nret = &BytesReceived );
  if ( !( 1 & status ) )
  {
      _bugprint(bflag = 1,
	str = "CEO_LOCATE.wakeup:  Call to  gr$get_database_type() failed:  status = 0x%x\n",
	var = status )
      goto quit;
  }
/******  end of stuff moved from CEO ****************************/

quit:
  _bugprint(bflag=TFLAG, str = "-CEO_LOCATE.wakeup:  status = %d, sts = %d\n",
	var = `status, sts`  )
  return OM_S_SUCCESS;	/*** don't return "status" -- JAJ:04-06-88 ***/
}
end implementation CEO_LOCATE;
