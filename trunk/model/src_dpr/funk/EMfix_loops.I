/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfround;

#include "EMS.h"
#include "EMSlm.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsmacros.h"
#include "emsgeteddef.h"
#include "EMSerrordef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "msmacros.h"
#include "ECmsg.h"

%safe
static IGRint EMsm_reverse_the_screwed_up_loop();
%endsafe

#define EM2dbxdiff(bx1, bx2, tol) \
                  (((fabs((bx1)[0]-(bx2)[0]+tol) <= tol) && \
                    (fabs((bx1)[1]-(bx2)[1]+tol) <= tol) && \
                    (fabs((bx1)[2]-(bx2)[2]-tol) <= tol) && \
                    (fabs((bx1)[3]-(bx2)[3]-tol) <= tol)) ? FALSE : TRUE)

from EMSedge import EMpt_location,
                    EMget_sf_edges,
                    EMget_props,
                    EMreverse,
                    EMgetrange,
                    EMptatpr,
                    EMendpts,
                    EMshrink_geom;
from EMSloop import EMget_props,
                    EMnext_edge; 
from EMSboundary import EMget_objid;

#argsused
IGRlong EMfix_loops(EMmsg,
                    num_imp_loops,
                    loop_bnd_info,
                    c_loop,
                    partol,
                    my_env,
                    end_pts)

IGRlong                *EMmsg;
IGRint                 *num_imp_loops;
struct EMboundary_info **loop_bnd_info;
IGRboolean             *c_loop;
struct EMSpartolbasis  *partol;
struct GRmd_env        *my_env;
IGRdouble              *end_pts;

{
 IGRlong                stat_OM, msg, msg1;
 IGRushort      lp_prop, ed_prop;
 IGRint                 i, j, k;
 IGRint                 index;
 IGRint                 num_ed;
 IGRboolean             same, my_stop;
 IGRboolean             change_geometry;
 IGRdouble              ed_parms[2], saved_dist;
 IGRdouble              i_range[4], j_range[4];
 extern IGRdouble       fabs();
 GRobjid                beg_edge, end_edge;
 struct GRid            previous_edge, next_edge;
 struct GRid            i_edge, j_edge;
 struct EMSptloc_info   pt_location, other_pt_loc;
 struct EMSedgebound    bound[2], mid_param, pt_param;
 OM_S_CHANSELECT        to_edges;

/*------------------------------------------------------------------*/

 *EMmsg = EMS_S_Success;
 stat_OM = OM_S_SUCCESS;
 
 ex$message(msgnumb = EMS_S_TrimmingEdges);

 *c_loop = FALSE;
 stat_OM = EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);
 if (! (1 & stat_OM)) goto wrapup;

 for (i=0; i<(*num_imp_loops); i++)
  {
   if (loop_bnd_info[i]->bnd_type == EMS_VERTEX_BND)
    {
     change_geometry = FALSE;
     for (k=0; k<2; k++)
      {
       saved_dist = 9999;
       for (j=0; j<(*num_imp_loops); j++)
        {
         if((i != j) && (loop_bnd_info[j]->bnd_type == EMS_EDGE_BND))
          {
           change_geometry = TRUE;
           pt_location.num_located_edges = 0;
           pt_location.location = EMS_L_UNKNWN;
           pt_location.options = NULL;

           stat_OM = om$send (msg = message EMSedge.EMpt_location (&msg,
                                    &(loop_bnd_info[i]->end_pts[k*2]),
                                    &pt_location,
                                    NULL,
                                    partol),
                              senderid = loop_bnd_info[j]->loop_id,
                              p_chanselect = &to_edges);
           EMerr_hndlr(!(1 &stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

           if (pt_location.edge[0].nst_pt.dist < saved_dist)
            {
             index = j;
             saved_dist = pt_location.edge[0].nst_pt.dist;
             pt_param.span_inx =pt_location.edge[0].nst_pt.param.span_inx;
             pt_param.param = pt_location.edge[0].nst_pt.param.param;
            }
           if ((pt_location.location == EMS_L_ONEDGE) ||
               (pt_location.location == EMS_L_ONVRTX))
               break;
          }                /* if (i != j)                */
        }                  /* for (j=0 to num_imp_loops) */
       if (change_geometry)
        {
         stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, NULL,
                                 NULL, bound, &bound[1], NULL),
                           senderid = loop_bnd_info[i]->loop_id,
                           p_chanselect = &to_edges);
         EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg, EMS_E_EdgeError,wrapup);

         if (bound[0].span_inx == bound[1].span_inx)
             mid_param.span_inx = bound[0].span_inx;
         else
             mid_param.span_inx =
                       (IGRint) (bound[0].span_inx + bound[1].span_inx)/2;

         mid_param.param = (bound[0].param + bound[1].param) / 2;

         stat_OM = om$send(msg = message EMSedge.EMptatpr(&msg, 1,
                                 &mid_param, NULL, ed_parms),
                           senderid = loop_bnd_info[i]->loop_id,
                           p_chanselect = &to_edges);
         EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

         other_pt_loc.num_located_edges = 0;
         other_pt_loc.location = EMS_L_UNKNWN;
         other_pt_loc.options = NULL;

         stat_OM = om$send (msg = message EMSedge.EMpt_location (&msg,
                                  ed_parms,
                                  &other_pt_loc,
                                  NULL,
                                  partol),
                            senderid = loop_bnd_info[index]->loop_id,
                            p_chanselect = &to_edges);
         EMerr_hndlr(!(1 &stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

         if ((other_pt_loc.edge[0].nst_pt.param.span_inx <
              pt_param.span_inx) ||
            ((other_pt_loc.edge[0].nst_pt.param.span_inx ==
              pt_param.span_inx) &&
            (other_pt_loc.edge[0].nst_pt.param.param < pt_param.param)))
          {
           my_stop = FALSE;
          }
         else
          {
           my_stop = TRUE;
           
           if  ((other_pt_loc.edge[0].nst_pt.param.span_inx ==
                 pt_param.span_inx) && 
               (other_pt_loc.edge[0].nst_pt.param.param <= partol->tol) &&
               (pt_param.param <= partol->tol))
            my_stop = FALSE;
          }
         stat_OM = om$send (msg = message EMSedge.EMshrink_geom(
                                  &msg,
                                  my_stop,
                                  loop_bnd_info[i]->loop_id,
                                  (k) ? TRUE : FALSE,
                                  partol),
                            senderid = loop_bnd_info[index]->loop_id,
                            p_chanselect = &to_edges);
         EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError, wrapup);
        }                  /* if (change_geometry)       */
      }                    /* for (k=0 to 2)             */
    }                  
  }                        /* for (i=0 to num_imp_loops) */


 stat_OM = om$send(msg = message EMSloop.EMget_props(&msg, &lp_prop),
                   senderid = NULL_OBJID,
                   targetid = loop_bnd_info[0]->rnd_loop_id);
 EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

 *c_loop = (! (lp_prop & EMLP_PLOOP)) ? TRUE : FALSE;
 
 for (i=0; i<(*num_imp_loops); i++)
  {
   if (loop_bnd_info[i]->bnd_type == EMS_EDGE_BND)
    {
     /* If rnd_edge_id is NULL_OBJID, then it is filletting */
     if (loop_bnd_info[i]->rnd_edge_id != NULL_OBJID)  
     {    
     stat_OM = EMsend_loops (&msg, message EMSloop.EMnext_edge (&msg1,
                             EMGetEd_Previous,
                             loop_bnd_info[i]->rnd_edge_id,
                             &previous_edge.objid),
                             loop_bnd_info[i]->rnd_edge_id, 0, 0,
                             EMLP_ACTIVE, NULL, NULL);
     EMerr_hndlr(! (1 & msg & msg1), *EMmsg, EMS_E_LoopError, wrapup);

     stat_OM = om$send(msg = message EMSedge.EMget_props(&msg, &ed_prop),
                       senderid = NULL_OBJID,
                       targetid = previous_edge.objid);
     EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

     if ((ed_prop & EMED_NATURAL) && (ed_prop & EMED_DEGENERATE))
      {
       stat_OM = EMsend_loops (&msg, message EMSloop.EMnext_edge (&msg1,
                               EMGetEd_Previous, previous_edge.objid,
                               &beg_edge),
                               previous_edge.objid, 0, 0,
                               EMLP_ACTIVE, NULL, NULL);
       EMerr_hndlr(! (1 & msg & msg1), *EMmsg, EMS_E_LoopError, wrapup);

       stat_OM = om$send(msg = message EMSedge.EMendpts (&msg,
                               loop_bnd_info[i]->point_in_area, NULL,NULL,
                               NULL, NULL),
                         senderid = NULL_OBJID,
                         targetid = beg_edge);
       EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
      }
     else
      {
       stat_OM = EMsend_loops (&msg, message EMSloop.EMnext_edge (&msg1,
                               EMGetEd_Next,
                               loop_bnd_info[i]->rnd_edge_id,
                               &next_edge.objid),
                               loop_bnd_info[i]->rnd_edge_id, 0, 0,
                               EMLP_ACTIVE, NULL, NULL);
       EMerr_hndlr(! (1 & msg & msg1), *EMmsg, EMS_E_LoopError, wrapup);

       stat_OM = om$send(msg = message EMSedge.EMget_props(&msg,&ed_prop),
                         senderid = NULL_OBJID,
                         targetid = next_edge.objid);
       EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

       if ((ed_prop & EMED_NATURAL) && (ed_prop & EMED_DEGENERATE))
        {
         stat_OM = EMsend_loops (&msg, message EMSloop.EMnext_edge (&msg1,
                                 EMGetEd_Next, next_edge.objid,
                                 &end_edge),
                                 next_edge.objid, 0, 0,
                                 EMLP_ACTIVE, NULL, NULL);
         EMerr_hndlr(! (1 & msg & msg1), *EMmsg, EMS_E_LoopError, wrapup);

         stat_OM = om$send(msg = message EMSedge.EMendpts (&msg,
                                 NULL, loop_bnd_info[i]->point_in_area,
                                 NULL, NULL, NULL),
                           senderid = NULL_OBJID,
                           targetid = end_edge);
         EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
        }
      }
     } /*if(.. .rnd_edge_id != NULL_OBJID) */

     pt_location.num_located_edges = 0;
     pt_location.location = EMS_L_UNKNWN;
     pt_location.options = NULL;

     stat_OM = om$send (msg = message EMSedge.EMpt_location (&msg,
                              loop_bnd_info[i]->point_in_area,
                              &pt_location,
                              NULL,
                              partol),
                        senderid = loop_bnd_info[i]->loop_id,
                        p_chanselect = &to_edges);
     EMerr_hndlr(!(1 &stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
     
     /************ SM Feb 17, 1992
      New code added (activated by the boolean flag). See new function
      and related comments at the end of this file.
     **************/
     if (pt_location.location == EMS_L_LEFT)
      {
	IGRboolean old_code_active = FALSE;

       if(old_code_active)
        stat_OM = om$send (msg = message EMSedge.EMreverse (&msg),
                          senderid = loop_bnd_info[i]->loop_id,
                          p_chanselect = &to_edges);
       else
        stat_OM = EMsm_reverse_the_screwed_up_loop(EMmsg, 
		  loop_bnd_info[i]->loop_id, &to_edges);
       EMerr_hndlr(!(1 &stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
      }
    }
  }

 for (i=0; i<(*num_imp_loops); i++)
  {
   if (loop_bnd_info[i]->bnd_type == EMS_EDGE_BND)
    {
     stat_OM = om$send(msg = message EMSedge.EMgetrange(&msg, i_range,
                             NULL),
                       senderid = loop_bnd_info[i]->loop_id,
                       p_chanselect = &to_edges);
     EMerr_hndlr(!(1 &stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

     EM2dbxinc(i_range, partol->tol);

     for (j=0; j<(*num_imp_loops); j++)
      {
       if ((i != j) && (loop_bnd_info[j]->bnd_type == EMS_EDGE_BND))
        {
         stat_OM = om$send(msg = message EMSedge.EMgetrange(&msg, j_range,
                                 NULL),
                           senderid = loop_bnd_info[j]->loop_id,
                           p_chanselect = &to_edges);
         EMerr_hndlr(!(1 &stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);

         if ((EM2dbxbxint (i_range, j_range)) &&
             (EM2dbxdiff (i_range, j_range, partol->tol)))
          {
           stat_OM = om$send (msg = message EMSedge.EMget_sf_edges(&msg,
                                    EMS_EDGE_BEG_PT, &previous_edge,
                                    &num_ed),
                              senderid = NULL_OBJID,
                              targetid = loop_bnd_info[i]->rnd_edge_id);
           EMerr_hndlr(!(1&stat_OM&msg), *EMmsg, EMS_E_EdgeError, wrapup);

           stat_OM = om$send (msg = message EMSedge.EMget_sf_edges(&msg,
                                    EMS_EDGE_END_PT, &next_edge, &num_ed),
                              senderid = NULL_OBJID,
                              targetid = loop_bnd_info[i]->rnd_edge_id);
           EMerr_hndlr(!(1&stat_OM&msg), *EMmsg, EMS_E_EdgeError, wrapup);
          
           if ((loop_bnd_info[j]->rnd_edge_id == previous_edge.objid) ||
               (loop_bnd_info[j]->rnd_edge_id == next_edge.objid))
            {
	     IGRdouble edge_endpt[2][2][2], /* 2 edges - 2 end pts - 2 uvs */
		       dist[4], mindist;
	     IGRint inx1, inx2 = 0;
	     IGRboolean at_stop1, at_stop2;
	
	/************ SM Feb 13, 1992.
	     The flag 'same' is later used in deciding which which end of
	     the edges are being trimmed. This is assuming that both the
	     edges, each coming from an independent loop share an end-to-end
	     continuity. This may not be necessarily true. Hence an end point
	     proximity check is done to decide which repective end of an
	     edge should be trimmed.
	****************************/
	/*********************
             same =  (loop_bnd_info[j]->rnd_edge_id == next_edge.objid) ?
                                                            TRUE : FALSE;
        **********************/

             stat_OM = om$get_objid_at_index(
                                       objid = loop_bnd_info[i]->loop_id,
                                       p_chanselect = &to_edges,
                                       index = 0,
                                       objidaddr = &i_edge.objid,
                                       osnumaddr = &i_edge.osnum);
             EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

             stat_OM = om$get_objid_at_index(
                                       objid = loop_bnd_info[j]->loop_id,
                                       p_chanselect = &to_edges,
                                       index = 0,
                                       objidaddr = &j_edge.objid,
                                       osnumaddr = &j_edge.osnum);
             EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_OMerror, wrapup);

	     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, 
		       edge_endpt[0][0], edge_endpt[0][1], NULL, NULL, NULL), 
		       targetid = i_edge.objid, senderid = NULL_OBJID);
             EMerr_hndlr(!(1&stat_OM&msg), *EMmsg, EMS_E_EdgeError, wrapup);
	     stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, 
		       edge_endpt[1][0], edge_endpt[1][1], NULL, NULL, NULL), 
		       targetid = j_edge.objid, senderid = NULL_OBJID);
             EMerr_hndlr(!(1&stat_OM&msg), *EMmsg, EMS_E_EdgeError, wrapup);

	     /* Calculate distances in the following order.
	        Beg1 Beg2
	        Beg1 End2
	        End1 Beg2
	        End1 End2
	     */
	     inx2 = 0;
	     for(inx1 = 0; inx1<2; inx1++)
              {
	
	       dist[inx2++] = EM2ddistptpt(edge_endpt[0][inx1], 
					   edge_endpt[1][0]);
	       dist[inx2++] = EM2ddistptpt(edge_endpt[0][inx1], 
					   edge_endpt[1][1]);
              }             
     
	     /* Get the closest combination of endpts.
	     */
             mindist = dist[0];
             inx2 = 0;
             for(inx1 = 1; inx1<4; inx1++)
              if(dist[inx1] < mindist)
               {
	        mindist = dist[inx1];
	        inx2 = inx1;
               }

              if(inx2 == 0)
               {
	        at_stop1 = FALSE;
	        at_stop2 = FALSE;
	       }
              else if(inx2 == 1)
	       {
	        at_stop1 = FALSE;
	        at_stop2 = TRUE;
	       }
              else if(inx2 == 2)
               {
	        at_stop1 = TRUE;
	        at_stop2 = FALSE;
	       }
              else if(inx2 == 3)
               {
	        at_stop1 = TRUE;
	        at_stop2 = TRUE;
	       }
	      else
	       {
	        *EMmsg = EMS_E_EdgeError;
	        goto wrapup;
               }

/********************* SM Feb 13, 1992
             EMtrim_two_edges (&msg,
                               &i_edge,
                               &j_edge,
                               (same) ? TRUE : FALSE,
                               (same) ? FALSE : TRUE,
                               &partol->tol);
*************************************/
             EMtrim_two_edges (&msg,
                               &i_edge,
                               &j_edge,
                               at_stop1,
                               at_stop2,
                               &partol->tol);

             EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
            }
          }                /* bxbxint                    */
        }                  /* i != j & ---               */
      }                    /* for j=0 to num_imp_loops   */
    }            
  }                        /* for (i=0 to num_imp_loops) */


 for (i=0; i<(*num_imp_loops); i++)
  {
   stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                           &end_pts[4*i],
                           &end_pts[(4*i + 2)],
                           NULL,NULL,NULL),
                     senderid = loop_bnd_info[i]->loop_id,
                     p_chanselect = &to_edges);
   EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
  }

 ex$message ( msgnumb = EMS_S_ClearStatusField);

 wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMSsfround.EMfix_loops");
  return (stat_OM);
}



/* The following function is a patch for the old rounding code. The edge
   reversal vis-a-vis loop reversal is not correct, as done in this
   function. Ideally, when ALL the edges of a loop are reversed, it should
   be done by sending the message EMreverse to the loop. This may not matter
   for loops with only one edge. But for loops with multiple edges, reversing
   the edges directly will produce incorrect topology.

   My patched up solution is -

   if the loop has only one edge, do what was being done earlier (send reverse
    message to the edge).
   if the loop has multiple edges, reverse the edges AND reverse the channel
   connections. In this case, I do not want to mark the loop as being reversed
   for fear of breaking somthing else in the old round flow.

   SM Feb 17, 1992.
*/
#define StaticBuf 10

static IGRint EMsm_reverse_the_screwed_up_loop(EMmsg, loopid, to_edges)
IGRlong *EMmsg;
GRobjid loopid;
OM_S_CHANSELECT *to_edges;
{
 IGRlong		sts = OM_S_SUCCESS;
 OMuint			count, i;
 OM_S_OBJECT_LINKAGE	*screwed_edges = NULL, screwed_edgesbuf[StaticBuf];
 OM_S_CHANSELECT	to_lp;

 *EMmsg = EMS_S_Success;
 
 sts = om$get_channel_count(objid = loopid, p_chanselect = to_edges, 
	count = &count);
 if(!count) goto wrapup;

 sts = om$send (msg = message EMSedge.EMreverse (EMmsg),
       senderid = loopid, p_chanselect = to_edges);

 if(count > 1)
  {
   if(count > StaticBuf)
    screwed_edges = (OM_S_OBJECT_LINKAGE *) om$malloc(size = count *
		   sizeof(OM_S_OBJECT_LINKAGE));
   else
    screwed_edges = screwed_edgesbuf;
   EMerr_hndlr(!screwed_edges, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   sts = om$get_channel_objects(objid = loopid, p_chanselect = to_edges, 
	 list = screwed_edges, size = count, count = &count);
   if(!(1&sts)) goto wrapup;

   sts = om$send(msg = message Root.wild_disconnect(*to_edges), 
	 targetid = loopid, senderid = loopid);
   if(!(1&sts)) goto wrapup;

   sts = EMmake_chanselect(EMSedge_to_owner, &to_lp);
   if(!(1&sts)) goto wrapup;

   /* Traversing the edge list from 0 to n-1 and using NULL as the channel
      index will effectively produce the channel connection as n-1 to 0 on
      a relatively ordered channel.
   */
   for(i=0; i<count; i++)
    {
     sts = om$send(msg = message Root.connect(to_lp, NULL, loopid, 
	   OM_Gw_current_OS, *to_edges, NULL), senderid = loopid, 
	   targetid = screwed_edges[i].S_objid);
     if(!(1&sts)) goto wrapup;
    }
  }

wrapup:
if(screwed_edges && (screwed_edges != screwed_edgesbuf))
 om$dealloc(ptr = screwed_edges);
return(sts);
}
end implementation EMSsfround;
