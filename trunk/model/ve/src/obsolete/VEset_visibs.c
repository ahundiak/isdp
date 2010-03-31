
#define CHECK_RETURN_CODES 1

#define DEBUG_SET_VISIBS   0

#include "igrtypedef.h"
#include "bs.h"
#include "bserr.h"
#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "stdio.h"
#include "bsparameters.h"


/* External Functions */
void       VEfree_temp_node();
IGRboolean VEin_solid();
IGRboolean BScveval();
void       BSpj_pt_sf1();
void       BSxtractpar();


void VEset_visibilities(edge, curve, element, self_hiding)
  struct VEedge_header    *edge;
  struct IGRbsp_curve     *curve;
  struct VEelement_header *element;
  IGRboolean              self_hiding;
  
  {
  IGRboolean sts;
  BSrc       rc;
  IGRdouble  u_pt_to_proj;
  IGRpoint   obj_pt_to_proj;
  IGRboolean proj_pt_in_solid;
  IGRint     num_deriv;
  IGRdouble  *proj_pts;
  IGRdouble  *u_par_proj, *v_par_proj;
  IGRdouble  *proj_vec;
  IGRlong    num_pts;
  IGRdouble  mod_cht;
  IGRdouble  *ele_range;
  IGRint     i; /* test */
  
  struct IGRbsp_surface *surf;
  struct VEtemp_node    *temp_node, *temp_node_srch,
                        *parm_del, *parm_del_prev;
  struct VEvisib_node   *visib_node;

  IGRboolean            use_double_projection;
  struct VEedge_header  *this_edge;
  struct VEedge_header  *edge_to_find;
    
  surf = element->geom.surf;

#if DEBUG_SET_VISIBS
   fprintf( stderr, "\nBefore VEset_visibilities:\n\n" );
   VEedge_debug( edge );
#endif   

  /* If we are (self-hiding a parting line or a stroked boundary)  */
  /* or we are projecting from a shared stroked boundary into the  */
  /* surface that owns the other shared edge, we must use the      */
  /* double projection scheme that is implemented in               */
  /* VEpart_line_visib.  This scheme helps to solve the tolerance  */
  /* problems encountered when projecting into a surface from a    */
  /* curve that was stroked from the surface.                      */
  if ( self_hiding )
     {
     if ( (edge->type == PARTING) ||
          ( (edge->type == BOUNDARY) && (curve->order == 2) ) )
        use_double_projection = TRUE;
     else
        use_double_projection = FALSE;
     }
  else if ( (edge->type == BOUNDARY) && (curve->order == 2) )
     {
     /* see if we are projecting from a shared edge into the */
     /* the surface that owns the other shared edge          */
     use_double_projection = FALSE;
     edge_to_find = edge->shared_edge;
     if (edge_to_find != NULL)
        {
        this_edge = element->edges;
        while (this_edge != NULL)
           {
           if (this_edge == edge_to_find)
              {
              use_double_projection = TRUE;
              break;
              }
           this_edge = this_edge->next;
	   }
        }  
     }
  else
     use_double_projection = FALSE;
     
  temp_node = edge->temp_list;
  visib_node = edge->visib_list;
  while (temp_node->next != NULL)
    {
    temp_node_srch = temp_node->next;

    while (visib_node->next->u < temp_node->u)
      visib_node = visib_node->next;

    if (! (temp_node->next_visib == OVERLAPPED))
      {
      /* If a region on the temp-list is contained within a HIDDEN or 
       * OVERLAPPED region on the visib-list, then I do not need to do a
       * projection.
       */
      if ((visib_node->visib == OVERLAPPED || visib_node->visib == HIDDEN)
       && temp_node_srch->u < visib_node->next->u)
        proj_pt_in_solid = FALSE;

      else if (temp_node->next_visib == VISIBLE
            || temp_node_srch->prev_visib == VISIBLE)
        proj_pt_in_solid = FALSE;

      else
        {
        u_pt_to_proj = (temp_node->u + temp_node_srch->u) * 0.5;

        num_deriv = 0;
        sts = BScveval(curve,
                       u_pt_to_proj,
                       num_deriv,
                       obj_pt_to_proj,
                       &rc);
        BS_ERRCHK(rc, "VEset_visibilities: BScveval failed\n");
        BS_STSCHK(sts, "VEset_visibilities: BScveval, bad status\n");
      
        BSxtractpar(&rc, BSTOLCHRDHT, &mod_cht);      

        /*
         * If obj_pt_to_proj is outside the hiding element's xy-range or if
         * it is closer in z, then I can assume the region it belongs to is
         * not hidden by the current hiding element. It is unnecessary to do
         * this test during self-hiding, of course, since every edge is within
         * its own element's range. 
         */
        ele_range = element->range;
        if ((!self_hiding)
         && ((obj_pt_to_proj[2] <= ele_range[2] - mod_cht)
          || (obj_pt_to_proj[0] <= ele_range[0] - mod_cht)
          || (obj_pt_to_proj[0] >= ele_range[3] + mod_cht)
          || (obj_pt_to_proj[1] <= ele_range[1] - mod_cht)
          || (obj_pt_to_proj[1] >= ele_range[4] + mod_cht)))
          proj_pt_in_solid = FALSE;

        else if ( use_double_projection )
          {
          proj_pt_in_solid = VEpart_line_visib(element, obj_pt_to_proj, curve, u_pt_to_proj);
          }

        else
          {
          proj_pts = NULL;
          u_par_proj = NULL;
          v_par_proj = NULL;
          VEget_projection_vector(obj_pt_to_proj, &proj_vec);
          BSpj_pt_sf1(surf,
                      obj_pt_to_proj,
                      proj_vec,
                      &num_pts,
                      &proj_pts,
                      &u_par_proj,
                      &v_par_proj,
                      &rc);
          BS_ERRCHK(rc, "VEset_visibilities: BSpj_pt_sf1 failed\n");
  
#if DEBUG_SET_VISIBS
	fprintf( stderr, "vec x,y,z    = %20.15lf, %20.15lf, %20.15lf\n",
		         proj_vec[0], proj_vec[1], proj_vec[2] );
        fprintf(stderr, "from pt u     = %20.18lf\n", u_pt_to_proj);
        fprintf(stderr, "from pt x,y,z = %20.15lf, %20.15lf, %20.15lf\n",
                         obj_pt_to_proj[0], obj_pt_to_proj[1], obj_pt_to_proj[2]);
        fprintf(stderr, "num proj pts  = %d\n", num_pts);
        for (i = 0; i < num_pts; i++)
          {
          fprintf(stderr, "proj pt x,y,z = %lf, %lf, %lf\n",
                           proj_pts[i * 3], proj_pts[i * 3 + 1], proj_pts[i * 3 + 2] );
	  fprintf(stderr, "proj pt u,v   = %lf, %lf\n",
	  	           u_par_proj[i], v_par_proj[i] );
          }
        fprintf(stderr, "cht = %20.15lf\n", mod_cht);
        fprintf(stderr, "2 * mod_cht = %lf\n", 2 * mod_cht);
        fprintf(stderr, "\n");
#endif

          proj_pt_in_solid = FALSE;
          while (num_pts && !proj_pt_in_solid)
            {
            if (obj_pt_to_proj[2] - proj_pts[(num_pts - 1) * 3 + 2] > 2 * mod_cht)
              {
              if (element->flags & HAS_BOUNDARIES)
                {
                proj_pt_in_solid = VEin_solid(element, 
                                              u_par_proj[num_pts - 1],
                                              v_par_proj[num_pts - 1]);
                }
              else
                proj_pt_in_solid = TRUE;
              }
            num_pts--;
            } /* end while (num_pts && !proj_pt_in_solid) */

          if (proj_pts != NULL)
            {
            free((char *) proj_pts);
            free((char *) u_par_proj);
            free((char *) v_par_proj);
            }

          } /* end else of if (use_double_projection) */

        } /* end else of if ((visib_node->visib == OVERLAPPED...) */

      if (proj_pt_in_solid)
        {
        temp_node->next_visib = HIDDEN;
        temp_node_srch->prev_visib = HIDDEN;
        } /* end if (proj_pt_in_solid) */
        
      else
        {
        temp_node->next_visib = VISIBLE;
        temp_node_srch->prev_visib = VISIBLE;
        } /* end else */

      } /* if (! (temp_node->next_visib == OVERLAPPED)) */
      
    temp_node = temp_node_srch;
    } /* end while (temp_node->next != NULL) */
    
  /* Delete X|X-nodes. */
  parm_del_prev = edge->temp_list;
  parm_del = parm_del_prev->next;
  while (parm_del->next != NULL)
    {
    if (parm_del->prev_visib == parm_del->next_visib)
      {
      parm_del_prev->next = parm_del->next;
      VEfree_temp_node(parm_del);
      parm_del = parm_del_prev->next;
      }
    else
      {
      parm_del_prev = parm_del;
      parm_del = parm_del->next;
      }
    } /* end while */
    
#if DEBUG_SET_VISIBS
   fprintf( stderr, "\nAfter VEset_visibilities:\n\n" );
   VEedge_debug( edge );
#endif   

  } /* end VEset_visibilities */
