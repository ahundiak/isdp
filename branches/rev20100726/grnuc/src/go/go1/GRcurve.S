/*
Abstract
 	This is the abstract class for all geometries representable as
	vector valued functions of a single parameter.
Notes
	None

History
	RDH  03/24/86 : Design date.
	MAS  09/03/87 : Altered for release 1.1
*/

class specification GRcurve (1:1) of GRvg;


message GRendpts(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	IGRpoint startpt,endpt);
/*
Abstract
	This routine determines the endpoints (beginning and 
	ending points) of the  graphics object.
Arguments
     *mat_type	  IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix
     *msg	  IGRlong	 return code:
     startpt	  IGRpoint	 start point
     endpt	  IGRpoint	 end poiint

Return Values
	MSSUCC - successful
	MSFAIL - an error occurred
*/
reject
GRendpts;
#ifndef BASE_EMS
message GRptseqspace(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	IGRpoint point1,point2,point3; struct GRparms *p1,*p2,*p3; 
	IGRlong *num; IGRdouble *out_points);
/*
Abstract
	This module produces a specified number of equally spaced 
	points on an object.  The points begin at point1 and end 
	at point3.

	Point2 is used to determine direction on closed curves.
Arguments
	*mx_type  IGRshort	 matrix type
	matrix    IGRmatrix	 environment matrix	
	point1	  IGRpoint	 beginning point for equal spaced
				    points
	point2    IGRpoint	 direction point needed for closed
				    objects
	point3    IGRpoint	 ending point for equal spaced points
	*p1	  GRparms	 structure for parameter information
				    for point1
	*p2	  GRparms	 structure for parameter information
				    for point2
	*p3	  GRparms	 structure for parameter information
				    for point3
   	*num	  IGRlong	 number of points requested
	*msg	  IGRlong	 completion code
	*out_points IGRdouble	 output points 
Return Values
	MSSUCC - successful completion
	MSINARG - invalid input request; number of points must be 2
		or more	
	MSFAIL - error occured

Notes
	If your object is an open curve, point2 (and its 
	parameter,p2) and point3 (with parameter, p3) 
	may be the same. 

	The input points, point1 and point3 will be included
	in the out_points array as the first and last
	points respectively.
*/

message GRptalong(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	IGRpoint point1,point2; struct GRparms *p1,*p2;
	IGRdouble *dist; IGRpoint out_point);
/*
Abstract
 	This module produces a point on an object at a given distance 
	from an input point in the direction of a second input point.
Arguments
	*mx_type  IGRshort	 matrix type
	matrix    IGRmatrix	 environment matrix	
	point1	  IGRpoint	 beginning point for distance measure
	point2    IGRpoint	 direction point
	*p1	  GRparms	 structure for parameter information
				    for point1
	*p2	  GRparms	 structure for parameter information
				    for point2
   	*dist	  IGRdouble	 distance from point1 to produce new
				    point
	*msg	  IGRlong	 completion code
	out_point IGRpoint	 output point
Return Values
	MSSUCC - successful completion
	MSFAIL - error occured
Notes
	If a curve is a closed curve, the results produced by
	this method may not be what you expect because you are
	unable to visually tell where the geometric beginning 
	and end of the curve are located.  

	This method will not produce a point off the endpoint
	of the curve.  An error will be returned if this is
	requested.
*/
message GRendpoint(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	struct IGRline *boreline; IGRpoint endpoint);
/*
Abstract: 
	This method determines the endpoint of the object which lies 
	closer to the given boreline.
Arguments
     *matrix_type IGRshort	 type of input transformation matrix
     matrix	  IGRmatrix	 input transformation matrix
     *boreline	  struct IGRline line referencing closest endpoint
     *msg	  IGRlong	 completion code
     endpoint	  IGRpoint	 endpoint of object nearest boreline
Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure
*/

message GRmidpoint(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	struct GRparms *ref_parms; IGRpoint midpoint);
/*
Abstract
	This routine finds the midpoint of the given graphics object.  
	If the object is segmented, then the midpoint of the selected 
	segment is returned. The selected segment is determined by the
	input parameter structure.

Arguments
     *matrix_type  IGRshort	  type of transformation matrix
     matrix	   IGRmatrix	  input transformation matrix
     *ref_parms	  struct GRparms  parameters identifying segment
     *msg	  IGRlong	  completion code
     midpoint	  IGRpoint	  desired midpoint
Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure
*/


message GRperbis(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	struct GRparms *ref_parms; IGRvector norm_vc; IGRpoint
	proj_pt; struct IGRbsp_curve *bisector);
/*
Abstract
	This routine finds the perpendicular bisector of an object.
Arguments
     *mat_type	  IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix
     *ref_parms	  GRparms	 reference parameters
     norm_vc	  IGRvector	 vector to use in linear case
     proj_pt	  IGRpoint	 point to determine endpoint of bis-
				 sector segment
     *msg	  IGRlong	 return code
     *bisector	  IGRline	 perpendicular bisector
Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure

Notes
	The input point, proj_pt is used to determine the endpoint of
	the perpendicular bisector by projecting it onto the perpen-
	dicular line from the midpoint.
*/

message GRinsvertex(IGRlong *msg; struct GRmd_env *md_env; 
	struct GRparms *ref_parms; struct IGRline *boreline; 
	GRobjid *new_objid);
/*
Abstract
	This routine inserts the input vertex into the object at the 
	specified location.  
	
	Special processing is performed if the input vertex should be 
	inserted at a current vertex point or if the object is a polygon
	and the vertex is to be inserted at the	start/end point.
Arguments
     *md_env	   GRmd_env	  environment information 
     *ref_parms	   GRparms	  parameters identifying segment
     *boreline     IGRline	  the desired vertex to insert
     *msg	   IGRlong	 completion code
     *newobjid     GRobjid	 will contain a new object id if the
				    object changes classes 
Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure
Notes
     	The response of some objects depends on the type object.

	point:
	  a line is formed, the new point becomes the start
		point and the original point becomes the endpoint

        line:
	  if selected location is exactly an endpoint, new point becomes 
		new endpoint
	  otherwise, new point is added between 
	       	endpoints

	line string:
	  if selected location is exactly start or end
		point, start or end is replaced by new point
	  if selected location is a vertex of segment,
		new point is inserted before vertex of segment
	  if selected location is between the endpoints of a
		segment, the new point is inserted there

	polygon:
	  processed exactly like the line string except for the
	  	following case
 	  if selected location is the start/end point,
		the new point is inserted before the start point
		to become the new start point and the original
		endpoint is modified to close the polygon (becomes
		the new point also).
*/

message GRdelvertex(IGRlong *msg; struct GRmd_env *md_env;
	struct GRparms *ref_parms; GRobjid *new_objid);
/*
Abstract
	This routine deletes the selected vertex from the object.  
	If the object is a polygon and the vertex to be deleted is
	the start/end point, special processing	must occur.

     *md_env	   GRmd_env	  environment information 
     *ref_parms	   GRparms	  parameters identifying nearest
				     vertex
     *msg	   IGRlong	 completion code
     *newobjid     GRobjid	 will contain a new object id if the
				    object changes classes 
Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure
Notes
	Special processing must occur for certain objects.  Following 
	is a description of this special processing:

	line segment:
	   when the vertex is deleted, a point object must
	   be constructed

	polygon:
	   if the deleted vertex is the start/end point,
	   the second point in the polygon becomes the
	   new start/end point
*/

message GR2ptpartdel(IGRlong *msg; struct GRmd_env *env; IGRpoint point1,
	point2; struct GRparms *p1, *p2; GRobjid *c1,*c2; IGRshort *num);
/*
Abstract
	This module performs the partial delete operation on an object 
	by deleting the portion of the object between the two points and
	constructing new objects from the remaining portions of the
	object.  The original object will be deleted.  Channel connections
	are not maintained.
Arguments
	*env	  GRmd_env	 data set environment structure
	point1	  IGRpoint	 beginning point of deletion
	point2    IGRpoint	 ending point of deletion
	*p1	  GRparms	 structure for parameter information
				    for point1
	*p2	  GRparms	 structure for parameter information
				    for point2
	*msg	  IGRlong	 completion code
        *c1       GRobjid	 new object
	*c2 	  GRobjid	 new object 
	*num	  IGRlong	 number of objects returned may be
				  0,1 or 2
Return Values
	MSSUCC - successful completion
	MSINARG  - partial delete request is not valid, 
		the delete points produced an object identical to 
		the old object
	MSFAIL - error occured
Notes
	If any error is encountered, the original object is left intact.
	Any additional objects created in the method are deleted.
*/

message GR3ptpartdel(IGRlong *msg; struct GRmd_env *env; IGRpoint point1,
	point2,point3; struct GRparms *p1, *p2, *p3;GRobjid *c1, *c2; 
	IGRshort *num);
/*
Abstract 
	This module performs the partial delete operation on an object 
	by deleting the portion of the object between point1 and point3 
	using point2 as a direction point to determine which portion of 
	the curve to delete.  After deletion of the desired segment, new 
	object(s) will be constructed from the remaining portions of the 
	curve if the curve is open.  If the object is closed, the 
	remaining portions will be concatenated into a single object 
	with the parameterization adjusted so that point1 is the 
	beginning point of the new object and point3 is the ending point.

	The original object will be deleted if the method is successful.
Arguments
	*env	  GRmd_env	 data set environment structure
	point1	  IGRpoint	 beginning point of deletion
	point2    IGRpoint	 direction point
	point3    IGRpoint	 ending point of deletion
	*p1	  GRparms	 structure for parameter information
	*p2	  GRparms	 structure for parameter information
	*p3	  GRparms	 structure for parameter information
	*msg	  IGRlong	 completion code
        *c1       GRobjid	 new object
	*c2 	  GRobjid	 new object 
	*num	  IGRlong	 number of objects returned may be
				  0,1 or 2
Return Values
	MSSUCC - successful completion
	MSINARG  - partial delete request is not valid, the delete
		points produced an object identical to the old object
	MSFAIL - error occured
Notes     
	The original object will be left intact if any error
	occurs.
*/

message GRarea(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix; 
	IGRdouble *area);
/*
Abstract
	This method determines the area of a closed, planar
	curve object.
Arguments
     *mat_type     IGRshort	  type of input matrix
     matrix	   IGRmatrix	  local to world transformation matrix
     *msg	  IGRlong	 completion code
     *area	  IGRdouble	 the area of the object
Return Values
   - MSSUCC if successful     
   - MSFAIL (severe) if other error
*/

message GRarclength(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
	IGRpoint point1,point2,point3; struct GRparms *p1,*p2,*p3; 
	IGRdouble *arclength);
/*
Abstract
	This module computes the arclength of an object between specified 
	input points. The measurement begins at point1 and ends at point3.

	Point2 is used as an indicator to determine if the curve is to 
	be treated as an open or closed curve.  If it is to be treated 
	as open, point2 should be the same as point1.  If it is to 
	be treated as closed, point2 must be different from point1 
	and point3.  Point2 is used to determine direction for 
	measurement on closed curves.
Arguments
	*mx_type  IGRshort	 matrix type
	matrix    IGRmatrix	 environment matrix	
	point1	  IGRpoint	 beginning point for equal spaced
				    points
	point2    IGRpoint	 direction point needed for closed
				    objects
	point3    IGRpoint	 ending point for equal spaced points
	*p1	  GRparms	 structure for parameter information
				    for point1
	*p2	  GRparms	 structure for parameter information
				    for point2
	*p3	  GRparms	 structure for parameter information
				    for point3
	*msg	  IGRlong	 completion code
	*length   IGRdouble	 length of the designated portion of
				    the curve 
Return Values
	MSSUCC - successful completion
	MSFAIL - error occured
Notes:
	If your object is to be treated as a closed curve, point2 
	(and its parameter,p2) is required to be the same as point1 
	(with parameter, p1). 
*/

message GRptextend(IGRlong *msg; struct GRmd_env *env; IGRpoint endpoint,
	ext_pt, new_end);
/*
Abstract
	This method extends one endpoint of an object to another point.
Arguments
     *env      struct GRmd_env	 environment information
     endpoint	  IGRpoint	 endpoint to extend
     ext_pt	  IGRpoint	 point to extend to
     *msg	  IGRlong	 return code
     newend	  IGRpoint	 new end point
Return Values
	MSSUCC - successful
	MSFAIL - severe error
	MSINARG - object is not open or is not linear
Notes
	The new endpoint is found as the projection of ext_pt onto
	the line segment formed by the first or last two poles.

	This routine works on curves of order 2 only (i.e. linear 
	curves).
*/

message GRdisextend(IGRlong *msg; struct GRmd_env *env; IGRpoint endpoint; 
	IGRdouble *dist; IGRpoint new_end);
/*
Abstract
	This routine extends one endpoint of a B-spline curve
	along its natural extenion by a specified distance.
Arguments
     *env	 struct GRmd_env environment information
     endpoint	  IGRpoint	 endpoint to extend
     *dist	  IGRdouble	 distance to extend geometry
     *msg	  IGRlong	 return code
     newend	  IGRpoint	 new end point
Return Values
	MSSUCC - successful
	MSFAIL - severe error
	MSINARG - object is not open or is not linear
	MASDGENRAT - curve is a point

Notes
	This routine works on curves of order 2 only (i.e. linear 
	curves).
*/

message GRsplit(IGRlong *msg; struct GRmd_env *env; IGRpoint point;
	struct GRparms *parm; GRobjid *c1, *c2; IGRshort *num);
/*
Abstract
	This module performs a split operation on a  curve object.

	For a closed curve, a new open curve is formed with the 
	beginning and ending point being the split point.  

	For an open curve, 2 new open curves are created, provided 
	the split point is not an endpoint of the original curve.
		
	The original object will be deleted if the method is successful.
	Channel connections are not maintained, since the original
	object no longer exists.
Arguments
	*env	  GRmd_env	 data set environment structure
	point	  IGRpoint	 point to split curve
	*p1	  GRparms	 structure for parameter information
	*msg	  IGRlong	 completion code
        *c1       GRobjid	 new object
	*c2 	  GRobjid	 new object 
	*num	  IGRlong	 number of objects returned may be
				  0,1 or 2
Return Values
	MSSUCC - successful completion
	MSINARG - invalid request for this method - split point
		was an endpoint of the original open curve. Original
		curve is left intact.
	MSFAIL - error occured
Notes
	The original curve is left intact if any error occurs.
*/



message GRrevparm(IGRlong *msg; struct GRmd_env *md_env);
/*
Abstract
	This method reverses the parameterization of a curve
	object.
Arguments
     *env	 struct GRmd_env environment information
     *msg	  IGRlong	 return code
Return Values
	MSSUCC - successful     
*/

message GRtotlength(IGRlong *msg; IGRshort *mat_type;
		IGRmatrix matrix; IGRdouble *tot_length);
/*
Abstract
	This method determines the total arc length of
	the curve object.
Arguments
     *mat_type     IGRshort	  type of input matrix
     matrix	   IGRmatrix	  local to world transformation matrix
     *msg	  IGRlong	 completion code
     *totlength	  IGRdouble	 the total arc length of the object
Return Values
   - MSSUCC if successful     
   - MSFAIL (severe) if other error
*/



message EMcvradcrv (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
	struct GRvg_construct *const_args; IGRlong numpars;
	struct GRparms *start_parm,*mid_parm,*end_parm; IGRdouble maxrad; 
	IGRdouble *crvtr_val; IGRdouble *radii_val; IGRdouble *radii_poly;
 	GRobjid *radii_obj; IGRdouble *crv_poly; GRobjid *crv_obj);


message EMcvtanorm (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
	struct GRvg_construct *const_args; IGRlong numpars;
	struct GRparms *start_parm,*mid_parm,*end_parm;
        IGRdouble displen; IGRdouble *dirpt; IGRboolean comp_tangent; 
	IGRboolean comp_normal; IGRdouble *outpoly; GRobjid *outobj);
	

message EMcvoffset (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
        struct GRvg_construct *const_args; IGRdouble *offdist;
	IGRvector vector; IGRboolean right_side; IGRboolean uniform;
	IGRint *off_code; IGRboolean fillet, remove_loops;
        struct GRid *offcvid; IGRlong *num_loops; 
	struct IGRbsp_curve ***loops; IGRlong **loop_table);

message EMpartofcv (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
        struct GRvg_construct *const_args; struct GRparms *start_parms,
	*mid_parms,*end_parms; GRobjid *partcvid);

message EMcrvcrvint( IGRlong		  *msg;
		    struct GRvg_construct *crv_cnst;
		    struct GRmdenv_info   *my_objenv;
		    struct IGRbsp_curve   *other_curve_in;
		    struct GRid		  *other_obj;
		    struct GRmdenv_info   *other_objenv;
		    IGRboolean		   end_inter_valid;

		    IGRlong		  *pnt_slots;
		    IGRlong		  *grand_num_pnt;
		    struct GRid		  **pnt_ids;
		    struct GRparms	  **my_pnt_inters;
		    struct GRparms	  **other_pnt_inters;
		    IGRdouble		  **inter_pnts_xyz;

		    IGRlong		  *crv_slots;
		    IGRlong		  *grand_num_crv;
		    struct GRid		  **crv_ids;
		    struct GRparms	  **my_crv_inters;
		    struct GRparms	  **other_crv_inters);

message EMcrvslfint(IGRlong *msg;
		    struct GRvg_construct *crv_cnst;
		    struct GRmdenv_info *my_objenv;

		    IGRlong		*pnt_slots;  
		    IGRlong 		*grand_num_pnt;
		    struct GRid 	**pnt_ids;
		    struct GRparms 	**my_pnt_inters;
		    IGRdouble      	**inter_pnts_xyz;

		    IGRlong		*crv_slots;
		    IGRlong 		*grand_num_crv;
		    struct GRid 	**crv_ids;
		    struct GRparms 	**my_crv_inters);

message EMbuild_stack (IGRlong 	*msg; IGRpoint search_pt;
	struct GRid original_cc; IGRdouble generic_tol;	
	IGRdouble closed_tol; IGRint *active_levels; 
	struct GRmd_env *module_info; struct GRlc_stack *stack);




message GRcpparallel(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix; struct GRmd_env *offset_env;
	struct IGRline *direction_boreline; 
	struct IGRline *distance_boreline; 
	IGRdouble *distance; IGRboolean *apparent_flag;
     	IGRmatrix projection_matrix; GRobjid *objid);
/*
Abstract:
	This method creates a new object parallel to the 
  	original object.

Arguments
	IGRlong *msg; 			return message
	IGRshort *mx_type, 		matrix type of original object
	IGRmatrix matrix; 		matrix for original object
	struct GRmd_env *offset_env;	environment for offset
	struct IGRline *direction_boreline; 
					boreline to indicate direction
					of offset
	struct IGRline *distance_boreline; 
					boreline to indicate distance 
					for offset ( send NULL pointer
					if sending distance)
	IGRdouble *distance; 		distance for offset (send NULL
					if sending distance_boreline)	
	IGRboolean *apparent_flag;	flag to indicate if the offset 
					is to be apparent
					 1 - do apparant offset
					 0 - offset in plane of element
     	IGRmatrix *projection_matrix;   matrix to use for apparent offset
			NOTE: non-planar elements will always be an
			      apparent offset
	GRobjid *objid   	      	offset object's id

Return Values:
	MSSUCC  - successful completion
	MSFAIL  - error occured
*/

reject 	GRptseqspace, GRptalong,  GRmidpoint,
 	GRinsvertex, GRdelvertex, GR2ptpartdel, GR3ptpartdel,
 	GRarea, GRarclength, GRtotlength, GRptextend, GRdisextend,
 	GRsplit,GRcpparallel;


reject  GRrevparm, EMcrvcrvint, EMcrvslfint, EMcvradcrv,
 	EMcvtanorm, EMcvoffset, EMpartofcv;


#endif
end specification GRcurve;
