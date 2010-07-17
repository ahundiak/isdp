/* $Id: VRGeneric.S,v 1.2 2002/05/03 13:51:42 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrgeneric / VRGeneric.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRGeneric.S,v $
 *	Revision 1.2  2002/05/03 13:51:42  louis
 *	TR5959 pload cleanup for symbolization
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:52  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/03/17  14:28:26  pinnacle
# Replaced: vrgeneric/VRGeneric.S for:  by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *      05/02/02   law          tr5959 pload cleanup
 *
 *************************************************************************/
/*---------------------------------------------------------------------------
/*
/*  VRGeneric.S
/*  Oct-22-90
/*
/*  Modification : 
/*
/*
/*		CLASS  NAME:	VRGeneric
/*
/*		SUBCLASS OF:	VDSroot
/*
/*		NOTES:
/*
/*
/*	The abstract class VRGeneric has been implemented for the NAVSEA
/*	routing application.
/*
/*	It manages the information gathering and the cache (graphics
/*	and component's specific attributes) accesses.
/*
/*	The cache selection must be determined by subclasses.
/*
/*	The basic information needed to manage a component are
/*
/*		- a set of network topology information contained in
/*		  objects ( first n templates )
/*		- a set of Active parameters contained in 
/*		  an AScollection object ( template n+1 )
/*		- and optionally a user's defined collection of
/*		  parameters only used for reports ( templates n+2
/*		  and higher )
/*		- a status specifying ERROR component, systems defined
/*		  components or user defined components.
/*		- a component's code ( 7 characters stored in the 
/*		  instances ).
/*
/*	* 6-Jun-95
/*		Manyam
/*		- Override VDgetParameters
/*
/*	* 18-Jan-95
/*		Mallik
/*		- Cancelled Override NDdrawing_copy_geom.
/*
/*	* 21-Dec-94
/*		
/*		Manyam
/*		- Override NDdrawing_copy_geom for OPE support
/*
/*      * 21-NOV-94     2.4.
/*
/*              Lori
/*              - Added messages VRVerifyTopology, VRVerifyChildren,
/*                VRVerifyModel, VRVerifyAttributes, VRVerifyConnect
/*                for validation 
/*
/*      * 10-AUG-94     2.3.1.9
/*
/*              Henk
/*              - Moved connectivity message declarations to new
/*                subclass VRConMgt for clarity
/*
/*      * 08-JUL-94     2.3.
/*
/*              Henk
/*              - Added messages VRGetOffCoord, VRSetOffCoord for
/*                management of offsets of individual cables from
/*                conduits and other collective components
/*
/*      * 07-JAN-94     2.2.1.32
/*
/*              Henk
/*              - Implemented VRCon.... messages for per lead/fiber
/*                connection management. These messages are rejected
/*                here and must be overridden at the actual object
/*                level (connectors and cables)
/*
/*	* 05-Nov-93	2.2.1.12
/*
/*		Manyam
/*		- Defined method VRGetCatBehavior
/*
/*	* 09-Oct-93	2.2.1.12
/*
/*		Bruno
/*		- Hardcode size 7 characters for szAABBCC since
/*		  the VR_CODE_LENGTH define has been changed from
/*		  7 to 13 in release 2.2.1.10.
/*
/*	* 14-Sep-92	2.1.0.2
/*
/*		Bruno
/*		- Override NDupdate method for compute optimization
/*		  purposes.
/*		- Add the VRNotifyCorrections method.
/*
/*	* 21-Jan-92	1.4.3.19	
/*
/*		Bruno
/*		- VRDisconnect method shifted from VRnozzle to here.
/*
/*	* 09-DEC-91	1.4.3.14	
/*
/*		Bruno
/*		- VRInitInstances method has been removed.
/*
/*	* 18-Nov-91	1.4.3.9	
/*
/*		Bruno
/*		- VRConnect method shifted from VRnozzle and VRConcComp
/*		  to here.
/*
/*---------------------------------------------------------------------------
/* */

class specification VRGeneric (0:1) of VDSroot;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "VRcompstr.h"
#include "VRstructs.h"
#include "AS_status.h"
#include "vdprocinfo.h"


  instance VRGeneric
  {

		/* component status */
		/* ( the possible values are defined in VRdef.h ) */

	IGRshort		Status;

	/* ------------------------------ */
	/* -- Component identification -- */
	/* ------------------------------ */

		/* component aabbcc code */

	IGRchar			szAABBCC[7];

		/* component option */

	IGRshort		nOption;

	/* ------------------------------------- */
	/* -- Component individual attributes -- */
	/* ------------------------------------- */

		/* component number */

	IGRchar			szNumber[13];

		/* component notes */

	IGRchar			szNotes[30];

		/* No MTO flag */

	IGRchar			cNoMtoFlg;

	/* ------------------------------------ */
	/* -- Component object environnement -- */
	/* ------------------------------------ */

		/* number of templates ( topology ) */

	IGRshort		nNbTopo;

		/* number of templates ( attributes ) */

	IGRshort		nNbAttr;

		/* placement connect point number */

	IGRshort		nJustif;

	/* ------------------------------ */
	/* -- Component geometric info -- */
	/* ------------------------------ */

		/* number of connection points */

	IGRshort			nNbCpts;
	IGRdouble			dOrigCoord [3];
  };



/*--------------------------------------------------------------------------*/
override 
	GRgetobjinfo,		/* to display Component's info when identified */
	GRxform,		/* Component can move if it is not attached to
				   a network */
	GRcopy,
	NDplace,
	NDdelete,
	NDget_objects,		/* return NO dependant object when in dynamics */
	NDupdate,		/* check which template has been recomputed and
				   tells the correction which type of compute is
				   needed */
	ACgive_structure,	/* must seek for attributes in the templates */
	ACgive_db_structure,	/* return the static attributes */
	ACconstruct_feet,	/* construct Component's representation */
        ACchange_feet,          /* insert symbology-tr5959              */
	NDcopy,
	ACreturn_foot,		/* to return feet belonging to collections
				   templates */
	GRget_siblings,		/* to return neighbors to the interference
				   checking */
	VDSmodUsrAttributes,    /* to modify user attributes            */
	VDSgetUsrAttributes,    /* to get user attributes               */
	VDSgetCompDesc,		/* to return Component's attributes	*/
	VDGetModel,
	VDgetParameters,	/* returns the list of all parameters
				for the object				*/

	VDGetParamsId;		/* This one is in VDS so that we can manipulate 
				   VREquipment from there */

		/* ---------------------------------------- */
		/* -- OCCURRENCE INITIALIZATION messages -- */
		/* ---------------------------------------- */




message VREvaluate (	IGRlong			*msg;
			struct VRGenInfo	*Instance;
			struct GRid 		*SysParamId;
			struct GRid 		*UserParamId;
			struct GRid 		*MissParamId;
			IGRint			*NumMaxTopo;
			IGRint			*TopoType;
			IGRint			*NbMissing;
			IGRchar			***MissingNames;
			struct ret_struct	**MissingStr;
			struct GRid		*Graphics;
			struct GRmd_env		*md_env );
/*---------------------------------------------------------------------------
/* VREvaluate
/*
/*      Performs an invisible placement of an occurence out of any
/*	topology. This occurrence can then be asked for any none
/*	topological description.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct VRGenInfo	*Instance	I : Specific instances structure
/*
/* struct GRid		*SysParamId	I : Active parameters
/*
/* struct GRid		*UserParamId	I : User parameters
/*
/* struct GRid		*MissParamId	I : Optional : Missing parameters
/*
/* IGRint		*NumMaxTopo	O : Max number of topology templates needed
/* 					    for placement.
/* IGRint		*TopoType	O : Not used. Will describe the type of
/*					    topological templates needed.
/* IGRint		*NbMissing	O : Number of missing templates.
/*
/* IGRchar		***MissingNames	O : address of a pointer on a string array.
/*					    (returns the address of a static buffer).
/* struct ret_struct	**MissingStr	O : address of a pointer on an array of
/*					    return structure.(returns the address
/*					    of a static buffer).
/* struct GRid		*Graphics	O : Returns the graphic symbol's Id. IT IS
/*					    UP TO THE USER TO DELETE IT.
/*
/* struct GRmd_env	*md_env		I : module env.
/* 
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

		/* ----------------------------------- */
		/* -- OCCURRENCE BEHAVIOUR messages -- */
		/* ----------------------------------- */

		/* -- Information -- */

message VRGetStatus (IGRlong *msg; IGRshort *StatusValue);
/*---------------------------------------------------------------------------
/* VRGetStatus
/*
/*      Returns the component's status
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		*StatusValue	O : status value(s) defined in VRdef.h
/*
/*---------------------------------------------------------------------------
/* */
		/* -- Modification -- */

message VRSetStatus (IGRlong *msg; IGRshort StatusMask; IGRshort StatusValue);
/*---------------------------------------------------------------------------
/* VRSetStatus
/*
/*      Sets the status in the component instance
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		StatusMask	I : status mask defined in VRdef.h
/*
/* IGRshort		StatusValue	I : status value(s) defined in VRdef.h
/*
/*---------------------------------------------------------------------------
/* */

message VRGetInstance (IGRlong *msg; struct VRGenInfo *Instance);
/*---------------------------------------------------------------------------
/* VRGetInstance
/*
/*      Returns the VRGeneric level and subclasses instances.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct VRGenInfo	*Instance	O : specific instances structure
/*
/* NOTE : PRIVATE AND DANGEROUS MESSAGE !!!
/*	Must be overriden in the subclass depending on the
/*	component type.
/*
/*---------------------------------------------------------------------------
/* */

message VRSetInstance (IGRlong *msg; struct VRGenInfo *Instance);
/*---------------------------------------------------------------------------
/* VRSetInstance
/*
/*      Sets the VRGeneric and subclasses instances.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct VRGenInfo	*Instance	I : specific instances structure
/*
/* NOTE : PRIVATE AND DANGEROUS MESSAGE !!!
/*	Must be overriden in the subclass depending on the
/*	component type.
/*
/*---------------------------------------------------------------------------
/* */
		/* --------------------------------------------- */
		/* -- COMPONENT SELECTION ATTRIBUTES messages -- */
		/* --------------------------------------------- */

		/* -- Info -- */

message VRGetSysType( IGRlong *msg;  IGRshort *nSysType );
/*---------------------------------------------------------------------------
/* VRGetSysType
/*
/*      Returns the component's item number if it has been
/*	placed by item number rather than by AABBCC code.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		*nSysType	I : Pointer to item number
/*					    (values defined in VRcompdef.h)
/*
/*
/* NOTE : Must be overriden by subclasses.
/*
/*---------------------------------------------------------------------------
/* */

message VRGetCode( IGRlong *msg;  IGRchar *szAABBCC );
/*---------------------------------------------------------------------------
/* VRGetCode
/*
/*      Returns the component's aabbcc code.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRchar		*szAABBCC	I : Pointer AABBCC code string
/*					    ( szAABBCC [7] )
/*
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */


		/* -- Modification -- */

message VRSetCode( IGRlong *msg;  IGRchar *szAABBCC );
/*---------------------------------------------------------------------------
/* VRSetCode
/*
/*      Sets the component's aabbcc code.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRchar		*szAABBCC	I : Pointer AABBCC code string
/*					    ( szAABBCC [7] )
/*
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRResetCode (IGRlong *msg);
/*---------------------------------------------------------------------------
/* VRResetCode
/*
/*      Forces the component's aabbcc code to induce re-evaluation.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/*---------------------------------------------------------------------------
/* */


		/* -------------------------------------------- */
		/* -- COMPONENT SELECTED ATTRIBUTES messages -- */
		/* -------------------------------------------- */

		/* -- Info -- */

message VRGetNumberOfCpts (IGRlong *msg ;IGRint *NbCpts; struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/* VRGetNumberOfCpts
/*
/*      Returns the number of connect points.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		NbCpts		O : Number of connect points.
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE : Is used to malloc arrays before getting component's geometry.
/*---------------------------------------------------------------------------
/* */

message VRGetCptProp ( 	IGRlong *msg ;IGRshort nCpNum;
			struct VRcp_attr *ConProp; struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetCptProp
/*
/*      Returns the connection properties at the specified
/*	connect point
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Connect point number.
/*
/* struct VRcp_attr	*ConProp	O : pointer on connection properties
/*					    structure.
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRGetCompDesc ( IGRlong *msg; struct ACrg_coll *Param ; struct GRmd_env *md_env );
/*---------------------------------------------------------------------------
/* VRGetCompDesc
/*
/*      Returns the named parameter from the component database attributes.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O   : MSSUC if success and MSFAIL if not.
/*
/* struct ACrg_coll	*Param		I/O : pointer on parameter structure.
/*					      The name field is used as input
/*					      and the desc field as output.
/*
/* struct GRmd_env	*md_env		I   : pointer on module env
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

		/* ---------------------------------- */
		/* -- OCCURRENCE GEOMETRY messages -- */
		/* ---------------------------------- */

		/* -- Info -- */

message VRGetMatrix( IGRlong *msg; IGRint NbTemp; struct GRid *TempList;
		     IGRdouble dRefMatrix [] ; struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetMatrix
/*
/*      Computes and returns the component orientation matrix
/*	based on the topologic templates
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		TempNum		I : Number of templates (optional
/*					    if TempList is NULL )
/* struct GRid		*TempList	I : Pointer to list of templates
/*					    ( can be set to NULL )
/* IGRdouble		dRefMatrix[]	O : Orientation matrix
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*	Must be overriden in the subclass depending on the
/*	type of templates.
/*---------------------------------------------------------------------------
/* */

message VRGetOrigCoor ( IGRlong *msg ; IGRdouble *dOrigCoor; 
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetOrigCoor
/*
/*      Returns the coordinates of placement point.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRdouble		*dOrigCoor	O : XYZ coordinates
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRGetCptGeom ( 	IGRlong *msg ;IGRshort nCpNum;
			IGRdouble *dCptCoor; IGRdouble *dConAxis;
			IGRdouble *dOrientation; 
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetCptGeom
/*
/*      Returns the geometry of the specified
/*	connect point
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Connect point number.
/*
/* IGRdouble		*dCptCoor	O : XYZ coordinates 
/*
/* IGRdouble		*dConAxis	O : Connection axis vector
/*
/* IGRdouble		*dOrientation	O : Orientation vector of the surface
/*					    of connection.
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE : The three output can be specified as NULL.
/*---------------------------------------------------------------------------
/* */

message VRGetOrientationDef ( 	IGRlong *msg ; 	struct GRid *PrimaryId;
						IGRshort    *nPosOnPri;
						IGRdouble   *dPrimary;
						struct GRid *SecondaryId;
						IGRshort    *nPosOnSec;
						IGRdouble   *dSecondary);
/*---------------------------------------------------------------------------
/* VRGetOrientationDef
/*
/*      This message returns all information the target component is using
/*	to compute its orientation relatively to its Primary and secondary
/*	segments.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		*PrimaryId	O : Object Id of its primary segment.
/*
/* IGRshort		*nPosOnPri	O : its position on the primary segment
/*					    ( 0 : start point, 1 : end point ).
/* IGRdouble		*dPrimary	O : Orientation relatively to the segment
/*					    orientation.
/* struct GRid		*SecondaryId	O : Object Id of its secondary segment.
/*
/* IGRshort		*nPosOnSec	O : its position on the secondary segment
/*					    ( 0 : start point, 1 : end point ).
/* IGRdouble		*dSecondary	O : Orientation relatively to the segment
/*					    orientation.
/*
/*
/* NOTE : Any pointer can be specified as NULL if information is not needed.
/*
/*---------------------------------------------------------------------------
/* */

message VRGetFlow ( 	IGRlong *msg; IGRshort nCpNum;
			IGRshort *nFlowDir ;IGRdouble *dFlowRate;
                        struct 	GRmd_env	*md_env );

/*---------------------------------------------------------------------------
/* VRGetFlow
/*
/*      Returns the Flow description on the specified connect point.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Connect point number.
/*
/* IGRshort		*nFlowDir	O : Flow direction 
/*					   ( VR_FLOW_IN; VR_FLOW_OUT or VR_FLOW_UNKNOWN 
/*					     defined in VRcompdef.h ).
/* IGRdouble		*dFlowRate	O : Flow rate at connect point.
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE : Any output can be specified as NULL.
/*---------------------------------------------------------------------------
/* */

message VRSetFlow ( 	IGRlong *msg; IGRshort nCpNum;
			IGRshort *nFlowDir ;IGRdouble *dFlowRate;
                        struct 	GRmd_env	*md_env );

/*---------------------------------------------------------------------------
/* VRSetFlow
/*
/*      Stores the Flow description on the specified connect point.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Connect point number.
/*
/* IGRshort		*nFlowDir	I : Flow direction 
/*					   ( VR_FLOW_IN; VR_FLOW_OUT or VR_FLOW_UNKNOWN 
/*					     defined in VRcompdef.h ).
/* IGRdouble		*dFlowRate	I : Flow rate at connect point.
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE : Any Flow input can be specified as NULL.
/*---------------------------------------------------------------------------
/* */

message VRIsGeometricAttr ( IGRlong *msg; IGRint NbAttr; IGRchar *AttrNames[]; 
			    IGRboolean *bIsGeometric; struct GRmd_env *md_env );

/*---------------------------------------------------------------------------
/* VRIsGeometricAttr
/*
/*      Given a list of attribute names, this method indicates whether there
/*	is one driving the geometry. ( This is used by the Change Attributes
/*	command object to know, depending on the attributes modified, whether
/*	it has to recompute or not the object ).
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		NbAttr		I : Number of attribute names in the list.
/*
/* IGRchar		*AttrNames[]	I : List of attribute names.
/*
/* IGRboolean		*bIsGeometric	O : Returns TRUE if there is one attribute
/*					    driving the geometry.
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE : 
/*---------------------------------------------------------------------------
/* */

		/* ------------------------------- */
		/* -- GRAPH MANAGEMENT messages -- */
		/* ------------------------------- */

		/* -- Information -- */


message VRGetParams( IGRlong *msg; 	struct GRid *SysParamId;
					struct GRid *UserParamId;
					struct GRid *MissParamId );
/*---------------------------------------------------------------------------
/* VRGetParams
/*
/*      Returns the component's attributes.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		*SysParamId	O : Returns the system parameters
/*					    object's Grid .
/* struct GRid		*UserParamId	O : Returns the user parameters
/*					    object's Grid , if any.
/* struct GRid		*MissParamId	O : Returns the added parameters
/*					    object's Grid , if any.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRGetSupports (IGRlong *msg; IGRint ArraySize; 
			 struct GRid SupIds[]; IGRint *NbSupports);
/*---------------------------------------------------------------------------
/* VRGetSupports
/*
/*      Returns the list of network supports templates.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		*ArraySize	I : Size of the SupIds array.
/*
/* struct GRid		SupIds[]	O : Array of supports.
/*					    ( can be specified as NULL )
/* IGRint		*NbSupports	O : number of found supports
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRGetPlanes 	(IGRlong *msg; IGRint ArraySize; 
			 struct GRid PlaneIds[]; IGRint *NbPlanes; struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetPlanes
/*
/*      Returns the list of planes templates of the components connect points.
/*	These planes are grouped three by three, each group being associated
/*	with one connect point.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		*ArraySize	I : Size of the PlaneIds array.
/*
/* struct GRid		PlaneIds[]	O : Array returning the Planes ids.
/*					    ( can be specified as NULL )
/* IGRint		*NbPlanes	O : number of found planes
/*
/* struct GRmd_env	*md_env		I : pointer to target object module env.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRGetCorrections (IGRlong *msg; IGRint ArraySize; 
			 struct GRid CorIds[]; IGRint *NbCorrections);
/*---------------------------------------------------------------------------
/* VRGetCorrections
/*
/*      Returns the list of correction objects children of the component.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		*ArraySize	I : Size of the CorIds array.
/*
/* struct GRid		CorIds[]	O : Array of correction objects
/*					    ( can be specified as NULL )
/* IGRint		*NbCorrections	O : number of found correction objects
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRGetHangers (	IGRlong *msg; IGRint ArraySize; 
			struct GRid HangerIds[]; IGRint *NbHangers;
			IGRdouble *dCpCoors; struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetHangers
/*
/*      Returns the list of hanger objects connected to the component.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		*ArraySize	I : Size of the HangerIds array.
/*
/* struct GRid		HangerIds[]	O : Array of Hanger objects
/*					    ( can be specified as NULL )
/* IGRint		*NbHangers	O : number of found hanger objects
/*
/* IGRdouble		*dCpCoors	O : Hangers' connection coordinates.
/*					    This buffer must be sized at 
/*					    (ArraySize*3).
/* struct GRmd_env	*md_env		I : pointer to object's module env.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRGetIndex (IGRlong *msg; struct GRid *SegmentId; IGRshort *CompIndex);
/*---------------------------------------------------------------------------
/* VRGetIndex
/*
/*    Returns the place of the component on the segment (0 or 1).
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		*SegmentId	I : Segment template of component.
/*
/* IGRint		*CompIndex	O : component's index on the segment
/*
/* NOTE : Must be overridden by subclass having segments as templates.
/*
/*---------------------------------------------------------------------------
/* */

message VRGetCptOnSup ( IGRlong *msg ; struct GRid *SegId; IGRshort *nCpNum;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetCptOnSup
/*
/*      Returns its connect point number on the specified
/*	support.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		*SegId		I : Specified support id.
/*
/* IGRshort		*nCpNum		O : Connect point number.
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRGetSupOnCpt ( IGRlong *msg ; IGRshort nCpNum; struct GRid *SegId;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetSupOnCpt
/*
/*      Returns its topologic template on which its specified connect
/*	point is.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Connect point number.
/*
/* struct GRid		*SegId		O : Segment Id
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRGetPlanesOnCpt ( IGRlong *msg ; IGRshort nCpNum; struct GRid *PlaneIds;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetPlanesOnCpt
/*
/*      Returns its topologic template on which its specified connect
/*	point is.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Connect point number.
/*
/* struct GRid		*PlaneIds	O : returns 3 plane Ids : 
/*						[Common, Ortho, Terminal]
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE : Temporarly rejected and overriden in VRConcComp.
/*---------------------------------------------------------------------------
/* */

message VRGetCorOnCpt ( IGRlong *msg ; IGRshort nCpNum; struct GRid *CorId;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetCorOnCpt
/*
/*      Returns its correction child which corrects its specified connect
/*	point.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Connect point number.
/*
/* struct GRid		*CorId		O : Segment Id
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRGetNextOnCpt ( IGRlong *msg ; IGRshort nCpNum;
			struct GRid *NextId;
			IGRshort *nNextCpNum;
			IGRshort nSizBuf;
			IGRshort *nNbVia;
			struct GRid *ViaIds;
			IGRshort *nViaCpNum;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* 3-98 KDD 	*** DO NOT USE THIS METHOD          ***
/*		*** if you want to get the neighbor ***
/*		*** Instead use VRGetNeighbors      ***
/*
/* VRGetNextOnCpt
/*
/*      Returns the next component in the network connectable to the
/*	specified connect point
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Connect point number.
/*
/* struct GRid		*NextId		O : pointer on Next componentid.
/*
/* IGRshort		*nNextCpNum	O : Connect point number of the
/*					    next component.
/* IGRshort		nSizBuf		I : Size of ViaIds and nViaCpNum
/*					    buffers.
/* IGRshort		*nNbVia		O : Number of in between components
/*					    MUST BE INITIALIZED TO 0
/* struct GRid		*ViaIds		O : buffer on in between components
/*
/* IGRshort		*nViaCpNum	O : Connect point number of each
/*					    in between components.
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE : Each buffer can be specified as a NULL pointer.
/*---------------------------------------------------------------------------
/* */

		/* -- Modification -- */

message VRNotifyCorrections( IGRlong *msg;IGRint NotifyFlag );
/*---------------------------------------------------------------------------
/* VRRNotifyCorrections
/*
/*      Notify the correction of the changes that occurred at the
/*	component's level.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		NotifyFlag	I : (Not Used).
/*
/* NOTE :  A pointer can be passed as NULL.
/*
/*---------------------------------------------------------------------------
/* */

message VRChgParams( IGRlong *msg; 	struct GRid *SysParamId;
					struct GRid *UserParamId;
					struct GRid *MissParamId );
/*---------------------------------------------------------------------------
/* VRChgParams
/*
/*      Replace old parameters objects by the new specified ones.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		*SysParamId	I : pointer to the new System parameters
/*					    object's Grid I must depend on.
/* struct GRid		*UserParamId	I : pointer to the new User parameters
/*					    object's Grid I must depend on.
/* struct GRid		*MissParamId	I : pointer to the Missing parameters
/*					    object's Grid I must depend on.
/*
/*
/* NOTE :  A pointer can be passed as NULL.
/*
/*---------------------------------------------------------------------------
/* */


message VRConnect(IGRlong 		*msg;
		  struct GRid		*SegId;
		  IGRshort		nIndex;
		  IGRshort		nCptNum;
		  struct GRmd_env	*md_env  ) ;
/*---------------------------------------------------------------------------
/* VRConnect
/*
/*	connects the component to a network's segment at the specified end point.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong 		*msg		O  : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		*SegId		I  : segment that has to be connected
/*					     to the connect point.
/* IGRshort		nIndex		I  : segment's end point number that
/*					     is on the connect point.
/* IGRshort		nCptNum		I  : connection point number on which
/*					     the segment will be attached.
/* struct GRmd_env	*md_env		I  : pointer on module env.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRDisconnect(	IGRlong 		*msg;
			struct GRid		*SegId;
			struct GRmd_env		*md_env  ) ;

/*---------------------------------------------------------------------------
/* VRDisconnect
/*
/*	disconnects a network's segment from the component.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong 		*msg		O  : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		*SegId		I  : segment that has to be disconnected
/*					     from the nozzle.
/* struct GRmd_env	*md_env		I  : pointer on module env.
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */


		/* ---------------------------------- */
		/* -- NETWORK INFORMATION messages -- */
		/* ---------------------------------- */

message VRGetNeighbors (IGRlong 	*msg ;
			IGRint		CpFrom;
			IGRint		CpTo;
			IGRint		*NbNeigh;
			struct GRid	*NeiId; 
			IGRshort	*nNeiCpNum;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetNeighbors
/*
/*      Returns the component's neighboring description.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRint		CpFrom		I : From connect point number.
/*
/* IGRint		CpTo		I : To connect point number.
/*
/* IGRint		*NbNeigh	O : Number of returned neighbors.
/*
/* struct GRid		*NeiId		O : (Optional) returns the Ids of the 
/*					    neighbors on the specified
/*					    connect points ( NULL objid is returned
/*					    if the connect point is not connected).
/*					    If not specified as NULL, this pointer
/*					    must point on a buffer sized as (CpTo-CpFrom).
/* IGRshort		*nNeiCpNum	O : (Optional) returns the neighbors' 
/*					    corresponding connect point number.
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRGetTopo ( IGRlong *msg ; IGRint BufSize;
			IGRint	 	*NbCpts;
			IGRdouble	*dCompOrig;
			IGRdouble	*dCpCoors;
			struct GRid 	*NeiIds;
			IGRshort 	*nNeiCpNum;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetTopo
/*
/*      Returns the network connection description at each 
/*	connect point of the target component.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if
/*					    nBufSize is != 0 but too small.
/* IGRint		BufSize		I : Size of the specified buffers
/*
/* IGRint		*NbCpts		O : Total number of connect points.
/*
/* IGRdouble		*dCompOrig	O : Placement point of the component.
/*
/* IGRdouble		*dCpCoors	O : Buffer returning the coordinates
/*					    of each connect point ( 3 doubles
/*					    per connect point )
/* struct GRid		*NeiIds		O : Buffer returning the Ids of the 
/*					    component connected to each
/*					    connect point.
/* IGRshort		*nNeiCpNum	O : Buffer returning the corresponding
/*					    connect point number of each
/*					    neighbor.
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*	Each pointer on buffer can be specified as NULL.
/*
/*---------------------------------------------------------------------------
/* */

message VRSelectCptByGeom (IGRlong *msg ;
			IGRdouble *dConPos; IGRdouble *dConVect; 
			IGRshort *nCpNum;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRSelectCptByGeom
/*
/*      Returns its connect point number that matches the specified geometry.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRdouble		*dConPos	I : If not NULL specifies a position
/*					    connectable to the requested
/*					    connect point.
/* IGRdouble		*dConVect	I : If not NULL specifies the direction
/*					    of connection.
/* IGRshort		*nCpNum		O : Selected connect point number.
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRGetConnDesc (IGRlong *msg ; struct GRid *OtherId;
			IGRshort *nTargetCpNum; 
			IGRshort *nOtherCpNum;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetConnDesc
/*
/*      Returns if the target component and the specified component can be
/*	connected via a correction, the connect points numbers.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if connectio exists and MSFAIL if not.
/*
/* struct GRid		*OtherId	I : Specifies the other component
/*
/* IGRshort		*nTargetCpNum	O : Returns target component's connect point number.
/*
/* IGRshort		*nOtherCpNum	O : Returns the other component's connect point number.
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */




		/* ----------------------------------- */
		/* -- FOR INTERNAL USE ONLY messages-- */
		/* ----------------------------------- */



message VRNotifyLengthModif (IGRlong *msg ; IGRshort nCpNum; struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRNotifyLengthModif
/*
/*      Notifies a component that the length of its associated correction component
/*	on specified connect point might have changed.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if connectio exists and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Specified connect point.
/*
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */

message VRGetDefName (IGRlong *msg; IGRchar *sMacroName);
/*---------------------------------------------------------------------------
/* VRGetDefName
/*
/*      Returns the macro definition name of the occurence.
/*
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRchar		*sMacroName	O : macro definition name.
/*
/* NOTE :
/*	Must be overriden in the subclass depending on the
/*	component type and product.
/*
/*---------------------------------------------------------------------------
/* */

message VRGetModel( IGRlong *msg;  struct GRid *ModelId ;
		    struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetModel
/*
/*      Returns the component's Cache stored in the design
/*	based on its attributes.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* struct GRid		*ModelId	O : Pointer to the model identifier
/*					    structure
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRGetMacro( 	IGRlong 		*msg ;
			IGRchar 		*szMacroName;
			IGRchar			*cRep;
			IGRshort		*nMacroType;
			struct GRid 		*StaticId ;
			IGRint			*NbMissing;
			IGRchar 		***MissingNames;
			struct ret_struct	**MissingStr;
			struct GRmd_env 	*md_env);

/*---------------------------------------------------------------------------
/* VRGetMacro
/*
/*      Returns the component's macro name and the attributes
/*	that, added to the component itself, will allow its
/*	placement.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRchar		*szMacroName	O : outputs the macro name.
/*
/* IGRchar		*cRep		O : Representation value for the
/*					    macro placement.
/* IGRshort		*nMacroType	O : Specifies whether the macro
/*					    can be placed as a symbol or
/*					    not ( VR_DYN => no symbol ).
/* struct GRid		*StaticId	O : Pointer to the collection id 
/*					    holding the db attributes.
/* IGRint		*NbMissing	O : Number of missing templates.
/*
/* struct ACrg_coll	**MissingStr	O : address of a pointer on an array of
/*					    attributes structures.(returns the
/*					    address of a static buffer).
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRChgSupport ( IGRlong *msg ; IGRdouble MyNewOrient;
                       IGRshort MyNewIndex; struct GRid *OldSupport;
                       struct GRid *NewSupport );

/*---------------------------------------------------------------------------
/* VRChgSupport
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* NOTE :
/*---------------------------------------------------------------------------
/* */
	/* +----------------------------+ */
	/* | ERROR Component management | */
	/* +----------------------------+ */

message VRGetErrGraphic( IGRlong *msg; IGRdouble *dMatrix;
			struct GRid *GraphicId  ;
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetErrGraphic
/*
/*      Returns the generic error model stored in the design.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRdouble		*dMatrix	I : Pointer to the 4x4 orientation
/*					    matrix ( only the origin point
/*					    is relevant).
/* struct GRid		*GraphicId	O : Pointer to the ERROR graphic object
/*					    identifier structure
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE :
/*
/*---------------------------------------------------------------------------
/* */

message VRGetErrGeom ( 	IGRlong *msg ;IGRshort nCpNum;
			IGRdouble *dCptCoor; IGRdouble *dConAxis;
			IGRdouble *dOrientation; 
			struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* VRGetErrGeom
/*
/*      Returns the geometry of the specified connect point of an error component.
/*
/*      Argument description :
/*      --------------------
/*
/* IGRlong              *msg            O : MSSUC if success and MSFAIL if not.
/*
/* IGRshort		nCpNum		I : Connect point number.
/*
/* IGRdouble		*dCptCoor	O : XYZ coordinates 
/*
/* IGRdouble		*dConAxis	O : Connection axis vector
/*
/* IGRdouble		*dOrientation	O : Orientation vector of the surface
/*					    of connection.
/* struct GRmd_env	*md_env		I : pointer on module env
/*
/*
/* NOTE : The three output can be specified as NULL.
/*---------------------------------------------------------------------------
/* */

/*C	This method gives the information( category and id bahavior )
	related with tag number management of route components. This
	contains default implementation at this level. This needs to
	be overriden as required at lower level
*/
message VRGetCatBehavior(
	IGRlong		*msg ;		/* I/O - return status		*/
	IGRint		*Category;	/* O   - Category of the Cmp	*/
	IGRint		*Behavior	/* O   - Behavior of the Cmp	*/
);


/*---------------------------------------------------------------------------

   NOTE:   Offset coordinates are to be used for arrangement of cables inside
           a conduit or to connect to a connectpoint at a certain offset
           the default implementation at this level has no offsets

           These messages must be overridden for the specific subclasses

  ---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------
        message VRGetOffCoord

        return actual connection coordinates (including offset)
        and connect orientation vector

      *msg;            I/O - return status
      *ChildId;        I   - Id of specific child
       nCpt;           I   - Connectpoint number
      *dCoord;         O   - Offset coordinates
      *dConaxis;       O   - connect orientation axis
      *pModEnv         I   - Module environment
*/

message VRGetOffCoord (IGRlong         *msg;
                struct GRid            *ChildId;
                       IGRshort         nCpt;
                       IGRdouble       *dCoord;
                       IGRdouble       *dConaxis;
                struct GRmd_env        *pModEnv);

/*---------------------------------------------------------------------------
        message VRSetOffCoord

        stores the offset for a specific child

      *msg;            I/O - return status
      *ChildId;        I   - Id of specific child
       nCpt;           I   - Connectpoint number
       dAngle;         I   - Angle from up or +x
       dDist;          I   - Distance from Cpt
      *pModEnv         I   - Module environment
*/

message VRSetOffCoord (IGRlong         *msg;
                struct GRid            *ChildId;
                       IGRshort         nCpt;
                       IGRdouble        dAngle;
                       IGRdouble        dDist;
                struct GRmd_env        *pModEnv);


/*---------------------------------------------------------------------------
 VRVerifyTopology

    This method will verify the topology of a object.  It verifies its
    channel connections.  It the results of the verifications to reports.
    It has the option of also returning all of the corrections and control
    segments attached to the component so that they may be verified later 


      *msg       O    - return status
      *md_env    I    - module environment 
      *NewObj    I/O  - objects to be returned to be later verified if any
      *FileData  I/O  - File info for verbose and error report
      bVerbose   I    - Flag, TRUE if verbose report is to be generated
      *ErrorCnt  I/O  - Count of Errors found 
      *dOrigCoor I/O  - Coordinates of the object being verified

 */

message VRVerifyTopology ( IGRlong *msg;  struct GRmd_env *md_env; 
			   struct VRvfy_objs *NewObj;
			   struct VRvfy_file *FileData;
			   IGRboolean bVerbose; IGRint *ErrorCnt;
			   IGRdouble *dOrigCoor);

/*---------------------------------------------------------------------------
 VRVerifyChildren

      This message verifies the topology of the children of the generic obj
      It is called by VRVerifyTopology.  It has the option of returning the 
      corrections connected to the object so they can be verified      

      *msg       O    - return status
      *md_env    I    - module environment 
      *NewObj    I/O  - objects to be returned to be later verified if any
      *FileData  I/O  - File info for verbose and error report
      bVerbose   I    - Flag, TRUE if verbose report is to be generated
      *ErrorCnt  I/O  - Count of Errors found 
      *dOrigCoor I/O  - Coordinates of the object being verified
      NbCnrlSeg  I    - Number of control segments as parents
 */

message VRVerifyChildren ( IGRlong *msg;  struct GRmd_env *md_env; 
			   struct VRvfy_objs *NewObj;
			   struct VRvfy_file *FileData;
			   IGRboolean bVerbose; IGRint *ErrorCnt;
			   IGRdouble *dOrigCoor; IGRint NbCnrlSeg);
/*---------------------------------------------------------------------------
 VRVerifyModel

      This message verifies the cache and model.  Various intermediated 
      verifications are done during the process.

      *msg       O    - return status
      *md_env    I    - module environment 
      *FileData  I/O  - File info for verbose and error report
      bVerbose   I    - Flag, TRUE if verbose report is to be generated
      *ErrorCnt  I/O  - Count of Errors found 
      *dOrigCoor I/O  - Coordinates of the object being verified

 */
message VRVerifyModel( IGRlong *msg; struct GRmd_env *md_env; 
		      struct VRvfy_file *FileData;
		      IGRboolean bVerbose;IGRint *ErrorCnt;
		      IGRdouble *dOrigCoor );

/*---------------------------------------------------------------------------
 VRVerifyAttributes

      This message verifies the system attributes.  It verifies the number
      and the names of the attributes

      *msg       O    - return status
      *md_env    I    - module environment 
      *FileData  I/O  - File info for verbose and error report
      bVerbose   I    - Flag, TRUE if verbose report is to be generated
      *ErrorCnt  I/O  - Count of Errors found 
      *dOrigCoor I/O  - Coordinates of the object being verified

 */
message VRVerifyAttributes( IGRlong *msg; struct GRmd_env *md_env; 
		      struct VRvfy_file *FileData;
		      IGRboolean bVerbose;IGRint *ErrorCnt;
		      IGRdouble *dOrigCoor );

/*---------------------------------------------------------------------------
 VRVerifyFlow

      This message verifies the flow directions and rates.

      *msg       O    - return status
      *md_env    I    - module environment 
      *FileData  I/O  - File info for verbose and error report
      bVerbose   I    - Flag, TRUE if verbose report is to be generated
      *ErrorCnt  I/O  - Count of Errors found 
      *dOrigCoor I/O  - Coordinates of the object being verified
      
 */

message VRVerifyFlow( IGRlong *msg; struct GRmd_env *md_env; 
		      struct VRvfy_file *FileData;
		     IGRboolean bVerbose; IGRint *ErrorCnt;
		     IGRdouble *dOrigCoor );

/*---------------------------------------------------------------------------
 VRVerifyConnect

      This message verifies the connectivity with the objects neighbors

      *msg       O    - return status
      *md_env    I    - module environment 
      *FileData  I/O  - File info for verbose and error report
      bVerbose   I    - Flag, TRUE if verbose report is to be generated
      *ErrorCnt  I/O  - Count of Errors found 
      *dOrigCoor I/O  - Coordinates of the object being verified

 */

message VRVerifyConnect( IGRlong *msg; struct GRmd_env *md_env; 
			struct VRvfy_file *FileData;
			IGRboolean bVerbose; IGRint *ErrorCnt;
			IGRdouble *dOrigCoor );


/*
  Public Message        VDprocAttr
        Get product information like, weight, center of gravity, mass and range
  Arguments
        OUT     long            *msg            Completion code.
        IN      struct GRmd_env *md_env.
        IN      int             flag            see vdprodinfo.h.
        OUT     VDprcAttr       *prcAttr.       see vdprodinfo.h

  Status/Return Code
        OM_S_SUCCESS    if success;

*/

message VDprocAttr (	IGRlong		*lMsg;
			struct GRmd_env	*MdEnv;
			IGRint		Flag;
			VDprcAttr	*prcAttr );

/*------------------------------------------------------------------------------
* 1-98 KDD
*
* This method solves the ballance equation for the current component.
*
*-------------------------------------------------
*
* PARAMETERS
*
* O: IGRlong    *msg            - output status flag.
*
* I: IGRshort   CptNum          - incoming connect point (-1 if not needed).
*                                 May be used to resolve propagation direction.
*
* I: IGRshort   *NoChangeList   - list of connect points not to change (if any).
*
* I: int        nNoChangeList   - number of points in NoChangeList
*
* I: int        MaxSize         - caller allocated size of arrays PointToChange,
*                                 FlowRateToChange and FlowDirToChange.
*
* O: IGRshort   *PointToChange  - list of points that need flow change.
*
* O: IGRdouble  *FlowRateToChange-  has the new flow rate at each changed point.
*
* O: IGRshort   *FlowDirToChange- has the new direction at each changed point
*
* O: int        *nPointToChange - Number of points that need flow rate changed.
*
* I: struct GRmd_env    *md_env - matrix transformation info.
*------------------------------------------
*
* NOTE: The caller MUST provide the memory needed (call twice if not sure).
*       Except nPointToChange (+msg, md_env) all other pointers may be null.
*
------------------------------------------------------------------------------*/
message VRFlowBallance (     IGRlong            *msg;
                             IGRshort           CptNum;
                             IGRshort           *NoChangeList;
                             int                nNoChangeList;
                             int                MaxSize;
                             IGRshort           *PointToChange ;
                             IGRdouble          *FlowRateToChange;
                             IGRshort           *FlowDirToChange;
                             int                *nPointToChange;
                             struct   GRmd_env  *md_env );

/*------------------------------------------------------------------------------
* 3-98 KDD
*
* method VRGetPrivateParams
*
* Well, That is how it works: By a kludgy design my collector parents may be 
* also parents of other components. The result being that my attributes are
* not unique, but shared with other components. Have fun, a? 
*
* That is why I created this method to return UNIQUE parent collectors.
* If the collectors are already private it works just like VRGetParams,
* otherwise it creates those private collectors, and reconnects them to my_id. 
*----------------------------------------
*
* PARAMETERS:
*
* O: IGRlong              *msg            MSSUC if success and MSFAIL if not.
*
* O: struct GRid          *SysParamId     Returns the system parameters GRid.
*
* O: struct GRid          *UserParamId    Returns the user parameters GRid.
*
* O: struct GRid          *MissParamId    Returns the added parameters GRid.
*
------------------------------------------------------------------------------*/
message VRGetPrivateParams( IGRlong *msg;      
					struct GRid *SysParamId;
                                        struct GRid *UserParamId;
                                        struct GRid *MissParamId );


reject 	VRGetDefName,
	VRGetIndex,
	VRChgSupport,
	VRGetPlanesOnCpt,    /* only implemented in VRConcComp. */
	VRDisconnect,	     /* differs depending on the type of component. */
        VRVerifyTopology;   /* differs depending on type of component */



end specification VRGeneric;





