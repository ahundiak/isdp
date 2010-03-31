/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This method returns the begin and the end point of an edge in
  parametric space(2D). If NULL is passed for the boundary, then the endpts
  are wrt the whole edge. Otherwise the input boundary is applied and the
  endpts are wrt the active part of the edge.

*/
class implementation EMSbsedge;

#include "EMS.h"
#include "emsmacros.h"
#include "bserr.h"
#include "bscveval.h"

#define X 0
#define Y 1
#define FROM_SPAN_INX 0
#define NUM_SPANS 1
#define NUM_DERIV 0

method EMendpts (IGRlong *EMmsg; 
		 IGRdouble *begin_pt,*end_pt;
        	 struct EMSedgebound *begin_param,*end_param;
                 struct EMSpartedinfo *bnd)
/* ***********************************************************************

Description 
            This method returns the endpoints of a bspline edge in parametric
            space
             
            Input
             bnd   -     if boundary information is passed in the endpoints
                         are returned with respect to the boundary
             
            Output
             begin_pt -  u, v value of the begin point of the edge
             end_pt   -  u, v value of the end point
             begin_param - begin parameter in the spanindex - parameter
                           format. span index is always 0
             end_param   - end parameter. Again span index is 0.

Notes
            Upon exit the completion code will be one of the following:
              EMS_E_EdgeError : if the method could not obtain the bspline
                                geometry
              EMS_E_Fail : if the math failed for whatever reason


Algorithm
            1. Get the true geometry of the whole bspline edge.
            if (boundary information exists)
             {
              assign the begin and end parameters appropriately
             }
            else
              since I am the edge, depending on whether I am reversed or
              not assign the begin and end parameters

            Do a curve evaluation to get the begin point
            If there are no boundaries coming in, and if I am physically
            closed then the end point is the same as the begin point
            else
            Do a curve evaluation to get the end point

Assumptions
            bnd->edbdry[0] is the begin parameter of the boundary
            bnd->edbdry[1] is the end parameter of the boundary

            the whole bspline edge spans from 0 to 1.

History    
            PP  : 04/02/87         Design date

            AMD : 01/28/92 :       fix for TR 92n0426.

            NP  : 02/11/92 :	   Undid the above fix, see comments in code.
                                   We cannot assume that the endpts of the edges                                   will ALWAYS lie between 0->1, since we have
                                   special "xyz" edges created during coincident
                                   plane processing that have their geometry 
                                   defined in Model space, which will break the
                                   above assumption.

	   SM  : 03/12/92 :	   Undid the undo of the fix! Snap to uv
				   only if this is not an xyz edge. Similar
				   check is done is EMgetpygeom.

	   Sudha 06/04/93	   modified to include BSprototype header files

*************************************************************************** */

{
    IGRlong		status; /* OM return status */

    struct IGRbsp_curve curve;  /* abstract geometry of the bspline edge in
                                   3-D assuming z coordinate to be 0 */

    BSrc		rc;

    struct EMSedgebound
                        begin_param_buff, 
                        end_param_buff;


    IGRpoint		evaluated_point;
                                /* to store the evaluated point of the
                                   bspline boundary */

 IGRboolean		isxyz;

    *EMmsg = EMS_S_Success;
    status = OM_S_SUCCESS;
    curve.poles = NULL;
    curve.weights = NULL;
    curve.bdrys = NULL;
    curve.knots = NULL;
 isxyz = ME.EMSedge->ed_props & EMED_XYZ;

/*
 * A null boundary is being passed in since we are interested in the true
 * geometry of the edge and not the logical geometry 
 */


    status = om$send (msg = message EMSedge.EMgetbcgeom (EMmsg, FROM_SPAN_INX,
                            NUM_SPANS, ME.EMSedge->ed_props & EMED_REVERSED,
                            NULL, &curve, NULL, NULL),
                      targetid = my_id);
    EMerr_hndlr ( !(1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);

    if (bnd) /* if boundary is present */
    {
       begin_param_buff.span_inx = bnd->edbdry[0].span_inx;
       begin_param_buff.param  = bnd->edbdry[0].param;

       end_param_buff.span_inx = bnd->edbdry[1].span_inx;
       end_param_buff.param = bnd->edbdry[1].param;
    }
    else
    {
       if (ME.EMSedge->ed_props & EMED_REVERSED)
       {
        begin_param_buff.span_inx = 0;
        begin_param_buff.param = 1.0;

        end_param_buff.span_inx = 0;
        end_param_buff.param = 0.0;
       }
       else
       {
        begin_param_buff.span_inx = 0;
        begin_param_buff.param = 0.0;

        end_param_buff.span_inx = 0;
        end_param_buff.param = 1.0;
       }
     }

/*
     BSadjpar(curve.knots, curve.order, curve.num_poles,
              &begin_param_buff.param, &rc);
*/
       if (begin_pt)
       {
        BScveval ( &curve, begin_param_buff.param , NUM_DERIV, 
                   (IGRpoint *)evaluated_point, &rc);
        EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

        /* SM: Activated the fix for non-xyz edges. 03/12/92
        */
        /* NP: Removed AMD fix below, since it was incorrectly getting
               endpts for "xyz" edges used in coincident plane processing
               whose geometry is not restricted to UV space bounds of 0->1.
        */
        /*          
           AMD : 01/28/92 : fix for TR 92n0426 
           temporary fix for 2.0. A more rigorous check should be
           done.
        */
        if(!isxyz)
         {
          if (evaluated_point[X] > 1.0 ) 
            evaluated_point[X] = 1.0;
          if (evaluated_point[X] < 0.0 )
            evaluated_point[X] = 0.0;

          if (evaluated_point[Y] > 1.0 ) 
            evaluated_point[Y] = 1.0;
          if (evaluated_point[Y] < 0.0 )
            evaluated_point[Y] = 0.0;
         }

        begin_pt[X] = evaluated_point[X];
        begin_pt[Y] = evaluated_point[Y];
       }

       if (end_pt) 
       {
           BScveval ( &curve, end_param_buff.param, NUM_DERIV, 
                      (IGRpoint *)evaluated_point, &rc);
           EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

        /* NP: Removed AMD fix below, since it was incorrectly getting
               endpts for "xyz" edges used in coincident plane processing
               whose geometry is not restricted to UV space bounds of 0->1.
        */
        if(!isxyz)
         {
          if (evaluated_point[X] > 1.0 ) 
            evaluated_point[X] = 1.0;
          if (evaluated_point[X] < 0.0 )
            evaluated_point[X] = 0.0;

          if (evaluated_point[Y] > 1.0 ) 
            evaluated_point[Y] = 1.0;
          if (evaluated_point[Y] < 0.0 )
            evaluated_point[Y] = 0.0;
         }
        end_pt[X] = evaluated_point[X];
        end_pt[Y] = evaluated_point[Y];
       }
         
       if (begin_param)
       {
        begin_param->span_inx = begin_param_buff.span_inx;
        begin_param->param = begin_param_buff.param;
       }

       if (end_param)
       {
        end_param->span_inx = end_param_buff.span_inx;
        end_param->param = end_param_buff.param;
       }


wrapup:
     if (curve.poles) om$dealloc (ptr = curve.poles);
     if (curve.knots) om$dealloc (ptr = curve.knots);
     if (curve.weights) om$dealloc (ptr = curve.weights);
     if (curve.bdrys) om$dealloc (ptr = curve.bdrys);
     EMWRAPUP (*EMmsg, status, "In EMSbsedge : EMendpts error ");
     return (status);
}

end implementation EMSbsedge;
    
