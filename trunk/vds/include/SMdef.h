/* $Id: SMdef.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / SMdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1996/08/22  06:55:34  pinnacle
 * Replaced: include/SMdef.h for:  by ksundar for vds.241
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef SMdef_include
#define SMdef_include

#ifndef	_STDIO.H
#	include "stdio.h"
#endif

#ifndef	OM_D_MINIMUM
#	include "OMminimum.h"
#endif

#ifndef	OM_D_MINIMUM
#	include "OMminimum.h"
#endif

#ifndef	igetypedef_include
#	include "igetypedef.h"
#endif

#ifndef	igrtypedef_include
#	include	"igrtypedef.h"
#endif

#ifndef	gr_include
#	include	"gr.h"
#endif


#ifndef	growner_include
#	include	"growner.h"
#endif

/*
 * Wind area polygons
 */
#define SM_MAX_ALLOW_PLG	10 /* Maximun number of polyons              */
#define SM_WIND_NB_MAX_ATTR      7 /* Maximum number of attributes for a plg */

/*
 * Groups & sub-groups
 */
#define SM_MAX_SUB_GRP		 10 /* Maximun sub group allowed 		*/
#define SM_MAX_SUB_GRP_ATT	  5 /* Maximun attrib for a sub-group or group 	*/
#define SM_MAX_GRP_ATT		 55 /* SM_MAX_SUB_GRP_ATT + SM_MAX_SUB+GRP * SM_MAX_GRP_ATT */

/*
 * maximum length +1 of a line in an ascii file
 */
#define MAX_CHAR_LINE 		81

/*
 * Used for the SMstate management 
 * Messages:
 *	- SMGetState
 *	- SMChgState
 */

/* Mask */
#define SM_STATE	0x0007  /* three bits are used 	          */
#define SM_STATE_USR	0xF000  /* User defined available state   */

/*
 * State values
 */
#define SM_NEW 		0x0001	/* New      object 		*/
#define SM_UPD 		0x0002	/* Updated  object 		*/
#define SM_MOD 		0x0004	/* Modified object 		*/
#define SM_TAG		0x0010  /* Tag flag			*/
#define SM_ACT		0x0020  /* Specify that it is an active */
#define SM_CAL_ERR	0x0040  /* Error at recompute time	*/
#define SM_SF_ERR	0x0080  /* Error at Seasafe Extraction  */
#define SM_CAL_ERR2	0x0140  /* Error at recompute time (due to root) */
#define SM_NOT_COMP	0x0200  /* Component not updated	*/

/*
 * Attribute types
 */
#define SM_STATIC_ATT   0x0100  /* Static attribute             */
#define SM_DYNAMIC_ATT  0x0200  /* Dynamic attribute            */
#define SM_USER_ATT     0x1000  /* User attribute               */
#define SM_SYST_ATT     0x2000  /* User attribute               */
#define SM_OTHER_ATT    0x4000  /* Other attribute              */
#define SM_UNKNOWN_ATT  0x8000  /* Unknown type                 */

/*
 * Extraction options,  SM$CritSel:  options
 */
#define SM_CLEAR_TAG	0x0001	/* Option used to clear tagged objects */
#define SM_ADD_LIST	0x0002	/* If add to an existing list   */
#define SM_REF_FILE     0x0004  /* Work with ref file           */
#define SM_NO_DUPLIC	0x0008  /* No object duplicated in list */

/*
 * Report options
 */
#define SM_REG_RPT	0x0010  /* Regular report		*/
#define SM_SHORT_RPT	0x0020  /* Short report			*/
#define SM_LONG_RPT	0x0040  /* full report			*/
#define SM_USR_DEF_RPT	0x0080  /* User defined (desc file)     */
#define SM_NO_HDR_RPT	0x40000  /* Does not print header        */

/*
 * Seasafe and reports options
 */
#define SM_ASCII_FILE	0x0100	/* The output is an ascii file	*/
#define SM_BIN_FILE	0x0200	/* The output is an binary file	*/
#define SM_SF_RPT_ON	0x0400	/* Print option for Seasafe 	*/

/*
 * Seasafe, reports  units definition
 */
#define SM_UNIT_INT	0x0000	/* Current Internal Units	*/

#define SM_UNIT_MTC	0x0001	/* Metric System		*/
#define SM_UNIT_IMP	0x0002	/* Imperial System		*/

#define SM_UNIT_MTR	0x0010  /* Output in meters		*/
#define SM_UNIT_MMTR	0x0020	/* Output in millimeters	*/

#define SM_UNIT_INC	0x0100  /* Output in inches		*/
#define SM_UNIT_FT	0x0200  /* Output in feet		*/

#define SM_UNIT_RAD     0x1000  /* Output in Radian             */
#define SM_UNIT_DEG     0x2000  /* Output in degree             */

#define SM_UNIT_CEL     0x10000  /* Output in celsius           */
#define SM_UNIT_FAR     0x20000  /* Output in farhenheit        */

/*
 * Seasafe option
 */
#define SM_SF_SHORT_EXT	0x0020  /* For an object already extracted */
				/* only a short descrition is given */

/*
 * Seasafe and reports private options
 */
#define SM_PRT_SUB_GRP	0x1000	/* Print only sub group of groups */

/*
 * Type and subtype of SMman objects
 */
#define SM_COMPART	0x0001	/* Compartment			*/
#define SM_REF_PTS	0x0002  /* Reference points		*/
#define SM_PTS_GRP	0x0004  /* Groups			*/
#define SM_WND_AREA	0x0008	/* Wind area polygons		*/
#define SM_FRM		0x0010	/* Frame			*/
#define SM_SCT		0x0020	/* Calculation sections		*/
#define SM_DW		0x0040  /* Dead weight			*/
#define SM_GRP		0x0080  /* Group			*/
#define SM_SUB_GRP	0x0100  /* Sub_group			*/
#define SM_SHIP_ATT	0x0200  /* Ship attributes		*/
#define SM_CS		0x0400  /* Coordinate system		*/
#define SM_PP		0x0800  /* Perpendicular		*/
#define SM_RPT		0x1000  /* Report object                */
#define SM_SRF		0x2000  /* Structural surface           */
#define SM_ZN		0x4000  /* Zone		                */

/*
 * Compartment sub types
 */
#define SM_HULL		0x0001	/* Hull compartment		*/
#define SM_REG		0x0002	/* Regular compartment		*/

/*
 * reference points sub types
 */
#define SM_OPN		0x0001	/* regular opening		*/
#define SM_SRS_OPN	0x0002	/* serious opening		*/
#define SM_USR_OPN	0x0004	/* user    opening		*/
#define SM_MRG_LN	0x0010	/* margin line			*/
#define SM_BLK_DCK	0x0020	/* bulkhead deck		*/

/*
 * wind area polygon sub types
 */
#define SM_XOZ		0x0100  /* xoz plane			*/
#define SM_ZOY		0x0200  /* zoy plane			*/

/* Group sub types
 * It gathers the reference points and wind area polygons types
 */

/*
 * No sub type for the frame
 *
 * No sub type for the calculation sections
 */


/*
 * Structure used by the message: SMAddToList
 */

struct SMObjList
 {
  IGRint 	nb_objects;	/* Number of objects		*/
  IGRint 	nb_alloc;	/* Number of objects allocated	*/
  struct GRobj_env *list;	/* Objects list + env		*/
 };

struct SMParts
 {
  IGRdouble	FrX;		/* First position		*/
  IGRdouble 	ToX;		/* Last position		*/
  IGRint	NbSect;		/* Number of sections wanted	*/
  IGRint	NbCrv;		/* Number of generated curved	*/
  IGRdouble	Inc;		/* Small Section increment	*/
 };

 
/*
 * Calculation sections
 */
#define SM_MAX_PARTS	 	 10  /* Maximun number of parts */
#define SM_MAX_SECT_PART	  7

/*
 * Internal use
 */
#define SM_SECT_REL_DATA	  1	/* The distance is given in % 	*/

struct SMSectUsr
 {
  IGRdouble     FrDx;       /* Delta x from the from frame */
  IGRdouble     ToDx;       /* Delta x from the to   frame */
  IGRint        NbSect;     /* Number of sections          */
 };
 
struct SMSectSgl
 {
  IGRint        NbSect;     /* Number of sections           */
 };

struct SMSectAuto
 {
  IGRdouble      MinDstSct;  /* Minumum distance between two sections          */
  IGRdouble      MinToInst;  /* % of min area diff between 2 adja. sections    */
  IGRdouble      MaxToSup;   /* % of max area diff between 2 adja. sections    */
  IGRboolean     RelAbs;     /* TRUE  => MinDstSct is a relative to the lenght */
                             /* FALSE => Absolut value                         */
 };

/*
 * Message for SMsection: SMSectSetCAl, SMSectGetCal
 *
 * mode
 */
#define SM_SECT_AUTO              1  /* Automatic way   */
#define SM_SECT_USER              2  /* Multiple parts  */
#define SM_SECT_SGL               3  /* Single parts    */

struct SMSectInfo
 {
  IGRdouble     EndOffset;      /* ends offsets for Cal sections           */
  IGRint        NbPart;         /* Number of parts (not used in auto mode) */
  IGRshort      mode;           /* Possible modes                          */
  IGRchar       axis;           /* Axis refering to the CS                 */
  union
   {
    struct SMSectAuto   oto;
    struct SMSectSgl    sgl;
    struct SMSectUsr    usr[SM_MAX_PARTS];
   } att;
 };


#endif

