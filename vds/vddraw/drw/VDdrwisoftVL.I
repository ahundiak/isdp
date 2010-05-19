/* $Id: VDdrwisoftVL.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:        vddraw/drw/VDdrwisoftVL.I
 *
 * Description: Simulation of the I/LOFT object for the first part of the
 * 		drawing extraction. The symbol of the yacc file need to be
 *		recognized to setup the macro and attribute list.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwisoftVL.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/28  19:46:44  pinnacle
# Replaced: vddraw/drw/VDdrwisoftVL.I for:  by rchennup for vds
#
# Revision 1.1  1997/10/28  15:58:12  pinnacle
# Created: vddraw/drw/VDdrwisoftVL.I by rchennup for vds
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *************************************************************************/

class implementation VDSroot ;

#include <string.h>
#include <stdio.h>
#include "v_drwapi.h"

/*
 * Includes for function prototypes.
 */
#include "v_drwproto.h"

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, marking ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "Mark" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( marking ) */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, roll ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "RolLn" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( roll ) */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, control ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "CntrLine" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( control ) */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, butt ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "*Butt*" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( butt ) */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, seam ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "*Seam*" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( seam ) */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, water ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "WatLine" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( water ) */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, trace ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "VLtrace" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( trace ) */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, unwrap ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "unwrap" ) ;

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( unwrap ) */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, stock ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "stock-line" ) ;

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( stock ) */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, min_rec ) {

        if( DRW_wantFilter ) strcpy( DRW_elmFilter, "min-rec" ) ;

        if( DRW_wantView ) {
            DRW_elmView = VD_anyViewType ;
        }

} /* ISOFTYPE( minimal-rectangle ) */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
