/* $Id: VDdrwcstedgV.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwcstedgV.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwcstedgV.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/10  14:39:20  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgV.I for:  by azuurhou for vds
#
# Revision 1.2  1997/10/30  21:24:46  pinnacle
# Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.12  1996/04/29  14:05:04  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgV.I for:  by v240_int for vds.240
#
# Revision 1.11  1995/09/26  16:53:20  pinnacle
# Replaced: ./vddraw/drw/VDdrwcstedgV.I for:  by azuurhou for vds.240
#
# Revision 1.8  1995/08/16  14:51:54  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgV.I for:  by azuurhou for vds.240
#
# Revision 1.7  1995/06/27  18:27:04  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgV.I for:  by azuurhou for vds.240
#
# Revision 1.6  1995/06/02  15:21:04  pinnacle
# Replace: vddraw/drw/VDdrwcstedgV.I by azuurhou for OPE
#
# Revision 1.4  1995/04/06  13:41:26  pinnacle
# Replaced: vddraw/drw/VDdrwcstedgV.I by azuurhou r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	01/01/95	adz		creation date
 *	04/06/95	adz		correction memory.
 *	08/15/95	adz		code correction.
 *	08/22/95	adz		memory management.
 *	10/30/97	ah		Warning messages
 *
 ***************************************************************************/

class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "asbox.h"
#include "exdef.h"
#include "exmacros.h"
#include "dp.h"
#include "dpmacros.h"
#include "EMSmsgdef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "vddlodef.h"
#include "vddlomacros.h"
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

from	ACheader	import	ACfind_model;
from	VDlink		import	ACget_model_list;


extern	OMuword		OPP_VDrelat_hdr_class_id ;

/*
 * Combine the needed edges of the object and project them.
 * After projection delete all the Covered Curves of the object.
 */
/*----------------------------------------------------------------------------*/
long VD_drwGenerateOutputType(	msg, inp, xData, outp,
				vv, vh, h, type )

long			*msg ;
VD_drwInputData         *inp ;
VD_drwExecData		*xData ;
VD_drwGraphicGroup	*outp ;
struct VDve_elem_buf	*vv,
			*vh,
			*h ;
int			type ;

{
	long			sts ;	    /* OM completion code.	      */
	int			mxCount,	
				cvCount;    /* Count of solids / surfaces     */
	struct GRid		*cvList ;

	SetProc( VD_drwGenerateOutputType ); Begin

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	cvList  = NULL ;
	cvCount = 0 ;

	/*
	 * Generate List of needed output for object.
	 */
	mxCount = 0 ;
	cvCount = 0 ;
	if ( type & VD_K_DRW_EDGES_A ){	mxCount += vv->count ; }
	if ( type & VD_K_DRW_EDGES_B ){	mxCount += vh->count ; }
	if ( type & VD_K_DRW_EDGES_C ){	mxCount +=  h->count ; }

	__DBGpr_int( "Number of Edges", mxCount ) ;
	if( ! mxCount ) goto wrapup ;

	if( ! (cvList = _MALLOC( mxCount, struct GRid )))
		vd_$mem_fail();

	if(   ( type & VD_K_DRW_EDGES_A )
	   && ( vv->count )		){

		__DBGpr_int(" EDGES_A : ", vv->count );
		sts =
		VD_drwProjectListAndChangeSymb(	msg, inp, xData, 
						VD_K_DRW_EDGES_A, vv,
						mxCount, &cvCount, cvList );
		__CheckRC( sts, *msg, "VD_drwProjectListAndChangeSymb", wrapup);
	}

	if(   ( type & VD_K_DRW_EDGES_B )
	   && ( vh->count )		){

		__DBGpr_int(" EDGES_B : ", vh->count );
		sts =
		VD_drwProjectListAndChangeSymb(	msg, inp, xData,
						VD_K_DRW_EDGES_B, vh,
						mxCount, &cvCount, cvList );
		__CheckRC( sts, *msg, "VD_drwProjectListAndChangeSymb", wrapup);
	}
	
	if(   ( type & VD_K_DRW_EDGES_C )
	   && ( h->count )		){

		__DBGpr_int(" EDGES_C : ", h->count );
		sts =
		VD_drwProjectListAndChangeSymb(	msg, inp, xData,
						VD_K_DRW_EDGES_C, h,
						mxCount, &cvCount, cvList );
		__CheckRC( sts, *msg, "VD_drwProjectListAndChangeSymb", wrapup);
	}

	outp->count	= cvCount ;
	outp->list	= cvList ;
	cvList		= NULL ;

	__DBGpr_int(" output List : ", outp->count );

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( ! ( sts & 1 & *msg )){

			_FREE( outp->list );
			outp->list	= NULL ;
			outp->count	= NULL ;
		}

		_FREE( cvList );
		End
		return sts ;

} /* VD_drwGenerateOutputType */
		
/*----------------------------------------------------------------------------*/
long VD_drwGiveFeetsBasedOnRep(	msg, buf, envInfo )

long			*msg ;
struct VDve_elem_buf	*buf ;
VD_drwEnvInfo		*envInfo ;	/* enveloppe information   */	

{

	int			sts = OM_S_SUCCESS ,
				i, r,
				doFreeList,
				ftCount ,	/* Number of feets	*/
				tmpCount ;
	struct	GRobj_env	*ftList ,	/* List of feet objects	*/
				*tmpList ;
	GRname			matchRE ;
	VD_dspRep		objRep ;

	SetProc( VD_drwGiveFeetsBasedOnRep ); Begin

	*msg  = MSSUCC ;

	ftCount	 = 0 ;
	tmpCount = 0 ;
	ftList   = NULL ;
	tmpList  = NULL ;
	doFreeList	= FALSE ;

	/*
	 * Do a quick checking before the allocation process.
	 */
	if( buf->count == 1 ){

	  if( !( vd_$is_ancestry_valid(
			object  = & (buf->obj_info_p[0]._grid) ,
			classid = OPP_ACncpx_class_id ))){

		__DBGpr_com(" Not a ACncpx object " );
		return sts ;
	  }
	
	  if( VD_validateObjectRep(	& (buf->obj_info_p[0]._grid ),
					& objRep,
					(VD_dspRep) AC_3D_REP )){

		__DBGpr_com(" Object Rep: AC_3D_REP ");
		return sts ;
	  }
	}

	/*
	 * Check the list with reallocation of input list.
	 */
	for( i=0 ; i<buf->count ; i++ ){

	    matchRE[0] 	= '\0' ;
	    if(( vd_$is_ancestry_valid(
			object	= & (buf->obj_info_p[i]._grid) ,
			classid	= OPP_ACncpx_class_id			)) &&

	       ( !( VD_validateObjectRep(
					& (buf->obj_info_p[i]._grid ),
					& objRep,
					(VD_dspRep) AC_3D_REP ))) ){

		/*
		 * Get the object specific information.
		 */
		for( r=0 ; r<envInfo->count ; r++ ){

		  if( objRep == envInfo->rep[r].rep_val ){

		    strcat( matchRE, envInfo->rep[r].match );
		    if( strlen( envInfo->rep[r].match )){
		      strcat( matchRE, "|" );
		    }
		  }
		}

		__DBGpr_str(" LO Name ", matchRE );

		if( strlen( matchRE ) == 0 ) goto default_object ;

	        doFreeList = TRUE ;

		sts =
		VD_findMatchFtNameSlSfInMacro(
					msg,
					& (buf->obj_info_p[i]._grid ),
					& (buf->obj_info_p[i].mod_env ),
					matchRE,
					envInfo->env1_obj0,
					&ftList,
					&ftCount );
		if( !(sts&*msg&1) ){
		  __DBGpr_com("Invalid Process VD_findMatchFtNameSlSfInMacro ");

		  _FREE( ftList );
		  ftList = NULL ;
		  doFreeList = FALSE ;
		  goto default_object ;
		}
	    } /* if ancestry + validate */
	    else{

		/*
		 * get the default option.
		 */
default_object:
		doFreeList = FALSE ;

		if( ! envInfo->env1_obj0 ){
			ftCount = 1 ;
			ftList  = & ( buf->obj_info_p[i] );
		}
		else{
			__DBGpr_com(" Nothing Needed Here ");
			ftCount = 0 ;
			ftList  = NULL ;
		}
	    }

	    __DBGpr_int(" Feet List ", ftCount );

	    if( ! ftCount ) continue ;

	    /*
	     * collect the output.
	     */
            if( tmpCount ) {
                if( !( tmpList = _REALLOC(      tmpList,
                                                tmpCount + ftCount,
                                                struct GRobj_env ) ) )
                        vd_$mem_fail() ;
            } else {
                if( !( tmpList = _MALLOC(	ftCount,
						struct GRobj_env ) ) )
                        vd_$mem_fail() ;
            }

	    for( r=0 ; r<ftCount ; r++ ) tmpList[tmpCount+r] = ftList[r];
	    tmpCount += ftCount ;

	    if( doFreeList )  _FREE( ftList );
	    doFreeList = FALSE ;
	    ftList  = NULL ;
	    ftCount = 0 ;

	} /* for ..  buf->count */

	/*
	 * Delete the original list and reattach this list.
	 */
	VD_veFreeElemBuf( buf );

	buf->count	= tmpCount ;
	buf->buf_siz	= tmpCount ;
	buf->obj_info_p	= tmpList ;

	tmpList = NULL ;

	wrapup:

		if( doFreeList )	_FREE(	ftList );
		_FREE(	tmpList );	/* in case of errors.	*/

		End
		return sts ;
}

#argsused // Get rid of warning

/*----------------------------------------------------------------------------*/
long VD_drwCstConstIndividual(	msg,
				elmId, elmEnv,
				xData, envInfo,
				v, h )

long			*msg ;
struct	GRid		*elmId ;
struct	GRmd_env	*elmEnv ;
VD_drwExecData		*xData ;
VD_drwEnvInfo		*envInfo ;	/* envelope information   */	
struct	VDve_elem_buf	*v ;
struct	VDve_elem_buf	*h ;

{
	IGRint			sts = OM_S_SUCCESS ;
	IGRdouble		VDwld_to_viewport[16],
				VDviewport_to_wld[16],
				VDrotation[16],
				VDwld_to_view[16];
//	IGRint			msCount = 0 ;
	struct  VDve_elem_buf	buf;

	SetProc( VD_drwCstConstIndividual ); Begin

	/*
	 * Get the solids and surfaces of the object with corresponding
	 * environment.
 	 */
	VD_veInitElemBuf( &buf );
	VD_veInitElemBuf( v );
	VD_veInitElemBuf( h );

	/*
	 * Check for special object types.
	 */

	if( vd_$is_ancestry_valid(
			object	= elmId,
			classid	= OPP_VDrelat_hdr_class_id )){

		IGRint			j,
					len = 5;	/* Max link list */
		struct	GRid		relObj,
					list[5] ;
		struct	GRmd_env	relEnv ;

	  relEnv._MD_OS	= elmId->osnum ;

	  sts =
	  ex$get_modid(	mod_osnum	=  relEnv._MD_OS,
			mod_id		= &relEnv._MD_ID );

	  sts =
	  _VD_SEND_OBJN(	*elmId,
				GRowner.GRget_matrix(	msg,
							&elmEnv->_MATRIX_TYPE,
							elmEnv->_MATRIX,
							&relEnv._MATRIX_TYPE,
							relEnv._MATRIX ));
	  __CheckRC( sts, *msg, "GRowner.GRget_matrix", wrapup );

	  __DBGpr_mat( " elmEnv ", elmEnv->_MATRIX );
	  __DBGpr_mat( " relEnv ", relEnv._MATRIX );

	  sts =
	  _VD_SEND_OBJN(	*elmId,
				ACheader.ACfind_model( msg, &relObj ));
	  __CheckRC( sts, *msg, "ACheader.ACfind_model", wrapup );

	  sts =
	  _VD_SEND_OBJN(	relObj,
				VDlink.ACget_model_list(	msg,
								len,
								list,
								&len ));
	  __CheckRC( sts, *msg, "VDlink.ACget_model_list", wrapup );

	  if( ! (buf.obj_info_p = _MALLOC( len, struct GRobj_env )))
		vd_$mem_fail();

	  for( j=0 ; j<len ; j++ ){

		__DBGpr_obj( "relObj ", list[j] );

		buf.obj_info_p[j].obj_id  = list[j] ;
		buf.obj_info_p[j].mod_env = *elmEnv ;
	  }

	  buf.count   = len ;
	  buf.buf_siz = len ;

	}
	else{

	  if( ! (buf.obj_info_p = _MALLOC( 1, struct GRobj_env )))
		vd_$mem_fail();

	  buf.obj_info_p[0].obj_id		= *elmId ;
	  buf.obj_info_p[0].mod_env	= *elmEnv;
	  buf.count	= 1 ;
	  buf.buf_siz	= 1 ;
	}

	/*
	 * Check if the object is an enveloppe representation and check
	 * according the input setting if this is needed.
	 */
	if( envInfo ){
	  if( envInfo->yes_no ){

		__DBGpr_com(" Check for ENVELOPE " );

		/*
		 * Check the object representation type.
		 */
		sts =
		VD_drwGiveFeetsBasedOnRep(	msg, &buf, envInfo );
		__CheckRC( sts, *msg, "VD_drwGiveSfsBasedOnRep", wrapup );
	  }
	}

	/*
	 * get matrix information.
	 */
	MAidmx( msg, VDwld_to_viewport );
	MAidmx( msg, VDviewport_to_wld );
	MAidmx( msg, VDwld_to_view );
	MAidmx( msg, VDrotation );

	/*
	 * Final checking before sending.
	 */
	if( buf.count ){

		__DBGpr_int(" buf.count ", buf.count );

		sts =
		VDve_process(	msg, &buf, v, h,
				VDwld_to_viewport,	VDviewport_to_wld,
				VDrotation,		VDwld_to_view );
	}

	__DBGpr_int(" vis_buf ", v->count );
	__DBGpr_int(" hid_buf ", h->count );

	wrapup:
		if( ! (sts & *msg & 1 )){
			VD_veDelElemBuf( v );
			VD_veDelElemBuf( h );
		}

		VD_veFreeElemBuf( &buf );
	
		End
		return sts ;
}
/*----------------------------------------------------------------------------*/
long VD_drwCstConstVisEdges( msg, inp, xData, outp, processType )

long			*msg ;
VD_drwInputData		*inp ;
VD_drwExecData		*xData ;
VD_drwGraphicGroup	*outp ;		    /* output graphics list           */
int			processType ;	    /* vis/env-edge type              */
{
	long			sts ;	    /* OM completion code.	      */
	int			ssCount;    /* Count of solids / surfaces     */
	struct GRobj_env	*ssList ;   /* List of solids / surfaces      */
	struct	VDve_elem_buf	v, h,
				vv, vh;
	VD_dspRep		objRep ;
	VD_drwEnvInfo		envInfo ;	/* enveloppe information   */	

	SetProc( VD_drwCstConstVisEdges ); Begin

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	outp->list  = NULL ;
	outp->count = 0 ;

	ssCount	 = 0 ;
	ssList	 = NULL ;

	VD_veInitElemBuf( &v );
	VD_veInitElemBuf( &h );
	VD_veInitElemBuf( &vv );
	VD_veInitElemBuf( &vh );

	__DBGpr_obj( "Construction to draw", *(inp->elmId) ) ;

	/*
	 * This function will be called for the main object and the envelope
	 * object part.
	 * The envelope representation will only be activated when the
	 * global flag is set. When this is not the case the function will
	 * do nothing.
	 */

	envInfo.yes_no	  = ( xData->processFlags & VD_drwCheckEnvelopes )
				? TRUE : FALSE ;
	envInfo.env1_obj0 = ( processType & VD_K_ENV_PROCESS_TYPE )
				? TRUE : FALSE ;

        if( envInfo.env1_obj0 ){

	  __DBGpr_com(" Envelope Processing ");

	  if( (	! envInfo.yes_no ) ||
		( VD_validateObjectRep(	inp->elmId,
					& objRep,
					(VD_dspRep) AC_3D_REP )) ){
		__DBGpr_com(" Envelope : Don't do any processing " );
		goto wrapup;
	  }
	}

        if( envInfo.yes_no ){
		
		/*
		 * Get the global information to compare the envelope
		 * structures.
		 */
		sts =
		VD_drwGetEnvInformation( msg, &envInfo );
		__CheckRC( sts, *msg, "VD_drwGetEnvInformation", wrapup );
	}

	/*
	 * Process the object independent.
	 */
	sts = VD_drwCstConstIndividual( msg,
					inp->elmId, inp->elmEnv,
					xData, &envInfo,
					&v, &h );
	__CheckRC( sts, *msg, "VD_drwCstConstIndividual", wrapup ) ;

	/*
	 * If more then one object is extracted, find the reference objects.
	 * from the reference list. Object are managed through sets. When
	 * the "refSetName" is non a null-string, the reference objects are
	 * get throught this.
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
		 * delete the primiairy list of found edges of the object.
		 */
		VD_veDelElemBuf( &v );
	}
	else{
	  vv.count	= v.count ;
	  vv.buf_siz	= v.buf_siz ;
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

        __DBGpr_objlist( "VisEdges 2d ", outp->count, outp->list ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( ! ( sts & 1 & *msg ) ) {

			__DBGpr_com("ERROR in VD_drwCstConstVisEdges\n");

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

} /* VD_drwCstConstVisEdges */

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
