/*

Name
  SKasptgrnd

Abstract

Synopsis

Description

Return Value

Notes

Index

Keywords
 evaluate, ground, constraint
 
History
  10/26/93 : GMK    :  TR#119303786 : The circumference point for circle is at
			       3'O clock position not at geometric end point.
  11/15/93 : GMK    :   TR#119312096 : finding the circumference point for circle 
  12/23/93 : Satya  :   TR#119313612 : Now even bsplines need to recompute.
  12/30/93 : Rajiv Agrawal : Extracted all the code out of the NDupdate method
                             so that the new coordinates are put into the solvedvars list
                             instead of going directly into the SKptvars.  

 */
class implementation SKasptgrnd;

#include "OMmacros.h"
#include "DIdef.h"
#include "madef.h"
#include "maarendpt.h"
#include "maidmx.h"
#include "maoptsxfo.h"
#include "matypemx.h"

#define FIRST	0
#define SECOND	1
#define THIRD	2

#define X 0
#define Y 1

from SKvariable import SKgetvar;
from SKvalvar import SKgetname;
from SKexplicit import SKgetname;
from SKmgr import SKget_xymat;

method SKevaluate (IGRlong *msg; IGRushort options;
                   struct SKsolvevars *tosolvevar;
                   struct SKsolvevars **solvedvars;
                   struct SKsolvevars **nosolution_vars)
{
  IGRchar 		name[DI_PATH_MAX];
  OMuint 		num_parents;
  IGRushort 		vprops;
  short 		matrix_type;
  int			stat_OM, point_inx, kk, j;
  long 			msg_loc, num;
  double 		*point, *dptr;
  IGRpoint 		o_point, newpoint;
  IGRmatrix		idmatrix;
  GRobjid 		var_id;
  GRspacenum 		dum_os;
  struct GRid 		parent;
  IGRpoint 		endpts[2];
  struct IGRarc 	arc;
  struct IGRbsp_curve   *cv;
  struct GRmd_env 	md_env;
  struct ret_struct 	ret_struct;
  struct SKsolvevars 	*varnode;
  OM_S_CHANSELECT 	chan_to_vars, chan_to_parents, chan_to_mgr;
  extern void 		SKaddvarlist();
  extern IGRboolean 	SKvarlistinx();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
 
  om$make_chanselect (channame = "SKconstraint.to_variables",
                      p_chanselect = &chan_to_vars);

  stat_OM = om$get_objid_at_index (object = me, 
                                   p_chanselect = &chan_to_vars, index = 0,
                                   objidaddr = &var_id, osnumaddr = &dum_os);
  EMerr_hndlr (stat_OM != OM_S_SUCCESS, *msg, EMS_E_InvalidCase, ret_end);

  if (SKvarlistinx (*solvedvars, var_id, tosolvevar->props, &varnode, NULL))
  {
    *msg = EMS_I_Redundant;
    goto ret_end;
  }

  /*
   * If the ground constraint has any parents, then get the values from 
   * there instead of just getting them from the point.
   */
  om$make_chanselect ( channame = "NDfather.father", p_chanselect = &chan_to_parents);
  om$get_channel_count ( objid = my_id, p_chanselect = &chan_to_parents,
                         count = &num_parents );
  EMerr_hndlr (num_parents > 1, *msg, EMS_I_InvalidArg, ret_end);
  
  if (!num_parents) 
  {
    stat_OM = om$send (msg = message SKvariable.SKgetvar (&msg_loc,
                             NULL, NULL, NULL, newpoint), 
                       targetid = var_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    point = newpoint;
  }
  else 
  {  
     om$get_objid_at_index ( objid = my_id, p_chanselect = &chan_to_parents,
                             index = 0,
                             objidaddr = &parent.objid, osnumaddr = &parent.osnum );

     om$make_chanselect ( channame = "SKconstraint.to_mgr", 
                          p_chanselect = &chan_to_mgr );
     
     matrix_type = MAIDMX;
     MAidmx(&msg_loc, idmatrix);
     stat_OM = om$send (msg = message SKmgr.SKget_xymat 
                              (&msg_loc, SK_OPT_GET_XYZ_TO_XY, &matrix_type, idmatrix,
                               &md_env.md_env.matrix_type, md_env.md_env.matrix),
                        p_chanselect = &chan_to_mgr);
     stat_OM = om$send (msg = message NDnode.NDgive_structure 
                              (&msg_loc, &ret_struct, &md_env), 
                        targetid = parent.objid,
                        targetos = parent.osnum);
     EMerr_hndlr(!(1 & stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    
     point_inx = ME.SKasptgrnd->asptinx;
     if (ret_struct.type == point_generic)
       point = ret_struct.var.point_st.pt;
     else if (ret_struct.type == line_generic)
     {
       if (point_inx == FIRST)
         point = ret_struct.var.line_st.p0;
       else
         point = ret_struct.var.line_st.p1;
     }
     else if (ret_struct.type == arc_type)
     {
        if(point_inx == FIRST || point_inx == THIRD)
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
      else if (ret_struct.type == circle_type)
      {
        IGRshort grprops;
        /*
         * if the type is circle, the circumference point lies at 3'o clock position
         * not the geometric endpoint.     TR # 119303786 & TR # 119312096
         * Since this behaviour is different from the EMS 2.2 days, we need to check
         * if the constraint was created in a post 2.2 era.  If so, then do the
         * correct stuff, else continue to do the old thing.
         */
        stat_OM = om$send(msg = message GRgraphics.GRgetprops (&msg_loc, &grprops), 
                          targetid = my_id);
        if (grprops & GRIS_POST220_OBJECT) 
        {
          if (point_inx == FIRST)        /* index ZERO is circumference point */
          {
            /*
             *  transform the o_point (at world origin) with circle matrix to get the 
             *  actual 3'O clock position point on the cicumference of circle.
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
        }
        else
        {
          if (point_inx == SECOND) 
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
      }
      /*
       *  Now it is possible to have even bsplines for constraints. TR# 119313612
       */
      else if (ret_struct.type == curve_generic)
      {
         /* Get geometry of the bspline curve */
         stat_OM = om$send (msg = message GRvg.GRgenabsg
                                 ( &msg_loc, &md_env.md_env.matrix_type,
         			  md_env.md_env.matrix, (IGRchar **) &cv),  
         	            senderid = NULL_OBJID,
                            targetid = parent.objid,
                            targetos = parent.osnum);
         EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
         if(point_inx == 0)
           kk = 0;
         else
           kk = (cv->num_poles - 1) * 3;
         for(j=0;j<3;j++,kk++)
         {
           o_point[j] = cv->poles[kk];
         }
         point = o_point;
      }
      else
         {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);}
  }
       
  vprops = tosolvevar->props;

  if ((vprops & VAR_PT) == VAR_PT && options & SK_UPDATE_COMPRESSED)
  {
    SKaddvarlist (&msg_loc, NULL, solvedvars, VAR_PT, var_id, my_id, my_id,
                  point, NULL);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  else
  {
    if (vprops & VAR_X)
    {
      SKaddvarlist (&msg_loc, NULL, solvedvars, VAR_X, var_id, my_id, my_id,
                    &point[X], NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    if (vprops & VAR_Y)
    {
      SKaddvarlist (&msg_loc, NULL, solvedvars, VAR_Y, var_id, my_id, my_id,
                    &point[Y], NULL);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }
    if (vprops & VAR_SOMEVAL)
    {
      if (vprops & VAR_PSEUDO_VAL)
        stat_OM = om$send (msg = message SKexplicit.SKgetname (&msg_loc, 
                   SK_GETVR_EQNVARNAME | SK_GETVR_SIGNIFNAME, name),
                   targetid = var_id);
      else
        stat_OM = om$send (msg = message SKvalvar.SKgetname (&msg_loc, 
                   SK_GETVR_EQNVARNAME | SK_GETVR_SIGNIFNAME, name),
                   targetid = var_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

      SKaddvarlist (&msg_loc, NULL, solvedvars,
                    vprops & VAR_SOMEVAL, var_id, my_id, my_id, point, name);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

  }

ret_end:
  EMWRAPUP(*msg, stat_OM, "SKasptgrnd.SKevaluate");
  return (stat_OM);
}

end implementation SKasptgrnd;
