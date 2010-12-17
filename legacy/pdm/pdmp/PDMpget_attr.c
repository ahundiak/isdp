#include 		<stdio.h>
#include 		"MEMstruct.h"
#include 		"NFMdb.h"
#include 		"NFMerrordef.h"
#include 		"ERR.h"
#include 		"DEBUG.h"
#include 		"NFMstruct.h"
#include                "PDUerror.h"
#include                "WFstruct.h"
#include                "SQLerrordef.h"
#include                "PDUris_incl.h"
#include                "PDMproto.h"
#include                "PDUpdmrpro.h"

extern  int     PDMdebug_on;
extern  char    PDM_DEBUG_FILE[];
static int              status;
extern PDMexec_ptr PDMexec;
extern struct NFMglobal_st NFMglobal ;
extern PDMpart_ptr PDMpart;
extern struct WFstruct WFinfo ;

int PDMquery_parm_catalog_attributes (attr_bufr, data_bufr, list_bufr)
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
MEMptr          *list_bufr;
{
        char		*fn = "PDMquery_parm_catalog_attributes";
        MEMptr          tmp_bufr = NULL;
        MEMptr          qry_bufr = NULL;
        MEMptr          qry_buf1 = NULL;
        MEMptr          attr_list = NULL;
        char		**q_data;
        char		**q_attr;
        int		col, col_index;
        int		catalog_no, commandno;
        char		sql_str[1024];
        char		*mem_str;
	long            _PDMload_datalist_bufr();

  PDMdebug("ENTER PDMquery_parm_catalog_attributes \n");
  sql_str[0] = '\0';
  sprintf (sql_str, "SELECT %s FROM %s WHERE %s = '%s' AND %s",
       "n_tableno", "NFMTABLES", "n_tablename ", PDMexec->catalog, 
       " n_tabletype = 'catalog'");
  status = SQLquery (sql_str, &qry_buf1, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_buf1);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "MEMbuild_query (qry_buf1) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("qry_buf1 from query", qry_buf1, PDM_DEBUG_FILE);
 }

  q_data = (char **) qry_buf1->data_ptr;
  catalog_no = atol (q_data[0]);
  _PDMdebug (fn, "catalog_no = %d\n", catalog_no);
  if (WFinfo.catalog_no != catalog_no) WFinfo.catalog_no = catalog_no;
  MEMclose (&qry_buf1);
  _PDMdebug (fn, "catalog_no = %d\n", catalog_no);

   /* NFM requires the commandno in the WFinfo structure
       in NFM3.2 */
   status = PDMget_commandno ("Add Item", &commandno);
   if(status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "PDMget_command_no failed status %d\n", status);
     return(PDM_E_GET_DATA);
   }

   WFinfo.command = commandno;

/*, "ORDER BY n_tableno,n_seqno");*/

/*
   sprintf (sql_str, "%s %s %s %s %s %s %s ",
"SELECT n_attrno, n_name, n_tableno, n_synonym, n_datatype, n_seqno, n_read, "
"n_write, n_update, n_delete, n_null, n_checkin, n_checkout, "
"n_application, n_lattrno, n_jointable, n_joinattrno "
"FROM nfmattributes, nfmtables "
"WHERE nfmtables.n_tablename = "
"AND nfmtables.n_tabletype = 't_appltable' "
"AND nfmattributes.tableno = nfmtables.tableno ");
*/
     sprintf (sql_str, "SELECT %s%s%s FROM %s WHERE %s = %d  %s",
              "n_name, n_datatype, n_synonym, ",
              "n_application, n_read, n_write, n_update, n_delete, n_null, ",
              "n_checkin, n_checkout, n_seqno, n_attrno,n_tableno",
              "NFMATTRIBUTES", "n_tableno", catalog_no,
              "ORDER BY n_seqno");

  _PDMdebug ("sql_str", "%s\n", sql_str);
  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("qry_bufr from query", qry_bufr, PDM_DEBUG_FILE);
 }




/***********************************************************/
/* add n_valueno and n_adviceno to the list */
   status = _PDMadd_cols_to_attr_bufr (qry_bufr, &attr_list);
  if (status != PDM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "_PDMadd_cols_to_attr_bufr (qry_bufr) 0x%.8x\n", status);
    return (status);
  }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

MEMclose (&qry_bufr);

/***********************************************************/
  q_attr = (char **) attr_list->data_ptr;

  status = MEMopen(&tmp_bufr,1024);
   if(status != MEM_S_SUCCESS) {
      MEMclose(&attr_list);
      _PDMdebug (fn, "MEMopen failed status %d\n",status);
      return(PDM_E_OPEN_BUFFER);
   }
    
    mem_str = (char *) malloc (((attr_list) -> rows) *10);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str[0] ='\0';

   
    for (col = 0; col < attr_list->rows; col++) {
    col_index = col * attr_list->columns;
     status = MEMwrite_format (tmp_bufr, 
                                  q_attr[col_index + 0], 
                                     q_attr[col_index + 1]);
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n",status);
                MEMclose(&attr_list);
                MEMclose(&tmp_bufr);
                return(PDM_E_WRITE_FORMAT);
        }
/* build the empty string at the same time */
    strcat (mem_str, "\1");
     }
  status = MEMbuild_array (tmp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&attr_list);
    MEMclose (&tmp_bufr);
    _PDMdebug ( fn, "MEMbuild_query (attr_list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }
   
 _PDMdebug ("mem_str", "%s\n", mem_str);
     
  status = MEMwrite(tmp_bufr, mem_str);
  if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           return(status);
  }
      
  *data_bufr = tmp_bufr;
  free (mem_str);
   MEMprint_buffer("Before calling load_datalist", attr_list, PDM_DEBUG_FILE);
/* add n_valueno and n_adviceno to the list */
   status = _PDMload_datalist_bufr (attr_list, data_bufr, list_bufr);
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_datalist_bufr 0x%.8x\n", status);
    return (status);
  }
   MEMprint_buffer("After calling load_datalist", attr_list, PDM_DEBUG_FILE);

   status = _PDMload_defaults (&attr_list, data_bufr, list_bufr, "W");
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_defaults  0x%.8x\n", status);
    return (status);
  }
  *attr_bufr = attr_list;

 if (PDMdebug_on) {
    MEMprint_buffer ("new data_bufr", *data_bufr, PDM_DEBUG_FILE);
    MEMprint_buffer ("new attr_bufr", *attr_bufr, PDM_DEBUG_FILE);
    MEMprint_buffers ("new list_bufr", *list_bufr, PDM_DEBUG_FILE);
 }


_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}

int _PDMadd_cols_to_attr_bufr (bufr, attr_bufr)
MEMptr	bufr;
MEMptr	*attr_bufr;
{
	char		*fn = "_PDMadd_cols_to_attr_bufr";
	int		i, j, index;
	char		*mem_str, **q_data;
	MEMptr		tmp_bufr = NULL;
	MEMptr		tmp1_bufr = NULL;
	char		**q_col;
	char		zero_chr[10];

_PDMdebug ("ENTER", "%s\n", fn);

      status = MEMopen(&tmp1_bufr, MEM_SIZE );
      if( status != MEM_S_SUCCESS ) {
          MEMclose (&tmp1_bufr) ;
          _PDMdebug (fn, "MEMopen : <0x%.8x>", status );
          return( NFM_E_MEM );
        }

/*
      status = MEMbuild_array (tmp_bufr);
      if( status != MEM_S_SUCCESS ) {
          MEMclose (&tmp1_bufr) ;
          _PDMdebug (fn, "MEMbuild_array : <0x%.8x>", status );
          return( NFM_E_MEM );
        }
*/


         _PDMdebug (fn, "membuild bufr\n");
      status = MEMbuild_array (bufr);
      if( status != MEM_S_SUCCESS ) {
          MEMclose (&tmp1_bufr) ;
          _PDMdebug (fn, "MEMbuild_array : <0x%.8x>", status );
          return( NFM_E_MEM );
        }

   q_col = (char **) bufr->column_ptr;
  q_data = (char **) bufr->data_ptr;

       /* add the column name to tmp_bufr */
/*
         _PDMdebug (fn, "adding cols to new attr_bufr\n");
       for (i = 0; i < bufr->rows; i++) {
       index = bufr->columns * i;
       _PDMdebug ( fn, "attr[%s.%s]\n", q_data[index], q_data[index +1]);
       status = MEMwrite_format( tmp_bufr, q_data[index], q_data[index +1]);
          if( status != MEM_S_SUCCESS ) {
              MEMclose( &tmp_bufr );
              _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", status );
              return( NFM_E_MEM );
            }
        }

*/

      status = _PDMcreate_new_attr_bufr (&tmp1_bufr);
      if( status != PDM_S_SUCCESS ) {
          MEMclose (&tmp1_bufr) ;
          _PDMdebug (fn, "_PDMcreate_new_attr_bufr : <0x%.8x>", status );
          return( status );
        }

      status = MEMbuild_array (tmp1_bufr);
      if( status != MEM_S_SUCCESS ) {
          MEMclose (&tmp_bufr) ;
          _PDMdebug (fn, "MEMbuild_array : <0x%.8x>", status );
          return( status );
        }

    mem_str = (char *) malloc (((bufr) -> row_size) *10);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str[0] ='\0';

/*
      for( i = 0; i < ((bufr->rows)*(bufr->columns)); i+=bufr->columns ) {
          mem_str [0] = '\0';
          for( j = 0; j < (bufr->columns); ++j ) {
              strcat( mem_str, q_data[i+j] );
              strcat( mem_str, "\001" );
            }
          strcat( mem_str, "0\0010\001" );
          _PDMdebug ("mem_str", "%s\n", mem_str);

          status = MEMwrite( tmp_bufr, mem_str );
          if( status != MEM_S_SUCCESS ) {
              _PDMdebug (fn, "MEMwrite:<0x%.8x>", status );
              MEMclose( &tmp_bufr );
              free (mem_str);
              return( NFM_E_MEM );
            }
        }

*/

    zero_chr[0] = '\0';
    sprintf (zero_chr, "%d", 0);
    _PDMdebug (fn, "zero_chr[%s]\n", zero_chr);
    for (i = 0; i < bufr->rows; i++) {
    index = i * bufr->columns;
    mem_str [0] = '\0';
    for (j = 0; j < bufr->columns; j++) {
      strcat (mem_str, q_data[index + j]);
      strcat (mem_str, "\1");
      _PDMdebug (q_col[j],"col[%d] -> %s\n", j, q_data[index +j]);
         }
     /* n_adviceno = n_valueno = 0 
    strcat (mem_str, "0\10\1"); */
    strcat (mem_str, zero_chr); 
    strcat (mem_str, "\1"); 
    strcat (mem_str, zero_chr); 
    strcat (mem_str, "\1"); 
          _PDMdebug ("mem_str", "%s\n", mem_str);
    status = MEMwrite(tmp1_bufr, mem_str);
    if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           free (mem_str);
           MEMclose( &tmp1_bufr );
           return(status);
        }
    }

 if (PDMdebug_on) {
    MEMprint_buffer ("new attr_bufr in add_cols fn", 
					tmp1_bufr, PDM_DEBUG_FILE);
 }

    *attr_bufr = tmp1_bufr;
    free (mem_str);
    
_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}


long _PDMload_datalist_bufr (attr_list, data_list, list_bufr)
   MEMptr   attr_list;     /*  modified - attribute buffer */
   MEMptr   *data_list;    /*  modified - data buffer */
   MEMptr   *list_bufr;   /*  modified - value list */
{
     static char *fn = "_PDMload_datalist_bufr" ;
     long    status;
     long    x, y, z, count ;
     long    a, b, c, d, e, f, g, h ;
     long    no_buffers ;
     MEMptr  temp_list = NULL;
     char    **column, **data, **data2 ;
     char    *sql_str, *sql_str1, tmp_str[100] ;
     char    value [100] ;
     long    _PDMXXget_list_bufr ();
     MEMptr  attrs = NULL, list_buffer = NULL ;
     char    no_buff [10] ;
     int     comma, row_offset, offset  = -1 ;
     int     i_name, i_datatype, i_valueno;
     int     i_adviceno, i_read, i_write, i_update, i_attrno;


     /* The attr_list buffer received get offsets for
        n_name, n_datatype, etc */

     _PDMdebug (fn, "ENTER\n");

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);          
      }

     status = MEMbuild_array (*data_list);
     if (status != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);          
      }

    if (PDMdebug_on) {
    MEMprint_buffer ("attr_list in get_data_value", attr_list, PDM_DEBUG_FILE);
    MEMprint_buffer ("data_list in get_data_value", *data_list, PDM_DEBUG_FILE);
    }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     a = i_name = 0;
     b = i_datatype = 1;
     c = i_valueno = 14;
     d = i_adviceno = 15;
     e = i_read = 4;
     f = i_write = 5;
     g = i_update = 6;
     h = i_attrno = 12;
     z = 0;

     /* if data_list existed recover data, otherwise put empty row */

/* create an empty row for data_list */
/*
     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (list_bufr);
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _PDMdebug (fn, "Malloc failed (sql_str)");
	 return (NFM_E_MALLOC);          
       }

         sql_str [0] = '\0';
	 for (y = 0; y < (*data_list) -> columns; ++y) strcat (sql_str, "\1");


	 status = MEMwrite (*data_list, sql_str);
	 if (status != MEM_S_SUCCESS)
	   {
	     free (sql_str);
	     MEMclose (data_list);
	     MEMclose (list_bufr);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _PDMdebug (fn, "MEM Write data_list : status = <0x%.8x>\n",
			 status);
	     return (NFM_E_MEM);          
	   }
	 free (sql_str);
       }
*/
     

     for (x=z; x<attr_list->rows ; ++x) {
         _PDMdebug (fn, "x = %d, z = %d\n", x, z);
	 status = MEMwrite_data (attr_list, "0", x+1, i_valueno+1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (list_bufr);
	     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",status);
	     return (NFM_E_MEM);          
	   }

	 status = MEMwrite_data (attr_list, "0", x + 1, i_adviceno + 1) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     MEMclose (data_list);
	     MEMclose (list_bufr);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	     _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n", 
			 status);
	     return (NFM_E_MEM);          
	   }
       }

     data   = (char **) attr_list -> data_ptr;

    /* Get default values for the data list and value list buffers */


     comma = 0 ;

     sql_str1 = (char *) malloc (200 + 60 * attr_list->rows) ;
     
     if (!sql_str1) 
       {
	 MEMclose (data_list);
	 MEMclose (list_bufr);
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _PDMdebug (fn, "Malloc failed (sql_str1)");
	 return (NFM_E_MALLOC);          
       }

     sql_str  = (char *) malloc (200 + 60 * attr_list-> rows) ;

     if (!sql_str)
       {
	 MEMclose (data_list);
	 MEMclose (list_bufr);
	 free (sql_str1) ;
            ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	 _PDMdebug (fn, "Malloc failed (sql_str)");
	 return (NFM_E_MALLOC);          
       }


     sprintf (sql_str1, 
       "SELECT %s FROM NFMVALUES WHERE (n_type = 'C' OR n_type = 'A') AND (",
	"n_attrno, n_type, n_defaultvalue, n_defaultno, n_minvalue, n_maxvalue, n_listno, n_programno") ;
 	      
         
     _PDMdebug ("sql_str1", "%s\n", sql_str1);

     sql_str[0] = '\0';

     for (x = z; x < attr_list -> rows; ++x)
       {
	 count = x * attr_list -> columns  ;
	 
	 if (comma)
	   strcat (sql_str, " OR ") ;
	 comma = 1 ;
	 sprintf (tmp_str, "n_attrno = %s", data[count + h]) ;
	 strcat (sql_str, tmp_str) ;
       } 
         
/*
     _PDMdebug ("sql_str1", "%s\n", sql_str1);
     _PDMdebug ("sql_str", "%s\n", sql_str);
*/


	
     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ") ;
/*
	   strcat (sql_str1, " ) ORDER by n_attrno") ;
*/
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _PDMdebug (fn, "No attributes ");
	 return (NFM_S_SUCCESS);                 
       }
         
/*
     _PDMdebug ("sql_str1", "%s\n", sql_str1);
     _PDMdebug ("sql_str", "%s\n", sql_str);
*/


     status = SQLquery (sql_str1, &attrs, MEM_SIZE) ;

     if (status != SQL_S_SUCCESS) 
       {
	 if ((status ) == SQL_I_NO_ROWS_FOUND)
	   {
	     MEMclose (&attrs) ;
	     _PDMdebug (fn, "No Rows found");
	     return (NFM_S_SUCCESS);                 
	   }
	 MEMclose (data_list) ;
	 MEMclose (list_bufr) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _PDMdebug (fn, "SQL Query Syntax : < 0x%.8x >", status);
	 return (NFM_E_SQL_QUERY) ;
       }

    sprintf (sql_str1, "SELECT %s FROM NFMVALUES a, NFMLISTS b WHERE (a.n_type = 'C' OR a.n_type = 'A') AND (a.n_listno = b.n_listno) AND (",
              "a.n_attrno, a.n_listno, b.n_value") ;

     if (comma) 
	{
           strcat (sql_str1, sql_str) ;
	   strcat (sql_str1, " ) ") ;
/*
	   strcat (sql_str1, " ) ORDER by a.n_attrno, a.n_listno") ;
*/
        }
     else 
       {
	 free (sql_str1) ;
	 free (sql_str) ;
	 _PDMdebug (fn, "No attributes ");
	 return (NFM_S_SUCCESS);                 
       }
         
/*
     _PDMdebug ("sql_str1", "%s\n", sql_str1);
     _PDMdebug ("sql_str", "%s\n", sql_str);
*/


     status = SQLquery (sql_str1, &list_buffer, MEM_SIZE) ;

     free (sql_str1) ;
     free (sql_str) ;

     if ((status != SQL_S_SUCCESS)  && (status != SQL_I_NO_ROWS_FOUND))
       {
	 MEMclose (data_list) ;
	 MEMclose (list_bufr) ;
	 MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
	 _PDMdebug (fn, "SQL Query Syntax : < 0x%.8x >", status);
	 return (NFM_E_SQL_QUERY) ;
       }

     status = MEMbuild_array (attrs) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (list_bufr);
	 MEMclose (&attrs) ;
	 
	 _PDMdebug (fn, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status);
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (list_buffer) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (list_bufr);
	 MEMclose (&attrs) ;
	 
	 _PDMdebug (fn, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status);
	 return (NFM_E_MEM);
       }

     status = MEMbuild_array (*data_list) ;
     if (status != MEM_S_SUCCESS) 
       {
	 MEMclose (&temp_list);
	 MEMclose (data_list);
	 MEMclose (list_bufr);
	 MEMclose (&attrs) ;
	 
	 _PDMdebug (fn, "MEMbuild_array(attrs) : < 0x%.8x >\n",
		   status);
	 return (NFM_E_MEM);
       }
     

    if (PDMdebug_on) {
    MEMprint_buffer ("attrs op of first query", 
					attrs, PDM_DEBUG_FILE);
    MEMprint_buffer ("list_buffer op of second query", 
					list_buffer, PDM_DEBUG_FILE);
     }

     data2 = (char **) attrs->data_ptr ;

     for (y = 0; y <attrs->rows; y++)
       {
	 row_offset = y*attrs->columns ;
	 
	 strcpy (value, data2 [row_offset + 2]) ;
	 
_PDMdebug ("_PDMXXget_list_bufr",
"attrno[%s] type[%s] minval[%s] maxval[%s]\ndefno[%s] listno[%s] progno[[%s]\n",
data2 [row_offset + 0], data2 [row_offset + 1], data2 [row_offset + 4], 
data2 [row_offset + 5], data2 [row_offset + 3], data2 [row_offset + 6],  
data2 [row_offset + 7]);
_PDMdebug ("_PDMXXget_list_bufr", "value[%s]\n", value);
	     status = _PDMXXget_list_bufr (atol (data2 [row_offset]),
					  data2 [row_offset + 1], /* type */
					  data2 [row_offset + 4], /* minvalue*/
					  data2 [row_offset + 5], /* maxvalue */
					  atol(data2 [row_offset+3]), /*defno*/
					  atol(data2 [row_offset+6]), /*listno*/
					  atol(data2 [row_offset+7]), /*progno*/
					  value, &temp_list,
					  list_buffer) ;
	     
	     if (status != NFM_S_SUCCESS && status != NFM_E_NO_ATTR_INFO)
	       {
		 MEMclose (&temp_list);
		 MEMclose (&attrs) ;
		 MEMclose (data_list);
		 MEMclose (list_bufr);
		 
		 _PDMdebug (fn, "Get Attr Value : status = <0x%.8x>\n",
			     status);
		 return (status);          
	       }

 if (PDMdebug_on) {
    MEMprint_buffer("list_buffer from get_list_bufr",
                                        list_buffer, PDM_DEBUG_FILE);
    MEMprint_buffer("temp_list from get_list_bufr", 
                                        temp_list, PDM_DEBUG_FILE);
       }

	 /* get row in attr/column in data list */
	 for (x=0; x<attr_list->rows; x++)
	   {
	     count = x*attr_list->columns ;
	     _PDMdebug (fn, "data2[row_offset] = %s; data[count+h] = %s\n",
	     data2 [row_offset], data [count +h]);
	     if (strcmp (data2 [row_offset], data [count +h]) == 0)
	       break ;
	   }
	 
	 if (x != attr_list->rows)
	   {
	     if (status != NFM_E_NO_ATTR_INFO)
	       {
                _PDMdebug (fn, "Value = %s\n", value);
		 if (strlen (value) && strcmp(value,""))
		   {
		     status = MEMwrite_data (*data_list, value, 1, x + 1);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (&temp_list);
			 MEMclose (&attrs);
			 MEMclose (data_list);
			 MEMclose (list_bufr);
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",
				     status);
			 return (NFM_E_MEM);          
		       }
		   }
		 
		 if (temp_list)
		   {
		     if (! (*list_bufr))
		       {
			 status = MEMsplit_copy_buffer (temp_list, list_bufr, 0);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (list_bufr);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _PDMdebug (fn, "Copy Buffer : status = <0x%.8x>\n",
					 status);
			     return (NFM_E_MEM);          
			   }
		       }
		     else
		       {
			 status = MEMappend (temp_list, *list_bufr);
			 if (status != MEM_S_SUCCESS)
			   {
			     MEMclose (&temp_list);
			     MEMclose (&attrs) ;
			     MEMclose (data_list);
			     MEMclose (list_bufr);
			     ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			     _PDMdebug (fn, "Append Buffer : status = <0x%.8x>\n",
					 status);
			     return (NFM_E_MEM);          
			   }
		       }
		     
		     status = MEMclose (&temp_list);
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list);
			 MEMclose (list_bufr);
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _PDMdebug (fn, "MEM CLose : status = <0x%.8x>\n",
				     status);
			 return (NFM_E_MEM);          
		       }
		     no_buff[0] = '\0'; 
		     status = MEMno_buffers (*list_bufr, &no_buffers);
                      if(status != MEM_S_SUCCESS)
                      {
			 MEMclose (data_list) ;
			 MEMclose (list_bufr) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _PDMdebug (fn, "MEM Write Data : < 0x%.8x >",
				     status);
			 return (NFM_E_MEM) ;
		       }
                       no_buff[0] = '\0';
		     sprintf (no_buff, "%d\0", no_buffers);
		     if (strcmp (data2 [row_offset +1], "C") == 0)
		       offset = c ;
		     else 
		       if (strcmp (data2 [row_offset +1], "A") == 0)
			 offset = d ;
              _PDMdebug(fn, "no_buff %s\n", no_buff);
		     status = MEMwrite_data (attr_list, no_buff, 
					     x + 1, offset + 1) ;
		     if (status != MEM_S_SUCCESS)
		       {
			 MEMclose (data_list) ;
			 MEMclose (list_bufr) ;
			 MEMclose (&attrs) ;
			 ERRload_struct (NFM, NFM_E_MEM, "", NULL);
			 _PDMdebug (fn, "MEM Write Data : < 0x%.8x >",
				     status);
			 return (NFM_E_MEM) ;
		       }
		   }
	       }
	   }
	 else
	   {
	     MEMclose (data_list) ;
	     MEMclose (list_bufr) ;
	     MEMclose (&attrs) ;
            ERRload_struct (NFM, NFM_E_CORRUPTED_SYSTEM, "", NULL);
	     _PDMdebug (fn, "Corrupted System : < 0x%.8x >\n",
		       NFM_E_CORRUPTED_SYSTEM);
	     return (NFM_E_CORRUPTED_SYSTEM) ;
	   }
       }
     
     MEMclose (&attrs) ;
     _PDMdebug (fn, "SUCCESSFUL\n");
     return (PDM_S_SUCCESS);
}




 long _PDMXXget_list_bufr (attrno,
			 type, min_value, max_value,
			 def_no, list_no, prog_no,
			 def_value, list, list_buffer)
   long     attrno ;
   char     *type, *min_value, *max_value ;
   long     def_no, list_no, prog_no ;
   char     *def_value;
   MEMptr   *list;
   MEMptr   list_buffer ;
{
     static char *fn = "_PDMXXget_list_bufr" ;
     long      status;
     long      _PDMXXget_list_list ();
     long      NFMget_range_list ();
     long      NFMget_program_list ();
     long      NFMget_program_value ();
     long     PDMXXget_range_list ();
     long     PDMXXget_program_list ();
     long     PDMXXget_program_value ();

     _PDMdebug ("ENTER", "%s\n", fn);

     _PDMdebug (fn, "Type       = <%s>  : Min Value = <%s> : Max Value = <%s> : Default No = <%d> : List No = <%d> : Program No = <%d> : Def Value = <%s>\n", 
		 type, min_value, max_value, def_no, list_no, prog_no,
		 def_value);

     if (! strcmp (type, "C"))
      {
        if (def_no > 0 && (! strlen (def_value)))
         {

/* right now this function does nothing! Just sets def_value to NULL */

           status = PDMXXget_program_value (NFMglobal.NFMuserid,
                    def_no, def_value);
           if (status != NFM_S_SUCCESS)
            {
              MEMclose (list);
              _PDMdebug (fn, "Get Prog Value : status = <0x%.8x>\n",
              status);
              return (status);        
            }
         }
      }

     if (strlen (min_value) || strlen (max_value))
      {
/* this just creates a empty buffer with one empty row*/
        status = PDMXXget_range_list (NFMglobal.NFMuserid,
				    min_value, max_value, list);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _PDMdebug (fn, "Get Range List : status = <0x%.8x>\n",
           status);
           return (status);        
         }
      }
     else if (list_no > 0)
      {
        status = _PDMXXget_list_list (attrno, list_no, list, list_buffer);
        if (status != NFM_S_SUCCESS)
         {
           MEMclose (list);
           _PDMdebug (fn, "Get Static List : status = <0x%.8x>\n",
           status);
           return (status);        
         }
      }
     else if (prog_no > 0) {
/* does not do anything...*/
        status = PDMXXget_program_list (NFMglobal.NFMuserid, prog_no, list);
        if (status != NFM_S_SUCCESS) {
           MEMclose (list);
           _PDMdebug (fn, "Get Prog List : status = <0x%.8x>\n",
           status);
           return (status);        
         }
      }

     _PDMdebug ("EXIT", "%s\n", fn);
     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS);
     return (NFM_S_SUCCESS);
}




 long PDMXXget_range_list (user_id, min, max, list)
   long     user_id;
   char     *min, *max;
   MEMptr   *list;
   {
     static char *fn = "PDMXXget_range_list" ;
     long    status;
     char    sql_str [512], datatype [20] ;

     _PDMdebug (fn, "Min = <%s> : Max = <%s>\n", 
		 min, max);
     user_id = user_id ;
     status = MEMopen (list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);
      }

         status = MEMwrite_format (*list, "n_input", "char(20)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }

	sprintf (datatype, "char(%d)", NFM_MINVALUE) ;
	status = MEMwrite_format (*list, "n_minvalue", datatype) ;
	if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }
	sprintf (datatype, "char(%d)", NFM_MAXVALUE) ;
	status = MEMwrite_format (*list, "n_maxvalue", datatype) ;
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }

     sprintf (sql_str, "%s\001%s\001%s\001",
              "NFM_RANGE", min, max) ;

     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);
      }

     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS);
     return (NFM_S_SUCCESS);
   }

long _PDMXXget_list_list (attrno, list_no, list, list_buffer)
     long     attrno ;
     long     list_no ;
     MEMptr   *list;
     MEMptr   list_buffer ;
{
  static char *fn= "_PDMXXget_list_list" ;
  long    status, break_point, x, offset, empty_buffer ;
  char    sql_str [512], **data ;
  char    datatype [30] ;
  offset = -1;
  
  _PDMdebug (fn, "Attrno = <%d> : List No = <%d>\n", 
	      attrno, list_no);
  
  status = MEMopen (list, MEM_SIZE) ;
  if (status != MEM_S_SUCCESS)
    {
      _PDMdebug (fn, "MEMopen : status = <0x%.8x>\n",
		  status) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  sprintf (datatype, "char(%d)", NFM_VALUE) ;
  status = MEMwrite_format (*list, "n_value", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      _PDMdebug (fn, "MEMwrite_format : status = <0x%.8x>\n",
		  status) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  data = (char **) list_buffer -> data_ptr;
  empty_buffer =0 ;
  break_point = 0 ;
  for (x = 0; x < list_buffer -> rows; ++x)
    {
      offset = x *list_buffer->columns ;
/*      _PDMdebug (fn, "comparing %d : %s and %d : %s\n",
		  list_no, data [offset+1], attrno, data [offset]) ;  */
      
      _PDMdebug (fn, 
          "list_no[%d], data [offset+1][%s], attrno[%d], data [offset][%s]\n",
            list_no, data [offset+1], attrno, data [offset]);
      if ((list_no == atol (data [offset+1])) && 
	  (attrno == atol (data [offset])))
	{
	  empty_buffer = 1 ;
	  break_point = 1 ;
	  sql_str [0] = '\0';
	  
	  strcat (sql_str, data [offset+2]);     strcat (sql_str, "\1");
	  
	  status = MEMwrite (*list, sql_str);
	  if (status != MEM_S_SUCCESS) {
	      MEMclose (list);
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	      _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n",
			  status);
	      return (NFM_E_MEM); 
	    }
	}
      else
	{
	  if (break_point) break ;
	}
    }
  
  if (! empty_buffer)
    {
      MEMclose (list) ;
      _PDMdebug (fn, "No list information for attr <%s>\n",
		  data [offset]) ;

    }

     _PDMdebug (fn, "SUCCESSFUL\n");
     return (NFM_S_SUCCESS);
   }

 long _PDMXXget_list_list2 (attrno, list_no, list, list_buffer)
   long     attrno ;
   long     list_no ;
   MEMptr   *list;
   MEMptr   list_buffer ;
   {
     static char *fn= "_PDMXXget_list_list2" ;
     long    status, break_point, x, offset;
     char    sql_str [512], **data ;
     char    datatype [30] ;

     _PDMdebug (fn, "Attrno = <%d> : List No = <%d>\n", 
		 attrno, list_no);

     _PDMdebug (fn, "opening list\n");
     status = MEMopen (list, MEM_SIZE) ;
     if (status != MEM_S_SUCCESS)
       {
	 _PDMdebug (fn, "MEMopen : status = <0x%.8x>\n",
		     status) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     sprintf (datatype, "char(%d)", NFM_VALUE) ;

     status = MEMwrite_format (*list, "n_value", datatype) ;
     if (status != MEM_S_SUCCESS)
       {
	 _PDMdebug (fn, "MEMwrite_format : status = <0x%.8x>\n",
		     status) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     sprintf (datatype, "char(%d)", NFM_VALUE2) ;

     status = MEMwrite_format (*list, "n_value2", datatype) ;
     if (status != MEM_S_SUCCESS)
       {
	 _PDMdebug (fn, "MEMwrite_format : status = <0x%.8x>\n",
		     status) ;
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 return (NFM_E_MEM) ;
       }

     data = (char **) list_buffer -> data_ptr;

     break_point = 0 ;
     for (x = 0; x < list_buffer -> rows; ++x)
      {
	offset = x *list_buffer->columns ;
/*	_PDMdebug (fn, "comparing %d : %s and %d : %s\n",
		    list_no, data [offset+1], attrno, data [offset]) ; 
*/
	if ((list_no == atol (data [offset+1])) && 
	     (attrno == atol (data [offset])))
	  {
	    break_point = 1 ;
	    sql_str [0] = '\0';
	    
	    strcat (sql_str, data [offset+2]);     strcat (sql_str, "\1");
	    strcat (sql_str, data [offset+3]);     strcat (sql_str, "\1");
	    
	    status = MEMwrite (*list, sql_str);
	    if (status != MEM_S_SUCCESS)
	      {
		MEMclose (list);
		ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		_PDMdebug (fn, "MEM Write : status = <0x%.8x>\n",
			    status);
		return (NFM_E_MEM); 
	      }
	  }
	else
	  {
	    if (break_point) break ;
	  }
      }

     _PDMdebug (fn, "SUCCESSFUL\n");
     return (NFM_S_SUCCESS);
   }


 long PDMXXget_program_list (user_id, program_no, list)
   long     user_id;
   long     program_no;
   MEMptr   *list;
   {
     static char *fn = "PDMXXget_program_list" ;
     list = list ;
     user_id = user_id ;
     _PDMdebug (fn, "Program No = <%d>\n", program_no);
     
     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS);
     return (NFM_S_SUCCESS);
   }

 long PDMXXget_program_value (user_id, program_no, value)
   long     user_id;
   long     program_no;
   char     *value;
   {
     static char *fn = "PDMXXget_program_value" ;
     value [0] = '\0';

     _PDMdebug (fn, "Program No = <%d> :Value = <%s>\n", 
		 program_no, value);
     user_id = user_id ;
     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS);
     return (NFM_S_SUCCESS);
   }

 long PDMXXget_range_info (user_id, min, max, list)
   long     user_id;
   char     *min, *max;
   MEMptr   *list;
   {
     static char *fn = "PDMXXget_range_info" ;
     long     status;
     char     sql_str [1024];
     long     PDMXXbuild_attr_list ();

     _PDMdebug (fn, "Min  = <%s>  : Max = <%s>\n", 
		 min , max);
     user_id = user_id ;
     status = PDMXXbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        _PDMdebug (fn, "Build Attr List : status = <0x%.8x>\n",
        status);
        return (status); 
      }

     sql_str [0] = '\0';

     strcpy (sql_str, "NFM_RANGE"); strcat (sql_str, "\1");
     strcat (sql_str, min);         strcat (sql_str, "\1");
     strcat (sql_str, max);         strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");
                                    strcat (sql_str, "\1");

     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n",status);
        return (NFM_E_MEM); 
      }

     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n", 
     NFM_S_SUCCESS);
     return (NFM_S_SUCCESS); 
   }

 long PDMXXget_list_info (user_id, list_no, list)
   long     user_id;
   long     list_no;
   MEMptr   *list;
   {
     static char *fn = "PDMXXget_list_info" ;
     long     status;
     MEMptr   temp_list = NULL;
     char     sql_str [1024];
     char     **data;
     long     x;
     long     PDMXXbuild_attr_list ();

     _PDMdebug (fn, "List No = <%d>\n", list_no);
     user_id= user_id ;
     sprintf (sql_str, "SELECT n_value FROM %s WHERE %s = %d", 
              "NFMLISTS", "n_listno", list_no);

     status = SQLquery (sql_str, &temp_list, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&temp_list);
 
        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
            ERRload_struct (NFM, NFM_E_BAD_LIST, "", NULL);
           _PDMdebug (fn, "No Such List : status = <0x%.8x>\n",
           NFM_E_BAD_LIST);
           return (NFM_E_BAD_LIST);
         }

            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        _PDMdebug (fn, "SQL Query Syntax : status = <0x%.8x>\n",
		    status);
        return (NFM_E_SQL_QUERY);
      }

     status = MEMbuild_array (temp_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&temp_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
		    status);
        return (NFM_E_MEM); 
      }

     status = PDMXXbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        MEMclose (&temp_list);
        _PDMdebug (fn, "Build Attr List : status = <0x%.8x>\n",
        status);
        return (status); 
      }

     data = (char **) temp_list -> data_ptr;

     for (x = 0; x < temp_list -> rows; ++x)
      {
        sql_str [0] = '\0';

        strcpy (sql_str, "NFM_STATIC"); strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
        strcat (sql_str, data [x]);     strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");

        status = MEMwrite (*list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (list);
           MEMclose (&temp_list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n",
		       status);
           return (NFM_E_MEM); 
         }
      }

     status = MEMclose (&temp_list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug (fn, "MEM Close : status = <0x%.8x>\n",status);
        return (NFM_E_MEM); 
      }

     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS);
     return (NFM_S_SUCCESS); 
   }


 long PDMXXget_program_info (user_id, program_no, list)
   long     user_id;
   long     program_no;
   MEMptr   *list;
   {
     static char *fn = "PDMXXget_program_info" ;
     long     status;
     char     sql_str [1024];
     char     program_name [50];
     long     PDMXXbuild_attr_list ();

     _PDMdebug (fn, "Program No = <%d>\n", program_no);

     status = NFMget_program_name (user_id, program_no, program_name);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fn, "Get Prog Name : status = <0x%.8x>\n",
        status);
        return (status); 
      }

     status = PDMXXbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        _PDMdebug (fn, "Build Attr List : status = <0x%.8x>\n",
        status);
        return (status); 
      }

     sql_str [0] = '\0';

     strcpy (sql_str, "NFM_PROGRAM");  strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
     strcat (sql_str, program_name);   strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");
                                       strcat (sql_str, "\1");

     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
        return (NFM_E_MEM); 
      }

     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS);
     return (NFM_S_SUCCESS); 
   }

 long PDMXXget_program_value_info (user_id, program_no, list)
   long     user_id;
   long     program_no;
   MEMptr   *list;
   {
     static char *fn = "PDMXXget_program_value_info" ;
     long     status;
     char     program_name [50];
     char     *sql_str [1024];
     long     PDMXXbuild_attr_list ();

     _PDMdebug (fn, "Program No = <%d>\n", program_no);

     status = NFMget_program_name (user_id, program_no, program_name);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fn, "Get Prog Name : status = <0x%.8x>\n",
         status);
        return (status); 
      }

     status = PDMXXbuild_attr_list (list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (list);
        _PDMdebug (fn, "Build Attr List : status = <0x%.8x>\n",
        status);
        return (status); 
      }

     sql_str [0] = '\0';

     strcpy (sql_str, "NFM_DEFAULT");   strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
     strcat (sql_str, program_name);    strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");
                                        strcat (sql_str, "\1");

     status = MEMwrite (*list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
        return (NFM_E_MEM); 
      }

     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS);
     return (NFM_S_SUCCESS); 
}

 long PDMXXbuild_attr_list (list)
   MEMptr   *list;
{
  static char *fn = "PDMXXbuild_attr_list" ;
  long     status;
  char     datatype [20] ;

     if (! (*list))
      {
	_PDMdebug (fn, "Building buffer\n");
         status = MEMopen (list, MEM_SIZE); 
         if (status != MEM_S_SUCCESS)
          {
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_input", "char(20)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }

	sprintf (datatype, "char(%d)", NFM_MINVALUE) ;
	status = MEMwrite_format (*list, "n_minvalue", datatype) ;
	if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }
	sprintf (datatype, "char(%d)", NFM_MAXVALUE) ;
	status = MEMwrite_format (*list, "n_maxvalue", datatype) ;
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_value", "char(40)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_filename", "char(14)") ;
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_type", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_appname", "char(3)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }

         status = MEMwrite_format (*list, "n_apptype", "char(1)");
         if (status != MEM_S_SUCCESS)
          {
            MEMclose (list);
            ERRload_struct (NFM, NFM_E_MEM, "", NULL);
            _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
			status);
            return (NFM_E_MEM); 
          }
      }
 
     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n",
     NFM_S_SUCCESS);
     return (NFM_S_SUCCESS); 
   }




int _PDMcreate_new_attr_bufr (attr_list)
MEMptr		*attr_list;
{
	char		*fn = "_PDMcreate_new_attr_bufr";
_PDMdebug ("ENTER", "%s\n", fn);


      
      status = MEMopen( attr_list, MEM_SIZE );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMopen : <0x%.8x>", status );
	  return( NFM_E_MEM );
	}
      
      status = MEMwrite_format( *attr_list, "n_name", "char(20)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_datatype", "char(15)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_synonym", "char(40)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}
      
      status = MEMwrite_format( *attr_list, "n_application", "char(3)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}
      
      status = MEMwrite_format( *attr_list, "n_read", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_write", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_update", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_delete", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_null", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      
      status = MEMwrite_format( *attr_list, "n_checkin", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      status = MEMwrite_format( *attr_list, "n_checkout", "char(1)" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      
      status = MEMwrite_format( *attr_list, "n_seqno", "integer" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}
      status = MEMwrite_format( *attr_list, "n_attrno", "integer" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      
      status = MEMwrite_format( *attr_list, "n_tableno", "integer" );
      if( status != MEM_S_SUCCESS )
	{
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      
      status = MEMwrite_format( *attr_list, "n_valueno", "integer" );
      if( status != MEM_S_SUCCESS ) {
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      
      status = MEMwrite_format( *attr_list, "n_adviceno", "integer" );
      if( status != MEM_S_SUCCESS ) {
	  _PDMdebug (fn, "MEMwrite_format:<0x%.8x>", 
		      status );
	  return( NFM_E_MEM );
	}    	
      

_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS); 
}



/* 
   This function loads default valies into data and list buffers.
   This function is also called for regular parts, in the file
   pdms/PDMcat_attr.c
*/

int _PDMload_defaults (attr_list, data_list, list_bufr, mode)
MEMptr		*attr_list;
MEMptr		*data_list;
MEMptr		*list_bufr;
char		*mode;
{
	char		*fn = "_PDMload_defaults";
	MEMptr		list = NULL;
	int		i_name, i_valueno, x;
	char		**column, **data;
        int		count ;
	char		date[50], user_name[50], acl_no[20], sa_no[10];
	char		update[50];
        int		no_buffers;

_PDMdebug ("ENTER", "%s\n", fn);
/* 
  mode support is added since both update and add part calls this
   and there was a problem that creationdate value was getting overwritten
   by updatedate value during update. MaC 042393
*/
  _PDMdebug (fn, "mode [%s]\n", mode);

  _PDMdebug (fn, "membuilding attr_list\n");
  status = MEMbuild_array (*attr_list);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (*attr_list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


  _PDMdebug (fn, "membuilding data_list\n");
  status = MEMbuild_array (*data_list);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (data_list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

     _PDMdebug (fn, "username [%s]\n", NFMglobal.NFMusername);
     strcpy (user_name, NFMglobal.NFMusername);
     status = NFMget_datetime (date) ;
     if (status != NFM_S_SUCCESS) {
      _PDMdebug (fn, "NFMget_datetime failed : status = <0x%x.8>\n", status) ;
       return (status) ;
       }

     _PDMdebug (fn, "date [%s]\n", date);

      status = _NFMget_cat_acl_list (NFMglobal.NFMuserno,
                                     WFinfo.catalog_no, &list);
       if (status != NFM_S_SUCCESS) {
         _PDMdebug (fn, "_NFMget_cat_acl_list : status = <0x%.8x>\n", status);
	 return (status) ;
       }

  _PDMdebug (fn, "membuilding list\n");
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("list from get_cat_acl_list", list, PDM_DEBUG_FILE);
 }

     if (list -> rows < 1) {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (list_bufr );
	_PDMdebug (fn, "Failure : No Acls Available for this item\n") ;
	return (NFM_E_NO_ACLS_FOUND) ;
      }

     if (*list_bufr ) {
        status = MEMappend (list, *list_bufr );
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (list_bufr );
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _PDMdebug (fn, "MEM Append : status = <0x%.8x>\n",
		       status);
           return (NFM_E_MEM);          
         }
      }
     else {
        status = MEMsplit_copy_buffer (list, list_bufr , 0);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (list_bufr );
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _PDMdebug (fn, "MEM Copy : status = <0x%.8x>\n",
		       status);
           return (NFM_E_MEM);          
         }
      }
 
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (list_bufr );
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug (fn, "MEM Close : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);          
      }
     acl_no[0] = '\0';
     MEMno_buffers (*list_bufr , &no_buffers );
     sprintf (acl_no, "%d", no_buffers );
     _PDMdebug (fn, "acl_no %d", no_buffers );

/*
     status = _NFMget_internal_sa_list_for_item (cat_name, item_name, 
						 item_rev, &list) ;
     if (status != NFM_S_SUCCESS) {
	 _PDMdebug (fn, "Failure : internal sa list for item\n", status) ;
	 return (status) ;
       }
*/
      status = _NFMget_cat_internal_sa_list (WFinfo.catalog_no, &list);
      if (status != NFM_S_SUCCESS) {
          MEMclose (list);
        _PDMdebug (fn, "_NFMget_cat_internal_sa_list  : status = <0x%.8x>\n", 
                                                              status);
          return (status);
        }

       if (status == NFM_S_SUCCESS) MEMbuild_array(list);

     if (list -> rows < 1) {
        MEMclose (&list);
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (list_bufr );
        ERRload_struct (NFM, NFM_E_NO_ST_AREAS, "", "") ;
	_PDMdebug (fn, "No storagearea available for item\n") ;
	return (NFM_E_NO_ST_AREAS) ;
      }

     if (*list_bufr ) {
        status = MEMappend (list, *list_bufr );
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (list_bufr );
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _PDMdebug (fn, "MEM Append : status = <0x%.8x>\n",
		       status);
           return (NFM_E_MEM);          
         }
      }
     else {
        status = MEMsplit_copy_buffer (list, list_bufr , 0);
        if (status != MEM_S_SUCCESS)
         {
           MEMclose (&list);
           MEMclose (attr_list);
           MEMclose (data_list);
           MEMclose (list_bufr );
	   ERRload_struct (NFM, NFM_E_MEM, "", NULL);
           _PDMdebug (fn, "MEM Copy : status = <0x%.8x>\n",
		       status);
           return (NFM_E_MEM);          
         }
      }
 
     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (attr_list);
        MEMclose (data_list);
        MEMclose (list_bufr );
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _PDMdebug (fn, "MEM Close : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);          
      }
      sa_no[0] = '\0';
     MEMno_buffers (*list_bufr , &no_buffers );
     sprintf (sa_no, "%d", no_buffers );
     _PDMdebug (fn, "sanos %d", no_buffers );
     _PDMdebug (fn, "sa_no %s", sa_no );

     column = (char **) (*attr_list) -> column_ptr;
     data   = (char **) (*attr_list) -> data_ptr;
     i_name = 0;
     i_valueno = 14;

     for (x = 0; x < (*attr_list) -> rows; ++x) {
        count = (*attr_list) -> columns * x;
         
        if (! strcmp (data [count + i_name], "n_itemlock"))
         {
           status = MEMwrite_data (*data_list, "N", 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (list_bufr );         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",
			  status);
              return (NFM_E_MEM);          
            }
         }
        else if (! strcmp (data [count + i_name], "n_creator"))
         {
           status = MEMwrite_data (*data_list, user_name, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (list_bufr );         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",
			  status);
              return (NFM_E_MEM);          
            }
         }
        else if ((! strcmp (data [count + i_name], "n_creationdate")) 
                  && (! strcmp (mode, "W")))
         {
           status = MEMwrite_data (*data_list, date, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (list_bufr );         
              _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",
              status);
              return (status);          
            }
         }
        else if ((! strcmp (data [count + i_name], "n_updatedate")) 
                  && ( strcmp (mode, "W")))
         {
       /* fix added because, the current date (date) was showing
          up in the updatedate column during review mode. The
          value existing in the database should be seen. MaC061893*/
          update [0] = '\0';
          _PDMdebug (fn, "updatedate[%s]\n", PDMpart.n_updatedate);
          if (!strcmp (mode, "R"))
                   strcpy (update, PDMpart.n_updatedate);
          else
                   strcpy (update, date);
  
           status = MEMwrite_data (*data_list, update, 1, x + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (list_bufr );         
              _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",
              status);
              return (status);          
            }
         }
        else if (! strcmp (data [count + i_name], "n_aclno"))
         {
           status = MEMwrite_data (*attr_list, acl_no, x + 1, i_valueno + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (list_bufr );         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",
			  status);
              return (NFM_E_MEM);          
            }
         }
        else if (! strcmp (data [count + i_name], "n_cisano"))
         {
           status = MEMwrite_data (*attr_list, sa_no, x + 1, i_valueno + 1);
           if (status != MEM_S_SUCCESS)
            {
              MEMclose (attr_list);
              MEMclose (data_list);
              MEMclose (list_bufr );         
	      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
              _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",
			  status);
              return (NFM_E_MEM);          
            }
         }
      }


_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS); 
}

/* This function takes as its input a memappended list of
   buffers and recreates another set of memappended list */

int _PDMrecreate_grandchildren_dyn_databufr (in_bufr, out_put_bufr)
MEMptr	in_bufr, *out_put_bufr;
{
	char		*fn = "_PDMrecreate_grandchildren_dyn_databufr";
	MEMptr		tmp_bufr = NULL;
	MEMptr		out_bufr = NULL;
	char		**column, **data, **format;
        int		i, k, buf_num, buf_num1, offset ;
	char		*mem_str;
	char		blank[5];
	char		prev_cat [40];
        int		no_bufrs;

_PDMdebug ("ENTER", "%s\n", fn);


  status = MEMbuild_array (in_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&in_bufr);
    _PDMdebug ( fn, "MEMbuild_query (in_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
     }

  status = MEMopen(out_bufr,1024);
  if(status != MEM_S_SUCCESS) {
      MEMclose(&out_bufr);
      _PDMdebug (fn, "MEMopen failed status %d\n",status);
      return(PDM_E_OPEN_BUFFER);
   }
     
   status = MEMno_buffers (in_bufr, &no_bufrs);
   if (status != MEM_S_SUCCESS) {
      _PDMdebug(fn, "MEMno_buffers failed status %d\n", status);
      return (PDM_E_RESET_BUFFER);
      }

   _PDMdebug (fn, "# of buffers appended = %d\n", no_bufrs);

   blank[0] = '\0';
   strcpy (blank, "");
  
 for (buf_num = 1; buf_num<=no_bufrs; buf_num++){ 
   status = MEMreset_buffer_no (in_bufr, buf_num);
   if (status != MEM_S_SUCCESS) {
     _PDMdebug(fn, "MEMreset_buffer_no failed status %d\n", status);
     return (PDM_E_RESET_BUFFER);
     }
 
   status = MEMbuild_array (in_bufr);
   if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (in_bufr) 0x%.8x\n", status );
    return (NFM_E_MEM);
     }
   
   data = (char **) (in_bufr) -> data_ptr;
   column = (char **) (in_bufr) -> column_ptr;
   format = (char **) (in_bufr) -> format_ptr;

   status = _PDMget_cat_index (in_bufr, "n_catalogname", &offset);
   if (status != PDM_S_SUCCESS) {
     _PDMdebug(fn, "_PDMget_cat_index failed status %d\n", status);
     return (status);
     }

   /* if the catalogname is not blank, then it is
      a part that has not been added to the out_bufr
      and needs to have a seperate bufr */

   if (strcmp (data[offset], "") ) {
     _PDMdebug (fn, "This is a new catalog[%s] prev[%s]\n",
                         data[offset], prev_cat);
   strcpy (prev_cat, data[offset]);

   if (tmp_bufr != NULL) {
   status = MEMappend (tmp_bufr, out_bufr);
   if(status != MEM_S_SUCCESS) {
          MEMclose(&out_bufr);
         _PDMdebug (fn, "MEMappend failed status %d\n",status);
         return(status);
      }
    

   if (PDMdebug_on) {
        MEMprint_buffer ("new output bufr ", out_bufr, PDM_DEBUG_FILE);
   }
  }

   status = MEMopen(tmp_bufr,1024);
   if(status != MEM_S_SUCCESS) {
          MEMclose(&out_bufr);
         _PDMdebug (fn, "MEMopen failed status %d\n", status);
         return(PDM_E_OPEN_BUFFER);
         }

     for (k = 0; k< in_bufr->columns; k++) {
     status = MEMwrite_format (tmp_bufr, data[k], format[k]);
     if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMwrite_format failed status %d\n",status);
       MEMclose (&tmp_bufr);
       MEMclose (&out_bufr);
       if (mem_str) free (mem_str);
       return(PDM_E_WRITE_FORMAT);
       }
      }

   for (buf_num1 = 1; buf_num1<=no_bufrs; buf_num1++){ 
 
   status = MEMreset_buffer_no (in_bufr, buf_num1);
   if (status != MEM_S_SUCCESS) {
     _PDMdebug(fn, "MEMreset_buffer_no failed status %d\n", status);
     return (PDM_E_RESET_BUFFER);
     }
 
   status = MEMbuild_array (in_bufr);
   if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (in_bufr) 0x%.8x\n", status );
    return (NFM_E_MEM);
     }
   
   data = (char **) (in_bufr) -> data_ptr;
   column = (char **) (in_bufr) -> column_ptr;
   format = (char **) (in_bufr) -> format_ptr;

   status = _PDMget_cat_index (in_bufr, "n_catalogname", &offset);
   if (status != PDM_S_SUCCESS) {
     _PDMdebug(fn, "_PDMget_cat_index failed status %d\n", status);
     return (status);
     }
   
   if (strcmp (prev_cat, data[offset])) {
      continue;
     }
     
   else {

     mem_str = (char *) malloc (((in_bufr) -> row_size) *  10);
     if (! mem_str) {
         _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
         return (NFM_E_MALLOC);
         }
      mem_str[0] ='\0';
  
     for (k = 0; k< in_bufr->columns; k++) {
      strcpy (mem_str, data[k]);
      strcpy (mem_str, "\1");
      }
     
     status = MEMwrite (tmp_bufr, mem_str);
     if(status != MEM_S_SUCCESS) {
       MEMclose (&tmp_bufr);
       MEMclose (&out_bufr);
       if (mem_str) free (mem_str);
       _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
       return(status);
        }

     if (mem_str) free (mem_str);

    /* blankout the catname */

     status = MEMwrite_data (in_bufr, blank, 1, offset + 1) ;
     if (status != MEM_S_SUCCESS) {
        MEMclose (&out_bufr);
        _PDMdebug (fn, "MEM Wr Data : status = <0x%.8x>\n",status);
        return (NFM_E_MEM);          
        }
       }
      }
     }
    }

 /* Whew! it is finally over!! */


  if (PDMdebug_on) {
        MEMprint_buffer ("new output bufr ", out_bufr, PDM_DEBUG_FILE);
   }
 *out_put_bufr = out_bufr;
  for (i=no_bufrs; i == 1; i--) {
   status = MEMreset_buffer_no (in_bufr, i);
   if (status != MEM_S_SUCCESS) {
     _PDMdebug(fn, "MEMreset_buffer_no failed status %d\n", status);
     return (PDM_E_RESET_BUFFER);
     }
   if (in_bufr) MEMclose (&in_bufr);
   }

_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS); 
}


int _PDMget_cat_index (in_bufr, column_name, offset)
MEMptr	in_bufr;
char	*column_name;
int	*offset;
{
	char		*fn = "_PDMget_cat_index";
	char		**column;
        int		i ;

     _PDMdebug ("ENTER", "%s\n", fn);

/*
     status = MEMbuild_array (in_bufr);
     if (status != MEM_S_SUCCESS) {
       _PDMdebug ( fn, "MEMbuild_query (in_bufr) 0x%.8x\n", status );
       return (NFM_E_MEM);
       }
*/
     
     column = (char **) (in_bufr) -> column_ptr;
   
     for( i = 0; i < (in_bufr->columns); ++i ) {
      if ( !strcmp (column [i], column_name) ) {
         *offset = i;
         break;
         }
        }

    _PDMdebug (fn, "Offset for %s is [%d] \n", column_name, *offset);
_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS); 
}


int PDMrecreate_validated_dyn_databufr (in_bufr, out_put_bufr)
MEMptr	in_bufr, *out_put_bufr;
{
	char		*fn = "_PDMrecreate_validated_dyn_databufr";
	MEMptr		tmp_bufr = NULL;
	MEMptr		out_bufr = NULL;
	MEMptr		attr_bufr = NULL;
	char		**column, **data, **format;
	char		**attr_data;
        int		k, x, buf_num, offset ;
	char		*mem_str;
        int		found, index, no_bufrs, nxi;

_PDMdebug ("ENTER", "%s\n", fn);


  status = MEMbuild_array (in_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&in_bufr);
    _PDMdebug ( fn, "MEMbuild_query (in_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
     }

  if (PDMdebug_on) {
       MEMprint_buffers ("input bufrs", in_bufr, PDM_DEBUG_FILE);
            }

   status = MEMno_buffers (in_bufr, &no_bufrs);
   if (status != MEM_S_SUCCESS) {
      _PDMdebug(fn, "MEMno_buffers failed status %d\n", status);
      return (PDM_E_RESET_BUFFER);
      }

  if (PDMdebug_on) {
       MEMprint_buffers ("input bufrs", in_bufr, PDM_DEBUG_FILE);
            }

   _PDMdebug (fn, "# of buffers appended = %d\n", no_bufrs);
  
 for (buf_num = 2; buf_num<=no_bufrs; buf_num++){ 
   status = MEMreset_buffer_no (in_bufr, buf_num);
   if (status != MEM_S_SUCCESS) {
     _PDMdebug(fn, "MEMreset_buffer_no failed status %d\n", status);
     return (PDM_E_RESET_BUFFER);
     }
/* 
   status = MEMbuild_array (in_bufr);
   if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (in_bufr) 0x%.8x\n", status );
    return (NFM_E_MEM);
     }
*/

  if (PDMdebug_on) {
        MEMprint_buffer ("current bufr", in_bufr, PDM_DEBUG_FILE);
            }
  
   offset = 0;

   status = _PDMget_cat_index (in_bufr, "n_catalogname", &offset);
   if (status != PDM_S_SUCCESS) {
     _PDMdebug(fn, "_PDMget_cat_index failed status %d\n", status);
     return (status);
     }

   data = (char **) (in_bufr) -> data_ptr;
   column = (char **) (in_bufr) -> column_ptr;
   format = (char **) (in_bufr) -> format_ptr;

   if (attr_bufr) MEMclose (&attr_bufr);

   status = PDMget_attr_bufr_for_dyn_cat (data[offset], &attr_bufr);
   if (status != PDM_S_SUCCESS) {
     _PDMdebug(fn, "_PDMget_attr_bufr_for_dyn_cat failed 0x%.8x\n", status);
     return (status);
     }

   status = MEMbuild_array (attr_bufr);
   if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (in_bufr) 0x%.8x\n", status );
    return (NFM_E_MEM);
     }

  if (PDMdebug_on) {
        MEMprint_buffer ("attr bufr for dyntab attrs", attr_bufr, 
                                                          PDM_DEBUG_FILE);
     }
   
   status = MEMopen(&tmp_bufr,1024);
   if(status != MEM_S_SUCCESS) {
          MEMclose(&out_bufr);
         _PDMdebug (fn, "MEMopen failed status %d\n", status);
         return(PDM_E_OPEN_BUFFER);
         }

   
   attr_data = (char **) (attr_bufr) -> data_ptr;

   status = MEMwrite_format (tmp_bufr, "p_childno", "char(20)");
   if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMwrite_format failed status %d\n",status);
       MEMclose (&tmp_bufr);
       MEMclose (&out_bufr);
       if (mem_str) free (mem_str);
       return(PDM_E_WRITE_FORMAT);
       }

   for (k = 0; k< attr_bufr->rows; k++) {
     index = attr_bufr->columns * k;
     _PDMdebug ("attr", "%s : type [%s]\n", 
                   attr_data[index], attr_data[index+1]);
     status = MEMwrite_format (tmp_bufr, attr_data[index], attr_data[index+1]);
     if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMwrite_format failed status %d\n",status);
       MEMclose (&tmp_bufr);
       MEMclose (&out_bufr);
       if (mem_str) free (mem_str);
       return(PDM_E_WRITE_FORMAT);
       }
      }

     mem_str = (char *) malloc ((((in_bufr) -> row_size) *  10 ) + 128);
     if (! mem_str) {
         _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
         return (NFM_E_MALLOC);
         }
      mem_str[0] ='\0';

   offset = 0;

   status = _PDMget_cat_index (in_bufr, "p_childno", &offset);
   if (status != PDM_S_SUCCESS) {
     _PDMdebug(fn, "_PDMget_cat_index failed status %d\n", status);
     return (status);
     }
 
    strcpy (mem_str, data[offset]);
    strcat (mem_str, "\1");

  
     for (x = 0; x< attr_bufr->rows; x++) {
      nxi = x * attr_bufr->columns;
      found = 0;
      for (k = 0; k< in_bufr->columns; k++) {
      _PDMdebug (fn, "Comparing %s with %s..\n", attr_data[nxi], column[k]);
       if (!strcmp (attr_data[nxi], column[k]) ) {
         found = 1;
         _PDMdebug (fn, "Adding %s to the new bufr\n", data[k]);
         strcat (mem_str, data[k]);
         strcat (mem_str, "\1");
         break;
          }
        }
       if (found == 0 ) 
        strcat (mem_str, "\1");
      }
   
    _PDMdebug ("mem_str", "%s\n", mem_str);
     
     status = MEMwrite (tmp_bufr, mem_str);
     if(status != MEM_S_SUCCESS) {
       MEMclose (&tmp_bufr);
       MEMclose (&out_bufr);
       if (mem_str) free (mem_str);
       _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
       return(status);
        }

     if (mem_str) free (mem_str);

     if (tmp_bufr != NULL) {
       if (out_bufr == NULL) out_bufr = tmp_bufr;
       else {
       status = MEMappend (tmp_bufr, out_bufr);
       if(status != MEM_S_SUCCESS) {
              MEMclose(&out_bufr);
             _PDMdebug (fn, "MEMappend failed status %d\n",status);
             return(status);
             }
  
       if (PDMdebug_on) {
          MEMprint_buffer ("new output bufr ", out_bufr, PDM_DEBUG_FILE);
          }
         }
       }
    }

 /* Whew! it is finally over!! */


  if (PDMdebug_on) {
        MEMprint_buffer ("new output bufr ", out_bufr, PDM_DEBUG_FILE);
   }

  *out_put_bufr = out_bufr;

 if (in_bufr) MEMclose (&in_bufr);

_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS); 
}


int PDMget_attr_bufr_for_dyn_cat (catalog, attr_bufr)
char	*catalog;
MEMptr  *attr_bufr;
{
	char		*fn = "PDMget_attr_bufr_for_dyn_cat";
	char		sql_str[1024];
	char		**data;
	MEMptr		qry_bufr = NULL;
	char		*dyn_table;
	int		tabno;

     _PDMdebug (fn, "Enter\n");
    
    sprintf(sql_str,
     "SELECT t2.p_dyntable FROM nfmcatalogs t1,pdmcatalogs t2 \
      where t1.n_catalogno = t2.n_catalogno AND t1.n_catalogname = '%s'",
      catalog);

    status = SQLquery(sql_str, &qry_bufr,512);
    if(status == SQL_S_SUCCESS) {
       status = MEMbuild_array (qry_bufr);
       if(status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMbuild_array : status = <0x%.8x>\n", status);
         return (status);
             }
       data = (char **) qry_bufr->data_ptr;
       dyn_table = (char *) malloc(strlen (data[0] +2));
       dyn_table [0] = '\0';
       strcpy (dyn_table, data[0]);
       }

    MEMclose (&qry_bufr);

    status = PDMquery_table_no (dyn_table, &tabno);
    if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMget_tableno failed 0x%.8x\n", status);
      free (dyn_table);
      return (status);
      }

    _PDMdebug (fn, "dynamic table no = %d\n", tabno);

    free (dyn_table);

    sprintf (sql_str, 
    "select n_name, n_datatype from nfmattributes where n_tableno = %d ", 
                                           tabno);
    status = SQLquery(sql_str, attr_bufr, 512);
    if (status != SQL_S_SUCCESS) {
      _PDMdebug (fn, "SQL qry for dyn cat attr failed 0x%.8x\n", status);
      MEMclose (attr_bufr);
      return (status);
       }
  
    status = MEMbuild_array (*attr_bufr);
    if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array : status = <0x%.8x>\n", status);
       MEMclose (attr_bufr);
       return (status);
      }
     
    _PDMdebug(fn,"Exit:\n");
   return(PDM_S_SUCCESS);
}
  
