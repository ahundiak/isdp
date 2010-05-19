/* $Id: VDdrwfdsetob.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/* I/VDS
 *
 * File:	 vddraw/drw/VDdrwfdsetob.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Reference:
 *	$Log: VDdrwfdsetob.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/12  16:08:08  pinnacle
# Replaced: vddraw/drw/VDdrwfdsetob.I for:  by impd for vds
#
# Revision 1.3  1998/03/29  16:06:10  pinnacle
# ah
#
# Revision 1.2  1998/03/27  08:59:50  pinnacle
# Replaced: vddraw/drw/VDdrwfdsetob.I for:  by vgnair for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/06/27  18:29:32  pinnacle
# Replaced: vddraw/drw/VDdrwfdsetob.I for:  by azuurhou for vds.240
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/03/95  adz     Creation date.
 * 03/29/98  vini    TR179800315
 * 03/29/98  ah	     Deleted extern from VDdrwUseSetBuffer
 * 04/12/98  adz     Testing setCount == 0  and return statements.
 */

class implementation VDSroot ;

#include <stdlib.h>
#include <values.h>
#include "OMmacros.h"
#include "asbox.h"
#include "exdef.h"
#include "exmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "EMSmsgdef.h"
#include "vddrwattr.h"
#include "vd_ve.h"
#include "v_drw.h"
#include "v_drwenv.h"
#include "v_vedef.h"
#include "v_edgedef.h"
#include "v_edgemacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_vecmxproto.h"
#include "v_virtualinf.h"


struct	VDdrw_setInfo {

	IGRchar			name[20];
	IGRint			count ;
	struct	GRobj_env	*list ;
	GRrange			*range ;
	struct	VDdrw_setInfo	*next ;
};

%safe
/*
 * Flag to active the internal set.
 */
IGRboolean			VDdrwUseSetBuffer = FALSE ;
// extern			VDdrwUseSetBuffer() ;

/*
 * Internal pointer to keep information.
 */
static	struct	VDdrw_setInfo	*VDdrwSetList	= NULL ;

%endsafe

/*----------------------------------------------------------------------------*/
void VD_drwClearSetBuffer( ) {

	struct	VDdrw_setInfo	*p = VDdrwSetList ;
	struct	VDdrw_setInfo	*n = NULL ;

	SetProc( VD_drwClearSetBuffer ); Begin

	while( p ) {
		_FREE( p->list );
		_FREE( p->range );
		n = p->next ;
		_FREE( p ) ;
		p = n ;
	}

	VDdrwSetList	= NULL ;

	End

} /* VD_drwFreeOutputData */

/*----------------------------------------------------------------------------*/
long VD_drwIfSetInBuffer( msg, setName, setInfo )

IGRlong			*msg ;
IGRchar			*setName ;
struct	VDdrw_setInfo	**setInfo ; {

	/*
	 * See if the setName is already in the internal list.
	 */
	IGRint			sts = MSSUCC ;
	struct	VDdrw_setInfo	*info = VDdrwSetList ;

	SetProc( VD_drwIfSetInBuffer ); Begin 

	*msg = MSSUCC ;
	*setInfo = NULL ;

	if( ! info ) return sts ;

	while( info ){

		__DBGpr_str( "Current Set ", info->name );
		__DBGpr_int( "Current Size", info->count );

		if( strcmp( info->name, setName ) == 0 ){

			*setInfo = info ;
			break ;
		}
		info = info->next ;
	}

	End
	return sts ;
}

/*----------------------------------------------------------------------------*/
long VD_drwAddSetToBuffer( msg, setName, setCount, setList, setRange )

IGRlong			*msg ;
IGRchar			*setName ;
int			*setCount ;
struct	GRobj_env	**setList ; 
GRrange			**setRange ; {

	IGRint			sts	= MSSUCC ;
	struct	VDdrw_setInfo	*info	= VDdrwSetList ;
	struct	VDdrw_setInfo	*tail	= NULL ;
	struct	VDdrw_setInfo	*new	= NULL ;
	struct	GRobj_env	*list ;
	GRrange			*range ;

	SetProc( VD_drwAddSetToBuffer ); Begin 

	*msg = MSSUCC ;

	/*
	 * Check if you are creating a list of objects ...
	 */
	if( ! *setCount ){
		__DBGpr_str(" Set with no objects ", setName );
		goto wrapup;
	}

	/*
	 * Check if the set already exist in the list.
	 */

	while( info ){

		__DBGpr_str( "Current Set ", info->name );
		__DBGpr_int( "Current Size", info->count );
		tail	= info ;
		info	= info->next ;
	}

	/*
	 * Adding the list to the end.
	 */
	if( ! info ){
		/*
		 * Having a new list
		 */
		new = info = _MALLOC( 1, struct VDdrw_setInfo ) ;
		VDdrwSetList  = new ;
	}
	else{
		/*
		 * add at the end of current list.
		 */
		new = tail->next = _MALLOC( 1, struct VDdrw_setInfo ) ;
	}
        if( new ) {

		strcpy(	new->name,	setName );
                new->count		= *setCount ;
                new->list		= NULL ;
                new->next		= NULL ;

		if( !( new->list = _MALLOC( *setCount , struct GRobj_env )))
			vd_$mem_fail();

		if( !( new->range = _MALLOC( *setCount , GRrange )))
			vd_$mem_fail();

		list = *setList ;
		range = *setRange ;
		OM_BLOCK_MOVE(	range,	new->range,
				*setCount * sizeof( GRrange ));
		OM_BLOCK_MOVE(	list,	new->list,
				*setCount * sizeof( struct GRobj_env ));
        }

	wrapup :

		End 
		return sts ;
}

/*----------------------------------------------------------------------------*/
long VD_drwGiveSetObjects( msg, mdEnv, setName, setCount, setList, setRange )

IGRlong			*msg ;
struct	GRmd_env	*mdEnv ;
IGRchar			*setName ;
int			*setCount ;
struct GRobj_env	**setList ; 
GRrange			**setRange ; {

	/*
	 * Given a setName, this function returns the found objects in the
	 * set.
	 * Internal buffering allows use to speed up performance processing.
	 * ------
	 *	'*setList' is allocated and hence must be freed by the caller
	 *	with 'free( *setList )'.
	 *	'*setRange' is allocated and hence must be freed by the caller
	 *	with 'free( *setRange )'.
	 */

	IGRint			sts = OM_S_SUCCESS, /* completion code.	*/
				i ;
	IGRboolean		world;		/* Compute the world range */
	IGRushort		mask = VD_B_drwDefaultMask ;
	struct	GRobj_env	*list ;
	GRrange			*range ,
				errRange ;

	SetProc( VD_drwGiveSetObjects ); Begin

	/*
	 * initialization output list.
	 */
	*msg     = MSSUCC ;

	*setCount = 0 ;
	*setList  = NULL ;
	*setRange = NULL ;

	sts =
	VDdrwMgrGetInfo(	msg,
				mdEnv,
				VD_O_drw2dPar,		/* Locate Mask	*/
				setName,		/* VDdrw2dVw	*/
				&mask,			/* Locate Type	*/
				setCount,		/* Number found */
				NULL,	
				setList );		/* list of objs	*/
	__CheckRC( sts, *msg, "VDdrwMgrGetInfo", wrapup );

	__DBGpr_int( "List of objects", *setCount );
	
	if ( *setCount <= 0 ) goto wrapup; /**added for TR-179800315 **/
				
	if( !( *setRange = _MALLOC( *setCount , GRrange )))
		vd_$mem_fail();

	/*
	 * Calculate the Object Range of the objects and store them in the
	 * internal structure.
	 */
	world	= TRUE ;
	range	= *setRange ;
	list	= *setList ;

	errRange[0] = errRange[1] = errRange[2] = -MAXDOUBLE ;
	errRange[3] = errRange[4] = errRange[5] =  MAXDOUBLE ;

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

	wrapup :

		if( !( sts & *msg & 1 )){
			_FREE( *setList );
			_FREE( *setRange );
			*setRange 	= NULL ;
			*setList	= NULL ;
			*setCount	= 0 ;
		}

		End
		return sts ;

} /* VD_drwGiveSetObjects */

/*----------------------------------------------------------------------------*/
long VD_drwGiveSetInfo(	msg, mdEnv, setName, setCount, setList, setRange )

IGRlong			*msg ;
struct	GRmd_env	*mdEnv ;
IGRchar			*setName ;
int			*setCount ;
struct	GRobj_env	**setList ; 
GRrange			**setRange ; {

	/*
	 * Check if the list exist. If exist, make an copy of the
	 * list and return it.
	 * If the list does not exist and we use the process improvement
	 * process (internal stack), we need to store the list and
	 * then return a copy of the list.
	 */
	IGRlong			sts = OM_S_SUCCESS ;
	struct  VDdrw_setInfo	*setInfo = NULL ;

	SetProc( VD_drwGiveSetInfo ); Begin

	*msg       = MSSUCC ;
	*setCount  = 0;
	*setList   = NULL;
	*setRange  = NULL;

	if( ! VDdrwUseSetBuffer ){

		/*
		 * get the list and go back.
		 */
		sts = VD_drwGiveSetObjects(	msg,
						mdEnv,
						setName, 
						setCount,
						setList,
						setRange );
		/* TR-179800315  - add the check */
		__CheckRC(sts,*msg,"VD_drwGiveSetObjects",wrapup);
	}
	else{
		/*
		 * Use internal buffer.
		 */
		sts = VD_drwIfSetInBuffer( msg, setName, &setInfo );

		if( setInfo ){

		  /*
		   * List is found and will be used.
		   */
		  __DBGpr_str( "Internal Stack exist ", setName );
		  __DBGpr_int( "Internal Stack Size  ", setInfo->count );

		  if( ! setInfo->count ) goto wrapup ;

		  *setCount = setInfo->count; 
		  if( !( *setList = _MALLOC( *setCount , struct GRobj_env )))
			vd_$mem_fail();

		  if( !( *setRange = _MALLOC( *setCount , GRrange )))
			vd_$mem_fail();

		  OM_BLOCK_MOVE(setInfo->list,	*setList,
				*setCount * sizeof( struct GRobj_env ));

		  OM_BLOCK_MOVE(setInfo->range,	*setRange,
				*setCount * sizeof( GRrange ));
		}
		else{

		  /*
		   * Generate the set.
		   */
		  sts = VD_drwGiveSetObjects(	msg,
						mdEnv,
						setName,
						setCount,
						setList,
						setRange );
		  /* TR-179800315  - add the check */
		  __CheckRC(sts,*msg,"VD_drwGiveSetObjects",wrapup);

		  sts = VD_drwAddSetToBuffer(	msg,
						setName,
						setCount,
						setList,
						setRange );
		  __CheckRC(sts,*msg,"D_drwAddSetToBuffer",wrapup);
		}
	} /* VDdrwUseSetBuffer == TRUE */

	setInfo = NULL ;

	wrapup :

		End 
		return sts ;

} /* VD_drwGiveSetInfo */

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
