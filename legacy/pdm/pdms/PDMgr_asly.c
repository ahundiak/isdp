#include      <stdio.h>
#include      "PDUerror.h"
#include      "MEMstruct.h"
#include      "MEMerrordef.h"
#include      "NFMerrordef.h"
#include      "SQLerrordef.h"
#include      "PDUris_incl.h"
#include      "PDMproto.h"
#include      "PDUpdmrpro.h"
#include      "PDMmessage.h"

static  long      status;
static  char      s[1024];
extern  int         PDMdebug_on;
extern   char      PDM_DEBUG_FILE[];
extern  PDMexec_ptr     PDMexec;


/* defines the assembly stucture of the part */
/*
 * This function is to be called whenever (during define assy st) the n_citnos
 *  are to be defined .
 *
 * DESCRIPTION:
 * To define a non-graphic assembly, a list of 1-level children are
 * given.
 *  Kumar - 2/27/92
 */


int   PDMsdefine_assembly_structure (assembly)
MEMptr      assembly;
{
        char            *fname = "PDMsdefine_assembly_structure";
   MEMptr   temp_buffer = NULL;
   MEMptr   bufr = NULL;
   char     n_setindicator[2];
   char     **columns, **data;
   char     p_quantity[50], sql_str[1024];
   /*char      p_incbom[2];*/
   char      s_citno[50];
   int      a1, a2, a3, a4, a5, a6, a7, a8;
   int      m1, m2, m3, m4, m5, m6, m7, m8;
   int      m9, m10, m11, m12, m13, m14;
   int      i, j, nx, nxj;
   int      catno, partno;

   _PDMdebug (fname, "ENTER:\n");

   status = PDMquery_catalog_partnos (PDMexec->catalog, 
                                     PDMexec->part_num,          
                                     PDMexec->revision, &catno, &partno);
   if (status != PDM_S_SUCCESS) {
        MEMclose (&assembly);
        _PDMdebug (fname, "PDMquery_catalog_partnos failed status %d\n", status);
        return (status);
   }

   /* expand the assembly buffer */

   status = MEMopen (&temp_buffer, 1024);
   if (status != MEM_S_SUCCESS) {
       MEMclose (&assembly);
        _PDMdebug (fname, "MEMopen failed status %d\n", status); 
       return (PDM_E_OPEN_BUFFER);
         }

   status = MEMwrite_format (temp_buffer, "p_citno", "integer");
   if (status == MEM_S_SUCCESS)
   status = MEMwrite_format (temp_buffer, "n_catalogno", "integer");
   if (status == MEM_S_SUCCESS)
   status = MEMwrite_format (temp_buffer, "n_itemno", "integer");
   if (status == MEM_S_SUCCESS)
   status = MEMwrite_format (temp_buffer, "pn_catalogno", "integer");
   if (status == MEM_S_SUCCESS)
   status = MEMwrite_format (temp_buffer, "pn_itemno", "integer");
   if (status == MEM_S_SUCCESS)
   status = MEMwrite_format (temp_buffer, "p_flag", "char(1)");
   if (status != MEM_S_SUCCESS) {
        MEMclose (&temp_buffer); MEMclose (&assembly);
        _PDMdebug (fname, "MEMwrite_format failed status 0x%.8x\n", status); 
        return (PDM_E_WRITE_FORMAT);
   }

   status = PDMexpand_copy_buffer (assembly, temp_buffer, &bufr);
   if (status != PDM_S_SUCCESS) {
      MEMclose (&temp_buffer); MEMclose (&assembly);
      _PDMdebug (fname, "PDMexpand_copy_buffer failed status 0x%.8x\n", status);
      return (status);    
        }

   MEMclose (&assembly); MEMclose (&temp_buffer);

   if (PDMdebug_on) MEMprint_buffer ("bufr", bufr, PDM_DEBUG_FILE);

   /* check if part is an assembly */

   n_setindicator[0] = '\0';

   status = PDMquery_assembly_ind (PDMexec->catalog, 
                                   PDMexec->part_num,          
                                   PDMexec->revision, n_setindicator);
   if (status != PDM_S_SUCCESS) {
     MEMclose (&bufr);
     _PDMdebug (fname, "PDMquery_assembly_ind failed status 0x%.8x\n", status);
     return (status);
   }

   /* load children's n_catalogno, n_itemno */

        status = PDMload_partnos (bufr);
   if (status != PDM_S_SUCCESS)
   {
     MEMclose (&bufr);
     _PDMdebug (fname, "PDMload_partnos failed status 0x%.8x\n", status); 
     goto wrapup;
   }

   /* load parent's pn_catalogno, pn_itemno */

        status = PDMload_parentnos (catno, partno, bufr);
   if (status != PDM_S_SUCCESS)
   {
     MEMclose (&bufr);
     _PDMdebug (fname, "PDMload_parentnos failed status 0x%.8x\n", status); 
     goto wrapup;
   }

   /* do cyclic check if requested */

        if (PDMexec->operation)
   {
      /* check assembly stucture */

      status = PDMcheck_cycles (bufr);
   if (status != PDM_S_SUCCESS)
    {
     MEMclose (&bufr);
     _PDMdebug (fname, "PDMcheck_cycles failed status 0x%.8x\n", status); 
     goto wrapup;
    }
   }

   /* load buffer into nfmsetcit */

   status = PDMstop_transaction (1200);
   if (status != PDM_S_SUCCESS)
   {
     MEMclose (&bufr);
     _PDMdebug (fname, "PDMstop_transaction failed status 0x%.8x\n", status);
     return (status);
   }

   /* if part is an assembly then drop its assembly structure */

/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
   if (!strncmp (n_setindicator, "Y", 1) || !strncmp (n_setindicator, "y", 1))
*/
   if (!strncmp (n_setindicator, "Y", 1) || 
       !strncmp (n_setindicator, "y", 1) ||
       !strncmp (n_setindicator, "A", 1) ||
       !strncmp (n_setindicator, "a", 1)) {
     status = PDMdron_setindicator (catno, partno);
     if (status != PDM_S_SUCCESS ) {
       MEMclose (&bufr);
       _PDMdebug (fname, "PDMdronme_setindicator failed status 0x%.8x\n", status); 
       goto wrapup;
     }
   }

   status = PDMload_set_members (PDMexec->user_id, bufr);
   if (status != PDM_S_SUCCESS) {
     MEMclose (&bufr);
     _PDMdebug (fname, "PDMload_set_members failed status 0x%.8x\n", status);
     goto wrapup;
   }

   if (PDMdebug_on)
     MEMprint_buffer ("bufr after PDMload_set_members ", 
                                            bufr, PDM_DEBUG_FILE);

   status = MEMbuild_array (bufr);

   if (status != MEM_S_SUCCESS) {
     MEMclose (&bufr);
     _PDMdebug (fname, "MEMbuild_array failed status 0x%.8x\n", status); 
     status = PDM_E_BUILD_ARRAY;
     goto wrapup;
   }

   a1 = -1; a2 = -1; a3 = -1; a4 = -1;
   a5 = -1; a6 = -1; a7 = -1; a8 = -1;
   m1 = -1; m2 = -1; m3 = -1; m4 = -1;
   m5 = -1; m6 = -1; m7 = -1; m8 = -1;
   m9 = -1; m10 = -1; m11 = -1; m12 = -1; m13 = -1, m14 = -1;
        
   data = (char **) bufr->data_ptr;
   columns = (char **) bufr->column_ptr;

   for (i=0;i<bufr->columns;i++) {
        if (!strcmp (columns[i], "p_citno"))       a1 = i;
        else   if (!strcmp (columns[i], "p_flag"))       a4 = i;
        else   if (!strcmp (columns[i], "n_catalogno"))      a5 = i;
        else    if (!strcmp (columns[i], "n_itemno"))      a6 = i;
         else   if (!strcmp (columns[i], "pn_catalogno"))    a7 = i;
        else   if (!strcmp (columns[i], "pn_itemno"))      a8 = i;
        else    if (!strcmp (columns[i], "n_catalogname")) m1 = i;
        else    if (!strcmp (columns[i], "n_itemname")) m2 = i;
        else    if (!strcmp (columns[i], "n_itemrev")) m3 = i;
        else    if (!strcmp (columns[i], "p_quantity")) m4 = i;
        else    if (!strcmp (columns[i], "p_history")) m5 = i;
        else    if (!strcmp (columns[i], "p_childno")) m6 = i;
        else    if (!strcmp (columns[i], "p_usageid")) m7 = i;
        else    if (!strcmp (columns[i], "p_tagno")) m8 = i;
        else    if (!strcmp (columns[i], "p_alttagno")) m9 = i;
        else    if (!strcmp (columns[i], "p_incbom")) m10 = i;
        else    if (!strcmp (columns[i], "p_explode")) m11 = i;
        else    if (!strcmp (columns[i], "p_attached")) m12 = i;
        else    if (!strcmp (columns[i], "n_cofilename")) m13 = i;
        else    if (!strcmp (columns[i], "p_incstr")) m14 = i;
        }
   if (a1 == -1 || a4 == -1 ||
      a5 == -1 || a6 == -1 || a7 == -1 || a8 == -1 ||
           m1 == -1 || m2 == -1 || m3 == -1 || m4 == -1 ||
           m5 == -1 || m6 == -1 || m9 == -1 ||
           m7 == -1 || m8 == -1 ||  m10 == -1 ||
           m11 == -1 || m12 == -1 || m13 == -1 || m14 == -1) 
   {
     MEMclose (&bufr);
     _PDMdebug (fname, "Couldnot set offsets in bufr\n");
     status = PDM_E_BUFFER_FORMAT;
     goto wrapup;
   }

   /* next insert pdmcit entries */

   for (i=0;i<bufr->rows;i++) {
     nx = i * bufr->columns;
     if (strlen (data[nx+m4]))
           strcpy (p_quantity, data[nx+m4]);
      else
         sprintf (p_quantity, "%d", 1);

        /* set p_citno */

      if (!strcmp (data[nx+a4], "D")) {
        for (j=0;j<bufr->rows;j++) {
          nxj = j * bufr->columns;
          if (!strcmp (data[nx+a5], data[nxj+a5]) &&
               !strcmp (data[nx+a6], data[nxj+a6]) &&
               !strcmp (data[nx+a7], data[nxj+a7]) &&
               !strcmp (data[nx+a8], data[nxj+a8]))
          {
            if (!strlen (data[nxj+a4])) {
             strcpy (s_citno, data[nxj+a1]);
             break;
               }
          }
        }
      }
      else
         strcpy (s_citno, data[nx+a1]);

/* 
    Added on 3.9.93 by Kumar to
    support added for background part (p_incstr):
     p_incstr   p_incbom        p_incbom
     Y          Y               Y
     N          N               N
     Y          N               A
     N          Y               B
  */

     if ( (!strcmp (data[nx+m10], "Y") ||
                          !strcmp (data[nx+m10], "y")) &&
         (!strcmp (data[nx+m14], "Y") ||
                          !strcmp (data[nx+m14], "y")))
                                        strcpy (data[nx+m10], "Y");
     else if ( (!strcmp (data[nx+m10], "N") ||
                          !strcmp (data[nx+m10], "n")) &&
         (!strcmp (data[nx+m14], "N") ||
                          !strcmp (data[nx+m14], "n")))
                                        strcpy (data[nx+m10], "N");
     else if ( (!strcmp (data[nx+m10], "N") ||
                          !strcmp (data[nx+m10], "n")) &&
         (!strcmp (data[nx+m14], "Y") ||
                          !strcmp (data[nx+m14], "y")))
                           strcpy (data[nx+m10], "A");
     else
                 strcpy (data[nx+m10], "B");

/* Fix added to also insert n_cofilename. MaC 121393 ..
     sprintf (sql_str, 
"%s (%s) VALUES (%s, '%s', '%s', %s, '%s', %s, '%s', '%s', '%s', '%s', '%s', '%s', %s)", 
      "INSERT INTO pdmcit ", 
      "p_citno, p_attached, p_history, p_quantity, p_usageid, p_tagno, p_alttagno, p_incbom, p_explode, n_catalogname, n_itemname, n_itemrev, p_childno", 
       s_citno, data[nx+m12], data[nx+m5], p_quantity, data[nx+m7], data[nx+m8], data[nx+m9], data[nx+m10], data[nx+m11], data[nx+m1], data[nx+m2], data[nx+m3], data[nx+m6]);
      */

     sprintf (sql_str, "INSERT INTO pdmcit ( %s %s %s ) VALUES (%s, '%s', '%s', %s, '%s', %s, '%s', '%s', '%s', '%s', '%s', '%s', %s, '%s')", 
      " p_citno, p_attached, p_history, p_quantity, p_usageid, p_tagno, ",
      " p_alttagno, p_incbom, p_explode, n_catalogname, n_itemname,  ",
      " n_itemrev, p_childno, n_cofilename ", 
       s_citno, data[nx+m12], data[nx+m5], p_quantity, data[nx+m7], 
       data[nx+m8], data[nx+m9], data[nx+m10], data[nx+m11], data[nx+m1], 
       data[nx+m2], data[nx+m3], data[nx+m6], data[nx+m13]);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS) {
         MEMclose (&bufr);
         _PDMdebug (fname, "SQLstmt failed status 0x%.8x\n", status);
         status = PDM_E_SQL_STMT;
         goto wrapup;
         }
   }
   MEMclose (&bufr);

   /* set n_setindicator */

   status = PDMset_n_setindicator (PDMexec->catalog, 
                                   PDMexec->part_num, 
                                   PDMexec->revision, "Y");
   if (status != PDM_S_SUCCESS) {
      _PDMdebug (fname, "PDMset_n_setindicator failed status 0x%.8x\n", status); 
      goto wrapup;
     }

   sprintf (sql_str, 
     "UPDATE %s SET p_incpartrpt = 'U' WHERE n_itemname = '%s' and n_itemrev = '%s'", 
      PDMexec->catalog, PDMexec->part_num, PDMexec->revision);

   SQLstmt (sql_str);
   status = PDMstart_transaction (1200);
   if (status != PDM_S_SUCCESS) {
     _PDMdebug (fname, "PDMstart_transaction failed status \n", status);
     return (status);
   }

   _PDMdebug (fname, "EXIT:\n");
   return (PDM_S_SUCCESS);

 wrapup:

    _PDMdebug (fname, "ERROR:PDMsdefine_assembly_strucuture status 0x%.8x\n", status);
   if (PDMrollback_transaction (1200) != PDM_S_SUCCESS)
   {
      _PDMdebug (fname, "PDMrollback_transaction failed status \n", status);
   }
   return (status);
}


int  PDMi_check_level (bufr)
MEMptr   bufr;
{
   char      **data, **columns;
   int         i, a1, l1, l2;
   int         nx1, nx2 ;

   PDMdebug ("ENTER:PDMi_check_level\n");

   status = MEMbuild_array (bufr);
   if (status != MEM_S_SUCCESS)
   {
      sprintf (s, "MEMbuild_array failed status 0x%.8x\n", 
      status); PDMdebug (s);
      return (PDM_E_BUILD_ARRAY);
   }

   a1 = -1;

   data = (char **) bufr->data_ptr;
   columns = (char **) bufr->column_ptr;

   for (i=0;i<bufr->columns;i++)
   {
      if (!strcmp (columns[i], "n_level"))   a1 = i;
   }

   if (a1 == -1)
   {
      PDMdebug ("Could not set offsets in bufr\n");
      return (PDM_E_BUFFER_FORMAT);
   }

   l1 = atol (data[a1]);

   if (l1 != 1)
   {
      sprintf (s, "Incorrect Assembly stucture\n");
      PDMdebug (s);
      return (PDM_E_FAILURE);
   }

   for (i=1;i<bufr->rows;i++)
   {
      nx1 = (i-1) * bufr->columns;
      nx2 = i * bufr->columns;
      l1 = atol (data[nx1+a1]);
      l2 = atol (data[nx2+a1]);
      if ( (l1 > l2) && (l2 < 1))
      {
         sprintf (s, "Incorrect Assembly stucture\n");
         PDMdebug (s);
         return (PDM_E_FAILURE);
      }
      else if ( (l2 > l1) && (l2-l1 != 1))
      {
         sprintf (s, "Incorrect Assembly stucture\n");
         PDMdebug (s);
         return (PDM_E_FAILURE);
      }
   }
   PDMdebug ("EXIT:PDMi_check_level\n");
   return (PDM_S_SUCCESS);
}

int PDMdron_setindicator (n_pcatalogno, n_pitemno)
int n_pcatalogno;
int n_pitemno;
{
   char      *fn = "PDMdron_setindicator";
   /* char      sql_str[512]; Insufficient. MaC 100494 */
   char      *sql_str;
   char      sql_str1[1024];
   char      **column_ptr, **data_ptr;
   MEMptr      bufr = NULL;   
   int             i = 0;

   PDMdebug ("ENTER:PDMdron_setindicator\n");

   sql_str1[0]='\0';
   sprintf (sql_str1, 
   "SELECT n_citno FROM NFMSETCIT WHERE n_pcatalogno = %d AND n_pitemno = %d",
                            n_pcatalogno, n_pitemno);

    status = SQLquery (sql_str1, &bufr, 1024);
    if (status  ==  SQL_I_NO_ROWS_FOUND) {
       _PDMdebug (fn, "No citnos found\n");
       PDMdebug ("EXIT:PDMdron_setindicator\n");
       return (PDM_S_SUCCESS);
       }
    else if (status !=  SQL_S_SUCCESS) {
       MEMclose (&bufr);
       _PDMdebug (fn, "SQLquery error : 0x%.8x\n", status);
       return (PDM_E_SQL_STMT);
       }

    status = MEMbuild_array (bufr);
    if (status !=  MEM_S_SUCCESS) {
       MEMclose (&bufr);
       _PDMdebug (fn, "MEMbuild_array error : 0x%.8x\n", status);
       return (PDM_E_BUILD_ARRAY);
          }

     data_ptr = (char **)bufr->data_ptr;
     column_ptr = (char **)bufr->column_ptr;

       /* delete all the first level children for the given part
          There is no need for calling the function
          NFMupdate_set_members with the level as 1. NFMupdate_set_members
          should be called only to get children with more than
          1 level */

     sprintf (sql_str1, 
      "DELETE FROM NFMSETCIT WHERE n_pcatalogno = %d AND n_pitemno = %d ", 
                                                      n_pcatalogno, n_pitemno);

     status = SQLstmt (sql_str1);
     if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND )
          {
            return (PDM_E_SQL_STMT);
          }


   /* sql_str will be dynamically allocated MaC 100494 */

    _PDMdebug (fn, "New sql_str alloc size = %d\n",
               ((bufr->rows * (25 + bufr->row_size)) + 512));

    sql_str = (char *) malloc ((bufr->rows * (25 + bufr->row_size)) + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }

    sql_str[0] = '\0';
    sprintf (sql_str, "%s ", 
                        "DELETE FROM pdmcit");

     /* delete old pdmcit assembly structure */

    for (i = 0; i < bufr->rows; i++) {
                sql_str1[0] = '\0';
        if ( i == 0)
        sprintf (sql_str1, "%s %d", " WHERE p_citno = ", atol (data_ptr[i]));
        else
        sprintf (sql_str1, "%s %d", " OR p_citno = ", atol (data_ptr[i]));
        strcat (sql_str, sql_str1);
        }
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
         _PDMdebug  (fn, "SQLstmt failed status 0x%.8x\n", status);
         if (sql_str) free (sql_str);
         return (PDM_E_SQL_STMT);
         }

   MEMclose (&bufr);
   if (sql_str) free (sql_str);

   PDMdebug ("EXIT:PDMdron_setindicator\n");
   return (PDM_S_SUCCESS);
}

/* 
   figures out the parent and loads pn_catalogno, pn_itemno
   at the end p_flag for duplicates is set to "D"
   (to be used while genarating n_citnos)
*/

int PDMload_parentnos (catno, partno, bufr)
int       catno;
int       partno;
MEMptr    bufr;
{
   int      a1 = -1, a2 = -1, a3 = -1, a4 = -1, a5 = -1, a6 = -1, p_row = 0;
   int         i, j, nx1, nx2, nx3, nx4;
   int         level1 = 0, level2;
   char      s_catno[50], s_partno[50];
   char      **column_ptr, **data;

   PDMdebug ("ENTER:PDMload_parentnos\n");

   a1 = -1; a2 = -1; a3 = -1; 
   a4 = -1; a5 = -1; a6 = -1;

   sprintf (s_catno, "%d", catno);
   sprintf (s_partno, "%d", partno);

   /* set required offsets */

   status = MEMbuild_array (bufr);
   if (status != MEM_S_SUCCESS)
   {
      sprintf (s, "MEMbuild_array failed status %d\n", status);
      PDMdebug (s);
      return (PDM_E_BUILD_ARRAY);
   }

   column_ptr = (char **) bufr->column_ptr;
   data = (char **) bufr->data_ptr;

   for (i=0;i<bufr->columns;i++)
   {
      if (!strcmp (column_ptr[i], "n_catalogno"))        a1 = i;
      else if (!strcmp (column_ptr[i], "n_itemno"))      a2 = i;
      else if (!strcmp (column_ptr[i], "pn_catalogno"))    a3 = i;
         else if (!strcmp (column_ptr[i], "pn_itemno"))    a4 = i;
      else if (!strcmp (column_ptr[i], "n_level"))       a5 = i;
      else if (!strcmp (column_ptr[i], "p_flag"))       a6 = i;
   }
   if (a1 == -1 || a2 == -1 || a3 == -1 || 
      a4 == -1 || a5 == -1 || a6 == -1)
   {
      PDMdebug ("Could not set offsets in bufr\n");
      return (PDM_E_BUFFER_FORMAT);
   }

   for (i=0;i<bufr->rows;i++)
   {
      nx1 = (i-1) * bufr->columns;
      nx2 = i * bufr->columns;
      if (i) level1 = atoi (data[nx1+a5]);
      level2 = atoi (data[nx2+a5]);
      if (i)
      {
         if (level2 - level1 == 1)
         {
            p_row = i-1;
         }
         else if ( (level2 - level1) < 0)
         {
            p_row = -1;
            for (j=i-1;j>0;j--)
            {
               nx3 = j * bufr->columns;
               nx4 = (j-1) * bufr->columns;
               if (!strcmp (data[nx2+a5], data[nx3+a5]) &&
                   strcmp (data[nx3+a5], data[nx4+a5]))
               {
                  p_row = j-1;  break;
               }
            }   
            if (p_row == -1)  p_row = 0;         
         }
      }
       if (level2 == 1)
      {
         status = PDMwrite_2_cols (bufr, i+1, a3+1, a4+1, 
                            s_catno, s_partno);
         if (status != PDM_S_SUCCESS)
         {
            return (status);
         }
      }
      else
      {
         status = PDMwrite_2_cols (bufr, i+1, a3+1, a4+1, 
                            data[p_row*bufr->columns+a1], 
                            data[p_row*bufr->columns+a2]);
         if (status != PDM_S_SUCCESS)
         {
            return (status);
         }
      }      
   }

   /* set p_flag */

   status = MEMbuild_array (bufr);
   if (status != MEM_S_SUCCESS)
   {
      sprintf (s, "MEMbuild_array failed status %d\n", status);
      PDMdebug (s);
      return (PDM_E_BUILD_ARRAY);
   }
   data = (char **) bufr->data_ptr;
   for (i=0;i<bufr->rows;i++)
   {
     nx1 = i * bufr->columns;

            /* if it is already set avoid */

     if (strcmp (data[nx1+a6], "D"))
      {
      for (j=0;j<bufr->rows;j++)
      {
         if (i != j)
         {
            nx2 = j * bufr->columns;
            if (!strcmp (data[nx1+a1], data[nx2+a1]) &&
               !strcmp (data[nx1+a2], data[nx2+a2]) &&
               !strcmp (data[nx1+a3], data[nx2+a3]) &&
               !strcmp (data[nx1+a4], data[nx2+a4]))
            {
               status = MEMwrite_data (bufr, "D", j+1, a6+1);
               if (status != MEM_S_SUCCESS)
               {
                  sprintf (s, "MEMwrite_data failed status %d\n", 
                  status); PDMdebug (s);
                  return (PDM_E_WRITE_COLUMN);
               }
            }
         }
      }
     }
   }
   PDMdebug ("EXIT:PDMload_parentnos\n");
   return (PDM_S_SUCCESS);
}


int PDMwrite_2_cols (bufr, row, col1, col2, val1, val2)
MEMptr   bufr;
int      row;
int      col1;
int      col2;
char   *val1;
char   *val2;
{

   status = MEMwrite_data (bufr, val1, row, col1);
   if (status != MEM_S_SUCCESS)
   {
      sprintf (s, "MEMwrite_data failed status %d \n", 
      status); PDMdebug (s);
      return (PDM_E_WRITE_COLUMN);
   }
   status = MEMwrite_data (bufr, val2, row, col2);
   if (status != MEM_S_SUCCESS)
   {
      sprintf (s, "MEMwrite_data failed status %d \n", 
      status); PDMdebug (s);
      return (PDM_E_WRITE_COLUMN);
   }
   return (PDM_S_SUCCESS);
}

/*
   Loads n_citnos into the buffer
   avoids duplicates
*/

int    PDMload_citnos (user_id, bufr)
long   user_id;
MEMptr   bufr;
{
   int         a1, a2, a3, a4, a5, a6;
   int         i, nx, n_citno;
   char      **data, **column_ptr;
   char      s_citno[50];

   PDMdebug ("ENTER:PDMload_citnos\n");
   status = MEMbuild_array (bufr);
   if (status != MEM_S_SUCCESS)
   {
      sprintf (s, "MEMbuild_array failed status %d\n", 
      status); PDMdebug (s);
      sprintf (s, "user_id status %d\n", 
      user_id); PDMdebug (s);
      return (PDM_E_BUILD_ARRAY);
   }
   a1 = -1; a2 = -1; a3 = -1; 
   a4 = -1; a5 = -1; a6 = -1;
   data = (char **) bufr->data_ptr;
   column_ptr = (char **) bufr->column_ptr;
   for (i=0;i<bufr->columns;i++)
   {
      if (!strcmp (column_ptr[i], "n_catalogno"))         a1 = i;
      else if (!strcmp (column_ptr[i], "n_itemno"))       a2 = i;
      else if (!strcmp (column_ptr[i], "pn_catalogno"))   a3 = i;
      else if (!strcmp (column_ptr[i], "pn_itemno"))     a4 = i;
      else if (!strcmp (column_ptr[i], "p_citno"))        a5 = i;
      else if (!strcmp (column_ptr[i], "p_flag"))        a6 = i;
   }
   if (a1 == -1 || a2 == -1 || a3 == -1 ||
      a4 == -1 || a5 == -1 || a6 == -1)
   {
      PDMdebug ("Could not set offsets in bufr\n");
      return (PDM_E_BUFFER_FORMAT);
   }
   for (i=0;i<bufr->rows;i++)
   {
      nx = i * bufr->columns;
      if (strcmp (data[nx+a6], "D"))
      {
         status = PDMi_maxrow_no ("nfmsetcit", "n_citno", &n_citno);
         if (status != PDM_S_SUCCESS)
         {
            sprintf (s, "PDMi_maxrow_no failed status %d\n", 
            status); PDMdebug (s);
            return (status);
         }
         n_citno = n_citno + 1;
         s_citno[0] = '\0';
         sprintf (s_citno, "%d", n_citno);
         status = MEMwrite_data (bufr, s_citno, i+1, a5+1);
         if (status != MEM_S_SUCCESS)
         {
            sprintf (s, "MEMwrite_data failed status %d\n", 
            status); PDMdebug (s);
            return (PDM_E_WRITE_COLUMN);
         }         
      }
   }
   PDMdebug ("EXIT:PDMload_citnos\n");
   return (PDM_S_SUCCESS);
}

/*
   Inserts the set in buffer into nfmsetcit 
*/

int    PDMload_set_members (user_id, bufr)
long   user_id;
MEMptr   bufr;
{
   int   a1 = -1, a2 = -1, a3 = -1, a4 = -1, a5 = -1, a6 = -1;
   int         i,  nx, n_citno = 0;
   char      **data, **column_ptr;
   char      **cit_data;
   char      s_citno[50];
        char          dumb_str[2]="";
   char      sql_str[512];
        MEMptr         n_citno_bufr = NULL, dumb_list = NULL;
        char   *fname = "PDMload_set_members";
   char *msg = NULL;

   PDMdebug ("ENTER:PDMload_set_members\n");

        n_citno = user_id;
   status = MEMbuild_array (bufr);
   if (status != MEM_S_SUCCESS)
   {
      sprintf (s, "MEMbuild_array failed status %d\n", 
      status); PDMdebug (s);
      return (PDM_E_BUILD_ARRAY);
   }

   data = (char **) bufr->data_ptr;
   column_ptr = (char **) bufr->column_ptr;

   for (i=0;i<bufr->columns;i++)
   {
      if (!strcmp (column_ptr[i], "n_catalogno"))         a1 = i;
      else if (!strcmp (column_ptr[i], "n_itemno"))       a2 = i;
      else if (!strcmp (column_ptr[i], "pn_catalogno"))   a3 = i;
      else if (!strcmp (column_ptr[i], "pn_itemno"))     a4 = i;
      else if (!strcmp (column_ptr[i], "p_citno"))        a5 = i;
      else if (!strcmp (column_ptr[i], "p_flag"))        a6 = i;
   }
   if (a1 == -1 || a2 == -1 || a3 == -1 || 
      a4 == -1 || a5 == -1 || a6 == -1)
   {
      PDMdebug ("Could not set offsets in bufr\n");
      return (PDM_E_BUFFER_FORMAT);
   }
        n_citno = 0;


    /* Lock must be the first stmt in a transaction...MaC110593*/
      status = NFMstop_transaction (1200);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
        _PDMdebug (fname, "Stop Transaction : status = <0x%.8x>\n", status);
         return (status);
       }

      status = NFMstart_transaction (1200);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
        _PDMdebug (fname, "Start Transaction : status = <0x%.8x>\n", status);
         return (status);
       }

 
      sprintf (sql_str, "LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS) {
        status = _PDMget_db_error (status);
        if (status == PDM_I_TABLE_LOCKED)
        {
          PDMupdate_dots ();
          msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS_HOLD);
          UI_status (msg);
          while (sleep (30)) PDMupdate_dots ();
          sprintf (sql_str, "LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS)
            {
            status = _PDMget_db_error (status);
            if (status == PDM_I_TABLE_LOCKED)
              {
              PDMupdate_dots ();
              UI_status (msg);
              while (sleep (30)) PDMupdate_dots ();
              sprintf (sql_str, "LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
              status = SQLstmt (sql_str);
              if (status != SQL_S_SUCCESS)
                {
                status = _PDMget_db_error (status);
                if (status == PDM_I_TABLE_LOCKED)
                  {
                   PDMupdate_dots ();
                   UI_status (msg);
                   while (sleep (30)) PDMupdate_dots ();
                    sprintf (sql_str, "LOCK TABLES NFMINDEX IN EXCLUSIVE MODE");
                    status = SQLstmt (sql_str);
                    if (status != SQL_S_SUCCESS)
                      {
                       NFMrollback_transaction (0);
                       _PDMdebug (fname, 
                           "LOCK NFMINDEX failed status %d\n", status);
                       return (PDM_E_LOCK_CIT);
                       }
                     }
                     else
                      {
                       NFMrollback_transaction (0);
                       _PDMdebug (fname, 
                           "LOCK NFMINDEX failed status %d\n", status);
                       return (status);
                       }
                  }
               }
               else
                {
                 NFMrollback_transaction (0);
                 _PDMdebug (fname, "LOCK NFMINDEX failed status %d\n", status);
                 return (status);
                 }
           }
         }
          else
             {
              NFMrollback_transaction (0);
              _PDMdebug (fname, "LOCK NFMINDEX failed status %d\n", status);
              return (status);
             }
      }

     sql_str[0] = '\0';
     sprintf (sql_str, 
       "SELECT n_indexslot from NFMINDEX where n_tablename = 'nfmsetcit' or n_tablename = 'NFMSETCIT'" );
          status = SQLquery (sql_str, &n_citno_bufr, 512);
           if (status != SQL_S_SUCCESS)
           {
            _PDMdebug (fname, "NO entry in NFMIDEX table for nfmsetcit  - %d\n", 
                                                                       status);
            strcpy (sql_str, "select max (n_citno) from nfmsetcit");
            status = NFMretrieve_values (sql_str, 1, 
                              dumb_str, &n_citno, &dumb_list);
            if (status != NFM_S_SUCCESS)
             {
                NFMrollback_transaction (0);
               _PDMdebug (fname, "SQLquery (%s) 0x%.8x\n", sql_str, status);
                return (NFM_E_SQL_QUERY);
                }
               MEMclose (&dumb_list);
             n_citno++;
           }
          else
           {
            status = MEMbuild_array (n_citno_bufr);
            if (status != MEM_S_SUCCESS)
            {
             NFMrollback_transaction (0);
              MEMclose (&n_citno_bufr);
             _PDMdebug (fname, "MEMbuild_array status %d\n", status);
             return (status);
            }
/* data is already used... 
           data = (char **) n_citno_bufr->data_ptr;
          ... MaC 110593 */
           cit_data = (char **) n_citno_bufr->data_ptr;
           n_citno = atoi (cit_data[0]);
           }
         MEMclose (&n_citno_bufr);

      /* Update the citnos and pdcnos in the NFMINDEX table */
      _PDMdebug (fname, "N_CITNO %d\n", n_citno);
      sql_str[0] = '\0';
      sprintf (sql_str, 
      "UPDATE NFMINDEX SET n_indexslot = %d  WHERE n_tablename = 'nfmsetcit' ", 
      (n_citno + bufr->rows));
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS) {
         sprintf (sql_str, 
            "DELETE FROM NFMINDEX  WHERE n_tablename = 'nfmsetcit'");
         status = SQLstmt (sql_str);
         sprintf (sql_str, 
   "INSERT INTO NFMINDEX (n_indexslot, n_tablename) VALUES (%d, 'nfmsetcit') ", 
                                       (n_citno + bufr->rows));
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS) {
            status = NFMrollback_transaction (0);
            _PDMdebug (fname, 
              "Insert into NFMINDEX failed : status = <0x%.8x>\n", status);
            return (status);
           }
          }

      /* Release the lock on the NFMINDEXES TABLE */

      status = NFMstart_transaction (0);
      if (status != NFM_S_SUCCESS)
       {
         NFMrollback_transaction (0);
        _PDMdebug (fname, "Start Transaction : status = <0x%.8x>\n", status);
         return (status);
       }

       if (n_citno >= 2147483648) /* 2^31 - Two to the power of 31 */
        {
          _PDMdebug (fname, "Cleanup your CIT, by rearranging your data\n");
          return (PDM_E_LOCK_CIT);
        }

   data = (char **) bufr->data_ptr;

     
   for (i=0;i<bufr->rows;i++)
   {
      nx = i * bufr->columns;
      if (strcmp (data[nx+a6], "D"))
      {
         sprintf (s_citno, "%d", n_citno);
         status = MEMwrite_data (bufr, s_citno, i+1, a5+1);
         if (status != MEM_S_SUCCESS)
         {
            sprintf (s, "MEMwrite_data failed status %d\n", 
            status); PDMdebug (s);
            return (PDM_E_WRITE_COLUMN);
         }         
         sprintf (sql_str, "%s %s VALUES (%s, %s, %s, %s, %s, '%s')", 
         "INSERT INTO nfmsetcit ", 
         " (n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno, n_type)", 
          s_citno, data[nx+a3], data[nx+a4], 
          data[nx+a1], data[nx+a2], "S");
         status = SQLstmt (sql_str);
         if (status != SQL_S_SUCCESS)
         {
            sprintf (s, "SQLstmt failed status %d\n", status);
            PDMdebug (s);
            return (PDM_E_SQL_STMT);
         }
      }
                n_citno++;
   }
   PDMdebug ("EXIT:PDMload_set_members\n");
   return (PDM_S_SUCCESS);
}

int   PDMcheck_cycles (bufr)
MEMptr   bufr;
{
 
   int      a1, a2, a3, a4, a5, a6, a7;
   int      i, j, nx1, nx2;
   char       *fn = "PDMcheck_cycles";
   MEMptr   bufr1 = NULL;
   char    **data, **columns;
   char   sql_str[512];

   PDMdebug ("ENTER:PDMcheck_cycles\n");
   status = MEMbuild_array (bufr);
   if (status != MEM_S_SUCCESS)
   {
      sprintf (s, "MEMbuild_array failed status %d\n", 
      status); PDMdebug (s);
      return (PDM_E_BUILD_ARRAY);
   }
   a1 = -1; a2 = -1; a3 =  -1; 
   a4 = -1; a5 = -1; a6 = -1; a7 = -1;
   data = (char **) bufr->data_ptr;
   columns = (char **) bufr->column_ptr;
   for (i=0;i<bufr->columns;i++)
   {
      if (!strcmp (columns[i], "pn_catalogno"))        a1 = i;
      else if (!strcmp (columns[i], "pn_itemno"))      a2 = i;
      else if (!strcmp (columns[i], "n_catalogno"))      a3 = i;
      else if (!strcmp (columns[i], "n_itemno"))      a4 = i;
      else if (!strcmp (columns[i], "p_citno"))          a5 = i;
      else if (!strcmp (columns[i], "n_level"))          a6 = i;
          /* Added support for background attachment ...MaC 120193*/
      else if (!strcmp (columns[i], "p_incstr"))         a7 = i;
   }
   if (a1 == -1 || a2 == -1 || a3 == -1 ||
      a4 == -1 || a5 == -1 || a6 == -1)
   {
      PDMdebug ("Couldnot set offsets in bufr\n");
      return (PDM_E_BUFFER_FORMAT);
   }
   for (i=0;i<bufr->rows;i++)
   {
      nx1 = i * bufr->columns;
      for (j=0;j<bufr->rows;j++)
      {
         if (i != j)
         {
            nx2 = j * bufr->columns;
/*_PDMdebug (fn, "a7[%d] column [%s] val[%s]\n", a7, columns[a7], data[nx2+a7]);*/
            if (!strcmp (data[nx1+a1], data[nx2+a3]) &&
               !strcmp (data[nx1+a2], data[nx2+a4]) &&
               !strcmp (data[nx1+a3], data[nx2+a1]) &&
               !strcmp (data[nx1+a4], data[nx2+a2]) &&
          /* Added support for background attachment ...MaC 120193*/
               !strcmp (data[nx2+a7], "Y")) 
            {
               sprintf (s, "Cyclic entry found\n");
               PDMdebug (s);
               if (atoi (data[nx2+a6]) == 1)
                  return (PDM_E_CYCLIC_1STLEVEL);
               else
                  return (PDM_E_CYCLIC_NTHLEVEL);
            }
         }
      }
   }
   
   /*  need to check with the rest of the setcit info */

   for (i=0;i<bufr->rows;i++)
   {   
      nx1 = i * bufr->columns;
      sprintf (sql_str, "%s %s %s %s %s %s %s %s %s %s %s", 
      " SELECT n_citno FROM nfmsetcit, pdmcit ", 
      " WHERE n_pcatalogno = ", data[nx1+a3], 
      " AND n_pitemno = ", data[nx1+a4], 
      " AND n_ccatalogno = ", data[nx1+a1], 
      " AND n_citemno = ", data[nx1+a2], 
                " AND pdmcit.p_citno = nfmsetcit.n_citno", 
                " AND (pdmcit.p_incbom = 'Y' OR pdmcit.p_incbom = 'A') ");
      status = SQLquery (sql_str, &bufr1, 1024);
      if (status != SQL_S_SUCCESS)
      {
         if (status == SQL_I_NO_ROWS_FOUND)
         {
         }
         else
         {
            MEMclose (&bufr1);
            sprintf (s, "SQLquery failed status %d\n", 
            status);  PDMdebug (s);
            return (PDM_E_SQL_QUERY);
         }
      }
      else
      {
         MEMclose (&bufr1);
/* MJG - 3/8/95 - Only return error if p_incstr = Y */
         if (strcmp (data[nx1+a7], "Y") == 0) 
           {
           PDMdebug ("p_incstr is YES\n");
           PDMdebug ("Cyclic Entry Found\n");
           if (atoi (data[nx1+a6]) == 1)
              return (PDM_E_CYCLIC_1STLEVEL);
           else
              return (PDM_E_CYCLIC_NTHLEVEL);
           }
      }
   }
   PDMdebug ("EXIT:PDMcheck_cycles\n");
   return (PDM_S_SUCCESS);
}
