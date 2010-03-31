
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hstabmacros_include

#define hstabmacros_include
/********************************************************************

  
	This macros is dependent on the following include files:

		"igrtypedef.h"
		"OMminimum.h"

********************************************************************/


/* this macro compares two entries - if equal result = TRUE		*/


#define cmpentry(entry1,entry2,size,result) 				\
		{							\
		    int i;						\
		    register int *e1;					\
		    register int *e2;		 			\
									\
		    e1 = (int *) (entry1);				\
		    e2 = (int *) (entry2);				\
		    (result) = 1; 					\
		    for (i = 0; i < (size) >> 2; i++)			\
		    { 							\
			if ( *e1++ != *e2++) 				\
			{ 						\
			    (result) = 0; 				\
			    break; 					\
			} 						\
		    } 							\
		}

#endif
