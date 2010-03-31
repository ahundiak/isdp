/* ###################   APOGEE COMPILED   ################## */
/* 
 * DESCRIPTION
 *
 * This method returns the range of a surface.  The range
 * may be returned in the local or world coordinate system.
 *
 * RETURN VALUES
 *
 * msg                  MSSUCC if success
 *                      MSFAIL if problems in allocating abstract buffer
 *
 * NOTES
 *
 * The range computed from the surface's instance data is in local coordinates
 * and this is also the range stored in the R-tree.  The range obtained
 * by transforming the surface by the input matrix will be in the current
 * master file space which is termed as the world coordinate system.
 *
 * HISTORY
 *
 * 09/21/86 : rlw : OM 4.0 conversion
 * 01/26/87 : rlw : Rewritten as per nucleus changes
 * 03/26/87 : rlw : Rewritten due to removal of range from instance data
 *                  Basically I took GRbcgetrang.I from the nucleus group
 *                  and mauled it.
 */

class implementation EMSsubbs;

#include "EMS.h"
#include <stdio.h>

# ifndef OM_D_MINIMUM
# include "OMminimum.h"     /* for gocmacros.h  */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"     /* for gocmacros.h  */
# endif

# ifndef gocmacros_include
# include "gocmacros.h"     /* GRgetabsg macro  */
# endif

#include "msdef.h"
#include "madef.h"
#include "OMmacros.h"
#include "EMSlogic.h"
#include "EMStypedef.h"
#include "EMScmacros.h"

method GRgetrang(
  IGRlong *msg;                         /* Error return code */
  IGRshort *matrix_type;                /* Matrix type code */
  IGRmatrix matrix;                     /* Transformation matrix */
  IGRboolean *world;                    /* Range desired in world system? */
  GRrange range)                        /* Return range */

{
 IGRchar        *old_ptr, *old_scratch;
 IGRshort       new_matrix_type;
 extern  IGRlong  GRabsg_test();
 IGRlong        in_buffer, old_size;
 IGRdouble      *new_matrix_ptr;
 IGRmatrix      identity_matrix;
 GRspacenum     osnum;
/*
 * Initialize
 */
 *msg = MSSUCC;
 osnum = OM_Gw_current_OS;
/*
 * Load a matrix based on whether world or local range is desired
 */
 if (*world)
  {
   new_matrix_type = *matrix_type;
   new_matrix_ptr = &matrix[0];
  }
 else
  {
 extern  IGRboolean  MAidmx();
   IGRboolean   status;

   new_matrix_type = MAIDMX;
   new_matrix_ptr = &identity_matrix[0];
   status = MAidmx(msg, identity_matrix);
  }
/*
 * Test to see if we are in the abstract buffer
 */
 in_buffer = GRabsg_test(
   msg,
   &new_matrix_type,
   new_matrix_ptr,
   &osnum,
   &my_id,
   &old_ptr);   
/*
 * If we were in the abstract buffer then we must save this buffer
 * and compute the range based on our instance data
 */
 if (in_buffer)
  {
   IGRboolean   status;
   IGRlong      *dummy = NULL;
   struct       IGRbsp_surface *old_surface;

   old_surface = (struct IGRbsp_surface *) old_ptr;
   EMSbs_size(
     old_surface->u_order,
     old_surface->v_order,
     old_surface->u_num_poles,
     old_surface->v_num_poles,
     old_surface->rational,
     0,                                 /* old_surface->num_boundaries */
     dummy,                             /* old_surface->points_per_bnd */
     old_size)
   old_scratch = (IGRchar *) om$malloc(size = old_size);
    if (!old_scratch)
     {
      *msg = MANOMEMORY;
      return(OM_E_ABORT);
     }
   OM_BLOCK_MOVE(old_ptr, old_scratch, old_size);
   status = GRabsg_del(old_ptr);        /* Force regeneration */
    if (!status)
     {
      om$dealloc(ptr = old_scratch);
      *msg = MSFAIL;
      return(OM_E_ABORT);
     }
  }
/*
 * Generate abstract data and compute range
 */
 {
  IGRchar       *generic_pointer;
 extern  IGRboolean  BSbx2();
  IGRboolean    status;
  IGRlong       i, loc_msg, total_poles;
  struct        IGRbsp_surface *surface;

  GRgetabsg(
    msg, 
    &new_matrix_type,
    new_matrix_ptr,
    &generic_pointer,
    i);
   if (!(1 & *msg))
    {
     if (in_buffer) om$dealloc(ptr = old_scratch);
     return(OM_E_ABORT);
    }
  surface = (struct IGRbsp_surface *) generic_pointer;
  surface->num_boundaries = 0;
  total_poles = surface->u_num_poles * surface->v_num_poles;
  status = BSbx2(
    &loc_msg,
    &total_poles,
    surface->poles,
    (surface->rational ? surface->weights : NULL),
    &range[0],
    &range[3]);
   if (!status)
    {
     if (in_buffer) om$dealloc(ptr = old_scratch);
     *msg = MSFAIL;
     return(OM_E_ABORT);
    }
 }
/*
 * Restore the abstract buffer, if necessary
 */
 if (in_buffer)
  {
   OM_BLOCK_MOVE(old_scratch, old_ptr, old_size);
   om$dealloc(ptr = old_scratch);
  }
/*
 * End of routine
 */
 return(OM_S_SUCCESS);
}

end implementation EMSsubbs;

