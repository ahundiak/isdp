/* #######################    APOGEE COMPILED   ######################## */
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
#include "grdpbdef.h"
#include "grdpbmacros.h"

extern IGRboolean GUcpxhandler();
extern void GUcpxinit();
extern void GUinit_symb();
extern void GUaddcount();
extern IGRshort GUsubcount();
extern IGRint GUcpxwritehdr();
extern IGRint GUset_symb();

/*****************************************************************************/
/*     This method is modified to fix TR# 91N1209 and TR# 92N3792.           */
/*									     */
/*  Previously Symbols were converted as "raw" graphics. Now  Symbols are    */
/*  copied into the active module environment as Cells and then converted    */
/*  them to IGDS. After convertion those Cells will be deleted.              */
/*								-Gangadhar   */
/*****************************************************************************/

method GRformatele ( IGRlong *msg; struct GRmd_env *mod_env;
		     IGRchar *dgn_buf; IGRchar *bs_buf;
		     IGRchar *ele_buf; IGRint *ele_size;
		     IGRint *file_des; IGRdouble *max_overflow;
		     IGRdouble *scale_factor )

{
    IGRlong           om_msg;
    struct GRmd_env   target_mod_env;
    struct GRid       cell_id;
    IGRlong  	      nbytes_in_buffer,nbytes_trans;

	/* Get the current (active) module environment */

        nbytes_in_buffer = sizeof(target_mod_env);
	gr$get_module_env(msg = msg,
			  sizbuf = &nbytes_in_buffer,
			  buffer = &target_mod_env,
			  nret= &nbytes_trans);	

	/* Copy the Symbol to a Cell */

        om_msg = om$send( msg = message GRsmhdr.GRcp_symbol_to_cell(msg,
			mod_env, &target_mod_env, &cell_id),
			targetid = my_id,
			targetos = OM_Gw_current_OS);

	if(*msg == MSFAIL)
	   return(om_msg);

        /* if the symbol is rigidly owned, attach the created cell to the
         * rigid owner; this is necessary for the cell to be successfully
         * formatted if it has a rigid owner other than a cell
         */

        if (me->properties & GR_RIGID_RELATIONSHIP)
        {
            struct GRid     owner_grid;
            OM_S_CHANSELECT chansel;
            IGRlong         owners_index;

            chansel.type = OM_e_name;
            chansel.u_sel.name = "GRconnector.to_owners";

            om_msg = om$get_objid_at_index(objid = my_id,
                                           p_chanselect = &chansel,
                                           index = 0,
                                           objidaddr = &owner_grid.objid,
                                           osnumaddr = &owner_grid.osnum);
            if (1 & om_msg)
            {
                owners_index = OM_K_MAXINT;

                om_msg = om$send(msg = message GRconnector.GRrigidconn
                                           (msg, &owner_grid, &owners_index),
                                 targetid = cell_id.objid,
                                 targetos = cell_id.osnum);
            }
        }

	/* Format the copied Cell */

        om_msg = om$send (mode = OM_e_wrt_message,
			  msg = message GRvg.GRformatele 
                                                ( msg, 
                                                  &target_mod_env,
                                                  dgn_buf, 
                                                  bs_buf, 
                                                  ele_buf, 
                                                  ele_size, 
                                                  file_des, 
                                                  max_overflow,
                                                  scale_factor),
                           targetid = cell_id.objid,
			   targetos = cell_id.osnum);

	/* Delete the Cell from the object space */

	om_msg = om$send (msg = message GRgraphics.GRdelete(msg,
			  &target_mod_env),
			  targetid = cell_id.objid,
			  targetos = cell_id.osnum);

    return (om_msg);

}
end implementation GRsmhdr;
