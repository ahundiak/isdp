/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* oppydefs.h - parser external definitions				*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef OPPYDEFS_INCLUDED
#define OPPYDEFS_INCLUDED

#include "class.h"
#include "carriers.h"

extern struct opp_class_def *active_class;

extern int yydebug; /* set to 1 to get debugging */

extern int yyparse();

#define CHAN_ATT_OO 	2
#define CHAN_ATT_OM	8
#define	CHAN_ATT_MO	4
#define CHAN_ATT_MM	16
#define CHAN_ATT_SIDES  (CHAN_ATT_OO | CHAN_ATT_OM | CHAN_ATT_MO | CHAN_ATT_MM)
#define CHAN_ATT_ABS	32
#define CHAN_ATT_REL	64
#define CHAN_ATT_RES	0x400
#define CHAN_ATT_OM_BITS (CHAN_ATT_SIDES | CHAN_ATT_ABS |\
			  CHAN_ATT_RES   | CHAN_ATT_REL)
#define CHAN_ATT_INIT	1
#define CHAN_ATT_INCR	128

#endif /* OPPYDEFS_INCLUDED */
/* End oppydefs.h */
