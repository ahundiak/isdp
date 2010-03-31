/*
 * This file contains definitions used for local modifications of solids
 */

# ifndef EMSlmdef_h
# define EMSlmdef_h

/*
 * The following definitions are used for building
 * instruction table for MOVE and LIFT opeartions
 */

#define EMS_MOVE_LIN_FACE	0
#define EMS_MOVE_LIN_EDGE	1
#define EMS_MOVE_INT_PRP_EDGE	2
#define EMS_MOVE_LIN_VERTEX		3
#define EMS_MOVE_INT_LIN_EDGE	4

/*
 * The folowing definitions are used for differentiating
 * local modification operations
 */

#define	EMS_LIFT_VERTEX       0
#define	EMS_LIFT_EDGE	      1
#define	EMS_LIFT_FACE	      2
#define	EMS_MOVE_VERTEX       3
#define	EMS_MOVE_EDGE	      4
#define	EMS_MOVE_FACE 	      5
#define EMS_SPLIT_SURFACE     6
#define EMS_LIFT_FACE_W_DRAFT 7
/*
 * The following definitions are used in getting modifiable
 * edges and vertices
 */

#define EMS_GET_MOD_EDGE 0
#define EMS_GET_MOD_VERT 1
#define EMS_GET_STI_EDGE 2

#define EMS_WHL_EDGE                0
#define EMS_EDGE_BEG_PT             1
#define EMS_EDGE_END_PT             2
#define EMS_NONNATURAL_EDGE         3
#define EMS_NONSUBORDINATE_EDGE        4
#define EMS_EDGE_W_VERTICES         5

/*
 * The following definitions are used by make face in
 * splitting a loopset into two loopsets
 */

#define EMS_MKFACE_GROUP1	1
#define EMS_MKFACE_GROUP2	2

#define EMS_PROCESS_PHASE1 1
#define EMS_PROCESS_PHASE2 2

/*
 * The following flags are used by lift operation
 * while constructing new surfaces.
 */

#define EMS_C_RULED_SF     1
#define EMS_C_PROJECTED_SF 2
#define EMS_C_DRAFTED_SF   3

/*
 * The following are the constarint definitions used 
 * in the  lift operation
 */
 
#define EMS_LC_AUTO_COINCIDENCE   1

/* The following flags are used for Rounding and Chamfering operation */

#define EMS_CONCAVE_EDGE  1
#define EMS_CONVEX_EDGE   2
#define EMS_NEUTRAL_EDGE  3

#define EMS_3CVX_VTX      0
#define EMS_3CNV_VTX      1
#define EMS_1CVX_2CNV_VTX 2
#define EMS_1CNV_2CVX_VTX 3
#define EMS_2CVX_VTX      4
#define EMS_2CNV_VTX      5

#define EMS_TRIM_VERTEX       0
#define EMS_PATCH_VERTEX      1
#define EMS_INT_TRIM_VERTEX   2
#define EMS_EXTD_TRIM_VERTEX  3
#define EMS_INT_PATCH_VERTEX  4
#define EMS_EXTD_PATCH_VERTEX 5
#define EMS_NTRL_PATCH_VERTEX 6

#define EMS_EDGE_BND      0
#define EMS_VERTEX_BND    1
#define EMS_UNUSED        2
#define EMS_DUMMY_BND     3
#define EMS_PATCH_BND     4

#define EMS_CHAMFER_OPR   0
#define EMS_ROUND_OPR     1
#define EMS_RND_AUTOTRIM  2

#endif
