#ifndef dimmacros_include

#define dimmacros_include

#include "dim.h"
#include "dimsrc.h"
#include "dimplan.h"
#include "parametric.h"


#define math_v_equal(to, from) \
{ \
	to[0] = from[0]; \
	to[1] = from[1]; \
	to[2] = from[2]; \
}

#define math_ln_equal(to, from) \
{ \
	to[0] = from[0]; \
	to[1] = from[1]; \
	to[2] = from[2]; \
	to[3] = from[3]; \
	to[4] = from[4]; \
	to[5] = from[5]; \
}

#define math_v_opposite(to, from) \
{ \
	to[0] = -from[0]; \
	to[1] = -from[1]; \
	to[2] = -from[2]; \
}

#define vec_equal(v1,v2) \
{ \
	(v2)[0] = (v1)[0] ; \
	(v2)[1] = (v1)[1] ; \
	(v2)[2] = (v1)[2] ; \
}

#define vec_scale(v,s,V) \
{ \
	(V)[0]=(v)[0]*(s); \
	(V)[1]=(v)[1]*(s); \
	(V)[2]=(v)[2]*(s); \
}

#define math_v_scale(v,s) \
{ \
	long ret_code; \
	BSnorvec(&ret_code, v); \
	(v)[0] *= (s); \
	(v)[1] *= (s); \
	(v)[2] *= (s); \
}

#define math_v_offset(xaxis, yaxis, basept, newpt, xoffset, yoffset) \
{ \
	xoffset = (xaxis[0] * (newpt[0] - basept[0]) + \
		   xaxis[1] * (newpt[1] - basept[1]) + \
		   xaxis[2] * (newpt[2] - basept[2])); \
\
	yoffset = (yaxis[0] * (newpt[0] - basept[0]) + \
		   yaxis[1] * (newpt[1] - basept[1]) + \
		   yaxis[2] * (newpt[2] - basept[2])); \
}

#define vec_neg(v,V) \
{ \
	(V)[0]= -(v)[0] ; \
	(V)[1]= -(v)[1] ; \
	(V)[2]= -(v)[2] ; \
}

#define vec_add(v1,v2,V) \
{\
	(V)[0]=(v1)[0]+(v2)[0]; \
	(V)[1]=(v1)[1]+(v2)[1]; \
	(V)[2]=(v1)[2]+(v2)[2]; \
}

#define vec_sub(v1,v2,V) \
{ \
	(V)[0]= (v1)[0] - (v2)[0]; \
	(V)[1]= (v1)[1] - (v2)[1]; \
	(V)[2]= (v1)[2] - (v2)[2]; \
}
#define vec_cross(v1,v2,V) \
{ \
	(V)[0]= (v1)[1]*(v2)[2] - (v1)[2]*(v2)[1] ; \
	(V)[1]= (v1)[2]*(v2)[0] - (v1)[0]*(v2)[2] ; \
	(V)[2]= (v1)[0]*(v2)[1] - (v1)[1]*(v2)[0] ; \
}

#define vec_dot(v1,v2) ( (v1)[0]*(v2)[0] + (v1)[1]*(v2)[1] + (v1)[2]*(v2)[2] )
#define vec_len(v) sqrt( (v)[0]*(v)[0] + (v)[1]*(v)[1] + (v)[2]*(v)[2] )

#define DIM_PLACE	0
#define DIM_EDIT	1

#omdef dm$get_dim_param(
		type,
		dim_objid = NULL_OBJID,
		dim_osnum = 0,
		p_grid = NULL,
		p_data = NULL)

#if !om$specified(p_grid) && !om$specified(p_data)
#omerror "must specify atleast one of 'p_grid' and 'p_data'"
#endif

	DMget_dim_param(type, dim_objid, dim_osnum, p_grid, p_data)

#endomdef

#omdef dm$get_dim_plane(win_grid, md_env, p_grid)

	DMget_dim_plane(win_grid, md_env, p_grid)

#endomdef

#omdef dm$put_dim_param(
		type,
		dim_objid = NULL_OBJID,
		dim_osnum = 0,
		p_grid = NULL,
		p_data)

	DMput_dim_param(type, dim_objid, dim_osnum, p_grid, p_data)

#endomdef

#omdef dm$get_param_info(
		type,
		size=NULL,
		index=NULL)

	DMget_param_info(type, size, index)

#endomdef

#omdef dm$change_node(
	broadcast = TRUE,
	exec_batch = FALSE,
	as_grid,
	md_env)

	DMchange_node(
		broadcast,
		exec_batch,
		as_grid,
		md_env)
#endomdef

/*--------------------- dm$pass_message --------------

	This macro passes the message "msg" to the
	all the dimensions in the specified "target".

	The target can be:

	PASS_BY_OSNUM	-	All dimensions in the
				specified object space (osnum).

	PASS_TO_CUROS	-	All dimensions in the
				current object space.

	PASS_TO_REFOS	-	All dimensions in all
				the attached reference
				files.

	The module environment object, if specified, is
	filled with that of the object space in consideration
`	before sending the message. The way to use this
	parameter (md_env) is to use it as on of the parameters
	in the message specified so that it automatically gets
	updated before sending.

	Arguments:

	OM_p_MESSAGE 	msg	Message to passed to
				target dimensions.

	IGRint		target	PASS_BY_OSNUM
				PASS_TO_CUROS
				PASS_TO_REFOS (dimgraph.h)

	struct GRmd_env *md_env	Module environment to be
				filled by the object space
				context info before sending
				the message.

	OMuword		osnum	Object space to pass message
				to if target is PASS_BY_OSNUM.

	IGRboolean	all_contexts	Send to all the contexts
					of a reference file?

--------------------------------------------------------------*/

#omdef dm$pass_message(
	msg,
	target = PASS_TO_CUROS,
	md_env = NULL,
	osnum = NULL,
	all_contexts = FALSE)

	DMpass_message(msg, target, osnum, md_env, all_contexts)

#endomdef


#omdef dm$get_super(
	md_os = OM_Gw_current_OS,
	md_id = NULL_OBJID,
	create = TRUE,
	p_grid)

	DMget_super(md_os, md_id, create, p_grid)

#endomdef

#omdef dm$get_cur_super(p_grid)

	DMget_cur_super(p_grid)

#endomdef

/* ------------- dm$get_plan_info -----------------------

	Description:

	Returns the dimension plane info given either the
	dimension objid or the plane objid.

	Arguments;

	OM_S_OBJID dim_objid	(I)	Dimension object id
	OM_S_OBJID plan_objid	(I)	Plan object id
	OMuword osnum		(I)	Object space number
	struct GRmd_env *md_env	(I)	Module environment
	struct DMplan_info *plan_info (O) Plan info

--------------------------------------------------------------*/

#omdef dm$get_plan_info(
		dim_objid = NULL_OBJID ^ plan_objid = NULL_OBJID,
		osnum,
		md_env,
		win_matrix = (struct GRmd_env *)NULL ^ 
                plan_info = (struct DMplan_info *)NULL)

	DMget_plan_info(
		dim_objid,
		plan_objid,
		osnum,
		md_env,
		win_matrix,
		plan_info)

#endomdef

#endif


