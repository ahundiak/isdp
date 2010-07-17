/* $Id: VCCmdPJi.I,v 1.4 2002/05/31 16:00:28 anand Exp $  */

/*************************************************************************
 * I/CABLE
									   *
 * File:  vccmd/VCCmdPJi.I
 *
 * Description:
 *      Implementation file for "Set Terminal Connections" object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPJi.I,v $
 *  Revision 1.4  2002/05/31 16:00:28  anand
 *  Superclass was clearing up wrong form_ptr...
 *
 *  Revision 1.3  2001/03/08 21:14:00  anand
 *  *** empty log message ***
 *
 *  Revision 1.2  2001/02/20 01:09:36  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *  Initial import to CVS
 *
# Revision 1.6  1999/07/05  08:29:36  pinnacle
# Replaced: vcterm/VCCmdPJi.I for: TR 179900629 by aharihar for route
#
# Revision 1.5  1999/04/14  07:27:26  pinnacle
# Replaced: vccmd/VCCmdPJi.I for:  by aharihar for route
#
# Revision 1.4  1999/02/12  10:49:48  pinnacle
# Replaced: vccmd/VCCmdPJi.I for: CR 179701619 by aharihar for route
#
# Revision 1.3  1999/02/01  15:59:56  pinnacle
# Replaced: vccmd/VCCmdPJi.I for: CR 179701619 by aharihar for route
#
# Revision 1.2  1999/01/27  07:20:56  pinnacle
# Replaced: vccmd/VCCmdPJi.I for: CR 179701619 by aharihar for route
#
# Revision 1.1  1999/01/19  09:56:40  pinnacle
# Created: vccmd/VCCmdPJi.I by aharihar for route
#
 *
 * History:
 *        DATE		AUTHOR		DESCRIPTION
 *
 *     18 Jan '99	Anand		Creation
 *     27 Jan '99	Anand		Implemented Modify jumper.
 *     12 Feb '99	Anand		Implemented check against max_connect
 *     05 Jul '99	Anand		Reset Jumper comp_code list - user need
 *     					need not enter * to reset list anymore
 *     					(for TR 179900629).
 *     08 Mar '01	Anand		Put in some pointer checks - found
 *					while investigating JTS TR 3255.
 *
 *************************************************************************/

class implementation VCCmdPJ;

#include <stdlib.h>
#include "vc_define.h"
#include "VCdbstructs.h"
#include "VCCmdPJ.h"
#include "VCCmdDef.h"
#include "VDmem.h"
#include "VCDBpar.h"
#include "VCmacros.h"
#include "vrdbgmacros.h"

/***********  EXTERN ***********/

from  VCDB   	import   VCGetAttr;
from  VCDB   	import   VCGetLayout;
from  VCMac   	import   VCGetEquipTag;
from  VCRoot    import   VCGetModel,
			 VCGetTagNo,
			 VCGetCode,
			 VCGetProduct;
from  VCTerm	import	 VCGetJumpInstance,
			 VCSetJumpInstance,
			 VCGetNumJumpCabOnTermPin;



method init ( int type ; char * str_ptr )
{
  int         status;
  IGRlong     retmsg;
  int         i;
  double      dSelOn   = 1;
  double      dSelOff  = 0;

  extern
  int         GRstatus_display_button();

  SetProc( Md init ); Begin 

  //Initialize superclass

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VCCmdCAT.init( type, str_ptr ),
                    targetid = my_id);

  me->nObjType  = VC_GEN_JUMPER;
  me->bSysUp	= FALSE;
  me->FCcontrol = VC_FPOS_PJ_MAIN;
  me->form_ptr	= NULL;
  me->PosTab	= NULL;
  VC_INITSTR(me->CompCode);

  me->bDblSidedTerminal = FALSE;
  me->nNbJumper	= 0;
  me->bMTO = 1;

  //Get the Number of Jumper Compcodes available in DB
  status =
  om$send (msg = message VCCmdCAT.VCATlist (&retmsg),
      targetid = my_id);
  __DBGpr_int( " Nb. of Compcode in DB ", me->nCC);

  status =
  om$send( msg     = message VCAT.VCAT_act (&retmsg),
          targetid = my_id);

  quit:
  End
  return OM_S_SUCCESS;
}

method wakeup ( int pos )
{
  int     status;

  SetProc( Md wakeup ); Begin 

  if( (pos & EX_suspend) && me->bSysUp )
  {
      __DBGpr_com( " Display the form " );
      FIf_display( me->form_ptr );
  }

  End
  return (OM_S_SUCCESS);
}

method sleep ( int pos )
{
    int             status;

    if( (pos & EX_suspend) && me->bSysUp )
	FIf_erase ( me->form_ptr );

    status = om$send (	mode     = OM_e_wrt_message,
			msg      = message VCCmdCAT.sleep( pos ),
			targetid = my_id);

    return (OM_S_SUCCESS);
}

method VCCleanup ( long * sts )
{
    IGRint       status;

    SetProc( Md VCCleanup ); Begin  

    if( me->PosTab )
    {
	_FREE( me->PosTab );
	__DBGpr_com(" Freed pos tab of instance");
    }

    if( me->form_ptr )
    {
	me->bSysUp = FALSE;
    }

    __DBGpr_com( " Calling VCATExit to Cleanup..." );
    status = om$send ( msg = message VCCmdCAT.VCATExit (sts),
	    targetid = my_id);

    End
    return OM_S_SUCCESS;
}

method VCFstart ()
{
  int   status;

  SetProc( Md VCFstart ); Begin 

  if( !me->bSysUp )
  {
      __DBGpr_com(" The form is not displayed already. So display it.");
      me->pCtlAtt  = me->forms[0].form_ptr;
      me->form_ptr = me->pCtlAtt;

     status = VC_Cmd_form_open ( me->form_ptr, me->FCcontrol );
     me->bSysUp = TRUE;
  }

  End
  return OM_S_SUCCESS;
}

method VCGetObject( IGRlong *sts )
{
  int   status;
  IGRlong retmsg;

  SetProc( Md VCGetObject ); Begin 

  me->CompId = me->event1.located_object[0].located_obj;

  if( me->CompId.objid == NULL_OBJID )
  {
     UI_status( "Component Location Error :-( " );
     End
     return ( OM_E_ABORT );
  }

  __DBGpr_obj( " Terminal ObjectId ", me->CompId );
  me->CmdProd = VC_PROD_NONE;

  //Get the Terminal's product
  status =
  om$send (msg = message VCRoot.VCGetProduct (&me->Product, NULL),
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum);
  as$status();

  if( me->Product == VC_PROD_FO )
  {
     UI_status( "Jumpers are not defined for Fiber-Optic Terminals" );
     End
     return ( OM_S_SUCCESS );
  }

  //Get the Terminals Compcode
  status = om$send ( msg = message VCRoot.VCGetCode( me->CompCode ),
		targetid = me->CompId.objid,
		targetos = me->CompId.osnum );
  __DBGpr_str( " Terminals Compcode ", me->CompCode );

  //Get the Terminals Tagnumber
  status = om$send ( msg = message VCRoot.VCGetTagNo( me->CompTag ),
		targetid = me->CompId.objid,
		targetos = me->CompId.osnum );
  __DBGpr_str( " Terminal Tag  Number ", me->CompTag );

  // Get the Equipments Tagnumber
  status = om$send ( msg = message VCMac.VCGetEquipTag( &retmsg, 
			me->EquipmentTag, &me->ModuleInfo ),
		targetid = me->CompId.objid,
		targetos = me->CompId.osnum );
  as$status();
  __DBGpr_str( " Equipment Tag  Number ", me->EquipmentTag );

  __DBGpr_int( " Nb. of Jumper codes in DB ", me->nCC );

#ifdef vdsDEBUG
  if( me->nCC > 0 )
  {
    IGRint i;

    for( i=0; i<me->nCC; i++ )
    {
       __DBGpr_str( " Jumper Compcode ", &me->CClist[i*VC_MAX_CCODE] );
    }
  }
#endif

  status =
  om$send (msg = message VCRoot.VCGetModel (&retmsg, &me->ModelId),
		targetid = me->CompId.objid,
		targetos = me->CompId.osnum );
  as$status();
  __DBGpr_obj( " Terminal's ModelId ", me->ModelId );

  if ((retmsg != MSSUCC) || (me->ModelId.objid == NULL_OBJID))
  {
    UI_status (" Terminal layout not available .. Login DB...");
    goto quit;
  }

  // Get the Nb. of Positions in the Terminal
  status = om$send (msg = message VCDB.VCGetLayout
                                ( &retmsg, NULL, &me->nNumConEnt,
                                 &me->nNumConTab, NULL ),
      targetid = me->ModelId.objid,
      targetos = me->ModelId.osnum);
  as$status();

  __DBGpr_int( " Total Nb. of Positions, nNumConEnt  ", me->nNumConEnt );
  __DBGpr_int( " Nb. of Positions, nNumConTab  ", me->nNumConTab );

  if( me->nNumConEnt != me->nNumConTab )
  {
    __DBGpr_com( " Its a two way terminal " );
    me->bDblSidedTerminal = TRUE;
  }

  me->nMaxCon = me->nNumConEnt * 3;

  //Allocate the memory for the Terminal positions
  me->PosTab = _MALLOC( me->nMaxCon, struct VClayout );

  if( me->PosTab == NULL )
  {
     __DBGpr_com( " Memory Allocation Error, me->PosTab " );
     End
     return ( OM_E_NODYNMEM );
  }

  __DBGpr_com( " Get the Terminal Layout ..." );
  status = om$send ( msg = message VCDB.VCGetLayout
                                ( &retmsg, NULL, &me->nNumConEnt,
                                 &me->nNumConTab, me->PosTab ),
		targetid = me->ModelId.objid,
		targetos = me->ModelId.osnum );
  as$status();

quit:
  End
  return OM_S_SUCCESS;
}

method VCDispForm( IGRlong *sts )
{
    IGRlong  retmsg;
    IGRshort nNbPins=0, nRow=0;
    IGRint   status, i, SelFlag=FALSE;
    IGRchar  szOld_ModId[VC_MAX_MOD_ID];
    IGRchar  szOld_AltPosId[VC_MAX_POS_ID], szOld_DefPosId[VC_MAX_POS_ID];

    SetProc( Md VCDispForm ); Begin 

    FIfld_set_text(me->form_ptr, VCPJ_TERMTAG, 0, 0, me->CompTag, SelFlag);
    FIfld_set_text(me->form_ptr, VCPJ_EQPTAG, 0, 0, me->EquipmentTag, SelFlag);

    //Set the Jumper Comp Code list in the gadget
    if( me->nCC > 0 )
    {
	FIfld_set_list_num_rows( me->form_ptr, VCPJ_COMPCODE, 0, me->nCC );

	for( i=0; i<me->nCC; i++ )
	{
	    FIfld_set_list_text( me->form_ptr, VCPJ_COMPCODE, i, 0, 
		    &me->CClist[i*VC_MAX_CCODE], 0 );
	}
    }

    //Set the Terminal Positions in the gadget list

    szOld_AltPosId[0] = szOld_DefPosId[0] = szOld_ModId[0] = '\0';

    if ( me->bDblSidedTerminal )
	nNbPins = me->nNumConTab;
    else
	nNbPins = me->nNumConEnt;

    __DBGpr_int(" Number of pins in terminal",nNbPins );

    for( i=0; i<nNbPins; i++ )
    {
	__DBGpr_str( " Module Id of Terminal ", 
				     me->PosTab[i].pDef.Conn.Term.szModId );

	__DBGpr_str( " Position Id of Terminal Pin ", 
				     me->PosTab[i].pDef.Conn.Term.szPosId );

	if ( strcmp( szOld_ModId,    me->PosTab[i].pDef.Conn.Term.szModId ) ||
	     strcmp( szOld_DefPosId, me->PosTab[i].pDef.Conn.Term.szPosId )
	   ) 
	{
	    FIfld_set_text ( me->form_ptr, VCPJ_TERMPOS, nRow, VC_MODCOLNO,
			     me->PosTab[i].pDef.Conn.Term.szModId , SelFlag );

	    FIfld_set_text ( me->form_ptr, VCPJ_TERMPOS, nRow, VC_POSCOLNO,
			     me->PosTab[i].pDef.Conn.Term.szPosId, SelFlag );

	    nRow++;
	    strcpy( szOld_ModId,    me->PosTab[i].pDef.Conn.Term.szModId );
	    strcpy( szOld_DefPosId, me->PosTab[i].pDef.Conn.Term.szPosId );
	}
	else
	{
	    __DBGpr_str(" Old Mod ID",szOld_ModId);
	    __DBGpr_str(" Old Pos ID",szOld_DefPosId);
	}

	if( me->bDblSidedTerminal &&
	    strcmp( me->PosTab[i].pAlt.Conn.Term.szPosId, szOld_AltPosId )
	  )
	{
	    strcpy( me->PosTab[i].pAlt.Conn.Term.szModId,
		    me->PosTab[i].pDef.Conn.Term.szModId );

	    FIfld_set_text ( me->form_ptr, VCPJ_TERMPOS, nRow, VC_MODCOLNO,
		    me->PosTab[i].pAlt.Conn.Term.szModId , SelFlag );

	    __DBGpr_str( " Position Id of Terminal Pin (on other side)", 
		    me->PosTab[i].pAlt.Conn.Term.szPosId );

	    FIfld_set_text ( me->form_ptr, VCPJ_TERMPOS, nRow, VC_POSCOLNO,
		    me->PosTab[i].pAlt.Conn.Term.szPosId, SelFlag );

	    nRow++;
	    strcpy( szOld_AltPosId, me->PosTab[i].pAlt.Conn.Term.szPosId );
	}
    }

    FIg_disable( me->form_ptr, VCPJ_TERMPOS );
    FIg_disable( me->form_ptr, VCPJ_PLACEJUMP );
    FIg_disable( me->form_ptr, VCPJ_UNSELROWS );
    FIg_disable( me->form_ptr, VCPJ_MODJUMP );
    FIg_disable( me->form_ptr, VCPJ_REMJUMP );

    status = om$send ( msg = message VCTerm.VCGetJumpInstance(  &retmsg,
								NULL,
								&me->nNbJumper,
								NULL ),
		  targetid = me->CompId.objid ,
		  targetos = me->CompId.osnum );

    if( me->nNbJumper )
    {
	void	*TempData, *TempConn;

	status = om$send( msg=message VCTerm.VCGetJumpInstance( &retmsg,
								&TempData,
								&me->nNbJumper,
								&TempConn ),
		     targetid=me->CompId.objid ,
		     targetos=me->CompId.osnum );

	/***************************************************************/
	/* The following lines of code assumes the offset type to be 1 */
	/***************************************************************/
	{
	    struct VCJumpData	*JumpData;
	    struct VCJumpConn	*JumpConn;
	    IGRint		NumPinsTerm=0;

	    JumpData = (struct VCJumpData *) TempData;
	    JumpConn = (struct VCJumpConn *) TempConn;

	    for( i=0 ; i<me->nNbJumper ; i++ )
	    {
		__DBGpr_int(" Jumper ID",(JumpData+i)->JumperId );
		me->JumperData[i].JumperId = (JumpData+i)->JumperId ;

		__DBGpr_str(" Jumper code", (JumpData+i)->jump_code);
		strcpy(me->JumperData[i].jump_code, (JumpData+i)->jump_code);

#ifdef vdsDEBUG
		printf("Material Take off: %c, Count against MAX: %c\n",
			(JumpData+i)->no_mto_flag,
			(JumpData+i)->cnt_vs_max );
#endif
		me->JumperData[i].no_mto_flag = (JumpData+i)->no_mto_flag;
		me->JumperData[i].cnt_vs_max  = (JumpData+i)->cnt_vs_max;

		__DBGpr_str(" Remarks: ",(JumpData+i)->remarks);
		strcpy(me->JumperData[i].remarks, (JumpData+i)->remarks);

		__DBGpr_int(" No. of terminal pins",(JumpData+i)->NumTermPins);
		me->JumperData[i].NumTermPins  = (JumpData+i)->NumTermPins;
		NumPinsTerm += (JumpData+i)->NumTermPins;
	    }

	    __DBGpr_int(" Total number of pins -> JumpData",NumPinsTerm);
	    FIfld_set_num_rows( me->form_ptr, VCPJ_EXISTJUMP, NumPinsTerm);

	    for( i=0 ; i<NumPinsTerm ; ++i )
	    {
		__DBGpr_int(" Jumper ID",(JumpConn+i)->JumperId );
		me->JumperConn[i].JumperId = (JumpConn+i)->JumperId;

		if( ( i==0 ) || ( i>0 &&
		    me->JumperConn[i].JumperId != me->JumperConn[i-1].JumperId
		    )
		  )
		{
		    IGRint	jmp_i;

			/* Query for jumper id to get jumper code */
		    for( jmp_i=0 ; jmp_i<me->nNbJumper ; jmp_i++ )
			if( me->JumperConn[i].JumperId
					     == me->JumperData[jmp_i].JumperId )
			    break;

		    __DBGpr_str(" Jumper code for this jumper ID",
					   me->JumperData[jmp_i].jump_code);
		    FIfld_set_text( me->form_ptr, VCPJ_EXISTJUMP, i, 0,
				    me->JumperData[jmp_i].jump_code, FALSE);
		}
		else
		    FIfld_set_text( me->form_ptr, VCPJ_EXISTJUMP, i, 0,
								 "", FALSE);

		__DBGpr_str(" Terminal Module", (JumpConn+i)->Mod );
		strcpy( me->JumperConn[i].Mod , (JumpConn+i)->Mod );
		FIfld_set_text( me->form_ptr, VCPJ_EXISTJUMP, i, 1,
				me->JumperConn[i].Mod, FALSE);

		__DBGpr_str(" Terminal Position", (JumpConn+i)->Pos );
		strcpy(   me->JumperConn[i].Pos , (JumpConn+i)->Pos );
		FIfld_set_text( me->form_ptr, VCPJ_EXISTJUMP, i, 2,
				me->JumperConn[i].Pos, FALSE);
	    }
	}
	/***********************************************************/
	/* The above lines of code assumes the offset type to be 1 */
	/***********************************************************/

	_FREE( TempData );
	_FREE( TempConn );
    }
    else
	FIg_disable( me->form_ptr, VCPJ_EXISTJUMP );

    End
    return OM_S_SUCCESS;
}

method form_notification ( int       form_label ;
                           int       gadget_label ;
                           double    value ;
                           char     *form_ptr )
{
    IGRint	status = OM_S_SUCCESS;
    IGRint	i;
    IGRlong   	retmsg;
    IGRchar  	*fptr;
    IGRchar   	c30buff[VC_MAX_TAGNO];

    SetProc( Md form_notification ); Begin 

    __DBGpr_int(" form label",form_label);
    __DBGpr_int(" gadget label",gadget_label);
    __DBGpr_dbl(" value label",value);
    __DBGpr_str(" form ptr",form_ptr);

    fptr = me->form_ptr;
    c30buff[0] = '\0';

    FIfld_set_text(fptr, VCPJ_MSGFLD, 0, 0, "", 0 );

    FIg_get_state( fptr, VCPJ_REMJUMP, &status );
    if( status && gadget_label!=VCPJ_REMJUMP )
	FIg_set_state( fptr, VCPJ_REMJUMP, FALSE );

    switch( gadget_label )
    {
      case FI_RESET:
      {
	  __DBGpr_com( " Reached reset case " );

	  status = om$send ( msg = message VCCmdPJ.VCDispForm( &retmsg ),
			targetid = my_id );
	  break;
      };

      case FI_ACCEPT:
      case FI_EXECUTE:
      {
	  __DBGpr_com( " Reached execute case " );
	  __DBGpr_obj(" Setting jumper instance for Terminal",me->CompId );
	  status = om$send ( msg = message VCTerm.VCSetJumpInstance( &retmsg,
		      					me->JumperData,
							me->nNbJumper,
							me->JumperConn),
		  targetid = me->CompId.objid ,
		  targetos = me->CompId.osnum );

	  if( gadget_label == FI_ACCEPT )
	      _put_response(resp = EX_FORM_FINISHED);
	  break;
      };

      case FI_CANCEL:
      {
	  __DBGpr_com( " Reached cancel case " );
	  _put_response (resp = EX_FORM_FINISHED);
	  break;
      };

      case VCPJ_COMPCODE:
      {
	  IGRint 	new_list_cnt, sel_index;
	  IGRchar	szText[VC_CMD_BUFSIZE];
	  IGRint 	i, jdsp;
	  IGRint 	sel_flag=0,r_pos,length;
	  IGRint 	unique_flg=0;

	  szText[0] = '\0';

	  __DBGpr_com( " Reached comp_code case " );
	  status = VDfrm_fld_set_sub_list(fptr,
					  VCPJ_COMPCODE,
					  VCPJ_MSGFLD,
					  me->CClist,
					  VC_MAX_CCODE,
					  me->nCC,
					  &new_list_cnt,
					  0,
					  &sel_index,
					  &unique_flg );

	  FIfld_get_text_length (fptr, VCPJ_COMPCODE, 0, 0, &length);
	  FIfld_get_text( fptr, VCPJ_COMPCODE, 0, 0, length,
		  (unsigned char *) szText, &sel_flag, &r_pos );

	  __DBGpr_str(" string in comp code field", szText );
	  __DBGpr_int(" unique match found?",unique_flg);
	  __DBGpr_int(" Num items in new list",new_list_cnt);

	  if( unique_flg )
	  {
		  /* Below lines added for TR 179900629 - Anand */
	      	  /* Reset comp_codes in associative list when unique match is
		   * found.		- Anand for TR 179900629 */
	      FIfld_set_list_num_rows(me->form_ptr, VCPJ_COMPCODE, 0, me->nCC);
	      for( i=0; i<me->nCC; i++ )
	      {
		  FIfld_set_list_text( me->form_ptr, VCPJ_COMPCODE, i, 0, 
			  &me->CClist[i*VC_MAX_CCODE], 0 );
	      }
		  /* Above lines added for TR 179900629 - Anand */

	      jdsp = sel_index * VC_MAX_SDESC;

	      strcpy( me->CompCode, szText);
	      __DBGpr_str(" comp code",szText);

	      strcpy (me->CompDesc, &me->CCdesc[jdsp]);
	      __DBGpr_str(" comp desc",me->CompDesc);
	      FIfld_set_text(fptr, VCPJ_NEWJUMPDES, 0, 0, me->CompDesc, 0 );

	      FIg_enable( fptr, VCPJ_TERMPOS);
	      me->bCCch = TRUE;

	      __DBGpr_com( " Calling VCGetJumpMaxPos ... " );
	      status = om$send ( msg = message VCCmdPJ.VCGetJumpMaxPos
		      ( &retmsg, me->CompCode ),
		      targetid = my_id );

	      if( retmsg & 1 )
	      {
		  IGRchar szMaxPos[4];

		  sprintf( szMaxPos, "%d", me->nMaxNoPos );
		  __DBGpr_str(" no. max posns",szMaxPos);
		  FIg_set_text( fptr, VCPJ_MAXPOS, szMaxPos );
	      }
	      else
	      {
		  FIg_set_text( fptr, VCPJ_MAXPOS, "" );
		  UI_status( "Failed to obtain max_position' for jumper" );
		  FIg_set_text( fptr, VCPJ_MSGFLD,
			  	"Could not obtain max_position for jumper!");
		  FIg_set_state_on( fptr,VCPJ_MAXCONN ); 
		  FIg_disable( fptr,VCPJ_MAXCONN ); 
	      }
	  }
	  break;
      };

      case VCPJ_TERMPOS:
      {
	  IGRint	row, col, temp, NbRows, sel_flag, state;
	  __DBGpr_com( " Reached Terminal Positions case " );

	  FIfld_get_active_row (fptr, VCPJ_TERMPOS, &row, &temp);
	  __DBGpr_int(" Selected Row",row);

	  NbRows = (me->bDblSidedTerminal)?(2*me->nNumConTab):me->nNumConEnt;
	  __DBGpr_int(" Number of rows in multi column field",NbRows);

	  if( row >= NbRows )
	      break;

	  FImcf_get_active_col (fptr, VCPJ_TERMPOS, &col, &temp);
	  __DBGpr_int(" Selected column",col);

	  FImcf_get_select( fptr, VCPJ_TERMPOS, row, &sel_flag );
	  __DBGpr_int(" select state",sel_flag);

	  if(!sel_flag)
	  {
	      IGRchar	szNumPos[5];
	      IGRint	dNumPos, strlen;

	      /* user clicks on selected terminal position to deselect it. */
	      FImcf_set_select( fptr, VCPJ_TERMPOS, row, FALSE );

	      /* update the num-positions-used field */
	      FIfld_get_text_length(fptr, VCPJ_POSUSED, 0, 0, &strlen );
	      __DBGpr_int(" num posns used empty?", strlen-1);
	      if( strlen > 1 )
	      {
		  FIfld_get_text( fptr, VCPJ_POSUSED, 0, 0, strlen,
			  szNumPos, &temp, &temp );
		  __DBGpr_str(" Number of positions", szNumPos);
		  dNumPos = atoi( szNumPos );
		  dNumPos--;
		  if( dNumPos>0 )
		      sprintf(szNumPos,"%d",dNumPos);
		  else
		  {
		      sprintf(szNumPos,"");
		      FIg_disable( fptr, VCPJ_UNSELROWS);
		  }
		  FIfld_set_text( fptr, VCPJ_POSUSED, 0, 0, szNumPos, 0);

		  if( dNumPos<2 )
		      FIg_disable( fptr, VCPJ_PLACEJUMP);
		  else
		  if( dNumPos <= me->nMaxNoPos )
		      FIg_enable( fptr, VCPJ_PLACEJUMP );
	      }
	      else
		  FIfld_set_text( fptr, VCPJ_POSUSED, 0, 0, "", 0);
	  }
	  else
	  {
	      IGRint	strlen;

	      FIg_get_state( fptr, VCPJ_MAXCONN, &state );
	      __DBGpr_int(" Check for max_conn?",state);

	      if( state )
	      {
		  /* Check against max no. connections is off */
		  FImcf_set_select(fptr, VCPJ_TERMPOS, row, TRUE);
	      }
	      else
	      {
		  /* Find number of cable leads and other jumpers that
		   * occupy this terminal position. Check if this exceeds
		   * max_con limit. If not then select it, else display a
		   * message. */

		  struct VCPinConnect	TerminalPin;

		  FIfld_get_text_length( fptr, VCPJ_TERMPOS, row, VC_MODCOLNO,
		  			 &strlen );
		  FIfld_get_text( fptr, VCPJ_TERMPOS, row, VC_MODCOLNO, strlen,
				  TerminalPin.PinId.szModId, &temp, &temp );

		  FIfld_get_text_length( fptr, VCPJ_TERMPOS, row, VC_POSCOLNO,
		  			 &strlen );
		  FIfld_get_text( fptr, VCPJ_TERMPOS, row, VC_POSCOLNO, strlen,
				  TerminalPin.PinId.szPosId, &temp, &temp );

		  __DBGpr_str(" Querying for Mod",TerminalPin.PinId.szModId);
		  __DBGpr_str(" Querying for Pos",TerminalPin.PinId.szPosId);

		  status=om$send(msg=message VCTerm.VCGetNumJumpCabOnTermPin
						  ( &retmsg, &TerminalPin ),
			    targetid=me->CompId.objid,
			    targetos=me->CompId.osnum );
		  as$status();

		  __DBGpr_int(" Num Cable leads on pin",TerminalPin.NumConnect);
		  __DBGpr_int(" Num Jumpers on pin",TerminalPin.NumJumpers);
		  __DBGpr_int(" DB max limit of pin",TerminalPin.DBlimit);

		  if( TerminalPin.DBlimit <=
			     TerminalPin.NumConnect+TerminalPin.NumJumpers )
		  {
		      IGRchar	tmpstr[60];

		      FImcf_set_select(fptr, VCPJ_TERMPOS, row, FALSE);
		      sprintf(tmpstr,"Sorry! DB limit exceeded for pin <%s,%s>",
				TerminalPin.PinId.szModId,
				TerminalPin.PinId.szPosId);
		      FIfld_set_text( fptr, VCPJ_MSGFLD, 0, 0, tmpstr, FALSE );
		      break;
		  }
	      }

	      /* update the num-positions-used field */
	      FIfld_get_text_length(fptr, VCPJ_POSUSED, 0, 0, &strlen );
	      __DBGpr_int(" num posns used empty?", strlen-1);
	      if( strlen > 1 )
	      {
		  IGRchar	szNumPos[5];
		  IGRint	dNumPos;

		  FIfld_get_text( fptr, VCPJ_POSUSED, 0, 0, strlen,
			  szNumPos, &temp, &temp );
		  __DBGpr_str(" Number of positions", szNumPos);
		  dNumPos = atoi( szNumPos );
		  dNumPos++;
		  sprintf(szNumPos,"%d",dNumPos);
		  FIfld_set_text( fptr, VCPJ_POSUSED, 0, 0, szNumPos, 0);

		  if( dNumPos>=2 )
		      FIg_enable( fptr, VCPJ_PLACEJUMP);
		  if( dNumPos>me->nMaxNoPos )
		  {
		      FIfld_set_text(fptr, VCPJ_MSGFLD, 0, 0,
			      "Warning: Max. no. positions exceeded",
			      FALSE);
		      FIg_disable( fptr, VCPJ_PLACEJUMP);
		  }
	      }
	      else
	      {
		  FIfld_set_text( fptr, VCPJ_POSUSED, 0, 0, "1", 0);
		  FIg_enable( fptr, VCPJ_UNSELROWS);
	      }
	  }
	  break;
      };

      case VCPJ_BOM:
      {
	  __DBGpr_com( " Reached BOM case " );
	  me->bMTO = !(me->bMTO);
//	  me->JumperData.no_mto_flag = !(me->JumperData.no_mto_flag);
	  break;
      };
      
      case VCPJ_PLACEJUMP:
	  __DBGpr_com(" Place jumper case");
      case VCPJ_MODIFY:
	  __DBGpr_com(" Place-jumper/Accept-modifications-of-jumper case");
      case VCPJ_CANCELJUMP:
      {
	  IGRint	NbRowsNew, NbRowsExist, PinNum=0, PrevTermPins=0;
	  IGRboolean	bIsCCdisp=FALSE;

	  __DBGpr_com( " Reached Place-Jumper/Modify/Cancel-Modify case." );

	  NbRowsNew=(me->bDblSidedTerminal)?(2*me->nNumConTab):me->nNumConEnt;
	  __DBGpr_int(" Number of rows in multi column field",NbRowsNew);

	  for( i=0 ; i<NbRowsNew ; i++ )
	  {
	      IGRint	sel_flag;

	      FImcf_get_select( fptr, VCPJ_TERMPOS, i, &sel_flag );

	      if(sel_flag)
	      {
		  IGRint    dStrLen, temp;
		  IGRchar   szTermMod[VC_MAX_MOD_ID],szTermPos[VC_MAX_POS_ID];

		  __DBGpr_int(" selected row no:",i);

		  FIfld_get_text_length( fptr, VCPJ_TERMPOS, i, VC_MODCOLNO,
		  			 &dStrLen );
		  FIfld_get_text( fptr, VCPJ_TERMPOS, i, VC_MODCOLNO,
		  		  dStrLen, szTermMod, &temp, &temp );

		  FIfld_get_text_length( fptr, VCPJ_TERMPOS, i, VC_POSCOLNO,
		  			 &dStrLen );
		  FIfld_get_text( fptr, VCPJ_TERMPOS, i, VC_POSCOLNO,
		  		  dStrLen, szTermPos, &temp, &temp );

		  FImcf_set_select( fptr, VCPJ_TERMPOS, i, FALSE );

		  FIfld_get_num_rows( fptr, VCPJ_EXISTJUMP, &NbRowsExist);
		  __DBGpr_int(" Num of existing terminal posns",NbRowsExist);
		  FIfld_set_num_rows( fptr, VCPJ_EXISTJUMP, NbRowsExist+1);

		  if( ! bIsCCdisp )
		  {
		      bIsCCdisp=TRUE;
		      FIfld_set_text( fptr, VCPJ_EXISTJUMP, NbRowsExist, 0,
				      me->CompCode, FALSE);

		      if( gadget_label != VCPJ_PLACEJUMP )
			  --(me->nNbJumper);

		      __DBGpr_int(" No. jumpers ",me->nNbJumper);

		      if( gadget_label == VCPJ_PLACEJUMP )
			  me->JumperData[me->nNbJumper].JumperId =
							      me->nNbJumper;

		      if( gadget_label != VCPJ_CANCELJUMP )
		      {
			  strcpy( me->JumperData[me->nNbJumper].jump_code ,
							     me->CompCode );
			  me->JumperData[me->nNbJumper].no_mto_flag =
							 (me->bMTO)?'y':'n';

			  FIg_get_state( fptr, VCPJ_MAXCONN, &temp );
			  me->JumperData[me->nNbJumper].cnt_vs_max  =
								  temp?'n':'y';

			  FIfld_get_text_length( fptr, VCPJ_NEWJUMPREM, 0, 0,
								 &dStrLen );
			  FIfld_get_text( fptr, VCPJ_NEWJUMPREM, 0, 0, dStrLen,
				      me->JumperData[me->nNbJumper].remarks,
							     &temp, &temp );
			  __DBGpr_str(" Jumper's remarks",
				     me->JumperData[me->nNbJumper].remarks); 
		      }

		      if( me->nNbJumper )
		      {
			  IGRint	tmp_i;

			  for( tmp_i=0 ; tmp_i<me->nNbJumper ; tmp_i++ )
			      PrevTermPins += me->JumperData[tmp_i].NumTermPins;
			  __DBGpr_int(" No. terminal posns",PrevTermPins);
		      }
		  }
		  else
		      FIfld_set_text( fptr, VCPJ_EXISTJUMP, NbRowsExist, 0,
				      "", FALSE);

		  __DBGpr_int("PrevTermPins",PrevTermPins); 
		  __DBGpr_int("PinNum",PinNum); 

//		  if( gadget_label == VCPJ_MODIFY )
//		      PrevTermPins -= me->JumperData[me->nNbJumper].NumTermPins;

		  if( gadget_label == VCPJ_PLACEJUMP )
		      me->JumperConn[PrevTermPins+PinNum].JumperId =
							      me->nNbJumper;

		  FIfld_set_text( fptr, VCPJ_EXISTJUMP, NbRowsExist, 1,
		  		  szTermMod, FALSE);
		  FIfld_set_text( fptr, VCPJ_EXISTJUMP, NbRowsExist, 2,
		  		  szTermPos, FALSE);

		  if( gadget_label != VCPJ_CANCELJUMP )
		  {
		      strcpy( me->JumperConn[PrevTermPins+PinNum].Mod ,
								    szTermMod);
		      strcpy( me->JumperConn[PrevTermPins+PinNum].Pos ,
								    szTermPos);
		  }

		  ++PinNum;
	      }
	  }
	  me->JumperData[me->nNbJumper].NumTermPins = PinNum;
	  __DBGpr_int("No Terminal pins in this jumper",PinNum); 

	  ++(me->nNbJumper);
	  __DBGpr_int(" Number of jumpers in command object",me->nNbJumper);

	  FIfld_set_text( fptr, VCPJ_POSUSED, 0, 0, "", 0);
	  FIg_enable( fptr, VCPJ_EXISTJUMP );

	  if( gadget_label != VCPJ_PLACEJUMP )
	  {
	      FIg_erase( fptr, VCPJ_MODIFY );
	      FIg_erase( fptr, VCPJ_CANCELJUMP );

	      FIg_erase( fptr, VCPJ_TITLE_MODJUMP );
	      FIg_display( fptr, VCPJ_TITLE_NEWJUMP );

	      FIg_display( fptr, VCPJ_PLACEJUMP );
	  }
		  /* Disable the place jumper and other gadgets */
	  FIg_disable( fptr, VCPJ_PLACEJUMP);
	  FIg_disable( fptr, VCPJ_UNSELROWS);
	  FIg_disable( fptr, VCPJ_TERMPOS);
	  FIfld_set_text( fptr, VCPJ_COMPCODE, 0, 0, "", 0);
	  FIfld_set_text( fptr, VCPJ_NEWJUMPDES, 0, 0, "", 0);
	  FIfld_set_text( fptr, VCPJ_NEWJUMPREM, 0, 0, "", 0);
	  FIg_set_text( fptr, VCPJ_MAXPOS, "");

	  break;
      };

      case VCPJ_MAXCONN:
      {
	  __DBGpr_com( " Reached Max. Connection case " );
	  break;
      };

      case VCPJ_MODJUMP:
      {
	  IGRint	sel_flag,NbRows,NoOfPins,jump_row,jump_id;
	  IGRint	length,temp,row_j,no_j,NoTermPos;
	  IGRchar	szCCode[VC_MAX_CCODE],szNumPos[4];
	  IGRchar	szMod[VC_MAX_MOD_ID],szPos[VC_MAX_POS_ID];

	  __DBGpr_com( " Reached Modify Jumper case " );

	  FIfld_get_num_rows( fptr, VCPJ_EXISTJUMP, &NbRows);

	    /* Step 1: Get details of Jumper to be modified */

	  for( jump_row=0 , sel_flag=FALSE ; !sel_flag ; ++jump_row )
	      FImcf_get_select( fptr, VCPJ_EXISTJUMP, jump_row, &sel_flag );
	  --jump_row;
	  __DBGpr_int(" Row of jumper",jump_row);

	  for( jump_id = 0 , NoOfPins = 0 ;
	       jump_id < me->nNbJumper  &&  NoOfPins != jump_row ;
	       jump_id++
	     )
	      NoOfPins += me->JumperData[jump_id].NumTermPins;

	  __DBGpr_int(" Jumper index",jump_id);
	  __DBGpr_int(" No. pins taken by prev jumpers",NoOfPins);

	  FIfld_get_num_rows( fptr, VCPJ_EXISTJUMP, &NoTermPos);
	  __DBGpr_int(" No rows in Existing terminal cons MC field",NoTermPos);

	  __DBGpr_int(" jumpdata ID", me->JumperData[jump_id].JumperId);
	  for( no_j=0 ; no_j<NoTermPos ; no_j++ )
	      if( me->JumperConn[no_j].JumperId ==
					  me->JumperData[jump_id].JumperId )
		  break;

	  __DBGpr_int(" Jump conn index for jump_id",no_j);
	  __DBGpr_int(" ID from jumpcon", me->JumperConn[no_j].JumperId);
	  __DBGpr_int(" No terminal pins for this jumper",
				       me->JumperData[jump_id].NumTermPins);


	    /* Step 2: Set-up upper portion of form for jumper-modification */

	  FIfld_get_text_length(fptr, VCPJ_EXISTJUMP, jump_row, 0, &length);
	  if( length > 1 )
	      FIfld_get_text( fptr, VCPJ_EXISTJUMP, jump_row, 0, length,
			      szCCode, &temp, &temp );
	  FIfld_set_text( fptr, VCPJ_COMPCODE, 0, 0, szCCode, FALSE );
	  FIfld_set_text( fptr, VCPJ_NEWJUMPREM, 0, 0,
		  	  me->JumperData[jump_id].remarks, FALSE );

	  status = om$send (msg = message VCCmdPJ.form_notification
		  					( 0, VCPJ_UNSELROWS,
							  0, me->form_ptr ),
		       targetid = my_id );

	  FIg_erase( fptr, VCPJ_TITLE_NEWJUMP );
	  FIg_display( fptr, VCPJ_TITLE_MODJUMP );
	  FIg_erase( fptr, VCPJ_PLACEJUMP );
	  FIg_display( fptr, VCPJ_MODIFY );
	  FIg_display( fptr, VCPJ_CANCELJUMP );

	    /* Code below -> For highlighting specific rows in VCPJ_TERMPOS
	     * MC field. */

	  FIfld_get_num_rows( fptr, VCPJ_TERMPOS, &NoTermPos);
	  __DBGpr_int(" Num rows in terminal conns MC field",NoTermPos);

	  for( row_j=0 ; row_j<NoTermPos ; row_j++ )
	  {
	      FIfld_get_text_length(fptr, VCPJ_TERMPOS, row_j, VC_MODCOLNO,
								   &length);
	      if( length > 1 )
		  FIfld_get_text( fptr, VCPJ_TERMPOS, row_j, VC_MODCOLNO,
					      length, szMod, &temp, &temp );

	      __DBGpr_str(" Module in field",szMod);
	      __DBGpr_str(" Module in jumper",me->JumperConn[no_j].Mod);

	      FIfld_get_text_length(fptr, VCPJ_TERMPOS, row_j, VC_POSCOLNO,
								   &length);
	      if( length > 1 )
		  FIfld_get_text( fptr, VCPJ_TERMPOS, row_j, VC_POSCOLNO,
					      length, szPos, &temp, &temp );
	      __DBGpr_str(" Position in field",szPos);
	      __DBGpr_str(" Position in jmper",me->JumperConn[no_j].Pos);

	      if( ! strcmp( szMod , me->JumperConn[no_j].Mod ) &&
		  ! strcmp( szPos , me->JumperConn[no_j].Pos ) )
	      {
		  __DBGpr_com(" Match found!");
		  FImcf_set_select( fptr, VCPJ_TERMPOS, row_j, TRUE );
		  ++no_j;
	      }

	      if( no_j == NoOfPins+me->JumperData[jump_id].NumTermPins )
		  break;
	  }
	  sprintf(szNumPos,"%d",me->JumperData[jump_id].NumTermPins);
	  FIfld_set_text( fptr, VCPJ_POSUSED, 0, 0, szNumPos, 0);
	  FIg_enable( fptr, VCPJ_UNSELROWS );

	  temp = me->JumperData[jump_id].cnt_vs_max=='y' ? FALSE : TRUE;
	  FIg_set_state( fptr, VCPJ_MAXCONN, temp );

	  me->bMTO = me->JumperData[jump_id].no_mto_flag=='y' ? TRUE : FALSE ;
	  FIg_set_state( fptr, VCPJ_BOM, !me->bMTO );

	    /* Step 3: Store the jumper to be modified, at the last.*/

	  no_j -= me->JumperData[jump_id].NumTermPins;

	  __DBGpr_int(" Jumper data id",jump_id);
	  __DBGpr_int(" Jumper conn index",no_j);
	  __DBGpr_int(" No. jumpers", me->nNbJumper );

	  FIg_set_state( fptr, VCPJ_REMJUMP, FALSE );

	  if( jump_id < me->nNbJumper-1 )
	  {
	      struct VCJumpData	 ModJumpData;
	      struct VCJumpConn	*ModJumpConn;
	      IGRint		 ji;


	      ModJumpData.JumperId    = me->JumperData[jump_id].JumperId;
	      ModJumpData.cnt_vs_max  = me->JumperData[jump_id].cnt_vs_max;
	      ModJumpData.NumTermPins = me->JumperData[jump_id].NumTermPins;
	      ModJumpData.no_mto_flag = me->JumperData[jump_id].no_mto_flag;
	      strcpy( ModJumpData.jump_code, me->JumperData[jump_id].jump_code);
	      strcpy( ModJumpData.remarks, me->JumperData[jump_id].remarks);

	      ModJumpConn = _CALLOC(ModJumpData.NumTermPins, struct VCJumpConn);

	      for( ji=0 ; ji<ModJumpData.NumTermPins ; ++ji )
	      {
		  (ModJumpConn+ji)->JumperId = me->JumperConn[no_j+ji].JumperId;
		  strcpy( (ModJumpConn+ji)->Mod, me->JumperConn[no_j+ji].Mod);
		  strcpy( (ModJumpConn+ji)->Pos, me->JumperConn[no_j+ji].Pos);
	      }

	      status = om$send (msg = message VCCmdPJ.form_notification
				       ( 0, VCPJ_REMJUMP, 0, me->form_ptr ),
			   targetid = my_id );

	      me->JumperData[me->nNbJumper].JumperId = ModJumpData.JumperId;
	      strcpy( me->JumperData[me->nNbJumper].jump_code ,
						    ModJumpData.jump_code );
	      me->JumperData[me->nNbJumper].no_mto_flag =
						    ModJumpData.no_mto_flag;
	      me->JumperData[me->nNbJumper].cnt_vs_max  =
						     ModJumpData.cnt_vs_max;
	      strcpy( me->JumperData[me->nNbJumper].remarks ,
						      ModJumpData.remarks );

	      FIfld_get_num_rows( fptr, VCPJ_EXISTJUMP, &no_j);

	      for( ji=0 ; ji<ModJumpData.NumTermPins ; ++ji )
	      {
		  me->JumperConn[no_j+ji].JumperId = (ModJumpConn+ji)->JumperId;
		  strcpy( me->JumperConn[no_j+ji].Mod, (ModJumpConn+ji)->Mod );
		  strcpy( me->JumperConn[no_j+ji].Pos, (ModJumpConn+ji)->Pos );
	      }

	      _FREE( ModJumpConn );
	  }
	  else
	  {
	      status = om$send (msg = message VCCmdPJ.form_notification
				       ( 0, VCPJ_REMJUMP, 0, me->form_ptr ),
			   targetid = my_id );
	  }

	  __DBGpr_int(" No. jumpers after deleting jumper to be modified",
							    me->nNbJumper );
	  ++me->nNbJumper;
	  __DBGpr_int(" No. jumpers after setting jumper at the end",
							    me->nNbJumper );

	  FIg_set_state( fptr, VCPJ_REMJUMP, TRUE );
	  FIg_disable( fptr, VCPJ_REMJUMP );
	  FIg_disable( fptr, VCPJ_MODJUMP );
	      


	    /* Step 4: Call form_notification for this jumper's comp_code. */

	  strcpy( me->CompCode , szCCode );
	  status = om$send (msg = message VCCmdPJ.form_notification
		  					( 0, VCPJ_COMPCODE,
							  0, me->form_ptr ),
		       targetid = my_id );

	  break;
      }

      case VCPJ_REMJUMP:
      {
	  IGRint	state;
	  __DBGpr_com( " Reached Remove Jumper case " );

	  FIg_get_state( fptr, VCPJ_REMJUMP, &state );
	  if( ! state )
	  {
	      IGRint	NbRows, tmp_i;

	      FIfld_get_num_rows( fptr, VCPJ_EXISTJUMP, &NbRows);
	      __DBGpr_int(" No. rows in existing jumpers field",NbRows);
	      for( tmp_i=0 ; tmp_i<NbRows ; ++tmp_i )
	      {
		  IGRint	sel_flag;

		  FImcf_get_select( fptr, VCPJ_EXISTJUMP, tmp_i, &sel_flag );
		  if( sel_flag )
		  {
		      IGRint	jump_id, NoOfPins, DelJumpPins;

	    /* Step 1: Get details of Jumper to be deleted */

		      for( jump_id=0 , NoOfPins=0 ;
		           jump_id<me->nNbJumper && NoOfPins!=tmp_i ;
			   jump_id++
			 )
			  NoOfPins += me->JumperData[jump_id].NumTermPins;

		      __DBGpr_int(" Jumper Id to be deleted",jump_id);
		      __DBGpr_int(" Selected Row",tmp_i);
		      __DBGpr_int(" No. pins taken by prev jumpers",NoOfPins);

		      DelJumpPins = me->JumperData[jump_id].NumTermPins;
		      __DBGpr_int(" No. pins by this jumper", DelJumpPins);

	    /* Step 2: Delete the rows from the MC field */

		      FIfld_delete_rows( fptr, VCPJ_EXISTJUMP, NoOfPins,
							      DelJumpPins );

		      __DBGpr_com(" Deleted rows, calling set_num_rows");
		      FIfld_set_num_rows( fptr, VCPJ_EXISTJUMP,
					  NbRows-DelJumpPins );

	    /* Step 3: Remove this jumper from command object */

		      if( jump_id != me->nNbJumper-1 )
		      {

	  /* Indentation below broken to accomodate entire lines */
	  /* The two for-loops below come under the above if-condition. */

	  /* First remove the jumper data from the comand object. */
	  
      for( i=jump_id ; i<me->nNbJumper-1 ; i++ )
      {
#ifdef vdsDEBUG
	  printf("Data of Jump id:%d being replaced by Jump id:%d\n",i,i+1);
#endif
	  me->JumperData[i].JumperId    = me->JumperData[i+1].JumperId;
	  strcpy(me->JumperData[i].jump_code,me->JumperData[i+1].jump_code);
	  me->JumperData[i].no_mto_flag = me->JumperData[i+1].no_mto_flag;
	  me->JumperData[i].cnt_vs_max  = me->JumperData[i+1].cnt_vs_max;
	  me->JumperData[i].NumTermPins = me->JumperData[i+1].NumTermPins;
	  strcpy(me->JumperData[i].remarks,me->JumperData[i+1].remarks);
      }
      me->JumperData[i].JumperId    = 0;
      me->JumperData[i].jump_code[0]= '\0';
      me->JumperData[i].no_mto_flag = 0;
      me->JumperData[i].cnt_vs_max  = 0;
      me->JumperData[i].NumTermPins = 0;
      me->JumperData[i].remarks[0]  = '\0';

	  /* Now remove the connection information of this jumper from the
	   * comand object. */
      
       for( i=NoOfPins ; i<NbRows-DelJumpPins ; i++ )
       {
#ifdef vdsDEBUG
	   printf("Conn info of Jump conn id:%d replaced by Jump conn id:%d\n",
							 i,(i+DelJumpPins));
#endif
	   me->JumperConn[i].JumperId=me->JumperConn[(i+DelJumpPins)].JumperId;
	   strcpy(me->JumperConn[i].Mod,me->JumperConn[(i+DelJumpPins)].Mod);
	   strcpy(me->JumperConn[i].Pos,me->JumperConn[(i+DelJumpPins)].Pos);
       }
       me->JumperConn[i].JumperId=0;
       me->JumperConn[i].Mod[0]='\0';
       me->JumperConn[i].Pos[0]='\0';

		      }
		      --me->nNbJumper;
		      __DBGpr_int(" Number of Jumpers left", me->nNbJumper);

		      break;
		  }
	      }

	      FIfld_set_text( fptr, VCPJ_OLDJUMPREM, 0, 0, "", 0 );
	      FIfld_set_text( fptr, VCPJ_OLDJUMPDES, 0, 0, "", 0 );
	      FIg_disable( fptr, VCPJ_REMJUMP );
	      FIg_disable( fptr, VCPJ_MODJUMP );

	      if( ! me->nNbJumper )
		  FIg_disable( fptr, VCPJ_EXISTJUMP );
	  }
	  else
	  {
	      FIfld_set_text( fptr, VCPJ_MSGFLD, 0, 0, "Confirm Jumper Removal by selecting the Remove Jumper button again", 0);
	  }
	  break;
      };

      case VCPJ_EXISTJUMP:
      {
	  IGRint	sel_row, col, temp, NbRows, txtlen, jump_row, NoOfPins;
	  IGRchar	szCompDesc[VC_MAX_SDESC],szCompCode[VC_MAX_CCODE];

	  __DBGpr_com( " Reached Existing Jumper case " );

	  FIfld_get_active_row (fptr, VCPJ_EXISTJUMP, &sel_row, &temp);
	  __DBGpr_int(" Selected Row",sel_row);

	  FImcf_get_active_col (fptr, VCPJ_EXISTJUMP, &col, &temp);
	  __DBGpr_int(" Selected column",col);

		/* First deselect all rows */
	  FIfld_get_num_rows( fptr, VCPJ_EXISTJUMP, &NbRows);
	  __DBGpr_int(" Number of rows in VCPJ_EXISTJUMP",NbRows);
	  for( i=0 ; i<NbRows ; i++ )
	      FImcf_set_select( fptr, VCPJ_EXISTJUMP, i, FALSE );

		/* Track the row corresponding to the Jumper of selected row */
	  FIfld_get_text_length( fptr, VCPJ_EXISTJUMP, sel_row, 0, &txtlen );
	  jump_row=sel_row;
	  while( txtlen <= 1 )
	  {
	      --jump_row;
	      if( jump_row < 0 )
		  break;
	      FIfld_get_text_length(fptr, VCPJ_EXISTJUMP, jump_row, 0, &txtlen);
	  }
	  __DBGpr_int(" Jumper row",jump_row);

		/* get jumper's compcode, and print description and remarks */
	  FIfld_get_text( fptr, VCPJ_EXISTJUMP, jump_row, 0, txtlen,
		  	  szCompCode, &temp, &temp);
	  __DBGpr_str(" selected jumper's comp code", szCompCode);

	  for( i=0 ; i<me->nCC ; i++ )
	  {
	      IGRint	idsp,jdsp;

	      idsp = i * VC_MAX_CCODE;
	      jdsp = i * VC_MAX_SDESC;

	      if( ! strcmp (szCompCode, &me->CClist[idsp]) )
	      {
		  strcpy (szCompDesc, &me->CCdesc[jdsp]);
		  __DBGpr_str(" comp desc",szCompDesc);
		  FIfld_set_text(fptr, VCPJ_OLDJUMPDES, 0, 0, szCompDesc, 0 );
		  break;
	      }
	  }

	  for( i=0 , NoOfPins=0 ; NoOfPins!=jump_row && i<me->nNbJumper; i++ )
	  {
	      __DBGpr_int(" Jumper ID",me->JumperData[i].JumperId );
	      __DBGpr_int(" No. pins in jumper",me->JumperData[i].NumTermPins);
	      NoOfPins += me->JumperData[i].NumTermPins;
	      __DBGpr_int(" Total number of pins so far",NoOfPins);
	  }
	  __DBGpr_int(" Jumper index",i);

	  __DBGpr_str(" Jumper's remarks", me->JumperData[i].remarks); 
	  FIfld_set_text( fptr, VCPJ_OLDJUMPREM, 0, 0,
			  me->JumperData[i].remarks, 0 );

		/* Select all rows corresponding to that Jumper */
	  for( i=jump_row ; i<=sel_row ; i++ )
	      FImcf_set_select( fptr, VCPJ_EXISTJUMP, i, TRUE );
	  do
	  {
	      FIfld_get_text_length(fptr, VCPJ_EXISTJUMP, i, 0, &txtlen);
	      if( txtlen <=1 )
		  FImcf_set_select( fptr, VCPJ_EXISTJUMP, i, TRUE );
	      ++i;
	  }
	  while( txtlen <= 1 && i<NbRows );

	  FIg_enable( fptr, VCPJ_MODJUMP );
	  FIg_enable( fptr, VCPJ_REMJUMP );

	  break;
      };

      case VCPJ_UNSELROWS:
      {
	  IGRint	sel_flag,NbRows;
	  __DBGpr_com( " Reached Unselect selected rows case " );

	  NbRows = (me->bDblSidedTerminal)?(2*me->nNumConTab):me->nNumConEnt;

	  for( i=0 ; i<NbRows ; i++ )
	  {
		  /* Unselect all the selected rows */
	      FImcf_get_select( fptr, VCPJ_TERMPOS, i, &sel_flag );
	      if(sel_flag)
		  FImcf_set_select( fptr, VCPJ_TERMPOS, i, FALSE );
	  }
	  FIfld_set_text( fptr, VCPJ_POSUSED, 0, 0, "", 0);

	  FIg_erase( fptr, VCPJ_TITLE_MODJUMP );
	  FIg_display( fptr, VCPJ_TITLE_NEWJUMP );
	  FIg_display( fptr, VCPJ_PLACEJUMP );
	  FIg_erase( fptr, VCPJ_MODIFY );
	  FIg_erase( fptr, VCPJ_CANCELJUMP );
		  /* Disable the place jumper and cancel gadgets */
	  FIg_disable( fptr, VCPJ_PLACEJUMP);
	  FIg_disable( fptr, VCPJ_UNSELROWS);
	  break;
      };

      default:
	  __DBGpr_com( " Reached default case " );
    }

quit:
    End
    return OM_S_SUCCESS;
}

method VCGetJumpMaxPos ( IGRlong *sts; IGRchar *szCompCode )
{
  IGRlong status=OM_S_SUCCESS, retmsg;
  struct GRid	ModelId;
  struct ret_struct res;

  SetProc( Md VCGetJumpMaxPos ); Begin 

  __DBGpr_str( " Jumper Compcode ", szCompCode );

  /* Get the Model Id corresponding to the Jumper Code */
  status = vc$jumper_old( code = szCompCode,
			  GRid = &ModelId );

  __DBGpr_obj( " Jumper Model Id ", ModelId );

  if( ModelId.objid != NULL_OBJID )
  {
      status = om$send (msg     = message VCDB.VCGetAttr (&retmsg,
			      NULL, VC_N_JUMP_MAX_POSITION_AN, &res),
			targetid = ModelId.objid,
			targetos = ModelId.osnum);
      as$status();

      if( status & retmsg & 1 )
      {
	   *sts = MSSUCC;
	   me->nMaxNoPos = (IGRshort) res.var.root_pm_st.value;
	   __DBGpr_int( " Max. of position for Jumper ", me->nMaxNoPos );
      }
      else
      {
	  *sts = MSFAIL;
	  __DBGpr_com( " Get Attr.'max_position' failed " );
      }
  }
  else *sts = MSFAIL;

  quit:
  End
  return OM_S_SUCCESS;
}

end implementation VCCmdPJ;
