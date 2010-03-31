class  implementation EMSloop;

/*
  HISTORY
        Nirmal   02/93     Genesis;
	Sudha	07/06/93   Modified for BSprototype ansification
        Hari    07/07/95   Fix for FMR : TR#119525966 .  

*/

#include "EMS.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_S.h"
#include "msmacros.h"
#include "OMmacros.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSlmdef.h"
#include "EMSopt.h"
#include "emsgeteddef.h"
#include "EMSbnddef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "EMSmsgdef.h"
#include "ECcmd.h"
#include "ECmsg.h" 
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsaddraft.h"
#include "emsimpdef.h"
#include "bsvalues.h"
#include  <math.h>
#include "EMSprop.h"
#include "bsdistptpt.h"

extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSloop_class_id;
extern OMuword OPP_EMSlinedge_class_id;

#define FIRST 0
#define SECOND 1

#define START  0
#define STOP   1

void EFget_the_incident_intobjs();

from EMSedge import EMinternalpt, EMxyz_endpt, EMendpts, EMextend_geom,
   EMget_bcxyz_geom;
from EMSsubbs import EMpartolbasis, EMpratpt;
from GRvg import GRgetsize, GRgetgeom;
from EMSloopset import EMtreemod, EMget_loops, EMset_props,  EMsplityourself;

IGRint   EMtrim_adj_surfs(EMmsg,
                    md_env,
                    const_list,
                    num_affect_sfs,
                    org_surfs_info_list,
                    adj_surfs_info_list)

   IGRlong *EMmsg;
   struct GRmd_env *md_env;
   struct GRvg_construct *const_list;
   IGRint *num_affect_sfs ;
   struct EMSadj_surf_info ***org_surfs_info_list;
   struct EMSadj_surf_info ***adj_surfs_info_list;
   {
    IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
    BSrc rc=BSSUCC;
    struct EMSadj_surf_info **adj_sf_info_list= NULL;
    struct EMSadj_surf_info **org_sf_info_list= NULL;
    struct GRid original_sf;
    GRobjid *loop_ids=NULL, parent_id;
    IGRint depth, lp_count;
    IGRint ij, ii,jj, kk;
    OM_S_CHANSELECT to_loopset;
    struct EMSintobj *q_intobj=NULL, *p_intobj=NULL;
    IGRint buff_size=0;
    IGRboolean good = TRUE;
    IGRlong EMregenerate_topology();

    adj_sf_info_list= *adj_surfs_info_list;
    org_sf_info_list= *org_surfs_info_list;
    stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
    EMerr_hndlr (!(1 & stat_OM), *EMmsg, EMS_E_Fail, wrapup);

    ex$message(msgnumb = EMS_S_ProcessingFour);

    for(ii=0;ii< *num_affect_sfs;ii++)
    {
      if(!adj_sf_info_list[ii]->operate)continue;

/** get the list of loops currently imposed on the surface **/
      buff_size = 0;
      depth = MAXINT;
      lp_count = 0;
      stat_OM = om$send( msg = message EMSloopset.EMget_loops(
                    &msg_loc,
                    0,
                    &depth,
                    &loop_ids,
                    NULL,
                    &buff_size,
                    &lp_count),
             p_chanselect = &to_loopset,
             from = 0,
             to = MAXINT,
             senderid = adj_sf_info_list[ii]->myself.objid,
             targetos = adj_sf_info_list[ii]->myself.osnum);

       EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup);

       /* DO THE REGEN STUFF  */
       original_sf.objid = adj_sf_info_list[ii]->copy;
       original_sf.osnum = adj_sf_info_list[ii]->myself.osnum;

/** get the right parent loop. If none is there then  NULL_OBJID **/
       parent_id = NULL_OBJID;
       if(loop_ids)
         parent_id =
          (adj_sf_info_list[ii]->par_loop_no  == -1) ? NULL_OBJID :
            loop_ids[adj_sf_info_list[ii]->par_loop_no];

/** generate and impose topology on surface **/
        if(parent_id == NULL_OBJID)
             adj_sf_info_list[ii]->loop_props|= EMLP_PLOOP;
        EMregenerate_topology(&msg_loc,
                        &org_sf_info_list[ii],
                        &adj_sf_info_list[ii]->my_inters,
                        &parent_id,
                        adj_sf_info_list[ii]->loop_props,
                        const_list);
        EMerr_hndlr (!(1&msg_loc),*EMmsg,EMS_E_OMerror,wrapup);
     }

    if(loop_ids)
      {
      om$dealloc(ptr=loop_ids);
      loop_ids=NULL;
      }


/** TAKING CARE OF EDGE - COMMEDGE BUSINESS ***/

    for(ii=0;ii< *num_affect_sfs;ii++)
      {
      if(!adj_sf_info_list[ii]->operate)continue;
      adj_sf_info_list[ii]->edges =
        (GRobjid *)om$malloc(size= adj_sf_info_list[ii]->num_adjacent *
                                                        sizeof(GRobjid));
      EMerr_hndlr(!adj_sf_info_list[ii]->edges,
                                    *EMmsg, EMS_E_NoDynamicMemory,wrapup);

/** initialize **/
      for(jj=0; jj<adj_sf_info_list[ii]->num_adjacent; jj++)
         adj_sf_info_list[ii]->edges[jj] = NULL_OBJID;
/**
    choose an starting edge which is NOT seam and NOT connected to an
    edge of a  surf which is connected to by another edge in the this loop. 
    'cause these are the problem guys!!!
**/
      for(kk=0; kk<adj_sf_info_list[ii]->num_adjacent; kk++)
        if(org_sf_info_list[ii]->adj_surfs[kk] !=
              org_sf_info_list[ii]->myself.objid)
             {
                good = TRUE;
                for(ij=0; ij<adj_sf_info_list[ii]->num_adjacent; ij++)
                   if( ij!=kk && org_sf_info_list[ii]->adj_surfs[kk] == 
                        org_sf_info_list[ii]->adj_surfs[ij])
                           {
                           good = FALSE;
                           break;
                           }
                if(good)
                   break;
              }

/**
  assign the edges and common (cyclically)  edges by traversing the inters list **/

/* FISRT PART OF CYCLE **/
      q_intobj = adj_sf_info_list[ii]->my_inters->cvs;
      for(jj=kk; jj<adj_sf_info_list[ii]->num_adjacent; jj++)
         {
         if(jj==kk)
         for(p_intobj = adj_sf_info_list[ii]->my_inters->cvs; p_intobj;
                                                    p_intobj= p_intobj->next)
            {
              if( p_intobj->other_intobj_node &&
                  (p_intobj->other_intobj_node->this_obj_node->this_obj.objid
                                         ==
                                         adj_sf_info_list[ii]->adj_surfs[jj] ))
                {
                adj_sf_info_list[ii]->edges[jj] =
                                    p_intobj->this_uvintobj.data.object->objid; 
                /* If this is not a teritiariy edge ***/
                if(adj_sf_info_list[ii]->commedges[jj] == NULL_OBJID)
                  adj_sf_info_list[ii]->commedges[jj] =
                  p_intobj->other_intobj_node->this_uvintobj.data.object->objid;
                break;
                }
            }

         if(p_intobj )
            {
            adj_sf_info_list[ii]->edges[jj] =
                           p_intobj->this_uvintobj.data.object->objid;
            if(adj_sf_info_list[ii]->commedges[jj] == NULL_OBJID)
                {
                 if(p_intobj->other_intobj_node)
                 adj_sf_info_list[ii]->commedges[jj] =
            p_intobj->other_intobj_node->this_uvintobj.data.object->objid;
                }
            p_intobj = p_intobj->next;
            }
         else  if(q_intobj)
            {
            adj_sf_info_list[ii]->edges[jj] =
                            q_intobj->this_uvintobj.data.object->objid;
            if(adj_sf_info_list[ii]->commedges[jj] == NULL_OBJID)
                {
                 if(q_intobj->other_intobj_node)
                    adj_sf_info_list[ii]->commedges[jj] =
                 q_intobj->other_intobj_node->this_uvintobj.data.object->objid;
                 }
            q_intobj = q_intobj->next;
            }
         }


/* REST  OF CYCLE **/
      for(jj=0; jj<kk; jj++)
         {
         if(p_intobj)
            {
            adj_sf_info_list[ii]->edges[jj] =
                           p_intobj->this_uvintobj.data.object->objid;
            if(adj_sf_info_list[ii]->commedges[jj] == NULL_OBJID)
                 if(p_intobj->other_intobj_node)
                 adj_sf_info_list[ii]->commedges[jj] =
            p_intobj->other_intobj_node->this_uvintobj.data.object->objid;
            p_intobj = p_intobj->next;
            }
         else  if(q_intobj)
            {
            adj_sf_info_list[ii]->edges[jj] =
                            q_intobj->this_uvintobj.data.object->objid;
            if(adj_sf_info_list[ii]->commedges[jj] == NULL_OBJID)
                 if(q_intobj->other_intobj_node)
                    adj_sf_info_list[ii]->commedges[jj] =
                 q_intobj->other_intobj_node->this_uvintobj.data.object->objid;
            q_intobj = q_intobj->next;
            }
          }

      }

    for(ii=0;ii< *num_affect_sfs;ii++)
      {
      for(jj=0; jj<adj_sf_info_list[ii]->num_adjacent; jj++)
         {
         if((adj_sf_info_list[ii]->edges[jj] == NULL_OBJID) || 
                      (adj_sf_info_list[ii]->commedges[jj] == NULL_OBJID))
              {
              if(adj_sf_info_list[ii]->comedge_cncv[jj] <= 2)
                 EMerr_hndlr (TRUE,*EMmsg,EMS_E_OMerror,wrapup);
              }
         }
      }

wrapup:
 EMWRAPUP( *EMmsg, stat_OM, "EMtrm_adj_surfs");
 return (stat_OM);
}



 /****************************************************************************
DESCRIPTION:
  This function trims each intobj on the input 'inters' node with respect
  to its adjacent two (previous and next) intobjs and finally constructs
  loops obejcts. It also nests the loop appropriately in the surface's loopset.

IGRlong EMregenerate_topology(msg, info, inters, par_id, loop_props, const_list)
 
  Arguments:

  IGRlong 	  	*msg		- Error return code   - O
  struct EMSinters 	**inters	- Inters node of the  - I/O
			   		  surface on which
			  	  	  topolgy is to be
			  	  	  recreated.
  struct GRid	      	info		- The original surf.  - I
                                          adj sf info list
			  	  	  the topology is
			  	  	  replicated.
  struct GRvg_construct	*const_list	- Construction list   - I


ALGORITHM:

HISTORY:
      Nirmal   02/93  Genesis;
*****************************************************************************/

IGRlong EMregenerate_topology(msg, info, inters, par_id, loop_props, const_list)
IGRlong *msg;
struct EMSadj_surf_info **info;
struct EMSinters **inters;
GRobjid  *par_id;
IGRushort loop_props;
struct GRvg_construct *const_list;

{
  IGRlong stat_OM = OM_S_SUCCESS,
           msg_loc = EMS_S_Success, loc_msg = EMS_S_Success;
  BSrc rc= BSSUCC;
  IGRint iii=0, ii, kk, jj, num_inters, location;
  IGRdouble dist1,dist2, dist, u_par,v_par, base_point[3];
  IGRdouble uvtol, uv[4], cht_tol, vertex_xyz[3], lentol;
  IGRushort  props=NULL;
  IGRboolean  world, split_other,xyz_closed, x_them;
  IGRboolean swap= FALSE,  no_split = FALSE, to_be_reved=TRUE, first_edge=TRUE;
  IGRboolean rev_connect=TRUE;
  GRobjid  edge, edge1, edge2, surf_1, surf_2, loopset_id;
  OMuint  num_lps;
  OM_S_OBJECT_LINKAGE comm_list[1];
  OM_S_CHANSELECT chan_to_loopset, chan_to_surface;

  struct EMSpartolbasis partolb;
  struct EMSsftracedata sftrace;
  struct EMSadj_surf_info *org_info;
  struct GRid org_sf, this_sf;
  struct IGRbsp_surface *org_surf_geom=NULL, *this_surf_geom=NULL;
  struct IGRbsp_surface *surf_1_geom=NULL, *surf_2_geom=NULL;
  struct GRmd_env *env;
  struct EMSpypoint *q_pypt=NULL, *p_pypt, *p_pypt1, *p_pypt2;
  struct EMSpypoint *projpts=NULL, *projpts1=NULL, *projpts2=NULL;
  struct EMSinters *loc_inters;
  struct EMSintobj *p_intobjs[2], *p_intobj=NULL, *p_intobj_rem=NULL,
    *p_intobj_bwd=NULL, *p_intobj_fwd=NULL, *ot_intobj=NULL,
    *ot_intobj_rem=NULL, *tmp_intobj=NULL, *ot_intobj_fwd=NULL,
    *ot_intobj_bwd=NULL, *ot_intobj_next=NULL, *p_intobj_prev=NULL,
    *q_intobj=NULL, *p_intobj_next=NULL;

  void EMmy_create_loop_from_int_group();
  extern void EFget_intersection_points(), EMsplit_sf_intobj_uv();
  IGRlong  EFproject_vertex();
  extern void EMsortpypts();
  extern IGRdouble BSdistptpt();
  IGRboolean BSmdistptsf();
  extern IGRboolean EM2dpycutint(), EMintobj_closed(), EMis_same_dataselect();
  extern void EMpypoint_free(),EMintobj_free(),EMdelintobj();
  void EFrefine_the_intobjs();
  extern IGRboolean EFget_surf_geom();
  extern IGRboolean EFare_surfs_tan();
  IGRboolean EFare_ints_tan();
      void EFget_vertex();


  stat_OM = EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
  stat_OM = EMmake_chanselect (EMSloopset_to_surface, &chan_to_surface);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  org_info =* info;
  p_pypt = NULL;

  loc_inters = *inters;  
  p_intobj = loc_inters->cvs;
  env = const_list->env_info;

  this_sf = loc_inters->this_obj;
  org_sf.objid = org_info->myself.objid;
  org_sf.osnum = org_info->myself.osnum;

  EFget_surf_geom(&msg_loc, env, this_sf.objid, this_sf.osnum, &this_surf_geom);
  EMerr_hndlr (!this_surf_geom, *msg, EMS_E_Fail, ret_end);

  EFget_surf_geom(&msg_loc, env, org_info->myself.objid,
                                                this_sf.osnum, &org_surf_geom);
  EMerr_hndlr (!org_surf_geom, *msg, EMS_E_Fail, ret_end);
       
  world = TRUE;
  stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                                 &env->md_env.matrix_type,
                                 env->md_env.matrix, &world, FALSE,
                                 &partolb.tol),
			  senderid = NULL_OBJID,
			  targetos = this_sf.osnum,
                          targetid = this_sf.objid);
  EMerr_hndlr(! (1 & stat_OM & msg_loc), *msg, EMS_E_SurfaceError, ret_end);

  partolb.in_world = TRUE;
  partolb.is_valid = TRUE;
  partolb.mattyp = &env->md_env.matrix_type;
  partolb.mat = env->md_env.matrix;
  uvtol = partolb.tol;
  BSEXTRACTPAR (&loc_msg, BSTOLCHRDHT, cht_tol);
  BSEXTRACTPAR(&loc_msg, BSTOLLENVEC, lentol);
  p_intobjs[FIRST] = loc_inters->cvs;

  projpts1= (struct EMSpypoint *)om$malloc(size =(sizeof(struct EMSpypoint)));
  EMerr_hndlr(!projpts1 , *msg, EMS_E_NoDynamicMemory, INT_INT);
  projpts2= (struct EMSpypoint *)om$malloc(size = (sizeof(struct EMSpypoint)));
  EMerr_hndlr(!projpts2 , *msg, EMS_E_NoDynamicMemory, INT_INT);
  projpts= (struct EMSpypoint *)om$malloc(size = (sizeof(struct EMSpypoint)));
  EMerr_hndlr(!projpts , *msg, EMS_E_NoDynamicMemory, INT_INT);
  projpts->next=NULL; projpts1->next=NULL; projpts2->next=NULL;
  stat_OM = OM_S_SUCCESS; msg_loc = EMS_S_Success;

  iii=0;
  while (p_intobjs[FIRST])
  {
   p_pypt=NULL; p_pypt1=NULL; p_pypt2=NULL; q_pypt=NULL;

   if(p_intobjs[FIRST]->next)
      p_intobjs[SECOND] = p_intobjs[FIRST]->next;
   else
      p_intobjs[SECOND] =  loc_inters->cvs;

   num_inters=0;
   x_them = TRUE;
   if(!p_intobjs[FIRST] || !p_intobjs[SECOND])
     {
     x_them = FALSE;
     goto SPLIT_EM_NOW;
     }

   if (p_intobjs[0] == p_intobjs[1]) 
         x_them = FALSE;

  if( p_intobjs[0]->other_intobj_node  && p_intobjs[1]->other_intobj_node)
   if((p_intobjs[0]->other_intobj_node->this_uvintobj.datatype == EMSdata_null)
        ||
    (p_intobjs[1]->other_intobj_node->this_uvintobj.datatype == EMSdata_null) )
         x_them = FALSE;

      if(x_them)
      {
        edge1 = org_info->edges[iii];
        if(iii+1 < org_info->num_adjacent)
            edge2 = org_info->edges[iii+1];
        else
            edge2 = org_info->edges[0];

         /** IF EDGE _ INTERSECTION INTERSECTION CASE **/
         /** project appropriate end point of edge on to the intersection **/
         if( (!(p_intobjs[0]->this_uvintobj.datatype==EMSdata_object) &&
             (p_intobjs[1]->this_uvintobj.datatype==EMSdata_object)) ||
             ((p_intobjs[0]->this_uvintobj.datatype==EMSdata_object) &&
            !(p_intobjs[1]->this_uvintobj.datatype==EMSdata_object)) )
          {
             if(p_intobjs[0]->this_uvintobj.datatype==EMSdata_object)
               {
                q_intobj = p_intobjs[1];
                edge= p_intobjs[0]->this_uvintobj.data.object->objid;
                p_intobj = p_intobjs[0];
                first_edge=TRUE;
               }
           else if(p_intobjs[1]->this_uvintobj.datatype==EMSdata_object)
               {
                q_intobj = p_intobjs[0];
                p_intobj = p_intobjs[1];
                edge= p_intobjs[1]->this_uvintobj.data.object->objid;
                first_edge=FALSE;
                }
             if(p_intobj->reversed)
               to_be_reved=TRUE;
             else
                to_be_reved=FALSE;
             /** get the int pt from edge end pts **/
             EFproject_vertex(&msg_loc, env, NULL, q_intobj, NULL, 
                &edge, first_edge, &this_sf, this_surf_geom, to_be_reved,
                     NULL, projpts1, &dist1, &dist2);
              EMerr_hndlr (EMSerror (msg_loc),*msg, EMS_E_Fail, INT_INT);

              if(dist1 > .00001) goto INT_INT;

              if(p_intobjs[0]->this_uvintobj.datatype==EMSdata_object)
                 {
                 p_pypt2 = projpts1;
                 p_pypt2->next=NULL;
                 location = END;
                 }
              else
                 {
                 p_pypt1 = projpts1;
                 p_pypt1->next=NULL;
                 location = BEGIN;
                 }
                goto SPLIT_EM_NOW;
           }
        else if ((p_intobjs[1]->this_uvintobj.datatype==EMSdata_object)
                              && 
              (p_intobjs[0]->this_uvintobj.datatype==EMSdata_object))
           {
           /* both are already imposd edges so  no need to split */
           goto   SPLIT_EM_NOW;
           }

/*** PROJECTING OLD VERTEX TO GET INT POINT FOR TOUCHING INTERSECTIONS *******/ 
   q_intobj= NULL;
   surf_1=NULL_OBJID;
   surf_2=NULL_OBJID;
  if(p_intobjs[0]->other_intobj_node)
      {
       surf_1 = p_intobjs[0]->other_intobj_node->this_obj_node->this_obj.objid; 
       if(surf_1_geom) om$dealloc(ptr= surf_1_geom); surf_1_geom=NULL;
       EFget_surf_geom(&msg_loc, env, surf_1, this_sf.osnum, &surf_1_geom);
       EMerr_hndlr (!surf_1_geom, *msg, EMS_E_Fail, ret_end);
      }

 if(p_intobjs[1]->other_intobj_node)
      {
       surf_2 = p_intobjs[1]->other_intobj_node->this_obj_node->this_obj.objid; 
       if(surf_2_geom) om$dealloc(ptr= surf_2_geom); surf_2_geom=NULL;
       EFget_surf_geom(&msg_loc, env, surf_2, this_sf.osnum, &surf_2_geom);
       EMerr_hndlr (!surf_2_geom, *msg, EMS_E_Fail, ret_end);
      }
       
/** get the vetex xyz point from the edge **/
      if(org_surf_geom->pos_orient != this_surf_geom->pos_orient)
          to_be_reved=TRUE;
      else
          to_be_reved=FALSE;
      q_intobj = p_intobjs[0]->other_intobj_node;
      if(q_intobj)
      {
      rev_connect = EFis_rev_connect(&msg_loc, p_intobjs[0]);
      EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
      tmp_intobj = rev_connect ?  q_intobj->bwd : q_intobj->fwd; 
      }
      if(!tmp_intobj)
         {
         q_intobj = p_intobjs[1]->other_intobj_node;
         if(q_intobj)
         {
         rev_connect = EFis_rev_connect(&msg_loc, p_intobjs[1]);
         EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
         tmp_intobj = rev_connect ?  q_intobj->fwd : q_intobj->bwd; 
         }
         }
      q_intobj = tmp_intobj ?  tmp_intobj: p_intobjs[0];

/** get the vertex ( edge end point) of original geometry ****/
      EFproject_vertex(&msg_loc, env, NULL, NULL, vertex_xyz, &edge1,
         TRUE, &org_sf, org_surf_geom, to_be_reved, NULL, NULL, &dist1, &dist2);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, INT_INT);

     BSmdistptsf(&rc, this_surf_geom,vertex_xyz,&u_par,&v_par,base_point,&dist);
     for(ii=0;ii<3;ii++)
        vertex_xyz[ii]=base_point[ii];

/** if the projection distance is large there may be problems so get the exact
    vertex point by intersecting the incident intersection (other than the
    p_intobjs) and the present surface beeing processed ****************/
      if(tmp_intobj && dist > (lentol*100000) )
      {
      if(!(p_intobjs[0]->props&EMSintobj_seam) &&
         !(p_intobjs[1]->props&EMSintobj_seam) &&
         !(tmp_intobj->props&EMSintobj_seam)    )
         {
          EFget_vertex(&msg_loc, env, tmp_intobj, this_surf_geom, base_point);
          for(ii=0;ii<3;ii++)
             vertex_xyz[ii]=base_point[ii];
         }
      }

      stat_OM = EMprojectpt (&msg_loc,
                    &env->md_env.matrix_type,
                    env->md_env.matrix,
                    &q_intobj->this_xyzintobj, 1,
                    vertex_xyz,
                    lentol, projpts, &dist);
      EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, INT_INT);

      if(surf_1 != NULL_OBJID)
      BSmdistptsf(&rc,surf_1_geom,vertex_xyz,&u_par,&v_par,base_point,&dist);

       if(EFare_ints_tan(&msg_loc, p_intobjs[0], p_intobjs[1], vertex_xyz))
        {
        /*** PROJECTING OLD VERTEX TO GET INT POINT FOR TOUCHING INTS *******/ 
         EFproject_vertex(&msg_loc, env, p_intobjs[0], p_intobjs[1], 
         projpts->point, NULL, TRUE, &this_sf, this_surf_geom, FALSE,
         projpts1, projpts2, &dist1, &dist2);
         EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, INT_INT);

           p_pypt1= projpts1;
           p_pypt1->next= NULL;
           p_pypt2= projpts2;
           p_pypt2->next= NULL;

         goto SPLIT_EM_NOW;
        }
        else
        {
            goto INT_INT ;
        }

  INT_INT :
        stat_OM =OM_S_SUCCESS; msg_loc =EMS_S_Success; *msg =EMS_S_Success;
        if(p_intobjs[FIRST]->this_uvintobj.datatype == EMSdata_curve3d &&
          p_intobjs[SECOND]->this_uvintobj.datatype == EMSdata_poly2d &&
            !(p_intobjs[SECOND]->props & EMSintobj_seam))
                       swap = TRUE;
        num_inters=0;

        EFget_intersection_points (&msg_loc, uvtol, 
                             &env->md_env.matrix_type,
                             env->md_env.matrix, 
                         swap ? &p_intobjs[SECOND]->this_uvintobj :
                             &p_intobjs[FIRST]->this_uvintobj ,
			     FALSE,
                         swap ? &p_intobjs[FIRST]->this_uvintobj :
                              &p_intobjs[SECOND]->this_uvintobj ,
                              FALSE,
                              &num_inters,
                         swap ? &p_pypt2 : &p_pypt1,
                         swap ? &p_pypt1 : &p_pypt2);
       if(EMSerror (msg_loc))
           {
           stat_OM = OM_S_SUCCESS; msg_loc = EMS_S_Success;
            num_inters=0;
           }

       if(num_inters > 1 ) num_inters=0;

       if(num_inters == 0)
       {
        /*** PROJECTING OLD VERTEX TO GET INT POINT FOR TOUCHING
        INTERSECTIONS AND MULTIPLE INTERSECTIONS ****** *******/ 
       EFproject_vertex(&msg_loc, env, p_intobjs[0], p_intobjs[1],
       projpts->point, NULL, TRUE, &this_sf, this_surf_geom, FALSE,
          projpts1, projpts2, &dist1, &dist2);
       EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

       if(p_pypt1) EMpypoint_free (p_pypt1, NULL);   p_pypt1=NULL;
       if(p_pypt2) EMpypoint_free (p_pypt2, NULL);  p_pypt2=NULL;

       p_pypt1= projpts1;
       p_pypt1->next= NULL;
       p_pypt2= projpts2;
       p_pypt2->next= NULL;
       }
       }

SPLIT_EM_NOW:
  for(jj=0; jj<2; jj++)
   {
    p_pypt = jj ? (struct EMSpypoint *)p_pypt2 : (struct EMSpypoint *)p_pypt1;

    p_intobj = p_intobjs[jj];
    if(p_intobj->this_uvintobj.datatype == EMSdata_object)
          goto Next;
    if(p_intobj->this_uvintobj.datatype == EMSdata_null)
          goto Next;
    if(p_intobj->props&EMSintobj_seam ||
       p_intobj->props&EMSintobj_uvdegenerate  ||
       p_intobj->props&EMSintobj_xyzdegenerate)
          goto Next;
      
    xyz_closed=0;
    xyz_closed = EMintobj_closed(&msg_loc, p_intobj, TRUE, cht_tol);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if ( !p_pypt ||
      (p_pypt->props & EMS_PYPT_ATSTART)||(p_pypt->props & EMS_PYPT_ATSTOP ))
         goto Next;

      split_other = TRUE;

/** SPLIT THE INTOBJ *****/
      no_split= TRUE;
      p_intobj_next = p_intobj->next;
      p_intobj_fwd = p_intobj->fwd;
      p_intobj_bwd = p_intobj->bwd;

    if(p_intobj->other_intobj_node)
     {
      ot_intobj = p_intobj->other_intobj_node;
      ot_intobj_next = ot_intobj->next;
      ot_intobj_fwd = ot_intobj->fwd;
      ot_intobj_bwd = ot_intobj->bwd;

      if(p_intobj->other_intobj_node->props&EMSintobj_delrefine)
         p_intobj->other_intobj_node->props |= EMSintobj_unmatched_dat;
      }

      EMsplit_sf_intobj_uv (&msg_loc,
                              EMSintobj_split_noconnectuv,
                              &env->md_env,
                              p_intobj,
                              p_pypt,
                              NULL,NULL);
         EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 


   if( p_intobj_next == p_intobj->next)
     {
      if(p_intobj)p_intobj = p_intobj->next; 
      no_split = FALSE;
      goto Next;
      }
    else
      {
/** DELETE THE APT SPLIT INTOBJ ****/
      p_intobj_rem = NULL;
      if(!p_intobj->other_intobj_node ||
       (p_intobj->other_intobj_node->this_obj_node->this_obj.objid ==
       p_intobj->next->other_intobj_node->this_obj_node->this_obj.objid))
        {
         IGRboolean del_next=FALSE;
         del_next = ( jj ? (p_intobj->reversed ?  TRUE : FALSE) :
                            (p_intobj->reversed ?  FALSE : TRUE) );

          if( del_next)
             {
             p_intobj_rem = p_intobj;
             EMdelintobj (&msg_loc, p_intobj->next);
             }
           else 
             {
             p_intobj_rem = p_intobj->next;
             EMdelintobj (&msg_loc, p_intobj);
             }
         p_intobj_fwd->bwd = p_intobj_rem;
         p_intobj_bwd->fwd = p_intobj_rem;
         p_intobj_rem->fwd = p_intobj_fwd;
         p_intobj_rem->bwd = p_intobj_bwd;

        /* Fix for FMR : TR#119525966 .Hari */

         if(p_intobj_rem->other_intobj_node)
          {
          ot_intobj_rem = p_intobj_rem->other_intobj_node;
          if(ot_intobj_fwd)
             ot_intobj_fwd->bwd = ot_intobj_rem;
          if(ot_intobj_bwd)
             ot_intobj_bwd->fwd = ot_intobj_rem;
          ot_intobj_rem->fwd = ot_intobj_fwd;
          ot_intobj_rem->bwd = ot_intobj_bwd;
          }
        }

         p_intobjs[jj] = p_intobj_rem;
       }

      if(p_pypt)
       q_pypt = p_pypt;
 Next:
      p_pypt=NULL;
      }

/*** REFINE THE INTOBJS AT THE VERTEX  *****/
     if(q_pypt)
      {
        uv[0] = q_pypt->point[0];
        uv[1] = q_pypt->point[1];
        EFrefine_the_intobjs(&msg_loc, env, p_intobjs, uv, partolb, lentol);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end); 
        stat_OM = OM_S_SUCCESS; msg_loc = EMS_S_Success;
      }

/** free memory ***/
     if(p_pypt1) EMpypoint_free (p_pypt1, NULL);   p_pypt1=NULL;
     if(p_pypt2) EMpypoint_free (p_pypt2, NULL);  p_pypt2=NULL;
    p_intobjs[FIRST] = p_intobjs[FIRST]->next;
    iii++;

  } 

/*** set xyz closed props intobjs**************/

      for(p_intobj = loc_inters->cvs; p_intobj; p_intobj=p_intobj->next)
        {
        xyz_closed = EMintobj_closed(&msg_loc, p_intobj, TRUE, cht_tol);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        if(xyz_closed)
            {
             p_intobj->props |= EMSintobj_xyz_closed;
             if(p_intobj->other_intobj_node)
               p_intobj->other_intobj_node->props |= EMSintobj_xyz_closed;
            }
         }

/* now create and impose them damn loops */

        num_lps = 0;
        om$get_channel_count(objid = this_sf.objid,
                osnum = this_sf.osnum,
                p_chanselect = &chan_to_loopset, count = &num_lps);
        EMerr_hndlr (num_lps > 1, *msg, EMS_E_Fail, ret_end);

       if(num_lps == 0)
       {
          stat_OM = om$construct(classid = OPP_EMSloopset_class_id,
                                 osnum = this_sf.osnum,
                                 p_objid = &loopset_id);
          stat_OM = om$send(msg = message Root.connect(chan_to_surface,
                                  0, this_sf.objid, this_sf.osnum,
                                  chan_to_loopset, 0),
                            senderid = NULL_OBJID,
                            targetid = loopset_id,
                            targetos = this_sf.osnum);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

          stat_OM = om$send (msg = message EMSloopset.EMset_props (&msg_loc,
                                   EMLS_NATURAL, EMS_O_ON),
                             senderid = NULL_OBJID,
                             targetos = this_sf.osnum,
                             targetid = loopset_id);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
        }
        else
        {
          num_lps = 0;
          om$get_channel_objects(objid = this_sf.objid,
                osnum = this_sf.osnum,
                p_chanselect = &chan_to_loopset, count = &num_lps, size = 1,
                list = comm_list);
          EMerr_hndlr (num_lps != 1, *msg, EMS_E_Fail, ret_end);

          loopset_id = comm_list[FIRST].S_objid;
        }

/******* RUN TRACE TO CHECK TOPOLOGY ****************************************/
          for(p_intobj = loc_inters->cvs; p_intobj; p_intobj = p_intobj->next)
              {
                p_intobj->bwd = NULL; p_intobj->fwd = NULL;
              }
          p_intobj = loc_inters->cvs;
          p_intobj->props |= EMSintobj_marked;
          loc_inters->next = NULL;
          cht_tol *= 1000.0;
          EMsfinttrace (&msg_loc, &env->md_env.matrix_type,
           env->md_env.matrix, loc_inters, &uvtol, &cht_tol,
             &sftrace.num_grps, &sftrace.num_subgrps_grp,
               &sftrace.num_elems_subgrp, &sftrace.elems, &sftrace.subgrp_rev,
                &sftrace.elem_rev, &sftrace.grp_closed, &sftrace.subgrp_closed);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

          if (!sftrace.num_grps || !sftrace.grp_closed[FIRST])
             {
               ex$message(msgnumb= EMS_F_PossibleInterference);
               EMerr_hndlr ( TRUE, *msg, EMS_E_Fail, ret_end);
             }
          else 
             {
              for(ii=0;ii<sftrace.num_grps; ii++)
                for(jj=0;jj<sftrace.num_subgrps_grp[ii]; jj++)
                  for(kk=0;kk<sftrace.num_elems_subgrp[ii][jj]; kk++)
                    if(sftrace.elem_rev[ii][jj][kk])
                      {
                      ex$message(msgnumb= EMS_F_PossibleInterference);
                      }
             }

          p_intobj_prev = NULL;
          for(p_intobj = loc_inters->cvs;
            p_intobj; p_intobj_prev = p_intobj , p_intobj = p_intobj->next)
             {
                p_intobj->bwd = p_intobj_prev;
                p_intobj->fwd = p_intobj->next;
              }
          tmp_intobj = loc_inters->cvs;
          p_intobj_prev->fwd = tmp_intobj;
          tmp_intobj->bwd = p_intobj_prev;
/*****************************************************************************/

	  props = props & ~(EMLP_NATURAL | EMLP_REVERSED);
          props |= loop_props;
          p_intobj = loc_inters->cvs;
	  EMmy_create_loop_from_int_group(&msg_loc,
                              p_intobj,
			      &loopset_id,
                              par_id, 
                              NULL,
                              NULL,
                              const_list,
			      &props);
    	  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

/** remove all intobjs which did not participate in the loop creation ***/
          for(p_intobj = loc_inters->cvs; p_intobj; p_intobj=p_intobj->next)
             {
              if( p_intobj->this_uvintobj.datatype != EMSdata_object )
                  {
                  EMdelintobj(&msg_loc, p_intobj);
                  }
             }


ret_end:
  if(this_surf_geom)
      om$dealloc(ptr=this_surf_geom); 
  if(org_surf_geom)
      om$dealloc(ptr=org_surf_geom); 
  if(surf_1_geom)
      om$dealloc(ptr=surf_1_geom); 
  if(surf_2_geom)
      om$dealloc(ptr=surf_2_geom); 
  if(projpts)
      om$dealloc(ptr=projpts);
  if(projpts1)
      om$dealloc(ptr=projpts1);
  if(projpts2)
      om$dealloc(ptr=projpts2);
  EMWRAPUP(*msg, stat_OM, "EMtopogen");
  return(stat_OM);
}


/***************************************************************************
DESCRIPTION:
This function creates a loop from the given intersection group and
imposes it on the loopset of the surface.

void EMmy_create_loop_from_int_group(msg, p_intobj, p_loopset,
 parent_id, p_alt_uvtol, p_alt_xyztol, p_const_list, p_loop_props)

IGRlong			*msg           - Error Return Code             (O)
struct EMSintobj	*p_intobj      - Pointer to 1st element of the
					 closed intersection group 
					 used to create new loop       (I)
GRobjid			*p_loopset     - Loopset on which the loop is
					 to be nested (Optional)
					 Extracted from surf if not
				         input                         (I)
IGRdouble		*p_alt_uvtol, 
			*p_alt_xyztol  - uv and xyz Tol (Optional)
					 Defaults to Basis tol         (I)
struct GRvg_construct	*p_const_list; - Construction list info        (I)
IGRushort		*p_loop_props; - Loop properties (Optional)    (I)
*****************************************************************************/

void EMmy_create_loop_from_int_group(msg, p_intobj, p_loopset, parent_id,
         p_alt_uvtol, p_alt_xyztol, p_const_list, p_loop_props)

IGRlong			*msg;
struct EMSintobj	*p_intobj;
GRobjid			*p_loopset, *parent_id;
IGRdouble		*p_alt_uvtol, *p_alt_xyztol;
struct GRvg_construct	*p_const_list;
IGRushort		*p_loop_props;

{
  IGRlong		stat_OM, msg_loc;
  IGRshort		*mattyp;
  IGRint		numpts, inxlim, i;
  OMuint		count;
  IGRboolean		true;
  IGRdouble		uvtol, xyztol, **sfpartols, *mat;
  GRobjid		**loops_and_sfs, **end_edges;
  struct GRmd_env	*env;
  struct GRid		this_sf;
  struct EMSpartolbasis	partolbasis;
  struct EMSintobj	*tmp_intobj ;
  struct EMSinters	*p_inters, *save_p_inters;
  struct EMSsfintedpar	***intedpars;
  struct EMSsftracedata	sftrace;
  struct EMSnest_info	nest_info;
  OM_S_CHANSELECT 	chan_to_loopset;
  OM_S_OBJECT_LINKAGE	comm_list[1];
  extern void EMbnduvpts();

     *msg = EMS_S_Success;
     stat_OM = OM_S_SUCCESS;
     env = p_const_list->env_info;
     mattyp = &env->md_env.matrix_type;
     mat = env->md_env.matrix;
     partolbasis.in_world = TRUE;
     partolbasis.mattyp = mattyp;
     partolbasis.mat = mat;

    /*
     * The incoming  intersections are in contiguous order and
     * this may be re-inforced by setting the continuity pointers. Also,
     * convert the uv-data into EMSedges.
     */

    p_inters = p_intobj->this_obj_node;
    this_sf = p_inters->this_obj;
    tmp_intobj = p_intobj;

    while (p_intobj->next)
    {
      p_intobj->props &= ~EMSintobj_fwd_noconnectuv;
      p_intobj->props |= EMSintobj_fwd_connectuv;
      p_intobj->fwd = p_intobj->next;

      p_intobj->fwd->props &= ~EMSintobj_bwd_noconnectuv;
      p_intobj->fwd->props |= EMSintobj_bwd_connectuv;
      p_intobj->fwd->bwd = p_intobj;
      if(p_intobj->this_uvintobj.datatype == EMSdata_poly2d)
        {
        numpts = p_intobj->this_uvintobj.data.poly->num_points;
        EMbnduvpts (numpts, p_intobj->this_uvintobj.data.poly->points);
        }
      EMconvert_to_edge (&msg_loc, p_intobj, this_sf.osnum);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      if (p_intobj->other_intobj_node)
      {
      if(p_intobj->other_intobj_node->this_uvintobj.datatype == EMSdata_poly2d)
        {
      numpts= p_intobj->other_intobj_node->this_uvintobj.data.poly->num_points;
        EMbnduvpts (numpts, 
           p_intobj->other_intobj_node->this_uvintobj.data.poly->points);
        }
      EMconvert_to_edge (&msg_loc, p_intobj->other_intobj_node, this_sf.osnum);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
      p_intobj = p_intobj->next;
    }

    p_intobj->props &= ~EMSintobj_fwd_noconnectuv;
    p_intobj->props |= EMSintobj_fwd_connectuv;
    p_intobj->fwd = tmp_intobj;

    tmp_intobj->props &= ~EMSintobj_bwd_noconnectuv;
    tmp_intobj->props |= EMSintobj_bwd_connectuv;
    tmp_intobj->bwd = p_intobj;

    EMconvert_to_edge (&msg_loc, p_intobj, this_sf.osnum);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    if (p_intobj->other_intobj_node)
      {
      EMconvert_to_edge (&msg_loc, p_intobj->other_intobj_node, this_sf.osnum);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }

    /*
     * Trace again and this time we should get a closed, single group. 
     * This group is converted to a loop and imposed as the
     * new boundary on the fillet surface.
     */

    if(p_alt_xyztol)
	xyztol = *p_alt_xyztol;
    else
        BSEXTRACTPAR (&msg_loc, BSTOLBASIS, xyztol);

    if(!p_alt_uvtol)
    {
      om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc, mattyp, mat,
       		     &true, TRUE, &uvtol),
	       senderid = NULL_OBJID,
	       targetos = this_sf.osnum,
	       targetid = this_sf.objid);
    }
    else
      uvtol = *p_alt_uvtol;

    save_p_inters = p_inters->next;
    p_inters->next = NULL;
    EMsfinttrace (&msg_loc, mattyp, mat, p_inters, &uvtol, &xyztol,
     &sftrace.num_grps, &sftrace.num_subgrps_grp, &sftrace.num_elems_subgrp,
     &sftrace.elems, &sftrace.subgrp_rev, &sftrace.elem_rev,
     &sftrace.grp_closed, &sftrace.subgrp_closed);
    p_inters->next = save_p_inters;    
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    EMerr_hndlr (sftrace.num_grps != 1 || !sftrace.grp_closed[FIRST] || 
     sftrace.num_subgrps_grp[FIRST] != 1 || !sftrace.subgrp_closed[FIRST] ||
     sftrace.subgrp_rev[FIRST][FIRST],
     *msg, EMS_E_Fail, ret_end);

    inxlim = sftrace.num_elems_subgrp[FIRST][FIRST];
    for (i=0; i<inxlim; i++)
      {EMerr_hndlr (sftrace.elem_rev[FIRST][FIRST][i], *msg,
        EMS_E_IntersectOrient, ret_end);}

    EMsfintloops (&msg_loc, mattyp, mat, this_sf.osnum, &uvtol,
     sftrace.num_grps, sftrace.num_subgrps_grp, sftrace.num_elems_subgrp,
     sftrace.elems, sftrace.subgrp_rev, sftrace.elem_rev,
     sftrace.grp_closed, sftrace.subgrp_closed, 
     FALSE, FALSE, &loops_and_sfs, &end_edges, &intedpars, &sfpartols);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message EMSloop.EMset_props (&msg_loc, EMLP_NEW,
               EMS_O_OFF), 
		senderid = NULL_OBJID,
		targetos = this_sf.osnum,
		targetid = loops_and_sfs[FIRST][FIRST]);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if(!p_loopset)
    {
      EMmake_chanselect (EMSsubbs_to_loopset, &chan_to_loopset);
      count = 0;
      om$get_channel_objects (objid = this_sf.objid,
	    osnum = this_sf.osnum,
            p_chanselect = &chan_to_loopset, count = &count, size = 1,
            list = comm_list);
      EMerr_hndlr (count != 1, *msg, EMS_E_Fail, ret_end);
      p_loopset = &comm_list[FIRST].S_objid;
    }

    partolbasis.is_valid = TRUE;
    partolbasis.tol = uvtol;
    nest_info.loopid = loops_and_sfs[FIRST][FIRST];
    nest_info.lp_props = EMLP_ACTIVE | (p_loop_props ? *p_loop_props : NULL);
    if(*parent_id == NULL_OBJID)
      nest_info.parent = *p_loopset; 
    else
      nest_info.parent = *parent_id;
    nest_info.parent_props = NULL;

    stat_OM = om$send (msg = message EMSloop.EMset_props (&msg_loc,
               nest_info.lp_props, EMS_O_ON), 
		senderid = NULL_OBJID,
		targetos = this_sf.osnum,
		targetid = nest_info.loopid );
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    if(*parent_id == NULL_OBJID)
       {
       stat_OM = om$send (msg = message EMSloopset.EMtreemod (&msg_loc,
               &nest_info, ADD_CHILD, &partolbasis),
	       senderid = NULL_OBJID,
	       targetos = this_sf.osnum,
               targetid = *p_loopset);
       EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
       }
    else
       {
       stat_OM = om$send (msg = message EMSloop.EMtreemod (&msg_loc,
               &nest_info, ADD_CHILD, &partolbasis),
	       senderid = NULL_OBJID,
	       targetos = this_sf.osnum,
               targetid = *parent_id);
       EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
       }

    EMsfinttrace_free (&msg_loc, sftrace.num_grps, sftrace.num_subgrps_grp,
     sftrace.num_elems_subgrp, sftrace.elems, sftrace.subgrp_rev,
     sftrace.elem_rev, sftrace.grp_closed, sftrace.subgrp_closed);

    EMsfintloops_free (loops_and_sfs, end_edges, intedpars, sfpartols);

ret_end:
    EMWRAPUP(*msg, stat_OM, "EMcreate_loop_from_int_group");
    return;
}



/* ************************************************************************* */
void EFget_the_incident_intobjs(msg, p_intobjs, num_incident, 
	   incident_intobjs, end_lis, sf_lis,  is_rev)
/* ************************************************************************* */
IGRlong			*msg, *num_incident;
struct EMSintobj	*p_intobjs[2], ***incident_intobjs;
IGRint			**end_lis;
struct GRid		**sf_lis;
IGRboolean		*is_rev;

{
  IGRlong		msg_loc, count;
  IGRint		buf_size, inc_size, loc, jj;
  IGRboolean		dead_ended, rev_connect, mem_allocated, vert_at_end;
  struct EMSintobj	*p_intobj, *tmp_intobj;

  *msg = EMS_S_Success;
  buf_size = inc_size = 5;
  mem_allocated = FALSE;

  if(num_incident) *num_incident = 0;
  if(!p_intobjs[0]->other_intobj_node && !p_intobjs[1]->other_intobj_node)
  {
    return;
  }

  if(incident_intobjs || end_lis || sf_lis)
  {
  /* Allocate memory for output */
     if(incident_intobjs)
     {
	*incident_intobjs = NULL;
	*incident_intobjs = (struct EMSintobj **) om$malloc(size = buf_size *
						  sizeof(struct EMSintobj *));
	EMerr_hndlr(!(*incident_intobjs), *msg, EMS_E_DynamicMemoryAllocated,
		    ret_end);
     }
     if(end_lis)
     {  *end_lis = NULL;
	*end_lis = (IGRint *) om$malloc(size = buf_size * sizeof(IGRint));
	EMerr_hndlr(!(*end_lis), *msg, EMS_E_DynamicMemoryAllocated, ret_end);
     }
     if(sf_lis)
     {
	*sf_lis = NULL;
	*sf_lis = (struct GRid *) om$malloc(size = buf_size * 
				  sizeof(struct GRid));
	EMerr_hndlr(!(*sf_lis), *msg, EMS_E_DynamicMemoryAllocated, ret_end);
     }
     mem_allocated = TRUE;
  }
  else mem_allocated = FALSE;

  dead_ended=FALSE;
  count = 0;
  *is_rev = FALSE;
     
for(jj=0;jj<2;jj++)
 {
  if(jj==1 && !dead_ended) continue;
  if(!dead_ended && p_intobjs[0]->other_intobj_node)
  {
    p_intobj = p_intobjs[0]->other_intobj_node;
    vert_at_end = TRUE;
  }
  else
  {
    p_intobj = p_intobjs[1]->other_intobj_node;
    vert_at_end = FALSE;
  }

  while(p_intobj)
  {
    rev_connect = EFis_rev_connect(&msg_loc, p_intobj);
    EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
    tmp_intobj = (vert_at_end ? 
                          (rev_connect ?  p_intobj->bwd : p_intobj->fwd) :
                          (rev_connect ?  p_intobj->fwd : p_intobj->bwd));

    if( !tmp_intobj)
        {
         dead_ended = TRUE;
         break;
        }

    /* Check if we have cycled back and reached one of the input intobj pair.
       If so exit the loop
    */
    if(p_intobjs[0]->other_intobj_node)
      if(tmp_intobj == p_intobjs[0]->other_intobj_node) 
         break;
    if(p_intobjs[1]->other_intobj_node)
      if(tmp_intobj == p_intobjs[1]->other_intobj_node) 
         break;

    if(incident_intobjs) (*incident_intobjs)[count] = tmp_intobj;

    loc = (vert_at_end ?  (rev_connect ?  END : BEGIN) :
                          (rev_connect ?  BEGIN : END));
    if(end_lis) (*end_lis)[count] = loc;

    if(sf_lis) (*sf_lis)[count] = tmp_intobj->this_obj_node->this_obj;

    count++;
    if(mem_allocated && count >= buf_size)
    {
       buf_size += inc_size;
       if(incident_intobjs) 
	  *incident_intobjs = (struct EMSintobj **) om$realloc(ptr =
			       (IGRchar *) *incident_intobjs, size =
			       buf_size * sizeof(struct EMSintobj *));
       if(end_lis) 
	  *end_lis = (IGRint *) om$realloc(ptr = (IGRchar *) *end_lis, size =
			        buf_size * sizeof(IGRint));
       if(sf_lis) 
	  *sf_lis = (struct GRid *) om$realloc(ptr = (IGRchar *) *sf_lis, 
				    size = buf_size * sizeof(struct GRid));
    }
    /* Set vert_at_end flag (TRUE/FALSE) for the current incident intobj
       (tmp_intobj) and set p_intobj to its 'other' intobj.
    */
    vert_at_end = (loc == END ? TRUE : FALSE);
    p_intobj = tmp_intobj->other_intobj_node;
  }
}
  if(num_incident) *num_incident = count;
ret_end:
  if(!(*msg & 1))
  {
     if(mem_allocated)
     {
	if(incident_intobjs && *incident_intobjs)
	   om$dealloc(ptr = *incident_intobjs);
	if(end_lis && *end_lis) om$dealloc(ptr = *end_lis);
	if(sf_lis && *sf_lis) om$dealloc(ptr = *sf_lis);
     }
  }
  return;

}


/* ************************************************************************* */
void EFrefine_the_intobjs(msg, env, this_intobjs, this_uv, this_tol, lentol)
/* ************************************************************************* */
IGRlong			*msg;
struct GRmd_env		*env;
struct EMSintobj	*this_intobjs[2];
IGRdouble		this_uv[2];
struct EMSpartolbasis	this_tol;
IGRdouble		lentol;

{

  IGRlong			i, j, rc, msg_loc, stat_OM, num_intobjs, 
				num_sfs;
  IGRint			location, loc_locn, *end_lis, num_par;
  struct GRid			sfs[4], *sf_lis;
  struct IGRbsp_surface		*surf[4];
  struct EMSpartolbasis		par_tol[4], loc_partol;
  IGRdouble			surf_uv[4][2], base_point[4], uv_pt[2];
  IGRpoint			xyz_pt;
  IGRboolean			is_succ,  free_data, rev_order;
  IGRboolean			loc_rev_order;
  struct EMSintobj		*p_intobjs[4], **inc_intobjs, *intobj_pair[2],
				*other_intobj, *q_intobj;
  struct EMSdataselect		loc_sf_data;
  IGRboolean		        rev_connect;

  IGRboolean	BSmdistptsf(), EMis_same_dataselect();
  IGRdouble	BSdistptpt();

  IGRdouble     dist[3];

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;
  num_sfs = 0;

  inc_intobjs = NULL;
  end_lis = NULL;
  sf_lis = NULL;
  surf[0] = surf[1] = surf[2] = NULL;

  EFget_the_incident_intobjs(&msg_loc, this_intobjs, &num_intobjs,
			 &inc_intobjs, &end_lis, &sf_lis, &rev_order);
  EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

  if(num_intobjs == 0) return;    /* No refinement needed */

  rev_order = FALSE;
  q_intobj = (rev_order ? this_intobjs[STOP] : this_intobjs[START]);

  if(q_intobj->other_intobj_node &&
      q_intobj->other_intobj_node->this_obj_node->this_obj.objid !=
         inc_intobjs[0]->this_obj_node->this_obj.objid)
            rev_order = rev_order ? FALSE : TRUE;

  p_intobjs[0] = (rev_order ? this_intobjs[STOP] : this_intobjs[START]);
  sfs[0] = p_intobjs[0]->this_obj_node->this_obj;
  loc_rev_order = rev_order;

  num_sfs=1;
  for(i=0; i<num_intobjs && i<2 ; i++)
  {
      p_intobjs[num_sfs] = inc_intobjs[i];
      sfs[num_sfs] = inc_intobjs[i]->this_obj_node->this_obj;
      num_sfs++;
  }

  if(this_intobjs[0]->other_intobj_node && this_intobjs[1]->other_intobj_node)
    if(num_sfs <3 || num_intobjs>1 )
      {
      p_intobjs[num_sfs] = (rev_order ? this_intobjs[START]->other_intobj_node :
                                     this_intobjs[STOP]->other_intobj_node);
      sfs[num_sfs] = p_intobjs[num_sfs]->this_obj_node->this_obj;
      num_sfs++;
      }

  if(num_sfs > 4)num_sfs=4;

  loc_sf_data.datatype = EMSdata_object;
  for(i=0; i<num_sfs; i++)
  {
     surf[i] = NULL;
     loc_sf_data.data.object = &sfs[i];
     stat_OM = EMsm_get_surface_geom(&msg_loc, &loc_sf_data, &env->md_env,
				   &surf[i]);
     EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  dist[0] = 0.0; dist[1]=0.0; dist[2]=0.0;

  OM_BLOCK_MOVE(this_uv, surf_uv[0], 2*sizeof(IGRdouble));
  par_tol[0] = this_tol;
  BSsfeval(surf[0], surf_uv[0][0], surf_uv[0][1], 0, xyz_pt, &rc );
  EMerr_hndlr(rc!=BSSUCC, *msg, EMS_E_Fail, ret_end);
  for(i=1; i<num_sfs; i++)
  {
     EFget_partolbasis(&msg_loc, sfs[i], env, &par_tol[i]);
     EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);

     if(!BSmdistptsf(&rc, surf[i], xyz_pt, &surf_uv[i][0],
                          &surf_uv[i][1], base_point, &dist[i]))
        EMerr_hndlr(TRUE, *msg, EMS_E_Fail, ret_end);
  }

  if(num_sfs >=3) 
  {
  /* There are 3 surfs meeting at a point. Hence perform 3 surface iteration. */
      BStrpsfiter(surf[0], surf[1], surf[2], par_tol[0].tol, par_tol[1].tol,
                  par_tol[2].tol, &surf_uv[0][0], &surf_uv[0][1],
		  &surf_uv[1][0], &surf_uv[1][1],
		  &surf_uv[2][0], &surf_uv[2][1],
                  xyz_pt, &is_succ, &rc);
      EMerr_hndlr(rc!=BSSUCC, *msg, EMS_E_Fail, ret_end);
  }
  else
  {
   /* There are only two participating surfaces. We need to compute the
      exact intersection point on the intersection curve between these two.
      Hence we perform what is called the curve-surface iteration.  */

      IGRint	 iso = 0, j, uv_size;
      IGRdouble  loc_my_uv[2], loc_comm_uv[2], junk_my_uv[2], 
		 junk_comm_uv[2], dist1, dist2;
      IGRpoint   loc_xyz_exact, junk_xyz_exact;

      uv_size = 2 * sizeof(IGRdouble);
      is_succ = FALSE;
      for(j=0; (j<2) && !is_succ && (iso < 4); j++)
      {
         OM_BLOCK_MOVE(xyz_pt, loc_xyz_exact, 3*sizeof(IGRdouble));
         OM_BLOCK_MOVE(surf_uv[0], loc_my_uv, uv_size);
         OM_BLOCK_MOVE(surf_uv[1], loc_comm_uv, uv_size);
         rc = BSSUCC;
         is_succ = FALSE;
         BScvsfiter(surf[0], surf[1], iso++, surf[0]->u_phy_closed, 
		    surf[0]->v_phy_closed , surf[1]->u_phy_closed,
		    surf[1]->v_phy_closed,
                    par_tol[0].tol, par_tol[1].tol,
		    loc_xyz_exact, &loc_my_uv[0], &loc_my_uv[1],
                    &loc_comm_uv[0], &loc_comm_uv[1], &is_succ, &rc);
         if((rc!=BSSUCC) || !is_succ) {iso++; continue;}

         if(BSdistptpt(&rc, loc_xyz_exact, xyz_pt) < lentol) continue;

         /* Try with the other parameter remaining constant and select the
             closest point.  */

         OM_BLOCK_MOVE(xyz_pt, junk_xyz_exact, 3*sizeof(IGRdouble));
         OM_BLOCK_MOVE(surf_uv[0], junk_my_uv, uv_size);
         OM_BLOCK_MOVE(surf_uv[1], junk_comm_uv, uv_size);
         rc = BSSUCC;
         is_succ = FALSE;
         BScvsfiter(surf[0], surf[1], iso++, surf[0]->u_phy_closed, 
		    surf[0]->v_phy_closed , surf[1]->u_phy_closed,
		    surf[1]->v_phy_closed,
                    par_tol[0].tol, par_tol[1].tol,
		    junk_xyz_exact, &junk_my_uv[0], &junk_my_uv[1],
                    &junk_comm_uv[0], &junk_comm_uv[1], &is_succ, &rc);
         if((rc!=BSSUCC) || !is_succ) {iso++; continue;}

         dist1 = BSdistptpt(&rc, xyz_pt, loc_xyz_exact);
         dist2 = BSdistptpt(&rc, xyz_pt, junk_xyz_exact);
         if(dist2 < dist1)
         {
           OM_BLOCK_MOVE(junk_xyz_exact, loc_xyz_exact, 3*sizeof(IGRdouble));
           OM_BLOCK_MOVE(junk_my_uv, loc_my_uv, uv_size);
           OM_BLOCK_MOVE(junk_comm_uv, loc_comm_uv, uv_size);
         }
      } /* for(j=0; (j<2) && .....) */
      EMerr_hndlr(rc!=BSSUCC, *msg, EMS_E_Fail, ret_end);
      EMerr_hndlr(!is_succ, *msg, EMS_I_NoSolution, ret_end);

      OM_BLOCK_MOVE(loc_xyz_exact, xyz_pt, 3*sizeof(IGRdouble));
      OM_BLOCK_MOVE(loc_my_uv, surf_uv[0], uv_size);
      OM_BLOCK_MOVE(loc_comm_uv, surf_uv[1], uv_size);
  } /* else ... curve-sf iteration */

/* The exact xyz point has been obtained in xyz_pt. The exact uv points have
   also been obtained in surf_uv[][].
   All that remains now is to actually modify the model-space and uv-space
   geometries of all the intobjs incident at this vertex to end 'exactly'
   at the XYZ point and the respective UV point.
*/

   
   /* Modify the incoming intobj pair lying on sfs[0] */
   for(i=0; i<2; i++)
   {
    if((this_intobjs[0]->props&EMSintobj_seam) ||
          (this_intobjs[1]->props&EMSintobj_seam) )
              continue;
    
    if((this_intobjs[0]->this_uvintobj.datatype == EMSdata_object) ||
       (this_intobjs[1]->this_uvintobj.datatype == EMSdata_object) )
            continue;
     location = (this_intobjs[i]->reversed ? (i==0 ? BEGIN : END) :
					    (i==0 ? END :BEGIN));    
     EFmodify_end(&msg_loc, &this_intobjs[i]->this_uvintobj, 2, location,
		  surf_uv[0], par_tol[0].tol, TRUE);
     EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

     other_intobj = this_intobjs[i]->other_intobj_node;  
     if(other_intobj)
        free_data = !EMis_same_dataselect(&this_intobjs[i]->this_xyzintobj,
					      &other_intobj->this_xyzintobj);
     else free_data = TRUE;

     EFmodify_end(&msg_loc, &this_intobjs[i]->this_xyzintobj, 3, location,
		xyz_pt, lentol, free_data);
     EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

   }

   for(j=1; j<num_sfs; j++)
   {
      intobj_pair[0] = p_intobjs[j];
      if(j<num_intobjs+1)
        {
        location = end_lis[j-1];
        }
      else
        {
        rev_connect = EFis_rev_connect(&msg_loc, intobj_pair[0]);
        EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

        location = rev_connect ? (rev_order ?  BEGIN : END) :
                                 (rev_order ?  END : BEGIN) ;
        }

       intobj_pair[1] = location ? intobj_pair[0]->fwd : intobj_pair[0]->bwd;
 
      if(!intobj_pair[1] || !intobj_pair[0] ||
            intobj_pair[0]->this_uvintobj.datatype == EMSdata_object  ||
               intobj_pair[1]->this_uvintobj.datatype == EMSdata_object )
          continue;

      {
 
       intobj_pair[0]->props |= EMSintobj_delrefine;
       intobj_pair[1]->props |= EMSintobj_delrefine;

       if(num_sfs<4) /* it will be never > 3 at least now */
       {
          uv_pt[0] = surf_uv[j][0];
          uv_pt[1] = surf_uv[j][1];
       }
       else
       {
       stat_OM = om$send(msg = message EMSsubbs.EMpratpt(&msg_loc,
                                                 &env->md_env.matrix_type,
                                                 env->md_env.matrix,
                                                 xyz_pt, uv_pt, &num_par),
                    senderid = NULL_OBJID,
                    targetid = sfs[j].objid,
                    targetos = sfs[j].osnum);
        EMerr_hndlr(!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, ret_end);
        }

	EFget_partolbasis(&msg_loc, sfs[j], env, &loc_partol);
	EMerr_hndlr(!(1&msg_loc), *msg, EMS_E_Fail, ret_end);
      }
      for(i=0; i<2; i++)
      {
       if((intobj_pair[0]->props&EMSintobj_seam) ||
          (intobj_pair[1]->props&EMSintobj_seam) )
              continue;
         loc_locn = (intobj_pair[i]->reversed ? (location==END ? BEGIN : END) :
					        location);
         EFmodify_end(&msg_loc, &intobj_pair[i]->this_uvintobj, 2, loc_locn,
		      uv_pt, loc_partol.tol, TRUE);
         EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);

         other_intobj = intobj_pair[i]->other_intobj_node;  
         if(other_intobj)
            free_data = !EMis_same_dataselect(&intobj_pair[i]->this_xyzintobj,
					      &other_intobj->this_xyzintobj);
         else free_data = TRUE;

         EFmodify_end(&msg_loc, &intobj_pair[i]->this_xyzintobj, 3, 
			 loc_locn, xyz_pt, lentol, free_data);
	 EMerr_hndlr(EMSerror(msg_loc), *msg, EMS_E_Fail, ret_end);
	 location = (location==END ? BEGIN : END);
      } /* ith for loop */
    }

ret_end:
   for(i=0; i<num_sfs; i++)
      if(surf[i]) free(surf[i]);
   if(inc_intobjs) om$dealloc(ptr = inc_intobjs);
   if(sf_lis) om$dealloc(ptr = sf_lis);
   if(end_lis) om$dealloc(ptr = end_lis);
   return;
}

 IGRlong  EFproject_vertex(EMmsg, env, p_intobj, q_intobj, xyz_pt, 
       edge, first_edge, this_sf, this_surf_geom,
           to_be_reved,  projpts1, projpts2, dist1, dist2)

       IGRlong *EMmsg;
       struct GRmd_env *env;
       struct EMSpypoint *projpts1,  *projpts2;
       struct EMSintobj *p_intobj,  *q_intobj;
       IGRdouble *xyz_pt;
       struct IGRbsp_surface *this_surf_geom;
        struct GRid *this_sf;
       IGRboolean first_edge, to_be_reved;
       GRobjid *edge;
       IGRdouble *dist1, *dist2;
       {
        IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
        BSrc rc= BSSUCC;
        IGRdouble lentol;
        IGRpoint split_end, other_end;
        IGRdouble *point=NULL;
        struct EMSedgebound coinc_start_param,coinc_end_param;
        IGRdouble  base_point[3];
         IGRboolean	BSmdistptsf();

        BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, lentol);
        *dist2=0.0;
        *dist1=0.0;
        if(!edge)
        {
        BSmdistptsf(&rc, this_surf_geom, xyz_pt, &split_end[0], &split_end[1],
              base_point, dist1);
        point = split_end;
        }
        else if(edge)
        {
        stat_OM = om$send (msg=message EMSedge.EMendpts (&msg_loc,
                  (first_edge ? other_end : split_end),
                  (first_edge ? split_end : other_end),
                     &coinc_start_param, &coinc_end_param, NULL),
                             targetid= *edge,
                             targetos= this_sf->osnum,
                             senderid= NULL_OBJID);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, INT_INT);
        point = to_be_reved ? other_end : split_end;
        }

        point[2]=0.0; 
        if(p_intobj)
        {
        stat_OM = EMprojectpt (&msg_loc,
                    &env->md_env.matrix_type,
                    env->md_env.matrix,
                    &p_intobj->this_uvintobj, 1,
                    point,
                    lentol, projpts1, dist1);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, INT_INT);
        }
        if( !q_intobj && !p_intobj)
        {
        BSsfeval(this_surf_geom, point[0], point[1], 0, xyz_pt, &rc);
        if(rc!=BSSUCC) printf("surface evaluation not possible\n");
        EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, Oh_hell);
        }
        if(q_intobj)
        {
        stat_OM = EMprojectpt (&msg_loc,
                    &env->md_env.matrix_type,
                    env->md_env.matrix,
                    &q_intobj->this_uvintobj, 1,
                    point,
                    lentol, projpts2, dist2);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail, INT_INT);
        }
   Oh_hell:
   INT_INT:
        return(stat_OM);
        }

IGRboolean  EFare_ints_tan(EMmsg, p_intobj, q_intobj, xyz_pt)
       IGRlong *EMmsg;
       struct EMSintobj *p_intobj,  *q_intobj;
       IGRpoint xyz_pt;

      {
       IGRlong msg_loc=EMS_S_Success;
       BSrc rc=BSSUCC;
       IGRboolean is_tan=FALSE;
       IGRvector p_tan, q_tan, nvec,  temp_vec;
       IGRdouble *p_poly, *q_poly;
       IGRint p_poly_num, q_poly_num, ii;
       struct IGRbsp_curve *p_curve=NULL, *q_curve=NULL;
       IGRdouble sum,chtol,point[6], *pars, *intpars0=NULL,*intpars1=NULL, dist;
       IGRint k, n;
       extern void BScveval(), BSmndistptcv(); 
       extern void BSalloccv();

       BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, chtol);
       chtol *= 1000.0;
       if(p_intobj->this_xyzintobj.datatype == EMSdata_curve3d)
         {
         p_curve = p_intobj->this_xyzintobj.data.curve;
         }
       else if(p_intobj->this_xyzintobj.datatype == EMSdata_poly3d)
         {
         p_poly = p_intobj->this_xyzintobj.data.poly->points;
         p_poly_num = p_intobj->this_xyzintobj.data.poly->num_points;
         BSalloccv(2,  p_poly_num+1, TRUE, 0, &p_curve, &rc);
         if(rc != BSSUCC) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
         BSlininter( &rc, &p_poly_num, p_poly, p_curve, nvec );
         EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
         }
       else
         {
         is_tan=TRUE;
         goto wrapup;
         } 

       BSmdistptcv(p_curve, xyz_pt, &k, &n, &pars, &dist, &intpars0, &rc);
       EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
       BScveval(p_curve, pars[0], 1, &point, &rc);
       EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
       EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       for(ii=0;ii<3;ii++)
           p_tan[ii] = point[3+ii];
       BSnorvec(&rc, p_tan);


       if(q_intobj->this_xyzintobj.datatype == EMSdata_curve3d)
         {
         q_curve = q_intobj->this_xyzintobj.data.curve;
         }
       else if(q_intobj->this_xyzintobj.datatype == EMSdata_poly3d)
         {
         q_poly = q_intobj->this_xyzintobj.data.poly->points;
         q_poly_num = q_intobj->this_xyzintobj.data.poly->num_points;
         BSalloccv(2,  q_poly_num+1, TRUE, 0, &q_curve, &rc);
         if(rc != BSSUCC) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
         BSlininter( &rc, &q_poly_num, q_poly, q_curve, nvec );
         EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
         }
       else
         {
         is_tan=TRUE;
         goto wrapup;
         } 

       BSmdistptcv(q_curve, xyz_pt, &k, &n, &pars, &dist, &intpars1, &rc);
       EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
       BScveval(q_curve, pars[0], 1, &point, &rc);
       EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
       EMerr_hndlr( rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
       for(ii=0;ii<3;ii++)
           q_tan[ii] = point[3+ii];
       BSnorvec(&rc, q_tan);

       BScrossp(&rc, p_tan, q_tan, temp_vec);

       is_tan= FALSE;
       sum = 0.0;
       if(fabs(temp_vec[0]) + fabs(temp_vec[1]) + fabs(temp_vec[2]) < chtol)
             is_tan = TRUE;
       else
             {
              sum = fabs(temp_vec[0]) *fabs(temp_vec[0]) ;
              sum += (fabs(temp_vec[1]) *fabs(temp_vec[1]) );
              sum += (fabs(temp_vec[2]) *fabs(temp_vec[2]) );
              if( sum < chtol*chtol)
                is_tan = TRUE;
              else if(sqrt(sum) < chtol)
                is_tan = TRUE;
             }

wrapup:
   if(p_intobj->this_xyzintobj.datatype == EMSdata_poly3d)
    if(p_curve)
      BSfreecv(&rc, p_curve);
   if(q_intobj->this_xyzintobj.datatype == EMSdata_poly3d)
    if(q_curve)
      BSfreecv(&rc, q_curve);
   if(pars)
      om$dealloc(ptr = pars);
   if(intpars0)
      om$dealloc(ptr = intpars0);
   if(intpars1)
      om$dealloc(ptr = intpars1);
   return(is_tan);
      }


void EFget_curve_geom(EMmsg, env, p_intobj, pq_curve)
       IGRlong *EMmsg;
       struct GRmd_env *env;
       struct IGRbsp_curve **pq_curve;
       struct EMSintobj *p_intobj;
     {

       IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
       BSrc rc=BSSUCC;
       IGRint p_poly_num;
       IGRdouble *p_poly;
       struct IGRbsp_curve *p_curve=NULL;
       IGRvector  nvec;
       extern void BScveval(), BSmndistptcv();
       extern void BSalloccv();

       if(p_intobj->this_xyzintobj.datatype == EMSdata_poly3d)
         {
         p_poly = p_intobj->this_xyzintobj.data.poly->points;
         p_poly_num = p_intobj->this_xyzintobj.data.poly->num_points;

         BSalloccv(2,  (p_poly_num+1), TRUE, 0, &p_curve, &rc);
         EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);

         BSlininter( &rc, &p_poly_num, p_poly, p_curve, nvec );
         EMerr_hndlr(rc!=BSSUCC, *EMmsg, EMS_E_Fail, wrapup);
         }
        else if(p_intobj->this_xyzintobj.datatype == EMSdata_object)
         {
         p_curve = (struct IGRbsp_curve *)
                          om$malloc(size=sizeof(struct IGRbsp_curve));
         EMerr_hndlr (! p_curve, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
         p_curve->poles = NULL;
         p_curve->knots = NULL;
         p_curve->weights = NULL;
         stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg_loc,
                                        &env->md_env,
                                        &p_intobj->this_obj_node->this_obj,
                                        NULL,
                                        0, MAXINT, FALSE, NULL,
                                        p_curve),
                       senderid = NULL_OBJID,
                       targetid = p_intobj->this_xyzintobj.data.object->objid,
                       targetos = p_intobj->this_xyzintobj.data.object->osnum);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup); 
        }
        *pq_curve= p_curve;
wrapup:
       return;
      }



void EFget_vertex(EMmsg, env, p_intobj, surface, vertex_xyz)
IGRlong *EMmsg;
struct EMSintobj *p_intobj;
struct IGRbsp_surface *surface;
IGRdouble vertex_xyz[];
 {
  struct IGRbsp_curve *pq_curve;
  IGRlong stat_OM = OM_S_SUCCESS, msg_loc = EMS_S_Success;
  BSrc rc= BSSUCC;
  IGRdouble  dist, *upar=NULL,*vpar=NULL;
  IGRdouble *int_pts=NULL, *tpar=NULL,  min_dist=0.0;
  IGRint ii, ij, num_inters, min_inx=0;
  void EFget_curve_geom();
  extern  BScv_sf_int();

      if(p_intobj->this_xyzintobj.datatype==EMSdata_curve3d)
        pq_curve= p_intobj->this_xyzintobj.data.curve;
      else if(p_intobj->this_xyzintobj.datatype==EMSdata_object ||
              p_intobj->this_xyzintobj.datatype==EMSdata_poly3d ||
              p_intobj->this_xyzintobj.datatype==EMSdata_poly2d)
        {
        EFget_curve_geom(&msg_loc, env, p_intobj, &pq_curve);
        EMerr_hndlr(EMSerror(msg_loc), *EMmsg, EMS_E_Fail, wrapup);
        }
      else
        EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,wrapup); 

      num_inters=0;
      if(pq_curve && surface)
        {
        BScv_sf_int(&rc, pq_curve, surface, &num_inters, &int_pts, &tpar,
             &upar, &vpar);
        EMerr_hndlr (!(1&stat_OM&msg_loc), *EMmsg, EMS_E_Fail,wrapup); 
        }
      else
        {
        EMerr_hndlr (TRUE, *EMmsg, EMS_E_Fail,wrapup); 
        }

      if(p_intobj->this_xyzintobj.datatype!=EMSdata_curve3d)
          BSfreecv(&rc, pq_curve);

/** If there are multiple intersections between the curve and surface
    take the one which is closest to the approximate vertex point ****/

      if(num_inters==1)
         {
         for(ii=0;ii<3; ii++)
           vertex_xyz[ii] = int_pts[ii];
         }
      else if(num_inters > 1)
         {
         for(ij=0;ij<num_inters; ij++)
             {
             dist = BSdistptpt(&rc, &int_pts[ij*3], vertex_xyz);
             if(ij==0 || dist < min_dist)
                 {
                 min_dist = dist;
                 min_inx = ij;
                 }
             }
         for(ii=0;ii<3; ii++)
           vertex_xyz[ii] = int_pts[min_inx*3 + ii];
         }

wrapup:
      if(int_pts){om$dealloc(ptr=int_pts); int_pts=NULL;}
      if(tpar){om$dealloc(ptr=tpar); tpar=NULL;}
      if(upar){om$dealloc(ptr=upar); upar=NULL;}
      if(vpar){om$dealloc(ptr=vpar); vpar=NULL;}
 }


end  implementation EMSloop;



