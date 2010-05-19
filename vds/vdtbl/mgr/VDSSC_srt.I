
/* $Id: VDSSC_srt.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDSSC_srt.I
 *
 * Description:
 *
 * Implementation file for sort criteria  manager internal methods (Private)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_srt.I,v $
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
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.3  1995/05/24  15:20:36  pinnacle
# Replaced: vdtbl/mgr/VDSSC_srt.I by hverstee r#
#
# Revision 1.2  1995/04/28  03:43:10  pinnacle
# Replaced: vdtbl/mgr/VDSSC_srt.I by hverstee r#
#
# Revision 1.1  1995/04/25  22:08:10  pinnacle
# Created: vdtbl/mgr/VDSSC_srt.I by hverstee r#
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



method   VDSSC_gsort (IGRlong         *msg;
                      IGRshort         nIndex;
                      IGRshort        *nCount;
               struct VDdrwlo_sort    *SrtRec)
{
  IGRint      nNumsrt;
  IGRint      i;

  *msg    = MSSUCC;
  *nCount = 0;
  nNumsrt = om$dimension_of (varray = me->Lsortrec);

  for (i=0;i<nNumsrt; i++)
  {
    if ((nIndex == VD_DRWLO_EN_ALL) || (nIndex == me->Lsortrec[i].nsIndex))
    {
      if (SrtRec)
      {
        SrtRec[*nCount].nsIndex = me->Lsortrec[i].nsIndex;
        SrtRec[*nCount].nsSeq   = me->Lsortrec[i].nsSeq;
        SrtRec[*nCount].nsTyp   = me->Lsortrec[i].nsTyp;

        strcpy (SrtRec[*nCount].szAtt, me->Lsortrec[i].szAtt);
      }

      (*nCount)++;
    }
  }

  return (OM_S_SUCCESS);
}

method   VDSSC_ssort (IGRlong         *msg;
                      IGRshort         nCount;
               struct VDdrwlo_sort    *SrtRec)
{
  IGRint      status;
  IGRint      i;

  status =
  om$vla_set_dimension (varray = me->Lsortrec,
                        size   = nCount);

  for (i=0; i<nCount; i++)
  {
    me->Lsortrec[i].nsIndex = SrtRec[i].nsIndex;
    me->Lsortrec[i].nsSeq   = SrtRec[i].nsSeq;
    me->Lsortrec[i].nsTyp   = SrtRec[i].nsTyp;

    strcpy (me->Lsortrec[i].szAtt, SrtRec[i].szAtt);
  }

  return (status);
}

end implementation VDSSC;

