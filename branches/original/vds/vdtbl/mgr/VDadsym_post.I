
/* $Id: VDadsym_post.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDadsym_post.I
 *
 * Description:
 *
 * Implementation file for ADS manager post to DB method
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDadsym_post.I,v $
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
# Revision 1.7  1996/04/12  19:31:16  pinnacle
# Replaced: vdtbl/mgr/VDadsym_post.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/11/17  22:22:36  pinnacle
# Replaced: vdtbl/mgr/VDadsym_post.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/09/25  23:46:06  pinnacle
# Replaced: vdtbl/mgr/VDadsym_post.I for:  by sundar for vds.240
#
# Revision 1.4  1995/09/05  20:17:30  pinnacle
# Replaced: vdtbl/mgr/VDadsym_post.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/11  19:09:36  pinnacle
# Replaced: vdtbl/mgr/VDadsym_post.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  14:38:54  pinnacle
# Replaced: vdtbl/mgr/VDadsym_post.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/19  19:32:26  pinnacle
# Created: vdtbl/mgr/VDadsym_post.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/12/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDadsym;

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

#define   MY_NUMCOL    (VDADSYM_NUM_REC+1)

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

  if (!(VD_Allow_DBdel (VDADSYM_NAM_TAB, me->SSid_tab.Tabnam))) goto WRAPUP;

  *msg   = MSSUCC;

  /*   delete old version    */

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete sort criterion, name = %s\n\n",
                                       me->SSid_tab.Tabnam);
    fflush  (OutFil);
  }

  strcpy (whout, VDDRWLO_DB_KEY);
  strcat (whout, "=\'");
  strcat (whout, me->SSid_tab.Tabnam);
  strcat (whout, "\'");

  status = vdb$RisDelete (table_name = VDADSYM_NAM_TAB,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete header\n");
    fflush  (OutFil);
  }

  status = vdb$RisDelete (table_name = VDADSYM_NAM_REC,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete sortkey table\n");
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
  IGRint        nNumsrt;

  IGRint        col_typ[MY_NUMCOL];
  IGRint        col_num[MY_NUMCOL];
  IGRint        columns;
  ICHRptr       col_value[MY_NUMCOL];

  FILE *p_file;

  extern int VDSverify_login();
  extern int VdsVerifyRisTable();

  /* Initialization */

  *msg = MSFAIL;
  nNumsrt = om$dimension_of (varray = me->Ladsrec);

  p_file = NULL;

#ifndef MY_DEBUG
  p_file = (FILE *)fopen( "CRsort.log", "w+" );
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

  if (VdsVerifyRisTable(VDADSYM_NAM_TAB) != VDS_DBTABLE_FOUND)
  {
    fprintf (p_file, VD_DRWLO_NODB_MSG);
    goto ABORT;
  }

  /*   delete old version    */

  status =
  om$send (msg = message VDADS.DBdelete (msg, p_file),
      targetid = my_id);

  if (*msg != MSSUCC) goto ABORT;
  if (!(status & OM_S_SUCCESS)) goto ABORT;

  /*      post table header    */

  fprintf (p_file," DB post table layout, name = %s \n\n",me->SSid_tab.Tabnam);
  fflush  (p_file);

  columns       = VDADSYM_NUM_TAB + 1;;
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
              (VDADSYM_NAM_TAB, columns, col_typ, col_num, col_value);
  if (status != SUCCESS) goto ABORT;

  /*      post sortkey table    */

  columns       = VDADSYM_NUM_REC + 1;
  col_typ[0]    = CHAR;
  col_typ[1]    = CHAR;
  col_typ[2]    = CHAR;
  col_typ[3]    = SMALLINT;
  col_typ[4]    = SMALLINT;
  col_typ[5]    = DOUBLE;
  col_typ[6]    = CHAR;
  col_typ[7]    = SMALLINT;
  col_typ[8]    = DOUBLE;
  col_typ[9]    = DOUBLE;
  col_typ[10]   = DOUBLE;
  col_typ[11]   = DOUBLE;
  col_typ[12]   = SMALLINT;
  col_typ[13]   = CHAR;

  col_num[0]    = VD_DRWLO_CHR_IDFLD;
  col_num[1]    = VD_DRWLO_CHR_IDFLD;
  col_num[2]    = VD_DRWLO_CHR_ATTRNAM;
  col_num[3]    = 0;
  col_num[4]    = 0;
  col_num[5]    = 0;
  col_num[6]    = VD_DRWLO_CHR_DESC;
  col_num[7]    = 0;
  col_num[8]    = 0;
  col_num[9]    = 0;
  col_num[10]   = 0;
  col_num[11]   = 0;
  col_num[12]   = 0;
  col_num[13]   = VD_DRWLO_CHR_IDFLD;

  fprintf (p_file," ADS table        %4d entries\n",nNumsrt);
  fflush  (p_file);

  for (iLine=0; iLine<nNumsrt; iLine++)
  {
    col_value[1]  =              me->Ladsrec[iLine].Symbol;
    col_value[2]  =              me->Ladsrec[iLine].szAtt;
    col_value[3]  = (IGRchar *) &me->Ladsrec[iLine].nDattyp;
    col_value[4]  = (IGRchar *) &me->Ladsrec[iLine].nnREL;
    col_value[5]  = (IGRchar *) &me->Ladsrec[iLine].dAttval;
    col_value[6]  =              me->Ladsrec[iLine].szAttval;
    col_value[7]  = (IGRchar *) &me->Ladsrec[iLine].nnSide;
    col_value[8]  = (IGRchar *) &me->Ladsrec[iLine].dOffset;
    col_value[9]  = (IGRchar *) &me->Ladsrec[iLine].dCharhgt;
    col_value[10] = (IGRchar *) &me->Ladsrec[iLine].dCharwdt;
    col_value[11] = (IGRchar *) &me->Ladsrec[iLine].dCharspc;
    col_value[12] = (IGRchar *) &me->Ladsrec[iLine].nCharwgt;
    col_value[13] =              me->Ladsrec[iLine].font;

#ifdef MY_DEBUG
    VD_post_prt (columns, col_typ, col_value);
#endif

    status = VD_post_SqlInsVal
              (VDADSYM_NAM_REC, columns, col_typ, col_num, col_value);
    if (status != SUCCESS) goto ABORT;
  }

  /*   reset my local flag..... */

  me->SSid_tab.Local = FALSE;

  *msg = MSSUCC;
  fprintf (p_file," \n\n ADS Table posted successfully\n");

  ABORT:
  if( p_file != (FILE *)stdout )
   fclose( p_file );

  return (OM_S_SUCCESS);
}

end implementation VDadsym;

