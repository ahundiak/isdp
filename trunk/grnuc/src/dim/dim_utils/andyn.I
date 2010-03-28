class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "dimlinear.h"
#include "dimradial.h"
#include "dimdyn.h"
#include "dimmod.h"
#include "dimgraph.h"

#include "msdef.h"
#include "msmacros.h"
#include "bsxlnpl.h"

from IGEgragad import	DPinrot;
from DMannot   import	modify_geom;

struct DMmod_an_info
{
	IGRint msgkey;
	IGRint control;
	struct GRid dim_grid;
	struct GRmd_env *md_env;
	struct DMplan_info plan_info;
	IGRint vertex_no;
	struct GRid display_list[MAX_GRAPH_SIZE];
	struct GRid compute_list[MAX_GRAPH_SIZE];
	IGRint display_count, compute_count;
};

#argsused
IGRint DMmodify_annot (msg,
                       dynamics,
		       msgkey,
		       copy,
		       cp_grid,
		       control,
		       data_point,
		       md_env,
		       event,
		       dim_grid)
	 IGRint  *msg;
	 IGRint  dynamics;
	 IGRint  msgkey;
	 IGRint  copy;
	 struct GRid  *cp_grid;
	 IGRint  control;
	 IGRpoint  data_point;
	 struct GRmd_env  *md_env;
	 struct GRevent  *event;
	 struct GRid  *dim_grid;
/*.DMmodify_annot*/
{
	IGRint status, rc, dim_type;
	struct DMmod_an_info dyn_info;
	struct GRmd_env dyn_env;
	struct GRid dyn_grid;
	IGRint dspgraph, computegraph;
	IGRdouble matrix[16];
	IGRboolean cp_mode, first_in_cpx, jogged;
	IGRint mod_batch;
        IGRint DMmod_andyn();

	dyn_grid = *dim_grid;
	dyn_env = *md_env;
	dyn_env.md_id.objid = NULL_OBJID;

	/*^
		print_grid("dim_grid", dim_grid);
		printf("dyn_grid=%d,%d\n", dyn_grid.objid, dyn_grid.osnum);
	*/

	status =
	om$send(msg = message DMroot.get_dimension_plane(
						&rc,
						md_env,
						&dyn_info.plan_info),
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum,
		senderid = NULL_OBJID);
	dm$status(action = RET_STATUS);

	/*^
		print_matrix("dim_plane", dyn_info.plan_info.win_plan.matrix);
	*/

	if (copy)
	{
		status =
		DMcopy_dimension(
			&rc,
			md_env,
			&dyn_env,
			NULL_OBJID,
			NULL_OBJID,
			dim_grid,
			&dyn_grid);
		dm$status(action = RET_STATUS);

		if (cp_grid)
			*cp_grid = dyn_grid;
	}

	dspgraph = ROOT | CHILDREN;
	computegraph = CHILDREN | DIMENSIONS_ONLY;

	dyn_info.display_count = 0;
	dyn_info.compute_count = 0;

	status =
	DMget_graph(
		dyn_grid,
		dspgraph,
		MAX_GRAPH_SIZE,
		dyn_info.display_list,
		&dyn_info.display_count);
	dm$status(action = RET_STATUS);

	status =
	DMget_graph(
		dyn_grid,
		computegraph,
		MAX_GRAPH_SIZE,
		dyn_info.compute_list,
		&dyn_info.compute_count);
	dm$status(action = RET_STATUS);

	/*^
		int i;

		printf("display_count = %d\n", dyn_info.display_count);
		for (i=0; i<dyn_info.display_count; i++)
		printf("%d) %d, %d\n",
			i,
			dyn_info.display_list[i].objid,
			dyn_info.display_list[i].osnum);

		printf("compute_count = %d\n", dyn_info.compute_count);
		for (i=0; i<dyn_info.compute_count; i++)
		printf("%d) %d, %d\n",
			i,
			dyn_info.compute_list[i].objid,
			dyn_info.compute_list[i].osnum);
	*/

	dyn_info.control = control | FILL_INFO;
	dyn_info.dim_grid = dyn_grid;
	dyn_info.md_env  = &dyn_env;
	dyn_info.vertex_no  = -1;

	cp_mode = FALSE;
	mod_batch = ND_TRANSACTION;

	status =
	DMmod_graph_batch_cp(GET_MODE | SET_MODE, &cp_mode, NULL, &mod_batch);
	dm$status(action = RET_STATUS);

	DMclear_cache();
	DMset_dyn_flag(TRUE);

	if (control == MOVE_POLE)
	{
		status =
		om$send(msg = message DMroot.return_vertex(
						&rc,
						&dim_type,
						&first_in_cpx,
						&jogged,
						data_point,
						&dyn_info.vertex_no,
						md_env),
			targetid = dim_grid->objid,
			targetos = dim_grid->osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	if (dynamics)
	{
		dyn_info.msgkey = msgkey;
		dp$dynamics(dyn_fun = DMmod_andyn, information = &dyn_info);
	}
	else
	{
		dyn_info.msgkey = NULL;

		status=
		om$send(msg = message IGEgragad.DPinrot((IGRlong *) &rc, matrix),
			senderid = NULL_OBJID,
			targetid = event->event.button.objid,
			targetos = event->event.button.osnum);
		dm$status(action = RET_STATUS);

		status = 
		DMmod_andyn(
			(char *) &dyn_info,
			&(event->event.button),
			matrix,
			NULL,	/* objects */
			NULL,	/* num_objects */
			NULL,	/* buffer */
			NULL,	/* num_buffers */
			NULL,	/* in_dummy1 */
			NULL,	/* in_dummy2 */
			NULL,	/* in_dummy3 */
			NULL,	/* out_dummy1 */
			NULL,	/* out_dummy2 */
			NULL);	/* out_dummy3 */
		dm$status();
	}

	DMclear_cache();
	DMset_dyn_flag(FALSE);

	status =
	DMmod_graph_batch_cp(GET_MODE | SET_MODE, &cp_mode, NULL, &mod_batch);
	dm$status(action = RET_STATUS);

	if (copy && (cp_grid == NULL))
	{
		/*| Delete Copy */

		status =
		DMdelete_dimension(
			&rc,
			TRUE,
			&dyn_env,
			&dyn_grid);
		dm$status(action = RET_STATUS);
	}

	return(TRUE);
}

#argsused
IGRint DMmod_andyn (info,
                    pnt,
		    matrix,
		    objects,
		    num_objects,
		    buffer,
		    num_buffers,
		    in_dummy1, 
		    in_dummy2 ,
		    in_dummy3 ,
		    out_dummy1,
		    out_dummy2,
		    out_dummy3)
	 char  *info;
	 struct EX_button  *pnt;
	 IGRdouble  *matrix;
	 struct GRid  **objects;
	 IGRint  *num_objects;
	 struct DPele_header  **buffer;
	 IGRint  *num_buffers;
	 IGRchar  **in_dummy1 ;
	 IGRchar  **in_dummy2 ;
	 IGRchar  **in_dummy3 ;
	 IGRchar  **out_dummy1;
	 IGRchar  **out_dummy2;
	 IGRchar  **out_dummy3;
/*.DMmod_andyn*/
{
	IGRint status = OM_S_SUCCESS, msg_loc = OM_S_SUCCESS;
	IGRlong long_rc = OM_S_SUCCESS;
	BSrc bs_rc;
	struct DMmod_an_info *dyn_info;
	IGRint i;
	struct GRid win_grid;

	IGRpoint  norm_to_plane;
	IGRpoint  p1, p2, pt_on_plane, ptproj;

	dyn_info = (struct DMmod_an_info *)info;

	if (dyn_info->msgkey)
	{
		ex$message(msgnumb = dyn_info->msgkey,
			   justification = RIGHT_JUS);
		dyn_info->msgkey = NULL;
	}

	p1[0] = pnt->x;
	p1[1] = pnt->y;
	p1[2] = pnt->z;
	win_grid.objid = pnt->objid;
	win_grid.osnum = pnt->osnum;

	for (i=0; i<3; i++)
	{
		norm_to_plane[i] = dyn_info->plan_info.win_plan.matrix[i+8];
		pt_on_plane[i] = dyn_info->plan_info.win_plan.matrix[4*i+3];
		p2[i] = p1[i] + matrix[i+8];
	}

	/*|Calling BSxlnpl*/

	BSxlnpl(&bs_rc,
		norm_to_plane,
		pt_on_plane,
		p1,
		p2,
		ptproj);

	/*^
		print_matrix("win_matrix", matrix);
		print_matrix("dim_plane", dyn_info->plan_info.win_plan.matrix);
		print_point("p1", p1);
		print_point("p2", p2);
		print_point("ptproj", ptproj);
	*/

	/*|Calling dynamics*/

	status =
	om$send(msg = message DMannot.modify_geom(
					&msg_loc,
					dyn_info->control,
					dyn_info->vertex_no,
					ptproj,
					&win_grid,
					dyn_info->md_env),
		senderid = NULL_OBJID,
		targetid = dyn_info->dim_grid.objid,
		targetos = dyn_info->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	dyn_info->control &= (~FILL_INFO);

	for (i=0; i<dyn_info->compute_count; i++)
	{
		status =
		om$send(msg = message NDnode.NDs_compute_node(
							&long_rc,
							0,
							dyn_info->md_env),
			targetid = dyn_info->compute_list[i].objid,
			targetos = dyn_info->compute_list[i].osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	if (objects)
	{
		*objects = dyn_info->display_list;
		*num_objects = dyn_info->display_count;
		*num_buffers = 0;
	}

	return(TRUE);
}

end implementation DMroot;
