/*
  DESCRIPTION:

    This method interfaces between the sf-sf-int method at EMSsubbs and
    the math functions that compute sf-sf intersection data, in order to
    provide the intersection data in a standard EMSdataselect format. The
    idea is that this method may be overriden for special sf-sf intersections
    where intersection data is computed by other means, yet is returned
    in the same EMSdataselect format.

    As it stands today, atleast one side of the intersection set ("my" or
    the "other", will have a polyline output). This limitation exists because
    the orientation function downstream has not been updated to handle
    an all B-spline situation.

  RETURN VALUES

    Upon exit the completion code will be one of the following:

      Success codes:
      - EMS_S_Success 
          if succeeded

      Error codes:
      - EMS_E_InvalidArg 
          if the input surface data is neither a surface-object, surface buffer
          or an infinite plane.
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_BSerror
          Call to a math function returned error.

  HISTORY

    RV  04/20/88  Creation.
    SS  05/17/89  Modified to also handle coincidence with infinite plane.
    SS  08/24/90  The call to the new math function.
    NP  01/09/92  "EMaddintpts" was introducing jumps in parametric space. So
                  "EFfix_the_intersection" is called a second time. Also, if
                  the number of intersections returned by math is modified, then
                  we do not make use of the intersection "curves" that math
                  may have returned.
    NP  02/09/92  There was a mismatch in poly and Bspline data in the 
                  intersections after the call to "EFfix_the_intersections" 
                  as the UV poly data was getting reversed within the call,
                  although the final number of intersections were the same. 
                  Since there is no change in the number of intersections, the
                  above fix does not catch this situation.
                  Therefore added an option "groups_modified" to the function
                  "EFfix_the_intersections" and changed its name to 
                  "EFfix_the_int". (TR 92n0787)
    NP 	02/19/92  The variable "ints_modified" was declared an "int" in this
                  method and "IGRboolean" in "EFfix_the_int". Therefore, even
                  if "ints_modified" (which is a short in EFfix_the_int) 
                  returns a "FALSE", the "ints_modified" in this method (which
                  is an int) could have a junk value. A symptom of this was 
                  that CURVE elements were being changed to POLY, when they 
                  should not have been. (TR 92n1464).
    NP  03/06/92  Further modified the check for freeing UV/XYZ curve memory in
                  case intersections returned by math are modified. Created two
                  new macros that free curve and polyline memory.(TR 92n2162)
    NP  05/25/92  Added timer function calls to time this method.
    NP  08/25/92  Modified for ANSI compliance. Moved "static void getcvtype" 
		  declaration to global scope.
    NP  04/13/93  Send the option "EMS_O_AckOnSf_Flag" in to EMaddintpts during
                  double check (when EMSINTER_MORE_PRECISE is set). This will
                  ENSURE that the newly added xyz points will lie on the surface
    NP  04/14/93  Undid the above fix. Instead, fixed  "EMaddintpts" to ensure 
                  that newly added xyz points will ALWAYS lie on the surface.
    NP  04/14/93  If OM_VERBOSE_WARNING is set, then a message is printed to 
                  stderr every time "fixing" of the intersection data is done. 
                  If data returned by math is good, fixing NEVER need be done.
    NP  04/21/93  Whole bunch of fixes. Updated macro to free ALL memory 
                  allocated by math (i.e. bspcv & array1). Free "sfgen_cv" ptr
                  returned by math in structure "BSgeom_bsp_surf" .Initialized 
                  "sfgen_cv" pointer to NULL before calling "BSsfsfint". Always
                  error out if ANY fixing is done (keyed off on a new global
                  variable called "_allow_intersection_fixing" instead of on
                  OM_VERBOSE_WARNING as mentioned above).
   Jack 06/11/93  Replaced use of _create_special_partial_surfaces with
                  WANT_POST220_BEHAVIOR.
   NP   06/17/93  Bunch of modifications. Added "_skip_intersection_fixing" 
                  toggle to totally skip the fixup code. EFfixtheint function
                  now returns bits indicating exactly what fixing was done. We
                  error out if fixing is done while "_allow_intersection_fixing"
                  is FALSE, else we just print message to stderr as to exactly
                  what fixing was done.Added a new math call BSsfsfdgnck, that
                  removes all XYZ degenerate intersection groups, i.e. removes 
                  all data (poly & curve, for both UV & XYZ) pertaining to that
                  degenerate intersection. Also added code to check if the 
                  geometry of a CONE or PARTIAL CONE is that of a CYL or PARTIAL
                  CYL, in which case we flag the surface as CYL/PARTIAL CYL to
                  math, so that they can return correct intersections. Whew!!!
      
   NP   01/04/94  Added "OM_Gf_verbose_warning" check before printing any
                  message relating to "fixing" of intersections.
*/

class implementation EMSsubbs;

#include "EMS.h"
#include "OMmacros.h"
#include "msdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsedgedef.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "EMSopt.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bsmalloc.h"
#include "timerdef.h"

#define UMIN 0
#define VMIN 1
#define UMAX 2
#define VMAX 3

#define ALL_POLY	 0
#define XYZ_CVS          1
#define XYZ_AND_UV_CVS   3
#define XYZ_AND_UV1_CVS  4
#define XYZ_AND_UV2_CVS  5

/* This macro takes in the size and pointer to an array of "BSgeom_bsp_curve" 
 * structs and frees the memory pointed to by the "IGRbsp_curve" and "array1"
 * components of the structs. The "IGRbsp_curve" curves are returned by math 
 * during intersections. Also, the pointer to the array is freed and set to 
 * NULL. The curves could be either UV or XYZ curves.
 *
 * NOTE: When math has a routine to deallocate ALL memory it has allocated 
 * ----  within "BSgeom_bsp_curve", that routine should replace the two "if"
 *       statements below for "bspcv" and "array1".
 */
#define free_bspmath_curve_data(msg_ptr,num_elements,bscurve_array)           \
        {                                                                     \
	  if (bscurve_array)                                                  \
            {  int i;                                                         \
               for (i=0; i<(num_elements); i++)                               \
               {                                                              \
                  if ( (bscurve_array)[i].bspcv)                              \
                     BSfreecv ((msg_ptr), (bscurve_array)[i].bspcv);          \
                  if ( (bscurve_array)[i].array1)                             \
                     BSdealloc((char *) ((bscurve_array)[i].array1));         \
               }                                                              \
               om$dealloc (ptr = (bscurve_array));                            \
               (bscurve_array)= NULL;                                         \
            }                                                                 \
        }

/* This macro takes in the size and pointer to an array of pointers to UV or XYZ
 * intersection polyline data. After freeing the polyline data, it also frees
 * the pointer to the array and sets it to NULL.
 */
#define free_bspmath_poly_data(num_elements,poly_array)   \
        {                                                 \
	  if (poly_array)                                 \
            {  int i;                                     \
               for (i=0; i<(num_elements); i++)           \
                  if ( (poly_array)[i])                   \
                    om$dealloc (ptr = (poly_array)[i]);   \
               om$dealloc (ptr = (poly_array));           \
               (poly_array) = NULL;                       \
            }                                             \
        }

/* This macro frees ALL the data that may have been malloced by math in the
 * BSsfsfint() function. Any of the intput may be NULL.
 * NOTE: I never check error code in this macro, while maybe I should. What can
 *       go wrong while doing a 'free' though?
 * Here is what the input should look like:
 *
 *  IGRlong                   *msg_ptr;
 *  IGRint                    num_ints;
 *  IGRdouble                 ***xyzpts, ***uv1pts, ***uv2pts;
 *  struct BSgeom_bsp_curve   *xyzcvs, *uv1cvs, *uv2cvs;
 *  struct BSgeom_bsp_surf    *sf1, *sf2;
 */

#define free_bspmath_data(msg_ptr, num_ints, xyzpts, uv1pts, uv2pts,                                                         xyzcvs, uv1cvs, uv2cvs,                                                         sf1,sf2)                        \
        {   IGRlong msg_loc;                                                 \
                                                                             \
            if (xyzpts)                                                      \
              free_bspmath_poly_data((num_ints), (xyzpts));                  \
            if (uv1pts)                                                      \
              free_bspmath_poly_data((num_ints), (uv1pts));                  \
            if (uv2pts)                                                      \
              free_bspmath_poly_data((num_ints), (uv2pts));                  \
            if (xyzcvs)                                                      \
              free_bspmath_curve_data(&msg_loc, (num_ints), (xyzcvs));       \
            if (uv1cvs)                                                      \
              free_bspmath_curve_data(&msg_loc, (num_ints), (uv1cvs));       \
            if (uv2cvs)                                                      \
              free_bspmath_curve_data(&msg_loc, (num_ints), (uv2cvs));       \
            if ((sf1) && ((sf1)->sfgen_cv))                                  \
            {                                                                \
                BSfreecv(&msg_loc, (sf1)->sfgen_cv);                         \
                (sf1)->sfgen_cv = NULL;                                      \
            }                                                                \
            if ((sf2) && ((sf2)->sfgen_cv))                                  \
            {                                                                \
                BSfreecv(&msg_loc, (sf2)->sfgen_cv);                         \
                (sf2)->sfgen_cv = NULL;                                      \
            }                                                                \
            if (msg_ptr)                                                     \
              *(msg_ptr) = msg_loc;                                          \
        }

extern IGRboolean _new_sfsfint_math, _use_infinite_plane;
extern IGRboolean WANT_POST220_BEHAVIOR;
extern IGRboolean _use_timers, _allow_intersection_fixing;
extern IGRboolean _skip_intersection_fixing;
extern OMuint     OM_Gf_verbose_warning;

extern GRclassid OPP_EMSplane_class_id;
extern GRclassid OPP_EMScylindr_class_id, OPP_EMSpcylindr_class_id;
extern GRclassid OPP_EMScone_class_id, OPP_EMSpcone_class_id;
extern GRclassid OPP_EMStorus_class_id, OPP_EMSsphere_class_id;
extern GRclassid OPP_EMSptorus_class_id, OPP_EMSpsphere_class_id;
extern GRclassid OPP_EMSrevol_class_id, OPP_EMSproject_class_id;

extern GRclassid OPP_EMAplane_class_id;
extern GRclassid OPP_EMAcylindr_class_id, OPP_EMApcylindr_class_id;
extern GRclassid OPP_EMAcone_class_id, OPP_EMApcone_class_id;
extern GRclassid OPP_EMAtorus_class_id, OPP_EMAsphere_class_id;
extern GRclassid OPP_EMAptorus_class_id, OPP_EMApsphere_class_id;
extern GRclassid OPP_EMArevol_class_id, OPP_EMAproject_class_id;

from EMSplane import EMis_rect_plane;

%safe
static void getcvtype();
%endsafe

method EMget_int_data (IGRlong *msg; IGRushort options;
                       struct EMSdataselect *other_data;
                       struct IGRbsp_surface *my_geom;
                       struct IGRbsp_surface *other_geom;
                       IGRdouble *my_uvrange;
                       IGRdouble *other_uvrange;
                       struct EMSpartolbasis *my_partol;
                       struct EMSpartolbasis *other_partol;
                       IGRint *num_pieces;
                       struct EMSdataselect **my_xyz_data;
                       struct EMSdataselect **other_xyz_data;
                       struct EMSdataselect **my_uv_data;
                       struct EMSdataselect **other_uv_data;
                       IGRdouble ***correl_params;
                       IGRchar *curve_type;
                       IGRushort *intinfo)
{
  IGRboolean stat_func, infpln, extended_flag, remove_edges_along_natbdry;
  IGRboolean is_planar, is_homogenous, is_samexyz, is_matched, is_xyz_uv_cvs;
  IGRushort addopts;
  IGRshort cvscode, bscvtype, chk_flag;
  IGRint i, outcvs, num_grps, *num_ints_grp, totnum_ints, *num_pts_int;
  IGRlong msg_loc, stat_OM;
  IGRdouble cht_tol, cvg_tol;
  IGRdouble urange1[2], vrange1[2], urange2[2], vrange2[2];
  IGRdouble *ptr, ***myuvpts, ***otheruvpts, ***uv_pts, ***xyzpts, **dum_tans;
  IGRvector nvec;
  struct IGRpolyline *temp_poly;
  struct EMSdataselect *p_xyz1_data, *p_xyz2_data;
  struct EMSdataselect *p_uv1_data, *p_uv2_data;
  struct BSgeom_bsp_surf sf1, sf2;
  struct BSgeom_bsp_curve *xyz_cvs, *uv1_cvs, *uv2_cvs, *uv_cvs;
  void getsftype();
  extern IGRboolean BSsur_surrg(), BSfreecv();
  extern void BSsf_pl_int(), BSsfsfint(), BStst_plan(), BSsftgeomsf();
  extern void BSsfsfdgnck();

  /* start timer for EMget_int_data */
  if (_use_timers)
    start_timer (T_EMGETINTDATA);

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  *my_xyz_data = NULL;
  *other_xyz_data = NULL;
  *my_uv_data = NULL;
  *other_uv_data = NULL;
  *correl_params = NULL;
  *num_pieces = 0;
  *intinfo = NULL;

  num_grps = 0;
  num_ints_grp = NULL;
  totnum_ints = 0;
  num_pts_int = NULL;
  myuvpts = NULL;
  otheruvpts = NULL;
  xyzpts = NULL;
  dum_tans = NULL;
  xyz_cvs = NULL;
  uv1_cvs = NULL;
  uv2_cvs = NULL;

  EMerr_hndlr (other_data->datatype == EMSdata_object && !other_geom ||
   !my_geom, *msg, EMS_E_InvalidArg, ret_end);

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, cht_tol);
  BSEXTRACTPAR (&msg_loc, BSTOLQNWT, cvg_tol);
  if (other_data->datatype == EMSdata_surface)
    other_geom = other_data->data.surface;

  cvscode = ALL_POLY;

  if (_use_timers)
    start_timer (T17_BSSFSFINT);

  if (_new_sfsfint_math)
    {
    sf1.geom_prop = FALSE;
    getsftype (my_id, OM_Gw_current_OS, &sf1.type);
    sf1.bounded = TRUE;
    ptr = sf1.urange;
    ptr[0] = my_uvrange[UMIN];
    ptr[1] = my_uvrange[UMAX];
    ptr = sf1.vrange;
    ptr[0] = my_uvrange[VMIN];
    ptr[1] = my_uvrange[VMAX];
    sf1.bspsf = my_geom;

    sf1.sfgen_cv = NULL; /*Initialize. Free later if alloced by math.*/
    sf2.sfgen_cv = NULL; /*Initialize. Free later if alloced by math.*/

    if (other_data->datatype == EMSdata_plane)
      {
      sf2.geom_prop = TRUE;
      sf2.type = BSINF_PLANE;
      sf2.bounded = FALSE;
      OM_BLOCK_MOVE (other_data->data.plane->point, sf2.pt1,
       sizeof (IGRpoint));
      OM_BLOCK_MOVE (other_data->data.plane->normal, sf2.vec1,
       sizeof (IGRvector));
      }
    else
      {
      infpln = FALSE;
      if (_use_infinite_plane)
        {
        BStst_plan (other_geom->u_num_poles * other_geom->v_num_poles,
         other_geom->poles, other_geom->rational ? other_geom->weights : NULL,
         &is_planar, nvec, &msg_loc);
        EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

        if (is_planar)
          {
          sf2.geom_prop = TRUE;
          sf2.type = BSINF_PLANE;
          sf2.bounded = FALSE;
          OM_BLOCK_MOVE (other_geom->poles, sf2.pt1, sizeof (IGRpoint));
          if (other_geom->rational)
            for (i=0; i<3; i++)
              sf2.pt1[i] /= *other_geom->weights;
          OM_BLOCK_MOVE (nvec, sf2.vec1, sizeof (IGRvector));
          infpln = TRUE;
          }
        }

      if (!infpln)
        {
        sf2.geom_prop = FALSE;
        if (other_data->datatype == EMSdata_surface)
          sf2.type = BSGEN_BSP_SF;
        else
          getsftype (other_data->data.object->objid,
           other_data->data.object->osnum, &sf2.type);
        sf2.bounded = TRUE;
        ptr = sf2.urange;
        ptr[0] = other_uvrange[UMIN];
        ptr[1] = other_uvrange[UMAX];
        ptr = sf2.vrange;
        ptr[0] = other_uvrange[VMIN];
        ptr[1] = other_uvrange[VMAX];
        sf2.bspsf = other_geom;
        }
      }

     BSsfsfint (&sf1, &sf2, &num_grps, &num_ints_grp, &num_pts_int,
     &xyzpts, &myuvpts, &otheruvpts,
     &cvscode, &xyz_cvs, &uv1_cvs, &uv2_cvs, &msg_loc);

     /* Post-process the intersections to remove any XYZ degenerate stuff */

     chk_flag = 1; /* ==> remove XYZ degenerate intersections*/

     BSsfsfdgnck(&sf1, &sf2, chk_flag, &num_grps,&num_ints_grp,&num_pts_int,
     &xyzpts, &myuvpts, &otheruvpts,
     &cvscode, &xyz_cvs, &uv1_cvs, &uv2_cvs, &msg_loc);

      /* This was the way we were handling it before version 2.2. This was 
       * when cone was being changed to cylinder during recompute (type 
       * was still set to cone) and math failed. For post 220 behavior, see
       * code above BSsfsfint call.
       * NOTE: It seems to me that if "type" is sent in as BSFULL_CONE or 
       * ----  BSPART_CONE, (while the geometry is that of a BSFULL_CYL or
       *       BSPART_CYL), math does not seem to return an error code. Instead
       *       it returns a BSSUCC code while setting  num_grps to 0. So I 
       *       dont see how the code below will help.
       */

     if((msg_loc==BSINARG || msg_loc==BSNOSOLUTION) && !WANT_POST220_BEHAVIOR)
     {

       if(sf1.type == BSPART_CONE || sf1.type == BSFULL_CONE ||
          sf2.type == BSPART_CONE || sf2.type == BSFULL_CONE)
       {
         if(sf1.type == BSPART_CONE || sf1.type == BSFULL_CONE)
            sf1.type = BSGEN_BSP_SF;
         if(sf2.type == BSPART_CONE || sf2.type == BSFULL_CONE)
            sf2.type = BSGEN_BSP_SF;
    
         /* free math data before calling sfsfint again */
         free_bspmath_data(&msg_loc, totnum_ints, xyzpts, myuvpts, otheruvpts,
                                       xyz_cvs, uv1_cvs, uv2_cvs, &sf1, &sf2);

         BSsfsfint (&sf1, &sf2, &num_grps, &num_ints_grp, &num_pts_int,
         &xyzpts, &myuvpts, &otheruvpts,
         &cvscode, &xyz_cvs, &uv1_cvs, &uv2_cvs, &msg_loc);

         /* Post-process the intersections to remove any XYZ degenerate stuff */

         chk_flag = 1; /* ==> remove XYZ degenerate intersections*/

         BSsfsfdgnck(&sf1, &sf2, chk_flag, &num_grps,&num_ints_grp,&num_pts_int,
         &xyzpts, &myuvpts, &otheruvpts,
         &cvscode, &xyz_cvs, &uv1_cvs, &uv2_cvs, &msg_loc);
       }
     }


    stat_func = TRUE;
    totnum_ints = 0;
    for (i=0; i<num_grps; i++)
      totnum_ints += num_ints_grp[i];

    }
  else
    {
    if (other_data->datatype != EMSdata_plane)
      {
      if (other_geom->planar && !my_geom->planar ||
          !other_geom->rational && my_geom->rational)
        {
        urange1[0] = other_uvrange[UMIN];
        urange1[1] = other_uvrange[UMAX];
        vrange1[0] = other_uvrange[VMIN];
        vrange1[1] = other_uvrange[VMAX];

        urange2[0] = my_uvrange[UMIN];
        urange2[1] = my_uvrange[UMAX];
        vrange2[0] = my_uvrange[VMIN];
        vrange2[1] = my_uvrange[VMAX];

        stat_func = BSsur_surrg (&msg_loc, other_geom, my_geom,
                     &cht_tol, &cvg_tol,
                     urange1, vrange1, urange2, vrange2,
                     &totnum_ints, &num_pts_int,
                     &xyzpts, &otheruvpts, &myuvpts);
        }
      else
        {
        urange1[0] = my_uvrange[UMIN];
        urange1[1] = my_uvrange[UMAX];
        vrange1[0] = my_uvrange[VMIN];
        vrange1[1] = my_uvrange[VMAX];

        urange2[0] = other_uvrange[UMIN];
        urange2[1] = other_uvrange[UMAX];
        vrange2[0] = other_uvrange[VMIN];
        vrange2[1] = other_uvrange[VMAX];

        stat_func = BSsur_surrg (&msg_loc, my_geom, other_geom,
                     &cht_tol, &cvg_tol,
                     urange1, vrange1, urange2, vrange2,
                     &totnum_ints, &num_pts_int,
                     &xyzpts, &myuvpts, &otheruvpts);
        }
      }
    else
      {
      BSsf_pl_int (other_data->data.plane->point,
       other_data->data.plane->normal, my_geom, extended_flag = FALSE,
       &totnum_ints, &num_pts_int, &xyzpts, &dum_tans, &myuvpts, &msg_loc);
      stat_func = TRUE;
      }
    }

  /* stop timer for BSsfsfint call */
  if (_use_timers)
   stop_timer (T17_BSSFSFINT, FALSE, "");

  EMerr_hndlr (!stat_func || msg_loc != BSSUCC && msg_loc != BSCOINCIDENT,
   *msg, EMS_E_BSerror, ret_end);

  if (msg_loc == BSCOINCIDENT)
    {
    *msg = EMS_I_Coincident;
    goto ret_end;
    }
  else if (!totnum_ints)
    goto ret_end;


  if (!_skip_intersection_fixing)
    {
    int        totnum_ints_math;
    IGRushort  ints_fixed;

    /* start timer for "fix intersections" */
    if (_use_timers)
      start_timer (T17_FIX_INTERSECTIONS);

    totnum_ints_math = totnum_ints; /* no. of intersections returned by math */
    ints_fixed = NULL;     /* we have not modified return data from math */

    /* The "EFfix_the_int" routines can split intersections so that the 
     * number of intersections returned by math is modified. This means
     * that the POLYLINE data for the intersection curves (i.e. xyzpts, myuvpts 
     * and otheruvpts) has been split to create more intersections. HOWEVER, 
     * currently we are not splitting the xyz and uv CURVES that may also be 
     * returned by math. Therefore, at the end of this function, when the 
     * memory de-allocation routines are called, there may be less than 
     * "totnum_ints" number of xyz and uv curves in memory, which means 
     * we are trying to free non-existing memory which will lead 
     * to a segmentation violation error. Therefore, in this case, we simply
     * act as if math did not return the xyz and uv curves by setting the 
     * cvscode to "ALL_POLY". This also means that we have to de-allocate 
     * the memory for the curves BEFORE going to "ret_end".
     *	
     * As a special case, even if the no. of intersections returned by math 
     * are not changed after the above calls, it may be the case that 
     * intersctions were created and deleted within "EFfix_the_int", so 
     * that there is no change in the final number of intersections. HOWEVER,
     * it is possible that in the process of creating and deleting intersec-
     * tions, the poly UV data might have gotten reversed, thus creating a 
     * mis-match with the Bspline curve data that might also have been
     * returned by math. In this case too, the "ints_fixed" flag would
     * come back as true since the intersections were modified within
     * "EFfix_the_int" and therefore we use ONLY poly data.   Navin.
     */

    EFfix_the_int(&ints_fixed, remove_edges_along_natbdry = FALSE,
     my_geom, other_geom, &totnum_ints, &num_pts_int, &xyzpts, &myuvpts,
     otheruvpts ? &otheruvpts : NULL, &msg_loc);
 
    if (EMSerror (msg_loc)) 
    {
      /* Intersections MAY have been split before error occurred */
      if (ints_fixed)
      {
        /* free memory for xyzcvs &/or uv1_cvs &/or uv2_cvs if any */
	free_bspmath_curve_data(&msg_loc,totnum_ints_math,xyz_cvs);
	free_bspmath_curve_data(&msg_loc,totnum_ints_math,uv1_cvs);
	free_bspmath_curve_data(&msg_loc,totnum_ints_math,uv2_cvs);
      }

      if (_allow_intersection_fixing)
      { 
         if (OM_Gf_verbose_warning)
         {
           fprintf (stderr, "\nError while fixing intersections\n\n");
           print_fix_message(ints_fixed); /* macro defined in emssfintdef.h*/
         }
      }
        
      *msg = EMS_E_Fail;
      goto ret_end;
    }

    if (ints_fixed)
    {   
        cvscode = ALL_POLY; /* assume NO xyz/uv1/uv2 cvs were output */
        /* free memory for xyzcvs &/or uv1_cvs &/or uv2_cvs if any */
        free_bspmath_curve_data(&msg_loc,totnum_ints_math,xyz_cvs);
        free_bspmath_curve_data(&msg_loc,totnum_ints_math,uv1_cvs);
        free_bspmath_curve_data(&msg_loc,totnum_ints_math,uv2_cvs);

        if (_allow_intersection_fixing)
        { 
           if (OM_Gf_verbose_warning)
           {
             fprintf (stderr, "\nIntersections fixed\n\n");
             print_fix_message(ints_fixed); /* macro defined in emssfintdef.h*/
           }
        }
        else
        {  *msg = EMS_E_Fail;
           goto ret_end;
        }
    }
    if (!totnum_ints)
      goto ret_end;

    if (options & EMS_INTER_MOREPRECISE)
      addopts = EMS_O_No_SfCheck ;
    else
      addopts = NULL;

    EMaddintpts (&msg_loc, my_geom, other_geom, totnum_ints, num_pts_int,
      xyzpts, myuvpts, otheruvpts, addopts);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    /* SECOND check is required because the "EMaddintpts" MAY have introduced
     * jumps across the parametric space, that need to be fixed. Actually only
     * the EFfix_jumps check is required and not all the checks in the 
     * "EFfix_the_int" function. However, it is safer to make all the
     * checks again.
     */
    ints_fixed = NULL;
    EFfix_the_int(&ints_fixed, remove_edges_along_natbdry = FALSE,
     my_geom, other_geom, &totnum_ints, &num_pts_int, &xyzpts, &myuvpts,
     otheruvpts ? &otheruvpts : NULL, &msg_loc);
    
    if (EMSerror (msg_loc))
    { 
      /* Intersections MAY have been split before error occurred */
      if (ints_fixed)
      { 
        /* free memory for xyzcvs &/or uv1_cvs &/or uv2_cvs if any */
        free_bspmath_curve_data(&msg_loc,totnum_ints_math,xyz_cvs);
        free_bspmath_curve_data(&msg_loc,totnum_ints_math,uv1_cvs);
        free_bspmath_curve_data(&msg_loc,totnum_ints_math,uv2_cvs);
      }

      if (_allow_intersection_fixing)
      {
         if(OM_Gf_verbose_warning)
         {
           fprintf (stderr, "\nError while fixing intersections\n\n");
           print_fix_message(ints_fixed); /* macro defined in emssfintdef.h*/
         }
      }
      *msg = EMS_E_Fail;
      goto ret_end;
    }

    if (ints_fixed)
    {   cvscode = ALL_POLY; /** assume NO xyz/uv1/uv2 cvs were output **/
        /* free memory for xyzcvs &/or uv1_cvs &/or uv2_cvs if any */
        free_bspmath_curve_data(&msg_loc,totnum_ints_math,xyz_cvs);
        free_bspmath_curve_data(&msg_loc,totnum_ints_math,uv1_cvs);
        free_bspmath_curve_data(&msg_loc,totnum_ints_math,uv2_cvs);

        if (_allow_intersection_fixing)
        {
          if (OM_Gf_verbose_warning)
          { fprintf (stderr, "\nIntersections fixed after adding points\n\n");
            print_fix_message(ints_fixed); /* macro defined in emssfintdef.h*/
          }
        }
        else
        {  *msg = EMS_E_Fail;
           goto ret_end;
        }
    }

    if (!totnum_ints)
      goto ret_end;

    /* stop timer for "fix intersections" */
    if (_use_timers)
      stop_timer (T17_FIX_INTERSECTIONS, FALSE, "");

    }/* if (!_skip_intersection_fixing) */

  *my_xyz_data = (struct EMSdataselect *) om$malloc (size = totnum_ints *
                  sizeof (struct EMSdataselect));
  EMerr_hndlr (!*my_xyz_data, *msg, EMS_E_NoDynamicMemory, ret_end);

  is_xyz_uv_cvs = cvscode == XYZ_AND_UV_CVS ||
                   cvscode == XYZ_AND_UV1_CVS ||
                   cvscode == XYZ_AND_UV2_CVS;
  if (is_xyz_uv_cvs)
    {
    *other_xyz_data = (struct EMSdataselect *) om$malloc (size = totnum_ints *
                       sizeof (struct EMSdataselect));
    EMerr_hndlr (!*other_xyz_data, *msg, EMS_E_NoDynamicMemory, ret_end);
    }

  *my_uv_data = (struct EMSdataselect *) om$malloc (size = totnum_ints *
                 sizeof (struct EMSdataselect));
  EMerr_hndlr (!*my_uv_data, *msg, EMS_E_NoDynamicMemory, ret_end);

  if (otheruvpts)
    {
    *other_uv_data = (struct EMSdataselect *) om$malloc (size = totnum_ints *
                      sizeof (struct EMSdataselect));
    EMerr_hndlr (!*other_uv_data, *msg, EMS_E_NoDynamicMemory, ret_end);
    }

  outcvs = FALSE;
  is_matched = TRUE;
  is_samexyz = TRUE;
  if (is_xyz_uv_cvs)
    {
    if (cvscode == XYZ_AND_UV2_CVS)
      {
      p_xyz1_data = *other_xyz_data;
      p_uv1_data = *other_uv_data;
      p_xyz2_data = *my_xyz_data;
      p_uv2_data = *my_uv_data;
      uv_cvs = uv2_cvs;
      uv_pts = myuvpts;
      }
    else
      {
      p_xyz1_data = *my_xyz_data;
      p_uv1_data = *my_uv_data;
      p_xyz2_data = *other_xyz_data;
      p_uv2_data = *other_uv_data;
      uv_cvs = uv1_cvs;
      uv_pts = otheruvpts;
      }
    }

  for (i=0; i<totnum_ints; i++)
    {
    if (is_xyz_uv_cvs)
      {
      p_xyz1_data[i].datatype = EMSdata_curve3d;
      p_xyz1_data[i].data.curve = xyz_cvs[i].bspcv;
      xyz_cvs[i].bspcv = NULL;

      p_xyz2_data[i].datatype = EMSdata_poly3d;
      temp_poly = (struct IGRpolyline *) om$malloc (size =
                   sizeof (struct IGRpolyline));
      EMerr_hndlr (!temp_poly, *msg, EMS_E_NoDynamicMemory, ret_end);
      temp_poly->points = (IGRdouble *) xyzpts[i];
      xyzpts[i] = NULL;
      temp_poly->num_points = num_pts_int[i];
      p_xyz2_data[i].data.poly = temp_poly;
      temp_poly = NULL;

      p_uv1_data[i].datatype = EMSdata_curve3d;
      p_uv1_data[i].data.curve = uv_cvs[i].bspcv;
      uv_cvs[i].bspcv = NULL;

      if (*other_uv_data && otheruvpts)
       {
        p_uv2_data[i].datatype = EMSdata_poly2d;
        temp_poly = NULL;
        temp_poly = (struct IGRpolyline *) om$malloc (size =
                   sizeof(struct IGRpolyline));
        EMerr_hndlr (!temp_poly, *msg, EMS_E_NoDynamicMemory, ret_end);
        temp_poly->points = (IGRdouble *) uv_pts[i];
        uv_pts[i] = NULL;
        temp_poly->num_points = num_pts_int[i];
        p_uv2_data[i].data.poly = temp_poly;
        temp_poly = NULL;
       }


      outcvs = TRUE;
      is_samexyz = FALSE;
      is_matched = FALSE;
      }
    else if (options & EMS_INTER_BSPCURVES && cvscode == XYZ_CVS)
      {
      (*my_xyz_data)[i].datatype = EMSdata_curve3d;
      (*my_xyz_data)[i].data.curve = xyz_cvs[i].bspcv;
      xyz_cvs[i].bspcv = NULL;

      *other_xyz_data = *my_xyz_data;

      (*my_uv_data)[i].datatype = EMSdata_poly2d;
      temp_poly = NULL;
      temp_poly = (struct IGRpolyline *) om$malloc (size =
                   sizeof (struct IGRpolyline));
      EMerr_hndlr (!temp_poly, *msg, EMS_E_NoDynamicMemory, ret_end);
      temp_poly->points = (IGRdouble *) myuvpts[i];
      myuvpts[i] = NULL;
      temp_poly->num_points = num_pts_int[i];
      (*my_uv_data)[i].data.poly = temp_poly;
      temp_poly = NULL;

      if (*other_uv_data && otheruvpts)
        {
        (*other_uv_data)[i].datatype = EMSdata_poly2d;
        temp_poly = NULL;
        temp_poly = (struct IGRpolyline *) om$malloc (size =
                     sizeof(struct IGRpolyline));
        EMerr_hndlr (!temp_poly, *msg, EMS_E_NoDynamicMemory, ret_end);
        temp_poly->points = (IGRdouble *) otheruvpts[i];
        otheruvpts[i] = NULL;
        temp_poly->num_points = num_pts_int[i];
        (*other_uv_data)[i].data.poly = temp_poly;
        temp_poly = NULL;
        }

      outcvs = TRUE;
      is_matched = FALSE;
      }
    else
      {
      (*my_xyz_data)[i].datatype = EMSdata_poly3d;
      temp_poly = (struct IGRpolyline *) om$malloc (size =
                   sizeof (struct IGRpolyline));
      EMerr_hndlr (!temp_poly, *msg, EMS_E_NoDynamicMemory, ret_end);
      temp_poly->points = (IGRdouble *) xyzpts[i];
      xyzpts[i] = NULL;
      temp_poly->num_points = num_pts_int[i];
      (*my_xyz_data)[i].data.poly = temp_poly;
      temp_poly = FALSE;

      *other_xyz_data = *my_xyz_data;

      (*my_uv_data)[i].datatype = EMSdata_poly2d;
      temp_poly = NULL;
      temp_poly = (struct IGRpolyline *) om$malloc (size =
                   sizeof (struct IGRpolyline));
      EMerr_hndlr (!temp_poly, *msg, EMS_E_NoDynamicMemory, ret_end);
      temp_poly->points = (IGRdouble *) myuvpts[i];
      myuvpts[i] = NULL;
      temp_poly->num_points = num_pts_int[i];
      (*my_uv_data)[i].data.poly = temp_poly;
      temp_poly = NULL;

      if (*other_uv_data && otheruvpts)
        {
        (*other_uv_data)[i].datatype = EMSdata_poly2d;
        temp_poly = NULL;
        temp_poly = (struct IGRpolyline *) om$malloc (size =
                     sizeof(struct IGRpolyline));
        EMerr_hndlr (!temp_poly, *msg, EMS_E_NoDynamicMemory, ret_end);
        temp_poly->points = (IGRdouble *) otheruvpts[i];
        otheruvpts[i] = NULL;
        temp_poly->num_points = num_pts_int[i];
        (*other_uv_data)[i].data.poly = temp_poly;
        temp_poly = NULL;
        }
      }
    } 

  *intinfo |= is_samexyz ? EMSintdata_samexyzdat : NULL;
  *intinfo |= is_matched ? EMSintdata_matcheddat : NULL;
  *num_pieces = totnum_ints;

  if (!outcvs)
    {
    /* 
     * Since at this level no intelligence is really available about the
     * model space type of the intersection pieces, set the curve_type to
     * linestring or linesegment.
     */

    if (totnum_ints == 1 && (*my_xyz_data)[0].data.poly->num_points == 2)
      *curve_type = EMlinesegment;
    else
      *curve_type = EMlinestring;
    }
  else
    {
    /*
     * The curve type is extracted from the output of the math-call.
     */

    is_homogenous = TRUE;
    bscvtype = xyz_cvs[0].type;
    for (i=0; i<totnum_ints; i++)
      if (xyz_cvs[i].type != bscvtype)
        {
        is_homogenous = FALSE;
        break;
        }

    if (is_homogenous)
      getcvtype (bscvtype, curve_type);
    else
      *curve_type = EMfreeform_curve;
    }

ret_end:
  if (num_ints_grp)
    om$dealloc (ptr = num_ints_grp);
  if (num_pts_int)
    om$dealloc (ptr = num_pts_int);
  if (dum_tans)
    om$dealloc (ptr = dum_tans);

  /* The curve data may already have been freed, if the "EFfix_the_int" routine
   *  happened to modify the intersections returned by math.
   */
  free_bspmath_data(&msg_loc, totnum_ints, xyzpts, myuvpts, otheruvpts,
                        xyz_cvs, uv1_cvs, uv2_cvs, &sf1, &sf2);
  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMget_int_data");

  /* stop timer for EMget_int_data */
  if (_use_timers)
   stop_timer (T_EMGETINTDATA, FALSE, "");

  return (stat_OM);
}

void getsfclassid (type, classid)
IGRshort type;
OMuword *classid;
{
  extern OMuword OPP_EMSgenbs_class_id;

  if (type == BSRECT_PLANE)
   *classid = OPP_EMSplane_class_id;
  else if (type == BSSPHERE)
   *classid = OPP_EMSsphere_class_id;
  else if (type == BSPART_SPHERE)
   {
   if (WANT_POST220_BEHAVIOR)
     *classid = OPP_EMSpsphere_class_id;
   else
     *classid = OPP_EMSgenbs_class_id;
   }
  else if (type == BSFULL_CYL)
   *classid = OPP_EMScylindr_class_id;
  else if (type == BSFULL_CONE)
   *classid = OPP_EMScone_class_id;
  else if (type == BSPART_CYL)
   *classid = OPP_EMSpcylindr_class_id;
  else if (type == BSPART_CONE)
   *classid = OPP_EMSpcone_class_id;
  else if (type == BSTORUS)
   *classid = OPP_EMStorus_class_id;
  else if (type == BSPART_TORUS)
   {
   if (WANT_POST220_BEHAVIOR)
     *classid = OPP_EMSptorus_class_id;
   else
     *classid = OPP_EMSgenbs_class_id;
   }
  else if (type == BSSF_OF_PROJ)
   *classid = OPP_EMSproject_class_id;
  else if (type == BSSF_OF_REV)
   *classid = OPP_EMSrevol_class_id;
  else 
   *classid = OPP_EMSgenbs_class_id;
  return;
}

void getsftype (sfid, sfos, type)
GRobjid sfid;
GRspacenum sfos;
IGRshort *type;
{
  IGRboolean is_rect_plane;
  IGRlong msg_loc;
  GRclassid myclass;

  om$get_classid (objid = sfid, osnum = sfos, p_classid = &myclass);

  if ((myclass == OPP_EMSplane_class_id) ||
      (myclass == OPP_EMAplane_class_id))
    {
      is_rect_plane = TRUE;
      om$send (msg = message EMSplane.EMis_rect_plane 
                                     (&msg_loc, &is_rect_plane),
       targetid = sfid, targetos = sfos, senderid = NULL_OBJID);
      if (is_rect_plane)
        *type = BSRECT_PLANE;
      else
        *type = BSGEN_BSP_SF;
    }
  else if ((myclass == OPP_EMScylindr_class_id) ||
           (myclass == OPP_EMAcylindr_class_id))
    *type = BSFULL_CYL;
  else if ((myclass == OPP_EMSpcylindr_class_id) ||
           (myclass == OPP_EMApcylindr_class_id))
    *type = BSPART_CYL;
  else if ((myclass == OPP_EMScone_class_id) ||
           (myclass == OPP_EMAcone_class_id))
    *type = BSFULL_CONE;
  else if ((myclass == OPP_EMSpcone_class_id) ||
           (myclass == OPP_EMApcone_class_id))
    *type = BSPART_CONE;
  else if ((myclass == OPP_EMStorus_class_id) ||
           (myclass == OPP_EMAtorus_class_id))
    *type = BSTORUS;
  else if ((myclass == OPP_EMSptorus_class_id) ||
           (myclass == OPP_EMAptorus_class_id))
    *type = BSPART_TORUS;
  else if ((myclass == OPP_EMSsphere_class_id) ||
           (myclass == OPP_EMAsphere_class_id))
    *type = BSSPHERE;
  else if ((myclass == OPP_EMSpsphere_class_id) ||
           (myclass == OPP_EMApsphere_class_id))
    *type = BSPART_SPHERE;
  else if ((myclass == OPP_EMSrevol_class_id) ||
           (myclass == OPP_EMArevol_class_id))
    *type = BSSF_OF_REV;
  else if ((myclass == OPP_EMSproject_class_id) ||
           (myclass == OPP_EMAproject_class_id))
    *type = BSSF_OF_PROJ;
  else
    *type = BSGEN_BSP_SF;

  return;
}

static void getcvtype (bstype, emstype)
IGRshort bstype;
IGRchar *emstype;
{
  if (bstype == BSPOINT)
    *emstype = EMpoint;
  else if (bstype == BSLINE)
    *emstype = EMlinesegment;
  else if (bstype == BSCIRCLE)
    *emstype = EMcircle;
  else if (bstype == BSELLIPSE)
    *emstype = EMellipse;
  else if (bstype == BSCIRC_ARC)
    *emstype = EMcircular_arc;
  else if (bstype == BSELLIP_ARC)
    *emstype = EMelliptical_arc;
  else if (bstype == BSINF_LINE)
    *emstype = EMinfinite_line;
  else
    *emstype = EMfreeform_curve;
  return;
}

end implementation EMSsubbs;
