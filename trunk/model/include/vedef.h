
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef vedef_include
#define vedef_include 1

/*
DESCRIPTION
	Defines used by Vector Hidden Line

HISTORY
	S.P. Rogers    05/11/87  Creation Date
*/

/* size of results file name field */
#define RESULTS_FNAME_SIZE  16

/* size of server field */
#define SERVER_SIZE 32

/* size of user name field */
#define USER_NAME_SIZE 16

/* size of password field */
#define PASSWORD_SIZE 16

/* size of start time field */
#define START_TIME_SIZE 64

/* size of unique name field */
#define UNIQUE_NAME_SIZE 12

/* number of buckets in sort structure */
#define NUM_SORTING_BUCKETS 512

#define SAVED_INT_BASE 4
#define SAVED_INT_OFFSET 3

/* number of buckets for saved intersections */
#define NUM_INT_BUCKETS 512

#define ABS_VAL(value) ((value) < 0 ? 0 - (value) : (value))

#define XMIN 0
#define YMIN 1
#define ZMIN 2
#define XMAX 3
#define YMAX 4
#define ZMAX 5

/* edge uv polyline types -- used for trimming */
#define GENERAL_POLY  0
#define CONST_U_POLY  1
#define CONST_V_POLY  2


/* element type classification */

#define SURFACE      0
#define CURVE        1
#define POINT        2
#define SOLID_HEADER 3

/*****************************************************************************/
/* Bit Use and Masks For the VEenv_info flags word                           */
/*                                                                           */
/*	        .... ...x  : Read only flag                                  */

#define VE_READ_ONLY_ENV    0x0001 /* Environment is read-only               */
#define VE_ENV_PROCESSED    0x0002 /* Environment has been processed already */
#define VE_ENV_MIRROR_TRANS 0x0004 /* Env has a mirror transformation        */
/*****************************************************************************/


/*****************************************************************************/
/* Bit Use and Masks For the VEsort_record flags word                        */
/*                                                                           */
/*	        .... ...x  : From solid flag                                 */

#define SORT_REC_FROM_SOLID 0x0001    /* Element is from a solid             */
/*****************************************************************************/


/*****************************************************************************/
/* Bit Use and Masks For the VEelement_header flags word                     */
/*                                                                           */
/*		x... .... .... ....  : Boundary flag                         */
/*		.x.. .... .... ....  : From solid flag                       */
/*	        .... .... .... ...x  : Cross-Hatching flag                   */
/*	        .... .... .... ..x.  : All Edges Invisible flag              */
/*              .... .... .xxx xx..  : Comparision Classification Bits       */

#define HAS_BOUNDARIES      0x8000    /* Element has boundaries              */
#define ELEM_FROM_SOLID     0x4000    /* Element from a solid                */
#define HAS_CROSS_HATCHING  0x0001    /* Element has cross-hatching          */
#define ALL_EDGES_INVISIBLE 0x0002    /* All edges are invisible             */

#define CLASSIFICATION_BITS 0x007C
#define Z_IN_FRONT          0x0040    /* Element is completely in front      */
#define Z_OVERLAP           0x0020    /* Element interacts in Z              */
#define Z_BEHIND            0x0010    /* Element is completely behind        */
#define TOTAL_OVERLAP       0x0008    /* Element completely covers other one */
#define SOME_OVERLAP        0x0004    /* Element overlaps other one          */
/*****************************************************************************/

/* edge type classification */

#define NATURAL               0x0001    /* natural edge                  */
#define BOUNDARY              0x0002    /* boundary                      */
#define SHARP                 0x0004    /* sharp edge                    */
#define HORIZON_EDGE          0x0008    /* horizon edge                  */
#define HORIZON_CURVE         0x0010    /* horizon curve                 */
#define MESH                  0x0020    /* mesh line                     */
#define STANDALONE            0x0040    /* standalone curve              */
#define SINGLE_POINT          0x0080    /* single point                  */
#define WIREFRAME_CROSS_HATCH 0x0100    /* wireframe cross-hatching edge */


/* masks to see if an edge can hide */
#define EDGE_CAN_HIDE      0x001F  /* NATURAL | BOUNDARY | SHARP | HORIZON_EDGE | HORIZON_CURVE */
#define EDGE_CAN_SELF_HIDE 0X001F  /* NATURAL | BOUNDARY | SHARP | HORIZON_EDGE | HORIZON_CURVE */


/* edge visibility classification */

#define UNKNOWN         0  /* visibility not known                         */
#define VISIBLE         1  /* visible                                      */
#define HIDDEN          2  /* hidden                                       */
#define OVERLAPPED      3  /* overlap region                               */
#define DO_NOT_PROCESS  4  /* not to be processed                          */
#define DEGENERATE_SPAN 5  /* span degenerates to a point when made planar */

/**********************************************************************************************/
/* Bit Use and Masks For the VEedge_header status word                                        */
/*                                                                                            */
/*	.... .... .... .... .... .... .... ...x  : Profile edge flag                          */
/*	.... .... .... .... .... .... .... ..x.  : Visible/Hidden Classification Flag         */
/*	.... .... .... .... .... .... .... .x..  : Totally Overlapped flag                    */
/*	.... .... .... .... .... .... .... x...  : Totally Invisible flag                     */
/*	.... .... .... .... .... .... ...x ....  : Dummy Shared Edge flag                     */
/*	.... .... .... .... .... .... ..x. ....  : XY Collinear flag                          */
/*	.... .... .... .... .... .... x... ....  : Has Saved Cv/Cv Int Data flag              */
/*	.... .... .... .... .... ...x .... ....  : Real Shared Edge flag                      */
/*	.... .... .... .... .... ..x. .... ....  : Edge debug flag                            */
/*	.... .... .... .... .... .x.. .... ....  : Split From Planar Parent flag              */
/*	.... .... .... .... .... x... .... ....  : Already classified flag                    */
/*	.... .... .... .... ...x .... .... ....  : Different Edge Types flag                  */
/*	.... .... .... .... ..x. .... .... ....  : Use Double Projection flag                 */
/*	.... .... .... .... .x.. .... .... ....  : Has Self-Overlaps flag                     */
/*	.... .... .... .... x... .... .... ....  : Trimmed a parting line flag                */
/*      .... .... .... ...x .... .... .... ....  : Constant U flag                            */
/*      .... .... .... ..x. .... .... .... ....  : Constant V flag                            */
/*      .... .... .... .x.. .... .... .... ....  : Using dummy geometry flag                  */
/*	.... .... .... x... .... .... .... ....  : Tangent edge flag                          */

#define EDGE_CLASSIFICATION      0x00000003
#define VISIBLE_NON_PROFILE      0x00000001    /* visible, non-profile edge                   */
#define VISIBLE_PROFILE          0x00000000    /* visible, profile edge                       */
#define HIDDEN_NORMAL_FLIP       0x00000002    /* hidden edge where normals flip              */
#define HIDDEN_NON_PROFILE       0x00000003    /* hidden, non profile edge                    */
#define CLASSIFIED_AS_HIDDEN     0x00000002    /* edge has been classified as hidden          */

#define TOTALLY_OVERLAPPED       0x00000004    /* the entire edge should be ignored           */
#define TOTALLY_INVISIBLE        0x00000008    /* edge only has hidden and overlapped spans   */
#define WAS_A_DUMMY              0x00000010    /* the edge is (or was) a dummy shared edge    */
#define COLLINEAR_EDGE           0x00000020    /* the edge is collinear in xy-space           */
#define HAS_SAVED_INT_DATA       0x00000080    /* the edge has saved intersection data        */
#define REAL_SHARED_EDGE         0x00000100    /* the edge is a real shared edge              */
#define DEBUG_EDGE               0x00000200    /* debug the edge                              */
#define SPLIT_FROM_PLANAR_PARENT 0x00000400    /* edge was split from planar parent edge      */
#define ALREADY_CLASSIFIED       0x00000800    /* edge has already been classified            */
#define DIFFERENT_EDGE_TYPES     0x00001000    /* shared edges are of different types         */
#define USE_DOUBLE_PROJECTION    0x00002000    /* the edge uses double pt proj scheme         */
#define HAS_SELF_OVERS           0x00004000    /* the edge has self-overlaps                  */
#define TRIMMED_A_PARTING_LINE   0x00008000    /* the edge (boundary) trimmed a parting line  */
#define CONSTANT_U_ISOCURVE      0x00010000    /* the edge is a constant U isocurve           */
#define CONSTANT_V_ISOCURVE      0x00020000    /* the edge is a constant V isocurve           */
#define EDGE_IS_ISOCURVE         0x00030000    /* the edge is an isocurve                     */
#define USING_DUMMY_GEOMETRY     0x00040000    /* the edge geometry is that of the dummy edge */
#define EDGE_IS_TANGENT          0x00080000    /* the edge is a tangent edge                  */
/**********************************************************************************************/


/* temp node status masks */
#define DOUBLE_PROJ_USED      0x8000    /* a double point proj was done from temp_node */

/**********************************************************************************************/
/* Masks for the global flags integer                                                         */
/*                                                                                            */
/*	bit use:                                                                              */
/*                                                                                            */
/*	.... .... .... .... .... .... .... ...x  : Tracing flag                               */
/*	.... .... .... .... .... .... .... ..x.  : Processing mode flag                       */
/*      .... .... .... .... .... .... .... .x..  : OLD Data Reduction flag (not used)         */
/*      .... .... .... .... .... .... .... x...  : Gapping flag                               */
/*      .... .... .... .... .... .... ...x ....  : Output Solid Self-Hidden Edges Flag        */
/*      .... .... .... .... .... .... ..x. ....  : Attach Results File Flag                   */
/*      .... .... .... .... .... .... .x.. ....  : New Data Reduction Flag                    */
/*                                                                                            */
/*                                                                                            */
/*      Tracing flag:                   0 => Trace, 1 => No Trace                             */
/*                                                                                            */
/*	Batch mode flag:                0 => Interactive, 1 => Batch                          */
/*                                                                                            */
/*      Gapping flag:                   0 => don't gap, 1 => gap                              */
/*                                                                                            */
/*	Output solid self hidden flag	0 => don't output solid self-hidden edges, 1 => do    */
/*                                                                                            */
/*	Attach results file flag	0 => don't attach results file, 1 => do               */
/*                                                                                            */
/*      New Data Reduction flag:        0 => Don't do Reduction, 1 => Do Reduction            */

#define VE_VHL_NO_TRACE                 0x00000001
#define VE_VHL_BATCH_MODE               0x00000002
#define VE_VHL_OLD_DATA_REDUCTION       0x00000004  /* not used */
#define VE_VHL_GAPPING_LINES            0x00000008
#define VE_VHL_OUTPUT_SOLID_SELF_HIDDEN 0x00000010
#define VE_VHL_ATTACH_RESULTS_FILE      0x00000020
#define VE_VHL_DATA_REDUCTION           0x00000040
/**********************************************************************************************/


#define SIBLINGS_FROM_PLANAR_PARENT( e0, e1 )                                             \
	                                                                                  \
	( ((e0)->edge_id == (e1)->edge_id) && ((e0)->status & SPLIT_FROM_PLANAR_PARENT) ) \


#define DUMMY_EDGE_FROM_SOLID( elem, edge )                                  \
	                                                                     \
	( ( ((elem)->flags & ELEM_FROM_SOLID) && ((edge)->gm_curve3d == NULL) ) ) \

/* Defines for interpreting output levels */
#define NO_HIDDEN_OUTPUT 0xFFFF

/*  Defines for VEgragad set/inquire methods  */
#define VE_BATCH_INFO         1

#endif
