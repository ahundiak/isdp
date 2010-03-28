/*****************************************************************
Author	: B. Demars 
Date	: March 28 , 1989 .



	   +------------------------------------------------+
	   |		DATA DEFINITION			    |
	   +------------------------------------------------+

*****************************************************************/

#ifndef dimdef13_include
#define dimdef13_include

/* - Release number */

#define DIM_RELEASE	"rel130..12jun89"

#define VERSION_130	0
#define VERSION_124	1
#define VERSION_114	2
#define VERSION_OLD	3

/* - Possible types for dimension */

enum	dm_class_id {	DMLINEAR_1_3 = 0,
	 		DMANGULAR_1_3,
	 		DMRADIAL_1_2,
	 		DMCOORDINATE_1_3,
			DMRADIAL_1_3,
			DM_END_CLASS };


/* - Possible subtypes for dimension */

#define 		CHAINED_13	0
#define 		STACKED_13	1
#define			RADIUS_13	2
#define 		DIAMETER_13	3
#define			SYMM_CHAINED_13	4
#define 		SYMM_STACKED_13	5
#define 		SINGLE_13	6


/* - DMget_neighbour entry options */

#define		DM_TEMPLATES	0
#define		DM_CHILDREN	1

/* - Scale to simulate infinite lines */

#define BIGNUM 1.e9

/* - dimensioning parameters possible values */

	/* environment parameters */
	
#define 		OFF 		0
#define 		ON  		1

#define 		ABSOLUTE    	0 
#define 		RELATIVE    	1 

 	/* 
  	 * text attributes 
  	 */

#define TXT_DIMN 	0
#define SYM_DIAM 	1
#define SYM_RADI 	2
#define SYM_PLMS 	3
#define SYM_ANGR 	4
#define ARR_HOLL 	5
#define ARR_FILL 	6
#define ARR_OPEN 	7
#define ARR_SLASH      	8
#define ARR_BACK_SLASH 	9

 	/* 
 	 * text_string escape_sequences 
 	 */

#define _DIM_GAP1_R 0
#define _DIM_GAP2_R 1
#define _DIM_GAP3_R 2
#define _TOL_SIZE_R 3
#define _TOL_SIZE_M 4
#define _TOL_OFF1_R 5
#define _TOL_OFF2_R 6
#define _LIM_OFF1_R 7
#define _LIM_OFF2_R 8
#define _DUA_OFF1_R 9
#define _DUA_OFF2_R 10
#define _BOX_XOFF_R 11
#define _BOX_YOFF_R 12
#define _TOL_MOV1   13
#define _TOL_MOV2   14
#define _BACK_MOV   15
#define _VAL_LAST   16

/*
#define _DIA_SIZE_R 16
#define _DIA_SIZE_M 17
#define _VAL_LAST   18
*/

#define _TXT_WEIG   0
#define _TOL_WEIG   1

#define THIRD  0.33     /* constant used in BACK_MOV calculation,
                         corresponding to the right extend of a character */

#define ARR_BLANK       10
#define ARR_POINT       11
#define ARR_CIRCLE      12
#define TXT_FRAC        13

	/* local parameters */
	
#define  		SYMBOL_MACRO 	0
#define			NESTED_MACRO 	1

	/* Definition of the possible measurement axes. */

#define 		HALF        2
#define 		SYMMETRICAL 3
#define 		LEFT  1 
#define 		RIGHT 2
#define 		BOTH  3
#define			PARALELL   0
#define			HORIZONTAL 1
#define			PERPENDICULAR 2
#define			VERTICAL      3
#define 		ABOVE    0
#define 		BELOW	 3
#define 		EMBEDDED 1
#define 		MIDDLE 0
#define 		FIRST  1
#define 		SECUND 2
#define 		CENTERED  0
#define                 AUTO_JUST 3
#define 		INTERNAL 1
#define 		EXTERNAL 2
#define 		MANUAL      1
#define 		SEMI_MANUAL 2
#define                 STATIC  0
#define                 DYNAMIC 1


	/*
	 * Terminator type
	 */

#define 		HOLLOW     0
#define 		FILLED     1
#define 		OPEN       2
#define 		SLASH      3
#define 		BACK_SLASH 4
#define 		BLANK      5
#define 		DOT        6
#define 		ORIGIN     7


	/*
	 * Tolerance display
	 */
	 
/*above			OFF         0 */
#define 		UP_LOW      1
#define 		LIMITS      2
#define 		PLUS_MINUS  3
#define 		BOX         4

	/*
	 * val_unit index and values
	 */

#define			PRIMARY   0
#define			SECUNDARY 1
#define 		SI 	  0
#define 		AN 	  0
#define 		US 	  1

	/*
	 * val_dimn values (same index than val_unit)
	 */
	 
#define 		DM_DOUBLE  0
#define 		DM_STRING  1
#define 		DM_MEASURE 2

/* - selection in DMmake_text_attributes () */

#define MAX_TEXT_STRING   1024

#define DM_FIRST_ARROW    0
#define DM_SECOND_ARROW   1
#define DM_DIMENSION_TEXT 2

/* - flag in DMtext_processing */

#define DM_MAKE_TXT_STRING 0
#define DM_MAKE_USR_FIELDS 1
#define DM_READ_USR_FIELDS 2
#define DM_MAKE_SYS_FIELDS 3
#define DM_READ_SYS_FIELDS 4
#define DM_MAKE_FIELDS     1

/* - index of the sub_string in dat_fields */

#define LOW_LEFT_CORNER		2
#define UP_RIGHT_CORNER		3

#define PREFIX_START		4
#define PREFIX_END		5
#define SUFFIX_START		6
#define SUFFIX_END		7

#define SYMBOL_BEFORE		8
#define SYMBOL_AFTER		9

#define SINGLE_START		10
#define SINGLE_END		11

#define DUAL_ABOVE_START	12
#define DUAL_ABOVE_MIDDLE	13
#define DUAL_ABOVE_END		14

#define DUAL_SLASH_START	15
#define DUAL_SLASH_MIDDLE	16
#define DUAL_SLASH_END		17

#define PRI_TOLE_OFF		20
#define PRI_TOLE_UP_LOW		21
#define PRI_TOLE_MIDDLE		22
#define PRI_TOLE_LIMITS		23

#define SEC_TOLE_OFF		25
#define SEC_TOLE_UP_LOW		26
#define SEC_TOLE_MIDDLE		27
#define SEC_TOLE_LIMITS		28

#define NO_PREFIX_END           29
#define NO_SUFFIX_START         30
#define NO_SUFFIX_END           31

#define MAX_FIELDS_NUMBER 	32

/* - flags to process the fields */

#define NON_EDITABLE 1
#define UPDATABLE    4
#define ESC          27 

#endif

