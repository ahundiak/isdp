 /*
	I/STRUCT
*/
class implementation VScompptCmd ;

#include <stdio.h>
#include <stdlib.h>
#include "COBmacros.h"
#include "dpmacros.h"
#include "godef.h"
#include "go.h"
#include "growner.h"
#include "nddef.h"
#include "asbox.h"
#include "EMSmsgdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vscmddef.h"
#include "vsdef.h"
#include "vs.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsophstproto.h"

from VSfeature		import VSgetOperationHistory ;
from NDnode		import NDget_objects,
			       NDchange_connect,
			       NDdisconnect,
			       NDconnect,
			       NDdelete,
			       NDchange_node ;
from GRgraphics		import GRchgprops ;
/*----------------------------------------------------------------------------*/
method operation( long * msg ) {
	
	long 			sts ;
	struct GRobj_env	*part = NULL ;
	int			i ;
	
	ex$message(	msgnumb		= VS_gI_Processing,
			justification	= CENTER_JUS ) ;

	/*
	 * Get located parts.
	 */
	part = _MALLOC( me->oprndCount, struct GRobj_env ) ; 
	if( !part ){
		sts  = OM_E_NODYNMEM ;
		*msg = EMS_E_NoDynamicMemory ;
		goto wrapup ;
	}
	sts = om$send( msg	= message VSlocateCmd.getLocObjs( 
								msg,
								me->oprndCount,
								part ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;
	
	dp$erase_hilite( msg = msg ) ;

	/*
	 * Compress part.
	 */
	for( i = 0 ; i < me->oprndCount ; i++ ) {
		
		sts = om$send( msg	= message VScompptCmd.VScompressPart(
								msg, part[i] ),
			       targetid = my_id ) ;
		__CheckRC( sts, *msg, "VScompptCmd.VScompressPart", wrapup ) ;
	}
	
	wrapup :
		_FREE( part ) ;
		ex$message( 	field 	= ERROR_FIELD,
				in_buff	= "" ) ;
				
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

	return OM_S_SUCCESS ;
	
} /* method operation */
/*----------------------------------------------------------------------------*/
method VScompressPart( long *msg ; struct GRobj_env part ) {
	
	long		sts ;
	VSopHistory	*history	= NULL,
			*h		= NULL,
			*startPart	= NULL,
			*endPart	= NULL,
			*compressPart	= NULL,
	                *LastPart	= NULL ;
	struct GRid	*children,
	                *parents,
	                compressId,
	                startPartId ;
	int		mask,
			compress,
			childrenCount,
			parentCount,
			i,
			compressDone = FALSE ;
	short		action,
			maskProp ;
			
	
	/*
	 * Get history of part.
	 */
	sts = om$send( msg	= message VSfeature.VSgetOperationHistory(
						msg, &part.mod_env, &history ),
		       targetid = part._objid,
		       targetos = part._osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;
	
	/*
	 * Set mask. All elements which have the value of argument `resultType'
	 * with the following mask will be compressed.
	 */
	mask = VS_m_COMPRESSABLE ;
		
	/*
	 * Find elements 'startPart' and 'endPart' which have the same 
	 * `resultType'.
	 */
	compress = FALSE ;

	for( h = history ; h ; h = h->next ) {

		endPart = h->next ;
		
		if( !endPart ) LastPart = h ;

		if(    ( h->resultType & mask )
		    && !( h->resultType & VS_m_IN_ASSEMBLY )
		    && !startPart
		    && endPart
		    && ( endPart->resultType == h->resultType ) ) {
		    	startPart = h ;
		}
		
		if(    (    startPart
		         && ( startPart != h )
			 && endPart
		         && ( endPart->resultType != startPart->resultType )
		       )
		    || (    !endPart
		    	 && startPart
		    	 && ( startPart->resultType == h->resultType )
		        ) ) {
		    	endPart = h ;
		    	compress = TRUE ;
		}
		
		if( compress ) {
			/*
			 * Get children and roots of part startPart->next
			 * until endPart and connect to startPart.( The fisrt
			 * root isn't connected, because it's a part ).
			 */
			 
			for( compressPart =  startPart->next ; 
			     compressPart != endPart->next ;
			     compressPart =  compressPart->next ) {

				compressId.objid = compressPart->resultId ;
				compressId.osnum = compressPart->resultOs ;
				
				/*
				 * Get children.
				 */			     	
			   	sts = om$send( 
			   		msg	= message NDnode.NDget_objects(
			   				ND_CHILDREN | ND_IN_BUF,
			   				NULL,
			   				0,
			   				&children,
			   				0,
			   				OM_K_MAXINT,
			   				&childrenCount ),
			   	        targetid = compressPart->resultId,
			   	        targetos = compressPart->resultOs ) ;
				__CheckRC( sts, 1, "NDnode.NDget_objects",
				           wrapup ) ;
				           
				/*
				 * Connect children to startPart.
				 */
				startPartId.objid = startPart->resultId ;
				startPartId.osnum = startPart->resultOs ;
			
				for( i = 0 ; i < childrenCount ; i++ ) {

					sts = om$send( msg	= message 
						NDnode.NDchange_connect( 
							1,
							&compressId,
							&startPartId ),
						 targetid = children[i].objid,
						 targetos = children[i].osnum ) ;
					__CheckRC( sts, 1, "NDnode.NDchange_connect",
					           wrapup ) ;
					           
				}

				/*
				 * Get parents.
				 */
			   	sts = om$send( 
			   		msg	= message NDnode.NDget_objects(
			   				ND_ROOT | ND_IN_BUF,
			   				NULL,
			   				0,
			   				&parents,
			   				0,
			   				OM_K_MAXINT,
			   				&parentCount ),
			   	        targetid = compressPart->resultId,
			   	        targetos = compressPart->resultOs ) ;
				__CheckRC( sts, 1, "NDnode.NDget_objects",
				           wrapup ) ;
				           
				/*
				 * Connect parents to startPart.
				 * Note : The first parent is already a part
				 * not to be connected.
				 */
				for( i = 1 ; i < parentCount ; i++ ) {
					
					sts = om$send( msg	= message 
						NDnode.NDdisconnect(
								1,
								&parents[i] ),
						targetid = compressPart->resultId,
						targetos = compressPart->resultOs ) ;
					__CheckRC( sts, 1, "NDnode.NDdisconnect",
					           wrapup ) ;

					sts = om$send( msg	= message 
						NDnode.NDconnect( 
								1,
								&parents[i],
								NULL_GRID,
								ND_ADD ),
								
						targetid = startPart->resultId,
						targetos = startPart->resultOs ) ;
					__CheckRC( sts, 1, "NDnode.NDconnect",
					           wrapup ) ;
				} 
					          
				/*
				 * Disconnect startPart->next from startPart.
				 */
				 
				sts = om$send( msg	= message 
					NDnode.NDdisconnect(
							1,
							&startPartId ),
					targetid = compressPart->resultId,
				        targetos = compressPart->resultOs ) ;
                               __CheckRC( sts, 1, "NDnode.NDdisconnect",
			                  wrapup ) ;
				
				/*
				 * Delete the part.
				 */
				 
				sts = om$send( msg = message NDnode.NDdelete(
						     &compressPart->resultEnv ),
					       targetid = compressPart->resultId,
					       targetos = compressPart->resultOs ) ;
				__CheckRC( sts, 1, "NDnode.NDdelete", wrapup ) ; 
				
				if( !compressPart->next ) 
					LastPart = startPart ; 
				
			}
#ifdef vsDEBUG
	/*
	 * Show the children and parents of part `startPart'.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects(
							ND_CHILDREN | ND_IN_BUF,
			   				NULL,
			   				0,
			   				&children,
			   				0,
			   				OM_K_MAXINT,
			   				&childrenCount ),
	   	       targetid = startPart->resultId,
		       targetos = startPart->resultOs ) ;
		       
	printf("The new children of part [%d,%d] are : \n",startPart->resultOs,
							   startPart->resultId ) ;
	
	if( !( sts & 1 ) ) printf( "Get new children FAILED\n" ) ;
	else for( i = 0 ; i < childrenCount ; i++ )
			printf("\t[%d,%d]\n",children[i].osnum,
					     children[i].objid  ) ;

	sts = om$send( msg	= message NDnode.NDget_objects(
							ND_ROOT | ND_IN_BUF,
			   				NULL,
			   				0,
			   				&parents,
			   				0,
			   				OM_K_MAXINT,
			   				&parentCount ),
	   	       targetid = startPart->resultId,
		       targetos = startPart->resultOs ) ;
	
	printf("The new parent of part [%d,%d] are : \n",startPart->resultOs,
						         startPart->resultId ) ;
	
	if( !( sts & 1 ) ) printf( "Get new parent FAILED\n" ) ;
	else for( i=0; i<parentCount; i++ )
			printf("\t[%d,%d]\n",parents[i].osnum,
					     parents[i].objid  ) ;
#endif				     
				    
			startPart = NULL ;
			compress = FALSE ;
			compressDone = TRUE ;
		}
	}
	
	/*
	 * If a compress was done : 
	 *	- Set last part displayable and locatable.
	 * 	- Recompute.
	 */
	 
	if( compressDone ) {

		action = 1 ;
		maskProp = GRIS_DISPLAYABLE | GRIS_LOCATABLE ;
		
		sts = om$send( msg	= message GRgraphics.GRchgprops( 
								msg,
								&action,
							 	&maskProp ),
			       targetid = LastPart->resultId,
			       targetos = LastPart->resultOs ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup ) ;
		
	 
		/*
	 	 * Recompute.
	 	 */

		sts = om$send( msg	= message NDnode.NDchange_node( 
							  &history->resultEnv ),
			       targetid = history->resultId,
			       targetos = history->resultOs ) ;
		__CheckRC( sts, 1, "NDnode.NDchange_node", wrapup ) ;
	}

	wrapup :
		if( !( sts & *msg & 1 ) ) *msg = MSFAIL ;
		else *msg = MSSUCC ;
		
		VSfreeOpHistory( history ) ;
			
	return OM_S_SUCCESS ;
	
} /* method VScompressPart */
/*----------------------------------------------------------------------------*/

end implementation VScompptCmd ;
