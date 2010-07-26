/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:32 $
$Locker:  $
$Log: place.I,v $
Revision 1.1.1.1  2001/12/17 22:39:32  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:10:00  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.4  1996/12/31  07:24:28  skathiri
# COMMENT : Changes for RFA+Assembly
#
# Revision 330.3  1996/10/18  08:40:27  skathiri
# COMMENT : Changes for RFA, part of house keeping chores
#
# Revision 330.1  1996/03/27  13:08:48  skathiri
# COMMENT : Changes for Reference File activation
#
# Revision 330.0  1996/01/11  21:24:08  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:53:31  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.10  1994/09/23  11:31:22  gvk
# COMMENT : Cannot use toggle term icon on the form to switch terminators during dynamics.
#
# Revision 400.3  1994/05/16  04:47:55  gvk
# COMMENT : Correct function call to get the environ parameters.
#
# Revision 400.2  1994/05/13  08:23:04  gvk
# COMMENT : Purify fixes
#
# Revision 240.9  1993/11/03  15:23:06  gvk
# COMMENT : Modified for the support of value type in text_with_leader macro.
#
# Revision 240.8  1993/10/13  05:16:14  samuel
# COMMENT : Added macros for stringed linear and stringed angular dims
#
# Revision 240.7  1993/08/03  11:26:12  laxmi
# COMMENT : taken care of the warnings during complation -Laxmi. 3 aug 1993
#
# Revision 240.6  1993/08/03  05:42:38  laxmi
# COMMENT : Dimensioning 2.4 CR and TR fixes checkin. -Laxmi
#
# Revision 240.4  1993/04/07  10:12:04  rishad
# COMMENT : Incorporated enhancements to placement interface.
#
# Revision 220.2  1992/10/16  19:36:28  poo
# COMMENT : Created a new macro to place balloon annotation.
#
Revision 201.28  1992/09/18  09:29:06  poo
COMMENT : Fix for modify on Leader line (AutoDimensions).

Revision 201.24  1992/02/17  20:29:38  bill
COMMENT : Initialized txt_string to NULL so it wouldn't be mistakenly deallocated.

Revision 201.23  1992/02/14  15:26:47  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - 14 Feb. '92

*/

class implementation DMroot;

#define AS_DEBUG 1

#include "msdef.h"
#include "exmacros.h"
#include "gr.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dpmacros.h"
#include "exdef.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "dimdef.h"
#include "dim.h"
#include "dimlinear.h"
#include "dimradial.h"
#include "dimdyn.h"
#include "dimmod.h"
#include "diminst.h"
#include "dimco.h"
#include "dimsrc.h"
#include "dimplcmacros.h"
#include "dimannot.h"
#include "DMmsg.h"

#include "maidmx.h"
#include "madef.h"
#include "actparam.h"

static IGRboolean aflag;
static GRspacenum osn;


from DMplan_mgr import create_dim_plane;
from DMplan import give_parents;

extern GRclassid OPP_dim_plan_class_id,
		 OPP_DMplan_class_id,
		 OPP_DMtxldr_class_id,
		 OPP_DMcoordj_class_id;

extern double fabs();

IGRint DMplace_dim (dim_type,
			  geom_type,
			  orig_grid,
			  orig_pt,
			  orig_count,
			  orig_type,
			  meas_grid,
			  meas_pt,
			  meas_count,
			  meas_type,
			  plane_grid,
			  plane_matrix,
			  brk_pos,
			  brk_dist,
			  leader,
			  lead_dist,
			  trak_dist,
			  mea_trak,
			  mask,
			  dynamics,
			  owner,
			  dim_grid)
IGRint dim_type;
IGRint geom_type;
struct GRid *orig_grid;
IGRdouble orig_pt[3];
IGRint orig_count;
IGRint orig_type;
struct GRid *meas_grid;
IGRdouble meas_pt[3];
IGRint meas_count;
IGRint meas_type;
struct GRid *plane_grid;
IGRmatrix plane_matrix;
IGRint brk_pos;
IGRdouble brk_dist;
IGRint leader;
IGRdouble lead_dist;
IGRdouble trak_dist;
IGRint mea_trak;
IGRint mask;
IGRboolean dynamics;
struct GRid *owner;
struct GRid *dim_grid;
{
	IGRint status, rc, index;
	IGRint orig_index, meas_index, num_parents;
	IGRlong long_rc, chan_index;
	IGRchar classname[20];
	IGRshort meas_needed;
	struct GRid list[MAX_DIM_ROOTS], context[MAX_DIM_ROOTS];
	struct GRid src_list[11], src_context[11]; 
	struct dim_attr dmattr;
	struct GRmd_env md_env, dyn_env;
	struct DMenv_param par_env;
	struct DMmisc_param par_misc;
	struct GRas assoc_lis;
	IGRdouble axis_attr[5];
	IGRdouble attr[10];
	IGRint i;
	struct GRid plan_mgr, null_id;

	/*| Get module info */

    aflag = pwIsActivationOn();
    if (aflag)
    {
      pwGetActiveModuleEnv(&md_env);
      pwGetActiveModuleEnv(&dyn_env);
      MAidmx(&long_rc, md_env.md_env.matrix);
      md_env.md_env.matrix_type = MAIDMX;
      MAidmx(&long_rc, dyn_env.md_env.matrix);
      dyn_env.md_env.matrix_type = MAIDMX;
    }
    else
    {
	status = DMget_module_info(&md_env);
	dm$status(action = RET_STATUS);


	status = DMget_module_info(&dyn_env);
	dm$status(action = RET_STATUS);
    }

	dyn_env.md_id.objid = NULL_OBJID;

/* dummy initialisationm of meas_index in order to avoid compilation
warning*/
	meas_index = DIM_CPX_MEAS;
	switch(dim_type)
	{
		case STACKED_LINEAR:
		case STRINGED_LINEAR:
		strcpy(classname, "DMlincpx");
		num_parents = NO_CPX_DIM_ROOTS;
		orig_index = DIM_CPX_ORIG;
		meas_index = DIM_CPX_MEAS;
		meas_needed = TRUE;
		break;

		case STACKED_ANGULAR:
		case STRINGED_ANGULAR:
		strcpy(classname, "DMangular");
		num_parents = NO_CPX_DIM_ROOTS;
		orig_index = DIM_CPX_ORIG;
		meas_index = DIM_CPX_MEAS;
		meas_needed = TRUE;
		break;

		case SINGLE_PARALLEL:
		strcpy(classname, "DMsglpara");
		num_parents = NO_SGPAR_DIM_ROOTS;
		orig_index = DIM_SGPAR_LINE;
		meas_needed = FALSE;
		break;

		case RADIAL:
		strcpy(classname, "DMradjog");
		num_parents = NO_RAD_DIM_ROOTS;
		orig_index = DIM_RAD_CURVE;
		meas_needed = FALSE;
		break;

		case RADIAL_DIAMETER:
		strcpy(classname, "DMradjog");
		num_parents = NO_RAD_DIM_ROOTS;
		orig_index = DIM_RAD_CURVE;
		meas_needed = FALSE;
		break;

		case COORDINATE:
		strcpy( classname, "DMcoordj" );
		num_parents = NO_CPX_DIM_ROOTS;
		orig_index = DIM_CPX_ORIG;
		meas_index = DIM_CPX_MEAS;
		if( DMancestry_valid(*orig_grid, OPP_DMcoordj_class_id) )
		{
		  num_parents = NO_CPX_DIM_ROOTS; /* Measurement Dim */
		  meas_needed = TRUE;
		}
		else
		{
		  num_parents = NO_CPX_DIM_ROOTS - 1; /* Origin Dim */
		  meas_needed = FALSE;
		}
		break;

		case LINEAR_DIAMETER:
		strcpy(classname, "DMlindia");
		num_parents = NO_LDIA_DIM_ROOTS;
		orig_index = DIM_LDIA_ORIG;
		meas_index = DIM_LDIA_MEAS;
		meas_needed = TRUE;
		break;

		case CIRCULAR_DIAMETER:
		strcpy(classname, "DMcirdia");
		num_parents = NO_CDIA_DIM_ROOTS;
		orig_index = DIM_CDIA_CURVE;
		meas_needed = FALSE;
		break;

		case SINGLE_ARC_LENGTH:
		case SINGLE_ARC_ANGLE:
		strcpy(classname, "DMsglarc");
		num_parents = NO_SGPAR_DIM_ROOTS;
		orig_index = DIM_CPX_ORIG;
		meas_needed = FALSE;
		break;

		default:
		printf("DMplace_dim : wrong dim_type %d\n",dim_type);
		return(OM_E_ABORT);
	}

	for (index=0; index<num_parents; index++)
	{
		list[index].objid = NULL_OBJID;
		list[index].osnum = md_env.md_id.osnum;
		context[index].objid = NULL_OBJID;
		context[index].osnum = md_env.md_id.osnum;
	}

	/*| Get dimension parameters and plane */

	status = dm$get_dim_param(type = DM_ENV_PARAM,
			p_grid = &list[DIM_ROOT_ENV],
			p_data = (char *)&par_env);
	dm$status(action = RET_STATUS);


	status = dm$get_dim_param(type = DM_LOC_PARAM,
			p_grid = &list[DIM_ROOT_LOC]);
	dm$status(action = RET_STATUS);

    aflag = pwIsActivationOn();
    if (aflag)
    {
      osn = pwGetActiveOs();
      list[DIM_ROOT_ENV].osnum = osn;
      list[DIM_ROOT_LOC].osnum = osn;
    }

	null_id.objid = NULL_OBJID;

	if( plane_matrix)
	{

		status = DMget_plan_mgr(&plan_mgr);
		dm$status(action = RET_STATUS);

		/*^ print_matrix("win_matrix",plane_matrix); */

		status =
		om$send(msg = message DMplan_mgr.create_dim_plane(
							&rc,
							null_id,
							plane_matrix,
							0,
							NULL,
							&md_env,
							&list[DIM_ROOT_PLAN]),
			senderid = NULL_OBJID,
			targetid = plan_mgr.objid,
			targetos = plan_mgr.osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		/*^ printf("plane_grid : %d, %d\n",plane_grid->objid, plane_grid->osnum);*/

		if (DMancestry_valid(*plane_grid, OPP_dim_plan_class_id))
		{
			/*|- Plane already a dim_plan object */

			list[DIM_ROOT_PLAN].objid = plane_grid->objid;
			list[DIM_ROOT_PLAN].osnum = plane_grid->osnum;
		}
		else
		{
			status = dm$get_dim_plane(
				win_grid = *plane_grid,
				md_env = (struct GRmd_env *) &md_env,
				p_grid = &list[DIM_ROOT_PLAN]);
			dm$status(action = RET_STATUS);
		}
	}

	
	if( orig_type != -1 &&
	    orig_count > 0 )	/* DMsrc type */
	 {
	   if( !is_valid_type( dim_type, orig_type ) )
	   {
	    printf( "DMsrc type for origin element is not valid\n" );
	    return(FALSE);
	   }

	   for( i=0; i < orig_count; i++ )
	    {
	      src_list[i].objid = orig_grid[i].objid;
	      src_list[i].osnum = orig_grid[i].osnum;

	      src_context[i].objid = NULL_OBJID;
	      src_context[i].osnum = orig_grid[i].osnum;

              status =
              GRfindcontext(
                        &rc,
                        &md_env.md_env.matrix_type,
                        md_env.md_env.matrix,
                        &orig_grid[i].osnum,
                        &src_context[i]); 
              if(status != OM_S_SUCCESS || rc != MSSUCC)
                src_context[i].objid = NULL_OBJID;
	    }


	   src_list[orig_count].objid = list[DIM_ROOT_PLAN].objid;
	   src_list[orig_count].osnum = list[DIM_ROOT_PLAN].osnum;

	   src_context[orig_count].objid = NULL_OBJID;
	   src_context[orig_count].osnum = md_env.md_id.osnum;

	   attr[0] = orig_pt[0];
	   attr[1] = orig_pt[1];
	   attr[2] = orig_pt[2];

	   status = dm$create_root(
			type = orig_type,
			count = orig_count+1,
			list = src_list,
			context = src_context,
			attr = attr,
			md_env = &md_env,
			p_root = &list[orig_index]);
	   dm$status(action = RET_STATUS);
	 }
	else /* conventional case */
	 {

	   if(mask < 0)
	   {
		list[orig_index].objid = orig_grid->objid;
		list[orig_index].osnum = orig_grid->osnum;
	   }
	   else
	   {
		/*| angular dimension relative to horizantal or vertical */

		axis_attr[0] = orig_pt[0];
		axis_attr[1] = orig_pt[1];
		axis_attr[2] = orig_pt[2];

		if( mask == ANG_DIM_HORIZANTAL)
			axis_attr[3] = ACT_X_AXIS;
		else	axis_attr[3] = ACT_Y_AXIS;

		src_list[0].objid = orig_grid->objid;
		src_list[0].osnum = orig_grid->osnum;

		src_list[1].objid = list[DIM_ROOT_PLAN].objid;
		src_list[1].osnum = list[DIM_ROOT_PLAN].osnum;

		src_context[0].objid = src_context[1].objid = NULL_OBJID;
		src_context[0].osnum = src_context[1].osnum = md_env.md_id.osnum;

		/*| create source object of type DMaxis */
		status =
		dm$create_root(
			type = DMaxis,
			count = 2,
			list = src_list,
			context = src_context,
			attr = axis_attr,
			md_env = &md_env,
			p_root = &list[orig_index]);
		dm$status(action = RET_STATUS);
	   }
	 }
	


	if( meas_needed)
	{
	     if( meas_type != -1 &&
	         meas_count > 0 )
	     {
		if( !is_valid_type( dim_type, meas_type ) )
		{
	         printf( "DMsrc type for measurement element is not valid\n" );
		 return(FALSE);
		}

		for (index=0; index < 2; index++)
		{
		  src_list[index].objid = NULL_OBJID;
		  src_list[index].osnum = md_env.md_id.osnum;
		  src_context[index].objid = NULL_OBJID;
		  src_context[index].osnum = md_env.md_id.osnum;
		}

	       for( i=0; i < meas_count; i++ )
	       {
	         src_list[i].objid = meas_grid[i].objid;
	         src_list[i].osnum = meas_grid[i].osnum;

	         src_context[i].objid = NULL_OBJID;
	         src_context[i].osnum = meas_grid[i].osnum;

                 status =
                 GRfindcontext(
                        &rc,
                        &md_env.md_env.matrix_type,
                        md_env.md_env.matrix,
                        &meas_grid[i].osnum,
                        &src_context[i]);
                 if(status != OM_S_SUCCESS || rc != MSSUCC)
                   src_context[i].objid = NULL_OBJID;
	       }

	       src_list[meas_count].objid = list[DIM_ROOT_PLAN].objid;
	       src_list[meas_count].osnum = list[DIM_ROOT_PLAN].osnum;

	       src_context[meas_count].objid = NULL_OBJID;
	       src_context[meas_count].osnum = md_env.md_id.osnum;

	       attr[0] = meas_pt[0];
	       attr[1] = meas_pt[1];
	       attr[2] = meas_pt[2];

	       status = dm$create_root(
			type = meas_type,
			count = meas_count+1,
			list = src_list,
			context = src_context,
			attr = attr,
			md_env = &md_env,
			p_root = &list[meas_index]);
	       dm$status(action = RET_STATUS);
	     }
	    else /* conventional case */
	     {
		list[DIM_CPX_MEAS].objid = meas_grid->objid;
		list[DIM_CPX_MEAS].osnum = meas_grid->osnum;
	     }
	}

/*		printf("dim_type = %d, geom_type = %d\n",dim_type,geom_type);
		printf("num_parents = %d, classname = %s\n",num_parents,classname);
		for(index=0; index<num_parents; index++)
		printf("list[%d] : %d, %d\n",index,list[index].objid,list[index].osnum);
		print_point(" orig_point",orig_pt);
		if(meas_needed)
		print_point(" meas_point",meas_pt);
		printf("trak_dist : %lf, mea_trak : %d\n",
					trak_dist, mea_trak); */

	if( (dim_type == RADIAL || dim_type == RADIAL_DIAMETER)
	&& fabs(trak_dist) < 0.005 )
		mea_trak = FALSE;

	dmattr.dim_type = dim_type;
	dmattr.brk_pos = brk_pos;
	dmattr.ter_loca = TER_LOCA_INTERNAL;
	dmattr.offs_pt[0] = 0.0;
	dmattr.offs_pt[1] = 0.0;
	dmattr.dim_state = DIM_NEEDS_UPDATE | DIM_IN_PLACEMENT;
	dmattr.geom_type = geom_type;
	dmattr.display = 0;
	dmattr.leader = leader;
	dmattr.brk_dist = brk_dist;
	dmattr.lead_dist = lead_dist;
	dmattr.mea_trak = mea_trak;


	if( dim_type != RADIAL_DIAMETER   &&
	    dim_type != CIRCULAR_DIAMETER &&
	    trak_dist < 0 )
	     dmattr.trak_dist = par_env.txt_heig * par_env.lin_offs_r;
	else dmattr.trak_dist = trak_dist;

	dmattr.orig[0] = orig_pt[0];
	dmattr.orig[1] = orig_pt[1];
	dmattr.orig[2] = orig_pt[2];

	if(meas_needed)
	{
		dmattr.meas[0] = meas_pt[0];
		dmattr.meas[1] = meas_pt[1];
		dmattr.meas[2] = meas_pt[2];
	}

	assoc_lis.parents = list;
	assoc_lis.num_parents = num_parents;
	assoc_lis.context = context;
	assoc_lis.as_attr = (char *)&dmattr;
	assoc_lis.go_attr = NULL;
	assoc_lis.go_objid.objid = NULL_OBJID;
	assoc_lis.my_context.objid = NULL_OBJID;
	assoc_lis.my_context.osnum = md_env.md_id.osnum;

	/*| construct dimension */

	dim_grid->osnum = md_env.md_id.osnum;

	status =
	om$construct(
		classname = classname,
		p_objid = &dim_grid->objid,
		osnum = dim_grid->osnum);
	dm$status(action = RET_STATUS);

/*^	printf("dim_grid : %d, %d\n",dim_grid->objid,dim_grid->osnum); */

	if(owner)
	{
		/*^ print_grid("Connect the owner :",owner); */

		chan_index = 0;
		long_rc = MSSUCC;

		status =
		om$send(msg = message GRconnector.GRrigidconn(
						&long_rc,
						owner,
						&chan_index),
			senderid = dim_grid->objid,
			targetid = dim_grid->objid,
			targetos = dim_grid->osnum);
		dm$status(action = RET_STATUS);
	}

	status =
	om$send(msg = message NDnode.NDplace(
					&assoc_lis,
					&dyn_env,
					NULL),
		senderid = NULL_OBJID,
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.NDs_compute_node(
						&long_rc,
						0,
						&dyn_env),
		senderid = NULL_OBJID,
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

        status =
        om$send(msg = message DMroot.set_dim_state(BIT_SET, 0),
                senderid = NULL_OBJID,
                targetid = dim_grid->objid,
                targetos = dim_grid->osnum);
        dm$status(action = RET_STATUS);

	dm$get_dim_param(type = DM_MISC_PARAM, p_data = (char *)&par_misc);

	status =
	om$send(msg = message DMroot.init_ter_loca(par_misc.ter_limit_r *
						   par_env.txt_heig),
		senderid = NULL_OBJID,
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	if(dynamics)
	{
		status =
		DMdimension_dynamics(*dim_grid);
		dm$status(action = RET_STATUS);
	}

        status =
        dm$change_node(
                as_grid = *dim_grid,
                md_env = &md_env,
                broadcast = FALSE);
        dm$status(action = RET_STATUS);

	/* If the current layer in environment form is set as active 
	   that needs to be translated to actual layer, so that if the 
	   active layer changes later the dimension would not update to
	   those layers.
	*/

	DMupdate_active_layer_info(&long_rc,dim_grid, &par_env);

	return(OM_S_SUCCESS);	
}

IGRint DMchange_plane (plane_grid,
		       dim_grid,
		       md_env)
		       /*(
	 struct GRid  *plane_grid,
	 struct GRid  *dim_grid,
	 struct GRmd_env  *md_env
	)
	*/
struct GRid *plane_grid;
struct GRid *dim_grid;
struct GRmd_env *md_env;
/*.DMchange_plane*/
{
	IGRint status, count;
	IGRlong long_rc;
	struct GRid new_plan;
	struct GRid list[MAX_DIM_ROOTS];

	/*^ print_grid("plane_grid",plane_grid); */
	/*^ print_grid("dim_grid",dim_grid); */

	/*|- Get the old_plan */

	status =
	om$send(msg = message DMroot.DMreturn_roots(&count, list),
		senderid = NULL_OBJID,
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	/*^ print_grid("old_plan",&list[DIM_ROOT_PLAN]); */

	/*| - Get the new_plan */

	if (DMancestry_valid(*plane_grid, OPP_DMplan_class_id))
	{
		/*|- Plane already a dim_plan object */

		new_plan.objid = plane_grid->objid;
		new_plan.osnum = plane_grid->osnum;
	}
	else
	{
		status = dm$get_dim_plane(
			win_grid = *plane_grid,
			md_env = (struct GRmd_env *) md_env,
			p_grid = &new_plan);
		dm$status(action = RET_STATUS);
	}

	/*^ print_grid("new_plan",&new_plan); */

	/*|- Change connect the dimension plane */

	status =
	om$send(msg = message ASnode.NDchange_connect(
						1,
						&list[DIM_ROOT_PLAN],
						&new_plan),
			mode = OM_e_wrt_message,
			senderid = NULL_OBJID,
			targetid = dim_grid->objid,
			targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message NDnode.NDs_compute_node(&long_rc, 0, md_env),
			senderid = NULL_OBJID,
			targetid = dim_grid->objid,
			targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	return(OM_S_SUCCESS);
}

IGRint DMdimension_dynamics (dim_grid)
         /*(
	 struct GRid  dim_grid
	)
	*/
struct GRid dim_grid;
/*.DMdimension_dynamics*/
{
	IGRint rc, response, status;
	IGRdouble response_data[(1024/sizeof(double))];
	IGRshort leader;
	struct GRid copy_dim;
	struct GRmd_env md_env, dyn_env;
	struct GRevent event;

	status = DMget_module_info(&md_env);
	dm$status(action = RET_STATUS);

	status = DMget_module_info(&dyn_env);
	dm$status(action = RET_STATUS);
	dyn_env.md_id.objid = NULL_OBJID;

	STATE_1:

	dm$invoke_dynamics(
		msg = &rc,
		msgkey = DM_P_PosDim,
		preproc = LEADER_OFF | CLEAR_OFFSET | MASK_STATE,
		prestate =  DIM_NEEDS_UPDATE,
		control = MOVE_TRAK_PT | MOVE_BREAK_PT,
		md_env = &dyn_env,
		copy = TRUE,
		cp_grid = &copy_dim,
		dim_grid = &dim_grid);

	status =
	co$getevent(
		msg = &rc,
		msgnum = DM_P_PosDim,
		response = &response,
		response_data = (char *)response_data,
		event_mask = (GRm_DATA | GRm_STRING | GRm_BACK_UP | GRm_RESET),
		event = &event);
	dm$status(action = RET_STATUS);

	switch(response)
	{
		case DATA:

		dm$invoke_dynamics(
			msg = &rc,
			dynamics = FALSE,
			postproc = CHGDP,
			control = MOVE_TRAK_PT | MOVE_BREAK_PT,
			md_env = &dyn_env,
			event = &event,
			dim_grid = &copy_dim);
		break;

		default:

		delete_copy(&copy_dim, &dyn_env);

		if (response == RESET || response == D_RESET)
			return(TRUE);
		else	goto STATE_1;
	}

	STATE_2:

	leader = FALSE;

	status =
	om$send(msg = message DMroot.leader_needed(
					&rc,
					&dyn_env,
					&leader),
		senderid = NULL_OBJID,
		targetid = copy_dim.objid,
		targetos = copy_dim.osnum);
	dm$status(action = RET_STATUS);

	if (leader)
	{
		dm$invoke_dynamics(
			msg = &rc,
			preproc = MASK_STATE,
			prestate = DIM_NEEDS_UPDATE,
			control = MOVE_LEADER_PT,
			md_env = &dyn_env,
			dim_grid = &copy_dim);

		status =
		co$getevent(
			msg = &rc,
			msgnum = DM_P_Enhotepo,
			response = &response,
			response_data = (char *)response_data,
			event_mask = (GRm_DATA | GRm_STRING | GRm_BACK_UP | GRm_RESET),
			event = &event);
		dm$status(action = RET_STATUS);

		switch(response)
		{
			case DATA:

			dm$invoke_dynamics(
				msg = &rc,
				dynamics = FALSE,
				postproc = CHGDP,
				control = MOVE_LEADER_PT,
				md_env = &dyn_env,
				event = &event,
				dim_grid = &copy_dim);
			break;

			case D_RESET:
			case RESET:

			delete_copy(&copy_dim, &dyn_env);

			if (response == RESET) return(TRUE);
			goto STATE_1;

			default:
			goto STATE_2;
		}
	}

	status =
	om$send(msg = message DMroot.copy_dim_attr(
					&rc,
					INST_OFFS_PT  | INST_TRAK_PT |
					INST_BREAK_PT | INST_LEADER_PT,
					&copy_dim,
					&md_env),
		senderid = NULL_OBJID,
		targetid = dim_grid.objid,
		targetos = dim_grid.osnum);
	dm$status(action = RET_STATUS);

	delete_copy(&copy_dim, &dyn_env);

	return(TRUE);
}

delete_copy (copy_dim,
	     md_env)
	     /*(
	 struct GRid  *copy_dim,
	 struct GRmd_env  *md_env
	)
	*/
struct GRid *copy_dim;
struct GRmd_env *md_env;
{
	IGRint msg;

	if (copy_dim->objid == NULL_OBJID) return(TRUE);

	DMdelete_dimension(&msg, TRUE, md_env, copy_dim);
	nd$exec_batch();

	copy_dim->objid = NULL_OBJID;
	return(TRUE);
}

IGRint DMset_type (type,
		   update,
		   op_code,
		   md_env,
		   dim_grid)
		   /*(
	 IGRint  type,
	 IGRboolean  update,
	 IGRint  op_code,
	 struct GRmd_env  *md_env,
	 struct GRid  *dim_grid
	)
	*/
IGRint type;
IGRboolean update;
IGRint op_code;
struct GRmd_env *md_env;
struct GRid *dim_grid;
/*DMset_type*/
{
        IGRint status;

	if ( update && !md_env)
	{
		printf("DMset_type : md_env is NULL\n");
		return(OM_E_ABORT);
	}

        if ( update && (md_env->md_id.objid == NULL_OBJID))
        {
                printf("DMset_type : Bad md_env cannot compute\n");
                return(OM_E_ABORT);
        }

        status =
        om$send(msg = message DMroot.set_geom_type(
                                        op_code,
                                        type,
                                        (update)?md_env:NULL),
                senderid = NULL_OBJID,
                targetid = dim_grid->objid,
                targetos = dim_grid->osnum);
        dm$status(action = RET_STATUS);

        return(OM_S_SUCCESS);
}

IGRint DMplace_annot (annot_type,
		      geom_type,
		      attach_ele1,
		      attach_ele2,
		      attach_pt1,
		      attach_pt2,
		      num_brkpt,brkpt,text_length,text_string,
		      expr_count,expr_list,plane_matrix,plane_grid,
		      owner,color,weight,dim_grid)
IGRint annot_type;
IGRint geom_type;
struct GRid *attach_ele1;
struct GRid *attach_ele2;
IGRdouble attach_pt1[3];
IGRdouble attach_pt2[3];
IGRint num_brkpt;
IGRdouble *brkpt;
IGRint text_length;
IGRchar *text_string;
IGRint expr_count;
struct GRid *expr_list;
IGRmatrix plane_matrix;
struct GRid *plane_grid;
struct GRid *owner;
IGRint color;
IGRint weight;
struct GRid *dim_grid;
{
int status ;

	status =
	DMplace_annot2(annot_type,
		      geom_type,
		      attach_ele1,
		      attach_ele2,
		      attach_pt1,
		      attach_pt2,
		      num_brkpt,brkpt,text_length,text_string,
		      expr_count,expr_list,plane_matrix,plane_grid,
		      owner,color,weight,dim_grid,0);
	return(status);
}

IGRint DMplace_annot2(annot_type,
		      geom_type,
		      attach_ele1,
		      attach_ele2,
		      attach_pt1,
		      attach_pt2,
		      num_brkpt,brkpt,text_length,text_string,
		      expr_count,expr_list,plane_matrix,plane_grid,
		      owner,color,weight,dim_grid,value_type)
		      /*(
	 IGRint  annot_type,
	 IGRint  geom_type,
	 struct GRid  *attach_ele1,
	 struct GRid  *attach_ele2,
	 IGRdouble  attach_pt1[3],
	 IGRdouble  attach_pt2[3],
	 IGRint  num_brkpt,
	 IGRdouble  *brkpt,
	 IGRint  text_length,
	 IGRchar  *text_string,
	 IGRint  expr_count,
	 struct GRid  *expr_list,
	 IGRmatrix  plane_matrix,
	 struct GRid  *plane_grid,
	 struct GRid  *owner,
	 IGRint  color,
	 IGRint  weight,
	 struct GRid  *dim_grid
	 IGRint value_type;
	)
	*/
IGRint annot_type;
IGRint geom_type;
struct GRid *attach_ele1;
struct GRid *attach_ele2;
IGRdouble attach_pt1[3];
IGRdouble attach_pt2[3];
IGRint num_brkpt;
IGRdouble *brkpt;
IGRint text_length;
IGRchar *text_string;
IGRint expr_count;
struct GRid *expr_list;
IGRmatrix plane_matrix;
struct GRid *plane_grid;
struct GRid *owner;
IGRint color;
IGRint weight;
struct GRid *dim_grid;
IGRint value_type;
/*.DMplace_annot*/
{
        IGRint status, rc, index;
        IGRshort txt_length = 0,loc_len;
        IGRchar *txt_string = NULL;
        IGRint num_parents;
        IGRlong long_rc, chan_index;
        struct GRid list[MAX_DIM_ROOTS], context[MAX_DIM_ROOTS];
        struct annot_attr an_attr;
        struct GRmd_env md_env;
        struct GRas assoc_lis;
        struct GRid plan_mgr, null_id, go_grid;
        IGRchar classname[20];
        struct GTattr gtattr;
        struct DMsenv_param par_senv;

        /*| Get module info */
        aflag = pwIsActivationOn();
        if (aflag)
        {
           pwGetActiveModuleEnv(&md_env);
           MAidmx(&long_rc,md_env.md_env.matrix);
           md_env.md_env.matrix_type = MAIDMX;
        }
        else
        {
        status = DMget_module_info(&md_env);
        dm$status(action = RET_STATUS);
        }

        for (index=0; index<MAX_DIM_ROOTS; index++)
        {
                list[index].objid = NULL_OBJID;
                list[index].osnum = md_env.md_id.osnum;
                context[index].objid = NULL_OBJID;
                context[index].osnum = md_env.md_id.osnum;
        }

        /*| Get dimension parameter */

        status =
        dm$get_dim_param(type = DM_SENV_PARAM,
                        p_grid = &list[DIM_ROOT_SENV],
                        p_data = (char *)&par_senv);
        dm$status(action = RET_STATUS);

        if (annot_type != LEADER_LINE)
        {
                txt_length = text_length;
                txt_string = (char *)om$malloc(size = sizeof(IGRchar) * 1024);
                if (txt_string == NULL)
                {
                        printf("DMplace_annot: malloc failed\n");
                        return(OM_E_ABORT);
                }
        }

        switch(annot_type)
        {
                case TEXT_WITH_LEADER:
                strcpy(classname, "DMtxldr");
                num_parents = NO_TEXT_LEADER_ROOTS;
                memcpy(txt_string, text_string, txt_length);
                break;

                case DATUM_FRAME:
                strcpy(classname, "DMframe");
                num_parents = NO_TEXT_LEADER_ROOTS;

                loc_len = 0;
                gtattr.text_font = par_senv.text_font;
                gtattr.active_font= 0;
                gtattr.sep_symbol = 'l';
                DMadd_seperator((IGRuchar *) txt_string,&loc_len,&gtattr);
                memcpy(&txt_string[loc_len], text_string, txt_length);
                loc_len += txt_length;
                DMadd_seperator((IGRuchar *) txt_string,&loc_len,&gtattr);
                txt_length = loc_len;
                txt_string[txt_length]= '\0';
                status=
                DMconv_txldr_text(&txt_length, &txt_string);
                dm$status(action = RET_STATUS);

                break;

                case LEADER_LINE:
                strcpy(classname, "DMleader");
                num_parents = NO_LEADER_ROOTS;
                break;

                case TEXT_WITH_BALLOON:
                strcpy(classname, "DMtxbln");
                num_parents = NO_TEXT_LEADER_ROOTS;
                memcpy(txt_string, text_string, txt_length);
                break;

                default:
                printf("DMplace_annot : wrong annot_type %d\n",annot_type);
                return(OM_E_ABORT);
        }

        /*| Get dimension plane */

        null_id.objid = NULL_OBJID;

        if( plane_matrix)
        {
                status = DMget_plan_mgr(&plan_mgr);
                dm$status(action = RET_STATUS);

                /*^ print_matrix("win_matrix",plane_matrix); */

                status =
                om$send(msg = message DMplan_mgr.create_dim_plane(
                                                        &rc,
                                                        null_id,
                                                        plane_matrix,
                                                        0,
                                                        NULL,
                                                        &md_env,
                                                        &list[DIM_ROOT_PLAN]),
                        senderid = NULL_OBJID,
                        targetid = plan_mgr.objid,
                        targetos = plan_mgr.osnum);
                dm$status(action = RET_STATUS);
        }
        else
        {
                /*^ printf("plane_grid : %d, %d\n",plane_grid->objid, plane_grid->osnum);*/

                if (DMancestry_valid(*plane_grid, OPP_dim_plan_class_id))
                {
                        /*|- Plane already a dim_plan object */

                        list[DIM_ROOT_PLAN].objid = plane_grid->objid;
                        list[DIM_ROOT_PLAN].osnum = plane_grid->osnum;
                }
                else
                {
                        status = dm$get_dim_plane(
                                win_grid = *plane_grid,
                                md_env = (struct GRmd_env *) &md_env,
                                p_grid = &list[DIM_ROOT_PLAN]);
                        dm$status(action = RET_STATUS);
                }
        }

        /*^
                printf("txt_length = %d\n",txt_length);
                analyse_string(txt_string, txt_length);
        */

        an_attr.dim_type    = annot_type;
        an_attr.geom_type   = geom_type;
        an_attr.display     = 0;
        an_attr.dim_state   = DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
        an_attr.leader      = (num_brkpt == 0)? FALSE:TRUE;
        an_attr.text_length = txt_length;
        an_attr.text_string = (IGRuchar *)txt_string;
        an_attr.num_brkpt   = num_brkpt;
        an_attr.dual_mode   = 0;
        an_attr.brkpt       = brkpt;
        an_attr.tol_symbol  = 0;
        an_attr.bln_dir     = 0; 

	if (annot_type == LEADER_LINE)
	   an_attr.leader = TRUE;

        for(index = 0; index <3; index++)       
        an_attr.start_pt[index] = attach_pt1[index];

        if (DMancestry_valid(*attach_ele1, OPP_DMtxldr_class_id))
        {
                status =
                om$send(msg = message DMroot.return_dim_go(
                                                &rc,
                                                DIM_TEXT,
                                                FALSE,
                                                DM_TEXT,
                                                &md_env,
                                                &go_grid),
                        senderid = NULL_OBJID,
                        targetid = attach_ele1->objid,
                        targetos = attach_ele1->osnum);
                dm$status(action = RET_STATUS);

                list[AN_ROOT_ELEM1] = go_grid;
        }
        else    list[AN_ROOT_ELEM1] = *attach_ele1;

        for (index=0; index<expr_count; index++)
            list[AN_ROOT_ELEM2+index] = expr_list[index];
        num_parents = num_parents + expr_count;

        if (attach_ele2)
        {
                list[AN_ROOT_ELEM2] = *attach_ele2;
                for(index = 0; index <3; index++)       
                an_attr.end_pt[index] = attach_pt2[index];
        }

        assoc_lis.parents = list;
        assoc_lis.num_parents = num_parents;
        assoc_lis.context = context;
        assoc_lis.as_attr = (char *)&an_attr;
        assoc_lis.go_attr = NULL;
        assoc_lis.go_objid.objid = NULL_OBJID;
        assoc_lis.my_context.objid = NULL_OBJID;
        assoc_lis.my_context.osnum = md_env.md_id.osnum;

        /*| construct dimension */

        dim_grid->osnum = md_env.md_id.osnum;
        status =
        om$construct(
                classname = classname,
                p_objid = &dim_grid->objid,
                osnum = dim_grid->osnum);
        dm$status(action = RET_STATUS);

        /*^ printf("dim_grid : %d, %d\n",dim_grid->objid,dim_grid->osnum); */

        if(owner)
        {
                /*|- connect owner to myself */

                chan_index = 0;

                status =
                om$send(msg = message GRconnector.GRrigidconn(
                                                &long_rc,
                                                owner,
                                                &chan_index),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(action = RET_STATUS);
        }

        status =
        om$send(msg = message NDnode.NDplace(
                                        &assoc_lis,
                                        &md_env,
                                        NULL),
                senderid = NULL_OBJID,
                targetid = dim_grid->objid,
                targetos = dim_grid->osnum);
        dm$status(action = RET_STATUS);

        /*"color = %d, weight = %d\n",color, weight*/

        if (( color != -1) || (weight != -1) || value_type >0)
        {
                /*|- edit the senv_param and post the correct values */

                status =
                dm$get_dim_param(
                        type = DM_SENV_PARAM,
                        dim_objid = dim_grid->objid,
                        dim_osnum = dim_grid->osnum,
                        p_data = (char *)&par_senv);
                dm$status(action = RET_STATUS);

                if (color != -1) par_senv.dim_colr = color;
                if (weight != -1) par_senv.dim_weig = weight;
                par_senv.value_type = value_type;

                /*| Set dim to state EDIT */

                status =
                om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_EDIT),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(action = RET_STATUS);

                /*| Put environment */

                status =
                dm$put_dim_param(
                        type = DM_SENV_PARAM,
                        dim_objid = dim_grid->objid,
                        dim_osnum = dim_grid->osnum,
                        p_data = (char *)&par_senv);
                dm$status(action = RET_STATUS);

                /*| Clear EDIT state */

                status =
                om$send(msg = message DMroot.set_dim_state(BIT_XOR, DIM_IN_EDIT),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(action = RET_STATUS);
        }

        status =
        dm$change_node(
                as_grid = *dim_grid,
                md_env = &md_env,
                broadcast = FALSE);
        dm$status(action = RET_STATUS);

	/* If the current layer in environment form is set as active 
	   that needs to be translated to actual layer, so that if the 
	   active layer changes later the dimension would not update to
	   those layers. -gvk
	*/

	{
	  struct DMenv_param par_env;

	  DMsplit_senv(&par_senv,&par_env,NULL,NULL);
	  DMupdate_active_layer_info(&long_rc,dim_grid, &par_env);
	}

        status =
        om$send(msg = message DMroot.set_dim_state(BIT_SET, 0),
                senderid = NULL_OBJID,
                targetid = dim_grid->objid,
                targetos = dim_grid->osnum);
        dm$status(action = RET_STATUS);

        if (txt_string) om$dealloc(ptr = txt_string);

        return(OM_S_SUCCESS);
}

IGRint DMdmplan_set_axis (win_grid,dim_grid,list,count,point,md_env)
/*(
	 struct GRid  *win_grid,
	 struct GRid  *dim_grid,
	 struct GRid  *list,
	 IGRint  count,
	 IGRdouble  *point,
	 struct GRmd_env  *md_env
	)
	*/
struct GRid *win_grid;
struct GRid *dim_grid;
struct GRid *list;
IGRint count;
IGRdouble *point;
struct GRmd_env *md_env;
/*.DMdmplan_set_axis*/
{
        IGRint status,rc, num;
        IGRlong long_rc;
        struct GRid parents[MAX_DIM_ROOTS], clist[MAX_DIM_ROOTS];
        struct GRid context[MAX_DIM_ROOTS];
        struct GRid null_grid, plan;

        if(win_grid)
        {
                if (DMancestry_valid(*win_grid, OPP_dim_plan_class_id))
                {
                        /*|- Plane already a dim_plan object */

                        plan.objid = win_grid->objid;
                        plan.osnum = win_grid->osnum;
                }
                else
                {
                        status = dm$get_dim_plane(
                                win_grid = *win_grid,
                                md_env = md_env,
                                p_grid = &plan);
                        dm$status(action = RET_STATUS);
                }
        }
        else
        {
                status =
                om$send(msg = message DMroot.DMreturn_roots(&num, clist),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(action = RET_STATUS);

                plan = clist[DIM_ROOT_PLAN];
        }

        /*^
	{
		int i;
                print_grid("dim_plane",&plan);
                printf("count = %d\n",count);

                for( i=0; i<count; i++)
                printf("list[%d] = %d, %d",i, list[i].objid, list[i].osnum);
	}
        */

        if (count == 2)
        {
                status =
                GRfindcontext(
                        &rc,
                        &md_env->md_env.matrix_type,
                        md_env->md_env.matrix,
                        &md_env->md_id.osnum,
                        &context[0]);
                if (status != OM_S_SUCCESS || rc != MSSUCC)
                        context[0].objid = NULL_OBJID;

                context[1] = context[0];

                status =
                dm$create_root(
                        type = DMkeypt,
                        count = 1,
                        list = &list[0],
                        context = &context[0],
                        attr = point,
                        md_env = md_env,
                        p_root = &parents[0]);
                dm$status(action = RET_STATUS);

                status =
                dm$create_root(
                        type = DMkeypt,
                        count = 1,
                        list = &list[1],
                        context = &context[1],
                        attr = &point[3],
                        md_env = md_env,
                        p_root = &parents[1]);
                dm$status(action = RET_STATUS);
        }
        else
        {
                status =
                GRfindcontext(
                        &rc,
                        &md_env->md_env.matrix_type,
                        md_env->md_env.matrix,
                        &md_env->md_id.osnum,
                        &context[0]);
                if (status != OM_S_SUCCESS || rc != MSSUCC)
                        context[0].objid = NULL_OBJID;

                status =
                dm$create_root(
                        type = DMkeyseg,
                        count = 1,
                        list = &list[0],
                        context = &context[0],
                        attr = point,
                        md_env = md_env,
                        p_root = &parents[0]);
                dm$status(action = RET_STATUS);
        }

        null_grid.objid = NULL_OBJID;

        status =
        om$send(msg = message NDnode.NDdisconnect(
                                0,
                                clist),
                senderid = NULL_OBJID,
                targetid = plan.objid,
                targetos = plan.osnum);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message NDnode.NDconnect(
                                count,
                                parents,
                                null_grid,
                                ND_NEW),
                senderid = NULL_OBJID,
                targetid = plan.objid,
                targetos = plan.osnum);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message NDnode.NDs_compute_node(
                                                &long_rc,
                                                0,
                                                md_env),
                senderid = NULL_OBJID,
                targetid = plan.objid,
                targetos = plan.osnum);
        dm$status(action = RET_STATUS);

        return(OM_S_SUCCESS);
}

IGRint DMplace_cenline (go_grid,point,position,plane_matrix,plane_grid,dim_grid)
/*(
	 struct GRid  *go_grid,
	 IGRdouble  *point,
	 IGRboolean  position,
	 IGRdouble  *plane_matrix,
	 struct GRid  *plane_grid,
	 struct GRid  *dim_grid
	)
	*/
struct GRid *go_grid;
IGRdouble *point;
IGRboolean position;
IGRdouble *plane_matrix;
struct GRid *plane_grid;
struct GRid *dim_grid;
/*.DMplace_cenline*/
{
        IGRint status, rc, index;
        struct GRid list[MAX_DIM_ROOTS], context[MAX_DIM_ROOTS];
        struct cenline_attr cen_attr;
        struct GRmd_env md_env, dyn_env;
        struct GRas assoc_lis;
        struct GRid plan_mgr, null_id;

        /*| Get module info */

        status = DMget_module_info(&md_env);
        dm$status(action = RET_STATUS);

	memcpy (&dyn_env, &md_env, sizeof (struct GRmd_env));
	dyn_env.md_id.objid = NULL_OBJID;

        for (index=0; index<MAX_DIM_ROOTS; index++)
        {
                list[index].objid = NULL_OBJID;
                list[index].osnum = md_env.md_id.osnum;
                context[index].objid = NULL_OBJID;
                context[index].osnum = md_env.md_id.osnum;
        }

        /*| Get dimension parameters and plane */

        status = dm$get_dim_param(type = DM_SENV_PARAM,
                        p_grid = &list[DIM_ROOT_SENV]);
        dm$status(action = RET_STATUS);

        null_id.objid = NULL_OBJID;

        if( plane_matrix)
        {
                status = DMget_plan_mgr(&plan_mgr);
                dm$status(action = RET_STATUS);

                /*^ print_matrix("win_matrix",plane_matrix); */

                status =
                om$send(msg = message DMplan_mgr.create_dim_plane(
                                                        &rc,
                                                        null_id,
                                                        plane_matrix,
                                                        0,
                                                        NULL,
                                                        &md_env,
                                                        &list[DIM_ROOT_PLAN]),
                        senderid = NULL_OBJID,
                        targetid = plan_mgr.objid,
                        targetos = plan_mgr.osnum);
                dm$status(action = RET_STATUS);
        }
        else
        {
                /*^ printf("plane_grid : %d, %d\n",plane_grid->objid, plane_grid->osnum);*/

                if (DMancestry_valid(*plane_grid, OPP_dim_plan_class_id))
                {
                        /*|- Plane already a dim_plan object */

                        list[DIM_ROOT_PLAN].objid = plane_grid->objid;
                        list[DIM_ROOT_PLAN].osnum = plane_grid->osnum;
                }
                else
                {
                        status = dm$get_dim_plane(
                                win_grid = *plane_grid,
                                md_env = (struct GRmd_env *) &md_env,
                                p_grid = &list[DIM_ROOT_PLAN]);
                        dm$status(action = RET_STATUS);
                }
        }

        cen_attr.gap_r = 0.5;
        cen_attr.minor_len_r = 1.0;
        cen_attr.major_len_r = 1.5;
        cen_attr.dim_type = CENTER_LINE;
        cen_attr.dim_state = DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
        cen_attr.posn = position;

        for(index = 0; index <3; index++)       
        cen_attr.pnt_meas[index] = point[index];

        list[DIM_CEN_CURVE] = *go_grid;

        assoc_lis.parents = list;
        assoc_lis.num_parents = NO_CEN_DIM_ROOTS;
        assoc_lis.context = context;
        assoc_lis.as_attr = (char *)&cen_attr;
        assoc_lis.go_attr = NULL;
        assoc_lis.go_objid.objid = NULL_OBJID;
        assoc_lis.my_context.objid = NULL_OBJID;
        assoc_lis.my_context.osnum = md_env.md_id.osnum;

        /*| construct dimension */

        dim_grid->osnum = md_env.md_id.osnum;
        status =
        om$construct(
                classname = "DMcenline",
                p_objid = &dim_grid->objid,
                osnum = dim_grid->osnum);
        dm$status(action = RET_STATUS);

        /*^ printf("dim_grid : %d, %d\n",dim_grid->objid,dim_grid->osnum); */

        status =
        om$send(msg = message NDnode.NDplace(
                                        &assoc_lis,
                                        &dyn_env,
                                        NULL),
                senderid = NULL_OBJID,
                targetid = dim_grid->objid,
                targetos = dim_grid->osnum);
        dm$status(action = RET_STATUS);

        status =
        dm$change_node(
                as_grid = *dim_grid,
                md_env = &md_env,
                broadcast = FALSE);
        dm$status(action = RET_STATUS);

        status =
        om$send(msg = message DMroot.set_dim_state(BIT_SET, 0),
                senderid = NULL_OBJID,
                targetid = dim_grid->objid,
                targetos = dim_grid->osnum);
        dm$status(action = RET_STATUS);

        return(OM_S_SUCCESS);
}

DMenclose_dimtext (set1_clear0,dim_grid,md_env)
/*(
	 IGRboolean  set1_clear0,
	 struct GRid  *dim_grid,
	 struct GRmd_env  *md_env
	)
	*/
IGRboolean set1_clear0; 
struct GRid *dim_grid;
struct GRmd_env *md_env;
/*.DMenclose_dimtext*/
{
        IGRint status;
        struct DMloc_param par_loc;

        status =
        dm$get_dim_param(
                type = DM_LOC_PARAM,
                dim_objid = dim_grid->objid,
                dim_osnum = dim_grid->osnum,
                p_data = (char *)&par_loc);
        dm$status(action = RET_STATUS);

        if (set1_clear0)
        {
                /*|- Enclose The dim text*/

                if (par_loc.tole_mode < 100)
                        par_loc.tole_mode += 100;
                else    return(OM_S_SUCCESS); /*text already in enclose mode*/

                /*|- set dim_state to edit mode & text needs compute*/

                /*| Set dim to state EDIT */

                status =
                om$send(msg = message DMroot.set_dim_state(
                                        BIT_OR,
                                        DIM_IN_EDIT|DIM_TEXT_NEEDS_UPDATE),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(action = RET_STATUS);

                /*|- Put this dim param and send a compute*/

                dm$put_dim_param(
                        type = DM_LOC_PARAM,
                        dim_objid = dim_grid->objid,
                        dim_osnum = dim_grid->osnum,
                        p_data = (char *)&par_loc);
                dm$status(action = RET_STATUS);

                /*| Clear EDIT state */

                status =
                om$send(msg = message DMroot.set_dim_state(BIT_XOR, DIM_IN_EDIT),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(action = RET_STATUS);

                status =
                dm$change_node(
                        as_grid = *dim_grid,
                        md_env = md_env,
                        broadcast = FALSE);
                dm$status(action = RET_STATUS);
        }
        else
        {
                /*|- clear the dim text*/

                if (par_loc.tole_mode > 99)
                        par_loc.tole_mode -= 100;
                else    return(OM_S_SUCCESS); /*text already cleared*/

                /*|- set dim_state to edit mode & text needs compute*/

                status =
                om$send(msg = message DMroot.set_dim_state(
                                        BIT_OR,
                                        DIM_IN_EDIT|DIM_TEXT_NEEDS_UPDATE),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(action = RET_STATUS);

                /*|- Put this dim param and send a compute*/

                dm$put_dim_param(
                        type = DM_LOC_PARAM,
                        dim_objid = dim_grid->objid,
                        dim_osnum = dim_grid->osnum,
                        p_data = (char *)&par_loc);
                dm$status(action = RET_STATUS);

                /*| Clear EDIT state */

                status =
                om$send(msg = message DMroot.set_dim_state(BIT_XOR, DIM_IN_EDIT),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(action = RET_STATUS);

                status =
                dm$change_node(
                        as_grid = *dim_grid,
                        md_env = md_env,
                        broadcast = FALSE);
                dm$status(action = RET_STATUS);
        }

        return(OM_S_SUCCESS);
}

IGRint DMdisplay_dim (mode,invisible_display,md_env,dim_grid)
/*(
	 enum GRdpmode  mode,
	 IGRboolean  invisible_display,
	 struct GRmd_env  *md_env,
	 struct GRid  *dim_grid
	)
	*/
enum GRdpmode mode;
IGRboolean invisible_display;
struct GRmd_env *md_env;
struct GRid *dim_grid;
/*DMdisplay_dim*/
{
	IGRint status;
	extern IGRboolean display_invisible_dims;

	if (invisible_display)
		display_invisible_dims = TRUE;

	status =
	om$send(msg = message NDnode.NDdisplay(
					0,
					mode,
					md_env),
		senderid = NULL_OBJID,
		targetid = dim_grid->objid,
		targetos = dim_grid->osnum);
	dm$status(action = RET_STATUS);

	display_invisible_dims = FALSE;

	return(OM_S_SUCCESS);
}

IGRint DMchange_ref_plane(
	inq0_chg1,
	ref_grid,
	plan_grid,
	md_env)
/*
(
IGRboolean   inq0_chg1;
struct GRid  *ref_grid,
	     *plan_grid;
struct GRmd_env  *md_env
)
*/
IGRboolean   inq0_chg1;
struct GRid  *ref_grid,*plan_grid;
struct GRmd_env  *md_env;
/*.DMchange_ref_plane*/
{
	IGRint status, count;
	IGRlong long_rc;
	struct GRid list[3];

	/*^ print_grid("plan_grid",plan_grid); */

	/*|- Get the old_ref */

	status =
	om$send(msg = message DMplan.give_parents(&count, list),
		senderid = NULL_OBJID,
		targetid = plan_grid->objid,
		targetos = plan_grid->osnum);
	dm$status(action = RET_STATUS);

	if (count > 0)
	{
		if (DMancestry_valid(list[0], OPP_dim_plan_class_id))
		{
			/*^ print_grid("old_ref",&list[0]); */

			if (!inq0_chg1)
			{
				ref_grid->objid = list[0].objid;
				ref_grid->osnum = list[0].osnum;
				return(OM_S_SUCCESS);
			}
		}
		else
		{
			if (!inq0_chg1)
			   ref_grid->objid = NULL_OBJID;

			return(OM_S_SUCCESS);
		}

		if (ref_grid->objid != NULL_OBJID)
		{
			/*|- Change connect the dimension plane */
	
			status =
			om$send(msg = message ASnode.NDchange_connect(
							1,
							&list[0],
							ref_grid),
				mode = OM_e_wrt_message,
				senderid = NULL_OBJID,
				targetid = plan_grid->objid,
				targetos = plan_grid->osnum);
			dm$status(action = RET_STATUS);

			status =
			om$send(msg = message NDnode.NDs_compute_node(&long_rc, 0, md_env),
				senderid = NULL_OBJID,
				targetid = plan_grid->objid,
				targetos = plan_grid->osnum);
			dm$status(action = RET_STATUS);
		}
	}
	else
	{
		if (!inq0_chg1) ref_grid->objid = NULL_OBJID;
	}

	return(OM_S_SUCCESS);
}


int is_valid_type( dim_type, dmsrc_type )
IGRint dim_type;
IGRint dmsrc_type;
{
 IGRint status;

 status = FALSE;
 if( dmsrc_type == -1 )
  return( TRUE );

 switch( dim_type )
 {
  case STACKED_LINEAR:
  case STRINGED_LINEAR:
  case LINEAR_DIAMETER:
  case COORDINATE:
   if( dmsrc_type == DMkeypt ||
       dmsrc_type == DMtanpt ||
       dmsrc_type == DMintpt ||
       dmsrc_type == DMmidpt ||
       dmsrc_type == DMcenpt ||
       dmsrc_type == DMedgept )
    status = TRUE;

   break;


  case SINGLE_PARALLEL:
   if( dmsrc_type == DMkeyseg ||
       dmsrc_type == DMedgeseg )
    status = TRUE;

   break;


  case RADIAL:
  case CIRCULAR_DIAMETER:
  case RADIAL_DIAMETER:
   if( dmsrc_type == DMradcen )
    status = TRUE;

   break;


  case SINGLE_ARC_LENGTH:
  case SINGLE_ARC_ANGLE:
  if( dmsrc_type == DMarc )
   status = TRUE;

  break;
 }

 return( status );
}

IGRint DMplace_dimension (dim_type,
			  geom_type,
			  orig_grid,
			  orig_pt,
			  meas_grid,
			  meas_pt,
			  plane_grid,
			  plane_matrix,
			  brk_pos,
			  brk_dist,
			  leader,
			  lead_dist,
			  trak_dist,
			  mea_trak,
			  mask,
			  dynamics,
			  owner,
			  dim_grid)
IGRint dim_type;
IGRint geom_type;
struct GRid *orig_grid;
IGRdouble orig_pt[3];
struct GRid *meas_grid;
IGRdouble meas_pt[3];
struct GRid *plane_grid;
IGRmatrix plane_matrix;
IGRint brk_pos;
IGRdouble brk_dist;
IGRint leader;
IGRdouble lead_dist;
IGRdouble trak_dist;
IGRint mea_trak;
IGRint mask;
IGRboolean dynamics;
struct GRid *owner;
struct GRid *dim_grid;
{
  DMplace_dim(	dim_type,
		geom_type,
	 	orig_grid,
		orig_pt,
		1,
		-1,
		meas_grid,
		meas_pt,
		1,
		-1,
		plane_grid,
		plane_matrix,
		brk_pos,
		brk_dist,
		leader,
		lead_dist,
		trak_dist,
		mea_trak,
		mask,
		dynamics,
		owner,
		dim_grid);
  return(TRUE);
}
end implementation DMroot;

