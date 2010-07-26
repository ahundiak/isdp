class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "dimsrc.h"

from DMplan_mgr import create_dim_plane;

extern GRclassid OPP_dim_src_class_id;

IGRint DMcreate_root (type,
                      construct,
                      num_parents,
		      src_list,
                      context_list,
		      attr,
		      md_env,
		      p_root)
	 IGRint  type;
	 IGRshort  construct;
	 IGRint  num_parents;
	 struct GRid  *src_list;
	 struct GRid  *context_list;
	 IGRdouble  *attr;
	 struct GRmd_env  *md_env;
	 struct GRid  *p_root;
 /*
IGRint			type;
IGRshort		construct;
IGRint			num_parents;
struct GRid		*src_list;
struct GRid		*context_list;
IGRdouble		*attr;
struct GRmd_env 	*md_env;
struct GRid		*p_root;
 */
/*.DMcreate_root*/
{
	IGRint			status;
	IGRlong			long_rc;
	IGRint			index;
	struct GRid		parents[MAX_DIM_ROOTS];
	struct GRid		context[MAX_DIM_ROOTS];
	struct GRas		assoc_list;
	struct src_attr		src_attr;

	if (num_parents > MAX_DIM_ROOTS)
	{
		/*"DMcreate_root: Error in parent count %d\n", num_parents*/
		return(OM_E_ABORT);
	}

	if (DMancestry_valid(src_list[0], OPP_dim_src_class_id))
	{
		/*| - parent already a DMsrc object */

		if( (type == DMkeyseg) ||
		    (type == DMkeypt)  ||
		    (type == DMradcen) ||
		    (type == DMarc)    ||
		    (type == DMptdist))
		{
			p_root->objid = src_list[0].objid;
			p_root->osnum = src_list[0].osnum;
			return(OM_S_SUCCESS);
		}
		else
		{
			/*| - Invalid DMsrc object found */

			return(OM_E_ABORT);
		}
	}

	/*^ printf("num_parents = %d\n", num_parents); */

	for (index=0; index<num_parents; index++)
	{
		/*^
			printf("list[%d]=%d,%d\n",
				index,
				src_list[index].objid,
				src_list[index].osnum);
		*/

		status =
		as$make_source(
			go_grid = src_list[index],
			context_grid = context_list[index],
			as_os = md_env->md_id.osnum,
			as_grid = &parents[index]);
		dm$status(action = RET_STATUS);

		/*^
			printf("parents[%d]=%d,%d\n",
				index,
				parents[index].objid,
				parents[index].osnum);
		*/

/*
		status =
		om$send(msg = message NDnode.ASreturn_go(&go_grid, NULL, NULL),
			senderid = NULL_OBJID,
			targetid = parents[index].objid,
			targetos = parents[index].osnum);
		if (status & 1)
		{
			status =
			om$send(msg = message GRgraphics.GRgetprops(&rc, &props),
				senderid = NULL_OBJID,
				targetid = go_grid.objid,
				targetos = go_grid.osnum);
			if (status & 1)
			{
				*"props=%d\n", props*

				if (!(props & (GRIS_LOCATABLE | GRIS_DISPLAYABLE)))
					return(OM_E_ABORT);
			}
		}
*/
		context[index].objid = NULL_OBJID;
	}

	assoc_list.num_parents	= num_parents;
	assoc_list.parents	= parents;
	assoc_list.context	= context;
	assoc_list.as_attr	= (char *)&src_attr;
	src_attr.type		= type;
	src_attr.attr		= attr;

	if(construct)
	{
		/*|- Construct DMsrc object */

		p_root->osnum	= md_env->md_id.osnum;
		p_root->objid	= NULL_OBJID;

		status =
		om$construct(
			classname = "DMsrc",
			osnum   = p_root->osnum,
			p_objid = &p_root->objid);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*|- Use the existing DMsrc object */

		status =
		om$send(msg = message NDnode.NDdisconnect(0, NULL),
			senderid = NULL_OBJID,
			targetid = p_root->objid,
			targetos = p_root->osnum);
		dm$status(action = RET_STATUS);
	}

	/*| - NDplace - */

	status =
	om$send(msg = message NDnode.NDplace(
					&assoc_list,
					md_env,
					NULL),
		senderid = NULL_OBJID,
		targetid = p_root->objid,
		targetos = p_root->osnum);
	dm$status(action = RET_STATUS);

	/*| - Compute the src object - */

	status =
	om$send(msg = message NDnode.NDs_compute_node(
						&long_rc,
						NULL,
						md_env),
		senderid = NULL_OBJID,
		targetid = p_root->objid,
		targetos = p_root->osnum);
	dm$status(action = RET_STATUS);

	/*| - ND_DEL_NO_CH - */

	status =
	om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
		senderid = NULL_OBJID,
		targetid = p_root->objid,
		targetos = p_root->osnum);
	dm$status (action = RET_STATUS);

/*
	if (degrade)
	{
		status =
		om$send(msg = message NDnode.NDmove_to_root(
						&long_rc,
						&parents[0],
						md_env),
			senderid = NULL_OBJID,
			targetid = p_root->objid,
			targetos = p_root->osnum);
		dm$status(action = RET_STATUS);
	}
*/

	return(TRUE);
}

IGRint DMcopy_roots (dest,src,count)
        /* (
	 struct GRid  dest[],
	 struct GRid  src[],
	 IGRint  count
	)
	*/
struct GRid dest[], src[];
IGRint count;
/*.DMcopy_roots*/
{
	IGRint index;

	for (index=0; index<count; index++)
		dest[index] = src[index];

	return(TRUE);
}

IGRint DMcreate_dmplan (msg,
			win,
			count,
			list,
			ctx,
			attr,
			md_env,
			plan)
			/*(
	 IGRint  *msg,
	 struct GRid  win,
	 IGRint  count,
	 struct GRid  list[],
	 struct GRid  ctx[],
	 IGRdouble  attr[],
	 struct GRmd_env  *md_env,
	 struct GRid  *plan
	)
	*/
IGRint *msg;
struct GRid win;
IGRint count;
struct GRid list[];
struct GRid ctx[];
IGRdouble attr[];
struct GRmd_env *md_env;
struct GRid *plan;
{
	IGRint status, rc, index;
	struct GRid root[2], plan_mgr;
	IGRint dmtype;

	dmtype = (count == 2)?DMkeypt:DMkeyseg;

	/*"count = %d, dmtype = %d\n", count, dmtype*/
 
	for (index=0; index<count; index++)
	{
		status =
		dm$create_root(
			type = dmtype,
			count = 1,
			list = &list[index],
			context = &ctx[index],
			attr = &attr[3*index],
			md_env = md_env,
			p_root = &root[index]);
		dm$status(action = RET_STATUS);
	}

	status = DMget_plan_mgr(&plan_mgr);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMplan_mgr.create_dim_plane(
					&rc,
					win,
					md_env->md_env.matrix,
					count,
					root,
					md_env,
					plan),
		targetid = plan_mgr.objid,
		targetos = plan_mgr.osnum,
		senderid = NULL_OBJID);
	dm$status(action = RET_STATUS);
					
	*msg = MSSUCC;
	return(OM_S_SUCCESS);
}

end implementation DMroot;
