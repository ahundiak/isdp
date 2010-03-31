/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMSdpr.h"         /*EMSinlist; KNOWN_DEPENDENT*/
#include "EMSdprquery.h"    /*DPR_BUFF_INCR*/

method EMcheckOverlap(IGRlong          *EMmsg; 
                      struct EMSinlist *inlist; 
                      IGRboolean       *does_overlap; 
                      IGRushort options)
/*
Description
    This message will determine if this tree node has an overlap of
    surfaces/topology based on the inlist or outlist.

Return Values    
    EMSS_S_Success if all is well.

Notes
    About parameters:
        inlist  - contains surf/loop/edge ids that have been added/removed  so
                  far.          
        does_overlap - TRUE if an overlap is detected.
        options - EMcheck_overlap_TREAT_SFS_AS_SFMOD - if specified, treat
                  the ids in the sflist as surfs modified.

    For the special case of a non-intersecting boolean (disjoint or hollow),
    this method will always report an overlap.  

    For the special case of a non-intersection intersect plane - save side,
    this method will always report an overlap.

History
    DLB 03/03/92 Wasnt checking for removal of surfs in inlist.
    DLB 02/08/91 Use EFcheck_overlap function.
    DLB 11/08/90 Added check for added/rem loop owning list edge id (due to
                 local mod recompute).
    DLB 12/13/88 Creation.
*/
{
  IGRlong                 OM_stat=OM_S_SUCCESS;
  enum EMSbooltype        exact_op;
  union EMSssi_table      *ssi=NULL;
  IGRint                  ii, jj, kk;
  GRobjid                 *ssi_id;
  struct EMSboolssi_table *my_info=NULL;
  IGRboolean              disj_op;


  *EMmsg = EMS_S_Success;
  *does_overlap = FALSE;

  if (options & EMcheck_overlap_TREAT_SFS_AS_SFMOD) goto wrapup;

  /*Get my operation type.*/
  disj_op = FALSE;
  OM_stat = om$send(msg = message EMSsfboolean.EMget_operation_type(EMmsg, 
                          NULL, &exact_op, NULL, NULL, NULL, &disj_op,
                          NULL, NULL, NULL, NULL, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  if (disj_op || 
      ((exact_op == EMSbool_saveside) && 
      (ME.EMSdpr->dpr_props & EMS_UNEVAL_STATE)))
  {
    /*Either disjoint boolean or disjoint saveside so assume overlap.*/  
    *does_overlap = TRUE;
    goto wrapup;
  }

  /*Get the SSI stuff.*/
  OM_stat = om$send(msg = message EMSdpr.EMgetSSI(EMmsg, &ssi),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;                    

  my_info = &ssi->bool_info;

  /*For every surface of the inlist struct...*/
  for(ii=0; ii<inlist->sflist.num_surfs; ii++)
  {
    /*Is it removed by this state?*/
    ssi_id = my_info->surface_out_ids;

    for(jj=0; jj<my_info->num_composites; jj++)
    {
      for(kk=0; kk<my_info->num_surfaces_out[jj]; kk++, ssi_id++)
      {
        if (inlist->sflist.surf_ids[ii] == *ssi_id)
        {
          *does_overlap = TRUE;
          goto wrapup;
        }
      }
    }
  }

  OM_stat = EFcheck_overlap(EMmsg, inlist,
                            my_info->num_surfaces,
                            my_info->surface_ids,
                            my_info->num_regions_out,
                            my_info->region_out_ids,
                            0, NULL,
                            0, NULL,
                            0, NULL,
                            0, NULL,
                            does_overlap,
                            OM_Gw_current_OS, NULL);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

wrapup:
  if (ssi) om$dealloc(ptr = ssi);
  EMWRAPUP(*EMmsg, OM_stat, "EMSsfbool.EMchkOvlap")
  return(OM_stat);
}
end implementation EMSsfboolean;
