class implementation EMScompsurf;

/*
Description
     This method returns the geometry properties of an object.

Return values
     *msg         MSSUCC if all is well
     *properties  geometric properties.

history:
     gupta     12/03/86 : Design date.
     DLB       10/29/87 : Rewrote to check planarity and closure rather than
                          use hard coded values.
*/

#include "msdef.h"
#include "EMSerrordef.h"
#include "emserr.h"
#include "EMSopt.h"
#include "PWminimum.h"
#include "PWapi/sfprops.h"

method GRgeomprops(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix; 
                   struct GRprops *properties)

{
  IGRlong     OM_stat;
/*  IGRint      num_comp_edges = 0, comp_buf_size = 0; */
  struct GRid *comp_edges = NULL;


  OM_stat = OM_S_SUCCESS;
  *msg = MSSUCC;
  
  properties->type         = GRSURFACE;
  properties->subtype      = GRCS;
  properties->closed       = 0;
  properties->is_segmented = 0;
  properties->planar       = ME.GRgraphics->properties & GRIS_PLANAR;
  properties->phy_closed   = pwIsSfOpen (my_id, OS);

/*
  OM_stat = om$send(msg = message EMSsurface.EMgetedges(msg,
                          EMS_OPT_CONNECTABLE, &comp_edges, &comp_buf_size,
                          &num_comp_edges, NULL, NULL, NULL, NULL),
                    targetid = my_id);
  if (!(1 & OM_stat)) goto wrapup;

  properties->phy_closed = (comp_edges == NULL); 
*/


 wrapup:
  if(comp_edges) om$dealloc(ptr = comp_edges);
  EMWRAPUP(*msg, OM_stat, "In EMScompsurf.GRgeomprop")
  return( OM_stat);
}
end implementation EMScompsurf;
