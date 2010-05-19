/* $Id: VDCmdExSet.I,v 1.1.1.1 2001/01/04 21:08:38 cvs Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/func/VDCmdExSet.I
 *
 * Description:
 *	Associative Visualization Process command object implementation
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdExSet.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/19  13:17:28  pinnacle
# Created: vddraw/func/VDCmdExSet.I by azuurhou for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *************************************************************************/

class implementation VDCmdExDr;

#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "AS_status.h"
#include "msmacros.h"
#include "msdef.h"
#include "ASmessages.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "coparadef.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "coparamac.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "go.h"
#include "ACattrib.h"
#include "ACdb_info.h"
#include "ACcheckin.h"
#include "refdef.h"
#include "ref.h"
#include "exdef.h"
#include "exmacros.h"
#include "parametric.h"
#include "EMS.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_drwmacros.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vddrwattr.h"

#include "VDmsg.h"
#include "VDSstatus.h"

#include "v_vecmxproto.h"

/*
 * external stop request access function.
 */

extern	IGRboolean		IGEstop();

/* 
 * The no of dots that can be displayed in the status field, is not equal to 
 * the no of characters; approximately, 2 dots are equivalent to 1 alpha
 * numeric character
 */

from    NDnode      import	NDget_objects,
				NDs_compute_node;
from    ACncpx      import	ACchange_feet,
				ACconstruct_feet;
from    NDmacro     import	ACreturn_foot;
from    GRgraphics  import	GRdisplay,
				GRremwrng,
				GRaddwrng,
				GRdelete;
from    GRvg        import	GRputattr,
				GRgetattr;
from	GRowner	    import	GRget_components;
from    ACdb_info   import	ACget_db_info,
				ACset_db_info,
				ACput_serial_no,
				ACcheckin_candidate;
from    IGEgragad   import	DPinrot, DPinquire;
from    GRreffile   import	GRgetlevels, GRinquireref;
from	VDSroot     import	VDcreate;
from	VDcontext   import	VDget_osname,
				VDget_extract_info;
from	GRcontext   import	GRgetmodule_env;

extern   GRclassid   OPP_VDdrw2d_class_id;
extern   GRclassid   OPP_VDdrw3d_class_id;

/* -------------------------------------------------------------------------- */

long	VDdrw_SetVDdrwSelectMode(	msg, mdEnv, type, 
					inCount, inList )

long			*msg ;
struct	GRmd_env	*mdEnv ;
int			type ;		/* Object Process Type	*/
IGRint			inCount ;	/* Number of drawing objects. */
struct	GRid		*inList ;	/* List of drawing objects */
{
	/* 
	 * Set the select mode for the VDdrw2d and VDdrw3d objects.
	 * This will permit uses to create partial sets in the extraction
	 * process, as a result objects will be transparent for process.
	 */
	IGRint			sts = OM_S_SUCCESS,
				i, 
				modLevel[32],
				rfCount,
				processMode,
				nbRoots ;
	struct	GRid		Roots[20],
				drw2dVw,
				ctxObj,
				*rfList = NULL,
				modObj;
	GRname			echoProc ;
        struct  IGRlbsys        ctxLbs,
                                refLbs ;
	struct	GRmd_env	modEnv ;
        IGRdouble               drwPnt[3],
                                drwVec[3];
        GRname                  visualFile ,
                                drw2dView ;
        VDpartAttr              attr ;
        VDdrw2dVwInfo           vwInfo ;
        struct IGRplane         drwPlane,
                                viewPlane ;
        IGRvector               viewVector ;
        IGRpoint                viewPoint ;
        VD_drwOutputData        *output = NULL ;

	SetProc( VDdrw_ProcessVDdrw_Objects ); Begin 

	*msg = MSSUCC ;

	if( inCount == 0 )	goto wrapup ;
	
	processMode	= ( ! ex$is_batch() );

	__DBGpr_int(" inCount         ", inCount );

	UI_echo( "" );
	UI_status( "Setting Objects Select Set mode" );

	/* sts = VDdrw_LoadUnitsKeyWord(); */
        /*
         * The reference object is a parent object connect through
         * generated "make_source" of the 3d-model object and the Context.
         */
	for( i=0 ; i<inCount ; i++ ){

	    /*
	     * Ask for signal.
	     */
	    if( IGEstop()){

		/*
		 * Request to stop process.
		 * For the VDdrw2d objects : Delete the objects.
		 *	   VDdrw3d objects : Delete the objects.
		 */

		/*
		 * Get the owner object of the VDdrw2d objects
		 */
		sts = VDdrw_GetChannelOwner(	msg, inList,
						type, &drw2dVw );
		__CheckRC( sts, *msg, "VDdrw_GetChannelOwner", wrapup );

		vd_$bulk_delete(count	= 1,
				theEnv	= mdEnv,
				grids	= &drw2dVw );

		*msg = MSSUCC ;
		goto wrapup ;
	    }

	    if( processMode ){
	    	sprintf(echoProc,	"Checking %.0f%% ",
			(double)(i*100./(double)inCount));
		UI_echo( echoProc );
	    }

	    nbRoots = 0 ;

            sts =
            VDdrw_GetChannelOwner(  msg, &inList[i], VD_O_drw2d, &drw2dVw );
            __CheckRC( sts, *msg, "VDdrw_GetChannelOwner", wrapup );

       	    VDdrw_Init2dVwInfo( msg, &vwInfo );

            vwInfo.intName  = drw2dView ;
            vwInfo.prjVec   = drwVec ;
            vwInfo.prjPnt   = drwPnt ;
            vwInfo.objLev   = modLevel ;
            vwInfo.drwLbsys = &ctxLbs ;

	    /*
	     * Get the model objects for the parser.
	     */
	    sts =
	    _VD_SEND_OBJN(inList[i],
			NDnode.NDget_objects(	ND_ROOT,
                                                Roots,
                                                20,
						NULL,
                                                0,
						OM_K_MAXINT,
                                                &nbRoots ));
	    __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

	    __DBGpr_obj( "Draw Obj ", inList[i] );
	    __DBGpr_obj( "ModelObj ", Roots[1] );

	    /*
	     * Check the visualization support file.
	     */
	    attr.Iwant = VD_I_drwChkStsMask ;
	    attr.aType = VD_B_drwTransParent ;
	    sts = _VD_SEND_OBJN( inList[i],
				GRvg.GRgetattr( msg, (char *)&attr ));
	    if( !(sts&*msg&1)){     vwInfo.visFile  = visualFile ; }
	    else{                   vwInfo.trsFile  = visualFile ; }

	    attr.Iwant = VD_I_drwProjAllInfo ;
	    attr.specific = (void *) &vwInfo ;
	    sts = _VD_SEND_OBJN( drw2dVw, GRvg.GRgetattr( msg, (char *)&attr ));
	    __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );

	    VD_drw_GetCtxAndRefFromSrc( &(Roots[1]), &ctxObj,
					(struct GRid *)NULL );

	    if( vd_$is_ancestry_valid(  object  = &ctxObj,
                                        classid = OPP_VDcontext_class_id )){

              /*
               * reference object list "rfList" is a static list of
               * objects created inside the command VDget_extract_info().
               * The buffer does not to be freed inside this command.
               */
              sts =
              _VD_SEND_OBJN( ctxObj,
                        VDcontext.VDget_extract_info(   &rfList,
                                                        &rfCount, /* not used */
                                                        drwVec,
                                                        drwPnt,
                                                        modLevel,
                                                        &ctxLbs ));
              __CheckRC( sts, 1, "VDcontext.VDget_extract_info", wrapup );

              if( VDdrw_getDrawing_Lbs(   &ctxObj, mdEnv, &refLbs )){

                ctxLbs = refLbs ;
                __DBGpr_vec(" diag_pt1 ", ctxLbs.diag_pt1 );
                __DBGpr_vec(" diag_pt2 ", ctxLbs.diag_pt2 );
                __DBGpr_mat(" OriginMtx", ctxLbs.matrix );
              }
            }

	    drwPlane.point      = drwPnt ;
	    drwPlane.normal     = drwVec ;

	    viewPlane.point     = VD_mxorigin( ctxLbs.matrix, viewPoint ) ;
	    viewPlane.normal    = drwVec ;

	    VD_vccpy( viewVector, drwVec ) ;

	    /*
	     * find object in model and its macro definition
             */
            sts =
            _VD_SEND_OBJN(Roots[1],
                        NDmacro.ACreturn_foot(  msg,
                                                "",
                                                &modObj,
                                                &modEnv.md_env.matrix_type,
                                                modEnv.md_env.matrix ));
            __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );

	    modEnv._MD_OS = modObj.osnum;
	    sts = ex$get_modid( mod_osnum = modEnv._MD_OS,
                                mod_id    = &modEnv._MD_ID );
	    /*
	     * Call the parser with the parent object.
	     */
	    sts = 
	    vd_$drwExecConfig(  
			  msg             = msg,
                       	  elmId           = &Roots[1],
                          elmEnv          = mdEnv,
                          drwPlane        = &drwPlane,
                          viewPlane       = &viewPlane,
                          viewVector      = viewVector,
                          drwEnv          = mdEnv,
                          drwLbsys        = &ctxLbs,
                          selCount        = 1,
                          selList         = &modObj,
                          filename        = visualFile,
			  elm_type        = "unit-processing",
			  appData         = (void *) &inList[i],
                          output          = &output ) ;

	   VD_drwFreeOutputData( &output ) ;
	   output = NULL;

	} /* for ( .. inCount ) */

	UI_echo("");

	*msg = MSSUCC ;

wrapup:

   	VD_drwFreeOutputData( &output ) ;

	UI_status("");
	UI_echo  ("");
	End ;
	return sts ;
}

/* -------------------------------------------------------------------------- */

end implementation VDCmdExDr;
