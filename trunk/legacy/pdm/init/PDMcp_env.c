#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "DEBUG.h"
#include "NETstruct.h"
#include "PDUerror.h"
#include "NFMstruct.h"
#include "curses.h"
#include "PDMproto.h"
#ifdef strchr
#undef strchr
#endif

    /*  Kumar - 8/8/92 */

char PDMCWD[100];
char PDM_ENV[200];
char PDM_REPORTS[200];
char PDM_PPLFILES[200];
extern char env[20];
extern char nfmlogin[20];
extern char nfmpasswd[20];

 long PDMcreate_env_file (env)
    char *env;
   {
     static char *fname = "PDMcreate_env_file" ;
     long      status;
     FILE      *fopen (), *in_file, *out_file;
     char      str [100];
     long      stat_loc ;
     struct   stat buf;
     char     NFM_ENV_FILE[200];
     char     PDM_ENV_FILE[200];
     char     *c_status;
     char     *env_var_name;
     char     name_path[80];

     _PDMdebug (fname, "CR ENV : %s\n", env);

     sprintf (NFM_ENV_FILE, "/usr/lib/nodes/owned/nfme_%s", env);
     sprintf (PDM_ENV_FILE, "/usr/lib/nodes/owned/pdme_%s", env);

c_status = (char *) stat (NFM_ENV_FILE, &buf) ;
     if (c_status)
       {
         _PDMdebug("/usr/lib/nodes/owned/nfme_%s was not found \n",env) ;
         printf("/usr/lib/nodes/owned/nfme_%s was not found \n",env) ;
         printf("Reinitialize I/NFM properly\n\n",env) ;
         return (NFM_E_OPEN_FILE) ;
       }
      in_file = fopen (NFM_ENV_FILE, "r");
      if (! in_file)
       {
         _PDMdebug (fname, "fopen %s: errno  = <%d>\n", NFM_ENV_FILE,errno);
         return (NFM_E_OPEN_FILE);
       }
if ((out_file = fopen (PDM_ENV_FILE, "w+")) == NULL)
      {
        status = NET_E_OPEN_FILENAME;
           unlink (PDM_ENV_FILE);
       printf("\nPDMinit should be owned by root with sticky bit set\n\n") ;
         _PDMdebug (fname, "fopen %s: errno  = <%d>\n", PDM_ENV_FILE,errno);
        return (status);
      }
     
     while ( fgets(str, 100, in_file) != NULL)
            fputs(str, out_file);
   
      status = fclose (in_file);
      if (status) /* OK */
      {
         _PDMdebug (fname, "fopen %s: errno  = <%d>\n", NFM_ENV_FILE,status);
        status = NET_E_CLOSE_FILE;
        return (status);
      }
       
      status = fclose (out_file);
      if (status) /* OK */
      {
         _PDMdebug (fname, "fopen %s: errno  = <%d>\n", PDM_ENV_FILE,status);
        status = NET_E_CLOSE_FILE;
        return (status);
      }
    
       str[0] = '\0';
#if defined(sco)
      status = (long) fork () ;
#else
      status = (long) vfork () ;
#endif
      if (status == 0)
        {
          sprintf (str, "pdme_%s", env) ;
          _PDMdebug (fname,"Executing a /usr/bin/clh -u %s\n",
                     str) ;
          status = (long) execl ("/usr/bin/clh", "/usr/bin/clh", "-u",
                                 str, (char *) 0) ;
          if (status == -1)
            {
              _PDMdebug (fname, "execl failed %d\n", errno);
              exit (0) ;
            }
        } if (status == -1)
        {
          _PDMdebug (fname, "vfork failed %d\n", errno);
          return (status) ;
        }


     status = (long) wait(&stat_loc) ;
     if (status == -1)
       {
         if (errno == EINTR)
           {
         _PDMdebug (fname, "Receipt of a signal from child process%d\n", errno);
           }
         else
           {
             _PDMdebug (fname, "wait for the child process failed %d\n", errno);
           }
         return (status) ;
       }

    printf("UPDATED CLEARINGHOUSE FOR ENVIRONMENT %s \n",env); 
#if defined(sco)
       status = (long) fork () ;
#else
       status = (long) vfork () ;
#endif
      if (status == 0)
        {
       /* Need to check the return status of getenv. MaC 060594 */

          /*env_var_name = (char *)getenv("INGRHOME");*/

          name_path[0] = '\0';
          if ((env_var_name = (char *) getenv("INGRHOME")) == NULL) {
             _PDMdebug (fname, "INGRHOME is not set...\n");
             strcpy (name_path, "/usr/ip32/inc/namex");
            }
          else {
              sprintf(name_path,"%s/inc/namex\0",env_var_name);
                }

          status = (long) execl (name_path, name_path,(char *) 0) ;
          if (status == -1)
            {
              _PDMdebug (fname, "execl for namex failed %d\n", errno);
              exit (0) ;
            }
        }

    printf("BROADCASTING THE NEW ENVIRONMENT AND SERVER \n"); 

      if (status == -1)
        {
          _PDMdebug (fname, "vfork failed %d\n", errno);
          return (status) ;
        }

      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
      return (PDM_S_SUCCESS);
   }


 long PDMcreate_ser_file (ser)
    char *ser;
   {
     static char *fname = "PDMcreate_ser_file" ;
     long      status;
     FILE      *fopen (), *in_file , *out_file;
     char      str [100];
     long      stat_loc ;
     struct   stat buf;
     char     NFM_SER_FILE[200];
     char     PDM_SER_FILE[200];
     char     *c_status;

     _PDMdebug (fname, "CR SERVER : %s\n", ser);

     sprintf (NFM_SER_FILE, "/usr/lib/nodes/owned/nfms_%s", ser);
     sprintf (PDM_SER_FILE, "/usr/lib/nodes/owned/pdms_%s", ser);

c_status = (char *) stat (NFM_SER_FILE, &buf) ;
     if (c_status)
       {
         _PDMdebug("/usr/lib/nodes/owned/nfme_%s was not found ",ser) ;
         printf("/usr/lib/nodes/owned/nfms_%s was not found \n",ser) ;
         printf("Reinitialize I/NFM properly\n\nerly\n\n") ;
         return (NFM_E_OPEN_FILE) ;
       }
      in_file = fopen (NFM_SER_FILE, "r");
      if (! in_file)
       {
         _PDMdebug (fname, "fopen %s: errno  = <%d>\n", NFM_SER_FILE,errno);
         return (NFM_E_OPEN_FILE);
       }
if ((out_file = fopen (PDM_SER_FILE, "w+")) == NULL)
      {
        status = NET_E_OPEN_FILENAME;
           unlink (PDM_SER_FILE);
       printf("\nPDMinit should be owned by root with sticky bit set\n") ;
         _PDMdebug (fname, "fopen %s: errno  = <%d>\n", PDM_SER_FILE,errno);
        return (status);
      }
     
       str[0] = '\0';
     while ( fgets(str, 100, in_file) != NULL)
            fputs(str, out_file);
   
      status = fclose (in_file);
      if (status) /* OK */
      {
         _PDMdebug (fname, "fopen %s: errno  = <%d>\n", NFM_SER_FILE,status);
        status = NET_E_CLOSE_FILE;
        return (status);
      }
       
      status = fclose (out_file);
      if (status) /* OK */
      {
         _PDMdebug (fname, "fopen %s: errno  = <%d>\n", PDM_SER_FILE,status);
        status = NET_E_CLOSE_FILE;
        return (status);
      }
    
       str[0] = '\0';
#if defined(sco)
      status = (long) fork () ;
#else
      status = (long) vfork () ;
#endif
      if (status == 0)
        {
          sprintf (str, "pdms_%s", ser) ;
          _PDMdebug (fname,"Executing a /usr/bin/clh -u %s\n",
                     str) ;
          status = (long) execl ("/usr/bin/clh", "/usr/bin/clh", "-u",
                                 str, (char *) 0) ;
          if (status == -1)
            {
              _PDMdebug (fname, "execl failed %d\n", errno);
              exit (0) ;
            }
        } if (status == -1)
        {
          _PDMdebug (fname, "vfork failed %d\n", errno);
          return (status) ;
        }
       

     status = (long) wait(&stat_loc) ;
     if (status == -1)
       {
         if (errno == EINTR)
           {
         _PDMdebug (fname, "Receipt of a signal from child process%d\n", errno);
           }
         else
           {
             _PDMdebug (fname, "wait for the child process failed %d\n", errno);
           }
         return (status) ;
       }

    printf("UPDATED CLEARINGHOUSE FOR SERVER %s\n",ser); 

      if (status == -1)
        {
          _PDMdebug (fname, "vfork failed %d\n", errno);
          return (status) ;
        }

      _PDMdebug (fname, "SUCCESSFUL : status = <0x%.8x>\n", PDM_S_SUCCESS);
      return (PDM_S_SUCCESS);
   }

/* Kumar 8/14/92 */

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
  static char blank_line[31] = "                       " ;
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
/*               mvaddstr (22,10,"       ") ;
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
/*               mvaddstr (22,10,"       ") ;
               mvaddstr (22,10, temp) ;
*/
               if (attr[y] == ECHO_S) mvaddstr (y+Y_OFFSET, X_OFFSET, temp) ;
                             else move (y+Y_OFFSET, X_OFFSET) ;
               keystroke = 0 ;
               refresh() ;
               break ;

     case BS :
     case DEL :

      if (x==0) {beep() ;
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

/* Kumar 8/24/92 */



int PDMadd_reports_dir ()
{
  static char *fname = "PDMadd_reports_dir" ;
  char *cwd ;
  char  sql_str[512];
  long status ;
  MEMptr bufr = NULL;
  char node_name[50] = "";
  int  nodeno, sano;
  char **data;
  char *c_status, str_stmt[512], enc_passwd[50], e_passwd[50] ;


      _PDMdebug(fname,"ENTER:");
status = NFMencrypt (nfmpasswd, enc_passwd) ;
  if (status != NFM_S_SUCCESS)
    {
      _PDMdebug (fname, "NFMencrypt failed : status = <0x%.8x>\n", NFM_E_BAD_TEMPLATE);
      return (NFM_E_MESSAGE) ;
    }

  status = NFMtic_to_tics (enc_passwd, e_passwd) ;
  if (status != NFM_S_SUCCESS)
    {
      _PDMdebug (fname, "NFMtic_to_tics failed : status = <0x%.8x>\n", NFM_E_BAD_TEMPLATE);
      return (NFM_E_MESSAGE) ;
    }

c_status = (char *) clh_vbyop ("TEMPLATE", "NODENAME", node_name);
  if (c_status)
    {
      _PDMdebug (fname, "Node Name Not Defined : status = <0x%.8x>\n", NFM_E_BAD_TEMPLATE);
      return (NFM_E_BAD_TEMPLATE);
    }

sprintf (str_stmt, "SELECT n_nodeno FROM  NFMNODES WHERE n_nodename = '%s'", node_name) ;

  status = SQLquery (str_stmt, &bufr, 512) ;
  if (status != SQL_S_SUCCESS)
    {
      _PDMdebug (fname, "Node No Not found in NFMnodes table : status = <0x%.8x>\n", NFM_E_BAD_NODE);
      return (NFM_E_BAD_NODE);
    }

    status = MEMbuild_array(bufr);
     if(status != MEM_S_SUCCESS)
       {
      _PDMdebug (fname, "MEMbuild_array : status = <0x%.8x>\n",status);
      return (status);
       }

    data = (char **) bufr->data_ptr;

    nodeno = atoi(data[0]);

     MEMclose(&bufr);
  
      bufr = NULL;

sprintf (str_stmt, "SELECT MAX(n_sano) FROM  NFMSTORAGEAREA") ;

  status = SQLquery (str_stmt, &bufr, 512) ;
  if (status != SQL_S_SUCCESS)
    {
      _PDMdebug (fname, "Node No Not found in NFMnodes table : status = <0x%.8x>\n", NFM_E_BAD_NODE);
      return (NFM_E_BAD_NODE);
    }

    status = MEMbuild_array(bufr);
     if(status != MEM_S_SUCCESS)
       {
      _PDMdebug (fname, "MEMbuild_array : status = <0x%.8x>\n",status);
      return (status);
       }

    data = (char **) bufr->data_ptr;
    sano = (atoi(data[0]) +1) ;

     PDMCWD [0] = '\0';
     cwd = NULL;
     cwd = (char *) getcwd ((char *) NULL, 98);
     if (! cwd)
       {
        _PDMdebug (fname, "INIT : Error No = <%d>\n", errno);
        _PDMdebug (fname, "INIT : Get CWD Failed : status = <0x%.8x>\n", NFM_E_GETPWD);

        return(NFM_E_GETPWD);
         }
      else strcpy(PDMCWD,cwd);

sprintf (PDM_REPORTS, "%s/%s/pdmreports", PDMCWD, env);

/* make reports subdirectory <CWD>/ENV/pdmreports */


  status = (long) mkdir (PDM_REPORTS, 00000775) ;
  if (status == -1)
    {
      _PDMdebug (fname, "mkdir %s failed", PDM_REPORTS);
      _PDMdebug (fname, "mkdir error no %d\n", errno);
      return (status);
    }

      status = (long) chown (PDM_REPORTS, (int) getuid(), (int) getgid()) ;
  if (status == -1)
    {
      _PDMdebug (fname, "chown %s failed", PDM_REPORTS);
      _PDMdebug (fname, "chown error no %d\n", errno);
      return (status);
    }

    sprintf(sql_str,"insert into nfmstoragearea (n_sano, n_saname, n_nodeno, n_username, n_passwd, n_pathname, n_devicetype, n_type, n_owner, n_nfs, n_compress, n_plattername, n_partition) values (%d, 'RIS templates', %d, '%s', '%s', '%s','HD', 'W', 1, 'N', 'N','', '')",sano,nodeno,nfmlogin,e_passwd,PDM_REPORTS );

      status = SQLstmt(sql_str);
       if(status != SQL_S_SUCCESS)
         {
      _PDMdebug (fname, "SQLstmt %s failed",status);
      return (status);
          }

++sano;

sprintf (PDM_PPLFILES, "%s/%s/pdmpplfiles", PDMCWD, env);

/* make reports subdirectory <CWD>/ENV/pdmreports */


  status = (long) mkdir (PDM_PPLFILES, 00000775) ;
  if (status == -1)
    {
      _PDMdebug (fname, "mkdir %s failed", PDM_REPORTS);
      _PDMdebug (fname, "mkdir error no %d\n", errno);
      return (status);
    }

      status = (long) chown (PDM_PPLFILES, (int) getuid(), (int) getgid()) ;
  if (status == -1)
    {
      _PDMdebug (fname, "chown %s failed", PDM_PPLFILES);
      _PDMdebug (fname, "chown error no %d\n", errno);
      return (status);
    }

    sprintf(sql_str,"insert into nfmstoragearea (n_sano, n_saname, n_nodeno, n_username, n_passwd, n_pathname, n_devicetype, n_type, n_owner, n_nfs, n_compress, n_plattername, n_partition) values (%d, 'PDM Functions', %d, '%s', '%s', '%s','HD', 'W', 1, 'N', 'N','', '')",sano,nodeno,nfmlogin,e_passwd,PDM_PPLFILES );

      status = SQLstmt(sql_str);
       if(status != SQL_S_SUCCESS)
         {
      _PDMdebug (fname, "SQLstmt %s failed",status);
      return (status);
          }
      _PDMdebug(fname,"EXIT:");
    return (PDM_S_SUCCESS);

}
