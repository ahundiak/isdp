#ifndef grerr_include
#define grerr_include

/* the following return codes are the generic codes for the
 * GR package.
 */

/*
 * severe errors
 */

#define GRSNOINVTRAN 	0X804832C	/* no inverse of transformation	*/
#define GRSDGNEXCEED	0X8048334	/* design space exceeded	*/
#define GRILLDEFINITION 0X8048344	/* illegal definition		*/
#define GRINVMSG        0X804834C	/* invalid message		*/
#define GRNOTIMPLEMENTED 0X804835C	/* not implemented		*/
#define GRNODELBCS 	0X804839C	/* cannot delete base coord sys	*/
#define GRNOCPBCS	0X8048354	/* cannot copy base coord sys 	*/
#define GRRIGIDEXISTS   0X80483C4	/* rigid owner already exists	*/

/*
 * errors
 */

#define GR_E_SDNOTUNIQUE 0X80437C
#define GRINVOBJECT 	0X804836A	/* invalid object for request	*/
#define GRLEVEL_OFF	0X8048392	/* level is not on		*/
#define GRNOT_VALID_PROPS 0X804839A	/* properties check failed	*/
#define GRNOT_VALID_CLASS 0X80483A2	/* class check failed		*/
#define GRNOCONNECT	  0X80483CA	/* no connection made		*/
#define GR_E_INV_REQUEST  0X80483D2	/* invalid request		*/

/* 
 * information
 */

#define GRIZRNGCHG 	  0X8048323	/* Z range changed		*/
#define GRINOCLUSTER      0X804833B	/* could not cluster		*/
#define GRCHANNEL_EMPTY   0X8048393	/* channel was empty		*/

#define GR_I_OBJINSIDE 	  0X804835B	/* entire object inside prism	*/
#define GR_I_OBJOUTSIDE	  0X8048363	/* entire object outside prism	*/

#define GR_I_EXCEDBUF     0X804836B
#define GR_I_CPXFLATTEN   0X8048373
#define GR_I_NODISATTR    0X8048383
#define GR_I_NOSL	  0X804838B
#define GR_I_INV_REQUEST  0X80483DB	/* invalid request		*/
#define GRNOTALLREMOVED   0X80483CB
#define GR_I_NO_RESPONSE  0x80483D3
#define GR_I_NO_LAYER	  0x80483EB
#define GR_I_SL_READ_ONLY 0X80483F3
#define GR_I_OUTSIDE_TOL  0X80483FB
#define GR_I_NO_INTERSECT 0X80483

/* 
 * success
 */

#define GRDEFAULT_USED    0X8048361
/* a default defined by the method was selected	*/

#define GR_PARM_NOT_VALID 0X80483A3	
/* parameter structure returned is meaningless for this object*/

#define GRNO_PROCESSING_NEEDED 0X80483E1
/* no processing needed for this object */

#define GR_NO_INT_POINT	 0X80483E3 
/* no intersection between proj line and object */

#endif
