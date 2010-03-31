
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>
#include <tools.h>

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


/*--- HSget_rhl_info ------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_rhl_info( IGRint *show_hidden )
#else
	void HSget_rhl_info( show_hidden )

	IGRint    *show_hidden;
#endif

/*
DESCRIPTION
	This function gets the RHL information from the DPB.  It
	gets the show hidden bit.

HISTORY
	S.P. Rogers  08/10/89  Creation Date
*/

	{
	IGRuint shading_flags;

	hs$get_shading_flags( shading_flags = &shading_flags );

	if ( show_hidden )
	   *show_hidden = ( shading_flags & HS_SHADING_SHOW_HIDDEN ) ?
	                  HS_SHOW_HIDDEN_EDGES_YES : HS_SHOW_HIDDEN_EDGES_NO;

	}  /* HSget_rhl_info */


/*--- HSset_rhl_info ------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSset_rhl_info( IGRint *show_hidden )
#else
	IGRint HSset_rhl_info( show_hidden )

	IGRint    *show_hidden;
#endif

/*
DESCRIPTION
	This function sets the RHL information in the DPB.  It
	sets the show hidden bit.

HISTORY
	S.P. Rogers  08/10/89  Creation Date
*/

	{
	IGRuint shading_flags;

	hs$get_shading_flags( shading_flags = &shading_flags );

	if ( show_hidden )
	   {
	   if ( *show_hidden == HS_SHOW_HIDDEN_EDGES_YES )
	      shading_flags |= HS_SHADING_SHOW_HIDDEN;
	   else if ( *show_hidden == HS_SHOW_HIDDEN_EDGES_NO )
	      shading_flags &= ~HS_SHADING_SHOW_HIDDEN;
	   else
	      return( 1 );   /* invalid input */
	   }
	
	hs$put_shading_flags( shading_flags = &shading_flags );
	return( 0 );
	}  /* HSset_rhl_info */
