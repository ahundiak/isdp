
/* $Id: VCCmdSAcat.I,v 1.4 2002/05/08 15:48:23 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdSAcat.I
 *
 * Description:
 *      Implementation file for command objects that display and
 *      edit attributes.
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdSAcat.I,v $
 *  Revision 1.4  2002/05/08 15:48:23  anand
 *  Files added/modified for sub-cable functionality.
 *
 *  Revision 1.3  2001/02/20 01:09:45  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.2  2001/01/11 20:05:25  anand
 *  SP merge
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1999/11/10  12:52:16  pinnacle
# Replaced: vccmd/VCCmdSAcat.I for:  by svngidug for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/02/18  10:43:40  pinnacle
# Replaced: vccmd/VCCmdSAcat.I for: TR179702189 by aharihar for route
#
# Revision 1.2  1998/02/03  14:01:12  pinnacle
# Replaced: vccmd/VCCmdSAcat.I for:  by apazhani for route
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/08/11  21:56:04  pinnacle
# Replaced: vccmd/VCCmdSAcat.I for:  by hverstee for cabling
#
# Revision 1.3  1997/08/05  22:52:42  pinnacle
# Replaced: vccmd/VCCmdSAcat.I for:  by hverstee for cabling
#
# Revision 1.2  1997/07/31  20:08:00  pinnacle
# Replaced: vccmd/VCCmdSAcat.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/29  15:03:52  pinnacle
# Created: vccmd/VCCmdSAcat.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  02/03/98      Alwin   Modified the methods VCSACabDsp() and VCSASysForm()
 *			  to list the Connection components, when required.
 *  16 Feb 98     Anand   Modified the Backshell-case in method VCSASysForm
 *			  for displaying tag and type fields of terminal and
 *			  equipment - TR 179702189
 *  11/09/99	  Satish  Modified VCSALoadLnAttr for CR179702190 
 *  06/18/00      law     Turned on display of eqtag and eqtyp-tr179901681 
 *
 *************************************************************************/

class implementation VCCmdSA;

#include "vrdbgmacros.h"
#include "VCmacros.h"
#include "VCCmdSet.h"
#include "VCchansel.h"

#include "VDmem.h"

#include "VCLead.h"

%safe
#include "VX_FIproto.h"
%endsafe

#include "VRMcForm.h"

/*
#define  MY_DEBUG
*/

from  VCDB          import  VCGpAnum;

from  VCRoot        import  VCGetRep;
from  VCRoot        import  VCGetMtoFlag;
from  VCRoot        import  VCGetType;
from  VCRoot        import  VCGetCode;
from  VCRoot        import  VCGetTagNo;
from  VCRoot        import  VCGetProduct;
from  VCRoot        import  VCGetParams;
from  VCRoot        import  VCGetTopology;
from  VCRoot        import  VCGetInstance;
from  VCRoot        import  VCChgParam;
from  VCRoot        import  VCGetExpand;
from  VCRoot        import  VCParent;

from  VCMac         import  VCGetEquipTag;
from  VCMac         import  VCGetEquipId;

from  VCCable       import  VCCbTerm, VCAmIParCab;

from  VCTerm        import  VCTshells;

from  ACncpx        import  ACgive_structure;


method  VCSAGetData (IGRlong    *msg;
             struct  GRid       *CompId)
{
  IGRint       status;

  *msg  = MSSUCC;

  status =
  om$send( msg = message VCRoot.VCGetCode (me->CompCode),
      targetid = CompId->objid,
      targetos = CompId->osnum );

  status =
  om$send( msg  = message VCRoot.VCGetTagNo (me->CompTag),
       targetid = CompId->objid,
       targetos = CompId->osnum );

  status =
  om$send( msg = message VCRoot.VCGetRep (&me->nObjRep, NULL ),
      targetid = CompId->objid,
      targetos = CompId->osnum );

  status =
  om$send( msg = message VCRoot.VCGetType (&me->nObjType),
      targetid = CompId->objid,
      targetos = CompId->osnum );

  // If cable type (VC_GEN_CABLE), check if parent cable. Set me->bParCab
  if( me->nObjType & VC_GEN_CABLE )
  {
      IGRint NbChild;

      status = om$send( msg	 = message VCCable.VCAmIParCab( msg,
								&NbChild,
								NULL ),
			targetid = CompId->objid,
			targetos = CompId->osnum );

      me->bParCab = (NbChild!=0)?TRUE:FALSE; // Ensure set to boolean value
  }
  else
      me->bParCab = FALSE;

  // Do all initialization related to Parent cable here.
  if( me->bParCab )
  {
      /* Check for VLA size of Beginning and End terminals,
       * and set to zero if non-zero. */
      om$vla_set_dimension( varray = me->BegTerm , size = 0 );
      om$vla_set_dimension( varray = me->EndTerm , size = 0 );
      om$vla_set_dimension( varray = me->szBegTag , size = 0 );
      om$vla_set_dimension( varray = me->szEndTag , size = 0 );

      // Initialize me->Connx[] to NULL_OBJID
      me->Connx[0].objid = me->Connx[1].objid = NULL_OBJID;

      // Set terminal tag fields (upstairs) to Null strings.
      FIg_set_text (me->pSysAtt, VCSET_GDG_CABA_TRTAG, "");
      FIg_set_text (me->pSysAtt, VCSET_GDG_CABB_TRTAG, "");
  }

  status =
  om$send( msg = message VCRoot.VCGetProduct (&me->Product, NULL),
      targetid = CompId->objid,
      targetos = CompId->osnum );

  status =
  om$send( msg = message VCRoot.VCGetMtoFlag (&me->bMTO, NULL),
      targetid = CompId->objid,
      targetos = CompId->osnum );

  return OM_S_SUCCESS;
}


method  VCSACabDsp   (IGRlong    *msg;
                      IGRint      ind;
                      IGRint      ieqtyp;
                      IGRint      ieqtag;
                      IGRint      itrtyp;
                      IGRint      itrtag;
                      IGRint      ibkshl;
                      IGRint      icomp;
                      IGRint      iconn)
{
  IGRint          status;
  IGRlong         retmsg;
  IGRchar         szFld[80];
  IGRshort        nSH=0;
  IGRshort        nIN;

  SetProc( Md VCSACabDsp ); Begin;
  *msg = MSSUCC;


  nIN = ind;
  __DBGpr_int( " Terminal Index/Position ", ind );

  VC_INITSTR (szFld);

  __DBGpr_com( " Get the Terminal Parent " );

  if( me->bParCab )
  {
  /* Call a method that does the following:
   * 1. Read the terminal tag field in the form (A/B depending upon nIN).
   * 2. Call API to get beginning/end (based on nIN) terminals for our cable.
   * 3. Do a for loop on each of the above terminal ids and get their tagnos.
   * 4. If the field is non-empty, the function comes in through
   *    form_notification; set me->Connx[nIN] based on the matching tag number.
   *    Otherwise, simply set the tag numbers on the pull down list.
   */
      status = om$send( msg = message VCCmdSA.VCSACabDspAB( msg, ind ),
			targetid = my_id );
      as$status();
  }
  else
  {
      status =
      om$send(msg = message VCCable.VCCbTerm (&retmsg, nIN, &me->Connx[ind]),
	 targetid = me->CompId.objid,
	 targetos = me->CompId.osnum);
  }

  FIg_set_text (me->pSysAtt, itrtyp, szFld);
  FIg_set_text (me->pSysAtt, ibkshl, szFld);

  __DBGpr_com( " Get the Equipment Details " );
  status =
  om$send (msg = message VCCmdSA.VCSAdsp_eq
                                  (&retmsg, &me->Connx[ind],
                                   me->pSysAtt, ieqtyp, ieqtag, icomp),
      targetid = my_id);

  if (me->Connx[ind].objid == NULL_OBJID) 
  {
     __DBGpr_int( " Cable doesn't have Terminal Parent, at position ", ind );
     End
     return (OM_S_SUCCESS);
  }

  status =
  om$send(msg = message VCRoot.VCGetCode (szFld),
     targetid = me->Connx[ind].objid,
     targetos = me->Connx[ind].osnum);

  FIg_set_text (me->pSysAtt, itrtyp, szFld);

  status =
  om$send(msg = message VCRoot.VCGetTagNo (szFld),
     targetid = me->Connx[ind].objid,
     targetos = me->Connx[ind].osnum);

  FIg_set_text (me->pSysAtt, itrtag, szFld);
  FIg_enable (me->pSysAtt, iconn);

  /* First get the no. of Connection Components, connected to the Terminal */
  status =
  om$send(msg = message VCTerm.VCTshells (&retmsg, &nSH, NULL),
     targetid = me->Connx[ind].objid,
     targetos = me->Connx[ind].osnum);

  /* added by alwin, for CR179702192 */
  if ( nSH )
  {
    struct GRid *Shells=NULL;

    Shells = _MALLOC( nSH, struct GRid );
 
    __CheckPtr( Shells, "Allocation for Conn. Components failed", quit );
 
    /* After the memory Allocation, now get all the Shell Object Ids */
    status =
    om$send ( msg = message VCTerm.VCTshells( &retmsg, &nSH, Shells ),
                            targetid = me->Connx[ind].objid,
                            targetos = me->Connx[ind].osnum);
 
    __DBGpr_int( " Nb of Conn. Components ", nSH );
    if (nSH == 1 )
    {
        FIg_erase( me->pSysAtt, VCSET_GDG_CABA_BKSH_LIST );
        FIg_erase( me->pSysAtt, VCSET_GDG_CABB_BKSH_LIST );
        FIg_display( me->pSysAtt,  ibkshl );
    }
    else if( nSH > 1 )
    {
       IGRint row=0;
 
       FIg_erase( me->pSysAtt, ibkshl );
 
       if( ind == 0 ) 
          ibkshl = VCSET_GDG_CABA_BKSH_LIST;
       else
          ibkshl = VCSET_GDG_CABB_BKSH_LIST;
 
       FIg_display( me->pSysAtt, ibkshl );
  
       FIfld_set_list_num_rows( me->pSysAtt, ibkshl, 0, nSH );
       for( row=0; row<nSH; row++ )
       {
           VC_INITSTR (szFld);
 
           status = om$send(msg = message VCRoot.VCGetCode (szFld),
                         targetid = Shells[row].objid,
                         targetos = Shells[row].osnum);
  
           __DBGpr_str( " Conn. Component Code ", szFld );
           FIfld_set_list_text( me->pSysAtt, ibkshl, row, 0,
					(unsigned char *)szFld, FALSE );
       }
 
    }
 
    VC_INITSTR (szFld);

    status =
    om$send(msg = message VCRoot.VCGetCode (szFld),
         targetid = Shells[0].objid,
         targetos = Shells[0].osnum);

    FIg_set_text (me->pSysAtt, ibkshl, szFld);

    _FREE( Shells );
  }
  else
  {
     FIg_erase( me->pSysAtt, VCSET_GDG_CABA_BKSH_LIST );
     FIg_erase( me->pSysAtt, VCSET_GDG_CABB_BKSH_LIST );
  }
  /* added by alwin, for CR179702192 */

  quit:
  End
  return (OM_S_SUCCESS);
}


method VCSACabDspAB( IGRlong	*msg;
		     IGRint	nSide )
{
    IGRint	status, GadgetLabel, t1, t2, i, j;
    IGRint	NoOppTerm=0, nCorrespTerm=0, NumTerm=0;
    IGRchar	szTrmTagFld[VC_MAX_TAGNO];
    struct GRid	*TermList=NULL;

    SetProc( VCSACabDspAB ); Begin;

    GadgetLabel = nSide?VCSET_GDG_CABB_TRTAG:VCSET_GDG_CABA_TRTAG;

  /* 2. Call API to get beginning/end (based on nIN) terminals for our cable. */
  /* 3. Do a for loop on each of the above terminal ids and get their tagnos. */
    if( nSide == 0 )
	NumTerm = om$dimension_of( varray = me->BegTerm );
    else
	NumTerm = om$dimension_of( varray = me->EndTerm );

    if( NumTerm == 0 ) // VLAs not set up, set them up.
    {
	if( nSide == 0 )
	{
	    VC$GetNetworkForCable( msg		= msg,
				   p_gridCabId	= &me->CompId,
				   p_nBegTerm	= &NumTerm );
	    __DBGpr_int("Num of Beginning terminals", NumTerm);
	    FIfld_set_list_num_rows( me->pSysAtt, GadgetLabel, 0, NumTerm );

	    if( NumTerm==0 )
	    {
		__DBGpr_com(" No terminals in beginning");
		End;
		return OM_S_SUCCESS;
	    }

	    om$vla_set_dimension( varray = me->BegTerm, size = NumTerm );
	    om$vla_set_dimension( varray = me->szBegTag,
				  size	 = NumTerm*VC_MAX_TAGNO );

	    VC$GetNetworkForCable( msg		= msg,
				   p_gridCabId	= &me->CompId,
				   p_nBegTerm	= &NumTerm,
				   p_gridBegTermId = me->BegTerm );
	    __DBGpr_objlist("Beginning Terminals",NumTerm,me->BegTerm);

	    for( i=0 ; i<NumTerm ; i++ )
	    {
		status =
		om$send( msg = message VCRoot.VCGetTagNo(
						  &me->szBegTag[i*VC_MAX_TAGNO]
							),
			 targetid = me->BegTerm[i].objid,
			 targetos = me->BegTerm[i].osnum );
		__DBGpr_int("Index",i);
		__DBGpr_obj("Terminal object",me->BegTerm[i]);
		__DBGpr_str("Tag number",&me->szBegTag[i*VC_MAX_TAGNO]);
		FIfld_set_list_text( me->pSysAtt,
				     VCSET_GDG_CABA_TRTAG,
				     i, 0,
			  (unsigned char *) &me->szBegTag[i*VC_MAX_TAGNO],
				     0 );
	    }

	    if( NumTerm==1 )
	    {
		FIfld_set_text( me->pSysAtt, VCSET_GDG_CABA_TRTAG, 0, 0,
				me->szBegTag, 0 );
		me->Connx[nSide] = me->BegTerm[0];
		__DBGpr_obj("ONly terminal at beginning",me->Connx[nSide]);
		End;
		return OM_S_SUCCESS;
	    }
	}
	else
	{
	    VC$GetNetworkForCable( msg		= msg,
				   p_gridCabId	= &me->CompId,
				   p_nEndTerm	= &NumTerm );
	    __DBGpr_int("Num of ending terminals", NumTerm);
	    FIfld_set_list_num_rows( me->pSysAtt, GadgetLabel, 0, NumTerm );

	    if( NumTerm==0 )
	    {
		__DBGpr_com(" No terminals at end");
		End;
		return OM_S_SUCCESS;
	    }

	    om$vla_set_dimension( varray = me->EndTerm, size = NumTerm );
	    om$vla_set_dimension( varray = me->szEndTag,
				  size	 = NumTerm*VC_MAX_TAGNO );

	    VC$GetNetworkForCable( msg		= msg,
				   p_gridCabId	= &me->CompId,
				   p_nEndTerm	= &NumTerm,
				   p_gridEndTermId = me->EndTerm );
	    __DBGpr_objlist("Ending Terminals",NumTerm,me->EndTerm);

	    for( i=0 ; i<NumTerm ; i++ )
	    {
		status =
		om$send( msg = message VCRoot.VCGetTagNo(
						&(me->szEndTag[i*VC_MAX_TAGNO])
							),
			 targetid = me->EndTerm[i].objid,
			 targetos = me->EndTerm[i].osnum );
		__DBGpr_int("Index",i);
		__DBGpr_obj("Terminal object",me->EndTerm[i]);
		__DBGpr_str("Tag number",&(me->szEndTag[i*VC_MAX_TAGNO]));
		FIfld_set_list_text( me->pSysAtt,
				     VCSET_GDG_CABB_TRTAG,
				     i, 0,
			      (unsigned char *)&(me->szEndTag[i*VC_MAX_TAGNO]),
				     0 );
	    }

	    if( NumTerm==1 )
	    {
		FIfld_set_text( me->pSysAtt, VCSET_GDG_CABB_TRTAG, 0, 0,
				me->szEndTag, 0 );
		me->Connx[nSide] = me->EndTerm[0];
		__DBGpr_obj("ONly terminal at end",me->Connx[nSide]);
		End;
		return OM_S_SUCCESS;
	    }
	}
    }


    VC_INITSTR(szTrmTagFld);

    FIfld_get_text( me->pSysAtt, GadgetLabel, 0, 0,
		    VC_MAX_TAGNO, (unsigned char*)szTrmTagFld, &t1, &t2 );
    __DBGpr_str("Tag number read from field",szTrmTagFld);

  /* 4. If the field is non-empty, the function comes in through
   *    form_notification; set me->Connx[nIN] based on the matching tag number.
   *    Otherwise, simply set the tag numbers on the pull down list.          */

    if( ! VC_EMPTYSTR(szTrmTagFld) )
    {
	for( i=0 ; i<NumTerm ; i++ )
	{
	    if( strcmp( szTrmTagFld, ( nSide ? &(me->szEndTag[i*VC_MAX_TAGNO])
					     : &(me->szBegTag[i*VC_MAX_TAGNO]) )
		      ) == 0
	      )
	    {
		// Found matching terminal.
		me->Connx[nSide] = ( nSide ? (me->EndTerm[i])
					   : (me->BegTerm[i]) );
		__DBGpr_obj("Terminal chosen from tag",me->Connx[nSide]);

		status =
		VCGetMatchLeadTerminals( &(me->Connx[nSide]), &(me->CompId),
					 &nCorrespTerm, NULL );

		if( !(status&1) )
		{
		    __DBGpr_com("VCGetMatchLeadTerminals failed!");
		    End;
		    return OM_E_ABORT;
		}

		// Set the pull down on the OTHER side!
		FIfld_set_list_num_rows( me->pSysAtt,
					 ( nSide ? VCSET_GDG_CABA_TRTAG
						 : VCSET_GDG_CABB_TRTAG ),
					 0, nCorrespTerm );

		if( nCorrespTerm==0 )
		{
		    __DBGpr_com("No terminals at other end for chosen term");
		    UI_status("No terminals at other end for chosen terminal");
		    End;
		    return OM_S_SUCCESS;
		}

		TermList = _CALLOC( nCorrespTerm, struct GRid );

		status =
		VCGetMatchLeadTerminals( &(me->Connx[nSide]), &(me->CompId),
					 &nCorrespTerm, TermList );

		if( !(status&1) || nCorrespTerm==0 || TermList==NULL )
		{
		    __DBGpr_com("VCGetMatchLeadTerminals failed!");
		    End;
		    return OM_E_ABORT;
		}
		break;
	    } // end if strcmp
	} // end for

	__DBGpr_int("Going to fill list on which side?",!nSide);
	__DBGpr_objlist("List of matching terminals",nCorrespTerm,TermList);

	// Still within if not empty szTrmTagFld!
	if( nSide==0 )
	{
	    NoOppTerm = om$dimension_of( varray = me->EndTerm );
	    __DBGpr_objlist("Filter end terminals",NoOppTerm,me->EndTerm);
	    // Fill other side list.
	    FIfld_set_list_num_rows( me->pSysAtt, VCSET_GDG_CABB_TRTAG, 0,
				     nCorrespTerm );

	    for( i=0 ; i<nCorrespTerm ; i++ )
	    {
		for( j=0 ; j<NoOppTerm ; j++ )
		{
		    if( TermList[i].objid == me->EndTerm[j].objid &&
			TermList[i].osnum == me->EndTerm[j].osnum )
		    {
			FIfld_set_list_text( me->pSysAtt, VCSET_GDG_CABB_TRTAG,
					     i, 0,
			      (unsigned char *)&(me->szEndTag[j*VC_MAX_TAGNO]),
					     FALSE );
			break;
		    }
		}
	    }
	}
	else
	{
	    NoOppTerm = om$dimension_of( varray = me->BegTerm );
	    __DBGpr_objlist("Filter begin terminals",NoOppTerm,me->BegTerm);
	    // Fill other side list.
	    FIfld_set_list_num_rows( me->pSysAtt, VCSET_GDG_CABA_TRTAG, 0,
				     nCorrespTerm );

	    for( i=0 ; i<nCorrespTerm ; i++ )
	    {
		for( j=0 ; j<NoOppTerm ; j++ )
		{
		    if( TermList[i].objid == me->BegTerm[j].objid &&
			TermList[i].osnum == me->BegTerm[j].osnum )
		    {
			__DBGpr_int("matching i ...",i);
			__DBGpr_int("... with j",j);
			FIfld_set_list_text( me->pSysAtt, VCSET_GDG_CABA_TRTAG,
					     i, 0,
			      (unsigned char *)&(me->szBegTag[j*VC_MAX_TAGNO]),
					     FALSE );
			break;
		    }
		}
	    }
	}
    } // End if not empty szTrmTagFld

    End;
    return OM_S_SUCCESS;
}



/*C  update the sys form */
method VCSASysForm (IGRlong   *msg)    /* I/O - return status */

{
  IGRint          status;
  IGRlong         retmsg;
  IGRchar        *FormPtr;
  IGRshort        nIndex, nMap;

  struct ret_struct   rts;

  SetProc( Md VCSASysForm ); Begin 

  nIndex = nMap = -1;

  FormPtr = me->pSysAtt;

  if ((me->iSynType == 2) ||
      (me->CompId.osnum != VC_GLB_writable_os))
  {
    FIg_disable (FormPtr, FI_EXECUTE);
    FIg_disable (FormPtr, FI_ACCEPT);
  }
  else
  {
    FIg_enable (FormPtr, FI_EXECUTE);
    FIg_enable (FormPtr, FI_ACCEPT);
  }

  /* Ensure the Tag Number Text is displayed properly. B'cas when the user
  select more than one component and views that it time it disappears. This 
  Tag Number Text is not needed. Alwin */

  if(  me->nObjType & VC_GEN_BKSHLL )
    FIg_erase( me->pSysAtt, VCSET_GDG_TAG_TXT );
  else
    FIg_display( me->pSysAtt, VCSET_GDG_TAG_TXT );

  if (me->nObjType & VC_GEN_CABLE)
  {
      /* Set the terminal tag fields to null (it is important). */
    FIg_set_text (FormPtr, VCSET_GDG_CABA_TRTAG, "");
    FIg_set_text (FormPtr, VCSET_GDG_CABB_TRTAG, "");

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

    FIg_erase (me->pSysAtt, VCSET_GDG_CAB_SWAP);

    FIg_set_value (me->pSysAtt, VCSET_GDG_CAB_TAILLGT, me->dTail);
    FIg_set_value (me->pSysAtt, VCSET_GDG_CAB_ESTLGT, me->dEstim);

    goto quit;
  }

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_STANDARD_AN, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_text (me->pSysAtt, VCSET_GDG_TERM_STAND, rts.var.text_st.text_string);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_CATALOG_NUM_AN, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_text (me->pSysAtt, VCSET_GDG_TERM_CATAL, rts.var.text_st.text_string);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_STOCK_NUM_AN, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_text (me->pSysAtt, VCSET_GDG_TERM_STOCK, rts.var.text_st.text_string);

  status =
  om$send ( msg = message VCDB.VCGpAnum
                    (&retmsg, nIndex, nMap, VC_X_WEIGHT_DB, &rts),
       targetid = me->CompId.objid,
       targetos = me->CompId.osnum);

  FIg_set_value (me->pSysAtt, VCSET_GDG_TERM_WGT, rts.var.root_pm_st.value);

  if (me->nObjType & VC_GEN_TERM)
  {
    IGRchar         szFld[80];
    IGRshort        nSH=0;

    VC_INITSTR (szFld);

    status =
    om$send (msg = message VCCmdSA.VCSAdsp_eq
                                  (&retmsg, &me->CompId, me->pSysAtt,
                                   VCSET_GDG_TERM_EQTYP,
                                   VCSET_GDG_TERM_EQTAG,
                                   VCSET_GDG_TERM_CMPAR),
      targetid = my_id);

    /* First get the number of Connection Components connected to terminal */
    status =
    om$send (msg = message VCTerm.VCTshells (&retmsg, &nSH, NULL),
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);

    /* added by alwin, for CR179702192 */
    if( nSH )
    {
      struct GRid *Shells=NULL;

      Shells = _MALLOC( nSH, struct GRid );
 
      __CheckPtr( Shells, "Allocation for Conn. Components failed", quit );
 
      /* After the memory Allocation, now get all the Shell Object Ids */
      status = 
      om$send ( msg = message VCTerm.VCTshells( &retmsg, &nSH, Shells ),
                            targetid = me->CompId.objid,
                            targetos = me->CompId.osnum);

      __DBGpr_int( " Nb of Conn. Components ", nSH );
      if ( nSH == 1 )
      {
         FIg_erase( me->pSysAtt, VCSET_GDG_TERM_BKSH_LIST ); 
         FIg_display( me->pSysAtt, VCSET_GDG_TERM_BKSH );
      }
      else if( nSH > 1 )
      {
         IGRint row=0;

         FIg_erase( me->pSysAtt, VCSET_GDG_TERM_BKSH); 
         FIg_display( me->pSysAtt, VCSET_GDG_TERM_BKSH_LIST );

         FIfld_set_list_num_rows( me->pSysAtt, VCSET_GDG_TERM_BKSH_LIST,
                                    0, nSH );
         for( row=0; row<nSH; row++ )
         {
             status = om$send(msg = message VCRoot.VCGetCode (szFld),
                      targetid = Shells[row].objid,
                      targetos = Shells[row].osnum);
  
             __DBGpr_str( " Conn. Component Code ", szFld );
             FIfld_set_list_text( me->pSysAtt, VCSET_GDG_TERM_BKSH_LIST, 
                              row, 0, (unsigned char *)szFld, FALSE );
         }
      }

      status = om$send(msg = message VCRoot.VCGetCode (szFld),
                    targetid = Shells[0].objid,
                    targetos = Shells[0].osnum);
 
      if( nSH == 1 )
         FIg_set_text ( me->pSysAtt, VCSET_GDG_TERM_BKSH      , szFld);
      else if( nSH > 1 )
         FIg_set_text ( me->pSysAtt, VCSET_GDG_TERM_BKSH_LIST , szFld);

      _FREE( Shells );
    }
    else
    {
	FIg_erase( me->pSysAtt, VCSET_GDG_TERM_BKSH_LIST );
	FIg_display( me->pSysAtt, VCSET_GDG_TERM_BKSH );
    }
    /* added by alwin, for CR179702192 */
  }
  else
  if (me->nObjType & VC_GEN_GUIDE)
  {
	/* This is to make sure the Conn. Component list gadgets are not 
	displayed. This may happen when the user tries to select more than one
	object at a time and view/modify it's attributes. Alwin */

	FIg_erase( me->pSysAtt, VCSET_GDG_TERM_BKSH_LIST );
	FIg_erase( me->pSysAtt, VCSET_GDG_CABA_BKSH_LIST );
	FIg_erase( me->pSysAtt, VCSET_GDG_CABB_BKSH_LIST );
  }
  else
  if (me->nObjType & VC_GEN_BKSHLL)
  {
	struct GRid	ParentId;
	IGRchar 	szFld[80];

	/* Same as above */
	FIg_erase( me->pSysAtt, VCSET_GDG_TERM_BKSH_LIST );
	FIg_erase( me->pSysAtt, VCSET_GDG_CABA_BKSH_LIST );
	FIg_erase( me->pSysAtt, VCSET_GDG_CABB_BKSH_LIST );

/* Setting the terminal's and equipment's tag and type gadgets - Anand */

        status = om$send(msg = message VCRoot.VCParent( &retmsg, 0, &ParentId,
                                                        &me->ModuleInfo),
                      targetid = me->CompId.objid,
                      targetos = me->CompId.osnum );
        __DBGpr_obj(" Parent id",ParentId);
  
        status = om$send(msg = message VCRoot.VCGetCode (szFld),
                      targetid = ParentId.objid,
                      targetos = ParentId.osnum);
        __DBGpr_str(" Terminal type",szFld);
        FIg_set_text( me->pSysAtt, VCSET_GDG_CABA_TRTYP, szFld );
  
	FIg_display( me->pSysAtt, VCSET_GDG_CABA_TRTAG );
/* You need to set display (again) because of some refreshing problems */

        status = om$send(msg = message VCRoot.VCGetTagNo (szFld),
                      targetid = ParentId.objid,
                      targetos = ParentId.osnum);
        __DBGpr_str(" Terminal tag",szFld);
        FIg_set_text( me->pSysAtt, VCSET_GDG_CABA_TRTAG, szFld );
   
/* Note: The last input for method VCSAdsp_eq is the gadget label of field for
	 Compartment. The input is now sent as zero, because this field is not
	 displayed. Set it to VCSET_GDG_CABA_CMPAR when required - Anand */

        /* Turned on the fields for TR179901681. May have to be conditional */
        FIg_display ( me->pSysAtt, VCSET_GDG_CABA_EQTYP);
        FIg_display ( me->pSysAtt, VCSET_GDG_CABA_EQTAG);
        status =
        om$send (msg = message VCCmdSA.VCSAdsp_eq
                                      (&retmsg, &ParentId, me->pSysAtt,
                                       VCSET_GDG_CABA_EQTYP,
                                       VCSET_GDG_CABA_EQTAG,
                                       0),
                  targetid = my_id);
  }

  quit:
  status = 
  om$send (msg = message VCAT.VCAT_sdsp (&retmsg, FormPtr),
      targetid = my_id);

#ifdef MY_DEBUG
  printf ("sysform done\n");
#endif

  End
  return  OM_S_SUCCESS;
}

/*C  */
method  VCSAChgLnAttr (IGRlong   *msg;    /* I/O - return status  */
               struct  GRid      *CompId;    /* I -  Link Id    */
               struct  GRid      *SysId;    /* I - System  Id  */
               struct  GRid      *UsrId)    /* I - User Id    */

{
  IGRint      status;
  IGRlong      retmsg;

  /*A initialization */
  *msg = MSSUCC;
  
  /*A validity check */
  if ( !CompId )  return  OM_E_INVARG;
  
  /*A change the system, user and missing parameters of
      the link */

  if (SysId)
  {
    status =
    om$send( msg = message VCRoot.VCChgParam
                            (&retmsg, (IGRshort) VC_SYSTEM, SysId),
    targetid = CompId->objid,
    targetos = CompId->osnum );
    as$status( action = RET_STATUS );
  }

  if (UsrId)
  {
    status =
    om$send( msg = message VCRoot.VCChgParam
                             (&retmsg, (IGRshort) VC_USER, UsrId),
    targetid = CompId->objid,
    targetos = CompId->osnum );
    as$status( action = RET_STATUS );
  }

  return  OM_S_SUCCESS;
}

/*C  loads the identified cable's info in to sys form  */
/*TBD  Add return status as an argument to this method    */

method  VCSALoadLnAttr (char  *SysFormPtr;  /* I : System form to fill up */
                 struct GRid  *CompId)      /* I : link to copy from */
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     noret;

  struct VCEXpan   ExRec;

  /*A return error if no object is found */
  if ( !CompId || CompId->objid == NULL_OBJID )
    return  OM_E_INVARG;

#ifdef MY_DEBUG
  printf (" Loadlnatt for <%d %d>\n", CompId->objid, CompId->osnum);
#endif
  /* Code below added for CR179702190 */
  /**************************************************************************
  * This method is called in two situations - when the SetAtt form comes up *
  * and when the copy attributes gadget is selected on the same form.	    *
  * CR179702190 requires the additional attribute be not copied when copy   *
  * attributes is selected.						    *
  *									    *
  * The instance variable - RefCId ( Because it was not being used anywhere *
  * else ) has been used as a handle to demarkate the two cases		    *
  * in the method VCAT_getcoll viz., where the instance data is actually    *
  * populated from either the active parameters or from the cable element   *
  * picked.								    *
  *									    *
  * When the form comes up, set RefCId to me->CompId so that the instance   *
  * data populated is that of the cable element picked. In the other case,  *
  * set RefCId to NULL so that the method VCAT_getcoll retains the	    *
  * additional attribute using this condition.				    *
  *									    *
  *					 -- Satish for CR179702190	    *
  ***************************************************************************/
  if( me->CompId.objid == CompId->objid &&
      me->CompId.osnum == CompId->osnum )
  {
      me->RefCId.objid = CompId->objid;
      me->RefCId.osnum = CompId->osnum;
  }
  else
  {
      me->RefCId.objid = NULL_OBJID;
      me->RefCId.osnum = OM_Gw_current_OS;
  }
  /* Above code added for CR179702190 */

  /*A get the system, user and missing parameters from comp */
  status =
  om$send( msg = message VCAT.VCAT_load (&retmsg, CompId),
    targetid = my_id );

  me->dTail  = 0.0;
  me->dEstim = 0.0;

  status =
  om$send (msg = message VCRoot.VCGetExpand
                              (&retmsg, (IGRshort) VC_EXIN_TAIL, 
                                &noret, &ExRec),
      targetid = CompId->objid,
      targetos = CompId->osnum);
  if (retmsg & MSSUCC) me->dTail  = ExRec.AT.EXd;

  status =
  om$send (msg = message VCRoot.VCGetExpand
                              (&retmsg, (IGRshort) VC_EXIN_ESTIM, 
                                &noret, &ExRec),
      targetid = CompId->objid,
      targetos = CompId->osnum);
  if (retmsg & MSSUCC) me->dEstim  = ExRec.AT.EXd;

  /*A update the sys form */  
  status =
  om$send( msg = message VCCmdSA.VCSASysForm (&retmsg),
      targetid = my_id );

#ifdef MY_DEBUG
  printf ("Leave LoadLnAttr\n");
#endif

  return  OM_S_SUCCESS;
}

method VCSAlist (IGRlong      *msg)
{
  IGRlong     retmsg;
  IGRint      status;
  IGRshort    nC1, nC2;
  IGRchar    *p1;
  IGRchar    *p2;

  *msg = MSSUCC;

  _FREE (me->CClist);
  _FREE (me->CCdesc);
  nC1 = nC2 = 0;

  if (me->CmdProd == VC_PROD_NONE)
  {
    me->Product  = VC_PROD_NONE;
    me->nFOstart = -1;
  }

  if (me->nObjType & VC_GEN_TERM)
  {
    if (me->Product != VC_PROD_FO)
    {
      vc$elterm_idx (p_count = &nC1,
                     osnum   = me->My_OS);

      me->nFOstart = nC1;
    }

    if (me->Product != VC_PROD_ELEC)
      vc$foterm_idx (p_count = &nC2,
                     osnum   = me->My_OS);
  }
  else
  if (me->nObjType & VC_GEN_CABLE)
  {
    if (me->Product != VC_PROD_FO)
    {
      vc$elcab_idx (p_count = &nC1,
                    osnum   = me->My_OS);

      me->nFOstart = nC1;
    }

    if (me->Product != VC_PROD_ELEC)
      vc$focab_idx (p_count = &nC2,
                    osnum   = me->My_OS);
  }
  else
  if (me->nObjType & VC_GEN_GUIDE)
  {
    vc$guide_idx (p_count = &nC1,
                  osnum   = me->My_OS);
  }
  else
  if (me->nObjType & VC_GEN_BKSHLL)
  {
    vc$bksh_idx (p_count = &nC1,
                 osnum   = me->My_OS);
  }

  me->nCC = nC1 + nC2;

  if (me->CmdProd == VC_PROD_NONE)
    me->nFOstart = nC1;
  else
    me->nFOstart = -1;

  if (me->nCC > 0)
  {
    me->CClist = _MALLOC (me->nCC * VC_MAX_CCODE, IGRchar);
    me->CCdesc = _MALLOC (me->nCC * VC_MAX_SDESC, IGRchar);
    if (me->CClist == NULL) return (OM_E_NODYNMEM);

    p1 = me->CClist;
    p2 = me->CCdesc;

    if (me->nObjType & VC_GEN_TERM)
    {
      if (me->Product != VC_PROD_FO)
      {
        vc$elterm_idx (p_count = &nC1,
                       p_desc  = p2,
                       p_codes = p1,
                       osnum   = me->My_OS);
        p1 += (nC1 * VC_MAX_CCODE);
        p2 += (nC1 * VC_MAX_SDESC);
      }

      if (me->Product != VC_PROD_ELEC)
      {
        vc$foterm_idx (p_count = &nC2,
                       p_desc  = p2,
                       p_codes = p1,
                       osnum   = me->My_OS);
      }
    }
    else
    if (me->nObjType & VC_GEN_CABLE)
    {
      if (me->Product != VC_PROD_FO)
      {
        vc$elcab_idx (p_count = &nC1,
                      p_desc  = p2,
                      p_codes = p1,
                      osnum   = me->My_OS);

        p1 += (nC1 * VC_MAX_CCODE);
        p2 += (nC1 * VC_MAX_SDESC);
      }

      if (me->Product != VC_PROD_ELEC)
      {
        vc$focab_idx (p_count = &nC2,
                      p_desc  = p2,
                      p_codes = p1,
                      osnum   = me->My_OS);
      }
    }
    else
    if (me->nObjType & VC_GEN_GUIDE)
    {
      vc$guide_idx (p_count = &me->nCC,
                    p_desc  = me->CCdesc,
                    p_codes = me->CClist,
                    osnum   = me->My_OS);
    }
    else
    if (me->nObjType & VC_GEN_BKSHLL)
    {
      vc$bksh_idx (p_count = &me->nCC,
                   p_desc  = me->CCdesc,
                   p_codes = me->CClist,
                   osnum   = me->My_OS);
    }
  }

#ifdef MY_DEBUG
  printf (" set compcode list %d entries, split\n",me->nCC,me->nFOstart);
#endif

  return (OM_S_SUCCESS);
}

method VCSAcheck (IGRlong      *msg)
{
  IGRint      status;
  IGRint      i;
  IGRshort    nST;

  *msg = VC_RTC_ALLOK;
  me->ret = VC_RTC_ALLOK;

  if (me->nCC <= 0)
  {
    status =
    om$send( msg = message VCCmdSA.VCSAlist (msg),
        targetid = my_id );
  }

  for (i=0; i<me->nCC; i++)
  {
#ifdef MY_DEBUG
    printf ("compcode check %s %s\n",me->CompCode, (&me->CClist[i*VC_MAX_CCODE]));
#endif
    if (strcmp (&me->CClist[i*VC_MAX_CCODE], me->CompCode) == 0) goto CCOK;
  }

  UI_status ("Invalid comp_code");
  *msg = VC_RTC_ERROR;
  me->ret = VC_RTC_ERROR;
  return (OM_S_SUCCESS);

  CCOK:

  if (me->bTagByp) return (OM_S_SUCCESS);

  if (VC_EMPTYSTR(me->CompTag))
  {
    UI_status ("Missing Tag Number");
    *msg = VC_RTC_ERROR;
    me->ret = VC_RTC_ERROR;
    return (OM_S_SUCCESS);
  }

  VC_TAGchk (&nST, me->nTagCat, me->CompTag);

  if (nST >= 0)
  {
    UI_status ("Duplicate Tag Number");
    *msg = VC_RTC_ERROR;
    me->ret = VC_RTC_ERROR;
  }

  return (OM_S_SUCCESS);
}

method  VCAT_sdsp (IGRlong     *sts;
                   IGRchar     *fptr)
{
  IGRshort        iloop;
  IGRshort        iAttr;
  IGRint          inum;

  *sts = MSSUCC;
  inum = om$dimension_of (varray = me->Syscoll);

  for (iloop = 0; iloop < inum; iloop++)
  {
    iAttr = VCDB_AttrNamToNum (me->Syscoll[iloop].name);

#ifdef MY_DEBUG
    printf (" sysatt %d %d, %s %s\n", iloop, iAttr,
                          me->Syscoll[iloop].name,
                          me->Syscoll[iloop].desc.value.att_txt);
#endif

    switch (iAttr)
    {
      case VC_X_ADD_LABEL_AN:
        FIg_set_text (fptr, VCSET_GDG_ADDLAB,
               me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_UNIT_AN:
        FIg_set_text (fptr, VCSET_GDG_UNIT,
               me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_SYST_NAME_AN:
        FIg_set_text (fptr, VCSET_GDG_SYSNM,
               me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_APPRV_STAT_AN:
        FIg_set_text (fptr, VCSET_GDG_APPRV,
               me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_CONSTR_STAT_AN:
        FIg_set_text (fptr, VCSET_GDG_CONSTR,
               me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_CHG_REQ_NUM_AN:
        FIg_set_text (fptr, VCSET_GDG_CHGNUM,
               me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_COMP_NOTE_AN:
        FIg_set_text (fptr, VCSET_GDG_NOTES,
               me->Syscoll[iloop].desc.value.att_txt);
        break;

    }
  }

  return (OM_S_SUCCESS);
}

end implementation VCCmdSA;

