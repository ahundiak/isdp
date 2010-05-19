/* $Id: VDDLU_exec.I,v 1.2 2001/01/26 22:52:01 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLU_exec.I
 *
 * Description:
 *
 * Implementation file for utilities execute methods (post/delete)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLU_exec.I,v $
 *      Revision 1.2  2001/01/26 22:52:01  ad
 *      *** empty log message ***
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/01/27  20:05:56  pinnacle
# Replaced: vdtbl/cmd/VDDLU_exec.I for:  by azuurhou for
#
# Revision 1.2  1997/10/21  04:36:20  pinnacle
# Replaced: vdtbl/cmd/VDDLU_exec.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1996/02/16  06:05:18  pinnacle
# Replaced: vdtbl/cmd/VDDLU_exec.I for:  by rgade for vds.240
#
# Revision 1.5  1996/02/15  23:15:00  pinnacle
# Replaced: ./vdtbl/cmd/VDDLU_exec.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/09/25  23:03:36  pinnacle
# Replaced: vdtbl/cmd/VDDLU_exec.I for:  by sundar for vds.240
#
# Revision 1.3  1995/09/05  23:12:58  pinnacle
# Replaced: vdtbl/cmd/VDDLU_exec.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/08/18  21:03:34  pinnacle
# Replaced: vdtbl/cmd/VDDLU_exec.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/08/18  20:59:08  pinnacle
# Created: vdtbl/cmd/VDDLU_exec.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      08/17/95        HV              Split off from VDDLU_fn.I
 *	02/15/96	HV		Correction for ISL.
 *	10/20/97        Sundar          Modified for expression table
 *      01/19/01        ylong           ETL4898, not assigned TR# yet
 * -------------------------------------------------------------------*/

class implementation VDCmdDLU;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
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

#include "VDdrwlo_pr.h"
#include "VDScheckin.h"

#include "vdbmacros.h"
#include "vdtblmacros.h"

// #define vdsDEBUG        1
#include "v_dbgmacros.h"


// from     VDSroot    import   VDPostYourselfToDb;

/*
#define MY_DEBUG
*/




method VDDLU_Post (long     *sts;
                   IGRchar  *szmsg;
                   IGRchar  *szms1;
                   int       gadget_label)
{
  IGRint       status;
  IGRint       rtc;
  IGRlong      retmsg;
  IGRchar      Ixtab[100];
  IGRchar      tabnam[100];

  extern IGRint     GRconfirm_box();

  SetProc( VDCmdDLU.VDDLU_Post ); Begin

  status  = OM_S_SUCCESS;
  *sts    = MSFAIL;

#ifdef MY_DEBUG
  printf("POST1: Db_Ixtab   : %s\n", me->Db_Ixtab );
  printf("POST1: CUR_tabnam : %s\n", me->CUR_tabnam );
#endif

  strcpy( Ixtab,   me->Db_Ixtab );
  strcpy( tabnam , me->CUR_tabnam );

  if (!(VD_Allow_DBdel (Ixtab, tabnam)))
  {
    strcpy (szmsg, VD_DLU_EMSG_NOIDP);
    goto quit;
  }

#ifdef MY_DEBUG
  printf("POSTallow: Db_Ixtab   : %s\n", me->Db_Ixtab );
  printf("POSTallow: CUR_tabnam : %s\n", me->CUR_tabnam );
#endif

  /*    check for local copy     */

  if (!(me->My_Localflag))
  {
    rtc = GRconfirm_box (VD_DLU_EMSG_NDBC);
    if (!rtc) goto quit;
  }

  strcpy( Ixtab,   me->Db_Ixtab );
  strcpy( tabnam , me->CUR_tabnam );

  if (VD_db_table_haskey (Ixtab, VDDRWLO_DB_KEY, tabnam))
  {
    rtc = GRconfirm_box (VD_DLU_EMSG_NDBO);
    if (!rtc) goto quit;
  }

  *sts = MSSUCC;

#ifdef MY_DEBUG
  printf (" send post to GRID <%d %d>\n",
                     me->My_stored_lo.objid, me->My_stored_lo.osnum);
  retmsg = MSSUCC;
#endif

  status =
  om$send (msg = message VDSroot.VDPostYourselfToDb
                                  (&retmsg, REG_CHECKIN, 0, NULL, NULL,
                                    NULL, NULL, 0),
      targetid = me->My_stored_lo.objid,
      targetos = me->My_stored_lo.osnum);

#ifdef MY_DEBUG
  printf (" from post, retmsg, succ, fail %d %d %d\n",retmsg,
                            MSSUCC, MSFAIL);
#endif

  if (retmsg == MSSUCC)
  {
    sprintf (szmsg, VD_DLU_EMSG_NDBP, me->CUR_tabnam);
    me->My_localret = gadget_label;
  }
  else
  {  /*  error occurred, switch to RESET   */
    strcpy (szmsg, VD_DLU_EMSG_NDBE);
    me->My_localret = FI_RESET;
  }

  _put_response( resp = EX_FORM_FINISHED );

  quit:
  End
  return (OM_S_SUCCESS);
}



method VDDLU_Delete (long     *sts;
                     IGRchar  *szmsg;
                     IGRchar  *szms1;
                     int       gadget_label)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       rtc;
  IGRchar      whout[100];

  extern IGRint     GRconfirm_box();

  SetProc( VDCmdDLU.VDDLU_Delete ); Begin

  status  = OM_S_SUCCESS;
  *sts    = MSFAIL;

  /*    check for local copy     */

  if (me->My_Delopt != VD_DLU_DST_LOCAL)
  {
    if (!(VD_Allow_DBdel (me->Db_Ixtab, me->CUR_tabnam)))
    {
      strcpy (szmsg, VD_DLU_EMSG_NOIDD);
      goto quit;
    }
  }

  if ((me->My_Localflag) && (me->My_Delopt != VD_DLU_DST_DB) 
	&& strcmp(szmsg,VD_DLU_OL_ALL))
  {
    rtc = GRconfirm_box (VD_DLU_EMSG_NLOC);
    if (!rtc) goto quit;
  }

  *sts    = MSSUCC;

  /* confirmed or DB copy , go ahead and delete  */

  strcpy (whout, VDDRWLO_DB_KEY);
  strcat (whout, "=\'");
  strcat (whout, me->CUR_tabnam);
  strcat (whout, "\'");

#ifdef MY_DEBUG
  printf (" DELETE %d\n", me->My_Delopt);
#else
  switch (me->My_ParTyp)
  {
    case VD_DLU_PAR_DLO:
    case VD_DLU_PAR_TYP:
      if (me->My_Delopt != VD_DLU_DST_DB)
      {
        vd$tbldlo_del (msg     = &retmsg,
                       osnum   = me->My_OS,
                       tabnam  = me->CUR_tabnam);
        sprintf (szmsg, VD_DLU_EMSG_FIDEL, "Table Layout", me->CUR_tabnam);
      }

      if (me->My_Delopt != VD_DLU_DST_LOCAL)
      {
        status = vdb$RisDelete (table_name = VDDRWLO_NAM_TAB,
                                where      = whout);
        status = vdb$RisDelete (table_name = VDDRWLO_NAM_ALG,
                                where      = whout);
        status = vdb$RisDelete (table_name = VDDRWLO_NAM_COL,
                                where      = whout);
        status = vdb$RisDelete (table_name = VDDRWLO_NAM_HTF,
                                where      = whout);
        status = vdb$RisDelete (table_name = VDDRWLO_NAM_FLD,
                                where      = whout);
        sprintf (szms1, VD_DLU_EMSG_DBDEL, "Table Layout", me->CUR_tabnam);
      }
      break;

    case VD_DLU_PAR_SRT:
      if (me->My_Delopt != VD_DLU_DST_DB)
      {
        vd$tblstc_del (msg     = &retmsg,
                       osnum   = me->My_OS,
                       tabnam  = me->CUR_tabnam);
        sprintf (szmsg, VD_DLU_EMSG_FIDEL, "Sort Criterion", me->CUR_tabnam);
      }

      if (me->My_Delopt != VD_DLU_DST_LOCAL)
      {
        status = vdb$RisDelete (table_name = VDCRSRT_NAM_TAB,
                                where      = whout);
        status = vdb$RisDelete (table_name = VDCRSRT_NAM_SKY,
                                where      = whout);
        sprintf (szms1, VD_DLU_EMSG_DBDEL, "Sort Criterion", me->CUR_tabnam);
      }
      break;

    case VD_DLU_PAR_SUM:
      if (me->My_Delopt != VD_DLU_DST_DB)
      {
        vd$tblsuc_del (msg     = &retmsg,
                       osnum   = me->My_OS,
                       tabnam  = me->CUR_tabnam);
        sprintf (szmsg, VD_DLU_EMSG_FIDEL, "Summ Criterion", me->CUR_tabnam);
      }

      if (me->My_Delopt != VD_DLU_DST_LOCAL)
      {
        status = vdb$RisDelete (table_name = VDCRSUM_NAM_TAB,
                                where      = whout);
        status = vdb$RisDelete (table_name = VDCRSUM_NAM_QTY,
                                where      = whout);
        status = vdb$RisDelete (table_name = VDCRSUM_NAM_MTC,
                                where      = whout);
        sprintf (szms1, VD_DLU_EMSG_DBDEL, "Summ Criterion", me->CUR_tabnam);
      }
      break;

    case VD_DLU_PAR_ADS:
      if (me->My_Delopt != VD_DLU_DST_DB)
      {
        vd$tblads_del (msg     = &retmsg,
                       osnum   = me->My_OS,
                       tabnam  = me->CUR_tabnam);
        sprintf (szmsg, VD_DLU_EMSG_FIDEL, "ADS Criterion", me->CUR_tabnam);
      }

      if (me->My_Delopt != VD_DLU_DST_LOCAL)
      {
        status = vdb$RisDelete (table_name = VDADSYM_NAM_TAB,
                                where      = whout);
        status = vdb$RisDelete (table_name = VDADSYM_NAM_REC,
                                where      = whout);
        sprintf (szms1, VD_DLU_EMSG_DBDEL, "ADS Criterion", me->CUR_tabnam);
      }
      break;

	/* Begin added for expression table -- sundar */
    case VD_DLU_PAR_EXP:
    case VD_DLU_PAR_EXP_TYP:

      if (me->My_Delopt != VD_DLU_DST_LOCAL)
      {
 
        status = om$send (msg = message VDcrexp.DBdelete
                                  (&retmsg, NULL),
        targetid = me->My_stored_lo.objid,
        targetos = me->My_stored_lo.osnum);
        sprintf (szms1, VD_DLU_EMSG_DBDEL, "Expression Criterion",
                                me->CUR_tabnam);
      }

      if (me->My_Delopt != VD_DLU_DST_DB)
      {
        vd$tblexp_del (msg     = &retmsg,
                       osnum   = me->My_OS,
                       tabnam  = me->CUR_tabnam);
        sprintf (szmsg, VD_DLU_EMSG_FIDEL, "Expression Criterion", 
				me->CUR_tabnam);
      }
 
      break;
	/* End added for expression table -- sundar */


    default:
      break;
  }
#endif

  me->My_localret = gadget_label;
  _put_response( resp = EX_FORM_FINISHED );

  quit:
  End
  return (OM_S_SUCCESS);
}

end implementation VDCmdDLU;

