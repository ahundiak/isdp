
/* $Id: VCDBElCi.I,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr/VCDBElCi.I
 *
 * Description:
 *   This file contains the methods and functions used to implement
 *   the Electrical cable DB cache.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBElCi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1998/12/09  09:57:14  pinnacle
# Replaced: vcdbattr/VCDBElCi.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.7  1997/08/11  21:26:38  pinnacle
# Replaced: vcdbattr/VCDBElCi.I for:  by hverstee for cabling
#
# Revision 1.6  1997/08/05  22:56:26  pinnacle
# Replaced: vcdbattr/VCDBElCi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/07/28  22:25:00  pinnacle
# Replaced: vcdbattr/VCDBElCi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/14  21:42:58  pinnacle
# Replaced: vcdbattr/VCDBElCi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:16:06  pinnacle
# Replaced: vcdbattr/VCDBElCi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/29  22:11:48  pinnacle
# Replaced: vcdbattr/VCDBElCi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:50:00  pinnacle
# Created: vcdbattr/VCDBElCi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *        12/09/98        Reddy      Code list is ordered by conductor n	 *                                   umber - CR179801133
 *
 *************************************************************************/

class implementation VCDBElCab;

#include "VCdbaccess.h"
#include "VCproto.h"
#include "v_postproto.h"

method  VCGetPos  (IGRlong         *msg;
            struct VCpos           *Posdef;
                   IGRshort        *nIndex;
                   IGRshort        *nMAP;
                   IGRshort        *nSig)
{
  IGRshort    nEnt;
  IGRshort    i;

  *msg = MSFAIL;

  *nIndex = *nMAP = *nSig = -1;

  if (VC_EMPTYSTR(Posdef->Conn.Cable.szLeadId))
  {
    *msg = MSSUCC;
    *nIndex = me->nDEFlead;
    return (OM_S_SUCCESS);
  }

  nEnt    = om$dimension_of (varray = me->Map);

  for (i=0; i< nEnt; i++)
  {
    if (strcmp (Posdef->Conn.Cable.szLeadId, me->Map[i].Con_name) == 0)
    {
      *nMAP = i;
      *nSig = i;
      break;
    }
  }

  /*  if not found in map do not worry about db, it's wrong anyway  */

  if (*nMAP >= 0)
  {
    nEnt = om$dimension_of (varray = me->ElCon);

    *nIndex = me->nDEFlead;
    *msg  = MSSUCC;

    for (i=0; i<nEnt; i++)
    {
      if (strcmp (Posdef->Conn.Cable.szLeadId, me->ElCon[i].Con_name) == 0)
      {
        *nIndex = i;
        break;
      }
    }
  }

  return (OM_S_SUCCESS);
}


method  VCGpAnum (IGRlong         *msg;
                  IGRshort         nIndex;
                  IGRshort         nMAP;
                  IGRint           nAttnum;
           struct ret_struct      *res)
{
   IGRshort      nEnt;
   IGRint        status;

   *msg = MSFAIL;
   nEnt = om$dimension_of (varray = me->ElCon);

   if (nIndex == -1) nIndex = me->nDEFlead;

   if ((nIndex >= 0) && (nIndex < nEnt))
   {
      *msg = MSSUCC;

      switch (nAttnum)
      {
        case VC_X_CLAD_DIAM_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Clad_dia;
          break;

/*      duplicate name with main ....

        case VC_X_DIAMETER_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Diameter;
          break;
*/

        case VC_X_SECT_CONDUCT_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Sect_con;
          break;

        case VC_X_VOLTAGE_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Voltage;
          break;

        case VC_X_CURRENT_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Current;
          break;

        case VC_X_RESIST_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Resistance;
          break;

        case VC_X_MODAL_BW_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Modal_bw;
          break;

        case VC_X_RESIS_MSR_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Res_meas_wl;
          break;

        case VC_X_LN_SC_FAC_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Len_sc_fac;
          break;

        case VC_X_SENSITIVE_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Sensitivity;
          break;

        case VC_X_DT_DATA1_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Dt_data_1;
          break;

        case VC_X_DT_DATA2_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->ElCon[nIndex].Dt_data_2;
          break;

        case VC_X_CON_MAT_AN:
          res->type = text_type;
          strcpy (res->var.text_st.text_string, me->ElCon[nIndex].Con_matl);
          break;

        default:
          *msg = MSFAIL;
          break;
      }
   }

   /*    find in master   */

   if (*msg == MSFAIL)
   {
      status =
      om$send (msg = message VCDBcable.VCGpAnum
                                  (msg, nIndex, nMAP, nAttnum, res),
              mode = OM_e_wrt_message,
          targetid = my_id);
   }

  return (OM_S_SUCCESS);
}

method  VCDB_fill (IGRlong      *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRchar        szWhere[60];
  IGRint         iRow;
  IGRint         iDsp;

  *msg = MSFAIL;
  DbIO = NULL;

  me->nDEFlead = 0;

  /*   construct key (where clause)    */

  strcpy (szWhere, VC_DBK_CODE);
  strcat (szWhere, "=\'");
  strcat (szWhere, me->DBMain.Compcode);
  strcat (szWhere, "\'");

  /*   load cable record    */

  status=
  vdb$RisSelect (select     = VC_DBS_ELCAB,
                 table_name = VC_DBT_ELCAB,
                 where      = szWhere,
                 numselect  = VC_DBN_ELCAB,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_ELCAB, szWhere);
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
  VCDBstr (me->DBMain.Insertblk,   DbIO[11]);
  VCDBstr (me->DBMain.Tubecode,    DbIO[12]);

  me->DBMain.Lug_size  = VCDBdbl (DbIO[13]);
  me->DBMain.Weight    = VCDBdbl (DbIO[14]);
  me->DBMain.Unit_Cost = VCDBdbl (DbIO[15]);
  me->DBMain.Gn_data_1 = VCDBdbl (DbIO[16]);
  me->DBMain.Gn_data_2 = VCDBdbl (DbIO[17]);
  me->DBMain.LcUnit    = VCDBint (DbIO[18]);

  VCDBstr (me->DBMain.Insul_type,  DbIO[19]);

  me->DBMain.Insul_thk = VCDBdbl (DbIO[20]);
  me->DBMain.Diameter  = VCDBdbl (DbIO[21]);
  me->DBMain.Bendrad   = VCDBdbl (DbIO[22]);

  me->DBMain.Local     = FALSE;

  VdsRisFreeBuffer (DbIO, NbRow);

  /*    load map records          */
  /****   Code list is ordered by conductor number(con_num) -CR179801133*/

  status=
  vdb$RisSelect (select     = VC_DBS_ELMAP,
                 table_name = VC_DBT_ELMAP,
                 where      = szWhere,
		 order      = "con_num",
                 numselect  = VC_DBN_ELMAP,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_ELMAP, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Map,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VC_DBN_ELMAP;

    me->Map[iRow].Con_number     = VCDBint (DbIO[iDsp]);

    VCDBstr (me->Map[iRow].Con_name ,    DbIO[iDsp+1]);
    VCDBstr (me->Map[iRow].Def_signal,   DbIO[iDsp+2]);
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  /*    load conductor records    */

  status=
  vdb$RisSelect (select     = VC_DBS_ELCND,
                 table_name = VC_DBT_ELCND,
                 where      = szWhere,
                 numselect  = VC_DBN_ELCND,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_ELCND, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->ElCon,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VC_DBN_ELCND;

    VCDBstr (me->ElCon[iRow].Con_name ,   DbIO[iDsp]);
    if (VC_EMPTYSTR(me->ElCon[iRow].Con_name)) me->nDEFlead = iRow;

    VCDBstr (me->ElCon[iRow].Con_matl ,   DbIO[iDsp+1]);

    me->ElCon[iRow].Diameter     = VCDBdbl (DbIO[iDsp+2]);
    me->ElCon[iRow].Clad_dia     = VCDBdbl (DbIO[iDsp+3]);
    me->ElCon[iRow].Sect_con     = VCDBdbl (DbIO[iDsp+4]);
    me->ElCon[iRow].Voltage      = VCDBdbl (DbIO[iDsp+5]);
    me->ElCon[iRow].Current      = VCDBdbl (DbIO[iDsp+6]);
    me->ElCon[iRow].Resistance   = VCDBdbl (DbIO[iDsp+7]);
    me->ElCon[iRow].Modal_bw     = VCDBdbl (DbIO[iDsp+8]);
    me->ElCon[iRow].Len_sc_fac   = VCDBdbl (DbIO[iDsp+9]);
    me->ElCon[iRow].Res_meas_wl  = VCDBdbl (DbIO[iDsp+10]);
    me->ElCon[iRow].Sensitivity  = VCDBdbl (DbIO[iDsp+11]);
    me->ElCon[iRow].Amp_60_40    = VCDBdbl (DbIO[iDsp+12]);
    me->ElCon[iRow].Amp_60_50    = VCDBdbl (DbIO[iDsp+13]);
    me->ElCon[iRow].Amp_400_40   = VCDBdbl (DbIO[iDsp+14]);
    me->ElCon[iRow].Amp_400_50   = VCDBdbl (DbIO[iDsp+15]);
    me->ElCon[iRow].Dt_data_1    = VCDBdbl (DbIO[iDsp+16]);
    me->ElCon[iRow].Dt_data_2    = VCDBdbl (DbIO[iDsp+17]);
  }

  *msg = MSSUCC;

  L_ABORT:
  return (status);
}

end implementation VCDBElCab;

