/* $Id: VDCmdAutxtf.I,v 1.1 2001/01/19 23:10:24 jayadev Exp $ */
/*----------------------------------------------------------------
 * I/VDS
 *
 * File:         ~VDS/VDSannot/VDCmdAutxtf.I
 *
 * Description: This file is for placing form control methods recall of default form data
 *
 * Revision History
 *	$Log: VDCmdAutxtf.I,v $
 *	Revision 1.1  2001/01/19 23:10:24  jayadev
 *	*** empty log message ***
 *	
# Revision 1.1  2000/10/26  17:46:48  pinnacle
# initial revision
#

 *
 * History:
 * 10/16/00      Paul Noel            Creation
 *
 */
/*============================================================================*/

class implementation VDCmdAutxt;


#include <stdio.h>
#include <string.h>
#include <stdlib.h>


#include "VDSannot.h"


#define VD_DEBUG
#include "VDdebug.h"



static  TVDFrmAuTxtData FormVal;

IGRint VDautxt_PrintData(TVDFrmAuTxtData *FormData )
{
  IGRint traceFlag = 0;
  if (traceFlag) {
    
    printf("\n\n******************** FormVal Report *******************\n");
    if(FormData->Offset) {
      printf("* FormVal.Offset = TRUE\n");
    }
    else {
      printf("* FormVal.Offset = FALSE\n"); 
    }
    if(FormData->Leader) {
      printf("* FormVal.Leader = TRUE\n");
    }
    else {
      printf("* FormVal.Leader = FALSE\n"); 
    }
    if(FormData->Action) {
      printf("* FormVal.Action = TRUE\n");
    }
    else {
      printf("* FormVal.Action = FALSE\n");
    }
    
    printf("* X,Y,Z  = [%s] [%s] [%s] \n",FormData->X,FormData->Y,FormData->Z);
    printf("* Leader = [%s] [%s] [%s] \n",FormData->LdOffset,FormData->LdLeader,FormData->LdAngle);
    
    printf("********* end ****** FormVal Report *******************\n\n"); 
  }
  
   return 1;
   
}


IGRint VDautxt_InitData ()
{
  IGRint   retFlag = 0;
  IGRint   sts = 0;
  IGRint   traceFlag = 0;
  IGRchar  fx[128];
  
  // init
  strcpy(fx,"VDautxt_InitData");
  
  // say hi
  if(traceFlag) printf(">>> %s\n",fx);

  //printf("Actually updated the inits\n");
    
  FormVal.Offset = FALSE;
  FormVal.Leader = FALSE;
  FormVal.Action = FALSE;

    strcpy(FormVal.LdOffset,"0.0");
    strcpy(FormVal.LdLeader,"0.0");
    strcpy(FormVal.LdAngle,"30.0");
    strcpy(FormVal.X,"0.0"); 
    strcpy(FormVal.Y,"0.0");
    strcpy(FormVal.Z,"0.0");
  
  
    
    retFlag = 1;
    
wrapup:
    // say bye
    if(traceFlag) printf("<<< %s(%d)\n",fx,retFlag);
    
  return retFlag;
}


IGRint VDautxt_SetData (TVDFrmAuTxtData *FormData )
{
  IGRint retFlag = 0;
  IGRint sts = 0;
  IGRint   traceFlag = 0;
  IGRchar  fx[128];
  
  // init
  strcpy(fx,"VDautxt_SetData");

  // say hi
  if(traceFlag) printf(">>> %s\n",fx);  
  FormVal = *FormData;

  //printf("Printing FormVal - SetData\n");
  //VDautxt_PrintData(&FormVal);

  retFlag = 1;
wrapup:
    // say bye
    if(traceFlag) printf("<<< %s(%d)\n",fx,retFlag);
    
  return retFlag;
}

IGRint VDautxt_GetData(TVDFrmAuTxtData *FormData)
{
  IGRint   retFlag = 0;
  IGRint   sts = 0;
  IGRint   traceFlag = 0;
  IGRchar  fx[128];
  static   initFlag = 0;
  
  // init
  strcpy(fx,"VDautxt_GetData");
  
  // say hi
  if(traceFlag) printf(">>> %s\n",fx);

  if (initFlag = 0) {
    VDautxt_InitData ();
    initFlag = 1;
  }

  // get the structure data out to be seen
    FormData->Offset  = FormVal.Offset;
    FormData->Leader  = FormVal.Leader;
    FormData->Action  = FormVal.Action;
    strcpy(FormData->LdOffset,FormVal.LdOffset);
    strcpy(FormData->LdLeader,FormVal.LdLeader);
    strcpy(FormData->LdAngle,FormVal.LdAngle);
    strcpy(FormData->X,FormVal.X);
    strcpy(FormData->Y,FormVal.Y);
    strcpy(FormData->Z,FormVal.Z);

    // printf("Printing FormData - GetData\n");
    // VDautxt_PrintData(FormData);
    //printf("Printing FormVal - GetData\n");
    //VDautxt_PrintData(&FormVal);
   
    retFlag = 1;
    
wrapup:
    // say bye
    if(traceFlag) printf("<<< %s(%d)\n",fx,retFlag);
    
  return retFlag;
}

#if 0
typedef struct
{
  IGRchar       LdOffset[TEXT_SIZE];
  IGRchar       LdLeader[TEXT_SIZE];
  IGRchar       LdAngle[TEXT_SIZE];
  IGRchar       X[TEXT_SIZE];
  IGRchar       Y[TEXT_SIZE];
  IGRchar       Z[TEXT_SIZE];
  IGRboolean    Offset;
  IGRboolean    Leader;
  IGRboolean    Action;
} TVDFrmAuTxtData;
#endif 




/*============================================================================*/ 
end implementation VDCmdAutxt; 
