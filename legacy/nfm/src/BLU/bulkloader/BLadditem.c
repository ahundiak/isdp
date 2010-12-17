#include <stdio.h>
#include <string.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/******************************************************************************

Doc:    BLadd_item

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLadditem.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module controls the performing of the NFM add item operation.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLadd_item();

Return Status:
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success
          any error code returned from NFMa_add_item() on failure.

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     09/23/91  wrw  -modified the parameters used to call NFMa_add_item.
     02/02/92  wrw  -modified to use new data structures.
     08/19/92  wrw  -made change for ftr to work

******************************************************************************/

long BLadd_item ()
{
char  buf2[20];
long   status;
long   i;
char **attrs,**values;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLadditem.\n");

   BLwrite_result(DMD_I_TRY_ADD,"");
   BLwrite_result(DMD_I_ITEM_NAME,parameters.item_name);

   /* increment operation counter */
   T_count.adds_found++;

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_ADD);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   if (!strcmp(parameters.item_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_ADD);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLadd_item because no item name.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   if (!strcmp(parameters.item_rev,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_ADD);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLadd_item because no item rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (parameters.acl_no < 0) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_ADD);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ACL_NO);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLadd_item because no acl num.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   sprintf(buf2,"%d\0",parameters.acl_no);

   /* write out the user defined and additional nfm attributes and values */
   attrs = (char **) malloc (num_of_attributes*sizeof(char *));
   values = (char **) malloc (num_of_attributes*sizeof(char *));
   if (!attrs || !values) {
      BLwrite_result(DMD_E_BAD_ALLOC,"");
      return(DMD_E_BAD_ALLOC);
      }
   for (i=0;i<num_of_attributes;i++) {
      attrs[i] = (char *) malloc(MAX_ATTR_NAME_LEN*sizeof(char));
      values[i] = (char *) malloc(attributes[i].alloc_size*sizeof(char));
      if (!attrs[i] || !values[i]) {
         BLwrite_result(DMD_E_BAD_ALLOC,"");
         return(DMD_E_BAD_ALLOC);
         }
      strcpy(attrs[i],attributes[i].name);
		if (   !strncmp(attributes[i].data[0],RR_INDIC,1)
          || !strncmp(attributes[i].data[0],RL_INDIC,1)
          || !strncmp(attributes[i].data[0],FTR_INDIC,1))
         strcpy(values[i],&attributes[i].data[0][1]);
		else
         strcpy(values[i],attributes[i].data[0]);
      }

   if (flags.dbg)
      fprintf(dbgfile,"Calling NFMa_add_item \n");
   status = NFMa_add_item(parameters.catalog_name,parameters.item_name
                         ,parameters.item_rev,buf2,attrs,values
                         ,num_of_attributes);
   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFMa_add_item ->status = %x\n",status);

/* free up the arrays created for the call */
   for (i=0;i<num_of_attributes;i++) {
      free(attrs[i]);
      free(values[i]);
      }
   free(attrs); free(values);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_ADD);
      NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLadd_item bad add status.\n");
      return(status);
      }
 
   flags.add = 0;
   T_count.adds_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_ADD);

/* MORE FOR 3.0  
    -need to add other files to the data base so that the simple_checkin
     call can be used */

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLadd_item normally.\n");
   return(DMD_S_SUCCESS);

} /* end BLadd_item */
