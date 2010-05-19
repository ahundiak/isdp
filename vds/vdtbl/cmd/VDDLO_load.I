
/* $Id: VDDLO_load.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_load.I
 *
 * Description:
 *
 * Implementation file for drawing layout command load operations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_load.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
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
# Revision 1.7  1995/11/29  13:56:20  pinnacle
# Replaced: ./vdtbl/cmd/VDDLO_load.I for:  by ksundar for vds.240
#
# Revision 1.6  1995/09/25  22:58:28  pinnacle
# Replaced: vdtbl/cmd/VDDLO_load.I for:  by sundar for vds.240
#
# Revision 1.5  1995/09/12  16:51:30  pinnacle
# Replaced: vdtbl/cmd/VDDLO_load.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/09/05  23:17:20  pinnacle
# Replaced: vdtbl/cmd/VDDLO_load.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:04:52  pinnacle
# Replaced: vdtbl/cmd/VDDLO_load.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:59:24  pinnacle
# Replaced: vdtbl/cmd/VDDLO_load.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/05/15  16:20:54  pinnacle
# Replaced: vdtbl/cmd/VDDLO_load.I by hverstee r#
#
# Revision 1.2  1995/05/11  17:06:40  pinnacle
# Replaced: vdtbl/cmd/VDDLO_load.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:06:14  pinnacle
# Created: vdtbl/cmd/VDDLO_load.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdDLO;

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

#include "VDmem.h"

/*
#define  MY_DEBUG
*/



method   VDDLO_load   (IGRlong    *msg;
                struct GRid       *lGrid)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     i;
  IGRshort     n1, n2, n3, n4;
  IGRint       nNeeded;
  IGRint       n1c, n2c, n3c, n4c;
  IGRchar     *pBuff;

  struct  VDdrwlo_db_col  *pCol;
  struct  VDdrwlo_db_htf  *pHtf;
  struct  VDdrwlo_db_fld  *pFld;
  struct  VDdrwlo_db_alg  *pAlg;

  nNeeded = 0;
  pBuff   = NULL;
  *msg    = MSFAIL;

#ifdef MY_DEBUG
  printf (" load layout <%d %d>\n",lGrid->objid,lGrid->osnum);
#endif

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_gtab (&retmsg, &me->Ltbrec),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_gcol
                              (&retmsg, VD_DRWLO_EN_ALL, &n1, NULL),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);
  n1c = n1 * sizeof (struct VDdrwlo_db_col);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_ghtf
                        (&retmsg, VD_DRWLO_EN_ALL, NULL, &n2, NULL),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);
  n2c = n2 * sizeof (struct VDdrwlo_db_htf);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_gfld
                        (&retmsg, VD_DRWLO_EN_ALL, VD_DRWLO_EN_ALL,
                         NULL, VD_DRWLO_EN_ALL, &n3, NULL),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);
  n3c = n3 * sizeof (struct VDdrwlo_db_fld);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_galign
                        (&retmsg, VD_DRWLO_EN_ALL, VD_DRWLO_EN_ALL,
                         &n4, NULL),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);
  n4c = n4 * sizeof (struct VDdrwlo_db_alg);

  if (n1c > nNeeded) nNeeded = n1c;
  if (n2c > nNeeded) nNeeded = n2c;
  if (n3c > nNeeded) nNeeded = n3c;
  if (n4c > nNeeded) nNeeded = n4c;

#ifdef MY_DEBUG
  printf (" LOAD LOCALLY %d %d %d %d\n",n1,n2,n3,n4);
#endif

  pBuff = _MALLOC (nNeeded, IGRchar);
  if (pBuff == NULL) goto quit;

  pCol  = (struct  VDdrwlo_db_col *) pBuff;
  pHtf  = (struct  VDdrwlo_db_htf *) pBuff;
  pFld  = (struct  VDdrwlo_db_fld *) pBuff;
  pAlg  = (struct  VDdrwlo_db_alg *) pBuff;

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_gcol
                                      (&retmsg, VD_DRWLO_EN_ALL, &n1, pCol),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);
  status = om$vla_set_dimension (varray = me->Lcolrec, size = n1);

  for (i=0;i<n1;i++)
    VD_drwlo_mcol (&(me->Lcolrec[i].col_db), &pCol[i]);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_ghtf
                                   (&retmsg, VD_DRWLO_EN_ALL, NULL, &n2, pHtf),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);
  status = om$vla_set_dimension (varray = me->Lhtfrec, size = n2);

  for (i=0;i<n2;i++)
    VD_drwlo_mhtf (&(me->Lhtfrec[i].htf_db), &pHtf[i]);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_gfld
                        (&retmsg, VD_DRWLO_EN_ALL, VD_DRWLO_EN_ALL,
                         NULL, VD_DRWLO_EN_ALL, &n3, pFld),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);
  status = om$vla_set_dimension (varray = me->Lfldrec, size = n3);

  for (i=0;i<n3;i++)
    VD_drwlo_mfld (&(me->Lfldrec[i]), &pFld[i]);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_galign
                        (&retmsg, VD_DRWLO_EN_ALL, VD_DRWLO_EN_ALL,
                         &n4, pAlg),
      targetid = lGrid->objid,
      targetos = lGrid->osnum);
  status = om$vla_set_dimension (varray = me->Lalgrec, size = n4);

  me->nNBalg[0] = me->nNBalg[1] = me->nNBalg[2] = me->nNBalg[3] = 0;

  for (i=0;i<n4;i++)
  {
    IGRshort    nGidx;

    nGidx = pAlg[i].hdtr_type - 1;

    VD_drwlo_malg (&(me->Lalgrec[i]), &pAlg[i]);
#ifdef MY_DEBUG
    printf (" load align tab %d -- %d %d %f\n", i,
                me->Lalgrec[i].hdtr_type, me->Lalgrec[i].aligncode,
                me->Lalgrec[i].value);
#endif

    (me->nNBalg[nGidx])++;
  }

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_set
                            (&retmsg, VD_DRWLO_EN_ALL, NULL),
      targetid = my_id);

  *msg = MSSUCC;

  quit:
  _FREE (pBuff);
  return (status);
}


method   VDDLO_ld_alg       (IGRlong     * msg;
                             IGRshort      hdtr_type)
{
  IGRint          status;
  IGRlong         retmsg;

  status  = OM_S_SUCCESS;
  *msg    = MSFAIL;

#ifdef MY_DEBUG
  printf (" ld_alg types %d %d\n",hdtr_type, me->nAlg_hdtr);
#endif

  if (hdtr_type != me->nAlg_hdtr)
  {
    _FREE (me->pCur_alg);

    me->nAlg_hdtr    = VD_DRWLO_EN_ALL;
    me->nAlg_alloc   = 0;
    me->nAlg_lines   = 0;
    me->pCur_alg     = NULL;
  }

  if ((hdtr_type != VD_DRWLO_EN_ALL) && (hdtr_type != VD_DRWLO_EN_DATA))
  {
    status =
    om$send (msg = message VDdrwlo.VDdrwlo_galign
                                     (&retmsg, hdtr_type, VD_DRWLO_EN_ALL,
                                      &me->nAlg_alloc, NULL),
        targetid = my_id);
#ifdef MY_DEBUG
    printf (" load alloc tab %d, %d alloc\n",hdtr_type, me->nAlg_alloc);
#endif

    /*     add a line for expansion   */

    (me->nAlg_alloc)++;
    me->pCur_alg = _MALLOC (me->nAlg_alloc, struct VDdrwlo_db_alg);
    if (me->pCur_alg == NULL) goto quit;

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_galign
                                     (&retmsg, hdtr_type, VD_DRWLO_EN_ALL,
                                      &me->nAlg_lines, me->pCur_alg),
        targetid = my_id);

#ifdef MY_DEBUG
    printf (" load alloc tab %d, %d lines\n",hdtr_type, me->nAlg_lines);
#endif

    me->nAlg_hdtr = hdtr_type;
  }

  *msg = MSSUCC;

  quit:
  return (status);
}


method  VDDLO_ld_fld (long      * sts;
                      IGRshort    hdtr_type)
{
  IGRint      status;
  IGRlong     retmsg;
  IGRshort    nNeeded;
  IGRint      i, idsp;
  IGRchar     szAdd[6] = "01234";

  struct   VDdrwlo_db_htf *pBuff;

  *sts = MSFAIL;

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_ghtf
                          (&retmsg, VD_DRWLO_EN_ALL, NULL, &nNeeded, NULL),
      targetid = my_id);

  me->nFtotTab = nNeeded;

  nNeeded += 5;

  pBuff = _MALLOC (nNeeded, struct   VDdrwlo_db_htf);
  if (pBuff == NULL) goto quit;

  if (nNeeded > me->nFtotAlloc)
  {
    _FREE (me->pFtotTab);

    me->pFtotTab   = _MALLOC (nNeeded * VD_DRWLO_CHR_IDFLD, IGRchar);
    if (me->pFtotTab == NULL) goto quit;

    me->nFtotAlloc = nNeeded;
  }

  *(me->pFtotTab) = '\0';

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_ghtf
                          (&retmsg, VD_DRWLO_EN_ALL, NULL, &nNeeded, pBuff),
      targetid = my_id);

  for (i=0; i<nNeeded; i++)
  {
    idsp = i * VD_DRWLO_CHR_IDFLD;

    me->pFtotTab[idsp]   = szAdd[pBuff[i].hdtr_type];
    me->pFtotTab[idsp+1] = ':';

    strcpy (&me->pFtotTab[idsp+2], pBuff[i].fieldid);
#ifdef MY_DEBUG
    printf (" load copy fieldlist text %s\n", &me->pFtotTab[idsp]);
#endif
  }

  if ((hdtr_type != VD_DRWLO_EN_ALL) && (hdtr_type != VD_DRWLO_EN_DATA))
  {
    IGRshort   n1Need;

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_ghtf
                                 (&retmsg, hdtr_type, NULL, &nNeeded, pBuff),
        targetid = my_id);

    me->nFldTab = nNeeded;

    n1Need = nNeeded + 5;

    if (n1Need > me->nFldAlloc)
    {
      _FREE (me->pFldTab);

      me->pFldTab   = _MALLOC (n1Need * VD_DRWLO_CHR_IDFLD, IGRchar);
      if (me->pFldTab == NULL) goto quit;

      me->nFldAlloc = n1Need;
    }

    *(me->pFldTab) = '\0';

#ifdef MY_DEBUG
    printf (" load fieldlist tab %d, %d lines\n",hdtr_type, nNeeded);
#endif

    for (i=0; i<nNeeded; i++)
    {
      idsp = i * VD_DRWLO_CHR_IDFLD;

      strcpy (&me->pFldTab[idsp], pBuff[i].fieldid);
#ifdef MY_DEBUG
      printf (" load fieldlist text %s\n", &me->pFldTab[idsp]);
#endif
    }
  }

  *sts = MSSUCC;

  quit:
  _FREE (pBuff);
  return (status);
}


method  VDDLO_set_alist (long             *sts;
                         char             *form_ptr;
                  struct VDdrwlo_ins_htf  *pHLoc)
{
  IGRint    status;
  IGRint    Scroll;
  IGRint    i,ict1,ict2;
  IGRint    inum;
  IGRint    Selflag;
  IGRchar   szfld[6];

  status  = OM_S_SUCCESS;
  Selflag = FALSE;

  /*      column alignment     */

#ifdef MY_DEBUG
  printf ("set alg lists %d %d\n",me->nMax_colnum, me->nAlg_lines);
#endif

  inum = me->nMax_colnum;

  if (inum > 5)    Scroll = 1;
  else             Scroll = 0;

  FIfld_set_list_scroll (form_ptr, VD_DLOH_FLD_ALGL, Scroll, 0);
  FIfld_set_list_scroll (form_ptr, VD_DLOH_FLD_ALGR, Scroll, 0);

  FIfld_set_list_num_rows (form_ptr, VD_DLOH_FLD_ALGL, 0, inum);
  FIfld_set_list_num_rows (form_ptr, VD_DLOH_FLD_ALGR, 0, inum);

  for (i=0; i<inum; i++)
  {
    sprintf (szfld, "%4d", (i+1));

    VDfld_set_list_text (form_ptr, VD_DLOH_FLD_ALGL, i, 0, szfld, Selflag);
    VDfld_set_list_text (form_ptr, VD_DLOH_FLD_ALGR, i, 0, szfld, Selflag);
  }

  /*      offset lines alignment    */

  inum = me->nAlg_lines;

  if (inum > 5)    Scroll = 1;
  else             Scroll = 0;

  ict1 = ict2 = 0;

  FIfld_set_list_scroll (form_ptr, VD_DLOH_FLD_ALGT, Scroll, 0);
  FIfld_set_list_scroll (form_ptr, VD_DLOH_FLD_ALGB, Scroll, 0);
  
  FIfld_set_list_num_rows (form_ptr, VD_DLOH_FLD_ALGT, 0, inum-1);
  FIfld_set_list_num_rows (form_ptr, VD_DLOH_FLD_ALGB, 0, inum-1);

  for (i=0; i<inum; i++)
  {
    sprintf (szfld, "%4d", (i+1));

    if (i != 0)
    {
      VDfld_set_list_text (form_ptr, VD_DLOH_FLD_ALGT, ict1, 0, szfld, Selflag);
      ict1++;
    }
    if (i != (inum-1))
    {
      VDfld_set_list_text (form_ptr, VD_DLOH_FLD_ALGB, ict2, 0, szfld, Selflag);
      ict2++;
    }
  }

  return (status);
}

end implementation VDCmdDLO;

