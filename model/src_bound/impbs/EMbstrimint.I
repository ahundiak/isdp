/* ###################   APOGEE COMPILED   ################## */

class implementation EMSbsedge;

#include "EMS.h"
#define FROM_SPAN_INX 0
#define NO_SPANS 1
#define START 0
#define STOP 1
#define ZERO_SPAN 0
#define MAX_INT 10
#define INIT_HOLD_SIZE 50

#include "emsdef.h" /* for EMSPY_ declarations */
#include "bserr.h"
#include "emssfint.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "emsinter.h"
#include "emsinterdef.h"
#include "bsparameters.h"
#include "EMSbstrim.h"
#include "OMmacros.h"
#include "bscvkttol2.h"
#include "bschgdeppar.h"
#include "bschangepar.h"
#include "bsbxint.h"
#include "bsbx2.h"

method EMedpytrimint (IGRlong *EMmsg;
                      struct IGRpolyline *inpoly;
                      IGRdouble *inpoly_range;
                      struct EMSpartolbasis *partol_basis;
                      struct EMSpartedinfo *partinfo;
                      IGRushort options;
                      IGRint *num_inters;
                      struct EMSsfintedpar **my_inters;
                      struct EMSpypoint **polyinters)
/* **************************************************************************

Description      This method trims a bsline edge against an incoming 
                 polyline. 


Notes: 
                 In the documentation the following convention has been
                 adopted
                 m - mygeometry which is the edge geometry against which the
                     incoming polyline is cutting.
                 c - cutting polyline
History          PP : 04/06/87        Design date
                 PP : 12/07/87        Fixed a problem which had to do with
                                      the intersection type on the edge not
                                      being set right
                 PP : 02/17/88 :      Fixed a problem wherein I was 
                                      causing a stop_sending when
                                      my_inters and poly_inters was NULL
                 PP : 11/10/88 :      Fixed a problem wherin an assumption
                                      that I had made earlier about no
                                      support for non-cutting intersections
                                      was no longer true. The problem
                                      showed up when options was set to
                                      non-cutting and the intersection
                                      happened to be at the beginning point
                                      of the edge.
		 DLB: 09/26/91 :      Pass *int to BSbx2 instead of
				      *short.  Sun problem.
	
                 Sudha 06/04/93       modified to include BSprototype header files

**************************************************************************** */

{
 IGRshort		i;
 IGRint 		no_mspans,
        		no_cspans;

 IGRlong		status;
 BSrc  			rc;

 GRobjid		dumid;

 IGRboolean		bssts, hold_proc;
 IGRboolean		memory_for_ints_allocated = FALSE;
                                        /* whether memory for storing 
                                           the intersection details has been
                                           allocated */
 IGRboolean		boxes_of_cm_intersect; 
                                        /* if boxes of polyline and myedge
                                           intersect */

 IGRlong		int_no;         /* total number of intersection found
                                           by trim */
 IGRushort      edge_props;
 IGRlong		size;

 IGRdouble		lentol;
 IGRdouble		param_chord_tol, chord_height_tol;
 IGRdouble		int_2dpt[2];

 struct EMSinthold	inthold;
 struct EMSpypoint      pypthold_mem[INIT_HOLD_SIZE];
 struct EMSsfintedpar   eparhold_mem[INIT_HOLD_SIZE];

 IGRdouble  		my_inters_par_buff[MAX_INT],
                        cb_inters_par_buff[MAX_INT],
                        int_pts_buff[MAX_INT][3];
 enum EMScvinttype      my_int_type_buff[MAX_INT],
                        cb_int_type_buff[MAX_INT];

 enum EMSrelorient      cb_relorient_buff[MAX_INT];
 IGRdouble		mpar;
                                                   
 IGRdouble		temp_range[4],    /* temporary range for calculating
                                             incoming poly range */
                        *poly_crange,
                        cmin[3], cmax[3], /* range of the cutting polyline*/
                        mmin[3], mmax[3]; /* range of my geometry */

 IGRdouble		basis_tol,
                        *my_inters_par, /* my intersection *params */
                        *cb_inters_par, /* cutting bspline intersection param */
                        *int_pts;       /* uv values of int points */

 GRobjid		sender_edge;

 struct EMplanar_bezier_curve bezier0;
                                        /* for storing the bezier spans of my
                                           geometry */
 enum EMSrelorient      *cb_relorient;
 IGRushort      cbprops, trim_options;

 enum EMScvinttype 	*my_int_type,   /* my intersection type */
                        *cb_int_type;   /* cutting bspline intersection type */

 struct IGRbsp_curve    mygeom;         /* structure to store bspline geometry
                                           of the edge */
 struct IGRbsp_curve    *span_ptr;
                                        /* dummy pointer to a span */

 IGRpoint  		poles[2];
 static IGRdouble 	knots[4] = { 0.0, 0.0, 1.0, 1.0 } ;

 struct IGRbsp_curve    line; /* structure to store a single 
                                  span of the polyline */
 struct EMSgetadjgeom   adjgeom;
 struct EMthis_spaninfo span_info;


 
 
 IGRboolean             EMbxint();
 IGRint			EMadjbs ();
 void			EMgetspan ();
 void			EMbsbscutint();
 void                   EMint_process ();
                        
 *EMmsg = EMS_E_Success;
 status = OM_S_SUCCESS;


 mygeom.poles = NULL;
 mygeom.knots = NULL;
 mygeom.weights = NULL;
 mygeom.bdrys = NULL;
 int_pts = NULL;
 cb_inters_par = NULL;
 my_inters_par = NULL;
 cb_int_type = NULL;
 my_int_type = NULL;

 inthold.num_inhold = 0;
 inthold.pypts = pypthold_mem;
 inthold.epars = my_inters ? eparhold_mem : NULL;
 inthold.malloc_at = INIT_HOLD_SIZE+1;

 bssts = BSEXTRACTPAR (&rc, BSTOLBASIS, basis_tol);
 EMerr_hndlr (!bssts, *EMmsg, EMS_E_Fail, wrapup);

 bssts = BSEXTRACTPAR(&rc, BSTOLCHRDHT, chord_height_tol);
/*
 bssts = BSEXTRACTPAR(&rc, BSTOLOVERLAP, overlap_tol);
*/

 trim_options = options;

 if (!partol_basis ->is_valid)
 {
  status = om$send (msg = message EMSboundary.EMgetsurface_info (EMmsg,
                          &dumid, partol_basis),
                    targetid = my_id);
  EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_EdgeError, wrapup);
 }

/* 
 * Get my active bspline geometry
 */

 BSchgdeppar (partol_basis->tol, &rc);
 EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);

 param_chord_tol = (partol_basis->tol / basis_tol) * chord_height_tol;

 bssts = BSchangepar(&rc,BSTOLCHRDHT, param_chord_tol);

/*
 bssts = BSchangepar(&rc,BSTOLOVERLAP, param_chord_tol);
*/

 status = om$send (msg = message EMSedge.EMgetbcgeom (EMmsg,
                         FROM_SPAN_INX, NO_SPANS, FALSE, partinfo, &mygeom,
                         partol_basis, NULL),
                   targetid = my_id);
 EMerr_hndlr (!(1 & status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);


 bssts = BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
 EMerr_hndlr (!bssts, *EMmsg, EMS_E_Fail, wrapup);

/*
 * Obtain the range of the input polyline and widen the range
 */

 if (inpoly_range)
  poly_crange = inpoly_range;
 else
  {
   poly_crange = temp_range;
   EM2dbx (inpoly->num_points, inpoly->points, poly_crange);
   EM2dbxinc (poly_crange, lentol);
  }

  no_mspans = mygeom.num_poles - mygeom.order + 1;
  no_cspans = inpoly->num_points - 1;

/*
 * Transfer the 2d range of the polyline into a 3d structure
 */

 cmin[0] = poly_crange[0];
 cmin[1] = poly_crange[1];
 cmin[2] = 0.0;
 cmax[0] = poly_crange[2];
 cmax[1] = poly_crange[3];
 cmax[2] = 0.0;

/* 
 * Get the range of the my geometry 
 */

 if (partinfo)
 {
  sender_edge = partinfo->edid;
  edge_props = partinfo->edprops;
 }
 else
 {
  sender_edge = my_id;
  edge_props = ME.EMSedge->ed_props;
 }


 if (mygeom.rational)
 {
 (void) BSbx2 (&rc, &mygeom.num_poles, (IGRpoint *) mygeom.poles,
               mygeom.weights, mmin, mmax);
 EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);
 }
 else
 {
 (void) BSbx2 (&rc, &mygeom.num_poles, (IGRpoint *) mygeom.poles,
               NULL, mmin, mmax);
 EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);
 }
 
 boxes_of_cm_intersect = BSbxint (&rc, cmin, cmax, mmin, mmax);
 EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);

 if (boxes_of_cm_intersect)
 {
  IGRint cindx,  
         mindx;

  IGRint mspn;
  IGRpoint lmin,
           lmax;
  IGRboolean boxes_of_py_mbp_intersect,
             boxes_of_spans_intersect,
             boxes_of_py_bz_intersect;
  IGRdouble my_knot_tol;


/*
 * Allocate memory if necessary for storing the parameters and intersection
 * points
 */

  if (mygeom.order * 2 >= MAX_INT)
  {
    memory_for_ints_allocated = TRUE;

    size = mygeom.order * 2 * sizeof (IGRdouble);
    my_inters_par = (IGRdouble *) om$malloc (size = size);
    EMerr_hndlr (!my_inters_par, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

    cb_inters_par = (IGRdouble *) om$malloc (size = size);
    EMerr_hndlr (!cb_inters_par, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

    int_pts = (IGRdouble *) om$malloc (size = 3 * size);
    EMerr_hndlr (!int_pts, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

    size = sizeof (enum EMScvinttype) * mygeom.order * 2;

    my_int_type = (enum EMScvinttype *) om$malloc (size = size);
    EMerr_hndlr (!my_int_type, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

    cb_int_type = (enum EMScvinttype *) om$malloc (size = size);
    EMerr_hndlr (!cb_int_type, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

    size = sizeof (enum EMSrelorient) * mygeom.order * 2 ;
    cb_relorient = (enum EMSrelorient *) om$malloc (size = size);
    EMerr_hndlr (!cb_int_type, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);
  }
  else
  {
    my_inters_par = my_inters_par_buff;
    cb_inters_par = cb_inters_par_buff;
    int_pts = (IGRdouble *)int_pts_buff;
    my_int_type = my_int_type_buff;
    cb_int_type = cb_int_type_buff;
    cb_relorient = cb_relorient_buff;
  }

  BScvkttol2 (mygeom.order, mygeom.knots, mygeom.num_poles, 
              mygeom.poles, mygeom.weights, &my_knot_tol, &rc);
  EMerr_hndlr (BSERROR	 (rc), *EMmsg, EMS_E_Fail, wrapup);

  bezier0.minmax.valid = FALSE;
  bezier0.minmax.degenerate = FALSE;
  span_ptr = &bezier0.curve;
  span_ptr->phy_closed = 0;
  span_ptr->planar = 1;
  span_ptr->poles = bezier0.poles;
  span_ptr->knots = bezier0.knots;
  if (mygeom.rational)
   span_ptr->weights = bezier0.weights;
  else
   span_ptr->weights = NULL; 
  span_ptr->bdrys = NULL;

/* Initialise the line structure representing a single span of the polyline */

 line.poles = &poles[0][0];
 line.num_poles = 2;
 line.order = 2;
 line.periodic = FALSE;
 line.non_uniform = FALSE;
 line.knots = knots;
 line.num_knots = 4;
 line.weights = NULL;
 line.bdrys = NULL;
 line.num_boundaries = 0;
 line.rational = FALSE;
 line.planar = TRUE;
 line.phy_closed = FALSE;
/* 
 * for each span in the incoming polyline do the following loop 
 */

 for (mindx = 0, mspn = mygeom.order - 1; mindx < no_mspans ; ++mindx,
      ++mspn)
 {

   bezier0.minmax.degenerate = (mygeom.knots[mspn + 1] - 
     mygeom.knots[mspn]) < my_knot_tol;

   if (bezier0.minmax.degenerate)
   {
    /* We dont worry about this span any more
     */
       continue;
   } 

   if (mygeom.rational)
   {
    IGRlong num_pts;
    num_pts = mygeom.order;  /*DLB SUN fix 9/26/91*/
    (void) BSbx2 ( &rc, &num_pts, (IGRpoint *)&mygeom.poles[mindx * 3],
           &mygeom.weights[mindx], bezier0.minmax.min, bezier0.minmax.max);
    EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);
   }
   else
   {
    IGRlong num_pts;
    num_pts = mygeom.order;  /*DLB SUN fix 9/26/91*/
    (void) BSbx2 ( &rc, &num_pts, (IGRpoint *)&mygeom.poles[mindx * 3],
           NULL, bezier0.minmax.min, bezier0.minmax.max);
    EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);
   }


   boxes_of_py_mbp_intersect = BSbxint (&rc, cmin, cmax,
                                 bezier0.minmax.min, bezier0.minmax.max);
   EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

   if (boxes_of_py_mbp_intersect)
   {
    EMgetspan (EMmsg, &mygeom, &mspn, &bezier0);
    EMerr_hndlr(EMis_error(*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   boxes_of_py_bz_intersect = BSbxint (&rc, cmin, cmax,
      bezier0.minmax.min, bezier0.minmax.max);
   EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_Fail, wrapup);

   if (boxes_of_py_bz_intersect)
   {

     for (cindx = 0; cindx < no_cspans ; cindx++)
     {
       lmin[0] = line.poles[0] = inpoly->points[2*cindx];
       lmin[1] = line.poles[1] = inpoly->points[2*cindx + 1];
       lmin[2] = line.poles[2] = 0.0;
       lmax[0] = line.poles[3] = inpoly->points[2*cindx + 2];
       lmax[1] = line.poles[4] = inpoly->points[2*cindx + 3];
       lmax[2] = line.poles[5] = 0.0;

       if (lmin[0] > lmax[0])
       {  
        lmin[0] = lmax[0];
        lmax[0] = line.poles[0];
       }
 
       if (lmin[1] > lmax[1])
       {
         lmin[1] = lmax[1];
         lmax[1] = line.poles[1];
        }

      boxes_of_spans_intersect = BSbxint (&rc, lmin, lmax, bezier0.minmax.min,
                  bezier0.minmax.max);
      EMerr_hndlr (BSERROR (rc), *EMmsg, EMS_E_Fail, wrapup);

     if (boxes_of_spans_intersect)
     {
      /* 

         Call a specilized routine to return the cutting intersections

         Doctor the intersection type returned from the routine to indicate
         if it is in the middle of the edge or on the right end. Intersections
         happening at the left end would not be returned as we have
         adopted the convention to ignore the beginning intersections at
         edges
       */

       span_info.this_spanindex = mindx;
       span_info.this_geom = &mygeom;
       span_info.knot_tol = my_knot_tol;

       adjgeom.this_edge = sender_edge;

       trim_options &= ~EMS_INTER_STARTPT;
       trim_options &= ~EMS_INTER_STOPPT;

       if (options & EMS_INTER_STARTPT)
        {
          if (cindx == 0)
            trim_options |= EMS_INTER_STARTPT;
        }
       
        if (options & EMS_INTER_STOPPT)
        {
          if (cindx == (no_cspans - 1))
             trim_options |= EMS_INTER_STOPPT;
        }

       adjgeom.geninfo = NULL;
         
       EMbsbscutint (EMmsg, &bezier0.curve, &line, EMadjbs, &adjgeom,&span_info,
       trim_options, &int_no,int_pts, my_inters_par, cb_inters_par, my_int_type,
                            cb_int_type, cb_relorient);
       EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

       for (i=0 ; i < int_no; i++)
       {

        hold_proc = FALSE;

        if (partinfo)
         {
          mpar = partinfo->edbdry[START].param + (partinfo->edbdry[STOP].param -
             partinfo->edbdry[START].param) * my_inters_par[i];
         }
        else
        {
          if (ME.EMSedge->ed_props & EMED_REVERSED)
            mpar = 1.0 - my_inters_par[i];
          else
            mpar = my_inters_par[i];
        }


       OM_BLOCK_MOVE (&int_pts[3*i],int_2dpt, 2*sizeof (IGRdouble));


/*
 * The following post processing step is necessary to correctly flag the 
 * intersection type occuring at my edge level. The information returned from
 * the function is with respect to the span and this needs to be converted
 * with respect to the edge. If the function is working correctly we should
 * not expect any intersections in the beginning of the edge. Hence all
 * intersection type execept that of the last span are classified as middle;
 * and the intersections on the last span is either middle or right.
 * This above assumption is no longer true when non-cutting intersections
 * are supported.
 */

 
/*
 * begin (removing assumption)
 *
 * If I am the first span and the only span then the intersection type
 * should not be changed. If I am the first span and not the only span
 * and intersection type happens to be at right end then make the
 * same to be middle.
 *
 * If I am any span except the last span then make the intersection type
 * to be middle.
 *
 * If I am the last span then the intersection type should be changed 
 * to middle if the intersection happened to be at the beginning.
 *                                        pp (11/10/88)
 */
    if (mindx == 0)
    {
      if ((mindx != no_mspans - 1) && (my_int_type[i] == EMScvint_rtend))
        my_int_type[i] = EMScvint_middle;
    }
    else if (mindx == no_mspans - 1) /* if it is the last span of my edge */
    {
     if (my_int_type[i] == EMScvint_lfend)
        my_int_type[i] = EMScvint_middle;
    }
    else
        my_int_type[i] = EMScvint_middle;

    cbprops = 0;

    switch (cb_relorient[i])
         {
           case EMSrelorient_hole_area:
            cbprops |= EMS_PYPT_HOLEAREA;
           break;

           case EMSrelorient_area_hole:
            cbprops |= EMS_PYPT_AREAHOLE;
           break;

           case EMSrelorient_hole_hole:
            cbprops |= EMS_PYPT_HOLEHOLE;
           break;

           case EMSrelorient_area_area:
            cbprops |= EMS_PYPT_AREAAREA;
           break;

           default:
            cbprops |= EMS_PYPT_RELUNKNOWN;
           break;
        }

          if (no_cspans == 1)
          {
           switch (cb_int_type[i])
           {
             case EMScvint_rtend:
              cbprops |= EMS_PYPT_ATSTOP;
             break;

             case EMScvint_lfend:
              cbprops |= EMS_PYPT_ATSTART;
             break;

             case EMScvint_middle:
              cbprops |= EMS_PYPT_ATMIDDLE;
             break;

             default:
              cbprops |= EMS_PYPT_POSUNKNOWN;
             break;
            }
          }
          else
          {
          if (cindx == (no_cspans - 1))
          {
            if (cb_int_type[i] != EMScvint_rtend)
            {
              cbprops |= EMS_PYPT_ATMIDDLE;
              cb_int_type[i] = EMScvint_middle;
            }
            else cbprops |= EMS_PYPT_ATSTOP;
          }
          else if (cindx == 0)
          {
            if (cb_int_type[i] != EMScvint_lfend)
            {
              cb_int_type[i] = EMScvint_middle;
              cbprops |= EMS_PYPT_ATMIDDLE;
            }
            else cbprops |= EMS_PYPT_ATSTART;
          }
          else
          {
           if (options & EMS_INTER_BDRYISAREA)
            hold_proc = TRUE;
               cb_int_type[i] = EMScvint_middle;
               cbprops |= EMS_PYPT_ATMIDDLE;
          }
         }

/*
 * Add code to handle processing of duplicate intersections
 */
         if (hold_proc)
         {
          EMint_holdproc (EMmsg, 0, cindx, mpar,
                          cb_inters_par[i], my_int_type[i], &cb_int_type[i],
                          int_2dpt, &cbprops, &inthold, sender_edge);
          EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);
         }
         else
         {
          EMint_process (EMmsg, my_inters, polyinters, 0,
                         cindx, mpar, cb_inters_par[i], my_int_type[i],
                         cb_int_type[i], int_2dpt, sender_edge, cbprops,
                         NULL); 
          EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);

          ++ (*num_inters);
         }
 

/*
 * Only an intersection is desired
 */

    if (!my_inters && !polyinters && (*num_inters))
    {
            status = OM_I_STOP_SENDING;
            goto wrapup;
    }

    }
     }  /* end if boxes of spans intersect */
    } /* end of for each span in pygeom */
   } /* endif boxes of py and bz intersect */
  } /* end if boxes of py and mbp intersect */
 } /* end of for each span in mygeom */
} /* end if boxes of cm intersect */
   
if (inthold.num_inhold)
 {
    EMint_afterprocess (EMmsg, options, my_inters, polyinters,
     num_inters, &inthold, NULL);
    EMerr_hndlr (EMis_error (*EMmsg), *EMmsg, *EMmsg, wrapup);
  }

wrapup :

/*
 * Change the basis tolerance back to what it was
 */


 BSchgdeppar  (basis_tol, &rc);

 bssts = BSchangepar(&rc,BSTOLCHRDHT, chord_height_tol);

/*
 bssts = BSchangepar(&rc,BSTOLOVERLAP, overlap_tol);
*/

  if (inthold.num_inhold > INIT_HOLD_SIZE)
    {
    free (inthold.pypts);
    if (inthold.epars)
      free (inthold.epars);
    }

 if (mygeom.poles) free (mygeom.poles);
 if (mygeom.knots) free (mygeom.knots);
 if (mygeom.weights) free (mygeom.weights);
 if (mygeom.bdrys) free (mygeom.bdrys);

 if (memory_for_ints_allocated)
 {
 if (int_pts) free (int_pts);
 if (cb_inters_par) free (cb_inters_par);
 if (my_inters_par) free (my_inters_par);
 if (my_int_type) free (my_int_type);
 if (cb_int_type) free (cb_int_type);
 if (cb_relorient) free (cb_relorient);
 }

 EMWRAPUP (*EMmsg, status, "In EMSbsedge: EMedpytrimint error");
 return (status);

}

end implementation EMSbsedge;
   


