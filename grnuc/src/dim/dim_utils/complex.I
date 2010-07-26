class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "diminst.h"
#include "dimangular.h"

from DMlincpx import swap_if_needed;
from DMangular import update_src;

IGRint DMupdate_complex (msg,
                         dim_grid,
                         md_env)
          /*(
	 IGRint  *msg,
	 struct GRid  dim_grid,
	 struct GRmd_env  *md_env
	)
*/
IGRint *msg;
struct GRid dim_grid;
struct GRmd_env *md_env;
/*.DMupdate_complex*/
{
	IGRint status, rc;
	IGRboolean last_in_cpx;
	struct GRid next[2];
	struct GRid first_dim;
	IGRint cpx_type;
	IGRint index;
	IGRint cn_type;
	struct GRid first_begin;
	IGRshort dim_type;
	struct DMtrak_info trak_info;
	IGRchar mea_trak;
	
	status =
	om$send(msg = message DMroot.get_first_in_cpx(&rc, &first_dim),
		senderid = NULL_OBJID,
		targetid = dim_grid.objid,
		targetos = dim_grid.osnum);
	dm$status(action = RET_STATUS);

	first_begin = first_dim;

	status =
	om$send(msg = message DMroot.get_complex_type(&cpx_type),
		senderid = NULL_OBJID,
		targetid = first_dim.objid,
		targetos = first_dim.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.give_next(
					&rc,
					&last_in_cpx,
					next),
		senderid = NULL_OBJID,
		targetid = first_dim.objid,
		targetos = first_dim.osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.get_dim_type(&dim_type),
		senderid = NULL_OBJID,
		targetid = first_dim.objid,
		targetos = first_dim.osnum);
	dm$status(action = RET_STATUS);

	if (dim_type == STRINGED_LINEAR)
	{
		status =
		om$send(msg = message DMlincpx.swap_if_needed(md_env),
			senderid = NULL_OBJID,
			targetid = first_dim.objid,
			targetos = first_dim.osnum);
		dm$status(action = RET_STATUS);
	}

	status =
        om$send(msg = message DMroot.remove_from_cpx(
                                                &rc,
						NO_ACTION,
						md_env),
		senderid = NULL_OBJID,
		targetid = first_dim.objid,
		targetos = first_dim.osnum);
	dm$status(action = RET_STATUS);

	for (index=0; index<2; index++)
	{
		if (next[index].objid == NULL_OBJID) continue;

		status =
		DMmerge_complex(&rc, cpx_type, &first_dim, &next[index], md_env);
		dm$status(action = RET_STATUS);
	}

	if (first_dim.objid != first_begin.objid)
	{
		/*^ printf("First dimension changed: old <%d,%d>, new<%d,%d>\n",
			first_begin.objid, first_begin.osnum,
			first_dim.objid, first_dim.osnum); */

		if (dim_type == STACKED_ANGULAR
		||  dim_type == STRINGED_ANGULAR)
		{
			status =
			om$send(msg = message DMroot.get_trak_info(&trak_info),
				senderid = NULL_OBJID,
				targetid = first_dim.objid,
				targetos = first_dim.osnum);
			dm$status(action = RET_STATUS);

			mea_trak = trak_info.mea_trak;
	
			/*"first_dim mea_trak = %d\n", mea_trak*/
		}

		status =
		om$send(msg = message DMroot.copy_dim_attr(
							&rc,
							INST_TRAK_PT,
							&first_begin,
							md_env),
			senderid = NULL_OBJID,
			targetid = first_dim.objid,
			targetos = first_dim.osnum);
		dm$status(action = RET_STATUS);

		if (dim_type == STACKED_ANGULAR
		||  dim_type == STRINGED_ANGULAR)
		{
			status =
			om$send(msg = message DMroot.get_trak_info(&trak_info),
				senderid = NULL_OBJID,
				targetid = first_dim.objid,
				targetos = first_dim.osnum);
			dm$status(action = RET_STATUS);

			/*"first_begin mea_trak = %d\n", trak_info.mea_trak*/

			trak_info.mea_trak = mea_trak;

			status =
			om$send(msg = message DMroot.set_trak_info(REP_TRAK_DIST, &trak_info),
				senderid = NULL_OBJID,
				targetid = first_dim.objid,
				targetos = first_dim.osnum);
			dm$status(action = RET_STATUS);
		}

		status =
		om$send(msg = message DMroot.set_trak_info(MIN_TRAK_DIST, NULL),
			senderid = NULL_OBJID,
			targetid = first_begin.objid,
			targetos = first_begin.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.get_trak_info(&trak_info),
			senderid = NULL_OBJID,
			targetid = first_begin.objid,
			targetos = first_begin.osnum);
		dm$status(action = RET_STATUS);

		/*"first_begin mea_trak2 = %d\n", trak_info.mea_trak*/
	}

	cn_type = ND_COMP;
	nd$wait_batch(
		type = GR_GEOM_POSTED,
		l_object = &first_dim,
		l_obj_info = &cn_type,
		nb_obj = 1);

	*msg = DIM_S_SUCCESS;

	return(TRUE);
}


IGRint DMmerge_complex (msg,
                        cpx_type,
			cpx_hdr1,
			cpx_hdr2,
			md_env)
			/*(
	 IGRint  *msg,
	 IGRint  cpx_type,
	 struct GRid  *cpx_hdr1,
	 struct GRid  *cpx_hdr2,
	 struct GRmd_env  *md_env
	)
	*/
IGRint *msg;
IGRint cpx_type;
struct GRid *cpx_hdr1, *cpx_hdr2;
struct GRmd_env *md_env;
/*.DMmerge_complex*/
{
	IGRint status, rc;
	IGRboolean last_in_cpx;
	struct GRid next[2];
	struct GRid list[NO_CPX_DIM_ROOTS];
	struct GRid dim_before, dim_after;
	struct GRid tmp_grid, meas;
	IGRint count;
	IGRint rel_pos;
	IGRshort dim_type;

	status =
	om$send(msg = message DMroot.get_dim_type(&dim_type),
		senderid = NULL_OBJID,
		targetid = cpx_hdr2->objid,
		targetos = cpx_hdr2->osnum);
	dm$status(action = RET_STATUS);

	do
	{
		status =
		om$send(msg = message DMroot.give_next(
						&rc,
						&last_in_cpx,
						next),
			senderid = NULL_OBJID,
			targetid = cpx_hdr2->objid,
			targetos = cpx_hdr2->osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.DMreturn_roots(
						&count,
						list),
			senderid = NULL_OBJID,
			targetid = cpx_hdr2->objid,
			targetos = cpx_hdr2->osnum);
		dm$status(action = RET_STATUS);

		dim_before.objid = NULL_OBJID;
		dim_after.objid = NULL_OBJID;

		status =
		om$send(msg = message DMroot.find_position_in_cpx(
						&rc,
						cpx_type,
						*cpx_hdr2,
						list[DIM_CPX_MEAS],
						md_env,
						&rel_pos,
						&dim_before,
						&dim_after),
			senderid = NULL_OBJID,
			targetid = cpx_hdr1->objid,
			targetos = cpx_hdr1->osnum);
		dm$status(action = RET_STATUS);

		if (cpx_type == STRINGED_CPX
		&&  (rel_pos == CPX_OPPOSITE_FAR
		||   rel_pos == CPX_OPPOSITE_NEAR))
		{
			/*|- Swap parents*/

			tmp_grid = list[DIM_CPX_ORIG];
			list[DIM_CPX_ORIG] = list[DIM_CPX_MEAS];
			list[DIM_CPX_MEAS] = tmp_grid;
			tmp_grid.objid = NULL_OBJID;

			status =
			om$send(msg = message NDnode.NDconnect(
							count,
							list,
							tmp_grid,
							ND_FULL),
				senderid = NULL_OBJID,
				targetid = cpx_hdr2->objid,
				targetos = cpx_hdr2->osnum);
			dm$status(action = RET_STATUS);
		}

		/*^
			print_grid("dim_after", &dim_after);
			print_grid("dim_before", &dim_before);
		*/

		if ((dim_after.objid != NULL_OBJID)
		&&  (dim_type == STRINGED_ANGULAR
		||   dim_type == STACKED_ANGULAR))
		{
			/*- The first dimension in the angular
			    dimension group must have its DMsrc
			    type as DMkeyseg or DM2ptseg. So if
			    any other dimension in the group is
			    inserted as first it src type has
			    to be checked and made the correct
			    type.
			*/

			/*|- Update angular source type*/

			status =
			om$send(msg = message DMangular.update_src(
						&rc,
						&meas,
						dim_after,
						md_env),
				senderid = NULL_OBJID,
				targetid = cpx_hdr2->objid,
				targetos = cpx_hdr2->osnum);
			dm$status(action = RET_STATUS);
		}

	status =
        om$send(msg = message DMroot.remove_from_cpx(
                                                &rc,
						NO_ACTION,
						md_env),
			senderid = NULL_OBJID,
			targetid = cpx_hdr2->objid,
			targetos = cpx_hdr2->osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.insert_into_cpx(
						&rc,
						NO_ACTION, /* SWAP_TRAK_DIST, */
						md_env,
						rel_pos,
						&dim_before,
						&dim_after),
			senderid = NULL_OBJID,
			targetid = cpx_hdr2->objid,
			targetos = cpx_hdr2->osnum);
		dm$status(action = RET_STATUS);

		if (dim_before.objid == NULL_OBJID)
			*cpx_hdr1 = *cpx_hdr2;

		*cpx_hdr2 = next[0];

	} while (!last_in_cpx);

	*msg = DIM_S_SUCCESS;
	return(TRUE);
}

end implementation DMroot;


