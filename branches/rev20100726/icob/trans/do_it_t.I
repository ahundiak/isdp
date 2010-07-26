/* trans/do_it_t.I */
class implementation CEO;

#include <stdio.h>


#ifdef DEBUG
#include <COB_DBflags.h>
_debug(extern int COBtrace;)
_debug(extern int trans_debug;)
#define TFLAG ( COBtrace  ||  trans_debug )
#define TRANSFLAG ( trans_debug )
#endif


COBtrans_do_it ( trans_ptr, cmd_oid, sts )
  struct COBtrans * trans_ptr;
  OM_S_OBJID	    cmd_oid;
  int		  * sts;
{
  int	 	    status, ii;
  int		    is_so = _false;
  int		    dummy_sts;	/*** JAJ:10-03-88 ***/


  _bugprint(bflag=TFLAG, str =
	"+COBtrans_do_it:  trans_ptr=(0x)%x, cmd_oid = %d\n",
	var = `trans_ptr, cmd_oid` )

  status = OM_S_SUCCESS;

  /***  *sts = OM_S_SUCCESS ***/

  for ( ii = 0; ii < trans_ptr->num_pods ; ii++)
    {
      _bugprint(bflag=TRANSFLAG, str =
	"sending cmd_oid CEO.predicate( pred[%d]=%d, op[%d]=%d, &data, is_so=%d)\n",
	var = `ii, trans_ptr->predicate[ii], \
		trans_ptr->operator[ii], ii, is_so` )
      status = om$send ( targetid = cmd_oid, senderid = cmd_oid, 
			 msg = message CEO.predicate
				( trans_ptr->predicate[ii],
				  trans_ptr->operator[ii],
				(char *) & trans_ptr->data[ii],
				& is_so) );
      _bugprint(bflag=TRANSFLAG, str =
	"sent CEO.predicate( pred=%d, op=%d, data.i=%d, is_so=%d)\n",
	var = ` trans_ptr->predicate[ii], \
		trans_ptr->operator[ii], \
		trans_ptr->data[ii].i, is_so` )
      if ( ! (1&status) )
	{
	  fprintf(stderr,
	    "\nCOBtrans_do_it():  Error in CEO.predicate ( %d, %d, )\n",
	    trans_ptr->predicate[ii], trans_ptr->operator[ii] );
	  om$report_error ( sts = status );
	  goto quit;
	}

      if ( is_so )
	{
	  _bugprint(bflag=TRANSFLAG, str =
	    "sending cmd_oid CEO.action(_set_next_state=%d, next_state_id=%hd,dummy_sts)\n",
	    var = `_set_next_state, trans_ptr->next_state_id` )
	    status = om$send ( targetid = cmd_oid, senderid = cmd_oid, 
			 msg = message CEO.action ( _set_next_state,
			(int) trans_ptr->next_state_id, & dummy_sts ));
	  _bugprint(bflag=TRANSFLAG, str =
	    "sent CEO.action ( _set_next_st, next_state_id=%hd, dummy_sts= %d\n",
	    var = `trans_ptr->next_state_id, dummy_sts` )
	  if ( ! (1&status) )   /** don't check dummy_sts -- _set_next_st **/
	    {			/** doesn't make it OM_S_SUCCESS     **/
	      fprintf(stderr,
	        "\nCOBtrans_do_it():  CEO.action ( set next state = %hd ) failed.\n",
	        trans_ptr->next_state_id );
	      om$report_error ( sts = status );
	      goto quit;
	    }

	  _COB_for_list ( at_ptr, list, trans_ptr->act_trans,\
						struct COBact_trans )
	    if ( at_ptr->is_trans )
	      {
		_bugprint(bflag=TRANSFLAG, str =
		    "Calling COBtrans_do_it ( trans_ptr=(0x)%x,...)\n",
		    var = `& at_ptr->at.trans` )
		status = COBtrans_do_it ( & at_ptr->at.trans,
							cmd_oid, sts );
	      }
	    else
	      {
		_bugprint(bflag=TRANSFLAG, str =
		  "Calling COBactions_do_it ( action_ptr=(0x)%x,...)\n",
		    var = `& at_ptr->at.action` )
		status = COBactions_do_it ( & at_ptr->at.action,
							cmd_oid, sts );
	      }

	    _bugprint(bflag=TRANSFLAG, str =
	       "Called COBact/trans_do_it():  status = %d, *sts = %d\n",
		    var = `status, *sts` )
	    if ( status == OM_I_STOP_SENDING || !( 1 & status ) ||
		 * sts == COB_E_ARG_NOT_FOUND )
	      {
		status = OM_I_STOP_SENDING;
		goto quit;
	      }

	  _COB_end_for_list

	  status = OM_I_STOP_SENDING;

	  break;  /*** don't try any more response types ***/
	} /* end of if (is_so) */

    }  /* end of for loop */

quit:
  _bugprint(bflag=TFLAG, str =
	"-COBtrans_do_it:  ret status=%d, *sts=%d, is_so = %d\n",
	var = `status, *sts, is_so` )
  return status;
}


/*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/
/*   COBtrans_dump gets included only if DEBUG set  -- JAJ:11-06-87  */
/*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*/

#ifdef DEBUG

#include <exdef.h>

COBtrans_dump ( trans_ptr, state_action, fp, sts )
  struct COBtrans * trans_ptr;
  char		    state_action;
  FILE		  * fp;
  int		  * sts;
{
  int	  	    ii;
  char		  * trans_str;

  _bugprint(bflag = TFLAG, str =
	"+COBtrans_dump:  trans_ptr = (0x)%x, state_action = '%c'\n",
	var = `trans_ptr, state_action` )

  if ( state_action )
    trans_str = "      t";
  else
    trans_str = "	  t";

  fprintf ( fp, "%s(%hd", trans_str, trans_ptr->next_state_id );

  for ( ii = 0; ii < trans_ptr->num_pods ; ii++)
    {
      switch ( trans_ptr->predicate[ii] )
	{
	  case EX_DATA:
	  case D_DATA:
	  case _ceo_return_code:
	  case _ceo_mytype:
	    fprintf ( fp, ",%d,%d,%d",
		     trans_ptr->predicate[ii],
		     trans_ptr->operator[ii],
		     trans_ptr->data[ii].i );
	    break;
	  case EX_VALUE:
	  case _ceo_angle:
	  case _ceo_distance:
	  case _ceo_scalar:
	    fprintf ( fp, ",%g,%d,%d",
		     trans_ptr->predicate[ii],
		     trans_ptr->operator[ii],
		     trans_ptr->data[ii].d );
	    break;
	  default:
	    if ( trans_ptr->data[ii].str[0] )
	      fprintf ( fp, ",%d,%d,\"%s\"",
		       trans_ptr->predicate[ii],
		       trans_ptr->operator[ii],
		       trans_ptr->data[ii].str );
	    else
	      fprintf ( fp, ",%d,%d,",
		       trans_ptr->predicate[ii],
		       trans_ptr->operator[ii] );
	    break;
	}
    }
  fprintf ( fp, ")\n" );

  if ( trans_ptr->act_trans )
    {
      fprintf ( fp, "	{\n" );

      _COB_for_list ( at_ptr, list, trans_ptr->act_trans, \
						struct COBact_trans )
	if ( at_ptr->is_trans )
	  {
	    COBtrans_dump ( & at_ptr->at.trans, _false, fp );
	  }
	else
	  {
	    COBactions_dump ( & at_ptr->at.action, _false, fp );
	  }

      _COB_end_for_list

      fprintf ( fp, "	}\n" );
    }

quit:
  _bugprint(bflag = TFLAG, str = "-COBtrans_dump:\n" )

  ;	/*** need the ; for compiling w/o DEBUG set ***/
}  /*** end of COBtrans_dump () ***/

#endif

end implementation CEO;
