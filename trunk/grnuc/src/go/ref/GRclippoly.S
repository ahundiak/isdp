/*

Abstract
	The class GRclippoly is a subclass of GRcurve and is a 3-D 
	double precision representation of a clipping polygon for
	a reference file attachment object.  The clipping polygon is
	geometrically defined as a curve prism (struct IGRcv_prism).  
Notes
	none.
History	
	MAS     05/21/87 : Design date
	MAS     09/08/87 : Altered for release 1.1
        Gang    05/27/93 : Added support for shrink/wrap.
*/

class specification GRclippoly  (1:1) of GRcurve;

instance GRclippoly
{
    channel {(one_to_one) GRreffile.to_clip;} to_attachment;
    GRobjid	cv_objid;
    IGRmatrix	matrix;
    IGRdouble 	height;
};

message GRgenprism(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
	IGRchar **absgptr);
/*     
Abstract: 
	This method generates the curve prism representation for an
	object and places the data in the standard buffer (abstract data
	cache).  
Arguments
     *matrix_type IGRshort	 type of the transformation matrix
     matrix	  IGRmatrix	 local-to-world transformation matrix
     *msg	  IGRlong	 completion code
     **absgptr    IGRchar	 pointer to abstract geometry 
Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure due to allocation problems
*/

message GRpostprism(IGRlong *msg; struct GRmd_env *md_env;
	struct GRpost_info *info; IGRchar *absptr; GRobjid *newobjid);
/*
Abstract: 
	This method posts the curve prism geometry.

Arguments
     *md_info    struct GRmd_env     structure defining the transfor-
				      mation and other information
				      necessary for interfacing with
				      the module.
     *post_info  struct GRpost_info  processing control information
     *absptr     IGRchar	     pointer to buffer containing the
				      geometry in internal format
     *msg	  IGRlong	 completion code
     *newobjid    GRobjid	 same as my-id; object cannot
				      change class
Return Values
    - MSSUCC if successful
    - GRSNOINVTRAN (severe) if input matrix is not invertible
    - GRSDGNEXCEED (severe) if range exceeds design limits
    - MSFAIL (severe) if failure
Notes
	If a failure occurs, the object's instance data will not be 
	modified
*/

message GRgetprismsize(IGRlong *msg; IGRshort *matrix_type; 
	IGRmatrix matrix; IGRlong *size);
/*
Abstract
	This method returns the size in bytes of the curve prism
	geometry of the object.
Arguments
     	*mat_type	IGRshort	type of matrix
     	matrix 	 	IGRmatrix	environment matrix
	*msg	  	IGRlong	 	return code
     	*size	  	IGRlong	 	size of geometry in bytes.
Return Values
	MSSUCC - successful
	MSFAIL - failure due to storage allocation.
*/

message GRmodify_height(IGRlong *msg; struct GRmd_env *md_env;
	struct GRparms *parms; IGRpoint point; struct IGRline *boreline);
/*
Abstract 	
	This method modifies the height of the curve prism of a clipping
	polygon.

Arguments
     *md_env 	   GRmd_env	environment information
     *vert_loc	   GRparms	  locates the appropriate vertex 
     point	   IGRpoint	  point to identify face to modify
     *boreline	   IGRline	  determines the new height
     *msg	   IGRlong	 completion code
Return Values
    - MSSUCC if successful
    - MSFAIL (severe) if failure
Notes 
     This method only modifies the height of the prism, if you 
     want to modify the prism face in the local x-y direction
     use GRmodify.

*/

message GRcpupdrtree ( IGRlong *msg; IGRdouble *range;struct IGRcv_prism *prism;
                       struct GRmd_env *md_env; IGRboolean add_rtree);
/*

Abstract
   This message will update the range of the clipping polygon in the R-tree.
   The input curve prism geometry will be posted to the curve prism
   representing the clipping polygon. If the add_rtree is TRUE then the
   clipping polygon will be added to the R-tree with the new range, else
   the clipping polygon will be deleted from the R-tree.

Arguments
    *msg      IGRlong            completion code
    *range    IGRdouble          range to be added to the R-tree
    *prism    IGRcv_prism        curve prism geometry
    *md_env   struct GRmd_env    object's module environment
    add_rtree IGRboolean         R-tree flag, TRUE for add to R-tree
                                 FALSE for remove from R-tree

Return values
     - MSSUCC if successful
     - MSFAIL if failure

*/


override GRgenabsg, GRpostabsg, GRxform, GRmodify, GRinsvertex,
	GRdelvertex, GRconstruct, GRptproject, GRlnproject,
	GRdelete, GRdisyourself, GRcopy, GRgetobjinfo, 
	GRclip,	GRapprojpt, GRclipto, GRdetplane, GRgeomprops, 
	GRplotyourself,GRgetrang,GRprismrel,GRaddwrng,GRremwrng,
	GRcptform,GRkeypoint,GRlocate,GRgetgeom,GRgetsize,
	GRanalyze_element;

/*
Motivation
	The motivation for all the overrides is to deal with the 
	curve prism geometry type of the curve prism.
*/

end specification GRclippoly;
