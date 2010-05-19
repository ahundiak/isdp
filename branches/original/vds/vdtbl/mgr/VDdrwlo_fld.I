
/* $Id: VDdrwlo_fld.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_fld.I
 *
 * Description:
 *
 * Implementation file for field fill table maintenance
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_fld.I,v $
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
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.4  1995/04/11  14:54:48  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fld.I by hverstee r#
#
# Revision 1.3  1995/03/25  15:38:48  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fld.I by hverstee r#
#
# Revision 1.2  1995/03/20  17:23:12  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fld.I by hverstee r#
#
# Revision 1.1  1995/03/08  21:32:20  pinnacle
# Created: vdtbl/mgr/VDdrwlo_fld.I by hverstee r#
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


method   VDdrwlo_gfld   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRshort         nColno;
                         IGRchar         *pFieldid;
                         IGRshort         nLinseq;
                         IGRshort        *nCount;
                  struct VDdrwlo_db_fld  *Fld)
{
  IGRshort       nNumfld;
  IGRshort       iLoop;

  *msg    = MSSUCC;
  *nCount = 0;
  nNumfld = om$dimension_of (varray = me->Lfldrec);

  for (iLoop=0; iLoop<nNumfld; iLoop++)
  {
    if (VD_drwlo_cfld (nGrptyp, nColno, pFieldid, nLinseq, &me->Lfldrec[iLoop]))
    {

      if (Fld != NULL)
        VD_drwlo_mfld (&(Fld[*nCount]), &(me->Lfldrec[iLoop]));

      (*nCount)++;
    }
  }

  return (OM_S_SUCCESS);
}

method   VDdrwlo_xfld   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRshort         nColno;
                         IGRchar         *pFieldid;
                         IGRshort         nLinseq;
                         IGRshort        *nIndex)
{
  IGRshort       nNumfld;
  IGRshort       iLoop;

  *msg    = MSFAIL;
  *nIndex = -1;
  nNumfld = om$dimension_of (varray = me->Lfldrec);

  for (iLoop=0; iLoop<nNumfld; iLoop++)
  {
    if (VD_drwlo_cfld (nGrptyp, nColno, pFieldid, nLinseq, &me->Lfldrec[iLoop]))
    {
      *nIndex = iLoop;
      *msg    = MSSUCC;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

method   VDdrwlo_dfld   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRshort         nColno;
                         IGRchar         *pFieldid;
                         IGRshort         nLinseq)
{
  IGRint         status;
  IGRshort       nNumfld;
  IGRshort       iLoop;
  IGRshort       jLoop;

  *msg    = MSFAIL;
  status  = OM_S_SUCCESS;
  nNumfld = om$dimension_of (varray = me->Lfldrec);

  for (iLoop=0; iLoop<nNumfld; iLoop++)
  {
    if (VD_drwlo_cfld (nGrptyp, nColno, pFieldid, nLinseq, &me->Lfldrec[iLoop]))
    {
      *msg   = MSSUCC;

      for (jLoop = iLoop; jLoop<(nNumfld-1); jLoop++)
      {
        VD_drwlo_mfld (&(me->Lfldrec[jLoop]), &(me->Lfldrec[jLoop+1]));
      }

      nNumfld--;

      status = om$vla_set_dimension (varray = me->Lfldrec,
                                     size   = nNumfld);

      if (nNumfld == 0)  break;
    }
  }

  return (status);
}


method   VDdrwlo_pfld   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_fld  *Fld)
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nNumfld;
  IGRshort       iAdd;
  IGRshort       iLoop;
  IGRshort       jLoop;

  *msg    = MSSUCC;
  nNumfld = om$dimension_of (varray = me->Lfldrec);

  for (jLoop=0; jLoop<nCount; jLoop++)
  {
    for (iLoop=0; iLoop<nNumfld; iLoop++)
    {
      if (VD_drwlo_cfld (Fld[jLoop].hdtr_type,
                         Fld[jLoop].col_seqno,
                         Fld[jLoop].fieldid,
                         Fld[jLoop].lin_seqno,
                         &(me->Lfldrec[iLoop])))
      {
        iAdd = iLoop;
        goto ADD_IT;
      }
    }

    iAdd = nNumfld;
    nNumfld++;

    status = om$vla_set_dimension (varray = me->Lfldrec,
                                   size   = nNumfld);

    ADD_IT:
    VD_drwlo_mfld (&(me->Lfldrec[iAdd]), &(Fld[jLoop]));
  }

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_set
                          (&retmsg, VD_DRWLO_EN_DATA, NULL),
      targetid = my_id);

  return (OM_S_SUCCESS);
}

method   VDdrwlo_sfld   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_fld  *Fld)
{
  IGRshort      iLoop;
  IGRint        status;

  *msg   = MSSUCC;
  status = om$vla_set_dimension (varray = me->Lfldrec,
                                 size   = nCount);

  for (iLoop =0; iLoop<nCount; iLoop++)
  {
    VD_drwlo_mfld (&(me->Lfldrec[iLoop]), &(Fld[iLoop]));
  }

  return (status);
}

end implementation VDdrwlo;

