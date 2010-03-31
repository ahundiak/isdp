class implementation EMSboundary;

#include "EMSdpr.h"

method EMfix_creator_id(IGRlong          *EMmsg; 
                        struct EMcp_info *cp_info;
                        GRobjid          new_creator_id;
                        OMuword          options)
/*
Description
    Fix up the creator_id.
    
Notes
    About options:
        EMfix_cr_id_VALIDATE - validate the stored creator id with the actual
                               and warn if a discrepancy is found.
History
    DLB 02/15/92    No real change in logic.  Just removed local_new_creator_id
                        declaration since it was unused.
    DLB 06/01/91    Creation.
*/
{
  IGRlong         OM_stat=OM_S_SUCCESS;
 
  *EMmsg = EMS_S_Success;
 
  if (options & EMfix_cr_id_VALIDATE)
  {
    if (ME.EMSboundary->creator_id != NULL_OBJID)
    {
      GRobjid saved_creator_id, returned_creator_id;;

      saved_creator_id = ME.EMSboundary->creator_id;
      ME.EMSboundary->creator_id = NULL_OBJID;
      OM_stat = EFget_creator_id(EMmsg, my_id, OM_Gw_current_OS,
                                 &returned_creator_id, NULL);
      ME.EMSboundary->creator_id = saved_creator_id;
      if (!(1 & OM_stat & *EMmsg)) goto wrapup;

      if (saved_creator_id != returned_creator_id)
      {
        fprintf(stderr,"ERROR: id (%d)!! stored creator (%d) differs ",
                my_id, saved_creator_id);
        fprintf(stderr,
                "from computed creator (%d) \n\tSetting to NULL_OBJID\n",
                returned_creator_id);
        ME.EMSboundary->creator_id = NULL_OBJID;
      }                                       
    }
  }
  else
  {
    if (cp_info)
    {
      IGRboolean  copy_exists;
      extern void EMcpsearch ();
  
      /*See if there's a map between  old creator id and the new creator id*/
      EMcpsearch(EMmsg, ME.EMSboundary->creator_id,
                 &ME.EMSboundary->creator_id, cp_info, 0, &copy_exists);
      if (!(1 & *EMmsg)) goto wrapup;
      
      if (!copy_exists) ME.EMSboundary->creator_id = new_creator_id;
    }
    else ME.EMSboundary->creator_id = new_creator_id;
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "bd.fixcrid")
  return (OM_stat);
}
end implementation EMSboundary;
