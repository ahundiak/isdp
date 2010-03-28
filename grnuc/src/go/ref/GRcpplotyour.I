/* #######################    APOGEE COMPILED   ######################## */
/*
  HISTORY
       dhm      07/01/92        ANSI conversion.
*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "dpdef.h"
#include "dpmacros.h"

method GRplotyourself(IGRlong *msg; struct GRmd_env *md_env;
	IGRchar *dgn_buf; IGRchar *bs_buf; IGRchar *ele_buf; 
	IGRint *ele_size; IGRint *file_des; IGRdouble  *max_overflow; 
	struct GRid *window_id; IGRdouble *scale_factor)
{

	IGRshort mx_size;

	IGRlong	OMmsg;			/* OM return value		*/
	IGRlong msg1;			/* local completion code	*/
	IGRlong i;			/* loop counter			*/

	IGRint	win_levels[(DP_NUM_OF_LEVELS - 1) / 32 + 1];
      	struct var_list win_params[2];
	struct GRmd_env local_env;

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    win_params[0].var = LEVELS;
    win_params[0].var_ptr = (IGRchar *) win_levels;
    win_params[0].num_bytes = sizeof(win_levels);
    win_params[0].bytes_returned = &i;

    win_params[1].var = END_PARAM;

    OMmsg = dp$inq_set_gragad (msg = msg,
	inq0_set1 = 0,
	osnum = window_id[0].osnum,
	gragad_objid = window_id[0].objid,
	which_error = &msg1,
	var_list = win_params);

    if ( ! (1 & OMmsg))
    {
	goto wrapup;
    }


    if (( me->properties  & GRIS_DISPLAYABLE)
	  && (DPlevel_check(me->level,win_levels)))
    {
        if (md_env->md_env.matrix_type == MAIDMX)
	{	
	    for (i=0; i<16; ++i)
	    {
	        local_env.md_env.matrix[i] = me->matrix[i];
	    }
 	}
	else
	{
	    mx_size = 4;
	    MAmulmx(msg,&mx_size,&mx_size,&mx_size,
		    md_env->md_env.matrix,me->matrix,
		    local_env.md_env.matrix);
	}

        MAtypemx(msg,local_env.md_env.matrix,
		&local_env.md_env.matrix_type);

        local_env.md_id =  md_env->md_id;

        OMmsg = om$send(
	    msg = message GRvg.GRplotyourself
	       	(msg,&local_env,dgn_buf,bs_buf,ele_buf,ele_size,
		 file_des,max_overflow,window_id,scale_factor),
            targetid = me->cv_objid);
    }

    

wrapup:

    return(OMmsg);

}
end implementation GRclippoly;
