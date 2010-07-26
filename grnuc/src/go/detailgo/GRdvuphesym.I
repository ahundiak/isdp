/*
Name
    GRdvuphesym

Description
    This method updates the symbology of all the reference files attached through
    a drawing view. 

Arguments
   struct GRhesym *hesym 	The new hidden edge symbology
                                          
Return Values
   MSSUCC   -  if success
   MSFAIL   -  if failure
*/
class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>


GRdvuphesym ( hesym )
struct GRhesym *hesym	/* The new hidden edge symbology		IN  */;
/*
   This function updates the symbology of all the drawing views with hesym.
*/
{
  OM_S_CHANSELECT   to_ref, to_owner;
  struct GRid       module, super, ref, drawing;
  struct IGRdisplay display;
  int               i; 
  OMuint            count;
  short             flag;
  long              msg; 
  unsigned long     properties;
  OMuword           owner_classid;
  extern OMuword    OPP_GRdvattach_class_id;
  
  /* get the objid of the reference file manager */
  ex$get_cur_mod ( id = &module.objid, osnum = &module.osnum );
  super.objid = NULL_OBJID;
  ex$get_super ( mod_id = module.objid,
                 mod_osnum = module.osnum,
                 super_name = REFERENCE_FILE_MANAGER,
                 create = 0,
                 super_id = &super.objid,
                 super_osnum = &super.osnum );

  if (super.objid != NULL_OBJID)
  {
    om$make_chanselect ( channame = "Super_rfmgr.mgr", p_chanselect = &to_ref );
    om$make_chanselect ( channame = "GRconnector.to_owners", p_chanselect = &to_owner );

    /* get the number of attachments */
    om$get_channel_count ( objid = super.objid,
                           osnum = super.osnum,
                           p_chanselect = &to_ref,
                           count = &count );
    if (count)
    {
      if ((hesym->flags & DPB_USE_ORIG_COLOR) &&
          (hesym->flags & DPB_USE_ORIG_WEIGHT) &&
          (hesym->flags & DPB_USE_ORIG_STYLE))
      {
        /* remove the alternate symbology of all attachments */
        flag = 0 /* clear properties */;
        properties = GROVERRIDE_SYMBOLOGY;
        display.color = (unsigned short) ~0;
        display.weight = display.style = (unsigned char) ~0;
      }
      else
      {
        /* set the alternate symbology for all attachments */
        flag = 1 /* set properties */;
        properties = GROVERRIDE_SYMBOLOGY;
        display.color = (hesym->flags & DPB_USE_ORIG_COLOR) ? 
                              (unsigned short) ~0 : hesym->color;
        display.weight = (hesym->flags & DPB_USE_ORIG_WEIGHT) ? 
                              (unsigned char) ~0 : hesym->weight;
        display.style = (hesym->flags & DPB_USE_ORIG_STYLE) ? 
                              (unsigned char) ~0 : hesym->style;
      }
            
      for (i = 0; i < count; i++)
      {
        om$get_objid_at_index ( objid = super.objid,
                                osnum = super.osnum,
                                p_chanselect = &to_ref,
                                index = i,
                                objidaddr = &ref.objid,
                                osnumaddr = &ref.osnum );
        
        /* we want the ones connected to a drawing view */
        drawing.objid = NULL_OBJID;
        om$get_objid_at_index ( objid = ref.objid,
                                osnum = ref.osnum,
                                p_chanselect = &to_owner,
                                index = 0,
                                objidaddr = &drawing.objid,
                                osnumaddr = &drawing.osnum );
        
        if (drawing.objid != NULL_OBJID)
        {
          om$get_classid ( osnum = drawing.osnum,
                           objid = drawing.objid,
                           p_classid = &owner_classid );
          if ((om$is_ancestry_valid ( superclassid = OPP_GRdvattach_class_id,
                                     subclassid = owner_classid ) == OM_S_SUCCESS) ||
              (OPP_GRdvattach_class_id == owner_classid))
          {
            om$send ( msg = message GRreffile.GRchgrfprops ( &msg, 
                                                             &flag, 
                                                             &properties ),
                      senderid = NULL_OBJID,
                      targetid = ref.objid,
                      targetos = ref.osnum );
            om$send ( msg = message GRreffile.GRchgdp ( &msg, &display ),
                      senderid = NULL_OBJID,
                      targetid = ref.objid,
                      targetos = ref.osnum );
          }
        }
      }
    }
  }
  
  return OM_S_SUCCESS;
}


end implementation GRreffile;
