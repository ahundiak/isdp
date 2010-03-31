class implementation EMSedge;

#define MX_INT 15
#define MAX_INT_SPANS 10
#define INIT_HOLD_SIZE 30
#define START 0
#define STOP 1

#include "emssfint.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "emsdattyp.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emsdef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "EMSbstrim.h"
#include "bscvkttol2.h"
#include "bschgdeppar.h"
#include "bschangepar.h"
#include "bsbxint.h"
#include "bsbx2.h"


void EMtrim_bspline_against_bspline (EMmsg, options, ingeom, against, 
                                bas_tol,ingeom_range, partinfo,
                                want_bnd_format, edge_props, getadjseg, 
                                adjdata, num_inters, 
                                against_inters, ingeom_inters)

IGRlong 		*EMmsg; 
IGRushort       options;
struct IGRbsp_curve     *ingeom;
struct IGRbsp_curve     *against;
IGRdouble		bas_tol;
IGRdouble		*ingeom_range;
struct EMSpartedinfo    *partinfo;
IGRboolean		want_bnd_format;
IGRushort	edge_props;
IGRlong 	        (*getadjseg) ();
struct EMSgetadjgeom    *adjdata;
IGRint			*num_inters;
struct EMSsfintedpar    **against_inters;
struct EMSpypoint	**ingeom_inters;
		
/* *************************************************************************

   Description

     This function trims an incoming bspline (pointed by against) with
respect to the geometry pointed by ingeom and returns the trim information
in the form of a linked list of EMSsfintedpar and EMSpypoint structures.

   Input 
   options : The following options are supported. See emsinterdef.h for
             explanation of these options

    EMS_INTER_BDRYISAREA 
    EMS_INTER_CUTTING
    EMS_INTER_STARTPT
    EMS_INTER_STOPPT 
    EMS_INTER_REMZEROEND 

   ingeom  : incoming bspline geometry which is to be trimmed.

   against : the geometry against which ingeom is trimmed.
             Both the incoming and against geomtry needs to be two 
             dimensional, but expressed as a 3d curve with z coordinate
             being 0. It does not have to lie within the parametric space.

   bas_tol : basis tolerance which needs to be used. So if the these
             two curves are in parametric space, parametric tolerance
             is expected

   ingeom_range : 2d range of the incoming geometry if known, or else set
             to NULL.

   partinfo :if the against buffer belonged to a part edge then information
             about the part edge needs to be sent. If the geometry does not
             belong to a part edge, the same "SHOULD" be set to null.

   want_bnd_format : if set to true, then the trim information of the against
             geometry is returned considering the geometry as being 
             constituted of bezier spans and each bezier span being parametrized
             from 0 to 1. An example when this is needed is for linear edges
             where the parametrizations is expressed in a manner as 
             described above. Callers whose "against" geometry does
             not belong to an edge, or who do not want the trim 
             parameters to be returned (after being mapped to an edge) need
             not worry about the explaination above and may safely set this
             option to FALSE.

   edge_props:
             If the "against" geometry was part of the edge; or if the trim
             parameters being returned need to be mapped on to an edge, then
             the edge properties of the edge need to be sent. If the 
             edge in question is a part edge then part edge props need to be
             sent etc. 

   getadjseg :
             It is a function pointer to get the first span of geometry of next
             edge or the next curve buffer lying ahead of the "against"
             geometry. This is necessary to unambiguosly classify an
             intersection as cutting or not. If this pointer is set to NULL,
             then should an end point intersection occur, the same is always
             returned. This function gets called when the next edge
             geometry is desired and takes in only one argument, a character
             pointer to a structure EMSgetadjgeom. The geometry of the next
             edge should be returned in the adjdata field of the 
             afore mentioned structure. The field geninfo serves as 
             a communication vehicle between the extraction function 
             and the EMSgetadjgeom structure. (See eminter.h for more
             information on EMSgetadjgeom structure). The memory for
             the span of the next edge is allocated  inside the function
             (equivalent to storing a bezier span of order 16).

  adjdata :  Pointer to a structure EMSgetadjgeom.
             

  Output
   num_inters Returns the number of intersections found.

   ingeom_inters Returns information about the intersection on the incoming
              geometry in a EMSpypoint structure, which is a linked list
              of intersection information on the incoming geometry. This 
              includes the 2d intersection point, span index and parameter
              of the intersection, and a properties word which describes
              the location of the intersection on the incoming geometry and
              whether the geometry goes from area to hole or hole to area etc.
 
   against_inters Returns information about the intersection on the "against"
              geometry in a EMSsfintedpar structure, which is a linked list
              of intersection information on against geometry, which includes
              intersection location, edge id on which this is occuring
              (NULL_OBJID) if the "against" geometry does not belong to an edge.
               edge parameter, the 2d intersection point.


Notes:

   Upon success the completion code will be one of the following:

   EMS_S_Success : if successful
   EMS_E_Fail    : if there is some form of failure
   EMS_E_BSerror : if there is a math error

Files


History

        PP          : Nov 1, 1987    Birth by C section  
        NP          : Jun 16,1993    If edge_props is EMED_REVERSED, 
                                     EMScvint_rtend should be replaced by 
                                     EMScvint_lfend and vice versa.
        Sudha       : 07/08/93       Modified for BSprototypes ansification
        SS          : Nov 3, 1993    Unrolled the above edge_props fix.
*********************************************************************** */


 
{
 IGRshort               i;
 IGRshort		l;
 IGRshort		degrees [2];
 IGRint			num_spans [2]; /* number of spans in ingeom and
                                          against geom */
 IGRint 			edind, toted, totc, edspn, cspn;
 IGRlong		rc;
 IGRboolean		memory_for_ints_allocated = FALSE;

 IGRboolean		bssts;
 IGRboolean		swapped_spans = FALSE;
                                       /* if swapped spans if false, then
                                          the inner loop is ingeom */
 IGRboolean		boxes_of_curves_intersect;
                             
 IGRboolean		hold_proc;
 IGRlong		int_no, size;        
 IGRdouble		int_2dpt[2];
 struct EMSpartolbasis  partol_basis;
 struct EMSinthold	inthold;
 struct EMSpypoint      pypthold_mem[INIT_HOLD_SIZE];
 struct EMSsfintedpar   eparhold_mem[INIT_HOLD_SIZE];

 IGRdouble		my_inters_par_buff[MX_INT],
                        cb_inters_par_buff[MX_INT];
 enum EMScvinttype      my_int_type_buff[MX_INT],
                        cb_int_type_buff[MX_INT];

 IGRpoint		int_pts_buff[MX_INT];

 enum EMSrelorient      cb_relorient_buff[MX_INT];

 IGRushort	trim_options;
 IGRushort	cbprops;

 IGRdouble		param_chord_tol, chord_height_tol;
 IGRdouble		*my_inters_par,
                        *cb_inters_par,
                        *int_pts;

 enum EMScvinttype      *my_int_type,
                        *cb_int_type;

 enum EMSrelorient      *cb_relorient;
 GRobjid		this_edge;

 IGRint			curve;
 IGRdouble		knot_tol[2];
 IGRdouble		basis_tol;
 IGRpoint		cv_min[2],
                        cv_max[2];     /* min max range for the two
                                          curves that are inputted */
                        
 struct IGRbsp_curve    *curves[2];
                        
 struct EMSedgebound    param, outpar;
 struct EMplanar_bezier_curve bezier0; /* bezier curve structure for
                                          the outer loop */
 struct EMplanar_bezier_curve bezext;  /* extension for bezier1 */
 struct EMplanar_bezier_curve *bez1;
 struct EMplanar_bezier_curve bezier1[MAX_INT_SPANS];
                                        /* bezier curve structure for
                                          the inner loop. A maximum of
                                          of MAX_INT_SPANS ARE STORED.
                                          Any span above that is 
                                          calculated on the fly */
 
 struct EMthis_spaninfo span_info;
 IGRdouble		fabs ();
 void			EMgetspan (); 
 void			EMmkeparlist ();
 void                   EMmkpyptlist ();
 void			EMcnvtedpar ();

/* 
 * Initialisation
 */

 *EMmsg = EMS_S_Success;
 int_pts = NULL;
 cb_inters_par = NULL;
 my_inters_par = NULL;
 cb_relorient = NULL;
 cb_int_type = NULL;
 my_int_type = NULL;
 curves[0] = against; /* outer loop */
 curves[1] = ingeom;  /* inner loop */
 inthold.num_inhold = 0;
 inthold.pypts = pypthold_mem;
 inthold.epars = against_inters ? eparhold_mem : NULL;
 inthold.malloc_at = INIT_HOLD_SIZE+1;

 partol_basis.tol = bas_tol;
 partol_basis.is_valid = TRUE;
 partol_basis.in_world = FALSE;
 
 trim_options = options;

 if (adjdata && adjdata->this_edge)
  this_edge = adjdata->this_edge;
 else
  this_edge = NULL_OBJID;

 bssts = BSEXTRACTPAR(&rc, BSTOLBASIS, basis_tol);
 bssts = BSEXTRACTPAR(&rc, BSTOLCHRDHT,chord_height_tol);

 BSchgdeppar (bas_tol, &rc);
 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

 param_chord_tol = (bas_tol / basis_tol) * chord_height_tol;

 bssts = BSchangepar(&rc,BSTOLCHRDHT, param_chord_tol);

 num_spans[0] = curves[0]->num_poles - curves[0]->order + 1;
 num_spans[1] = curves[1]->num_poles - curves[1]->order + 1;

/*
 * The inner loop is made up of that curve which has a lesser number
 * of spans
 */

 if (num_spans[0] < num_spans[1])
 {
   curves[0] = ingeom;
   curves[1] = against;
   swapped_spans = TRUE;
   num_spans[0] = num_spans[1];
   num_spans[1] = curves[1]->num_poles - curves[1]->order + 1;
 }

 for (curve =0; curve < 2; curve ++)
 {
   degrees[curve] = curves[curve]->order - 1;

   if (curves[curve]->rational)
   {
   (void) BSbx2 (&rc, &curves[curve]->num_poles,(IGRpoint *)curves[curve]->poles,
                 curves[curve]->weights, cv_min[curve], cv_max[curve]);
    EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
   }
   else
   {
   (void) BSbx2 (&rc, &curves[curve]->num_poles,(IGRpoint *)curves[curve]->poles,
                 NULL, cv_min[curve], cv_max[curve]);
    EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
   }
 }

 boxes_of_curves_intersect = BSbxint (&rc, cv_min[0], cv_max[0],
                             cv_min[1], cv_max[1]);
 EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

 if (boxes_of_curves_intersect)
 {
  IGRint ispans,
         jspans;
  IGRint span_index[2];
  IGRboolean boxes_of_spans_intersect,
             boxes_of_bz0_and_cv1_intersect;
   
/*
 * Get the knot tolerance for both curves
 */

   for (curve=0; curve < 2; curve ++)
   {
     BScvkttol2 (curves[curve]->order, curves[curve]->knots, 
                 curves[curve]->num_poles, curves[curve]->poles,
                 (curves[curve]->rational ? curves[curve]->weights : NULL), 
                 &knot_tol[curve], &rc);
     EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
   }

/*
 * Allocate memory for storing the intersections if necessary
 * else use the temporary bufers
 */

  if (curves[0]->order * (curves[1]->order) >= MX_INT)
  {
    memory_for_ints_allocated = TRUE;

    size = curves[0]->order * (curves[1]->order)  * sizeof (IGRdouble);
    my_inters_par = (IGRdouble *) om$malloc (size = size);
    EMerr_hndlr (!my_inters_par, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

    cb_inters_par = (IGRdouble *) om$malloc (size = size);
    EMerr_hndlr (!cb_inters_par, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

    int_pts = (IGRdouble *) om$malloc (size = 3 * size);
    EMerr_hndlr (!int_pts, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

    size = sizeof (enum EMScvinttype)*curves[0]->order*(curves[1]->order);

    my_int_type = (enum EMScvinttype *) om$malloc (size = size);
    EMerr_hndlr (!my_int_type, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

    cb_int_type = (enum EMScvinttype *) om$malloc (size = size);
    EMerr_hndlr (!cb_int_type, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

    size = sizeof (enum EMSrelorient) * curves[0]->order * curves[1]-> order;
    cb_relorient = (enum EMSrelorient *) om$malloc (size = size);
    EMerr_hndlr (!cb_int_type, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);
  }
  else
  {
    my_inters_par = my_inters_par_buff;
    cb_inters_par = cb_inters_par_buff;
    int_pts = (IGRdouble *)&int_pts_buff[0][0];
    my_int_type = my_int_type_buff;
    cb_int_type = cb_int_type_buff;
    cb_relorient = cb_relorient_buff;
  }

    bezier0.minmax.valid = FALSE;      
    bezier0.minmax.degenerate = FALSE;
    bezier0.curve.poles = (IGRdouble *) bezier0.poles;
    bezier0.curve.knots = (IGRdouble *) bezier0.knots;
    bezier0.curve.bdrys = NULL;
    bezier0.curve.phy_closed = 0;
    bezier0.curve.planar = 1;
    bezier0.curve.num_boundaries = 0;
    if (curves[0]->rational)
      bezier0.curve.weights = (IGRdouble *) bezier0.weights;
    else
      bezier0.curve.weights = NULL;

   
    bezext.minmax.valid = FALSE;
    bezext.minmax.degenerate = FALSE;
    bezext.curve.poles = (IGRdouble *)bezext.poles;
    bezext.curve.knots = (IGRdouble *)bezext.knots;
    bezext.curve.bdrys = NULL;
    bezext.curve.phy_closed = 0;
    bezext.curve.planar = 1;
    bezext.curve.num_boundaries = 0;
    if (curves[1]->rational)
      bezext.curve.weights = (IGRdouble *) bezext.weights;
    else
      bezext.curve.weights = NULL;

    for (i=0 ; i < MAX_INT_SPANS; i++)
    {
      bezier1[i].minmax.valid = FALSE;
      bezier1[i].minmax.degenerate = FALSE;
      bezier1[i].curve.poles = bezier1[i].poles;
      bezier1[i].curve.knots = bezier1[i].knots;
      bezier1[i].curve.bdrys = NULL;
      bezier1[i].curve.num_boundaries = 0;
      bezier1[i].curve.phy_closed = 0;
      bezier1[i].curve.planar = 1;
      if (curves[1]->rational)
       bezier1[i].curve.weights = bezier1[i].weights;
      else
       bezier1[i].curve.weights = NULL;
    }

    for (ispans=0, span_index[0] = degrees[0]; ispans < num_spans[0];
         ispans ++, span_index[0]++)
    {

      bezier0.minmax.valid = FALSE;
      bezier0.minmax.degenerate = 
       (curves[0]->knots[span_index[0]+1] - curves[0]->knots[span_index[0]] ) 
       < knot_tol[0];

 
      if (bezier0.minmax.degenerate)
        continue;

      EMgetspan (EMmsg, curves[0], &span_index[0], &bezier0);
      EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);

      boxes_of_bz0_and_cv1_intersect = BSbxint (&rc, bezier0.minmax.min,
         bezier0.minmax.max, cv_min[1], cv_max[1]);
      EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

      if (boxes_of_bz0_and_cv1_intersect)
      {
       for (jspans = 0, span_index[1] = degrees[1]; jspans < num_spans[1];
            jspans ++, span_index[1]++)
       {
        if (jspans < MAX_INT_SPANS)
         bez1 = &bezier1[jspans];
        else
        {
         bez1 = &bezext;
         bez1->minmax.valid = FALSE;
         bez1->minmax.degenerate = FALSE;
        }
 
        if (!bez1->minmax.valid)
        {
         bez1->minmax.degenerate = (curves[1]->knots[span_index[1]+1]
                - curves[1]->knots[span_index[1]]) < knot_tol[1];
         bez1->minmax.valid = bez1->minmax.degenerate;
        }

        if (bez1->minmax.degenerate)
         continue;
     
        if (!bez1->minmax.valid)
        {
          EMgetspan( EMmsg, curves[1], &span_index[1], bez1);
          EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);
        }

        boxes_of_spans_intersect = BSbxint (&rc, bezier0.minmax.min,
          bezier0.minmax.max, bez1->minmax.min, bez1->minmax.max);
        EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

        if (boxes_of_spans_intersect)
        {
/*
 * Call the routine to determine the cutting or simple intersections
 */
         if (swapped_spans)
         {
          span_info.this_spanindex = jspans;
          span_info.this_geom = against;
          span_info.knot_tol = knot_tol[1];

          edspn = jspans;
          edind = span_index[1];
          toted = num_spans[1];
          cspn = ispans;
          totc = num_spans[0];
         }
         else 
         {
          span_info.this_spanindex = ispans;
          span_info.this_geom = against;
          span_info.knot_tol = knot_tol[0];

          edspn = ispans;
          edind = span_index[0];
          toted = num_spans[0];
          cspn = jspans;
          totc = num_spans[1];
         }


         trim_options &= ~EMS_INTER_STARTPT;
         trim_options &= ~EMS_INTER_STOPPT;

         if (options & EMS_INTER_STARTPT)
         {
           if (cspn == 0)
             trim_options |= EMS_INTER_STARTPT;
         }
         
         if (options & EMS_INTER_STOPPT)
         {
           if (cspn == (totc - 1))
              trim_options |= EMS_INTER_STOPPT;
         }


         if (swapped_spans)
         {
          EMbsbscutint (EMmsg, &bez1->curve, &bezier0.curve, getadjseg,
                        adjdata, &span_info, trim_options, &int_no,
                        int_pts, my_inters_par, cb_inters_par, my_int_type,
                        cb_int_type, cb_relorient);
          EMerr_hndlr (EMis_error (*EMmsg), *EMmsg, *EMmsg, wrapup);
         }
         else
         {

          EMbsbscutint (EMmsg, &bezier0.curve, &bez1->curve, getadjseg,
                        adjdata, &span_info, trim_options, &int_no,
                        int_pts, my_inters_par, cb_inters_par, my_int_type,
                        cb_int_type, cb_relorient);
          EMerr_hndlr (EMis_error (*EMmsg), *EMmsg, *EMmsg, wrapup);
         }
         
         for (l=0 ; l < int_no; l++)
         {
           hold_proc = FALSE;
           cbprops = 0;
/*
 * if both the linked lists are set to null, then it is assumed that the
 * caller is interested in only knowing whether there is an intersection or
 * not
 */

         switch (cb_relorient[l])
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

            
         OM_BLOCK_MOVE (&int_pts[3*l], int_2dpt, 2 * sizeof(IGRdouble));
          
         if (edspn == (toted - 1)) /* if it is the last span on my edge */ 
          {
           if (my_int_type[l] != EMScvint_rtend)
             my_int_type [l] = EMScvint_middle;
          }
          else if (edspn == 0) /* if it is the first span on my edge */
          {
           if (my_int_type[l] != EMScvint_lfend)
             my_int_type [l] = EMScvint_middle;
          }
          else
             my_int_type[l] = EMScvint_middle;

          if (totc == 1)
          {
           switch (cb_int_type[l])
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
          if (cspn == (totc - 1))
          {
            if (cb_int_type[l] != EMScvint_rtend)
            {
              cbprops |= EMS_PYPT_ATMIDDLE;
              cb_int_type[l] = EMScvint_middle;
            }
            else cbprops |= EMS_PYPT_ATSTOP;
          }
          else if (cspn == 0)
          {
            if (cb_int_type[l] != EMScvint_lfend)
            {
              cb_int_type[l] = EMScvint_middle;
              cbprops |= EMS_PYPT_ATMIDDLE;
            }
            else cbprops |= EMS_PYPT_ATSTART;
          }
          else
          {
            if (options & EMS_INTER_BDRYISAREA)
              hold_proc = TRUE;
              cb_int_type[l] = EMScvint_middle;
              cbprops |= EMS_PYPT_ATMIDDLE;
          }
         }
          

         if (want_bnd_format)
         {
           param.span_inx = edspn;
           param.param = (my_inters_par[l] - against->knots[edind]) /
                         (against->knots[edind + 1] -
                          against->knots[edind]);

           if (edge_props)
            {
             if (edge_props & EMED_REVERSED)
               {
                param.span_inx = toted - param.span_inx - 1;
                param.param = 1.0 - param.param;
               }
             }

           if (partinfo)
           {
            EMcnvtedpar (EMmsg, &partinfo->edbdry[START],
                         &partinfo->edbdry[STOP],&param, &outpar);
            EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);

            param.span_inx = outpar.span_inx;
            param.param = outpar.param;

           }
          }
          else
          {
           param.span_inx = 0;
           param.param = my_inters_par[l];

           if (partinfo)
             param.param = partinfo->edbdry[START].param + 
                           (partinfo->edbdry[STOP].param - 
                            partinfo->edbdry[START].param) * param.param;
           else
           {
            if (edge_props)
            {
              if (edge_props & EMED_REVERSED)
                param.param = 1.0 - param.param;
            }
           }
          }

/*
 * Add code to handle processing of duplicate intersections 
 */
         if (hold_proc)
         {
          EMint_holdproc (EMmsg, param.span_inx, 0, param.param, 
                          cb_inters_par[l], my_int_type[l], &cb_int_type[l],
                          int_2dpt, &cbprops, &inthold, this_edge);
          EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);
         }
         else
         {
         EMint_process (EMmsg, against_inters, ingeom_inters, param.span_inx,
                        0, param.param, cb_inters_par[l], my_int_type[l],
                        cb_int_type[l], int_2dpt, this_edge, cbprops,
                        NULL); 
         EMerr_hndlr (EMis_error(*EMmsg), *EMmsg, *EMmsg, wrapup);
 
         ++ (*num_inters);
         }
                        

         if (!(against_inters) && !(ingeom_inters))
            goto wrapup;
         }
        } /* end if boxes of spans intersect */
       } /* end if boxes of bz0 and cv1 intersect */
      } /* end for each span in curves[1] */
     } /* end for each span in curves[0] */
    } /* end if boxes of curves intersect */

  if (inthold.num_inhold)
    {
      EMint_afterprocess (EMmsg, options, against_inters, ingeom_inters,
      num_inters, &inthold, NULL);
      EMerr_hndlr (EMis_error (*EMmsg), *EMmsg, *EMmsg, wrapup);
    }

wrapup :
 /*
  * Change the basis tolerance back to what it was 
  */

  BSchgdeppar (basis_tol, &rc);

  bssts = BSchangepar(&rc,BSTOLCHRDHT, chord_height_tol);

  if (inthold.num_inhold > INIT_HOLD_SIZE)
    {
    free (inthold.pypts);
    if (inthold.epars)
      free (inthold.epars);
    }


  if (memory_for_ints_allocated)
  {
   if (int_pts) om$dealloc (ptr = int_pts);
   if (cb_inters_par) om$dealloc (ptr = cb_inters_par);
   if (my_inters_par) om$dealloc (ptr = my_inters_par);
   if (my_int_type) om$dealloc (ptr = my_int_type);
   if (cb_int_type) om$dealloc (ptr = cb_int_type);
   if (cb_relorient) om$dealloc (ptr = cb_relorient);
  }
  return ;
}

end implementation EMSedge;
      
               
