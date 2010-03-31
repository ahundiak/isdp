/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "emsmacros.h"
#include "OMmacros.h"

extern OMuword OPP_EMSsfround_class_id;
extern OMuword OPP_EMSslround_class_id;
extern OMuword OPP_EMSsolid_class_id;

method EMlmround(IGRlong *EMmsg;
                 OM_p_MESSAGE mess;
                 struct GRid *round_GRid)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	11/30/87:	design date

Algorithm

      The solid dpr and the surface dpr will also inherit
      this message. So, first see if the class EMSsolid is in my 
      ancestry. If so then construct an object of EMSslround and
      send it the incoming message 'mess'. If EMSsolid class is not
      in my ancestry, then construct an object of EMSsfround and pass
      on the message.

*/
                   
{
  IGRshort  mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  IGRlong            stat_OM, msg;
  IGRboolean         action = 1;
  OMuword            My_Class_id;

/*--------------------------------------------------------------------*/

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
 
  stat_OM = om$get_classid (object = me,
		                	p_classid = &My_Class_id);
  if (! (1 & stat_OM)) goto wrapup;

  stat_OM = om$is_ancestry_valid (subclassid = My_Class_id,
                                  superclassid = OPP_EMSsolid_class_id);

  if (stat_OM == OM_S_SUCCESS)
   {
	/* I am a solid object. Thus, construct a  solid
     * dpr local mod round object
     */
    stat_OM = om$construct ( classid = OPP_EMSslround_class_id,
                			 osnum = OM_Gw_current_OS,
				             p_objid = &round_GRid->objid,
                             msg = mess);
    EMerr_hndlr(! (1 & stat_OM), *EMmsg, msg, wrapup);
	round_GRid->osnum = OM_Gw_current_OS;
   }
  else
  if (stat_OM == OM_I_INVANCESTRY)
   {
    /*  I am a surface/composite object. Thus, construct a surface
     *  dpr local mod round object
     */
    stat_OM = om$construct (classid = OPP_EMSsfround_class_id,
                            osnum = OM_Gw_current_OS,
                            p_objid = &round_GRid->objid,
                            msg = mess);
    EMerr_hndlr(! (1 & stat_OM), *EMmsg, msg, wrapup);
    round_GRid->osnum = OM_Gw_current_OS;
   }
  else
   {
    goto wrapup;
   }

  /* activate dpr */
 
  if (1 & (stat_OM = om$is_objid_valid(objid = round_GRid->objid)))
   {
    stat_OM = om$send (msg = message GRvg.GRchgprops (&msg,
                             &action, &mask),
                       targetid = round_GRid->objid,
                       targetos = round_GRid->osnum);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, msg, wrapup);
   }
  else
   stat_OM = OM_S_SUCCESS;

wrapup:

  EMWRAPUP  (*EMmsg, stat_OM, "EMSsurface.EMlmround"); 
  return(stat_OM);
}
end implementation EMSsurface;
