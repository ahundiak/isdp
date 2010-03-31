#ifndef EMSasectvw_h
#define EMSasectvw_h 1

/* associative section view object recomp_info types; before defining any new
 * types, check in file REagrp.h since the #defines EMS_ASintersect_elements
 * and EMS_ASintersect_elements1 are used as section view types
 */

#define EMS_ASsect_view    3   /* indicates object's associative instance
                                  data is a struct EMS_ASsect_view_info */
#define EMS_ASsection_view 4   /* indicates object's associative instance
                                  data is a struct EMS_ASsection_view_info;
                                  an orientation vector was added so that
                                  the orientation of the section view will
                                  remain the same no matter which side of the
                                  cutting plane line the section view is on */
#define EMS_ASsectvw       6   /* indicates object's associative instance
                                  data is a struct EMS_ASsectvw_info;
                                  the section view's origin was added so that
                                  if the section view's drawing view attachment
                                  is moved, the section view can be moved
                                  (during NDupdate) instead of being recomputed;
                                  the drawing view also contains the section
                                  view's origin but the drawing view was
                                  already moved and since the section view
                                  didn't have its old origin, it didn't know
                                  where to move from */
#define EMS_ASsectvw_tran       7  
                                  

/* defines for the indices of the parents of section views of type
 *  EMS_ASsect_view
 */

#define CUT_PLN_LINE_INDEX 0
#define DRAW_VIEW_INDEX    1   /* this is the parent channel index at which
                                  to find the Section View's drawing view only
                                  if Section View type == EMS_ASsect_view  */

/* structure and definitions for the "old" type section view - not associative
 * to a drawing view
 */

struct EMSsect_view_info
{
/*
 * The following properties are supported.
 */
#define EMS_TRIMMING_REQUIRED 0x1 

/* The following flags are supported */
#define FIRST_SEG_ALIGN     0x1
#define SV_FIRST_ANGLE_PROJ 0x2
    IGRdouble cht;
    IGRdouble z_vec[3];
    IGRdouble placement_pt[3];
    unsigned char props;
    unsigned char flags;
};

/* structure and definitions for the "new" type section view - now associative
 * to a drawing view
 */

struct EMS_ASsect_view_info
{
/* the following flags are supported */
#define SV_TRIMMING_REQUIRED  0x1
#define SV_FIRST_SEG_ALIGN    0x2
#define SV_SHOW_VISIBLE_LINES 0x4  /* if set, the visible lines of the section
                                    * view will be show if either the section
                                    * view is not aligned or the flag
                                    * SV_PROJ_INTERSECTIONS is set
                                    */
#define SV_PROJ_INTERSECTIONS 0x8  /* if set, indicates that in an aligned
                                    * section view the intersection elements
                                    * that are non-planar to the section plane
                                    * are to be projected onto the section
                                    * plane; otherwise the intersection
                                    * elements are rotated and translated to
                                    * the section plane in which case the flag
                                    * SV_SHOW_VISIBLE_LINES is ignored since
                                    * visible lines can't be shown
                                    */
#define SV_RECREATE_SOLID     0x10 /* Added to take care of Recreate Solid **
                                    * - SpB
                                    */

    IGRdouble cht;
    IGRdouble z_vec[3];
    unsigned short flags;
};

/* structure and definitions for the "newer" type section view - it is a
 * superset of struct EMS_ASsect_view_info above, with an orientation angle
 * added so the section view can maintain the same orientation no matter
 * where the section view is moved in relation to the cutting plane line
 */

struct EMS_ASsection_view_info
{
    IGRdouble rot_angle;           /* angle to rotate the section view elements
                                    * about the rotation axis given that the
                                    * angle between the rotation axis vector
                                    * and z_vec is 90 degrees
                                    */
    struct EMS_ASsect_view_info view_info;
};

/* structure and definitions for the latest type section view (type
 * EMS_ASsectvw) - it is a superset of struct EMS_ASsection_view_info above,
 * with an origin added
 */

struct EMS_ASsectvw_info
{
    IGRdouble rot_angle;           /* angle to rotate the section view elements
                                    * about the rotation axis given that the
                                    * angle between the rotation axis vector
                                    * and z_vec is 90 degrees
                                    */
    IGRdouble origin[3];           /* origin of the section view; also the
                                    * same origin as the section view's drawing
                                    * view
                                    */
    struct EMS_ASsect_view_info view_info;
};


struct EMS_ASsectvw_tran_info
{
    IGRdouble rot_angle;           /* angle to rotate the section view elements
                                    * about the rotation axis given that the
                                    * angle between the rotation axis vector
                                    * and z_vec is 90 degrees
                                    */
    IGRdouble origin[3];           /* origin of the section view; also the
                                    * same origin as the section view's drawing
                                    * view
                                    */
    struct EMS_ASsect_view_info view_info;

    IGRmatrix   rot_matrix;
};
/* structure used to pass information from EMinit_associative to EMSasectvw's
 * override of EMconstruct_associative
 */

struct EMS_SVconstruct_info
{
/* the following flags are supported */
#define EMS_ALIGN_SECTION_VIEW  0x1
    unsigned int    flags;
    IGRint           num_ni_parents;  /* number of non-intersecting parents */
    struct GRid     *ni_parents;
};

#endif
