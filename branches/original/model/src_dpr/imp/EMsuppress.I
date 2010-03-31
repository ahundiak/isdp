class implementation EMSsuppress;

#include "OMmacros.h"
#include "emsdef.h"
#include "stdio.h"
#include "EMSopt.h"
#include "asbox.h" /*NULL_GRID*/
#include "nddef.h" /*ND_NEW*/
#include "EMSdpr.h"

IGRlong EFcreate_suppress_id(EMmsg, tree_id, tree_os, suppress_id, options)
IGRlong         *EMmsg;
GRobjid         tree_id;
OMuword         tree_os;
GRobjid         *suppress_id;
OMuword         options;
{
  IGRlong     OM_stat=OM_S_SUCCESS;
  struct GRid root;
  OMuword     clid;
  extern OMuword OPP_EMSpartsupp_class_id;


  if (options & EFcreate_supp_id_CREATE_PARTIAL)
    clid = OPP_EMSpartsupp_class_id;
  else
    clid = OPP_EMSsuppress_class_id;

  OM_stat = om$construct(classid = clid,
                         osnum = tree_os,
                         p_objid = suppress_id);
  if (!(1 & OM_stat)) goto wrapup;

  root.objid = tree_id,
  root.osnum = tree_os;
  OM_stat = om$send(msg = message NDnode.NDconnect(1, &root, NULL_GRID,
                          ND_NEW),
                    senderid = tree_id,
                    targetid = *suppress_id,
                    targetos = tree_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFcreate_suppress_id")
  return(OM_stat);
}


method EMget_suppress_id(IGRlong         *EMmsg;
                         GRobjid         *suppress_id;
                         OMuword         options)
{
  *EMmsg = EMS_S_Success;
  *suppress_id = my_id;
  return(OM_S_SUCCESS);
}


method EMget_suppressed_geom(IGRlong         *EMmsg;
                             IGRint          *num_suppressed_geom_ids;
                             GRobjid         **suppressed_geom_ids;
                             OMuword         options)
{ 
  IGRlong             OM_stat=OM_S_SUCCESS;
  OMuint              comp_cnt, ii;
  OM_S_CHANSELECT     to_comps;
  OM_S_OBJECT_LINKAGE *link=NULL;


  *EMmsg = EMS_S_Success;
  *num_suppressed_geom_ids = 0;
  *suppressed_geom_ids = NULL;

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);
  OM_stat = om$get_channel_count(object = me,
                                 p_chanselect = &to_comps,
                                 count = &comp_cnt);
  if (!(1 & OM_stat) || !comp_cnt) goto wrapup;

  link = (OM_S_OBJECT_LINKAGE *) alloca(comp_cnt*sizeof(OM_S_OBJECT_LINKAGE));
  if (!link) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}
      
  OM_stat = om$get_channel_objects(object = me,
                                   p_chanselect = &to_comps,
                                   list = link,
                                   size = comp_cnt,
                                   count = &comp_cnt);
  if (!(1 & OM_stat)) goto wrapup;

  if (comp_cnt)
  {
    GRobjid *sup;

    *suppressed_geom_ids = (GRobjid *) om$malloc
                           (size = comp_cnt * sizeof(GRobjid)); 
    if (!*suppressed_geom_ids) {*EMmsg = EMS_E_NoDynamicMemory; goto wrapup;}
  
    sup = *suppressed_geom_ids;

    for(ii=0; ii<comp_cnt; ii++, sup++)
    {
      *sup = link[ii].S_objid;
    }

    *num_suppressed_geom_ids = comp_cnt;
  }

wrapup:
  /*if (link) allocf(link); PORTING_CATCHER*/
  EMWRAPUP(*EMmsg, OM_stat, "supp.EMget_suppressed_geom")
  return(OM_stat);
}


method EMmove_comps(IGRlong    *EMmsg; 
                    GRobjid    dpr;
                    IGRboolean to_suppress;
                    IGRint     num_comps;
                    GRobjid    *comps;
                    OMuword    options)
/*
Description
    This message will set the props bits in the props instance data.

Returned values
    EMSS_S_Success if all is well.

Notes
    About parameters:
      to_suppress - If TRUE move array of "comps" to the suppress object.
                    Else move all comps on suppress object back to dpr.
      options     - None so far.
       
History
    07/19/91    DLB     Creation.
*/ 
{
  IGRlong     OM_stat=OM_S_SUCCESS;
  IGRlong     owner_index=OM_K_MAXINT, ii;
  struct GRid owner_GRid;


  *EMmsg = EMS_S_Success;

  owner_GRid.osnum = OM_Gw_current_OS;

  if (to_suppress)
  {
    for(ii=0; ii<num_comps; ii++)
    {
      owner_GRid.objid = dpr;
      OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                              &owner_GRid), 
                        targetid = comps[ii]);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      owner_GRid.objid = my_id;
      OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                              &owner_GRid, &owner_index),
                        targetid = comps[ii]);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        

      (void) EFsetsfstate(EMmsg, comps[ii], OM_Gw_current_OS, EMS_O_OFF);
    }
  }
  else
  {
    OMuint          comp_cnt;
    GRobjid         comp;
    OM_S_CHANSELECT to_comps;
    OMuword         dumosnum;

    EMmake_chanselect(GRcmpowner_to_components, &to_comps);
    OM_stat = om$get_channel_count(object = me,
                                   p_chanselect = &to_comps,
                                   count = &comp_cnt);
    if (!(1 & OM_stat)) goto wrapup;                                   
    
    for(ii=0; ii<comp_cnt; ii++)
    {
      OM_stat = om$get_objid_at_index(object = me,
                                      p_chanselect = &to_comps,
                                      index = ii,
                                      objidaddr = &comp,
                                      osnumaddr = &dumosnum);
      if (!(1 & OM_stat)) goto wrapup;

      owner_GRid.objid = my_id;

      OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg,
                              &owner_GRid), 
                        targetid = comp);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      owner_GRid.objid = dpr;
      OM_stat = om$send(msg = message GRconnector.GRrigidconn(EMmsg,
                              &owner_GRid, &owner_index),
                        targetid = comp);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;                        

      (void) EFsetsfstate(EMmsg, comps[ii], OM_Gw_current_OS, EMS_O_ON);
    }                                            
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "supp.EMmove_comps")
  return(OM_stat);  
}                      


method debug()
{
  fprintf(stderr,"suppress props = 0x%x\n", ME.EMSsuppress->props);

  return(OM_S_SUCCESS);
}

method EMsetProps(IGRlong *EMmsg; IGRboolean clear; OMuword props)
/*
Description
    This message will set the props bits in the props instance data.

Returned values
    EMSS_S_Success if all is well.

Notes
    About parameters:
      clear - If TRUE clear the specified bits.
 
History
    07/19/91    DLB     Creation.
*/ 
{
  *EMmsg = EMS_S_Success;

  if (clear) ME.EMSsuppress->props &= ~props;
  else ME.EMSsuppress->props |= props;

  return(OM_S_SUCCESS);
}

method NDmove_to_root(IGRlong *EMmsg; struct GRid *src_grid;
                      struct GRmd_env *env)
{
  return(om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                 targetid = my_id));
}                      

method NDcompute_node(IGRlong *msg; IGRint cn_type;
                      IGRint count; struct GRid list []; 
                      struct GRmd_env *md_env)
{
  *msg = ND_COMP_SUCC;  
  return(OM_S_SUCCESS);
}                       

#if THIS_HAS_BEEN_REMOVED_REPLACED_BY_DPR_DELETE_FEA_MESSAGE
from EMSdpr import EMremove;

method EMdelete_suppressed(IGRlong           *EMmsg;
                           struct GRmd_env   *env;
                           OMuword           options)
{
  IGRlong             OM_stat=OM_S_SUCCESS;
  OMuint              cnt;
  struct GRid         dpr_GRid;
  OM_S_CHANSELECT     to_father, to_comps;
  OM_S_OBJECT_LINKAGE dpr_link;


  EMmake_chanselect(NDfather_father, &to_father);
  
  OM_stat = om$get_channel_objects(object = me,
                                   p_chanselect = &to_father,
                                   list = &dpr_link,
                                   size = 1,
                                   count = &cnt);
  if (!(1 & OM_stat)) goto wrapup;

  if (!cnt) {*EMmsg = EMS_E_InvalidCase; goto wrapup;}

  EMmake_chanselect(GRcmpowner_to_components, &to_comps);

  dpr_GRid.objid = dpr_link.S_objid;
  dpr_GRid.osnum = OM_Gw_current_OS;

  OM_stat = om$send(msg = message GRconnector.GRdisconn(EMmsg, &dpr_GRid),
                    senderid = dpr_GRid.objid,
                    p_chanselect = &to_comps,
                    from = 1, to = OM_K_MAXINT);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  OM_stat = om$send(msg = message EMSdpr.EMremove(EMmsg, NULL),
                    targetid = dpr_GRid.objid);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  /*Delete the added geom on the suppress id*/
  {
    GRobjid tmp_id;

    fprintf(stderr,"Not removing geom from rtree\n");
    tmp_id = env->md_id.objid;
    env->md_id.objid = NULL_OBJID;
    OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                      p_chanselect = &to_comps);
    env->md_id.objid = tmp_id;
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
  }

  /*Delete me*/
  OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
                                         
  /*Add the dpr id to the delete batch.*/
#if MODEL_LATER_THAN_20
  {
    nd$wait_batch(type = GR_DELETED,
                  p_fr_info = env,
                  nb_obj = 1,
                  l_object = &dpr_GRid,
                  l_obj_info =  env);
  }
#else
  fprintf(stderr,"nd$wait_batch not performed\n");
  OM_stat = om$send(msg = message GRgraphics.GRdelete(EMmsg, env),
                    targetid = dpr_GRid.objid);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
#endif

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "sup.del_sup")
  return(OM_stat);
}                           
#endif

/*
 * Need to override NDget_objects since EMSsuppress overrides NDchildren,
 * which means it does not have a NDchildren.children channel; if NDget_objects
 * is requesting the children objects, this method should return a count of
 * zero and a return code of success. (TR 119314250 and 119314253)
 */

method NDget_objects(int type; struct GRid *list; int size;
		     struct GRid **buffer; int ifrom, ito, *count)
{
    IGRint status;

    if (type & ND_ROOT)
    {
        status = om$send(mode = OM_e_wrt_message,
                         msg = message NDnodein.NDget_objects(type, list,
                                                              size, buffer,
                                                              ifrom, ito,
                                                              count),
                         targetid = my_id);
    }
    else
    {
        *count = 0;
        status = OM_S_SUCCESS;
    }

    return(status);
}

/*
 * Need to override NDmove_to_tmp_clone since EMSsuppress overrides NDchildren,
 * which means it does not have a NDchildren.children channel; since this
 * moves the objects on the children channel, it doesn't need to do anything
 */

method NDmove_to_tmp_clone(long *msg; struct GRid *clone)
{
    *msg = MSSUCC;
    return (OM_S_SUCCESS);
}

end implementation EMSsuppress;
