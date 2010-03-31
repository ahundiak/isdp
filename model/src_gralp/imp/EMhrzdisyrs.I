/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include "EMS.h"


method GRdisyourself(IGRlong *EMmsg;
                     IGRshort *type;
                     IGRmatrix matrix;
                     enum GRdpmode *mode;
                     struct IGRaltdisplay *alt_symb;
                     struct DP_information *sp_info;
                     OM_p_KEY_DESC key)

/********************************************************************


History
 Jack    10/05/91    Created as override.
 
 ********************************************************************/

{
  IGRlong      status;
  struct GRid  window_id;
  struct EMSpartolbasis   partol;
            
  status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;


  partol.is_valid = FALSE;
  partol.mattyp = type;
  partol.mat = matrix;

  if(sp_info)
   {
    window_id.objid = sp_info->view_objid;
    window_id.osnum = sp_info->view_osnum;
   }
  else 
   {
    window_id.objid = 0;
    window_id.osnum = 0;
   }

 status = om$send( msg = message EMShorizon.EMdisplay(
                                             EMmsg,
                                             0,
                                             mode,
                                             sp_info,
                                             NULL,
                                             NULL,
                                             type, 
                                             matrix,
                                             NULL,
                                             0,
                                            &partol,
                                             NULL,
                                            &window_id),
                 targetid = my_id); 
 if(! (1 & status & *EMmsg)) goto wrapup;

wrapup:
 return (status);
  
}
end implementation EMShorizon;
