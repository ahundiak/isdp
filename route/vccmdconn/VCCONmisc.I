/* $Id: VCCONmisc.I,v 1.3 2002/05/08 15:48:24 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmdconn/VCCONmisc.I
 *
 * Description:
 *
 *  Implementation file for connect command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCONmisc.I,v $
 *     Revision 1.3  2002/05/08 15:48:24  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.2  2001/02/20 01:10:15  build
 *     Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:29  cvs
 *     Initial import to CVS
 *
# Revision 1.7  1999/04/14  07:20:52  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for: TR179900463 by aharihar for route
#
# Revision 1.6  1999/02/18  18:02:08  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for: CR 179701619 by aharihar for route
#
# Revision 1.5  1999/02/10  21:33:38  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by lawaddel for route
#
# Revision 1.4  1998/11/13  15:38:46  pinnacle
# TR179801250
#
# Revision 1.3  1998/10/28  03:52:26  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/04/20  09:27:14  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for: TR179800932 by aharihar for route
#
# Revision 1.4  1997/12/09  23:54:48  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by kddinov for route
#
# Revision 1.15  1997/12/09  14:33:06  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by kddinov for cabling
#
# Revision 1.14  1997/12/06  23:33:40  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by kddinov for cabling
#
# Revision 1.13  1997/11/21  00:14:16  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by kddinov for cabling
#
# Revision 1.12  1997/11/17  23:17:02  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by kddinov for cabling
#
# Revision 1.1  1997/10/30  04:16:58  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.11  1997/08/15  12:48:00  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by hverstee for cabling
#
# Revision 1.10  1997/08/12  22:13:48  pinnacle
# Replaced: vccmdconn for:  by hverstee for cabling
#
# Revision 1.9  1997/07/22  15:28:44  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by hverstee for cabling
#
# Revision 1.8  1997/03/19  18:26:50  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by hverstee for cabling
#
# Revision 1.7  1997/01/24  00:09:28  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/20  22:25:38  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by hverstee for cabling
#
# Revision 1.5  1996/10/25  14:41:50  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by hverstee for cabling
#
# Revision 1.4  1996/09/18  18:55:04  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by hverstee for cabling
#
# Revision 1.3  1996/08/30  21:21:42  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:56:18  pinnacle
# Replaced: vccmdconn/VCCONmisc.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:32:48  pinnacle
# Created: vccmdconn/VCCONmisc.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      08/21/96          HV            New
 *      Apr 20, 98       Anand		Calls to FIfld_set_line_color replaced
 *					by FIfld_set_select.
 *      10/06/98         Alwin          Connect button shoule be enabled only
 *                                      after selection Terminal Posi, Cable
 *                                      lead and Connector/splice in case of
 *                                      Fiber optic terminals.
 *      11/12/98         Alwin          Set the signal to the cable leads, by 
 *                                    	calling the method VCSetSignal. 
 *                                    	TR179801250
 *      02/10/99         law            Correct splice posting-TR179802033
 *      Feb 18, 99       Anand		Implemented form_notification for a new
 *					form viz., 'Review Terminal
 *					Connections' that displays information
 *					of jumpers connected to our terminal.
 *					This form is displayed by clicking on a
 *					new gadget that has been added to the
 *					existing Cabling connections form. An
 *					additional case for this form has also
 *					been added in the form_notification.
 *      Apr 14, 99       Anand		For TR 179900463. Do not free form ptr.
 *-------------------------------------------------------------------*/

class implementation VCCmdCON;

%safe
#include "VX_FIproto.h"
%endsafe

#include "VDmem.h"
#include "vrdbgmacros.h" 

#include "vc_define.h" 
#include "VCCmdPJ.h"
#include "VCmacros.h"
#include "VCstructs2.h"
#include "VCLead.h"

from  VCFoCable  import        VCFo_PutConn;

from  VCCon      import        VCConDscall;
from  VCCon      import        VCConnect;
from  VCCon      import        VCSetSignal;

from  VCCable    import        VCCbAutoCon;
from  VCCable    import        VCPutSignal;

from  VCTerm     import        VCGetJumpInstance;


/*=======================================================================*/


method init ( int type ; char * str_ptr )
{
  int       status;
  IGRdouble    dtmp;

SetProc(init); Begin;

  /*A call my super class's init */
  status = 
  om$send(mode     = OM_e_wrt_message,
          msg      = message VDS_LOCATE.init (type, str_ptr),
          targetid = my_id);

  /*A initialize my instance data */
  me->RefId.objid    = NULL_OBJID;
  me->RefId.osnum    = me->ModuleInfo.md_id.osnum;
  me->bICB           = FALSE;
  me->nCptNum        = -1;
  me->nActPos        = -1;
  me->nActSide       = -1;
  me->nActCnd        = -1;
  me->nMaxCnd        = 0;
  me->nMaxCon        = 0;
  me->nCndNum        = 0;
  me->nNumConTab     = 0;
  me->nNumConEnt     = 0;
  me->CSPnum         = 0;
  me->CSPlist        = NULL;
  me->nCurC_S        = VCFO_T_NONE;

  me->Product        = VC_PROD_NONE;

/* KDD 12-97 check signal initial state == form VCConnect check button state */
  FIg_get_value (me->forms[0].form_ptr, VC_CONGDG_CHKSIG, &dtmp);
  me->bSigChk = (dtmp) ? TRUE: FALSE;

  VC_INITSTR (me->szEqT);
  VC_INITSTR (me->szTag);

  me->WRT_os         = me->ModuleInfo.md_id.osnum;

  /*    fill initializer structures    */

  VC_INITSTR (me->INITsig.sig);
  me->INITsig.bSWsig   = FALSE;

  me->INITstr.GR.objid = NULL_OBJID;
  VC_INITSTR (me->INITstr.Ctag);
  VC_INITSTR (me->INITstr.CON);

  me->INITstr.nCstat   = VCFO_T_NONE;
  me->INITstr.nCtype   = VCFO_A_UNCHANGED;

  me->INITstr.ps.nType = VC_GEN_CABLE;
  me->INITstr.ps.Conn.Cable.nCpt = VC_REQ_ALL_CPT;
  me->INITstr.ps.Conn.Cable.bPass = FALSE;
  VC_INITSTR (me->INITstr.ps.Conn.Cable.szLeadId);

  me->INITtrm.nType = VC_GEN_TERM;
  VC_INITSTR (me->INITtrm.Conn.Term.szModId);
  VC_INITSTR (me->INITtrm.Conn.Term.szPosId);

  End
  return OM_S_SUCCESS;
}

method form_notification ( int        form_label ;
                           int        gadget_label ;
                           double     value ;
                           char     * form_ptr )
{
  int		  status = OM_S_SUCCESS;

  IGRint        r_pos;
  IGRint        SelFlag = TRUE;
  IGRchar       szIN[30];

  IGRint        VRConCheck();
  IGRint        VR_FindMate();

  SetProc(form_notification); Begin;

  if( ( form_ptr   == NULL ) ||
      ( form_label != VC_CONN_FORM  &&  form_label != VC_CONN_JUMP_FORM ) )
  {
      __DBGpr_com("Null form pointer or invalid form label");
      End
      return OM_E_INVARG;
  }


  if( form_label == VC_CONN_FORM )
  {
    strcpy (me->szMSG, "");
    FIg_set_text (form_ptr, FI_MSG_FIELD, me->szMSG);
    me->MyRet = gadget_label;

    switch (gadget_label)
    {
      case FI_CANCEL:
	  me->bRedisplay = FALSE; 	/* KDD 11-97 That is expected */

      case FI_ACCEPT:
	FIf_erase (form_ptr);

	/*CC    NOTE : fall through into finished   */

      case FI_EXECUTE:
      case FI_RESET:
	status =
	om$send (msg = message VCCmdCON.VCCONactv (form_ptr, -1 , -1, -1),
	    targetid = my_id);
	_put_response (resp = EX_FORM_FINISHED);
	break;

      case VC_CONGDG_CHKSIG: /* Check Signal button */
	{
	  IGRdouble    dtmp;

	  FIg_get_value (form_ptr, gadget_label, &dtmp);
	  me->bSigChk = (dtmp) ? TRUE: FALSE;
	}
	break;

      case VC_CONGDG_CONFLD:
	__DBGpr_com( " Reached case Connector/Splice ..." );
	if ((me->nActPos < 0) || (me->nActPos >= me->nNumConTab))
	{
	  me->nCurC_S        = VCFO_T_NONE;
	  strcpy (me->szMSG, "No Connection selected for connector assignment");
	  break;
	}

	/****
	if (!(me->bActConn))
	{
	  me->nCurC_S        = VCFO_T_NONE;
	  strcpy (me->szMSG, "Active Position is not connected");
	  break;
	}
	commenting this for testing. All these things will be straightened once
	we start fixing the fiber-optic cables issues. Alwin ****/

	szIN[0] = '\0';
	FIfld_get_text (form_ptr, gadget_label, 0, 0, VC_MAX_ID,
			   (unsigned char *)szIN, &SelFlag, &r_pos);

	__DBGpr_str( " Selectd Connetor/Splice ", szIN );
	__DBGpr_int("nActPos",me->nActPos);
	__DBGpr_int("nActSide",me->nActSide);
	if (me->nActSide == VC_CONCOL_MPOS2)
	{
  /*      strcpy (me->ConTab2[me->nActPos].CON, szIN); wrong array-TR179802033*/
	  me->ConTab2[me->nActPos].nCstat  = VCFO_A_MANUAL;
	  me->ConTab2[me->nActPos].nCtype  = me->nCurC_S;
	}
	else
	{
  /*      strcpy (me->ConTab1[me->nActPos].CON, szIN); wrong array-TR179802033*/
	  me->ConTab1[me->nActPos].nCstat  = VCFO_A_MANUAL;
	  me->ConTab1[me->nActPos].nCtype  = me->nCurC_S;
	  __DBGpr_str("me->CndTab.CON stored",me->CndTab[me->nActCnd].CON);
	}
	strcpy (me->CndTab[me->nActCnd].CON, szIN); /* Added for TR179802033 */

	/* If the connector selected is not a null then enable Connect button
	or else disable it. added by alwin for TR179801275 */
	if( szIN[0] != '\0' )
	{
	  if( ( me->nActPos >= 0 ) && ( me->nActCnd >= 0 ) )
	      FIg_enable (form_ptr, VC_CONGDG_CBTN);
	}
	else
	  FIg_disable (form_ptr, VC_CONGDG_CBTN);

	break;

      case VC_CONGDG_CNDLIST: 			/* list of candidates */
	status =
	om$send (msg = message VCCmdCON.VCCONctab
			     (form_label, form_ptr),
	    targetid = my_id);
	break;

      case VC_CONGDG_STAB:  		/* one sided terminals (single tab) */
	status = om$send( msg = message VCCmdCON.VCCONstab
						  (form_label, form_ptr),
			 targetid = my_id);
	break;

      case VC_CONGDG_MTAB:  		/* two sided terminals (single tab) */
	status = om$send( msg = message VCCmdCON.VCCONmtab 
						  (form_label, form_ptr),
			 targetid = my_id);
	break;

      case VC_CONGDG_CBTN: 			/* connect button */
	status =
	om$send (msg = message VCCmdCON.VCCONcbtn
			     (form_label, form_ptr),
	    targetid = my_id);
	break;

      case VC_CONGDG_DBTN: 			/* disconnect button */
	status =
	om$send (msg = message VCCmdCON.VCCONdbtn
			     (form_label, form_ptr),
	    targetid = my_id);
	break;

	       /* Following case added by Anand for CR 179701619 */

      case VC_CONGDG_VIEWJUMP: 			/* view jumper button */
	__DBGpr_com(" Going to view jumper details");
	me->bRedisplay = FALSE;
	FIf_erase( form_ptr );
	_put_response (resp = EX_FORM_FINISHED);
	break;

		 /* Above case added by Anand for CR 179701619 */


      default:
	break;
    }

    if (me->bRedisplay)
    {
      status =
      om$send (msg = message VCCmdCON.VCCONFillForm(),
	  targetid = my_id);
    }

    FIg_set_text (form_ptr, FI_MSG_FIELD, me->szMSG);
  }


  if( form_label==VC_CONN_JUMP_FORM )
  {
    switch (gadget_label)
    {
      case FI_CANCEL:
        __DBGpr_com(" User cancels r t c form");
        FIf_erase( form_ptr );
	me->bRedisplay = TRUE;
	_put_response (resp = EX_FORM_FINISHED);
	break;

      case VCVJ_JUMPFLD:
      {
	  IGRshort	i, nCC;
	  IGRint	sel_row, col, temp, NbRows, txtlen, jump_row, NoOfPins;
	  IGRlong	retmsg;
	  IGRchar	szCompDesc[VC_MAX_SDESC],szCompCode[VC_MAX_CCODE];
	  IGRchar	*CClist, *CCdesc;

	  __DBGpr_com(" User selected MC field.");

	  FIfld_get_active_row (form_ptr, VCVJ_JUMPFLD, &sel_row, &temp);
	  __DBGpr_int(" Selected Row",sel_row);

	  FImcf_get_active_col (form_ptr, VCVJ_JUMPFLD, &col, &temp);
	  __DBGpr_int(" Selected column",col);

		/* First deselect all rows */
	  FIfld_get_num_rows( form_ptr, VCVJ_JUMPFLD, &NbRows);
	  __DBGpr_int(" Number of rows in VCVJ_JUMPFLD",NbRows);
	  for( i=0 ; i<NbRows ; i++ )
	      FImcf_set_select( form_ptr, VCVJ_JUMPFLD, i, FALSE );

		/* Track the row corresponding to the Jumper of selected row */
	  FIfld_get_text_length( form_ptr, VCVJ_JUMPFLD, sel_row, 0, &txtlen );
	  jump_row=sel_row;
	  while( txtlen <= 1 )
	  {
	      --jump_row;
	      if( jump_row < 0 )
		  break;
	      FIfld_get_text_length(form_ptr,VCVJ_JUMPFLD,jump_row,0,&txtlen);
	  }
	  __DBGpr_int(" Jumper row",jump_row);

		/* get jumper's compcode, and print description and remarks */
	  FIfld_get_text( form_ptr, VCVJ_JUMPFLD, jump_row, 0, txtlen,
		  	  (unsigned char *)szCompCode, &temp, &temp);
	  __DBGpr_str(" selected jumper's comp code", szCompCode);

		/* Get the Jumper's description and display in field */
	  vc$jumper_idx( p_count = &nCC,
		  	 osnum   = me->RefId.osnum );

	  CClist = _CALLOC( nCC * VC_MAX_CCODE , IGRchar );
	  CCdesc = _CALLOC( nCC * VC_MAX_SDESC , IGRchar );

	  vc$jumper_idx( p_count = &nCC,
		  	 p_desc  = CCdesc,
			 p_codes = CClist,
		  	 osnum   = me->RefId.osnum );

	  for( i=0 ; i<nCC ; i++ )
	  {
	      IGRint	idsp,jdsp;

	      idsp = i * VC_MAX_CCODE;
	      jdsp = i * VC_MAX_SDESC;

	      if( ! strcmp (szCompCode, &CClist[idsp]) )
	      {
		  strcpy (szCompDesc, &CCdesc[jdsp]);
		  __DBGpr_str(" comp desc",szCompDesc);
		  FIfld_set_text(form_ptr, VCVJ_JUMPDESC, 0, 0, szCompDesc, 0 );
		  break;
	      }
	  }

	  _FREE( CClist );
	  _FREE( CCdesc );

		/* Fetch and Display the Jumper's remarks */
	  {
	      void	*TempData;
	      IGRint	NbJumper=0;

	      status=om$send( msg = message VCTerm.VCGetJumpInstance( &retmsg,
								    &TempData,
								    &NbJumper,
									NULL ),
			 targetid = me->RefId.objid,
			 targetos = me->RefId.osnum);
	      as$status();

       /***************************************************************/
       /* The following lines of code assumes the offset type to be 1 */
       /***************************************************************/
	      {
		  struct VCJumpData	*JumpData;

		  JumpData = (struct VCJumpData *) TempData;

		  for( i=0 ; i<NbJumper ; i++ )
		  {
		      __DBGpr_int(" Jumper ID",(JumpData+i)->JumperId );
		      __DBGpr_str(" Jumper code", (JumpData+i)->jump_code);
		      __DBGpr_str(" Remarks: ",(JumpData+i)->remarks);

		      if( ! strcmp(szCompCode,(JumpData+i)->jump_code) )
		      {
			  FIfld_set_text(form_ptr, VCVJ_JUMPREMK, 0, 0,
						(JumpData+i)->remarks, FALSE );
			  break;
		      }
		  }
	      }
	 /***********************************************************/
	 /* The above lines of code assumes the offset type to be 1 */
	 /***********************************************************/

	      _FREE( TempData );
	  }


		/* Select all rows corresponding to that Jumper */
	  for( i=jump_row ; i<=sel_row ; i++ )
	      FImcf_set_select( form_ptr, VCVJ_JUMPFLD, i, TRUE );
	  do
	  {
	      FIfld_get_text_length(form_ptr, VCVJ_JUMPFLD, i, 0, &txtlen);
	      if( txtlen <=1 )
		  FImcf_set_select( form_ptr, VCVJ_JUMPFLD, i, TRUE );
	      ++i;
	  }
	  while( txtlen <= 1 && i<NbRows );

	  break;
      }
    }
  }

  quit:
  End
  return OM_S_SUCCESS;
}

method VCCONRetCode ()
{
   me->ret = me->MyRet;

  return OM_S_SUCCESS;
}

method VCCONinsert (IGRshort  index)
{
  IGRshort    ii;

SetProc(VCCONinsert); Begin;

#ifdef MY_DEBUG
  printf (" insert at %d \n",index);
#endif

/* KDD 11-97  */
  if ( index > me->nMaxCon - 1 ) {
	UI_status("Maximum Connect limit reached");
	printf("Connect limit of %d, reached for [%d]\n", me->nMaxCon, my_id); 
	goto wrapup;
  }
  
  for (ii=me->nMaxCon-1; ii>=index+1; ii--)
  {
     me->ConTab1[ii] = me->ConTab1[ii-1];
     me->ConTab2[ii] = me->ConTab2[ii-1];
     me->ConSig1[ii] = me->ConSig1[ii-1];
     me->ConSig2[ii] = me->ConSig2[ii-1];

     me->PosTab[ii]  = me->PosTab[ii-1];
  }

  me->ConTab1[index+1]           = me->INITstr;
  me->ConTab2[index+1]           = me->INITstr;
  me->ConSig1[index+1]           = me->ConSig1[index];
  me->ConSig2[index+1]           = me->ConSig2[index];

  me->nNumConTab++;

#ifdef MY_DEBUG
  printf (" re-init %d \n",(index+1));
#endif
  me->bRedisplay = TRUE;

wrapup:
End;
  return OM_S_SUCCESS;
}

method VCCONactv (IGRchar  *form_ptr;
                  IGRint    Nactcon;
                  IGRint    Nactsid;
                  IGRint    Nactcnd)
{
  IGRboolean      bConnected;
  int		  RefFileFlag =0;

SetProc(VCCONactv); Begin;

  bConnected = FALSE;
  __DBGpr_int(" Nactcon",Nactcon);
  __DBGpr_int(" nActPos",me->nActPos);
  __DBGpr_int(" Nactsid",Nactsid);
  __DBGpr_int(" nActSide",me->nActSide);
  __DBGpr_int(" Nactcnd",Nactcnd);
  __DBGpr_int(" nActCnd",me->nActCnd);

  /*   check if this is a legal activation    */

  if (Nactcon >= 0)
  {
    if (Nactsid == VC_CONCOL_MPOS2)
    {
      if ((me->ConTab2[Nactcon].GR.objid != NULL_OBJID) &&
          (me->ConTab2[Nactcon].GR.osnum != me->WRT_os))
      {
        strcpy (me->szMSG, "Cannot disconnect cable in reference file");
	RefFileFlag= 1;
        /* KDD 12-97 allow connection for other cables  goto WRAPUP;  */
      }
    }
    else
    {
      if ((me->ConTab1[Nactcon].GR.objid != NULL_OBJID) &&
          (me->ConTab1[Nactcon].GR.osnum != me->WRT_os))
      {
        strcpy (me->szMSG, "Cannot disconnect cable in reference file");
        RefFileFlag= 1;
        /* KDD 12-97 allow connection for other cables  goto WRAPUP;  */
      }
    }
  }

  if (Nactcnd >= 0)
  {
    if ((me->CndTab[Nactcnd].GR.objid != NULL_OBJID) &&
        (me->CndTab[Nactcnd].GR.osnum != me->WRT_os))
      {
        strcpy (me->szMSG, "Cannot connect cable in reference file");
        goto WRAPUP;
      }
  }

  /*   check if color changes, turn off old   */
  __DBGpr_int(" double sided form used?",me->bICB);
  __DBGpr_int(" nNumConEnt",me->nNumConEnt);
  __DBGpr_int(" nNumConTab",me->nNumConTab);

/* Between points A and B marked below, all calls to FIfld_set_line_color
   were replaced by FIfld_set_select. FIfld_set_line_color has not been
   quite doing its job in terms of setting the display of the selected row
   and column of a field to the desired colour. Anand for TR179800932 */


/********************* POINT A *****************************/

  if (((Nactcon != me->nActPos) || (Nactsid != me->nActSide)) &&
       (me->nActPos >= 0))
  {
    if (me->bICB)
    {
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, me->nActPos,
							VC_CONCOL_MMOD, FALSE);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, me->nActPos,
							me->nActSide, FALSE);

/*
      FIfld_set_line_color (form_ptr, VC_CONGDG_MTAB, me->nActPos,
                              VC_CONCOL_MMOD, -1);
      FIfld_set_line_color (form_ptr, VC_CONGDG_MTAB, me->nActPos,
                              me->nActSide, -1);
*/
    }
    else
    {
      __DBGpr_com(" going to remove colour in VC_CONGDG_STAB");

      FIfld_set_select (form_ptr, VC_CONGDG_STAB, me->nActPos,
							VC_CONCOL_SMOD, FALSE);
      FIfld_set_select (form_ptr, VC_CONGDG_STAB, me->nActPos,
							me->nActSide, FALSE);

/*
      FIfld_set_line_color (form_ptr, VC_CONGDG_STAB, me->nActPos,
                              VC_CONCOL_SMOD, -1);
      FIfld_set_line_color (form_ptr, VC_CONGDG_STAB, me->nActPos,
                              me->nActSide, -1);
*/
      __DBGpr_com(" REMOVED COLOUR IN VC_CONGDG_STAB");
    }
  }

  if ((Nactcnd != me->nActCnd) && (me->nActCnd >= 0))
  {
      __DBGpr_com(" going to remove colour in VC_CONGDG_CNDLIST");
      FIfld_set_select (form_ptr, VC_CONGDG_CNDLIST, me->nActCnd,
				        	VC_CNDCOL_LEAD, FALSE);
      FIfld_set_select (form_ptr, VC_CONGDG_CNDLIST, me->nActCnd,
						VC_CNDCOL_CAB, FALSE);

/*
      FIfld_set_line_color (form_ptr, VC_CONGDG_CNDLIST, me->nActCnd,
                              VC_CNDCOL_LEAD, -1);
      FIfld_set_line_color (form_ptr, VC_CONGDG_CNDLIST, me->nActCnd,
                              VC_CNDCOL_CAB, -1);
*/
      __DBGpr_com(" REMOVED COLOUR IN VC_CONGDG_CNDLIST");
  }

  /*   check if color changes, turn on new   */

  me->nActPos  = Nactcon;
  me->nActSide = Nactsid;
  me->nActCnd  = Nactcnd;

  if (me->nActPos >= 0)
  {
    if (me->bICB)
    {
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, me->nActPos,
				        	VC_CONCOL_MMOD, TRUE);
      FIfld_set_select (form_ptr, VC_CONGDG_MTAB, me->nActPos,
						 me->nActSide, TRUE);

/*
      FIfld_set_line_color (form_ptr, VC_CONGDG_MTAB, me->nActPos,
                              VC_CONCOL_MMOD, FI_RED);
      FIfld_set_line_color (form_ptr, VC_CONGDG_MTAB, me->nActPos,
                              me->nActSide, FI_RED);
*/
      if (me->nActSide == VC_CONCOL_MPOS1)
      {
        if (me->ConTab1[me->nActPos].GR.objid != NULL_OBJID)
          bConnected = TRUE;
      }
      else
      {
        if (me->ConTab2[me->nActPos].GR.objid != NULL_OBJID)
          bConnected = TRUE;
      }
    }
    else
    {
      __DBGpr_com(" Going to set colour for VC_CONGDG_STAB");

      FIfld_set_select (form_ptr, VC_CONGDG_STAB, me->nActPos,
							VC_CONCOL_SMOD, TRUE);
      FIfld_set_select (form_ptr, VC_CONGDG_STAB, me->nActPos,
							me->nActSide, TRUE);

/*
      FIfld_set_line_color (form_ptr, VC_CONGDG_STAB, me->nActPos,
                              VC_CONCOL_SMOD, FI_RED );
      FIfld_set_line_color (form_ptr, VC_CONGDG_STAB, me->nActPos,
                              me->nActSide, FI_RED);
*/
      __DBGpr_com(" SET COLOUR FOR VC_CONGDG_STAB");

      if (me->ConTab1[me->nActPos].GR.objid != NULL_OBJID)
        bConnected = TRUE;
    }
  }

  if (me->nActCnd >= 0)
  {
      __DBGpr_com(" Going to set colour for VC_CONGDG_CNDLIST");
      FIfld_set_select (form_ptr, VC_CONGDG_CNDLIST, me->nActCnd,
							VC_CNDCOL_LEAD, TRUE);
      FIfld_set_select (form_ptr, VC_CONGDG_CNDLIST, me->nActCnd,
							VC_CNDCOL_CAB, TRUE);
/*
      FIfld_set_line_color (form_ptr, VC_CONGDG_CNDLIST, me->nActCnd,
                              VC_CNDCOL_LEAD, FI_RED);
      FIfld_set_line_color (form_ptr, VC_CONGDG_CNDLIST, me->nActCnd,
                              VC_CNDCOL_CAB, FI_RED);
*/
      __DBGpr_com(" SET COLOUR FOR VC_CONGDG_CNDLIST");
  }

/********************* POINT B *****************************/

  /*    update the button status    */

  if ((me->nActPos >= 0) && (bConnected))
    FIg_enable (form_ptr, VC_CONGDG_DBTN);
  else
    FIg_disable (form_ptr, VC_CONGDG_DBTN);

  if ((me->nActPos >= 0) && (me->nActCnd >= 0))
  {
    if (me->Product == VC_PROD_FO)
    {
      /* This is not the only criteria for enabling/disabling the CONNECT
      button, before doing this we need to check whether the "Connector/Splice"
      s selected. Only then this should be enabled. Alwin */
      /******* commented for TR179801275
      if (bConnected)
        FIg_disable (form_ptr, VC_CONGDG_CBTN);
      else
          FIg_enable (form_ptr, VC_CONGDG_CBTN);
      *******/
    }
    else
    {
        FIg_enable (form_ptr, VC_CONGDG_CBTN);
    }
  }
  else
    FIg_disable (form_ptr, VC_CONGDG_CBTN);

  WRAPUP:
/*-- KDD 12-97 Disable disconnect button for cables in reference files --*/
    if ( RefFileFlag) FIg_disable (form_ptr, VC_CONGDG_DBTN);

  End
  return OM_S_SUCCESS;
}

method VCCONCables ( long * sts )
{

  int             status;
  IGRlong         retmsg;
  IGRshort        nNumCab, attrType;
  struct VCLdInfo ldInfo;
  IGRshort        nn;
  IGRint          i;

SetProc(VCCONCables); Begin;

  nNumCab = om$dimension_of (varray = me->CabId);

  /*    disconnect all leads first    */

__DBGpr_int("Num of cables to disconnect ", nNumCab);

  for (i=0; i<nNumCab; i++)
  {
    if (me->CabId[i].osnum != me->WRT_os) continue; /* bypass cables in ref  */

    status =
    om$send (msg = message VCCon.VCConDscall (&retmsg, me->nCPS[i]),
        targetid = me->CabId[i].objid,
        targetos = me->CabId[i].osnum);
#ifdef MY_DEBUG
    printf("disconnect cable %d, (Def)%s, (Alt)%s [%d,%d], end %x\n", 
			i,
			me->ConTab1[i].Ctag, 
			me->ConTab2[i].Ctag, 
			me->CabId[i].objid, 
			me->CabId[i].osnum, 
			me->nCPS[i]); 
#endif
  }

  /*  and connect all positions    */
  /*  also set signal names        */
__DBGpr_int("Connect positions", me->nNumConTab); 

  for (i=0; i<me->nNumConTab; i++)
  {
    if (me->PosTab[i].pDef.Conn.Term.szModId[0] == '\0') continue;

    __DBGpr_str( " ModId ", me->PosTab[i].pDef.Conn.Term.szModId );
    __DBGpr_str( " PosId ", me->PosTab[i].pDef.Conn.Term.szPosId );

    if (me->PosTab[i].pDef.Conn.Term.szPosId[0] != '\0')
    {
      __DBGpr_obj( " Conn. Cable Lead GRid ", me->ConTab1[i].GR );

      if ((me->ConTab1[i].GR.objid != NULL_OBJID) &&
          (me->ConTab1[i].GR.osnum == me->WRT_os ))  /* bypass cables in ref  */
      {
        __DBGpr_com( " Calling VCConnect ... " );
        status =
        om$send (msg = message VCCon.VCConnect (&retmsg, (IGRshort) 1,
                                         &me->ConTab1[i].ps,
                                         &me->PosTab[i].pDef, &me->RefId),
            targetid = me->ConTab1[i].GR.objid,
            targetos = me->ConTab1[i].GR.osnum);
#ifdef MY_DEBUG
        printf (" Lead [%s, %s] end %d connected to Def position %d [%s %s]\n",
		       me->ConTab1[i].Ctag, 
                       me->ConTab1[i].ps.Conn.Cable.szLeadId,
                       me->ConTab1[i].ps.Conn.Cable.nCpt,
		       i,
                       me->PosTab[i].pDef.Conn.Term.szModId,
                       me->PosTab[i].pDef.Conn.Term.szPosId);
#endif

/*
        if (me->ConSig1[i].bSWsig)
        {
*/
          __DBGpr_com( " Calling VCSetSignal ... " );
          __DBGpr_str( " Signal Value ", me->ConSig1[i].sig );

          /***********
          Previously the message was sent to VCSetSignal, this inturn finally
          sets the signal into the Terminal pins instead of the Cable leads.
          Whereas the still further down the file, there is a place where the
          Terminal pins are also updated withe proper signals. So, to set the
          signals into Cable leads we should be making a call to VCPutSignal
          of the Cable object, and this should set the signal correctly.

          om$send (msg = message VCCon.VCSetSignal (&retmsg,

          Changing the message VCSetSignal >> VCPutSignal.
          added by Alwin for TR179801250 ********/

	  /* commented by Jayadev 
	   * VCSetLeadAttrInfo function will set the marker/signal
	   * info for all the (sub)cables thru which a given lead passes
	   * in the network
           * status =
           * om$send (msg = message VCCable.VCPutSignal ( &retmsg,
                                         &me->ConTab1[i].ps,
                                          me->ConSig1[i].sig),
              targetid = me->ConTab1[i].GR.objid,
              targetos = me->ConTab1[i].GR.osnum);
	   */
	   attrType = VC_MARKER_TYPE|VC_SIGNAL_TYPE;
	   __DBGpr_int(" attrType",attrType);
	   __DBGpr_int(" Marker?",attrType&VC_MARKER_TYPE);
	   __DBGpr_int(" Signal?",attrType&VC_SIGNAL_TYPE);

	   strcpy(ldInfo.LeadNam, me->ConTab1[i].ps.Conn.Cable.szLeadId);
	   strcpy(ldInfo.SigNam,  me->ConSig1[i].sig );
	   strcpy(ldInfo.Marker,  me->ConSig1[i].marker );

	   retmsg = VCSetLeadAttrInfo( &me->ConTab1[i].GR, &ldInfo,
				       1, attrType);
	   if(!(retmsg&1))
	   {
	       __DBGpr_obj("FAILED TO SET THE LEAD ATTR INFO for Cable",
			   me->ConTab1[i].GR);
	       __DBGpr_str("Lead name ",me->ConTab1[i].ps.Conn.Cable.szLeadId);
	       goto quit;
	   }
/*
        }
*/
      }

/*
      if ((me->ConSig1[i].bSWsig) &&
          (me->RefId.osnum == me->WRT_os))
*/
      if (me->RefId.osnum == me->WRT_os)
      {
        __DBGpr_com( " Calling VCSetSignal to set signals in Terminal Pins.." );
        status =
        om$send (msg = message VCCon.VCSetSignal (&retmsg, 
                                         &me->PosTab[i].pDef,
                                          me->ConSig1[i].sig),
            targetid = me->RefId.objid,
            targetos = me->RefId.osnum);
      }
    }

    if (!(me->bICB))    continue;

    if (!VC_EMPTYSTR(me->PosTab[i].pAlt.Conn.Term.szPosId))
    {
      if ((me->ConTab2[i].GR.objid != NULL_OBJID) &&
          (me->ConTab2[i].GR.osnum == me->WRT_os ))  /* bypass cables in ref  */
      {
        status =
        om$send (msg = message VCCon.VCConnect (&retmsg, (IGRshort) 1,
                                         &me->ConTab2[i].ps,
                                         &me->PosTab[i].pAlt, &me->RefId),
            targetid = me->ConTab2[i].GR.objid,
            targetos = me->ConTab2[i].GR.osnum);

#ifdef MY_DEBUG
        printf (" Lead [%s, %s] end %d connected to Alt position %d [%s %s]\n",
                       me->ConTab2[i].Ctag,
                       me->ConTab2[i].ps.Conn.Cable.szLeadId,
                       me->ConTab2[i].ps.Conn.Cable.nCpt,
                       i,
                       me->PosTab[i].pAlt.Conn.Term.szModId,
                       me->PosTab[i].pAlt.Conn.Term.szPosId);
#endif

/*
        if (me->ConSig2[i].bSWsig)
        {
          status =
          om$send (msg = message VCCon.VCSetSignal (&retmsg, 
                                         &me->ConTab2[i].ps,
                                          me->ConSig2[i].sig),
              targetid = me->ConTab2[i].GR.objid,
              targetos = me->ConTab2[i].GR.osnum);
*/
	   attrType = VC_MARKER_TYPE|VC_SIGNAL_TYPE;

	   strcpy(ldInfo.LeadNam, me->ConTab2[i].ps.Conn.Cable.szLeadId);
	   strcpy(ldInfo.SigNam,  me->ConSig2[i].sig );
	   strcpy(ldInfo.Marker,  me->ConSig2[i].marker );

	   retmsg = VCSetLeadAttrInfo( &me->ConTab2[i].GR, &ldInfo,
				       1, attrType);
	   if(!(retmsg&1))
	   {
	       __DBGpr_obj("FAILED TO SET THE LEAD ATTR INFO for Cable",
			   me->ConTab2[i].GR);
	       __DBGpr_str("Lead name ",me->ConTab2[i].ps.Conn.Cable.szLeadId);
	       goto quit;
	   }
/*
        }
*/
      }

/*
      if ((me->ConSig2[i].bSWsig) &&
          (me->RefId.osnum == me->WRT_os))
*/
      if (me->RefId.osnum == me->WRT_os)
      {
        status =
        om$send (msg = message VCCon.VCSetSignal (&retmsg, 
                                         &me->PosTab[i].pAlt,
                                          me->ConSig2[i].sig),
            targetid = me->RefId.objid,
            targetos = me->RefId.osnum);
      }
    }
  }

  /*   where necessary set signal names for unconnected leads   */

  for (i=0; i<me->nCndNum; i++)
  {
/*
    if ((me->CndSig[i].bSWsig) &&
*/
    if (me->CndTab[i].GR.osnum == me->WRT_os)
    {
      __DBGpr_com( " Setting signals on Unconnected Leads " );
      /*
      status =
      om$send (msg = message VCCon.VCSetSignal (&retmsg,
                                         &me->CndTab[i].ps,
                                          me->CndSig[i].sig),
          targetid = me->CndTab[i].GR.objid,
          targetos = me->CndTab[i].GR.osnum);
      */
       attrType = VC_MARKER_TYPE|VC_SIGNAL_TYPE;

       strcpy(ldInfo.LeadNam, me->CndTab[i].ps.Conn.Cable.szLeadId);
       strcpy(ldInfo.SigNam,  me->CndSig[i].sig );
       strcpy(ldInfo.Marker,  me->CndSig[i].marker );

       retmsg = VCSetLeadAttrInfo( &me->CndTab[i].GR, &ldInfo,
	         		   1, attrType);
       if(!(retmsg&1))
       {
         __DBGpr_obj("FAILED TO SET THE LEAD ATTR INFO for Cable",
          	      me->CndTab[i].GR);
	 __DBGpr_str("Lead name ",me->CndTab[i].ps.Conn.Cable.szLeadId);
	 goto quit;
       }
     }
   }
  /*    When everything is connected up see if autoconnect can add
        anything                                                        */

  for (i=0; i<nNumCab; i++)
  {
    if (me->CabId[i].osnum != me->WRT_os) continue; /* bypass cables in ref  */

    nn = 1 - me->nCPS[i];
#ifdef MY_DEBUG
    printf (" To autoconnect <%d %d> cpt %d\n",me->CabId[i].objid,
                  me->CabId[i].osnum, nn);
#endif

    __DBGpr_com( " Calling VCCbAutoCon ... " );
    status =
    om$send (msg = message VCCable.VCCbAutoCon (&retmsg, nn),
        targetid = me->CabId[i].objid,
        targetos = me->CabId[i].osnum);
  }

  /*A   update CABLES with fiberoptic connectors ................    */

  if (me->Product != VC_PROD_FO) goto quit;

  for (i=0; i<me->nNumConTab; i++)
  {
    __DBGpr_int("ConTab1.nCstat", me->ConTab1[i].nCstat);
    __DBGpr_int("should be not be equal to",VCFO_A_UNCHANGED);
    __DBGpr_int("and GR.osnum",me->ConTab1[i].GR.osnum);
    __DBGpr_int("should be equal to",me->WRT_os);

    if ((me->ConTab1[i].nCstat != VCFO_A_UNCHANGED) &&
        (me->ConTab1[i].GR.osnum == me->WRT_os))
    {
      IGRshort    nCP;

      nCP = me->ConTab1[i].ps.Conn.Cable.nCpt;

      __DBGpr_int("nCpt in ConTab1",nCP);
      __DBGpr_int("fibre index",i);
      __DBGpr_str("splice name",me->ConTab1[i].CON);
      __DBGpr_com("Calling VCFoCable.VCFo_PutConn");

      status =
      om$send (msg = message VCFoCable.VCFo_PutConn
                               (&retmsg, nCP, 0, &me->ConTab1[i].ps,
                                 me->ConTab1[i].CON,
                                 me->ConTab1[i].nCtype),
          targetid = me->ConTab1[i].GR.objid,
          targetos = me->ConTab1[i].GR.osnum);
    }

    __DBGpr_int("ConTab2.nCstat", me->ConTab2[i].nCstat);
    __DBGpr_int("should not be equal to",VCFO_A_UNCHANGED);
    __DBGpr_int("and GR.osnum",me->ConTab2[i].GR.osnum);
    __DBGpr_int("should be equal to",me->WRT_os);

    if ((me->ConTab2[i].nCstat != VCFO_A_UNCHANGED) &&
        (me->ConTab2[i].GR.osnum == me->WRT_os))
    {
      IGRshort    nCP;

      nCP = me->ConTab2[i].ps.Conn.Cable.nCpt;
      __DBGpr_int("nCpt in ConTab2",nCP);
      __DBGpr_com("Calling VCFoCable.VCFo_PutConn");

      status =
      om$send (msg = message VCFoCable.VCFo_PutConn
                               (&retmsg, nCP, 0, &me->ConTab2[i].ps,
                                 me->ConTab2[i].CON,
                                 me->ConTab2[i].nCtype),
          targetid = me->ConTab2[i].GR.objid,
          targetos = me->ConTab2[i].GR.osnum);
    }
  }

  quit:
End;
  return OM_S_SUCCESS;
}

method VCCONCleanup ( long * sts )
{
  int          status;
  IGRlong      retmsg;

  SetProc(VCCONCleanup); Begin;

  /*C  dehighlight    */

  _FREE (me->CSPlist);

  dp$erase_hilite (msg = &retmsg);

  __DBGpr_int("Dimension of form pointer",om$dimension_of(varray=me->forms) );

#if COMMENTED_FOR_TR179900463
  __DBGpr_com(" going to delete s c c form");
  if (me->forms[0].form_ptr) FIf_delete (me->forms[0].form_ptr);
  _FREE(me->forms[0].form_ptr);
  _FREE(me->forms[0].name);

  __DBGpr_com(" going to delete r t c form");
  if (me->forms[1].form_ptr) FIf_delete (me->forms[1].form_ptr);
  _FREE(me->forms[1].form_ptr);
  _FREE(me->forms[1].name);
#endif

  /*C send the delete message wrt message to myself */

  __DBGpr_com(" going to call VDS_LOCATE.delete");
  status =
  om$send (msg = message VDS_LOCATE.delete (0) ,
          mode = OM_e_wrt_message,
      targetid = my_id);

  End
  return OM_S_SUCCESS;
}

end implementation VCCmdCON;
