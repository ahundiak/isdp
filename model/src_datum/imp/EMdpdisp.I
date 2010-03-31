/* ###################   APOGEE COMPILED   ################## */
class implementation EMSdatpln;

#include "EMS.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "maidmx.h"

method NDdisplay(IGRint dp_type;enum GRdpmode pen;struct GRmd_env *env)
/* *****************************************************************
Abstract
  If this message is being sent during compute do not do anthing since
  we will take care of displaying or erasing.

History
 02/26/92 : JSD : Creation (patterned from $MODEL/src_assoc/imp/EMasdisp.I)
 Sudha   23-june-93      modified for BSprototype ansification

******************************************************************* */
 {
  IGRint status;
  IGRlong EMmsg;
  struct GRid my_GRid;
  struct GRid mod_grid;
  IGRshort mat_type;
  IGRmatrix mat_ident;
  IGRdouble *mat;
 
  status = OM_S_SUCCESS;
  EMmsg = EMS_S_Success;

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;

    if(env == NULL)
     {
      mat_type = MAIDMX;
      MAidmx(&EMmsg,mat_ident);
      mat = mat_ident;
     }
   else
     { 
      mat_type = env->md_env.matrix_type;
      mat = env->md_env.matrix;
     }
     GRfindmod(&mod_grid);
     status = om$send(msg = message GRgraphics.GRdisplay(&EMmsg,
	         		    &mat_type,mat,&pen,&mod_grid),
                      targetid = my_id);
     EMerr_hndlr (!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);
  
wrapup:
 if (!(1&EMmsg)) status = OM_E_ABORT;
 return(status);
 }
end implementation EMSdatpln;

