
#define CHECK_RETURN_CODES 1

#define DEBUG_PL_VISIB 0

#include "igrtypedef.h"
#include "bs.h"
#include "bserr.h"
#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "stdio.h"
#include "bsparameters.h"


/* External Functions */
void       VEget_projection_vector();
IGRboolean VEin_solid();
void       BSpj_pt_sf1();
void       BSxtractpar();


IGRboolean VEpart_line_visib(element, pt_to_proj, curve, u_pt_to_proj)
  struct VEelement_header *element;
  IGRpoint                pt_to_proj;
  struct IGRbsp_curve     *curve;
  IGRdouble               u_pt_to_proj;
  
  {
  BSrc       rc;
  IGRpoint   tst_pt_to_proj;
  IGRdouble  mod_cht, mod_cht_2;
  IGRint     i, knot_index, pole_index;
  IGRdouble  *proj_pts, *u_par_proj, *v_par_proj;
  IGRdouble  *proj_vec;
  IGRlong    num_pts;
  IGRboolean proj_pt_in_solid;
  IGRdouble  *pole_array, *knot_array;
  IGRvector  perp_vec;
  
  struct IGRbsp_surface *surface;
  
  surface = element->geom.surf;
  
  /* Find the poles between which pt_to_proj lies. */
  knot_array = curve->knots;
  pole_array = curve->poles;
  knot_index = 2;
  while (knot_array[knot_index] <= u_pt_to_proj)
    knot_index++;
  pole_index = (knot_index - 2) * 3;

#if DEBUG_PL_VISIB
  fprintf(stderr, "knot_index = %d\n", knot_index);

  fprintf(stderr, "Pole 1: %20.10lf %20.10lf\n",
          pole_array[pole_index], pole_array[pole_index + 1]);
  fprintf(stderr, "Pole 2: %20.10lf %20.10lf\n",
          pole_array[pole_index + 3], pole_array[pole_index + 4]);
#endif

  /* Find the vector that is perpendicular to the parting line chord that pt_to_proj is on   */
  /* and normalize it. Since a vector parallel to the chord is <(x2 - x1), (y2 - y1)>, where */
  /* (x1, y1) and (x2, y2) are the endpoints of the chord, then a vector perpendicular to    */
  /* the chord is <(y2 - y1), (x1 - x2)>. I will later use this vector to determine how to   */
  /* offset the points from which to do the point projections.                               */
  perp_vec[0] = pole_array[pole_index + 4] - pole_array[pole_index + 1];
  perp_vec[1] = pole_array[pole_index] - pole_array[pole_index + 3];
  perp_vec[2] = 0.0;

#if DEBUG_PL_VISIB
  fprintf(stderr, "Before normalization:\n");
  fprintf(stderr, "perp_vec[0] = %20.10lf\n", perp_vec[0]);
  fprintf(stderr, "perp_vec[1] = %20.10lf\n", perp_vec[1]);
#endif

  BSnorvec(&rc, perp_vec);

#if DEBUG_PL_VISIB
  fprintf(stderr, "After normalization:\n");
  fprintf(stderr, "perp_vec[0] = %20.10lf\n", perp_vec[0]);
  fprintf(stderr, "perp_vec[1] = %20.10lf\n\n", perp_vec[1]);
#endif

  BSxtractpar(&rc, BSTOLCHRDHT, &mod_cht);
  mod_cht_2 = mod_cht * 1.01;
                    
  tst_pt_to_proj[0] = pt_to_proj[0] + (mod_cht_2 * perp_vec[0]);
  tst_pt_to_proj[1] = pt_to_proj[1] + (mod_cht_2 * perp_vec[1]);
  tst_pt_to_proj[2] = pt_to_proj[2];
                     
  proj_pts = NULL;
  u_par_proj = NULL;
  v_par_proj = NULL;
  VEget_projection_vector(tst_pt_to_proj,
                          &proj_vec);
  BSpj_pt_sf1(surface,
              tst_pt_to_proj,
              proj_vec,
              &num_pts,
              &proj_pts,
              &u_par_proj,
              &v_par_proj,
              &rc);
                    
     BS_ERRCHK( rc, "VEpl_visib:  BSpj_pt_sf1 failed" );

#if DEBUG_PL_VISIB
  fprintf(stderr, "mod_cht_2 = %lf\n", mod_cht_2);
  fprintf(stderr, "Parting line visib (first projection):\n" );
  fprintf(stderr, "test pt x,y,z = %lf, %lf, %lf\n",
                   tst_pt_to_proj[0], tst_pt_to_proj[1], tst_pt_to_proj[2]);
  fprintf(stderr, "num proj pts  = %d\n", num_pts );
  for (i = 0; i < num_pts; i++)
    fprintf(stderr, "proj pts x,y,z = %lf, %lf, %lf\n",
                     proj_pts[i * 3], proj_pts[i * 3 + 1], proj_pts[i * 3 + 2]);
#endif

  if (num_pts == 0)
    {
    return(FALSE);
    }
    
  else
    {
    proj_pt_in_solid = FALSE;
    while (num_pts && !proj_pt_in_solid)
      {
      if (tst_pt_to_proj[2] - proj_pts[(num_pts - 1) * 3 + 2] > mod_cht)
        {
        if (element->flags & HAS_BOUNDARIES)
          proj_pt_in_solid = VEin_solid(element,
                                        u_par_proj[num_pts - 1],
                                        v_par_proj[num_pts - 1]);
        else
          proj_pt_in_solid = TRUE;
        } /*end if */
      num_pts--;
      } /* end while */
      
    free((char *) proj_pts);
    free((char *) u_par_proj);
    free((char *) v_par_proj);
    
    if (!proj_pt_in_solid)
      return(FALSE);      
       
    else
      {
      tst_pt_to_proj[0] = pt_to_proj[0] - (mod_cht_2 * perp_vec[0]);
      tst_pt_to_proj[1] = pt_to_proj[1] - (mod_cht_2 * perp_vec[1]);
                         
      proj_pts = NULL;
      u_par_proj = NULL;
      v_par_proj = NULL;
      VEget_projection_vector(tst_pt_to_proj, 
                              &proj_vec);
      BSpj_pt_sf1(surface,
                  tst_pt_to_proj,
                  proj_vec,
                  &num_pts,
                  &proj_pts,
                  &u_par_proj,
                  &v_par_proj,
                  &rc);
                      
     BS_ERRCHK( rc, "VEpl_visib:  BSpj_pt_sf1 failed" );

#if DEBUG_PL_VISIB
  fprintf(stderr, "Parting line visib (second projection):\n" );
  fprintf(stderr, "test pt x,y,z = %lf, %lf, %lf\n",
                   tst_pt_to_proj[0], tst_pt_to_proj[1], tst_pt_to_proj[2]);
  fprintf(stderr, "num proj pts  = %d\n", num_pts );
  for (i = 0; i < num_pts; i++)
    fprintf(stderr, "proj pts x,y,z = %lf, %lf, %lf\n",
                     proj_pts[i * 3], proj_pts[i * 3 + 1], proj_pts[i * 3 + 2]);
#endif

      if (num_pts == 0)
        {
        return(FALSE);
        }
      
      else
        {
        proj_pt_in_solid = FALSE;
        while (num_pts && !proj_pt_in_solid)
          {
          if (tst_pt_to_proj[2] - proj_pts[(num_pts - 1) * 3 + 2] > mod_cht)
            {
            if (element->flags & HAS_BOUNDARIES)
              proj_pt_in_solid = VEin_solid(element,
                                            u_par_proj[num_pts - 1],
                                            v_par_proj[num_pts - 1]);
            else
              proj_pt_in_solid = TRUE;
            } /*end if */
          num_pts--;
          } /* end while */

        free((char *) proj_pts);
        free((char *) u_par_proj);
        free((char *) v_par_proj);
        if (!proj_pt_in_solid)
          return(FALSE);
        else
          return(TRUE);
        } /* end else of if (num_pts == 0) */
      
      } /* end else of if (!proj_pt_in_solid) */

    } /* end else of if (num_pts == 0) */
    
  } /* end VEpart_line_visib */
