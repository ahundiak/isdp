/*
  HISTORY



    12-Jan-1994  SAK Added a new option "EMSintobj_special_tangent" to 
                     used in the "EFoffset_compsf" function to mark tangent
                     intobjs which have second order continuity between its
                     two surfaces.

    17-Jun-1993  NP  Added options that get set while "fixing" intersection data
                     Also added "EMSintobj_mapped_data" for Rustagi.
    04-Apr-1992  NP  Added "EMSfixsfint_chk_opposite_orient" option used in
                     arguments to the EMfixsfintout function.

    12-Dec-1991  NP  Added the "EMSintobj_split_noconnectuv" option for
		     splitting intobj's. Used for rounding. See file
		     EFsplitInts.I in src_dpr/funk.
    22-Jun-1989  SS  Added the options used in the EMintersect_surfaces
                     function. The EMS_SFINT_* series.
    11-Jan-1989  rlw Added EMget_int_data option for iso edges.
    10-May-1988  SM  Added EMSsfbool_opt_OpenIntPossible mask for boolean
         	     options.
    14-Apr-1988  jBk Added EMSsfbool_opt_retryDisjoint mask for
                     EMboolean messages.
    Long Ago     SS  Creation.
*/


# ifndef emssfintdef_include
# define emssfintdef_include

/*
 * These masks are used to specify the kind of
 * model-space output desired from surface-surface
 * intersection. With the "no-typed-cv" option, the
 * raw intersection data in a very general form (3D-polyline
 * or a general B-spline curve) is output. Otherwise, when 
 * possible, intelligent curve typing is done - eg: a circle-
 * intersection when detected is output as a cirle.
 * In addition, the orientation masks can be used.
 */

#define EMSINT_OUTPUT_WORLD      0x0001
#define EMSINT_WORLD_OBJECT      0x0002
#define EMSINT_WORLD_NOTYPEDCV   0x0010
#define EMSINT_WORLD_NOFITTEDCV  0x0020
/* Next mask to begin at	 0x0040 */

/*
 * These masks are used to specify the kind of
 * parametric-space output desired from surface-surface
 * intersection. In addition, the orientation masks
 * can be used.
 */

#define EMSINT_OUTPUT_PARAM      0x0001
#define EMSINT_PARAM_OBJECT      0x0002
/* Next mask to begin at	 0x0010 */

/*
 * The following masks can be provided along
 * with either the parmateric-output mask or the
 * model-space output mask. These serve to specify
 * if the output should be oriented with respect to
 * the other intersecting surface and if so, in what
 * manner. If conflicting orientations are specified in
 * the world-output mask and the parametric-output mask,
 * ORIENT_RIGHT is construed.
 */

#define EMSINT_ORIENT_OUTPUT     0x0004
#define EMSINT_ORIENT_RIGHT      0x0008


/*
 * These masks specify if the intersection should
 * be trimmed with respect to the surface-boundaries
 * or not. Whether to treat bounday as area or hole. Whether coplanar
 * surfaces should be processed specially. Whether the trim computation
 * needs to be done with greater precision. There is an indicator bit
 * to flag that the operands to surface-surface intersection have been
 * switched around. A bit is available to chose the option to do some special
 * processing on overlapping cases. There is an option to return intersections
 * only if it is "cutting" - currently, this only has the effect of marking
 * as deletable, those coincident plane intersecions produced between
 * two planes that have volumes on opposite sides (so it has any effect only
 * with COPLANAR processing also turned on). An option is provided to have
 * the STOP-interrupt by the user, handled and not ignored.
 *
 * The exact effect of these options is further described in the documentation
 * for the intersection function/method.
 */

#define EMSINT_TRIM_OUTPUT       0x0001
#define EMSINT_TRIM_COPLANAR     0x0002
#define EMSINT_TRIM_BDRYISAREA   0x0004
#define EMSINT_TRIM_MOREPRECISE  0x0008
#define EMSINT_TRIM_OPSWITCHED   0x0010
#define EMSINT_TRIM_PROCOVERLAP  0x0020
#define EMSINT_TRIM_ONLYCUTTING  0x0040
#define EMSINT_TRIM_HANDLESTOP	 0x0080
#define EMSINT_TRIM_IGNOREVOLUME 0x0100
#define EMSINT_TRIM_RETAIN_ON_PRIMARY	0x0200
#define EMSINT_TRIM_DELETE_ON_SECONDARY	0x0400


/*
 * The following defined constants are intended as options that can be
 * specified when calling methods/function involving surface intersection or
 * it's post-processing. Refer to the relevant function/method document for
 * specifics.
 */

/*
 * EMintersect_surfaces:
 */

#define EMS_SFINT_MUSTINTERSECT		0x01
#define EMS_SFINT_MUSTCLOSE		0x02
#define EMS_SFINT_MUSTORIENT		0x04
#define EMS_SFINT_MUSTNOAMBIGUOUS	0x08
#define EMS_SFINT_SKIPSFINT		0x10
#define EMS_SFINT_NOREFINE		0x20
#define EMS_SFINT_DOUBLECHECK		0x40
#define EMS_SFINT_SKIPFIXING		0x80
#define EMS_SFINT_AUTODOUBLECHECK      0x100
#define EMS_SFINT_REVERSESECONDINT     0x200
#define EMS_SFINT_HANDLESTOP	       0x400
#define EMS_SFINT_PUSHBADCOINC	       0x800
#define EMS_SFINT_MARKEDDELINFO	      0x1000
#define EMS_SFINT_YESORNO	      0x2000
#define EMS_SFINT_NOCURVECOPY         0x4000 
#define EMS_SFINT_CHTTRACETOL	      0x8000


/* 
 * EMfixsfintout: 
 * See the function definition for EMfixsfintout. It explains the
 * meaning of each of these enumerated types.
 */

enum EMSfixsfint_type
  {
  chk_noop,
  chk_dupsamesurf,
  chk_dupothersurf,
  chk_deletable,
  chk_nonoriented,
  chk_redundant,
  chk_noconnect,
  chk_opporiented,
  chk_midptcoinc
  };

#define EMSfixsfint_act_delmarked    0x0001    /* Remove the 'marked' intobj
                                                  out of the pair */
#define EMSfixsfint_act_delunmarked  0x0002    /* Remove the 'unmarked' intobj
                                                  out of the pair */
#define EMSfixsfint_act_setnonorient 0x0004    /* Both the 'marked' and
                                                  'unmarked' intobjs will be
                                                  marked as non-oriented */
#define EMSfixsfint_act_splitinters  0x0008    /* The 'marked' intobj is split
                                                  when found appropriate */


/* 
 * EMSsfint_graphics_output:
 */

#define EMSsfint_grout_trace 	 0x0001	  /* Perform a trace before 
                                             outputting the results */

/*
 * EMSedge.EMsfintdata:
 */

#define EMSsfint_edge_sameside   0x0001   /* The two planes have their
					     volumes on the same side */
#define EMSsfint_edge_primary1	 0x0002   /* Out of the two given surfaces -
                                             (first and second) the first
                                             one is the primary one. If not
					     set, the second one is primary */
#define EMSsfint_edge_deletable  0x0004   /* Mark the output intersection
                                             as deletable, unconditionally */

/*
 * EMSsfboolean.EMboolean:
 */

#define EMSsfbool_opt_display	  0x0001  /* If set, then the boolean method
					     will do the erase for the 
                                             operands.*/
#define EMSsfbool_opt_doublecheck 0x0002  /* If set will perform all it's
					     sub-operations using alternate
					     (which may be more time-comsuming)
					     algorithms, wherever possible. 
                                             These algorithms double check
					     certain results, unconditionally.
					     Eg: check for duplicate
					     intersections. */
#define EMSsfbool_opt_outinters   0x0004  /* Output the intersection result.
					     The intersection is output as a
					     graphic group. */
#define EMSsfbool_opt_outaux      0x0008  /* Output an auxilliary graphic
                                             group that contains elements
                                             indicating problem areas. These
                                             consist of points at which closure
                                             was expected but did not occur,
                                             etc. */
#define EMSsfbool_opt_noredraw    0x0010  /* If set then the boolean method
                                             will NOT do the redraw of 
                                             modified surfaces and WILL add
                                             the modified ids to the array.
                                             If not set the method will do the
                                             reverse.*/
#define EMSsfbool_opt_retryDisjoint 0x0020 /* If this bit is set and if the
                                             boolean method finds no
                                             intersections while attempting a
                                             non-disjoint operation, but was
                                             otherwise successful, then the
                                             spatial relationship between the
                                             elements is tested, and an 
                                             appropriate disjoint boolean is
                                             performed. */

#define EMSsfbool_opt_retryingDisjoint 0x0040 /* If this bit is set, then this
                                             is a retry of a non-intersecting
                                             joining boolean as a disjoint
                                             boolean.*/

#define EMSsfbool_opt_OpenIntPossible 0x0080 /* This option means that even if
                                             the intersection is open go ahead
                                             and perform the boolean as long
                                             as each intersection piece is
                                             incident on an existing edge.*/

#define EMSsfbool_opt_SingleTopology 0x0100 /* This option is used during
                                             a boolean operation where
                                             the topology should be altered
                                             only on the first operand of the
                                             boolean. Note that this option
                                             may invalidate a solid. */

#define EMSsfbool_opt_ValidateAllData 0x0200 /* Used only in 
					     EMsfint_topology_validate().
					     Indicates continuation of
					     validation even after finding a
					     defect. */
#define EMSsfbool_opt_IncompleteInt 0x0400 /* Used in 
					      EMboolean_surfaces_w_intersection
					      . It indicates that the input
					      intersection data may be
					      incomplete in the sense that
					      for an intersection ending
					      on an edge, there may not be a
					      continuation on the common
					      surface. Such a condition under
					      this option is not error
					      causing.
					     */
#define EMSsfbool_opt_HandleStop    0x0800 /* Handle the STOP-interrupt. If not
					      set, then the STOP-interrupt is
					      ignored */

#define EMSsfbool_opt_ConnectToComEdge 0x1000 /* used in 
                                                 If has been added as special
                                                 requirement for round/chamfer
                                                 operation. If this flag is
                                                 set means that the common
                                                 edge connection must be made
                                                 irresective of SingleTopology
                                                 bit is set or not.
                                               */
                                    
#define EMSsfbool_opt_OperandsSwitched 0x2000 /* Last ditch attempt at 
                                                 union/intersection involving
                                                 coincedent surfaces, by
                                                 switching the operands.
                                              */
#define EMSsfbool_opt_AdjacentRegions  0x4000 /* The input EMSinters will
                                                 create adjacent regions on
                                                 the same surface. If an
                                                 intobj is "marked" then 
                                                 maintain the loop it creates
                                                 as forming area and 
                                                 alternating, adjacent regions
                                                 as "hole". */


/*
 * EMSsubbs.EMget_int_data:
 */

#define EMSintdata_samexyzdat	0x001	/* There is only a single copy
					   of the model-space data */
#define EMSintdata_matcheddat	0x002   /* The two surfaces have polyline
                                           data with matching spans */
#define EMSintdata_isoedge	0x004   /* The intersection(s) returned are iso
                                           curves */
#define EMSintdata_xyzdegen	0x008   /* The intersection(s) are degenerate
                                           in xyz */

/* 
 * OPTIONS RELATING TO FIXING OF INTERSECTION DATA. UPDATE MACRO BELOW IF ANY
 * ADDITIONAL OPTIONS ARE ADDED HERE.
 * The following are indicators of what was done to the intersection data
 * in it's fixing phase and is used solely for debugging. As such, these
 * should be ignored for the general purpose of communicating information
 * back and forth functions.
 */

#define EMSdebug_intdata_fixed_jumps      0x008   /* Intersection data fixed such that
                                               no jumps takes place in
                                               parametric space */

#define EMSdebug_intdata_fixed_edge_ints  0x010   /* Intersection data fixed such that
                                               intersections along natural edges
                                               are removed (if seam, then moved
                                               to correct side), intersections
                                               near nat. edge are moved to the
                                               nat. edge etc. */

#define EMSdebug_intdata_fixed_self_intr  0x020   /* Intersection data fixed such that
                                               there is no self intersection */

#define EMSdebug_intdata_fixed_grp_intr   0x040   /* Intersection data fixed such that
                                               there is intersection between
                                               groups, i.e. no intersection
                                               among intersections */

#define EMSdebug_intdata_fixed_degen_intr 0x080   /* Intersection data fixed such that
                                               degenerate intersections are
                                               deleted.Degenerate intersections
                                               are groups with ONE point (as 
                                               opposed to degenerate 
                                               intersections in math, which are
                                               groups with 2 identical points).
                                             */

/* UPDATE THIS MACRO IF MORE FIX OPTIONS ARE ADDED ABOVE */

#define print_fix_message(fix_options)                                     \
        {   if (fix_options)                                               \
            {                                                              \
              fprintf(stderr, "\nFixed:\n");                               \
              if (fix_options & EMSdebug_intdata_fixed_jumps)                    \
                 fprintf(stderr, "\tParametric jumps\n");                  \
              if (fix_options & EMSdebug_intdata_fixed_edge_ints)                \
                 fprintf(stderr, "\tIntersections near/on natural edge\n");\
              if (fix_options & EMSdebug_intdata_fixed_self_intr)                \
                 fprintf(stderr, "\tSelf intersections\n");                \
              if (fix_options & EMSdebug_intdata_fixed_grp_intr)                 \
                 fprintf(stderr, "\tIntersections between groups\n");      \
              if (fix_options & EMSdebug_intdata_fixed_degen_intr)               \
                 fprintf(stderr, "\tDegenerate intersections\n");          \
              fprintf(stderr, "\n");                                       \
            }                                                              \
        }


/*
 * Property masks that further characterize an intersection. These can
 * be used in the "props" field of an EMSintobj structure. These bits
 * are to be used when the EMSintobj represents a surface intersection.
 *
 * History
 * 	SS	Long Ago	Creation
 *	SM	12-April-88	Added property EMSintobj_exact.
 *      janaka  02/17/93        Added EMSintobj_not_in_area (for
 *                              EMrndsngtrm()).
 */



/*  ADD INTOBJ BITS ONLY IF YOU ABSULUTELY MUST. TRY AND MAKE USE OF 
 *  EXISTING BITS BEFORE DEFINING NEW ONES.  
 */

#define EMSintobj_dupthissurf	0x01   /* This intersection is possibly a
                                          duplicate of another on this
                                          same surface */
#define EMSintobj_dupothersurf	0x02   /* This intersection is possibly
                                          a duplicate on some other 
                                          surface. */
#define EMSintobj_delrefine     0x04   /* This intersection was diagnosed
					  to be deletable during
					  refinement. */
#define EMSintobj_nonoriented   0x08   /* This intersection has not been
                                          oriented w.r.t. to the other */
#define EMSintobj_coincident    0x10   /* This intersection is produced by
                                          coincident surfaces */
#define EMSintobj_deletable	0x20   /* This intersection can be deleted 
                                          unconditionally */
#define EMSintobj_exact_atstart	0x40   /* This intersection is known to be
					  exact at start point and does not 
					  need any further refinement.*/
#define EMSintobj_exact_atstop  0x80   /* As above - for stop point */

#define EMSintobj_fwd_noconnectuv 0x100  /* This intersection has definitely
					  no contiguous interesction ahead
					  of it */
#define EMSintobj_bwd_noconnectuv 0x200  /* This intersection has definitely
					  no contiguous interesction behind
					  it */
#define EMSintobj_fwd_connectuv 0x400  /* This intersection has contiguity
					  in uv-space ahead of it */
#define EMSintobj_bwd_connectuv 0x800  /* This intersection has contiguity
					  in uv-space behind it */
#define EMSintobj_nontriminfo	0x1000 /* The more info provided in this
					  intobj is not related to trimming
					  but is user specific. */
#define EMSintobj_uvdegenerate	0x2000 /* The uv-data is degenerate in
					  length */
#define EMSintobj_xyzdegenerate	0x4000 /* The xyz-data is degenerate in
					  length */
#define EMSintobj_marked        0x8000 /* A generic bit indicating a marked
					  intersection. EMsfinttrace behaviour:
                                          looks for this bit and rearranges the
                                          linked list with this EMSintobj as
                                          the starting element in the list.
                                          It then performs the trace. */
#define EMSintobj_isocurve      0x10000 /* The intersection is long an iso
                                           curve */
#define EMSintobj_tmpmarked     0x20000 /* The intersection is marked temp-
                                           orarily */
#define EMSintobj_tangent	0x40000 /* The intersection is a locally or
					 * globally tangent edge.
					 */
#define EMSintobj_seam		0x80000 /* The intobj represents a seam edge
					 */
#define EMSintobj_unmatched_dat	0x100000 /* intobj and its other intobj
					    have polyline data, but not
					    matching spans.
					 */

#define EMSintobj_mapped_data   0x200000 /* indicates that this intobj was 
                                            created by mapping, rather than from
                                            usual sf-sf intersection process.
                                          */
#define EMSintobj_overlap       0x400000 /* intobj overlaps
                                                    boundary component **/

#define EMSintobj_xyz_closed	0x800000 /* The intobj should be closed in XYZ
					 */

#define EMSintobj_not_in_area   0x1000000

#define EMSintobj_degen_ornt_right 0x2000000 /* This intersection 
                                             should be considered to be
                                             oriented such that closure is
                                             on the right.
                                             Makes sense only if NOT 
                                             nonoriented.
                                             Used in causing maximum splits
                                             during booleans when 2
                                             intersections are incedent
                                             at the same point on an existing
                                             edge.
                                            */

#define EMSintobj_degen_ornt_left 0x4000000 /* As above */

#define EMSintobj_special_tangent 0x8000000 /* Used to mark tangent edges
                                               which have second order
                                               continuity between its two
                                               surfaces. */


/* Options that deal with splitting an EMSintobj node */

#define  EMSintobj_dealloc_uvdata      0x01    /* To deallocate uv_data */ 

#define  EMSintobj_dealloc_xyzdata     0x02    /* To deallocate xyz_data */

#define	 EMSintobj_split_noconnectuv   0x04    /* used in rounding code (at 
 						  present). Makes sure that the
						  split halves of an intobj 
                                                  will never be considered 
                                                  contiguous */
#define  EMSintobj_fix_uvendpt         0x08    /* An option to pull the 
                                                  nearest uv end point to
                                                  the given point */
#define  EMSintobj_split_ignoreconnect 0x100   /* At the split junction no
                                                  'connect' information is
                                                  introduced or preserved. */

/*
 * Property masks that characterize an EMSinters node. These are
 * used in the "props" field of the EMSinters structure. 
 */

#define EMSinters_loopcreated		0x01 /* The intersections associated
						with this node have already
						been used to create the loop
						on this surface */

#endif
