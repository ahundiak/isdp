class specification COm_move (0:1) of COpara;

#include "macro.h"
#include "DIdef.h"
#include "COmdef.h"

/* action and state table  */

#define NUM_STATES 	4
#define NUM_ACTIONS 	12
#define NUM_TOKENS 	4

/*
   different states and actions used in the state/action tables
*/

#define MAX_OBJ_NUM 60

enum possible_states { 	INITIAL  ,
			WAIT_OBJ , 
			WAIT_TEM,
			FULL_DEF
		     };

enum possible_actions {	NIL,
			ERR,
			RESTART,
			REG_EXP,
			LOC_OBJ,
			STO_OBJ,
			GET_GRAPH,
			NEXT_TEMP,
			PRO_TEMP,
			STO_TEMP,
			LOC_FORM,
			COPY,
			MOVE
	 	       };

/* Possible entries */

enum possible_entries { PARENT,
			PARAM,
			POINT,
			NOENT };

/* Different fields of the form */

#define FORM_EXEC 2
#define FORM_ABORT 4
#define FORM_RESTART 3
#define TEMPLATE_LIST 12
#define FEET_LIST 11
#define CMD_NAME 13
#define FORM_COPY 16
#define FORM_MOVE 17

instance COm_move
  {
  int Nb_Max_Obj;
  variable struct GRid Obj_List[MAX_OBJ_NUM];     /* List od selected object  */
  variable int         Obj_Info[MAX_OBJ_NUM];     /* their possible position  */
 
  int Nb_Max_Temp;
  variable struct GRid Temp_List[MAX_OBJ_NUM];    /* List of macro templates  */
  variable struct GRid Temp_Clone[MAX_OBJ_NUM];   /* List of macro templates  */
  variable char Temp_Name[MAX_OBJ_NUM*macro_MAX_CHAR];  /* corresponding name */
  variable char Temp_Clone_Name[MAX_OBJ_NUM*macro_MAX_CHAR];  /* clone name */
  variable struct ret_struct Temp_Value[MAX_OBJ_NUM];
  
  int Nb_Max_Feet;
  variable struct GRid 	Feet_List[MAX_OBJ_NUM];         /* List of macro feet */
  variable char Feet_Name[MAX_OBJ_NUM*macro_MAX_CHAR];  /* corresponding name */
  variable int Feet_Type[MAX_OBJ_NUM];

  channel {(rel_ordered, many_to_many,
           initial=1, increment=1)}  located_graphics;
  OM_S_CHANSELECT         located_chansel;      /* located gra chan select    */
  int set_index;                        /* index of the objet that is located */
                                        /* by fence                           */
  IGRint        index_to_locate;        /* Index of the template to locate    */
  IGRint	root_changed;           /* Indicates if roots have been       */
					/* changed or not 		      */



  struct GRid located_obj;
  enum possible_entries Entry_Request;
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

message copy_graph();

message move_graph();

message realloc_template(int nb_template);

message realloc_feet(int nb_feet);

message realloc_obj(int nb_obj);

end specification COm_move;
