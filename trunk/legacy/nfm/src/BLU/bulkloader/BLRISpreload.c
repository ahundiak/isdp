/******************************************************************************

Doc:    BLRIS_pre_load

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLRISpreload.c

Author: Rob Whitesell

Date:   20-SEPTEMBER-1991

Description:
        This function controls the RIS pre-load option.
        It writes its own messages to the results file.

Examples:
          BLRIS_pre_load(ris_fp);

Return Status:
          (none)

History:

******************************************************************************/
  

#include <stdio.h>
#include <string.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


long BLRIS_pre_load (fp)
  FILE *fp;
{
long   status;
char   sql_line[4000];
char  *error_m;
char  *spot;
char   work[MAX_ASCII_LINE_LEN];
int    count;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLRIS_pre_load().\n");

   BLwrite_result(DMD_I_TRY_RIS_PRE,"");

   count = 0;
   sql_line[0]=0;
   while (fgets(work,MAX_ASCII_LINE_LEN,fp)) {
      if (spot=strrchr(work,'\n'))
         strcpy(spot," ");
      strcat(sql_line,work);
      if (spot=strrchr(sql_line,';')) {
         count++;
         strcpy(spot,"\0");
         status = single_select(sql_line,work,&error_m);
         sprintf(work,"%d",count);
         if (status == DMD_S_SUCCESS)
            BLwrite_result(DMD_I_GOOD_RIS_PRE,work);
         else {
            BLwrite_result(DMD_I_BAD_RIS_PRE,work);
            BLwrite_result(DMD_W_RIS_ERROR,error_m);
            }
         sql_line[0] = 0;
         }
      }   
  
   if (sql_line[0]) 
      BLwrite_result(DMD_I_NO_TERM,sql_line);

   return(0);
} /* end BLRIS_pre_load */
