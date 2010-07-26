class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe

#include "macro.h"
#include "dimcenline.h"

from ACpretend import ACgive_downscan, ACpconnect;

#define AUTO_SIZE 20

method convert_feet(struct GRid dim_13)
{
	IGRint status;
	IGRint count, index;
	struct GRid foot, my_grid;
	OM_S_OBJECT_LINKAGE slist[AUTO_SIZE], *list;
	IGRchar foot_name[macro_MAX_CHAR];
	IGRchar ft[macro_MAX_CHAR];
	IGRint go_index;

	/*"my_id=%d, dim_type=%d\n",  my_id,  me->dim_type*/

	status =
	om$get_channel_count(
		objid = dim_13.objid,
		osnum = dim_13.osnum,
		p_chanselect = &ND_children,
		count = (OMuint *)&count);
	dm$status(action = RET_STATUS);

	if (!count) return(OM_S_SUCCESS);

	if (count > AUTO_SIZE)
	{
		printf("WARNING: This macro has too many feet %d\n", count);
		list = (OM_S_OBJECT_LINKAGE *) om$malloc(size = sizeof(OM_S_OBJECT_LINKAGE) * count);
		if (list == NULL)
		{
			dm$status(sts = OM_E_NODYNMEM, action = RET_STATUS);
		}
	}
	else	list = slist;

	status =
	om$get_channel_objects(
		objid = dim_13.objid,
		osnum = dim_13.osnum,
		p_chanselect = &ND_children,
		list = list,
		size = count,
		count =(OMuint *) &count);
	dm$status(action = RET_STATUS);

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	for (index=0; index<count; index++)
	{
		foot.objid = list[index].S_objid;
		foot.osnum = list[index].osnum;

		if (!DMancestry_valid(foot, OPP_ACpretend_class_id))
			continue;

		status =
		om$send(msg = message ACpretend.ACgive_downscan(foot_name),
			targetid = list[index].S_objid,
			targetos = list[index].osnum);
		dm$status(); if (!(status & 1)) continue;

		strcpy(ft, foot_name);
		DMupper_to_lower(ft);

		if (!strcmp(ft, "dim_line:0"))
			go_index = DIM_LINE1;
		else if (!strcmp(ft, "dim_line:1"))
			go_index = DIM_LINE2;
		else if (!strncmp(ft, "dim_line", 8))
			go_index = DIM_LINE1;
		else if (!strncmp(ft, "dim_witn_f", 10)
		     ||  !strncmp(ft, "dim_witn:1", 10))
			go_index = DIM_ORI_PROJ;
		else if (!strncmp(ft, "dim_witn_s", 10)
		     ||  !strncmp(ft, "dim_witn:2", 10))
			go_index = DIM_MEA_PROJ;
		else if (!strncmp(ft, "dim_term_f", 10))
			go_index = DIM_ORI_TERM;
		else if (!strncmp(ft, "dim_term_s", 10))
			go_index = DIM_MEA_TERM;
		else if (!strcmp(ft, "dim_text:dim_text"))
			go_index = DIM_TEXT;
		else if (!strncmp(ft, "dim_text", 8))
			go_index = DIM_LEADER;
		else if (!strncmp(ft, "dim_circ", 8))
			go_index = DIM_LINE1;
		else if (!strncmp(ft, "axis1", 5))
			go_index = DIM_LINE1;
		else if (!strncmp(ft, "axis2", 5))
			go_index = DIM_LINE2;
		else if (!strncmp(ft, "axis3", 5))
			go_index = DIM_LINE3;
		else if (!strncmp(ft, "axis4", 5))
			go_index = DIM_LINE4;
		else if (!strncmp(ft, "lseg1", 5))
			go_index = DIM_ORI_PROJ;
		else if (!strncmp(ft, "lseg2", 5))
			go_index = DIM_MEA_PROJ;
		else if (!strncmp(ft, "balloon:circle", 14))
			go_index = DIM_BALLOON;
		else if (!strcmp(ft, "line1"))
			go_index = DIM_LINE1;
		else if (!strcmp(ft, "line2"))
			go_index = DIM_LINE2;
		else if (!strcmp(ft, "text"))
			go_index = DIM_TEXT;
		else
		{
#ifdef DM_DEBUG
			printf("foot <%s>, dim_type=%d\n",
				foot_name, me->dim_type);
#endif

			status =
			om$send(msg = message Root.delete(1),
				targetid = foot.objid,
				targetos = foot.osnum);
			dm$status();

			continue;
		}

		/*"foot_name=<%s>, go_index=%d\n", foot_name, go_index*/

		status =
		om$send(msg = message Root.wild_disconnect(ND_father),
			targetid = foot.objid,
			targetos = foot.osnum);
		dm$status(); if (!(status & 1)) continue;

		sprintf(foot_name, "dim_foot_%d", go_index);

		status =
		om$send(msg = message ACpretend.ACpconnect(0, my_grid, foot_name),
			targetid = foot.objid,
			targetos = foot.osnum);
		dm$status();
	}

	if (list != slist) om$dealloc(ptr = list);

	return(OM_S_SUCCESS);
}

end implementation DMroot;
