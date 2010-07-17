/* $Id: VSdrwisbmhid.I,v 1.7 2001/09/15 22:28:26 ahundiak Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwisbmhid.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwisbmhid.I,v $
 *      Revision 1.7  2001/09/15 22:28:26  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/03/01 00:03:34  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/02/06 21:31:57  ramarao
 *      Fixed ETL# 6146.
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:33  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.2  1996/01/31  07:02:46  pinnacle
# Replaced: vsdrawing/VSdrwisbmhid.I for:  by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	09/15/01	ad-ramarao	TR 5589 change IsBeamHidden process.
 * -------------------------------------------------------------------*/

/*
	I/STRUCT
*/
class implementation VSplate ;

#include <stdio.h>
#define _INGR_EXTENSIONS
#include <math.h>
#include <values.h>
#include "OMmacros.h"
#include "bserr.h"
#include "bsdotp.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "EMSmsgdef.h"
#include "VDobj.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsvedef.h"
#include "vsbeamdef.h"
#include "vsbeam.h"
#include "vsglobalmsg.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsvirtualinf.h"
#include "vsvisedproto.h"
#include "vsvecmxproto.h"

/*
#define vsDEBUG		1
#define vserrDEBUG	1
*/

#include "vsdbgmacros.h"

/*----------------------------------------------------------------------------*/
long VSdrwIsBeamHiddenByPlate( msg, bmId, bmEnv, plId, plEnv, viewVector,
				hidden )

long			*msg ;
const struct GRid	*bmId ;
const struct GRmd_env	*bmEnv ;
const struct GRid	*plId ;
const struct GRmd_env	*plEnv ;
const IGRvector 	viewVector ;
int			*hidden ; {

	long		sts ;		/* OM completion code.		*/
	long		rc ;		/* Auxilliary return code	*/
	GRrange 	bmRange ;	/* Range of beam		*/
	GRrange 	plRange ;	/* Range of plate		*/
	short		world = TRUE ;	/* Range in world coords	*/
	int		relationship ;
	int		mustRefine ;
	IGRvector	normal ;	/* Normal of bottom side	*/

	struct GRobj_env	temp_obj, gensolOE;


	__DBGpr_obj( "Beam #0", *bmId ) ;
	__DBGpr_obj( "Plate #1", *plId ) ;
	__DBGpr_mat( "Mx #0", bmEnv->_MATRIX ) ;
	__DBGpr_mat( "Mx #1", plEnv->_MATRIX ) ;

	*hidden    = FALSE ;
	mustRefine = FALSE ;

	__DBGpr_vec("View vector", viewVector );

#define PLENV ((struct GRmd_env *) plEnv)
#define BMENV ((struct GRmd_env *) bmEnv)
	/*
	 * The plate does not hide ANYTHING if it is perpendicular to the
	 * view vector...
	 */
	sts = om$send(	msg	  = message VSfeature.VSforwardToSource(
				&rc,
				OM_e_wrt_object,
				message VSfeature.VSgetNormalOfComponent(
					msg, PLENV, VS_K_plBotSfPath,
					0.5, 0.5, normal ) ),
			senderid= plId->objid,
			targetid= plId->objid,
			targetos= plId->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSforwardToSource", wrapup ) ;

#define TWO_DEGREES ( 2. / 180. * M_PI )
	if( VSareaOrthoVectors( viewVector, normal, TWO_DEGREES ) )
		goto wrapup ;

        temp_obj.obj_id  = *bmId;
        temp_obj.mod_env = *BMENV;

	gensolOE.obj_id.objid = NULL_OBJID;
        vdobj$GetFoot( objOE    = &temp_obj,
                       footName = VS_K_bmGrCmpName,
                       footOE   = &gensolOE );
        if(gensolOE.obj_id.objid == NULL_OBJID) goto wrapup;
	gensolOE.mod_env = *BMENV;

        vs$getRangeOfComposite( msg = msg,
                                composite = &gensolOE,
                                range     = bmRange       );

	__DBGpr_vec( "Beam Low Point", &bmRange[0] );
	__DBGpr_vec( "Beam High Point", &bmRange[3] );

        temp_obj.obj_id  = *plId;
        temp_obj.mod_env = *PLENV;

	gensolOE.obj_id.objid = NULL_OBJID;
        vdobj$GetFoot( objOE    = &temp_obj,
                       footName = VS_K_plGrCmpName,
                       footOE   = &gensolOE );
        if(gensolOE.obj_id.objid == NULL_OBJID) goto wrapup;
	gensolOE.mod_env = *PLENV;

        vs$getRangeOfComposite( msg = msg,
                                composite = &gensolOE,
                                range     = plRange       );

        __DBGpr_vec( "Plate Low Point", &plRange[0] );
        __DBGpr_vec( "Plate High Point", &plRange[3] );

	sts = VSveRangeRangeRelationShip(	msg,
						plRange,	/* Range #0 */
						bmRange,	/* Range #1 */
						viewVector,
						&relationship ) ;
	__CheckRC( sts, *msg, "VSveRangeRangeRelationShip", wrapup ) ;

	/*
	 * The description of the relationships is as follows:
	 *		.	 .
	 *	(A)	.   (B)  .	(C)
	 *		.	 .
	 *		+--------+
	 *..............|	 |................
	 *		|range 0 |
	 *		+--------+
	 *
	 *		   (E)
	 *		    ^
	 *		    | view vector
	 *
	 * VS_K_0_TOTALLY_HIDES_1  : range #1 in (B)
	 * VS_K_0_PARTIALLY_HIDES_1: range #1 across boundary (A)/(B) ot (B)/(C)
	 * VS_K_0_IN_FRONT_OF_1    : range #1 in (A) or (C)
	 * VS_K_0_AT_THE_BACK_OF_1 : range #1 in (E)
	 * VS_K_INTERSECT	   : range #0 and range #1 intersect
	 */
	switch( relationship ) {

		case VS_K_INTERSECT		:
		/*
		 * Plate range and beam range intersect.
		 */
		*hidden 	= FALSE ;
		mustRefine	= TRUE ;
		break ;

		case VS_K_0_TOTALLY_HIDES_1	:
		/*
		 * Plate range totally hides beam range.
		 */
		*hidden 	= TRUE ;
		mustRefine	= FALSE ;
		break ;

		case VS_K_0_PARTIALLY_HIDES_1	:
		/*
		 * Plate range partially hides beam range.
		 */
		*hidden 	= FALSE ;
		mustRefine	= TRUE ;
		break ;

		case VS_K_0_IN_FRONT_OF_1	:
		/*
		 * Plate range is in front of beam range.
		 */
		*hidden 	= FALSE ;
		mustRefine	= FALSE ;
		break ;

		case VS_K_0_AT_THE_BACK_OF_1	:
		/*
		 * Plate range is at the back of beam range.
		 */
		mustRefine	= FALSE ;
		*hidden 	= FALSE ;
		break ;

	}
	__DBGpr_int( "Range/range relationship", relationship ) ;

	/*
	 * Refine if needed. The plate hides the beam only if the dot product
	 * between the view vector and the vector middle point of beam's range
	 * to middle point of plate's range is >0.
	 *
	 *		^
	 *		|		<- view vector.
	 *
	 *	-------------------
	 *	|		  |	<- range of plate.
	 *	|	^	  |
	 *	--------|----------
	 *	     |	    |		<- range of beam.
	 *	     --------
	 *
	 * The plate hides the beam.
	 *
	 *		^
	 *		|		<- view vector.
	 *
	 *	     --------
	 *	     |	    |		<- range of beam.
	 *	--------|----------
	 *	|	v	  |	<- range of plate.
	 *	|		  |
	 *	-------------------
	 *
	 * The plate doesn't hide the beam.
	 */
	if( mustRefine ) {
		long		bsRC ;
		IGRpoint	bmRngMid,
				plRngMid ;
		IGRvector	bmTopl ;

		VSmidpoint( bmRange, bmRange +3, bmRngMid ) ;
		VSmidpoint( plRange, plRange +3, plRngMid ) ;

		__DBGpr_vec( "Beam Mid Point", bmRngMid ) ;
		__DBGpr_vec( "Plate Mid Point", plRngMid ) ;

		BSmkvec( &bsRC, bmTopl, bmRngMid, plRngMid ) ;

		__DBGpr_vec( "bmTopl", bmTopl );

		__DBGpr_int( "Dot Product", BSdotp( &bsRC, (double *) viewVector, bmTopl ) );

		if( BSdotp( &bsRC, (double *) viewVector, bmTopl ) > 0. ) {
			__DBGpr_com( "Plate hides beam" ) ;
			*hidden = TRUE ;
		} else {
			__DBGpr_com( "Plate doesn't hide beam" ) ;
			*hidden = FALSE ;
		}
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;
#undef PLENV
#undef BMENV

} /* VSdrwIsBeamHiddenByPlate */
/*----------------------------------------------------------------------------*/
int VSdrwIsBeamHidden( msg, inp, xData, hidden )

long			*msg ;
const VSdrwInputData	*inp ;
const VSdrwExecData	*xData ;
int			*hidden ; {

	/*
	 * This function finds whether if the beam being drawn is hidden or
	 * not by a plate in the list of selected elements.
	 */

	long		sts ;		/* OM completion code.		      */
	int		i ;		/* Loop index.			      */
	struct GRid	virtualId ;	/* Virtual object of the element in   */
					/*   the list of selected elements.   */
	struct GRmd_env virtualEnv ;	/* Env. of the above.		      */
	unsigned long	resultType ;	/* Result type of the element in the  */
					/*  list of selected elements.	      */
	IGRlong		 rc;
	IGRpoint	 spt, ept;
	IGRvector	 vec;
	IGRmatrix	 SecMat;
	struct GRobj_env bmObj;
	VSpartAttr       part ;     /* My part attributes  */
        VSbeamAttr       myAttr ;   /* My beam attributes  */	

	__DBGpr_obj( "Beam to draw", *(inp->elmId) ) ;
	__DBGpr_mat( "Beam mx", inp->elmEnv->_MATRIX ) ;

	/*
	 * Input element must be a beam.
	 */
	if(    xData->parsedElmType != VS_gI_Beam
	    && xData->parsedElmType != VS_gI_Stiffener ) vs$inv_arg() ;

	*hidden = FALSE ;

	bmObj.obj_id  = *(inp->elmId);
	bmObj.mod_env = *(inp->elmEnv);

        sts = VSevalBeamCS( msg, &bmObj, 0, VS_e_BOT_LEFT , SecMat );
        __CheckRC( sts, *msg, "VSevalBeamCS", wrapup ) ;

	spt[0] = SecMat[3]; spt[1] = SecMat[7]; spt[2] = SecMat[11];

	__DBGpr_vec( "Start Point", spt );
		
	sts = VSevalBeamCS( msg, &bmObj, 0, VS_e_UPP_LEFT , SecMat );
        __CheckRC( sts, *msg, "VSevalBeamCS", wrapup ) ;

        ept[0] = SecMat[3]; ept[1] = SecMat[7]; ept[2] = SecMat[11];
	__DBGpr_vec( "End Point", ept );

        part.Iwant = VS_m_Symmetry ;
        part.specific   = (void *) &myAttr ;
        sts = om$send( msg      = message GRvg.GRgetattr( msg, &part ),
                          senderid = bmObj._objid,
                          targetid = bmObj._objid,
                          targetos = bmObj._osnum   ) ;
        __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

        if( ( myAttr.sym == VS_e_No_Symm ) ||
            ( myAttr.sym == VS_e_Y_Symm ) )
                        BSmkvec( &rc, vec, spt, ept ) ;
        else
                        BSmkvec( &rc, vec, ept, spt );

	BSmkvec( &rc, vec, spt, ept ) ;
	BSnorvec( &rc, vec );

	__DBGpr_vec( "Vector", vec );
	__DBGpr_vec( "View Vector", inp->drwInfo.viewVector );

	if( BSdotp( &rc, (double *) inp->drwInfo.viewVector, vec ) < 0. )
	{
                        __DBGpr_com( "Plate hides beam" ) ;
                        *hidden = TRUE ;
	} else {
                        __DBGpr_com( "Plate doesn't hide beam" ) ;
                        *hidden = FALSE ;
	} 

	__DBGpr_int( "Is beam hidden ?", *hidden ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSdrwIsBeamHidden */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
