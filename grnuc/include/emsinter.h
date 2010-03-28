#ifndef emsinter_include
#define emsinter_include 1

/*
 * The following structures are used to return the information
 * from the intersection of two arbitrary elements (including
 * composites). These structures are designed for the worst case of
 * intersection between two composite surfaces, with the intersection
 * between two curves as the simplest, special case.
 *
 * NOTE: The field 'props' in the EMSintobj structure has been typed as
 *       'unsigned short' instead of 'IGRushort' because of an
 *       apparent bug in the OM-opp code which refuses to allow it. Once
 *       the bug is fixed, the type should be coded with 'IGRshort'.
 *
 * SS	prehistoric	creation.
 * SM	15-April-88	added field 'more_info' to the struture. The use
 *			of this field is user specific. For e.g it can
 *			be used to contain the pointer to the geometry of
 *			component on which the intersection occured.
 * SS	20-Jul-88	added field '*fwd and *bwd to the EMSintobj structure.
 *			This pointer points to the next (and/or previous)
 *			intobj which is contiguous with this intobj. These
 *			fields were originally represented by a single 
 *			'*connecting_intobj' defined by SM on 15-Jun-88.
 * SS   25-Jul-91       Added the "props" field to EMSinters and made the
 *                      "props" field in EMSintobj an "unsigned long" in
 *                      place of "unsigned short".
 * NP   27-May-93       Added the "curve_type" field to the EMSintobj struct.
 */

struct EMSinters
  {
  unsigned long props;      /* Properties of this EMSinters node. See
                               emsinterdef.h for these */
  struct GRid this_obj;     /* The GRid of the component on which
                               the intersection is being returned.
                               The rest of the structure deals with 
                               this component */
  IGRlong num_pts;          /* Number of point-intersections being
                               returned */
  struct EMSintobj *pts;    /* The list containing the point-intersection
                               data. Each node of this list contains
                               xyz and/or parametric points */
  IGRlong num_cvs;          /* Number of curve-intersections being
                               returned */
  struct EMSintobj *cvs;    /* The list containing the curve-intersection
                               data. Each node of this list contains
                               xyz and/or parametric points */
                            /* If intersections routines, some day have the
                               capability to return overlapping surfaces
                               in the case of surface-surface intersection,
                               this structure will have to be expanded
                               accordingly */
  IGRchar *more_info;	    /* Generic pointer. The use can be user 
                               specific */
  struct EMSinters *next;   /* Pointer to the next component on which an
                               intersection was detected. NULL if no other
                               component exists */
  IGRint *num_coincs;
  IGRint **coinc_info_list;    /* Pointer to an array containing  sf-sf
                               coincidence matrix */

  };


/*
 * This structure is used to form the linked list that 
 * contains the information on the intersection objects
 * on a given component (or simple object) returned by
 * the intersection routine.
 */

struct EMSintobj 
  {
  struct EMSdataselect
   this_xyzintobj;           /* (One of the) intersection objects produced
                                on this_obj. This object is the intersection
                                in model or world space */
  struct EMSdataselect
   this_uvintobj;            /* (One of the) intersection objects produced
                                on this_obj. This oject is the intersection
                                in parametric space */
  IGRboolean
   reversed;                 /* Flag giving information about the orientation
                                of the intersection-data. If TRUE, the
                                data should be viewed reversed */
  unsigned long
   props;                    /* Properties mask that further classifies the
                                intersection data. This field is user 
                                specific */
  struct EMSinters
   *this_obj_node;           /* Pointer to the EMSinters node that contains
                                this (component) object on which this
                                intersection is produced */
  struct EMSintobj
   *other_intobj_node;       /* Pointer to the EMSintobj node that contains
                                the corresponding intersection object 
                                produced on the other (component) object */
  IGRchar
   *more_info;	             /* A pointer to some data-structure that gives
                                more information on this intersection
                                object. It is free for different
                                interpretation by different kinds of
                                intersections. Therefore, the user needs to
                                know the exact type of information being
                                returned by the specific method/routine. 
                                Could be NULL */
  struct EMSintobj 
    *fwd, *bwd;		     /* Pointer to intobj(s) which is(are) contiguous
    				with this intobj in model space or parametric
				space. 'fwd' points to the logical next and
				'bwd to the logical previous. If set to NULL,
				the contiguity is not known. Property masks
				may also be used indicate a definite lack of
				continuity. See emssfintdef.h */
  struct EMSintobj
    *next;		     /* Pointer to the next intersection object
                                (if any) produced on the this_obj */
  IGRuchar
    curve_type;              /* Type of curve this intobj is. Examples of 
                                curve types are EMfreeform_curve, EMcircle,
                                EMelliptical_arc, EMlinesegment, EMpoint etc. 
                                (include file emsedgedef.h has the types).
                              */

  IGRuint classification;    /* Classification of intobj, which defines its
                                orientation. Pre EMS 3.2 Additional field 
                                for Project PATHWAY. */

  GRobjid coinced;           /* Coincident edge ID.  Pre EMS 3.2 Additional 
                                field for Project PATHWAY. */
       
  };

/*
 * This structure is used as the argument to a function that fetches
 * geometry adjacent to a given one. This structure is primarily designed
 * to work with edges of a surface-boundary but can be used in a more
 * general context. This structure is used as communication vehicle
 * to and from the function.
 */

struct EMSgetadjgeom
  {
  IGRlong msg;			   /* The completion code id returned in
				      this field. */
  IGRchar *geninfo;                /* Pointer to any kind of information that
                                      might be needed by the extraction
                                      function */
  GRobjid this_edge;               /* If the geometry is in surface-edges,
			 	      the objid of this edge */
  IGRboolean at_stop;              /* Whether the geometry to be obtained is
 				      next to the start or the stop point */
  struct EMSdataselect adjdata;    /* The field in which the adjacent geometry
				      will be returned */
  };


/*
 * This enumerated type is used to classify curve intersections
 * according to the orientation of the curve to the intersecting
 * object at the intersection point.
 */

enum EMScvinttype
  {
  EMScvint_middle,         /* Intersection at middle of
                              curve */
  EMScvint_end,            /* Intersection at an endpoint but not
                              known if right or left. */
  EMScvint_rtend,          /* Intersection at the right 
                              endpoint */
  EMScvint_lfend,          /* Intersection at the left
                              endpoint */
  EMScvint_endcoll,        /* At an endpoint and the intersecting object
                              is collinear at the intersection point */
  EMScvint_rtendcoll,      /* At right endpoint and intersecting object
                              is collinear at the intersection point */
  EMScvint_lfendcoll,      /* At left endpoint and intersecting object
                              is collinear at the intersection point */
  EMScvint_collapsed,      /* The intersecting curve is degenerate
                              with it's geometry collapsed to a point */
  EMScvint_overlap,        /* The intersection is not a point but some
                              portion of the intersecting curve */
  EMScvint_unknown         /* Just as the label says. It is intended
                              as a catch-all */
  };

/*
 * This enumerated type is used to classify the relative orientation of one
 * element w.r.t. another that bounds some area/volume. The element can
 * be classified as either going frm hole to area/volume, vice versa
 * or even hole to hole, area to area.
 */

enum EMSrelorient
  {
   EMSrelorient_hole_area,    /* The element naturally proceeds from a hole
                               region into the area/volume */
   EMSrelorient_area_hole,    /* The element naturally proceeds from area
		               region into a hole */
   EMSrelorient_hole_hole,    /* The element naturally proceeds from a hole
		               and remains in hole */
   EMSrelorient_area_area,    /* The element naturally proceeds from an area
                               and remains in area */
   EMSrelorient_unknown       /* When the orientation is unknown */
   };


#endif 
