/*
 * 
 *  File     :		exudata.h
 *  Author   : 		Srikanth S
 *  Date     :   	Mar 1995
 *
 *
 *  Change  History :
 *
 *
 *  This contains a generic data structure which can be used by the higher
 *  layers eg. GRNUC, MODEL, etc to place their values so that they can be
 *  accessed by Exnuc code to do some specific things depending on the
 *  data.  Two APIs are exposed thro' which the application would be able
 *  to set and get the data.
 */

#ifndef EX_D_UDATA
#define ED_D_UDATA 	1

#include "OMtypes.h"
#include "OMminimum.h"

extern int exPostUData(int type, char *data);
extern int exRevcUData(int type, char *data);

/*
 *  defines for type
 */

#define EX_UDATA_ACTREF		0x0

struct ex_udata_actref {
   int      aflag;
   OMuword  osn;
   struct   Refid
   {
       OMuint     objid;
       OMuword    osnum;
   }refid;
	};
typedef struct ex_udata_actref 		exUDataActref;

/* API return codes */

#define UDATA_SUCCESS			0x1
#define UDATA_TYPE_NOTSUPPORTED		0x2
#endif
 
