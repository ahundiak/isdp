/*
  DESCRIPTION
    
 *  This file contains recomputation information type for features 
 *  belonging to the following classes:
 *  EMSslboolfea
 *  EMSslslotfea
 *  EMSslflanfea
 */

#ifndef EMSasfeatdef_h
#define EMSasfeatdef_h 

/* Feature hole types applicable for EMSslboolfea class  
  NOTE :
   Please DO NOT change the defined numbers
   certain code depends on the fact that the numbers do not repeat
*/

#define EMS_ASCIR_THRU_ALL_HOLE_TYPE    1
#define EMS_ASCIR_THRU_NEXT_HOLE_TYPE 	2
#define EMS_ASCIR_THRU_UNTIL_HOLE_TYPE  3
#define EMS_ASCIR_FINITE_FLAT_HOLE_TYPE 4
#define EMS_ASCIR_FINITE_V_HOLE_TYPE    5
#define EMS_ASPRO_THRU_ALL_HOLE_TYPE    6
#define EMS_ASPRO_THRU_NEXT_HOLE_TYPE   7
#define EMS_ASPRO_THRU_UNTIL_HOLE_TYPE  8
#define EMS_ASCIR_THRU_ALL_HOLE_TYPE_1    21
#define EMS_ASCIR_THRU_NEXT_HOLE_TYPE_1   22	
#define EMS_ASCIR_THRU_UNTIL_HOLE_TYPE_1  23
#define EMS_ASCIR_FINITE_FLAT_HOLE_TYPE_1 24 
#define EMS_ASCIR_FINITE_V_HOLE_TYPE_1    25
#define EMS_ASCIR_THRU_ALL_REFPLANE	  26 
#define EMS_ASCIR_THRU_NEXT_REFPLANE	  27 
#define EMS_ASCIR_THRU_UNTIL_REFPLANE	  28 
#define EMS_ASCIR_FINITE_FLAT_REFPLANE	  29 
#define EMS_ASCIR_FINITE_V_REFPLANE	  30 

/* 
 * recompute information for placing holes. Applies to the above defined
 * types. 
 */

struct EMSplace_hole
{
  IGRint   	hole_count;
  IGRboolean 	axis_normal;
};

/*
 * Feature counterbore/countersink types applicable 
 * for EMSslboolfea class 
 */

#define EMS_ASCSINK_AXIS_NOR_AND_THRU 	11
#define EMS_ASCSINK_AXIS_ALI_AND_THRU 	12
#define EMS_ASCSINK_AXIS_NOR_AND_BLIND 	13
#define EMS_ASCSINK_AXIS_ALI_AND_BLIND 	14
#define EMS_ASCBORE_AXIS_NOR_AND_THRU 	15
#define EMS_ASCBORE_AXIS_ALI_AND_THRU 	16
#define EMS_ASCBORE_AXIS_NOR_AND_BLIND 	17
#define EMS_ASCBORE_AXIS_ALI_AND_BLIND 	18


/* Feature slot - Applies to class EMSslslotfea */

#define EMS_AS_THRU_ALL_SLOT_TYPE    	1
#define EMS_AS_THRU_NEXT_SLOT_TYPE 	2
#define EMS_AS_THRU_UNTIL_SLOT_TYPE  	3
#define EMS_AS_FINITE_SLOT_TYPE 	4

/* 
 * recompute information for placing slot. Applies to class EMSslslotfea. 
 */

struct EMSplace_slot
{
  IGRboolean    dir_rev, pro_nor_rev;
};

/* Feature flange/groove - Applies to EMSslflanfea */

#define EMS_AS_PART_IS_FLANGE		1
#define EMS_AS_PART_IS_GROOVE		2

/* Feature thread types applicable for EMSsfthread/EMSslthread class */

#define EMS_ASTHR_SOLID_VEC_REVERSED       1
#define EMS_ASTHR_SOLID_VEC_NOT_REVERSED   2
#define EMS_ASTHR_SURF_VEC_REVERSED        3
#define EMS_ASTHR_SURF_VEC_NOT_REVERSED    4

#define EMS_I_AM_A_MACFEA_BOSS              1
#define EMS_I_AM_A_MACFEA_POCKET            2
#define EMS_I_AM_A_BOSS                     35 
#define EMS_I_AM_A_POCKET                   36 


#define SURFACES_AND_EDGES_OR_CRVS_OR_SURFS   0
#define SURFACE_AND_SURFACES                  1 
#define REPLACE_SURFACE                       2





/* new definitions for phoenix features */

#define EMS_ASSOC_FEATURE_RIB             1 /* although a kind of add matl */
#define EMS_ASSOC_FEATURE_ADD_MATERIAL    2 
#define EMS_ASSOC_FEATURE_REMOVE_MATERIAL 3

/* recompute data for all features */
struct EMSfeature_data
{
  IGRulong attributes;
  IGRulong more_attributes; /* for future expansion*/
};
#endif
