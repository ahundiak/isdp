/* $Id: VDdrwisoftVS.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwisoftVS.I
 *
 * Description:
 *	Functions to implement STRUCT elementTypes
 *	See description in VDdrwisotyp.I
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwisoftVS.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/03/15  20:40:30  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/08/16  14:49:14  pinnacle
# Replaced: vddraw/drw/VDdrwisoftVS.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/03/31  10:52:22  pinnacle
# Replace: by tlbriggs for OPE
#
 *
 * History:
 *
 *	3/20/95		tlb	Add GraType support
 *	8/15/95		adz	Changed ViewType calls.
 *      03/15/00        Ming    For TR179901203. Added "structure" which covers
 *                              beam, stiffener and plate.
 *
 *************************************************************************/

/*
	I/VDS

	Simulation of the I/STRUCT object for the first part of the
	drawing extraction. The symbol of the yacc file need to be
	recognized to setup the macro and attribute list.
*/

class implementation VDSroot ;

#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "gotextdef.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "v_slcdef.h"
#include "v_slc.h"
#include "v_drwdef.h"
#include "v_drwapi.h"
#include "VDdrwgrammar.h"
#include "v_globalmsg.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*
 * Includes for function prototypes.
 */
#include "v_drwproto.h"

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, beam ) {

	SetProc( ISOFTYPE_equipment ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "VS*Beam" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ){	
          long msg ;
          if( !( 1 & VD_drwGetViewTypeFromSTRUCT( &msg, inp, xData ) ) )
            DRW_elmView = VD_unknownViewType ;
	}

	End

} /* ISOFTYPE( beam ) */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, stiffener ) {

	SetProc( ISOFTYPE_stiffener ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "VS*Beam" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ){
          long msg ;
          if( !( 1 & VD_drwGetViewTypeFromSTRUCT( &msg, inp, xData ) ) )
            DRW_elmView = VD_unknownViewType ;
	}

	End

} /* ISOFTYPE( stiffener ) */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, plate ) {

	SetProc( ISOFTYPE_plate ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "VS*Plate" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ){
	  long msg ;
          if( !( 1 & VD_drwGetViewTypeFromSTRUCT( &msg, inp, xData ) ) )
            DRW_elmView = VD_unknownViewType ;
        }
	End

} /* ISOFTYPE( plate ) */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, structure ) {

        SetProc( ISOFTYPE_structure ); Begin

        if( DRW_wantFilter )    strcpy( DRW_elmFilter, "VS*Beam|VS*Plate" ) ;

        if( DRW_wantType ){     VD_drwGetMacroType( inp, xData );       }

        if( DRW_wantGraType ){  VD_drwNoGraType( inp, xData );          }

        if( DRW_wantView ){
          long msg ;
          if( !( 1 & VD_drwGetViewTypeFromSTRUCT( &msg, inp, xData ) ) )
            DRW_elmView = VD_unknownViewType ;
        }

        End

} /* ISOFTYPE( structure ) */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, joint ) {

	SetProc( ISOFTYPE_joint ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "VS*Joint" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ){
	  long msg ;
          if( !( 1 & VD_drwGetViewTypeFromSTRUCT( &msg, inp, xData ) ) )
            DRW_elmView = VD_unknownViewType ;
	}

	End

} /* ISOFTYPE( joint ) */

/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
