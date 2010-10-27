/* $Id: VDdrwexeccfg.I,v 1.5 2001/09/04 14:24:02 ramarao Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwexeccfg.I
 *
 * Description:
 *	Main driver of the Drawing Extraction Language Interpreter: set up
 *	a few things then kick off parsing.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwexeccfg.I,v $
 *	Revision 1.5  2001/09/04 14:24:02  ramarao
 *	Fixed TR# 5534.
 *	
 *	Revision 1.4  2001/03/08 22:50:10  ramarao
 *	Added "declivity" Keyword in VISUAL and STRUDEL.
 *	
 *	Revision 1.3  2001/01/31 17:32:43  ramarao
 *	Implemented CR# 4564.
 *	
 *	Revision 1.2  2001/01/19 21:06:00  ramarao
 *	Merged from SP.
 *	
# Revision 1.2  2000/10/14  18:46:26  pinnacle
# Replaced: vds/vddraw/drw/VDdrwexeccfg.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/05/16  14:56:58  pinnacle
# Created: vds/vddraw/drw/VDdrwexeccfg.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.11  1998/04/18  19:07:06  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by azuurhou for vds
#
# Revision 1.10  1998/04/10  21:10:38  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by yzhu for vds
#
#
# Revision 1.8  1998/03/24  21:48:58  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by mdong for vds
#
# Revision 1.7  1997/12/26  19:36:46  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by v250_int for vds
#
# Revision 1.6  1997/12/16  19:43:52  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by impd for vds
#
# Revision 1.5  1997/11/13  19:30:00  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by rchennup for vds
#
# Revision 1.3  1997/07/24  04:06:40  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by ksundar for vds
#
# Revision 1.2  1997/07/08  14:16:00  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.11  1996/06/07  20:44:22  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by v240_int for vds.240
#
# Revision 1.10  1995/09/28  12:50:46  pinnacle
# Replaced: ./vddraw/drw/VDdrwexeccfg.I for:  by azuurhou for vds.240
#
# Revision 1.9  1995/08/16  14:47:14  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by azuurhou for vds.240
#
# Revision 1.8  1995/06/27  18:28:02  pinnacle
# Replaced: vddraw/drw/VDdrwexeccfg.I for:  by azuurhou for vds.240
#
# Revision 1.7  1995/05/05  08:05:08  pinnacle
# Replace: by tlbriggs for OPE
#
 *
 * History:
 *	MM/DD/YY	AUTHOR	DESCRIPTION
 *	05/02/95	tlb	Change element not processed message
 *	08/12/95	adz	Add structural keywords for visualization.
 *	09/27/95	adz	Change getname for general call.
 *	07/23/97	Sundar	Add cog keyword and kept the keywords 
 *				intersection & contour of I/STRUCT.  
 *      03/24/98        Ming    TR179800846.
 *      05/16/00	RR	Added to-uppercase and to-lowercase.
 *************************************************************************/

class implementation VDSroot ;

#include <malloc.h>
#include "exdef.h"
#include "exmacros.h"
#include "DIdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "UOMdef.h"
#include "UOM.h"
#include "fontdef.h"
#include "font.h"
#include "vdprdmacros.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_drwdef.h"
#include "vddrwattr.h"
#include "v_drw.h"
#include "v_drwapi.h"
#include "v_drwmacros.h"
#include "v_dbgmacros.h"
#include "v_miscmacros.h"

/*
 * Includes of function prototypes.
 */
#include "v_drwproto.h"
#include "v_ioproto.h"
#include "v_objgarbage.h"
#include "v_strngproto.h"

#define		MAX_VISUAL_FUNC	50

/*----------------------------------------------------------------------------*/
long VD_drwExecConfigAddFunctions()
{
	char			*visK	[ MAX_VISUAL_FUNC ] ;
	VD_drwUsrTokType	 visU	[ MAX_VISUAL_FUNC ] ;
	VD_drwAction		 visA	[ MAX_VISUAL_FUNC ] ;
	int			sts,
				k = 0,
				u = 0,
				a = 0;

	/*	
	 * Add the graphical output function volume-cut.
	 */
	SetProc( VD_drwExecConfigAddFunctions ); Begin
						   
	visK[ k++	]	 = "cog" ;
	visK[ k++	]	 = "vis-edges-A" ;
	visK[ k++	]	 = "vis-edges-B" ;
	visK[ k++	]	 = "vis-edges-C" ;
	visK[ k++	]	 = "env-edges-A" ;
	visK[ k++	]	 = "env-edges-B" ;
	visK[ k++	]	 = "env-edges-C" ;
	visK[ k++	]	 = "member-A" ;
	visK[ k++	]	 = "member-B" ;
	visK[ k++	]	 = "member-C" ;
	visK[ k++	]	 = "centerline" ;
	visK[ k++	]	 = "centerline-A" ;
	visK[ k++	]	 = "centerline-B" ;
	visK[ k++       ]        = "intersection" ;
        visK[ k++       ]        = "contour" ;
        visK[ k++       ]        = "placemacro" ;
	visK[ k++       ]        = "to-uppercase" ;
	visK[ k++       ]        = "to-lowercase" ;
	visK[ k++       ]        = "int-holes-to-delete" ;

	visU[ u++	]	 = VD_drwOUTPUT ;	/* cog */
	visU[ u++	]	 = VD_drwOUTPUT ;	/* vis-edges-A	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* vis-edges-B	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* vis-edges-C	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* env-edges-A	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* env-edges-B	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* env-edges-C	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* member-A	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* member-B	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* member-C	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* centerline	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* centerline-A	*/
	visU[ u++	]	 = VD_drwOUTPUT ;	/* centerline-B	*/
	visU[ u++       ]        = VD_drwOUTPUT ;       /* intersection */
        visU[ u++       ]        = VD_drwOUTPUT ;       /* contour      */
        visU[ u++       ]        = VD_drwOUTPUT ;       /* placemacro   */
	visU[ u++       ]        = VD_drwFUNCTION ;	/* Convert to UPPER */
	visU[ u++       ]        = VD_drwFUNCTION ;     /* Convert to lower */
	visU[ u++       ]        = VD_drwFUNCTION ;     /* Int Holes To Delete */

	visA[ a++	].output = OUTPUT_ADDRESS( VD,	cog );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	edges_A );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	edges_B );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	edges_C );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	env_edges_A );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	env_edges_B );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	env_edges_C );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	member_A );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	member_B );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	member_C );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	centerline );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	centerline_A );
	visA[ a++	].output = OUTPUT_ADDRESS( VD,	centerline_B );
	visA[ a++       ].output = OUTPUT_ADDRESS( VD,  intersection );
        visA[ a++       ].output = OUTPUT_ADDRESS( VD,  contour );
        visA[ a++       ].output = OUTPUT_ADDRESS( VD,  placemacro );

	visA[ a++       ].function = FUNCTION_ADDRESS( VD, get_upper_text );
	visA[ a++       ].function = FUNCTION_ADDRESS( VD, get_lower_text );
	visA[ a++       ].function = FUNCTION_ADDRESS( VD, int_holes_to_delete );

	if(( vd$prd_get_product_info( logo = VD_PROD_LOGO_STRUCT )) &&
	   ( ! ex$is_batch() )){

	   /*
	    * Only when I/STRUCT is active and using the interactive
	    * mode, these keywords will be added to the process.
	    */

	  visK[ k++	]	 = "profile" ;
	  visK[ k++	]	 = "projection" ;
	  visK[ k++	]	 = "axis" ;
	  visK[ k++	]	 = "axis-A" ;
	  visK[ k++	]	 = "axis-B" ;
	  visK[ k++	]	 = "edge" ;
	  visK[ k++	]	 = "weldline" ;

	  /*
	   * Structural functions.
	   */

	  visK[ k++	]	 = "profile-direction" ;
	  visK[ k++	]	 = "plate-direction" ;
	  visK[ k++	]	 = "is-plate-hidden" ;
	  visK[ k++	]	 = "is-beam-hidden" ;
	  visK[ k++	]	 = "parallel-plates" ;
	  visK[ k++     ]        = "is-mark-hidden" ;
	  visK[ k++       ]      = "declivity";
	  visK[ k++       ]      = "set-object-transparent";
	  
	  visU[ u++	]	 = VD_drwOUTPUT ;	/* profile	*/
	  visU[ u++	]	 = VD_drwOUTPUT ;	/* projection	*/
	  visU[ u++	]	 = VD_drwOUTPUT ;	/* axis		*/
	  visU[ u++	]	 = VD_drwOUTPUT ;	/* axis-A	*/
	  visU[ u++	]	 = VD_drwOUTPUT ;	/* axis-B	*/
	  visU[ u++	]	 = VD_drwOUTPUT ;	/* edge		*/
	  visU[ u++	]	 = VD_drwOUTPUT ;	/* weldline	*/

	  visU[ u++	]	 = VD_drwFUNCTION ;	/* profile-dir	*/
	  visU[ u++	]	 = VD_drwFUNCTION ;	/* plate-dir	*/
	  visU[ u++	]	 = VD_drwFUNCTION ;	/* is-plate-hid	*/
	  visU[ u++	]	 = VD_drwFUNCTION ;	/* is-beam-hid	*/
	  visU[ u++	]	 = VD_drwFUNCTION ;	/* parallel-pl	*/
	  visU[ u++     ]        = VD_drwFUNCTION ;     /* is-mark-hid  */
	  visU[ u++     ]        = VD_drwFUNCTION ;     /* Declivity Angle  */
	  visU[ u++     ]	 = VD_drwFUNCTION ;     /*object-transparent*/

	  visA[ a++	].output = OUTPUT_ADDRESS( VD,	profile );
	  visA[ a++	].output = OUTPUT_ADDRESS( VD,	projection );
	  visA[ a++	].output = OUTPUT_ADDRESS( VD,	axis );
	  visA[ a++	].output = OUTPUT_ADDRESS( VD,	axis_A );
	  visA[ a++	].output = OUTPUT_ADDRESS( VD,	axis_B );
	  visA[ a++	].output = OUTPUT_ADDRESS( VD,	edge );
	  visA[ a++	].output = OUTPUT_ADDRESS( VD,	weldline );

	  visA[ a++	].function = FUNCTION_ADDRESS( VD, profile_direction );
	  visA[ a++	].function = FUNCTION_ADDRESS( VD, plate_direction   );
	  visA[ a++	].function = FUNCTION_ADDRESS( VD, is_plate_hidden   );
	  visA[ a++	].function = FUNCTION_ADDRESS( VD, is_beam_hidden    );
	  visA[ a++	].function = FUNCTION_ADDRESS( VD, parallel_plates   );
          visA[ a++     ].function = FUNCTION_ADDRESS( VD, is_mark_hidden    );
	  visA[ a++     ].function = FUNCTION_ADDRESS( VD, declivity );
	  visA[ a++     ].function = FUNCTION_ADDRESS( VD, set_object_trans  );

	  // When adding more entries, make sure NOT to EXCEED "MAX_VISUAL_FUNC" (ADJUST IF NECESSARY !!!)
	}

	/*
	 * validation check.
	 */
	if( k != u || k != a || u != a ){
		printf(" Error in setup external for Visualization.\n");
		return FALSE ;
	}

	sts =
	VD_drwAddFunctions( k, visK, visU, visA );
	if( ! (sts & 1)){
	  printf(" Error: VD_drwAddFunctions in VD_drwExecConfigAddFunc\n");
	}

	End ;
	return sts ;
} 

/*----------------------------------------------------------------------------*/
long VD_drwExecConfigRmFunctions()
{
	/*
	 * remove external functions from standard parser.
	 */
	VD_drwRmFunctions() ;
	return OM_S_SUCCESS ;
}

/*----------------------------------------------------------------------------*/
long VD_drwExecConfig( msg, elmId, elmEnv, drwPlane, viewPlane, viewVect, 
		      drwEnv, drwLbsys, selCount, selList, filename, set_name,
		      appData, elm_type, output )

long		      *msg ;	   /* OUT: Completion code		   */
const struct GRid     *elmId ;	   /* IN : Id of element to draw	   */
const struct GRmd_env *elmEnv ;	   /* IN : Mod. env. of element to draw	   */
const struct IGRplane *drwPlane ;  /* IN : Plane of drawing sheet	   */
const struct IGRplane *viewPlane ; /* IN : Plane of drawing view	   */
const IGRvector	      viewVect ;   /* IN : View (projection) vector	   */
const struct GRmd_env *drwEnv ;	   /* IN : Mod. env. of drawing sheet	   */
const struct IGRlbsys *drwLbsys ;  /* IN : Extents of drawing sheet	   */
int		      selCount ;   /* IN : Count of graphics also selected */
const struct GRid     selList[] ;  /* IN : List  of graphics also selected */
const char	      *filename ;  /* IN : File to be executed		   */
const char	      *set_name ;  /* IN : SetName of reference objects    */
void		      *appData ;   /* IN : Application-specific data	   */
const char	      *elm_type ;  /* IN : Element Type                    */
VD_drwOutputData      **output ;  {/* OUT: List of outputs		   */

	long			sts = OM_S_SUCCESS ;
	GRname			filepath;
	int			NumberOfBytes,
				BytesReceived ;
	struct GRsymbology	elmSymb ;
	VD_drwInputData		inp ;

	SetProc( VD_drwExecConfig ); Begin

	*output = NULL ;

	if( filename ) {
		sprintf( filepath, "%s/%s", VD_K_DRW_CONFIG_RELPATH, filename );
	}
	else{
                strcpy( filepath, VD_K_DRW_SETUP_RELPATH ) ;
        }

	/*
	 * Copy the setname of the reference objects.
	 */
	if( set_name ){
		strcpy( inp.refSetName, set_name );
	}
	else{
		inp.refSetName[0] = '\0' ;
	}

	/*
	 * Look for Drawing Extraction config file, then open it.
	 */
	VD_drwInitStackOfInputFiles( &inp.inputFiles ) ;
	if( !VD_drwPushInputFile( filepath, TRUE, &inp.inputFiles ) ) {
		*msg = MSFAIL ; goto wrapup ;
	}

	/*
	 * Get default attributes for text.
	 */
	NumberOfBytes = sizeof inp.defaults.textSymb ;
	gr$get_text_symb(	msg	= msg,
				sizbuf	= &NumberOfBytes,
				buffer	= &inp.defaults.textSymb,
				nret	= &BytesReceived ) ;

	/*
	 * Whatever the Active Font is, put "default" font by default.
	 */
	VD_retrieveFont( msg, VD_K_DRW_DFLT_FONT,
			&inp.defaults.textSymb.Active_font ) ;

	/*
	 * Default angle for view cone (used to find the view type).
	 */
	inp.defaults.viewConeAngle	= VD_K_VIEW_CONE_ANGLE ;

	/*
	 * Flag justification as `not set', if not overriden by user in the
	 * interpreted file, the system will decide of a justification by
	 * itself.
	 */
	inp.defaults.textSymb.Active_just = VD_K_DRW_JUST_NOT_SET ;

	/*
	 * Default scale factor : 1.
	 * Offset of axis from beam : 0.
	 * Filled display OFF by default.
	 * Set default style for hidden lines.
	 */
	inp.defaults.dpAttr.scale		= 1. ;
	inp.defaults.dpAttr.offset		= 0. ;
	inp.defaults.dpAttr.filledDisplay	= FALSE ;
	inp.defaults.dpAttr.hiddenStyle		= VD_K_HIDDEN_STYLE ;
	inp.processFlags			= FALSE ;

	/*
	 * Default position for text placed near extracted graphics:
	 * - At mid point of element
	 * - Horizontal (// to horizontal axis of drawing sheet)
	 */
	inp.defaults.textPos.loc	= VD_middle ;
	inp.defaults.textPos.voff	= VD_vcenter;
	inp.defaults.textPos.voffVal	= 0 ;
	inp.defaults.textPos.hoff	= VD_hcenter;
	inp.defaults.textPos.hoffVal	= 0 ;
	inp.defaults.textPos.dir	= VD_horiz ;
	inp.defaults.textPos.rev	= VD_notReversed ;

	/*
	 * Get default symbology for the graphics in drawing sheet: that of the
	 * element being extracted.
	 */
	om$send(msg	= message GRvg.GRgetsymb( msg, &elmSymb ),
		senderid= elmId->objid,
		targetid= elmId->objid,
		targetos= elmId->osnum ) ;

	inp.defaults.elmDisplay	= elmSymb.display_attr ;
	inp.defaults.elmLevel	= elmSymb.level ;

        /*
         * Hidden Line defaults.
         */
        inp.defaults.hdnDisplay = elmSymb.display_attr ;
        inp.defaults.hdnLevel   = elmSymb.level ;
        inp.defaults.hdnDisplay.style   = VD_K_HIDDEN_STYLE ;

	/*
	 * Element in model to be extracted.
	 */
	inp.elmId		= (struct GRid*)     elmId ;
	inp.elmEnv		= (struct GRmd_env*) elmEnv ;

	/*
	 * When the element to be extracted is a macro occurrence (construction)
	 * we need the name of the macro definition to compare it with that
	 * specified by user in the config file.
	 */
	if( elm_type )  {
		strcpy( inp.constDefName, elm_type ) ;
	}
	else  {
	        *inp.constDefName = '\0' ;
	}

	/*
	 * Drawing sheet information:
	 * - module environment of drawing sheet.
	 * - extents and axes of drawing sheet.
	 * - drawing plane.
	 * - view plane.
	 * - view vector.
	 * - view type initialization.
	 */
	inp.drwInfo.drwEnv	= (struct GRmd_env*) drwEnv ;
	inp.drwInfo.drwLbsys	= (struct IGRlbsys*) drwLbsys ;
	inp.drwInfo.drwPlane	= (struct IGRplane*) drwPlane ;
	inp.drwInfo.viewPlane	= (struct IGRplane*) viewPlane ;
	inp.drwInfo.viewVector	= (double*)          viewVect ;
	inp.viewType		= VD_notDefinedType ;

	/*
	 * List and count of elements to be extracted selected by user.
	 */
	inp.toBeDrawn.elmCount	= selCount ;
	inp.toBeDrawn.elmList	= (struct GRid *) selList ;
	inp.appData		= appData ;

	/*
         * Initialize function specific data.
         */
	VSinitNamesToDelete();

	/*
	 * `sts' comes from Yacc : 0 if OK else error.
	 * *msg is not relevant to examine since its is passed everywhere and
	 * it is allowed in the interpreter for things to go badly.
	 * Anyway in case of Yacc error (mostly syntax errors) we allow
	 * any generated graphics to be returned, if any.
	 */

	sts = VD_drwExecConfigAddFunctions();

	sts = vd_$drwInterpretConfigFile(	msg	= msg,
						input	= &inp,
						output	= output ) ;
	if( sts == 0 ) sts = OM_S_SUCCESS ;

	sts = VD_drwExecConfigRmFunctions();

	/*
	 * Close log file if a "set logfile <filename>" in the config file
	 * opened a logfile. If not nothing will be done.
	 */
	VD_drwCloseLogFile() ;

	wrapup :
		/*
		 * Free memory allocated for APFEL-STRUDEL's arrays.
		 */
		VD_drwFreeMemoryForArrays() ;

		/*
		 * Get rid of possible temporary elements created by the system
		 * for computation purposes. Those elements normally go away
		 * at sleep time, but if a large model is being extracted in
		 * one go, we may run out of memory ...
		 */
		VD_discardTmpObjs() ;

		VD_drwCloseInputFiles( &inp.inputFiles ) ;

		if( !( sts & 1 ) ) {
			if( *msg & 1 ) *msg = MSFAIL ;
			VD_drwFreeOutputData( output ) ;
		} 
		End
		return *msg & 1 ;

} /* VD_drwExecConfig */
/*----------------------------------------------------------------------------*/
void VD_drwElmNotProcessed( logFile, inp )

FILE			*logFile ;
const VD_drwInputData	*inp ; {

	long			sts,
				rc ;
	struct GRobj_info	info ;
	GRname			name ;

	SetProc( VD_drwElmNotProcessed ); Begin

	sts = om$send(	msg	= message GRgraphics.GRgetobjinfo( &rc, &info ),
			senderid= inp->elmId->objid,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & rc ) ) *info.type = '\0' ;

	*name = '\0' ;
	if( ! ( VD_drwGetACcpxInfo( inp->elmId, name, FALSE ))){
		*name = '\0' ;
	}

	fprintf( logFile, " ** Object not processed : %s (%s)\n",
		 info.type, name ) ;
	End

} /* VD_drwElmNotProcessed */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
