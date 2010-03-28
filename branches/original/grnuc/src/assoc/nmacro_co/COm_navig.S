
/* form gadget number */


#define SELECTED_LIST   11
#define SUCCESSORS_LIST 12 
#define FEET_LIST       13 
#define ANCESTORS_LIST  14 

#define FEET_TEXT 18

#define FORM_EXIT 1
#define FORM_VALIDATE 2
#define FORM_RESTART 3
#define FORM_ABORT 4

#define SELECT_TEXT 23
#define EVENT_TEXT 20
#define NAVIGATE 21
#define EVENT    22

class specification COm_navig (0:1) of COpara;

#include "growner.h"

instance COm_navig
 {
  variable struct GRobj_env	selected[10],
				successors[10],
				feet[10],
				ancestors[10];
  int n_selected,
      n_successors,
      n_feet,
      n_ancestors;
 
  struct GRobj_env active;
  int active_type;
  int stacked;                 /* 0 : the command is active                   */
			       /* 1 : the command is stacked		      */
			       /* 2 : the command looks like deleted for user */
 };

message form_notification(int form_label,label;double value; char *fp);

message locate_elem(int *response; char *response_data);

message navigate(char *fp);

/*message set_action_and_state(enum possible_actions action;
/*                             enum possible_states  state);
/*****/

message write_form();

override
  init,
  wakeup,
  execute,
  sleep,
  delete;

end specification COm_navig;
 
