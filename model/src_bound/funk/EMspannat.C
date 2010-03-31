/* ###################   APOGEE COMPILED   ################## */
/*
Notes
	This function determines whether a line segment lies on any of the
	natural edges of the surface. If it does it also returns the natural
	edge location.
	If the input points are within tolerance of the natural side
	then they are 'snapped' to the nearest side. Thus the point may change
	upon exit from this function.
	
Arguments
	pt1, pt2	input	The end points of the segment.
	full_natural	output	Boolean flag TRUE if the segment completely
				overlaps a natural edge. Else FALSE.
	part_natural	output	Boolean flag TRUE if the segment partially
				overlaps a natural edge. Else FALSE.
	location	output	If either full_natural or part_natural is
				TRUE then this is the location of the natural
				edge. 
	partol		input	Parametric dist. tolerance.
	parsqtol	input	Parametric squared dist tolerance.
	
Return Values
	The function returns TRUE if the input segment is partially/fully
	overlapping a natural edge. Else it returns FALSE.
	
Assumptions
	The numbering of the natural edges is -
	u_low	0
	u_high	2
	v_low	3
	v_high	1
	
Note
	If either/both of the points of the segment is/are outside parametric
	space then it is considred as NO OVERLAP (even if the segment may
	be partially overlapping) and FALSE is returned.

History
	SM	28-Sep-1987	Design and Creation.
        SCW     13-Feb01997     included emsmacros_c.h rather than emsmacros.h
*/

# include "EMS.h"
# include "OMminimum.h"
# include "OMmacros.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include <math.h>
# include "emsmacros_c.h"

IGRboolean  EMis_span_on_natural_edge(pt1, pt2, full_natural, 
				part_natural, location, partol, parsqtol)

 IGRdouble	*pt1, *pt2, partol, parsqtol;
 IGRboolean	*full_natural, *part_natural;
 IGRshort	*location;
{

	
	IGRboolean	natural, EFfind_closest_uv_side();
	IGRdouble	nat_points[2][2];
	IGRlong		cls_side[2], blksize, num_sides[2], i, j;
	IGRdouble	cls_side_coord[2], mat_side_coord[2];
	IGRshort	loc_location[2][2];
	extern void EMside_number_to_location();
	
   blksize = 2 * sizeof(IGRdouble);
   *full_natural = *part_natural = natural = FALSE;

/* If the points are outside parametric domain, then exit.
*/
   for(i=0; i<2; i++)
       if( ((pt1[i] + partol) < 0.0) || ((pt1[i] - partol) > 1.0) ||
           ((pt2[i] + partol) < 0.0) || ((pt2[i] - partol) > 1.0))
         	goto wrapup;

/* Is the first point on a natural edge. If not exit.
*/
   natural = EFfind_closest_uv_side(0.0, 1.0, 0.0, 1.0, pt1[0], 
				pt1[1], partol, cls_side, cls_side_coord, 
				&cls_side_coord[1], 
				mat_side_coord, &mat_side_coord[1]);
   if(!natural) goto wrapup;

   OM_BLOCK_MOVE(cls_side_coord, pt1, blksize);

/* Is the second point on a natural edge. If not exit.
*/
   natural = EFfind_closest_uv_side(0.0, 1.0, 0.0, 1.0, pt2[0], 
				pt2[1], partol, &cls_side[1], cls_side_coord, 
				&cls_side_coord[1], 
				mat_side_coord, &mat_side_coord[1]);
   if(!natural) goto wrapup;
   OM_BLOCK_MOVE(cls_side_coord, pt2, blksize);

   EMside_number_to_location(cls_side[0], &loc_location[0][0], nat_points);
   if( EM2ddistptpts(pt1, nat_points[0]) < parsqtol)
    {
       num_sides[0] = 2;
       loc_location[0][1] = (loc_location[0][0] == 0) ? 3 : 
						loc_location[0][0] - 1;
    }
   else if(EM2ddistptpts(pt1, nat_points[1]) < parsqtol)
    {
	num_sides[0] = 2;
       loc_location[0][1] = (loc_location[0][0] == 3) ? 0 : 
						loc_location[0][0] + 1;
    }
   else num_sides[0] = 1;

   EMside_number_to_location(cls_side[1], &loc_location[1][0], nat_points);
   if( EM2ddistptpts(pt2, nat_points[0]) < parsqtol)
    {
       num_sides[1] = 2;
       loc_location[1][1] = (loc_location[1][0] == 0) ? 3 : 
						loc_location[1][0] - 1;
    }
   else if(EM2ddistptpts(pt2, nat_points[1]) < parsqtol)
    {
	num_sides[1] = 2;
       loc_location[1][1] = (loc_location[1][0] == 3) ? 0 : 
						loc_location[1][0] + 1;
    }
   else num_sides[1] = 1;

   for(i=0; i<num_sides[0]; i++)
      for(j=0; j<num_sides[1]; j++)
	if(loc_location[0][i] == loc_location[1][j])
	 {
	   OM_BLOCK_MOVE(&loc_location[0][i], location, sizeof(IGRshort));
	   if( (num_sides[0] == 2) && (num_sides[1] == 2) &&
	       (EM2ddistptpts(pt1, pt2) > parsqtol))
	     *full_natural = TRUE;
	   else
	     *part_natural = TRUE;
	   break;
	 }

wrapup:
  if(*part_natural || *full_natural) return(TRUE);
  else return(FALSE);

}




extern void EMside_number_to_location(side, location, nat_points)
 IGRshort	side, *location;
 IGRdouble	*nat_points;
{
   IGRlong	rc;

   if(side == 1) *location = 0;
   else if(side == 4) *location = 1;
   else *location = side;
  
  if(nat_points)
      EMnatpoints(&rc, *location, nat_points);
}

