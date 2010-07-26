class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "macro.h"
#include "sunlimits.h"
#include "maidmx.h"

from ACpretend	  import ACpconnect, ACgive_downscan;
from ACpretendin  import ACiconnect;

#define path_MAX_CHAR 160

method NDmake_source(
	IGRlong *msg;
	struct GRid *located_obj;
	struct GRid *context;
	char *path;
	GRspacenum as_osnum;
	struct GRid *as)
{
	IGRint status, rc;
	IGRint nb_child, count, go_index, i, j;
	OM_S_OBJECT_LINKAGE list[20], clist[2];
	GRclassid obj_class, pretend_class;
	char foot_name[path_MAX_CHAR];
	char downscan[path_MAX_CHAR];
	struct GRid owner;
	struct GRid mygrid;

	extern GRclassid OPP_ACpretend_class_id;
	extern GRclassid OPP_ACpretendin_class_id;

	mygrid.objid = my_id;
	mygrid.osnum = OM_Gw_current_OS;
	owner.objid=NULL_OBJID;

	ASget_as_owner( &mygrid, &owner );

	if ((owner.objid != NULL_OBJID)
	&&  (located_obj->objid != my_id)
	&&  (DMancestry_valid(owner, OPP_DMroot_class_id)))
	{
		/*| assoc owner */

		status =
		om$send(msg = message DMroot.return_go_index(
							&rc,
							*located_obj,
							&go_index),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		sprintf(foot_name, "dim_foot_%d", go_index);

		if (path[0])
		{
			strcat(foot_name,":");
			strcat(foot_name, path);
		}

		status =
		om$send(msg = message NDnode.NDmake_source(
						msg,
						&mygrid,
						context,
						foot_name,
						as_osnum,
						as),
			targetid = owner.objid);
		dm$status(action = RET_STATUS);

		return(OM_S_SUCCESS);
	}


	/*
		To connect dependency 
		- use a sourcein object connected
		  by tag if there is a context
		- use a pretend object if there
		  is no context
	*/

	if (located_obj->objid == my_id
	&&  located_obj->osnum == as_osnum)
	{
		as->objid = my_id;
		as->osnum = OM_Gw_current_OS;
		return(OM_S_SUCCESS);
	}

	foot_name[0] = '\0';

	if (located_obj->objid != my_id)
	{
		status =
		om$send(msg = message DMroot.return_go_index(
							&rc,
							*located_obj,
							&go_index),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		sprintf(foot_name, "dim_foot_%d", go_index);
	}

	/*"find/create pretend for <%s>\n", foot_name*/

	pretend_class = (context->objid == NULL_OBJID)?
			OPP_ACpretend_class_id:
			OPP_ACpretendin_class_id;

	status =
	om$get_channel_objects(
		object = me,
		p_chanselect = (context->objid == NULL_OBJID)?
			&ND_children:&AS_notification,
		list = list,
		size = 20,
		count = (OMuint *) &nb_child);
	dm$status(action = RET_STATUS);

	for (i=0; i<nb_child; i++)
	{
		/*^ printf("list[%d]=%d,%d\n",
			i,
			list[i].S_objid,
			list[i].osnum); */

		status =
		om$get_classid(
			osnum = list[i].osnum,
			objid = list[i].S_objid,
			p_classid = &obj_class);
		dm$status(action = RET_STATUS);

		if (om$is_ancestry_valid(
			subclassid   = obj_class,
	        	superclassid = pretend_class)
			== OM_S_SUCCESS)
		{
			/*| It is ACpretend */

			status =
			om$send(msg = message ACpretend.ACgive_downscan(downscan),
	                  	targetid = list[i].S_objid, 
				targetos = list[i].osnum);
			dm$status(action = RET_STATUS);

			/*"pretend=<%s>\n", downscan*/

			if (!strcmp(foot_name, downscan))
			{
				/*|Name Match*/

				if (context->objid == NULL_OBJID)
				{
					/*| ACpretend exists */

					as->objid = list[i].S_objid;
					as->osnum = list[i].osnum;
					return(OM_S_SUCCESS);
				}

				status =
				om$get_channel_objects(
					objid = list[i].S_objid,
					osnum = list[i].osnum,
					p_chanselect = &AS_listeners,
					list = clist,
					size = 2,
					count = (OMuint *) &count);
				if (!(status & 1))
				{
					/*|Channel empty*/

					dm$status();
					continue;
				}

				for (j=0; j<count; j++)
				{
					/*^ printf("ctx[%d]=%d,%d\n",
						j,
						clist[j].S_objid,
						clist[j].osnum);
					*/

					if ((context->objid == clist[j].S_objid)
					&&  (context->osnum == clist[j].osnum))
					{
						/*| ACpretendin exists */

						as->objid = list[i].S_objid;
						as->osnum = list[i].osnum;
						return(OM_S_SUCCESS);
					}
				}
			}
		}
	}

	if (context->objid == NULL_OBJID)
	{
		/*| Creating ACpretend */

		as->osnum = OM_Gw_current_OS;

		status =
		om$construct(
			classid = OPP_ACpretend_class_id,
			osnum	= as->osnum,
			p_objid = &as->objid,
			msg 	= message ACpretend.ACpconnect(
						0,
						mygrid,
						foot_name));
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*"Creating ACpretendin in osnum %d\n", context->osnum */

		as->osnum = context->osnum;

		status =
		om$construct(
			classid = OPP_ACpretendin_class_id,
			osnum	= as->osnum,
			p_objid = &as->objid,
			msg 	= message ACpretendin.ACiconnect(
						0,
						mygrid,
						*context,
						foot_name));
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

method GRmksource(
	IGRlong *msg;
	struct GRid *context;
	GRspacenum target_os;
	struct GRid *source;
	IGRint option)
{
	IGRint status;
	struct GRid my_grid;
	char path[DI_PATH_MAX];

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	path[0] = 0;

	status =
	om$send(msg = message NDnode.NDmake_source(
					msg,
					&my_grid,
					context,
					path,
					target_os,
					source),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method ACgive_foot(
	int *suc;
	char *footname;
	struct GRid *foot_obj)
{
	IGRint status, rc;
	IGRint go_index;

	/*"footname=%s\n", footname*/

	if (!footname[0])
	{
		foot_obj->objid = my_id;
		foot_obj->osnum = OM_Gw_current_OS;

		/*^print_grid("foot_obj", foot_obj);*/
	}
	else
	{
		struct GRmd_env  dum_md_env;

		if (!sscanf(footname, "dim_foot_%d", &go_index))
		{
			printf("DMroot.Unknown foot %s\n", footname);
			*suc = FALSE;
			return(OM_W_ABORT);
		}

		/*"go_index=%d\n", go_index*/

		/*Get a dummy env for return_dim_go. Need a good env???
		 *  Dave Brann 11/03/91
                 */
		gr$get_module_env(buffer = &dum_md_env);

		status =
		om$send(msg = message DMroot.return_dim_go(
						&rc,
						go_index,
						FALSE,
						NULL,
						&dum_md_env,
						foot_obj),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	*suc = graphic_foot;
	return(OM_S_SUCCESS);
}

method ACreturn_foot(
	IGRlong *msg;
	char *footname;
	struct GRid *foot_obj;
	IGRshort *mat_type;
	IGRdouble *matrix)
{
	IGRint status;
	IGRlong long_rc;

	status =
	om$send(msg = message NDmacro.ACgive_foot((IGRint *) msg, footname, foot_obj),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	if (mat_type) *mat_type = MAIDMX;
	if (matrix)   MAidmx(&long_rc, matrix);

	return(OM_S_SUCCESS);
}

method ACgive_structure(
	int *suc;
	int *direct_index;
	char *footname;
	struct ret_struct *ptr_rst;
	struct GRmd_env *md_env)
{
	IGRint status, rc;
	struct GRid go;

	if (*direct_index == -1)
	{
		status =
		om$send(msg = message NDmacro.ACgive_foot(
						(IGRint *) suc,
						footname,
						&go),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}
	else
	{
		status =
		om$get_objid_at_index(
			objid = my_id,
			osnum = OM_Gw_current_OS,
			p_chanselect = &AS_to_comp,
			index = *direct_index,
			objidaddr = &go.objid,
			osnumaddr = &go.osnum);
		dm$status(action = RET_STATUS);
	}

	/*"go_index = %d\n", go_index*/

	if (rc = DIM_S_SUCCESS && go.objid != NULL_OBJID)
	{
		status =
		as$any_give_structure(
				go_grid = go,
				inst = ptr_rst,
				mod_env = md_env);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

end implementation DMroot;

