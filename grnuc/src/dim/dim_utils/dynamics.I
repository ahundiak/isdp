class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "dimdef.h"
#include "dimdyn.h"
#include "dimmod.h"
#include "dimgraph.h"

#include "msdef.h"
#include "msmacros.h"
#include "bsxlnpl.h"
#include "bsdotp.h"

#include "igrtypedef.h"
#include "bserr.h"
#include "mainvmx.h"
#include "matypemx.h"
#include "madef.h"
#include "maoptsxfo.h"

from IGEgragad import	DPinrot;

#argsused
IGRint DMinvoke_dynamics (msg,
                          dynamics,
                          msgkey,
			  preproc,
			  postproc,
			  pre_state,
			  post_state,
			  copy,
			  cp_grid,
			  control,
			  md_env,
			  event,
			  dim_grid)
/*(
	 IGRint  *msg,
	 IGRint  dynamics,
	 IGRint  msgkey,
	 IGRint  preproc,
	 IGRint  postproc,
	 IGRchar  pre_state,
	 IGRchar  post_state,
	 IGRint  copy,
	 struct GRid  *cp_grid,
	 IGRint  control,
	 struct GRmd_env  *md_env,
	 struct GRevent  *event,
	 struct GRid  *dim_grid
	)
	*/
IGRint		*msg;
IGRint		dynamics;
IGRint		msgkey;
IGRint		preproc;
IGRint		postproc;
IGRchar		pre_state;
IGRchar		post_state;
IGRint		copy;
struct GRid	*cp_grid;
IGRint		control;
struct GRmd_env *md_env;
struct GRevent	*event;
struct GRid	*dim_grid;
/*.DMinvoke_dynamics*/
{
	IGRint status, rc;
	IGRlong long_rc;
	struct DMdynamics_info dyn_info;
	struct DMdim_info auto_info[MAX_CPX_SIZE];
	struct GRmd_env dyn_env;
	struct GRid dyn_grid;
	IGRint dspgraph, computegraph;
	IGRint dsp_control;
	IGRdouble matrix[16];
	IGRboolean cp_mode;
        IGRint DMdynamics();
	IGRint mod_batch;
	IGRint cpx_size;

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

	dsp_control = 0;

	if (preproc & ERASE_DIM)
		dsp_control |= ERASE;
	if (preproc & TAKE_OFF_RTREE)
		dsp_control |= REMWRNG;

	if (dsp_control)
	{
		status =
		DMdisplay_dimension(
			&rc,
			ROOT | CHILDREN,
			dsp_control,
			md_env,
			dim_grid);
		dm$status(action = RET_STATUS);
	}

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

	if (preproc & LEADER_OFF)
	{
		status =
		om$send(msg = message DMroot.leader_off(),
			targetid = dyn_grid.objid,
			targetos = dyn_grid.osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	if (preproc & JOGGED_OFF)
	{
		status =
		om$send(msg = message DMroot.jogged_off(),
			targetid = dyn_grid.objid,
			targetos = dyn_grid.osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	if (preproc & CLEAR_OFFSET)
	{
		status =
		om$send(msg = message DMroot.clear_offset(),
			targetid = dyn_grid.objid,
			targetos = dyn_grid.osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	if (preproc & (SET_STATE | MASK_STATE | CLEAR_STATE))
	{
		IGRint flag;

		if (preproc & SET_STATE)
			flag = BIT_SET;
		else if (preproc & MASK_STATE)
			flag = BIT_OR;
		else if (preproc & CLEAR_STATE)
			flag = BIT_CLEAR;

		status =
		om$send(msg = message DMroot.set_dim_state(flag, pre_state),
			targetid = dyn_grid.objid,
			targetos = dyn_grid.osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	if (control & MOVE_TRAK_PT)
	{
		dspgraph = ROOT | CHILDREN;
		computegraph = CHILDREN | COMPONENTS_ONLY;
	}
	else
	{
		dspgraph = ROOT | CHILDREN | COMPONENTS_ONLY | IMMEDIATE_ONLY;
		computegraph = CHILDREN | COMPONENTS_ONLY | IMMEDIATE_ONLY;
	}

	dyn_info.display_count = 0;
	status =
	DMget_graph(
		dyn_grid,
		dspgraph,
		MAX_GRAPH_SIZE,
		dyn_info.display_list,
		&dyn_info.display_count);
	dm$status(action = RET_STATUS);

	dyn_info.compute_count = 0;
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
		for (i=0; i < dyn_info.compute_count; i++)
		printf("%d) %d, %d\n",
			i,
			dyn_info.compute_list[i].objid,
			dyn_info.compute_list[i].osnum);
	*/

	dyn_info.control = control | FILL_INFO;
	dyn_info.dim_grid = dyn_grid;
	dyn_info.md_env  = &dyn_env;

	cp_mode = FALSE;
	mod_batch = ND_TRANSACTION;

	status =
	DMmod_graph_batch_cp(GET_MODE | SET_MODE, &cp_mode, NULL, &mod_batch);
	dm$status(action = RET_STATUS);

	DMclear_cache();
	DMset_dyn_flag(TRUE);

	status =
	om$send(msg = message DMroot.get_complex_size(&cpx_size),
		targetid = dyn_grid.objid,
		targetos = dyn_grid.osnum,
		senderid = NULL_OBJID);
	dm$status(action = RET_STATUS);

	if (cpx_size > MAX_CPX_SIZE)
	{
		cpx_size *= sizeof(struct DMdim_info);
		dyn_info.info = (struct  DMdim_info *) om$malloc(size = cpx_size);
		if (dyn_info.info == NULL)
		{
			dm$status(sts = OM_E_NODYNMEM, action = RET_STATUS);
		}
	}
	else	dyn_info.info = auto_info;

	if (dynamics)
	{
		dyn_info.msgkey = msgkey;
		dp$dynamics(dyn_fun = DMdynamics, information = (char *) &dyn_info);
	}
	else
	{
		dyn_info.msgkey = NULL;

		status=
		om$send(msg = message IGEgragad.DPinrot(&long_rc, matrix),
			senderid = NULL_OBJID,
			targetid = event->event.button.objid,
			targetos = event->event.button.osnum);
		dm$status(action = RET_STATUS);

		status = 
		DMdynamics(
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

	if (dyn_info.info != auto_info)
		om$dealloc(ptr = dyn_info.info);

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

	if (postproc & CHGDP)
	{
		struct DMenv_param par_env;

		status =
		dm$get_dim_param(type = DM_ENV_PARAM,
			dim_objid = dyn_grid.objid,
			dim_osnum = dyn_grid.osnum,
			p_data = (char *) &par_env);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message DMroot.chgdp(&rc, &par_env),
			targetid = dyn_grid.objid,
			targetos = dyn_grid.osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	dsp_control = 0;

	if (postproc & DISP_DIM)
		dsp_control |= DISPLAY;
	if (postproc & PUT_IN_RTREE)
		dsp_control |= ADDWRNG;

	if (dsp_control)
	{
		status =
		DMdisplay_dimension(
			&rc,
			ROOT | CHILDREN,
			dsp_control,
			md_env,
			dim_grid);
		dm$status(action = RET_STATUS);
	}

	if (postproc & (SET_STATE | MASK_STATE | CLEAR_STATE))
	{
		IGRint flag;

		if (preproc & SET_STATE)
			flag = BIT_SET;
		else if (preproc & MASK_STATE)
			flag = BIT_OR;
		else if (preproc & CLEAR_STATE)
			flag = BIT_CLEAR;

		status =
		om$send(msg = message DMroot.set_dim_state(flag, post_state),
			targetid = dyn_grid.objid,
			targetos = dyn_grid.osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	return(TRUE);
}

#argsused
IGRint DMdynamics (info,
		   pnt,
		   rot_matrix,
		   objects,
		   num_objects,
		   buffer,
		   num_buffers,
		   in_dummy1 ,
		   in_dummy2 ,
		   in_dummy3 ,
		   out_dummy1,
		   out_dummy2,
		   out_dummy3)
		   /*(

	 char  *info,
	 struct EX_button  *pnt,
	 IGRdouble  *rot_matrix,
	 struct GRid  **objects,
	 IGRint  *num_objects,
	 struct DPele_header  **buffer,
	 IGRint  *num_buffers,
	 IGRchar  **in_dummy1 ,
	 IGRchar  **in_dummy2 ,
	 IGRchar  **in_dummy3 ,
	 IGRchar  **out_dummy1,
	 IGRchar  **out_dummy2,
	 IGRchar  **out_dummy3
	)
	*/
char			*info;
struct EX_button	*pnt;
IGRdouble		*rot_matrix;
struct GRid		**objects;
IGRint			*num_objects;
struct DPele_header	**buffer;
IGRint			*num_buffers;
IGRchar			**in_dummy1 , **in_dummy2 , **in_dummy3 ;
IGRchar			**out_dummy1, **out_dummy2, **out_dummy3;
/*.DMdynamics*/
{
	IGRint status, rc;
	IGRlong long_rc;
	struct DMdynamics_info *dyn_info;
	struct DMdyn_radial *place_attr1;
	struct DMdyn_surf *place_attr2;
	struct DMdyn_weld *place_attr3;
	IGRint level, i;
	IGRdouble dotp, *matrix;
	IGRboolean plane_perp;
	static struct EX_button cursor;
	struct DPele_header *buf;
	IGRshort dim_type;
	BSrc bs_rc;

	IGRpoint  norm_to_plane;
	IGRpoint  p1, p2, pt_on_plane, ptproj;

    IGRshort dim=4,invmxtyp=MAIDMX;
    IGRlong one=1;
    IGRmatrix invmx;
    IGRpoint tmppt,tmppt1;
    IGRboolean aflag=0;
    struct GRmd_env rfenv;

	dyn_info = (struct DMdynamics_info *)info;

	if (dyn_info->msgkey)
	{
		ex$message(msgnumb = dyn_info->msgkey,
			   justification = RIGHT_JUS);
		dyn_info->msgkey = NULL;
	}
    
    if(aflag = pwIsActivationOn())
    {
    pwGetActiveModuleEnv(&rfenv);

    tmppt1[0] = pnt->x;
    tmppt1[1] = pnt->y;
    tmppt1[2] = pnt->z;

    if(rfenv.md_env.matrix_type != MAIDMX)
     {
      MAinvmx( &bs_rc, &dim, rfenv.md_env.matrix, invmx);
      MAtypemx( &bs_rc, invmx, &invmxtyp);

      MAoptsxform( &bs_rc, &one, &invmxtyp, invmx, tmppt1, tmppt);
      memcpy(tmppt1, tmppt, sizeof(IGRpoint));

      pnt->x = tmppt[0];
      pnt->y = tmppt[1];
      pnt->z = tmppt[2];
     }

     if (out_dummy2)
      {
       struct GRmdenv_info *rfinfo;
       *out_dummy2 =(IGRchar *) malloc(sizeof(struct GRmdenv_info));
       rfinfo = (struct GRmdenv_info *) *out_dummy2;
       memcpy(rfinfo->matrix, rfenv.md_env.matrix, sizeof(IGRmatrix));
       rfinfo->matrix_type = rfenv.md_env.matrix_type;
      }
    }

	if (pnt->objid != NULL_OBJID)
	{
		cursor.objid = NULL_OBJID;
		cursor = *pnt;
		matrix = rot_matrix;
	}
	else	matrix = dyn_info->plan_info.win_plan.matrix;

	p1[0] = pnt->x;
	p1[1] = pnt->y;
	p1[2] = pnt->z;

	/*|- Fill dimension type */

	status =
	om$send(msg = message DMroot.get_dim_type(&dim_type),
		senderid = NULL_OBJID,
		targetid = dyn_info->dim_grid.objid,
		targetos = dyn_info->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	if (dim_type == RADIAL)
	{
		place_attr1 = (struct DMdyn_radial *)dyn_info->info;
		place_attr1->win_grid.objid = cursor.objid;
		place_attr1->win_grid.osnum = cursor.osnum;
	}
	else if (dim_type == SURF)
	{
		place_attr2 = (struct DMdyn_surf *)dyn_info->info;
		place_attr2->win_grid.objid = cursor.objid;
		place_attr2->win_grid.osnum = cursor.osnum;
	}
	else if (dim_type == WELD)
	{
		place_attr3 = (struct DMdyn_weld *)dyn_info->info;
		place_attr3->win_grid.objid = cursor.objid;
		place_attr3->win_grid.osnum = cursor.osnum;
	}

	dotp =
	fabs(BSdotp(&bs_rc,
		&matrix[8],
		&dyn_info->plan_info.win_plan.matrix[8]));
	plane_perp = (dotp < 0.0001);

	for (i=0; i<3; i++)
	{
		norm_to_plane[i] = dyn_info->plan_info.win_plan.matrix[i+8];
		pt_on_plane[i] = dyn_info->plan_info.win_plan.matrix[4*i+3];
		p2[i] = p1[i] + ((plane_perp)?
				dyn_info->plan_info.win_plan.matrix[i+8]:
				matrix[i+8]);
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

	if (dyn_info->control & FILL_INFO)
	{
		status =
		om$send(msg = message DMroot.update_parents(),
			senderid = NULL_OBJID,
			targetid = dyn_info->dim_grid.objid,
			targetos = dyn_info->dim_grid.osnum);
		dm$status(action = RET_STATUS);
	}

	level = 0;
	status =
	om$send(msg = message DMroot.dynamics(
					&rc,
					dyn_info->control,
					&level,
					(char *)dyn_info->info,
					matrix,
					dyn_info->md_env,
					ptproj),
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

		if (dim_type == RADIAL)
		{
			/*|- check if cross line buffer set */

			buf = (struct DPele_header *)place_attr1->buffer;
			if (buf[0].dis_att == NULL)
				*num_buffers = 0;
			else
			{
				/*|- cross line buffer set */

				*num_buffers = 2;
				*buffer = (struct DPele_header *)buf;
			}
		}
		else	*num_buffers = 0;
	}

	return(TRUE);
}

end implementation DMroot;
