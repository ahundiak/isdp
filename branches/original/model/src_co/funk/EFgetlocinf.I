/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function sets up the locate information based on the type
 of locate operation being performed.

 History

 ??/??/87 : rlw : Creation date
 09/20/88 : rlw : Modified to support additional field in locate structure
                  by specifying that objects, by default, are not to be
                  located more than once by a command.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 */

class implementation Root;

//%safe
#include <math.h>
//%endsafe

#include "EMS.h"
#include "ems_m_inc.h"			/* Includes everything */
#include "EC_P.h"			/* Prompt strings */
#include "EC_I.h"			/* Informational strings */

#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2
#define LITTLE_ELEMENT 3
#define ANY_ELEMENT 4
#define BIG_SURFACE 5

extern OMuword OPP_GRbspline_class_id;
extern OMuword OPP_GRcurve_class_id;
#ifndef IDRAW
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsurface_class_id;
#endif

void EFget_locate_information(
option,
loc_info)

IGRlong option;
struct	RLW_locate_info *loc_info;

{
 loc_info->identify_event_type = dummy;
 loc_info->accept_event_type = good_data;
 loc_info->acc_key = EMS_P_00038;
 loc_info->are_groups_allowed = FALSE;
 loc_info->allow_duplicate_objects = FALSE;
 loc_info->planar_flag = LC_PLANAR_NON_PLANAR;
 loc_info->rtree_classes.w_count = 1;
 loc_info->rtree_classes.w_flags = OM_CLST_subclass;
 loc_info->eligible_classes.w_count = 1;
 loc_info->eligible_classes.w_flags = OM_CLST_subclass;

 switch (option)
  {
   case BIG_CURVE:
    loc_info->operation_type = entity_read_only;
    loc_info->relocate_key = EMS_I_00010;
    loc_info->r_classes[0] = OPP_GRbspline_class_id;
    loc_info->e_classes[0] = OPP_GRcurve_class_id;
    break;
   case LITTLE_CURVE:
    loc_info->operation_type = info_read_only;
    loc_info->relocate_key = EMS_I_00010;
    loc_info->r_classes[0] = OPP_GRbspline_class_id;
    loc_info->e_classes[0] = OPP_GRbspline_class_id;
    break;
#ifndef IDRAW
   case LITTLE_SURFACE:
    loc_info->operation_type = info_read_only;
    loc_info->relocate_key = EMS_I_00011;
    loc_info->r_classes[0] = OPP_EMSsubbs_class_id;
    loc_info->e_classes[0] = OPP_EMSsubbs_class_id;
    break;
#endif
   case LITTLE_ELEMENT:
#ifndef IDRAW
    loc_info->rtree_classes.w_count = 2;
    loc_info->eligible_classes.w_count = 2;
#endif
    loc_info->operation_type = info_read_only;
    loc_info->relocate_key = EMS_I_00013;
    loc_info->r_classes[0] = OPP_GRbspline_class_id;
    loc_info->e_classes[0] = OPP_GRbspline_class_id;
#ifndef IDRAW
    loc_info->r_classes[1] = OPP_EMSsubbs_class_id;
    loc_info->e_classes[1] = OPP_EMSsubbs_class_id;
#endif
    break;
   case ANY_ELEMENT:
#ifndef IDRAW
    loc_info->rtree_classes.w_count = 2;
    loc_info->eligible_classes.w_count = 2;
#endif
    loc_info->operation_type = info_read_only;
    loc_info->relocate_key = EMS_I_00013;
    loc_info->r_classes[0] = OPP_GRbspline_class_id;
    loc_info->e_classes[0] = OPP_GRcurve_class_id;
#ifndef IDRAW
    loc_info->e_classes[1] = OPP_EMSsurface_class_id;
    loc_info->r_classes[1] = OPP_EMSsubbs_class_id;
#endif
    break;
#ifndef IDRAW
   case BIG_SURFACE:
    loc_info->rtree_classes.w_count = 1;
    loc_info->eligible_classes.w_count = 1;
    loc_info->operation_type = info_read_only;
    loc_info->relocate_key = EMS_I_00011;
    loc_info->r_classes[0] = OPP_EMSsubbs_class_id;
    loc_info->e_classes[0] = OPP_EMSsurface_class_id;
    break;
#endif
  } /* switch (option) */
}

end implementation Root;
