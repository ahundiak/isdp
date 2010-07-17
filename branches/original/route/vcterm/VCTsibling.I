
/* $Id: VCTsibling.I,v 1.1.1.1 2001/01/04 21:12:40 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm / VCTsibling.I
 *
 * Description:
 *   This file contains the overridden GRget_siblings method
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCTsibling.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.5  1997/07/14  22:10:12  pinnacle
# Replaced: vcterm/VCTsibling.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/19  16:06:16  pinnacle
# Replaced: vcterm/VCTsibling.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/12  16:34:56  pinnacle
# Replaced: vcterm/VCTsibling.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/25  13:54:00  pinnacle
# Replaced: vcterm/VCTsibling.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:32:22  pinnacle
# Created: vcterm/VCTsibling.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCTerm;

#include "VDmem.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

/***********************************************************************/

/*\
Name
   GRget_siblings

Description
   This method obtains all siblings of this owner object. Sibling is
   a losely defined term and currently, can be interpreted by the
   owner for a particular application.

   *msg           IGRlong              completion code 
   opts           unsigned IGRshort    Options (currently none supported).
   *num_siblings  IGRint         output number of siblings
   **siblings     struct GRid          output siblings (will be malloced
                                       or "buff" used if large enough)
   num_buff       IGRint               number of GRid in "buff" being supplied
                                       to be used for output memory
                                       for "siblings"
   *buff          struct GRid          the buffer

Return Values
   MSSUCC  if successful
   MSFAIL  if failure
\*/

/***********************************************************************/

method GRget_siblings (IGRlong     *msg;
                       IGRushort    opts;
                       IGRint      *num_siblings;
                struct GRid       **siblings;
                       IGRint       num_buff;
                struct GRid        *buff)
{
  IGRint     status;
  IGRlong    retmsg;
  IGRshort   nCab;

  struct GRid      Eq_id;

  *msg          = MSSUCC;
  *num_siblings = 0;

  /* ------------------------------ */
  /* -- get number of neighbours -- */
  /* ------------------------------ */
  status =
  om$send ( msg = message VCRoot.VCGetTopology
                                   ( &retmsg, VC_REQ_ALL_CPT, &nCab,
                                     NULL, NULL, NULL, NULL),
       targetid = my_id );

  *num_siblings = nCab;

  /* ---------------------------- */
  /* -- get number of supports -- */
  /* ---------------------------- */

  status =
  om$send ( msg = message VCMac.VCGetEquipId (&retmsg, &Eq_id),
       targetid = my_id );

  if (Eq_id.objid != NULL_OBJID) (*num_siblings)++;

  if ( *num_siblings > num_buff ) 
  {
    /*| buffer has to be allocated */

    *siblings = _MALLOC (*num_siblings , struct GRid);
    if ( !(*siblings) ) return OM_E_NODYNMEM;
  }
  else
  {
    /*| No malloc needed */
    *siblings = buff;
  }


  /* ------------------- */
  /* -- get neighbors -- */
  /* ------------------- */
  status =
  om$send ( msg = message VCRoot.VCGetTopology
                                   ( &retmsg, VC_REQ_ALL_CPT, &nCab,
                                     *siblings, NULL, NULL, NULL),
       targetid = my_id );

  /* ---------------------- */
  /* -- return Equipment -- */
  /* ---------------------- */

  if (Eq_id.objid != NULL_OBJID)
           (*siblings)[nCab] = Eq_id;

  return OM_S_SUCCESS;

}/* end GRget_siblings */

end implementation VCTerm;
