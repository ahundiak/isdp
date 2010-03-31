/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

/*
   History

         Sudha 06/04/93          modified to include BSprototype header files
*/

#include "EMS.h"
#include "EMSbnd.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "OMmacros.h"
#include "bsparameters.h"

#define INCR_SIZE 5

extern OMuword OPP_EMSpartedge_class_id;

from GRvg import GRgetsize;
from GRvg import GRgetgeom;
from EMSpartedge import EMmake_end_compatible;
from EMSgenbs import EMinsktln;
from EMSsubbs import EMmove_class;

method EMmake_compatible(IGRlong *EMmsg; 
                         struct GRmd_env *my_env)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure
                - EMS_E_EdgeError -- edge error
                - EMS_E_SurfaceError -- surface error
Assumption

Bugs

History
	
	  gupta 	05/05/87:	design date
                10/19/87:   changed for new class structure

Algorithm

      This method will make me compatible with respect to my common
      edge if I am not so.
      o get the surface geometry of my edge and my common edge
      o compare the knot sequence in these two surfaces and when
        a vector is found on one which is missing on the other, a
        knot vector is inserted at that parameter. 
*/

{
  IGRshort              code1, code2, option;
  IGRshort              my_loc, com_loc;
  IGRlong               stat_OM,msg;
  OMuword               edge_class_id;
  IGRint                i, j, mul, num_parms;
  OMuint                comm_edge_cnt;
  IGRint                surf1_size, surf2_size;
  IGRdouble             knot_tol, parm1[2], parm2[2], *parms;
  struct EMSedgebound   bound1[2], bound2[2];
  IGRdouble             previous_parm;
  extern   IGRdouble             fabs();
  IGRboolean            is_candidate;
  GRobjid               comm_surf, my_surf, my_surf_id, 
                        com_surf_id;
  GRobjid               new_surf, chg_id;
  struct IGRbsp_surface *surf1, *surf2;
  struct EMSedgebound   my_edge_info, comm_edge_info;
  OM_S_CHANSELECT       to_common_edge;

/*------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  parms = NULL;
  previous_parm = 999;

  stat_OM = om$get_classid(object = me,
                           p_classid = &edge_class_id);
  if (! (1 & stat_OM)) goto wrapup;

  /* if I am already compatible with my common edge -- return */

  to_common_edge.type = OM_e_addr;
  to_common_edge.u_sel.addr = &ME.EMSedge->to_common_edge;

  /* if I do not have a common edge -- return */

  stat_OM = om$get_channel_count (object = me,
                                  p_chanselect = &to_common_edge,
                                  count = &comm_edge_cnt);
  EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.get_chan_cnt");

  stat_OM = om$is_ancestry_valid (subclassid = edge_class_id,
                    superclassid = OPP_EMSpartedge_class_id);

  if ((ME.EMSedge->ed_props & EMED_COMPATIBLE) && (! comm_edge_cnt) &&
      (stat_OM == OM_S_SUCCESS))
   {
    stat_OM = om$send (msg = message EMSpartedge.EMmake_end_compatible(
                             &msg, my_env),
                       targetid = my_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMmake_end_compatible");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }  
  else if (stat_OM == OM_I_INVANCESTRY)
   {stat_OM = OM_S_SUCCESS;}
   
  if ((ME.EMSedge->ed_props & EMED_COMPATIBLE) || (! comm_edge_cnt))
      return (OM_S_SUCCESS);

  /* get my surface id as well as the common edge's surface id */

   stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                           (&msg, &my_surf_id, NULL),
                     targetid = my_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMgetsurf_info");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

   stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                           (&msg, &com_surf_id, NULL),
                     p_chanselect = &to_common_edge);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMgetsurf_info");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

   if (my_surf_id == com_surf_id)
       return(OM_S_SUCCESS);

   num_parms = 0;

   (void)BSEXTRACTPAR(&msg, BSTOLKNOT, knot_tol);

   EMerr_hndlr(BSERROR(msg), *EMmsg, EMS_E_Fail, wrapup);

   /* get my and my common edge's end parameters */

   stat_OM = om$send(msg=message EMSedge.EMendpts(&msg, NULL, NULL,
                         &bound1[0], &bound1[1], NULL),
                     targetid = my_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMendpts");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

   parm1[0] = bound1[0].param;
   parm1[1] = bound1[1].param;

   stat_OM = om$send(msg=message EMSedge.EMendpts(&msg, NULL, NULL,
                         &bound2[0], &bound2[1], NULL),
                     p_chanselect = &to_common_edge);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMendpts");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

   parm2[0] = bound2[0].param;
   parm2[1] = bound2[1].param;

   stat_OM = om$send(msg = message EMSedge.EMget_location(&msg, &my_loc),
                     targetid = my_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMget_location");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

   stat_OM = om$send(msg = message EMSedge.EMget_location(&msg, &com_loc),
                     p_chanselect = &to_common_edge);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMget_location");
   EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

   code1 = (my_loc == 1 || my_loc == 3) ? 1 : 2;
   code2 = (com_loc == 1 || com_loc == 3) ? 1 : 2;
  
   if (code1 == 1 && code2 == 1)
       option = 0;
   else if (code1 == 1 && code2 == 2)
       option = 1;
   else if (code1 == 2 && code2 == 1)
       option = 2;
   else
       option = 3;

   /*
    * reset my and common edge's end parameters if the location is 
    * 2 or 3 
    */

   if (my_loc == 2 || my_loc == 3)
    {
     parm1[0] = 1 - parm1[0];
     parm1[1] = 1 - parm1[1];
    }
   if (com_loc == 2 || com_loc == 3)
    {
     parm2[0] = 1 - parm2[0];
     parm2[1] = 1 - parm2[1];
    }

   /* get my surface and common edge's surface geometry */

   stat_OM = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetsize
                           (&msg,&my_env->md_env.matrix_type,
                           my_env->md_env.matrix, (IGRlong *)&surf1_size),
                      senderid = my_id,
                      targetid = my_surf_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.GRgetsize");
   EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

   surf1 = (struct IGRbsp_surface *) om$malloc(size = surf1_size);

   EMerr_hndlr (! surf1 , *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   stat_OM = om$send(mode = OM_e_wrt_object,
                            msg = message GRvg.GRgetgeom
                            (&msg,&my_env->md_env.matrix_type,
                            my_env->md_env.matrix, (IGRchar *)surf1),
                      senderid = my_id,
                      targetid = my_surf_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.GRgetgeom");
   EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

   stat_OM = om$send(mode = OM_e_wrt_object,
                     msg = message GRvg.GRgetsize
                          (&msg,&my_env->md_env.matrix_type,
                           my_env->md_env.matrix, (IGRlong *)&surf2_size),
                      senderid = my_id,
                      targetid = com_surf_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.GRgetsize");
   EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

   surf2 = (struct IGRbsp_surface *) om$malloc(size = surf2_size);

   EMerr_hndlr (! surf2 , *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   stat_OM = om$send(mode = OM_e_wrt_object,
                            msg = message GRvg.GRgetgeom
                            (&msg,&my_env->md_env.matrix_type,
                            my_env->md_env.matrix, (IGRchar *)surf2),
                      senderid = my_id,
                      targetid = com_surf_id);
   EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.GRgetgeom");
   EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);

   /* make the two surfaces compatible at indicated directions */

 switch (option)
  {
   case 0:     /* u and u */

   if (surf1->u_order != surf2->u_order)
    {
     *EMmsg = EMS_I_DiffSrfOrder;
     goto wrapup;
    }

   for (i=0; i<surf1->u_num_knots; i++)
    {
     if ((surf1->u_knots[i]>=parm1[0] && surf1->u_knots[i]<=parm1[1]) ||
         (surf1->u_knots[i]>=parm1[1] && surf1->u_knots[i]<=parm1[0]))
      {
         my_edge_info.span_inx = 0;
         my_edge_info.param = (my_loc == 3) ? 1 - surf1->u_knots[i]:
                                                  surf1->u_knots[i];
    
         my_surf = NULL_OBJID;
         stat_OM = om$send(msg = message EMSedge.EMtwin_crv_parm(&msg,
                                 &my_edge_info, &comm_edge_info, my_env,
                                 com_loc, &my_surf, &comm_surf),
                           targetid = my_id);
         EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMtwin_crv_parm");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
         is_candidate = TRUE;

         comm_edge_info.param = (com_loc == 3) ? 1-comm_edge_info.param :
                                                 comm_edge_info.param;

         if (fabs(comm_edge_info.param - parm2[0]) <= knot_tol)
             comm_edge_info.param = parm2[0];
         else
         if (fabs(comm_edge_info.param - parm2[1]) <= knot_tol)
             comm_edge_info.param = parm2[1];

         if (comm_edge_info.param == previous_parm)
             is_candidate = FALSE;
         else
         {
          for (j=0; j<surf2->u_num_knots; j++)
           {
            if (fabs(surf2->u_knots[j] - comm_edge_info.param)
                                       < knot_tol)
                is_candidate = FALSE;
                continue;
           }
         }
         if (is_candidate)
          {
           if (! ((num_parms) % INCR_SIZE))
            {
             if (! num_parms)
              {
               parms = (IGRdouble *) om$malloc (size = INCR_SIZE *
                                                sizeof(IGRdouble));
              }
             else
              {
               parms = (IGRdouble *) om$realloc (ptr = (IGRchar *)parms,
                      size = (num_parms + INCR_SIZE) * sizeof(IGRdouble));
              }
            }
           parms[num_parms] = comm_edge_info.param;
           num_parms++; 
           previous_parm = comm_edge_info.param; 
          }
      }
    }
   if (num_parms)
   {
    stat_OM = om$send(msg = message EMSsubbs.EMmove_class (&msg,
                            my_env, &new_surf),
                      targetid = com_surf_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMmove_class");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

    mul = surf1->u_order-1;
    stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                            num_parms, parms, NULL, NULL, 
                            mul, 0, TRUE, FALSE, &chg_id),
                      targetid = new_surf);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMinsktln");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);
   }
   num_parms = 0;
   parms = NULL;

   for (i=0; i<surf2->u_num_knots; i++)
    {
     if ((surf2->u_knots[i]>=parm2[0] && surf2->u_knots[i]<=parm2[1]) ||
         (surf2->u_knots[i]>=parm2[1] && surf2->u_knots[i]<=parm2[0]))
      {
         my_edge_info.span_inx = 0;
         my_edge_info.param = (com_loc == 3) ? 1 - surf2->u_knots[i]:
                                                   surf2->u_knots[i];
    
         my_surf = NULL_OBJID;
         stat_OM = om$send(msg = message EMSedge.EMtwin_crv_parm(&msg,
                                 &my_edge_info, &comm_edge_info, my_env,
                                 my_loc, &my_surf, &comm_surf),
                           p_chanselect = &to_common_edge);
         EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMtwin_crv_parm");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
         is_candidate = TRUE;

         comm_edge_info.param = (my_loc == 3) ? 1-comm_edge_info.param :
                                                comm_edge_info.param;
         if (fabs(comm_edge_info.param - parm1[0]) <= knot_tol)
             comm_edge_info.param = parm1[0];
         else
         if (fabs(comm_edge_info.param - parm1[1]) <= knot_tol)
             comm_edge_info.param = parm1[1];

         if (comm_edge_info.param == previous_parm)
             is_candidate = FALSE;
         else
         {
          for (j=0; j<surf1->u_num_knots; j++)
           {
            if (fabs(surf1->u_knots[j] - comm_edge_info.param)
                                       < knot_tol)
                is_candidate = FALSE;
                continue;
           }
         }
         if (is_candidate)
          {
           if (! ((num_parms) % INCR_SIZE))
            {
             if (! num_parms)
              {
               parms = (IGRdouble *) om$malloc (size = INCR_SIZE *
                                                sizeof(IGRdouble));
              }
             else
              {
               parms = (IGRdouble *) om$realloc (ptr = (IGRchar *)parms,
                      size = (num_parms + INCR_SIZE) * sizeof(IGRdouble));
              }
            }
           parms[num_parms] = comm_edge_info.param;
           num_parms++; 
           previous_parm = comm_edge_info.param; 
          }
      }
    }
   if (num_parms)
   {
    stat_OM = om$send(msg = message EMSsubbs.EMmove_class (&msg,
                            my_env, &new_surf),
                      targetid = my_surf_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMmove_class");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

    mul = surf2->u_order-1;
    stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                            num_parms, parms, NULL, NULL, 
                            mul, 0, TRUE, FALSE, &chg_id),
                      targetid = new_surf);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMinsktln");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);
   }
   break;

   case 1:     /* u and v */

   if (surf1->u_order != surf2->v_order)
    {
     *EMmsg = EMS_I_DiffSrfOrder;
     goto wrapup;
    }

   for (i=0; i<surf1->u_num_knots; i++)
    {
     if ((surf1->u_knots[i]>=parm1[0] && surf1->u_knots[i]<=parm1[1]) ||
         (surf1->u_knots[i]>=parm1[1] && surf1->u_knots[i]<=parm1[0]))
      {
         my_edge_info.span_inx = 0;
         my_edge_info.param = (my_loc == 3) ? 1 - surf1->u_knots[i]:
                                                  surf1->u_knots[i];
        
         my_surf = NULL_OBJID;
         stat_OM = om$send(msg = message EMSedge.EMtwin_crv_parm(&msg,
                                 &my_edge_info, &comm_edge_info, my_env,
                                 com_loc, &my_surf, &comm_surf),
                           targetid = my_id);
         EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMtwin_crv_parm");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
         is_candidate = TRUE;

         comm_edge_info.param = (com_loc == 2) ? 1-comm_edge_info.param :
                                                 comm_edge_info.param;

         if (fabs(comm_edge_info.param - parm2[0]) <= knot_tol)
             comm_edge_info.param = parm2[0];
         else
         if (fabs(comm_edge_info.param - parm2[1]) <= knot_tol)
             comm_edge_info.param = parm2[1];

         if (comm_edge_info.param == previous_parm)
             is_candidate = FALSE;
         else
         {
          for (j=0; j<surf2->v_num_knots; j++)
           {
            if (fabs(surf2->v_knots[j] - comm_edge_info.param)
                                       < knot_tol)
                is_candidate = FALSE;
                continue;
           }
         }
         if (is_candidate)
          {
           if (! ((num_parms) % INCR_SIZE))
            {
             if (! num_parms)
              {
               parms = (IGRdouble *) om$malloc (size = INCR_SIZE *
                                                sizeof(IGRdouble));
              }
             else
              {
               parms = (IGRdouble *) om$realloc (ptr = (IGRchar *)parms,
                      size = (num_parms + INCR_SIZE) * sizeof(IGRdouble));
              }
            }
           parms[num_parms] = comm_edge_info.param;
           num_parms++; 
           previous_parm = comm_edge_info.param; 
          }
      }
    }
   if (num_parms)
   {
    stat_OM = om$send(msg = message EMSsubbs.EMmove_class (&msg,
                            my_env, &new_surf),
                      targetid = com_surf_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMmove_class");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

    mul = surf1->u_order-1;
    stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                             NULL, NULL, num_parms, parms, 
                            mul, 0, FALSE, TRUE, &chg_id),
                      targetid = new_surf);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMinsktln");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);
   }
   num_parms = 0;
   parms = NULL;

   for (i=0; i<surf2->v_num_knots; i++)
    {
     if ((surf2->v_knots[i]>=parm2[0] && surf2->v_knots[i]<=parm2[1]) ||
         (surf2->v_knots[i]>=parm2[1] && surf2->v_knots[i]<=parm2[0]))
      {
         my_edge_info.span_inx = 0;
         my_edge_info.param = (com_loc == 2) ? 1 - surf2->v_knots[i]:
                                                   surf2->v_knots[i];
        
         my_surf = NULL_OBJID;
         stat_OM = om$send(msg = message EMSedge.EMtwin_crv_parm(&msg,
                                 &my_edge_info, &comm_edge_info, my_env,
                                 my_loc, &my_surf, &comm_surf),
                           p_chanselect = &to_common_edge);
         EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMtwin_crv_parm");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
         is_candidate = TRUE;

         comm_edge_info.param = (my_loc == 3) ? 1-comm_edge_info.param :
                                                comm_edge_info.param;
         if (fabs(comm_edge_info.param - parm1[0]) <= knot_tol)
             comm_edge_info.param = parm1[0];
         else
         if (fabs(comm_edge_info.param - parm1[1]) <= knot_tol)
             comm_edge_info.param = parm1[1];

         if (comm_edge_info.param == previous_parm)
             is_candidate = FALSE;
         else
         {
          for (j=0; j<surf1->u_num_knots; j++)
           {
            if (fabs(surf1->u_knots[j] - comm_edge_info.param)
                                       < knot_tol)
                is_candidate = FALSE;
                continue;
           }
         }
         if (is_candidate)
          {
           if (! ((num_parms) % INCR_SIZE))
            {
             if (! num_parms)
              {
               parms = (IGRdouble *) om$malloc (size = INCR_SIZE *
                                                sizeof(IGRdouble));
              }
             else
              {
               parms = (IGRdouble *) om$realloc (ptr = (IGRchar *)parms,
                      size = (num_parms + INCR_SIZE) * sizeof(IGRdouble));
              }
            }
           parms[num_parms] = comm_edge_info.param;
           num_parms++; 
           previous_parm = comm_edge_info.param; 
          }
      }
    }
   if (num_parms)
   {
    stat_OM = om$send(msg = message EMSsubbs.EMmove_class (&msg,
                            my_env, &new_surf),
                      targetid = my_surf_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMmove_class");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

    mul = surf2->v_order-1;
    stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                            num_parms, parms, NULL, NULL, 
                            mul, 0, TRUE, FALSE, &chg_id),
                      targetid = new_surf);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMinsktln");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);
   }
   break;

   case 2:     /* v and u */

   if (surf1->v_order != surf2->u_order)
    {
     *EMmsg = EMS_I_DiffSrfOrder;
     goto wrapup;
    }

   for (i=0; i<surf1->v_num_knots; i++)
    {
     if ((surf1->v_knots[i]>=parm1[0] && surf1->v_knots[i]<=parm1[1]) ||
         (surf1->v_knots[i]>=parm1[1] && surf1->v_knots[i]<=parm1[0]))
      {
         my_edge_info.span_inx = 0;
         my_edge_info.param = (my_loc == 2) ? 1 - surf1->v_knots[i]:
                                                  surf1->v_knots[i];
    
         my_surf = NULL_OBJID;
         stat_OM = om$send(msg = message EMSedge.EMtwin_crv_parm(&msg,
                                 &my_edge_info, &comm_edge_info, my_env,
                                 com_loc, &my_surf, &comm_surf),
                           targetid = my_id);
         EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMtwin_crv_parm");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
         is_candidate = TRUE;

         comm_edge_info.param = (com_loc == 3) ? 1-comm_edge_info.param :

                                                 comm_edge_info.param;
         if (fabs(comm_edge_info.param - parm2[0]) <= knot_tol)
             comm_edge_info.param = parm2[0];
         else
         if (fabs(comm_edge_info.param - parm2[1]) <= knot_tol)
             comm_edge_info.param = parm2[1];

         if (comm_edge_info.param == previous_parm)
             is_candidate = FALSE;
         else
         {
          for (j=0; j<surf2->u_num_knots; j++)
           {
            if (fabs(surf2->u_knots[j] - comm_edge_info.param)
                                       < knot_tol)
                is_candidate = FALSE;
                continue;
           }
         }
         if (is_candidate)
          {
           if (! ((num_parms) % INCR_SIZE))
            {
             if (! num_parms)
              {
               parms = (IGRdouble *) om$malloc (size = INCR_SIZE *
                                                sizeof(IGRdouble));
              }
             else
              {
               parms = (IGRdouble *) om$realloc (ptr = (IGRchar *)parms,
                      size = (num_parms + INCR_SIZE) * sizeof(IGRdouble));
              }
            }
           parms[num_parms] = comm_edge_info.param;
           num_parms++; 
           previous_parm = comm_edge_info.param; 
          }
      }
    }
   if (num_parms)
   {
    stat_OM = om$send(msg = message EMSsubbs.EMmove_class (&msg,
                            my_env, &new_surf),
                      targetid = com_surf_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMmove_class");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

    mul = surf1->v_order-1;
    stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                            num_parms, parms, NULL, NULL, 
                            mul, 0, TRUE, FALSE, &chg_id),
                      targetid = new_surf);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMinsktln");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);
   }
   num_parms = 0;
   parms = NULL;

   for (i=0; i<surf2->u_num_knots; i++)
    {
     if ((surf2->u_knots[i]>=parm2[0] && surf2->u_knots[i]<=parm2[1]) ||
         (surf2->u_knots[i]>=parm2[1] && surf2->u_knots[i]<=parm2[0]))
      {
         my_edge_info.span_inx = 0;
         my_edge_info.param = (com_loc == 3) ? 1 - surf2->u_knots[i]:
                                                   surf2->u_knots[i];
        
         my_surf = NULL_OBJID;
         stat_OM = om$send(msg = message EMSedge.EMtwin_crv_parm(&msg,
                                 &my_edge_info, &comm_edge_info, my_env,
                                 my_loc, &my_surf, &comm_surf),
                           p_chanselect = &to_common_edge);
         EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMtwin_crv_parm");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
         is_candidate = TRUE;

         comm_edge_info.param = (my_loc == 2) ? 1-comm_edge_info.param :
                                                comm_edge_info.param;

         if (fabs(comm_edge_info.param - parm1[0]) <= knot_tol)
             comm_edge_info.param = parm1[0];
         else
         if (fabs(comm_edge_info.param - parm1[1]) <= knot_tol)
             comm_edge_info.param = parm1[1];

         if (comm_edge_info.param == previous_parm)
             is_candidate = FALSE;
         else
         {
          for (j=0; j<surf1->v_num_knots; j++)
           {
            if (fabs(surf1->v_knots[j] - comm_edge_info.param)
                                       < knot_tol)
                is_candidate = FALSE;
                continue;
           }
         }
         if (is_candidate)
          {
           if (! ((num_parms) % INCR_SIZE))
            {
             if (! num_parms)
              {
               parms = (IGRdouble *) om$malloc (size = INCR_SIZE *
                                                sizeof(IGRdouble));
              }
             else
              {
               parms = (IGRdouble *) om$realloc (ptr = (IGRchar *)parms,
                      size = (num_parms + INCR_SIZE) * sizeof(IGRdouble));
              }
            }
           parms[num_parms] = comm_edge_info.param;
           num_parms++; 
           previous_parm = comm_edge_info.param; 
          }
      }
    }
   if (num_parms)
   {
    stat_OM = om$send(msg = message EMSsubbs.EMmove_class (&msg,
                            my_env, &new_surf),
                      targetid = my_surf_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMmove_class");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

    mul = surf2->u_order-1;
    stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                             NULL, NULL, num_parms, parms, 
                            mul, 0, FALSE, TRUE, &chg_id),
                      targetid = new_surf);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMinsktln");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);
   }
   break;

   case 3:     /* v and v */

   if (surf1->v_order != surf2->v_order)
    {
     *EMmsg = EMS_I_DiffSrfOrder;
     goto wrapup;
    }

   for (i=0; i<surf1->v_num_knots; i++)
    {
     if ((surf1->v_knots[i]>=parm1[0] && surf1->v_knots[i]<=parm1[1]) ||
         (surf1->v_knots[i]>=parm1[1] && surf1->v_knots[i]<=parm1[0]))
      {
         my_edge_info.span_inx = 0;
         my_edge_info.param = (my_loc == 2) ? 1 - surf1->v_knots[i]:
                                                  surf1->v_knots[i];
        
         my_surf = NULL_OBJID;
         stat_OM = om$send(msg = message EMSedge.EMtwin_crv_parm(&msg,
                                 &my_edge_info, &comm_edge_info, my_env,
                                 com_loc, &my_surf, &comm_surf),
                           targetid = my_id);
         EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMtwin_crv_parm");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
         is_candidate = TRUE;

         comm_edge_info.param = (com_loc == 2) ? 1-comm_edge_info.param :
                                                 comm_edge_info.param;
         if (fabs(comm_edge_info.param - parm2[0]) <= knot_tol)
             comm_edge_info.param = parm2[0];
         else
         if (fabs(comm_edge_info.param - parm2[1]) <= knot_tol)
             comm_edge_info.param = parm2[1];

         if (comm_edge_info.param == previous_parm)
             is_candidate = FALSE;
         else
         {
          for (j=0; j<surf2->v_num_knots; j++)
           {
            if (fabs(surf2->v_knots[j] - comm_edge_info.param)
                                       < knot_tol)
                is_candidate = FALSE;
                continue;
           }
         }
         if (is_candidate)
          {
           if (! ((num_parms) % INCR_SIZE))
            {
             if (! num_parms)
              {
               parms = (IGRdouble *) om$malloc (size = INCR_SIZE *
                                                sizeof(IGRdouble));
              }
             else
              {
               parms = (IGRdouble *) om$realloc (ptr = (IGRchar *)parms,
                      size = (num_parms + INCR_SIZE) * sizeof(IGRdouble));
              }
            }
           parms[num_parms] = comm_edge_info.param;
           num_parms++; 
           previous_parm = comm_edge_info.param; 
          }
      }
    }
   if (num_parms)
   {
    stat_OM = om$send(msg = message EMSsubbs.EMmove_class (&msg,
                            my_env, &new_surf),
                      targetid = com_surf_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMmove_class");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

    mul = surf1->v_order-1;
    stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                             NULL, NULL, num_parms, parms, 
                            mul, 0, FALSE, TRUE, &chg_id),
                      targetid = new_surf);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMinsktln");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);
   }
   num_parms = 0; 
   parms = NULL;

   for (i=0; i<surf2->v_num_knots; i++)
    {
     if ((surf2->v_knots[i]>=parm2[0] && surf2->v_knots[i]<=parm2[1]) ||
         (surf2->v_knots[i]>=parm2[1] && surf2->v_knots[i]<=parm2[0]))
      {
         my_edge_info.span_inx = 0;
         my_edge_info.param = (com_loc == 2) ? 1 - surf2->v_knots[i]:
                                                   surf2->v_knots[i];
        
         my_surf = NULL_OBJID;
         stat_OM = om$send(msg = message EMSedge.EMtwin_crv_parm(&msg,
                                 &my_edge_info, &comm_edge_info, my_env,
                                 my_loc, &my_surf, &comm_surf),
                           p_chanselect = &to_common_edge);
         EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMtwin_crv_parm");
         EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);
         is_candidate = TRUE;

         comm_edge_info.param = (my_loc == 2) ? 1-comm_edge_info.param :
                                                comm_edge_info.param;

         if (fabs(comm_edge_info.param - parm1[0]) <= knot_tol)
             comm_edge_info.param = parm1[0];
         else
         if (fabs(comm_edge_info.param - parm1[1]) <= knot_tol)
             comm_edge_info.param = parm1[1];

         if (comm_edge_info.param == previous_parm)
             is_candidate = FALSE;
         else
         {
          for (j=0; j<surf1->v_num_knots; j++)
           {
            if (fabs(surf1->v_knots[j] - comm_edge_info.param)
                                       < knot_tol)
                is_candidate = FALSE;
                continue;
           }
         }
         if (is_candidate)
          {
           if (! ((num_parms) % INCR_SIZE))
            {
             if (! num_parms)
              {
               parms = (IGRdouble *) om$malloc (size = INCR_SIZE *
                                                sizeof(IGRdouble));
              }
             else
              {
               parms = (IGRdouble *) om$realloc (ptr = (IGRchar *)parms,
                      size = (num_parms + INCR_SIZE) * sizeof(IGRdouble));
              }
            }
           parms[num_parms] = comm_edge_info.param;
           num_parms++; 
           previous_parm = comm_edge_info.param; 
          }
      }
    }
   if (num_parms)
   {
    stat_OM = om$send(msg = message EMSsubbs.EMmove_class (&msg,
                            my_env, &new_surf),
                      targetid = my_surf_id);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMmove_class");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);

    mul = surf2->v_order-1;
    stat_OM = om$send(msg = message EMSgenbs.EMinsktln(&msg, my_env,
                             NULL, NULL, num_parms, parms,
                            mul, 0, FALSE, TRUE, &chg_id),
                      targetid = new_surf);
    EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMinsktln");
    EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_SurfaceError, wrapup);
   }
   break;

  } /* switch */

/* set the EMED_COMPATIBLE property ON for me and my common edge */

ME.EMSedge->ed_props |= EMED_COMPATIBLE;
stat_OM = om$send(msg = message EMSedge.EMset_props (&msg,
                        EMED_COMPATIBLE, EMS_O_ON),
                  p_chanselect = &to_common_edge);
EMomerr_hndlr(stat_OM, wrapup, "EMedmk_cmptl.EMset_props");
EMerr_hndlr(EMis_error(msg), *EMmsg, EMS_E_EdgeError, wrapup);

wrapup:

   if(surf1) om$dealloc(ptr = surf1);
   if(surf2) om$dealloc(ptr = surf2);
   if(parms) om$dealloc(ptr = parms);
    
   return(stat_OM);
}

end implementation EMSedge;
