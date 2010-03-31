/* ###################   APOGEE COMPILED   ################## */
/* -----

     CHANGE HISTORY:
     RC     12/04/86  : Creation date	
     SS     25/08/87  : Modified connect_edges flag to an options 
                            mask. See EMSboundary-spec file.
     DLB    06/17/91  : Fix creator id in copies.

----- */

class implementation EMSboundary;

#include "EMS.h"
# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMcp.h"

method EMtpcopy(
    IGRlong                *EMmsg; 
    struct GRmd_env        *mdenv;
    GRspacenum             obj_osnum;
    GRspacenum             new_osnum; 
    IGRushort      options;
    GRobjid                *newobjid)
{
   IGRlong   OM_stat;
   IGRlong   mthd_stat;
   GRobjid   crid;
   struct EMcp_info  copy_info;
   IGRboolean        pass_copy_info;
   GRclassid         classids[2];
   extern OM_S_OBJID current_creator;
   extern OMuword    OPP_EMSloop_class_id, OPP_EMSedge_class_id;


   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   copy_info.num_entries = 0;
   copy_info.array_size = 0;
   copy_info.objid_array = NULL;

   /*
    * send a message to myself to perform the copy process
    */

   OM_stat = om$send (msg = message EMSboundary.EMintcopy (
                  &mthd_stat, mdenv, obj_osnum, new_osnum, options,
                  newobjid, &copy_info),
              targetid = my_id);
   EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   if (current_creator == NULL_OBJID)
   {
     pass_copy_info = TRUE;
     crid = NULL_OBJID;
   }
   else
   { 
     pass_copy_info = FALSE;
     crid = current_creator;
   }

   classids[0] = OPP_EMSloop_class_id;
   classids[1] = OPP_EMSedge_class_id;
   OM_stat = om$send(msg = message EMSboundary.EMtree_traverse(EMmsg,
                               message EMSboundary.EMfix_creator_id(EMmsg,
                               (pass_copy_info ? &copy_info : NULL),
                               crid, NULL),
                           MAXINT, 2, classids, EMStreetrav_down,
                           NULL, NULL, NULL), 
                     targetid = *newobjid,
                     targetos = new_osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;                      

wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "bdry.EMtpcopy");
   if (copy_info.objid_array) om$dealloc (ptr = copy_info.objid_array);

   return(OM_stat);
}

end implementation EMSboundary;
