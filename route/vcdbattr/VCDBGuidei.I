
/* $Id: VCDBGuidei.I,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr/VCDBGuidei.I
 *
 * Description:
 *   This file contains the methods and functions used to implement
 *   the Fiberoptic cable DB cache.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBGuidei.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/07/21  22:50:16  pinnacle
# Replaced: vcdbattr/VCDBGuidei.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/14  21:43:42  pinnacle
# Replaced: vcdbattr/VCDBGuidei.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:17:32  pinnacle
# Replaced: vcdbattr/VCDBGuidei.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/29  22:12:50  pinnacle
# Replaced: vcdbattr/VCDBGuidei.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:52:16  pinnacle
# Created: vcdbattr/VCDBGuidei.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCDBGuide;

#include "VCdbaccess.h"
#include "v_postproto.h"


method  VCDB_fill (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRchar        szWhere[60];

  *msg = MSFAIL;
  DbIO = NULL;

  /*   construct key (where clause)    */

  strcpy (szWhere, VC_DBK_CODE);
  strcat (szWhere, "=\'");
  strcat (szWhere, me->DBMain.Compcode);
  strcat (szWhere, "\'");

  /*   load guide record    */

  status=
  vdb$RisSelect (select     = VC_DBS_GD,
                 table_name = VC_DBT_GD,
                 where      = szWhere,
                 numselect  = VC_DBN_GD,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_GD, szWhere);
    goto L_ABORT;
  }

  VCDBstr (me->DBMain.OwnerId,     DbIO[0]);
  VCDBstr (me->DBMain.Timest,      DbIO[1]);
  VCDBstr (me->DBMain.Short_desc,  DbIO[2]);
  VCDBstr (me->DBMain.Standard,    DbIO[3]);
  VCDBstr (me->DBMain.Environment, DbIO[4]);
  VCDBstr (me->DBMain.Fire_resist, DbIO[5]);
  VCDBstr (me->DBMain.Security,    DbIO[6]);
  VCDBstr (me->DBMain.Desc,        DbIO[7]);
  VCDBstr (me->DBMain.Vendor,      DbIO[8]);
  VCDBstr (me->DBMain.Catalog,     DbIO[9]);
  VCDBstr (me->DBMain.Stockno,     DbIO[10]);

  me->DBMain.Weight    = VCDBdbl (DbIO[11]);
  me->DBMain.Unit_Cost = VCDBdbl (DbIO[12]);
  me->DBMain.Gn_data_1 = VCDBdbl (DbIO[13]);
  me->DBMain.Gn_data_2 = VCDBdbl (DbIO[14]);
  me->DBMain.LcUnit    = VCDBint (DbIO[15]);

  VCDBstr (me->DBMain.Insul_type,  DbIO[16]);

  me->DBMain.Insul_thk = VCDBdbl (DbIO[17]);
  me->DBMain.Diameter  = VCDBdbl (DbIO[18]);
  me->DBMain.Bendrad   = VCDBdbl (DbIO[19]);

  me->DBMain.Local     = FALSE;

  VdsRisFreeBuffer (DbIO, NbRow);

  *msg = MSSUCC;

  L_ABORT:
  return (status);
}

end implementation VCDBGuide;

