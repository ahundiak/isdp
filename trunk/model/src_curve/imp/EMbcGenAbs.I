/* ###################   APOGEE COMPILED   ################## */
/* 
   DESCRIPTION
  
 This method generates the abstract data
 representation for a 3-D double precision curve
 and places the data in the standard buffer.  The
 input transformation matrix is applied to the
 object before placing it in the buffer.

 RETURN VALUES

 *msg	  IGRlong	 completion code
                         - MSSUCC if successful
                         - MSFAIL (severe) if failure
                           due to allocation problems
 **absgptr    IGRchar	 pointer to abstract geometry
  
 NOTES

 Extra memory is allocated since the green hill compiler
 aligns doubles on quadword boundaries.  Padding may
 occur between the curve structure and the start of
 the poles, weight, and knots.  
   
 ALGORITHM
  
 This method converts the 3-D double precision curve
 into its internal format (abstract geometry form).  A
 buffer is dynamically allocated and partitioned to hold
 a B-spline curve.  Then the curve is transformed to
 world coordinates using the input transformation matrix.
 The result (abstract geometry) is placed in the allocated
 buffer and the input pointer is modified to contain the
 address of this buffer.

 HISTORY

 REJ	04/21/86 : Creation date.
 MAS	08/07/86 : re-creation date.
 rlw	04/02/87 : Modified due to radical changes in the instance data
 dhm    02/22/88 : Added GR_NOTIFY_LISTENERS  
 dhm    06/09/88 : Took out GR_INQUIRED notification.
 Sudha  06/16/93     Modified for BSprototype ansification
 */

class implementation GRbcsubbc;

#include "EMS.h"
#include "madef.h"			/* Has MAIDMX */
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "OMmacros.h"			/* Has OM_BLOCK_MOVE macro */
#include "godef.h"
#include "gocmacros.h"
#include "marptsxfo.h"

method GRgenabsg(IGRlong *msg; IGRshort *matrix_type;
		 IGRmatrix matrix; IGRchar **absgptr)
{
  extern  IGRchar	*GRabsg_alloc();
 IGRboolean	is_rational, status;
 IGRlong	sts, num_knots, num_poles, dimension, num_bytes, i;
 IGRdouble	*double_ptr, *weight_ptr;
 struct     	IGRbsp_curve *curve;
 struct     	GRabsg_hdr absg_hdr;
/*
 * Initialize
 */
 sts = OM_S_SUCCESS;
 *msg = MSSUCC;
 is_rational = ME.GRbcsubbc->bc_props & GRIS_RATIONAL;
 num_knots = ME.GRbcsubbc->num_poles + ME.GRbcsubbc->order;
 num_poles = ME.GRbcsubbc->num_poles;
/*
 * Get a partitioned abstract buffer
 */
 {
  IGRshort		order, num_boundaries;
  extern   IGRboolean		GRgetbuffer();

  num_boundaries = 0;
  order = ME.GRbcsubbc->order;
  status = GRgetbuffer(
    msg,
    matrix_type,
    matrix,
    &num_poles,
    &order,
    &is_rational,
    &num_boundaries,
    &my_id,
    &curve);
   if (!status)
   {
     sts = OM_E_ABORT;
     goto ret_end;
   }

 }
/*
 * Fill the the curve data
 */
 curve->order = ME.GRbcsubbc->order;
 curve->periodic = ME.GRbcsubbc->bc_props & GRIS_PERIODIC;
 curve->non_uniform = ME.GRbcsubbc->bc_props & GRIS_NON_UNIFORM;
 curve->num_poles = ME.GRbcsubbc->num_poles;
 curve->num_knots = num_knots;
 curve->rational = is_rational;
 curve->planar = ME.GRgraphics->properties & GRIS_PLANAR;
 curve->phy_closed = ME.GRbcsubbc->bc_props & GRIS_PHY_CLOSED;
 curve->num_boundaries = 0;
 curve->bdrys = NULL;
/*
 * Transform the poles, if necessary
 */
 double_ptr = &ME.GRbcsubbc->packed_doubles[0];
 weight_ptr = double_ptr + 3 * ME.GRbcsubbc->num_poles;
 if(*matrix_type != MAIDMX)
  {
   status = MArptsxform(
     msg, 
     &num_poles, 
     &is_rational, 
     weight_ptr,
     matrix,
     &ME.GRbcsubbc->packed_doubles[0], 
     curve->poles);
    if (! status)
    {
      *msg = MSFAIL;
      sts = OM_E_ABORT;
      goto ret_end;
    }
  }
 else
  {
    num_bytes = 3 * sizeof(IGRdouble) * num_poles;
    OM_BLOCK_MOVE(
     double_ptr,
     curve->poles, 
     num_bytes);
  }
 double_ptr = weight_ptr;
/*
 * Get the weights
 */
 if (is_rational)
  {
   num_bytes = sizeof(IGRdouble) * ME.GRbcsubbc->num_poles;
   OM_BLOCK_MOVE(
     double_ptr,
     curve->weights, 
     num_bytes);
   double_ptr += ME.GRbcsubbc->num_poles;
  }
/*
 * Get the knots
 */
 if (curve->non_uniform || curve->periodic)
  {
   num_bytes = sizeof(IGRdouble) * num_knots;
   OM_BLOCK_MOVE(
     double_ptr,
     curve->knots, 
     num_bytes);
   double_ptr += num_knots;
  }
 else
  {
   IGRint	i;
   IGRdouble	knot_increment, knot;

   for (i = 0; i < ME.GRbcsubbc->order; i ++)
    {
     curve->knots[i] = 0.0;
    }
   knot_increment = 1.0 / (ME.GRbcsubbc->num_poles - 
                    ME.GRbcsubbc->order + 1.0);
   knot = 0.0;
   for (i = ME.GRbcsubbc->order; 
        i < ME.GRbcsubbc->num_poles;
        i++)
    {
     knot += knot_increment;
     curve->knots[i] = knot;
    }
   for (i = ME.GRbcsubbc->num_poles;
        i < num_knots; 
        i++)
    {
     curve->knots[i] = 1.0;
    }
  } /* ELSE FOR if (curve->non_uniform || curve->periodic) */
/*
 * Return a pointer to the abstract geometry
 */
 *absgptr = (IGRchar *) curve;

 ret_end:
   return(sts);
}

end implementation GRbcsubbc;
