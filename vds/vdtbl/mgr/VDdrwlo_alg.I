
/* $Id: VDdrwlo_alg.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_alg.I
 *
 * Description:
 *
 * Implementation file for alignment table maintenance
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_alg.I,v $
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
# Revision 1.2  1995/06/19  19:28:22  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_alg.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.4  1995/04/11  14:52:50  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_alg.I by hverstee r#
#
# Revision 1.3  1995/03/25  15:36:44  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_alg.I by hverstee r#
#
# Revision 1.2  1995/03/20  17:16:52  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_alg.I by hverstee r#
#
# Revision 1.1  1995/03/08  21:29:26  pinnacle
# Created: vdtbl/mgr/VDdrwlo_alg.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/09/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDdrwlo;

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

/*
#define MY_DEBUG
*/


method   VDdrwlo_galign (IGRlong          *msg;
                         IGRshort          nGrptyp;
                         IGRshort          nAligncode;
                         IGRshort         *nCount;
                  struct VDdrwlo_db_alg   *Align)
{
  IGRshort       nNumalg;
  IGRshort       iLoop;

  *msg    = MSSUCC;
  *nCount = 0;
  nNumalg = om$dimension_of (varray = me->Lalgrec);

  for (iLoop=0; iLoop<nNumalg; iLoop++)
  {
    if (VD_drwlo_calg (nGrptyp, nAligncode, &(me->Lalgrec[iLoop])))
    {
      if (Align != NULL)
        VD_drwlo_malg (&(Align[*nCount]), &(me->Lalgrec[iLoop]));

      (*nCount)++;
    }
  }

  return (OM_S_SUCCESS);
}

method   VDdrwlo_xalign (IGRlong          *msg;
                         IGRshort          nGrptyp;
                         IGRshort          nAligncode;
                         IGRshort         *nIndex)
{
  IGRshort       nNumalg;
  IGRshort       iLoop;

  *msg    = MSFAIL;
  *nIndex = -1;
  nNumalg = om$dimension_of (varray = me->Lalgrec);

  for (iLoop=0; iLoop<nNumalg; iLoop++)
  {
    if (VD_drwlo_calg (nGrptyp, nAligncode, &(me->Lalgrec[iLoop])))
    {
      *nIndex = iLoop;
      *msg    = MSSUCC;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

method   VDdrwlo_ialign (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRdouble        dValue;
                         IGRshort        *nCode)
{
  IGRint         status;
  IGRlong        retmsg;

  IGRshort       nGidx;
  IGRshort       nCut;
  IGRshort       iBeg, iEnd;
  IGRshort       nNumalg;
  IGRshort       nNumhtf;
  IGRshort       iLoop;
  IGRshort       jLoop;

  *msg    = MSFAIL;
  status  = OM_S_SUCCESS;
  if (nGrptyp == VD_DRWLO_EN_ALL) return (status);

  nGidx   = nGrptyp - 1;
  nCut    = me->nNBalg[nGidx];

  nNumalg = om$dimension_of (varray = me->Lalgrec);
  nNumhtf = om$dimension_of (varray = me->Lhtfrec);

  iBeg = iEnd = -1;

  for (iLoop=0; iLoop<4 ;iLoop++)
  {
    if (iLoop == nGidx)
    {
      iEnd = iBeg + me->nNBalg[iLoop];
      iBeg++;
      break;
    }
    else
    {
      iBeg += me->nNBalg[iLoop];
    }
  }
#ifdef MY_DEBUG
  printf (" alignrec insert range %d %d\n",iBeg, iEnd);
#endif

  if (iBeg > iEnd)    /*   empty section, insert without adjustment */
  {                   /*   should not happen !!!!                   */
    *msg   = MSSUCC;

#ifdef MY_DEBUG
  printf (" insert in empty \n");
#endif

    status = om$vla_set_dimension (varray = me->Lalgrec,
                                   size   = (nNumalg+1));
    for (iLoop=nNumalg; iLoop>iBeg; iLoop--)
        VD_drwlo_malg (&(me->Lalgrec[iLoop]),
                       &(me->Lalgrec[iLoop-1]));

    me->Lalgrec[iBeg].hdtr_type = nGrptyp;
    me->Lalgrec[iBeg].aligncode = 1;
    me->Lalgrec[iBeg].value     = dValue;

    me->nNBalg[nGidx] = 1;
    if (nCode) *nCode = 1;

    return (status);
  }

  if (dValue > me->Lalgrec[iEnd].value)
  {   /*   add after end of section, insert without adjustment */
    *msg   = MSSUCC;

#ifdef MY_DEBUG
  printf (" insert at end \n");
#endif

    status = om$vla_set_dimension (varray = me->Lalgrec,
                                   size   = (nNumalg+1));

    for (iLoop=nNumalg; iLoop>(iEnd+1); iLoop--)
        VD_drwlo_malg (&(me->Lalgrec[iLoop]),
                       &(me->Lalgrec[iLoop-1]));

    (me->nNBalg[nGidx])++;
    me->Lalgrec[iEnd+1].hdtr_type = nGrptyp;
    me->Lalgrec[iEnd+1].aligncode = me->nNBalg[nGidx];
    me->Lalgrec[iEnd+1].value     = dValue;

    return (status);
  }

  for (iLoop=(iBeg+1); iLoop<=iEnd; iLoop++)
  {
    nCut = me->Lalgrec[iLoop].aligncode;

    if ((me->Lalgrec[iLoop-1].value <= dValue) &&
        (me->Lalgrec[iLoop].value   >= dValue))
    {

      status = om$vla_set_dimension (varray = me->Lalgrec,
                                     size   = (nNumalg+1));

      for (jLoop = nNumalg; jLoop>iLoop; jLoop--)
      {
        VD_drwlo_malg (&(me->Lalgrec[jLoop]),
                       &(me->Lalgrec[jLoop-1]));
        if (me->Lalgrec[jLoop].hdtr_type == nGrptyp)
          (me->Lalgrec[jLoop].aligncode)++;
#ifdef MY_DEBUG
  printf (" move up to %d result %d %d %f\n",jLoop,
                                    me->Lalgrec[jLoop].hdtr_type,
                                    me->Lalgrec[jLoop].aligncode,
                                    me->Lalgrec[jLoop].value);
#endif

      }
#ifdef MY_DEBUG
  printf (" insert at %d for code %d\n",iLoop, nCut);
#endif


      (me->nNBalg[nGidx])++;
      me->Lalgrec[iLoop].value = dValue;

      if (nCode) *nCode = nCut;
      *msg    = MSSUCC;
      break;
    }
  }

  if (*msg == MSSUCC)
  { /*   adjust htf alignment pointers   */

    for (iLoop=0; iLoop<nNumhtf; iLoop++)
    {
      if (me->Lhtfrec[iLoop].htf_db.hdtr_type != nGrptyp) continue;

      if (me->Lhtfrec[iLoop].htf_db.align_bot >= nCut)
           me->Lhtfrec[iLoop].htf_db.align_bot++;

      if (me->Lhtfrec[iLoop].htf_db.align_top >= nCut)
           me->Lhtfrec[iLoop].htf_db.align_top++;
    }

    /*    recalculate instances   */

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_set
                            (&retmsg, nGrptyp, NULL),
        targetid = my_id);
  }

  return (status);
}


method   VDdrwlo_dalign (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRshort         nAligncode)
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nNumalg;
  IGRshort       nNumhtf;
  IGRshort       iLoop;
  IGRshort       jLoop;
  IGRshort       nGidx;

  *msg    = MSFAIL;
  status  = OM_S_SUCCESS;
  nNumalg = om$dimension_of (varray = me->Lalgrec);

  for (iLoop=0; iLoop<nNumalg; iLoop++)
  {
    if (VD_drwlo_calg (nGrptyp, nAligncode, &(me->Lalgrec[iLoop])))
    {
      IGRshort   nLocgrp;

      nLocgrp = me->Lalgrec[iLoop].hdtr_type;

      for (jLoop = iLoop; jLoop<(nNumalg-1); jLoop++)
      {
        VD_drwlo_malg (&(me->Lalgrec[jLoop]),
                       &(me->Lalgrec[jLoop+1]));

        if (me->Lalgrec[jLoop].hdtr_type == nLocgrp)
          me->Lalgrec[jLoop].aligncode--;
      }

      nGidx = nLocgrp - 1;

      (me->nNBalg[nGidx])--;

      nNumalg--;
      status = om$vla_set_dimension (varray = me->Lalgrec,
                                     size   = nNumalg);

      *msg = MSSUCC;
      break;
    }
  }

  if (*msg == MSSUCC)
  { /*   adjust htf alignment pointers   */
    nNumhtf = om$dimension_of (varray = me->Lhtfrec);

    for (iLoop=0; iLoop<nNumhtf; iLoop++)
    {
      if (me->Lhtfrec[iLoop].htf_db.hdtr_type != nGrptyp) continue;

      if (me->Lhtfrec[iLoop].htf_db.align_bot >= nAligncode)
           me->Lhtfrec[iLoop].htf_db.align_bot--;

      if (me->Lhtfrec[iLoop].htf_db.align_top >= nAligncode)
           me->Lhtfrec[iLoop].htf_db.align_top--;
    }

    /*    recalculate instances   */

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_set
                            (&retmsg, nGrptyp, NULL),
        targetid = my_id);
  }

  return (status);
}


method   VDdrwlo_palign (IGRlong         *msg;
                  struct VDdrwlo_db_alg  *Align)
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nNumalg;
  IGRshort       iLoop;

  *msg    = MSFAIL;
  status  = OM_S_SUCCESS;
  nNumalg = om$dimension_of (varray = me->Lalgrec);

  for (iLoop=0; iLoop<nNumalg; iLoop++)
  {
    if (VD_drwlo_calg(Align->hdtr_type, Align->aligncode,
                                       &(me->Lalgrec[iLoop])))
    {
      /*    replace alignment record   */

      VD_drwlo_malg (&(me->Lalgrec[iLoop]), Align);
      *msg    = MSSUCC;
      break;
    }
  }

  if (*msg == MSSUCC)
  {
    status =
    om$send (msg = message VDdrwlo.VDdrwlo_set
                            (&retmsg, Align->hdtr_type, NULL),
        targetid = my_id);
  }

  return (status);
}

method   VDdrwlo_salign (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_alg  *Align)
{
  IGRshort      iLoop;
  IGRshort      nGidx;
  IGRint        status;

  *msg   = MSSUCC;
  status = om$vla_set_dimension (varray = me->Lalgrec,
                                 size   = nCount);

  me->nNBalg[0] = me->nNBalg[1] = me->nNBalg[2] = me->nNBalg[3] = 0;

  for (iLoop =0; iLoop<nCount; iLoop++)
  {
    nGidx = Align[iLoop].hdtr_type - 1;
    VD_drwlo_malg (&(me->Lalgrec[iLoop]), &(Align[iLoop]));
    (me->nNBalg[nGidx])++;
  }

  return (status);
}


method   VDdrwlo_qalign (IGRlong          *msg;
                         IGRshort          nGrptyp)

{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nNumalg;
  IGRshort       nEnd;
  IGRboolean     chg;
  IGRshort       iLoop;
  IGRdouble      dVal;

  *msg    = MSSUCC;
  nNumalg = om$dimension_of (varray = me->Lalgrec);
  nEnd    = nNumalg - 1;
  chg     = TRUE;
  status  = OM_S_SUCCESS;

  while (chg)
  {
    chg = FALSE;

    for (iLoop=0; iLoop<nEnd; iLoop++)
    {
      if ((me->Lalgrec[iLoop].hdtr_type != nGrptyp) &&
          (nGrptyp != VD_DRWLO_EN_ALL))  continue;

      if (me->Lalgrec[iLoop].hdtr_type != me->Lalgrec[iLoop+1].hdtr_type)
             continue;
      if (me->Lalgrec[iLoop].value > me->Lalgrec[iLoop+1].value)
      {
        status =
        om$send (msg = message VDdrwlo.VDdrwlo_falign
                                  (&retmsg, me->Lalgrec[iLoop].hdtr_type,
                                    me->Lalgrec[iLoop].aligncode,
                                    me->Lalgrec[iLoop+1].aligncode),
            targetid = my_id);

        dVal                       = me->Lalgrec[iLoop].value;
        me->Lalgrec[iLoop].value   = me->Lalgrec[iLoop+1].value;
        me->Lalgrec[iLoop+1].value = dVal;
        chg = TRUE;
      }
    }
  }

  return (status);
}

method   VDdrwlo_falign (IGRlong          *msg;
                         IGRshort          nGrptyp;
                         IGRshort          nAlign1;
                         IGRshort          nAlign2)
{
  IGRshort       nNumhtf;
  IGRshort       iLoop;

  *msg = MSSUCC;
  nNumhtf = om$dimension_of (varray = me->Lhtfrec);

  for (iLoop=0; iLoop<nNumhtf; iLoop++)
  {
    if (me->Lhtfrec[iLoop].htf_db.hdtr_type != nGrptyp)   continue;

    if (me->Lhtfrec[iLoop].htf_db.align_top == nAlign1)
      me->Lhtfrec[iLoop].htf_db.align_top = nAlign2;
    else
    if (me->Lhtfrec[iLoop].htf_db.align_top == nAlign2)
      me->Lhtfrec[iLoop].htf_db.align_top = nAlign1;

    if (me->Lhtfrec[iLoop].htf_db.align_bot == nAlign1)
      me->Lhtfrec[iLoop].htf_db.align_bot = nAlign2;
    else
    if (me->Lhtfrec[iLoop].htf_db.align_bot == nAlign2)
      me->Lhtfrec[iLoop].htf_db.align_bot = nAlign1;
  }

  return (OM_S_SUCCESS);
}

end implementation VDdrwlo;

