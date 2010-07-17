/* $Id: VRCOPFunc1i.I,v 1.6 2002/05/29 15:15:03 louis Exp $  */

/* I/ROUTE
 *
 * File:        vrco/VRCOPFunc1i.I
 *
 * Description:
 *
 *      Functions to support form notification in VRProduct.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCOPFunc1i.I,v $
 *	Revision 1.6  2002/05/29 15:15:03  louis
 *	TR6312 Option codes increased to 99
 *	
 *	Revision 1.5  2002/04/10 15:04:20  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.4  2001/08/31 19:30:15  anand
 *	JTS TR MP 5098
 *	
 *	Revision 1.3  2001/02/20 01:12:11  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/11 22:46:12  anand
 *	SP merge
 *	
# Revision 1.3  2000/11/28  21:34:04  pinnacle
# Replaced: route/vrco/VRCOPFunc1i.I for:  by lawaddel for Service Pack
#
# Revision 1.2  2000/11/22  21:30:22  pinnacle
# Replaced: route/vrco/VRCOPFunc1i.I for:  by aharihar for Service Pack
#
# Revision 1.1  2000/07/14  18:03:04  pinnacle
# Created: route/vrco/VRCOPFunc1i.I by apazhani for Service Pack
#
# Revision 1.3  2000/02/21  20:51:24  pinnacle
# Replaced: vrco/VRCOPFunc1i.I for:  by lawaddel for route
#
# Revision 1.2  1998/11/20  09:43:26  pinnacle
# Replaced: vrco/VRCOPFunc1i.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/01/14  18:38:54  pinnacle
# Replaced: vrco/VRCOPFunc1i.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.8  1996/04/25  22:01:46  pinnacle
# Replaced: vrco/VRCOPFunc1i.I for:  by ashankar for route240
#
# Revision 1.7  1996/04/10  19:58:20  pinnacle
# Replaced: vrco/VRCOPFunc1i.I for:  by hverstee for route240
#
# Revision 1.6  1996/04/04  17:48:18  pinnacle
# Replaced: vrco/VRCOPFunc1i.I for:  by r240_int for route240
#
# Revision 1.5  1996/02/08  12:38:08  pinnacle
# Replaced: vrco/VRCOPFunc1i.I for:  by ashankar for route240
#
# Revision 1.4  1996/01/18  23:28:44  pinnacle
# Replaced: vrco/VRCOPFunc1i.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/16  21:26:54  pinnacle
# Replaced: vrco/VRCOPFunc1i.I for:  by r240_int for route240
#
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      -----------------------------------------------------------------------
 *	02/06/91	  ON	Creation.
 *	07/27/94	  MM	Fixed TR# 179421156
 *				Size allocated for long text for Codelist
 *					was only 8. Increased it to 15 upon 
 *					consultation with JG and MAB.
 *	07/27/94	Mallik 	Fixed TR 179421156.
 *			  		Size allocated for long text for 
 *					Codelist was only 8. Increased to 15.
 *	08/19/94	MM	Modified two functions. VRGetShapeString
 *					VRGetShapeCode upon adding TRAY_CODE.
 *	01/15/96	tlb	Add VX_FIproto.h, protoypes
 *				Change to ANSII style:
 *					VRIsTopoCompatible, VRCircularTreatment 
 *	01/17/96	tlb	Use VDfld_set_list_text
 *      01/12/98        law     CR179309874- New raceway shapes
 *      11/20/98        Reddy   TR179802158 - While placing HVAC offset
 *				system was crashing when a user 
 *				parameter was entered in VRUserForm
 *      02/14/00        law     tr179900985 - corrected != of doubles
 *      07/14/00        Alwin   ETL2780 - Clean the optcode field when not 
 *				found in the list of optcodes.
 *	Nov 22 2k	Anand	CR 179902073
 *      11/17/00        law     etl4583-TR MP4140
 *	Aug 31 01	Anand	TR 5098
 *      04/05/02        law     TR5649-standardize tolerance with VRGetTol
 *      05/29/02        law     TR6312-increased options to 99
 *
 ***********************************************************************/

class implementation VRCOProduct;

#include "nddef.h"
#include "ndmacros.h"
#include "VRco.h"
#include "VRMath.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "MS.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "VRDbParamDef.h"
#include "VRmacros.h"
#include "HV_param.h"
#include "VRcsdef.h"
#include "VDmacdef.h"
#include "vdsmacros.h"
#include "bsparameters.h"

#include "vrco_pto.h"
#include "vrtools_pto.h"
#include "vrpdu_pto.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
#include <math.h>
%endsafe

#define AS_DEBUG
#define VR_MAX_OPTCODE_SIZE  99
#define VR_OPTCODE_LIST_NUM  400

from 	NDnode		import	NDdisplay,
				NDs_compute_node;
from 	GRgraphics	import	GRdisplay,
				GRxform;
from 	VRGeneric	import	VRSetInstance,
				VRNotifyCorrections,
				VRGetPlanesOnCpt;
from	ACrg_collect	import	ACget_named_attribute,
				AClist_attribute;
from	VRCorrection	import	VRMergeCorrection;
from	ACncpx		import	ACgive_structure;



/* ====================================================================	*/
/* Given a Shape code it returns the corresponding string 		*/
/* The string must be allocated first					*/
/* Code and Strings are defined in VRco.h				*/

IGRint VRGetShapeString ( Code, szCode )
IGRint 	Code;
IGRchar *szCode;
/*.VRGetShapeString */
{
/*"Code on entry <%d>\n", Code */

switch (Code)
    {

case HRECTANGCODE:
    strcpy (szCode, HRECTANGSTRING );
    break;
case HOVALCODE:
    strcpy (szCode, HOVALSTRING );
    break;
case HCIRCLECODE:
    strcpy (szCode, HCIRCLESTRING );
    break;
/* Tray shape was deleted for CR179309874- New raceway shapes */
case HCORNRADCODE:
    strcpy (szCode, HCORNRRADSTRING );
    break;
case HRECTOVALCODE:
    strcpy (szCode, HRECTOVALSTRING );
    break;
case HRECTCIRCODE:
    strcpy (szCode, HRECTCIRSTRING );
    break;
case HRECTCORNCODE:
    strcpy (szCode, HRECTCORNSTRING );
    break;
case HOVALCIRCODE:
    strcpy (szCode, HOVALCIRSTRING );
    break;
case HOVALCORNCODE:
    strcpy (szCode,HOVALCORNSTRING  );
    break;
case HCIRCCORNCODE:
    strcpy (szCode, HCIRCORNSTRING  );
    break;
/* below added for CR179309874 - New raceway shapes */
case HELLPCIRCODE:
    strcpy (szCode, HELLPCIRCSTRING  );
    break;
case HELLPCORNCODE:
    strcpy (szCode, HELLPCORNSTRING  );
    break;
case HRECTELLPCODE:
    strcpy (szCode, HELLPRECTSTRING  );
    break;
case HOVALELLPCODE:
    strcpy (szCode, HELLPOVALSTRING  );
    break;

default:
    strcpy (szCode, HRECTANGSTRING );
    } /* end switch */

/*"szCode found is <%s>\n", szCode */

return OM_S_SUCCESS;

} /* end function VRGetShapeString */

/* ====================================================================	*/
/* Given a Shape string it returns the corresponding code		*/
/* Code and Strings are defined in VRco.h				*/

IGRint VRGetShapeCode ( szCode, Code )
IGRchar *szCode;
IGRint 	*Code;
/*.VRGetShapeCode */
{

VRTrimRightLeftSpace (szCode);

/*"szCode on entry <%s>\n", szCode */

if (!strcmp (szCode, HRECTANGSTRING))
    *Code = HRECTANGCODE;
else
    if (!strcmp (szCode, HOVALSTRING))
	*Code = HOVALCODE;
    else
	if (!strcmp (szCode, HCIRCLESTRING))
	    *Code = HCIRCLECODE;
        else
            if(!strcmp (szCode, HCORNRRADSTRING))
               *Code = HCORNRADCODE;
    	    else
	        if (!strcmp (szCode, HRECTOVALSTRING))
		    *Code = HRECTOVALCODE;
	        else
		    if (!strcmp (szCode, HRECTCIRSTRING))
		        *Code = HRECTCIRCODE;
             	    else
		        if (!strcmp (szCode, HOVALCIRSTRING))
			    *Code = HOVALCIRCODE;
                        else 
                            if (!strcmp (szCode, HRECTCORNSTRING))
                                *Code = HRECTCORNCODE; 
                            else 
                                if (!strcmp (szCode, HOVALCORNSTRING))
                                    *Code = HOVALCORNCODE;
                          /* Below modified for CR179309874 - New RW shapes */
                                else if(!strcmp (szCode, HCIRCORNSTRING))
                                        *Code = HCIRCCORNCODE; 
				else if(!strcmp (szCode, HELLPCIRCSTRING  ))
					*Code = HELLPCIRCODE;
				else if(!strcmp (szCode, HELLPCORNSTRING  ))
					*Code = HELLPCORNCODE;
				else if(!strcmp (szCode, HELLPRECTSTRING  ))
					*Code = HRECTELLPCODE;
				else if(!strcmp (szCode, HELLPOVALSTRING  ))
					*Code = HOVALELLPCODE;
	  		        else
		                        *Code = HRECTANGCODE;

/*"Code found is <%d>\n", *Code */

return OM_S_SUCCESS;

} /* end function VRGetShapeCode */

/* ====================================================================	*/
/* Pointers on struct CompSegDesc, on structure VRGenInfo and on GRid	*/
/* might be NULL.							*/
/* The aim of this function is mainly to modify the instances of the	*/
/* component and send a GRxform to planes.				*/

IGRint	VRUpdateGeometry ( msg, pCompSegDesc, pCompId, pMdEnv)

IGRlong 		*msg;
struct tagCompSegDesc 	*pCompSegDesc;
struct GRid 		*pCompId;
struct GRmd_env 	*pMdEnv;

/*.VRUpdateGeometry */
{
  IGRint		CnType=ND_COMP, i;
  IGRlong 		status;
  IGRdouble 		dIdMatrix [16];
  IGRshort 		nMatrixType;
  BSrc			rc;
  GRclassid 		ClassId;
  struct GRid 		PlanesId[VR_MAX_CPTS * 3];

  extern GRclassid OPP_VRHCComp_class_id; 
  extern GRclassid OPP_VRPCComp_class_id; 
  extern GRclassid OPP_VRRCComp_class_id; 

  *msg = MSSUCC;

  if (pCompId)
  {
	status =
	om$send( msg = message NDnode.NDs_compute_node ( msg, CnType, 
						         pMdEnv ),
		senderid = NULL_OBJID,
		targetid = pCompId->objid,
		targetos = pCompId->osnum );
	as$status(action = RET_STATUS);
  } /* end if */


  /*| Test Component ClassId */
  status = om$get_classid (	objid = pCompId->objid,
				osnum = pCompId->osnum,
			 	p_classid = &ClassId);
  as$status ();

  /*"Component ClassId = %d\n",ClassId */

  if( ClassId != OPP_VRPCComp_class_id &&
      ClassId != OPP_VRHCComp_class_id &&
      ClassId != OPP_VRRCComp_class_id )
  {
	/*| Non constraint component case */
	if( pCompSegDesc )
	{
		for (i=0;i<pCompSegDesc->NbSeg;i++)
		{
	    		if (pCompSegDesc->SegDesc [i].bChangeLength &&
			    pCompSegDesc->SegDesc [i].SegId.objid != NULL_OBJID)
			{
			/*| -- Send ChangeSegLength --- */
			status = 
			VRChangeSegLength (pCompSegDesc->SegDesc [i].SegType,
				    	   pCompSegDesc->SegDesc [i].Fitting,
				    	   &pCompSegDesc->SegDesc [i].SegId,
					   pMdEnv);
			as$status ();
			} /* end if */
	    	} /* end for */
	}/*end if pCompSegDesc */
	else
	{
		status = 
		om$send( msg = message VRGeneric.VRNotifyCorrections( msg, 0 ),
		 	 senderid = NULL_OBJID,
		 	 targetid = pCompId->objid,
		 	 targetos = pCompId->osnum );
		as$status();
	}
  }
  else
  {
	/*| Constraint component case */
	/*| Get planes on Cpt0 */
	status = om$send( msg = message VRGeneric.VRGetPlanesOnCpt ( msg,
					    			     0,
					    			     PlanesId,
					    			     pMdEnv),
			  senderid = NULL_OBJID,
			  targetid = pCompId->objid,
			  targetos = pCompId->osnum);
	as$status ();
	/*"Planes (%d,%d,%d)\n",PlanesId[0].objid,PlanesId[1].objid,PlanesId[2].objid*/

	MAidmx (msg, dIdMatrix);
	MAtypemx (&rc, dIdMatrix, &nMatrixType );

	for (i=0;i<3;i++)
	{
	    	/*"GRxform to Plane %d\n", PlanesId [i].objid */
	    	status = 
		om$send (msg = message GRgraphics.GRxform( msg, pMdEnv,
					    		   &nMatrixType,
					    		   dIdMatrix,
					    		   &PlanesId [i].objid),
			 senderid = NULL_OBJID,
			 targetid = PlanesId [i].objid,
			 targetos = PlanesId [i].osnum);
	    	as$status ();
	} /* end for */
  } /* end if */

return	OM_S_SUCCESS;

} /* end function VRUpdateGeometry */

/****************************************************************************/

VRBuildUserFromForm ( form_ptr, gadget_label, UserId, MissId )

IGRchar		*form_ptr;
IGRint		gadget_label;
struct 	GRid	*UserId;
struct 	GRid	*MissId;
/*.VRBuildUserFromForm */
{
  IGRchar		*UserNames [VR_MAX_ATTR], *EndNames;
  IGRchar		*UserValues [VR_MAX_ATTR];
  IGRint		i, row, len, len1;
  IGRint		r_pos, num_rows, num_param=0, sel_flag = 0;
  IGRint		status, UserIndex=0, MissIndex=0;
  IGRlong 		retcode;
  struct ACrg_coll 	UserCollection[VR_MAX_ATTR],
			MissCollection[VR_MAX_ATTR];
  struct ACrg_coll	Collection;
  IGRdouble 		dValue;

  SetProc( VRBuildUserFromForm ); Begin

  EndNames	= NULL ;
  for( i=0 ; i<VR_MAX_ATTR ; i++ ) UserNames[i] = NULL ;
  for( i=0 ; i<VR_MAX_ATTR ; i++ ) UserValues[i] = NULL ;

/*^ 
    if( UserId ) VRprint_user_attr (UserId);
    if( MissId ) VRprint_user_attr (MissId);
*/

FIfld_get_max_num_rows( form_ptr, gadget_label, &num_rows );
__DBGpr_int( " Nb. of rows ", num_rows );

/* First recover all lines in col0 and col1 */

for( row=0; row<num_rows; row++ )
    {
    len = len1 = 0;

    FIfld_get_text_length( form_ptr, gadget_label, row, 0, &len );
    __DBGpr_int( " Length of the text ", len );

    if( len >1 )
       {
	  FIfld_get_text_length( form_ptr, gadget_label, row, 1, &len1 );
	  __DBGpr_int( " Length of the value ", len1 );

	  /* changed the index variable from "row" -> "num_param". 
	  Alwin for TR179802158 */
	  UserNames [num_param] = _MALLOC( len+1, char );
	  UserValues[num_param] = _MALLOC( len1+1, char );

	  FIfld_get_text ( form_ptr, gadget_label, row, 0, len, 
			(unsigned char *) UserNames [num_param], 
			&sel_flag, &r_pos);
	  __DBGpr_str( " Attribute name ", UserNames[num_param] );

	  FIfld_get_text ( form_ptr, gadget_label, row, 1, len1, 
			(unsigned char *) UserValues [num_param], 
			&sel_flag, &r_pos);
	  __DBGpr_str( " Attribute value ", UserValues[num_param] );
	  num_param++;
	} /* end if */
    } /* end for */

#ifdef vdsDEBUG
 printf("number of param is %d\n", num_param );
 for( i=0; i<num_param; i++ )
 {
     printf("value of %s is %s\n", UserNames [i], UserValues [i] );
 }
#endif

/*| Build array of ACrg_coll */
for (i=0;i<num_param;i++)
    {
    	strcpy ( Collection.name , UserNames[i] ); 
	/*"attr name = %s\n", Collection.name */

	EndNames = NULL ;
    	dValue = strtod (UserValues [i], &EndNames);
    	if (strlen (EndNames) != 0) Collection.desc.type = AC_ATTRIB_TEXT;
    	else			    Collection.desc.type = AC_ATTRIB_DOUBLE;

  	if( UserId->objid != NULL_OBJID )
	{
    		status =
		om$send( msg = message ACrg_collect.ACget_named_attribute( &retcode, &Collection),
			 senderid = NULL_OBJID,
		     	 targetid = UserId->objid,
		    	 targetos = UserId->osnum );
	}

	if( MissId && MissId->objid != NULL_OBJID )
	{
		retcode=MSFAIL;
    		status =
		om$send( msg = message ACrg_collect.ACget_named_attribute( &retcode, &Collection),
			 senderid = NULL_OBJID,
		         targetid = MissId->objid,
		    	 targetos = MissId->osnum );
	}

	__DBGpr_str( " Attr Name ", Collection.name );
    	if( Collection.desc.type == AC_ATTRIB_TEXT )
	{
		strcpy( Collection.desc.value.att_txt, UserValues [i] );
		__DBGpr_str( " Attr text ", Collection.desc.value.att_txt );
	}
    	else
	{
		Collection.desc.value.att_exp = dValue;
		__DBGpr_dbl( " Attr Value ", Collection.desc.value.att_exp );
	}

    	if( !( MissId && MissId->objid != NULL_OBJID ) || !( retcode & 1 ) )
    	{
		/*| add attr in user collection */
		UserCollection[UserIndex] = Collection;
		UserIndex++;
    	}
    	else
    	{
		/*| add attr in miss collection */
		MissCollection[MissIndex] = Collection;
		MissIndex++;
    	}
    } /* end for */

retcode = MSSUCC;

if( UserId && UserId->objid != NULL_OBJID )
{
	status = 
  	VR$ModifyCollection( 	p_msg                   = &retcode,
                        	Operation               = VR_MERGE_COLL,
				p_ParamsListToModify    = UserCollection,
				NbParamsToModify	= UserIndex,
                        	p_OutputCollectionId    = UserId);
	CheckRC( status, retcode );
	/*^ VRprint_user_attr (UserId); */
}

if( MissId && MissId->objid != NULL_OBJID )
{
	__DBGpr_com( " Calling VR$ModifyCollection ... " );
	__DBGpr_int( " Nb. of Parameters to modify ", MissIndex );
	__DBGpr_obj( " Missing Collector Id ", *MissId );
	status = 
  	VR$ModifyCollection( 	p_msg                   = &retcode,
                        	Operation               = VR_UPDATE_COLL,
				p_ParamsListToModify    = MissCollection,
				NbParamsToModify	= MissIndex,
                        	p_OutputCollectionId    = MissId);
	CheckRC( status, retcode );
	/*^ VRprint_user_attr (MissId); */
}


wrapup:

	for( i=0 ; i<VR_MAX_ATTR ; i++ ) _FREE( UserValues[i] );
	for( i=0 ; i<VR_MAX_ATTR ; i++ ) _FREE( UserNames[i] );

	End
	return OM_S_SUCCESS;

} /* end function VRBuildUserFromForm */

/************************************************************************/
/* The aim of this function is to check whether a new component can be	*/
/* inserted or replaced.						*/

VRIsTopoCompatible ( 	IGRshort	nProduct,
			IGRshort	nTopoLocated,
			IGRshort	nTopoNew)
/*.VRIsTopoCompatible */
{
IGRint	ReturnFlag = FALSE;

if (nTopoLocated == nTopoNew)
    ReturnFlag = TRUE;
else
    {
    switch (nProduct)
	{
case VR_PIPING:
	if (nTopoLocated == VRP_V_OLET_TOPO && nTopoNew == VRP_V_3_WAYS_TOPO)
		ReturnFlag = TRUE | OLET_TO_TEE;
	if (nTopoNew == VRP_V_OLET_TOPO && nTopoLocated == VRP_V_3_WAYS_TOPO)
		ReturnFlag = TRUE | TEE_TO_OLET;
	break;
case VR_HVAC:
	if (nTopoLocated == VRH_V_OLET_TOPO && nTopoNew == VRH_V_3_WAYS_TOPO)
		ReturnFlag = TRUE | OLET_TO_TEE;
	if (nTopoNew == VRH_V_OLET_TOPO && nTopoLocated == VRH_V_3_WAYS_TOPO)
		ReturnFlag = TRUE | TEE_TO_OLET;
	break;
case VR_RWAY:
	if (nTopoLocated == VRR_V_OLET_TOPO && nTopoNew == VRR_V_3_WAYS_TOPO)
		ReturnFlag = TRUE | OLET_TO_TEE;
	if (nTopoNew == VRR_V_OLET_TOPO && nTopoLocated == VRR_V_3_WAYS_TOPO)
		ReturnFlag = TRUE | TEE_TO_OLET;
	break;
	} /* end switch */
    } /* end if */

return ReturnFlag;

} /* end function VRIsTopoCompatible */

/************************************************************************/
/* The aim of this function is to set the correction of replaced comp	*/
/* i.e splited if old component is an olet and newone is a tee,		*/
/* and merged is old one is a tee and newone is an olet.		*/

VRSpecialCorrectionProcessing ( msg, TopoReturnCode,
				SupportId, CompId, MdEnv )
IGRlong		*msg;
IGRint		TopoReturnCode;
struct	GRid	*SupportId;
struct	GRid	*CompId;
struct	GRmd_env	*MdEnv;
/*.VRSpecialCorrectionProcessing */
{
IGRlong		status;
struct GRid	CorId;

*msg = MSSUCC;

/*^
printf ("SupportId is <%d>, CompId is <%d>\n", SupportId->objid, CompId->objid);
*/

if (TopoReturnCode & OLET_TO_TEE)
    {
    /*| Olet to Tee Sending a compute to the transformed element */
    status = om$send (msg = message NDnode.NDs_compute_node ( 
					    msg, 
					    ND_COMP,
					    MdEnv ),
				    targetid = CompId->objid,
				    targetos = CompId->osnum,
				    senderid = NULL_OBJID );
    as$status ();
    as$status (sts = *msg);

    status = VR$SplitCorrection( p_retmsg	= msg,
				 p_SegId	= SupportId,
				 p_CmpId	= CompId,
				 p_MdEnv	= MdEnv );
    as$status ();
    as$status (sts = *msg);
    }
else
    if (TopoReturnCode & TEE_TO_OLET)
	{
	/*| Tee to Olet Treatement -> Merging Correction */
	status = VRGetCorrection( msg, SupportId, CompId,
			MdEnv, &CorId, NULL );
	as$status();
	as$status(sts = *msg);
	/*"CorrectionId got is %d\n", CorId.objid */

	/*| Sending a compute to the transformed element */
	status = om$send (msg = message NDnode.NDs_compute_node ( 
						msg, 
						ND_COMP,
						MdEnv ),
					targetid = CompId->objid,
					targetos = CompId->osnum,
					senderid = NULL_OBJID );
	as$status ();
	as$status (sts = *msg);

	status = om$send( msg      = message VRCorrection.VRMergeCorrection
					   ( msg, CompId, MdEnv ),
			senderid = NULL_OBJID,
			targetid = CorId.objid,
			targetos = CorId.osnum );
	as$status();
	as$status(sts = *msg);

	} /* end if TEE_TO_OLET */

return OM_S_SUCCESS;

} /* end function VRSpecialCorrectionProcessing */

/************************************************************************/
VRUndisplayComponent ( CompId, MdEnv )

struct GRid	*CompId;
struct GRmd_env *MdEnv;
/*.VRUndisplayComponent */
{
  IGRlong	status;

  if( CompId->objid == NULL_OBJID ) 	return OM_S_SUCCESS;
  status =
  om$send( msg = message	NDnode.NDdisplay ( 0, GRbehe, MdEnv),
		    senderid = NULL_OBJID,
		    targetid = CompId->objid,
		    targetos = CompId->osnum);
  as$status ();

  return OM_S_SUCCESS;

} /* end function VRUndisplayComponent */

/************************************************************************/

VRProcessingMessage ()
{

ex$message( field = ERROR_FIELD, in_buff = "Processing ...");

return OM_S_SUCCESS;

} /* end function VRProcessingMessage */

/************************************************************************/

VRBlankMessage ()
{

ex$message( field = ERROR_FIELD, in_buff = "");

return OM_S_SUCCESS;

} /* end function VRBlankMessage */

/************************************************************************/
/* This function forces depth value to width value if the shape of 	*/
/* param box is circular. Returns true if a modification has been	*/
/* made false otherwise. True might means that forms needs updating.	*/

VRCircularTreatment ( 	IGRshort	nProduct,
			struct GRid	*FormSysParamId,
			struct GRmd_env *MdEnv)
/*.CircularTreatment */
{
IGRlong			status, msg;
IGRint 			FootIndex = -1, retstatus, Shape, VStatus;
IGRdouble		dDepthG, dDepthR, dWidthG, dWidthR;
struct ret_struct	ParamAttr;
struct	ACrg_coll	Collection;

VStatus = FALSE;

switch (nProduct)
{
case VR_PIPING:
    /*| no circular process in piping */
    break;

case VR_HVAC:
case VR_RWAY:
    status = om$send( msg      = message ACncpx.ACgive_structure
			       ( &retstatus, &FootIndex, VR_N_SHAPE_IN,
				 &ParamAttr, MdEnv),
		    senderid = NULL_OBJID,
		    targetid = FormSysParamId->objid,
		    targetos = FormSysParamId->osnum );
    as$status ();
    Shape = (IGRint) ParamAttr.var.root_pm_st.value;
    /******
    printf ("Shape got from macro foot <%lf>\n",
			     ParamAttr.var.root_pm_st.value);
    ******/
    if (Shape == HCIRCLECODE)
    {
	/* Recover width value */
	status =
	om$send( msg      = message ACncpx.ACgive_structure
				   ( &retstatus, &FootIndex, VR_N_WIDTH1_DB,
				     &ParamAttr, MdEnv),
		senderid = NULL_OBJID,
		targetid = FormSysParamId->objid,
		targetos = FormSysParamId->osnum );
	as$status ();
	dWidthG = ParamAttr.var.root_pm_st.value;
	status = om$send( msg      = message ACncpx.ACgive_structure
				   ( &retstatus, &FootIndex, VR_N_DEPTH1_DB,
				     &ParamAttr, MdEnv),
			senderid = NULL_OBJID,
			targetid = FormSysParamId->objid,
			targetos = FormSysParamId->osnum );
	as$status ();

	dDepthG = ParamAttr.var.root_pm_st.value;
        /*** != between doubles tr179900985 ****/
        if (fabs(dWidthG - dDepthG) > VRGetTol(VR_DIST_TOL));
	{
		dDepthG = dWidthG;
		strcpy ( Collection.name , VR_N_DEPTH1_DB ); 
	    	Collection.desc.type = AC_ATTRIB_DOUBLE;
	    	Collection.desc.value.att_exp =  dDepthG;
	    	status = VRUpdateParameterBox( &msg, &Collection, FormSysParamId);
	    	as$status ();
		VStatus = TRUE;
	}

	status =
	om$send( msg      = message ACncpx.ACgive_structure
				   ( &retstatus, &FootIndex, VR_N_WIDTH2_DB,
				     &ParamAttr, MdEnv),
		senderid = NULL_OBJID,
		targetid = FormSysParamId->objid,
		targetos = FormSysParamId->osnum );
	as$status ();

	dWidthR = ParamAttr.var.root_pm_st.value;

	status = om$send( msg      = message ACncpx.ACgive_structure
				   ( &retstatus, &FootIndex, VR_N_DEPTH2_DB,
				     &ParamAttr, MdEnv),
			senderid = NULL_OBJID,
			targetid = FormSysParamId->objid,
			targetos = FormSysParamId->osnum );
	as$status ();

	dDepthR = ParamAttr.var.root_pm_st.value;

        /*** != between doubles tr179900985 ****/
        if (fabs(dWidthR - dDepthR) > VRGetTol(VR_DIST_TOL));
	{
		/*"Forcing dDepthR to %lf instead of %lf\n", dWidthR, dDepthR */
		dDepthR = dWidthR;
		strcpy ( Collection.name , VR_N_DEPTH2_DB ); 
		Collection.desc.type = AC_ATTRIB_DOUBLE;
		Collection.desc.value.att_exp =  dDepthR;
		status = VRUpdateParameterBox( &msg, &Collection, FormSysParamId);
		as$status ();
	    	VStatus = TRUE;
	}
    } /* end if circular case */

} /* end switch */

return VStatus;

} /* end function VRCircularTreatment */

/*****************************************************************************/

VRUpgradeUserForm( form_ptr, NbColl, CollId, gadget_label )

IGRchar		*form_ptr;
IGRint		NbColl;
struct	GRid	*CollId;
IGRint		gadget_label;
{
  IGRchar			tmp_txt[MAX_FIELD];
  IGRint			i, init_row, user_numb, col=0;
  IGRint			row, sel_flag=0;
  IGRlong			status, retcode;
  struct	ACrg_coll	user_attributes[VR_MAX_ATTR];

  if( !form_ptr || !CollId || !NbColl ) return OM_E_INVARG;

  /*"NbColl = %d\n", NbColl */

  FIg_reset( form_ptr, gadget_label );
  FIfld_set_max_num_rows( form_ptr, gadget_label, VR_MAX_ATTR );

  for( i=0, init_row=0; i<NbColl; i++ )
  {
	/*"CollId[%d] = %d \n",i,CollId[i].objid*/
  	status =
	om$send( msg      = message ACrg_collect.AClist_attribute
                               		(	&retcode, VR_MAX_ATTR, 
						user_attributes, &user_numb ),
		 senderid = NULL_OBJID,
		 targetid = CollId[i].objid,
		 targetos = CollId[i].osnum );
  	as$status( action = RET_STATUS );

  	for ( row=0; row< user_numb; row++, init_row++ )
  	{
    		FIfld_set_text
    		( form_ptr, gadget_label, init_row, col, user_attributes[row].name, sel_flag );
                   
    		if( user_attributes[row].desc.type == AC_ATTRIB_DOUBLE )
    		{
      			/*|type is AC_ATTRIB_DOUBLE */
		    /* Changed format specifier from %f to %.15lg - TR 5098 */
      			sprintf( tmp_txt, "%.15lg", user_attributes[row].desc.value.att_exp ); 
      			FIfld_set_text(  form_ptr, gadget_label, init_row, 1, tmp_txt, sel_flag );
    		}
    		else
    		{
      			FIfld_set_text
      			( form_ptr, gadget_label, init_row, 1, user_attributes[row].desc.value.att_txt,
			  sel_flag
      			);
    		}
  	}
  }

  return OM_S_SUCCESS;
}

/*****************************************************************************/

VRGetOptionCode( retmsg, AABBCCcode, ParamId, gadget_label, FormPtr, MdEnv)

IGRlong		*retmsg;
IGRchar		*AABBCCcode;
struct	GRid	*ParamId;
IGRint		gadget_label;
IGRchar		*FormPtr;
struct GRmd_env *MdEnv;
{
  IGRlong		status=1, retstatus;
  IGRint		rc;
  struct ret_struct	ParamAttr;
  IGRint 		i,FootIndex = -1;
  IGRdouble		size_g, size_r;
  IGRchar		specname[15], Error[300];
  /* Second dimension of 'optcodes' below changed from 16 to 81 by Anand */
  IGRchar		optcodes[VR_MAX_OPTCODE_SIZE][81];
  IGRshort    		*opt_codes;
  IGRchar     		*opt_txt;
  IGRshort    		opt_cnt;

  SetProc( VRGetOptionCode ); Begin

  Error[0] = 0;
  /*"ParamId = %d %d\n",ParamId->objid, ParamId->osnum*/
  *retmsg = MSSUCC;
  opt_codes	= NULL ;
  opt_txt	= NULL ;

  status = 
  om$send( msg      = message ACncpx.ACgive_structure(  &rc,
							&FootIndex,
							VR_N_GDIAMETER_DB, 
							&ParamAttr, 
							MdEnv),
	   senderid = NULL_OBJID,
	   targetid = ParamId->objid,
	   targetos = ParamId->osnum );
  if( status&1 )
	size_g	= ParamAttr.var.root_pm_st.value;
  else
  {
 	*retmsg = MSFAIL;
	return *retmsg;
  }

  status = 
  om$send( msg      = message ACncpx.ACgive_structure( 	&rc,
							&FootIndex,
							VR_N_RDIAMETER_DB, 
							&ParamAttr, 
							MdEnv),
	   senderid = NULL_OBJID,
	   targetid = ParamId->objid,
	   targetos = ParamId->osnum );
  if( status&1 )
	size_r	= ParamAttr.var.root_pm_st.value;
  else
  {
	*retmsg = MSFAIL;
	return *retmsg;
  }

  status =
  om$send( msg      = message ACncpx.ACgive_structure(  &rc,
							&FootIndex, 
							VR_N_CLASS_AN,
			     				&ParamAttr, 
							MdEnv),
	   senderid = NULL_OBJID,
	   targetid = ParamId->objid,
	   targetos = ParamId->osnum );
  if( status&1 )
	strcpy( specname,ParamAttr.var.text_st.text_string);
  else
  {
	*retmsg = MSFAIL;
	return *retmsg;
  }

  status = VRget_opt_code_txt ( &retstatus, VR_PIPING, AABBCCcode, 
				specname, size_g, size_r, &opt_codes, 
				&opt_txt, &opt_cnt, NULL);

  /* -- build the list of texts corresponding to the option codes -- */
  if( status&1 )
  {
    /** TR-MP4140 increase opt code to 80 characters **/
    IGRboolean 	bOptCodeExisting = FALSE;
    IGRchar	szOptCode[81];

    FIg_get_text( FormPtr, gadget_label, szOptCode );

    FIfld_set_list_num_rows( FormPtr, gadget_label, 0, opt_cnt);
    for( i=0; i< opt_cnt; i++ )
    {
      IGRlong	msg;
      IGRchar	p_error[30];
    
      /*** TR-MP4140 initialize o_lname ***/
      optcodes[i][0] = '\0'; 

      status = vd$get_alias ( p_msg	= &msg,
		    	       product	= PIPING,
		    	       type	= VR_OPTCODE_LIST_NUM,
		               i_code	= (IGRint) opt_codes[i],
		    	       o_lname	=  optcodes[i],
		    	       p_error	= p_error	);

      /* -- display the opt code if no short desc is available -- */
      if ( !strlen( optcodes[i]) )
        sprintf( optcodes[i], "%d", opt_codes[i] );

      // for ETL2780. Alwin
      if( !strcmp(szOptCode, optcodes[i]) ) bOptCodeExisting = TRUE;
    }

    /* Below lines added by Anand for CR 179902073 */
    /* corrected by law 28Nov2000 */
//    qsort( optcodes, VR_MAX_OPTCODE_SIZE, 81, strcmp );
    qsort( optcodes, opt_cnt, 81, strcmp );
    for( i=0 ; i<opt_cnt ; i++ )
	VDfld_set_list_text( FormPtr, gadget_label, i, 0, optcodes[i], FALSE);
    /* Above lines added by Anand for CR 179902073 */

    if( bOptCodeExisting == FALSE )
	FIg_set_text( FormPtr, gadget_label, "" );
  }

  /*
   * VRget _opt_code_txt used static list.
   */
  opt_codes	= NULL ;
  opt_txt	= NULL ;
  End
  return OM_S_SUCCESS;
}
end implementation VRCOProduct;
