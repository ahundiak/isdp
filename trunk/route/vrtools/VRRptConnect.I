/* $Id: VRRptConnect.I,v 1.1.1.1 2001/01/04 21:13:12 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRRptConnect.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRptConnect.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/18  00:32:28  pinnacle
# Replaced: vrtools/VRRptConnect.I for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb		Add prototypes, 
 *
 *************************************************************************/
/* -------------------------------------------------------------- */
/*	Author	: Bruno Demars (ISDC, Paris)
/*
/*	Date	: 8-Sep-93
/*
/*	Description :
/*
/*	This file contains functions to report to database.
/*	
/*	BIG KLUDGE : Most of the code should be implemented in the
/*	object themselves but I don;t have enough time.
/*
/* -------------------------------------------------------------- */
class implementation VRConnect;

#include "grdpb.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "vrdef.h"
#include "vrmacros.h"
#include "VDScheckdef.h"
#include "VDDbtbldef.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bserr.h"
#include "nddef.h"
#include "bslenvec.h"

extern        GRclassid        OPP_VRConnect_class_id;
extern        GRclassid        OPP_VRSupport_class_id;
extern        GRclassid        OPP_VRLink_class_id;
extern        GRclassid        OPP_VRNozzle_class_id;

/*D
	VDGetRouteConnection :
		For a specified Component this function
		returns the number of connections , their names
		and the other Compnent/Equipment it is connected
		at and its connection's name.
*/


int     VDGetRouteConnection( EntityId,
				pMdEnv,
				nbSize,
				NbCpts,
				Cpts,
				Entities )
struct GRid		*EntityId;
struct GRmd_env		*pMdEnv;
int			nbSize;
int			*NbCpts;
char			**Cpts;
struct VDConnEntity	*Entities;
{

		IGRint	status, TotalCpts;
		IGRlong	retmsg;
register 	IGRint	i;
		GRclassid	EntClassId;
		struct VRGenInfo	ConnInfo;
*NbCpts = 0;

/*K Management by class */
status =
om$get_classid( osnum      = EntityId->osnum,
		objid      = EntityId->objid,
		p_classid  = &EntClassId );
as$status ( action = RET_STATUS );

/*K if VRLINK => return only neighbor on CPT 1 ( simulate flow ) */

if (om$is_ancestry_valid(
	subclassid   = EntClassId,
	superclassid = OPP_VRLink_class_id
	) == OM_S_SUCCESS )
{
	IGRint		Tmp;
	IGRshort	nTmp[2];
	struct GRid	TmpIds[2];

	TmpIds[0].objid = NULL_OBJID;
	TmpIds[1].objid = NULL_OBJID;

	/*C Get both neighbors */
	status=
	om$send ( msg = message VRGeneric.VRGetNeighbors
			( &retmsg, 0, 1, &Tmp,
			TmpIds,
			nTmp, pMdEnv),
		senderid = NULL_OBJID,
		targetid = EntityId->objid,
		targetos = EntityId->osnum);
	as$status ( action = RET_STATUS );

	/*C return Neighbor on cpt 1 if exists */
	if (TmpIds[1].objid != NULL_OBJID )
	{
		if ( *NbCpts<nbSize)
		{
			sprintf (Cpts[*NbCpts], "%d", 1);
			Entities[*NbCpts].EntityNo = TmpIds[1];
			sprintf (Entities[*NbCpts].Cpt, "%d", nTmp[1]);
		}
		/*C Increment number of connections returned */
		(*NbCpts) ++;

	}/* end returning connection on cp1 */


	/*C return connector on Cpt 0 if it is a logical one */
	if (TmpIds[0].objid != NULL_OBJID )
	{
		status =
		om$get_classid( osnum      = TmpIds[0].osnum,
				objid      = TmpIds[0].objid,
				p_classid  = &EntClassId );
		as$status ( action = RET_STATUS );
		if (om$is_ancestry_valid(
			subclassid   = EntClassId,
			superclassid = OPP_VRConnect_class_id
			) == OM_S_SUCCESS )
		{

			status=
			om$send ( msg = message VRGeneric.VRGetInstance
				( &retmsg, &ConnInfo),
				senderid = NULL_OBJID,
				targetid = TmpIds[0].objid,
				targetos = TmpIds[0].osnum);
			as$status ( action = RET_STATUS );

			if ( ConnInfo.Attr.Conn.nVRConn_type &
				(VRConn_LG|VRConn_CB) )
			{
			/*C Return logical connector */
			if (*NbCpts<nbSize)
			{
				sprintf (Cpts[*NbCpts], "%d", 0);
				Entities[*NbCpts].EntityNo = TmpIds[0];
				sprintf (Entities[*NbCpts].Cpt, "%d", nTmp[0]);
			}/* end returning info */

			/*C Increment number of connections returned */
			(*NbCpts) ++;

			}/* end return logical connector */
		}/* end connector found */
	}/* end of neighbor on cpt 0 */
}/* end of Link management */
else
if (om$is_ancestry_valid(
	subclassid   = EntClassId,
	superclassid = OPP_VRConnect_class_id
	) == OM_S_SUCCESS )
{
	/*K The VRGetNumberOfCpts and VRGetNeighbors should return as many
	    Cpts or Neighbors as there have connectors or links as children */
	/* Code copied from GetNeighbors method : Has to be reintegrated. */
/******************** BEGIN OF CONNECTOR **************************/
	IGRint		NbSiblings,isibl;
	struct GRid	*buffer;

	/*C Get all children */
	status =
	om$send( msg     = message NDnode.NDget_objects
			(ND_CHILDREN | ND_IN_BUF, NULL, 0, &buffer,
				0, OM_K_MAXINT, &NbSiblings ),
		senderid = NULL_OBJID,
		targetid = EntityId->objid,
		targetos = EntityId->osnum);
	as$status ( action = RET_STATUS );

	/*C Find Cables or connectors */

	for (isibl = 0; isibl < NbSiblings; isibl++)
	{
		GRclassid      SiblClassId;

		om$get_classid (objid     = buffer[isibl].objid,
				osnum     = buffer[isibl].osnum,
				p_classid = &SiblClassId );

		if ( om$is_ancestry_valid
			( subclassid   = SiblClassId,
			superclassid = OPP_VRConnect_class_id )
			== OM_S_SUCCESS )
		{  /*A  Found a (logical) connector   */
			/*C Return logical connector */
			if (*NbCpts<nbSize)
			{
				sprintf (Cpts[*NbCpts], "%d", *NbCpts);
				Entities[*NbCpts].EntityNo = buffer[isibl];
				sprintf (Entities[*NbCpts].Cpt, "%d", 0);
			}/* end returning info */

			/*C Increment number of connections returned */
			(*NbCpts) ++;

		}
		else
		if ( om$is_ancestry_valid (
			subclassid   = SiblClassId,
			superclassid = OPP_VRLink_class_id )
			== OM_S_SUCCESS )
		{
			/*A  Found a link, select the closest connectpoint     */

			/* Only return if it is Cp 0 of the link */
			IGRdouble    dVec[3];
			IGRdouble    dCp[3];
			IGRdouble    dist[2];
			BSrc         rc;
			IGRshort     i;
			IGRdouble 	dCoord[3];

			/*A  get cpt coordinates    */
			status =
			om$send ( msg = message VRGeneric.VRGetCptGeom
					(&retmsg, 0, dCoord, NULL, NULL, pMdEnv),
				senderid = NULL_OBJID,
				targetid = EntityId->objid,
				targetos = EntityId->osnum);
			as$status ( action = RET_STATUS );

			for (i = 0; i < 2; i++)
			{
				status =
				om$send ( msg = message VRGeneric.VRGetCptGeom
				( &retmsg, i, dCp, NULL, NULL, pMdEnv),
					senderid = NULL_OBJID,
					targetid = buffer[isibl].objid,
					targetos = buffer[isibl].osnum );
				as$status ();

				BSmkvec (&rc, dVec, dCoord, dCp);
				if ( rc != BSSUCC )
				dist[i] = 0.0;
				else
				dist[i] = BSlenvec (&rc, dVec);
			}

			if (dist[0] < dist[1])
			{
				/*C return connectivity information of cable Cp0 */
				if (*NbCpts<nbSize)
				{
					sprintf (Cpts[*NbCpts], "%d", *NbCpts);
					Entities[*NbCpts].EntityNo = buffer[isibl];
					sprintf (Entities[*NbCpts].Cpt, "%d", 0);
				}/* end returning info */

				/*C Increment number of connections returned */
				(*NbCpts) ++;

			}/* end returning Cp0 of link */

		}   /*  end of link found   */

	}/* end of loop on children */

/********************** END OF CONNECTOR *****************************/

}/* end of Connector management KLUDGE */
else
{
/*K GENERIC MANGEMENT : THE LOGICAL CONNECTORS SHOULD BE RETURNED AS NEIGHBORS
			BY EVERYBODY.
*/

/*A Get number of connection points of the component */

status=
om$send ( msg = message VRGeneric.VRGetNumberOfCpts
		( &retmsg, &TotalCpts, pMdEnv),
	senderid = NULL_OBJID,
	targetid = EntityId->objid,
	targetos = EntityId->osnum);
as$status ( action = RET_STATUS );

/*A Return connection only if flow is out */
for ( i=0; i<TotalCpts; i++)
{
	IGRint		Tmp;
	IGRshort	nTmp;
	IGRshort	nNeighborsType;

	/*C Get flow */
	status=
	om$send ( msg = message VRGeneric.VRGetFlow
			( &retmsg, i, &nTmp, NULL, pMdEnv),
		senderid = NULL_OBJID,
		targetid = EntityId->objid,
		targetos = EntityId->osnum);
	as$status ( action = CONTINUE );

	/*C If flow is OUT */
	if ( nTmp == VR_FLOW_OUT )
	{
		/*C Fill connection name */

		if (*NbCpts<nbSize)
		{
			sprintf (Cpts[*NbCpts], "%d", i);

			/*C Fill connection description */
			/*C 	Get element connected to it */
			status=
			om$send ( msg = message VRGeneric.VRGetNeighbors
					( &retmsg, i, i, &Tmp,
					&Entities[*NbCpts].EntityNo,
					&nTmp, pMdEnv),
				senderid = NULL_OBJID,
				targetid = EntityId->objid,
				targetos = EntityId->osnum);
			as$status ( action = CONTINUE );

			/*C If neighbor is a logical connector : Special action */

			sprintf (Entities[*NbCpts].Cpt, "%d", nTmp);
		}
		/*C verify if the neighbour is a dangle.  */
		status = 
		om$send ( msg = message VRGeneric.VRGetSysType 
					( &retmsg, &nNeighborsType ),
				senderid = NULL_OBJID,
				targetid = Entities[*NbCpts].EntityNo.objid,
				targetos = Entities[*NbCpts].EntityNo.osnum );

		if ( nNeighborsType == VR_DANGLING )
		{}
		/*	printf("This is a Dangling \n" ); */
		else

		/*C Increment number of connections returned */
		(*NbCpts) ++;

	}/* end fill connection */

}/* end loop */

}/* end generic treatment */

/*
for ( i=0; i<*NbCpts && i<nbSize ; i++ )
{
	printf (" Ent[%d] = <%d,%d>\n", i,
	Entities[i].EntityNo.objid, Entities[i].EntityNo.osnum );
}
*/

/*K Set special values for the LOGICAL CONNECTORS */
for ( i=0; i<*NbCpts && i<nbSize ; i++ )
{
	/*C Who knows ??? */
	if (Entities[i].EntityNo.objid == NULL_OBJID ) continue;

	status =
	om$get_classid( osnum      = Entities[i].EntityNo.osnum,
			objid      = Entities[i].EntityNo.objid,
			p_classid  = &EntClassId );
	as$status ( action = RET_STATUS );

	if ((om$is_ancestry_valid(
		subclassid   = EntClassId,
		superclassid = OPP_VRConnect_class_id
		) == OM_S_SUCCESS)  ||
	    (om$is_ancestry_valid(
		subclassid   = EntClassId,
		superclassid = OPP_VRNozzle_class_id
		) == OM_S_SUCCESS) )
	{
		IGRint			FootIndex=-1;
		struct ret_struct	AttrRst;

printf("encountered a Connect or a Nozzle \n" );
		
		/*C Get connector's tag */
		status = 
		om$send ( msg = message VRGeneric.ACgive_structure
				( (IGRint *) &retmsg, &FootIndex, VD_N_TAG_NUMBER_AN,
				  &AttrRst, NULL ),
			senderid = NULL_OBJID,
			targetid = Entities[i].EntityNo.objid,
			targetos = Entities[i].EntityNo.osnum);
		as$status ( action = RET_STATUS );
		status=
		om$send ( msg = message VRGeneric.VRGetInstance
				( &retmsg, &ConnInfo),
			senderid = NULL_OBJID,
			targetid = Entities[i].EntityNo.objid,
			targetos = Entities[i].EntityNo.osnum);
		as$status ( action = RET_STATUS );

		if ( ! (ConnInfo.Attr.Conn.nVRConn_type&(VRConn_LG|VRConn_CB) ))
		{
		struct GRid EquipId;

		/*C Set Equip Id and connector number */
		status = 
		om$send ( msg = message VRConnect.VRGetEquipId
				( &retmsg, &EquipId ),
			senderid = NULL_OBJID,
			targetid = Entities[i].EntityNo.objid,
			targetos = Entities[i].EntityNo.osnum);
		if ( (status&1) && EquipId.objid != NULL_OBJID )
		{
			/*C Set entity number */
			Entities[i].EntityNo = EquipId;
			/*C Set connector's name */
			strcpy (Entities[i].Cpt,
				AttrRst.var.text_st.text_string);
		}
		/* I should not be doing this stupid thing, but when the whole
		 * thing is rewritten, it needs to be cleaned */
		else if (om$is_ancestry_valid( subclassid   = EntClassId,
			superclassid = OPP_VRNozzle_class_id) == OM_S_SUCCESS) 
		   {

			/*C Set connector's name */
			strcpy (Entities[i].Cpt,
				AttrRst.var.text_st.text_string);

			FootIndex = -1;
			status = 
			om$send ( msg = message VRGeneric.ACgive_structure
				( (IGRint *) &retmsg, &FootIndex, VD_N_EQP_ID_IN,
				  &AttrRst, NULL ),
				senderid = NULL_OBJID,
				targetid = Entities[i].EntityNo.objid,
				targetos = Entities[i].EntityNo.osnum);
			as$status ( action = RET_STATUS );
			Entities[i].EntityNo.objid = (GRobjid)AttrRst.var.root_pm_st.value;

		   }/* end management of Equipments */
		}
		else
		{

		/*C Set entity number */
		Entities[i].EntityNo.objid = 0;
		/*C Set connector's name */
		strcpy (Entities[i].Cpt, AttrRst.var.text_st.text_string);
		}/* end logical connector */

	}/* end set LOGICAL values */
}/* end manage LOGICAL CONNECTORS */

return OM_S_SUCCESS;

}/* end VDGetRouteConnection function */


end implementation VRConnect;
