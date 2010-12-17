#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/******************************************************************************

Doc:    BLmodify

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLmodify.c

Author: Rob Whitesell

Date:   26-AUGUST-1991

Description:
        This module controls the performing of the NFM modify item operation.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLmodify();

Return Status:
          DMD_F_INTERN_ERR      - bad malloc
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success
          any error status returned by NFMa_update_item() on failure

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     02/02/92  wrw  -modified to work with new data storage

******************************************************************************/

long BLmodify()
{
long   num,i,status;
char **attrs,**values;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLmodify.\n");

   BLwrite_result(DMD_I_TRY_MODIFY,"");
   BLwrite_result(DMD_I_ITEM_NAME,parameters.item_name);

   /* increment operation counter */
   T_count.modifys_found++;

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_MODIFY);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   if (!strcmp(parameters.item_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_MODIFY);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLmodify because no item name.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   if (!strcmp(parameters.item_rev,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_MODIFY);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLmodify because no item rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   attrs = (char **) malloc(num_of_attributes * sizeof(char *));
   values     = (char **) malloc(num_of_attributes * sizeof(char *));
   if (!attrs || !values) {
      BLwrite_result(DMD_F_INTERN_ERR,"");
      return(DMD_F_INTERN_ERR);
      }
     
   num = 0;
   for (i=0;i<num_of_attributes;i++) {
      attrs[i] = (char *) malloc(MAX_ATTR_NAME_LEN*sizeof(char));
      values[i]=(char *) malloc(attributes[i].alloc_size*sizeof(char));
      if (!attrs[i] || !values[i]) {
         BLwrite_result(DMD_F_INTERN_ERR,"");
         return(DMD_F_INTERN_ERR);
         }
/* MORE FOR 3.0
     -should make sure they are only modifying item attrs
     -should do a change file on the file atts */
      if (attributes[i].stored) 
         if (   !flags.nfm_mode  
             && (   !strcmp(attributes[i].name,D_MULT_PAGE)
                 || !strcmp(attributes[i].name,D_REDUCED)
                 || !strcmp(attributes[i].name,D_MIRROR)
                 || !strcmp(attributes[i].name,D_DESC))) 
            /* user wants to update some attribute in the d_table. */
            BLwrite_result(DMD_W_NO_MOD_D_CAT,attributes[i].name);
         else {
            strcpy(attrs[num],attributes[i].name);
            strcpy(values[num],attributes[i].data[0]);
            num++;
            }
      }

   if (flags.dbg)
      fprintf(dbgfile,"Calling NFMa_update_item \n");

   status = NFMa_update_item(parameters.catalog_name,parameters.item_name
                            ,parameters.item_rev,attrs,values,num,0);

   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFMa_update_item ->status = %x\n",status);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_MODIFY);
      NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLmodify bad modify status.\n");
      return(status);
      }
 
   flags.modify = 0;
   T_count.modifys_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_MODIFY);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLmodify normally.\n");
   return(DMD_S_SUCCESS);

} /* end BLmodify */
