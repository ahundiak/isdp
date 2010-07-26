/*
API Definition

  ABSTRACT

  These set of APIs get the activation details. The various details
  accessible and their APIs are:

    1. Activation Flag - pwIsActivationOn()
    2. OS              - pwGetActiveOs()
    3. GRreffile       - pwGetActiveRefHeader()
    4. Module Env      - pwGetActiveModuleEnv()


  NOTES

  It is very important that the activation flag is checked before accessing
  the other parameters. If activation is off then there is no validation of
  the values in the other parameters.


  ARGUMENTS

  IGRboolean pwIsActivationOn()
  -----------------------------

  The return value indicates the status of Activation. It takes no arguments.

  GRspacenum pwGetActiveOs()
  --------------------------

  The return value is the activated OS. It takes no arguments.

  IGRint pwGetActiveRefHeader(GRid *rfhead)
  ----------------------------------------

  GRid *rfhead (OUT)  - The objid and os of the GRreffile object controlling 
                        the activated OS.

  IGRint pwGetActiveModuleEnv(struct GRmd_env *rfenv)
  --------------------------------------------------

  struct GRmd_env *rfenv (OUT) - The module environment of the activated OS.


  KEYWORDS

  Activation , Reference File, Activation Parameters


  CAVEATS

  None so far.

  HISTORY

  Satish - Creation - 

*/

class implementation Root;

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "madef.h"

/** Exnuc include to store and get activation data **/
#include "exudata.h"


from GRreffile import  GRgetenvironment;


IGRboolean pwIsActivationOn
(
)
{
   exUDataActref rfact;
   int status;
 
   status = exRecvUData(EX_UDATA_ACTREF, (char *)&rfact);
   return(rfact.aflag); 
}

GRspacenum pwGetActiveOs
(
)
{
   exUDataActref rfact;
   int status;

   if(pwIsActivationOn())
   {
     status = exRecvUData(EX_UDATA_ACTREF, (char *)&rfact);
     return(rfact.osn);
   }
   else return(EX_active_OS_num);
}

IGRint pwGetActiveRefHeader
(
   struct GRid *rfhead
)
{
   exUDataActref rfact;
   int status;

   if (rfhead == NULL)
   {
      return(OM_E_INVARG);
   }
   else
   {  
      status = exRecvUData(EX_UDATA_ACTREF, (char *)&rfact);
      rfhead->objid = rfact.refid.objid;
      rfhead->osnum = rfact.refid.osnum;
   }

   return(OM_S_SUCCESS);
}

IGRint pwGetActiveModuleEnv
(
   struct GRmd_env *rfenv
)
{
   exUDataActref rfact;
   struct GRmd_env mast_env;
   IGRlong loc_msg;
   int status;

   status = OM_S_SUCCESS;

   if (rfenv == NULL)
   {
      return(OM_E_INVARG);
   }

   status = exRecvUData(EX_UDATA_ACTREF, (char *)&rfact);

   if (rfact.aflag)
   {
     /** Get the master file module env **/
     ex$get_cur_mod(id = &mast_env.md_id.objid, osnum = &mast_env.md_id.osnum);
     MAidmx(&loc_msg, mast_env.md_env.matrix);
     mast_env.md_env.matrix_type = MAIDMX;

      /** Send getenv to the GRreffile object **/
      status = om$send(msg = message GRreffile.GRgetenvironment(&loc_msg,
                                                                &mast_env,
                                                                rfenv),
                       senderid = NULL_OBJID,
                       targetid = rfact.refid.objid,
                       targetos = rfact.refid.osnum);
   }
   else
   {
     /*
      * Return identity matrix and master OS module id.
      */
     ex$get_cur_mod(id = &(rfenv->md_id.objid), osnum = &(rfenv->md_id.osnum));
     MAidmx(&loc_msg, rfenv->md_env.matrix);
     rfenv->md_env.matrix_type = MAIDMX;
   }
   
wrapup:
   return(status);
}

end implementation Root;
