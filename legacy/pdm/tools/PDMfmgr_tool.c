#include <stdio.h>
#include <MEMstruct.h>
#include <PDUstorage.h>
#include <PDUerror.h>
#include <SQLerrordef.h>
#include <NFMerrordef.h>

/* ALR  7/23/93   This file contains functions that are used by the PDU product
   and the API's. These are functions that were pulled out of the original
   file locations to be more independent of other functions.
*/

extern struct PDUstorage *storage;
extern          int             PDMdebug_on;
extern          char    PDM_DEBUG_FILE[];

static long status;
static char s[1024];


int PDMlogin_find_sainfo(n_sano,n_saname)
int             *n_sano;
char            *n_saname;
{
        char    *fn = "PDMlogin_find_sainfo";
        char    dbpasswd [51], passwd[15];
        char    **data;
        char    sql_str[512];
        char    *msg;
        MEMptr  bufr = NULL;
        int             n_nodeno;

        PDMdebug("ENTER:PDMlogin_find_sainfo\n");

   /* find storage no */

/*
   status = MEMbuild_array(storage_buffer);
   if(status != MEM_S_SUCCESS) {
                sprintf(s,"MEMbuild_array failed status %d\n",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
   }
   strg_data = (char **) storage_buffer->data_ptr;
   columns = (char **) storage_buffer->column_ptr;
   strcpy (passwd, strg_data[4]);
   p1 = -1; p2 = -1; p3 = -1; p4 = -1;
   for(j=0;j<storage_buffer->columns;j++) {
       if(!strcmp(columns[j],"node_name"))     p1 = j;
       if(!strcmp(columns[j],"user_name"))     p2 = j;
       if(!strcmp(columns[j],"path_name"))     p3 = j;
       if(!strcmp(columns[j],"passwd"))        p4 = j;
   }
   if(p1 == -1 || p2 == -1 || p3 == -1 || p4 == -1 ) {
                PDMdebug("Couldnot find cols in <storage_buffer>\n");
                return(PDM_E_BUFFER_FORMAT);
   }
*/
   PDMupdate_dots();
   strcpy (passwd, storage->passwd);
                status = PDMi_find_nodeno(storage->node_name, &n_nodeno);
                if(status != PDM_S_SUCCESS) {
                        sprintf(s,"PDMi_find_nodeno failed status %d\n",status);
                        PDMdebug(s);
                                return(PDM_I_NO_SAREA_FOUND);

                }

   status = _PDMCheckDuplPath (n_nodeno);
   if (status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "Duplicate Storage Path Found status %d\n",status);
     if (status == PDM_E_DUPL_BAD_STORAGE_AREA) {
        /*msg[0] = '\0';*/
        msg = (char *) PDUtranslate_message (PDM_E_DUPL_BAD_STORAGE_AREA);
/*
        strcat (msg, "This working directory is already being used by another user. Please use another directory to work from.");
*/
         UI_error (msg);
          }
     return(status);
     }
           sql_str[0] = '\0';
        sprintf(sql_str,
"SELECT n_sano, n_saname, n_passwd FROM NFMSTORAGEAREA WHERE n_nodeno = %d \
 AND n_username = '%s' AND n_pathname = '%s'",
 n_nodeno,storage->user_name, storage->path_name);
                status = SQLquery(sql_str,&bufr,512);
                if(status != SQL_S_SUCCESS) {
                   MEMclose(&bufr);
                   if(status == SQL_I_NO_ROWS_FOUND) {
/* Added fix to eliminate 2 users using same working area MaC 012994*/
                     status = _PDMCheckDuplPath (n_nodeno);
                     if (status != PDM_S_SUCCESS) {
                        _PDMdebug (fn,
                        "Duplicate Storage Path Found status %d\n",status);
/*                       if (PDM_E_DUPL_BAD_STORAGE_AREA) */
                                return(status);
                         }
                        _PDMdebug (fn,
                        "nfmstoragearea query failed status %d\n",status);
                                return(PDM_I_NO_SAREA_FOUND);
                   }
                   _PDMdebug (fn,
                   "SQL query failed status %d\n",status);
                    return(status);
                }
   PDMupdate_dots();
                status = MEMbuild_array(bufr);
                if(status != MEM_S_SUCCESS) {
                        MEMclose(&bufr);
                        sprintf(s,"MEMbuild_array failed status %d\n",status);
                        PDMdebug(s);
                        return(PDM_E_BUILD_ARRAY);
                }
                data = (char **) bufr->data_ptr;
   if(PDMdebug_on) {
                MEMprint_buffer("bufr in PDMlogin_find_sainfo",
                                bufr, PDM_DEBUG_FILE);
   }

/* added 022492 - MaC: checking and updating user-sano-passwd combo */

        /* Decrypt the passwd first ....*/
        status = NFMdecrypt (data[2], &dbpasswd);
        if(status != NFM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s,"NFMdecrypt failed status %d\n",status);
                PDMdebug(s);
/*              return(PDM_E_DECRYPT);*/
                return(PDM_E_LOGIN);
                }
       _PDMdebug (fn, "dbpasswd[%s] <=> passwd[%s]\n",
                   dbpasswd, passwd);

        /* Update the passwd in the database if it is old...*/
        if ( strcmp (dbpasswd, passwd) ) {
        status = NFMchange_working_area_passwd  (data [1], dbpasswd, passwd);
        if(status != NFM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s,"NFMchange_working_area_passwd failed status %d\n",
                                      status);
   PDMdebug(s);
                return(PDM_E_LOGIN);
                /*return(PDM_E_UPDATE_SA);*/
                }

          }

                *n_sano = atoi(data[0]);
                strcpy(n_saname,data[1]);
       _PDMdebug (fn, "n_sano = %d and n_saname = %s\n", n_sano, n_saname);
                MEMclose(&bufr);
         PDMupdate_dots();
        PDMdebug("EXIT:PDMlogin_find_sainfo\n");
        return(PDM_S_SUCCESS);
}


int PDMi_find_storageno_name(n_sano,n_saname)
int             *n_sano;
char            *n_saname;
{
        char    **data;
        char    *fn = "PDMi_find_storageno_name";
        char    sql_str[512];
        MEMptr  bufr = NULL;
        int             n_nodeno;

        PDMdebug("ENTER:PDMi_find_storageno_name\n");

   /* find storage no */

/*
   status = MEMbuild_array(storage_buffer);
   if(status != MEM_S_SUCCESS)
   {
                sprintf(s,"MEMbuild_array failed status %d\n",status);
                PDMdebug(s);
                return(PDM_E_BUILD_ARRAY);
   }
   strg_data = (char **) storage_buffer->data_ptr;
   columns = (char **) storage_buffer->column_ptr;
   p1 = -1; p2 = -1; p3 = -1;
   for(j=0;j<storage_buffer->columns;j++)
   {
           if(!strcmp(columns[j],"node_name"))     p1 = j;
       if(!strcmp(columns[j],"user_name"))     p2 = j;
       if(!strcmp(columns[j],"path_name"))         p3 = j;
   }
   if(p1 == -1 || p2 == -1 || p3 == -1 )
   {
                PDMdebug("Couldnot find cols in <storage_buffer>\n");
                return(PDM_E_BUFFER_FORMAT);
   }
*/
                status = PDMi_find_nodeno(storage->node_name,&n_nodeno);
                if(status != PDM_S_SUCCESS)
                {
                        sprintf(s,"PDMi_find_nodeno failed status %d\n",status);
                        PDMdebug(s);
                                return(PDM_I_NO_SAREA_FOUND);

                }
           sql_str[0] = '\0';
           sprintf(sql_str, "SELECT n_sano,n_saname from nfmstoragearea where n_nodeno = %d AND n_username = '%s' AND n_pathname = '%s'",n_nodeno,storage->user_name, storage->path_name);
                status = SQLquery(sql_str,&bufr,512);
                if(status != SQL_S_SUCCESS)
                {
                        MEMclose(&bufr);
                        if(status == SQL_I_NO_ROWS_FOUND)
                        {
                                return(PDM_I_NO_SAREA_FOUND);

                        }
                }
                status = MEMbuild_array(bufr);
                if(status != MEM_S_SUCCESS)
                {
                        MEMclose(&bufr);
                        sprintf(s,"MEMbuild_array failed status %d\n",status);
                        PDMdebug(s);
                        return(PDM_E_BUILD_ARRAY);
                }
                data = (char **) bufr->data_ptr;
   if(PDMdebug_on) {
  MEMprint_buffer("bufr in PDMi_find_storageno_name",
                                bufr, PDM_DEBUG_FILE);
   }

                *n_sano = atoi(data[0]);
                strcpy(n_saname,data[1]);
       _PDMdebug (fn, "n_sano = %d and n_saname = %s\n", n_sano, n_saname);
                MEMclose(&bufr);
        PDMdebug("EXIT:PDMi_find_storageno_name\n");
        return(PDM_S_SUCCESS);
}

/* This function checks to see if present path is duplicate
   for any other user.....MaC 012994 */

int _PDMCheckDuplPath (nodeno)
int  nodeno;
{
 char      *fn = "_PDMCheckDuplPath";
 char      sql_str[512];
 MEMptr    bufr = NULL;
 char      **data;
 int       x, index;

  PDMdebug("ENTER:_PDMCheckDuplPath\n");
  
  sql_str[0] = '\0';
  sprintf(sql_str,
   "SELECT n_sano, n_saname, n_passwd, n_username \
    FROM NFMSTORAGEAREA WHERE n_nodeno = %d AND n_pathname = '%s'",
    nodeno, storage->path_name);

   status = SQLquery(sql_str, &bufr, 512);
   if(status != SQL_S_SUCCESS) {
      MEMclose(&bufr);
        _PDMdebug (fn, 
         "path is unique & needs to be added; query failed status %d\n",status);
        _PDMdebug (fn, "Exit\n");
        /* we are returning success cos this will trigger
           "no sa found" from calling function. MaC */
        return (PDM_S_SUCCESS);
        }

   PDMupdate_dots();

   status = MEMbuild_array (bufr);
   if(status != MEM_S_SUCCESS) {
      MEMclose(&bufr);
      _PDMdebug (fn, "MEMbuild_array failed status %d\n",status);
      return(PDM_E_BUILD_ARRAY);
      }

   if(PDMdebug_on) {
                MEMprint_buffer("bufr in _PDMCheckDuplPath",
                                bufr, PDM_DEBUG_FILE);
   }

   data = (char **) bufr->data_ptr;

   for (x = 0; x < bufr->rows; x++) {
    index = x * bufr->columns ;
    if (strcmp (data [index + 3], storage->user_name)) {
       _PDMdebug (fn, "This path [%s] is not unique.., used for user [%s]\n",
                    storage->path_name, data[index+3]);
        MEMclose (&bufr);
        return (PDM_E_DUPL_BAD_STORAGE_AREA);
        }
     }

   MEMclose (&bufr);
/*
   _PDMdebug (fn, "There is already a storage area for this directory\n");
   return (PDM_E_DUPL_STORAGE_AREA);
*/
   _PDMdebug (fn, "EXIT\n");
   return (PDM_S_SUCCESS);
 }
