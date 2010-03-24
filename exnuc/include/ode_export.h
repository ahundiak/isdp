 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
		< 1986, 1987, 1988, 1989, 1990, 1991 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35894-0001
  
 */ 

/* ode_export.h -- definitions exported from ode */
#ifndef ode_exporth
#define ode_exporth

#include "COBshfn.h"	/** read_t_next "token" #defines **/
#include "UMS.h"
#include "OMlimits.h"

/*--------  things that are probably defined elsewhere  --------------*/
#define _true			  1
#define _false			  0
#define _max_file_name		256
#define _max_class_name		 OM_K_MAXCLASS_LEN
#define _max_key		 UMS_MAX_BUFLEN


/* ---------- return codes ------------------------------------------ */
#define _ret_setup(f,m,s)	((f)<<16|(m)<<3|(s))
#define _ode			1111
#define COB_E_FORM_NOT_FOUND	_ret_setup (_ode,2,ERRO)  /*** new ***/
#define COB_FORM_NOT_FOUND	COB_E_FORM_NOT_FOUND	  /*** old ***/
#define COB_E_FILTER_FAIL	_ret_setup (_ode,3,ERRO)
#define COB_E_VERS_MISMATCH	_ret_setup (_ode,4,ERRO)
#define COB_E_ARG_NOT_FOUND	_ret_setup (_ode,5,ERRO)
#define COB_E_FORM_LABEL_IN_USE	_ret_setup (_ode,6,ERRO)

/* ---------- for use with ms_on_off keyword -------------------------*/
#define COB_MS_PREV_STATE	(-1)

/* -------------- form display types ------------------------ */
#define _manual_display_form	0
#define _auto_display_form	1
#define _persistent_form	2

/*------------ dynamics ------------------------------------------*/
#define _dynamics_off		0

/*------------ filters ------------------------------------------*/
/* #define _none		0  */
#define _get_event		1
#define _wfi			2
#define _gr_locate		3
#define _gr_locate_noauto	4
#define _gs_locate		5
#define _gr_locate_event3	6
#define _menu			7
#define _gr_locate_noauto_event3 8
#define _gs_locate_noauto	9

/*------------ predicate codes -----------------------------------*/
#define _ceo_else		128
#define _ceo_success		129
#define _ceo_info		130
#define _ceo_warning		131
#define _ceo_error		132
#define _ceo_severe		133
#define _ceo_null_string	134
#define _ceo_angle		135
#define _ceo_distance		136
#define _ceo_text_value		137
#define _ceo_null_text_value	138
#define _ceo_return_code	139
#define _ceo_scalar		140
#define _ceo_mytype		141
#define _ceo_vsd_and_q_empty	142
#define _ceo_vsd_empty		143
#define _ceo_q_empty		144
#define _ceo_max_pred		144 /* ALWAYS set this to the last # */

/*------------ predicate operators -------------------------------*/
#define _ceo_noop	0
#define _ceo_eq		1
#define _ceo_ne		2
#define _ceo_lt		3
#define _ceo_le		4
#define _ceo_ge		5
#define _ceo_gt		6
#define _ceo_subtype	7

/*------------ action codes --------------------------------------*/
/* instance data things */
#define	_help			 1
#define _msg			 2
#define _prompt			 3
#define _status			 4
#define _relocate		 5
#define _accept			 6
#define _filter			 7
#define _execute		 8
#define _dynamics		 9
#define _locate_class		10
#define _locate_props		11
#define _locate_owner		12
#define _locate_display		13
#define _locate_type		14
#define _display_form		15
#define _erase_form		16
#define _hilite_const		17
#define _discon_const		18
#define _hilite_located		19
#define _discon_located		20
#define _event_mask		21
#define _value_type		22
#define _msg_key		23
#define _prompt_key		24
#define _status_key		25
#define _relocate_key		26
#define _accept_key		27
/* #define _init_form		28 */
#define _event_mask1		29
#define _event_mask2		30
#define _locate_rtree		31
#define _locate_eligible	32
#define _do_prompt		33
#define _loc_regex		34
#define _loc_stack_size		35
#define _gsloc_num_inputs	36
#define _gsloc_spec_mask1	37
#define _gsloc_spec_mask2	38
#define _gsloc_spec_prompt1	39
#define _gsloc_spec_prompt2	40
#define _gsloc_spec_prompt1_key	41
#define _gsloc_spec_prompt2_key	42
#define _filter_mode		43
#define _gsloc_spec_mask	44
#define	_const_class		45
#define _erase_form_reset	46
#define _convert_resp_to_mask   47
#define _highlight_mode		48
#define _unhighlight_mode	49
#define _display_mode		50
#define _error_box		51
#define _error_box_key		52
#define _ms_on_off		53
#define _value_type_locate	54
#define _value_type_accept	55
#define _scale_flag		56

/* other things */
#define _terminate	-1
#define _previous_state	-2
#define _suspend	-3
#define _set_next_state	-3
#define _go_next_state	-4

/* ---------- attribute formats and types ---------- */
#define _ascii		'c'
/* #define _float	'f' */
#define _int		'i'

#endif
