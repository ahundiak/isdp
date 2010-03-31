#ifndef FImin_included
#define FImin_included

#include "FIimport.h"	 /* Import must be included first for shlib */
#include "FI.h"
#include "FIgadget.h"
#include "FIcolors.h"
#include "FIover.h"
#include "FIext.h"
#include "FImacros.h"

#include "limits.h"  /* need this for PATH_MAX #define -- JAJ:05/09/90*/


/**********************************************************************/
/*** The next two used to be in FIkey.h ( private ), and then I     ***/
/*** moved them into FIappl.h ( public ), until I realized that     ***/
/*** "RETURN" is a lex/yacc reserved macro.  So now they're here .  ***/
/***					-- JAJ:05/17/91		    ***/
/**********************************************************************/
#define RETURN     10
#define SPACE      32




#endif
