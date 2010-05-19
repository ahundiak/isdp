
/* $Id: VDcrexp_if.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrexp_if.I
 *
 * Description:
 *
 * Implementation file for expression criteria  manager internal methods
 *    (Private)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrexp_if.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/10/21  03:59:40  pinnacle
# Created: vdtbl/mgr/VDcrexp_if.I by ksundar for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *	10/03/97        Sundar		Creation Date
 *
 * -------------------------------------------------------------------*/

class implementation VDcrexp;

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

// #define vdsDEBUG        1
#include "v_dbgmacros.h"

extern   int     atoi();

/*
#define   MY_DEBUG
*/



method   VDcrexp_fill   (IGRlong         *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRchar        szWhere[80];
  IGRint         iRow;
  IGRint         iDsp;

  SetProc( VDcrexp.VDcrexp_fill ); Begin
  *msg = MSFAIL;
  DbIO = NULL;

  /*   construct key (where clause)    */

  strcpy (szWhere, VDDRWLO_DB_KEY);
  strcat (szWhere, "=\'");
  strcat (szWhere, me->Expid_tab.Tabnam);
  strcat (szWhere, "\'");

  /*    load object from DB ........... */
  /*    general table                   */

  status=
  vdb$RisSelect (select     = VDCREXP_SEL_TAB,
                 table_name = VDCREXP_NAM_TAB,
                 where      = szWhere,
                 numselect  = VDCREXP_NUM_TAB,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDCREXP_NAM_TAB, szWhere);
    goto L_ABORT;
  }

  VD_mv_Iin_Quote (me->Expid_tab.Timest, DbIO[0]);
  VD_mv_Iin_Quote (me->Expid_tab.Userid, DbIO[1]);
  VD_mv_Iin_Quote (me->Expid_tab.Shdesc, DbIO[2]);

  me->Expid_tab.Local = FALSE;

  VdsRisFreeBuffer (DbIO, NbRow);

  /*       Data records       */

	/*
  strcpy (szWhere, VDDRWLO_DB_KEY);
  strcat (szWhere, "=\'");
  strcat (szWhere, me->Expid_tab.Tabnam);
  strcat (szWhere, "\'");
	*/
   sprintf ( szWhere,
                     "%s=\'%s\' and %s=\'%s\'",
                     VDDRWLO_DB_KEY, me->Expid_tab.Tabnam,
                     VDCREXP_SEL_GRP, VDCREXP_GRP_VAL);

  status=
  vdb$RisSelect (select     = VDCREXP_SEL_DAT,
                 table_name = VDCREXP_NAM_DAT,
                 where      = szWhere,
                 numselect  = VDCREXP_NUM_DAT,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDCREXP_NAM_DAT, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Ldatarec,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VDCREXP_NUM_DAT;

    VD_mv_Iin_Quote (me->Ldatarec[iRow].Datnam , DbIO[iDsp]);
    VD_mv_Iin_Quote (me->Ldatarec[iRow].Datgrp , DbIO[iDsp+1]);
    me->Ldatarec[iRow].Datsegn   = atoi (DbIO[iDsp+2]);
    VD_mv_Iin_Quote (me->Ldatarec[iRow].Datinfo , DbIO[iDsp+3]);

  }


  VdsRisFreeBuffer (DbIO, NbRow);

  *msg = MSSUCC;

  L_ABORT:
  End
  return (status);
}

end implementation VDcrexp;

