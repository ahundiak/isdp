
/* $Id: VDcrsum_post.I,v 1.2 2001/10/12 14:38:20 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrsum_post.I
 *
 * Description:
 *
 * Implementation file for sort criteria manager post to DB method
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrsum_post.I,v $
 *      Revision 1.2  2001/10/12 14:38:20  ylong
 *      *** empty log message ***
 *
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
# Revision 1.6  1996/04/12  19:30:58  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_post.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/11/17  22:22:58  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_post.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/09/05  20:16:44  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_post.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/25  15:16:00  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_post.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  19:30:30  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_post.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/05/09  15:13:18  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_post.I by hverstee r#
#
# Revision 1.1  1995/04/25  22:23:52  pinnacle
# Created: vdtbl/mgr/VDcrsum_post.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/17/95          HV            New
 *	10/12/01	ylong		TR4377
 * -------------------------------------------------------------------*/

class implementation VDcrsum;

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

#define   MY_NUMCOL     10

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

  if (!(VD_Allow_DBdel (VDCRSUM_NAM_TAB, me->SSid_tab.Tabnam))) goto WRAPUP;

  *msg   = MSSUCC;

  /*   delete old version    */

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete summarization criterion, name = %s\n\n",
                                       me->SSid_tab.Tabnam);
    fflush  (OutFil);
  }

  strcpy (whout, VDDRWLO_DB_KEY);
  strcat (whout, "=\'");
  strcat (whout, me->SSid_tab.Tabnam);
  strcat (whout, "\'");

  status = vdb$RisDelete (table_name = VDCRSUM_NAM_TAB,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete header\n");
    fflush  (OutFil);
  }

  status = vdb$RisDelete (table_name = VDCRSUM_NAM_QTY,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete summarization quantities table\n");
    fflush  (OutFil);
  }

  status = vdb$RisDelete (table_name = VDCRSUM_NAM_MTC,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete summarization match table\n");
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
  IGRint        nNumqty;
  IGRint        nNummtc;

  IGRint        col_typ[MY_NUMCOL];
  IGRint        col_num[MY_NUMCOL];
  IGRint        columns;
  ICHRptr       col_value[MY_NUMCOL];

  FILE *p_file;

  extern int VDSverify_login();
  extern int VdsVerifyRisTable();

  /* Initialization */

  *msg = MSFAIL;

  nNumqty = om$dimension_of (varray = me->Lsqtyrec);
  nNummtc = om$dimension_of (varray = me->Lsmtcrec);

  p_file = NULL;

#ifndef MY_DEBUG
  p_file = (FILE *)fopen( "CRsumm.log", "w+" );
#endif
  if( p_file == NULL )
  {
    p_file = (FILE *)stdout;
  }

  if (VDSverify_login() != PDM_S_SUCCESS)
  {
    fprintf (p_file,"Attempted post of %s, no DB connection\n\n",
                                me->SSid_tab.Tabnam);
    goto ABORT;
  }

  if (VdsVerifyRisTable(VDCRSUM_NAM_TAB) != VDS_DBTABLE_FOUND)
  {
    fprintf (p_file, VD_DRWLO_NODB_MSG);
    goto ABORT;
  }

  /*   delete old version    */

  status =
  om$send (msg = message VDSSC.DBdelete (msg, p_file),
      targetid = my_id);

  if (*msg != MSSUCC) goto ABORT;
  if (!(status & OM_S_SUCCESS)) goto ABORT;

  /*      post table header    */

  fprintf (p_file," DB post summarization table, name = %s \n\n",
                                     me->SSid_tab.Tabnam);
  fflush  (p_file);

  columns       = VDCRSUM_NUM_TAB + 1;
  col_typ[0]    = CHAR;
  col_typ[1]    = CHAR;
  col_typ[2]    = CHAR;
  col_typ[3]    = CHAR;
  col_typ[4]    = SMALLINT;

  col_num[0]    = VD_DRWLO_CHR_IDFLD;
  col_num[1]    = VD_DRWLO_CHR_TSTP;
  col_num[2]    = VD_DRWLO_CHR_IDFLD;
  col_num[3]    = VD_DRWLO_CHR_DESC;
  col_num[4]    = 0;

  col_value[0]  = me->SSid_tab.Tabnam;
  col_value[1]  = me->SSid_tab.Timest;
  col_value[2]  = me->SSid_tab.Userid;
  col_value[3]  = me->SSid_tab.Shdesc;
  col_value[4]  = (IGRchar *) &me->SSid_tab.LcUnit;

#ifdef MY_DEBUG
  VD_post_prt (columns, col_typ, col_value);
#endif

  status = VD_post_SqlInsVal
              (VDCRSUM_NAM_TAB, columns, col_typ, col_num, col_value);
  if (status != SUCCESS) goto ABORT;

  /*      post summarization quantities table    */

  columns       = VDCRSUM_NUM_QTY + 1;
  col_typ[0]    = CHAR;
  col_typ[1]    = CHAR;
  col_typ[2]    = CHAR;
  col_typ[3]    = SMALLINT;
  col_typ[4]    = CHAR;

  col_num[0]    = VD_DRWLO_CHR_IDFLD;
  col_num[1]    = VD_DRWLO_CHR_IDFLD;
  col_num[2]    = VD_DRWLO_CHR_IDFLD;
  col_num[3]    = 0;
  col_num[4]    = VD_DRWLO_CHR_DESC;

  fprintf (p_file," Quantities table        %4d entries\n",nNumqty);
  fflush  (p_file);

  for (iLine=0; iLine<nNumqty; iLine++)
  {
    col_value[1]  =              me->Lsqtyrec[iLine].szCat;
    col_value[2]  =              me->Lsqtyrec[iLine].szSub;
    col_value[3]  = (IGRchar *) &me->Lsqtyrec[iLine].nSflag;
    col_value[4]  =              me->Lsqtyrec[iLine].szExp;

#ifdef MY_DEBUG
    VD_post_prt (columns, col_typ, col_value);
#endif

    status = VD_post_SqlInsVal
              (VDCRSUM_NAM_QTY, columns, col_typ, col_num, col_value);
    if (status != SUCCESS) goto ABORT;
  }

  /*      post summarization match table    */

  columns       = VDCRSUM_NUM_MTC + 1;
  col_typ[0]    = CHAR;
  col_typ[1]    = CHAR;
  col_typ[2]    = CHAR;
  col_typ[3]    = SMALLINT;
  col_typ[4]    = CHAR;
  col_typ[5]    = SMALLINT;
  col_typ[6]    = SMALLINT;
  col_typ[7]    = CHAR;

  col_num[0]    = VD_DRWLO_CHR_IDFLD;
  col_num[1]    = VD_DRWLO_CHR_IDFLD;
  col_num[2]    = VD_DRWLO_CHR_IDFLD;
  col_num[3]    = 0;
  col_num[4]    = VD_DRWLO_CHR_ATTRNAM;
  col_num[5]    = 0;
  col_num[6]    = 0;
  col_num[7]    = VD_DRWLO_CHR_DESC;

  fprintf (p_file," Match records table     %4d entries\n",nNummtc);
  fflush  (p_file);

  for (iLine=0; iLine<nNummtc; iLine++)
  {
    col_value[1]  =              me->Lsmtcrec[iLine].szCat;
    col_value[2]  =              me->Lsmtcrec[iLine].szSub;
    col_value[3]  = (IGRchar *) &me->Lsmtcrec[iLine].nsIndex;
    col_value[4]  =              me->Lsmtcrec[iLine].szAtt;
    col_value[5]  = (IGRchar *) &me->Lsmtcrec[iLine].nnREL;
    col_value[6]  = (IGRchar *) &me->Lsmtcrec[iLine].nDattyp;
    col_value[7]  =              me->Lsmtcrec[iLine].szExp;

#ifdef MY_DEBUG
    VD_post_prt (columns, col_typ, col_value);
#endif

    status = VD_post_SqlInsVal
              (VDCRSUM_NAM_MTC, columns, col_typ, col_num, col_value);
    if (status != SUCCESS) goto ABORT;
  }

  /*   reset my local flag..... */

  me->SSid_tab.Local = FALSE;

  *msg = MSSUCC;
  fprintf (p_file," \n\n Summarization Tables posted successfully\n");

  ABORT:
  if( p_file != (FILE *)stdout )
   fclose( p_file );

  return (OM_S_SUCCESS);
}

end implementation VDcrsum;

