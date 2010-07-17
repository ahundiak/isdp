/* $Id: VSbacnstfeet.I,v 1.5 2001/04/27 13:25:12 ramarao Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmaxis/VSbacnstfeet.I
 *
 * Description:
 *		Construct routine for the beam axis object.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbacnstfeet.I,v $
 *	Revision 1.5  2001/04/27 13:25:12  ramarao
 *	Fixed TR# 5117.
 *	
 *	Revision 1.4  2001/02/20 01:18:42  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.3  2001/02/14 20:51:55  ramarao
 *	Modification related to __DBGpr_com() macro.
 *	
 *	Revision 1.2  2001/01/17 00:12:53  ramarao
 *	*** empty log message ***
 *	
# Revision 1.2  2000/12/06  16:23:36  pinnacle
# Replaced: struct/vsbmaxis/VSbacnstfeet.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/07/18  21:56:54  pinnacle
# Created: struct/vsbmaxis/VSbacnstfeet.I by rchennup for Service Pack
#
# Revision 1.2  1998/08/13  14:44:30  pinnacle
# tr179801437
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/03/23  15:06:36  pinnacle
# TR179800631
#
# Revision 1.3  1998/02/20  18:24:18  pinnacle
# CR179800676
#
# Revision 1.2  1998/01/22  14:21:26  pinnacle
# Replaced: vsbmaxis/VSbacnstfeet.I for:  by azuurhou for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 *	     i-struct  creation date
 * 01/22/98  adz       Data reduction to final curve.
 * 02/20/98  ah        CR179800676 - Allow axis to extend past edge of plate
 * 02/20/98  ah        CR179800677 - Option to force paramertization to follow
 *                                   parent support curve vice surface
 * 03/23/98  Manoj     TR179800631 - Twisted stiffener  is not working
 * 08/12/98  ah        TR179801437 - Failing on some cases due to 
 *				     extended geomotry
 * 07/18/00  Jayadev   No TR       - Extension outside plate limits handled
 ***************************************************************************/

class implementation VSbeamAxis ;

#include <stdio.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "vssplitdef.h"
#include "vsbmaxisdef.h"
#include "vsplatedef.h"
#include "vsiomacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
/*
#define vdsDEBUG        1
#define vdserrDEBUG     1

#include "vsdbgmacros.h"

#define DEBUG 1
*/
/*
 * Includes of function prototypes.
 */
#include "vsgetchildrn.h"
#include "vsvirtualinf.h"

extern long	VSfindBmAxisExtToEnterSurfaces() ;
extern long	VDSapplyDataReduction();
extern long	VSfitCurve() ;

extern OMuword OPP_GRcurve_class_id ;
extern OMuword OPP_VSstfBeam_class_id ;

from EMSsubbs   import EMproject_curve_along_surface_normals ;

/* The following function was written for beam axis extension outside plate */
/* Function to extend the underlying plate surface for the beam axis */

IGRlong VSgetAxisExtn(struct GRobj_env *surfOE, struct GRobj_env *axisOE, IGRdouble *extension)
{
    IGRlong retFlag = 0,msg;
    IGRint		    sts,ii;
    struct IGRbsp_curve     *axisGeom = NULL;
    struct IGRbsp_surface   *srfGeom  = NULL;
    IGRdouble               bastol= 0.0, chtol= 0.0;
    IGRdouble		    dist1 = 0.0, dist2 = 0.0;
    IGRdouble 		    ptSurf[3],start_pt[3], end_pt[3]; 
    IGRdouble               u,v;
    BSrc		    rc;

    BSxtractpar( &rc, BSTOLBASIS, &bastol );
    BSxtractpar( &rc, BSTOLCHRDHT, &chtol );

    // get the surface geometry
                sts = vs$get_geometry( msg      = &msg,
                                       grobjId  = &surfOE->obj_id,
                                       grobjEnv = &surfOE->mod_env,
                                       geometry = &srfGeom ) ;
                __CheckRC( sts, msg, "vs$get_geometry", wrapup ) ;
    	// get the axis geometry
                sts = vs$get_geometry( msg      = &msg,
                                       grobjId  = &axisOE->obj_id,
                                       grobjEnv = &axisOE->mod_env,
                                       geometry = &axisGeom ) ;
                __CheckRC( sts, msg, "vs$get_geometry", wrapup ) ;

        BScveval( axisGeom, 0.0, 0, start_pt, &rc );
        if (rc != BSSUCC) goto wrapup ;
	__DBGpr_vec("Axis start point",start_pt);

        BScveval( axisGeom, 1.0, 0, end_pt, &rc );
        if (rc != BSSUCC) goto wrapup ;
	__DBGpr_vec("Axis end point",end_pt);


	// evaluate plate surface distances from the axis end points
        BSmdistptsf(&rc, srfGeom,start_pt, &u,&v,ptSurf,&dist1);
    	if ( BSSUCC != rc ) {
		__DBGpr_com("BSmdistptsf failed ");
       		goto wrapup ;
    	}
	__DBGpr_dbl("dist1",dist1);
        BSmdistptsf(&rc, srfGeom,end_pt, &u,&v,ptSurf,&dist2);
    	if ( BSSUCC != rc ) {
		__DBGpr_com("BSmdistptsf failed ");
       		goto wrapup ;
    	}
	__DBGpr_dbl("dist2",dist2);


	if((dist1 < chtol) && (dist2 < chtol)){
		__DBGpr_com("No extension of plate surface required ");
		 goto wrapup;
	}
	else{
		__DBGpr_com("Extension of plate surface required ");
		if(dist1>dist2) *extension =  1.1*(dist1);
		else *extension =  1.1*(dist2);

		//*extension =  1.1*(dist1+dist2);
		__DBGpr_dbl("Extension ",*extension);
	}
    	// Done
    	retFlag = 1;
wrapup:
	_FREE(axisGeom);
	_FREE(srfGeom);
    return retFlag;
}
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					count ;
			struct GRid	list[] ;
			struct GRmd_env *MyEnv ;
			int		*feetCount ;
			struct GRid	*feetList ) {

	long			sts ;		/* OM return code.	    */
	struct GRvg_construct	cst ;		/* My construction list.    */
	struct GRobj_env	templates[4],	/* 0: plate,		    */
						/* 1: curve or surface,     */
						/* 2: start surface limit   */
						/*    or end surface limit  */
						/*    if no start surface.  */
						/* 3: end surface limit.    */
				SideObj,	/* Side to place axis.	    */
				myStif ;	/* My children stiffener.   */
	struct GRid		myGrid, 	/* My grid.		    */
				*myChild = NULL,/* My childrens.	    */
				fitCurve ;	/* Output curve fit.	    */
	struct GRsymbology	mySymb ;	/* My symbology.	    */
	int			curve,		/* FALSE = Parent #1 is a   */
						/* surface, TRUE is a curve.*/
				ii,		/* Loop index 		    */
				haveOffset,	/* TRUE/FALSE.		    */
				cntChild,	/* Count of my childrens.   */
				doFit ; 	/* TRUE/FALSE.		    */
	char			*sidename ;	/* Name of side of plate.   */
	double			offset[2] ;	/* Offset distances.	    */
	struct IGRbsp_surface	*sdGeom ;	/* Geometry of side.	    */
 	struct GRid 		beamAxis;
	IGRint flag,flags[2];
	IGRchar			debugfile[50];
	struct GRobj_env	dbgOE,resOE,res1OE, goOE;
        struct GRlc_info        curve_info,
                                side_info ;
        OM_S_OBJID              *proj_obj = NULL ;
        long                    nb_proj = 0 ;
 	int 			stat    =   OM_E_INVARG;
	IGRdouble		extend = 0.0;
	IGRboolean		is_planar = TRUE;
	
	if( !count ) { *msg = MSINARG ; return OM_W_ABORT ; }

	feetList[0].objid = NULL_OBJID ;
	resOE.obj_id.objid= NULL_OBJID ;

	myGrid.objid = my_id ; myGrid.osnum = OM_Gw_current_OS ;
	haveOffset = FALSE ;
	sdGeom	   = NULL ;

	vs$dotsInStsFld( dots = 0 ) ;

	/*
	 * NOTE: the AC system has initialized all the "feetList[k].objid"
	 * to NULL_OBJID.
	 */

	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Env_info	= MyEnv,
				Display 	= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	/*
	 * Get graphics parents after plate.
	 */
	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
					msg, count-1, list+1, templates+1 ),
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	/*
	 * Parent plate may in fact be a pretend or an image of a plate.
	 * In any case get tranformation matrix and virtual id if applicable.
	 */
	sts = VSgetVirtualInfo( msg,
				list + 0,
				&templates[0].mod_env,
				&templates[0]._grid ) ;
	__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

	vs$dotsInStsFld() ;

        VSget_actual_go( &templates[1].obj_id, &templates[1].mod_env,
                         &goOE.obj_id, &goOE.mod_env );

	if( vs$is_ancestry_valid( object  = &goOE.obj_id,
				  classid = OPP_GRcurve_class_id ) )
						curve = TRUE ;
	else curve = FALSE ;

	/*
	 * Retrieve side of plate, support of this axis.
	 *
	 * CR179800676 This used to read like this
	 * if( (me->flagAttr & ~VS_K_baExtendAxis) == VS_K_baOnTopOfPlate )
         * I don't understand why.  
         * It will fail with the new bits being used so I replaced
         * it with this method which simply tests the rightmost bit.
	 *
	 * Actually, they already have a method defined for getting
	 * the desired surface.  Don't know why they did use it.
	 */
	sts = om$send(msg = message VSbeamAxis.VSgetPlateSide(msg,&flag),
		      targetid = my_id);
	__CheckRC( sts, *msg, "VSbeamAxis.VSgetPlateSide", wrapup ) ;
	

	if(flag == VS_K_baOnTopOfPlate ) sidename = VS_K_plTopSfPathABS ;
	else	                         sidename = VS_K_plBotSfPathABS ;

	sts = om$send( msg = message NDmacro.ACreturn_foot(
						msg,
						sidename,
						&SideObj.obj_id,
						&templates[0]._matrix_type,
						templates[0]._matrix ),
		       targetid = list[0].objid,
		       targetos = list[0].osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	SideObj.mod_env = templates[0].mod_env ;

	/*
	 * Construct axis.
	 */
	if( curve ) {
		/*
		 * Parent #1 is a curve, construct axis projected onto side.
		 */
		__DBGpr_com("Construction axis is curve ");
		sts = om$send(
			msg = message VSbeamAxis.VScnst_axis_project_onto_side(
					      msg,
					      templates +1,
					      &SideObj,
					      count == 4 ? templates +2 : NULL,
					      count == 4 ? templates +3 : NULL,
					      &cst,
					      feetList ),
			targetid = my_id ) ;
		__CheckRC( sts, *msg, "VSbeamAxis.VScnst_axis_project_onto_side",
			   wrapup ) ;
	#ifdef DEBUG
		dbgOE.obj_id = feetList[0];
		dbgOE.mod_env = *MyEnv; 
		strcpy(debugfile,"axis1.txt");
		sts = VDdumpCurve(&dbgOE,NULL,debugfile);
	#endif
	} else {
		/*
		 * Parent #1 is a surface, construct axis which is the
		 * intersection between this surface and plate side.
		 */
		__DBGpr_com("Construction axis is surface ");
		sts = om$send(
			msg = message VSbeamAxis.VScnst_axis_int_surf_and_side(
					      msg,
					      templates +1,
					      &SideObj,
					      count == 4 ? templates +2 : NULL,
					      count == 4 ? templates +3 : NULL,
					      &cst,
					      feetList ),
			targetid = my_id ) ;
		__CheckRC( sts, *msg, "VSbeamAxis.VScnst_axis_int_surf_and_side",
			   wrapup ) ;
	#ifdef DEBUG
		dbgOE.obj_id = feetList[0];
		dbgOE.mod_env = *MyEnv; 
		strcpy(debugfile,"axis1.txt");
		sts = VDdumpCurve(&dbgOE,NULL,debugfile);
	#endif
	}

	/*
	 * Split axis constructed if start and end surfaces are given using
	 * for orientation those surfaces. Otherwise, set orientation of
	 * axis constructed with respect to U or V direction of side support.
	 */
	if( count == 4 ) {

		struct GRobj_env  AxisObj ;

		AxisObj.obj_id	= feetList[0] ;
		AxisObj.mod_env = *MyEnv ;

		/*
		 * If stiffener attached to me should be extended, compute
		 * offset distance to extend axis.
		 *
		 * CR179800676 This used to use me->flagAttr directly
		 */
		sts = om$send(msg = message VSbeamAxis.VSgetExtendFlag(msg,&flag),
		      targetid = my_id);
		__CheckRC( sts, *msg, "VSbeamAxis.VSgetExtendFlag", wrapup ) ;

		if( !(purpose & VS_K_InitialPlacement) && flag) {
		  
			/*
			 * Retrieve child stiffener.
			 */
			__DBGpr_com("Recompute case ");
			sts = VSgetChildrenGoThruPretends( msg,
							   &myGrid,
							   &cntChild,
							   &myChild ) ;
			__CheckRC( sts, *msg, "VSgetChildrenGoThruPretends",
				   wrapup ) ;

			if( !cntChild ) vs$error() ;

			/*
			 * Check for the class of the children and validate
			 * it so that we are sending the stiffener object 
			 * for further  computations.
			 * The order of children is different in case of 
			 * twisted stiffener Ref: 179800631. Manoj
			 */
			for( ii = 0; ii < cntChild ; ii++ ) {
			     if( vs$is_ancestry_valid( object  = &myChild[ii],
						       classid = OPP_VSstfBeam_class_id ) ) {
					myStif.obj_id  = myChild[ii] ;
					myStif.mod_env = *MyEnv ;
					break ;
				}
			}

			_FREE( myChild ) ;

			/*
			 * Compute offset distance.
			 */
			sts = VSfindBmAxisExtToEnterSurfaces( msg,
							      &myStif,
							      &AxisObj,
							      templates +2,
							      templates +3,
							      offset,
							      offset +1 ) ;
			__CheckRC( sts, *msg, "VSfindBmAxisExtToEnterSurfaces",
				   wrapup ) ;

			__DBGpr_dbl("offset1",offset[0]);
			__DBGpr_dbl("offset2",offset[1]);

			if( offset[0] != 0. || offset[1] != 0. )
				haveOffset = TRUE ;
			else
				haveOffset = FALSE ;

			__DBGpr_int("haveOffset",haveOffset);
		}

		/*
		 * NOTES:
		 * ======
		 *
		 * - Since the input curve is in the current OS (it was
		 *   constructed in it above) and we want to use the results in
		 *   the very same OS, we do not have to copy the input curve
		 *   first.
		 *
		 * - Orientation of axis is set from 'start' to 'end' surfaces
		 *   limits.
		 */

		/* CR179800676 Retrieve the bits indicating if either or both ends
		 * should be extended to the limit surfaces if they do not already
		 * intersect them.
		 */
		sts = om$send(msg = message VSbeamAxis.VSgetExtend(msg,&flags[0],&flags[1]),
			      targetid = my_id);
		__CheckRC( sts, *msg, "VSbeamAxis.VSgetExtend", wrapup ) ;
		__DBGpr_int("Extend flag1",flags[0]);
		__DBGpr_int("Extend flag2",flags[1]);
		sts = vs$delimit_curve_by_two_surfaces(
						msg	   = msg,
						curve	   = &AxisObj,
						surf	   = templates +2,
						surfFlags  = flags,  // CR179800676 Added Arg
						option	   =
							VS_K_CONSASANINFPLANE |
							VS_K_SETCURVORIENT,
						offset	   = haveOffset ?
							     offset : NULL ,
						resultSymb = &mySymb,
						result	   = feetList ) ;
		__CheckRC( sts, *msg, "delimit_curve_by_two_surfaces", wrapup );

		dbgOE.obj_id = feetList[0];
		dbgOE.mod_env = AxisObj.mod_env; 
	#ifdef DEBUG
		strcpy(debugfile,"axis2.txt");
		sts = VDdumpCurve(&dbgOE,NULL,debugfile);
	#endif

           is_planar = vs$is_surface_planar( msg = msg,
                                     surfId  = &SideObj.obj_id,
                                     surfEnv = &SideObj.mod_env ) ;

	if(!is_planar) { __DBGpr_com("Plate surface is non planar"); }
	else	       { __DBGpr_com("Plate surface is  planar");    }

	// check if the axis is extended outside the plate surface

	if(((flags[0]&1) || (flags[1]&1)) && (!is_planar)){
		sts = VSgetAxisExtn(&SideObj,&dbgOE,&extend);
		if((!(sts&1)) || (extend == 0.0))
		{
			__DBGpr_com("Axis is within the plate surface limits ");
		 	goto oldProcess;
		}
	}
	else{
			__DBGpr_com("No Extension of the plate surface ");
			goto oldProcess;
	}

	// begin of the surface extension and axis projection
	if( curve ) 	/* TR# 5117 - RR 04/26/01 */
	{
		sts = VSextendOffsetSurface(&SideObj,extend,0.0,cst.env_info,&resOE.obj_id);
		if((!(sts&1)) || (resOE.obj_id.objid == NULL_OBJID)){
			 printf("\n VSextendOffsetSurface failed \n");
			 goto oldProcess;
		}
		else{
			__DBGpr_dbl(" extension applied", extend);
			__DBGpr_obj(" resID",resOE.obj_id);
		#ifdef DEBUG
			strcpy(debugfile,"resSurf.txt");
			res1OE.obj_id =   resOE.obj_id ;
			res1OE.mod_env=   *cst.env_info; 
			sts = VDdumpSurface(&res1OE,NULL,debugfile);
		#endif
		}

        	curve_info.located_obj  = feetList[0] ;
        	curve_info.module_info  = AxisObj.mod_env ;
        	side_info.located_obj   = resOE.obj_id ;
        	side_info.module_info   = *cst.env_info ;

		__DBGpr_obj("curve_info.located_obj",feetList[0]);
		__DBGpr_obj("side_info.located_obj",resOE.obj_id);

        	sts = om$send(
               	msg = message EMSsubbs.EMproject_curve_along_surface_normals(
                                                        &curve_info,
                                                        &side_info,
                                                        &cst,
                                                        TRUE,
                                                        TRUE,
                                                        &nb_proj,
                                                        &proj_obj,
                                                        msg ),
                        targetid = resOE.obj_id.objid,
                        targetos = resOE.obj_id.osnum ) ;

	if((sts&*msg&1)&&(nb_proj>0)){
		#ifdef DEBUG
		printf("\n successful projection of axis on plate surface \n");
		#endif

 		feetList[0].objid = proj_obj[0];

		__DBGpr_obj("feetList",feetList[0]);
		__DBGpr_int("nb_proj",nb_proj);
	
		#ifdef DEBUG
		strcpy(debugfile,"axiscurve2.txt");
		res1OE.obj_id.objid = feetList[0].objid;
		res1OE.obj_id.osnum = feetList[0].osnum;
		res1OE.mod_env = AxisObj.mod_env;

		sts = VDdumpCurve(&res1OE,NULL,debugfile);
		if(!(sts&1)) printf("\n failed to dump the curve \n");
		#endif
	} else {
		#ifdef DEBUG
			printf("\n axis projection failed \n");
		#endif
		goto oldProcess;
	  }
	} // end of the surface extension and axis projection
	} else {
		/*
		 * Set orientation of axis with respect to U or V direction
		 * of side support.
		 */
	  
		/* CR179800677 If this bit is set then don't do this
		 */
		sts = om$send(msg = message VSbeamAxis.VSgetByCurve(msg,&flag),
			      targetid = my_id);
		__CheckRC( sts, *msg, "VSbeamAxis.VSgetByCurve", wrapup ) ;

		if (flag == 0) {
		  
		  sts = vs$set_cv_orient_along_UVsf( msg	 = msg,
						     cvId  = feetList,
						     cvEnv = MyEnv,
						     sfId  = &SideObj._grid,
						     sfEnv = &SideObj.mod_env ) ;
		
		  __CheckRC( sts, *msg, "vs$set_cv_orient_along_UVsf", wrapup ) ;
		}
		
	}
	oldProcess: // continue as per the old implementation

	/*
	 * Reduce & fit curve if it is eligible for it ( if not eligible
	 * `VSfitCurve' returns *msg = EMS_I_InvalidCase ) and if side of plate
	 * is planar on u or v direction.
	 */
	sts = vs$get_geometry( msg	= msg,
			       grobjId	= &SideObj._grid,
			       grobjEnv = &SideObj.mod_env,
			       geometry = &sdGeom ) ;

	__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	doFit = sdGeom->u_order != 2 || sdGeom->v_order != 2 ;

	if( doFit ) {

		sts = VSfitCurve( msg,
				  &feetList[0],
				  cst.env_info,
				  &cst,
				  &fitCurve ) ;

		if( (sts & 1 & *msg) && (*msg != EMS_I_InvalidCase) ) {

			vs$bulk_delete( grids	= &feetList[0],
					theEnv	= cst.env_info ) ;

			feetList[0] = fitCurve ;
#ifdef DEBUG
dbgOE.obj_id = feetList[0];
dbgOE.mod_env = *MyEnv; 
strcpy(debugfile,"axis3.txt");
sts = VDdumpCurve(&dbgOE,NULL,debugfile);
#endif

		} /* Else "VSfitCurve" failed: keeping old axis anyway. */
	}

	*feetCount = 1 ;

	/* -------------------------------------------------
	 * TR179801437 Ignore errors because get something
	 * even if it fails
	 */
	if( feetList[0].objid != NULL_OBJID ){
		struct GRlc_info	sfInfo ;
		IGRlong msg1;
		
		sfInfo.located_obj	= SideObj.obj_id ;
		sfInfo.module_info	= SideObj.mod_env ;

		VDSapplyDataReduction(	&msg1,
					&sfInfo, &sfInfo,
					&cst,
					*feetCount, feetList );
	}

	/*
	 * Update object tag, don't check return code: will be
	 * OM_W_NOTTAGGED if object has no tag connection.
	 */
	om$change_tag_version() ;

	wrapup :
		vs$dotsInStsFld( dots = clear ) ;

		if( !( sts & 1 & *msg ) ) {

			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
				sts = OM_S_SUCCESS ;
			}
		}
		// delete the unwanted projection objects
	        for(ii=1;ii<nb_proj;ii++)
		{
                  stat= om$send(msg  = message GRgraphics.GRdelete( msg,
                                                         cst.env_info ),
                        targetid =   proj_obj[ii],
                        targetos =   cst.env_info->md_id.osnum  );
                        
                }	
		// delete the extended plate surface

		if(resOE.obj_id.objid != NULL_OBJID)
		{
                  stat= om$send(msg  = message GRgraphics.GRdelete( msg,
                                                         cst.env_info ),
                        targetid =   resOE.obj_id.objid,
                        targetos =   resOE.obj_id.osnum  );
                }

		_FREE( sdGeom ) ;
		_FREE( proj_obj ) ;

	return sts ;

} /* method ACconstruct_feet */

/*----------------------------------------------------------------------------*/
end implementation VSbeamAxis ;
