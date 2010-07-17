
/* $Id: VCSAFN.I,v 1.4 2002/05/08 15:48:23 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCSAFN.I
 *
 * Description:
 *
 * Implementation file for VCSA form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCSAFN.I,v $
 *      Revision 1.4  2002/05/08 15:48:23  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.3  2001/02/20 01:09:58  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/26 22:42:29  louis
 *      TR4437
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *      Initial import to CVS
 *
# Revision 1.6  1999/04/19  19:07:26  pinnacle
# Modified the form_notification to perform a check for the Object being procesed
#
# Revision 1.5  1999/01/28  05:08:58  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by apazhani for route
#
# Revision 1.4  1998/12/22  17:03:10  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by lawaddel for route
#
# Revision 1.3  1998/06/24  19:10:00  pinnacle
# tr179801131
#
# Revision 1.2  1998/06/15  20:09:32  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by lawaddel for route
#
# Revision 1.5  1998/02/20  05:37:20  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by apazhani for route
#
# Revision 1.4  1998/02/19  06:07:58  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by apazhani for route
#
# Revision 1.3  1998/02/06  10:48:50  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by apazhani for route
#
# Revision 1.2  1997/11/30  16:07:56  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by r250_int for route
#
# Revision 1.9  1997/11/27  16:39:06  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by onayragu for cabling
#
# Revision 1.8  1997/11/10  11:15:22  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by apazhani for cabling
#
# Revision 1.7  1997/10/14  10:12:20  pinnacle
# Replaced: vccmd/VCSAFN.I for: CR 179701618 by aharihar for cabling
#
# Revision 1.6  1997/09/11  20:52:32  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by apazhani for cabling
#
# Revision 1.5  1997/08/11  21:54:36  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by hverstee for cabling
#
# Revision 1.3  1997/08/05  22:52:28  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by hverstee for cabling
#
# Revision 1.2  1997/07/31  20:07:34  pinnacle
# Replaced: vccmd/VCSAFN.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/29  15:04:22  pinnacle
# Created: vccmd/VCSAFN.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/20/96          HV            New
 *      09/11/97          Alwin         Added case FENCE_DN, FENCE_UP and
 *                                      FENCE_FL, in method VCSAFN_main.
 *      10/14/97          Anand		CR 179701618 - Implements search
 *					capability in fields with
 *					associative lists.
 *      11/10/97          Alwin         TR 179702063-Checked the freeing process
 *                                      and set the freed pointers to NULL.
 *      02/06/98          Alwin         Updated the Component Description when
 *					the user changes the Component Code.
 *      02/18/98          Alwin         Tag Numbers are checked only when the
 *					Tag Number entered is different from
 *					that of the Component's. 
 *  	02/20/98    	  Alwin   	Check has been made whether the user 
 *					keys in search string or picking it 
 *					from the associative list. If user
 *                      		picks the compdoe from list, don't call
 *					the search algorithm. TR179800042
 *      06/10/98          law           Add call to VDfrm_fld_set_sub_list
 *                                      for TR179800042.
 *      06/24/98          ah            TR179801131 Unable to change comp code
 *      12/02/98          law           CR179802404 Get angle from form field.
 *      27/01/99          Alwin         Added an if condition to prevent the
 *					crash & getting executed for all the 
 *					objects.
 *      01/26/01	  law           TR4437-Offsets lost when replacing
 *                                      terminals
 * -------------------------------------------------------------------*/

class implementation VCCmdSA;

#include "VDfrm.h"

#include <stdlib.h>
#include <math.h>       /* Added for CR179802404 */
#include <string.h>	/* Added by Anand */

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"

%safe
#include "VX_FIproto.h"
%endsafe

#include "VRMcForm.h"

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
#include "VCproto.h"
#include "VCCmdSet.h"
#include "VCTagDef.h"

/*** VCGetInstance,VCSetInstance added for CR179802404 **/
from      ACncpx   import   ACgive_structure;
from      VCRoot   import   VCGetTagNo, VCGetInstance,VCSetInstance,VCGetType,VCSetType;

/*
#define   MY_DEBUG
*/


method form_notification ( int       form_label ;
                           int       gadget_label ;
                           double    value ;
                           char    * form_ptr )
{
  IGRint    status;

#ifdef MY_DEBUG
  printf("in form_notification %d form, %d gadget\n", form_label, gadget_label);
#endif


  switch (form_label)
  {
    case VC_FRM_MAIN:
      status =
      om$send( msg  = message VCCmdSA.VCSAFN_main (gadget_label),
           targetid = my_id);

      /* Update the Component Description when the user changes the Components
      Code. Alwin */
      if( gadget_label == VCSET_GDG_CCODE )
      {
         if( me->CompCode[0] != '\0' )
             FIg_set_text( form_ptr, VCSET_GDG_DESC, me->CompDesc );
      }
      break;

    case VC_FRM_SUB:
      status =
      om$send( msg  = message VCCmdSA.VCSAFN_sub (gadget_label),
           targetid = my_id);
      break;

    case VC_FRM_MORE:
    case VC_FRM_TCON:
    case VC_FRM_CCON:
      status =
      om$send( msg = message VCCmdSA.VCSAFN_util
                                  (form_label, gadget_label, form_ptr),
          targetid = my_id );
      break;

    default:
      break;
  }

  return OM_S_SUCCESS;
}

method  VCSAFN_util  (int      form_label;
                      int      gadget_label;
                      char    *form_ptr)
{
  IGRint    status;

  if (gadget_label == FI_CANCEL)
  {
    switch (form_label)
    {
      case VC_FRM_MORE:
        status = VC_Cmd_form_close (me->pMORE, VC_FPOS_SA_MORE);
        me->bSAmoreup = FALSE;

        FIg_set_state_off (me->pSysAtt, VCSET_GDG_CAB_MOREBTN);
        break;

      case VC_FRM_TCON:
        status = VC_Cmd_form_close (me->pTCON, VC_FPOS_SA_TCON);
        me->bSAtconup = FALSE;

        FIg_set_state_off (me->pSysAtt, VCSET_GDG_TERM_VCBTN);
        break;

      case VC_FRM_CCON:
        status = VC_Cmd_form_close (me->pCCON, VC_FPOS_SA_CCON);
        me->bSAcconup = FALSE;

        FIg_set_state_off (me->pSysAtt, VCSET_GDG_CABB_VCBTN);
        break;
    }
  }

  return OM_S_SUCCESS;
}

method  VCSAFN_sub   (int      gadget_label)
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
  IGRchar     *form_ptr;

  form_ptr = me->pUsrAtt;

  switch (gadget_label)
  {

    case VC_GDG_MFL_USERPAR:
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
      FIg_set_state_off (me->pSysAtt, VCSET_GDG_USERBTN);
      FIg_set_state_off (me->pSysAtt, VCSET_GDG_COPYBTN);

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

method  VCSAFN_main  (int      gadget_label)

{
  IGRlong      retmsg;
  IGRint       status;
  IGRint       i, idsp, jdsp;
  IGRint       iType;
  IGRshort     nST;
  IGRchar      szFld[VC_CMD_BUFSIZE];
  IGRchar      CompTag[VC_MAX_TAGNO];
  IGRchar     *form_ptr;
  IGRdouble    dPScale;
  IGRint       FootIndex, intmsg;

  struct ret_struct   p_rs;

  SetProc( Md VCSAFN_main ); Begin 

  FootIndex = -1;

  form_ptr = me->pSysAtt;
  status   = OM_S_SUCCESS;

  VC_INITSTR (szFld);
  VC_INITSTR (me->szMsg);

  UI_status( " " );
  FIfld_get_type (form_ptr, gadget_label, 0, &iType);
  if (iType == FI_ALPHA)
  {
    FIg_get_text (form_ptr, gadget_label, szFld);
    szFld[VC_CMD_BUFSIZE-1] = '\0';
  }

  switch (gadget_label)
  {
    case VCSET_GDG_TAGNO:
      if (VC_EMPTYSTR(szFld)) break;

      szFld[VC_MAX_TAGNO-1] = '\0';

      /* Get the TagNumber from the Component */
      status = om$send ( msg = message VCRoot.VCGetTagNo( CompTag ),
                      targetid = me->CompId.objid,
                      targetos = me->CompId.osnum );

      __DBGpr_str( " Components Tag ", CompTag );
      __DBGpr_str( " TagNumber from gadget ", szFld );

      /* Check the CompTag with that of the one obtained form the gadget, if 
      they are different then go for TagNumber check. Alwin */

      if( strcmp( szFld, CompTag ) )
      {
	 nST = -1;
	 status = VC_TAGchk (&nST, me->nTagCat, szFld);

	 if (nST < 0)
	 {
	   strcpy (me->CompTag, szFld);
	   me->bTGch = TRUE;
	   UI_status ("  ");
	 }
	 else
	 {
	   UI_status ("Duplicate Tag Number");
	   VC_INITSTR(me->CompTag);
	 }
      }

      break;

    case VCSET_GDG_CCODE:
      if (VC_EMPTYSTR(szFld)) break;

      /* added by alwin  for 179800042 */
      /* Large block of code deleted/rewritten for TR179800042 - law */
      if( ! me->bParCab )
      {
        int new_list_cnt,sel_index,longest_text;
        IGRchar      szText[VC_CMD_BUFSIZE];
        int sel_flag=0,r_pos,length;
        int unique_flg;

        status = VDfrm_fld_set_sub_list(  form_ptr,
                                VCSET_GDG_CCODE,
                                VCSET_GDG_MESSAGE,
                                me->CClist,
                                VC_MAX_CCODE,
                                me->nCC,
                                &new_list_cnt,
                                0,
                                &sel_index,
                                &unique_flg   );

        /* The form preprocessor uses  me->CompCode to reset the field */
        FIfld_get_text_length (form_ptr, VCSET_GDG_CCODE, 0, 0, &length);
        FIfld_get_text( form_ptr, VCSET_GDG_CCODE, 0, 0, length,
                          (unsigned char *) szText, &sel_flag, &r_pos );
        strcpy(me->CompCode,szText);
        if(unique_flg)
        {
          FIg_enable(form_ptr,FI_EXECUTE);
          FIg_enable(form_ptr,FI_ACCEPT);

	  jdsp = sel_index * VC_MAX_SDESC;

	  strcpy (me->CompDesc, &me->CCdesc[jdsp]);
	  me->bCCch = TRUE;

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
      else
	  UI_status("Cannot modify comp_code for Parent cables");
      break; /* End of case VCSET_GDG_CCODE */
 

    case VCSET_GDG_ADDLAB:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_ADD_LABEL_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCSET_GDG_UNIT:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_UNIT_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCSET_GDG_SYSNM:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_SYST_NAME_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCSET_GDG_CHGNUM:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_CHG_REQ_NUM_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCSET_GDG_APPRV:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_APPRV_STAT_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCSET_GDG_CONSTR:
      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_CONSTR_STAT_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCSET_GDG_NOTES:
      szFld[VC_MAX_NOTES-1] = '\0';

      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_COMP_NOTE_AN, 
                                    AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCSET_GDG_SCALE_FLD:
      FIg_get_value (form_ptr, VCSET_GDG_SCALE_FLD, &(dPScale));

      status =
      om$send (msg = message VCAT.VCAT_set 
                              (&retmsg, VC_SYSTEM, VC_N_PID_SCALE_DB, 
                                    AC_ATTRIB_DOUBLE, NULL, dPScale),
          targetid = my_id);
      break;


    case VCSET_GDG_MTO:
      me->bMTO = !(me->bMTO);
      break;

    case VCSET_GDG_CAB_TAILLGT:
      FIg_get_value (form_ptr, VCSET_GDG_CAB_TAILLGT, &me->dTail);
      break;

    case VCSET_GDG_CAB_ESTLGT:
      FIg_get_value (form_ptr, VCSET_GDG_CAB_ESTLGT, &me->dEstim);
      break;

    case VCSET_GDG_CAB_CALCBTN:
      status =
      om$send ( msg = message ACncpx.ACgive_structure
                      (&intmsg, &FootIndex, VC_N_CAB_LENGTH_DB, &p_rs,
                       &VCANGLB_mdenv),
           targetid = me->CompId.objid,
           targetos = me->CompId.osnum);

      me->dEstim = p_rs.var.root_pm_st.value;

      FIg_set_value (form_ptr, VCSET_GDG_CAB_ESTLGT, me->dEstim);
      break;


/* ------------------------------------------------------------ */

    case VCSET_GDG_USERBTN:
      VC_Cmd_form_open (me->pUsrAtt, VC_FPOS_SA_SUB);

      me->bUsrUp = TRUE;

      status =
      om$send (msg = message VCAT.VCAT_udsp (&retmsg, me->pUsrAtt),
          targetid = my_id);

      me->MyRet = VC_RTC_BTN_USRPAR;
      _put_response( resp = VC_RTC_BTN_USRPAR );
      break;

    case VCSET_GDG_COPYBTN:
      me->MyRet = VC_RTC_BTN_LOADATT;
      FIg_set_state_off (form_ptr, VCSET_GDG_COPYBTN);
      _put_response( resp = VC_RTC_BTN_LOADATT );
      break;

    case VCSET_GDG_TERM_CPBTN:
      /*     change term parent    @@@ TBD  @@@    */
      me->MyRet = VC_RTC_BTN_RECON;
      FIg_set_state_off (form_ptr, VCSET_GDG_TERM_CPBTN);
      FIf_erase (form_ptr);
      me->bSysUp	= FALSE;
      _put_response( resp = VC_RTC_BTN_RECON );
      break;

    case VCSET_GDG_TERM_VCBTN:
      status =
      om$send (msg = message VCCmdSA.VCSAdsp_tcon (&retmsg),
          targetid = my_id);
      break;

    case VCSET_GDG_CABA_VCBTN:
    case VCSET_GDG_CABB_VCBTN:
      status =
      om$send (msg = message VCCmdSA.VCSAdsp_ccon (&retmsg),
          targetid = my_id);
      break;

    case VCSET_GDG_CAB_MOREBTN:
      status =
      om$send (msg = message VCCmdSA.VCSAdsp_more (&retmsg),
          targetid = my_id);
      break;

    case VCSET_GDG_AROT_FLD: /** CR179802404 **/
         /* do nothing */
      break;
/* ------------------------------------------------------------ */

    case FI_ACCEPT:
      if ((VC_EMPTYSTR(me->CompTag)) && (!me->bTagByp))
      {
        UI_status ("Missing Tag Number");
        break;
      }

      if ((VC_EMPTYSTR(me->CompCode)) && (!me->bGdcode))
      {
        UI_status ("Missing Component Code");
        break;
      }

      /*  store values     set up attrboxes   */
      status =
      om$send (msg = message VCCmdSA.VCSAsave(),
          targetid = my_id);
      /**** CR179802404 - Get rotation angle from form */

      /* if condition added by alwin to prevent crash, b'cas it shouldn't
      get executed for objects other than Terminal & Backshell. Jan 27 '99 */

      if( ( me->nObjType & VC_GEN_TERM ) || ( me->nObjType & VC_GEN_BKSHLL ) )
      {
         IGRint ang;
         IGRdouble dang;
         IGRdouble dMyMat[16];
         struct VCGenInfo     Instance;
      FIg_get_value (form_ptr, VCSET_GDG_AROT_FLD, &dang);
      ang = (IGRint) dang;
      while (ang >= 360)
      {
        ang -= 360;
      }
      dang = (IGRdouble) ang * M_PI / (IGRdouble) 180.0;
      Instance.Attr.Term.dOffVal = &dMyMat[0];
      status =
            om$send (msg = message VCRoot.VCGetInstance ( &retmsg, &Instance ),
                  targetos = me->CompId.osnum,
                  targetid = me->CompId.objid );
      /******** TR4437 ***********/
      /**** Check if return matrix is 3x1 offset ****/
      if(Instance.Attr.Term.nOff == 3)
      {
          IGRint nVCType;
          IGRshort LocTypeMask = 0x0f00;
          Instance.Attr.Term.nOff = 16;
          dMyMat[3] = dMyMat[0];
          dMyMat[7] = dMyMat[1];
          dMyMat[11]= dMyMat[2];
          dMyMat[2] = dMyMat[6] = dMyMat[8] = dMyMat[9] = 0.0;
          dMyMat[11] = dMyMat[12] = dMyMat[13] = dMyMat[14] = 0.0;
          dMyMat[10] = dMyMat[15] = 1.0;
          status = om$send (msg = message VCRoot.VCSetType ( 
                  LocTypeMask,VC_TOFF_C_FULL),
                  targetos = me->CompId.osnum,
                  targetid = me->CompId.objid );

          status = om$send (msg = message VCRoot.VCGetType ( &nVCType ),
                  targetos = me->CompId.osnum,
                  targetid = me->CompId.objid );

          Instance.nType = nVCType;

      }
      dMyMat[0] = dMyMat[5] = cos(dang);
      dMyMat[4] = sin(dang);
      dMyMat[1] = -sin(dang);
      __DBGpr_dbl("set rotation angle",dang);
      __DBGpr_mat("after adjust-mymat = ",dMyMat);

      __DBGpr_com("got instance");

      __DBGpr_mat("dOffVal",Instance.Attr.Term.dOffVal);
      status =
           om$send (msg = message VCRoot.VCSetInstance ( &retmsg, &Instance ),
                  senderid = NULL_OBJID,
                  targetos = me->CompId.osnum,
                  targetid = me->CompId.objid );
      }
      VC_Cmd_form_close (form_ptr, me->FCmain);
      me->bSysUp = FALSE;

      me->MyRet = VC_RTC_ACCEPT;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_EXECUTE:
      if ((VC_EMPTYSTR(me->CompTag)) && (!me->bTagByp))
      {
        UI_status ("Missing Tag Number");
        break;
      }

      if ((VC_EMPTYSTR(me->CompCode)) && (!me->bGdcode))
      {
        UI_status ("Missing Component Code");
        break;
      }

      /*  store values     set up attrboxes   */
      status =
      om$send (msg = message VCCmdSA.VCSAsave(),
          targetid = my_id);

      /* CR179802404 - Get rotation angle from form */
      /* This piece of code should be executed only Terminal & Backshell.
      Alwin*/
      if( ( me->nObjType & VC_GEN_TERM ) || ( me->nObjType & VC_GEN_BKSHLL ) )
      {
         IGRint ang;
         IGRdouble dang;
         IGRdouble dMyMat[16];
         struct VCGenInfo     Instance;
         FIg_get_value (form_ptr, VCSET_GDG_AROT_FLD, &dang);
         ang = (IGRint) dang;
         while (ang >= 360)
         {
            ang -= 360;
         }
         dang = (IGRdouble) ang * M_PI / 180.0;
         Instance.Attr.Term.nOff = 16;
         Instance.Attr.Term.dOffVal = &dMyMat[0];
         status =
            om$send (msg = message VCRoot.VCGetInstance ( &retmsg, &Instance ),
                  senderid = NULL_OBJID,
                  targetos = me->CompId.osnum,
                  targetid = me->CompId.objid );
         /******** TR4437 ***********/
         if(Instance.Attr.Term.nOff == 3)
         {
            IGRint nVCType;
            IGRshort LocTypeMask = 0x0f00;
            dMyMat[3] = dMyMat[0];
            dMyMat[7] = dMyMat[1];
            dMyMat[11]=dMyMat[2];
            dMyMat[2] = dMyMat[6] = dMyMat[8] = dMyMat[9] = 0.0;
            dMyMat[11] = dMyMat[12] = dMyMat[13] = dMyMat[14] = 0.0;
            dMyMat[10] = dMyMat[15] = 1.0;
            dMyMat[15]=1.0; /***** MAY NEED SCALE HERE *******/
            dMyMat[2] = dMyMat[6] = dMyMat[8] = dMyMat[9] = 0.0;
            status = om$send (msg = message VCRoot.VCSetType ( 
                  LocTypeMask,VC_TOFF_C_FULL),
                  targetos = me->CompId.osnum,
                  targetid = me->CompId.objid );

            status = om$send (msg = message VCRoot.VCGetType ( &nVCType ),
                  targetos = me->CompId.osnum,
                  targetid = me->CompId.objid );

            Instance.nType = nVCType;
         }

         dMyMat[0] = dMyMat[5] = cos(dang);
         dMyMat[4] = sin(dang);
         dMyMat[1] = -sin(dang);

         Instance.Attr.Term.nOff = 16;
         status =
            om$send (msg = message VCRoot.VCSetInstance ( &retmsg, &Instance ),
                  senderid = NULL_OBJID,
                  targetos = me->CompId.osnum,
                  targetid = me->CompId.objid );
     }
/*      me->MyRet = VC_RTC_DONE; */
      me->MyRet = VC_RTC_NEXT;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_RESET:
      /*  reset all values, discard active coll   */

      me->MyRet = VC_RTC_RESET;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_CANCEL:
      VC_Cmd_form_close (form_ptr, me->FCmain);
      me->bSysUp = FALSE;

      me->MyRet = VC_RTC_CANCEL;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case VCSET_GDG_FENCE_UP : /* Gadget Number is 75 */

     if( (++me->nSAindex) < me->nSAmax )
     {
         me->CompId = me->LocatedObjects[me->nSAindex].obj_id;
     }
     else 
     {
        /* Reset the index to the old one if it exceeds the Maximum no 
           of elements in the fence. And then inform the user about the same */

        me->nSAindex--;
        me->CompId = me->LocatedObjects[me->nSAindex].obj_id;
        UI_status( "Reached the last element" );
     }
     me->MyRet = VC_RTC_NEXT;
     _put_response( resp = EX_FORM_FINISHED );

     break;

    case VCSET_GDG_FENCE_DN : /* Gadget Number is 74 */

     if( (--me->nSAindex) >= 0 )
     {
         me->CompId = me->LocatedObjects[me->nSAindex].obj_id;
     }
     else 
     {
        /* Reset the index to the old one if it goes below zero ( the Minimym ).
           And then inform the user about the same */

        ++me->nSAindex;
        me->CompId = me->LocatedObjects[me->nSAindex].obj_id;
        UI_status( "Reached the first element" );
     }
     me->MyRet = VC_RTC_NEXT;
     _put_response( resp = EX_FORM_FINISHED );

     break;

    case VCSET_GDG_FENCE_FL : /* Gadget Number is 73 */
    {
       IGRdouble dTmpIndex;

       /* In case if the user wanted to key the number to locate a specific
          component, he's allowed to do so. We get the number and check 
          whether it's there in fence limits( i.e zero to m->nSAmax ). If not
          reset the same index in the field */

       FIg_get_value( form_ptr, gadget_label, &dTmpIndex );
       dTmpIndex = dTmpIndex - 1; /* adjusting for zero start */

       if( (dTmpIndex >= 0) && (dTmpIndex < me->nSAmax) )
       {
	 if( me->nSAindex == dTmpIndex )
	     break;

         me->nSAindex = dTmpIndex;  
         me->CompId = me->LocatedObjects[me->nSAindex].obj_id;
         me->MyRet = VC_RTC_NEXT;
         _put_response( resp = EX_FORM_FINISHED );
        break;
       }
       else if ( dTmpIndex < 0 )
       {
          UI_status( "Reached the first element" );
       }
       else  UI_status( "Reached the last element" );
    
       FIg_set_value( form_ptr, gadget_label, me->nSAindex+1 );
    }
    break;

    case VCSET_GDG_CABA_TRTAG:

    status =
    om$send(msg = message VCCmdSA.VCSACabDsp
                                   (&retmsg, 0,
                                    VCSET_GDG_CABA_EQTYP,
                                    VCSET_GDG_CABA_EQTAG,
                                    VCSET_GDG_CABA_TRTYP,
                                    VCSET_GDG_CABA_TRTAG,
                                    VCSET_GDG_CABA_BKSH,
                                    VCSET_GDG_CABA_CMPAR,
                                    VCSET_GDG_CABA_VCBTN),
       targetid = my_id);
    break;


    case VCSET_GDG_CABB_TRTAG:

    status =
    om$send(msg = message VCCmdSA.VCSACabDsp
                                   (&retmsg, 1,
                                    VCSET_GDG_CABB_EQTYP,
                                    VCSET_GDG_CABB_EQTAG,
                                    VCSET_GDG_CABB_TRTYP,
                                    VCSET_GDG_CABB_TRTAG,
                                    VCSET_GDG_CABB_BKSH,
                                    VCSET_GDG_CABB_CMPAR,
                                    VCSET_GDG_CABB_VCBTN),
       targetid = my_id);

    break;

    default:
      sprintf (me->szMsg," ERROR edit unknown gadget %d\n", gadget_label);
      break;
  }

  quit:
  End
  return (status);
}

end implementation VCCmdSA;

