
/* $Id: VDdrwlo_post.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_post.I
 *
 * Description:
 *
 * Implementation file for table manager post to DB method
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_post.I,v $
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
# Revision 1.9  1996/04/12  19:30:28  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_post.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/11/17  22:23:10  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_post.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/05  20:16:22  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_post.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/08/25  15:15:36  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_post.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/07/27  21:52:16  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_post.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/07/26  19:26:40  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_post.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  14:39:40  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_post.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:30:04  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_post.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/05/09  15:12:42  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_post.I by hverstee r#
#
# Revision 1.1  1995/04/11  14:48:14  pinnacle
# Created: vdtbl/mgr/VDdrwlo_post.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/03/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDdrwlo_occ;

#include <ctype.h>
#include <string.h>
#include <stdio.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vdbmacros.h"

#include "VDSpdudef.h"
#include "vdbmacros.h"
#include "VDScheckin.h"
#include "VDScheckdef.h"
#include "VDSris_def.h"
#include "VDSris_siz.h"
#include "VDDbtbldef.h"
#include "vdbmacros.h"

#include "PDUerror.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"
#include "VDdrwlo_pr.h"
#include "VDDbDef.h"

#include "v_postproto.h"

typedef  IGRchar   *  ICHRptr;

#define   MY_NUMCOL     30

/*
#define   MY_DEBUG
*/


method DBdelete  (IGRlong         *msg;
                  FILE            *OutFil)
{
  IGRint         status;
  IGRchar        whout[40];

  *msg   = MSFAIL;
  status = OM_S_SUCCESS;

  if (!(VD_Allow_DBdel (VDDRWLO_NAM_TAB, me->Ltbrec.Tabnam))) goto WRAPUP;

  *msg = MSSUCC;

  /*   delete old version    */

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete table layout, name = %s\n\n",me->Ltbrec.Tabnam);
    fflush  (OutFil);
  }

  strcpy (whout, VDDRWLO_DB_KEY);
  strcat (whout, "=\'");
  strcat (whout, me->Ltbrec.Tabnam);
  strcat (whout, "\'");

  status = vdb$RisDelete (table_name = VDDRWLO_NAM_TAB,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete header\n");
    fflush  (OutFil);
  }

  status = vdb$RisDelete (table_name = VDDRWLO_NAM_ALG,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete alignment tables\n");
    fflush  (OutFil);
  }

  status = vdb$RisDelete (table_name = VDDRWLO_NAM_COL,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete column data\n");
    fflush  (OutFil);
  }

  status = vdb$RisDelete (table_name = VDDRWLO_NAM_HTF,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete header/trailer layout\n");
    fflush  (OutFil);
  }

  status = vdb$RisDelete (table_name = VDDRWLO_NAM_FLD,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete fill fields\n\n\n");
    fflush  (OutFil);
  }

  WRAPUP:
  return (status);
}


method VDPostYourselfToDb( long *msg;
                           char *key;
                           int  to_sql;
                           char *catalog;
                           char *partid;
                           char *revision;
                           char *designRep;
                           int  *delete             )
{
  IGRint        status;
  IGRint        iLine;
  IGRint        nNumhtf;
  IGRint        nNumalg;
  IGRint        nNumcol;
  IGRint        nNumfld;

  IGRint        col_typ[MY_NUMCOL];
  IGRint        col_num[MY_NUMCOL];
  IGRint        columns;
  ICHRptr       col_value[MY_NUMCOL];

  IGRchar     * szSpac = " ";

  FILE *p_file;

  extern int VDSverify_login();
  extern int VdsVerifyRisTable();

  /* Initialization */

  *msg = MSFAIL;

   nNumhtf = om$dimension_of (varray = me->Lhtfrec);
   nNumalg = om$dimension_of (varray = me->Lalgrec);
   nNumcol = om$dimension_of (varray = me->Lcolrec);
   nNumfld = om$dimension_of (varray = me->Lfldrec);

  p_file = NULL;

#ifndef MY_DEBUG
  p_file = (FILE *)fopen( "Drwlo.log", "w+" );
#endif
  if( p_file == NULL )
  {
    p_file = (FILE *)stdout;
  }

  if (VDSverify_login() != PDM_S_SUCCESS)
  {
    fprintf (p_file,"Attempted post of %s, no DB connection\n\n",
                                me->Ltbrec.Tabnam);
    goto ABORT;
  }

  if (VdsVerifyRisTable(VDDRWLO_NAM_TAB) != VDS_DBTABLE_FOUND)
  {
    fprintf (p_file, VD_DRWLO_NODB_MSG);
    goto ABORT;
  }

  /*   delete old version    */

  status =
  om$send (msg = message VDdrwlo.DBdelete (msg, p_file),
      targetid = my_id);

  if (*msg != MSSUCC) goto ABORT;
  if (!(status & OM_S_SUCCESS)) goto ABORT;

  /*      post table header    */

  fprintf (p_file," DB post table layout, name = %s \n\n",me->Ltbrec.Tabnam);
  fflush  (p_file);

  columns       = VDDRWLO_NUM_TAB + 1;
  col_typ[0]    = CHAR;
  col_typ[1]    = CHAR;
  col_typ[2]    = SMALLINT;
  col_typ[3]    = CHAR;
  col_typ[4]    = CHAR;
  col_typ[5]    = CHAR;
  col_typ[6]    = CHAR;
  col_typ[7]    = CHAR;
  col_typ[8]    = SMALLINT;

  col_num[0]    = VD_DRWLO_CHR_IDFLD;
  col_num[1]    = VD_DRWLO_CHR_IDFLD;
  col_num[2]    = 0;
  col_num[3]    = VD_DRWLO_CHR_TSTP;
  col_num[4]    = VD_DRWLO_CHR_IDFLD;
  col_num[5]    = VD_DRWLO_CHR_DESC;
  col_num[6]    = VD_DRWLO_CHR_IDFLD;
  col_num[7]    = VD_DRWLO_CHR_IDFLD;
  col_num[8]    = 0;

  col_value[0]  =              me->Ltbrec.Tabnam;
  col_value[1]  =              me->Ltbrec.Tabtyp;
  col_value[2]  = (IGRchar *) &me->Ltbrec.direct;
  col_value[3]  =              me->Ltbrec.Timest;
  col_value[4]  =              me->Ltbrec.Userid;
  col_value[5]  =              me->Ltbrec.Shdesc;
  col_value[6]  =              me->Ltbrec.SumFil;
  col_value[7]  =              me->Ltbrec.SortFil;
  col_value[8]  = (IGRchar *) &me->Ltbrec.LcUnit;

#ifdef MY_DEBUG
  VD_post_prt (columns, col_typ, col_value);
#endif

  status = VD_post_SqlInsVal
              (VDDRWLO_NAM_TAB, columns, col_typ, col_num, col_value);
  if (status != SUCCESS) goto ABORT;

  /*      post alignment table   */

  columns       = VDDRWLO_NUM_ALG + 1;
  col_typ[0]    = CHAR;
  col_typ[1]    = SMALLINT;
  col_typ[2]    = SMALLINT;
  col_typ[3]    = DOUBLE;

  for (iLine=0; iLine<MY_NUMCOL; iLine++)
    col_num[iLine] = 0;
  col_num[0]    = VD_DRWLO_CHR_IDFLD;

  fprintf (p_file," Alignment table        %4d entries\n",nNumalg);
  fflush  (p_file);

  for (iLine=0; iLine<nNumalg; iLine++)
  {
    col_value[1]  = (IGRchar *) &me->Lalgrec[iLine].hdtr_type;
    col_value[2]  = (IGRchar *) &me->Lalgrec[iLine].aligncode;
    col_value[3]  = (IGRchar *) &me->Lalgrec[iLine].value;

#ifdef MY_DEBUG
    VD_post_prt (columns, col_typ, col_value);
#endif

    status = VD_post_SqlInsVal
                 (VDDRWLO_NAM_ALG, columns, col_typ, col_num, col_value);
    if (status != SUCCESS) goto ABORT;
  }

  /*      post columns table   */

  columns       = VDDRWLO_NUM_COL + 1;
  col_typ[0]    = CHAR;
  col_typ[1]    = SMALLINT;
  col_typ[2]    = SMALLINT;

  col_typ[3]    = DOUBLE;
  col_typ[4]    = DOUBLE;
  col_typ[5]    = DOUBLE;
  col_typ[6]    = DOUBLE;
  col_typ[7]    = DOUBLE;
  col_typ[8]    = DOUBLE;

  col_typ[9]    = SMALLINT;
  col_typ[10]   = SMALLINT;
  col_typ[11]   = SMALLINT;
  col_typ[12]   = SMALLINT;
  col_typ[13]   = SMALLINT;
  col_typ[14]   = SMALLINT;
  col_typ[15]   = SMALLINT;
  col_typ[16]   = SMALLINT;
  col_typ[17]   = SMALLINT;
  col_typ[18]   = SMALLINT;

  fprintf (p_file," Columnar layout        %4d entries\n",nNumcol);
  fflush  (p_file);

  for (iLine=0; iLine<nNumcol; iLine++)
  {
    col_value[1]  = (IGRchar *) &(me->Lcolrec[iLine].col_db.col_seqno);
    col_value[2]  = (IGRchar *) &(me->Lcolrec[iLine].col_db.col_chars);

    col_value[3]  = (IGRchar *) &(me->Lcolrec[iLine].col_db.col_wdt);
    col_value[4]  = (IGRchar *) &(me->Lcolrec[iLine].col_db.col_hgt);
    col_value[5]  = (IGRchar *) &(me->Lcolrec[iLine].col_db.col_charwdt);
    col_value[6]  = (IGRchar *) &(me->Lcolrec[iLine].col_db.col_charspc);
    col_value[7]  = (IGRchar *) &(me->Lcolrec[iLine].col_db.col_charhgt);
    col_value[8]  = (IGRchar *) &(me->Lcolrec[iLine].col_db.col_linspc);

    col_value[9]  = (IGRchar *) &(me->Lcolrec[iLine].col_db.ltop_style);
    col_value[10] = (IGRchar *) &(me->Lcolrec[iLine].col_db.ltop_wgt);
    col_value[11] = (IGRchar *) &(me->Lcolrec[iLine].col_db.lbot_style);
    col_value[12] = (IGRchar *) &(me->Lcolrec[iLine].col_db.lbot_wgt);
    col_value[13] = (IGRchar *) &(me->Lcolrec[iLine].col_db.llft_style);
    col_value[14] = (IGRchar *) &(me->Lcolrec[iLine].col_db.llft_wgt);
    col_value[15] = (IGRchar *) &(me->Lcolrec[iLine].col_db.lrgt_style);
    col_value[16] = (IGRchar *) &(me->Lcolrec[iLine].col_db.lrgt_wgt);

    col_value[17] = (IGRchar *) &(me->Lcolrec[iLine].col_db.tl_br);
    col_value[18] = (IGRchar *) &(me->Lcolrec[iLine].col_db.bl_tr);

#ifdef MY_DEBUG
    VD_post_prt (columns, col_typ, col_value);
#endif

    status = VD_post_SqlInsVal
                 (VDDRWLO_NAM_COL, columns, col_typ, col_num, col_value);
    if (status != SUCCESS) goto ABORT;
  }

  /*      post htf table   */

  columns       = VDDRWLO_NUM_HTF + 1;
  col_typ[0]    = CHAR;
  col_typ[1]    = SMALLINT;
  col_typ[2]    = CHAR;
  col_typ[3]    = SMALLINT;

  col_typ[4]    = DOUBLE;
  col_typ[5]    = DOUBLE;
  col_typ[6]    = DOUBLE;
  col_typ[7]    = DOUBLE;

  col_typ[8]    = SMALLINT;
  col_typ[9]    = SMALLINT;
  col_typ[10]   = SMALLINT;
  col_typ[11]   = SMALLINT;
  col_typ[12]   = SMALLINT;
  col_typ[13]   = SMALLINT;
  col_typ[14]   = SMALLINT;
  col_typ[15]   = SMALLINT;
  col_typ[16]   = SMALLINT;
  col_typ[17]   = SMALLINT;
  col_typ[18]   = SMALLINT;
  col_typ[19]   = SMALLINT;
  col_typ[20]   = SMALLINT;
  col_typ[21]   = SMALLINT;

  col_num[0]    = VD_DRWLO_CHR_IDFLD;
  col_num[2]    = VD_DRWLO_CHR_IDFLD;

  fprintf (p_file," Header/trailer layout  %4d entries\n",nNumhtf);
  fflush  (p_file);

  for (iLine=0; iLine<nNumhtf; iLine++)
  {
    col_value[1]  = (IGRchar *) &me->Lhtfrec[iLine].htf_db.hdtr_type;
    col_value[2]  =              me->Lhtfrec[iLine].htf_db.fieldid;
    col_value[3]  = (IGRchar *) &me->Lhtfrec[iLine].htf_db.fld_chars;

    col_value[4]  = (IGRchar *) &me->Lhtfrec[iLine].htf_db.fld_charwdt;
    col_value[5]  = (IGRchar *) &me->Lhtfrec[iLine].htf_db.fld_charspc;
    col_value[6]  = (IGRchar *) &me->Lhtfrec[iLine].htf_db.fld_charhgt;
    col_value[7]  = (IGRchar *) &me->Lhtfrec[iLine].htf_db.fld_linspc;

    col_value[8]  = (IGRchar *) &me->Lhtfrec[iLine].htf_db.align_lcol;
    col_value[9]  = (IGRchar *) &me->Lhtfrec[iLine].htf_db.align_rcol;
    col_value[10] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.align_top;
    col_value[11] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.align_bot;

    col_value[12] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.ltop_style;
    col_value[13] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.ltop_wgt;
    col_value[14] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.lbot_style;
    col_value[15] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.lbot_wgt;
    col_value[16] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.llft_style;
    col_value[17] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.llft_wgt;
    col_value[18] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.lrgt_style;
    col_value[19] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.lrgt_wgt;

    col_value[20] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.tl_br;
    col_value[21] = (IGRchar *) &me->Lhtfrec[iLine].htf_db.bl_tr;

#ifdef MY_DEBUG
    VD_post_prt (columns, col_typ, col_value);
#endif

    status = VD_post_SqlInsVal
                 (VDDRWLO_NAM_HTF, columns, col_typ, col_num, col_value);
    if (status != SUCCESS) goto ABORT;
  }

  /*      post fieldlines table   */

  columns       = VDDRWLO_NUM_FLD + 1;
  col_typ[0]    = CHAR;
  col_typ[1]    = SMALLINT;
  col_typ[2]    = SMALLINT;
  col_typ[3]    = SMALLINT;
  col_typ[4]    = CHAR;
  col_typ[5]    = SMALLINT;
  col_typ[6]    = SMALLINT;
  col_typ[7]    = SMALLINT;
  col_typ[8]    = SMALLINT;
  col_typ[9]    = SMALLINT;

  col_typ[10]   = CHAR;
  col_typ[11]   = CHAR;

#ifdef VD_DLO_NEW_DB
  col_typ[12]   = CHAR;
#endif

  for (iLine=0; iLine<MY_NUMCOL; iLine++)
    col_num[iLine] = 0;
  col_num[0]    = VD_DRWLO_CHR_IDFLD;
  col_num[4]    = VD_DRWLO_CHR_IDFLD;
  col_num[10]   = VD_DRWLO_CHR_IDFLD;
  col_num[11]   = VD_DRWLO_CHR_DESC;
  col_num[12]   = VD_DRWLO_CHR_TEXT;

  fprintf (p_file," Field fill             %4d entries\n",nNumfld);
  fflush  (p_file);

  for (iLine=0; iLine<nNumfld; iLine++)
  {
    col_value[1]  = (IGRchar *) &me->Lfldrec[iLine].hdtr_type;
    col_value[2]  = (IGRchar *) &me->Lfldrec[iLine].lin_seqno;
    col_value[3]  = (IGRchar *) &me->Lfldrec[iLine].col_seqno;

    if (me->Lfldrec[iLine].hdtr_type == VD_DRWLO_EN_DATA)
      col_value[4]  = szSpac;
    else
      col_value[4]  = me->Lfldrec[iLine].fieldid;

    col_value[5]  = (IGRchar *) &me->Lfldrec[iLine].fieldtype;
    col_value[6]  = (IGRchar *) &me->Lfldrec[iLine].datatype;
    col_value[7]  = (IGRchar *) &me->Lfldrec[iLine].f_decimal;
    col_value[8]  = (IGRchar *) &me->Lfldrec[iLine].justification;

    col_value[9]  = (IGRchar *) &me->Lfldrec[iLine].id_weight;
    col_value[10] =              me->Lfldrec[iLine].id_Font;
    col_value[11] =              me->Lfldrec[iLine].id_name;
    col_value[12] =              me->Lfldrec[iLine].Ftext;

#ifdef MY_DEBUG
    VD_post_prt (columns, col_typ, col_value);
#endif

    status = VD_post_SqlInsVal
                 (VDDRWLO_NAM_FLD, columns, col_typ, col_num, col_value);
    if (status != SUCCESS) goto ABORT;
  }

  /*   reset my local flag..... */

  me->Ltbrec.Local = FALSE;

  *msg = MSSUCC;
  fprintf (p_file," \n\n Table layout posted successfully\n");

  ABORT:
  if( p_file != (FILE *)stdout )
   fclose( p_file );

  return (OM_S_SUCCESS);
}

end implementation VDdrwlo_occ;

