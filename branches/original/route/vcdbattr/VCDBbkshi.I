
/* $Id: VCDBbkshi.I,v 1.2 2001/05/30 16:58:59 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr / VCDBbkshi.I
 *
 * Description:
 *   This file contains the methods and functions used in the basic
 *   VCDBbksh class
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBbkshi.I,v $
 *        Revision 1.2  2001/05/30 16:58:59  anand
 *        No TR. bend_rad for backshell.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/07/21  22:51:34  pinnacle
# Replaced: vcdbattr/VCDBbkshi.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/14  21:45:52  pinnacle
# Created: vcdbattr/VCDBbkshi.I by hverstee for cabling
#
 *
 * History:
 *      05/29/96        hv	Initial
 *	05/30/01	Anand	No TR. Backshell was being queried for the
 *				bend_rad attribute, which has no relevance to
 *				it. It was returning a junk value, that caused
 *				overflows elsewhere. Kluged to return a zero.
 *
 *************************************************************************/

class implementation VCDBbksh;

#include "VCdbaccess.h"
#include "v_postproto.h"
#include "vrdbgmacros.h"


method  VCGpAnum  (IGRlong         *msg;
                   IGRshort         nIndex;
                   IGRshort         nMAP;
                   IGRint           nAttnum;
            struct ret_struct      *res)
{
  SetProc(VCDBbksh-VCGpAnum); Begin

  if (nAttnum == VC_X_MACRO_NAME_AN)
  {
    *msg = MSSUCC;

    res->type = text_type;
    strcpy (res->var.text_st.text_string, me->DBMain.Macro_name);
  }
  else if (nAttnum == VC_X_BEND_RAD_DB)
  {
    *msg = MSSUCC;

    __DBGpr_com(" Entered bend radius kluge");
    res->type = double_type;
    res->var.root_pm_st.value = 0.0;
  }
  else
  {
    IGRint     status;

    status =
    om$send (msg = message VCDBgen.VCGpAnum
                                     (msg, nIndex, nMAP, nAttnum, res),
            mode = OM_e_wrt_message,
        targetid = my_id);
  }

  End
  return (OM_S_SUCCESS);
}

method VCDB_init (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  IGRint     status;

  status =
  om$send (msg = message VCDBgen.VCDB_init (msg, Tabrec),
          mode = OM_e_wrt_message,
      targetid = my_id);

  strcpy (me->DBMain.Macro_name,  Tabrec->Macro_name);

  return (OM_S_SUCCESS);
}

method VCDB_ghdr (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  IGRint     status;

  status =
  om$send (msg = message VCDBgen.VCDB_ghdr (msg, Tabrec),
          mode = OM_e_wrt_message,
      targetid = my_id);

  strcpy (Tabrec->Macro_name, me->DBMain.Macro_name);

  return (OM_S_SUCCESS);
}


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

  /*   load backshell record    */

  status=
  vdb$RisSelect (select     = VC_DBS_BK,
                 table_name = VC_DBT_BK,
                 where      = szWhere,
                 numselect  = VC_DBN_BK,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_BK, szWhere);
    goto L_ABORT;
  }

  VCDBstr (me->DBMain.OwnerId,     DbIO[0]);
  VCDBstr (me->DBMain.Timest,      DbIO[1]);
  VCDBstr (me->DBMain.Macro_name,  DbIO[2]);
  VCDBstr (me->DBMain.Short_desc,  DbIO[3]);
  VCDBstr (me->DBMain.Standard,    DbIO[4]);
  VCDBstr (me->DBMain.Environment, DbIO[5]);
  VCDBstr (me->DBMain.Fire_resist, DbIO[6]);
  VCDBstr (me->DBMain.Security,    DbIO[7]);
  VCDBstr (me->DBMain.Desc,        DbIO[8]);
  VCDBstr (me->DBMain.Vendor,      DbIO[9]);
  VCDBstr (me->DBMain.Catalog,     DbIO[10]);
  VCDBstr (me->DBMain.Stockno,     DbIO[11]);

  me->DBMain.Weight    = VCDBdbl (DbIO[12]);
  me->DBMain.Unit_Cost = VCDBdbl (DbIO[13]);
  me->DBMain.Gn_data_1 = VCDBdbl (DbIO[14]);
  me->DBMain.Gn_data_2 = VCDBdbl (DbIO[15]);
  me->DBMain.LcUnit    = VCDBint (DbIO[16]);

  me->DBMain.Local     = FALSE;

  VdsRisFreeBuffer (DbIO, NbRow);

  *msg = MSSUCC;

  L_ABORT:
  return (status);
}

end implementation VCDBbksh;

