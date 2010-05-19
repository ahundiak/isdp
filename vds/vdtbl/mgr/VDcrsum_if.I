
/* $Id: VDcrsum_if.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrsum_if.I
 *
 * Description:
 *
 * Implementation file for summarization criteria  manager internal methods
 *    (Private)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrsum_if.I,v $
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
# Revision 1.2  1995/11/17  22:20:56  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_if.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.1  1995/04/25  22:22:34  pinnacle
# Created: vdtbl/mgr/VDcrsum_if.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/14/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDcrsum;

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

#include "v_postproto.h"

extern   int     atoi();

/*
#define   MY_DEBUG
*/



method   VDSSC_fill   (IGRlong         *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRchar        szWhere[60];
  IGRint         iRow;
  IGRint         iDsp;

  *msg = MSFAIL;
  DbIO = NULL;

  /*   construct key (where clause)    */

  strcpy (szWhere, VDDRWLO_DB_KEY);
  strcat (szWhere, "=\'");
  strcat (szWhere, me->SSid_tab.Tabnam);
  strcat (szWhere, "\'");

  /*    load object from DB ........... */
  /*    general table                   */

  status=
  vdb$RisSelect (select     = VDCRSUM_SEL_TAB,
                 table_name = VDCRSUM_NAM_TAB,
                 where      = szWhere,
                 numselect  = VDCRSUM_NUM_TAB,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDCRSUM_NAM_TAB, szWhere);
    goto L_ABORT;
  }

  VD_mv_Iin_Quote (me->SSid_tab.Timest, DbIO[0]);
  VD_mv_Iin_Quote (me->SSid_tab.Userid, DbIO[1]);
  VD_mv_Iin_Quote (me->SSid_tab.Shdesc, DbIO[2]);

  me->SSid_tab.Local = FALSE;

  VdsRisFreeBuffer (DbIO, NbRow);

  /*       sqty records       */

  status=
  vdb$RisSelect (select     = VDCRSUM_SEL_QTY,
                 table_name = VDCRSUM_NAM_QTY,
                 where      = szWhere,
                 numselect  = VDCRSUM_NUM_QTY,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDCRSUM_NAM_QTY, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Lsqtyrec,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VDCRSUM_NUM_QTY;

    VD_mv_Iin_Quote (me->Lsqtyrec[iRow].szCat , DbIO[iDsp]);
    VD_mv_Iin_Quote (me->Lsqtyrec[iRow].szSub , DbIO[iDsp+1]);

    me->Lsqtyrec[iRow].nSflag   = atoi (DbIO[iDsp+2]);

    VD_mv_Iin_Quote (me->Lsqtyrec[iRow].szExp , DbIO[iDsp+3]);
  }


  VdsRisFreeBuffer (DbIO, NbRow);

  /*    smatch records   */

  status=
  vdb$RisSelect (select     = VDCRSUM_SEL_MTC,
                 table_name = VDCRSUM_NAM_MTC,
                 where      = szWhere,
                 numselect  = VDCRSUM_NUM_MTC,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDCRSUM_NAM_MTC, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Lsmtcrec,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VDCRSUM_NUM_MTC;

    VD_mv_Iin_Quote (me->Lsmtcrec[iRow].szCat , DbIO[iDsp]);
    VD_mv_Iin_Quote (me->Lsmtcrec[iRow].szSub , DbIO[iDsp+1]);

    me->Lsmtcrec[iRow].nsIndex  = atoi (DbIO[iDsp+2]);

    VD_mv_Iin_Quote (me->Lsmtcrec[iRow].szAtt , DbIO[iDsp+3]);

    me->Lsmtcrec[iRow].nnREL    = atoi (DbIO[iDsp+4]);
    me->Lsmtcrec[iRow].nDattyp  = atoi (DbIO[iDsp+5]);

    VD_mv_Iin_Quote (me->Lsmtcrec[iRow].szExp , DbIO[iDsp+6]);
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  *msg = MSSUCC;

  L_ABORT:
  return (status);
}

end implementation VDcrsum;

