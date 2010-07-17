/* $Id: VRAttributes.I,v 1.3 2001/02/20 01:17:33 build Exp $ */

/* I/ROUTE
 *
 * File		:	VRAttributes.I
 *
 * Dependencies	:
 *			NONE
 * -------------------------------------------------------------- 
 *	Author	: Bruno Demars (ISDC, Paris)
 *
 *	Date	: 15-Jul-92
 *
 *	Description :
 *
 *	This file contains functions accessing components' parameters.
 *	These functions have to be called through the macros defined
 *	in the vrmacros.h file.
 *	
 *	History	:
 *
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/04/94	msm		Added a function VRGetParameterType()	
 *
 *
 * -------------------------------------------------------------- */
class implementation Root;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "VRdef.h"
#include "parametric.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "VRstructs.h"
#include "VRchgattrdef.h"
#include "VDmem.h"
#include <stdio.h>
#include "vrdbgmacros.h"

/************************************************************************
 *									*
 *	VRReviewParameters:						*
 *          Given a list of attribute names, this function returns	*
 *	    their values in the specified component.			*
 *									*
 *	Must be called via vr$get_attributes				*
 *									*
 *									*
 ************************************************************************/

from NDmacro	import	ACgive_structure;
from VRGeneric	import	VRGetCompDesc,VRGetParams;
from ACcpx	import find_macro;
from ACmacro_defn import ACgive_feet_desc;
from NDmacro	import  ACreturn_foot;
from NDnode	import  NDgive_structure;

extern GRclassid OPP_VREquipment_class_id;

IGRint	VRReviewParameters ( pMsg, CompId, NamesNumber, pList, pMdEnv )

IGRlong 	*pMsg;		/* Completion code 		*/
struct GRid	*CompId;	/* Specified component 		*/
IGRint		NamesNumber;	/* Number of specified names	*/
struct ACrg_coll *pList;	/* Array of parameters		*/
struct GRmd_env	*pMdEnv;	/* Module environment of the object */
{
	IGRint			status, i;
	IGRlong			retmsg;
	IGRint			Index = -1;
	struct ret_struct	AttrSt;

  SetProc( Root_VRReviewParameters ); Begin
 *pMsg = MSSUCC;

 for ( i=0; i<NamesNumber; i++ )
 {
	pList[i].desc.type 	= AC_ATTRIB_TYPE_NOT_DEF;

	status = om$send ( msg = message NDmacro.ACgive_structure
				( (IGRint *) &retmsg, &Index,
				 pList[i].name, &AttrSt, pMdEnv ),
			senderid = NULL_OBJID,
			targetid = CompId->objid,
			targetos = CompId->osnum );
	as$status ( action = RET_STATUS );
	if ( retmsg&1 )
	{
		/* Parameter exists and it has the right type */
		/* Put value in the array */
		if ( AttrSt.type == double_type )
		{
			pList[i].desc.type 	= AC_ATTRIB_DOUBLE;
			pList[i].desc.value.att_exp =
				AttrSt.var.root_pm_st.value;
		}
		else if ( AttrSt.type == text_type )
		{
			pList[i].desc.type 	= AC_ATTRIB_TEXT;
			strcpy (pList[i].desc.value.att_txt ,
				AttrSt.var.text_st.text_string) ;
		}
	}/* end get parameter succeeded */
	else /* try to get the attribute value from Static Attributes */
	{
		status = 
		om$send ( msg = message VRGeneric.VRGetCompDesc
			( &retmsg, &pList[i], pMdEnv ),
			senderid = NULL_OBJID,
			targetid = CompId->objid,
			targetos = CompId->osnum );
		as$status ( action = RET_STATUS );

		if ( !( retmsg & 1 ) ) *pMsg = MSFAIL;
	}

 }/* end loop on parameter names */

 End
 return OM_S_SUCCESS;

}/* end VRGetParameters */

from VRGeneric	import	VRGetCptProp, VRGetNumberOfCpts;

extern	GRclassid	OPP_VRPiping_class_id, OPP_VRHvac_class_id,
			OPP_VRRway_class_id;
/*C
	This function outputs the connecton properties given a 
	component Id and the CptNum at which connection 
	properties are required.
*/

IGRint	VRGetCptProp( pMsg, pCmpId, nCptNum, pDim1, pDim2,
		pSection, pEndPrep, pPressure, pCptOffSet, pMdEnv )

IGRlong 	*pMsg ;		/* O : Return code, MSSUCC or MSFAIL.   */
struct GRid	*pCmpId;	/* I : Componet GRid			*/
IGRshort	nCptNum;	/* I : CptNum of the Comp for which
				       Props are required		*/
IGRdouble	*pDim1;		/* O : returns 
					Diameter in case of PIPING Comp
					Width  in case of HVAC & CABLING*/
IGRdouble	*pDim2;		/* O : returns 
					-1     in case of PIPING Comp
					Depth  in case of HVAC & CABLING*/
IGRshort	*pSection;	/* O : Section Mask at the Cpt		*/
IGRint		*pEndPrep;	/* O : End Prep at the Specified CptNum */
IGRdouble	*pPressure;	/* O : Pressure at the Specified CptNum */
IGRdouble	*pCptOffSet;	/* O : Cpt Offset at the Specified CptNo*/
struct GRmd_env	*pMdEnv;	/* I : Module environment of the Cmp	*/
{
	IGRlong		status, retmsg;
	IGRint		Product;

        SetProc( Root_VRGetCptProp ); Begin
	/*A validity check for the input arguments */
	if ( !pCmpId || !pMdEnv || nCptNum < 0 )
		return OM_E_INVARG;

	/*A initialization */
	status = OM_S_SUCCESS;
	*pMsg = MSSUCC;
	if ( pDim1 ) *pDim1 = -1.;
	if ( pDim2 ) *pDim2 = -1.;
	if ( pSection ) *pSection = -1.;

	/*A get the number of Cpts of the Cmp */
	{
		IGRint	NbCpts;

		status = 
		om$send( msg      = message VRGeneric.VRGetNumberOfCpts
			( &retmsg, &NbCpts, pMdEnv ),
                      	senderid = NULL_OBJID,
                      	targetid = pCmpId->objid, 
                      	targetos = pCmpId->osnum );
		as$status();
		as$status( action = RET_STATUS ); 

		/* "NbCpts = %d \n", NbCpts */

		/*C error out if the CptNum is out of limits */
		if ( nCptNum > NbCpts )
		{
			*pMsg = MSFAIL;
                        End
			return OM_E_ABORT;
		}
	}

	/*A get the appllication type from the Cmp */

	/*C get the classid and set the product type */
	{
		GRclassid	ObjClass;
	
		status = om$get_classid(
			osnum	= pCmpId->osnum,
			objid   = pCmpId->objid,
			p_classid = &ObjClass );
		as$status();

      		if ( om$is_ancestry_valid( subclassid   = ObjClass,
	  	 superclassid = OPP_VRPiping_class_id ) == OM_S_SUCCESS )
			Product = VR_PIPING;
		else if (om$is_ancestry_valid( subclassid   = ObjClass,
	  	 superclassid = OPP_VRHvac_class_id ) == OM_S_SUCCESS )
			Product = VR_HVAC;
		else if (om$is_ancestry_valid( subclassid   = ObjClass,
	  	 superclassid = OPP_VRRway_class_id ) == OM_S_SUCCESS )
			Product = VR_CABLING;
		else
                {
                  End
                  return OM_E_ABORT;
                }
	} /* end set the product type */

	/*A get the particular Cpt Prop from the Cmp */
	{
		struct	VRcp_attr	CptProp;
	
		status = 
		om$send( msg      = message VRGeneric.VRGetCptProp
			( &retmsg, nCptNum, &CptProp, pMdEnv ),
			senderid = NULL_OBJID,
			targetid = pCmpId->objid,
			targetos = pCmpId->osnum );
		as$status();
		as$status( action = RET_STATUS );

		/*A output the respective properties based 
		    on the application */
		if ( retmsg == MSSUCC )
		{
		 switch ( Product )
		 {
			case VR_PIPING:
				if ( pDim1 ) *pDim1 = CptProp.width;
				break;

			case VR_HVAC:
			case VR_CABLING:
				if ( pDim1 ) *pDim1 = CptProp.width;
				if ( pDim2 ) *pDim2 = CptProp.depth;
				if ( pSection ) 
				 *pSection = CptProp.section_mask & VR_SHAPE;
				break;
			
			default :
				printf( "Invalid Product Type \n");
                                End
				return OM_E_ABORT;
	
		 } /* end product switch */

		 if ( pEndPrep ) *pEndPrep = CptProp.end_prep;
		 if ( pPressure ) *pPressure = CptProp.pressure;
		 if ( pCptOffSet ) *pCptOffSet = CptProp.cp_offset;
		} /* end MSSUCC */

		/* " Width or Diameter = %f \n", CptProp.width */
		/* " Depth = %f \n", CptProp.depth )*/
		/* " Section mask = %d \n", (int)*pSection */
		/* " EndPrep = %d \n", CptProp.end_prep */
		/* " Pressure = %f \n", CptProp.pressure */
		/* " Cpt Off Set = %f \n", CptProp.cp_offset */

	} /* end get Cpt Prop from Cmp */

        End
	return OM_S_SUCCESS;

} /* end VRGetCptProps */

/************************************************************************
 *									*
 *	VRGetConnections:						*
 *          Given a listnction returns	*
 *	    their valuescomponent.			*
 *									*
 *	Must be called via vr$get_connections				*
 *									*
 *									*
 ************************************************************************/

/*+fe

Abstract:

	This function returns to which collection a particular attribute 
	belongs, whether System collection or User collection or Missing
	attributes collection or to the Database.

	The possible return values for AttrType:
			VR_SYSTEM_ATTRIBUTE
			VR_USER_ATTRIBUTE
			VR_MISSING_ATTRIBUTE
			VR_DB_ATTRIBUTE
			VR_ATTRIBUTE_NE		(Attribute Does not exist)


IGRint VRGetParameterType ( pMsg, CompId, AttrName, AttrType, pMdEnv )
IGRlong 	*pMsg;		Completion code 		(O)
struct GRid	*CompId;	Specified component 		(I)
IGRchar		*AttrName;	Name of the Attribute		(I)
IGRint		*AttrType;	Attribute Type			(O)
struct GRmd_env	*pMdEnv;	Module environment of the object(I)

-fe*/

IGRint VRGetParameterType ( pMsg, CompId, AttrName, AttrType, pMdEnv )
IGRlong 	*pMsg;
struct GRid	*CompId;
IGRchar		*AttrName;
IGRint		*AttrType;
struct GRmd_env	*pMdEnv;

/* VRGetParameterType */
{
	IGRint			status, i;
	IGRlong			retmsg;
	struct ACrg_coll 	pList;
	struct GRid		AttId[3];
	GRclassid		Classid;

        SetProc( Root_VRGetParameterType ); Begin
 	*pMsg  = MSSUCC;
	retmsg = MSSUCC;
	status = OM_S_SUCCESS;

	strcpy( pList.name, AttrName );

	status = om$get_classid( objid = CompId->objid,
					  osnum = CompId->osnum,
					  p_classid = &Classid );
	as$status();

	if( Classid != OPP_VREquipment_class_id )
	{
		status = 
		om$send ( msg = message VRGeneric.VRGetCompDesc
			( &retmsg, &pList, pMdEnv ),
			senderid = NULL_OBJID,
			targetid = CompId->objid,
			targetos = CompId->osnum );
		as$status ( action = RET_STATUS );
	}
	else
		retmsg = 0;

        if ( retmsg & 1 ) {
                if ( pList.desc.value.att_exp != -99 )
        	        *AttrType = VR_DB_ATTR;
		else
			*AttrType = VR_ATTRIBUTE_NE;
	}
	else
	{
		status = 
		om$send ( msg 	= message VRGeneric.VRGetParams 
				( &retmsg, &AttId[0], &AttId[1], &AttId[2] ),
			senderid = NULL_OBJID,
			targetid = CompId->objid,
			targetos = CompId->osnum );

		for (i=0; i<3; i++)
		{
			IGRint			Index=-1;
			struct ret_struct	AttrSt;

			if ( AttId[i].objid != NULL_OBJID )
			{
				status = 
				om$send ( msg = message NDmacro.ACgive_structure
					( (IGRint *) &retmsg, &Index,
				 	AttrName, &AttrSt, pMdEnv ),
					senderid = NULL_OBJID,
					targetid = AttId[i].objid,
					targetos = AttId[i].osnum );

				if( (retmsg&1) && (status&1) ) break;
			}
		}

		if ( i == 0 ) *AttrType = VR_SYSTEM_ATTR;
		else if ( i == 1 ) *AttrType = VR_USER_ATTR;
		else if ( i == 2 ) *AttrType = VR_MISSING_ATTR;
		else *AttrType = VR_ATTRIBUTE_NE;

	}
        End
	return OM_S_SUCCESS;
}

IGRint VRGetInternalAttributes( struct GRid CmpId, 
			struct ACrg_coll **params, 
			IGRint *nb_params,
			struct GRmd_env *md_env )
{
	struct GRid macro_def, Feet;
	struct myfeet *l_feet;
	struct ret_struct rst;
	IGRlong retmsg;
	GRclassid Classid;
	IGRint nb_feet, i, status, cnt;

	extern GRclassid OPP_ACpretend_class_id;
        SetProc( Func_VRGetInternalAttributes ); Begin
	cnt = 0;
	*params = NULL;
	status = om$send( msg = message ACcpx.find_macro ( &macro_def ),
				senderid = NULL_OBJID,
				targetid = CmpId.objid,
				targetos = CmpId.osnum );
	as$status();

	status = om$send( msg = message ACmacro_defn.ACgive_feet_desc
				( &nb_feet, &l_feet ),
				senderid = NULL_OBJID,
				targetid = macro_def.objid,
				targetos = macro_def.osnum );
	as$status();

	for ( i=0; i < nb_feet; i++ )
	{
		status = om$send( msg = message NDmacro.ACreturn_foot
					( &retmsg, l_feet[i].name,
						&Feet, NULL, NULL ),
				senderid = NULL_OBJID,
				targetid = CmpId.objid,
				targetos = CmpId.osnum );
		as$status();

		status = om$get_classid( objid = Feet.objid,
					  osnum = Feet.osnum,
					  p_classid = &Classid );
		as$status();

		if( Classid == OPP_ACpretend_class_id )
		{
			status = om$send( msg = message NDnode.NDgive_structure
				( &retmsg, &rst, md_env ),
				senderid = NULL_OBJID,
				targetid = Feet.objid,
				targetos = Feet.osnum );

			/*A allocate the memory	for collection	*/
			if( ! *params )
			{
				*params = (struct ACrg_coll *)
						_MALLOC (1, struct ACrg_coll);
				if ( !*params )
				{
				  status = OM_E_NODYNMEM;
				  printf( "VDgetParameters:Could not allocate dynamic memory\n");
				  goto	wrapup;
				}
			}
			else
			{
				*params = (struct ACrg_coll *)
					_REALLOC (*params, cnt+1, struct ACrg_coll);
				if ( !*params )
				{
				  status = OM_E_NODYNMEM;
				  printf( "VDgetParameters:Could not allocate dynamic memory\n");
				  goto	wrapup;
				}
			}

			if( rst.type == double_type )
			{
				strcpy( (*params)[cnt].name, l_feet[i].name );
				(*params)[cnt].desc.type = AC_ATTRIB_DOUBLE;
				(*params)[cnt].desc.value.att_exp =
						rst.var.root_pm_st.value;
				cnt++;
			}
			else if ( rst.type == text_type )
			{
				strcpy( (*params)[cnt].name, l_feet[i].name );
				(*params)[cnt].desc.type = AC_ATTRIB_TEXT;
				strcpy( (*params)[cnt].desc.value.att_txt,
						rst.var.text_st.text_string );
				cnt++;
			}
		}
	}

	*nb_params = cnt;
        End
	return OM_S_SUCCESS;
   wrapup:
        End
	return OM_W_ABORT;
}

end implementation Root;
