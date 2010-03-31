/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
# include "msdef.h" /* MS message codes */
# include "madef.h"
# include "OMmacros.h"
# include "EMStypedef.h"
# include "EMSlogic.h"
# include "EMScmacros.h"
# include "EMSssprops.h"
# include "EMSsubbs.h"

method GRgenabsg(IGRlong *EMmsg; IGRshort *matrix_type;
                 IGRmatrix matrix; IGRchar **absgptr)
/* 
Abstract
  
    This method generates the abstract data representation for a 3-D
    double precision bspline surface and places the data in the standard
    buffer. The input transformation matrix is applied to the geometry
    before placing it in the buffer.


Algorithm

    Get the surface header.
    Allocate the buffer.
    Fill in the information not provided in the header: poles, weights,
    knots, etc.

Return Status

   MSSUCC   - Success
   MSFAIL   - Failure

History

    10 Mar 88   AIC     Use EFknotVector to generate the knot vectors.
    28 Oct 87   AIC     Creation Date
*/
{
  extern   IGRchar                   *GRabsg_alloc();
 extern  IGRboolean  MArptsxform();
  IGRboolean                status;
  IGRlong                   sts = OM_S_SUCCESS;
  IGRlong                   total_bytes, total_poles;
  IGRlong                   num_bytes, i;
  IGRdouble                 *double_ptr, *weight_ptr;
  struct IGRbsp_surface     *surface, surface_header;
  struct GRabsg_hdr         absg_hdr;

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;

  /*
   * Get the surface header info
   */
  surface = &surface_header;
  sts = om$send(msg = message EMSsubbs.EMgetbsdef(EMmsg, surface),
                targetid = my_id);
  total_poles = surface->u_num_poles * surface->v_num_poles;

  /*
   * Calculate the abstract buffer size
   */
  EMSbs_size(surface->u_order, surface->v_order, surface->u_num_poles,
             surface->v_num_poles, surface->rational, 0, (IGRlong *)NULL,
             total_bytes)

  /*
   * Allocate the abstract buffer
   */
  absg_hdr.geometry_size = total_bytes;
  absg_hdr.id.objid = my_id;
  absg_hdr.id.osnum = OM_Gw_current_OS;
  absg_hdr.matrix_type = *matrix_type;
  num_bytes = sizeof(IGRmatrix);
  OM_BLOCK_MOVE(matrix, absg_hdr.matrix, num_bytes);
  surface = (struct IGRbsp_surface *) GRabsg_alloc(EMmsg, &absg_hdr);
  if (! (1 & *EMmsg)) goto wrapup;
  *surface = surface_header;

  /*
   * Partition the abstract buffer
   */
  EMSbs_partition(surface->u_order, surface->v_order,
                  surface->u_num_poles, surface->v_num_poles,
                  surface->rational, 0, (IGRlong *)NULL, surface)

  /*
   * Get a pointer to the poles
   */
  {
    struct EMSbsplineSurfaceHeader      *instance_data;

    instance_data = (struct EMSbsplineSurfaceHeader *)
                       me^^EMSsubbs.packed_data;
    double_ptr = instance_data->double_data;
  }

  /*
   * Transform the poles, if necessary
   */
  weight_ptr = double_ptr + 3 * total_poles;
  if(*matrix_type != MAIDMX)
  {
    status = MArptsxform(EMmsg, &total_poles, &surface->rational,
                         weight_ptr, matrix, double_ptr, surface->poles);
    if(! status) { *EMmsg = MSFAIL; goto wrapup; }
  }
  else
  {
    num_bytes = 3 * sizeof(IGRdouble) * total_poles;
    OM_BLOCK_MOVE(double_ptr, surface->poles, num_bytes);
  }
  double_ptr = weight_ptr;

  /*
   * Get the weights
   */
  if(surface->rational)
  {
    num_bytes = sizeof(IGRdouble) * total_poles;
    OM_BLOCK_MOVE(double_ptr, surface->weights, num_bytes);
    double_ptr += total_poles;
  }

  /*
   * Get the u knots
   */
  if (surface->u_non_uniform || surface->u_periodic)
  {
    num_bytes = sizeof(IGRdouble) * surface->u_num_knots;
    OM_BLOCK_MOVE(double_ptr, surface->u_knots, num_bytes);
    double_ptr += surface->u_num_knots;
  }
  else /* Make the knot vector */
  {
    EFknotVector(surface->u_order,surface->u_num_poles,surface->u_knots);
  }

  /*
   * Get the v knots 
   */
  if (surface->v_non_uniform || surface->v_periodic)
  {
    num_bytes = sizeof(IGRdouble) * surface->v_num_knots;
    OM_BLOCK_MOVE(double_ptr, surface->v_knots, num_bytes);
  }
  else /* Make the knot vector */
  {
    EFknotVector(surface->v_order,surface->v_num_poles,surface->v_knots);
  }

  /*
   * Return a pointer to the abstract geometry
   */
  *absgptr = (IGRchar *) surface;

wrapup:
  if EMSmsgReport(*EMmsg, "EMSsubbs.GRgenabsg", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSsubbs;
