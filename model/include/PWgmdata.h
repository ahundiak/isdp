#ifndef _PWgmdata_include
#define _PWgmdata_include

#ifndef igrtypedef_include
#include "igr_include/igrtypedef.h"
#endif

#ifndef igr_include
#include "igr_include/igr.h"
#endif

#ifndef bsgeom_cvsf_include
#include "bsgeom_cvsf.h"
#endif

/*--------------------- struct PWgeomid -----------------------------------
 *
 * This structure identifies an object (id.objid) inside an object-space 
 * (id.osnum) and knows that a transform (mat) needs to be applied to the way 
 * it is locally stored within the object in order to get the geometry in the 
 * target space. Thus the information is complete enough to be able to extract
 * or put geometry. API exist to read and write to a file.
 */

struct PWgeomid
{
  struct PWid id;
  short mattyp;
  PWmatrix mat;
};

/*------------------ struct PWpoly, struct PWpoly2d -------------------------
 *
 * Following structure define polylines in 3d and 2d respectively. Read/write
 * functions are provided.
 */

struct PWpoly
{
  int num_pts;
  PWpoint *p_pts;
};

struct PWpoly2d
{
  int num_pts;
  PWpoint2d *p_pts;
};


/*--------------------- struct PWplane ------------------------------------
 *
 * Structure that holds the information to define an infinite plane 
 * completely. Read/write functions are provided.
 */

struct PWplane
{
  PWpoint pt;
  PWvector normal;
};


/*--------------- struct IGRbsp_curve, struct IGRbsp_surface ---------------
 *
 * Structures that define general B-spline curves and surfaces. These are 
 * actually found in the igrtypedef file within igr_include dir in the
 * B-spline math layer. They are not duplicated here. These structures are
 * fairly obvious. Functions are provided to read and write these from and to 
 * files.
 */


 
/*-------------------- struct PWcvdata ------------------------------------
 *
 * An abstract way of defining a curve since a curve can be defined in so
 * many ways. Functions that input/output this datatype are capable of handling
 * all the sub datatypes of the curve (unless they post restrictions of their
 * own). Note that 'null' is a datatype. This is the way of specifying that
 * no curve is available. Some functions can handle this. 
 * A string function is available to obtain an ASCII representation of this
 * enum. Another function takes in the string and outputs the enum.
 */

enum PWcvdatatype
{
  PWcvdata_null,
  PWcvdata_pt2d,
  PWcvdata_pt,
  PWcvdata_py2d, 
  PWcvdata_py, 
  PWcvdata_bspcv, 
  PWcvdata_gmbspcv 
};

struct PWcvdata
{
  enum PWcvdatatype datatype;
  
  union 
  {
    PWpoint2d pt2d;
    PWpoint pt;
    struct PWpoly2d py2d; 
    struct PWpoly py;
    struct IGRbsp_curve *p_bspcv;
    struct BSgeom_bsp_curve *p_gmbspcv;
  } data;
};
 

/*---------------------- struct PWsfdata ----------------------------------
 *
 * An abstract way of defining a surface since a surface can be defined in so
 * many ways. Functions that input/output this datatype are capable of handling
 * all the sub datatypes of the surface (unless they post restrictions of their
 * own). Note that 'null' is a datatype. This is the way of specifying that
 * no surface is available. Some functions can handle this.
 * A string function is available to obtain an ASCII representation of this
 * enum. Another function takes in the string and outputs the enum.
 */

enum PWsfdatatype
{
  PWsfdata_null, 
  PWsfdata_plane, 
  PWsfdata_bspsf, 
  PWsfdata_gmbspsf
};

struct PWsfdata
{
  enum PWsfdatatype datatype;
  
  union 
  {
    struct PWplane plane; 
    struct IGRbsp_surface *p_bspsf;
    struct BSgeom_bsp_surf *p_gmbspsf;
  } data;
};
 

/*----------------------- Topological position ----------------------------
 *
 * Bit masks that define the topological position on a curve. These bit-masks  
 * are typically used in a properties word in a structure to store this 
 * information. 2 (two) bits are taken up somewhere in the properties word to 
 * store this info. Accessor functions are usually available to extract this 
 * information and return an enumerated type that corresponds to these values.
 * A string function is available to obtain an ASCII representation of this
 * enum. Another function takes in the string and outputs the enum.
 */

#define PW_TOPOPOS_START     0x01
#define PW_TOPOPOS_STOP      0x02
#define PW_TOPOPOS_MIDDLE    0x03
#define PW_TOPOPOS_UNKNOWN   0x00

enum PWtopopostype
{
  PWtopopos_start,
  PWtopopos_stop,
  PWtopopos_middle,
  PWtopopos_unknown
};


/*
 * This is the enumerated type that enumerate that various topological
 * positions a point can occupy with respect to geometries like Surface,
 * Loop (Face or Hole), Edge.
 */

enum PWptloctype
{
  PWptloc_unknown,
  PWptloc_onstartvtx,
  PWptloc_onstopvtx,
  PWptloc_onedge,
  PWptloc_inarea,
  PWptloc_inhole,
  PWptloc_outside
};


/*-------------------- struct PWcvparam ----------------------------------
 *
 * This is a structure that defines the parameter of a point on a curve in two 
 * parts - span of the curve on which the point lies and the parameter on that 
 * span (param ranges frmo 0 to 1) at which the point lies.
 */

struct PWcvparam
{
  int spaninx;                       /*
                                      * A B-spline curve is regarded as having
                                      * only one span (span_inx == 0, always).
                                      * A polyline is considered made up of
                                      * numpts-1 spans (span_inx ranges from 0
                                      * to numpts-2).
                                      */
                     
  double spanpar;                    /*
                                      * The parameter value on the span at 
                                      * which the point lies. Each span is
                                      * parameterized from 0 to 1 but only in
                                      * the case of a linear span is it 
                                      * guaranteed to be uniform.
                                      */                                    
};


/*--------------------- struct PWcvpt --------------------------------------
 *
 * This is the structure that contains all the relevant information that 
 * positions the point on the curve. 
 */

struct PWcvpt
{
  unsigned int props;           /* 
                                 * 1) 2 bits - Toplogical position on the curve
                                 * NB: Access functions are used on this 
                                 * structure to get and set these properties. 
                                 */

  double pt[3];                 /*  
                                 * Co-ordinates of the point. These may have 2 
                                 * or 3 dimensions. This is known in the 
                                 * context in which this structure is used 
                                 */

  struct PWcvparam cvparam;     /*
                                 * Parameter on the curve at which this point 
                                 * sits 
                                 */

  unsigned int cvid;            /*
                                 * Id of the curve. Note that this is not Pwid 
                                 * or a PWgeomid and as such does not fully 
                                 * define the curve. This Id can be thus used 
                                 * only if the relevant context is known 
                                 * (OS, matrix, etc).
                                 */

  struct PWattrib *p_attrib;    /*
                                 * Attributes on this point. If NULL then no 
                                 * attributes exist.
                                 */
};


/*-------------------  struct PWsfpt -------------------------------------
 *
 * This is the structure that contains all the relevant information that 
 * positions the point on the surface. 
 */

struct PWsfpt
{
  unsigned int props;           /* 
                                 * NB: Access functions are used on this 
                                 * structure to get and set these properties. 
                                 */

  PWpoint pt;                   /*  
                                 * XYZ co-ordinates of the point.
                                 */

  PWpoint2d uvpt;               /*
                                 * UV co-ordinates of the corresponding point
                                 * in the parametric space.
                                 */

  PWobjid sfid;                 /*
                                 * Id of the surface. Note that this is not
                                 * a PWid or a PWgeomid and as such does not
                                 * fully define the surface. This id can be
                                 * used only if the relevant context is known 
                                 * (OS, matrix, etc).
                                 */

  struct PWattrib *p_attrib;    /*
                                 * Attributes on this point. If NULL then no 
                                 * attributes exist.
                                 */
};
 

/*------------------ enum PWcnvxtype -------------------------------
 *
 * This is the enumerated type that lists out the convexity-related
 * typing that an entity can get. For example: edge, 2D vertex, etc.
 * One could think of applying this same enumerated typing to the second
 * order (curvature) of that entity. Thus we may have an edge 'neutral'
 * in the first order but 'convex' in the second order, etc.
 */

enum PWcnvxtype
{
  PWcnvx_unknown,
  PWcnvx_convex,
  PWcnvx_concave,
  PWcnvx_neutral
};

/*---------------- enum PWfeattype ----------------------------------
 * 
 * This enumeration is for the various kinds of Feature operations.
 * Boolean operation is a special kind of feature operation and is treated
 * more granularly, with it's own enumeration type, below. Note that
 * 'protrusion' is also called 'add-material' and 'cutout' is also called 
 * 'remove-material'. 'Protrusion' and 'Cutout' are used to distinguish
 * from features like holes and ribs which also remove and add material.
 */

enum PWfeattype
{
  PWfeat_unknown,

  /*
   * Preferred feature set
   */

  PWfeat_addmaterial,
  PWfeat_removematerial,
  PWfeat_thinwall,
  PWfeat_adddraft,
  PWfeat_round,
  PWfeat_boolean,

  /*
   * Not so preferred. Limited support.
   */

  PWfeat_hole,
  PWfeat_counterbore,
  PWfeat_countersink,
  PWfeat_rib,
  PWfeat_imposebnd,
  PWfeat_stitch,
  PWfeat_unitesf,
  PWfeat_delbnd,

  /*
   * Features being phased out.
   */

  PWfeat_makeface,
  PWfeat_liftface,
  PWfeat_replacesf,
  PWfeat_boss,
  PWfeat_pocket,
  PWfeat_cutout,
  PWfeat_slot
};


/*---------------- enum PWbooltype ----------------------------------
 * 
 * This enumeration is for the 3 primary kinds of Boolean operations
 * (union, intersection and difference) and a fourth kind -- the save
 * side operation, which is really a difference except that the diff-
 * erencer is an infinite plane.
 */

enum PWbooltype
{
  PWbool_unknown,
  PWbool_union,
  PWbool_intersection,
  PWbool_difference,
  PWbool_saveside
};


/* ----------------- struct PWadjseg --------------------------------
 *
 * This is the structure that contains the information related to  an
 * adjacent segment which can define it's position w.r.t. to  another
 * segment unambiguously. It contains the center of curvature and the
 * tangent at one end of the segment. This will be helpful when clas-
 * fying an end interaction point w.r.t. adjacent segment.
 */ 


struct PWadjseg
{
  PWpoint    adjpt;    /* 
                        * adjacent segment point, which will define 
                        * it's tangent vector.
                        */ 
  struct PWcvdata  *p_cvdata;

  PWboolean        reversed;
};

/*------------ PROTOTYPES OF FUNCTIONS OPERATING ON THESE STRUCTURES --------*/

#ifndef _gmdata_proto_h
#include "PWapi/gmdata.h"
#endif

#endif
