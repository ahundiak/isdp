#include "machine.h"
#include "NFMU.h"
#include "WFstruct.h"
#include "NFMfto_buf.h"
#include "WFcommands.h"
#include "NFMitemfiles.h"
#include "memory.h"

extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal ;
extern long DM_MANAGER;
extern long NFM_FTR_INITED;

     char     sname[100];
     struct   stat snamebuffer; 

/* Duke Power Duplicate Problem 
   To make to the code efficient, PR_TRANS macro is controlled 
   by PRINT_TRANS switch which could be defined in the makefile
                                                      -- Jujare 
*/
     char        time_str[50];
     extern long NFM_TRANSACTION;
     char        *NFM_gettime(void);
     long        NFMsharelock_table(char *);

#ifdef PRINT_TRANS 
#define PR_TRANS()  _NFMdebug ((fname, "NFM_TRANSACTION:<%d>:<%s>\n",NFM_TRANSACTION, NFM_gettime()));
#else
#define PR_TRANS()   {};
#endif 

/* End - Duke Power Duplicate Problem -- Jujare */ 

 long NFMcopy_item_n (cat_name,
		    attr_cat, data_cat, attr_f_cat, data_f_cat)
   char    *cat_name;
   MEMptr  attr_cat;
   MEMptr  data_cat;
   MEMptr  attr_f_cat;
   MEMptr  data_f_cat;
   {
     static char *fname = "NFMcopy_item_n" ;
     long     status, item_state ;
     long     item_no, i, acl_no =-1, action_pos =-1, move_files, offset ;
     long     original_item_no, cat_no, original_acl ;
     long     checkin_state, new_state ;
     MEMptr   buffer = NULL ;
     char     sql_str [1000], fcat_name[NFM_TABLENAME+1] ;
     long     _NFMadd_catalog_entry ();
     long     _NFMadd_file_catalog_entry ();
     long     _NFMadd_file_catalog_entry_and_copy ();
     char     **data, **column ;
     char     checkin_command [NFM_COMMANDNAME+1] ;
     char     add_command [NFM_COMMANDNAME+1] ;

/* Duke Power Duplicate Problem -- Jujare */ 
     char        cat_fcat[50];
/* End - Duke Power Duplicate Problem -- Jujare */ 

     _NFMdebug ((fname, "table name  = <%s>\n", cat_name));

     if (WFinfo.catalog_no > 0)
       {
	 cat_no = WFinfo.catalog_no ;
       }
     else
       {
	 status = NFMget_catalog_no (NFMglobal.NFMuserid, cat_name, &cat_no) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Bad Catalog No : catalog %s : status = <0x%.8x>\n",
			 cat_name, status)) ;
	     return (status) ;
	   }
       }

     status = MEMbuild_array (data_cat) ;
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 _NFMdebug ((fname, "MEMbuild_array : data_cat : status = <0x%.8x>\n",
		     status)) ;
	 return (NFM_E_MEM) ;
       }

     data = (char **) data_cat -> data_ptr ;
     column = (char **) data_cat -> column_ptr ;
     acl_no = -1 ;
     original_acl = -1 ;

     for (i=0; i<data_cat->columns; i++)
       {
	 if (strcmp (column [i], "n_aclno") == 0)  
	   {
	     acl_no = atol (data [i]) ;
	     if (acl_no != -1) break ;
	   }
/*********
	 else if (strcmp (column [i], "original_aclno") == 0)
	   {
	     original_acl = atol (data [i]) ;
	   }
*************/
       }

/*****
     _NFMdebug ((fname, "Acl for this 'new' item is <%d> : original item's acl is <%d>\n",
		 acl_no, original_acl)) ;

     if (acl_no == -1)
       {
	 / * get acl no from original item * /
	 acl_no = original_acl ;
       }
**********/
     /* if files are to be copied */
     status = MEMbuild_array (data_f_cat) ;
     if (status != MEM_S_SUCCESS)
       {
	 ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	 _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }
     move_files = 0 ;
     if (data_f_cat -> rows > 0) 
       {
     data = (char **) data_f_cat -> data_ptr ;
     column = (char **) data_f_cat -> column_ptr ;
     for (i=0; i<data_f_cat->columns; i++)
       {
	 if (strcmp (column [i], "n_action") == 0)  
	   {
	     action_pos = i ;
	     break ;
	   }
       }

     for (i=0; i<data_f_cat->rows; i++)
       {
	 offset = i*data_f_cat->columns ;
	 if (strcmp (data [offset + action_pos], "") != 0)  
	   {
	     move_files = 1 ;
	     break ;
	   }
       }
   }
     
    /*tmpMahesh
       if (move_files) _NFMdebug ((fname, "files exist\n")) ;
    */
     
     sprintf (add_command, ADD_ITEM) ;

     /* get initial add item state */
     sprintf (sql_str, "Select DISTINCT nfmtransitions.n_tostate \
FROM nfmacls,nfmtransitions \
WHERE nfmacls.n_aclno = %d AND \
((nfmtransitions.n_commandno in (select n_commandno from nfmcommands where n_commandname = '%s')) OR \
 (nfmtransitions.n_commandno in (select n_nfmcommandno from nfmcommands where n_commandname = '%s'))) AND \
  nfmtransitions.n_workflowno = nfmacls.n_workflowno",
		  acl_no, add_command, add_command) ;

          status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
          if (status != SQL_S_SUCCESS)
          {
              ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
              _NFMdebug ((fname, "SQLquery failed : status = <0x%.8x>\n",
                          status)) ;
              return (NFM_E_SQL_QUERY) ;
          }
          if (buffer->rows != 1)
           {
             _NFMdebug ((fname, "Multiple transition : status = <0x%.8x>\n",
                         status));
             ERRload_struct (NFM, NFM_E_MULTIPLE_TRANSITIONS, "", "") ;
             return (NFM_E_MULTIPLE_TRANSITIONS) ;
           }

          status = MEMbuild_array (buffer) ;
          if (status != MEM_S_SUCCESS) 
          {
              ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
                          status)) ;
              return (NFM_E_MEM) ;
          }
          data = (char **) buffer->data_ptr ;
          item_state = atol (data [0]) ;
          new_state = item_state ;
          status = MEMclose (&buffer) ;
          if (status != MEM_S_SUCCESS)
          {
              ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n", status)) ;
              return (NFM_E_MEM) ;
          }

if (move_files)
{
  strcpy (checkin_command, CHECKIN_ITEM) ;
	 /* get initial checkin state no */
	 sprintf (sql_str, "Select DISTINCT nfmtransitions.n_tostate \
FROM nfmtransitions, nfmacls \
  WHERE nfmacls.n_aclno = %d AND \
nfmtransitions.n_fromstate = %d AND \
  ((nfmtransitions.n_commandno in (select n_commandno from nfmcommands where n_commandname = '%s')) OR \
  (nfmtransitions.n_commandno in (select n_nfmcommandno from nfmcommands where n_commandname = '%s'))) AND \
  nfmtransitions.n_workflowno = nfmacls.n_workflowno",
		  acl_no, item_state, checkin_command, checkin_command);
          status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
          if (status != SQL_S_SUCCESS)
          {
	    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	    _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
              return (NFM_E_SQL_QUERY) ;
          }
          if (buffer->rows != 1)
           {
	     _NFMdebug ((fname, "Failure : Multiple transitions: status = <0x%.8x>\n",
			 status)) ;
	     ERRload_struct (NFM, NFM_E_MULTIPLE_TRANSITIONS, "", "") ;
	     return (NFM_E_MULTIPLE_TRANSITIONS) ;
           }
          status = MEMbuild_array (buffer) ;
          if (status != MEM_S_SUCCESS) 
          {
	    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	    _NFMdebug ((fname, "MEMbuld array : status = <0x%.8x>\n", status));
              return (NFM_E_MEM) ;
          }
          data = (char **) buffer->data_ptr ;
          checkin_state = atol (data [0]) ;
          if ((checkin_state == 1) || (checkin_state == 0)) ;
             else
           new_state = checkin_state ;
/**** mms - I put I new variable, in case they cancelled out of the
  2nd form (no files attached, I will update the state
           item_state = checkin_state ;
***********/
	    
	 status = MEMclose (&buffer) ;
	 if (status != MEM_S_SUCCESS)
	   {
	     ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	     _NFMdebug ((fname, "MEMclose : status = <0x%.8x>\n",
			 status)) ;
	     return (NFM_E_MEM) ;
	   }
       }
     status = NFMset_autocommit_off (0) ;
     if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname, "Set Autocommit off : status = <0x%.8x>\n", 
		   status)) ;
       return (status) ;
     }


/* Duke Power Duplicate Problem -- Jujare */ 

     _NFMdebug ((fname, "Locking tables <%s> and f_<%s>:<%s>\n",cat_name,
                 cat_name,NFM_gettime())); 
     PR_TRANS(); 
     sprintf(cat_fcat,"%s, f_%s",cat_name,cat_name);   
     PR_TRANS(); 
     status = NFMsharelock_table (cat_fcat);                
     PR_TRANS();
     if (status != NFM_S_SUCCESS) 
     { 
       _NFMdebug ((fname, "UNSUCCESSFUL Locking of <%s> and f_<%s>:<%s>: \
             status = <0x%.8x>\n", cat_name,cat_name,NFM_gettime(),status));
       return (status) ;
     }
     _NFMdebug ((fname, "SUCCESSFUL Locking of <%s> and f_<%s>:<%s>\n", 
                 cat_name,cat_name,NFM_gettime()));   

/* End - Duke Power Duplicate Problem -- Jujare */ 

  PR_TRANS();
     status = _NFMadd_catalog_entry (cat_name, &item_no, &original_item_no,
				     attr_cat, data_cat, new_state,
				     &move_files);
  PR_TRANS();

     if (status != NFM_S_SUCCESS)
      {
  PR_TRANS();
	NFMrollback_transaction (0) ;
  PR_TRANS();
        _NFMdebug ((fname, "Make Item Entry : status = <0x%.8x>\n", status));
        return (status);
      }

     sprintf (fcat_name, "f_%s", cat_name);

     if (move_files)
     {
  PR_TRANS();
       status = _NFMadd_file_catalog_entry_and_copy (cat_name, cat_no, 
						     item_no, original_item_no,
						     attr_f_cat, data_f_cat);
  PR_TRANS();
     }
     else
    {
      if (new_state != item_state)
	{
	  sprintf (sql_str, "update %s set n_stateno = %d where n_itemno = %d",
		   cat_name, item_state, item_no) ;
  PR_TRANS();
	  status = SQLstmt (sql_str) ;
  PR_TRANS();
	  if (status != SQL_S_SUCCESS)
	    {
  PR_TRANS();
	      NFMrollback_transaction (0) ;
  PR_TRANS();
	      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	      return (NFM_E_SQL_STMT) ;
	    }
	}
  PR_TRANS();
      status = _NFMadd_file_catalog_entry (cat_name, item_no, data_f_cat) ;
  PR_TRANS();
    }

     if (status != NFM_S_SUCCESS)
      {
  PR_TRANS();
	NFMrollback_transaction (0) ;
  PR_TRANS();
        _NFMdebug ((fname, "Make File Entry : status = <0x%.8x>\n", status));
        return (status);
      }

  PR_TRANS();
     status = NFMset_autocommit_on (0) ;
  PR_TRANS();
     if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname, "Set autocommit on : status = <0x%.8x>\n",status));
       return (status) ;
     }


/* Duke Power Duplicate Problem -- Jujare */ 
  _NFMdebug ((fname, "Completed NFMset_autocommit_on for <%s> and f_<%s> \n", cat_name,cat_name));
  _NFMdebug ((fname, "At :  <%s> \n", NFM_gettime()));
/* End - Duke Power Duplicate Problem -- Jujare */ 

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
}    

 long _NFMadd_catalog_entry (cat_name, item_no, original_item_no,
                            attr_list, data_list, stateno, move_files)
   char    *cat_name;
   long    *item_no;
   long    *original_item_no ;
   MEMptr  attr_list, data_list;
   long    stateno ; 
   long    *move_files ;
   {
     static char *fname = "_NFMadd_catalog_entry" ;
     long    status, insert ;
     char    **column, **data, **data1;
     long    a, b, c, x, y, count, i, acl_pos ;
     char    *sql_str, *sql_str1, date [50] ;
     long    check;
     char    sql_str2 [1024], attr_name [100], out_str [50];
     char    value [50] ;
     char    original_item_status [NFM_STATUS+1] ;

     *item_no = 0;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d>\n", 
		 cat_name, *item_no));

     status = MEMbuild_array (attr_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (data_list);
     if (status != MEM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
      }

     column = (char **) attr_list -> column_ptr;
     data   = (char **) attr_list -> data_ptr;

     data1  = (char **) data_list -> data_ptr;

     a = -1; b = -1; c = -1;

     for (y = 0; y < attr_list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))      a = y;
        else if (! strcmp (column [y], "n_datatype"))  b = y;
      }

     sql_str = (char *) malloc (50 * attr_list -> rows +
                                     data_list -> row_size);
     if (! sql_str)
      {
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str1 = (char *) malloc (50 * attr_list -> rows +
                                 data_list -> row_size);
     if (! sql_str1)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
        _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
        NFM_E_MALLOC));
        return (NFM_E_MALLOC);
      }

     sql_str [0] = 0;  sql_str1 [0] = 0; 

     status = NFMget_RISdatetime (date) ;
     if (status != NFM_S_SUCCESS)
      {
        free (sql_str);
	_NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	return (status) ;
      }

     sprintf (sql_str,  "INSERT INTO %s (n_stateno, n_creator, n_creationdate, n_itemlock ", cat_name);
     sprintf (sql_str1, ") VALUES (%d, '%s', TIMESTAMP '%s', 'N' ", 
	      stateno, NFMglobal.NFMusername, date) ;

     sprintf (sql_str2, "WHERE ");
     check = 0;

     i = -1;
     acl_pos = -1 ;
     for (x = 0; x < attr_list -> rows; ++x)
      {
         count = attr_list -> columns * x;
         insert = 0;

         if (! strcmp (data [count + a], "original_itemno")) 
          {
	    *original_item_no = atol (data1 [x]) ;
	    _NFMdebug ((fname, "original item no is %d\n", *original_item_no));
            insert = 1;

            status = NFMget_serial_slot (NFMglobal.NFMuserid, cat_name,
                     "n_itemno", item_no);
            if (status != NFM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               _NFMdebug ((fname, "Get Serial No : status = <0x%.8x>\n",
               status));
               return (status);
             }

            sprintf (value, "%d", *item_no);
	    strcpy (attr_name, "n_itemno") ;

            status = MEMwrite_data (data_list, value, 1, x + 1);
            if (status != MEM_S_SUCCESS)
             {
               free (sql_str);
               free (sql_str1);
               ERRload_struct (NFM, NFM_E_MEM, "", NULL);
               _NFMdebug ((fname, "Write Data : status = <0x%.8x>\n",
			   status));
               return (NFM_E_MEM);
             }
          }
         else if (! strcmp (data [count + a], "original_status"))
          {
	    strcpy (original_item_status, data1 [x]) ;
	     strcpy (attr_name, "n_status") ;
	    _NFMdebug ((fname, "status of original item is %s\n",
			data1 [x])) ;
	    if (! strcmp (original_item_status, ""))
	      *move_files = 0 ;
	    else if ( strcmp (original_item_status, "I"))
	      {
		_NFMdebug ((fname, "Warning : Original Item is checked out\n"));
/*		ERRload_struct (NFM, NFM_W_MESSAGE, "%s",
				"Warning : Original Items is Checked Out") ; */
	      }

	    if (*move_files)
	      {
		insert = 1;
		status = MEMwrite_data (data_list, "I", 1, x + 1);
		if (status != MEM_S_SUCCESS)
		  {
		    free (sql_str);
		    free (sql_str1);
		    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
		    _NFMdebug ((fname, "Write Data : status = <0x%.8x>\n",
				status));
		    return (NFM_E_MEM);
		  }
	      }
	    else
	      insert = 0 ;
          }
         else if (! strcmp (data [count + a], "n_aclno"))
	   {
	     acl_pos = a ;
	     strcpy (attr_name, data [count + a]) ;
	     insert = 1;
	   }
         else if (! strcmp (data [count + a], "original_aclno"))
          {
/*	    strcpy (original_acl, data1 [x]) ; */
	    insert = 0 ;
          }
         else if ((! strcmp (data [count + a], "n_updater")) ||
		  (! strcmp (data [count + a], "n_updatedate")) || 
		  (! strcmp (data [count + a], "n_colevel")) ||
		  (! strcmp (data [count + a], "n_itemno")) ||
		  (! strcmp (data [count + a], "n_archivestate")) ||
		  (! strcmp (data [count + a], "n_prevstateno")) ||
		  (! strcmp (data [count + a], "n_creator")) ||
		  (! strcmp (data [count + a], "n_creationdate")) ||
		  (! strcmp (data [count + a], "n_status")) ||
/* mms -09/13/92 copy_set (! strcmp (data [count + a], "n_setindicator")) || */
		  (! strcmp (data [count + a], "n_stateno")) ||
		  (! strcmp (data [count + a], "n_itemlock")) ||
		  (! strcmp (data [count + a], "n_pendingflag")))
	   {
	     insert = 0;
	   }
         else if (strlen (data1 [x])) 
	   {
	     strcpy (attr_name, data [count + a]) ;
	     insert = 1;
	   }
         else if (! strcmp (data [count + a], "n_itemrev"))
	   {
	     strcpy (attr_name, data [count + a]) ;
	     insert = 2;
	   }

         if (insert)
          {
	    strcat (sql_str,  ", ");
	    strcat (sql_str1, ", ");
	    
    /*            strcat (sql_str, data [count + a]); */
	    strcat (sql_str, attr_name) ;

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str1, "'");
		if(insert != 2 )
               		strcat (sql_str1, data1 [x]);
               strcat (sql_str1, "'");
             }
	    else if (! strcmp (data [count + b], "timestamp"))
	      {
                status = NFMascii_to_timestamp_format (data1 [x], out_str) ;
                if (status != NFM_S_SUCCESS)
                  {
                    _NFMdebug ((fname,"ascii to timestamp:status = <0x%.8x>\n",
                                status)) ;
                    return (status) ;
                  }

		strcat (sql_str1, "TIMESTAMP '") ;
		strcat (sql_str1, out_str);
		strcat (sql_str1, "'") ;
	      }
            else
             {
               if (strlen (data1 [x])) strcat (sql_str1, data1 [x]);
               else                    strcat (sql_str1, "null");   
             }
          }
      }
/******* if n_aclno is not in the buffer then insert original_acl * /
     if (acl_pos == -1)
     {
       strcat (sql_str, ", n_aclno") ;
       sprintf (tmp_str, ", %s", original_acl) ;
       strcat (sql_str1, tmp_str) ;
     }
*************/

     strcat (sql_str, sql_str1);
     strcat (sql_str, ")");

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        free (sql_str1);

        if (status == SQL_E_DUPLICATE_VALUE)
         {
           ERRload_struct (NFM, NFM_E_DUP_ITEM, "", NULL);
           _NFMdebug ((fname, "Item Exists : status = <0x%.8x>\n",
           NFM_E_DUP_ITEM));
           return (NFM_E_DUP_ITEM);
         }

        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     free (sql_str);
     free (sql_str1);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }

 long _NFMadd_file_catalog_entry_and_copy (cat_name, cat_no, item_no,
                                 original_item_no,
                                 attr_list, data_list)
char    *cat_name ;
long    cat_no ;
long    item_no;
long    original_item_no ; 
MEMptr  attr_list, data_list;
{
  static char *fname = "_NFMadd_file_catalog_entry_and_copy" ;
  MEMptr  move_buffer = NULL ;
  struct sto_area_info ;
  long    status, file_no =-1, original_file_no =0, netid ;
  long    source_sano =0 , dest_sano  =0, n_filenum ;
  char    **column, **data, **data1, **column1 ;
  long    a, b, x, y, count, insert, action_add, offset ;
  long    i_fileclass=-1;
  char f_string[20];
  char    *sql_str, *sql_str1 ;
  char    file_no_str[50], out_str [50], where_str[50];
  char    source_file [NFM_COFILENAME+1], dest_file [NFM_COFILENAME+1], date [50] ;
  char    file_cat [NFM_TABLENAME+1] ;
  char    original_cifilename [NFM_CIFILENAME+1] ;
  long    cisano_pos =-1, cifilename_pos =-1 ;
  struct  fto_buf file_buffer ;

  _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d>\n", 
	      cat_name, item_no));

  original_item_no = original_item_no ;


  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		    status));
        return (NFM_E_MEM);
    }
  
  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFMdebug ((fname, "MEM Build Array : status = <0x%.8x>\n",
		  status));
      return (NFM_E_MEM);
    }
  
  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;
  
  data1  = (char **) data_list -> data_ptr;
  column1 = (char **) data_list -> column_ptr;
  
  a = -1; b = -1; 
  
  for (y = 0; y < attr_list -> columns; ++y)
    {
      if (! strcmp (column [y], "n_name"))      a = y;
      else if (! strcmp (column [y], "n_datatype"))  b = y;
    }

  for (y = 0; y < data_list -> columns; ++y)
  {
      _NFMdebug ((fname, "column1 %s\n", column1[y]));
      if (! strcmp (column1 [y], "n_fileclass"))  i_fileclass = y;
  }

  PR_TRANS();
  status = NFMget_RISdatetime (date) ;
  PR_TRANS();
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  n_filenum = 1;
  for (y=0; y<data_list->rows; y ++)
    {
      offset = y*data_list->columns ;
      sql_str = (char *) malloc (50 * attr_list -> rows +
				 data_list -> row_size + 512);
      if (! sql_str)
	{
  PR_TRANS();
	  _NFMundo_copied_files (data_list, y-1,
				 cisano_pos, cifilename_pos,
				 cat_name, cat_no, item_no) ;
  PR_TRANS();
	  ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	  _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		      NFM_E_MALLOC));
	  return (NFM_E_MALLOC);
	}
      
      sql_str1 = (char *) malloc (50 * attr_list -> rows +
				  data_list -> row_size + 512);
      if (! sql_str1)
	{
  PR_TRANS();
	  _NFMundo_copied_files (data_list, y-1,
				 cisano_pos, cifilename_pos,
				 cat_name, cat_no, item_no) ;
  PR_TRANS();
	  free (sql_str);
	  ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
	  _NFMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n",
		      NFM_E_MALLOC));
	  return (NFM_E_MALLOC);
	}
      

     sprintf (file_cat, "f_%s", cat_name) ;
  PR_TRANS();
      status = NFMget_attr_value (NFMglobal.NFMuserid, file_cat, 
				  "max(n_fileno)",
				  "", file_no_str);
  PR_TRANS();
      if (status != NFM_S_SUCCESS)
	{
  PR_TRANS();
	  _NFMundo_copied_files (data_list, y-1,
				 cisano_pos, cifilename_pos, 
				 cat_name, cat_no, item_no) ;
  PR_TRANS();
	  _NFMdebug ((fname, "NFMget_attr_value : status = <0x%.8x>\n",
		      status));
	  return (status);
	}
      file_no = atol (file_no_str) + 1;
      

/* Duke Power Duplicate Problem -- Jujare */ 
     _NFMdebug ((fname, "Trying to Insert n_fileno = <%d>\n",file_no));
/* End -  Duke Power Duplicate Problem -- Jujare */ 

      sql_str [0] = 0;  sql_str1 [0] = 0; 
      
      sprintf (sql_str,  "INSERT INTO f_%s (n_itemnum, n_fileno, n_fileversion,n_filenum, n_cidate, n_ciuser, n_fileco %s ",
	       cat_name, (i_fileclass > -1? ", n_fileclass": "") );
      if (i_fileclass > -1)
      {
        sprintf (f_string, ", '%s'", data1[offset+i_fileclass]);
      }
      else
        f_string[0] = '\0';

      sprintf (sql_str1, 
               ") VALUES (%d, %d, 1, %d, TIMESTAMP '%s', '%s', 'N' %s ",
	       item_no, file_no, n_filenum, date, NFMglobal.NFMusername,
               f_string);
      ++n_filenum ;
      

      action_add = 0 ;
      cifilename_pos = -1 ;
      dest_file [0] = 0 ;
      dest_sano = -1 ;
      cisano_pos  = -1 ;
      for (x=0; x<attr_list->rows; x++)
	{	
	  insert = 0;
	  count = attr_list -> columns * x;
	  
	  if (! strcmp (data [count + a], "original_fileno"))
	    {
	      insert = 0 ;
	      original_file_no = atol (data1 [offset+x]) ;
	    }
	  else if ((! strcmp (data [count + a], "n_filenum")) ||
		   (! strcmp (data [count + a], "n_fileno")) ||
		   (! strcmp (data [count + a], "n_itemnum")) ||

		   (! strcmp (data [count + a], "n_cocomment")) ||
		   (! strcmp (data [count + a], "n_fileversion")) ||
		   (! strcmp (data [count + a], "n_fileclass")) ||
		   (! strcmp (data [count + a], "n_fileco")) || 
		   (! strcmp (data [count + a], "n_restoreflag")) ||
		   (! strcmp (data [count + a], "n_archiveno")) ||
		   (! strcmp (data [count + a], "n_filesize")) ||
		   (! strcmp (data [count + a], "n_ciuser")) ||
		   (! strcmp (data [count + a], "n_cidate")) ||
		   (! strcmp (data [count + a], "n_cosano")) ||
		   (! strcmp (data [count + a], "n_couser")) ||
		   (! strcmp (data [count + a], "n_codate")) ||
		   (! strcmp (data [count + a], "n_covertind")))
	    {
	      insert = 0 ;
	    }
         else if (! strcmp (data [count + a], "n_cifilename"))
          {
	    cifilename_pos = x ;
/** destination  - new file ***/
            if (strlen (data1 [offset+x])) 
	      {
		strcpy (dest_file, data1 [offset+x]) ;
		/* get encrypted name do not insert and move destination
                   is encrypted */
		insert = 1 ;
	      }
	    else
	      {
		/* get itemno and fileno of original item */
  PR_TRANS();
		status = NFMget_file_name(NFMglobal.NFMuserid,
					  cat_no, file_no,
					  dest_file) ;
  PR_TRANS();
		if (status != NFM_S_SUCCESS)
		  {
  PR_TRANS();
		    _NFMundo_copied_files (data_list, y-1,
					   cisano_pos, cifilename_pos, 
					   cat_name, cat_no, item_no) ;
  PR_TRANS();
		    _NFMdebug ((fname, "Get file Name : status = <0x%.8x>\n",
				status)) ;
		    return (status) ;
		  }
		insert = 0 ;
	      }
          }
         else if (! strcmp (data [count + a], "original_cifilename"))
          {
/** source  - original file ***/
	    strcpy (original_cifilename, data1 [offset+x]) ;
	    insert = 0 ;
          }
         else if (! strcmp (data [count + a], "n_cisano"))
          {
	    cisano_pos = x ;
	    _NFMdebug ((fname, "cisano is %s\n", data1 [offset+x])) ;
	    dest_sano = atol (data1 [offset+x]) ;
	    if (dest_sano < 0)
	      {
  PR_TRANS();
		_NFMundo_copied_files (data_list, y-1,
				       cisano_pos, cifilename_pos, 
				       cat_name, cat_no, item_no) ;
  PR_TRANS();
		_NFMdebug ((fname, "Failure : Internal storage not specified for the new item\n")) ;
		ERRload_struct (NFM, NFM_E_ISA_REQUIRED, "", "") ;
		return (NFM_E_ISA_REQUIRED) ;
	      }
	    insert = 1 ;
          }
         else if (! strcmp (data [count + a], "original_cisano"))
          {
	    _NFMdebug ((fname, "source cisano is %s\n", data1 [offset+x])) ;
	    source_sano = atol (data1 [offset+x]) ;
	    if (source_sano < 0)
	    {
  PR_TRANS();
	      _NFMundo_copied_files (data_list, y-1,
				     cisano_pos, cifilename_pos, 
				     cat_name, cat_no, item_no) ;
  PR_TRANS();
	      _NFMdebug ((fname, "Failure : Bad Internal storage for original item\n")) ;
		ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", "") ;
		return (NFM_E_BAD_ST_AREA) ;
	    }
	    insert = 0 ;
          }
         else if (! strcmp (data [count + a], "n_action"))
	   {
	     if (strcmp (data1 [offset+x], "ADD") == 0)
	       {
		 action_add = 1 ;
	       }
	     insert = 0 ;
	   }
/********* mms - Not needed ******
  else if (! strcmp (data [count + a], "n_ciuser"))
  {
  insert = 1;
  status = MEMwrite_data (data_list, NFMglobal.NFMusername, 
  y+1, x + 1);
  if (status != MEM_S_SUCCESS)
  {
  _NFMundo_copied_files (data_list, y-1,
  cisano_pos, cifilename_pos, 
  cat_name, cat_no, item_no) ;
  free (sql_str);
  free (sql_str1);
  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
  _NFMdebug ((fname, "Write Data : status = <0x%.8x>\n",
  status));
  return (NFM_E_MEM);
  
  }
  }
  else if (! strcmp (data [count + a], "n_cidate"))
  {
  insert = 1;
  status = NFMget_datetime (date) ;
  if (status != NFM_S_SUCCESS)
  {
  _NFMundo_copied_files (data_list, y-1,
  cisano_pos, cifilename_pos,
  cat_name, cat_no, item_no) ;
  _NFMdebug ((fname, "Failure : Bad ethnic date : status = <0x%.8x>\n",  status)) ;
  return (status) ;
  }
  
  status = MEMwrite_data (data_list, date, y+1, x + 1);
  if (status != MEM_S_SUCCESS)
  {
  _NFMundo_copied_files (data_list, y-1,
  cisano_pos, cifilename_pos,
  cat_name, cat_no, item_no) ;
  free (sql_str);
  free (sql_str1);
  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
  _NFMdebug ((fname, "Write Data : status = <0x%.8x>\n",
  status));
  return (NFM_E_MEM);
  }
  }
**************************/
/****** duplicate *******
  else if ((! strcmp (data [count + a], "n_archiveno")) ||
  (! strcmp (data [count + a], "n_fileco")) ||
  (! strcmp (data [count + a], "n_cocomment")) ||
  (! strcmp (data [count + a], "n_couser")) ||
  (! strcmp (data [count + a], "n_codate")))
  insert = 0 ;
  ***************************/
         else if (strlen (data1 [x]))  insert = 1;

         if (insert)
          {
	    strcat (sql_str,  ", ");
	    strcat (sql_str1, ", ");
	    
            strcat (sql_str, data [count + a]);

            if (! strncmp (data [count + b], "char", 4))
             {
               strcat (sql_str1, "'");
               strcat (sql_str1, data1 [offset+x]);
               strcat (sql_str1, "'");
             }
	    else if (! strcmp (data [count+b], "timestamp"))
	      {
                status = NFMascii_to_timestamp_format (data1 [x], out_str) ;
                if (status != NFM_S_SUCCESS)
                  {
  PR_TRANS();
		    _NFMundo_copied_files (data_list, y-1,
					   cisano_pos, cifilename_pos,
					   cat_name, cat_no, item_no) ;
  PR_TRANS();
		    _NFMdebug ((fname,"ascii to timestamp:status = <0x%.8x>\n",
                                status)) ;
                    return (status) ;
                  }

		strcat (sql_str1, "TIMESTAMP '") ;
		strcat (sql_str1, out_str);
		strcat (sql_str1, "'") ;
	      }
            else
             {
               if (strlen (data1 [offset+x])) 
		 strcat (sql_str1, data1 [offset+x]);
               else                    strcat (sql_str1, "null");   
             }
          }
      } /* x */

      /* if n_cisano is not in buffer write n_cisano = <source cisano> 
	 if (cisano_pos == -1)
	 {
	 strcat (sql_str, ", n_cisano") ;
	 sprintf (tmp_str, ", %d", source_sano) ;
	 strcat (sql_str1, tmp_str) ;
	 }
	 *******************************/

      strcat (sql_str, sql_str1);
      strcat (sql_str, ")");
      _NFMdebug ((fname, "action add is %d\n", action_add)) ;
      
      if (action_add)
	{
	  /* load source location */
  PR_TRANS();
	  status = _NFMget_sano_info_fto_buf (source_sano,
					      "",
					      &file_buffer) ;
  PR_TRANS();
	  if (status != NFM_S_SUCCESS)
	    {
  PR_TRANS();
              _NFMundo_copied_files (data_list, y-1,
                                     cisano_pos, cifilename_pos,
                                     cat_name, cat_no, item_no) ;
  PR_TRANS();
 	      _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }
	  
	  status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
	  if (status != NFM_S_SUCCESS)
	    {
  PR_TRANS();
              _NFMundo_copied_files (data_list, y-1,
                                     cisano_pos, cifilename_pos,
                                     cat_name, cat_no, item_no) ;
  PR_TRANS();
 	      _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }
	  
	  status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
	  if (status != NFM_S_SUCCESS)
	    {
  PR_TRANS();
              _NFMundo_copied_files (data_list, y-1,
                                     cisano_pos, cifilename_pos,
                                     cat_name, cat_no, item_no) ;
  PR_TRANS();
 	      _NFMdebug ((fname, "Loading first row failed : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }
	  
	  /* load destination location 
	     if (dest_sano == -1)
	     {
	     / * n_cisano was not in the buffer -> default to source sano * /
	     dest_sano = source_sano ;
	     }
	     *****************/
	  
	  _NFMdebug ((fname, "storage location for new item is <%d> : storage location for original item is <%d>\n",
		      dest_sano, source_sano)) ;

	  status = _NFMget_sano_info_fto_buf (dest_sano,
					      "",
					      &file_buffer) ;
	  if (status != NFM_S_SUCCESS)
	    {
  PR_TRANS();
              _NFMundo_copied_files (data_list, y-1,
                                     cisano_pos, cifilename_pos,
                                     cat_name, cat_no, item_no) ;
  PR_TRANS();
 	      _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }
	  strcpy (sname, file_buffer.n_pathname); 

	  if (strlen (original_cifilename)) 
	    {
	      strcpy (source_file, original_cifilename) ;
	      /* get encrypted name do not insert and move destination
		 is encrypted */
	    }
	  else
	    {
	      /* get itemno and fileno of original item */
  PR_TRANS();
	      status = NFMget_file_name(NFMglobal.NFMuserid,
					cat_no, original_file_no,
					source_file) ;
  PR_TRANS();
	      if (status != NFM_S_SUCCESS)
		{
  PR_TRANS();
		  _NFMundo_copied_files (data_list, y-1,
					 cisano_pos, cifilename_pos,
					 cat_name, cat_no, item_no) ;
  PR_TRANS();
		  _NFMdebug ((fname, "Failure : Bad file name : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	    }
	  
	  /* if n_cifilename is not writable for this catalog -> dest_file must be encrypted name */
	  if (! strlen (dest_file))
	    {
	      /* get itemno and fileno of original item */
  PR_TRANS();
	      status = NFMget_file_name(NFMglobal.NFMuserid,
					cat_no, file_no,
					dest_file) ;
  PR_TRANS();
	      if (status != NFM_S_SUCCESS)
		{
  PR_TRANS();
		  _NFMundo_copied_files (data_list, y-1,
					 cisano_pos, cifilename_pos, 
					 cat_name, cat_no, item_no) ;
  PR_TRANS();
		  _NFMdebug ((fname, "Get file Name : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}
	    }
	  strcpy (file_buffer.n_cifilename, dest_file) ;
	  strcpy (file_buffer.n_cofilename, source_file) ;
/* **** addition by NAIDU for TR# 249502599(DMMGR). Date 22, Aug 1995 ****** */
      sprintf(where_str, "where n_itemnum = %d and n_fileno = %d", original_item_no, original_file_no);
      status = NFMget_attr_value (NFMglobal.NFMuserid, file_cat, 
				  "n_filetype",
				  where_str, file_no_str);
	  if(!strcmp(file_buffer.n_filetype , ""))
	  	strcpy(file_buffer.n_filetype, file_no_str);
	  file_buffer.n_fileno  = file_no;
/* **** addition by NAIDU 22, Aug 1995 ****** */
	  file_buffer.n_status1 = NFM_MOVE ;
	  
	  status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
	  if (status != NFM_S_SUCCESS)
	    {
  PR_TRANS();
              _NFMundo_copied_files (data_list, y-1,
                                     cisano_pos, cifilename_pos,
                                     cat_name, cat_no, item_no) ;
  PR_TRANS();
 	      _NFMdebug ((fname, "Loading second row failed : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }
	  
          
          _NFMdebug ((fname, "pathname = %s\n", file_buffer.n_pathname));
	  strcpy (sname, file_buffer.n_pathname); 
	  if ( (!strcmp (dest_file, source_file)) &&
	      (source_sano == dest_sano))
	    {
  PR_TRANS();
              _NFMundo_copied_files (data_list, y-1,
                                     cisano_pos, cifilename_pos,
                                     cat_name, cat_no, item_no) ;
  PR_TRANS();
 	      _NFMdebug ((fname, "internal storagearea and internal filename can not be the same as the original item\n")) ;
	      ERRload_struct (NFM, NFM_E_DUP_II, "", NULL);
	      return (NFM_E_MESSAGE) ;
	    }


          _NFMdebug ((fname, "sname = %s\n", sname));
          strcat(sname,"/");
	  strcat(sname,dest_file);
          _NFMdebug ((fname, "sname = %s\n", sname));
	  /* snamebuffer = ( struct stat *) malloc(100); */
	  if ( stat(sname, &snamebuffer) == 0 )
	  {
  PR_TRANS();
	     _NFMundo_copied_files (data_list, y-1,
                                     cisano_pos, cifilename_pos,
                                     cat_name, cat_no, item_no) ;
  PR_TRANS();
              _NFMdebug ((fname, " Internal file name already exists in the check in storage area\n"));
              ERRload_struct (NFM, NFM_E_CI_FILENAME_EXISTS, "", NULL);
              return (NFM_E_MESSAGE) ;
	  }

  PR_TRANS();
	  status = _NFMfs_send_files (&move_buffer,  &netid, 1) ;
  PR_TRANS();
	  if (status != NFM_S_SUCCESS)
	    {
  PR_TRANS();
              _NFMundo_copied_files (data_list, y-1,
                                     cisano_pos, cifilename_pos,
                                     cat_name, cat_no, item_no) ;
  PR_TRANS();
 	      _NFMdebug ((fname, "Send files failed : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }
  PR_TRANS();

          if (DM_MANAGER && NFM_FTR_INITED)
          {
  PR_TRANS();
            status = _NFMexpand_buffer (&move_buffer, cat_name, 
                                        cat_no, item_no);
  PR_TRANS();
            if (status != NFM_S_SUCCESS)
            {
  PR_TRANS();
              _NFMdebug ((fname, "Failed to expand the buffer\n"));
            }
            else
            {
  PR_TRANS();
              if (_NFMdebug_st.NFMdebug_on)
              {
  PR_TRANS();
                MEMprint_buffer ("move_buffer", move_buffer, 
                                  _NFMdebug_st.NFMdebug_file);
              }
  PR_TRANS();
              status = _NFMmount_add_index (move_buffer, NFM_ITEM); 
  PR_TRANS();
              if (status != NFM_S_SUCCESS)
              {
  PR_TRANS();
                _NFMdebug ((fname, "_NFMmount_add_index 0x%.8x\n", status));
              }
              ERRreset_struct ();
  PR_TRANS();
            }
          }

	  MEMclose (&move_buffer) ;
	  
  PR_TRANS();
	  status = SQLstmt (sql_str);
  PR_TRANS();
	  if (status != SQL_S_SUCCESS)
	    {
	      free (sql_str);
	      free (sql_str1);
	      
	      if (status == SQL_E_DUPLICATE_VALUE)
		{
  PR_TRANS();
		  _NFMundo_copied_files (data_list, y,
					 cisano_pos, cifilename_pos,
					 cat_name, cat_no, item_no) ;
  PR_TRANS();
 		  ERRload_struct (NFM, NFM_E_DUP_FILE, "", NULL);
		  _NFMdebug ((fname, "Item Exists : status = <0x%.8x>\n",
			      NFM_E_DUP_FILE));
		  return (NFM_E_DUP_FILE);
		}
	      
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	      _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
			  status));
	      return (NFM_E_SQL_STMT);
	    }
	}
      
      if (move_buffer != NULL)
	{
	  MEMclose (&move_buffer) ;
	}
      free (sql_str);
      free (sql_str1);
    }  /* y */

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

 long _NFMadd_file_catalog_entry (cat_name, item_no, data_list) 
   char    *cat_name;
   long    item_no ;
   MEMptr  data_list ;
   {
     static char *fname = "_NFMadd_file_catalog_entry" ;
     long    status, file_no, y, new_columns ;
     char    sql_str [1024], sql_str1 [1024] ;
     char    file_no_str[50], **data, **column, **format ;
     char    file_cat [NFM_TABLENAME+1] ;

     _NFMdebug ((fname, "Cat  Name = <%s> : Item No = <%d>\n", 
		 cat_name, item_no));

     sprintf (file_cat, "f_%s", cat_name) ;
     status = NFMget_attr_value (NFMglobal.NFMuserid, file_cat, 
				 "max(n_fileno)",
				 "", file_no_str);
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "NFMget_attr_value : status = <0x%.8x>\n",
		     status));
	 return (status);
       }
     file_no = atol (file_no_str) + 1;
     
     sql_str [0] = 0; 
/*
     sprintf (sql_str,  "INSERT INTO f_%s (n_itemnum, n_fileno, n_filenum, n_fileversion) VALUES (%d, %d, 0, 0)", 
	      cat_name, item_no, file_no) ;
*/

     sprintf (sql_str,  "INSERT INTO f_%s (n_itemnum, n_fileno, n_fileversion", 
	      cat_name) ;

     sprintf (sql_str1, ") VALUES (%d, %d, 0 ", 
	      item_no, file_no);

     new_columns = 0 ;
     if ((data_list) && (data_list->rows > 0))
       {
	 status = MEMbuild_array (data_list) ;
         if (status != MEM_S_SUCCESS)
         { 
            _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
                        status)) ;
            ERRload_struct (NFM, NFM_E_MEM, "", "") ;
            return (NFM_E_MEM) ;
         }
	 column = (char **) data_list->column_ptr ;
	 data = (char **) data_list -> data_ptr ;
	 format = (char **) data_list -> format_ptr ;

	 for (y=0; y<data_list->columns; y++)
	   {
             if (( strcmp (column [y], "n_archiveno")) &&
		  ( strcmp (column [y], "n_fileco")) &&
		  ( strcmp (column [y], "n_cocomment")) &&
		  ( strcmp (column [y], "n_couser")) &&
		  ( strcmp (column [y], "n_codate")) &&
		  ( strcmp (column [y], "original_fileno")) &&
		  ( strcmp (column [y], "original_cisano")) &&
		  ( strcmp (column [y], "original_cifilename")) &&
		  ( strcmp (column [y], "n_fileno")) &&
		  ( strcmp (column [y], "n_itemnum")) &&
		  ( strcmp (column [y], "n_fileversion")) &&
		  ( strcmp (column [y], "n_filenum")) &&
		  ( strcmp (column [y], "n_action")))
              {

	     if (strlen (data [y]))
	       {
		 new_columns = 1 ;
		 strcat (sql_str, ",") ;
		 strcat (sql_str, column [y]) ;
		 if (strncmp (format[y], "char", 4) == 0)
		   {
		     strcat (sql_str1, ",'") ;
		     strcat (sql_str1, data [y]) ;
		     strcat (sql_str1, "'") ;
		   }
		 else
		   {
		     strcat (sql_str1, ",") ;
		     strcat (sql_str1, data [y]) ;
		   }
	       }
             }
	   }
       }

     if (new_columns) 
       {
	 strcat (sql_str, ",n_filenum") ;
	 strcat (sql_str1, ",1)") ;
       }
     else
       {
	 strcat (sql_str, ",n_filenum, n_fileclass") ;
	 strcat (sql_str1, ",0, 'C')") ;
       }

     strcat (sql_str, sql_str1) ;

     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS)
      {
        if (status == SQL_E_DUPLICATE_VALUE)
         {
           ERRload_struct (NFM, NFM_E_DUP_FILE, "", NULL);
           _NFMdebug ((fname, "Item Exists : status = <0x%.8x>\n",
		     NFM_E_DUP_FILE));
           return (NFM_E_DUP_FILE);
         }

        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SQL Stmt Syntax : status = <0x%.8x>\n",
		    status));
        return (NFM_E_SQL_STMT);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }


long _NFMundo_copied_files (data_list, incl_last, cisano_pos, cifilename_pos,
			    catalog_name, cat_no, item_no)
     MEMptr data_list ;
     long   incl_last ;
     long   cisano_pos ;
     long   cifilename_pos ;
     char   *catalog_name ;
     long   cat_no ;
     long   item_no ;
{
  char *fname = "_NFMundo_copied_files" ;
  long status ;
  MEMptr del_buffer = NULL, error_ptr = NULL, sql_buffer = NULL ;
  long i, dest_sano = 0 ;
  long offset, file_no ;
  char dest_file [NFM_COFILENAME+1] ;
  char **data, **data1, sql_str [1024] ;
  struct fto_buf file_buffer ;

  _NFMdebug ((fname, "ENTER\n")) ;
  data = (char **) data_list -> data_ptr ;

  status = NFMbuild_fto_buffer (&del_buffer, MEM_SIZE) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  _NFMdebug ((fname, "Will undo file up to and including n_filenum %d\n",
	      incl_last+1)) ;
  for (i=0; i<incl_last+1; i++)
    {
      offset = i*data_list->columns ;
      dest_sano = atol(data[offset+cisano_pos]) ;

      status = _NFMget_sano_info_fto_buf (dest_sano,
					  "",
					  &file_buffer) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
      
      file_buffer.n_status1 = NFM_DELETE_FILE ;
      if (strlen (data [offset+cifilename_pos]))
	{
	  strcpy (dest_file, data [offset+cifilename_pos]) ;
	}
      else
	{
	  sprintf (sql_str, 
		   "select n_fileno from f_%s where n_itemnum = %d and n_filenum = %d",
		   catalog_name, item_no, i+1) ;
	  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : SQLquery : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	      return (NFM_E_SQL_QUERY) ;
	    }

	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n", status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }

	  data1 = (char **) sql_buffer-> data_ptr ;
	  file_no = atol (data1 [0]) ;
	  MEMclose (&sql_buffer) ;

	  status = NFMget_file_name (NFMglobal.NFMuserid,
				     cat_no, file_no,
				     dest_file) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }
	}

      strcpy (file_buffer.n_cifilename, dest_file ) ;

      status = NFMload_fto_buf (&del_buffer, &file_buffer) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Loading first row failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
    }

  if (del_buffer != NULL)
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  MEMprint_buffer ("delete buffer", del_buffer, 
			   _NFMdebug_st.NFMdebug_file) ;
	}
      status = NFMfs_chg_files (&del_buffer,  &error_ptr) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Remove co files failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
    }
  
  MEMclose (&del_buffer) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

/* Duke Power Duplicate Problem -- Jujare */ 
#include <stdio.h>
#include <time.h>
#include <sys/types.h>

char *NFM_gettime(void)
{
static char buf[200];
time_t cur_time;
struct tm   *cur_tm;

      time(&cur_time);
      cur_tm = localtime(&cur_time);
      strftime(buf,sizeof(buf),"%a %b %d %H:%M:%S %Y", cur_tm);
      return(buf);
}

/* Converted this function to a macro for efficiency - Jujare, 29 th Dec 95 
void PR_TRANS(void)
{
char *fname = "PR_TRANS";
     _NFMdebug ((fname, "NFM_TRANSACTION:<%d>:<%s>\n",NFM_TRANSACTION,
                 NFM_gettime()));
}
*/
/* End -  Duke Power Duplicate Problem -- Jujare */ 

