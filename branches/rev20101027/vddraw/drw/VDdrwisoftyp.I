/* $Id: VDdrwisoftyp.I,v 1.2 2001/01/19 21:09:00 ramarao Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwisoftyp.I
 *
 * Description:
 *	Functions to implement elementTypes
 *
 *	Each IMPLEMENT_ISOFTYPE function must provide 3 cases:
 *		DRW_wantFilter 		return filter macro name
 *					  preprocess value used for locate
 *					  process value used to match with
 *						object macro name in parser 
 *		DRW_wantType 		return object macro name, DRW_elmType
 *		DRW_wantGraType 	return obj graphics name, DRW_elmType
 *		DRW_wantView		return object draing view 
 * 
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwisoftyp.I,v $
 *	Revision 1.2  2001/01/19 21:09:00  ramarao
 *	Merged from SP.
 *	
# Revision 1.7  2000/08/25  04:10:02  pinnacle
# Replaced: vds/vddraw/drw/VDdrwisoftyp.I for:  by mdong for Service Pack
#
# Revision 1.6  2000/07/25  13:36:12  pinnacle
# Replaced: vds/vddraw/drw/VDdrwisoftyp.I for:  by mdong for Service Pack
#
# Revision 1.5  2000/07/24  22:04:04  pinnacle
# Replaced: vds/vddraw/drw/VDdrwisoftyp.I for:  by mdong for Service Pack
#
# Revision 1.4  2000/07/24  21:56:08  pinnacle
# Replaced: vds/vddraw/drw/VDdrwisoftyp.I for:  by mdong for Service Pack
#
# Revision 1.3  2000/07/24  18:38:24  pinnacle
# Replaced: vds/vddraw/drw/VDdrwisoftyp.I for:  by mdong for Service Pack
#
# Revision 1.2  2000/07/21  15:20:42  pinnacle
# Replaced: vds/vddraw/drw/VDdrwisoftyp.I for:  by mdong for Service Pack
#
# Revision 1.1  2000/07/21  02:29:24  pinnacle
# Created: vds/vddraw/drw/VDdrwisoftyp.I by mdong for Service Pack
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
# Revision 1.13  1995/09/29  19:50:02  pinnacle
# Replaced: ./vddraw/drw/VDdrwisoftyp.I for:  by azuurhou for vds.240
#
# Revision 1.12  1995/09/28  12:50:14  pinnacle
# Replaced: ./vddraw/drw/VDdrwisoftyp.I for:  by azuurhou for vds.240
#
# Revision 1.11  1995/08/17  22:53:20  pinnacle
# Replaced: vddraw/drw/VDdrwisoftyp.I for:  by azuurhou for vds.240
#
# Revision 1.9  1995/06/27  18:30:30  pinnacle
# Replaced: vddraw/drw/VDdrwisoftyp.I for:  by azuurhou for vds.240
#
# Revision 1.8  1995/05/26  12:57:10  pinnacle
# Replace: by tlbriggs for OPE
#
# Revision 1.7  1995/05/11  19:12:30  pinnacle
# Replace: by tlbriggs for OPE
#
# Revision 1.6  1995/05/01  21:28:50  pinnacle
# Replaced: vddraw/drw/VDdrwisoftyp.I by jwfrosch r#
#
# Revision 1.5  1995/03/31  10:52:22  pinnacle
# Replace: by tlbriggs for OPE
#
 *
 * History:
 *
 *	3/15/95		tlb	Add function for all, macro
 *
 *	3/20/95		tlb	Add function, support for cell
 *				Make VD_drwGetMacroType 
 *				Add GraType support
 *
 *	5/1/95		jwf	Add mirrored copy macro case
 *
 *	5/9/95		tlb	Add function, support for "sym"
 *				Add GetGRhdrType, GetGRhdrGraType
 *				Fix macro function - call GetMacroType
 *				Use VD_drwGet*Info functions
 *
 *	5/24/95		tlb	"All" case - support graphic name
 *				"Macro" case - use macro name for graphic name
 *
 *	8/15/95		adz	Changed ViewType Settings.
 *	9/27/95		adz	ACcpx returns "Unknown" when macro is missing.
 *	9/29/95		adz	All -> Macros + Cells + Symbols.
 *	07/20/00	Ming    Added "stage" which covers all stage nodes.
 *	07/24/00	Ming    Added "Macro" which covers ACconst objects.
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

extern OMuword OPP_ACconst_class_id ;
extern OMuword OPP_ACcpx_class_id ;
extern OMuword OPP_VDdrw3d_class_id ;
extern OMuword OPP_VDSroot_class_id ;
extern OMuword OPP_GRclhdr_class_id ;
extern OMuword OPP_GRsmhdr_class_id ;

from ACcpx_defn		import 	ACgive_name ;

/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, equipment ) {

	SetProc( ISOFTYPE_equipment ); Begin
	__DBGpr_int ("\tQuery", query);

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "VDequidef" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetMacroGraType( inp, xData );	}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( equipment ) */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, compartment ) {

	SetProc( ISOFTYPE_compartment ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMcomp" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( compartment ) */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, struct_surf ) {

	SetProc( ISOTYPE_struct_surf ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMMainSf" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( struct_surf ) */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, split_surf ) {

	SetProc( ISOTYPE_split_surf ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMSpltSrf" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ) {	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( split_surf ) */
/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, bound_surf ) {

	SetProc( ISOTYPE_bound_surf ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMSfBnd" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( bound_surf ) */
/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, split_volume ) {

	SetProc( ISOTYPE_split_volume ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMVolBySplt" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( split_volume ) */

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, limit_volume ) {

	SetProc( ISOTYPE_limit_volume ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMLtdVol" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( limit_volume ) */

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, profile_volume ) {

	SetProc( ISOTYPE_profile_volume ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMSketchVol" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( profile_volume ) */

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, section ) {

	SetProc( ISOTYPE_section ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMSection" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( section ) */

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, inf_plane ) {

	SetProc( ISOTYPE_inf_plane ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMInfPlane" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( inf_plane ) */

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, plane_system ) {

	SetProc( ISOTYPE_plane_system ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMFrameSys" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( plane_system ) */

/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, perpendicular ) {

	SetProc( ISOTYPE_perpendicular ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "SMPerp" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( perpendicular ) */

/*----------------------------------------------------------------------------*/
/* Macro
 *	Matches any Vds model object  - child of ACcpx
 */

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, macro ) {

	SetProc( ISOTYPE_macro ); Begin
	__DBGpr_int ("\tQuery", query);

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "*" ) ;

	if( DRW_wantType  ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End
	return;


} /* ISOFTYPE( macro ) */
/*----------------------------------------------------------------------------*/
/* All
 *	Matches any Vds model object + Cells and symbol
 */
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, all ) {

	/* matches any macro name which is subclass of VDdrw_Sect or ACcpx 
	 */

	SetProc( ISOFTYPE_all ); Begin
	__DBGpr_int ("\tQuery", query);

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "*|Cell|Symbol" ) ;

	if( DRW_wantType ){
		VD_drwGetMacroType( inp, xData );
		if (!DRW_elmType) 
			VD_drwGetGRhdrType( inp, xData );
	}

	if( DRW_wantGraType ) {
		VD_drwGetMacroType( inp, xData );
		if (!DRW_elmType) 
			VD_drwGetGRhdrType( inp, xData );
	}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( all ) */
/*----------------------------------------------------------------------------*/
/* Cell - 
 *	Matches any object of class GRclhdr
 */

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, cell ) {

	SetProc( ISOTYPE_cell ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "Cell" ) ;

	if( DRW_wantType ){	VD_drwGetGRhdrType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetGRhdrGraType( inp, xData );	}

	if( DRW_wantView )	DRW_elmView = VD_unknownViewType ;

	End
}
/*----------------------------------------------------------------------------*/
/* Symbol - 
 *	Matches any object of class GRsmhdr
 */

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, sym ) {

	SetProc( ISOTYPE_sym ); Begin

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "Symbol" ) ;

	if( DRW_wantType ){	VD_drwGetGRhdrType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetGRhdrGraType( inp, xData );	}

	if( DRW_wantView )	DRW_elmView = VD_unknownViewType ;

	End
}
/*----------------------------------------------------------------------------*/
/* Const
 *	treated seperately in parser - filter not required 
 */

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, const ) {

	/*
	 * Do not set filter here, it is read from the 'const' statement.
	 */

	SetProc( ISOTYPE_const ); Begin

	if( DRW_wantType ) {
		VD_drwGetConstType( inp, xData ); 

		/*  
		 * shouldn't this really be to pick equip, piping etc:
		 *	VD_drwGetMacroType( inp, xData ); 
		 */
	}

	/* This should never be called */
	if( DRW_wantGraType ){	VD_drwNoGraType( inp, xData );		}

	if( DRW_wantView ) {
	  	long msg ;
	  	if( !( 1 & VD_drwGetViewTypeFromConst( &msg, inp, xData ) ) )
	    		DRW_elmView = VD_unknownViewType ;
	}

	End
	return;

} /* ISOFTYPE( const ) */
/*----------------------------------------------------------------------------*/
/* VD_drwGetMacroType
 *	Return object macro name in inp->constDefName	
 *		VDdrw_Sect object	return model macro name 
 *		ACcpx child		return macro name
 *		other			return ""
 *	Set DRW_elmType 
 *		VD_gI_InAsbly		VDdrw_Sect obj  or ACcpx child
 *		0			other			
 */
void
VD_drwGetMacroType( 
	VD_drwInputData			*inp ,
	VD_drwExecData			*xData 
	)
{
	inp->constDefName[0] ='\0';

	/*  
	 * Section cut object
	 */
	if( vd_$is_ancestry_valid(	object	= DRW_elmId,
					classid	= OPP_VDdrw3d_class_id ) ) 

		VD_drwGetSectInfo (inp->elmId, inp->constDefName, TRUE);
		
	/* 
	 * ACcpx child class 
 	 */
	else if (vd_$is_ancestry_valid(	object	= DRW_elmId,
					classid	= OPP_ACcpx_class_id ) ){

		if( ! (VD_drwGetACcpxInfo(	inp->elmId,
						inp->constDefName,
						TRUE ))){
			strcpy( inp->constDefName, "Unknown" );
		}

	}

	/* explicitly reject any Cell or symbol */
	if (!strcmp(inp->constDefName, "Cell") ||
	    !strcmp(inp->constDefName, "Symbol") )
		inp->constDefName[0] = '\0';

	DRW_elmType = (*inp->constDefName) ? VD_gI_InAsbly : 0;
	return;
}
/*----------------------------------------------------------------------------*/
/* VD_drwGetGRhdrType
 *	Return GR hdr macro name in inp->constDefName	
 *		cell object		return model macro name 
 *		other			return ""
 *	Set DRW_elmType 
 *		VD_gI_InAsbly		VDdrw_Sect obj  or ACcpx child
 *		0			other			
 */
void
VD_drwGetGRhdrType( 
	VD_drwInputData			*inp ,
	VD_drwExecData			*xData 
	)
{
	inp->constDefName[0] ='\0';
    	if( vd_$is_ancestry_valid(	object	= DRW_elmId,
					classid	= OPP_GRclhdr_class_id ) ||
	    vd_$is_ancestry_valid(	object	= DRW_elmId,
					classid	= OPP_GRsmhdr_class_id )) 

		VD_drwGetGRhdrInfo (inp->elmId, inp->constDefName, TRUE);

	DRW_elmType = (*inp->constDefName) ? VD_gI_InAsbly : 0;
}
/*----------------------------------------------------------------------------*/
/* VD_drwGetConstType
 *	Return const macro name in inp->constDefName	
 *		const object		return model macro name 
 *		other			return ""
 *	Set DRW_elmType 
 *		VD_gI_InAsbly		const
 *		0			other			
 */
void
VD_drwGetConstType( 
	VD_drwInputData			*inp ,
	VD_drwExecData			*xData 
	)
{
	long		sts ;
	struct GRid	macroDef ;
	char		*macName ;

	if( vd_$is_ancestry_valid(	object	= DRW_elmId,
					classid	= OPP_ACconst_class_id ) ) {

		/*
		 * Since it's a const, get the macro definition name.
		 */
		sts = om$send(	msg	= message ACcpx.find_macro( &macroDef ),
				senderid= DRW_elmId->objid,
				targetid= DRW_elmId->objid,
				targetos= DRW_elmId->osnum ) ;
		__CheckRC( sts, 1, "ACcpx.find_macro", none ) ;
	
		sts = om$send(	msg	= message ACcpx_defn.ACgive_name(
								&macName ),
				senderid= macroDef.objid,
				targetid= macroDef.objid,
				targetos= macroDef.osnum ) ;
		__CheckRC( sts, 1, " ACcpx_defn.ACgive_name", none ) ;
	
		strcpy( inp->constDefName, macName ) ;
		DRW_elmType = VD_gI_InAsbly ;

		return;
  		}
none:
	inp->constDefName[0] ='\0';
	DRW_elmType = 0 ;
}

/*----------------------------------------------------------------------------*/
/* VD_drwNoGraType
 *	Macro has no graphics type name
 */
void
VD_drwNoGraType( 
	VD_drwInputData			*inp ,
	VD_drwExecData			*xData 
	)
{
	inp->constDefName[0] ='\0';
	DRW_elmType = 0 ;
}
/*----------------------------------------------------------------------------*/
/* VD_drwGetMacroGraType
 *	Get graphics name for VDS equipment and route coponents
 */
void
VD_drwGetMacroGraType(
	VD_drwInputData			*inp ,
	VD_drwExecData			*xData 
	)
{
	long			sts, rc ;
	GRname			graName ;

	graName[0] = '\0';
	sts = om$send(	msg= message VDSroot.VDGetGraphMac(
						&rc, graName),
				senderid= DRW_elmId->objid,
				targetid= DRW_elmId->objid,
				targetos= DRW_elmId->osnum ) ;
	__CheckRC( sts, rc, "VDGetGraphMac", none) ;

	strcpy( inp->constDefName, graName ) ;
	DRW_elmType = VD_gI_InAsbly ;
	return;
none:
	inp->constDefName[0] ='\0';
	DRW_elmType = 0 ;
}
/*----------------------------------------------------------------------------*/
/* VD_drwGetGRhdrGraType
 *	Get graphics name for GR hdr objects
 */
void
VD_drwGetGRhdrGraType(
	VD_drwInputData			*inp ,
	VD_drwExecData			*xData 
	)
{
	inp->constDefName[0] ='\0';
    	if( vd_$is_ancestry_valid(	object	= DRW_elmId,
					classid	= OPP_VDdrw3d_class_id ) ) 
		VD_drwGetSectInfo (inp->elmId, inp->constDefName, FALSE);
	else 
		VD_drwGetGRhdrInfo (inp->elmId, inp->constDefName, FALSE);

	DRW_elmType = (*inp->constDefName) ? VD_gI_InAsbly : 0;
}
/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, stage ) {

	SetProc( ISOFTYPE_stage ); Begin
	__DBGpr_int ("\tQuery", query);

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "VD*Base" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetMacroGraType( inp, xData );	}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( stage ) */
/*----------------------------------------------------------------------------*/

/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VD, Macro ) {

	SetProc( ISOFTYPE_Macro ); Begin
	__DBGpr_int ("\tQuery", query);

	if( DRW_wantFilter )	strcpy( DRW_elmFilter, "*" ) ;

	if( DRW_wantType ){	VD_drwGetMacroType( inp, xData );	}

	if( DRW_wantGraType ){	VD_drwGetMacroGraType( inp, xData );	}

	if( DRW_wantView ){	DRW_elmView = VD_unknownViewType ;	}

	End

} /* ISOFTYPE( Macro ) */

end implementation VDSroot ;
