
/* $Id: VDcrexp_post.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrexp_post.I
 *
 * Description:
 *
 * Implementation file for expression criteria manager post to DB method
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrexp_post.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/10/21  04:02:10  pinnacle
# Created: vdtbl/mgr/VDcrexp_post.I by ksundar for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      10/10/97        Sundar          Creation Date
 *
 * -------------------------------------------------------------------*/

class implementation VDcrexp;

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

// #define vdsDEBUG        1
#include "v_dbgmacros.h"

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

  SetProc( VDcrexp.DBdelete ); Begin
  *msg   = MSFAIL;
  status = OM_S_SUCCESS;

  if (!(VD_Allow_DBdel(VDCREXP_NAM_TAB, me->Expid_tab.Tabnam))) goto WRAPUP;

  *msg   = MSSUCC;

  /*   delete old version    */

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete expression criterion, name = %s\n\n",
                                       me->Expid_tab.Tabnam);
    fflush  (OutFil);
  }

  strcpy (whout, VDDRWLO_DB_KEY);
  strcat (whout, "=\'");
  strcat (whout, me->Expid_tab.Tabnam);
  strcat (whout, "\'");

  status = vdb$RisDelete (table_name = VDCREXP_NAM_TAB,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete header\n");
    fflush  (OutFil);
  }

  strcpy (whout, VDDRWLO_DB_KEY);
  strcat (whout, "=\'");
  strcat (whout, me->Expid_tab.Tabnam);
  strcat (whout, "\'");

  status = vdb$RisDelete (table_name = VDCREXP_NAM_DAT,
                          where      = whout);
  if (!(status & OM_S_SUCCESS)) goto WRAPUP;

  if (OutFil != NULL)
  {
    fprintf (OutFil," DB delete expression data table\n");
    fflush  (OutFil);
  }

  End
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
  IGRint        nNumData;

  IGRint        col_typ[MY_NUMCOL];
  IGRint        col_num[MY_NUMCOL];
  IGRint        columns;
  ICHRptr       col_value[MY_NUMCOL];

  FILE *p_file;

  extern int VDSverify_login();
  extern int VdsVerifyRisTable();

  SetProc( VDcrexp.VDPostYourselfToDb ); Begin
  /* Initialization */

  *msg = MSFAIL;

  nNumData = om$dimension_of (varray = me->Ldatarec);

  p_file = NULL;

#ifndef MY_DEBUG
  p_file = (FILE *)fopen( "CRexpr.log", "w+" );
#endif
  if( p_file == NULL )
  {
    p_file = (FILE *)stdout;
  }

  if (VDSverify_login() != PDM_S_SUCCESS)
  {
    fprintf (p_file,"Attempted post of %s, no DB connection\n\n",
                                me->Expid_tab.Tabnam);
    goto ABORT;
  }

  if (VdsVerifyRisTable(VDCREXP_NAM_TAB) != VDS_DBTABLE_FOUND)
  {
    fprintf (p_file, VD_DRWLO_NODB_MSG);
    goto ABORT;
  }

  /*   delete old version    */

  status =
  om$send (msg = message VDcrexp.DBdelete (msg, p_file),
      targetid = my_id);

  if (*msg != MSSUCC) goto ABORT;
  if (!(status & OM_S_SUCCESS)) goto ABORT;

  /*      post table header    */

  fprintf (p_file," DB post expression table, name = %s \n\n",
                                     me->Expid_tab.Tabnam);
  fflush  (p_file);

  columns       = VDCREXP_NUM_TAB + 3;
  col_typ[0]    = CHAR;
  col_typ[1]    = CHAR;
  col_typ[2]    = CHAR;
  col_typ[3]    = CHAR;
  col_typ[4]    = CHAR;
  col_typ[5]    = SMALLINT;

  col_num[0]    = VD_CREXP_CHR_TYPE;
  col_num[1]    = VD_CREXP_CHR_NAME;
  col_num[2]    = VD_CREXP_CHR_STAMP;
  col_num[3]    = VD_CREXP_CHR_IDFLD;
  col_num[4]    = VD_CREXP_CHR_DESC;
  col_num[5]    = 0;

  col_value[0]  = me->Expid_tab.Tabtyp;
  col_value[1]  = me->Expid_tab.Tabnam;
  col_value[2]  = me->Expid_tab.Timest;
  col_value[3]  = me->Expid_tab.Userid;
  col_value[4]  = me->Expid_tab.Shdesc;
  col_value[5]  = (IGRchar *) &me->Expid_tab.data_type;

#ifdef MY_DEBUG
  VD_post_prt (columns, col_typ, col_value);
#endif

  status = VD_post_SqlInsVal
              (VDCREXP_NAM_TAB, columns, col_typ, col_num, col_value);
  if (status != SUCCESS) goto ABORT;

  /*      post expression data table    */

  columns       = VDCREXP_NUM_DAT ;
  col_typ[0]    = CHAR;
  col_typ[1]    = CHAR;
  col_typ[2]    = SMALLINT;
  col_typ[3]    = CHAR;

  col_num[0]    = VD_CREXP_CHR_NAME;
  col_num[1]    = VD_CREXP_CHR_GRP;
  col_num[2]    = 0;
  col_num[3]    = VD_CREXP_CHR_INFO;

  fprintf (p_file," Data table        %4d entries\n",nNumData);
  fflush  (p_file);

  for (iLine=0; iLine<nNumData; iLine++)
  {
    col_value[0]  =              me->Ldatarec[iLine].Datnam;
    col_value[1]  =              me->Ldatarec[iLine].Datgrp;
    col_value[2]  = (IGRchar *) &me->Ldatarec[iLine].Datsegn;
    col_value[3]  =              me->Ldatarec[iLine].Datinfo;

#ifdef MY_DEBUG
    VD_post_prt (columns, col_typ, col_value);
#endif

    status = VD_post_SqlInsVal
              (VDCREXP_NAM_DAT, columns, col_typ, col_num, col_value);
    if (status != SUCCESS) goto ABORT;
  }

  /*   reset my local flag..... */

  me->Expid_tab.Local = FALSE;

  *msg = MSSUCC;
  fprintf (p_file," \n\n Expression Tables posted successfully\n");

  ABORT:
  if( p_file != (FILE *)stdout )
   fclose( p_file );

  End
  return (OM_S_SUCCESS);
}

end implementation VDcrexp;

