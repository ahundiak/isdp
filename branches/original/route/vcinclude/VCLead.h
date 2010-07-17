/* $Id: VCLead.h,v 1.1 2002/05/08 15:48:24 anand Exp $ */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:	vcinclude/VCLead.h
 *
 * Description:
 *
 *     Include file to define service routine macros for Sub Cables.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCLead.h,v $
 *	Revision 1.1  2002/05/08 15:48:24  anand
 *	Files added/modified for sub-cable functionality.
 *	
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	1 Mar 2002	Anand		Creation
 *
 * -------------------------------------------------------------------*/

#ifndef  VCLead_h

#define  VCLead_h

#include "vc_define.h"
#include "VCdefine.h"
#include "VCproto.h"

 /* me->DataType value on cable objects in files created before June 2002. */
#define VC_LEGACY_JUN02	0

 /* me->DataType value that signifies that the me->Data VLA in the cable object
  * is of type struct ACrg_coll */
#define VC_ACRG_COLLECT	1

#define VC_ALL_TYPES	0xffff
#define VC_MARKER_TYPE	0x0001
#define VC_SIGNAL_TYPE	0x0002

struct VCLdInfo
{
    /* Below three fields store info from vct_ecmap or vct_fcmap DB tables */
    IGRshort	ConNum;	/* con_num field in vct_[ef]cmap DB table */
    IGRchar	LeadNam[VC_MAX_LEAD_ID];
    IGRchar	SigNam[VC_MAX_SIG_ID];

    /* Store status of lead ends */
    IGRshort	nEndStat[2];
    IGRshort	nFibStat;

    struct GRid		TermId[2];
    struct VCTpos	FibEnds[2];

    IGRchar	szTagNo[VC_MAX_TAGNO];

    struct GRid		TrunkCabId;
    IGRint		NbCab;
    struct GRid		*CabId;

    IGRchar	Marker[VC_MAX_MARK_ID];

    IGRchar	Future1[VC_MAX_FUT1_ID];
    IGRchar	Future2[VC_MAX_FUT2_ID];
    IGRchar	Future3[VC_MAX_FUT3_ID];
    IGRchar	Future4[VC_MAX_FUT4_ID];
};

/* new structure for "C Configure Cable Leads" command */

struct VCConfigLead
{
  struct VCLdInfo ldInfo;
  IGRint          used;
};

/****************************************************************************/
/*			       M A C R O S				    */
/****************************************************************************/

/* Given a cable's object id (gridMainCabId), return all its subcables
 * (p_intNbSubCab returns the number of subcables, and p_gridSubCabId returns
 * the list of object ids.
 *
 * Caller first calls VC$GetAllSubCab with p_gridSubCabId as NULL, allocs for
 * this pointer based on what is returned in p_intNbSubCab, and calls
 * VC$GetAllSubCab with this pointer the second time.
 */

#omdef	VC$GetALLSubCab ( msg,
			  p_gridMainCabId,
			  p_intNbSubCab   = NULL,
			  p_gridSubCabId  = NULL,
			  p_intNbEndCab   = NULL,
			  p_gridEndCabId  = NULL)
#  if (om$equal (p_gridMainCabId, NULL))
#    omerror "p_gridMainCabId is a reqd argument"
#  elif (om$equal (p_intNbSubCab, NULL) && (om$equal (p_intNbEndCab, NULL)))
#    omerror "VC$GetAllSubCab: BAD ARGUMENT CHOICE"
#  else
 VCGetAllSubCab( (msg), (p_gridMainCabId), (p_intNbSubCab),
		 (p_gridSubCabId), (p_intNbEndCab), (p_gridEndCabId))
#  endif
#endomdef

/* In an arbitrary "network" of cable and subcables, given the object-id of any
 * Cable or Sub-cable (p_gridCabId), return the object id (p_gridTrunkCabId) of
 * the "Trunk Cable" (i.e., the cable which is not a sub-cable of any other
 * Cable, the master cable).
 */

#omdef VC$GetTrunkCab( msg,
		       p_gridCabId,
		       p_gridTrunkCabId )
#   if om$equal( p_gridCabId, NULL )
#	omerror "Invalid input to VC$GetTrunkCab"
#   else
VCGetTrunkCable((msg), (p_gridCabId), (p_gridTrunkCabId))
#   endif
#endomdef

/*
 * In an arbitrary network of cables and sub-cables, this macro will give us a
 * list of all the cables (p_gridCabList, p_nNbCab), list of all the beginining
 * terminals (p_gridBegTermId, p_nBegTerm) and ending terminals
 * (p_gridEndTermId, p_nEndTerm).
 *
 * The inputs can be any one of the following - 
 *
 *   1. Object id of any one of the cables in the network (p_gridCabId)
 *   2. Information of all the leads in the network  (p_LeadInfo, p_NbLeads)
 *
 */

#omdef VC$GetNetworkForCable( msg,
			      p_gridCabId      = NULL,
			      p_NbLeads        = NULL,
			      p_LeadInfo       = NULL,
			      p_nNbCab	       = NULL,
			      p_gridCabList    = NULL,
			      p_nBegSubCab     = NULL,
			      p_gridBegSubCab  = NULL,
			      p_nEndSubCab     = NULL,
			      p_gridEndSubCab  = NULL,
			      p_nBegLeafCab    = NULL,
			      p_gridBegLeafCab = NULL,
			      p_nEndLeafCab    = NULL,
			      p_gridEndLeafCab = NULL,
			      p_nBegTerm       = NULL,
			      p_gridBegTermId  = NULL,
			      p_nEndTerm       = NULL,
			      p_gridEndTermId  = NULL )

#   if (om$equal( p_gridCabId, NULL ) && (om$equal(p_LeadInfo, NULL)))
#	omerror "Invalid input to VC$GetNetworkForCable"
#   endif
VCGetCableNetwork((msg), (p_gridCabId), (p_LeadInfo), (p_NbLeads),
		  (p_gridCabList), (p_nNbCab), (p_gridBegSubCab),
		  (p_nBegSubCab), (p_gridEndSubCab), (p_nEndSubCab),
		  (p_gridBegLeafCab), (p_nBegLeafCab), (p_gridEndLeafCab), 
		  (p_nEndLeafCab), (p_gridBegTermId), (p_nBegTerm), 
		  (p_gridEndTermId), (p_nEndTerm))
#endomdef

/*
 * In an arbitrary network of cables and sub-cables, this macro will give us a
 * information about the lead given the leadName (szLeadName or nConNum) and
 * the object id of any cable in the network (p_gridCabId)    
 *
 * The lead information can be made available in any form i.e., either through
 * p_LeadInfo structure or as individual pieces (p_gridCabList, etc.)
 *
 */

#omdef VC$GetNetworkForLead( msg,
			     szLeadName ,
			     p_gridCabId, 
			     p_nNbCab      = NULL,
			     p_gridCabList = NULL,
			     p_gridBegTerm = NULL,
			     p_gridEndTerm = NULL,
			     p_vctposBegTermPin = NULL,
			     p_vctposEndTermPin = NULL,
			     p_LeadInfo = NULL )

VCGetLeadNetwork((msg), (szLeadName), (p_gridCabId), (p_nNbCab),
		 (p_gridCabList), (p_gridBegTerm), (p_gridEndTerm),
		 (p_vctposBegTermPin), (p_vctposEndTermPin),
		 (p_LeadInfo))
#endomdef

/*
 * In an arbitrary network of cables and sub-cables, this macro will give us 
 * the common leads (p_LeadInfo, p_NbLeads) running from a begining terminal(s)
 * (p_gridBegTerm, p_nBegTerms) to ending terminals (p_gridEndTerm,
 * p_nEndTerms) or vice-versa. 
 *
 * The lead info of all the leads in the network for the selected cable
 * (p_NetworkLdInfo, nTotNumLeads) will be supplied to this macro
 *
 */
#omdef VC$GetLeadsGivenTerm( msg,
			     nTotNumLeads,
			     p_NetworkLdInfo,
			     p_nBegTerms,
			     p_gridBegTerm = NULL,
			     p_nEndTerms,
			     p_gridEndTerm = NULL,
			     p_NbLeads,
			     p_LeadInfo )

#endomdef

/*
 * For a given lead (szLeadName or nConNum) and object id of any cable in the
 * network (p_gridCabId), we initialize the supplied lead information on all
 * the cable objects that carry this lead.
 *
 */
#omdef VC$InitAttrForLead( msg,
			   szLeadName ^ nConNum,
			   szSignal = "",
			   szMarker = "",
			   NbAttr = 0,
			   p_Attr = NULL,
			   p_gridCabId )

#endomdef

/*
 * For a given lead (szLeadName or nConNum) and object id of any cable in the
 * network (p_gridCabId), we set the supplied lead information on all
 * the cable objects that carry this lead.
 *
 */

#omdef VC$SetAttrForLead( msg,
			  szLeadName ^ nConNum,
			  szSignal = NULL,
			  szMarker = NULL,
			  NbAttr = 0,
			  p_Attr = NULL,
			  p_gridCabId )

#endomdef


/* Macro for fetching Lead Name given con_num */

/* Macro for fetching con_num given Lead Name */

/* Macro for fetching Marker attribute on a specific lead. */

/* Macro for fetching a Named attribute on a specific lead. */

/* Macro for finding available leads on Parent cable */

/* Macro for finding leads "used up" by a (sub-)cable. */

/* Macro for returning the number of leads in a cable */

/* Macro for setting the Lead information in a cable! (Sets both VCcab_connect
 * vla and the Data vla) */

      /*****************************************************************\
      *		 WRAPPER MACRO FOR method VCGetInfoSubCab		*
      *									*
      * Caller to (optionally) alloc for -				*
      *	1. p_gridCabId							*
      *	2. arr_nBegCabLd						*
      * (based on earlier call that returns p_nBegCab),			*
      *									*
      * AND/OR								*
      *	3. p_gridCabId							*
      *	2. arr_nEndCabLd						*
      * (based on earlier call that returns p_nEndCab),			*
      *									*
      * The VCcab_connect structures viz., p_BegLead, p_EndLead,	*
      * p_BegAvlblLds and p_EndAvlblLds may be conservatively allocated *
      * for the number of leads in main cable (each). This routine will	*
      * realloc and return them.					*
      *									*
      * Notes:								*
      *									*
      * 1. arr2_BegCabLd and arr2_EndCabLd are arrays. The number of	*
      *    elements in these arrays are the number of Cables (beginning	*
      *    and end respectively). The i-th element in each array would	*
      *    store the number of leads in the i-th cable.			*
      *									*
      * 2. Although possible, there would be little meaning in getting	*
      *    p_BegLead and p_EndLead without ALSO getting arr_nBegCabLd	*
      *    AND ARR_NEndCabLd.						*
      *									*
      * 3. All files that intend calling this routine from a .I file    *
      *    that is NOT implementing VCCable, MUST add the following     *
      *    line in their file. ( Sorry! :( )                            *
      *									*
from VCCable import VCGetInfoSubCab;
      *									*
      *									*
      \*****************************************************************/

#omdef VC$SubCabLeadInfo( p_msg,
			  gridInputCab,
			  arr2_SectMap	= NULL,
			  arr6_dEndCoord	= NULL,
			  p_nBegCab	= NULL,
			  p_gridBegCab	= NULL,
			  arr_nBegCabLd	= NULL,
			  p_BegLead	= NULL,
			  p_nEndCab	= NULL,
			  p_gridEndCab	= NULL,
			  arr_nEndCabLd	= NULL,
			  p_EndLead	= NULL,
			  p_nBegAvlblLeads	= NULL,
			  p_BegAvlblLds	= NULL,
			  p_nEndAvlblLeads	= NULL,
			  p_EndAvlblLds	= NULL,
			  md_env = NULL )

#  if ( !om$equal(p_gridBegCab,NULL) || !om$equal(arr_nBegCabLd,NULL) ) && om$equal(p_nBegCab,NULL)
#    omerror "Need to provide a valid address of an int to p_nBegCab"
#  elif ( !om$equal(p_gridEndCab,NULL) || !om$equal(arr_nEndCabLd,NULL) ) && om$equal(p_nEndCab,NULL)
#    omerror "Need to provide a valid address of an int to p_nEndCab"
#  elif ( !om$equal(p_BegAvlblLds,NULL) && om$equal(p_nBegAvlblLeads,NULL) )
#    omerror "Need to provide a valid address of an int to p_nBegAvlblLeads"
#  elif ( !om$equal(p_EndAvlblLds,NULL) && om$equal(p_nEndAvlblLeads,NULL) )
#    omerror "Need to provide a valid address of an int to p_nEndAvlblLeads"
#  elif ( !om$equal(arr6_dEndCoord,NULL) && om$equal(md_env,NULL) )
#    omerror "Need to provide valid md_env for fetching Cable's Coordinates"
#  else

om$send( msg = message VCCable.VCGetInfoSubCab( (p_msg),
						(arr2_SectMap),
						(arr6_dEndCoord),
						(p_nBegCab), (p_gridBegCab),
						(arr_nBegCabLd), (p_BegLead), 
						(p_nEndCab), (p_gridEndCab),
						(arr_nEndCabLd), (p_EndLead),
						(p_nBegAvlblLeads),
						(p_BegAvlblLds),
						(p_nEndAvlblLeads),
						(p_EndAvlblLds),
						(md_env) ),
	 targetid = gridInputCab.objid,
	 targetos = gridInputCab.osnum,
	 senderid = NULL_OBJID )

#  endif
#endomdef
/* Macro for returning the tagnumber to be set on a new sub-cable */

/* Macro that returns a struct VCLdInfo, given a struct VCcab_connect and
 * attribute information. */

#endif /* close ifndef	VCLead_h */

