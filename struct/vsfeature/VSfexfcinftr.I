/* $Id: VSfexfcinftr.I,v 1.2 2001/01/17 00:04:06 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:	struct/vsfeature / VSfexfcinftr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfexfcinftr.I,v $
 *	Revision 1.2  2001/01/17 00:04:06  ramarao
 *	*** empty log message ***
 *	
# Revision 1.1  2000/06/27  15:08:48  pinnacle
# Created: struct/vsfeature/VSfexfcinftr.I by jwfrosch for Service Pack
#
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	06/27/00	HF	Modify free() ==>> _FREE()
 *
 * -------------------------------------------------------------------*/

class implementation VSfeature ;

#include <stdlib.h>
#include "OMmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetchildrn.h"
/*----------------------------------------------------------------------------*/
method VSexecuteFunctionInFuture(
		int   (*functionToExecute)( const struct GRid *target,
					    void	      *argsOfFunction );
		void  *argsOfFunction ) {

	/*
	 * Execute function on yourself and the forward this very message
	 * to the children consuming you.
	 */
	long		sts ;		/* OM return code		*/
	struct GRid	moi ;		/* My little self		*/

	moi.objid	= my_id ;
	moi.osnum	= OM_Gw_current_OS ;

	if( !(*functionToExecute)( &moi, argsOfFunction ) ) {
	  /*
	   * We stop sending here...
	   */
	  sts = OM_S_SUCCESS ;
	} else {
	  /*
	   * Send same message to consuming children. There is is generaly one
	   * consuming child but for divided features the division manager is
	   * consumed by all its children. Since the consuming children may not
	   * necessarily be a direct one (on my to-children channel), but
	   * interfaced to me via an ACpretend (if I am in a macro and child is
	   * not) or an ACpretendin (if I am  not in the same design file as my
	   * child) object, `VSgetChildren' gets all types of children (in same
	   * OS or in other OSes), and message `VSisChildConsumingMe' does the
	   * necessary magic to find the consuming VSfeature-kind of object.
	   */
	  long		msg ;
	  struct GRid	*myChildren,	/* My children			*/
			virtChild ;	/* My virtual consuming child	*/
	  int		cnt,		/* Count of children		*/
			i ;		/* Loop index			*/

	  sts = VSgetChildren( &msg, &moi, &cnt, &myChildren ) ;
	  __CheckRC( sts, msg, "VSgetChildren", endLoop ) ;

	  for( i = 0 ; i < cnt ; i++ ) {

	     int isConsumer ;
	     sts = om$send( msg      = message VSfeature.VSisChildConsumingMe(
	                                              &msg, myChildren + i,
	                                              &isConsumer, &virtChild ),
	                    targetid = my_id ) ;
	     __CheckRC( sts, msg, "VSfeature.VSisChildConsumingMe", endLoop ) ;

	     if( isConsumer ) {

	       /*
	        * This one consumes me, send him message !
	        */
	       sts = om$send(	msg	= OPPmargs,
				targetid= virtChild.objid,
				targetos= virtChild.osnum ) ;
	       __CheckRC( sts, msg, "VSexecuteFunctionInFuture", endLoop ) ;

	     } /* if */
	  } /* for */
	  endLoop :
	  	if( cnt ) _FREE( myChildren ) ;
	}

	return sts ;

} /* method VSexecuteFunctionInFuture */
/*----------------------------------------------------------------------------*/
struct VSlistOfGRids {
	struct GRid		grid ;
	struct VSlistOfGRids	*next ;
} ;
static long VS__trackDescendent(  long			*msg,
				  const struct GRid	*target,
				  const struct GRid	*descendent,
				  int			*foundIt,
				  struct VSlistOfGRids	**list ) {

	  long		sts ;
	  struct GRid	*children = NULL,	/* Children of target	   */
			virtChild ;		/* Virtual consuming child */
	  int		cnt,			/* Count of children	   */
			i ;			/* Loop index		   */
	  struct VSlistOfGRids	*next = NULL ;

	  *foundIt = FALSE ;

	  sts = VSgetChildren( msg, target, &cnt, &children ) ;
	  __CheckRC( sts, *msg, "VSgetChildren", wrapup ) ;

	  for( i = 0 ; i < cnt ; i++ ) {

	     int isConsumer ;
	     sts = om$send( msg      = message VSfeature.VSisChildConsumingMe(
	                                              msg, children + i,
	                                              &isConsumer, &virtChild ),
	                    senderid = NULL_OBJID,
	                    targetid = target->objid,
	                    targetos = target->osnum ) ;
	     __CheckRC( sts, *msg, "VSfeature.VSisChildConsumingMe", wrapup ) ;

	     if( isConsumer ) {
	       /*
	        * This one consumes 'target', is it the looked-for descendent ?
	        */
	       if( IF_EQ_GRID( virtChild, *descendent ) ) {
	       	 *foundIt = TRUE ; break ;
	       } else {
	       	 sts = VS__trackDescendent( msg, &virtChild, descendent,
	       	 				foundIt, list ) ;
	       	 __CheckRC( sts, *msg, "VS__trackDescendent", wrapup ) ;
	       	 if( *foundIt ) { next = *list ; break ; }
	       }

	     } /* if */

	  } /* for */

	if( *foundIt ) {
		*list = _MALLOC( 1, struct VSlistOfGRids ) ;
		(*list)->grid = *target ;
		(*list)->next = next ;
	}
	wrapup :
		if( cnt ) _FREE( children ) ;
		return sts ;

} /* VS__trackDescendent */
/*----------------------------------------------------------------------------*/
method VStrackDescendent( const struct GRid	*descendent ;
			  int			*size ;
			  struct GRid		**generation ) {

	/*
	 * Collects the ids of the history nodes between you and your descendent
	 *
	 *                          |
	 *                        A + <- you
	 *                         / \
	 *                      B +   + C
	 *                       / \
	 *                    D +   + E
	 *                     / \
	 *                  F +   + G <- descendent
	 *
	 * The list returned will be A, B, D, G.
	 */
	long			sts	= OM_S_SUCCESS ;
	struct VSlistOfGRids	*list	= NULL ;

	*size		= 0 ;
	*generation	= NULL ;

	if(    !IF_EQ_OBJID( my_id, descendent->objid )
	    || OM_Gw_current_OS != descendent->osnum ) {

		long		msg ;
		struct GRid	moi ;
		int		foundIt = FALSE ;

		moi.objid =  my_id ; moi.osnum = OM_Gw_current_OS ;
		sts = VS__trackDescendent( &msg, &moi, descendent,
					   &foundIt, &list ) ;
		__CheckRC( sts, msg, "VS__trackDescendent", wrapup ) ;

		if( foundIt ) {
			int			count	= 0 ;
			struct VSlistOfGRids	*l	= list ;

			while( l ) { count++ ; l = l->next ; }

			count += 1 ; /* Add 'descendent' in list */
			*generation = _MALLOC( count, struct GRid ) ;

			(*generation)[count-1]	= *descendent ;

			for( count = 0, l = list ; l ; count++ ) {

				struct VSlistOfGRids	*next = l->next ;
				(*generation)[count] = l->grid ;
				_FREE( l ) ;
				l = next ;
			}
			*size = count + 1 ;
		}
	}

	wrapup :
		return sts ;

} /* method VStrackDescendent */
/*----------------------------------------------------------------------------*/
method VSexecuteFunctionAlongGeneration(

	const struct GRid  *descendent ;
	int                (*functionToExecute)( const struct GRid *target,
					         void	      *argsOfFunction );
	void               *argsOfFunction ;
	int                goOnAfterDescendent ) {

	long		sts ;
	struct GRid	*generation	= NULL ;
	int		count		= 0 ;

	if( !descendent ) {
	  sts = om$send( msg = message VSfeature.VSexecuteFunctionInFuture(
     			 		    functionToExecute, argsOfFunction ),
     		         targetid= my_id ) ;
	} else if( IF_EQ_OBJID( my_id, descendent->objid ) 
		   && OM_Gw_current_OS == descendent->osnum ) {
	  if( goOnAfterDescendent ) {
	    sts = om$send( msg = message VSfeature.VSexecuteFunctionInFuture(
     					functionToExecute, argsOfFunction ),
     			   targetid= my_id ) ;
	  } else {
	    struct GRid	moi ;
	    moi.objid	= my_id ;
	    moi.osnum	= OM_Gw_current_OS ;

	    (*functionToExecute)( &moi, argsOfFunction ) ;
	    sts = OM_S_SUCCESS ;
	  }
	} else {
	  /*
	   * Execute function on the generation between you and descendent,
	   * including you and descendent. Optionally executes the function on
	   * descendent's future (i.e. all generations AFTER descendent).
	   */

	  sts = om$send(msg	= message VSfeature.VStrackDescendent(
					     descendent, &count, &generation ),
			targetid= my_id ) ;
	  __CheckRC( sts, 1, "VSfeature.VStrackDescendent", wrapup ) ;

	  {
	    int	max	= count ;
	    int	i ;
	    int	stop	= FALSE ;

	    /* Don't do it twice on descendent */
            if( goOnAfterDescendent ) count-- ;

	    for( i = 0 ; i < max ; i++ ) {
	      if( !(*functionToExecute)( generation + i, argsOfFunction ) ) {
		  /*
		   * We stop processing here...
		   */
		  stop = TRUE ; break ;
	      }
	    }
	    if( count > 0 && goOnAfterDescendent && !stop ) {
	       sts = om$send( msg = message VSfeature.VSexecuteFunctionInFuture(
     					functionToExecute, argsOfFunction ),
     			      targetid= descendent->objid,
     			      targetos= descendent->osnum ) ;
	    }
	  }
	}
	  
	wrapup :
		if( count ) _FREE( generation ) ;
		return sts ;
		
} /* method VSexecuteFunctionAlongGeneration */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;

