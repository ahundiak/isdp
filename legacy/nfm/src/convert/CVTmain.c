#include "machine.h"
#include "CVT.h"
#include "NFMsysstruct.h"

#define ECHO_S 0
#define NOECHO 1

/******** FIRST FORM *********/
#define S_ENVIRONMENT 0
#define S_USERNAME    1
#define S_PASSWD      2
#define S_NFMDEBUG    3
#define S_ACTIVITY    4
#define S_MEMDEBUG    5


/****** SECOND FORM ************/
#define S_CATALOG     1

struct NFMglobal_st NFMglobal ;
struct CVTglobal_st CVTglobal ;
extern struct NETuser_struct NETusr_info ;
extern struct NFMuser_info_struct NFMuser_info ;
int  relation[1024], relation1[1024], skip_relation ;
int  def[50] ; 
char old_db[50] , terminal_name[30] ;
char **def_buf ;
int fd1 ;
int global_item_no ;
int global_item_rev_flag ;
int global_ci_flag ;
char activity_flag ;

main(argc, argv)
     int argc ;
     char **argv ;
{
  char *fname = "main" ;
  char message [512] ;
  UNIT_INFO  acq_data, acq_data1, catalogs ;
  long status ;
  int i , first_form, second_form, y ;
  int cat_selection [5000] ;
  long no_selected ;
  long exit_flag = 0, tot_data, no_catalogs ;
  char env_name [15] ;
  char sql_str [1024], **data ;
  long CVTlogout () ;
  MEMptr sql_buffer = NULL ;
  char systables_flag, cat_flag, wf_flag, search_sort_flag ;
  char process_flag, completion_flag ;
  char nfm_file [NFM_CIFILENAME+1] ;
  char mem_file [NFM_CIFILENAME+1] ;
  char username [NFM_USERNAME +1] ;
  char password [51] ;
  long take_defaults ;
  int  flag ;
  char activity[2];
  long CVTline_options ();  

/*********** BLANK FORM ONE  *******************************/
  static char *other_titles[] ={"-----------------------------------", 
                                  "" ,
                                  "Control C - To Terminate Conversion now",
                                  "PF1       - To Resume Conversion now",
                                  "Backspace/Delete - To delete",
                                  NULL } ;

  static char *titles_new[] = { "Environment name",
				  "Username",
                                  "Password", 
                                  "NFM/SQL Debug",
				  "Convert nfmactivity",
                                  "MEM Debug",
                                  NULL } ;
    
  static char *def_val[] = { "",
                               "nfmadmin",
                               "",
                               "/dev/console",
			       "n",
                               "",
                               NULL
			       } ;

  static short attrs[] = {   ECHO_S,
			       ECHO_S,
			       NOECHO,
			       ECHO_S,
			       ECHO_S,
			       ECHO_S,
			       ECHO_S,
			       NULL
			       } ;

  static char *extra_char[] = { "_",
				  "_",
				  "_",
				  "_./\"",
				  "_/.,",
				  "",
				  "_/.,",
				  NULL
				  } ;



/***********  BLANK FORM 2  *******************************/

  static char *titles_new1[] = { "NFM System Tables",
				  "Catalogs",
                                  "Workflow",
				  "Search/Sort Criteria",
				  "Programs/Processes",
				  "Completion Check & Cleanup",
                                  NULL } ;
    
  static char *def_val1[] = { "n",
                               "n",
                               "n",
			       "n",
			       "n",
			       "n",
                               NULL
			       } ;

  static short attrs1[] = {   ECHO_S,
			       ECHO_S,
			       ECHO_S,
			       ECHO_S,
			       ECHO_S,
                               ECHO_S,
			       NULL
			       } ;

  static char *extra_char1[] = { "",
				   "",
				  "",
				  "",
				  "",
				  "",
				  NULL
				  } ;

  static char *other_titles1[] ={"-----------------------------------", 
                                  "" ,
                                  "Control C - To Terminate Conversion now",
                                  "PF1       - To Resume Conversion now",
                                  "Backspace/Delete - To delete",
                                  NULL } ;


  
  /**************   init error msg *******************/
  ERRinit_messages ("",0);
  ERRreset_struct () ;
  /* init attribute structure */
  CVTglobal.num_of_attr = 0 ;
  CVTglobal.root_attr = NULL ;

  /************** init NFMuser_info structure - used copying search files */
  NFMuser_info.uid = getuid () ;
  NFMuser_info.gid = getgid () ;

  /**************   HEADING  **************************/

  nfm_file [0] = 0 ;
  username [0] = 0 ;
  password [0] = 0 ;
  env_name [0] = 0 ;
  activity [0] = 0 ;
/*  activity_flag = 'n' ;*/

  status = CVTline_options (argc, argv, nfm_file, username, password, env_name, activity, &take_defaults) ;
  if (status != NFM_S_SUCCESS)
    {
      fprintf (stderr, 
	       "CVTnfm : line options failed\n") ;
      exit (0) ;
    }
  
  if (strlen(nfm_file)) 
    {
      mem_file [0] = 0 ;
    }
  heading() ;  

  /*************  RIS PRINT ***************************/
  SQLload_ris_print_format ("mm/dd/yyyy hh24:nn:ss") ;

  /**************   GET TERMINAL NAME    ********************/

  if ((! strlen (env_name)) || (! strlen(username)) || (! strlen(password)))
    {
      /*********    BLANK FORM ONE  ******************/
      /* copy default multidimensional array */
      for (i=0; def_val[i] != NULL; i++)  ;

      def_buf = (char **) malloc (i * sizeof (char *)) ;
      memset (def_buf, NULL, i*sizeof (char *)) ;
      
      first_form = i ;
      
      for (y=0; y<i; y++) 
	{
	  def_buf[y] = (char *) malloc (strlen(def_val[y]) + 1) ;
	  strcpy (def_buf[y], def_val[y]) ;
	}

      if (strlen (username))
	{
	  if (def_buf[S_USERNAME]) free (def_buf[S_USERNAME]) ;
	  def_buf[S_USERNAME] = (char *) malloc (strlen (username) + 1) ;
	  strcpy (def_buf[S_USERNAME], username) ;
	}

      if (strlen (password))
	{
	  if (def_buf[S_PASSWD]) free (def_buf[S_PASSWD]) ;
	  def_buf[S_PASSWD] = (char *) malloc (strlen (password) + 1) ;
	  strcpy (def_buf[S_PASSWD], password) ;
	}

      if (strlen (nfm_file))
	{
	  if (def_buf[S_NFMDEBUG]) free (def_buf[S_NFMDEBUG]) ;
	  def_buf[S_NFMDEBUG] = (char *) malloc (strlen (nfm_file) + 1) ;
	  strcpy (def_buf[S_NFMDEBUG], nfm_file) ;
	}

      if (strlen (env_name))
	{
	  if (def_buf[S_ENVIRONMENT]) free (def_buf[S_ENVIRONMENT]) ;
	  def_buf[S_ENVIRONMENT] = (char *) malloc (strlen (env_name) + 1) ;
	  strcpy (def_buf[S_ENVIRONMENT], env_name) ;
	}
/*
      if (strlen (activity))
	  {
		if (def_buf[S_ACTIVITY]) free (def_buf[S_ACTIVITY]) ;
		def_buf[S_ACTIVITY] = (char *) malloc (strlen (activity) + 1); 
		strcpy(def_buf[S_ACTIVITY], activity);
      }*/

      menu("I/NFM 3.0 CONVERTER",titles_new, def_buf, attrs, 
	   extra_char, &acq_data, other_titles) ;  
      
/************** INIT DEBUG *******************/
      strcpy (nfm_file, acq_data.data [S_NFMDEBUG]) ;
      strcpy (mem_file, acq_data.data [S_MEMDEBUG]) ;

      for (y=0; y<i; y++) if (def_buf[y]) free (def_buf[y]) ;
      if (def_buf) free (def_buf) ;
      
      strcpy (env_name, acq_data.data [S_ENVIRONMENT]) ;
      strcpy (username, acq_data.data [S_USERNAME]) ;
      strcpy (password, acq_data.data [S_PASSWD]) ;
      strcpy (activity, acq_data.data [S_ACTIVITY]);

      if ((strcmp (acq_data.data [S_ACTIVITY], "n") == 0) ||
	  (strcmp (acq_data.data [S_ACTIVITY], "N") == 0))
	  {
	    strcpy(activity, "n") ;
	  }
	  if ((strcmp (acq_data.data [S_ACTIVITY], "y") == 0) ||
	  (strcmp (acq_data.data [S_ACTIVITY], "Y") == 0))
	  {
		strcpy(activity, "y");
      }

      for (y=0; y<first_form; y++) if (acq_data.data[y]) free (acq_data.data[y]) ;
      if (acq_data.data) free (acq_data.data) ;
    }

  if (strlen (nfm_file))
    {
      _NFMdebug_st.NFMdebug_on = 1 ;
      strcpy (_NFMdebug_st.NFMdebug_file, nfm_file) ;
      _NFMdebug_st.SQLdebug_on = 1 ;
      strcpy (_NFMdebug_st.SQLdebug_file, nfm_file) ;
      printf ("debug enabled <%s> : <%s>\n",
	      _NFMdebug_st.NFMdebug_file,
	      _NFMdebug_st.SQLdebug_file) ;
    }
  if (strlen (mem_file)) 
    {
      _NFMdebug_st.MEMdebug_on = 1 ;
      strcpy (_NFMdebug_st.MEMdebug_file, mem_file) ;
    }

  /********* default schema *****************************************/
  strcpy (CVTglobal.env_name, env_name) ;
  strcpy (NFMglobal.environment_name, env_name) ;
  status = CVTget_schema_info (env_name, CVTglobal.schema_name, 
			       CVTglobal.schema_passwd) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Get schema <%s> for environment failed\n",
		  env_name)) ;
      ERRget_message (message) ;
      fprintf (stdout, "<%s>\n", message) ;
       exit (-1) ;
    }
  
  status = CVTdefault_schema (CVTglobal.schema_name, CVTglobal.schema_passwd) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Default schema <%s> for environment failed\n",
		  env_name)) ;
      ERRget_message (message) ;
      fprintf (stdout, "<%s>\n", message) ;
       exit (-1) ;
    }


/* set isolation dirty read for informix on_line ***************/

  status = NFMget_db_info(CVTglobal.schema_name);
  if (status != NFM_S_SUCCESS)
  {
	_NFMdebug ((fname, "Failure : Exec <%s> Set Isolation Dirty Read failed\n", "INFORMIX"));
	ERRget_message (message);
	fprintf(stdout, "<%s>\n", message);
	exit (-1);
  }

  status = CVTvalidate_administrator (username, password) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Not a administrator : status <0x%.8x>\n",
		  status)) ;
      CVTlogout (-1) ;
    }

  status = CVTcreate_cvtlog_tables ()  ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Not create cvtlog : status <0x%.8x>\n",
		  status)) ;
      CVTlogout (-1) ;
    }

/*********** mms - decided not to do this ***************
  status = CVTquery_cvtlog_entry ("nfmsyscat", c_status, &l_flag) ;
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : Query for cvtlog : status <0x%.8x>\n",
		  status)) ;
      CVTlogout (-1) ;
    }


  if (status == NFM_S_SUCCESS)
  {
    if (strcmp (c_status, "C") == 0)
      {
	_NFMdebug ((fname, "Failure : Converter finished and cleaned up was performed\n")) ;
	ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
			"Conversion was succesfully completed") ;
	CVTlogout (-1) ;
      }
  }
*************************/
  if (! take_defaults)
    {
      /*********    BLANK FORM TWO  ******************/
      
      /* copy default multidimensional array */
      for (i=0; def_val1[i] != NULL; i++) 
	{  
	  def_buf = (char **) malloc (i * sizeof (char *)) ;
	  memset (def_buf, NULL, i*sizeof (char *)) ;
	}
      
      second_form = i ;
      
      for (y=0; y<i; y++) 
	{
	  def_buf[y] = (char *) malloc (strlen(def_val1[y]) + 1) ;
	  strcpy (def_buf[y], def_val1[y]) ;
	}
      
      menu("SELECTION MENU",titles_new1, def_buf, attrs1, 
	   extra_char1, &acq_data1, other_titles1) ;  
      
      for (y=0; y<i; y++) if (def_buf[y]) free (def_buf[y]) ;
      if (def_buf) free (def_buf) ;
      
      for (y=0; y<second_form; y++) 
	NFMlower_case (acq_data1.data [y], acq_data1.data [y]) ;

      status = CVTresolve_date (take_defaults) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status <0x%.8x>\n",
		      status)) ;
	  CVTlogout (-1) ;
	}
      
 /************* SELECT CATALOGS TO CONVERT *********************/
      if (acq_data1.data [S_CATALOG][0] == 'y')
	{
	  strcpy (sql_str, "select n_catalogname from nfmcatalogs \
where n_catalogname != 'nfmsyscat' \
and n_catalogname NOT IN \
(select n_tablename from nfmconvertlog where n_cvtstatus = 'C')") ;

	  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
	  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	    {
	      _NFMdebug ((fname, "Failure : status = <0x%..8x>\n",
                          status)) ;
              CVTlogout (-1) ;
	    }

          no_selected = 0 ;
	  
	  if (status != SQL_I_NO_ROWS_FOUND)
	    {
	      status = MEMbuild_array (sql_buffer) ;
	      if (status != MEM_S_SUCCESS)
		{
		  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
                  CVTlogout (-1) ;
		}
	      
	      data = (char **) sql_buffer -> data_ptr ;
	      /* load into UNIT_INFO catalogs */
	      
	      tot_data = sql_buffer->rows * sql_buffer->columns ;
	      
	      catalogs.num_of_rows = sql_buffer->rows ;
	      catalogs.num_of_cols = sql_buffer->columns ;
	      /* allocate and initiate pointers */
	      catalogs.data = (char **) malloc(tot_data * sizeof(char *)) ;
	      if (catalogs.data == NULL) 
		{
		  MEMclose (&sql_buffer) ;
		  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
                  CVTlogout (-1) ;
		}
	      
	      memset (catalogs.data, NULL, (tot_data * sizeof(char *))) ;
	      /* store data */
	      for (i=0 ; i< tot_data; ++i) 
		{
		  _NFMdebug ((fname, "loading %s\n", data[i])) ;
		  catalogs.data[i]  =  (char *) malloc(strlen(data[i]) + 1) ;
		  if (catalogs.data[i] == NULL) 
		    {
		      MEMclose (&sql_buffer) ;
		      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
                      CVTlogout (-1) ;
		    }
		  strcpy (catalogs.data[i], data[i]) ;
		}
	      no_catalogs = sql_buffer->rows ;
	      MEMclose (&sql_buffer) ;
	      
	      memset (cat_selection, NULL, (no_catalogs * sizeof(int))) ;

	      i = 0 ;
	      while (i != no_catalogs)
		{
		  menu2 ("<Enter> to Select ; <PF1> to Accept ; <PF4> to Accept All; <PF3> to Cancel", catalogs, &cat_selection [0], 
			 &i, &flag) ;
		  if ((flag == -1) || (flag == 1))
		    {
		      /* cancel */
		      break ;
		    }
		}

	      no_selected = 0 ;
	      for (i=0; i<no_catalogs; i++)
		{
		  if (cat_selection [i] == 1)
		    {
		      ++no_selected ;
		      _NFMdebug ((fname, "catalog %s selected : position %d\n",
				  catalogs.data [i], i+1)) ;
		    }
		}
	    }
	}
      
      
/*************** CONVERSION STARTS **********************/
      systables_flag   = acq_data1.data [0][0] ;
      cat_flag         = acq_data1.data [1][0] ;
      wf_flag          = acq_data1.data [2][0] ;
      search_sort_flag = acq_data1.data [3][0] ;
      process_flag     = acq_data1.data [4][0] ;
      completion_flag  = acq_data1.data [5][0] ;
      
      for (y=0; y<second_form; y++) 
	if (acq_data1.data[y]) free (acq_data1.data[y]) ;
      if (acq_data1.data) free (acq_data1.data) ;
    }
  else
    {
/* take all defaults */
      /* get all catalogs */
      systables_flag   = 'y' ;
      cat_flag         = 'y' ;
      wf_flag          = 'y' ;
      search_sort_flag = 'y' ;
      process_flag = 'y' ;
      completion_flag = 'y' ;

      strcpy (sql_str, "select n_catalogname from nfmcatalogs \
where n_catalogname != 'nfmsyscat'") ;
      status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  _NFMdebug ((fname, "Failure : SQLquery <0x%.8x>\n",
		      status)) ;
          CVTlogout (-1) ;
	}

      no_selected = sql_buffer -> rows ;
      if (status != SQL_I_NO_ROWS_FOUND)
	{
	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              CVTlogout (-1) ;
	    }
	  
	  data = (char **) sql_buffer -> data_ptr ;
	  /* load into UNIT_INFO catalogs */
	  
	  tot_data = sql_buffer->rows * sql_buffer->columns ;
	  
	  catalogs.num_of_rows = sql_buffer->rows ;
	  catalogs.num_of_cols = sql_buffer->columns ;
	  /* allocate and initiate pointers */
	  catalogs.data = (char **) malloc(tot_data * sizeof(char *)) ;
	  if (catalogs.data == NULL) 
	    {
	      MEMclose (&sql_buffer) ;
	      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
              CVTlogout (-1) ;
	    }
	  
	  memset (catalogs.data, NULL, (tot_data * sizeof(char *))) ;
	  /* store data */
	  for (i=0 ; i< tot_data; ++i) 
	    {
	      _NFMdebug ((fname, "loading %s\n", data[i])) ;
	      catalogs.data[i]  =  (char *) malloc(strlen(data[i]) + 1) ;
	      if (catalogs.data[i] == NULL) 
		{
		  MEMclose (&sql_buffer) ;
		  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
                  CVTlogout (-1) ;
		}
	      strcpy (catalogs.data[i], data[i]) ;
	    }
	  no_catalogs = sql_buffer->rows ;
	  for (i=0; i<no_catalogs; i++) cat_selection [i] = 1 ;
	}
      MEMclose (&sql_buffer) ;

      status = CVTresolve_date (take_defaults) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : status <0x%.8x>\n",
		      status)) ;
	  CVTlogout (-1) ;
	}
    }

  exit_flag = 0 ;
  status = CVTinit_signal_handler () ;
  if (status != NFM_S_SUCCESS)
    {
      exit_flag = 1 ;
    }


  status = CVTprint_cvtlog () ;
  if (status != NFM_S_SUCCESS)
    {
      exit_flag = 1 ;
    }

  if ((systables_flag == 'y') && (! exit_flag)) 
    {
      status = CVTconvert_sys_tables (activity) ;
      if (status != NFM_S_SUCCESS)
	{
	  exit_flag = 1 ;
	}
      else ERRreset_struct () ;
       
    }
  if ((cat_flag == 'y') && (! exit_flag))
    {
      status = CVTconvert_catalogs (&catalogs, &cat_selection [0]) ;
      if (status != NFM_S_SUCCESS)
	{
	  exit_flag = 1 ;
	}
      else ERRreset_struct () ;
    }
  if ((wf_flag == 'y') && (! exit_flag))
    {
      status = CVTconvert_workflow () ;
      if (status != NFM_S_SUCCESS)
	{
	  exit_flag = 1 ;
	}
      else ERRreset_struct () ;
    }
  if ((search_sort_flag == 'y') && (! exit_flag))
    {
      status = CVTsearch_sort_files () ;
      if (status != NFM_S_SUCCESS)
	{
	  exit_flag = 1 ;
	}
      else ERRreset_struct () ;
    }

  if ((process_flag == 'y') && (! exit_flag))
    {
      status = CVTprocess_on_transition () ;
      if (status != NFM_S_SUCCESS)
	{
	  exit_flag = 1 ;
	}
      else ERRreset_struct () ;
    }

  if ((completion_flag == 'y') && (! exit_flag))
    {
      ERRreset_struct () ;
      status = CVTcompletion_check () ;
      if (status != NFM_S_SUCCESS)
	{
	  exit_flag = 1 ;
	}
      else ERRreset_struct () ;
    }

/****************  EXIT  ************************/

  CVTlogout (exit_flag) ;
/*  exit (0) ; */
}



long CVTlogout (exit_flag)
     long exit_flag ;
{
  char *fname = "CVTlogout" ;
  char  sql_str [1024] ;
  char  message [512] ;
  long  tmp_flag ;

  _NFMdebug ((fname, "ENTER : exit_flag <%d>\n", exit_flag)) ;

  CVTprint_cvtlog () ;
  CVTfree_date_link () ;

  tmp_flag = _NFMdebug_st.SQLdebug_on ;
  _NFMdebug_st.SQLdebug_on = 0 ;
  if (strlen (CVTglobal.schema_passwd))
      sprintf (sql_str, "CLOSE schema %s", CVTglobal.schema_name) ;
  else
      sprintf (sql_str, "CLOSE schema %s.%s", CVTglobal.schema_name, 
	       CVTglobal.schema_passwd) ;

  SQLstmt(sql_str) ;
  _NFMdebug_st.SQLdebug_on = tmp_flag ;
  ERRget_message (message) ;
  if (strlen (message))  fprintf (stdout, "<%s>\n", message) ;
  fprintf (stdout, "EXITING CONVERSION\n") ;
  _NFMdebug ((fname, "EXIT\n")) ;
  exit (exit_flag) ;
}


long CVTdate_ud_attrs(take_defaults)
     long take_defaults ;
{
  char *fname = "CVTdate_ud_attrs" ;
  long status, no_date_attrs, tot_data, no_catalogs, sel_date_attrs;
  int i, flag ;
  UNIT_INFO  date_unit, acq_data ;
  char  sql_str [1024], **data ;
  char  *dyn_str1, *f_dyn_str1, *dyn_str2 ;
  char  cat_nfm_dt [500], f_cat_nfm_dt [500], tmp_str [1024] ;
  int   date_selection [5000] ;
  MEMptr sql_buffer = NULL ;
  struct CVTattr_st *cell, *last_cell = NULL ;
/*
  static char *other_titles3[] ={"-----------------------------------", 
                                  "" ,
                                  "Control C - To Terminate Conversion now",
                                  "PF1       - To Resume Conversion now",
                                  "Backspace/Delete - To delete",
                                  NULL } ;
*/
  _NFMdebug ((fname, "ENTER\n")) ;
  sel_date_attrs = 0 ;
  strcpy (sql_str, "select n_catalogname from nfmcatalogs \
where n_catalogname != 'nfmsyscat'") ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : Failure : SQL query : status =<0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {

      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      
      data = (char **) sql_buffer -> data_ptr ;
      /* load into UNIT_INFO catalogs */
      
      no_catalogs = sql_buffer->rows ;
      
      dyn_str1 = (char *) malloc (no_catalogs * 30) ;
      if (dyn_str1 == NULL)
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure : Malloc\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}
      dyn_str1 [0] = 0 ;
      f_dyn_str1 = (char *) malloc (no_catalogs * 30) ;
      if (f_dyn_str1 == NULL)
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure : Malloc\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}
      f_dyn_str1 [0] = 0 ;

      
      for (i=0; i<no_catalogs; i++)
	{
	  if (i == 0)
	    sprintf (tmp_str, "'%s'", data [i]) ;
	  else
	    sprintf (tmp_str, ",'%s'", data [i]) ;
	  strcat (dyn_str1, tmp_str) ;
	  
	  if (i == 0)
	    sprintf (tmp_str, "'f_%s'", data [i]) ;
	  else
	    sprintf (tmp_str, ",'f_%s'", data [i]) ;
	  strcat (f_dyn_str1, tmp_str) ;
	}
      
      MEMclose (&sql_buffer) ;
      /* User defined date attribute */
      /* 
	1. find all user defined date attributes (ones that end in *date) and present to user
	2. Store in link if any, set pointer in CVTglobal, null terminate list
	*/

      strcpy (cat_nfm_dt, "'n_creationdate', 'n_updatedate'") ;
      strcpy (f_cat_nfm_dt, "'n_cidate', 'n_codate'") ;

      dyn_str2 = (char *) malloc (strlen (dyn_str1) + strlen (f_dyn_str1) + strlen (cat_nfm_dt) + strlen (f_cat_nfm_dt) + 512) ;

      if (dyn_str2 == NULL)
	{
	  free (dyn_str1) ;
	  free (f_dyn_str1) ;
	  _NFMdebug ((fname, "Failure : Malloc\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}
      dyn_str2 [0] = 0 ;

      _NFMdebug ((fname, "allocated %d\n",
		  strlen (dyn_str1) + strlen (f_dyn_str1) + strlen (cat_nfm_dt) + strlen (f_cat_nfm_dt) + 512)) ;

      sprintf (dyn_str2, "Select distinct(a.n_name) from nfmattributes a, nfmtables b where a.n_name like '%%date' and a.n_tableno = b.n_tableno and ((b.n_tablename in (%s) and a.n_name NOT in (%s)) or (b.n_tablename in (%s) and a.n_name NOT IN(%s)))",
	       dyn_str1, cat_nfm_dt, f_dyn_str1, f_cat_nfm_dt) ;

      _NFMdebug ((fname, "dyn_str2 <%s>\n", dyn_str2)) ;
      free (dyn_str1) ;
      free (f_dyn_str1) ;
      status = SQLquery (dyn_str2, &sql_buffer, MEM_SIZE) ;
      free (dyn_str2) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure :status = <0x%.8x>\n",status));
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}

      if (status != SQL_I_NO_ROWS_FOUND)
	{
	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&sql_buffer) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  
	  data = (char **) sql_buffer -> data_ptr ;
	  /* load into UNIT_INFO catalogs */
	  
	  tot_data = sql_buffer->rows * sql_buffer->columns ;
	  
	  date_unit.num_of_rows = sql_buffer->rows ;
	  date_unit.num_of_cols = sql_buffer->columns ;
	  /* allocate and initiate pointers */
	  date_unit.data = (char **) malloc(tot_data * sizeof(char *)) ;
	  if (date_unit.data == NULL) 
	    {
	      MEMclose (&sql_buffer) ;
	      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	      return (NFM_E_MALLOC) ;
	    }
	  
	  memset (date_unit.data, NULL, (tot_data * sizeof(char *))) ;
	  /* store data */
	  for (i=0 ; i< tot_data; ++i) 
	    {
	      _NFMdebug ((fname, "loading %s\n", data[i])) ;
	      date_unit.data[i]  =  (char *) malloc(strlen(data[i]) + 1) ;
	      if (date_unit.data[i] == NULL) 
		{
		  MEMclose (&sql_buffer) ;
		  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		  return (NFM_E_MEM) ;
		}
	      strcpy (date_unit.data[i], data[i]) ;
	    }
	  no_date_attrs = sql_buffer->rows ;
	  MEMclose (&sql_buffer) ;
	  
	  if (! take_defaults)
	    {
	      memset (date_selection, NULL, (no_date_attrs * sizeof(int))) ;
	      /* present to user */
	      i = 0 ;
	      while (i != no_date_attrs)
		{
		  menu2 ("<Enter> to Select ; <PF1> to Accept ; <PF4> to Accept All; <PF3> to Cancel", date_unit, &date_selection [0], 
			 &i, &flag) ;
		  if ((flag == -1) || (flag == 1))
		    {
		      /* cancel */
		      break ;
		    }
		}
	    }
	  else
	    {
	      for (i=0; i<no_date_attrs; i++) date_selection [i] = 1 ;
	    }

	  /* put in link list */
	  for (i=0; i<no_date_attrs ; i++)
	    {
	      if (date_selection [i] == 1)
		{
		  ++sel_date_attrs  ;
		  cell = (struct CVTattr_st *) calloc (1, sizeof (struct CVTattr_st)) ;
		  if (cell == NULL)
		    {
		      _NFMdebug ((fname, "Failure : Malloc\n")) ;
		      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
		      return (NFM_E_MALLOC) ;
		    }
		  strcpy(cell->attr_name, date_unit.data [i]) ;
		  _NFMdebug ((fname, "copying <%s>\n", cell->attr_name)) ;
		  cell->next_attr = NULL ;
		  if (CVTglobal.root_attr == NULL)
		    {
		      CVTglobal.root_attr = cell ;
		      last_cell = cell ;
		    }
		  else
		    {
		      last_cell->next_attr = cell ;
		      last_cell = cell ;
		    }
		}
	    }
	} /* list of %date attributes */
      
      /* get other options for user */
/*      last_cell points to the last cell */
/*      sel_date_attrs has the number of date attributes already selected */
      if (! take_defaults)
	{
	  acq_data.data = (char **) malloc (5000*sizeof(char *)) ;
	  _NFMdebug ((fname, "1\n")) ;
	  if (acq_data.data == NULL)
	    {
	      _NFMdebug ((fname, "Malloc Failed\n")) ;
	      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	      return (NFM_E_MALLOC) ;
	    }
	  memset (acq_data.data, NULL, 5000*sizeof(char *)) ;
	  acq_data.num_of_rows = 0 ;
	  menu3("**** Additional Date Attributes (up to 48) ****\n <ENTER/LF> Selects; <PF1>Accepts Form; <PF4>Deletes entry; <PF3>Restarts Form",
		&acq_data) ;
	  /* append to link list */
	  for (i=0; i<acq_data.num_of_rows; i++)
	    {
	      ++sel_date_attrs  ;
	      cell = (struct CVTattr_st *) calloc (1, sizeof (struct CVTattr_st)) ;
	      if (cell == NULL)
		{
		  _NFMdebug ((fname, "Failure : Malloc\n")) ;
		  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
		  return (NFM_E_MALLOC) ;
		}
	      strcpy(cell->attr_name, acq_data.data [i]) ;
	      if (acq_data.data != NULL) free (acq_data.data [i]) ;
	      _NFMdebug ((fname, "copying <%s>\n", cell->attr_name)) ;
	      cell->next_attr = NULL ;
	      if (CVTglobal.root_attr == NULL)
		{
		  CVTglobal.root_attr = cell ;
		  last_cell = cell ;
		}
	      else
		{
		  last_cell->next_attr = cell ;
		  last_cell = cell ;
		}
	    }
	  if (acq_data.data != NULL) free(acq_data.data) ;
	} /* list of catalogs */
    }
  CVTglobal.num_of_attr = sel_date_attrs ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


int CVTprint_date_link ()
{
  char *fname = "CVTprint_date_link" ;
  struct CVTattr_st *cell = NULL ;

  _NFMdebug ((fname, "ENTER\n")) ;
  if (CVTglobal.num_of_attr == 0)
    {
      _NFMdebug ((fname, "No date attributes\n")) ;
      return (NFM_S_SUCCESS) ;
    }
  cell = CVTglobal.root_attr ;
  while (cell != NULL)
    {
      _NFMdebug ((fname, "%s\n", cell->attr_name)) ;
      cell = cell->next_attr ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

int CVTfree_date_link ()
{
  char *fname = "CVTfree_date_link" ;
  struct CVTattr_st *cell = NULL, *prev_cell = NULL ;

  _NFMdebug ((fname, "ENTER\n")) ;
  if (CVTglobal.num_of_attr == 0)
    {
      _NFMdebug ((fname, "No date attributes\n")) ;
      return (NFM_S_SUCCESS) ;
    }

  cell = CVTglobal.root_attr ;
  while (cell != NULL)
    {
      _NFMdebug ((fname, "%s\n", cell->attr_name)) ;
      prev_cell = cell ;
      cell = cell->next_attr ;
      free (prev_cell) ;
      
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long CVTdate_timestamp ()
{
  char *fname = "CVTdate_timestamp" ;
  long status, no_catalogs ;
  int i ;
  char  sql_str [1024], **data ;
  char  *dyn_str1, *f_dyn_str1, *dyn_str2 ;
  char  cat_nfm_dt [500], f_cat_nfm_dt [500], tmp_str [1024] ;
  MEMptr sql_buffer = NULL ;
  struct CVTattr_st *cell, *last_cell = NULL ;

 _NFMdebug ((fname, "ENTER\n")) ;

  strcpy (sql_str, "select n_catalogname from nfmcatalogs \
where n_catalogname != 'nfmsyscat'") ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : Failure : SQL query : status =<0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status != SQL_I_NO_ROWS_FOUND)
    {
      status = MEMbuild_array (sql_buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      
      data = (char **) sql_buffer -> data_ptr ;
      /* load into UNIT_INFO catalogs */
      
      no_catalogs = sql_buffer->rows ;
      
      dyn_str1 = (char *) malloc (no_catalogs * 30) ;
      if (dyn_str1 == NULL)
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure : Malloc\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}
      dyn_str1 [0] = 0 ;
      f_dyn_str1 = (char *) malloc (no_catalogs * 30) ;
      if (f_dyn_str1 == NULL)
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure : Malloc\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}
      f_dyn_str1 [0] = 0 ;
      
      for (i=0; i<no_catalogs; i++)
	{
	  if (i == 0)
	    sprintf (tmp_str, "'%s'", data [i]) ;
	  else
	    sprintf (tmp_str, ",'%s'", data [i]) ;
	  strcat (dyn_str1, tmp_str) ;
	  
	  if (i == 0)
	    sprintf (tmp_str, "'f_%s'", data [i]) ;
	  else
	    sprintf (tmp_str, ",'f_%s'", data [i]) ;
	  strcat (f_dyn_str1, tmp_str) ;
	}
      
      MEMclose (&sql_buffer) ;
      /* User defined date attribute */
      /* 
	1. find all user defined date attributes (ones that end in *date) and present to user
	2. Store in link if any, set pointer in CVTglobal, null terminate list
	*/
      strcpy (cat_nfm_dt, "'n_creationdate', 'n_updatedate'") ;
      strcpy (f_cat_nfm_dt, "'n_cidate', 'n_codate'") ;

      dyn_str2 = (char *) malloc (strlen (dyn_str1) + strlen (f_dyn_str1) + strlen(cat_nfm_dt) + strlen (f_cat_nfm_dt) + 512) ;

      if (dyn_str2 == NULL)
	{
	  free (dyn_str1) ;
	  free (f_dyn_str1) ;
	  _NFMdebug ((fname, "Failure : Malloc\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}
      dyn_str2 [0] = 0 ;

      _NFMdebug ((fname, "allocated %d\n",
		  strlen (dyn_str1) + strlen (f_dyn_str1) + strlen(cat_nfm_dt) + strlen (f_cat_nfm_dt) + 512)) ;
		  

      sprintf (dyn_str2, "Select distinct(a.n_name) from nfmattributes a, nfmtables b where a.n_datatype = 'timestamp' and a.n_tableno = b.n_tableno and ((b.n_tablename in (%s) and a.n_name NOT in (%s)) or (b.n_tablename in (%s) and a.n_name NOT IN(%s)))",
	       dyn_str1, cat_nfm_dt, f_dyn_str1, f_cat_nfm_dt) ;

      free (dyn_str1) ;
      free (f_dyn_str1) ;
      status = SQLquery (dyn_str2, &sql_buffer, MEM_SIZE) ;
      free (dyn_str2) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "Failure :status = <0x%.8x>\n",status));
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}

      if (status != SQL_I_NO_ROWS_FOUND)
	{
	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&sql_buffer) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  
	  data = (char **) sql_buffer -> data_ptr ;
	  /* load into UNIT_INFO catalogs */

	  /* put in link list */
	  for (i=0; i<sql_buffer->rows ; i++)
	    {
	      cell = (struct CVTattr_st *) calloc (1, sizeof (struct CVTattr_st)) ;
	      if (cell == NULL)
		{
		  MEMclose (&sql_buffer) ;
		  _NFMdebug ((fname, "Failure : Malloc\n")) ;
		  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
		  return (NFM_E_MALLOC) ;
		}
	      strcpy(cell->attr_name, data [i]) ;
	      cell->next_attr = NULL ;
	      if (CVTglobal.root_attr == NULL)
		{
		  CVTglobal.root_attr = cell ;
		  last_cell = cell ;
		}
	      else
		{
		  last_cell->next_attr = cell ;
		  last_cell = cell ;
		}
	    }
	  CVTglobal.num_of_attr = sql_buffer->rows ;
	}
      MEMclose (&sql_buffer) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long CVTresolve_date (take_defaults)
     long take_defaults ;
{
  char *fname = "CVTresolve_date" ;
  long status, l_flag ;
  char c_status [10] ;

  /* if nfmattributes status != 'N' or 'M' or 'C' */
  status = CVTquery_cvtlog_entry ("nfmattributes", c_status, &l_flag) ;
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "Failure : Query for cvtlog : status <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  /* if it returns rows -> check for status = 'C' or 'M' */
  if (status == NFM_S_SUCCESS)
    {
      if ((strcmp (c_status, "C") == 0) ||
	  (strcmp (c_status, "M") == 0))
	{
	  /* build link list from timestamp in nfmattributes table */
	  status = CVTdate_timestamp() ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : Date User Defined attributes : status = <0x%.8x>\n", 
			  status)) ;
	      return(status) ;
	    }
	}
    }
  else
    {
      status = CVTdate_ud_attrs (take_defaults) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : Date User Defined attributes : status = <0x%.8x>\n", 
		      status)) ;
	  return(status) ;
	}
    }
  
  CVTprint_date_link () ;
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


