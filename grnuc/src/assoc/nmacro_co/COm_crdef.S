class specification COm_crdef (0:1) of COpara;

#include "macro.h"
#include "DIdef.h"
#include "COmdef.h"

/* action and state table  */

#define NUM_STATES 	2
#define NUM_ACTIONS 	9
#define NUM_TOKENS 	3

#define ND_INVISIBLE 0x100
#define ND_TEMPLATE_AND_FEET 0x200

/*
   different states and actions used in the state/action tables
*/

#define MAX_OBJ_NUM 60

enum possible_states {  WAIT_OBJ, 
			FULL_DEF
		     };

enum possible_actions {	NIL,
			ERR,
			RESTART,
			REG_EXP,
			LOC_OBJ,
			STO_OBJ,
			GET_GRAPH,
			LOC_FORM,
			CREATE_MACRO
	 	       };

/* Possible entries */

enum possible_entries { PARENT,
			POINT,
			NOENT };

/* Different fields of the form */

#define FORM_EXEC 2
#define FORM_RESTART 3
#define FORM_ABORT 4
#define MACRO_NAME 16
#define TEMPLATE_LIST 12
#define ERROR_BOX 22
#define CMD_NAME 13
#define MACRO_TYPE 24
#define FEET_LIST 18
#define SEARCHDIR 23
#define SEARCHDIR_200 223
#define TEMPLATE_TYPE 19

#define ACCEPT_OPTIONS 201
#define ABORT_OPTIONS  204
#define DEF_OPTIONS 15

/* Possible template type */

#define TEMPLATE_OR_FEET  0
#define TEMPLATE_ONLY     1
#define TEMPLATE_AND_FEET 2
#define FEET_ONLY 	  3 

/* Default placement option that can be initialize by startup cmd */

instance COm_crdef
  {
  char macro_name[DI_PATH_MAX]; 	        /* Macro name */

  int Nb_Max_Obj;
  variable struct GRid Obj_List[MAX_OBJ_NUM];     /* List od selected object  */
  variable int         Obj_Info[MAX_OBJ_NUM];     /* their possible position  */

  int Nb_Max_Temp;
  variable struct GRid Temp_List[MAX_OBJ_NUM];    /* List of macro templates  */
  variable char Temp_Name[MAX_OBJ_NUM*macro_MAX_CHAR];  /* corresponding name */
  variable struct ret_struct Temp_Value[MAX_OBJ_NUM];
  variable char Temp_Fixed[MAX_OBJ_NUM];	  /* fixed value or not       */
  
  int Nb_Max_Feet;
  variable struct GRid 	Feet_List[MAX_OBJ_NUM];         /* List of macro feet */
  variable char Feet_Name[MAX_OBJ_NUM*macro_MAX_CHAR];  /* corresponding name */
  variable int Feet_Type[MAX_OBJ_NUM];
  variable char Feet_Removed[MAX_OBJ_NUM];	  	/* Feet removed or not*/

  int template_type;
  struct GRid located_obj;
  enum possible_entries Entry_Request;

  char search_path[DI_PATH_MAX];
  enum ACm_poss_hdr hdr_type;
  enum ACm_poss_scroll hdr_scroll;
  enum ACm_poss_def_par hdr_def;
  int hdr_symb;
  
};

override 

  init,
  wakeup,
  sleep,
  execute,
  delete;



message form_notification(int form_label,label;double value; char *fp;
			  int init_notf);

message write_form(char *fp);

message set_action_and_state(enum possible_actions action;
                             enum possible_states  state);

message realloc_template(int nb_template);

message realloc_feet(int nb_feet);

message realloc_obj(int nb_obj);
end specification COm_crdef;
