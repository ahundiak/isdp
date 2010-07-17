
/* $Id: VCTAGi.I,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr / VCTAGi.I
 *
 * Description:
 *   This file contains the methods and functions used in the basic
 *   VCTAG class
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCTAGi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/30  16:08:56  pinnacle
# Replaced: vcdbattr/VCTAGi.I for:  by r250_int for route
#
# Revision 1.6  1997/11/14  23:17:48  pinnacle
# Replaced: vcdbattr/VCTAGi.I for:  by onayragu for cabling
#
# Revision 1.5  1997/08/11  21:25:54  pinnacle
# Replaced: vcdbattr/VCTAGi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/03/19  15:15:48  pinnacle
# Replaced: vcdbattr/VCTAGi.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/08  21:44:40  pinnacle
# Replaced: vcdbattr/VCTAGi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  15:45:46  pinnacle
# Replaced: vcdbattr/VCTAGi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/30  17:39:52  pinnacle
# Created: vcdbattr/VCTAGi.I by hverstee for cabling
#
 *
 * History:
 *        08/29/96        hv         Initial
 *	11/12/97	Onay		Suppress public functions.
 *
 *************************************************************************/

class implementation VCTAG;

#include "PDUerror.h"
#include "v_risproto.h"

#include "VCproto.h"

#define   VC_TAGMGR_NAME         "tag_manager"

extern GRclassid   OPP_VCTAG_class_id;

method  VCTagInit  (IGRlong    *msg)
{
  /*   read DB tag table   ?   */
  me->nTagStat = 0;

  *msg = MSSUCC;

  return (OM_S_SUCCESS);
}

method  VCTagChk   (IGRshort   *nST;
                    IGRint      CAT;
                    IGRchar    *szTag)
{
  IGRint   i, iloop;

  *nST = -1;
  iloop = om$dimension_of (varray = me->taglist);

#ifdef MY_DEBUG
    printf ("TAGCHK %s\n", szTag);
#endif

  for (i=0; i<iloop; i++)
  {
    if ((CAT == me->taglist[i].nTagCat) &&
        (strcmp (me->taglist[i].Tag, szTag) == 0))
    {
      *nST = i;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

method  VCTagAdd   (IGRshort   *nST;
                    IGRint      CAT;
                    IGRchar    *szTag)
{
  IGRint   iloop;
  IGRint   status;

  status =
  om$send (msg = message VCTAG.VCTagChk (nST, CAT, szTag),
      targetid = my_id);

  if (*nST >= 0)
    *nST = -1;
  else
  {
    iloop = om$dimension_of (varray = me->taglist);
    *nST  = iloop;

    status = om$vla_set_dimension (varray = me->taglist,
                                   size   = (iloop + 1));

    me->taglist[iloop].nTagOrig = 0;
    me->taglist[iloop].nTagCat  = CAT;
    strcpy (me->taglist[iloop].Tag, szTag);

#ifdef MY_DEBUG
    printf ("TAGADD %d %s\n",iloop, szTag);
#endif
  }

  return (status);
}

method  VCTagDel   (IGRshort   *nST;
                    IGRint      CAT;
                    IGRchar    *szTag)
{
  IGRint   iloop;
  IGRint   i;
  IGRint   status;

  status =
  om$send (msg = message VCTAG.VCTagChk (nST, CAT, szTag),
      targetid = my_id);

#ifdef MY_DEBUG
    printf ("TAGDEL %d %s\n",*nST, szTag);
#endif
  if (*nST >= 0)
  {
    iloop = om$dimension_of (varray = me->taglist);

    for (i=*nST; i<(iloop-1); i++)
      me->taglist[i] = me->taglist[i+1];

    status = om$vla_set_dimension (varray = me->taglist,
                                   size   = (iloop - 1));
  }

  return (status);
}

end implementation VCTAG;

