
/* $Id: VDSSC_sum.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDSSC_sum.I
 *
 * Description:
 *
 * Implementation file for summarization criteria  manager internal methods
 *    (Private)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_sum.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/07/06  14:41:00  pinnacle
# Replaced: vdtbl/mgr/VDSSC_sum.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/04/25  22:09:16  pinnacle
# Created: vdtbl/mgr/VDSSC_sum.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/14/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDSSC;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"

#include "vdbmacros.h"

extern   int     atoi();

/*
#define   MY_DEBUG
*/



method   VDSSC_gsqty (IGRlong         *msg;
                      IGRchar         *szCat;
                      IGRchar         *szSub;
                      IGRshort        *nCount;
               struct VDdrwlo_sqty    *QtyRec)
{
  IGRint      nNumqty;
  IGRint      i;

  *msg    = MSSUCC;
  *nCount = 0;
  nNumqty = om$dimension_of (varray = me->Lsqtyrec);

  for (i=0;i<nNumqty; i++)
  {
    if (szCat)
      if (strcmp (szCat, me->Lsqtyrec[i].szCat) != 0)   continue;

    if (szSub)
      if (strcmp (szSub, me->Lsqtyrec[i].szSub) != 0)   continue;

    if (QtyRec)
    {
      strcpy (QtyRec[*nCount].szCat, me->Lsqtyrec[i].szCat);
      strcpy (QtyRec[*nCount].szSub, me->Lsqtyrec[i].szSub);
      strcpy (QtyRec[*nCount].szExp, me->Lsqtyrec[i].szExp);

      QtyRec[*nCount].nSflag  = me->Lsqtyrec[i].nSflag;
    }

    (*nCount)++;
  }

  return (OM_S_SUCCESS);
}

method   VDSSC_giqty (IGRlong         *msg;
                      IGRchar         *szCat;
                      IGRchar         *szSub;
                      IGRshort        *nIndex)
{
  IGRint      nNumqty;
  IGRint      i;

  *msg    = MSSUCC;
  *nIndex = -1;
  nNumqty = om$dimension_of (varray = me->Lsqtyrec);
  if ((szCat == NULL) || (szSub == NULL)) return (OM_S_SUCCESS);

  for (i=0;i<nNumqty; i++)
  {
    if ((strcmp (szCat, me->Lsqtyrec[i].szCat) == 0) &&
        (strcmp (szSub, me->Lsqtyrec[i].szSub) == 0))
    {
      *nIndex = i;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

method   VDSSC_ssqty (IGRlong         *msg;
                      IGRshort         nCount;
               struct VDdrwlo_sqty    *QtyRec)
{
  IGRint      status;
  IGRint      i;

  status =
  om$vla_set_dimension (varray = me->Lsqtyrec,
                        size   = nCount);

  for (i=0; i<nCount; i++)
  {
    strcpy (me->Lsqtyrec[i].szCat, QtyRec[i].szCat);
    strcpy (me->Lsqtyrec[i].szSub, QtyRec[i].szSub);
    strcpy (me->Lsqtyrec[i].szExp, QtyRec[i].szExp);

    me->Lsqtyrec[i].nSflag = QtyRec[i].nSflag;
  }

  return (status);
}


method   VDSSC_gsmtc (IGRlong         *msg;
                      IGRchar         *szCat;
                      IGRchar         *szSub;
                      IGRshort         nIndex;
                      IGRshort        *nCount;
               struct VDdrwlo_smatch  *MtcRec)
{
  IGRint      nNummtc;
  IGRint      i;

  *msg    = MSSUCC;
  *nCount = 0;
  nNummtc = om$dimension_of (varray = me->Lsmtcrec);

  for (i=0;i<nNummtc; i++)
  {
    if (szCat)
      if (strcmp (szCat, me->Lsmtcrec[i].szCat) != 0)   continue;

    if (szSub)
      if (strcmp (szSub, me->Lsmtcrec[i].szSub) != 0)   continue;

    if (nIndex != VD_DRWLO_EN_ALL)
      if (nIndex != me->Lsmtcrec[i].nsIndex)            continue;

    if (MtcRec)
    {
      strcpy (MtcRec[*nCount].szCat, me->Lsmtcrec[i].szCat);
      strcpy (MtcRec[*nCount].szSub, me->Lsmtcrec[i].szSub);
      strcpy (MtcRec[*nCount].szAtt, me->Lsmtcrec[i].szAtt);
      strcpy (MtcRec[*nCount].szExp, me->Lsmtcrec[i].szExp);

      MtcRec[*nCount].nsIndex  = me->Lsmtcrec[i].nsIndex;
      MtcRec[*nCount].nnREL    = me->Lsmtcrec[i].nnREL;
      MtcRec[*nCount].nDattyp  = me->Lsmtcrec[i].nDattyp;
    }

    (*nCount)++;
  }

  return (OM_S_SUCCESS);
}

method   VDSSC_gimtc (IGRlong         *msg;
                      IGRchar         *szCat;
                      IGRchar         *szSub;
                      IGRshort        *nBeg;
                      IGRshort        *nEnd)
{
  IGRint      nNummtc;
  IGRint      i;
  IGRboolean  bFound;

  *msg    = MSSUCC;
  nNummtc = om$dimension_of (varray = me->Lsmtcrec);
  *nBeg   = -1;
  *nEnd   = -1;
  bFound  = FALSE;

  if ((szCat == NULL) || (szSub == NULL)) return (OM_S_SUCCESS);

  for (i=0;i<nNummtc; i++)
  {
    if (szCat)
      if (strcmp (szCat, me->Lsmtcrec[i].szCat) != 0) goto MISMATCH;

    if (szSub)
      if (strcmp (szSub, me->Lsmtcrec[i].szSub) != 0) goto MISMATCH;

    if (bFound) continue;

    /*   match or unspecified   */

    bFound = TRUE;
    *nBeg  = i;
    continue;

    MISMATCH:
    if (bFound)
    {
      *nEnd = i-1;
      break;
    }
  }

  if (bFound && (*nEnd == -1))
   *nEnd = nNummtc - 1;

  return (OM_S_SUCCESS);
}


method   VDSSC_ssmtc (IGRlong         *msg;
                      IGRshort         nCount;
               struct VDdrwlo_smatch  *MtcRec)
{
  IGRint      status;
  IGRint      i;

  status =
  om$vla_set_dimension (varray = me->Lsmtcrec,
                        size   = nCount);

  for (i=0; i<nCount; i++)
  {
    strcpy (me->Lsmtcrec[i].szCat, MtcRec[i].szCat);
    strcpy (me->Lsmtcrec[i].szSub, MtcRec[i].szSub);
    strcpy (me->Lsmtcrec[i].szExp, MtcRec[i].szExp);
    strcpy (me->Lsmtcrec[i].szAtt, MtcRec[i].szAtt);

    me->Lsmtcrec[i].nsIndex = MtcRec[i].nsIndex;
    me->Lsmtcrec[i].nnREL   = MtcRec[i].nnREL;
    me->Lsmtcrec[i].nDattyp = MtcRec[i].nDattyp;
  }

  return (status);
}

end implementation VDSSC;

