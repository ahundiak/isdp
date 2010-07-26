/*
Abstract
	The abstract class GRconic is a subclass of GRbspline which
	encompasses all conic graphics objects.  Each subclass of
	GRconic can be represented as a 3rd order rational b-spline
	curve.
Notes 
	None
History	
	KMO	03/24/86 : Revision date.
	SDG     11/12/85 : Creation date.
	MAS	09/03/87 : altered for Release 1.1
*/

class specification GRconic (1:1) of GRbspline;

from GRvg inherit GRstretch;
override
  GRgenabsg, 
  GRgeomprops;


message GRgetarc(IGRlong *msg; IGRshort *mx_type; IGRmatrix
		 matrix; struct   IGRarc *geom);
/*
Abstract 
	This method converts the object's instance data into the 
	equivalent IGRarc data placing it into a provided data structure.
Arguments
     *mat_type	  IGRshort	 environment matrix type
     matrix	  IGRmatrix	 environment transformation matrix
     *msg	  IGRlong	 completion code
 
     *arc	  IGRarc	 pointer to storage for an IGRarc data
				 structure
Return Values
     	MSSUCC - successful
 	MSFAIL - sine and cosine of rotation angle could not be calculated
        MAIDGENRAT - one axis degenerated and rotation is aligned 
		with the axis.
        MAINOTUNIQUE - both axes degenrated and unique rotation 
		matrix could not be determined. Rotation matrix is 
		same as stored in the arc object
*/
reject GRgetarc;

#ifndef BASE_EMS
override GRcenter,GRkeypoint,GRdisextend,GRgetexgeom,
	 GRgetexsize,GRptextend,GRlocaldp,
	 GRmodify,GRprojpt,GRapprojpt,
	 GRlnproject, GRptproject,GRgetrang,GRarea,
	 GRpostabsg, GRaltconstruct,
	 GRcentcurv, GRcpparallel;
/* 
Motivation 

GRcenter - overridden to return the defined center (origin) of a
	conic instead of the centroid.

GRkeypoint - overridden to return the closest keypoint
	of a conic.  The conic keypoints are defined as the
	endpoints of an arc (if object is an arc), the endpoints
	of the axis and the origin of the conic.

GRdisextend - overridden to handle the extensions of the object

GRgetexgeom - overridden to return the extended geometry of a conic.
	Parent's method defaults to return the objects geometry
	without extensions

GRgetexsize  - overridden to return the size of the extended geometry
 	of a conic. Parent's method defaults to return the objects size.

GRptextend  - overridden to extend the object along the natural
	definition of its extensions

GRgeomprops - overridden because it returns information about
	the actual object which cannot be determined at parent
	classes.

GRlocaldp - overridden to display the extensions of the object

GRmodify - overridden to modify the axis of a conic

GRprojpt - overridden to handle the extensions of the object

GRapprojpt - overridden to handle the extensions of the object

GRlnproject - overridden for efficiency

GRptproject - overridden for efficiency

GRgetrang - overridden to return the true range of the conic object.

GRarea - overridden for efficiency

GRaltconstruct - overridden to deal with the arc's geometry 

GRgenabsg - overriden to convert the IGRarc form to a B-spline

GRpostabsg - overriden to convert the B-spline form to IGRarc form 

GRcppparallel - overridden to allow the copy to be the same class 

*/

message GRaxmodify(IGRlong *msg; struct GRmd_env *md_env;
		   IGRpoint axis_pt,end_pt; GRobjid *new_id);
/*
Abstract
	This routine modifies the length of one axis of a 
	conic element as indicated by an input point that is
	projected onto the axis to determine the length.
Arguments
     *env	struct  GRmd_env environment information
     axis_pt	  IGRpoint	 point indicating axis to modify
     end_pt	  IGRpoint	 point to extend end of axis to
     *msg	  IGRlong	 return code
     *newid	  GRobjid	 returned object id
Return Values
	MSSUCC - successful
	MSFAIL - severe error
*/

message GRputarc(IGRlong *msg; struct GRmd_env *env; 
	struct GRpost_info *post_info;  struct IGRarc *arc; 
	GRobjid *new_objid);
/*
Abstract 
	This method stores the geometry into the object's 
	instance data. 
Arguments
     *env    struct GRmd_env	 environment information
     *post_info struct GRpost_info special posting information
     *msg	  IGRlong	 completion code
     *arc	  IGRarc	 pointer to storage for an IGRarc data
				 structure
     *new_objid   GRobjid	 object id after posting
 
Return Values
     	MSSUCC - successful
 	MSFAIL - error
*/

reject GRputarc;
#endif

end specification GRconic;
