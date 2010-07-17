/* $Id: VLdrwfcnsupp.I,v 1.3 2001/02/20 01:07:11 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLdrwfcnsupp.I
 *
 * Description: STRUDEL function implementation.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLdrwfcnsupp.I,v $
 *      Revision 1.3  2001/02/20 01:07:11  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/07 01:21:42  ramarao
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:43  cvs
 *      Initial import to CVS
 *
# Revision 1.4  2000/03/07  22:21:04  pinnacle
# (No comment)
#
# Revision 1.3  2000/02/14  23:13:00  pinnacle
# (No comment)
#
# Revision 1.2  2000/02/07  15:51:46  pinnacle
# Get the Correct side of the plate to be unwrapped.
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/10/28  15:32:12  pinnacle
# Created: src/unwext/VLdrwfcnsupp.I by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *      02/07/00   Rama Rao     Get the correct side of the plate to be unwrapped
 *		General messing to test CVS - Anand
 *************************************************************************/

class implementation VDSroot;

#include <stdio.h>
#include <string.h>
#include "nddef.h"
#include "exmacros.h"
#include "vddrwattr.h"
#include "v_drw.h"
#include "v_drwapi.h"
#include "v_drwproto.h"
#include "v_slcdef.h"
#include "v_miscmacros.h"
#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "vlmsg.h"
#include "vlstructure.h"
#include "vlunfold.h"
#include "vldbgmacros.h"

from  VLunwFeat		import 	VLgetUnw_obj;
from  VLmrkLine		import	WhichSide;

#define vdsDEBUG      1
#define vdserrDEBUG   1

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_FUNCTION( VD, is_marking_hidden ) {

        long    		sts, msg ;
	int			is_baseunwrap, which_side, is_basemark;
	struct GRid		FeatObj, UnwObj;
	struct unw_obj_plat 	dev;
	VDpartAttr              attr ;
        const char      	*type = xData->parsedElmDesc ;

	SetProc( VD_drwFUNCTIONis_marking_hidden ); Begin

        res->type  = VD_int ;
        res->_ival = 0 ;

        CHECK_ARGCOUNT( 0 )
        if( strcmp( type, "marking-line" ) ) {
             XFERR( "!!! %s(): argument is not a marking line\n", function ) ;
             End
             return xfINVARG ;
        }

	sts = VDchk_child_on_class(   &msg,
                                      inp->elmId,
                                      inp->elmId,
                                      "VLunwFeat",
                                      &FeatObj );
	__CheckRC( sts, msg, "VDchk_child_on_class", wrapup );

        sts = _VD_SEND_OBJN( FeatObj, VLunwFeat.VLgetUnw_obj( &msg, &UnwObj ));
	__CheckRC( sts, msg, "VLunwFeat.VLgetUnw_obj", wrapup );

        attr.Iwant = VL_I_getOpts ;
        attr.specific = (void *) &dev ;
        sts = _VD_SEND_OBJN( UnwObj, GRvg.GRgetattr( &msg, (char *)&attr ));
        __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

	sts = _VD_SEND_OBJN( *(inp->elmId), VLmrkLine.WhichSide( &which_side) );
	__CheckRC( sts, msg, "VLmrkLine.WhichSide", wrapup );

	if( which_side == VS_K_baOnBotOfPlate )  is_basemark = TRUE;
	else					 is_basemark = FALSE;

        if( sts & 1 & msg ) {
/*
		if( dev.side_of_plate == MAX_MARK)
		{
                   struct GRid      root;  
                   struct GRobj_env plate;
		   char             word[50];
		   int		    count;

                   sts = _VD_SEND_OBJN( UnwObj, NDnode.NDget_objects( ND_ROOT,
                                &root, 1, NULL, 0, 0, &count ));
                   __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

                   sts = _VD_SEND_OBJN( root, NDmacro.ACreturn_foot(
                                        &msg, "", &plate.obj_id,
                                        &plate._matrix_type,
                                        plate._matrix           ) );
                   __CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup );
                   __DBGpr_obj( " Original Plate in model ", plate.obj_id );
                   plate._md_os = plate.obj_id.osnum;
                   ex$get_modid(   mod_osnum = plate._md_os,
                	           mod_id    = &plate._md_id ) ;
          	   VLget_side_w_more_mrkln(&plate, word);
		   if( !strcmp( word, VS_K_plBotSfPath) ) is_baseunwrap = TRUE;
		   else					  is_baseunwrap = FALSE;
		}
		else 
*/
		if(dev.side_of_plate == BASE_SIDE || 
			dev.side_of_plate == BASE_FLIP ) is_baseunwrap = TRUE;
		else is_baseunwrap = FALSE;

                res->_ival = (is_baseunwrap==is_basemark) ? 0 : 1 ;

		End
                return xfSUCCESS ;
        }
wrapup:
	End
        return xfFAILURE ;

} /* VSdrwFUNCTIONis_beam_hidden */

end implementation VDSroot;
