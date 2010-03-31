/*
 * This file is created for feature commands (holes, pockets, bosses,
 * counterbore holes, countersink holes) use.
 * 
 * History :  ?????       ??????      Creation
 *            03/02/94    Sanjay      Modified to add the recompute information
 *                                    structure for Add/Remove Material feature
 *                                    for EMS 4.0
 */

# ifndef EMSfeadef_include
# define EMSfeadef_include	1


#ifndef EMSasnuc_h
#include "EMSasnuc.h"   /* for structs EMSobject_info, EMSvalue_info */
#endif

/*
 * This struct is for holes use.
 */

struct	EMShole
{
    IGRdouble	radius;
    IGRdouble	center[3]; /* the base center point */
    IGRpoint	axis_line[2];
    IGRdouble	depth;
};

/*
 * This struct is for pockets and bosses use.
 */

struct	pocket_data
{
    IGRdouble  center[3]; /* the reference center point */
    IGRdouble  depth;
    GRobjid  objid;
};

/*
 * This struct is for counterbore and countersink holes use.
 */

struct	part_data
{
    IGRdouble  center[3]; /* the top center point */
    IGRdouble  depth_pt[3]; /* the bottom center point */
    IGRdouble  hole_depth; /* only for the 'through' counterxxxx hole use */
    IGRdouble  axis_dir[3]; /* the axis unit vector */
    GRobjid  objid;
};

/* This struct is for slot use */

struct	EMSslot
{
    IGRpoint    axis_pts[2];
    IGRdouble  	depth;
    IGRdouble 	dist_move;
    IGRvector   axis_vec;
};


struct	EMSpocket
{
    IGRpoint    axis_pts[2];
    IGRdouble  	depth;
    GRobjid  	objid;
    IGRvector   axis_vec;
};

/* Action handler for place hole command */

struct hole_loc_acthndlr_args {
	struct hole_loc_acthndlr_args *next;
	IGRlong option;
	IGRchar	*acc_prompt;
	IGRlong num_objects;
	OMuword *classids;
	struct GRid my_inst;
};

/* Action handler for place shell solid command */

struct shell_loc_acthndlr_args {
	struct shell_loc_acthndlr_args *next;
	struct GRid my_inst;
};

/* used by command object to pass information to feature placement function
 * about the parents of the rib feature.
 */
struct EMSrib_feature_parent_info
{   struct EMSobject_info profile;
    struct EMSobject_info solid;

   /* Pass back the next four fields using the "valevent" sub-field of 
    * the struct (and set "type" sub-field to EMSdatainfo_event), so that 
    * associativity is maintained, whenever the user keys in a value for these.
    * Otherwise, use the "val" field, with type EMSdatainfo_numeric.
    */
    struct EMSvalue_info thickness;
    struct EMSvalue_info flip_thickness_side;  /* zero or one (boolean)*/
    struct EMSvalue_info flip_projection_side; /* zero or one (boolean)*/
    struct EMSvalue_info proj_dist;
};

/*
 * Parent information structure for Add / Remove Material command object 
 * Creation : Sanjay
 */

struct EMSAddRm_ParentInfo
{
    struct EMSobject_info  profile; /* -- The profile object information
                                          which will be used in secondary
                                          solid creation
                                          Parent : Always
                                       -- */
    union
    {
           struct EMSvector_info projection_vec;
                                    /* -- Projection vector
                                          Parent : If Projected 
                                       -- */
           struct EMSpoint_info  rotational_axis[2];
                                    /* -- Rotational Axis
                                          Parent : If Revolved 
                                       -- */
           struct EMSobject_info trace_curve;
                                    /* -- Trace curve information
                                          Parent : If Skinned 
                                       -- */
    } sweep_dir;

    union
    {
           struct EMSvalue_info  start_sweep_dist[2]; 
                                    /* -- Projection distance 
                                          Parent : If Projected and finite
                                       -- */
           struct EMSvalue_info  start_sweep_angle[2]; 
                                    /* -- Sweep Angle
                                          Parent : If Revolved and finite
                                       -- */
           
           struct EMSobject_info from_to_surfaces[2];
                                    /* -- From and To surface information
                                          Parents : If From - To Option is
                                                    specified
                                       -- */
    } sweep_extent;
                                
    struct EMSobject_info base_solid;
                                    /* -- Base solid Information
                                          Parent : Always
                                       -- */
}; 


#endif
