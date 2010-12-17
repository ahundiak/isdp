#include "machine.h"
#include "CVT.h"
#include <string.h>

#define YEAR       0
#define MONTH      1
#define DAY        2
#define DELIMITER  "-"
#define NFMACTIVITY 1000

  extern struct CVTglobal_st CVTglobal ;
  extern char activity_flag ;
  char message [200] ;

long CVTconvert_sys_tables (activity)
char *activity;
{
  FILE *fp;
  long i, status;
  char list_mod_tables[22][100] ;
  int mod_tables;
  long terminate_flag, step, last_row ;
  char *fname = "CONVERTER";
  char sch[100], sql_str[100] ; 
  char str[50], command[500], log_flag [10] ;
  long CVTtable_script (), CVTcat_script ();
  struct stat buf ;
  MEMptr c_buffer = NULL ;
  char **c_data;
  long count;

  _NFMdebug ((fname, "ENTER\n")) ;
  status = CVTtable_script ();
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  /*status = CVTcat_script ();
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8.x>\n", status)) ;
      return (status) ;
    }*/

  /* mms = ordering  nfmattributes , nfmvalues, nfmlists 
           must go before nfmtables */

/* strcpy (list_mod_tables[0], "nfmcommands");
 strcpy (list_mod_tables[1], "nfmstoragearea");
 strcpy (list_mod_tables[0], "nfmsyscat");*/

 strcpy (list_mod_tables[0], "nfmactivity") ;
 strcpy (list_mod_tables[1], "nfmarchives") ;
 strcpy (list_mod_tables[2], "nfmattributes");
 strcpy (list_mod_tables[3], "nfmcatalogs");
 strcpy (list_mod_tables[4], "nfmsignoff");
 strcpy (list_mod_tables[5], "nfmcommands");
 strcpy (list_mod_tables[6], "nfmnodes");
 strcpy (list_mod_tables[7], "nfmprocesses");
 strcpy (list_mod_tables[8], "nfmprograms");
 strcpy (list_mod_tables[9], "nfmprojects");
 strcpy (list_mod_tables[10], "nfmreports");
 strcpy (list_mod_tables[11], "nfmsafiles");
 strcpy (list_mod_tables[12], "nfmsavesets");
 strcpy (list_mod_tables[13], "nfmstoragearea");
 strcpy (list_mod_tables[14], "nfmvalues");
 strcpy (list_mod_tables[15], "nfmlists");
 strcpy (list_mod_tables[16], "nfmworkflow");
 strcpy (list_mod_tables[17], "nfmacls");
 strcpy (list_mod_tables[18], "nfmtables");
 strcpy (list_mod_tables[19], "nfmstates");
 strcpy (list_mod_tables[20], "nfmsyscat");
 strcpy (list_mod_tables[21], "nfmtransitions") ;

  mod_tables = 22 ;

/********** get dump that has spec file **********/  
  if (strlen (CVTglobal.schema_passwd))
    {
      sprintf(sch, "%s.%s", CVTglobal.schema_name, CVTglobal.schema_passwd) ;
    }
  else
    {
      sprintf(sch, "%s", CVTglobal.schema_name) ;
    }
  
  status = stat ("/usr/ip32/nfm/config/convert/cvt3.0.dmp", &buf) ; 
  if (status)
    {
      strcpy (message, "/usr/ip32/nfm/config/convert/cvt3.0.dmp not found") ; 
	  _NFMdebug((fname, "Failure : error = %s\n", message));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }
/**********
  sprintf(command, "cp %s %s", "/usr/ip32/nfm/config/convert/cvt3.0.dmp", "/usr/tmp/cvt.dmp"); 

  _NFMdebug ((fname, "Executing <%s>\n", command)) ;
  status = system(command);
  if (status)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }

 strcpy(str2, "cvt.dmp");
 if ((fp = fopen(str2, "r"))==NULL)
 {
   _NFMdebug ((fname, "cannot open file\n")) ;
   ERRload_struct (NFM, NFM_E_FAILURE, "", "") ;
   return (NFM_E_FAILURE) ;
 }

************************/
  strcpy(str, "default schema ");
  strcat(str, sch);
  strcat (str, "\n") ;

  if ((fp = fopen("cvt.dmp", "w"))==NULL)
    {
      sprintf (message, "cannot open file cvt.dmp for writing") ;
      _NFMdebug ((fname, "Failure : %s\n", message)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }
  
  
  fprintf(fp, "%s", str);
  fclose(fp);
  
  sprintf(command, "cat /usr/ip32/nfm/config/convert/cvt3.0.dmp >> cvt.dmp") ;
  _NFMdebug ((fname, "executing -> %s\n", command)) ;
  status = system(command);
  if (status)
    {
      _NFMdebug ((fname, "Failure : system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  

/**********************************/

 for (i=0; i<mod_tables ; i++) 
    {
      /* unload old table */
      status = CVTquery_cvtlog_entry (list_mod_tables[i],
				      log_flag, &last_row) ;
      if ((status != NFM_S_SUCCESS)  && (status != NFM_I_NO_ROWS_FOUND))
	{
	  _NFMdebug ((fname, "Failure : query cvtlog entry : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      if (status == NFM_I_NO_ROWS_FOUND)
	{
	  log_flag[0] = 0 ;
	}

/* translate the flag into step no */
      if (! strcmp (log_flag, "B")) step = 1 ;
      else if (! strcmp (log_flag, "U")) step = 2 ;
      else if (! strcmp (log_flag, "D")) step = 3 ;
      else if (! strcmp (log_flag, "R")) step = 4 ;
      else if (! strcmp (log_flag, "T")) step = 5 ;
      else if (! strcmp (log_flag, "N")) step = 6 ;
      else if (! strcmp (log_flag, "M")) step = 7 ;
      else if (! strcmp (log_flag, "C")) step = 8 ;
      else step = 0 ;

      terminate_flag = 0 ;
      fprintf (stderr, "NFM systable <%s>\n", list_mod_tables[i]) ;
      while ((step < 8) && (!terminate_flag))
	{
	  _NFMdebug ((fname, "Performing step %d in table <%s>\n",
		      step, list_mod_tables [i])) ;
	  switch (step)
	    {
	      /**** "B" - begin conversion */
	    case 0 :
	      fprintf (stderr, "Performing : begin conversion (B)...\n") ;
	      status = CVTupdate_cvtlog (list_mod_tables[i], "B", 0) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
		  return (status) ;
		}
	      ++step ;
	      break ;
	      
	      /**** "U" - unload the original 2.0 table */
	    case 1 :
	      fprintf (stderr, "Performing : unload original 2.0 table (U)...\n") ;
	      if ((strcmp (list_mod_tables[i], "nfmactivity") == 0) &&
		  (strcmp(activity,"y") != 0)) ;
	      else
		status = CVTunload (list_mod_tables[i]);
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%..8x>\n",status));
		  return (status);
		}
	      status = CVTupdate_cvtlog (list_mod_tables[i], "U", 0) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		  return (status);
		}
	      ++step ;
	      break ;
	      
	      /**** "D" - drop the original 2.0 table */
	    case 2 :
	      fprintf (stderr, "Performing : drop original 2.0 table (D)...\n") ;
	      status =CVTdrop_sys_table (list_mod_tables[i]) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		  return (status);
		}
	      status = CVTupdate_cvtlog (list_mod_tables[i], "D", 0) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		  return (status);
		}
	      ++step ;
	      break ;
	      
	      /**** "R" - rename o_tablename in dump file ****/
	    case 3 :
	      fprintf (stderr, "Performing : Rename o_<table> into dump file (R)...\n") ;
	      if ((strcmp (list_mod_tables[i], "nfmactivity") == 0) &&
		  (strcmp(activity, "y") != 0)) ;
	      else
		status =CVTrename_dmp_file (list_mod_tables[i]) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status <0x%.8x>\n", status));
		  return (status);
		}
	      status = CVTupdate_cvtlog (list_mod_tables[i], "R", 0) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%..8x>\n",status));
		  return (status) ;
		}
	      ++step ;
	      break ;
	      
	      /**** "T" - risload o_tablename dump file ****/
	    case 4 :
	      fprintf (stderr, "Performing : Load o_<table> into DB (T)...\n") ;
	      if ((strcmp (list_mod_tables[i], "nfmactivity") == 0) &&
		  (strcmp(activity, "y") != 0)) ;
	      else
		status =CVTrisload_o_tablename (list_mod_tables[i]) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		  return (status) ;
		}
	      status = CVTupdate_cvtlog (list_mod_tables[i], "T", 0) ;
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		  return (status) ;
		}
	      ++step ;
	      break ;
	      
	      /* "N" - risload new schema tables specifications */
	    case 5 :
	      fprintf (stderr, "Performing : Load new schema specs for table (N)...\n") ;

	      status =CVTrisload_new_tables_spec (list_mod_tables[i]);
	      if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
		    return (status) ;
		  }
		  if (strcmp(list_mod_tables[i], "nfmsyscat") == 0)
		  {
			status = CVTrisload_new_index(list_mod_tables[i]);
			if (status != NFM_S_SUCCESS)
			{
			  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
			  return (status);
            }
          }
	      status = CVTupdate_cvtlog (list_mod_tables[i], "N", 0) ;
	      if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status)) ;
		    return (status) ;
		  }
	      ++step ;
	      break ;
	      
	      /* "M" - move old table data into new table */
	    case 6 :
	      if ((strcmp (list_mod_tables[i], "nfmactivity") == 0) &&
		  (strcmp(activity, "y") == 0))
		{ 
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;

          strcpy(sql_str, "Select count(*) from o_nfmactivity");
          status = SQLquery(sql_str, &c_buffer, 32*MEM_SIZE);
          if (status != SQL_S_SUCCESS) 
          {
	        if (status == SQL_I_NO_ROWS_FOUND)
            {
	          _NFMdebug ((fname, "No rows found.\n"));
	          return (NFM_S_SUCCESS);
            }
            ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
            _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n", status)) ;
            return (NFM_E_SQL_QUERY) ;
          }
  
          status = MEMbuild_array (c_buffer) ;
          if (status != MEM_S_SUCCESS)
          {
		    ERRload_struct(NFM, NFM_E_MEM, "", "");
	        _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
	        return (NFM_E_MEM);
          } 
          c_data = (char **) c_buffer -> data_ptr;
          count = (atol (c_data[0]));

		  _NFMdebug((fname, "Number of nfmactivity rows = %d\n", count));

          if (count >= NFMACTIVITY)
          {
		    /*status = CVTnfmactivity (list_mod_tables[i]) ;*/
		    status = CVTact_table ();
		    if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		      return (status) ;
		    }
		  }
		  status = CVTnfmactivity(list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		  {
		    _NFMdebug((fname, "Failure : status = <0x%.8x>\n", status));
		    return (status);
          }
       }
	      else if (strcmp (list_mod_tables[i], "nfmarchives") == 0)
		  {
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmarchives (list_mod_tables[i]) ;
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		      return (status) ;
		    }	
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}

	      else if (strcmp (list_mod_tables[i], "nfmcatalogs") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmcatalogs (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmsignoff") == 0)
		{
		  status = CVTnfmsignoff (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status  = <0x%.8x>\n", status));
		  return (status);
        }
		}

	      else if (strcmp (list_mod_tables[i], "nfmcommands") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmcommands (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmnodes") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmnodes (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmprocesses") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmprocesses (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
/*******
	      else if (strcmp (list_mod_tables[i], "nfmprograms") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmprograms (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n",status));
		      return (status) ;
		    }
		}
************/
	      else if (strcmp (list_mod_tables[i], "nfmprojects") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmprojects (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmsafiles") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmsafiles (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		/*status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }*/
		}
	      else if (strcmp (list_mod_tables[i], "nfmsavesets") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmsavesets (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		/*status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "SQL stmt : status = <0x%.8x>\n", status));
		  return (NFM_E_SQL_STMT);
        }*/
		}
	      else if (strcmp (list_mod_tables[i], "nfmstoragearea") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmstoragearea (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "Failure : status = <0x%.8x>", status));
		      return(status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmattributes") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmattributes (list_mod_tables[i]) ;
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }	
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		status = CVTrename_attr();
		if (status != NFM_S_SUCCESS)
		{
		  NFMrollback_transaction (0);
		  _NFMdebug((fname, "Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		status = NFMset_autocommit_on (0);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Failure : status = <0x%.8x>\n", status ));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmtables") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmtables (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		}
	      else if (strcmp (list_mod_tables[i], "nfmvalues") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmvalues (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmlists") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmlists (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmworkflow") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmworkflow (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmacls") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmacls (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload Index Failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
/******
	      else if (strcmp (list_mod_tables[i], "nfmsyscat") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmsyscat ();
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		}
*****************/
	      else if (strcmp (list_mod_tables[i], "nfmtransitions") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmtransitions () ;
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload index failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else if (strcmp (list_mod_tables[i], "nfmstates") == 0)
		{
		  fprintf (stderr, "Performing : Move old table into new table (M)...\n") ;
		  status = CVTnfmstates (list_mod_tables[i]);
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		status = CVTrisload_new_index(list_mod_tables[i]);
		if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug((fname, "Risload index failure : status = <0x%.8x>\n", status));
		  return (status);
        }
		}
	      else terminate_flag = 1 ;
	      if (!terminate_flag)
		{
		  status = CVTupdate_cvtlog (list_mod_tables[i], "M", 0) ;
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		  ++step ;
		}
	      break ;

	      /* "C" - drop o_table */
	    case 7 :

	      if ( (!strcmp (list_mod_tables[i], "nfmactivity"))      ||
		  (! strcmp (list_mod_tables[i], "nfmarchives"))      ||
		  (! strcmp (list_mod_tables[i], "nfmnodes"))         ||
		  (! strcmp (list_mod_tables[i], "nfmsafiles")))
		{ 
		  fprintf (stderr, "Performing : Drop o_<table> (C)...\n") ;
		  status = CVTdrop_old_table (list_mod_tables[i]) ;
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		  status = CVTupdate_cvtlog (list_mod_tables[i], "C", 0) ;
		  if (status != NFM_S_SUCCESS)
		    {
                      _NFMdebug ((fname,"Failure : status=<0x%.8x>\n",status));
                      return (status) ;
		    }
		  ++step ;
		}
	      else terminate_flag = 1 ;
	      break ;
	    }
	}  /* switch */
    }

  status = CVTnfmusers () ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = CVTconvert_nfmsysattributes () ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure:convert nfmsysattributes:status=<0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = CVTstamp_status () ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : status : <0x%.8x>\n", status)) ;
      return (status);
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
}

int CVTunload (table_name)
char *table_name ;
{
  char *fname = "CVTunload";
  char command[500];
  FILE *fp;
  char *p;
  char str1[25], str[80];
  long status ;

   _NFMdebug ((fname, "Unloading 2.0 table %s\n",
	       table_name)) ;

   strcpy(str1, "CVTtable.dmp");
   if ((fp = fopen(str1, "w"))==NULL)
   {
	 printf("Cannot open file\n");
	 exit(1);
   }

  if (strlen (CVTglobal.schema_passwd))
  {
      sprintf (str, "default schema %s.%s\n", 
	       CVTglobal.schema_name, CVTglobal.schema_passwd) ;
  }
  else
  {
      fprintf (fp, "default schema %s\n", 
	       CVTglobal.schema_name) ;
  }
   p = str;
   while(*p)
	 if (fputc(*p++, fp)==EOF)
	 {
	   printf("Error writing file\n");
	   exit(1);
     }
   fclose(fp);

  unlink ("ris.bad") ;

  if (strlen (CVTglobal.schema_passwd))
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risunload -o CVTtable.dmp -m a -s %s .%s\
		  table with data %s >> %s", 
		  CVTglobal.schema_name, CVTglobal.schema_passwd,
		  table_name, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risunload -o CVTtable.dmp -m a -s %s .%s\
		  table with data %s >/dev/null", 
		  CVTglobal.schema_name, CVTglobal.schema_passwd,
		  table_name) ;
	}
	  _NFMdebug ((fname, "executing -> <%s>\n", command)) ;
    }
  else
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risunload -o CVTtable.dmp -m a -s %s 		  table with data %s >> %s", 
		  CVTglobal.schema_name, table_name, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risunload -o CVTtable.dmp -m a -s %s 		  table with data %s >/dev/null", 
		  CVTglobal.schema_name, table_name);
	}
      _NFMdebug ((fname, "executing -> <%s>\n", command)) ;
    }
  status = system(command) ;
  if (status)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to risunload failed") ;
      return (NFM_E_MESSAGE) ;
    }

  /*status = SQLunload(str1, CVTglobal.schema_name,CVTglobal.schema_passwd,table_name);

  if (status != SQL_S_SUCCESS)
  {
	_NFMdebug((fname, "RISUNLOAD FAILED : status = <0x%.8x>\n", status));
	ERRload_struct(NFM, NFM_E_MESSAGE, "%s", "RISUNLOAD FUNCTION FAILED");
	return (NFM_E_MESSAGE);
  }
  _NFMdebug ((fname, "RISUNLOAD SUCCESSFUL\n"));*/

  status = CVTcheck_ris_bad ("ris.bad") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : risunload failed : status = <0x%x.8>\n",
		  status)) ;
      return (status) ;
    }

   _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS);
}

int CVTdrop_sys_table (table_name) 
char *table_name ;
{
   char *fname = "CVTdrop_sys_table" ;
   long status;
   char sql_str[1024];

   _NFMdebug ((fname, "load new schema %s and renamed o_%s\n",
	       table_name, table_name)) ;
  /* Dropping old table */
  sprintf(sql_str,"DROP TABLE %s", table_name);
  status=SQLexec_imm (sql_str) ;
  if (status != SQL_S_SUCCESS)
  {
	status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL) ;
	_NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status)) ;
	return (NFM_E_SQL_STMT) ;
  } 
   _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
 }

int CVTrename_dmp_file (table_name)
char *table_name ;
{
   char *fname = "CVTrename_dmp_file" ;
   char command[100];
   long status;

   _NFMdebug ((fname, "renamed o_%s\n", table_name)) ;

   if (_NFMdebug_st.NFMdebug_on)
     {
       sprintf(command, "ksh CVTtable.sh >> %s", _NFMdebug_st.NFMdebug_file);
     }
   else
     {
       sprintf(command, "ksh CVTtable.sh") ;
     }
   _NFMdebug ((fname, "executing -> %s\n", command)) ;
   status = system(command);
   if (status)
     {
       _NFMdebug ((fname, "system : errno %d\n", errno)) ;
       ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to CVTtable.sh failed") ;
       return (NFM_E_MESSAGE) ;
     }
   
   _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
 }

int CVTrisload_o_tablename (table_name)
char *table_name ;
{
  char *fname = "CVTrisload_o_tablename" ;
  char command [500] ;
  long status ;

  _NFMdebug ((fname, "ENTER\n")) ;

 /* old edited table */
  unlink ("ris.bad") ;

  if (strlen (CVTglobal.schema_passwd))
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
		 CVTtable.dmp -e %s -m w -c1000 -s %s .%s\
		 table with data o_%s >> %s", 
		  CVTglobal.database,
		  CVTglobal.schema_name, CVTglobal.schema_passwd,
		  table_name, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
		 CVTtable.dmp -e %s -m w -c1000 -s %s .%s\
		 table with data o_%s >/dev/null", 
		  CVTglobal.database,
		  CVTglobal.schema_name, CVTglobal.schema_passwd,
		  table_name);
	}
    }
  else
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
		 CVTtable.dmp -e %s -m w -c1000 -s %s \
		 table with data o_%s >> %s", 
		  CVTglobal.database,
		  CVTglobal.schema_name, 
		  table_name, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
		 CVTtable.dmp -e %s -m w -c1000 -s %s \
		 table with data o_%s >/dev/null", 
		  CVTglobal.database,
		  CVTglobal.schema_name, 
		  table_name);
	}
    }
  _NFMdebug ((fname, "executing -> %s\n", command)) ;
   status = system(command);
  if (status)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to risload failed") ;
      return (NFM_E_MESSAGE) ;
    }
	/*strcpy(data_file,"CVTtable.dmp");
	sprintf(o_tablename, "o_%s", table_name);
	status = SQLtable_data(data_file,CVTglobal.database,CVTglobal.schema_name,CVTglobal.schema_passwd,o_tablename);
	if (status != SQL_S_SUCCESS)
	{
	  _NFMdebug((fname, "RISLOAD FUNCTION CALL FAILED : status = <0x%.8x>\n", status));
	  ERRload_struct(NFM,NFM_E_MESSAGE,"%s", "RISLOAD FUNCTION FAILED");
	  return (NFM_E_MESSAGE);
    }
    _NFMdebug((fname, "RISLOAD SUCCESSFUL\n"));
*/
  status = CVTcheck_ris_bad ("ris.bad") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : risload failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
 }

int CVTrisload_new_tables_spec(table_name)  
char *table_name ;
{
   char *fname = "CVTrisload_new_tables_spec" ;
   char command[500] ;
   long status;

/* Load schema with ris */
/* new specification of table */  
   unlink ("ris.bad") ;

 	/*status = SQLtabledef(CVTglobal.database, CVTglobal.schema_name, 
			 CVTglobal.schema_passwd, table_name);
    if(status != SQL_S_SUCCESS)
	{
	  _NFMdebug((fname, "RIS loader : status = <0x%.8x>\n", status));
	  ERRload_struct(NFM, NFM_E_MESSAGE, "%s", "RIS loader function call failed"); 
	  return (status);
    }
	_NFMdebug((fname, "RIS LOADER FUNCTION SUCCESSFUL.\n"));
*/
  if (strlen (CVTglobal.schema_passwd))
     {
       if (_NFMdebug_st.NFMdebug_on)
	 {
	   sprintf (command, "/usr/ip32/ris/risucu/bin/risload -i \
		  cvt.dmp -e %s -m w -s %s .%s table \
		  %s >> %s",
		    CVTglobal.database,
		    CVTglobal.schema_name, 
		    CVTglobal.schema_passwd,
		    table_name, _NFMdebug_st.NFMdebug_file);
	 }
       else
	 {
	   sprintf (command, "/usr/ip32/ris/risucu/bin/risload -i \
		  cvt.dmp -e %s -m w -s %s .%s table \
		  %s >/dev/null",
		    CVTglobal.database,
		    CVTglobal.schema_name, 
		    CVTglobal.schema_passwd,
		    table_name);
	 }
     }
   else
     {
       if (_NFMdebug_st.NFMdebug_on)
	 {
	   sprintf (command, "/usr/ip32/ris/risucu/bin/risload -i \
		  cvt.dmp -e %s -m w -s %s table \
		  %s >> %s", 
		    CVTglobal.database,
		    CVTglobal.schema_name, table_name, 
		    _NFMdebug_st.NFMdebug_file);
	 }
       else
	 {
	   sprintf (command, "/usr/ip32/ris/risucu/bin/risload -i \
		  cvt.dmp -e %s -m w -s %s table \
		  %s >/dev/null", 
		    CVTglobal.database,
		    CVTglobal.schema_name, table_name);
	 }
     }
   _NFMdebug ((fname, "executing %s\n", command)) ;
   status = system(command);
  if (status)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to risload failed") ;
      return (NFM_E_MESSAGE) ;
    }
   status = CVTcheck_ris_bad ("ris.bad") ;
   if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname, "Failure : ris operation failed : status = <0x%..8x>\n",
		   status)) ;
       return (status) ;
     }
    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS) ;
 }

int CVTrisload_new_index(table_name)  
char *table_name ;
{
   char *fname = "CVTrisload_new_index" ;
   char command[500] ;
   long status;

/* Load schema with ris */
/* new specification of index */  
   unlink ("ris.bad") ;

   if (strlen (CVTglobal.schema_passwd))
     {
       if (_NFMdebug_st.NFMdebug_on)
	 {
	   sprintf (command, "/usr/ip32/ris/risucu/bin/risload -i \
		  cvt.dmp -e %s -m w -s %s .%s \
		  index %s >> %s",
		    CVTglobal.database,
		    CVTglobal.schema_name, 
		    CVTglobal.schema_passwd,
		    table_name, _NFMdebug_st.NFMdebug_file);
	 }
       else
	 {
	   sprintf (command, "/usr/ip32/ris/risucu/bin/risload -i \
		  cvt.dmp -e %s -m w -s %s .%s \
		  index %s >/dev/null",
		    CVTglobal.database,
		    CVTglobal.schema_name, 
		    CVTglobal.schema_passwd,
		    table_name);
	 }
     }
   else
     {
       if (_NFMdebug_st.NFMdebug_on)
	 {
	   sprintf (command, "/usr/ip32/ris/risucu/bin/risload -i \
		  cvt.dmp -e %s -m w -s %s \
		  index %s >> %s", 
		    CVTglobal.database,
		    CVTglobal.schema_name, table_name, 
		    _NFMdebug_st.NFMdebug_file);
	 }
       else
	 {
	   sprintf (command, "/usr/ip32/ris/risucu/bin/risload -i \
		  cvt.dmp -e %s -m w -s %s \
		  index %s >/dev/null", 
		    CVTglobal.database,
		    CVTglobal.schema_name, table_name);
	 }
     }
   _NFMdebug ((fname, "executing %s\n", command)) ;
   status = system(command);
  if (status)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to risload failed") ;
      return (NFM_E_MESSAGE) ;
    }
/*	status = SQLindex(CVTglobal.database,CVTglobal.schema_name,CVTglobal.schema_passwd,table_name);
	if (status != SQL_S_SUCCESS)
	{
	  _NFMdebug((fname, "RIS Loader Index failed : status = <0x%.8x>\n", status));
	  ERRload_struct(NFM, NFM_E_MESSAGE, "%s", "RIS LOADER INDEX function call failed");
	  return (NFM_E_MESSAGE);
     }
	 _NFMdebug((fname, "RIS LOADER INDEX FUNCTION SUCCESSFUL.\n"));
*/
     status = CVTcheck_ris_bad ("ris.bad") ;
   if (status != NFM_S_SUCCESS)
     {
       _NFMdebug ((fname, "Failure : ris operation failed : status = <0x%..8x>\n",
		   status)) ;
       return (status) ;
     }
   _NFMdebug ((fname, "SUCCESSFUL\n")) ;
   return (NFM_S_SUCCESS) ;
 }


long CVTalter_table_add_col (tablename, columnname, datatype)
     char *tablename ;
     char *columnname ;
     char *datatype ;
{
  char *fname = "CVTalter_table_add_col" ;
  long status ;
  char str [100] ;

  _NFMdebug ((fname, "ENTER\n")) ;
  sprintf (str, "alter table %s add %s %s",
	   tablename, columnname, datatype) ;
  status = SQLstmt (str) ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_STMT) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}




int CVTconvert_to_ansi (data, new_date, time)
char *data, new_date[20], time[10];
{
  char year[20], month[20], *year1, *i, msg[5];
  char *fname = "CVTconvert_to_ansi";

  strcpy(year, data);
  strcpy(month, year);
  i= (char *) strchr (year, '.');
  if (i == NULL)
  {
	sprintf(msg, "Unknown date for %s", year);
	sprintf(msg, "String Search of . in %s Failed", year);
	_NFMdebug ((fname, "%s\n", msg));
	ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg);
	return (NFM_E_MESSAGE);
  }
  *i='-';
  ++i;
  year1= (char *) strrchr (i, '.');
  if (year1 == NULL)
  {
	sprintf(msg, "Unknown date for %s", i);
	sprintf(msg, "String Search of . in %s Failed", i);
	_NFMdebug ((fname, "%s\n", msg));
	ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg);
	return (NFM_E_MESSAGE);
  }
  *year1= '-';
  ++year1;
  strcat(year, ":");
  strcat(year, time);
  sprintf(new_date, year);
  return (NFM_S_SUCCESS);
}

int CVTconvert_validate(data, new_date, time)
char *data;
char new_date[20], time[10];
{
  char year[20], month[20], *year1, *i, msg[5];
  char *fname = "CVTconvert_validate";
  long status;
  
  _NFMdebug((fname, "Input date = %s", data));

  strcpy(year, data);
  strcpy(month, year);
  i= (char *) strchr (year, '.');
  if (i == NULL)
  {
	sprintf(msg, "Unknown date for %s", year);
	sprintf(msg, "string Search of . in %s Failed", year);
	_NFMdebug ((fname, "%s\n", msg));
	ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg);
	return (NFM_E_MESSAGE);
  }
  *i='-';
  ++i;
  year1= (char *) strrchr (i, '.');
  if (year1 == NULL)
  {
	sprintf(msg, "Unknown date for %s", i);
	sprintf(msg, "String Search of . in %s Failed", i);
	_NFMdebug ((fname, "%s\n", msg));
	ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg);
	return (NFM_E_MESSAGE);
  }
  *year1= '-';
  ++year1;

  status = CVTvalidate(year);
  if (status != NFM_S_SUCCESS)
  {
    strcpy(year, "0001-01-01");
	_NFMdebug((fname, "Invalid date : status <0x%.8x>\n", status));
  }

  strcat(year, ":");
  strcat(year, time);
  sprintf(new_date, year);
  return (NFM_S_SUCCESS);
}



int CVTvalidate (v_date)
  char    *v_date;
  {
    int     i;
    long    status ;
    char    *save_date;
    char    *tokens[4];
    char    *fname = "CVTvalidate" ;

	_NFMdebug((fname, "Input date = %s", v_date));

    /*  Initialize the tokens array  */

    for (i = 0; i < 3; ++i)
        tokens[i] = NULL;

    /*  Save the input string  */

    if ((save_date = (char *) malloc (strlen (v_date) + 1)) == NULL)
      {
        _NFMdebug ((fname, "error allocating dynamic memory; size = <%d>\n",
            strlen (v_date) + 1));
	ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
        return (NFM_E_MALLOC);
      }

    strcpy (save_date, v_date);

    /*  Parse the string  */

    for (i = 0; i < 3; ++i)
      {
        if (i)
            tokens[i] = strtok (NULL, DELIMITER);
        else
            tokens[i] = strtok (save_date, DELIMITER);

        if (tokens[i] == NULL)
          {
           if (i != 0)
              {
                _NFMdebug ((fname, "Bad delimiter\n"));
                ERRload_struct (NFM, NFM_E_DATE_BAD_DELIMITER, "%s",
				DELIMITER) ;
		status = NFM_E_DATE_BAD_DELIMITER;
              }
            else
              {
                _NFMdebug ((fname, "Not enough fields specified\n"));
                ERRload_struct (NFM, NFM_E_DATE_NOT_ENOUGH_FIELDS, "", "");
		status = NFM_E_DATE_NOT_ENOUGH_FIELDS;
              }
            free (save_date);
            return (status);
              }
      }

    if ((tokens[3] = strtok (NULL, DELIMITER)) != NULL)
      {
        _NFMdebug ((fname, "Must be 3 separate fields\n"));
        free (save_date);
	ERRload_struct (NFM, NFM_E_DATE_BE_THREE_FIELDS, "", "");
        return (NFM_E_DATE_BE_THREE_FIELDS) ;
      }

    if ((strlen (tokens[YEAR])) == 2)
      {
        if ((atoi (tokens[YEAR])) < 0)
          {
           /*  It is an invalid 2 digit year value  */
            _NFMdebug ((fname, "Failure : Invalid 2 digit year value <%s>\n",
                     tokens[YEAR]));
            free (save_date);
            ERRload_struct (NFM, NFM_E_DATE_BAD_YEAR_VALUE, "%s", 
			    tokens[YEAR]) ;
            return (NFM_E_DATE_BAD_YEAR_VALUE) ;
	  }
      }
    else if ((strlen (tokens[YEAR])) == 4)
      {
        if ((atoi (tokens[YEAR])) < 1900)
          {
            /*  It is an invalid 4 digit year value  */
            _NFMdebug ((fname, "Failure : Invalid 4 digit year value <%s>\n",
                     tokens[YEAR]));
            free (save_date);
            ERRload_struct (NFM, NFM_E_DATE_BAD_YEAR_VALUE,"%s", tokens[YEAR]);
            return (NFM_E_DATE_BAD_YEAR_VALUE);
           }
      }
    else
      {
        /*  There is an incorrect number of digits in the year value  */
        _NFMdebug ((fname, "Failure : Incorrect number of digits in year value <%d>\n",
                 strlen (tokens[YEAR]))) ;
        sprintf (message, "%d", strlen(tokens[YEAR])) ;
        free (save_date);
        ERRload_struct (NFM, NFM_E_DATE_BAD_DIGIT_YEAR, "%s", message);
        return (NFM_E_DATE_BAD_DIGIT_YEAR) ;
        }

    if (((atoi (tokens[MONTH])) <= 0) || ((atoi (tokens[MONTH])) > 12))
      {
        /*  It is an invalid month value  */

        _NFMdebug ((fname, "Failure : Invalid month value <%s>\n", tokens[MONTH]));
        free (save_date);
        ERRload_struct (NFM, NFM_E_DATE_BAD_MONTH_VALUE, "%s", tokens[MONTH]);
        return (NFM_E_DATE_BAD_MONTH_VALUE);
      }

    if (((atoi (tokens[DAY])) <= 0) || ((atoi (tokens[DAY])) > 31))
      {
       /*  It is an invalid day value  */
        _NFMdebug ((fname, "Failure : Invalid day value <%s>\n", tokens[DAY]));
        free (save_date);
        ERRload_struct (NFM, NFM_E_DATE_BAD_DAY_VALUE, "%s", tokens[DAY]);
        return (NFM_E_DATE_BAD_DAY_VALUE);
        }
   /* strcpy (token1, tokens [0]) ;
    strcpy (token2, tokens [1]);
    strcpy (token3, tokens [2]);*/

    free (save_date);
    return (NFM_S_SUCCESS);
  }

int CVTdrop_old_table (table_name)
char *table_name;
{
  long status;
  char *fname="CVTdrop_old_table";
  char sql_str[1024];

  sprintf(sql_str, "DROP TABLE o_%s", table_name);
  status = SQLexec_imm (sql_str);
  if (status != SQL_S_SUCCESS) 
  {
    status = ERRload_struct (NFM, NFM_E_SQL_STMT, "%s", sql_str);
    _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
    return (NFM_E_SQL_STMT);
  }
  return (NFM_S_SUCCESS) ;
}

long CVTtable_script ()
{
  char *fname = "CVTtable_script", cmd[100];
  long status ;
  /***************   Create Editing Script           *************/ 
  sprintf(cmd, "echo '%s' > %s", "chmod 777 CVTtable.dmp",  "CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo '%s' >> %s", "sed \"", "CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo '%s' >> %s", "/^create schema/d", "CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo '%s' >> %s", "s/^create table/create table o_/", "CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo '%s' >> %s", "s/^create table o_ /create table o_/", "CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo '%s' >> %s", "s/^insert into/insert into o_/", "CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo '%s' %s >> %s", "s/^insert into o_ /insert into o_/\"", "CVTtable.dmp '>' CVTtable1.dmp", "CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo '%s' >> %s", "mv CVTtable1.dmp CVTtable.dmp", "CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  /*sprintf(cmd, "echo } >> CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }*/
  sprintf(cmd, "chmod +x CVTtable.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  return (NFM_S_SUCCESS);
}

long CVTcat_script ()
{
  char *fname="CVTcat_script", cmd[100];
  long status ;
  /***************   Create Editing Script for Catalogs  *************/ 

  if (_NFMdebug_st.NFMdebug_on)
    {
      sprintf(cmd, "echo %s > %s >> %s", "chmod 777 catalog.dmp",  "CVTcat.sh", _NFMdebug_st.NFMdebug_file);
    }
  else
    {
      sprintf(cmd, "echo %s > %s", "chmod 777 catalog.dmp",  "CVTcat.sh");
    }
      status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }

  sprintf(cmd, "echo '%s' >> %s", "ex -s catalog.dmp << '}' ", \
	  " CVTcat.sh");

  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo :g/create schema/d >> CVTcat.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo :g/create table/s//create table o_/ >> CVTcat.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo :g/create table o_ /s//create table o_/ >> CVTcat.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo :g/insert into/s//insert into o_/ >> CVTcat.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo :g/insert into o_ /s//insert into o_/ >> CVTcat.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo :wq! >> CVTcat.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "echo } >> CVTcat.sh");
  status = system(cmd);
  if (status < 0)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to cp failed") ;
      return (NFM_E_MESSAGE) ;
    }
  sprintf(cmd, "chmod +x CVTcat.sh");
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

int CVTrecreate_table (table_name)
char *table_name ;
{
   char *fname = "CVTrecreate_table" ;
   long status;

   _NFMdebug ((fname, "load new schema %s and renamed o_%s\n",
	       table_name, table_name)) ;
  /* Dropping old table */
   status =CVTdrop_sys_table (table_name) ;
   if (status != NFM_S_SUCCESS)
     {
       status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
       return (NFM_E_SQL_STMT);
     }
   
/* Edit ris.dmp file to add default schema <passwd> statement.  */

/*status = CVTtable_script();*/

   status =CVTrename_dmp_file (table_name) ;
   if (status != NFM_S_SUCCESS)
     {
       status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
       return (NFM_E_SQL_STMT);
     }
   
   status =CVTrisload_o_tablename (table_name) ;
   if (status != NFM_S_SUCCESS)
     {
       status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
       return (NFM_E_SQL_STMT);
     }

/* Load schema with ris */
/* new specification of table */  
   status =CVTrisload_new_tables_spec (table_name) ;
   if (status != NFM_S_SUCCESS)
     {
       status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
       _NFMdebug ((fname, "SQL stmt : status = <0x%.8x>\n", status));
       return (NFM_E_SQL_STMT);
     }

   _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS);
 }


int CVTload_function (table_name)
char *table_name;
{
  char *fname = "CVTload_function" ;
  char command [200] ;
  long status ;

  _NFMdebug ((fname, "table name <%s>\n", table_name)) ;
  unlink ("ris.bad") ;

  if (strlen (CVTglobal.schema_passwd))
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
		 /usr/ip32/nfm/config/initial/ris3.0.dmp -e %s -m w -s %s .%s\
		 table with data %s >> %s", 
		  CVTglobal.database,
		  CVTglobal.schema_name, CVTglobal.schema_passwd,
		  table_name, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
		 /usr/ip32/nfm/config/initial/ris3.0.dmp -e %s -m w -s %s .%s\
		 table with data %s >/dev/null", 
		  CVTglobal.database,
		  CVTglobal.schema_name, CVTglobal.schema_passwd,
		  table_name);
	}
    }
  else
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
		 /usr/ip32/nfm/config/initial/ris3.0.dmp -e %s  -m w -s \
		 %s table with data %s >> %s", 
		  CVTglobal.database,
		  CVTglobal.schema_name, table_name, _NFMdebug_st.NFMdebug_file);
	}
      else
	{
	  sprintf(command, "/usr/ip32/ris/risucu/bin/risload -i \
		 /usr/ip32/nfm/config/initial/ris3.0.dmp -e %s  -m w -s \
		 %s table with data %s >/dev/null", 
		  CVTglobal.database,
		  CVTglobal.schema_name, table_name);
	}
    }
   status = system(command);
  if (status)
    {
      _NFMdebug ((fname, "system : errno %d\n", errno)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "system call to risload failed") ;
      return (NFM_E_MESSAGE) ;
    }
  status = CVTcheck_ris_bad ("ris.bad") ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : ris operation failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTact_table ()
{
  long status, j;
  char sql_str[500];
  MEMptr a_buffer = NULL;
  char **a_data;
  char *fname = "CVTact_table";

  _NFMdebug ((fname, "Getting Commands For The Nfmactivity Query.\n"));

  strcpy(sql_str, "SELECT n_commandname FROM nfmcommands");
  status = SQLquery(sql_str, &a_buffer, MEM_SIZE);
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
  {
	ERRload_struct(NFM, NFM_E_SQL_QUERY, "", "");
	_NFMdebug((fname, "SQL query : status = <0x%.8x>\n", status)) ;
	return (NFM_E_SQL_QUERY);
  }
  status = MEMbuild_array(a_buffer);
  if (status != MEM_S_SUCCESS)
  {
	ERRload_struct(NFM, NFM_E_MEM, "", "");
	_NFMdebug ((fname, "MEMbuild_array : status = <0x%.8>\n", status));
	return (NFM_E_MEM);
  }

  a_data = (char **) a_buffer -> data_ptr;
  for (j=0; j<a_buffer->rows; j++)
  {
	status = CVTnfmactivity(a_data[j]);
	if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	  return (status);
    }
  }
  _NFMdebug ((fname, "SUCCESSFUL\n"));
  return (NFM_S_SUCCESS);
}
