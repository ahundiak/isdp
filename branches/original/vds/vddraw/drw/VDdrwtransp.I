/* $Id $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwtransp.I
 *
 * Description:
 *		The function described in this file does the sort the
 *		objects and keep only the owner object in the list.
 *		Input List will be output list.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwtransp.I,v $
 *	Revision 1.3  2001/09/04 14:24:07  ramarao
 *	Fixed TR# 5534.
 *	
 *	Revision 1.2  2001/09/02 18:31:59  ad
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/18  18:37:40  pinnacle
# Created: vddraw/drw/VDdrwtransp.I by azuurhou for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/16/98	adz		creation date
 *
 ***************************************************************************/

class implementation VDSroot ;

#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "adpdef.h"
#include "grgsmacros.h"
#include "EMSmsgdef.h"
#include "v_drwdef.h"
#include "v_drwenv.h"
#include "v_drw.h"
#include "vddrwattr.h"
#include "vdsetmacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */

/*----------------------------------------------------------------------------*/
int VD_drwGetSelectSetObjects( msg, inp, xData, setCount, setList, setRange )
long			*msg ;		/* O */
VD_drwInputData		*inp ;		/* I : Reference Input */
VD_drwExecData		*xData ;	/* I : Reference Data */
int			*setCount ;	/* O : number of objects list */	
struct	GRobj_env	**setList ;	/* O : input list */
GRrange			**setRange ;	/* O : range of list */
{
	/*
	 * This function will check if drawing objects are part of a 
	 * define object selection criteria 'selectMask'. When this is 
	 * valid, the model objects (plate, beam, etc) will be retrieved
	 * for processing and there range will get calculated.
	 */

	long			sts = OM_S_SUCCESS ;
	int			i,
				oCount,
				selectMask;
	IGRboolean		world ;
	GRrange			*range ,
				errRange ;
	IGRushort		mask = VD_B_drwDefaultMask ;
	VDpartAttr		attr ;
	struct GRobj_env	*list ;
	
	SetProc( VD_drwGetSelectSetObjects ); Begin

	*msg		= MSSUCC ;
	*setCount	= 0 ;
	*setList	= NULL ;
	*setRange	= NULL ;	

	__DBGpr_str(" refSetName ", inp->refSetName );

        sts =
        VDdrwMgrGetInfo(        msg,
                                inp->drwInfo.drwEnv,
                                VD_O_drw2dObj,          /* Locate Mask  */
                                inp->refSetName,        /* VDdrw2dVw    */
                                &mask,                  /* Locate Type  */
                                setCount,               /* Number found */
                                NULL,			/* No GRid      */
                                setList );              /* list of objs */
        __CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

        __DBGpr_int( "List of objects", *setCount );

        if( *setCount == 0 ){
		__DBGpr_str(" Nothing found with ", inp->refSetName );
		 goto wrapup;
	}

	/*
	 * Check for father object of the located objects and put the valid
	 * into the 'setList' structure.
	 */
	oCount	= 0 ;
	list	= *setList ;

	for( i=0 ; i<*setCount ; i++ ){

	    /* get mask */
	    attr.Iwant = VD_I_drwSelectMask ;
	    sts =
	    _VD_SEND_OBJN( list[i]._grid, GRvg.GRgetattr(msg,(char *)&attr));
	    __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

	    selectMask = (int) attr.aType;

	    /*
	     * check if object has trasnsparent Select flag set.
	     */
	    __DBGpr_int(" selectMask ", selectMask );

	    if ( selectMask == VD_K_drwTrans ) continue ;

	    /*
             * Check object trasparently level. Only accept object at 
	     * the same level or lower (Level_1 < Level_2)
	     */
	    if( selectMask <= xData->selectMask ){

		/*
		 * Get the parent Object
		 */
		__DBGpr_obj(" SelectMask Accepted", list[i]._grid );
		attr.Iwant = VD_I_drwParentObj ;
               	sts =
		_VD_SEND_OBJN(	list[i]._grid,
				GRvg.GRgetattr( msg, (char *)&attr ));
		if( !(sts&*msg&1)) continue ;

		memcpy( list +oCount, &attr.obj,  sizeof( struct GRobj_env));
		__DBGpr_obj(" Added Model", attr.obj._grid );
		oCount++ ;
	    } /* if selectMask ... */
	}

	*setCount = oCount ;
	__DBGpr_int( "List of objects", *setCount );
	if ( *setCount <= 0 ) goto wrapup;
				
	if( !( *setRange = _MALLOC( *setCount , GRrange )))
		vd_$mem_fail();

	/*
	 * Calculate the Object Range of the objects and store them in the
	 * internal structure.
	 */
	world	= TRUE ;
	range	= *setRange ;
	list	= *setList ;

	errRange[0] = errRange[1] = errRange[2] = -GR_MAXDOUBLE ;
	errRange[3] = errRange[4] = errRange[5] =  GR_MAXDOUBLE ;

	for( i=0 ; i<*setCount ; i++ ){

		sts =
		om$send(msg	= message GRgraphics.GRgetrang(
						msg,
						&list[i]._matrix_type,
						list[i]._matrix,
						&world,
						range[i] ),
			targetid = list[i]._objid,
			targetos = list[i]._osnum,
			senderid = list[i]._objid );
		if( !( sts & *msg & 1 )){
			__DBGpr_obj(" Invalid Range ", list[i]._grid );
			OM_BLOCK_MOVE( errRange, range[i], 6 * sizeof(double));
		}
	}
				
	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup:

		if( !( sts & *msg & 1 )){
			__DBGpr_com(" Accept original list as output ");
			if( *setCount )		*setCount = 0 ;
			_FREE( *setList );	*setList  = NULL ;
			_FREE( *setRange );	*setRange = NULL ;
			sts = OM_S_SUCCESS ;
			*msg = MSSUCC ;
		}

		End
		return sts ;

} /* VD_drwGetSelectSetObjects */

end implementation VDSroot ;
