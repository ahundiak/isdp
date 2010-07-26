# ifndef emsdattyp_include
# define emsdattyp_include 1

/*
 * Enumerated data-types that indicate different types of 
 * data. This enumerated type may be used to differentiate
 * tag data of various types.
 */

enum EMSdatatype 
  {
  EMSdata_poly2d,     /* Data is a pointer to memory containing a structure
                        of type struct IGRpolyline. 2 dimensional */
  EMSdata_poly3d,     /* Data is a pointer to memory containing a structure
                        of type struct IGRpolyline. 3 dimensional */
  EMSdata_curve2d,    /* Data is a pointer to memory containing a structure
                        of type struct IGRbsp_curve. 2 dimensional poles */
  EMSdata_curve3d,    /* Data is a pointer to memory containing a structure
                        of type struct IGRbsp_curve. 3 dimensional poles */
  EMSdata_surface,    /* Data is a pointer to memory containing a structure
                        of type struct IGRbsp_surface */
  EMSdata_plane,      /* Data is a pointer to memory containing a structure
                        of type struct IGRplane */
  EMSdata_object,     /* Data is a structure of type struct 
                        GRid (not a pointer) */
  EMSdata_null        /* There is no data */
  };


/*
 * A union of data-pointers that point to data of specific type.
 * The type is indicated by the enum EMSdatatype. The enumerated type
 * and this union type go hand in hand. This union is frightfully close
 * to the union IGRgeometries defined in exec. But they do not have the
 * vital field giving a pointer to objid-osnum.
 */

union EMSdata
  {
  struct IGRpolyline *poly;
  struct IGRbsp_curve *curve;
  struct IGRbsp_surface *surface;
  struct IGRplane *plane;
  struct GRid *object;
  };

/*
 * This is a modification of the above union data-type. Eventually, the
 * above data type definition will go out of the system and be replaced by
 * a definition that looks like this.
 */

union EMSaltdata
  {
  struct IGRpolyline poly;
  struct IGRbsp_curve curve;
  };

/*
 * The following structure is used to abstract the various
 * data types. Input and output of data through methods and
 * functions could be based on this structure.
 */

struct EMSdataselect
  {
  enum EMSdatatype datatype;
  union EMSdata data;
  };

/*
 * This is a modification of the above struct data-type. Eventually, the
 * above data type definition will go out of the system and be replaced by
 * a definition that looks like this.
 */

struct EMSaltdataselect
  {
  enum EMSdatatype datatype;
  union EMSaltdata data;
  };

/*
 * This structure is used to form a linked list that 
 * would represent a chain of points on a linestring.
 * Besides the "true value" of the point, the structure
 * also supplies information about it's topological
 * placement along the linestring. For example: if the
 * linked list were to represent intersections on a 
 * linestring, it would be a simple matter to sort them
 * with respect to their occurence on the linestring as the
 * linestring is traversed.
 */

struct EMSpypoint
  {
  IGRpoint point;             /* The actual point. It is the evaluation
                                 of the point using the next two pieces
                                 of data */
  IGRdouble param;            /* If the segment between "span_inx" and
                                 "span_inx+1" was linearly parameterized
                                 from 0 to 1, the exact point is 
                                 at this parameter value */
  IGRlong span_inx;           /* The point lies on this span, ie,
                                 between (and including) the point
                                 with index "span_inx" and point with
                                 index "span_inx+1" */
  unsigned short props;       /* Properties half-word that gives more
                                 information about this point. The usage
                                 of this field is user-specific */
  IGRchar *info;              /* A generic pointer available to store
                                 user specific information */
  struct EMSpypoint *next;    /* Pointer to the next point, if any */
  };


/*
 * Enumerated data-type which is used to specify the kind of constraint
 * to be applied to a data point or value.
 */

enum EMSconstraintype
  {
  EMSconstrain_null,      /* Unconstrained */
  EMSconstrain_fixed,     /* Constrained to be fixed */
  EMSconstrain_tocrv,     /* Constrained along a given curve */
  EMSconstrain_tozdepth,  /* Constrained to a given point's Z-depth in view */
  EMSconstrain_toline     /* Constrained long a given infinite line */
  };

/*
 * Structure used to specify completely the constraint to be applied
 * on a data point or value.
 */

struct EMSdataconstrain
  {
  enum EMSconstraintype type;
  struct EMSdataselect data;
  };



/********************************************

 TEMPORARILY DEFINED, UNTIL THE SUBCURVE_CONCEPT
 IS COMPLETELY STAMPED OUT OF THE SYSTEM.
 THIS SECTION OF THE FILE (UPTO EOF) SHOULD BE
 TREATED AS NON-EXISTENT. IT EXISTS ONLY TO EASE
 THE TRANSFER TO A NON-SUBCURVE-SYSTEM.
                  
********************************************/

# ifndef EMmsg_obj_include
# include "EMmsg_obj.h"
# endif

#endif 
