/* $Id: DMroot.I,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/emsfixes/grnuc / DMroot.I
 *
 * Description:
 *
 * Dependencies:
 *		$GRNUCSRC/src/dim/dim_root/root.I
 *
 * Revision History:
 *	$Log: DMroot.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/11/03  17:17:42  pinnacle
# Replaced: ./emsfixes/grnuc/DMroot.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	11/01/95	adz		Add EMS correction.
 *
 * -------------------------------------------------------------------*/

class implementation DMroot;

#include "grownmacros.h"
#include "cotxmacros.h"
#include "grownerdef.h"
#include "dimcomplex.h"
#include "dimtxt.h"

#include "dimlinear.h"
#include "dimradial.h"
#include "dimangular.h"
#include "dimtxtdef.h"
#include "dimannot.h"

method GRdelete(
	IGRlong *msg;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	IGRint mod_graph;
	OM_S_OBJID md_id;
        struct GRid my_grid;

	extern IGRboolean ASbroadcast_in_progress;

	me->dim_state |= GRDELETE_PENDING;

	if (!ASbroadcast_in_progress)
	{
		/*| Inquire mod_graph */

		nd$mod_graph(request = ND_INQ, p_ret_mode = &mod_graph);

		/*"mod_graph=0x%x\n", mod_graph*/

                if ((mod_graph & ND_NO_BROAD_DEL)
		&&  (md_env->md_id.objid != NULL_OBJID))
		{
                        IGRuint l_count;
			/*|ND_NO_BROAD_DEL - remove_from_cpx*/

			status =
			om$send(msg = message DMroot.remove_from_cpx(
						&rc,
						DELETE_ACTION,
						md_env),
				targetid = my_id);
			dm$status(action = RET_STATUS);

                       /** remove_from_cpx fails as dim_clones do not have
                            connection to the actual dim objects after
                            a detach ref file is done. Provide temporary
                            parents.
                        */
                        if( !(status &1) && DMis_complex(me->dim_type))
                        {
                          struct GRid prev,next;

                            my_grid.objid = my_id;
                            my_grid.osnum = OM_Gw_current_OS;

                            om$get_channel_count(objid = my_id,
                                          p_chanselect = &ND_children,
                                          count = &l_count);
                            if(l_count)
                             {
                                  next.objid = NULL_OBJID;
                                  prev.objid = NULL_OBJID;
                                  status =
                                  om$get_objid_at_index(
                                            object = me,
                                            p_chanselect = &ND_father,
                                            index = DIM_CPX_MEAS,
                                            objidaddr = &prev.objid,
                                            osnumaddr = &prev.osnum);

                                  status =
                                  om$get_objid_at_index(
                                            object = me,
                                            p_chanselect = &ND_children,
                                            index = 0,
                                            objidaddr = &next.objid,
                                            osnumaddr = &next.osnum);

                                    status =
                                    om$send(msg=message ASnode.NDchange_connect(
                                                 1,
                                                &my_grid,
                                                &prev),
                                            mode = OM_e_wrt_message,
                                            targetid = next.objid,
                                            targetos = next.osnum);

                                /* All efforts to keep dim intact have failed.
                                   Do not check the status
                                */
                                 dm$status();

                             }
                            else
                                 dm$status();
                        }
                }
        }

	if ((md_id = md_env->md_id.objid) != NULL_OBJID)
	{
		/* - Remove owner from R-tree and set
		   - md_id to NULL_OBJID so that no
		   - attempt is made to remove components
		   - from the R-tree (they are never in
		   - in the R-tree).
		*/

		status =
		om$send(msg = message GRgraphics.GRremwrng(msg, md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);

/* START VDS CORRECTION */
/*
   Modified GRdelete.  After removing from range tree, we should not set
   module id to NULL_OBJID. 
 * Do not set to NULL_OBJID, we are not attempting to remove any components
 * as stated above. --
 *              md_env->md_id.objid = NULL_OBJID;
 */
 /* END  VDS CORRECTION */
	}

	status =
	om$send(msg = message ASnode.GRdelete(msg, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

end implementation DMroot;
