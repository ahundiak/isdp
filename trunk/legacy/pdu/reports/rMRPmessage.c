#include	<string.h>
#include 	"FI.h"
#include	<sys/types.h>
#include	<sys/stat.h>
#include	<stdio.h>
#include	<ctype.h>
#include 	"UMS.h"
#include	"MRPmessage.h"
#include	"MRPstr.h"
#include	"MRPmacros.h"
#include	"PSUgadlabs.h"
#include	"PDUstr.h"
#include	"PDUproto.h"
#include	"MRPintdef.h"

extern struct MRPvar *mrpvar;
extern FILE 	*rMRPdbg_fileptr;
extern Form 	psu_master_id;
extern int 	PSUmessage;

/**************************************************************************

***************************************************************************/
int	MRPinterpret_message ( msgNum, var1, var2, var3 )
  int	msgNum;
  char  *var1;
  char  *var2;
  char  *var3;
  {
  int   sts;
  char  msgBuf[80];

strcpy(msgBuf, "");
if ( mrpvar->status != -30 )
  {
  if (var1 != NULL)
       if (var2 != NULL)
           if (var3 != NULL)
		sts = UMSGetByNum(msgBuf, msgNum, "%s%s%s", var1, var2, var3 );
	   else
		sts = UMSGetByNum(msgBuf, msgNum, "%s%s", var1, var2 );
       else	   sts = UMSGetByNum(msgBuf, msgNum, "%s", var1 );
  else
       sts = UMSGetByNum(msgBuf, msgNum, 0 );

  if ( sts )
    {
    if (( msgNum != MRP_E_NoPDMBOM ) && ( PSUmessage == PSU_C_PRODUCT ))
      {
      FIfld_set_text( psu_master_id, PSU_STATUS_FIELD1, 0, 0, msgBuf, FALSE );
      FIg_display( psu_master_id, PSU_STATUS_FIELD1 );
      }
    else
      printf("%s\n", msgBuf);
    }
 }
return( MRP_S_Success );
}
