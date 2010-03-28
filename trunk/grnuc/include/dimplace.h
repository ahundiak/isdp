#ifndef dm_place_include

#define dm_place_include

#define STACKED_LINEAR          0
#define STRING_LINEAR           1
#define LINEAR_DIAMETER         2
#define SYMMETRICAL_DIAMETER    3
#define CIRCULAR_DIAMETER       4
#define SINGLE_PARALLEL         5
#define STACKED_ANGULAR         6
#define STRING_ANGULAR          7
#define RADIAL_RADIUS           8
#define RADIAL_DIAMETER         9

#define HORIZONTAL		0
#define VERTICAL		1

#omdef dm$place_linear_dimension(
                type,
                ori_ele,
                ori_pt,
                mea_ele=NULL_OBJID,
                mea_pt=NULL,
                view="top",
                axis=HORIZONTAL,
                break_pt,
                leader_pt)

#if om$equal(type, STACKED_LINEAR) || om$equal(type, STRING_LINEAR) || om$equal(type, LINEAR_DIAMETER)

#if (!om$specified(mea_ele) || !om$specified(mea_pt))
#omerror "Must specify both 'mea_ele' and 'mea_pt'"
#endif

        place_linear_dimension(
                type,
                ori_ele,
                ori_pt,
                mea_ele,
                mea_pt,
                view,
                axis,
                break_pt,
                leader_pt)
#endif

#if om$equal(type, SINGLE_PARALLEL)

        place_single_parallel(
                type,
                ori_ele,
                ori_pt,
                view,
                break_pt,
                leader_pt)

#endif

#if om$equal(type, CIRCULAR_DIAMETER)

        place_circular_diameter(
                type,
                ori_ele,
                ori_pt,
                view,
                axis_dir,
                break_pt,
                leader_pt)

#endif

#endomdef

#omdef dm$place_angular_dimension(
                type,
                ori_ele,
                ori_pt,
                mea_ele,
                mea_pt,
                view="top",
                sel_pt,
                break_pt,
                leader_pt)

        place_angular_dimension(
                type,
                ori_ele,
                ori_pt,
                mea_ele,
                mea_pt,
                view,
                sel_pt,
                break_pt,
                leader_pt)

#endomdef

#omdef dm$place_radial_dimension(
                type,
                mea_ele,
                mea_pt,
                view="top",
                break_pt,
                leader_pt)

        place_radial_dimension(
                type,
                mea_ele,
                mea_pt,
                view,
                break_pt,
                leader_pt)

#endomdef

#omdef dm$add_measurement_to_group(
                type,
                dim_id,
                mea_ele,
                mea_pt,
                break_pt,
                leader_pt)

        add_measurement_to_group(
                type,
                dim_id,
                mea_ele,
                mea_pt,
                break_pt,
                leader_pt)

#endomdef

#omdef dm$set_param(par)

        begincmd("dm");
        ci$put(string = par);
        endcmd()

#endomdef

#omdef dm$set_axis(view = "top", obj, point)

        set_meas_axis(view, obj, point)

#endomdef

#omdef dm$get_dim_id(dim_id)

        get_dim_id(dim_id)

#endomdef

#include "cieveryone.h"
#include "exmacros.h"
#include "cievent.h"
#include "cilocate.h"
#include "cisend.h"
#include "ciexec.h"

#include "msdef.h"
#include "msmacros.h"

#include "godef.h"
#include "go.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "DMmessages.h"
#include "dimplan.h"
#include "dimmacros.h"


char   buff[128];
extern int DMget_dim_plane();
extern int DMcreate_dmplan();
extern int DMget_plan_info();

extern int ASget_active_symb();
extern int DPgetggid();
extern int printf();
extern int MAidmx();
extern int MSmessage();
extern int GRdpb_get();
extern int GRdpb_put();


#define error_check(sts, comment) \
        if (!(sts & 1)) \
                printf("sts=%d, Error %s\n", sts, comment);

get_window_id(view, win_grid)
char *view;
struct GRid *win_grid;
{
        int sts, msg;
        int one;

        sts =
        dp$get_gragad_id(
                msg = &msg,
                name = view,
                array_size = 1,
                numberofids = &one,
                found_GRids = win_grid);
        return(sts);
}

get_sel_pt(win_grid, pt, md_env, axis_dir, sel_pt)
struct GRid win_grid;
double *pt;
struct GRmd_env *md_env;
int axis_dir;
double *sel_pt;
{
        int sts, msg;
	IGRdouble *axis;
        struct GRid dim_plan;
	struct DMplan_info plan_info;

	sts = DMget_dim_plane(win_grid, md_env, &dim_plan);
        error_check(sts, "DMget_dim_plane\n");

	sts =
	dm$get_plan_info(
		plan_objid = dim_plan.objid,
		osnum = dim_plan.osnum,
		md_env = md_env,
		plan_info = &plan_info);
        error_check(sts, "dm$get_plan_info\n");

	if (axis_dir)
		axis = plan_info.act_plan.vec_xpos;
	else	axis = plan_info.act_plan.vec_ypos;

        sel_pt[0] = pt[0] + axis[0];
        sel_pt[1] = pt[1] + axis[1];
        sel_pt[2] = pt[2] + axis[2];

        return(TRUE);
}

set_meas_axis(view, obj, point)
char *view;
GRobj obj;
double *point;
{
        IGRint sts, msg;
        struct GRid win_grid, grid, ctx, plan;
	struct GRmd_env md_env;

        sts = get_window_id(view, &win_grid);
        error_check(sts, "Unknown view\n");

	ci$get_module_info(md_env = &md_env);
	grid.objid = obj;
	grid.osnum = md_env.md_id.osnum;
	ctx.objid = NULL_OBJID;

	sts = DMcreate_dmplan( &msg, win_grid, 1, &grid, &ctx,
				point, &md_env, &plan);
        error_check(sts, "create dmplan\n");

	return(TRUE);
}

place_linear_dimension(
        type,
        obj1,
        p1,
        obj2,
        p2,
        view,
        axis_dir,
        break_pt,
        leader_pt)
int type;
GRobj obj1;
double *p1;
GRobj obj2;
double *p2;
char *view;
int axis_dir;
double *break_pt;
double *leader_pt;
{
        IGRint sts, msg;
        struct GRmd_env md_env;
        struct GRid win_grid;
        int index;
        IGRpoint sel_pt;
        IGRdouble dummy_par;
        int byte;
        int msgnumb;

        ci$get_module_info(md_env = &md_env);

        sts = get_window_id(view, &win_grid);
        error_check(sts, "Unknown view\n");

        sts = get_sel_pt(win_grid, p2, &md_env, axis_dir, sel_pt);
        error_check(sts, "Error getting select point\n");

        switch (type)
        {
                case STACKED_LINEAR: msgnumb = DMC_M_DMLnStc; break;
                case STRING_LINEAR:  msgnumb = DMC_M_DMLnStr; break;
                case LINEAR_DIAMETER: msgnumb = DMC_M_DMLnDia; break;
                case SYMMETRICAL_DIAMETER: msgnumb = DMC_M_DMSmDia; break;
                default: printf("place_linear_dimension: Error in type %d\n", type);
                         return(FALSE);
        }

        ex$message(msgnumb = msgnumb, buff = buff);

        byte = FALSE;
        set_dyn_flag(&byte);

        begincmd(buff);
        ci$put(	obj = obj1,
		data_point = p1,
		window_id = win_grid.objid);
        ci$put(	obj = obj2,
		data_point = p2,
		window_id = win_grid.objid);
        ci$put(point = sel_pt);
        ci$put(point = break_pt);
        ci$put(point = leader_pt);
        ci$put(response = TERMINATE);
        endcmd();

        set_dyn_flag(&byte);
}

place_circular_diameter(
        type,
        obj1,
        p1,
        view,
        axis_dir,
        break_pt,
        leader_pt)
int type;
GRobj obj1;
double *p1;
char *view;
int axis_dir;
double *break_pt;
double *leader_pt;
{
        IGRint sts, msg;
        struct GRmd_env md_env;
        struct GRid win_grid;
        int index;
        IGRpoint sel_pt;
        IGRdouble dummy_par;
        int byte;

        ci$get_module_info(md_env = &md_env);

        sts = get_window_id(view, &win_grid);
        error_check(sts, "Unknown view\n");

        sts = get_sel_pt(win_grid, p1, &md_env, axis_dir, sel_pt);
        error_check(sts, "Error getting select point\n");

        ex$message(msgnumb = DMC_M_DMCrDia, buff = buff);

        byte = FALSE;
        set_dyn_flag(&byte);

        begincmd(buff);
        ci$put( obj = obj1,
		data_point = p1,
		window_id = win_grid.objid);
        ci$put(point = sel_pt);
        ci$put(point = break_pt);
        ci$put(point = leader_pt);
        ci$put(response = TERMINATE);
        endcmd();

        set_dyn_flag(&byte);
}

place_radial_dimension(
        type,
        obj1,
        p1,
        view,
        break_pt,
        leader_pt)
int type;
GRobj obj1;
double *p1;
char *view;
double *break_pt;
double *leader_pt;
{
        IGRint sts, msg;
        struct GRid win_grid;
        int byte;
        int msgnumb;

        sts = get_window_id(view, &win_grid);
        error_check(sts, "Unknown view\n");

        switch (type)
        {
                case RADIAL_RADIUS: msgnumb = DMC_M_DMRd; break;
                case RADIAL_DIAMETER:  msgnumb = DMC_M_DMRdDia; break;
                default: printf("place_radial_dimension: Invalid type %d\n", type);
                         return(FALSE);
        }

        ex$message(msgnumb = msgnumb, buff = buff);

        byte = FALSE;
        set_dyn_flag(&byte);

        begincmd(buff);
        ci$put( obj = obj1,
		data_point = p1,
		window_id = win_grid.objid);
        ci$put(point = break_pt);
        ci$put(point = leader_pt);
        ci$put(response = TERMINATE);
        endcmd();

        set_dyn_flag(&byte);
}

place_angular_dimension(
        type,
        obj1,
        p1,
        obj2,
        p2,
        view,
        sel_pt,
        break_pt,
        leader_pt)
int type;
GRobj obj1;
double *p1;
GRobj obj2;
double *p2;
char *view;
double *sel_pt;
double *break_pt;
double *leader_pt;
{
        IGRint sts, msg;
        struct GRid win_grid;
        int index;
        IGRdouble dummy_par;
        int byte;
        int msgnumb;

        sts = get_window_id(view, &win_grid);
        error_check(sts, "Unknown view\n");

        switch (type)
        {
                case STACKED_ANGULAR: msgnumb = DMC_M_DMAnStc; break;
                case STRING_ANGULAR: msgnumb = DMC_M_DMAnStr; break;
                default: printf("place_angular: Invalid type %d\n", type);
                         return(FALSE);
        }

        ex$message(msgnumb = msgnumb, buff = buff);

        byte = FALSE;
        set_dyn_flag(&byte);

        begincmd(buff);
        ci$put(	obj = obj1,
		data_point = p1,
		window_id = win_grid.objid);
        ci$put(	obj = obj2,
		data_point = p2,
		window_id = win_grid.objid);
        ci$put(point = sel_pt);
        ci$put(point = break_pt);
        ci$put(point = leader_pt);
        ci$put(response = TERMINATE);
        endcmd();

        set_dyn_flag(&byte);
}

place_single_parallel(
        type,
        obj1,
        p1,
        view,
        break_pt,
        leader_pt)
int type;
GRobj obj1;
double *p1;
char *view;
double *break_pt;
double *leader_pt;
{
        IGRint sts, msg;
        struct GRid win_grid;
        int byte;

        sts = get_window_id(view, &win_grid);
        error_check(sts, "Unknown view\n");

        ex$message(msgnumb = DMC_M_DMLnPar, buff = buff);

        byte = FALSE;
        set_dyn_flag(&byte);

        begincmd(buff);
        ci$put(	obj = obj1,
		data_point = p1,
		window_id = win_grid.objid);
        ci$put(point = break_pt);
        ci$put(point = leader_pt);
        ci$put(response = TERMINATE);
        endcmd();

        set_dyn_flag(&byte);
}

add_measurement_to_group(type, obj1, obj2, p2, break_pt, leader_pt)
int type;
GRobj obj1;
GRobj obj2;
double *p2;
double *break_pt;
double *leader_pt;
{
        IGRint sts, msg;
        int response;
        struct GRid win_grid;
        int index;
        IGRpoint sel_pt;
        IGRdouble dummy_par;
        int byte;
        int msgnumb;

	msgnumb = DMC_M_DMAdMsTGr;
        ex$message(msgnumb = msgnumb, buff = buff);

        byte = FALSE;
        set_dyn_flag(&byte);

        begincmd(buff);
        ci$put(obj = obj1);
        ci$put(obj = obj2, data_point = p2);
        ci$put(point = break_pt);
        ci$put(point = leader_pt);
        ci$put(response = TERMINATE);
        endcmd();

        set_dyn_flag(&byte);
}

get_dim_id(dim_id)
GRobj *dim_id;
{
        readrtree(dim_id, 1, 1);
        return(TRUE);
}

set_dyn_flag(flag)
int *flag;
{
        int msg, sizbuf, dynflag, nret;

        sizbuf = sizeof(int);

        gr$get_dynamics_on(
                msg = &msg,
                sizbuf = &sizbuf,
                buffer = &dynflag,
                nret = &nret);

        gr$put_dynamics_on(
                msg = &msg,
                sizbuf = &sizbuf,
                buffer = flag);

        *flag = dynflag;
}

#endif
