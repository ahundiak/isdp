/* trans/set_t.I */
class implementation CEO;

#include <stdio.h>
#include <exdef.h>
#include <COBint.h>	/* need this for _attr_type ---  JAJ:12-02-88 */


#ifdef DEBUG
#include <COB_DBflags.h>
_debug(extern int read_debug;)
#define TFLAG ( read_debug )
#define TRANSFLAG ( read_debug )
#endif


void COBtrans_set (  trans_ptr, state_ptr, cmd_oid, val, num_attrs,
		ceo_free_trans_pods_ptr,
		ceo_free_trans_pods_index,
		ceo_free_strs_ptr,
		ceo_free_strs_indices,
		ceo_free_strs_index,
		ceo_free_strs_size,
		sts )
  struct COBtrans	* trans_ptr;
  struct COBstate	* state_ptr;
  OM_S_OBJID		  cmd_oid;
  _attr_type		  val [];
  int			  num_attrs;
  char			  ceo_free_trans_pods_ptr[];
  int			* ceo_free_trans_pods_index;
  char		       ** ceo_free_strs_ptr[];
  int			* ceo_free_strs_indices[];
  int			* ceo_free_strs_index;
  int			* ceo_free_strs_size;
  int			* sts;
{
  int		  status, ii;
  int		  attr_dim;	/* counter for val[] array */
  long		  out_m;
  extern char	* COB_shove_str ( );


  _bugprint(bflag = TFLAG, str =
   "+COBtrans_set:  trans_ptr=(0x)%x, state_ptr=(0x)%x, num_attrs=%d\n",
	var = `trans_ptr, state_ptr, num_attrs` )

	/*** init a few things ***/
  * sts = OM_S_SUCCESS;

	/***  val[0] has the next state ***/
  trans_ptr->next_state_id = val[0].val.i;
  _bugprint(bflag = TRANSFLAG, str =
	"next_state_id = %hd  =?=  val[0].val.i = %d\n",
	var = `trans_ptr->next_state_id, val[0].val.i` )

	/***  calculate the number of ( pred, op, data ) triples ***/
  trans_ptr->num_pods =  ( num_attrs - 1 ) / 3 ;
  _bugprint(bflag = TRANSFLAG, str =
	"num_pods = %d  =?= (num_attrs - 1)/3 = %d\n",
	var = `trans_ptr->num_pods, (num_attrs-1)/3` )

  /*** Get some memory for the ( pred, op, data ) triple(s) ***/

	/*** This needs to start on a (double) boundary. ***/
	/***   SO ALWAYS PUT IT FIRST!			 ***/
  trans_ptr->data	= ( data_val * )
	       & ceo_free_trans_pods_ptr[ *ceo_free_trans_pods_index ];

  (*ceo_free_trans_pods_index) +=
				trans_ptr->num_pods * sizeof(data_val) ;

	/*** This needs to start on an (int) boundary. ***/
  trans_ptr->predicate	= ( int * )
	      &	ceo_free_trans_pods_ptr[ *ceo_free_trans_pods_index ];

  (*ceo_free_trans_pods_index) += trans_ptr->num_pods * sizeof(int) ;


	/*** This needs to start on an (int) boundary. ***/
  trans_ptr->operator	= ( int * )
	      &	ceo_free_trans_pods_ptr[ *ceo_free_trans_pods_index ];

  (*ceo_free_trans_pods_index) += trans_ptr->num_pods * sizeof(int) ;


  for ( ii = 0, attr_dim = 0 ; ii < trans_ptr->num_pods ; ii++)
    {
      _bugprint(bflag = TRANSFLAG, str =
	    "TOP of LOOP: ii=%d, attr_dim=%d\n", var = `ii, attr_dim` )

	  /***************** case _trans_pred: ************************/
      attr_dim ++;
      trans_ptr->predicate[ii] = val[attr_dim].val.i;
      _bugprint(bflag = TRANSFLAG, str =
	"trans_ptr->predicate[%d]=%d  =?=  val[%d].val.i=%d\n",
	var=`ii, trans_ptr->predicate[ii], attr_dim, val[attr_dim].val.i` )

      if ( state_ptr )
	{					/*** JAJ:10-21-87 ***/
	    /**** make a get_event mask out of response type ****/
	    /** KLUDGE NOTE:  out_m is sent thru the traditional **/
	    /**   * sts argument in this next send -- so DON'T   **/
	    /**	check * sts for SUCCESS immediately after    **/
          status = om$send ( targetid = cmd_oid, senderid = cmd_oid,
		      msg = message CEO.action ( _convert_resp_to_mask,
				 	    trans_ptr->predicate[ii],
					    (int *) & out_m ) );
          _bugprint(bflag = TRANSFLAG, str =
	      "Sent CEO.action( _convert_resp_to_mask, out_m = %d)\n",
	      var = out_m )
			/** don't do a _cob_check2() here **/
	  if ( ! (1&status) )
	    {
	      fprintf(stderr,
	        "\nCOBtrans_set():  CEO.action(_convert_resp_to_mask) failed.\n" );
	      om$report_error ( sts = status );
	      goto quit;
	    }

          if ( out_m )
	    {
		/*** this line replaces COBstate_set() ***/
	      state_ptr->mask |= out_m;

	      _bugprint(bflag = TRANSFLAG, str =
		  "OR-ed %d into state mask = %ld\n",
		  var = `out_m, state_ptr->mask` )
	    }
        }


	/********************   case _trans_op:  **********************/
      attr_dim ++;
      trans_ptr->operator[ii] = val[attr_dim].val.i;
      _bugprint(bflag = TRANSFLAG, str =
	"trans_ptr->operator[%d]=%d  =?= val[%d].val.i = %d\n",
	var = `ii, trans_ptr->operator[ii], attr_dim, val[attr_dim].val.i` )


	/********************  case _trans_data: **********************/
      attr_dim ++;
      switch ( trans_ptr->predicate[ii] )
        {
          case EX_DATA:
          case _ceo_return_code:
          case _ceo_mytype:
            trans_ptr->data[ii].i  =
				   eval_str ( val [attr_dim].val.str );
            _bugprint(bflag = TRANSFLAG, str =
                "trans_ptr->data[%d].i = %d from eval_str ('%s')\n",
                var= `ii,trans_ptr->data[ii].i,val[attr_dim].val.str`)
            break;

          case EX_VALUE:
          case _ceo_angle:
          case _ceo_distance:
          case _ceo_scalar:
	    if ( trans_ptr->operator[ii] == _ceo_subtype )
	      {
		trans_ptr->data[ii].i  =
				    eval_str ( val[attr_dim].val.str );
		_bugprint(bflag = TRANSFLAG, str =
		    "trans_ptr->data[%d].i = %d from eval_str ('%s')\n",
		    var=`ii,trans_ptr->data[ii].i,val[attr_dim].val.str`)
	      }
	    else
	      { /***** atof doesn't work right so use sscanf ****/
                sscanf ( val[attr_dim].val.str , "%lf",
				& trans_ptr->data[ii].d );
                _bugprint(bflag = TRANSFLAG, str =
	           "\n\t***** Setting trans_ptr->data[%d].d = %lf\n",
			var = `ii, trans_ptr->data[ii].d` )
                _bugprint(bflag = TRANSFLAG, str =
		    "\t***** (val[%d].val.str) = '%s'\n",
		    var = `attr_dim, val[attr_dim].val.str` )
	      }
            break;

	      /*** this is tied to COBtrans_delete() --JAJ:11-03-88***/
          case EX_STRING:
          case EX_CHAR:	/*** JAJ:02-08-88 ***/
	  case _ceo_text_value:
	  case _ceo_null_text_value:
	  case _ceo_null_string:
	    if ( trans_ptr->operator[ii] == _ceo_subtype )
	      {
		trans_ptr->data[ii].i  =
				eval_str ( val[attr_dim].val.str );
		_bugprint(bflag = TRANSFLAG, str =
		    "trans_ptr->data[%d].i = %d from eval_str ('%s')\n",
		    var=`ii,trans_ptr->data[ii].i,val[attr_dim].val.str`)
		break;
	      }

	  default:
            _bugprint(bflag = TRANSFLAG, str = "\t[DEFAULT]\n" )

	    _bugprint(bflag = TRANSFLAG, str =
                 "Before COB_shove_str:  val[%d].val.str=(0x)%x = '%s'\n",
                 var = `attr_dim, val[attr_dim].val.str, val[attr_dim].val.str` )

	    trans_ptr->data[ii].str =
  				COB_shove_str ( val[attr_dim].val.str,
						ceo_free_strs_ptr,
						ceo_free_strs_indices,
						ceo_free_strs_index,
						ceo_free_strs_size  );

            _bugprint(bflag = TRANSFLAG, str =
                      "After COB_shove_str:  trans_ptr->data[%d].str= 0x%x = '%s'\n",
                      var = `ii, trans_ptr->data[ii].str, \
					trans_ptr->data[ii].str` )
            _bugprint(bflag = TRANSFLAG, str =
                 "\ttrans_ptr->data[%d].i=%d  =?=  val[%d].val.i=%d\n",
                 var = `ii, trans_ptr->data[ii].i, attr_dim, val[attr_dim].val.i` )

            break;
        }
    } /* end for loop */

quit:
  _bugprint(bflag = TFLAG, str = "-COBtrans_set:  * sts = %d\n", 
							var = `*sts` )
  ;	/*** need the ; for compiling w/o DEBUG set ***/
} /* COBtrans_set() */

end implementation CEO;
