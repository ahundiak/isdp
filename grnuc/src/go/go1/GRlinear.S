/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract
	This is a subclass of GRbspline which encompasses all linear 
	graphics objects.  All of the subclasses of GRlinear can be 
	geometrically described as consisting of a set of n points 
	connected by n-1 line segments between adjacent points.  
	Each subclass can be represented as a 2nd order B-spline curve.

Notes
	None

History	
	MAS     11/12/85 : Design date.
	MAS	09/03/87 : Altered for Release 1.1

*/

class specification GRlinear (1:1) of GRbspline;

message GRgetpolyline(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix; 
	IGRint *action;	struct IGRpolyline *polyline);
/*
Abstract 
	This method returns the IGRpolyline representation of a linear
	object.  If the action is 0, only the number of points is 
	returned. If the action is 1, the points are returned.

Arguments
     *mat_type	  IGRshort	 environment matrix type
     matrix	  IGRmatrix	 environment transformation matrix
     *action	  IGRint	 action flag
				 0 - return only number of points (value
				     is returned in the polyline structure)
				 1 - return polyline  (assumes the
					storage has been allocated)
     *msg	  IGRlong	 completion code
     *polyline	  IGRpolyline	 pointer to storage for an IGRpolyline data
				 structure

Notes
	The typical usage of this method will result in the method
	being called twice.  Once to find out the number of points
	(action = 0) in order to provide sufficient storage, and
	then, after assigning the points pointer in the polyline, call
	it again (action = 1) to get the polyine representation of 
	the object.

Return Values
     	MSSUCC - successful
 	MSFAIL - error
*/


override
GRgenabsg,
GRgeomprops;

#ifndef BASE_EMS
override GRcenter,GRlocaldp,GRmidpoint,GRapprojpt,GRdelvertex,
	 GRinsvertex,GRprojpt,GRarea,GRpostabsg,
	 GRaltconstruct,GRcentcurv,GRdisyourself,
  	 GRcpparallel, GRreport_defaults, GRreport, GRupdate_gadgets;

/* 
Motivation

GRcenter - overridden on this class because the center of a linear
	object is defined to be the centriod.

GRlocaldp - overridden to display the extensions of a specified 
	segment.

GRmidpoint - overridden for efficiency in calculations

GRapprojpt - overridden to deal with extensions of the object 

GRdelvertex - overridden because parent class declaration was a 
	method declaration only (MDO). The method is implemented at
	this level.

GRinsvertex - overridden because parent class declaration was a 
	method declaration only (MDO). The method is implemented at
	this level.

GRprojpt - overridden to deal with extensions of the object  

GRgeomprops - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

GRarea	- overridden for efficiency in calculations

GRcpparallel - overridden to handle disappearing segments


*/

message GRaddpts(IGRlong *msg; struct GRmd_env *env; IGRshort *num; 
	IGRdouble *points; IGRshort *option; GRobjid *new_objid);
/*
Abstract: 	
	This method adds a set of points to the end of a 
	linear graphics object.  For a closed geometry (e.g., a
	polygon), the repeated last point is removed, the new 
	points are added, and a new repeated last point is 
	generated.
Arguments
     *env	  GRmd_env	 structure defining the transformation
				 and other info about the object
     *num	  IGRshort	 number of points to add
     *points	  IGRdouble	 array of 3-D points to add
     *option	  IGRshort	 option to be used for closed linear
				 objects
				   - if = 0, then replace current
				     repeated last point with new 
				     list of points and close again
				     (primarily used for polygons)
				   - if = 1, then add current list
				     of points without deleting 
				     the current repeated point 
				     (primarily used for linestrings)
     *msg	  IGRlong	 completion code
     *new_objid	  GRobjid	 used if object changes classes, 
				 otherwise is same as my_id
Return Values
   - MSSUCC if successful     
   - GRSNOINVTRAN (severe) if input matrix is not invertible
   - GRSDGNEXCEED (severe) if range exceeds design limits
   - MSFAIL (severe) if other error
*/

message GRmoveseg(IGRlong *msg; struct GRmd_env *env;
	struct GRparms *seg_locate; IGRpoint from_pt; 
	struct IGRline *boreline);
/*
Abstract
	This method redefines the geometric representation
	of the linear object by moving an identified segment
	in its geometry.
Arguments
     *md_env       GRmd_env	  environment information
     *seg_locate   GRparms	  locates the appropriate segment to
				  modify 
     point	   IGRpoint	  point on segment ('from' point)
     *boreline	   IGRline	  indicates new location for segment
     *msg	   IGRlong	 completion code
Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure

Notes
	There must exist a unique, local plane determined by 
	the segment chosen for movement and its adjacent 
	segments.  Otherwise, the routine will fail.

	This method moves the segment indicated by the input GRparms
	structure to the location parallel to the original and 
	specified by the boreline.  The segment may not be moved 
	past the intersection of its adjacent segments.  The segment
	will either shrink or lengthen depending on the direction of
	movement.  However, if adjacent segments are either parallel
	or colinear, the length of the segment to move remains the
	same.  
*/


message GRsegfind(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
	struct GRparms *ref_parms; IGRpoint point1,point2);
/*
Abstract
	This routine finds the desired segment of alinear
	object.  
Arguments
     *matrix_type  IGRshort	  type of transformation matrix
     matrix	   IGRmatrix	  input transformation matrix
     *ref_parms	   GRparms	  parameters identifying segment
     *msg	   IGRlong	 completion code
     point1	   IGRpoint	 beginning point of selected segment
     point2	   IGRpoint	 ending point of selected segment

Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure
*/

message GRvtadjseg(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
	struct GRparms *vert_loc; IGRpoint point,vertex; 
	struct GRparms *seg_id1,*seg_id2);
/*
Abstract
	This method returns to the user the closest vertex to the 
	input point along with identifiers of the segments adjacent 
	to that vertex.
Arguments
     *matrix_type  IGRshort	  type of input transformation matrix
     matrix	   IGRmatrix	  transformation matrix
     *vert_loc	   GRparms	  locates the appropriate vertex 
				  (i.e. line strings which may have
				 	repeated vertices)
     point	   IGRpoint	  point to project
     *msg	   IGRlong	 completion code
     vertex	   IGRpoint	 vertex nearest input point
     *seg_id1	   GRparms	 parameter identifying adjacent seg
     *seg_id2	   GRparms 	 parameter identifying adjacent seg

Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure
*/

message GRremovepts(IGRlong *msg; struct GRmd_env *env; IGRshort *num);
/*
Abstract
	This method removes a set of points from the end
	of a linear graphics object.  For a closed geometry
	(e.g., a polygon), the requested number of points are
	removed beginning with the next to the last point.  The
	repeated last point is preserved.
Arguments
     *env	  GRmd_env	 structure defining the transformation
				 and other info about the object
     *num	  IGRshort	 number of points to remove
     *msg	  IGRlong	 completion code

Return Values
   - MSSUCC if successful     
   - MSFAIL (severe) if other error
*/

message GRputpolyline(IGRlong *msg; struct GRmd_env *env; 
	struct GRpost_info *post_info;  struct IGRpolyline *polyline; 
	GRobjid *new_objid);
/*
Abstract 
	This method stores the geometry into the object's 
	instance data. 
Arguments
     *env    struct GRmd_env	 environment information
     *post_info struct GRpost_info special posting information
     *msg	  IGRlong	 completion code
     *polyline	  IGRpolyline	 pointer to storage for an IGRpolyline data
				 structure
     *new_objid   GRobjid	 object id after posting
 
Return Values
     	MSSUCC - successful
 	MSFAIL - error
*/

reject GRputpolyline;

#endif

reject GRgetpolyline;

end specification  GRlinear;
