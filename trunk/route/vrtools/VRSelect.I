/* $Id: VRSelect.I,v 1.1.1.1 2001/01/04 21:13:12 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRSelect.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRSelect.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/12/03  21:27:20  pinnacle
# ah
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/04/04  18:59:24  pinnacle
# Replaced: vrtools/VRSelect.I for:  by ashankar for route240
#
# Revision 1.5  1996/04/04  16:23:06  pinnacle
# Replaced: vrtools/VRSelect.I for:  by ashankar for route240
#
# Revision 1.4  1996/01/18  00:32:34  pinnacle
# Replaced: vrtools/VRSelect.I for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb		Add prototypes, 
 *
 *************************************************************************/
/* -------------------------------------------------------------- */
/*	Author	: Bruno Demars (ISDC, Paris)
/*
/*	Date	: 15-Jul-92
/*
/*	Description :
/*
/*	This file contains functions selecting components' based on
/*	specified parameters.
/*	These functions have to be called through the macros defined
/*	in the vrmacros.h file.
/*	
/*     CHANGE HISTORY        
/*                           
/*     Lori     11/21/94   CR#179415717 added function VRFreeStaticSelect
/*			   to free the memory allocated in this file.     
/*	ah	12/03/98   Changed NDmacro.ACgive_structure to ACncpx to avoid
/*                         compilier error
/* -------------------------------------------------------------- */
class implementation Root;

#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gomacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "vrdef.h"
#include "parametric.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "VRmacros.h"
#include "vrtools_pto.h"
#include "VDmem.h"

/* --------------------------------------------------- */
/* Structure for objects selection based on parameters */
/* --------------------------------------------------- */

struct VRSelect
	{
	IGRint			NbAttr;		/*(I) Number of attributes used
						   for selection */
	struct ACrg_coll	*Attr;		/*(I) list of attributes'
						   descriptions */
	IGRint			Size;		/*(I/O) Initial size of the
						   "Selected" buffer */
	struct GRid		*Selected;	/*(O) Return buffer which has to
						   be allocated before calling.
						   the function will then reallocate
						   it if its size is not sufficient */
	IGRint			NbSelected;	/*(O) Number of returned object */
	};

/************************************************************************
 *									*
 *	VRSelectByAttributes: 						*
 *									*
 *          Given a set of parameters (names and values), this		*
 *	    function checks that the specified object's parameters	*
 *	    match them.	This function has been built to be activated	*
 *	    via the GRfunction method of GRgraphics.			*
 *									*
 *									*
 ************************************************************************/

/* Internal buffer */
%safe
static	struct GRid 	*VRSelected = NULL;
static  IGRint		VRSelectedSize = 0;
%endsafe

#define IndId(grid)	(grid##->objid)
#define IndOs(grid)	(grid##->osnum)
#define Arg(field)	((struct VRSelect *)(f_info->info))->##field

from 	ACncpx	import ACgive_structure;

IGRint VRSelectByAttributes (msg, CompId, f_info)
IGRlong			*msg;
struct GRid 		*CompId;
struct GRfunction_info	*f_info;

{
 IGRint			status;
 IGRlong		retmsg;
 IGRint			i;

 IGRint			Index=-1;
 struct ret_struct      AttrSt;

 *msg  = MSSUCC;

 /*" Processing object <%d.%d>\n", IndId(CompId) , IndOs(CompId) */

 for (i=0; i< Arg(NbAttr); i++)
 {
	/*" Get parameter %s \n", Arg(Attr[i].name) */

	status =
	om$send( msg = message ACncpx.ACgive_structure
				((int *) &retmsg, &Index,
 				Arg(Attr[i].name),
				&AttrSt, f_info->md_env ),
		senderid = NULL_OBJID,
		targetid = IndId(CompId),
		targetos = IndOs(CompId));
	as$status( action = RET_STATUS );

	if (  ! (retmsg&1)  ||
		( Arg( Attr[i].desc.type ) == AC_ATTRIB_DOUBLE &&	
			(fabs(AttrSt.var.root_pm_st.value - 
			  Arg(Attr[i].desc.value.att_exp)) >= .1 )) ||
		( Arg( Attr[i].desc.type ) == AC_ATTRIB_TEXT   &&
			strcmp ( AttrSt.var.text_st.text_string,
				 Arg( Attr[i].desc.value.att_txt ) ) ) )
	{
		/*| Does not match -> not selected */
		return OM_S_SUCCESS;
	}

 }/* end loop on parameters' check */

 /*| Add the component in the list */


 if( Arg (Size) <= Arg(NbSelected) )
 {
	/*| Realloc buffer */
	Arg (Selected) =
	(struct GRid *) _REALLOC( Arg(Selected), ( Arg(Size) + 50 ), struct GRid );
	if ( !Arg (Selected) ) return OM_E_NODYNMEM;

	Arg( Size ) += 50;
 }

 Arg ( Selected [ Arg (NbSelected) ] ) = *CompId;
 Arg (NbSelected) += 1;

 *msg  = MSSUCC;
 return OM_S_SUCCESS;

}/* end VRSelectByAttributes */

/************************************************************************
 *									*
 *	VRSelectComponent:						*
 *          Given some select criteria, return an allocated array	*
 *          of control components.					*
 *									*
 *									*
 *	Must be called via vr$select_component				*
 *									*
 *									*
 ************************************************************************/
from OMObjSpace	import pass;
from GRgraphics	import GRfunction;

IGRint VRSelectComponent( msg, Product, NbAttr, Attrs, Buffer, NbSelected)
IGRlong			*msg;
IGRint			Product;	/* (I) Type of components to be selected
					       VR_PIPING, VR_HVAC or VR_RWAY. */
IGRint			NbAttr;		/* (I) Number of attributes to be checked */
struct ACrg_coll	*Attrs;		/* (I) List of attributes descriptions
					       ( names and values ) */
struct GRid 		**Buffer;	/* (O) Buffer of returned components  */
IGRint			*NbSelected;	/* (O) Number of components returned  */

{
 IGRlong		status,retmsg;
 struct VRSelect	Select;		/* Selection information structure */
 OM_S_CLASSLIST		clist;
 OMuword		classes[2];
 struct GRfunction_info	f_info;
 IGRint			VRSelectByAttributes();
 extern GRclassid	OPP_VRHanger_class_id;
 struct GRmd_env	ModEnv;

 /* -- Initialize return arguments -- */
 *msg 		= MSFAIL;
 *NbSelected 	= 0 ;
 *Buffer	= NULL;


 /* -- Set local static buffer -- */
 if ( !VRSelectedSize )
 {
	/* Initialize internal buffer */
	VRSelected = (struct GRid *) _MALLOC ( 5, struct GRid );
	if (!VRSelected ) return OM_E_NODYNMEM ;
	VRSelectedSize = 5;
 }/* end malloc internal buffer */


 /* -- Based on product, select the classes -- */

 switch (Product)
 {
	case VR_PIPING :
		{
			extern GRclassid OPP_VRPiping_class_id;
			
			clist.w_count	= 2;
			classes[0]	= OPP_VRPiping_class_id;
 			classes[1]      = OPP_VRHanger_class_id;
			break;
		}/* end piping components */

	case VR_HVAC :
		{
			extern GRclassid OPP_VRHvac_class_id;

			clist.w_count   = 2;
			classes[0]      = OPP_VRHvac_class_id;
 			classes[1]      = OPP_VRHanger_class_id;
			break;
		}/* end hvac components */

	case VR_RWAY :
		{
			extern GRclassid OPP_VRRway_class_id;

			clist.w_count   = 2;
			classes[0]      = OPP_VRRway_class_id;
 			classes[1]      = OPP_VRHanger_class_id;
			break;
		}/* end rway components */

	default : return OM_E_INVARG;

 }/* end switch on product */

 /* -- Set all arguments needed by the selection function -- */

 Select.NbAttr 		= NbAttr;
 Select.Attr 		= Attrs;
 Select.Size		= VRSelectedSize;
 Select.Selected	= VRSelected;
 Select.NbSelected	= 0;

 /* -- Get current object space module env -- */

 {
 IGRint	size, ret_size;

 size = sizeof( struct GRmd_env ) ;

 gr$get_module_env( msg	  = &retmsg,
		   sizbuf = &size,
		   buffer = &ModEnv,
		   nret   = &ret_size );
 }

 go$build_user_function_buffer(buffer   = &f_info,
			       your_info= &Select,
				md_env 	= &ModEnv );

 clist.w_flags   = OM_CLST_subclass;
 clist.p_classes = classes;

 /* !!! recuperer tous les osnums si reference file */

 /*"OM_GO_current_OS_objid: %d\n",OM_GO_current_OS_objid*/
 /*"OM_Gw_current_OS: %d\n",OM_Gw_current_OS*/

 /* -- Send function accross object space -- */

 status = om$send( msg = message OMObjSpace.pass(&clist,OM_e_wrt_object,
  			 message GRgraphics.GRfunction(msg, VRSelectByAttributes, 
			                               (char *) &f_info)),
                         senderid = NULL_OBJID,
			 targetid = OM_GO_current_OS_objid,
			 targetos = ModEnv.md_id.osnum);
 as$status(action = RET_STATUS);
 if(*msg == MSFAIL) 
 {
	/*"GRfunction bad completion code\n" */
	return OM_W_ABORT;
 }

 /* -- Save returned values -- */ 

 /* buffer might have been reallocated */
 VRSelectedSize = Select.Size;
 VRSelected     = Select.Selected;

 /* return found objects */
 *NbSelected    = Select.NbSelected;
 *Buffer 	= VRSelected;

 return OM_S_SUCCESS;

}/* end VRSelectComponent */

/************************************************************************
 *                                                                      *
 *      VRFreeStaticSelect :                                            *
 *                                                                      *
 *          This function sets the static variables in this             *
 *          file so that memory can be freed in functions calling       *
 *          the select functions in this file                           *
 *                                                                      *
 ************************************************************************/

VRFreeStaticSelect()
{
  if (VRSelected)
    _FREE(VRSelected);
  VRSelected = NULL;
  VRSelectedSize = 0;

  return OM_S_SUCCESS;
}



/************************************************************************
 *									*
 *	VRReviewTopology : 						*
 *									*
 *          This function returns the topologic information		*
 *	    from the selected connect point of the specified		*
 *	    component.							*
 *									*
 *	Must be called via vr$review_topology				*
 *									*
 ************************************************************************/


from VRGeneric	import	VRGetNeighbors;

IGRint	VRReviewTopology ( pMsg, pComponent, CptNum, pTee,
			   pMatrix, pNeighbor, pNeighCpt, pMdEnv ) 
IGRlong			*pMsg;
struct GRid		*pComponent;
IGRint			CptNum;
IGRdouble		*pTee;
IGRdouble		*pMatrix;
struct GRid		*pNeighbor;
IGRint			*pNeighCpt;
struct GRmd_env		*pMdEnv;
{
 IGRint		status , TmpInt;

 *pMsg = MSFAIL;

 /* -- Return component's neighbor -- */

 if ( pNeighbor || pNeighCpt )
 {
	status =
	om$send ( msg = message VRGeneric.VRGetNeighbors
			( pMsg , CptNum, CptNum,&TmpInt,
			pNeighbor, (IGRshort *)pNeighCpt, pMdEnv),
		senderid = NULL_OBJID,
		targetid = pComponent->objid,
		targetos = pComponent->osnum );
	as$status ( action = RET_STATUS );

 }/* end return neighbor */

 /* -- Return component's orientation tee matrix -- */

 if ( pTee )
 {
	status = 
	VR$GetMatrix ( 	p_msg 		= pMsg,
			p_ComponentId 	= pComponent,
			p_Matrix	= pTee,
			p_MdEnv		= pMdEnv );
	as$status ( action = RET_STATUS );

 }/* end return component matrix */

 /* -- Return component's connection orientation matrix -- */

 if ( pMatrix )
 {
	status = 
	VR$GetMatrix ( 	p_msg 		= pMsg,
			p_ComponentId 	= pComponent,
			CompCpt		= CptNum,
			p_Matrix	= pMatrix,
			p_MdEnv		= pMdEnv );
	as$status ( action = RET_STATUS );

 }/* end return cpt matrix */	

 return OM_S_SUCCESS;

}/* end VRReviewTopology */


/************************************************************************
 *									*
 *	VRReviewFlowdir : 						*
 *									*
 *          This function returns the flow rate and direction 		*
 *	    from the selected connect point of the specified		*
 *	    component.							*
 *									*
 *	Must be called via vr$review_flowdir				*
 *									*
 ************************************************************************/


from VRGeneric	import	VRGetFlow;

IGRint VRReviewFlowdir (pMsg, pComponent, CptNum, pFlowDir, pFlowRate, pMdEnv )
IGRlong			*pMsg;
struct GRid		*pComponent;
IGRint			CptNum;
IGRshort		*pFlowDir;
IGRdouble		*pFlowRate;
struct GRmd_env		*pMdEnv;
{
 IGRint		status;

 *pMsg = MSFAIL;

	/*C Get flow */
	if ( pFlowDir || pFlowRate )
	{
		status=
		om$send ( msg = message VRGeneric.VRGetFlow
			      ( pMsg, CptNum, pFlowDir, pFlowRate, pMdEnv),
			senderid = NULL_OBJID,
			targetid = pComponent->objid,
			targetos = pComponent->osnum);
		as$status ( action = CONTINUE );
	}

 return OM_S_SUCCESS;

}


end implementation Root;

