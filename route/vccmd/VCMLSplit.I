/* $Id: VCMLSplit.I,v 1.3 2002/05/24 21:41:49 anand Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE					vim600:fdm=marker:fmr=@<@,@>@
 *
 * File:	vccmd/VCSplitCab.I
 *
 * Description:
 *
 *  Place Cable Command methods to handle splitting process.
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCMLSplit.I,v $
 *     Revision 1.3  2002/05/24 21:41:49  anand
 *     Second set of bug fixes for the cable lead enhancement.
 *     Fixes errors in model arising out of merge-cable workflows.
 *     Ensure placeholders are created for markers for DB driven
 *     cables. Major shuffling of code in Sketch cable state table.
 *
 *     Revision 1.2  2002/05/10 22:13:24  anand
 *     First set of bug fixes for sub-cable functionality. Attempts
 *     to fix merge issues, and some cpt issues. Fix for TR 6344.
 *
 *     Revision 1.1  2002/05/08 15:48:23  anand
 *     Files added/modified for sub-cable functionality.
 *
 *
 *
 * History:
 *
 *	DATE		DEVELOPER	REASON
 *
 *	May 2002	Anand		Creation
 *
 * ---------------------------------------------------------------------*/

class implementation VCCmdPC;

#include "vc_define.h"
#include "VCCmdDef.h"
#include "vrdbgmacros.h"

from	VCCable	import	VCAmISubCab;
from	VCRoot	import	VCSelectCpt, VCGetCptCoord;
from	VCCable	import	VCGetInfoSubCab; // Needed for VC$SubCabLeadInfo

#if 0
IGRint VCGetLeadNamesFromCompCode( IGRchar  CompCode[VC_MAX_CCODE], // @<@
				   IGRshort ElType,
				   IGRint   *NumLeads,
				   IGRchar  (*LdNam)[VC_MAX_LEAD_ID] )
{
    IGRint	status, i;
    IGRlong	retmsg;
    struct GRid	ModelId;
    struct VClayout	*Layout=NULL;

    SetProc( VCGetLeadNamesFromCompCode ); Begin;

    __DBGpr_str(" input comp code",CompCode);
    __DBGpr_int(" Input type",ElType);

    if( NumLeads == NULL )
    {
	status = OM_E_INVARG;
	goto wrapup;
    }

    vc$db_old( element	= VC_CABLE_TYPE,
	       product	= ElType,
	       code	= CompCode,
	       GRid	= ModelId );

    __DBGpr_obj(" Model id from compcode",ModelId);

    status = om$send( msg = message VCDB.VCGetLayout( &retmsg, NULL,
						      NumLeads, NumLeads,
						      NULL ),
		      targetid = ModelId.objid,
		      targetos = ModelId.osnum );
    __CheckRC( status, retmsg, "VCGetLayout failed!", wrapup );

    __DBGpr_int(" Number of leads", *NumLeads);

    if( LdNam == NULL )
	goto wrapup;

    Layout = _MALLOC( *NumLeads, struct VClayout );
    __CheckPtr( Layout, "Alloc of Layout failed", wrapup );

    status = om$send( msg = message VCDB.VCGetLayout( &retmsg, NULL,
						      NumLeads, NumLeads,
						      Layout ),
		      targetid = ModelId.objid,
		      targetos = ModelId.osnum );
    __CheckRC( status, retmsg, "VCGetLayout failed!", wrapup );

    __DBGpr_int(" Number of leads", *NumLeads);

    for( i=0 ; i<*NumLeads ; i++ )
    {
	strcpy( LeadNam[i], Layout[i].pDef.Conn.Cable.szLeadId );
	__DBGpr_str(" Lead name", LeadNam[i] );
    }

    _FREE( Layout );

wrapup:
    End;
    return status;
} // @>@
#endif

method VCMLSetRetCode( IGRlong *sts )
{
    *sts = me->ret = me->MyRetCode;

    return OM_S_SUCCESS;
}

method VCSplitPreFormProc( IGRlong *sts )
{
    IGRshort	SplitEnd=-1;
    IGRint	status, NbLeads, NumRows, i;
    IGRlong	retmsg;
    struct GRid	ParCabId;

    SetProc( VCSplitPreFormProc ); Begin;

    /* Changed below condition from >2 to >=2. TR 6344. Anand */
    if( me->nMyPnts>=2 ) // Sketching something that we need to split? @<@1
    {
	IGRdouble	t1[3];
	IGRboolean	b1;

	// If so, go ahead and place it. Need to have an object @<@2

	me->bToBeSplit = TRUE; // To ensure that VCinit is not called at end.
	status = om$send( msg = message VCCmdPC.VCInsertLink( sts ),
			  targetid = my_id );
	me->bToBeSplit = FALSE;
	__DBGpr_obj("Id of newly constructed parent",me->CompId);
	__DBGpr_vec("Coord of last point pushed",me->myPnts[me->nMyPnts-1].xyz);

	// Find which end of just placed cable is going to be split. @<@2
	status = om$send( msg = message VCRoot.VCSelectCpt( &retmsg,
						 me->myPnts[me->nMyPnts-1].xyz,
							    &SplitEnd,
							    t1, NULL, &b1,
							    &me->ModuleInfo ),
			  targetid = me->CompId.objid,
			  targetos = me->CompId.osnum );
	__DBGpr_int("Which end?",SplitEnd);

	// Hold on to any other command instance variables necessary. @<@2
	ParCabId = me->CompId;

	// Initialize command instance @<@2
	status = om$send( msg = message VCCmdPC.VCinit( sts ),
			  targetid = my_id );

	// Restore the saved command instance variables. @<@2
	me->CompId = ParCabId;
	me->ParSpltEnd = SplitEnd;
    }
    else
    if( me->ConnId.objid != NULL_OBJID ) // Splitting a placed cable? @<@1
    {
	// Hold on to any other command instance variables necessary. @<@2
	ParCabId = me->ConnId;
	SplitEnd = me->ParSpltEnd;
	__DBGpr_obj("Coming of a sketched cable",me->ConnId);

	// Initialize command instance @<@2
	status = om$send( msg = message VCCmdPC.VCinit( sts ),
			  targetid = my_id );

	// Restore the saved command instance variables. @<@2
	me->CompId = ParCabId;
	me->ParSpltEnd = SplitEnd;
    }
    else // Attempt to split a cable hitherto unplaced @<@1
    {
	UI_status("Sketch some cable before splitting first!");
	*sts = VC_RTC_ERROR;
	End;
	return VC_ERROR;
    }

    /* @<@1 At this point, we should have a (non-transient) cable object in the
     * design file that is going to be split. */

    __DBGpr_obj("Parent cable to be split",me->CompId);
    __DBGpr_int("End of cable being split",me->ParSpltEnd);

    if( me->CompId.objid == NULL_OBJID )
    {
	*sts = VC_RTC_ERROR;
	End;
	return VC_ERROR;
    }

    if( me->CompId.osnum != me->ModuleInfo.md_id.osnum )
    {
	UI_status("Cannot split cable in reference file.");
	*sts = VC_RTC_ERROR;
	End;
	return VC_ERROR;
    }

    // Set me->Leads based on parent cable @<@1
    if( me->ParSpltEnd == 0 )
	status = VC$SubCabLeadInfo( p_msg		= &retmsg,
				    gridInputCab	= me->CompId,
				    p_nBegAvlblLeads	= &NbLeads
				  );
    else
	status = VC$SubCabLeadInfo( p_msg		= &retmsg,
				    gridInputCab	= me->CompId,
				    p_nEndAvlblLeads	= &NbLeads
				  );

    __DBGpr_int(" Number of available leads in located cable", NbLeads);
    if( NbLeads==0 )
    {
	UI_status("All leads in cable taken by other sub-cables!");
	*sts = VC_RTC_ERROR;
	End;
	return VC_ERROR;
    }

    om$vla_set_dimension( varray = me->Leads, size = NbLeads );

    if( me->ParSpltEnd == 0 )
	status = VC$SubCabLeadInfo( p_msg		= &retmsg,
				    gridInputCab	= me->CompId,
				    p_nBegAvlblLeads	= &NbLeads,
				    p_BegAvlblLds	= me->Leads
				  );
    else
	status = VC$SubCabLeadInfo( p_msg		= &retmsg,
				    gridInputCab	= me->CompId,
				    p_nEndAvlblLeads	= &NbLeads,
				    p_EndAvlblLds	= me->Leads
				  );

    // Display leads on form. @<@1
    VC_Cmd_form_open( me->PkLdForm, VC_FPOS_PC_LEAD );

    NumRows = om$dimension_of(varray=me->Leads);
    FIfld_set_num_rows( me->PkLdForm, VCSUBCAB_AVLBL_LEAD, NumRows );
    FIfld_set_num_rows( me->PkLdForm, VCSUBCAB_UNUSD_LEAD, 0 );

    for( i=0 ; i<NumRows ; i++ )
	FIfld_set_text( me->PkLdForm, VCSUBCAB_AVLBL_LEAD, i, 0,
			me->Leads[i].LeadNam, 0 );

    VC_Cmd_form_close( me->pCtlAtt, me->FCcontrol );

    FIg_disable( me->PkLdForm, FI_ACCEPT );

quit:
    *sts=VC_RTC_ALLOK;
    End;
    return OM_S_SUCCESS;
} // @>@

method VCRedirectMerge( IGRlong *sts )
{
  IGRint status;
  SetProc(VCRedirectMerge); Begin;

  *sts = me->ret = VC_RTC_ALLOK;

  me->event1.located_object[0].located_obj = me->CompId;
  me->event1.located_object[0].module_info = me->ModuleInfo;

  me->ConnId = me->CompId;
  me->CompId.objid = NULL_OBJID;
                                                          
  me->event1.event.button.x = me->dIncrd[0];
  me->event1.event.button.y = me->dIncrd[1];
  me->event1.event.button.z = me->dIncrd[2];

  me->bGoing = FALSE;

  status = om$send( msg = message VCCmdPC.VCGetLink( sts ),
		    targetid = my_id );
  
  End;
  return OM_S_SUCCESS;
}

method VCStartSplit( IGRlong *sts )
{
    IGRint	status, nType;
    IGRdouble	dCoord[3];

    SetProc(VCStartSplit); Begin;

    __DBGpr_int("me return code",me->ret);

    FIg_disable( me->pCtlAtt, VCPCAB_COMPCODE );
    FIg_disable( me->pCtlAtt, VCPCAB_TAGNO );
    FIg_set_value( me->pCtlAtt, VCPCAB_SPLIT, 1 );

    nType = me->ParSpltEnd ? VCC_SPLIT_END : VCC_SPLIT_BEGIN;
    __DBGpr_int("Parent type on subcable",nType);

    status = om$send( msg = message VCRoot.VCGetCptCoord( sts, me->ParSpltEnd,
							  dCoord,
							  &me->ModuleInfo ),
		      targetid = me->CompId.objid,
		      targetos = me->CompId.osnum );
    __DBGpr_vec("coordinate of 1st pt of subcable",dCoord);

    status = om$send( msg = message VCCmdPC.VCMLAddNode( nType,
							 dCoord, dCoord,
							 0, 0, &me->CompId ),
		      targetid = my_id );

    status = om$send( msg = message VCCmdPC.VCMLAddStrP( dCoord ),
		      targetid = my_id );

    me->CompId.objid = NULL_OBJID;
    me->bSkSplCab = TRUE;

    *sts = VC_RTC_ALLOK;
    End;
    return OM_S_SUCCESS;
}

end implementation VCCmdPC;

