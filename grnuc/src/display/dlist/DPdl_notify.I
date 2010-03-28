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

#include "godef.h"

/* New Prototypes */
PROTO_DPdlist_wireframe_notify
PROTO_DPdlist_loopset_notify
PROTO_DPdlist_SO_notify
PROTO_DPdlist_delete_element
PROTO_DPdlist_delete_variable_data
PROTO_DPdlist_change_attr
PROTO_DPdlist_surface_active_notify
PROTO_DPdlist_surface_drop_notify
PROTO_DPdlist_graloop_notify
PROTO_DPdlist_horizon_curve_notify
PROTO_DPdlist_deactivate_object_space
PROTO_DPdlist_free_hash_table
PROTO_DPdlist_hash_delete_all
PROTO_DPdlist_hash_lookup
PROTO_DPdlist_tangent_edge_display_notify

from GRgraphics import GRgetprops;
from GRvg import GRgetsymb;
from GRvg import GRgetattr;

extern IGRboolean DPdlist_display_tangent_edges;

/*--- DPdlist_graphics_props_notify ---------------------------------*/

static int DPdlist_graphics_props_notify(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_graphics_props_notify (static)

DESCRIPTION
   This function notifies that display list that the graphics
   properties word (from GRgraphics) has changed for an element

SYNOPSIS
   int DPdlist_graphics_props_notify(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - the object id of the element whose props word changed
   osnum (IN) - the object space number of the object

GLOBALS USED
   none
  
RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/04/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   IGRlong msg;
   int delete_variable = 0;
   IGRshort props;
   struct DPdlist_fixed_data *fixed_data;
   struct IGResbs surf_attr;
   struct IGResbc curve_attr;
   IGRboolean display_polygon;
   
   sts = DPdlist_hash_lookup( objid, osnum, &fixed_data );
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }

   sts = om$send( msg = message GRgraphics.GRgetprops( &msg, &props ),
                  targetid = objid,
                  targetos = osnum,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & msg) )
   {
      return( DLIST_E_ERROR );
   }
   
   if ( (props & GRIS_DISPLAYABLE) &&
        (!(fixed_data->ele_flags & DP_DLIST_ELE_DISPLAYABLE)) )
   {
      delete_variable |= (DP_DLIST_DELETE_WF_DATA | DP_DLIST_DELETE_SH_DATA);
      fixed_data->ele_flags |= DP_DLIST_ELE_DISPLAYABLE;
   }

   if ( (!(props & GRIS_DISPLAYABLE)) &&
        (fixed_data->ele_flags & DP_DLIST_ELE_DISPLAYABLE) )
   {
      delete_variable |= (DP_DLIST_DELETE_WF_DATA | DP_DLIST_DELETE_SH_DATA);
      fixed_data->ele_flags &= ~DP_DLIST_ELE_DISPLAYABLE;
   }

   if ( (props & GRFILLED_DISPLAY) &&
        (!(fixed_data->ele_flags & DP_DLIST_ELE_FILLED)) )
   {
      delete_variable |= DP_DLIST_DELETE_WF_DATA;
      fixed_data->ele_flags |= DP_DLIST_ELE_FILLED;
   }

   if ( (!(props & GRFILLED_DISPLAY)) &&
        (fixed_data->ele_flags & DP_DLIST_ELE_FILLED) )
   {
      delete_variable |= DP_DLIST_DELETE_WF_DATA;
      fixed_data->ele_flags &= ~DP_DLIST_ELE_FILLED;
   }

   if ( (props & DEHAS_OVERRIDE) &&
        (!(fixed_data->ele_flags & DP_DLIST_ELE_HAS_SOS)) )
   {
      delete_variable |= DP_DLIST_DELETE_WF_DATA;
      fixed_data->ele_flags |= DP_DLIST_ELE_HAS_SOS;
   }

   if ( (!(props & DEHAS_OVERRIDE)) &&
        (fixed_data->ele_flags & DP_DLIST_ELE_HAS_SOS) )
   {
      delete_variable |= DP_DLIST_DELETE_WF_DATA;
      fixed_data->ele_flags &= ~DP_DLIST_ELE_HAS_SOS;
   }
 
   display_polygon = FALSE;
   if ( fixed_data->type == DP_DLIST_CURVE )
   {
      sts = om$send( msg = message GRvg.GRgetattr( &msg,
                                                   (IGRchar *)&curve_attr ),
                     targetid = objid,
                     targetos = osnum,
                     senderid = NULL_OBJID );

      if ( !(1 & sts & msg) )
      {
         return( DLIST_E_ERROR );
      }

      display_polygon = curve_attr.is_polydis;
   }
   else if ( fixed_data->type == DP_DLIST_SURFACE )
   {
      sts = om$send( msg = message GRvg.GRgetattr( &msg,
                                                   (IGRchar *)&surf_attr ),
                     targetid = objid,
                     targetos = osnum,
                     senderid = NULL_OBJID );

      if ( !(1 & sts & msg) )
      {
         return( DLIST_E_ERROR );
      }

      display_polygon = surf_attr.is_polydis;
   }

   if ( (display_polygon) &&
        (!(fixed_data->ele_flags & DP_DLIST_ELE_DISPLAY_POLYGON)) )
   {
      delete_variable |= DP_DLIST_DELETE_WF_DATA;
      fixed_data->ele_flags |= DP_DLIST_ELE_DISPLAY_POLYGON;
   }

   if ( (!display_polygon) &&
        (fixed_data->ele_flags & DP_DLIST_ELE_DISPLAY_POLYGON) )
   {
      delete_variable |= DP_DLIST_DELETE_WF_DATA;
      fixed_data->ele_flags &= ~DP_DLIST_ELE_DISPLAY_POLYGON;
   }

   if ( (delete_variable) &&
        ( (fixed_data->wf_data) || (fixed_data->sh_data) ) )
   {
      /* delete variable data becuase the format of the data */
      /* may have changed                                    */
      sts = DPdlist_delete_variable_data( objid, osnum, delete_variable );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_graphics_props_notify */

/*--- DPdlist_rule_line_notify ---------------------------------------------*/

int DPdlist_rule_line_notify(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_rule_line_notify

DESCRIPTION
   This function process a notification for the number of rule
   lines changing on a surface.  This only needs to be handled
   if the surface does not have graphics data objects.

SYNOPSIS
   int DPdlist_rule_line_notify(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - the object id of the notifying element
   osnum (IN) - the object space number of the element

GLOBALS USED
   none

RETURN VALUES
   OM_S_SUCCES - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/18/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   IGRlong msg;
   struct IGResbs surf_attr;
   struct DPdlist_fixed_data *fixed_data;
   unsigned short *num_u_rules, *num_v_rules;

   sts = DPdlist_hash_lookup( objid, osnum, &fixed_data );
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }

   if ( (!fixed_data) ||
        (fixed_data->type != DP_DLIST_SURFACE) ||
        (fixed_data->ele_flags & DP_DLIST_ELE_HAS_GRADATA) ||
        (!(fixed_data->wf_data)) )
   {
      return( DLIST_S_SUCCESS );
   }

   sts = om$send( msg = message GRvg.GRgetattr( &msg, (char *) &surf_attr ),
                  targetid = objid,
                  targetos = osnum,
                  senderid = NULL_OBJID );

   if ( !(1 & sts & msg) )
   {
      return( DLIST_E_ERROR );
   }
   
   DLIST_SRF_NUM_U_RULES_PTR( fixed_data->wf_data, num_u_rules );
   DLIST_SRF_NUM_V_RULES_PTR( fixed_data->wf_data, num_v_rules );
   
   if ( (*num_u_rules != surf_attr.u_rules) ||
        (*num_v_rules != surf_attr.v_rules) )
   {
      sts = DPdlist_delete_variable_data( objid, osnum, DP_DLIST_DELETE_WF_DATA );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_rule_line_notify */


/*--- DPdlist_wireframe_notify -----------------------------------------------*/

int DPdlist_wireframe_notify(
   OM_S_OBJID objid,
   OMuword osnum,
   IGRint notify_mask )

/*
NAME
   DPdlist_wireframe_notify

DESCRIPTION
   This function processes a wirframe notification for an element in the
   display list.

SYNOPSIS
   int DPdlist_wireframe_notify(
      OM_S_OBJID objid,
      OMuword osnum,
      IGRint notify_mask )

PARAMETERS
   objid (IN) - the object id of the wireframe object that is notifying
                the display list
   osnum (IN) - the object space number of the wireframe object
   notify_mask (IN) - the notification mask

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
   struct GRsymbology symb;

   if ( notify_mask & GR_DELETED )
   {
      sts = DPdlist_delete_element( objid, osnum );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }

      return( DLIST_S_SUCCESS );
   }

   if ( notify_mask & GR_ATTR_MODIFIED )
   {
      sts = om$send( msg = message GRvg.GRgetsymb( &msg, &symb ),
                     targetid = objid,
                     targetos = osnum,
                     senderid = NULL_OBJID );

      if ( !(1 & sts & msg) )
      {
         return( DLIST_E_ERROR );
      }

      sts = DPdlist_change_attr( objid, osnum,
                                 symb.display_attr.color,
                                 symb.display_attr.style,
                                 symb.display_attr.weight,
                                 symb.level );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }

      sts = DPdlist_graphics_props_notify( objid, osnum );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }

      sts = DPdlist_rule_line_notify( objid, osnum );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
   }


   if ( notify_mask & ( GR_GEOM_MODIFIED | GR_GEOM_XFORMED |
                        GR_GEOM_POSTED | GR_CHANGED) )
   {
      sts = DPdlist_delete_variable_data( objid, osnum,
                                          DP_DLIST_DELETE_WF_DATA | DP_DLIST_DELETE_SH_DATA );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
   }

   return( DLIST_S_SUCCESS );
} /* DPdlist_wireframe_notify */

/*--- DPdlist_loopset_notify -----------------------------------------------*/

int DPdlist_loopset_notify(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_loopset_notify

DESCRIPTION
   This function processes a loopset notification for a surface in the
   display list.

SYNOPSIS
   int DPdlist_loopset_notify(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - the object id of the surface that is doing the notification
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

   sts = DPdlist_delete_variable_data( objid, osnum,
                                       DP_DLIST_DELETE_SH_DATA | DP_DLIST_DELETE_WF_DATA );
   return( sts );
} /* DPdlist_loopset_notify */

/*--- DPdlist_SO_notify ----------------------------------------------------*/

int DPdlist_SO_notify(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_SO_notify

DESCRIPTION
   This function processes a SO notification for a wireframe element.

SYNOPSIS
   int DPdlist_SO_notify(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - the object id of the wireframe element that is having a SO
                added/deleted/changed.
   osnum (IN) - the object space number of the wireframe element

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

   sts = DPdlist_delete_variable_data( objid, osnum,
                                       DP_DLIST_DELETE_WF_DATA );
   return( sts );
} /* DPdlist_SO_notify */

/*--- DPdlist_surface_active_notify -----------------------------*/

int DPdlist_surface_active_notify(
   OM_S_OBJID objid,
   OMuword osnum,
   IGRboolean active )

/*
NAME
   DPdlist_surface_active_notify

DESCRIPTION
   This function is used to notify the display list that a surface has
   become active or inactive.

SYNOPSIS
   int DPdlist_surface_active_notify(
      OM_S_OBJID objid,
      OMuword osnum,
      IGRboolean active )

PARAMETERS
   objid (IN) - the object id of the surface
   osnum (IN) - the object space number of the surface
   active (IN) - TRUE, if surface is active; FALSE, if inactive

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/04/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   struct DPdlist_fixed_data *fixed_data;

   sts = DPdlist_hash_lookup( objid, osnum, &fixed_data );
   if ( ( !(1 & sts) ) || (!fixed_data) )
   {
      return( DLIST_E_ERROR );
   }

   if ( active )
   {
      fixed_data->ele_flags &= ~DP_DLIST_ELE_INACTIVE;
   }
   else
   {
      fixed_data->ele_flags |= DP_DLIST_ELE_INACTIVE;

      /* remove variable data from inactive surfaces to save space */
      sts = DPdlist_delete_variable_data( objid, osnum,
                                          DP_DLIST_DELETE_SH_DATA | DP_DLIST_DELETE_WF_DATA );
      if ( !(1 & sts) )
      {
         return( DLIST_E_ERROR );
      }
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_surface_active_notify */

/*--- DPdlist_surface_drop_notify -----------------------------*/

int DPdlist_surface_drop_notify(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_surface_drop_notify

DESCRIPTION
   This function is used to notify the display list that a surface has
   been dropped

SYNOPSIS
   int DPdlist_surface_drop_notify(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - the object id of the surface
   osnum (IN) - the object space number of the surface
   active (IN) - TRUE, if surface is active; FALSE, if inactive

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   10/04/93 Shridar Subramanian
      Initial specification, design, and implementation
*/

{
   int sts;
   struct DPdlist_fixed_data *fixed_data;

   sts = DPdlist_hash_lookup( objid, osnum, &fixed_data );
   if ( ( !(1 & sts) ) || (!fixed_data) )
   {
      return( DLIST_E_ERROR );
   }

      /* remove variable data from inactive surfaces to save space */
   sts = DPdlist_delete_variable_data( objid, osnum,
                                       DP_DLIST_DELETE_WF_DATA );
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_surface_drop_notify */


/*--- DPdlist_graloop_notify -----------------------------*/

int DPdlist_graloop_notify(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_graloop_notify

DESCRIPTION
   This function is used to notify the display list that a surface has
   had a change to a graphics loop.

SYNOPSIS
   int DPdlist_graloop_notify(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - the object id of the surface
   osnum (IN) - the object space number of the surface

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   06/08/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   struct DPdlist_fixed_data *fixed_data;

   sts = DPdlist_hash_lookup( objid, osnum, &fixed_data );
   if ( ( !(1 & sts) ) || (!fixed_data) )
   {
      return( DLIST_E_ERROR );
   }
 
   /* mark that the surface has graphics loops */
   fixed_data->ele_flags |= DP_DLIST_ELE_HAS_GRALOOPS;

   /* when we support graphic loops in the display list we will have */
   /* to delete the variable data when we get this notification      */
#if defined( GRALOOPS_SUPPORTED )
   sts = DPdlist_delete_variable_data( objid, osnum,
                                       DP_DLIST_DELETE_WF_DATA );
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }
#endif

   return( DLIST_S_SUCCESS );

} /* DPdlist_graloop_notify */

/*--- DPdlist_horizon_curve_notify -----------------------------*/

int DPdlist_horizon_curve_notify(
   OM_S_OBJID objid,
   OMuword osnum )

/*
NAME
   DPdlist_horizon_curve_notify

DESCRIPTION
   This function is used to notify the display list that a surface has
   had a change to its horizon curves.

SYNOPSIS
   int DPdlist_horizon_curve_notify(
      OM_S_OBJID objid,
      OMuword osnum )

PARAMETERS
   objid (IN) - the object id of the surface
   osnum (IN) - the object space number of the surface

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Failure

HISTORY
   09/09/93 S.P. Rogers
      Initial specification, design, and implementation
*/

{
   int sts;
   struct DPdlist_fixed_data *fixed_data;

   sts = DPdlist_hash_lookup( objid, osnum, &fixed_data );
   if ( ( !(1 & sts) ) || (!fixed_data) )
   {
      return( DLIST_E_ERROR );
   }
 
   /* mark that the surface has horizon curves */
   fixed_data->ele_flags |= DP_DLIST_ELE_HAS_HORIZON_CURVES;

   /* when we support horizon curves in the display list we will have */
   /* to delete the variable data when we get this notification       */
#if defined( HORIZON_CURVES_SUPPORTED )
   sts = DPdlist_delete_variable_data( objid, osnum,
                                       DP_DLIST_DELETE_WF_DATA );
   if ( !(1 & sts) )
   {
      return( DLIST_E_ERROR );
   }
#endif

   return( DLIST_S_SUCCESS );

} /* DPdlist_horizon_curve_notify */

/*--- DPdlist_deactivate_object_space -------------------------------*/

int DPdlist_deactivate_object_space(
   OMuword osnum )

/*
NAME
   DPdlist_deactivate_object_space

DESCRIPTION
   This function deactivates an object space by freeing everything
   in its hash table

SYNOPSIS
   int DPdlist_deactivate_object_space(
      OMuword osnum )

PARAMETERS
   osnum (IN) - the object space to deactivate

GLOBALS USED
   none

RETURN VALUES
   DLIST_S_SUCCESS - Success
   DLIST_E_ERROR - Error
*/

{
   int sts;

   sts = DPdlist_hash_delete_all( osnum, TRUE );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   sts = DPdlist_free_hash_table( osnum );
   if ( !(1 & sts) )
   {
      return( sts );
   }

   return( DLIST_S_SUCCESS );

} /* DPdlist_deactivate_object_space */

/*--- DPdlist_tangent_edge_display_notify -------------------------*/

int DPdlist_tangent_edge_display_notify(
   int display_flag )

/*
NAME
   DPdlist_tangent_edge_display_notify

DESCRIPTION
   This function is used to tell the display list about a change
   in the status of the tangent edge display flag maintained by
   drawing views.

SYNOPSIS
   int DPdlist_tangent_edge_display_notify(
      int display_flag )
   
PARAMETERS
   display_flag (IN) - TRUE, if tangent edges are to be displayed

GLOBALS USED
   DPdlist_display_tangent_edges

RETURN VALUES
   DLIST_S_SUCCESS - Success

HISTORY
   06/16/93 S.P. Rogers
      Initial specification, design, and implementation
*/
{
   DPdlist_display_tangent_edges = display_flag;
   return( DLIST_S_SUCCESS );
} /* DPdlist_tangent_edge_display_notify */

end implementation Root;
