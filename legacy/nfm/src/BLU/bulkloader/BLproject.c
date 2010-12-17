#include <stdio.h>
#include <string.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/******************************************************************************

Doc:    BLproject

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLproject.c

Author: Rob Whitesell

Date:   23-AUGUST-1991

Description:
        This function controls the addition of items to NFM projects.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLproject();

Return Status:
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success
          any error status returned by NFMa_add_project_item() on failure.

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     02/02/92  wrw  -updated to new data structures

******************************************************************************/

long BLproject ()
{
long   status;
char  buf1[5];

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLproject.\n");

   BLwrite_result(DMD_I_TRY_PROJECT,"");
   BLwrite_result(DMD_I_PROJECT_NAME,parameters.project_name);

   /* increment operation counter */
   T_count.projects_found++;

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_PROJECT);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   if (!strcmp(parameters.item_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_PROJECT);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLproject because no item name.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   if (!strcmp(parameters.item_rev,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_PROJECT);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLproject because no item rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (!strcmp(parameters.project_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_PROJECT);
      BLwrite_result(DMD_W_MISSING_PARAM,P_PROJECT);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLproject because no project name.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (!strcmp(parameters.project_type,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_PROJECT);
      BLwrite_result(DMD_W_MISSING_PARAM,P_TYPE);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLproject because no project type.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (!strcmp(parameters.project_type,OWNED))
      strcpy(buf1,"O");
   else if (!strcmp(parameters.project_type,REFERENCED))
      strcpy(buf1,"R");
   else {
      BLwrite_result(DMD_W_BAD_PROJ_TYPE,parameters.project_type);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLproject because bad proj type <%s>.\n"
                        ,parameters.project_type);
      return(DMD_W_SYNTAX_ERR);
      }
     

   if (flags.dbg)
      fprintf(dbgfile,"Calling NFMa_add_project_item \n");

   status = NFMa_add_project_item(parameters.project_name
                                 ,parameters.catalog_name,parameters.item_name
                                 ,parameters.item_rev,buf1);
   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFMa_add_project_item ->status = %x\n",status);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_PROJECT);
      NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLproject bad set status.\n");
      return(status);
      }
 
   flags.project = 0;
   T_count.projects_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_PROJECT);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLproject normally.\n");
   return(DMD_S_SUCCESS);

} /* end BLproject */
