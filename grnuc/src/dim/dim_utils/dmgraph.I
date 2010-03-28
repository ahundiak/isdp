class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "dimgraph.h"

IGRint DMget_graph (root,level,size,list,count)
/*(
	 struct GRid  root,
	 int  level,
	 int  size,
	 struct GRid  list[],
	 int  *count
	)
*/
struct GRid root;
int    level;
int    size;
struct GRid list[];
int *count;
/*.DMget_graph*/
{
	IGRint status;
	OM_S_OBJECT_LINKAGE static_list[10], *tmp_list;
	struct GRid grid;
	OMuint tmp_count;
        IGRint  index;
	GRclassid obj_class;
	int sublevel;
	extern GRclassid OPP_DMroot_class_id;

	/*"level=%x\n", level*/

	if (level & ROOT)
	{
		/*"count=%d, root=%d,%d\n", *count, root.objid, root.osnum*/

		for (index=0; index<*count; index++)
		{
			if (list[index].objid == root.objid
			&&  list[index].osnum == root.osnum)
				return(TRUE);
		}

		if (size > *count)
			list[*count] = root;
		*count += 1;
	}

	if (!(level & CHILDREN))
		return(TRUE);
	else	level |= ROOT;

	status =
	om$get_channel_count(
		osnum = root.osnum,
		objid = root.objid,
		p_chanselect = &ND_children,
		count = &tmp_count);
	dm$status(action = RET_STATUS);

	if (tmp_count > 10)
	{
		tmp_list = (OM_S_OBJECT_LINKAGE *)malloc(
				sizeof(OM_S_OBJECT_LINKAGE) * tmp_count);
		if (tmp_list == NULL)
		{
			printf("DMget_graph: Malloc failed\n");
			return(FALSE);
		}
	}
	else	tmp_list = static_list;

	status =
	om$get_channel_objects(
		osnum = root.osnum,
		objid = root.objid,
		p_chanselect = &ND_children,
		list = tmp_list,
		size = tmp_count,
		count = &tmp_count);
	dm$status(action = GOTO_VALUE, value = free_abort);

	/* - If only immediate children are required
	     turn off CHILDREN flag - */

	if (level & IMMEDIATE_ONLY)
		level &= ~CHILDREN;

	for (index=0; index<tmp_count; index++)
	{
		grid.objid = tmp_list[index].S_objid;
		grid.osnum = tmp_list[index].osnum;
		sublevel = level;

		if (level & (COMPONENTS_ONLY | DIMENSIONS_ONLY))
		{
			status =
			om$get_classid(
				osnum = grid.osnum,
				objid = grid.objid,
				p_classid = &obj_class);
			dm$status(action = GOTO_VALUE, value = free_abort);
		}

		if (level & COMPONENTS_ONLY)
		{
			status =
			om$is_ancestry_valid(
				subclassid = obj_class,
				superclassid = OPP_DMroot_class_id);

			if (status == OM_S_SUCCESS)
			{
				/* - If only immediate components are
				     required skip next dimension(s) - */

				if (level & IMMEDIATE_ONLY)
					continue;
				else	sublevel &= ~ROOT;
			}
			else
			{
				/* - A Component of the dimension.
				     Obtain the entire sub graph - */

				sublevel = CHILDREN;
			}
		}
		else if (level & DIMENSIONS_ONLY)
		{
			status =
			om$is_ancestry_valid(
				subclassid = obj_class,
				superclassid = OPP_DMroot_class_id);

			if (status == OM_S_SUCCESS)
				sublevel |= ROOT;
			else	continue;
		}

		status =
		DMget_graph(
			grid,
			sublevel,
			size,
			list,
			count);
		dm$status(action = GOTO_VALUE, value = free_abort);
	}

	free_abort:
	if (tmp_list != static_list) free(tmp_list);
	return(TRUE);
}

IGRint DMbroadcast_subgraph (order,root,p_msg)
/*(
	 IGRint  order,
	 struct GRid  root,
	 OM_S_MESSAGE  *p_msg
	)
*/
IGRint order;
struct GRid root;
OM_S_MESSAGE *p_msg;
/*.DMbroadcast_subgraph*/
{
	#define AUTO_SIZE 20

	IGRint status, index;
        OMuint count;
	struct GRid child;
	extern GRclassid OPP_GRcmpowner_class_id;
	OM_S_OBJECT_LINKAGE *list = NULL, autolist[AUTO_SIZE];

	if (om$is_objid_valid(
		osnum = root.osnum,
		objid = root.objid) != OM_S_SUCCESS)
		return(OM_S_SUCCESS);

	status =
	om$get_channel_count(
		objid = root.objid,
		osnum = root.osnum,
		p_chanselect = &ND_children,
		count = &count);
	dm$status();

	if (count > AUTO_SIZE)
	{
		list = (OM_S_OBJECT_LINKAGE *)om$malloc(size = sizeof(OM_S_OBJECT_LINKAGE) * count);
		if (list == NULL)
		{
			dm$status(sts = OM_E_NODYNMEM, action = RET_STATUS);
		}
	}
	else	list = autolist;

	status =
	om$get_channel_objects(
		objid = root.objid,
		osnum = root.osnum,
		p_chanselect = &ND_children,
		size = count,
		list = list,
		count = &count);
	dm$status();

	if (order == TOP_DOWN)
	{
		if (DMancestry_valid(root, OPP_GRcmpowner_class_id))
		{
			/*|notify_disconnect*/

			/*^
				IGRchar classname[OM_K_MAXCLASS_LEN];

				status =
				om$get_classname(
					osnum = root.osnum,
					objid = root.objid,
					classname = classname);
				dm$status(action = RET_STATUS);

				printf("root=(%d,%d)\n", root.objid, root.osnum);
				printf("classname=<%s>\n", classname);
			*/

			DMnotify_disconnect(root);

			/*|delete components*/

			status =
			om$send(msg = p_msg,
				p_chanselect = &AS_to_comp,
				senderid = root.objid);
			dm$status();
		}

		status =
		om$send(msg = p_msg,
			targetid = root.objid,
			targetos = root.osnum,
			senderid = NULL_OBJID);
		dm$status(action =  RET_STATUS);
	}

	for (index=0; index<count; index++)
	{
		child.objid = list[index].S_objid;
		child.osnum = list[index].osnum;

		status =
		DMbroadcast_subgraph(order, child, p_msg);
		dm$status();
	}

	if (list != autolist) om$dealloc(ptr = list);

	if (order == BOTTOM_UP)
	{
		status =
		om$send(msg = p_msg,
			targetid = root.objid,
			targetos = root.osnum,
			senderid = NULL_OBJID);
		dm$status();
	}

	return(OM_S_SUCCESS);
}

DMnotify_disconnect (dim)
/*(
	 struct GRid  dim
	)
*/
struct GRid dim;
/*.DMnotify_disconnect*/
{
	IGRint status;
	IGRint i, j;
	IGRchar el_state;
	OM_S_OBJECT_LINKAGE S_parent[10], *parent;
	struct GRid *child, par_grid;
	OMuint parent_count;
        IGRint child_count;

	status =
	om$get_channel_count(
		objid = dim.objid,
		osnum = dim.osnum,
		p_chanselect = &ND_father,
		count = &parent_count);
	dm$status(action = RET_STATUS);

	if (!parent_count) return(OM_S_SUCCESS);

	if (parent_count < 10)
		parent = S_parent;
	else
	{
		parent = (OM_S_OBJECT_LINKAGE *)om$malloc(size = sizeof(OM_S_OBJECT_LINKAGE) * parent_count);
		if (parent == NULL)
		{
			dm$status(sts = OM_E_NODYNMEM, action = RET_STATUS);
		}
	}

	status =
	om$get_channel_objects(
		objid = dim.objid,
		osnum = dim.osnum,
		p_chanselect = &ND_father,
		size = parent_count,
		list = parent,
		count = &parent_count);
	dm$status();

	for (i=0; i<parent_count; i++)
	{
		par_grid.objid = parent[i].S_objid;
		par_grid.osnum = parent[i].osnum;

		status =
		om$send(msg = message NDnode.NDget_state(&el_state),
			senderid = NULL_OBJID,
			targetid = par_grid.objid,
			targetos = par_grid.osnum);
		dm$status(action = GOTO_VALUE, value = abort);

		if (!(el_state & ND_DEL_NO_CH))
			goto abort;

		status =
		om$send(msg = message NDnode.NDget_objects(
					ND_CHILDREN | ND_IN_BUF,
					NULL,
					0,
					&child,
					0,
					OM_K_MAXINT,
					&child_count),
			senderid = NULL_OBJID,
			targetid = par_grid.objid,
			targetos = par_grid.osnum);
		dm$status(action = GOTO_VALUE, value = abort);

		for (j=0;j<child_count; j++)
		{
			if (dim.objid != child[j].objid)
			{
				status =
				om$send(msg = message NDnode.NDget_state(&el_state),
					senderid = NULL_OBJID,
					targetid = child[j].objid,
					targetos = child[j].osnum);
				dm$status(action = GOTO_VALUE, value = abort);

				if(!(el_state & ND_WAIT_DEL))
					goto abort;
			}
		}

		status =
		om$send(msg = message NDnode.NDchg_state(ND_WAIT_DEL, ND_WAIT_DEL),
			senderid = NULL_OBJID,
			targetid = par_grid.objid,
			targetos = par_grid.osnum);
		dm$status(action = GOTO_VALUE, value = abort);

		DMnotify_disconnect(par_grid);
	}

	abort:

	if (parent != S_parent)
		om$dealloc(ptr = parent);
	return(status);
}

end implementation DMroot;

