#ifndef REagrp_h
#define REagrp_h 1

/*
  This include file contains the recomputation information and type 
  definition for the class EMSagrp. 

  EMS_ASintersect_elements 1
  EMS_ASiso_parametric_curves 2


History:
 PP: 11/4/91 : Trying to make some sense of the info spread out in 
               different include files.
 SM: 09/30/92: Added new type to distinguish new data-fitted intersections
               from old types to prevent topology mismatches.
               
*/

#define EMS_ASintersect_elements 	1
#define EMS_ASiso_parametric_curves 	2
/* CHECK WITH THE FILE 'EMSasectvw.h' FOR NON_CONFLICTING DEFINITIONS!!
   DEFINES FROM BOTH THE FILES ARE USED IN trans/EMSasectvw_sp.c ON THE
   SUN.
*/
#define EMS_ASintersect_elements1 	5

struct EMSintersect_elements
{
/*
 * The following properties are supported.
 */
#define EMS_TRIMMING_REQUIRED 0x1 
 unsigned char props;
 IGRdouble cht;
};



struct EMSisoparametric_curves
{
/*
 * The following properties are supported.
 */
#define EMS_TRIMMING_REQUIRED 0x1
#define EMS_USE_U_DIRECTION 0x2
 unsigned char props;
 IGRint num_parms;
 double start_param;
 double end_param;
};
#endif
