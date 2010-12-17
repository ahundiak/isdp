#include "FImin.h"
#include "FIline.h"
#include "FIrect.h"
#include "FIbezel.h"
#include <math.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

#define ARRAY_CALLOC_SIZE 50


/********************************************************************/
/* _FI_f_is_gadget_found () - look thru _FI_found_gadgets[ ] array  */
/*                and see if gadget label has been found previously */
/********************************************************************/
int _FI_f_is_gadget_found (int  gadget_label,
                           int  _FI_found_gadgets[],
                           int  _FI_found_gadgets_next_index)
{
  int ii;

  for ( ii = 0; ii < _FI_found_gadgets_next_index ; ii++ )
    {
      if ( _FI_found_gadgets[ii] == gadget_label )
	return 1;
    }

  return 0;
} /*** _FI_f_is_gadget_found ( ) ***/



/**********************************************************************/
/* _FI_f_find_by_point_maybe_return () - Called by find_by_point()    */
/*   to determine whether or not to return a point that meets the     */
/*   locate criteria.  Don't return it if it's already been returned. */
/*   If you return the point, store it in the _FI_found_gadgets array.*/
/**********************************************************************/

int _FI_f_find_by_point_maybe_return (int    gadget_label,
                                      int  **_FI_found_gadgets,
                                      int  * _FI_found_gadgets_size,
                                      int  * _FI_found_gadgets_next_index)
{
  if ( ! _FI_f_is_gadget_found ( gadget_label, *_FI_found_gadgets,
				      *_FI_found_gadgets_next_index ) )
    {
	/*** put gadget in _FI_found_gadgets_array ***/

      if ( *_FI_found_gadgets_next_index >= *_FI_found_gadgets_size )
        {
	  /*** Make the _FI_found_gadgets array larger ***/

          *_FI_found_gadgets_size += 10;

          *_FI_found_gadgets = (int *) realloc ( *_FI_found_gadgets,
			 (*_FI_found_gadgets_size ) * sizeof (int) );
        }

		/*** store away gadget ***/
      (*_FI_found_gadgets)[*_FI_found_gadgets_next_index]= gadget_label;
      (*_FI_found_gadgets_next_index)++ ;

      return 1;
    }

  /*** don't return gadget because it's been returned already ***/
  return 0;

} /*** _FI_f_find_by_point_maybe_return ( ) ***/


	/************************************************************/
	/*** FIf_find_by_point will take an (x,y) point, relative ***/
	/*** to the upper left of the form, and return a pointer  ***/
	/*** to the label of the gadget nearest that point.	  ***/
	/*** It returns either FI_SUCCESS or FI_NO_SUCH_GROUP or  ***/
	/*** FI_NO_SUCH_GADGET ( if no gadget is found within a   ***/
	/*** range of "max_dist" pixels from the point )	  ***/
	/************************************************************/
/* Form form_ptr;	** INPUT:  pointer to the form       */
/* int 	 group_label;		** INPUT:  label of group gadget to  */
				/*         restrict search to;       */
				/*         set to FI_FORM_GROUP to   */
				/*         search entire form.	     */
/* int	 xpos;			** INPUT:  x-coordinate of point     */
				/*     relative to form's upper left */
/* int	 ypos;			** INPUT:  y-coordinate of point     */
				/*     relative to form's upper left */
/* int	 max_dist;		** INPUT:  number of pixels away     */
				/*         from point that a gadget  */
				/*         may be and still be found */
				/*         by search                 */
/* int	*label;			** OUTPUT:  pointer to label of      */
				/*          gadget nearest the x,y   */
				/*          point on the form	     */
/* int	 reset_search_flag;	** INPUT: 0 means that you've called */
				/*          this function before,    */
				/*          and it's returned you    */
				/*          the gadget label nearest */
				/*          the point, but you didn't*/
				/*          want that gadget for some*/
				/*          reason; so now you want  */
				/*          the next-nearest gadget  */
				/*          to the point.  This is   */
				/*          useful for having the    */
				/*          user distinguish between */
				/*          gadgets crowded together */
				/*          on a form, by putting    */
				/*          this function in an      */
				/*          accept/reject loop.      */
				/*          If FI_NO_SUCH_GADGET is  */
				/*          returned, then there are */
				/*          no more gadgets within   */
				/*          "max_dist" of the point. */
				/*        1 means always return the  */
				/*          nearest gadget           */

int FIf_find_by_point (Form  form_ptr,
                       int 	 group_label,
                       int	 xpos,
                       int	 ypos,
                       int	 max_dist,
                       int	*label,
                       int	 reset_search_flag)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  struct FIgadget_obj * gadget;
  struct FIgroup_obj  * group;

  static int    *_FI_found_gadgets		= 0;
  static int	_FI_found_gadgets_size		= 0;
  static int	_FI_found_gadgets_next_index	= 0;

  int	ii;

  int	xlo, xhi, ylo, yhi;
  int	wt;
  int     type;

  group = (struct FIgroup_obj *) _FI_g_get_id ( form, group_label );

  if ( ! group )
    {
      return ( FI_NO_SUCH_GROUP );
    }

  if ( _FI_found_gadgets == 0 )
    {
      _FI_found_gadgets_size = 20;
      _FI_found_gadgets = (int *)  calloc ( _FI_found_gadgets_size,
						    sizeof ( int ) );
      _FI_found_gadgets_next_index = 0;
    }

  if ( reset_search_flag > 0 )
    {
      _FI_found_gadgets_next_index = 0;
    }

  for ( ii = 0 ; ii < (int)group->FIgroup.size ; ii++ )
    {
	gadget = group->FIgroup.gadgets[ii];

	if ( ! gadget )
	  continue;

	type = gadget->FIgadget.type;

	xlo = gadget->FIgadget.xlo;
	ylo = gadget->FIgadget.ylo;
	xhi = gadget->FIgadget.xhi;
	yhi = gadget->FIgadget.yhi;

	if ( type == FI_LINE )
	  {
	    wt = 0.5 * ( ((struct FIline_obj *)
				gadget)->FIgraphic.line_weight + 1 );

	    if ( _FI_is_pt_next_to_line_seg ( max_dist, wt,
				    xlo, ylo, xhi, yhi, xpos, ypos ) )
	      {
	        if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
	          {
		    *label = gadget->FIgadget.label;
		    return ( FI_SUCCESS );
		  }
	      }
	  }
	else if ( type == FI_RECT )
	  {
	    wt = 0.5 * ( ((struct FIrect_obj *)
				gadget)->FIgraphic.line_weight + 1 );

			/*** top line segment of rect ***/

	    if ( _FI_is_pt_next_to_line_seg ( max_dist, wt,
				    xlo, ylo, xhi, ylo, xpos, ypos ) )
	      {
		if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
		  {
		    *label = gadget->FIgadget.label;
		    return ( FI_SUCCESS );
		  }
	      }

			/*** right line segment of rect ***/

	    if ( _FI_is_pt_next_to_line_seg ( max_dist, wt,
				    xhi, ylo, xhi, yhi, xpos, ypos ) )
	      {
		if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
		  {
		    *label = gadget->FIgadget.label;
		    return ( FI_SUCCESS );
		  }
	      }

			/*** left line segment of rect ***/

	    if ( _FI_is_pt_next_to_line_seg ( max_dist, wt,
				    xlo, ylo, xlo, yhi, xpos, ypos ) )
	      {
		if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
		  {
		    *label = gadget->FIgadget.label;
		    return ( FI_SUCCESS );
		  }
	      }

			/*** bottom line segment of rect ***/

	    if ( _FI_is_pt_next_to_line_seg ( max_dist, wt,
				    xlo, yhi, xhi, yhi, xpos, ypos ) )
	      {
		if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
		  {
		    *label = gadget->FIgadget.label;
		    return ( FI_SUCCESS );
		  }
	      }
	  }
	else if ( type == FI_BEZEL )
	  {
	    wt = BEZEL_GADGET_BEZEL;

			/*** top line segment of bezel ***/

	    if ( _FI_is_pt_next_to_line_seg ( max_dist, wt,
				    xlo, ylo, xhi, ylo, xpos, ypos ) )
	      {
	        if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
		  {
		    *label = gadget->FIgadget.label;
		    return ( FI_SUCCESS );
		  }
	      }

			/*** right line segment of bezel ***/

	    if ( _FI_is_pt_next_to_line_seg ( max_dist, wt,
				    xhi, ylo, xhi, yhi, xpos, ypos ) )
	      {
	        if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
	          {
	            *label = gadget->FIgadget.label;
	            return ( FI_SUCCESS );
	          }
	      }

			/*** left line segment of bezel ***/

	    if ( _FI_is_pt_next_to_line_seg ( max_dist, wt,
				    xlo, ylo, xlo, yhi, xpos, ypos ) )
	      {
	        if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
	          {
	            *label = gadget->FIgadget.label;
	            return ( FI_SUCCESS );
	          }
	      }

			/*** bottom line segment of bezel ***/

	    if ( _FI_is_pt_next_to_line_seg ( max_dist, wt,
				    xlo, yhi, xhi, yhi, xpos, ypos ) )
	      {
	        if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
	          {
	            *label = gadget->FIgadget.label;
	            return ( FI_SUCCESS );
	          }
	      }
	  }
	else if ( type == FI_GROUP )
	  {
	    int status;

			/*** recursively check group gadgets ***/

	    status = FIf_find_by_point ( (Form) form, gadget->FIgadget.label,
				          xpos, ypos, max_dist, label,
					  reset_search_flag );

			    /*** DON'T call maybe_return() here! ***/
	    if ( ! status ) 
	      {
		return ( FI_SUCCESS );
	      }

	  }
	else	/*** non-line, non-group, non-rect gadgets ***/
	  {	/***   See if gadget contains point  ***/

	    if ( ( xpos >= xlo - max_dist ) &&
		 ( xpos <= xhi + max_dist ) &&
		 ( ypos >= ylo - max_dist ) &&
		 ( ypos <= yhi + max_dist )    )
	      {
		if ( _FI_f_find_by_point_maybe_return 
			            (    gadget->FIgadget.label,
				      & _FI_found_gadgets,
				      & _FI_found_gadgets_size,
				      & _FI_found_gadgets_next_index ) )
		  {
		    *label = gadget->FIgadget.label;
		    return ( FI_SUCCESS );
		  }
	      }
	  }
    }

  return ( FI_NO_SUCH_GADGET );
}



	/************************************************************/
	/* FIf_find_by_area() will return a pointer to an array of  */
	/* gadget labels for all gadgets on a form ( restricted to  */
	/* a particular group, if desired ) which fall within a     */
	/* rectangular fence bounded by (x1,y1) on the upper left   */
	/* and (x2,y2) on the lower right of the form.  It returns  */
	/* FI_SUCCESS or FI_NO_SUCH_GROUP or FI_NO_MEMORY.          */
	/* The number of gadgets falling within these bounds are    */
	/* returned via the num_labels argument.		    */
	/*   NOTE:  This function allocates memory ! It is the	    */
	/* application's responsibility to free the "labels"	    */
	/* pointer after calling this function !!		    */
	/************************************************************/
/* Form form_ptr;	** INPUT: pointer to the form	     */
/* int	  group_label;	** INPUT: label of group to restrict search  */
			/*        to; use FI_FORM_GROUP to search    */
			/*        the entire form.		     */
/* int	  x1, y1;	** INPUT: upper left corner point of fence   */
/* int	  x2, y2;	** INPUT: lower right corner point of fence  */
/* int	 *num_labels;	** OUTPUT:  pointer to number of gadgets     */
			/*          found that are in "labels" array */
/* int	**labels;       ** OUTPUT:  pointer to array of labels of    */
	        /*    	    gadgets which fall within the    */
			/*          indicated area on the form.      */

int FIf_find_by_area (Form   form_ptr,
                      int    group_label,
                      int    x1,
                      int    y1,
                      int    x2,
                      int    y2,
                      int   *num_labels,
                      int  **labels)
{
  struct FIform_obj * form = (struct FIform_obj *) form_ptr;
  int	labels_size = 0;
 

  *num_labels = 0;

  return ( _FI_grp_find_by_area ( form, group_label, x1, y1, x2, y2,
			    & labels_size, num_labels, labels ));

}



static int _FI_add_label_to_array (int     gadget_label,
                                   int    *labels_size,
                                   int    *num_labels,
                                   int   **labels)
{
	/*** if the array is full, calloc/realloc more space ***/
  if ( *num_labels == *labels_size )
    {
      if ( *labels_size )	/* realloc */
	{
	  *labels = (int*) realloc ( *labels,
		( *labels_size + ARRAY_CALLOC_SIZE ) * sizeof(int) );

	  if ( ! *labels )
		return ( FI_NO_MEMORY );

 	   		/* set the just added memory to 0's */
	  /***************************    not necessary ! ************
	  memset ( labels[*labels_size], 0,
				ARRAY_CALLOC_SIZE * sizeof ( int ) );
	  ************************************************************/
	}
      else	/* calloc */
	{
	  *labels = (int *) calloc ( ARRAY_CALLOC_SIZE, sizeof (int) );

	  if ( ! *labels )
		return ( FI_NO_MEMORY );
	}
	   	/* adjust the number of elements in this array */
      *labels_size += ARRAY_CALLOC_SIZE; 
    }

  (*labels)[*num_labels] = gadget_label;
  (*num_labels)++;

  return ( FI_SUCCESS );
}


/*** return a label of a gadget entirely contained in area ***/

int _FI_grp_find_by_area (struct FIform_obj  *form,
                          int                 group_label,
                          int                 x1,
                          int                 y1,
                          int                 x2,
                          int                 y2,
                          int                *labels_size,
                          int                *num_labels,
                          int               **labels)
{
  struct FIgadget_obj * gadget;
  struct FIgroup_obj  * group;
  int		        ii, sts;

  group = (struct FIgroup_obj *) _FI_g_get_id ( form, group_label );

  if ( ! group ) 	
    return ( FI_NO_SUCH_GADGET );	
		 	
  if ( group->FIgadget.type != FI_GROUP )
    return ( FI_NO_SUCH_GROUP );		

  for ( ii = 0 ; ii < (int)group->FIgroup.size ; ii++ )
    {
	gadget = group->FIgroup.gadgets[ii];

	if ( ! gadget )   continue;

	if ( gadget->FIgadget.type == FI_GROUP )
	  {
		/*** recursively check group gadgets ***/
		sts = _FI_grp_find_by_area ( form,
						gadget->FIgadget.label,
						x1, y1, x2, y2,
						labels_size, num_labels,
						labels );
		if ( sts ) return sts;
	  }
	else
	  {
	    if ( ( gadget->FIgadget.xlo >= x1 ) &&
	         ( gadget->FIgadget.xhi <= x2 ) &&
	         ( gadget->FIgadget.ylo >= y1 ) &&
	         ( gadget->FIgadget.yhi <= y2 ) )
	      {
		/*** add gadget label to search array ***/
		sts = _FI_add_label_to_array ( gadget->FIgadget.label,
					labels_size, num_labels,
					labels );
		if ( sts ) return sts;
	      }
	  }
    }
  return ( FI_SUCCESS );
}



int _FI_is_pt_next_to_line_seg (int max_dist,
                                int wt,
                                int x1,
                                int y1,
                                int x2,
                                int y2,
                                int x,
                                int y)
{
  int md;

  md = max_dist + wt;

	/*** see if point lies close enough to infinite line ***/
  if ( md >= _FI_get_dist_pt_line ( x1, y1, x2, y2, x, y ) )
    {
	/*** see if point lies between endpoints ***/
      if ( y2 >= y1 )
        {
	  if ( x2 >= x1 )
	    {
              if ( ( x >= x1 - md )  &&  ( y >= y1 - md ) &&
                   ( x <= x2 + md )  &&  ( y <= y2 + md )    )
	        {
	          return 1;
	        }
	    }
	  else
	    {
              if ( ( x >= x2 - md )  &&  ( y >= y1 - md ) &&
                   ( x <= x1 + md )  &&  ( y <= y2 + md )    )
	        {
	          return 1;
	        }
	    }
        }
      else
        {
	  if ( x2 >= x1 )
	    {
              if ( ( x >= x1 - md )  &&  ( y >= y2 - md ) &&
                   ( x <= x2 + md )  &&  ( y <= y1 + md)    )
	        {
	          return 1;
	        }
	    }
	  else
	    {
              if ( ( x >= x2 - md )  &&  ( y >= y2 - md ) &&
                   ( x <= x1 + md )  &&  ( y <= y1 + md )    )
	        {
	          return 1;
	        }
	    }
        }

	/*** see if point lies near first endpoint ***/
      if ( ( ABS( x - x1 ) <= md )  &&  ( ABS( y - y1 ) <= md ) )
	{
	  return 1;
	}

	/*** see if point lies near second endpoint ***/
      if ( ( ABS( x2 - x ) <= md )  &&  ( ABS( y2 - y ) <= md ) )
	{
	  return 1;
	}
    }

  return 0;
}


/* dmb:10/10/92:Change floats to doubles for ANSI */
void _FI_get_line_ABC (int     x1,
                       int     y1,
                       int     x2,
                       int     y2,
                       double *A,
                       double *B,
                       double *C)
{
  double dont_divide_by_0 = 0.0;

  if ( x1 == x2 )
	dont_divide_by_0 = 0.01;

  *A = ( y2 - y1 ) / ( x2 - x1 + dont_divide_by_0 );

  *B = -1.0;

  *C = - (x1) * (*A) + y1;
}



int _FI_get_dist_pt_line (int x1,
                          int y1,
                          int x2,
                          int y2,
                          int x,
                          int y)
{
  double A,B,C;	/*** parameters in line def Ax + By + C = 0 ***/

  _FI_get_line_ABC ( x1, y1, x2, y2, &A, &B, &C );

  return ( (int) ( ABS ( A*x + B*y + C ) /
			sqrt ( (double) ( A * A + B * B ) )
		 ) 
	 );
}
