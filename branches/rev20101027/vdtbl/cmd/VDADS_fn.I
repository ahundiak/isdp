
/* $Id: VDADS_fn.I,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDADS_fn.I
 *
 * Description:
 *
 * Implementation file for ads form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDADS_fn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/07/14  20:49:12  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/01/29  19:48:58  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by mdong for vds
#
# Revision 1.3  1998/01/21  04:08:04  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by vgnair for vds
#
# Revision 1.2  1997/11/27  06:10:54  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.14  1995/12/14  22:28:18  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by hverstee for vds.240
#
# Revision 1.13  1995/11/17  22:28:22  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by hverstee for vds.240
#
# Revision 1.12  1995/10/10  14:09:46  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by tlbriggs for vds.240
#
# Revision 1.11  1995/10/06  15:27:56  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by yzhu for vds.240
#
# Revision 1.10  1995/09/25  23:43:54  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by sundar for vds.240
#
# Revision 1.9  1995/09/25  23:03:20  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by sundar for vds.240
#
# Revision 1.8  1995/09/22  14:06:58  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/09/08  23:30:24  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/09/05  23:16:18  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/15  23:50:58  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/14  22:41:04  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/11  23:32:20  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  15:45:00  pinnacle
# Replaced: vdtbl/cmd/VDADS_fn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/19  19:58:56  pinnacle
# Created: vdtbl/cmd/VDADS_fn.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY   AUTHOR   	DESCRIPTION
 *
 *      06/12/95    HV         	New
 *	10/06/95    yzhu	Keep attribute name when relation type flips
 *	10/06/95    tlb		Set szAttrval in case VD_ADSYM_FLD_ATVNUM
 *	11/27/97    vini 	Place cell in BOM table
 *      07/13/99    Ming        TR179900709
 *
 * -------------------------------------------------------------------*/


class implementation VDCmdADS;

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
#include "vdpardef.h"

#include "VDdrwlo_pr.h"

#include <OMerrordef.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <msdef.h>
#include <exms.h>
#include <msmacros.h>
#include "grmacros.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "griomacros.h"
#include "grmsg.h"
#include "grerr.h"

#include "VDCmdDrwlo.h"
#include "vdsmacros.h"


%safe
#include <math.h>
%endsafe

/*
#define   MY_DEBUG
*/



method form_notification ( int         form_label ;
                           int         gadget_label ;
                           double      value ;
                           char      * form_ptr )

{
  IGRint       status;
  IGRlong      retmsg;
  IGRchar      szFld[VD_DRWLO_CHR_DESC];
  IGRchar      tmpFld[VD_DRWLO_CHR_DESC];
  IGRchar      szmsg[80];
  int          i, idsp;
  IGRshort     iSet;
  double       dLocval;
  int          nLocval;

  struct   GRid              lGRID;
  struct   VDdrwlo_sstab     Local;

char *cell;
int cell_count = 0;
int rows = 0;
char null[1];
int Selflag = FALSE;

  extern IGRboolean   VD_TBL_idquote (IGRchar   *szFld);

  IGRlong				sts,
					ret_msg;
  struct 	GRactive_symbol_def	active_symbol;
  struct 	GRsymbol_lib_file	file;
  struct	GRid			symbol_id;
  struct 	GRmd_env		sl_env;

  sts	   = MSSUCC;
  ret_msg  = MSSUCC;
  symbol_id.objid = NULL_OBJID;

  status   = OM_S_SUCCESS;
  szmsg[0] = '\0';
  iSet     = -1;

  me->My_localret = 0;

#ifdef MY_DEBUG
  printf (" EDIT formnot, gadget %d\n",gadget_label);
#endif

  FIg_get_value (form_ptr, gadget_label, &dLocval);

  nLocval = (dLocval > 0) ? (dLocval + 0.001) : (dLocval - 0.001);

  switch (gadget_label)
  {

/* ---------------------  HEADER SECTION GADGETS -------------------------- */

    case VD_ADSYM_FLD_TABNAM:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (VD_TBL_idquote(szFld))
      {
        strcpy  (szmsg, VD_ADS_EMSG_QTE);
        break;
      }

      status = VD_adsym_getid (&retmsg, szFld, &lGRID);

      me->My_stored_lo.objid = lGRID.objid;
      me->My_stored_lo.osnum = lGRID.osnum;

      if (lGRID.objid == NULL_OBJID)
      {   /*    does not exist, create new   */
        if (me->My_Type == VD_CMD_ADS_REV) break;

        strcpy (me->CUR_tabnam, szFld);

        strcpy (Local.Tabnam, me->CUR_tabnam);

        strcpy (Local.Shdesc, "");

        Local.Local  = TRUE;

        status =
        om$send (msg = message VDADS.VDADS_init (&retmsg, &Local),
            targetid = my_id);

        sprintf (szmsg, VD_ADS_EMSG_NSYM, szFld);
        strcat  (szmsg, VD_ADS_EMSG_CRE);
        me->nCurSym = -1;
        me->nMaxSym = 0;
      }
      else
      {
        strcpy (me->CUR_tabnam, szFld);

        status =
        om$send (msg = message VDCmdADS.VDADS_load (&retmsg, &lGRID),
            targetid = my_id);

        if (me->nMaxSym > 0)
          me->nCurSym = 0;
        else
          me->nCurSym = -1;

        if (me->My_Type == VD_CMD_ADS_REV) break;

        VD_DLO_SetIndx (me->SSid_tab.Userid, me->SSid_tab.Timest,
                         &me->SSid_tab.Local, &me->SSid_tab.LcUnit);
      }
      break;

    case VD_ADSYM_FLD_DESCR:
      if (me->My_Type == VD_CMD_ADS_REV) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      strcpy (me->SSid_tab.Shdesc, szFld);
      break;

    case VD_ADSYM_FLD_COPY:
      if (me->My_Type == VD_CMD_ADS_REV) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      if (me->My_stored_lo.objid != NULL_OBJID)
      {   /*    already one active, save or reset first  */
        strcpy (szmsg, VD_ADS_EMSG_NACT);
        break;
      }

      status = VD_adsym_getid (&retmsg, szFld, &lGRID);

      if (lGRID.objid == NULL_OBJID)
      {
        sprintf (szmsg, VD_ADS_EMSG_NSYM, szFld);
        break;
      }

      strcpy (Local.Timest, me->SSid_tab.Timest);
      strcpy (Local.Userid, me->SSid_tab.Userid);

      status =
      om$send (msg = message VDCmdADS.VDADS_load (&retmsg, &lGRID),
          targetid = my_id);

      strcpy (me->SSid_tab.Tabnam, me->CUR_tabnam);
      strcpy (me->SSid_tab.Timest, Local.Timest);
      strcpy (me->SSid_tab.Userid, Local.Userid);

      me->My_stored_lo.objid = NULL_OBJID;
      me->My_stored_lo.osnum = lGRID.osnum;

      if (me->nMaxSym > 0)
        me->nCurSym = 0;
      else
        me->nCurSym = -1;

      sprintf (szmsg, VD_ADS_EMSG_COPY, szFld, me->CUR_tabnam);
      break;

/* ------------------------------  DATA GADGETS --------------------------- */

     case VD_ADSYM_FLD_FLAG:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0 ) break;

	FIg_get_text(form_ptr, gadget_label,szFld );

	if (!strncmp(szFld,"Text",4)) {
	   me->Ladsrec[me->nCurSym].nDattyp = 0;
	   strcpy (me->Ladsrec[me->nCurSym].font, "default");
	   strcpy (me->Ladsrec[me->nCurSym].Symbol, " ");
	   me->defrec.dCharhgt = 0.1;
  	   me->defrec.dCharwdt = 0.1;
           me->Ladsrec[me->nCurSym].dCharwdt = 0.1;
	   me->Ladsrec[me->nCurSym].dCharhgt = 0.1;
	}
	else{
	        me->defrec.dCharhgt = 0.0;
  	        me->defrec.dCharwdt = 0.0;
                me->Ladsrec[me->nCurSym].dCharwdt = 0.0;
	        me->Ladsrec[me->nCurSym].dCharhgt = 0.1;

		if (!strncmp(szFld,"Cell",4)) {
		   me->Ladsrec[me->nCurSym].nDattyp = VD_DRWLO_EN_CELL ;
		 }
		else if (!strncmp(szFld,"Symbol",6)) {
			me->Ladsrec[me->nCurSym].nDattyp =  VD_DRWLO_EN_SYMBOL;
		      }

        /*  Get the active library  */

        gr$symget_asl_info( msg = &ret_msg, file = &file);
	if ( ret_msg == GR_I_NOSL ) file.file_name[0] = '\0' ; 

        /* Modified by Ming for TR179900709 */
        {
          char *new_file_name = NULL;

          new_file_name = strrchr( file.file_name, '/' );
          if( new_file_name )
          {
            new_file_name++;
            strcpy( me->Ladsrec[me->nCurSym].font, new_file_name );
          }
          else
            strcpy( me->Ladsrec[me->nCurSym].font , file.file_name );
        }

        /* Commented by Ming
        strcpy( me->Ladsrec[me->nCurSym].font, file.file_name);
        */

	if ( ret_msg == GR_I_NOSL)
		strcpy( szmsg," Active Library not defined");

        /*  for the active cell */

	if ( ret_msg == MSSUCC){
        gr$symget_active_symbol (msg = &ret_msg,
                   act_symbol_def = &active_symbol);
        if(ret_msg == MSSUCC)
                strcpy( me->Ladsrec[me->nCurSym].Symbol,active_symbol.name);
        else me->Ladsrec[me->nCurSym].Symbol[0] = '\0';

	cell = NULL;
        /* for the cells in the library */

        gr$get_cell_def_info( p_count = &cell_count,
                        pp_names = &cell);

        if(cell_count == 0 )
	    strcpy (szmsg, " Cells not defined in the library \n");

        null[0] = '\0';

        FIfld_get_list_num_rows( form_ptr, VD_ADSYM_FLD_SYMSTR,0, &rows );
 
     for (i=0; i<rows; i++) {
        VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_SYMSTR, i, 0,
                        null, Selflag);
      }


     if (cell_count > 5)
        FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_SYMSTR, 1, 0);
     else
        FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_SYMSTR, 0, 0);

     for (i=0; i<cell_count; i++) {
       VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_SYMSTR, i, 0,
               &cell[MAX_SYMBOL_DEF_NAME * i], Selflag);
	}
     if(cell !=NULL) free(cell);

	   }
	}/* for else */
	break;


    case VD_ADSYM_FLD_CURENT:
      if ((nLocval < 1) || (nLocval > me->nMaxSym))
      {
        strcpy (szmsg, VD_ADS_EMSG_PAR);
        break;
      }

      me->nCurSym = nLocval - 1;
      break;

    case VD_ADSYM_BTN_DOWN:
      if (me->My_Type == VD_CMD_ADS_REV)
      {
        if (me->nCurSym > 0) me->nCurSym--;
      }
      else
      {
        if (me->nCurSym >= 0) me->nCurSym--;
      }
#ifdef MY_DEBUG
        printf (" down Current rec %d\n",me->nCurSym);
#endif
      break;

    case VD_ADSYM_BTN_UP:
      if (me->nCurSym < (me->nMaxSym-1)) me->nCurSym++;
#ifdef MY_DEBUG
        printf (" up Current rec %d\n",me->nCurSym);
#endif
      break;

    case VD_ADSYM_BTN_INSERT:
      if (me->My_Type == VD_CMD_ADS_REV) break;

      status =
      om$vla_set_dimension (varray = me->Ladsrec,
                            size   = (me->nMaxSym+1));

      for (i=(me->nMaxSym); i>(me->nCurSym+1); i--)
      {
        VD_ADS_move (&(me->Ladsrec[i]), &(me->Ladsrec[i-1]));

#ifdef MY_DEBUG
        printf (" move %d to %d for insert \n", i+1,i);
#endif
      }

      (me->nMaxSym)++;
      (me->nCurSym)++;
#ifdef MY_DEBUG
      printf (" after insert, max,cur %d %d\n",me->nMaxSym,me->nCurSym);
#endif

      VD_ADS_move (&(me->Ladsrec[me->nCurSym]), &(me->defrec));

      break;

    case VD_ADSYM_BTN_DELETE:
      if (me->My_Type == VD_CMD_ADS_REV) break;

      if (me->nCurSym < 0) break;

      for (i=me->nCurSym; i<(me->nMaxSym-1); i++)
      {
#ifdef MY_DEBUG
        printf ("delete, move %d to %d\n",i+1,i);
#endif

        VD_ADS_move (&(me->Ladsrec[i]), &(me->Ladsrec[i+1]));

      }

      status =
      om$vla_set_dimension (varray = me->Ladsrec,
                            size   = (me->nMaxSym-1));

      (me->nMaxSym)--;
      (me->nCurSym)--;
      break;


    case VD_ADSYM_FLD_TEXT:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

	FIg_get_text (form_ptr, gadget_label,me->Ladsrec[me->nCurSym].Symbol);
	break;

    case VD_ADSYM_FLD_SYMSTR:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

	FIg_get_text (form_ptr, gadget_label, szFld);
	if (szFld[0] == '\0') break;
	strcpy( me->Ladsrec[me->nCurSym].Symbol,szFld);

        sts = gr$symsd_locate_in_all_sl ( msg = &ret_msg,
                     sd_name = me->Ladsrec[me->nCurSym].Symbol,sl_env = &sl_env,
                     sd_id = &symbol_id);
        if( ret_msg == MSFAIL) {
	    me->Ladsrec[me->nCurSym].Symbol[0] = '\0';
		 strcpy(szmsg,"Symbol Not Defined");
		 break;
	 } 
	else if (ret_msg == MSSUCC) {

        	sts = gr$symput_active_symbol ( msg = &ret_msg,
                     symbol_name = me->Ladsrec[me->nCurSym].Symbol,
			 symbol_id = &symbol_id,
                     asl_env = &sl_env);
        	if(!( ret_msg & 1))break;
	     }
      break;

    case VD_ADSYM_FLD_ATTNAM:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      FIg_get_text (form_ptr, gadget_label,me->Ladsrec[me->nCurSym].szAtt);
      break;

    case VD_ADSYM_FLD_ATVASC:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      FIg_get_text (form_ptr, gadget_label,me->Ladsrec[me->nCurSym].szAttval);
      break;

    case VD_ADSYM_FLD_ATVNUM:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      me->Ladsrec[me->nCurSym].dAttval = dLocval;

      /* tlb - ADDED  to ensure that szAttval has a non-null value. */
      sprintf (me->Ladsrec[me->nCurSym].szAttval, "%g",dLocval);
      break;

    case VD_ADSYM_FLD_OFFSET:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      me->Ladsrec[me->nCurSym].dOffset = dLocval;
      break;

    case VD_ADSYM_FLD_CHHGT:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      if (dLocval <= 0)
      {
        strcpy (szmsg, VD_ADS_EMSG_PAR);
        break;
      }

      me->Ladsrec[me->nCurSym].dCharhgt = dLocval;
      break;

    case VD_ADSYM_FLD_CHWDT:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      if( (me->Ladsrec[me->nCurSym].nDattyp == VD_DRWLO_EN_CELL) ||
          (me->Ladsrec[me->nCurSym].nDattyp == VD_DRWLO_EN_SYMBOL) )
      {
        if( dLocval < 0 )
          {
            strcpy( szmsg, VD_ADS_EMSG_PAR );
            break;
          }
      }
      else
      {
        if( dLocval <= 0 )
          {
            strcpy( szmsg, VD_ADS_EMSG_PAR );
            break;
          }
      }

      me->Ladsrec[me->nCurSym].dCharwdt = dLocval;
      break;

    case VD_ADSYM_FLD_CHSPC:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      if (dLocval <= 0)
      {
        strcpy (szmsg, VD_ADS_EMSG_PAR);
        break;
      }

      me->Ladsrec[me->nCurSym].dCharspc = dLocval;
      break;

    case VD_ADSYM_FLD_CHWGT:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      if ((dLocval < 0) || (dLocval > 31))
      {
        strcpy (szmsg, VD_ADS_EMSG_PAR);
        break;
      }

      me->Ladsrec[me->nCurSym].nCharwgt = (IGRshort)(dLocval + 0.001);
      break;

    case VD_ADSYM_FLD_CHFONT:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;
      strcpy (me->Ladsrec[me->nCurSym].font, szFld);
      break;

    case VD_ADSYM_FLD_LIBRY:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;
      
      /* Commented by Ming for TR179900709
      if(!strcmp(szFld, me->Ladsrec[me->nCurSym].font))  break; 
      */

      /* Added by Ming for TR179900709 */
      {
        char *new_file_name = NULL;
        char firstDir[1024];
        char absPathName[1024];

        tmpFld[0] = '\0';
        strcpy( tmpFld, szFld );
        new_file_name = strrchr( szFld, '/' );

        if( !new_file_name )
        {
          firstDir[0] = absPathName[0] = '\0';
          strcpy( firstDir, "." );

          status =
          vd$file_path( msg = &retmsg,
                        fileToFind = szFld,
                        dirToSearchFirst = firstDir,
                        dirInProdPathToSearchThen = VD_DLO_CELL_CONFIG_RELPATH,
                        absPathName = absPathName );

          if( status&retmsg&1 )
            strcpy( szFld, absPathName );
	  else
	  {
	    strcpy( szmsg, "Can't find cell library!" );
	    break;
	  }
        }
      }

        sts = gr$symretrieve_cell_library (
                filename = szFld,
                file_no = &file.file_no,
                flag = EX_read_write | EX_read_only,
                fstat = EX_old_module);

        if (sts == GR_E_NO_FILE) {
		strcpy(szmsg,"File Does Not Exist");
                break;
                }
        else if (sts == GR_E_NOT_CELL_LIB) {
		strcpy(szmsg,"File Not A Cell Library");
                break;
                }
                else if (sts == GR_E_NO_PREMISSION) {
		strcpy(szmsg,"No Permission for Operation");
                break;
                }
            else if( !(sts & 1)) break;

	strcpy(file.file_name,szFld);

        sts = gr$symput_asl ( msg = &ret_msg,
                     file = &file);

	/* Added by Ming for TR179900709 */
        strcpy( szFld, tmpFld );

	strcpy (me->Ladsrec[me->nCurSym].font, szFld);

	gr$symget_active_symbol (msg = &ret_msg,
                   act_symbol_def = &active_symbol);
	if(ret_msg == MSSUCC)
                strcpy( me->Ladsrec[me->nCurSym].Symbol,active_symbol.name);
        else  me->Ladsrec[me->nCurSym].Symbol[0] = '\0'; 

	/* for the cells in the library */
 	cell = NULL;
	gr$get_cell_def_info( p_count = &cell_count,
                        pp_names = &cell);

        null[0] = '\0';

        FIfld_get_list_num_rows( form_ptr, VD_ADSYM_FLD_SYMSTR,0, &rows );

     for (i=0; i<rows; i++) {
        VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_SYMSTR, i, 0,
                        null, Selflag);
      }


     if (cell_count > 5)
        FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_SYMSTR, 1, 0);
     else
        FIfld_set_list_scroll (form_ptr, VD_ADSYM_FLD_SYMSTR, 0, 0);

     for (i=0; i<cell_count; i++) {
       VDfld_set_list_text (form_ptr, VD_ADSYM_FLD_SYMSTR, i, 0,
               &cell[MAX_SYMBOL_DEF_NAME * i], Selflag);
	}
     if(cell != NULL) free(cell);


	break;

    case VD_ADSYM_TGG_ATTTYP:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      me->Ladsrec[me->nCurSym].nDattyp = 1 - me->Ladsrec[me->nCurSym].nDattyp;
      break;

    case VD_ADSYM_TGG_PLACE:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      me->Ladsrec[me->nCurSym].nnSide = 1 - me->Ladsrec[me->nCurSym].nnSide;
      break;

    case VD_ADSYM_FLD_RELTYP:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      for (i=0; i<me->nNumComp; i++)
      {
        idsp = i * VD_ADSYM_STL_COMPAR;
        if (strcmp (&me->pCompar[idsp], szFld) == 0)
        {
          iSet = i;
          break;
        }
      }

      if (iSet < 0)
        strcpy (szmsg, VD_ADS_EMSG_INV);
      else
      {
        me->Ladsrec[me->nCurSym].nnREL = i;

        if (iSet == VD_cnt_qry_NONE)
        {
          me->Ladsrec[me->nCurSym].dAttval = 0;
          me->Ladsrec[me->nCurSym].szAttval[0] = '\0';

          /* yzhu - MODIFIED
           don't erase the attribute name 
           me->Ladsrec[me->nCurSym].szAtt[0]    = '\0';
           */
        }
      }
      break;

    case VD_ADSYM_BTN_DEFAULT:
      if (me->My_Type == VD_CMD_ADS_REV) break;
      if (me->nCurSym < 0) break;

      VD_ADS_move (&(me->defrec), &(me->Ladsrec[me->nCurSym]));

      me->defrec.Symbol[0]   = '\0';
      me->defrec.szAtt[0]    = '\0';
      me->defrec.szAttval[0] = '\0';

      me->defrec.nnREL       = VD_cnt_qry_NONE;
      break;

/* ------------------------  CONTROL BAR GADGETS --------------------------- */

    case FI_ACCEPT:
    case FI_EXECUTE:
      if (me->My_Type == VD_CMD_ADS_REV) break;

      if (me->CUR_tabnam[0] == '\0')
      {
        strcpy (szmsg, VD_ADS_EMSG_NTAB);
        break;
      }

      status =
      om$send (msg = message VDADS.VDADS_check  (&retmsg, &iSet),
          targetid = my_id);

      if (retmsg != MSSUCC)
      {
        me->nCurSym = iSet;
        strcpy (szmsg, VD_ADS_EMSG_NSV);
        break;
      }

      status = 
      om$send (msg = message VDCmdADS.VDADS_Save  (&retmsg),
          targetid = my_id);

    /*      fall through    */

    case FI_CANCEL:
      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
#ifdef MY_DEBUG
      printf (" EXFORM response\n");
#endif
      break;

      /*    fall through into reset    */

    case FI_RESET:
      status =
      om$send (msg = message VDCmdADS.VDADS_Reset (&retmsg),
          targetid = my_id);

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
#ifdef MY_DEBUG
      printf (" EXFORM response\n");
#endif
      break;

    default:
#ifdef MY_DEBUG
      printf (" ERROR edit unknown gadget %d\n", gadget_label);
#endif
      goto quit;
  }

  FIg_set_text (form_ptr, VD_ADSYM_FLD_MSG, szmsg);

  status =
  om$send (msg = message VDCmdADS.VDADS_disp (form_ptr),
      targetid = my_id);

  quit:
  return (status);
}

end implementation VDCmdADS;

