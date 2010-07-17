/* $Id: VSfndendtrts.I,v 1.2 2001/01/16 23:31:05 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsmisc/VSfndendtrts.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfndendtrts.I,v $
 *	Revision 1.2  2001/01/16 23:31:05  ramarao
 *	*** empty log message ***
 *	
# Revision 1.2  2000/06/08  16:46:52  pinnacle
# Replaced: struct/vsmisc/VSfndendtrts.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/10  16:38:06  pinnacle
# initial revision
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/17  19:40:18  pinnacle
# TR179800996
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.3  1997/02/04  20:15:10  pinnacle
# Replaced: vsmisc/VSfndendtrts.I for:  by s241_int for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/02/97  adz     Argument modification (GRname->char *)
 * 04/17/98  ah      TR179800996 Array limits being exceded on Solaris
 ***************************************************************************/
class implementation VSbeam ;

#include "madef.h"
#include "VDobj.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsophstproto.h"
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"

struct VS_s_boolOpList {
	char			macName[20] ;
	struct GRobj_env	boolOp ;
}; 

typedef struct VS_s_boolOpList boolOpList ;

extern OMuword OPP_ACconst_class_id ;

from ACpretend	import ACfind_parent ;
from ACcpx_defn	import ACgive_name ;
from GRcurve	import GRendpts, GRmidpoint ;
/*----------------------------------------------------------------------------*/
int VSorderEndTreatment( msg, bmId, bmEnv, nbBop, bopList,
				etNear0, etNear1 )
long		*msg ;
struct GRid	*bmId ;
struct GRmd_env	*bmEnv ;
int		nbBop ;
struct VS_s_boolOpList	*bopList ;
char		*etNear0 ;
char		*etNear1 ; 
{

	long		sts, rc;
	double 		tNear0 = 1.,
			tNear1 = 0. ;
	int		i,
			iNear0 = -1, 
			iNear1 = -1 ;
	struct GRobj_env
			suppAxis ;
	GRrange		range ;
	IGRboolean	world = FALSE, is_reverse = FALSE ;
	struct GRparms	prjParms ;
	IGRpoint	mid,
			prjPt ;
	IGRdouble       SecMat[16], z_axis[3], spt[3], ept[3], vec[3];

	SetProc( VSorderEndTreatment ); Begin

	__DBGpr_int (" nbBop  ", nbBop );
        for( i = 0 ; i < nbBop ; i++ ){
	     __DBGpr_int(" index   ", i );
             __DBGpr_str(" orderMN ", bopList[i].macName );
             __DBGpr_obj(" orderOP ", bopList[i].boolOp.obj_id );
        }
	__DBGpr_obj (" myBeam ", *bmId );

	*msg	= MSSUCC ;

	__DBGpr_mat (" myEnv ", bmEnv->md_env.matrix );

	sts = om$send(	msg	= message VSbeam.VSgetSupportAxis(
						msg, bmEnv, &suppAxis ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	CheckRC( sts, *msg ) ;

	__DBGpr_com(" Hello 1 ");

	/*
	 * Have geometric entities evaluated in beam's coordinate system.
	 */
	if( bmEnv->_MATRIX_TYPE != MAIDMX ) {
		__DBGpr_com(" Hello 2 ");
		VSmulmx(	bmEnv->_MATRIX,
				suppAxis._matrix,
				suppAxis._matrix,
				&suppAxis._matrix_type ) ;
	}

        sts = VSgetCsStiff( msg, bmId, bmEnv, SecMat );
        __CheckRC( sts, *msg, "VSgetCsStiff", wrapup ) ;

        z_axis[0] = SecMat[2];
        z_axis[1] = SecMat[6];
        z_axis[2] = SecMat[10];
        __DBGpr_vec("Stiffener Z axis ", z_axis );

        is_reverse = FALSE;
        sts = om$send ( msg      = message GRcurve.GRendpts (
                                                msg,
                                                &suppAxis._matrix_type,
                                                suppAxis._matrix,
                                                spt,
                                                ept ),
                        senderid = NULL_OBJID,
                        targetid = suppAxis._objid,
                        targetos = suppAxis._osnum );
        __CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;
        BSmkvec( &rc, vec, spt, ept );
        BSnorvec ( &rc,  vec );

        if( BSdotp ( &rc, z_axis, vec ) < 0.0 )  is_reverse = TRUE;

	__DBGpr_com(" Hello 3 ");
	__DBGpr_int(" nbBop ", nbBop );

        for( i = 0 ; i < nbBop ; i++ ){
	     __DBGpr_int(" index   ", i );
             __DBGpr_str(" orderMN ", bopList[i].macName );
             __DBGpr_obj(" orderOP ", bopList[i].boolOp.obj_id );
        }

	for( i = 0 ; i < nbBop ; i++ ) {

		__DBGpr_int(" index ", i );
		__DBGpr_obj(" bopList ", bopList[i].boolOp.obj_id );

		sts = om$send(	msg	= message GRgraphics.GRgetrang(
						msg,
						&bopList[i].boolOp._matrix_type,
						bopList[i].boolOp._matrix,
						&world,
						range ),
				senderid= bmId->objid,
				targetid= bopList[i].boolOp._objid,
				targetos= bopList[i].boolOp._osnum ) ;
		CheckRC( sts, *msg ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		VSmidpoint( range + 0, range + 3, mid ) ;

		sts = om$send(	msg	= message GRgraphics.GRptproject(
						msg,
						&suppAxis._matrix_type,
						suppAxis._matrix,
						mid,
						prjPt,
						&prjParms ),
				senderid= bmId->objid,
				targetid= suppAxis._objid,
				targetos= suppAxis._osnum ) ;
		CheckRC( sts, *msg ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		if( is_reverse ) prjParms.u = 1.0 - prjParms.u ;

		if( prjParms.u < tNear0 ) {
			tNear0 = prjParms.u ; iNear0 = i ;
		}
		if( prjParms.u > tNear1 ) {
			tNear1 = prjParms.u ; iNear1 = i ;
		}

		__DBGpr_int(" iNear0 ", iNear0 );
		__DBGpr_int(" iNear1 ", iNear1 );

		__DBGpr_dbl(" tNear0 ", tNear0 );
		__DBGpr_dbl(" tNear1 ", tNear1 );
	}

	etNear0[0] = '\0' ;
	etNear1[0] = '\0' ;

	__DBGpr_dbl(" tNear0 ", tNear0 );
	__DBGpr_dbl(" tNear1 ", tNear1 );

	if( iNear0 != -1 ) __DBGpr_str(" macName0 ", bopList[iNear0].macName );
	if( iNear1 != -1 ) __DBGpr_str(" macName1 ", bopList[iNear1].macName );

	if( iNear0 != iNear1 ) { 
		if( iNear0 != -1 ) strcpy( etNear0, bopList[iNear0].macName ) ;
		if( iNear1 != -1 ) strcpy( etNear1, bopList[iNear1].macName ) ;
	} else {
		om$send(msg	= message GRcurve.GRmidpoint(
						msg,
						&suppAxis._matrix_type,
						suppAxis._matrix,
						&prjParms,
						mid ),
			senderid= bmId->objid,
			targetid= suppAxis._objid,
			targetos= suppAxis._osnum ) ;
		CheckRC( sts, *msg ) ;
			
		om$send(msg	= message GRgraphics.GRptproject(
						msg,
						&suppAxis._matrix_type,
						suppAxis._matrix,
						mid,
						prjPt,
						&prjParms ),
			senderid= bmId->objid,
			targetid= suppAxis._objid,
			targetos= suppAxis._osnum ) ;
		CheckRC( sts, *msg ) ;

		if( is_reverse ) prjParms.u = 1.0 - prjParms.u ;

		if( tNear0 <= prjParms.u ) {
			if( iNear0 != -1 )
				strcpy( etNear0, bopList[iNear0].macName ) ;
		} else {
			if( iNear0 != -1 )
				strcpy( etNear1, bopList[iNear1].macName ) ;
		}
	}

	wrapup:

		__DBGpr_str(" etNear0 ", etNear0 );
		__DBGpr_str(" etNear1 ", etNear1 );

		End
		return sts ;

} /* VSorderEndTreatment */
/*----------------------------------------------------------------------------*/
long VSfindEndTreatments( msg, bmId, bmEnv, et1, et2 )

long		*msg ;
struct GRid	*bmId ;
struct GRmd_env	*bmEnv ;
char		*et1 ;
char		*et2 ; 
{
	/*
	 * Given a beam finds the end-treatments performed on it: actually
	 * returns the definition names of the last two macros whose solid
	 * members were used to perform boolean differences on that beam.
	 */

	long		sts ;
	VSopHistory	*history = NULL,
			*h ;
	int		o,
			nbop ;
	struct GRid	operator,
			macroOcc,
			macroDef ;
	char		*macName ;
	struct VS_s_boolOpList
			*bop = NULL ;

	SetProc( VSfindEndTreatments ); Begin

	__DBGpr_obj( " bmId ", *bmId );

	et1[0] = '\0' ;
	et2[0] = '\0' ;

	sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
							msg, bmEnv, &history ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

	/*
	 * Find a max. for allocation of list of boolean operators.
	 */
	for( nbop = 0, h = history ; h ; h = h->next ) nbop++ ;
	if( ! nbop ) goto wrapup ;

	__DBGpr_int( " nbop ", nbop );

	/* --------------------------------------------------------------------------
	 * TR179800996 System was crashing on some beams with multiple end treatment
	 * cutting curves.  Each op can have more that one curve
	 * By allocating room for 10 curves per op, the crashing went away
	 * We may have only needed one more but I still could not pin down
	 * exactly where the bounds limit was being exceeded
	 *
	 * nbop never got over more that 1 but something was going on
	 * this seems to work for now
	 * nbop -> is equal to number of Beam parents. Each beam can have a
	 * max of 100 (VS_K_bbMAX_NOTCHES) cutouts.
	 */
	if( !( bop = _MALLOC( nbop * VS_K_bbMAX_NOTCHES,
				 struct VS_s_boolOpList ) ) ) vs$mem_fail() ;
        for( o = 0 ; o < (nbop*VS_K_bbMAX_NOTCHES) ; o++ ){ bop[o].macName[0] = '\0' ; }

	for( nbop = 0, h = history ; h  ; h = h->next ) {
		if( !( h->resultType & VS_m_DPR_generic ) ) continue ;

		for( o = 0 ; o < h->opCount ; o++ ) {
			operator.objid = h->opList[o].id ;
			operator.osnum = h->opList[o].os ;

			/*
			 * Operator is a pretend: find macro occurrence which is
			 * its parent.
			 */
			sts = om$send(
				msg	= message ACpretend. ACfind_parent(
							&macroOcc, NULL, NULL ),
				senderid= operator.objid,
				targetid= operator.objid,
				targetos= operator.osnum ) ;
			__CheckRC( sts, 1, "VSbeam.ACpretend. ACfind_parent", wrapup ) ;
			if( !( sts & 1 ) ) continue ;

			if( IF_NULL_OBJID( macroOcc.objid ) ) continue ;

			if( !vs$is_ancestry_valid(
					object = &macroOcc,
					classid = OPP_ACconst_class_id ) ) 
				continue ;
			/*
			 * This send will fail if it is not a macro occurrence
			 * but an ASsource and this failure is fine with us.
			 */
			sts = om$send(	msg	= message ACcpx.find_macro(
								&macroDef ),
					senderid= macroOcc.objid,
					targetid= macroOcc.objid,
					targetos= macroOcc.osnum ) ;
			__CheckRC( sts, 1, "VSbeam.ACcpx.find_macro", wrapup ) ;
			if( !( sts & 1 ) ) continue ;

			macName = NULL ;
			sts = om$send(	msg	= message ACcpx_defn.ACgive_name(
								&macName ),
					senderid= macroDef.objid,
					targetid= macroDef.objid,
					targetos= macroDef.osnum ) ;
			__CheckRC( sts, 1, "VSbeam.ACcpx_defn.ACgive_name", wrapup ) ;
			if( !( sts & 1 ) ) continue ;

			sts = VSgetVirtualInfo(	msg,
						&operator ,
						&bop[nbop].boolOp.mod_env ,
						&bop[nbop].boolOp._grid ) ;
			__CheckRC( sts, *msg, "VSbeam.VSgetVirtualInfo", wrapup ) ;
			if( !( sts & 1 & *msg ) ) continue ; 

			/*
			 * Have geomtries evaluated in the beam's coordinate
			 * system.
			 */
			if(  bmEnv->_MATRIX_TYPE != MAIDMX ) {
				VSmulmx( bmEnv->_MATRIX,
					 bop[nbop].boolOp._matrix,
					 bop[nbop].boolOp._matrix,
					 &bop[nbop].boolOp._matrix_type ) ;
			}
			strcpy( bop[nbop].macName, macName );
			__DBGpr_str(" +macName ", macName );
			__DBGpr_str(" \tmacName ", bop[nbop].macName );
			nbop++;
		}
	}

	__DBGpr_int(" nbop ", nbop );

	if( nbop ) {

		for( o = 0 ; o < nbop ; o++ ){
			__DBGpr_str(" macName ", bop[o].macName );
			__DBGpr_obj(" boolOP  ", bop[o].boolOp.obj_id );
		}

		sts = VSorderEndTreatment(	msg, 
						bmId, 
						bmEnv, 
						nbop, 
						bop, 
						et1, 
						et2 ) ;
	}

	wrapup :
		_FREE( bop );
		VSfreeOpHistory( history ) ;

		__DBGpr_str(" et1 ", et1 );
		__DBGpr_str(" et2 ", et2 );

		End ;
		return sts ;

} /* VSfindEndTreatments */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
