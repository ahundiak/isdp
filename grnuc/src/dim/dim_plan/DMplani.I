/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:31 $
$Locker:  $
$Log: DMplani.I,v $
Revision 1.1.1.1  2001/12/17 22:39:31  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:08:32  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:22:33  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:52:03  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.4  1994/11/01  10:12:19  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.3  1994/08/27  06:45:06  gvk
# COMMENT : 1.4 converted dimensions with measurement axis will recompute properly.
#
# Revision 400.0  1994/03/16  18:29:31  grnuc40
# COMMENT : Initial checkin to 4.0 RCS
#
# Revision 240.2  1993/05/16  11:01:11  gvk
# COMMENT : Fixes for dimension font TRs.
#
# Revision 240.1  1992/12/23  20:37:55  gvk
# COMMENT : Measurement angle needs to be recomputed for 1.4 files.
#
# Revision 220.1  1992/10/19  21:12:57  poo
# COMMENT : Fix to handle Coordinate system as a dimension plane or dimensions parent.
#
Revision 201.20  1992/08/17  08:21:59  poo
COMMENT : Calling NDgive_structure in compute, to take care of ref plane & Coordinate system.

Revision 201.19  1992/07/20  05:44:48  gvk
COMMENT : ANSI compilation, global modification of DMglobal to DM_global.

*/

class implementation DMplan;

#define AS_DEBUG 1
%safe
#include "math.h"
%endsafe

#include "OMminimum.h" 
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "madef.h"
#include "bserr.h"
#include "asmacros.h"
#include "dpmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "GM.h"
#include "ndmacros.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "dim.h"
#include "dimplan.h"
#include "dm_status.h"
#include "dimmacros.h"
#include "dimacc.h"
#include "dimext.h"
#include "dimerror.h"
#include "dimdef.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "maidmx.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bscrossp.h"

extern double fabs();
extern GRclassid OPP_dim_src_class_id,
                 OPP_GRgencs_class_id;

from DMplan_mgr import create_dim_plane;

/* *************************  Method NDplace  ****************************

ABSTRACT: This is method is used intialise the associative object and
	  store the instance data.

	  instance DMplan
	  {
	    IGRdouble xaxis[3];   unit vector in postive X-axis.
	    IGRdouble yaxis[3];   unit vector in postive Y-axis.
	  };

RETURN CODE:

 - This function returns always OM_S_SUCCESS.

*************************************************************************/


method NDplace(
	struct GRas *assoc_list;
	struct GRmd_env *md_env;
	IGRchar *go_cnst_lis)
{
	IGRint		status, rc, i;
	IGRlong		long_rc, bsrc;
	IGRdouble	matrix[16];
	struct GRid	null_grid;
	struct DMplan_attr *plan_attr;
	struct var_list list_var[2];

	/* Root elements are connected to the object of class DMplan */

	if (assoc_list->num_parents)
	{
		null_grid.objid = NULL_OBJID;

		status =
		om$send(msg = message NDnode.NDconnect(
					assoc_list->num_parents,
					assoc_list->parents,
					null_grid,
					ND_NEW),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	plan_attr = (struct DMplan_attr *)assoc_list->as_attr;

	if (plan_attr->win_grid.objid != NULL_OBJID)
	{
		if (DMancestry_valid(plan_attr->win_grid, OPP_dim_plan_class_id))
		{
			/*|- Get the matrix from refernce plane*/
			
			status =
			om$send(msg = message dim_plan.give_plane(
							&rc,
							matrix,
							md_env),
				targetid = plan_attr->win_grid.objid,
				targetos = plan_attr->win_grid.osnum);
			dm$status(action = RET_STATUS);
		}
		else
		{
			/*|- Get the matrix from window */

			list_var[0].var = VW_ROT_NO_CON;
			list_var[0].var_ptr = (char *)matrix;
			list_var[0].num_bytes = sizeof (IGRmatrix);
			list_var[0].bytes_returned = (IGRlong *)&long_rc;

			list_var[1].var = END_PARAM;
			list_var[1].var_ptr = NULL;
			list_var[1].num_bytes = 0;
	        	list_var[1].bytes_returned = NULL;

			status =
			dp$inq_set_gragad (
				msg = &long_rc,
        			osnum = plan_attr->win_grid.osnum,
				gragad_objid = plan_attr->win_grid.objid,
        			which_error = &long_rc,
               		 	var_list = list_var);
			dm$status(action= RET_STATUS);
		}
	}
	else	memcpy(matrix, plan_attr->matrix, sizeof(double)*16);

	for (i=0; i<3; i++)
	{
		me->xaxis[i] = matrix[i];
		me->yaxis[i] = matrix[i+4];
	}

	me->win_objid = plan_attr->win_grid.objid;
	BSnorvec(&bsrc, me->xaxis);
	BSnorvec(&bsrc, me->yaxis);

	status =
	om$send(msg = message NDnode.NDs_compute_node(&long_rc, NULL, md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method give_plane(
	IGRint *msg;
	IGRmatrix matrix;
	struct GRmd_env *md_env)
{
	IGRint 	index, rc;
	IGRvector zaxis;
	BSrc	bsrc;

	BScrossp(&bsrc, me->xaxis, me->yaxis, zaxis);
	MAidmx(&bsrc, matrix);

	for (index=0; index<3; index++)
	{
		matrix[index] = me->xaxis[index];
		matrix[index + 4] = me->yaxis[index];
		matrix[index + 8] = zaxis[index];
	}

	if (md_env->md_env.matrix_type != MAIDMX)
	{
		DMtransform_matrix(matrix, md_env);
	}

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method give_axis(
	IGRint *msg;
	IGRvector axis;
	struct GRmd_env *md_env)
{
	IGRint 	status, rc;
	IGRlong long_rc;
	IGRmatrix matrix;
	struct GRid my_grid,list[10];
	IGRint count,lcount = 0;
	struct GRmd_env mod_info;

	if( fabs(me->mea_angle - 0.0) <1.0e-4)
	{
		/*|- Measure Axis not Set */

		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;
		DMget_parents(my_grid,10,list,&count);

		/* initialize lcount to proper value  if the first parent 
	           is not a reference plane. TR#119421610. -gvk 26 Aug 94
		 */
		if(count && (DMancestry_valid(list[0],OPP_dim_plan_class_id) ||
		    DMancestry_valid(list[0],OPP_GRgencs_class_id)))
		    lcount = count-1;
		else lcount = count;

		if(lcount)
		{
		        DMget_module_info(&mod_info);
			
			status =
			om$send(msg = message NDnode.NDcompute_node(
							&long_rc,
							0,
							count,
							list,
							&mod_info),
				targetid = my_id);
			dm$status(action = RET_STATUS);
		}
		if( fabs(me->mea_angle - 0.0)<1.0e-4)
		{
			*msg = NO_AXIS;
			return(OM_S_SUCCESS);
		}

	}

	/*|- Measure Axis Set */

	status =
	om$send(msg = message DMplan.give_plane(
					&rc,
					matrix,
					md_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*"me->mea_angle = %f\n", me->mea_angle*/

	MATH_rotate_vector(
		&rc,
		matrix,
		me->mea_angle,
		matrix,
		axis);

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method translate(
	OM_S_OBJID win_objid;
	struct GRid *plan_grid)
{
	IGRint count, status;
	struct GRid list[3];
	
	if (me->win_objid == win_objid)
	{
		/* - If change dependent is done on DMplan object
		     which as reference plane object as its parent
		     and coordinate system is connected, the "win_objid"
		     stored in the instance is not updated. So we need
		     to check whether the parent is still "win_objid"
		*/

		status =
		om$send(msg = message dim_plan.give_parents(
						&count,
						list),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		if (count > 1)
		{
			if (list[0].objid == me->win_objid)
			{
				plan_grid->objid = my_id;
				plan_grid->osnum = OM_Gw_current_OS;
				return(OM_I_STOP_SENDING);
			}
		}		
		else
		{
			plan_grid->objid = my_id;
			plan_grid->osnum = OM_Gw_current_OS;
			return(OM_I_STOP_SENDING);
		}
	}

	return(OM_S_SUCCESS);
}

method matcmp(IGRint *msg; IGRdouble matrix[16])
{
	IGRint rc, i;
	IGRvector xaxis, yaxis;
	IGRdouble dotp_x, dotp_y;
	BSrc	bsrc;

	for (i=0; i<3; i++)
	{
		xaxis[i] = matrix[i];
		yaxis[i] = matrix[i+4];
	}

	BSnorvec(&bsrc, xaxis);
	BSnorvec(&bsrc, yaxis);

	dotp_x = BSdotp(&bsrc, me->xaxis, xaxis);
	dotp_y = BSdotp(&bsrc, me->yaxis, yaxis);

	/*^
		print_point("me->xaxis", me->xaxis);
		print_point("me->yaxis", me->yaxis);
		print_point("xaxis", xaxis);
		print_point("yaxis", yaxis);
		printf("dotp_x=%lf\n", dotp_x);
		printf("dotp_y=%lf\n", dotp_y);
	*/

	if ((dotp_x > DOTP_LOWER_BOUND && dotp_x < DOTP_UPPER_BOUND) &&
	    (dotp_y > DOTP_LOWER_BOUND && dotp_y < DOTP_UPPER_BOUND))
	{
		/*| - No difference - */
		*msg = 0;
	}
	else
	{
		/*| - Different - */
		*msg = 1;
	}

	return(OM_S_SUCCESS);
}

method update_plan(
	IGRint *msg;
	struct GRmd_env *md_env;
	struct GRid *new_plan)
{
	IGRint status, rc, count;
	IGRlong long_rc;
	IGRmatrix matrix;
	struct GRid win_grid, plan_mgr, parent;
	struct var_list list_var[2];

	win_grid.objid = me->win_objid;
	win_grid.osnum = OM_Gw_current_OS;

	if (DMancestry_valid(win_grid, OPP_dim_plan_class_id))
	{
		status =
		om$send(msg = message dim_plan.give_plane(
						&rc,
						matrix,
						md_env),
			targetid = me->win_objid);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*|- Get the matrix from window */

		list_var[0].var = VW_ROT_NO_CON;
		list_var[0].var_ptr = (char *)matrix;
		list_var[0].num_bytes = sizeof (IGRmatrix);
		list_var[0].bytes_returned = (IGRlong *)&long_rc;

		list_var[1].var = END_PARAM;
		list_var[1].var_ptr = NULL;
		list_var[1].num_bytes = 0;
        	list_var[1].bytes_returned = NULL;

		status =
		dp$inq_set_gragad (
			msg = &long_rc,
       			osnum = OM_Gw_current_OS,
			gragad_objid = me->win_objid,
       			which_error = &long_rc,
       		 	var_list = list_var);
		dm$status(action= RET_STATUS);
	}

	status =
	om$send(msg = message DMplan.matcmp(&rc, matrix),
		targetid = my_id);
	dm$status(action =  RET_STATUS);

	if (!rc)
	{
		/*| - Window Not Rotated - */

		new_plan->objid = my_id;
		new_plan->osnum = OM_Gw_current_OS;
	}
	else
	{
		/*| - Window Rotated - */

		status = DMget_plan_mgr(&plan_mgr);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message GRconnector.GRdisconn(&long_rc, &plan_mgr),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH),
			targetid = my_id);
		dm$status(action = RET_STATUS);

		dbg$print(msg = "Creating Dimension Plane - Update");

		if (DMancestry_valid(win_grid, OPP_dim_plan_class_id))
		{
			/*| - win_grid is a reference plane  */

			parent.objid = win_grid.objid;
			parent.osnum = win_grid.osnum;
			count = 1;
		}
		else
		{
			count = 0;
			parent.objid = NULL_OBJID;
		}

		status =
		om$send(msg = message DMplan_mgr.create_dim_plane(
							&rc,
							win_grid,
							matrix,
							count,
							&parent,
							md_env,
							new_plan),
			targetid = plan_mgr.objid,
			targetos = plan_mgr.osnum);
		dm$status(action = RET_STATUS);
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method translate_local(
	IGRint *msg;
	OM_S_OBJID win_objid;
	IGRdouble matrix[16];
	IGRint count;
	struct GRid *list;
	IGRdouble axis[6];
	struct GRmd_env *md_env;
	struct GRid *plan_grid)
{
	IGRint status, rc, i;
	IGRint parcount;
	struct GRid parlist[2];

	*msg = 0;

	status =
	om$send(msg = message DMplan.matcmp(&rc, matrix),
		targetid = my_id);
	dm$status(action =  RET_STATUS);

	if (!rc)
	{
		struct GRid my_grid;

		/*| - Window Orientation Match - */

		my_grid.objid = my_id;
		my_grid.osnum = OM_Gw_current_OS;

		DMget_parents(my_grid, 2, parlist, &parcount);
		if (parcount)
		DMget_parents(parlist[0], 2, parlist, &parcount);

		if (count != parcount)	return(OM_S_SUCCESS);

		for (i=0; i<count; i++)
		{
			if (list[i].objid != parlist[i].objid
			||  list[i].osnum != parlist[i].osnum)
				return(OM_S_SUCCESS);
		}

		plan_grid->objid = my_id;
		plan_grid->osnum = OM_Gw_current_OS;

		*msg = DIM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	return(OM_S_SUCCESS);
}

method NDcompute_node(
	IGRlong *msg;
	IGRint cn_type;
	IGRint count;
	struct GRid list[];
	struct GRmd_env *md_env)
{
	IGRint status, rc, i, j, index, num_parents;
	IGRlong long_rc;
	IGRdouble mea_axis[3], *mat;
	IGRmatrix matrix;
	struct ret_struct ret_struct;

	if(!count)
	{
		/*|- No parents - measurement axis not set */
		me->mea_angle = 0.0;
		return(OM_S_SUCCESS);
	}

	index = 0;
	num_parents = count;
	ret_struct.type = NULL;

	status =
	om$send(msg = message NDnode.NDgive_structure(
						&long_rc,
						&ret_struct,
						md_env),
		targetid = list[0].objid,
		targetos = list[0].osnum);
	dm$status(action = RET_STATUS);
	
	if (ret_struct.type == ref_generic)
	{
		/*|- Parent is reference plane or coordinate system*/

		/*- Need to transpose the matrix returned by
		    the NDgive_structure, since the format is
		    different from DMplan matrix */

		me->win_objid = list[0].objid;

		mat = ret_struct.var.ref_st.t;

		for (i=0; i<4; i++)
		    for (j=0; j<4; j++)
			matrix[i*4+j] = mat[j*4+i];

		for (i=0; i<3; i++)
		{
			me->xaxis[i] = matrix[i];
			me->yaxis[i] = matrix[i+4];
		}

		if (count < 2)
		{
			/*|- No parents - measurement axis not set */
			me->mea_angle = 0.0;
			return(OM_S_SUCCESS);
		}	

		num_parents--;
		index++;
	}
	else
	{
		status =
		om$send(msg = message DMplan.give_plane(
						&rc,
						matrix,
						md_env),
			targetid = my_id);
		dm$status(action = RET_STATUS);
	}

	status =
	DMcompute_mea_axis(
		&rc,
		&list[index],
		num_parents,
		mea_axis,
		matrix,
		md_env);
	dm$status(action = RET_STATUS);

	MATH_ang_bet_lines(matrix, mea_axis, &me->mea_angle, &matrix[8]);

	/*^  printf("mea_angle = %f\n",me->mea_angle); */

	*msg = OM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method change_copy(
	IGRint *msg;
	struct GRmd_env *fr_env;
	struct GRmd_env *to_env)
{
	IGRint status, rc, index;
	IGRmatrix matrix;

	status =
	om$send(msg = message DMplan.give_plane(
					&rc,
					matrix,
					fr_env),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	/*| - store the new axis in instance data */

	for(index=0; index<3; index++)
	{
		me->xaxis[index] = matrix[index];
		me->yaxis[index] = matrix[index+4];
	}

	*msg = DIM_S_SUCCESS;
	return(OM_S_SUCCESS);
}

method give_parents(
	IGRint *count;
	struct GRid list[])
{
	IGRint status;

	status =
	om$send(msg = message NDnode.NDget_objects(
					ND_ROOT,
					list,
					MAX_DIM_ROOTS,
					NULL,
					0,
					OM_K_MAXINT,
					count),
		targetid = my_id);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

method NDmake_source(
	IGRlong *msg;
	struct GRid *located_obj;
	struct GRid *context;
	char *path;
	GRspacenum as_osnum;
	struct GRid *as)
{
	struct GRid owner, mygrid;

	mygrid.objid = my_id;
	mygrid.osnum = OM_Gw_current_OS;
	owner.objid  = NULL_OBJID;

	ASget_as_owner(&mygrid, &owner);

	if ((owner.objid != NULL_OBJID) &&
		(located_obj->objid != my_id))
	{
		/*| assoc owner */

		printf(" ERROR:No owner should be present\n");
		*msg = MSFAIL;
		return(OM_W_ABORT);
	}


	if (located_obj->objid == my_id
	&&  located_obj->osnum == as_osnum)
	{
		as->objid = my_id;
		as->osnum = OM_Gw_current_OS;

		*msg = OM_S_SUCCESS;
		return(OM_S_SUCCESS);
	}

	ASmake_source_from_go(msg,located_obj,context,as_osnum,as); 

	return(OM_S_SUCCESS);
}

end implementation DMplan;

