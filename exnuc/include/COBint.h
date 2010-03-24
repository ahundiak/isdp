/* COBint.h -- internal COB structures and definitions */

#ifndef COBint_h
#define COBint_h

#include "ode_export.h"	  /*** need this for _max_data_union_str ***/

/*************************  moved from tool.h *************************/

typedef union
  {
    int		  i;
    double	  d;
    char	  str [_max_data_union_str];
  } data_union;


/********************  stuff from old "CDO.h"  ************************/

/* --- cdo attribute definitions --- */
#define _ceo_string		 2
#define _ceo_form_name		 4
#define _ceo_version		 7
#define _ceo_form_label		11
#define _ceo_form_display	12
#define _ceo_form_x		13
#define _ceo_form_y		14
#define _ceo_num_states		19
#define _ceo_num_actions	20
#define _ceo_num_action_args	21
#define _ceo_num_trans		22
#define _ceo_num_trans_pods	23

/* pseudo-class names for read_t_attrs() */
#define _ceo_form		12
#define _ceo_init		14
#define _ceo_wakeup		15
#define _ceo_sleep		16
#define _ceo_status_form	17
#define _ceo_delete		18


/************************  stuff from old "CEO.h"  ********************/

/*------- return codes -----*/
#define _ceo 1112


/************************  stuff from old "actions.h"  ***************/

/* ---------- attribute definitions ---------- */
#define _actions		4
#define _actions_class_name	7
#define _actions_class		0
#define _actions_name		1
#define _actions_data		2


/************************  stuff from old "state.h"  ******************/

/* ---------- attribute definitions ---------- */
#define _state		5
#define _state_num	0
#define _state_mask	1


/************************  stuff from old "trans.h"  ******************/

/* ---------- attribute definitions ---------- */
#define _trans		6
#define _trans_pred	0
#define _trans_data	1
#define _trans_next	13
#define _trans_op	4


/********************** stuff for CEO.read_t_file and COB_shove_str ***/
				
#define  FREE_STR_LINE_LENGTH	512	/*** JAJ:11-22-88 ***/
#define  AVG_MSG_NAME_LENGTH	21
#define  AVG_ARG_LENGTH		11
#define  AVG_TRANS_DATA_LENGTH	11
#define  REALLOC_ADD_STR_LINES	1


typedef struct
  { 
    int		class_name; 
    int		attribute;
    char	fmt;	/* attribute format */
    data_union	val;
  } _attr_type;

/* ---------- attr_type setup macros ---------- */
#define _attr_setup( attr, ent, att, frmt ) \
{ \
  memset(&(attr),0,sizeof(_attr_type)); \
  (attr).class_name = ent; \
  (attr).attribute = att; \
  (attr).fmt = frmt; \
}


#endif
