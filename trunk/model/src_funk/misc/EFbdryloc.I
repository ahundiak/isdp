/* ###################   APOGEE COMPILED   ################## */
class implementation EMSboundary;

# include "EMS.h" /* For shared libraries */
# include "lcmacros.h" /* For lc$classchek */
# include "grdpbdef.h" /* For DPB_LOCATE_ON */
# include "grdpb.h"    
# include "grdpbmacros.h"
# include "EMSerrordef.h" 
# include "emserr.h"   /* For EMerr_hndlr and EMWRAPUP */
# include "dpdef.h"    /* For END_PARAM */
/* 
 * These assorted function set interface with the locate control information
 * and return whether boundary curves, edge curves and loop curves
 * are locatable. They return TRUE if locatable and FALSE if not
 * locatable. Please note that curves is taken to mean model space 
 * counterparts of the boundary elements.
 * 
 * History
 *  Creation : PP : 02/12/89
 *             mrm  05/03/91    modified to reflect argument changes
 *                              to gr$set_inq, and use message keys
 */

IGRboolean EFedge_curves_locatable()
{
 struct var_list var_list[2];
 struct GRelclass_f classprops;
 IGRlong msg_loc;

 strcpy(classprops.ascii_key, "EMSedge");
 var_list[0].var = DPB_PROPERTIES;
 var_list[0].var_ptr = (IGRchar *)&classprops;
 var_list[1].var = END_PARAM;

 gr$set_inq(msg = &msg_loc, var_list = var_list);

 if (!(1&msg_loc)) return (1); /* If there is some error then always
                                  make the edge curves locatable */
 
 if (classprops.properties & DPB_LOCATE_ON) return(1);
 else return (0);
}

IGRboolean EFloop_curves_locatable()
{
 struct var_list var_list[2];
 struct GRelclass_f classprops;
 IGRlong msg_loc;

 strcpy(classprops.ascii_key, "EMSloop");
 var_list[0].var = DPB_PROPERTIES;
 var_list[0].var_ptr = (IGRchar *)&classprops;
 var_list[1].var = END_PARAM;

 gr$set_inq(msg = &msg_loc, var_list = var_list);

 if (!(1&msg_loc)) return (1); /* If there is some error then always
                                  make the loop curves locatable */
 if (classprops.properties & DPB_LOCATE_ON) return (1);
 else return (0);
}

IGRboolean EFboundary_curves_locatable()
{
 IGRboolean EFedge_curves_locatable(),
            EFloop_curves_locatable();
 IGRboolean boundary_locatable;
  
 boundary_locatable = (EFedge_curves_locatable()) ||
                       (EFloop_curves_locatable());

 return (boundary_locatable);
}

/*
 * This function can be used to do the following when given the element
 * type.
 *
 * if option is 0 - turns locate off for the specified element type.
 * if option is 1 - turns locate on for the specified element type.
 * if option is 2 - toggles locate for the specified element type.
 * 
 * Return codes:
 *  EMS_E_Fail: General failure
 *  EMS_E_InvalidArg: If the option is not one of 0, 1 or 2
 *
 * History
 * pp : Creation : 09/20/89
 */

EFset_locate_eligibility(EMmsg,option,element_type)
IGRlong *EMmsg;
IGRint option;
IGRchar *element_type;
{
 struct var_list var_list[2];
 struct GRelclass_f classprops;
 IGRlong msg_loc;

 *EMmsg = EMS_S_Success;
 strcpy(classprops.ascii_key, element_type);
 classprops.properties = 0;
 var_list[0].var = DPB_PROPERTIES;
 var_list[0].var_ptr = (IGRchar *)&classprops;
 var_list[1].var = END_PARAM;

 gr$set_inq(msg = &msg_loc, var_list = var_list);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 if (option == 0 )
   classprops.properties &= ~DPB_LOCATE_ON;
 else if (option == 1)
   classprops.properties |= DPB_LOCATE_ON;
 else if (option == 2)
 {
  if (classprops.properties & DPB_LOCATE_ON) classprops.properties &= ~DPB_LOCATE_ON;
  else classprops.properties |= DPB_LOCATE_ON;
 }
 else
 {
  *EMmsg= EMS_E_InvalidArg;
  goto wrapup;
 } 

 gr$set_inq(set_inq = DPB_SET, msg = &msg_loc, var_list = var_list);
 EMerr_hndlr(!(1&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
 return(*EMmsg);
}

end implementation EMSboundary;

