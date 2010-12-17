#ifndef SS_included
#define SS_included	 1

#ifndef sbitset
/* This macro returns 1 if the sign bit is set */
#define sbitset(c) ((c) & 128 ? 1 : 0 )
#endif



/* The following define what type of font the auxilary font is	*/

#define SEVENEIGHT 0
#define SEVENSIXTEEN 1

#endif
