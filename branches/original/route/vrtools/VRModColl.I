/* $Id: VRModColl.I,v 1.2 2001/02/20 01:17:53 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRModColl.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRModColl.I,v $
 *	Revision 1.2  2001/02/20 01:17:53  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/09/08  00:32:30  pinnacle
# Replaced: vrtools/VRModColl.I for:  by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
class implementation Root;

/*
#define vdsDEBUG        1
*/ 


#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h" 
#include "msdef.h"
#include "nddef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "VRutildef.h"
#include "VRattr_def.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "vrdbgmacros.h"
#include "VDmem.h"

#define AS_DEBUG

from 	NDnode		import 	NDchg_state;
from	ACrg_collect	import	AClist_attribute,
				ACrem_attribute,
				ACset_list_attribute,
				ACadd_list_attribute,
				ACget_named_attribute,
				ACmod_list_attribute;

extern	GRclassid	OPP_ACrg_collect_class_id; 
extern	GRclassid	OPP_ACdyn_col_class_id; 

/********************************************************************************************/
/*
/*	This function modify a collection 
/*
/**/

IGRint VRModifyCollection(	p_msg, Operation, Type, p_InputCollectionId,
				p_ParamsListToModify, NbParamsToModify,
				p_OutputCollectionId )

IGRlong				*p_msg;              	/* return code            	*/
IGRint				Operation;		/* operation type		*/
IGRshort			Type;
struct		GRid		*p_InputCollectionId;	/* given collection GRid 	*/
struct		ACrg_coll	*p_ParamsListToModify;	/* list of parameters to modify */
IGRint				NbParamsToModify;	/* number of these parameters	*/
struct		GRid		*p_OutputCollectionId;	/* output collection GRid 	*/

/*.VRModifyCollection */
{
  IGRint			i,*p_NbAttr, NbAttr, NbOutAttr, index;
  IGRboolean			found=0;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	ACrg_coll	*p_ListAttr, ListOutAttr[VR_MAX_ATTR];
  struct	ACrg_coll	ListAttr[VR_MAX_ATTR];
  extern IGRboolean VDgetAttrIndex();


SetProc( VRModifyCollection ); Begin

  *p_msg    = MSSUCC;

  if( ( !p_InputCollectionId && !p_ParamsListToModify ) ||
	!p_OutputCollectionId ) return OM_E_INVARG;

__DBGpr_obj("p_OutputCollectionId", *p_OutputCollectionId);

  if( p_InputCollectionId )
  {
__DBGpr_obj("p_InputCollectionId", *p_InputCollectionId);

	p_ListAttr = ListAttr;
	p_NbAttr   = &NbAttr;
	
	status = om$send( msg      = message ACrg_collect.AClist_attribute
                               		( &retcode, VR_MAX_ATTR, p_ListAttr, p_NbAttr ),
                    	  senderid = NULL_OBJID,
                    	  targetid = p_InputCollectionId->objid,
                    	  targetos = p_InputCollectionId->osnum );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );
  }
  else
  {
	p_ListAttr = p_ParamsListToModify;
	p_NbAttr   = &NbParamsToModify;
  }
 
__DBGpr_int("Number of attributes to modify", *p_NbAttr);
__DBGpr_int("Operation                     ", Operation);

  switch( Operation )
  {
	case VR_MERGE_COLL :

		if( p_OutputCollectionId->objid	== NULL_OBJID )
		{
			if( Type == VR_DYN_COLL )
			{
      				status = 
				om$construct( 	classid = OPP_ACdyn_col_class_id,
    		             			p_objid = &p_OutputCollectionId->objid,
		             			osnum   = p_OutputCollectionId->osnum,
             					msg     = message NDnode.NDchg_state
							  ( ~0, ND_DEL_NO_CH ));
      				as$status( action = RET_STATUS ); 
			}
			else
			{
      				status = 
				om$construct( 	classid = OPP_ACrg_collect_class_id,
    		             			p_objid = &p_OutputCollectionId->objid,
		             			osnum   = p_OutputCollectionId->osnum,
             					msg     = message NDnode.NDchg_state
							( ~0, ND_DEL_NO_CH ));
      				as$status( action = RET_STATUS ); 
			}
      			/*"created ACrg_collect %d\n", p_OutputCollectionId->objid */

  			status = om$send( msg      = message ACrg_collect.ACset_list_attribute
                                     		     ( &retcode, *p_NbAttr, p_ListAttr ),
                    		  	  senderid = NULL_OBJID,
                    		  	  targetid = p_OutputCollectionId->objid,
                    		  	  targetos = p_OutputCollectionId->osnum );
  			as$status( action = RET_STATUS );
		}
		else
		{
			status = om$send( msg = message ACrg_collect.AClist_attribute
                              	( &retcode, VR_MAX_ATTR, ListOutAttr,&NbOutAttr ),
                    	  	senderid = NULL_OBJID,
                    	  	targetid = p_OutputCollectionId->objid,
                    	  	targetos = p_OutputCollectionId->osnum );
  			as$status( action = RET_STATUS );
  			as$status( sts = retcode, action = RET_STATUS );


			for ( i=0; i < *p_NbAttr; i++ )
			{
				found = VDgetAttrIndex( p_ListAttr[i].name, 
							ListOutAttr, NbOutAttr,
								 &index );
				if ( found )
					ListOutAttr[index] = p_ListAttr[i];
				else
					ListOutAttr[NbOutAttr++] = p_ListAttr[i];
			}

__DBGpr_int("Attributes ready to set        ", NbOutAttr); 
			status = om$send( msg= message ACrg_collect.ACset_list_attribute
					( &retcode, NbOutAttr, ListOutAttr ),
                    	  		senderid = NULL_OBJID,
					targetid = p_OutputCollectionId->objid,
					targetos = p_OutputCollectionId->osnum );
			as$status( action = RET_STATUS );
		}

		break;

	case VR_UPDATE_COLL :
		if( p_OutputCollectionId->objid == NULL_OBJID ) 
			return OM_E_INVARG;

		status = om$send( msg = message ACrg_collect.AClist_attribute
                              ( &retcode, VR_MAX_ATTR, ListOutAttr,&NbOutAttr ),
                    	  senderid = NULL_OBJID,
                    	  targetid = p_OutputCollectionId->objid,
                    	  targetos = p_OutputCollectionId->osnum );
  		as$status( action = RET_STATUS );
  		as$status( sts = retcode, action = RET_STATUS );


		for ( i=0; i < *p_NbAttr; i++ )
		{
			found = VDgetAttrIndex( p_ListAttr[i].name, ListOutAttr, 
							NbOutAttr, &index );
			if ( found )
				ListOutAttr[index] = p_ListAttr[i];
		}

		status = om$send( msg= message ACrg_collect.ACset_list_attribute
				( &retcode, NbOutAttr, ListOutAttr ),
                    	  	senderid = NULL_OBJID,
				targetid = p_OutputCollectionId->objid,
				targetos = p_OutputCollectionId->osnum );
		as$status( action = RET_STATUS );

		break;

	case VR_UNION_COLL :

		if( p_OutputCollectionId->objid == NULL_OBJID ) return OM_E_INVARG;

  		status = om$send( msg      = message ACrg_collect.ACadd_list_attribute
                                      			( &retcode, *p_NbAttr, p_ListAttr ),
                    		  senderid = NULL_OBJID,
                    		  targetid = p_OutputCollectionId->objid,
                    		  targetos = p_OutputCollectionId->osnum );
  		as$status( action = RET_STATUS );

		break;

	case VR_SUBSTR_COLL :
		if( p_OutputCollectionId->objid == NULL_OBJID ) return OM_E_INVARG;

		for (i=0; i<*p_NbAttr; i++)
		{
	  		status =
			om$send( msg      = message ACrg_collect.ACrem_attribute
                                      		( &retcode, p_ListAttr[i].name ),
                    		  senderid = NULL_OBJID,
                    		  targetid = p_OutputCollectionId->objid,
                    		  targetos = p_OutputCollectionId->osnum );
  			as$status( action = RET_STATUS );
		}

		break;

	case VR_INTER_COLL :
		{
			IGRint			NbOutAttr;
			struct	ACrg_coll	OutListAttr[VR_MAX_ATTR];

		if( p_OutputCollectionId->objid == NULL_OBJID ) return OM_E_INVARG;
		status = om$send( msg      = message ACrg_collect.AClist_attribute
                               		( &retcode, VR_MAX_ATTR, OutListAttr, &NbOutAttr),
				  senderid = NULL_OBJID,
				  targetid = p_OutputCollectionId->objid,
				  targetos = p_OutputCollectionId->osnum );
  		as$status( action = RET_STATUS );
  		as$status( sts = retcode, action = RET_STATUS );

		for (i=0; i<NbOutAttr; i++)
		{
			retcode = TRUE;

			status =
			om$send( msg      = message ACrg_collect.ACget_named_attribute
                                      		( &retcode, &OutListAttr[i] ),
                    		  senderid = NULL_OBJID,
                    		  targetid = p_InputCollectionId->objid,
                    		  targetos = p_InputCollectionId->osnum );
  			as$status( action = RET_STATUS );

			if( !retcode )
			{
				status =
				om$send( msg      = message ACrg_collect.ACrem_attribute
                                      	      ( &retcode, OutListAttr[i].name ),
                    		  	senderid = NULL_OBJID,
                    		  	targetid = p_OutputCollectionId->objid,
                    		  	targetos = p_OutputCollectionId->osnum );
  				as$status( action = RET_STATUS );
			}
		}
		}
	break;

        case VR_CLEAR_COLL :
             {
             if( p_OutputCollectionId->objid == NULL_OBJID ) return OM_E_INVARG;

             status = om$send( msg   = message ACrg_collect.ACset_list_attribute
                                                	( &retcode, 0, NULL ),
                            senderid = NULL_OBJID,
                            targetid = p_OutputCollectionId->objid ,
                            targetos = p_OutputCollectionId->osnum);
             as$status( action = RET_STATUS );

__DBGpr_com("All Attributes removed");
             }
        break;

	default : return OM_E_INVARG;

  }

  /*^ VRprint_user_attr( p_OutputCollectionId ); */

wrapup:

End;
  return (status) ;
}


/*--------------------------------------------------------------------
*       function VRModifyCollection2
*---------------------------------------------------------------------
*
* This function Modifies Collection. It is an extension of VRModifyCollection,
* which allows the output to be list. 
*---------------------------------------------------------------------
*
*  PARAMETERS:
*
*
* IGRlong	*msg	          :I = output status. 1 (default) is OK. 
*
* int		Operation         :I = Operation to perform:
*
* IGRint	InNumAttr         :I = Number of Input parameters to modify.
*
* struct GRid	*InParId          :I =Input collection ID if given must
*					be real object. 
*
* struct ACrg_coll *InAttrList    :I =Meaningful only if InParId = NULL
*					Input parameter list pointer. If given
*					then InNumAttr must be given also. 
*
* IGRint	   *OutNumAttr    :O =Number of attributes in the output list.
*					Doesn't make sence to be NULL. 
*
* struct ACrg_coll **OutAttList    :O = Address of Output parameter list pointer
*					Will allocate memory for you. 
*					The caller must free the memory.
*---------------------------------------------------------------------
* Note: OutAttList is assumed unique. I may output non ordered list.  
*	If specific order is needed modify _UNION_, _SUBSTR_ & _INTER_ cases. 
*
*	VR_INTER_COLL will output unique list, whatever the input. 
*
*	InAttrList need not be unique. 
*---------------------------------------------------------------------
*
* Possible Operations:
* VR_UPDATE_COLL= For the common attribute names, overwrite output with input.
* VR_UNION_COLL	= Add to the output all new attribute names from the input.
* VR_MERGE_COLL	= UPDATE + UNION.
* VR_SUBSTR_COLL= Remove from output all input attribute names.
* VR_INTER_COLL	= Remove from output all attribute names that are not in input.
* VR_CLEAR_COLL = Remove all attributes from the output list.Input is irrelevant
--------------------------------------------------------------------*/
IGRint VRModifyCollection2 ( 	IGRlong			*msg, 
				int			Operation,
				IGRint			InNumAttr,
				struct GRid		*InParId,
				struct ACrg_coll	*InAttrList, 
				IGRint			*OutNumAttr,
				struct ACrg_coll	**OutAttrList )
{
	IGRlong			retcode; 
	int			sts = 1, dummy = 0, 
				i, j, 
				exist, 
				TempNum, OutNum = 0; 
	struct ACrg_coll	*TempList = NULL, *pList = NULL, *p_OutList;


SetProc( VRModifyCollection2 ); Begin

/*-------------------
# Initialize 
---------------------*/
   if ( !InParId && !InAttrList ) { sts = 0; return sts;}
   if ( !OutAttrList ) {sts = 0; return sts ; }

   if ( OutNumAttr) OutNum = (int) *OutNumAttr;
   if ( !(*OutAttrList) ) OutNum = 0; 

   p_OutList = (*OutAttrList); 

/*-------------------
#  Get pointer to the input attribute list. 
---------------------*/
   if ( InParId ) { 
        sts    = om$send( msg      = message ACrg_collect.AClist_attribute
                                     ( &retcode, 0, TempList, &TempNum ),
                          senderid = NULL_OBJID,
                          targetid = InParId->objid,
                          targetos = InParId->osnum );
        as$status( sts = sts, action = GOTO_VALUE, value = wrapup);

	if ( TempNum == 0 ) { sts = 0; goto wrapup;}

        pList = _MALLOC( TempNum, struct ACrg_coll ); 
	TempList   = pList;

        sts    = om$send( msg      = message ACrg_collect.AClist_attribute
                                     ( &retcode, TempNum, TempList, &TempNum ),
                          senderid = NULL_OBJID,
                          targetid = InParId->objid,
                          targetos = InParId->osnum );
        as$status( sts = sts, action = GOTO_VALUE, value = wrapup);
   }
   else {
	TempList = InAttrList;
	TempNum  = (int) InNumAttr;
        if ( TempNum == 0 ) { sts = 0; goto wrapup;} 
   }


/*-------------------
#  Short cut if output collection is empty.
---------------------*/
   if ( OutNum == 0 ) {
      switch (Operation) { 
      	case VR_MERGE_COLL:
      	case VR_UPDATE_COLL:
      	case VR_UNION_COLL:
      	case VR_INTER_COLL:

	     if ( p_OutList ) { _FREE (p_OutList ); p_OutList = NULL; }

             p_OutList = _MALLOC( TempNum, struct ACrg_coll ); 

	     for ( i = 0; i < TempNum; i++ ) 
		 p_OutList [  i  ] =  TempList [  i  ]; 

             OutNum = TempNum;
	     break;
      }
      goto wrapup; 
   }
					
/*-------------------
# Main 
---------------------*/
   dummy = OutNum;

   switch (Operation) {
      case VR_MERGE_COLL:
      case VR_UPDATE_COLL:
           for ( j = 0; j < TempNum ; j++ )  
           for ( i = 0; i < OutNum  ; i++ ) {
                if ( !strcmp( p_OutList [ i ].name, TempList [ j ].name) ){
                   p_OutList [ i ] = TempList [ j ] ;
		   break;			/* OutAttrList assumed unique */
		}
           }
	   if ( Operation == VR_UPDATE_COLL )  break;


      case VR_UNION_COLL:
	   for     ( j = 0; j < TempNum ; j++ )  {
	       for ( i = 0; i < OutNum  ; i++ ) { 
		   if ( !strcmp(p_OutList [ i ].name, TempList [ j ].name))
			break; 
	       }
	       if ( i == OutNum  ) {
		   if ( !p_OutList) p_OutList = _MALLOC( 1, struct ACrg_coll);

		   p_OutList = _REALLOC( p_OutList, OutNum+1, struct ACrg_coll);
	           p_OutList [  OutNum++  ] = TempList [ j ] ;
	       }
	   }
	   break;


      case VR_INTER_COLL:
      case VR_SUBSTR_COLL:
           i = 0;
           while ( i < OutNum )  {
               for ( exist = -1, j = 0; j < TempNum ; j++ ) {
                   if ( !strcmp(p_OutList[ i ].name, TempList[ j ].name)) {
                        exist = i;
                        break;	
                   }
               }

	       if ( Operation  ==  VR_SUBSTR_COLL) { 
                   if(exist < 0) i++;
                   else          {OutNum--; p_OutList[ i ] =p_OutList[ OutNum];}
	       }
	       else {
                   if(exist < 0) {OutNum--; p_OutList[ i ] =p_OutList[ OutNum];}
	           else            i++; 
	       }
           }

	   if( OutNum == 0 ){ 
		_FREE( p_OutList ); p_OutList = NULL; OutNum = 0;}
	   else if ( dummy != OutNum ) 
                p_OutList = _REALLOC( p_OutList, OutNum, struct ACrg_coll);

	   break;

      case VR_CLEAR_COLL:
	   if ( p_OutList ){ _FREE ( p_OutList ); p_OutList = NULL; OutNum = 0;}
	   break;
   }


wrapup:
   if (pList) _FREE (pList);
   pList = NULL; 

   if ( OutNumAttr ) *OutNumAttr = (IGRint) OutNum;
   if ( OutAttrList) *OutAttrList= p_OutList; 

   *msg = sts;

End;
   return (sts);
}




end implementation Root;


