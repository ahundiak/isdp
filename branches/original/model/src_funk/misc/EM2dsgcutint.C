/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
  DESCRIPTION

    This function is used to determine "cutting" intersection between two
    2D-segments. Cutting intersection is different from a regular intersection
    in that the area bounded by one of the segments (W-vector) is taken into
    consideration. The other segment (C-vector) is said to have an intersection
    with the W-vector, iff it "cuts" into or out of the area so bounded.

    An intersection at the W-vector's start point is ignored. A "cutting"
    intersection at the stop-point is ambiguos unless the the following
    W-vector is also known, so that the bounded area is now determinable.
    For this purpose a third point (that immediately follows the W-vector)
    is taken in as input. If the argumnet corresponding to this point is
    NULL, a stop-point condition results in an intersection regardless.

    The relative position of the intersection point as well as the relative
    position of the intersecting vectors is returned via an enumerated
    type - one for the W-vector and one for the C-vector.

  ARGUMENTS

    wpt1, wpt2		- Input: Together these two points define the W-vector
    wpt3		- Input: This point taken after wpt2, defines the
			  following W-vector. Could be NULL.
    cpt1, cpt2		- Input: Together these two points define the C-vector
    basis_tol		- Input: The basis tolerance from which all other 
			  tolerances may be derived using the function
			  EFextract_par. The various tolerances used are
                          BSTOLLENVEC and BSTOLCOLLINVEC.
    options		- Input: This bit-mask provides for some special
			  processing that might be desired. Currently,
			  the following options are supported:
                            EMS_INTER_STARTPT - Regardless of the intersection
			      being cutting or not, if the start-point
			      of C-vector is common with W-vector return it
                              as an intersection.
                            EMS_INTER_STOPPT - The above criteria for the
			      stop-point.
    numinters		- Output: The number of intersections output. This
                          can be one or two. It is two only in cases when
                          C-vector and W-vector overlap and the endpoint(s)
                          options are on.
    wtype, ctype	- Output: The type of intersection as seen by the
			  W-vector and C-vector respectively.
                            EMScvint_lfend - intersections at start-point
                             (possible output only for ctype)
			    EMScvint_rtend - intersections at stop-point
                             (possible output for both wtype and ctype)
			    EMScvint_middle - intersection at middle.
                             (possible output for both wtype and ctype)
    wpar, cpar		- Output: The parameter on the W-vector and
			  the C-vector (segment parameterized from 0.0
			  to 1.0) at which the intersection took place.
    pt			- Output: The intersection point.
    relorient		- Output: This enumerated type returns the relative
			  orientation of the C-vector w.r.t. the W-vector.
			  There are four possible orientations that are
			  returned (and are self-explanatory):
			    EMSrelorient_area_hole - cutting intersection
			    EMSrelorient_hole_area - cutting intersection
			    EMSrelorient_hole_hole - this indicates that
			      it is not a cutting intersection but because of
			      the special processing implied in the options
			      an intersection is being returned.
			    EMSrelorient_unknown - this indicates that
                             insufficient information is availble
                             to make a judgement about the C-vectors
                             progreesion relative to the area.

  RETURN VALUE

    This function returns a TRUE if an intersection has been found; a
    FALSE otherwise.
    
  NOTES

    See files emsinterdef.h for options.

  HISTORY

    SS  :  11/01/86  :  Creation
    SS  :  10/01/87  :  Changed the name from EM2dpycutint to EM2dsgcutint
                        Added support for the options mask and the relorient
                        argument.
    SS  :  11/04/87  :  Added the numinters argument. This is to support
                        1 or 2 intersections being returned; the latter in
                        the case where an overlap occurs and the endpoint(s)
                        options are on.
    SS  :  02/24/88  :  Changed the call to sign_cross and sign_cross_val
                        to EM2dcrossp - now a general function.
    SS  :  11/25/88  :  Removed all short-cut computations of cross-products
                        specially s2 = c1 + c3 - c4. This value was more
                        prone to tolerancing errors than the direct 
                        cross-product evaluation.
    SS  :  02/24/89  :  When an 'internal' intersection point is to be
			computed, check if W-segment is vertical/horizontal.
			If so, plug the exact X/Y value into the output
			point to remove any numerical instabilities.
*/

#include "EMS.h"
#include <math.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsdef.h"
#include "bserr.h"
#include "bsparameters.h"

#define X 0
#define Y 1

#define ZERO 0
#define NEGATIVE 1
#define POSITIVE 2
#define ZERO_NEGATIVE ZERO + NEGATIVE
#define NEG_POSITIVE NEGATIVE + POSITIVE

#define T_S 0
#define T_T 1
#define S_S 2
#define S_T 3

static IGRboolean EMonvector();

IGRboolean EM2dsgcutint (wpt1, wpt2, wpt3, cpt1, cpt2, basis_tol, options,
                         numinters, wtype, ctype, wpar, cpar, pt, relorient)
IGRdouble *wpt1, *wpt2, *wpt3, *cpt1, *cpt2, basis_tol;
IGRushort options;
IGRint *numinters;
enum EMScvinttype *wtype, *ctype;
IGRdouble *wpar, *cpar, *pt;
enum EMSrelorient *relorient;
{
   IGRboolean onvector, intfound;
   IGRshort s1, s2, s3, s4;
   IGRshort s1a, s2a, s4a, s;
   IGRlong msg_loc;
   IGRdouble c1, c2, c3, c4, c1a, c2a, c4a;
   IGRdouble ac1, ac2, ac3, ac4, ac1a, ac2a, ac4a;
   IGRdouble vc[2], vc1[2], vc2[2], vc2a[2];
   IGRdouble vw[2], vw1[2], vw2[2];
   IGRdouble vwa[2], vw1a[2], vw2a[2];
   IGRdouble coltol;
   IGRdouble locpar, locpt[2], locval;
   enum EMScvinttype loctype;
   IGRboolean EFextract_par();
   IGRint EM2dcrossp();
/*
   IGRboolean EMonvector();
*/

   *numinters = 0;
   intfound = FALSE;

   EFextract_par (BSTOLCOLLINVEC, basis_tol, &coltol, &msg_loc);

   vc[X] = cpt2[X] - cpt1[X];
   vc[Y] = cpt2[Y] - cpt1[Y];
   vc1[X] = wpt1[X] - cpt1[X];
   vc1[Y] = wpt1[Y] - cpt1[Y];
   vc2[X] = wpt2[X] - cpt1[X];
   vc2[Y] = wpt2[Y] - cpt1[Y];

   s3 = EM2dcrossp (&coltol, vc, vc1, &ac3, &c3);
   s4 = EM2dcrossp (&coltol, vc, vc2, &ac4, &c4);


   /***************************************
   If the following check is true, no end-
   point condition exists.
   ***************************************/

   if (s3 != ZERO && s4 != ZERO)                         
       {
       
       /***************************************
       W-vector on the same side of C-vector.
       Hence reject.
       ***************************************/
       if (s3 == s4) return (intfound);

       vw[X] = wpt2[X] - wpt1[X];
       vw[Y] = wpt2[Y] - wpt1[Y];
       vw1[X] = cpt1[X] - wpt1[X];
       vw1[Y] = cpt1[Y] - wpt1[Y];
       vw2[X] = cpt2[X] - wpt1[X];
       vw2[Y] = cpt2[Y] - wpt1[Y];

       s1 = EM2dcrossp (&coltol, vw, vw1, &ac1, &c1);
       s2 = EM2dcrossp (&coltol, vw, vw2, &ac2, &c2);

       /***************************************
       C-vector on the same side of W-vector.
       Hence reject.
       ***************************************/

       if (s1 == s2) return (intfound);

       /***************************************
       Mid-intersection but C-vector entirely
       on space-side of W-vector except for end-
       point of C-vector, which lies on the W-vector.
       Hence reject. But if the endpoint options
       is on, return intersections appropriately.
       ***************************************/

       if (s1 + s2 == ZERO_NEGATIVE)
         {
         if (s1 == ZERO && options & EMS_INTER_STARTPT)
           *cpar = 0.0;
         else if (s2 == ZERO && options & EMS_INTER_STOPPT)
           *cpar = 1.0;
         else
           return (intfound);
         *ctype = (s1 == ZERO ? EMScvint_lfend : EMScvint_rtend);

         *wpar = ac3 / (ac3 + ac4);
         *wtype = EMScvint_middle;
         pt[X] = (s1 == ZERO ? cpt1[X] : cpt2[X]);
         pt[Y] = (s1 == ZERO ? cpt1[Y] : cpt2[Y]);
         *relorient = EMSrelorient_hole_hole;
         (*numinters)++;
         intfound = TRUE;
         return (intfound);
         }

       /***************************************
       A cutting intersection exists. Compute
       line-seg parameter at the intersection
       and return the results on the argument
       list.
       ***************************************/

       if (s1 == ZERO || s2 == ZERO) 
         {
         *cpar = (s1 == ZERO ? 0.0 : 1.0);
         pt[X] = (s1 == ZERO ? cpt1[X] : cpt2[X]);
         pt[Y] = (s1 == ZERO ? cpt1[Y] : cpt2[Y]);
         *ctype = (s1 == ZERO ? EMScvint_lfend : EMScvint_rtend);
         }
       else 
         {
         *cpar = ac1 / (ac1 + ac2);
         if (fabs (vw[X]) < MINDOUBLE)
           pt[X] = wpt1[X];
         else
           pt[X] = cpt1[X] + *cpar * vc[X];
         if (fabs (vw[Y]) < MINDOUBLE)
           pt[Y] = wpt1[Y];
         else
           pt[Y] = cpt1[Y] + *cpar * vc[Y];
         *ctype = EMScvint_middle;
         }
       *wpar = ac3 / (ac3 + ac4);
       *wtype = EMScvint_middle;
       if (s3 == NEGATIVE) 
         *relorient = EMSrelorient_area_hole;
       else
         *relorient = EMSrelorient_hole_area;
       (*numinters)++;
       intfound = TRUE;
       return (intfound);
       }

       /***************************************
       An end-point or a coincidence condition
       exists.
       ***************************************/
   else
       {

       /***************************************
       Reject any C-edge that neither passes
       through the start-point of W-edge nor is
       it coincident with it.
       ***************************************/

       if (s4 != ZERO) return (intfound);                  

       if (s3 == ZERO && s4 == ZERO)
         {
         /*************************************
         The two vectors are in-line. If any of 
         the endpoint options are on, check if
         the specified endpoint lies in the 
         middle of the W-vector. These 
         "intersections" will not be picked up
         by the rest of the logic.
         **************************************/

         if (options & EMS_INTER_STARTPT)
           {
           onvector = EMonvector (cpt1, wpt1, wpt2, basis_tol, 
                       NULL, &locpar, &loctype, locpt);
           if (onvector && loctype == EMScvint_middle)
             {
             *cpar++ = 0.0;
             *ctype++ = EMScvint_lfend; 
             *relorient++ = EMSrelorient_hole_hole;
             *wpar++ = locpar;
             *wtype++ = loctype;
             *pt++ = locpt[X]; *pt++ = locpt[Y];
             (*numinters)++;
             intfound = TRUE;
             }
           }
         
         if (options & EMS_INTER_STOPPT)
           {
           onvector = EMonvector (cpt2, wpt1, wpt2, basis_tol, 
                       NULL, &locpar, &loctype, locpt);
           if (onvector && loctype == EMScvint_middle)
             {
             *cpar++ = 1.0;
             *ctype++ = EMScvint_rtend; 
             *relorient++ = EMSrelorient_hole_hole;
             *wpar++ = locpar;
             *wtype++ = loctype;
             *pt++ = locpt[X]; *pt++ = locpt[Y];
             (*numinters)++;
             intfound = TRUE;
             }

           if (*numinters == 2)
             return (intfound);
           }
         }
       
       if (! wpt3) 
         {

         /***********************************
         The information necessary to determine
         the true space-half-space bounded by
         the wpt-segments is missing. An
         intersection is realised based simply
         on the fact whether wpt2 touches the
         C-vector at all.
         ***********************************/

         onvector = EMonvector (wpt2, cpt1, cpt2, basis_tol, 
                     NULL, cpar, ctype, pt);
         if (onvector)
           {
           *wpar = 1.0;
           *wtype = EMScvint_rtend;
           *relorient = EMSrelorient_unknown;
           (*numinters)++;
           intfound = TRUE;
           return (intfound);
           }
         else
           return (intfound);
         }

       vwa[X] = wpt3[X] - wpt2[X];
       vwa[Y] = wpt3[Y] - wpt2[Y];
       vw1a[X] = cpt1[X] - wpt2[X];
       vw1a[Y] = cpt1[Y] - wpt2[Y];
       vw2a[X] = cpt2[X] - wpt2[X];
       vw2a[Y] = cpt2[Y] - wpt2[Y];
       vc2a[X] = wpt3[X] - cpt1[X];
       vc2a[Y] = wpt3[Y] - cpt1[Y];

       s1a = EM2dcrossp (&coltol, vwa, vw1a, &ac1a, &c1a);
       s2a = EM2dcrossp (&coltol, vwa, vw2a, &ac2a, &c2a);
       s4a = EM2dcrossp (&coltol, vc, vc2a, &ac4a, &c4a);

       /***************************************
       C-vector does not pass through the start-
       point of the following W-vector. Hence,
       reject.
       ***************************************/

       if (s1a == s2a && s1a != ZERO) return (intfound);   

       /***************************************
       The C-vector is in-line with W-vector.
       ***************************************/

       if (s3 == ZERO)                                   
           {
           vw[X] = wpt2[X] - wpt1[X];
           vw[Y] = wpt2[Y] - wpt1[Y];
           s = EM2dcrossp (&coltol, vw, vwa, &locval, &locval);

           /***************************************
           A convex vertex. Hence reject. But if 
           endpoint options are on, return intersection
           appropriately.
           ***************************************/

           if (s != NEGATIVE && 
               ((options & EMS_INTER_STARTPT) ||
                (options & EMS_INTER_STOPPT)))
             {
             onvector = EMonvector (wpt2, cpt1, cpt2, basis_tol, options,
                         cpar, ctype, pt);
             if (onvector)
               {
               *wpar = 1.0;
               *wtype = EMScvint_rtend;
               *relorient = EMSrelorient_hole_hole;
               (*numinters)++;
               intfound = TRUE;
               return (intfound);
               }
             else
               return (intfound);
             }
           else if (s != NEGATIVE)
             return (intfound);

           /***************************************
           C-vector on space side of the workpiece
           except for it's end-point. Hence reject.
           But if the end-point options are on, return
           an intersection appropriately.
           ***************************************/

           if (s1a + s2a == ZERO_NEGATIVE) 
             {
             if (s1a == ZERO && options & EMS_INTER_STARTPT)
               *cpar = 0.0;
             else if (s2a == ZERO && options & EMS_INTER_STOPPT)
               *cpar = 1.0;
             else
               return (intfound);
             *ctype = (s1a == ZERO ? EMScvint_lfend : EMScvint_rtend);

             *wpar = 1.0;
             *wtype = EMScvint_rtend;
             pt[X] = wpt2[X];
             pt[Y] = wpt2[Y];
             *relorient = EMSrelorient_hole_hole;
             (*numinters)++;
             intfound = TRUE;
             return (intfound);
             }

           /***************************************
           An end-point intersection is recognised.
           ***************************************/

           if (s1a == ZERO || s2a == ZERO) 
             {
             *cpar = (s1a == ZERO ? 0.0 : 1.0);
             *ctype = (s1a == ZERO ? EMScvint_lfend : EMScvint_rtend);
             }
           else
             {
             *cpar = ac1a / (ac1a + ac2a);
             *ctype = EMScvint_middle;
             }
           *wpar = 1.0;
           *wtype = EMScvint_rtend;
           pt[X] = wpt2[X];
           pt[Y] = wpt2[Y];
           if (s1a == POSITIVE) 
             *relorient = EMSrelorient_area_hole;
           else
             *relorient = EMSrelorient_hole_area;
           (*numinters)++;
           intfound = TRUE;
           return (intfound);
           }

       /***************************************
       C-vector collinear with the following
       W-vector.
       ***************************************/
    
       else if (s4a == ZERO)        
           {
           vw[X] = wpt2[X] - wpt1[X];
           vw[Y] = wpt2[Y] - wpt1[Y];
           s = EM2dcrossp (&coltol, vw, vwa, &locval, &locval);

           /***************************************
           W-vertex is convex. Hence reject. But if 
           endpoint options are on, return intersection
           appropriately.
           ***************************************/

           if (s != NEGATIVE && 
               ((options & EMS_INTER_STARTPT) ||
                (options & EMS_INTER_STOPPT)))
             {
             onvector = EMonvector (wpt2, cpt1, cpt2, basis_tol, options,
                         cpar, ctype, pt);
             if (onvector)
               {
               *wpar = 1.0;
               *wtype = EMScvint_rtend;
               *relorient = EMSrelorient_hole_hole;
               (*numinters)++;
               intfound = TRUE;
               return (intfound);
               }
             else
               return (intfound);
             }
           else if (s != NEGATIVE)
             return (intfound);

           vw[X] = wpt2[X] - wpt1[X];
           vw[Y] = wpt2[Y] - wpt1[Y];
           vw1[X] = cpt1[X] - wpt1[X];
           vw1[Y] = cpt1[Y] - wpt1[Y];
           vw2[X] = cpt2[X] - wpt1[X];
           vw2[Y] = cpt2[Y] - wpt1[Y];

           s1 = EM2dcrossp (&coltol, vw, vw1, &ac1, &c1);
           s2 = EM2dcrossp (&coltol, vw, vw2, &ac2, &c2);
      
           /***************************************
           C-vector does not pass through the forward
           end-point of the W-vector. Hence reject.
           ***************************************/

           if (s1 == s2 && s1 != ZERO) return (intfound);  

           /***************************************
           C-vector entirely on space-side of the 
           workpiece, except for an end-point. Hence
           reject. But if the enpoint options are
           on, return intersection appropriately.
           ***************************************/

           if (s1 + s2 == ZERO_NEGATIVE) 
             {
             if (s1 == ZERO && options & EMS_INTER_STARTPT)
               *cpar = 0.0;
             else if (s2 == ZERO && options & EMS_INTER_STOPPT)
               *cpar = 1.0;
             else
               return (intfound);
             *ctype = (s1 == ZERO ? EMScvint_lfend : EMScvint_rtend);

             *wpar = 1.0;
             *wtype = EMScvint_rtend;
             pt[X] = wpt2[X];
             pt[Y] = wpt2[Y];
             *relorient = EMSrelorient_hole_hole;
             (*numinters)++;
             intfound = TRUE;
             return (intfound);
             }

           /***************************************
           A cutting intersection has been recognised.
           Compute the intersection and return.
           ***************************************/

           if (s1 == ZERO || s2 == ZERO)
             {
             *cpar = (s1 == ZERO ? 0.0 : 1.0);
             *ctype = (s1 == ZERO ? EMScvint_lfend : EMScvint_rtend);
             }
           else 
             {
             *cpar = ac1 / (ac1 + ac2);              
             *ctype = EMScvint_middle;
             }
           *wpar = 1.0;
           *wtype = EMScvint_rtend;
           pt[X] = wpt2[X];
           pt[Y] = wpt2[Y];
           if (s1 == POSITIVE) 
             *relorient = EMSrelorient_area_hole;
           else
             *relorient = EMSrelorient_hole_area;
           (*numinters)++;
           intfound = TRUE;
           return (intfound);
           }

       /***************************************
       C-vector passes through the end-point and
       is not collinear with either W-edges.
       ***************************************/

       else 
           {
        
           /***************************************
           Select the piece of code that conforms to
           the particular type of situation.
           The following code system is adopted:
           The first letter represents the direction
           of the C-vector with respect to the W-vector.
           The second letter, the direction with respect to
           the follwoing W-vector. S, means from 
           space-side to tool-side and T, is vice-versa.
           If the endpoint options are on, compute endpoint
           intersection if any and return it.
           ***************************************/

           switch ((s3-1)*2 + (s4a-1))                   
               {
               case T_S:
               case S_T:
                 vw[X] = wpt2[X] - wpt1[X];
                 vw[Y] = wpt2[Y] - wpt1[Y];
                 s = EM2dcrossp (&coltol, vw, vwa, &locval, &locval);
                 if (s != NEGATIVE && 
                     ((options & EMS_INTER_STARTPT) ||
                      (options & EMS_INTER_STOPPT)))
                   {
                   onvector = EMonvector (wpt2, cpt1, cpt2, basis_tol, options,
                               cpar, ctype, pt);
                   if (onvector)
                     {
                     *wpar = 1.0;
                     *wtype = EMScvint_rtend;
                     *relorient = EMSrelorient_hole_hole;
                     (*numinters)++;
                     intfound = TRUE;
                     return (intfound);
                     }
                   else
                     return (intfound);
                   }
                 else if (s != NEGATIVE)
                   return (intfound);

                 if (s1a + s2a == NEG_POSITIVE) 
                   return (intfound);
                 else
                   *relorient = (s1a == ZERO ? EMSrelorient_hole_area :
                                               EMSrelorient_area_hole);
                 break;
               case T_T:
                 if (s1a == ZERO &&
                     options & EMS_INTER_STARTPT)
                   {
                   *cpar = 0.0;
                   *wpar = 1.0;
                   *ctype = EMScvint_lfend;
                   *wtype = EMScvint_rtend;
                   pt[X] = wpt2[X];
                   pt[Y] = wpt2[Y];
                   *relorient = EMSrelorient_hole_hole;
                   (*numinters)++;
                   intfound = TRUE;
                   return (intfound);
                   }
                 else if (s1a == ZERO)
                   return (intfound);
                 else
                   *relorient = EMSrelorient_area_hole;
                 break;
               case S_S:
                 if (s2a == ZERO &&
                     options & EMS_INTER_STOPPT)
                   {
                   *cpar = *wpar = 1.0;
                   *ctype = *wtype = EMScvint_rtend;
                   pt[X] = wpt2[X];
                   pt[Y] = wpt2[Y];
                   *relorient = EMSrelorient_hole_hole;
                   (*numinters)++;
                   intfound = TRUE;
                   return (intfound);
                   }
                 else if (s2a == ZERO)
                   return (intfound);
                 else
                   *relorient = EMSrelorient_hole_area;
               }

           /***************************************
           A cutting end-point intersection exists
           and the C-vector is not in-line with
           either of the W-vectors.
           ***************************************/

           if (s1a == ZERO || s2a == ZERO) 
             {
             *cpar = (s1a == ZERO ? 0.0 : 1.0);
             *ctype = (s1a == ZERO ? EMScvint_lfend : EMScvint_rtend);
             }
           else
             {
             *cpar = ac1a / (ac1a + ac2a);
             *ctype = EMScvint_middle;
             }
           *wpar = 1.0;
           *wtype = EMScvint_rtend;
           pt[X] = wpt2[X];
           pt[Y] = wpt2[Y];
           (*numinters)++;
           intfound = TRUE;
           return (intfound);
           }
      }
}


/*
 * Computes if the given point is on the given vector. If the start or the
 * stop point options are set, a TRUE is returned only if these options
 * are satisfied.
 */

static IGRboolean EMonvector (pt, vpt1, vpt2, basis_tol, options, 
                             par, type, outpt)
IGRdouble *pt, *vpt1, *vpt2;
IGRdouble basis_tol;
IGRushort options;
IGRdouble *par;
enum EMScvinttype *type;
IGRdouble *outpt;
{
  IGRboolean startpt, stoppt;
  IGRlong msg_loc;
  IGRdouble lentol;
  IGRdouble distsq, seglensq, fromstartsq;
  IGRdouble dist, seglen, fromstart;
  IGRboolean EFextract_par();
  IGRdouble EMmdistptseg();

  EFextract_par (BSTOLLENVEC, basis_tol, &lentol, &msg_loc);
  distsq = EMmdistptseg (&msg_loc, vpt1, vpt2, pt, 2, par, &seglensq, 
            &fromstartsq);
  dist = sqrt (distsq);
  if (dist > lentol) 
    return (FALSE);

  fromstart = sqrt (fromstartsq);
  seglen = sqrt (seglensq);
  startpt = fromstart < lentol;
  stoppt = (seglen - fromstart) < lentol;

  if ((!(options & EMS_INTER_STARTPT) && !(options & EMS_INTER_STOPPT)) ||
      (options & EMS_INTER_STARTPT && startpt) ||
      (options & EMS_INTER_STOPPT && stoppt))
     {
     *type = startpt ? EMScvint_lfend : 
                       stoppt ? EMScvint_rtend : EMScvint_middle;
     outpt[X] = pt[X];
     outpt[Y] = pt[Y];
     return (TRUE);
     }
  else
     return (FALSE);
}
