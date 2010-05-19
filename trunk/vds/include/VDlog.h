/* $Id: VDlog.h,v 1.3 2001/03/13 00:15:21 ahundiak Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:  include/VDlog.h
 *
 * Description: Logging Routines
 *
 *
 * Dependencies: VDtypedef.h or VDtypedefc.h
 *
 * Revision History:
 *	$Log: VDlog.h,v $
 *	Revision 1.3  2001/03/13 00:15:21  ahundiak
 *	ah
 *	
 *	Revision 1.2  2001/02/22 23:00:44  ahundiak
 *	ah
 *	
 *	Revision 1.1  2001/01/10 15:55:49  art
 *	sp merge
 *	
 * Revision 1.1  2000/12/01  13:54:20  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/28/00  ah      Created
 * 01/10/01  ah      sp merge
 * -------------------------------------------------------------------*/
#ifndef VDlog_include
#define VDlog_include

#ifndef   VDtypedef_include
#ifndef   VDtypedefc_include
#include "VDtypedef.h"
#endif
#endif

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#define VDLOG_ERROR 0
#define VDLOG_WARN  1
#define VDLOG_INFO  2
#define VDLOG_DEBUG 3
#define VDLOG_STAT  4

extern IGRstat VDlogPrintBuf  __((IGRint type, IGRint stdOutFlag, IGRchar *buf));

extern IGRstat VDlogPrintFmt  __((IGRint type, IGRint stdOutFlag, IGRchar *fmt, ...));

extern IGRstat VDlogPrintE __((IGRint stdOutFlag, IGRchar *fmt, ...));
extern IGRstat VDlogPrintW __((IGRint stdOutFlag, IGRchar *fmt, ...));
extern IGRstat VDlogPrintI __((IGRint stdOutFlag, IGRchar *fmt, ...));
extern IGRstat VDlogPrintD __((IGRint stdOutFlag, IGRchar *fmt, ...));

extern IGRstat VDlogPrintObject __((IGRint     type, 
				    IGRint     stdOutFlag, 
				    IGRchar    *prefix, 
				    TGRobj_env *objOE, 
				    TGRid      *objID));

#define VDlogPrintOE(type,flag,prefix,objOE) \
        VDlogPrintObject(type,flag,prefix,objOE,NULL)

#define VDlogPrintID(type,flag,prefix,objID) \
        VDlogPrintObject(type,flag,prefix,NULL,objID)

#define VDlogPrintObjectE(stdOutFlag,prefix,objOE,objID) \
        VDlogPrintObject(VDLOG_ERROR,stdOutFlag,prefix,objOE,objID)
#define VDlogPrintObjectW(stdOutFlag,prefix,objOE,objID) \
        VDlogPrintObject(VDLOG_WARN, stdOutFlag,prefix,objOE,objID)
#define VDlogPrintObjectI(stdOutFlag,prefix,objOE,objID) \
        VDlogPrintObject(VDLOG_INFO, stdOutFlag,prefix,objOE,objID)
#define VDlogPrintObjectD(stdOutFlag,prefix,objOE,objID) \
        VDlogPrintObject(VDLOG_DEBUG,stdOutFlag,prefix,objOE,objID)

extern IGRstat VDlogCloseCat __((IGRchar *cat_name));
extern IGRstat VDlogOpenCat  __((IGRchar *cat_name));
extern IGRstat VDlogShowCat  __((IGRchar *cat_name));

extern IGRstat VDlogCloseAllCats __(());

extern IGRstat VDlogOpenCatCallback  __((IGRchar *cat_name, void (*callback)(IGRint type, IGRchar *buf)));

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif

