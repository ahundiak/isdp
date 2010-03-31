/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method checks the caller specified properties of the loopset, 
 loops and edges and makes them valid at the time this message is sent to
 the loopset. The properties of the loopset/loops/edges which need to be
 checked and set should be specified as combinations of bit masks in the
 3 input arguments. If for en element no property is to be checked then the
 corresponding address should still be valid and should point to value
 NULL.
	If a property is not specified in the check list it may be assumed
 to be valid and used in the checking of one of the properties specified
 on input list. If the caller is not sure of any related property then it
 would safer to specify it on the check list. For e.g in determining if
 the loopset is natural or not, the natural property of the loop is made
 use of. If the caller is not certain of validity of this property in
 the loops then it should be specified on the check list for loops.
	The input check list has bit combinations on input. These bit
 combinations WILL get ALTERED upon exit.

Bugs
	Only the properties needed at this time are taken care of.The method
	can be expanded in future to care of various other properties.
  Following checks will be handled as of now -
  1) ls_props - EMLS_NATURAL.
  2) lp_props - EMLP_NATURAL, EMLP_EXTERNAL.

History
	SM	06/01/87	Creation date.
*/
class implementation EMSedge;

#include "EMS.h"
#include "emsdef.h"
#include "EMSopt.h"

from EMSloop import EMset_props;

extern OMuword	OPP_EMSnatedge_class_id;

method EMcheck_props(IGRlong *EMmsg; IGRushort *ls_props, 
			  *lp_props, *ed_props)
{
  IGRlong		sts, rc;
  OM_S_CHANSELECT	to_owner;
  OMuword		my_class;
  IGRint		EMsend_loops();

  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  to_owner.type = OM_e_addr;
  to_owner.u_sel.addr = &ME.EMSedge->to_owner;

  sts = om$get_classid(object = me, p_classid = &my_class);
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

/* If the natural property of the loop is to be checked then the checks if
   it is natural(of class EMSnatedge). If not it concludes that the loop
   is non natural and returns OM_I_STOP_SENDING.
*/
  if( (*lp_props) & EMLP_NATURAL)
   {
     if(my_class != OPP_EMSnatedge_class_id)
      {
	sts = EMsend_loops(&rc, message EMSloop.EMset_props
				(EMmsg, EMLP_NATURAL, EMS_O_OFF), my_id, 
			0, MAXINT, EMLP_ACTIVE, NULL, NULL);
	EMerr_hndlr(!(1&*EMmsg&sts), *EMmsg, EMS_E_LoopError, wrapup);
	(*lp_props) &= ~EMLP_NATURAL;
	return(OM_I_STOP_SENDING);
      }
   }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSedge.EMcheck_props");
  return(sts);

}
end implementation EMSedge;
