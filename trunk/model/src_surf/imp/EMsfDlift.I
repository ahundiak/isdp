/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
#include "emsmacros.h"
#include "OMmacros.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECmsg.h"

extern OMuword OPP_EMSsldlift_class_id;
extern OMuword OPP_EMSsfdlift_class_id;
extern OMuword OPP_EMSsolid_class_id;

from GRcontext import GRgetmodule_env;

/*
 Notes
     This method creates an object of class EMSsfdlift if
     the object is a surface or composite surface. Otherwise
     it creates an object of class EMSsldlift class.
     Then it passes the incoming message to the incoming object.

History    RC   10/31/87   Creation
         Inasu  May 31,90  Fix for TR 90n1402. The fix deletes the object
                           created.   

*/

method EMlift_face_w_draft (
    IGRlong         *EMmsg;
    OM_p_MESSAGE    pass_message;
    struct  GRid    *lm_object)			

{
   IGRlong              OM_stat;
   OMuword              My_Class_id;

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

   /*
    * if the top_lm_object (me) is a surface or composite 
    * surface then new object constructed should of
    * class EMSsfdlift. Otherwise, it is a solid object
    * and thus the new object constructed should be of class
    * EMSsldlift.
    */

   OM_stat = om$get_classid (object = me, p_classid = &My_Class_id);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = om$is_ancestry_valid (subclassid = My_Class_id,
                superclassid = OPP_EMSsolid_class_id);

   if (OM_stat == OM_S_SUCCESS)
   {
     /* 
      * I am a solid object. Thus, construct a  solid
      *  dpr local mod lift object
      */

     OM_stat = om$construct ( classid = OPP_EMSsldlift_class_id,
               osnum = OM_Gw_current_OS, p_objid = &lm_object->objid);
     EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

     lm_object->osnum = OM_Gw_current_OS;
   }

   else
   if (OM_stat == OM_I_INVANCESTRY)
   {
		
     /* I am a composite surface object. Thus, construct
      *  a surface dpr lift object
      */

     OM_stat = om$construct ( classid = OPP_EMSsfdlift_class_id,
             osnum = OM_Gw_current_OS, p_objid = &lm_object->objid);
     EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

     lm_object->osnum = OM_Gw_current_OS;
   }
   else
   {
     *EMmsg = EMS_E_Fail;
     goto wrapup;
   }

   OM_stat = om$send (msg = pass_message, 
              targetid = lm_object->objid, targetos = lm_object->osnum);
   
   /* The following code is added to delete the draft surf object   */
   /* in case the lifting surface with draft fails.                 */  
   if (*EMmsg == EMS_I_InvalidArg || *EMmsg == EMS_I_BSerror
                         || *EMmsg == EMS_E_Fail)
    {
     struct GRmd_env md_env;

     ex$message(msgnumb = EMS_I_00002) /* Construction failed */

     OM_stat = om$send (msg = message GRcontext.GRgetmodule_env(EMmsg,
                              &md_env),
                        targetid = lm_object->objid, 
                        targetos = lm_object->osnum);
     EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_SurfaceError,wrapup);

     OM_stat = om$send (msg = message GRgraphics.GRdelete(EMmsg, &md_env),
                        targetid = lm_object->objid, 
                        targetos = lm_object->osnum);
     EMerr_hndlr (!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_SurfaceError,wrapup);
     goto wrapup;
    }
    /* insertion over */
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);
wrapup:

   EMWRAPUP (*EMmsg, OM_stat, "In EMSsurface.EMlift_face_w_draft");
	
   return (OM_stat);
	
}

end implementation EMSsurface;
