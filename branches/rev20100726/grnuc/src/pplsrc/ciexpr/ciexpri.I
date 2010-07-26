class implementation ciexpr;

#include "parametric.h"

method NDcompute_node (
	IGRlong *msg ;
	IGRint cn_type;	/* reserved for future use */
	IGRint count;
	struct GRid pmlist[];
 	struct GRmd_env *md_env	)
{
	double new_value,old_value;
	int stat;

	*msg = MSSUCC ;
	old_value = ME.expression->value;
/*
printf("ciexpr: old_value:%lf\n",old_value);
fflush(stdout);
 */
	/* calculates the new value */
	stat = om$send(mode = OM_e_wrt_message,
			 msg = message expression.NDcompute_node
			 			(msg, cn_type, count,
						pmlist,md_env),
			targetid = my_id );
	if ( (stat & 1) != 1 )
	{
	    printf("ciexpr.execute -> expression.NDcompute_node\n");
	    om$report_error(sts = stat);
		*msg = MSFAIL ;
	    return(OM_W_ABORT);
	}

	new_value = ME.expression->value;
/*
printf("ciexpr: new_value:%lf\n",new_value);
fflush(stdout);
 */
	/* if the value has changed, execute the command file */
	if(new_value != old_value){
		OM_S_OBJID moi = my_id;
		if( !ci$run ( file_id = &moi ) ) {
			*msg = MSFAIL ;
		    return(OM_W_ABORT);
		}
	}
 
	return 1;
}
 
end implementation ciexpr;

