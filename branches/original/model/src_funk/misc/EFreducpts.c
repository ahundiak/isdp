/* ###################   ANSI COMPILED     ################## */
#include <stdio.h>
#include <math.h>
# include "igrtypedef.h"
# include "EMSmsgdef.h"

#define KEEP 1
#define DELETE 0
#define TRUE 1
#define FALSE 0

/** finds min. dist. of point from segment **/
extern IGRdouble EMmdistptseg();


void EFreduce_pts (numpts, dim, array, tol, indexarray_ptr)
IGRint	numpts;
IGRshort dim, **indexarray_ptr;
IGRdouble (*array)[3], tol;
{
IGRdouble 	pt_to_segment;
IGRboolean	make_segment = TRUE;
IGRint	   	i, seg_start, seg_end, curr_pt;
IGRshort  	*indexarray;

IGRlong    msg; /** returns success value of EMmdistptseg fn. call **/

/** allocate space for index array **/

*indexarray_ptr = (short *) malloc (numpts * sizeof(short));

indexarray= *indexarray_ptr;

/** initially set all values to 1 ==> KEEP all points **/
for (i=0; i<numpts; i++)
	indexarray[i] = KEEP;

/** start with first point on edge **/
seg_start = 0; 

while (seg_start < (numpts-2) )
{
  for (seg_end=seg_start+2; seg_end < numpts; seg_end++)
  {	
	make_segment = TRUE; /** assume segment can be made **/

	/** for ALL points lying within above segment (i.e. between
	    end-points of the above segment) **/

	for (i=seg_start+1; i<seg_end; i++)
	{	
		pt_to_segment = EMmdistptseg (&msg, array[seg_start], array[seg_end], array[i], dim, NULL, NULL, NULL);
		pt_to_segment = sqrt (pt_to_segment);


		if ((msg == EMS_S_Success) && (pt_to_segment > tol))
		{ 	/**segment is NOT possible **/
			make_segment = FALSE;
			break;
	    	}/*if*/
	}/*for, i*/

	if (make_segment == FALSE) 
	{	/** ==> PREVIOUS segment was OK !! So delete all points 
		        between (seg_start) and (seg_end-1). The while loop
			also handles the case when there is just ONE point
			between "seg_start" and "seg_end" (i.e. if 
			"make_segment" turns out to be FALSE for the very
			FIRST segment attempted).  **/
		curr_pt = seg_start + 1;
		while (curr_pt < (seg_end-1) )
			indexarray[curr_pt++] = DELETE;
		/** set the segment start point to the previous end point **/
		seg_start = seg_end-1;
		break;
	}/*if*/

  }/*for, seg_end*/
  
  /** At this point, if "make_segment" is TRUE, (i.e. for the given start point,
      if all points between the start point and the LAST point on the edge 
      are within "tol" chord height with the segment made by the start point 
      and the last point), then, this segment has to be made. **/
	if (make_segment == TRUE)
	{	curr_pt = seg_start + 1;
		while (curr_pt < (numpts-1))
			indexarray[curr_pt++] = DELETE;
		break;
	}/*if*/

}/*while*/

}/*EFreduce_pts*/

/***************************************************/

void EFcompress_array (numpts, dim, array, indexarray)
IGRint	*numpts;
IGRshort dim, *indexarray;
IGRdouble *array;
{

IGRshort	max_pts, unit_size, num_moves;
IGRint		i, size, to, from; 

max_pts 	= *numpts;
unit_size 	= sizeof(double);
num_moves 	= 0; /** number of moves made so far **/

for (i=0; i<max_pts; i++)
{
	if (indexarray[i] == DELETE)
	{
		to 	= dim * (i - num_moves);
		from 	= to + dim;
		size 	= (max_pts - i) * dim * unit_size;
		memcpy (&array[to], &array[from], size);
		num_moves++;
		(*numpts)--;
	}/*if*/

}/*for*/
	
}/*EFcompress_array()*/
