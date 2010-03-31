/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method outputs the prompt string and returns the mask
 needed by the getevent function for the following simple commands:

                 Command                      my_type
        ----------------------------------    -------
	Change curve order			71
	Change surface order			72
	Increase curve order			73
	Increase surface order			74
	Change rule line display		75
	Place solid by capping surface		76
	Toggle polygon on/off			77
	Insert pole without changing shape	78
	Insert knot				79
	Extend surface - linear			80
	Extend surface - circular		81
	Extend surface - polynomial		82
	Delete surface boundaries		86
	Align 2 curves				87
	Align 2 surfaces			88
	Bezier curves from a bspline curve	89
	Bezier surfaces from a bspline surface	90
	Insert knotline				91
                                                --
	Modify curve shape			106
        Reduce curve data			107
	Modify surface shape			108
						---
	Change curve direction			110
						---
	Reduce surface data			114

 History

 12/28/87 : rlw : The beginning
 01/05/88 : rlw : Added some commands
 01/13/88 : rlw : Modified cap command to locate composite surfaces also
 01/15/88 : rlw : Modified delete boundaries locate to allow for location
                  of dpr classes.
 07/04/88 : rlw : Added modify curve shape command
 07/08/88 : rlw : Added modify surface shape command
 07/20/88 : rlw : Added Change curve direction command
 07/28/88 : rlw : Modified Change rule line display to support fences
                  and also ask for number of rule lines to use.
 08/05/88 : rlw : Changed curve data reduction from a placement command to
                  a modification command.
                  Added surface data reduction command.
 08/09/88 : rlw : Modified delete boundaries to locate composites
 08/26/88 : rlw : Modified such that user cannot reject both directions
                  for modification in surface data reduction.  Also made
                  changes to declare functions for shared libraries.
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
*/

class implementation ECmodify;

%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "EMSdpb.h"		/* To get active rule line counts */
#include "EC_P.h"		/* Message keys for prompt strings */
#include "EC_I.h"		/* Message keys for status strings */

#define BIG_CURVE 0
#define LITTLE_CURVE 1
#define LITTLE_SURFACE 2
#define LITTLE_ELEMENT 3
#define ANY_ELEMENT 4
#define BIG_SURFACE 5

#ifndef IDRAW
extern OMuword OPP_EMSsubbs_class_id;
extern OMuword OPP_EMSsfimpbnd_class_id;
extern OMuword OPP_EMSsflift_class_id;
extern OMuword OPP_EMSsfmove_class_id;
#endif

method next_event_processing(
 IGRchar	*prompt_string;
 IGRlong	*prompt_index;
 IGRlong	*event_mask;
 IGRlong	*type_of_value_needed;
 IGRboolean	*locate_desired;
 struct		RLW_locate_info *loc_info)

{
 void		EFget_locate_information();
 IGRboolean	force_encode;
 IGRlong	key, integer_to_encode, *my_msg, my_type, sts;
/*
 * Compiler optimizations
 */
 my_msg = &me->msg;
 my_type = me->mytype;
/*
 * Initialize
 */
 *my_msg = MSSUCC;
 force_encode = FALSE;
 integer_to_encode = 0;
/*
 * Branch based on the command state
 */
 switch (me->number_of_events_input)
  {
/*
 * Event 1 prompt
 */
   case 0:
    switch (my_type)
     {
      case 71:
      case 73:
      case 78:
      case 79:
      case 89:
      case 106:
      case 107:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_CURVE, loc_info);
       loc_info->operation_type = geometry_modification;
       key = EMS_P_00030;
       switch (my_type)
        {
#ifndef IDRAW
         case 71:
         case 73:
         case 89:
         case 107:
          loc_info->accept_event_type = dummy;
          break;
         case 78:
          loc_info->acc_key = EMS_P_00098;
          break;
#endif
         case 79:
         case 106:
          loc_info->acc_key = EMS_P_00070;
          break;
        } /* switch (my_type) */
       break;
#ifndef IDRAW
      case 72:
      case 74:
      case 80:
      case 81:
      case 82:
      case 90:
      case 91:
      case 108:
      case 114:
       *locate_desired = TRUE;
       EFget_locate_information(LITTLE_SURFACE, loc_info);
       loc_info->operation_type = geometry_modification;
       loc_info->accept_event_type = dummy;
       key = EMS_P_00031;
       switch (my_type)
        {
         case 80:
         case 81:
         case 82:
          loc_info->accept_event_type = good_data;
          loc_info->acc_key = EMS_P_00047;
          break;
         case 91:
         case 108:
          loc_info->accept_event_type = good_data;
          loc_info->acc_key = EMS_P_00068;
          break;
         default:
          break;
        }
       break;
      case 75:
      case 76:
      case 86:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_SURFACE, loc_info);
       loc_info->accept_event_type = dummy;
       switch (my_type)
        {
         case 75:
          key = EMS_P_00134;
          loc_info->operation_type = display_modification;
          loc_info->are_groups_allowed = TRUE;
          break;
         case 76:
         case 86:
          key = EMS_P_00031;
          loc_info->operation_type = geometry_modification;
          break;
        } /* switch (my_type) */
       break;
      case 77:
       *locate_desired = TRUE;
       EFget_locate_information(ANY_ELEMENT, loc_info);
       loc_info->operation_type = display_modification;
       loc_info->are_groups_allowed = TRUE;
       loc_info->accept_event_type = dummy;
       key = EMS_P_00135;
       break;
#endif
      case 87:
      case 88:
       *event_mask &= ~GRm_DATA;
       *type_of_value_needed = SCALAR;
       key = EMS_P_00103;
       break;
#ifndef IDRAW
      case 110:
       *locate_desired = TRUE;
       EFget_locate_information(BIG_CURVE, loc_info);
       loc_info->operation_type = geometry_modification;
       loc_info->accept_event_type = dummy;
       key = EMS_P_00030;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 2 prompt
 */
   case 1:
    switch (my_type)
     {
#ifndef IDRAW
      case 75:
       {
        IGRuchar buffer;
        extern		IGRlong EMdpb_get();

        *event_mask &= ~GRm_DATA;
        *type_of_value_needed = SCALAR;
        key = EMS_P_00151;
        sts = EMdpb_get(
          my_msg,
          EMSdpb_u_rules,
          &buffer);
         if (! (1 & sts)) goto wrapup;
        me->surface_element_specific.u_rules = buffer;
        integer_to_encode = buffer;
        force_encode = TRUE;
       }
       break;
      case 78:
       key = EMS_P_00099;
       break;
#endif
      case 79:
      case 106:
       key = EMS_P_00071;
       break;
#ifndef IDRAW
      case 80:
      case 81:
      case 82:
       key = EMS_P_00064;
       break;
#endif
      case 87:
      case 88:
       {
        IGRlong		mode;

        *locate_desired = TRUE;
        if (my_type == 87)
         {
          EFget_locate_information(LITTLE_CURVE, loc_info);
          loc_info->acc_key = EMS_P_00070;
          key = EMS_P_00035;
         }
#ifndef IDRAW
        else
         {
          EFget_locate_information(LITTLE_SURFACE, loc_info);
          loc_info->acc_key = EMS_P_00047;
          key = EMS_P_00062;
         }
#endif
        integer_to_encode = 1;
        mode = me->events[0].event.value;
        switch (mode)
         {
          case 0:
          case 2:
          case 3:
           loc_info->operation_type = geometry_modification;
           break;
          case 1:
           loc_info->operation_type = info_read_only;
           break;
         } /* switch (mode) */
       }
       break;
#ifndef IDRAW
      case 91:
      case 108:
       key = EMS_P_00069;
       break;
      case 107:
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       key = EMS_P_00142;
       break;
      case 110:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00061;
       break;
      case 114:
       key = EMS_P_00144;
       *event_mask |= GRm_RJT_MOVEON;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 3 prompt
 */
   case 2:
    switch (my_type)
     {
#ifndef IDRAW
      case 75:
       {
        IGRuchar buffer;
        extern		IGRlong EMdpb_get();

        *event_mask &= ~GRm_DATA;
        *type_of_value_needed = SCALAR;
        key = EMS_P_00152;
        sts = EMdpb_get(
          my_msg,
          EMSdpb_v_rules,
          &buffer);
         if (! (1 & sts)) goto wrapup;
        me->surface_element_specific.v_rules = buffer;
        integer_to_encode = buffer;
        force_encode = TRUE;
       }
       break;
      case 79:
       {
        extern	IGRlong EFgetabstract();
        struct	IGRbsp_curve *curve;

        *event_mask &= ~GRm_DATA;
        *type_of_value_needed = SCALAR;
        key = EMS_P_00100;
        sts = EFgetabstract(
          &me->events[0],
          my_id,
          &curve,
          my_msg);
         if (! (1 & sts)) goto wrapup;
        integer_to_encode = curve->order - 1;
       }
       break;
      case 80:
      case 81:
      case 82:
       key = EMS_P_00097;
       break;
#endif
      case 87:
       key = EMS_P_00071;
       break;
#ifndef IDRAW
      case 88:
       key = EMS_P_00064;
       break;
      case 91:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00061;
       break;
#endif
      case 106:
      case 108:
       key = EMS_P_00141;
       break;
#ifndef IDRAW
      case 107:
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       key = EMS_P_00143;
       break;
      case 110:
       *event_mask |= GRm_RJT_MOVEON;
       key = EMS_P_00150;
       break;
      case 114:
       key = EMS_P_00146;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 4 prompt
 */
   case 3:
    switch (my_type)
     {
      case 87:
      case 88:
       {
        IGRlong		mode;

        *locate_desired = TRUE;
        if (my_type == 87)
         {
          EFget_locate_information(LITTLE_CURVE, loc_info);
          loc_info->acc_key = EMS_P_00070;
          key = EMS_P_00035;
         }
#ifndef IDRAW
        else
         {
          EFget_locate_information(LITTLE_SURFACE, loc_info);
          loc_info->acc_key = EMS_P_00047;
          key = EMS_P_00062;
         }
#endif
        integer_to_encode = 2;
        mode = me->events[0].event.value;
        switch (mode)
         {
          case 0:
           loc_info->operation_type = info_read_only;
           break;
          case 1:
          case 2:
          case 3:
           loc_info->operation_type = geometry_modification;
           break;
         } /* switch (mode) */
       }
       break;
#ifndef IDRAW
      case 91:
       {
        extern	IGRlong EFgetabstract();
        struct	IGRbsp_surface *surface;

        *event_mask &= ~GRm_DATA;
        *type_of_value_needed = SCALAR;
        key = EMS_P_00100;
        sts = EFgetabstract(
          &me->events[0],
          my_id,
          &surface,
          my_msg);
         if (! (1 & sts)) goto wrapup;
        if (me->events[0].located_object[0].geom_parms.polygon_inx)
         integer_to_encode = surface->u_order - 1;
        else
         integer_to_encode = surface->v_order - 1;
       }
       break;
#endif
      case 106:
       if (me->events[0].located_object[0].geom_parms.polygon_inx)
        key = EMS_P_00049;	/* Input from point */
       else
        {
         key = EMS_P_00140;	/* Input from point/move on */
         *event_mask |= GRm_RJT_MOVEON;
        }
       break;
#ifndef IDRAW
      case 108:
       if (me->events[0].located_object[0].geom_parms.polygon_inx == 3)
        key = EMS_P_00049;	/* Input from point */
       else
        {
         key = EMS_P_00140;	/* Input from point/move on */
         *event_mask |= GRm_RJT_MOVEON;
        }
       break;
      case 114:
       key = EMS_P_00146;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 5 prompt
 */
   case 4:
    switch (my_type)
     {
      case 87:
       key = EMS_P_00071;
       break;
#ifndef IDRAW
      case 88:
       key = EMS_P_00064;
       break;
#endif
      case 106:
      case 108:
       key = EMS_P_00050;
       break;
#ifndef IDRAW
      case 114:
       if (me->events[1].response == EX_DATA)
        {
         key = EMS_P_00144;
         *event_mask |= GRm_RJT_MOVEON;
        }
       else
        key = EMS_P_00145;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 6 prompt
 */
   case 5:
    switch (my_type)
     {
      case 106:
       key = EMS_P_00142;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
#ifndef IDRAW
      case 108:
       if (me->events[0].located_object[0].geom_parms.polygon_inx & 2)
        key = EMS_P_00145;
       else
        {
         key = EMS_P_00144;
         *event_mask |= GRm_RJT_MOVEON;
        }
       break;
      case 114:
       key = EMS_P_00146;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 7 prompt
 */
   case 6:
    switch (my_type)
     {
      case 106:
       key = EMS_P_00143;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
#ifndef IDRAW
      case 108:
       key = EMS_P_00146;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
      case 114:
       key = EMS_P_00146;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 8 prompt
 */
   case 7:
    switch (my_type)
     {
#ifndef IDRAW
      case 108:
       key = EMS_P_00146;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 9 prompt
 */
   case 8:
    switch (my_type)
     {
#ifndef IDRAW
      case 108:
       if (me->events[5].response != EX_DATA)
        key = EMS_P_00145;
       else
        {
         key = EMS_P_00144;
         *event_mask |= GRm_RJT_MOVEON;
        }
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 10 prompt
 */
   case 9:
    switch (my_type)
     {
#ifndef IDRAW
      case 108:
       key = EMS_P_00146;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Event 11 prompt
 */
   case 10:
    switch (my_type)
     {
#ifndef IDRAW
      case 108:
       key = EMS_P_00146;
       *event_mask &= ~GRm_DATA;
       *event_mask |= GRm_TEXT_VALUE;
       break;
#endif
      default:
       *my_msg = MSFAIL;
       goto wrapup;
     } /* switch (my_type) */
    break;
/*
 * Error 
 */
   default:
    *my_msg = MSFAIL;
    goto wrapup;
  } /* switch (me->number_of_events_input) */
/*
 * Get the prompt string
 */
 if (force_encode ||
     integer_to_encode)
  {
   ex$message(
    msgnumb = key,
    type = "%d",
    var = `integer_to_encode`,
    buff = prompt_string);
  }
 else
  {
   ex$message(
    msgnumb = key,
    buff = prompt_string);
  }
/*
 * eof
 */
wrapup:
 if (1 & *my_msg)
  return(TRUE);
 else
  return(FALSE);
}

end implementation ECmodify;
