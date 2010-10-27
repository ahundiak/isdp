/* $Id: VDnfmc.h,v 1.1 2001/02/11 17:30:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDnfmc.h
 *
 * Description:	Stand alone nfm utilities
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDnfmc.h,v $
 *      Revision 1.1  2001/02/11 17:30:40  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/01 21:24:40  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/01 15:33:49  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/10 15:55:49  art
 *      sp merge
 *
 * Revision 1.2  2000/12/06  14:41:34  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  13:52:48  pinnacle
 * ah
 *
 * Revision 1.1  2000/11/27  19:02:20  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/27/00  ah      Creation
 * 01/10/01  ah      sp merge
 * 01/11/01  ah      Changed name from NDnfmx
 ***************************************************************************/
#ifndef VDnfmc_include
#define VDnfmc_include

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------------
 * VDnfmCrypt.c
 */

extern IGRstat VDnfmEncrypt __((IGRchar *passwd_plain, IGRchar *passwd__crypt));
extern IGRstat VDnfmDecrypt __((IGRchar *passwd_crypt, IGRchar *passwd_plain));
  

typedef struct 
{
  char envName[32];
  char appName[32];
  char srvNode[32];
  char schName[32];
  char schPass[32];
  char nfmName[32];
  char nfmPass[32];
  char pdmName[32];
  char pdmPass[32];
  int  pdmNum;  
} TVDnfmEnvInfo;

extern IGRstat VDnfmPrintEnvInfo        __((FILE *file,    TVDnfmEnvInfo *info));
extern IGRstat VDnfmDecodeEnvInfoLine   __((IGRchar *line, TVDnfmEnvInfo *info));

extern IGRstat VDnfmDumpEnvInfoLine     __((FILE *file, IGRchar *line));
extern IGRstat VDnfmDumpEnvInfoFile     __((FILE *file, IGRchar *fileName));

extern IGRstat VDnfmGetEnvInfoFileName  __((IGRchar *fileName));
extern IGRstat VDnfmGetSchemaPassword   __((IGRchar *schema, IGRchar *password));

extern IGRstat VDnfmGetEnvInfoForPdmEnv __((IGRchar *env, TVDnfmEnvInfo *info, void (*showStatus)(IGRchar *buf)));
  
extern IGRstat VDnfmLocateSchemaFile    __((TVDnfmEnvInfo *info, void (*showStatus)(IGRchar *buf) ));
extern IGRstat VDnfmOpenSchema          __((TVDnfmEnvInfo *info, void (*showStatus)(IGRchar *buf) ));
extern IGRstat VDnfmValidateUser        __((TVDnfmEnvInfo *info, void (*showStatus)(IGRchar *buf) ));

extern IGRstat VDnfmOpenEnv __((IGRchar *a_envName, 
				void (*showStatus)(IGRchar *buf),
				TVDnfmEnvInfo *info));

#define VDNFM_FORM_LOGIN_NAME "VDnfmLogin.F"
  
/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
