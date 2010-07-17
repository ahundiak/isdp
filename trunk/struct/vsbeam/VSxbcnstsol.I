/* $Id: VSxbcnstsol.I,v 1.2 2001/11/04 17:34:33 jayadev Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbeam/VSxbcnstsol.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSxbcnstsol.I,v $
 *      Revision 1.2  2001/11/04 17:34:33  jayadev
 *      fix for TR#5723
 *
 *      Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/07/15  20:26:32  pinnacle
# For TR #179801182 , math.h included.
#
# Revision 1.4  1998/01/21  20:31:16  pinnacle
# Replaced: vsbeam/VSxbcnstsol.I for:  by svkadamb for struct
#
# Revision 1.3  1998/01/02  12:24:54  pinnacle
# Replaced: vsbeam/VSxbcnstsol.I for:  by svkadamb for struct
#
# Revision 1.2  1997/09/29  19:10:36  pinnacle
# TR179700841
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      09/26/97        ah              added header
 *      09/29/97        ah		TR179700841, partial fix
 *      09/14/98        manoj		TR179701882  math.h included
 *					             because protype of 
 *						     fabs was required. 
 *      11/04/01        Jayadev		TR#MP5723 - some tabbing done on the
 *                                      code in emacs to organize it better
 *
 ***************************************************************************/

class implementation VSxtrBeam ;

#include <stdlib.h>
#include "math.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "nddef.h"
#include "EMSutlmacros.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSsfparms.h"
#include "EMSssprops.h"
#include "emsinter.h"
#include "emssfint.h"
#include "EMSsfintsort.h"
#include "emsbool.h"
#include "VDchn.h"
#include "v_geommacros.h"
#include "vsglobalmsg.h"
#include "vsRDBdef.h"
#include "vsbeammacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vschgsymb.h"
#include "vsioproto.h"

extern long		VSmustRevOrient() ;
extern void		VSsetGRids() ;
extern long		VSext_axis_for_trimming_plane() ;

extern OMuword		OPP_EMSslboolean_class_id,
			OPP_EMSplane_class_id,
			OPP_GR3dlineseg_class_id,
			OPP_GRbcsubbc_class_id ;

from	EMSsurface	import	EMtrim_a_surface ;
from	EMSsfboolean	import	EMboolean ;
from    EMSsubbs	import  EMget_props ;

#define EXTRA_LENGTH_PERCENTAGE	0.1

/*
 * This macro will make sure I don't forget an argument !.
 */
#omdef vs$mustRevOrient( msg, sfGeom, cvGeom, isNatNorm, p_revOrient )
	VSmustRevOrient( (msg), (sfGeom), (cvGeom), (isNatNorm), (p_revOrient) )
#endomdef
/*----------------------------------------------------------------------------*/
method VScnst_solid_rep(	long			*msg ;
				struct GRmd_env		*myEnv ;
				long			parentType ;
				struct GRobj_env	*trimSurf ;
				VSdspRep		sectRep ;
				struct GRvg_construct	*cst ;
				struct GRmd_env		*solidEnv ;
				struct GRid		*solidToExtend,
							*solidRep ) {

	long			sts,		/* OM return code	*/
				rc ;		/* Aux. return code	*/
	struct GRmd_env		*cstEnv ;	/* Construct env.	*/
	VSsuppList		supports ;	/* List of supports	*/
	struct GRobj_env 	extIdEnv,	/* Portion of curve	*/
				xsIdEnv ;	/* Cross-section curve	*/
	struct IGRbsp_curve	*axisGeom,	/* Geometry of axis	*/
				*extnGeom ;	/* Geometry of extension*/
	struct IGRbsp_surface	*trimGeom ;	/* Geometry of trim surf*/
	OMuword			extClassid ;	/* Cl. of extended axis	*/
	struct GRvg_construct	solidCst ;	/* Const. list of rep.	*/
	struct EMSsortpt_info	whichSide,
				*badPts ;	/* From trimming	*/
	int			suppCount,	/* Count of supports	*/
#define EXT_TRIM_project	0		/* Trim sf. of proj.	*/
#define EXT_TRIM_prjcompsf	1		/* Trim cmpsf. of proj.	*/
#define EXT_TRIM_any		2		/* All the others	*/
				perform,	/* What trim+extend ?	*/
				revOrient,	/* Rev. sf. orient. ?	*/
				nbBadPts,	/* From trimming	*/
				isNatNorm ;	/* Is normal of trimming*/
						/* surface natural ?    */
	OM_S_OBJECT_LINKAGE	owner ;		/* Of selective diff.	*/
#define X_SECTN	0				/* Cross-section curve	*/
#define	EXTAXIS	1				/* Extension of axis	*/
#define MXTMPOB 2
	struct GRid		tmpObj[MXTMPOB],/* Temporaries to be
						   deleted.		*/
#define EXTBMSG	0				/* Extension of beam	*/
#define	UNIONSL	1				/* Of input & ext. segs	*/
#define	SELDIFF	2				/* Selective difference	*/
#define MXCSTOB 3

				cstObj[MXCSTOB];/* Objects to be deleted
						   upon error, but kept
						   otherwise		*/
	unsigned char		props ;		/* Properties of        */
					        /* trimming surface.    */

	cstEnv = cst->env_info ;

	/*
	 * Init stuff.
	 */
	VSsetGRids( cstEnv->_MD_OS, MXTMPOB, tmpObj ) ;
	VSsetGRids( cstEnv->_MD_OS, MXCSTOB, cstObj ) ;
	solidRep->objid = NULL_OBJID ;
	axisGeom	= extnGeom = NULL ;
	trimGeom	= NULL ;

	/*
	 * If the solid to extend is a solid build on a (composite) surface of
	 * projection we can use the EMS message EMtrim_a_surface.
	 */
	if( parentType & VS_m_SRC_generic ) {
		int			RC,
					ix = -1 ;
		struct ret_struct	attr ;

		/*
		 * The geometry type of the beam is decided using the geometry
		 * of the axis. Since our axis does not exist at this stage,
		 * we use parent's.
		 */
		om$send(msg	= message NDmacro.ACgive_structure(
						&RC, &ix, VS_K_prMbrGeoAttr,
						&attr, myEnv ),
			targetid= my_id ) ;
		
		/*
		 * TR 179700841 Don't use == on a double!
		 * Skewed beam in test case returns .0000001 instead of 0 on one end
		 *	if( attr.var.root_pm_st.value == VS_rdb_bmLINEAR ) {
		 */
		if (fabs(attr.var.root_pm_st.value - VS_rdb_bmLINEAR) < .01){ 
		  perform = EXT_TRIM_prjcompsf ;
		} else	{
		  perform = EXT_TRIM_any ;
		}
	} else {
	  perform = EXT_TRIM_any ;
	}
	
	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= cstEnv,
				Display		= cst->display,
				Level		= cst->level,
				Cnst_list	= solidCst ) ;
	/*
	 * Get supporting geometry. Reminder #0 : surface, #1 axis.
	 * Send wrt message since our VSgetSupports will return an extended
	 * axis.
	 */
	sts = om$send(	msg	= message VSmodBeam.VSgetSupports(
	  msg, myEnv, &suppCount, supports ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;
	
	
	sts = om$send(	msg	= message VSbeam.VSextractProfile(
 						msg,
       						myEnv,
       						supports + 0,
       						supports + 1,
       						(double) (perform == EXT_TRIM_any ? me->extEnd : 0),
       						cst,
       						sectRep,
       						&tmpObj[X_SECTN] ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;
	
	xsIdEnv._grid	= tmpObj[X_SECTN] ;
	xsIdEnv.mod_env	= *cstEnv ;
	
	/*
	 * Get geometry of support axis and trimming surface.
	 */
	vs$get_geometry(	msg	= msg,
				grobjId	= &supports[1]._grid,
				grobjEnv= &supports[1].mod_env,
				geometry= &axisGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
	
	vs$get_geometry(	msg	= msg,
				grobjId	= &trimSurf->_grid,
				grobjEnv= &trimSurf->mod_env,
				geometry= &trimGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
	
	/*
	 * Create portion of curve extending axis at desired end, till it
	 * intersects trimming surface and goes beyond, if possible.
	 * We need to go beyond to make sure generated beam segment will
	 * penetrate the trimming surface.
	 */
	if(    perform == EXT_TRIM_any
	       && vs$is_ancestry_valid(	object	= &supports[0]._grid,
	    				classid	= OPP_EMSplane_class_id )
	       && vs$is_ancestry_valid(	object	= &trimSurf->_grid,
	    				classid	= OPP_EMSplane_class_id ) ) {
	  
	  /*
	   * Special case: use more reliable (ie. working more often)
	   * algorithm.
	   */
	  
	  struct GRid	myGRid ;
	  
	  myGRid.objid	= my_id ;
	  myGRid.osnum	= OM_Gw_current_OS ;
	  
	  sts = VSext_axis_for_trimming_plane(	
	                                msg,
			       		&myGRid,
			       		myEnv,
			       		supports,
			       		axisGeom,
			       		trimGeom,
			       		(double) me->extEnd,
			       		/*
			       		 * Have extended portion a little bigger to
			       		 * make sure that the beam segment constructed
			       		 * on this portion will penetrate the trimming
			       		 * plane so that the boolean difference later
			       		 * has a chance to succeed.
			       		 */
			       		EXTRA_LENGTH_PERCENTAGE,
			       		/* 
			       		 * Return extended portion,
			       		 * not the whole curve:
			       		 */
			       		TRUE,
			       		&extnGeom ) ;
	  __CheckRC(sts,*msg,"VSext_axis_for_trimming_plane",wrapup);
	  
	} else {
	  sts = vs$mk_portion_of_cv_through_sf(
	                            msg		= msg,
	                            curveGeom	= axisGeom,
	                            surfaceGeom	= trimGeom,
	                            whichEnd	= me->extEnd,
	                            p_portionGeom	= &extnGeom ) ;
	  __CheckRC(sts,*msg,"mk_portion_of_cv_through_sf",wrapup);
	}
	if( !( sts & 1 & *msg ) ) {
	  *msg	= EMS_E_IntersectTrim ;
	  __DBGpr_com("going to wrapup");
	  goto wrapup ;
	}
	
	/*
	 * Put some topology onto trimming surface for boolean op.
	 */
	sts = vs$make_natural_boundary(	msg		= msg,
					surfaceEnv	= &trimSurf->mod_env,
					surfaceId	= &trimSurf->_grid ) ;
	__CheckRC( sts, *msg, "vs$make_natural_boundary", wrapup ) ;
	
	/*
	 * Reverse its normal for the boolean difference if need be: the
	 * surface normal must point away from the portion of extended curve.
	 */
	sts = om$send( msg	= message EMSsubbs.EMget_props( msg,
								&props ),
		       targetid = trimSurf->_objid,
		       targetos = trimSurf->_osnum ) ;
	
	__CheckRC( sts, *msg, "EMSsubbs.EMget_props", wrapup ) ;
	
	isNatNorm = props & EMSIS_NRML_REVERSED ? FALSE : TRUE ;
	
	sts = vs$mustRevOrient(	msg		= msg,
				sfGeom		= trimGeom,
				cvGeom		= extnGeom,
				isNatNorm	= isNatNorm,
				p_revOrient	= &revOrient ) ;
	__CheckRC( sts, *msg, "vs$mustRevOrient", wrapup ) ;
	if( revOrient ) {
	  sts = vs$reverse_sf_orientation(
	                 msg		= msg,
	                 ignRevFlag	= TRUE,
	                 surfaceId	= &trimSurf->_grid ) ;
	  __CheckRC( sts, *msg, "vs$reverse_sf_orientation", wrapup ) ;
	}
	
	if( perform == EXT_TRIM_prjcompsf || perform == EXT_TRIM_project ) {
	  sts = vs$extend_sl_to_sf_and_trim(	msg	= msg,
						solidEnv= solidEnv,
						solidId	= solidToExtend,
						begCapCv= &xsIdEnv,
						trimSf	= trimSurf,
						whichEnd= me->extEnd,
						cst	= cst,
						compress= TRUE,
						extSolid= solidRep ) ;
	  __CheckRC( sts, *msg, "vs$extend_sl_to_sf_and_trim", wrapup ) ;
	  
	  /*
	   * The symbology of the graphic component at the trimming
	   * location is that of the trimming surface, set it to be
	   * that of the beam.
	   */
	  VSchangeSymbology( msg, solidRep, cst->level, cst->display ) ;
	  
	  goto wrapup ;
	  
	} 
	/* Else :
	   We do not have a solid of projection: the works ...
	*/
	
	/*
	 * Construct a curve object with the portion of curve.
	 */
	extClassid =    vs$is_curve_linear(	msg		= msg,
						curveGeom	= extnGeom )
	  ? OPP_GR3dlineseg_class_id  : OPP_GRbcsubbc_class_id ;
	
	*msg = EMS_E_OMerror ;
	sts = om$construct(	classid	= extClassid,
				osnum	= tmpObj[EXTAXIS].osnum,
				p_objid	= &tmpObj[EXTAXIS].objid ) ;
	if( !( sts & 1 ) ){
	  __DBGpr_com("going to wrapup ");
	  goto wrapup ;
	}
	
	solidCst.geometry = (char *) extnGeom ;
	sts = om$send(	msg	= message GRgraphics.GRconstruct( &solidCst ),
			targetid= tmpObj[EXTAXIS].objid,
			targetos= tmpObj[EXTAXIS].osnum ) ;
	solidCst.geometry = NULL ;
	
	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;
	
	/*
	 * Generate portion (extension) of segment along the portion of
	 * extended axis.
	 */
	extIdEnv._grid	= tmpObj[EXTAXIS] ;
	extIdEnv.mod_env= *cstEnv ;
	sts = vs$make_beam_segment(	msg	= msg,
					xSection= &xsIdEnv,
					surface	= supports + 0,
					axis	= &extIdEnv,
					cst	= &solidCst,
					segment	= &cstObj[EXTBMSG] ) ;

	__CheckRC( sts, *msg, "vs$make_beam_segment", wrapup ) ;
	
	/*
	 * Now union extension with input segment.
	 */
	*msg = EMS_E_OMerror ;
	sts = om$construct(	classid = OPP_EMSslboolean_class_id,
				osnum	= cstObj[UNIONSL].osnum,
				p_objid = &cstObj[UNIONSL].objid ) ;
	__CheckRC( sts, 1, "om$construct( EMSslboolean )", wrapup ) ;
	
	sts = om$send(	msg     = message EMSsfboolean.EMboolean(
 					&rc, 
					&solidEnv->_MATRIX_TYPE,
					solidEnv->_MATRIX,
		       			solidToExtend->objid,
					1,
					&cstObj[EXTBMSG].objid,
		       			&solidCst,
					EMSbool_union,
					EMSsfbool_opt_retryDisjoint
					| EMSsfbool_opt_noredraw,
					VSmsgkey2string( VS_gI_Processing ),
					NULL,
					NULL,
					NULL,
					NULL ),
			targetid= cstObj[UNIONSL].objid,
			targetos= cstObj[UNIONSL].osnum ) ;

	*msg = VSchgEMSseverity( rc ) ;
	if( !( sts & 1 & *msg ) ) {
	  __DBGpr_com(" Going to wrapup ");
	  goto wrapup ;
	}
	
	solidToExtend->objid = NULL_OBJID ;
	
	/*
	 * Perform a selective boolean difference between copy of input
	 * trimming surface and union solid, which will remove the part of
	 * the solid which goes beyond the trimming surface.
	 */
	nbBadPts	= 0 ;
	badPts		= NULL ;
	sts = om$send(	msg	= message EMSsurface.EMtrim_a_surface(
							&rc,
							cstObj[UNIONSL].objid,
							cstEnv,
							1,
							&trimSurf->_objid,
							&trimSurf->mod_env,
							&solidCst,
							FALSE,
							NULL,
							FALSE,
							0,
							&whichSide,
							EMSbool_difference,
							FALSE,
							&nbBadPts,
							&badPts ),
			targetid= cstObj[UNIONSL].objid,
			targetos= cstObj[UNIONSL].osnum ) ;

	if( nbBadPts ) _FREE( badPts ) ;
	
	if( !( sts & 1 & rc & *msg ) ) {
	  if( *msg & 1 ) {
	    *msg = rc & 1 ? MSFAIL : rc ;
	  }
	  __DBGpr_com("going to wrapup");
	  goto wrapup ;
	}
        {
	  /*
	   * The second component of the solid union may not have graphics
	   * when there is no need for extending the original beam to meet
	   * the trimming plane; In such cases we should not have the composite
	   * surface object in the channel of the Union Solid object; The 
	   * existing of which hamphers the locate process for the VSxtrBeam
	   * Fix for TR# MP5723 - giving locate problems in downstream drawings
	   */  
	  struct GRid *Comps   = NULL, object;
	  int          cpCount = 0;
	  
	  object.objid = NULL_OBJID;
	  
	  vdchn$Get2(objID  = &cstObj[UNIONSL],
		     chnIDx = VDCHN_IDX_TO_COMPONENTS,
		     nth    = 1,
		     outID  = &object );
	  __DBGpr_obj("Object at 2nd index of UNION solid ",object);
	  if(object.objid != NULL_OBJID)
	  {
	    sts =
	      vd_$get_components(  msg             = msg,
				   grobjId         = &object,
				   grobjEnv        = cst->env_info,
				   number          = &cpCount,
				   components      = &Comps );
	    __DBGpr_int("No. of components ",cpCount);
	    if(cpCount == 0)
	      vs$bulk_delete(	count	= 1,
				grids	= &object,
				theEnv	= cst->env_info ) ;
	  }
	  _FREE( Comps );
	}
	/*
	 * The result of the selective boolean difference is in fact the
	 * owner of the target of the EMtrim_a_surface message.
	 */
	{
	  OM_S_CHANSELECT	toOwner ;
	  
	  ems$make_chanselect(	chan_label	= GRconnector_to_owners,
	 			chan_selector	= &toOwner ) ;
	  
	  sts = om$get_channel_objects(	objid		= cstObj[UNIONSL].objid,
					osnum		= cstObj[UNIONSL].osnum,
					p_chanselect	= &toOwner,
					list		= &owner,
					count		= (OMuint *) &rc,
					size		= 1 ) ;
	}
	if( !( sts & 1 ) || !rc ) {
	  *msg = EMS_E_NoSolution ; sts  = OM_W_ABORT ; 
	  __DBGpr_com("Going to wrapup");
	  goto wrapup ;
	}
	
	cstObj[SELDIFF].objid	= owner.S_objid ;
	cstObj[SELDIFF].osnum	= owner.osnum ;
	
	cstObj[UNIONSL].objid = NULL_OBJID ;
	
	sts = vs$cap_surface(	msg	= msg,
				cst	= cst,
				surface	= &cstObj[SELDIFF],
				solid	= solidRep ) ;
	__CheckRC( sts, *msg, "vs$cap_surface", wrapup ) ;
	
	/*
	 * The symbology of the graphic component at the trimming location is
	 * that of the trimming surface, set it to be that of the beam.
	 */
	VSchangeSymbology( msg, &cstObj[SELDIFF], cst->level, cst->display ) ;
	
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;
	
	wrapup :
	  
	  /*
	   * Delete extension of axis, cross-section curve.
	   */
	  vs$bulk_delete(	count	= MXTMPOB,
				grids	= tmpObj,
				theEnv	= cstEnv ) ;
	
	_FREE( axisGeom ) ; _FREE( trimGeom ) ; _FREE( extnGeom ) ;
	
	if( !( sts & 1 & *msg ) ) {
	  /*
	   * Ged rid of constructed graphics, and input solid to extend.
	   */
	  vs$bulk_delete(	count	= MXCSTOB,
				grids	= cstObj,
				theEnv	= cstEnv ) ;
	  vs$bulk_delete(	count	= 1,
				grids	= solidRep,
				theEnv	= cstEnv ) ;
	  vs$bulk_delete(	count	= 1,
				grids	= solidToExtend,
				theEnv	= solidEnv ) ;
	} else {
	  /*
	   * Unify symbology (boolean ops mixed those of operands.
	   */
	  VSchangeSymbology( msg, solidRep, cst->level, cst->display ) ;
	}
	
	return sts ;
	
} /* method VScnst_solid_rep */
/*----------------------------------------------------------------------------*/

end implementation VSxtrBeam ;
