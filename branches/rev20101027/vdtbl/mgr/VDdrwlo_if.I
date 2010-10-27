
/* $Id: VDdrwlo_if.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_if.I
 *
 * Description:
 *
 * Implementation file for table manager internal methods (Private)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_if.I,v $
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
# Revision 1.8  1995/11/17  22:20:42  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/28  21:18:04  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I for:  by rmanem for vds.240
#
# Revision 1.6  1995/09/12  16:48:58  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/25  15:16:44  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/07/26  19:26:14  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  14:37:32  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:27:52  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/05/10  22:07:54  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I by hverstee r#
#
# Revision 1.3  1995/04/28  03:44:14  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I by hverstee r#
#
# Revision 1.2  1995/04/25  22:30:02  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.5  1995/04/11  14:53:32  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I by hverstee r#
#
# Revision 1.4  1995/03/25  15:42:06  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I by hverstee r#
#
# Revision 1.3  1995/03/20  17:26:42  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_if.I by hverstee r#
#
# Revision 1.1  1995/03/06  16:42:30  pinnacle
# Created: vdtbl/mgr/VDdrwlo_if.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            New
 *      09/28/95          rmn           Fixed TR # 179527734
 *					Number of lines per field in
 *					header would not show up correctly
 *
 * -------------------------------------------------------------------*/

class implementation VDdrwlo;

#include <time.h>
#include <sys/types.h>

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
#include "VDmem.h"

#include "v_postproto.h"

extern   double  atof();
extern   int     atoi();

/*
#define   MY_DEBUG
*/



method   VDdrwlo_init   (IGRlong         *msg;
                  struct VDdrwlo_tab     *Tabrec)
{
  IGRint      status;

  *msg = MSSUCC;

  strcpy (me->Ltbrec.Tabnam, Tabrec->Tabnam);
  strcpy (me->Ltbrec.Tabtyp, Tabrec->Tabtyp);

  status = VD_DLO_SetIndx (me->Ltbrec.Userid,
                           me->Ltbrec.Timest,
                          &me->Ltbrec.Local,
                          &me->Ltbrec.LcUnit);
#ifdef MY_DEBUG
  printf (" VDdrwlo_init %s %s\n",me->Ltbrec.Timest,me->Ltbrec.Userid);
#endif

  me->Ltbrec.direct = Tabrec->direct;

  strcpy (me->Ltbrec.Shdesc, Tabrec->Shdesc);
  strcpy (me->Ltbrec.SumFil, Tabrec->SumFil);
  strcpy (me->Ltbrec.SortFil, Tabrec->SortFil);

  /*   (re) initialize variable length arrays   */

  status = om$vla_set_dimension (varray = me->Lcolrec, size = 0);
  status = om$vla_set_dimension (varray = me->Lhtfrec, size = 0);
  status = om$vla_set_dimension (varray = me->Lfldrec, size = 0);

  /*    alignment table is special, initialize with baseline for
        all four groups. Note that database fill will override this,
        so make sure ASCII input contains the equivalent entries        */

  status = om$vla_set_dimension (varray = me->Lalgrec, size = 4);

  me->nNBalg[0] = me->nNBalg[1] = me->nNBalg[2] = me->nNBalg[3] = 1;

  me->Lalgrec[0].hdtr_type = VD_DRWLO_EN_HEADER;
  me->Lalgrec[1].hdtr_type = VD_DRWLO_EN_TRAILER;
  me->Lalgrec[2].hdtr_type = VD_DRWLO_EN_BRKHDR;
  me->Lalgrec[3].hdtr_type = VD_DRWLO_EN_BRKTRLR;

  me->Lalgrec[0].aligncode = me->Lalgrec[1].aligncode =
  me->Lalgrec[2].aligncode = me->Lalgrec[3].aligncode = 1;

  me->Lalgrec[0].value     = me->Lalgrec[1].value     =
  me->Lalgrec[2].value     = me->Lalgrec[3].value     = 0;

  return (OM_S_SUCCESS);
}

method   VDdrwlo_check (IGRlong         *msg;
                        IGRshort        *nError;
                        FILE            *ppFile;
                 struct VDdrwlo_error   *Errtab)
{
  IGRint      status;
  IGRshort    nG, iLoop, iLine;
  IGRshort    nCount;
  IGRshort    nCode;
  IGRshort    MaxCol;
  IGRshort    MaxAlg;
  IGRint      nNumhtf;
  IGRint      nNumalg;
  IGRint      nNumcol;
  IGRint      nNumfld;
  IGRshort   *FldIndic;
  IGRshort    AlgIndic[4];

  *msg    = MSFAIL;
  *nError = 0;

   nNumhtf = om$dimension_of (varray = me->Lhtfrec);
   nNumalg = om$dimension_of (varray = me->Lalgrec);
   nNumcol = om$dimension_of (varray = me->Lcolrec);
   nNumfld = om$dimension_of (varray = me->Lfldrec);
   MaxCol  = nNumcol + 1;

   /*  in case no fieldrecords are present allocate one extra in
       indicatorarray (doesn't hurt, keeps MALLOC from complaining)   */
   FldIndic = _MALLOC ((nNumfld + 1) ,IGRshort);

   if (FldIndic == NULL) return (OM_E_NODYNMEM);

   for (iLoop=0; iLoop<(nNumfld+1); iLoop++)
     FldIndic[iLoop] = 0;

#ifdef MY_DEBUG
   printf ("array sizes %d %d %d %d\n",nNumalg,nNumcol,nNumhtf,nNumfld);
#endif

  /*   make sure at least one alignment record exists per group  */

  for (nG = VD_DRWLO_EN_HEADER; nG <= VD_DRWLO_EN_BRKTRLR; nG++)
  {
    status =
    om$send (msg = message VDdrwlo.VDdrwlo_galign
                              (msg, nG, VD_DRWLO_EN_ALL, &nCount, NULL),
        targetid = my_id);

    AlgIndic[nG-1] = nCount;
    if (nCount == 0)
    {
#ifdef MY_DEBUG
      printf (" insert aligncode in empty group %d\n",nG);
#endif
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_ialign
                              (msg, nG, (IGRdouble) 0.0, &nCode),
          targetid = my_id);

      (AlgIndic[nG-1])++;
    }
  }

  /*    check col records    */
  for (iLoop=0; iLoop<nNumcol; iLoop++)
  {
    for (iLine = 1; iLine <= me->Lcolrec[iLoop].col_lns; iLine++)
    {
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xfld
                       (msg, VD_DRWLO_EN_DATA, (iLoop+1), NULL, iLine, &nCode),
          targetid = my_id);

      if (*msg != MSSUCC)
      {
        if (ppFile != NULL)
        fprintf (ppFile," COLUMN %d line not found %d\n",iLoop+1, iLine);
        (*nError)++;
      }

      if (nCode < 0 || nCode >= nNumfld)
      {
        if (ppFile != NULL)
        fprintf (ppFile," COLUMN %d field index invalid %d\n",iLoop+1, nCode);
        (*nError)++;
      }
      else
        FldIndic[nCode]++;
    }
  }

  /*    check for valid alignment pointers in HTF    */

  for (iLoop=0; iLoop<nNumhtf; iLoop++)
  {
    IGRchar    *CPT;

    nG = me->Lhtfrec[iLoop].htf_db.hdtr_type;
    MaxAlg = AlgIndic[nG-1];
    CPT = me->Lhtfrec[iLoop].htf_db.fieldid;

    if ((me->Lhtfrec[iLoop].htf_db.align_lcol < 1) ||
        (me->Lhtfrec[iLoop].htf_db.align_lcol > MaxCol))
    {
      if (ppFile != NULL)
      fprintf (ppFile," HTF lcol invalid %d %d\n",
                 me->Lhtfrec[iLoop].htf_db.align_lcol, MaxCol);
      (*nError)++;
    }

    if ((me->Lhtfrec[iLoop].htf_db.align_rcol < 1) ||
        (me->Lhtfrec[iLoop].htf_db.align_rcol > MaxCol))
    {
      if (ppFile != NULL)
      fprintf (ppFile," HTF rcol invalid %d %d\n",
                 me->Lhtfrec[iLoop].htf_db.align_rcol, MaxCol);
      (*nError)++;
    }

    if (me->Lhtfrec[iLoop].htf_db.align_rcol < 
        me->Lhtfrec[iLoop].htf_db.align_lcol)
    {
      if (ppFile != NULL)
      fprintf (ppFile," HTF col align invalid %d %d\n",
                 me->Lhtfrec[iLoop].htf_db.align_rcol,
                 me->Lhtfrec[iLoop].htf_db.align_lcol);
      (*nError)++;
    }

    if ((me->Lhtfrec[iLoop].htf_db.align_top < 1) ||
        (me->Lhtfrec[iLoop].htf_db.align_top > MaxAlg))
    {
      if (ppFile != NULL)
      fprintf (ppFile," HTF top invalid %d %d\n",
                 me->Lhtfrec[iLoop].htf_db.align_top, MaxAlg);
      (*nError)++;
    }

    if ((me->Lhtfrec[iLoop].htf_db.align_bot < 1) ||
        (me->Lhtfrec[iLoop].htf_db.align_bot > MaxAlg))
    {
      if (ppFile != NULL)
      fprintf (ppFile," HTF bot invalid %d %d\n",
                 me->Lhtfrec[iLoop].htf_db.align_bot, MaxAlg);
      (*nError)++;
    }

    if (me->Lhtfrec[iLoop].htf_db.align_bot >=
        me->Lhtfrec[iLoop].htf_db.align_top)
    {
      if (ppFile != NULL)
      fprintf (ppFile," HTF ver align invalid %d %d\n",
                 me->Lhtfrec[iLoop].htf_db.align_top,
                 me->Lhtfrec[iLoop].htf_db.align_bot);
      (*nError)++;
    }

    for (iLine = 1; iLine <= me->Lhtfrec[iLoop].htf_lns; iLine++)
    {
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xfld
                       (msg, nG, (IGRshort) -1, CPT, iLine, &nCode),
          targetid = my_id);

      if (*msg != MSSUCC)
      {
        if (ppFile != NULL)
        fprintf (ppFile," HTF %d:%s line not found %d\n",nG,CPT, iLine);
        (*nError)++;
      }

      if (nCode < 0 || nCode >= nNumfld)
      {
        if (ppFile != NULL)
        fprintf (ppFile," HTF %d:%s field index invalid %d\n",nG,CPT, nCode);
        (*nError)++;
      }
      else
        FldIndic[nCode]++;
    }
  }

  for (iLoop=0; iLoop<nNumfld; iLoop++)
  {
    if (FldIndic[iLoop] != 1)
    {
      if (ppFile != NULL)
      fprintf (ppFile," FIELD REFERENCE invalid %d %d\n",
                                 iLoop, FldIndic[iLoop]);
      (*nError)++;
    }
  }

  if (ppFile != NULL)
    fflush (ppFile);

  _FREE (FldIndic);

  return (status);
}


method   VDdrwlo_set    (IGRlong          *msg;
                         IGRshort          nGrptyp;
                  struct VDdrwlo_ins_htf  *Htf_I)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRshort        iLoop;
  IGRshort        i;
  IGRshort        nNumcol;
  IGRshort        nNumhtf;
  IGRshort        nNumfld;
  IGRshort        nCount;

  struct VDdrwlo_db_alg        Alg[4];

  *msg    = MSSUCC;
  status  = OM_S_SUCCESS;
  nNumcol = om$dimension_of (varray = me->Lcolrec);
  nNumfld = om$dimension_of (varray = me->Lfldrec);

  if ((nGrptyp == VD_DRWLO_EN_ALL) || (nGrptyp == VD_DRWLO_EN_DATA))
  {
    IGRdouble     xCur;

    xCur    = 0.0;

    for (iLoop = 0; iLoop < nNumcol; iLoop++)
    {
      me->Lcolrec[iLoop].col_x1 = xCur;

      xCur += me->Lcolrec[iLoop].col_db.col_wdt;
      me->Lcolrec[iLoop].col_x2 = xCur;

      me->Lcolrec[iLoop].col_lns = 0;

      for (i=0; i<nNumfld; i++)
      {

        if (me->Lcolrec[iLoop].col_db.col_seqno ==
            me->Lfldrec[i].col_seqno)
        {
           (me->Lcolrec[iLoop].col_lns)++;
        }
      }
#ifdef MY_DEBUG
      printf (" set column %d lines %d xvals %f %f\n",
                                 me->Lcolrec[iLoop].col_db.col_seqno,
                                 me->Lcolrec[iLoop].col_lns,
                                 me->Lcolrec[iLoop].col_x1,
                                 me->Lcolrec[iLoop].col_x2);
#endif
    }
  }

  if (nGrptyp == VD_DRWLO_EN_DATA) goto DONE;

  if (Htf_I != NULL)
  {
    for (i=0; i<nNumcol; i++)
    {
#ifdef MY_DEBUG
      printf (" column loop %d seqno %d\n",i,me->Lcolrec[i].col_db.col_seqno);
#endif
      if (me->Lcolrec[i].col_db.col_seqno == Htf_I->htf_db.align_lcol)
      {
              Htf_I->htf_x1 = me->Lcolrec[i].col_x1;
#ifdef MY_DEBUG
        printf (" set htf 1, index %d  xval %f \n",i,Htf_I->htf_x1);
#endif
      }

      if (me->Lcolrec[i].col_db.col_seqno == Htf_I->htf_db.align_rcol)
      {
              Htf_I->htf_x2 = me->Lcolrec[i].col_x2;
#ifdef MY_DEBUG
        printf (" set htf 2, index %d  xval %f \n",i,Htf_I->htf_x2);
#endif
      }
    }

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_galign
                                     (&retmsg, Htf_I->htf_db.hdtr_type,
                                      Htf_I->htf_db.align_top, &nCount, Alg),
        targetid = my_id);

    Htf_I->htf_y2 = Alg[0].value;

    status =
    om$send (msg = message VDdrwlo.VDdrwlo_galign
                                     (&retmsg, Htf_I->htf_db.hdtr_type,
                                      Htf_I->htf_db.align_bot, &nCount, Alg),
        targetid = my_id);

    Htf_I->htf_y1  = Alg[0].value;

    Htf_I->htf_lns = 0;

    for (i=0; i<nNumfld; i++)
    {
      if ( (strcmp(Htf_I->htf_db.fieldid, me->Lfldrec[i].fieldid) == 0) &&
			(Htf_I->htf_db.hdtr_type == me->Lfldrec[i].hdtr_type) )
      {
         (Htf_I->htf_lns)++;
      }
    }
  }
  else
  {
    nNumhtf = om$dimension_of (varray = me->Lhtfrec);

    for (iLoop = 0; iLoop < nNumhtf; iLoop++)
    {
      for (i=0; i<nNumcol; i++)
      {
        if (me->Lcolrec[i].col_db.col_seqno ==
            me->Lhtfrec[iLoop].htf_db.align_lcol)
                me->Lhtfrec[iLoop].htf_x1 = me->Lcolrec[i].col_x1;

        if (me->Lcolrec[i].col_db.col_seqno ==
            me->Lhtfrec[iLoop].htf_db.align_rcol)
                me->Lhtfrec[iLoop].htf_x2 = me->Lcolrec[i].col_x2;
      }

#ifdef MY_DEBUG
      printf (" set field column align %d %f %f\n", iLoop,
                        me->Lhtfrec[iLoop].htf_x1,
                        me->Lhtfrec[iLoop].htf_x2);
      printf (" field aligncodes %d %d\n",me->Lhtfrec[iLoop].htf_db.align_top,
                                        me->Lhtfrec[iLoop].htf_db.align_bot);
#endif

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_galign
                          (&retmsg, me->Lhtfrec[iLoop].htf_db.hdtr_type,
                           me->Lhtfrec[iLoop].htf_db.align_top, &nCount, Alg),
          targetid = my_id);

      me->Lhtfrec[iLoop].htf_y2 = Alg[0].value;

      status =
      om$send (msg = message VDdrwlo.VDdrwlo_galign
                          (&retmsg, me->Lhtfrec[iLoop].htf_db.hdtr_type,
                           me->Lhtfrec[iLoop].htf_db.align_bot, &nCount, Alg),
          targetid = my_id);

      me->Lhtfrec[iLoop].htf_y1 = Alg[0].value;

      me->Lhtfrec[iLoop].htf_lns = 0;

      for (i=0; i<nNumfld; i++)
      {

        if( (strcmp(me->Lhtfrec[iLoop].htf_db.fieldid, me->Lfldrec[i].fieldid) 
								== 0) &&
	    (me->Lhtfrec[iLoop].htf_db.hdtr_type == me->Lfldrec[i].hdtr_type ) )
        {
           (me->Lhtfrec[iLoop].htf_lns)++;
        }
      }
#ifdef MY_DEBUG
        printf (" linecount HTF %s %d\n",me->Lhtfrec[iLoop].htf_db.fieldid,
                           me->Lhtfrec[iLoop].htf_lns);
#endif
    }
  }

  DONE:
  return (status);
}

method   VDdrwlo_fill   (IGRlong         *msg)
{
  IGRint         status;
  IGRchar      **DbIO;
  IGRint         NbRow;
  IGRchar        szWhere[60];
  IGRint         iRow;
  IGRint         iDsp;
  IGRint         nCol, iCol, jCol;
  IGRint         igAlg, isAlg, j, jsAlg;
  IGRshort       nError;

  *msg = MSFAIL;
  DbIO = NULL;

#ifdef MY_DEBUG
  printf ("  Load DB\n");
#endif

  /*   construct key (where clause)    */

  strcpy (szWhere, VDDRWLO_DB_KEY);
  strcat (szWhere, "=\'");
  strcat (szWhere, me->Ltbrec.Tabnam);
  strcat (szWhere, "\'");

  /*    load object from DB ........... */
  /*    general table                   */

  status=
  vdb$RisSelect (select     = VDDRWLO_SEL_TAB,
                 table_name = VDDRWLO_NAM_TAB,
                 where      = szWhere,
                 numselect  = VDDRWLO_NUM_TAB,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDDRWLO_NAM_TAB, szWhere);
    goto L_ABORT;
  }

  VD_mv_Iin_Quote (me->Ltbrec.Tabtyp, DbIO[0]);
  me->Ltbrec.direct = atoi (DbIO[1]);

  VD_mv_Iin_Quote (me->Ltbrec.Timest, DbIO[2]);
  VD_mv_Iin_Quote (me->Ltbrec.Userid, DbIO[3]);
  VD_mv_Iin_Quote (me->Ltbrec.Shdesc, DbIO[4]);

  VD_mv_Iin_Quote (me->Ltbrec.SumFil, DbIO[5]);
  VD_mv_Iin_Quote (me->Ltbrec.SortFil, DbIO[6]);

  me->Ltbrec.Local = FALSE;

  VdsRisFreeBuffer (DbIO, NbRow);

  /*    alignment tables            */

  status=
  vdb$RisSelect (select     = VDDRWLO_SEL_ALG,
                 table_name = VDDRWLO_NAM_ALG,
                 where      = szWhere,
                 numselect  = VDDRWLO_NUM_ALG,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDDRWLO_NAM_ALG, szWhere);
    goto L_ABORT;
  }

  me->nNBalg[0] = me->nNBalg[1] = me->nNBalg[2] = me->nNBalg[3] = 0;

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp  = iRow * VDDRWLO_NUM_ALG;
    igAlg = atoi (DbIO[iDsp]);
    isAlg = atoi (DbIO[iDsp+1]);

    if ((igAlg < VD_DRWLO_EN_HEADER) || (igAlg > VD_DRWLO_EN_BRKTRLR))
        return (OM_E_ABORT);

    if (isAlg > me->nNBalg[igAlg-1]) me->nNBalg[igAlg-1] = isAlg;
  }

  isAlg = me->nNBalg[0] + me->nNBalg[1] + me->nNBalg[2] + me->nNBalg[3];

  status =
  om$vla_set_dimension (varray = me->Lalgrec,
                        size   = isAlg);

  j = 0;
  for (isAlg = 0; isAlg < 4; isAlg++)
    for (jsAlg = 0; jsAlg < me->nNBalg[isAlg]; jsAlg++)
    {
      me->Lalgrec[j].hdtr_type = isAlg + 1;
      me->Lalgrec[j].aligncode = jsAlg + 1;

#ifdef  MY_DEBUG
    printf (" set up skeleton %d %d %d\n",j,me->Lalgrec[j].hdtr_type,
                                            me->Lalgrec[j].aligncode);
#endif

      j++;
    }

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VDDRWLO_NUM_ALG;

    igAlg = atoi (DbIO[iDsp]);
    isAlg = atoi (DbIO[iDsp+1]);

    jsAlg = 0;
    for (j=0; j<igAlg-1; j++)
      jsAlg += me->nNBalg[j];

    jsAlg = jsAlg + isAlg - 1;

#ifdef  MY_DEBUG
    printf (" final load align %d %d %d\n",jsAlg,igAlg, isAlg);
#endif

    me->Lalgrec[jsAlg].hdtr_type    = igAlg;
    me->Lalgrec[jsAlg].aligncode    = isAlg;
    me->Lalgrec[jsAlg].value        = atof (DbIO[iDsp+2]);
  }

#ifdef  MY_DEBUG
  isAlg = om$dimension_of (varray = me->Lalgrec);
  for (iRow = 0; iRow < isAlg; iRow++)
    printf (" alignrec %d - %d %d %f\n", iRow,
                    me->Lalgrec[iRow].hdtr_type,
                    me->Lalgrec[iRow].aligncode,
                    me->Lalgrec[iRow].value);
#endif

  VdsRisFreeBuffer (DbIO, NbRow);

  /*       column records       */

  status=
  vdb$RisSelect (select     = VDDRWLO_SEL_COL,
                 table_name = VDDRWLO_NAM_COL,
                 where      = szWhere,
                 numselect  = VDDRWLO_NUM_COL,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDDRWLO_NAM_COL, szWhere);
    goto L_ABORT;
  }

  /* find the largest column number  */
  nCol = 0;
  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iCol = atoi (DbIO[iRow * VDDRWLO_NUM_COL]);

    if (iCol > nCol) nCol = iCol;
  }

  status =
  om$vla_set_dimension (varray = me->Lcolrec,
                        size   = nCol);

  for (iRow = 0; iRow < nCol; iRow++)
    me->Lcolrec[iRow].col_db.col_seqno = iRow + 1;

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VDDRWLO_NUM_COL;
    iCol = atoi (DbIO[iDsp]);
    jCol = iCol - 1;

    me->Lcolrec[jCol].col_db.col_seqno    = iCol;
    me->Lcolrec[jCol].col_db.col_chars    = atoi (DbIO[iDsp+1]);
    me->Lcolrec[jCol].col_db.col_wdt      = atof (DbIO[iDsp+2]);
    me->Lcolrec[jCol].col_db.col_hgt      = atof (DbIO[iDsp+3]);
    me->Lcolrec[jCol].col_db.col_charwdt  = atof (DbIO[iDsp+4]);
    me->Lcolrec[jCol].col_db.col_charspc  = atof (DbIO[iDsp+5]);
    me->Lcolrec[jCol].col_db.col_charhgt  = atof (DbIO[iDsp+6]);
    me->Lcolrec[jCol].col_db.col_linspc   = atof (DbIO[iDsp+7]);

    me->Lcolrec[jCol].col_db.ltop_style   = atoi (DbIO[iDsp+8]);
    me->Lcolrec[jCol].col_db.ltop_wgt     = atoi (DbIO[iDsp+9]);
    me->Lcolrec[jCol].col_db.lbot_style   = atoi (DbIO[iDsp+10]);
    me->Lcolrec[jCol].col_db.lbot_wgt     = atoi (DbIO[iDsp+11]);
    me->Lcolrec[jCol].col_db.llft_style   = atoi (DbIO[iDsp+12]);
    me->Lcolrec[jCol].col_db.llft_wgt     = atoi (DbIO[iDsp+13]);
    me->Lcolrec[jCol].col_db.lrgt_style   = atoi (DbIO[iDsp+14]);
    me->Lcolrec[jCol].col_db.lrgt_wgt     = atoi (DbIO[iDsp+15]);

    me->Lcolrec[jCol].col_db.tl_br        = atoi (DbIO[iDsp+16]);
    me->Lcolrec[jCol].col_db.bl_tr        = atoi (DbIO[iDsp+17]);

#ifdef  MY_DEBUG
    printf (" colrec %d colno %d colsize %f %f\n", jCol,
                me->Lcolrec[jCol].col_db.col_seqno,
                me->Lcolrec[jCol].col_db.col_wdt,
                me->Lcolrec[jCol].col_db.col_hgt);
#endif
  }

#ifdef  MY_DEBUG
  for (iRow = 0; iRow < NbRow; iRow++)
  {
    printf (" colrec %d charvals %f %f %f %f\n", iRow,
                me->Lcolrec[iRow].col_db.col_charwdt,
                me->Lcolrec[iRow].col_db.col_charspc,
                me->Lcolrec[iRow].col_db.col_charhgt,
                me->Lcolrec[iRow].col_db.col_linspc);
  }
#endif

  VdsRisFreeBuffer (DbIO, NbRow);

  /*       header/trailer field records       */

  status=
  vdb$RisSelect (select     = VDDRWLO_SEL_HTF,
                 table_name = VDDRWLO_NAM_HTF,
                 where      = szWhere,
                 numselect  = VDDRWLO_NUM_HTF,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDDRWLO_NAM_HTF, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Lhtfrec,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VDDRWLO_NUM_HTF;

    me->Lhtfrec[iRow].htf_db.hdtr_type    = atoi (DbIO[iDsp]);

    VD_mv_Iin_Quote (me->Lhtfrec[iRow].htf_db.fieldid , DbIO[iDsp+1]);

    me->Lhtfrec[iRow].htf_db.fld_chars    = atoi (DbIO[iDsp+2]);
    me->Lhtfrec[iRow].htf_db.fld_charwdt  = atof (DbIO[iDsp+3]);
    me->Lhtfrec[iRow].htf_db.fld_charspc  = atof (DbIO[iDsp+4]);
    me->Lhtfrec[iRow].htf_db.fld_charhgt  = atof (DbIO[iDsp+5]);
    me->Lhtfrec[iRow].htf_db.fld_linspc   = atof (DbIO[iDsp+6]);

    me->Lhtfrec[iRow].htf_db.align_lcol   = atoi (DbIO[iDsp+7]);
    me->Lhtfrec[iRow].htf_db.align_rcol   = atoi (DbIO[iDsp+8]);
    me->Lhtfrec[iRow].htf_db.align_top    = atoi (DbIO[iDsp+9]);
    me->Lhtfrec[iRow].htf_db.align_bot    = atoi (DbIO[iDsp+10]);

    me->Lhtfrec[iRow].htf_db.ltop_style   = atoi (DbIO[iDsp+11]);
    me->Lhtfrec[iRow].htf_db.ltop_wgt     = atoi (DbIO[iDsp+12]);
    me->Lhtfrec[iRow].htf_db.lbot_style   = atoi (DbIO[iDsp+13]);
    me->Lhtfrec[iRow].htf_db.lbot_wgt     = atoi (DbIO[iDsp+14]);
    me->Lhtfrec[iRow].htf_db.llft_style   = atoi (DbIO[iDsp+15]);
    me->Lhtfrec[iRow].htf_db.llft_wgt     = atoi (DbIO[iDsp+16]);
    me->Lhtfrec[iRow].htf_db.lrgt_style   = atoi (DbIO[iDsp+17]);
    me->Lhtfrec[iRow].htf_db.lrgt_wgt     = atoi (DbIO[iDsp+18]);

    me->Lhtfrec[iRow].htf_db.tl_br        = atoi (DbIO[iDsp+19]);
    me->Lhtfrec[iRow].htf_db.bl_tr        = atoi (DbIO[iDsp+20]);

#ifdef  MY_DEBUG
    printf (" htfrec %d fieldid %s \n", iRow,
                me->Lhtfrec[iRow].htf_db.fieldid);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  /*       FILL field records       */

  status=
  vdb$RisSelect (select     = VDDRWLO_SEL_FLD,
                 table_name = VDDRWLO_NAM_FLD,
                 where      = szWhere,
                 numselect  = VDDRWLO_NUM_FLD,
                 p_numrows  = &NbRow,
                 p_buffer   = &DbIO);

  if (!(status & OM_S_SUCCESS ))
  {
    printf (" Error, Select from <%s> where <%s>\n",
                                          VDDRWLO_NAM_FLD, szWhere);
    goto L_ABORT;
  }

  status =
  om$vla_set_dimension (varray = me->Lfldrec,
                        size   = NbRow);

  for (iRow = 0; iRow < NbRow; iRow++)
  {
    iDsp = iRow * VDDRWLO_NUM_FLD;

    me->Lfldrec[iRow].hdtr_type     = atoi (DbIO[iDsp]);
    me->Lfldrec[iRow].lin_seqno     = atoi (DbIO[iDsp+1]);
    me->Lfldrec[iRow].col_seqno     = atoi (DbIO[iDsp+2]);

    VD_mv_Iin_Quote (me->Lfldrec[iRow].fieldid , DbIO[iDsp+3]);

    me->Lfldrec[iRow].fieldtype     = atoi (DbIO[iDsp+4]);
    me->Lfldrec[iRow].datatype      = atoi (DbIO[iDsp+5]);
    me->Lfldrec[iRow].f_decimal     = atoi (DbIO[iDsp+6]);
    me->Lfldrec[iRow].justification = atoi (DbIO[iDsp+7]);

/* ^^^^^^^^  redo when DB updated    */

#ifdef VD_DLO_NEW_DB
    me->Lfldrec[iRow].id_weight     = atoi (DbIO[iDsp+8]);

    VD_mv_Iin_Quote (me->Lfldrec[iRow].id_Font , DbIO[iDsp+9]);
    VD_mv_Iin_Quote (me->Lfldrec[iRow].id_name , DbIO[iDsp+10]);
    VD_mv_Iin_Quote (me->Lfldrec[iRow].Ftext   , DbIO[iDsp+11]);
#else
    VD_mv_Iin_Quote (me->Lfldrec[iRow].id_Font, VD_DRWLO_TXT_DEFFONT);

    me->Lfldrec[iRow].id_weight     = 0;

    VD_mv_Iin_Quote (me->Lfldrec[iRow].id_name , DbIO[iDsp+9]);
    VD_mv_Iin_Quote (me->Lfldrec[iRow].Ftext   , DbIO[iDsp+10]);
#endif
/* ^^^^^^^^  redo when DB updated    */

#ifdef  MY_DEBUG
    printf (" fldrec %d text %s \n", iRow,
                    me->Lfldrec[iRow].Ftext);
#endif
  }

  VdsRisFreeBuffer (DbIO, NbRow);

  /*     set additional parameters     */

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_set (msg, VD_DRWLO_EN_ALL, NULL),
      targetid = my_id);

  /*     and check for validity   */

/*@@@@@@@*/
#ifdef  MY_DEBUG
  status =
  om$send (msg = message VDdrwlo.VDdrwlo_check (msg, &nError, stdout, NULL),
      targetid = my_id);
#else
  status =
  om$send (msg = message VDdrwlo.VDdrwlo_check (msg, &nError, NULL, NULL),
      targetid = my_id);
#endif
/*@@@@@@@*/

  L_ABORT:
#ifdef  MY_DEBUG
  printf ("fill finished\n");
#endif
  return (status);
}


IGRint  VD_drwlo_getx (IGRshort         nGrptyp,
                struct VDdrwlo_ins_col *pCol,
                struct VDdrwlo_ins_htf *pHtf,
                       IGRdouble       *dX)
{
  IGRdouble      dLlgt;
  IGRdouble      dCle;
  IGRdouble      dAbSpc;
  IGRint         nChar;

  if (nGrptyp == VD_DRWLO_EN_DATA)
  {
    dAbSpc = pCol->col_db.col_charspc * pCol->col_db.col_charwdt;
    nChar  = pCol->col_db.col_chars;

#ifdef VDDLO_CHSP_INC_CHWD
    dLlgt = ((IGRdouble)(nChar)) * dAbSpc;
#else
    dLlgt = ((IGRdouble)(nChar - 1)) * dAbSpc   +
             ((IGRdouble)(nChar)) * pCol->col_db.col_charwdt;
#endif

    dCle = (pCol->col_x2 - pCol->col_x1 - dLlgt) / 2.0;

    dX[0] = pCol->col_x1 + dCle;
    dX[1] = (pCol->col_x1 + pCol->col_x2) / 2.0;
    dX[2] = pCol->col_x2 - dCle;
  }
  else
  {
    dAbSpc = pHtf->htf_db.fld_charspc * pHtf->htf_db.fld_charwdt;
    nChar  = pHtf->htf_db.fld_chars;

#ifdef VDDLO_CHSP_INC_CHWD
    dLlgt = ((IGRdouble)(nChar)) * dAbSpc;
#else
    dLlgt = ((IGRdouble)(nChar - 1)) * dAbSpc   +
             ((IGRdouble)(nChar)) * pHtf->htf_db.fld_charwdt;
#endif

    dCle = (pHtf->htf_x2 - pHtf->htf_x1 - dLlgt) / 2.0;

    dX[0] = pHtf->htf_x1 + dCle;
    dX[1] = (pHtf->htf_x1 + pHtf->htf_x2) / 2.0;
    dX[2] = pHtf->htf_x2 - dCle;

#ifdef MY_DEBUG
    printf ("getx dX %f %f %f\n",dX[0],dX[1],dX[2]);
#endif
  }

  return (OM_S_SUCCESS);
}

IGRint  VD_drwlo_gtty (IGRdouble        dCHGT,
                       IGRdouble        dLSPC,
                       IGRshort         nLIN,
                       IGRdouble        dFHGT,
                       IGRdouble       *dY)
{
  IGRdouble      dThgt;
  IGRdouble      dInc;
  IGRdouble      dLCle;
  IGRdouble      dFCle;
  IGRshort       i;
  IGRdouble      dABSY;

#ifdef VDDLO_LNSP_INC_LNHG
  dLCle = (dLSPC - 1) * dCHGT;
#else
  dLCle = dLSPC * dCHGT;
#endif

  dThgt = dCHGT * nLIN + dLCle * (nLIN - 1);
  dFCle = (dFHGT - dThgt) / 2.0;

  dInc  = dCHGT + dFCle;
  dABSY = dFHGT;

  for (i=0;i<nLIN; i++)
  {
    dABSY -= dInc;
    dY[i] = dABSY;
    dInc  = dLCle + dCHGT;
  }

  return (OM_S_SUCCESS);
}

IGRint  VD_drwlo_gety (IGRshort         nGrptyp,
                struct VDdrwlo_ins_col *pCol,
                struct VDdrwlo_ins_htf *pHtf,
                       IGRshort         nLin,
                       IGRdouble       *dY)
{
  IGRdouble      dLhgt;
  IGRdouble      dInc;
  IGRdouble      dCle;
  IGRshort       i;
  IGRdouble      dAbSpc;

  if (nGrptyp == VD_DRWLO_EN_DATA)
  {
#ifdef MY_DEBUG
    printf (" gety columns %d lines\n",pCol->col_lns);
#endif

    dAbSpc = pCol->col_db.col_linspc * pCol->col_db.col_charhgt;

#ifdef VDDLO_LNSP_INC_LNHG
    dLhgt = ((IGRdouble)(pCol->col_lns)) * dAbSpc;
    dInc  = dAbSpc;
#else
    dLhgt = ((IGRdouble)(pCol->col_lns - 1)) * dAbSpc   +
            ((IGRdouble)(pCol->col_lns)) * pCol->col_db.col_charhgt;
    dInc  = dAbSpc + pCol->col_db.col_charhgt;
#endif
    dCle = (pCol->col_db.col_hgt - dLhgt) / 2.0;

    dY[nLin-1] = dCle;
  }
  else
  {
    dAbSpc = pHtf->htf_db.fld_linspc * pHtf->htf_db.fld_charhgt;

#ifdef VDDLO_LNSP_INC_LNHG
    dInc  = dAbSpc;
    dLhgt = ((IGRdouble)(nLin)) * dAbSpc;
#else
    dInc  = dAbSpc + pHtf->htf_db.fld_charhgt;
    dLhgt = ((IGRdouble)(nLin - 1)) * dAbSpc   +
            ((IGRdouble)(nLin)) * pHtf->htf_db.fld_charhgt;
#endif

    dCle = (pHtf->htf_y2 - pHtf->htf_y1 - dLhgt) / 2.0;

    dY[nLin-1] = dCle + pHtf->htf_y1;;
  }

#ifdef MY_DEBUG
    printf ("gety dInc, dLhgt,dCle %f %f %f\n",dInc, dLhgt,dCle);

    printf ("gety dY start %d -- %f\n",nLin-1,dY[nLin-1]);
#endif

  for (i=(nLin-2) ; i >= 0; i--)
  {
    dY[i] = dY[i+1] + dInc;

#ifdef MY_DEBUG
    printf ("%d %f\n",i,dY[i]);
#endif
  }

  return (OM_S_SUCCESS);
}


void    VD_drwlo_malg (struct VDdrwlo_db_alg  *Aout,
                       struct VDdrwlo_db_alg  *Ain)
{
  Aout->hdtr_type     = Ain->hdtr_type;
  Aout->aligncode     = Ain->aligncode;
  Aout->value         = Ain->value;

  return;
}

void    VD_drwlo_mcol (struct VDdrwlo_db_col  *Cout,
                       struct VDdrwlo_db_col  *Cin)
{
  Cout->col_seqno     = Cin->col_seqno;
  Cout->col_chars     = Cin->col_chars;
  Cout->col_wdt       = Cin->col_wdt;
  Cout->col_hgt       = Cin->col_hgt;
  Cout->col_charwdt   = Cin->col_charwdt;
  Cout->col_charspc   = Cin->col_charspc;
  Cout->col_charhgt   = Cin->col_charhgt;
  Cout->col_linspc    = Cin->col_linspc;

  Cout->ltop_style    = Cin->ltop_style;
  Cout->ltop_wgt      = Cin->ltop_wgt;
  Cout->lbot_style    = Cin->lbot_style;
  Cout->lbot_wgt      = Cin->lbot_wgt;
  Cout->llft_style    = Cin->llft_style;
  Cout->llft_wgt      = Cin->llft_wgt;
  Cout->lrgt_style    = Cin->lrgt_style;
  Cout->lrgt_wgt      = Cin->lrgt_wgt;
  Cout->tl_br         = Cin->tl_br;
  Cout->bl_tr         = Cin->bl_tr;

  return;
}



void    VD_drwlo_mfld (struct VDdrwlo_db_fld  *Fout,
                       struct VDdrwlo_db_fld  *Fin)
{
  IGRint     iCHECK;

  Fout->hdtr_type         = Fin->hdtr_type;
  Fout->lin_seqno         = Fin->lin_seqno;
  Fout->col_seqno         = Fin->col_seqno;
  Fout->fieldtype         = Fin->fieldtype;
  Fout->datatype          = Fin->datatype;
  Fout->f_decimal         = Fin->f_decimal;
  Fout->justification     = Fin->justification;
  Fout->id_weight         = Fin->id_weight;

  iCHECK = strlen (Fin->id_Font);
  if (iCHECK <= VD_DRWLO_CHR_IDFLD)
    strcpy (Fout->id_Font, Fin->id_Font);
  else
  {
    printf ("___reset font %d\n",iCHECK);
    Fout->id_Font[0] = '\0';
  }

  iCHECK = strlen (Fin->fieldid);
  if (iCHECK <= VD_DRWLO_CHR_IDFLD)
    strcpy (Fout->fieldid, Fin->fieldid);
  else
  {
    printf ("___reset fieldid %d\n",iCHECK);
    Fout->fieldid[0] = '\0';
  }

  iCHECK = strlen (Fin->id_name);
  if (iCHECK <= VD_DRWLO_CHR_DESC)
    strcpy (Fout->id_name, Fin->id_name);
  else
  {
    printf ("___reset id_name %d\n",iCHECK);
    Fout->id_name[0] = '\0';
  }

  iCHECK = strlen (Fin->Ftext);
  if (iCHECK <= VD_DRWLO_CHR_TEXT)
    strcpy (Fout->Ftext, Fin->Ftext);
  else
  {
    printf ("___reset Ftext %d\n",iCHECK);
    Fout->Ftext[0] = '\0';
  }

  return;
}

void    VD_drwlo_mhtf (struct VDdrwlo_db_htf  *Hout,
                       struct VDdrwlo_db_htf  *Hin)
{
  IGRint     iCHECK;

  Hout->hdtr_type     = Hin->hdtr_type;
  Hout->fld_chars     = Hin->fld_chars;
  Hout->fld_charwdt   = Hin->fld_charwdt;
  Hout->fld_charspc   = Hin->fld_charspc;
  Hout->fld_charhgt   = Hin->fld_charhgt;
  Hout->fld_linspc    = Hin->fld_linspc;
  Hout->align_lcol    = Hin->align_lcol;
  Hout->align_rcol    = Hin->align_rcol;
  Hout->align_top     = Hin->align_top;
  Hout->align_bot     = Hin->align_bot;
  Hout->ltop_style    = Hin->ltop_style;
  Hout->ltop_wgt      = Hin->ltop_wgt;
  Hout->lbot_style    = Hin->lbot_style;
  Hout->lbot_wgt      = Hin->lbot_wgt;
  Hout->llft_style    = Hin->llft_style;
  Hout->llft_wgt      = Hin->llft_wgt;
  Hout->lrgt_style    = Hin->lrgt_style;
  Hout->lrgt_wgt      = Hin->lrgt_wgt;
  Hout->tl_br         = Hin->tl_br;
  Hout->bl_tr         = Hin->bl_tr;

  iCHECK = strlen (Hin->fieldid);
  if (iCHECK <= VD_DRWLO_CHR_IDFLD)
    strcpy (Hout->fieldid, Hin->fieldid);
  else
  {
    printf ("___reset fieldid %d\n",iCHECK);
    Hout->fieldid[0] = '\0';
  }

  strcpy (Hout->fieldid, Hin->fieldid);

  return;
}


IGRboolean  VD_drwlo_calg (IGRshort         nGrptyp,
                           IGRshort         nAlign,
                    struct VDdrwlo_db_alg  *Alg)
{
  IGRboolean     bRetval1;
  IGRboolean     bRetval2;

  bRetval1 = ((nGrptyp == VD_DRWLO_EN_ALL) ||
              (nGrptyp == Alg->hdtr_type));

  bRetval2 = ((nAlign == VD_DRWLO_EN_ALL) ||
              (nAlign == Alg->aligncode));

  return (bRetval1 && bRetval2);
}

IGRboolean  VD_drwlo_ccol (IGRshort         nColno,
                    struct VDdrwlo_db_col  *Cin)
{
  return ((nColno == Cin->col_seqno) || (nColno == VD_DRWLO_EN_ALL));
}

IGRboolean  VD_drwlo_chtf (IGRshort         nGrptyp,
                           IGRchar         *pFieldid,
                    struct VDdrwlo_db_htf  *Hin)
{
  IGRboolean     bRetval1;
  IGRboolean     bRetval2;

  bRetval1 = ((nGrptyp == VD_DRWLO_EN_ALL) ||
              (nGrptyp == Hin->hdtr_type));

  if (pFieldid == NULL)
    bRetval2 = TRUE;
  else
    bRetval2 = (strcmp(pFieldid, Hin->fieldid) == 0);

  return (bRetval1 && bRetval2);
}

IGRboolean  VD_drwlo_cfld (IGRshort         nGrptyp,
                           IGRshort         nColno,
                           IGRchar         *pFieldid,
                           IGRshort         nLinseq,
                    struct VDdrwlo_db_fld  *Fin)
{
  IGRboolean     bRetval1;
  IGRboolean     bRetval2;
  IGRboolean     bRetval3;

  bRetval1 = ((nGrptyp == VD_DRWLO_EN_ALL) ||
              (nGrptyp == Fin->hdtr_type));

  if (Fin->hdtr_type == VD_DRWLO_EN_DATA)
  {
    bRetval2 = ((nColno == Fin->col_seqno) || (nColno == VD_DRWLO_EN_ALL));
  }
  else
  {
    if (pFieldid == NULL)
      bRetval2 = TRUE;
    else
      bRetval2 = (strcmp(pFieldid, Fin->fieldid) == 0);
  }

  bRetval3 = ((nLinseq == VD_DRWLO_EN_ALL) ||
              (nLinseq == Fin->lin_seqno));

  return (bRetval1 && bRetval2 && bRetval3);
}

end implementation VDdrwlo;

