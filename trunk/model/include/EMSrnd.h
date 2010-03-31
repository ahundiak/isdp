/* 
  DESCRIPTION

    Include file that declares structures, types, transient properties,
    etc., for new rounding.

  HISTORY
   
    Janaka: December 1, 1992	Additions to support Phoenix work.
    Janaka: March 31, 1992	Various comments added.
				Error sturture added.
    Inasu : ??? ??, 91		Creation.
*/

#ifndef EMSrnd_include
#define EMSrnd_include 

#ifndef EMSrndtp_include
#include "EMSrndtp.h"
#endif
/*
 * Initial guess at how many edges are at a vertex.
 */

#   define STATIC_MAX_NUM_EDGES_VTX	8


/* Every edge of a solid can be classified into ONE of the following
 * categories (see documentation on rounding for definitions).  This
 * information (together with others such as rounding radii) is used
 * to classify end vertices of the edges.
 */
	enum EMSedge_config	{

          EMSedge_undefined,         /* configuration cannot be determined
                                      */
          EMSedge_neutral,           /* Edge is neutral */
          EMSedge_neutral_convex,    /* edge is neutral and globally convex.
                                        e.g. seam edge of a cylinder seen from
                                        outside.
                                      */
          EMSedge_neutral_concave,   /* edge is neutral and globally concave.
                                        e.g. seam edge of a cylinder seen from
                                        inside (and the volume side is the
				        outside of the cylinder).
                                      */
          EMSedge_convex,            /* edge is convex */
          EMSedge_concave            /* edge is concave */
	};

/*
 * Information concerning each edge that is to be rounded is recorded
 * in an instance of the following structure.  Some of this is input
 * received from the command, and the remainder is generated.
 */
	struct EMSedge_rnd_info {
          /*
           * Round edge related information.
           */
	      GRobjid edge_id;
              /*
               * Start and stop vertex information for this edge.
               */
	          struct EMSvtx_rnd_info *start_vtx,
	  	   		         *stop_vtx;
              /*
               * Edge classification (convex, concave, neutral).
               */
	          enum EMSedge_config  edge_config;

   	      /*
	       * Various edge properties that are applicable to this edge
               * (defined in EMSprop.h).
	       */
                  IGRlong props;

              /*
               * Various options that apply to this edge (defined in
               * EMSopt.h).
               */
                  IGRushort options;
          /*
           * Information on the surface of this edge.
           */
	      GRobjid			surf_id;
	      struct IGRbsp_surface	*surf;
	      IGRdouble			surf_tol; /* Knot tolerance */

          /*
           * Information on the common surface of this edge.
           */
	      GRobjid			com_surf_id;
	      struct IGRbsp_surface	*com_surf;
	      IGRdouble			com_surf_tol; /* Knot tol: */

          /*
           * Fillet related info:
           */
              GRobjid			fill_id;
	      struct IGRbsp_surface 	*fill_surf;
              IGRdouble			fill_surf_tol;

          /*
           * Fillet iso-edge information (u=0,1)
           */

              struct IGRbsp_curve       *fill_isocvs[2];
              struct EMSdataselect      fill_isocvs_onsfs[2];

              /*
               * Rounding radii at the logical START (radius) and STOP (other_
               * radius) of the edge [in case of constant radius rounding,
               * radius == other_radius (this maintains symmetry)]
               */
	          IGRdouble	radius,
                          	other_radius;

              /*
               * Fillet's conic geometry specifier. If the option
               * 'EMS_rho_specified' is set in 'options' field, then the
               * the following rho value is interpreted.  Else, the rho
               * value used for fillet creation correspond to the kind of
               * operation (round or chamfering).
               */
                  IGRdouble	rho_value;

          /*
           * Specific information, as required by various parts of the
           * round algorithm.
           */
	      IGRchar    *more_info;
 
          /*
           * Extra-topology interaction information.
           */
              struct EMStansf_rnd_info  *tansf_rnd_info;
	};

/*
 * The classification of edges incident on a vertex is used to classify
 * each vertex (that is effected by the rounding operation) into ONE of
 * of the following categories.  Each of these vertex categories
 * determine the effect of rounding on each vertex.
 */
	enum EMSvertex_config {

	  /*
	   * 3-edge-homog vertex/ uniform radii/ rounding all edges.
	   */
	      EMSvertex_spherical_blend,

	  /*
	   * 1. 3-edge-arb vertex/ uniform or non-uniform radii/ rounding all
	   *    edges.
	   */
	      EMSvertex_3edge_rolling_ball,
            
	  /*
	   * 3-edge-arb vertex with one neutral edge, and the other two edges
	   * are of the same classification/ uniform or non-uniform rounding/
	   * rounding two edges OR
           * 4-edge-arb vertex with two neutral edges, the other two
           * edges are of the same classification, and they are both rounded.
           * The edge configuration must be some permutation of the following.
           *   neutral-convex/concave-neutral-convex/concave.
	   */
	      EMSvertex_tangent_trim,

	  /*
	   * 3-edge-arb vertex with no neutral edges/ uniform or non-uniform
	   * radii/ rounding the two edges which are of the same classification.
	   */
	      EMSvertex_2edge_cx_1edge_cv,

	  /*
	   * 1. n-edge-homog vertex/ uniform or non-uniform rounding/ number of
	   *    edges runded is equal to, or greater than one, and less than n.
	   * 2. n-edge-arb vertex/ one edge is being rounded, and its
	   *    classification, its next and previous edges classification are
	   *    of the same.
	   */
	      EMSvertex_general_trim,

	  /*
	   * n-edge-arb or n-edge-homog vertex where n > 3/ uniform or non-
	   * uniform radii/ rounding all edges.
	   */
	      EMSvertex_general_blend,

          /*
           * 3-edge arb vertex, with no neutral edges, thus one of the three
           * edges has a classification different from the other two, and that
           * single edge is been rounded.
           */
              EMSvertex_3edge_single_trim,

	  /*
	   * n-edge-arb vertex/ rounding a single edge, and the edge being
	   * rounded, its previous and its next edges are of different
	   * classifications.
	   */
	      EMSvertex_single_patch,

          /*
           * The following vertex occur during the rounding of an edge
           * that is implied by the intersection of two surfaces.
           */
              EMSvertex_open,

	  /*
	   * All other vertices.
	   */
	      EMSvertex_not_implemented 

           };

/*
 * Classification of each end vertex of each edge that is rounded is
 * instantiated into an instance of the following structure.  These
 * instances are recorded for each edge (kept as an instance of struct
 * EMSedge_rnd_info) in the fields, 'start_vtx' and 'stop_vtx'.
 */
    struct EMSvtx_rnd_info  {

        IGRpoint vtx_pt;                     /* The vertex point */

	enum   EMSvertex_config  vtx_config; /* vertex configuaration */

	/*
	 * If this vertex has been processed for rounding then it is
	 * considered to be fixed (to avoid multiple processing of a vertex).
	 */
	     IGRboolean   fixed;

	IGRint	  num_edges;         /* number of dominant edges at the vertex*/

	GRobjid   *edge_ids;         /* 
				      * Array of edge ids at the vertex.
				      * (in cyclic order)
				      */
	/*
	 * Each edge in 'edge_ids' could be an edge that is to be rounded.
	 * 'edge_infos' is an array of pointers to corresponding edge round
	 * info.  If an edge in 'edge_ids' is not rounded, then the
	 * corresponding entry in 'edge_info' is NULL.
	 */
	    struct EMSedge_rnd_info  **edge_infos;

	/*           
	 * Array of flags indicating whether this vertex is the stop
	 * of the corresponding edge in 'edge_ids'.
	 */
	    IGRboolean *edge_stops;

	/* 
	 * Array of edge configurations for each edge in 'edge_ids'.
	 */
	    enum   EMSedge_config   *edge_configs;

	/*
	 * Make an initial guess on number of edges at this vertex to be
	 * STATIC_MAX_NUM_EDGES_VTX, and allocate memory for the above edge
	 * buffers.
	 */
	    GRobjid edge_ids_mem[STATIC_MAX_NUM_EDGES_VTX];
	    struct EMSedge_rnd_info *edge_infos_mem[STATIC_MAX_NUM_EDGES_VTX];
	    IGRboolean edge_stops_mem[STATIC_MAX_NUM_EDGES_VTX];
	    enum EMSedge_config edge_configs_mem[STATIC_MAX_NUM_EDGES_VTX];

        /*
         * If an error occured at this vertex, then a description of that
         * error (ex: unexpected topology interaction).
         */
       };

/*
 * The 'command object' to 'round function' communication of the round
 * input occures as an array of instances of the following structure
 * (one per each edge).
 */
	struct EMSrnd_boundary_input {
           /*
            * The fillet is applied along this edge.
            */
               struct GRid	boundary_id;
           /*
            * Fillet's conic characteristic (also see 'props').
            */
               struct EMSvalue_info	rho_value,
           /*
            * Start (radius) and stop (other_radius) radii of fillet, where
            * start/stop corresponds to the logical start and end of this edge
            * (also see 'props').
            */
			                radius,
			                other_radius;
           /*
            * Various (transient) properties (defined in EMSprop.h).
            * The valid ones are:
            *    EMSfillet_is_variable_radius : If this is set, then both,
            *       'radius' and 'other_radius' are interpreted.
            *       Else, only 'radius' is interpreted.
            *    EMSrnd_edge_code : This bit is used to group collections
            *       of edges within the array of edges generated by the
            *       command object.  It is to toggle among sequencial groups
            *       of edges.
            */
               IGRushort	props;

           /* Various options (defined in EMSopt.h).
            *    EMSfillet_rho_specified : If set, then interprit 'rho_value'.
            *       Else use rho for circular fillet.  Of course, if the
            *       operation is chamfering, this bit has no interpretation,
            *       and the rho value will be that appropriate to a chamfer.
            *    EMSblend_edge_start : If set, force a vertex classification
            *        of EMSvertex_general_blend, else go through normal
            *        classification procedure for start end of edge.
            *    EMSblend_edge_stop : As above, for the stop end of edge.
            */
               IGRushort	options;
        };

/*
 * Round failures are recorded per edge basis.
 *  . Failure on fillet creation.
 *  . Failure on processing of one or both of edge end vertices.
 *  . Forced failure as requested by the user (through the specification
 *    of option EMS_RND_DONOT_MODIFY_SOLID, defined in EMSopt.h).
 */
	enum EMSrnd_failure_kind {
                EMSrnd_vtx_failure,
                EMSrnd_fillet_failure,
                EMSrnd_forced_failure
        };

/*
 * Errors occuring within the rounding algorithm are collected into
 * an instance of the following struct and passed back to the command
 * object.
 */
	struct EMSrnd_error   {

          /*
           * On EMSrnd_vtx_failure, and on EMSrnd_fillet_failure.
	   *  The composite surface containing all the fillets and patches
           *  generated during the rounding operation.  Only those patches
           *  generated at vertices where rounding succeded will be included.
           *  Fillet ends at vertices where rounding failed, will be in their
           *  natural state.
           *
           * On EMSrnd_forced_failue.
           *  The composite surface containing all the completed fillets and
           *  and patches.
 	   */
	      struct GRid fill_patch_compsf;
          /*
           * Array of edges where rounding failed. Clearly, this information
           * is valid only in the case of !EMSrnd_forced_faliure.
           */
	      IGRint			num_fail_edges;
	      GRobjid			*fail_edges;
              enum EMSrnd_failure_kind  *kind_of_failure;
              struct EMSvtx_rnd_info	**start_vtx,
                                        **stop_vtx;
	};


/* -------------------- General blend related stuff ----------------------- */


/* Some transient (thus not defined in EMSprop.h) properties used within
 * the round general blend.
 */

/* Blend curve properties.
 *
 * .... .... .... ...x  An attempt has been made to construct a legal
 *                      transition curve without success.
 * .... .... .... ..x.	No attempt has been made to construct the
 *                      transition curve.
 * .... .... .... .x..	A transition curve exists.
 * .... .... .... x...	The transition is from a fillet iso, to the round
 *                      vertex.
 * .... .... ...x ....	The transition is from the round vertex, to a
 *                      fillet iso.
 */

# define  EMSrnd_bln_trans_cv_undefined		0x1
# define  EMSrnd_bln_trans_cv_unknown		0x2
# define  EMSrnd_bln_trans_cv_exists 		0x4
# define  EMSrnd_bln_trans_cv_to_rnd_vtx	0x8
# define  EMSrnd_bln_trans_cv_from_rnd_vtx	0x10
# define  EMSrnd_bln_trans_cv_extracted_iso_curve 0x01
# define  EMSrnd_fit_bsp_curve 0x02


/* Option for blend curve trimming. */

# define  EMSrnd_bln_cv_donot_trim		0x1 


enum STATUS_OF_SETBACK_POINT    {setback_pt_defined, setback_pt_transient,
                                 setback_pt_undefined};
enum BLEND_CURVE_TYPE_ON_FILLET	{blend_curve_iso, blend_curve_int_with_plane,
                                 blend_curve_undefined};


/* The following stores the blend related information such as set back
 * points, per edge.  Note that each edge may be rounded, or it may be not.
 * There are some fields in the struct that has two locations for the second
 * index.  Typically these are used to store the (u,v) values pertaining to
 * the fillet associated with the edge.  For edges that do not have a fillet,
 * only the first index (at the second index of two dimensional arrays) is
 * valid.  In such cases, the value of that location is interpreted w.r.t.
 * to the edge. The first index of arrays, indexes over the two set back
 * points on each edge or fillet (i.e. FIRST and SECOND).
 *
 * USAGE: Array of instances for the edges at a round vertex (where the
 *        round solution is a general blend).  There is a one-to-one
 *        correspondence between this array, and the arrays inside
 *        EMSvtx_rnd_info, for that round vertex.
 */
   struct EMSedge_blend_info {

    /* Indicator for recording whether valid values are present for each
     * of the two setback points.
     */
       enum STATUS_OF_SETBACK_POINT	setback_pt_stat[2];
   
    /* If the set back point has a dependant set back point on another
     * edge (such is the case in fillet-fillet), then the index of the
     * dependant node (a modification to one must be propergated to the
     * other in order to obtain a reasonable blend curve).
     */
       IGRint counter_part[2];

    /* If this edge is rounded, how to construct the blend curve on the
     * fillet.
     */
       enum BLEND_CURVE_TYPE_ON_FILLET	blend_cv_type;
   
    /* If the edge is rounded, the set back points are on the fillet,
     * else they are on the two edges.
     */
        IGRdouble	setback_pts_uv[2][2];
        IGRpoint	setback_pts_xyz[2];

    IGRboolean	setback_pts_refined[2];

    IGRpoint	rnd_end_vtx[2];
    IGRboolean  rnd_end_stop[2];
    IGRboolean	FIRST_is_dominant;
    IGRdouble   default_setback;

    IGRint	fillet_int_iso[2];    /* u0 or u1 for FIRST and SECOND.
                                       * UNDEFINED for edges that are not
                                       * rounded.
                                       */

    GRobjid	ed_ids[2];	      /* FIRST and the SECOND edges in the
                                       * cyclic order of vertex edges.
                                       */

    /* The following stores the properties of blend transition curves
     * from this edge (or its fillets isos), to its neighboring edges
     * (or their fillets).  The legal properties are: (defined within
     * this file due to the transient nature of the properties)
     *
     *  EMSrnd_bln_trans_cv_undefined
     *  EMSrnd_bln_trans_cv_unknown  
     *  EMSrnd_bln_trans_cv_exists
     *  EMSrnd_bln_trans_cv_to_rnd_vtx
     *  EMSrnd_bln_trans_cv_from_rnd_vtx
     *
     * As usual, the array is index FIRST and SECOND in the cyclic order
     * of vertex edges.
     */
       IGRushort	bln_cv_props[2];
   };





/* This aggregates the blend curve related information (recall that
 * these can be either on fillets, or on model surfaces).
 * There are as many instances of this aggregate as the number of
 * blend curves.  Each blend bounding curve has three constituents.
 * (1) A uv curve (uv1) on a fillet, or on a model surface.
 * (2) A uv curve (uv2) on a constituent of the blend composite.
 * (3) An xyz space curve representing the model space geometry of
 *     preceding two uv curves.
 * This aggregate is primarily concerned with information pertaining
 * to (1) and (3).
 */
   struct EMSrnd_blend_curve_info {
            struct EMSdataselect	uv1;

            /* The blend is generated such that it is tangent
             * to the surface on which uv1 lies on (either a
             * model surface or a fillet).
             */
               struct IGRbsp_surface	*tangent_sf_geom;
               GRobjid			tangent_sf_id;

            /* If this a blend on a fillet, then that edge's edge info.
             * Else it will be NULL.
             */
               struct EMSedge_rnd_info	*ed_info;
            
            /* Logical orientation of 'uv1' on 'tangent_sf_geom' (the curve
             * as stored in 'uv1' is oriented in the cyclic ordering
             * defined by the edges at the round vertex).  It is IGRint since
             * unknown has to be communicated (IGRboolean should have been
             * tri state: TRUE, FALSE, UNKNOWN).
             */
               IGRint  uv1_orientation; /* w.r.t. to present parameterization
                                         * of 'uv1'.
                                         */

            /* The xyz space component of this bound curve. */
               struct IGRbsp_curve	*xyz_geom;

            /* Blend curve properties (as defined in EMSrnd.h) These are
             * only applicable to those on model surfaces. For those on
             * fillets, it will be undefined.
             * Legal properties are:
             *  EMSrnd_bln_trans_cv_to_rnd_vtx
             *  EMSrnd_bln_trans_cv_from_rnd_vtx
             *  EMSrnd_bln_trans_cv_undefined
             */
               IGRushort		props;

            /* Incident information for uv1 (FIRST is at the parametric
             * start of the uv curve, and SECOND is at the parametric end
             * of the uv curve.  These two nodes are NOT linked together
             * (since a split of uv1 may be required).
             */
               struct EMSsfintedpar	*incident_info[2];


            struct EMSrnd_blend_curve_info	*next, *prev;
   };

#endif
