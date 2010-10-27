/* $Id: VDdrwexecatt.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:        vddraw/drw/VDdrwexecatt.I
 *
 * Description:
 *
 *	This is the main driver for an suported interface for the generation
 *	of Attribute Driven Symbology. 
 *
 *	The graphical output function used in the ASCII support file is called
 *	symbology [ ... ] ;
 *
 *	To avoid problems within the parser, the function will be loaded only
 *	when calling the parser control function. The function will be added
 *	and deleted on line.
 *
 *	This interface is created to allow the user to define a specific
 *	symbology for the object, different then the objects 3d model
 *	symbology. The layer will be allways a needed request for this process.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwexecatt.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1998/05/20  21:58:22  pinnacle
# Replaced: vddraw/drw/VDdrwexecatt.I for:  by mdong for vds
#
 *
 * History:
 *      05/20/98        Ming      TR179800594
 *
 *************************************************************************/

class implementation VDSroot ;

#include <malloc.h>
#include "DIdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "UOMdef.h"
#include "UOM.h"
#include "fontdef.h"
#include "font.h"
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

#define		MAX_SYMB_FUNC	5

/*----------------------------------------------------------------------------*/
long VD_drwExecSymbAddFunctions()
{
	char			*symbK	[ MAX_SYMB_FUNC ] ;
	VD_drwUsrTokType	symbU	[ MAX_SYMB_FUNC ] ;
	VD_drwAction		symbA	[ MAX_SYMB_FUNC ] ;
	int			sts,
				k = 0,
				u = 0,
				a = 0;

	/*	
	 * Add the graphical output function volume-cut.
	 */
	SetProc( VD_drwExecSymbAddFunctions ); Begin

	symbK[ k++	]	 = "symbology" ;
	symbU[ u++	]	 = VD_drwOUTPUT ;
	symbA[ a++	].output = OUTPUT_ADDRESS( VD, symbology );

	/*
	 * validation check.
	 */
	if( k != u || k != a || u != a ){
		printf(" Error in setup external Attr. Driven Symbology.\n");
		return FALSE ;
	}

	sts =
	VD_drwAddFunctions( k, symbK, symbU, symbA );
	if( ! (sts & 1)){
	  printf(" Error: VD_drwAddFunctions in VD_drwExecSymbAddFunctions\n");
	}

	End ;
	return sts ;
} 

/*----------------------------------------------------------------------------*/
long VD_drwExecSymbRmFunctions()
{
	/*
	 * remove external functions from standard parser.
	 */
	VD_drwRmFunctions() ;
	return OM_S_SUCCESS ;
}

/*----------------------------------------------------------------------------*/
long VD_drwExecSymbology(msg, elmId, elmEnv, drwPlane, viewPlane, viewVect, 
			drwEnv, drwLbsys, selCount, selList, filename, appData,
		       	output )

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
void		      *appData ;   /* IN : Application-specific data	   */
VD_drwOutputData      **output ;  {/* OUT: List of outputs		   */

	long			sts = OM_S_SUCCESS ;
	GRname			filepath;
	int			NumberOfBytes,
				BytesReceived ;
	struct GRsymbology	elmSymb ;
	VD_drwInputData		inp ;

	SetProc( VD_drwExecSymbology ); Begin

	*output = NULL ;

	/*
	 * Check if a filename was given.
	 */

	if( filename ) {
		sprintf( filepath, "%s/%s", "config/attribute", filename );
	}
	else{
		sts = MSFAIL ;
		goto wrapup;
        }

	/*
	 * Look for Drawing Extraction config file, then open it.
	 */
	VD_drwInitStackOfInputFiles( &inp.inputFiles ) ;
	if( !VD_dgnPushInputFile( filepath, TRUE, &inp.inputFiles ) ) {
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
	 * Get default symbology for the graphics in drawing sheet: that
	 * 	of the element being extracted.
	 */

        __DBGpr_obj( "elmId", *elmId);

        sts = 
        _VD_SEND_OBJN(  *elmId, GRvg.GRgetsymb( msg, &elmSymb ));
        if( sts&*msg&1 ) {
/* yzhu     __CheckRC( 1, *msg, "GRvg.GRgetsymb", wrapup ); */
        __DBGpr_com( " OK to get symbology from the element ");
        __DBGpr_int( " level", elmSymb.level);
        __DBGpr_int( " color", elmSymb.display_attr.color);
        __DBGpr_int( " weight", elmSymb.display_attr.weight);
        __DBGpr_int( " style", elmSymb.display_attr.style);

        inp.defaults.elmDisplay = elmSymb.display_attr ;
        inp.defaults.elmLevel   = elmSymb.level ;
	
	/*
	 * Hidden Line defaults.
	 */
        inp.defaults.hdnDisplay = elmSymb.display_attr ;
        inp.defaults.hdnLevel   = elmSymb.level ;
        inp.defaults.hdnDisplay.style   = VD_K_HIDDEN_STYLE ;
        }	

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
	*inp.constDefName = '\0' ;

	/*
	 * Drawing sheet information is not needed.
	 *	 The are set to NULL in the macro.
	 */
	inp.drwInfo.drwEnv	= (struct GRmd_env*) drwEnv ;

	inp.drwInfo.drwLbsys	= (struct IGRlbsys*) drwLbsys ;
	inp.drwInfo.drwPlane	= (struct IGRplane*) drwPlane ;
	inp.drwInfo.viewPlane	= (struct IGRplane*) viewPlane ;
	inp.drwInfo.viewVector	= (double*)          viewVect ;

	/*
	 * List and count of elements to be extracted selected by user.
	 */
	inp.toBeDrawn.elmCount	= selCount ;
	inp.toBeDrawn.elmList	= (struct GRid *) selList ;

	inp.appData		= appData ;
	inp.applicationFlag 	= VD_K_DRW_SYMBOLOGY;  /* TR179800594  */

	/*
	 * `sts' comes from Yacc : 0 if OK else error.
	 * *msg is not relevant to examine since its is passed everywhere and
	 * it is allowed in the interpreter for things to go badly.
	 * Anyway in case of Yacc error (mostly syntax errors) we allow
	 * any generated graphics to be returned, if any.
	 */

	sts = VD_drwExecSymbAddFunctions() ;

	sts = vd_$drwInterpretConfigFile(	msg	= msg,
						input	= &inp,
						output	= output ) ;
	if( sts == 0 ) sts = OM_S_SUCCESS ;

	sts = VD_drwExecSymbRmFunctions() ;

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

} /* VD_drwExecSymbology */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
