
/* $Id: VCSYSi.I,v 1.1.1.1 2001/01/04 21:12:57 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vcinit/VCSYSi.I
 *
 * Description:
 *  CABLE system switches management
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCSYSi.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/31  21:24:34  pinnacle
# Created: vrinit/VCSYSi.I by impd for route
#
# Revision 1.1  1997/07/14  21:51:56  pinnacle
# Created: vcinit/VCSYSi.I by hverstee for cabling
#
 *
 * History:
 *
 *************************************************************************/

class implementation VCSYS;

#include "VCdefine.h"
#include "VCparameters.h"
#include "VCDBpar.h"
#include "VCstructs.h"
#include "VCdbstructs.h"
#include "VCdbaccess.h"
#include "VCproto.h"
#include "VCchansel.h"
#include "VCMacLib.h"
#include "VCsys.h"

/*
#define MY_DEBUG  1
*/

/**********************************************************/

method VCS_def (IGRlong    *msg)
{
  IGRint   nOld;
  IGRint   status;

  *msg   = MSSUCC;

  nOld = om$dimension_of (varray = me->SWbuf);

  status =
  om$vla_set_dimension (varray = me->SWbuf,
                        size   = VCG_MAX);

  if (VCG_PRESERVE > nOld)
  {
    me->SWbuf[VCG_PRESERVE-1].nType  = VCT_INT;
    me->SWbuf[VCG_PRESERVE-1].nIndic = VCG_PRESERVE;
    me->SWbuf[VCG_PRESERVE-1].fld.iF = TRUE;
  }

  if (VCG_DYNCPT > nOld)
  {
    me->SWbuf[VCG_DYNCPT-1].nType  = VCT_INT;
    me->SWbuf[VCG_DYNCPT-1].nIndic = VCG_DYNCPT;
    me->SWbuf[VCG_DYNCPT-1].fld.iF = TRUE;
  }

  if (VCG_OFFSET > nOld)
  {
    me->SWbuf[VCG_OFFSET-1].nType  = VCT_INT;
    me->SWbuf[VCG_OFFSET-1].nIndic = VCG_OFFSET;
    me->SWbuf[VCG_OFFSET-1].fld.iF = TRUE;
  }

  VCSYSGLB_preserve =  me->SWbuf[VCG_PRESERVE-1].fld.iF;
  VCSYSGLB_dyncpt   =  me->SWbuf[VCG_DYNCPT-1].fld.iF;
  VCSYSGLB_offset   =  me->SWbuf[VCG_OFFSET-1].fld.iF;

  return (OM_S_SUCCESS);

} /* method init */

/*----------------------------------------------------------------------------*/

method VCS_set (IGRlong    *msg;
                IGRint      nCode;
         struct VCsysbuf   *Buf)
{
  IGRint   nOld;
  IGRint   status;
  IGRint   i;

  *msg   = MSSUCC;

  nOld = om$dimension_of (varray = me->SWbuf);

  if (nCode > nOld)
  {
    status =
    om$vla_set_dimension (varray = me->SWbuf,
                          size   = nCode);

    for (i=nOld; i< nCode; i++)
    {
      me->SWbuf[i].nType  = VCT_INT;
      me->SWbuf[i].nIndic = i + 1;
      me->SWbuf[i].fld.iF = TRUE;
    }
  }

  me->SWbuf[nCode - 1] = *Buf;

  VCSYSGLB_preserve =  me->SWbuf[VCG_PRESERVE-1].fld.iF;
  VCSYSGLB_dyncpt   =  me->SWbuf[VCG_DYNCPT-1].fld.iF;
  VCSYSGLB_offset   =  me->SWbuf[VCG_OFFSET-1].fld.iF;

  return (OM_S_SUCCESS);

} /* method init */

/*----------------------------------------------------------------------------*/

method VCS_get (IGRlong    *msg;
                IGRint      nCode;
         struct VCsysbuf   *Buf)
{
  IGRint   nOld;

  *msg   = MSSUCC;

  nOld = om$dimension_of (varray = me->SWbuf);

  if (nCode <= nOld)
    *Buf = me->SWbuf[nCode - 1];
  else
    *msg   = MSFAIL;

  return (OM_S_SUCCESS);

} /* method init */

end implementation VCSYS;

