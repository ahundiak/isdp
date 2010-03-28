/* #######################    APOGEE COMPILED   ######################## */
class implementation GRsmdfhdr;

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

#define N_INTS  (DP_NUM_OF_LEVELS/32 + 1)

extern IGRint GUprocessplot();

method GRplotyourself ( IGRlong *msg; struct GRmd_env *mod_env;
		        IGRchar *dgn_buf; IGRchar *bs_buf;
		        IGRchar *ele_buf; IGRint *ele_size;
		        IGRint *file_des; IGRdouble *max_overflow;
		        struct GRid *window_id; IGRdouble *scale_factor )

{
    static IGRint           i = 0, all_layers[N_INTS];
    IGRint                  *real_layers;
    IGRlong                 om_msg;
    OM_S_CHANSELECT         chansel;
    struct GRfunction_info *func_info;
    struct GRmd_env        *old_md_env;
    IGRlong                 old_index1, old_index2;

    struct plot_element_args
    {
	IGRlong		*internal_msg;
	struct GRmd_env *md_env;
	IGRchar		*design_buffer;
	IGRchar		*object_buffer;
	IGRchar		*element_buffer;
	IGRlong		*element_size;
	IGRlong		*file_descriptor;
	IGRdouble	*max_overflow;
	struct GRid	*id_info;
	IGRdouble	*scale_factor;
    } *plot_args;

    struct user_info
    {
	OM_S_MESSAGE   *plot_msg;
	struct IGRcv_prism *prism_array;
	IGRlong	   	num_prisms;
	IGRlong	   	index1,index2;
	IGRint		*levels;
    } *my_info;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        GUgetfunc_info(msg, &func_info);

        my_info = (struct user_info *)func_info->info;
        plot_args = (struct plot_element_args *)
                        (my_info->plot_msg->p_arglist);
        old_md_env = plot_args->md_env;
        plot_args->md_env = mod_env;

        /* turn all layers on so that all symbol components will plot */

        if (i == 0)
            for (i = 0; i < N_INTS; i++) all_layers[i] = 0xffffffff;
        real_layers = my_info->levels;
        my_info->levels = all_layers;

        /*
            Save the current channel indices so that nothing already
            on the owner channel gets unintentionally deleted.
        */

        old_index1 = my_info->index1;
        old_index2 = my_info->index2;

        om$get_channel_count (osnum = plot_args->id_info[1].osnum,
                              objid = plot_args->id_info[1].objid,
                              p_chanselect = &chansel,
                              count = (OMuint *)&my_info->index1);

        my_info->index2 = my_info->index1;

        /*
         * The GUprocessplot is sent instead of a GRplotyourself
         * because none of the graphic elements have received the
         * GRplotprep message since they are not in the rtree.
         * GUprocessplot will send the GRplotprep and then the
         * GRplotyourself to each component in the symbol definition.
         */
	om_msg = om$send (msg = message GRgraphics.GRfunction
                                                ( msg,
                                                  GUprocessplot,
                                                  (IGRchar *)func_info ),
                          p_chanselect = &chansel );

        my_info->index1 = old_index1;
        my_info->index2 = old_index2;
        plot_args->md_env = old_md_env;
        my_info->levels = real_layers;
    }


    return (om_msg);

}
end implementation GRsmdfhdr;
