
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "msdef.h"
#include "madef.h"

#include "igr.h"
#include "gr.h"
#include "igrdp.h"

#include "dpstruct.h"
#include "godef.h"
#include "go.h"

#include "bs.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grgsmacros.h"

/* prototype files */
%safe
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"
%endsafe

from GRvg import GRgenabsg;


/*--- VEprocess_fence -----------------------------------------------------------*/

void VEprocess_fence( gragad_id )

	OM_S_OBJID gragad_id;
	
/*
NAME
	VEprocess_fence

DESCRIPTION
	This function determines if a fence object is connected to the given
	window and uses its geometry to reset the clipping range if it is.

	A fence is connected to a window in the following manner:


	|-----------|                      |----------|
	|           | winsup               |          |
	|  window   |----------------------| GRgsmgr  |
	|           |              gra_gad |          |
	|-----------|                      |----------|
	                                        | to_components
	                                        |
	                                        |
	                              to_owners |
	                                   |----------|
	                                   |          |
	                                   |  Fence   |
	                                   |          |
	                                   |----------|


	To see if the fence is connected to the current VE window, we:

	   - get the id of the fence using the gr$gsget_fence macro

	   - find the id of the GRgsmgr object by looking up the fence's
             to_owners channel

	   - find the id of the window the fence is connected to by looking
	     up the GRgsmgr's gra_gad channel and compare it to the id
	     of the current VE window

PARAMETERS
	gragad_id (IN) - the object id of the gragad that is having VE
	                 run in it

GLOBALS USED
	none

HISTORY
	11/28/88    S.P. Rogers
	   Creation Date.
*/

	{
	IGRlong             msg;
	IGRlong             sts;
	IGRshort            id_mat_type;
	IGRint              ii;
	OMuint              count;
	OMuint              num_owners;
	IGRmatrix           id_mat;
	struct GRid         fence_grid;
	OM_S_CHANSELECT     owner_chandef;
	OM_S_CHANSELECT     gragad_chandef;
	OM_S_OBJECT_LINKAGE obj_list[1];
	struct IGRbsp_curve *fence_geom;
	OM_S_OBJID          owner_id;
	OMuword             owner_os;
	OMuword             owner_classid;

	/* get the GRid of the fence (if there is one) */
	gr$gsget_fence( msg      = &msg,
	                fence_id = &fence_grid );

	if ( msg != MSFAIL )
	   {
	   /* see if the fence is attached to the VE window */
	   om$make_chanselect( channame     = "GRconnector.to_owners",
	                       p_chanselect = &owner_chandef );

	   om$make_chanselect( channame     = "IGEwinsup.gra_gad",
	                       p_chanselect = &gragad_chandef );

	   /* loop through all owners of the fence until we find the GRgsmgr object */
	   sts = om$get_channel_count( objid        = fence_grid.objid,
	                               osnum        = fence_grid.osnum,
	                               p_chanselect = &owner_chandef,
	                               count        = &num_owners );

	      OM_ERRCHK( sts, "VEprocess_fence: om$get_channel_count failed" );

	   for ( ii = 0; ii < num_owners; ii++ )
	      {
	      /* get the id of the object at this index */
	      sts = om$get_objid_at_index( objid        = fence_grid.objid,
	                                   osnum        = fence_grid.osnum,
	                                   p_chanselect = &owner_chandef,
	                                   index        = ii,
	                                   objidaddr    = &owner_id,
	                                   osnumaddr    = &owner_os );

	         OM_ERRCHK( sts, "VEprocess_fence: om$get_objid_at_index failed" );

	      /* see if the object is a GRgsmgr object */
	      om$get_classid( objid     = owner_id,
	                      osnum     = owner_os,
	                      p_classid = &owner_classid );

	      if ( om$is_ancestry_valid( subclassid = owner_classid,
	                                 superclassname = "GRgsmgr" ) == OM_S_SUCCESS )
	         {
	         /* get the id of the window the GRgsmgr object is connected to */
	         sts = om$get_channel_objects( objid        = owner_id,
	                                       osnum        = owner_os,
	                                       p_chanselect = &gragad_chandef,
	                                       list         = obj_list,
	                                       size         = 1,
	                                       count        = &count );

	             OM_ERRCHK( sts, "VEprocess_fence: om$get_channel_objects failed" );

	         if ( obj_list[0].S_objid == gragad_id )
	            {
	            /* fence is attached to VE window => get geometry of */
	            /* the fence and reset the clip range                */
	            id_mat_type = MAIDMX;
	            id_mat[0]  = 1.0; id_mat[1]  = 0.0; id_mat[2]  = 0.0; id_mat[3]  = 0.0;
	            id_mat[4]  = 0.0; id_mat[5]  = 1.0; id_mat[6]  = 0.0; id_mat[7]  = 0.0;
	            id_mat[8]  = 0.0; id_mat[9]  = 0.0; id_mat[10] = 1.0; id_mat[11] = 0.0;
	            id_mat[12] = 0.0; id_mat[13] = 0.0; id_mat[14] = 0.0; id_mat[15] = 1.0;

	            sts = om$send( mode     = OM_e_wrt_object,
	                           msg      = message GRvg.GRgenabsg( &msg,
	                                                              &id_mat_type,
	                                                              id_mat,
	                                                              (IGRchar **)&fence_geom ),
	                           senderid = NULL_OBJID,
	                           targetid = fence_grid.objid,
	                           targetos = fence_grid.osnum );

	               OM_ERRCHK( sts, "VEprocess_fence:  GRvg.GRgenabsg send failed" );
	               MSG_ERRCHK( msg, "VEprocess_fence:  GRvg.GRgenabsg failed" );

	            if ( (1 & sts & msg) )
	               VEset_fence_clip( fence_geom );
	            }  /* end: if ( fence is in VEwindow ) */

	         }  /* end: if ( owner is a GRgsmgr object ) */

	      }  /* end: for */

	   }  /* end: if ( fence exists ) */

	}  /* VEprocess_fence */

end implementation Root;

