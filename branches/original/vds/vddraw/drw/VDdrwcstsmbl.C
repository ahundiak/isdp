/* $Id: VDdrwcstsmbl.C,v 1.2 2001/01/19 21:04:49 ramarao Exp $  */

/* I/VDS
 * -------------------------------------------------------------------------
 *
 * File:        vddraw/drw/ VDdrwcstsmbl.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDdrwcstsmbl.C,v $
 * Revision 1.2  2001/01/19 21:04:49  ramarao
 * Supress the warning messages for symbol placement.
 *
 * Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 * Initial import to CVS
 *
 * Revision 1.3  1999/04/09  21:04:44  pinnacle
 * Rama Rao SP08
 *
 * Revision 1.2  1998/04/30  18:59:22  pinnacle
 * Need typecast in sym_cl_place
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.6  1998/04/21  21:15:00  pinnacle
 * Replaced: vddraw/drw/VDdrwcstsmbl.C for:  by mdong for vds
 *
 *
 * History:
 *
 * 04/17/98  Ming  TR179800965
 * 04/30/98  ah    Need typecast in TR179800965 fix
 * 04/09/99  ah    Suppress some unwanted warnings, see APR99
 * -------------------------------------------------------------------------
 */

#include <string.h>
#include <stdlib.h>

#include <OMerrordef.h>
#include <igrtypedef.h>
#include <exdef.h>
#include <ex.h>
#include <msdef.h>
#include <exms.h>
#include <msmacros.h>
#include "grmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"

#include "grio.h"
#include "lc.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "griomacros.h"
#include "grmsg.h"

#include "bstypes.h"
#include "msdef.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "vdmiscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "maidmx.h"
#include "v_drwproto.h"
#include "v_vecmxproto.h"

#define	_X	0
#define _Y	1
#define _Z	2

extern int		VD_drwGetEndTxOrientAndJust() ;
extern int		VD_drwGetMidTxOrientAndJust() ;
extern int		VD_drwGetTxOrientAndJust() ;

extern int              EX_cmdsrch();
/*----------------------------------------------------------------------------*/
int VD_drwCstSymbol( msg, inp, xData, outpgr, outptx )

long		        *msg ;	   /* OUT: Completion code		  */
const VD_drwInputData    *inp ;	   /* IN : Data input to interpreter      */
VD_drwExecData	        *xData ;   /* IN : Data modified during execution */
const VD_drwGraphicGroup *outpgr ;  /* IN : List of constructed graphics   */
VD_drwGraphicGroup       *outptx ; {/* I/O: List to which add new symbol   */

	long			sts ;		/* Return status	*/
	struct IGRbsp_curve	*cvGeom	= NULL,	/* Geom of input curve	*/
				**cvGeoms= NULL;/* Geom of input curves	*/
	IGRvector		cvDir,		/* Dir. vector of curve	*/
				endTn1,		/* Tg. of cv at 1st end	*/
				endTn2,		/* Tg. of cv at 2nd end	*/
				midTn ;		/* Tg. of cv at mid pnt	*/
	int			hasNoDir,	/* Curve has no dir. ?	*/
				txJust,		/* Text justification	*/
				i ;		/* Loop-on-geoms index	*/
	IGRpoint		cvBox[4],	/* Box of curve		*/
				txPos,		/* Text position	*/
				endPt1,		/* 1st end point of cv.	*/
				endPt2,		/* 2nd end point of cv.	*/
				midPt ;		/* Mid point of curve	*/
	VD_blkJustPnts		cvJustPnts ;	/* Justif pnts of curve	*/
	VD_directionType		cvDirType ;	/* Direction type of cv	*/
	VD_drwVertTxOffset	txVtOff ;	/* Vert. offset type	*/
	VD_drwHoriTxOffset	txHzOff ;	/* Hori. offset type	*/
	VD_drwTxDir		txDir ;		/* Direction of text	*/
	VD_drwTxLoc		txLoc ;		/* Location of text	*/
	double			*p,
				*v = NULL,
				txHOval,	/* Val of horiz. offset	*/
				txVOval ;	/* Val of vert.  offset	*/
	IGRmatrix		txMx ;		/* Matrix for text	*/
	char			*txString ;	/* String of text	*/
	short			txLength ;	/* Length of text	*/
	struct GRid		txObj ;		/* Constructed text	*/
	VD_drwTxPosHelper	txPosHelper ;	/* Flag for text dir+pos*/


        IGRchar                 symbol_name[MAX_SYMBOL_DEF_NAME];
        IGRchar                 s[MAX_SYMBOL_DEF_NAME],
                                *original_sy = NULL,
                                *originl_lib = NULL;
        IGRlong                 size,
                                om_msg,
                                ret_msg,
                                ret_size;
//        struct  GRdpb_scale     dpb_scale;
        IGRdouble               scale[3];
        struct  GRmd_env        moduleinfo;
        struct  GRactive_symbol_def     active_symbol;
        struct  GRid            sdh_id,
                                symbol_id;
        struct  GRmd_env        sl_env;
        IGRdouble               active_angle;
        struct  GRsymbol_lib_file       file;
        struct  GRsymbol_lib_file       ori_file;
        IGRint			length;


#ifdef vdsDEBUG
	printf( "VD_drwCstSymbol enter\n" ) ;
#endif

	*msg = MSSUCC;
	
	active_angle = 0;

	txObj.objid = NULL_OBJID ;
	txPosHelper = xData->txPosHelper ;

	switch( txPosHelper ) {

		case VD_useAnchorPoint	: hasNoDir = TRUE ; break ;

		case VD_useAnchorCurve	: break ;

		case VD_useFirstCurve	:
		case VD_useAllCurves	:
		if( !outpgr || !( outpgr->count && outpgr->list ) ) {
			if( xData->verbose ) {
				VD_drwPrintf( "!!! No object constructed to put symbol on\n" ) ;
			}
			// APR99 Suppress warnings by returning MSSUCC
			*msg = MSSUCC ; return FALSE ;
		}
		if( 1 == outpgr->count ) txPosHelper = VD_useFirstCurve ;
		break ;

		default			:
		case VD_undefTxPosHelper	: /* Should never get here ... */
                        // Suppress warnings by returning MSSUCC
                        *msg = MSSUCC ; return FALSE ;
	}

	txLoc		= xData->overrides.textPos.loc ;
	txDir		= xData->overrides.textPos.dir ;
	txHzOff		= xData->overrides.textPos.hoff;
	txVtOff		= xData->overrides.textPos.voff;
	txHOval		= xData->overrides.textPos.hoffVal ;
	txVOval		= xData->overrides.textPos.voffVal ;

	switch( txPosHelper ) {

	case VD_useAnchorPoint	:
		/*
		 * We shall use the anchor point for the text position it it
		 * the same as having a curve with not predominant direction
		 * (eg. like a circle).
		 */
		hasNoDir = TRUE ;
		break ;

	case VD_useAnchorCurve	:
		vd_$get_geometry(	msg	= msg,
					grobjId	= &xData->anchorCurve._grid,
					grobjEnv= &xData->anchorCurve.mod_env,
					geometry= &cvGeom ) ;
		if( !( *msg & 1 ) ) {
			goto wrapup ;
		}
		VD_findDirOfCvInXYPlane( msg, cvGeom, cvDir, &hasNoDir ) ;
		/*
		 * From here on same processing as for `VD_useFirstCurve'.
		 */
		txPosHelper = VD_useFirstCurve ;
		break ;

	case VD_useFirstCurve	:
		/*
		 * We shall use the first curve in `outpgr->list' to find the
		 * position, direction and justification of the text.
		 */
		vd_$get_geometry(	msg	= msg,
					grobjId	= outpgr->list,
					grobjEnv= inp->drwInfo.drwEnv,
					geometry= &cvGeom ) ;
		if( !( *msg & 1 ) ) {
			goto wrapup ;
		}
		VD_findDirOfCvInXYPlane( msg, cvGeom, cvDir, &hasNoDir ) ;
		break ;

	case VD_useAllCurves	:
		/*
		 * We shall use the all the curves in `outpgr->list' to find the
		 * position, direction and justification of the text.
		 */
		/*
		 * For beam/stiffener and projection, must find the right
		 * wireframe for annotation.
		 */
		cvGeoms = _CALLOC( outpgr->count, struct IGRbsp_curve * ) ;

		for( i = 0 ; i < outpgr->count ; i++ ) {
#ifdef vdsDEBUG
			VD_ShowObj( outpgr->list + i ) ;
#endif
			vd_$get_geometry(	msg	= msg,
						grobjId	= outpgr->list + i,
						grobjEnv= inp->drwInfo.drwEnv,
						geometry= cvGeoms + i ) ;
			if( !( *msg & 1 ) ) {
				goto wrapup ;
			}
		}
		VD_findDirOfSetOfCurvesInXYPlane( msg, outpgr->count, cvGeoms,
						 cvDir, &hasNoDir ) ;
		break ;
	}

	if( hasNoDir ) {
		/*
		 * Curve with no directions are considered horizontal.
		 */
		cvDir[_X] = 1. ; cvDir[_Y] = cvDir[_Z] = 0. ;
		cvDirType = VD_horizontal ;
	} else {
		cvDirType = VD_getDirType( cvDir ) ;
	}

	__DBGpr_int( "Curve direction", cvDirType ) ;
	__DBGpr_int( "Text location", txLoc ) ;

	if( VD_useFirstCurve == txPosHelper ) {
		int	swapped ;

		switch( txLoc ) {

		case VD_1stEnd 	:
		case VD_2ndEnd	:
			VD_findEndPtsCvInXYPlane( msg, cvGeom, cvDirType,
						 endPt1, endPt2,
						 endTn1, endTn2, &swapped ) ;
			break ;
		
		case VD_middle	:
			if( cvGeom->phy_closed ) txLoc = VD_center ;
			else VD_findMidPtCvInXYPlane( msg, cvGeom,
						     midPt, midTn ) ;
			break ;
		case VD_innermost:
			 VD_findTheMostInteriorPointToACurve(	msg,
			 					cvGeom,
			 					midPt ) ;
			 break ;
		}
	} else if( VD_useAllCurves == txPosHelper ) {
		VD_drwTxLoc	t = txLoc ;
		int		swapped ;
		int		findTan = FALSE ;

		switch( t ) {
		default		:
		case VD_innermost:
		case VD_center	:
		case VD_middle	: txLoc = VD_center ;
			VD_findCenterOfSetOfCurvesInXYPlane(	msg,
								outpgr->count,
								cvGeoms,
								midPt ) ;
			break ;

		case VD_bottom	:
		case VD_right	:
		case VD_top	:
		case VD_left	: goto XMOST ;
		case VD_1stEnd	:
			t = VD_horizontal == cvDirType ? VD_left : VD_top ;
			findTan = TRUE ;
			goto XMOST ;

		case VD_2ndEnd	:
			t = VD_horizontal == cvDirType ? VD_right : VD_bottom ;
			findTan = TRUE ;

		XMOST		:
			VD_findXMostCurve( msg, t, outpgr->count, cvGeoms, &i ) ;
                        if( findTan ) {
			    VD_findEndPtsCvInXYPlane( msg, cvGeoms[i], cvDirType,
					             endPt1, endPt2,
						     endTn1, endTn2, &swapped );
			}
			break ;
		}
		cvGeom = cvGeoms[i] ;
	}

	if(      VD_useAllCurves == txPosHelper 
	    && (    VD_center    == txLoc 
	         || VD_innermost == txLoc ) ) {
		/*
		 * An horizontal vector is used.
		 */
		VD_vccpy( cvJustPnts.Center, midPt ) ;
	} else if(    VD_useAllCurves  == txPosHelper 
		   || VD_useFirstCurve == txPosHelper ) {
		/*
		 * We do not not need justification points when we have
		 * several curves with a text at center.
		 */
		VD_findBoxOfCvInXYPlane( msg, cvGeom, hasNoDir ? NULL : cvDir,
					cvBox ) ;

		VD_getJustPntsOfBlk( cvBox, cvDir, &cvJustPnts ) ;
	}

	/*
	 * Set the point for text location, as well as the vector `v' to
	 * evaluate the matrix for the text.
	 */
	if( VD_useAnchorPoint == txPosHelper ) {
		VD_vccpy( txPos, xData->anchorPoint ) ;
		/*
		 * Use the horizontal vector as `tangent to curve' for
		 * computation of text orientation and justification, when
		 * `txPosHelper' is `VD_useAnchorPoint', `cvDir' contains the
		 * horizontal vector.
		 */
		v = cvDir ;
	} else /* VD_useFirstCurve or VD_useAllCurves */ {
		switch( txLoc ) {
			case VD_innermost: p = midPt		  ; break ;
			case VD_center	: p = cvJustPnts.Center   ; break ;
			case VD_bottom	: p = cvJustPnts.BotMid   ; break ;
			case VD_right	: p = cvJustPnts.RightMid ; break ;
			case VD_top	: p = cvJustPnts.TopMid   ; break ;
			case VD_left	: p = cvJustPnts.LeftMid  ; break ;
			case VD_1stEnd	: p = endPt1 ; v = endTn1 ; break ;
			case VD_2ndEnd	: p = endPt2 ; v = endTn2 ; break ;
			default		: txLoc = VD_middle ; /* Do not break */
			case VD_middle	: p = midPt  ; v = midTn  ; break ;
		}
		VD_vccpy( txPos, p ) ;
	}
	__DBGpr_vec( "Text point before offset", txPos ) ;

/* ALAIN OLD: absolute offset - CAN BE IMPLEMENTED WHEN SOMEONE NEEDS IT
	__DBGpr_int( "Horizontal offset", txHzOff ) ;
	switch( txHzOff ) {
		case VD_toTheLeft	: txPos[_X] -= txHOval ; break ;
		case VD_hcenter		: break ;
		case VD_toTheRight	: txPos[_X] += txHOval ; break ;
	}

	__DBGpr_int( "Vertical offset", txVtOff ) ;
	switch( txVtOff ) {
		case VD_below	: txPos[_Y] -= txVOval ; break ;
		case VD_vcenter	: break ;
		case VD_above	: txPos[_Y] += txVOval ; break ;
	}
END ALAIN OLD */

	if( VD_center == txLoc || VD_innermost == txLoc ) txDir = VD_horiz ;

	/*
	 * Evaluate text's matrix and text's justification flag.
	 */
	if(    ( VD_1stEnd == txLoc || VD_2ndEnd == txLoc )
	    && ( VD_para   == txDir || VD_ortho  == txDir ) ) {

		VD_drwGetEndTxOrientAndJust(	msg,
						v,
						cvDirType,
						txDir,
						txLoc,
						txMx,
						&txJust ) ;
	} else if( VD_middle == txLoc ) {

		VD_drwGetMidTxOrientAndJust(	msg,
						v,
						cvDirType,
						txDir,
						txMx,
						&txJust ) ;
	} else {

		VD_drwGetTxOrientAndJust(	msg,
						&cvJustPnts,
						txDir,
						txLoc,
						txMx,
						&txJust ) ;
	}

	/* relative offset */
	__DBGpr_int( "Horizontal offset", txHzOff ) ;
	switch( txHzOff ) {
		case VD_toTheLeft : txPos[_X] -= txHOval * txMx[0] ;
				   txPos[_Y] -= txHOval * txMx[4] ; break ;
		case VD_hcenter	 : break ;
		case VD_toTheRight: txPos[_X] += txHOval * txMx[0] ;
				   txPos[_Y] += txHOval * txMx[4] ; break ;
	}

	__DBGpr_int( "Vertical offset", txVtOff ) ;
	switch( txVtOff ) {
		case VD_below	: txPos[_X] -= txVOval * txMx[1] ;
				  txPos[_Y] -= txVOval * txMx[5] ; break ;
		case VD_vcenter	: break ;
		case VD_above	: txPos[_X] += txVOval * txMx[1] ;
				  txPos[_Y] += txVOval * txMx[5] ; break ;
	}

	if( VD_K_DRW_JUST_NOT_SET == xData->overrides.textSymb.Active_just ) {
		__DBGpr_int( "Overriding just w/", txJust ) ;
		xData->overrides.textSymb.Active_just = txJust ;
	}

	if( xData->textFormat.bufsiz ) {
		txString = xData->textFormat.buffer ;
		txLength = xData->textFormat.curpos ;
		__DBGpr_int( "Text length", txLength ) ;

	} else {
		txString = "" ;
		txLength = 0 ;
	}
	if( xData->overrides.dpAttr.filledDisplay ) {
		xData->overrides.textSymb.Active_flags |= GRFILLED_TEXT ;
	} else {
		xData->overrides.textSymb.Active_flags &= ~GRFILLED_TEXT ;
	}

	/*
	 * Correct text matrix if text is requested to be uspide down or
	 * right-to-left.
	 */
	__DBGpr_int( "Upside down", xData->overrides.textPos.rev & VD_upsideDown ) ;
	if( (int) xData->overrides.textPos.rev & (int) VD_upsideDown ) {
		txMx[1] = - txMx[1] ;
		txMx[5] = - txMx[5] ;
	}
	__DBGpr_int( "Right to left", xData->overrides.textPos.rev & VD_rightToLeft ) ;
	if( (int) xData->overrides.textPos.rev & (int) VD_rightToLeft ) {
		txMx[0] = - txMx[0] ;
		txMx[4] = - txMx[4] ;
	}

	__DBGpr_mat( "Text mx    ", txMx ) ;
	__DBGpr_vec( "Text point ", txPos ) ;

if( xData->library.bufsiz == 0 )
{
	sts = co$place_text(
			msg		= msg,
			ModuleInfo	= inp->drwInfo.drwEnv,
			lbs_matrix	= txMx,
			text_string	= txString,
			text_length	= &txLength,
			ActiveDisplay	= &xData->overrides.elmDisplay,
			ActiveLevel	= xData->overrides.elmLevel,
			TextSymb	= &xData->overrides.textSymb,
			origin		= txPos,
			flags		= 0,
			buffer		= &txObj ) ;

	if( sts & 1 & *msg ) {
		__DBGpr_obj( "Text", txObj ) ;
		__DBGpr_int( "Old count", outptx->count ) ;

		outptx->list	= _MALLOC( 1, struct GRid ) ;
		outptx->list[0]	= txObj ;
		outptx->count	= 1 ;
	} else {
		vd_$bulk_delete(	grids	= &txObj,
				theEnv	= inp->drwInfo.drwEnv ) ;
#ifdef vdsDEBUG
		printf( "TEXT FAILED\n");
#endif
	}
}/* for text strings */

else { /* place the cell */

        /*
        *  Get the module environment.
        */

        size = sizeof(moduleinfo);
        sts = gr$get_module_env (msg = msg,
                          sizbuf = &size,
                          buffer = &moduleinfo,
                          nret = &ret_size);
        if(!(*msg & 1)){goto wrapup;}

        /*
         * Get the active symbol and store the original name.
         */

	active_symbol.name[0]  = '\0';
        sts = gr$symget_active_symbol (msg = &ret_msg,
                        act_symbol_def = &active_symbol);
        /* TR179800965 */
        if( ret_msg == MSSUCC && active_symbol.name[0] != '\0'){
                 length = strlen( active_symbol.name ) + 1;
                 original_sy = _MALLOC( length, IGRchar );
                 strcpy(original_sy, active_symbol.name);
           }
        /*
         * Get the information about the active cell library and save the
         * active library name.
         */

	ori_file.file_name[0] = '\0';
        sts = gr$symget_asl_info (msg = msg, file = &ori_file);
        if (!( *msg & 1 )) {goto wrapup; }

        /* TR179800965 */
        if( ori_file.file_name[0] != '\0' )
        {
          length = strlen( ori_file.file_name ) + 1;
          originl_lib = _MALLOC( length, IGRchar );
          strcpy(originl_lib,ori_file.file_name);
        }

        /*
         * Retreive the cell library with the given file name.
         */

         strncpy(file.file_name,xData->library.buffer,xData->library.bufsiz);
        file.file_name[xData->library.bufsiz]='\0';

        sts = gr$symretrieve_cell_library (
                filename = file.file_name,
                file_no = &file.file_no,
                flag = EX_read_write | EX_read_only,
                file_access = &file.file_access,
                fstat = EX_old_module);
        if (sts == GR_E_NO_FILE) {
                UI_status("File Does Not Exist");
                goto wrapup;
                }
        else if (sts == GR_E_NOT_CELL_LIB) {
                UI_status("File Not A Cell Library");
                goto wrapup;
                }
                else if (sts == GR_E_NO_PREMISSION) {
                UI_status("No Permission for Operation");
                goto wrapup;
                }
            else if( !(sts & 1)){ goto wrapup;}

        /*
         * Define the given lib as active lib.
         */
        om_msg = gr$symput_asl ( msg = msg,
                     file = &file);
        if(!(om_msg & *msg & 1)) goto wrapup;

        strncpy(symbol_name,xData->textFormat.buffer,xData->textFormat.bufsiz);
        symbol_name[xData->textFormat.bufsiz]='\0';

        om_msg = gr$symsd_locate_in_all_sl ( msg = msg,
                     sd_name = symbol_name, sl_env = &sl_env,
                     sd_id = &symbol_id);
        if( *msg == MSFAIL) {
                 sprintf(s,"Symbol %s Not Defined",symbol_name);
                 UI_status(s); goto wrapup;
          }

        /*
         * Make the required cell as active.
         */

        om_msg = gr$symput_active_symbol ( msg = msg,
                     symbol_name = symbol_name, symbol_id = &symbol_id,
                     asl_env = &sl_env);
        if(!( *msg & 1)){goto wrapup;}

        /*
         * Get the active symbol.
         */

        sts = gr$symget_active_symbol (msg = msg,
               act_symbol_def = &active_symbol);
        if( *msg == MSFAIL) {goto wrapup;}

        /*
         * To Place the cell
         *  Get the active scale.
         *

        size = sizeof(struct GRdpb_scale);
        sts = gr$get_active_scale (msg = msg, sizbuf = &size,
                                buffer = &dpb_scale, nret = &ret_size);
        if(!(*msg & 1)) { goto wrapup;}

        scale[0] = dpb_scale.Active_xscale;
        scale[1] = dpb_scale.Active_yscale;
        scale[2] = dpb_scale.Active_zscale;
	this is not required as the user will specify the height(scale)*/
	
        /*
         *  Get the active angle (in radians)
         */

        size = sizeof (IGRdouble);
        sts = gr$get_active_angle (msg = msg, sizbuf = &size,
        buffer = &active_angle, nret = &ret_size);
        if (!( *msg & 1 )) {goto wrapup;}
	

        scale[0] = scale[1] = scale[2]= xData->overrides.textSymb.Active_height;
//        active_angle = (3.14/180)*(xData->overrides.textSymb.Active_width);

/* add angle, let the user change the angle-input in degrees-vini-04/12/98 */
        active_angle = (3.14/180)*(xData->overrides.textSymb.Active_width);

        sdh_id.objid = active_symbol.objid;
        sdh_id.osnum = active_symbol.symbol_env.md_id.osnum;

        /*  TR179800965 Call vd$sym_cl_place() instead of gr$sym_cl_place()
        /*  Place the cell */
	/*  ah Needed typecast in front of origin to compile */
        sts = vd$sym_cl_place (
                        msg = msg,
                        origin = (IGRpoint*)txPos,
                        angle = &active_angle,
                        scale = scale,
                        rot_matrix = txMx,
                        display = &xData->overrides.elmDisplay,
                        properties = GRIS_NEW | GRIS_DISPLAYABLE |
                                     GRIS_LOCATABLE,
                        level = &xData->overrides.elmLevel,
                        symbol_env = &sl_env,
                        target_env = inp->drwInfo.drwEnv,
                        classname = "GRclhdr",
                        sdh_id = &sdh_id,
                        cl_id = &symbol_id);
	if( sts&1&*msg )
        {
          __DBGpr_obj( "Cell", symbol_id ) ;
          __DBGpr_int( "Old count", outptx->count ) ;

          outptx->list    = _MALLOC( 1, struct GRid ) ;
          outptx->list[0] = symbol_id ;
          outptx->count   = 1 ;
        } 
        else
        {
       	  UI_status( "Cell Placement Failed" );
          vd_$bulk_delete( grids   = &symbol_id,
                           theEnv  = inp->drwInfo.drwEnv ) ;
	  goto wrapup ;
	}

        /*
         * Display the cell.
         */

        sts = gr$display_object(object_id = &symbol_id,
                        md_env = &moduleinfo,
                        mode = GRbd);
        /*
         * Make the original lib and cell active.
         */
        if(originl_lib) {
          sts = gr$symretrieve_cell_library (
                 filename = ori_file.file_name,
                 file_no = &ori_file.file_no,
                 flag = EX_read_write | EX_read_only,
                 file_access = &ori_file.file_access,
                 fstat = EX_old_module);
          om_msg = gr$symput_asl ( msg = msg, file = &ori_file);
        }

        if(original_sy){
            om_msg = gr$symsd_locate_in_all_sl ( msg = msg,
                     sd_name = original_sy, sl_env = &sl_env,
                     sd_id = &symbol_id);

            om_msg = gr$symput_active_symbol ( msg = msg,
                     symbol_name = original_sy, symbol_id = &symbol_id,
                     asl_env = &sl_env);
        }

}/* for cell */



	wrapup :
		switch( txPosHelper ) {
			case VD_useFirstCurve	:
				_FREE( cvGeom ) ;
				break ;

			case VD_useAllCurves	:			
				if( cvGeoms ) {
					for( i = 0 ; i < outpgr->count ; i++ ) {
						_FREE( cvGeoms[i] ) ;
					}
					_FREE( cvGeoms ) ;
				}
				break ;
			default			: break ;
		}
 
                _FREE( original_sy );
                _FREE( originl_lib );
		return *msg & 1 ;

} /* VD_drwCstSymbol */
/*----------------------------------------------------------------------------*/
int VD_drwGetTxOrientAndJust( msg, jPnts, txDir, txLoc, orientMx, txJust )

long			*msg ;
VD_blkJustPnts		*jPnts ;
VD_drwTxDir		txDir ;
VD_drwTxLoc		txLoc ;
IGRmatrix		orientMx ;
int			*txJust ; {


	double		*vx,
			*vy ;
	IGRvector	botToTop,
			leftToRight,
			topToBot,
			rightToLeft ;
	int		haveB2T		= FALSE,
			haveL2R		= FALSE ;

	/*
	 * CASE PARALLEL			CASE ORTHOGONAL
	 *             y                                  x
	 *             ^                                  ^
	 *             |                                  |
	 *             -> x                            y <-
	 *         x +---T----+                      +---T----+
	 *         ^ |        | -> y           y     |        | y
	 *         | L        R |              ^     L        R ^
	 *       y<- |        | v              |     |        | |
	 *           +---B----+ x              -> x  +---B----+ -> x
	 *             y                                 -> y
	 *             ^                                 |
	 *             |                                 v
	 *             -> x                              x
	 * Remember: block justification points are supposed to be in an
	 * xy-plane, hence vectors have a null z.
	 */
	MAidmx( msg, orientMx ) ;


	if( VD_center == txLoc || VD_innermost == txLoc ) {
		*txJust = CENTER_CENTER ; goto wrapup ;
	}

	if( VD_horiz == txDir ) {
		switch( txLoc ) {
			case VD_bottom	: *txJust = CENTER_TOP    ; break ;
			case VD_right	: *txJust = LEFT_CENTER   ; break ;
			case VD_top	: *txJust = CENTER_BOTTOM ; break ;
			case VD_left	: *txJust = RIGHT_CENTER  ; break ;
		}
		goto wrapup ;
	}
	if( !VD_eqPoints( jPnts->BotLeft, jPnts->TopLeft ) ) {
		BSmkvec( msg, botToTop, jPnts->BotLeft, jPnts->TopLeft  ) ;
		BSnorvec( msg, botToTop ) ;
		haveB2T = TRUE ;
	}

	if( !VD_eqPoints( jPnts->BotLeft, jPnts->BotRight ) ) {
		BSmkvec( msg, leftToRight, jPnts->BotLeft, jPnts->BotRight ) ;
		BSnorvec( msg, leftToRight ) ;
		haveL2R = TRUE ;
	}

	if( !haveB2T ) {
		if( haveL2R ) {
			botToTop[_X] = - leftToRight[_Y] ;
			botToTop[_Y] =   leftToRight[_X] ;
			botToTop[_Z] =   leftToRight[_Z] ;
		} else {
			goto wrapup ;
		}
	} else if( !haveL2R ) {
		leftToRight[_X] =   botToTop[_Y] ;
		leftToRight[_Y] = - botToTop[_X] ;
		leftToRight[_Z] =   botToTop[_Z] ;
	}

	VD_negvc( leftToRight, rightToLeft ) ;
	VD_negvc( botToTop   , topToBot    ) ;

	if( VD_para == txDir ) {
		switch( txLoc ) {
			default		:
			case VD_bottom	:
				vx = leftToRight; vy = botToTop    ;
				*txJust = CENTER_TOP   ; break ;
			case VD_right	:
				vx = topToBot	; vy = leftToRight ;
				*txJust = CENTER_BOTTOM; break ;
			case VD_top	:
				vx = leftToRight; vy = botToTop    ;
				*txJust = CENTER_BOTTOM; break ;
			case VD_left	: 
				vx = botToTop	; vy = rightToLeft ;
				*txJust = CENTER_BOTTOM; break ;
		}
	} else /* VD_ortho */ {
		switch( txLoc ) {
			case VD_1stEnd	:
			default		:
			case VD_bottom	:
				vx = topToBot	; vy = leftToRight ;
				*txJust = LEFT_CENTER  ; break ;
			case VD_right	:
				vx = leftToRight; vy = botToTop	   ;
				*txJust = LEFT_CENTER  ; break ;
			case VD_2ndEnd	:
			case VD_top	:
				vx = botToTop	; vy = rightToLeft ;
				*txJust = LEFT_CENTER  ; break ;
			case VD_left	:
				vx = leftToRight; vy = botToTop	   ;
				*txJust = RIGHT_CENTER ; break ;
				
		}
	}

	orientMx[0] = vx[_X] ; orientMx[4] = vx[_Y] ;
	orientMx[1] = vy[_X] ; orientMx[5] = vy[_Y] ;

	wrapup :
		*msg = MSSUCC ;
		return 1 ;

} /* VD_drwGetTxOrientAndJust */
/*----------------------------------------------------------------------------*/
int VD_drwGetEndTxOrientAndJust( msg, endTan, cvDirType, txDir, txLoc,
				orientMx, txJust )

long			*msg ;
IGRvector		endTan ;
VD_directionType		cvDirType ;
VD_drwTxDir		txDir ;
VD_drwTxLoc		txLoc ;
IGRmatrix		orientMx ;
int			*txJust ; {

	/*
	 * Vertical curve		Horizontal curve
	 * PARALLEL
	 *      x->y
	 *      |
	 *      v
	 *      +		    y  		  y
	 *      |                   ^  		  ^
	 *      |		   x|-> +--------+|->x
	 *      |                       
	 *      +                       
	 *      ->y
	 *      |
	 *      v
	 *      x
	 * ORTHOGONAL
	 *      ^y
	 *      |
	 *      ->x
	 *      +		     x
	 *      |                    ^
	 *      |		  y<-|  +--------+|->y
	 *      |                                 v
	 *      +                                 x
	 *      ^y
	 *      |
	 *      ->x
	 *
	 * In all cases x = input endTan (supposed to point away from curve
	 * and be normalized).
	 */
	IGRvector	xTx,
			yTx ;

	MAidmx( msg, orientMx ) ;
	VD_vccpy( xTx, endTan ) ;

	if( VD_para == txDir ) {
		switch( cvDirType ) {

		default			:
		case VD_horizontal	:
			switch( txLoc ) {
				default	      :
				case VD_1stEnd : /* Leftmost  point	*/
					xTx[_X] = - endTan[_X] ;
					xTx[_Y] = - endTan[_Y] ;
					yTx[_X] = - endTan[_Y] ;
					yTx[_Y] =   endTan[_X] ;
					*txJust = LEFT_CENTER ;
					break ;
				case VD_2ndEnd : /* Rightmost point	*/
					yTx[_X] = - endTan[_Y] ;
					yTx[_Y] =   endTan[_X] ;
					*txJust = LEFT_CENTER ;
					break ;
			}
			break ;
		case VD_vertical		:
			switch( txLoc ) {
				default	      :
				case VD_1stEnd : /* Uppermost point	*/
					xTx[_X] = - endTan[_X] ;
					xTx[_Y] = - endTan[_Y] ;
					yTx[_X] = - endTan[_Y] ;
					yTx[_Y] =   endTan[_X] ;
					*txJust = LEFT_CENTER ;
					break ;
				case VD_2ndEnd : /* Lowermost point	*/
					yTx[_X] = - endTan[_Y] ;
					yTx[_Y] =   endTan[_X] ;
					*txJust = LEFT_CENTER ;
					break ;
			}
			break ;
		}
	} else /* VD_ortho */ {
		switch( cvDirType ) {
			default			:
			case VD_horizontal	:
			switch( txLoc ) {
				case VD_1stEnd : /* Leftmost  point	*/
					xTx[_X] =   endTan[_Y] ;
					xTx[_Y] = - endTan[_X] ;
					yTx[_X] =   endTan[_X] ;
					yTx[_Y] =   endTan[_Y] ;
					*txJust = CENTER_BOTTOM ;
					break ;
				case VD_2ndEnd : /* Rightmost point	*/
					xTx[_X] = - endTan[_Y] ;
					xTx[_Y] =   endTan[_X] ;
					yTx[_X] =   endTan[_X] ;
					yTx[_Y] =   endTan[_Y] ;
					*txJust = CENTER_BOTTOM ;
					break ;
			}
			break ;
		case VD_vertical		:
			switch( txLoc ) {
				default	      :
				case VD_1stEnd : /* Uppermost point	*/
					xTx[_X] =   endTan[_Y] ;
					xTx[_Y] = - endTan[_X] ;
					yTx[_X] =   endTan[_X] ;
					yTx[_Y] =   endTan[_Y] ;
					*txJust = CENTER_BOTTOM ;
					break ;
				case VD_2ndEnd : /* Lowermost point	*/
					xTx[_X] = - endTan[_Y] ;
					xTx[_Y] =   endTan[_X] ;
					yTx[_X] = - endTan[_X] ;
					yTx[_Y] = - endTan[_Y] ;
					*txJust = CENTER_BOTTOM ;
					break ;
			}
			break ;
		}
	}

	orientMx[0] = xTx[_X] ; orientMx[4] = xTx[_Y] ;
	orientMx[1] = yTx[_X] ; orientMx[5] = yTx[_Y] ;

	*msg = MSSUCC ;

	return *msg & 1 ;
	
} /* VD_drwGetEndTxOrientAndJust */
/*----------------------------------------------------------------------------*/
int VD_drwGetMidTxOrientAndJust( msg, midTan, cvDirType, txDir,
				orientMx, txJust )

long			*msg ;
IGRvector		midTan ;
VD_directionType		cvDirType ;
VD_drwTxDir		txDir ;
IGRmatrix		orientMx ;
int			*txJust ; {

	/*
	 * Vertical curve		Horizontal curve
	 * PARALLEL			PARALLEL
	 *
	 *      +			    y
	 *    x |			    ^
	 *    ^ |		            |
	 * y<-| m                           -> x
	 *      |			+---m---+
	 *      |
	 *      +
	 * ORTHOGONAL			ORTHOGONAL
	 *
	 *      +			    x
	 *      | y			    ^
	 *      | ^		            |
	 *      m |-> x                  y <-
	 *      |			+---m---+
	 *      |
	 *      +
	 *
	 * In all cases x = input midTan (supposed to point away from curve
	 * and be normalized).
	 */
	IGRvector	xTx,
			yTx ;

	MAidmx( msg, orientMx ) ;

	switch( cvDirType ) {
		default			:
		case VD_horizontal	:

			switch( txDir ) {
				default		:
				case VD_horiz	:
					*txJust = CENTER_CENTER ;
					break ;
				case VD_para	:
					if( midTan[_X] >= 0 ) { 
						xTx[_X] = midTan[_X] ;
						xTx[_Y] = midTan[_Y] ;
					} else {
						xTx[_X] = - midTan[_X] ;
						xTx[_Y] = - midTan[_Y] ;
					}
					yTx[_X] = - xTx[_Y] ;
					yTx[_Y] =   xTx[_X] ;
					*txJust = CENTER_CENTER ;
					break ;
				case VD_ortho	:
					if( midTan[_X] < 0 ) { 
						yTx[_X] = midTan[_X] ;
						yTx[_Y] = midTan[_Y] ;
					} else {
/* ALAIN */
						if( midTan[_Y] >= 0 ) {
							yTx[_X] = midTan[_X] ;
							yTx[_Y] = midTan[_Y] ;
						} else {
/* ALAIN */
							yTx[_X] = - midTan[_X] ;
							yTx[_Y] = - midTan[_Y] ;
/* ALAIN */
						}
/* ALAIN */
					}
					xTx[_X] =   yTx[_Y] ;
					xTx[_Y] = - yTx[_X] ;
					*txJust = CENTER_CENTER ;
					break ;
			}
			break ;
		case VD_vertical		:
			switch( txDir ) {
				default	      	:
				case VD_horiz	:
					*txJust = CENTER_CENTER ;
					break ;
				case VD_para	:
					if( midTan[_X] >= 0 ) { 
						xTx[_X] = midTan[_X] ;
						xTx[_Y] = midTan[_Y] ;
					} else {
						xTx[_X] = - midTan[_X] ;
						xTx[_Y] = - midTan[_Y] ;
					}
					yTx[_X] = - xTx[_Y] ;
					yTx[_Y] =   xTx[_X] ;
					*txJust = CENTER_CENTER ;
					break ;
				case VD_ortho	:
					if( midTan[_X] >= 0 ) { 
						yTx[_X] = midTan[_X] ;
						yTx[_Y] = midTan[_Y] ;
					} else {
/* ALAIN */
						if( midTan[_Y] >= 0 ) {
							yTx[_X] = midTan[_X] ;
							yTx[_Y] = midTan[_Y] ;
						} else {
/* ALAIN */
							yTx[_X] = - midTan[_X] ;
							yTx[_Y] = - midTan[_Y] ;
/* ALAIN */
						}
/* ALAIN */
					}
					xTx[_X] =   yTx[_Y] ;
					xTx[_Y] = - yTx[_X] ;
					*txJust = CENTER_CENTER ;
					break ;
			}
			break ;
	}

	if( txDir != VD_horiz ) {
		orientMx[0] = xTx[_X] ; orientMx[4] = xTx[_Y] ;
		orientMx[1] = yTx[_X] ; orientMx[5] = yTx[_Y] ;
	}

	*msg = MSSUCC ;

	return *msg & 1 ;
	
} /* VD_drwGetMidTxOrientAndJust */
/*----------------------------------------------------------------------------*/
