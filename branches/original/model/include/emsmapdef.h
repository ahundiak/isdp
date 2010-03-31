/* Following options are used in the process of mapping an xyz curve
   into surface parametric space.
*/

# ifndef emsmapdef_include
# define emsmapdef_include

#define  EMMapBnd_WantBadCurves		0x0001 /* Accept curves with some
						  points outside surface
						*/
						
#define  EMMapBnd_WantStatMsg		0x0002 /* Want status messages */

#define  EMMapBnd_StrokeIfNeeded	0x0004 /* Stroke only if needed */

#define	 EMMapBnd_StrokeAlways		0x0008 /* Stroke unconditionally
						*/
						
#define  EMMapBnd_NoStroke		0x0010 /* Stroke is NO NO */

#define  EMMapBnd_NoClip		0x0020 /* Avoid Clipping */

#define	 EMMapBnd_NoTraceClipFix	0x0040 /* Avoid Tracing, Clipping, 
						  Fixing and Validation.*/
						
#define	 EMMapBnd_NoValidate		0x0080 /* Avoid Validation */
						
#define  EMMapBnd_NoCurveType		0x0100 /* I do not care about curve
						  types/edge types
						*/

#define EMMapBnd_NoFixing		0x0200  /* When creating loops in
						   parametric space, from
						   model space data, no
						   fixing of data should be
						   attempted(like removing
						   overlaps, collapsed points
						   etc).
						*/
						
#define EMMapBnd_SurfIsPlane		0x0400  /* This bit indicates whether
						   the concerned surface
						   is a plane or not. This
						   info when known can be
						   conveyed via this bit
						   for optimisation during
						   xyz to uv mapping.
						*/

#define EMMapBnd_NoRmvColEds        	0x0800 	/* Do not remove the boundaries
                           			   that collapse onto natural 
						   edges while fixing the 
						   data. */
						
#define EMMapBnd_ClipBdryArea        	0x1000 	/* When performing clipping,
						   treat the loopset boundary
						   as area. Relevant only if
						   NoClip is off. */
						
#define EMMapBnd_RmvDegenCvs        	0x2000 	/* Remove any degenerate curves
                           			   that remain/result after
						   clipping. Relevant only if
						   NoClip is off. */
						
						
/* Following structure is used to return the edge ids produced from input
   curves.
*/

struct EMSgetlp_edgeinfo
{
  GRobjid	edgeid;		/* Objid of the edge */
  IGRchar	*info;	
};
				/* Pointer pointing to any information. This
				   pointer is simply transferred from the
				   input list. If the caller does not pass
				   the required input this will be NULL.
				   For further details see the explaination
				   of the arguments in
				   'src_funk/misc/EMgetlpimp.I'.
				*/

struct EMSgetlp_badcrvinfo
{
 IGRint		num;
 IGRlong	*bad_indices;
};

struct EMSgetlp_output
{
 IGRint		num_objs;
 GRobjid	*objs; 
};

struct EMSgetlp_planar_info
{
 IGRuchar		*edge_types;
 IGRchar			**curve_info;
 struct EMSgetlp_edgeinfo	***out_edges;
 IGRint				**num_out_edges;
};

/*
 * This structure was created for the Trim Composite functionality. This is
 * to take care of the curves that overlap the boundary edges of surfaces
 * to be trimmed.  The max number of surfaces onto which such curves can get
 * mapped onto, is, at the most, two.
 */

struct EMScvsfs {
       struct GRid surface;
       IGRshort location;
       };

# endif
