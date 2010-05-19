
/* $Id: VDSSC_load.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDSSC_load.I
 *
 * Description:
 *
 * Implementation file for criterion edit/review load operations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_load.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/01/05  22:17:24  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.6  1998/01/09  21:29:50  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by mdong for vds
#
# Revision 1.5  1997/12/11  15:15:40  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by mdong for vds
#
# Revision 1.4  1997/12/03  18:22:52  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by mdong for vds
#
# Revision 1.3  1997/12/03  16:27:26  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by mdong for vds
#
# Revision 1.2  1997/11/11  02:40:30  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1995/11/29  13:57:12  pinnacle
# Replaced: ./vdtbl/cmd/VDSSC_load.I for:  by ksundar for vds.240
#
# Revision 1.7  1995/09/25  23:01:36  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by sundar for vds.240
#
# Revision 1.6  1995/09/05  23:18:10  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/11  23:37:40  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/04  14:40:16  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:22:44  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.5  1995/05/15  16:16:16  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I by hverstee r#
#
# Revision 1.3  1995/05/11  16:59:38  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I by hverstee r#
#
# Revision 1.2  1995/05/08  20:33:16  pinnacle
# Replaced: vdtbl/cmd/VDSSC_load.I by hverstee r#
#
# Revision 1.1  1995/04/29  17:02:42  pinnacle
# Created: vdtbl/cmd/VDSSC_load.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdSSC;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include "ASmatrix.h"

#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"

#include "VDdrwlo_pr.h"
#include "VDcompmacros.h"

#include "VDmem.h"
#include "vdtblmacros.h"
#include "v_dbgmacros.h"

/*
#define  MY_DEBUG
*/

from VDcrexp               import VDcrexp_gdata;
from VDcrexp               import VDcrexp_gtab;



method   VDSSC_load   (IGRlong    *msg;
                struct GRid       *lGrid)
{
  IGRint       		status;
  IGRlong      		retmsg;
  IGRint       		i, NbExpDat, index = 0;
  struct VDdrwexp_tab	SSID_exp;
  struct VDdrwexp_data	*expdata;

  *msg        = MSSUCC;

  me->nMaxSrt = 0;
  me->nMaxQty = 0;
  me->nMaxMtc = 0;
  expdata     = NULL;

  __DBGpr_obj( "ID of expression loaded", *lGrid );

  if ((me->My_Type == VD_CMD_SRT_EDIT) ||
      (me->My_Type == VD_CMD_SRT_REV))
  {  /*    load sort records    */

    status =
    om$send (msg = message VDSSC.VDSSC_gtab (&retmsg, &me->SSid_tab),
        targetid = lGrid->objid,
        targetos = lGrid->osnum);

    status =
    om$send (msg = message VDSSC.VDSSC_gsort
                         (&retmsg, VD_DRWLO_EN_ALL, &me->nMaxSrt, NULL),
        targetid = lGrid->objid,
        targetos = lGrid->osnum);
#ifdef MY_DEBUG
    printf ("in load, found %d sortrecords\n",me->nMaxSrt);
#endif

    status =
    om$vla_set_dimension (varray = me->Lsortrec,
                          size   = me->nMaxSrt);

    status =
    om$send (msg = message VDSSC.VDSSC_gsort
                         (&retmsg, VD_DRWLO_EN_ALL, &me->nMaxSrt, me->Lsortrec),
        targetid = lGrid->objid,
        targetos = lGrid->osnum);

    if (me->nMaxSrt > 0) me->nCurSrt = 1;
#ifdef MY_DEBUG
    printf ("loaded %d sortrecords\n",me->nMaxSrt);
#endif
  }
  else if( (me->My_Type == VD_CMD_SUM_EDIT) ||
      (me->My_Type == VD_CMD_SUM_REV) )
  {  /*    load quantity records    */

    status =
    om$send (msg = message VDSSC.VDSSC_gtab (&retmsg, &me->SSid_tab),
        targetid = lGrid->objid,
        targetos = lGrid->osnum);

    status =
    om$send (msg = message VDSSC.VDSSC_gsqty
                        (&retmsg, NULL, NULL, &me->nMaxQty, NULL),
        targetid = lGrid->objid,
        targetos = lGrid->osnum);

    status =
    om$vla_set_dimension (varray = me->Lsqtyrec,
                          size   = me->nMaxQty);

    status =
    om$send (msg = message VDSSC.VDSSC_gsqty
                        (&retmsg, NULL, NULL, &me->nMaxQty, me->Lsqtyrec),
        targetid = lGrid->objid,
        targetos = lGrid->osnum);

    if (me->nMaxQty > 0) me->nCurQty = 1;
#ifdef MY_DEBUG
    printf ("loaded %d qtyrecords\n",me->nMaxQty);
#endif

    /*    load match records    */

    status =
    om$send (msg = message VDSSC.VDSSC_gsmtc
                        (&retmsg, NULL, NULL, VD_DRWLO_EN_ALL,
                         &me->nMaxMtc, NULL),
        targetid = lGrid->objid,
        targetos = lGrid->osnum);

    status =
    om$vla_set_dimension (varray = me->Lsmtcrec,
                          size   = me->nMaxMtc);

    status =
    om$send (msg = message VDSSC.VDSSC_gsmtc
                        (&retmsg, NULL, NULL, VD_DRWLO_EN_ALL,
                         &me->nMaxMtc, me->Lsmtcrec),
        targetid = lGrid->objid,
        targetos = lGrid->osnum);

    if (me->nMaxMtc > 0) me->nCurMtc = 1;
#ifdef MY_DEBUG
    printf ("loaded %d matchrecords\n",me->nMaxMtc);
    {
      int ii;
      for (ii=0; ii<me->nMaxMtc; ii++)
        printf (" mrec %s %s %d\n",me->Lsmtcrec[ii].szCat,
                                   me->Lsmtcrec[ii].szSub,
                                   me->Lsmtcrec[ii].nsIndex);
    }
#endif

    if (me->My_Type == VD_CMD_SUM_REV)
    {
      status =
      om$send (msg = message VDCmdSSC.VDSSC_ld_cat (msg),
          targetid = my_id); 
    }

    /*   load current list of subcategories   */

    if (*msg == MSSUCC)
    {
      status =
      om$send (msg = message VDCmdSSC.VDSSC_ld_sub (msg),
        targetid = my_id); 
    }
  }
  else if( (me->My_Type == VD_CMD_EXP_EDIT) ||
           (me->My_Type == VD_CMD_EXP_REV) )
  {
  /*
  **    Load expression data records.
  */

    status =
    om$vla_set_dimension( varray = me->Lexpdata, size = 0 );

    NbExpDat = 0;
    status =
    om$send( msg      = message VDcrexp.VDcrexp_gtab(&retmsg,
                                                     &SSID_exp,
                                                     &NbExpDat,
                                                     NULL),
             targetid = lGrid->objid,
             targetos = lGrid->osnum );

    strcpy( me->SSid_exp.Timest, SSID_exp.Timest );
    strcpy( me->SSid_exp.Userid, SSID_exp.Userid );
    strcpy( me->SSid_exp.Shdesc, SSID_exp.Shdesc );
    me->SSid_exp.data_type = SSID_exp.data_type;
    me->SSid_exp.LcUnit    = SSID_exp.LcUnit;
    me->SSid_exp.Local     = SSID_exp.Local;

    status =
    om$send( msg = message VDcrexp.VDcrexp_gdata(&retmsg,
                                                 (IGRint *)&me->nExprData,
                                                 &expdata),
             targetid = lGrid->objid,
             targetos = lGrid->osnum );
    __DBGpr_int( "No. of data records loaded", me->nExprData );
    if( me->nExprData > 0 )
    {
      __DBGpr_str( "Name of expression loaded", expdata[0].Datnam );
      __DBGpr_str( "Group of expression loaded", expdata[0].Datgrp );
      __DBGpr_str( "Data records loaded", expdata[0].Datinfo );
    }

    status =
    om$vla_set_dimension( varray = me->Lexpdata, size = me->nExprData ); 

    for( i = 0 ; i < me->nExprData ; ++i )
    {
      index = expdata[i].Datsegn;
      strcpy( me->Lexpdata[index].Datnam, expdata[i].Datnam );
      strcpy( me->Lexpdata[index].Datgrp, expdata[i].Datgrp );
      strcpy( me->Lexpdata[index].Datinfo, expdata[i].Datinfo );
      me->Lexpdata[index].Datsegn = expdata[i].Datsegn;
    }

    _FREE( expdata );
  }
  
  return (OM_S_SUCCESS);
}



method   VDSSC_ld_sub (IGRlong    *msg)

{
  IGRshort      i, idsp;
  IGRshort      nSneed;
  char         *form_ptr;
  int           Selflag;
  int           iSub;
  int           iIN;

  *msg     = MSFAIL;
  Selflag  = FALSE;

  iIN    = om$dimension_of (varray = me->Lsqtyrec);
  nSneed = iIN + 1;

  if (nSneed > me->nMaxSbC)
  {
    _FREE (me->pSbC);
    me->nMaxSbC = nSneed + 5;
    me->pSbC    = _MALLOC (me->nMaxSbC * VD_DRWLO_CHR_IDFLD, IGRchar);
    if (me->pSbC == NULL) goto quit;
  }

  iSub = 0;
  *msg = MSSUCC;

  for (i=0; i<iIN; i++)
  {
    if (strcmp (me->CUR_catnam, me->Lsqtyrec[i].szCat) != 0) continue;

    idsp = iSub * VD_DRWLO_CHR_IDFLD;

    strcpy (&me->pSbC[idsp], me->Lsqtyrec[i].szSub);
    iSub++;
  }

  me->nNumSbC = iSub;

  form_ptr = me->forms[me->My_actv_form].form_ptr;

  FIfld_set_list_num_rows (form_ptr, VD_CRSUM_FLD_SUBCAT, 0, (int)me->nNumSbC);

  if (me->nNumSbC > 10)
    FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_SUBCAT, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_SUBCAT, 0, 0);

  for (i=0; i<me->nNumSbC; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;

    VDfld_set_list_text (form_ptr, VD_CRSUM_FLD_SUBCAT, i, 0,
                                   &me->pSbC[idsp], Selflag);
  }

  quit:
  return (OM_S_SUCCESS);
}

method   VDSSC_ld_cat (IGRlong    *msg)

{
  int       status;
  int       Num;
  int       NumFnd;
  int       i, j, idsp;
  int       Selflag;
  char     *form_ptr;

  *msg    = MSFAIL;
  Selflag = FALSE;

  _FREE (me->pCat);

  Num      = 0;
  NumFnd   = 0;

  if (me->My_Type == VD_CMD_SUM_EDIT)
  {  /*    edit, load full categories list    */
    status =
    VD_compGetCompNames (VD_CRSUM_STL_CAT, &NumFnd, &(me->pCat));
  }
  else
  {  /*   review, load only list of used categories  */
    Num = om$dimension_of (varray = me->Lsqtyrec);

    if (Num > 0)
    {
      me->pCat = _MALLOC (VD_CRSUM_STL_CAT * Num, IGRchar);
      if (me->pCat == NULL) goto quit;

      strcpy (&(me->pCat[0]), me->Lsqtyrec[0].szCat);
      NumFnd = 1;

      for (i=1; i<Num; i++)
      {
        for (j=0; j<NumFnd; j++)
        {
          idsp = j * VD_CRSUM_STL_CAT;

          if (strcmp (&(me->pCat[idsp]), me->Lsqtyrec[i].szCat) ==0)
                 goto BYPASS;
        }

        idsp = NumFnd * VD_CRSUM_STL_CAT;
        strcpy (&(me->pCat[idsp]), me->Lsqtyrec[i].szCat);
        NumFnd++;

        BYPASS:;
      }
    }
  }

  *msg    = MSSUCC;

  form_ptr = me->forms[me->My_actv_form].form_ptr;

  me->nNumCat = NumFnd;

  FIfld_set_list_num_rows (form_ptr, VD_CRSUM_FLD_CAT, 0, (int)me->nNumCat);

  if (me->nNumCat > 10)
    FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_CAT, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_CRSUM_FLD_CAT, 0, 0);

  for (i=0; i<me->nNumCat; i++)
  {
    idsp = i * VD_CRSUM_STL_CAT;

    VDfld_set_list_text (form_ptr, VD_CRSUM_FLD_CAT, i, 0,
                                   &me->pCat[idsp], Selflag);
  }

  quit:
  return (OM_S_SUCCESS);
}

end implementation VDCmdSSC;

