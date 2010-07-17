
/* $Id: VCDBFoTi.I,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr/VCDBFoTi.I
 *
 * Description:
 *   This file contains the methods and functions used to implement
 *   the fiberoptic terminal DB cache.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBFoTi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/08/11  21:26:10  pinnacle
# Replaced: vcdbattr/VCDBFoTi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/07/21  22:51:20  pinnacle
# Replaced: vcdbattr/VCDBFoTi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/14  21:43:30  pinnacle
# Replaced: vcdbattr/VCDBFoTi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:17:14  pinnacle
# Replaced: vcdbattr/VCDBFoTi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/29  22:12:30  pinnacle
# Replaced: vcdbattr/VCDBFoTi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:51:36  pinnacle
# Created: vcdbattr/VCDBFoTi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCDBFoTerm;

#include "VCdbaccess.h"
#include "v_postproto.h"


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
        case VC_X_CON_MATCH_AN:
          res->type = text_type;
          strcpy (res->var.text_st.text_string, me->Pin[nIndex].Con_match);
          break;

        case VC_X_BANDWIDTH_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Bandwidth;
          break;

        case VC_X_SPECTRAL_W_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Spectral_w;
          break;

        case VC_X_LAMBDA_C_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Lambda_c;
          break;

        case VC_X_ANG_DIST_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->Pin[nIndex].Ang_dist;
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

  /*   load cable record    */

  status=
  vdb$RisSelect (select     = VC_DBS_FOTERM,
                 table_name = VC_DBT_FOTERM,
                 where      = szWhere,
                 numselect  = VC_DBN_FOTERM,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_FOTERM, szWhere);
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
  vdb$RisSelect (select     = VC_DBS_FOMOD,
                 table_name = VC_DBT_FOMOD,
                 where      = szWhere,
                 numselect  = VC_DBN_FOMOD,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_FOMOD, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Mod,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VC_DBN_FOMOD;

    VCDBstr (me->Mod[iRow].Mod_id ,      DbIO[iDsp]);
    VCDBstr (me->Mod[iRow].Mod_desc ,    DbIO[iDsp+1]);
    VCDBstr (me->Mod[iRow].Pos_id1 ,     DbIO[iDsp+3]);
    VCDBstr (me->Mod[iRow].Pos_id2 ,     DbIO[iDsp+5]);
    VCDBstr (me->Mod[iRow].Def_signal ,  DbIO[iDsp+7]);

    me->Mod[iRow].ConnecPAR   = VCDBint (DbIO[iDsp+2]);
    me->Mod[iRow].Iotype1     = VCDBint (DbIO[iDsp+4]);
    me->Mod[iRow].Iotype2     = VCDBint (DbIO[iDsp+6]);
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  /*    load pin records    */

  status=
  vdb$RisSelect (select     = VC_DBS_FOPIN,
                 table_name = VC_DBT_FOPIN,
                 where      = szWhere,
                 numselect  = VC_DBN_FOPIN,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_FOPIN, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Pin,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VC_DBN_FOPIN;

    VCDBstr (me->Pin[iRow].Mod_id ,    DbIO[iDsp]);
    VCDBstr (me->Pin[iRow].Pos_id ,    DbIO[iDsp+1]);
    if ((VC_EMPTYSTR(me->Pin[iRow].Mod_id)) &&
        (VC_EMPTYSTR(me->Pin[iRow].Pos_id)))   me->nDEFpin = iRow;

    VCDBstr (me->Pin[iRow].Con_match , DbIO[iDsp+2]);

    me->Pin[iRow].Bandwidth       = VCDBdbl (DbIO[iDsp+3]);
    me->Pin[iRow].Spectral_w      = VCDBdbl (DbIO[iDsp+4]);
    me->Pin[iRow].Lambda_c        = VCDBdbl (DbIO[iDsp+5]);
    me->Pin[iRow].Ang_dist        = VCDBdbl (DbIO[iDsp+6]);
    me->Pin[iRow].Sensitivity     = VCDBdbl (DbIO[iDsp+7]);
    me->Pin[iRow].Power_mean      = VCDBdbl (DbIO[iDsp+8]);
    me->Pin[iRow].Power_max       = VCDBdbl (DbIO[iDsp+9]);
    me->Pin[iRow].Power_stddev    = VCDBdbl (DbIO[iDsp+10]);
    me->Pin[iRow].Sensi_stddev    = VCDBdbl (DbIO[iDsp+11]);
    me->Pin[iRow].Rise_time       = VCDBdbl (DbIO[iDsp+12]);
    me->Pin[iRow].Dt_data_1       = VCDBdbl (DbIO[iDsp+13]);
    me->Pin[iRow].Dt_data_2       = VCDBdbl (DbIO[iDsp+14]);
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  *msg = MSSUCC;

  L_ABORT:
  return (status);
}

end implementation VCDBFoTerm;

