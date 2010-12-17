#include <stdio.h>
#include <string.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"

extern char *BL_ticked();

/******************************************************************************

Doc:    BLdelete_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLdeleteitem.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module controls the performing of the NFM delete item operation.
/---
see History!
        Note:
          1) the item cannot be deleted if there are files checked in to the
               item.
          2) if files are checked in, this fact is noted to the results file
               and the files are flagged for deletion.
          3) if no files are associated, the item is deleted.
---/
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLdelete_item();

Return Status:
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success
          any error status returned by single_select() on failure
          any error status returned by NFMa_flag_item_delete() on failure
          any error status returned by NFMa_delete_item() on failure

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     02/03/92  wrw  -changed to work with new structs
     05/19/92  wrw  -put in BL_ticked call
     05/17/93  wrw  -removed restriction about checkin (NFM changed to allow
                     the deletion of checked in items.)

******************************************************************************/

long BLdelete_item ()
{
long   status;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLdeleteitem.\n");

   BLwrite_result(DMD_I_TRY_DELETE,"");
   BLwrite_result(DMD_I_ITEM_NAME,parameters.item_name);

   /* increment operation counter */
   T_count.deletes_found++;

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_DELETE);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   if (!strcmp(parameters.item_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_DELETE);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLdelete_item because no item name.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   if (!strcmp(parameters.item_rev,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_DELETE);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLdelete_item because no item rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (flags.dbg)
      fprintf(dbgfile,"Calling NFMa_delete_item \n");

   status = NFMa_delete_item(parameters.catalog_name,parameters.item_name
                         ,parameters.item_rev);

   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFMa_delete_item ->status = %x\n",status);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_DELETE);
      NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLdelete_item bad delete status.\n");
      return(status);
      }
 
   flags.delete = 0;
   T_count.deletes_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_DELETE);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLdelete_item normally.\n");
   return(DMD_S_SUCCESS);

} /* end BLdelete_item */
