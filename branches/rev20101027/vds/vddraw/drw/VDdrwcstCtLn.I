/* $Id: VDdrwcstCtLn.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* I/VDS
 *
 * File:	vddraw/drw/VDdrwcstCtLn.I
 *
 * Description:
 *
 * Dependencies:
 *	$Log: VDdrwcstCtLn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/24  19:46:04  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by impd252 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/04/19  13:41:22  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by impd for vds
#
# Revision 1.6  1998/04/10  14:41:16  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by azuurhou for vds
#
# Revision 1.5  1998/03/11  22:48:30  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by mdong for vds
#
# Revision 1.4  1998/03/10  16:13:40  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by mdong for vds
#
# Revision 1.3  1997/12/26  19:42:46  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by v250_int for vds
#
# Revision 1.2  1997/12/26  19:24:12  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by v250_int for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.5  1996/11/20  13:30:26  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by ashankar for vds.241
#
# Revision 1.4  1996/11/18  11:52:22  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by ashankar for vds.241
#
# Revision 1.3  1996/11/06  06:49:52  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by ashankar for vds.241
#
# Revision 1.2  1996/11/05  14:33:14  pinnacle
# Replaced: vddraw/drw/VDdrwcstCtLn.I for:  by v241_int for vds.241
#
# Revision 1.1  1996/11/02  16:09:36  pinnacle
# Created: vddraw/drw/VDdrwcstCtLn.I by v241_int for vds.241
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      11/03/96        adz             first version.
 *	03/24/00	adz		TR 179901232 - Get parent of VDdrw3d.
 */

class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "asbox.h"
#include "exdef.h"
#include "exmacros.h"
#include "dp.h"
#include "nddef.h"
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

/*
 * Get the symbolic rep. objects and project them.
 * After projection delete all the Centerline object.
 */

extern OMuword OPP_VDdrw3d_class_id ;

/*----------------------------------------------------------------------------*/
long VD_drwCstConstCenterLine( msg, inp, xData, outp, processType )

long			*msg ;
VD_drwInputData		*inp ;
VD_drwExecData		*xData ;
VD_drwGraphicGroup	*outp ;
int			processType ;
{
	long			sts ;	    /* OM completion code.	      */
	int			i, cnt,
				prType,	    /* Process Type Flag              */
				ssCount,    /* Count of reference Surfaces    */
				clCount;    /* Count of symbolic rep.         */
	struct GRid		*clList ;   /* Centerline identifier	      */
	struct GRobj_env	*ssList ;   /* List of reference Surfaces     */
	struct GRobj_env	parObj ;    /* Get parent object for VDdrw3d  */
 	struct GRid		clObj ;     /* Working object 		      */
	struct	VDve_elem_buf	v, h, vv, vh ;
	VD_drwEnvInfo		envInfo ;   /* Enveloper support process      */

	SetProc( VD_drwCstConstCenterLine ); Begin

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;
	prType = processType ;

	__DBGpr_obj( "CenterLine to draw", *(inp->elmId) ) ;

	clCount	 = 0 ;
	clList	 = NULL ;

	ssCount  = 0 ;
	ssList   = NULL ;

	outp->list  = NULL ;
	outp->count = 0 ;

	VD_veInitElemBuf( &v );
	VD_veInitElemBuf( &h );
	VD_veInitElemBuf( &vv );
	VD_veInitElemBuf( &vh );

	envInfo.yes_no		= FALSE ;
	envInfo.env1_obj0	= FALSE ;
	envInfo.count		= 0 ;

	clObj.objid = inp->elmId->objid ;
        clObj.osnum = inp->elmId->osnum ;

	__DBGpr_obj(" INPUT ", clObj );
        /*
	 * Get the parent of a VDdrw3d Section object.
	 */

        if( vd_$is_ancestry_valid(      object  = inp->elmId ,
                                        classid = OPP_VDdrw3d_class_id ) ){
		/*
		 * Get the parent object and replace in process.
		 */

		sts =
		om$send(  msg     = message NDnode.NDget_objects( ND_ROOT,&parObj._grid,
								1, NULL, 1, 1, &cnt ),
			senderid = inp->elmId->objid ,
			targetid = inp->elmId->objid ,
			targetos = inp->elmId->osnum );
		if( (!(sts&1))||( parObj._objid == NULL_OBJID )){
                        *msg = MSFAIL ;
                        goto wrapup ;
                }

		sts =
        	om$send(  msg     = message NDmacro.ACreturn_foot(
                                			msg,
                                                        "",
                                                        &clObj,
                                                        &parObj._matrix_type,
                                                        parObj._matrix ),
                        senderid= parObj._objid,
                        targetid= parObj._objid,
                        targetos= parObj._osnum ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );
		__DBGpr_obj(" Parent ", clObj );
	}
	
        /*
         * Get the number of Centerline object.
         */
        sts = om$send(  msg     = message VDSroot.VDGetCenterLine(
						msg,
						inp->elmEnv,
						&clCount,
						NULL ),
                        senderid= clObj.objid,
                        targetid= clObj.objid,
                        targetos= clObj.osnum ) ;
        if( !( sts & 1 & *msg )||( clCount == 0 )) {
          if( xData->verbose )
            VD_drwPrintf( " !!! Cannot find symbolic rep. in '%s'\n",
                                          inp->constDefName ) ;
            goto wrapup ;
        }

	__DBGpr_int( "clCount", clCount );

        if( ! (clList = _MALLOC( clCount, struct GRid )))
                vd_$mem_fail();

	/*
	 * The Centerline objects are stored as the wireframe output
         */
        sts = om$send(  msg     = message VDSroot.VDGetCenterLine(
						msg,
						inp->elmEnv,
						&clCount,
						&clList ),
                        senderid= clObj.objid,
                        targetid= clObj.objid,
                        targetos= clObj.osnum ) ;
        if( !( sts & 1 & *msg )||( clCount == 0 )) {
          if( xData->verbose )
            VD_drwPrintf( " !!! Cannot find symbolic rep. in '%s'\n",
                                          inp->constDefName ) ;
            goto wrapup ;
        }

	/*
	 * The Centerline objects are stored as the wireframe output
	 * of the pipe segment.
	 */
        if( ! (v.obj_info_p = _MALLOC( clCount, struct GRobj_env )))
                vd_$mem_fail();

        for( i=0 ; i<clCount ; i++ ){

                __DBGpr_obj( "Line ", clList[i] );

                v.obj_info_p[i].obj_id  = clList[i] ;
                v.obj_info_p[i].mod_env = *inp->drwInfo.drwEnv ;
        }

        v.count   = clCount ;
        v.buf_siz = clCount ;

	/*
	 * If more then one object is extracted, find the reference objects.
	 * from the reference list. Object are managed through sets. When
	 * the "refSetName" is non a null-string, the reference objects are
	 
	 * Get solids / surfaces for processing hidden lines.
	 */

	__DBGpr_str( "SetName to check ", inp->refSetName );
	__DBGpr_int( "processType      ", processType );

	if(( processType ) &&
	   ( strlen( inp->refSetName ))) {

	  sts =
	  VD_drwFindRefSurfacesOfObject(	msg, &envInfo,
						inp, xData,
						&ssList, &ssCount ) ;
	  __CheckRC( sts, *msg, "VD_drwFindRefSurfacesOfObject", wrapup );
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

		__DBGpr_int(" ssCount ", ssCount );
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
		 * delete the primiairy list of found edges of the object.
		 */
		VD_veDelElemBuf( &v );
	  }
	  else{
		vv.count	= v.count ;
		vv.buf_siz	= v.buf_siz ;
		vv.obj_info_p	= v.obj_info_p ;
		VD_veInitElemBuf( &v );
	  } /* if ! ssCount */
	}
	else{

		vv.count	= v.count ;
		vv.buf_siz	= v.buf_siz ;
		vv.obj_info_p	= v.obj_info_p ;
		VD_veInitElemBuf( &v );

	} /* if ! processtype */

	__DBGpr_int(" VVcount ", vv.count );
	__DBGpr_int(" VHcount ", vh.count );
	__DBGpr_int("  Hcount ",  h.count );

	/*
	 * Combine the needed edges of the object and project them.
	 * After projection delete all the Covered Curves of the object.
	 */
	processType |= VD_K_DRW_PROCESS_A ;	/* For Output Gen */

	__DBGpr_int( "processType      ", processType );

	sts =
	VD_drwGenerateOutputType(	msg,
					inp,
					xData,
					outp,
					&vv,	/* visible edges */
					&vh,	/* opaque edges  */
					&h,	/* hidden edges  */
					processType );
	__CheckRC( sts, *msg, "VD_drwGenerateOutputType", wrapup ) ;
        __DBGpr_objlist( "CenterLines 2d ", outp->count, outp->list ) ;

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
		VD_veDelElemBuf( &vh );	
		if( prType ) VD_veDelElemBuf( &vv );

		VD_veFreeElemBuf( &v );

	        vd_$bulk_delete(count	= clCount,
				grids   = clList,
                                theEnv  = inp->drwInfo.drwEnv ) ;

		_FREE( clList );

		End
		return sts ;

} /* VD_drwCstConstCenterLines */

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
