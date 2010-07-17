
/* $Id: VCDBElTi.I,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr/VCDBElTi.I
 *
 * Description:
 *   This file contains the methods and functions used to implement
 *   the Electrical terminal DB cache.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBElTi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/08/11  21:26:22  pinnacle
# Replaced: vcdbattr/VCDBElTi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/07/21  22:51:06  pinnacle
# Replaced: vcdbattr/VCDBElTi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/14  21:43:08  pinnacle
# Replaced: vcdbattr/VCDBElTi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:16:22  pinnacle
# Replaced: vcdbattr/VCDBElTi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/29  22:12:12  pinnacle
# Replaced: vcdbattr/VCDBElTi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:50:34  pinnacle
# Created: vcdbattr/VCDBElTi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCDBElTerm;

#include "VCdbaccess.h"
#include "v_postproto.h"

/*
#define MY_DEBUG
*/

method  VCGetPos  (IGRlong         *msg;
            struct VCpos           *Posdef;
                   IGRshort        *nIndex;
                   IGRshort        *nMAP;
                   IGRshort        *nSig)
{
  IGRshort      nEnt;
  IGRint        i;
  IGRshort      nSub;
  IGRshort      nLin;
  IGRboolean    bPaired;

  *msg    = MSFAIL;

  *nIndex = *nMAP = *nSig = -1;
  nSub = nLin = -1;
  bPaired = TRUE;

  if ((VC_EMPTYSTR(Posdef->Conn.Term.szModId)) &&
      (VC_EMPTYSTR(Posdef->Conn.Term.szPosId)))
  {
    *msg = MSSUCC;
    *nIndex = me->nDEFpin;
    return (OM_S_SUCCESS);
  }

  nEnt    = om$dimension_of (varray = me->Mod);

  for (i=0; i< nEnt; i++)
  {
    if (strcmp (Posdef->Conn.Term.szModId, me->Mod[i].Mod_id) == 0)
    {
      if (strcmp (Posdef->Conn.Term.szPosId, me->Mod[i].Pos_id1) == 0)
      {
        nSub  = 1;
        nLin  = i;
      }
      else
      if (strcmp (Posdef->Conn.Term.szPosId, me->Mod[i].Pos_id2) == 0)
      {
        nSub  = 2;
        nLin  = i;
      }

      if ((VC_EMPTYSTR(me->Mod[i].Pos_id1)) ||
          (VC_EMPTYSTR(me->Mod[i].Pos_id2)))      bPaired = FALSE;
    }
  }

  *nSig = *nMAP = nLin * 10 + nSub;

  if (bPaired)   *nSig = nLin * 10;

  /*  if not found in map do not worry about db, it's wrong anyway  */

  if (*nMAP >= 0)
  {
     nEnt    = om$dimension_of (varray = me->Pin);

     *nIndex = me->nDEFpin;
     *msg  = MSSUCC;

     for (i=0; i< nEnt; i++)
     {
       if ((strcmp (Posdef->Conn.Term.szModId, me->Pin[i].Mod_id) == 0) &&
           (strcmp (Posdef->Conn.Term.szPosId, me->Pin[i].Pos_id) == 0))
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

   nEnt = om$dimension_of (varray = me->Pin);

   if (nIndex == -1) nIndex = me->nDEFpin;

   if ((nIndex >= 0) && (nIndex < nEnt))
   {
      *msg = MSSUCC;

      switch (nAttnum)
      {
        case VC_X_MAX_CONNECT_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Maxconnect;
          break;

        case VC_X_WORK_VOLT_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Work_volt;
          break;

        case VC_X_PEAK_VOLT_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Peak_volt;
          break;

        case VC_X_FREQUENCY_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Frequency;
          break;

        case VC_X_SENSITIVE_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Sensitivity;
          break;

        case VC_X_PWR_MEAN_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Power_mean;
          break;

        case VC_X_PWR_MAX_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Power_max;
          break;

        case VC_X_PWR_STD_DEV_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Power_stddev;
          break;

        case VC_X_SEN_STD_DEV_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Sensi_stddev;
          break;

        case VC_X_RISE_TIME_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Rise_time;
          break;

        case VC_X_PRECISION_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Precision;
          break;

        case VC_X_DT_DATA1_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Dt_data_1;
          break;

        case VC_X_DT_DATA2_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Dt_data_2;
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
      om$send (msg = message VCDBterm.VCGpAnum
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

  me->nDEFpin = 0;

  /*   construct key (where clause)    */

  strcpy (szWhere, VC_DBK_CODE);
  strcat (szWhere, "=\'");
  strcat (szWhere, me->DBMain.Compcode);
  strcat (szWhere, "\'");

#ifdef MY_DEBUG
  printf ("Load elterm %s\n", szWhere);
#endif

  /*   load cable record    */

  status=
  vdb$RisSelect (select     = VC_DBS_ELTERM,
                 table_name = VC_DBT_ELTERM,
                 where      = szWhere,
                 numselect  = VC_DBN_ELTERM,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_ELTERM, szWhere);
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

  /*    load module records    */

  status=
  vdb$RisSelect (select     = VC_DBS_ELMOD,
                 table_name = VC_DBT_ELMOD,
                 where      = szWhere,
                 numselect  = VC_DBN_ELMOD,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_ELMOD, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Mod,
                        size   = NbRow);
#ifdef MY_DEBUG
  printf (" Load modules %d\n",NbRow);
#endif

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VC_DBN_ELMOD;

    VCDBstr (me->Mod[iRow].Mod_id ,      DbIO[iDsp]);
    VCDBstr (me->Mod[iRow].Mod_desc ,    DbIO[iDsp+1]);
    VCDBstr (me->Mod[iRow].Pos_id1 ,     DbIO[iDsp+2]);
    VCDBstr (me->Mod[iRow].Pos_id2 ,     DbIO[iDsp+4]);
    VCDBstr (me->Mod[iRow].Def_signal ,  DbIO[iDsp+6]);

    me->Mod[iRow].Iotype1     = VCDBint (DbIO[iDsp+3]);
    me->Mod[iRow].Iotype2     = VCDBint (DbIO[iDsp+5]);
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  /*    load pin records    */

  status=
  vdb$RisSelect (select     = VC_DBS_ELPIN,
                 table_name = VC_DBT_ELPIN,
                 where      = szWhere,
                 numselect  = VC_DBN_ELPIN,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_ELPIN, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Pin,
                        size   = NbRow);

#ifdef MY_DEBUG
  printf (" Load pins %d\n",NbRow);
#endif

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VC_DBN_ELPIN;

    VCDBstr (me->Pin[iRow].Mod_id , DbIO[iDsp]);
    VCDBstr (me->Pin[iRow].Pos_id , DbIO[iDsp+1]);
    if ((VC_EMPTYSTR(me->Pin[iRow].Mod_id)) &&
        (VC_EMPTYSTR(me->Pin[iRow].Pos_id)))   me->nDEFpin = iRow;

    VCDBstr (me->Pin[iRow].Altdir , DbIO[iDsp+2]);

    me->Pin[iRow].Maxconnect      = VCDBint (DbIO[iDsp+3]);
    me->Pin[iRow].Work_volt       = VCDBdbl (DbIO[iDsp+4]);
    me->Pin[iRow].Peak_volt       = VCDBdbl (DbIO[iDsp+5]);
    me->Pin[iRow].Frequency       = VCDBdbl (DbIO[iDsp+6]);
    me->Pin[iRow].Sensitivity     = VCDBdbl (DbIO[iDsp+7]);
    me->Pin[iRow].Power_mean      = VCDBdbl (DbIO[iDsp+8]);
    me->Pin[iRow].Power_max       = VCDBdbl (DbIO[iDsp+9]);
    me->Pin[iRow].Power_stddev    = VCDBdbl (DbIO[iDsp+10]);
    me->Pin[iRow].Sensi_stddev    = VCDBdbl (DbIO[iDsp+11]);
    me->Pin[iRow].Rise_time       = VCDBdbl (DbIO[iDsp+12]);
    me->Pin[iRow].Precision       = VCDBdbl (DbIO[iDsp+13]);
    me->Pin[iRow].Dt_data_1       = VCDBdbl (DbIO[iDsp+14]);
    me->Pin[iRow].Dt_data_2       = VCDBdbl (DbIO[iDsp+15]);
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  *msg = MSSUCC;

#ifdef MY_DEBUG
  printf (" Load term done\n");
#endif

  L_ABORT:
  return (status);
}

end implementation VCDBElTerm;

