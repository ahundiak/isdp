/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
#include "emsmacros.h"
#include "OMmacros.h"

extern OMuword OPP_EMSsfmove_class_id;
extern OMuword OPP_EMSslmove_class_id;
extern OMuword OPP_EMSsolid_class_id;

method EMlmmove(IGRlong *EMmsg;
                 OM_p_MESSAGE mess;
                 struct GRid *move_GRid)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
    			- EMS_E_Fail (severe) if failure

Assumption

Bugs

History
	
	  gupta 	05/04/87:   design date
          ?????         10/19/87:   changed logic for new system
          NP            08/21/92:   Modified for ANSI compliance.
Algorithm

      The solid dpr and the surface dpr will also inherit
      this message. So, first see if the class EMSsolid is in my 
      ancestry. If so then construct an object of EMSslmove and
      send it the incoming message 'mess'. If EMSsolid class is not
      in my ancestry, then construct an object of EMSsfmove and pass
      on the message.

*/
                   
{
  /* "mask" has been declared as "IGRshort" since method "GRchgprops" below 
   * expects a pointer to a "IGRshort" and not an "IGRushort".
   */
  IGRshort           mask = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
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
     * dpr local mod move object
     */
    stat_OM = om$construct ( classid = OPP_EMSslmove_class_id,
                			 osnum = OM_Gw_current_OS,
				             p_objid = &move_GRid->objid,
                             msg = mess);
    EMomerr_hndlr(stat_OM, wrapup, "EMsflmmove.construct0");
	move_GRid->osnum = OM_Gw_current_OS;
   }
  else
  if (stat_OM == OM_I_INVANCESTRY)
   {
    /*  I am a surface/composite object. Thus, construct a surface
     *  dpr local mod move object
     */
    stat_OM = om$construct (classid = OPP_EMSsfmove_class_id,
                            osnum = OM_Gw_current_OS,
                            p_objid = &move_GRid->objid,
                            msg = mess);
    EMomerr_hndlr(stat_OM, wrapup, "EMsflmmove.construct1");
    move_GRid->osnum = OM_Gw_current_OS;
   }
  else
   {
    goto wrapup;
   }

  /* activate dpr */
 
  stat_OM = om$send (msg = message GRvg.GRchgprops (&msg,
                           &action, &mask),
                     targetid = move_GRid->objid);
  EMomerr_hndlr(stat_OM, wrapup, "EMsflmmove.GRchgprops");
  EMerr_hndlr(EMis_error(msg), *EMmsg, msg, wrapup);
 
wrapup:

   return(stat_OM);
}
end implementation EMSsurface;
