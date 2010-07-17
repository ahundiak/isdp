/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
# Created: vsmisc/VSretngrcopy.I by svkadamb for struct
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	09/20/96	K.V.Suresh	This particular funtion retruns 
					the graphical object of a beam or a
					plate in AC_3D_rep.
 * -------------------------------------------------------------------*/
/*
	I/STRUCT
*/

class implementation Root;

#include        "OMprimitives.h"
#include 	"EMSmsgdef.h"
#include 	"acrepdef.h"
#include 	"igetypedef.h"
#include 	"igrtypedef.h"
#include 	"igrdef.h"
#include 	"igrdp.h"
#include 	"godef.h"
#include 	"nddef.h"
#include        "grdpbdef.h"
#include 	"grdpbmacros.h"
#include 	"vsbeammacros.h"
#include 	"vsattr.h"
#include 	"vsplate.h"
#include 	"vsoptdef.h"
#include 	"vsplatedef.h"
#include 	"vsmiscmacros.h"
#include 	"vsgeommacros.h"
#include        "vsdbgmacros.h"

from 	VSbeam		import 	VSgetSupportSf;
from 	VSbeam		import 	VSgetSupportAxis;
from	VSbeam		import	VSextractProfile;
from	GRgraphics	import	GRdelete;
from	GRvg		import	GRgetsymb;
from	GRvg		import	GRgetattr;
from	NDmacro		import	ACreturn_foot;

extern	OMuword		OPP_VSplate_class_id;
extern	OMuword		OPP_VSbeam_class_id;

/*----------------------------------------------------------------------------*/
/*	This function is interfaced by the macro vs$return_gr_copy()	      */
/*----------------------------------------------------------------------------*/
long VSreturn_gr_copy(	 IGRlong		*msg ,
			 struct GRmd_env	*strEnv ,
			 struct GRid		strElement,
			 struct GRid		*solidRep  )
{

	long			numberOfBytes,BytesReceived;
	IGRlong			sts ;
	struct GRmd_env		modEnv;
	struct GRvg_construct	cst;
	struct GRsymbology      mySymb ;       

	/*
 	 * Fill construction list
	 */
        sts = om$send(  msg     = message GRvg.GRgetsymb( msg, &mySymb ),
			senderid = NULL_OBJID,
                	targetid = strElement.objid ,
        	        targetos = strElement.osnum );
       	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ; 

        vs$fill_cnst_list(      Env_info        = strEnv,
                               	Display         = &mySymb.display_attr,
                       	        Level           = mySymb.level,
               	                Cnst_list       = cst ) ;

	/*
	 * Get Current Module Environment
	 */
	numberOfBytes = sizeof( struct GRmd_env );
	gr$get_module_env  (	msg     = msg,
       	        	        sizbuf  = &numberOfBytes,
               	         	buffer  = &modEnv,
       	                 	nret    = &BytesReceived );
	/*
	 * Check what type of structural Element it is.
	 */

	if( vs$is_ancestry_valid( 	object  = &strElement,
					classid = OPP_VSplate_class_id ) ) 
	{
	        VSpartAttr              myAttr ;
        	VSplateAttr             myInfo ;
		struct GRid     	botSurf ;
		struct GRobj_env	surf ;
		
		surf._objid = NULL_OBJID;

		/*
	         * Get attributes.
        	 */
	        myAttr.Iwant    = VS_m_Thickness | VS_m_Orientation
        	                | VS_m_CutOff    | VS_m_Offset ;
	        myAttr.specific = (void *) &myInfo ;
        	sts = om$send(  msg     = message GRvg.GRgetattr( msg, 
							(char *) &myAttr),
			senderid = NULL_OBJID,
                	targetid = strElement.objid ,
        	        targetos = strElement.osnum );                	
		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

		sts = om$send(  msg  = message NDmacro.ACreturn_foot(
                                                        msg,
                                                        VS_K_plBotSfPath,
                                                        &botSurf,
                                                        NULL, NULL ),
				senderid = NULL_OBJID,
	        	        targetid = strElement.objid ,
		                targetos = strElement.osnum );
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;


		sts = vs$grCopy(        msg     = msg,
                                        frEnv   = strEnv,
                                        frObj   = &botSurf,
                                        toEnv   = &modEnv,
                                        toObj   = &surf._grid) ;
                __CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;
		
		surf.mod_env = modEnv;

		sts = vs$offset_surface_to_solid(
                                        msg             = msg,
                                        surfId          = &surf._grid,
                                        surfEnv         = &surf.mod_env,
                                        offset          = myInfo.thickness,
                                        isNatNorm       = TRUE,
                                        cst             = &cst,
                                        isPlanar        = DONT_KNOW,
                                        offSolId        = solidRep ) ;
                __CheckRC( sts, *msg, "vs$offset_surface_to_solid", wrapup ) ;
		
		if ( surf._objid != NULL_OBJID ) {
			sts = om$send ( msg = message GRgraphics.GRdelete (
								msg,
								&modEnv ),
				senderid = NULL_OBJID,
				targetid = surf._objid,
				targetos = surf._osnum );
        	}

	} else {
		struct GRid		xsId;
		struct GRobj_env 	surface, axis, prflIdEnv;
	

		xsId.objid = NULL_OBJID;
		/*
		 * Get the support Surface
		 */
		sts = om$send ( msg = 	message VSbeam.VSgetSupportSf(
								msg,
								strEnv,
								&surface ),
				senderid = NULL_OBJID,
	        	        targetid = strElement.objid ,
		                targetos = strElement.osnum );
	
	        __CheckRC( sts, *msg, "VSsrcBeam.VSgetSupportSf", wrapup ) ; 
		/*
		 * Get the Beam Axis
		 */
		sts = om$send ( msg =  message VSbeam.VSgetSupportAxis(
								msg,
                                                                strEnv,
                                                                &axis ),
				senderid = NULL_OBJID,
	        	        targetid = strElement.objid ,
		                targetos = strElement.osnum );
	
        	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ; 

		/*
		 * Extract the profile of the beam in Fillet representation
		 */
		sts = om$send ( msg = 	message VSbeam.VSextractProfile( 	
								msg,
                                				&modEnv,
                                				&surface,
                                        	            	&axis,
                                				0.0,
								&cst,
								AC_3D_REP,
        	                        			&xsId ),
				senderid = NULL_OBJID,
	                	targetid = strElement.objid ,
	        	        targetos = strElement.osnum );
		__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ; 
	
		/*
		 * Construct solid representation of beam with the extracted 
		 * cross section
		 */
		prflIdEnv._grid = xsId;
		prflIdEnv.mod_env = *cst.env_info;
	
		sts = vs$make_beam_segment(	msg     = msg,
						xSection= &prflIdEnv,
						surface = &surface,
						axis    = &axis,
						cst     = &cst,
						segment = solidRep ) ;
	        __CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ; 

		if ( xsId.objid != NULL_OBJID ) {
			sts = om$send ( msg = message GRgraphics.GRdelete (
								msg,
								&modEnv ),
					senderid = NULL_OBJID,
					targetid = xsId.objid,
					targetos = xsId.osnum );
		}
	}

wrapup :
	if( !(sts & *msg & 1 )) {
		if ( solidRep->objid != NULL_OBJID ) {
			sts = om$send ( msg = message GRgraphics.GRdelete (
								msg,
								&modEnv ),
				senderid = NULL_OBJID,
				targetid = solidRep->objid,
				targetos = solidRep->osnum );
        	}
	}

	return (sts & *msg & 1);
} /* VSreturn_gr_copy */
/*----------------------------------------------------------------------------*/

end implementation Root;
