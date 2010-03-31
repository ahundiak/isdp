class implementation EMSsfimpbnd;

#include "nddef.h"
#include "ndmacros.h"
#include <alloca.h>
#include "REsfimpbnd.h"
#include "asbox.h"  /*For NULL_GRID*/
#include "OMmacros.h"
#include "EMSasnucdef.h"

method NDattach_to_track_pt(IGRlong *EMmsg; struct GRid pt_grid;
                            struct GRid *as_grid; struct GRmd_env *md_env)
/*
Description
    Attach track point parent to me after surface parent but before state
    parent.

History
    DLB  07/30/92    Update the assoc dude when the track point is detached.
    DLB  06/30/92    Creation.  
*/ 
{
  IGRlong        OM_stat=OM_S_SUCCESS;
  extern IGRlong EFattach_to_track_pt();


  *EMmsg = EMS_S_Success;

  /*For EMSsfimpbnd class, my parent information is formatted as...
   *      curve1...curveN, surface, state
   *    where state is on the comps channel
   *
   *  The following function assumes the track pt goes at the end of the
   *  father channel (after surface)  which is fine.
   */

  OM_stat = EFattach_to_track_pt(EMmsg, &pt_grid, my_id, OM_Gw_current_OS,
                                 as_grid,
                                 EMS_ASsfimpbnd_w_track_pt, NULL);

  EMWRAPUP(*EMmsg,OM_stat,"impbnd.NDatt_trac_pt")
  return (OM_stat);
}

method NDdetach_from_track_pt(IGRlong *EMmsg; struct GRid pt_grid;
                              struct GRid *as_grid; struct GRmd_env *md_env)
/*
Return values
   EMS_S_Success if all is well.

History
   DLB  06/30/92    Creation.  
*/ 
{
  IGRlong        OM_stat=OM_S_SUCCESS;
  extern IGRlong EFdetach_from_track_pt();


  *EMmsg = EMS_S_Success;

  OM_stat = EFdetach_from_track_pt(EMmsg, &pt_grid, my_id, OM_Gw_current_OS,
                                   as_grid, 
                                   EMS_ASsfimpbnd_w_track_pt, EMS_ASno_type,
                                   NULL);

  EMWRAPUP(*EMmsg,OM_stat,"impbnd.NDdet_trac_pt")
  return (OM_stat);
}

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
IGRlong EFattach_to_track_pt(EMmsg, pt_grid, att_id, att_os, as_grid, 
                             type_to_be, options)
IGRlong     *EMmsg; 
struct GRid *pt_grid;
GRobjid     att_id;
OMuword     att_os;
struct GRid *as_grid;
IGRuint     type_to_be;    
OMuword     options;
/*
Notes
    options - EFtrack_pt_func_NO_STATE_PARENTS - if set will disconnect the
              parent from the end instead of end-1.

History
    DLB 9/8/92 support new option.
*/
{
  IGRlong     OM_stat=OM_S_SUCCESS;
  IGRuint     type, info_size;
  IGRint      parent_count=0, comp_type;
  struct GRid my_grid, *buf_ptr=NULL, *parent_info=NULL;


  *EMmsg = EMS_S_Success;

  my_grid.objid = as_grid->objid = att_id;
  my_grid.osnum = as_grid->osnum = att_os;
    
  /*Look for a possible cycle in the graph*/
  if (nd$dep_exist(l_root = &my_grid,  nb_root = 1, 
                   l_tip  = pt_grid,  nb_tip = 1))
  {
    /*There is a cycle*/
    /*PRINT MSG??*/
    *EMmsg = EMS_E_InvalidSend; goto wrapup;
  }

  OM_stat = om$send(msg = message NDnode.NDget_objects(ND_IN_BUF | ND_ROOT,
                          NULL, 0, &buf_ptr, 0, MAXINT, &parent_count),
                    senderid = NULL_OBJID,
                    targetid = my_grid.objid,
                    targetos = my_grid.osnum);
  if (!(1 & OM_stat)) goto wrapup;
  if (!parent_count) {*EMmsg = EMS_E_InvalidArg; goto wrapup;}

  parent_info = (struct GRid *) alloca(parent_count * sizeof(struct GRid));

  OM_BLOCK_MOVE(buf_ptr, parent_info, parent_count * sizeof(struct GRid));

  OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL,
                          &type, &info_size, NULL),
                    senderid = NULL_OBJID,
                    targetid = my_grid.objid,
                    targetos = my_grid.osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  if (type == type_to_be)
  {
    /*Disconnect the existing track pt first*/
    IGRuint parent_index;

    if (options & EFtrack_pt_func_NO_STATE_PARENTS)
      parent_index = parent_count - 1;
    else
      parent_index = parent_count - 2;  

    OM_stat = om$send(msg = message NDnode.NDdisconnect(1, 
                            &parent_info[parent_index]),
                      senderid = NULL_OBJID,
                      targetid = my_grid.objid,
                      targetos = my_grid.osnum);
    if (!(1 & OM_stat)) goto wrapup;
  }
  
  OM_stat = om$send(msg = message NDnode.NDconnect(1, pt_grid,
                          NULL_GRID, ND_ADD), 
                    senderid = NULL_OBJID,
                    targetid = my_grid.objid,
                    targetos = my_grid.osnum);
  if (!(1 & OM_stat)) goto wrapup;

  if (type != type_to_be)
  {
    OM_stat = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL,
                            type_to_be, info_size, NULL),
                      senderid = NULL_OBJID,
                      targetid = my_grid.objid,
                      targetos = my_grid.osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }

  /*Put me on the batch so I will update*/
  comp_type = ND_COMP;

  nd$wait_batch(type = GR_GEOM_POSTED,
                nb_obj = 1,
                l_object = &my_grid,
                l_obj_info = &comp_type);
wrapup:
  EMWRAPUP(*EMmsg,OM_stat,"EFattach_to_track_pt")
  return (OM_stat);
}

#if __STDC__
#argsused
#else
/* ARGSUSED */
#endif
IGRlong EFdetach_from_track_pt(EMmsg, pt_grid, att_id, att_os, as_grid,
                               type_w_track, type_wo_track, options)
IGRlong     *EMmsg;
struct GRid *pt_grid;
GRobjid     att_id;
OMuword     att_os;
struct GRid *as_grid;
IGRuint     type_w_track, type_wo_track;
OMuword     options;

/*
Notes
    options - EFtrack_pt_func_NO_STATE_PARENTS - if set will disconnect the
              parent from the end instead of end-1.

History
    DLB 9/8/92 support new option.
*/
{
  IGRlong     OM_stat=OM_S_SUCCESS;
  IGRuint     type, info_size, parent_index;
  IGRint      parent_count=0, comp_type;
  struct GRid *buf_ptr=NULL, *parent_info=NULL, my_grid;


  *EMmsg = EMS_S_Success;

  my_grid.objid = as_grid->objid = att_id;
  my_grid.osnum = as_grid->osnum = att_os;  

  OM_stat = om$send(msg = message EMSassoc.EMget_info(EMmsg, NULL,
                          &type, &info_size, NULL),
                    senderid = NULL_OBJID,
                    targetid = my_grid.objid,
                    targetos = my_grid.osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  if (type != type_w_track)
  {*EMmsg = EMS_E_InvalidSend; goto wrapup;}

  /*Disconnect the existing track pt*/
  OM_stat = om$send(msg = message NDnode.NDget_objects(ND_IN_BUF | ND_ROOT,
                          NULL, 0, &buf_ptr, 0, MAXINT, &parent_count),
                    senderid = NULL_OBJID,
                    targetid = my_grid.objid,
                    targetos = my_grid.osnum);
  if (!(1 & OM_stat)) goto wrapup;
  if (!parent_count) {*EMmsg = EMS_E_InvalidArg; goto wrapup;}

  parent_info = (struct GRid *) alloca(parent_count * sizeof(struct GRid));

  OM_BLOCK_MOVE(buf_ptr, parent_info, parent_count * sizeof(struct GRid));

  if (options & EFtrack_pt_func_NO_STATE_PARENTS)
    parent_index = parent_count - 1;
  else
    parent_index = parent_count - 2;  

  OM_stat = om$send(msg = message NDnode.NDdisconnect(1, 
                          &parent_info[parent_index]),
                    senderid = NULL_OBJID,
                    targetid = my_grid.objid,
                    targetos = my_grid.osnum);
  if (!(1 & OM_stat)) goto wrapup;

  OM_stat = om$send(msg = message EMSassoc.EMput_info(EMmsg, NULL,
                          type_wo_track, info_size, NULL),
                    senderid = NULL_OBJID,
                    targetid = my_grid.objid,
                    targetos = my_grid.osnum);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  /*Put me on the batch so I will update*/
  comp_type = ND_COMP;

  nd$wait_batch(type = GR_GEOM_POSTED,
                nb_obj = 1,
                l_object = &my_grid,
                l_obj_info = &comp_type);

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFdetach_from_track_pt")
  return (OM_stat);
}
end implementation EMSsfimpbnd;
