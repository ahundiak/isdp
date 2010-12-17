#include <stdio.h>
#include "MEMstruct.h"
#include "PDUerror.h"
#include "MEMerrordef.h"
#include "SQLerrordef.h"
#include "NFMerrordef.h"
#include "NFMapi.h"
#include "NFMstruct.h"
#include "dbadev.h"
#include "rMRPstr.h"
#include "MRPmessage.h"
#include "PDMproto.h"

/* 
	DESCRIPTION: Creates the required buffers for defining 
	a PDM format/report. 
	The input buffer in PDMexec contains all the 
    required sizes. The output buffers are all appended 
	and sent across ....
       Kumar 2/1/92
*/

static		char		s[1024];
static 		long		status;

extern  int PDMdebug_on;
extern  char	PDM_DEBUG_FILE[];
extern struct NFMglobal_st NFMglobal;
extern PDMexec_ptr PDMexec;

/* This function validates a search or sort criteria 
given the name of the criteria
Kumar 9/21/91*/

int  PDMsvalidate_report_name ()
{
	char		sql_str[1024];
        MEMptr          bufr = NULL;
        char 		*fn = "PDMsvalidate_report_name ";
        char   apptype[3];      

	_PDMdebug (fn, "ENTER:PDMsvalidate_report_name\n");

        strcpy (apptype, "");
        sprintf (apptype, "%cF", PDMexec->drevision[0]);
        sql_str[0] = '\0';
        sprintf (sql_str, "SELECT p_templateno FROM psurptopts WHERE  p_templatename = '%s' AND (p_templatetype = '%s' OR p_templatetype = '%s')", PDMexec->drawing, PDMexec->drevision, apptype);
        status = SQLquery (sql_str, &bufr, 1024);
        if (status != SQL_S_SUCCESS) {
                MEMclose (&bufr);
                  if (status == SQL_I_NO_ROWS_FOUND)
                    {
	               _PDMdebug (fn, "EXIT:PDMivalidate_report\n");
                       return (PDM_I_NO_REPORT);
                    }
                _PDMdebug (fn, "SQLquery failed status %d\n", 
                        status);
                return (PDM_E_SQL_QUERY);
        }

	MEMclose (&bufr);
	_PDMdebug (fn, "EXIT:PDMsvalidate_report_name\n");
		return (PDM_E_REPORT_EXISTS);
}

/* 
	DESCRIPTION:	This function reads an existing report format 
*/

int PDMsread_report_format (bufr, def_bufr, def_op, def_list)
MEMptr		bufr;
MEMptr		def_bufr;
MEMptr		*def_op;
MEMptr		*def_list;
{
   char		**data;
   int             list_total;
   int             process;
   char            template_type[3], templib[100], where[20];
   char 	   *fn = "PDMsread_report_format ";
   struct PSUrpt   psurpt;

   _PDMdebug (fn, "ENTER:PDMsread_report_format\n");
   MEMclose (&def_bufr);
   status = MEMbuild_array (bufr);
   if (status != MEM_S_SUCCESS)
   {
	_PDMdebug (fn, "%s %d\n", 
		"MEMbuild_array failed status ", status);
	return (PDM_E_BUILD_ARRAY);
	}
   data = (char **) bufr->data_ptr;
   PDMinit_psurpt (&psurpt); 
   strcpy (psurpt.options.template_name, data[1]);
   strcpy (psurpt.templatetype, PDMexec->dcatalog);
   status = PSUrs_load_rpt (&psurpt);
   if (status != MRP_S_Success) {
      _PDMdebug (fn, "PSUrs_load_rpt failed status %d\n", status);
      status = PDM_E_OUTPUT_REPORT;
      goto wrapup;
   }

   status = PDMcvt_struct_bufr (def_op, def_list, &list_total, &process, template_type, templib, where, psurpt);
   if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "PSUcvt_struct_bufrfailed status %d\n", status);
                status = PDM_E_OUTPUT_REPORT;
                goto wrapup;
   }

    if (PDMdebug_on)
	{
	MEMprint_buffer ("PSUread_report:def_list", *def_list, PDM_DEBUG_FILE);
	MEMprint_buffer ("PSUread_report:def_op", *def_op, PDM_DEBUG_FILE);
	}			 

   rMRPfree_psurpt (&psurpt);
   _PDMdebug (fn, "EXIT:PDMsread_report_format -SUCCESS\n");
   return (PDM_S_SUCCESS);

 wrapup:
   MEMclose (&bufr);
   rMRPfree_psurpt (&psurpt);
   _PDMdebug (fn, "EXIT:PDMsread_report_format\n");
   return (status);
}

   /* 
	DESCRIPTION:	This function reads an existing 
					search/sort string
    */

int PDMsread_criteria (ret_bufr)
MEMptr		*ret_bufr;
{
   struct  NFMquery_info query_info;
   char 	   *fn = "PDMsread_criteria ";

   *ret_bufr = NULL;

   _PDMdebug (fn, "ENTER:PDMsread_criteria\n");
       
   status = PDMretrieve_query (PDMexec->catalog, &query_info);
   if (status != PDM_S_SUCCESS)
	{
             PDMfree_query_info_struct (query_info);
   	_PDMdebug (fn, "%s %d\n", 
   	"NFMretrieve_query failed status ", status);
   	return (PDM_E_RPS_READ_FORMAT);
	}			 

   status = PDMload_criteria_bufr (ret_bufr, query_info);
   if (status != PDM_S_SUCCESS)
   {
   	MEMclose (ret_bufr);
             PDMfree_query_info_struct (query_info);
   	_PDMdebug (fn, "%s %d\n", 
   	"NFMretrieve_query failed status ", status);
   	return (PDM_E_RPS_READ_FORMAT);
	}			 

        
   _PDMdebug (fn, "calling MEMprint_buffers\n");

   if (PDMdebug_on)
   {
   	MEMprint_buffers ("PDMsread_criteria:ret_bufr", 
   				  *ret_bufr, PDM_DEBUG_FILE);
   }

  PDMfree_query_info_struct (query_info);
   _PDMdebug (fn, "EXIT:PDMsread_criteria\n");
   return (PDM_S_SUCCESS);
}

int PDMsadd_report (def_op, def_list)
MEMptr		def_op;
MEMptr		def_list;
{
        int             list_total;
        int             process,i;
        int             subtotal, total;
        char             template_type[2];
        char             where[20];
        char             templib[20];
        struct  PSUrpt  psurpt;
        char 	   *fn = "PDMsadd_report ";

   _PDMdebug  ("ENTER:PDMsadd_report\n");

   list_total = PDMexec->entity;
   process = PDMexec->operation;
   strcpy (template_type, PDMexec->dcatalog);
   strcpy (where, PDMexec->drawing);
   strcpy (templib, PDMexec->drevision);

   if (PDMdebug_on) {
   MEMprint_buffer ("PDMsadd_report:def_op", def_op, PDM_DEBUG_FILE);
   MEMprint_buffer ("PDMsadd_report:def_list", def_list, PDM_DEBUG_FILE);
          }
   PDMinit_psurpt (&psurpt);

   status = PDMcvt_bufr_struct (def_op, def_list, list_total, process, 
                        template_type, templib, where, &psurpt);
   if (status != PDM_S_SUCCESS) {
	MEMclose (&def_op);
	MEMclose (&def_list);
	_PDMdebug  (fn, "%s %d\n", 
	"PDMcvt_bufr_struct failed status ", status);
	return (PDM_E_BUFFER_FORMAT);
	}
 
 /* Added fix to support sorting, totaling and sub-totaling for
    created reports. MaC  052394  */

   subtotal = 0;
   total    = 0;
   for ( i = 0; i < psurpt.list_total; ++i ) {
     _PDMdebug(fn,"\tpsurpt.list[i].name = %s\n", psurpt.list[i].name);
     _PDMdebug(fn,"\tpsurpt.list[i].header= %s\n", psurpt.list[i].header);
     _PDMdebug(fn,"\tpsurpt.list[i].type = %d\n", psurpt.list[i].type);
     _PDMdebug(fn,"\tpsurpt.list[i].start = %d\n", psurpt.list[i].start);
     _PDMdebug(fn,"\tpsurpt.list[i].length = %d\n", psurpt.list[i].length);
     _PDMdebug(fn,"\tpsurpt.list[i].decimal = %d\n", psurpt.list[i].decimal);
     _PDMdebug(fn,"\tpsurpt.list[i].sort = %d\n", psurpt.list[i].sort);
     _PDMdebug(fn,"\tpsurpt.list[i].subtotal = %d\n", 
                                         psurpt.list[i].subtotal);
     _PDMdebug(fn,"\tpsurpt.list[i].total = %d\n", psurpt.list[i].total);

/* if either list.total/subtotal is set;  options.total/subtotal needs
              to be set */
    if (psurpt.list[i].subtotal == 1) 
          subtotal = 1;
    if (psurpt.list[i].total == 1)
          total = 1;

    if (total == 1 && subtotal == 1) break;
    }

   psurpt.options.subtotals = subtotal;
   psurpt.options.totals = total;

   status = PSUrs_update_rpt (&psurpt);
   if (status != MRP_S_Success) {
	MEMclose (&def_op);
	MEMclose (&def_list);
	_PDMdebug  (fn, "%s %d\n", 
	"PSUrs_update_rpt failed status ", status);
	return (PDM_E_RPS_ADD_FORMAT);
	}			 
   _PDMdebug  ("EXIT:PDMsadd_report\n");
   return (PDM_S_SUCCESS);
}

/* Kumar 2.2.92 */
int PDMsadd_criteria (bufr, input_buffers)
MEMptr		bufr;
MEMptr		input_buffers;
{
   char		**data, **input_data;
        struct  NFMquery_info query_info;
        char *fname = "PDMsadd_criteria";


   _PDMdebug (fname, "ENTER:\n");
   if (PDMdebug_on)
   {
	MEMprint_buffers ("PDMsadd_criteria:input_buffers", 
						 input_buffers, PDM_DEBUG_FILE);
   }
   status = MEMbuild_array (bufr);
   if (status != MEM_S_SUCCESS)
   {
   	MEMclose (&bufr);
	_PDMdebug (fname, "%s %d\n", "MEMbuild_array failed status ", status);
   	return (PDM_E_BUILD_ARRAY);
	}
   status = MEMbuild_array (input_buffers);
   if (status != MEM_S_SUCCESS)
   {
   	MEMclose (&bufr);
   	MEMclose (&input_buffers);
	_PDMdebug (fname, "%s %d\n", "MEMbuild_array failed status ", status);
   	return (PDM_E_BUILD_ARRAY);
	}
        input_data = (char **) input_buffers->data_ptr;
   data = (char **) bufr->data_ptr;

       /* The input buffers should of following format 

       select_clause  char[]
       from_clause  char[]
       where_clause  char[]
       order_by_clause  char[]
       prompts  char[]
        */

      query_info.select_clause = (char *) malloc (strlen (input_data[0]) +1);
      strcpy (query_info.select_clause , input_data[0]);
      query_info.from_clause = (char *) malloc (strlen (input_data[1]) +1);
      strcpy (query_info.from_clause , input_data[1]);
      query_info.where_clause = (char *) malloc (strlen (input_data[2]) +1);
      strcpy (query_info.where_clause , input_data[2]);
      query_info.order_by_clause = (char *) malloc (strlen (input_data[3]) +1);
      strcpy (query_info.order_by_clause , input_data[3]);
      query_info.prompts = (char *) malloc (strlen (input_data[4]) +1);
      strcpy (query_info.prompts , input_data[4]);


         /* 
            Protocol
            PDMdefine_query (query_name, query_desc, query_type, application, 
                            user_name, query_info)
           */
       if (!strcmp (data[2], "W"))
        {
	status = PDMdefine_query (data[0], data[3], 
		 NFM_WHERE_CLAUSE, "PDM", NFMglobal.NFMusername, query_info);
	if (status != PDM_S_SUCCESS)
	{
	MEMclose (&bufr); MEMclose (&input_buffers);
             PDMfree_query_info_struct (query_info);
	_PDMdebug (fname, "%s %d\n", 
		"NFMdefine_query failed status ", status);
		return (PDM_E_RPS_ADD_FORMAT);
	}			 
        }
        else if (!strcmp (data[2], "O"))
        {
	status = PDMdefine_query (data[0], data[3], 
		 NFM_ORDER_BY_CLAUSE, "PDM", NFMglobal.NFMusername, query_info);
	if (status != PDM_S_SUCCESS)
	{
	MEMclose (&bufr); MEMclose (&input_buffers);
             PDMfree_query_info_struct (query_info);
		_PDMdebug (fname, "%s %d\n", 
		"NFMdefine_query failed status ", status);
		return (PDM_E_RPS_ADD_FORMAT);
	}			 
        }
         else 
             {
	MEMclose (&bufr); MEMclose (&input_buffers);
             PDMfree_query_info_struct (query_info);
		_PDMdebug (fname, "%s \n", "Invalid query_type [W or O only] ");
		return (PDM_E_RPS_ADD_FORMAT);
               }
   MEMclose (&bufr); MEMclose (&input_buffers);
        PDMfree_query_info_struct (query_info);
   _PDMdebug (fname, "EXIT:\n");
   return (PDM_S_SUCCESS);
}

int  PDMvalidate_querys ()
{
    char  sql_str[512];
    MEMptr  bufr = NULL;
    char 	   *fn = "PDMvalidate_querys ";

	               _PDMdebug (fn, "ENTER:PDMvalidate_querys\n");
        sql_str[0] = '\0';
        sprintf (sql_str, "SELECT n_reportname FROM nfmreports WHERE  n_reportname = '%s' AND n_type = '%s' AND n_reportdesc = '%s'", PDMexec->catalog, PDMexec->part_num, PDMexec->revision);

        status = SQLquery (sql_str, &bufr, 1024);
        if (status != SQL_S_SUCCESS) {
                MEMclose (&bufr);
                  if (status == SQL_I_NO_ROWS_FOUND)
                    {
	               _PDMdebug (fn, "EXIT:PDMvalidate_querys\n");
                       return (PDM_E_CRT_DOESNT_EXIST);
                    }
                _PDMdebug (fn, "SQLquery failed status %d\n", 
                        status);
                return (PDM_E_SQL_QUERY);
        }
         MEMclose (&bufr);
	               _PDMdebug (fn, "EXIT:PDMvalidate_querys\n");
       return (PDM_S_SUCCESS);
}

int PDMsdelete_report ()
{
  char           *fn = "PDMsdelete_report" ;
  char           sql_str[1024]; 
  char           **data;
  char           type[3];
  char           f_type[3];
  MEMptr         bufr = NULL;
  int		 j, index;

  _PDMdebug (fn, "ENTER:PDMsdelete_report\n");
     
  sql_str[0] = '\0';
  type[0] = '\0';
  f_type[0] = '\0';

  sprintf (f_type, "%sF", PDMexec->dcatalog);

  sprintf (sql_str, 
         "SELECT p_templateno,p_templatetype FROM psurptopts WHERE \
         p_templatename = '%s' AND ( p_templatetype = '%s' \
         OR p_templatetype  = '%s' )", 
         PDMexec->catalog, PDMexec->dcatalog, f_type);

  status = SQLquery (sql_str, &bufr, 1024);
  if (status != SQL_S_SUCCESS) {
           MEMclose (&bufr);
           if (status == SQL_I_NO_ROWS_FOUND) {
               _PDMdebug (fn, "EXIT\n");
               return (PDM_I_NO_REPORT);
               }
           _PDMdebug (fn, "SQLquery failed status %d\n", status);
           return (PDM_E_SQL_QUERY);
        }

  status = MEMbuild_array (bufr);
  if (status != MEM_S_SUCCESS) {
          MEMclose (&bufr);
          _PDMdebug (fn, "MEMbuild_array failed status 0x%.8x\n", 
                                               status);
          _PDMdebug (fn, "EXIT\n");
          return (PDM_E_BUILD_ARRAY);
  }
  data = (char **) bufr->data_ptr;

/* Changed so that ris reports can also be deleted MaC 72893*/
      /*
         strcpy (type, PDMexec->dcatalog);
            */
   type[0] = '\0';
   strcpy (type, data[1]);
   _PDMdebug (fn, "type [%s]\n", type);
   sql_str[0]='\0';
   sprintf (sql_str, "DELETE  FROM psurptopts WHERE \
        p_templatename = '%s' AND ( p_templatetype = '%s' \
        OR p_templatetype  = '%s' )", 
                         PDMexec->catalog, PDMexec->dcatalog, f_type);
   status = SQLstmt (sql_str);
   if (status != SQL_S_SUCCESS) {
                MEMclose (&bufr);
                  if (status == SQL_I_NO_ROWS_FOUND)
                    {
                 PDMdebug ("EXIT:PDMsdelete_report\n");
                       return (PDM_I_NO_REPORT);
                    }
                _PDMdebug (fn, "SQLquery failed status %d\n", 
                        status);
                return (PDM_E_SQL_QUERY);
   }

   if (type[1] != 'F')
         {
         sql_str[0]='\0';
        sprintf (sql_str, "DELETE  FROM psurptlist WHERE \
                         p_templateno = %s", data[0]);
          status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS) {
                MEMclose (&bufr);
                  if (status == SQL_I_NO_ROWS_FOUND)
                    {
                 PDMdebug ("EXIT:PDMsdelete_report\n");
                       return (PDM_S_SUCCESS);
                    }
                _PDMdebug (fn, "SQLquery failed status %d\n", 
                        status);
                return (PDM_E_SQL_QUERY);
        }

        }
        else
        {
   /* Changed: There could be other templates in the template library.
            We check to see if there any other formats of the same
            name but different type. If none, delete the file. Else
            do _not_ delete the template library. Note: If there are
            any other templates in the library, they should also be
            imported into the database for this logic to work. MaC 011694 */

        sprintf (sql_str, 
         "SELECT p_templatename, p_templatetype FROM psurptopts WHERE \
         p_templatename = '%s' ",
         PDMexec->catalog);

        MEMclose (&bufr); 

        status = SQLquery (sql_str, &bufr, 1024);
        if ( (status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND)) {
           MEMclose (&bufr);
           _PDMdebug (fn, "SQLquery failed status %d\n", status);
           return (PDM_E_SQL_QUERY);
        }

        if (status == SQL_S_SUCCESS) {

        status = MEMbuild_array (bufr);
        if (status != MEM_S_SUCCESS) {
          MEMclose (&bufr);
          _PDMdebug (fn, "MEMbuild_array failed status 0x%.8x\n", 
                                               status);
          _PDMdebug (fn, "EXIT\n");
          return (PDM_E_BUILD_ARRAY);
        }

        data = (char **) bufr->data_ptr;

        for (j = 0; j < bufr->rows; j++) {
          index = bufr->columns * j;
         
         /* If there exists another row with the same name but diff
            type, then return success */

          if (strcmp (data[index + 1], f_type) ) {
           _PDMdebug (fn, "Another report exists name[%s] type [%s]\n",
                           data[index], data[index + 1]);
           MEMclose (&bufr); 
           PDMdebug ("EXIT:PDMsdelete_report\n");
           return (PDM_S_SUCCESS);
           }
         }
        }
       
        /* If no_rows_found or Comes out of "for" loop meaning that 
           there are no other templates defined of the same name. */

         status = PDMdelete_ris_rpt (PDMexec->catalog);
          if (status != PDM_S_SUCCESS) {
              PDMdebug ("EXIT:PDMdelete_report- can't delete templatefile\n");
              MEMclose (&bufr); 
              return (status);
           }

      }
  MEMclose (&bufr); 
  PDMdebug ("EXIT:PDMsdelete_report\n");
  return (PDM_S_SUCCESS);
}

int PDMsshow_boms (return_buffer)
  MEMptr    *return_buffer;
{
  MEMptr    bufr1 = NULL;
  MEMptr    bufr2 = NULL;
  int    i, nx;
  char    **data;
  char    **column;
  char    sql_str[1024];
  char    part_num[80];
  char    part_rev[80];
  char 	   *fn = "PDMsshow_boms ";

  _PDMdebug (fn, "ENTER:PDMsshow_boms\n");

  *return_buffer = NULL;

  sprintf (sql_str, "%s %s %s", "SELECT n_catalogname, p_bomname, n_itemno, pdmboms.n_catalogno, p_createdate ", " FROM pdmboms, nfmcatalogs ", "WHERE nfmcatalogs.n_catalogno = pdmboms.n_catalogno ");
  status = SQLquery (sql_str, &bufr1, 1024);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&bufr1);
    _PDMdebug (fn, "Query bom list failed : 0x%.8x\n", status);
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      _PDMdebug (fn, "EXIT:PDMsshow_boms\n");
      return (PDM_E_NO_BOMS);
    }
    return (PDM_E_SQL_QUERY);
  }
  status = MEMbuild_array (bufr1);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&bufr1);
    _PDMdebug (fn, "MEMbuild_array failed : 0x%.8x\n", status);
    return (PDM_E_BUILD_ARRAY);
  }

  if (PDMdebug_on)
    MEMprint_buffer ("List of Available BOMs", bufr1, PDM_DEBUG_FILE);

  data = (char **) bufr1->data_ptr;
  column = (char **) bufr1->column_ptr;

  status = MEMopen (&bufr2, 512);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&bufr1);  
    _PDMdebug (fn, "MEMopen failed : 0x%.8x\n", status);
    return (PDM_E_OPEN_BUFFER);
  }

  status = MEMwrite_format (bufr2, "n_itemname", "char(30)");
  if (status == MEM_S_SUCCESS)
  status = MEMwrite_format (bufr2, "n_itemrev", "char(30)");
  if (status == MEM_S_SUCCESS)
  status = MEMwrite_format (bufr2, "n_catalogname", "char(20)");
  if (status == MEM_S_SUCCESS)
  status = MEMwrite_format (bufr2, "p_bomname", "char(20)");
  if (status == MEM_S_SUCCESS)
  status = MEMwrite_format (bufr2, "p_createdate", "char(20)");
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&bufr1); 
    _PDMdebug (fn, "MEMwrite_format failed : 0x%.8x\n", status);
    return (PDM_E_OPEN_BUFFER);
  }

  _PDMdebug (fn, "bufr2 created \n");

  for (i=0;i<bufr1->rows;i++)
  {
    nx = i * bufr1->columns;
      part_num[0] = '\0';
      part_rev[0] = '\0';
      status = PDMi_get_partnum_rev (data[nx], atol (data[nx+2]), 
            part_num, part_rev);
      if (status != PDM_S_SUCCESS)
      {
        MEMclose (&bufr1);
        return (status);
      }
      sprintf (s, "%s\1%s\1%s\1%s\1%s\1", 
             part_num, part_rev, data[nx], data[nx+1], data[nx+4]);
    status = MEMwrite (bufr2, s);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&bufr1); 
      MEMclose (&bufr2); 
      _PDMdebug (fn, "MEMwrite failed : 0x%.8x\n", status);
      return (PDM_E_WRITE_ROW);
    }
  }
/*   
  data1 = (char **) bufr2->data_ptr;
  for (i=0;i<bufr1->rows;i++)
  {
    nx = i * bufr1->columns;
    if (!strlen (data1[i*bufr2->columns]))
    {
      part_num[0] = '\0';
      part_rev[0] = '\0';
      status = PDMi_get_partnum_rev (data[nx], atol (data[nx+2]), 
            part_num, part_rev);
      if (status != PDM_S_SUCCESS)
      {
        MEMclose (&bufr1); MEMclose (&bufr2);
        return (status);
      }
      for (j=0;j<bufr2->rows;j++)
      {
        if (!strcmp (data[nx], data[j*bufr1->columns]) &&
         !strcmp (data[nx+3], data[j*bufr1->columns+3]))
        {
        status = MEMwrite_data (bufr2, part_num, i+1, 1);
        if (status != MEM_S_SUCCESS)
        {
          MEMclose (&bufr1); MEMclose (&bufr2);
          return (status);
        }
        status = MEMwrite_data (bufr2, part_rev, i+1, 2);
        if (status != MEM_S_SUCCESS)
        {
          MEMclose (&bufr1); MEMclose (&bufr2);
          return (status);
        }
        }
      }
      }
  }

  MEMclose (&bufr1);
         */
    if (PDMdebug_on)
  {
    MEMprint_buffer ("bufr2", bufr2, PDM_DEBUG_FILE);
        }
  MEMclose (&bufr1);
  *return_buffer = bufr2;
  _PDMdebug (fn, "EXIT:PDMsshow_boms\n");
  return (PDM_S_SUCCESS);
}


int PDMload_criteria_bufr ( attr_list, query_info)
MEMptr   *attr_list;
struct NFMquery_info query_info;
{
      static char *fname = "PDMload_criteria_bufr" ;
      long     status;
      short     size, size1, size2, size3, size4, size5;
      char      *mem_str, cize1[10], cize2[10], cize3[10], cize4[10], cize5[10];

       _PDMdebug (fname, "ENTER: PDMload_criteria_bufr\n");

      size1 = (strlen (query_info.select_clause)+1);
      size2 = (strlen (query_info.from_clause)+1);  
      size3 = (strlen (query_info.where_clause)+1);  
      size4 = (strlen (query_info.order_by_clause)+1);  
      size5 = (strlen (query_info.prompts)+1);  
      sprintf (cize1, "char(%d)", size1);  
      sprintf (cize2, "char(%d)", size2);  
      sprintf (cize3, "char(%d)", size3);  
      sprintf (cize4, "char(%d)", size4);  
      sprintf (cize5, "char(%d)", size5);  
      _PDMdebug (fname, "cize1 %s\n", cize1);
      _PDMdebug (fname, "cize2 %s\n", cize2);
      _PDMdebug (fname, "cize3 %s\n", cize3);
      _PDMdebug (fname, "cize4 %s\n", cize4);
      _PDMdebug (fname, "cize5 %s\n", cize5);
      _PDMdebug (fname, "select %s\n", query_info.select_clause);
      _PDMdebug (fname, "from %s\n", query_info.from_clause);
      _PDMdebug (fname, "where %s\n", query_info.where_clause);
      _PDMdebug (fname, "order_by %s\n", query_info.order_by_clause);
      _PDMdebug (fname, "prompts %s\n", query_info.prompts);
      status = MEMopen (attr_list, 1024);
      if (status != MEM_S_SUCCESS)
       {
         _PDMdebug (fname, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }
     status = MEMwrite_format (*attr_list, "select_clause", cize1);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
          _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
     status = MEMwrite_format (*attr_list, "from_clause", cize2);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
          _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
     status = MEMwrite_format (*attr_list, "where_clause", cize3);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
          _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
     status = MEMwrite_format (*attr_list, "order_by_clause", cize4);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
          _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
     status = MEMwrite_format (*attr_list, "prompts", cize5);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
          _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
    
        size = size1 + size2 + size3 + size4 + size5;
          _PDMdebug (fname, "size %d\n", size);

       mem_str = (char *) malloc (size + 50);

      mem_str[0] = '\0'; 
      
       if (strlen (query_info.select_clause) > 1)
           {
           strcat (mem_str, query_info.select_clause);
             strcat (mem_str, "\1");
           }
          else strcat (mem_str, "\1");
       if (strlen (query_info.from_clause) > 1)
           {
           strcat (mem_str, query_info.from_clause);
             strcat (mem_str, "\1");
            }
          else strcat (mem_str, "\1");
       if (strlen (query_info.where_clause) > 1)
           {
           strcat (mem_str, query_info.where_clause);
             strcat (mem_str, "\1");
            }
          else strcat (mem_str, "\1");
       if (strlen (query_info.order_by_clause) > 1)
           {
           strcat (mem_str, query_info.order_by_clause);
             strcat (mem_str, "\1");
            }
          else strcat (mem_str, "\1");
       if (strlen (query_info.prompts) > 1)
           {
           strcat (mem_str, query_info.prompts);
             strcat (mem_str, "\1");
            }
          else strcat (mem_str, "\1");
     /*
       sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1", 
                        query_info.select_clause, query_info.from_clause, 
                        query_info.where_clause, query_info.order_by_clause, 
                        query_info.prompts);
       */
          _PDMdebug (fname, "mem_str %s\n", mem_str);
        status = MEMwrite (*attr_list, mem_str);
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (attr_list);
          _PDMdebug (fname, "MEM Write  : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
          }
        free (mem_str);

      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      return (PDM_S_SUCCESS);
}

