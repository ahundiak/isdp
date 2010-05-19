
/* $Id: VDdrwlo_htf.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_htf.I
 *
 * Description:
 *
 * Implementation file for header/trailer table maintenance
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_htf.I,v $
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
# Revision 1.4  1995/04/11  14:54:12  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_htf.I by hverstee r#
#
# Revision 1.3  1995/03/25  15:41:28  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_htf.I by hverstee r#
#
# Revision 1.2  1995/03/20  17:26:00  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_htf.I by hverstee r#
#
# Revision 1.1  1995/03/08  21:33:26  pinnacle
# Created: vdtbl/mgr/VDdrwlo_htf.I by hverstee r#
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



method   VDdrwlo_ghtf   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRchar         *pFieldid;
                         IGRshort        *nCount;
                  struct VDdrwlo_db_htf  *Htf)
{
  IGRshort       nNumhtf;
  IGRshort       iLoop;

  *msg    = MSSUCC;
  *nCount = 0;
  nNumhtf = om$dimension_of (varray = me->Lhtfrec);

  for (iLoop=0; iLoop<nNumhtf; iLoop++)
  {
    if (VD_drwlo_chtf(nGrptyp, pFieldid, &(me->Lhtfrec[iLoop].htf_db)))
    {
      if (Htf != NULL)
        VD_drwlo_mhtf (&(Htf[*nCount]), &(me->Lhtfrec[iLoop].htf_db));

      (*nCount)++;
    }
  }

  return (OM_S_SUCCESS);
}

method   VDdrwlo_xhtf   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRchar         *pFieldid;
                         IGRshort        *nIndex)
{
  IGRshort       nNumhtf;
  IGRshort       iLoop;

  *msg    = MSFAIL;
  *nIndex = -1;
  nNumhtf = om$dimension_of (varray = me->Lhtfrec);

  for (iLoop=0; iLoop<nNumhtf; iLoop++)
  {
    if (VD_drwlo_chtf(nGrptyp, pFieldid, &(me->Lhtfrec[iLoop].htf_db)))
    {
      *nIndex = iLoop;
      *msg    = MSSUCC;
      break;
    }
  }

  return (OM_S_SUCCESS);
}

method   VDdrwlo_dhtf   (IGRlong         *msg;
                         IGRshort         nGrptyp;
                         IGRchar         *pFieldid)
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nNumhtf;
  IGRshort       iLoop;
  IGRshort       jLoop;

  *msg    = MSSUCC;
  status  = OM_S_SUCCESS;
  nNumhtf = om$dimension_of (varray = me->Lhtfrec);

  for (iLoop=0; iLoop<nNumhtf; iLoop++)
  {
    if (VD_drwlo_chtf(nGrptyp, pFieldid, &(me->Lhtfrec[iLoop].htf_db)))
    {
      /*    remove field records    */

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_dfld
                                (&retmsg, me->Lhtfrec[iLoop].htf_db.hdtr_type,
                                 VD_DRWLO_EN_ALL, pFieldid, VD_DRWLO_EN_ALL),
        targetid = my_id);

      for (jLoop = iLoop; jLoop<(nNumhtf-1); jLoop++)
      {
        me->Lhtfrec[jLoop].htf_x1    = me->Lhtfrec[jLoop+1].htf_x1;
        me->Lhtfrec[jLoop].htf_y1    = me->Lhtfrec[jLoop+1].htf_y1;
        me->Lhtfrec[jLoop].htf_x2    = me->Lhtfrec[jLoop+1].htf_x2;
        me->Lhtfrec[jLoop].htf_y2    = me->Lhtfrec[jLoop+1].htf_y2;
        me->Lhtfrec[jLoop].htf_lns   = me->Lhtfrec[jLoop+1].htf_lns;

        VD_drwlo_mhtf (&(me->Lhtfrec[jLoop].htf_db),
                       &(me->Lhtfrec[jLoop+1].htf_db));
      }

      nNumhtf--;
      status = om$vla_set_dimension (varray = me->Lhtfrec,
                                     size   = nNumhtf);

      if (nNumhtf == 0)  break;
    }
  }

  return (status);
}


method   VDdrwlo_phtf   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_htf  *Htf)
{
  IGRint         status;
  IGRlong        retmsg;
  IGRshort       nNumhtf;
  IGRshort       iAdd;
  IGRshort       iLoop;
  IGRshort       jLoop;
  IGRshort       nGrp;

  *msg    = MSSUCC;
  status  = OM_S_SUCCESS;
  nNumhtf = om$dimension_of (varray = me->Lhtfrec);

  for (jLoop=0; jLoop<nCount; jLoop++)
  {
    nGrp = Htf->hdtr_type;

    for (iLoop=0; iLoop<nNumhtf; iLoop++)
    {
      if (VD_drwlo_chtf(Htf[jLoop].hdtr_type,
                        Htf[jLoop].fieldid,
                        &(me->Lhtfrec[iLoop].htf_db)))
      {
        iAdd = iLoop;
        goto ADD_IT;
      }
    }

    iAdd = nNumhtf;
    nNumhtf++;

    status = om$vla_set_dimension (varray = me->Lhtfrec,
                                   size   = nNumhtf);

    ADD_IT:
    VD_drwlo_mhtf (&(me->Lhtfrec[iAdd].htf_db), &(Htf[jLoop]));

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_set
                              (&retmsg, nGrp, &(me->Lhtfrec[iAdd])),
        targetid = my_id);
  }

  /*    sort and straighten out ???   */

  return (status);
}

method   VDdrwlo_shtf   (IGRlong         *msg;
                         IGRshort         nCount;
                  struct VDdrwlo_db_htf  *Htf)
{
  IGRshort      iLoop;
  IGRint        status;

  *msg   = MSSUCC;
  status = om$vla_set_dimension (varray = me->Lhtfrec,
                                 size   = nCount);

  for (iLoop =0; iLoop<nCount; iLoop++)
  {
    VD_drwlo_mhtf (&(me->Lhtfrec[iLoop].htf_db), &(Htf[iLoop]));
  }

  return (status);
}

end implementation VDdrwlo;

