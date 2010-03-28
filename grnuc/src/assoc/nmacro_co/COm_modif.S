class specification COm_modif (0:1) of COpara;
#include "macro.h"
#include "DIdef.h"
#include "COmdef.h"

/* action and state table  */

#define NUM_STATES 	2
#define NUM_ACTIONS 	7
#define NUM_TOKENS 	2

/*
   different states and actions used in the state/action tables
*/

enum possible_states { 	WAIT_DEF ,
			WAIT_MOD
		     };

enum possible_actions {	NIL,
			ERR,
			RESTART,
			LOC_MAC,
			STO_NAME,
			STO_MAC,
			LOC_FORM,
			MODIFY
	 	       };

/* Possible entries */

enum possible_entries { POINT,
			NOENT };

/* Different fields of the form */

#define FORM_EXEC 2
#define FORM_RESTART 3
#define FORM_ABORT 4
#define MACRO_NAME 23
#define DEF_NAME 16
#define ERROR_BOX 22
#define TEMPLATE_LIST 12
#define OTHER_OPTIONS 11
#define SEARCHDIR 23
#define SEARCHDIR_200 223

#define ACCEPT_OPTIONS 201
#define ABORT_OPTIONS  204
#define DEF_OPTIONS 15

#define DEF_SELECTION 14


#define MAX_OBJ_NUM 60
#define OPT_LEN 80
#define NB_OPT 10


instance COm_modif
{
  int Nb_Max_Temp;				        /* Template name and  */
  variable struct ret_struct Temp_Value[MAX_OBJ_NUM];
  struct sup *dup;
  struct GRid macro_id;
  struct GRid def_id;
  char initial_def_name[DI_PATH_MAX];
  char def_name[DI_PATH_MAX];
  char macro_name[DI_PATH_MAX];
  char *form_ptr,
       *form_select_ptr,
       *form_option_ptr;

  char search_path[DI_PATH_MAX];
  enum ACm_poss_hdr hdr_type;
  enum ACm_poss_scroll hdr_scroll;
  enum ACm_poss_def_par hdr_def;
  int hdr_symb;
  int Entry_Request;
  int Nb_Max_Opt;
  variable char Opt_Name [NB_OPT*OPT_LEN];
  variable struct ret_struct Opt_Value[NB_OPT];
};

override 

  init,
  wakeup,
  sleep,
  execute,
  delete;



message form_notification(int form_label,label;double value; char *fp;
			  int init_notf);

message write_form();

message set_action_and_state(enum possible_actions action;
                             enum possible_states  state);

message realloc_template(int nb_template);

message realloc_opt(int nb_opt);

message delete_form();

end specification COm_modif;
