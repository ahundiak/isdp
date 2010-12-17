#include "machine.h"
#include "curses.h"
#ifdef strchr
#undef strchr
#endif
#include "CVT.h"

  FILE *CVTconsole ;
  extern struct CVTglobal_st CVTglobal ;
  extern struct termio fdoriginal ;
  extern int    fd1 ;
  char msg [512] ;
  extern char *optarg ;

long _CVTget_next_slot (nfmtablename, column_name, index_no)
     char *nfmtablename ;
     char *column_name ;
     long *index_no ;
{
  char *fname = "_CVTget_next_slot" ;
  long status ;
  MEMptr buffer = NULL ;
  char **data ;
  char sql_str [1024] ;

  _NFMdebug ((fname, "tablename %s\n", nfmtablename)) ;
  sprintf (sql_str, "select max(%s) from %s",
	   column_name, nfmtablename) ;
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


long CVTansi_to_timestamp (source, dest)
     char *source, *dest ;
{
  char *fname = "CVTansi_to_timestamp" ;
  char *ptr ;
  char new_year [10], day [10], month [10] ;
  long status ;
  long CVTcheck_for_ansi () ;

  _NFMdebug ((fname, "Old date %s\n", source)) ;
  /* year */
  ptr = (char *) strrchr (source, '/') ;
  if (ptr == NULL) 
    {
      status = CVTcheck_for_ansi (source) ;
      if (status == NFM_S_SUCCESS)
	{
	  strcpy (dest, source) ;
	  return (NFM_S_SUCCESS) ;
	}
      sprintf (msg, "Unknown date data for %s",
	       source) ;
      _NFMdebug ((fname, "%s\n", msg));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg) ;
      return (NFM_E_MESSAGE) ;
    }

  *ptr = 0 ;
  ++ptr ;
  if (strlen (ptr) == 2)
    sprintf (new_year, "19%s", ptr) ;
  else if (strlen (ptr) == 4)
    sprintf (new_year, ptr) ;

  /* day */
  ptr = (char *) strrchr (source, '/') ;
  if (ptr == NULL) 
    {
      sprintf (msg, "Unknown date data for %s",
	       source) ;
      sprintf (msg, "String Search of / in %s Failed",
	       source) ;
      _NFMdebug ((fname, "%s\n", msg));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg) ;
      return (NFM_E_MESSAGE) ;
    }

  *ptr = 0 ;
  ++ ptr ;
  strcpy (day, ptr) ;
  
  /* month */
  strcpy (month, source) ;

  sprintf (dest, "%.4s.%.2s.%.2s",
	   new_year, month, day) ;

  _NFMdebug ((fname, "new date %s\n", dest)) ;

  return (NFM_S_SUCCESS) ;
}


long CVTamerican_to_timestamp(source, dest)
     char *source, *dest ;
{
  char *fname = "CVTamerican_to_timestamp" ;
  char *ptr ;
  char new_year [10], day [10], month [10] ;

  _NFMdebug ((fname, "Old date %s\n", source)) ;
  /* day */
  ptr = (char *) strrchr (source, '.') ;
  if (ptr == NULL) 
    {
      sprintf (msg, "String Search of . in %s Failed",
	       source) ;
      _NFMdebug ((fname, "%s\n", msg));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg) ;
      return (NFM_E_MESSAGE) ;
    }

  *ptr = 0 ;
  ++ptr ;
  sprintf (day, ptr) ;

  /* month */
  ptr = (char *) strrchr (source, '.') ;
  if (ptr == NULL) 
    {
      sprintf (msg, "String Search of . in %s Failed",
	       source) ;
      _NFMdebug ((fname, "%s\n", msg));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg) ;
      return (NFM_E_MESSAGE) ;
    }
  *ptr = 0 ;
  ++ ptr ;
  strcpy (month, ptr) ;
  
  /* year  */
  strcpy (new_year, &source [2]) ;

  sprintf (dest, "%.2s/%.2s/%.2s",
	   month, day, new_year) ;

  _NFMdebug ((fname, "new date %s\n", dest)) ;

  return (NFM_S_SUCCESS) ;
}

long CVTcheck_for_ansi (source) 
     char *source ;
{
  char *fname = "CVTcheck_for_ansi" ;

  if (strlen (source) != 10)
    {
      sprintf (msg, "Not in Ansi Format %s\n", source) ;
      _NFMdebug ((fname, "%s\n", msg));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg) ;
      return (NFM_E_MESSAGE) ;
    }

  if ((source [4] != '.') && (source [7] != '.'))
    {
      sprintf (msg, "Not in Ansi Format %s\n", source) ;
      _NFMdebug ((fname, "%s\n", msg));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", msg) ;
      return (NFM_E_MESSAGE) ;
    }

  return (NFM_S_SUCCESS) ;
}

/**********************************************************************
 *                    WINDOW                                          *
 **********************************************************************/
#define X_OFFSET 38
#define Y_OFFSET 4
#define MAX_X    30
#define LF       0xa 
#define PF1      0411
#define PF3      0413 
#define PF4      0414
#define BS       0x8
#define DEL      0177
#define UP_ARROW 0403
#define DW_ARROW 0402
#define ECHO_S   0
#define NOECHO   1

menu(main_title, titles, def_val, attr, extra_char, data, o_titles)
     char *main_title ;
     char *titles[] ;
     char *def_val[] ;
     short *attr ;
     char *extra_char[] ;
     UNIT_INFO *data ;
     char *o_titles[] ;
{
  int i, y, x, index_s, offset, keystroke ;
  unsigned short ch ; 
  char temp[50] ;
  static char blank_line[31] = "                               " ;
  char *chr_ptr, *strchr() ;

  initscr() ;
  clear() ;
  noecho() ;
  keypad (stdscr, 1) ;

/* display titles */
  mvaddstr(2,25, main_title) ;

  for(i=0,y=18,x=20; o_titles[i] != NULL ; i++) mvaddstr(y+i,x, o_titles[i]) ; 

  /* display titles */
  for (i=0, y=4; titles[i] != NULL ; i++, y++) {
    mvaddstr (y,10, titles[i]) ; 
    mvaddstr (y, 37, "[") ; 
    mvaddstr(y, 37 + MAX_X + 5, "]") ;
  }
  refresh () ;

/* get title position */
  data->num_of_rows  = i ;   

/* init strings to NULLS */
  data->data = (char **) malloc(data->num_of_rows * sizeof(char *)) ;
  if (data->data == NULL)
    {
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  memset (data->data,NULL,data->num_of_rows* sizeof(char *)) ;

  for (i=0; i<data->num_of_rows; i++) {
    if (strlen(def_val[i]) != 0) {
      data->data[i] = (char *) malloc (strlen(def_val[i])+1) ;
      strcpy (data->data[i], def_val[i]) ;
      if (attr[i] == ECHO_S) mvaddstr (i+Y_OFFSET,X_OFFSET,data->data[i]) ;
    }
    else {
      data->data[i] = (char *) malloc (strlen("") + 1 ) ;
      strcpy (data->data[i], "") ;
    }
  }


/* go to home position */
  y = 0 ;
  strcpy (temp, data->data[y]) ;
  x = strlen(data->data[y]) ;
  move (y+Y_OFFSET,x+X_OFFSET) ;
  keystroke = 0 ;
  do {
    ch = getch() ; 
    switch (ch)
      {
    /* LF go to next field store field */
    case LF :  
    case DW_ARROW :
               /* store temp into y location */
               if (data->data[y] != NULL) free (data->data[y]) ;
               data->data[y] = (char *) malloc (strlen(temp) + 1) ;
	       strcpy (data->data[y], temp) ;          

               /* move to next row */
               if (++y == data->num_of_rows) y = 0 ;
               /* get next position */
               temp[0] = '\0';
               if (data->data[y] != NULL) {
                   strcpy (temp, data->data[y]) ;
                    x = strlen (temp) ;
		  }
               else x = 0 ;
/* for debug */               
/*               mvaddstr (22,10,"               ") ;
               mvaddstr (22,10, temp) ;  
*/
               if (attr[y] == ECHO_S) mvaddstr (y+Y_OFFSET, X_OFFSET, temp) ;
                             else move (y+Y_OFFSET, X_OFFSET) ;
               keystroke = 0 ;
               refresh() ;
               break ;
     
     case UP_ARROW :
               /* store temp into y location */
               if (data->data[y] != NULL) free (data->data[y]) ;
               data->data[y] = (char *) malloc (strlen(temp) + 1) ;
	       strcpy (data->data[y], temp) ;          

               /* move to previous row */
               if (--y == -1) y = data->num_of_rows-1 ;
               /* get next position */
               temp[0] = '\0';
               if (data->data[y] != NULL) {
                   strcpy (temp, data->data[y]) ;
                    x = strlen (temp) ;
		  }
               else x = 0 ;
/* for debug */               
/*               mvaddstr (22,10,"               ") ;
               mvaddstr (22,10, temp) ;  
*/
               if (attr[y] == ECHO_S) mvaddstr (y+Y_OFFSET, X_OFFSET, temp) ;
                             else move (y+Y_OFFSET, X_OFFSET) ;
               keystroke = 0 ;
               refresh() ;
               break ;

     case BS :  
     case DEL :     

      if (x==0) {
                 beep() ;
	       }
               else {
                 offset = strlen(temp) ;
                 if (offset != 0) temp[offset-1] = '\0' ;
                 --x ;
                 if (attr[y] == ECHO_S) {
                    mvaddstr(y+Y_OFFSET, X_OFFSET,blank_line) ;
	            mvaddstr (y+Y_OFFSET, X_OFFSET, temp) ;
                    move (y+Y_OFFSET, x+X_OFFSET) ;
		  }
	       }
               refresh() ;
               break ;
    case PF3 : 
    case PF1 :
               break ;

    default :  
               chr_ptr = (char *) strchr (extra_char [y], (int) ch) ;  
               if ((isalnum(ch)) || (chr_ptr != NULL))
		 {
                 if ((!keystroke) && (attr[y] == NOECHO)) {
		   temp[0] = '\0' ;
                   x=0 ;
                   keystroke = 1 ;
		 }
                 index_s = strlen(temp) ;
                 if (x != MAX_X) {
		   temp[index_s] = ch ;
                   temp[index_s+1] = '\0' ;
                   ++x ;
		 } else temp[index_s-1] = ch ;

                 if (attr[y] == ECHO_S) {
                     mvaddstr(y+Y_OFFSET, X_OFFSET, blank_line) ;
                     mvaddstr(y+Y_OFFSET, X_OFFSET, temp) ;
                     move (y+Y_OFFSET, x+X_OFFSET) ;
		   }
                 refresh() ;
                 break ;
	       }
               else beep() ;
               refresh() ;
	     }

  }while (ch != PF1 && ch != PF3) ;
  clear() ; 
  refresh() ;
  endwin() ;
}


menu3(main_title, data) 
     char *main_title ;
     UNIT_INFO *data ;
{
  int i, y, x, index_s, offset, keystroke ;
  unsigned short ch ; 
  char temp[50] ;
  static char blank_line[31] = "                               " ;
  char *chr_ptr, *strchr() ;
  long x1, z ;

  initscr() ;
  clear() ;
  noecho() ;
  keypad (stdscr, 1) ;

/* display titles */
  mvaddstr(2,10, main_title) ;
  refresh () ;

  /* display box */
  mvaddstr (20, 10, "[") ; 
  mvaddstr(20, 10 + MAX_X + 5, "]") ;
  refresh () ;
  x = 0 ;
  /* go to home position */
  move (20,11) ;
  keystroke = 0 ;
  do 
    {
      ch = getch() ; 
      switch (ch)
	{
	  /* LF go to next field store field */
	case LF :  
	case KEY_ENTER :
	  /* store temp into y location */
/* no more than 48 date stuff attributes */
	  if (data->num_of_rows == 48) break ;
	  for (i=0; i<data->num_of_rows; i++)
	    {
	      if (strcmp (temp, data->data[i]) == 0) break ;
	    }
	  if (i == data->num_of_rows)
	    {
	      y = data->num_of_rows ;
	      if (data->data[y] != NULL) free (data->data[y]) ;
	      data->data[y] = (char *) malloc (strlen(temp) + 1) ;
	      if (data->data[y]== NULL)
		{
		  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
		  return(NFM_E_MALLOC) ;
		}
	      strcpy (data->data[y], temp) ;          
	      ++data->num_of_rows ;
	    }
	  /* get next position */
	  x = 0 ;
	  temp[0] = '\0';
	  mvaddstr (20, 11, blank_line) ;
	  /* list of things in list */
	  x1 = 2;
	  z = 0 ;
	  for (i=0;  i<data->num_of_rows; i++, z++) 
	    {
	      if (z == 16) 
		{
		  z = 0 ;
		  x1 += 25 ;
		}
	      mvaddstr (z+4, x1, "                    ") ;
	      mvaddstr (z+4,x1,data->data[i]) ;
	    }

	  move (20,11) ;
	  keystroke = 0 ;
	  refresh() ;
	  break ;

	case PF4:
	  /* store temp into y location */

	  for (i=0; i<data->num_of_rows; i++)
	    {
	      if (strcmp (temp, data->data[i]) == 0) break ;
	    }
	  /* delete from list */
	  if (i != data->num_of_rows)
	    {
	      y = data->num_of_rows - 1 ;
	      if (data->data[i] != NULL) free (data->data[i]) ;
	      /* move last entry to this slot */
	      data->data[i] = (char *) malloc (strlen(data->data[y]) + 1) ;
	      if (data->data[i]== NULL)
		{
		  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
		  return(NFM_E_MALLOC) ;
		}
	      strcpy (data->data[i], data->data[y]) ;
	      if (data->data[y] != NULL) free (data->data[y]) ;
	      --data->num_of_rows ;
	    }
	  /* get next position */
	  x = 0 ;
	  temp[0] = '\0';
	  mvaddstr (20, 11, blank_line) ;
	  /* list of things in list */
	  x1 = 2;
	  z = 0 ;
	  for (i=0;  i<data->num_of_rows; i++, z++) 
	    {
	      if (z == 16) 
		{
		  z = 0 ;
		  x1 += 25 ;
		}
	      mvaddstr (z+4, x1, "                    ") ;
	      mvaddstr (z+4,x1,data->data[i]) ;
	    }
/* one more to clear */
	  if (z == 16) 
	    {
	      z = 0 ;
	      x1 += 25 ;
	    }
	  mvaddstr (z+4, x1, "                    ") ;
	  move (20,11) ;
	  keystroke = 0 ;
	  refresh() ;
	  break ;

	  
	case BS :  
	case DEL :     
	  if (x==0) 
	    {
	      beep() ;
	    }
	  else 
	    {
	      offset = strlen(temp) ;
	      if (offset != 0) temp[offset-1] = '\0' ;
	      --x ;
	      mvaddstr(20, 11,blank_line) ;
	      mvaddstr (20, 11, temp) ;
	      move (20, 11) ;
	    }
	  refresh() ;
	  break ;
	  
	case PF3 : 
	  z = 0;
	  x1 = 2 ;
	  for (i=0; i<data->num_of_rows+1; i++, z++)
	    {
	      if (z == 16) 
		{
		  z = 0 ;
		  x1 += 25 ;
		}
	      mvaddstr (z+4, x1, "                    ") ;
	      if (data->data[i] != NULL) free (data->data[i]) ;
	    }
	  data->num_of_rows = 0 ;
	  x = 0 ;
	  temp[0] = '\0';
	  mvaddstr (20, 11, blank_line) ;
	  keystroke = 0 ;
	  refresh() ;
	  break ;

	case PF1 :
	  break ;
	  
	  default :  
	    chr_ptr = (char *) strchr ("_", (int) ch) ;  
	  if ((isalnum(ch)) || (chr_ptr != NULL))
	    {
	      if (!keystroke)
		{
		  temp[0] = '\0' ;
		  x=0 ;
		  keystroke = 1 ;
		}
	      index_s = strlen(temp) ;
	      if (x != MAX_X) 
		{
		  temp[index_s] = ch ;
		  temp[index_s+1] = '\0' ;
		  ++x ;
		} 
	      else temp[index_s-1] = ch ;
	      
	      mvaddstr(20, 11, blank_line) ;
	      mvaddstr(20, 11, temp) ;
	      move (20, 11) ;
	      refresh() ;
	      break ;
	    }
	  else beep() ;
	  refresh() ;
	}
      
    }while (ch != PF1) ;

  clear() ; 
  refresh() ;
  endwin() ;
  return (NFM_S_SUCCESS) ;
}



long confirmation ()
{
  unsigned short ch ; 
  long return_status ;

  initscr() ;
  clear() ;
  noecho() ;
  keypad (stdscr, 1) ;

/* display titles */
  mvaddstr(2,10, "Are you sure you want to do the cleanup?  ") ;
  ch = getch() ; 
  switch (ch) ;
  return_status = NFM_E_FAILURE ;
  if ((ch == 'Y') || (ch == 'y'))
    {
      return_status = NFM_S_SUCCESS ;
    }
   
  clear() ; 
  refresh() ;
  endwin() ;
  return (return_status) ;
}

/***********
int set_new () 
{
  struct termio new ;

  if (ioctl (fd1, TCGETA, &fdoriginal) < 0)
    return (NFM_E_FAILURE) ;
  new = fdoriginal ;

*/ /* wait for one character or timer off, whichever is first *//*
  new.c_cc [VMIN] = 0 ;
  new.c_cc [VTIME] = 1 ;  */ /* 0.1 seconds interval */ /*
  
*/  /* enable echo */ /*
  new.c_lflag = 0 ;

  if (ioctl(fd1, TCSETA, &new) < 0)
    return (NFM_E_FAILURE) ;
  return (NFM_S_SUCCESS) ;
}


int set_old ()
{
  if (ioctl (fd1, TCFLSH, 0) < 0) 
    {
      fprintf(stderr, "error tcflsh %d  fd1 %d\n", errno,fd1) ;
    }
  
  if (ioctl (fd1, TCSETA, &fdoriginal) < 0)
    {
      fprintf(stderr, "error tcseta is %ld\n", errno) ;
      return (NFM_E_FAILURE) ;
    }

  return (NFM_S_SUCCESS) ;
}
**************************************/

long get_terminal_name (str) 
     char *str ; /* output-null terminated path name of the terminal device */
{
  char *ptr ;
  int   i ;

  ptr = (char *) ttyname (0) ;

  if (ptr == NULL) return (NFM_E_FAILURE) ;
  else  for (i=0; *ptr !=0; i++, ptr++) str[i] = *ptr ;

  str[i] = 0 ;

  return (NFM_S_SUCCESS) ;
}

void heading()
  {
  _NFMprint_copyright ("3.0 Converter") ;
  sleep (3);
}

long CVTget_schema_info (env_name, schema_name, schema_passwd)
     char    *env_name;
     char    *schema_name;
     char    *schema_passwd ;
{
  static char *fname = "CVTget_schema_info" ;
  long      status ;
  char      sql_str[200], *clh_status, *clh_vbyop ();
  char      sch_name   [100], d_sch_name   [100];
  char      sch_pwd    [100], d_sch_pwd    [100];
  char      temp_str   [100] ;
  char      env_file [15] ;
  
  _NFMdebug ((fname, "Environment Name = <%s>\n", env_name)) ;
  
  /* look up the node_name of the server */
  
  sprintf (env_file, "nfme_%s", env_name) ;
  clh_status = clh_vbyop (env_file, "NETPROP20", sch_name, 25);
  if (clh_status)
    {
      ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
      ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
		      "nfm schema name", env_file) ;
      _NFMdebug ((fname, "Get Schema Name : status = <0x%.8x>\n",
		  NFM_E_CLH));
      return (NFM_E_CLH);
    }

     sprintf (temp_str, "%*.*s", 25, 25, sch_name);

     /* Store the encrypted schema name in a global variable. */

     status = NFMdecrypt (temp_str, d_sch_name);
     if (status != NFM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname, "Decrypy Schema Name : status = <0x%.8x>\n",
		    status));
        return (status) ;
      }

     strcpy (schema_name, d_sch_name) ;

     clh_status = clh_vbyop (env_file, "NETPROP21", sch_pwd, 25);
     if (clh_status)
      {
	ERRload_struct (NETS, NET_E_MESSAGE, "%s", clh_status) ;
        ERRload_struct (NFM, NFM_E_CLH, "%s%s", 
				 "nfm schema password", env_file) ;
        _NFMdebug ((fname, "Get Schema Pwd : status = <0x%.8x>\n",
		  NFM_E_CLH));
        return (NFM_E_CLH);
      }

     sprintf (temp_str, "%*.*s", 25, 25, sch_pwd);

     /* Store the encrypted schema passwd in a global variable.  */

     status = NFMdecrypt (temp_str, d_sch_pwd);
     if (status != NFM_S_SUCCESS)
      {
        ERRload_struct (NFM, NFM_E_NET, "", NULL);
        _NFMdebug ((fname, "Decrypt Schema Password : status = <0x%.8x>\n",
		    status));
        return (status);
      }
     strcpy (schema_passwd, d_sch_pwd) ;

     _NFMdebug ((fname, "Executing SET DATABASE ENABLE statement\n")) ;
     sprintf (sql_str, "SET DATABASE ENABLE ONLY INFORMIX, ORACLE, INGRES, DB2");
     status = SQLexec_imm (sql_str);
     if (status != SQL_S_SUCCESS)
       {
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFMdebug ((fname, "SET DATABASE ENABLE : status = <0x%.8x>\n",
                    status));
        return (NFM_E_SQL_STMT);
      }

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
  }


long CVTdefault_schema (schema_name, schema_passwd)
     char *schema_name, *schema_passwd ;
{
  char *fname = "CVTdefault_schema" ;
  char sql_str [1024] ;
  long tmp_flag, status ;

  sql_str [0] = 0;
  
  _NFMdebug ((fname, "Executing default schema statement\n")) ;
  tmp_flag = _NFMdebug_st.SQLdebug_on ;  
  _NFMdebug_st.SQLdebug_on = 0 ;  
  if (! strlen (schema_passwd))
    sprintf (sql_str, "DEFAULT SCHEMA %s", schema_passwd) ;
  else
    sprintf (sql_str, "DEFAULT SCHEMA %s.%s", schema_name, schema_passwd) ;
  
  status = SQLexec_imm (sql_str);
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug_st.SQLdebug_on = tmp_flag ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFMdebug ((fname, "Default Schema : status = <0x%.8x>\n",
		  status));
      return (NFM_E_SQL_STMT);
    }
  status =  CVTget_db_type () ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : get db type : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug_st.SQLdebug_on = tmp_flag ;  
  return (NFM_S_SUCCESS) ;
}



  int row[5000] ;
  int col[5000] ;

/* #define MAX_PER_PAGE 75 */
#define MAX_PER_PAGE 60

menu2 (title, list, sel, start, flag)
char *title ;
UNIT_INFO list ;
int  sel[] ;
int  *start ;
int  *flag ;   /* 0- accept user selection ; -1 - no selection ; 1 - all selected */
{
int selection, i ;
/* chtype	ch; */
unsigned long ch ;
int no_titles ;
int selec, min ;

    initscr() ;
    clear() ;
    noecho () ;
    keypad (stdscr, 1) ;

    selec = *start ;
    min = *start ;

    display_menu2 (title, list, &no_titles, start) ;

    for (i=0; i<no_titles; i++) sel[i+selec] = 0 ;

    while (1) 
      {
	ch = getch ();
	selection = get_input2 (ch, list.data, no_titles, &selec, 
				&sel[0], min, flag) ;
        if (selection == -2) 
	  {
	    if (*flag == 1)
	      {
		/* all selected */
		for (i=0; i<list.num_of_rows; i++) sel [i] = 1 ;
	      }
	    else if (*flag == -1)
	      {
		/* none selected */
		for (i=0; i<list.num_of_rows; i++) sel [i] = 0 ;
	      }
	    break ;
	  }
      }
    clear () ;
    refresh () ;
    addch(LF) ;
    endwin() ;
}

display_menu2 (title, functions, no_titles, start) 
char *title ;
UNIT_INFO functions ;
int *no_titles ;
int *start ;
{
int i ;
int rows, columns ;
int MAX_ROW, MAX_COL ;
int no ;

        clear () ;
/* center title */
	mvaddstr (1, 40 - (strlen (title) / 2), title);

/* build the row array and column array */

/* get number of titles */

     if ((functions.num_of_rows - *start) <= MAX_PER_PAGE)
       no = functions.num_of_rows - *start ;
     else
       no = MAX_PER_PAGE;


/* calculate max */
         MAX_COL = 18 ;
          if (no< 10)  MAX_ROW = 2 ;
       else if (no<20) MAX_ROW = 4 ;
       else if (no<30) MAX_ROW = 6 ;
       else if (no<40) MAX_ROW = 8 ;
       else MAX_ROW = 15 ;

/* calculate the columns size */

       for (i=0, rows=5, columns = 0; i<no ; ++i)  
	 {
           if (rows == MAX_ROW+5) 
	     {
	       rows = 5 ;
	       columns +=  MAX_COL ;
	     }
           row[i + *start] = rows++ ;
           col[i + *start] = columns ;
	 }

       *no_titles = no ;

/* put in reverse video first entry */
        attron (A_REVERSE);
	mvaddstr (row[*start], col[*start], functions.data[*start]);
	attroff (A_REVERSE);

/* write all entries */
	for (i = 0 ; i < *no_titles ; ++i) 
            mvaddstr (row[i+*start], col[i+*start], functions.data[i+*start]);

        *start = *start +no ;
        refresh () ;
 }



get_input2 (ch, functions, no_titles, selec, sel, min, flag)
/* chtype	ch; */
unsigned long ch ;
char *functions[] ;
int no_titles ;
int *selec ;
int *sel ;
int min ;
int *flag ;
{
int selection ;

        *flag = 0 ;
        selection = *selec ;
	if (ch) {
		switch (ch) {
			case KEY_UP:
                                if (sel[selection]) attron(A_UNDERLINE) ;
				mvaddstr (row[selection], col[selection],
					functions[selection]);
                                attroff(A_UNDERLINE) ;

				if (selection == min)
					selection = min + no_titles-1 ;
				else
					--selection;
                                if (sel[selection]) attron (A_UNDERLINE) ;
				attron (A_REVERSE);
				mvaddstr (row[selection], col[selection],
					functions[selection]);
                                attroff(A_UNDERLINE) ;
				break;

                        case LF :
			case KEY_DOWN:
                                if (sel[selection]) attron(A_UNDERLINE) ;
				mvaddstr (row[selection], col[selection],
					functions[selection]); 
                                attroff (A_UNDERLINE) ;

				if (selection == min + no_titles-1)
					selection = min;
				else
					++selection;
				attron (A_REVERSE);
                                if (sel[selection]) attron(A_UNDERLINE) ;
				mvaddstr (row[selection], col[selection],
					functions[selection]);
                                attroff (A_UNDERLINE) ;
				break;

                       case KEY_ENTER:
                                if (sel[selection]) sel[selection] = 0 ;
                                 else {
                                       sel[selection] = 1 ;
                                       attron (A_UNDERLINE) ;
				     }
                                attron (A_REVERSE) ;
				mvaddstr (row[selection], col[selection],
					functions[selection]);
				attroff (A_UNDERLINE);
				break;

                       case PF3:
				*flag = -1 ;      /* cancel */
				attroff (A_REVERSE) ;
/*				echo () ; */
				refresh () ;
                                return (-2) ;

                       case PF1:
				*flag = 0 ;        /* accept */
				attroff (A_REVERSE) ;
/*				echo () ; */
				refresh () ;
                                return (-2) ;

		      case PF4:
			        *flag = 1 ;        /* all */
				attroff (A_REVERSE) ;
		/*			       echo () ; */
				refresh () ;
				return (-2) ;

			default:
				break;
			      }

		attroff (A_REVERSE);
	      }
        *selec =selection ;
        refresh () ;
	return (-1);
  }



int CVTget_db_type ()
{
  char *fname="CVTget_db_type";
  char dbtype[2];
  long status ;

  _NFMdebug((fname,"ENTER\n")) ;
  
  status = SQLget_dbtype(CVTglobal.schema_name,dbtype);
  if(status != SQL_S_SUCCESS)
    {
      _NFMdebug((fname,"Cannot get dbtype: status <0x%.8x>\n",status));
      return(status);
    }
  switch(dbtype[0])
    {
    case 'O' :
      strcpy(CVTglobal.database,"ORACLE");
      break;
    case 'I' :
      strcpy(CVTglobal.database,"INGRES");
      break;
    case 'D' :
      strcpy(CVTglobal.database,"DB2");
      break;
    case 'X' :
    default:
      strcpy(CVTglobal.database,"INFORMIX");
      break;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return(NFM_S_SUCCESS);
}

long CVTline_options (argc, argv, filename, username, password, environment, activity, take_defaults)
     int argc ;
     char **argv ;
     char *filename, *username, *password, *environment, *activity ;
     long *take_defaults ;
{
  int c ;
  long error_flag = 0 ;

  CVTconsole = NULL ;
  *take_defaults = 0 ;
  while (((c = getopt(argc,argv,"d:u:p:e:a:?:D")) != EOF) && (!error_flag))
    {
      switch(c)
	{
	case 'd':
	  strcpy(filename,optarg);
	  if ( strlen (filename))
	    {
	      if ((CVTconsole = fopen(filename,"w")) == NULL)
		{
		  fprintf(stderr,"%s: unable to open \"%s\" for debug\n",
			  argv[0],filename);
		  CVTlogout (-1) ;
		}
	    }
	  else
	    {
	      strcpy (filename, "/dev/console") ;
	      if ((CVTconsole = fopen("/dev/console","w")) == NULL)
		{
		  fprintf(stderr,"%s: unable to open /dev/console for debug\n");
		  CVTlogout (-1) ;
		}
	    }

	  break;
	  
	case 'u':
	  /* the login username */
	  strcpy (username, optarg);
	  break;

	case 'p':
	  /* password */
	  strcpy (password, optarg);
	  break;

	case 'e':
	  /* the environment to connect to */
	  strcpy (environment, optarg);
	  break;

	case 'a':
	  /* nfmactivity table */
	  strcpy(activity, optarg);
	  break;
	  
    case 'D' :
      /* take defaults */
      *take_defaults = 1;
      break ;

	case '?':
	  error_flag = 1 ;
	  fprintf (stderr,
		   "Usage: %s [-d output] [-u username] [-p password] [-e environment] [-a activity] [-D]\n",
		   argv[0]);
	  /*	CVTlogout (1) ; */
	  break;
    

	  default :
	    error_flag = 1 ;
	    break ;
	}
    }
  return (NFM_S_SUCCESS) ;
}

long CVTvalidate_administrator (username, password)
     char *username, *password ;
{
  char *fname = "CVTvalidate_administrator" ;
  char sql_str [512], d_passwd [51] ;
  MEMptr list = NULL ;
  long status ;
  char **data ;
  
  _NFMdebug ((fname, "ENTER\n")) ;

  sprintf (sql_str, "Select e.n_passwd \
from nfmacls a, nfmworkflow b, nfmaclusers c, nfmclasses d, nfmusers e \
 where e.n_username = '%s' and b.n_workflowname = 'NFM_ADMIN_WORKFLOW' and a.n_workflowno = b.n_workflowno and c.n_aclno = a.n_aclno and d.n_classname = 'administrator' and d.n_workflowno = b.n_workflowno and e.n_userno=c.n_userno",
	   username) ;
  
  status = SQLquery (sql_str, &list, MEM_SIZE) ;
  
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&list) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  if (status == SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&list) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Not an administrator") ;
      _NFMdebug ((fname, "User is not administrator\n")) ;
      return(NFM_E_MESSAGE) ;
    }

  status = MEMbuild_array (list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) list->data_ptr ;
  status = NFMdecrypt (data [0], d_passwd) ;
  if (status != NFM_S_SUCCESS)
    {
      return (status) ;
    }

  if (strcmp (d_passwd, password))
    {
      MEMclose (&list) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad password") ;
      _NFMdebug ((fname, "Bad Password\n")) ;
      return (NFM_E_MESSAGE) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long CVTcheck_ris_bad (ris_bad_file)
     char *ris_bad_file ;
{
  char *fname = "CVTcheck_ris_bad" ;
  long status ;
  struct stat file_buf ;

  _NFMdebug ((fname, "ris bad file <%s>\n", ris_bad_file)) ;

  status = stat (ris_bad_file, &file_buf) ;
  if ((status) && (errno != 2))
    {
      _NFMdebug ((fname, "Failure : stat failed : errno <%d>\n",
		  errno)) ;
      ERRload_struct (NFM, NFM_E_STAT, "", "") ;
      return (NFM_E_STAT) ;
    }

  if ((!status) && (file_buf.st_size != 0))
    {
      _NFMdebug ((fname, "Failure : file status : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Ris operation failed") ;
      return (NFM_E_MESSAGE) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _CVTconvert_to_timestamp (in_str1, out_str) 
     char *in_str1 ;
     char *out_str ;
{
  char *fname = "_CVTconvert_to_timestamp" ;
  long status ;
  long CVTamerican_to_timestamp ();
  long CVTansi_to_timestamp () ;
  char in_str[50];

  strncpy(in_str, in_str1,49);
  in_str[49]=NULL;
  strcpy(out_str, "");

  if (strcmp (CVTglobal.date_type, "AMERICAN") == 0)
    {
      status = CVTamerican_to_timestamp (in_str, out_str) ;
    }
/* else ANSI */
  else
    {
      status = CVTansi_to_timestamp (in_str, out_str) ;
    }

  _NFMdebug ((fname, "input date %s output date %s : status <0x%.8x>\n",
	      in_str, out_str, status)) ;
  return (status) ;
}

