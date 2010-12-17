#include "machine.h"
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/utsname.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <malloc.h>
#include <errno.h>
#include "CVT.h"



extern struct CVTglobal_st CVTglobal ;

#define NUM_OF_RECORD	500


long CVTconvert_catalogs (catalogs, cat_selection) 
     UNIT_INFO *catalogs ;
     int       cat_selection [] ;
{
  char *fname = "CVTconvert_catalogs" ;
  long status, cats ;
  long CVTconvert_catalog () ;
  long last_row;
  char status_flag[20];
  _NFMdebug ((fname, "ENTER\n")) ;

  fprintf(stderr,"BEGIN:	<<<	CATALOG		CONVERSION 	>>>>\n");
  status = CVTquery_cvtlog_entry("CVTSTATUS2",status_flag,&last_row);
  if(status == NFM_S_SUCCESS)
  {
	_NFMdebug((fname,"All catalogs are converted previously\n"));
	fprintf(stderr,"All catalogs are converted previously.\n");
	return(NFM_S_SUCCESS);
  }
  status = CVTcheck_catalog_start();
  if(status!= NFM_S_SUCCESS)
  {
	_NFMdebug((fname,"Some core tables are not converted. Catalog\
Conversion can begin only after the core catalogs are converted\n"));
/* ERRload is done in the lower function */
	fprintf(stderr,"\nPlease convert the systems tables first.\n");
	return(status);
  }

  for (cats = 0 ; cats <catalogs->num_of_rows; cats++)
    {
      if (cat_selection [cats]) 
	{
	  status = CVTconvert_catalog (catalogs->data[cats]) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug((fname,"Catalog conversion failed for catalog <%s>\
 : status <0x%.8x>\n",catalogs->data[cats],status));
	      fprintf(stderr,"Catalog conversion failed for catalog <%s> and \
 file catalog <f_%s>\n",catalogs->data[cats],catalogs->data[cats]);
	      fprintf(stderr,"\n\n Continuing with next catalog .....\n");
	    }
	}
    }
  CVTupdate_catalog_end();
  fprintf(stderr,"END:	<<<	CATALOG		CONVERSION	>>>\n");
  return (NFM_S_SUCCESS) ;
}


int CVTcheck_catalog_start ()
{
  char *fname="CVTcheck_catalog_start";
  int status,i,j,count;
  static char *sql_str= "SELECT n_tablename, n_cvtstatus FROM nfmconvertlog \
WHERE n_tablename  in ('nfmattributes','nfmcatalogs','nfmvalues','nfmlists','nfmtables')";
  char   **data;
  MEMptr buffer = NULL;
  
  
  _NFMdebug((fname,"Entry\n"));
  
  /* Figure out if 
     nfmattributes
     nfmcatalogs
     nfmvalues
     nfmlist
     nfmtables
     are done 
     then and only then we can call all other catalogs to be converted
     */
  status = SQLquery (sql_str, &buffer, NULL) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "SUCCESSFUL - NO ROWS FOUND\n")) ;
	  fprintf(stderr,"\nTables <%s> <%s> <%s> <%s> <%s> \nare \
not yet converted. Please convert these system tables first.\n","nfmattributes",
		  "nfmcatalogs","nfmvalues","nfmlists","nfmtables");
	  ERRload_struct(NFM,NFM_I_MESSAGE,"%s","Please convert the systems \
tables before attempting catalog conversion");
	  return (NFM_I_NO_ROWS_FOUND);
	}
      fprintf(stderr,"ERROR:	Cannot obtain information from convert log\n");
      MEMclose (&buffer);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY);
    }
  
  status = MEMbuild_array (buffer);
  if (status != MEM_S_SUCCESS)
    {
      fprintf(stderr,"FATAL ERROR: 	Memory subsystem failure\n");
      ERRload_struct(NFM,NFM_E_MEM,"");
      MEMclose (&buffer);
      return (status);
    }
  
  data = (char **) buffer->data_ptr;
  
  j = 0;
  for(i=0;i < buffer->rows; i++)
    {
      count = buffer->columns * i;
      _NFMdebug((fname,"Table <%s> : cvtstatus <%s>\n",data[count],data[count+1]));
      if(strcmp(data[count+1],"M") == 0 ) j++;
      else if(strcmp(data[count+1],"C") == 0 ) j++;
      else
	{
	  _NFMdebug((fname,"Table <%s> : cvtstatus <%s> != <M>\n",data[count],data[count+1]));
	  fflush(stdout);
	  ERRload_struct(NFM,NFM_E_MESSAGE,"%s","System tables are not\
converted properly for catalog conversion to start");
	  fprintf(stderr,"\n<<<<WARNING>>>>	Catalogs cannot be converted until\
 system table\n <%s> is converted properly and n_cvtstatus is <M or C> in table \n\
<nfmconvertlog>: Current n_cvtstatus is <%s> \n",data[count],data[count+1]);
	  
	}	
    }
  
  MEMclose (&buffer);
  if ( j==5) return(NFM_S_SUCCESS);
  else return(NFM_E_FAILURE);
}

int CVTupdate_catalog_end ()
{
  char *fname="CVTupdate_catalog_end";
  int status,i,j,count;
  static char *sql_str= "SELECT n_tablename, n_cvtstatus FROM nfmconvertlog \
WHERE n_lastrowdone = -1";
  static char *sql_str2= "SELECT n_catalogname FROM nfmcatalogs \
WHERE n_catalogname != 'nfmsyscat'";
  char   **data;
  MEMptr buffer = NULL;
  
  
  _NFMdebug((fname,"Entry\n"));
  
  status = SQLquery (sql_str, &buffer, NULL) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "SUCCESSFUL - NO ROWS FOUND\n")) ;
	  fprintf(stderr,"\nNo tables/catalogs converted yet.\n");
	  ERRload_struct(NFM,NFM_I_MESSAGE,"%s","There are no catalogs in \
nfmcatalogs table");
	  MEMclose (&buffer);
	  return (NFM_I_NO_ROWS_FOUND);
	}
      fprintf(stderr,"ERROR:	Cannot obtain information from convert log\n");
      MEMclose (&buffer);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY);
    }
  
  status = MEMbuild_array (buffer);
  if (status != MEM_S_SUCCESS)
    {
      fprintf(stderr,"FATAL ERRORL:	Memory subsystem failure\n");
      ERRload_struct(NFM,NFM_E_MEM,"");
      MEMclose (&buffer);
      return (status);
    }
  
  data = (char **) buffer->data_ptr;
  
  j = 0;
  for(i=0;i < buffer->rows; i++)
    {
      count = buffer->columns * i;
      _NFMdebug((fname,"Table <%s> : cvtstatus <%s>\n",data[count],data[count+1]));
      if(strcmp(data[count+1],"C") == 0 ) j++;
      else
	{
	  _NFMdebug((fname,"Table <%s> : cvtstatus <%s> != <C>\n",data[count],data[count+1]));
	  fprintf(stderr,"\nCatalog <%s> is not converted successfully\n\
Catalog conversion status <%s>\n",data[count],data[count+1]);
	  
	}	
    }
  
  MEMclose (&buffer);
  status = SQLquery (sql_str2, &buffer, NULL) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "SUCCESSFUL - NO ROWS FOUND\n")) ;
	  fprintf(stderr,"No entries found in nfmcatalogs\n");
	  MEMclose (&buffer);
	  return (NFM_I_NO_ROWS_FOUND);
	}
      fprintf(stderr,"ERROR:	Cannot obtain information from nfmcatalogs\n");
      MEMclose (&buffer);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY);
    }
  if ( j== buffer->rows)
    {
      status = CVTupdate_cvtlog("CVTSTATUS2","C",-1);
      if(status != NFM_S_SUCCESS)
	{
	  _NFMdebug((fname,"Cannot update nfmconvertlog for \
catalog <%s>: status_flag <%s>: row_no <%d>\n","CVTSTATUS2","C",-1));
	  fflush(stdout);
	  fprintf(stderr,"Write access failed for table <nfmconvertlog> for Logging  <%s> .\n","CVTSTATUS2");
	  fprintf(stderr,"All catalogs are successfully completed\n");
	  return(status);
	}
      fprintf(stderr,"ALL catalogs are successfully converted\n");
    }
  MEMclose (&buffer);
  return(NFM_S_SUCCESS);
}

long CVTconvert_catalog(catalog_name)
     char *catalog_name;
{
  char *fname="CVTconvert_catalog";
  int status;
  char table[100],status_flag[10], sql_str[1024] ;
  char s_cat_no [20] ;
  long last_row;
  long catalogno, f_catalogno ;
  char tmp_str [200] ;
  long CVTget_s_cat_no () ;
  long CVTupdates() ;
  long insert_bad;

  _NFMdebug((fname,"Entry:Conversion started for catalog <%s>\n",
	     catalog_name));
  fprintf(stderr,"Catalog  <%s> conversion started.\n",catalog_name);
  
  strcpy(table,catalog_name);
  strcpy(status_flag,"");
  last_row = insert_bad = 0;
  while (1)
    {
      status = CVTquery_cvtlog_entry(table,status_flag,&last_row);
      switch(status)
	{
	case NFM_S_SUCCESS:
	  if(status_flag[0] == 'C')
	    {
	      _NFMdebug((fname,"Catalog <%s> already\
 converted : Returning status <0x%.8x>\n",table,NFM_S_SUCCESS));
	      fflush(stdout);
	      fprintf(stderr,"Catalog  <%s> is already converted.\n",catalog_name);
	      return(NFM_S_SUCCESS);
	    }
	  else if ((status_flag[0] == 'B') || (status_flag[0] == 'E'))
	    {
	      status = CVTcreate_catalog(catalog_name, &insert_bad) ;
	      if(status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname,"Cannot create catalog <%s>: status<0x%.8x>\n",catalog_name,status));
		  fprintf(stdout,"Catalog conversion failed for catalog <%s> .\n",catalog_name);
		  CVTupdate_cvtlog(catalog_name,"E",-1);
		  return(status);
		}
	      status = CVTupdate_cvtlog(catalog_name,"Z",-1);
	      if(status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname,"Cannot update nfmconvertlog for \
catalog <%s>: status_flag <%s>: row_no <%d>\n",catalog_name,"Z",-1));
		  fflush(stdout);
		  fprintf(stderr,"Write access failed for table <nfmconvertlog> for Catalog  <%s> .\n",catalog_name);
		  return(status);
		}
	    }
	  else if (status_flag[0] == 'Z') 
	    {
	      status =  CVTget_s_cat_no (catalog_name, s_cat_no) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",
			      status)) ;
		  return (status) ;
		}

	      _NFMdebug ((fname, "Creating index on cat <%s>\n",
			  table)) ;
	      fprintf (stderr, "Creating index on cat and f_cat <%s>..\n",
		       table) ;
	      sprintf(sql_str, "CREATE UNIQUE INDEX i_%s_1 ON %s (n_itemno)",
		      s_cat_no, catalog_name);
	      status = SQLstmt (sql_str);
	      if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <%s>\n",catalog_name);
		  return (NFM_E_SQL_STMT);
		}
	      sprintf(sql_str, "CREATE UNIQUE INDEX i_%s_2 ON %s (n_itemname, \
	n_itemrev)", s_cat_no, catalog_name);
	      status = SQLstmt (sql_str);
	      if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
		  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <%s>\n",catalog_name);
		  sprintf(sql_str, "DROP INDEX i_%s_1", s_cat_no) ;
		  status = SQLstmt (sql_str);
		  return (NFM_E_SQL_STMT);
		}
	      sprintf(sql_str, "CREATE UNIQUE INDEX i_%s_3 ON f_%s (n_fileno)", \
		      s_cat_no, catalog_name);
	      status = SQLstmt (sql_str);
	      if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
		  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <f_%s>\n",catalog_name);
		  sprintf(sql_str, "DROP INDEX i_%s_1", s_cat_no) ;
		  status = SQLstmt (sql_str);
		  sprintf(sql_str, "DROP INDEX i_%s_2", s_cat_no) ;
		  status = SQLstmt (sql_str);
		  return (NFM_E_SQL_STMT);
		}
	      sprintf(sql_str, "CREATE INDEX i_%s_4 ON f_%s (n_itemnum)", \
		      s_cat_no, catalog_name);
	      status = SQLstmt (sql_str);
	      if (status != SQL_S_SUCCESS)
		{
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
		  _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <f_%s>\n",catalog_name);
		  sprintf(sql_str, "DROP INDEX i_%s_1", s_cat_no) ;
		  status = SQLstmt (sql_str);
		  sprintf(sql_str, "DROP INDEX i_%s_2", s_cat_no) ;
		  status = SQLstmt (sql_str);
		  sprintf(sql_str, "DROP INDEX i_%s_3", s_cat_no) ;
		  status = SQLstmt (sql_str);
		  return (NFM_E_SQL_STMT);
		}
		if (insert_bad)
		{
		  _NFMdebug((fname, "Items in CVTbad_in.ris file"));
		  CVTupdate_cvtlog(catalog_name, "Y", -1);
		  sprintf(sql_str, "UPDATE nfmconvertlog SET n_cvtstatus = 'P'\
		  WHERE n_tablename = '%s'", catalog_name);
		  CVTwrite_bad_insert(catalog_name, sql_str);
		  insert_bad = 0;
		  return (NFM_S_SUCCESS);
        }
	      status = CVTupdate_cvtlog (catalog_name, "L", -1) ;
              if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
                  return (status) ;
                }
	    }
	  else if ((status_flag [0] == 'L') || (status_flag[0] == 'P'))
	    {
	      status = CVTupdates (catalog_name) ;
	      if (status != NFM_S_SUCCESS)
		{
                  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
                  return (status) ;
		}
	      status = CVTupdate_cvtlog (catalog_name, "I", -1) ;
              if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
                  return (status) ;
                }
	    }
	  else if (status_flag[0] == 'I')
	    {
	      _NFMdebug ((fname, "Resolve file attributes on cat <%s>\n",
			  table)) ;
	      fprintf(stderr,"Resolving file attributes for catalog <%s>\n",catalog_name);
	      status = CVTresolve_file_attrs (catalog_name);
	      if(status != NFM_S_SUCCESS)
		  {
		  _NFMdebug((fname,"CVTresolve_file_attrs ERROR status <0x%.8x>\n",status));
		  fprintf(stderr,"ERROR:	Cannot resolve file attributes for catalog <%s>\n",catalog_name);
		  CVTget_s_cat_no (catalog_name, s_cat_no) ;
		  catalogno = atol (s_cat_no) ;
		  sprintf (tmp_str, "f_%s", catalog_name) ;
		  CVTget_s_cat_no (tmp_str, s_cat_no) ;
		  f_catalogno = atol (s_cat_no) ;
		  CVTdelete_all_new_attributes(catalogno,f_catalogno);
		  CVTupdate_cvtlog(catalog_name,"E",-1);
		  CVTcat_restore(catalog_name);
		  return(status);
		  }
	      status = CVTupdate_cvtlog (catalog_name, "C", -1) ;
              if (status != NFM_S_SUCCESS)
                {
                  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
                  return (status) ;
                }
	    }
	  break;

	case NFM_I_NO_ROWS_FOUND:
	  _NFMdebug((fname,"No entry found for catalog\
 <%s> in table nfmconvertlog: Proceeding to convert table <%s>\n",table,table));
	  status = CVTupdate_cvtlog(catalog_name,"B",-1);
	  if(status != NFM_S_SUCCESS)
	    {
	      _NFMdebug((fname,"Cannot update nfmconvertlog for \
catalog <%s>: status_flag <%s>: row_no <%d>\n",catalog_name,"B",-1));
	      fflush(stdout);
	      fprintf(stderr,"Write access failed for table <nfmconvertlog> for Catalog  <%s> .\n",catalog_name);
	      return(status);
	    }
	  status = CVTcreate_catalog(catalog_name, &insert_bad) ;
	  if(status != NFM_S_SUCCESS)
	    {
	      _NFMdebug((fname,"Cannot create catalog <%s>: status<0x%.8x>\n",catalog_name,status));
	      fprintf(stdout,"Catalog conversion failed for catalog <%s> .\n",catalog_name);
	      CVTupdate_cvtlog(catalog_name,"E",-1);
	      return(status);
	    }
	  status = CVTupdate_cvtlog(catalog_name,"Z",-1);
	  if(status != NFM_S_SUCCESS)
	    {
	      _NFMdebug((fname,"Cannot update nfmconvertlog for \
catalog <%s>: status_flag <%s>: row_no <%d>\n",catalog_name,"Z",-1));
	      fflush(stdout);
	      fprintf(stderr,"Write access failed for table <nfmconvertlog> for Catalog  <%s> .\n",catalog_name);
	      return(status);
	    }
	  break;

	default:
	  _NFMdebug((fname,"Failed to query nfmconvertlog\
 for catalog <%s>: status <0x%.8x>\n",table,status));
	  fflush(stdout);
	  fprintf(stderr,"Read access failed for table <nfmconvertlog> for Catalog  <%s> .\n",catalog_name);
	  ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot query  \
nfmconvertlog ");
	  
	  return(status);
	}
    }
/******* unreachable ********
  _NFMdebug((fname,"Conversion done for catalog <%s>: status: <0x%.8x>\n",
	     catalog_name,status));
  fprintf(stderr,"Catalog <%s> conversion completed.\n",catalog_name);
  return(status);
**********************************/
}

int CVTcreate_catalog (catalog_name, insert_bad)
     char *catalog_name ;
	 long *insert_bad;
{
  char *fname = "CVTcreate_catalog";
  long status, i,j,count ,size,flag;
  char sql_str[1024];
  char *qry_str = NULL;
  MEMptr buffer = NULL;
  char **column, **data,itemno[60];
  int catalogno,f_catalogno;
  
  
  _NFMdebug((fname,"Entry: catalog_name <%s>\n",catalog_name));
  catalogno = f_catalogno = 0;
  
  fflush(stdout);
  fprintf(stderr,"Creating catalog <%s> and <f_%s>\n",catalog_name,catalog_name);
  
  
  sprintf(sql_str, "SELECT n_tablename, n_tableno FROM NFMTABLES \
  WHERE n_tablename = '%s' or n_tablename = 'f_%s'",catalog_name,catalog_name);
  status = SQLquery (sql_str, &buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) )
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Cannot obtain catalog number from database\n");
      return (NFM_E_SQL_QUERY);
    }
  status = MEMbuild_array (buffer);
  if(status != MEM_S_SUCCESS)
    {
      _NFMdebug((fname,"MEMbuild_array failed sataus: <0x%.8x>\n"));
      ERRload_struct(NFM,NFM_E_MEM,"");
	fprintf(stderr,"ERROR:	Memory subsystem failed. Cannot obtain catalog number from database\n");
      return(status);
    }
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr;
  flag = 0;
  for(i=0;i < buffer->rows; i++)
    {
      count = i * buffer->columns;
      for(j=0;j< buffer->columns; j++)
	{
	  if((strcmp(column[j],"n_tablename") == 0 ))
	    {
	      if(strcmp(data[count+j],catalog_name) == 0 )
		{
		  flag++;
		  strcpy(itemno,data[count+j+1]);
		  catalogno = atol (data[count+j+1]);
		}
	      else 
		{
		  flag++;
		  f_catalogno = atol (data[count+j+1]);
		}
	    }
	}
    }	
  if(flag != 2 )
    {
      _NFMdebug((fname,"Failed to obtain catalog_no and f_catalog_no for\
catalog <%s>: status <0x%.8x>\n",catalog_name,NFM_E_FAILURE));
      fprintf(stderr,"ERROR: Cannot obtain catalog number for catalog <%s> \
and <f_%s>\n",catalog_name,catalog_name);
      ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot obtain catalog_no and f_catalog_no");
      return(NFM_E_FAILURE);
    }
  MEMclose(&buffer);
  fprintf(stderr,"Creating new attributes for catalog <%s> and <f_%s>\n",catalog_name,catalog_name);
  status = CVTinsert_all_new_attributes(catalogno,f_catalogno);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"Cannot create new attributes for catalog  <%s>: status<0x%.8x>\n",catalog_name,status));
      fprintf(stderr,"ERROR:	Catalog conversion failed for catalog <%s> .\n",catalog_name);
      fprintf(stderr,"ERROR:	Cannot create new attributes\n");
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      return(status);
    }
  status = CVTload_cat_names (catalog_name);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"Cannot load catalog  names <%s>: status <0x%.8x>\n",catalog_name,status));
      fprintf(stderr,"ERROR:	Catalog conversion failed for catalog <%s> .\n",catalog_name);
      fprintf(stderr,"ERROR:	Cannot load catalog name in global variable\n");
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      return(status);
    }
  fprintf(stderr,"Unloading catalog <%s> and <f_%s> data\n",
	  catalog_name,catalog_name);
  status = CVTcat_unload (catalog_name);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"Cannot unload catalog <%s>: status <0x%.8x>\n",catalog_name,status));
      fprintf(stderr,"ERROR:	Failed to unload catalog <%s> and <f_%s> data\n",
	      catalog_name,catalog_name);
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      return(status);
    }
  fprintf(stderr,"Unloading catalog <%s> and <f_%s> data DONE\n",
	  catalog_name,catalog_name);
  fprintf(stderr,"Create new catalog <%s>\n",catalog_name);
  
  sprintf(sql_str, "select n_name,n_datatype,n_seqno from NFMATTRIBUTES\
 where n_tableno = %d order by n_seqno",catalogno);
  
  status = SQLquery (sql_str, &buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) )
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Cannot obtain attributes information from database for catalog <%s>\n",catalog_name);
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);
      return (NFM_E_SQL_QUERY);
    }
  status = MEMbuild_array (buffer);
  if(status != MEM_S_SUCCESS)
    {
      _NFMdebug((fname,"MEMbuild_array failed sataus: <0x%.8x>\n"));
      fprintf(stderr,"ERROR:	Memory subsystem failure. Cannot obtain \
attributes information from\n database for catalog <%s>\n",catalog_name);
      ERRload_struct(NFM,NFM_E_MEM,"");
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);
      return(status);
    }
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr;
  size = buffer->row_size * buffer->rows + 512 ;
  qry_str = malloc (size);
  if(qry_str == (char *)0 )
    {
      _NFMdebug((fname,"Malloc failed for size <%d>\n",size));
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);
      fprintf(stderr,"FATAL ERROR:	Memory allocation failed\n");
      ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
      return(NFM_E_MALLOC);
    }
  
  sprintf(qry_str,"CREATE TABLE %s ( ",catalog_name);
  
  for(i=0;i < buffer->rows; i++)
    {
      count = i * buffer->columns;
      sprintf(sql_str," %s %s " , data[count], data[count+1]);
      strcat(qry_str,sql_str);
      if ( (i+1) < buffer->rows ) strcat(qry_str," , ");
    }	
  strcat (qry_str," )");
  MEMclose(&buffer);
  _NFMdebug((fname,"qry_str <%s>\n",qry_str));
  
  status = SQLstmt(qry_str);
  free(qry_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create table statement failed for catalog <%s>\n",catalog_name);
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);
      return (NFM_E_SQL_STMT);
    }
  sprintf(sql_str, "CREATE UNIQUE INDEX i_%s_10 ON %s (n_itemno)", itemno, CVTglobal.o_catalog);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <%s>\n",CVTglobal.o_catalog);
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
	CVTupdate_cvtlog(catalog_name,"E",-1);
	CVTcat_restore(catalog_name);
      return (NFM_E_SQL_STMT);
    }
  sprintf(sql_str, "CREATE UNIQUE INDEX i_%s_20 ON %s (n_itemname, \
	n_itemrev)", itemno, CVTglobal.o_catalog);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <%s>\n",CVTglobal.o_catalog);
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
	CVTupdate_cvtlog(catalog_name,"E",-1);
	CVTcat_restore(catalog_name);
      return (NFM_E_SQL_STMT);
    }
  
  fprintf(stderr,"Create new catalog <f_%s>\n",catalog_name);
  sprintf(sql_str, "select n_name,n_datatype,n_seqno from NFMATTRIBUTES\
 where n_tableno = %d order by n_seqno",f_catalogno);
  
  status = SQLquery (sql_str, &buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) )
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Cannot obtain attributes information from database for catalog <f_%s>\n",catalog_name);
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);
      return (NFM_E_SQL_QUERY);
    }
  status = MEMbuild_array (buffer);
  if(status != MEM_S_SUCCESS)
    {
      _NFMdebug((fname,"MEMbuild_array failed sataus: <0x%.8x>\n"));
      fprintf(stderr,"ERROR:	Memory subsystem failure. Cannot obtain \
attributes information from\n database for catalog <f_%s>\n",catalog_name);
      ERRload_struct(NFM,NFM_E_MEM,"");
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);
      return(status);
    }
  data = (char **) buffer -> data_ptr;
  column = (char **) buffer -> column_ptr;
  size = buffer->row_size * buffer->rows + 512 ;
  qry_str = malloc (size);
  if(qry_str == (char *)0 )
    {
      _NFMdebug((fname,"Malloc failed for size <%d>\n",size));
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);
      fprintf(stderr,"FATAL ERROR:	Memory allocation failed\n");
      ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
      return(NFM_E_MALLOC);
    }
  
  sprintf(qry_str,"CREATE TABLE f_%s  (",catalog_name);
  
  for(i=0;i < buffer->rows; i++)
    {
      count = i * buffer->columns;
      sprintf(sql_str," %s %s " , data[count], data[count+1]);
      strcat(qry_str,sql_str);
      if ( (i+1) < buffer->rows ) strcat(qry_str," , ");
    }	
  strcat (qry_str," )");
  MEMclose(&buffer);
  
  _NFMdebug((fname,"qry_str <%s>\n",qry_str));
  status = SQLstmt(qry_str);
  free(qry_str);
  
  
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create table statement failed for catalog <f_%s>\n",catalog_name);
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);
      return (NFM_E_SQL_STMT);
    }
  sprintf(sql_str, "CREATE UNIQUE INDEX i_%s_30 ON f_%s (n_fileno)", \
	  itemno, CVTglobal.o_catalog);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <f_%s>\n",CVTglobal.o_catalog);
       CVTdelete_all_new_attributes(catalogno,f_catalogno);
         CVTupdate_cvtlog(catalog_name,"E",-1);
	 CVTcat_restore(catalog_name);
      return (NFM_E_SQL_STMT);
    }
  sprintf(sql_str, "CREATE INDEX i_%s_40 ON f_%s (n_itemnum)", \
	  itemno, CVTglobal.o_catalog);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <f_%s>\n",CVTglobal.o_catalog);
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
	CVTupdate_cvtlog(catalog_name,"E",-1);
	CVTcat_restore(catalog_name);
      return (NFM_E_SQL_STMT);
    }

 /* Set database to exclusive mode and lock table in exclusive mode */

  /*status = CVTexclusive(CVTglobal.env_name, catalog_name);
  if (status != NFM_S_SUCCESS)
  {
	_NFMdebug((fname, "Failure : status <0x%.8x>\n", status));
	return (status);
  }*/
  
  fprintf(stderr,"Processing data in <%s>\n",catalog_name);
  status = CVTNprocess_catalog (catalog_name, insert_bad);
  if(status != NFM_S_SUCCESS)
	{
	  _NFMdebug((fname,"CVTNprocess_catalog ERROR status <0x%.8x>\n",status));
	  fprintf(stderr,"ERROR: Cannot process data in catalog <%s>\n",catalog_name);
	  CVTdelete_all_new_attributes(catalogno,f_catalogno);
	  CVTupdate_cvtlog(catalog_name,"E",-1);
	  CVTcat_restore(catalog_name);
	  return(status);
	}
  fprintf(stderr,"Processing data in <%s> DONE\n",catalog_name);
  fprintf(stderr,"Processing data in <f_%s>\n",catalog_name);
  status = CVTNprocess_f_catalog (catalog_name, insert_bad);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"CVTprocess_f_catalog ERROR status <0x%.8x>\n",status));
      fprintf(stderr,"ERROR: Cannot process data in catalog <f_%s>\n",catalog_name);
      CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);
      return(status);
    }
  fprintf(stderr,"Processing data in <f_%s> DONE\n",catalog_name);
  /*	fprintf(stderr,"Resolving file attributes for catalog <%s>\n",catalog_name);
	status = CVTresolve_file_attrs (catalog_name);
	if(status != NFM_S_SUCCESS)
	{
	_NFMdebug((fname,"CVTresolve_file_attrs ERROR status <0x%.8x>\n",status));
	fprintf(stderr,"ERROR:	Cannot resolve file attributes for catalog <%s>\n",catalog_name);
	CVTdelete_all_new_attributes(catalogno,f_catalogno);
	CVTupdate_cvtlog(catalog_name,"E",-1);
	CVTcat_restore(catalog_name);
	return(status);
	}*/
/***************** moved **********
  sprintf(sql_str, "CREATE UNIQUE INDEX i_%s_1 ON %s (n_itemno)", itemno, catalog_name);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <%s>\n",catalog_name);
	  CVTupdate_cvtlog(catalog_name, "I", -1);
      return (NFM_E_SQL_STMT);
    }
  sprintf(sql_str, "CREATE UNIQUE INDEX i_%s_2 ON %s (n_itemname, \
	n_itemrev)", itemno, catalog_name);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <%s>\n",catalog_name);
	  CVTupdate_cvtlog(catalog_name,"I", -1);
      return (NFM_E_SQL_STMT);
    }
  sprintf(sql_str, "CREATE UNIQUE INDEX i_%s_3 ON f_%s (n_fileno)", \
	  itemno, catalog_name);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <f_%s>\n",catalog_name);
	  CVTupdate_cvtlog(catalog_name, "I", -1);
      return (NFM_E_SQL_STMT);
    }
  sprintf(sql_str, "CREATE INDEX i_%s_4 ON f_%s (n_itemnum)", \
	  itemno, catalog_name);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Create unique index statement failed for catalog <f_%s>\n",catalog_name);

	  CVTupdate_cvtlog(catalog_name,"I",-1);
      return (NFM_E_SQL_STMT);
    }
******************* moved *******************************/
/*********** moved *********
  fprintf(stderr,"Resolving file attributes for catalog <%s>\n",catalog_name);
  status=NFMset_autocommit_off(0);
  if (status != NFM_S_SUCCESS)
  {
	_NFMdebug((fname, "Failure: status = <0x%.8x>\n", status));
	return(NFM_E_MESSAGE);
  }
  status = CVTresolve_file_attrs (catalog_name);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"CVTresolve_file_attrs ERROR status <0x%.8x>\n",status));
      fprintf(stderr,"ERROR:	Cannot resolve file attributes for catalog <%s>\n",catalog_name);
	  NFMrollback_transaction(0);
	  CVTupdate_cvtlog(catalog_name,"A",-1);
      return(status);
    }
  status=NFMset_autocommit_on(0);
  if (status != NFM_S_SUCCESS)
  {
	CVTupdate_cvtlog(catalog_name,"A",-1);
	_NFMdebug((fname, "Failure: status = <0x%.8x>\n", status));
	return(NFM_E_MESSAGE);
  }
*********************** moved **************/
  fprintf(stderr,"Dropping old copy of catalog <%s>\n",catalog_name);
  status = CVTdrop_o_catalogs (catalog_name);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"CVTdrop_o_catalogs ERROR status <0x%.8x>\n",status));
      fprintf(stderr,"ERROR:	Cannot delete old copy of catalog <%s> and <f_%s>\n",catalog_name,catalog_name);
    }

  /*fprintf(stderr,"Updating convert log\n");
  status = CVTupdate_cvtlog(catalog_name,"C",-1);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"Cannot update nfmconvertlog for \
catalog <%s>: status_flag <%s>: row_no <%d>\n",catalog_name,"C",-1));
      fprintf(stderr,"Write access failed for table <nfmconvertlog> for Catalog  <%s> .\n",catalog_name);
*/      /*CVTdelete_all_new_attributes(catalogno,f_catalogno);
      CVTupdate_cvtlog(catalog_name,"E",-1);
      CVTcat_restore(catalog_name);*/ /*
      return(status);
    }
  
  fprintf(stderr,"Catalog <%s> converted successfully\n",catalog_name);
*******************************************/
_NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

int CVTinsert_all_new_attributes(catalog_no,f_catalog_no)
     int catalog_no,f_catalog_no;
{
  int status;
  char *fname="CVTinsert_all_new_attributes";
  _NFMdebug((fname,"Entry: catalog_no <%d>\n",catalog_no));
  status=CVTinsert_new_attributes(catalog_no,"catalog","n_iconname");
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"Insert new attribute failed catalog_no <%d>:\
attribute_name <%s>\n",catalog_no,"n_iconname"));
      return(status);
    }
  status=CVTinsert_new_attributes(catalog_no,"catalog","n_lgfiletype");
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"Insert new attribute failed catalog_no <%d>:\
attribute_name <%s>\n",catalog_no,"n_lgfiletype"));
      return(status);
    }
  status=CVTinsert_new_attributes(catalog_no,"catalog","n_pendingflag");
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"Insert new attribute failed catalog_no <%d>:\
attribute_name <%s>\n",catalog_no,"n_pendingflag"));
      return(status);
    }
  
  status=CVTinsert_new_attributes(f_catalog_no,"f_catalog","n_filenum");
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"Insert new attribute failed f_catalog_no <%d>:\
attribute_name <%s>\n",f_catalog_no,"n_filenum"));
      return(status);
    }
  
  status=CVTinsert_new_attributes(f_catalog_no,"f_catalog","n_restoreflag");
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"Insert new attribute failed f_catalog_no <%d>:\
attribute_name <%s>\n",f_catalog_no,"n_restoreflag"));
      return(status);
    }
  return(NFM_S_SUCCESS);
}
int CVTinsert_new_attributes(catalog_no,catalog_type,attr_name)
     int catalog_no;
     char *catalog_type,*attr_name;
{
  char *fname="CVTinsert_new_attributes";
  int status,query_tableno,i,comma_flag;
  long n_attrno,n_seqno;
  char sql_str[1024],values[1024],tmp_str[96];
  char   **data,**column,**format;
  MEMptr buffer = NULL;
  _NFMdebug((fname,"Entry:catalog_no <%d>:catalog_type: <%s>:attr_name <%s>\n",catalog_no,catalog_type,attr_name));
  status = _CVTget_next_slot ("nfmattributes", "n_attrno", &n_attrno) ;
  if (status != NFM_S_SUCCESS)
    {
      ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot get next n_attrno");
      return(status);
    }
  status = _CVTget_next_seq_no ("nfmattributes", "n_seqno",catalog_no, &n_seqno);
  if (status != NFM_S_SUCCESS)
    {
      
      ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot get next n_seqno");
      return(status);
    }
  
  sprintf(sql_str,"select n_tableno from nfmtables where n_tablename='%s' and n_tabletype='t_basic'",catalog_type);
  
  status = SQLquery (sql_str, &buffer, NULL) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot find n_tableno for template");
	  _NFMdebug ((fname, "SUCCESSFUL - NO ROWS FOUND\n")) ;
	  return (NFM_I_NO_ROWS_FOUND);
	}
      fprintf (stdout, "%s: SQLquery <0x%.8x>.\n", fname, status);
      MEMclose (&buffer);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY);
    }
  
  status = MEMbuild_array (buffer);
  if (status != MEM_S_SUCCESS)
    {
      fprintf (stdout, "%s: MEMbuild_array <0x%.8x>.\n", fname, status);
      ERRload_struct(NFM,NFM_E_MEM,"");
      MEMclose (&buffer);
      return (status);
    }
  
  data = (char **) buffer->data_ptr;
  
  query_tableno = atol (data[0]);
  
  MEMclose (&buffer);
  
  sprintf (sql_str,"select * from nfmattributes where n_tableno=%d and n_name='%s'",query_tableno,attr_name);
  
  status = SQLquery (sql_str, &buffer, NULL) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot get attributes");
	  _NFMdebug ((fname, "SUCCESSFUL - NO ROWS FOUND\n")) ;
	  return (NFM_I_NO_ROWS_FOUND);
	}
      fprintf (stdout, "%s: SQLquery <0x%.8x>.\n", fname, status);
      MEMclose (&buffer);
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY);
    }
  
  status = MEMbuild_array (buffer);
  if (status != MEM_S_SUCCESS)
    {
      fprintf (stdout, "%s: MEMbuild_array <0x%.8x>.\n", fname, status);
      ERRload_struct(NFM,NFM_E_MEM,"");
      MEMclose (&buffer);
      return (status);
    }
  
  data = (char **) buffer->data_ptr;
  column = (char **) buffer->column_ptr;
  format = (char **) buffer->format_ptr;
  strcpy(sql_str,"INSERT into nfmattributes (");
  strcpy(values," VALUES (");
  comma_flag = 0;
  for(i=0;i< buffer->columns; i++)
    {
      if(strlen(data[i]) <=  0 )continue;
      if(comma_flag)
	{
	  strcat(sql_str,",");
	  strcat(values,",");
	}
      
      strcat(sql_str,column[i]);
	
      if(strncmp(format[i],"char",4) == 0 ) 
	{
	  strcat(values,"'");
	  strcat(values,data[i]);
	  strcat(values,"'");
	}
      else
	{
	  if ( strcmp (column[i],"n_attrno") == 0 )
	    {
	      sprintf(tmp_str,"%d",n_attrno);
	      strcat(values,tmp_str);
	    }
	  else if ( strcmp (column[i],"n_seqno") == 0 )
	    {
	      sprintf(tmp_str,"%d",n_seqno);
	      strcat(values,tmp_str);
	    }
	  else if ( strcmp (column[i],"n_tableno") == 0 )
	    {
	      sprintf(tmp_str,"%d",catalog_no);
	      strcat(values,tmp_str);
	    }
	  else
	    strcat(values,data[i]);
        }
      comma_flag=1;
    }
  strcat(sql_str,") " );
  strcat(values,") " );
  strcat(sql_str,values);
  status = SQLstmt (sql_str) ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQL stmt failed : status = <0x%.8x>\n",
		  status)) ;
      
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      MEMclose (&buffer);
      return (NFM_E_SQL_STMT) ;
    }
  
  
  
  MEMclose (&buffer);
  
  return(NFM_S_SUCCESS);
}


int CVTcat_unload (catalog_name) 
     char *catalog_name;
{
  char *fname = "CVTcat_unload";
  char command[500], sql_str[1024];
  FILE *fp;
  char str1[25];
  long status;
  struct   stat  fbuff;
  
  
  strcpy(str1, "CVTcatalog.dmp");
  if ((fp = fopen(str1, "w"))==NULL)
    {
      printf("Cannot open file <%s>\n",str1);
      ERRload_struct(NFM,NFM_E_FOPEN,"%s%s%d",str1,"w",errno);
      _NFMdebug((fname,"fopen failed for file <%s>\n",str1));
      return(NFM_E_FOPEN);
    }
  
  if(strlen(CVTglobal.schema_passwd))
    fprintf(fp, "default schema %s.%s\n",CVTglobal.schema_name,CVTglobal.schema_passwd);
  else
    fprintf(fp, "default schema %s\n",CVTglobal.schema_name);
  
  fclose(fp);
  if (strlen(CVTglobal.schema_passwd))
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risunload -o \
			   %s -m a -s %s .%s  table with data %s f_%s >> %s", \
		  str1,CVTglobal.schema_name,CVTglobal.schema_passwd, catalog_name, catalog_name, _NFMdebug_st.NFMdebug_file); 
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risunload -o \
			   %s -m a -s %s .%s  table with data %s f_%s >/dev/null", \
		  str1,CVTglobal.schema_name,CVTglobal.schema_passwd, catalog_name, catalog_name) ;
	}
    }
  else
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risunload -o \
			   %s -m a \
               -s %s  table with data %s f_%s >> %s", \
		  str1,CVTglobal.schema_name, catalog_name, catalog_name, _NFMdebug_st.NFMdebug_file); 
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risunload -o \
			   %s -m a \
               -s %s  table with data %s f_%s >/dev/null", \
		  str1,CVTglobal.schema_name, catalog_name, catalog_name); 
	}
    }
  
  status = NFMsystem_imm(command);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "System call failed for <%s>:status <0x%.8x>\n",command,status));
      return (status) ;
    }
  
/*  sprintf(command,"cp %s SAVECVTcat.dmp",str1);
  status = NFMsystem_imm(command);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "System call failed for <%s>:status <0x%.8x>\n",command,status));
      return (status) ;
    }
 */ 
  status = CVTNcat_script(CVTglobal.catalog,CVTglobal.o_catalog);
  if(status!=NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Cannot create script file <%s>:status <0x%.8x>\n","CVTNcat.sh",status));
      return (status) ;
    }
  /* This script should already exists */
  status = stat("CVTNcat.sh",&fbuff);
  if(status)
    {
      status = ERRload_struct (NFM, NFM_E_STAT, "%s%d", "CVTcat.sh",errno) ;
      _NFMdebug ((fname, "stat failed  for file <%s>:status <0x%.8x>\n","CVTcat.sh",NFM_E_STAT));
      return (NFM_E_STAT) ;
    }
  if (_NFMdebug_st.NFMdebug_on)
    {
      sprintf(command, "ksh CVTNcat.sh >> %s", _NFMdebug_st.NFMdebug_file);
    }
  else
    {
      strcpy(command, "ksh CVTNcat.sh");
    }
  status = NFMsystem_imm(command);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "System call failed for <%s>:status <0x%.8x>\n",command,status));
      return (status) ;
    }
  
  
  /* Remove the bad file */
  
  status = unlink ( "CVTcat.bad");
  
  
  if (strlen(CVTglobal.schema_passwd))
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
             %s -e %s -l CVTcat.log -b CVTcat.bad \
             -m w -c1000 -s %s .%s table with data %s %s >> %s",\
		  str1,CVTglobal.database,CVTglobal.schema_name,CVTglobal.schema_passwd, CVTglobal.o_catalog, CVTglobal.o_f_catalog, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
             %s -e %s -l CVTcat.log -b CVTcat.bad \
             -m w -c1000 -s %s .%s table with data %s %s >/dev/null",\
		  str1,CVTglobal.database,CVTglobal.schema_name,CVTglobal.schema_passwd, CVTglobal.o_catalog, CVTglobal.o_f_catalog);
	}
    }
  else
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
             %s -e %s -l CVTcat.log -b CVTcat.bad \
             -m w -c1000 -s %s table with data %s %s >> %s",\
		  str1,CVTglobal.database,CVTglobal.schema_name, CVTglobal.o_catalog, CVTglobal.o_f_catalog, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
             %s -e %s -l CVTcat.log -b CVTcat.bad \
             -m w -c1000 -s %s table with data %s %s >/dev/null",\
		  str1,CVTglobal.database,CVTglobal.schema_name, CVTglobal.o_catalog, CVTglobal.o_f_catalog);
	}
    }
  status = NFMsystem_imm(command);
  
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "System call failed for <%s>:status <0x%.8x>\n",command,status));
      CVTdrop_o_catalogs (catalog_name) ;
      return (status) ;
    }
  status = CVTcheck_ris_bad("CVTcat.bad");
  
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Risload  failed for <%s>:status <0x%.8x>\n",catalog_name,status));
      CVTdrop_o_catalogs (catalog_name) ;
      return (status) ;
    }
  sprintf(sql_str,"DROP TABLE %s", catalog_name);
  status=SQLexec_imm(sql_str) ;
  if (status != SQL_S_SUCCESS)
    {
      status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL) ;
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status)) ;
      CVTcat_restore(catalog_name);
      return (NFM_E_SQL_STMT) ;
    } 
  
  sprintf(sql_str,"DROP TABLE f_%s", catalog_name);
  status=SQLexec_imm(sql_str) ;
  if (status != SQL_S_SUCCESS)
    {
      status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL) ;
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status)) ;
      CVTcat_restore(catalog_name);
      return (NFM_E_SQL_STMT) ;
    } 
  
  
  return (NFM_S_SUCCESS);
}

int CVTNprocess_catalog(catalog_name, insert_bad)
     char *catalog_name;
	 long *insert_bad;
     
{
  char *fname="CVTNprocess_catalog";
  long status,i,j,k,count,size,comma,malloced_flag,found_flag,pass_no;
  char sql_str[1024],*qry_str1,*qry_str2;
  char tmp_str1[96],tmp_str2[96];
  MEMptr buffer = NULL ;
  struct CVTattr_st *attr_ptr;
  char **data, **column, **format ;
  long max_item_no, min_item_no, cur_item_no,upper_item_no;
  long CVTcat_date () ;
  char tmp[512];
  
  _NFMdebug((fname,"Entry: catalog <%s>:\n",catalog_name));
  pass_no = 0;
  fprintf(stderr,"Processing data in catalog <%s>\n",catalog_name);
  
  max_item_no= min_item_no= cur_item_no = malloced_flag = 0;
  qry_str1 = qry_str2 = NULL ;
  
  status = SQLget_max_record_num(CVTglobal.o_catalog,"n_itemno",&max_item_no);
  if(status != SQL_S_SUCCESS)
    {
      _NFMdebug((fname,"Cannot obtain maximum attribute value for\
 attribute <%s> in catalog <%s>\n","n_itemno",CVTglobal.o_catalog));
      ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot obtain maximum \
item number for a catalog");
      return(status);
    }
  status = SQLget_min_record_num(CVTglobal.o_catalog,"n_itemno",&min_item_no);
  if(status != SQL_S_SUCCESS)
    {
      _NFMdebug((fname,"Cannot obtain minimum attribute value for\
 attribute <%s> in catalog <%s>\n","n_itemno",CVTglobal.o_catalog));
      ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot obtain minimum \
item number for a catalog");
      return(status);
    }
  
  _NFMdebug((fname,"Catalog <%s>: n_itemno: max_value <%d>: min_value <%d>\n",
	     CVTglobal.o_catalog,max_item_no,min_item_no));
  
  cur_item_no = min_item_no;
  
  while ( cur_item_no <= max_item_no )
    {
      upper_item_no = cur_item_no + NUM_OF_RECORD ;
      
      sprintf(sql_str,"SELECT * from %s WHERE n_itemno >= %d AND\
 n_itemno < %d",CVTglobal.o_catalog,cur_item_no,upper_item_no);
      _NFMdebug((fname,"SQL_QUERY <%s>\n",sql_str));
      status = SQLquery (sql_str, &buffer, MEM_SIZE);
      if(status != SQL_S_SUCCESS  && status != SQL_I_NO_ROWS_FOUND )
	{
	  _NFMdebug((fname,"SQLstmt status <0x%.8x>\n",status));
	  if(malloced_flag > 0 )
	    {
	      free(qry_str1);
	      free(qry_str2);
	    }
	  return(status);
	}
      if(status == SQL_I_NO_ROWS_FOUND )
	{
	  _NFMdebug((fname,"Catalog %s has no rows with itemno \
>= %d and < %d\n",catalog_name, cur_item_no,upper_item_no));
	  cur_item_no = upper_item_no ;
	  MEMclose(&buffer);
	  continue;
	  /*
	    return(NFM_S_SUCCESS);
	    */
	}
      status = MEMbuild_array (buffer);
      if(status != MEM_S_SUCCESS)
	{
	  _NFMdebug((fname,"MEMbuild_array failed sataus: <0x%.8x>\n"));
	  ERRload_struct(NFM,NFM_E_MEM,"");
	  fprintf(stderr,"<<<<ERROR>>>>:	Cannot obtain catalog number from database\n");
	  if(malloced_flag > 0 )
	    {
	      free(qry_str1);
	      free(qry_str2);
	    }
	  MEMclose(&buffer);
	  return(status);
	}
      data = (char **) buffer -> data_ptr;
      column = (char **) buffer -> column_ptr;
      format = (char **) buffer -> format_ptr;
      
      if(malloced_flag == 0 )
	{
	  size = buffer->row_size + buffer->columns * 20 + 512 ;
	  qry_str1 = malloc(2*size);
	  if(qry_str1 == (char *)0)
	    {
	      _NFMdebug((fname,"qry_str1:Malloc failed to alloc size <%d>\n",size));
	      ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
	      MEMclose(&buffer);
	      return(NFM_E_MALLOC);
	    }
	  qry_str2 = malloc(size);
	  if(qry_str2 == (char *)0)
	    {
	      _NFMdebug((fname,"qry_str2:Malloc failed to alloc size <%d>\n",size));
	      ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
	      free(qry_str1);
	      MEMclose(&buffer);
	      return(NFM_E_MALLOC);
	    }
	  malloced_flag = 1;
	}
      i=pass_no = 0;
      while ( i < buffer->rows)
	{
	  count = i * buffer->columns;
	  sprintf(qry_str1,"INSERT INTO %s ( ", catalog_name);
	  sprintf(qry_str2," VALUES ( ");
	  
	  comma = 0;
	  for(j=0;j< buffer->columns; j++)
	    {
	      if(strlen(data[count+j]) <= 0 ) continue;
	      if(strcmp(column[j],"n_creationtime") == 0) continue;
	      if(strcmp(column[j],"n_updatetime") == 0) continue;
	      
	      if(comma)
		{
		  strcat(qry_str1," , ");
		  strcat(qry_str2," , ");
		}
	      if(CVTglobal.num_of_attr > 0 )
		{
		  attr_ptr = CVTglobal.root_attr;
		  found_flag = 0;
		  for(k=0; k < CVTglobal.num_of_attr && !found_flag; k++)
		    {
		      if(attr_ptr == NULL)
			{
			  _NFMdebug((fname,"Bad pointer to user defined date attribute\n"));
			  if(malloced_flag > 0 )
			    {
			      free(qry_str1);
			      free(qry_str2);
			    }
			  MEMclose(&buffer);
			  return(status);
			}
		      
		      if((strcmp(column[j],attr_ptr->attr_name) == 0 ))
			{
			  found_flag = 1;
			  strcat(qry_str1,column[j]);
			  status = CVTcat_date (data[count+j],
						"00:00:00",
						tmp_str2,
						&pass_no) ;
			  
			  strcat(qry_str2,tmp_str2);
			}
		      attr_ptr = attr_ptr->next_attr;
		    }
		  if(found_flag) continue;
		}
	      
	      if((strcmp(column[j],"n_creationdate") == 0 ))
		{
		  strcat(qry_str1,column[j]);
		  status = CVTcat_date (data[count+j],
					data[count+j+1],
					tmp_str2,
					&pass_no) ;
		  
		  strcat(qry_str2,tmp_str2);
		}
	      else if((strcmp(column[j],"n_updatedate") == 0 ))
		{
		  strcat(qry_str1,column[j]);
		  status = CVTcat_date (data[count+j],
					data[count+j+1],
					tmp_str2,
					&pass_no) ;
		  strcat(qry_str2,tmp_str2);
		}
	      else if (strcmp(column[j], "n_coout") == 0)
		{
		  strcat(qry_str1,"n_status");
		  sprintf(tmp_str1," '%s' ",data[count+j]);
		  strcat(qry_str2,tmp_str1);
		}
	      else
		{
		  strcat(qry_str1,column[j]);
		  if(strncmp(format[j],"char",4) == 0 )
		    {
			  strcpy(tmp, data[count+j]);
			  NFMparse_string(data[count+j], tmp);
		      sprintf(tmp_str1," '%s' ",tmp);
		      strcat(qry_str2,tmp_str1);
		    }
		  else
		    strcat(qry_str2,data[count+j]);
		}
	      comma=1;
	      
	    }
	  strcat(qry_str1,") ");
	  strcat(qry_str2,") ");
	  strcat(qry_str1,qry_str2);
	  status = SQLstmt (qry_str1) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      if(!pass_no)
		{
		  pass_no++;
		  continue;
		}
	      else
		{
		  status=CVTwrite_bad_insert(CVTglobal.catalog,qry_str1);
		  CVTupdate_cvtlog(CVTglobal.catalog,"I",-1);
		  pass_no=0;
		  *insert_bad = 1;
		  /*i++;*/
		}
	      /*
		ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		if(malloced_flag > 0 )
		{
		free(qry_str1);
		free(qry_str2);
		}
		MEMclose(&buffer);
		return (NFM_E_SQL_STMT);
		*/
	    }
	  pass_no = 0;
	  i++;
	  
	}	
      MEMclose(&buffer);
      cur_item_no = cur_item_no + NUM_OF_RECORD ;
    }
  
  if(malloced_flag > 0 )
    {
      free(qry_str1);
      free(qry_str2);
    }
  sprintf(sql_str, "Update %s set n_updater = '%s' Where n_itemlock = '%s'", catalog_name, "nfmadmin", "Y");
  status = SQLstmt(sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_STMT);
    }
  return(NFM_S_SUCCESS);
  
}

int CVTNprocess_f_catalog(catalog_name,insert_bad)
     char *catalog_name;
	 long *insert_bad;
{
  char *fname="CVTprocess_f_catalog";
  long status,i,j,count,size,comma,k,found_flag,pass_no=0;
  char sql_str[1024],*qry_str1,*qry_str2;
  char tmp_str1[96],tmp_str2[96];
  MEMptr buffer = NULL ;
  char **data, **column, **format ;
  struct CVTattr_st *attr_ptr = NULL ;
  long max_file_no,min_file_no,cur_file_no,upper_file_no,malloced_flag;
  long CVTcat_date () ;
  
  _NFMdebug((fname,"Entry: f_catalog <f_%s>:\n",catalog_name));
  fprintf(stderr,"Processing data in catalog <f_%s>\n",catalog_name);
  
  
  max_file_no= min_file_no= cur_file_no = malloced_flag = 0;
  qry_str1 = qry_str2 = NULL ;
  
  status = SQLget_max_record_num(CVTglobal.o_f_catalog,"n_fileno",&max_file_no);
  if(status != SQL_S_SUCCESS)
    {
      _NFMdebug((fname,"Cannot obtain maximum attribute value for\
 attribute <%s> in catalog <%s>\n","n_fileno",CVTglobal.o_f_catalog));
      ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot obtain maximum \
item number for a catalog");
      return(status);
    }
  status = SQLget_min_record_num(CVTglobal.o_f_catalog,"n_fileno",&min_file_no);
  if(status != SQL_S_SUCCESS)
    {
      _NFMdebug((fname,"Cannot obtain minimum attribute value for\
 attribute <%s> in catalog <%s>\n","n_fileno",CVTglobal.o_f_catalog));
      ERRload_struct(NFM,NFM_E_MESSAGE,"%s","Cannot obtain minimum \
item number for a catalog");
      return(status);
    }
  
  _NFMdebug((fname,"Catalog <%s>: n_fileno: max_value <%d>: min_value <%d>\n",
	     CVTglobal.o_f_catalog,max_file_no,min_file_no));
  
  cur_file_no = min_file_no;
  
  while ( cur_file_no <= max_file_no )
    {
      upper_file_no = cur_file_no + NUM_OF_RECORD ;
      
      sprintf(sql_str,"SELECT * from %s where n_fileno >= %d \
 AND n_fileno < %d",CVTglobal.o_f_catalog,cur_file_no,upper_file_no);
      status = SQLquery (sql_str, &buffer, MEM_SIZE);
      if(status != SQL_S_SUCCESS  && status != SQL_I_NO_ROWS_FOUND )
	{
	  _NFMdebug((fname,"SQLstmt status <0x%.8x>\n",status));
	  ERRload_struct(NFM,NFM_E_SQL_STMT,"");
	  MEMclose(&buffer);
	  if(malloced_flag > 0)
	    {
	      free(qry_str1);
	      free(qry_str2);
	    }
	  return(status);
	}
      if(status == SQL_I_NO_ROWS_FOUND )
	{
	  _NFMdebug((fname,"Catalog %s has no rows with itemno \
>= %d and < %d\n",CVTglobal.o_f_catalog, cur_file_no,upper_file_no));
	  cur_file_no = upper_file_no ;
	  MEMclose(&buffer);
	  continue;
	  /*
	    return(NFM_S_SUCCESS);
	    */
	}
      status = MEMbuild_array (buffer);
      if(status != MEM_S_SUCCESS)
	{
	  _NFMdebug((fname,"MEMbuild_array failed sataus: <0x%.8x>\n"));
	  ERRload_struct(NFM,NFM_E_MEM,"");
	  fprintf(stderr,"<<<<ERROR>>>>:	Cannot obtain catalog number from database\n");
	  if(malloced_flag > 0)
	    {
	      free(qry_str1);
	      free(qry_str2);
	    }
	  return(status);
	}
      data = (char **) buffer -> data_ptr;
      column = (char **) buffer -> column_ptr;
      format = (char **) buffer -> format_ptr;
      
      size = buffer->row_size + buffer->columns * 20 + 512 ;
      if(malloced_flag == 0 )
	{
	  qry_str1 = malloc(2*size);
	  if(qry_str1 == (char *)0)
	    {
	      _NFMdebug((fname,"qry_str1:Malloc failed to alloc size <%d>\n",size));
	      ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
	      MEMclose(&buffer);
	      return(NFM_E_MALLOC);
	    }
	  qry_str2 = malloc(size);
	  if(qry_str2 == (char *)0)
	    {
	      _NFMdebug((fname,"qry_str2:Malloc failed to alloc size <%d>\n",size));
	      ERRload_struct(NFM,NFM_E_MALLOC,"%d",size);
	      free(qry_str1);
	      MEMclose(&buffer);
	      return(NFM_E_MALLOC);
	    }
	  malloced_flag = 1;
	}
      i= pass_no = 0;
      while (i < buffer->rows)
	{
	  count = i * buffer->columns;
	  sprintf(qry_str1,"INSERT INTO f_%s ( ", catalog_name);
	  sprintf(qry_str2," VALUES ( ");
	  
	  comma = 0;
	  for(j=0;j< buffer->columns; j++)
	    {
	      if(strlen(data[count+j]) <= 0 ) continue;
	      if(strcmp(column[j],"n_citime") == 0) continue;
	      if(strcmp(column[j],"n_cotime") == 0) continue;
	      if(strcmp(column[j],"n_iconno") == 0) continue;
	      if(strcmp(column[j],"n_pendinguser") == 0) continue;
	      if(strcmp(column[j],"n_pendingflag") == 0) continue;
	      /*if(strcmp(column[j],"n_archiveno") == 0)
		{
		if(strcmp(data[count+j], "") == 0)
		{
		strcpy(data[count+7], "3.0.0");
		}
                }*/
	      if(comma)
		{
		  strcat(qry_str1," , ");
		  strcat(qry_str2," , ");
		}
	      
	      if(CVTglobal.num_of_attr > 0 )
		{
		  attr_ptr = CVTglobal.root_attr;
		  found_flag = 0;
		  for(k=0; k < CVTglobal.num_of_attr && !found_flag; k++)
		    {
		      if(attr_ptr == NULL)
			{
			  _NFMdebug((fname,"Bad pointer to user defined date attribute\n"));
			  if(malloced_flag > 0 )
			    {
			      free(qry_str1);
			      free(qry_str2);
			    }
			  MEMclose(&buffer);
			  return(status);
			}
		      
		      if((strcmp(column[j],attr_ptr->attr_name) == 0 ))
			{
			  found_flag = 1;
			  strcat(qry_str1,column[j]);
			  status = CVTcat_date (data[count+j],
						"00:00:00",
						tmp_str2,
						&pass_no) ;
			  strcat(qry_str2,tmp_str2);
			  
			}
		      attr_ptr = attr_ptr->next_attr;
		    }
		  if(found_flag) continue;
		}
	      
	      
	      if((strcmp(column[j],"n_cidate") == 0 ))
		{
		  strcat(qry_str1,column[j]);
		  status = CVTcat_date (data[count+j],
					data[count+j+1],
					tmp_str2,
					&pass_no) ;
		  
		  strcat(qry_str2,tmp_str2);
		}
	      else if((strcmp(column[j],"n_codate") == 0 ))
		{
		  strcat(qry_str1,column[j]);
		  status = CVTcat_date (data[count+j],
					data[count+j+1],
					tmp_str2,
					&pass_no) ;
		  
		  strcat(qry_str2,tmp_str2);
		}
	      else
		{
		  strcat(qry_str1,column[j]);
		  if(strncmp(format[j],"char",4) == 0 )
		    {
		      sprintf(tmp_str1," '%s' ",data[count+j]);
		      strcat(qry_str2,tmp_str1);
		    }
		  else
		    strcat(qry_str2,data[count+j]);
		}
	      comma=1;
	      
	    }
	  strcat(qry_str1,") ");
	  strcat(qry_str2,") ");
	  strcat(qry_str1,qry_str2);
	  status = SQLstmt (qry_str1) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      if(!pass_no)
		{
		  pass_no++;
		  continue;
		}
	      else
		{
		  status = CVTwrite_bad_insert(CVTglobal.f_catalog,qry_str1);
		  CVTupdate_cvtlog(CVTglobal.catalog,"I",-1);
		  pass_no=0;
		  *insert_bad = 1;
		  /*i++;*/
		}
	      /*
		ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
		_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
		if(malloced_flag > 0)
		{
		free(qry_str1);
		free(qry_str2);
		}
		MEMclose(&buffer);
		return (NFM_E_SQL_STMT);
		*/
	    }
	  pass_no=0;
	  i++;
	}	
      MEMclose(&buffer);
      cur_file_no = upper_file_no;
    }
  if(malloced_flag > 0)
    {
      free(qry_str1);
      free(qry_str2);
    }

/***** moved - so it won't rolled back the whole catalog  ******
  sprintf(sql_str, "Update f_%s set n_convertind = '3.0.0' where n_archiveno is NOT NULL", catalog_name);
  status = SQLstmt(sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_STMT);
    }
****************/

  return(NFM_S_SUCCESS);
}



int CVTdelete_all_new_attributes(catalog_no,f_catalog_no)
     int catalog_no,f_catalog_no;
{
  int status;
  char *fname="CVTdelete_all_new_attributes";
  _NFMdebug((fname,"Entry: catalog_no <%d>:f_catalog_no <%d>\n",catalog_no,f_catalog_no));
  status=CVTdelete_new_attributes(catalog_no,"n_iconname");
  status=CVTdelete_new_attributes(catalog_no,"n_lgfiletype");
  status=CVTdelete_new_attributes(catalog_no,"n_pendingflag");
  status=CVTdelete_new_attributes(f_catalog_no,"n_filenum");
  status=CVTdelete_new_attributes(f_catalog_no,"n_restoreflag"); 
  return(NFM_S_SUCCESS);
}

int CVTdelete_new_attributes ( table_no,attr_name)
     int table_no;
     char *attr_name;
{
  char *fname="CVTdelete_attr_from_nfmattributes";
  int status;
  char sql_str[512];
  
  _NFMdebug((fname,"Entry: table_no <%d>:attribute_name <%s>\n",table_no,attr_name));
  
  sprintf(sql_str,"DELETE FROM NFMATTRIBUTES WHERE n_tableno=%d AND\
 n_name='%s'",table_no,attr_name);
  
  status = SQLexec_imm(sql_str);
  if (status != SQL_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "");
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status ));
      return (NFM_E_SQL_STMT);
    }
  return(NFM_S_SUCCESS);
}




int CVTdrop_o_catalogs (catalog_name) 
     char *catalog_name;
{
  char *fname = "CVTdrop_o_catalogs";
  char sql_str[512];
  int status, status1;
  sprintf(sql_str,"%s", catalog_name);
  sprintf(sql_str,"DROP TABLE %s", CVTglobal.o_catalog);
  status1=SQLexec_imm(sql_str) ;
  sprintf(sql_str,"DROP TABLE %s", CVTglobal.o_f_catalog);
  status=SQLexec_imm(sql_str) ;
  if((status1 != SQL_S_SUCCESS) || (status != SQL_S_SUCCESS))
    {
      _NFMdebug((fname,"Drop table failed for str <%s>:status <0x%.8x>\n",sql_str,status));
	  return (NFM_E_SQL_STMT);
    }
  return(NFM_S_SUCCESS);
}
int CVTcat_restore (catalog_name) 
     char *catalog_name;
{
  char *fname = "CVTcat_restore";
  char command[500], sql_str[1024];
  char str1[25];
  struct stat fbuff ;
  long status;
  
  /*strcpy(str1, "SAVECVTcat.dmp");*/
  strcpy(str1, "CVTcatalog.dmp");
  sprintf(sql_str,"DROP TABLE %s", CVTglobal.catalog);
  status=SQLexec_imm(sql_str) ;
  sprintf(sql_str,"DROP TABLE %s", CVTglobal.o_catalog);
  status=SQLexec_imm(sql_str) ;
  sprintf(sql_str,"DROP TABLE %s", CVTglobal.f_catalog);
  status=SQLexec_imm(sql_str) ;
  sprintf(sql_str,"DROP TABLE %s", CVTglobal.o_f_catalog);
  status=SQLexec_imm(sql_str) ;
  
  
  
  status = stat("CVTNScat.sh",&fbuff);
  if(status)
    {
      status = ERRload_struct (NFM, NFM_E_STAT, "%s%d", "CVTcat.sh",errno) ;
      _NFMdebug ((fname, "stat failed  for file <%s>:status <0x%.8x>\n","CVTNScat.sh",NFM_E_STAT));
      return (NFM_E_STAT) ;
    }
  if (_NFMdebug_st.NFMdebug_on)
    {
      sprintf(command, "ksh CVTNScat.sh >> %s", _NFMdebug_st.NFMdebug_file);
    }
  else
    {
      strcpy(command, "ksh CVTNScat.sh");
    }
  status = NFMsystem_imm(command);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "System call failed for <%s>:status <0x%.8x>\n",command,status));
      return (status) ;
    }
  if (strlen(CVTglobal.schema_passwd))
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
             %s -e %s -l CVTcat.log -b CVTcat.bad \
             -m w -c1000 -s %s .%s table with data %s f_%s >> %s",\
		  str1,CVTglobal.database,CVTglobal.schema_name,CVTglobal.schema_passwd, catalog_name, catalog_name, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
             %s -e %s -l CVTcat.log -b CVTcat.bad \
             -m w -c1000 -s %s .%s table with data %s f_%s >/dev/null",\
		  str1,CVTglobal.database,CVTglobal.schema_name,CVTglobal.schema_passwd, catalog_name, catalog_name);
	}
    }
  else
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
             %s -e %s -l CVTcat.log -b CVTcat.bad \
             -m w -c1000 -s %s table with data %s f_%s >> %s",\
		  str1,CVTglobal.database,CVTglobal.schema_name, catalog_name, catalog_name, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
             %s -e %s -l CVTcat.log -b CVTcat.bad \
             -m w -c1000 -s %s table with data %s f_%s >/dev/null",\
		  str1,CVTglobal.database,CVTglobal.schema_name, catalog_name, catalog_name);
	}
    }
  status = NFMsystem_imm(command);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "System call failed for <%s>:status <0x%.8x>\n",command,status));
      return (status) ;
    }
  
  return (NFM_S_SUCCESS);
}



int _CVTget_next_seq_no (nfmtablename, column_name,table_no, index_no)
     char *nfmtablename ;
     char *column_name ;
     long table_no,*index_no ;
{
  char *fname = "_CVTget_next_seq_no" ;
  long status ;
  MEMptr buffer = NULL ;
  char **data ;
  char sql_str [1024] ;
  _NFMdebug ((fname, "tablename %s\n", nfmtablename)) ;
  sprintf (sql_str, "select max(%s) from %s where n_tableno = %d ",
	   column_name, nfmtablename,table_no) ;
  status = SQLquery (sql_str, &buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&buffer) ;
    _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
    return (NFM_E_MEM) ;
  }
  
  data = (char **) buffer->data_ptr ;
  *index_no = (atol (data [0]) + 1) ;
  
  _NFMdebug ((fname, "SUCCESSFUL : next slot %d\n", *index_no)) ;
  return (NFM_S_SUCCESS) ;
}


CVTcatalog_load_info (schema) 
     char *schema;
{
  char list_alter_tables[10][100], list_create_tables[5][100] ;
  long status, i ;
  int alter_tables, create_tables ;
  char *fname = "CVTcatalog_load_info";
  char command[100];
  
  
  strcpy(list_alter_tables[0], "nfmcatalogsamap");
  /*strcpy(list_alter_tables[0], "nfmtables");
    strcpy(list_alter_tables[1], "nfmattributes");
    strcpy(list_alter_tables[2], "nfmcatalogs");
    strcpy(list_alter_tables[3], "nfmstates"); 
    strcpy(list_alter_tables[4], "nfmlists");
    strcpy(list_alter_tables[5], "nfmvalues");
    strcpy(list_alter_tables[6], "nfmcatalogsamap");
    strcpy(list_alter_tables[7], "nfmcatalogaclmap");*/
  alter_tables = 1 ;
  schema = schema ;
  
  for (i=0; i<alter_tables; i++)
  {
    status = CVTunload (list_alter_tables[i] ) ;	
    if (status != NFM_S_SUCCESS)
      {
	status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
      }
    status = CVTrecreate_table (list_alter_tables[i]);
    if (status != NFM_S_SUCCESS)
      {
	status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
	_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
	return (NFM_E_SQL_STMT);
      }
  }
  
  strcpy(list_create_tables[0], "nfmsysattributes");
  create_tables = 1;
  for (i=0; i<create_tables; i++)
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i  \
   /usr/tmp/cvt.dmp -m w -c1000 -s %s table with data %s >> %s",  \
		  CVTglobal.schema_name, list_create_tables[i], _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i  \
   /usr/tmp/cvt.dmp -m w -c1000 -s %s table with data %s >/dev/null",  \
		  CVTglobal.schema_name, list_create_tables[i]);
	}
      system(command) ;
    }
  return (NFM_S_SUCCESS) ;
}


CVTload_cat_names(catalog_name)
     char *catalog_name;
{
  char *fname="CVTload_cat_names";
  char tmp[16],sql_str[512],*c_ptr;
  int status,flag;
  static int count=0;
  MEMptr buffer = NULL ;
  _NFMdebug((fname,"Entry: catalog_name <%s>\n",catalog_name));
  
  flag = 0;
  while(!flag)
    {
      count++;
      sprintf(tmp,"nfm%dXXXXXX",count);
      if((c_ptr=(char *)mktemp(tmp))== (char *)0)
	{
	  _NFMdebug((fname,"Call to mktemp failed: status <0x%.8x>\n",NFM_E_FAILURE));
	  
	  ERRload_struct(NFM,NFM_E_MESSAGE,"%s","mktemp call failed");
	  return(NFM_E_FAILURE);
	}
      sprintf(sql_str,"select * from ristables where table_name\
 = '%s' or table_name = 'f_%s'",tmp,tmp); 	
      status = SQLquery (sql_str, &buffer, MEM_SIZE);
      if ((status != SQL_S_SUCCESS)  && status != SQL_I_NO_ROWS_FOUND)
	{
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
	  _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
	  MEMclose(&buffer);
	  return (NFM_E_SQL_QUERY);
	}
      if(status == SQL_I_NO_ROWS_FOUND)
	{
	  flag++;
	  strcpy(CVTglobal.catalog,catalog_name);
	  sprintf(CVTglobal.f_catalog,"f_%s",catalog_name);
	  strcpy(CVTglobal.o_catalog,tmp);
	  sprintf(CVTglobal.o_f_catalog,"f_%s",tmp);
	  MEMclose(&buffer);
	}
      MEMclose(&buffer);
      
    }
  MEMclose(&buffer);
  return(NFM_S_SUCCESS);
}


CVTNcat_script (catalog_name,o_catalog_name)
     char *catalog_name,*o_catalog_name;
{
  char *fname="CVTNcat_script", cmd[100];
  long status ;
  FILE *fp , *fopen();
  static char *tmp_dir;
  char str[100];

  if((fp=fopen("CVTNcat.sh","w")) == (FILE *)0)
    {
      _NFMdebug((fname,"fopen failed for file <%s>: status <0x%.8x>\n","CVTNcat.sh",NFM_E_FOPEN));
      ERRload_struct(NFM,NFM_E_FOPEN,"%s%s%d","CVTNcat.sh","w",errno);
      return(NFM_E_FOPEN);
    }

	tmp_dir = getenv("TMPDIR");
    if (tmp_dir == NULL)
	{
	  putenv("TMPDIR=/usr/tmp");
	  tmp_dir = getenv("TMPDIR");
    }

  NFMlower_case(catalog_name, str);
  strcpy(catalog_name, str);

  sprintf(cmd, "%s\n", "chmod 777 CVTcatalog.dmp");
  fputs(cmd,fp);
  sprintf(cmd, "%s\n", "sed \"");
  fputs(cmd,fp);
  sprintf(cmd, "%s\n","/^create schema/d");
  fputs(cmd,fp);
  sprintf(cmd,"s/^create table %s/create table %s/\n",catalog_name,o_catalog_name);
  fputs(cmd,fp);
  sprintf(cmd,"s/^create table f_%s/create table f_%s/\n",catalog_name,o_catalog_name);
  fputs(cmd,fp);
  sprintf(cmd,"s/^insert into %s/insert into %s/\n",catalog_name,o_catalog_name);
  fputs(cmd,fp);
  sprintf(cmd,"s/^insert into f_%s/insert into f_%s/\" ",catalog_name,o_catalog_name);
  fputs(cmd,fp);
  sprintf(cmd, "CVTcatalog.dmp > %s%s%s\n",tmp_dir,"/","CVTcatalog1.dmp");
  fputs(cmd,fp);
  sprintf(cmd, "mv %s%s%s %s\n",tmp_dir,"/","CVTcatalog1.dmp", "CVTcatalog.dmp");
  fputs(cmd,fp);
  fclose(fp);
  
  sprintf(cmd, "chmod +x CVTNcat.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  
  if((fp=fopen("CVTNScat.sh","w")) == (FILE *)0)
    {
      _NFMdebug((fname,"fopen failed for file <%s>: status <0x%.8x>\n","CVTNScat.sh",NFM_E_FOPEN));
      ERRload_struct(NFM,NFM_E_FOPEN,"%s%s%d","CVTNcat.sh","w",errno);
      return(NFM_E_FOPEN);
    }
  /*sprintf(cmd, "%s\n", "chmod 777 SAVECVTcat.dmp");
  fputs(cmd,fp);
  sprintf(cmd, "%s\n", "sed \"");
  fputs(cmd,fp);
  sprintf(cmd, "%s","/^create schema/d\" ");
  fputs(cmd,fp);
  sprintf(cmd, "SAVECVTcat.dmp > SAVECVTcat1.dmp\n");
  fputs(cmd,fp);
  sprintf(cmd, "%s\n","mv SAVECVTcat1.dmp SAVECVTcat.dmp");
  fputs(cmd,fp);*/

  sprintf(cmd, "%s\n", "chmod 777 CVTcatalog.dmp");
  fputs(cmd,fp);
  sprintf(cmd, "%s\n", "sed \"");
  fputs(cmd,fp);
  sprintf(cmd,"s/^create table %s/create table %s/\n",o_catalog_name,catalog_name);
  fputs(cmd,fp);
  sprintf(cmd,"s/^create table f_%s/create table f_%s/\n",o_catalog_name,catalog_name);
  fputs(cmd,fp);
  sprintf(cmd,"s/^insert into %s/insert into %s/\n",o_catalog_name,catalog_name);
  fputs(cmd,fp);
  sprintf(cmd,"s/^insert into f_%s/insert into f_%s/\" ",o_catalog_name,catalog_name);
  fputs(cmd,fp);
  sprintf(cmd, "CVTcatalog.dmp > %s%s%s\n",tmp_dir,"/","CVTcatalog1.dmp");
  fputs(cmd,fp);
  sprintf(cmd, "mv %s%s%s %s\n",tmp_dir,"/","CVTcatalog1.dmp", "CVTcatalog.dmp");
  fputs(cmd,fp);
  fclose(fp);
  
  sprintf(cmd, "chmod +x CVTNScat.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}


CVTwrite_bad_insert(catalog,insert_stmt)
     char *catalog,*insert_stmt;
{
  char *fname="CVTwrite_bad_insert";
  static char *file="CVTbad_in.ris" ;
  FILE *fp , *fopen();
  _NFMdebug((fname,"Entry: Catalog <%s>\nInsert stmt <%s>\n",catalog,insert_stmt));
  
  if((fp=fopen(file,"a")) == (FILE *)0)
    {
      _NFMdebug((fname,"Cannot open file <%s>: errno <%d>\n",file,errno));
      ERRload_struct(NFM,NFM_E_FOPEN,"%s%d",file,errno);
      return(NFM_E_FOPEN);
    }
  fprintf(fp,"-- Catalog <%s> \n",catalog);
  fprintf(fp,"%s;\n",insert_stmt);
  fprintf(stderr,"ERROR:	Row insertion failed for catalog <%s>\n",catalog);
  fprintf(stderr,"INFORMATION:	Insert statement written out to file <%s>\n",file);
  fprintf(stderr,"\n\nPlease check the validity of the <insert statement> and use <ris> interactive \nutility to <insert row>\n");
  fclose(fp);
  _NFMdebug((fname,"SUCCESSFUL: status <0x%.8x>\n",NFM_S_SUCCESS));
  return(NFM_S_SUCCESS);
}

long CVTcat_date (old_date, old_time, insert_date, pass_no)
     char *old_date ;
     char *old_time ;
     char *insert_date ;
     long *pass_no ;
{
  char *fname = "CVTcat_date" ;
  long status ;
  char tmp_str[50], tmp_str2 [50] ;
  
  _NFMdebug ((fname, "old date <%s> : old time <%s>\n", old_date, old_time)) ;
  
  status=_CVTconvert_to_timestamp(old_date,tmp_str);
  if(status != NFM_S_SUCCESS)
    {
      _NFMdebug((fname,"_CVTconvert_to_timestamp Failed: status:<0x%.8x>\n",status));
      strcpy(insert_date,old_date) ;
      *pass_no = 2 ;
    }
  else
    {
      if (!strlen(old_time))
	strcpy(old_time, "00:00:00");
      if(!*pass_no)
	status = CVTconvert_to_ansi (tmp_str, tmp_str2, old_time) ;
      else
	status = CVTconvert_validate (tmp_str, tmp_str2, old_time) ;

      sprintf(insert_date," TIMESTAMP '%s' ",tmp_str2);
    }
  _NFMdebug ((fname, "SUCCESSFUL : <%s>\n", insert_date)) ;
  return (NFM_S_SUCCESS) ;
}




long CVTget_s_cat_no (catalog_name, s_cat_no) 
     char *catalog_name ;
     char *s_cat_no ;
{
  char *fname = "CVTget_s_cat_no" ;
  char sql_str [1024] ;
  MEMptr buffer = NULL ;
  char **data ;
  long status ;

  _NFMdebug ((fname, "catalog name <%s>\n", catalog_name)) ;

  sprintf(sql_str, "SELECT n_tableno FROM NFMTABLES \
  WHERE n_tablename = '%s'",catalog_name) ;
  status = SQLquery (sql_str, &buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) )
    {
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "");
      _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status));
      fprintf(stderr,"ERROR:	Cannot obtain catalog number from database\n");
      return (NFM_E_SQL_QUERY);
    }
  status = MEMbuild_array (buffer);
  if(status != MEM_S_SUCCESS)
    {
      _NFMdebug((fname,"MEMbuild_array failed sataus: <0x%.8x>\n"));
      ERRload_struct(NFM,NFM_E_MEM,"");
	fprintf(stderr,"ERROR:	Memory subsystem failed. Cannot obtain catalog number from database\n");
      return(status);
    }
  data = (char **) buffer -> data_ptr;
  strcpy (s_cat_no, data [0]) ;
  MEMclose(&buffer);
  _NFMdebug ((fname, "SUCCESSFUL : s_cat_no <%s>\n", s_cat_no)) ;
  return (NFM_S_SUCCESS) ;
}

long CVTupdates(catalog_name) 
     char *catalog_name ;
{
  long status ;
  char sql_str [500] ;
  char *fname = "CVTupdates" ;

  sprintf(sql_str, "Update f_%s set n_convertind = '3.0.0' where n_archiveno is NOT NULL", catalog_name);
  status = SQLstmt(sql_str);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      ERRload_struct(NFM, NFM_E_SQL_STMT, "", "");
      _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
      return (NFM_E_SQL_STMT);
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}
