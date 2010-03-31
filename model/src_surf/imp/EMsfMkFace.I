/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "emsmacros.h"
#include "OMmacros.h"

extern OMuword OPP_EMSslmkface_class_id;
extern OMuword OPP_EMSsfmkface_class_id;
extern OMuword OPP_EMSsolid_class_id;

method EMmake_face (
	IGRlong		*EMmsg;
	OM_p_MESSAGE	pass_message;
	struct	GRid	*lm_object)			

/*
 	This method constructs a make face local mod object.
	Depending upon the state tree top local mod object class,
	it appropriately constructs the EMSslmkface or EMSsfmkface
	class object. This way the command object does not
	have to worry about the class of the local mod object.
	And finally it passes the incoming message to the the newly
	constructed object.

History	   RC	04/30/87	Creation Date
           RC   11/2/87         Modified for version 1.1.0

*/
	
{
   IGRlong           OM_stat;
IGRlong   mthd_stat;
   IGRshort          mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
   IGRshort          action = 1;
   OMuword           My_Class_id;
		
   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;

                           
   /*
    * if the top_lm_object (me) is a surface/composite surface
    * then new object constructed should of
    * class EMSsfmkface. Otherwise, it is a solid object
    * and thus the new object constructed should be of class
    * EMSslmkface.
    */

   OM_stat = om$get_classid (object = me, p_classid = &My_Class_id);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   OM_stat = om$is_ancestry_valid (subclassid = My_Class_id,
                       superclassid = OPP_EMSsolid_class_id);
   EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

   if (OM_stat == OM_S_SUCCESS)
   {
     /* I am a solid object. Thus, construct a  solid
      *  of class EMslmkface class.
      */

     OM_stat = om$construct ( classid = OPP_EMSslmkface_class_id,
                              osnum = OM_Gw_current_OS,
                              p_objid = &lm_object->objid);
     EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);
     lm_object->osnum = OM_Gw_current_OS;
   }
   else
	 
   if (OM_stat == OM_I_INVANCESTRY)
   {
      /* I am a surface/composite surface object. Thus, construct
       *  a object of class EMsfmkface.
       */

      OM_stat = om$construct ( classid = OPP_EMSsfmkface_class_id,
                               osnum = OM_Gw_current_OS,
                               p_objid = &lm_object->objid);
     EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);
     lm_object->osnum = OM_Gw_current_OS;
   }
   else goto wrapup;

   /*
    * set the properties of the above construected
    * object to GRIS_DISPLAYABLE and GRIS_LOCATABLE
    */

   OM_stat = om$send (msg = message GRvg.GRchgprops( &mthd_stat, &action,
                       &mask), targetid = lm_object->objid);
   EMerr_hndlr (!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail,wrapup);

   OM_stat = om$send (msg = pass_message, targetid = lm_object->objid,
                   targetos = lm_object->osnum);
   EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
	
   EMWRAPUP (*EMmsg, OM_stat, "In EMSsurface.EMmake_face");
	
   return (OM_stat);

}

end implementation EMSsurface;
