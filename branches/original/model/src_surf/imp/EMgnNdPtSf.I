/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
HISTORY:
Creation	Before recorded history....
08/19/92   NP	The "node_pts" parameter had been  mistakenly declared as 
		"IGRint **" instead of "IGRdouble **". Also moved static 
		declaration of "generate_uniform_knots" up to the entire file
		scope. ANSI compiled.


*/


#include "EMS.h"
#include "msdef.h"
#include "EMSopt.h" /* For EMS_VAL_PLANAR */ 
#include "gocmacros.h" /* GRgetabsg */
#define U_KNOTS_BUFF 10
#define V_KNOTS_BUFF 10

extern OMuword OPP_EMSgenbs_class_id;
static IGRint generate_uniform_knots();

method EMgenerate_node_pt_surf (IGRlong *EMmsg; 
                                struct GRmd_env *env;
                                IGRint u_insert;
                                IGRint v_insert;
                                IGRushort options; 
                                struct GRvg_construct *construct_list;
                                OM_S_OBJID *newobjid;
                                IGRint *numu;
                                IGRdouble **u_vals;
                                IGRint *numv;
                                IGRdouble **v_vals;
                                IGRint *pts_num;
                                IGRdouble **weights;
                                IGRdouble **node_pts)
/* **********************************************************************
Description
 This message generates a node point surface of an input surface. The
 node points are characteristic points following the shape of the surface
 and need not lie on the surface.

Arguments
 num_u : I : num values to be inserted in u.
 num_v : I : num values to be inserted in v.
 options   : currently unused.
 construct_list : construction information

Notes
 Upon exit the completion code will be one of the following:
 EMS_S_Success : If all goes well.
 EMS_E_Fail : If there is failure
 EMS_E_BSerror : If there is a math error

Output
 EMmsg : Completion code. 
 newobjid : The objid representing the node point surface.

************************************************************************* */
 
{
 IGRlong status,loc_msg;
 IGRchar *ptr;
 struct IGRbsp_surface *surf,new_surf;
 IGRint i,unum,vnum,num_pts;
 IGRint max_u_vals, max_v_vals, max_node_pts;
 IGRdouble *u_vals_ptr = NULL, *v_vals_ptr = NULL, *node_pts_ptr = NULL,
           *weights_ptr = NULL;
 IGRdouble *u_knots_ptr = NULL, *v_knots_ptr = NULL;
 IGRdouble u_knots_buff[U_KNOTS_BUFF], v_knots_buff[V_KNOTS_BUFF];
 OMuword spacenum;
 extern void BSsfnodpts();
 extern void EF_ck_bs_props();
 extern void EFget_sf_nod_pts();

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 *u_vals = NULL;
 *v_vals = NULL;
 *node_pts = NULL;
 *weights = NULL;
 *newobjid = NULL_OBJID;
 
 new_surf.poles = new_surf.weights = new_surf.u_knots = 
 new_surf.v_knots = NULL;

 GRgetabsg(&loc_msg,&env->md_env.matrix_type, env->md_env.matrix, &ptr,i);
 EMerr_hndlr(!(1&loc_msg), *EMmsg, EMS_E_Fail, wrapup);

 surf = (struct IGRbsp_surface *) ptr;

 max_u_vals = (surf->u_num_poles - 1) * (u_insert + 1) + 1;
 max_v_vals = (surf->v_num_poles - 1) * (v_insert + 1) + 1;
 max_node_pts = max_u_vals * max_v_vals;
 
 u_vals_ptr = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) *
                            max_u_vals);
 EMerr_hndlr(!u_vals_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 v_vals_ptr = (IGRdouble *) om$malloc(size = sizeof (IGRdouble) *
                            max_v_vals);
 EMerr_hndlr(!v_vals_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 node_pts_ptr = (IGRdouble *) om$malloc(size = sizeof (IGRdouble) *
                                        (max_node_pts * 3));
 EMerr_hndlr(!node_pts_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 if (surf->rational)
 {
   weights_ptr = (IGRdouble *) om$malloc(size = sizeof (IGRdouble) *
                                        max_node_pts);
   EMerr_hndlr(!weights_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }

 EFget_sf_nod_pts(&loc_msg,surf,u_insert,v_insert,&unum, &vnum, u_vals_ptr,
                  v_vals_ptr,&num_pts,weights_ptr,
                  node_pts_ptr);
 EMerr_hndlr(!(1&loc_msg), *EMmsg, EMS_E_Fail, wrapup);

 if ((unum * vnum) != num_pts)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 if ((unum + 2) > U_KNOTS_BUFF)
 {
  u_knots_ptr = (IGRdouble *) om$malloc(size = sizeof (IGRdouble) * (unum + 2));
  EMerr_hndlr(!u_knots_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
  u_knots_ptr = u_knots_buff;

 if ((vnum + 2) > V_KNOTS_BUFF)
 {
  v_knots_ptr = (IGRdouble *) om$malloc(size = sizeof (IGRdouble) * (vnum + 2));
  EMerr_hndlr(!v_knots_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }
 else
  v_knots_ptr = v_knots_buff;


 new_surf.u_order = 2;
 new_surf.v_order = 2;

 generate_uniform_knots(new_surf.u_order,unum,u_knots_ptr);
 generate_uniform_knots(new_surf.v_order,vnum,v_knots_ptr);

 new_surf.u_num_poles = unum;
 new_surf.v_num_poles = vnum;
 new_surf.u_num_knots = unum + 2;
 new_surf.v_num_knots = vnum + 2;
 new_surf.u_periodic = FALSE;
 new_surf.rational = FALSE;
 new_surf.u_non_uniform = FALSE;
 new_surf.v_non_uniform = FALSE;
 new_surf.poles = node_pts_ptr;
 new_surf.u_knots = u_knots_ptr;
 new_surf.v_knots = v_knots_ptr;
 new_surf.planar = FALSE;
 new_surf.u_phy_closed = FALSE;
 new_surf.v_phy_closed = FALSE;
 new_surf.num_boundaries = 0;
 new_surf.bdrys = NULL;

 EFck_sf_bs_props (&loc_msg, &new_surf,(EMS_VAL_PLANAR | EMS_VAL_PHY_CLSD));
 EMerr_hndlr(!(1&loc_msg), *EMmsg, EMS_E_Fail, wrapup);

 construct_list->newflag = FALSE;
 construct_list->geometry = (IGRchar *)&new_surf;

 spacenum = construct_list->env_info->md_id.osnum;

 status = om$construct (p_objid = newobjid,
                        classid = OPP_EMSgenbs_class_id,
                        osnum = construct_list->env_info->md_id.osnum,
                        msg = message GRvg.GRconstruct(construct_list));
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 if (u_vals)  *u_vals = u_vals_ptr;
 if (v_vals)  *v_vals = v_vals_ptr;
 if (node_pts) *node_pts = node_pts_ptr;
 if (weights) *weights = weights_ptr;
 if (numu) *numu = unum;
 if (numv) *numv = vnum;
 if (pts_num) *pts_num = num_pts;

wrapup:
 if (!(1&status&*EMmsg) && (*newobjid != NULL_OBJID))
 {
  IGRlong cln_sts;

  cln_sts = om$send (msg = message Root.delete(1),
                     targetid = *newobjid,
                     targetos = spacenum);
 }
 if (!u_vals && u_vals_ptr) om$dealloc(ptr = u_vals_ptr);
 if (!v_vals && v_vals_ptr) om$dealloc(ptr = v_vals_ptr);
 if (!node_pts && node_pts_ptr) om$dealloc(ptr = node_pts_ptr);
 if (!weights && weights_ptr) om$dealloc(ptr = weights_ptr);
 return (status);
}

static IGRint generate_uniform_knots(order,num_poles,knots)
IGRint order;
IGRint num_poles;
IGRdouble *knots;
{
  IGRint i;
  IGRdouble knot_increment,
            knot,num_knots;

  num_knots = num_poles + 2;

  for (i=0 ; i < 2; i++)
   knots[i] = 0.0;

  knot_increment = 1.0 / (num_poles - 1);
  knot = 0.0;

  for (i = 2; i < num_poles; i++)
  {
    knot += knot_increment;
    knots[i] = knot;
  }

  for (i = num_poles ; i < num_knots; i++)
   knots[i] = 1.0;
  return (1);
}
end implementation EMSsubbs;

