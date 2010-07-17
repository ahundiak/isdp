/* $Id: VSstcnstfeet.I,v 1.5 2001/02/20 01:18:40 build Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbeam/VSstcnstfeet.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VSstcnstfeet.I,v $
 * Revision 1.5  2001/02/20 01:18:40  build
 * Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 * Revision 1.4  2001/02/14 20:46:30  ramarao
 * Modification related to __DBGpr_obj() macro.
 *
 * Revision 1.3  2001/02/14 20:45:04  ramarao
 * Modification related to __DBGpr_obj() macro.
 *
 * Revision 1.2  2001/01/17 00:13:44  ramarao
 * *** empty log message ***
 *
# Revision 1.1  2000/07/18  21:56:20  pinnacle
# Created: struct/vsbeam/VSstcnstfeet.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/04/24  21:20:54  pinnacle
# ah Piece Marks
#
# Revision 1.2  1998/04/24  20:43:48  pinnacle
# ah Piece Marks
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/24/98  ah      Add hook to VDbtAfterConstructFeet
 * 07/18/00  Jayadev Stiffeners extending out of the plate limits - extend
 *		     underlying plate surface; related stuff handled inside
 *		     the beam axis construction
 ***************************************************************************/

class implementation VSstfBeam ;

#include "EMSmsgdef.h"
#include "VDobj.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsiomacros.h"
#include "vsdbgmacros.h"
/*
#define vdsDEBUG        1
#define vdserrDEBUG     1

#include "vsdbgmacros.h"

#define DEBUG 1
*/
extern IGRlong VSgetAxisExtn();

from EMSsubbs   import EMproject_curve_along_surface_normals ;
from VSbeamAxis import VSgetExtend;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*MyEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	struct GRvg_construct 	cst ;		/* My construction list	*/
	struct GRobj_env	supports[2] ;	/* 0: surface, 1: curve	*/
	struct GRid		xsId,axisId ;	/* Id of cross-section	*/
	VSdspRep		myRep ;		/* My representation	*/
	struct GRsymbology	mySymb ;	/* My symbology		*/
        struct GRobj_env        resOE,myOE;
        IGRchar                 debugfile[50];
	IGRdouble               extend = 0.0;
	int                     stat  =  OM_E_INVARG,flags[2];
	IGRboolean		is_planar = TRUE;

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	resOE.obj_id.objid = NULL_OBJID;
	axisId.objid 	   = NULL_OBJID;
	flags[0] = flags[1] = FALSE;

	vs$dotsInStsFld( dots = 0 ) ;

	/*
	 * NOTE: the AC system has initialized all the "listOfOutputs[k].objid"
	 * to NULL_OBJID.
	 */
        xsId.objid = NULL_OBJID;

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
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	/*
	 * Get support plate and axis, disregard parent collection.
	 * The following message will return the graphics of the parent plate
	 * (parent #0), which we do not care about (we need a side of the plate),
	 * Hence the second message send right afterwards.
	 */
	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
					msg, 2, listOfInputs, supports ),
			targetid = my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	sts = om$send(	msg	= message VSstfBeam.VSgetPlateSurface(
				msg, MyEnv, listOfInputs + 0, supports + 0 ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSstfBeam.VSgetPlateSurface", wrapup ) ;

	vs$dotsInStsFld() ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;

	/*
	 * Rep needs to be fixed if an expanded macro graph is being computed.
	 */
	sts = vs$fixIfNoRep( inRep = myRep, outRep = &myRep ) ;

        sts = om$send(	msg	= message VSbeam.VSextractProfile(
					msg, MyEnv, supports + 0,
					supports + 1, 0.0, &cst, myRep, &xsId ),
                        targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;

	switch( myRep ) {

	case AC_2D_REP		:
                sts = om$send( msg	= message VSsrcBeam.VScnst_line_rep(
                					msg,
                					MyEnv,
							supports,
							&cst,
							&xsId,
							listOfOutputs + 0 ),
                                targetid = my_id ) ;
		__CheckRC( sts, *msg, "VSsrcBeam.VScnst_line_rep", wrapup ) ;
                break ;

	case VS_m_3dWFillet	:
	case VS_m_2dSurface	:
	case AC_3D_REP		:
	case AC_ENV_REP		:
           is_planar = vs$is_surface_planar( msg = msg,
                                     surfId  = &supports[0].obj_id,
                                     surfEnv = &supports[0].mod_env ) ;

        	if(!is_planar) { __DBGpr_com("Plate surface is non planar"); }
        	else           { __DBGpr_com("Plate surface is  planar");    }

		__DBGpr_obj(" supports[0]",supports[0].obj_id);
		__DBGpr_obj(" supports[1]",supports[1].obj_id);

		myOE.obj_id.objid  = my_id;
		myOE.obj_id.osnum  = OM_Gw_current_OS;
		myOE.mod_env	   = *MyEnv;

		__DBGpr_obj("My Id ",myOE.obj_id);
 
  		vdobj$GetParent(objOE = &myOE, idx = 1, parentID = &axisId);
  		if (axisId.objid == NULL_OBJID) {
    			__DBGpr_com("Can't find stiffener axis");
    			goto wrapup;
  		} 
		__DBGpr_obj("beam axis Id ",axisId);

                sts = om$send(msg = message VSbeamAxis.VSgetExtend(msg,
							&flags[0],&flags[1]),
					senderid = NULL_OBJID,
                        		targetid = axisId.objid,
					targetos = axisId.osnum);
                __CheckRC( sts, *msg, "VSbeamAxis.VSgetExtend", wrapup ) ;

		// extend the underlying plate surface for curved plates

		__DBGpr_int("flags[0]", flags[0]);
		__DBGpr_int("flags[1]", flags[1]);
		__DBGpr_int("is_planar", is_planar);

		if(((flags[0]&1) || (flags[1]&1)) && (!is_planar)){
			sts = VSgetAxisExtn(&supports[0],&supports[1],&extend);
		}
		else extend = 0.0;

        	if((!(sts&1)) || (extend == 0.0))
        	{
               	 	__DBGpr_com("Axis is within the plate surface limits ");
        	}
		else
		{
			sts = VSextendOffsetSurface(&supports[0],extend,0.0,
				            	cst.env_info,&resOE.obj_id);
			if(!(sts&1)) 
			{ __DBGpr_com(" Surface extension failed "); }
			else{
				__DBGpr_dbl("extension",extend);
        			supports[0].obj_id.objid = resOE.obj_id.objid;
        			supports[0].obj_id.osnum = resOE.obj_id.osnum;
				supports[0].mod_env      = *cst.env_info;
                #ifdef DEBUG
                        strcpy(debugfile,"resSurf1.txt");
                        resOE.mod_env=   *cst.env_info;
                        sts = VDdumpSurface(&resOE,NULL,debugfile);
                #endif
			}
		}

                sts = om$send( msg	= message VSsrcBeam.VScnst_solid_rep(
                					msg,
                					MyEnv,
                					&cst,
                					&supports[0],
							&supports[1],
							&xsId,
							listOfOutputs + 0 ),
				targetid= my_id ) ;

		if( !( sts & 1 & *msg ) ) {
			__DBGpr_com("VSsrcBeam.VScnst_solid_rep failed");
			goto wrapup ;
		}
                break ;

           default :
           	/* Bad representation */
           	*msg = MSINARG ; sts	= OM_W_ABORT ; goto wrapup ;
	}

	*countOfOutputs = 1 ;

	/* -------------------------------------------------
	 * 24 Apr 1998 Hook into post processor for
	 * production purposes
	 */
	{
	  struct GRobj_env myOE;

	  myOE.obj_id.objid = my_id;
	  myOE.obj_id.osnum = OM_Gw_current_OS;
	  myOE.mod_env      = *MyEnv;
	  
	  VDbtAfterConstructFeet(&myOE,purpose);
	}

	wrapup :
		/*
		 * Except in linear case (pure AC_2D_REP), where the section
		 * is part of feet, the section curve has to be deleted.
		 */
		if( myRep != AC_2D_REP ) {
			vs$bulk_delete(	count	= 1,
					grids	= &xsId,
					theEnv	= MyEnv ) ;
		}
                // delete the extended plate surface

                if(resOE.obj_id.objid != NULL_OBJID)
                {
                  stat= om$send(msg  = message GRgraphics.GRdelete( msg,
                                                         cst.env_info ),
                        targetid =   resOE.obj_id.objid,
                        targetos =   resOE.obj_id.osnum  );
                }

		if( sts & 1 & *msg ) {
			/*
			 * Update beam tag, don't check return code: will be
			 * OM_W_NOTTAGGED if object has no tag connection.
			 */
			om$change_tag_version() ;
		} else {
			/*
			 * Delete feet.
			 */
			vs$bulk_delete(	count	= *countOfOutputs,
					grids	= listOfOutputs,
					theEnv	= MyEnv ) ;
			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    			sts = OM_S_SUCCESS ;
			}
		}

		vs$dotsInStsFld( dots = clear ) ;
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;
