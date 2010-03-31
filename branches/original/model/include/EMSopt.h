/*
 * This file contains the various defined constants used as
 * options.

HISTORY
13 Oct 95   SAM Added EMS_GETB_DOMINANT
17 Jun 94   WBC Added EMS_OPT_CREATE_HRZ_CVS.
05 Jan 93  skar Added EMSEdgCrv_DONOT_FIT_BSP_CURVE option.
29 Dec 93 ashok Added EMExtPrj_NoClip and EMExtPrj_WantSingleOut
27 Sep 93   sam Added EMS_opt_offsetS_remove_opensfs.
20 Jun 92 ashok Added EMS_opt_mklp_ConnectAtLastIndex
07 Jul 93   WBC Added DISPLAY_HRZ_EDGES for EMdisplay.
17 Jun 93   WBC Added EMS_OPT_ALL_HORIZON for EMget_graphics_edges and
                      EMS_CREATE_MSCS and EMS_CREATE_POINTERS for
                      EFmake_os_read_only_assoc.
02 Nov 92Janaka Added EMS_RND_CHECK_CURV_PROB
10 Jul 92  Jack Added EMS_OPT_NONTAN_NONDEG for EMget_edges.
03 Mar 92  Jack Added EMS_OPT_NONDEG_NONTANSEAM for EMget_edges.
20 Jan 92   AIC Added EMS_CHECK_SEAM_TANGENCY.
11 Jan 92   AIC Added EMS_OPT_ATNKOTS_NOTCUSPS.
17 Sep 91  Jack Added EMS_OPT_ONLY_CUSP option.  
26 Aug 91   Pai Added EMS_GETB_REDUCEDATA option for stroked edges. 
13 Aug 91  Jack Added EMS_OPT_DELETE_HRZ and changed value for
                EMS_OPT_NO_DIS from 0x12 to 0x10. 
23 JUL 1991 SCW Added option for EMget_graphics_edges, EMS_OPT_NO_DIS.
02 Jul 91  Jack Added an option for EMget_graphics_edges, EMS_OPT_CREATE.
13 Jun 91  Jack Added options for EMget_graphics_edges.
08 Dec 1988 SM	Added options for EMtoggle_type method (EMTogType_..)
08 Aug 1988 AIC Added EMprofile and EMpartingLines options.
20 Jul 1988 AIC Added EMS_OPT_ATCUSPS.
20 Jun 1988 SAM Added #defined for surface changes: CONSTRUCTIONAL,
                GEOMETRICAL and TOPOLOGICAL.
10 Jun 1988 jBk Started option list for surface offset.
?? ??? 198? ??? Creation.
 */
# ifndef EMSopt_include
# define EMSopt_include 1

/*
 * Set properties options
 */
# define EMS_O_OFF      0
# define EMS_O_ON       1
# define EMS_O_TOGGLE   2
# define EMS_O_SET      3

/*
 * Changes to surface
*/
#define CONSTRUCTIONAL 0
#define GEOMETRICAL    1
#define TOPOLOGICAL    2
#define POLYGON_TOGGLE 3

/*
 * Following are the operations which can be done on a valid
 * looptree.
 */
# define  ADD_CHILD     0
# define  DEL_CHILD     1
# define  CHG_PARENT    2
# define  DELETE        3
# define  EXTRACT       4

/*
 * Pack options
 */
# define EMS_PACK_ALL       0
# define EMS_PACK_LOOP      1
# define EMS_PACK_FACE      2

/*
 * General options
 */
# define EMS_OPT_ALL                    0
# define EMS_OPT_OPEN                   1
# define EMS_OPT_CLOSED                 2
# define EMS_OPT_SPLIT                  3
# define EMS_OPT_UNSPLIT                4
# define EMS_OPT_UNKNOWN                5
# define EMS_OPT_ALL_WITH_FEATURES      6
# define EMS_OPT_FEATURES               7
# define EMS_OPT_CONNECTABLE            8
# define EMS_OPT_OLD                    9
# define EMS_OPT_OLD_CHILDREN           10
# define EMS_OPT_NATURAL                11
# define EMS_OPT_NATURAL_NONDEG         12
# define EMS_OPT_NONDEG_NONSEAM         13
# define EMS_OPT_CLOOP                  16
# define EMS_OPT_PLOOP                  17
# define EMS_OPT_STITCHED               18
# define EMS_OPT_NON_DEG_SEAM_XYZCLSD   19
# define EMS_OPT_SEAM                   20
# define EMS_OPT_NON_DEG_STITCHED       21
# define EMS_OPT_NAT_LOC0               22
# define EMS_OPT_NAT_LOC1               23
# define EMS_OPT_NAT_LOC2               24
# define EMS_OPT_NAT_LOC3               25
# define EMS_OPT_ACTIVE	                26
# define EMS_OPT_NONDEG                 27
# define EMS_OPT_STITCHED_ALL		28 
# define EMS_OPT_NONDEG_NONTANSEAM      29
# define EMS_OPT_NONTAN_NONDEG          30

/*
 * Test options used during make natural boundary.
 */
# define EMS_TEST_DEGENERATE    0x01
# define EMS_TEST_XYZ_CLOSED    0x02

/*
 * Options for making a copy a given boundary element or
 * elements.
 */
# define EMS_COPY_XYZ               0x01 /*Make the boundary element with it's 
					 model space geometry. Else use the
					 paramteric space geometry itself. If 
					 the model-space geometry is used, the 
					 copied edge is always connected on the
    				         assoc channel.*/

					
# define EMS_COPY_ONCOMMON          0x02 /*Connect the edge with its copy 
					   on the common edge channel. If set,
                          		   the caller has to make sure that the
					   edge(s) copied don't have any 
					   existing common edge connections.*/
					
# define EMS_COPY_PRIMEDGE          0x04 /*A partedge is copied into an edge of
 					   a primitive type - EMSlinedgeor
					   EMSbsedge. */
					
# define EMS_COPY_INTO_DUMMYEDGE    0x08 /*The copy is made into a dummy-edge.
					   With EMS_COPY_XYZ on, this
					   bit is ignored.*/
					
# define EMS_COPY_NOMSC		    0x10 /*If the existing edge has a MSC
					   do not create one for the copy.
			  		   If EMS_COPY_XYZ is on, this option 
					   is always implied.*/

# define EMS_COPY_IGNORECOMMON	    0x20 /*The existing edges common edge 
					   connection is ignored for all 
					   purposes.*/


# define EMS_COPY_ACTIVETOPOLOGY    0x40 /*Copy only the active topology. A
					   partedge is copied into a primitive
					   edge, except for a part natural
				 	   edge, in which case only the active 
					   partedge and its primitive natural 
					   edge are copied and the copies 
					   connected. Thus except for a part 
					   natural edge, the effect of this 
					   option is same as EMS_COPY_PRIMEDGE.
					 */


/*
 * Options for point location
 */
# define EMS_PTLOC_BOXCHECK     0x01
                                /*
                                 * A box check should be performed or not.
                                 * If a trivial determination is made
                                 * using box check then the information
                                 * in the structure EMSlocated_edge is not
                                 * returned. If this info is desired this
                                 * option should not be specified.
                                 */
                                
# define EMS_PTLOC_ACTLOOP      0x02
                                /*
                                 * Only active loops should be considered
                                 * for location. If an inactive loop is
                                 * encountered in the loopset it flagged
                                 * as an error.
                                 */
                                
# define EMS_PTLOC_LS_INFINITE  0x04
                                /* This option indicates that the loopset
                                 * should be considered infinite for
                                 * classifying a point outside the 
                                 * outermost loop(s). If the external
                                 * loops are P loops then such a point
                                 * is classifed as EMS_L_INHOLE. If
                                 * external loops are C loops then
                                 * such a point is classified as
                                 * INAREA. If this option is not
                                 * set then point outside the outermost
                                 * loop is classified as EMS_L_UNKNWN.
                                 * This option is used only for a loopset
                                 * point location.
                                 */

# define EMS_PTLOC_USECHTTOL    0x08
                                /*
                                 * This option implies that whereever 
                                 * applicable transform the uv-basis-tolerance
                                 * to chord-height and use it instead. The
                                 * transformation is based on the ratio of
                                 * the current model-space basis-tol to
                                 * the model-space chord-height-tol.
                                 * Example: In the point-location method
                                 * of a stroked-out edge or a linear edge.
                                 */
                                
# define EMS_PTLOC_INCHTTOL    0x10
                                /*
                                 * This option implies that the input
                                 * tolerance is uv-cht-tolerance.
                                 */
                                
# define EMS_PTLOC_NOLOOPTYPE  0x20
				 /* Loop type should not be used for resolving
				  any ambiguity. The reason for this
				  could be that the point location method
				  is being used to conclude the loop type
				  hence the existing loop type is still
				  uninitialized.
				 */

# define EMS_PTLOC_CLOSEST_EDGE	0x40
				  /* By default the edge information returned
				     when the message is sent to the loopset
				     pertains to the nearest edge in the
				     innermost loop INSIDE which the input
				     point lies. This option however requests
				     the absolute nearest edge in the loopset
				     regardless of whether the input point
				     was inside or outside the loop of that 
				     edge. The algorithm may make use of
				     any edge, but the the information returned
				     about, will be the nearest. This option
				     is valid only for EMSloopset.EMpt_location
				  */
				
# define EMS_PTLOC_XYZ_ONEDGE	0x80
                                  /* The check for whether the input point
                                     is on-edge or on-vertex is done w.r.t.
                                     the model-space geometry of the edge.
                                  */
/*
 * Options for modifying the edges of a loop.
 */
# define EMS_INS_AFTER             1       
# define EMS_INS_BEFORE            2
# define EMS_INS_REPLACE           3
# define EMS_INS_ATBEGIN           4
# define EMS_INS_ATEND             5
# define EMS_DEL_EDGE_RESTORE_LOOP 6


/*
 * DPR undo options.
 */
# define EMS_UNDO_DELETE          0x0001
# define EMS_UNDO_SAVE            0x0002
# define EMS_GET_ACTIVE_STATES    0x0004
# define EMS_TEMP_OP              0x0008
# define EMS_DO_DISPLAY           0x0010
# define EMS_DONT_REDRAW          0x0020
# define EMS_DELETE_DPR           0x0040
# define EMS_DONT_REEX            0x0080
# define EMS_UNDO_DONTDELME       0x0100
# define EMS_DISCONNECT_TOP       0x0200
# define EMS_UNDO_DONTCLEANOWN    0x0400
# define EMS_UNDO_DONTDISCONCOMPS 0x0800
# define EMS_UNDO_SENDSTOREKEY    0x1000
# define EMS_TEMP_UNDO            (EMS_TEMP_OP | EMS_UNDO_SAVE)

/*
 * DPR add options.
 */
# define EMS_DPR_ADD             0x001
# define EMS_DPR_INSERT          0x002

#define EMonly_If_Dominant       0x001

/*
 * Topology transformation options
 */
# define EMS_TF_TRANSFORM_NE     0x001
# define EMS_TF_NO_PE_TRANSFORM  0x002

/*
 * Intended as generic options. Currently
 * used in deleting duplicating intersections -
 * whether first, second or both.
 */
# define EMS_O_First            0x01
# define EMS_O_Second           0x02
# define EMS_O_Start            0x04
# define EMS_O_Stop             0x08
# define EMS_O_Internal         0x10
# define EMS_O_Debug		0x20
# define EMS_O_Noop		0x40
# define EMS_O_Continue		0x80
# define EMS_O_Delete		0x100
# define EMS_O_Incremental	0x200
# define EMS_O_Display		0x400
# define EMS_O_Undo		0x800
# define EMS_O_Retry		0x1000
# define EMS_O_Global		0x2000
# define EMS_O_Majority		0x4000
# define EMS_O_External		0x8000

/*
 * Make general solid options
 */
# define EMS_ASK_CONVERT    0x1
                            /*
                             * Ask user if composite sf should be
                             * converted to a solid.
                             */

# define EMS_GOOD_ORIENT    0x2
                            /*
                             * Inform that composite surface is already 
                             * oriented correctly.
                             */

# define EMS_CHECK_CLOSURE  0x4 
                            /*
                             * Check composite object for closure and 
                             * hilite all unconnected edges.
                             */
/*
 * Insert points options
 */

# define EMS_O_No_SfCheck     0x01
# define EMS_O_AckOnSf_Flag   0x02

/*
 * The following options are used in stitching.
 */

# define EMSstitch_TopEdge		0x01
# define EMSstitch_InternalValidation	0x02
# define EMSstitch_InvestigateMatch	0x04
# define EMSstitch_MatchTolerance	0x08
# define EMSstitch_NoMoveSurfs		0x10
# define EMSstitch_NoOrientSurfs	0x20
# define EMSstitch_IgnoreGap		0x40
# define EMSstitch_NoRangeCheck		0x80
# define EMSstitch_IgnoreOrientError    0x100

/*
 * The following options are used by EMSsfstitch.EMmake_comp method.
 */
# define EMSmakecs_CreateShell		0x01	/* When only one  component
						   is input and it has no
						   stitchable edges, create
						   a null stitch state. Without
						   this option EMS_I_Fail is
						   returned and no stitch
						   state is created.
						*/
# define EMSmakecs_FineToCoarseTol	0x02	/* When stitching many surfaces
				                   make multiple passes with
						   increasingly coarser 
						   tolerances.
						*/

#define EMSmakecs_SliverProcessing	0x04    /* Used Internally */

#define EMSmakecs_SpecialProcessing	0x08    /* Use special processing
                                                   algorithm since there
                                                   may exist orientation
                                                   problems because of sliver
                                                   surfaces. This option
                                                   will be automatically
                                                   invoked if problems are
                                                   detected, unless this
                                                   behavior is explicitly
                                                   supressed by the following
                                                   option. Setting this option
                                                   ALWAYS will make even
                                                   a typical case inefficient.
                                                 */
#define EMSmakecs_NoSpecialProcessing  0x10      /* No special processing under
                                                    any circumstances. Caller
                                                    takes the risk.
                                                 */

/*
 * The following options are used in overlap validation.
 */

# define EMSvalovlap_WriteSamples	0x01
# define EMSvalovlap_WriteSummary	0x02
# define EMSvalovlap_DisplayMisses	0x04
# define EMSvalovlap_TextMisses		0x08
# define EMSvalovlap_WriteMissSummary	0x10


/*
 * The following options are used in EMleinit
 */
#define  EMSleinit_NoIsoCheck		0x01 /* Do not test the geometry
						for being iso.*/
#define  EMSleinit_NoClosureCheck	0x02 /* Do not check the closure
						of the geometry(uv
						closure).*/
#define  EMSleinit_IgnoreProps		0x04 /* Do not initialize props */
#define  EMSleinit_IgnoreCurveType	0x08 /* Do not initialize cuve type*/
#define  EMSleinit_SnapToUvLimits	0x10 /* Check the points for being
						within the uv range
						(0,0) to (1, 1). If some
						point is outside the range
						but within tolerance
						snap it to the appropriate
						boundary. */
						
/* The following defined constants are the symbologies to which bad surfaces
   are optionaly set during validation. For the options see below.

   SM		11-Aug-89
*/
#define EMSvalidateBadSurfWeight	5
#define EMSvalidateBadSurfLevel		1023

/*
 * The following options are used in topology validation
 * 
 * History
 *   SM		23-Jun-89	Changed option names from 'EMS_VAL..'. Added
				new option EMSvalidateAutoCorrect.
				
 */
# define EMSvalidateSolid      0x0001    /* validate solid properties */
# define EMSvalidateEdgeMatch  0x0002    /* validate edge-matches     */
# define EMSvalidateAutoCorrect 0x0004   /* perform all possible auto 
					  corrections.
					  Note that the model may contain
					  defects which were beyond auto
					  corrections.
				       */
#define EMSvalidateNoPrintDefects 0x0008   /* Do not Print defects during
					      auto correction.
 					   */
#define EMSvalidateWeightBadSurfs 0x0010  /* Increase the bad surface's
					  weights to EMSvalidateBadSurfWeight.
					  A bad surface is
					  one on which defects exist after
					  auto correction or user choosing
					  not to correct them as they are
					  reported in the manual mode.
					  */
#define EMSvalidateChangeBadSurfLevel 0x0020
#define EMSvalidateNonSubEdge	   0x0040  /* degeneracy and common edge
					   match tests for edge and
					   common edge to be done only for
					   non subordinate edges. This is
					   to avoid doing these tests from
					   both edges in a composite.
					   */
					
/*
 * The following options are used in bs-props validation
 */
# define EMS_VAL_PLANAR      0x01    /* validate planarity */
# define EMS_VAL_PHY_CLSD    0x02    /* validate physically clsd props */

/*
 * The following options are used to generate different types of
 * default rule line tables. Non-negative integers indicate even
 * spacing in parametric space.
 */
# define EMS_OPT_ATKNOTS            -1
# define EMS_OPT_CONIC              -2
# define EMS_OPT_ATCUSPS            -3
# define EMS_OPT_ATKNOTS_NOTCUSPS   -4

/*
    The following option(s) is/are for the message which creates
    an offset surface:
*/

# define EMS_opt_offsetS_copy_topology   	0x0001

# define EMS_opt_offsetS_extend_start		0x0002
# define EMS_opt_offsetS_shorten_start		0x0004
# define EMS_opt_offsetS_by_delta_at_start	0x0008

# define EMS_opt_offsetS_extend_stop		0x0010
# define EMS_opt_offsetS_shorten_stop		0x0020
# define EMS_opt_offsetS_by_delta_at_stop	0x0040

# define EMS_opt_offsetS_display		0x0080
# define EMS_opt_offsetS_handlestop		0x0100

# define EMS_opt_offsetS_negative		0x0200
# define EMS_opt_offsetS_by_range		0x0400
# define EMS_opt_offsetS_of_sfsolid             0x0800
# define EMS_opt_offsetS_remove_opensfs         0x1000
# define EMS_opt_offsetS_special_algo_only      0x2000

/*
    The following option(s) is/are for the message which extends a
    surface by distance along its natural directions
*/
# define EMS_opt_extendS_deextend_if_needed     0x0001
# define EMS_opt_extendS_reparametrize_surface  0x0002

/* The following option(s) are meant to be used during creation and nesting
   of EMSloop objects. These option(s) were were first introduced for the
   function EMcreate_loop_from_int_group() in src_funk/misc/EMmklp.I
*/
#define EMS_opt_mklp_ConnectAtLastIndex         0x0001

/*
    If this bit is set, any boundaries of the original surface
    will be copied to the new surface, possibly with their
    degenerate and xyz-closed properties being reset.
*/

/*
 * Surface profile generation options
 */
# define EMSplaceProfileFeatures    0x0001
# define EMSplaceProfileCurves      0x0002
# define EMSignoreBoundaries        0x0004

/*
 * Parting line options
 */
# define EMStrimParametricData      0x0001
# define EMStrimWorldData           0x0002
# define EMSuntrimmedParametricData 0x0004
# define EMSuntrimmedWorldData      0x0008


/*
 * The following option masks are used in the processing of
 * model-space counterparts of uv-boundary objects.
 */

#define EMSmsc_innerloops	0x01  /* Process inner loops */
#define EMSmsc_edges		0x02  /* Process edges of the loop */
#define EMSmsc_noupdateshell	0x04  /* Do not update the shell-manager's 
					 data-base */

/*
 * Options for the message EMtree_traverse, EMsendtomsc
 */

#define EMStreetrav_down	0x01  /* The traversal goes down the tree */
#define EMStreetrav_up		0x02  /* The traversal goes up the tree */



/* Options for the message EMSloop.EMtoggle_type */

#define EMTogType_SendInner	0x0001   /* Propogate toggling down the tree*/
#define EMTogType_SendOuter	0x0002   /* Propogate toggling up the tree*/
#define EMTogType_SendAdjacent	0x0004	 /* Propogate toggling to adjacent
					    loops. Adjacency is defined by
					    atleast one edge pair of two
					    loops being common edges. */
#define EMTogType_NoAction	0x0008	 /* Instead of toggling the loop
					    type of a conflicting loop just
					    return its id if the array is
					    provided */
#define EMTogType_ExclusiveAdjacency 0x0010 /* If a loop is decided to be
						kept, its ajacent loops are
						deletable. The 'delete' flag
						is toggled when propagating
						the message to adjacent
						loops. A combination of this
						option with NoAction, will
						return the ids of the loops
						in deletable_loops
						array. */
						    
#define EMTogType_SendExternalSiblings	0x0020   /* Indicates propagation of the
                                              message to siblings under the
                                              loopset.*/

 /* Following option is used in getting edge definitions.
    (message EMSgetedgedef).
 */

#define	EMGetDef_OnlyPartInfo		0x0001  /* Applicable only for
						   partedge. It specifies
						   not to return info
						   about that partedge's
						   full edge.
						*/
						
						
						
						
#define EMsws_MaintainHistory		0x0001


/*
 * The following options are used in the method EMmkfilletsf defined at
 * the EMSgenbs class.
 */

#define EMS_FILLET_PART		0x01	/* A partial fillet needs to be
					   constructed from the starting
					   point to the ending point. If
					   fillet is closed a direction-point
					   must be given */

/*
 * The following options used in EMptnetwrk
 */

#define EMS_PTNET_DISPROWS		0x01	/* Display rows */
#define EMS_PTNET_DISPCOLS		0x02	/* Display columns */
#define EMS_PTNET_DISPPT		0x04	/* Display the point */

/*
 * Options for the family of methods that do the post-processing after
 * the logical completion of an operation (EMpost... methods).
 */

#define EMS_POST_NOCOMPONENTS	0x01	/* Perform the post-processing
					   only on this object and not
					   on any of it's components. */
#define EMS_POST_SAVEDSTATE	0x02	/* The state has been saved and can
					   be restored at a later time */

/*
 * Options to call EMmkarea. See EMmkarea.I for details
 */

#define EMmkarea_outside	0x01

/*
 * Options to call EM*getbdry and EMgetstrkpy methods at EMSloopset, EMSloop
 * and EMSedge levels respectively. See the EMgetstrkpy message in EMSedge.S
 * for explanation of these options.
 */

#define EMS_GETB_COMPATIBLEXYZ		0x001
#define EMS_GETB_COMPATIBLEUV		0x002
#define EMS_GETB_STROKEISO		0x004
#define EMS_GETB_CONSISTLFXYZVTX	0x008
#define EMS_GETB_CONSISTRTXYZVTX	0x010
#define EMS_GETB_CONSISTLFUVVTX		0x020
#define EMS_GETB_CONSISTRTUVVTX		0x040
#define EMS_GETB_REDUCEDATA		0x080
#define EMS_GETB_INCLUDEDEGEN		0x100
#define EMS_GETB_INCLUDETOPODEGEN	0x200
#define EMS_GETB_DOMINANT	        0x400

/*
 * The following options are used in the message EMSedge.EMgetvtxedges
 * These options are also listed with the message declaration in EMSedge.S
 * and in the file containing the implementation - EMedvtxedges.I
 */

#define EMSvtxedges_nodegenerate	0x1
#define EMSvtxedges_noseamedge		0x2
#define EMSvtxedges_onlydominant	0x4
#define EMSvtxedges_onlythissurf	0x8
#define EMSvtxedges_onlycommon		0x10
#define EMSvtxedges_notangent		0x20

/*
 * The following options used in the function EMchkedconvex
 */

#define EMSchkconvex_global		0x1
#define EMSchkconvex_nextgeomsf		0x2
#define EMSchkconvex_geometric		0x4

/*
 * The following options are used in the function EMgetmapped_inters()
 *     --- KNAP
 * Added two more options : EMS_DONOT_MAP_SEAM_EDGES
 *                          EMS_OPT_REVERSE_MAPPED_EDGE
 *     --- Sanjay
 */
#define EMS_DONOT_MAP_CONVEX_EDGES	0x01
#define EMS_DONOT_MAP_CONCAVE_EDGES	0x02
#define EMS_DONOT_MAP_NEUTRAL_EDGES	0x04
#define EMS_DONOT_MAP_SEAM_EDGES	0x08
#define EMS_DONOT_MAP_ANY_EDGE	        0x10
#define EMS_OPT_PUSH_TO_COMMON_EDGE     0x20
#define EMS_OPT_REVERSE_MAPPED_EDGE     0x40


/*
 * Options to be used in rounding.
 */

#define EMS_EXTEND_SURF                 0x01 /* option to extend fillet surf*/

/* 
 * Options for EMget_graphics_edges
 */
#define EMS_OPT_GRALOOP       0x1  /* return graphic loop edges */
#define EMS_OPT_HORIZON       0x2  /* return horizon loop edges */
#define EMS_OPT_CUSP          0x4  /* return cusp edges */
#define EMS_OPT_CREATE        0x8  /* create horizon edges/cusps for the 
                                      surface if they don't already exist. */
#define EMS_OPT_NO_DIS        0x10 /* display and locate turned off for the
                                      horizon/cusp/graphic loop.  To be 
                                      specified with the EMS_OPT_CREATE 
                                      option. */
#define EMS_OPT_DELETE_HRZ    0x20 /* option to delete the horizon loop
                                      for the object in the specified 
                                      orientation. */
#define EMS_OPT_ONLY_CUSP     0x40 /* option to only create an EMScusp and
                                      no EMShorizon object. */
#define EMS_OPT_ALL_HORIZON   0x80 /* return all horizon loop edges,
                                      regardless of orientation */
#define EMS_OPT_CREATE_HRZ_CVS 0x100 /* create horizon curves if in a read-only
                                        reference file; only applicable if the
                                        EMS_OPT_CREATE flag is also set*/

/* Options for setting surface_display_flags, currently a global flag */
#define HORIZON_EDGES_ON    0x1
#define TANGENT_EDGES_ON    0x2
#define RULE_LINES_ON       0x4
#define OLD_MATH_ROUTINE    0x8
#define GET_GRA_EDGES       0x10  /* if the message EMSsubbs.EMget_graphics_edgs
                                     was sent with the option to create
                                     horizon edges/cusps if they do not already
                                     exist, then this option will be set.  At
                                     this point it will only be used to allow
                                     access to the EMShorizon class methods 
                                     such as locate and display.
                                   */  
#define DISPLAY_HRZ_EDGES   0x20  /* display horizon edges if this flag is set
                                   */

/* 
 * option(s) for new rounding.
 */    
 
#define EMS_EXTEND_SURF          0x01 /* option to extend a surface */
#define EMS_OPERATION_ROUND      0x02 /* option to create a fillet surface */
#define EMS_OPERATION_CHAMFER    0x04 /* option to create a ruled surface */


#define EMS_REMBND_SURF       0x0001 /* option to delete surface */
                                     /* File - implp/EMdelbd_init.I */
                                     
# define EMS_CHECK_SEAM_TANGENCY    0x8

/*
 * Options used in filleting within rounding
 */

#define EMS_RND_SF1_NATSIDE		0x1
#define EMS_RND_SF2_NATSIDE		0x2
#define EMS_RND_SINGLE_FILLET		0x4
#define EMS_RND_EXTEND_SURF		0x8
#define EMS_RND_END_ROLLING_BALL	0x10
#define EMS_RND_INT_ROLLING_BALL	0x20
#define EMS_RND_PARTIAL_FILLET		0x40
#define EMS_RND_BOUND_SURF		0x80
#define EMS_RND_ORIENTED		0x100
#define EMS_RND_DEFAULT_RHO		0x200
#define EMS_RND_CHECK_CURV_PROB		0x400

#define EMS_RND_SF3_NATSIDE             0x800
#define EMS_RND_CV_NATSIDE_IND          0x1000

/*
 * Options to EMround_chamfer_edges(), and EMSsfrndbool.EMround().
 */

#define EMS_RND_DONOT_MODIFY_MODEL	0x1
#define EMS_RND_NON_ASSOCIATIVE		0x2
#define EMS_RND_CHAMFER			0x4
#define EMS_RND_SAMERADIUS		0x8
#define EMS_RND_BLENDALL		0x10

/*
 * Options used within structs EMSedge_rnd_info and EMSrnd_edge_input in
 * EMSrnd.h.
 */
#define EMSfillet_rho_specified	       0x1
#define EMSblend_edge_start            0x2
#define EMSblend_edge_stop             0x4

/*
 * Options used by the function EFmake_os_read_only_assoc to determine
 * what type of elements are to be created
 */
#define EMS_CREATE_MSCS         0x1
#define EMS_CREATE_POINTERS     0x2

/*
 * Options used by the function EFext_and_prj_cv() which optionally can extend
 * the input curve and then projects it onto a surface
 */
#define EMSExtPrj_NoClip	0x1
#define EMSExtPrj_WantSingleOut	0x2

/*
 * Options used by the function EFcvt_edge_to_cv() which extracts the  
 * geometry of an edge and does a Bspline fit unless the following
 * option is set.
 */
#define EMSEdgCrv_DONOT_FIT_BSP_CURVE  0x1

# endif
