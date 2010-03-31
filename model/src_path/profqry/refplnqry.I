
/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
	The API queries a reference plane and gets the xvec, yvec, zvec and
	the origin point of the plane.

  NOTES

  ARGUMENTS
	PWobjid 		refplid
	PWosnum 		os
	PWvector		xvec,yvec,zvec;
	PWpoint			origpt;

  HISTORY

     Satya   07/11/96   Creation 

*/

/* Includes */
class implementation	SKmgr;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igetypedef.h"

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "EMSmsgdef.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSopt.h"
#include "EMdtmacros.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/refplnqry.h"

from EMSdatpln import EMget_pln_info;

PWresult pwGetDatpldata
(
  PWobjid datplane,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  PWvector xvec,
  PWvector yvec,
  PWvector zvec,
  PWpoint  origpt
)
{

        struct GRmd_env	    mod_env;
        long                OMmsg,OMsts,PWsts;
        extern OMuword      EX_active_OS_num;
	int		    i;

        OMmsg = EMS_S_Success;
        PWsts = PW_K_Success;
        OMsts = OM_S_SUCCESS;

	for(i=0;i<3;i++)
	{
	  xvec[i] = 0.0;
	  yvec[i] = 0.0;
	  zvec[i] = 0.0;
	  origpt[i] = 0.0;
	}

        mod_env.md_env.matrix_type = mattyp;
        memcpy(mod_env.md_env.matrix,mat,sizeof(IGRmatrix));

        if(datplane != NULL_OBJID)
        {
          OMsts = om$send (msg = message EMSdatpln.EMget_pln_info(&OMmsg,
                           NULL, &mod_env, xvec, yvec, zvec, origpt, NULL),
                           targetid = datplane, 
                           targetos = os,
                           senderid = NULL_OBJID);
          if (!(1&OMmsg))
          {
             PWsts = SetError (PW_K_Pathway, PW_K_Internal);
             goto wrapup;
          }
        }
wrapup:
/*
  if(reset_os)
   {
     stat = pwActivateOS(save_os);
     if(!(1&stat))
        PWsts = SetError( PW_K_Pathway, PW_K_Error);
   }
*/
   PW_Wrapup (PWsts, "pwGetDatpldata");
   return (PWsts);
}
end implementation SKmgr;
