/* Command Definition section */

class           ECtrmcrvele             /* Command Object class */
command_string  EM_M_TrimCur,0,EMDlCr   /* command table entry */
super_class     ECconst                 /* parent of Command Object */
spec_path       "$MODEL/spec"           /* path to .S (specification) files */
start_state     id_curve1
product_name    "$MODEL"
options         "si"

/* state_table section - for .T (transition table) file */

state_table

#define MSTRM_DUP_CRV           101  /* duplicate curve located */
#define MSTRM_1_CRV             103  /* 1 curve located */

/* EMtrmcrvele warning return status codes */

#define MSTRM_NONINT_CRV        201 /* non-intersecting with other curves */
#define MSTRM_DISJNT_CRV        203 /* unconnected(disjoint) w/ other curves */
#define MSTRM_AMBIG_CRV         205 /* curve segment ambiguous */
#define MSTRM_INVMULT_CRV       207 /* invalid mult. input, curve disjoint */

/* includes */

#include        "griodef.h"
#include        "lcdef.h"
#include        "msdef.h"
#include        "grmsg.h"
#include        "ECcmd.h"
#include        "ECmsg.h"

state id_curve1
  execute 		init_event1_md_env
  highlight_located     0    /* dehighlight objects on located channel */
  disconnect_located    1    /* disconnect all objects from located channel */

  message_key           EM_M_TrimCur
  status_key            EMS_I_ClearStatusField
  prompt_key            EMS_P_IdCvPtSg
  accept_key            EMS_P_AcPtSgNxCvRj
  relocate_key          EMS_P_CvNotFoundRetry
  locate_class          "GRcurve, SKgeometry"
  locate_display        "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | LC_ACCEPT_CURSOR | LC_ERASE_LOC_ELEMENT"

  locate_properties     "LC_LC_ONLY | LC_DP_ONLY"
  locate_owner          "LC_FLEX_COMP | LC_RIGID_OWNER | LC_RIGID_COMP | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED"

  locate_mask           GRm_DATA
  accept_mask           GRm_DATA
  filter                locate_noauto     /* don't dehighlight object */

  on EX_DATA            do save_loc_info
                        do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
                        state id_curve2


state id_curve2
  status_key            EMS_I_ClearStatusField
  prompt_key            EMS_P_IdNxCvPtSg
  accept_key            EMS_P_AcPtSgNxCvRj
  relocate_key          EMS_P_CvNotFoundRetry

  locate_class          "GRcurve, SKgeometry"
  locate_display        "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | LC_ACCEPT_CURSOR | LC_ERASE_LOC_ELEMENT"

  locate_properties     "LC_LC_ONLY | LC_DP_ONLY"
  locate_owner          "LC_FLEX_COMP | LC_RIGID_OWNER | LC_RIGID_COMP | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED"

  locate_mask           "GRm_DATA | GRm_BACK_UP | GRm_RESTART"
  accept_mask           "GRm_DATA | GRm_RESTART"
  filter                locate_noauto   /* locate but do not dehighlight */

  on EX_DATA            do save_loc_info
/*                                on MSTRM_DUP_CRV state duplicate_curve */
                        do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
                        state id_next_curve

  on EX_BACK_UP         do reject_loc_info
                        state id_curve1

  on EX_RESTART         do restart_cmd
                        state id_curve1


state id_next_curve
  status_key            EMS_I_ClearStatusField
  prompt_key            EMS_P_IdNxCvPtSgMvOn
  accept_key            EMS_P_AcPtSgNxCvRj
  relocate_key          EMS_P_CvNotFoundRetry
  locate_class          "GRcurve, SKgeometry"
  locate_display        "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | LC_ACCEPT_CURSOR | LC_ERASE_LOC_ELEMENT"

  locate_properties     "LC_LC_ONLY | LC_DP_ONLY"
  locate_owner          "LC_FLEX_COMP | LC_RIGID_OWNER |LC_RIGID_COMP | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED"

  locate_mask           "GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON |
  GRm_RESTART"
  accept_mask           "GRm_DATA | GRm_RESTART"
  filter                locate_noauto   /* locate but do not dehighlight */

  on EX_RJT_MOVEON      do process
                           on MSFAIL state proc_error
                           on MSTRM_NONINT_CRV state nonint_curve
                           on MSTRM_INVMULT_CRV state invmult_curve
                           on MSTRM_DISJNT_CRV state disjnt_curve
                           on MSTRM_AMBIG_CRV state ambig_curve
                        state ask_user
  on EX_DATA            do save_loc_info
/*				on MSTRM_DUP_CRV state duplicate_curve */
                        do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
                        state .

  on EX_BACK_UP         do reject_loc_info
				on MSTRM_1_CRV state id_curve2
                        state .

  on EX_RESTART         do restart_cmd
                        state id_curve1

state ask_user
  status_key            EMS_I_ResCvAfTrim
  prompt_key            EMS_P_AcDtBkCn
  filter                get_event
  on EX_BACK_UP         do cancel_result
                        do restart_cmd
                        state id_curve1 /* restart command */
  on EX_DATA            do patch_get_event
                        do confirm_result
                        do restart_cmd
                        state id_curve1 /* restart command */
  on EX_RJT_MOVEON      state .


state proc_error
  prompt_key            EMS_P_MvOnToRs
  status_key            EMS_E_ErrProc
  filter                get_event
  on EX_RJT_MOVEON      do restart_cmd
                        state id_curve1 /* restart command */
  on EX_BACK_UP         state .
  on EX_DATA            state .


/*
state duplicate_curve
  status_key            EMS_P_CvPrevId
  prompt_key            EMS_P_MultInAccYesNo
  mask                  GRm_STRING
  filter                get_event
  on EX_STRING = "y"    do push_accept_event
                        state previous_state
  on ELSE               do reject_loc_info
                        do push_accept_event
                        state previous_state
*/

state nonint_curve
  status_key            EMS_E_ErrNonIsectCvsId
  prompt_key            EMS_P_MvOnToCn
  filter                get_event
  on EX_RJT_MOVEON      do restart_cmd
                        state id_curve1 /* restart command */
  on EX_BACK_UP         state .
  on EX_DATA            state .


state invmult_curve
  status_key            EMS_E_ErrInvMlInCvs
  prompt_key            EMS_P_MvOnToCn
  filter                get_event
  on EX_RJT_MOVEON      do restart_cmd
                        state id_curve1 /* restart command */
  on EX_BACK_UP         state .
  on EX_DATA            state .


state disjnt_curve
  status_key            EMS_E_WrnDsjRslt
  prompt_key            EMS_P_EnDtFrInMvOnCn
  filter                get_event
  on EX_RJT_MOVEON      do cancel_part_result
                        do restart_cmd
                        state id_curve1 /* restart command */
  on EX_DATA            do cancel_part_result
                        do hilight_curves
                        do patch_get_event
                        do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
                        state id_next_curve
  on EX_BACK_UP         state .


state ambig_curve
  status_key            EMS_E_WrnAmbCnd
  prompt_key            EMS_P_EnDtFrInMvOnCn
  filter                get_event
  on EX_RJT_MOVEON      do cancel_part_result
                        do restart_cmd
                        state id_curve1 /* restart command */
  on EX_DATA            do cancel_part_result
                        do hilight_curves
                        do patch_get_event
                        do ECcmd.EMpush_button_on_stack(&me^^CEO_LOCATE.event1)
                        state id_next_curve
  on EX_BACK_UP         state .


  at delete do          my_delete
