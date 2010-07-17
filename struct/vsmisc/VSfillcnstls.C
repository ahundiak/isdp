/*
	I/STRUCT

Abstract
	Fill a construction list given the element geometry, the module
	environment, the properties and specvifi args.
	A buffer for the display must be provided: it will be set to the
	active display.
	The level will be set to the active level.

Arguments
IN	long			*p_msg		buffer for completion code
IN	struct IGRdisplay	*p_display	buffer for active display
IN	char			*p_geometry	element geometry
IN	struct GRmd_env		*p_env		module environment
IN	int			properties	propreties GRIS_...
IN	char 			*p_args		specific args
OUT	struct GRvg_construct	*p_cnst_list	construction list

Returns
	Nothing.
*/

#include <stdio.h>
#include "OMminimum.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "exdef.h"		/* Constants for exec (IGE)	*/
#include "ex.h"			/* Structs EX*			*/
#include "igrdef.h"		/* Constants IGR??		*/
#include "igr.h"		/* Structs IGR* for geometries	*/
#include "igrdp.h"		/* Structs IGR* for display	*/
#include "gr.h"			/* Structs GR* for graphic info	*/
#include "godef.h"		/* Struct GR* for graphics	*/
#include "go.h"			/* Struct GR* for graphics	*/
#include "grdpbdef.h"		/* Constants for DPB		*/
#include "grdpbmacros.h"	/* Macros for DPB		*/
/*----------------------------------------------------------------------------*/
void VSfill_cnst_list( p_msg, p_display, p_geometry,
			p_env, properties, p_args, p_cnst_list )

long			*p_msg ;
struct IGRdisplay	*p_display ;
char			*p_geometry ;
struct GRmd_env		*p_env ;
int			properties ;
char 			*p_args ;
struct GRvg_construct	*p_cnst_list ; {

	int	size,
		nret ;

	size = sizeof( short ) ;
	gr$get_active_level(	msg	= p_msg,
				sizbuf	= &size,
				nret	= &nret,
				buffer	= &p_cnst_list->level ) ;

	size = sizeof( struct IGRdisplay ) ;
	gr$get_active_display(	msg	= p_msg,
				sizbuf	= &size,
				nret	= &nret,
				buffer	= p_display ) ;

	p_cnst_list->msg        = p_msg ;
	p_cnst_list->env_info   = p_env ;
	p_cnst_list->newflag    = FALSE ;
	p_cnst_list->name       = NULL ;
	p_cnst_list->class_attr = p_args ;
	p_cnst_list->display    = p_display;
	p_cnst_list->properties = properties ;
	p_cnst_list->geometry   = p_geometry ;

} /* VSfill_cnst_list */
/*----------------------------------------------------------------------------*/

