/*
Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BSsfsfint

Abstract
    This routine intersects two surfaces (e.g. quadric/quadric, quadric/plane, 
    quadric/general, general/plane, or general/general).

Synopsis
    void BSsfsfint(s1, s2, numgrps, numint, num_pts, pts, uvpars1, uvpars2,
                   cvscode, xyz_cvs, uv_cvs1, uv_cvs2, rc)

    struct 
     BSgeom_bsp_surf     (input) *s1............1st surface structure
    struct 
     BSgeom_bsp_surf     (input) *s2............2nd surface structure
    IGRint               (output) *numgrps......number of groups of 
                                                  intersections
    IGRint               (output) **numint......array of number of inter-
                                                  sections per group
    IGRint               (output) **num_pts.....array of number of points 
                                                  per intersection
    IGRpoint             (output) ***pts........array of pointers to arrays
                                                  of intersection points
    BSpair               (output) ***uvpars1....array of pointers to arrays
                                                  of uv parameter values for 
                                                  s1 (if s1 is not infinite
                                                  plane)
    BSpair               (output) ***uvpars2....array of pointers to arrays
                                                  of uv parameter values for 
                                                  s2 (if s2 is not infinite
                                                  plane)
    IGRshort             (output) *cvscode......flag indicating which curves
                                                  are returned:
                                                    (0) none 
                                                    (1) xyz_cvs (model space)
                                                    (2) uv_cvs for both s1  
                                                          and s2 (uv space)
                                                    (3) both xyz_cvs and
                                                          uv_cvs for both s1
                                                          and s2
                                                    (4) uv_cvs for s1, xyz_cvs
                                                    (5) uv_cvs for s2, xyz_cvs

    struct 
      BSgeom_bsp_curve   (output) **xyz_cvs.....pointer to array of structures
                                                  for intersection curves
                                                  in model space 
                                                  (if cvscode = 1, 3, 4, or 5)
    struct 
      BSgeom_bsp_curve   (output) **uv1_cvs.....pointer to array of
                                                  structures for inter-
                                                  section curves in uv space
                                                  of s1 (if cvscode = 2, 3, or
                                                  4 and s1 is not infinite
                                                  plane)
    struct 
      BSgeom_bsp_curve   (output) **uv2_cvs.....pointer to array of
                                                  structures for inter-
                                                  section curves in uv space
                                                  of s2 (if cvscode = 2, 3, or
                                                  5 and s2 is not infinite
                                                  plane)
    BSrc                 (output) *rc...........return code
    
Description
    Given 2 structures (s1, s2) containing B-spline representation of a 
    surface, type of surface, uv range (if available) and possibly geometric
    properties defining the surface, this routine intersects these 2 surfaces
    and returns the number of groups of intersections (numgrps), number of
    intersections per group (numint), the number of points per intersection
    (numpts), these intersection points (pts), uv pars of pts with respect
    to s1 and s2 (uvpars1, uvpars2), and a code (cvscode) indicating if 
    structures containing B-spline representation of model space and/or uv 
    space intersection curves are returned.
    Meaning of cvscode is as follows:
       cvscode          structures returned
       =======          ===================
         (0)              none
         (1)              xyz_cvs only
         (2)              uv1_cvs and uv2_cvs only
         (3)              xyz_cvs, uv1_cvs, and uv2_cvs
         (4)              xyz_cvs and uv1_cvs
         (5)              xyz_cvs and uv2_cvs

    The BSgeom_bsp_curve structures returned will always contain the B-spline
    representation of the intersection curve and, if available, geometric
    properties defining the curve (i.e. circle, ellipse, arc, etc...).

Return Values
    BSSUCC  if successful
    BSNOMEMORY if memory can not be allocated
    BSCOINCIDENT if surfaces are coincident

Notes
    Types of surfaces supported by this routine are :
       BSINF_PLANE....infinite plane
       BSRECT_PLANE...rectangular plane
       BSSPHERE.......sphere
       BSFULL_CYL.....rt angle, circular cylinder
       BSFULL_CONE....rt angle, circular cone   
       BSPART_CYL.....partial rt angle, circular cylinder
       BSPART_CONE....partial rt angle, circular cone
       BSTORUS........torus
       BSPART_TORUS...partial torus
       BSSF_OF_PROJ...surface of projection
       BSSF_OF_REV....surface of revolution
       BSGEN_BSP_SF...general B-spline surface
  

    Memory for all output is allocated inside this routine.

    Calling routine MUST set uv range for s1 and s2 inside BSgeom_bsp_surf
    structure = start and end u knots:
      urange[0] = s1->bspsf->u_knots[s1->bspsf->u_order - 1]     
      urange[1] = s1->bspsf->u_knots[s1->bspsf->u_num_poles]     

      vrange[0] = s1->bspsf->v_knots[s1->bspsf->v_order - 1]     
      vrange[1] = s1->bspsf->v_knots[s1->bspsf->v_num_poles]     

      (Similar for s2).


    Below are examples of how to free memory for geometric curves 
    and surfaces:

       GEOMETRIC CURVES:
       -----------------
       numcvs_dealloc = 0;	
       for (j = 0; j < numgrps; ++j)
       {
          for (k = 0; k < numint[j]; ++k)
              ++numcvs_dealloc;
       }

       if (xyz_cvs)
       {
          for (i = 0; i < numcvs_dealloc; ++i)
          {
              if (xyz_cvs[i].array1)
              {
                 BSdealloc((char *) xyz_cvs[i].array1);
                 xyz_cvs[i].array1 = NULL;
              }
	
              if (xyz_cvs[i].bspcv)
              {
                 status = BSfreecv(&rc, xyz_cvs[i].bspcv);
                 xyz_cvs[i].bspcv = NULL;
              }
          }
          BSdealloc((char *)xyz_cvs);
          xyz_cvs = NULL;
       }
 
      (Similar for uv1_cvs and uv2_cvs)


      GEOMETRIC SURFACES:
      -------------------
      if (s1)
      {
         if (sf1->sfgen_cv)
         {
            (void)BSfreecv(&rc, sf2->sfgen_cv);
            sf2->sfgen_cv = NULL;
         }

         if (sf1->bspsf)
         {
            status = BSfreesf( &rc, sf1->bspsf );
            sf1->bspsf = NULL;
         }

         BSdealloc((char *)sf1);
         sf1 = NULL;
      }

      (Similar for sf2) 


Index
    em

Keywords

History
    S. C. Wood    08/16/90   : Creation date.
    S. C. Wood    09/04/90   : Correction allocation/deallocation mismatch.
    Vivian W.Ye   09/18/90   : Replace BSsf_pl_int by BSsfplintlg.
    S. C. Wood    09/26/90   : Modified to adapt to changes in BSprptsquad
                               resulting from change in BSprptssph where
                               number of points (num_pts) may be increased.
    S. C. Wood    10/19/90   : Corrected description of xyz_cvs, uv1_cvs, and
                               uv2_cvs in header.  Adapted to call BSxsfprjpln
                               for surface of projection / plane (rectangular
                               or infinite).
    S. C. Wood    11/08/90   : Modified to call BSxsfprjpln for surf. of proj.
                               and plane (or planar surface) intersections.
    S. C. Wood    11/14/90   : Declared BSgmsfprop.
    S. C. Wood    12/02/90   : Modified if statement for calling BSxsfprjpln
                               for surface of projection and plane or planar
                               surface.  Modified to call BSxsfrevpln for
                               surface of revolution / planar surface inter-
                               sections. If BSxsfrevpln returns rc = 
                               BSNOTYETSUPPORTED, call BSsf_pl_int if infinite
                               plane or call BSsur_surrg if bounded plane.
    S. C. Wood    12/18/90   : Broke out code to calculate pts, uvpars1, and
                               uvpars2 into separate routine (BSchtpts_uv)
                               after call to BSsfplintlg and when getchtpts
                               = TRUE.
    S. C. Wood    01/08/91   : Define BSVOID and typecast all IGRboolean
                               BSroutines as void and delete all reference 
                               to status.  Call temporary, dummy routine
                               (BSsfplintlg) that is in library but returns
                               rc = BSOUTOFDESN.  Dummy BSsfplintlg will 
                               later be replaced by real BSsfplintlg in 
                               library.
    S. C. Wood    01/18/91   : Call BSxcylpln for cylinder / planar surface
                               intersection instead of calling BSxsfprjpln.
                               Perform min/max box intersection check on s1
                               and s2 if s1 and s2 are both bounded
    S. C. Wood    01/22/91   : Set bounded bit in surface structure = FALSE
                               if surface is infinite plane. 
    S. C. Wood    01/24/91   : Call BSx2sf_rev to intersect 2 surf. of rev-
                               olution.  Also call BSx2sf_rev to intersect
                               cylinder, cone, sphere, and torus as surfaces
                               of revolution.  If BSx2sf_rev returns rc = 
                               BSNOTYETSUPPORTED, call BSsur_surrg.  Set
                               u and v range of tmp_sf to appropriate knot
                               values instead of hardcoded = 0.0 and 1.0.
    S. C. Wood    01/25/91   : When checking for torus and planar surface, 
                               had unintentionally left out checking for
                               surface type == BSINF_PLANE.  Added this
                               to the if statement so BSxsfrevpln will
                               be called.
    S. C. Wood    02/14/91   : Temporaily modified to set rc = BSSUCC if
                               BSx2sf_rev returns rc = BSCOINCIDENT to 
                               prevent failure in interface.
    S. C. Wood    02/21/91   : At wrapup, if rc = BSCOINCIDENT, always set
                               rc = BSSUCC.  Previous fix was performed only
                               after BSx2sf_rev.
    S. C. Wood    02/21/91   : Call BSx2sf_prj for two surfaces of projection
                               or one surface of projection and a full or
                               partial cylinder.
    S. C. Wood    03/13/91   : Initialize and deallocate array1 in all
                               BSgeom_bsp_curve structures.
    S. C. Wood    04/02/91   : Modified to call BSx2pln for 2 planar surfaces
                               and to NOT call BSsfplintlg for infinite plane/
                               infinite plane case.  Deallocate bsp_cvs pointer
                               at wrapup if allocated.
    S. C. Wood    04/16/91   : Modified to call BSxconepln for cone / planar
                               surface cases.
    Vivian W.Ye   06/05/91   : Changed call to BSsfplintlg and replace
                               BSchtpts_uv by BSchtptsuvc.
    S. C. Wood    06/28/91   : Restructured BSsfsfint.
    S. C. Wood    07/09/91   : Call BScpgeomsf to copy original surfaces
                               into temporary surfaces which will possibly
                               be changed depending on type of surface.
    S. C. Wood    07/15/91   : Allocate memory for new_s1->sfgen_cv only
                               if s1 is sf. of rev. or sf. of proj. and
                               s1->sfgen_cv exists. (Similar for new_s2) 
                               Fixed "if" statements following calls
                               to BSx2sf_rev and BSx2sf_prj to reset 
                               rc = BSSUCC and call BSsur_surrg if the above
                               mentioned routines return rc = 
                               BSNOTYETSUPPORTED.
    S. C. Wood    07/07/91   : Do not allocate memory for new_s1->bspsf
                               if s1->type = BSINF_PLANE.  Do not rely solely
                               on s1->bspsf to be set = NULL by calling
                               routine for infinite planes.
    S. C. Wood    09/19/91   : If rc = BSCOINCIDENT, do not set rc = BSSUCC.
                               Previously set = BSSUCC to prevent interface
                               from considering BSCOINCIDENT as an error.
    S. C. Wood    10/01/91   : If rc != BSSUCC at wrapup, make sure that
                               final output is deallocated and *numgrps = 0.
    S. C. Wood    01/02/92   : Call BSuvcv_rpln to calculate curves in uv
                               space corresponding to the xyz_cvs for s1
                               and/or s2 if rectangular plane.  Modified
                               cvscode to indicate if only 1 set of uv curves
                               is returned, and if returned, which surface
                               it corresponds to. Also, modified header to
                               explain these changes to cvscode indicator.
    S. C. Wood    01/23/92   : Normalize knots of xyz_cvs.  BSuvcv_rpln
                               will copy these normalized knots into uv
                               curves so both xyz and uv curves will be
                               normalized before return.
    S. C. Wood    01/30/92   : Do not set pln1 (or pln2) flag = TRUE for
                               planar general B-spline surfaces.
    S. C. Wood    01/30/92   : Deallocate numint after all references to
                               it.
    S. C. Wood    02/07/92   : If both surfaces are planar and bounded, 
                               do not return any curves (xyz or uv).
                               Go directly to calculation of points
                               (call BSchtptsuvc). This was requested by
                               Siki to fix TR # 92n0683.
    S. C. Wood    02/17/92   : Corrected if statement determining whether
                               or not to return any curves and setting
                               cvscode = 0.  Was not checking for planar
                               general B-spline surfaces.  Fix for TR# 92n1194.
    S. C. Wood    02/19/92   : If all intersection curves are order = 2, 
                               set cvscode = 0.
    S. C. Wood    05/05/92   : Make sure that deallocation of memory correlates
                               to allocation (stackalloc--stackdealloc, 
                               malloc--dealloc).
    S. C. Wood    06/09/92   : Modified header as requested by M. Holderer.
    S. C. Wood    12/04/92   : Do not call BSchtptsuvc if both s1 and s2
                               are infinite because there are no uv parameters
                               to find.
    S. C. Wood    12/07/92   : Set new variable, new_lgd_code, to indicate
                               if lgd_cvs or intcvs are to be used in calcu-
                               lating uvs for s1 or s2.  This is sent to
                               BSchtptsuvc.  This was necessary now that
                               BSsfplintlg is being called for rectangular
                               plane cases.
    P.R. Slubicki 01/20/93   : I added a call to BSsftgeomsf() when s1 or s2 is
                               of type BSGEN_BSP_SF, BSSF_OF_PROJ, or 
                               BSSF_OF_REV. This routine determines if an input
                               surface is a specific geometric type. For
                               example, it may determine that a BSSF_OF_REV is
                               also a torus.
    S. C. Wood    04/07/93   : Free (*xyz_cvs)[i].bspcv, (*uv1_cvs).bspcv, 
                               (*uv2_cvs).bspcv if BSERROR(*rc).
    S. C. Wood    04/13/93   : Check to make sure *numgrps > 0 before
                               going into code to stroke intersection
                               curves (getptsflag == TRUE).  Corrects problem
                               of attempting to allocate zero bytes of memory.
    S. C. Wood    05/27/93   : Mistakenly, setting (*uv1_cvs)[ind+j].bspcv = 
                               NULL when intending to set (*uv2_cvs)[ind+j].
                               bspcv = NULL. Fix for TR#9307244.
    S. C. Wood    08/02/93   : Incorporate flag indicating if s1 or s2
                               is input classified as BSGEN_BSP_SF (gensf1, 
                               gensf2).  Reset classification to BSGEN_BSP_SF
                               before wrapup if BSsftgeomsf set classification
                               to special type.  Also, set geom_prop flag = 0
                               and deallocate sfgen_cv (if available).
    S. C. Wood    08/03/93   : Remove code added on 08/02/93.  Never modify
                               input surfaces.  Instead, work with a copy
                               (mod_s1, mod_s2) throughout.
    S. C. Wood    10/29/93   : Temporarily modified to always call BSsftgeomsf,
                               except for infinite surface, to verify surface
                               type.
    S. C. Wood    11/15/93   : Modified to transform input surfaces to new
                               system with origin being the midpoint of
                               min/max box of s1 (call BSgmsfoton) before 
                               intersecting and then transform intersection 
                               curves back to original system (call
                               BSgmcvntoo).  Set uv range before calling
                               BSsur_surrg.
    S. C. Wood    11/16/93   : Do not attempt transformation if both surfaces
                               are not bounded. If one surface is not bounded, 
                               use min/max box of bounded surface to get
                               translation vector.
    S. C. Wood    11/22/93   : Call BSalloccv to allocate sfgen_cv pointer
                               in all instances instead of "stack allocating".
    S. C. Wood    12/01/93   : If BSx2sf_rev or BSx2sf_prj returns rc = 
                               BSNOTYETSUPPORTED and sfgen_cv pointer was
                               allocated for the surfaces inside BSx2sf_rev
                               or BSx2sf_prj, free this curve pointer.
    S. C. Wood    12/13/93   : Translate cylinders to coordinate system with 
                               origin being the midpoint of the minimum 
                               distance points of axis lines of cylinders.
    S. C. Wood    03/18/94   : Initialize scale=1.0 in declaration.
    S. C. Wood    07/20/94   : If BSquadsfint returns rc = BSINCONSISTENT, 
                               reset rc = BSSUCC eventually call BSsur_surrg.
    Vivian Y.Hsu  01/25/95   : Modified structure of lgd_cvs.
    S. C. Wood    11/07/95   : Store uv ranges for mod_s1 and mod_s2 before
			       calling BSsftgeomsf and restore them after
			       returning from BSsftgeomsf.
    Vivian Y.Hsu  03/24/97   : In case lgd_flag = TRUE, set cvscode = 1 
                               only if cvscode = 0. If cvscode = 4, we 
                               should not over write it with 1. ( Since
                               I return lgd_cvs with bound plane when the
                               bsp_cvs is not trimed. So uv_cvs is valid
                               in this case).

*/

#define BSVOID
#include <math.h>
#include "bserr.h"
#include "bsdefs.h"
#include "bssfsf_int2.h"
#include "bsgeom_cvsf.h"
#include "bsstk.h"
#include "bsmalloc.h"
#include "bsparameters.h"
#include "bsmemory.h"
#include "bsplpchlgd.h"

#define BSVOID
#define MAXNUM_QUADINT 20
#define MAXSIZE 100

void BSsfsfint(
struct
  BSgeom_bsp_surf  *s1,
 struct	  BSgeom_bsp_surf  	 *s2,
IGRint             *numgrps,
IGRint             **numint,
IGRint             **num_pts,
IGRpoint           ***pts,
BSpair             ***uvpars1,
BSpair             ***uvpars2, 
IGRshort           *cvscode,
struct
  BSgeom_bsp_curve **xyz_cvs,
struct
  BSgeom_bsp_curve **uv1_cvs,
struct
  BSgeom_bsp_curve **uv2_cvs,
BSrc               *rc)     
{
#include "bsdbgrc.h"
#include "bsquadsfint.h"
#include "bsx2sf_rev.h"
#include "bsgmsfprop.h"
#include "bschtptsuvc.h"
#include "bslsqptlnpl.h"
#include "bsxplngmsf.h"
#include "bscpgeomsf.h"
#include "bsuvcv_rpln.h"
#include "bsstallsffl.h"
#include "bsstfresffl.h"
#include "bsstallcvfl.h"
#include "bsstfrecvfl.h"
#include "bssur_surrg.h"
#include "bsbx2.h"
#include "bsnorkts.h"
#include "bsfreecv.h"
#include "bsfreesf.h"
#include "bsalloccv.h"
#include "bsx2sf_prj.h"
#include "bsstallcvfl.h"
#include "bsstallsffl.h"
#include "bsstfrecvfl.h"
#include "bsstfresffl.h"
#include "bssftgeomsf.h"
#include "bsgmsfoton.h"
#include "bsgmcvntoo.h"
#include "bsptsnwtold.h"
#include "bslldist.h"
#include "bsfrecmpcvs.h"

   IGRint             i, ii, j, ind;
   IGRint             code, option, numcvs;
   IGRlong            totp1, totp2, npts;
   IGRdouble          dum_tol1, dum_tol2;
   IGRdouble          dist_tol, err;
   IGRpoint           min1, max1, min2, max2;
   IGRshort           new_lgd_code;
   IGRboolean         ptcode, s1_code, s2_code;
   IGRboolean         getptsflag, intersect, cv_found;
   IGRboolean         lgd_flag, pln1, pln2, quad1, quad2, rev1, rev2;
   IGRboolean         prj1, prj2, trational=FALSE, trans_flag;
   IGRboolean         free_sfgen_cv1=FALSE, free_sfgen_cv2=FALSE, parallel;
   IGRvector          tvec;
   IGRpoint           tintpts[2];
   IGRdouble          mat[3][3], scale=1.0, mdist;
   struct
     BSgeom_bsp_surf  *new_s1 = NULL, *new_s2 = NULL;
   struct
     BSgeom_bsp_surf  *mod_s1 = NULL, *mod_s2 = NULL;
   struct
     BSgeom_bsp_surf  *new_mod_s1 = NULL, *new_mod_s2 = NULL;
   struct
     BSgeom_bsp_curve ***tmp_cvs = NULL;
   struct 
     IGRbsp_curve     **bsp_cvs = NULL, **bsp_cvs2 = NULL, *tcv = NULL;
   struct 
     IGRbsp_surface   *tsf = NULL;
   struct
     BScmplgd_cv      *lgd_cvs = NULL, *dummystr = NULL;
   BSrc               rc1 = BSSUCC;
   IGRdouble          sav_urange0=0.0, sav_urange1=1.0;
   IGRdouble          sav_vrange0=0.0, sav_vrange1=1.0;

   *rc = BSSUCC;

   /* Initialize final output pointers */
   *numgrps = 0;
   *xyz_cvs = NULL;
   *uv1_cvs = NULL;
   *uv2_cvs = NULL;
   *numint = NULL;
   *num_pts = NULL;
   *uvpars1 = NULL;
   *uvpars2 = NULL;

   *cvscode = 0;

   /* Perform min/max box check for s1 and s2 if both are bounded */

   BSEXTRACTPAR( rc, BSTOLLENVEC, dist_tol);

   /* Set temporary structure (mod_s1) */
   mod_s1 = (struct BSgeom_bsp_surf *)BSstackalloc((unsigned) 
               (sizeof (struct BSgeom_bsp_surf)));
   if (s1->bspsf && s1->type != BSINF_PLANE)
   {
      tsf = s1->bspsf;
      mod_s1->bspsf = (struct IGRbsp_surface *)BSstackalloc((unsigned)
                         (sizeof (struct IGRbsp_surface)));
      (void)BSstallsffl(tsf->u_num_poles, tsf->v_num_poles, tsf->rational, 
                        tsf->u_num_knots, tsf->v_num_knots, mod_s1->bspsf, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      mod_s1->bspsf = NULL;
   }
   if (s1->sfgen_cv && (s1->type == BSSF_OF_PROJ || 
       s1->type == BSSF_OF_REV))
   {
      tcv = s1->sfgen_cv;
      BSalloccv(tcv->order, tcv->num_poles, tcv->rational, 0, 
                &mod_s1->sfgen_cv, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      mod_s1->sfgen_cv = NULL;
   }

   BScpgeomsf(s1, mod_s1, rc);
   if (BSERROR(*rc))
      goto wrapup;

/****************************************************************************/
/* Temporarily modified to always call BSsftgeomsf (except for BSINF_PLANE)
   to verify input type*/
/***************************************************************************/
/*   if (s1->type == BSGEN_BSP_SF
    || s1->type == BSSF_OF_PROJ
    || s1->type == BSSF_OF_REV)
   {
*/
   if (s1->type != BSINF_PLANE && s1->bounded)
   {
      if (mod_s1->bounded)
      {
         sav_urange0 = mod_s1->urange[0];
         sav_urange1 = mod_s1->urange[1];

         sav_vrange0 = mod_s1->vrange[0];
         sav_vrange1 = mod_s1->vrange[1];
      }

      BSsftgeomsf (mod_s1, TRUE, 100, rc);
      if (BSERROR (*rc))
        goto wrapup;

      if (mod_s1->bounded)
      {
         mod_s1->urange[0] = sav_urange0;
         mod_s1->urange[1] = sav_urange1;

         mod_s1->vrange[0] = sav_vrange0;
         mod_s1->vrange[1] = sav_vrange1;
      }
   }

/*   } */

   
   /* Set temporary structure (mod_s2) */
   mod_s2 = (struct BSgeom_bsp_surf *)BSstackalloc((unsigned) 
               (sizeof (struct BSgeom_bsp_surf)));
   if (s2->bspsf && s2->type != BSINF_PLANE)
   {
      tsf = s2->bspsf;
      mod_s2->bspsf = (struct IGRbsp_surface *)BSstackalloc((unsigned)
                         (sizeof (struct IGRbsp_surface)));
      (void)BSstallsffl(tsf->u_num_poles, tsf->v_num_poles, tsf->rational, 
                        tsf->u_num_knots, tsf->v_num_knots, mod_s2->bspsf, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      mod_s2->bspsf = NULL;
   }

   if (s2->sfgen_cv && (s2->type == BSSF_OF_PROJ || 
       s2->type == BSSF_OF_REV))
   {
      tcv = s2->sfgen_cv;
      BSalloccv(tcv->order, tcv->num_poles, tcv->rational, 0, 
                &mod_s2->sfgen_cv, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      mod_s2->sfgen_cv = NULL;
   }

   BScpgeomsf(s2, mod_s2, rc);
   if (BSERROR(*rc))
      goto wrapup;

/***********************************************************************/
/* Temporarily modified to always call BSsftgeomsf (except for BSINF_PLANE)
   to verify input type*/
/***********************************************************************/

/*   if (s2->type == BSGEN_BSP_SF
    || s2->type == BSSF_OF_PROJ
    || s2->type == BSSF_OF_REV)
   {
*/

   if (s2->type != BSINF_PLANE && s2->bounded)
   {
      if (mod_s2->bounded)
      {
         sav_urange0 = mod_s2->urange[0];
         sav_urange1 = mod_s2->urange[1];

         sav_vrange0 = mod_s2->vrange[0];
         sav_vrange1 = mod_s2->vrange[1];
      }

      BSsftgeomsf (mod_s2, TRUE, 100, rc);
      if (BSERROR (*rc))
        goto wrapup;

      if (mod_s2->bounded)
      {
         mod_s2->urange[0] = sav_urange0;
         mod_s2->urange[1] = sav_urange1;

         mod_s2->vrange[0] = sav_vrange0;
         mod_s2->vrange[1] = sav_vrange1;
      }

   }
/*   } */

   if (mod_s1->type == BSINF_PLANE)
      mod_s1->bounded = FALSE;

   if (mod_s2->type == BSINF_PLANE)
      mod_s2->bounded = FALSE;
   
   if (mod_s1->bounded)
   {
      totp1 = mod_s1->bspsf->u_num_poles * mod_s1->bspsf->v_num_poles;

      (void)BSbx2(rc, &totp1, (IGRpoint *)mod_s1->bspsf->poles,
                  mod_s1->bspsf->weights, min1, max1);
      if (BSERROR(*rc))
         goto wrapup;
   }

   if (mod_s2->bounded)
   {
      totp2 = mod_s2->bspsf->u_num_poles * mod_s2->bspsf->v_num_poles;
	
      (void)BSbx2(rc, &totp2, (IGRpoint *)mod_s2->bspsf->poles,
                  mod_s2->bspsf->weights, min2, max2);
      if (BSERROR(*rc))
          goto wrapup;
   }

   if (mod_s1->bounded && mod_s2->bounded)
   {
      ii = 0;
      intersect = TRUE;
      do
      {
         if (((max1[ii] + dist_tol) < min2[ii]) || 
             ((max2[ii] + dist_tol) < min1[ii]))
            intersect = FALSE;
         ii++;
      } while ((intersect ) && (ii < 3));

      if (!intersect)
         goto wrapup;
   }

   /* If mod_s1->type != BSINF_PLANE and != BSGEN_BSP_SF, call BSgmsfprop
      if geom_sf->geom_prop = FALSE  (same for s2). */
   if (mod_s1->type != BSINF_PLANE && mod_s1->type != BSGEN_BSP_SF)
   {
      if (!mod_s1->geom_prop)
      {
         BSgmsfprop(mod_s1, rc);
         if (BSERROR(*rc) && *rc != BSNOTYETSUPPORTED)
            goto wrapup;

         if (*rc == BSNOTYETSUPPORTED)
            *rc = BSSUCC;
      }
   }

   if (mod_s2->type != BSINF_PLANE && mod_s2->type != BSGEN_BSP_SF)
   {
      if (!mod_s2->geom_prop)
      {
         BSgmsfprop(mod_s2, rc);
         if (BSERROR(*rc) && *rc != BSNOTYETSUPPORTED)
            goto wrapup;

         if (*rc == BSNOTYETSUPPORTED)
            *rc = BSSUCC;
      }
   }

   /**************************************************************************/
   /* Translate mod_s1 and mod_s2 from old system with origin being the
      center of min/max box of mod_s1 to new system with origin being (0,0,0)*/
   /**************************************************************************/

   /* Set temporary structure (new_mod_s1) */
   new_mod_s1 = (struct BSgeom_bsp_surf *)BSstackalloc((unsigned) 
               (sizeof (struct BSgeom_bsp_surf)));
   if (mod_s1->bspsf && mod_s1->type != BSINF_PLANE)
   {
      tsf = mod_s1->bspsf;
      new_mod_s1->bspsf = (struct IGRbsp_surface *)BSstackalloc((unsigned)
                             (sizeof (struct IGRbsp_surface)));
      (void)BSstallsffl(tsf->u_num_poles, tsf->v_num_poles, tsf->rational, 
                        tsf->u_num_knots, tsf->v_num_knots, new_mod_s1->bspsf,
                        rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      new_mod_s1->bspsf = NULL;
   }

   if (mod_s1->sfgen_cv && (mod_s1->type == BSSF_OF_PROJ || 
       mod_s1->type == BSSF_OF_REV))
   {
      tcv = mod_s1->sfgen_cv;
      BSalloccv(tcv->order, tcv->num_poles, tcv->rational, 0, 
                &new_mod_s1->sfgen_cv, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      new_mod_s1->sfgen_cv = NULL;
   }

   /* Set temporary structure (new_mod_s2) */
   new_mod_s2 = (struct BSgeom_bsp_surf *)BSstackalloc((unsigned) 
               (sizeof (struct BSgeom_bsp_surf)));
   if (mod_s2->bspsf && mod_s2->type != BSINF_PLANE)
   {
      tsf = mod_s2->bspsf;
      new_mod_s2->bspsf = (struct IGRbsp_surface *)BSstackalloc((unsigned)
                             (sizeof (struct IGRbsp_surface)));
      (void)BSstallsffl(tsf->u_num_poles, tsf->v_num_poles, tsf->rational, 
                        tsf->u_num_knots, tsf->v_num_knots, new_mod_s2->bspsf,
                        rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      new_mod_s2->bspsf = NULL;
   }

   if (mod_s2->sfgen_cv && (mod_s2->type == BSSF_OF_PROJ || 
       mod_s2->type == BSSF_OF_REV))
   {
      tcv = mod_s2->sfgen_cv;
      BSalloccv(tcv->order, tcv->num_poles, tcv->rational, 0, 
                &new_mod_s2->sfgen_cv, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      new_mod_s2->sfgen_cv = NULL;
   }

   /* Set translation vector, rotation matrix and scale factor*/
   trans_flag = FALSE;
   if ((mod_s1->type == BSFULL_CYL || mod_s1->type == BSPART_CYL) &&
       (mod_s2->type == BSFULL_CYL || mod_s2->type == BSPART_CYL))
   {
      /* Translate cylinders to coordinate system with origin being
         the midpoint of the minimum distance points of axis lines
         of cylinders. */

      (void)BSlldist(rc, mod_s1->pt1, mod_s2->pt1, mod_s1->vec1, mod_s2->vec1, 
                     &parallel, &mdist, tintpts[0], tintpts[1]);
      if (BSERROR(*rc))
         goto wrapup;

      trans_flag = TRUE;
      tvec[0] = tintpts[0][0] + fabs(tintpts[0][0] - tintpts[1][0])*.5;
      tvec[1] = tintpts[0][1] + fabs(tintpts[0][1] - tintpts[1][1])*.5;
      tvec[2] = tintpts[0][2] + fabs(tintpts[0][2] - tintpts[1][2])*.5;

      mat[0][0] = 1.0;
      mat[0][1] = 0.0;
      mat[0][2] = 0.0;
  
      mat[1][0] = 0.0;
      mat[1][1] = 1.0;
      mat[1][2] = 0.0;

      mat[2][0] = 0.0;
      mat[2][1] = 0.0;
      mat[2][2] = 1.0;

      BSgmsfoton(tvec, mat, scale, mod_s1, new_mod_s1, rc);
      if (BSERROR(*rc))
         goto wrapup;

      BSgmsfoton(tvec, mat, scale, mod_s2, new_mod_s2, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      if (mod_s1->bounded || mod_s2->bounded)
      {
         trans_flag = TRUE;
         if (mod_s1->bounded)
         {
            tvec[0] = min1[0] + fabs(min1[0] - max1[0])*.5;
            tvec[1] = min1[1] + fabs(min1[1] - max1[1])*.5;
            tvec[2] = min1[2] + fabs(min1[2] - max1[2])*.5;
         }

         if (mod_s2->bounded)
         {
            tvec[0] = min2[0] + fabs(min2[0] - max2[0])*.5;
            tvec[1] = min2[1] + fabs(min2[1] - max2[1])*.5;
            tvec[2] = min2[2] + fabs(min2[2] - max2[2])*.5;
         }
      
         mat[0][0] = 1.0;
         mat[0][1] = 0.0;
         mat[0][2] = 0.0;
  
         mat[1][0] = 0.0;
         mat[1][1] = 1.0;
         mat[1][2] = 0.0;

         mat[2][0] = 0.0;
         mat[2][1] = 0.0;
         mat[2][2] = 1.0;

         BSgmsfoton(tvec, mat, scale, mod_s1, new_mod_s1, rc);
         if (BSERROR(*rc))
            goto wrapup;

         BSgmsfoton(tvec, mat, scale, mod_s2, new_mod_s2, rc);
         if (BSERROR(*rc))
            goto wrapup;
      }
      else
      {
         /* Copy mod_s1 into new_mod_s1 (similar for mod_s2) */
         BScpgeomsf(mod_s1, new_mod_s1, rc);
         if (BSERROR(*rc))
            goto wrapup;

         BScpgeomsf(mod_s2, new_mod_s2, rc);
         if (BSERROR(*rc))
            goto wrapup;
      }
   }   /* end if((mod_s1->type==BSFULL_CYL || mod_s1->type==BSPART_CYL)...*/

   /* Initialize booleans indicating type of surface */
   pln1 = FALSE;
   quad1 = FALSE;
   rev1 = FALSE;
   prj1 = FALSE;

   pln2 = FALSE;
   quad2 = FALSE;
   rev2 = FALSE;
   prj2 = FALSE;

   getptsflag = FALSE;
   lgd_flag = FALSE;
   new_lgd_code = 0;

   /* Save original type for s1 and s2 to be reset later */

   /*****************************/
   /* Check for planar surfaces */
   /*****************************/
   if (new_mod_s1->type == BSINF_PLANE || new_mod_s1->type == BSRECT_PLANE)
   {
      pln1 = TRUE;
   }

   if (new_mod_s2->type == BSINF_PLANE || new_mod_s2->type == BSRECT_PLANE)
   {
      pln2 = TRUE;
   }

   /******************************/
   /* Check for quadric surfaces */
   /******************************/
   if (new_mod_s1->type == BSSPHERE || new_mod_s1->type == BSPART_SPHERE ||
       new_mod_s1->type == BSFULL_CYL || new_mod_s1->type == BSPART_CYL ||
       new_mod_s1->type == BSFULL_CONE || new_mod_s1->type == BSPART_CONE ||
       new_mod_s1->type == BSTORUS || new_mod_s1->type == BSPART_TORUS)
   {
      quad1 = TRUE;
   }

   if (new_mod_s2->type == BSSPHERE || new_mod_s2->type == BSPART_SPHERE ||
       new_mod_s2->type == BSFULL_CYL || new_mod_s2->type == BSPART_CYL ||
       new_mod_s2->type == BSFULL_CONE || new_mod_s2->type == BSPART_CONE ||
       new_mod_s2->type == BSTORUS || new_mod_s2->type == BSPART_TORUS)
   {
      quad2 = TRUE;
   }


   /***********************************/
   /* Check for surface of projection */
   /***********************************/
   if (new_mod_s1->type == BSSF_OF_PROJ || new_mod_s1->type == BSFULL_CYL ||
       new_mod_s1->type == BSPART_CYL)
   {
      prj1 = TRUE;
   }

   if (new_mod_s2->type == BSSF_OF_PROJ || new_mod_s2->type == BSFULL_CYL ||
       new_mod_s2->type == BSPART_CYL)
   {
      prj2 = TRUE;
   }


   /***********************************/
   /* Check for surface of revolution */
   /***********************************/
   if (new_mod_s1->type == BSSF_OF_REV || new_mod_s1->type == BSFULL_CYL ||
       new_mod_s1->type == BSPART_CYL || new_mod_s1->type == BSSPHERE || 
       new_mod_s1->type == BSPART_SPHERE || new_mod_s1->type == BSTORUS ||
       new_mod_s1->type == BSPART_TORUS || new_mod_s1->type == BSFULL_CONE || 
       new_mod_s1->type == BSPART_CONE)
   {
      rev1 = TRUE;
   }

   if (new_mod_s2->type == BSSF_OF_REV || new_mod_s2->type == BSFULL_CYL ||
       new_mod_s2->type == BSPART_CYL || new_mod_s2->type == BSSPHERE || 
       new_mod_s2->type == BSPART_SPHERE || new_mod_s2->type == BSTORUS ||
       new_mod_s2->type == BSPART_TORUS || new_mod_s2->type == BSFULL_CONE || 
       new_mod_s2->type == BSPART_CONE)
   {
      rev2 = TRUE;
   }

   /* Allocate memory for new_s1 and new_s2 */
   new_s1 = (struct BSgeom_bsp_surf *)BSstackalloc((unsigned) 
               (sizeof (struct BSgeom_bsp_surf)));
   new_s2 = (struct BSgeom_bsp_surf *)BSstackalloc((unsigned) 
               (sizeof (struct BSgeom_bsp_surf)));
   if (new_mod_s1->bspsf && new_mod_s1->type != BSINF_PLANE)
   {
      tsf = new_mod_s1->bspsf;
      new_s1->bspsf = (struct IGRbsp_surface *)BSstackalloc((unsigned)
                        (sizeof (struct IGRbsp_surface)));
      (void)BSstallsffl(tsf->u_num_poles, tsf->v_num_poles, tsf->rational, 
                        tsf->u_num_knots, tsf->v_num_knots, new_s1->bspsf, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      new_s1->bspsf = NULL;
   }

   if (new_mod_s2->bspsf && new_mod_s2->type != BSINF_PLANE)
   {
      tsf = new_mod_s2->bspsf;
      new_s2->bspsf = (struct IGRbsp_surface *)BSstackalloc((unsigned)
                         (sizeof (struct IGRbsp_surface)));
      (void)BSstallsffl(tsf->u_num_poles, tsf->v_num_poles, tsf->rational, 
                        tsf->u_num_knots, tsf->v_num_knots, new_s2->bspsf, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      new_s2->bspsf = NULL;
   }

   if (new_mod_s1->sfgen_cv && (new_mod_s1->type == BSSF_OF_PROJ || 
       new_mod_s1->type == BSSF_OF_REV))
   {
      tcv = new_mod_s1->sfgen_cv;
      BSalloccv(tcv->order, tcv->num_poles, tcv->rational, 0, 
                &new_s1->sfgen_cv, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      new_s1->sfgen_cv = NULL;
   }

   if (new_mod_s2->sfgen_cv && (new_mod_s2->type == BSSF_OF_PROJ || 
       new_mod_s2->type == BSSF_OF_REV))
   {
      tcv = new_mod_s2->sfgen_cv;
      BSalloccv(tcv->order, tcv->num_poles, tcv->rational, 0, 
                &new_s2->sfgen_cv, rc);
      if (BSERROR(*rc))
         goto wrapup;
   }
   else
   {
      new_s2->sfgen_cv = NULL;
   }

   /***********************************************************/
   /* Call appropriate routine to calculate intersection      */
   /* (Priority : plane, quadric, sf. proj, sf. rev, gen. sf) */
   /***********************************************************/
   if (pln1 || pln2)
   {
      BScpgeomsf(new_mod_s1, new_s1, rc);
      if (BSERROR(*rc))
         goto wrapup;

      BScpgeomsf(new_mod_s2, new_s2, rc);
      if (BSERROR(*rc))
         goto wrapup;

      /*****************/
      /* PLANE / PLANE */
      /*****************/
      if (pln1)
      {
         if (new_s1->type != BSINF_PLANE && new_s1->type != BSRECT_PLANE)
         {
            /* Set properties of new_s1 (pt and vec) */
            new_s1->geom_prop = TRUE;

            /* Call BSlsqptlnpl to get point and normal vector for s1 */
            npts = new_s1->bspsf->u_num_poles * new_s1->bspsf->v_num_poles;
            option = 3;
            BSlsqptlnpl(npts, new_s1->bspsf->poles, new_s1->bspsf->weights, 
                        option, &code, new_s1->pt1, new_s1->vec1, &err, rc);
            if (BSERROR(*rc))
               goto wrapup;

            if (code != 3 && err > (10*dist_tol))
            {
               *rc = BSNONPLANAR;
               goto wrapup;
            }
         }

         /* Call BSxplngmsf */
         BSxplngmsf(new_s1, new_s2, &lgd_flag, numgrps, numint, xyz_cvs,
                    &lgd_cvs, &ptcode, num_pts, pts, &s1_code, uvpars1, 
                    &s2_code, uvpars2, rc);
         if (BSERROR(*rc)) 
            goto wrapup;

         /* Note:
              new_lgd_code indicates if uv for s1 and s2 are to be computed
              using Legendre curves (lgd_cvs):
                0 : No Legendre -- neither s1 nor s2
                1 : Legendre for s1
                2 : Legendre for s2

              Since intersection computed using Legendre polynomials
              only for infinite plane (or rectangular plane represented
              temporarily by infinite plane) / surface, only considers
              one bounded surface, only 1 set of uv can be computed based
              on the Legendre curves (lgd_cvs).   */


         if (lgd_flag)
            new_lgd_code = 2;


         /* Normalize knots of xyz_cvs.  BSuvcv_rpln copies knots of
            xyz_cvs into uv curves so both will be normalized at return. */
         ind = 0;
         if (*xyz_cvs)
         {
            for (i = 0; i < *numgrps; ++i)         
            {
                for (j = 0; j < (*numint)[i]; ++j)
                {
                    if ((*xyz_cvs)[ind+j].bspcv)
                    {
                       (void)BSnorkts(rc, &((*xyz_cvs)[ind+j].bspcv->order), 
                                      &((*xyz_cvs)[ind+j].bspcv->num_poles), 
                                      (*xyz_cvs)[ind+j].bspcv->knots);
                       if (BSERROR(*rc))
                          goto wrapup;
                    }
                }
                ind += (*numint)[i];
            }
         }

         if ((pln1 || new_s1->bspsf->planar) && new_s1->bounded && 
             (pln2 || new_s2->bspsf->planar) && new_s2->bounded && !ptcode)
         {
            /* Both new_s1 and new_s2 are planar and bounded and only xyz_cvs
               currently exist.  Get points and pars and DO NOT return
               xyz_cvs. */
            *cvscode = 0;
            getptsflag = TRUE;
         }
         else
         {
            /* If new_s1 is a bounded, rectangular plane call BSuvcv_rpln to
               get the uv curve for plane */
            if (!ptcode)
            {
               /* xyz_cvs are returned instead of points and parameters */
   
               if (new_s1->type == BSRECT_PLANE && new_s1->bounded)
               {
                  /* Call BSuvcv_rpln */
                  numcvs = 0;
                  for (i = 0; i < *numgrps; ++i)
                  {
                     for (j = 0; j < (*numint)[i]; ++j)	
                         ++numcvs;
                  }

                  if (numcvs > 0)
                  {
                     *uv1_cvs = (struct BSgeom_bsp_curve *)BSmalloc((unsigned)
                                   numcvs * sizeof (struct BSgeom_bsp_curve));
                     if (! *uv1_cvs)
                     {
                        *rc = BSNOMEMORY;
                        goto wrapup;
                     }
 
                     for (i = 0; i < numcvs; ++i)
                     {
                         (*uv1_cvs)[i].bspcv = NULL;
                         (*uv1_cvs)[i].array1 = NULL;    
                     }

                     for (i = 0; i < numcvs; ++i)
                     {
                         tcv = (*xyz_cvs)[i].bspcv;
                         BSalloccv(tcv->order, tcv->num_poles, tcv->rational,
                                   0, &((*uv1_cvs)[i].bspcv), rc);
                         if (!(*uv1_cvs)[i].bspcv)
                         {
                            *rc = BSNOMEMORY;
                            goto wrapup;
                         }

                         BSuvcv_rpln(tcv, new_s1->pt1, new_s1->pt2, 
                                     new_s1->pt3, new_s1->len1, new_s1->len2, 
                                     (*uv1_cvs)[i].bspcv, rc);
                         if (BSERROR(*rc))
                            goto  wrapup;

                         (*uv1_cvs)[i].geom_prop = FALSE;
                         (*uv1_cvs)[i].bscv_flag = TRUE;
                         (*uv1_cvs)[i].type = BSGEN_BSP_CV;
   
                      }   /* end i loop */
 
                      *cvscode = 4;        

                  }   /* end if (numcvs > 0) */
               }
               else
               {
                  *cvscode = 1;

               }   /* end if(new_s1->type= BSRECT_PLANE && new_s1->bounded) */

               if (new_s2->type == BSRECT_PLANE && new_s2->bounded)
               {
                  /* Call BSuvcv_rpln */
                  numcvs = 0;
                  for (i = 0; i < *numgrps; ++i)
                  {
                     for (j = 0; j < (*numint)[i]; ++j)	
                         ++numcvs;
                  }

                  if (numcvs > 0)
                  {
                     *uv2_cvs = (struct BSgeom_bsp_curve *)BSmalloc((unsigned)
                                   numcvs * sizeof (struct BSgeom_bsp_curve));
                     if (! *uv2_cvs)
                     {
                        *rc = BSNOMEMORY;
                        goto wrapup;
                     }
 
                     for (i = 0; i < numcvs; ++i)
                     {
                         (*uv2_cvs)[i].bspcv = NULL;
                         (*uv2_cvs)[i].array1 = NULL;    
                     }
   
                     for (i = 0; i < numcvs; ++i)
                     {
                         tcv = (*xyz_cvs)[i].bspcv;
                         BSalloccv(tcv->order, tcv->num_poles, tcv->rational,
                                   0, &((*uv2_cvs)[i].bspcv), rc);
                         if (!(*uv2_cvs)[i].bspcv)
                         {
                            *rc = BSNOMEMORY;
                            goto wrapup;
                         }
	
                         BSuvcv_rpln(tcv, new_s2->pt1, new_s2->pt2, 
                                     new_s2->pt3, new_s2->len1, new_s2->len2, 
                                     (*uv2_cvs)[i].bspcv, rc);
                         if (BSERROR(*rc))
                            goto  wrapup;
   
                         (*uv2_cvs)[i].geom_prop = FALSE;
                         (*uv2_cvs)[i].bscv_flag = TRUE;
                         (*uv2_cvs)[i].type = BSGEN_BSP_CV;
 
                     }   /* end i loop */
    
                     if (*cvscode == 4) 
                        *cvscode = 3;
                     else
                        *cvscode = 5;

                  }   /* end if (numcvs > 0) */ 

               }
               else
               {
                  if (*cvscode == 0)
                     *cvscode = 1;

               }   /* end if (new_s1->type == BSRECT_PLANE && new_s1->bounded*/

         
               getptsflag = TRUE;

            }   /* end if (!ptcode) */

         }   /* end if (pln1 && new_s1->bounded && pln2 .... */

      }
      else
      {
         /* new_s2 is planar */

         if (new_s2->type != BSINF_PLANE && new_s2->type != BSRECT_PLANE)
         {
            /* Set properties of new_s2 (pt and vec) */
            new_s2->geom_prop = TRUE;

            /* Call BSlsqptlnpl to get point and normal vector for s1 */
            npts = new_s2->bspsf->u_num_poles * new_s2->bspsf->v_num_poles;
            option = 3;
            BSlsqptlnpl(npts, new_s2->bspsf->poles, new_s2->bspsf->weights, 
                        option, &code, new_s2->pt1, new_s2->vec1, &err, rc);
            if (BSERROR(*rc))
               goto wrapup;

            if (code != 3 && err > (10*dist_tol))
            {
               *rc = BSNONPLANAR;
               goto wrapup;
            }
         }

         /* Call BSxplngmsf */
         BSxplngmsf(new_s2, new_s1, &lgd_flag, numgrps, numint, xyz_cvs, 
                    &lgd_cvs, &ptcode, num_pts, pts, &s2_code, uvpars2, 
                    &s1_code, uvpars1, rc);
         if (BSERROR(*rc)) 
            goto wrapup;

         /* Note:
              new_lgd_code indicates if uv for s1 and s2 are to be computed
              using Legendre curves (lgd_cvs):
                0 : No Legendre -- neither s1 nor s2
                1 : Legendre for s1
                2 : Legendre for s2

              Since intersection computed using Legendre polynomials
              only for infinite plane (or rectangular plane represented
              temporarily by infinite plane) / surface, only considers
              one bounded surface, only 1 set of uv can be computed based
              on the Legendre curves (lgd_cvs).   */

         if (lgd_flag)
            new_lgd_code = 1;


         /* Normalize knots of xyz_cvs.  BSuvcv_rpln copies knots of
            xyz_cvs into uv curves so both will be normalized at return. */
         ind = 0;
         if (*xyz_cvs)
         {
            for (i = 0; i < *numgrps; ++i)         
            {
                for (j = 0; j < (*numint)[i]; ++j)
                {
                    if ((*xyz_cvs)[ind+j].bspcv)
                    {
                       (void)BSnorkts(rc, &((*xyz_cvs)[ind+j].bspcv->order), 
                                      &((*xyz_cvs)[ind+j].bspcv->num_poles), 
                                      (*xyz_cvs)[ind+j].bspcv->knots);
                       if (BSERROR(*rc))
                          goto wrapup;
                    }
                }
                ind += (*numint)[i];
            }
         }

         if ((pln1 || new_s1->bspsf->planar) && new_s1->bounded && 
             (pln2 || new_s2->bspsf->planar) && new_s2->bounded && !ptcode)
         {
            /* Both new_s1 and new_s2 are planar and bounded and only xyz_cvs
               currently exist.  Get points and pars and DO NOT return
               xyz_cvs. */
            *cvscode = 0;
            getptsflag = TRUE;
         }
         else
         {
            /* If new_s2 is a bounded, rectangular plane call BSuvcv_rpln to
               get the uv curve for plane */
            if (!ptcode)
            {
               if (new_s2->type == BSRECT_PLANE && new_s2->bounded)
               {
                  /* Call BSuvcv_rpln */
                  numcvs = 0;
                  for (i = 0; i < *numgrps; ++i)
                  {
                     for (j = 0; j < (*numint)[i]; ++j)	
                         ++numcvs;
                  }

                  if (numcvs > 0)
                  {
                     *uv2_cvs = (struct BSgeom_bsp_curve *)BSmalloc((unsigned)
                                   numcvs * sizeof (struct BSgeom_bsp_curve));
                     if (! *uv2_cvs)
                     {
                        *rc = BSNOMEMORY;
                        goto wrapup;
                     }
 
                     for (i = 0; i < numcvs; ++i)
                     {
                         (*uv2_cvs)[i].bspcv = NULL;
                         (*uv2_cvs)[i].array1 = NULL;    
                     }
   
                     for (i = 0; i < numcvs; ++i)
                     {
                         tcv = (*xyz_cvs)[i].bspcv;
                         BSalloccv(tcv->order, tcv->num_poles, tcv->rational,
                                   0, &((*uv2_cvs)[i].bspcv), rc);
                         if (!(*uv2_cvs)[i].bspcv)
                         {
                            *rc = BSNOMEMORY;
                            goto wrapup;
                         }
	 
                         BSuvcv_rpln(tcv, new_s2->pt1, new_s2->pt2, 
                                     new_s2->pt3, new_s2->len1, new_s2->len2, 
                                     (*uv2_cvs)[i].bspcv, rc);
                         if (BSERROR(*rc))
                            goto  wrapup;
   
                         (*uv2_cvs)[i].geom_prop = FALSE;
                         (*uv2_cvs)[i].bscv_flag = TRUE;
                         (*uv2_cvs)[i].type = BSGEN_BSP_CV;
  
                     }   /* end i loop */
  
                     if (*cvscode == 4) 
                        *cvscode = 2;
                     else
                        *cvscode = 5;

                  }   /* end if (numcvs > 0) */ 

               }
               else
               {
                  if (*cvscode == 0)
                     *cvscode = 1;
 
               }   /* end if (new_s1->type == BSRECT_PLANE && new_s1->bounded*/

               getptsflag = TRUE;

            }   /* end if (!ptcode) */

         }   /* end if (pln1 && new_s1->bounded && pln2 .... */

      }   /* end if (pln1) */


      /* If ptcode = TRUE, intersection was found calling BSsf_pl_int
         and only pts and parameters are returned. Tranform pts back to
         original system, then go to wrapup. */
      if (ptcode)
      {
         trational = FALSE;
         for (i = 0; i < *numgrps; ++i)
         {
            for (j = 0; j < (*numint)[i]; ++j)
            {
               BSptsnwtold(tvec, mat, scale, (*num_pts)[ind+j], trational, 
                           (*pts)[ind+j], NULL, (*pts)[ind+j], rc);
               if (BSERROR(*rc))
                  goto wrapup;
            } 

            ind = ind + (*numint)[i];
         }

         goto wrapup;
      }
 
      /* If getptsflag = TRUE, intersection curves were found, now 
         get chord-height points */
      if (getptsflag)
         goto getchtpts;

   }   /* end if (pln1 || pln2) */


   if (quad1 && quad2)
   {
      /*********************/
      /* QUADRIC / QUADRIC */
      /*********************/

      /* Call BSquadsfint */
      *numint = (IGRint *)BSmalloc((unsigned)MAXNUM_QUADINT * sizeof (IGRint));
      if (! *numint)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }

      *xyz_cvs = (struct BSgeom_bsp_curve *)BSmalloc((unsigned)
                       MAXNUM_QUADINT * sizeof (struct BSgeom_bsp_curve));
      if (! *xyz_cvs)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }
 
      for (i = 0; i < MAXNUM_QUADINT; ++i)
      {
          (*xyz_cvs)[i].bspcv = NULL;
          (*xyz_cvs)[i].array1 = NULL;    
      }

      tmp_cvs = (struct BSgeom_bsp_curve ***)BSmalloc((unsigned)
                      MAXNUM_QUADINT * sizeof (struct BSgeom_bsp_curve **));
      if (! tmp_cvs)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }

      *tmp_cvs = (struct BSgeom_bsp_curve **)BSmalloc((unsigned)
                       MAXNUM_QUADINT * sizeof (struct BSgeom_bsp_curve *));
      if (! *tmp_cvs)
      {
         *rc = BSNOMEMORY;
         goto wrapup;
      }

      for (i = 0; i < MAXNUM_QUADINT; ++i)
      {
          (*tmp_cvs)[i] = &((*xyz_cvs)[i]);
          (*tmp_cvs)[i]->bspcv = NULL;
          (*tmp_cvs)[i]->array1 = NULL;
      }

      BSquadsfint(new_mod_s1, new_mod_s2, numgrps, *numint, (*tmp_cvs), rc);
      if (BSOKAY(*rc))
      {
         /* Normalize knots of xyz_cvs. */
         ind = 0;
         for (i = 0; i < *numgrps; ++i)         
         {
             for (j = 0; j < (*numint)[i]; ++j)
             {
                 if ((*xyz_cvs)[ind+j].bspcv)
                 {  
                    (void)BSnorkts(rc, &((*xyz_cvs)[ind+j].bspcv->order), 
                                   &((*xyz_cvs)[ind+j].bspcv->num_poles), 
                                   (*xyz_cvs)[ind+j].bspcv->knots);
                    if (BSERROR(*rc))
                       goto wrapup;
                 }
             }
             ind += (*numint)[i];
         }

         *cvscode = 1;
         getptsflag = TRUE;
         goto getchtpts;
      }
      else
      {
         if (*rc == BSNOTYETSUPPORTED || *rc == BSPAROUTOFBOUNDS ||
             *rc == BSINCONSISTENT)
         {
            *rc = BSSUCC;
            /* Free memory allocated before call to BSquadsfint*/
            if (tmp_cvs)
            {
               if (*tmp_cvs)
               {
                  BSdealloc((char *) *tmp_cvs);
                  *tmp_cvs = NULL;
               }

               BSdealloc((char *) tmp_cvs);
               tmp_cvs = NULL;
            }

            if (*numint)
            {
               BSdealloc((char *) *numint);
               *numint = NULL;
            }

            if (*xyz_cvs)
            {
               BSdealloc((char *) *xyz_cvs);
               *xyz_cvs = NULL;
            }
         }
         else
         {
            goto wrapup;
         }   /* end if (*rc == BSNOTYETSUPPORTED) */

      }   /* end if (BSOKAY(*rc)) */

   }   /* end if (quad1 && quad2) */


   if (prj1 && prj2)
   {
      /*********************/
      /* SF PROJ / SF PROJ */
      /*********************/

      /* If s1 and/or s2 are not type BSSF_OF_PROJ, set new_s1 and/or new_s2
         to be type BSSF_OF_PROJ */
      BScpgeomsf(new_mod_s1, new_s1, rc);
      if (BSERROR(*rc))
         goto wrapup;

      free_sfgen_cv1 = FALSE;
      if (new_mod_s1->type != BSSF_OF_PROJ)
      {
         new_s1->geom_prop = FALSE;
         new_s1->type = BSSF_OF_PROJ;
         if (new_s1->bounded)
         {
            new_s1->urange[0] = 
                new_mod_s1->bspsf->u_knots[new_mod_s1->bspsf->u_order - 1];
            new_s1->urange[1] = 
                new_mod_s1->bspsf->u_knots[new_mod_s1->bspsf->u_num_poles];
            new_s1->vrange[0] = 
                new_mod_s1->bspsf->v_knots[new_mod_s1->bspsf->v_order - 1];
            new_s1->vrange[1] = 
                new_mod_s1->bspsf->v_knots[new_mod_s1->bspsf->v_num_poles];
         }
         new_s1->sfgen_cv = NULL;
         free_sfgen_cv1 = TRUE;
      }

      BScpgeomsf(new_mod_s2, new_s2, rc);
      if (BSERROR(*rc))
         goto wrapup;

      free_sfgen_cv2 = FALSE;
      if (new_mod_s2->type != BSSF_OF_PROJ)
      {
         new_s2->geom_prop = FALSE;
         new_s2->type = BSSF_OF_PROJ;
         if (new_s2->bounded)
         {
            new_s2->urange[0] = 
                new_mod_s2->bspsf->u_knots[new_mod_s2->bspsf->u_order - 1];
            new_s2->urange[1] = 
                new_mod_s2->bspsf->u_knots[new_mod_s2->bspsf->u_num_poles];
            new_s2->vrange[0] = 
                new_mod_s2->bspsf->v_knots[new_mod_s2->bspsf->v_order - 1];
            new_s2->vrange[1] = 
                new_mod_s2->bspsf->v_knots[new_mod_s2->bspsf->v_num_poles];
         }
         new_s2->sfgen_cv = NULL;
         free_sfgen_cv2 = TRUE;
      }

      BSx2sf_prj(new_s1, new_s2, numgrps, numint, xyz_cvs,rc);
      if (BSERROR(*rc))
      {
         if(*rc != BSNOTYETSUPPORTED)
            goto wrapup;
         else
         {
            /* If rc = BSNOTYETSUPPORTED, free new_s1->sfgen_cv if 
               free_sfgen_cv1 = TRUE. Similar for new_s2->sfgen_cv */
            *rc = BSSUCC;
            if (free_sfgen_cv1)       
            {
               (void)BSfreecv(rc, new_s1->sfgen_cv);
               if (BSERROR(*rc))
                  goto wrapup;
               new_s1->sfgen_cv = NULL;
            }

            if (free_sfgen_cv2)       
            {
               (void)BSfreecv(rc, new_s2->sfgen_cv);
               if (BSERROR(*rc))
                  goto wrapup;
               new_s2->sfgen_cv = NULL;
            }
         }
      }
      else
      {
         ind = 0;
         if (*xyz_cvs)
         {
            for (i = 0; i < *numgrps; ++i)         
            {
                for (j = 0; j < (*numint)[i]; ++j)
                {
                    if ((*xyz_cvs)[ind+j].bspcv)
                    {
                       (void)BSnorkts(rc, &((*xyz_cvs)[ind+j].bspcv->order), 
                                      &((*xyz_cvs)[ind+j].bspcv->num_poles), 
                                      (*xyz_cvs)[ind+j].bspcv->knots);
                       if (BSERROR(*rc))
                          goto wrapup;
                    }
                }
                ind += (*numint)[i];
            }
         }

         *cvscode = 1;
         getptsflag = TRUE;
         goto getchtpts;
      }

   }   /* end if (prj1 && prj2) */


   if (rev1 && rev2)
   {
      /* If s1 and/or s2 are not type BSSF_OF_REV, set new_s1 and/or new_s2
         to be typ BSSF_OF_REV */

      BScpgeomsf(new_mod_s1, new_s1, rc);
      if (BSERROR(*rc))
         goto wrapup;

      if (new_mod_s1->type != BSSF_OF_REV)
      {
         new_s1->geom_prop = FALSE;
         new_s1->type = BSSF_OF_REV;
         if (new_s1->bounded)
         {
            new_s1->urange[0] = 
                new_mod_s1->bspsf->u_knots[new_mod_s1->bspsf->u_order - 1];
            new_s1->urange[1] = 
                new_mod_s1->bspsf->u_knots[new_mod_s1->bspsf->u_num_poles];
            new_s1->vrange[0] = 
                new_mod_s1->bspsf->v_knots[new_mod_s1->bspsf->v_order - 1];
            new_s1->vrange[1] = 
                new_mod_s1->bspsf->v_knots[new_mod_s1->bspsf->v_num_poles];
         }
         new_s1->sfgen_cv = NULL;
      }

      BScpgeomsf(new_mod_s2, new_s2, rc);
      if (BSERROR(*rc))
         goto wrapup;

      if (new_mod_s2->type != BSSF_OF_REV)
      {
         new_s2->geom_prop = FALSE;
         new_s2->type = BSSF_OF_REV;
         if (new_s2->bounded)
         {
            new_s2->urange[0] = 
                new_mod_s2->bspsf->u_knots[new_mod_s2->bspsf->u_order - 1];
            new_s2->urange[1] = 
                new_mod_s2->bspsf->u_knots[new_mod_s2->bspsf->u_num_poles];
            new_s2->vrange[0] = 
                new_mod_s2->bspsf->v_knots[new_mod_s2->bspsf->v_order - 1];
            new_s2->vrange[1] = 
                new_mod_s2->bspsf->v_knots[new_mod_s2->bspsf->v_num_poles];
         }
         new_s2->sfgen_cv = NULL;
      }

      BSx2sf_rev(new_s1, new_s2, numgrps, numint, xyz_cvs,rc);
      if (BSERROR(*rc))
      {
         if(*rc != BSNOTYETSUPPORTED)
            goto wrapup;
         else
         {
            /* If rc = BSNOTYETSUPPORTED, free new_s1->sfgen_cv if 
               free_sfgen_cv1 = TRUE. Similar for new_s2->sfgen_cv. */
            *rc = BSSUCC;
            if (free_sfgen_cv1)
            {
               (void)BSfreecv(rc, new_s1->sfgen_cv);
               if (BSERROR(*rc))
                  goto wrapup;
               new_s1->sfgen_cv = NULL;
            }

            if (free_sfgen_cv2)
            {
               (void)BSfreecv(rc, new_s2->sfgen_cv);
               if (BSERROR(*rc))
                  goto wrapup;
               new_s2->sfgen_cv = NULL;
            }
         }
      }
      else
      {
         ind = 0;
         if (*xyz_cvs)
         {
            for (i = 0; i < *numgrps; ++i)         
            {
                for (j = 0; j < (*numint)[i]; ++j)
                {
                    if ((*xyz_cvs)[ind+j].bspcv)
                    {
                       (void)BSnorkts(rc, &((*xyz_cvs)[ind+j].bspcv->order), 
                                      &((*xyz_cvs)[ind+j].bspcv->num_poles), 
                                      (*xyz_cvs)[ind+j].bspcv->knots);
                       if (BSERROR(*rc))
                          goto wrapup;
                    }
                }
                ind += (*numint)[i];
            }
         }

         *cvscode = 1;
         getptsflag = TRUE;
         goto getchtpts;
      }
   }   /* end if (rev1 && rev2) */


   /****************************************************************/
   /* Call BSsur_surrg for cases not supported by special routines */
   /****************************************************************/

   /* If bounded bit = FALSE for the surface, reset = TRUE and set
      uv ranges before calling BSsur_surrg. */   
   if (!mod_s1->bounded)      
   {
      tsf = mod_s1->bspsf;
      mod_s1->bounded = TRUE;
      mod_s1->urange[0] = tsf->u_knots[tsf->u_order-1];
      mod_s1->urange[1] = tsf->u_knots[tsf->u_num_poles];

      mod_s1->vrange[0] = tsf->v_knots[tsf->v_order-1];
      mod_s1->vrange[1] = tsf->v_knots[tsf->v_num_poles];
   }

   if (!mod_s2->bounded)      
   {
      tsf = mod_s2->bspsf;
      mod_s2->bounded = TRUE;
      mod_s2->urange[0] = tsf->u_knots[tsf->u_order-1];
      mod_s2->urange[1] = tsf->u_knots[tsf->u_num_poles];

      mod_s2->vrange[0] = tsf->v_knots[tsf->v_order-1];
      mod_s2->vrange[1] = tsf->v_knots[tsf->v_num_poles];
   }

   (void)BSsur_surrg(rc, mod_s1->bspsf, mod_s2->bspsf, &dum_tol1, 
                     &dum_tol2, mod_s1->urange, mod_s1->vrange, 
                     mod_s2->urange, mod_s2->vrange, numgrps, num_pts,
                     pts, uvpars1, uvpars2);
   if (BSERROR(*rc))
   {
      if (*numgrps > 0)
      {
         if (!*numint)
         {
            *numint = (IGRint *)BSmalloc((unsigned)*numgrps * sizeof (IGRint));
            if (! *numint)
            {
               *rc = BSNOMEMORY;
               goto wrapup;
            }

            /* Set numint = 1 for each group */
            for (i = 0; i < *numgrps; ++i)
                (*numint)[i] = 1;
         }

         goto wrapup;
      }
      else
      {
         goto wrapup;
      }
   }
   
   if (*numgrps > 0)
   {
      if (!*numint)
      {
         *numint = (IGRint *)BSmalloc((unsigned)*numgrps * sizeof (IGRint));
         if (! *numint)
         {
            *rc = BSNOMEMORY;
            goto wrapup;
         }

         /* Set numint = 1 for each group */
         for (i = 0; i < *numgrps; ++i)
             (*numint)[i] = 1;
      }
   }

   /***********************************/
   /*  Stroke out intersection curves */
   /***********************************/
   getchtpts:

   if (getptsflag && *numgrps > 0)
   {
      if (trans_flag)
      {
         /* Transform xyz_cvs back to original system before stroking */
         ind = 0;
         for (i = 0; i < *numgrps; ++i)
         {
            for (j = 0; j < (*numint)[i]; ++j)
            {
                BSgmcvntoo(tvec, mat, scale, &((*xyz_cvs)[ind+j]), 
                           &((*xyz_cvs)[ind+j]), rc);
                if (BSERROR(*rc))
                   goto wrapup;
            }
            ind = ind + (*numint)[i];
         }
      }

      if (lgd_flag)
      {
         bsp_cvs = (struct IGRbsp_curve **)BSmalloc(*numgrps * sizeof
                      (struct IGRbsp_curve *));

         for (i = 0; i < *numgrps; ++i)
             bsp_cvs[i] = (*xyz_cvs)[i].bspcv;

         if (*numgrps > 0 && (mod_s1->bounded || mod_s2->bounded))
         {
            BSchtptsuvc(mod_s1, mod_s2, *numgrps, bsp_cvs, new_lgd_code, 
                        lgd_cvs, num_pts, pts, uvpars1, uvpars2, rc);
            if (BSERROR(*rc))
               goto wrapup;

            if (!*numint)
            {
               *numint = (IGRint *)BSmalloc(*numgrps * sizeof (IGRint));
               if (! *numint)
               {
                  *rc = BSNOMEMORY;
                  goto wrapup;
               }

               for (i = 0; i < *numgrps; ++i)
                   (*numint)[i] = 1;
            }
            if (*cvscode == 0)
              *cvscode = 1;
         }
      }
      else
      {
         numcvs = 0;
         for (i = 0; i < *numgrps; ++i)
             numcvs += (*numint)[i];

         if (numcvs > 0 && (mod_s1->bounded || mod_s2->bounded))
         {
            bsp_cvs2 = (struct IGRbsp_curve **)BSstackalloc((unsigned) 
                          (numcvs * sizeof (struct IGRbsp_curve *)));
            if (! bsp_cvs2)
            {
               *rc = BSNOSTKMEMORY;
               goto wrapup;
            }

            for (i = 0; i < numcvs; ++i)
            {
                bsp_cvs2[i] = (*xyz_cvs)[i].bspcv;
            }

            BSchtptsuvc(mod_s1, mod_s2, numcvs, bsp_cvs2, new_lgd_code, 
                        dummystr, num_pts, pts, uvpars1, uvpars2, rc);
            if (BSERROR(*rc))
               goto wrapup;
         }   /* end if (lgd_flag) */

      }   /* end if (numcvs > 0) */

   }   /* end if (getptsflag) */


   /* If all are order = 2 linestrings (or line segments), set cvscode = 0. */

   if (*cvscode != 0)   
   {
      numcvs = 0;
      for (i = 0; i < *numgrps; ++i)
      {
          for (j = 0; j < (*numint)[i]; ++j)	
              ++numcvs;           
      }

      i = 0;
      cv_found = FALSE;
      if (*cvscode != 2)                 
      {
         /* xyz_cvs exist */	

         while (i < numcvs && !cv_found)
         {        
            if ((*xyz_cvs)[i].bspcv)
            {
               if ((*xyz_cvs)[i].bspcv->order != 2)
                  cv_found = TRUE; 
            } 
            else
            {
               cv_found = TRUE;
            }
            ++i;
         }
      }
      else
      {
         /* no xyz_cvs exist -- check uv1_cvs */
 
         while (i < numcvs && !cv_found)
         {
            if ((*uv1_cvs)[i].bspcv)	
            {
               if ((*uv1_cvs)[i].bspcv->order != 2)	
                  cv_found = TRUE;
            }
            else
            {
               cv_found = TRUE;
            }

            ++i;
         }
      }   /* end if (*cvscode != 2) */


      if (!cv_found)
         *cvscode = 0;

   }   /* end if (*cvscode != 0) */


   wrapup:
   if (new_mod_s2)
   {
      if (new_mod_s2->sfgen_cv)
      {
         (void)BSfreecv(&rc1, new_mod_s2->sfgen_cv);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
      }

      rc1 = BSSUCC;
      if (new_mod_s2->bspsf)
      {
         (void)BSstfresffl(&rc1, new_mod_s2->bspsf);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;

         BSstackdealloc((char *) new_mod_s2->bspsf);   
         new_mod_s2->bspsf = NULL;
      }

      rc1 = BSSUCC;
      BSstackdealloc((char *) new_mod_s2);
      new_mod_s2 = NULL;
   }

   if (new_mod_s1)
   {
      if (new_mod_s1->sfgen_cv)
      {
         (void)BSfreecv(&rc1, new_mod_s1->sfgen_cv);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
      }

      rc1 = BSSUCC;
      if (new_mod_s1->bspsf)
      {
         (void)BSstfresffl(&rc1, new_mod_s1->bspsf);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;

         BSstackdealloc((char *) new_mod_s1->bspsf);   
         new_mod_s1->bspsf = NULL;
      }

      rc1 = BSSUCC;
      BSstackdealloc((char *) new_mod_s1);
      new_mod_s1 = NULL;
   }

   if (mod_s1)
   {
      if (mod_s1->sfgen_cv)
      {
         (void)BSfreecv(&rc1, mod_s1->sfgen_cv);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
      }

      rc1 = BSSUCC;
      if (mod_s1->bspsf)
      {
         (void)BSstfresffl(&rc1, mod_s1->bspsf);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;

         BSstackdealloc((char *) mod_s1->bspsf);   
         mod_s1->bspsf = NULL;
      }

      rc1 = BSSUCC;
      BSstackdealloc((char *) mod_s1);
      mod_s1 = NULL;
   }

   if (mod_s2)
   {
      if (mod_s2->sfgen_cv)
      {
         (void)BSfreecv(&rc1, mod_s2->sfgen_cv);
         if (BSERROR(rc1) && BSOKAY(*rc))
             *rc = rc1;
      }

      if (mod_s2->bspsf)
      {
         (void)BSstfresffl(&rc1, mod_s2->bspsf);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;

         BSstackdealloc((char *) mod_s2->bspsf);   
         mod_s2->bspsf = NULL;
      }

      rc1 = BSSUCC;
      BSstackdealloc((char *) mod_s2);
      mod_s2 = NULL;
   }



   if (new_s1)
   {
      if (new_s1->sfgen_cv)
      {
         (void)BSfreecv(&rc1, new_s1->sfgen_cv);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
      }

      rc1 = BSSUCC;
      if (new_s1->bspsf)
      {
         (void)BSstfresffl(&rc1, new_s1->bspsf);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;

         BSstackdealloc((char *) new_s1->bspsf);   
         new_s1->bspsf = NULL;
      }

      rc1 = BSSUCC;
      BSstackdealloc((char *) new_s1);
      new_s1 = NULL;
   }

   if (new_s2)
   {
      if (new_s2->sfgen_cv)
      {
         (void)BSfreecv(&rc1, new_s2->sfgen_cv);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;
      }

      if (new_s2->bspsf)
      {
         (void)BSstfresffl(&rc1, new_s2->bspsf);
         if (BSERROR(rc1) && BSOKAY(*rc))
            *rc = rc1;

         BSstackdealloc((char *) new_s2->bspsf);   
         new_s2->bspsf = NULL;
      }

      rc1 = BSSUCC;
      BSstackdealloc((char *) new_s2);
      new_s2 = NULL;
   }

   if (bsp_cvs)
   {
      BSdealloc((char *) bsp_cvs);
      bsp_cvs = NULL;
   }

   /* If numgrps == 0, deallocate all final output*/
   if (*numgrps == 0)
   {
      if (*pts)
      {
         BSdealloc((char *) *pts);
         pts = NULL;
      }

      if (*uvpars2)
      {
         BSdealloc((char *) *uvpars2);
         *uvpars2 = NULL;
      }

      if (*uvpars1)
      {
         BSdealloc((char *) *uvpars1);
         *uvpars1 = NULL;
      }

      if (*num_pts)
      {
         BSdealloc((char *) *num_pts);
         *num_pts = NULL;
      }

      if (*numint)
      {
         BSdealloc((char *) *numint);
         *numint = NULL;
      }

      if (*xyz_cvs)
      {
         BSdealloc((char *) *xyz_cvs);
         *xyz_cvs = NULL;
      }

      *cvscode = 0;
      *numgrps = 0;
   }

   if (*rc != BSSUCC)
   {
      if (*pts)
      {
         ind = 0;
         for (i = 0; i < *numgrps; ++i)
         {
            if ((*numint)[i] > 0)
            {
               for (j = 0; j < (*numint)[i]; ++j)
               {
                  if ((*pts)[ind + j])
                  {
                     BSdealloc((char *) (*pts)[ind + j]);
                     (*pts)[ind + j] = NULL;
                  }
               } 
               ind = ind + (*numint)[i];
            }
         }

         BSdealloc((char *) *pts);
         *pts = NULL;

      }   /* end if (*pts) */

      if (*uvpars2)
      {
         ind = 0;
         for (i = 0; i < *numgrps; ++i)
         {
            if ((*numint)[i] > 0)
            {
               for (j = 0; j < (*numint)[i]; ++j)
               {
                  if ((*uvpars2)[ind + j])
                  {
                     BSdealloc((char *) (*uvpars2)[ind + j]);
                     (*uvpars2)[ind + j] = NULL;
                  }
               } 
               ind = ind + (*numint)[i];
            }
         }
         BSdealloc((char *) *uvpars2);
         *uvpars2 = NULL;

      }   /* end if (*uvpars2) */

      if (*uvpars1)
      {
         ind = 0;
         for (i = 0; i < *numgrps; ++i)
         {
            if ((*numint)[i] > 0)
            {
               for (j = 0; j < (*numint)[i]; ++j)
               {
                  if ((*uvpars1)[ind + j])
                  {
                     BSdealloc((char *) (*uvpars1)[ind + j]);
                     (*uvpars1)[ind + j] = NULL;
                  }
               } 
               ind = ind + (*numint)[i];
            }
         }
         BSdealloc((char *) *uvpars1);
         *uvpars1 = NULL;

      }   /* end if (*uvpars1) */

      if (*num_pts)
      {
         BSdealloc((char *) *num_pts);
         *num_pts = NULL;
      }
 
         if (*xyz_cvs)
         {
            ind = 0;
            for (i = 0; i < *numgrps; ++i)         
            {
               if ((*numint)[i] > 0)	
               {
                  for (j = 0; j < (*numint)[i]; ++j)
                  {
                      if ((*xyz_cvs)[ind+j].array1)
                      {
                         BSdealloc((char *) (*xyz_cvs)[ind+j].array1);
                         (*xyz_cvs)[ind+j].array1 = NULL;
                      }

                      if ((*xyz_cvs)[ind+j].bspcv)
                      {
                         (void)BSfreecv(&rc1,(*xyz_cvs)[ind+j].bspcv);
                         if (BSERROR(rc1) && BSOKAY(*rc))
                            *rc = rc1;
                         (*xyz_cvs)[ind+j].bspcv = NULL;
                      }
                  }
                  ind = ind + (*numint)[i];
               }
            }
            BSdealloc((char *) *xyz_cvs);
            *xyz_cvs = NULL;
         }

         if (*uv1_cvs)
         {
            ind = 0;
            for (i = 0; i < *numgrps; ++i)         
            {
               if ((*numint)[i] > 0)	
               {
                  for (j = 0; j < (*numint)[i]; ++j)
                  {
                      if ((*uv1_cvs)[ind+j].array1)
                      {
                         BSdealloc((char *) (*uv1_cvs)[ind+j].array1);
                         (*uv1_cvs)[ind+j].array1 = NULL;
                      }

                      if ((*uv1_cvs)[ind+j].bspcv)
                      {
                         (void)BSfreecv(&rc1,(*uv1_cvs)[ind+j].bspcv);
                         if (BSERROR(rc1) && BSOKAY(*rc))
                            *rc = rc1;
                         (*uv1_cvs)[ind+j].bspcv = NULL;
                      }
                  }
                  ind = ind + (*numint)[i];
               }
            }
            BSdealloc((char *) *uv1_cvs);
            *uv1_cvs = NULL;
         }

         if (*uv2_cvs)
         {
            ind = 0;
            for (i = 0; i < *numgrps; ++i)         
            {
               if ((*numint)[i] > 0)	
               {
                  for (j = 0; j < (*numint)[i]; ++j)
                  {
                      if ((*uv2_cvs)[ind+j].array1)
                      {
                         BSdealloc((char *) (*uv2_cvs)[ind+j].array1);
                         (*uv2_cvs)[ind+j].array1 = NULL;
                      }

                      if ((*uv2_cvs)[ind+j].bspcv)
                      {
                         (void)BSfreecv(&rc1,(*uv2_cvs)[ind+j].bspcv);
                         if (BSERROR(rc1) && BSOKAY(*rc))
                            *rc = rc1;
                         (*uv2_cvs)[ind+j].bspcv = NULL;
                      }
                  }
                  ind = ind + (*numint)[i];
               }
            }
            BSdealloc((char *) *uv2_cvs);
            *uv2_cvs = NULL;
         }

         if (*numint)
         {
            BSdealloc((char *) *numint);
            *numint = NULL;
         }

 
      *cvscode = 0;
      *numgrps = 0;
   }
 
   /* Deallocate temporary ptrs */
   if (bsp_cvs2)
   {
      BSstackdealloc((char *) bsp_cvs2);
      bsp_cvs2 = NULL;
   }

   if (lgd_cvs)
   {
     BSfrecmpcvs(lgd_cvs,&rc1);
     if (BSERROR(rc1) && BSOKAY(*rc))
       *rc = rc1;
   }
        
   if (tmp_cvs)
   {
      if (*tmp_cvs)
      {
         BSdealloc((char *) *tmp_cvs);
         *tmp_cvs = NULL;
      }

      BSdealloc((char *) tmp_cvs);
      tmp_cvs = NULL;
   }


   {
   if(BSERROR(*rc))
       BSdbgrc(*rc,"BSsfsfint");
   return;
   }
}   
