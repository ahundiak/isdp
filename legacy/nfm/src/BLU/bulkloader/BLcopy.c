#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"


/******************************************************************************

Doc:    BLcopy

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcopy.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module controls the performing of the NFM copy operation.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLcopy();

Return Status:
          DMD_F_INTERN_ERR      - bad malloc
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success
          any error status returned by NFM2_copy_item on failure

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     02/02/92  wrw  -modified to use new data structs

******************************************************************************/
  
long BLcopy ()
{
long   i,fl,len;
long   status;
long   tot_files;
long   co_sa;
char *files;
char *tmp;
char *tmp2;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLcopy.\n");

   T_count.copys_found++;

   BLwrite_result(DMD_I_TRY_COPY,"");
   BLwrite_result(DMD_I_ITEM_NAME,parameters.item_name);

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_COPY);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   if (!strcmp(parameters.item_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_COPY);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcopy() because no item name.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   if (!strcmp(parameters.item_rev,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_COPY);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcopy() because no item rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   fl= parameters.co_file_index;
   len=attributes[fl].alloc_size;
   
   /* find check out storage area */
/* tmpPS - 13 June 96 - added ! mark before attributes ( if NULL then ) */
   if (((i=parameters.cosa_index)<0)||(!attributes[i].data[0][0])){
      BLwrite_result(DMD_W_MISSING_INFO,OP_COPY);
      BLwrite_result(DMD_W_MISSING_PARAM,P_CO_SA);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcopy() because no co_sa.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   co_sa = atoi(attributes[i].data[0]);
   if (!(status=valid_sa(co_sa))) {
      BLwrite_result(DMD_W_BAD_INFO,P_CO_SA);
      BLwrite_result(DMD_W_BAD_VALUE,attributes[i].data[0]);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcopy() because bad co_sa.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   if (status != 1) {
         BLwrite_result(DMD_F_INTERN_ERR,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcopy() because bad malloc. \n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   files=(char *) malloc(((attributes[fl].stored*len)
                          +attributes[fl].stored+20)*sizeof(char));
   if (!files) {
      BLwrite_result(DMD_E_BAD_ALLOC,"");
      return(DMD_E_BAD_ALLOC);
      }

   tmp2=(char *) malloc(((attributes[fl].stored*len)
                         +attributes[fl].stored+1)*sizeof(char));
   if (!tmp2) {
      BLwrite_result(DMD_E_BAD_ALLOC,"");
      free(files);
      return(DMD_E_BAD_ALLOC);
      }

   strcpy(tmp2,"\0");
   tot_files = attributes[fl].stored;
   for (i=0;i<attributes[fl].stored;i++) {
      tmp = attributes[fl].data[i];
      if (!strncmp(tmp,RL_INDIC,1)) {
         tot_files--;
         continue;
         }
      if (!strncmp(tmp,RR_INDIC,1))
         tmp++;
      strcat(tmp2,tmp);
      strcat(tmp2,"~");
      }
 
   if (tot_files>0) 
      sprintf(files,"#~%d~%s\0",tot_files,tmp2);
   else
      sprintf(files,"");

   if (flags.dbg)
      fprintf(dbgfile,"Calling NFM2_copy_item,File list: <%s>\n",files);

   status = NFM2_copy_item(parameters.catalog_name,parameters.item_name
                              ,parameters.item_rev,sa_names[co_sa],files);

   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFM2_copy_item status-->%x\n",status);

   free(files);
   free(tmp2);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_COPY);
      NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcopy() bad copy status.\n");
      return(status);
      }
 
   flags.copy = 0;
   T_count.copys_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_COPY);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLcopy normally.\n");
   return(DMD_S_SUCCESS);
} /* end BLcopy */
