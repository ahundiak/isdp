
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:32 $
$Locker:  $
$Log: dmexec.I,v $
Revision 1.1.1.1  2001/12/17 22:39:32  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:09:41  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:23:47  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:53:12  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.3  1994/08/31  03:55:44  samuel
# COMMENT : Corrected a check for malloc
#
# Revision 240.2  1993/08/24  14:07:22  gvk
# COMMENT : Updated GRcopy method
#
# Revision 240.1  1993/08/11  22:02:27  doree
# COMMENT : fixes for the solaris 5.2 sun build
#
# Revision 240.0  1992/12/06  23:48:39  tim
# COMMENT : Initial checkin to 2.4 RCS
#
# Revision 220.0  1992/08/29  06:27:15  root
# COMMENT : Corresponds to Rel201.14 in 2.0.1 RCS
#
Revision 201.14  1992/07/19  15:32:41  gvk
COMMENT : ANSI compilation and deleting obsolete functions.

*/

class implementation DMroot;

#define AS_DEBUG 1

#ifndef SUNOS5
%safe
#include "math.h"
%endsafe
#endif

#include "dimgraph.h"
#include "dimcomplex.h"

from dim_param import import_param;

IGRint DMbroadcast (msg,
                    level,
		    msglist,
		    msgcount,
		    p_root)
/*
	(
	 IGRint  *msg,
	 IGRint  level,
	 OM_S_MESSAGE  msglist[],
	 IGRint  msgcount,
	 struct GRid  *p_root
	)
*/
IGRint *msg;
IGRint level;
OM_S_MESSAGE msglist[];
IGRint msgcount;
struct GRid *p_root;
/*.DMbroadcast*/
{
	IGRint status;
	struct GRid static_list[32], *objlist;
	IGRint objcount, graphsize;
	IGRint i, j;

	objlist = static_list;
	graphsize = 32;
	objcount = 0;

	status =
	DMget_graph(*p_root, level, graphsize, objlist, &objcount);
	dm$status(action = RET_STATUS);

	if (objcount > 32)
	{
		objlist = (struct GRid *)om$malloc(size = sizeof(struct GRid) * objcount);
		if (objlist == NULL)
		{
			printf("DMbroadcast: malloc failed\n");
			return(FALSE);
		}

		graphsize = objcount;
		objcount = 0;

		status =
		DMget_graph(
			*p_root,
			level,
			graphsize,
			objlist,
			&objcount);
		dm$status(action = GOTO_VALUE, value = free_abort);
	}

	/*^
		printf("objcount=%d\n", objcount);
		for (i=0; i<objcount; i++)
			printf("obj[%d]=%d,%d\n",
				i, objlist[i].objid, objlist[i].osnum);
	*/

	status = TRUE;

	for (i=0; i<objcount; i++)
	{
		for (j=0; j<msgcount; j++)
		{
			status =
			om$send(msg = &msglist[j],
				senderid = NULL_OBJID,
				targetid = objlist[i].objid,
				targetos = objlist[i].osnum);
			if (status == OM_W_REJECTED_METHOD
			||  status == OM_W_UNKNOWN_MSG) continue;

			if (!(status & 1))
			{
				/*"obj=%d, message=%d\n", i, j*/
				dm$status();
				break;
			}
		}
	}

	free_abort:

	if (objlist != static_list) om$dealloc(ptr = objlist);
	*msg = DIM_S_SUCCESS;
	return(status);
}

IGRint DMdisplay_dimension(
	msg,
        level,
	control,
	md_env,
	p_root)
/*
	(
	 IGRint  *msg,
	 IGRint  level,
	 IGRint  control,
	 struct GRmd_env  *md_env,
	 struct GRid  *p_root
	)
*/
IGRint *msg;
IGRint level;
IGRint control;
struct GRmd_env *md_env;
struct GRid *p_root;
/*.DMdisplay_dimension*/
{
	IGRint status;
	IGRlong long_rc;
	OM_S_MESSAGE msglist[2];
	IGRint msgcount = 0;
	struct NDnode_NDdisplay_Msg     dspargs;
	struct GRgraphics_GRaddwrng_Msg addargs;
	struct GRgraphics_GRremwrng_Msg remargs;

	extern GRclassid OPP_GRgraphics_class_id;

	if (control & (ERASE | DISPLAY))
	{
		dspargs.obsolet = 0;
		dspargs.md_env = md_env;
		dspargs.mode = (control & ERASE)?GRbe:GRbd;

		status =
		om$make_message(
			classid = OPP_NDnode_class_id,
			methodname = "NDdisplay",
			size = sizeof(dspargs),
			p_arglist = &dspargs,
			p_msg = &msglist[msgcount++]);
		dm$status(action = RET_STATUS);
	}

	if (control & REMWRNG)
	{
		remargs.msg = &long_rc;
		remargs.md_info = md_env;

		status =
		om$make_message(
			classid = OPP_GRgraphics_class_id,
			methodname = "GRremwrng",
			size = sizeof(remargs),
			p_arglist = &remargs,
			p_msg = &msglist[msgcount++]);
		dm$status(action = RET_STATUS);
	}
	else if (control & ADDWRNG)
	{
		addargs.msg = &long_rc;
		addargs.md_info = md_env;

		status =
		om$make_message(
			classid = OPP_GRgraphics_class_id,
			methodname = "GRaddwrng",
			size = sizeof(addargs),
			p_arglist = &addargs,
			p_msg = &msglist[msgcount++]);
		dm$status(action = RET_STATUS);
	}

	status =
	DMbroadcast(msg, level, msglist, msgcount, p_root);
	dm$status(action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

IGRint DMmod_graph_batch_cp (flag,
			     cp_mode,
			     dm_graph,
			     dm_batch)
			     /*(
	 IGRint  flag,
	 IGRboolean  *cp_mode,
	 IGRint  *dm_graph,
	 IGRint  *dm_batch
	)
	*/
IGRint flag, *dm_graph, *dm_batch;
IGRboolean *cp_mode;
/*.DMmod_graph_batch_cp*/
{
	IGRint rc;
	IGRint old_graph, old_batch;
	IGRint sizbuf, nret;
	IGRboolean old_cp_mode;

	if (cp_mode)
	{
		sizbuf = sizeof(IGRboolean);

		if (flag & GET_MODE)
		gr$get_dynamics_copy_flag(
			msg = &rc,
			sizbuf = &sizbuf,
			buffer = &old_cp_mode,
			nret = &nret);

		if (flag & SET_MODE)
		gr$put_dynamics_copy_flag(
			msg = &rc,
			sizbuf = &sizbuf,
			buffer = cp_mode);

		/*"old_cp_mode=%d, cp_mode=%d\n", old_cp_mode, *cp_mode*/

		if (flag & GET_MODE)
			*cp_mode = old_cp_mode;
	}

	if (dm_graph)
	{
		if (flag & GET_MODE)
		nd$mod_graph(request = ND_INQ, p_ret_mode = &old_graph);

		if (flag & SET_MODE)
		nd$mod_graph(request = ND_SET, req_mode = *dm_graph);

		if (flag & GET_MODE) *dm_graph = old_graph;
	}
   
	if (dm_batch)
	{
		if (flag & GET_MODE)
		nd$mod_batch(request = ND_INQ, p_ret_mode = &old_batch);

		if (flag & SET_MODE)
		nd$mod_batch(request = ND_SET, req_mode = *dm_batch);

		if (flag & GET_MODE) *dm_batch = old_batch;
	}

	return(TRUE);
}

IGRint DMcopy_dimension (msg,
			 from_env,
			 to_env,
			 old_parent,
			 new_parent,
			 p_root,
			 p_copy)
			 /*(
	 IGRint  *msg,
	 struct GRmd_env  *from_env,
	 struct GRmd_env  *to_env,
	 OM_S_OBJID  old_parent,
	 OM_S_OBJID  new_parent,
	 struct GRid  *p_root,
	 struct GRid  *p_copy
	)
	*/
IGRint *msg;
struct GRmd_env *from_env, *to_env;
OM_S_OBJID old_parent, new_parent;
struct GRid *p_root, *p_copy;
/*.DMcopy_dimension*/
{
	IGRint status, count, rc, i, child_count;
	IGRlong long_rc, chan_index;
	struct GRid list[MAX_DIM_ROOTS], owner;
	struct GRid parents[MAX_DIM_ROOTS];
	struct GRid children[5], child_copy, context;
	extern GRclassid OPP_dim_param_class_id;

	p_copy->osnum = to_env->md_id.osnum;

	/*"Copy the element %d, %d\n",p_root->objid, p_root->osnum*/

	status =
	om$send(msg = message NDnode.NDcopy(
					&long_rc,
					0,
					from_env,
					to_env,
					p_copy),
		senderid = NULL_OBJID,
		targetid = p_root->objid,
		targetos = p_root->osnum);
	dm$status(action = RET_STATUS);

	/* Reconnect the clone to the roots of the initial element */

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					list,
					MAX_DIM_ROOTS,
					NULL,
					0,
					OM_K_MAXINT,
					&count),
		senderid = NULL_OBJID,
		targetid = p_root->objid,
		targetos = p_root->osnum);
	dm$status(action = RET_STATUS);

	if (p_copy->osnum != p_root->osnum)
	{
		/*| - get the context of root - */

		context.objid = NULL_OBJID;

		status =
		GRfindcontext(
			&rc,
			&from_env->md_env.matrix_type,
			from_env->md_env.matrix,
			&p_root->osnum,
			&context);

		/*^ print_grid("context", &context); */

		for (i=0; i<count; i++)
		{
			/*"list[%d]=%d,%d\n",i,list[i].objid,list[i].osnum*/

			if (list[i].objid != old_parent)
			{
				if (DMancestry_valid(list[i], OPP_dim_param_class_id))
				{
					status =
					om$send(msg = message dim_param.import_param(
								&rc,
								from_env,
								to_env,
								&parents[i]),
						senderid = NULL_OBJID,
						targetid = list[i].objid,
						targetos = list[i].osnum);
					dm$status(action = RET_STATUS);
				}
				else
				{
					status =
					as$make_source(
						go_grid = list[i],
						context_grid = context,
						as_os = to_env->md_id.osnum,
						as_grid = &parents[i]);
					dm$status(action = RET_STATUS);
				}
			}
			else
			{
				parents[i].objid = new_parent;
				parents[i].osnum = p_copy->osnum;
			}

			/*"parents[%d]=%d,%d\n",i,parents[i].objid,parents[i].osnum*/
		}
	}
	else
	{
		for (i=0; i<count; i++)
		{
			if (list[i].objid != old_parent)
			{
				parents[i] = list[i];
			}
			else
			{
				parents[i].objid = new_parent;
				parents[i].osnum = p_copy->osnum;
			}
		}
	}

	status =
	om$send(msg = message NDnode.NDconnect(
					count,
					parents,
					*p_root,
					ND_NEW),
	    senderid = NULL_OBJID,
	    targetid = p_copy->objid,
	    targetos = p_copy->osnum);
	dm$status(action = RET_STATUS);

	/*"Copy %d, %d\n",p_copy->objid, p_copy->osnum*/

	/*|- set the ND_DONT_MVRT bit so that the copied din is deleted properly*/

	status =
	om$send(msg = message NDnode.NDchg_state(ND_DONT_MVRT, ND_DONT_MVRT),
	    senderid = NULL_OBJID,
	    targetid = p_copy->objid,
	    targetos = p_copy->osnum);
	dm$status(action = RET_STATUS);

	/*|- Copy dependency */

	child_count = 0;

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_CHILDREN,
					children,
					5,
					NULL,
					0,
					OM_K_MAXINT,
					&child_count),
		senderid = NULL_OBJID,
		targetid = p_root->objid,
		targetos = p_root->osnum);
	dm$status(action = RET_STATUS);

	/*"child_count = %d\n", child_count*/

	if (child_count > 0)
	{
		for (i=0; i<child_count; i++)
		{
			status =
			DMcopy_dimension(
				msg,
				from_env,
				to_env,
				p_root->objid,
				p_copy->objid,
				&children[i],
				&child_copy);
			dm$status(action = RET_STATUS);
		}
	}

	owner.objid = NULL_OBJID;

	status =
	om$get_objid_at_index(
		objid = p_root->objid,
		osnum = p_root->osnum,
		p_chanselect = &AS_to_owner,
		index = 0,
		objidaddr = &owner.objid,
		osnumaddr = &owner.osnum);
	if ((!(status & 1)) || (owner.objid == NULL_OBJID))
		return(OM_S_SUCCESS);

	chan_index = 0;

	/*^
		print_grid("owner",&owner);
	*/

	/*|- connect the owner to my copy */

	status =
	om$send(msg = message GRconnector.GRrigidconn(
					&long_rc,
					&owner,
					&chan_index),
		senderid = p_copy->objid,
		targetid = p_copy->objid,
		targetos = p_copy->osnum);
	dm$status(action = RET_STATUS);

	*msg = DIM_S_SUCCESS;
	return(TRUE);
}

IGRint DMdelete_dimension (msg,
			   delete_graph,
			   md_env,
			   p_root)
			   /*(
	 IGRint  *msg,
	 IGRint  delete_graph,
	 struct GRmd_env  *md_env,
	 struct GRid  *p_root
	)
	*/
IGRint *msg;
IGRint delete_graph;
struct GRmd_env *md_env;
struct GRid *p_root;
/*.DMdelete_dimension*/
{
	IGRint status, rc;
	IGRlong long_rc;
	IGRboolean cp_mode;
	IGRint mod_graph, mod_batch;

	/*| Set the graph manager and the batch modes */

	if (!delete_graph)
	{
		status =
		om$send(msg = message DMroot.remove_from_cpx(&rc, DELETE_ACTION, md_env),
			targetid = p_root->objid,
			targetos = p_root->osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);
	}

	cp_mode = TRUE;
	mod_graph = ND_BROAD_DEL;
	mod_batch = ND_IMMEDIATE;

	DMmod_graph_batch_cp(
		GET_MODE | SET_MODE,
		&cp_mode,
		&mod_graph,
		&mod_batch);

	status =
	om$send(msg = message GRgraphics.GRdelete(&long_rc, md_env),
		senderid = NULL_OBJID,
		targetid = p_root->objid,
		targetos = p_root->osnum);
	dm$status(action = RET_STATUS);

	/*| Execute the delete */
	nd$exec_batch(mode = 0);

	DMmod_graph_batch_cp(
		SET_MODE,
		&cp_mode,
		&mod_graph,
		&mod_batch);

	*msg = DIM_S_SUCCESS;
	return(TRUE);
}

IGRint DMmake_grgrp (list,
		     count,
		     md_env,
		     grp_grid)
		     /*(
	 OM_S_OBJECT_LINKAGE  list[],
	 IGRint  *count,
	 struct GRmd_env  *md_env
	)
	*/
OM_S_OBJECT_LINKAGE list[];
IGRint *count;
struct GRmd_env *md_env;
struct GRid *grp_grid;
/*.DMmake_grgrp*/
{
	IGRint status, rc;
	IGRlong long_rc;
	struct GRvg_construct go_cnst_list;
	struct IGRdisplay display;
	int sizbuf, nret;
	IGRint index;
	IGRlong flag, indx1, indx2;
	struct GRid grgrp;

	sizbuf = sizeof(display);

	status =
	gr$get_active_display(
		msg = &rc,
		sizbuf = &sizbuf,
		buffer = &display,
		nret = &nret);
	dm$status(action = RET_STATUS);

	go_cnst_list.msg = &long_rc;
	go_cnst_list.env_info = md_env;
	go_cnst_list.newflag = FALSE;
	go_cnst_list.level = 0;
	go_cnst_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
	go_cnst_list.display = &display;
	go_cnst_list.class_attr = NULL;
	go_cnst_list.geometry = NULL;
	go_cnst_list.name = NULL;

	grgrp.osnum = md_env->md_id.osnum;

	status =
	om$construct(
		classname = "GRgrgrp",
		msg = message GRgraphics.GRconstruct(&go_cnst_list),
		p_objid = &grgrp.objid,
		osnum = grgrp.osnum);
	dm$status(action = RET_STATUS);

	flag = 1;
	indx1 = OM_K_MAXINT;
	indx2 = OM_K_MAXINT;

	for (index=0; index < *count; index++)
	{
		status =
		om$send(msg = message GRconnector.GRflexconn(
						&long_rc,
						&flag,
						&grgrp,
						&indx1,
						&indx2),
			senderid = NULL_OBJID,
			targetid = list[index].S_objid,
			targetos = list[index].osnum);
		dm$status(action = RET_STATUS);
	}

	*count = 0;
	grp_grid->objid = grgrp.objid;
	grp_grid->osnum = grgrp.osnum;
	return(OM_S_SUCCESS);	
}

/*
IGRint DMdelete_components (list,
			    count,
			    md_env)
			    
	 OM_S_OBJECT_LINKAGE  list[],
	 IGRint  *count,
	 struct GRmd_env  *md_env
	)
OM_S_OBJECT_LINKAGE list[];
IGRint *count;
struct GRmd_env *md_env;
{
	IGRint status, index;
	IGRlong long_rc;

	for (index=0; index < *count; index++)
	{
		status =
		om$send(msg = message GRgraphics.GRdelete(
						&long_rc,
						md_env),
			senderid = NULL_OBJID,
			targetid = list[index].S_objid,
			targetos = list[index].osnum);
		dm$status(action = RET_STATUS);
	}

	*count = 0;
	return(OM_S_SUCCESS);	
}
*/

IGRint DMchange_node (broadcast,exec_batch,as_grid,md_env)
/*(
	 IGRboolean  broadcast,
	 IGRboolean  exec_batch,
	 struct GRid  as_grid,
	 struct GRmd_env  *md_env
	)
*/
IGRboolean broadcast;
IGRboolean exec_batch;
struct GRid as_grid;
struct GRmd_env *md_env;
/*.DMchange_node*/
{
	IGRint status;
	IGRlong long_rc;
	IGRint info;
	extern IGRboolean ASbroadcast_in_progress;

	if (broadcast)
	{
		if (ASbroadcast_in_progress)
			return(OM_S_SUCCESS);

		info = ND_COMP;

		nd$wait_batch(
			type = GR_GEOM_POSTED,
			l_object = &as_grid,
			l_obj_info = &info,
			nb_obj   = 1);

		if (exec_batch)
			nd$exec_batch();
	}
	else
	{
		if (md_env->md_id.objid != NULL_OBJID)
		{
			status =
			om$send(msg = message NDnode.NDdisplay(0, GRbe, md_env),
				targetid = as_grid.objid,
				targetos = as_grid.osnum,
				senderid = NULL_OBJID);
			dm$status(action = RET_STATUS);
		}

		status = 
		om$send(msg = message NDnode.NDs_compute_node(&long_rc, ND_COMP, md_env),
			targetid = as_grid.objid,
			targetos = as_grid.osnum,
			senderid = NULL_OBJID);
		dm$status(action = RET_STATUS);

		if (md_env->md_id.objid != NULL_OBJID)
		{
			status =
			om$send(msg = message NDnode.NDdisplay(0, GRbd, md_env),
				targetid = as_grid.objid,
				targetos = as_grid.osnum,
				senderid = NULL_OBJID);
			dm$status(action = RET_STATUS);
		}
	}

	return(OM_S_SUCCESS);
}

end implementation DMroot;

