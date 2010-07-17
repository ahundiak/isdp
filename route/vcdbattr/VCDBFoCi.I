
/* $Id: VCDBFoCi.I,v 1.2 2002/05/17 19:23:35 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr/VCDBFoCi.I
 *
 * Description:
 *   This file contains the methods and functions used to implement
 *   the Fiberoptic cable DB cache.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBFoCi.I,v $
 *        Revision 1.2  2002/05/17 19:23:35  anand
 *        Misc. bug fixes. Covers change rejects CR 5846 and 6040.
 *        Ensures that new sub-cables carry over signals of parent
 *        cables.
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.4  1999/02/12  22:30:02  pinnacle
# Replaced: vcdbattr/VCDBFoCi.I for:  by lawaddel for route
#
# Revision 1.3  1998/12/11  05:22:06  pinnacle
# Replaced: vcdbattr/VCDBFoCi.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/08/11  21:26:52  pinnacle
# Replaced: vcdbattr/VCDBFoCi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/08/05  22:56:42  pinnacle
# Replaced: vcdbattr/VCDBFoCi.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/14  21:43:18  pinnacle
# Replaced: vcdbattr/VCDBFoCi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:16:42  pinnacle
# Replaced: vcdbattr/VCDBFoCi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/29  22:11:28  pinnacle
# Replaced: vcdbattr/VCDBFoCi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:51:06  pinnacle
# Created: vcdbattr/VCDBFoCi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *        12/09/98        Reddy      Code list is ordered by conductor 
 *                                   number - CR179801133
 *        02/12/99        law        TR179802033-errors in posting splices
 *        05/15/02	  Anand	     Uncommented the above fix (which involved
 *        			     commenting out lines) for CR 5846&6040.
 *************************************************************************/

class implementation VCDBFoCab;

#include "VCdbaccess.h"
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
/*       *nIndex = i;    Added for TR179802033 */
      break;
    }
  }

  /*  if not found in map do not worry about db, it's wrong anyway  */

  /****** Begin Deleted for TR179802033- Wrong table - ????? */
  if (*nMAP >= 0)
  {
    nEnt = om$dimension_of (varray = me->FoCon);
    *nIndex = me->nDEFlead;
    *msg  = MSSUCC;
    for (i=0; i<nEnt; i++)
    {
      if (strcmp (Posdef->Conn.Cable.szLeadId, me->FoCon[i].Con_name) == 0)
      {
        *nIndex = i;
        break;
      }
    }
  }
  /****** End Deleted for TR179802033- Wrong table - ????? */
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

   status = OM_S_SUCCESS;

   *msg = MSFAIL;

   nEnt = om$dimension_of (varray = me->FoCon);

   if (nIndex == -1) nIndex = me->nDEFlead;

   if ((nIndex >= 0) && (nIndex < nEnt))
   {
      *msg = MSSUCC;

      switch (nAttnum)
      {
        case VC_X_CON_MATCH_AN:
          res->type = text_type;
          strcpy (res->var.text_st.text_string, me->FoCon[nIndex].Con_match);
          break;

        case VC_X_CLAD_DIAM_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Clad_dia;
          break;

/*      duplicate name with main ....

        case VC_X_DIAMETER_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Diameter;
          break;

*/

        case VC_X_MODAL_BW_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Modal_bw;
          break;

        case VC_X_NUM_APER_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Num_aper;
          break;

        case VC_X_CHROM_DISP_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Chrom_disp;
          break;

        case VC_X_ZERO_DISP_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Zero_disp;
          break;

        case VC_X_ATTENUATION_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Attenuation;
          break;

        case VC_X_ATT_MEAS_WL_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Att_meas_wl;
          break;

        case VC_X_LMT_PH_SP_ATT_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Lim_space_att;
          break;

        case VC_X_HO_MOD_LOSS_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].High_order_loss;
          break;

        case VC_X_LN_SC_FAC_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Len_sc_fac;
          break;

        case VC_X_SENSITIVE_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Sensitivity;
          break;

        case VC_X_DT_DATA1_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Dt_data_1;
          break;

        case VC_X_DT_DATA2_DB:
          res->type = double_type;
          res->var.root_pm_st.value = me->FoCon[nIndex].Dt_data_2;
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
  vdb$RisSelect (select     = VC_DBS_FOCAB,
                 table_name = VC_DBT_FOCAB,
                 where      = szWhere,
                 numselect  = VC_DBN_FOCAB,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_FOCAB, szWhere);
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

/*  Code list is ordered by conductor number(con_num) -CR179801133 */
  status=
  vdb$RisSelect (select     = VC_DBS_FOMAP,
                 table_name = VC_DBT_FOMAP,
                 where      = szWhere,
		 order      = "con_num",
                 numselect  = VC_DBN_FOMAP,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_FOMAP, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Map,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VC_DBN_FOMAP;

    me->Map[iRow].Con_number     = VCDBint (DbIO[iDsp]);

    VCDBstr (me->Map[iRow].Con_name ,    DbIO[iDsp+1]);
    VCDBstr (me->Map[iRow].Def_signal,   DbIO[iDsp+2]);
  }

  VdsRisFreeBuffer (DbIO, NbRow);


  /*    load conductor records    */

  status=
  vdb$RisSelect (select     = VC_DBS_FOCND,
                 table_name = VC_DBT_FOCND,
                 where      = szWhere,
                 numselect  = VC_DBN_FOCND,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n", VC_DBT_FOCND, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->FoCon,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VC_DBN_FOCND;

    VCDBstr (me->FoCon[iRow].Con_name ,   DbIO[iDsp]);
    if (VC_EMPTYSTR(me->FoCon[iRow].Con_name)) me->nDEFlead = iRow;

    VCDBstr (me->FoCon[iRow].Con_match ,  DbIO[iDsp+1]);

    me->FoCon[iRow].Diameter        = VCDBdbl (DbIO[iDsp+2]);
    me->FoCon[iRow].Clad_dia        = VCDBdbl (DbIO[iDsp+3]);
    me->FoCon[iRow].Modal_bw        = VCDBdbl (DbIO[iDsp+4]);

    me->FoCon[iRow].Num_aper        = VCDBdbl (DbIO[iDsp+5]);
    me->FoCon[iRow].Chrom_disp      = VCDBdbl (DbIO[iDsp+6]);
    me->FoCon[iRow].Zero_disp       = VCDBdbl (DbIO[iDsp+7]);
    me->FoCon[iRow].Attenuation     = VCDBdbl (DbIO[iDsp+8]);
    me->FoCon[iRow].Att_meas_wl     = VCDBdbl (DbIO[iDsp+9]);
    me->FoCon[iRow].Lim_space_att   = VCDBdbl (DbIO[iDsp+10]);
    me->FoCon[iRow].High_order_loss = VCDBdbl (DbIO[iDsp+11]);

    me->FoCon[iRow].Len_sc_fac      = VCDBdbl (DbIO[iDsp+12]);
    me->FoCon[iRow].Sensitivity     = VCDBdbl (DbIO[iDsp+13]);
    me->FoCon[iRow].Dt_data_1       = VCDBdbl (DbIO[iDsp+14]);
    me->FoCon[iRow].Dt_data_2       = VCDBdbl (DbIO[iDsp+15]);
  }

  VdsRisFreeBuffer (DbIO, NbRow);
  *msg = MSSUCC;

  L_ABORT:
  return (status);
}

end implementation VCDBFoCab;

