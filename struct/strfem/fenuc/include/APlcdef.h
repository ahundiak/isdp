#ifndef APlcdef_included
#define APlcdef_included

/* *****************************H H H H H******************************* */
/* Doc: APlcdef.h

   Abstract:  Used in the following:
   		APPco.setup_locate
   		FDCgen.place_fd
	
   History:

      Date	Who	Version	Why
      ---------	------	-------	---------------------------
      10-16-91	kk	2.0.0	Creation
      11-30-93	ret	3	added AP_LC_TOPLEVEL

*/
/* *****************************H H H H H******************************* */

#define AP_LC_ANY	0

#define AP_LC_NODE	1

#define AP_LC_ELEM1D	2
#define AP_LC_ELEM2D	3
#define AP_LC_ELEM3D	4

#define AP_LC_ELEM	5

#define AP_LC_POINT	6
#define AP_LC_EDGE	7
#define AP_LC_STITCHSURF 8
#define AP_LC_SURF	9
#define AP_LC_SOLID	10

#define AP_LC_MAPPED_MESH 11

#define AP_LC_CURVE	12

#define AP_LC_LOOPS	13

#define	AP_LC_NOCLASS	14

#define AP_LC_PLANE	15

#define AP_LC_STRUCTURE	16

#define AP_LC_TOPLEVEL	17	/* use to locate "top level" owner only. */

#define AP_LC_ELEMEDGE	18	/* edge of FEM element */

/*
 *	The following are used by locate_domains filter
 */

#define AP_SINGLE		1
#define AP_MANY			2

/*
 *	define the behavior of MOVE_ON
 */
#define AP_LC_NO_MOVEON		0	/* no prompt for move on		 */
#define AP_LC_MOVEON_ALL	1	/* works only for AP_LC_NODE or AP_LC_ELEM
					   with AP_MANY specified		*/
#define AP_LC_MOVEON_NONE	2	/* prompt: "locate xxx / Move On" */
/*
 *	define the options for locate_domains
 */

#define AP_LC_NOPROMPT		0x01


/* make sure TRUE and FALSE and NULL are defined */
#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

#ifndef NULL
#define NULL 0
#endif

#endif
