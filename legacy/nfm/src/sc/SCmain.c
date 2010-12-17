#include "machine.h"
#include <curses.h>
#include <ctype.h>
#include <signal.h>
#include "MSGstruct.h"
#include "SCstruct.h"
#include "SCextern.h"
#include "UNIX_or_VMS.h"
#include "SCrap.h"
#include "NFIerrordef.h"
#include "NETerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "UMS.h"

#ifdef OS_HPUX
/* HP PORT - IGI - 1 Jul 94 */
#include "NFMcurses.h"
#endif

extern char   SCexec[30];
extern char   SCuser_cmd_file[150];
extern char   SCadmin_cmd_file[150];

/** Can not include NFMRextern.h because it conflicts with
    NFM_E_FAILURE Definition **/
#ifdef COMBINED_MAKE
#define COMBINED_CLIENT_SERVER
#endif

int keyin_count;
int display_count;

int error_line;
char error_msg[80];
char string[81];
char *strrchr();

WINDOW *cmd_win;
struct SCfunc_st *first_func,*cur_func,*last_func;

struct _ERRstruct _ERRstruct;

void Signal_function();

main(argc,argv)
int argc;
char **argv;
  {
    FILE *menu;

    int i,c;
    int mode = IMMEDIATE;        /* RAP mode */
    int match_count;

    char  *whence();    /* Temp - Vasu */

    chtype ch;

    char *p;
    char *sts;       /* RAP status */
    char filename[132];
    char func_name[80];
    char menu_file[132];
    char user_menu_file[132];
    char all_menu_file[132];
    char config_file[132];
    char server[20];
    char environment[20];
    char username[20];
    char password[20];
    char exec_path[132] ;
    char path[256];
    char language[20];

    struct SCfunc_st *top,*temp;
    struct SCfunc_st *match_func;

    int status;    /* KT */
    int NFM_E_FAILURE = 1;
    int error_flag = FALSE;
    int file_flag = FALSE;    /* has an error file been defined ? */
    int user_menu_flag = FALSE;    /* has a user data file been requested ? */
    int all_menu_flag = FALSE; /*  has all data file been requested ? */
    int user_rap  = FALSE;    /* has user turned on RAP ? */
    int user_flag = FALSE;    /* username specified */
    int pwd_flag  = FALSE;    /* password specified */

    extern char *optarg;
    extern int optind;

    FILE *fopen();
    FILE *language_file;

    strcpy( SCprint_file, "./Nfmalpha.prt" );

    SCdebug = FALSE;
    SCconsole = NULL;

    user_menu_file[0] = 0;
    all_menu_file[0]  = 0;

 /* Added by VASU 15.11.93 */

    strcpy (server,  "");
    strcpy (environment,  "");
    strcpy (username,  "");
    strcpy (password,  "");

    /* End addition VASU 15.11.93 */

    /*  Set up default menu_file ( user_menu file )
     */

    strcpy (menu_file, SCuser_cmd_file);
    strcpy (user_menu_file, menu_file );
    strcpy (all_menu_file, SCadmin_cmd_file);

    while ((c = getopt(argc,argv,"do:m:R:P:u:p:s:e:A")) != EOF)
      {
        switch(c)
          {
            case 'o':
              strcpy(filename,optarg);
              strncpy (_NFMdebug_st.NFMRdebug_file, optarg,
                       NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NFMRdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy (_NFMdebug_st.ERRdebug_file, optarg,
                       NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.ERRdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy (_NFMdebug_st.NFMdebug_file, optarg,
                       NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NFMdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy (_NFMdebug_st.NFIdebug_file, optarg,
                       NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NFIdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';
/* keep them for debugging info - srinivas */
              strncpy (_NFMdebug_st.NETCdebug_file, optarg,
                       NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NETCdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy (_NFMdebug_st.NETSdebug_file, optarg,
                       NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.NETSdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';

              strncpy (_NFMdebug_st.SQLdebug_file, optarg,
                       NFM_DEBUG_FILE_SIZE);
              _NFMdebug_st.SQLdebug_file[NFM_DEBUG_FILE_SIZE-1] = '\0';
/* srinivas */
              file_flag = TRUE;
              break;

            case 'd':
              SCdebug = TRUE;
	      _NFMdebug_st.NFIdebug_on = TRUE;
              _NFMdebug_st.NFMRdebug_on = TRUE;
              _NFMdebug_st.NFMdebug_on = TRUE;
              _NFMdebug_st.ERRdebug_on = TRUE;
              _NFMdebug_st.NETCdebug_on = TRUE;  /* srinivas */
              _NFMdebug_st.NETSdebug_on = TRUE;  /* srinivas */
              _NFMdebug_st.SQLdebug_on = TRUE;   /* srinivas */
              break;

            case 'm':
              /* full pathname of menu command file */
              strcpy (user_menu_file, optarg);
              user_menu_flag = TRUE;
              break;
            case 'R':
              /* record option */
	      user_rap = TRUE;
              if ((sts = start_record(optarg)) != NULL)
              {
                fprintf(stderr,"%s: %s\n",argv[0],sts);
                exit(1);
              }
              break;
            case 'P':
              /* playback option */
              switch (optarg[0])
              {
                case 'i':
                  mode = IMMEDIATE;
                  break;

                case 'r':
                  mode = REAL_TIME;
                  break;

                case 's':
                  mode = SINGLE_STEP;
                  break;

                default:
                  error_flag = TRUE;
                  break;
              }
              if (!error_flag)
              {
		  user_rap = TRUE;
                  if ((sts = start_playback(optarg + 1,mode)) != NULL)
                  {
                    fprintf(stderr,"%s: %s\n",argv[0],sts);
                    exit(1);
                  }
              }
              break;

            case 'u':
              /* the login username */
              strcpy (username, optarg);
	      user_flag = TRUE;
              break;
            case 'p':
              /* password */
              strcpy (password, optarg);
	      pwd_flag = TRUE;
              break;
            case 's':
              /* the server to connect to */
              strcpy (server, optarg);
#ifdef COMBINED_CLIENT_SERVER
              fprintf (stderr, "Usage: %s [-d [-o output]] [-m user command file] [-P{i|r|s}filename] [-u username] [-p password] [-e environment] [-R filename] [-A admin command file]\n",  argv[0]);
	              exit(1);
#endif
              break;
            case 'e':
              /* the environment to connect to */
              strcpy (environment, optarg);
              break;
            case 'A':
              /* full pathname of menu command file */
              all_menu_flag = TRUE;
	      if( optarg != NULL )
                  strcpy (all_menu_file, optarg);

              break;
            case '?':
              error_flag = TRUE;
              break;
          }
      }
    if (error_flag)
      {
#ifdef COMBINED_CLIENT_SERVER
        fprintf (stderr, 
              "Usage: %s [-d [-o output]] [-m user command file] [-P{i|r|s}filename] [-u username] [-p password] [-e environment][-R filename] [-A admin command file]\n",  argv[0]);
        exit(1);
#endif
        fprintf (stderr,
          "Usage: %s [-d [-o output]] [-m user command file] [-P{i|r|s}filename] [-u username] [-p password] [-s server] [-e environment] [-R filename] [-A admin command file]\n", argv[0]);
        exit(1);
      }

    if (file_flag)
      {
        if ((SCconsole = fopen(filename,"w")) == NULL)
          {
            fprintf(stderr,"%s: unable to open \"%s\" for SCdebug\n",
                    argv[0],filename);
            exit(1);
          }
      }
    else
      {
        if (SCdebug)
          {
            if ((SCconsole = fopen("/dev/console","w")) == NULL)
              {
                fprintf(stderr,"%s: unable to open SCconsole for SCdebug\n",
                        filename);
                exit(1);
              }
          }
      }

/* Print out copyright */
    _NFMprint_copyright (SCexec);
    sleep (3); 

    if(!pwd_flag )
	strcpy( password, "" );

    if (SCdebug)
      {
        fprintf(SCconsole,"Debug output goes here...\n");
      }

      for (i=1;i<=17;i++)
      {
	if (i!=SIGALRM)
        signal (i,  Signal_function);
      }

/* IGNORE SIGNAL 13 (SIGPIPE) - 11/30/89 Glenn said to trap signal 13 */
/* !!!!!!!!!!!!!!!!!!!!!!!!!! - 11/30/89 Glenn also said to ignore signal 18 */

      for (i=19;i<=27;i++)
      {
/* SIGWINCH is terminating the application - PS */
#if defined(OS_INTELSOL)
	if (i!=SIGWINCH)
#endif
        signal (i, Signal_function);
      }
  
    /* ignore the signal SIG_CHLD for system() to work properly */

#ifndef OS_CLIX
    signal(SIGCHLD,SIG_DFL);
#endif
    keyin_count = 0;
    error_line = 1;

    initscr();
    noecho();
    nocrmode(); /* -- remove later - tmpPS  */
    raw();
    keypad(stdscr,TRUE);

    init_rap (user_rap);

    cmd_win = newwin(2,80,0,0);
    keypad(cmd_win,TRUE);

    SCmsg_win = newwin(1,80,2,0);
    wattrset(SCmsg_win,A_REVERSE);

    SCref_win = newwin(1,80,3,0);
    wattrset(SCref_win,A_REVERSE);

    refresh();

/* JM - Determine path of message files then initialize ERRor message files */
    status = ERRinit_messages (config_file, mode);
    if( status != ERR_S_SUCCESS )
    {
        sprintf (error_msg, "Error initializing error message files <0x%.8x>\n",status );
        SCdisplay_msg (error_msg);
        endwin ();
        exit (0);
    }
    strcpy (path, "/usr/ip32/nfm/config/language");

    /*  Open the "language" file to find the preferred language  */

    strcpy( language, "english" );
    if ((language_file = fopen (path, "r")) == NULL)
    {
	sprintf( error_msg, "Failed to open <%s>\n", path);
        SCdisplay_msg( error_msg ); 
    }
    else
    {
        /*  Read the language out of the file  */

        if ((SCfgets (language,
            sizeof (language) - 1, language_file)) == NULL)
        {
            strncpy (language, "english", sizeof (language) - 1);
        }

        fclose (language_file);
    }

    /*  Remove "/language"  */

    p = strrchr (path, '/');
    *p = NULL;

    strcat (path, "/");
    strcat (path, language);
    strcat (path, "/messages/NFMtitles.msg");
   
    UMSInitMsg( path, UMS_INDEX );

     strcpy( exec_path,  whence (argv[0],  NULL));

/* KT - function to either call nfm_init or nfm_login */
/* JM - nfm_init always returns 'NFM_E_FAILURE' so you will
 *      exit the SCreen controller after initializing.
 */
    status = nfm_enter (server, environment, username, password,
                        exec_path);

    if ((status == NFI_W_COMMAND_CANCELLED) || (status == NFI_E_FAILURE) ||
	(status == NFM_E_FAILURE))
        {
	ERRget_message( error_msg );
	SCdisplay_msg( error_msg );
        status = nfm_exit ();
        endwin ();
        exit (0);
        }
    if ((status == NFI_W_COMMAND_CANCELLED) || 
	(status == NET_E_NO_SERVER_CONNECTION))
	{
	ERRget_message( error_msg );
	SCdisplay_msg( error_msg );
	endwin ();
	exit (0);
	}

    if (status == NFI_S_SUCCESS)
    {
        ERRget_message( error_msg );
        SCdisplay_msg( error_msg );
	ERRreset_struct();
    }

    /* if both menu files OR no menu files were specified on 
     * the command line, use the user menu file (default). Otherwise, use
     * the menu file specified.
     */
    if (user_menu_flag && all_menu_flag)  /* Both options specified */
	strcpy( menu_file, user_menu_file );
    else if( (!user_menu_flag) && (!all_menu_flag) ) /* No menu option */
	user_menu_flag = TRUE;
    else if( all_menu_flag )			     /* All menu option */
	strcpy( menu_file, all_menu_file );
    else if( user_menu_flag )			     /* User menu option */
	strcpy( menu_file, user_menu_file );

    /* Try to open the menu file.  If you can't, default to "user.dat" */

    if ((menu = fopen(menu_file, "r")) == NULL)
        sprintf (menu_file, SCuser_cmd_file);
    else
        fclose (menu);

    if ((read_function_file (&top, menu_file)) == ERROR)
      {
        sprintf (error_msg, "Error reading command data file. <%s : #%d>\n",
                 menu_file, error_line);
        SCdisplay_msg (error_msg);
        status = nfm_exit ();
        endwin ();
        exit (0);
      }

    cur_func = top;
    first_func = top;

/**/

    touchline(stdscr,5,19);

    update_cmd_win();

    while(1)
      {
        ch = getch_rap ();
        SCclear_msg();
        switch(ch)
          {
            case 127:
            case 8:
              if (keyin_count > 0)
                {
                  keyin_count--;
                  func_name[keyin_count] = 0;
                  mvwdelch(cmd_win,1,keyin_count);
                  wrefresh(cmd_win);
                }
              break;
/*
            case KEY_UP:
              if (cur_func->parent != NULL)
                {
                  first_func = cur_func->parent_first_func;
                  cur_func = cur_func->parent;
                  update_cmd_win();
                  keyin_count = 0;
                }
              break;
*/
            case KEY_DOWN:
              break;
            case KEY_RIGHT:
              if (cur_func->next != NULL)
                {
                  if (cur_func == last_func)
                    {
                      temp = first_func;
                      for(i=0;i<(display_count/2) + 1;i++)
                        temp = temp->next;
                      temp->left_scroll = first_func;
                      first_func = temp;
                    }
                  cur_func = cur_func->next;
                  update_cmd_win();
                  keyin_count = 0;
                }
              flushinp();
              break;
            case KEY_LEFT:
              if (cur_func->prev != NULL)
                {
                  if (cur_func == first_func)
                    {
                      first_func = cur_func->left_scroll;
                    }
                  cur_func = cur_func->prev;
                  update_cmd_win();
                  keyin_count = 0;
                }
              flushinp();
              break;
            case '\n':
            case 13:
              if (keyin_count)
                {
                  match_count = 0;

/* first check displayed functions */
                  temp = first_func;
                  while (1)
                    {
                      if (!strncmp_ignore_case(temp->func_symb,func_name,
                                               strlen(func_name)))
                        {
                          match_count++;
                          match_func = temp;
                        }
                      if (temp == last_func || temp->next == NULL)
                        break;
                      temp = temp->next;
                    }

                  if (match_count == 1)
                    {
                      cur_func = match_func;
                      execute_func();
                      update_cmd_win();
                      keyin_count = 0;
                      break;
                    }

/* check all functions at this level */
                  temp = first_func;
                  while(temp->prev != NULL)
                    temp = temp->prev;
                  check_for_function(temp,func_name,&match_func,&match_count);
                  if (match_count == 1)
                    {
                      /* move cur_func to left-most function */
                      /* set first_func to left-most function */
                      first_func = cur_func = temp;

                      update_cmd_pointers();
                      while (cur_func->next != NULL)
                        {
                          if (cur_func == match_func)
                            break;
                          if (cur_func == last_func)
                            {
                              temp = first_func;
                              for(i=0;i<(display_count/2) + 1;i++)
                                temp = temp->next;
                              temp->left_scroll = first_func;
                              first_func = temp;
                            }
                          cur_func = cur_func->next;
                          update_cmd_pointers();
                          keyin_count = 0;
                        }
                      execute_func();
                      update_cmd_win();
                      keyin_count = 0;
                    }
                  else
                    {
                      sprintf(string,"Invalid keyin: %s matches %d functions\n",
                               func_name,match_count);
                      SCdisplay_msg(string);
                      update_cmd_win();
                      keyin_count = 0;
                    }
                }
              else 
                {
                  execute_func();
                  update_cmd_win();
                }
              break;
            case 5:  /* ctrl-e */
/*
             endwin();
             exit(0);
*/
             break;
            case 264:  /* KT- ATP test function */
             rap_exec_process ();
             break;
            default:
/* KT - check keyin_count to avoid crash */
              if ((isprint(ch)) && (keyin_count < 80))
                {
                  wmove(cmd_win,1,keyin_count);
                  if (keyin_count == 0)
                    {
                      wclrtoeol(cmd_win);
                    }
                  func_name[keyin_count++] = ch;
                  func_name[keyin_count] = 0;
                  wechochar(cmd_win,ch);
                }
              
              break;
          }
      }
  }

int update_cmd_win()
  {
    int pos;
    int len;
    struct SCfunc_st *ptr;

    werase(cmd_win);

    pos = 0;
    display_count = 0;
    ptr = first_func;
    while (ptr != NULL)
      {
        len = strlen(ptr->func_symb);
        if (len + pos >= 79)
          break;
        last_func = ptr;
       
        if (ptr == cur_func)
          wstandout(cmd_win);
        mvwaddstr(cmd_win,0,pos,ptr->func_symb);
        wstandend(cmd_win);

        if (ptr->child != NULL)
          {
            wattron(cmd_win,A_ALTCHARSET);
            waddch(cmd_win,ACS_DIAMOND);
            wattroff(cmd_win,A_ALTCHARSET);
/*
            waddch(cmd_win,'*');
*/
          }

        if (ptr == cur_func)
          mvwaddstr(cmd_win,1,0,ptr->func_string);

        pos += len + 2;
        ptr = ptr->next;
        display_count++;
      }
    wmove(cmd_win,1,0);
    wrefresh(cmd_win);

    return (0);
  }

int update_cmd_pointers()
  {
    int pos;
    int len;
    struct SCfunc_st *ptr;

    pos = 0;
    display_count = 0;
    ptr = first_func;
    while (ptr != NULL)
      {
        len = strlen(ptr->func_symb);
        if (len + pos >= 79)
          break;
        last_func = ptr;
       
        pos += len + 2;
        ptr = ptr->next;
        display_count++;
      }
    return (0);
  }

void Signal_function(sig)
int sig;
  {
    if(SCdebug)
    fprintf (SCconsole, "Received Signal %d\n", sig);
    if (sig != 13)
        {
        endwin();
        printf ("Received Signal %d\n",sig);
        nfm_exit ();
        exit(1);
        }
   if(SCdebug)
   {
    fprintf (SCconsole, "---- SIGPIPE Received Signal %d !!!!!!!!!!!\n", sig);
    fprintf (SCconsole, "---- SIGPIPE Received Signal %d !!!!!!!!!!!\n", sig);
    fprintf (SCconsole, "---- SIGPIPE Received Signal %d !!!!!!!!!!!\n", sig);
   }
    return; /* changed from return(0) as the function is void - vasu */
  }

int check_for_function(ptr,name,match_ptr,count)
struct SCfunc_st *ptr;
char *name;
struct SCfunc_st **match_ptr;
int *count;
  {
    *count = 0;
    while (ptr != NULL)
      {
        if (!strncmp_ignore_case(ptr->func_symb,name,strlen(name)))
          {
            *match_ptr = ptr;
            (*count)++;
          }
        ptr = ptr->next;
      }
    return (0);
  }

int execute_func()
  {

    int top,mid,bot;
    struct SCfunc_st *temp;
    int status;

    if (SCdebug)
      fprintf(SCconsole,"Entering execute_func()\n");

    if (cur_func->func_name != NULL)
      {
/*
        if (!strcmp(cur_func->func_name,"EXIT"))
          {
            if (cur_func->parent != NULL)
              {
                first_func = cur_func->parent_first_func;
                cur_func = cur_func->parent;
                return;
              }
            else
              {
                status = nfm_exit ();
                endwin();
                exit(0);
              }
          }
*/

        if (!strcmp(cur_func->func_name,"EXIT"))
          {
          first_func = cur_func->parent_first_func;
          cur_func = cur_func->parent;
          return (0);
          }
        else if (!strcmp(cur_func->func_name, "LOGOUT")) 
          {
          /* EXIT PROGRAM */
          /* KT - function to exit from requestor */
          status = nfm_exit ();
          endwin();
          exit(0);
          }

        if (SCdebug)
          fprintf(SCconsole,"Checking for %s\n",cur_func->func_name);
        bot = 0;
        top = SCatofn_count - 1;
        while (top > bot)
          {
            mid = (top + bot)/2;
            if (SCdebug)
              {
                fprintf(SCconsole,"Comparing with %s\n",SCatofn[mid].name);
              }
            if (strcmp(cur_func->func_name,SCatofn[mid].name) > 0)
              bot = mid + 1;
            else
              top = mid;
          }
        if (strcmp(cur_func->func_name,SCatofn[top].name) == 0)
          {
            if (SCdebug)
              fprintf(SCconsole,"function found -> <%s>\n", SCatofn[top].name);
            (*(SCatofn[top].fn_ptr))();
            touchline(stdscr,5,19);
            refresh();
          }
        else
          {
            if (SCdebug)
              fprintf(SCconsole,"function not found\n");
            sprintf(string,"Function <%s> not found\n",cur_func->func_name);
            SCdisplay_msg(string);
          }
        keyin_count = 0;
      }
    if (cur_func->child != NULL)
      {
        temp = cur_func->child;
        while (temp != NULL)
          {
            temp->parent = cur_func;
            temp->parent_first_func = first_func;
            temp = temp->next;
          }
        first_func = cur_func = cur_func->child;
        update_cmd_win();
        keyin_count = 0;
      }
    return (0);
  }
