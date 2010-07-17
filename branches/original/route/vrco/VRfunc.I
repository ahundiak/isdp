/* $Id: VRfunc.I,v 1.3 2002/04/10 15:04:38 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco / VRfunc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRfunc.I,v $
 *	Revision 1.3  2002/04/10 15:04:38  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.2  2001/01/22 17:44:04  anand
 *	Merged func.I into VRfunc.I
 *	func.I is therefore redundant in vrco directory.
 *	It's entry has been removed from the vrco.m file.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
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
# Revision 1.2  1996/01/16  21:27:48  pinnacle
# Replaced: vrco/VRfunc.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/15/96	tlb	Add prototypes
 *	01/22/01   Anand	Merged func.I to this file.
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/
class implementation VRCmpMgr;

%safe
#include <math.h>
%endsafe

#include <string.h>
#include "bserr.h"
#include "VRMath.h"
#include "VRattr_def.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRDbParamDef.h"
#include "VRdimdef.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "VRstructs.h"
#include "vrtools_pto.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "maunitvc.h"

	/* Below include files reqd by function VRUpdOrAddAttr which was
	 * originally implemented in func.I - now merged with this file. */
#include "OMlimits.h"
#include "OMminimum.h"
#include "gr.h"
#include "igrdef.h"
#include "godef.h"
#include "go.h"
#include "MS.h"
#include "msdef.h"
#include <stdio.h>
#include <stdlib.h>
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "AS_status.h"

from	ACrg_collect	import	ACmod_list_attribute;
from	ACrg_collect	import	AClist_attribute;
from	ACrg_collect	import	ACadd_list_attribute;
	/* Above from-import statements reqd by function VRUpdOrAddAttr which
	 * was originally implemented in func.I - now merged with this file. */

from	NDmacro		import	ACgive_structure;
from	VRGeneric	import	VRGetCompDesc, VRGetTopo, VRGetSupports,
			VRGetSupOnCpt, VRGetCptGeom,VRGetCptOnSup,
			VRGetInstance, VRSetInstance ;

#define AS_DEBUG	

/*****************************************************************************

		    VRTestCmpPosition	:
		    ---------------------
		    Test if the position of a component is compatible
		    with its previous topology ( supports )
		
			- CmpId					( I )
			- Supports direction array		( I )

*******************************************************************************/
IGRint	VRTestCmpPosition( CmpId, NbCpts, NbSupports, SupDirection, Flag, MdEnv)

struct GRid 	*CmpId;
IGRint 		NbCpts;
IGRint 		NbSupports;
IGRdouble 	*SupDirection;
IGRboolean	*Flag;
struct GRmd_env *MdEnv;

/*.VRTestCmpPosition */
{
  IGRint	i, j;
  IGRlong	status,retcode;
  IGRdouble	CmpDirection[3*VR_MAX_CPTS];
  IGRmatrix	Matrix;
  IGRboolean	Result[VR_MAX_CPTS];

  *Flag	 = TRUE;

  /* -- Initialize array of result to False -- */
  for( i=0; i<NbSupports; i++ )	Result[i] = FALSE;

  /* --- Take direction of each cpt --- */
  for( i=0; i<NbCpts; i++ )
  {
	status = VR$GetMatrix ( p_msg	      = &retcode,
                          	p_ComponentId = CmpId ,
			  	CompCpt	      = i,
		          	p_Matrix      = Matrix,
                          	p_MdEnv	      = MdEnv);
	as$status();

	CmpDirection[3*i]     = Matrix[0];
	CmpDirection[(3*i)+1] = Matrix[4];
	CmpDirection[(3*i)+2] = Matrix[8];
  }

  /* ---- See if one of the cpt as the same direction as the support ---- */
  for( i=0; i<NbSupports; i++ )
  {
	for( j=0; j<NbCpts; j++ )
	{
		/* -- To match vectors must be opposite -- */
		Result[i] = bVRTestVect( &retcode, &SupDirection[3*i], 
					 &CmpDirection[3*j], VR_OPPOSITE );
		if( Result[i] == TRUE )	j = NbCpts;
	}
  }

  /* -- Set final result to false if one of the support doesn't match -- */
  for( i=0; i<NbSupports; i++ )
  {
	if( Result[i] == FALSE )	*Flag = FALSE;
  }		

  return OM_S_SUCCESS;

}


/*******************************************************************************/    
IGRint VRGetCmpInfo ( msg, szCode, szNumber, szNotes, nOption, CmpId, MdEnv )
			       
IGRlong 		*msg ;		/* O : Return code, MSSUCC or MSFAIL.   */
IGRchar			*szCode;	/* O : code of Cmpid 			*/
IGRchar			*szNumber;	/* O : Number of CmpId 			*/
IGRchar			*szNotes;	/* O : Notes  of CmpId 			*/
IGRshort		*nOption;	/* O : Option code of component 	*/
struct  GRid		*CmpId;		/* I : GRid of component		*/
struct  GRmd_env	*MdEnv;		/* I : Module Env of component		*/
 
/*.VRGetCmpInfo */ 
{
  IGRint 		FootIndex = -1, retstatus;
  IGRlong 		status;
  struct ret_struct 	ParamAttr;

  *msg = MSSUCC;

	status =
	om$send( msg      = message  NDmacro.ACgive_structure(
			&retstatus, &FootIndex,	VR_N_COMP_CODE_AN,
			&ParamAttr, MdEnv),
		senderid = NULL_OBJID,
		targetid = CmpId->objid,
		targetos = CmpId->osnum );

	strcpy( szCode,ParamAttr.var.text_st.text_string);

	status =
	om$send( msg      = message NDmacro.ACgive_structure(
			&retstatus, &FootIndex, VR_N_OPTION_IN,
			&ParamAttr, MdEnv),
		senderid = NULL_OBJID,
		targetid = CmpId->objid,
		targetos = CmpId->osnum );
	*nOption = (IGRshort) ParamAttr.var.root_pm_st.value;

	status =
	om$send( msg      = message NDmacro.ACgive_structure(
			&retstatus, &FootIndex, VR_N_COMP_NOTE_AN,
			&ParamAttr, MdEnv),
		senderid = NULL_OBJID,
		targetid = CmpId->objid,
		targetos = CmpId->osnum );
	strcpy( szNotes,ParamAttr.var.text_st.text_string);

	status =
	om$send( msg      = message NDmacro.ACgive_structure(
			&retstatus, &FootIndex, VR_N_TAG_NUMBER_AN,
			&ParamAttr, MdEnv),
		senderid = NULL_OBJID,
		targetid = CmpId->objid,
		targetos = CmpId->osnum );
	strcpy( szNumber,ParamAttr.var.text_st.text_string);

  return OM_S_SUCCESS;

}

/* ====================================================================	*/
/* This function retrieves CompType of Component.		*/

IGRint VRGetCmpType ( msg , nCompType, CompId , MdEnv )
IGRlong 	*msg;
IGRshort 	*nCompType;
struct GRid	*CompId;
struct GRmd_env *MdEnv;
/*.VRGetCmpType */
{
  struct	ACrg_coll	Collection;
  IGRlong 	status;
 
  *msg = MSSUCC;

  /*"CompId is %d\n", CompId->objid */

  strcpy ( Collection.name , VR_N_COMP_TYPE_IN ); 
  Collection.desc.type = AC_ATTRIB_DOUBLE;
  status = om$send( msg      = message VRGeneric.VRGetCompDesc(msg, &Collection, MdEnv),
		    senderid = NULL_OBJID,
		    targetid = CompId->objid,
		    targetos = CompId->osnum );
  as$status();
  as$status (sts = *msg);

  *nCompType = (IGRshort) Collection.desc.value.att_exp;
  /*^
  printf ("*nCompType is %d\n",*nCompType);
  */

return OM_S_SUCCESS;

} /* end function VRGetCmpType */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 CHANGE HISTORY:  Manyam 1-Jun-1993 : Design date


 DESCRIPTION  : This function finds out whether the given component is 
		rotatable or not. Returns 1 if orientable, 0 if not.

 OBJECTIVE    : To find out whether the given comp has non-colinear supports
		or not.
		
		Component can reoriented if it has Colinear supports
		otherwise not.

 		Algorithm :
		*. Get the No of Cpts and Supports of the Cmp
	        *. Get the Rot Axis of the Cmp.
		*. if ( No of Supports <= 1 ) 
			Cmp can be reoriented
		   else
		   *. For each Cpt of the Cmp which has Support
			- take first Cpt as Ref Pt.
			- find vector from Ref Pt to Cpt.
			- find the angle between Rot Axis and this vector.
			- Cmp can be reoriented if the angle is 0 or 180
			  otherwise not
					
/*******************************************************************************/    
IGRint VRIsCmpOrientable ( pMsg, pCmpId, pRotAxis, pMdEnv )
			       
IGRlong 		*pMsg ;		/* O : Return code, MSSUCC or MSFAIL.   */
struct  GRid		*pCmpId;	/* I : GRid of component		*/
IGRdouble		*pRotAxis;	/* O : RotAxis of the Comp		*/
struct  GRmd_env	*pMdEnv;	/* I : Module Env of component		*/
/* VRIsCmpOrientable*/ 
{
  struct GRid		SupIds[VR_MAX_CPTS], SupportId;
  IGRint		NbSupports = 0, i, NbCpts;
  IGRdouble		dCmpOrigin[3], dRotAxis[3];
  IGRshort		nCptNum = -1, nCptOnSup;
  IGRlong		status, retmsg;

  *pMsg	= MSSUCC;

  /* --  Get the nb of connect points of the specified component -- */
  status = om$send( msg     = message VRGeneric.VRGetTopo( &retmsg, VR_MAX_CPTS,
		    			&NbCpts, dCmpOrigin, (IGRdouble *) NULL,
		    			(struct GRid *) NULL, (IGRshort *) NULL, pMdEnv),
			  senderid = NULL_OBJID,
	    		  targetid = pCmpId->objid,
	    		  targetos = pCmpId->osnum);
  as$status ();
  as$status( sts = retmsg );
  
  /* "NbCpts = %d \n", NbCpts */

  /* -- Get the component support information -- */
  status = 
  om$send ( msg      = message VRGeneric.VRGetSupports ( &retmsg, VR_MAX_CPTS, 
							 SupIds, &NbSupports),
	    		senderid = NULL_OBJID,
	    		targetid = pCmpId->objid,
	    		targetos = pCmpId->osnum );
  as$status ();
  as$status( sts = retmsg );

  /*"Nb supports = %d \n", NbSupports */

  /* -- Get the first connect point of the component which has support-- */
  SupportId.objid = NULL_OBJID;

  if ( NbSupports )
    for( i=0; i<NbCpts; i++ )
    {
      status = om$send ( msg     = message VRGeneric.VRGetSupOnCpt( &retmsg, i, &SupportId,
						             pMdEnv ),
	    		senderid = NULL_OBJID,
		  	targetid = pCmpId->objid,
	          	targetos = pCmpId->osnum );
      as$status ();

      /* -- this will be Cpt for getting the rotation axis -- */
      if ( SupportId.objid != NULL_OBJID )
      {
        nCptNum = i;
        break;
      }
    }	
  else return TRUE;

  if ( nCptNum != -1 ) 
  {
    /* -- Get the axis of rotation -- */
    status = om$send ( msg     = message VRGeneric.VRGetCptGeom( &retmsg, nCptNum,
					NULL, dRotAxis, NULL, pMdEnv),
	    		senderid = NULL_OBJID,
			targetid = pCmpId->objid,
	             	targetos = pCmpId->osnum );
    as$status ();
    as$status( sts = retmsg );

    if ( pRotAxis ) 
	for ( i=0; i<3; i++ ) pRotAxis[i] = dRotAxis[i];

    /* "dRotAxis[%d] = %f dRotAxis[%d] = %f dRotAxis[%d] = %f \n",
		0, dRotAxis[0], 1, dRotAxis[1], 2, dRotAxis[2]*/
     
    /* -- return TRUE if the num of supports is equal to one -- */
    if ( NbSupports <= 1 ) return TRUE;
    else 
    {
      for( i=0; i<NbSupports; i++ )
      {
        int	j;
        BSrc	bsretcode;
        double 	dTmpVect[3], dDotp, dCptCoord[3], dRefPt[3];

        status = om$send ( msg     = message VRGeneric.VRGetCptOnSup( &retmsg, 
					&SupIds[i], &nCptOnSup, pMdEnv ),
	    		senderid = NULL_OBJID,
		     	targetid = pCmpId->objid,
	             	targetos = pCmpId->osnum );
        as$status ();
        as$status( sts = retmsg );

	/* -- Get Cpt vector -- */
	/* -- don't get the vector but get the coordinates -- */
        status = om$send ( msg     = message VRGeneric.VRGetCptGeom( 
			&retmsg, nCptOnSup, dCptCoord, NULL, NULL, pMdEnv),
	    		senderid = NULL_OBJID,
			targetid = pCmpId->objid,
	             	targetos = pCmpId->osnum );
        as$status ();
        as$status( sts = retmsg );

        /*"dCptCoord[%d] = %f dCptCoord[%d] = %f dCptCoord[%d] = %f \n",
		0, dCptCoord[0], 1, dCptCoord[1], 2, dCptCoord[2] */

	/* -- Take the first Cpt as Ref pt -- */      
        if ( i== 0 ) for ( j=0; j<3; j++ ) dRefPt[j] = dCptCoord[j];

        /* -- don't do for the first one -- */
        if ( i )	
        {
          /* -- make a vector from the ref pnt to the current connect pnt -- */
          BSmkvec( &bsretcode, dTmpVect, dRefPt, dCptCoord) ;
	
	  /* -- Get the unit vector -- */
	  MAunitvc( &retmsg, dTmpVect, dTmpVect );

	  /*for ( j=0; j<3; j++ ) printf( "dTmpVect[%d] = %f \n", j, dTmpVect[j] ); */

	  /* -- Get the dot product of the rot axis and TmpVect -- */
    	  dDotp = BSdotp(&retmsg, dRotAxis, dTmpVect);
          /* "dDotp = %f \n", dDotp */

	  /* -- Cmp is orientable if the angle is 0 or 180 degrees -- */
	  if ( fabs( 1 - fabs( dDotp ) ) < VRGetTol(VR_ANGULAR_TOL) ) ;
	  else return FALSE;
        }
      }
    }
  } else *pMsg = MSFAIL;

  return TRUE;
 
}

IGRint	VRResetTagNum( CmpId )
	struct	GRid	*CmpId;
{
	IGRint			status=OM_S_SUCCESS;
	IGRlong			retmsg;
	struct	VRGenInfo	Instance;

	/*A validate the args*/
	if ( !CmpId || CmpId->objid == NULL_OBJID )
		return OM_E_INVARG;

	/*A get the instance of the old component that is 
	    going to be deleted	*/
  	status = 
	om$send ( msg      = message VRGeneric.VRGetInstance( 
			&retmsg, &Instance),
		  senderid = NULL_OBJID,
		  targetid = CmpId->objid,
		  targetos = CmpId->osnum);
  	as$status ( action = RET_STATUS );
	
	/*A set the tag number to -1 */
	strcpy(Instance.szNumber, "-1" );

	/*A set the new instance in to the object that is going to
	    be deleted */
  	status = 
	om$send ( msg      = message VRGeneric.VRSetInstance( 
			&retmsg, &Instance),
		  senderid = NULL_OBJID,
		  targetid = CmpId->objid,
		  targetos = CmpId->osnum);
  	as$status ( action = RET_STATUS );

	return OM_S_SUCCESS;
}

/****************************************************************************/

/* Below function was originally implemented in func.I - now merged in this
 * file - Anand (Jan 2001) */

VRUpdOrAddAttr ( CollId, SysId, UserId, MissId )

struct 	GRid		*CollId;
struct 	GRid		*SysId;
struct 	GRid		*UserId;
struct 	GRid		*MissId;
/*.VRUpdOrAddAttr */
{
  IGRlong			msg, status;
  IGRint			i, NbParam;
  IGRint			NbAttrMod=1;
  struct	ACrg_coll 	attribute[VR_MAX_ATTR];

  msg    = MSSUCC;

  if( CollId->objid == NULL_OBJID )	return	OM_E_INVARG;

  /* --- List the collection --- */
  status =
  om$send( msg      = message ACrg_collect.AClist_attribute( &msg,
				VR_MAX_ATTR, attribute, &NbParam ),
		 senderid = CollId->objid,
                 targetid = CollId->objid,
                 targetos = CollId->osnum) ;
  as$status() ;

  /*"NbParam = %d \n",NbParam */
  
  /*| --- For each param try to update first collection --- */
  for( i=0; i<NbParam;)
  {
	msg = 0;
	/*"Attr name = <%s> \n",attribute[i].name*/
	status = 
	om$send( msg      = message ACrg_collect.ACmod_list_attribute
                                       	( &msg, NbAttrMod, &attribute[i] ),
                 senderid = SysId->objid,
                 targetid = SysId->objid,
                 targetos = SysId->osnum);
  	as$status();

	if( msg != MSFAIL )	i += 1;
	else
	{
  		/*| --- Param was not in first coll so try in second one --- */
  		status = 
		om$send( msg      = message ACrg_collect.ACmod_list_attribute
                                       	( &msg, NbAttrMod, &attribute[i] ),
                 	 senderid = UserId->objid,
                 	 targetid = UserId->objid,
                 	 targetos = UserId->osnum);
  		as$status();

		if ( msg != MSFAIL ) i += 1;
		else
		{
  			/*| --- Not in first nor in second so add it in third one --- */
			if( MissId->objid != NULL_OBJID )
			{
  				status = 
				om$send( msg      = message ACrg_collect.ACadd_list_attribute
                                       	     ( &msg, NbAttrMod, &attribute[i] ),
                    		 	 senderid = MissId->objid,
                    		 	 targetid = MissId->objid,
                    		 	 targetos = MissId->osnum );
  				as$status();
			}
			else
			{
				/* --- Create collection with the parameter --- */
				status = 
				VR$ModifyCollection( 
						p_msg                = &msg,
                                		Operation            = VR_MERGE_COLL,
						p_ParamsListToModify = &attribute[i],
         					NbParamsToModify     = NbAttrMod,
                                		p_OutputCollectionId = MissId );
  				as$status();
			}
			i += 1;
		}
	}	
  }

  return OM_S_SUCCESS;

} /* end VRUpdOrAddAttr */


end implementation VRCmpMgr;
