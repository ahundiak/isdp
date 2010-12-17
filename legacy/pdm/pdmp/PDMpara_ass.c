#include<stdio.h>
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "MEMstruct.h" 
#include "NFMapi.h" 
#include "PDUerror.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"

extern int      PDMdebug_on;

extern char     PDM_DEBUG_FILE[];
extern PDMexec_ptr PDMexec;

#define NFM_RETURN_VALUE 1

long PDMdefine_parametric_assembly (para_ass, para_ass_dynamic) 

MEMptr para_ass;
MEMptr para_ass_dynamic;
/***
 
  This function is used to define a n-level parametric sub-assembly during

  checkin.

  CHANGE HISTORY:
    09/21/92  Kumar 

***/

{

  char *fname="PDMdefine_parametric_assembly";
  char sql_str[2048], dumb_str[2], p_assembly[10], item_no[5];
  char **columns,**data, **cat_data, **cit_data;
  char pre_str[1024],post_str[1024], ref_catalog[40], temp_catalog[40];
  char p_cat[21],p_part[241],p_rev[41],c_cat[21],c_part[241],c_rev[41], *pdc_table, type[6];
  int or, i,xx, yx,nx,k, kx, x, y, z, index, index1, set_index, slot;
  short a1=0,a2=0,a3=0,a4=0,a5=0,a6=0,a7=0,a8=0,a9=0,a10=0,a11=0,a12=0;
  short a13=0,a14=0,a15=0,a16=0,a17=0,a18=0;
  short a19=0,a20=0,a21=0,a22=0,a23=0;
  int added, p_pdcno, pdcno, catno, c_item_no, duplicate = 0, p_citno = 0;
  long status;
  MEMptr cit_bufr = NULL, list=NULL, dumb_list=NULL;

  _PDMdebug (fname, "ENTER:\n");

 /* Init vars MaC 051393 */
   p_cat[0] = '\0';
   p_part[0] = '\0';
   p_rev[0] = '\0';
   c_cat[0] = '\0';
   c_part[0] = '\0';
   c_rev[0] = '\0';
   pre_str[0] = '\0';
   post_str[0] = '\0';
   sql_str[0] = '\0';
   dumb_str[0] = '\0';
   ref_catalog[0] = '\0';
   temp_catalog[0] = '\0';

    status = SQLstmt ("SET TRANSACTION AUTOCOMMIT ON");
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      NFMrollback_transaction (1200);
      _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
      return (NFM_E_SQL_STMT);
    }

   if(PDMdebug_on)
      {
   MEMprint_buffer("parametric_assembly bufr",para_ass,PDM_DEBUG_FILE);
  if (para_ass_dynamic)
   MEMprint_buffer("parametric_assembly bufr dynamic info",para_ass_dynamic,PDM_DEBUG_FILE);
      }


  status = MEMbuild_array (para_ass);   
  if (status != MEM_S_SUCCESS) {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }

       columns = (char **) para_ass->column_ptr;
       data = (char **) para_ass->data_ptr;

        for(i=0;i<para_ass->columns;i++)
        {
             if(!strcmp(columns[i],"p_structureno"))    a1 = i;
        else    if(!strcmp(columns[i],"p_level"))          a2 = i;
        else    if(!strcmp(columns[i],"pn_catalogname"))   a3 = i;
        else    if(!strcmp(columns[i],"pn_itemname"))      a4 = i;
        else    if(!strcmp(columns[i],"pn_itemrev"))       a5 = i;
        else    if(!strcmp(columns[i],"n_pcatalogno"))     a6 = i;
        else    if(!strcmp(columns[i],"n_pitemno"))        a7 = i;
        else    if (!strcmp(columns[i], "n_catalogname"))  a8 = i;
        else    if (!strcmp(columns[i], "n_itemname"))     a9 = i;
        else    if (!strcmp(columns[i], "n_itemrev"))      a10 = i;
        else    if (!strcmp(columns[i], "n_ccatalogno"))    a11 = i;
        else    if (!strcmp(columns[i], "n_citemno"))      a12 = i;
        else    if (!strcmp(columns[i], "p_quantity"))     a13 = i;
        else    if (!strcmp(columns[i], "p_history"))      a14 = i;
        else    if (!strcmp(columns[i], "p_childno"))      a15 = i;
        else    if (!strcmp(columns[i], "p_usageid"))      a16 = i;
        else    if (!strcmp(columns[i], "p_tagno"))        a17 = i;
        else    if (!strcmp(columns[i], "p_alttagno"))     a18 = i;
        else    if (!strcmp(columns[i], "p_incbom"))       a19 = i;
        else    if (!strcmp(columns[i], "p_explode"))      a20 = i;
        else    if (!strcmp(columns[i], "p_attached"))     a21 = i;
        else    if (!strcmp(columns[i], "n_cofilename"))   a22 = i;
        else    if (!strcmp(columns[i], "p_dyndataindex"))   a23 = i;
        }
    
  /* go down the list and retrieve catalog numbers for new members, if they 
     are not given. */

  strcpy (sql_str, "select n_catalogname, n_catalogno from nfmcatalogs where ");

  or = 0;

  for (x = 0; x < para_ass->rows; x ++)
  {
    nx = x  * para_ass->columns;

    if ( (!strcmp(data[nx+a6],"")) || (data[nx+a6]== NULL) || (atoi (data[nx+a6])) < 1 )
    {
      if (or)
        strcat (sql_str, " or ");
      else
        or = 1;
      strcat (sql_str, "n_catalogname = '");
      strcat (sql_str, data[nx + a3] );
      strcat (sql_str, "'");
    } 
    if ( (!strcmp(data[nx+a11],"")) || (data[nx+a11]== NULL) || (atoi (data[nx+a11])) < 1 )
    {
      if (or)
        strcat (sql_str, " or ");
      else
        or = 1;
      strcat (sql_str, "n_catalogname = '");
      strcat (sql_str, data[nx + a8] );
      strcat (sql_str, "'");
    } 
  }
  status = SQLquery (sql_str, &list, 512);
  if (status != SQL_S_SUCCESS)
  {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "SQLquery (%s) 0x%.8x\n", sql_str, status);
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (1200);
    MEMclose (&list);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }

  cat_data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x ++)
  {
    index = list->columns * x;
    _PDMdebug (fname, "catalog_name [%s] catalog_no [%s]\n",
                        cat_data[index], cat_data[index+1]);
    for (y = 0; y < para_ass->rows; y ++)
    {
      yx = y * para_ass->columns;
      if (!strcmp(cat_data[index],data[yx+a3]))
      {
         status = MEMwrite_data(para_ass,cat_data[index+1],y+1, a6+1);
          if(status != MEM_S_SUCCESS)
           {
           NFMrollback_transaction (1200);
           _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
            return (status);
           }
        _PDMdebug (fname, "Found match, cat_name [%s] cat_no [%s]\n",
                   data[yx+a3], data[yx+a6]);
      }
       status = MEMbuild_array (para_ass);   
        if (status != MEM_S_SUCCESS) {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
          }

       columns = (char **) para_ass->column_ptr;
       data = (char **) para_ass->data_ptr;
    }

  for (y = 0; y < para_ass->rows; y ++)
    {
      yx = y * para_ass->columns;
      if (!strcmp(cat_data[index],data[yx+a8]))
      {
         status = MEMwrite_data(para_ass,cat_data[index+1],y+1, a11+1);
          if(status != MEM_S_SUCCESS)
           {
           NFMrollback_transaction (1200);
           _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
            return (status);
           }
        _PDMdebug (fname, "Found match, cat_name [%s] cat_no [%s]\n",
                   data[yx+a8], data[yx+a11]);
      }

  status = MEMbuild_array (para_ass);   
  if (status != MEM_S_SUCCESS) {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }

       columns = (char **) para_ass->column_ptr;
       data = (char **) para_ass->data_ptr;
     }
    }

   if(PDMdebug_on)
      MEMprint_buffer("parametric_assembly bufr",para_ass,PDM_DEBUG_FILE);
  status = MEMbuild_array (para_ass);   
  if (status != MEM_S_SUCCESS) {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }
       columns = (char **) para_ass->column_ptr;
       data = (char **) para_ass->data_ptr;
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
    return (status);
  }
  /* go down the structure, retrieve the item number for the new members */

  sprintf (pre_str, "select n_itemname, n_itemrev, n_itemno from");
  for (x = 0; x < para_ass->rows; x++)
  {
     xx = x * para_ass->columns;
    if ( atoi(data[xx+a7]) < 1)
    {
      post_str[0] ='\0';
      sprintf (post_str, "(%s '%s' and %s '%s')", 
               "n_itemname =", data[xx+a4],
               "n_itemrev =", data[xx+a5]);

      status = PDMget_catno_type(data[xx+a3], &catno, type);
      if(status != SQL_S_SUCCESS) strcpy(type,"C");
        
      sql_str[0] = '\0';
     if(!strcmp(type,"EID") || !strcmp(type,"CID"))
      {
      sprintf (sql_str,  "%s e_%s %s %s",
             pre_str, data[xx+a3], "where", post_str);
       }
      else
        {
      sprintf (sql_str,  "%s %s %s %s",
             pre_str, data[xx+a3], "where", post_str);
         }
       

      _PDMdebug (fname, "exec qry: %s\n", sql_str);

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if (status != SQL_S_SUCCESS)
      {
        if(!strcmp(type,"EID") || !strcmp(type,"CID"))
        {
         status = PDMquery_itemno_assind (data [xx+a3],
          data [xx + a4], data [xx + a5], type, p_assembly, &c_item_no);
              if (status != PDM_S_SUCCESS)
               {
         _PDMdebug (fname, "Get Item No : status = <0x%.8x>\n", status);
          NFMrollback_transaction (1200);
        _PDMdebug (fname, "PDMquery_itemno_assind (%s) 0x%.8x\n", sql_str, status);
         return (status);
                 }
        for (y = x; y < para_ass->rows; y ++)
        {
             yx = y * para_ass->columns;
          if (atoi(data[yx + a7]) < 1 &&
              atoi(data[yx +a6]) == atoi (data[xx+ a6]) &&
              !strcmp (data[yx+a4], data[xx+a4]) &&
              !strcmp (data[yx+a5], data[xx+a5]) )
          {
          sprintf(item_no, "%d", c_item_no);
         status = MEMwrite_data(para_ass,item_no,y+1, a7+1);
          if(status != MEM_S_SUCCESS)
           {
           NFMrollback_transaction (1200);
           _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
            return (status);
           }
            status = MEMbuild_array (para_ass);   
              if (status != MEM_S_SUCCESS) {
              NFMrollback_transaction (1200);
               _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
                    return (status);
               }
       columns = (char **) para_ass->column_ptr;
       data = (char **) para_ass->data_ptr;
          }
         }
          MEMclose(&list); continue;
        }
         else
          {
        NFMrollback_transaction (1200);
        _PDMdebug (fname, "SQLquery (%s) 0x%.8x\n", sql_str, status);
        return (status);
          }
      }
      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        NFMrollback_transaction (1200);
        _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", status);
        return (status);
      }
      cat_data = (char **) list->data_ptr;
      for (z = 0; z < list->rows; z ++)
      {
        index = list->columns * z;
        for (y = x; y < para_ass->rows; y ++)
        {
             yx = y * para_ass->columns;
          if (atoi(data[yx + a7]) < 1 &&
              atoi(data[yx +a6]) == atoi (data[xx+ a6]) &&
              !strcmp (data[yx+a4], cat_data[index]) &&
              !strcmp (data[yx+a5], cat_data[index+1]) ) 
          {
         status = MEMwrite_data(para_ass,cat_data[index+2],y+1, a7+1);
          if(status != MEM_S_SUCCESS)
           {
           NFMrollback_transaction (1200);
           _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
            return (status);
           }
          }
          status = MEMbuild_array (para_ass);   
           if (status != MEM_S_SUCCESS) {
             NFMrollback_transaction (1200);
            _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
            return (status);
             }
            columns = (char **) para_ass->column_ptr;
            data = (char **) para_ass->data_ptr;
        }
      }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
      {
        NFMrollback_transaction (1200);
        _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", status);
        return (status);
      }
    }
    if ( atoi(data[xx+a12]) < 1)
    {
       post_str[0] = '\0';
      sprintf (post_str, "(%s '%s' and %s '%s')", 
               "n_itemname =", data[xx+a9],
               "n_itemrev =", data[xx+a10]);

        status = PDMget_catno_type(data[xx+a8], &catno, type);
         if(status != SQL_S_SUCCESS) strcpy(type,"C");
        sql_str[0] = '\0';

        if(!strcmp(type,"EID") || !strcmp(type,"CID"))
      sprintf (sql_str,  "%s e_%s %s %s",
             pre_str, data[xx+a8], "where", post_str);
        else
      sprintf (sql_str,  "%s %s %s %s",
             pre_str, data[xx+a8], "where", post_str);

      _PDMdebug (fname, "exec qry: %s\n", sql_str);

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if (status != SQL_S_SUCCESS)
       {
        if(!strcmp(type,"EID") || !strcmp(type,"CID"))
        {
         status = PDMquery_itemno_assind (data [xx+a8],
          data [xx + a9], data [xx + a10], type, p_assembly, &c_item_no);
              if (status != PDM_S_SUCCESS)
               {
         _PDMdebug (fname, "Get Item No : status = <0x%.8x>\n", status);
          NFMrollback_transaction (1200);
        _PDMdebug (fname, "PDMquery_itemno_assind (%s) 0x%.8x\n", sql_str, status);
         return (status);
                }
        for (y = x; y < para_ass->rows; y ++)
        {
             yx = y * para_ass->columns;
          if (atoi(data[yx + a12]) < 1 &&
              atoi(data[yx +a11]) == atoi (data[xx+ a11]) &&
              !strcmp (data[yx+a9], data[xx+a9]) &&
              !strcmp (data[yx+a10], data[xx+a10]) )
          {
          sprintf(item_no, "%d", c_item_no);
         status = MEMwrite_data(para_ass,item_no,y+1, a12+1);
          if(status != MEM_S_SUCCESS)
           {
           NFMrollback_transaction (1200);
           _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
            return (status);
           }
            status = MEMbuild_array (para_ass);   
              if (status != MEM_S_SUCCESS) {
              NFMrollback_transaction (1200);
               _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
                    return (status);
               }
           columns = (char **) para_ass->column_ptr;
           data = (char **) para_ass->data_ptr;
           
          }
         }
          MEMclose(&list); continue;
        }
         else
          {
        NFMrollback_transaction (1200);
        _PDMdebug (fname, "SQLquery (%s) 0x%.8x\n", sql_str, status);
        return (status);
          }
      }
      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        NFMrollback_transaction (1200);
        _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", status);
        return (status);
      }
      cat_data = (char **) list->data_ptr;
      for (z = 0; z < list->rows; z ++)
      {
        index = list->columns * z;
        for (y = x; y < para_ass->rows; y ++)
        {
             yx = y * para_ass->columns;
          if (atoi(data[yx + a12]) < 1 &&
              atoi(data[yx +a11]) == atoi (data[xx+ a11]) &&
              !strcmp (data[yx+a9], cat_data[index]) &&
              !strcmp (data[yx+a10], cat_data[index+1]) ) 
          {
         status = MEMwrite_data(para_ass,cat_data[index+2],y+1, a12+1);
          if(status != MEM_S_SUCCESS)
           {
           NFMrollback_transaction (1200);
           _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
            return (status);
           }
          }
  status = MEMbuild_array (para_ass);   
  if (status != MEM_S_SUCCESS) {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }
  columns = (char **) para_ass->column_ptr;
       data = (char **) para_ass->data_ptr;
        }
      }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
      {
        NFMrollback_transaction (1200);
        _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", status);
        return (status);
      }
    }
  }  

  status = NFMlock_table ("nfmsetcit");
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "NFMlock_table (nfmsetcit) 0x%.8x\n", status);
    return (status);
  }
 
   if(PDMdebug_on)
      MEMprint_buffer("parametric_assembly bufr",para_ass,PDM_DEBUG_FILE);
  status = MEMbuild_array (para_ass);   
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }
       columns = (char **) para_ass->column_ptr;
       data = (char **) para_ass->data_ptr;

   if(para_ass_dynamic != NULL)
    {
       status = PDMi_maxrow_no("pdmcit", "p_pdcno", &p_pdcno);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug(fname, "PDMi_maxrow_no failed status %d\n", status);
                return (status);
        }

     }

  for (x = added = 0; x < para_ass->rows ; x ++)
  {
    set_index = x * para_ass->columns;
      /* while the structure no is the current structure no */
 if (data[set_index +a3 ] == NULL || !strcmp(data[set_index + a3],"")) continue;

     /* for all children with the same parent */

          strcpy(p_cat,data[set_index+a3]);
          strcpy(p_part,data[set_index+a4]);
          strcpy(p_rev,data[set_index+a5]);
    for (k = x; k < para_ass->rows; k++)
    {
           kx = k * para_ass->columns;
     if (data[kx + a3] == NULL || !strcmp(data[kx+a3],"")) continue;
     if ((!strcmp(data[set_index+a3], data[kx+a3])) &&
         (!strcmp(data[set_index+a4], data[kx+a4])) &&
         (!strcmp(data[set_index+a5], data[kx+a5])) )
       {
          strcpy(c_cat,data[kx+a8]);
          strcpy(c_part,data[kx+a9]);
          strcpy(c_rev,data[kx+a10]);
    _PDMdebug (fname, "Defining parent <%s> <%s> <%s> -> child <%s> <%s> <%s> relationship  \n", p_cat,p_part,p_rev, c_cat,c_part,c_rev);
      /* if (data[kx+a3]) free (data[kx+a3]); data[kx+a3] = NULL; */
      if (data[kx+a3]) strcpy(data[kx+a3],"");
      sprintf (sql_str, "%s '%s'",
               "select min(n_indexslot) from nfmindex where n_tablename =",
               "nfmsetcit");
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
               &slot, &dumb_list);
      if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
      {
        NFMrollback_transaction (1200);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_QUERY); 
      }
   
      if (slot < 1)
      {
        strcpy (sql_str, "select max(n_citno) from nfmsetcit");
        status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                   &slot, &list);
        if (status != NFM_S_SUCCESS)
        {
          NFMrollback_transaction (1200);
          _PDMdebug (fname, "SQLquery(%s) 0x%.8x\n", sql_str, status);
          return (NFM_E_SQL_QUERY);
        }
        slot++;
       }
      else
      {
        sprintf (sql_str, "%s %d",
                 "delete from nfmindex where n_indexslot =", slot);
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          NFMrollback_transaction (1200);
          _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
          return (NFM_E_SQL_STMT);
        }
      }
      duplicate = 0;
      sql_str[0] = '\0';
      sprintf (sql_str, "%s %s %d, %s, %s, %s, %s, 'S' %s",
               "insert into nfmsetcit (n_citno, n_pcatalogno, n_pitemno,",
               "n_ccatalogno, n_citemno, n_type) values (",
            slot, data[set_index+a6], data[set_index+a7], data[kx + a11],
               data[kx+a12], ")");
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        if(status == SQL_E_DUPLICATE_VALUE)
           {
          duplicate = 1;
          sql_str[0] = '\0';
      sprintf (sql_str, "select n_citno, p_childno, p_pdcno from nfmsetcit,pdmcit where nfmsetcit.n_pcatalogno = %s and nfmsetcit.n_pitemno = %s and nfmsetcit.n_ccatalogno = %s and nfmsetcit.n_citemno =  %s ", data[set_index+a6], data[set_index+a7], data[kx + a11], data[kx+a12]);
      status = SQLquery (sql_str, &cit_bufr, 512);
           if(status == SQL_S_SUCCESS)
            {
          MEMbuild_array(cit_bufr);
           cit_data = (char **) cit_bufr->data_ptr;
           p_citno = atoi(cit_data[0]);
             }
           MEMclose(&cit_bufr);
           }
           else
           {
        NFMrollback_transaction (1200);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_STMT);
           }
      }
       if(!strcmp(data[set_index+a23],"")) pdcno = 0;
       else 
          {
           p_pdcno++;
           pdcno = p_pdcno ;
           }
        ref_catalog[0] = '\0';
         if(!strcmp(temp_catalog, data[set_index+a8]));
        else
        {
        strcpy (ref_catalog, PDMexec->catalog);
        strcpy (PDMexec->catalog, data[set_index+a8]);
        strcpy (temp_catalog, data[set_index+a8]);

        status = PDMdyntable_for_catalog(&pdc_table);
        if (status != PDM_S_SUCCESS) {
               strcpy (PDMexec->catalog, ref_catalog);
            _PDMdebug (fname, "PDMdyntable_for_catalog status = <%d>\n", status);
            return (status);
        }
       if (pdc_table)
          _PDMdebug (fname, "dynamic_table [%s]\n", pdc_table);
      

        strncpy (PDMexec->catalog, ref_catalog,20);
       }
       if (duplicate == 1)
       {
          sql_str[0] = '\0';
      sprintf (sql_str, "select  p_childno, p_pdcno from pdmcit where p_citno = %d and p_childno = %s  ",  p_citno, data[kx+a15]);
      status = SQLquery (sql_str, &cit_bufr, 512);
           if(status == SQL_S_SUCCESS)
             {
           MEMclose(&cit_bufr);
              continue;
             }
            else
             {
             MEMclose(&cit_bufr);
       sql_str[0] = '\0';
      sprintf (sql_str, "insert into pdmcit (p_citno, p_quantity, p_history,p_childno, p_usageid, p_tagno, p_alttagno, p_incbom, p_explode, p_attached, n_cofilename, n_catalogname, n_itemname, n_itemrev, p_pdcno) VALUES (%d, %s, '%s', %s, '%s',%s, '%s','%s','%s','%s','%s','%s','%s','%s', %d)", p_citno, data[kx+a13], data[kx+a14],data[kx+a15],data[kx+a16],data[kx+a17],data[kx+a18],data[kx+a19],data[kx+a20],data[kx+a21],data[kx+a22],data[kx+a8],data[kx+a9],data[kx+a10], pdcno);
             } 
      }
      else
      sprintf (sql_str, "insert into pdmcit (p_citno, p_quantity, p_history,p_childno, p_usageid, p_tagno, p_alttagno, p_incbom, p_explode, p_attached, n_cofilename, n_catalogname, n_itemname, n_itemrev, p_pdcno) VALUES (%d, %s, '%s', %s, '%s',%s, '%s','%s','%s','%s','%s','%s','%s','%s', %d)", slot, data[kx+a13], data[kx+a14],data[kx+a15],data[kx+a16],data[kx+a17],data[kx+a18],data[kx+a19],data[kx+a20],data[kx+a21],data[kx+a22],data[kx+a8],data[kx+a9],data[kx+a10], pdcno);
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction (1200);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_STMT);
      }

   if(para_ass_dynamic != NULL)
    {
     /* temp_para_ass_dynamic = para_ass_dynamic; */
        status = MEMreset_buffer_no(para_ass_dynamic, (atoi(data[set_index+a23]) ));
      if (status != MEM_S_SUCCESS) {
        _PDMdebug(fname, "MEMreset_buffer_no failed status %d\n", status);
            return (PDM_E_RESET_BUFFER);
                }
     /*  if (PDMdebug_on)
      MEMprint_buffer("para_ass_dynamic",para_ass_dynamic,PDM_DEBUG_FILE); */
/* Fix added to if there is no dynamic table associated. MaC 071294 */
      if (pdc_table) {
        status = PDMinsert_nthlevel_dynamic_info (pdcno, pdc_table, 
                                                     para_ass_dynamic);
        if (status != PDM_S_SUCCESS) {
           _PDMdebug(fname, 
             "PDMinsert_nthlevel_dynamic_info failed status %s\n", status);
           return (PDM_E_COPY_BUFFER);
           }
         }
       /*  para_ass_dynamic = temp_para_ass_dynamic; */
     }
      for (index = k+1 ; index< para_ass->rows; index++)
         {
          index1 = index * para_ass->columns;
       /* if same parent and child combination */
     if (data[index1+a3] != NULL && strcmp(data[index1+a3],"") &&
    (!strcmp (data[set_index+a3], data[index1+a3])) && 
    (!strcmp(data[set_index+a4], data[index1+a4])) && 
    (!strcmp(data[set_index+a5],data[index1+a5])) && 
    (!strcmp(data[kx+a8],data[index1+a8])) && 
    (!strcmp(data[kx+a9],data[index1+a9])) &&
   (!strcmp (data[kx+a10],data[index1+a10])) )
                 {
    _PDMdebug (fname, "Defining <%d> parent <%s> <%s> <%s> -> child < %s > <%s> <%s> <%s> relationship  \n", slot, p_cat,p_part,p_rev, data[index1+a15],c_cat,c_part,c_rev);
   /* if(data[index1+a3]) free (data[index1*a3]) ; data[index1*a3] = NULL ;*/
   if(data[index1+a3]) strcpy(data[index1*a3],"") ;
       if(!strcmp(data[index1+a23],"")) pdcno = 0;
       else 
          {
           p_pdcno++;
          pdcno = p_pdcno ;
          }
        ref_catalog[0] = '\0';
        if(!strcmp(temp_catalog, data[index1+a8]));
        else
        {
        strcpy (ref_catalog, PDMexec->catalog);
        strncpy (PDMexec->catalog, data[index1+a8], 20);
        strcpy (temp_catalog, data[index1+a8]);

        status = PDMdyntable_for_catalog(&pdc_table);
        if (status != PDM_S_SUCCESS) {
               strcpy (PDMexec->catalog, ref_catalog);
            _PDMdebug (fname, "PDMdyntable_for_catalog status = <%d>\n", status);
            return (status);
        }

       if (pdc_table)
       _PDMdebug (fname, "dynamic_table [%s]\n", pdc_table);

        strncpy (PDMexec->catalog, ref_catalog, 20);
        }
      if(duplicate == 1)
       {
          sql_str[0] = '\0';
      sprintf (sql_str, "select  p_childno, p_pdcno from pdmcit where p_citno = %d and p_childno = %s  ",  p_citno, data[kx+a15]);
      status = SQLquery (sql_str, &cit_bufr, 512);
           if(status == SQL_S_SUCCESS)
             {
           MEMclose(&cit_bufr);
              continue;
             }
            else
             {
      sprintf (sql_str, "insert into pdmcit (p_citno, p_quantity, p_history,p_childno, p_usageid, p_tagno, p_alttagno, p_incbom, p_explode, p_attached, n_cofilename, n_catalogname, n_itemname, n_itemrev, p_pdcno) VALUES (%d, %s, '%s', %s, '%s',%s, '%s','%s','%s','%s','%s','%s','%s','%s', %d)", p_citno, data[kx+a13], data[kx+a14],data[kx+a15],data[kx+a16],data[kx+a17],data[kx+a18],data[kx+a19],data[kx+a20],data[kx+a21],data[kx+a22],data[kx+a8],data[kx+a9],data[kx+a10], pdcno);
              } 
      }
      else
        {
      sprintf (sql_str, "insert into pdmcit (p_citno, p_quantity, p_history,p_childno, p_usageid, p_tagno, p_alttagno, p_incbom, p_explode, p_attached, n_cofilename, n_catalogname, n_itemname, n_itemrev, p_pdcno) VALUES (%d, %s, '%s', %s, '%s',%s, '%s','%s','%s','%s','%s','%s','%s','%s', %d)", slot, data[index1+a13], data[index1+a14],data[index1+a15],data[index1+a16],data[index1+a17],data[index1+a18],data[index1+a19],data[index1+a20],data[index1+a21],data[index1+a22],data[index1+a8],data[index1+a9],data[index1+a10], pdcno);
         }
                     status = SQLstmt (sql_str);
                     if (status != SQL_S_SUCCESS)
                     {
                      NFMrollback_transaction (1200);
                    _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
                     return (NFM_E_SQL_STMT);
                     }
           /* Insert the corresponding dynamic attribute info */
    if(para_ass_dynamic != NULL)
    {
 status = MEMreset_buffer_no(para_ass_dynamic, (atoi(data[index1+a23]) + 1));
      if (status != MEM_S_SUCCESS) {
        _PDMdebug(fname, "MEMreset_buffer_no failed status %d\n", status);
            return (PDM_E_RESET_BUFFER);
                }
         if (PDMdebug_on) {
         MEMprint_buffer("para_ass_dynamic",para_ass_dynamic,PDM_DEBUG_FILE);
          }
         if (pdc_table) {
          status = PDMinsert_nthlevel_dynamic_info (pdcno, pdc_table, 
                                                         para_ass_dynamic);
          if (status != PDM_S_SUCCESS) {
           _PDMdebug(fname, 
             "PDMinsert_nthlevel_dynamic_info failed status %s\n", status);
           return (PDM_E_COPY_BUFFER);
           }
         }
     }

                  } /* If it is same parent and child */
             } /* for same parent and child combination */
      sprintf (sql_str, "update %s set n_setindicator = 'Y' where n_itemno = %s", p_cat,data[set_index+a7]);
             status = SQLstmt (sql_str);
             if (status != SQL_S_SUCCESS)
              {
              NFMrollback_transaction (1200);
              _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
               return (NFM_E_SQL_STMT);
              }
         } /* If there are any other row with parent cat,part,rev */
      }/* For all children with same parent */

      added = 1;
   } /* For all the rows in the bufr */

  _PDMdebug (fname, "EXIT: successful 0x%.8x\n", PDM_S_SUCCESS);
  return (PDM_S_SUCCESS);
}




long PDMdefine_support_libraries
(
char  *macro_cat,
char  *macro_part,
char  *macro_rev,
MEMptr macro_ass
)
/***
  This function is used to define the support libraries for a given
  macro library.
  CHANGE HISTORY:
    09/21/92  Kumar 
***/
{
  char *fname="PDMdefine_support_libraries";
  char sql_str[1024], dumb_str[2];
  char **columns,**data, **cat_data;
  char **cit_col, **cit_data;
  char citno_list[1024];
  int  cit_index;
  MEMptr citno_bufr = NULL;
  char pre_str[1024],post_str[1024];
  int or, i,xx, yy, yx,nx, x, y, z, index, set_index, slot;
  short a8=0,a9=0,a10=0,a11=0,a12=0;
  int added, child_no=0;
  int catalog_no = -1, item_no = -1;
  int CatalogNo = -1, PartNo = -1;
  long status;
  MEMptr list=NULL, dumb_list=NULL;

  _PDMdebug (fname, "ENTER:\n");

_PDMdebug (fname, "ENTER: catalog[%s ] macro[%s.%s] define [%d] members ",
                      macro_cat, macro_part, macro_rev, macro_ass->rows);
  if (PDMdebug_on)
       MEMprint_buffer("macro_ass",macro_ass,PDM_DEBUG_FILE);

  status = PDMris_get_pitemno(&item_no,macro_cat,macro_part,macro_rev);
     if(status != SQL_S_SUCCESS)
      {
    _PDMdebug (fname, "PDMris_get_pitemno 0x%.8x\n", status);
    return (status);
      }

  PartNo = item_no;
  
  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _PDMdebug (fname, "NFMstop_transaction 0x%.8x\n", status);
    return (status);
  }

  status = MEMbuild_array (macro_ass);   
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }
       columns = (char **) macro_ass->column_ptr;
       data = (char **) macro_ass->data_ptr;
        for(i=0;i<macro_ass->columns;i++)
        {
                if (!strcmp(columns[i], "n_catalogname"))  a8 = i;
        else    if (!strcmp(columns[i], "n_itemname"))     a9 = i;
        else    if (!strcmp(columns[i], "n_itemrev"))      a10 = i;
        else    if (!strcmp(columns[i], "n_catalogno"))    a11 = i;
        else    if (!strcmp(columns[i], "n_itemno"))       a12 = i;
        }
    
  /* go down the list and retrieve catalog numbers for new members, if they 
     are not given. */

  strcpy (sql_str, "select n_catalogname, n_catalogno from nfmcatalogs where ");

  or = 0;
  if (catalog_no < 1)
  {
    strcat (sql_str, "n_catalogname = '");
    strcat (sql_str, macro_cat);
    strcat (sql_str, "'");
    or = 1;
  }
  for (x = 0; x < macro_ass->rows; x ++)
  {
    nx = x  * macro_ass->columns;
    if ( atoi (data[nx+a11]) < 1 )
    {
      if (or)
        strcat (sql_str, " or ");
      else
        or = 1;
      strcat (sql_str, "n_catalogname = '");
      strcat (sql_str, data[nx + a8] );
      strcat (sql_str, "'");
    } 
  }

 _PDMdebug ("sql_str", "%s\n", sql_str);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _PDMdebug (fname, "SQLquery (%s) 0x%.8x\n", sql_str, status);
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    MEMclose (&list);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }

  cat_data = (char **) list->data_ptr;

/* Update catalognos in the buffer */
  for (x = 0; x < list->rows; x ++)
  {
    index = list->columns * x;
    _PDMdebug (fname, "catalog_name [%s] catalog_no [%s]\n",
                        cat_data[index], cat_data[index+1]);
    for (y = 0; y < macro_ass->rows; y ++)
    {
      yx = y * macro_ass->columns;
      if (!strcmp(cat_data[index],data[yx+a8]))
      {
         status = MEMwrite_data(macro_ass,cat_data[index+1],y+1, a11+1);
          if(status != MEM_S_SUCCESS)
           {
           NFMrollback_transaction (0);
           _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
            return (status);
           }
        _PDMdebug (fname, "Found match, cat_name [%s] cat_no [%s]\n",
                   data[yx+a8], data[yx+a11]);
      }
    }
      if ((catalog_no < 1)  && (!strcmp(cat_data[index], macro_cat))) {
        _PDMdebug (fname, "Found parent mac cat [%s]\n", cat_data[index]);
        catalog_no = atol (cat_data[index+1]);
      }
  }
  CatalogNo = catalog_no;

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
    return (status);
  }
  _PDMdebug (fname, "Catalognos updated in the buffer\n");
  if (PDMdebug_on)
       MEMprint_buffer("macro_ass",macro_ass,PDM_DEBUG_FILE);
  status = MEMbuild_array (macro_ass);   
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }
       columns = (char **) macro_ass->column_ptr;
       data = (char **) macro_ass->data_ptr;

  /* go down the structure, retrieve the item number for the new members */

  sprintf (pre_str, "select n_itemname, n_itemrev, n_itemno from");
  for (x = 0; x < macro_ass->rows; x++)
  {
     xx = x * macro_ass->columns;
    if ( atoi(data[xx+a12]) < 1)
    {
      sprintf (post_str, "(%s '%s' and %s '%s')", 
               "n_itemname =", data[xx+a9],
               "n_itemrev =", data[xx+a10]);
      for (y = x + 1; y < macro_ass->rows; y ++)
      {
          yy = y * macro_ass->columns;
        _PDMdebug (fname, "Try to group, item_name [%s] cat_no [%s]\n",
                   data[xx+a9], data[xx+a11]);
        if (atoi(data[yy+a12]) < 1 &&
            atoi(data[yy+a11]) == atoi(data[xx+a11]) ) 
        {
          strcat (post_str, " or (");
          strcat (post_str, "n_itemname = '");
          strcat (post_str, data[yy+a9]);
          strcat (post_str, "' and ");
          strcat (post_str, "n_itemrev = '");
          strcat (post_str, data[yy+a10]);
          strcat (post_str, "')");
        }
      }
      sprintf (sql_str,  "%s %s %s %s",
             pre_str, data[xx+a8], "where", post_str);

      _PDMdebug (fname, "exec qry: %s\n", sql_str);

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "SQLquery (%s) 0x%.8x\n", sql_str, status);
        return (status);
      }
      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        NFMrollback_transaction (0);
        _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", status);
        return (status);
      }
      cat_data = (char **) list->data_ptr;
      for (z = 0; z < list->rows; z ++)
      {
        index = list->columns * z;
        for (y = z; y < macro_ass->rows; y ++)
        {
             yx = y * macro_ass->columns;
          if (atoi(data[yx + a12]) < 1 &&
              atoi(data[yx +a11]) == atoi (data[index+ a11]) &&
              !strcmp (data[yx+a9], cat_data[index]) &&
              !strcmp (data[yx+a10], cat_data[index+1]) ) 
          {
         status = MEMwrite_data(macro_ass,cat_data[index+2],y+1, a12+1);
          if(status != MEM_S_SUCCESS)
           {
           NFMrollback_transaction (0);
           _PDMdebug (fname, "MEMclose 0x%.8x\n", status);
            return (status);
           }
          }
        }
      }
      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "MEMbuild_array 0x%.8x\n", status);
        return (status);
      }
    }
  }  

  _PDMdebug (fname, "partnos updated in the buffer\n");

  if (PDMdebug_on)
       MEMprint_buffer("macro_ass",macro_ass,PDM_DEBUG_FILE);

  status = MEMbuild_array (macro_ass);   
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }

  columns = (char **) macro_ass->column_ptr;
  data = (char **) macro_ass->data_ptr;

/*********************************************************************
  Modified as follows:
    1. get all the citnos from nfmcit for the current
       assy.
    2. delete all the the children rows in nfmcit and pdmcit
    3. get the cit index from nfmindex.
    4. insert rows in cit (pdm/nfm) for the new assy
       in the buffer.
********************************************************************/

  _PDMdebug  (fname, "catalogno[%d] \n", catalog_no);
  _PDMdebug  (fname, "item_no[%d] \n", item_no);

  sprintf (sql_str, "%s = %d  %s = %d ",
  " select n_citno from nfmsetcit where n_pcatalogno ", catalog_no,
  " and n_pitemno  ", item_no );

  _PDMdebug  (fname, "catalogno[%d] \n", catalog_no);
  _PDMdebug  (fname, "item_no[%d] \n", item_no);

  status = SQLquery (sql_str, &citno_bufr, 512);
  if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
     NFMrollback_transaction (0);
     _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
     return (NFM_E_SQL_QUERY); 
     }

  if (status == SQL_S_SUCCESS) {
  _PDMdebug (fname, "An Older assy exists...\n");
  status = MEMbuild_array (citno_bufr);   
  if (status != MEM_S_SUCCESS) {
    NFMrollback_transaction (1200);
    _PDMdebug (fname, "MEMbuild_array  0x%.8x\n", status);
    return (status);
  }

   if(PDMdebug_on)
      MEMprint_buffer("Citno Bufr ", citno_bufr, PDM_DEBUG_FILE);

  cit_col = (char **) citno_bufr->column_ptr;
  cit_data = (char **) citno_bufr->data_ptr;
  citno_list [0] = '\0';

  /* Delete rows from nfmsetcit and pdmcit */
  for (x = 0; x < citno_bufr->rows ; x ++) {
    cit_index = citno_bufr-> columns * x;
    if (x > 0)
     strcat (citno_list, ", ");
    strcat (citno_list, cit_data [ cit_index ]);
  }
   
  _PDMdebug (fname, "citno_list [%s]\n", citno_list);

 sprintf (sql_str, 
       " delete from nfmsetcit where n_citno in ( %s )", citno_list);
   status = SQLstmt (sql_str);
   if (status != SQL_S_SUCCESS) {
     NFMrollback_transaction (0);
     _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
     return (NFM_E_SQL_STMT);
     }

 sprintf (sql_str, 
       " delete from pdmcit where p_citno in ( %s )", citno_list);
   status = SQLstmt (sql_str);
   if (status != SQL_S_SUCCESS) {
     NFMrollback_transaction (0);
     _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
     return (NFM_E_SQL_STMT);
     }

 }

  status = NFMlock_table ("nfmsetcit");
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _PDMdebug (fname, "NFMlock_table (nfmsetcit) 0x%.8x\n", status);
    return (status);
  }
 
   /* Get index from NFMINDEX for NFMSETCIT */

    sprintf (sql_str, "%s '%s'",
               "select min(n_indexslot) from nfmindex where n_tablename =",
               "nfmsetcit");
    status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
               &slot, &dumb_list);
    if (status != NFM_S_SUCCESS ) {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_QUERY); 
      }
   
     if (slot < 1)
      {
        strcpy (sql_str, "select max(n_citno) from nfmsetcit");
        status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                   &slot, &list);
        if (status != NFM_S_SUCCESS)
        {
          NFMrollback_transaction (0);
          _PDMdebug (fname, "SQLquery(%s) 0x%.8x\n", sql_str, status);
          return (NFM_E_SQL_QUERY);
        }
       }
      else
      {
       /* This is not smart.  If there exists another table
          whose slot no is same as nfmsetcit? ..
        sprintf (sql_str, "%s %d",
                 "delete from nfmindex where n_indexslot =", slot);
               */
        sprintf (sql_str, "%s '%s'",
                 "delete from nfmindex where n_tablename =", "nfmsetcit");
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          NFMrollback_transaction (0);
          _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
          return (NFM_E_SQL_STMT);
        }
      }

  /* Add rows from macro_ass buffer */

  for (x = added = 0; x < macro_ass->rows ; x ++) {
    set_index = x * macro_ass->columns;

   /* Increment the slot */
    slot++;

    /* insert into pdmcit */
    
      sprintf (sql_str, "%s %s %d, %d, %d, %s, %s, 'S' %s",
               "insert into nfmsetcit (n_citno, n_pcatalogno, n_pitemno,",
               "n_ccatalogno, n_citemno, n_type) values (",
            slot, catalog_no, item_no, data[set_index + a11],
               data[set_index+a12], ")");
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS)
          {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_STMT);
           }

    /* increment the childno */
       child_no++;
    
    /* insert into pdmcit */
      sprintf (sql_str, 
     "insert into pdmcit (p_citno, p_quantity,p_childno,p_incbom,p_explode, p_attached, n_catalogname, n_itemname, n_itemrev) VALUES (%d, 1.0, %d, 'Y','Y', 'Y','%s','%s','%s')", slot, child_no,data[set_index+a8],data[set_index+a9],data[set_index+a10]);
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_STMT);
      }

  }

      /* Update nfnindex table with new slot */
 sprintf (sql_str, 
 "insert into nfmindex (n_tablename, n_indexslot) VALUES ('%s', %d )", 
      "nfmsetcit", slot++);
 status = SQLstmt (sql_str);
 if (status != SQL_S_SUCCESS) {
   _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
   return (NFM_E_SQL_STMT);
   }

/*
  for (x = added = 0; x < macro_ass->rows ; x ++)
  {
       set_index = x * macro_ass->columns;

      sprintf (sql_str, "select n_citno from nfmsetcit where n_pcatalogno = %d and n_pitemno = %d and n_ccatalogno = %s and n_citemno = %s",catalog_no,item_no,data[set_index+a11],data[set_index+a12]);
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
               &citno, &dumb_list);
      if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
      {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_QUERY); 
      }
      if(status == SQL_I_NO_ROWS_FOUND)
      {
      sprintf (sql_str, "%s '%s'",
               "select min(n_indexslot) from nfmindex where n_tablename =",
               "nfmsetcit");
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
               &slot, &dumb_list);
      if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
      {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_QUERY); 
      }
   
      if (slot < 1)
      {
        strcpy (sql_str, "select max(n_citno) from nfmsetcit");
        status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                   &slot, &list);
        if (status != NFM_S_SUCCESS)
        {
          NFMrollback_transaction (0);
          _PDMdebug (fname, "SQLquery(%s) 0x%.8x\n", sql_str, status);
          return (NFM_E_SQL_QUERY);
        }
        slot++;
       }
      else
      {
        sprintf (sql_str, "%s %d",
                 "delete from nfmindex where n_indexslot =", slot);
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          NFMrollback_transaction (0);
          _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
          return (NFM_E_SQL_STMT);
        }
      }
      sprintf (sql_str, "%s %s %d, %d, %d, %s, %s, 'S' %s",
               "insert into nfmsetcit (n_citno, n_pcatalogno, n_pitemno,",
               "n_ccatalogno, n_citemno, n_type) values (",
            slot, catalog_no, item_no, data[set_index + a11],
               data[set_index+a12], ")");
          status = SQLstmt (sql_str);
          if (status != SQL_S_SUCCESS)
          {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_STMT);
           }
      } 
      else slot = citno;
       child_no++;
      sprintf (sql_str, "insert into pdmcit (p_citno, p_quantity,p_childno,p_incbom,p_explode, p_attached, n_catalogname, n_itemname, n_itemrev) VALUES (%d, 1.0, %d, 'Y','Y', 'Y','%s','%s','%s')", slot, child_no,data[set_index+a8],data[set_index+a9],data[set_index+a10]);
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
        return (NFM_E_SQL_STMT);
      }

  }
*/
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      NFMrollback_transaction (0);
      _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
      return (NFM_E_SQL_STMT);
    }
      sprintf (sql_str, "update %s set n_setindicator = 'Y' where n_itemno = %d", macro_cat,item_no);
             status = SQLstmt (sql_str);
             if (status != SQL_S_SUCCESS)
              {
              _PDMdebug (fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status);
               return (NFM_E_SQL_STMT);
              }

  _PDMdebug (fname, "EXIT: successful 0x%.8x\n", PDM_S_SUCCESS);
  return (PDM_S_SUCCESS);
}

