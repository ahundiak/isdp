/* $Id: VSdrwexeccfg.I,v 1.6 2001/03/08 22:52:48 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:	vsdrawing/VSdrwexeccfg.I
 *
 * Description: Main driver of the Drawing Extraction Language Interpreter: 
 *              set up a few things then kick off parsing.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdrwexeccfg.I,v $
 *	Revision 1.6  2001/03/08 22:52:48  ramarao
 *	Added "declivity" Keyword in VISUAL and STRUDEL.
 *	
 *	Revision 1.5  2001/02/22 16:21:01  ramarao
 *	Removed unnecessary debugs.
 *	
 *	Revision 1.4  2001/02/14 21:04:06  ramarao
 *	Modification related to SetProc() macro.
 *	
 *	Revision 1.3  2001/01/31 17:30:16  ramarao
 *	Implemented CR# 4564.
 *	
 *	Revision 1.2  2001/01/16 22:18:46  ramarao
 *	*** empty log message ***
 *	
# Revision 1.2  2000/11/03  23:30:36  pinnacle
# Replaced: struct/vsdrawing/VSdrwexeccfg.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/11/02  15:34:32  pinnacle
# Created: struct/vsdrawing/VSdrwexeccfg.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/29  22:23:40  pinnacle
# ah
#
 *
 * History:
 *	MM/DD/YY  AUTHOR  DESCRIPTION
 *	01/29/98  ah      Got rid of global VDdraw_setup_Name
 * -------------------------------------------------------------------*/

class implementation VSfeature ;

#include <malloc.h>
#include "DIdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "UOMdef.h"
#include "UOM.h"
#include "fontdef.h"
#include "font.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrwdef.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"

/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"
#include "vsioproto.h"
#include "vsobjgarbage.h"
#include "vsstrngproto.h"

/*
 * External variable;  Set to TRUE during drawing extraction. Defaults to
 * FALSE. If it is TRUE, the downloaded EMS methods understand that they
 * are being called for drawing extraction and behave accordingly. When FALSE
 * their behavior is that of EMS' behavior.
 */

%safe
IGRboolean  VS_STRUDL_process = FALSE;
%endsafe

//extern IGRboolean VS_STRUDL_process;

#define         MAX_VISUAL_FUNC 50

/*----------------------------------------------------------------------------*/
long VSdrwExecConfigAddFunctions()
{
        char                    *visK   [ MAX_VISUAL_FUNC ] ;
        VSdrwUsrTokType         visU   [ MAX_VISUAL_FUNC ] ;
        VSdrwAction             visA   [ MAX_VISUAL_FUNC ] ;
        int                     sts,
                                k = 0,
                                u = 0,
                                a = 0;

	visK[ k++       ]        = "is-mark-hidden" ;
	visU[ u++       ]        = VSdrwFUNCTION ; /* is-mark-hidden */
	visA[ a++       ].function = FUNCTION_ADDRESS( VS, is_mark_hidden );

        visK[ k++       ]        = "int-holes-to-delete" ;
        visU[ u++       ]        = VSdrwFUNCTION ; /* int-holes-to-delete */
        visA[ a++       ].function = FUNCTION_ADDRESS( VS, int_holes_to_delete );

        visK[ k++       ]        = "declivity" ;
        visU[ u++       ]        = VSdrwFUNCTION ; /* Declivity Angle */
        visA[ a++       ].function = FUNCTION_ADDRESS( VS, declivity );

        /*
         * validation check.
         */
        if( k != u || k != a || u != a ){
                printf(" Error in setup external for Visualization.\n");
                return FALSE ;
        }

        sts =
        VSdrwAddFunctions( k, visK, visU, visA );
        if( ! (sts & 1)){
          printf(" Error: VD_drwAddFunctions in VD_drwExecConfigAddFunc\n");
        }

        return sts ;
}

/*----------------------------------------------------------------------------*/
long VSdrwExecConfigRmFunctions()
{
        /*
         * remove external functions from standard parser.
         */
        VSdrwRmFunctions() ;
        return OM_S_SUCCESS ;
}


/*----------------------------------------------------------------------------*/
long VSdrwExecConfig( msg, elmId, elmEnv, drwPlane, viewPlane, viewVect, 
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
VSdrwOutputData	      **output ;  {/* OUT: List of outputs		   */

	long			sts = OM_S_SUCCESS ;
	GRname			filepath ;
	int			NumberOfBytes,
				BytesReceived ;
	struct GRsymbology	elmSymb ;
	VSdrwInputData		inp ;

	*output = NULL ;

	/*
	 * If no filename has been specified, take the default one.
	 */
	if( filename ) {
		sprintf( filepath, "%s/%s", VS_K_DRW_CONFIG_RELPATH, filename );
	} else {
                VDdrwGetSetupFileName(filepath);
                if (strlen(filepath) == 0) { 
       			strcpy( filepath, VS_K_DRW_SETUP_RELPATH ) ;
		}
	}

	/*
	 * Look for Drawing Extraction config file, then open it.
	 */
	VSdrwInitStackOfInputFiles( &inp.inputFiles ) ;
	if( !VSdrwPushInputFile( filepath, TRUE, &inp.inputFiles ) ) {
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
	VSretrieveFont( msg, VS_K_DRW_DFLT_FONT,
			&inp.defaults.textSymb.Active_font ) ;

	/*
	 * Default angle for view cone (used to find the view type).
	 */
	inp.defaults.viewConeAngle	= VS_K_VIEW_CONE_ANGLE ;

	/*
	 * Flag justification as `not set', if not overriden by user in the
	 * interpreted file, the system will decide of a justification by
	 * itself.
	 */
	inp.defaults.textSymb.Active_just = VS_K_DRW_JUST_NOT_SET ;

	/*
	 * Default scale factor : 1.
	 * Offset of axis from beam : 0.
	 * Filled display OFF by default.
	 * Set default style for hidden lines.
	 */
	inp.defaults.dpAttr.scale		= 1. ;
	inp.defaults.dpAttr.offset		= 0. ;
	inp.defaults.dpAttr.filledDisplay	= FALSE ;
	inp.defaults.dpAttr.hiddenStyle		= VS_K_HIDDEN_STYLE ;

	/*
	 * Default position for text placed near extracted graphics:
	 * - At mid point of element
	 * - Horizontal (// to horizontal axis of drawing sheet)
	 */
	inp.defaults.textPos.loc	= VSmiddle ;
	inp.defaults.textPos.voff	= VSvcenter;
	inp.defaults.textPos.voffVal	= 0 ;
	inp.defaults.textPos.hoff	= VShcenter;
	inp.defaults.textPos.hoffVal	= 0 ;
	inp.defaults.textPos.dir	= VShoriz ;
	inp.defaults.textPos.rev	= VSnotReversed ;

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
	 * Drawing sheet information:
	 * - module environment of drawing sheet.
	 * - extents and axes of drawing sheet.
	 * - drawing plane.
	 * - view plane.
	 * - view vector.
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

	VS_STRUDL_process = TRUE;

	/*
	 * Initialize the function specific data.
 	 */
	VSinitNamesToDelete();

	/*
	 * `sts' comes from Yacc : 0 if OK else error.
	 * *msg is not relevant to examine since its is passed everywhere and
	 * it is allowed in the interpreter for things to go badly.
	 * Anyway in case of Yacc error (mostly syntax errors) we allow
	 * any generated graphics to be returned, if any.
	 */

	sts = VSdrwExecConfigAddFunctions();

	sts = vs$drwInterpretConfigFile(	msg	= msg,
						input	= &inp,
						output	= output ) ;
	if( sts == 0 ) sts = OM_S_SUCCESS ;

	//sts = VSdrwExecConfigRmFunctions();

	VS_STRUDL_process = FALSE;

	/*
	 * Close log file if a "set logfile <filename>" in the config file
	 * opened a logfile. If not nothing will be done.
	 */
	VSdrwCloseLogFile() ;

	wrapup :
		/*
		 * Free memory allocated for APFEL-STRUDEL's arrays.
		 */
		VSdrwFreeMemoryForArrays() ;

		/*
		 * Get rid of possible temporary elements created by the system
		 * for computation purposes. Those elements normally go away
		 * at sleep time, but if a large model is being extracted in
		 * one go, we may run out of memory ...
		 */
		VSdiscardTmpObjs() ;

		VSdrwCloseInputFiles( &inp.inputFiles ) ;

		if( !( sts & 1 ) ) {
			if( *msg & 1 ) *msg = MSFAIL ;
			VSdrwFreeOutputData( output ) ;
		} 
		return *msg & 1 ;

} /* VSdrwExecConfig */
/*----------------------------------------------------------------------------*/
void VSdrwElmNotProcessed( logFile, inp )

FILE			*logFile ;
const VSdrwInputData	*inp ; {

	long			sts,
				rc ;
	struct GRobj_info	info ;
	GRname			name ;

	sts = om$send(	msg	= message GRgraphics.GRgetobjinfo( &rc, &info ),
			senderid= inp->elmId->objid,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & rc ) ) *info.type = '\0' ;

	sts = om$send(	msg	= message GRvg.GRgetname( &rc, name ),
			senderid= inp->elmId->objid,
			targetid= inp->elmId->objid,
			targetos= inp->elmId->osnum ) ;
	if( !( sts & 1 & rc ) ) *name = '\0' ;

	fprintf( logFile, " ** Object not processed :\n ** %s %s\n",
		 info.type, name ) ;
	fprintf( logFile, " ** Object matched no type specified in `%s'\n",
		 inp->inputFiles.name[0] ) ;

} /* VSdrwElmNotProcessed */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
