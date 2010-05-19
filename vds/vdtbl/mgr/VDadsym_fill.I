
/* $Id: VDadsym_fill.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDadsym_fill.I
 *
 * Description:
 *
 * Implementation file for ADS manager database fill
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDadsym_fill.I,v $
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
# Revision 1.5  1995/11/17  22:22:22  pinnacle
# Replaced: vdtbl/mgr/VDadsym_fill.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/09/25  23:45:52  pinnacle
# Replaced: vdtbl/mgr/VDadsym_fill.I for:  by sundar for vds.240
#
# Revision 1.3  1995/08/11  19:10:00  pinnacle
# Replaced: vdtbl/mgr/VDadsym_fill.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  14:38:22  pinnacle
# Replaced: vdtbl/mgr/VDadsym_fill.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/19  19:32:50  pinnacle
# Created: vdtbl/mgr/VDadsym_fill.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/12/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDadsym;

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
extern   double  atof();

/*
#define   MY_DEBUG
*/



method   VDADS_fill   (IGRlong         *msg)
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
  vdb$RisSelect (select     = VDADSYM_SEL_TAB,
                 table_name = VDADSYM_NAM_TAB,
                 where      = szWhere,
                 numselect  = VDADSYM_NUM_TAB,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDADSYM_NAM_TAB, szWhere);
    goto L_ABORT;
  }

  VD_mv_Iin_Quote (me->SSid_tab.Timest, DbIO[0]);
  VD_mv_Iin_Quote (me->SSid_tab.Userid, DbIO[1]);
  VD_mv_Iin_Quote (me->SSid_tab.Shdesc, DbIO[2]);

  me->SSid_tab.LcUnit = atoi (DbIO[3]);
  me->SSid_tab.Local  = FALSE;

  VdsRisFreeBuffer (DbIO, NbRow);

  /*       sortkey records       */

  status=
  vdb$RisSelect (select     = VDADSYM_SEL_REC,
                 table_name = VDADSYM_NAM_REC,
                 where      = szWhere,
                 numselect  = VDADSYM_NUM_REC,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDADSYM_NAM_REC, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Ladsrec,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VDADSYM_NUM_REC;

    me->Ladsrec[iRow].nDattyp   = atoi (DbIO[iDsp+2]);
    me->Ladsrec[iRow].nnREL     = atoi (DbIO[iDsp+3]);
    me->Ladsrec[iRow].dAttval   = atof (DbIO[iDsp+4]);
    me->Ladsrec[iRow].nnSide    = atoi (DbIO[iDsp+6]);
    me->Ladsrec[iRow].dOffset   = atof (DbIO[iDsp+7]);
    me->Ladsrec[iRow].dCharhgt  = atof (DbIO[iDsp+8]);
    me->Ladsrec[iRow].dCharwdt  = atof (DbIO[iDsp+9]);
    me->Ladsrec[iRow].dCharspc  = atof (DbIO[iDsp+10]);
    me->Ladsrec[iRow].nCharwgt  = atoi (DbIO[iDsp+11]);

    VD_mv_Iin_Quote (me->Ladsrec[iRow].Symbol   , DbIO[iDsp]);
    VD_mv_Iin_Quote (me->Ladsrec[iRow].szAtt    , DbIO[iDsp+1]);
    VD_mv_Iin_Quote (me->Ladsrec[iRow].szAttval , DbIO[iDsp+5]);
    VD_mv_Iin_Quote (me->Ladsrec[iRow].font     , DbIO[iDsp+12]);
  }


  VdsRisFreeBuffer (DbIO, NbRow);

  *msg = MSSUCC;

  L_ABORT:
  return (status);
}

end implementation VDadsym;

