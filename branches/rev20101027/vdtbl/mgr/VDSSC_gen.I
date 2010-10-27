
/* $Id: VDSSC_gen.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDSSC_gen.I
 *
 * Description:
 *
 * Implementation file for top level criterion manager
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_gen.I,v $
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
# Revision 1.4  1995/08/18  15:53:58  pinnacle
# Replaced: vdtbl/mgr/VDSSC_gen.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/15  23:33:48  pinnacle
# Replaced: vdtbl/mgr/VDSSC_gen.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  14:37:56  pinnacle
# Replaced: vdtbl/mgr/VDSSC_gen.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.2  1995/05/10  22:06:46  pinnacle
# Replaced: vdtbl/mgr/VDSSC_gen.I by hverstee r#
#
# Revision 1.1  1995/04/25  22:07:32  pinnacle
# Created: vdtbl/mgr/VDSSC_gen.I by hverstee r#
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

#include <time.h>
#include <sys/types.h>

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
#include "vdpardef.h"



method   VDSSC_init   (IGRlong         *msg;
                struct VDdrwlo_sstab   *Tabrec)
{
  IGRint      status;

  *msg = MSSUCC;

  strcpy (me->SSid_tab.Tabnam, Tabrec->Tabnam);
  strcpy (me->SSid_tab.Shdesc, Tabrec->Shdesc);

  status = VD_DLO_SetIndx (me->SSid_tab.Userid,
                           me->SSid_tab.Timest,
                          &me->SSid_tab.Local,
                          &me->SSid_tab.LcUnit);

  /*   (re) initialize variable length arrays   */

  status = om$vla_set_dimension (varray = me->Lsortrec, size = 0);
  status = om$vla_set_dimension (varray = me->Lsqtyrec, size = 0);
  status = om$vla_set_dimension (varray = me->Lsmtcrec, size = 0);

  return (OM_S_SUCCESS);
}

method   VDSSC_gtab   (IGRlong         *msg;
                struct VDdrwlo_sstab   *Tabrec)
{

  *msg = MSSUCC;

  if (Tabrec)
  {
    strcpy (Tabrec->Tabnam,  me->SSid_tab.Tabnam);
    strcpy (Tabrec->Timest,  me->SSid_tab.Timest);
    strcpy (Tabrec->Userid,  me->SSid_tab.Userid);
    strcpy (Tabrec->Shdesc,  me->SSid_tab.Shdesc);

    Tabrec->Local  = me->SSid_tab.Local;
  }

  return (OM_S_SUCCESS);
}


method   VDSSC_check (IGRlong         *msg;
                      IGRshort        *nSrtIx;
                      IGRchar         *szCAT;
                      IGRchar         *szSBC;
                      IGRshort        *nSumIx)
{
  IGRshort   irec;
  IGRshort   nCount;

  *msg    = MSSUCC;
  *nSrtIx = *nSumIx = -1;

  nCount = om$dimension_of (varray = me->Lsortrec);

  for (irec = 0; irec < nCount; irec++)
  {
    if (me->Lsortrec[irec].szAtt[0]   != '\0') continue;

    /*    found incomplete     */

    *msg = MSFAIL;

    *nSrtIx = irec;
    goto WRAPUP;
  }

  nCount = om$dimension_of (varray = me->Lsqtyrec);

  for (irec = 0; irec < nCount; irec++)
  {
    if (me->Lsqtyrec[irec].nSflag == VD_DRWLO_EN_COUNT) continue;

    if (me->Lsqtyrec[irec].szExp[0]   != '\0') continue;

    /*    found incomplete     */

    *msg = MSFAIL;

    strcpy (szCAT, me->Lsqtyrec[irec].szCat);
    strcpy (szSBC, me->Lsqtyrec[irec].szSub);

    goto WRAPUP;
  }

  nCount = om$dimension_of (varray = me->Lsmtcrec);

  for (irec = 0; irec < nCount; irec++)
  {
    /*    allow complete spec   */
    if ((me->Lsmtcrec[irec].szExp[0]    != '\0') &&
        (me->Lsmtcrec[irec].szAtt[0]    != '\0') &&
        (me->Lsmtcrec[irec].nnREL       != VD_cnt_qry_NONE)) continue;

    /*    allow NONE with anything   */
    if (me->Lsmtcrec[irec].nnREL      == VD_cnt_qry_NONE) continue;

    /*    found incomplete     */

    *msg = MSFAIL;

    strcpy (szCAT, me->Lsmtcrec[irec].szCat);
    strcpy (szSBC, me->Lsmtcrec[irec].szSub);

    *nSumIx = irec;
    break;
  }

  WRAPUP:
  return (OM_S_SUCCESS);
}

end implementation VDSSC;

