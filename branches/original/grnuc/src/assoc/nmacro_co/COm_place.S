class specification COm_place (0:1) of COpara;

#include "macro.h"
#include "DIdef.h"
#include "COmdef.h"
#define macro_MAX 40

/*
   Description of the possible entries states and action used in the
   state table of the command object
*/

#define NUM_STATES     	5  	/* NUMber of possible STATES                  */
#define NUM_ACTIONS    	13    	/* NUMber of possible ACTIONS                 */
#define NUM_TOKENS     	4     	/* NUMber of TOKEN (DATA type)                */

enum Poss_Entry
  {
  PROMPT,                    /* when the user get a PROMPT                    */
  PARAM,                     /* when the user identify a PARAMETER            */
  PARENT,                    /* when the user identify a PARENT               */
  NOTHING                    /* when the system wait NOTHING                  */
  };

enum possible_states
  {
  WAIT_MAC,                   	/* wait to locate a MACRO                     */
  WAIT_TEM,                   	/* wait to locate a PARENT                    */
  WAIT_ELI,                   	/* wait to locate an eligible value           */
  FULL_DEF,			/* ready to place			      */
  WAIT_LOA		        /* Wait to load template from an occurence    */
  };

enum possible_actions
  {
  NIL,                       	/* Does not make anything                     */
  ERR_M,                     	/* When an error occurs                       */
  PRO_MAC,                  	/* PRepar to LOCATE a MACRO                   */
  STO_OCC,			/* Store located occurance (modification mode */
  STO_MAC,                  	/* STORE the MACRO LOCATED                    */
  STO_DEF,                  	/* STORE the default definition               */
  CHOSE_TEMP,		        /* Chose the template to select		      */
  PRO_TEMP,                  	/* prepar to LOCATE a PARENT                  */
  STO_ELI,			/* store an eligible value 		      */
  STO_TEMP,                  	/* store the located template                 */
  NEXT_TEMP,                  	/* Goes to the next template                  */
  END_TEMP,			/* User try to stop temp. selection by reset  */
  CREATE_MACRO,			/* Create the macro 			      */
  CREATE_NAME,			/* Give it a name			      */
  PRO_LOAD,			/* Prepare to load template from an occurence */
  STO_LOAD,			/* Store template loaded from an occurence    */
  REM_LOAD,			/* Emd of loading template from an occurence  */
  };

/* Gadget number on the placement forms and sub-forms */

/* placement form */
#define FORM_EXEC 2
#define FORM_ABORT 4
#define FORM_RESTART 3
/*#define EVENT 18 */
#define CMD_NAME 13
/* #define ERROR_BOX 22 */
#define TEMPLATE_LIST 12
#define LOAD_TEMPLATE 18
#define ELIGIBLE_LIST 19
#define DEF_SELECTION 11
#define NAMES 214
#define DEF_OPTIONS 14
#define MAC_NAME 15
#define DEF_NAMES 16
#define SCALE_GADG 17
#define SCALE_FACT 20

/* sub form to define macro name */

#define MACRO_LIB  13
#define MACRO_IN_LIB_TITLE 15
#define MACRO_IN_LIB 14
#define ACCEPT_SELECTION 101
#define ABORT_SELECTION 104


/* sub form to define placement option */

#define LAYER     12
#define COLOR     14
#define WEIGHT    16
#define STYLE     18
#define SCROLLING 21
#define SEARCHDIR 23
#define OCC_TYPE  26
#define ACCEPT_OPTIONS 201
#define ABORT_OPTIONS  204
#define SEARCHDIR_200  223
#define OCC_TYPE_200   226
#define DONT_MVRT 29
#define DEL_NO_CH 30

/* sub form to define names */

#define TEMP_NAME 11
#define OCC_NAME  25
#define ACCEPT_NAMES 301
#define VALID_NAMES  302 
#define RESET_NAMES  303 
#define ABORT_NAMES  304

instance COm_place
  {
  struct GRid 	macro_id;            	/* definition id 		     */
  IGRchar    	macro_name[DI_PATH_MAX];/* definition name                   */
  IGRchar    	def_name[DI_PATH_MAX];  /* name of collection with placement */
					/* option and default template       */
  enum poss_macro     	macro_type;	/* definition type		     */

  struct GRid 	def_id;            	/* default parameter id		     */
  IGRchar    	search_path[DI_PATH_MAX];/* default parameter name           */
  IGRchar 	post_placement[DI_PATH_MAX];/* post placement ppl	     */

  IGRint     	Nb_Max_Temp;            /* Current Number of Template        */
  IGRint     	Nb_Min_Var_Temp;        /* Number Min of Template            */
					/* when variable number of template  */
  IGRint     	Nb_Max_Var_Temp;        /* Number Max of Template            */
					/* when variable number of template  */
variable struct GRid Temp_List[macro_MAX];  /* List of the Templates objid   */
variable struct GRid Temp_Elig[macro_MAX];  /* List of eligible values       */
variable struct ret_struct Temp_Value[macro_MAX]; /* Default value	     */
  struct sup    *dup;			/* template definition		     */
  IGRint        index_to_locate;	/* Index of the template to locate   */
  int 		def_properties;		/* Does the macro has intances to    */
					/* initialize or a variable number   */
					/* of template			     */
  int 		rep;			/* representation to use for the     */
					/* placed occurence		     */
  

  enum ACm_poss_def_par hdr_def;
  enum ACm_poss_scroll hdr_scroll;

  enum Poss_Entry Entry_Request;

  struct GRid   def_hdr;		/* default occurence to take symbology*/
					/* from				      */
  struct GRid   def_window;		/* window where def_hdr is displayed  */
  struct GRid   def_gragad;		/* window where def_hdr is displayed  */
  struct GRid 	hdr;                    /* occurence id */
  enum ACm_poss_hdr	hdr_type;	/* occurence type */
  char 		hdr_name[DI_PATH_MAX];  /* occurance name */
  char		temp_name[DI_PATH_MAX]; /* where to name template */
  int		hdr_symb;

  int		Obj_Generic;		/* Type of object to locate */
  char		Obj_Name[macro_MAX_CHAR];/* Its macro name if macro */

  channel {(abs_ordered, many_to_many,
           initial=1, increment=1)}  located_graphics;
  OM_S_CHANSELECT         located_chansel;      /* located gra chan select    */
  int set_index;			/* index of the objet that is located 
					/* by fence			      */
  IGRdouble scale_fact;
  int  scale_flag;
  char *form_ptr;			/* Pointer to form */
  char *user_form_ptr;

  char *form_option_ptr;		/* pointer to sub form with option    */
  char *form_select_ptr;		/* pointer to sub form with selection */
					/* in library 			      */
  char *form_names_ptr;			/* pointer to sub form with names     */

};

override
  init,
  wakeup,
  sleep,
  delete,
  execute;

message get_form_name(char *form_name);

/* ABSTRACT 
   This message gets the name of the form to use by the command object
   It is called by the method init to allow subclassing with a diferent
   form

   ARGUMENTS

char *form_name OUT : name of the form to use

*/

message form_notification(int form_label,label;double value; char *fp);

/* ABSTRACT 
  
   This method is called when a notification is received from the
   form which drives the command object

*/

message user_form_notification(int form_label,label;double value; char *fp);

/* ABSTRACT 
  
   This method is called when a notification is received from the user
   form which drives the command object
   It the label corresponds to a known label, will call the standart
   form notification method
*/

message write_form();

/* ABSTRACT

   This method field the form which drives the command object
*/


message write_template(struct GRid *template;int itemp);

/* ABSTRACT

   This method writes the item template on the place macro form
   (system or user defined form)
*/

message set_action_and_state(enum possible_actions action;
                             enum possible_states  state);

/* ABSTRACT
   
   Set the action and the state of the command object to the defined values
*/
  

message prompt_macro();

/* ABSTRACT

   This method prompt the user to give the name of the macro he want to place.
   It can be overriden to place a macro with a weel define name by
   - initializing me->macro_name,
   - calling set_action_and_state(STO_MAC,WAIT_TEM)
*/

message get_macro_defn(int *found);

/* ABSTRACT

  From the macro name me->macro_defn 
  - get the macro_id me->macro_id 
  - get template description me->Nb_Max_Temp, me->def_properties, me->dup
    as defined in the message ACmacro_defn.ACgive_upscan
  - get type of the macro j
*/

message place_macro();

/* ABSTRACT
 Place a macro
*/

message modify_macro(long *msg);

/* ABSTRACT
 Modify a macro
*/

message generate_hdr_name();

/* ABSTRACT
 Message called by place macro to generate the name given to the occurence.
 This message is sent when all the template of the occurence have been
 defined.
*/

message get_placement_option(char *default_option_name);

/* ABSTRACT
*/

message get_default_template();

/* ABSTRACT
Get default values for the macro templates.
Default implementation is to search these values 

*/

message gen_missing_temp(long *msg; int i_occ);

message verify_temp_rep(long *msg);

message get_active_symb
	(short *active_level; struct IGRdisplay *active_display;char *dir_name);

message rem_consumed_temp(int i_occ);

message pro_occ();

message pro_template();

/* ABSTRACT
*/

message realloc_template(int nb_template);

/* ABSTRACT
*/

message delete_form();

/* ABSTRACT
Delete macro form 
*/

end specification COm_place;
