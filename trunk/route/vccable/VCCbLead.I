/* $Id: VCCbLead.I,v 1.5 2002/05/30 14:56:04 anand Exp $  */

/*************************************************************************
 * I/Route
 *
 * File:	vccable/VCCbLead.I
 *
 * Description:
 *   This file contains methods relating to sub cables.
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCbLead.I,v $
 *        Revision 1.5  2002/05/30 14:56:04  anand
 *        Freed allocated pointer.
 *
 *        Revision 1.4  2002/05/29 20:25:43  anand
 *        Third set of bug fixes for the split cable functionality.
 *        Merge does not corrupt the model. The marker information is
 *        now propagated to newly sketched cables/sub-cables. Changed
 *        interface of VCGetAttrInfoForLead to mirror VCSetLeadAttrInfo.
 *
 *        Revision 1.3  2002/05/17 19:23:35  anand
 *        Misc. bug fixes. Covers change rejects CR 5846 and 6040.
 *        Ensures that new sub-cables carry over signals of parent
 *        cables.
 *
 *        Revision 1.2  2002/05/10 22:13:23  anand
 *        First set of bug fixes for sub-cable functionality. Attempts
 *        to fix merge issues, and some cpt issues. Fix for TR 6344.
 *
 *        Revision 1.1  2002/05/08 15:48:22  anand
 *        Files added/modified for sub-cable functionality.
 *
 *
 *
 * History
 *
 *	DATE		DEVELOPER	REASON
 *
 *	Feb/Mar 2002	Anand		Creation
 *
 **************************************************************************/


class implementation VCCable;

#include "VCdefine.h"
#include "VDmem.h"
#include "VDchn.h"
#include "vrdbgmacros.h"
#include "VCLead.h"

method VCAmIParCab( IGRlong	*msg;
		    IGRint	*nNumSubCab;
		    struct GRid	*SubCabIds )
{
    IGRint	status;
    struct GRid	MyId;

    SetProc(VCAmIParCab); Begin
    
    if( nNumSubCab == NULL )
    {
	*msg = MSFAIL;
	End;
	return OM_E_INVARG;
    }
    *nNumSubCab = 0;

    MyId.objid = my_id;
    MyId.osnum = OM_Gw_current_OS;
    __DBGpr_obj("Checking sub cables for",MyId);

    /* Get all children who are Cables */
    status = vdchn$GetList( objID	= &MyId,
			    chnIDx	= VDCHN_IDX_CHILD,
			    maxCnt	= 100, // Hard-coded assumption.
			    cnt		= nNumSubCab,
			    FltrClsId	= OPP_VCCable_class_id );

    __DBGpr_int("Number of subcables",*nNumSubCab);
    if( *nNumSubCab == 0 )
    {
	*msg = MSSUCC;
	End;
	return OM_S_SUCCESS;
    }

    if( SubCabIds == NULL )
    {
	/* Caller does not wish to know GRid of sub cables */
	*msg = MSSUCC;
	End;
	return OM_S_SUCCESS;
    }

    status = vdchn$GetList( objID	= &MyId,
			    chnIDx	= VDCHN_IDX_CHILD,
			    maxCnt	= *nNumSubCab,
			    cnt		= nNumSubCab,
			    outIDs	= SubCabIds,
			    FltrClsId	= OPP_VCCable_class_id );
    __DBGpr_objlist("Sub Cable",*nNumSubCab,SubCabIds);

    End;
    return OM_S_SUCCESS;
}

method VCAmISubCab( IGRlong		 *msg;
		    IGRint		 *nWhichEnd;
		    struct GRid		 *ParId;
		    IGRint		 *NumLeads;
		    struct VCcab_connect *LeadInfo )
{
    *msg = MSSUCC;

    /* If requested return lead information, even when not a sub-cable */
    if( NumLeads )
    {
	*NumLeads = om$dimension_of(varray = me->Connect_Data);
	if( LeadInfo )
	{
	    IGRint	i;

	    for( i=0 ; i<*NumLeads ; i++ )
		LeadInfo[i] = me->Connect_Data[i];
	}
    }

    if( nWhichEnd == NULL )
    {
	*msg = MSFAIL;
	return OM_E_INVARG;
    }

    /* Question: Actually verify parent channel (rather than rely on
     * section map)? */
    if( me->Sect[0].type != VCC_SPLIT_BEGIN &&
	me->Sect[0].type != VCC_SPLIT_END )
    {
	*msg = MSFAIL;
	return OM_E_ABORT;
    }
    *nWhichEnd = me->Sect[0].type;
    if( ParId )
    {
	IGRint status;

	status = om$send( msg = message VCRoot.VCParent( msg, me->Sect[0].parno,
							 ParId, NULL ),
			  targetid = my_id );
	as$status();
    }

    return OM_S_SUCCESS;
}

method VCGetInfoSubCab( IGRlong			*msg;
			struct VCCL_sectmap	Sect[2];
			IGRdouble		Coord[6];
			IGRint			*NumBegCab;
			struct GRid		*BegCabId;
			IGRint			*NumBegCabLds;
			struct VCcab_connect	*BegCabLeads;
			IGRint			*NumEndCab;
			struct GRid		*EndCabId;
			IGRint			*NumEndCabLds;
			struct VCcab_connect	*EndCabLeads;
			IGRint			*NumBegAvlblLds;
			struct VCcab_connect	*BegAvlblLds;
			IGRint			*NumEndAvlblLds;
			struct VCcab_connect	*EndAvlblLds;
			struct GRmd_env		*md_env )
{

      /*****************************************************************\
      *									*
      * WARNING: DO NOT CALL THIS METHOD DIRECTLY. RATHER CALL IT FROM  *
      *		 THE WRAPPER OM MACRO viz., VC$SubCabLeadInfo. SEE      *
      *		 COMMENT IN SPEC FILE.                                  *
      *									*
      * Caller to (optionally) alloc for -				*
      *	1. BegCabId							*
      *	2. NumBegCabLds							*
      * (based on earlier call that returns NumBegCab),			*
      *									*
      * AND/OR								*
      *	3. EndCabId							*
      *	4. NumEndCabLds							*
      * (based on earlier call that returns NumEndCab),			*
      *									*
      * The VCcab_connect structures viz., BegCabLeads, EndCabLeads,	*
      * BegAvlblLds and EndAvlblLds may be conservatively allocated for	*
      * the number of leads in main cable (each).			*
      *									*
      * Notes:								*
      *									*
      * 1. NumBegCabLds and NumEndCabLds are arrays. The number of	*
      *    elements in these arrays are the number of Cables (beginning	*
      *    and end respectively). The i-th element in each array would	*
      *    store the number of leads in the i-th cable.			*
      *									*
      * 2. Although possible, there would be little meaning in getting	*
      *    BegCabLds and EndCabLds without ALSO getting NumBegCabLds	*
      *    and NumEndCabLds.						*
      *									*
      \*****************************************************************/

    IGRint		status, i, j, k, bndx, endx;
    IGRint		NbSubCab = 0, NbMainLds = 0;
    struct GRid		*SubCabIds = NULL;
    IGRint		*nWhichEnd = NULL;
    IGRint		*NbLeads = NULL;
    IGRboolean		*BegLdTaken = NULL, *EndLdTaken = NULL;
    struct VCcab_connect *LdDetails = NULL;

    SetProc( VCGetInfoSubCab ); Begin;

    /* If Sect and/or Coord are not null, provide requested info (irresp. of
     * my_id having sub-cables or not) */

    if( Sect )
    {
	Sect[0] = me->Sect[0];
	Sect[1] = me->Sect[ om$dimension_of(varray=me->Sect) - 1 ];
    }

    if( Coord )
    {
	/* Other arg check done by macro wrapper */
	if( md_env == NULL )
	{
	    __DBGpr_com("Called with NULL Module Env");
	    status = OM_E_INVARG;
	    *msg = MSFAIL;
	    goto wrapup;
	}

	status = om$send( msg	   = message VCRoot.VCGetCptCoord( msg, 0,
								   &Coord[0],
								   md_env ),
			  targetid = my_id );
	as$status();

	status = om$send( msg	   = message VCRoot.VCGetCptCoord( msg, 1,
								   &Coord[3],
								   md_env ),
			  targetid = my_id );
	as$status();
    }

    status = om$send( msg	= message VCCable.VCAmIParCab( msg, &NbSubCab,
							       NULL ),
		      targetid	= my_id );
    __CheckRC( status, *msg, "Getting NbSubCab failed", wrapup );

    if( NbSubCab == 0 )
    {
	/* No sub cables. If caller wanted info, set output vars and quit. */
	if( NumBegCab )
	    *NumBegCab = 0;
	if( NumEndCab )
	    *NumEndCab = 0;

	NbMainLds = om$dimension_of(varray = me->Connect_Data);
	if( NumBegAvlblLds )
	    *NumBegAvlblLds = NbMainLds;
	if( NumEndAvlblLds )
	    *NumEndAvlblLds = NbMainLds;
	if( BegAvlblLds )
	{
	    for( k=0 ; k<NbMainLds ; k++ )
		BegAvlblLds[k] = me->Connect_Data[k];
	}
	if( EndAvlblLds )
	{
	    for( k=0 ; k<NbMainLds ; k++ )
		EndAvlblLds[k] = me->Connect_Data[k];
	}

	*msg = MSSUCC;
	status = OM_S_SUCCESS;
	goto wrapup;
    }

    SubCabIds = _CALLOC( NbSubCab, struct GRid );
    if( SubCabIds == NULL )
    {
	status = OM_E_NODYNMEM;
	*msg = MSFAIL;
    }
    __CheckPtr( SubCabIds, "Alloc for SubCabIds failed!", wrapup );

    status = om$send( msg	= message VCCable.VCAmIParCab( msg, &NbSubCab,
							       SubCabIds ),
		      targetid	= my_id );
    __CheckRC( status, *msg, "Getting SubCabIds failed", wrapup );
    __DBGpr_objlist("Sub Cable IDs",NbSubCab,SubCabIds);

    nWhichEnd	= _CALLOC( NbSubCab, IGRint );
    NbLeads	= _CALLOC( NbSubCab, IGRint );
    if( nWhichEnd == NULL || NbLeads == NULL )
    {
	status = OM_E_NODYNMEM;
	*msg = MSFAIL;
    }
    __CheckPtr( nWhichEnd, "Alloc for nWhichEnd failed!", wrapup );
    __CheckPtr( NbLeads, "Alloc for NbLeads failed!", wrapup );

    if( NumBegCab )
	*NumBegCab = 0;
    if( NumEndCab )
	*NumEndCab = 0;

    for( i=0 ; i<NbSubCab ; i++ )
    {
	status = om$send( msg	   = message VCCable.VCAmISubCab( msg,
								  (nWhichEnd+i),
								  NULL,
								  (NbLeads+i),
								  NULL ),
			  targetid = SubCabIds[i].objid,
			  targetos = SubCabIds[i].osnum );
	__CheckRC( status, *msg, "VCAmISubCab failed", wrapup );
	__DBGpr_int(" Which end of par cab is sub cab?", nWhichEnd[i] );

	if( nWhichEnd[i] == VCC_SPLIT_BEGIN )
	{
	    if( NumBegCab )
	    {
		if( BegCabId )
		    BegCabId[*NumBegCab] = SubCabIds[i];
		if( NumBegCabLds )
		    NumBegCabLds[*NumBegCab] = NbLeads[i];
		++(*NumBegCab);
	    }
	}
	else if( nWhichEnd[i] == VCC_SPLIT_END )
	{
	    if( NumEndCab )
	    {
		if( EndCabId )
		    EndCabId[*NumEndCab] = SubCabIds[i];
		if( NumEndCabLds )
		    NumEndCabLds[*NumEndCab] = NbLeads[i];
		++(*NumEndCab);
	    }
	}
    }

    if( NumBegCab )
	__DBGpr_int("Num of Sub cables at Beginning",*NumBegCab);
    if( BegCabId )
	__DBGpr_objlist("Sub cables at Beginning",*NumBegCab,BegCabId);
    if( NumEndCab )
	__DBGpr_int("Num of Sub cables at End",*NumEndCab);
    if( EndCabId )
	__DBGpr_objlist("Sub cables at End",*NumEndCab,EndCabId);

    if( BegCabLeads == NULL && EndCabLeads == NULL &&
	NumBegAvlblLds == NULL && NumEndAvlblLds == NULL )
    {
	/* Caller not interested in lead information. */
	*msg     = MSSUCC;
	status = OM_S_SUCCESS;
	goto wrapup;
    }

    NbMainLds = om$dimension_of(varray = me->Connect_Data);
    if( NumBegAvlblLds )
	*NumBegAvlblLds = NbMainLds;
    if( NumEndAvlblLds )
	*NumEndAvlblLds = NbMainLds;
    if( BegAvlblLds )
    {
	BegLdTaken = _CALLOC( NbMainLds, IGRboolean );
	__CheckPtr( BegLdTaken, "Alloc for BegLdTaken failed", wrapup );
    }
    if( EndAvlblLds )
    {
	EndLdTaken = _CALLOC( NbMainLds, IGRboolean );
	__CheckPtr( EndLdTaken, "Alloc for EndLdTaken failed", wrapup );
    }

    bndx = 0;
    endx = 0;
    for( i=0 ; i<NbSubCab ; i++ )
    {
	LdDetails = _CALLOC( NbLeads[i], struct VCcab_connect );
	__CheckPtr(LdDetails,"LdDetails alloc inside for loop failed",wrapup);
	status = om$send( msg	   = message VCCable.VCAmISubCab( msg,
								  (nWhichEnd+i),
								  NULL,
								  (NbLeads+i),
								  LdDetails ),
			  targetid = SubCabIds[i].objid,
			  targetos = SubCabIds[i].osnum );
	__CheckRC( status, *msg, "VCAmISubCab failed", wrapup );

	for( j=0 ; j<NbLeads[i] ; j++ )
	{
	    if( nWhichEnd[i] == VCC_SPLIT_BEGIN )
	    {
		if( BegCabLeads )
		{
		    BegCabLeads[bndx++]=LdDetails[j];
		}
		if( NumBegAvlblLds )
		{
		    /* Compare leads in main cable versus leads
		     * in sub cable */
		    for( k=0 ; k<NbMainLds ; k++ )
			if( strcmp( me->Connect_Data[k].LeadNam,
				    LdDetails[j].LeadNam ) == 0 )
			{
#if defined(vdsDEBUG)
    printf( "Lead <%s> in Main cable %d (me) taken by beginning subcable %d\n",
	    me->Connect_Data[k].LeadNam,my_id,SubCabIds[i].objid );
#elif defined(DBG_PROD_NAME)
    if( DBG_Gb_dbg & DBG_PROD )
	fprintf( DBG_Gb_Fp,
	     "Lead <%s> in Main cable %d (me) taken by beginning subcable %d\n",
	     me->Connect_Data[k].LeadNam,my_id,SubCabIds[i].objid );
#endif
			    --(*NumBegAvlblLds);
			    if( BegAvlblLds && BegLdTaken )
				BegLdTaken[k] = TRUE;
			}
		}
	    }
	    else if( nWhichEnd[i] == VCC_SPLIT_END )
	    {
		if( EndCabLeads )
		{
		    EndCabLeads[endx++]=LdDetails[j];
		}
		if( NumEndAvlblLds )
		{
		    /* Compare leads in main cable versus
		     * leads in sub cable */
		    for( k=0 ; k<NbMainLds ; k++ )
			if( strcmp( me->Connect_Data[k].LeadNam,
				    LdDetails[j].LeadNam ) == 0 )
			{
#if defined(vdsDEBUG)
    printf( "Lead <%s> in Main cable %d (me) taken up by end subcable %d\n",
	    me->Connect_Data[k].LeadNam,my_id,SubCabIds[i].objid );
#elif defined(DBG_PROD_NAME)
    if( DBG_Gb_dbg & DBG_PROD )
	fprintf( DBG_Gb_Fp,
	     "Lead <%s> in Main cable %d (me) taken up by end subcable %d\n",
	     me->Connect_Data[k].LeadNam,my_id,SubCabIds[i].objid );
#endif
			    --(*NumEndAvlblLds);
			    if( EndAvlblLds && EndLdTaken )
				EndLdTaken[k] = TRUE;
			}
		}
	    }
	}
	_FREE( LdDetails );
    }
    if( NumBegAvlblLds )
	__DBGpr_int(" Num of beg available leads",*NumBegAvlblLds);
    if( NumEndAvlblLds )
	__DBGpr_int(" Num of end available leads",*NumEndAvlblLds);
    __DBGpr_int(" Num of beg leads taken (if proper arg passed)",bndx);
    __DBGpr_int(" Num of end leads taken (if proper arg passed)",endx);

    bndx = 0;
    endx = 0;
    for( k=0 ; k<NbMainLds ; k++ )
    {
	if( BegLdTaken && !BegLdTaken[k] && BegAvlblLds )
	{
	    BegAvlblLds[bndx] = me->Connect_Data[k];
	    bndx++;
	}

	if( EndLdTaken && !EndLdTaken[k] && EndAvlblLds )
	{
	    EndAvlblLds[endx] = me->Connect_Data[k];
	    endx++;
	}
    }
    __DBGpr_int("CHECK if == NumBegAvlblLds (if proper arg passed)",bndx);
    __DBGpr_int("CHECK if == NumEndAvlblLds (if proper arg passed)",endx);

wrapup:
    _FREE( SubCabIds );
    _FREE( nWhichEnd );
    _FREE( NbLeads );
    _FREE( LdDetails );
    _FREE( BegLdTaken );
    _FREE( EndLdTaken );
    End;
    return status;
}

method VCSubCabTogSectMap( IGRlong *msg )
{
    *msg = MSSUCC;

    if( me->Sect[0].type == VCC_SPLIT_BEGIN )
	me->Sect[0].type = VCC_SPLIT_END;
    else
    if( me->Sect[0].type == VCC_SPLIT_END )
	me->Sect[0].type = VCC_SPLIT_BEGIN;
    else
    {
	*msg = MSFAIL;
	return OM_E_ABORT;
    }

    return OM_S_SUCCESS;
}


struct LNN
{
    IGRshort			ConNum;
    struct VCcab_connect	LeadData;
};

static int LeadNamCompare( const void *l1, const void *l2 )
{
    struct LNN *Lead1 = (struct LNN *)l1;
    struct LNN *Lead2 = (struct LNN *)l2;

    if( Lead1->ConNum < Lead2->ConNum )
	return -1;
    if( Lead1->ConNum > Lead2->ConNum )
	return 1;

    return 0;
}


method VCCSetCon_Data( IGRlong	*msg;
		       IGRint	NbLeads;
		       struct VCcab_connect *Connect_Data;
		       IGRchar	(*LdNames)[VC_MAX_LEAD_ID] )
{
    IGRint	i, status, CabEnd;
    struct LNN	*LeadNamNum=NULL;
    struct GRid	MyId, ParId;
    extern int	VCGetSignalForLead( long *, struct GRid *, char [], char [] );

    SetProc( VCCable_VCCSetCon_Data ); Begin;

    MyId.objid = my_id;
    MyId.osnum = OM_Gw_current_OS;
    ParId.objid = NULL_OBJID;
    ParId.osnum = OM_Gw_current_OS;

		/* If I am NOT a sub cable, call VCCbInitCon */
    status = om$send( msg	= message VCCable.VCAmISubCab( msg, &CabEnd,
							       &ParId, NULL,
							       NULL ),
		      targetid	= my_id );

    if( (CabEnd!=VCC_SPLIT_BEGIN) && (CabEnd!=VCC_SPLIT_END) )
    {
	/* I am a "Normal" cable. */
	status = om$send( msg = message VCCable.VCCbInitCon( msg, TRUE ),
			  targetid = my_id );

	End;
	return status;
    }

		/* Sort the input leads based on the Con Num */
    LeadNamNum = _CALLOC( NbLeads, struct LNN );
    if( LeadNamNum==NULL )
    {
	End;
	return OM_E_NODYNMEM;
    }

    if( Connect_Data == NULL )	/* Only Lead Names provided */
	for( i=0 ; i<NbLeads ; i++ )
	{
	    VC_INITSTR( LeadNamNum[i].LeadData.FibEnds[0].szModId );
	    VC_INITSTR( LeadNamNum[i].LeadData.FibEnds[0].szPosId );

	    /* Since only lead names are provided,
	     * initialize terminal pin positions at end 1. */
	    VC_INITSTR( LeadNamNum[i].LeadData.FibEnds[1].szModId );
	    VC_INITSTR( LeadNamNum[i].LeadData.FibEnds[1].szPosId );

	    strcpy( LeadNamNum[i].LeadData.LeadNam, LdNames[i] );

	    /* Initialize signal name to the signal
	     * in the same lead on the trunk cable */
	    status = VCGetSignalForLead( msg, &ParId, LdNames[i],
					 LeadNamNum[i].LeadData.SigNam );

	    LeadNamNum[i].LeadData.nEndStat[0] = VC_CBE_FROMMAIN;
	    LeadNamNum[i].LeadData.nEndStat[1] = VC_CBE_OPEN;

	    LeadNamNum[i].LeadData.nFibStat = VC_CAB_SUB;

	    VC_ConNum_LeadName( msg, &MyId, LeadNamNum[i].LeadData.LeadNam,
				&LeadNamNum[i].ConNum );
	}
    else
	for( i=0 ; i<NbLeads ; i++ )
	{
	    LeadNamNum[i].LeadData = Connect_Data[i];
	    VC_ConNum_LeadName( msg, &MyId, LeadNamNum[i].LeadData.LeadNam,
							&LeadNamNum[i].ConNum );
	}

    for( i=0 ; i<NbLeads ; i++ )
	__DBGpr_str("Lead names to be in sub cable",
					     LeadNamNum[i].LeadData.LeadNam );

    qsort( (void *) LeadNamNum, NbLeads, sizeof(struct LNN), LeadNamCompare );

    for( i=0 ; i<NbLeads ; i++ )
	__DBGpr_str("Lead names after sorting based on ConNum",
					      LeadNamNum[i].LeadData.LeadNam );

	       /* Now set the sorted leads into the instance */
    status = om$vla_set_dimension( varray = me->Connect_Data,
				   size   = NbLeads );

    for( i=0 ; i<NbLeads ; i++ )
	me->Connect_Data[i] = LeadNamNum[i].LeadData;

    _FREE( LeadNamNum );

    /* Create place holders for the marker attribute. Note: This may be called
     * only after the vla size for me->Connect_Data has been set. */
    VCsyncLdAttrInfo( &MyId );

    // Propagate Marker information (based on ParId).
    {
	IGRboolean bLgcy=FALSE;
	struct VCLdInfo	*LdInfo = NULL;

	LdInfo = _MALLOC( NbLeads , struct VCLdInfo );
	for( i=0 ; i<NbLeads ; i++ )
	    strcpy( LdInfo[i].LeadNam , me->Connect_Data[i].LeadNam );

	status = 
	VCGetAttrInfoForLead(&ParId, LdInfo, NbLeads, VC_MARKER_TYPE, &bLgcy);
	if( !(status&1) || bLgcy )
	    __DBGpr_obj("Error fetching marker from",ParId);

	status = VCSetMarkerInfoForLead(&MyId, LdInfo, NbLeads);
	if( !(status&1) )
	    __DBGpr_obj("Error Propagating Marker to",MyId);

	_FREE( LdInfo );
    }

    End;
    return status;
}

method VCGetLayout( IGRlong	*msg;
		    IGRchar	*Modnam;
		    IGRshort	*nEnt;
		    IGRshort	*nTab;
		    struct VClayout	*Layout )
{
    IGRint          status, CabEnd;

    SetProc( VCCable_VCGetLayout ); Begin;

    status = om$send( msg	= message VCCable.VCAmISubCab( msg, &CabEnd,
							       NULL, NULL, NULL
							     ),
		      targetid	= my_id );

    if( (CabEnd!=VCC_SPLIT_BEGIN) && (CabEnd!=VCC_SPLIT_END) )
    {
	/* I am a "Normal" cable. Get my layout from the Model */

	struct GRid     Modelid;

	status =
	om$send( msg	  = message VCRoot.VCGetModel( msg, &Modelid ),
		 targetid = my_id );

	__DBGpr_obj("Model id of normal cable",Modelid);

	if (Modelid.objid != NULL_OBJID)
	{
	    status =
	    om$send( msg = message VCDB.VCGetLayout( msg, Modnam, nEnt,
						     nTab, Layout),
		     targetid = Modelid.objid,
		     targetos = Modelid.osnum);
	}
	else
	    *msg = MSFAIL;

	End;
	return status;
    }
    else
    {
	IGRint	i;

	*nEnt = *nTab = om$dimension_of(varray = me->Connect_Data);

	if( Layout == NULL )
	{
	    *msg = MSSUCC;
	    End;
	    return OM_S_SUCCESS;
	}

	for( i=0 ; i<*nEnt ; i++ )
	{
	    strcpy( Layout[i].pDef.Conn.Cable.szLeadId,
						 me->Connect_Data[i].LeadNam );
	    strcpy( Layout[i].szDefSig, me->Connect_Data[i].SigNam );

	    Layout[i].pDef.nType = VC_CABLE_TYPE;
	    Layout[i].pAlt.nType = VC_UNKNOWN;

	    Layout[i].nTOPO      = VC_TOPO_CAB;
	}

	End;
	return OM_S_SUCCESS;
    }

}/* end method VCGetLayout */

/* Call the below function to get the Lead Name from Con Num OR vice versa.
 * All arguments are required. If caller wants Lead Name, pass the szLeadName
 * string initialised to "". This indicates to the function that the Lead Name
 * is sought. If string is not initialized or if the lead name is not found,
 * a -1 will be returned as ConNum.
 */

IGRint VC_ConNum_LeadName( IGRlong	*msg,
			   struct GRid	*CabId,
			   IGRchar	 szLeadName[VC_MAX_LEAD_ID],
			   IGRshort	*nConNum )
{
    IGRint	status;

    SetProc( VC_ConNum_LeadName ); Begin

    if( CabId==NULL || szLeadName==NULL || nConNum==NULL )
    {
	*msg=MSFAIL;
	End;
	return OM_E_INVARG;
    }

    if( szLeadName[0]!='\0' )
    {
	IGRshort	t1, t2;
	struct VCpos	Posdef;

	strcpy( Posdef.Conn.Cable.szLeadId, szLeadName );
	__DBGpr_str("Input Lead name", szLeadName );

	/* NOTE: Whether or not CabId passed to this function corresponds to a
	 * sub-cable or not, the below method will ALWAYS query the database.
	 */
	status = om$send( msg = message VCRoot.VCGetPos( msg, &Posdef, &t1,
							 nConNum, &t2 ),
			  senderid = NULL_OBJID,
			  targetid = CabId->objid,
			  targetos = CabId->osnum );
	__DBGpr_int("Output ConNum",*nConNum);
	
	if( *nConNum == -1 )
	{
	    /* Lead name was not found on Cable (per DB defn) */
	    *msg=MSFAIL;
	    status=OM_E_ABORT;
	}

	End;
	return status;
    }
    else
    {
	struct GRid     Modelid;

	__DBGpr_int("Input ConNum",*nConNum);
	status = om$send( msg	  = message VCRoot.VCGetModel( msg, &Modelid ),
			  senderid= NULL_OBJID,
			  targetid= CabId->objid,
			  targetos= CabId->osnum );

	if (Modelid.objid != NULL_OBJID)
	{
	    IGRshort	t1,t2;
	    struct VClayout	*Layout;

	    status =
	    om$send( msg = message VCDB.VCGetLayout( msg, NULL, &t1,
						     &t2, NULL ),
		     senderid = NULL_OBJID,
		     targetid = Modelid.objid,
		     targetos = Modelid.osnum);

	    Layout = _CALLOC( t1, struct VClayout );

	    status =
	    om$send( msg = message VCDB.VCGetLayout( msg, NULL, &t1,
						     &t2, Layout),
		     senderid = NULL_OBJID,
		     targetid = Modelid.objid,
		     targetos = Modelid.osnum);

	    if( (*nConNum<0) || (*nConNum>t1) )
	    {
		/* Invalid input! */
		*msg=MSFAIL;
		status=OM_E_ABORT;
	    }
	    strcpy( szLeadName, Layout[*nConNum].pDef.Conn.Cable.szLeadId );
	    __DBGpr_str("Output Lead name", szLeadName);
	    
	    _FREE( Layout );
	}
	else
	    *msg = MSFAIL;

	End;
	return status;
    }
}



/*
 * Interface function for macro VC$GetTrunkCab()
 */
IGRlong VCGetTrunkCable(
                         IGRlong     *msg,        // O - return msg
                         struct GRid *arbNetCable,// I - any cable in network
                         struct GRid *trunkCable  // O - trunk or main cable
                       )
{
  IGRlong sts ;
  IGRint  status, nWhichEnd;
  struct GRid subCable, parID;
 
  *msg = MSFAIL;
  sts  = OM_W_ABORT;

  if(!arbNetCable) goto wrapup;
  if(!trunkCable)  goto wrapup;

  trunkCable->objid = NULL_OBJID;

  parID = *arbNetCable;

   do{
        *trunkCable = parID;
        subCable    = parID;

        parID.objid = NULL_OBJID;
        status = om$send( msg      = message VCCable.VCAmISubCab( msg,
                                                                  &nWhichEnd,
                                                                  &parID,
                                                                  NULL,
                                                                  NULL ),
			  senderid = NULL_OBJID,
                          targetid = subCable.objid,
                          targetos = subCable.osnum );
   }while((status&*msg&1) && (parID.objid != NULL_OBJID));

  //Done
  *msg= MSSUCC;
  sts = OM_S_SUCCESS; 
wrapup:
  return sts;
}


/*
 * Given a main cable ID, this function will recurse the cable tree 
 * to return the total number of subcables in the network
 */

IGRlong VCrecurseSubCables(
                            struct GRid *mainCable, 
                            IGRint      *nCab, 
                            struct GRid *subCabList,
			    struct GRid *endCabList,
			    IGRint      *nEndCab
                          )
{
  IGRlong retFlag = 0, msg;
  IGRint  i, status, nSubCab, oldCab;
  struct GRid *subCables;

  if(!nCab && !nEndCab) goto wrapup;

  nSubCab = 0; 
  subCables = NULL;
  status = om$send( msg      = message VCCable.VCAmIParCab( &msg,
                                                            &nSubCab,
                                                            NULL ),
		    senderid = NULL_OBJID,
                    targetid = mainCable->objid,
                    targetos = mainCable->osnum );
  if(!(status&msg&1)) goto wrapup;
  if(nSubCab == 0)
  {
    __DBGpr_obj("I HAVE !!! NO MORE SUB CABLES !!! ", *mainCable);
    if(endCabList && nEndCab) 
    {
      endCabList[*nEndCab] = *mainCable;
      (*nEndCab) ++;
    }
    else
    {
      if(nEndCab) {(*nEndCab)++;} 
    }
    
    retFlag = 1;
    goto wrapup;
  }
  subCables = _MALLOC(nSubCab, struct GRid);
  __CheckPtr( subCables, "Alloc for subCables failed", wrapup );

  status = om$send( msg      = message VCCable.VCAmIParCab( &msg,
                                                            &nSubCab,
                                                            subCables ),
		    senderid = NULL_OBJID,
                    targetid = mainCable->objid,
                    targetos = mainCable->osnum );
  if(!(status&msg&1)) goto wrapup;
  if(nCab)
  {
    oldCab = *nCab;
    *nCab += nSubCab;
  }
  if(subCabList)
  {
    for(i = 0; i < nSubCab; i++ )
    {
      subCabList[oldCab] = subCables[i];
      oldCab ++;
    }
  } 
  for(i = 0; i < nSubCab; i++ )
  {
    VCrecurseSubCables(&subCables[i],nCab,subCabList, endCabList, nEndCab); 
  } 

  //Done
  retFlag = 1;
wrapup:
  _FREE(subCables);
  return retFlag;
}


/*
 * Interface function for macro VC$GetALLSubCab()
 */
IGRlong VCGetAllSubCab(
                         IGRlong     *msg,       // O - return message 
                         struct GRid *mainCable, // I - main cable of network
                         IGRint      *nSubCab,   // O - no. of subcables
                         struct GRid *listSubCab,// O - list of subcables
                         IGRint      *nEndCab,   // O - no. of endcables
                         struct GRid *listEndCab // O - list of endcables
                       )
{
  IGRlong sts ;
  IGRint  status, nCab, i, nEnd;
  struct GRid *subCabList, *endCabList;
 
  *msg        = MSFAIL;
  sts         = OM_W_ABORT;

  if( !mainCable ) goto wrapup; // input should contain the main cable
  if( !nEndCab && !nSubCab ) goto wrapup; // either of them should be asked for

  subCabList  = NULL;
  endCabList  = NULL;
  nCab        = 0;
  nEnd        = 0;
  if(nSubCab) *nSubCab    = 0;
  if(nEndCab) *nEndCab    = 0;

  sts = VCrecurseSubCables(mainCable, &nCab, NULL, NULL, &nEnd);
  if(!(sts&1)) goto wrapup;
  if(nCab == 0) // no subcables found
  {
    __DBGpr_obj("DESERTED MAIN CABLE", *mainCable);
    __DBGpr_int("No. of SubCables  ",nCab);
    __DBGpr_int("No. of EndCables  ",nEnd);

    if(nSubCab) *nSubCab = nCab; 
    if(nEndCab)
    {
      // the main cable itself is the end cable
      *nEndCab = nEnd; 
      if(listEndCab)
      {
        listEndCab[0] = *mainCable;
      }
    }
    *msg     = MSSUCC;
    sts      = OM_S_SUCCESS;
    goto wrapup;
  }

  // fill the info the subcables
  if(nSubCab) 
  {

    __DBGpr_int("No. of SubCables  ",nCab);
    __DBGpr_int("No. of EndCables  ",nEnd);

    // fill the output count
    *nSubCab = nCab; 

    if(listSubCab)
    {
      subCabList = _MALLOC(nCab, struct GRid);
      __CheckPtr( subCabList, "Alloc for subCables failed", wrapup );

      nCab = 0; // required to be reset for calling VCrecurseSubCables
      sts = VCrecurseSubCables(mainCable, &nCab, subCabList, NULL, NULL);
      if(!(sts&1)) goto wrapup;

      // fill the output list
      for(i=0; i<nCab; i++) listSubCab[i] = subCabList[i]; 
    }
  }

  // fill the info the endcables
  if(nEndCab) 
  {

    __DBGpr_int("No. of SubCables  ",nCab);
    __DBGpr_int("No. of EndCables  ",nEnd);

    // fill the output count
    *nEndCab = nEnd; 

    if(listEndCab)
    {
      endCabList = _MALLOC(nEnd, struct GRid);
      __CheckPtr( endCabList, "Alloc for endCables failed", wrapup );

      nEnd = 0; // required to be reset for calling VCrecurseSubCables
      sts = VCrecurseSubCables(mainCable, NULL, NULL, endCabList, &nEnd);
      if(!(sts&1)) goto wrapup;

      // fill the output list
      for(i=0; i<nEnd; i++) listEndCab[i] = endCabList[i]; 
    }
  }
 
  //Done
  *msg     = MSSUCC;
  sts      = OM_S_SUCCESS;
wrapup:
  _FREE(endCabList);
  _FREE(subCabList);
  return sts;
}


/*
 * Interface function for macro VC$GetNetworkForCable();
 * Any of cableID or networkLdInfo can be the inputs to generate
 * the outputs 
 */

IGRlong VCGetCableNetwork(
			   IGRlong          *mesg,          // O - return code
                           struct GRid      *cableID,       // I - any cable
                           struct VCLdInfo  *networkLdInfo, // I - lead info
                           IGRint           *nLeads,        // I - no. leads                      
                           struct GRid      *allCables,     // O - all cables
                           IGRint           *nCables,       // O - count 
                           struct GRid      *begSubCabs,    // O - sub cables
                           IGRint           *nBegSubCabs,   // O - count 
                           struct GRid      *endSubCabs,    // O - sub cables
                           IGRint           *nEndSubCabs,   // O - count 
                           struct GRid      *begLeafCabs,   // O - beg leafcabs
                           IGRint           *nBegLeafCabs,  // O - count 
                           struct GRid      *endLeafCabs,   // O - end leafcabs
                           IGRint           *nEndLeafCabs,  // O - count 
                           struct GRid      *begTerms,      // O - beg terms
                           IGRint           *nBegTerms,     // O - count 
                           struct GRid      *endTerms,      // O - end terms
                           IGRint           *nEndTerms      // O - count 
                         ) 
{
  IGRlong       retFlag = 0, sts, msg;
  struct GRid   trunkCable, *subCables;
  struct GRid   *cables, *begCables, *endCables;
  struct GRid   *begLeafCables, *endLeafCables;
  IGRint        nSub, i, j, nBeg, nEnd, begCount;
  IGRint        nCount, nBegLeaf, nEndLeaf, endCount; 
  IGRint        nLocalBegTerms, nLocalEndTerms; 
  IGRint        *nBegCabs, *nEndCabs;

  *mesg = MSFAIL;

  if((!cableID) && (!networkLdInfo)) goto wrapup;

  // Init
  trunkCable.objid = NULL_OBJID;
  nSub             = 0;
  nBeg     	   = 0;
  nEnd     	   = 0;
  nCount     	   = 0;
  begCount     	   = 0;
  endCount     	   = 0;
  nBegLeaf     	   = 0;
  nEndLeaf     	   = 0;
  nLocalBegTerms   = 0;
  nLocalEndTerms   = 0;
  cables           = NULL;
  subCables        = NULL;
  begCables        = NULL;
  begLeafCables    = NULL;
  endCables        = NULL;
  endLeafCables    = NULL;
  nBegCabs         = NULL;
  nEndCabs         = NULL;

  if(nCables)             *nCables         = 0;
  if(nBegLeafCabs)        *nBegLeafCabs    = 0;
  if(nEndLeafCabs)        *nEndLeafCabs    = 0;
  if(nBegTerms)           *nBegTerms       = 0;
  if(nEndTerms)           *nEndTerms       = 0;
  if(nBegSubCabs)         *nBegSubCabs     = 0;
  if(nEndSubCabs)         *nEndSubCabs     = 0;

  if(cableID)
  {
    // get the main cable in the network
    sts = VC$GetTrunkCab( msg              = &msg,
			  p_gridCabId      = cableID,
			  p_gridTrunkCabId = &trunkCable
			);
    if(!(sts&msg&1) || (trunkCable.objid == NULL_OBJID))
    {
      __DBGpr_obj("TRUNK CABLE ", trunkCable);
      __DBGpr_obj("VC$GetTrunkCab FAILED ", *cableID);
      goto wrapup;
    }
    __DBGpr_obj("TRUNK CABLE ", trunkCable);
    // get the no. of subcables on either end of main cable  
    sts = VC$SubCabLeadInfo( p_msg        = &msg,
			     gridInputCab = trunkCable,
			     p_nEndCab    = &nEnd,
			     p_nBegCab    = &nBeg
			   );
     if(!(sts&msg&1) )
     {
       __DBGpr_obj("VCCable.VCGetInfoSubCab FAILED ", trunkCable);
       goto wrapup;
     }
     __DBGpr_int("nBeg ", nBeg);
     __DBGpr_int("nEnd ", nEnd);
     
     if(nBeg)
     {
       begCables = _MALLOC(nBeg,struct GRid);
       nBegCabs  = _MALLOC(nBeg,IGRint);
       __CheckPtr( begCables, "Alloc for begCables failed!", wrapup );

       for(i=0; i<nBeg; i++) nBegCabs[i] = 0;
     }
     if(nEnd)
     {
       endCables = _MALLOC(nEnd,struct GRid);
       nEndCabs  = _MALLOC(nEnd,IGRint);
       __CheckPtr( endCables, "Alloc for SubCables failed!", wrapup );

       for(i=0; i<nEnd; i++) nEndCabs[i] = 0;
     }
      
     // get the list of subcables on either end of main cable  
     sts = VC$SubCabLeadInfo( p_msg        = &msg,
			      gridInputCab = trunkCable,
			      p_nBegCab    = &nBeg,
			      p_gridBegCab = begCables,
			      p_nEndCab    = &nEnd,
			      p_gridEndCab = endCables
			    );
     if(!(sts&msg&1) )
     {
       __DBGpr_obj("VCCable.VCGetInfoSubCab FAILED for ", trunkCable);
       goto wrapup;
     }

    if(nBegSubCabs)
    {
      IGRint begSubCabCnt = nBeg, nCount = 0;

      for(i=0; i<nBeg; i++)
      {
	nCount = 0;
        sts = VC$GetALLSubCab ( msg              = &msg,
  			        p_gridMainCabId  = &begCables[i],
			        p_intNbSubCab    = &nCount
			      );
        if(!(sts&msg&1))
        {
          __DBGpr_obj("VC$GetALLSubCab failed for", begCables[i]);
	  goto wrapup;
        }
	begSubCabCnt += nCount;
	nBegCabs[i] = nCount;
      }
      *nBegSubCabs = begSubCabCnt;
      __DBGpr_int("NO. OF BEGIN SUBCABLES", *nBegSubCabs);

      if(begSubCabs)
      {
	begSubCabCnt = 0;

        for(i=0; i<nBeg; i++)
	{
	  begSubCabs[begSubCabCnt] = begCables[i];
	  begSubCabCnt ++;
	}
        for(i=0; i<nBeg; i++)
        {
	  _FREE(cables);
	  if(nBegCabs[i])
	  {
	    cables = _MALLOC(nBegCabs[i], struct GRid);
            __CheckPtr( cables, "Alloc for cables failed!", wrapup );

	    nCount = 0;
            sts = VC$GetALLSubCab ( msg              = &msg,
			            p_gridMainCabId  = &begCables[i],
				    p_intNbSubCab    = &nCount,
				    p_gridSubCabId   = cables);
           if(!(sts&msg&1))
           {
             __DBGpr_obj("VC$GetALLSubCab failed for", begCables[i]);
	     goto wrapup;
           }
	   for(j=0; j<nCount; j++)
	   {
             begSubCabs[begSubCabCnt] = cables[j];
	     begSubCabCnt ++;
	   }
	  }
        }
      }
    }
    if(nEndSubCabs)
    {
      IGRint endSubCabCnt = nEnd, nCount = 0;

      for(i=0; i<nEnd; i++)
      {
	nCount = 0;
        sts = VC$GetALLSubCab ( msg              = &msg,
  			        p_gridMainCabId  = &endCables[i],
			        p_intNbSubCab    = &nCount);
        if(!(sts&msg&1))
        {
          __DBGpr_obj("VC$GetALLSubCab failed for", endCables[i]);
	  goto wrapup;
        }
	endSubCabCnt += nCount;
	nEndCabs[i] = nCount;
      }
      *nEndSubCabs = endSubCabCnt;
      __DBGpr_int("NO. OF END SUBCABLES", *nEndSubCabs);

      if(endSubCabs)
      {
	endSubCabCnt = 0;

        for(i=0; i<nEnd; i++)
	{
	  endSubCabs[endSubCabCnt] = endCables[i];
	  endSubCabCnt ++;
	}
        for(i=0; i<nEnd; i++)
        {
	  _FREE(cables);
	  if(nEndCabs[i])
	  {
	    cables = _MALLOC(nEndCabs[i], struct GRid);
            __CheckPtr( cables, "Alloc for cables failed!", wrapup );

	    nCount = 0;
            sts = VC$GetALLSubCab ( msg              = &msg,
			            p_gridMainCabId  = &endCables[i],
				    p_intNbSubCab    = &nCount,
				    p_gridSubCabId   = cables);
           if(!(sts&msg&1))
           {
             __DBGpr_obj("VC$GetALLSubCab failed for", endCables[i]);
	     goto wrapup;
           }
	   for(j=0; j<nCount; j++)
	   {
             endSubCabs[endSubCabCnt] = cables[j];
	     endSubCabCnt ++;
	   }
	  }
        }
      }
    }
    // fill out the return info only when asked for
    if((nBegTerms || nEndTerms) ||
       (nBegLeafCabs || nEndLeafCabs))
    {
      if(nBegTerms || nBegLeafCabs) 
      {
        // gather all the leaf cables on the begin end of main cable 
        nBegLeaf = 0;

	// If there are no subcables at the begining, i myself am the
	// leaf cable
	if(nBeg == 0) nBegLeaf = 1;

        for(i=0; i<nBeg; i++)
        {
  	  nCount = 0;
  	  // get the count of the leaf cables
	  sts = VC$GetALLSubCab ( msg              = &msg,
				  p_gridMainCabId  = &begCables[i],
				  p_intNbEndCab    = &nCount);
  	  if(!(sts&msg&1))
  	  {
  	    printf("VC$GetALLSubCab failed to get the list of subcables\n");
            goto wrapup; 
          }
	  nBegLeaf += nCount;
        }
	__DBGpr_int(" nBegLeaf ", nBegLeaf);

	if(nBegLeafCabs) *nBegLeafCabs = nBegLeaf;
	if((!nBegTerms) && (!begLeafCabs) && (!begTerms))
	  goto check_endlist_info;

	if(nBegTerms || begLeafCabs)
	{
	  if( nBegLeaf )
	  {
            begLeafCables = _MALLOC(nBegLeaf,struct GRid);
            __CheckPtr(begLeafCables,"Alloc for begLeafCables failed!", wrapup );
	  }

	  // for each begin subcable, populate the leaf cable list
	  begCount = 0;
	  if(nBeg == 0) 
	  {
	      begCount = 1;
	      begLeafCables[0] = trunkCable; 
	  }
	  for(i=0; i<nBeg; i++)
	  {
	    nCount = 0;
	    _FREE(cables);

	    // get the count of the leaf cables
	    sts = VC$GetALLSubCab ( msg              = &msg,
				    p_gridMainCabId  = &begCables[i],
				    p_intNbEndCab    = &nCount);
  	    if(!(sts&msg&1))
  	    {
  	      printf("VC$GetALLSubCab failed to get the list of subcables\n");
              goto wrapup; 
            }
	    __DBGpr_obj("SUB CABLE", begCables[i]);
	    __DBGpr_int("NO. OF LEAF CABLES", nCount);
	    if(nCount)
	    {
              cables = _MALLOC(nCount,struct GRid);
              __CheckPtr( cables, "Alloc for SubCables failed!", wrapup );
	    }

	    // get the list of the leaf cables
	    sts = VC$GetALLSubCab ( msg              = &msg,
				    p_gridMainCabId  = &begCables[i],
				    p_intNbEndCab    = &nCount,
				    p_gridEndCabId   = cables);
  	    if(!(sts&msg&1))
  	    {
  	      printf("VC$GetALLSubCab failed to get the list of subcables\n");
              goto wrapup; 
            }

	    for(j=0; j<nCount; j++)
	    {
	      begLeafCables[begCount] = cables[j];
	      begCount ++;
	    }
	  }
	  __DBGpr_int("NO. OF BEGIN_LEAF_CABLES", begCount);
          __DBGpr_objlist("BEGIN_LEAF_CABLE",begCount,begLeafCables);
      
	  // fill the leaf cable info
	  if(begLeafCabs && nBegLeafCabs)
	  {
	    // fill the output list of all the leaf cables
            *nBegLeafCabs = begCount;

	    for(i=0; i<begCount; i++)
	      begLeafCabs[i] = begLeafCables[i];
	  }
	  // terminal info requires leaf cables anyway
	  if(nBegTerms)
	  {
	    struct GRid termID;
            IGRint termCount, nEnd;

            __DBGpr_int(" begCount ", begCount);

	    *nBegTerms = 0;

            for(i=0;i<begCount;i++)
	    {
	      termID.objid = NULL_OBJID;
	      nEnd = 1;

	      if((begLeafCables[i].objid == trunkCable.objid) &&
		 (begLeafCables[i].osnum == trunkCable.osnum)) 
		   nEnd = 0;

	      sts = om$send( msg=message VCCable.VCCbTerm(&msg, nEnd, &termID),
			  senderid = NULL_OBJID,
			  targetos = begLeafCables[i].osnum, 
			  targetid = begLeafCables[i].objid );
              if(!(sts&msg&1))
	      {
                __DBGpr_obj(" VCCable.VCCbTerm failed for", begLeafCables[i]);
		continue;
	      }
	      __DBGpr_obj("BEGIN_LEAF_CABLE ", begLeafCables[i]);
	      __DBGpr_obj("TERMINAL ", termID);

	      if(termID.objid == NULL_OBJID) continue;

	      if(begTerms)
	      {
		begTerms[*nBegTerms] = termID;
              }
	      (*nBegTerms) ++;
	    }
	    __DBGpr_int("No. of BEGIN TERMINALS ", *nBegTerms);
            if(begTerms)
	      __DBGpr_objlist("BEGIN TERMINAL",*nBegTerms,begTerms);
	  }
        }
      } // if the user asked for the begin terminals

check_endlist_info:

      if(nEndTerms || nEndLeafCabs) 
      {
        // gather all the leaf cables on the end side of main cable 
        nEndLeaf = 0;

	// If there are no subcables at the end, i myself am the
	// leaf cable
	if(nEnd == 0) nEndLeaf = 1;

        for(i=0; i<nEnd; i++)
        {
  	  nCount = 0;
  	  // get the count of the leaf cables
	  sts = VC$GetALLSubCab ( msg              = &msg,
				  p_gridMainCabId  = &endCables[i],
				  p_intNbEndCab    = &nCount);
  	  if(!(sts&msg&1))
  	  {
  	    printf("VC$GetALLSubCab failed to get the list of subcables\n");
            goto wrapup; 
          }
	  nEndLeaf += nCount;
        }
	__DBGpr_int(" nEndLeaf ", nEndLeaf);

	if(nEndLeafCabs) *nEndLeafCabs = nEndLeaf;

	if((!nEndTerms) && (!endLeafCabs) && (!endTerms))
	  goto check_allcable_info;

	if(nEndTerms || endLeafCabs)
	{
	  if( nEndLeaf )
	  {
            endLeafCables = _MALLOC(nEndLeaf,struct GRid);
            __CheckPtr(endLeafCables,"Alloc for endLeafCables failed!", wrapup );
	  }

	  // for each end subcable, populate the leaf cable list
	  endCount = 0;
	  if(nEnd == 0) 
	  {
	      endCount = 1;
	      endLeafCables[0] = trunkCable; 
	  }
	  for(i=0; i<nEnd; i++)
	  {
	    nCount = 0;
	    _FREE(cables);

	    // get the count of the leaf cables
	    sts = VC$GetALLSubCab ( msg              = &msg,
				    p_gridMainCabId  = &endCables[i],
				    p_intNbEndCab    = &nCount);
  	    if(!(sts&msg&1))
  	    {
  	      printf("VC$GetALLSubCab failed to get the list of subcables\n");
              goto wrapup; 
            }
	    __DBGpr_obj("SUB CABLE", endCables[i]);
	    __DBGpr_int("NO. OF LEAF CABLES", nCount);
	    if(nCount)
	    {
              cables = _MALLOC(nCount,struct GRid);
              __CheckPtr( cables, "Alloc for SubCables failed!", wrapup );
	    }

	    // get the list of the leaf cables
	    sts = VC$GetALLSubCab ( msg              = &msg,
				    p_gridMainCabId  = &endCables[i],
				    p_intNbEndCab    = &nCount,
				    p_gridEndCabId   = cables);
  	    if(!(sts&msg&1))
  	    {
  	      printf("VC$GetALLSubCab failed to get the list of subcables\n");
              goto wrapup; 
            }

	    for(j=0; j<nCount; j++)
	    {
	      endLeafCables[endCount] = cables[j];
	      endCount ++;
	    }
	  }
	  __DBGpr_int("NO. OF END_LEAF_CABLES", endCount);
          __DBGpr_objlist("END_LEAF_CABLE",endCount,endLeafCables);
      
	  // fill the leaf cable info
	  if(endLeafCabs && nEndLeafCabs)
	  {
	    // fill the output list of all the leaf cables
            *nEndLeafCabs = endCount;

	    for(i=0; i<endCount; i++)
	      endLeafCabs[i] = endLeafCables[i];
	  }
	  // terminal info requires leaf cables anyway
	  if(nEndTerms)
	  {
	    struct GRid termID;
            IGRint termCount;

	    *nEndTerms = 0;

            for(i=0;i<endCount;i++)
	    {
	      termID.objid = NULL_OBJID;
	      sts = om$send( msg = message VCCable.VCCbTerm(&msg, 1,&termID),
			  senderid = NULL_OBJID,
			  targetos = endLeafCables[i].osnum, 
			  targetid = endLeafCables[i].objid );
              if(!(sts&msg&1))
	      {
                __DBGpr_obj(" VCCable.VCCbTerm failed for", endLeafCables[i]);
		continue;
	      }
	      if(termID.objid == NULL_OBJID) continue;

	      __DBGpr_obj("END_LEAF_CABLE ", endLeafCables[i]);
	      __DBGpr_obj("TERMINAL ", termID);

	      if(endTerms)
	      {
		endTerms[*nEndTerms] = termID;
              }
	      (*nEndTerms) ++;
	    }
	    __DBGpr_int("No. of END TERMINALS ", *nEndTerms);
            if(endTerms)
	      __DBGpr_objlist("END TERMINAL",*nEndTerms,endTerms);
	  }
        }
      } // if the user asked for the end terminals
    }

check_allcable_info:

    // fill out the return info only when asked for
    if(nCables)
    {
      // query only for the number of subcables
      nSub = 0;
      sts = VC$GetALLSubCab ( msg              = &msg,
        		      p_gridMainCabId  = &trunkCable,
			      p_intNbSubCab    = &nSub
                            );
      if(!(sts&msg&1))
      {
        printf("VC$GetALLSubCab failed to get the list of subcables\n");
        goto wrapup;
      }	

      *nCables = nSub + 1; // provision for main cable
      __DBGpr_int("No. of SUB CABLES", nSub);
      __DBGpr_int("No. of ALL CABLES", *nCables);

      if(allCables) allCables[0] = trunkCable;

      if(allCables && nSub)
      {
        subCables = _MALLOC(nSub,struct GRid);
        __CheckPtr( subCables, "Alloc for SubCables failed!", wrapup );
 
        // query for the list of subcables
        nSub = 0;
        sts = VC$GetALLSubCab ( msg              = &msg,
          		        p_gridMainCabId  = &trunkCable,
			        p_intNbSubCab    = &nSub,
			        p_gridSubCabId   = subCables
                              );
        if(!(sts&msg&1))
        {
          printf("VC$GetALLSubCab failed to get the list of subcables\n");
          goto wrapup;
        }	
        __DBGpr_objlist("SUB CABLE",nSub,subCables);

        for(i=1, j=0; i<(*nCables); i++, j++)
        {
          allCables[i] = subCables[j];
        }
        __DBGpr_objlist("ALL CABLES",*nCables,allCables);
      }
    }
   } 

   //Done
   *mesg = MSSUCC;
   retFlag = 1;
wrapup:
  _FREE(cables);
  _FREE(subCables);
  _FREE(begCables);
  _FREE(begLeafCables);
  _FREE(endCables);
  _FREE(endLeafCables);
  _FREE(nBegCabs);
  _FREE(nEndCabs);
  return retFlag;
}                            


/*
 * Given a lead and a list of subcables, this function will check if 
 * any of the subcable has the lead and if so returns the matching
 * subcable
 */
IGRlong VCGetSubCableForLead( 
			      IGRlong               *mesg,       
		              GRname                leadName,     
			      IGRint                nConNum,     
			      struct GRid           *mainCable, 
			      struct GRid           *matchSubCab, 
			      IGRint                nSubCab,
			      struct GRid           *listSubCab
                            )
{
  IGRlong             retFlag = 0, msg, sts;
  IGRint              i, j;
  struct VClayout     *Layout;
  IGRshort            nEnt, nTab;

  *mesg = MSFAIL;
  matchSubCab->objid = NULL_OBJID;
  Layout = NULL;

  if(!listSubCab) goto wrapup;


  for(i=0; i<nSubCab; i++)
  {
    _FREE(Layout); 
    Layout = NULL;
    nEnt   = nTab = 0;

    sts =
    om$send (msg = message VCDB.VCGetLayout
                                (&msg, NULL, &nEnt, &nTab, NULL),
        senderid = NULL_OBJID,
        targetid = listSubCab[i].objid,
        targetos = listSubCab[i].osnum);
    if(!(sts&msg&1))
    {
      __DBGpr_obj(" VCDB.VCGetLayout failed for ", listSubCab[i]);
      continue;
    }
    if(nEnt == 0) continue;
   
    Layout = _MALLOC(nEnt, struct VClayout); 
    sts =
    om$send (msg = message VCDB.VCGetLayout
                                (&msg, NULL, &nEnt, &nTab, Layout),
        senderid = NULL_OBJID,
        targetid = listSubCab[i].objid,
        targetos = listSubCab[i].osnum);
    if(!(sts&msg&1))
    {
      __DBGpr_obj(" VCDB.VCGetLayout failed for ", listSubCab[i]);
      continue;
    }
    for(j=0; j<nEnt; j++)
    {
      if(!strcmp(leadName, Layout[j].pDef.Conn.Cable.szLeadId))
      {
        *matchSubCab = listSubCab[i];
        *mesg        = MSSUCC;
        retFlag      = 1;
        goto wrapup;
      } 
    }
  }
  //Done
  *mesg = MSSUCC;
  retFlag = 1;
wrapup:
  _FREE(Layout);
  __DBGpr_obj(" VCGetSubCableForLead matchSubCab ", *matchSubCab);
  return retFlag;
}


/*
 * This function will findout the lead in the list termLeads that match
 * the input lead name and nConNum and return the matching index of the
 * lead in the list
 */
IGRlong VCLdFindMatchLead(
			   GRname               leadName, 
			   IGRint               nConNum, 
			   IGRint               nTermLd, 
			   struct VCcab_connect *termLeads, 
			   IGRint               *matchIndex
			 )
{
  IGRlong retFlag = 0;
  int i;

  *matchIndex = -1;
  if(!termLeads) goto wrapup;

  for(i=0; i<nTermLd; i++)
  {
    if(!strcmp(leadName, termLeads[i].LeadNam))
    {
      *matchIndex = i;
      retFlag = 1;
      goto wrapup;
    }
  }
  //Done
  retFlag = 1;
wrapup:
  return retFlag;
}


/*
 * This function gets the terminal for the cable if there is one and 
 * the info for this lead if it is connected to the terminal
 */
IGRlong VCGetTerminalForLead(
				 IGRlong               *mesg,        // O - success msg
				 GRname                leadName,     // I - name of lead
				 IGRint                nConNum,      // DB no. of lead
				 struct GRid           *mainCable,   // I - main cable
				 IGRint                whichEnd,     // I - which side of trunk
				 struct GRid           *Terminal,    // O - terminal at end
			         struct VCTpos         *TermPin      // O - pin on terminal
                               )
{
  IGRlong              retFlag = 0, sts, msg;
  IGRint               i, nTermLd, matchIndex;
  struct VCcab_connect *termLeads;
  struct GRid           Term ;

  *mesg             = MSFAIL;
  if(!mainCable)    goto wrapup;

  termLeads         = NULL;
  nTermLd           = 0;

   __DBGpr_obj("MAIN CABLE ",*mainCable);
   __DBGpr_int("whichEnd ", whichEnd);
   /*
    * check if there is a terminal attached to the main cable
    */
   Term.objid = NULL_OBJID;
   Term.osnum = 2;
   sts = VCGetCabConnTerm( &msg, *mainCable, whichEnd, NULL, NULL, &Term, 0);
   if(!(sts&msg&1))
   {
     __DBGpr_obj(" VCGetCabConnTerm failed for", *mainCable);
     goto wrapup;
   }
   if(Term.objid == NULL_OBJID)
   {
     __DBGpr_obj("MAIN CABLE HAS NO TERMINAL ATTACHED", *mainCable);
     *mesg   = MSSUCC;
     retFlag = 1;
     goto wrapup;
   }

   if(Terminal) *Terminal = Term;
   /*
    * get the no. of leads taken by the terminal 
    */
   nTermLd = 0;
   sts = VCGetCabConnTerm( &msg, *mainCable, whichEnd, &nTermLd, NULL, &Term, 0);
   if(!(sts&msg&1))
   {
     __DBGpr_obj(" VCGetCabConnTerm failed for", *mainCable);
     goto wrapup;
   }
   if(nTermLd == 0)
   {
     __DBGpr_obj(" No leads connected to the terminal", Term); 
     if(TermPin)
     {
       VC_INITSTR(TermPin->szModId);
       VC_INITSTR(TermPin->szPosId);
     }
     *mesg   = MSSUCC;
     retFlag = 1;
     goto wrapup;
   }
   __DBGpr_int(" nTermLd ", nTermLd);

   termLeads = _MALLOC(nTermLd, struct VCcab_connect);
   __CheckPtr( termLeads, "Alloc for termLeads failed!", wrapup );

   nTermLd = 0;
   sts = VCGetCabConnTerm( &msg, *mainCable, whichEnd, &nTermLd, termLeads, &Term, 0);
   if(!(sts&msg&1))
   {
     __DBGpr_obj(" VCGetCabConnTerm failed for", *mainCable);
     goto wrapup;
   }

   matchIndex = -1;
   sts = VCLdFindMatchLead(leadName, nConNum, nTermLd, termLeads, &matchIndex); 
   if(!(sts&1))
   {
     __DBGpr_str(" VCLdFindMatchLead failed for LeadName ", leadName);
     goto wrapup;
   }

   // none of the terminal leads matched our lead
   if(matchIndex == -1)
   {
     // our lead is a free lead
     if(TermPin)
     {
       VC_INITSTR(TermPin->szModId);
       VC_INITSTR(TermPin->szPosId);
     }
     *mesg   = MSSUCC;
     retFlag = 1;
     goto wrapup;
   }
   else // there is a matching lead in the terminal
   {
     if(TermPin)
     {
       strcpy(TermPin->szModId, termLeads[matchIndex].FibEnds[whichEnd].szModId); 
       strcpy(TermPin->szPosId, termLeads[matchIndex].FibEnds[whichEnd].szPosId); 
     }
   }

  //Done
  *mesg   = MSSUCC;
  retFlag = 1;
wrapup:
  _FREE(termLeads);

  __DBGpr_obj("mainCable ", *mainCable);
  __DBGpr_int("VCGetTerminalForLead retFlag ", retFlag);

  return retFlag; 
}


/*
 * This function will recurse through the network to get the 
 * subcables through which the lead passes and any terminal info
 * the lead is connected to
 */
IGRlong VCrecurseNetworkForLead(
				 IGRlong       *mesg,        // O - success msg
				 GRname        leadName,     // I - name of lead
				 IGRint        nConNum,      // DB no. of lead
				 struct GRid   trunkCable,   // I - trunk cable
				 struct GRid   *mainCable,   // I - main cable
				 struct GRid   *subCabList,  // I - list of subcabs
				 IGRint        nSubCab,      // I - count
				 IGRint        *nTotCables,  // O - count 
				 struct GRid   *totCables ,  // O - all cables for Lead
				 IGRint        whichEnd,     // I - which side of trunk
				 struct GRid   *Terminal,    // O - terminal at end
			         struct VCTpos *TermPin      // O - pin on terminal
                               )
{
  IGRlong              retFlag = 0, sts, msg;
  IGRint               i;
  IGRint               nSubSubCab, nOther;
  struct GRid          matchSubCab, *SubSubCab;

  if(!nTotCables)                goto wrapup;
  if(!mainCable)                 goto wrapup;

  *mesg             = MSFAIL;
  SubSubCab         = NULL;
  matchSubCab.objid = NULL_OBJID;
  nSubSubCab        = 0;

  /*
   *---------------------------------------------------------------------
   * PSUEDO CODE FOR ALGORITHM BEING IMPLEMENTED HERE
   *---------------------------------------------------------------------
   *
   * check if (mainCable has a terminal attached)
   *       {
   *         // the VCcab_connect for the leads connected to
   *         // the terminal will be available
   *         check if(our lead is connected to the terminal)
   *               {
   *                 assign the lead with Terminal info [*Term]
   *                 assign the pin info from matchIndex......
   *                 *mesg   = MSSUCC;
   *                 retFlag = 1;
   *                 goto wrapup;
   *               }
   *               else
   *               {
   *                 assign the if(Term) Term = NULL;
   *                 assign the pin info if(TermPin) *TermPin = NULL;
   *                 *mesg   = MSSUCC;
   *                 retFlag = 1;
   *                 goto wrapup;
   *               }
   *        } // end if (mainCable has a terminal attached)
   *
   * The above part is implemented by calling VCGetTerminalForLead()
   *--------------------------------------------------------------------
   * The below part is implemented by calling VCGetSubCablesForLead()
   *
   *       check if(subCabList && nSubCab)
   *       {
   *         Find out which of the subcables has our lead [SUBCAB] - say
   *
   *          - One of the subcables CAN have our lead 
   *          - Available lead list CAN have our lead
   *
   *          - Error out with a big MESSAGE in other case 
   *
   *         if(SUBCAB  has our lead)
   *         {
   *           Fill if(totCables) totCables[*nTotCables] = SUBCAB;
   *           (*nTotCables) +  = 1;
   *           Find all the end subcables for the SUBCAB
   *    
   *           // call our recursive routine as follows 
   *           sts = VCrecurseNetworkForLead(&msg, leadName, nConNum, trunkCable, &SUBCAB, begCables, nBeg, 
   *				    &nBegCabs, begCabList, 1, Term, TermPin );
   *           __DBGpr_str(" Lead Name ", leadName);
   *
   *           if(!(sts&msg&1))
   *           {
   *             __DBGpr_com(" VCrecurseNetworkForLead FAILED");
   *             goto wrapup;
   *           }
   *         }
   *         else
   *         {
   *          
   *           assign the if(Term) Term = NULL;
   *           assign the pin info if(TermPin) *TermPin = NULL;
   *           *mesg   = MSSUCC;
   *           retFlag = 1;
   *           goto wrapup;
   *         }
   * 
   *       } 
   *---------------------------------------------------------------------
   */

   /*
    * check if there is a terminal attached to the main cable
    */
   __DBGpr_obj("TRUNK CABLE ",trunkCable);
   __DBGpr_obj("MAIN CABLE ",*mainCable);
   __DBGpr_int("whichEnd ", whichEnd);

   if((mainCable->objid != trunkCable.objid)) whichEnd = 1;

   sts = VCGetTerminalForLead( &msg, leadName, nConNum, mainCable,
			       whichEnd, Terminal, TermPin);
   if(!(sts&msg&1))
   {
     __DBGpr_obj(" VCGetTerminalForLead failed for ", *mainCable);
     goto wrapup;
   }
   if(Terminal->objid != NULL_OBJID)
   {
     __DBGpr_obj(" Terminal ", *Terminal);
     __DBGpr_str(" Terminal Pin szModId ", TermPin->szModId);
     __DBGpr_str(" Terminal Pin szPosId ", TermPin->szPosId);
     *mesg   = MSSUCC;
     retFlag = 1;
     goto wrapup;
   }
   /*
    * check if there are no subcables also
    * If so, all the leads at this whichEnd are free
    */
   if(nSubCab == 0)
   {
     VC_INITSTR(TermPin->szModId);
     VC_INITSTR(TermPin->szPosId);
     *mesg   = MSSUCC;
     retFlag = 1;
     goto wrapup;
   }
   /*
    * We have subcables at this whichEnd
    * The lead can be part of any of the subcables or left free
    * to be taken by other subcables
    */
   sts = VCGetSubCableForLead( &msg, leadName, nConNum, mainCable,
			       &matchSubCab, nSubCab, subCabList);
   if(!(sts&msg&1))
   {
     __DBGpr_obj(" VCGetTerminalForLead failed for ", *mainCable);
     goto wrapup;
   }
   // if there is no matching subcable
   if(matchSubCab.objid == NULL_OBJID)
   {
     VC_INITSTR(TermPin->szModId);
     VC_INITSTR(TermPin->szPosId);
     *mesg   = MSSUCC;
     retFlag = 1;
     goto wrapup;
   }
   else
   {
     // fill the output list
     if(totCables) totCables[*nTotCables] = matchSubCab;
     (*nTotCables) ++;

       sts = VC$SubCabLeadInfo( p_msg              = &msg,
			        gridInputCab       = matchSubCab,
			        p_nEndCab          = &nSubSubCab,
			        p_nBegCab          = &nOther
                              );
     if(!(sts&msg&1) )
     {
       __DBGpr_obj("VC$SubCabLeadInfo FAILED ", matchSubCab);
       goto wrapup;
     }
     if(nSubSubCab) SubSubCab = _MALLOC(nSubSubCab, struct GRid);

     if(nSubSubCab)
     {
         sts = VC$SubCabLeadInfo( p_msg              = &msg,
			          gridInputCab       = matchSubCab,
			          p_nEndCab          = &nSubSubCab,
			          p_gridEndCab       = SubSubCab
                                );
       if(!(sts&msg&1) )
       {
         __DBGpr_obj("VC$SubCabLeadInfo FAILED ", trunkCable);
         goto wrapup;
       }
     }

     sts = VCrecurseNetworkForLead ( &msg, leadName, nConNum, trunkCable,
				     &matchSubCab, SubSubCab, nSubSubCab,
				     nTotCables, totCables, 1, Terminal,
				     TermPin
                                   );
     if(!(sts&msg&1))
     {
       __DBGpr_obj("VCrecurseNetworkForLead failed for maincable", matchSubCab);
       goto wrapup;
     } 
   }
  //Done
  *mesg   = MSSUCC;
  retFlag = 1;
wrapup:
  _FREE(SubSubCab);

  __DBGpr_obj("mainCable ", *mainCable);
  __DBGpr_int("VCrecurseNetworkForLead retFlag ", retFlag);

  return retFlag; 
}

/*
 * This function is interfaced by VC$GetNetworkForLead
 * This fills up the VCLdInfo structure for any lead 
 */

IGRlong VCGetLeadNetwork(
                          IGRlong              *mesg,      // O
			  GRname               leadName,   // I - lead name
			  struct GRid          *cableID,   // I - any cable
			  IGRint               *nCables,   // O - no. of cables
			  struct GRid          *cables,    // O - lead cablelist
			  struct GRid          *begTerm,   // O - lead beg term
			  struct GRid          *endTerm,   // O - lead end term
			  struct VCTpos        *begTermPin,// O - begin pin
			  struct VCTpos        *endTermPin,// O - end pin
			  struct VCLdInfo      *leadInfo   // O - lead info
                        )

{
  IGRlong               retFlag = 0, sts, msg;
  struct GRid           trunkCable;
  struct GRid           *begCables, *endCables;
  IGRint                i,j, nBeg, nEnd, nCount;
  struct GRid           begTerminal, endTerminal; // terminals for lead
  struct VCTpos         bTermPin, eTermPin;       // terminal pins for lead
  IGRint                nBegCabs, nEndCabs;       // through which lead goes
  struct GRid           *begCabList, *endCabList; // lead cable list
  IGRint                nConNum = 10;
  IGRboolean            legacy;

  *mesg             = MSFAIL;
  if(!cableID) goto wrapup;
  if(leadName[0] == '\0') goto wrapup;

  if(nCables)       *nCables = 0;
  if(begTerm)       begTerm->objid = NULL_OBJID;
  if(endTerm)       endTerm->objid = NULL_OBJID;

  trunkCable.objid  = NULL_OBJID;
  begTerminal.objid = NULL_OBJID;
  begTerminal.osnum = 2;
  endTerminal.objid = NULL_OBJID;
  endTerminal.osnum = 2;
  begCabList        = NULL;
  endCabList        = NULL;
  begCables         = NULL;
  endCables         = NULL;
  nBeg              = 0;
  nEnd              = 0;
  nCount            = 0;
  nBegCabs          = 0;
  nEndCabs          = 0;

  VC_INITSTR(bTermPin.szModId);
  VC_INITSTR(bTermPin.szPosId);
  VC_INITSTR(eTermPin.szModId);
  VC_INITSTR(eTermPin.szPosId);

  // get the main cable in the network
   sts = VC$GetTrunkCab( msg              = &msg,
			 p_gridCabId      = cableID,
			 p_gridTrunkCabId = &trunkCable
		       );
  if(!(sts&msg&1) || (trunkCable.objid == NULL_OBJID))
  {
    __DBGpr_obj("TRUNK CABLE ", trunkCable);
    __DBGpr_obj("VC$GetTrunkCab FAILED ", *cableID);
    goto wrapup;
  }

  // get the no. of subcables or terminals 
  // on either end of main cable  
  sts = VC$SubCabLeadInfo( p_msg              = &msg,
			   gridInputCab       = trunkCable,
			   p_nBegCab          = &nBeg,
			   p_nEndCab          = &nEnd
                         );
  if(!(sts&msg&1) )
  {
    __DBGpr_obj("VC$SubCabLeadInfo FAILED ", trunkCable);
    goto wrapup;
  }
  __DBGpr_obj("TRUNK CABLE ", trunkCable);
  __DBGpr_int("Begin cables - nBeg ", nBeg);
  __DBGpr_int("End   cables - nEnd ", nEnd);
 
  if(nBeg)
  {
    begCables = _MALLOC(nBeg, struct GRid);
    __CheckPtr( begCables, "Alloc for begCables failed!", wrapup );
  }
  if(nEnd)
  {
    endCables = _MALLOC(nEnd, struct GRid);
    __CheckPtr( endCables, "Alloc for begCables failed!", wrapup );
  }
  sts = VC$SubCabLeadInfo( p_msg              = &msg,
			   gridInputCab       = trunkCable,
			   p_nBegCab          = &nBeg,
			   p_nEndCab          = &nEnd,
			   p_gridBegCab       = begCables,
			   p_gridEndCab       = endCables
                         );
  if(!(sts&msg&1) )
  {
    __DBGpr_obj("VC$SubCabLeadInfo FAILED ", trunkCable);
    goto wrapup;
  }

  // This is the recursive routine which does all the job
  sts = VCrecurseNetworkForLead(&msg, leadName, nConNum, trunkCable, &trunkCable, begCables, nBeg, 
				&nBegCabs, NULL, 0, &begTerminal, &bTermPin);
  __DBGpr_str(" Lead Name ", leadName);
  __DBGpr_int(" No. of begin cables for this lead ", nBegCabs);

  if(!(sts&msg&1))
  {
    __DBGpr_com(" VCrecurseNetworkForLead FAILED");
    goto wrapup;
  }
  if(nBegCabs)
  {
    begCabList = _MALLOC(nBegCabs, struct GRid);
    __CheckPtr( begCabList, "Alloc for begCabList failed!", wrapup );
  }

  nBegCabs = 0;
  begTerminal.objid = NULL_OBJID;
  sts = VCrecurseNetworkForLead(&msg, leadName, nConNum, trunkCable, &trunkCable, begCables, nBeg, 
				&nBegCabs, begCabList, 0, &begTerminal, &bTermPin );
  __DBGpr_str(" Lead Name ", leadName);

  if(!(sts&msg&1))
  {
    __DBGpr_com(" VCrecurseNetworkForLead FAILED");
    goto wrapup;
  }
  __DBGpr_int(" No. of begin cables for the lead ", nBegCabs);
  __DBGpr_objlist("end Cable for Lead ",nBegCabs,begCabList);
  __DBGpr_obj(" Begin Terminal ", begTerminal);
  __DBGpr_str(" Begin Pin szModId ", bTermPin.szModId);
  __DBGpr_str(" Begin Pin szPosId ", bTermPin.szPosId);

  sts = VCrecurseNetworkForLead(&msg, leadName, nConNum, trunkCable, &trunkCable, endCables, nEnd, 
				&nEndCabs, NULL, 1, &endTerminal, &eTermPin );
  __DBGpr_str(" Lead Name ", leadName);
  __DBGpr_int(" No. of end cables for this lead ", nEndCabs);

  if(!(sts&msg&1))
  {
    __DBGpr_com(" VCrecurseNetworkForLead FAILED");
    goto wrapup;
  }
  if(nEndCabs)
  {
    endCabList = _MALLOC(nEndCabs, struct GRid);
    __CheckPtr( endCabList, "Alloc for endCabList failed!", wrapup );
  }

  nEndCabs = 0;
  endTerminal.objid = NULL_OBJID;
  sts = VCrecurseNetworkForLead(&msg, leadName, nConNum, trunkCable, &trunkCable, endCables, nEnd, 
				&nEndCabs, endCabList, 1, &endTerminal, &eTermPin );
  __DBGpr_str(" Lead Name ", leadName);

  if(!(sts&msg&1))
  {
    __DBGpr_com(" VCrecurseNetworkForLead FAILED");
    goto wrapup;
  }
  __DBGpr_int(" No. of end cables for the lead ", nEndCabs);
  __DBGpr_objlist("end Cable for Lead ",nEndCabs,endCabList);
  __DBGpr_obj(" End Terminal ", endTerminal);
  __DBGpr_str(" End Pin szModId ", eTermPin.szModId);
  __DBGpr_str(" End Pin szPosId ", eTermPin.szPosId);

  // Fill in the output lists
  if(nCables) *nCables = nBegCabs + nEndCabs + 1;

  nCount = 0;
  if(cables)
  {
    for(i=0; i<nBegCabs; i++)
    {
      cables[nCount] = begCabList[i];
      nCount ++;
    }

    cables[nCount] = trunkCable;
    nCount ++;

    for(i=0; i<nEndCabs; i++)
    {
      cables[nCount] = endCabList[i];
      nCount ++;
    }
  }
  else
  {
      nCount = nBegCabs + 1 + nEndCabs;
  }

  __DBGpr_int(" nCount ", nCount);
  if( nCables ) // Crashing in debug mode!
      __DBGpr_int(" *nCables ", *nCables);

  if(begTerm) *begTerm = begTerminal;
  if(endTerm) *endTerm = endTerminal;

  if(begTermPin) *begTermPin = bTermPin;
  if(endTermPin) *endTermPin = eTermPin;

  // return the VCLdInfo structure
  if(leadInfo)
  {
    IGRshort nCnum;  
    VC_ConNum_LeadName( &msg, &trunkCable, leadName, &nCnum );
    leadInfo->ConNum = nCnum;
    strcpy(leadInfo->LeadNam, leadName);

    VC_INITSTR(leadInfo->Marker);
    sts =  VCGetAttrInfoForLead( &trunkCable, leadInfo, 1,
		   VC_MARKER_TYPE, &legacy);
    if(!(sts&1))
    {
      __DBGpr_obj("Marker : VCGetAttrInfoForLead failed for", trunkCable);
      __DBGpr_str(" Lead Name ", leadName);
      goto wrapup;
    }
    leadInfo->TermId[0]  = begTerminal;
    leadInfo->TermId[1]  = endTerminal;
    leadInfo->FibEnds[0] = bTermPin;
    leadInfo->FibEnds[1] = eTermPin;

    leadInfo->TrunkCabId = trunkCable;
    leadInfo->NbCab      = nCount;

    if(leadInfo->NbCab)
    {
      leadInfo->CabId = _MALLOC(leadInfo->NbCab, struct GRid);
      nCount = 0;
      // need to fill the list in the reverse order
      for(i=(nBegCabs-1); i>=0; i--)
      {
        leadInfo->CabId[nCount] = begCabList[i];
        nCount ++;
      }
      leadInfo->CabId[nCount] = trunkCable;
      nCount ++;

      for(i=0; i<nEndCabs; i++)
      {
        leadInfo->CabId[nCount] = endCabList[i];
        nCount ++;
      }
    }

  }
  //Done
  *mesg = MSSUCC;
  retFlag = 1;

wrapup:
  _FREE(begCables);
  _FREE(endCables);
  _FREE(begCabList);
  _FREE(endCabList);

  return retFlag;
}

/*
 * Given a terminal, this routine gets the correspoding terminals
 * for common leads on the other side of the network; 
 * any cable in the network is also the input, which signifies the 
 * network(trunk) we should be looking into for the terminal connections
 */

IGRlong VCGetMatchLeadTerminals( struct GRid *termID,
				 struct GRid *cabID ,
				 IGRint      *nTerm ,
				 struct GRid *termList
			       )
{
    IGRlong              sts, msg, retFlag = 0;
    IGRint               status = OM_S_SUCCESS;
    IGRint               i, j, k, ii, jj, thisCount = 0;
    IGRshort             nCables = 0, nTotLeads = 0, *conCount = NULL;
    struct GRid          trunkCable, *allCables = NULL;
    struct VCcab_connect **conList = NULL, *allLeads = NULL;
    struct GRid          *theseCables = NULL, networkTrunk;
    IGRshort             *nCps = NULL, *theseCps = NULL;
    struct GRid          *otherTerms = NULL, begTerm, endTerm;

    if((!termID) || (!cabID) || (!nTerm))goto wrapup;

    *nTerm = 0;

    trunkCable.objid   = NULL_OBJID;
    trunkCable.osnum   = 2;
    networkTrunk.objid = NULL_OBJID;
    networkTrunk.osnum = 2;

    // get the main cable in the network
    sts = VC$GetTrunkCab( msg              = &msg,
			  p_gridCabId      = cabID,
			  p_gridTrunkCabId = &trunkCable
			);
    if(!(sts&msg&1) || (trunkCable.objid == NULL_OBJID))
    {
      __DBGpr_obj("TRUNK CABLE ", trunkCable);
      __DBGpr_obj("VC$GetTrunkCab FAILED ", *cabID);
      goto wrapup;
    }

    __DBGpr_obj("TERMINAL  ", *termID);
    __DBGpr_obj("TRUNK CABLE", trunkCable);
    // get the total no. of cables connected to the terminal
    status =
    om$send (msg = message VCRoot.VCGetTopology
                                     (&msg, VC_REQ_ALL_CPT, &nCables,
                                       NULL, NULL, NULL, NULL),
        senderid = NULL_OBJID,
        targetid = termID->objid,
        targetos = termID->osnum);    
    if(!(status&msg&1))
    {
      __DBGpr_obj("VCRoot.VCGetTopology failed for term ", *termID);
      goto wrapup;
    }

    __DBGpr_int("nCables ", nCables);
    if(nCables == 0)
    {
      *nTerm = 0;
      retFlag = 1;
      goto wrapup;
    }

    /* all and items corresponding to this (trunk cable)
     * network
     */
    allCables    = _MALLOC(nCables, struct GRid);
    theseCables  = _MALLOC(nCables, struct GRid);
    nCps         = _MALLOC(nCables, IGRshort   );
    theseCps     = _MALLOC(nCables, IGRshort   );

    status =
    om$send (msg = message VCRoot.VCGetTopology
                                     (&msg, VC_REQ_ALL_CPT, &nCables,
                                       allCables, nCps, NULL, NULL),
        senderid = NULL_OBJID,
        targetid = termID->objid,
        targetos = termID->osnum);
    if(!(status&msg&1))
    {
      __DBGpr_obj("VCRoot.VCGetTopology failed for term ", *termID);
      goto wrapup;
    }
    __DBGpr_objlist("Terminal Cables",nCables,allCables);

    /* 
     * gather the terminal cables which belong to this network
     * identified by trunkCable
     */
    for(i=0; i<nCables; i++)
    {
      sts = VC$GetTrunkCab( msg              = &msg,
			    p_gridCabId      = &allCables[i],
			    p_gridTrunkCabId = &networkTrunk
			  );
      if(!(sts&msg&1) || (networkTrunk.objid == NULL_OBJID))
      {
        __DBGpr_obj("TRUNK CABLE ", networkTrunk);
        __DBGpr_obj("VC$GetTrunkCab FAILED ", allCables[i]);
        goto wrapup;
      }

      if((networkTrunk.objid == trunkCable.objid) &&
         (networkTrunk.osnum == trunkCable.osnum)) 
      {
        theseCables[thisCount] = allCables[i];
	theseCps   [thisCount] = nCps[i];
	thisCount ++;
      }
    }
    if(thisCount == 0)
    {
      *nTerm = 0;
      goto wrapup;
    }
    __DBGpr_objlist("Terminal Cables",thisCount,theseCables);
    /*
     * get the leads of theseCables which are connected to the terminal
     * get the terminals for these leads on the other side of the network
     */ 

    // allocate for the list of connected cables' count
    // no. of leads in each connected cable to the terminal
    conCount = _MALLOC(thisCount, IGRshort);
    conList  = _MALLOC(thisCount, struct VCcab_connect *);

    for(i=0; i<thisCount; i++) 
    {
      conCount[i] = 0;
      conList [i] = NULL;
    }

    for(i=0; i<thisCount; i++)
    {
      sts = VCGetCabConnTerm( &msg, theseCables[i], theseCps[i], &conCount[i], NULL, NULL, 1);
      if(!(sts&msg&1))
      {
        __DBGpr_obj(" VCGetCabConnTerm failed for", theseCables[i]);
        goto wrapup;
      }
      if(conCount[i] == 0) continue;

      conList[i] = _MALLOC(conCount[i], struct VCcab_connect);

      conCount[i] = 0;
      sts = VCGetCabConnTerm( &msg, theseCables[i], theseCps[i], &conCount[i], conList[i], NULL, 1);
      if(!(sts&msg&1))
      {
        __DBGpr_obj(" VCGetCabConnTerm failed for", theseCables[i]);
        goto wrapup;
      }
      nTotLeads += conCount[i];
    }

    __DBGpr_int(" Total No. of leads connected to terminal ", nTotLeads);
    if(nTotLeads == 0) 
    {
	retFlag = 1;
	goto wrapup;
    }

    // collect all the leads into an array
    allLeads = _MALLOC(nTotLeads, struct VCcab_connect);

    nTotLeads = 0;
    for(i=0; i<thisCount; i++)
    {
      for(j=0; j<conCount[i]; j++)
      {
        allLeads[nTotLeads] = conList[i][j];
        __DBGpr_str(" Lead Name in terminal ", allLeads[nTotLeads].LeadNam);
	nTotLeads ++;
      }
    }
    __DBGpr_int(" Total No. of leads connected to terminal ", nTotLeads);
    otherTerms = _MALLOC(nTotLeads, struct GRid);
    for(i=0; i<nTotLeads; i++) 
    {
      otherTerms[i].objid = NULL_OBJID;
      otherTerms[i].osnum = 2;
    }
    jj = 0;
    for(i=0; i<nTotLeads; i++)
    {
      begTerm.objid = endTerm.objid = NULL_OBJID;
      begTerm.osnum = endTerm.osnum = 2;

      sts = VC$GetNetworkForLead( 
			        msg            = &msg,
			        szLeadName     = allLeads[i].LeadNam,
			        p_gridCabId    = &trunkCable,
			        p_gridBegTerm  = &begTerm,
			        p_gridEndTerm  = &endTerm
                              );
      if(!(sts&msg&1))
      {
        __DBGpr_obj(" VC$GetNetworkForLead failed for", trunkCable);
        __DBGpr_str(" Lead Name ", allLeads[i].LeadNam);
        goto wrapup;
      }
      __DBGpr_obj("Input Terminal ", *termID);
      __DBGpr_str("Lead Name ", allLeads[i].LeadNam);
      __DBGpr_obj(" Begin Term    ", begTerm);
      __DBGpr_obj(" End   Term    ", endTerm);

      if((begTerm.objid == termID->objid) &&
         (begTerm.osnum == termID->osnum))
      {
        if(endTerm.objid != NULL_OBJID)
	{
	  otherTerms[jj] = endTerm;
	  jj ++;
	}
      } 
      if((endTerm.objid == termID->objid) &&
         (endTerm.osnum == termID->osnum))
      {
        if(begTerm.objid != NULL_OBJID)
	{
	  otherTerms[jj] = begTerm;
	  jj ++;
	}
      } 
    }
    // the above list of otherTerms can have duplicates; filter it
    ii = 0;
    for(ii=0; ii<jj; ii++)
    {
	for(k=ii+1; k<jj; k++)
	{
	    if((otherTerms[k].objid == otherTerms[ii].objid) &&
               (otherTerms[k].osnum == otherTerms[ii].osnum))
	    {
		otherTerms[k].objid = NULL_OBJID;
	    }
	}
    }
    ii = 0;
    for(i=0; i<jj; i++)
    {
	if(otherTerms[i].objid != NULL_OBJID)  ii++;
    }

    *nTerm = ii;

    __DBGpr_int(" No. of other side terminals ", ii);

    ii = 0;
    if(termList)
    {
        for(i=0; i<(*nTerm); i++)
        {
          termList[i].objid = NULL_OBJID;
          termList[i].osnum = 2;
        }
	for(i=0; i<jj; i++)
	{
          if(otherTerms[i].objid != NULL_OBJID)
	  {
	    termList[ii]  = otherTerms[i];
	    ii ++; 
	  }
	}
    }
    __DBGpr_int(" nTerm ", *nTerm);
    __DBGpr_int(" ii ", ii);
    __DBGpr_objlist("Other Side Terminals ",ii,termList);

    //Done
    retFlag = 1;
wrapup:
    if(thisCount > 0)
    {
      for(i=0; i<thisCount; i++) _FREE(conList[i]);
      _FREE(conList);
    }
    _FREE(allCables);
    _FREE(nCps);
    _FREE(theseCables);
    _FREE(theseCps);
    _FREE(conCount);
    _FREE(allLeads);
    _FREE(otherTerms);

    return retFlag;
}

end implementation VCCable;

