class implementation EMSsurface;

#include "EMSdpr.h"
#include "memory.h"

from EMSboundary import EMgetsurface_info, EMget_put_creator_id;
from EMSsubbs    import EMgetowner;
from EMSdpr      import EMgetInInfo, EMgetInGeomIds;

extern OMuword OPP_EMSdpr_class_id;
extern OMuword OPP_ACconst_class_id, OPP_EMScreator_class_id, 
               OPP_GRclhdr_class_id,
               OPP_GRsmdfhdr_class_id,
               OPP_VDSroot_class_id,
               OPP_EMSassoc_class_id,
               OPP_EMSdpr_class_id,
               OPP_EMSdprparam_class_id,		
               OPP_EMSasectvw_class_id;


IGRlong EFget_creator_id(EMmsg, created_id, created_os, creator_id, options) 
IGRlong           *EMmsg; 
GRobjid           created_id;
OMuword           created_os;
GRobjid           *creator_id;
IGRushort options;
/*
Description
    This function returns the id of the element that created the sf/lp/ed
    given.

Return Values    
    EMSS_S_Success if all is well.

Notes

History
    DLB 10/14/92    If bdry element's creator is not valid or not of the
                    supported type, try to find the right one.
    WBC 08/11/92    Support EMSasectvw (Section View) as creator of sf/sl.
    DLB 05/28/92    Support ACconst (construction macro) as creator of sf/sl.
    DLB 01/03/92    Fix oversight where solid owned by a dpr is actually 
                    created geometry.  In this case the code would say the
                    solid was the creator of its surfaces and topology instead
                    of the dpr.
    DLB 06/19/91    If the creator is found to be a non-surface element
                    then issue an error and return NULL_OBJID.
    DLB 05/24/91    Handle created topology thats part of an added surface.
    DLB 05/15/91    Fixed bug in check for EMS_I_NotFound.
    DLB 05/11/91    Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRint          num_in=0;
  GRobjid         sf_id, top_id, top_comp_id, *in=NULL, saved_created_id;
  struct EMSinlist  inlist;
  IGRboolean        created_is_topology=FALSE, free_inlist=FALSE,
                    store_creator=FALSE ;
  extern IGRboolean EFisAncestryValid();
  extern OMuword  OPP_EMSboundary_class_id,
                  OPP_EMSsubbs_class_id;
  IGRlong        EFget_dpr_creator_id();

  *EMmsg = EMS_S_Success;

  *creator_id = sf_id = top_id = top_comp_id = NULL_OBJID;
  saved_created_id = created_id;

  if (EFisAncestryValid(EMmsg, created_id, created_os,
                        OPP_EMSboundary_class_id, FALSE))
  {
    OM_stat = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg,
                            creator_id, FALSE),
                      senderid = NULL_OBJID, 
                      targetid = created_id,
                      targetos = created_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
                       
    if (*creator_id != NULL_OBJID && *creator_id != 0)
    {
      if (EFisAncestryValid(EMmsg, *creator_id, created_os,
                            OPP_ACconst_class_id, TRUE) ||
          EFisAncestryValid(EMmsg, *creator_id, created_os,
                            OPP_EMSasectvw_class_id, TRUE) ||
          EFisAncestryValid(EMmsg, *creator_id, created_os,
                            OPP_EMScreator_class_id, TRUE)) goto wrapup;
      else
      {
        store_creator = TRUE;
	*creator_id = NULL_OBJID;
      }
    }
    else store_creator = TRUE;

    created_is_topology = TRUE;
    OM_stat = om$send(msg = message EMSboundary.EMgetsurface_info(EMmsg,
                            &sf_id, NULL),
                      senderid = NULL_OBJID, 
                      targetid = created_id,
                      targetos = created_os);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      

    if (sf_id == NULL_OBJID)
    {
      *EMmsg = EMS_E_NotFound;
      goto wrapup;
    }
  }
  else sf_id = created_id;  /*set up for EMget_tree_top send.*/
  
  /*Get the top composite and the first dpr.*/
  OM_stat = om$send(msg = message EMSsurface.EMget_tree_top(EMmsg,
                          &top_id, &top_comp_id, EMget_tree_top_FIRST_DPR),
                    senderid = NULL_OBJID, 
                    targetid = sf_id,
                    targetos = created_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      
                            
  /*Check special case of a construction macro and section view.  In this case,
   * the entire structure is rigidly owned by either a ACconst or EMSasectvw
   * object - who is considered the creator.  If such a case is detected,
   * return the ACconst or EMSasectvw owner.  Note that there can be multiple
   * ACconst objects so a loop is used.
   */
  {
    GRobjid        tmp_top_id;
    IGRshort       grprops;
    IGRboolean     got_ACconst=FALSE;
    
    /* 
       SM 12/23/93
       top_id = top DPR state
       top_comp_id = top composite sate.
       If there is a DPR it will always be above the top composite, so
       we take that. 
       If there is no DPR, use the top composite.
    */
    tmp_top_id = (top_id == NULL_OBJID) ? top_comp_id : top_id;

/* END SM 12/23/93 */

    for (;;)
    {
      OM_stat = om$send(msg = message GRgraphics.GRgetprops(EMmsg, &grprops),
                        senderid = NULL_OBJID,
                        targetid = tmp_top_id,
                        targetos = created_os);
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (grprops & GR_RIGID_RELATIONSHIP)
      {
        OM_S_CHANSELECT to_owners;

        EMmake_chanselect(GRconnector_to_owners, &to_owners);

        OM_stat = om$get_objid_at_index(objid = tmp_top_id,
                                        osnum = created_os,
                                        p_chanselect = &to_owners,
                                        index = 0,
                                        objidaddr = &tmp_top_id,
                                        osnumaddr = &created_os);
        if (!(1 & OM_stat)) goto wrapup;

        if (!EFisAncestryValid(EMmsg, tmp_top_id, created_os,
                               OPP_ACconst_class_id, FALSE)   &&
            !EFisAncestryValid(EMmsg, tmp_top_id, created_os,
                               OPP_EMSasectvw_class_id, FALSE))
        {
         if ((EFisAncestryValid(EMmsg, tmp_top_id, created_os,
                               OPP_EMSdprparam_class_id, FALSE)) ||
             (EFisAncestryValid(EMmsg, tmp_top_id, created_os,
                               OPP_GRclhdr_class_id, FALSE)) ||
             (EFisAncestryValid(EMmsg, tmp_top_id, created_os,
                               OPP_GRsmdfhdr_class_id, FALSE)) ||
             (EFisAncestryValid(EMmsg, tmp_top_id, created_os,
                               OPP_EMSassoc_class_id, FALSE)) ||
             (EFisAncestryValid(EMmsg, tmp_top_id, created_os,
                               OPP_EMSdpr_class_id, FALSE))   ||
             (EFisAncestryValid(EMmsg, tmp_top_id, created_os,
                               OPP_VDSroot_class_id, FALSE)))
          break;
         else
         {
/*
 * We do not support association to elements of this type. Return error.
 */
          *creator_id = NULL_OBJID;
          goto wrapup;
         }

/* end pp */

        }
        else            
        {
          /* Got at least 1 ACconst or EMSasectvw object so record and go on
           * to see if another...
           */

          top_id = tmp_top_id;
          got_ACconst = TRUE;
        }
      }
      else break;
    } 

    if (got_ACconst)
    {
      *creator_id = top_id;
      goto wrapup;
    }
  }

  if (created_is_topology && EFisAncestryValid(EMmsg, top_id, created_os,
                                               OPP_EMSdpr_class_id, FALSE)) 
  {
    *creator_id = NULL_OBJID;

    memset((char *) &inlist, '\0', sizeof(struct EMSinlist));
    free_inlist = TRUE;

    OM_stat = EFget_dpr_creator_id(EMmsg, created_id, creator_id, created_os,
                                   &inlist, top_id, NULL);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (*creator_id != NULL_OBJID) goto wrapup;

    /*Now, the created id was not part of any DPR's in info.  So, proceed to
     * determine if the surface it is part of is an added surface of a DPR or
     * just part of a composite or just part of an independent surface.
     */
    created_id = sf_id;    
  }

  if (top_comp_id != NULL_OBJID)
  {
    *creator_id = top_comp_id;  /*say is top comp until told otherwise.*/

    if (top_id != NULL_OBJID)
    {
      /*created is owned by a DPR.  Is it the creator?  If msg is unknown
       * then creator is top non-dpr composite
       */
      OMuint ii;
      OM_stat = om$send(msg = message EMSdpr.EMgetInGeomIds(EMmsg,
                              NULL_OBJID, FALSE, &num_in, &in, NULL),
                        senderid = NULL_OBJID, 
                        targetid = top_id,
                        targetos = created_os);
      if (!(1&OM_stat&*EMmsg) && (OM_stat!=OM_W_UNKNOWN_MSG)) goto wrapup;
      OM_stat = OM_S_SUCCESS;
        
      for(ii=0; ii<num_in; ii++)
      {
        if (created_id == in[ii] || top_comp_id == in[ii])
        {
          *creator_id = top_id;
          break;
        }
      }
    }
  }
  else *creator_id = created_id;   /*Should never happen but...*/

  if (EFisAncestryValid(EMmsg, *creator_id, created_os,
                        OPP_EMSboundary_class_id, FALSE))
  {
    *EMmsg = EMS_E_Ambiguous;
    fprintf(stderr,
            "WARNING: Creator was found to be a topology element (%d)\n",
            *creator_id); 
    *creator_id = NULL_OBJID;
    store_creator = FALSE;
  }                         

wrapup:
  if (store_creator && created_is_topology)
  {
    OM_stat = om$send(msg = message EMSboundary.EMget_put_creator_id(EMmsg,
                            creator_id, TRUE),
                      senderid = NULL_OBJID, 
                      targetid = saved_created_id,
                      targetos = created_os);
  }                       
  if (free_inlist)
  {
    if (inlist.sflist.surf_ids) om$dealloc(ptr = inlist.sflist.surf_ids);
    if (inlist.lplist.loop_ids) om$dealloc(ptr = inlist.lplist.loop_ids);
    if (inlist.edlist.edge_ids) om$dealloc(ptr = inlist.edlist.edge_ids);
  }
  if (in) om$dealloc(ptr = in);
  EMWRAPUP(*EMmsg, OM_stat, "EFget_creator_id")
  return(OM_stat);
}


IGRlong EFget_dpr_creator_id(EMmsg, created_id, creator_id, osnum,
                             inlist, dpr_id, options)
IGRlong          *EMmsg;
GRobjid          created_id;
GRobjid          *creator_id;
OMuword          osnum;
struct EMSinlist *inlist;
GRobjid          dpr_id;
OMuword          options;

/*
Description
    Find who created the sf/lp/ed.
    
Notes
    No options...yet.

    The entire tree should be active (not partially undone).

History
    DLB 03/24/93    Hack problem where del sf bnd does not have added geom but 
                    stitch is a dependent.  So getInInfo on del sf bnd returns
                    edges it disconnected but dont want del sf bnd to be 
                    seen as the creator of those edges.
    DLB     05/11/91    Creation.
*/
{
  IGRlong           OM_stat=OM_S_SUCCESS;
  GRobjid           owner_id;
  OM_S_CHANSELECT   to_owners;
  IGRboolean        EFisAncestryValid();
  OMuword           dumosnum;
  extern OMuword    OPP_EMSedge_class_id;
  IGRlong           EFfind_created();

  *EMmsg = EMS_S_Success;

  /*Process the states top down, therefore send up first*/

  EMmake_chanselect(GRconnector_to_owners, &to_owners);
  OM_stat = om$get_objid_at_index(objid = dpr_id,
                                  osnum = osnum,
                                  index = 0,
                                  p_chanselect = &to_owners,
                                  objidaddr = &owner_id,
                                  osnumaddr = &dumosnum);
  if ((1 & OM_stat) &&
      EFisAncestryValid(EMmsg, owner_id, osnum, OPP_EMSdpr_class_id,
                        FALSE))
  {
    OM_stat = EFget_dpr_creator_id(EMmsg, created_id, creator_id, osnum,
                                   inlist, owner_id, options);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
  }
  else OM_stat = OM_S_SUCCESS;

  /*DLB hack 3/24/93 - see above.*/
  {
    extern OMuword OPP_EMSsfrembnd_class_id;
    
    if (EFisAncestryValid(EMmsg, dpr_id, osnum, OPP_EMSsfrembnd_class_id,
                          FALSE)) goto wrapup;
  }

  if (*creator_id == NULL_OBJID)
  {
    /*The owner didn't find it.  Did the dpr_id do it?*/
    OMuint     list_index;
    IGRboolean found_created=FALSE, in_edge_list=FALSE;

    inlist->sflist.num_surfs = 0;
    inlist->lplist.num_loops = 0;
    inlist->edlist.num_edges = 0;

    OM_stat = EFfind_created(EMmsg, created_id, dpr_id, osnum, inlist,
                             &found_created, &in_edge_list, &list_index, NULL);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;

    if (found_created) *creator_id = dpr_id;
  }
  
wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFget_dpr_creator_id")
  return(OM_stat);
} 


IGRlong EFfind_created(EMmsg, created_id, creator_id, created_os, inlist,
                       found_created, in_edge_list, list_index, options)
IGRlong             *EMmsg;
GRobjid             created_id;
GRobjid             creator_id;
OMuword             created_os;
struct EMSinlist    *inlist;
IGRboolean          *found_created;
IGRboolean          *in_edge_list;
OMuint              *list_index;
OMuword             options;
{
  IGRlong OM_stat=OM_S_SUCCESS;
  OMuint  ii;
  OMuword ininf_opts;
  IGRboolean created_is_a_edge;
  extern IGRboolean EFisAncestryValid();
  extern OMuword    OPP_EMSedge_class_id;

  *EMmsg = EMS_S_Success;

  created_is_a_edge = EFisAncestryValid(EMmsg, created_id, created_os,
                                        OPP_EMSedge_class_id, FALSE);

  ininf_opts = EMget_in_inf_NO_SURFS;
  ininf_opts |= options & EFfind_created_NO_EDGES ? EMget_in_inf_NO_EDGES :
                                                    NULL;    
  ininf_opts |= options & EFfind_created_NO_LOOPS ? EMget_in_inf_NO_LOOPS :
                                                    NULL;
  ininf_opts |= options & EFfind_created_NO_EDGES_FROM_LOOPS ? 
                                         EMget_in_inf_NO_EDGES_FROM_LOOPS :
                                         NULL;

  OM_stat = om$send(msg = message EMSdpr.EMgetInInfo(EMmsg, inlist,
                          NULL_OBJID, FALSE,
                          ininf_opts),
                    senderid = NULL_OBJID,
                    targetid = creator_id,
                    targetos = created_os);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (created_is_a_edge)
  {
    for (ii=0; ii<inlist->edlist.num_edges; ii++)
    {
      if (inlist->edlist.edge_ids[ii] == created_id)
      {
        *found_created = TRUE;
        *in_edge_list = TRUE;
        *list_index = ii;
        goto wrapup;
      }
    }
  }
  else
  {
    for (ii=0; ii<inlist->lplist.num_loops; ii++)
    {
      if (inlist->lplist.loop_ids[ii] == created_id) 
      {
        *found_created = TRUE;
        *in_edge_list = FALSE;
        *list_index = ii;
        goto wrapup;
      }
    }
  }    

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EFfind_created")
  return(OM_stat);
}

end implementation EMSsurface;
