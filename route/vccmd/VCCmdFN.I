/* $Id: VCCmdFN.I,v 1.3 2002/05/08 15:48:23 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdFN.I
 *
 * Description:
 *
 * Implementation file for VCCmd form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdFN.I,v $
 *      Revision 1.3  2002/05/08 15:48:23  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.2  2001/02/20 01:09:28  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *      Initial import to CVS
 *
# Revision 1.4  1998/12/22  17:00:28  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by lawaddel for route
#
# Revision 1.3  1998/06/24  19:10:00  pinnacle
# tr179801131
#
# Revision 1.2  1998/06/15  20:08:54  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by lawaddel for route
#
# Revision 1.4  1998/02/20  05:35:52  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by apazhani for route
#
# Revision 1.3  1998/02/19  06:08:38  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by apazhani for route
#
# Revision 1.2  1997/11/30  16:08:02  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by r250_int for route
#
# Revision 1.19  1997/11/10  11:25:26  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by apazhani for cabling
#
# Revision 1.18  1997/10/14  10:15:36  pinnacle
# Replaced: vccmd/VCCmdFN.I for: CR 179701618 by aharihar for cabling
#
# Revision 1.17  1997/07/29  15:03:20  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.16  1997/07/22  16:04:36  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.15  1997/07/14  22:51:06  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.14  1997/05/22  14:44:46  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.13  1997/05/19  14:07:32  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.12  1997/05/07  14:16:10  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.11  1997/01/31  18:14:06  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.10  1997/01/31  00:07:26  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.9  1997/01/09  20:01:34  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.7  1996/12/18  17:48:16  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.6  1996/10/30  15:28:20  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.5  1996/10/25  14:33:28  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/09  22:03:52  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/08  22:00:02  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/26  21:19:28  pinnacle
# Replaced: vccmd/VCCmdFN.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:13:40  pinnacle
# Created: vccmd/VCCmdFN.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/20/96          HV            New
 *      10/14/97        Anand           CR 179701618 - Implements search
 *					capability in fields with associative
 *					lists.
 *      11/10/97        Alwin           TR179702063. Checked the freeing process
 *                                      and set the freed pointers to NULL.
 *  	02/20/98    	Alwin   	Check has been made whether the user 
 *					keys in search string or picking it 
 *					from the associative list. If user 
 *					picks the compdoe from list, don't call 
 *					the search algorithm. TR179800042
 *      06/10/98        law             Repair of TR179800042.
 *      06/12/98        law             Always search in master list.
 *      12/02/98        law             CR179802404-rotatation in form field
 * -------------------------------------------------------------------*/

class implementation VCCmdParam;

#include "VDfrm.h"

#include <stdlib.h>
#include <string.h>  /* Added by Anand for CR 179701618 */

#include "vc_param.h"    /* 	CR179802404 */
#include "OMprimitives.h"
#include "igetypedef.h"
#include <math.h>    /* Added by law for CR179802404 */
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
#include "VDmem.h"
#include "vrdbgmacros.h"

#include "VCTagDef.h"
#include "VCCmdForm.h"
#include "VCCmdCAT.h"
#include "VCproto.h"

from	ACrg_collect	import	ACshow_data; /* for debugging */
/*
#define   MY_DEBUG
*/


#define   VC_FRM_MESSAGE_FIELD         9 /* Added by law for TR179800042 */

method form_notification ( int         form_label ;
                           int         gadget_label ;
                           double      value ;
                           char      * form_ptr )
{
  int       retmsg;
  int       status;

  me->szMsg[0] = '\0';
  me->My_localret = 0;

#ifdef MY_DEBUG
  printf (" formnot label = %d\n",form_label);
#endif

  switch (form_label)
  {
    case VC_FRM_MAIN:
      status =
      om$send (msg = message VCCmdParam.VCFN_main
                             (gadget_label, value, form_ptr),
          targetid = my_id);
      break;

    case VC_FRM_SUB:
      status =
      om$send (msg = message VCCmdParam.VCFN_sub
                             (gadget_label, value, form_ptr),
          targetid = my_id);
#ifdef MY_DEBUG
  printf (" from fn_sub = %d\n",form_label);
#endif

      break;

    default:
      status = OM_S_SUCCESS;
      break;
  }

#ifdef MY_DEBUG
  printf (" formnot to disp = %d\n",form_label);
#endif

  status =
  om$send (msg = message VCCmdParam.VCCmdDisp (&retmsg, form_label),
      targetid = my_id);


#ifdef MY_DEBUG
  printf (" formnot done\n");
#endif

  return (status);
}


method  VCFN_sub   (int      gadget_label;
                    double   value;
                    char    *form_ptr)

{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       row, num_rows;
  IGRint       nAtt;
  IGRint       length;
  IGRint       len1;
  IGRint       sel_flag, r_pos;
  IGRchar      szValue[VC_CMD_BUFSIZE];
  IGRchar      szText[VC_CMD_BUFSIZE];

  switch (gadget_label)
  {

    case VCCAT_MFL_USRPAR:
      FIfld_get_num_rows( form_ptr, VC_GDG_MFL_USERPAR, &num_rows );

      nAtt = 0;
      status =
      om$send (msg = message VCAT.VCAT_set
                                  (&retmsg, VC_USER, NULL,
                                      AC_ATTRIB_TEXT, NULL, 0.0),
          targetid = my_id);
      for ( row=0; row<num_rows; row++ )
      {
        /* Get name's length */
        length = len1 = 0;
        FIfld_get_text_length (form_ptr, VC_GDG_MFL_USERPAR, row, 0, &length);
        FIfld_get_text_length (form_ptr, VC_GDG_MFL_USERPAR, row, 1, &len1);

        if (length > 1)
        {
          FIfld_get_text( form_ptr, VC_GDG_MFL_USERPAR, row, 0, length,
                          (unsigned char *) szText, &sel_flag, &r_pos );

          FIfld_get_text( form_ptr, VC_GDG_MFL_USERPAR, row, 1, len1,
                          (unsigned char *) szValue, &sel_flag, &r_pos );

          status =
          om$send (msg = message VCAT.VCAT_set
                                  (&retmsg, VC_USER, szText,
                                     AC_ATTRIB_TEXT, szValue, 0.0),
              targetid = my_id);

          nAtt++;
        }
      }
      break;

    case FI_RESET:
      FIfld_set_num_rows( form_ptr, VC_GDG_MFL_USERPAR, 0);
      break;

    case FI_EXECUTE:
    case FI_ACCEPT:
      FIfld_get_num_rows( form_ptr, VC_GDG_MFL_USERPAR, &num_rows );

      nAtt = 0;
      status =
      om$send (msg = message VCAT.VCAT_set
                                  (&retmsg, VC_USER, NULL, 
                                      AC_ATTRIB_TEXT, NULL, 0.0),
          targetid = my_id);

      for ( row=0; row<num_rows; row++ )
      {
        /* Get name's length */
        length = len1 = 0;
        FIfld_get_text_length (form_ptr, VC_GDG_MFL_USERPAR, row, 0, &length);
        FIfld_get_text_length (form_ptr, VC_GDG_MFL_USERPAR, row, 1, &len1);

        if (length > 1)
        {
          FIfld_get_text( form_ptr, VC_GDG_MFL_USERPAR, row, 0, length,
                          (unsigned char *) szText, &sel_flag, &r_pos );

          FIfld_get_text( form_ptr, VC_GDG_MFL_USERPAR, row, 1, len1,
                          (unsigned char *) szValue, &sel_flag, &r_pos );

          status =
          om$send (msg = message VCAT.VCAT_set
                                  (&retmsg, VC_USER, szText, 
                                     AC_ATTRIB_TEXT, szValue, 0.0),
              targetid = my_id);

          nAtt++;
        }
      }

      FIg_set_state_off (form_ptr, gadget_label);

    case FI_CANCEL:
      FIg_set_state_off (me->pSysAtt, VC_GDG_BTN_USRPAR);
      FIg_set_state_off (me->pSysAtt, VC_GDG_BTN_LOADATT);

      VC_Cmd_form_close (form_ptr, me->FCsub);

      me->bUsrUp = FALSE;

      _put_response( resp = EX_FORM_FINISHED);
      break;

    default:
      /*    form will keep until exit   */
      break;
  }

  quit:
  return (OM_S_SUCCESS);
}

method  VCFN_main  (int      gadget_label;
                    double   value;
                    char    *form_ptr)

{
  IGRlong      retmsg;
  IGRint       status;
  IGRint       ret;
  IGRint       i, idsp, jdsp;
  IGRint       iType;
  IGRshort     nST;
  IGRchar      szFld[VC_CMD_BUFSIZE];

  extern IGRboolean   VD_TBL_idquote (IGRchar   *szFld);

  SetProc( Md VCFN_main ); Begin 

  status   = OM_S_SUCCESS;

  FIfld_get_type (form_ptr, gadget_label, 0, &iType);
  if (iType == FI_ALPHA)
  {
    FIg_get_text (form_ptr, gadget_label, szFld);
    szFld[VC_CMD_BUFSIZE-1] = '\0';
  }

  FIg_set_text (form_ptr, VC_FRM_MESSAGE_FIELD, ""); /* -law-TR179800042 */
  szFld[VC_CMD_BUFSIZE-1] = '\0';

  switch (gadget_label)
  {
    case VC_GDG_FLD_TAGNUMBER:
      if (szFld[0] == '\0') break;
      szFld[VC_MAX_TAGNO-1] = '\0';

      __DBGpr_str( " Entered TagNumber ", szFld );

      status = VC_TAGchk (&nST, me->nTagCat, szFld);

      __DBGpr_int( " Does this TagNumber exist already ?", nST );

      if (nST < 0)
      {
        strcpy (me->TagNum, szFld);
        strcpy (me->szMsg, "  ");
      }
      else
      {
        strcpy (me->szMsg, "Duplicate Tag Number");
        me->TagNum[0] = '\0';
      }
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_FLD_COMPCODE:
      {
        /* Large block deleted/replaced by law for TR179800042 */
        int new_list_cnt,sel_index,longest_text;
        IGRchar      szText[VC_CMD_BUFSIZE];
        int sel_flag=0,r_pos,length;
        int unique_flg;

        status = VDfrm_fld_set_sub_list(  form_ptr,
                                VC_GDG_FLD_COMPCODE,
                                VC_FRM_MESSAGE_FIELD,
                                me->CClist,
                                VC_MAX_CCODE,
                                me->nCC,
                                &new_list_cnt,
                                0,
                                &sel_index,
                                &unique_flg   );

        /* The form preprocessor uses  me->CompCode to reset the field */
        FIfld_get_text_length (form_ptr, VC_GDG_FLD_COMPCODE, 0, 0, &length);
        FIfld_get_text( form_ptr, VC_GDG_FLD_COMPCODE, 0, 0, length,
                          (unsigned char *) szText, &sel_flag, &r_pos );
        strcpy(me->CompCode,szText);
        if(unique_flg)
        {
          FIg_enable(form_ptr,FI_EXECUTE);
          FIg_enable(form_ptr,FI_ACCEPT);

          jdsp = sel_index * VC_MAX_SDESC;

          strcpy (me->CompDesc, &me->CCdesc[jdsp]);

              if (me->iSynType == VC_CMDTYP_GEN)
              {   /*   for general command set product etc...   */
                if (sel_index >= me->nFOstart)
                {
                  me->Product = VC_PROD_FO;
                  me->nTagCat = VCTAG_CAT_FOTERM;
                }
                else
                {
                  me->Product = VC_PROD_ELEC;
                  me->nTagCat = VCTAG_CAT_ELTERM;
                }
              }
        }
      }
      break; /* End of case VC_GDG_FLD_COMPCODE */

/* ------------------------------------------------------------ */

    case VC_GDG_FLD_ADDLABEL:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_ADD_LABEL_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_FLD_UNITNUMBER:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_UNIT_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_FLD_SYSNUMBER:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_SYST_NAME_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_FLD_CHGNO:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_CHG_REQ_NUM_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_FLD_APPSTAT:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_APPRV_STAT_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_FLD_CONSTR:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_CONSTR_STAT_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_FLD_NOTES:
      szFld[VC_MAX_NOTES-1] = '\0';

      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_COMP_NOTE_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

/* ------------------------------------------------------------ */
   /* Probably not necessary for CR179802404, but inserted for completeness */

    case VCFORM_GDG_AROT:
      break;

/* ------------------------------------------------------------ */


    case VC_GDG_FLD_SCALE:
      FIg_get_value (form_ptr, VC_GDG_FLD_SCALE, &(me->dPScale));

      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_PID_SCALE_DB, 
                                    AC_ATTRIB_DOUBLE, NULL, me->dPScale),
          targetid = my_id);
      break;


/* ------------------------------------------------------------ */

    case VC_GDG_CHK_NOMTO:
      me->bMTO = !(me->bMTO);
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_TGG_NOCODE:
      me->bGdcode = 1 - me->bGdcode;

      if (me->bGdcode)
      {
         FIg_erase   (form_ptr, VC_GDG_TXT_COMPCODE);
         FIg_erase   (form_ptr, VC_GDG_FLD_COMPCODE);
         FIg_display (form_ptr, VC_GDG_TXT_DIAMETER);
         FIg_display (form_ptr, VC_GDG_FLD_DIAMETER);
         me->dDiameter = 0;
         FIg_set_value (form_ptr, VC_GDG_FLD_DIAMETER, me->dDiameter);
         me->CompCode[0] = '\0';
      }
      else
      {
         FIg_erase   (form_ptr, VC_GDG_TXT_DIAMETER);
         FIg_erase   (form_ptr, VC_GDG_FLD_DIAMETER);
         FIg_display (form_ptr, VC_GDG_TXT_COMPCODE);
         FIg_display (form_ptr, VC_GDG_FLD_COMPCODE);
         me->CompCode[0] = '\0';
         FIg_set_text (form_ptr, VC_GDG_FLD_COMPCODE, me->CompCode);
      }

/* ------------------------------------------------------------ */

    case VC_GDG_FLD_DIAMETER:
      FIg_get_value (form_ptr, VC_GDG_FLD_DIAMETER, &me->dDiameter);
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_BTN_USRPAR:
      VC_Cmd_form_open (me->pUsrAtt, me->FCsub);

      me->bUsrUp = TRUE;

      status =
      om$send (msg = message VCCmdParam.VCCmdDisp (&ret, VC_FRM_SUB),
          targetid = my_id);

      me->My_localret = VC_RTC_BTN_USRPAR;
      _put_response( resp = VC_RTC_BTN_USRPAR );
      break;

/* ------------------------------------------------------------ */

    case VC_GDG_BTN_LOADATT:
      me->My_localret = VC_RTC_BTN_LOADATT;
      _put_response( resp = VC_RTC_BTN_LOADATT );
      break;

/* ------------------------------------------------------------ */

    case FI_ACCEPT:
      if ((VC_EMPTYSTR(me->TagNum)) && (me->CommGadget != VC_GDG_CMD_BKSH))
      {
        strcpy (me->szMsg, "Missing Tag Number");
        /* law- Added message field for TR179800042 */
        FIg_set_text (form_ptr, VC_FRM_MESSAGE_FIELD, me->szMsg);
        break;
      }

      if ((VC_EMPTYSTR(me->CompCode)) && (!me->bGdcode))
      {
        strcpy (me->szMsg, "Missing Component Code");
        /* law- Added message field for TR179800042 */
        FIg_set_text (form_ptr, VC_FRM_MESSAGE_FIELD, me->szMsg);
        break;
      }


      /* CR179802404 - Get rotation angle from form */
      {
         IGRint ang;
         IGRdouble dang;
      dang = 0.0;
      FIg_get_value (form_ptr, VCFORM_GDG_AROT, &dang);
      ang = (IGRint) dang;
      while (ang >= 360)
      {
        ang -= 360;
      }
      dang = (IGRdouble) ang;
      __DBGpr_int("angle stored \n",ang);
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_PID_ANGLE_DB, 
                                    AC_ATTRIB_DOUBLE, NULL, dang),
          targetid = my_id);
      /*  store values     set up attrboxes   */
      status =
      om$send (msg = message VCAT.VCAT_sav (&retmsg),
          targetid = my_id);
      /********** DEBUG PRINT
      {
         IGRlong status=OM_S_SUCCESS, retcode=MSFAIL;
         __DBGpr_obj("sys_coll_id ", me->SysCId );

         status = om$send( msg = message ACrg_collect.ACshow_data( &retmsg ),
                    senderid = NULL_OBJID,
                    targetid = me->SysCId.objid,
                    targetos = me->SysCId.osnum );
         as$status( action = RET_STATUS );

      }
      ************/

      } /* End add for CR179802404 */

      VC_Cmd_form_close (form_ptr, me->FCmain);
      me->bTERM = TRUE;
      me->bSysUp = FALSE;

      me->My_localret = VC_RTC_DONE;
      _put_response( resp = EX_FORM_FINISHED );
      break;

/* ------------------------------------------------------------ */

    case FI_EXECUTE:
      if ((VC_EMPTYSTR(me->TagNum)) && (me->CommGadget != VC_GDG_CMD_BKSH))
      {
        strcpy (me->szMsg, "Missing Tag Number");
        /* law- Added message field for TR179800042 */
        FIg_set_text (form_ptr, VC_FRM_MESSAGE_FIELD, me->szMsg);
        break;
      }

      if ((VC_EMPTYSTR(me->CompCode)) && (!me->bGdcode))
      {
        strcpy (me->szMsg, "Missing Component Code");
      /* law- Added message field for TR179800042 */
        FIg_set_text (form_ptr, VC_FRM_MESSAGE_FIELD, me->szMsg);
        break;
      }
      if (me->CommGadget == VC_GDG_CMD_BKSH ||
          me->CommGadget == VC_GDG_CMD_GENTERM)
      /* CR179802404 - Get rotation angle from form */
      {
         IGRint ang;
         IGRdouble dang;
      FIg_get_value (form_ptr, VCFORM_GDG_AROT, &dang);
      ang = (IGRint) dang;
      while (ang >= 360)
      {
        ang -= 360;
      }
      dang = (IGRdouble) ang;
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_PID_ANGLE_DB, 
                                    AC_ATTRIB_DOUBLE, NULL, dang),
          targetid = my_id);
      __DBGpr_dbl("store rotation angle",dang);
      __DBGpr_int("store collection for ",my_id);
      /*  store values     set up attrboxes   */
      status =
      om$send (msg = message VCAT.VCAT_sav (&retmsg),
          targetid = my_id);
      }
      me->My_localret = VC_RTC_ACCEPT;
      _put_response( resp = EX_FORM_FINISHED );
      break;

/* ------------------------------------------------------------ */

    case FI_RESET: /* Modified for CR179802404 (rotate terminals/connectors */
      /*  reset all values, discard active coll   */

      FIg_set_value (form_ptr, VCFORM_GDG_AROT, 0.0);
      me->My_localret = VC_RTC_RESET;
      _put_response( resp = EX_FORM_FINISHED );
      break;

/* ------------------------------------------------------------ */

    case FI_CANCEL:
      VC_Cmd_form_close (form_ptr, me->FCmain);
      me->bSysUp = FALSE;

      me->My_localret = VC_RTC_CANCEL;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    default:
      sprintf (me->szMsg," ERROR edit unknown gadget %d\n", gadget_label);
      /* law- Added message field for TR179800042 */
      FIg_set_text (form_ptr, VC_FRM_MESSAGE_FIELD, me->szMsg);
      break;
  }

  quit:
  End
  return (status);
}

end implementation VCCmdParam;

