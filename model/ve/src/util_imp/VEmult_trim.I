
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/

class implementation Root;


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "godef.h"
#include "go.h"

#include "bs.h"

#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "emsdef.h"

#include "ve_timing.h"
#include "ve.h"
#include "vedef.h"
#include "veerr.h"
#include "vemem.h"

/* prototype files */
%safe
#include "VEpr_utilimp.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static void VEsort_for_visib_mult_trim __((
					IGRint                  num,
					IGRdouble               *uv_par,
					IGRint                  *sort ));

static void VEget_in_solid_status_mult_trim __((
					struct VEelement_header *elem,
					IGRint                  num,
					IGRdouble               *sort_uv_par,
					IGRint                  *sort,
					IGRchar                 *in_solid_flags ));

#if defined(__cplusplus)
}
#endif

#undef __
%endsafe

#define CHECK_RETURN_CODES 1

#define MAX_TRIM_POINTS 120

#if TIMING
extern IGRdouble VEtime_multrim;
extern IGRint    VEcount_multrim;
extern struct tms VEs_time;
extern struct tms VEe_time;
#endif

from EMSloopset import EMlsparttrim;


/*--- VEsort_for_visib_mult_trim --------------------------------------*/

static void VEsort_for_visib_mult_trim( num, uv_par, sort )

	IGRint    num;
	IGRdouble *uv_par;
	IGRint    *sort;

/* 
NAME
	VEsort_for_visib_mult_trim (static)

DESCRIPTION
	This function sorts the UV points that are going to be
	used to form a polyline for multiple trimming.  The points
	are sorted into ascending order.  The UV points are not
	moved in their array, rather an array of indices indicating
	the sorted order is filled in.

PARAMETERS
	num (IN) - the number of parameters to sort
	uv_par (IN) - array of UV parameters to sort
	sort (OUT) - the sort index array for the parameters

GLOBALS USED
	none

HISTORY
	03/04/91    Shridar Subramanian
	   Creation Date             
*/

	{
	IGRboolean done = FALSE;
	IGRint ii, j, temp;

	ii = 0;
	while( (ii < num) && !done )
	   {
	   done = TRUE;
	   for ( j= num-1; j > ii; j-- )
	      {
	      if ( (uv_par[ 2* sort[j]] < uv_par[ 2 * sort[j-1]]) ||
	           ( (uv_par[2*sort[j]] == uv_par[2*sort[j-1]]) &&
	             (uv_par[(2 * sort[j]) +1] < uv_par[(2 * sort[j-1]) +1]) ) )
	         {
	         temp = sort[j-1];
	         sort[j-1] = sort[j];
	         sort[j] = temp;
	         done = FALSE;
	         }
	      }
	   ii++;
	   }

	}   /* VEsort_visib_for_mult_trim */


/*--- VEget_in_solid_status_mult_trim ------------------------------------------------*/

static void VEget_in_solid_status_mult_trim( elem, num, sort_uv_par, sort, in_solid_flags )

	struct VEelement_header *elem;
	IGRint                  num;
	IGRdouble               *sort_uv_par;
	IGRint                  *sort;
	IGRchar                 *in_solid_flags;

/*
NAME
	VEget_in_solid_status_mult_trim (static)

DESCRIPTION
	This function determines whether each point in the polyline passed
	in is in a solid or hole region of the surface.  It makes this
	determinination by trimming the polyline against the loopset of
	the surface and using the trimming information to determine the
	solid/hole status of the vertices.

PARAMETERS
	elem (IN) - the element whose UV status is being determined
	num (IN) - the number of UV parameters
	sort_uv_par (IN) - array of sorted UV parameters
	sort (IN) - sorting index array
	in_solid_flags (OUT) - the status of each UV parameter

GLOBALS USED
	none

HISTORY
	03/04/91    Shridar Subramanian
	   Creation Date 
*/

	{
	IGRchar               my_in_solid_flags[MAX_TRIM_POINTS];
	IGRint                span_a, span_b, span_c, ii;
	IGRdouble             param_a, param_b, param_c;
	IGRshort              trim_options;
	IGRlong               msg;
	IGRint                num_bdry;
	struct EMSpypoint     *this_edge, *bdry;
	struct EMSdataselect  uv_data;
	struct EMSsfintedpar  *int_info;
	struct EMSpartolbasis partol;
	struct IGRpolyline    polyline;


	if ( num == 1 )
	   {
	   /* use point classification instead of trimming for just one point */
	   in_solid_flags[sort[0]] = VEin_solid( elem, *sort_uv_par, *(sort_uv_par+1) );
	   }
	else
	   {
	   partol.tol = 1e-6;
	   partol.is_valid = TRUE;

	   polyline.num_points = num;
	   polyline.points = sort_uv_par;

	   uv_data.datatype = EMSdata_poly2d;
	   uv_data.data.poly = &polyline;

	   bdry = NULL;
	   int_info = NULL;
	   trim_options = EMS_INTER_BDRYISAREA;

#if TIMING
	   times( &VEs_time );
#endif

	   om$send( msg = message EMSloopset.EMlsparttrim( &msg, &uv_data, &partol,
	                                                   trim_options, &num_bdry,
	                                                   &bdry, &int_info ),
	            senderid = NULL_OBJID,
	            targetid = elem->loopset_id,
	            targetos = elem->env->osnum );

#if TIMING
	   times( &VEe_time );

	   VEcount_multrim++;
	   VEtime_multrim += ( ( (VEe_time.tms_utime + VEe_time.tms_stime) - 
	                         (VEs_time.tms_utime + VEs_time.tms_stime) ) / 60.0 );
#endif


	   this_edge = bdry;
	   memset( my_in_solid_flags, FALSE, MAX_TRIM_POINTS * sizeof( IGRchar ) );

	   if ( this_edge )
	      {
	      for( ii = 0; ii <= this_edge->span_inx; ii++ )
	         my_in_solid_flags[ii] = FALSE;
	      if ( this_edge->param == 0.0 )
	         my_in_solid_flags[this_edge->span_inx] = TRUE;
	      }

	   while ( this_edge )
	      {
	      span_a = this_edge->span_inx;
	      param_a = this_edge->param;
	      this_edge = this_edge->next;
	      if ( this_edge )
	         {
	         span_b = this_edge->span_inx;
	         param_b = this_edge->param;
	         this_edge = this_edge->next;
	         if ( this_edge )
	            {
	            span_c = this_edge->span_inx;
	            param_c = this_edge->param;
	            }
	         else
	            {
	            span_c = param_c = -1;
	            }
	         }
	      else
	         {
	         span_b = span_c = param_b = param_c = -1;
	         }
      
	      for ( ii = span_a+1; ii <= span_b; ii++ )
	         my_in_solid_flags[ii] = TRUE;
	      for ( ii = span_b+1; ii <= span_c; ii++ )
	         my_in_solid_flags[ii] = FALSE;
	      if ( param_a == 0.0 )
	         my_in_solid_flags[span_a] = TRUE;
	      if ( param_b == 1.0 )
	         my_in_solid_flags[span_b+1] = TRUE;
	      if ( param_c == 0.0 )
	         my_in_solid_flags[span_c] = TRUE;

	      }   /* end: while ( this_edge ) */

	   for ( ii = 0; ii < num; ii++ )
	      {
	      in_solid_flags[sort[ii]] = my_in_solid_flags[ii];
	      }

	   EMpypoint_free( bdry, NULL );
	   EMsfintedpar_free( int_info, NULL );
	   }

	}  /* VEget_in_solid_status_mult_trim */


/*--- VEdetermine_visib_via_mult_trim --------------------------------------------*/

void VEdetermine_visib_via_mult_trim( elem, num_arr, total, uv_par, in_solid_flags )

	struct VEelement_header *elem;
	IGRint                  *num_arr;
	IGRint                  total;
	IGRdouble               *uv_par;
	IGRchar                 *in_solid_flags;

/*
NAME
	VEdetermine_visib_via_mult_trim

DESCRIPTION
	This function determines the visibility of a set of points, uv_par,
	with respect to an element, elem.  In order to acheive this it sorts
	the points in ascending order (ascending u ) , and calls EMlsparttrim
	with the sorted array of points.  No two points in the sorted array,
	passed to EMlsparttrim, are within 1e-6 units of each other (tolerance
	limit).

PARAMETERS
	elem (IN) - the element whose UV status is being determined
	num_arr (IN) - the array of UV parameters for each point
	total (IN) - the number of points that were projected from
	uv_par (IN) - array of UV parameters
	in_solid_flags (OUT) - the status of each UV parameter

GLOBALS USED
	none

HISTORY
	03/04/91    Shridar Subramanian
	   Creation Date 
*/

	{
	IGRboolean from_removed = FALSE;
	IGRint ii, jj, num, new_num;
	IGRint rem_count, rem_index, removed[2*MAX_TRIM_POINTS];
	IGRint new_sort[MAX_TRIM_POINTS], x, y;
	IGRint sort[MAX_TRIM_POINTS];
	IGRint num1, processed;
	IGRdouble tol;
	IGRdouble sort_uv_par[2*MAX_TRIM_POINTS];
 

	tol = 1e-6;
	num1 = 0;
	rem_index = 0;
	rem_count = 0;
	for( ii = 0; ii < total; ii++ )
	   num1 = num1 + num_arr[ii];

	processed = 0;
	while ( num1 )
	   {
	   if ( rem_count >= MAX_TRIM_POINTS )
	      {
	      num = MAX_TRIM_POINTS;
	      from_removed = TRUE;
	      rem_count -= MAX_TRIM_POINTS;
	      for ( ii = 0; ii < num; ii++ )
	         sort[ii] = removed[ii];
	      for ( ii = 0; ii < rem_count; ii++ )
	         removed[ii] = removed[ii+num];
	      }
	   else
	      {
	      if ( num1 > MAX_TRIM_POINTS )
	         num = MAX_TRIM_POINTS;
	      else 
	         num = num1;

	      for ( ii = 0; ii < num; ii++ )
	         sort[ii] = ii + processed;
	      }

	   VEsort_for_visib_mult_trim( num, uv_par, sort ); 

	   rem_index = 0;
	   while ( rem_index < num )
	      {
	      if ( sort[rem_index] != -1 )
	         {
	         for ( ii = rem_index + 1; ii < num; ii++ )
	            {
	            if ( sort[ii] != -1 )
	               {
	               x = 2*sort[ii];
	               y = 2*sort[rem_index];
	               if ( ( fabs( uv_par[x]-uv_par[y] ) < tol ) &&
	                    ( fabs( uv_par[x+1]-uv_par[y+1] ) < tol) )
	                  {	
	                  removed[rem_count] = sort[ii];
	                  sort[ii] = -1;
	                  rem_count++;
	                  } 
	               }
	            }
	         }
	      rem_index++;
	      }
    
	   new_num = 0;
	   jj = 0; 
	   for ( ii = 0; ii < num; ii++ )
	      {
	      if ( sort[ii] != -1 )
	         {
	         sort_uv_par[ 2*jj] = uv_par[2 * sort[ii]];
	         sort_uv_par[(2*jj)+1] = uv_par[(2*sort[ii])+1];
	         new_sort[jj] = sort[ii];
	         jj++;
	         new_num++;
	         }
	      }

	   VEget_in_solid_status_mult_trim( elem, new_num, sort_uv_par, new_sort, in_solid_flags );
	
	   if ( !from_removed )
	      {
	      processed += num;
	      num1 -= num;
	      }
	   else
	      from_removed = FALSE;

	   }  /* end: while ( num1 ) */

	while ( rem_count )
	   {
	   if ( rem_count >= MAX_TRIM_POINTS )
	      num = MAX_TRIM_POINTS;
	   else
	      num = rem_count;
    
	   for ( ii = 0; ii < num; ii++ )
	      sort[ii] = removed[ii];
    
	   rem_count -= num;
	   for ( ii = 0; ii < rem_count; ii++ )
	      removed[ii] = removed[ii+num];

	   rem_index = 0;
	   while ( rem_index < num )
	      {
	      if ( sort[rem_index] != -1 )
	         {
	         for ( ii = rem_index+1; ii < num; ii++ )
	            {
	            if ( sort[ii] != -1 )
	               {
	               x = 2*sort[ii];
	               y = 2*sort[rem_index];
	               if ( (fabs( uv_par[x]-uv_par[y] ) < tol) &&
	                    (fabs( uv_par[x+1]-uv_par[y+1] ) < tol) )
	                  {	
	                  removed[rem_count] = sort[ii];
	                  sort[ii] = -1;
	                  rem_count++;
 	                  } 
	               }
	            }
	         }
	      rem_index++;
	      }  /* end: while ( rem_index < num ) */
    
	   new_num = 0;
	   jj = 0; 
	   for ( ii = 0; ii < num; ii++ )
	      {
	      if ( sort[ii] != -1 )
	         {
	         sort_uv_par[2*jj] = uv_par[2 * sort[ii]];
	         sort_uv_par[(2*jj)+1] = uv_par[(2*sort[ii])+1];
	         new_sort[jj] = sort[ii];
	         jj++;
	         new_num++;
	         }
	      }

	   VEget_in_solid_status_mult_trim( elem, new_num, sort_uv_par, new_sort, in_solid_flags );

	   }  /* end: while ( rem_count ) */

	}  /* VEdetermine_visib_via_mult_trim */

end implementation Root;
