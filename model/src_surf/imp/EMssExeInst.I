/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "EMS.h"
# include "msdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlmdef.h"
#include "EMSlm.h"
#include "bsconic.h"
#include "emsmacros.h"
#include "bsparameters.h"
#include "bserr.h"

# ifndef gocmacros_include
# include "gocmacros.h" /* GRgetabsg */
# endif

method EMexeinst (IGRlong *EMmsg;
                  IGRvector vector;
                  struct GRmd_env *my_env;
                  IGRint inst_no;
                  GRobjid *newid;
                  struct EMinstruction_table_info *raw_instructions)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_InvalidArg for invalid arguement
                - EMS_E_SurfaceError error in surface method
Assumption

Bugs

History
	
	  gupta 	05/04/87:	design date
          RC            1/18/87         Changed GRpostab call EMputGeom
                                        such that validation of the
                                        class is performed.

Algorithm

      Get my abstract geometry. Based on the option for move, ie
      EMS_MOVE_LIN_FACE --     move the whole surface by vector
      EMS_MOVE_LIN_EDGE --     move all the poles on the edge (const par
                               curve of surface corresponding to the edge)
                               by vector. If a degenerate edge follows the
                               end points of the edge, all the poles 
                               corresponding to the degenerate edge are
                               also moved
      EMS_MOVE_INT_PRP_EDGE -- move all the internal poles of the edge
                               proportionately through the vector. The
                               first index of the end point specified in
                               the structure EMinstruction_table_info
                               is not moved and the other end point
                               is not moved either and is treated as 
                               rigid. All the other poles on this edge
                               will be moved by a certain ratio of vector.
      EMS_MOVE_LIN_VERTEX  --  move all the poles corresponding to the
                               parameter or end point specified for the
                               edge.
      EMS_MOVE_INT_LIN_EDGE -- this is similar to moving the whole edge
                               through vector, except that the poles 
                               corresponding to the end points are not
                               moved

      For edge and vertex, the poles correspond to U0, U1, V0 and V1
      curves of the surface, and this information is given to the 
      math, to minimize the search. The edges can be part of U0, U1,
      V0, V1 as well and the vertex may lie anywhere on these edges.
      This information is given to math through the end point 
      parameters of the edge or vertex

      Finally post the modified geometry of the surface.
 
 */

{
 IGRlong			             stat_OM, msg;
 IGRchar			             *ptr;
 IGRshort 			             option;
 IGRint				             i, j, ind, cnt0, cnt1, bndind;
 IGRdouble                       xdiff, ydiff;
 IGRdouble			             dist_tol;
 struct GRpost_info	             postinfo;
 struct IGRbsp_surface           *surf;
 struct EMinstruction_table_info *int_prop_inst;
 struct EMinstruction_table_info *other_inst;
 struct EMinstruction_table_info *instructions;

  extern  void BSmovsfpol2();
  extern  IGRdouble fabs();

/*--------------------------------------------------------------------*/

 stat_OM = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 cnt0 = cnt1 = 0;
 surf = NULL;

 int_prop_inst = (struct EMinstruction_table_info *) om$malloc (size =
                  inst_no * sizeof(struct EMinstruction_table_info));
 other_inst = (struct EMinstruction_table_info *) om$malloc (size =
                  inst_no * sizeof(struct EMinstruction_table_info));
 instructions = (struct EMinstruction_table_info *) om$malloc (size =
                  inst_no * sizeof(struct EMinstruction_table_info));

 GRgetabsg(&msg, &my_env->md_env.matrix_type, my_env->md_env.matrix, 
           &ptr, i);
 if (! (1 & msg)) goto wrapup;

 surf = (struct IGRbsp_surface *) ptr;

 /*
  * Reorganize the instructions so that all the EMS_MOVE_INT_PRP_EDGE
  * instructions are in the beginning of the stack 'instructions'
  */

 for (i=0; i<inst_no; i++)
  {
   if (raw_instructions[i].move_operation == 2)
    {
     int_prop_inst[cnt0] = raw_instructions[i];
     cnt0++;
    }
   else
    {
     other_inst[cnt1] = raw_instructions[i];
     cnt1++;
    }
  }

 for (i=0; i<cnt0; i++)
      instructions[i] = int_prop_inst[i];
 ind = 0;
 for (j=cnt0; j<(cnt0+cnt1); j++)
  {
      instructions[j] = other_inst[ind];
      ind++;
  }
 
 for (i=0 ; i<inst_no ; i++)
  {
   switch (instructions[i].move_operation)
   {
    case EMS_MOVE_LIN_FACE:

      option = 0;

      (void) BSmovsfpol2 (option, surf, vector, NULL, NULL, &msg);
      EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

      break;

    case EMS_MOVE_LIN_EDGE:
    
      option = 1;

      xdiff = fabs (instructions[i].params.end_pts[0] -
                   instructions[i].params.end_pts[2]);
      ydiff = fabs (instructions[i].params.end_pts[1] -
                   instructions[i].params.end_pts[3]);
     
      stat_OM = BSEXTRACTPAR(&msg, BSTOLLENVEC,dist_tol);
      EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

      if (xdiff < dist_tol)
       {
        if (fabs (instructions[i].params.end_pts[0] - 0.0) < dist_tol)
         {
          bndind = BSULEFTBND;  
         }
        else
        if (fabs (instructions[i].params.end_pts[0] - 1.0) < dist_tol)
         {
          bndind = BSURIGHTBND;
         }
        else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
        }
       else
       if (ydiff < dist_tol)
        {
        if (fabs (instructions[i].params.end_pts[1] - 0.0) < dist_tol)
         {
          bndind = BSVLEFTBND;
         }
        else
        if (fabs (instructions[i].params.end_pts[1] - 1.0) < dist_tol)
         {
          bndind = BSVRIGHTBND;
         }
        else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
       }
      else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
 
       (void) BSmovsfpol2(option, surf, vector, bndind,
                         instructions[i].params.end_pts, &msg);
       EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

      break;
 
    case EMS_MOVE_INT_PRP_EDGE:
    
      option = 2;
 
      xdiff = fabs (instructions[i].params.end_pts[0] -
                   instructions[i].params.end_pts[2]);
      ydiff = fabs (instructions[i].params.end_pts[1] -
                   instructions[i].params.end_pts[3]);
   
      stat_OM = BSEXTRACTPAR(&msg, BSTOLLENVEC,dist_tol);
      EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

      if (xdiff < dist_tol)
       {
        if (fabs (instructions[i].params.end_pts[0] - 0.0) < dist_tol)
         {
          bndind = BSULEFTBND;  
         }
        else
        if (fabs (instructions[i].params.end_pts[0] - 1.0) < dist_tol)
         {
          bndind = BSURIGHTBND;
         }
        else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
        }
       else
       if (ydiff < dist_tol)
        {
        if (fabs (instructions[i].params.end_pts[1] - 0.0) < dist_tol)
         {
          bndind = BSVLEFTBND;
         }
        else
        if (fabs (instructions[i].params.end_pts[1] - 1.0) < dist_tol)
         {
          bndind = BSVRIGHTBND;
         }
        else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
       }
      else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);

       (void) BSmovsfpol2(option, surf, vector, bndind,
                         instructions[i].params.end_pts, &msg);
       EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

      break;

    case EMS_MOVE_LIN_VERTEX:
      option = 3;
 
      stat_OM = BSEXTRACTPAR(&msg, BSTOLLENVEC,dist_tol);
      EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

      if (fabs (instructions[i].params.vt_pt[0] - 0.0) < dist_tol)
         {
          bndind = BSULEFTBND;  
         }
      else
      if (fabs (instructions[i].params.vt_pt[0] - 1.0) < dist_tol)
         {
          bndind = BSURIGHTBND;
         }
      else
      if (fabs (instructions[i].params.vt_pt[1] - 0.0) < dist_tol)
         {
          bndind = BSVLEFTBND;
         }
      else
      if (fabs (instructions[i].params.vt_pt[1] - 1.0) < dist_tol)
         {
          bndind = BSVRIGHTBND;
         }
      else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
  
      (void) BSmovsfpol2(option, surf, vector, bndind,
                        instructions[i].params.vt_pt, &msg);
      EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

      break;

    case EMS_MOVE_INT_LIN_EDGE:
    
      option = 4;

      xdiff = fabs (instructions[i].params.end_pts[0] -
                   instructions[i].params.end_pts[2]);
      ydiff = fabs (instructions[i].params.end_pts[1] -
                   instructions[i].params.end_pts[3]);
   
      stat_OM = BSEXTRACTPAR(&msg, BSTOLLENVEC,dist_tol);
      EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

      if (xdiff < dist_tol)
       {
        if (fabs (instructions[i].params.end_pts[0] - 0.0) < dist_tol)
         {
          bndind = BSULEFTBND;  
         }
        else
        if (fabs (instructions[i].params.end_pts[0] - 1.0) < dist_tol)
         {
          bndind = BSURIGHTBND;
         }
        else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
        }
       else
       if (ydiff < dist_tol)
        {
        if (fabs (instructions[i].params.end_pts[1] - 0.0) < dist_tol)
         {
          bndind = BSVLEFTBND;
         }
        else
        if (fabs (instructions[i].params.end_pts[1] - 1.0) < dist_tol)
         {
          bndind = BSVRIGHTBND;
         }
        else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
       }
      else
         EMerr_hndlr(TRUE, *EMmsg, EMS_E_InvalidArg, wrapup);
  
       (void) BSmovsfpol2(option, surf, vector, bndind,
                         instructions[i].params.end_pts, &msg);
       EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

      break;

     }
    }

 postinfo.construct_flag = FALSE;

 /*
  * Changed GRpostansg call to EMputGeom with validate_class
  * flag to TRUE.
  */

 stat_OM = om$send (msg = message EMSsubbs.EMputGeom (&msg, my_env,
                          &postinfo, ptr, newid, TRUE), 
                   targetid = my_id);
 EMomerr_hndlr(stat_OM, wrapup, "EMbsexeinst.GRpostabsg");
 EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);


wrapup:

 if (ptr) GRabsg_del(ptr);
 if (int_prop_inst) om$dealloc(ptr = int_prop_inst);
 if (other_inst) om$dealloc(ptr = other_inst);
 if (instructions) om$dealloc(ptr = instructions);

 return (stat_OM);
}

end implementation EMSsubbs;

