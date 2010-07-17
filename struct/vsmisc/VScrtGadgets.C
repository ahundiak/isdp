/*
	I/STRUCT
*/
#include <stdio.h>
#include <FI.h>
#include <FIdyn.h>
#include "vs.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "VX_FIproto.h"
#include "vsformproto.h"
/*----------------------------------------------------------------------------*/
int VSg_create_line( form, x1, y1, x2, y2, color, gadget )

char	*form ;
int	x1,
	y1,
	x2,
	y2,
	color,
	*gadget ; {

	/*
	 * This function creates a line gadget from (x1,y1) to (x2,y2).
	 */
	int			rc,
				gadget_label = -1 ;
	struct standard_st	standard_var ;

	/*
	 * Get next unused label in form.
	 */
	rc = FIf_get_next_label( form, &gadget_label ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Create line gadget.
	 */
	rc = FIg_new( form, FI_LINE, gadget_label ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Fill standard structure.
	 *
	 * WARNING : Fill all fields of gadget structure so
	 * FIg_set_standard_variables won't go crazy.
	 */
	standard_var.xlo		= x1 ;
	standard_var.ylo		= y1 ;
	standard_var.xhi		= x2 ;
	standard_var.yhi		= y2 ;
	standard_var.attr_mask		= ( FI_NOT_DISPLAYED |
					    FI_NO_COMPLETE_NOTIFY ) ;
	standard_var.value		= 0. ;
	standard_var.bodysize		= 0. ;
	standard_var.text		= NULL ;
	standard_var.help_topic 	= NULL ;
	standard_var.command		= NULL ;
	standard_var.fontname		= NULL ;
	standard_var.user_pointer	= NULL ;
	standard_var.off_color		= color ;
	standard_var.on_color		= color ;
	standard_var.off_color2 	= color ;
	standard_var.on_color2		= color ;
	standard_var.symbol_index	= 0 ;
	standard_var.symbol_index2	= 0 ;
	standard_var.next_in_seq	= 0 ;

	rc = FIg_set_standard_variables( form,
					 gadget_label,
					 &standard_var ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Set weight of line equal to 1.
	 */
	rc = FIg_set_line_weight( form, gadget_label, 1 ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	/*
	 * Activate gadget.
	 */
	rc = FIg_activate( form, gadget_label ) ;
	if( rc != FI_SUCCESS ) goto wrapup ;

	wrapup :
		*gadget = gadget_label ;

	return rc ;

} /* VSg_create_line */
/*----------------------------------------------------------------------------*/
