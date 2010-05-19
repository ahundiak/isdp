
/* $Id: VDdrwlo_col.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_col.I
 *
 * Description:
 *
 * Implementation file for column table maintenance
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_col.I,v $
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
# Revision 1.2  1995/05/23  15:53:12  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_col.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.4  1995/04/11  14:56:12  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_col.I by hverstee r#
#
# Revision 1.3  1995/03/25  15:37:24  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_col.I by hverstee r#
#
# Revision 1.2  1995/03/20  17:17:34  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_col.I by hverstee r#
#
# Revision 1.1  1995/03/08  21:30:16  pinnacle
# Created: vdtbl/mgr/VDdrwlo_col.I by hverstee r#
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


method   VDdrwlo_gcol   (IGRlong         *msg;
                         IGRshort         nColno;
                         IGRshort        *nCount;
                  struct VDdrwlo_db_col  *Col)
{
  IGRshort       nNumcol;
  IGRshort       iLoop;

  *msg    = MSSUCC;
  *nCount = 0;
  nNumcol = om$dimension_of (varray = me->Lcolrec);

  for (iLoop=0; iLoop<nNumcol; iLoop++)
  {
    if (VD_drwlo_ccol (nColno, &(me->Lcolrec[iLoop].col_db)))
    {
      if (Col != NULL)
        VD_drwlo_mcol (&(Col[*nCount]), &(me->Lcolrec[iLoop].col_db));

      (*nCount)++;
    }
  }

  return (OM_S_SUCCESS);
}

method   VDdrwlo_xcol   (IGRlong         *msg;
                         IGRshort         nColno;
                         IGRshort        *nIndex)
{
  IGRshort       nNumcol;
/*
  IGRshort       iLoop;
*/

  *msg    = MSFAIL;
  *nIndex = -1;
  nNumcol = om$dimension_of (varray = me->Lcolrec);

/*
  for (iLoop=0; iLoop<nNumcol; iLoop++)
  {
    if (VD_drwlo_ccol (nColno, &(me->Lcolrec[iLoop].col_db)))
    {
      *nIndex = iLoop;
      *msg    = MSSUCC;
      break;
    }
  }
*/

  if ((nColno > 0) && (nColno <= nNumcol)) *nIndex = nColno - 1;

  return (OM_S_SUCCESS);
}


method   VDdrwlo_dcol   (IGRlong         *msg;
                         IGRshort         nColno)
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nNumcol;
  IGRshort       nNumhtf;
  IGRshort       nNumfld;
  IGRshort       iLoop;
  IGRshort       jLoop;

  *msg    = MSFAIL;
  nNumcol = om$dimension_of (varray = me->Lcolrec);

  /*   delete associated fields    */

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_dfld
                          (&retmsg, VD_DRWLO_EN_DATA, nColno, NULL,
                           VD_DRWLO_EN_ALL),
      targetid = my_id);

  for (iLoop=0; iLoop<nNumcol; iLoop++)
  {
    if (VD_drwlo_ccol(nColno, &(me->Lcolrec[iLoop].col_db)))
    {
      for (jLoop = iLoop; jLoop<(nNumcol-1); jLoop++)
      {
        VD_drwlo_mcol (&(me->Lcolrec[jLoop].col_db),
                       &(me->Lcolrec[jLoop+1].col_db));

        me->Lcolrec[jLoop].col_db.col_seqno--;
      }

      nNumcol--;
      status = om$vla_set_dimension (varray = me->Lcolrec,
                                     size   = nNumcol);
      *msg = MSSUCC;
      break;
    }
  }

  if (*msg == MSSUCC)
  {
    nNumfld = om$dimension_of (varray = me->Lfldrec);

    for (iLoop = 0; iLoop<nNumfld; iLoop++)
    {
      if (me->Lfldrec[iLoop].col_seqno >= nColno)
        (me->Lfldrec[iLoop].col_seqno)--;
    }

    /*    adjust header/trailer alignment     */

    nNumhtf = om$dimension_of (varray = me->Lhtfrec);

    for (iLoop=0; iLoop<nNumhtf; iLoop++)
    {
      if (me->Lhtfrec[iLoop].htf_db.align_lcol >= nColno)
           me->Lhtfrec[iLoop].htf_db.align_lcol--;

      if (me->Lhtfrec[iLoop].htf_db.align_rcol >= nColno)
           me->Lhtfrec[iLoop].htf_db.align_rcol--;
    }

    /*    recalculate instances    */

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_set
                            (&retmsg, VD_DRWLO_EN_ALL, NULL),
        targetid = my_id);
  }

  return (status);
}

method   VDdrwlo_icol   (IGRlong         *msg;
                  struct VDdrwlo_db_col  *Col)
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nNumcol;
  IGRshort       nNumfld;
  IGRshort       nNumhtf;
  IGRshort       iLoop;
  IGRshort       jLoop;
  IGRshort       nColno;

  *msg    = MSFAIL;
  nNumcol = om$dimension_of (varray = me->Lcolrec);
  nColno  = Col->col_seqno;
  status  = OM_S_SUCCESS;

  if (nColno > nNumcol)
  {  /* insert after end  */
    status = om$vla_set_dimension (varray = me->Lcolrec,
                                   size   = nColno);

    VD_drwlo_mcol (&(me->Lcolrec[nColno-1].col_db), Col);
    *msg = MSSUCC;
  }
  else
  {
    for (iLoop=0; iLoop<nNumcol; iLoop++)
    {
      if (VD_drwlo_ccol(nColno, &(me->Lcolrec[iLoop].col_db)))
      {
        status = om$vla_set_dimension (varray = me->Lcolrec,
                                       size   = (nNumcol+1));

        /*    insert new column    */

        for (jLoop = nNumcol; jLoop>iLoop; jLoop--)
        {
          VD_drwlo_mcol (&(me->Lcolrec[jLoop].col_db),
                         &(me->Lcolrec[jLoop-1].col_db));
          (me->Lcolrec[jLoop].col_db.col_seqno)++;
        }

        VD_drwlo_mcol (&(me->Lcolrec[iLoop].col_db), Col);
        *msg = MSSUCC;
        break;
      }
    }

    if (*msg == MSSUCC)
    { /*    bump all appropriate fields   */
      nNumfld = om$dimension_of (varray = me->Lfldrec);

      for (jLoop = 0; jLoop<nNumfld; jLoop++)
      {
        if (me->Lfldrec[jLoop].col_seqno >= nColno)
          (me->Lfldrec[jLoop].col_seqno)++;
      }

      /*    and all appropriate htf references  */

      nNumhtf = om$dimension_of (varray = me->Lhtfrec);

      for (jLoop = 0; jLoop<nNumhtf; jLoop++)
      {
        if (me->Lhtfrec[jLoop].htf_db.align_lcol >= nColno)
          (me->Lhtfrec[jLoop].htf_db.align_lcol)++;
        if (me->Lhtfrec[jLoop].htf_db.align_rcol >= nColno)
          (me->Lhtfrec[jLoop].htf_db.align_rcol)++;
      }
    }
  }

    /*    recalculate column and htf instances    */

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_set
                          (&retmsg, VD_DRWLO_EN_ALL, NULL),
      targetid = my_id);

  return (status);
}


method   VDdrwlo_pcol   (IGRlong         *msg;
                  struct VDdrwlo_db_col  *Col)
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nNumcol;
  IGRshort       iLoop;

  *msg    = MSFAIL;
  status  = OM_S_SUCCESS;
  nNumcol = om$dimension_of (varray = me->Lcolrec);

  for (iLoop=0; iLoop<nNumcol; iLoop++)
  {
    if (VD_drwlo_ccol(Col->col_seqno, &(me->Lcolrec[iLoop].col_db)))
    {
      /*    replace column    */

      VD_drwlo_mcol (&(me->Lcolrec[iLoop].col_db), Col);
      *msg = MSSUCC;
      break;
    }
  }

  if (*msg == MSSUCC)
  {  /*   recalculate column instances   */
    status =
    om$send (msg = message VDdrwlo.VDdrwlo_set
                            (&retmsg, VD_DRWLO_EN_ALL, NULL),
        targetid = my_id);
  }

  return (status);
}

method   VDdrwlo_scol   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_col  *Col)
{
  IGRshort      iLoop;
  IGRint        status;

  *msg   = MSSUCC;
  status = om$vla_set_dimension (varray = me->Lcolrec,
                                 size   = nCount);

  for (iLoop =0; iLoop<nCount; iLoop++)
  {
    VD_drwlo_mcol (&(me->Lcolrec[iLoop].col_db), &(Col[iLoop]));
  }

  return (status);
}

end implementation VDdrwlo;

