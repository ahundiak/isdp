/* $Id: VDdrwisoftVR.I,v 1.2 2001/02/20 19:50:23 build Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwisoftVR.I
 *
 * Description:
 *	Functions to implement STRUCT ROUTE
 *	See description in VDdrwisotyp.I
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwisoftVR.I,v $
 *	Revision 1.2  2001/02/20 19:50:23  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/09/24  17:25:58  pinnacle
# Replaced: vddraw/drw/VDdrwisoftVR.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/11/30  20:40:24  pinnacle
# Replaced: vddraw/drw/VDdrwisoftVR.I for:  by tlbriggs for vds.240
#
# Revision 1.3  1995/08/16  14:48:44  pinnacle
# Replaced: vddraw/drw/VDdrwisoftVR.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/03/31  10:52:22  pinnacle
# Replace: by tlbriggs for OPE
#
 *
 * History:
 *
 *	3/20/95		tlb	Add GraType support
 *	8/15/95		adz	Changed viewType calls to direct default.
 *				Delete the *_comp objects names.
 *	11/20/95	tlb	Add nozzle keyword
 *	02/20/01	adz	Change Nozzle macro as dummy. (to avoid 
 *				clashing against hvac, piping, rway).
 *
 *************************************************************************/

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
IMPLEMENT_ISOFTYPE( VD, pipe ) {

	SetProc( ISOFTYPE_pipe ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "PPc*def" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetMacroGraType( inp, xData );	}

        if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( pipe ) */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, hvac ) {

	SetProc( ISOFTYPE_hvac ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "HVc*def" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

        if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( hvac ) */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, rway ) {

	SetProc( ISOFTYPE_rway ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "RWc*def" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetMacroGraType( inp, xData );	}

        if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( rway ) */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, r_equipment ) {

	SetProc( ISOFTYPE_r_equipment ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "VDequidef" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetMacroGraType( inp, xData );	}

        if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( r_equipment ) */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, nozzle ) {

	SetProc( ISOFTYPE_nozzle ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "ISDP_nozzle" ) ;

        if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetMacroGraType( inp, xData );	}

        if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( nozzle ) */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, cable ) {

        SetProc( ISOFTYPE_cable ); Begin

        if( DRW_wantFilter )    strcpy( DRW_elmFilter, "VCCableDef" ) ;

        if( DRW_wantType ){     VD_drwGetMacroType( inp, xData );       }

        if( DRW_wantGraType ){  VD_drwGetMacroGraType( inp, xData );    }

        if( DRW_wantView ){     DRW_elmView = VD_unknownViewType ;      }

        End

} /* ISOFTYPE( cable ) */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, guide ) {


        SetProc( ISOFTYPE_guide ); Begin

        if( DRW_wantFilter )    strcpy( DRW_elmFilter, "VCGuideDef" ) ;

        if( DRW_wantType ){     VD_drwGetMacroType( inp, xData );       }

        if( DRW_wantGraType ){  VD_drwGetMacroGraType( inp, xData );    }

        if( DRW_wantView ){     DRW_elmView = VD_unknownViewType ;      }

        End

} /* ISOFTYPE( guide ) */

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, terminal ) {

        SetProc( ISOFTYPE_terminal ); Begin

        if( DRW_wantFilter )    strcpy( DRW_elmFilter, "VCTermDef" ) ;

        if( DRW_wantType ){     VD_drwGetMacroType( inp, xData );       }

        if( DRW_wantGraType ){  VD_drwGetMacroGraType( inp, xData );    }

        if( DRW_wantView ){     DRW_elmView = VD_unknownViewType ;      }

        End

} /* ISOFTYPE( terminal ) */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, connect_comp ) {

        SetProc( ISOFTYPE_connect_comp ); Begin

        if( DRW_wantFilter )    strcpy( DRW_elmFilter, "VCBkshdef" ) ;

        if( DRW_wantType ){     VD_drwGetMacroType( inp, xData );       }

        if( DRW_wantGraType ){  VD_drwGetMacroGraType( inp, xData );    }

        if( DRW_wantView ){     DRW_elmView = VD_unknownViewType ;      }

        End

} /* ISOFTYPE( connect_comp ) */

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, back_shell ) {

        SetProc( ISOFTYPE_back_shell ); Begin

        if( DRW_wantFilter )    strcpy( DRW_elmFilter, "VCBkshdef" ) ;

        if( DRW_wantType ){     VD_drwGetMacroType( inp, xData );       }

        if( DRW_wantGraType ){  VD_drwGetMacroGraType( inp, xData );    }

        if( DRW_wantView ){     DRW_elmView = VD_unknownViewType ;      }

        End

} /* ISOFTYPE( back_shell ) */

/*----------------------------------------------------------------------------*/

end implementation VDSroot;

