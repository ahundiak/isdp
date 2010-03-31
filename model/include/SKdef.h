#ifndef SKdef_include
#define SKdef_include 1

/*
 * Constants used within the "sketch" system
 */

#define SK_INCR_SIZE	10

#define SK_ARBIT_LINELENGTH	10.0

/*
 * Properties in SKmgr class objects
 */

#define SK_MGR_STATE_SAVED	0x01
#define SK_MGR_OUTOFDATE	0x02
#define SK_MGR_PLN_OUTOFDATE	0x04

/*
 * Properties in SKconstraint class objects
 */

#define SK_GROUND_X          0x01
#define SK_GROUND_Y          0x02
#define SK_TEMPORARY         0x04
#define SK_NOVALUE           0x08
#define SK_HORIZONTAL        0x10
#define SK_INVISIBLEHNDL     0x20
#define SK_MODIFIED          0x40
#define SK_NEWADD            0x80
#define SK_USERADD           0x100
#define SK_PARAMETER_DIM     0x200
#define SK_SELFCNSTR	     0x400
#define SK_CLOCKWISE_ANGLE   0x800
#define SK_NEGATIVE_AXIS     0x1000
#define SK_HALFVALUE	     0x2000
#define SK_UNITSCONVERT	     0x4000
#define SK_SUPPLEMENT	     0x8000

/*
 * Properties in the SKvariable class of objects
 */

#define SK_VAR_ISEXPR     0x01
#define SK_VAR_READEXPR   0x02
#define SK_VAR_NEGDIRGEOM 0x04

/*
 * Aliases that stand for various units (used in unit-macros)
 */

#define EMS_UNIT_FEET		"feet"
#define EMS_UNIT_INCHES 	"inches"
#define EMS_UNIT_METERS 	"meters"
#define EMS_UNIT_MILLIMETERS	"millimeters"
#define EMS_UNIT_DEGREES	"degrees"
#define EMS_UNIT_RADIANS	"radians"

/*
 * The following indicate topological position of a point on an infinite
 * line represented by two points
 */

#define SK_AT_START	 0x1
#define SK_AT_STOP	 0x2
#define SK_IN_MIDDLE	 0x4
#define SK_ON_SEGMENT    (SK_AT_START | SK_AT_STOP | SK_IN_MIDDLE)
#define SK_BEFORE_START  0x8
#define SK_AFTER_STOP    0x10


/*
 * Options used to drive the "pass" message on the
 * constraints based on their classes. 
 */

#define SK_PASS_IMPLICIT_CLASS          0x01
#define SK_PASS_EXPLICIT_CLASS          0x02
#define SK_PASS_NotPublic_ASGROUND	0x04
#define SK_PASS_ASGROUND_CLASS          (SK_PASS_NotPublic_ASGROUND |\
                                         SK_PASS_IMPLICIT_CLASS)

/*
 * Options used in the update methods/functions. Also the SKmergemgr
 * method. Also the SKvalidate message. A subset of these may be the only ones
 * supported by different modules.
 */

#define SK_UPDATE_DONOTPOST	     0x1
#define SK_UPDATE_PSEUDOVAL	     0x2
#define SK_UPDATE_IMPCONSTRS	     0x4
#define SK_UPDATE_EXPCONSTRS	     0x8
#define SK_UPDATE_ERASE		     0x10
#define SK_UPDATE_DRAW		     0x20
#define SK_UPDATE_NOSAVESTATE        0x40
#define SK_UPDATE_COMPRESSED         0x80
#define SK_UPDATE_INFOERROR	     0x100
#define SK_UPDATE_DELETEOLD	     0x200
#define SK_UPDATE_CHKCYCLE	     0x400
#define SK_UPDATE_GEOMNOPOST	     0x800
#define SK_UPDATE_CNSTRNOPOST	     0x1000

/*
 * Options used in construction/initialization methods of constraints
 * and geometries.
 */

#define SK_OPT_CONNECT_GEOMETRY 0x01
#define SK_OPT_CREATE_GEOMETRY  0x02
#define SK_OPT_NO_MGR_CONNECT   0x04
#define SK_OPT_MARK_AS_NEWADD	0x10
#define SK_OPT_NO_CONNECT_PTS   0x20
#define SK_OPT_MARK_AS_USERADD  0x40
#define SK_OPT_NO_CREATE_EXPR	0x80
#define SK_OPT_DISPLAY_GEOMETRY	0x100
#define SK_OPT_SAVE_OLD_VALUE	0x200
#define SK_OPT_NO_CREATE_PTS	0x400
#define SK_OPT_CHECK_UNITS      0x400

/*
 * Options used in manipualting transformation matrix
 */

#define SK_OPT_GET_XY_TO_XYZ    0x01
#define SK_OPT_GET_XYZ_TO_XY    0x02
#define SK_OPT_GET_XY_TO_LXYZ   0x04
#define SK_OPT_GET_LXYZ_TO_XY   0x08
#define SK_OPT_FULL_TRANSFORM   0x100
#define SK_OPT_VAR_X	        0x200
#define SK_OPT_VAR_Y            0x400
#define SK_OPT_NO_ORIGIN        0x800
#define SK_OPT_NO_ROTATION      0x1000

/*
 * Options used in copy
 */

#define SK_OPT_COPY_ASSOCIATIVE 0x01
#define SK_OPT_NO_COPY_HANDLE   0x02

/*
 * Options used in the jacobian functions/methods
 */

#define SK_JACOB_PSEUDO_VAR       0x01
#define SK_JACOB_PSEUDO_EQN       0x02
#define SK_JACOB_GROUND_SECDIM    0x04
#define SK_JACOB_ADJACENCY	  0x08
#define SK_JACOB_ACCURACY	  0x10
#define SK_JACOB_LEASTSQUARES	  0x20
#define SK_JACOB_UPDATE_GUESS     0x40

/*
 * Options used in the manipulate locus functions
 */

#define SK_LOCUS_PTORDERED	0x01
#define SK_LOCUS_ANYPT		0x02
#define SK_LOCUS_NOADDPTLIST	0x04
#define SK_LOCUS_NOADDLCLIST	0x08
#define SK_LOCUS_NOADDHLCLIST	0x10

/*
 * Options used in obtaining variables and/or constraints of a
 * sketch manager. Used in SKmgr.SKgetvarconstrs, SKvariable.SKgetvarlist,
 * SKconstraint.SKgetconstrs, SKexplicit.SKgetname, SKvalvar.SKgetname.
 */

#define SK_GETCN_NEW       0x1
#define SK_GETCN_GENEQN    0x2
#define SK_GETCN_HNDL      0x4
#define SK_GETCN_NDPARENTS 0x8
#define SK_GETCN_FIND      0x10
#define SK_GETCN_IMPLICIT  0x20
#define SK_GETCN_GEOMHNDL  0x40
#define SK_GETCN_NOGROUND  0x80
#define SK_GETCN_ADJVARS   0x4000

#define SK_GETVR_FIND       0x0100
#define SK_GETVR_NDCHILDREN 0x0200
#define SK_GETVR_EQNVARNAME 0x0400
#define SK_GETVR_VALVAR     0x0800
#define SK_GETVR_COMPRESSED 0x1000
#define SK_GETVR_SIGNIFNAME 0x2000

/*
 * Options used while dealing with SKvalvar class
 */

#define SK_VARCREATE_NEWEXPR            0x10
#define SK_VARCREATE_NEWINPUTEXPR       0x20

/*
 * Options used to in the change properties message
 */

#define SK_CHGPROPS_OFF     0
#define SK_CHGPROPS_ON      1
#define SK_CHGPROPS_TOGGLE  2
#define SK_CHGPROPS_SET     3
#define SK_CHGPROPS_GET     4


/*
 * Options used in the function used to create dimensional constraints.
 * Some of these bits are also used in output to describe the kind of
 * dimension constraint.
 */

#define SK_DIMCNSTR_NODISPLAY	0x2
#define SK_DIMCNSTR_UNIDIR	0x4
#define SK_DIMCNSTR_MASKONSEC   0x8

/*
 * Options used in the function SKprocess_sketch_graphics,
 * method SKgeometry.SKcreate_ptvars, SKisparskpln. Some of these may not be
 * used in the above functions.
 */

#define SK_PROCSKGR_MERGESK	0x1
#define SK_PROCSKGR_MERGERETURN	0x2
#define SK_PROCSKGR_CLOSED	0x4
#define SK_PROCSKGR_PROCEND	0x8
#define SK_PROCSKGR_FULLYCNSTR	0x10
#define SK_PROCSKGR_DATUMPLANE	0x20
#define SK_PROCSKGR_INTERNCNSTR 0x40
#define SK_PROCSKGR_FULLXFORM   0x80
#define SK_PROCSKGR_GRAPHHANDLE 0x100
#define SK_PROCSKGR_NOPLNORIG	0x200
#define SK_PROCSKGR_CHKCYCLE	0x400

/*
 * Bit mask definitions of geometry and/or geometric-parameters that
 * are driven variationally. 
 */

#define NULL_GEOM    0x0
#define SK_ARC       0x01
#define SK_LINE      0x02
#define SK_POINT     0x04
#define SK_CIRCLE    0x08
#define EMS_PARAMPT  0x10
#define EMS_PARAMVC  0x20
#define EMS_ANYPARAM (EMS_PARAMPT | EMS_PARAMVC)
#define GR_BSPLINE   0x40
#define GR_LINESEG   0x80
#define GR_POINT     0x100
#define DM_SRC	     0x200
#define SK_BSPLINE   0x400
#define SK_ANYGEOM   (SK_ARC | SK_LINE | SK_POINT | SK_CIRCLE | SK_BSPLINE)
#define SK_COMPCURVE 0x800

/*
 * Type definitions for the various geometric constraints in the vg-system
 */

#define SK_CNSTR_GENERAL	0
#define SK_CNSTR_GROUND		1
#define SK_CNSTR_HORIZVERT	2
#define SK_CNSTR_PARALLEL	3
#define SK_CNSTR_NORMAL		4
#define SK_CNSTR_COLLINEAR	5
#define SK_CNSTR_TANGENT	6
#define SK_CNSTR_PTONELEM	7
#define SK_CNSTR_COINCIDENT	8
#define SK_CNSTR_EQUALLEN	9

/*
 * Options used with initialisation of the manager.
 */

#define SK_OPT_NO_STORE_PROPS       0x01
#define SK_OPT_NO_STORE_ORIENTATION 0x02
#define SK_OPT_NO_INIT_SAVE_STATE   0x04

/*
 * Return codes used when converting a composite curve
 * into a profile.
 */
#define SK_CONVERT_VERBOSE			0x01
#define SK_CONVERT_CANT_ELEMENT 		0x02
#define SK_CONVERT_ELEMENT_NOT_SUPPORTED 	0x04
#define SK_CONVERT_OUT_MEMORY 			0x08
#define SK_CONVERT_CYCLE_FOUND 			0x10
#define SK_CONVERT_CURVE_MUST_BE_ON_REF_PLANE 	0x20
#define SK_CONVERT_LINE_MUST_BE_ON_REF_PLANE 	0x40
#define SK_CONVERT_CURVE_MUST_BE_PLANAR 	0x80
#define SK_CONVERT_OK 				0x100
#define SK_CONVERT_NO_AUTO_CONSTRAIN		0x200

#endif
