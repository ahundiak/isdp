/* ###################   APOGEE COMPILED   ################## */
class implementation Root;
#include <stdio.h>                      /* Needed for print statements */
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "EMSopt.h"
#include "gr.h" 
#include "igr.h"
#include "EMSbnddef.h"
#include "EMSlogic.h"
#include "EMSmsgdef.h"
#include "EMScmacros.h"
#include "OMmacros.h"
#include "EMSlmdef.h"
#include "EMSdpb.h"
#include "nddef.h"
#include "ndmacros.h"
#include "godef.h"
#include "exfi.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "dim.h"
#include "dimdef.h"
#include "madef.h"
#include "SKdef.h"
#include "emserr.h"
#include "DIdef.h"

#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if (! (1 & sts_stupid & error_number)) goto wrapup;\
 }

from DMroot import return_dim_go,get_info;
from expression import modify;


void EMrestore(  EMmsg,
                   num_of_dims,
                   driving_dim_grid,
                   driving_dim_type,
                   driving_dim_value,
                   driving_dim_sel,
                   env)

 IGRint           *num_of_dims, *driving_dim_type;
 IGRint           *driving_dim_sel;
 IGRdouble        *driving_dim_value;
 struct GRid      *driving_dim_grid;
 struct GRmd_env  *env;
 IGRlong *EMmsg;

 {
 struct  GRid     driving_grid;
 IGRdouble        value;
 IGRchar          temp_name[DI_PATH_MAX] ;
 IGRchar          new_value[DI_PATH_MAX] ;
 IGRboolean       save;
 IGRint           ii, sts;
 IGRlong          msg;
 extern IGRboolean ASbroadcast_in_progress;

 msg = EMS_S_Success;

/*************************** restore values ***********************************/

      save = ASbroadcast_in_progress;
      ASbroadcast_in_progress = TRUE;

      for(ii=0;ii< *num_of_dims;ii++)
        {
        if( *(driving_dim_sel + ii) == TRUE)
          {
           value = *(driving_dim_value+ii)  ; 
           temp_name[0] = '\0';
           new_value[0] = '\0';
           sprintf(new_value,"%lf",value);

           driving_grid = *(driving_dim_grid +ii);

           sts = om$send (msg = message expression.modify(temp_name,
                           new_value,(IGRshort *)&msg),
               senderid = NULL_OBJID,
               targetid = driving_grid.objid,
               targetos = driving_grid.osnum);
           ERROR(sts, msg, "SKexplicit.SKstorevalue.error");

          }
        }
           sts = nd$update_graph(cn_type =ND_COMP_NO_ERASE | ND_COMP_NO_DISPLAY,
           md_env =  env);
           ASbroadcast_in_progress = save;

wrapup:
        *EMmsg = msg;
        EMWRAPUP(msg,sts, "EMrestore");
 return;
}

end implementation Root;

