#ifndef SKinc_include
#define SKinc_include

/*
 * Structures and the type-properties used to represent geometry.
 */

struct SKline
  {
# define BOUNDED_LINE	1
# define SEMIINFI_LINE	2
# define INFI_LINE	3

  unsigned short type;
  IGRpoint pt1, pt2;
  struct IGRline line;
  };

struct SKbspcurve
  {
# define  CIRCLE_CIR	1

  unsigned short type;
  IGRpoint defpts[3];
  IGRpoint poles[7];
  IGRdouble knots[10];
  IGRdouble weights[7];
  struct IGRbsp_curve curve;
  };


/*
 * Structures and the type-properties used to represent "half"-geometry.
 */

struct SKvector
  {
  unsigned short type;
  IGRvector vec;  
  };

struct SKdistline
  {
  unsigned short type;
  IGRvector distvec;
  IGRdouble vecdist;
  IGRvector dirvec;
  };


/*
 * Data-structures used to represent geometry of all types used in the
 * sketch system.
 */

enum SKgeomtype
  {
  SKvector,
  SKline,
  SKdistline,
  SKbspcurve,
  SKnullgeom
  };

union SKgeom
  {
  struct SKline line;
  struct SKbspcurve bspcurve;
  struct SKvector vector;
  struct SKdistline distline;
  };

struct SKgeomselect
  {
  enum SKgeomtype geomtype;
  union SKgeom geom;
  };


/*
 * Structures used to represent the current state of the system.
 */

struct SKsolvevars
  {
# define VAR_VAL	    0x1
# define VAR_PSEUDO_VAL     0x2
# define VAR_X	            0x4
# define VAR_Y              0x8
# define VAR_AMBIGUOUS      0x10
# define VAR_OVERSOLVED     0x20
# define VAR_NOSOLUTION     0x40
# define VAR_MARKER	    0x1000

# define VAR_SOMEVAL        (VAR_VAL | VAR_PSEUDO_VAL)
# define VAR_FIRSTDIM	    (VAR_VAL | VAR_PSEUDO_VAL | VAR_X)
# define VAR_SECONDDIM      VAR_Y
# define VAR_PT             (VAR_X | VAR_Y)
# define VAR_VAR	    (VAR_SOMEVAL | VAR_PT)

  unsigned short props;
  GRobjid varobj;
  IGRchar *varname;
  IGRdouble var[3];
  IGRint constrid1, constrid2;
  struct SKsolvevars *next;

# define VAR_STATIC_NAMESIZE 10
  IGRchar varname_store[VAR_STATIC_NAMESIZE];
  };


struct SKconstrinfo
  {
# define CONSTR_REGULAR     0x1
# define CONSTR_PSEUDO_EQN  0x2
# define CONSTR_GRND_X      0x4
# define CONSTR_GRND_Y      0x8
# define CONSTR_PSEUDO_VAR  0x10
# define CONSTR_EQUAL_EQN   0x20
# define CONSTR_GEN_EQN     0x40
# define CONSTR_GRND_V      0x80

  unsigned short cprops;
  GRobjid constrid;

  unsigned short vprops;
  GRobjid varsolveid;

  IGRint num_adjvars;
  struct SKsolvevars **adjvars;

# define CONSTR_STATIC_ADJVARSIZE 10
  struct SKsolvevars *adjvar_store[CONSTR_STATIC_ADJVARSIZE];
  };


struct SKvarinfo
  {
  IGRdouble var[2];
  GRobjid varobj;
  };

/*
 * Structures used within the solution process.
 */

struct SKsolvepath
  {
  IGRint num_constrs;

# define PATH_EVALCONSTR    0
# define PATH_SIMULCONSTR   1
# define PATH_OSIMULCONSTR  2

  short *action;

  struct SKconstrinfo *constrs;
  };

struct SKlocus
  {
# define LOCUS_REDUNDANT	0x1
# define LOCUS_AMBIGUOUS	0x2
# define LOCUS_HORIZONTAL	0x4
# define LOCUS_VERTICAL		0x8
# define LOCUS_HORVER		(LOCUS_HORIZONTAL | LOCUS_VERTICAL)

  unsigned short props;
  struct SKgeomselect locus;

  IGRint numconstrobjs;
  GRobjid *constrobjs;

  IGRint numptobjs;
  GRobjid *ptobjs;

  struct SKlocus *next;

# define LOCUS_STATIC_STORESIZE 5

  GRobjid constrobj_store[LOCUS_STATIC_STORESIZE];
  GRobjid ptobj_store[LOCUS_STATIC_STORESIZE];
  };

struct SKhalflocus
  {
#define HLOCUS_USED	0x1

  unsigned short props;
  GRobjid constrobj;
  struct SKlocus *saddlelocus;
  struct SKgeomselect ridegeom;
  GRobjid ride_ptobj;
  struct SKhalflocus *next;
  };


/*
 * The following are class-specific structures used during the construction
 * of constraints
 */

struct SKptptaxis_info
  {
  IGRchar lin_axis;		/* ACT_X_AXIS or ACT_Y_AXIS (dimsrc.h) */
  IGRint num_lin_axis_objs;
  struct GRid lin_axis_objs[2];
  };

struct SKptonelmt_info
  {
  GRobjid elemobj;		/* Object on which the constraint is applied */
  };

/*
 * This structure is used to describe the constraints used to define a given
 * point. Using an array of this, a profile described by the "place profile"
 * command can be fully-constrained.
 */

struct SKcnstr_ptinfo
{
# define PT_NULL	0
# define PT_EVENT	1
# define PT_HORIZ	2
# define PT_VERT	3
# define PT_ORTHO	4
# define PT_COLL	5
# define PT_TANGE       6
# define PT_TANGM	7
# define PT_DIST	8
# define PT_ANGLE	9
# define PT_RADIUS      10
# define PT_PT1_HORIZ	11
# define PT_PT1_VERT	12
# define PT_ONCIRC      13
# define PT_SWEEP	14
# define PT_PROJEVENT   15
# define PT_MERGE	16

  IGRshort pttype[2];
  IGRshort geomtype;

  struct GRevent event;
  IGRdouble value[2];
};

/*
 * Arguments for a locate action handler        --GMK
 */
struct SKlocate_action_args 
{
  struct GRid *selected_object;
};

#endif
