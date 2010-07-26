#ifndef igr_include

#define igr_include


   /* 
    *
    *	This include file is dependent on the following include file
    *
    *		igrtypdef.h
    *
    */


/*
 * 
 *  Geometry definitions.
 *
 */



struct IGRline			/* line entity				*/
{
	IGRdouble  *point1;	/* 2 points define a line; format -	*/
	IGRdouble  *point2;	/* 3-D           			*/
};

struct IGRline_seg		/* line segment structure		*/
{
	IGRdouble *beg_point;	/* beginning point of the line segment  */
	IGRdouble *end_point;	/* end point of the line segment	*/
				/* both points are 3-D           	*/
};

struct IGRpolyline			/* polyline geometry		*/
{
	IGRlong	  num_points;		/* number of points in polyline	*/
	IGRdouble *points;		/* pointer to array of contig-	*/
					/* uous points			*/
};

struct IGRset_polyline			/* polyline set geometry	*/
{
	IGRlong	num_comps;		/* number of components		*/
	struct IGRpolyline *comp_polys;	/* pointer to array of polyline */
					/* structures 			*/
	struct IGRpolyline polyline;	/* polyline structure for 	*/
					/* entire array of points	*/
};

struct IGRarc				/* arc geometry			*/
{
	IGRdouble prim_axis;		/* length of primary axis	*/
	IGRdouble sec_axis;		/* length of secondary axis	*/
	IGRdouble origin[3];		/* origin point			*/
	IGRdouble rot_matrix[16];	/* rotation matrix from local	*/
					/* to world coordinates		*/
	IGRdouble start_angle;		/* angle from primary axis to 	*/
					/* starting point of arc 	*/
					/* (in radians)			*/
	IGRdouble sweep_angle;		/* sweep angle of arc (radians)	*/
};

struct IGRellipse			/* ellipse geometry		*/
{
	IGRdouble prim_axis;		/* length of primary axis	*/
	IGRdouble sec_axis;		/* length of secondary axis	*/
	IGRdouble origin[3];		/* origin point			*/
	IGRdouble rot_matrix[16];	/* rotation matrix from local	*/
					/* to world coordinates		*/
};

struct IGRcone				/* circular cone geometry	*/
{
	IGRdouble base_radius;		/* the base radius		*/
	IGRdouble base_origin[3];	/* base origin point		*/
	IGRdouble top_radius;		/* the top radius		*/
	IGRdouble top_origin[3];	/* top origin point		*/
	IGRdouble rot_matrix[16];	/* rotation matrix from local	*/
					/* to world coordinates		*/
};

struct IGRptstring 			/* point string geometry	*/
{
	struct IGRpolyline polyline;	/* polyline defining points	*/
	double *matrix_array;		/* pointer to an array of 	*/
					/* matrices			*/
};

struct IGRlbsys				/* local bounded system geometry*/
{
	IGRdouble matrix[16];		/* transformation matrix from	*/
					/* local to world coordinates	*/
					/* (includes origin)		*/
	IGRdouble diag_pt1[3];		/* range block diagonal pt 1	*/
	IGRdouble diag_pt2[3];		/* range block diagonal pt 2	*/
};

struct IGRsymboldef /* Geometry of a symbol definition header */
{
   IGRdouble   diag_pt1[3];   /* range block diagonal pt 1  */
   IGRdouble   diag_pt2[3];   /* range block diagonal pt 2  */
};

struct IGRsymbol   /* Geometry of a symbol header    */
{
   IGRdouble   matrix[16]; /* transformation matrix from    */
                           /* local to world coordinates    */
                           /* (includes origin)             */
};

struct IGRbsp_curve			/* B-spline curve geometry	*/
{
	IGRshort   order;		/* order of the curve		*/
	IGRboolean periodic;		/* periodic (TRUE) / non-	*/
					/* periodic (FALSE) indicator	*/
	IGRboolean non_uniform;		/* non-uniform (TRUE) / uniform	*/
					/* (FALSE) knot vector 		*/
	IGRlong    num_poles;		/* number of poles		*/
	IGRdouble  *poles;		/* pointer to array of poles	*/
	IGRlong	   num_knots;		/* number of knots		*/
	IGRdouble  *knots;		/* pointer to array of knots	*/
	IGRboolean rational;		/* rational (TRUE) / 		*/
					/* nonrational (FALSE)		*/
	IGRdouble  *weights;		/* pointer to array of weights	*/
					/* (if rational)		*/
	IGRboolean planar;		/* planarity indicator		*/
	IGRboolean phy_closed;		/* physically closed indicator	*/
	IGRshort   num_boundaries;	/* number of boundaries imposed */
					/* on the curve			*/
	IGRdouble  *bdrys;		/* pointer to array of boundary	*/
					/* parameter values (total 	*/
					/* number of values is twice	*/
					/* the number of boundaries)	*/
};

struct IGRbc_bdrys			/* curve boundaries structure	*/
{
	IGRshort   num_boundaries;	/* number of boundaries imposed */
					/* on the curve			*/
	IGRdouble  *bdrys;		/* pointer to array of boundary	*/
					/* parameter values (total 	*/
					/* number of values is twice	*/
					/* the number of boundaries)	*/
};

struct IGRbsp_bdry_pts			/* boundary points structure	*/
{
	IGRlong	  num_points;		/* number of points in the 	*/
					/* boundary			*/
	IGRdouble *points;		/* pointer to array of 		*/
					/* contiguous (u,v) points	*/
};

struct IGRbsp_surface			/* B-spline surface geometry	*/
{
	IGRshort   u_order;		/* order in the u direction	*/
	IGRshort   v_order;		/* order in the v direction	*/
	IGRboolean u_periodic;		/* periodic (TRUE) / non-	*/
					/* periodic (FALSE) in the u	*/
					/* direction indicator		*/
	IGRboolean v_periodic;		/* periodic (TRUE) / non-	*/
					/* periodic (FALSE) in the v	*/
					/* direction indicator		*/
	IGRboolean u_non_uniform;	/* non-uniform (TRUE) / uniform	*/
					/* (FALSE) u direction knot	*/
					/* vector			*/
	IGRboolean v_non_uniform;	/* non-uniform (TRUE) / uniform	*/
					/* (FALSE) v direction knot	*/
					/* vector			*/
	IGRlong    u_num_poles;		/* # poles in u direction	*/
					/* (# rows in pole matrix)	*/
	IGRlong    v_num_poles;		/* # poles in v direction	*/
					/* (# columns in pole matrix)	*/
	IGRdouble  *poles;		/* pointer to matrix of poles	*/
					/* (column major form)		*/
	IGRlong	   u_num_knots;		/* number of knots in u 	*/
	IGRdouble  *u_knots;		/* pointer to u direction knots	*/
	IGRlong	   v_num_knots;		/* number of knots in v 	*/
	IGRdouble  *v_knots;		/* pointer to v direction knots	*/
	IGRboolean rational;		/* rational (TRUE) / non-	*/
					/* rational (FALSE) indicator	*/
	IGRdouble  *weights;		/* pointer to matrix of weights	*/
					/* (if rational)		*/
	IGRboolean planar;		/* planarity indicator		*/
	IGRboolean u_phy_closed;	/* physically closed indicator	*/
	IGRboolean v_phy_closed;	/* physically closed indicator	*/
	IGRboolean pos_orient;		/* orientation indicator	*/
	IGRboolean on_off;		/* indicator of whether the 	*/
					/* point (u,v) = (0,0) is on 	*/
					/* (TRUE) or off (FALSE) the	*/
					/* surface (only valid if number*/
					/* of boundaries is non-zero)	*/
	IGRshort   num_boundaries;	/* number of boundaries imposed */
					/* on the surface		*/
	struct IGRbsp_bdry_pts		/* pointer to array of boundary */
	  	   *bdrys;		/* point structures		*/
};

struct IGRrt_prism			/* right prism geometry		*/
{
	IGRdouble matrix[16];		/* transformation matrix from 	*/
					/* local to world coordinates	*/
					/* (includes origin)		*/
	struct IGRpolyline polygon;	/* bottom face definition 	*/
					/* (closed, planar polyline in 	*/
					/* x-y plane of local system	*/
					/* (stored in local coordinates)*/
	IGRdouble height;		/* height (in local z-direction)*/
					/* of upper prism face		*/
};

struct IGRcv_prism			/* curve prism geometry		*/
{
	IGRdouble matrix[16];		/* transformation matrix from 	*/
					/* local to world coordinates	*/
					/* (includes origin)		*/
	struct IGRbsp_curve curve;	/* bottom face definition 	*/
					/* (closed, planar polyline in 	*/
					/* x-y plane of local system	*/
					/* (stored in local coordinates)*/
	IGRdouble height;		/* height (in local z-direction)*/
					/* of upper prism face		*/
};

struct IGRpolygon			/* polygon geometry		*/
{
	IGRlong	  num_points;		/* number of points in polygon	*/
	IGRdouble *points;		/* pointer to array of contig-	*/
					/* uous points			*/
};

struct IGRcurve				/* curve geometry		*/
{
	IGRlong	  num_points;		/* number of points in curve	*/
	IGRdouble *points;		/* pointer to array of contig-	*/
					/* uous points			*/
};



/*
 *
 *  Supporting geometry definitions.
 *
 */



struct IGRplane			/* plane entity				*/
{
	IGRdouble  *point;	/* point on plane; (3-D)		*/
	IGRdouble  *normal;	/* vector normal to the point		*/
};

struct IGRpointset		/* point set structure			*/
{
	IGRlong	   num_points;	/* number of points in set		*/
	IGRdouble  *points;	/* array of contiguous points, points	*/
				/*     must be 3-D           		*/
};

#endif
