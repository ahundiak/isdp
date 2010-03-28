/*****************************************************************
Author	: B. Demars 
Date	: May 30 , 1989 .


This file defines all data used to describe a dimension graph.


	   +------------------------------------------------+
	   |		DATA DEFINITION			    |
	   +------------------------------------------------+

*****************************************************************/

#ifndef dimgraph_include
#define dimgraph_include



/* - the following table describes the class' character specifier that must
     be at the 9th position of the graphic macro name.
     These characters must be stored according to the dm_class_id enum
     definition order ( dimdef.h file ) */
      
%safe
static IGRchar	dm_type_table[DM_END_CLASS] = { 'l',  /* LINEAR specifier */
						'a',  /* ANGULAR specifier */
						'r',  /* RADIAL_1_2 specifier */
						'o',  /* COORDINATE specifier */
						's'   /* RADIAL specifier */
					      };
%endsafe


/* - the macro names must be defined as follow:

	- The two ci_macros are not dependant on the dimension's type.

	Theyre significant characters are the first 9 ones:
		_dat_elem[....] and _dat_c[mpx] 
	The last three can be modified. 

	- The macros depend on the dimension type:

	The maximum name length is 14 characters.
		- The first 9 characters determine theyre position in the
		graph,
		- the X character determines the type of dimension the macro
		has been written for,
		- the character enclosed by brackets are meaningless to the 
		system and can be changed if between two releases one macro
		is rewritten but the old one has to remain in the system to
		keep the old dimensions working.
	
		dim_orig_X[....]	: origin macro
		dim_meas_X[....]	: measure macro
		dim_sque_X[....]	: first squeleton macro of a complex 
		dim_elem_X[....]	: graphic macro
		dim_sqst_X[....]	: added squeleton macro in a complex 
					  stacked dimension.
		dim_sqch_X[....]	: added squeleton macro in a complex 
					  stacked dimension. 
*/


#define	DM_MACRO_NAME_MAXLEN	14	/* no macro name can exceed 
					   14 characters */
#define	DM_MACRO_NAME_MINLEN	5	/* represent the minimum character
					   number meaningfull to navigate
					   into a dimension graph */
					   
/* - Imposed prefixes for macros names */
/* - These generic names are used to navigate within a dimension
     graph ( allows to select a macro only with its significant characters ) */

#define	DM_MACROS_PREFIX_LENGTH	9 	/* the first 9 character of the
					   macro names are imposed */

#define DM_ADD_SQUE_DETERMINE	6	/* index on the first of the two
					   character determining in the
					   added squeleton name whether
					   it is a CHAINED or a stacked 
					   squeleton */
#define	DM_TYPE_CHAR_INDEX	9	/* index of the character determining
					   the dimension type in a macro name */

/* - the following table describes the imposed macros name's prefix.
     These names must be stored according to the dm_macro_index enum
     definition order ( dm_macro_index defined below ) */
 
%safe
static IGRchar	*dm_macro_prefix[9]= 
			{	"_dat_cmpx",	/* dat_cmpx : complex data */
				"dim_orig_",	/* dim_orig : origin */
				"dim_meas_",	/* dim_meas : measurement */
				"dim_sque_",	/* dim_sque : first squeleton */
				"_dat_elem",	/* dat_elem : dimension data  */
				"dim_elem_",	/* dim_elem : graphic macro */
				"dim_box2",	/* dim_box  : box around text */
				"dim_under2", 	/* dim_under: under line text */
				"dim_sqxx_"	/* dim_sq.. : added squeleton */
			};
%endsafe
		
/* - Macros names index for dmcnst_lis.macros_names  and dm_macro_prefix
     access */

enum dm_macro_index { 	DM_DAT_CMPX = 0, 
			DM_DIM_ORIG,
			DM_DIM_MEAS,
			DM_DIM_SQUE,
			DM_DAT_ELEM,
			DM_DIM_ELEM,
			DM_BOX,
			DM_UNDERLINE,
			DM_DIM_SQXX,
			DM_END_MACROS };

#endif
