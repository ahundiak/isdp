#ifndef REgenbs_h
#define REgenbs_h 1
/*
  This include file contains the recomputation information and type 
  definition for the class EMAgenbs. Please make sure when adding types
  to see that the same have not been defined at a parent level. 

   EMS_ASskinning_surface                  1 
   EMS_ASdirect_fit_surface                2
   EMS_ASleast_squares_fit_surface         3 
   EMS_ASdirect_fit_surface_by_curves      4 
   EMS_ASnetwork_of_curves                 5 
   EMS_ASsurface_by_poles                  6 
   EMS_ASsurface_by_bound                  7 
   EMS_ASblend_exterior                    10
   EMS_ASbox_by_4pts                       17
   EMS_AStube_by_linear_and_radii          18
   EMS_ASfitted_surface                    27 
   EMS_ASdefault_ruled_surface             41
   EMS_ASarclength_ruled_surface           42
   EMS_ASdevelopable_ruled_surface         43
   EMS_AScross_section_surface             50


 History:
 Creation : PP : 11/04/91
 Added cross_section_surface type : R.Burkhart : 01/19/95
 */

/*
 * The following definitions are used to interpret the recomputation 
 * information for the skinning surface command.
 */

#define EMS_ASskinning_surface                  1 

/* 
Tangent surf props 
 */
#define EMS_FIRST_SURF 0x1
#define EMS_SECOND_SURF 0x2
#define EMS_THIRD_SURF 0x4
#define EMS_FOURTH_SURF 0x8

/* 
 Skinning surf props
 */

#define EMS_IS_HEIGHT_SCALING 0x1
#define EMS_IS_ABSOLUTE_ORIENTATION 0x2
#define EMS_IS_SHAPE_LAW 0x4
#define EMS_IS_ORIENTATION_LAW 0x8
#define EMS_IS_SURFACE_OPEN 0x10
#define EMS_IS_ARC_LENGTH_PARAM 0x20 /* Indicates that the crosssections
                                        and traces have to be arclength
                                        parametrized */
#define EMS_COMPOSITE_WANTED 0x40 /* Indicates user wants a composite */  

#ifndef __DDP__
struct EMSskinning_surface
{
 unsigned int number_of_sections; /* Number of cross-sections */
 unsigned int number_of_trace_curves; /* Number of trace curves */
 unsigned char tangent_surf_props; /* Tangent surface properties */
 unsigned char skinning_surf_props;/* Skinning surface properties */
 char chardata[1]; /* Contains information about the reversal info for each
                     curve, orientation law curve name, shape law curve name
                   */
};
#endif

/* End skinning surface */

#define EMS_ASleast_squares_fit_surface         3 

/* No recomputation information for EMS_ASleast_squares_fit_surface */


#define EMS_ASnetwork_of_curves                 5 

#ifndef __DDP__
struct EMSnetwork_of_curves /* Structure for recomputing a surface generated
                              through network of curves */
{ 
 unsigned long numu; /* Number of sections in u direction */
 unsigned long numv; /* Number of sections in v direction */
 char rev_info[1];
};
#endif


#define EMS_ASdirect_fit_surface                2
#define EMS_ASdirect_fit_surface_by_curves      4 
#define EMS_ASsurface_by_poles                  6 

/*
 * Recomputation information for the above types is just an array of
 * characters. 
 */

#define EMS_ASsurface_by_bound                  7 

/* No recomputation information for EMS_ASsurface_by_bound */

#define EMS_ASbox_by_4pts                       17

/* No recomputation information for EMS_ASbox_by_4pts */

#define EMS_ASfitted_surface                    27 

#ifndef __DDP__
struct EMSfitted_surface /* Structure for recomputing a fitted surface */
{
 double cht; /* Chord height tolerance */
 char rev_info[1]; /* Information about curve reversals */
};
#endif


#define EMS_ASdefault_ruled_surface             41
#define EMS_ASarclength_ruled_surface           42
#define EMS_ASdevelopable_ruled_surface         43

#ifndef __DDP__
struct EMSruled_surface
{
#define EMS_FIRST_CURVE_REVERSED 0x1
#define EMS_SECOND_CURVE_REVERSED 0x2
 unsigned char rlsf_props;
 unsigned  int num_cp;
 IGRchar chardata[1];
};
#endif

#define EMS_ASblend_exterior                    10

struct EMSblend_surface_exterior
{
#define EMS_SURF1_REVERSED  0x1/* If surf is considered reversed */ 
#define EMS_SURF2_REVERSED  0x2/* If surf is considered reversed */          
#define EMS_BLEND1_REVERSED 0x4/* If the blend direction for surface 1
                                  flows opposite to the natural tangent */
#define EMS_BLEND2_REVERSED 0x8/* If the blend direction for surface 2
                                  flows opposite to the natural tangent */

/*
 * The following options are used in returning blend direction information
 * in the function EFret_blend_dirinfo.
 */
#define EMS_OPT_RET_BLEND_POINT    0x1    /* Used in EFret_blend_dirinfo */
#define EMS_OPT_RET_BLEND_REV_INFO 0x2    /* Used in EFret_blend_dirinfo */

  unsigned char props;
  unsigned char side_1;        /* Natural boundary on which the blend is
                                  created for surface 1 */
  unsigned char side_2;        /* Natural boundary on which the blend is
                                  created for surface 2 */
};

#define EMS_AStube_by_linear_and_radii          18

/* No recomputation information for EMS_AStube_by_linear_and_radii */

#define EMS_AScross_section_surface              50

/*
attach method props
 */
#define EMS_FIRST_ATTCH 0x1
#define EMS_SECOND_ATTCH 0x2
#define EMS_THIRD_ATTCH 0x4
#define EMS_FOURTH_ATTCH 0x8

/*
generation type props
 */
#define EMS_CREA_CURV 0x1
#define EMS_CREA_SURF 0x2
#define EMS_USE_FIRST_CROSSTAN 0x4 /* same as EMS_CREA_SURF and use tangency */
#define EMS_USE_LAST_CROSSTAN 0x8
#define EMS_USE_BOTH_CROSSTAN 0x10

/*
css surf props
 */
#define EMS_IS_TRACE_COMPOSITE 0x1
#define EMS_IS_BLEND_TYPE_PARAMETER 0x2  /* blend linearly according to parameter
                                            or to arc length of trace */
#define EMS_IS_TRACE_CLOSED 0x4
#define EMS_IS_CROSS_SEC_REPARAM 0x8 /* Indicates that the cross-sections
                                        have to be arclength parametrized */

#ifndef __DDP__
struct EMScross_section_surface
{
 unsigned int number_of_sections; /* Number of cross-sections */
 unsigned int number_of_trace_curves; /* Number of trace curves */
 double refpln[12]; /* reference plane info of cross-sections */
 double dirvec[3]; /* direction vector */
 unsigned int mirror_case;
 unsigned char att_method_props; /* attach method properties */
 unsigned char gen_type_props; /* generation type properties */
 unsigned char cross_surf_props; /* Cross-section surface properties */
 char chardata[1]; /* Contains information about reversal info, origin and rotangle
                      for each cross-section, about attachment point trihedron
                   */
};
#endif


#endif
