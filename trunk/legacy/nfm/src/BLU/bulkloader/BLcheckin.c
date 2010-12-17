#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "WFcommands.h"
#include "UMS.h"
#include "BLums.h"
#include "BLtypes.h"
#include "BLdefs.h"
#include "BLvars.h"

extern char *BL_ticked();

/* Global variables (used in this module only) */
char   **co_files;
char   **ci_files;
char   **ci_sas;
char   **file_types;
char   **co_comms;
long     co_sa;


/* functions in this .c */
long write_detail();
long find_params();
void free_params();
long upd_redlines();
long BLcheck_in();


/******************************************************************************

Doc:    BLcheck_in

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcheckin.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This module controls the performing of the NFM check in operation.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.
  
        Algorithm:
             1) verify the existence of good data.
             2) check for redline and reduced resolution files
                  a) perform specifics needed fo them
             2) call NFM routine to do the check in.
             3) if DMANDS mode
                  a) verify existence of detail catalog
                  b) make entries for files
             3) evaluate and report on status.

Examples:
          status = BLcheck_in();

Return Status:
          DMD_F_INTERN_ERR      - bad malloc
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_W_CREATE_FAIL     - creation of the D_ table failed.
          DMD_S_SUCCESS 	- Success
          any error status returned by find_params() on failure
          any error status returned by NFMa_checkin_mult_item() on failure

History:
     09/03/91  wrw  -added standard header and converted externs to .h
     09/10/91  wrw  -added code to copy the file if it will be mirror archived.
                    -added code to cancel out the copy if checkin failed.
     10/11/91  wrw  -changed so that red. res files are not copied for ma.
                    -changed so that red. res files are not caneled if failed.
     02/02/92  wrw  -changed to use the new data structures.
     08/03/92  wrw  -changed mirror archive to not use mcm (removed code)
     08/18/92  wrw  -straighted out some problems with built in ftr.

******************************************************************************/
  

long BLcheck_in ()
{
long   status;
long   num_files;
long   fl,i;
char  detail_cat[MAX_CAT_NAME_LEN];
char *tmp,*error_m;

   if (flags.dbg)
      fprintf(dbgfile,"Entered BLcheck_in().\n");

   BLwrite_result(DMD_I_TRY_CHECKIN,"");
   if ((fl=parameters.co_file_index) >= 0) {
      for (i=0;i<attributes[parameters.co_file_index].stored;i++) {
         tmp = attributes[parameters.co_file_index].data[i];
         if (   !strncmp(tmp,RR_INDIC,1) 
             || !strncmp(tmp,RL_INDIC,1)
             || !strncmp(tmp,FTR_INDIC,1))
            tmp++;
         BLwrite_result(DMD_I_CO_FILES,tmp);
         }
      }
   else
      BLwrite_result(DMD_I_CO_FILES,"");

   /* increment operation counter */
   T_count.checkins_found++;

   /* check catalog type */
   if (parameters.catalog_type==RIS_CAT) {
      BLwrite_result(DMD_W_NOT_RIS_OP,OP_CHECKIN);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because not right type of catalog.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* make sure that the required info is found */
   /* check for item name */
   if (!strcmp(parameters.item_name,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_CHECKIN);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_NAME);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcheck_in() because no item name.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   /* check for revision */
   if (!strcmp(parameters.item_rev,"/0")) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_CHECKIN);
      BLwrite_result(DMD_W_MISSING_PARAM,P_ITEM_REV);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcheck_in() because no item rev.\n");
      return(DMD_W_SYNTAX_ERR);
      }

   /* get parameters: storage area name, file names, comments, file types */
   status = find_params(&num_files);
   if (status != DMD_S_SUCCESS) {
      return (status);
      }

   if (flags.dbg)
      fprintf(dbgfile,"Entering NFMa_checkin_mult_item \n");

   status = NFMa_checkin_mult_item(parameters.catalog_name,parameters.item_name
                         ,parameters.item_rev,sa_names[co_sa],"","","",""
                         ,num_files,co_files,ci_files,ci_sas,file_types
                         ,co_comms,CHECKIN_ITEM);
   if (flags.dbg)
      fprintf(dbgfile,"Exit from NFMa_checkin_mult_item ->status = %x\n"
                     ,status);

   if (status) {
      BLwrite_result(DMD_W_OP_FAILED,OP_CHECKIN);
      if (status == 9999)
         BLwrite_result(DMD_W_LESS_FILES,"");
      else 
         NFMa_write_result();
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcheck_in() bad checkin status.\n");

      free_params();
      return(status);
      }
 
   flags.checkin = 0;
   T_count.checkins_performed++;
   BLwrite_result(DMD_S_OP_SUCCESS,OP_CHECKIN);

   /* Exit if NFM only mode */
   if (flags.nfm_mode) {
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcheck_in() normally.\n");
      free_params();
      return(DMD_S_SUCCESS);
      }

   /* Must be DMANDS mode, make entry in d_<cat_name> */
   BLwrite_result(DMD_I_TRY_DMANDS,"");
   sprintf(detail_cat,"d_%s\0",parameters.catalog_name);
   if (flags.dbg) 
      fprintf(dbgfile,"Checking for detail catalog <%s>\n",detail_cat);
   if (!BLvalid_cat(detail_cat,RIS_CAT)) {
      if (flags.dbg) 
         fprintf(dbgfile,"detail catalog not found, creating....\n");
      if ((status=NFMa_create_d_(detail_cat,&error_m)) != 0) {
         BLwrite_result(DMD_W_CREATE_FAIL,detail_cat);
         BLwrite_result(DMD_W_RIS_ERROR,error_m);
         free_params();
         return(DMD_W_CREATE_FAIL);
         }
      }
   if (flags.dbg) 
      fprintf(dbgfile,"detail catalog is in existence at this time.\n");

   /* write the d_ table and perform mirror archive */
   if ((status=write_detail(detail_cat)) != DMD_S_SUCCESS) {
      free_params();
      return(status);
      }
   
   if (flags.dbg)
      fprintf(dbgfile,"Exiting BLcheck_in() normally.\n");
   free_params();
   return(DMD_S_SUCCESS);
} /* end BLcheck_in */


/******************************************************************************

Doc:    check_red_line

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcheckin.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function is supposed to check redlines into the _rl catalog.
        It is currently disabled at the point of call, and does not work.

Examples:
          check_red_line(file_no);

Return Status:
          (none)

History:
     09/03/91  wrw  -added standard header

******************************************************************************/

/*ARGSUSED*/
void check_red_line (file_no) 
long file_no;                       /* I - file number of redline in catalog
                                             structure */
{
/*  disabled
long    fl,i,x,len;
long    item_no, fl_no, co_sa, page_no, layer_no;
long    status;
char   sql_line[1024], *error_m;
long   buff_size, max_rows;
char   data_buff[1024];
long   rows_cols, rows, cols;
long  *src;
short *size;
char  *data;
char   layer[5];
char   cat_name[MAX_CAT_NAME_LEN],item_name[25];

   if (flags.dbg) 
      fprintf(dbgfile,"Entering check_red_line()\n");

   x=parameters.catalog_index;
   fl=parameters.co_file_index;
   len = catalogs[x].attributes[fl].length;
   for (i=file_no;i>=0;i--) 
      if (!strncmp(RR_INDIC,&catalogs[x].attributes[fl].data[i*len],1))
         continue;
      else
         break;

   if (i < 0) {
      BLwrite_result(DMD_W_NO_DETAIL
                    ,&catalogs[x].attributes[fl].data[file_no*len]);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting cause no detail found\n");
      return;
      }

*/
   /* find stuff to determine item name */
/* disabled
   sprintf(sql_line 
          ,"select %s, %s from %s,f_%s where %s='%s' and %s=%s and %s='%s'" 
          ,P_ITEM_NO,P_FILE_NO,parameters.catalog_name,parameters.catalog_name 
          ,P_ITEM_NAME,BL_ticked(parameters.item_name),P_ITEM_NO,P_ITEM_NUM
          ,P_ITEM_REV,BL_ticked(parameters.item_rev));
   if (flags.dbg)
      fprintf(dbgfile,"RIS SQL:<%S>\n",sql_line);

   max_rows = 100;
   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,&error_m);

   if (status) {
      if (flags.dbg)
         fprintf(dbgfile,"status =%d, error <%s>\n",status,error_m);
      BLwrite_result(DMD_W_BAD_DETAIL
                    ,&catalogs[x].attributes[fl].data[file_no*len]);
      return;
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
         BLwrite_result(DMD_W_BAD_DETAIL
                       ,&catalogs[x].attributes[fl].data[file_no*len]);
         return;
         }
      else {
*/
         /* move data pointer past column names */
/* disabled
         for (i=1;i<=cols;i++) { 
      if (flags.dbg)
         fprintf(dbgfile,"past cols; data:<%s>\n",data);
            data += (*size+1); 
            size++; 
            }
         item_no=atoi(data);
         if (flags.dbg)
            fprintf(dbgfile,"item_no = %d data=%s\n",item_no,data);
         data += (*size +1);
         size++;
         fl_no=atoi(data);
         if (flags.dbg)
            fprintf(dbgfile,"fl_no = %d data=%s\n",fl_no,data);
         }
      }

   sprintf(sql_line,"select count(*) from %s_rl where %s like '%.6d|%.7d'"
          ,parameters.catalog_name,P_ITEM_NAME,item_no,fl_no);
   if (flags.dbg)
      fprintf(dbgfile,"RIS SQL:<%S>\n",sql_line);

   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,&error_m);

   if (status) {
      if (flags.dbg)
         fprintf(dbgfile,"status =%d, error <%s>\n",status,error_m);
      BLwrite_result(DMD_W_BAD_DETAIL
                    ,&catalogs[x].attributes[fl].data[file_no*len]);
      return;
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
         BLwrite_result(DMD_W_BAD_DETAIL
                       ,&catalogs[x].attributes[fl].data[file_no*len]);
         return;
         }
      else {
*/
         /* move data pointer past column names */
/* disabled
         for (i=1;i<=cols;i++) { 
      if (flags.dbg)
         fprintf(dbgfile,"past cols; data:<%s>\n",data);
            data += (*size+1); 
            size++; 
            }
         layer_no=atoi(data);
         if (flags.dbg)
            fprintf(dbgfile,"layer_no = %d data=%s\n",layer_no,data);
         }
      }

   co_sa = atoi(catalogs[x].attributes[parameters.cosa_index].data);
   if (!(status=valid_sa(co_sa))) {
      BLwrite_result(DMD_W_BAD_INFO,P_CO_SA);
      BLwrite_result(DMD_W_BAD_VALUE
                    ,catalogs[x].attributes[parameters.cosa_index].data);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because bad co_sa.\n");
      return;
      }
   if (status != 1) {
         BLwrite_result(DMD_F_INTERN_ERR,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting because bad malloc. \n");
      return;
      }

   layer[0]=catalogs[x].attributes[fl].data[(file_no*len)+5];
   layer[1]=catalogs[x].attributes[fl].data[(file_no*len)+6];
   layer[2]=catalogs[x].attributes[fl].data[(file_no*len)+7];
   layer[3]='\0';
   layer_no = (to_decimal(layer,36)/256) + 1;

*/
   /* page_no = ? */
/* disabled
   page_no = 0;
*/

   /* fix up checkin parameters */
/* disabled
   sprintf(cat_name,"%s_rl",parameters.catalog_name);
   sprintf(item_name,"%.06d|%.07d|%.03d%.03d",item_no,fl_no,page_no,layer_no);
   if (flags.dbg)
      fprintf(dbgfile,"RL checkin: cat=<%s> item=<%s> rev=<%s> \n",cat_name
                     ,item_name,parameters.item_rev);
   
   status = NFM2_checkin_item(cat_name,item_name,parameters.item_rev
                             ,sa_names[co_sa],"","","",""
                             ,&catalogs[x].attributes[fl].data[file_no*len]
                             ,CHECKIN_ITEM);
   if (!status)
      BLwrite_result (DMD_S_OP_SUCCESS,OP_RL_CHECKIN);
   else {
      BLwrite_result (DMD_W_OP_FAILED,OP_RL_CHECKIN);
      NFMa_write_result();
      }
  
*/
   return;
} /* end check_red_line() */


long RLC_base_cvt( in, out, base, digits )
long in;	/* I - decimal number */
char *out;	/* O - Output base number */
long base;	/* I - Base to convert to */
long digits;	/* I - Number of digits to generate */
{
int x;
int powers[10];
static char *xlate="0123456789abcdefghijklmnopqrstuvwxyz";

powers[0] = 1;
for( x = 1; x < digits; x++ ) powers[x] = powers[x-1] * base;

while( digits-- )
{
  x = in / powers[ digits ];
  *(out++) = xlate[ x ];
  in = in - ( x * powers[ digits ] );
}

*out = 0;
return(0);
} /* end of RLC_base_cvt() */


/******************************************************************************

Doc:    upd_redlines

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcheckin.c

Author: Rob Whitesell

Date:   12-JULY-1991

Description:
        This function checks a give item_no for multiple versions.  If there
           are multiple versions, it checks to see if the previous version 
           had redlines on its files.  If the n_cofilename of the old file with
           redlines match the new co_filename, the redlines are transfered to
           the new version.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.
  
Examples:
          status = upd_redlines(item_no);

Return Status:
          DMD_F_INTERN_ERR      - bad information given
          DMD_F_BAD_SELECT      - select statement failed.
          DMD_S_SUCCESS 	- Success
          any error status returned by NFMa_update_item() on failure

History:
     09/03/91  wrw  -added standard header

******************************************************************************/

long upd_redlines(item_no)
long item_no;                  /* I - item number to check redlines of */
{
long hold_old,hold_new,hold_cat;
char oldred[16],redfile[16];
long  file_ver,redlines,file_no;
char  sql_line[1000];
char *error_m;
char  red_file[25],tmp[50],attr_name[20],cat_name[MAX_CAT_NAME_LEN];
char **old_red,new_red[25];
char **old_rev;
char  *tmp1[2],*tmp2[2];
long   buff_size, max_rows;
char   *data_buff;
long    status,i,j;
long   rows_cols, rows, cols;
long  *src;
short *size;
char  *data;

   if (flags.dbg)
      fprintf(dbgfile,"entered upd_redlines(%d)\n",item_no);

   sprintf(sql_line,"select max(%s) from f_%s where %s=%d",P_FILE_VER
                   ,parameters.catalog_name,P_ITEM_NUM,item_no);
   status = single_select(sql_line,tmp,&error_m);
   if (status != DMD_S_SUCCESS) {
      BLwrite_result(DMD_F_BAD_SELECT,"");
      BLwrite_result(DMD_W_RIS_ERROR,error_m);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting upd_redlines() cause bad select.\n");
      return(DMD_F_BAD_SELECT);
      }
   file_ver = atoi(tmp);
   
   /* check if multiple versions exist */
   if (file_ver <= 1) {
      if (flags.dbg)
         fprintf(dbgfile,"exit upd_redlines, fileversion <%d>.\n",file_ver);
      return(DMD_S_SUCCESS);
		}

   /* redlines have item name: IIIIII|FFFFFFF|PPPLLL               */
   /*    I - item no;  F - file no;  P - page no;  L - layer no    */

   sprintf(sql_line
          ,"select count(*) from %s_rl where %s like '%.6d|%%'"
          ,parameters.catalog_name,P_ITEM_NAME,item_no);
   status = single_select(sql_line,tmp,&error_m);
   if (status != DMD_S_SUCCESS) {
      BLwrite_result(DMD_F_BAD_SELECT,"");
      BLwrite_result(DMD_W_RIS_ERROR,error_m);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting upd_redlines() cause bad select.\n");
      return(DMD_F_BAD_SELECT);
      }
   redlines = atoi(tmp);

   /* check if any redlines exist */
   if (redlines <= 0) {
      if (flags.dbg)
         fprintf(dbgfile,"exit upd_redlines(), no redlines found.\n");
      return(DMD_S_SUCCESS);
		}

   /* check if redlines exist - fetch item names for them */
   if (flags.dbg)
      fprintf(dbgfile,"check if redlines exist - fetching their item names \n");

   buff_size = 2048 + (25 * redlines);
   data_buff = (char *) malloc (buff_size*sizeof(char));
   if (!data_buff) {
      BLwrite_result(DMD_F_INTERN_ERR,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting upd_redlines() because bad malloc. \n");
      return(DMD_F_INTERN_ERR);
      }
   max_rows = redlines +10;
   sprintf(sql_line
          ,"select %s, n_itemrev from %s_rl where %s like '%.6d|%%'"
          ,P_ITEM_NAME,parameters.catalog_name,P_ITEM_NAME,item_no);
   status = SS_sql(data_buff,sql_line,&buff_size,max_rows,&error_m);
   if (status) {
      BLwrite_result(DMD_F_BAD_SELECT,"");
      BLwrite_result(DMD_W_RIS_ERROR,error_m);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting upd_redlines() cause bad select.\n");
      free(data_buff);
      return(DMD_F_BAD_SELECT);
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
         free(data_buff);
         return(DMD_S_SUCCESS);
         }
      else {
         /* allocate space for the redline names */
         old_red = (char **) malloc(redlines*sizeof(char *));
         old_rev = (char **) malloc(redlines*sizeof(char *));
         if (!old_red || !old_rev) {
            BLwrite_result(DMD_F_INTERN_ERR,"");
            if (flags.dbg)
               fprintf(dbgfile,"Exiting upd_redlines() because bad malloc. \n");
            free(data_buff);
            return(DMD_F_INTERN_ERR);
            }
         for (i=0;i<redlines;i++) {
            old_red[i] = (char *) malloc(25*sizeof(char));
            old_rev[i] = (char *) malloc(128*sizeof(char));
            if (!old_red[i] || !old_rev[i]) {
               BLwrite_result(DMD_F_INTERN_ERR,"");
               if (flags.dbg)
                  fprintf(dbgfile,"Exit upd_redlines() because bad malloc.\n");
               free(data_buff);
               return(DMD_F_INTERN_ERR);
               }
            }

         /* move data pointer past column names */
         for (i=1;i<=cols;i++) {
            data += (*size+1);
            size++;
            }
         /* FINALLY! load names in name array */
         for (i=0;i<rows_cols;i++) {
            if (i>=redlines) {
               if (flags.dbg)
                  fprintf(dbgfile,"More item_names returned than counted.\n");
               break;
               }
            strcpy(old_red[i],data);
            if (flags.dbg)
               fprintf(dbgfile,"Redline %d = <%s>\n",i,data);
            data += (*size+1);
            size++;

            strcpy(old_rev[i],data);
            if (flags.dbg)
               fprintf(dbgfile,"Redline rev %d = <%s>\n",i,data);
            data += (*size+1);
            size++;
            }
         if (rows_cols<redlines) {
            if (flags.dbg)
               fprintf(dbgfile,"Less item_names returned than counted.\n");
            for (i=rows_cols;i<redlines;i++) {
               free(old_red[i]); free(old_rev[i]);
					}
            redlines = rows_cols;
            }
         }
      }

   free(data_buff);

   /* process the list of redlines -fix as we go. */
   if (flags.dbg)
      fprintf(dbgfile,"Trying to convert %d redlines.\n",redlines);
   strcpy(attr_name,P_ITEM_NAME);
   sprintf(cat_name,"%s_rl",parameters.catalog_name);
   for (i=0; i<redlines; i++) {
      if (flags.dbg)
         fprintf(dbgfile,"Working on redline <%s> rev <%s>.\n"
                        ,old_red[i],old_rev[i]);
      strncpy(tmp,&old_red[i][7],7);
      tmp[7]=0;
      if (flags.dbg)
         fprintf(dbgfile,"--old file_no <%s>.\n",tmp);
      hold_old=file_no = atoi(tmp);
 
      /* find the file name -used for future selects and diagnostics */
      sprintf(sql_line,"select %s from f_%s where %s=%d and %s=%d and %s=%d"
                      ,P_CO_FILE,parameters.catalog_name,P_ITEM_NUM,item_no
                      ,P_FILE_VER,(file_ver-1),P_FILE_NO,file_no);
      status = single_select(sql_line,red_file,&error_m);
      if (status != DMD_S_SUCCESS) {
         BLwrite_result(DMD_F_BAD_SELECT,"");
         BLwrite_result(DMD_W_RIS_ERROR,error_m);
         if (flags.dbg)
            fprintf(dbgfile,"Exiting upd_redlines() cause bad select.\n");
         status = DMD_F_BAD_SELECT;
         break;
         }

      /* find the new file number */
      sprintf(sql_line
             ,"select %s from f_%s where %s=%d and %s=%d and %s='%s'"
             ,P_FILE_NO,parameters.catalog_name,P_ITEM_NUM,item_no,P_FILE_VER
             ,file_ver,P_CO_FILE,BL_ticked(red_file));
      if (flags.dbg)
         fprintf(dbgfile,"--new fileno select: <%s>\n",sql_line);
      status = single_select(sql_line,tmp,&error_m);
      if (status != DMD_S_SUCCESS) {
         BLwrite_result(DMD_F_BAD_SELECT,"");
         BLwrite_result(DMD_W_RIS_ERROR,error_m);
         if (flags.dbg)
            fprintf(dbgfile,"Exiting upd_redlines() cause bad select.\n");
         status = DMD_F_BAD_SELECT;
         break;
         }
      /* check if the file was found. */
      if (!tmp[0]) {
         if (flags.dbg)
            fprintf(dbgfile,"redline <%s> could not be reassociated.\n"
                           ,old_red[i]);
         if (flags.dbg)
            fprintf(dbgfile,"--lost redline belonged to old file <%s>\n",tmp);
         BLwrite_result(DMD_W_LOST_RED,red_file);
         continue;
         }
      
      /* find new file number and create new redline item name */
      hold_new=file_no = atoi(tmp);
      tmp[0]=0;
      sprintf(tmp,"%.7d",file_no);
      strcpy(new_red,old_red[i]);
      for (j=0;j<7;j++)
         new_red[j+7]=tmp[j];
      if (flags.dbg)
         fprintf(dbgfile,"old item_name = <%s>  new item_name = <%s>\n"
                        ,old_red[i],new_red);
   
      /* do nfm update */
      if (flags.dbg)
         fprintf(dbgfile,"Calling NFMa_update_item\n");
      tmp1[0]=attr_name; tmp2[0]=new_red;
      sprintf(tmp,"%d",file_no);
      tmp1[1]="n_detfileno";tmp2[1]=tmp;
      status = NFMa_update_item(cat_name,old_red[i],old_rev[i]
                                ,tmp1,tmp2,2,1);
      if (status) {
         NFMa_write_result();
         }
      else {
			/* the following code was added to handle redlines generated by
            XDMANDS.  File names must also change. */
			if (!strcmp(&new_red[15],"000000")) {
				sprintf(sql_line,"select n_catalogno from nfmcatalogs where n_catalogname='%s'",parameters.catalog_name);
				status=single_select(sql_line,tmp,&error_m);
				hold_cat=atol(tmp);
				RLC_base_cvt(hold_old,oldred,(long)36,(long)5);
				RLC_base_cvt(hold_cat,tmp,(long)36,(long)5);
				strcat(oldred,tmp); strcat(oldred,".dat");
				RLC_base_cvt(hold_new,redfile,(long)36,(long)5);
				strcat(redfile,tmp); strcat(redfile,".dat");
      		if (flags.dbg)
         		fprintf(dbgfile,"changing file name from <%s> to <%s>.\n"
								,oldred,redfile);
				status=NFMa_change_file_entry(cat_name,new_red,parameters.item_rev
														,oldred,redfile,redfile,(char*)NULL
														,(char*)NULL,(char*)NULL);
      		if (!status) {
					RLC_base_cvt(hold_old,oldred,(long)36,(long)5);
					RLC_base_cvt(hold_cat,tmp,(long)36,(long)5);
					strcat(oldred,tmp); strcat(oldred,".idx");
					RLC_base_cvt(hold_new,redfile,(long)36,(long)5);
					strcat(redfile,tmp); strcat(redfile,".idx");
      			if (flags.dbg)
         			fprintf(dbgfile,"changing file name from <%s> to <%s>.\n"
									,oldred,redfile);
					status=NFMa_change_file_entry(cat_name,new_red
												,parameters.item_rev,oldred,redfile,redfile
												,(char*)NULL,(char*)NULL,(char*)NULL);
					}
				}
      	if (status) {
				NFMa_write_result();
				}
			else {
				status = DMD_S_SUCCESS;
				BLwrite_result(DMD_W_FOUND_RED,red_file);
				}
			}
      }

   for (i=0;i<redlines;i++) {
      free(old_red[i]);
      free(old_rev[i]);
      }
   free(old_red);
   free(old_rev);
   if (flags.dbg)
      fprintf(dbgfile,"exit upd_redlines(), redlines updated found.\n");
   return(status);
} /* end upd_redlines() */


/******************************************************************************

Doc:    write_detail

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcheckin.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        It writes info to DMANDS detail catalog
        It makes call to update the redline catalog if it is needed.
        It would also handle any redlines that must be checked in if that
           code were not disabled.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.

Examples:
          status = write_detail(detail_catalog);

Return Status:
          DMD_F_BAD_SELECT      - RIS select failed.
          DMD_F_BAD_INSERT      - RIS insert statement failed.
          DMD_S_SUCCESS 	- Success
          any error status returned by upd_redlines() on failure

History:
     07/12/91  wrw  -added support for re-associating of redlines
     09/03/91  wrw  -added standard header
     09/10/91  wrw  -replaced stub for mirror_archive with code to perform it.
     02/02/92  wrw  -fixed to work with new structs
     08/03/92  wrw  -changed mirror archiving to not use mcm.
     08/18/92  wrw  -straighted out some problems with built in ftr.

******************************************************************************/

long write_detail (detail_cat)
   char *detail_cat;          /* I - name of the detail catalog */
{
long   i;
long   fl,mpn,d,ma,ci=0;
long   rr_found;
long  item_no,ci_sano;
char  work[MAX_ASCII_LINE_LEN];
char *tmp;
char  rr_file[20];
char  def_desc[80];
long   def_mpn,def_re,def_ma;
char  sql_line[1024], *error_m;
long   buff_size, max_rows;
char   data_buff[1024];
long    status;

   if (flags.dbg) 
      fprintf(dbgfile,"Entering write_detail()\n");
   def_desc[0]=0;
   def_mpn = 1; def_re = 0; def_ma = 0;
   fl = mpn = d = ma = -1;
   for (i=0;i<num_of_attributes;i++) {
      if (!strcmp(attributes[i].name,P_CO_FILE)) {
         fl=i;
         continue;
         }
      if (!strcmp(attributes[i].name,D_MULT_PAGE)) {
         mpn=i;
         continue;
         }
      if (!strcmp(attributes[i].name,D_DESC)) {
         d=i;
         continue;
         }
      if (!strcmp(attributes[i].name,D_MIRROR)) {
         ma=i;
         continue;
         }
      if (!strcmp(attributes[i].name,"n_cisano")) {
         ci=i;
         continue;
         }
      }

   /* query for n_itemno...it makes later sql's faster */
   sprintf(sql_line,"select %s from %s where %s='%s' and %s='%s'"
                   ,P_ITEM_NO,parameters.catalog_name,P_ITEM_NAME
                   ,BL_ticked(parameters.item_name),P_ITEM_REV
                   ,BL_ticked(parameters.item_rev));
   status = single_select(sql_line,work,&error_m);
   if (status != DMD_S_SUCCESS) {
      BLwrite_result(DMD_F_BAD_SELECT,"");
      BLwrite_result(DMD_W_RIS_ERROR,error_m);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting write_detail() cause bad select.\n");
      return(DMD_F_BAD_SELECT);
      }
   item_no = atol(work);

   rr_found = 0; 
   /* make sure dmands required attributes are present */
   if (flags.dbg)
      fprintf(dbgfile,"num_of_files = %d\n",attributes[fl].stored);
   for (i=attributes[fl].stored-1;i>=0;i--) {
      tmp = attributes[fl].data[i];
      if (flags.dbg)
         fprintf(dbgfile,"Working on d_ for file <%s> i=%d\n",tmp,i);
 
      /* determine the file type */
      if (!strncmp(tmp,RL_INDIC,1)) {
         /* perform redline checkin */
         /*  disabled for time being.  NO REDLINES CHECKED IN     
         check_red_line(i);
         */
         BLwrite_result(DMD_I_NO_REDS,++tmp);
         continue;
         }
      else if (!strncmp(tmp,RR_INDIC,1)) {
         /* don't write d_, save file name, set flag */
         if (rr_found) 
            BLwrite_result(DMD_W_DUP_RR,rr_file);
         tmp++;
         strcpy(rr_file,tmp);
         rr_found=1;
         continue;
         }
      else {
         if (!strncmp(tmp,FTR_INDIC,1)) tmp++;
         max_rows = 10;
         buff_size=1024;

         /* file is a detail file */
         if (ma >= 0 && attributes[ma].data[i][0]) {
            def_ma=atoi(attributes[ma].data[i]);
            ci_sano=atoi(attributes[ci].data[i]);
            if (def_ma>0) 
               status = BLfull_mirror_archive(item_no,tmp,ci_sano,def_ma);
            /* status message was written by BLmirror_archive */
            /* ignore status and continue processing. */
            }
         if (mpn >= 0 && attributes[mpn].data[i][0]) {
            def_mpn=atoi(attributes[mpn].data[i]);
            }
         if (d >= 0 && attributes[d].data[i][0]) {
            strncpy(def_desc,attributes[d].data[i],80);
            }

         /* write horrendous sql_line */
         if (rr_found) {
            rr_found = 0;

            /* select the file number for the reduced resolution file */
            sprintf(sql_line,"select %s from f_%s where %s=%d and %s='%s' and %s=any (select max(%s) from f_%s where %s=%d and %s='%s')"
                 ,P_FILE_NO,parameters.catalog_name,P_ITEM_NUM,item_no
                 ,P_CO_FILE,BL_ticked(rr_file),P_FILE_VER,P_FILE_VER
                 ,parameters.catalog_name,P_ITEM_NUM,item_no,P_CO_FILE
                 ,BL_ticked(rr_file));
            if (flags.dbg)
               fprintf(dbgfile,"SQL for select rr #: <%s>\n",sql_line);
            status = single_select(sql_line,work,&error_m);

            if (status != DMD_S_SUCCESS) {
               if (flags.dbg)
                  fprintf(dbgfile,"status =%x, error <%s>\n",status,error_m);
               def_re=0;
               }
            else {
               if (work)
                  def_re=atoi(work);
               else
                  def_re=0;
               }
            }
         else
            def_re=0;

         sprintf(sql_line,"insert into %s (%s, %s, %s, %s, %s, %s, %s) select %d, %s, %s, %d, %d, %d, '%s' from f_%s where %s=%d and %s='%s' and %s=any (select max(%s) from f_%s where %s=%d and %s='%s')"
                 ,detail_cat,D_ITEM_NO,D_FILE_NO,D_FILE_VER,D_MULT_PAGE
                 ,D_MIRROR,D_REDUCED,D_DESC,item_no,P_FILE_NO,P_FILE_VER
                 ,def_mpn,def_ma,def_re,BL_ticked(def_desc)
                 ,parameters.catalog_name
                 ,P_ITEM_NUM,item_no,P_CO_FILE,BL_ticked(tmp),P_FILE_VER
                 ,P_FILE_VER
                 ,parameters.catalog_name,P_ITEM_NUM,item_no,P_CO_FILE
                 ,BL_ticked(tmp));
         if (flags.dbg)
            fprintf(dbgfile,"SQL for D_: <%s>\n",sql_line);
      
         /* perform sql statement that we were given */
         status = SS_sql(data_buff,sql_line,&buff_size,max_rows,&error_m);
         if (flags.dbg)
            fprintf(dbgfile,"status=%d RIS says: <%s>\n",status,error_m);
         if (status) {
            BLwrite_result(DMD_F_BAD_INSERT,"");
            BLwrite_result(DMD_W_RIS_ERROR,error_m);
            if (flags.dbg) 
               fprintf(dbgfile,"Exiting write_detail() cause bad insert.\n");
            return(DMD_F_BAD_INSERT);
            }
         } /* end else for detail file */
      } /* end for file list */

   /* call upd_redlines() to update any redlines that existed */
   status = upd_redlines(item_no);

   if (flags.dbg) 
      fprintf(dbgfile,"Exiting write_detail() normally.\n");
   return(status);
} /* end write_detail() */


/******************************************************************************

Doc:    find_params

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcheckin.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        It does the dirty work of finding paramters needed for the call to
           perform an NFM checkin.
        It returns the number of files as a parameter
        It loads the global variables for this module, later these are used
           by BLcheckin().
        It doesn't include redline files in the count
        It writes its own messages to the results file, and returns a code to
           reflect the success status.
  
Examples:
          status = find_params(num_files);

Return Status:
          DMD_F_INTERN_ERR      - bad malloc
          DMD_W_SYNTAX_ERR      - bad information given
          DMD_S_SUCCESS 	- Success

History:
     09/03/91  wrw  -added standard header
     02/02/92  wrw  -modified to use new data sturcts
     08/18/92  wrw  -straighted out some problems with built in ftr.

******************************************************************************/

long find_params (num_files)
long *num_files;              /* O - number of files to checkin to the item */
{
long   max_no,tot_files;
long   i,j;
long   cof,cif,cis,ft,coc;
long   status;
char  *tmp;

   max_no = attributes[parameters.co_file_index].stored;
   /* allocate space for them */
   co_files   = (char **) malloc(max_no*sizeof(char *));
   ci_files   = (char **) malloc(max_no*sizeof(char *));
   ci_sas     = (char **) malloc(max_no*sizeof(char *));
   file_types = (char **) malloc(max_no*sizeof(char *));
   co_comms   = (char **) malloc(max_no*sizeof(char *));
   if (!co_files||!ci_files||!ci_sas||!file_types||!co_comms) {
      BLwrite_result(DMD_E_BAD_ALLOC,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcheck_in() because bad malloc. \n");
      return(DMD_E_BAD_ALLOC);
      }
   for (i=0;i<max_no;i++) {
      co_files[i]   = (char *) malloc(MAX_ATTRIBUTE_LEN*sizeof(char));
      ci_files[i]   = (char *) malloc(MAX_ATTRIBUTE_LEN*sizeof(char));
      ci_sas[i]     = (char *) malloc(MAX_ATTRIBUTE_LEN*sizeof(char));
      file_types[i] = (char *) malloc(MAX_ATTRIBUTE_LEN*sizeof(char));
      co_comms[i]   = (char *) malloc(MAX_ATTRIBUTE_LEN*sizeof(char));
      if (!co_files[i]||!ci_files[i]||!ci_sas[i]||!file_types[i]||!co_comms[i]){
         BLwrite_result(DMD_E_BAD_ALLOC,"");
         if (flags.dbg)
            fprintf(dbgfile,"Exiting BLcheck_in() because bad malloc. \n");
         return(DMD_E_BAD_ALLOC);
         }
      co_files[i][0]=0;
      ci_files[i][0]=0;
      ci_sas[i][0]=0;
      file_types[i][0]=0;
      co_comms[i][0]=0;
      }
   
   /* find check out storage area */
   if (((i=parameters.cosa_index)<0)||(!attributes[i].data[0][0])){
      BLwrite_result(DMD_W_MISSING_INFO,OP_CHECKIN);
      BLwrite_result(DMD_W_MISSING_PARAM,P_CO_SA);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcheck_in() because no co_sa.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   co_sa = atoi(attributes[i].data[0]);
   if (!(status=valid_sa(co_sa))) {
      BLwrite_result(DMD_W_BAD_INFO,P_CO_SA);
      BLwrite_result(DMD_W_BAD_VALUE,attributes[i].data[0]);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcheck_in() because bad co_sa.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   if (status != 1) {
         BLwrite_result(DMD_F_INTERN_ERR,"");
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcheck_in() because bad malloc. \n");
      return(DMD_F_INTERN_ERR);
      }

   if (flags.dbg) 
      fprintf(dbgfile,"Finding co file name index.\n");

   /* find co file names */
   if (((cof=parameters.co_file_index)<0)||
                                  (!attributes[cof].data[0][0])) {
      BLwrite_result(DMD_W_MISSING_INFO,OP_CHECKIN);
      BLwrite_result(DMD_W_MISSING_PARAM,P_CO_FILE);
      if (flags.dbg)
         fprintf(dbgfile,"Exiting BLcheck_in() because no co_filename.\n");
      return(DMD_W_SYNTAX_ERR);
      }
   
   /* find other (non-essiential) attributes */
   cif = parameters.ci_file_index;
   cis = parameters.cisa_index;
   ft  = parameters.type_index;
   coc = parameters.co_comm_index;

   if (flags.dbg) 
      fprintf(dbgfile,"Loading parameter arrays.\n");

   tot_files = 0;
   for (j=0;j<max_no;j++) {
      if (!strncmp(RL_INDIC,attributes[cof].data[j],1)) 
         continue;
      if (!strncmp(RR_INDIC,attributes[cof].data[j],1)) {
         tmp = attributes[cof].data[j];
         tmp++;
         strcpy(co_files[tot_files],tmp);
         if (flags.dbg)
            fprintf(dbgfile,"Reduced Res found : <%s>\n",tmp);
         }
      else if (!strncmp(FTR_INDIC,attributes[cof].data[j],1)) {
         tmp = attributes[cof].data[j];
         tmp++;
         strcpy(co_files[tot_files],tmp);
         if (flags.dbg)
            fprintf(dbgfile,"Internal FTR file found: <%s>\n",tmp);
         }
      else
         strcpy(co_files[tot_files],attributes[cof].data[j]);
      if (flags.dbg) 
         fprintf(dbgfile,"---co_filename=<%s>\n",co_files[tot_files]);

      if ((cif >= 0) && (attributes[cif].data[j][0])) {
         strcpy(ci_files[tot_files],attributes[cif].data[j]);
         }
      if (flags.dbg) 
         fprintf(dbgfile,"---ci_filename=<%s>\n",ci_files[tot_files]);

      if ((cis >= 0) && (attributes[cis].data[j][0])) {
         strcpy(ci_sas[tot_files],attributes[cis].data[j]);
         }
      if (flags.dbg) 
         fprintf(dbgfile,"---ci_sano=<%s>\n",ci_sas[tot_files]);

      if ((ft >= 0) && (attributes[ft].data[j][0])) {
         strcpy(file_types[tot_files],attributes[ft].data[j]);
         }
      if (flags.dbg) 
         fprintf(dbgfile,"---file_type=<%s>\n",file_types[tot_files]);

      if ((coc >= 0) && (attributes[coc].data[j][0])) {
         strcpy(co_comms[tot_files],attributes[coc].data[j]);
         }
      if (flags.dbg) 
         fprintf(dbgfile,"---co_comm=<%s>\n",co_comms[tot_files]);
      tot_files++;
      }
   *num_files = tot_files;
   return(DMD_S_SUCCESS);
} /* end find_params */


/******************************************************************************

Doc:    free_params

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: BLcheckin.c

Author: Rob Whitesell

Date:   10-JUNE-1991

Description:
        This function frees the memory allocated by find_params() to hold the
           checkin parameters.
        It writes its own messages to the results file, and returns a code to
           reflect the success status.
  
Examples:
          free_params();

Return Status:
          (none)

History:
     09/03/91  wrw  -added standard header

******************************************************************************/

void free_params ()
{
long i;

   for (i=0;i<attributes[parameters.co_file_index].stored;i++) {
      if (co_files[i])   free(co_files[i]);
      if (ci_files[i])   free(ci_files[i]);
      if (ci_sas[i])     free(ci_sas[i]);
      if (file_types[i]) free(file_types[i]);
      if (co_comms[i])   free(co_comms[i]);
      }
   if (co_files)   free(co_files);
   if (ci_files)   free(ci_files);
   if (ci_sas)     free(ci_sas);
   if (file_types) free(file_types);
   if (co_comms)   free(co_comms);
} /* end free_params */
