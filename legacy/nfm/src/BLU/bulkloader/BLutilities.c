#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <ctype.h>
#include "UMS.h"
#include "BLums.h"
#include "BLdefs.h"
#include "BLtypes.h"
#include "BLvars.h"

/* some stuff needed from NFMa_stuff.c */
extern char     NFM_Error_Messages[][512];
extern long     NFM_Messages;

/* Global variables (used in this .c only) */
long    cash_start=0;
char NFM_cash[CASH_SLOTS][MAX_CAT_NAME_LEN];
char RIS_cash[CASH_SLOTS][MAX_CAT_NAME_LEN];


/******************************************************************************

Doc:    BLwrite_result

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function fetches a message from the UMS (based on the error code
           and information supplied).
        If the text parameter is NULL, it fetches a message with no specific
           inputs.
        It writes the fetched message to the results file.

Examples:
          BLwrite_result(error_code
                         info_text);

Return Status:
          (none)

History:
     09/03/91  wrw  -added standard header and converted externs to .h

******************************************************************************/
void BLwrite_result(err_code, info) 
int err_code;                 /* I - error code that matches UMS message */
char *info;                   /* I - text message to insert into UMS message */
{
char errmsg[MAX_ASCII_LINE_LEN];

   /* get message from UMS */
   if (!strcmp(info,""))
      UMSGetByNum(errmsg,err_code,0);
   else
      UMSGetByNum(errmsg,err_code,"%s",info);

   /* write out error message */
   fprintf(results,"%s\n",errmsg);

} /* end write_result */


/******************************************************************************

Doc:    BLwrite_output

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function fetches a message from the UMS (based on the error code
           and information supplied).
        If the text parameter is NULL, it fetches a message with no specific
           inputs.
        It writes the fetched message to the standard out.

Examples:
          BLwrite_result(error_code
                         info_text);

Return Status:
          (none)

History:
     09/03/91  wrw  -added standard header

******************************************************************************/
  
void BLwrite_output(err_code, info) 
long   err_code;               /* I - error code that matches UMS message */
char *info;                   /* I - text message to insert into UMS message */
{
char errmsg[MAX_ASCII_LINE_LEN];

   /* get message from UMS */
   if (!strcmp(info,""))
      UMSGetByNum(errmsg,err_code,0);
   else
      UMSGetByNum(errmsg,err_code,"%s",info);

   /* write out error message */
   printf("%s\n",errmsg);

} /* end write_output() */


/******************************************************************************

Doc:    BLwrite_sts

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function fetches a message from the UMS (based on the error code
           and information supplied).
        If the text parameter is NULL, it fetches a message with no specific
           inputs.
        It writes the fetched message to the .sts file

Examples:
        BLwrite_sts(error_code
                    info_text);

Return Status:
        (none)

History:
******************************************************************************/

void BLwrite_sts(err_code, info) 
int err_code;                 /* I - error code that matches UMS message */
char *info;                   /* I - text message to insert into UMS message */
{
char errmsg[MAX_ASCII_LINE_LEN];

   /* get message from UMS */
   if (!strcmp(info,""))
      UMSGetByNum(errmsg,err_code,0);
   else
      UMSGetByNum(errmsg,err_code,"%s",info);

   /* write out error message */
   if (stsfile)
      fprintf(stsfile,"%s\n",errmsg);

} /* end BLwrite_sts */


/******************************************************************************

Doc:    single_select

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function executes a give line of SQL.
        It was originally intended for this funtion to perform selects that 
           were sure to return only one value.  It can also be used to do
           inserts, updates, etc.
        It returns a single value (first column, first row) in the parameter
           'value'.  Space to hold this value must be allocated by calling 
           function.
        It returns the RIS provided error message in 'error_m'

Examples:
          single_select(sql_line,
                        value,
                        &error_m_char_ptr);

Return Status:
          DMD_S_SUCCESS    - success
          any error status returned by SS_sql() on a failure.

History:
     09/03/91  wrw  -added standard header
     09/20/91  wrw  -cleaned up the processing of non-select statements.
     10/21/92  wrw  -converted to use NFMa_single_select()

******************************************************************************/
  
long single_select (sql_line,value,error_m)
char *sql_line;      /* I - char ptr to a line of SQL to submit */
char *value;         /* O - char ptr to a place to store the value returned */
char **error_m;      /* O - address of char ptr to allocate to store error 
                              messages from RIS.  Space allocated by RIS */
{

long    status;


	status=NFMa_single_select(sql_line,value,error_m);

	if (status)
		return(status);
	else
		return(DMD_S_SUCCESS);
/*
long    k;
long   buff_size, max_rows;
char   data_buff[3072];
long   rows_cols, rows, cols;
long  *src;
short *size;
char  *data;

   if (flags.dbg)
      fprintf(dbgfile,"in single_sql sql_line: <%s>\n",sql_line);

   value[0]=0;

   buff_size=3072;
   max_rows=5;
   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,error_m);

   if (strncmp(sql_line,"select",6)) {
      if (status)
         return(status);
      else
         return(DMD_S_SUCCESS);
      }

   if (status) {
      if (status == 0x8088013)
         return(DMD_S_SUCCESS);
      if (flags.dbg)
         fprintf(dbgfile,"status =%x, error <%s>\n",status,*error_m);
      return(status);
      }
   else {
      src = (long *)data_buff;
      status = (*src++);
      rows_cols = (*src++);
      cols = (*src++);
      rows = rows_cols/cols;
      size = (short *)src;
      data = (char *)((long)size+((rows_cols + cols)*sizeof(short)));
      if (flags.dbg)
         fprintf(dbgfile,"rows=%d,cols=%d\n",rows,cols);
      if (status || rows == 0) {
         if (flags.dbg)
            fprintf(dbgfile,"Bad internal or no rows\n");
         if (status) 
            return(status);
         else 
            return(DMD_S_SUCCESS);
         }
      else {
         for (k=1;k<=cols;k++) {
            data += (*size+1);
            size++;
            }
         strcpy(value,data);
         if (flags.dbg)
            fprintf(dbgfile,"returning data=<%s>\n",value);
         }
      }
   return(DMD_S_SUCCESS);
*/
} /* end single_select () */


/******************************************************************************

Doc:    BLvalid_cat

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function determines if a give catalog (supplied by name) exists 
           either as a NFM or a RIS catalog. 
        If the mode supplied is NFM_CAT, it checks its existience as an NFM
           catalog.
        If the mode supplied is RIS_CAT, it checks its existience as an RIS
           catalog.

Examples:
          BLvalid_cat(catalog_name,
                      catalog_mode);

Return Status:
          1       - catalog exists as specified mode.
          0       - catalog does not exist as specified mode.

History:
     09/03/91  wrw  -added standard header

******************************************************************************/
  
long BLvalid_cat (name,mode)
char *name;          /* I - name of the catalog to check for */
long   mode;          /* I - mode to check for: either NFM_CAT for NFM catalogs
                            or RIS_CAT for RIS catalogs */
{
long  i;
char sql_line[100], *error_m;
long status;
char value[MAX_CAT_NAME_LEN];

   if (!cash_start) 
      for (i=0;i<CASH_SLOTS;i++) {
          NFM_cash[i][0]=0;
          RIS_cash[i][0]=0;
          }

   if (mode == NFM_CAT) {
      /* check in the cash */
      for (i=0;i<CASH_SLOTS;i++) 
          if (!strcmp(name,NFM_cash[i]))
             return(1);
          
      /* select the nfm catalogs.  */
      sprintf(sql_line,
          "select n_catalogname from nfmcatalogs where n_catalogname='%s'"
          ,name);
      }
   else if (mode == RIS_CAT) {
      /* check in the cash */
      for (i=0;i<CASH_SLOTS;i++) 
          if (!strcmp(name,RIS_cash[i]))
             return(1);
          
      /* select the RIS catalogs.  */
      sprintf(sql_line,
          "select table_name from ris5tables where table_name='%s'",name);
      }
   else {
      if (flags.dbg) 
         fprintf(dbgfile,"BLvalid_cat=0, mode unknown\n");
      return(0);
      }

   /* perform select */
   status = single_select(sql_line,value,&error_m);

   if (status != DMD_S_SUCCESS) {
      if (flags.dbg) {
         fprintf(dbgfile,"BLvalid_cat=0, bad SS_sql status\n");
         fprintf(dbgfile,"RIS error message: <%s>\n",error_m);
         }
      return(0);
      }

   if (value[0] != 0) {
      if (flags.dbg) 
         fprintf(dbgfile,"BLvalid_cat=1, rows returned\n");
      return(1);
      }
   else {
     if (mode == RIS_CAT) {
        for (i=0;i<(CASH_SLOTS-1);i++) 
           strcpy(RIS_cash[i],RIS_cash[i+1]);
        strcpy(RIS_cash[CASH_SLOTS-1],name);
        }
     if (mode == NFM_CAT) {
        for (i=0;i<(CASH_SLOTS-1);i++) 
           strcpy(NFM_cash[i],NFM_cash[i+1]);
        strcpy(NFM_cash[CASH_SLOTS-1],name);
        }
     if (flags.dbg) 
        fprintf(dbgfile,"BLvalid_cat=0, no rows returned\n");
     return (0);
     }
} /* end BLvalid_cat */


/******************************************************************************

Doc:    BLfind_attr

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function returns the index of an attribute (supplied by name) in
           the global structures of the current catalog.

Examples:
          BLfind_attr(attr_name);

Return Status:
          -1          -if attribute does not exist in current catalog structure
          index       -if attribute is found

History:
     09/03/91  wrw  -added standard header

******************************************************************************/
  
long BLfind_attr (name)
char *name;           /* I - name of the attribute to return the index of */
{
long   i;

   for (i=0;i<num_of_attributes;i++) {
      if (!strcmp(attributes[i].name,name))
         return(i);
      }
   return(-1);
} /* end BLfind_attr */


/******************************************************************************

Doc:    header_out

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function writes our the header for the results and mail files.
        It writes the header to the file supplied as a parameter.

Examples:
          header_out(out_file_fp);

Return Status:
          (none)

History:
  09/03/91  wrw  -added standard header
  06/14/92  wrt  -added more header info

******************************************************************************/
  
void header_out(out)
FILE *out;           /* I - file pointer of the file to write to */
{
long  seconds;
long   len;
char  msg[MAX_ASCII_LINE_LEN];
char  hold[MAX_ASCII_LINE_LEN];
char *tmp;
FILE *fp;

   seconds=time(0);

   UMSGetByNum(msg,DMD_I_RESULT_HEADER,0);
   len = ((80-strlen(msg))/2) + strlen(msg);
   fprintf(out,"%*s\n",len,msg);

   UMSGetByNum(msg,DMD_I_ON_ENVIRON,"%s",n_environ);
   len = ((80-strlen(msg))/2) + strlen(msg);
   fprintf(out,"%*s\n",len,msg);

   UMSGetByNum(msg,DMD_I_ON_SERVER,"%s",server);
   len = ((80-strlen(msg))/2) + strlen(msg);
   fprintf(out,"%*s\n",len,msg);

#if defined(SCO_UNIX) || defined(SPARC_SOLARIS) || defined(INTEL_SOLARIS)
   fp=popen("uname -n","r");
#else
   fp=vpopen("uname -n","r");
#endif

   if (fp) {
      fgets(hold,MAX_ASCII_LINE_LEN,fp);
      if ((tmp=strrchr(hold,'\n'))!=NULL)
         strcpy(tmp,"\0");
      }
   else
      hold[0]=0;
   
   strcpy(on_node,hold);
   UMSGetByNum(msg,DMD_I_ON_NODE,"%s",on_node);
   len = ((80-strlen(msg))/2) + strlen(msg);
   fprintf(out,"%*s\n",len,msg);

   sprintf(msg,"%s\0",ctime(&seconds));
   len = ((80-strlen(msg))/2) + strlen(msg);
   fprintf(out,"%*s\n\n",len,msg);
   
   UMSGetByNum(msg,DMD_I_BULK_FN,"%s",fn_bulkload);
   fprintf(out,"%s\n",msg);

   UMSGetByNum(msg,DMD_I_RESULT_FN,"%s",fn_results);
   fprintf(out,"%s\n",msg);

   if (flags.sts) {
      UMSGetByNum(msg,DMD_I_STS_FN,"%s",fn_sts);
      fprintf(out,"%s\n",msg);
      }

   UMSGetByNum(msg,DMD_I_RELOAD_FN,"%s",fn_reload);
   fprintf(out,"%s\n\n",msg);
} /* end header_out */


/******************************************************************************

Doc:    tail_out

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function writes our the tail for the results and mail files.
        It writes the tail to the file supplied as a parameter.

Examples:
          tail_out(out_file_fp);

Return Status:
          (none)

History:
  06/28/91  wrw  -added code to support NFM copy operation.
  08/21/91  wrw  -added code to support NFM create_set operation.
  08/23/91  wrw  -added code to support NFM add_to_project operation.
  08/26/91  wrw  -added code to support NFM modify operation.
  09/03/91  wrw  -added standard header
  09/13/91  wrw  -added code to support mirror archiving.
  06/14/92  wrw  -added code to support FTR indexing
  09/22/94  wrw  -added code to support set check in/out

******************************************************************************/
  
void tail_out(out)
FILE *out;           /* I - file pointer of the file to write to */
{
char  msg[MAX_ASCII_LINE_LEN];

   fprintf(results,"\n\nBulkload Totals:\n");

   if (T_count.records_found > 0) {
      UMSGetByNum(msg,DMD_I_RESULTS_R,"%d%d",T_count.records_performed
                     ,T_count.records_found);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.adds_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.adds_performed
                     ,T_count.adds_found,OP_ADD);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.projects_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.projects_performed
                     ,T_count.projects_found,OP_PROJECT);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.modifys_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.modifys_performed
                     ,T_count.modifys_found,OP_MODIFY);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.deletes_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.deletes_performed
                     ,T_count.deletes_found,OP_DELETE);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.checkins_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.checkins_performed
                     ,T_count.checkins_found,OP_CHECKIN);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.checkouts_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.checkouts_performed
                     ,T_count.checkouts_found,OP_CHECKOUT);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.copys_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.copys_performed
                     ,T_count.copys_found,OP_COPY);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.c_sets_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.c_sets_performed
                     ,T_count.c_sets_found,OP_CREATE_SET);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.sets_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.sets_performed
                     ,T_count.sets_found,OP_SET);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.setins_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.setins_performed
                     ,T_count.setins_found,OP_SETIN);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.setouts_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.setouts_performed
                     ,T_count.setouts_found,OP_SETOUT);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.RISinserts_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.RISinserts_performed
                     ,T_count.RISinserts_found,OP_RISINSERT);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.RISdeletes_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.RISdeletes_performed
                     ,T_count.RISdeletes_found,OP_RISDELETE);
      fprintf(out,"     %s\n",msg);
      }

   if (T_count.ftr_indexs_found>0) {
      UMSGetByNum(msg,DMD_I_RESULTS_O,"%d%d%s",T_count.ftr_indexs_performed
                     ,T_count.ftr_indexs_found,OP_FTR_INDEX);
      fprintf(out,"     %s\n",msg);
      }

   if (mirror_count > 0) {
      UMSGetByNum(msg,DMD_I_M_RESULTS,"%d%d",mirror_okay,mirror_count);
      fprintf(out,"     %s\n",msg);
      }

} /* end tail_out */


/******************************************************************************

Doc:    ignore_comments

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function ignores comment lines in the .blk file by skipping over
           them.
        Algorith:
           1) Save current position, read next line.
           2) if line is a comment, perform step 1 again.
              else reset file to saved position.

Examples:
          ignore_comments();

Return Status:
          DMD_W_EOF_FOUND  - EOF was encountered in the .blk file.
          DMD_S_SUCCESS    - comment lines have been skipped over.

History:
     09/03/91  wrw  -added standard header

******************************************************************************/
  
long ignore_comments() 
{
long hold_pos;
char work[MAX_ASCII_LINE_LEN+1];

   /* save current position in file */
   hold_pos = ftell(bulkload);

   /* loop and skip over comments */
   while (fgets(work,(MAX_ASCII_LINE_LEN),bulkload) != NULL) {
      if (strncmp(work,COMMENT_DELIMIT,1)) {
         fseek (bulkload,hold_pos,0);
         return (DMD_S_SUCCESS);
         }
      /* save new position in file */
      hold_pos = ftell(bulkload);
      }
   
   /* if control gets to here then EOF occured */
   return(DMD_W_EOF_FOUND);
} /* end ignore_comments */


/******************************************************************************

Doc:    BLwrite_reload

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function writes a data record to the reload file from values 
           found in memory.
        Operations who's flags are set get written out.
        All values of attributes get written out.

Examples:
          BLwrite_reload();

Return Status:
          (none)

History:
     06/23/91  wrw  -removed erroneous tailing PARAM_DELIMIT from delete 
                        operation.
     06/28/91  wrw  -added code to support NFM copy operation.
     08/21/91  wrw  -added code to support NFM create_set operation.
     08/23/91  wrw  -added code to support NFM add_to_project operation.
     08/26/91  wrw  -added code to support NFM modify operation.
     09/03/91  wrw  -added standard header
     08/25/92  wrw  -added code to support ftr indexing.
     09/22/94  wrw  -added code to support set check in/out

******************************************************************************/
  
void BLwrite_reload()
{
char work[MAX_ASCII_LINE_LEN];
char  hld_acl_no[10];
long   i;

   hld_acl_no[0]=0;
   if (parameters.acl_no >= 0)
     sprintf(hld_acl_no,"%d\0",parameters.acl_no);

   /* catalog is required */
   fprintf(reload,"%s%c%s\n",OP_CATALOG,PARAM_DELIMIT,parameters.catalog_name);
   
   /* check other operations */
   if (flags.add) 
      fprintf(reload,"%s%c%s%c%s%c%s\n",OP_ADD,PARAM_DELIMIT
                    ,parameters.item_name,PARAM_DELIMIT,parameters.item_rev
                    ,PARAM_DELIMIT,hld_acl_no);
   if (flags.project)
      fprintf(reload,"%s%c%s%c%s\n",OP_PROJECT,PARAM_DELIMIT
                    ,parameters.project_name,PARAM_DELIMIT
                    ,parameters.project_type);
   if (flags.create_set)
      fprintf(reload,"%s%c%s%c%s%c%s%c%d\n",OP_CREATE_SET,PARAM_DELIMIT
                    ,parameters.set_catalog,PARAM_DELIMIT,parameters.set_name
                    ,PARAM_DELIMIT,parameters.set_rev,PARAM_DELIMIT
                    ,parameters.set_acl_no);
   if (flags.modify) 
      fprintf(reload,"%s%c%s%c%s\n",OP_MODIFY,PARAM_DELIMIT
                    ,parameters.item_name,PARAM_DELIMIT,parameters.item_rev);
   if (flags.delete) 
      fprintf(reload,"%s%c%s%c%s\n",OP_DELETE,PARAM_DELIMIT
                    ,parameters.item_name,PARAM_DELIMIT,parameters.item_rev);
   if (flags.checkin) 
      fprintf(reload,"%s%c%s%c%s\n",OP_CHECKIN,PARAM_DELIMIT
                    ,parameters.item_name,PARAM_DELIMIT,parameters.item_rev);
   if (flags.copy) 
      fprintf(reload,"%s%c%s%c%s\n",OP_COPY,PARAM_DELIMIT
                    ,parameters.item_name,PARAM_DELIMIT,parameters.item_rev);
   if (flags.checkout) 
      fprintf(reload,"%s%c%s%c%s\n",OP_CHECKOUT,PARAM_DELIMIT
                    ,parameters.item_name,PARAM_DELIMIT,parameters.item_rev);
   if (flags.set) 
      fprintf(reload,"%s%c%s%c%s%c%s%c%s\n",OP_SET,PARAM_DELIMIT
                    ,parameters.set_catalog,PARAM_DELIMIT,parameters.set_name
                    ,PARAM_DELIMIT,parameters.set_rev,PARAM_DELIMIT
                    ,parameters.set_mode);
   if (flags.setin) 
      fprintf(reload,"%s%c%s%c%s%c%s\n",OP_SETIN,PARAM_DELIMIT
                    ,parameters.catalog_name,PARAM_DELIMIT,parameters.set_name
                    ,PARAM_DELIMIT,parameters.set_rev);
   if (flags.setout) 
      fprintf(reload,"%s%c%s%c%s%c%s\n",OP_SETOUT,PARAM_DELIMIT
                    ,parameters.catalog_name,PARAM_DELIMIT,parameters.set_name
                    ,PARAM_DELIMIT,parameters.set_rev);
   if (flags.RISinsert) 
      fprintf(reload,"%s\n",OP_RISINSERT);
   if (flags.RISdelete) 
      fprintf(reload,"%s\n",OP_RISDELETE);
   if (flags.ftr_index) 
      fprintf(reload,"%s\n",OP_FTR_INDEX);

   /* write out the division delimeter */
   fprintf(reload,"%s\n",DIVISION_DELIMIT);
  
   /* take care of set and project and ftr_index's 
      params that may not have been supplied in data div */
   if (flags.set || flags.project || flags.ftr_index) {
      if (((i=BLfind_attr(P_ITEM_NAME))<0) || 
          (attributes[i].data[0][0])) 
         fprintf(reload,"%s%c%s\n",P_ITEM_NAME,PARAM_DELIMIT
                                  ,parameters.item_name);
      if (((i=BLfind_attr(P_ITEM_REV))<0) || 
          (attributes[i].data[0][0])) 
         fprintf(reload,"%s%c%s\n",P_ITEM_REV,PARAM_DELIMIT
                                  ,parameters.item_rev);
      }

   /* write out the data division */
   fseek(bulkload,data_div_pos,0);
   while (fgets(work,MAX_ASCII_LINE_LEN,bulkload)) {
      fprintf (reload,"%s",work);
      if (!strncmp(work,RECORD_DELIMIT,1))
         break;
      }
} /* end BLwrite_reload() */


/******************************************************************************

Doc:    check_params

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function checks to see if the supplied attribute name was given
           a value as a parameter.
        It only checks the parameters item name, item revision, and acl number.

Examples:
          status = check_params(attr_name);

Return Status:
          1     -attribute is a parameter and has a value
          0     -either attribute isn't a parameter or it doesn't have a value.

History:
     09/03/91  wrw  -added standard header

******************************************************************************/
  
long check_params (a_name)
char *a_name;                /* I - attribute name to check for */
{
   if (flags.dbg)
      fprintf(dbgfile,"Checking if parameter: %s\n",a_name);
   if (!strcmp(a_name,P_ITEM_NAME) && strcmp(parameters.item_name,"\0"))
      return (1);

   if (!strcmp(a_name,P_ITEM_REV) && strcmp(parameters.item_rev,"\0"))
      return (1);

   if (!strcmp(a_name,P_ACL_NO) && (parameters.acl_no != -1))
     return (1);

   return(0);
} /* end check_params */


/******************************************************************************

Doc:    BLcheck_version

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function checks the version number found in the .blk file.
        If the version does not match the current version, it calls the 
           convert routine.
        The original file is not harmed on the conversion attempt.

Examples:
          BLcheck_version();

Return Status:
          1         -versions are incompatible and conversion attempt failed.
          0         -versions were okay or conversion was successful.

History:
     09/03/91  wrw  -added standard header

******************************************************************************/
  
long BLcheck_version()
{
char  work[MAX_ASCII_LINE_LEN];
char  fname[64];
long   status;
extern int getpid();

   if (fgets(work,MAX_ASCII_LINE_LEN,bulkload)==NULL)
      return(0);
   rewind(bulkload);

   if (!strncmp(work,VERSION,strlen(VERSION)))
      return(0);
   else {
      fname[0]=0;
      sprintf(fname,"/usr/tmp/NEW%d.blk",getpid());
      status = BLconvert_blk(bulkload,fname);
      if (status)
         return(1);
      fclose(bulkload);
      bulkload = fopen(fname,"r");
      if (!bulkload)
         return(1);
      return(0);
      }
} /* end BLcheck_version */


/******************************************************************************

Doc:    BLcheck_req

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function checks to make sure that all required attributes have
           values in the global structures.
        It writes its own messages to the results file and returns a status
           message that reflects its status.

Examples:
          status = BLcheck_req();

Return Status:
          DMD_W_ATTR_REQ    - some attribute was required but not found.
          DMD_S_SUCCESS     - all required attributes were found.

History:
     09/03/91  wrw  -added standard header
     02/02/92  wrw  -made this function obsolete

******************************************************************************/
  
long BLcheck_req()
{
/*
long i,x;
   if (flags.dbg)
      fprintf(dbgfile,"Entering BLcheck_req() \n");
   x = parameters.catalog_index;
   for (i=0;i<catalogs[x].num_of_attr;i++) {
      if (catalogs[x].attributes[i].req_code &&
                                    !catalogs[x].attributes[i].stored) {
         if (check_params(catalogs[x].attributes[i].name))
            continue;
         BLwrite_result(DMD_W_ATTR_REQ,catalogs[x].attributes[i].name);
         BLwrite_reload();
         return(DMD_W_ATTR_REQ);
         }
      if (flags.dbg && catalogs[x].attributes[i].req_code) 
         fprintf(dbgfile,"--attr: %s was required and found\n"
                        ,catalogs[x].attributes[i].name);
      }
*/
   return (DMD_S_SUCCESS);
} /* end BLcheck_req */


/******************************************************************************

Doc:    to_decimal

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Jeff Silvagii

Date:   10-JUNE-1991

Description:
        This function converts a number in any base to its decimal equivalent
           which it returns.

Examples:
          to_decimal(number_to_convert,
                     original_base);

Return Status:
          decimal        - it returns the original number converted to decimal.

History:
     09/03/91  wrw  -added standard header

******************************************************************************/
  
long to_decimal( in, base )
char *in;	/* I - Input number */
long base;	/* I - Base to convert from */
{
long x, num, sub, out;
char *ptr;
static char *xlate="0123456789abcdefghijklmnopqrstuvwxyz";

num = 1;
out = 0;

x = strlen( in );
while( x-- )
{
  ptr = strchr( xlate, in[x] );
  sub = ptr - xlate;
  out += (sub * num);
  num *= base;
}
return(out);
} /* end of to_decimal() */


/******************************************************************************

Doc:    valid_sa

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function validates the number supplied as a NFM storage area.
        It cashes the storage areas in 'sa_names' so as not to do unnecessary
           sqls.  The names will be used by other parts of the code too.

Examples:
          status = BLwrite_result(s_a_number);

Return Status:
          1    -storage area number is a valid NFM storage area.
          0    -storage area is not a valid NFM storage area or some other
                   catastophic error ocurred.

History:
     09/03/91  wrw  -added standard header

******************************************************************************/
  
long valid_sa (sa_no)
long sa_no;           /* I - number of the storage area to validate */
{
long    i;
char   sql_line[100], *error_m;
long   buff_size, max_rows;
char  *data_buff;
long   rows_cols, rows, cols, status;
long  *src;
short *size;
char  *data;

   if (sa_no<0)
      return(0);

   /* check if we have already queried NFM for this number */
   if (sa_no<max_sa) {
      if (strcmp(sa_names[sa_no],"\0"))
         return (1);
      }

   /* reallocate sa_names array if needed */
   if ((sa_no+1)>max_sa) {
      if (flags.dbg)
         fprintf(dbgfile,"Re-allocing sa_names sa_no=%d max_sa=%d.\n"
                        ,sa_no,max_sa);
      if (max_sa==0)
         sa_names = (char **) malloc((sa_no+1)*sizeof(char *));
      else
         sa_names = (char **) realloc(sa_names,(sa_no+1)*sizeof(char *));

      if (!sa_names)
         return(DMD_F_INTERN_ERR);

      for (i=max_sa; i<(sa_no+1); i++) {
         sa_names[i] = (char *) malloc(MAX_SA_LEN*sizeof(char));
         if (!sa_names[i])
            return(DMD_F_INTERN_ERR);
         sa_names[i][0]=0;
         }
      max_sa = sa_no+1;
      }

   if (flags.dbg)
      fprintf(dbgfile,"Querying for sa name for number %d.\n",sa_no);

   /* query NFM to get storage name for this number */
   sprintf(sql_line,"select n_saname from nfmstoragearea where n_sano =%d"
                   ,sa_no);
   data_buff = (char *) malloc(1024);
   if (!data_buff)
      return(DMD_F_INTERN_ERR);
   max_rows = 3;
   buff_size = 1024;
   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,&error_m);
   if (status != 0) {
      free(data_buff);
      BLwrite_result(DMD_F_BAD_SELECT,"");
      BLwrite_result(DMD_I_NFM_MESG,error_m);
      return(0);
      }

   /* parse the data buffer */
   src = (long *)data_buff;
   status = (*src++);
   rows_cols = (*src++);
   cols = (*src++);
   rows = rows_cols/cols;
   size = (short *)src;
   data = (char *)((long)size + ((rows_cols + cols) * sizeof(short)));

   if (status || rows == 0) {
      free(data_buff);
      return(0);
      }

   /* move data pointer past column names */
   for (i=1;i<=cols;i++) {
      data += (*size+1);
      size++;
      }

   if (flags.dbg)
      fprintf (dbgfile,"sa number = %d  sa name = %s \n",sa_no,data);

   /* load name for future reference */
   strcpy(sa_names[sa_no],data);

   free(data_buff);
   return(1);
} /* end valid_sa */


/******************************************************************************

Doc:    BLmail_results

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function mails a writes out and mails a message to the person
           who is executing this code.

Examples:
          BLmail_results();

Return Status:
          (none)

History:
     09/03/91  wrw  -added standard header
     09/20/94  wrw  -changed to work w/ SCO UNIX
                    -added support for using the mailpath in the database

******************************************************************************/
  
void BLmail_results()
{
FILE *mfp;
char  to[MAX_ASCII_LINE_LEN];
char *error_m;
char  msg[MAX_ASCII_LINE_LEN];

   mfp = fopen(MAIL_FILE,"w");
   if (!mfp) {
      if (flags.dbg)
         fprintf(dbgfile,"Could not open mail file %s\n",MAIL_FILE);
      return;
      }

   UMSGetByNum(msg,DMD_I_MAIL_INFO1,0);
   fprintf(mfp,"\n\n%s\n",msg);
   
   UMSGetByNum(msg,DMD_I_MAIL_INFO2,0);
   fprintf(mfp,"%s\n",msg);
   
   UMSGetByNum(msg,DMD_I_MAIL_INFO3,0);
   fprintf(mfp,"%s\n\n\n",msg);
   
   header_out(mfp);
   tail_out(mfp);

   fclose(mfp);

   sprintf(msg,"select n_emailaddr from nfmusers where n_username='%s'",user);
   single_select(msg,to,&error_m);
   if (!strchr(to,'@') && !strchr(to,'!')) {
      single_select("select n_nodename from nfmnodes, nfmstoragearea where n_sano=1 and nfmstoragearea.n_nodeno=nfmnodes.n_nodeno",msg,&error_m);
      sprintf(to,"%s@%s",user,msg);
      }

   sprintf(msg,"mailx %s <%s",to,MAIL_FILE);
   
   if (flags.dbg)
      fprintf(dbgfile,"Mail file written.  Executing:<%s>\n",msg);

   system(msg);
   
   return;
} /* end BLmail_results */


/******************************************************************************

Doc:    check_time

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991
  
Description:
        This function maintains all the timing averages that are used if the
           timer flag is turned on.  It writes these timing statistics to the
           debug and timer files.
        It used to do the logging in and out of NFM if performance degraded
           with virtual size growth.  NFM fixed this problem, and while the
           code and algorithms are still there, it has been commented out.

Examples:
          check_time();

Return Status:
          (none)

History:
     09/03/91  wrw  -added standard header

******************************************************************************/

void check_time (op,elapse)
struct time_type *op;           /* I/O - pointer to the timing structure for
                                         the current operation */
float             elapse;       /* I - amount of time that has elapsed. */
{
long i;

   op->count++;

   for (i=0;i<4;i++)
      op->times[i] = op->times[i+1];

   if (op->times[4])
      op->times[4] = ((elapse>(1.1*op->times[4]))?(1.1*op->times[4]):elapse);
   else
      op->times[4] = elapse;

   op->curr_avg = (op->times[0] + op->times[1] + op->times[2] + op->times[3]
                  + op->times[4]) / 5.0;

   if (flags.dbg)
      fprintf(dbgfile
             ," elapse time %5.2fs lowest avg %5.2fs current avg %5.2fs \n"
             ,elapse,op->low_avg,op->curr_avg);
   if (flags.timer)
      fprintf(timerfile
             ," elapse time %5.2fs lowest avg %5.2fs current avg %5.2fs \n"
             ,elapse,op->low_avg,op->curr_avg);

   if (op->count < 5)
      return;

   if (op->curr_avg < op->low_avg) {
      op->low_avg = op->curr_avg;
      return;
      }
  
/* disabling logout due to NFM's server fix
   if (op->curr_avg > (op->low_avg * 1.5)) {
      if (flags.dbg)
         fprintf(dbgfile,"Logging out due to large server size\n");
      if (flags.timer)
         fprintf(timerfile,"Logging out due to large server size\n");
      status = NFM2_logout();
      if (flags.dbg)
         fprintf(dbgfile,"Logout was successful...sleeping 30\n");
      if (flags.dbg)
         fprintf(timerfile,"Logout was successful...sleeping 30\n");
      sleep(30);
      if (flags.dbg) {
         fprintf(dbgfile,"Logging back in after log out due to big NFM\n");
         fprintf(dbgfile,"server <%s> envir <%s> user <%s> pw <%s>\n"
                        ,server,n_environ,user,password);
         }
      if (flags.timer) {
         fprintf(timerfile,"Logging back in after log out due to big NFM\n");
         fprintf(timerfile,"server <%s> envir <%s> user <%s> pw <%s>\n"
                        ,server,n_environ,user,password);
         }
      status = NFMa_login(server,n_environ,user,password,flags.dbg,1991);
      if (status <= 0) {
         BLwrite_result(DMD_F_BAD_LOGIN,"");
         if (flags.dbg)
            fprintf (dbgfile,"login failed-status = %d\n",status);
         if (flags.timer)
            fprintf (timerfile,"login failed-status = %d\n",status);
         }
      else
         if (flags.dbg)
            fprintf (dbgfile,"login was successful.\n");
         if (flags.timer)
            fprintf (timerfile,"login was successful.\n");
      op->count = 0;
      op->low_avg = 1000.0;
      op->curr_avg = 0.0;
      for (i=0;i<5;i++)
         op->times[i] = 0.0;
      }
*/

   return;
} /* end check_time */


/******************************************************************************

Doc:    has_char

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991
  
Description:
        This function determins if a string as something other than numbers.
          

Examples:
          has_char();

Return Status:
          0  - string contains only numbers
          1  - string has something other than numbres.

History:
  10.23.92  wrw  -changed to isdigit
******************************************************************************/

int has_char (str)
   char *str;     /* I - srtring to look at */
{
int i;

	for (i=0;i<strlen(str);i++)
		if (!isdigit(str[i])) return (1);
	return(0);

/*
char *look;
   for (look=str; *look!='\0'; look++)
      if (*look=='0'||*look=='1'||*look=='2'||*look=='3'||*look=='4'==
          *look=='5'||*look=='6'||*look=='7'||*look=='8'||*look=='9')
         continue;
      else
         return(1);
   return(0);
*/
} /* end has_char */


/******************************************************************************

Doc:    NFMa_write_result

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   10-JUNE-1991
  
Description:
        This function writes out the errors given by NFM to the results file.
        It has no return codes.

Examples:
          NFMa_write_result();

Return Status:
          (none)

History:
     09/03/91  wrw  -added standard header
     09/23/91  wrw  -moved from NFMa_stuff.c to make that module non-dependent
                     on BL structures.

******************************************************************************/

void NFMa_write_result()
{
long    loop;
char    errmsg[MAX_ASCII_LINE_LEN];

   for (loop = 0; loop < NFM_Messages; loop++) {
      UMSGetByNum(errmsg,DMD_I_NFM_MESG,0);
      fprintf (results,"%s %s\n",errmsg,NFM_Error_Messages[loop]);
      }
}


/******************************************************************************

Doc:    BL_ticked

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   May 19, 1992

Description:
        Returns a character pointer to a string that is a duplicate of the
          string you passed in.
        The catch is that all ticks (') are doubled so that ris statements
          work ok.
        Can have up to 5 different simultaineous strings.


Examples:
          new_string = BL_ticked(string)

Return Status:
        char *    -to the new string

History:

******************************************************************************/

char *BL_ticked(string)
   char *string;
{
static char *new[5];
static long  size[5]={0,0,0,0,0};
static long  seq=0;
long i,j;

   seq++; if (seq>=5) seq=0;

   if ((2*(strlen(string)+1))>size[seq]) {
      if (size[seq])
         new[seq]=(char *)realloc(new[seq],(size[seq]=2*(strlen(string)+1)*sizeof(char)));
      else
         new[seq]=(char *)malloc((size[seq]=2*(strlen(string)+1)*sizeof(char)));
      }
   for (j=i=0;i<strlen(string);i++,j++) {
      new[seq][j]=string[i];
      if (string[i]=='\'') new[seq][++j]='\'';
      }
   new[seq][j]=0;
   return(new[seq]);
}


/******************************************************************************

Doc:    BL_catalog_no

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   June 14, 1992

Description:
		returns the catalog number for the given catalog.

Examples:
		n_catalogno=BL_catalog_no()

Return Status:
		-1			catalog not founc
		n_catalogno

History:

******************************************************************************/
long BL_catalog_no(catalog)
	char *catalog; /* I -catalog to return number of */
{
static char cats[5][64]={"","","","",""};
static long nums[5]={-1,-1,-1,-1,-1};
static long wght[5]={0,0,0,0,0};
char sql[132];
long status;
char *error_m;
char tmp[8];
long i,min,idx;

   /* check local cash */
   for (i=0;i<5&&cats[i][0];i++)
      if (!strcmp(catalog,cats[i])) {
         wght[i]++;
         return(nums[i]);
         }

   /* not found, must generate */
   sprintf(sql,"select n_catalogno from nfmcatalogs where n_catalogname='%s'"
          ,catalog);
   status=single_select(sql,tmp,&error_m);
   if (!tmp[0]) strcpy(tmp,"-1");

   /* found in db, store in local cache */
   min=wght[idx=0];
   for (i=0;i<5;i++)
      if (wght[i]<min) min=wght[idx=i];

   nums[idx]=atol(tmp);
   wght[idx]=1;
   strcpy(cats[idx],catalog);

   return(nums[idx]);
}


/******************************************************************************

Doc:    BL_write_capture_indexing_info

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   June 14, 1992

Description:
		Writes out the current n_catalogno, n_itemno, n_fileno

Examples:
		BL_write_capture_indexing_info()

Return Status:
		none

History:

******************************************************************************/
void BL_write_capture_indexing_info()
{
char sql_line[512];
char tmp[8];
char *error_m;
int x;

   sprintf(tmp,"%d",BL_catalog_no(parameters.catalog_name));
   BLwrite_sts(DMD_I_STS_CAT_NO,tmp);

   sprintf(sql_line,"select n_itemno,n_fileno from %s,f_%s where n_itemname='%s' and n_itemrev='%s' and n_itemno=n_itemnum and n_fileversion=(select max(n_fileversion) from f_%s where n_itemnum=n_itemno)"
			,parameters.catalog_name,parameters.catalog_name,parameters.item_name
         ,parameters.item_rev,parameters.catalog_name);

   NFMa_multi_select(sql_line,2048,NULL,"n_itemno",1,tmp,&error_m);
   BLwrite_sts(DMD_I_STS_ITEM_NO,tmp);

   NFMa_multi_select(NULL,2048,NULL,"n_fileno",x=1,tmp,&error_m);
   do {
      BLwrite_sts(DMD_I_STS_FILE_NO,tmp);
		NFMa_multi_select(NULL,2048,NULL,"n_fileno",++x,tmp,&error_m);
		} while (tmp[0]);
}


/******************************************************************************

Doc:    is_char

        Copyright (c) 1991
        Intergraph Corporation; All Rights Reserved
        Including Application Programs, File Formats, and Visual Displays

Source: BLutilities.c

Author: Rob Whitesell

Date:   November 20, 1992

Description:
		determines if an attribute is a character.  uses a cash for speed.

Examples:
		if (is_char(catalog,attribute)) ...

Return Status:
		0 -if not a char
		1 -if a char

History:

******************************************************************************/
#define C_SLOTS   20
long is_char(cat,attr)
	char *cat;
	char *attr;
{
struct c_type {
	char *cat;
	char *attr;
	long is_char;
	};
static struct c_type c[C_SLOTS];
static long free_c=(-1);

long i;
char *em;
char work[256];
char val[32];

	if (!cat || !attr || !cat[0] || !attr[0]) return(1);

	if (free_c<0) {
		for (i=0;i<C_SLOTS;i++) {
			c[i].cat=(char*)NULL;
			c[i].attr=(char*)NULL;
			c[i].is_char=1;
			}
		free_c=0;
		}

	for (i=1;i<C_SLOTS;i++) {
		if (!c[i].cat || !c[i].attr) break;
		if (!strcmp(c[i].cat,cat) && !strcmp(c[i].attr,attr))
			return(c[i].is_char);
		}

sprintf(work
	,"select ris_type from riscolumns where table_name='%s' and column_name='%s'"
	,cat,attr);

	if (NFMa_single_select(work,val,&em)) 
		sprintf(val,"%d",1);

	free(c[free_c].cat);
	free(c[free_c].attr);

	c[free_c].cat=strdup(cat);
	c[free_c].attr=strdup(attr);
	i=c[free_c].is_char=(atol(val)==1)?1:0;

	if (++free_c>=C_SLOTS) free_c=0;

	return(i);
}
