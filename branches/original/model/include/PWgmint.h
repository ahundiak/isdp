#ifndef _PWgmint_include
#define _PWgmint_include

/*
 * Bit masks that define the containment relative to a geometry that encloses
 * space (could be 2d-space or 3d-space). These bit-masks are typically used 
 * in a properties word in a structure to store this information. 2 (two) bits 
 * are taken up somewhere in the properties word to store this info. Accessor 
 * functions are usually available to extract this information and return an
 * enumerated type that corresponds to these values. Also, provided are two
 * functions, one to get an ASCII string of the enum and the other to return
 * the enum given the ASCII string.
 */

# define PW_CONTAIN_IN        0x01
# define PW_CONTAIN_OUT       0x02
# define PW_CONTAIN_ON        0x03
# define PW_CONTAIN_UNKNOWN   0x00

enum PWcontaintype
{
  PWcontain_in,
  PWcontain_out,
  PWcontain_on,
  PWcontain_unknown
};


/*------------------ Structure definition of PWcvintpt ---------------------
 *
 * Structure used to hold an intersection point between two curves. Each
 * such point on the curve has a counterpart (sibling) point sitting on
 * the other curve.
 */

struct PWcvintpt
{

#define PW_PROP_NOSIBLING   0x01

  unsigned int props;              /*
                                    * 1) 2 bits - Containment of the left
                                    *    neighborhood at this point, wrt to
                                    *    the other curve (which bounds an area)
                                    * 2) 2 bits - Containment of the right
                                    *    neighborhood at this point, wrt to
                                    *    the other curve (which bounds an area)
                                    * 3) 1 bit - Whether this interaction point
                                    *    contains sibling data or not i.e. the
                                    *    interaction point is a result of inte-
                                    *    raction of two curves or not.
                                    * These properties are of this intersection
                                    * point as it is looked at in isolation of
                                    * other intersection points in a set.
                                    * NB: Access functions on this structure
                                    * are used to set/get these properties. 
                                    */

  struct PWcvpt cvpt;              /*
                                    * Complete definition of the intersection
                                    * point
                                    */

  struct PWcvpt sibling;           /* 
                                    * Complete definition of the corresponding
                                    * point on the other curve
                                    */

  struct PWattrib *p_attrib;       /*
                                    * Attributes that may be attached to this
                                    * intersection point. These attributes
                                    * relate to this intersection point in
                                    * isolation of other intersection points
                                    * that may form the complete set.
                                    */
};


/*------------------ Structure definition of PWcvintpt_list----------------
 *
 * Structure to define a doubly-linked list of intersection points on a given
 * curve or a collection of curves. The curve is identified by the "id" within
 * the PWcvpt field. The creation, and manipulation of this list is managed 
 * strictly through functions defined for this data-structure.
 */

struct PWcvintpt_list
{
  struct PWcvintpt_list *p_prev;  /* 
                                   * Pointer to the prev intersection in 
                                   * list
                                   */

  struct PWcvintpt_list *p_next;  /* 
                                   * Pointer to the next intersection in
                                   * list
                                   */

# define PW_PROP_ARBSEQUENCE 0x01
# define PW_PROP_COINCNEXT   0x02
# define PW_PROP_COINCPREV   0x04
# define PW_PROP_INFONODE    0x08

  unsigned int props; 	          /*
                                   * 1) 2 bits - Containment till the 'next'
                                   *    node in this list, wrt to the other
                                   *    intersecting geom (which bounds an 
                                   *    area)
                                   * 2) 2 bits - Containment till the 'prev'
                                   *    node in this list, wrt to the other
                                   *    intersecting goem (which bounds an 
                                   *    area)
                                   * 3) 4 bits - Properties defined 
                                   *    specifically for this structure. 
                                   * These properties pertain to this node as
                                   * it associates with others in this list 
                                   * (and NOT those that pertain to the intpt 
                                   * as it is viewed in isolation). 
                                   * The first property indicates whether this
                                   * node belongs to an arbitrary sequence list
                                   * of nodes. 
                                   * The second two properties tells whether 
                                   * this node in the list is coincident with
                                   * it's adjacent nodes. 
                                   * The last property indicates that this is
                                   * an informational node. 
                                   * NB: Access functions on this structure
                                   * are used to set/get these properties
                                   */

  struct PWcvintpt intpt;         /* Definition of the intersection point */

  struct PWattrib *p_attrib;      /*
                                   * Attributes that may be placed this node.
                                   * Example: When there is containment  
                                   * information as 'IN' indicated by props
                                   * there could be the corresponding loop-id
                                   * stored within which it is in.
                                   * These attributes pertain to this node as
                                   * it associates with others in this list.
                                   */
};


/*------------------ Structure definition of PWcvregion  --------------------
 *
 * Structure that demarcates a region on a given curve. The demarcating points
 * are defined by intersection points.
 */

struct PWcvregion
{
# define PW_PROP_DEGENERATE  0x01

  unsigned int props;             /* 
                                   * 1) 2 bits - Containment of this region 
                                   *    wrt the other curve(s) that bound area.
                                   *    NB: If the containment is 'ON' then
                                   *    the curve(edge) along which this region
                                   *    lies is stored as an attribute (id).
                                   * 2) 1 bit - The region is degenerate or 
                                   *    not.
                                   * These properties pertain to this region
                                   * as it stands in isolation from any that
                                   * may be part of a list or a group.
                                   * NB: Access functions on this structure
                                   * are used to set/get these properties.
                                   */

  struct PWcvintpt regbounds[2];  /*
                                   * The two bounding points defining the
                                   * region. The first index holds the start of
                                   * the region in the logical curve direction 
                                   * and the second holds the stop of the 
                                   * region.
                                   */

  struct PWattrib *p_attrib;      /*
                                   * Attributes that may be placed on this 
                                   * node.
                                   * Example: When there is containment  
                                   * information as 'ON' indicated by props
                                   * there could be the corresponding edge-id
                                   * stored on which it is on.
                                   * These attributes pertain to this region as
                                   * it stands in isolation.
                                   */
                              
};


/*------------------ Structure definition of PWcvregion_list -----------------
 *
 * Structure to define a doubly-linked list of regions on a given curve or a 
 * collection of curves. The creation, and manipulation of this list is 
 * managed strictly through functions defined for this data-structure.
 */

struct PWcvregion_list
{
  struct PWcvregion_list *p_prev; /* Pointer to the prev subsequent region */

  struct PWcvregion_list *p_next; /* Pointer to the next subsequent region */

  unsigned int props;             /* 
                                   * These properties pertain to this node
                                   * as it associates with other in this
                                   * list.
                                   * NB: Access functions on this structure
                                   * are used to set/get these properties.
                                   */

  struct PWcvregion cvregion;     /* The definition of this region */ 

  struct PWattrib *p_attrib;      /*
                                   * Attributes that may be placed on this node
                                   * which pertain to this region as it
                                   * relates with others in the list.
                                   */
};


/*------------------ Structure definition of PWgeomloop ---------------------
 *
 * Structure used to hold a loop which comprises area/hole region on a surface.
 * It contains a list of edges which will form this loop and the edge data can
 * be stored in the model space/ parametric space of the surface.
 */

struct PWgeomloop
{
  struct PWgeomloop *p_prev; /*
                              * Pointer to the prev edge in the list.
                              */

  struct PWgeomloop *p_next; /*
                              * Pointer to the next edge in the list.
                              */

  struct PWattrib *p_attrib; /*
                              * Attributes that may be placed on this node
                              * which pertain to this edge as it relates 
                              * with others in the list.
                              */

  struct PWcvdata edge;      /*
                              * Pointer to the edge geometry.
                              */

  void (*free_edge) (struct PWcvdata *); /*
                                          * Pointer to the function which needs
                                          * be called on the edge to free it's 
                                          * geometry. If it is NULL, standard C
                                          * function "free()" will be invoked.
                                          * This will be especially useful as 
                                          * the memory for the "BScurve" can be
                                          * allocated by one single malloc call
                                          * or by BSalloccv call. If using the
                                          * single malloc call, one can pass in
                                          * NULL otherwise set it to "pwFree
                                          * CvdataGeom".
                                          */
};

/*------------ PROTOTYPES OF FUNCTIONS OPERATING ON THESE STRUCTURES --------*/

#ifndef _cvintpt_proto_h
#include "PWapi/cvintpt.h"
#endif

#ifndef _cvregion_proto_h
#include "PWapi/cvregion.h"
#endif

#ifndef _geomloop_proto_h
#include "PWapi/geomloop.h"
#endif

#endif
