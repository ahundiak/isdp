
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

/* This file contains definitions associated with the tool. */

#define	NO_DOT_PRODUCT		-1	/* flag to indicate that the dot product
					   between this vertex and its path curve
					   has not been calculated */
#define	NO_PROFILE_POINT	-1	/* flag to indicate that there is no profile
					   point on this edge of this facet */

struct NC_tool_data
   {
   IGRint	num_xsect;		/* the number of cross-sections required to
   					   tile the tool to the given tolerance */
   IGRint	num_curve_points;	/* the number of points in the tool curve */
   IGRdouble	critical_cosine;	/* cosine of the critical angle */
   IGRdouble	fax_facet_cosine;	/* cosine for the five-axis facet generator */
   IGRdouble	height;			/* distance between the tip and top of the tool */
   IGRboolean	open_ended;		/* TRUE if the top of the tool is open (r!=0) */
   IGRboolean	linestring;		/* TRUE if the order of the original curve was
   					   a linestring (order 2). */
   };

struct NC_tool_arrays
   {
   IGRpoint	*xsect;		/* the CROSS-SECTION matrix.  This array holds all the
				   points of all the tool cross sections in world
				   coordinates. */
   IGRpoint	*fnorm;		/* the FACET NORMAL matrix.  This array holds all the
				   normals to all the points in xsect. */
   IGRpoint	*vnorm;		/* the VERTEX NORMAL matrix.  This array holds all the
				   normals to all the points in xsect. */
   IGRpoint	*txm;		/* the TEMPORARY XSECT matrix.  This is used in the
				   generation of the profile curve. */
   IGRpoint	*tfm;		/* the TEMPORARY FACET NORMAL matrix.  This is used in
				   the generation of five-axis swept volumes. */
   IGRpoint	*tvm;		/* the TEMPORARY VERTEX NORMAL matrix.  This is used in
				   the generation of five-axis swept volumes. */
   IGRpoint	*orig_start_pt;	/* the ORIGIN START PROFILE POINT array.  This holds the
				   points of the start of the origin profile for use in
				   generating the five-axis swept volume. */
   IGRpoint	*orig_start_norm;/*the ORIGIN START PROFILE NORMAL array.  This holds
				   the normals for the points of the start of the origin
				   profile for use in generating the five-axis swept
				   volume. */
   IGRpoint	*orig_end_pt;	/* the ORIGIN END PROFILE POINT array.  This holds the
				   points of the projection of the origin profile for
				   use in generating the five-axis swept volume. */
   IGRpoint	*orig_end_norm;	/* the ORIGIN END PROFILE NORMAL array.  This holds
				   the normals for the points of the projection of the
				   origin profile for use in generating the five-axis
				   swept volume. */
   IGRint	*orig_prof_edge;/* the ORIGIN PROFILE EDGE matrix.  This holds the indexes
				   of pairs of points that make up the origin profile edges. */
   IGRdouble	*orig_dp;	/* the ORIGIN DOT PRODUCT matrix.  This holds the dot
				   products of all origin vertices with their path curves. */
   IGRpoint	*dest_start_pt;	/* the DESTINATION START PROFILE POINT array.  This holds
				   the points of the start of the destination profile for
				   use in generating the five-axis swept volume. */
   IGRpoint	*dest_start_norm;  /* the DESTINATION START PROFILE NORMAL array.  This
				   holds the normals for the points of the start of the
				   destination profile for use in generating the five-axis
				   swept volume. */
   IGRpoint	*dest_end_pt;	/* the DESTINATION END PROFILE POINT array.  This holds the
				   points of the projection of the destination profile for
				   use in generating the five-axis swept volume. */
   IGRpoint	*dest_end_norm;	/* the DESTINATION END PROFILE NORMAL array.  This holds
				   the normals for the points of the projection of the
				   destination profile for use in generating the five-axis
				   swept volume. */
   IGRint	*dest_prof_edge;/* the DESTINATION PROFILE EDGE matrix.  This holds the
				   indexes of pairs of points that make up the destination
				   profile edges. */
   IGRdouble	*dest_dp;	/* the DESTINATION DOT PRODUCT matrix.  This holds the dot
				   products of all dest vertices with their path curves. */
   IGRpoint	*profile;	/* the PROFILE POINT array.  This holds the profile
				   points for use in generating the swept volume. */
   IGRpoint	*profnorm;	/* the PROFILE NORMAL array.  This holds the profile
				   normals for use in shading the swept volume. */
   IGRint	*profind;	/* the PROFILE INDEX array.  This holds the indexes
				   of all the profile points. */
   IGRint	*minpind;	/* the MIN POINT INDEX array.  This is used to save
				   the index of the minimum point at which the
				   profile curve crosses each cross section.  It
				   is used when tiling the tool at the destination
				   end of the swept volume. */
   };
