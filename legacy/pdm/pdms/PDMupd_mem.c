#include                <stdio.h>
#include                "PDUerror.h"
#include                "MEMstruct.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "SQLerrordef.h"
#include                "PDMdbs_err.h"
#include                "PDUpdmrpro.h"
#include                "PDMproto.h"

#include                "NFMschema.h"
#include                "NFMapi.h"
#include                "NFMitemfiles.h"
#include                "NFMitems.h"
#include                "NFMfto_buf.h"

extern int      PDMdebug_on;
extern PDMpart_ptr PDMpart;
extern char     PDM_DEBUG_FILE[];



/*
#include "ERR.h"
#include "DEBUG.h"
*/



 long PDMcheck_set_loop (user_id, cit_attr, p_cat_no, p_item_no,
                         c_cat_no, c_item_no, pc_off, pi_off, 
                         cc_off, ci_off)
   long     user_id;
   MEMptr   cit_attr;
   long     p_cat_no, p_item_no;
   long     c_cat_no, c_item_no;
   long     pc_off, pi_off;
   long     cc_off, ci_off;
   {
      static char *fn = "NFMcheck_set_loop" ;
      long     status, atol ();
      MEMptr   list = NULL, p_list = NULL;
      char     *sql_str;
      char     **data;
 /*     char     value [100];*/
      long     x, count;
      long     PDMcheck_parent_loop ();

      _PDMdebug (fn, "PC   No  = <%d> : PI No = <%d> : CC No = <%d> : CI No = <%d> : PC Offset = <%d> : PI Offset = <%d> : CC Offset = <%d> : CI Offset = <%d>\n",
		  p_cat_no, p_item_no, c_cat_no, c_item_no, pc_off,
		  pi_off, cc_off, ci_off);

      if ((p_cat_no == c_cat_no) && (p_item_no == c_item_no))
       {
         _PDMdebug (fn, "Set in Loop : status = <0x%.8x>\n",
		     NFM_E_SET_IN_LOOP);
         return (NFM_E_SET_IN_LOOP);
       }

      status = MEMopen (&list, 2 * MEM_SIZE);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (list, "cat_no", "integer");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (list, "item_no", "integer");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);
       }

      status = MEMwrite_format (list, "flag", "char(1)");
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         MEMclose (&list);
         _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
		     NFM_E_MALLOC);
         return (NFM_E_MALLOC);
       }
      sql_str[0] = '\0';
      
      sprintf (sql_str, "%d\1%d\1\1", c_cat_no, c_item_no);

      status = MEMwrite (list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&list);
         _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }

      sql_str[0] = '\0';
      sprintf (sql_str, "%d\1%d\1\1", p_cat_no, p_item_no);

      status = MEMwrite (list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         MEMclose (&list);
         _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }

      data = (char **) cit_attr -> data_ptr;

/*
      sprintf (sql_str, "SELECT %s, %s FROM %s WHERE ",
               data [(cit_attr -> columns * pc_off)],
               data [(cit_attr -> columns * pi_off)],
               "NFMSETCIT");

      strcat (sql_str, data [(cit_attr -> columns * cc_off)]);
      strcat (sql_str, " = ");

      sprintf (value, "%d", p_cat_no);

      if (! strncmp (data [(cit_attr -> columns * cc_off) + 1],
                     "char", 4))
       {
         strcat (sql_str, ",");
         strcat (sql_str, value);
         strcat (sql_str, ",");
       }
      else
         strcat (sql_str, value);
        
      strcat (sql_str, " AND ");

      strcat (sql_str, data [(cit_attr -> columns * ci_off)]);
      strcat (sql_str, " = ");

      sprintf (value, "%d", p_item_no);

      if (! strncmp (data [(cit_attr -> columns * ci_off) + 1],
                     "char", 4))
       {
         strcat (sql_str, ",");
         strcat (sql_str, value);
         strcat (sql_str, ",");
       }
      else
         strcat (sql_str, value);
*/
   
/* modified to hard code "n_pcatalogno and n_pitemno" instead of 
   getting it from the buffer */
/* query is 
    select n_pcatalogno, n_pitemno from nfmsetcit, pdmcit where
    n_ccatalogno = p_cat_no and n_citemno = p_item_no and
    pdmcit.n_citno = nfmsetcit.n_citno and (p_incbom = 'Y' or
    p_incbom = 'A' "  */

      sql_str[0] = '\0';
      sprintf (sql_str, "%s %s %s (%s %d AND %s %d ) ",
       " SELECT n_pcatalogno, n_pitemno FROM nfmsetcit, pdmcit WHERE",
       " pdmcit.p_citno = nfmsetcit.n_citno AND ",
       " ( p_incbom = 'Y' OR p_incbom = 'A' ) AND ",
       " n_ccatalogno = ", p_cat_no,
       " n_citemno = ", p_item_no);


      status = SQLquery (sql_str, &p_list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) && 
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         free (sql_str);
         MEMclose (&list);
         MEMclose (&p_list);
         _PDMdebug (fn, "SQL Stmt Failed : status = <0x%.8x>\n",
		     status);
         return ( NFM_E_SQL_QUERY);
       }

      free (sql_str);

      status = MEMbuild_array (p_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         MEMclose (&p_list);
         _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);
       }

      data = (char **) p_list -> data_ptr;

      for (x = 0; x < p_list -> rows; ++x)
       {
         count = p_list -> columns * x;

         status = PDMcheck_parent_loop (user_id, cit_attr, list,
                  atol (data [count]), atol (data [count + 1]),
                  pc_off, pi_off, cc_off, ci_off);
         if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            MEMclose (&p_list);
            _PDMdebug (fn, "Chk Par In Loop : status = <0x%.8x>\n",
            status);
            return (status);
          }
       }

      status = MEMclose (&p_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&p_list);
         _PDMdebug (fn, "MEM CLose : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM CLose : status = <0x%.8x>\n",status);
         return (NFM_E_MEM);
       }
 
      _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
      NFM_S_SUCCESS);
      return (NFM_S_SUCCESS); 
   }

 long PDMcheck_parent_loop (user_id, cit_attr, par_list, cat_no, item_no,
                            pc_off, pi_off, cc_off, ci_off)
   long    user_id;
   MEMptr  cit_attr, par_list;
   long    cat_no, item_no;
   long    pc_off, pi_off, cc_off, ci_off;
   {
     static char *fn = "PDMcheck_parent_loop" ;
      long     status, atol ();
      char     **data;
      long     x, count, row_no;
      char     *sql_str;
 /*     char     value [100];*/
      MEMptr   list = NULL;

      _PDMdebug (fn, "Cat  No = <%d> : Item No = <%d> : PC Offset = <%d> : PI Offset = <%d> : CC Offset = <%d> : CI Offset = <%d>\n",
		  cat_no, item_no, pc_off, pi_off, cc_off, ci_off);

      status = MEMbuild_array (par_list);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);            
       }

if (PDMdebug_on)
      MEMprint_buffer ("par_list ub check par loop", par_list,
                                               PDM_DEBUG_FILE);
 
      data = (char **) par_list -> data_ptr;

      for (x = 0; x < par_list -> rows; ++x)
       {
         count = par_list -> columns * x;

         if (strcmp (data [count + 2], "N"))
          {
           _PDMdebug ("Checking", "[%s].[%s]...\n", data[count], data[count+1]);
            if ((atol (data [count]) == cat_no) &&
                (atol (data [count + 1]) == item_no))
             {
               _PDMdebug (fn, "Set In Loop : status = <0x%.8x>\n",
			   NFM_E_SET_IN_LOOP);
               return (NFM_E_SET_IN_LOOP);            
             }
          }
       }

      sql_str = (char *) malloc (2 * MEM_SIZE);
      if (! sql_str)
       {
         _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
		     NFM_E_MALLOC);
         return (NFM_E_MALLOC);            
       }
      sql_str[0] = '\0';

      sprintf (sql_str, "%d\1%d\1", cat_no, item_no);
 
      status = MEMwrite (par_list, sql_str);
      if (status != MEM_S_SUCCESS)
       {
         free (sql_str);
         _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);            
       }

      row_no = par_list -> rows;

      data = (char **) cit_attr -> data_ptr;

/*
      sprintf (sql_str, "SELECT %s, %s FROM nfmsetcit WHERE ",
               data [(cit_attr -> columns * pc_off)],
               data [(cit_attr -> columns * pi_off)]);

      strcat (sql_str, data [(cit_attr -> columns * cc_off)]);

      strcat (sql_str, " = ");
      sprintf (value, "%d", cat_no);

      if (! strncmp (data [(cit_attr -> columns * cc_off) + 1],
                     "char", 4))
       {
         strcat (sql_str, ",");
         strcat (sql_str, value);
         strcat (sql_str, ",");
       }
      else
         strcat (sql_str, value);
        
      strcat (sql_str, " AND ");

      strcat (sql_str, data [(cit_attr -> columns * ci_off)]);
      strcat (sql_str, " = ");

      sprintf (value, "%d", item_no);

      if (! strncmp (data [(cit_attr -> columns * ci_off) + 1],
                     "char", 4))
       {
         strcat (sql_str, ",");
         strcat (sql_str, value);
         strcat (sql_str, ",");
       }
      else
         strcat (sql_str, value);
*/


      sql_str[0] = '\0';
      sprintf (sql_str, "%s %s %s (%s %d AND %s %d ) ",
       " SELECT n_pcatalogno, n_pitemno FROM nfmsetcit, pdmcit WHERE",
       " pdmcit.p_citno = nfmsetcit.n_citno AND ",
       " ( p_incbom = 'Y' OR p_incbom = 'A' ) AND ",
       " n_ccatalogno = ", cat_no,
       " n_citemno = ", item_no);

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if ((status != SQL_S_SUCCESS) && 
          ((status) != SQL_I_NO_ROWS_FOUND))
       {
         free (sql_str);
         MEMclose (&list);
         _PDMdebug (fn, "SQL Stmt Failed : status = <0x%.8x>\n",
		     status);
         return ( NFM_E_SQL_QUERY);
       }

      free (sql_str);

    if (status == SQL_S_SUCCESS) {
      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);
       }

if (PDMdebug_on) {
      MEMprint_buffer ("list ub check par loop", list,
                                               PDM_DEBUG_FILE);
      }
 

      data = (char **) list -> data_ptr;

      for (x = 0; x < list -> rows; ++x)
       {
         count = list -> columns * x;

         status = PDMcheck_parent_loop (user_id, cit_attr, par_list,
                  atol (data [count]), atol (data [count + 1]),
                  pc_off, pi_off, cc_off, ci_off);
         if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            _PDMdebug (fn, "Chk Par In Loop : status = <0x%.8x>\n",
            status);
            return (status);
          }
       }
     }

      status = MEMbuild_array (par_list);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);
       }

if (PDMdebug_on) {
      MEMprint_buffer ("par_list after qry", par_list,
                                               PDM_DEBUG_FILE);
        }
      row_no = par_list->rows;
      status = MEMwrite_data (par_list, "N", row_no, 3);
      if (status != MEM_S_SUCCESS)
       {
         MEMclose (&list);
         _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);            
       }

      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fn, "MEM Close : status = <0x%.8x>\n",
		     status);
         return (NFM_E_MEM);            
       }
      
      _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
		  NFM_S_SUCCESS);
      return (NFM_S_SUCCESS); 
   }
