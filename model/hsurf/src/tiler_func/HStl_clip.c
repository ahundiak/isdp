
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#include <stdlib.h>
#include <math.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsmath.h"

#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"


/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HStl_clip.c */
static void interpolate __((	struct HSvertex *v1, 
				struct HSvertex *v2, 
				struct HSvertex *interp, 
				      IGRdouble t));
				      
static struct HSvertex *clip_low __((	struct HSvertex *this_vertex, 
						 IGRint clip_coord, 
					      IGRdouble clip_plane));
					      
static struct HSvertex *clip_high __((	struct HSvertex *this_vertex, 
						 IGRint clip_coord, 
					      IGRdouble clip_plane));
					      
static struct HSvertex *clip_pyr_low __((	struct HSvertex *this_vertex, 
							 IGRint clip_coord));
							 
static struct HSvertex *clip_pyr_high __((	struct HSvertex *this_vertex, 
							 IGRint clip_coord));
							 


#if defined(__cplusplus)
}
#endif


#undef __



/**********************
 * EXTERNAL VARIABLES *
 **********************/

struct HSvertex		*alloc_vertex();
void			dispose_vertex();


/*******************
 * LOCAL VARIABLES *
 *******************/

static IGRint		interp_normals,
			coords_to_interp;


/*-- interpolate ------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void interpolate( struct HSvertex *v1, 
				 struct HSvertex *v2, 
				 struct HSvertex *interp, 
				       IGRdouble t )
#else
	static void interpolate( v1, v2, interp, t )

	struct
	   HSvertex	*v1, *v2, *interp;
	IGRdouble	t;
#endif


/*
 * Linearly interpolates between v1 and v2 according to the parameter t,
 * where the parametric equation of the line is v1 + t(v2 - v1).  Results
 * are placed in "interp"; "coords_to_interp" tells whether to find
 * W (homogenous coordinate) or not; "interp_normals" tells if normals
 * should be interpolated too.
 *
 * HISTORY: 01/14/87 Created.				S. A. Rapa
 */

 {
   IGRdouble	vect_length;
   IGRint	i;

   for (i = 0; i < coords_to_interp; i++)
      interp->coord[i] = v1->coord[i] + (t * (v2->coord[i] - v1->coord[i]));

   if (element_parms.facet_type == FEM_TILE)
    { /* interpolate the FEM parameters */
      interp->percent = v1->percent + (t * (v2->percent - v1->percent));
      interp->norm[0] = v1->norm[0] + (t * (v2->norm[0] - v1->norm[0]));
      interp->norm[1] = v1->norm[1] + (t * (v2->norm[1] - v1->norm[1]));
    }

   interp->u = v1->u + (t * (v2->u - v1->u));
   interp->v = v1->v + (t * (v2->v - v1->v));

   if (interp_normals)
    {
      interp->norm[0] = v1->norm[0] + (t * (v2->norm[0] - v1->norm[0]));
      interp->norm[1] = v1->norm[1] + (t * (v2->norm[1] - v1->norm[1]));
      interp->norm[2] = v1->norm[2] + (t * (v2->norm[2] - v1->norm[2]));

      if (element_parms.facet_type != FEM_MESH)
/*      for FEM_MESH we are sticking in r,g,b values into the normals so*/
/*      do not normalize them and skew them*/

      /*
       * Normalize vector length
       */

      {
         vect_length =  SQRT ((interp->norm[0] * interp->norm[0]) +
			   (interp->norm[1] * interp->norm[1]) +
			   (interp->norm[2] * interp->norm[2])  );
         if (vect_length > 0.0)
         {
            interp->norm[0] /= vect_length;
            interp->norm[1] /= vect_length;
            interp->norm[2] /= vect_length;
         }
         else
         {
            interp->norm[0] = 0.0;
            interp->norm[1] = 0.0;
            interp->norm[2] = 0.0;
         }
      }

   }
 }


/************************
 * 3-D SURFACE CLIPPING *
 ************************/


/*-- clip_low ---------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSvertex *clip_low( struct HSvertex *this_vertex, 
						   IGRint clip_coord, 
						IGRdouble clip_plane )
#else
	static struct HSvertex *clip_low( this_vertex, clip_coord, clip_plane )

	struct
	   HSvertex	*this_vertex;
	IGRint		clip_coord;
	IGRdouble	clip_plane;
#endif

/*
 * Clips a facet loop so that only the portion x|y|z >= clip_plane
 * is visible (the particular coordinate is defined by "clip_coord").
 * The resulting facet is returned.
 *
 * HISTORY: 01/14/87 Created.				S. A. Rapa
 */

 {
   struct
      HSvertex	*stop_vertex,
		*last_vertex,
		*first_interp_pt;
   IGRboolean	start_found;

   /*
    * Trivial acceptance test
    */

   stop_vertex = this_vertex;
   start_found = TRUE;
   do
    {
      if (this_vertex->coord[clip_coord] < clip_plane)
       {
	 start_found = FALSE;
	 break;
       }
      else
	 this_vertex = this_vertex->next;
    }
   while (this_vertex != stop_vertex);

   if (start_found)
      return (this_vertex);

   /*
    * Look for a visible vertex (or trivially reject)
    */

   stop_vertex = this_vertex;
   do
    {
      if (this_vertex->coord[clip_coord] > clip_plane)
       {
	 start_found = TRUE;
	 break;
       }
      else
	 this_vertex = this_vertex->next;
    }
   while (this_vertex != stop_vertex);

   if (start_found == FALSE)
    {
      dispose_vertex_list (this_vertex);
      return (NIL_VERTEX);
    }

   /*
    * Polygon is partly visible ... clip against the plane
    */

   last_vertex = this_vertex;
   this_vertex = this_vertex->next;
   stop_vertex = last_vertex;
 
   do
    {
      if ((this_vertex->coord[clip_coord] <  clip_plane) &&
          (last_vertex->coord[clip_coord] >= clip_plane)   )
       {
	 if (last_vertex->coord[clip_coord] == clip_plane)
	    first_interp_pt = last_vertex;
	 else
	  {

	    /*
	     * Interpolate point where segment leaves visible region
	     */

	    first_interp_pt = alloc_vertex();
	    interpolate (last_vertex, this_vertex, first_interp_pt,
			 (last_vertex->coord[clip_coord] - clip_plane) /
			 (last_vertex->coord[clip_coord] -
			  this_vertex->coord[clip_coord])		);
	    last_vertex->next     = first_interp_pt;
	  }

	 /*
	  * Throw out invisible points
	  */

	 last_vertex = this_vertex;
	 this_vertex = this_vertex->next;
	 while (this_vertex->coord[clip_coord] < clip_plane)
	  {
	    dispose_vertex (last_vertex);
	    last_vertex = this_vertex;
	    this_vertex = this_vertex->next;
	  }

	 /*
	  * Interpolate point where segment enters visible region
	  */

	 if (this_vertex->coord[clip_coord] == clip_plane)
	  {
	    dispose_vertex (last_vertex);
	    first_interp_pt->next = this_vertex;
	  }
	 else
	  {
	    first_interp_pt->next = last_vertex;
	    interpolate (last_vertex, this_vertex, last_vertex,
			 (last_vertex->coord[clip_coord] - clip_plane) /
			 (last_vertex->coord[clip_coord] -
			  this_vertex->coord[clip_coord])		);
	  }
       }

      last_vertex = this_vertex;
      this_vertex = this_vertex->next;
    }
   while (last_vertex != stop_vertex);

   return (stop_vertex);
 }


/*-- clip_high --------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSvertex *clip_high( struct HSvertex *this_vertex, 
						    IGRint clip_coord, 
						 IGRdouble clip_plane )
#else
	static struct HSvertex	*clip_high (this_vertex, clip_coord, clip_plane)

	struct
	   HSvertex	*this_vertex;
	IGRint		clip_coord;
	IGRdouble	clip_plane;
#endif

/*
 * Clips a facet loop so that only the portion x|y|z <= clip_plane
 * is visible (the particular coordinate is defined by "clip_coord").
 * The resulting facet is returned.
 *
 * HISTORY: 01/14/87 Created.				S. A. Rapa
 */

 {
   struct
      HSvertex	*stop_vertex,
		*last_vertex,
		*first_interp_pt;
   IGRboolean	start_found;

   /*
    * Trivial acceptance test
    */

   stop_vertex = this_vertex;
   start_found = TRUE;
   do
    {
      if (this_vertex->coord[clip_coord] > clip_plane)
       {
	 start_found = FALSE;
	 break;
       }
      else
	 this_vertex = this_vertex->next;
    }
   while (this_vertex != stop_vertex);

   if (start_found)
      return (this_vertex);

   /*
    * Look for a visible vertex (or trivially reject)
    */

   stop_vertex = this_vertex;
   do
    {
      if (this_vertex->coord[clip_coord] < clip_plane)
       {
	 start_found = TRUE;
	 break;
       }
      else
	 this_vertex = this_vertex->next;
    }
   while (this_vertex != stop_vertex);

   if (start_found == FALSE)
    {
      dispose_vertex_list (this_vertex);
      return (NIL_VERTEX);
    }

   /*
    * Polygon is partly visible ... clip against the plane
    */

   last_vertex = this_vertex;
   this_vertex = this_vertex->next;
   stop_vertex = last_vertex;
 
   do
    {
      if ((this_vertex->coord[clip_coord] >  clip_plane) &&
          (last_vertex->coord[clip_coord] <= clip_plane)   )
       {
	 if (last_vertex->coord[clip_coord] == clip_plane)
	    first_interp_pt = last_vertex;
	 else
	  {

	    /*
	     * Interpolate point where segment leaves visible region
	     */

	    first_interp_pt = alloc_vertex();
	    interpolate (last_vertex, this_vertex, first_interp_pt,
			 (last_vertex->coord[clip_coord] - clip_plane) /
			 (last_vertex->coord[clip_coord] -
			  this_vertex->coord[clip_coord])		);
	    last_vertex->next     = first_interp_pt;
	  }

	 /*
	  * Throw out invisible points
	  */

	 last_vertex = this_vertex;
	 this_vertex = this_vertex->next;
	 while (this_vertex->coord[clip_coord] > clip_plane)
	  {
	    dispose_vertex (last_vertex);
	    last_vertex = this_vertex;
	    this_vertex = this_vertex->next;
	  }

	 /*
	  * Interpolate point where segment enters visible region
	  */

	 if (this_vertex->coord[clip_coord] == clip_plane)
	  {
	    dispose_vertex (last_vertex);
	    first_interp_pt->next = this_vertex;
	  }
	 else
	  {
	    first_interp_pt->next = last_vertex;
	    interpolate (last_vertex, this_vertex, last_vertex,
			 (last_vertex->coord[clip_coord] - clip_plane) /
			 (last_vertex->coord[clip_coord] -
			  this_vertex->coord[clip_coord])		);
	  }
       }

      last_vertex = this_vertex;
      this_vertex = this_vertex->next;
    }
   while (last_vertex != stop_vertex);

   return (stop_vertex);
 }


/*-- hs_clip_3d -------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HSvertex *hs_clip_3d( struct HSvertex *facet,
					IGRdouble xlo,
					IGRdouble ylo,
					IGRdouble zlo,
					IGRdouble xhi,
					IGRdouble yhi,
					IGRdouble zhi,
					IGRint do_normals )
#else
	struct HSvertex	*hs_clip_3d (facet, xlo, ylo, zlo, xhi, yhi, zhi, do_normals)

	struct
	   HSvertex	*facet;
	IGRdouble	xlo, ylo, zlo, xhi, yhi, zhi;
	IGRint		do_normals;
#endif

/*
 * Clips a facet loop against the clipping planes specified by 
 * "clip_range" and returns the resulting facet.  "do_normals"
 * indicates if normals are to be interpolated too at the clipping
 * boundaries.
 *
 * HISTORY: 01/14/87 Created.				S. A. Rapa
 */

 {
   interp_normals   = do_normals;
   coords_to_interp = 3;

   facet = clip_low (facet, 0, xlo);
   if (facet)
    {
      facet = clip_low (facet, 1, ylo);
      if (facet)
       {
	 facet = clip_low (facet, 2, zlo);
	 if (facet)
	  {
	    facet = clip_high (facet, 0, xhi);
	    if (facet)
	     {
	       facet = clip_high (facet, 1, yhi);
	       if (facet)
		  facet = clip_high (facet, 2, zhi);
	     }
	  }
       }
    }

   return (facet);
 }


/**************************************
 * 4-D (PERSPECTIVE) SURFACE CLIPPING *
 **************************************/


/*-- clip_pyr_low -----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSvertex *clip_pyr_low( struct HSvertex *this_vertex, 
						       IGRint clip_coord )
#else
	static struct HSvertex *clip_pyr_low( this_vertex, clip_coord )

	struct
	   HSvertex	*this_vertex;
	IGRint		clip_coord;
#endif

/*
 * Clips a facet loop so that only the portion x|y|z <= w is
 * visible (the particular coordinate is defined by "clip_coord").
 * The resulting facet is returned.
 *
 * HISTORY: 01/14/87 Created.				S. A. Rapa
 */

 {
   struct
      HSvertex	*stop_vertex,
		*last_vertex,
		*first_interp_pt;
   IGRboolean	start_found;
   IGRdouble	xyz1, w1, xyz2, w2;

   /*
    * Trivial acceptance test
    */

   stop_vertex = this_vertex;
   start_found = TRUE;
   do
    {
      if (this_vertex->coord[clip_coord] < - this_vertex->coord[3])
       {
	 start_found = FALSE;
	 break;
       }
      else
	 this_vertex = this_vertex->next;
    }
   while (this_vertex != stop_vertex);

   if (start_found)
      return (this_vertex);

   /*
    * Look for a visible vertex (or trivially reject)
    */

   stop_vertex = this_vertex;
   do
    {
      if (this_vertex->coord[clip_coord] > - this_vertex->coord[3])
       {
	 start_found = TRUE;
	 break;
       }
      else
	 this_vertex = this_vertex->next;
    }
   while (this_vertex != stop_vertex);

   if (start_found == FALSE)
    {
      dispose_vertex_list (this_vertex);
      return (NIL_VERTEX);
    }

   /*
    * Polygon is partly visible ... clip against the plane
    */

   last_vertex = this_vertex;
   this_vertex = this_vertex->next;
   stop_vertex = last_vertex;
 
   do
    {
      if ((this_vertex->coord[clip_coord] <  - this_vertex->coord[3]) &&
          (last_vertex->coord[clip_coord] >= - last_vertex->coord[3])   )
       {
	 if (last_vertex->coord[clip_coord] == - last_vertex->coord[3])
	    first_interp_pt = last_vertex;
	 else
	  {

	    /*
	     * Interpolate point where segment leaves visible region
	     */

	    first_interp_pt = alloc_vertex();
	    xyz1 = last_vertex->coord[clip_coord];
	    w1   = last_vertex->coord[3];
	    xyz2 = this_vertex->coord[clip_coord];
	    w2   = this_vertex->coord[3];
	    interpolate (last_vertex, this_vertex, first_interp_pt,
			 (w1 + xyz1) / ((w1 + xyz1) - (w2 + xyz2)) );
	    last_vertex->next     = first_interp_pt;
	  }

	 /*
	  * Throw out invisible points
	  */

	 last_vertex = this_vertex;
	 this_vertex = this_vertex->next;
	 while (this_vertex->coord[clip_coord] < - this_vertex->coord[3])
	  {
	    dispose_vertex (last_vertex);
	    last_vertex = this_vertex;
	    this_vertex = this_vertex->next;
	  }

	 /*
	  * Interpolate point where segment enters visible region
	  */

	 if (this_vertex->coord[clip_coord] == - this_vertex->coord[3])
	  {
	    dispose_vertex (last_vertex);
	    first_interp_pt->next = this_vertex;
	  }
	 else
	  {
	    first_interp_pt->next = last_vertex;
	    xyz1 = last_vertex->coord[clip_coord];
	    w1   = last_vertex->coord[3];
	    xyz2 = this_vertex->coord[clip_coord];
	    w2   = this_vertex->coord[3];
	    interpolate (last_vertex, this_vertex, last_vertex,
			 (w1 + xyz1) / ((w1 + xyz1) - (w2 + xyz2)));
	  }
       }

      last_vertex = this_vertex;
      this_vertex = this_vertex->next;
    }
   while (last_vertex != stop_vertex);

   return (stop_vertex);
 }


/*-- clip_pyr_high ----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static struct HSvertex *clip_pyr_high( struct HSvertex *this_vertex, 
							IGRint clip_coord )
#else
	static struct HSvertex *clip_pyr_high( this_vertex, clip_coord )

	struct
	   HSvertex	*this_vertex;
	IGRint		clip_coord;
#endif

/*
 * Clips a facet loop so that only the portion x|y >= w is
 * visible (the particular coordinate is defined by "clip_coord").
 * The resulting facet is returned.
 *
 * HISTORY: 01/14/87 Created.				S. A. Rapa
 */

 {
   struct
      HSvertex	*stop_vertex,
		*last_vertex,
		*first_interp_pt;
   IGRboolean	start_found;
   IGRdouble	xyz1, w1, xyz2, w2;

   /*
    * Trivial acceptance test
    */

   stop_vertex = this_vertex;
   start_found = TRUE;
   do
    {
      if (this_vertex->coord[clip_coord] > this_vertex->coord[3])
       {
	 start_found = FALSE;
	 break;
       }
      else
	 this_vertex = this_vertex->next;
    }
   while (this_vertex != stop_vertex);

   if (start_found)
      return (this_vertex);

   /*
    * Look for a visible vertex (or trivially reject)
    */

   stop_vertex = this_vertex;
   do
    {
      if (this_vertex->coord[clip_coord] < this_vertex->coord[3])
       {
	 start_found = TRUE;
	 break;
       }
      else
	 this_vertex = this_vertex->next;
    }
   while (this_vertex != stop_vertex);

   if (start_found == FALSE)
    {
      dispose_vertex_list (this_vertex);
      return (NIL_VERTEX);
    }

   /*
    * Polygon is partly visible ... clip against the plane
    */

   last_vertex = this_vertex;
   this_vertex = this_vertex->next;
   stop_vertex = last_vertex;
 
   do
    {
      if ((this_vertex->coord[clip_coord] >  this_vertex->coord[3]) &&
          (last_vertex->coord[clip_coord] <= last_vertex->coord[3])   )
       {
	 if (last_vertex->coord[clip_coord] == last_vertex->coord[3])
	    first_interp_pt = last_vertex;
	 else
	  {

	    /*
	     * Interpolate point where segment leaves visible region
	     */

	    first_interp_pt = alloc_vertex();
	    xyz1 = last_vertex->coord[clip_coord];
	    w1   = last_vertex->coord[3];
	    xyz2 = this_vertex->coord[clip_coord];
	    w2   = this_vertex->coord[3];
	    interpolate (last_vertex, this_vertex, first_interp_pt,
			 (xyz1 - w1) / ((xyz1 - w1) - (xyz2 - w2)) );
	    last_vertex->next     = first_interp_pt;
	  }

	 /*
	  * Throw out invisible points
	  */

	 last_vertex = this_vertex;
	 this_vertex = this_vertex->next;
	 while (this_vertex->coord[clip_coord] > this_vertex->coord[3])
	  {
	    dispose_vertex (last_vertex);
	    last_vertex = this_vertex;
	    this_vertex = this_vertex->next;
	  }

	 /*
	  * Interpolate point where segment enters visible region
	  */

	 if (this_vertex->coord[clip_coord] == this_vertex->coord[3])
	  {
	    dispose_vertex (last_vertex);
	    first_interp_pt->next = this_vertex;
	  }
	 else
	  {
	    first_interp_pt->next = last_vertex;
	    xyz1 = last_vertex->coord[clip_coord];
	    w1   = last_vertex->coord[3];
	    xyz2 = this_vertex->coord[clip_coord];
	    w2   = this_vertex->coord[3];
	    interpolate (last_vertex, this_vertex, last_vertex,
			 (xyz1 - w1) / ((xyz1 - w1) - (xyz2 - w2)));
	  }
       }

      last_vertex = this_vertex;
      this_vertex = this_vertex->next;
    }
   while (last_vertex != stop_vertex);

   return (stop_vertex);
 }


/*-- clip_4d ----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	struct HSvertex	*clip_4d( struct HSvertex *facet,
					   IGRint do_normals,
					IGRdouble zlo )
#else
	struct HSvertex	*clip_4d (facet, do_normals, zlo)

	struct
	   HSvertex	*facet;
	IGRdouble	zlo;
	IGRint		do_normals;
#endif

/*
 * Clips a facet loop against the normalized viewing pyramid
 * (i.e   -w <= x <= w;   -w <= y <= w;   zlo <= z <= w) and
 * returns the resulting facet.  "do_normals" indicates if normals
 * are to be interpolated too at the clipping boundaries.
 *
 * HISTORY: 01/14/87 Created.				S. A. Rapa
 */

 {
   interp_normals   = do_normals;
   coords_to_interp = 4;

   facet = clip_low (facet, 2, zlo);
   if (facet)
    {
      facet = clip_pyr_high (facet, 2);
      if (facet)
       {
	 facet = clip_pyr_low (facet, 0);
	 if (facet)
	  {
	    facet = clip_pyr_low (facet, 1);
	    if (facet)
	     {
	       facet = clip_pyr_high (facet, 0);
	       if (facet)
		  facet = clip_pyr_high (facet, 1);
	     }
	  }
       }
    }

   return (facet);
 }
