class implementation Root;

#include <stdlib.h>
#include <stdio.h>

#include "wl.h"

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "madef.h"

#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "dpstruct.h"

#include "dl.h"
#include "DPdlist.h"
#include "HSdlist.h"

#include "godef.h"

/* New Prototypes */
PROTO_HSdlist_msc_created
PROTO_DPdlist_delete_variable_data
PROTO_HSdlist_shading_parameter_notify

extern int DPdlist_hash_lookup(OM_S_OBJID objid, OMuword osnum,
         struct DPdlist_fixed_data **fixed_data);

from EMSboundary import EMgetsurface_info;
from GAcurve import GAget_msc_component;

/*--- HSdlist_msc_created --------------------------------------------------*/

int HSdlist_msc_created(
   OM_S_OBJID msc_objid,
   OMuword osnum )

/*
NAME
   HSdlist_msc_created

DESCRIPTION
   This function processes a model space counterpart creation notification
   for a surface in the display list.

SYNOPSIS
   int HSdlist_msc_created(
      OM_S_OBJID msc_objid,
      OMuword osnum )

PARAMETERS
   msc_objid (IN) - the object id of the MSC that was created
   osnum (IN) - the object space number of the surface

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   05/10/93  S.P. Rogers
      Initial specification and design
*/

{
   int sts;
   IGRlong msg;
   OM_S_OBJID edge_objid, surf_objid;
   OMuword edge_os;

   /* find the surface associated with the msc */
   sts = om$send( msg = message GAcurve.GAget_msc_component( &msg, &edge_objid, &edge_os ),
                  targetid = msc_objid,
                  targetos = osnum,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & msg) )
   {
      return( DLIST_E_ERROR );
   }

   sts = om$send( msg = message EMSboundary.EMgetsurface_info( &msg, &surf_objid, NULL ),
                  targetid = edge_objid,
                  targetos = edge_os,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & msg) )
   {
      return( DLIST_E_ERROR );
   }

   sts = DPdlist_delete_variable_data( surf_objid, osnum, DP_DLIST_DELETE_WF_DATA );

   return( sts );

} /* HSdlist_msc_created */

/*--- HSdlist_shading_parameter_notify -----------------------*/

int HSdlist_shading_parameter_notify(
   OM_S_OBJID objid,
   OMuword osnum,
   unsigned char diff_refl,
   unsigned char spec_refl,
   unsigned char finish,
   unsigned char trans )

/*
NAME
   HSdlist_shading_parameter_notify

DESCRIPTION
   This function processes the notification for a change in
   the shading parameters of a surface.  It does this by
   updating the shading parameters in the shading variable
   data for the surface.

SYNOPSIS
   int HSdlist_shading_parameter_notify(
      OM_S_OBJID objid,
      OMuword osnum,
      unsigned char diff_refl,
      unsigned char spec_refl,
      unsigned char finish,
      unsigned char trans )

PARAMETERS
   objid (IN) - the object id of the element
   osnum (IN) - the object space number of the element
   diff_refl (IN) - the new diffuse reflectance
   spec_refl (IN) - the new specular reflectance
   finish (IN) - the new finish
   trans (IN) - the new transparency

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS
      Success
   DLIST_I_NOTFOUND
      The surface is not in the hash table
   DLIST_I_NOVARIABLEDATA
      The was no shading variable data for the surface

HISTORY
   07/20/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   struct DPdlist_fixed_data *fixed;
   struct DPdlist_sh_surface_variable sh_surface_ptrs;

   DPdlist_hash_lookup( objid, osnum, &fixed );
   if ( !fixed )
   {
      return( DLIST_I_NOTFOUND );
   }

   if ( !fixed->sh_data )
   {
      return( DLIST_I_NOVARIABLEDATA );
   }

   DLIST_SH_SRF_ALL_PTRS( fixed->sh_data, sh_surface_ptrs );

   *(sh_surface_ptrs.diff_refl) = diff_refl / 255.0;
   *(sh_surface_ptrs.spec_refl) = spec_refl / 255.0;
   *(sh_surface_ptrs.finish) = (float) finish;
   *(sh_surface_ptrs.trans) = trans / 255.0;

   return( DLIST_S_SUCCESS );

} /* HSdlist_shading_parameter_notify */

end implementation Root;
