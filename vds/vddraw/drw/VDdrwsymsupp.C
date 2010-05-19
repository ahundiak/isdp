/* $Id */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw / VDdrwsymsupp.C
 *
 * Description:
 *	symbology support functions
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwsymsupp.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.3  1995/03/31  10:52:22  pinnacle
 * Replace: by tlbriggs for OPE
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	3/15/95		tlb		Add VD_drwSet*, VD_drwPrintSymbology
 *
 *	3/20/95		tlb		Verbose messages reflect values used
 *					Hidden color defaults to visible color
 *					Hidden level defaults to visible level+1
 *					Fix hidden weight default -
 *						set only if not overridden
 *
 *************************************************************************/
/*
	I/VDS	Copy.
*/
#include <string.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "wl.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "adpdef.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_dbgmacros.h"

/* avoid conflicts with tokens and defines in tools.h */
#undef	CENTER
#undef	LEFT
#undef	RIGHT
#include "VDdrwgrammar.h"

/*
 * Shortcuts
 */
#define VIS 	xData.overrides.elmDisplay
#define HDN 	xData.overrides.hdnDisplay

/*----------------------------------------------------------------------------*/
void VD_drwPrintSymbology(
		char			*desc,
		VD_drwExecData		xData		/* execute data struct*/
		)
{
	printf ("\n%s symbology\n", desc);
	printf ("  Visible:\t overriden: 0x%x\n", xData.symbOverrides & 0x000F);
	printf ("\tcolor = %d\tweight = %d\tstyle = %d\tlevel = %d\n",
		VIS.color, VIS.weight, VIS.style, xData.overrides.elmLevel);
	printf ("  Hidden:\t overriden: 0x%x\n", xData.symbOverrides & 0x00F0);
	printf ("\tcolor = %d\tweight = %d\tstyle = %d\tlevel = %d\n",
		HDN.color, HDN.weight, HDN.style, xData.overrides.hdnLevel);
}

/*----------------------------------------------------------------------------*/
/* Reset symbology to */
void VD_drwResetSymbology(
    	VD_drwExecData 		*xData ,	/* Execution data */
	VD_drwConstructData	*defaults	/* default symbology */
	)
{
	/* reset override flags */
        xData->symbOverrides	= 0;

	/* reset symbology */
	xData->overrides.dpAttr 	= defaults->dpAttr ;	/*TEMPORARY */
	xData->overrides.elmDisplay	= defaults->elmDisplay ;
	xData->overrides.hdnDisplay	= defaults->hdnDisplay ;
	xData->overrides.elmLevel	= defaults->elmLevel;
	xData->overrides.hdnLevel	= defaults->hdnLevel;
}
/*----------------------------------------------------------------------------*/
void VD_drwSetColor(
		int			tok_type,	/* token type */
		const VD_execRes 	*value,		/* color token read */
		VD_drwExecData		*xData		/* execute data struct*/
		)
{
	short unsigned     *field;		/* current default color */
	int		    color, mask;

	SetProc( VD_drwSetColor ); Begin

	/* select field to update, mask to use */
	switch (tok_type) {
		case COLOR:
			field = &(xData->overrides.elmDisplay.color);
			mask = VD_drwColorOverriden ;
			break;
		case HIDDEN_COLOR:
			field = &(xData->overrides.hdnDisplay.color);
			mask = VD_drwHdnColorOverriden ;
			break;
		default:
		 	VD_drwSyntaxError (xData->verbose,
				"Invalid color token type: %d\n",tok_type);
			End
			return;
			}

	/* check if has already been set */
	if ( xData->symbOverrides &= mask ) 
		VD_drwParserWarn (xData->verbose, "Color previously set\n"); 

	/* Check color and convert to color number */
	VD_checkColor (value, &color) ;

	switch( color ) {
	  	case VD_K_DRW_INV_CLR_NUM :
			VD_drwParserWarn (xData->verbose,
					"Invalid color number: %d, using %d\n",
			          	color, *field ) ;
			color = *field;
			break ;
	 	case VD_K_DRW_INV_CLR_NAM :
			VD_drwParserWarn (xData->verbose,
		    	    "Invalid color name: '%s', using color number %d\n",
							value->_sval,*field ) ;
			color = *field;
			break ;
		default :
			*field = color;
			xData->symbOverrides |= mask ;

			/* hidden color defaults to visible */
			if (tok_type ==  COLOR &&
		   	  !(xData->symbOverrides & VD_drwHdnColorOverriden)) 
				xData->overrides.hdnDisplay.color = color;
			break;
		}

	if (xData->verbose)
		 VD_drwPrtItem (tok_type, VD_int, &color ) ;
	End
}
/*----------------------------------------------------------------------------*/
void VD_drwSetStyle(
		int		tok_type,	/* token type */
		int		value,		/* style value read */
		VD_drwExecData	*xData		/* execute data structure */
		)
{
	int		mask;
	IGRuchar	*field;

	SetProc( VD_drwSetStyle ); Begin

	switch (tok_type) {
		case STYLE:
			field = &(xData->overrides.elmDisplay.style);
			mask = VD_drwStyleOverriden ;
			break;
		case HIDDEN_STYLE:
			field = &(xData->overrides.hdnDisplay.style);
			mask = VD_drwHdnStyleOverriden ;
			break;
		default:
		 	VD_drwSyntaxError (xData->verbose,
		 		"Invalid style token type: %d\n",tok_type);
			End
			return;
			}

	/* check if has already been set */
	if ( xData->symbOverrides &= mask ) 
		VD_drwParserWarn (xData->verbose, "Style previously set\n"); 

	if (VD_checkStyle (value)) {
		*field = value;
		xData->symbOverrides |= mask ;

		/* TEMPORARY - also set old adp structure for compatability*/
		if (tok_type ==  HIDDEN_STYLE)
			xData->overrides.dpAttr.hiddenStyle = value ;
		}
	else {
		VD_drwParserWarn (xData->verbose,
			"Invalid style: %d , using %d\n", value, *field ) ;
		value = *field;
		}

	if (xData->verbose)
		 VD_drwPrtItem (tok_type, VD_int, &value ) ;
	End
}
/*----------------------------------------------------------------------------*/
void VD_drwSetWeight(
		int		tok_type,	/* token type */
		int		value,		/* weight value read */
		VD_drwExecData	*xData		/* execute data structure */
		)
{
	int		mask;
	IGRuchar	*field;		/* current default weight */

	SetProc( VD_drwSetWeight ); Begin

	switch (tok_type) {
		case WEIGHT:
			field = &(xData->overrides.elmDisplay.weight);
			mask = VD_drwWeightOverriden ;
			break;
		case HIDDEN_WEIGHT:
			field = &(xData->overrides.hdnDisplay.weight);
			mask = VD_drwHdnWeightOverriden ;
			break;
		default:
		 	VD_drwSyntaxError (xData->verbose,
		 		"Invalid weight token type: %d\n",tok_type);
			End
			return;
			}

	/* check if has already been set */
	if ( xData->symbOverrides &= mask ) 
		VD_drwParserWarn (xData->verbose, "Weight previously set\n"); 

	if (VD_checkWeight (value)) {
		*field = value;
		xData->symbOverrides |= mask ;

		/* hidden weight defaults to visible */
		if (tok_type ==  WEIGHT &&
		   !(xData->symbOverrides & VD_drwHdnWeightOverriden))
			xData->overrides.hdnDisplay.weight = value;
		}
	else {
		VD_drwParserWarn (xData->verbose,
			"Invalid weight: %d, using %d\n", value, *field);
		value = *field;
		}

	if (xData->verbose)
		 VD_drwPrtItem (tok_type, VD_int, &value ) ;
	End
}
/*----------------------------------------------------------------------------*/
void VD_drwSetLevel(
		int		tok_type,	/* token type */
		int		value,		/* level value read */
		VD_drwExecData	*xData		/* execute data structure */
		)
{
	int		mask;
	short		*field;		/* current default level */

	SetProc( VD_drwSetLevel ); Begin

	switch (tok_type) {
		case LEVEL:
			field = &(xData->overrides.elmLevel);
			mask = VD_drwLevelOverriden ;
			break;
		case HIDDEN_LEVEL:
			field = &(xData->overrides.hdnLevel);
			mask = VD_drwHdnLevelOverriden ;
			break;
		default:
		 	VD_drwSyntaxError (xData->verbose,
		 		"Invalid level token type: %d\n",tok_type);
			End
			return;
			}

	/* check if has already been set */
	if ( xData->symbOverrides &= mask ) 
		VD_drwParserWarn (xData->verbose, "Level previously set\n"); 

	if (VD_checkLayer (value)) {
		*field = value;
		xData->symbOverrides |= mask ;

		/* hidden level defaults to visible + 1 */
		if (tok_type ==  LEVEL && 
		    !(xData->symbOverrides & VD_drwHdnLevelOverriden)) 
				xData->overrides.hdnLevel = value + 1;
		}
	else {
		VD_drwParserWarn (xData->verbose,
				"Invalid layer: %d, using %d\n", value, *field);
		value = *field;
		}

	if (xData->verbose)
		 VD_drwPrtItem (tok_type, VD_int, &value) ;
	End;
}
/*----------------------------------------------------------------------------*/
int VD_checkStyle( style ) int style ; {

	/*
	 * Check that style number is valid.
	 */
	return GR_LO_STYLE <= style && style <= GR_HI_STYLE ;

} /* VD_checkStyle */
/*----------------------------------------------------------------------------*/
int VD_checkWeight( weight ) int weight ; {

	/*
	 * Check that weight number is valid.
	 */
	return GR_LO_WEIGHT <= weight && weight <= GR_HI_WEIGHT ;

} /* VD_checkWeight */
/*----------------------------------------------------------------------------*/
int VD_checkColor( color, val ) const VD_execRes *color ; int *val ; {

	/*
	 * Checks that color name or number is valid.
	 * Returns
	 * *val = VD_K_DRW_INV_CLR_NUM invalid color number	rc = FALSE
	 * *val = VD_K_DRW_INV_CLR_NAM invalid color name	rc = FALSE
	 * *val = the color number				rc = TRUE
	 */
	int rc ;

	if( VD_string == color->type ) {
		short	co ;

		rc = ige$get_color_from_name(	name	= color->_sval,
						color	= &co ) ;
		*val = rc ? co : VD_K_DRW_INV_CLR_NAM ;
	} else {
		int co = VD_drwIntVal( color ) ;

		rc = GR_LO_COLOR <= co && co <= GR_HI_COLOR ;
		*val = rc ? co : VD_K_DRW_INV_CLR_NUM ;
	}

	return rc ;

} /* VD_checkColor */
/*----------------------------------------------------------------------------*/
int VD_checkLayer( layer ) int layer ; {

	/*
	 * Check that layer number is valid.
	 */
	return GR_LO_LAYER <= layer && layer <= GR_HI_LAYER ;

} /* VD_checkStyle */
/*----------------------------------------------------------------------------*/
