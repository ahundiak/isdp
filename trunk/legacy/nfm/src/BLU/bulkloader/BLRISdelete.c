#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"

extern char *BL_ticked();


/******************************************************************************

Doc:    BLRIS_delete

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLRISdelete.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module controls the performing of the RIS delete operation.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = BLRIS_delete();

Return Status:
          DMD_E_BAD_ALLOC       - bad malloc
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_F_BAD_DELETE      - RIS delete failed
          DMD_S_SUCCESS 	- Success

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     02/02/92  wrw  -changed to work with new data structs
     05/19/92  added code to deal with the tick problem
     11/20/92  corrected a problem with recognizing character fields

******************************************************************************/

long BLRIS_delete ()
{
long  i;
long  status;
long  curr_count,curr_size;
char  hold[100];
char *sql_line, *error_m;
long  buff_size, max_rows;
char  data_buff[512];

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLRIS_delete.\n");

   /* increment operation counter */
   T_count.RISdeletes_found++;

   /* check catalog type */
   if (!parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_NFM_OP,OP_RISDELETE);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that some attributes have been given */
   for (i=0;i<num_of_attributes;i++) {
      if (attributes[i].data[0][0]) 
         break;
      }
   if (i>=num_of_attributes) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_RISDELETE);
      BLwrite_result(DMD_W_ANY_ATTR,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLRIS_delete because no attr specified.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   /* compose the delete statement */
   curr_count = 0; curr_size = 1000;
   sql_line = (char *)malloc(curr_size * sizeof(char));
   if (!sql_line) {
      BLwrite_result(DMD_E_BAD_ALLOC,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLRISdelete() cause bad malloc.\n");
      return(DMD_E_BAD_ALLOC);
      }
   sprintf(sql_line,"delete from %s where ",parameters.catalog_name);
   curr_count = 19 + strlen(parameters.catalog_name);
 
   /* write the where clause */
   for (i=0;i<num_of_attributes;i++) {
      if (!attributes[i].data[0][0])
         continue;
      curr_count += (8 + strlen(attributes[i].name)
                       + strlen(attributes[i].name));
      if (is_char(parameters.catalog_name,attributes[i].name))
         curr_count += 2;
      if (curr_count > (curr_size-10)) {
         curr_size += 300;
         sql_line = (char *) realloc(sql_line,(curr_size*sizeof(char)));
         if (!sql_line) {
            BLwrite_result(DMD_E_BAD_ALLOC,"");
            if (flags.dbg)
               fprintf(dbgfile,"Exiting BLRISdelete() cause bad malloc.\n");
            return(DMD_E_BAD_ALLOC);
            }
         }
      if (is_char(parameters.catalog_name,attributes[i].name))
         sprintf(hold,"%s = '%s' and \0",attributes[i].name
                     ,BL_ticked(attributes[i].data[0]));
      else
         sprintf(hold,"%s = %s and \0",attributes[i].name
                                      ,attributes[i].data[0]);
      strcat(sql_line,hold);
      }
   
   /* remove that last and */
   strcpy(&sql_line[strlen(sql_line)-5],"\0");

   if (flags.dbg)
      fprintf(dbgfile,"RISdelete SQL: <%s>\n",sql_line);

   /* perform delete */
   buff_size = 512;
   max_rows  =  10;
   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,&error_m);
   if (flags.dbg)
      fprintf(dbgfile,"status=%d RIS says: <%s>\n",status,error_m);
   if (status) {
      BLwrite_result(DMD_F_BAD_DELETE,"");
      BLwrite_result(DMD_W_RIS_ERROR,error_m);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLRISdelete() cause bad delete.\n");
      free(sql_line);
      return(DMD_F_BAD_DELETE);
      }
   
   flags.RISdelete = 0;
   T_count.RISdeletes_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_RISDELETE);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLRIS_delete normally.\n");
   free(sql_line);
   return(DMD_S_SUCCESS);

} /* end BLdelete_item */
