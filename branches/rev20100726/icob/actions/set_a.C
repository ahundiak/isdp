/* actions/set_a.C */


#include <stdio.h>
#include <OMminimum.h>
#include <OMerrordef.h>
#include <ODE.h>
#include <COBstructs.h>
#include <COBint.h>	/* need this for _attr_type ---  JAJ:12-02-88 */

#ifdef DEBUG
#include <COB_DBflags.h>
#endif

_debug(extern int read_debug;)
#define TFLAG ( read_debug )
#define ACT_TRANS  ( read_debug )


COBactions_set ( action_ptr, val, num_attrs,
		 ceo_free_action_args_ptr,
		 ceo_free_action_args_index,
		 ceo_free_strs_ptr,
		 ceo_free_strs_indices,
		 ceo_free_strs_index,
		 ceo_free_strs_size,
		 sts )
  struct COBaction	* action_ptr;
  _attr_type		  val [];
  int		 	  num_attrs;
  char			  ceo_free_action_args_ptr[];
  int			* ceo_free_action_args_index;
  char		       ** ceo_free_strs_ptr[];
  int			* ceo_free_strs_indices[];
  int			* ceo_free_strs_index;
  int			* ceo_free_strs_size;
  int			* sts ;
{
  int		  ii;
  extern char	* COB_shove_str ( );


  _bugprint(bflag=TFLAG, str =
	"+COBactions_set:  num_attrs = %d, action_ptr = %(0x)%x\n",
	var = `num_attrs, action_ptr` )

  * sts = OM_S_SUCCESS;

  action_ptr->num_args = num_attrs - 2 ;

  _bugprint(bflag=ACT_TRANS, str =
	  "action_ptr->num_args = %d =?= num_attrs - 2 = %d\n",
	  var = `action_ptr->num_args, num_attrs - 2` )

  if ( action_ptr->num_args )
    {
	/*** this needs to start on a (double) boundary ***/
	/***   SO ALWAYS PUT IT FIRST		      ***/
      action_ptr->values =
	      &	ceo_free_action_args_ptr[ *ceo_free_action_args_index ];

      (*ceo_free_action_args_index) +=
				action_ptr->num_args * sizeof(double);

	/*** this needs to start on a (char *) boundary ***/
      action_ptr->args = (char **)
	      &	ceo_free_action_args_ptr[ *ceo_free_action_args_index ];

      (*ceo_free_action_args_index) +=
				action_ptr->num_args * sizeof(char *) ;

	/*** this needs to start on a (short) boundary ***/
      action_ptr->args_index = ( short * )
	      &	ceo_free_action_args_ptr[ *ceo_free_action_args_index ];

      (*ceo_free_action_args_index) +=
				action_ptr->num_args * sizeof(short) ;

	/*** this needs to start on a (short) boundary ***/
      action_ptr->is_const = (short *)
	      &	ceo_free_action_args_ptr[ *ceo_free_action_args_index ];

      (*ceo_free_action_args_index) +=
				action_ptr->num_args * sizeof(short) ;
    }

  /*** initialize the args_index[] array to -1 ***/
  for ( ii = 0; ii < action_ptr->num_args ; ii++ )
	action_ptr->args_index[ii] = -1;

  /*** set the class name of the message to send ***/
  strcpy ( action_ptr->class_name, val[0].val.str );
  _bugprint(bflag=ACT_TRANS, str =
	"Setting action_ptr->class_name to val[0].val.str = '%s'\n",
	var = action_ptr->class_name )

  /*** set the message to send ***/
  action_ptr->message_name = COB_shove_str ( val[1].val.str,
					ceo_free_strs_ptr,
					ceo_free_strs_indices,
					ceo_free_strs_index,
					ceo_free_strs_size  );
  _bugprint(bflag=ACT_TRANS, str =
       "Setting action_ptr->message_name to val[1].val.str = '%s'\n",
	var = action_ptr->message_name )

  /** for the rest of the val array, val[i].attribute = _actions_data**/
  for ( ii = 2; ii < num_attrs; ++ii )
    {
      action_ptr->args[ii-2] = COB_shove_str ( val[ii].val.str,
					ceo_free_strs_ptr,
					ceo_free_strs_indices,
					ceo_free_strs_index,
					ceo_free_strs_size  );
      _bugprint(bflag=ACT_TRANS, str =
	  "\tsetting action_ptr->args[%d]to (val[%d].val.str) = '%s'\n",
	  var = `ii-2, ii, action_ptr->args[ii-2]` )
    }

/*quit:*/
  _bugprint(bflag=TFLAG, str = "-COBactions_set:  *sts = %d\n", var = *sts)
 ;	/*** need ';' here so something comes after ***/
	/***   quit: when DEBUG isn't set	  ***/

} /* COBactions_set() */

