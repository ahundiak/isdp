class specification COm_condit (0:1) of COpara;

#include "macro.h"
#include "DIdef.h"
#include "ACcondit.h"
#include "COmdef.h"

/* action and state table  */

#define NUM_STATES 	6
#define NUM_ACTIONS 	14
#define NUM_TOKENS 	3

/*
   different states and actions used in the state/action tables
*/

#define MAX_OBJ_NUM 60

enum possible_states {  WAIT_MACRO, 
			WAIT_VALUE,
			WAIT_NAME,
			WAIT_CONDIT,
			WAIT_DEF_TEMP,
			FULL_DEF
		     };

enum possible_actions {	NIL,
			ERR,
			RESTART,
			GET_MACRO,
			STO_MACRO,
			GET_VALUE,
			STO_VALUE,
			GET_NAME, 
			STO_NAME,
			GET_CONDIT, 
			STO_CONDIT,
			GET_DEF_TEMP,
			STO_DEF_TEMP,
			WAIT,
			CREATE_CONDIT
	 	       };

/* Possible entries */

enum possible_entries { POINT,
			NOENT };

/* Different fields of the form */

#define FORM_EXEC 2
#define FORM_RESTART 3
#define FORM_ABORT 4

#define MACRO_NAME 12
#define COND_VALUE 18
#define MACRO_TEMP 11
#define MACRO_FEET 16

#define CONDIT_NAME 22
#define CONDIT_COND_TEMP 24
#define CONDIT_TEMP 19
#define CONDIT_FEET 21

#define ERROR_BOX 22
#define CMD_NAME 13

#define SCROLL_MACRO 26
#define SCROLL_TEMPLATE 27
#define SCROLL_FEET 28

#define DEF_OPTIONS 23
#define ACCEPT_OPTIONS 201
#define ABORT_OPTIONS 204
#define SEARCHDIR 23
#define SEARCHDIR_200 223

#define MAX_CONS 10

instance COm_condit
{
/***************** different construction entering the condit *****************/
 int nb_macros;
 variable struct GRid       macro[MAX_CONS];
 variable struct ACcond_val value[MAX_CONS];
 variable int first_temp_def[MAX_CONS];
 variable int nb_temp_def[MAX_CONS];

 char condit_name[macro_MAX_CHAR];
 enum possible_entries Entry_Request;

/****************************** condit description ****************************/

  char macro_name[DI_PATH_MAX];                            /* Macro name */

  int Nb_Max_Temp;
  variable char Temp_Name[MAX_OBJ_NUM*macro_MAX_CHAR];  /* template name      */
  variable int Temp_Used[MAX_OBJ_NUM];			/* used by n macros   */
  variable struct ret_struct Temp_Value[MAX_OBJ_NUM];	/* default value      */

  int Nb_Max_Feet;					/* number of feet     */
  variable char Feet_Name[MAX_OBJ_NUM*macro_MAX_CHAR];  /* feet name          */
  variable OM_S_OBJID  Feet_Defid[MAX_OBJ_NUM];  /* id in a default occurence */
  variable int  Feet_Firstm[MAX_OBJ_NUM];  	/* first macro containing it  */

  int active_macro,active_template;	/* macro and template that is given a */
				        /* default value                      */

  int num_default;			/*number max of possible default value*/
					/* Is the addition of the macro temp  */
					/* number			      */
  variable struct ACcond_temp Temp_Def[MAX_OBJ_NUM]; /* array of defautl value*/


  /**************************  placement options ******************************/

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

message write_macro(char *fp; int index; int add);

message write_condit(char *fp);

message find_template(char *name;struct ret_struct *rst;int add_it;
		      int *real_index);

message find_feet(char *name;int add_it;int *visible_index);

message set_action_and_state(enum possible_actions action;
                             enum possible_states  state);

end specification COm_condit;
