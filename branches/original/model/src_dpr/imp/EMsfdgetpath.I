/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfdpr;

#include "EMS.h"
#include "EMSdpr.h"

method EMgettreepath(IGRlong *EMmsg; GRobjid **pathlist; 
                     IGRint *pathlist_count; IGRboolean unused)
/*
Description
   This method will return the tree path from the lowermost tree node
   (primitive) to the active dpr state.

Return Values
   EMS_S_Success    if all is well

Notes
   The initial sender of this method MUST set pathlist = NULL and
   pathlist_count = 0 

History
   DLB 03/22/93  Hack non-assoc boolfeas to work with loc intermed node.
   DLB 10/15/91  Added getInGeom send to generally throw out added geom 
                 from list.  This should allow all other DPR overrides
                 of this message to be deleted.
   DLB 06/11/89  Creation
*/

{
  IGRlong         OM_stat=OM_S_SUCCESS;
  IGRint          ii, num_in=0;
  GRobjid         *in=NULL;
  IGRboolean      add_sender=TRUE;
  extern OMuword  OPP_EMSsfboolfea_class_id, OPP_EMSslboolfea_class_id;
  extern OMuword  OPP_EMSslslotfea_class_id;


  *EMmsg = EMS_S_Success;    


  /*DLB hack - if my class is an EMSsfboolfea AND I'm not
   *            associative then convert to regular boolean so loc int nod 
   *            command will work on them as in 1.4.
   */
  if (!(ME.GRgraphics->properties & GRIS_ASSOCIATIVE) &&
       EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                         OPP_EMSsfboolfea_class_id, FALSE))
  {
    IGRchar boolclass[OM_K_MAXCLASS_LEN];
    OMuword senddepth;

    OM_stat = om$get_senddepth(p_depth = &senddepth);
    if (!(1 & OM_stat)) goto wrapup;

    /*Check for senddepth of only 1 to ensure no nested sends having access
     * to my instance data - for change_class.
     */

    if (senddepth < 2)
    {
      if ((EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                            OPP_EMSslboolfea_class_id, FALSE)) ||
        (EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                            OPP_EMSslslotfea_class_id, FALSE)))
        strcpy(boolclass, "EMSslboolean");      
      else
        strcpy(boolclass, "EMSsfboolean");      
  
      /*Convert it to a boolean.*/
      OM_stat = om$change_class(objid = my_id,
                                classname = boolclass,
                                sd_override = OM_K_change_class_sd_override);
      if (!(1 & OM_stat)) goto wrapup;                              
    }
  }

  OM_stat = om$send(msg = message EMSdpr.EMgetInGeomIds(EMmsg, NULL_OBJID,
                          FALSE, &num_in, &in, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;
                      
  for(ii=0; ii<num_in; ii++)
  {
    if (sender_id == in[ii])
    {
      add_sender = FALSE;
      break;
    }
  }

  if (add_sender)
  {
    EFrealloc_if_needed(EMmsg, pathlist, *pathlist_count, TREE_PATH_BUFF_INCR,
                        sizeof(GRobjid)); 
    if (!(1 & *EMmsg)) goto wrapup;

    (*pathlist)[*pathlist_count] = sender_id;
    (*pathlist_count)++;
  }

  /*Get the rest of the path.*/
  OM_stat = om$send(mode = OM_e_wrt_message,
                    msg = message EMSsurface.EMgettreepath(EMmsg,
                          pathlist, pathlist_count, unused),
                    targetid = my_id);
  if (!(1 & OM_stat & *EMmsg)) goto wrapup;

  wrapup:
    if (in) om$dealloc(ptr = in);
    EMWRAPUP(*EMmsg, OM_stat, "EMSsfdpr.EMgettreepath")
    return(OM_stat);
}
end implementation EMSsfdpr;
