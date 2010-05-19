/* $Id: VDAttribMac.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/*************************************************************************
 * I/VDSTE
 *
 * File:	vds/vdinclude / VDAttribMac.h
 *
 * Description: 
*	This file came from I/Route/vrinclude: VRMcForm.h + VRutilmacros.h .
* 	Here are Collection to/from Form manipulation, as well as
* 	general collection manipulation macros. 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDAttribMac.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/11/18  17:13:24  pinnacle
 * Created: vdinclude/VDAttribMac.h by kddinov for vds
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
*	10-97	KDD	creation
 *
 *************************************************************************/

#ifndef vd_collection_include
#define vd_collection_include 1

#include "FI.h"
#include "ACrg_collect.h"
#include "VDAttribDef.h"


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


#if defined(__cplusplus)
extern "C" {
#endif

extern IGRint VDDispCollAttr 	__(( 	Form		pForm,         
					struct GRid     *pCollId,     
					IGRint          GadgetNum,   
					IGRchar         *pAttrName));

extern IGRint VDDispCollList 	__(( 	Form            pForm,          
					IGRint          GadgetNum,     
					IGRint          Row,          
					IGRint          *pNbAttr,    
					struct GRid     *pCollId)); 

extern IGRint VDDispCollList2   __((    Form            pForm,
                                        IGRint          GadgetNum,
                                        IGRint          Row,
                                        IGRint          *pNbAttr,
                                        struct GRid     *pCollId));

extern IGRint VDDispAttrList  	__(( 	Form            pForm,          
					IGRint          GadgetNum,     
					IGRint          Row,          
					IGRint          *pNbAttr,    
					struct ACrg_coll *ListAttr));

extern int VDCreCollFromForm	__((  	Form                    form,
                        		int                     gadget,
                        		int                     start_row,
                        		int                     end_row,
                        		struct GRid             *ParId,
		                        struct ACrg_coll        **ParLst,
		                        IGRint                  *NumParId,
		                        IGRint                  *NumParLst ));

extern  IGRint VDModifyCollection __((
                                IGRlong                 *p_msg,
                                IGRint                  Operation,
                                IGRshort                Type,
                                struct  GRid            *p_InputCollectionId,
                                struct  ACrg_coll       *p_ParamsListToModify,
                                IGRint                  NbParamsToModify,
                                struct  GRid            *p_OutputCollectionId));

extern IGRint VDModifyCollection2 __((  IGRlong                 *msg,
                                        int                     Operation,
                                        IGRint                  InNumAttr,
                                        struct GRid             *InParId,
                                        struct ACrg_coll        *InAttrList,
                                        IGRint                  *OutNumAttr,
                                        struct ACrg_coll        **OutAttrList));

#if defined(__cplusplus)
}
#endif


/************************************************************************/
/*									*/
/* Abstract :	Given a form this macro displays in the specified	*/
/*		gadget the specifed attribute if its name is specified	*/
/*		or the entire list of attributes contained in the 	*/
/*		collection ( the gadget must be a list ...)		*/
/* Arguments :								*/
/*									*/
/* Form		pForm		: I	Pointer on the Form.		*/
/*									*/
/* IGRint	GadgetNumber	: I	Gadget number on the form.	*/
/*									*/
/* IGRint	Row		: I	Start row number for field	*/
/*					gadgets.			*/
/* IGRchar	*pAttrName	: I	Attribute name in the collection*/
/*									*/
/* IGRint	*pNbAttr	: O	If no attribute is specified,	*/
/*					returns the number of them in	*/
/*					the collection			*/
/* struct GRid	*pCollId	: I	Collection Id.			*/
/*									*/
/************************************************************************/

#omdef	VD$DispCollAttr ( pForm, Gadget, Row=0, pAttrName=NULL, pNbAttr=NULL, pCollId )

#if om$specified (pAttrName)
	VDDispCollAttr (pForm, pCollId, Gadget, pAttrName)
#else
	VDDispCollList (pForm, Gadget, Row, pNbAttr, pCollId)
#endif
#endomdef


/************************************************************************
*                                                                      *
* Abstract :   Given a form this macro displays in the specified gadget*
*	- 	attribute name if pAttrName is specified
*	- 	list of attributes coming from pCollId, if specified. 
*	-	list of attributes, coming from ListAttr, if specified
*
* It will handle fields with variable number of columns.
* First column is the name.
* If more than 2 columns the first is the type, the second is the value.
* If 2 columns only, the second is the value (no type info).
*
* Arguments :                                                          *
*                                                                      *
* Form         pForm           : I!    Pointer on the Form.            *
*                                                                      *
* IGRint       GadgetNumber    : I!    Gadget number on the form.      *
*                                                                      *
* IGRint       Row             : I     Start row number for field      *
*                                      gadgets.                        *
* IGRchar      *pAttrName      : I     Attribute name in the collection*
*                                                                      *
* IGRint       *pNbAttr        :I/O    With pCollId: May not be given.
*					On input is the number of attr 
*					to be displayed (all if NULL). 
*					On output is the total num of attr
*                                       in the collection
*
*				       With ListAttr: Must be given 
*					Number of attr to display. 
*
* struct GRid  *pCollId        : I     Collection Id.                  *
*
* struct ACrg_coll *ListAttr   : I     Points to the list of Attributes to 
*					display.
************************************************************************/
#omdef  VD$DispCollAttr2( pForm, 
			  Gadget, 
			  Row		=0, 
			  pNbAttr	=NULL, 
			  pAttrName	=NULL ,
			  pCollId	=NULL ^
			  ListAttr	= NULL)

#if om$specified (pAttrName)
     VDDispCollAttr (pForm, pCollId, Gadget, pAttrName)

#elif om$specified (pCollId)
     VDDispCollList2 (pForm, Gadget, Row, pNbAttr, pCollId)

#elif (om$specified (ListAttr) && !om$specified (pNbAttr) ) 
#omerror "Must specify pNbAttr if ListAttr is given."

#else
     VDDispAttrList (pForm, Gadget, Row, pNbAttr, ListAttr)
#endif

#endomdef



/************************************************************************
*  macro VD$CreCollFromForm
*
*  This macro creates Attribute collection using data from a form.
*  The specified gadget must have at least 1 column, specifying attribute name.
*-------------------------------------------------------------------------------
*
* PARAMETERS:
*
* I: Form      	 form          = the from and gadget to use when creating
* I: int       	 gadget          the collection ParId (ParLst).
*
* I: int       	 start_row       (default = 0)
* I: int       	 end_row         (default = -1, i.e. num_rows_in_gadget)
*
* O: struct GRid *ParId        = collection ID, Will get created if != NULL
*                               The caller must provide ParId->osnum.
*                               If ParId->objid = NULL_OBJID, brand new object
*                               will be created.
*                               Otherwize will VD_MERGE_COLL with old attributes
*
* O: IGRint      *NumParId     = output number of parameters in ParId.
*                               It is wise to be != NULL if ParId != NULL.
*
* O: struct ACrg_coll **ParLst = Output parameters list. 
*				Will get created if != NULL.
*                               The called must free the memory.
*
* O: IGRint      *NumParLst    = number of parameters in ParLst.
*                               It is wise to be != NULL if ParLst != NULL.
*-------------------------------------------------------------------------------
*
* Return status:
*
*  1	=  OK (default)
*  0    = any problem
*-------------------------------------------------------------------------------
*
* NOTE:
*  Recognized User Parameters types (2-nd column of gadget)
*  If starts with "d" or "D" is considered AC_ATTRIB_DOUBLE
*  Otherwise AC_ATTRIB_TEXT.
************************************************************************/
#omdef  VD$CreCollFromForm ( 	form,
				gadget,
				start_row	= 0,
				end_row		= -1,
				NumParLst	= NULL, 
				NumParId 	= NULL, 
				ParLst  	= NULL ^
         			ParId    	= NULL)

VDCreCollFromForm ( (form), (gadget), (start_row), (end_row), 
		    (ParId), (ParLst ), (NumParId), (NumParLst) ) 
#endomdef


/****************************************************************************
* Abstract :                                                          	
*	given an input collection or a list of parameters and an output 
*	collection this macro :					
*										
* - UPDATE : if the output and the input have common parameters. this macro set	
*	   the output paramters by the input one. the output collection should  
*	   be created by the caller		 				
*										
* - UNION : add in the output all input parameters which don't exist in the 
*		  output the output collection should  be created by the caller	
*										
* - MERGE : UPDATE + UNION. output can be NULL_OBJID so this macro creates a new
*		  collection.							
*										
* - SUBSTR: remove from the output collection, all attributes contained in the  
*		  input collection. No update of output collection. 
*										
* - INTER : remove from the output collection, all attributes not contained in  
*		  the input collection. No update of output collection. 
*
* - CLEAR : remove all attributes from the output collection or parameter list.
*------------------------------------------------------------------------------
*
*  PARAMETERS:
*
* O:	IGRlong		*p_msg			return code           	
*
* I:	IGRshort     	Operation		operation type ( above )
*
* I: struct GRid	*p_InputCollectionId	input collection grid 	
*
* I: strcut ACrg_coll	*p_ParamsListToModify	list of input parameters 
*
* I:	IGRint		NbParamsToModify	number of input parameters	
*						Valid with InParListToMod
*
* O: struct GRid	*p_OutputCollectionId	output collection ID.  	
*										
* O: struct ACrg_coll	**OutParList        pointer to output list of parameters
*	
* O:	IGRint		*OutNumPar		output number of parameters
*					Valid only with OutParList
*					On input must have number of
*					parameters in OutParList (if != NULL)
******************************************************************************/

#omdef VD$ModifyCollection
       ( p_msg,                         	
         Operation		= VD_MERGE_COLL,
	 Type			= VD_RG_COLL,
	 p_InputCollectionId	= NULL 		^ p_ParamsListToModify = NULL,	
	 NbParamsToModify	= 0,		
	 p_OutputCollectionId	= NULL 		^ OutParList           = NULL,
	 OutNumPar		= NULL )  

#if (om$specified (p_ParamsListToModify) && !om$specified(NbParamsToModify) )
#omerror "Given p_ParamsListToModify, also specify NbParamsToModify (input)."

#elif (om$specified (OutParList) && !om$specified(OutNumPar) )
#omerror "Given OutParList, also specify OutNumPar (output)."

#elif om$specified (p_OutputCollectionId)
VDModifyCollection( ( p_msg                ), ( Operation            ), 
		    ( Type                 ), ( p_InputCollectionId  ),
                    ( p_ParamsListToModify ), ( NbParamsToModify     ), 
		    ( p_OutputCollectionId ) )

#else
VDModifyCollection2(( p_msg                ), ( Operation            ),
                    ( NbParamsToModify     ), 
		    ( p_InputCollectionId  ), ( p_ParamsListToModify ), 
		    ( OutNumPar            ),
                    ( OutParList           ) )

#endif
#endomdef

#endif
