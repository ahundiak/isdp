
/* $Id: VDcheckCorr.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vddraw/func/VDcheckCorr.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcheckCorr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/07/28  20:37:06  pinnacle
# Created: vddraw/func/VDcheckCorr.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 ***************************************************************************/

class implementation VDSroot;

#include <stdio.h>
#include <math.h>
#include "OMprimitives.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "griomacros.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"

extern	OMuword		OPP_GRgrset_class_id ;

/*
#define	DEBUG	1
 */

#define _REALLOC( ptr, nelem, type ) \
        (type *) realloc( (ptr), (unsigned) ( (nelem) * sizeof( type ) ) )


/*
 * ------------------------------------------------------------------------
 */

VD_objCheckInputOnCorrObject(   msg, objCount, objList )

long			*msg ;
int			*objCount ;
struct	GRobj_env	*objList[] ;
{
IGRint			sts = OM_S_SUCCESS,
			cpCount  = 0,
			outCount = 0,
			eqCount  = 0,
			pCount   = 0,
			freeList = FALSE ,
			i, j, k ;
OMuword			classId ;
struct	GRid		*cpList  = NULL ,
			cpObj ;
struct	GRobj_env	*pList   = NULL ,
			*outList = NULL ;

	SetProc( VD_objCheckInputOnCorrObject ); Begin

	pList  = *objList ;
	pCount = *objCount ;

#ifdef	vdsDEBUG
	__DBGpr_com(" List of Input Objects ");
	for( i=0 ; i< pCount ; i++ )	VD_ShowObj( & pList[i]._grid );
#endif

	sts =
	om$get_classid(	classname	= "VRCorrection",
			p_classid	= &classId );

	if( !( sts&1 )){
		/*
		 * I/ROUTE is probably non-active.
		 */
		goto wrapup;
	}

	for( i=0 ; i<pCount ; i++ ){

	    if( vd_$is_ancestry_valid(
				object	= &(pList[i]._grid),
				classid	= classId )){
		
		sts = 
		vd_$get_components(msg		= msg,
				grobjId		= &(pList[i]._grid),
				grobjEnv	= &(pList[i].mod_env),
				number		= &cpCount,
				components	= &cpList ); 

		freeList = TRUE ;

		if( ! cpCount ){
			_FREE( cpList );
			cpList = NULL ;
	    		freeList = FALSE ;
			cpCount = 0 ;
			continue ;
	    	}
		__CheckRC( sts, *msg, "vd_$get_components", wrapup );
	    }
	    else{

		/*
		 * set the object self.
		 */
		cpObj   = pList[i]._grid ;
		cpList  = &cpObj ;
		cpCount = 1 ;
	    }

	    /*
	     * save the components in a buffer.
	     */

	    if( outCount ) {
		if( !( outList = _REALLOC(	outList,
						outCount + cpCount,
                                                struct GRobj_env ) ) )
                        vd_$mem_fail() ;
	    } else {
		if( !( outList = _MALLOC( cpCount, struct GRobj_env ) ) )
                        vd_$mem_fail() ;
	    }

	    eqCount = 0 ;
	    for( j=0 ; j<cpCount ; j++ ){

		/*
		 * check if object already in list 
		 */
		for( k=0 ; k<outCount ; k++ ){
			if( IF_EQ_GRID( outList[k]._grid, cpList[j] ) )
			{
				break ;
			}
		}

		if( k==outCount ){

                	outList[outCount+eqCount]._grid   = cpList[j] ;
			outList[outCount+eqCount].mod_env = pList[i].mod_env ;

			/*
			 * find proper foot env (header objects).
			 */

#ifdef	LATER
			sts =
			VD_drwGetObjFootEnv(msg,
					&(cpList[j]),
					&(pList[i].mod_env),
					&(outList[outCount+eqCount].mod_env ));
			if( !( sts&*msg&1 )){
			  outList[outCount+eqCount].mod_env = pList[i].mod_env ;
			}
#endif 

			eqCount++ ;
		}
	    }

	    outCount += eqCount ;

	    if( freeList ){
		_FREE( cpList );
	    }
	    freeList = FALSE ;
	    cpList  = NULL ;
	    cpCount = 0 ;
	}

	pCount = outCount ;
	pList  = outList ;

#ifdef	vdsDEBUG
	__DBGpr_com(" List of Output Objects ");
	for( i=0 ; i< pCount ; i++ )	VD_ShowObj( & pList[i]._grid );
#endif

	/*
	 * free the old buffer.
	 */
	_FREE(	*objList );

	*objList  = outList ;
	*objCount = outCount ;

	sts = OM_S_SUCCESS ;
	*msg = MSSUCC ;

wrapup:

	if( freeList ){
		_FREE( cpList );
	}

	return sts ;
}

end implementation VDSroot;
