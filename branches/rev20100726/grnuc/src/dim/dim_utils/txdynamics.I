class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "msdef.h"
#include "msmacros.h"
#include "dimannot.h"
#include "dimdyn.h"
#include "dimmod.h"
#include "dimgraph.h"
#include "dpdef.h"
#include "bsxlnpl.h"
#include "bsdotp.h"
/*
#include "gotext.h"
*/

from IGEgragad import	DPinrot;
from DMannot import	txdynamics;
from DMannot import 	get_disp_list;

extern GRclassid OPP_DMweld_class_id; 

IGRint DMinvoke_txdynamics (msg,
                            dynamics,dyn_info,msgkey,preproc,postproc,pre_state,
                            post_state,copy,cp_grid,control,md_env,event,dim_grid)                      
/*(
                            
	 IGRint  *msg;
	 IGRint  dynamics,
	 struct DMtxdynamics_info  *dyn_info,
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
struct DMtxdynamics_info *dyn_info;
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
/*.DMinvoke_txdynamics*/
{
	IGRint status, rc;
	IGRlong long_rc;
	struct GRmd_env dyn_env;
	struct GRid dyn_grid;
	IGRint  dspgraph, computegraph;
	IGRint dsp_control;
	IGRdouble matrix[16];
	IGRboolean cp_mode;
	IGRint mod_batch, DMannotdyn();
	IGRboolean pnt_flag,char_flag;
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
						&dyn_info->plan_info),
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum,
		senderid = NULL_OBJID);
	dm$status(action = RET_STATUS);

	/*^
		print_matrix("dim_plane", dyn_info->plan_info.win_plan.matrix);
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

	if (preproc & CLEAR_OFFSET)
	{
		status =
		om$send(msg = message DMroot.clear_offset(),
			targetid = dyn_grid.objid,
			targetos = dyn_grid.osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	if (preproc & SET_STATE)
	{
		status =
		om$send(msg = message DMroot.set_dim_state(BIT_SET, pre_state),
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

	dyn_info->display_count = 0;
	status =
	DMget_graph(
		dyn_grid,
		dspgraph,
		MAX_GRAPH_SIZE,
		dyn_info->display_list,
		&dyn_info->display_count);
	dm$status(action = RET_STATUS);

	dyn_info->compute_count = 0;
	status =
	DMget_graph(
		dyn_grid,
		computegraph,
		MAX_GRAPH_SIZE,
		dyn_info->compute_list,
		&dyn_info->compute_count);
	dm$status(action = RET_STATUS);

	/*^
		int i;

		printf("display_count = %d\n", dyn_info->display_count);
		for (i=0; i<dyn_info->display_count; i++)
		printf("%d) %d, %d\n",
			i,
			dyn_info->display_list[i].objid,
			dyn_info->display_list[i].osnum);

		printf("compute_count = %d\n", dyn_info->compute_count);
		for (i=0; i<dyn_info->compute_count; i++)
		printf("%d) %d, %d\n",
			i,
			dyn_info->compute_list[i].objid,
			dyn_info->compute_list[i].osnum);
	*/

	dyn_info->control = control | FILL_INFO;
	dyn_info->dim_grid = dyn_grid;
	dyn_info->md_env  = &dyn_env;

	cp_mode = FALSE;
	mod_batch = ND_TRANSACTION;

	status =
	DMmod_graph_batch_cp(GET_MODE | SET_MODE, &cp_mode, NULL, &mod_batch);
	dm$status(action = RET_STATUS);

	if (dynamics)
	{
		dyn_info->msgkey = msgkey;
		DPtxdynamics(DMannotdyn, dyn_info,NULL,NULL,NULL);
	}
	else
	{
		dyn_info->msgkey = NULL;

		status =
		om$send(msg = message IGEgragad.DPinrot(&long_rc, matrix),
			senderid = NULL_OBJID,
			targetid = event->event.button.objid,
			targetos = event->event.button.osnum);
		dm$status(action = RET_STATUS);
		pnt_flag = TRUE; char_flag = FALSE;
		status = 
		DMannotdyn(
			dyn_info,
			&(event->event.button),
			&pnt_flag,
			NULL,
			0,
			&char_flag,
			matrix,
			NULL,	/* objects */
			NULL,	/* num_objects */
			NULL,	/* buffer */
			NULL,	/* num_buffers */
			NULL,	/* outflags */
			NULL);	/* viewind */
		dm$status();
	}

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

	if (postproc & SET_STATE)
	{
		status =
		om$send(msg = message DMroot.set_dim_state(BIT_SET, post_state),
			targetid = dyn_grid.objid,
			targetos = dyn_grid.osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	*msg = OM_S_SUCCESS;
	return(TRUE);
}

#argsused
IGRint DMannotdyn (info,pnt,pnt_flag,character,num_bytes,char_flag,
                   rot_matrix,objects,num_objects,buffers,num_buffers,out_flags,viewind)
/*(
	 struct DMdynamics_info  *info,
	 struct EX_button  *pnt,
	 IGRboolean  *pnt_flag,
	 IGRuchar  *character,
	 IGRint  num_bytes,
	 IGRboolean  *char_flag,
	 IGRdouble  *rot_matrix,
	 struct GRid  **objects,
	 IGRint  *num_objects,
	 struct DPele_header  **buffers,
	 IGRint  *num_buffers,
	 IGRint  *out_flags,
	 struct DPviewind  **viewind
	)
*/
struct DMdynamics_info *info;  /*      information for DPdynamics       */     
struct EX_button    *pnt;        /*    current cursor position in world*/
IGRboolean          *pnt_flag;     /*  flag is set if cursor was moved   */    
IGRuchar    *character;     /* character entered by user             */
IGRint              num_bytes;  /*     number of bytes from software queue */  
IGRboolean          *char_flag;   /*   flag is set if user entered a char.   */
IGRdouble           *rot_matrix;    /* window view rotation atrix           */
struct GRid         **objects; /*      objects that are in dynamics          */
IGRint              *num_objects; /*   number of objects in dynamics         */
struct DPele_header **buffers;      /* buffered elements in dynamics         */
IGRint              *num_buffers;/*    number of buffered elements           */
IGRint              *out_flags;    /*  indicates whether or not text is      */
struct DPviewind    **viewind;       /*info to provide if text is view ind   */
/*.DMannotdyn*/
{
	IGRint status, rc;
	IGRlong long_rc, msg;
	struct DMtxdynamics_info *dyn_info;
	struct DMdyn_annot *place_attr;
	struct DMdyn_weld *place_attr1;
	IGRint level, i;

	static struct EX_button  cursor;
	IGRpoint  norm_to_plane;
	IGRpoint  p1, p2, pt_on_plane; 
	IGRdouble *matrix, dotp;
	IGRint info_flag, weld;
	IGRboolean plane_perp;
	BSrc bs_rc;

	dyn_info = (struct DMtxdynamics_info *)info;
	place_attr = (struct DMdyn_annot *)&dyn_info->info;
	place_attr1 = (struct DMdyn_weld *)&dyn_info->info1;

	weld = 0;

	weld = DMancestry_valid(dyn_info->dim_grid, OPP_DMweld_class_id);

	if (dyn_info->msgkey)
	{
		ex$message(msgnumb = dyn_info->msgkey,
			   justification = RIGHT_JUS);
		dyn_info->msgkey = NULL;
	}

	if (pnt->objid != NULL_OBJID)
	{
		cursor = *pnt;
		matrix = rot_matrix;
	}
	else	matrix = dyn_info->plan_info.win_plan.matrix;


	p1[0] = pnt->x;
	p1[1] = pnt->y;
	p1[2] = pnt->z;

	place_attr1->win_grid.objid = cursor.objid;
	place_attr1->win_grid.osnum = cursor.osnum;
	place_attr->win_grid.objid = cursor.objid;
	place_attr->win_grid.osnum = cursor.osnum;

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
		&cursor.x);
	
	/*^
		print_matrix("win_matrix", rot_matrix);
		print_matrix("dim_plane", dyn_info->plan_info.win_plan.matrix);
		print_point("p1", p1);
		print_point("p2", p2);
		print_point("pt_on_plane",pt_on_plane);
		print_point("norm_to_plane",norm_to_plane);
		printf("cursor = %f, %f, %f\n",cursor.x,cursor.y,cursor.z);
		printf("pnt_flag=%d, char_flag=%d\n", *pnt_flag, *char_flag);

	*/
	
	/*|Calling dynamics*/


	info_flag = 0;
	if( *pnt_flag)
		info_flag |=PNT_MOVED;
	if( *char_flag)
	{
        	info_flag |=TEXT_ENTERED;
		DPtxdyn_set_drawing_mode( WL_DYN_ERASE_MODE );
		dp$erase_hilite(msg = &msg);
	}
	level = 0;
	status =
	om$send(msg = message DMannot.txdynamics(
					&long_rc,
					dyn_info->control,
					info_flag,
					&level,
					(weld)?(char *)&dyn_info->info1:
						(char *)&dyn_info->info,
					&cursor,
					character,
					num_bytes,
					matrix,
					dyn_info->md_env),
		senderid = NULL_OBJID,
		targetid = dyn_info->dim_grid.objid,
		targetos = dyn_info->dim_grid.osnum);
	dm$status(action = RET_STATUS);
	
	dyn_info->control &= (~FILL_INFO);

	if(!objects) return(TRUE);

	status =
	om$send(msg = message DMannot.get_disp_list(
					&rc,
					&dyn_info->display_count,
					dyn_info->display_list,
					dyn_info->md_env),
		senderid= NULL_OBJID,
		targetid= dyn_info->dim_grid.objid,
		targetos= dyn_info->dim_grid.osnum);
	dm$status(action = RET_STATUS);

	/*^
		printf("display count = %d\n", dyn_info->display_count);
		for(i=0; i<dyn_info->display_count; i++)
		printf("display_list[%d] = %d, %d\n",i,
				dyn_info->display_list[i].objid,
				dyn_info->display_list[i].osnum);
	*/

	*num_objects = dyn_info->display_count;
	*objects = dyn_info->display_list;

	if (weld) *num_buffers = 0;
	else
	{
		if(place_attr->ele_header.dis_att == NULL)
		{
			/*|- place attr ele_header.dis_att is NULL */
			*num_buffers = 0;
		}
		else
		{
			/*|- place attr ele_header.dis_att is not NULL */

			*num_buffers = 1;
			*buffers = &place_attr->ele_header;
		}
	}

	return(TRUE);
}

end implementation DMroot;
