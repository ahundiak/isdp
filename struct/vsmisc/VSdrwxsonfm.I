/* $Id: VSdrwxsonfm.I,v 1.1.1.1 2001/01/04 21:10:50 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsmisc/VSdrwxsonfm.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwxsonfm.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:50  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/09/29  14:59:36  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 ***************************************************************************/

class implementation VSbeam ;

#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsformmacros.h"
/*
 * Inludes of  function prototypes.
 */
#include "vsbeamproto.h"
/*----------------------------------------------------------------------------*/
long VSdrawSectionOnForm( msg, form, gadget, rep, lineWeight, mdEnv, sectDef )

/*
 * This function is interfaced by macro vs$draw_section_on_form.
 */

long			*msg ;
char			*form ;
int			gadget ;
VSdspRep		rep ;
int			lineWeight ;
struct GRmd_env		*mdEnv ;
struct GRid		*sectDef ; {

	IGRpoint		worldPnt ;
	struct GRobj_env	curve ;
	{     
  
// TR179700969
		IGRboolean 	cardOpt = FALSE;

		VScardpt_to_vector( 	mdEnv, 
					*sectDef, 
					&cardOpt, 
					VS_e_GEO_CENT, 
					worldPnt ) ;
	}

	vs$get_graphic_section(	msg		= msg,
				sectDef		= sectDef,
				representation	= rep,
				section		= &curve ) ;
	if( *msg & 1 ) {
		vs$draw_curve_on_form(	msg	= msg,
					form	= form,
					gadget	= gadget,
					weight	= lineWeight,
					refPoint= worldPnt,
					curveEnv= &curve.mod_env,
					curveId	= &curve._grid ) ;
	}
	return *msg & 1 ;

} /* VSdrawSectionOnForm */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
