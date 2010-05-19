/* $Id: VDdrwcstedgM.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* I/VDS
 *
 * File:	vddraw/drw/VDdrwcstedgM.I
 *
 * Description:
 *
 * Dependencies:
 *	$Log: VDdrwcstedgM.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/10  14:37:20  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgM.I for:  by azuurhou for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1996/03/18  11:03:46  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by ksundar for vds.240
#
# Revision 1.6  1995/08/23  20:07:00  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgM.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/08/16  14:51:24  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgM.I for:  by azuurhou for vds.240
#
# Revision 1.4  1995/06/27  18:26:34  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgM.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/05/09  11:42:12  pinnacle
# Replace: vddraw/drw/VDdrwcstedgM.I by azuurhou for OPE
#
# Revision 1.2  1995/04/03  16:25:02  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgM.I by azuurhou r#
#
# Revision 1.1  1995/03/16  20:27:36  pinnacle
# Created: vddraw/drw/VDdrwcstedgM.I by azuurhou r#
# rno
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      03/16/95        adz             first version.
 *	08/15/95	adz		code correction.
 *
 */
class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "asbox.h"
#include "exdef.h"
#include "exmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "EMSmsgdef.h"
#include "vd_ve.h"
#include "v_drwdef.h"
#include "v_drwenv.h"
#include "v_drw.h"
#include "v_vedef.h"
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

extern double *VD_mulmx(const double *firstMatrix,const double *secondMatrix,double *productMatrix,short *productMatrixType);

/*
 * Combine the needed edges of the object and project them.
 * After projection delete all the Covered Curves of the object.
 */
/*----------------------------------------------------------------------------*/
long VD_drwCstConstMemEdges( msg, inp, xData, member, outp, processType )

long			*msg ;
VD_drwInputData		*inp ;
VD_drwExecData		*xData ;
VD_tktxt		member ;
VD_drwGraphicGroup	*outp ;
int			processType ;
{
	long			sts ;	    /* OM completion code.	      */
	int			ssCount;    /* Count of solids / surfaces     */
	struct GRid		footId ;    /* Foot identifier		      */
	struct GRmd_env		footEnv ;   /* Foot environment		      */
	struct GRobj_env	*ssList ;   /* List of solids / surfaces      */
	struct GRvg_construct	cst ;	    /* Construction list for	      */
					    /* projected wireframes.	      */
	struct IGRdisplay	dspVis,     /* Display for visible wireframes.*/
				dspHid ;    /* Display for hidden wireframes. */
	struct	VDve_elem_buf	v, h,
				vv, vh ;
	VD_drwEnvInfo		envInfo ;	/* enveloppe information   */	
	double                  *sts_dbl=NULL ;

	SetProc( VD_drwCstConstMemEdges ); Begin

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	__DBGpr_obj( "Construction to draw", *(inp->elmId) ) ;

	ssCount	 = 0 ;
	ssList	 = NULL ;

	VD_veInitElemBuf( &v );
	VD_veInitElemBuf( &h );
	VD_veInitElemBuf( &vv );
	VD_veInitElemBuf( &vh );
	
        if( !*member ) {
                if( xData->verbose )
                   VD_drwPrintf( "!!! Member not specified for const '%s'\n",
                                  inp->constDefName ) ;
                *msg = MSFAIL ;
                goto wrapup ;
        }

        /*
         * Get foot to project.
         */
        sts = om$send(  msg     = message NDmacro.ACreturn_foot(
                                                          msg,
                                                          (char *) member,
                                                          &footId,
                                                          &footEnv._MATRIX_TYPE,
                                                          footEnv._MATRIX ),
                        senderid= inp->elmId->objid,
                        targetid= inp->elmId->objid,
                        targetos= inp->elmId->osnum ) ;
        if( !( sts & 1 & *msg ) ) {
                if( xData->verbose )
                        VD_drwPrintf( "!!! Cannot find '%s' in const '%s'\n",
                                          member, inp->constDefName ) ;
                goto wrapup ;
        }

        sts_dbl = VD_mulmx( inp->elmEnv->_MATRIX, footEnv._MATRIX, footEnv._MATRIX,
                 &footEnv._MATRIX_TYPE ) ;

        footEnv.md_id = inp->elmEnv->md_id ;

	/*
	 * Process the object independent from the reference objects.
	 */
	dspVis = dspHid = xData->overrides.elmDisplay ;
	dspHid.style = xData->overrides.dpAttr.hiddenStyle ;

	/*
	 * Check if we have envelope processing active.
	 */
	envInfo.yes_no	  = ( xData->processFlags & VD_drwCheckEnvelopes )
				? TRUE : FALSE ;
	envInfo.env1_obj0 = ( processType & VD_K_ENV_PROCESS_TYPE )
				? TRUE : FALSE ;

        if( envInfo.yes_no ){		
		sts =
		VD_drwGetEnvInformation( msg, &envInfo );
		__CheckRC( sts, *msg, "VD_drwGetEnvInformation", wrapup );
	}

	sts = VD_drwCstConstIndividual( msg,
					&footId, &footEnv,
					xData, &envInfo,
					&v, &h );
	__CheckRC( sts, *msg, "VD_drwCstConstIndividual", wrapup ) ;

	/*
	 * Fill construction list for projected wireframes.
	 */
	vd_$fill_cnst_list(Msg          = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &xData->overrides.elmDisplay,
                           Cnst_list    = cst ) ;

	/*
	 * If more then one object is extracted, find the reference objects.
	 * from all input objects.
	 * Get solids / surfaces for processing hidden lines.
	 */
        __DBGpr_str( "SetName to check ", inp->refSetName );

        if( strlen( inp->refSetName )) {

		sts =
		VD_drwFindRefSurfacesOfObject(	msg, &envInfo,
						inp, xData,
						&ssList, &ssCount ) ;
		__CheckRC( sts, *msg, "VD_drwFindRefSurfacesOfObject", wrapup );
	} /* inp->refSetName */

	__DBGpr_int( "Count of located solids / surfaces", ssCount ) ;

	/*
	 * Process each of the given edges of the current object and process
	 * them against the surfaces in the from. This will result in change
	 * of the visible symbology of the found edges. The hidden edges
	 * are not processed.
	 */
	if( ssCount ){
		/*
		 * Threat each of the found surfaces against the 
		 * list of input edges.
		 */

		sts = 
		VD_drwFindHiddenEdgesOfObject(	msg,
						inp,
						xData,
						ssCount,
						ssList,
						&v,
						&vv,
						&vh );
		__CheckRC( sts, *msg, "VD_drwFindHiddenEdgesOfObject", wrapup );

		/*
		 * delete the primiairy list of foubd edges of the object.
		 */
		VD_veDelElemBuf( &v );
	}
	else{
		vv.count	= v.count ;
		vv.obj_info_p	= v.obj_info_p ;
		VD_veInitElemBuf( &v );
	}

	/*
	 * Combine the needed edges of the object and project them.
	 * After projection delete all the Covered Curves of the object.
	 */
	sts =
	VD_drwGenerateOutputType(	msg,
					inp,
					xData,
					outp,
					&vv,	/* visible edges */
					&vh,	/* opaque edges  */
					&h,		/* hidden edges  */
					processType );
	__CheckRC( sts, *msg, "VD_drwGenerateOutputType", wrapup ) ;

        __DBGpr_objlist( "MemEdges 2d ", outp->count, outp->list ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg )){
			__DBGpr_com(" ERROR OCCURS ");
			_FREE( outp->list );
			outp->list  = NULL ;
			outp->count = 0 ;
		}

		/*
		 * Delete the intermediair objects.
		 */
		VD_veDelElemBuf( &h );
		VD_veDelElemBuf( &vv );
		VD_veDelElemBuf( &vh );
		VD_veFreeElemBuf( &v );

		_FREE( ssList ) ;

		End
		return sts ;

} /* VD_drwCstConstEnvEdges */

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
