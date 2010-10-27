/* $Id: VDFormUtil.I,v 1.1.1.1 2001/01/04 21:09:30 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdtools / VDFormUtil.I
 *
 * Description: 
 *	Handy set of routines to create/retrieve/display collections to/from
 *	forms (coming from I/Route). 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDFormUtil.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:30  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/11/18  17:03:12  pinnacle
# Created: vdtools/VDFormUtil.I by kddinov for vds
#
 *
 * History:
*	10-97	KDD	creation.
 *
 *************************************************************************/

class implementation Root;

/*
#define vdsDEBUG        1
*/ 


#include <stdio.h>

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "FI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "alloca.h"
#include "VDmem.h"

#include "AS_status.h"
#include "VDAttribMac.h"

#include "v_dbgmacros.h"


%safe
#include "VX_FIproto.h"
%endsafe

from 	ACrg_collect	import	AClist_attribute;
from	ACrg_collect	import 	ACget_named_attribute;


/*-------------------------------------------------------------------*/
/*	function VDDispCollAttr
/*
/* 
/* This function gets the specified attribute from the collection
/* and sets its value in the specified form's gadget.
/*
/* Returns OM_S_SUCCESS if the attribute is found.
/*-------------------------------------------------------------------*/
IGRint VDDispCollAttr ( pForm, pCollId, GadgetNum, pAttrName )

Form		pForm;		/* Pointer on formwhich would display */
struct GRid	*pCollId;	/* Collection where attr is stored */
IGRint		GadgetNum;		/* Gadget number on the form */
IGRchar		*pAttrName;	/* Attribute name in the collection */
{
	IGRlong			retmsg;
	IGRint			status;
	struct ACrg_coll	Attr;
	IGRint			row=0;
	IGRint			col=0;
	IGRint			sel_flag=0;

SetProc( VDDispCollAttr ); Begin

	if( pCollId->objid == NULL_OBJID )
		return OM_E_INVARG;

	/* -- Get attribute from the collection -- */

	strcpy ( Attr.name, pAttrName );
	/*"Attr name : <%s>\n", Attr.name */

	status =
	om$send( msg      = message ACrg_collect.ACget_named_attribute( &retmsg, 
									&Attr ),
		 senderid = NULL_OBJID,
		 targetid = pCollId->objid,
		 targetos = pCollId->osnum );
	as$status( );
	if ( !(retmsg&1) ) return OM_E_ABORT;

	/* -- Based on the attribute's type, set the gadget -- */

	if 		( Attr.desc.type == AC_ATTRIB_TEXT )
	{
		FIfld_set_text( pForm, GadgetNum, row, col,
				Attr.desc.value.att_txt,sel_flag );
	}
	else if 	( Attr.desc.type == AC_ATTRIB_DOUBLE )
	{
                FIfld_set_value( pForm, GadgetNum, row, col,
                                Attr.desc.value.att_exp, sel_flag );
	}
	else return OM_E_ABORT;

End;
return OM_S_SUCCESS;

}


/*-------------------------------------------------------------------*/
/*	function VDDispCollList
/*
/* 
/* This function gets the attributes from the collection
/* and sets their values in the specified form's gadget
/* which must hold a list with at least 2 columns.
/*
/*-------------------------------------------------------------------*/
IGRint VDDispCollList ( pForm, GadgetNum, Row, pNbAttr, pCollId )

Form		pForm;		/* Pointer on formwhich would display */
IGRint		GadgetNum;	/* Gadget number on the form */
IGRint		Row;		/* Row in the gadget */
IGRint		*pNbAttr;	/* Number of attributes found */
struct GRid	*pCollId;	/* Collection to be listed */
{

  struct	ACrg_coll	*ListAttr=NULL;
  IGRlong			status, retcode;
  IGRint			i, row=0, sel_flag=0, NbAttr, NumCols = 1;


	/*C get the number of attributes */
	status = 
	om$send( msg      = message ACrg_collect.AClist_attribute
			( &retcode, 0, ListAttr, &NbAttr ),
	         senderid = NULL_OBJID,
	         targetid = pCollId->objid,
		 targetos = pCollId->osnum );
        as$status( action = RET_STATUS );

	/*C Allocate the memory for the collection array */
	ListAttr = (struct ACrg_coll * )
		alloca( (NbAttr)*(sizeof( struct ACrg_coll )) );
	if ( !ListAttr ) 
	{
		printf( " Could Not allocate Dynamic Memory \n" );
		return OM_E_ABORT;
	}	

	/* -- Get all attributes from the collection -- */
	status = 
	om$send( msg      = message ACrg_collect.AClist_attribute
                              ( &retcode, NbAttr, ListAttr, &NbAttr ),
	         senderid = NULL_OBJID,
	         targetid = pCollId->objid,
		 targetos = pCollId->osnum );
        as$status( action = RET_STATUS );

 	/* -- Reset the gadget -- */
	if ( !Row ) FIg_reset( pForm, GadgetNum );

	if ( (NbAttr+Row) > VD_MAX_ATTR )
		FIfld_set_max_num_rows( pForm, GadgetNum, NbAttr+Row );
	else
		FIfld_set_max_num_rows( pForm, GadgetNum, VD_MAX_ATTR );

	/* Get number of columns for that gadget */
	FImcf_get_num_cols( pForm, GadgetNum, &NumCols);

	for ( row=Row, i=0; i<NbAttr; row++, i++ )
	{
		/* -- Set Attribute name in first column -- */
          	FIfld_set_text( pForm, GadgetNum, row, 0,
				ListAttr[i].name, sel_flag ); 

		if ( NumCols < 2 ) continue; 

		/* -- Set Attribute value in second column -- */
          	if( ListAttr[row].desc.type == AC_ATTRIB_DOUBLE )
          	{
		 FIfld_set_value( pForm,GadgetNum, row, 1,
			ListAttr[i].desc.value.att_exp, sel_flag );
		}/* end double */
	        else
          	{
		 FIfld_set_text(  pForm, GadgetNum, row, 1, 
				ListAttr[i].desc.value.att_txt, sel_flag );
        	}/* end text */

	}/* end loop on attributes */

	if (pNbAttr)	*pNbAttr = NbAttr;

return (OM_S_SUCCESS);
}


/*-------------------------------------------------------------------*/
/*	function VDDispCollList
/*
/* 
/* This function gets the attributes from the collection
/* and sets their values in the specified form's gadget
/* which must hold a list with at least 2 columns.
/*
/* It will handle fields with variable number ( >= 1) of columns (June 97, KDD).
/* First column is the name. 
/* If more than 2 columns the first is the type, the second is the value.
/* If 2 columns only, the second is the value (no type info). 
/* 
/* The caller must ensure that the form can handle the text lenght. 
/*-------------------------------------------------------------------*/

IGRint VDDispCollList2 ( pForm, GadgetNum, Row, pNbAttr, pCollId )

Form		pForm;		/* Pointer on formwhich would display */
IGRint		GadgetNum;	/* Gadget number on the form */
IGRint		Row;		/* Row in the gadget */
IGRint		*pNbAttr;	/* Num of attributes to display (I)/ (O) found*/
struct GRid	*pCollId;	/* Collection to be listed */
{

  struct	ACrg_coll	*ListAttr=NULL;
  IGRlong			status, retcode;
  IGRint			i, row=0, sel_flag=0, NbAttr;
  IGRint                        NumCols = 1, 
				NumAttrToDisp,
                                ColType = 0, 
                                ColValue = 0;


SetProc( VDDispCollList2 ); Begin

	if ( !pForm) return 0; 

	/*C get the number of attributes */
	status = 
	om$send( msg      = message ACrg_collect.AClist_attribute
			( &retcode, 0, ListAttr, &NbAttr ),
	         senderid = NULL_OBJID,
	         targetid = pCollId->objid,
		 targetos = pCollId->osnum );
        as$status( action = RET_STATUS );

	/*C Allocate the memory for the collection array */
	ListAttr = (struct ACrg_coll * )
		alloca( (NbAttr)*(sizeof( struct ACrg_coll )) );
	if ( !ListAttr ) 
	{
		printf( " Could Not allocate Dynamic Memory \n" );
		return OM_E_ABORT;
	}	

	/* -- Get all attributes from the collection -- */
	status = 
	om$send( msg      = message ACrg_collect.AClist_attribute
                              ( &retcode, NbAttr, ListAttr, &NbAttr ),
	         senderid = NULL_OBJID,
	         targetid = pCollId->objid,
		 targetos = pCollId->osnum );
        as$status( action = RET_STATUS );

 	/* -- Reset the gadget -- */
	if ( !Row ) FIg_reset( pForm, GadgetNum );

	if ( pNbAttr && (*pNbAttr >= 0) ) NumAttrToDisp = *pNbAttr;
	else           			  NumAttrToDisp = NbAttr;

	if ( (NumAttrToDisp + Row) > VD_MAX_ATTR )
		FIfld_set_max_num_rows( pForm, GadgetNum, NumAttrToDisp + Row );
	else
		FIfld_set_max_num_rows( pForm, GadgetNum, VD_MAX_ATTR );

/*** KDD July 1997 * Make it user friendly. ****/
        ColType = 0;
        ColValue= 0; 
        FImcf_get_num_cols( pForm, GadgetNum, &NumCols);
        if ( NumCols > 2 ) {
                ColType = 1;
                ColValue= 2;
        }
        else if ( NumCols > 1 ) {
                ColValue= 1;
        }


	for ( row=Row, i=0; i < NumAttrToDisp ; row++, i++ )
	{
	    /* -- Set Attribute name in first column -- */
            FIfld_set_text( pForm, GadgetNum, row, 0,
				ListAttr[i].name, sel_flag ); 

	    if ( ColValue ) {
          	if ( ListAttr[i].desc.type == AC_ATTRIB_DOUBLE )  {
                   FIfld_set_value( pForm,GadgetNum, row, ColValue,
                          ListAttr[i].desc.value.att_exp, sel_flag );
		}
	        else
		   FIfld_set_text(  pForm, GadgetNum, row, ColValue, 
				ListAttr[i].desc.value.att_txt, sel_flag );
	    }

	    if ( ColType ) {
		if ( ListAttr[i].desc.type == AC_ATTRIB_DOUBLE ) 
                   FIfld_set_text( pForm,GadgetNum, row, ColType,
                                "dbl", sel_flag );
                else
                   FIfld_set_text(  pForm, GadgetNum, row, ColType,
                                "txt", sel_flag );
	    }

	}/* end loop on attributes */

	if (pNbAttr)	*pNbAttr = NbAttr;

End;
return (OM_S_SUCCESS);
}



/*--------------------------------------------------------------------
*	function VDDispAttrList 
*---------------------------------------------------------------------
* 
* This function gets the attributes from the attribute list
* and sets their values in the specified form's gadget
* which must hold at least 1 column.
*---------------------------------------------------------------------
*
* It will handle fields with variable number of columns.
* First column is the name. 
* If more than 2 columns the first is the type, the second is the value.
* If 2 columns only, the second is the value (no type info). 
*---------------------------------------------------------------------
* 
* The caller must ensure that the form can handle the text lenght. 
*---------------------------------------------------------------------
* 
* PARAMETERS:
*
* Form		   pForm     :I	= pointer to form to display. 
*
* IGRint  	   GadgetNum :I = gadget number to display into. 
*
* IGRint	   InRow     :I = start row to display from. 
*
* IGRint	   *NbAttr   :I = number of attributes to display. 
*
* struct ACrg_coll *ListAttr :I = pointer to the list of attributes. 
*-------------------------------------------------------------------*/
IGRint VDDispAttrList ( Form		 pForm,
			IGRint		 GadgetNum,	
			IGRint		 InRow,	
			IGRint		 *NbAttr,	
			struct ACrg_coll *ListAttr)
{

  IGRlong			status = OM_S_SUCCESS;
  IGRint			i, row=0, sel_flag=0;
  IGRint			NumCols=1, ColType, ColValue;

SetProc( VDDispAttrList ); Begin

	if ( !pForm)                    {status = 0; goto wrapup; } 
	if ( !NbAttr)                   {status = 0; goto wrapup; }

	if ( !InRow ) FIg_reset( pForm, GadgetNum );

        ColType = 0;
        ColValue= 0; 
        FImcf_get_num_cols( pForm, GadgetNum, &NumCols);

        if ( NumCols > 2 )      { ColValue= 2; ColType = 1; }
        else if ( NumCols > 1 ) { ColValue= 1; }

	for ( row=InRow, i=0; i < *NbAttr; row++, i++ ) {
            FIfld_set_text( pForm, GadgetNum, row, 0,
				ListAttr[i].name, sel_flag ); 

	    if ( ColValue ) {
          	if ( ListAttr[i].desc.type == AC_ATTRIB_DOUBLE )  {
                   FIfld_set_value( pForm, GadgetNum, row, ColValue,
                          	ListAttr[i].desc.value.att_exp, sel_flag );
		}
	        else
		   FIfld_set_text(  pForm, GadgetNum, row, ColValue, 
				ListAttr[i].desc.value.att_txt, sel_flag );
	    }

	    if ( ColType ) {
		if ( ListAttr[i].desc.type == AC_ATTRIB_DOUBLE ) 
                   FIfld_set_text( pForm,GadgetNum, row, ColType, 
                                "dbl", sel_flag );
                else
                   FIfld_set_text(  pForm, GadgetNum, row, ColType,
                                "txt", sel_flag );
	    }
	}

wrapup:
End;
return (status);
}



/*******************************************************************************
*  Function VDCreCollFromForm
* 
*  This function creates (updates) Attribute collection using data from a form. 
*  The specified gadget must have at least 1 column, specifying attribute name. 
*-------------------------------------------------------------------------------
*
* PARAMETERS:
*
* (I) Form      form          = the from and gadget to use when creating
*
* (I) int       gadget          the collection ParId (ParLst).
*
* (I) int       start_row       (default = 0)
*
* (I) int       end_row         (default = -1, i.e. num_rows_in_gadget)
*
* (O) struct GRid *ParId      = collection ID. If != NULL will load here only. 
*				The caller must provide ParId->osnum.
*				If ParId->objid = NULL_OBJID, brand new object
*				will be created.
* 				Otherwize will VD_MERGE_COLL with old attributes
*
* (O) IGRint   	*NumParId     = output number of parameters in ParId.
*                               It is wise to be != NULL if ParId != NULL.
*
* (O) struct ACrg_coll **ParLst= address of pointer to output parameters list. 
*				Will get created if is !NULL.
*                               Otherwize will VD_MERGE_COLL with old attributes
*				The called must free the memory.
*
* (O) IGRint   	*NumParLst    = output number of parameters in ParLst.
*				It is wise to be != NULL if ParLst != NULL. 
*-------------------------------------------------------------------------------
*
* Return status:
*
*  1    =  OK (default)
*  0    = any problem
*-------------------------------------------------------------------------------
*
* NOTE: 
*  Recognized User Parameters types (2-nd column of gadget) 
*  If starts with "d" or "D" is considered AC_ATTRIB_DOUBLE
*  Otherwise AC_ATTRIB_TEXT. 
*******************************************************************************/
int VDCreCollFromForm( 	Form			form, 
			int			gadget,
			int			start_row,
			int			end_row,
			struct GRid		*ParId,
			struct ACrg_coll	**ParLst,
			IGRint			*NumParId,
			IGRint			*NumParLst)
{
	int			status = 1, num_rows, num_pars=0, i,
				sel, pos;

        IGRint                  NumCols=1, ColType, ColValue;

	IGRlong			retcode;

	struct ACrg_coll	*FormLst = NULL;

	char			text[64], text2[64];

	double			value; 

SetProc( VDCreCollFromForm ); Begin 

/*---------------------
# Initialize. 
*----------------------*/
   if ( !form )             {status = 0; goto wrapup; } 

   FIfld_get_num_rows( form, gadget, &num_rows);  
   if ( end_row == -1 ) end_row = num_rows;
   if ( end_row < start_row ) {status = 0; goto wrapup; } 

   FormLst = _MALLOC( end_row - start_row + 1, struct ACrg_coll ); 

   ColType = 0;
   ColValue= 0;
   FImcf_get_num_cols( form, gadget, &NumCols);

   if ( NumCols > 2 )      { ColValue= 2; ColType = 1; }
   else if ( NumCols > 1 ) { ColValue= 1; }

/*---------------------
#  Load FormLst. Will generate unique list (no order specified). 
*       ACrg_collect.ACadd_list_attribute will take the first occurence. 
*----------------------*/
      for (num_pars=0, i=start_row; i < end_row; i++)  {
           (FormLst[num_pars].name)[0] = '\0';
	   text[0]  = '\0';
	   text2[0] = 't';

           FIfld_get_text(form, gadget, i, 0, 60,
                        (unsigned char *)FormLst[num_pars].name, &sel, &pos);

           if ( strlen(FormLst[num_pars].name) == 0 ) continue;

	   if ( ColType > 0 ) {
           	FIfld_get_text(form, gadget, i, ColType, 60, (unsigned char *) 
							text2, &sel, &pos);
	   }

           FIfld_get_text(form, gadget, i, ColValue,60, (unsigned char *) 
							text, &sel, &pos);

           if ( (text2[0] == 'd') || (text2[0] == 'D') ) {
		sscanf( text, "%lf", &value); 
		FormLst[num_pars].desc.value.att_exp = (IGRdouble) value; 
                FormLst[num_pars].desc.type = AC_ATTRIB_DOUBLE;
           }
           else {
                strcpy(FormLst[num_pars].desc.value.att_txt, text);
                FormLst[num_pars].desc.type = AC_ATTRIB_TEXT;
           }

	   num_pars++; 
      }

/*---------------------
# Does the caller want ParId? 
*----------------------*/
   if ( ParId )  {
        status = VD$ModifyCollection(   p_msg                 = &retcode,
	                                Operation             = VD_MERGE_COLL,
	                                p_ParamsListToModify  = FormLst,
	                                NbParamsToModify      =(IGRint)num_pars,
	                                p_OutputCollectionId  = ParId); 

	if ( NumParId ) {
           status = om$send( msg      = message ACrg_collect.AClist_attribute
	                                      ( &retcode, 0, NULL, NumParId),
                             senderid = NULL_OBJID,
                             targetid = ParId->objid,
                             targetos = ParId->osnum );
	}
   }

/*---------------------
# Does the caller want ParLst? 
*----------------------*/
   if ( ParLst )  { 
	if (NumParLst ) num_rows = *NumParLst;
	else		num_rows = 0; 

        status = VD$ModifyCollection(   p_msg                 = &retcode,
	                                Operation             = VD_MERGE_COLL,
	                                p_ParamsListToModify  = FormLst,
	                                NbParamsToModify      =(IGRint)num_pars,
	                                OutParList            = ParLst,
	                                OutNumPar             = &num_rows );

	if (NumParLst ) *NumParLst = num_rows;
   }

wrapup:
   if ( FormLst ) _FREE( FormLst); 
   FormLst = NULL; 

End;
   return (status);
}









end implementation Root;





