/* $Id: VREval.I,v 1.6 2002/05/28 19:14:32 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VREval.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VREval.I,v $
 *	Revision 1.6  2002/05/28 19:14:32  louis
 *	TR5888-component flipping on replace
 *	
 *	Revision 1.5  2002/04/10 20:44:45  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.4  2001/05/11 21:56:41  louis
 *	TR3303 - HOSE component sometimes incorrectly being constructed as a VRPComp.
 *	
 *	Revision 1.3  2001/02/20 01:17:42  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:17  anand
 *	SP merge
 *	
# Revision 1.1  2000/05/24  01:31:54  pinnacle
# Created: route/vrtools/VREval.I by lawaddel for Service Pack
#
# Revision 1.2  2000/02/21  20:52:08  pinnacle
# Replaced: vrtools/VREval.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/07/17  19:13:02  pinnacle
# Replaced: vrtools/VREval.I for:  by r250_int for route
#
# Revision 1.5  1997/07/07  22:07:46  pinnacle
# Replaced: vrtools/VREval.I for:  by yzhu for route
#
# Revision 1.4  1997/03/05  18:07:18  pinnacle
# Replaced: vrtools/VREval.I for:  by hverstee for route
#
# Revision 1.3  1997/03/03  18:39:06  pinnacle
# Replaced: vrtools/VREval.I for:  by r241_int for route
#
# Revision 1.2  1997/02/28  11:06:18  pinnacle
# Replaced: vrtools/VREval.I for:  by apazhani for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/04/05  14:01:14  pinnacle
# Replaced: vrtools/VREval.I for:  by r240_int for route240
#
# Revision 1.5  1996/04/04  18:49:24  pinnacle
# Replaced: vrtools/VREval.I for:  by ashankar for route240
#
# Revision 1.4  1996/04/04  16:17:08  pinnacle
# Replaced: vrtools/VREval.I for:  by ashankar for route240
#
# Revision 1.3  1996/04/04  15:06:54  pinnacle
# Replaced: vrtools/VREval.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/18  00:30:20  pinnacle
# Replaced: vrtools/VREval.I for:  by r240_int for route240
#
 *
 * History:
	01/17/96   tlb	Add prototypes
	07/07/97   yzhu	use VDsetAttDrSymb
	05/11/01   law  TR3303-HOSE component gets constructed as a VRPComp
                        with some combinations of parameters
 *      04/08/02   law  TR5649-standardize tolerance with VRGetTol
 *      05/28/02   law  a few debug prints
 *************************************************************************/
/*************************************************************/
/*	File 	: VREval.I
/*	Author	: B Demars ( ISDC, Paris )
/*	Date	: 21-DEC-91 Route release 1.4.3.17
/*
/*	* 07-JAN-92	1.4.3.18
/*		Bruno
/*		Implemente treatment when the component
/*		to evaluate already exists.
/*	  05-SEP-92
/*		Mallik
/*		Modified to read routeattr.symb for attribute driven symbology.
/*		YSL requirement.
/*        18 Feb 2000
/*              LAW
/*              TR179900985- Correct transition shape not stored in collection.
/*
/*************************************************************/

class implementation Root;


#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "igr.h"
#include "msdef.h"
#include "msmacros.h"
#include <stdio.h>
#include "VRdef.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRcompdef.h"
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRDbStruct.h"
#include "ACattrib.h"
#include "bstypes.h"
#include "bslenvec.h"
#include "ACrg_collect.h"
#include "vrparameters.h"      /* TR179900985 */
#include "VRMath.h"
#include "vdattmacros.h"                /* vd$get_attr_symbology        */
#include "vrdbgmacros.h"                
#include "vddgndef.h"
#include "v_drw.h"

#include "AS_status.h"
#include "vrtools_pto.h"
#include "VDmem.h"
#define AS_DEBUG

/*-------------------------------------------------------------------*/
/*	function VREvaluate
/*
/* 
/* Given the component description attributes, it evaluates this component
/* and returns it geometric description.
/*
/* This function returns 	MSSUCC if specified connect point is free.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

extern GRclassid	OPP_VRPComp_class_id,
			OPP_VRPCComp_class_id,
			OPP_VRHComp_class_id,
			OPP_VRHCComp_class_id,
			OPP_VRRComp_class_id,
			OPP_VRRCComp_class_id;

from VRGeneric	import	VREvaluate,
			VRGetOrigCoor,
			VRGetCptGeom;
from GRgraphics	import	GRdelete;
from GRvg	import	GRputsymb;
from VDSroot    import  VDgetAttrDrivenSymb;

/* Internal buffer storing the missing parameters of evaluated component */
IGRint VREvaluateCmp(	p_msg, Product, AABBCCcode, ItemNum, Status, Angle, 
			Number, Notes, NoMtoFlag, p_Option, Symbology,
			Representation, p_Type, p_NbCpts, p_SysParamId, 
			p_UsrParamId, p_MissParamId, p_ComponentId, 
			p_NbMissParams, p_AddrMissingss, p_MdEnv )
			       
IGRlong	*p_msg ;	   /* O : Return code, MSSUCC or MSFAIL.   */
IGRint	Product;	   /* I : Product the component belongs to */
IGRchar	*AABBCCcode;	   /* I : AABBCC code of the component     */
IGRshort ItemNum;	   /* I : ItemNum of the component         */
IGRshort Status;	   /* I : Component status       	   */
IGRdouble	Angle;
IGRchar		*Number;	   /* I : Number of the component          */
IGRchar		*Notes;		   /* I : Notes of the component           */
IGRchar		NoMtoFlag;	   /* I : Component Mto Flag 		*/
IGRshort	*p_Option;	   /* I : option code of the component     */
struct GRsymbology *Symbology;	   /* I : symbology		       */
IGRchar		Representation;	   /* I : Representation	       */
IGRint		*p_Type;	   /* O : TYpe of the evaluated component  */
IGRint		*p_NbCpts;	   /* O : Nb of Cpts of the evaluated comp */
struct GRid	*p_SysParamId,     /* I : Active parameters.               */
		*p_UsrParamId,     /* I : User parameters.                 */
		*p_MissParamId ;   /* I : Missing parameters.              */
struct GRid	*p_ComponentId ;   /* I : Component to evaluate.           */
IGRint		*p_NbMissParams;   /* I : Number of missing parameters */
struct ACrg_coll **p_AddrMissingss; /* I/O : Returns the pointer to the static 
				       array containing the missing parameters
						description */
struct GRmd_env 	*p_MdEnv ; 
/*.VREvaluateCmp */
{
	IGRint			status,
				NbMissingTemp = 0;
	IGRlong			retmsg;
	IGRchar			*SimpleClassName,
				*ComplexClassName;
	IGRchar 		**MissingNames ;
	struct ret_struct	*MissingStr ;
	IGRboolean		bIsNew;
	GRclassid		CompClass, 	/* Component Class Id */
				SimpleClass,
				ComplexClass;
	struct VRGenInfo        Instance;
	struct GRid		GraphicId;		
        /*  following are used by vd$get_att_symbology */
        IGRchar                 filename[DI_PATH_MAX];
  	long                    msg;
  	struct GRid             collId; /* for symbology collector */
  	VD_drwOutputData        *output = NULL;
/**** Relocated for service pack with TR3303 ***/
%safe
static	IGRint			StatMissingSize = 0;
static	struct ACrg_coll 	*StatMissings = NULL;
%endsafe

        SetProc ( VREvaluateCmp ); Begin
	GraphicId.objid = NULL_OBJID;
	GraphicId.osnum = p_MdEnv->md_id.osnum;

	/*" Objectid %d specified for evaluation\n", p_ComponentId->objid */

	bIsNew = (p_ComponentId->objid == NULL_OBJID);

	/* -- Initialize component class to the more frequent class used -- */
	switch (Product)
	{
	case VR_PIPING :
		SimpleClass 		= OPP_VRPComp_class_id;
		ComplexClass 		= OPP_VRPCComp_class_id;
		SimpleClassName 	= "VRPComp";
		ComplexClassName 	= "VRPCComp";
		break;
	case VR_HVAC :
		SimpleClass 		= OPP_VRHComp_class_id;
		ComplexClass 		= OPP_VRHCComp_class_id;
		SimpleClassName 	= "VRHComp";
		ComplexClassName 	= "VRHCComp";
		break;
	case VR_CABLING :
		SimpleClass 		= OPP_VRRComp_class_id;
		ComplexClass 		= OPP_VRRCComp_class_id;
		SimpleClassName 	= "VRRComp";
		ComplexClassName 	= "VRRCComp";
		break;
	default :
		printf ( "UNKNOWN PRODUCT : %d\n", Product );
                End
		return OM_E_INVARG;

 	}/* end switch on product */

	/*" Simple  Component (%s ,%d)\n", SimpleClassName,SimpleClass */
	/*" Complex Component (%s ,%d)\n", ComplexClassName,ComplexClass */

	/* -- If it is a component creation ==> Create the object with a default class -- */

	if ( bIsNew )
	{
		/* -- Create component object -- */

    		p_ComponentId->osnum = p_MdEnv->md_id.osnum;
    		status = om$construct( 	classid = SimpleClass,
      		           		p_objid = &p_ComponentId->objid,
		           		osnum   = p_ComponentId->osnum );
    		as$status( );

		/* -- Store component class -- */
		CompClass = SimpleClass;

	}/* end object creation */
	else
	{
		/* -- Else : Get class from specified object -- */
		om$get_classid ( objid = p_ComponentId->objid,
				 osnum = p_ComponentId->osnum,
				 p_classid = &CompClass	);

	}/* end get component's class */

	/*" Component's classid : (%d)\n", CompClass */

	/* ----- KLUDGE : wait to remove structure VRGenInfo ----- */

	/*| -- Set what is known in Instance -- */

	if( AABBCCcode )	strcpy( Instance.szAABBCC, AABBCCcode );
	else			Instance.szAABBCC[0] = '\0';

	if( Number )	strcpy( Instance.szNumber, Number );
	else		Instance.szNumber[0] = 0;
	if( Notes )	strcpy( Instance.szNotes, Notes );
	else		Instance.szNotes[0] = 0;
	Instance.nOption 		 	  = *p_Option;
	Instance.nStatus 		 	  = Status;	
	Instance.cNoMtoFlg 		 	  = NoMtoFlag;
        Instance.cRep 			 	  = Representation;
	Instance.nNbTopo		 	  = 0;
	Instance.nJustif			  = VR_CENTER_JUST;
	Instance.Attr.Comp.Orientation.nPriIndex  = -1;
	Instance.Attr.Comp.Orientation.dPrimary	  = 0.0;
	Instance.Attr.Comp.Orientation.nSecIndex  = -1;
	Instance.Attr.Comp.Orientation.dSecondary = 0.0;
	Instance.Attr.Comp.Desc.nItemNum 	  = ItemNum;
        __DBGpr_com("nPriIndex and nSecIndex initialized to -1");
        /* TR179900985 - correct shape not being stored on object ***/
        if(Product == VR_HVAC)
        {
           IGRint locshape_code;

           IGRshort bIsTransition;
           struct        ACrg_coll       Attr;
           struct GRid SysParam;
           IGRlong      retmsg;

           SysParam.objid = p_SysParamId->objid;
           SysParam.osnum = p_SysParamId->osnum;
           status = VRGetShapeFrmCompCode (  Instance.szAABBCC,
                                                      &bIsTransition,
                                                      &locshape_code,
                                                      Product );
           if(bIsTransition)
           {
               Attr.desc.value.att_exp = (double) locshape_code;
               strcpy(Attr.name, VR_N_SHAPE_IN);
               Attr.desc.type = AC_ATTRIB_DOUBLE;
               __DBGpr_com("modified shape collection here");
               status = VRModifyCollection( &retmsg,
                                 VR_UPDATE_COLL, VR_RG_COLL,
                                NULL, &Attr,1,p_SysParamId);
           }

         }


	/* KLUDGE : 	specify the elbow or branch angle in
			the dPrimary field  (automatic)*/
	if( ItemNum == VR_ELBOW || ItemNum == VR_TEE || ItemNum == VR_DANGLING )
	{  
                __DBGpr_com("nPriIndex set to -2 here\n");
		Instance.Attr.Comp.Orientation.nPriIndex  = -2;
		Instance.Attr.Comp.Orientation.dPrimary	  = Angle;
                __DBGpr_dbl("dPrimary set to angle",Angle);
	}

	/*| -- Evaluate the component with specified parameters -- */

	status =
	om$send( msg	   = message VRGeneric.VREvaluate(
							p_msg,
							&Instance,
							p_SysParamId,
							p_UsrParamId,
							p_MissParamId,
							p_NbCpts,
							NULL,
							&NbMissingTemp,
							&MissingNames,
							&MissingStr,
							&GraphicId,
							p_MdEnv ),
			  senderid = NULL_OBJID,
			  targetid = p_ComponentId->objid,
			  targetos = p_ComponentId->osnum ) ;

	if( *p_msg == VR_MISSING_IN_SEARCH )
	{
		p_MissParamId->objid = NULL_OBJID;
		p_MissParamId->osnum = p_MdEnv->md_id.osnum;

		/* -- GraphicId is the search missing collection Id -- */
		status =
		VR$ModifyCollection( p_msg  		   = &retmsg,
                                     Operation             = VR_MERGE_COLL,
				     p_InputCollectionId   = &GraphicId,
                                     p_OutputCollectionId  = p_MissParamId );
  		as$status();

                End
		return OM_S_SUCCESS;
	}

	if ( !(status&1) ) goto wrapup ;

	/*| -- Give symbology to the component-- */
	if( Symbology )
	{
/*
	  struct GRsymbology AttrSymb ;
*/

	  /*"color  : %d\n", Symbology->display_attr.color*/
	  /*"weight : %d\n", Symbology->display_attr.weight*/
	  /*"style  : %d\n", Symbology->display_attr.style*/

	 /*
	  *  read symbology from input file. 9/1/94
	  *  For the moment it is hardcoded later we need to change it using
	  *  setup file. msm. 9/5/94
	  */

         /* yzhu attr.symb or user defined file for symbology driven */
  	 collId.objid = NULL_OBJID ;
  	 status =
  	 VDgetVdCollId( &msg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
  	 if( (status&msg&1) ) {
      	   status = VDsetAttDrSymb(&msg, *p_ComponentId, p_MdEnv, output );
      	   if( !(status&msg&1) ) {
	      status =
              om$send(msg     = message GRvg.GRputsymb(&retmsg,Symbology),
                 senderid = NULL_OBJID,
                 targetid = p_ComponentId->objid,
                 targetos = p_ComponentId->osnum ) ;
           }
           VD_drwFreeOutputData( &output ) ;
  	 }
         else {

          /* simply OVERRIDE the active values with the VDS method
           HV 3/4/97                                                  */

          strcpy( filename, "routeattr.symb");
	  status =
          om$send( msg = message VDSroot.VDgetAttrDrivenSymb(
                                        &retmsg,
                                        filename,
                                        p_MdEnv,
                                        Symbology),
/*
                                        &AttrSymb),
*/
			senderid = NULL_OBJID,
                        targetid = p_ComponentId->objid,
                        targetos = p_ComponentId->osnum ) ;	

/*
	  if( status & retmsg & 1 ){ *Symbology = AttrSymb ; }
*/

	  status =
	  om$send(msg 	  = message GRvg.GRputsymb(&retmsg,Symbology),
		 senderid = NULL_OBJID,
		 targetid = p_ComponentId->objid,
		 targetos = p_ComponentId->osnum ) ;
          }
	}

	/*| -- Treat missing parameters if pointer is given -- */
	if ( NbMissingTemp != 0 )
	{
		/*" %d MISSING PARAMETERS \n", NbMissingTemp */

	   if ( p_AddrMissingss )
	   {
		if ( NbMissingTemp > StatMissingSize )
		{
			if ( StatMissingSize == 0 )
			{
				if ( StatMissings != NULL )
				{
					/** Free Previous Memory **/
					_FREE( StatMissings );
					StatMissings = NULL;
				}

				/*| First allocation */
				StatMissings =
				(struct ACrg_coll *) _MALLOC ( NbMissingTemp, struct ACrg_coll );
			}/* end first allocation */
			else
			{
				/*| Reallocation */
				StatMissings = 
				(struct ACrg_coll * ) _REALLOC ( StatMissings, NbMissingTemp, struct ACrg_coll );
			} /* end of reallocation */

			if ( !StatMissings ) { StatMissingSize = 0;
                                               End
                                               return OM_E_NODYNMEM;}

			StatMissingSize = NbMissingTemp;

		}/* end allocation missing buffer */

		/*| fill up the Missings array */

		status = VRExtractExpStr( &retmsg,
					  NbMissingTemp,
					  MissingNames,
					  MissingStr,
					  p_NbMissParams,
					  StatMissings ) ;
					  
		as$status( action = GOTO_VALUE, value = wrapup ) ;

		if( NbMissingTemp != *p_NbMissParams ) {
			/*|ERROR : Bad number of expression returned*/
			goto  wrapup ;
		}

		*p_AddrMissingss = StatMissings;

		*p_msg = MSSUCC;
                End
		return OM_S_SUCCESS;

	   }/* end return missings */

	   *p_msg = MSFAIL;
           End
	   return OM_E_ABORT;

	}/* end missing parameters treatment */

	/*| -- EVALUATE COMPONENT'S GEOMETRY -- */


	/* -- Get the type of th evaluated component to change his class if needed -- */
	status = VRTestGeom ( &retmsg, p_ComponentId, *p_NbCpts, p_Type, p_MdEnv );
	as$status ( action = GOTO_VALUE, value = wrapup );

	/* -- Perform change class if necessary -- */
	/*" Component's class is %d\n", CompClass */
	if ( *p_Type == VR_SIMPLE_COMPONENT_TYPE  && CompClass != SimpleClass )
	{
		/*"Simple component : %s -> %s\n",ComplexClassName,SimpleClassName*/
		status =
		om$change_class ( osnum     = p_ComponentId->osnum,
				  objid     = p_ComponentId->objid,
				  classname = SimpleClassName );
		as$status ( action = GOTO_VALUE, value = wrapup );
	}
	else if ( *p_Type == VR_CONSTR_COMPONENT_TYPE  && CompClass != ComplexClass )
	{
		/*"Change component class from %s to %s\n",SimpleClassName,ComplexClassName*/
		status =
		om$change_class ( osnum     = p_ComponentId->osnum,
				  objid     = p_ComponentId->objid,
				  classname = ComplexClassName );
		as$status ( action = GOTO_VALUE, value = wrapup );
	}/* end change class */


	*p_msg = MSSUCC ;
        End
	return OM_S_SUCCESS ;

wrapup :
	/*| -- On Error restore previous steps -- */
	if ( bIsNew &&  p_ComponentId->objid != NULL_OBJID )
	{
		/*| ERROR -> Delete component which failed */

		status =
		om$send ( msg = message GRgraphics.GRdelete ( &retmsg, p_MdEnv ),
			  senderid = NULL_OBJID,
			  targetid = p_ComponentId->objid,
			  targetos = p_ComponentId->osnum ) ;
		as$status ();

		p_ComponentId->objid = NULL_OBJID;

	}/* end delete created component */

	*p_msg = MSFAIL;
        End
	return OM_E_ABORT;

}/* end VREvaluate */


#include "bstypes.h"
#include "bserr.h"
#include "bsparameters.h"

/*-------------------------------------------------------------------*/
/*	function VRTestGeom
/*
/* 
/* Given the component's Id, it evaluates its geometry and
/* returns whether it should be a constrained component or not.
/*
/* This function returns 	MSSUCC if specified connect point is free.
/* 				MSFAIL if not.
/*-------------------------------------------------------------------*/

IGRint	VRTestGeom ( msg, pCmpId, NbCpts, Type, md_env )
IGRlong		*msg;
struct GRid	*pCmpId;	/* I : Component's graphics symbol */
IGRint		NbCpts;		/* I : Number of connect points if known */
IGRint		*Type;		/* O : Component's type : 0 regular, 1 constrained */
struct GRmd_env	*md_env;

/*.VRTestGeom */
{
	IGRint			status;
	IGRlong			retmsg;
	IGRint			i,CpNum;
	struct IGRline		*Lines[2],Line1, Line2;
	IGRdouble		CptCoor[3], ConAxis[3], dOrigin[3]; 
	IGRdouble		Pt1[3], Pt2[3], Pt3[3], Pt4[3];
	IGRdouble		dDist, dIntPt[6], dRefPt[3];
	BSrc			rc;
	IGRboolean		bFirstInter=TRUE;

	*Type = VR_SIMPLE_COMPONENT_TYPE;

	/* Component should be constrained if all connection .. */
	/* .. do not intersect at the same point */
        /* TR3303- inserted the additional requirement that the intersection
                   point be the component origin ****/

	Line1.point1 = Pt1; Line1.point2 = Pt2 ;
	Line2.point1 = Pt3; Line2.point2 = Pt4 ;
	Lines[0] = &Line1 ; Lines[1] = &Line2;

	/*| Get first connection line */
	CpNum = 0;
	status = 
	om$send ( msg = message VRGeneric.VRGetCptGeom ( &retmsg, CpNum, 
							 CptCoor, ConAxis,
                     					 NULL, md_env),
		  senderid = NULL_OBJID,
		  targetid = pCmpId->objid,
		  targetos = pCmpId->osnum );
	as$status ( action = RET_STATUS );

	for (i=0;i<3;i++)
	{
		 Line1.point1[i] = CptCoor[i];
		 Line1.point2[i] = Line1.point1[i] + ConAxis[i];
	}
        /* TR3303 *** Get the component origin coordinates ***/
        status =
        om$send (msg = message VRGeneric.VRGetOrigCoor(&retmsg, dOrigin,md_env),
	    senderid = NULL_OBJID,
            targetid = pCmpId->objid,
            targetos = pCmpId->osnum );

        as$status ( action = RET_STATUS );

	/*| Loop on other connect points */
	for ( CpNum=1; CpNum<NbCpts; CpNum++ )
	{
		/* -- Get Cpt coordinates -- */
		status = 
		om$send ( msg = message VRGeneric.VRGetCptGeom ( &retmsg , CpNum, 
								 CptCoor, ConAxis,
                     					 	 NULL, md_env),
			  senderid = NULL_OBJID,
		  	  targetid = pCmpId->objid,
		  	  targetos = pCmpId->osnum );
		as$status ( action = RET_STATUS );

		for (i=0;i<3;i++)
		{
			Line2.point1[i] = CptCoor[i];
			Line2.point2[i] = Line2.point1[i] + ConAxis[i];
		}

		/*| Compute intersection Cpt0, Cpti */

		dDist=0.0;
		BSint2lns ( Lines, dIntPt, &dDist, &rc );
		/*  " Intersect Lines rc = %d\n", rc */
		/*  " Distance           = %f\n", dDist */
		/* Constrained comp if no intersection or parallel but not equal */
		if ( 	  rc == BSNOINTERS ||
			( rc == BSPARALLEL && dDist > VRGetTol(VR_LENGTH_TOL) ) )
		{
			/*" Cpt[0] and Cpt[%d] do not intersect\n", i */
			/* Change class must be performed */
			*Type = VR_CONSTR_COMPONENT_TYPE;
			break;

		}/* end connections do not intersect */
		else if ( rc != BSPARALLEL )
		{
                     
			/*"Intersection point: %f,%f,%f\n",dIntPt[0],dIntPt[1],dIntPt[2]*/
			{
				IGRdouble	dVect[3];
				IGRdouble	BSlenvec();
				/*| Check Against previous intersection */
				BSmkvec ( &rc, dVect, dOrigin, dIntPt );
				if ( BSlenvec ( &rc, dVect ) > VRGetTol(VR_LENGTH_TOL) )
				{
					/*| Intersection points differ */
					*Type = VR_CONSTR_COMPONENT_TYPE;
					break;
				}/* end Intersection points differ */
			}/* end check new intersection point */

		}/* end check that the intersection point remains the same */

	}/* end loop on cpts */

*msg = MSSUCC;
return OM_S_SUCCESS;

}/* end VRTestGeom */

end implementation Root;

