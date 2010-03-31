/* ###################   APOGEE COMPILED   ################## */
/*
    gupta : 09/28/88 : Creation
    Sudha   07/08/93   Modified for BSprototypes ansification

*/

class implementation EMSedge;

#include "EMS.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "emsmacros.h"
#include "emssfint.h"
#include "EMSopt.h"
#include "EMSlmdef.h"
#include "EMSlm.h"
#include "bsprptonsf.h"
#include "bsmdistptsf.h"

extern GRclassid OPP_EMSlinedge_class_id;
extern GRclassid OPP_EMSbsedge_class_id;

IGRint EMfix_two_edges (EMmsg,
                        my_env,
                        my_info,
                        edge_index,
                        surface_id,
                        surface_geom,
                        parting_point,
                        edge1,
                        edge2,
                        partol)

IGRlong                  *EMmsg;
struct GRmd_env          *my_env;
struct EMedge_round_info *my_info;
IGRint                   *edge_index;
GRobjid                  surface_id;
struct IGRbsp_surface    *surface_geom;
IGRpoint                 parting_point;
GRobjid                  edge1, edge2;
struct EMSpartolbasis    *partol;
 
{
  IGRlong               stat_OM, msg;
  IGRlong               blksize;
  IGRint                location;
  IGRushort     option;
  IGRboolean            at_stop1, at_stop2,
                        status, onSurf;
  IGRdouble             ed1_begpt[2], ed1_endpt[2];
  IGRdouble             ed2_begpt[2], ed2_endpt[2];
  IGRdouble             ed1_param[2], ed2_param[2];
  IGRdouble             parting_parm[2], comm_parm[2];
  IGRdouble             d1, d2, dist;
  IGRpoint              base_point;
  GRclassid             classid1, classid2;
  struct GRid           i_edge, j_edge;
  struct EMSproj_info   proj_info1, proj_info2,
                        proj_info3, proj_info4,
                        proj_info5, proj_info6;
  struct EMSsfintedpar  inters;
  OM_S_CHANSELECT       to_common_edge; 

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);
  if (! (1 & stat_OM)) goto wrapup;

  blksize = 2*sizeof (IGRdouble);

  if (surface_id == my_info[edge_index[0]].surface_id)
   {
    stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, ed1_begpt,
                            ed1_endpt, NULL, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = my_info[edge_index[0]].edge_id);
   }
  else
   {
    stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, ed1_begpt,
                            ed1_endpt, NULL, NULL, NULL),
                      senderid = my_info[edge_index[0]].edge_id,
                      p_chanselect = &to_common_edge);
   }
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

  if (surface_id == my_info[edge_index[1]].surface_id)
   {
    stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, ed2_begpt,
                            ed2_endpt, NULL, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = my_info[edge_index[1]].edge_id);
   }
  else
   {
    stat_OM = om$send(msg = message EMSedge.EMendpts(&msg, ed2_begpt,
                            ed2_endpt, NULL, NULL, NULL),
                      senderid = my_info[edge_index[1]].edge_id,
                      p_chanselect = &to_common_edge);
   }
  EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

  status = BSprptonsf(&msg, surface_geom, parting_point, &parting_parm[0],
                     &parting_parm[1], &onSurf);
  if (! onSurf)
   {
    status = BSmdistptsf (&msg, surface_geom, parting_point,
                          &parting_parm[0], &parting_parm[1], base_point,
                          &dist);
   }
  EMerr_hndlr(! status || msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  d1 = EM2ddistptpt(ed1_begpt, ed2_endpt);
  d2 = EM2ddistptpt(ed1_endpt, ed2_begpt);

  if ((d1 <= partol->tol) && (d2 <= partol->tol))
   {
    if (EM2ddistptpts(ed1_begpt, parting_parm) <
        EM2ddistptpts(ed1_endpt, parting_parm))
     {
      OM_BLOCK_MOVE (ed1_endpt, ed1_param, blksize);
      OM_BLOCK_MOVE (ed2_begpt, ed2_param, blksize);
      OM_BLOCK_MOVE (ed1_begpt, comm_parm, blksize);
     }
    else
     {
      OM_BLOCK_MOVE (ed1_begpt, ed1_param, blksize);
      OM_BLOCK_MOVE (ed2_endpt, ed2_param, blksize);
      OM_BLOCK_MOVE (ed1_endpt, comm_parm, blksize);
     }
   }
  else
   {
    if (d1 < d2)
     {
      OM_BLOCK_MOVE (ed1_endpt, ed1_param, blksize);
      OM_BLOCK_MOVE (ed2_begpt, ed2_param, blksize);
      OM_BLOCK_MOVE (ed1_begpt, comm_parm, blksize);
     }
    else
     {
      OM_BLOCK_MOVE (ed1_begpt, ed1_param, blksize);
      OM_BLOCK_MOVE (ed2_endpt, ed2_param, blksize);
      OM_BLOCK_MOVE (ed1_endpt, comm_parm, blksize);
     }
   }
 
  stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, parting_parm,
                          1, &proj_info1, NULL, partol),
                    senderid = NULL_OBJID,
                    targetid = edge1);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, parting_parm,
                          1, &proj_info2, NULL, partol),
                    senderid = NULL_OBJID,
                    targetid = edge2);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, ed1_param,
                          1, &proj_info3, NULL, partol),
                    senderid = NULL_OBJID,
                    targetid = edge1);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, comm_parm,
                          1, &proj_info5, NULL, partol),
                    senderid = NULL_OBJID,
                    targetid = edge1);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, comm_parm,
                          1, &proj_info6, NULL, partol),
                    senderid = NULL_OBJID,
                    targetid = edge2);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  if (proj_info5.param.span_inx == proj_info3.param.span_inx)
   {
    at_stop1 = (proj_info3.param.param <= proj_info5.param.param) ? TRUE :
                                                                    FALSE;
   }
  else
   {
    at_stop1 = (proj_info3.param.span_inx < proj_info5.param.span_inx) ?
                                                           TRUE : FALSE;
   }

  stat_OM = om$send(msg = message EMSedge.EMptproject (&msg, ed2_param,
                          1, &proj_info4, NULL, partol),
                    senderid = NULL_OBJID,
                    targetid = edge2);
  EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);

  if (proj_info6.param.span_inx == proj_info4.param.span_inx)
   {
    at_stop2 = (proj_info4.param.param <= proj_info6.param.param) ?
                                                      TRUE : FALSE;
   }
  else
   {
    at_stop2 = (proj_info4.param.span_inx < proj_info6.param.span_inx) ?
                                                           TRUE : FALSE;
   }

  if (at_stop1 == at_stop2)
   {
    if ((proj_info5.param.span_inx == proj_info3.param.span_inx) &&
        (proj_info5.param.param == proj_info3.param.param))
     {
      at_stop1 = (at_stop2) ? FALSE : TRUE;
     }
    else
    if ((proj_info6.param.span_inx == proj_info4.param.span_inx) &&
        (proj_info6.param.param == proj_info4.param.param))
     {
      at_stop2 = (at_stop1) ? FALSE : TRUE;
     }
   }

  stat_OM = om$get_classid (osnum = my_env->md_id.osnum, objid = edge1,
                            p_classid = &classid1);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = om$get_classid (osnum = my_env->md_id.osnum, objid = edge2,
                            p_classid = &classid2);
  if (! (1 & stat_OM)) goto wrapup;

  if (EM2ddistptpt(proj_info1.proj_pt, proj_info2.proj_pt) >=
      partol->tol)
   {
    i_edge.objid = edge1; i_edge.osnum = my_env->md_id.osnum;
    j_edge.objid = edge2; j_edge.osnum = my_env->md_id.osnum;

    if ((classid1 == OPP_EMSlinedge_class_id) && 
        (classid2 == OPP_EMSlinedge_class_id))
         goto avoid_bad_inters;

    EMtrim_two_edges (&msg,
                      &i_edge,
                      &j_edge,
                      at_stop1,
                      at_stop2,
                      &partol->tol);
    EMerr_hndlr(! (1 & msg), *EMmsg, msg, wrapup);
    if (msg == EMS_I_NoIntersection) goto avoid_bad_inters;
   }
  else
   {
    avoid_bad_inters:

    if ((classid1 == OPP_EMSlinedge_class_id) &&
        (classid2 == OPP_EMSbsedge_class_id))
     {
      inters.intloc = EMScvint_middle;
      inters.edgeid = edge2;
      inters.info = NULL;
      inters.next = NULL;
      inters.point[0] = proj_info2.proj_pt[0]; 
      inters.point[1] = proj_info2.proj_pt[1];
      inters.edgepar.param = proj_info2.param.param;
      inters.edgepar.span_inx = proj_info2.param.span_inx;

      stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                               &inters, at_stop2),
                         senderid = NULL_OBJID,
                         targetid = edge2); 
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

      stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                              (at_stop2) ? NULL : comm_parm,
                              (at_stop2) ? comm_parm : NULL,
                              NULL, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = edge2);
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

      inters.intloc = EMScvint_middle;
      inters.edgeid = edge1;
      inters.info = NULL;
      inters.next = NULL;
      inters.point[0] = comm_parm[0];
      inters.point[1] = comm_parm[1];
      inters.edgepar.param = proj_info1.param.param;
      inters.edgepar.span_inx = proj_info1.param.span_inx;

      stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                               &inters, at_stop1),
                         senderid = NULL_OBJID,
                         targetid = edge1); 
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
     }
    else if ((classid1 == OPP_EMSbsedge_class_id) &&
        (classid2 == OPP_EMSlinedge_class_id))
     {
      inters.intloc = EMScvint_middle;
      inters.edgeid = edge1;
      inters.info = NULL;
      inters.next = NULL;
      inters.point[0] = proj_info1.proj_pt[0]; 
      inters.point[1] = proj_info1.proj_pt[1];
      inters.edgepar.param = proj_info1.param.param;
      inters.edgepar.span_inx = proj_info1.param.span_inx;

      stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                               &inters, at_stop1),
                         senderid = NULL_OBJID,
                         targetid = edge1); 
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

      stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                              (at_stop1) ? NULL : comm_parm,
                              (at_stop1) ? comm_parm : NULL,
                              NULL, NULL, NULL),
                        senderid = NULL_OBJID,
                        targetid = edge1);
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

      inters.intloc = EMScvint_middle;
      inters.edgeid = edge2;
      inters.info = NULL;
      inters.next = NULL;
      inters.point[0] = comm_parm[0];
      inters.point[1] = comm_parm[1];
      inters.edgepar.param = proj_info2.param.param;
      inters.edgepar.span_inx = proj_info2.param.span_inx;

      stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                               &inters, at_stop2),
                         senderid = NULL_OBJID,
                         targetid = edge2); 
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);
     }
    else
     {
      inters.intloc = EMScvint_middle;
      inters.edgeid = edge1;
      inters.info = NULL;
      inters.next = NULL;
      inters.point[0] = proj_info1.proj_pt[0]; 
      inters.point[1] = proj_info1.proj_pt[1];
      inters.edgepar.param = proj_info1.param.param;
      inters.edgepar.span_inx = proj_info1.param.span_inx;

      stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                               &inters, at_stop1),
                         senderid = NULL_OBJID,
                         targetid = edge1); 
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

      inters.intloc = EMScvint_middle;
      inters.edgeid = edge2;
      inters.info = NULL;
      inters.next = NULL;
      inters.point[0] = proj_info1.proj_pt[0]; 
      inters.point[1] = proj_info1.proj_pt[1];
      inters.edgepar.param = proj_info2.param.param;
      inters.edgepar.span_inx = proj_info2.param.span_inx;

      stat_OM = om$send (msg = message EMSedge.EMalter_geometry (&msg,
                               &inters, at_stop2),
                         senderid = NULL_OBJID,
                         targetid = edge2); 
      EMerr_hndlr (! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

      if ((classid1 == OPP_EMSbsedge_class_id) &&
          (classid2 == OPP_EMSbsedge_class_id))
       {
        stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                                (at_stop1) ? NULL : ed1_param,
                                (at_stop1) ? ed1_param : NULL,
                                NULL, NULL, NULL),
                          senderid = NULL_OBJID,
                          targetid = edge1);
        EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

        stat_OM = om$send(msg = message EMSedge.EMendpts(&msg,
                                (at_stop2) ? NULL : ed2_param,
                                (at_stop2) ? ed2_param : NULL,
                                NULL, NULL, NULL),
                          senderid = NULL_OBJID,
                          targetid = edge2);
        EMerr_hndlr(!(1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError,wrapup);

        if (EM2ddistptpt(ed1_param, ed2_param) > partol->tol)
         {
          option = NULL | EMS_ROUND_OPR;

          base_point[0] = ed1_param[0];
          base_point[1] = ed1_param[1];
          base_point[2] = 0.0;

          location = (at_stop2) ? END : BEGIN;

          stat_OM = om$send(msg = message EMSedge.EMextend_geom (&msg,
                                  base_point, &location, TRUE, NULL,
                                  NULL, NULL, partol, option, NULL,
                                  surface_geom, NULL, NULL),
                            senderid = NULL_OBJID,
                            targetid = edge2);
          EMerr_hndlr(!(1 & stat_OM & msg),*EMmsg,EMS_E_EdgeError,wrapup);
         }
       }
     }
   }

wrapup:

  EMWRAPUP (*EMmsg, stat_OM, "EMfix_two_edges");
  return (stat_OM);
}

end implementation EMSedge;
