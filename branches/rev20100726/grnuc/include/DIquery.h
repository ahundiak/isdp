#ifndef diquery

/* possible operators (from y.tab.h) 	*/
# define NUMBER 	257
# define IDENT 		258
# define WHERE		260
# define OR 		261
# define AND 		262
# define GT 		263
# define GE 		264
# define LT 		265
# define LE 		266
# define EQ 		267
# define NE 		268
# define NOT 		269
# define EXIST 		270

/* possible return code			*/
#define QY_E_SYNTAX 	-1
#define QY_TRUE		1
#define QYfalse		0

#endif
