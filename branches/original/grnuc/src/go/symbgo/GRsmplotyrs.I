/* #######################    APOGEE COMPILED   ######################## */
/*
 * Description
 *    This method implements the GRplotyourself method for symbols.
 *
 * History
 *    ???    ??/??/??   created.
 *    dhm    04/15/92   added the view independent code for symbols with
 *                      lots of help from bill.
 */

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "gocmacros.h"
#include "grsymdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"

extern IGRint GUset_symb();
extern void GUinit_symb();
extern IGRboolean MAtrnmx(), MAmulmx(), MAtypemx(), MAidmx();


method GRplotyourself ( IGRlong *msg; struct GRmd_env *mod_env;
		        IGRchar *dgn_buf; IGRchar *bs_buf;
		        IGRchar *ele_buf; IGRint *ele_size;
		        IGRint *file_des; IGRdouble *max_overflow;
		        struct GRid *window_id; IGRdouble *scale_factor )

{
    IGRshort	      props;
    IGRshort	      owner_props;
    IGRlong	      status;
    IGRlong           om_msg;
    IGRboolean	      alt_symb = FALSE;
    IGRboolean	      set = TRUE;
    OM_S_CHANSELECT   chansel;
    OMuword	      classid;
    struct GRid       id;
    struct GRid       owner;
    struct GRmd_env   local_mod_env;
    struct GRsymbology symb;
    struct GRsymbology real_symb;


    props = 0;
    if ( me->owner_properties & GR_SYM_DISPLAY_ATTR )
    {
	status = om$send (msg = message GRvg.GRgetsymb ( msg, &real_symb ),
			  targetid = my_id);
	props |= me->owner_properties;
	alt_symb = TRUE;
    }
    
    if ( me->properties & GR_RIGID_RELATIONSHIP )
    {
	chansel.type = OM_e_name;
	chansel.u_sel.name = "GRconnector.to_owners";

	status = om$get_objid_at_index ( osnum = OM_Gw_current_OS,
					 objid = my_id,
					 p_chanselect = &chansel,
					 index =0,
					 objidaddr = &owner.objid,
					 osnumaddr = &owner.osnum );
    
	while ( status == OM_S_SUCCESS )
	{
	    status = om$get_classid (osnum = owner.osnum,
				     objid = owner.objid,
				     p_classid = &classid );

	    status = om$is_ancestry_valid ( subclassid = classid,
					    superclassname = "GRsmhdr" );
	
	    if ( status == OM_S_SUCCESS )
	    {
		status = om$send ( msg = message GRowner.GRget_owner_properties
						 ( msg, &owner_props ),
				   targetid = owner.objid,
				   targetos = owner.osnum );

		if ( owner_props & GR_SYM_DISPLAY_ATTR )
		{
		   status = om$send ( msg = message GRvg.GRgetsymb ( msg, &symb ),
			              targetid = owner.objid,
			              targetos = owner.osnum );

	   	   if ( *msg == MSSUCC )
	   	   {
				alt_symb = TRUE;
		        if ( owner_props & GR_SYM_COLOR )
				{
			    real_symb.display_attr.color = symb.display_attr.color;
		   	    props |= GR_SYM_COLOR;
		        }

		        if ( owner_props & GR_SYM_WEIGHT )
		    	{
		   	    real_symb.display_attr.weight = symb.display_attr.weight;
		   	    props |= GR_SYM_WEIGHT;
		    	}

		    	if ( owner_props & GR_SYM_STYLE )
		        {
		   	    real_symb.display_attr.style = symb.display_attr.style;
		   	    props |= GR_SYM_STYLE;
			}
		    }
	   	}
	    }	
	    id.objid = owner.objid;
	    status = om$get_objid_at_index ( osnum = OM_Gw_current_OS,
					     objid = id.objid,
					     p_chanselect = &chansel,
					     index =0,
					     objidaddr = &owner.objid,
					     osnumaddr = &owner.osnum );
	}
    }	
    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        id.osnum = OM_Gw_current_OS;
        id.objid = my_id;

	if ( alt_symb )
	{
	    GUset_symb ( msg, &real_symb, &props, &set );
	}

        /*
         *  Get the component context.
         */
        om_msg = om$send (msg = message GRowner.GRget_context 
                                                ( msg, 
                                                  mod_env,
                                                  &local_mod_env), 
                          targetid = my_id);

        /* if this is a view independent symbol, find the rotation of the view
         * the symbol is being plotted in, get the inverse of that matrix
         * (just get the tranpose of the matrix since we know it's just a
         *  rotation matrix) and multiply the local mod_env matrix by this
         * matrix; this is done to cancel out the view'w rotation when it's
         * applied at plotting time
         */

        if (ME.GRgraphics->properties & GRIS_VIEW_INDEP)
        {
            IGRdouble        view_rot_matrix[16],
                             view_indep_matrix[16],
                             origin_matrix[16],
                             temp_matrix[16];
            IGRlong          which_error,
                             bytes_ret;
            IGRint           index;
            struct var_list  var_list[2];
            IGRshort         dimension = 4;

            var_list[0].var = VW_ROT_NO_CON;
            var_list[0].var_ptr = (IGRchar *) view_rot_matrix;
            var_list[0].num_bytes = sizeof(IGRdouble) * 16;
            var_list[0].bytes_returned = &bytes_ret;
            var_list[1].var = END_PARAM;

            dp$inq_set_gragad(msg = msg,
                              osnum = window_id->osnum,
                              gragad_objid = window_id->objid,
                              which_error = &which_error,
                              var_list = var_list);

            MAtrnmx(msg, &dimension, view_rot_matrix, view_rot_matrix);

            /* create an identity matrix that has the negative of the symbol's
             * origin
             */

            MAidmx(msg, origin_matrix);

            for (index = 0; index < 3; index++)
                origin_matrix[(index * 4) + 3] =
                            -local_mod_env.md_env.matrix[(index * 4) + 3];

            MAmulmx(msg, &dimension, &dimension, &dimension, origin_matrix,
                    local_mod_env.md_env.matrix, view_indep_matrix);

            MAmulmx(msg, &dimension, &dimension, &dimension, view_rot_matrix,
                    view_indep_matrix, temp_matrix);

            for (index = 0; index < 3; index++)
                origin_matrix[(index * 4) + 3] *= -1;

            MAmulmx(msg, &dimension, &dimension, &dimension, origin_matrix,
                    temp_matrix, local_mod_env.md_env.matrix);

            MAtypemx(msg, local_mod_env.md_env.matrix,
                     &local_mod_env.md_env.matrix_type);

        }

        om_msg = om$send (msg = message GRgraphics.GRplotyourself 
                                                ( msg, 
                                                  &local_mod_env,
                                                  dgn_buf, 
                                                  bs_buf, 
                                                  ele_buf, 
                                                  ele_size, 
                                                  file_des, 
                                                  max_overflow,
                                                  window_id,
                                                  scale_factor),
                          p_chanselect = &chansel);
    }


    if (alt_symb)
    {
       GUinit_symb();
    }
    return (om_msg);

}
end implementation GRsmhdr;
