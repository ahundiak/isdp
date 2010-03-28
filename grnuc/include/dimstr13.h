/*****************************************************************
Author	: B. Demars 
Date	: April 17 , 1989 .



	   +------------------------------------------------+
	   |		DATA STRUCTURE DEFINITION	    |
	   |	( Structures less used by themselves )	    |
	   +------------------------------------------------+


Dependancies : 	gr.h
		dpstruct.h
		
*****************************************************************/

#ifndef dimstruct_include
#define dimstruct_include


/*----- argument structure for functions called in dynamics ---*/

struct DMarg
	{
		struct DMconstruct	*cnstlis; /* construction list */
		
						    
		/* - fields destinated to the DMset_text_position function 
		     ( including the cnstlis ) */
		     
		IGRint			control; /* indicates the control
						    point that moved */

		struct DMplan		*win_plan; /* accessed dimension window
						    plane description */

		struct DMid		*dmgraph_id;/* if not NULL, indicates
						    that the dimension line
						    structure in the cnstlis
						    is not up to date */

	/* - fields destinated to the DMupdt_graphics function 
		     ( including the cnstlis ) */

		IGRint			level; /* update level :
							- DM_UPD_GRAPHICS
							- DM_UPD_TEXT_STR
							- DM_UPD_SYMB
							- DM_UPD_BREAK_PT
							- DM_UPD_LEAD_PT
							- DM_UPD_ALL
							- DM_UPD_COMPLEX  */
	};

/*------ description of a field (^F...^E) contained in a text_string ---------*/

struct DMfields_contents
  {
   short number;
   char  flag;
   short first_car;
   short last_car;
  };

/*--------- feet of the ci_macro "dat_elem" ---------------------------------*/

struct DMdat_elem_feet
 {
	double val_infr;
	double val_supr;

  	double wit_offs;
  	double wit_extn;
  	double pnt_inte;
  	double pnt_exte;
  	double lea_leng;

	double val_null;
	char   values_string[80];

  char _end;
 } ;

struct DMdat_cmpx_feet
 {
	double lin_orig;
	double lin_offs;
  	double wit_angl;
	double val_null;

  char _end;
 } ;

/* 
   communication between command_object and dim_param.u 
   (arguments of DMdeclare_active_dimension() )
*/

struct  DMdeclare_dimension
 {
  int                 declare_flag;
  struct DMid 	     *p_dmgraph_id;
  struct DMconstruct *p_dmcnst_lis;
  struct GRmd_env    *p_md_env;
  struct DMplanes    *p_dmplanes;
 } ;

#endif

