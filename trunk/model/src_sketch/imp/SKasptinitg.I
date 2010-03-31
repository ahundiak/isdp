/*

Name
  SKinit_assocpt_ground

Abstract

Synopsis

Description
    This constraint will create one grounded vg-point for the associative
    object. The associative object is a subclass of NDnode and responds
    correctly to the message NDgive_structure. Using the point_index argument
    this method decides the point in the associative object to ground.
    Currently, only the following types are supported:

    point_generic	- point_inx is irrelevant
    line_generic	- point_inx indicates START or STOP point.
    arc_type		- point_inx indicates START, CENTRE or STOP point.
    circle_type		- point_inx indicates CENTRE or circumf point.
    curve_generic       - point_inx indicates the START or STOP point.
    
    The input associative object is connected as a parent of this
    ground constraint.

Return Value

Notes

Index

Keywords

History
  07/02/93 : Sudha : Modified for BSprototypes ansification
  10/26/93 : GMK   : TR#119303786 : The circumference point for circle is at
                               3'O clock position not at geometric end point.
  11/15/93 : GMK   : TR#119312096 : finding the circumference point for circle 
  12/14/93 : Satya : added code to handle a bspline curve. (TR#119313612).
  01/21/94 : Rajiv Agrawal : Added a call to SKsavestate to that undo information
             is stored correctly.  (TR119415612)
 */

class implementation SKasptgrnd;

#include "OMmacros.h"
#include "parametric.h"
#include "bserr.h"
#include "bsconic.h"
#include "ma.h"
#include "maarendpt.h"
#include "maoptsxfo.h"
#include "matypemx.h"


#define FIRST  0
#define SECOND 1
#define THIRD  2

from SKmgr import SKconnect_to_ptvar, SKsavestate;
from SKvariable import SKputvar;

extern GRclassid OPP_SKptvar_class_id;

method SKinit_assocpt_ground (IGRlong *msg; IGRushort options;
                              struct GRmd_env *md_env;
                              struct GRid *assoc_src; IGRint point_inx;
                              GRobjid mgrobj;
                              IGRchar *moreinfo;
                              GRobjid *vgpt)
{
  IGRushort 		propsmask;
  IGRshort 		matrix_type;
  IGRint		kk,j;
  IGRlong 		msg_loc, stat_OM,num;
  IGRdouble 		*point, *dptr;
  IGRdouble 		o_point[3],newpoint[3];
  IGRpoint 		endpts[2];
  struct ret_struct 	ret_struct;
  struct IGRarc 	arc;
  struct IGRbsp_curve 	*cv;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the geometry of the associative object and pull out the
   * specific point needed to be grounded.
   */

  stat_OM = om$send (msg = message NDnode.NDgive_structure (&msg_loc,
             &ret_struct, md_env), targetid = assoc_src->objid,
             targetos = assoc_src->osnum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (ret_struct.type == point_generic)
  {
    point = ret_struct.var.point_st.pt;
    point_inx = FIRST;
  }
  else if (ret_struct.type == line_generic)
  {
    if (point_inx == FIRST)
      point = ret_struct.var.line_st.p0;
    else
    {
      point = ret_struct.var.line_st.p1;
      point_inx = SECOND;
    }
  }
  else if (ret_struct.type == arc_type)
  {
    if (point_inx == FIRST || point_inx == THIRD)
    {
      arc.prim_axis = ret_struct.var.circle_st.rad;
      arc.sec_axis = arc.prim_axis;
      OM_BLOCK_MOVE (ret_struct.var.circle_st.cent_p, arc.origin,
                     sizeof (IGRpoint));
      OM_BLOCK_MOVE (ret_struct.var.circle_st.mat, arc.rot_matrix,
                     sizeof (IGRmatrix));
      dptr = arc.rot_matrix;
      dptr[XORIG_PLANEMAT_INX] = 0.0;
      dptr[YORIG_PLANEMAT_INX] = 0.0;
      dptr[ZORIG_PLANEMAT_INX] = 0.0;
      arc.start_angle = ret_struct.var.circle_st.start_angle;
      arc.sweep_angle = ret_struct.var.circle_st.sweep_angle;

      MAarendpts (&msg_loc, &arc, (IGRdouble *)endpts);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);

      point = endpts[point_inx == FIRST ? FIRST : SECOND];
    }
    else
      point = ret_struct.var.circle_st.cent_p;
    }
    /*
     * if the type is circle, the circumference point lies at 3'o clock position
     * not the geometric endpoint.     TR # 119303786 & TR # 119312096
     */
    else if (ret_struct.type == circle_type)
    {
      IGRshort action = 1;
      IGRshort props = GRIS_POST220_OBJECT;

      if (point_inx == FIRST)        /* index ZERO is circumference point */
      {
        /*
         *  transform the o_point with circle matrix to get the actual 3'O clock position
         *  point on the cicumference of circle.
         */
        num = 1;
        o_point[0] = ret_struct.var.circle_st.rad;
        o_point[1] = 0.0;
        o_point[2] = 0.0;
        
        MAtypemx(&msg_loc,ret_struct.var.circle_st.mat,&matrix_type);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
        
        MAoptsxform(&msg_loc,&num,&matrix_type,ret_struct.var.circle_st.mat,
        	    o_point,newpoint );
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
        
        point = newpoint;
      }
      else
        point = ret_struct.var.circle_st.cent_p;
      
      /*
       * Set the POST220 property bit since the behaviour of this constraint has
       * changed.
       */
      stat_OM = om$send ( msg = message GRgraphics.GRchgprops (&msg_loc, &action, &props),
                          targetid = my_id );
          
    }
    else if (ret_struct.type == curve_generic)
    {
       /* Get geometry of the bspline curve */
       stat_OM = om$send( msg = message GRvg.GRgenabsg( &msg_loc, &md_env->md_env.matrix_type,
       			  md_env->md_env.matrix,(IGRchar **) &cv),  
       			  senderid = NULL_OBJID,
                          targetid = assoc_src->objid,
                          targetos = assoc_src->osnum);
       EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
       if(point_inx == 0)
         kk = 0;
       else
         kk = (cv->num_poles - 1) * 3;
       for(j=0; j<3; j++, kk++)
       {
         o_point[j] = cv->poles[kk];
       }
       point = o_point;
    }
   else
    {EMerr_hndlr (TRUE, *msg, EMS_E_NotSupported, ret_end);}

  /*
   * Construct a ptvar (if needed) and connect it to the manager. After that
   * the geometry can be stored and the transformation obtained automatically
   * from the manager.
   */

  if (IF_NULL_OBJID (*vgpt))
  {
    stat_OM = om$construct (classid = OPP_SKptvar_class_id,
               p_objid = vgpt);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

    stat_OM = om$send (msg = message SKmgr.SKconnect_to_ptvar (&msg_loc,
               *vgpt, NULL, 0, MAXINT), targetid = mgrobj);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
  }

  stat_OM = om$send (msg = message SKvariable.SKputvar (&msg_loc, NULL, 
             &md_env->md_env.matrix_type, md_env->md_env.matrix, point),
             targetid = *vgpt);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Perform the default construct. This would initialize my props and
   * make all the relevant connections for this constraint
   * (constraint-mgr and constraint-pt).
   */

  propsmask = SK_OPT_CREATE_GEOMETRY | SK_OPT_DISPLAY_GEOMETRY |
              SK_OPT_MARK_AS_NEWADD | SK_OPT_MARK_AS_USERADD;
  stat_OM = om$send (mode = OM_e_wrt_message,
             msg = message SKground.SKinit (&msg_loc, options & propsmask,
             md_env, 1, vgpt, 
             !(options & SK_OPT_CREATE_GEOMETRY) ? SK_INVISIBLEHNDL : NULL,
             NULL, NULL), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * The point-index is stored in the instance data.
   */

  ME.SKasptgrnd->asptinx = point_inx;

  /*
   * Connect the associative geometry object to me as a parent.
   */

  stat_OM = om$send (msg = message NDnode.NDconnect 
                           (1, assoc_src, NULL_GRID, ND_ADD), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_ASerror, ret_end);

  /*
   * Forcefully save the state of the profile since there will be no recompute
   * based on this assoc ground addition.
   */
  stat_OM = om$send (msg = message SKmgr.SKsavestate (&msg_loc, NULL, NULL),
                     targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKasptgrnd.SKinit_assocpt_ground");
  return (stat_OM);
}

end implementation SKasptgrnd;

