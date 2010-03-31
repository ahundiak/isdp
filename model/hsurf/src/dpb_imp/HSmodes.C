
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "igrtypedef.h"

#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "hslight.h"
#include "hsurf.h"
#include "HSpr_dpb_imp.h"

/*------------------------------
 *  for function
 *     HSget_symb
 */
 
#include "hstex_table.h"
#include "hssymb.h"
#include "HSpr_bundle.h"

/*------------------------------*/


/*--- HSget_symbology_modes -------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_symbology_modes( IGRint *style,
				    IGRint *finish,
				    IGRint *reflect,
				    IGRint *trans )
#else
	void HSget_symbology_modes( style, finish, reflect, trans )

	IGRint *style, *finish, *reflect, *trans;
#endif

/*
DESCRIPTION
	This function gets the symbology modes from the HS DPB.  The values returned
	for the modes are: HS_MODE_ELEMENT or HS_MODE_ACTIVE.  If the value of a mode
	is not desired, the corresponding parameter should be passed in as NULL.

HISTORY
	S.P. Rogers  07/11/89  Creation Date
*/

	{
	IGRuint HS_flags;

	/* get the HS_module_flags from the HSdpb */
	hs$get_shading_flags( shading_flags = &HS_flags );

	if ( style )
	   *style = (HS_flags & HS_SHADING_STYLE_MODE) ? HS_MODE_ELEMENT : HS_MODE_ACTIVE;

	if ( finish )
	   *finish = (HS_flags & HS_SHADING_FINISH_MODE) ? HS_MODE_ACTIVE : HS_MODE_ELEMENT;

	if ( reflect )
	   *reflect = (HS_flags & HS_SHADING_REFLECT_MODE) ? HS_MODE_ACTIVE : HS_MODE_ELEMENT;

	if ( trans )
	   *trans = (HS_flags & HS_SHADING_TRANS_MODE) ? HS_MODE_ELEMENT : HS_MODE_ACTIVE;

	} /* HSget_symbology_modes */


/*--- HSset_symbology_modes -------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSset_symbology_modes( IGRint *style,
				      IGRint *finish,
				      IGRint *reflect,
				      IGRint *trans )
#else
	IGRint HSset_symbology_modes( style, finish, reflect, trans )

	IGRint *style, *finish, *reflect, *trans;
#endif

/*
DESCRIPTION
	This function sets the symbology modes in the HS DPB.  Valid values for 
	the modes are: HS_MODE_ELEMENT or HS_MODE_ACTIVE.  If a mode is not to
	be set, the corresponding parameter should be passed in as NULL.

	Return Values:

	   0 - success
	   1 - failure (one of the modes was invalid)

HISTORY
	S.P. Rogers  07/11/89  Creation Date
*/

	{
	IGRuint HS_flags;

	/* get the HS_module_flags from the HSdpb */
	hs$get_shading_flags( shading_flags = &HS_flags );

	if ( style )
	   {
	   if ( *style == HS_MODE_ELEMENT )
	      HS_flags |= HS_SHADING_STYLE_MODE;
	   else if ( *style == HS_MODE_ACTIVE )
	      HS_flags &= ~HS_SHADING_STYLE_MODE;
	   else
	      return( 1 ); /* error */
	   }

	if ( finish )
	   {
	   if ( *finish == HS_MODE_ACTIVE )
	      HS_flags |= HS_SHADING_FINISH_MODE;
	   else if ( *finish == HS_MODE_ELEMENT )
	      HS_flags &= ~HS_SHADING_FINISH_MODE;
	   else
	      return( 1 ); /* error */
	   }

	if ( reflect )
	   {
	   if ( *reflect == HS_MODE_ACTIVE )
	      HS_flags |= HS_SHADING_REFLECT_MODE;
	   else if ( *reflect == HS_MODE_ELEMENT )
	      HS_flags &= ~HS_SHADING_REFLECT_MODE;
	   else
	      return( 1 ); /* error */
	   }

	if ( trans )
	   {
	   if ( *trans == HS_MODE_ELEMENT )
	      HS_flags |= HS_SHADING_TRANS_MODE;
	   else if ( *trans == HS_MODE_ACTIVE )
	      HS_flags &= ~HS_SHADING_TRANS_MODE;
	   else
	      return( 1 ); /* error */
	   }

	hs$put_shading_flags( shading_flags = &HS_flags );

	return( 0 );

	} /* HSset_symbology_modes */


/*--- HSget_accuracy_mode ----------------------------------------------------*/

void HSget_accuracy_mode( acc_mode )

	IGRint *acc_mode;

/*
DESCRIPTION
	This function gets the accuracy mode from the HS DPB.  The value returned
	for the mode is: HS_ACCURACY_MODE_WINDOW, HS_ACCURACY_MODE_ELEMENT or 
	HS_ACCURACY_MODE_ACTIVE.

HISTORY
	S.P. Rogers  07/11/89  Creation Date
*/

	{
	IGRuint HS_flags;

	hs$get_shading_flags( shading_flags = &HS_flags );

	switch ( HS_flags & HS_SHADING_ACCUR_MODE )
	   {
	   case HS_SHADING_WINDOW_ACCUR :

	      *acc_mode = HS_ACCURACY_MODE_WINDOW;
	      break;

	   case HS_SHADING_ACTIVE_ACCUR :

	      *acc_mode = HS_ACCURACY_MODE_ACTIVE;
	      break;

	   case HS_SHADING_ELEMENT_ACCUR :

	      *acc_mode = HS_ACCURACY_MODE_ELEMENT;
	      break;
	   }

	}  /* HSget_accuracy_mode */


/*--- HSset_accuracy_mode --------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSset_accuracy_mode( IGRint acc_mode )
#else
	IGRint HSset_accuracy_mode( acc_mode )

	IGRint acc_mode;
#endif

/*
DESCRIPTION
	This function sets the accuracy mode in the HS DPB.  Valid values for
	the mode are: HS_ACCURACY_MODE_WINDOW, HS_ACCURACY_MODE_ELEMENT or 
	HS_ACCURACY_MODE_ACTIVE.

	Return Values:

	   0 - success
	   1 - failure (invalid mode)

HISTORY
	S.P. Rogers  07/11/89  Creation Date
*/

	{
	IGRuint HS_flags;

	/* get HS flags word and clear accuracy mode bits */
	hs$get_shading_flags( shading_flags = &HS_flags );
	HS_flags &= ~HS_SHADING_ACCUR_MODE;

	switch ( acc_mode )
	   {
	   case HS_ACCURACY_MODE_WINDOW :

	      HS_flags |= HS_SHADING_WINDOW_ACCUR;
	      break;

	   case HS_ACCURACY_MODE_ACTIVE :

	      HS_flags |= HS_SHADING_ACTIVE_ACCUR;
	      break;	      

	   case HS_ACCURACY_MODE_ELEMENT :

	      HS_flags |= HS_SHADING_ELEMENT_ACCUR;
	      break;	      

	   default:

	      return( 1 );

	   }  /* end: switch */

	hs$put_shading_flags( shading_flags = &HS_flags );
	return( 0 );
	
	}  /* HSset_accuracy_mode */

/*
 *
 * HSget_trans_grid() gets the translucency grid (HS_GRID_WIDE or HS_GRID_NARROW).
 * It accomplishes this by looking at a bit in the HSdpb word.
 * It returns the proper value in '*grid'
 *
 * HISTORY: 06/20/89	Created.
 *									Trevor Mink
 */

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_trans_grid( IGRint *grid )
#else
	void HSget_trans_grid( grid )

	IGRint *grid;
#endif

	{
	IGRuint HS_flags;

	/* read the symbology word and determine current shading */
	hs$get_shading_flags( shading_flags = &HS_flags );

	*grid = (HS_flags & HS_SHADING_TRANS_GRID) ? HS_GRID_WIDE : HS_GRID_NARROW;

	} /* HSget_trans_grid */


/*
 *
 * HSset_trans_grid() sets the translucency grid to HS_GRID_WIDE or HS_GRID_NARROW.
 * It does this by setting a bit in the HSdpb word.
 * It returns zero upon successful completion, one upon unsuccessful completion.
 *
 * HISTORY: 06/20/89	Created.
 *									Trevor Mink
 */

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSset_trans_grid( IGRint grid )
#else
	IGRint HSset_trans_grid( grid )

	IGRint grid;
#endif

	{
	IGRuint HS_flags;

	/* read the symbology word and determine current shading */
	hs$get_shading_flags( shading_flags = &HS_flags );

	if (grid == HS_GRID_WIDE)
		HS_flags |= HS_SHADING_TRANS_GRID;
	else if (grid == HS_GRID_NARROW)
		HS_flags &= ~HS_SHADING_TRANS_GRID;
	else
		return (1);

	hs$put_shading_flags( shading_flags = &HS_flags );

	return (0);

	} /* HSset_trans_grid */


/*--- HSget_cull_mode ---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_cull_mode( IGRint *mode )
#else
	void HSget_cull_mode( mode )

	IGRint *mode;
#endif

/*
DESCRIPTION
	This function gets the culling mode (HS_CULL_YES or HS_CULL_NO).

HISTORY
	S.P. Rogers  11/29/89  Creation Date
*/

	{
	IGRuint HS_flags;

	hs$get_shading_flags( shading_flags = &HS_flags );

	*mode = (HS_flags & HS_SHADING_CULLING_MODE) ? HS_CULL_NO : HS_CULL_YES;
	} /* HSget_cull_mode */


/*--- HSset_cull_mode ---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSset_cull_mode( IGRint mode )
#else
	IGRint HSset_cull_mode( mode )

	IGRint mode;
#endif


/*
DESCRIPTION
	This function set the culling mode to HS_CULL_YES or HS_CULL_NO.
	Zero is returned upon successful completion and one is returned if
	there is an error.

HISTORY
	S.P. Rogers  11/29/89  Creation Date
*/

	{
	IGRuint HS_flags;

	hs$get_shading_flags( shading_flags = &HS_flags );

	if ( mode == HS_CULL_NO )
	   HS_flags |= HS_SHADING_CULLING_MODE;
	else if ( mode == HS_CULL_YES )
	   HS_flags &= ~HS_SHADING_CULLING_MODE;
	else
	   return( 1 );

	hs$put_shading_flags( shading_flags = &HS_flags );

	return( 0 );

	} /* HSset_cull_mode */

