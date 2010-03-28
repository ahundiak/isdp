/*
ABSTRACT : 

 The class ASmodbsp is a subclass of ASbspline and ASmodifier . All these 
 classes describe bspline modifications witch only affect the display off 
 the bspline and not the geometry.


CHANGE HISTORY
	
  D.Payannet   14 apr  87 : design date
*/

class specification ASmodbsp (0:1) of ASbspline,ASmodifier;

/* Declared messages */


message ASbs_extend
  (
  struct    GRid    bsp_to_ext;  /* IN     The B_spline to extend             */
  struct    GRid    *parent;     /* IN     All the parents for modifications  */
  struct    GRmd_env *md_env;    /* IN     Informations about the environment */
  struct    GRid    *segment     /* OUT   				      */
  );
/*
  DESCRIPTION

  Extend the curve (bsp_to_ext) to the parent points (in *parent).
*/




message ASbs_part_del
  (
  struct    GRid    bsp_to_split;/* IN     The B_spline to split              */
  struct    GRid    *parent;     /* IN     All the parents for modifications  */
  struct    GRmd_env *md_env;    /* IN     Informations about the environment */
  struct    GRid    *segment;    /* OUT   				      */
  IGRint            *nseg   	 /* OUT   				      */
  );
/*
  DESCRIPTION

  With the array of modifications (*parents), give the array of begin and end 
  points  of the partial delete (beg_points[], end_points[]), return the number
  of partial delete (*npt).
*/


message make_seg
  (
  struct GRmd_env *md_env;      /* IN     Information about the environment  */
  struct GRid list_par[];        /* IN     List of the parents of the modifier*/
  struct GRid *segment;
  IGRint *nseg;
  );


 override GRvg;

/* Overriden messages for the ASmodbsp subclass */

override
  NDplace,
  NDparent_deleted,
  GRlocate_owner,
  ACbecome_macro,
  NDcompute_node,
  NDprint,
  GRendpts,
  GRgetobjinfo;

end specification ASmodbsp;
