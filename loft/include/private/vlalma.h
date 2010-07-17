#ifndef vlalma_include
#define vlalma_include

#include "bsmemory.h"

/************************** internal definitions************************/

#define LIN_CL          0       /* line classe id                       */
#define CIR_ARC_CL      1       /* circular classe id                   */
#define CIR_CL          2       /* circle classe id                     */
#define ELL_ARC_CL      3       /* elliptical arc classe id             */
#define BSP_CL          4       /* bspline curve classe id              */
#define COMP_CL         5       /* composite curve classe id            */
#define ELL_CL          6       /* ellipse classe id                    */
#define OWNER_CL        7       /* GRowner classe id                    */
#define NCI_MACRO_CL    8       /* nci_macro classe id                  */
#define ACPRETEND_CL    9       /* ACpretend classe id                  */
#define VSPLATE_CL      10      /* Struct plate classe id               */
#define MANPLTJIG_CL    11      /* Man Jig classe id                    */
#define LIN_STR_CL      12      /* line string classe id                */
#define COMPCRV_CL      13      /* line string classe id                */
#define MARK_CL		14      /* mark        classe id                */

#define MARQUAGE        31      /* Mark on plate or surface             */
#define COUPE_DROITE    1       /* Linear cut                           */
#define COUPE_V         21      /* Cut along V                          */
#define COUPE_X         22      /* Cut along X axis                     */
#define BAD_MATRIX      99      /* Problem with located object's matrix */

#define TYPE            "type"
#define ANGLE1          "angle1"
#define ANGLE2          "angle2"

#define MATL_SIZE       20      /* no of characters as defined by Alma   */
#define GRADE_SIZE      20      /* no of characters as defined by Alma   */
#define MAXOFILES       20      /* no of ini files open at one time      */
#define NUMMARKS        10      /* no of marks on either the top/bot of plate */

#define DELETE          0       /* options for status */
#define ADD             1
#define MODIFY          2

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif
#define RADDEG 180.0/M_PI

#define AL_E_MATH_ERROR             (-1)

#define retbs_test {                      \
  if( retbs )                             \
  {                                       \
    ret0 = AL_E_MATH_ERROR;               \
    goto ret_error_exit ;                 \
  }                                       \
}

#  define BSmemcpy( numbytes, source, destination ) \
   BSMEMCPY( numbytes, source, destination )


/***** copy predefined error message in alma error buffer 	****/

#       define __CopyLogMessage( OMrc, GRrc, _message_ ) \
        if( !( (OMrc) & 1 & (GRrc) ) && me->LogFileId )  \
				strcpy( LogMessage, _message_ )  

/******** bit map for types to be converted **************************/

#define	FlatPlates	1 		/* 1:flattened plates */
#define	Flattened	(1<<1) 		/* 2:flattened plates */
#define	PlateTempls	(1<<2)		/* 4:plates' templates  */
#define	StiffTempls	(1<<3)		/* 8:stiffeners' templates */
#define FlatBars	(1<<4)		/* 16:beams that are flat bars */
#define	PinJigs		(1<<5)		/* 32:Pin Jigs! */

/*************  form gadget definitions	******************************/

/* Gadgets */

#define LOGFILEREQ	23
#define LOGFILENAME	24
#define GROUP1		21
#define GROUP2		22
#define FLATPLATES	12
#define FLATTENED	13
#define PLATETEMPLS	14
#define STIFFTEMPLS	15
#define FLATBARS	16
#define PLATEJIGS	17
#define AUTOFILE	25
#define FILEPREFIX	26
#define CIRCAPPROX	27
#define MESSAGES	10

#define VLAL_GET_CHAMFID	"vl-alma-GetChamfId"

/************************** internal definitions************************/

#endif
