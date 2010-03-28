/*
  macro.h
  robert patience
  21_jul_86
*/  
#ifndef MACRODEF
#define MACRODEF

/* macro header type found in return structures */
#define ACtcomplex 		0 

/* properties of macro_definition */
#define ACkeep_no_real_template 0x1 /* OBSOLET NOT USED never copy template   */
#define AChmc_nocopy      	0x2 /* PROBABLY OBSOLET take the original as  */
				    /* def graph                              */
#define ACsame_feet_in_set  	0x4 /* ACchange always same feet              */
#define ACcant_place_sym        0x8 /* Used if inst overflow or graph changes */
#define ACextern_no_copy	0x10/* NOT USED always copy extern            */
#define ACpret_index_built      0x20/* pretend index have been build          */
#define ACsym_computed		0x40/* NEEDS to be removed                    */
#define ACminimal_graph         0x80/*Only internal elements are in the macro */
#define ACvariable_template    0x100/* This macro has a variable number of    */
				  /* template elements.                       */
				  /* - The variable template are the last ones*/
				  /*   with name like tmp00 tmp01 .... tmpnn  */
				  /* - The definition is with max number      */
#define ACwith_instances       0x200/* these macro has internal instances to  */
				  /* be intialize by a specific command object*/

#define ACno_construct         0x400 /* Can not be placed as construct        */
#define ACno_drop              0x800 /* Can not be paced as  symbol           */
#define ACno_symbol            0x1000/* Can not be placed as drop 	      */

/* properties for cpx placement */
#define AChdr_nobuild   	1 /* exit before rebuild  		*/
#define AChdr_nocompute 	2 /* exit before compute 		*/
#define AChdr_nodisplay 	4 /* exit before display  		*/
#define AChdr_noprotect 	8 /* do not try make source on template */
#define AChdr_norange          16 /* exit before adding in range  	*/

/* state for ACcpx  */
#define sym_rtn_built 		2  /* returned structures build */
#define sym_in_macro  		4  /* nested symbol macros */
#define ncpx_root       	8  /* ACncpx take root state behaviour */
#define ncpx_consumed       	16 /* ACncpx comsumed state */
#define ncpx_missing       	32 /* ACncpx feet given to consumer state */
#define in_error_rep 		64 /* in error representation dont
				       context switch when leaving  */
#define no_cpy_tmpft	       128 /* Do not copy template feet to feet when  */
				   /* copying to root			      */

/* return success type for ACgive_foot and  ACfind_temp_obj */
#define real_assoc_foot 	1  /* the assoc object NOT USED              */
#define temp_assoc_foot  	2  /* temporary assoc object                 */
				   /*  default for ACsym NEEDS to be removed */
#define graphic_foot            4  /* graphic or root objects                */
				   /*  default for  ACncpx and ci_macros     */
#define temp_miss_foot         16  /*ACncpx reponse if NULL given for foot   */

/* symbol macro instance save actions PRIVATE */
#define ACinst_ch_in	1
#define ACinst_ch_out	2

/*macro name*/
#define macro_MAX_CHAR 		16


extern OM_S_CHANSELECT 
			AC_template_chns,
			AC_mto_graf_chns,
			AC_mfrom_graf_chns;

/*********************************************************/
/*
/* Structures used in macro definition objects
/*
/*********************************************************/

			
/* Structure mapping parameter names to real templates   */
/* This is only used by macro ( graph compute complexes) */		
struct sup
{
char prompt[macro_MAX_CHAR];
char up_scan[macro_MAX_CHAR];
int type;
};
 
/* Structure naming and typing function parameters  */
struct stemp
{
char down_scan[macro_MAX_CHAR];
char name[macro_MAX_CHAR];
int type;
int back;
int direct_index;
};

/* chan defines where the feet are */
#define feet_in_template 0
#define feet_virtual     1
#define feet_in_graphic  2
#define feet_numeric     3

/* Directory definition of complex */
struct myfeet
{
char name[macro_MAX_CHAR];
int chan;
int pos;
int prop;
};


/*********************************************************/
/* 
/* Functions to manage the creation and naming of
/* complex definitions in the contruct directory of
/* IGRdirectory system.
/*
/*********************************************************/


/* action for the ACfind_macro_defn function 				*/
#define ACfind_no_load  1 /* find the macro def 			*/
#define ACfind_load 	2 /* if not found try to load it 		*/
#endif
