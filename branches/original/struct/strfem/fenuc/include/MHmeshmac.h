#ifndef MHmeshmac_include
#define MHmeshmac_include

#include "APdef.h"

/*----------------------------------------------------------------------------*/
/* Doc: fe$create_auto_mesh

   Abstract:
	This macro will mesh a surface, composite surface, solid, or
	non-manifold part.  The part can also be a group or set of
	these objects.

   Arguments:
	long			*msg		o - return code

	struct GRlc_info	*part		i - part to mesh

	struct MHmeshing_info	*mesh_info	i - elem size, type, gamma
						    (see MHmsdef.h)

	MHmesh_const_list	*mesh_list	o - optional list of meshes
						    created

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation

*/
/* *****************************H H H H H******************************* */

extern long MHcreate_auto_mesh ();

#omdef	fe$create_auto_mesh( msg,
			     part,
			     mesh_info,
			     mesh_list = NULL )

	MHcreate_auto_mesh( (msg), (part), (mesh_info), (mesh_list) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$bilin_surf_mesh

   Abstract:
	This macro will construct a bilinear mesh given a surface, the
	number of elements in the u and v directions and the element type.
	A bilinear mesh can be constructed by giving 4 edges without a
	reference surface, 4 edges with a reference surface, or only a
	reference surface.  In the last case, the natural boundaries of the
	surface will be used and the number of elements in the u and v
	directions must be input.  If edges are specified, edges[0]is
	opposite edges[1] and edges[2]is opposite edges[3].  Opposite
	edges must have the same number of nodes.

   Arguments:
	struct IGRpolyline	edges[4]	i - edges of bilinear mesh

	struct IGRbsp_surface	*sfgeom 	i - reference surface geometry to mesh

	int			num_elem[2]	i - number of elements in u and v
					    	    directions on surface ( sfgeom
					    	    must be specified )

	int			elem_type 	i - element type (APdef.h)

	struct GRid		*mesh 	  	o - (opt) mesh object created

	struct MHface_elmap	*face_map 	o - (opt) elem map of face elems
					    	    for input to solid meshing

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS
	
   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.
*/
/* *****************************H H H H H******************************* */

extern long MHbilin_surf_mesh ();

#omdef	fe$bilin_surf_mesh( sfgeom = NULL,
			    edges = NULL ^ 
			    num_elem = NULL,
			    elem_type = TRI3,
			    mesh = NULL,
			    face_map = NULL,
                            check_for_stop = FALSE,
                            stop = NULL  )

	MHbilin_surf_mesh( (edges), (sfgeom), (num_elem), (elem_type),
				(mesh), (face_map), (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$proj_single_edge

   Abstract:
	This macro will construct a mapped mesh by projecting a single
	edge.

   Arguments:
	struct IGRpolyline	*edge     	i - edge to be projected

	int			num_proj  	i - number of elements in 
					    	    direction of projection

	double			vector[3] 	i - projection vector

	int			elem_type 	i - element type (APdef.h)

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS 

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern MHproject_edge_mesh ();

#omdef	fe$proj_single_edge( edge,
			     num_proj,
			     vector,
			     elem_type = TRI3,
			     mesh = NULL,
                             check_for_stop = FALSE,
                             stop = NULL  )

	MHproject_edge_mesh( (edge), (num_proj), (vector), (elem_type),
                             (mesh), (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$proj_edge_to_edge

   Abstract:
	This macro will construct a mapped mesh between two edges.

   Arguments:
	struct IGRpolyline	edges[]   	i - opposite edges of mesh

	int			num_proj  	i - number of elements between edges

	int			elem_type 	i - element type (APdef.h)

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern MHproj_between_edges ();

#omdef	fe$proj_edge_to_edge( edges,
			      num_proj,
			      elem_type = TRI3,
			      mesh = NULL,
                              check_for_stop = FALSE,
                              stop = NULL  )

	MHproj_between_edges( (edges), (num_proj), (elem_type), (mesh),
                              (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$proj_edge_along_edge

   Abstract:
	This macro will construct a mapped mesh by dragging one edge
	along a second edge.

   Arguments:
	struct IGRpolyline	edges[]   	i - two adjacent edges of mesh

	int			elem_type 	i - element type (APdef.h)

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.
*/
/* *****************************H H H H H******************************* */

extern MHproj_edge_along_edge ();

#omdef	fe$proj_edge_along_edge( edges,
				 elem_type = TRI3,
				 mesh = NULL,
                                 check_for_stop = FALSE,
                                 stop = NULL  )

	MHproj_edge_along_edge( (edges), (elem_type), (mesh),
                                (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$rotate_edge

   Abstract:
	This macro will construct a mapped mesh by rotating a single
	edge about an axis by a specified angle

   Arguments:
	struct IGRpolyline	*edge     	i - edge to be projected

	int			num_rot   	i - number of elements in 
					    	    direction of rotation

	double			axis[6]   	i - rotation axis x1,y1,z1,x2,y2,z2

	double			degree    	i - rotation angle in degrees

	int			elem_type 	i - element type (APdef.h)

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern MHrotate_edge_mesh ();

#omdef	fe$rotate_edge(	edge,
			num_rot,
			axis,
			degree,
			elem_type = TRI3,
			mesh = NULL,
                        check_for_stop = FALSE,
                        stop = NULL  )

	MHrotate_edge_mesh( (edge), (num_rot), (axis), (degree),
			    (elem_type), (mesh), (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$proj_solid_mesh

   Abstract:
	This macro will construct a solid mesh by projecting a map
	of "surface elements" along a vector

   Arguments:
	struct MHface_elmap	base_map  	i - node list and connectivity
					    	    information (see MHmsdef.h)

	int			num_proj  	i - number of elements in 
					            direction of projection

	double			vector[3] 	i - rotation axis x1,y1,z1,x2,y2,z2

	int			el_type   	i - element type as in APdef.h

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern MHproj_solid_mesh ();

#omdef	fe$proj_solid_mesh( base_map,
			    num_proj,
			    vector,
			    el_type,
			    mesh = NULL,
                            check_for_stop = FALSE,
                            stop = NULL  )

	MHproj_solid_mesh((base_map), (num_proj), (vector), (el_type), (mesh),
                          (check_for_stop), (stop) );

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$rotate_solid_mesh

   Abstract:
	This macro will construct a solid mesh by rotating a "map" of
	surface elements about an axis by a specified angle

   Arguments:
	struct MHface_elmap	base_map  	i - node list and connectivity
					    	    information (see MHmsdef.h)

	int			num_rot   	i - number of elements in 
					            direction of rotation

	double			axis[6]   	i - rotation axis x1,y1,z1,x2,y2,z2

	double			degree    	i - rotation angle in degrees

	int			el_type   	i - element type as in APdef.h

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern MHrotate_solid_mesh ();

#omdef	fe$rotate_solid_mesh( base_map,
			      num_rot,
			      axis,
			      degree,
			      el_type,
			      mesh = NULL,
                              check_for_stop = FALSE,
                              stop = NULL  )

	MHrotate_solid_mesh( (base_map), (num_rot), (axis), (degree),
				(el_type), (mesh), (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$skin_abs_solid_mesh

   Abstract:
	This macro will construct a solid mesh by dragging (skin absolute)
	a "map" of surface elements along a trace curve

   Arguments:
	struct MHface_elmap	base_map  	i - node list and connectivity
					    	    information (see MHmsdef.h)

	struct IGRpolyline	*trace	  	i - polyline define nodes on trace curve

	int			el_type   	i - element type as in APdef.h

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern MHskin_abs_solid_mesh ();

#omdef	fe$skin_abs_solid_mesh(	base_map,
				trace,
				el_type,
			        mesh = NULL,
                                check_for_stop = FALSE,
                                stop = NULL  )

	MHskin_abs_solid_mesh( (base_map), (trace), (el_type), (mesh),
                               (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$skin_rel_solid_mesh

   Abstract:
	This macro will construct a solid mesh by skinning
	a "map" of surface elements along a set of trace curves

   Arguments:
	struct MHface_elmap	base_map  	i - node list and connectivity
					    	    information (see MHmsdef.h)

	int			num_layer 	i - number of element layers along
					    	    trace curves

	int			ntrace    	i - number of trace curves

	struct IGRbsp_curve	*trace_cvs[] 	i - trace curves

	int			el_type   	i - element type as in APdef.h

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern MHskin_rel_solid_mesh ();

#omdef	fe$skin_rel_solid_mesh(	base_map,
				num_layer,
				ntrace,
				trace_cvs,
				el_type,
			        mesh = NULL,
                                check_for_stop = FALSE,
                                stop = NULL  )

	MHskin_rel_solid_mesh( (base_map), (num_layer), (ntrace), (trace_cvs),
				(el_type), (mesh), (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$face_to_face_solid_mesh

   Abstract:
	This macro will construct a solid mesh by projecting a map
	of "surface elements" along a vector

   Arguments:
	struct MHface_elmap	base_map  	i - node list and connectivity
					    	    information (see MHmsdef.h)

	struct MHface_elmap	face2_map  	i - node list and connectivity
					    	    information for face 2

	int			num_proj  	i - number of elements in 
					    	    direction of projection

	int			el_type   	i - element type as in APdef.h

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern MHface_to_face_solid_mesh ();

#omdef	fe$face_to_face_solid_mesh( base_map,
				    face2_map,
				    num_proj,
				    el_type,
			            mesh = NULL,
                                    check_for_stop = FALSE,
                                    stop = NULL  )

	MHface_to_face_solid_mesh( (base_map), (face2_map), (num_proj),
				(el_type), (mesh), (check_for_stop), (stop) );

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$trilin_surf_mesh

   Abstract:
	This macro constructs a trilinear mesh given three edges,
	an optional reference surface, and the element type.

   Arguments:
	struct IGRpolyline	edges[3]  	i - edges of trilinear mesh

	struct IGRbsp_surface	*sfgeom   	i - reference surface geometry to mesh

	int			elem_type 	i - element type (APdef.h)

	struct GRid		*mesh 	  	o - (opt) mesh object created

	struct MHface_elmap	*face_map 	o - (opt) elem map of face elems
					    	    for input to solid meshing

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern long MHtrilin_surf_mesh ();

#omdef	fe$trilin_surf_mesh( sfgeom = NULL,
			     edges,
			     elem_type,
			     mesh = NULL,
			     face_map = NULL,
                             check_for_stop = FALSE,
                             stop = NULL  )

	MHtrilin_surf_mesh( (edges), (sfgeom), (elem_type),
				(mesh), (face_map), (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$transition_layer

   Abstract:
	This macro will construct a mapped mesh between two edges.

   Arguments:
	int			nedges    	i - number of edges (2 or 4) edges 3
					    	    and 4 are optional to define
					    	    midside nodes for high order

	struct IGRpolyline	edges[]   	i - opposite edges of mesh

	struct IGRbsp_surface	*sfgeom   	i - reference surface geometry to mesh

	int			elem_type 	i - element type (APdef.h)

	struct GRid		*mesh 	  	o - (opt) mesh object created

	struct MHface_elmap	*face_map 	o - (opt) elem map of face elems
					    	    for input to solid meshing
					    	    NOTE: this map should not be used
					    	    for face to face solid transition

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern long MHtransition_layer ();

#omdef	fe$transition_layer( nedges,
			     edges,
			     sfgeom = NULL,
			     elem_type = TRI3,
			     mesh = NULL,
			     face_map = NULL,
                             check_for_stop = FALSE,
                             stop = NULL  )

	MHtransition_layer( (nedges), (edges), (sfgeom), (elem_type),
				(mesh), (face_map), (check_for_stop), (stop) )

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$face_to_face_solid_transition

   Abstract:
	This macro will construct a solid mesh by projecting a map
	of "surface elements" along a vector

   Arguments:
	struct IGRpolyline	edges[4]  	i - 4 edges of transition layer
					    	    edges[0] and [1] are on face1
					            edges[2] and [3] are the matching
					            edges on face2 respectively

	struct IGRbsp_surface	*sfgeom[2]	i - reference surface geometry to mesh

	int			num_proj  	i - number of elements in direction
					    	    of projection

	int			el_type   	i - element type as in APdef.h

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern long MHface_to_face_solid_transition ();

#omdef	fe$face_to_face_solid_transition( edges,
                                          sfgeom = NULL,
					  num_proj,
					  el_type,
					  mesh = NULL,
                                          check_for_stop = FALSE,
                                          stop = NULL  )

	MHface_to_face_solid_transition( (edges), (sfgeom), (num_proj),
				(el_type), (mesh), (check_for_stop), (stop) );

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$mesh_line_elems

   Abstract:
	This macro will construct a mesh of linear elements

   Arguments:
	struct IGRpolyline	*edge      	i - edge on which to create 
					    	    line elements

	int			el_type   	i - element type as in APdef.h

	struct GRid		*mesh 	  	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag


   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern long MHmesh_line_elems();

#omdef	fe$mesh_line_elems( edge,
			    el_type,
			    mesh = NULL,
                            check_for_stop = FALSE,
                            stop = NULL  )

	MHmesh_line_elems( (edge), (el_type), (mesh), (check_for_stop), (stop) );

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$six_face_solid_mesh

   Abstract:
	This macro will construct a solid mesh using the hyperpatch
        method to find nodes enclosed inside of six connected faces. 

   Arguments:
        struct MHface_elmap   	face_map[6]  	i - array of face maps containing
                                             	    node list and connectivity info.

	int		      	el_type      	i - element type as in APdef.h

	struct GRid	      	*mesh 	   	o - (opt) mesh object created

        int			check_for_stop  i - process the STOP sign?

        int			*stop           o - (opt) STOP sign selected flag

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
				Creation
      24 Nov 92 ret     2.2.0   added STOP sign processing for mapped meshing.

*/
/* *****************************H H H H H******************************* */

extern long MHsix_face_solid_mesh();

#omdef	fe$six_face_solid_mesh( face_map,
				el_type,
				mesh = NULL,
                                check_for_stop = FALSE,
                                stop = NULL  )

	MHsix_face_solid_mesh( (face_map), (el_type), (mesh),
                                (check_for_stop), (stop) );

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$copy_transform_mesh

   Abstract:
	This macro will copy and transform a mesh.  For mirroring a mesh
	see fe$copy_mirror_mesh.

   Arguments:
	long		num_elem		i - number of elements to copy

	struct GRid	elems[]			i - list of elements
	
	double		matrix[]		i - 4x4 transformation matrix

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      02/17/93	bwh	2.2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern long MHcopy_transform_mesh();

#omdef	fe$copy_transform_mesh( num_elem,
				elems,
				matrix  )

	MHcopy_transform_mesh( (num_elem), (elems), (matrix) );

#endomdef

/*----------------------------------------------------------------------------*/
/* Doc: fe$copy_mirror_mesh

   Abstract:
	This macro will copy and mirror a mesh.  The element normals
	are maintained in the same direction as the input elements.

   Arguments:
	long		num_elem		i - number of elements to copy

	struct GRid	elems[]			i - list of elements
	
	struct IGRplane	plane[]			i - mirror plane

   Return Status:
	1	-	SUCCESS

   Examples:

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      02/17/93	bwh	2.2.0	Creation

*/
/* *****************************H H H H H******************************* */

extern long MHcopy_mirror_mesh();

#omdef	fe$copy_mirror_mesh( num_elem,
				elems,
				plane  )

	MHcopy_mirror_mesh( (num_elem), (elems), (plane) );

#endomdef

/* *****************************H H H H H******************************* */
/* Doc: fe$free_edge_face

   Abstract:
        Displays the free edges and free faces of the mesh in the model.
	Display intersections of a solid mesh with planes. The planes
	are defined through a list of a,b,c,d defining the planes.

   Arguments:
	long			num_sec		i - Number of intersec planes

	double			*abcd  		i - list of A,B,C,D of planes

	long	 		list_cnt	i - # of grids in the list 	
						    = -1: process all	

	struct GRid		*list_grids  	i - list of grids in group	

	struct GRid		*gg_grid  	i - graphics group id	

 	struct GRsymbology	*sym		i - display_attr, level	

	struct GRid		*gragad		i - gragad to display in	

	long			temp_flg 	i - temporary display flag 	
						  0 = create permanant obj	

	long			num_el_adj_face	i - see note below  		

	long			num_el_adj_edge	i - see note below  		

	int			highlight	i - highlight flag:1=YES,0=NO

   Notes: 
	 Argument num_el_adj_face and  num_el_adj_edge indicate what 'boundary' 
	 entity to display. The following convention applies:
	 num_el_adj_face = 1 - display faces used by ONE element ONLY;
			 = 2 - display faces used by TWO elements ONLY;
			 = 3 - display faces used by ONE OR TWO elements;
			 > 4 - invalid value;
	 num_el_adj_edge = N - display edges used by N elements ONLY;

   Return Status:
	OM_S_SUCCESS	-	Success

	OM_E_NODYNMEM   -	No dynamic memory available

   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      12/16/92  Manyam   2.2.0	Creation
      09/14/93	jc	3.0	moved from FEqkmacros.h

*/
/* *****************************H H H H H******************************* */

extern long APdispfrebdy();

#omdef	fe$free_edge_face( num_sec =1,
		       abcd = NULL,
			list_cnt = -1,
			 list_grids = NULL,
			  gg_grid,
			   sym,
			    gragad = NULL,
			     temp_flg = 1,
			      num_el_adj_face = 1,
			       num_el_adj_edge = 1 ,
				highlight = 1 )

	APdispfrebdy( num_sec, abcd, list_cnt,list_grids, gg_grid, sym, gragad, 
			temp_flg, num_el_adj_face, num_el_adj_edge, highlight );
#endomdef

#endif
