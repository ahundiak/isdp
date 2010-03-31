/* ###################   APOGEE COMPILED   ################## */
class implementation EMSbsedge;

#include "EMS.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#define START 0
#define STOP 1
#include "OMmacros.h"
#define DEBUG 0
#if DEBUG
 #include <stdio.h>
#include "bsrev_cv.h"
#include "bspartofcv.h"
#include "bschgdeppar.h"
#endif

method EMgetbcgeom (IGRlong *EMmsg;
                    IGRint from_spaninx;
                    IGRint num_spans;
                    IGRboolean reverse;
                    struct EMSpartedinfo *bnd;
                    struct IGRbsp_curve *bcgeom;
                    struct EMSpartolbasis *partolbasis;
                    IGRushort options)


/* ******************************************************************

Description
             This method returns the bspline geometry of the edge. 
             It currently ignores the information about spans and the
             number of spans and returns the complete geometry of the bspline
             edge.  In consistency with the meaning of span used in 
             boolean operations for a linear edge, a bs edge has only one span
             with a span index of 0 and is also stored thus. For extracting
             the partial edge geometry if the caller decides to provide
             the memory then the same should be enough to support
             (whole_edge->num_poles + 2 * whole_edge->order - 1) poles
             and order equal to whole_edge->order. If the whole edge
             is rational then the part edge is also rational.
            

Notes:
             If the definition of span should change or need is felt for
             returning bezier spans the existing method needs to change.
             The allocated memory will be deallocated if the routine 
             encounters an error
             Upon exit the completion code will be one of the following:
             EMS_E_BSerror : If there was an error in calling a
                             bs math routine.
             EMS_E_DynamicMemoryAllocated : If there was an error in
                             mallocing memory.
             EMS_E_EdgeError : If there was an error in getting the
                               parametric tolerance from the edge.
             EMS_S_Success : If all is fine.

History
             PP : 01/05/89              Made changes to support the
                                        case (erstwhile returning 
                                        an EMS_E_InvalidArg) related to
                                        extraction of partial edge geometry
                                        into premalloced structures in
                                        bcgeom. It is assumed that  
                                        the maximum memory necessary for
                                        returning part edge geometry is 
                                        equivalent to supporting 
                                        ( whole_edge->num_poles +
                                         2*whole_edge->order - 1) 
                                        poles and order equal to 
                                        whole_edge->order.
                                          
             PP : 08/12/88              Made changes so that the
                                        basis tolerance is changed to
                                        parametric tolerance while within
                                        this function if a partial
                                        edge is coming in to keep the
                                        results consistent with the rest
                                        of the system. If the incoming
                                        parametrics tol field is set to NULL,
                                        it uses the model space tolerance.
             PP : 04/17/87              Pre natal 

             Sudha 06/04/93             modified to include BSprototype header files

   ****************************************************************** */

{
 IGRshort		i;
 IGRlong		status;
 IGRboolean		is_rational;
 IGRboolean 		memory_allocated = FALSE;
 IGRlong		num_knots,
                        num_poles,
                        num_bytes;
 IGRdouble		*double_ptr;
 IGRboolean             tolerance_changed = FALSE;
 IGRdouble              partol;
 IGRdouble              basis_tol;
 IGRboolean             bssts;
 struct			IGRbsp_curve partcv;
 BSrc			rc;



 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 partcv.poles = NULL;
 partcv.knots = NULL;
 partcv.weights = NULL;
 partcv.bdrys = NULL;
 double_ptr = NULL;

 bssts = BSEXTRACTPAR (&rc, BSTOLBASIS, basis_tol);
 EMerr_hndlr (!bssts, *EMmsg, EMS_E_BSerror, wrapup);

 partol = basis_tol;

 is_rational = ME.EMSbsedge->bs_props & EMBS_RATIONAL;
 num_knots = ME.EMSbsedge->num_poles + ME.EMSbsedge->order;
 num_poles = ME.EMSbsedge->num_poles;

 double_ptr = &ME.EMSbsedge->packed_doubles[0];
 
 if (!bcgeom->poles)
 {
  memory_allocated = TRUE;

  bcgeom->poles = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) * 3 *
                                           num_poles);
  EMerr_hndlr (!(bcgeom->poles), *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }

 if (!bcgeom->knots)
 {
  bcgeom->knots = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) *
                                           num_knots);
  EMerr_hndlr (!(bcgeom->knots), *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }

 if (is_rational)
 {
  if (!bcgeom->weights)
  {
   bcgeom->weights = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) *
                                             num_poles);
   EMerr_hndlr (!(bcgeom->weights), *EMmsg, 
                 EMS_E_DynamicMemoryAllocated, wrapup);
  }
 }

 bcgeom->periodic = ME.EMSbsedge->bs_props & EMBS_PERIODIC;
 bcgeom->non_uniform = ME.EMSbsedge->bs_props & EMBS_NON_UNIFORM;
 bcgeom->rational = is_rational;
 bcgeom->planar = TRUE;
 bcgeom->phy_closed = ME.EMSedge->ed_props & EMED_XYZ_CLOSED;
 bcgeom->order = ME.EMSbsedge->order;
 bcgeom->num_poles = ME.EMSbsedge->num_poles;
 bcgeom->num_knots = num_knots;
 bcgeom->num_boundaries = NULL;
 bcgeom->bdrys = NULL;

 for (i=0; i < num_poles; i++)
 {
  bcgeom->poles[3*i] = double_ptr[2*i];
  bcgeom->poles[3*i + 1] = double_ptr[2*i + 1];
  bcgeom->poles[3*i + 2] = 0.0;
 }

 double_ptr += 2*num_poles;

 if (is_rational)
 {
  num_bytes = sizeof (IGRdouble) * num_poles;
  OM_BLOCK_MOVE (double_ptr, bcgeom->weights, num_bytes);

  double_ptr += num_poles;
 }

 if (bcgeom->non_uniform || bcgeom->periodic)
 {
  num_bytes = sizeof (IGRdouble) * num_knots;
  OM_BLOCK_MOVE (double_ptr, bcgeom->knots, num_bytes);
 }
 else
 {
  IGRdouble knot_increment,
            knot;

  for (i=0 ; i< ME.EMSbsedge->order; i++)
   bcgeom->knots[i] = 0.0;

  knot_increment = 1.0 / (num_poles - ME.EMSbsedge->order + 1);
  knot = 0.0;

  for (i = ME.EMSbsedge->order; i < num_poles; i++)
  {
    knot += knot_increment;
    bcgeom->knots[i] = knot;

  }

  for (i = num_poles ; i < num_knots; i++)
   bcgeom->knots[i] = 1.0;
  }

 if (!bnd)
 {
  if ((!reverse && ME.EMSedge->ed_props & EMED_REVERSED) ||
      (reverse && !(ME.EMSedge->ed_props & EMED_REVERSED)))
  {
  BSrev_cv (&rc, bcgeom);
  EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
  }
 }
 else 
 {
  IGRdouble     mid_param = 0.0;
  IGRint	start_parinx, stop_parinx;
  IGRboolean	bssts;

  if (partolbasis)
  {
    if (partolbasis->is_valid)
     partol = partolbasis->tol;
    else
    {
      status = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg,
                              NULL, partolbasis),
                        targetid = my_id);
      EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);
      partol = partolbasis->tol;
    }
  }
  else
  {
/*
   IGRdouble matrix[16];
   IGRshort matrix_type = MAIDMX;
   IGRboolean bssts;
   struct EMSpartolbasis partol_basis;
   IGRint marc;
    
   bssts = MAidmx(&marc, matrix);
   EMerr_hndlr (!bssts, *EMmsg, EMS_E_MAerror, wrapup);

   partol_basis.in_world = FALSE;
   partol_basis.is_valid = FALSE;
   partol_basis.mattyp = NULL;
   partol_basis.mat = NULL;
   partol_basis.mattyp = &matrix_type;
   partol_basis.mat = matrix;

   status = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg,
                           NULL, &partol_basis),
                     targetid = my_id);
   EMerr_hndlr (! (1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);

   partol = partol_basis.tol;
   partol_basis.is_valid = TRUE;
*/
   partol = basis_tol;
  }

  BSchgdeppar (partol, &rc);
  EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
  
  tolerance_changed = TRUE;

  num_poles = bcgeom->num_poles + 2 * bcgeom->order - 1;

  partcv.poles = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) * 3 *
                                                 num_poles);
  partcv.knots = (IGRdouble *) om$malloc ( size = sizeof (IGRdouble) *
                                                (num_poles + bcgeom->order));
  if (is_rational)
  {
   partcv.weights = (IGRdouble *) om$malloc (size = sizeof (IGRdouble) *
                                                num_poles);
  }

  if (bcgeom->phy_closed) 
  {
   if(((bnd->edbdry[START].param > bnd->edbdry[STOP].param ) && 
     (!(bnd->edprops & EMED_REVERSED))) ||
     ((bnd->edbdry[START].param < bnd->edbdry[STOP].param) &&
     (bnd->edprops & EMED_REVERSED)))
    mid_param = 0.0;
   else
    mid_param = (bnd->edbdry[START].param + bnd->edbdry[STOP].param) / 2.0;
  }

/*
 * The following rigmarole has to be done to get the geometry of the edge
 * in the true direction of parametrization of the edge. 
 * parametrization of the edge.
 */
 
  if ((bnd->edbdry[START].param > bnd->edbdry[STOP].param))
  {
    start_parinx = 1;
    stop_parinx = 0;
  }
  else
  {  
    start_parinx = 0;
    stop_parinx = 1;
  }

  bssts = BSpartofcv (&rc, bcgeom, bnd->edbdry[start_parinx].param, mid_param,
                      bnd->edbdry[stop_parinx].param, &partcv);
  EMerr_hndlr (!bssts, *EMmsg, EMS_E_BSerror, wrapup);
  
/* ************************************************
 
 Have to orient the partial curve appropriately 
 
   ************************************************ */

 if ((!reverse && (bnd->edprops & EMED_REVERSED)) ||
      (reverse && !(bnd->edprops & EMED_REVERSED)))
 {
  BSrev_cv (&rc, &partcv);
  EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
 }

  if (memory_allocated) /* Memory allocated by this routine */
  {
   if (bcgeom->poles) om$dealloc (ptr = bcgeom->poles);
   if (bcgeom->knots) om$dealloc (ptr = bcgeom->knots);
   if (bcgeom->weights) om$dealloc (ptr = bcgeom->weights);

   bcgeom->poles = partcv.poles;
   bcgeom->knots = partcv.knots;

   if (is_rational)
    bcgeom->weights = partcv.weights;
/*
 * Since we have access to the memory location of the partcurve poles, knots
 * and weights its better to set them to null
 */
   partcv.poles = NULL;
   partcv.knots = NULL;
   partcv.weights = NULL;
  }
  else /* Memory is malloced by the caller */
  {

    OM_BLOCK_MOVE (partcv.poles, bcgeom->poles, sizeof(IGRdouble) * 3 *
                   partcv.num_poles);

    OM_BLOCK_MOVE (partcv.knots, bcgeom->knots, sizeof(IGRdouble) *
                   (partcv.num_poles + partcv.order));

    if (is_rational)
     OM_BLOCK_MOVE (partcv.weights, bcgeom->weights, sizeof (IGRdouble) *
                    partcv.num_poles);
  }

/*
 * Rest of the information should remain the same
 */

  bcgeom->num_poles = partcv.num_poles;
  bcgeom->num_knots = partcv.num_knots;
  bcgeom->order = partcv.order;
  bcgeom->phy_closed = partcv.phy_closed;
  bcgeom->non_uniform = partcv.non_uniform;
  bcgeom->periodic = partcv.periodic;
  bcgeom->rational = partcv.rational;

 }
 

wrapup:

if (tolerance_changed)
  BSchgdeppar (basis_tol, &rc);

  if (! (1 & status & *EMmsg))
  {
    if (memory_allocated)
    {
    if (bcgeom->poles) free (bcgeom->poles);
    if (bcgeom->knots) free (bcgeom->knots);
    if (bcgeom->weights) free (bcgeom->weights);
    if (bcgeom->bdrys) free (bcgeom->bdrys);
    }

    if (partcv.poles) free (partcv.poles);
    if (partcv.weights)free(partcv.weights);
    if (partcv.knots) free (partcv.knots);
    if (partcv.bdrys) free (partcv.bdrys);

  }

  EMWRAPUP (*EMmsg, status, "In EMSbsedge : EMgetbcgeom error");
  return (status);

}

end implementation EMSbsedge; 
