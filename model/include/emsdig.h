/*                      emsdig.h                         */
/* Some definitions used in almost all methods of EMSdig */

# ifndef emsdig_include
# define emsdig_include 1

#define IS              ==
#define IS_NOT          !=
#define NOT             !
#define OR              ||
#define AND             &&

#define ZERO            0

/* The following are required for EMdispoly */

#define DRAW            0
#define ERASE           1
#define HLITE           2
#define UNHIL           3

/* The following are bitvalues in obj_prop of EMSdig instance data */

#define EMSDIG_DELETE_BIT       0x00000001
#define EMSDIG_REVERSE_BIT      0x00000002

#define NUMB_CHAN_INIT  5
#define NUMB_CHAN_INC   5

# endif
