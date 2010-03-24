/* COBstate/do_it_s.I */
class implementation CEO;

#include <stdio.h>

#ifdef DEBUG
#include <COB_DBflags.h>
_debug(extern int COBtrace;)
_debug(extern int state_debug;)
#define TFLAG ( COBtrace || state_debug )
#endif


COBstate_do_it ( state_ptr, cmd_oid, sts )
  struct COBstate * state_ptr;
  OM_S_OBJID	    cmd_oid;
  int		  * sts;
{
  int	  status;

  _bugprint(bflag=TFLAG, str =
	"+COBstate_do_it:  state_ptr = (0x)%x,  cmd_oid=%d\n",
	var = `state_ptr, cmd_oid` )

  _bugprint(bflag=state_debug, str =
	    "Sending CEO.action ( _event_mask, state_ptr->mask=%d )\n",
	    var = state_ptr->mask )
  status = om$send ( senderid = cmd_oid, targetid = cmd_oid,
		     msg = message CEO.action
			( _event_mask, state_ptr->mask, sts ));
  if ( ! (1&status) )
    {
      fprintf(stderr,
        "\nCOBstate_do_it():  CEO.action ( event_mask = %d ) failed.\n",
        state_ptr->mask );
      om$report_error ( sts = status );
      goto quit;
    }

  * sts = OM_S_SUCCESS;

  _COB_for_list ( at_ptr, list, state_ptr->act_trans,\
						struct COBact_trans )
    if ( at_ptr->is_trans )
      {
	_bugprint(bflag=state_debug, str =
	    "Calling COBtrans_do_it ( trans_ptr=(0x)%x,...)\n",
	    var = `& at_ptr->at.trans` )
	status = COBtrans_do_it ( & at_ptr->at.trans, cmd_oid, sts );
      }
    else
      {
	_bugprint(bflag=state_debug, str =
	  "Calling COBactions_do_it ( action_ptr=(0x)%x,...)\n",
	    var = `& at_ptr->at.action` )
	status = COBactions_do_it ( & at_ptr->at.action, cmd_oid, sts );
      }

    _bugprint(bflag=state_debug, str =
       "Called COBact/trans_do_it():  status = %d, *sts = %d\n",
	    var = `status, *sts` )
    if ( status == OM_I_STOP_SENDING || !( 1 & status ) ||
	 * sts == COB_E_ARG_NOT_FOUND )
      {
	goto quit;
      }

  _COB_end_for_list

quit:
  _bugprint(bflag=TFLAG, str =
	"-COBstate_do_it:  ret status=%d, *sts=%d\n",
	var = `status,*sts` )
  return status;
}  /*** COBstate_do_it() ***/



/*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/
/*   COBstate_dump gets included only if DEBUG set  -- JAJ:11-06-87  */
/*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/

#ifdef DEBUG

COBstate_dump ( state_ptr, fp )
  struct COBstate * state_ptr;
  FILE		  * fp;
{
  _bugprint(bflag=TFLAG, str = "+COBstate_dump:  state_ptr = (0x)%x\n",
			var = state_ptr )

  fprintf ( fp, "s(%d)\n{\n", state_ptr->state_id );

  _COB_for_list ( at_ptr, list, state_ptr->act_trans, \
						struct COBact_trans )
    if ( at_ptr->is_trans )
      {
	    COBtrans_dump ( & at_ptr->at.trans, _true, fp );
      }
    else
      {
	    COBactions_dump ( & at_ptr->at.action, _true, fp );
      }
  _COB_end_for_list

  fprintf ( fp, "}\n" );

quit:
  _bugprint(bflag=TFLAG, str = "-COBstate_dump:\n" )

  ;	/*** need the ; for compiling w/o DEBUG set ***/
}  /*** end of COBstate_dump() ***/

#endif

end implementation CEO;
