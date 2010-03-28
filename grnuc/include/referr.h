
#ifndef referr_include

#define referr_include 1


/* the following return codes are the generic codes for reference
 * files.
 */

/*
 * severe errors
 */

#define  GRFILENOTFOUND		0X804837C
#define  GRVIEWNOTFOUND		0X8048384
#define  GRNAMEDUPLICATED	0X8048414

/*
 * errors
 */

#define GR_E_SAME_OSNUM		0X804840E

/* 
 * information
 */

#define GRSAVED_VIEW_GONE 	0X31	/* temporary (for testing)	*/
#define GRNOTREFFILE		0X80483AB 
#define GR_I_NAME_CHANGED	0X8048403

/* 
 * success
 */

#define GRRF_ACTIVE_MODULE	0X1	/* temporary (for testing)	*/


#endif
