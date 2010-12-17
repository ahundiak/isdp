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

Doc:    BLRIS_insert

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLRISinsert.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module controls the performing of the RIS insert operation.
        It writes its own messages to the results file, and returns a status
           code

Examples:
          status = BLRIS_insert();

Return Status:
          DMD_E_BAD_ALLOC       - bad malloc
          DMD_W_SYNTAX_ERR      - bad information in globals
          DMD_F_BAD_INSERT      - RIS insert failed
          DMD_S_SUCCESS 	- Success

History:  
     09/03/91  wrw  -added standard header and converted externs to .h
     02/02/92  wrw  -changed to use new data struct.
     05/19/92  wrw  -fixed the problem with ticks
     11/20/92  wrw  -corrected a problem with recognizing char fields

******************************************************************************/

long BLRIS_insert ()
{
long  i;
long  status;
long  curr_count,curr_size;
char  hold[100];
char *sql_line, *error_m;
long  buff_size, max_rows;
char  data_buff[512];

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLRIS_insert.\n");

   /* increment operation counter */
   T_count.RISinserts_found++;

   /* check catalog type */
   if (!parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_NFM_OP,OP_RISINSERT);
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
      BLwrite_result(DMD_W_MISSING_INFO,OP_RISINSERT);
      BLwrite_result(DMD_W_ANY_ATTR,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLRIS_insert because no attr specified.\n");
      return(DMD_W_SYNTAX_ERR);
      }
  
   if (flags.dbg)
      fprintf(dbgfile,"Attributes found, continue insert\n");
   /* compose the insert statement */
   curr_count = 0; curr_size = 1000;
   sql_line = (char *) malloc(curr_size * sizeof(char));
   if (!sql_line) {
      BLwrite_result(DMD_E_BAD_ALLOC,"");
      return(DMD_E_BAD_ALLOC);
      }
   sprintf(sql_line,"insert into %s (",parameters.catalog_name);
   curr_count = 14 + strlen(parameters.catalog_name);
 
   /* write the column names */
   for (i=0;i<num_of_attributes;i++) {
      if (!attributes[i].data[0][0])
         continue;
      curr_count += (1 + strlen(attributes[i].name));
      if (curr_count > (curr_size-10)) {
         curr_size += 300;
         sql_line = (char *) realloc(sql_line,(curr_size*sizeof(char)));
         if (!sql_line) {
            BLwrite_result(DMD_E_BAD_ALLOC,"");
            if (flags.dbg)
               fprintf(dbgfile,"Exiting BLRISinsert() cause bad malloc.\n");
            return(DMD_E_BAD_ALLOC);
            }
         }
      sprintf(hold,"%s,\0",attributes[i].name);
      strcat(sql_line,hold);
      }

   if (flags.dbg)
      fprintf(dbgfile,"SQL so far: <%s>\n",sql_line);
   
   /* remove that last comma */
   strcpy(strrchr(sql_line,','),"\0");
   curr_count -= 1;

   if (flags.dbg)
      fprintf(dbgfile,"SQL so far: <%s>\n",sql_line);
   
   /* write values */
   curr_count += 10;
   strcat(sql_line,") values (");
   if (curr_count > (curr_size-10)) {
      curr_size += 300;
      sql_line = (char *) realloc(sql_line,(curr_size*sizeof(char)));
      if (!sql_line) {
         BLwrite_result(DMD_E_BAD_ALLOC,"");
         if (flags.dbg)
            fprintf(dbgfile,"Exiting BLRISinsert() cause bad malloc.\n");
         return(DMD_E_BAD_ALLOC);
         }
      }
   for (i=0;i<num_of_attributes;i++) {
      if (!attributes[i].data[0][0])
         continue;
      curr_count += (1 + attributes[i].alloc_size);
      if (is_char(parameters.catalog_name,attributes[i].name))
         curr_count += 2;
      if (curr_count > (curr_size-10)) {
         curr_size += 300;
         sql_line = (char *) realloc(sql_line,(curr_size*sizeof(char)));
         if (!sql_line) {
            BLwrite_result(DMD_E_BAD_ALLOC,"");
            if (flags.dbg)
               fprintf(dbgfile,"Exiting BLRISinsert() cause bad malloc.\n");
            return(DMD_E_BAD_ALLOC);
            }
         }
      if (is_char(parameters.catalog_name,attributes[i].name))
         sprintf(hold,"'%s',\0",BL_ticked(attributes[i].data[0]));
      else
         sprintf(hold,"%s,\0",attributes[i].data[0]);
      strcat(sql_line,hold);
      }

   /* remove that last comma */
   strcpy(strrchr(sql_line,','),")");

   if (flags.dbg)
      fprintf(dbgfile,"RISinsert SQL: <%s>\n",sql_line);

   /* perform insert */
   buff_size = 512;
   max_rows  =  10;
   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,&error_m);
   if (flags.dbg)
      fprintf(dbgfile,"status=%d RIS says: <%s>\n",status,error_m);
   if (status) {
      BLwrite_result(DMD_F_BAD_INSERT,"");
      BLwrite_result(DMD_W_RIS_ERROR,error_m);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLRISinsert() cause bad insert.\n");
      free(sql_line);
      return(DMD_F_BAD_INSERT);
      }
   
   flags.RISinsert = 0;
   T_count.RISinserts_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_RISINSERT);

   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLRIS_insert normally.\n");
   free(sql_line);
   return(DMD_S_SUCCESS);

} /* end BLadd_item */
