#include <stdio.h>
#include <string.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/******************************************************************************

Doc:    BLadd_set

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLaddset.c

Author: Rob Whitesell

Date:   21-AUGUST-1991

Description:
        This module controls the performing of the NFM add set operation.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLadd_set();

Return Status:
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success
          any error code returned by NFMa_add_set() on failure.

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     02/02/92  wrw  -updated to new data storage stuff

******************************************************************************/

long BLadd_set ()
{
char  buf2[20];
long  status;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLaddset.\n");

   BLwrite_result(DMD_I_TRY_ADD_SET,"");
   BLwrite_result(DMD_I_SET_NAME,parameters.set_name);

   /* increment operation counter */
   T_count.c_sets_found++;

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_CREATE_SET);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   if (!strcmp(parameters.set_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_CREATE_SET);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLadd_set because no set name.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   if (!strcmp(parameters.set_rev,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_CREATE_SET);
      BLwrite_result(DMD_W_MISSING_PARAM,P_SET_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLadd_set because no set rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (parameters.set_acl_no < 0) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_CREATE_SET);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ACL_NO);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLadd_set because no acl num.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   sprintf(buf2,"%d\0",parameters.set_acl_no);

   if (flags.dbg)
      fprintf(dbgfile,"Calling NFMa_add_set \n");
   status = NFMa_add_set(parameters.set_catalog,parameters.set_name
                         ,parameters.set_rev,buf2);
   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFMa_add_set ->status = %x\n",status);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_CREATE_SET);
      NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLadd_set bad add status.\n");
      return(status);
      }
 
   flags.create_set = 0;
   T_count.c_sets_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_CREATE_SET);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLadd_set normally.\n");
   return(DMD_S_SUCCESS);

} /* end BLadd_set */
