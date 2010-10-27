/* $Id: VDgetvolints.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmisc/VDgetvolints.I
 *
 * Description:
 *	A intersection/save side macro for section-cuts or other boolean
 *	operations.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDgetvolints.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/06/28  20:13:18  pinnacle
# AVD worksheet
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1995/06/05  13:20:12  pinnacle
# Replace: vdmisc/VDgetvolints.I by azuurhou for OPE
#
# Revision 1.6  1995/05/09  11:44:00  pinnacle
# Replace: vdmisc/VDgetvolints.I by azuurhou for OPE
#
# Revision 1.5  1995/05/01  16:21:14  pinnacle
# Replace: vdmisc/VDgetvolints.I by azuurhou for OPE
#
# Revision 1.4  1995/04/04  22:13:18  pinnacle
# Replaced: vdmisc/VDgetvolints.I by azuurhou r#
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/02/95	adz		creation date
 *	04/04/95	adz		Return list was invalid managed.
 *	05/01/95	adz		When no surface/solid was found the
 *					list was still returned.
 *	05/07/95	adz		Checking before intersections.
 *	05/22/95	adz		Change hole interact with interaction
 *					and added wireframe checking.
 *	06/28/99	adz		WS of AVD with processing of Compartment
 *					volumes. SdSf is change into Surfaces.
 ***************************************************************************/

class implementation VDSroot ;

#include <stdlib.h>
#include "OMmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "msmacros.h"
#include "EMSmsgdef.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "VDvolelem.h"
#include "vd_ve.h"
#include "v_edgedef.h"
#include "v_edgemacros.h"
#include "v_globalmsg.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_datamacros.h"
#include "v_dbgmacros.h"
#include "AS_status.h"
/*
 * Includes of function prototypes.
 */
#include "v_ioproto.h"

extern	GRclassid	OPP_GRbspline_class_id ;
extern	GRclassid	OPP_EMSsolid_class_id ;
extern	int		SMSplS1ByS2();
extern	int		SMBndS1BySfs();
extern	IGRboolean	ASbroadcast_in_progress ;

#define _REALLOC( ptr, nelem, type ) \
	(type *) realloc( (ptr), (unsigned) ( (nelem) * sizeof( type ) ) )

/*----------------------------------------------------------------------------*/

/*
 * Algorithm:
 *
 * Input	: List of object to be intersected.
 *		  Operand object (solid) against which the object are
 *		  intersected.
 * 		  Construction Environment.
 * Output	: List of graphical objects (Wf,Sf,Sd).
 *
 * Steps:	: First we get all the graphical components of the object(s).
 *		: One by One we will intersect the object.
 *		  When object is Solid/Surface, the space mananagement 
 *		  split routine will be used. This routine is save for
 *		  solids, but can give invalid results for surfaces. When the
 *		  surface is coincidence with the operand, the split will
 *		  fail. 
 *		  To cover this the surfaces will ve reprocesed against the 
 *		  solid surfaces, with extention option for the solid
 *		  surfaces. Solids will succeed. The problem with solids is
 *		  that data reduction is not changing the range (and lot more)
 *		  for several cases.
 *		  The routine VDchkrngrng will called for the solid and
 *		  surfaces. Internaly, it will return TRUE for solids.
 *		  Surface ranges will be checked aginst the operand.
 *		  Wireframe objects are done seperated.
 */

long VD_get_volume_intersect(	msg,
				optrCount,
				optrList,
				operand,
				resCst,
				resCount,
				result )
/*
 * This function is interfaced by macro vd_$get_volume_intersect,
 * #defined in "v_geommacros.h".
 */

long			*msg ;
int			optrCount;
struct GRobj_env	optrList[],
			*operand ;
struct GRvg_construct	*resCst ;
int			*resCount ;
struct GRid		**result ; {

	int			i, j ;		/* Loop index		*/
	long			sts;		/* OM return code	*/
	IGRboolean		saveBroadcast ;	/* Save-broadcast flag	*/
	struct GRmd_env		*cstEnv	;	/* Unburdens compiler	*/
	struct GRid		*outList,
				intSurf ;
	struct GRobj_env	*cvList ;
	IGRchar			relation ;
	IGRint			outCount ,
				cvCount ,
				outMalloc ;
	IGRint			*revList ;	/* For checking split proc */
	struct VDve_elem_buf	buf, bufOp, bufSd;
	struct GRsymbology	elmSymb ;

	/*
	 * intersection constants.
	 */
	IGRboolean		Reverse	 = FALSE ;	
	IGRboolean		NeedCopy = TRUE ,
				Extend   = FALSE ,
				Infinite = FALSE ;

	SetProc( VD_get_volume_intersect ); Begin
		
	sts = OM_S_SUCCESS ;
	cstEnv = resCst->env_info ;
	resCst->properties |= GRIS_NEW ;

	saveBroadcast = ASbroadcast_in_progress ;
	ASbroadcast_in_progress = TRUE ;

	*resCount	= 0 ;
	*result		= NULL ;

	cvCount		= 0 ;
	cvList		= NULL ;

	revList		= NULL ;
	outList		= NULL ;
	outCount	= 0 ;
	outMalloc	= 0 ;

	buf.count	= 0 ;		bufOp.count	= 0 ;
	buf.buf_siz	= 0 ;		bufOp.buf_siz	= 0 ;
	buf.obj_info_p	= NULL ;	bufOp.obj_info_p = NULL ;

	bufSd.count	= 0 ;
	bufSd.buf_siz	= 0 ;
	bufSd.obj_info_p = NULL ;

	/*
	 * Get all the surfaces of the object.
	 */

#ifdef	vdsDEBUG
	__DBGpr_com(" OptrList : ");
	for( i=0 ; i<optrCount ; i++ ) VD_ShowObj( & optrList[i].obj_id );
#endif

	/*
	 * Get the Solids, Surfaces and Wireframe objects of the
	 * input object.
	 * Adz (6/99): Change the VD_K_gm_SdSfWf into Surface and Wireframe options 
 	 *	only. by selecting VD_K_gm_SURFACE | VD_K_gm_WIREFRAME. 
	 */
	sts =
	vd_$select_obj_comps(	msg	= msg,
				option  = VD_K_gm_SURFACE | VD_K_gm_WIREFRAME ,
				count   = optrCount,
                                objEnvs = optrList,
                                elmList = &buf );
	__CheckRC( sts, *msg, "vd_$select_obj_comps", wrapup );

	__DBGpr_int(" NUMBER COMP", buf.count );
#ifdef	vdsDEBUG
	__DBGpr_com(" Component List : ");
	for( i=0;i<buf.count;i++ ) VD_ShowObj( & buf.obj_info_p[i].obj_id );
#endif

	if( ! buf.count )	goto wrapup ;

	outMalloc = buf.count + 10 ;
	if( ! ( outList = _MALLOC( outMalloc, struct GRid )))
		vd_$mem_fail();

	for( j=0; j<buf.count ; j++ ){

#ifdef	vdsDEBUG
	  VD_ShowObj( & buf.obj_info_p[j]._grid );
#endif

	  if( ! (vd_$is_ancestry_valid(
			object  = & buf.obj_info_p[j]._grid,
			classid = OPP_GRbspline_class_id ))){
	
	    /*
	     * Check if the object is totaly inside.
	     */
	    relation = VD_UNKNOWN ;
	    VDsolid_surf_rln(	msg,
				& (operand->obj_id),
				& (operand->mod_env),
				& buf.obj_info_p[j]._grid,
				& buf.obj_info_p[j].mod_env,
				& relation );

	    if( (*msg&1) && relation == VD_OUTSIDE ){
	      __DBGpr_com(" Object Outside - continue ");
	      continue ;
	    }

	    /*
	     * Check if enough memory available for output list.
	     */
	    if( outCount+1 >= outMalloc ){
	      outMalloc += 10 ;
	      if( !( outList = _REALLOC( outList, outMalloc, struct GRid )))
		    vd_$mem_fail();
	    }

	    if( (!(*msg&1)) || relation != VD_INSIDE ){

	      intSurf.objid = NULL_OBJID ;

	      sts =
	      SMSplS1ByS2(	resCst,
				buf.obj_info_p + j,
				operand,
				Infinite,
				Extend,
				Reverse,
				NeedCopy,
				&intSurf );
	      if( (sts&1) &&
		VD_checkRangeInsideRange(	msg, operand, NULL,
						&intSurf, cstEnv, TRUE ) ){
		/*
		 * Accep the object.
		 */
		__DBGpr_com(" Accecpt Object with SMSplS1ByS2 ");
		outList[outCount++] = intSurf ;
	      }
	      else{
	        /*
	         * delete the previous try.
		 */
	        if( intSurf.objid != NULL_OBJID ){
		  vd_$bulk_delete(	count	= 1,
					theEnv	= cstEnv,
					grids	= &intSurf );
		}

		/*
		 * Get the surfaces of the solid object;
		 * This is needed when the primary intersect fails as
		 * result of coincidence surfaces.
		 */

		if( bufOp.obj_info_p == NULL ){
		  sts =
		  vd_$select_obj_comps(msg	= msg,
					option  = VD_K_gm_SURFACE,
					count   = 1,
					objEnvs = operand,
					elmList = &bufOp );
		  /*
		   * Set all surface of the operand solid to FALSE.
		   */
		  if( ! ( revList = _MALLOC( bufOp.count, IGRint )))
			vd_$mem_fail();
		  for( i=0; i<bufOp.count ; i++ ){ revList[i] = FALSE ; }
		}

		/*
		 * See if the object is a surface or a solid.
		 * When it is a solid-intersect the surfaces.
		 */
		if( vd_$is_ancestry_valid(
                        object  = & buf.obj_info_p[j]._grid,
                        classid = OPP_EMSsolid_class_id )){

		  /*
		   * Get the surfaces of the solid.
		   */
		  bufSd.count		= 0 ;
		  bufSd.buf_siz		= 0 ;
		  _FREE( bufSd.obj_info_p );
		  bufSd.obj_info_p 	= NULL ;
		
		  sts =
		  vd_$select_obj_comps(msg	= msg,
					option  = VD_K_gm_SURFACE,
					count   = 1,
					objEnvs = buf.obj_info_p +j,
					elmList = &bufSd );
		  /*
		   * Check if we have enough memory.
		   */
		  if( outCount+bufSd.count >= outMalloc ){
		    outMalloc = outMalloc + bufSd.count + 10 ;
		    if( !( outList = _REALLOC(outList,
						outMalloc, struct GRid )))
			vd_$mem_fail();
		  }

		  for( i=0 ; i<bufSd.count ; i++ ){
		    /*
		     * check each surface against the solid.
		     */
#ifdef  vdsDEBUG
	            VD_ShowObj( & bufSd.obj_info_p[i]._grid );
#endif
		    sts =
		    SMBndS1BySfs(	resCst,
					bufSd.obj_info_p + i,	/* to check */
					Infinite,	/* Inf S1 -> NO	   */
					bufOp.count,	/* Solid parts     */
					bufOp.obj_info_p, /* Solid Sf's      */
					revList,
					Infinite,
					Extend,
					Reverse,
					&intSurf );
		    /*
		     * Check the result.
		     */
		    if( (sts&1) &&
		      VD_checkRangeInsideRange( msg, operand, NULL,
						&intSurf, cstEnv, TRUE ) ){
		      /*
		       * Accep the object.
		       */
		      __DBGpr_com(" Accecpt Object with SMBndS1BySfs ");
		      outList[outCount++] = intSurf ;
		    }
		    else{
		      __DBGpr_obj("SMBndS1ByS2 fails",
					bufSd.obj_info_p[j]._grid );
		      if( intSurf.objid != NULL_OBJID ){
			vd_$bulk_delete(	count	= 1,
						theEnv	= cstEnv,
						grids	= &intSurf );
	              }
		    }
		  }
		}
		else{

		  /*
		   * Check the input object again for surfaces.
		   */
		  sts =
		  SMBndS1BySfs(	resCst,
				buf.obj_info_p + j,	/* to check */
				Infinite,	/* Inf S1 -> NO	   */
				bufOp.count,	/* Solid parts     */
				bufOp.obj_info_p, /* Solid Sf's      */
				revList,
				Infinite,
				Extend,
				Reverse,
				&intSurf );
		  /*
		   * Check the result.
		   */
		  if( (sts&1) &&
		    VD_checkRangeInsideRange(	msg, operand, NULL,
						&intSurf, cstEnv, TRUE ) ){
		      /*
		       * Accep the object.
		       */
		     __DBGpr_com(" Accecpt Object with SMBndS1BySfs ");
		    outList[outCount++] = intSurf ;
		  }
		  else{
		    __DBGpr_obj("SMBndS1ByS2 fails",buf.obj_info_p[j]._grid );
		    if( intSurf.objid != NULL_OBJID ){
		      vd_$bulk_delete(	count	= 1,
					theEnv	= cstEnv,
					grids	= &intSurf );
		    }
		  }
		}
	      } /* Alternative processing. */
	    } /* if VDsolid_srf_rln */

	    else{
	      /*
	       * OBject is inside the solid.
	       * Copy the input object and add in list.
	       */
	      intSurf.objid = NULL_OBJID ;
	      sts =
	      vd_$grCopy(	msg	= msg,
				frEnv	= & buf.obj_info_p[j].mod_env,
				frObj	= & buf.obj_info_p[j]._grid,
				toEnv	= cstEnv,
				toObj	= &intSurf );
	      if( sts & *msg & 1 ){
		/*
		 *  resulting object accepted.
		 */
		__DBGpr_com(" Copy Accepted ");
		outList[outCount++] = intSurf ;
	      }
	    }
	  } /* if( vd_$is_ancestry_valid .. ) */

	  else{
	    /*
	     * Check the wireframe objects against the solid.
	     */
	    sts = 
	    VD_splitCrvBySolid(	msg,
				resCst,
				buf.obj_info_p +j,
				operand,
				&cvCount,
				&cvList );
	    if( ! ( sts & *msg & 1 ) || ( cvCount == 0 )){
		_FREE( cvList );
		cvList = NULL ;
		continue ;
	    }

	    /*
	     * Check for reallocation of output buffer.
	     * More then one object can be generated.
	     */
	    if( outCount+cvCount >= outMalloc ){
	      outMalloc = outMalloc + cvCount + 10 ;
	      if( !( outList = _REALLOC( outList, outMalloc, struct GRid )))
		    vd_$mem_fail();
	    }

	    for( i=0 ; i<cvCount ; i++ )
	      outList[outCount++] = cvList[i]._grid ;
	    _FREE( cvList );
	    cvList = NULL ;
	  } /* else .. wireframe objects */
	} /* for buf.count  */

	/*
	 * return the resulting objects.
	 */
	elmSymb.level			= resCst->level ;
	elmSymb.display_attr.color	= resCst->display->color ;
	elmSymb.display_attr.weight	= resCst->display->weight ;
	elmSymb.display_attr.style	= resCst->display->style ;

	__DBGpr_int(" outCount ", outCount );

	for( i=0 ; i<outCount ; i++ ){
		sts =
		_VD_SEND_OBJN(	outList[i], GRvg.GRputsymb( msg, &elmSymb ));
		__CheckRC( sts, *msg, "GRvg.GRputsymb", wrapup );
	}

	if( outCount ){
		*resCount = outCount ;
		*result   = outList  ;
		outList   = NULL ;
	}

	sts = OM_S_SUCCESS ;
	*msg = MSSUCC ;

wrapup :

	ex$message( msgnumb = VD_gI_EmptyMessage ) ;
	ASbroadcast_in_progress = saveBroadcast ;

	if( !( sts & 1 & *msg )){
		/*
		 * Delete result if constructed.
		 */

		__DBGpr_com(" Error occured in process. ");

		if( outList ) {
			vd_$bulk_delete(count	= outCount,
					grids	= outList,
					theEnv	= cstEnv ) ;
		}
		_FREE( outList );
		outList = NULL ;
		*resCount = 0 ;
		*result   = NULL ;
	}

	_FREE( buf.obj_info_p );
	_FREE( bufOp.obj_info_p );
	_FREE( bufSd.obj_info_p );
	_FREE( revList );
	_FREE( cvList );
	_FREE( outList );		/* INCASE of Zero objects found. */

	End
	return sts ;

} /* VD_get_volume_intersect */

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
