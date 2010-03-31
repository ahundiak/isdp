/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
#include "emsmacros.h"
#include "OMmacros.h"

extern OMuword OPP_EMSsl_lift_class_id;
extern OMuword OPP_EMSsf_lift_class_id;
extern OMuword OPP_EMSsolid_class_id;

/*
 Notes
     This method creates an object of class EMSsflift if
     the object is a surface or composite surface. Otherwise
     it creates an object of class EMSsllift class.
     Then it passes the incoming message to the incoming object.

History    RC   10/31/87   Creation


*/

method EM_lift (
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
    * class EMSsflift. Otherwise, it is a solid object
    * and thus the new object constructed should be of class
    * EMSsllift.
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

     OM_stat = om$construct ( classid = OPP_EMSsl_lift_class_id,
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

     OM_stat = om$construct ( classid = OPP_EMSsf_lift_class_id,
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
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

wrapup:

   EMWRAPUP (*EMmsg, OM_stat, "In EMSsurface.EM_lift");
	
   return (OM_stat);
	
}

end implementation EMSsurface;
