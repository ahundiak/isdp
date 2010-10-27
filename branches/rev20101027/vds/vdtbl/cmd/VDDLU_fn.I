
/* $Id: VDDLU_fn.I,v 1.2 2001/01/26 22:52:03 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLU_fn.I
 *
 * Description:
 *
 * Implementation file for utilities form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLU_fn.I,v $
 *      Revision 1.2  2001/01/26 22:52:03  ad
 *      *** empty log message ***
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/01/27  20:07:52  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I for:  by azuurhou for
#
# Revision 1.2  1997/10/21  04:39:28  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.10  1996/04/03  23:16:02  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I for:  by hverstee for vds.240
#
# Revision 1.9  1996/02/15  23:15:14  pinnacle
# Replaced: ./vdtbl/cmd/VDDLU_fn.I for:  by azuurhou for vds.240
#
# Revision 1.8  1995/09/25  23:00:08  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I for:  by sundar for vds.240
#
# Revision 1.7  1995/09/06  18:42:18  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/05  23:13:44  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/18  21:01:12  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/15  23:53:28  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/06  16:13:06  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.2  1995/05/11  17:02:06  pinnacle
# Replaced: vdtbl/cmd/VDDLU_fn.I by hverstee r#
#
# Revision 1.1  1995/04/29  17:04:52  pinnacle
# Created: vdtbl/cmd/VDDLU_fn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *	10/20/97        Sundar          Modified for expression table
 *	01/19/01        ylong           ETL4989, not assigned TR# yet
 * -------------------------------------------------------------------*/

class implementation VDCmdDLU;

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

#include "vdtblmacros.h"

//#define vdsDEBUG        1
#include "v_dbgmacros.h"

from     VDADS      import   VDADS_gtab;

//#define MY_DEBUG	1

method form_notification ( int         form_label ;
                           int         gadget_label ;
                           double      value ;
                           char      * form_ptr )
{
  IGRint	status;
  IGRlong	retmsg;
  IGRchar	szFld[100];
  IGRchar	szmsg[100];
  IGRchar	szms1[100];
  IGRint	idsp;
  IGRint	iPar;
  IGRint	i, no_exp_data = 0;

  struct GRid  lGRID;

  SetProc( VDCmdDLU.form_notification ); Begin

  status  = OM_S_SUCCESS;

  szmsg[0] = '\0';
  szms1[0] = '\0';
  szFld[0] = '\0';

  me->My_localret = 0;

  switch (gadget_label)
  {
    case VD_DLU_FLD_DELOPT:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      for (iPar=0; iPar<me->nDELopt; iPar++)
      {
        idsp = iPar * VD_DRWLO_CHR_IDFLD;
        if (strcmp (szFld, &me->pDELopt[idsp]) != 0) continue;

        switch (iPar)
        {
          case 0:
            me->My_Delopt = VD_DLU_DST_LOCAL;
            break;

          case 1:
            if (!(me->My_Dblogin))
              strcpy (szmsg, VD_DLU_EMSG_NODB);
            else
              me->My_Delopt = VD_DLU_DST_DB;
            break;

          case 2:
            if (!(me->My_Dblogin))
              strcpy (szmsg, VD_DLU_EMSG_NODB);
            else
              me->My_Delopt = VD_DLU_DST_BOTH;
            break;

          default:
            me->My_Delopt = VD_DLU_DST_NONE;
            break;
        }

        break;
      }

      break;

    case VD_DLU_FLD_PARAM:
      FIg_get_text (form_ptr, gadget_label, szFld);
      FIg_enable (form_ptr, VD_DLU_FLD_DELOPT);
      FIg_enable (form_ptr, VD_DLU_FLD_TABNAM);
      FIg_enable (form_ptr, VD_DLU_FLD_TABTYP);
      if (szFld[0] == '\0') break;

#ifdef MY_DEBUG
        printf (" fn param %s - %d\n", szFld, me->nPARNams);
#endif
      status =
      om$send (msg = message VDCmdDLU.VDDLU_Reset (&retmsg),
          targetid = my_id);

      for (iPar=0; iPar<me->nPARNams; iPar++)
      {
        idsp = iPar * VD_DLU_PAR_LENGTH;
#ifdef MY_DEBUG
        printf (" setpar %s - %s\n", szFld, &me->pPARNams[idsp]);
#endif
        if (strcmp (szFld, &me->pPARNams[idsp]) != 0) continue;

        switch (iPar) {
	case 0:
	    /* Delete all tables from local. ylong */
	    me->My_ParTyp = VD_DLU_PAR_ALL;
            me->My_Delopt = VD_DLU_DST_LOCAL;
            strcpy (me->Db_Ixtab, "ALL");
	    FIg_set_text (form_ptr, VD_DLU_FLD_DELOPT, VD_DLU_DO_FILE);
	    FIg_disable (form_ptr, VD_DLU_FLD_DELOPT);
	    FIg_disable (form_ptr, VD_DLU_FLD_TABNAM);
	    FIg_disable (form_ptr, VD_DLU_FLD_TABTYP);
            break;
        case 1:
            me->My_ParTyp = VD_DLU_PAR_DLO;
            strcpy (me->Db_Ixtab, VDDRWLO_NAM_TAB);
            break;
        case 2:
            me->My_ParTyp = VD_DLU_PAR_SRT;
            strcpy (me->Db_Ixtab, VDCRSRT_NAM_TAB);
            break;
        case 3:
            me->My_ParTyp = VD_DLU_PAR_SUM;
            strcpy (me->Db_Ixtab, VDCRSUM_NAM_TAB);
            break;
        case 4:
            me->My_ParTyp = VD_DLU_PAR_ADS;
            strcpy (me->Db_Ixtab, VDADSYM_NAM_TAB);
            break;
	case 5:
	    me->My_ParTyp = VD_DLU_PAR_EXP;
            strcpy (me->Db_Ixtab, VDCREXP_NAM_TAB);
            break;
        default:
            me->My_ParTyp = VD_DLU_PAR_NONE;
            me->Db_Ixtab[0] = '\0';
            break;
        }
        break;
      }

#ifdef MY_DEBUG
      printf ("set parametertype %d %s\n",me->My_ParTyp, me->Db_Ixtab);
#endif

      if( me->My_ParTyp == VD_DLU_PAR_ALL ) break;

      status =
      om$send (msg = message VDCmdDLU.VDDLU_Load (&retmsg),
          targetid = my_id);
      break;

    case VD_DLU_FLD_TABTYP:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if ((me->My_ParTyp != VD_DLU_PAR_DLO) &&
          (me->My_ParTyp != VD_DLU_PAR_TYP) &&
          (me->My_ParTyp != VD_DLU_PAR_EXP) &&
          (me->My_ParTyp != VD_DLU_PAR_EXP_TYP))
      {
        strcpy (szmsg, VD_DLU_EMSG_NOPAR);
        break;
      }

      strcpy (me->CUR_tabtyp, szFld);
      /* me->My_ParTyp = VD_DLU_PAR_TYP; */
      if (me->My_ParTyp == VD_DLU_PAR_EXP )
          me->My_ParTyp = VD_DLU_PAR_EXP_TYP;
      else if (me->My_ParTyp == VD_DLU_PAR_DLO)
          me->My_ParTyp = VD_DLU_PAR_TYP;

      status =
      om$send (msg = message VDCmdDLU.VDDLU_Load (&retmsg),
          targetid = my_id);

      break;

    case VD_DLU_FLD_TABNAM:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (me->My_ParTyp == VD_DLU_PAR_NONE)
      {
        strcpy (szmsg, VD_DLU_EMSG_NOPAR);
        break;
      }

      lGRID.objid = NULL_OBJID ;
      lGRID.osnum = me->My_OS ;

      switch (me->My_ParTyp)
      {
        case VD_DLU_PAR_DLO:
        case VD_DLU_PAR_TYP:
          vd$tbldlo_old ( msg    = &retmsg,
                          osnum  = me->My_OS,
                          tabnam = szFld,
                          GRid   = &lGRID);
          break;

        case VD_DLU_PAR_SRT:
          vd$tblstc_old ( msg    = &retmsg,
                          osnum  = me->My_OS,
                          tabnam = szFld,
                          GRid   = &lGRID);
          break;

        case VD_DLU_PAR_SUM:
          vd$tblsuc_old ( msg    = &retmsg,
                          osnum  = me->My_OS,
                          tabnam = szFld,
                          GRid   = &lGRID);
          break;

        case VD_DLU_PAR_ADS:
          vd$tblads_old ( msg    = &retmsg,
                          osnum  = me->My_OS,
                          tabnam = szFld,
                          GRid   = &lGRID);
          break;
	/* Begin added for exprssion table -- sundar */
	case VD_DLU_PAR_EXP:
	case VD_DLU_PAR_EXP_TYP:
	   vd$tblexp_old ( msg    = &retmsg,
                          osnum  = me->My_OS,
                          tabnam = szFld,
                          GRid   = &lGRID);
          break;
	/* End added for exprssion table -- sundar */

      }

      if (lGRID.objid == NULL_OBJID)
      {
        sprintf (szmsg, VD_DLU_EMSG_NPAR, szFld);
        break;
      }

      me->My_stored_lo.objid = lGRID.objid;
      me->My_stored_lo.osnum = lGRID.osnum;

      strcpy (me->CUR_tabnam, szFld);

#ifdef MY_DEBUG
      printf ("to find dbowner with %s %s\n",me->Db_Ixtab, me->CUR_tabnam);
#endif

      status = VD_Find_DBowner (me->Db_Ixtab, me->CUR_tabnam, me->CUR_dbowner);


#ifdef MY_DEBUG
      printf ("found dbowner  %s\n",me->CUR_dbowner);
#endif

      switch (me->My_ParTyp)
      {

        case VD_DLU_PAR_DLO:
        case VD_DLU_PAR_TYP:
        default:
          status =
          om$send (msg = message VDdrwlo.VDdrwlo_gtab (&retmsg, &me->Ltbrec),
              targetid = lGRID.objid,
              targetos = lGRID.osnum);

          me->My_Localflag = me->Ltbrec.Local;

          strcpy (me->CUR_tabtyp, me->Ltbrec.Tabtyp);
          break;

        case VD_DLU_PAR_SRT:
        case VD_DLU_PAR_SUM:
          status =
          om$send (msg = message VDSSC.VDSSC_gtab (&retmsg, &me->SSid_tab),
              targetid = lGRID.objid,
              targetos = lGRID.osnum);

          me->My_Localflag = me->SSid_tab.Local;
          me->CUR_tabtyp[0] = '\0';
          break;

        case VD_DLU_PAR_ADS:
          status =
          om$send (msg = message VDADS.VDADS_gtab (&retmsg, &me->SSid_tab),
              targetid = lGRID.objid,
              targetos = lGRID.osnum);

          me->My_Localflag = me->SSid_tab.Local;
          me->CUR_tabtyp[0] = '\0';
          break;

	/* Begin added for expression table -- sundar */
	case VD_DLU_PAR_EXP:
	case VD_DLU_PAR_EXP_TYP:
	  {
	  IGRint no_exp_data=0;
          status =
          om$send (msg = message VDcrexp.VDcrexp_gtab (&retmsg, &me->Expid_tab,
				&no_exp_data, NULL),
              targetid = lGRID.objid,
              targetos = lGRID.osnum);
 
          me->My_Localflag = me->Expid_tab.Local;
          /* me->CUR_tabtyp[0] = '\0'; */
	  strcpy (me->CUR_tabtyp, me->Expid_tab.Tabtyp);
          }
          break;
	/* End added for expression table -- sundar */

      }

      break;

    case FI_ACCEPT:
    case FI_EXECUTE:
      if (me->My_ParTyp == VD_DLU_PAR_NONE)
      {
        strcpy (szmsg, VD_DLU_EMSG_NOPAR);
        break;
      }

      if (me->CUR_tabnam[0] == '\0' && me->My_ParTyp != VD_DLU_PAR_ALL)
      {
        strcpy (szmsg, VD_DLU_EMSG_NOTAB);
        break;
      }

      if (me->My_Type == VD_DLU_CMD_POST)
      {
#ifdef	MY_DEBUG
  printf(" Db_Ixtab   : %s\n", me->Db_Ixtab );
  printf(" CUR_tabnam : %s\n", me->CUR_tabnam );
  printf(" Call VDCmdDLU.VDDLU_Post \n");
#endif

        status =
        om$send (msg = message VDCmdDLU.VDDLU_Post
                               (&retmsg, szmsg, szms1, gadget_label),
            targetid = my_id);
      }
      else
      {
	if( me->My_ParTyp != VD_DLU_PAR_ALL )
	{
        	status =
        	om$send (msg = message VDCmdDLU.VDDLU_Delete
                               (&retmsg, szmsg, szms1, gadget_label),
            		targetid = my_id);
	}
	/* Delete all tables from local */
	else
	{
	    if(GRconfirm_box(
		  "All OPE tables in the local design file will be deleted ?"))
	    {

		for (iPar=1; iPar<me->nPARNams; iPar++)
		{
			idsp = iPar * VD_DLU_PAR_LENGTH;
			switch (iPar) {
			case 1:
			    me->My_ParTyp = VD_DLU_PAR_DLO;
			    strcpy (me->Db_Ixtab, VDDRWLO_NAM_TAB);
			    break;
			case 2:
			    me->My_ParTyp = VD_DLU_PAR_SRT;
			    strcpy (me->Db_Ixtab, VDCRSRT_NAM_TAB);
			    break;
			case 3:
			    me->My_ParTyp = VD_DLU_PAR_SUM;
			    strcpy (me->Db_Ixtab, VDCRSUM_NAM_TAB);
			    break;
			case 4:
			    me->My_ParTyp = VD_DLU_PAR_ADS;
			    strcpy (me->Db_Ixtab, VDADSYM_NAM_TAB);
			    break;
			case 5:
			    me->My_ParTyp = VD_DLU_PAR_EXP;
		            strcpy (me->Db_Ixtab, VDCREXP_NAM_TAB);
			};

			status = om$send (
				msg = message VDCmdDLU.VDDLU_Load (&retmsg),
				targetid = my_id);
#ifdef MY_DEBUG
			printf("me->nNamLoc = %d, me->Db_Ixtab = <%s>\n", 
				me->nNamLoc, me->Db_Ixtab);
#endif

			for(i = 0; i < me->nNamLoc; i++) {
				lGRID.objid = NULL_OBJID ;
				lGRID.osnum = me->My_OS ;
				idsp = i * VD_DRWLO_CHR_IDFLD;
#ifdef MY_DEBUG
				printf("  me->pNamLoc[%d] <%s>\n", i, &me->pNamLoc[idsp]);
#endif
				strcpy(szFld, &me->pNamLoc[idsp]);

				switch (me->My_ParTyp)
				{
				case VD_DLU_PAR_DLO:
				case VD_DLU_PAR_TYP:
				  vd$tbldlo_old ( msg    = &retmsg,
				                  osnum  = me->My_OS,
				                  tabnam = szFld,
				                  GRid   = &lGRID);
				  break;
				case VD_DLU_PAR_SRT:
				  vd$tblstc_old ( msg    = &retmsg,
				                  osnum  = me->My_OS,
				                  tabnam = szFld,
				                  GRid   = &lGRID);
				  break;
				case VD_DLU_PAR_SUM:
				  vd$tblsuc_old ( msg    = &retmsg,
				                  osnum  = me->My_OS,
				                  tabnam = szFld,
				                  GRid   = &lGRID);
				  break;

				case VD_DLU_PAR_ADS:
				  vd$tblads_old ( msg    = &retmsg,
				                  osnum  = me->My_OS,
				                  tabnam = szFld,
				                  GRid   = &lGRID);
				  break;

				case VD_DLU_PAR_EXP:
				case VD_DLU_PAR_EXP_TYP:
				  vd$tblexp_old ( msg    = &retmsg,
				                  osnum  = me->My_OS,
				                  tabnam = szFld,
				                  GRid   = &lGRID);
				  break;

				};

				if (lGRID.objid == NULL_OBJID)
				{
				  sprintf (szmsg, VD_DLU_EMSG_NPAR, szFld);
			 	  break;
				}

				me->My_stored_lo.objid = lGRID.objid;
				me->My_stored_lo.osnum = lGRID.osnum;

				strcpy (me->CUR_tabnam, szFld);

				status = VD_Find_DBowner(me->Db_Ixtab, 
							me->CUR_tabnam, 
							me->CUR_dbowner);

				switch (me->My_ParTyp)
				{
				case VD_DLU_PAR_DLO:
				case VD_DLU_PAR_TYP:
				default:
				  status = om$send (
					msg	 = message VDdrwlo.VDdrwlo_gtab 
							(&retmsg, &me->Ltbrec),
					targetid = lGRID.objid,
					targetos = lGRID.osnum);

				  me->My_Localflag = me->Ltbrec.Local;
				  strcpy (me->CUR_tabtyp, me->Ltbrec.Tabtyp);
				  break;

				case VD_DLU_PAR_SRT:
				case VD_DLU_PAR_SUM:
				  status = om$send (
					msg	 = message VDSSC.VDSSC_gtab 
							(&retmsg,&me->SSid_tab),
					targetid = lGRID.objid,
					targetos = lGRID.osnum);

				  me->My_Localflag = me->SSid_tab.Local;
				  me->CUR_tabtyp[0] = '\0';
				  break;

				case VD_DLU_PAR_ADS:
				  status = om$send (
					msg	 = message VDADS.VDADS_gtab 
						(&retmsg, &me->SSid_tab),
					targetid = lGRID.objid,
					targetos = lGRID.osnum);

				  me->My_Localflag = me->SSid_tab.Local;
				  me->CUR_tabtyp[0] = '\0';
				  break;

				case VD_DLU_PAR_EXP:
				case VD_DLU_PAR_EXP_TYP:
				{
				  IGRint no_exp_data=0;
				  status = om$send (
					msg	 = message VDcrexp.VDcrexp_gtab 
						      (&retmsg, &me->Expid_tab,
							&no_exp_data, NULL),
					targetid = lGRID.objid,
					targetos = lGRID.osnum);
 
				  me->My_Localflag = me->Expid_tab.Local;
				  strcpy (me->CUR_tabtyp, me->Expid_tab.Tabtyp);
				  break;
				}

      				}; 

				strcpy(szmsg, VD_DLU_OL_ALL);
				status = om$send (
					msg = message VDCmdDLU.VDDLU_Delete
					(&retmsg, szmsg, szms1, gadget_label),
					targetid = my_id);
			}
		}

		if( (status&1) && retmsg == MSSUCC)
		{
		   strcpy(szmsg, 
		    "All OPE tables have been deleted from local design file.");
		}
		else
		{
		   strcpy(szmsg, 
		    "Failed to delete All OPE tables from local design file.");
		}
	    };
        }
        /* End - Delete all tables from local */

      }

      if (retmsg == MSSUCC)
      {
        me->My_localret = gadget_label;
        _put_response( resp = EX_FORM_FINISHED );
      }
      break;

    case FI_RESET:
    case FI_CANCEL:
      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    default:
      break;
  }

  status =
  om$send (msg = message VDCmdDLU.VDDLU_disp (form_ptr),
      targetid = my_id);

  FIg_set_text (form_ptr, VD_DLU_FLD_MSG, szmsg);
  FIg_set_text (form_ptr, VD_DLU_FLD_MSG2, szms1);

  quit:
  End
  return (status);
}

end implementation VDCmdDLU;
