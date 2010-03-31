/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdpr;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/
#include "emsdef.h"         /*EMmake_chanselect def.*/
#include "EMSmsgdef.h"
#include <stdio.h>
#include "bserr.h"
#include "bsbxint.h"

method EMcheckRngOverlap(IGRlong *EMmsg; 
                         GRobjid node_id; 
                         GRrange node_range; 
                         GRobjid nodes_side_id; 
                         struct GRmd_env *env; 
                         IGRboolean *does_overlap; 
                         IGRushort options)
/*
Description
    This message will determine if this tree node has an range overlap of
    'other side or changed' geometry wrt the added geometry.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        node_id  - the added node which is being checked against.
        node_range - the added nodes geometric range.
        nodes_side_id - the component of this state that contains the
                        replacing node.  This is needed by some states 
                        such as booleans where in the overlap of geometry can
                        only be determined relative to what has changed.  For
                        local operations this parameter MAY not be referenced.
        does_overlap - TRUE if an overlap is detected.
        options - currently unused.

History
    Sudha   06/23/93     Modified for BSprototype ansification

    DLB 11/30/92 If node_id is a comp surf then unroll it to each atomic
                 surface to allow better range overlap check.
    DLB 11/19/92 Unroll in_geom_ids to their atomic surfaces (subbs) to allow
                 better range overlap check.
    DLB 11/08/90 Modified for EMgetInGeomIds param change.
    DLB 10/17/89 Removed nodes_side_id computation. Also send EMgetInGeomIds
                 message rather than EMgetUnevalIds.
    DLB 07/27/89 Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  IGRint            num_ids=0, ii, jj, kk;
  IGRint            comp_cnt=0, node_comp_cnt=0;
  GRobjid           *ids=NULL;  
  GRrange           other_range, *node_atom_range=NULL;
  struct GRid       *comp_lst=NULL;
  IGRboolean        world=TRUE;
  extern OMuword    OPP_EMScompsurf_class_id, OPP_EMSsolid_class_id;


  *EMmsg = EMS_S_Success;
  *does_overlap = FALSE;

#if DEBUG
  if (OM_Gf_verbose_warning && node_id != NULL_OBJID)
  {
    IGRchar id_name[OM_K_MAXCLASS_LEN];
    id_name[0] = '\0';
    om$get_classname(objid = node_id, classname = id_name);
    fprintf(stderr,"+++intersecting %d (%s) with eval range+++\n", 
            node_id, id_name);
  }
#endif

  if (EFisAncestryValid(EMmsg, node_id, OM_Gw_current_OS, 
                        OPP_EMScompsurf_class_id, FALSE) &&
      !EFisAncestryValid(EMmsg, node_id, OM_Gw_current_OS,
                         OPP_EMSsolid_class_id, FALSE))
  {
    (void) EFgetcomponents(EMmsg, node_id, node_id, OM_Gw_current_OS,
                           &node_comp_cnt, &comp_lst);
    if (!(1 & *EMmsg)) goto wrapup;

    node_atom_range = (GRrange *) alloca(node_comp_cnt * sizeof(GRrange));

    for(ii=0; ii<node_comp_cnt; ii++)
    {
      OM_stat = om$send(msg = message GRgraphics.GRgetrang(EMmsg,
                              &env->md_env.matrix_type,
                              env->md_env.matrix,
                              &world,
                              node_atom_range[ii]),
                        targetid = comp_lst[ii].objid);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;
    }

    if (comp_lst)
    {
      om$dealloc(ptr = comp_lst);
      comp_lst = NULL;
    }
  }                                               

  /*Get the ids of the geometry added.  This is a relative term so
   * nodes_side_id must be given.
   */
  OM_stat = om$send(msg = message EMSdpr.EMgetInGeomIds(EMmsg, nodes_side_id,
                          FALSE, &num_ids, &ids, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  for(ii=0; ii<num_ids; ii++)
  {
    (void) EFgetcomponents(EMmsg, ids[ii], ids[ii], OM_Gw_current_OS,
                           &comp_cnt, &comp_lst);
    if (!(1 & *EMmsg)) goto wrapup;

    for(jj=0; jj<comp_cnt; jj++)
    {
      /*Get the range of each id and intersect it with the incoming range.*/
      OM_stat = om$send(msg = message GRgraphics.GRgetrang(EMmsg,
                              &env->md_env.matrix_type,
                              env->md_env.matrix,
                              &world,
                              other_range),
                        targetid = comp_lst[jj].objid);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (node_comp_cnt)
      {
        for(kk=0; kk<node_comp_cnt; kk++)
        {
          if (BSbxint(EMmsg, &node_atom_range[kk][0], &node_atom_range[kk][3],
                      &other_range[0], &other_range[3]))
          {
            *does_overlap = TRUE;
            *EMmsg = EMS_S_Success;  /*Because of BSbxint call.*/
            goto wrapup;
          }                 
        }
      }
      else
      {
        if (BSbxint(EMmsg, &node_range[0], &node_range[3],
                    &other_range[0], &other_range[3]))
        {
          *does_overlap = TRUE;
          *EMmsg = EMS_S_Success;  /*Because of BSbxint call.*/
          goto wrapup;
        }                 
      }
    }
    if (comp_lst)
    {
      om$dealloc(ptr = comp_lst);
      comp_lst = NULL;
      comp_cnt = 0;
    }
  }

  *EMmsg = EMS_S_Success;  /*Because of BSbxint call.*/

wrapup:
  if (ids) om$dealloc(ptr = ids);
  if (comp_lst) om$dealloc(ptr = comp_lst);
  if (!(1 & OM_stat & *EMmsg)) *does_overlap = TRUE;
  EMWRAPUP(*EMmsg, OM_stat, "EMSdpr.EMcheckRngOverlap")
  return(OM_stat);
}
end implementation EMSdpr;
