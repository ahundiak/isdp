/*
/*---------------------------------------------------------------------------
/*  ACm_macro_defn.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/*	This is the class of objects that keeps definitions
/*	of macros. These macro definition are access through the 
/*	directory system(and if not there dynamically loaded).
/*	They are too access through their channel connection to
/*	macro occurences.
/*---------------------------------------------------------------------------*/
class specification ACmacro_defn (0:0) of ACcomplex,ASnode,ACcpx_defn;

#include "macro.h"

instance ACmacro_defn 
{
  /* Search structure used in command object copy of macro */ 
  int tot_up;
  variable struct sup xdup[0];
  

  /*current mapped symbol macro */
  struct GRid symbol_macro; 
  variable char inst_save[0];
  int sz_inst_save;

  /* struct for fast ndcompute */
  int  tot_assoc;
  char *comp_struct;
  char *map_struct;
  char *go_struct;
};

/* override unknown; */

/*---------------------------------------------------------------------------
/* message called when a definition is created in alibrary 
/* or when a local copy of the definition is put in the design 
/* this message deal with the problem of nested macros
/*-------------------------------------------------------------------------*/
override  	NDprint_root,
		NDsleep,
		NDgive_structure;

reject  	NDmove_to_root;

/* Change also name in the instances */
override	GRputname,
		GRchgname;

/* Returns correct string when located */
override 	GRgetobjinfo,
		GRgetsymb;

/*
   create instead a temporary definition to be able to rebind occurences that
   are in the same object space 
*/

override delete;



/*  PRIVATE MESSAGES */

message ACbuild_macro(
	int *suc, prop;	char *macro_name;
	int tot_up;	struct GRid *template;	struct sup *xdup;
        int tot_temp;	struct stemp *xdtemp; 
	int feet_num;	struct myfeet *myfeet;	struct GRid *feetlist;
        struct GRid  macro_hdr;	struct GRmd_env *md_env);

message ACbuild_min_macro(
        int *suc, prop; char *macro_name;
        int tot_up;     struct GRid *template;  struct sup *xdup;
        int tot_temp;   struct stemp *xdtemp;
        int feet_num;   struct myfeet *myfeet;  struct GRid *feetlist;
        struct GRid  macro_hdr; struct GRmd_env *md_env);

/*---------------------------------------------------------------------------
/* 	ACcreate function 
/*
/*      Argument description :
/*      --------------------
/*
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*
/*	int prop		I :
/*
/*	  #define ACkeep_no_real_template 1
/*	  #define AChmc_nocopy      	2 /* take the original as def graph   */
/*	  #define ACsame_feet_in_set  	4
/*	  #define ACcant_place_sym	8 /*also used if overflow in map from */
/*	  #define ACextern_no_copy	16/* copy extern of the def graph     */
/*
/*	char *macro_name	I : the macro name 
/*
/*	int tot_up		I : the number of real template
/*
/*	struct GRid *template	I : the list of template
/*
/*	struct sup *xdup	I : strusture describing upscan.
/*
/*	int tot_temp		I : the number of template definition 
/*
/*	struct stemp *xdtemp	I : strusture describing the templates.
/*
/*	int feet_num		I : the number of feet
/*
/*	struct myfeet *myfeet	I : structure describing the feet
/*
/*	struct GRid *feetlist	I : the list of feet
/*
/*	struct GRid  macro_hdr	I : the ACcreate that is driving 
/*				the construction of a macro
/*
/*	struct GRmd_env *md_env	I);
/*
/*---------------------------------------------------------------------------*/


message ACtake_template(int tot_up;struct sup *xdup;
                	int tot_temp;struct stemp *xdtemp);
/*---------------------------------------------------------------------------
/* 	Load new template definitions 
/*
/*      Argument description :
/*      --------------------
/*
/*	int tot_up		I : the number of real template as necessary 
/*				at the placement of an occurence.
/*
/*	struct sup *xdup	I : strusture describing upscan.
/*		
/*	int tot_temp		I : the number of template definition. 
/*				This number can be larger from the number
/*				tot_up. this hapens when some of the templates
/*				as defined in the definition are mapped
/*				to the same real template at placement.
/*
/*	struct stemp *xdtemp	I : strusture describing the template.
/*
/*---------------------------------------------------------------------------*/

message ACtake_feet(int tot_feet;struct myfeet *feet_desc);

/*---------------------------------------------------------------------------
/* 	Load new feet definitions 
/*
/*      Argument description :
/*      --------------------
/*
/* PRIVATE messages for ACsym computing */
/*      Argument description :
/*      --------------------
/*
/*	int tot_feet	I : the number of feet
/*
/*	struct myfeet 	I : structure describing feet.
/*		
/*---------------------------------------------------------------------------*/


message ACinit_map_ptr(long *msg; struct GRid *list; int nb_temp);

/*---------------------------------------------------------------------------
/* ABSTRACT
/* Initialize the array that describes the parents of the computed or copied
/* macro
/* 
/* Arguments
/* 
/* *msg    O : return code
/* list    I : list of parents
/* nb_temp I : number of parents 
/*---------------------------------------------------------------------------*/



message ACsym_init();
/*---------------------------------------------------------------------------
/* build definition of symbol macro using graph 
/*---------------------------------------------------------------------------*/


message ACbuild_comp();

message ACfind_map(struct GRid  **ptr);
message ACfind_go(struct GRid  **ptr);
message ACfind_pretgo(int *count;struct GRid **slist);

message ACmap_test(struct GRid  sym;int *mapped);
/*---------------------------------------------------------------------------
/* 		Used to check wether the macro occurence sym is mapped
/*	or not. A symbol macro has been mapped to the definition 
/*	if :
/*		-the associative objects have been feeded with what 
/*		the occurence saved.
/*
/*		-the graphic objects of the occurence have beeen 
/*		connected to the associative objects in the definition
/*		to be thus the one really computed.
/*	
/*		-the ACpretend in the definition are set to do the
/*		correct indirection.
/*
/*      Argument description :
/*      --------------------
/*	
/*	struct GRid  sym		I : the macro occurence
/*	
/*	int *mapped		O : 0 not mapped
/*				  1 mapped
/*	
/*---------------------------------------------------------------------------*/

message ACmap_to_hdr(struct GRid  sym;struct GRid *list);
/*---------------------------------------------------------------------------
/*		This message is send to the definition to force
/*	a mapping to the given symbol macro occurence.
/*	The following operations will occurs :
/*
/*		- connection of the graphic objects of the definition to 
/*		 the corresponding associative objects in the definition.
/*
/*
/*      Argument description :
/*      --------------------
/*
/*	struct GRid  sym		I : the symbol macro to map.
/*	
/*	struct GRid *list	I : the list of template of this occurence
/*	
/*---------------------------------------------------------------------------*/

message ACunmap_hdr(struct GRid   sym);
/*---------------------------------------------------------------------------
/*		This message undo all that was done by the previous message.
/*      Argument description :
/*      --------------------
/*
/*	struct GRid  sym		I : the symbol macro to unmap
/*
/*---------------------------------------------------------------------------*/

message ACconnect_compute(IGRlong *msg;IGRint cn_type,tempsz;
		struct GRid sym;struct GRid *list;
		struct ret_struct *rtstr[];struct GRmd_env *md_env ;
		int *int_out_ch,*size_inst;char *inst_save);
/*---------------------------------------------------------------------------
/* 	 	Symbol macro compute routine.Attach template, graphic feet
/*	and computes with instance pile.
/*
/*      Argument description :
/*      --------------------
/*
/*      int       *msg          O : completion code
/*
/*      int       cn_type       I : type of computation
/*
/*	struct GRid  sym		I : objid of the computed sym header
/*
/*	struct ret_struct *rtstr[] 
/*				I : the array of the returned structure
/*				of all the feet
/*
/*	struct GRmd_env *md_env	I : The module environement.
/*
/*---------------------------------------------------------------------------*/

message ACgive_inst_defn(int *size;char **int_save);
/*---------------------------------------------------------------------------
/* 		Access to array of varying instance data in graph that was 
/* 	saved in the definition.
/*
/*      Argument description :
/*      --------------------
/*
/*	int *size		O : returned size of the vla
/*
/*	char **int_save		O : a pointer to the instance vla
/*
/*---------------------------------------------------------------------------*/

/* PRIVATE messages for ACconst computing */

message ACconstruct_feet(IGRlong *msg;char rep;int tempsz;
		struct GRid sym;struct GRid *list;
		int *fcount;struct GRid *feet_list;struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* 	 	Attaches template and find feet within definition.
/*
/*      Argument description :
/*      --------------------
/*
/*      int       *msg          O : completion code
/*
/*      char	  rep       	I : navsea representation
/*
/*      int       tempsz        I : size of template
/*
/*	struct GRid *list  	I : template list
/*
/*	struct GRid  sym	I : objid of the computed sym header
/*
/*      int       fcount        O : number of feet found
/*
/*	struct GRid *feet_list  O : Feet within macro definition
/*
/*	struct GRmd_env *md_env	I : The module environement.
/*
/*---------------------------------------------------------------------------*/


message ACcontext_compute_feet(char rep;int fcnt,ctxcnt;
		struct GRid *feet_list,*ctx_list;
		struct GRmd_env *md_env);
/*---------------------------------------------------------------------------
/* 	 	Used to compute th macro currently mapped
/*
/*      Argument description :
/*      --------------------
/*
/*      char	  rep       	I : navsea representation
/*      int       *msg          O : completion code
/*      int       fcnt          I : number of feet
/*      int       ctxcnt        I : number of old feet
/*
/*	struct GRid *feet_list  I/O : Root object for all feet produced 
/*
/*	struct GRid *ctx_list   I : Context foot if it exists 
/*
/*	struct GRmd_env *md_env	I : The module environement.
/*
/*---------------------------------------------------------------------------*/

/* PUBLIC MESSAGES */

message ACedit_template(int *suc,num_up,num_down;
		char **up_prompt,**upscan,**temp_name,**dwnscan;
		int template_to_up[]);
/*---------------------------------------------------------------------------
/* 	Change template attach definitions 
/*	allows the users to define attachement between macros
/*
/*      Argument description :
/*      --------------------
/*
/*	
/*	int *suc		O : 0 FAILED 1 SUCCESS
/*	
/*	num_up			I : number of real parent that will be given 
/*				at placement of an occurence
/*	
/*	num_down		I : number of template edited
/*	
/*	char **up_prompt	I : prompt used at placement of an occurence 
/*				to locate the real parent
/*	
/*	**upscan		I : string used to check if the parent 
/*				is of the right type(using its macro name):
/*				it is a regular expression as used under unix
/*				
/*	
/*	**temp_name		I : the templates we are mapping
/*	
/*	**dwnscan		I : wath we are looking for in the located
/*				parent. it is a feet name in the parent 
/*				definition
/*		
/*	int template_to_up[]	I : if template_to_up[i] = j that means that
/*				the i th element as defined in the temp_name 
/*				array is mapped to the j th parent as
/*				defined in the upscan	array whith the i th
/*				dwnscan as definied in the dwnscan array.
/*
/*---------------------------------------------------------------------------*/

message ACgive_upscan(int *tot_up,*prop;struct sup **xdup);
/*---------------------------------------------------------------------------
/* 		Access to real template attach structure 
/*
/*      Argument description :
/*      --------------------
/*
/*	int *tot_up		O : number of template that will be necessary 
/*				at placement of an occurence.
/*
/*	*prop			O : returns the properties 
/*
/*	struct sup **xdup	O : strusture describing upscan.
/*
/*---------------------------------------------------------------------------*/

message ACcreate_default
    (int *msg;GRspacenum osnum;struct GRid *def_macro; struct GRid *feet_list);

/*---------------------------------------------------------------------------
/*  Create a macro occurence which strores the initial description of the
/*  macro
/*
/*      Argument description :
/*      --------------------
/*
/*  msg       O : completion code
/*  osnum     I : osnum where the macro occurence must be created
/*  feet_list I : list of feet to create occurence from. This could be
/*		  a null pointer
/*  def_macro O : GRid of the macro occurence
/*---------------------------------------------------------------------------*/

message ACreturn_default
	(int *msg;struct GRid *placement_options,*def_values,*def_macro);

/*---------------------------------------------------------------------------
/*  Return information for the comand object place macro
/*
/*      Argument description :
/*      --------------------
/*
/*  msg       O         : completion code
/*  placement_options O : collection containing description of placement
/*			  options
/*  def_values 	      O : GRid of collection containing default values
/*  def_macro         O : macro occurence to be used to display macro
/*			  definition or to get initial symbology
/*---------------------------------------------------------------------------*/

message ACcopy_definition(long *msg;char *name;struct GRmd_env *fr_env,*to_env;
			  struct GRid *new_definition);

/*---------------------------------------------------------------------------
/*  Copy macro defintion to a different name/ object space
/*
/*      Argument description :
/*      --------------------
/*
/* msg       O  : completion code
/* name      I  : name to give to the new macro definition 
/* fr_env,to_env  I : md_env to use during copy
/* new_definition O  : GRid of the copied macro
---------------------------------------------------------------------------*/

message ACcopy_default(long *msg;struct GRid *new_definition;
		       struct GRmd_env *fr_env,*to_env;
		       struct GRid *new_default);

/*---------------------------------------------------------------------------
/*  Copy macro default to a different macro/ object space
/*
/*      Argument description :
/*      --------------------
/*
/* msg       O  : completion code
/* new_definition I : macro definition the copied default are associated to
/* fr_env,to_env  I : md_env to use during copy
/* new_default    O : GRid of the copied macro
---------------------------------------------------------------------------*/

end specification ACmacro_defn;
