/* $Id: GRggrigidcon.I,v 1.1 2001/07/28 17:40:27 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/emsfixes/GRggrigidcon.I
 *
 * Description: Tweak to support using graphic groups in VDbufMacros
 *              Avoid flatening to allow nested graphic groups
 * Dependencies: 
 *
 * Revision History:
 *      $Log: GRggrigidcon.I,v $
 *      Revision 1.1  2001/07/28 17:40:27  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/24/01  ah      Created
 ***************************************************************************/
/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRrigidconn

Description
   This method will flatten the graphics group.

   *msg              IGRlong           Return code
   *owners_id        struct GRid       The owners objid, osnum
   *owners_index     IGRlong           The index on the flexible
                                       owners channel

Return Values
   MSSUCC  -- successful completion

History
   Gray Winn    09/07/87    Creation date.
\*/

class implementation GRgrgrp;

#include "grimport.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "grerr.h"

extern GRclassid OPP_VDbufMacro_class_id;

/* -----------------------------------------------
 * This guy seems to do what I want but it flattens
 * itself when attaching to an owner i.e. hooks
 * it's components up instead of itself.
 *
 * Change it using a flag such that if a macro
 * is creating feet then the macro can control the flettenning
 */
static IGRint doNotFlatten;

void GRgrpSetDoNotFlatten(IGRint flag) 
{
  doNotFlatten = flag;
}
void GRgrpGetDoNotFlatten(IGRint *flag) 
{
  if (*flag) *flag = doNotFlatten;
}

method   GRrigidconn(IGRlong *msg; struct GRid *owners_id; 
                     IGRlong *owners_index)
{
  IGRlong           om_msg;
  OM_S_CHANSELECT   chansel;
  
  IGRint flag = doNotFlatten;
  
  // See if need to flatten or not
  if (flag == 0) flag = VDobjIsAncestryValid(NULL, owners_id,OPP_VDbufMacro_class_id,NULL);

  /* -----------------------------------------------
   * Use the flag
   */
  if (flag) {
    
    // Just pass it up, verified no other ancestor overrides this
    // printf(">>>  GRgrgrp.GRrigidconn Owner %d, Myself %d\n",owners_id->objid,my_id);

    om_msg = om$send(msg = message GRconnector.
		     GRrigidconn (msg, owners_id,owners_index),
		     mode     = OM_e_wrt_message,
		     targetid = my_id);

    return om_msg;    
  }
  

  // Original Code
  chansel.type = OM_e_name;
  chansel.u_sel.name = "GRcmpowner.to_components";

  om_msg = om$send (
    msg = message GRconnector.GRrigidconn (msg, owners_id,
					   owners_index), p_chanselect = &chansel);

  if (om_msg & *msg & 1)
  {
    *msg = GR_I_CPXFLATTEN;
  }
  return(om_msg);
}
end implementation GRgrgrp;
