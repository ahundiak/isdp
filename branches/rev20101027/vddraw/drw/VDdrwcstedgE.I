/* $Id: VDdrwcstedgE.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwcstedgE.I
 *
 * Description:
 *		Support functions for drawing process.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwcstedgE.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
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
# Revision 1.9  1995/09/28  12:50:26  pinnacle
# Replaced: ./vddraw/drw/VDdrwcstedgE.I for:  by azuurhou for vds.240
#
# Revision 1.8  1995/09/25  13:34:58  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgE.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	??/??/??			creation date
 *	09/17/95	adz		Set cht temporary to bastol to
 *					perform data reduction process.
 *	09/27/95	adz		Checked sts in project/symbol process
 *
 ***************************************************************************/
class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "asbox.h"
#include "exdef.h"
#include "exmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "EMSmsgdef.h"
#include "vd_ve.h"
#include "v_drwdef.h"
#include "v_drwenv.h"
#include "v_drw.h"
#include "v_vedef.h"
#include "vddlodef.h"
#include "vddlomacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "ACrg_collect.h"

#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_fndslsinmc.h"
#include "v_vecmxproto.h"
#include "v_virtualinf.h"
#include "v_visedproto.h"
#include "bsxtractpar.h"


from	ACrg_collect	import	AClist_attribute;

/*----------------------------------------------------------------------------*/

long VD_drwProjectListAndChangeSymb( msg, inp, xData, type, inList,
				     maxCount, outCount, outList )

long			*msg ;
VD_drwInputData		*inp ;
VD_drwExecData		*xData ;
int			type ;		/* Visible Edges Type	*/
struct	VDve_elem_buf	*inList ;
int			maxCount ;
int			*outCount ;
struct	GRid		*outList ;
{
	int			sts,
				i,
				savCount ;
	long			bsRC ;
	IGRdouble		redTolerance ;
	OMuword			pjClassid ;
	struct IGRdisplay	dsp ;
	struct GRvg_construct	cst ;

	SetProc( VD_drwProjectListAndChangeSymb ); Begin

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	savCount = *outCount ;

	if( ! inList || inList->count == 0 ) goto wrapup ;

	BSxtractpar( &bsRC, BSTOLBASIS, &redTolerance );
	/*
	 * Fill construction list for projected wireframes with the
	 * hidden symbology.
	 */
	if( type & VD_K_DRW_EDGES_A ){

	  vd_$fill_cnst_list(Msg        = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &xData->overrides.elmDisplay,
                           Cnst_list    = cst ) ;
	  dsp = xData->overrides.elmDisplay ;

	}
	else{

	  vd_$fill_cnst_list(Msg        = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.hdnLevel,
                           Display      = &xData->overrides.hdnDisplay,
                           Cnst_list    = cst ) ;
	  dsp = xData->overrides.hdnDisplay ;

	  __DBGpr_com(" Set Symbology to HIDDEN symbology " );
	}


	for( i=0 ; i<inList->count ; i++ ){

		/*
		 * Limitation check.
		 */
		if( *outCount == maxCount ) break ;

		outList[*outCount].objid = NULL_OBJID ;

		/*
		 * Project wireframe onto drawing plane with hidden
		 * symbology.
		 */
                sts =
		EFproject_any_curve_on_planen( msg,
                                               &cst,
                                               &inList->obj_info_p[i]._grid,
                                               &inList->obj_info_p[i].mod_env,
                                               inp->drwInfo.drwPlane,
                                               inp->drwInfo.viewVector,
                                               &outList[*outCount],
                                               &pjClassid ) ;
		CheckRC( sts, *msg );
		if( !(sts&*msg&1 )){
		  /*
		   * Delete the created object if exist.
		   */
		   if( outList[*outCount].objid != NULL_OBJID ){
			vd_$bulk_delete(count	= 1,
					grids	= &(outList[*outCount]),
					theEnv	= inp->drwInfo.drwEnv );
			continue ;
		   }
		}

		sts =
                VD_changeSymbology(     msg,
                                        &outList[*outCount],
                                        cst.level,
                                        &dsp );
                CheckRC( sts, *msg );

		/*
		 * Apply Data reduction on the curves.
		 */

		sts =
		VD_drwCvApplyDataReduction(	msg,
						&redTolerance,
						&outList[*outCount],
						inp->drwInfo.drwEnv );
		/*
		 * DO NOT CHECK THE ERROR MESSAGE.
		 * 	FAILURE MEANS NO REDUCTION -> No ERROR.
		 */
		sts = OM_S_SUCCESS ;
		*msg = MSSUCC ;
		(*outCount)++ ;
	}

	wrapup:
		if( !(sts&*msg&1)){
			*outCount = savCount ;
		}	

		End
		return sts ;
}

/*----------------------------------------------------------------------------*/

long VD_drwGetIndCompsOfObjEnvList( msg, inCount, inList, outCount, outList )
long			*msg ;
int			inCount ;
struct GRobj_env	inList[] ;
int			*outCount ;
struct GRobj_env	*outList[] ;

{
	long		sts ;			/* OM completion code.	      */
	int		i,j,k ;			/* Loop on face.	      */
	IGRint		cpCount ,		/* When object is composite   */
			eqCount ,
			tmpCount ;
	IGRint		freeList ;
	struct GRid	*cpList ;		/* List of components	      */
	struct GRobj_env *tmpList ;
	extern		OMuword		OPP_GRcompcurve_class_id ;

	SetProc( VD_drwGetIndCompsOfObjEnvList ); Begin

	*outCount = 0 ;
	*outList  = NULL ;

	tmpCount = cpCount = 0 ;
	tmpList  = NULL ;
	cpList   = NULL ;
	freeList = FALSE ;

	for( i=0 ; i<inCount ; i++ ){

	    sts =
	    om$is_objid_valid(	objid = inList[i]._objid,
				osnum = inList[i]._osnum );

	    if( !(sts&1)) continue ;

	    if( vd_$is_ancestry_valid(
			object	= &( inList[i]._grid ),
			classid	= OPP_GRcompcurve_class_id )){
						
		freeList = TRUE ;

		__DBGpr_com(" Find a compcurve " );

		sts =
		vd_$get_components(
				msg		= msg,
				grobjId		= & inList[i]._grid,
				grobjEnv	= & inList[i].mod_env,
				number		= &cpCount,
				components	= &cpList );
		__CheckRC( sts, *msg, "vd_$get_components", wrapup );

		if( ! cpCount ){
			_FREE( cpList );
			cpList = NULL ;
	    		freeList = FALSE ;
			cpCount = 0 ;
			continue ;
	    	}

		__DBGpr_int( " NUmber of Comps :", cpCount );

		sts =
		om$send(msg = message GRowner.GRdrop( msg, &inList[i].mod_env ),
			targetid = inList[i]._objid,
			targetos = inList[i]._osnum,
			senderid = inList[i]._objid );
		__CheckRC( sts, *msg, "GRowner.GRdrop", wrapup );
	    }
	    else{
		/*
		 * set the object self.
		 */
		cpList  = & inList[i]._grid ;
		cpCount = 1 ;
	    }

	    /*
	     * save the components in a buffer.
	     */
	    if( tmpCount ) {
		if( !( tmpList = _REALLOC(	tmpList,
						tmpCount + cpCount,
                                                struct GRobj_env ) ) )
                        vd_$mem_fail() ;
	    } else {
		if( !( tmpList = _MALLOC( cpCount, struct GRobj_env ) ) )
                        vd_$mem_fail() ;
	    }

	    eqCount = 0 ;
	    for( j=0 ; j<cpCount ; j++ ){
		/*
		 * check if object already in list 
		 */
		for( k=0 ; k<tmpCount ; k++ ){
		  if( IF_EQ_GRID( tmpList[k]._grid, cpList[j] )){ break ; }
		}

		if( k==tmpCount ){
                	tmpList[tmpCount+eqCount]._grid   = cpList[j] ;
			tmpList[tmpCount+eqCount].mod_env = inList[i].mod_env ;
			eqCount++ ;
		}
	    }

	    tmpCount += eqCount ;

	    if( freeList )	_FREE( cpList ); 

	    freeList = FALSE ;
	    cpList  = NULL ;
	    cpCount = 0 ;
	}

	*outCount = tmpCount ;
	*outList  = tmpList ;

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup:

		if( !(sts & *msg & 1 )){
			_FREE( tmpList );
			tmpList = NULL ;

			*outCount = inCount ;
			*outList  = inList ;
		}

		if( freeList )	_FREE( cpList ); 
		End
		return sts ;
}
/*----------------------------------------------------------------------------*/
long VD_drwGetEnvInformation( msg, info )

long			*msg ;
VD_drwEnvInfo		*info ;

{
	int			sts = OM_S_SUCCESS ;
	int			i;
	struct	GRid		coll ;
	struct	ACrg_coll	collStr[VD_K_drwRepMax] ;
	VD_drwLoInfo		drwLoInfo ;

	SetProc( VD_drwGetEnvInformation ); Begin

	*msg = MSSUCC ;

	info->count	= 0 ;
	
	/*
	 * list initialization.
	 */
	for( i=0 ; i<VD_K_drwRepMax ; i++ ){

		info->rep[i].name[0]	= '\0';
		info->rep[i].rep_val	= 0.0 ;
		info->rep[i].match[0]	= '\0';
	}

	/*
	 * get the representation collector.
	 */
	coll.objid = NULL_OBJID ;
	sts =
	ac$get_rep_col(	col = & coll );

	sts =
	_VD_SEND_OBJN(	coll,
			ACrg_collect.AClist_attribute(	msg,
							VD_K_drwRepMax,
							collStr,
							&info->count ));
	__CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );

	for( i=0 ; i<info->count ; i++ ){

		sts =
		vd$drw_layout_info(     msg     = msg,
					type    = VD_K_drwLO_objRep,
					rep     = collStr[i].name,
					info    = &drwLoInfo );

		strcpy( info->rep[i].name, collStr[i].name );
		VD_drwLO_cvrtToString( &drwLoInfo, 0, info->rep[i].match );
		info->rep[i].rep_val	= collStr[i].desc.value.att_exp ;

	}

#ifdef	vdsDEBUG
	for( i=0 ; i<info->count ; i++ ){
		__DBGpr_str("Name   ", info->rep[i].name );
		__DBGpr_str("Match  ", info->rep[i].match );
		__DBGpr_dbl("Value  ", info->rep[i].rep_val );
	}
#endif
	*msg = MSSUCC ;
	sts = OM_S_SUCCESS ;

	wrapup:

		End
		return sts ;
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
