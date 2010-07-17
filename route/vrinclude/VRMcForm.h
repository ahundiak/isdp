#ifndef vr_mcform_include
#define vr_mcform_include


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#include "ACrg_collect.h"


#if defined(__cplusplus)
extern "C" {
#endif

extern int VRDisplayFormUnits 	__(( 	Form    FormPtr,
					int     MetGroup, 
					int	ImpGroup));


extern IGRint VRDispCollAttr 	__(( 	Form            pForm,         
					struct GRid     *pCollId,     
					IGRint          GadgetNum,   
					IGRchar         *pAttrName));

extern IGRint VRDispCollList 	__(( 	Form            pForm,          
					IGRint          GadgetNum,     
					IGRint          Row,          
					IGRint          *pNbAttr,    
					struct GRid     *pCollId)); 

extern IGRint VRDispCollList2   __((    Form            pForm,
                                        IGRint          GadgetNum,
                                        IGRint          Row,
                                        IGRint          *pNbAttr,
                                        struct GRid     *pCollId));

extern IGRint VRDispAttrList  	__(( 	Form            pForm,          
					IGRint          GadgetNum,     
					IGRint          Row,          
					IGRint          *pNbAttr,    
					struct ACrg_coll *ListAttr));

extern int VRCreCollFromForm	__((  	Form                    form,
                        		int                     gadget,
                        		int                     start_row,
                        		int                     end_row,
                        		struct GRid             *ParId,
		                        struct ACrg_coll        **ParLst,
		                        IGRint                  *NumParId,
		                        IGRint                  *NumParLst ));

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

#omdef	VR$DispCollAttr ( pForm, Gadget, Row=0, pAttrName=NULL, pNbAttr=NULL, pCollId )

#if om$specified (pAttrName)
	VRDispCollAttr (pForm, pCollId, Gadget, pAttrName)
#else
	VRDispCollList (pForm, Gadget, Row, pNbAttr, pCollId)
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
#omdef  VR$DispCollAttr2( pForm, 
			  Gadget, 
			  Row		=0, 
			  pNbAttr	=NULL, 
			  pAttrName	=NULL ,
			  pCollId	=NULL ^
			  ListAttr	= NULL)

#if om$specified (pAttrName)
     VRDispCollAttr (pForm, pCollId, Gadget, pAttrName)

#elif om$specified (pCollId)
     VRDispCollList2 (pForm, Gadget, Row, pNbAttr, pCollId)

#elif (om$specified (ListAttr) && !om$specified (pNbAttr) ) 
#omerror "Must specify pNbAttr if ListAttr is given."

#else
     VRDispAttrList (pForm, Gadget, Row, pNbAttr, ListAttr)
#endif

#endomdef



/************************************************************************/
/*									*/
/* Abstract :	Given a form and the two group numbers containing the	*/
/*		metric and imperial units' symbols, this macro displays	*/
/*		the right group based on the project's working unit.	*/
/* Arguments :								*/
/*									*/
/* Form		pForm		: I	Pointer on the Form.		*/
/*									*/
/* IGRint	MetGroup: I	Group number on the form of the units.	*/
/*									*/
/* IGRint	ImpGroup: I	Group number on the form of the units.	*/
/*									*/
/************************************************************************/


#omdef	VR$DispFormUnits ( pForm, MetGroup = 200 , ImpGroup = 201 )

	VRDisplayFormUnits ( pForm, MetGroup, ImpGroup )
#endomdef


/************************************************************************
*  macro VR$CreCollFromForm
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
*                               Otherwize will VR_MERGE_COLL with old attributes
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
#omdef  VR$CreCollFromForm ( 	form,
				gadget,
				start_row	= 0,
				end_row		= -1,
				NumParLst	= NULL, 
				NumParId 	= NULL, 
				ParLst  	= NULL ^
         			ParId    	= NULL)

VRCreCollFromForm ( (form), (gadget), (start_row), (end_row), 
		    (ParId), (ParLst ), (NumParId), (NumParLst) ) 
#endomdef


#endif

