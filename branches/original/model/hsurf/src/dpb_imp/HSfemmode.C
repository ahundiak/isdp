
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

/*
DESCRIPTION
	This file contains all routines that return or modify the
	FEM shading mode bits in the active hidden line properties flag.

HISTORY
	06/13/89  C. M. Jablonski	Created.
	04/11/91  R. Druzynski          Apogee compliance
*/

/*#include <stdlib.h>*/

#include "igrtypedef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include <stdio.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "hslight.h"
#include "hsurf.h"
#include "HSpr_dpb_imp.h"

#define HS_SUCCESS	0
#define HS_ERROR	1


/*--- HSget_fem_style -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_fem_style( IGRint *fem_style )
#else
	void HSget_fem_style( fem_style )

	IGRint	*fem_style;
#endif

/*
 * Returns the current FEM contour tile shading style.
 *
 * HISTORY: 06/13/89 Created.			C. M. Jablonski
 */

	{
	IGRuint	mode;

	/* read the symbology word */
	hs$get_shading_flags( shading_flags = &mode );

	/* set the style flag */
	*fem_style = (mode & HS_SHADING_FEM_STYLE) ? HS_FEM_BLENDED : HS_FEM_DIRECT;
	}

/*--- HSset_fem_style -----------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSset_fem_style( IGRint fem_style )
#else
	IGRint	HSset_fem_style( fem_style )

	IGRint	fem_style;
#endif

/*
 * Changes the current FEM contour tile shading style.
 *
 * HISTORY: 06/13/89 Created.			C. M. Jablonski
 */

	{
	IGRuint	mode;

	/* read the symbology word */
	hs$get_shading_flags( shading_flags = &mode );

	/* set the style bit */
	if (fem_style == HS_FEM_BLENDED)
		mode |= HS_SHADING_FEM_STYLE;
	else if (fem_style == HS_FEM_DIRECT)
		mode &= ~(HS_SHADING_FEM_STYLE);
	else
		return( HS_ERROR );

	/* write the symbology word */
	hs$put_shading_flags( shading_flags = &mode );

	return( HS_SUCCESS );
	}

/*--- HSget_fem_mesh ------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_fem_mesh( IGRint *fem_mesh )
#else
	void HSget_fem_mesh( fem_mesh )

	IGRint	*fem_mesh;
#endif

/*
 * Returns the current FEM contour tile mesh mode.
 *
 * HISTORY: 06/13/89 Created.			C. M. Jablonski
 */

	{
	IGRuint	mode;

	/* read the symbology word */
	hs$get_shading_flags( shading_flags = &mode );

	/* set the mesh mode flag */
	*fem_mesh = (mode & HS_SHADING_FEM_MESH) ? HS_FEM_MESH_ON : HS_FEM_MESH_OFF;
	}

/*--- HSset_fem_mesh ------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSset_fem_mesh( IGRint fem_mesh )
#else
	IGRint HSset_fem_mesh( fem_mesh )

	IGRint	fem_mesh;
#endif

/*
 * Changes the current FEM contour tile mesh mode.
 *
 * HISTORY: 06/13/89 Created.			C. M. Jablonski
 */

	{
	IGRuint	mode;

	/* read the symbology word */
	hs$get_shading_flags( shading_flags = &mode );

	/* set the mesh mode bit */
	if (fem_mesh == HS_FEM_MESH_ON)
		mode |= HS_SHADING_FEM_MESH;
	else if (fem_mesh == HS_FEM_MESH_OFF)
		mode &= ~(HS_SHADING_FEM_MESH);
	else
		return( HS_ERROR );

	/* write the symbology word */
	hs$put_shading_flags( shading_flags = &mode );

	return( HS_SUCCESS );
	}
