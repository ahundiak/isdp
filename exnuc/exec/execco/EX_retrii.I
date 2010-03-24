class implementation EX_retri;

#include "exsysdep.h"
#include <stdio.h>
#include <OMerrordef.h>
#include <UNIXerrdef.h>
#include <string.h>
#ifdef ENV5
#include <tools.h>
#endif
#include <exdef.h>
#include <ex.h>
#include <expriv.h>
#include <exmacros.h>
#include <execmsg.h>
#include <EXproduct.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <igewindef.h>
#include <igewinmacros.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifndef NT
/*helpnt*/
#include <sys/param.h>
#endif
#include <DItypedef.h>
#include <DIdef.h>
#include <DIglob.h>
#include <DIprims.h>
#include <OMOSfilehdr.h>
#include <exproto.h>
#include <FI.h>
#include <dload.h>

#include "exudata.h"

#ifdef SUNOS5
%undef sleep
#endif
from module import mod_init,wake_up,sleep,execute_mod,GRmd_deactive,GRmd_active, mod_info;
from cmdserver import wakeup_cs;
from OMFiledOS import set_state,write;

#define debug  0
#define tabledebug  0
#define EX_RETRIEVE_TYPE 1

%safe
static int (*EX_call_function_on_retrieve)() = 0;
static int first = 1;
static int first_menu = 1;
static int have_file = 0;
static char mloc_file_name[257];
%endsafe

/*helpnt*/
extern int FEI_set_form_icon_path();
extern int Help_active();
extern int Help_remove();
extern OMuint  OM_Gf_fileLocking;
extern struct OM_sd_lockFiles **OM_GA_lockFiles;
extern struct OM_sd_lockFileRec *OM_Gp_lockFileRec;
extern int     som_modifyAccess();
extern int EX_process_unknowns;
extern int EX_use_mloc;
#ifdef X11
extern int EX_DefaultIOError ();
#endif
extern struct module_params **module_data;
extern struct EX_visible_module *module_table;
extern struct EX_invisible_module *invisible_table;
extern OM_S_OBJID EX_exec_id;
extern OM_S_OBJID EX_cmdserver_id;
extern char EX_filename[];
extern char EX_seedfile[];
extern char EX_runname[];
extern int  EX_mod_type;
extern int  EX_create;
extern struct EX_global EX_global_var;
extern struct EX_cmd_cntrl *EX_cmdlist_ptr;
extern uword EX_ACTINV_OS_num;
extern uword EX_dup_os_occured;
extern int no_modules;
extern char *getenv();
extern int EX_help_proc_exist;

typedef void (*p_function)();
void EXstatus_display_button(int on)
{
static p_function p_real_func = NULL;
if (p_real_func == NULL)
#if defined (SUNOS) || defined (CLIX)
    p_real_func = (p_function)dload_address_lookup("_GRstatus_display_button");
#else
    p_real_func = (p_function)dload_address_lookup("GRstatus_display_button");
#endif
if (p_real_func)(*p_real_func)(on);
}

void EX_construct_and_display_menus()
{
    Form  menu_ptr;
    Form  panel_ptr;
    int status;
    char *use_mloc;

    if (ex$is_interactive())
    {
        /******************************************************/
        /*     see if user wants mloc to be used              */
        /******************************************************/
        if ( have_file )MS_save_locations(mloc_file_name);
        use_mloc = getenv("EX_SCREEN_MENUS");
        if (use_mloc)
            {
                EX_use_mloc = atoi(use_mloc);
            }
        if ( EX_use_mloc )
        {
            /*this must be done every time because we may have done
                                         a switch product*/
            EX_get_mloc_file(mloc_file_name,&have_file);
            MS_set_startup_file(mloc_file_name);
            first_menu = 0;     /*after the first ret they may have
                                  moved the menus*/

        }


        /******************************************************/
        /*     construct menu                                 */
        /******************************************************/
        MS_delete_menus();
        MS_init_menus();
        if (!have_file)
        {
            status = FI_get_form_by_name ( "BAR_MENU", &menu_ptr );
            status = FI_get_form_by_name ( "PANEL_MENU", &panel_ptr );
            if (status == FI_SUCCESS)
            {
                int  width, height, x, y, panel_x, panel_y;
                int  xdecor, ydecor, xoffset, yoffset;

                /* find out how much window manager decoration to account for */
    
                EXget_form_offset ( &xoffset, &yoffset );
                EXget_form_decoration ( &xdecor, &ydecor );

                /* position the panel menu at the right edge of the screen */
 
                EXposition_form ( panel_ptr, EX_RIGHT_EDGE );
   
                /* move the panel menu just below the message strip */

                FIf_get_location ( panel_ptr, &x, &y );
                panel_x = x + xoffset;
                panel_y = 55 + (ydecor * 3) - yoffset;
                FIf_set_location (panel_ptr, panel_x, panel_y );

                /* position the menu bar below the message strip */

                FIf_get_location ( menu_ptr, &x, &y );
                y = 55 + (ydecor * 3) - yoffset; /* ydecor * 2 for overlap */

                /* slide the bar over against the panel menu */

                FIf_get_size ( menu_ptr, &width, &height );
                x = panel_x - width - (xdecor * 2);
                FIf_set_location ( menu_ptr, x, y );
            }
        }
        if((EX_use_mloc) && (!have_file))
        { 
            have_file = 1;
            MS_save_locations(mloc_file_name);
        }
        MS_display_menus();
    }
}

void retrieve_error(msgn,string,response)
int msgn;
char *string;
int *response;
{
    int myresp;
    long mmsg;
    long pos;
    if (msgn)
        /*output invalid message*/
        ex$message(msgnumb = msgn,type ="%s%",
                   var=string);
    /*setup exit for cmdserver*/
    myresp = EX_CMDSVR_RETURN;
    ex$putque( msg = &mmsg,    pos=FRONT,
              response=&myresp );
    *response = CLEAR_STACK;
    EX_create = FALSE;
    string[0] = 0;
}

int EX_set_up_full_path_for_filename(string)
char *string;
{
/*this routine will take filename and create the full path while
  testing for max file name limits*/
char new_string[OM_K_MAXOSNAME_LEN];
char *tttmp;
int retcode;
  retcode = 1;
  if (string[0] != '/' )
  {
   strcpy(new_string,string);
   if( EX_use_default_dir() )
     {
      strcpy(string , EX_global_var.working_dir);
     }
   else
     {
      tttmp = getenv("PWD");
      if( tttmp == NULL )
         strcpy( string, "." );
      else
         strcpy(string,tttmp);

      strcat(string,"/");
     }
   if ( (strlen(string) + strlen(new_string)) >
                                    OM_K_MAXOSNAME_LEN - 1)
    {
      retcode = EX_F_MaxPathFilename;
      return (retcode);
    }
  else
     strcat(string,new_string);
  }/*end if string did not start with slash*/
  else
  {
         /*did start with a slash check to see it is not too long*/
   if ( strlen(string)  >  OM_K_MAXOSNAME_LEN - 1)
      {
      retcode = EX_F_MaxPathFilename;
      return (retcode);
      }
  }

/*filename can still only be 14*/
  tttmp = strrchr(string,'/'); /* get the real file name */
               if (strlen(tttmp+1) > 14 )
               {
                retcode = EX_F_MaxFileName;
                return (retcode);
               }


return (retcode);
}

int EX_invalid_char_in_filename(inputstring)
char *inputstring;
{
   int goodfile;
   char *spacebar;
   /*test for invalid characters*/
   goodfile = 1;

   spacebar = strchr (inputstring,':');
   if ( spacebar )goodfile = 0;

   spacebar = strchr (inputstring,'\\');
   if ( spacebar )goodfile = 0;

   spacebar = strchr (inputstring,' ');
   if ( spacebar )goodfile = 0;

   spacebar = strchr (inputstring,'+');
   if ( spacebar )goodfile = 0;

   spacebar = strchr (inputstring,'*');
   if ( spacebar )goodfile = 0;

   spacebar = strchr (inputstring,'-');
   if ( spacebar )goodfile = 0;

   spacebar = strchr (inputstring,'?');
   if ( spacebar )goodfile = 0;

   spacebar = strchr (inputstring,'[');
   if ( spacebar )goodfile = 0;

   spacebar = strchr (inputstring,']');
   if ( spacebar )goodfile = 0;
   return (goodfile);
}

/************************************************************/

/*
 *  This code was added because display list needs to know
 *  if we've retrieved a file. Mike Lanier (11/18/96)
 */

%safe
static int      weve_retrieved_a_file = 0;
%endsafe

void    WereRetrieving() { weve_retrieved_a_file = 1; }

int	WeveRetrieved() 
   { 
   int i;

   /*
    *  clear the flag after it has been looked at so that we don't
    *  act on the contents twice.
    */

   i = weve_retrieved_a_file;
   weve_retrieved_a_file = 0;
   return i;
   }

/************************************************************/
method execute(int *response; char *response_data; int pos    )
{
   static  int first =1;
   int prompt_status;
   OM_S_OBJID filed_id;
   OM_S_OBJID dum_id;
   struct construct_args
   {
      char           *s_name;        /* pointer to name string */
      OMuint         i_initsize;     /* NULL =>use default */
      int            i_extsize;      /* negative number => no extension */
      OMuint         i_init_number_objects; /* NULL =>use default */
      int            i_extcount;     /* negative number => no extend total
                                        object count */
      OMuint         i_number_objs;  /* number of objects in space after
                                        construct. 1=> "fresh OS" */
   } os_args;
   int status,i,j,result,new_module;

   uword os_num;
   char     string[OM_K_MAXOSNAME_LEN],
   tmp_file[OM_K_MAXOSNAME_LEN];


   char  *tmp_string;
   char *tttmp;
   char na_me[100];
   int  EX_seed_file_found;
   int  EX_file_read_only;
   int  tmp_stat;
   int  notfound;
   int  retri_goahead;
   IGRlong mmsg;
   int rmsg;
   int goahead;
   long num_byte;
   char yes[128];
   char no[128];
   int goodfile;

   int save_flag = 0;/*flag sent to close visible 1 for save,0 nosave */

   WereRetrieving();

   /*   EXstatus_display_button(1);hilite options button does not work*/

   os_args.s_name = NULL;                /* pointer to name string */
   os_args.i_initsize = 0;            /* NULL =>use default */
   os_args.i_extsize = 0;             /* negative number=>no extension */
   os_args.i_init_number_objects = 0; /* NULL =>use default */
   os_args.i_extcount = 0;            /* negative number => no extend
                                               total object count */
   os_args.i_number_objs = 0;         /* number of objects in space after
                                              construct. 1=> "fresh OS" */

   /*********************************/
   /***     RETRIEVE           ******/
   /*********************************/
#ifdef TIMING_TEST
   EX_start_timing();
#endif

   EX_seed_file_found = 0;
   EX_file_read_only  = 0;
   retri_goahead = 1;

   if( first == 1 )
   {
      if( ex$is_interactive() )
      {
         EX_end_copyright();
#ifdef X11
         XSetIOErrorHandler(EX_DefaultIOError );
#endif
      }
      first = 0;
   }

   ex$message(msgnumb = EX_P_Yes,buff = yes);
   ex$message(msgnumb = EX_P_No,buff = no);

   for(i=0; i<EX_MAX_MODULES; i++)
   {
      if (module_table[i].obj_space_num == 0) break;
   }

/***************************close file code************************/

   if( i > 0 ) /* we have a opened file, close it */
   {
    /* bbkr - TR#119700213 */
     exUDataActref rfact;
     status = exRecvUData(EX_UDATA_ACTREF, (char *)&rfact);
     if (rfact.aflag)
     {
       ex$message(in_buff = "Deactivate the Activated Part",
                  field = ERROR_FIELD,
                  seconds = MS_SLEEP_TIME);
       status = ex$clear_event_queue ( );
       *response = TERMINATE;
       response_data[0]='\0';
       return(1);
     }

      /*      UI_message("Retrieve / Close existing file first");*/
      ex$message(msgnumb = EX_M_RetrClose);
      goahead = FALSE;
      retri_goahead = FALSE;
      strcpy(tmp_file,
      module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);
      do
      {
         prompt_status = ex$create_prompt(message_no = EX_P_Save,
             left_prompt = EX_P_Yes,
             right_prompt = EX_P_No,
             string = tmp_file,
             response = response,
             response_data = response_data);

         if(*response == RESET)
         {
            response_data[0] = '\0';
            EX_init_keyboard();
            UI_echo(" ");
         }
         else if( *response == STRING )
         {
            if ( prompt_status == EX_LEFT_MATCH )
            {
               /*the answer is yes to save all files*/

               if( module_table[active_module_num].permis_flag == EX_read_only)
               {
                  na_me[0]='\0';
                  strcpy(na_me,module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);
                  ex$message(msgnumb = EX_S_Var1, type="%s",var=na_me);
                  ex$message(msgnumb = EX_F_UseSaveas);
                  *response = TERMINATE;
               }
               else
               {
                  save_flag = 1;
                  goahead = TRUE;
                  retri_goahead = TRUE;
               }
            }/*end if ans 'y'*/
            else if (prompt_status == EX_RIGHT_MATCH )
            {
               save_flag = 0;/*nosave*/
               goahead = TRUE;
               retri_goahead = TRUE;
            }
            else
            {
               num_byte = strlen(response_data) + 1;
               status = ex$putque( msg = &mmsg,
                   pos=FRONT,
                   response=response ,
                   byte=&num_byte,
                   buffer=response_data );
            }
         }
         else if( (*response == CMD_STRING ) ||
             (*response == EX_CMD_KEY ) )
         {
            num_byte = strlen(response_data) + 1;
            status = ex$putque( msg = &mmsg,
                pos=FRONT,
                response=response ,
                byte=&num_byte,
                buffer=response_data );
         }
      } while( *response == RESET );/*end prompt save file*/
      if( goahead )
      {
        ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
        ex$message(msgnumb = EX_S_CloseInProg);


         /* close visible will send clear stack message to command server */
         /* so we need to inform cmdserver not to delete this retrieve cmd*/
        EX_cmdserver_save_last_cmd();
        retri_goahead = close_visible(save_flag, my_id);
                                       /*1 for save,0 for nosave*/
        if (retri_goahead == 1) /*close_visible a success*/
        {        

         for( j=EX_MAX_MODULES - 1; j >= 0;j--)
         {
            if (module_table[j].obj_space_num != 0)
            {
               if(active_module_num==(EX_MAX_MODULES - 1)) active_module_num = (-1);

               active_module_num = j;
               EX_active_module = module_table[active_module_num].module_my_id;
               EX_active_OS_num = module_table[active_module_num].obj_space_num;
               EX_ACTINV_OS_num = EX_active_OS_num;

               tttmp = strrchr( module_data[module_table[active_module_num].obj_space_num]->CS_OS_name, '/');
               strcpy(EX_global_var.filename, tttmp + 1 );

               status=om$send(mode = OM_e_wrt_object,
                   msg = message module.GRmd_active(),
                   senderid = my_id,
                   targetid = module_table[active_module_num].module_my_id,
                   targetos = module_table[active_module_num].obj_space_num);

               check_error_status(status,
                   "IN EXEC wake_up (module.active) error");
               break;
            }
         }
         if ( EX_help_proc_exist == 1 )
         {
            int help_active_flag;

            Help_active(&help_active_flag);
            if (help_active_flag == 1)
            {
               Help_remove();
            }
         }
       }/*end if close_visible a success*/
      }/*end if goahead*/
      ex$message(msgnumb = EX_S_Clear);
   }/*end if have a file open close it*/

/******************* end close file code **************************/

   if( retri_goahead != TRUE )
   {
      *response = TERMINATE;
      EX_create = FALSE;
      return(OM_S_SUCCESS);
   }

   for(i=0; i<EX_MAX_MODULES; i++)
   {
      if (module_table[i].obj_space_num == 0) break;
   }
   if ( i < EX_MAX_MODULES && retri_goahead)
   {
      do
      {  /******* while response_data == n ******/
         if ( EX_filename[0] == '\0')
         {
            do /*  get file name from operator */
            {
               ex$message(msgnumb = EX_M_RetrFile);
               ex$message(msgnumb = EX_S_StatusDisplay);
               ex$message(msgnumb = EX_P_InputFileName,
                   justification = RIGHT_JUS);
               EX_get_input(response,response_data,0);
               if( *response == RESET )
               {
                  response_data[0] = '\0';
                  EX_init_keyboard();
                  UI_echo("");
                  string[0] = '\0';
               }
               else if( *response == D_RESET )
               {
                  response_data[0] = '\0';
                  EX_init_keyboard();
                  UI_echo("");
                  ex$message(msgnumb = EX_S_Clear);
                  string[0] = '\0';
                  break;
               }
               else if( *response == STRING )
               {
                  ex$message(msgnumb = EX_S_Clear);
                  tmp_string = response_data;
                  string[0] = '\0';
                  strcpy(string,tmp_string);
               }
               else if(( *response == STATUS_DISP ) ||
                    (( *response == EX_CMD_KEY ) &&
                      (!(strcmp(response_data,"GRStFr")))))
               {
                  status = ex$file_form(title = "Retrieve Options",
                      returned_filename = string,
                      seedfile = EX_seedfile,
                      form_type = EX_RETRIEVE_FILE_FORM,
                      response = response,
                      response_data = response_data);
                  if ( *response != EX_FORM_FINISHED )
                  {
                    /*expect it to be FORM_FINISHED*/
                     /* CAN NOT STACK RETRIEVE COMMAND,
                     SINCE THERE IS NO MODULE FOR ANY OPERATION */
                     retrieve_error(0,string,response);/*set up error*/
                     break;   /* at this point no module */
                  }

                  else 
                  {
                    /*was form finished see if name is in string*/
                     ex$message(msgnumb = EX_S_Clear);
                     if ( string[0] != 0 )
                      {
                       *response = STRING;
                       break;
                      }
                    else
                      {
                      /*no filename given go back to prompt*/
                      retrieve_error(0,string,response);/*set up error*/
                      break;   /* at this point no module */

                      }
                  }

               }
               else
               {
                  /* CAN NOT STACK RETRIEVE COMMAND,
               SINCE THERE IS NO MODULE FOR ANY OPERATION */
                  retrieve_error(0,string,response);/*set up error*/
                  break;   /* at this point no module */
               }
            }/*end do get input */               while(string[0]=='\0');
            /*--------------------*/
         }/*end if EX_filename == 0*/
         else /* get file name from command line argument */
         {
            strcpy(string,EX_filename);
            EX_filename[0] = '\0';
            *response = STRING;
         }
/**** you now have filename in string by keyin,form, or command line***/
/******* or it is a null telling you to exit *************************/

/* The filename is first checked for invalid characters  - jeff */

         goodfile =  EX_invalid_char_in_filename(string);
         if (!goodfile)
             {
             retrieve_error(EX_F_InvalidFilename,string,response);
                                                   /*set up error*/
             }


        if ( EX_call_function_on_retrieve )
         {
         status = (*EX_call_function_on_retrieve)(string);
         if ( !status )
           {
             retrieve_error(0,string,response);
             return (OM_S_SUCCESS);
           }
         }
/* This code must be there before the translate related fucntion is called
   so that all  files with invalid filenames are not processed - jeff

         goodfile =  EX_invalid_char_in_filename(string);
         if (!goodfile)
             {
             retrieve_error(EX_F_InvalidFilename,string,response);
                                                   
             }
*/

         if((*response != STRING) || (string[0] == '\0'))break;


         ex$message(msgnumb = EX_S_RetrInProg);
         status = EX_set_up_full_path_for_filename(string);
         if (status == EX_F_MaxPathFilename)
         {
             retrieve_error(EX_F_MaxPathFilename,string,response);
             return(OM_S_SUCCESS);
         }

         if (status == EX_F_MaxFileName)
         {
             retrieve_error(EX_F_MaxFileName,string,response);
             return(OM_S_SUCCESS);
         }


         /* put y in response_data          */
         ex$message(msgnumb = EX_P_Yes,buff = response_data);

         result = EX_check_file(string,TRUE);
         /*result == 0 file is there or can be created there*/
         if ( result > 1 ) /* error occured */
         {
            ex$message(msgnumb = result,justification=LEFT_JUS,time=4);
            /*              strcpy(response_data,"n");*/
            ex$message(msgnumb = EX_P_No,buff = response_data);
         }
         if ( result == 1 )
         {
            /*        strcpy(response_data,"n");*/
            ex$message(msgnumb = EX_P_No,buff = response_data);
            printf(" retrieve file ( file name generic error)\n");
         }

         if (result < 0)  /* file is not on disk */
         {
            /* check if in master file table */
            int kkkk;

            notfound = TRUE;
            for(i = 0; i< EX_MAX_MODULES && notfound ; i++)
            {
               kkkk = module_table[i].obj_space_num;
               if( module_data[kkkk] && !strcmp(module_data[kkkk]->CS_OS_name,
                   string ))   /* same name */
               {
                  notfound = FALSE;
                  ex$message(msgnumb = EX_F_FileCurOpen);
                  string[0] = '\0';
               }
            }
            /* check if in invisible table */
            for(i=0; ((i<EX_MAX_INVIS_MODULES)    &&
                (invisible_table[i].obj_space_num!=0));i++)
            {
               if( module_data[invisible_table[i].obj_space_num] &&
                   !strcmp(module_data[invisible_table[i].obj_space_num]->CS_OS_name,
                   string ))   /* same name */
               {
                  notfound = FALSE;
                  ex$message(msgnumb = EX_F_FileCurOpen);
                  string[0] = '\0';
               }
            }

            if ( string[0] != '\0')
            {
               ex$message(msgnumb = EX_S_Var1, type="%s",var=`string`);
               if( EX_create != TRUE ) /* from command line */
               {
                  ex$message(msgnumb = EX_M_RetrFile);
                  do
                  {
                     do
                     {
                        prompt_status = 
                            ex$create_prompt(message_no = EX_P_FlNotExst,
                            left_prompt = EX_P_Yes,
                            right_prompt = EX_P_No,
                            response = response,
                            response_data = response_data);



                        if (*response == RESET)
                        {
                           response_data[0] = '\0';
                           UI_echo("");
                           EX_init_keyboard();
                        }
                        else if (*response == D_RESET)
                        {
                           response_data[0] = '\0';
                           UI_echo("");
                           EX_init_keyboard();
                           string[0] = '\0';
                           ex$message(msgnumb = EX_S_Clear);
                           break;
                        }
                       else if ( *response == STRING )
                        {
                        if ( prompt_status == EX_LEFT_MATCH )
                         {
                         ex$message(msgnumb = EX_P_Yes,buff = response_data);
                         }
                        else
                         {
                         ex$message(msgnumb = EX_P_No,buff = response_data);
                         }
                        }
                     }/*end while file does not exist*/ 
                     while( (*response != STRING) || ((response_data[0] == '\0') ||
                         (response_data[0] == ' ')));
                     /*----------------------------------*/
                     if(*response == D_RESET) break;
                  }           while(prompt_status == EX_NO_MATCH);
                  /*-------------------------------------*/
               }
               else /* EX_create set in command line */
               {
                  EX_create = FALSE;
                  /*          strcpy(response_data,"y");*/
                  ex$message(msgnumb = EX_P_Yes,buff = response_data);
               }
               ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
               if( !(strcmp(response_data,yes)) )
               {
               if ( EX_seedfile[0] != 0 )
               {
               int nbytes;
               char *seedptr;
                seedptr =  strrchr(EX_seedfile,'/');
                if (seedptr)
                 {
                 seedptr++;
                 nbytes = strlen(seedptr);
                 }
                else
                 nbytes = strlen(EX_seedfile);
                 if ( nbytes > 14)
                  {
                  retrieve_error(EX_F_MaxFileName,EX_seedfile,response);
                  return(OM_S_SUCCESS);
                  }
                }



                  EX_seed_file_found = EX_get_seed_file( EX_seedfile,tmp_file );
               }
            }
         }/*end file not on disk*/
         /* file exist give it to application
         prompt for confirm                */
      } while(!(strcmp(response_data,no)));/*stay till get filename*/


      if(string[0] != '\0')
      {

         os_args.s_name = ( EX_seed_file_found ) ? tmp_file : string;
         ex$message(msgnumb = EX_S_SysInit);
         ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
         EX_dup_os_occured = 0;
         strcpy(na_me, ":");
         tttmp = strrchr(string,'/'); /* get the real file name */
         strcat(na_me,tttmp+1);

         status = om$construct_os(classname = "OMFiledOS",
             osnum = &os_num,
             p_objid = &filed_id,
             osname = os_args.s_name,
             resultcount = &os_args.i_number_objs,
             sameosflag = 1,
             di_logical = na_me );
         if ( !( status & 1))ex$message(msgnumb = EX_S_Clear);

         if( (status == OM_I_READ_FROM_FILE) ||
             (status == OM_I_READ_FROM_RO_FILE) )
         {
            new_module =  0 ;
         }
         else
         {
            new_module = 1;
         }
         if( status == OM_I_READ_FROM_RO_FILE)
         {
            if( EX_seed_file_found != 1 )
            {
               ex$message(msgnumb = EX_F_ReadOnly);
               EX_file_read_only = 1;
            }
         }

         if(status == OM_W_OBJSPACE_EXISTS)
         {
            ex$message(msgnumb = EX_F_FileCurOpen);
            string[0] = '\0';
            *response = -1;
         }
         else if( status == UNIX_E_ENOENT )
         {
            ex$message(msgnumb = EX_S_Var1,type="%s",var=os_args.s_name);
            ex$message(msgnumb = EX_F_NoFileDir);
            string[0] = '\0';
            *response = -1;
         }
         else if( status == OM_E_INACCESSABLE_FILE )
         {
            printf(" In EXEC construct_os \n");
            result = EX_check_file(os_args.s_name,TRUE);
            if ( result > 1 ) ex$message(msgnumb = result,justification=LEFT_JUS,time=4);
            if ( result == 1 ) printf(" generic error\n");
            string[0] = '\0';
            *response = -1;
         }
         else if (status == OM_F_VERSION_MISMATCH)
         {
            ex$message( msgnumb = EX_F_VerErr );
            string[0] = '\0';
            *response = -1;
         }
         else if (status ==  OM_E_NODYNMEM )
         {
            ex$message( msgnumb = EX_F_NoDynMem );
            printf("retrieve file : no dynamic memory available\n");
            printf("clean up ipc structures /or expand swap space\n");
            string[0] = '\0';
            *response = -1;

         }
         else if( 1 & status )
         {


            tmp_stat = 1;
            if( EX_seed_file_found )
            {
               if (OM_Gf_fileLocking)
               {
                  /* The seed file must not be locked to any user.
                   * Always make sure its lockfile access is READ.
                   * Have to change it before changing the osname
                   * or we won't know which lockfile to change.
                   */
                  sprintf(OM_Gp_lockFileRec->osnum, "%5d", os_num);
                  som_modifyAccess(OM_GA_lockFiles[os_num]->name, 'R');
               }
               status=om$change_os_name( osnum = os_num,
                   new_osname = string,
                   overwrite = OM_e_overwrite);
               if( !( 1 & status) )
               {
                  tmp_stat = 0;
                  om$report_error(sts = status);
                  if( status == OM_W_ISODIRONOS)
                  {
                     printf("Seed file can not have iso in it");
                  }
               }
            }
            if( tmp_stat )
            {
               tttmp = strrchr(string,'/');
               strcpy( EX_global_var.filename,tttmp+1);
               EX_init_rec_echo(tttmp+1);
               EX_construct_and_display_menus();
               status = EX_module_construct( &rmsg, os_num,
                   filed_id, new_module,
                   EX_file_read_only, 1, &dum_id );
               if( status == 0)
               {
                  if ( rmsg == EXe_cell )
                  {
                   retrieve_error(0,string,response);
                                                   /*set up error*/
                  }
                  else
                  *response = EX_EXIT;
               }
               else
               {
                  if (EX_dup_os_occured )
                     ex$message(msgnumb = EX_F_DupIntOSName);
                  *response = CLEAR_STACK;
               }
            }
         }
         else
         {
            printf("Can not construct object space\n");
            om$report_error(sts=status);
            *response = -1;
         }
      }
   } /* end if(i<EX_MAX_MODULES) */
   else
   {
      ex$message(msgnumb = EX_F_MaxModule);
   }

   EX_create = FALSE;
   return(OM_S_SUCCESS);
} /* method retrieve execute */




#if defined( __STDC__ )
int EX_module_construct( int *msg, uword os_num, OM_S_OBJID filed_id,
                         int new_module, int read_only, int activate,
                         OM_S_OBJID *mod_id )
#else
int EX_module_construct( msg, os_num, filed_id,
                         new_module, read_only, activate,
                         mod_id )
int *msg;
uword os_num;
OM_S_OBJID filed_id;
int new_module;
int read_only;   /* read_only = 1 means read only */
int activate;    /* make new module as currently active module */
OM_S_OBJID *mod_id;
#endif
{
   int  tmpslot=0; /* tempapory module table slot number */
   int  init_success;
   int  status;
   int  numof_supers=0;
   int  deact_flag;
   int  type_of_mod;
   int  retstat;
   OM_S_OBJID module_id;
   char cmdsvr_class[13],module_class[13],*listof_supers=NULL;
   char pathn[128];
#ifndef NT
   IGRlong ret_msg;
#endif
   retstat = 1;
   init_success = 1;
   if( msg ) *msg = EX_succ;

   if(new_module)
   {
      status = get_modtype_data(EX_runname,NULL, module_class, NULL,NULL,NULL );
      if( ! (1&status))
      {
         printf("<%s> not found in product_data file\n",EX_runname);
         printf("can not get the module class name\n");
         retstat = 0;
         if( msg ) *msg = EXe_module_class;
      }
      else
      {
         status = om$construct(osnum = os_num,
             classname = module_class,
             p_objid = &module_id,
             neighbor = OM_GS_NULL_NEIGHBOR);
         if ( !( 1& status))
         {
            printf("IN EXEC module_construct (module.construct) error %s",module_class);
            init_success = 0;
            retstat = 0;
            om$report_error(sts=status);
            if( msg ) *msg = EXe_mod_construct;
         }
         else
         {
            /* set up tmpslot number for NOD to use               */
            /* we do not know whether init/wakeup are success     */
            /* or not, have to restore the tmpslot if not success */

            for(tmpslot = 0; ((tmpslot < EX_MAX_MODULES)
                && (module_table[tmpslot].obj_space_num != 0)); tmpslot++);
            module_table[tmpslot].obj_space_num = os_num;
            module_table[tmpslot].module_my_id = module_id;
            module_table[tmpslot].filed_id = filed_id;
            module_table[tmpslot].permis_flag = EX_read_write;
            module_table[tmpslot].no_scn_menu = 0;
            if ( activate )
            {
               EX_active_module = module_id;
               EX_active_OS_num = os_num;
               EX_ACTINV_OS_num = EX_active_OS_num;
            }
            strcpy(cmdsvr_class, "cmdserver");
            type_of_mod = -1;
            status = om$send(mode = OM_e_wrt_object,
                msg = message module.mod_init(
                type_of_mod,cmdsvr_class,numof_supers, listof_supers,1),
                senderid = EX_exec_id,
                targetid = module_id,
                targetos = os_num);
            check_error_status(status,
                "IN EXEC module_construct (module.init) error");
            if (! (1 & status))
            {
               init_success = 0;
               if( msg ) *msg = EXe_module_init;
            }
         }
      }
   } /* end of (if new_module)  */
   else
   {
#ifndef NT
     if (EX_process_unknowns)
       {
       if (EX_force_product_dload(&status) && status)
         {
              ms$init();
              FEI_set_form_icon_path();
              EX_cmddetach( &ret_msg , -1);
              ret_msg = om$send(mode = OM_e_wrt_object,
                msg = message cmdserver.wakeup_cs(),
                senderid = EX_exec_id,
                targetos = OM_Gw_TransOSnum_0,
                targetid = EX_cmdserver_id);
          }
        }
#endif
      status = di$give_pathname(osnum = os_num, pathname= pathn);
      if (! (1&status) )
      {
         printf("in Retrieve_Os get di path error osnum =<%d>\n",os_num);
         di$report_error(sts = status);
         return(0);
      }
      DIstrcat(pathn,"IGENOD");
      status = di$translate(objname = "MODULE" ,path=pathn, p_objid=&module_id);
      if (!(1&status))
      {
         di$report_error(sts=status, comment="IN EX_construct_module (translate module id) error");
         retstat = 0;
         init_success = 0;
         if( msg) *msg = EXe_module_id;
         return(0);
      }
      else
      {
         char app[20];
         status = om$send (msg = message module.mod_info(EX_INQ,NULL,0,app,20),
             senderid = module_id, targetid = module_id,targetos = os_num );
         if( !(1&status) )
         {
            om$report_error(sts = status);
            retstat = 0;
            init_success = 0;
            if( msg) *msg = EX_erro;
            return(0);
         }
         else
         {
            if ( !strcmp( app, "cell" ) )
            {
               ex$message(msgnumb = EX_E_CellAsMaster, seconds=180);
               printf("can not retrieve cell library as master file\n");
               status = om$send(mode = OM_e_wrt_object,
                   msg = message OMFiledOS.set_state(0),
                   senderid = EX_exec_id,
                   targetid = filed_id,
                   targetos = os_num);
               if (!(1 & status))
               {
                  printf("EX_module_construct (OMFiledOS.set_state) error\n");
                  om$report_error(sts = status);
               }
               else /* set state success */
               {
                  status = om$send(mode = OM_e_wrt_object,
                      msg = message OMFiledOS.delete(0),
                      senderid = EX_exec_id,
                      targetid = filed_id,
                      targetos = os_num);
                  if (!(1 & status))
                  {
                     printf("EX_module_construct (OMFiledOS.delete) error\n");
                     om$report_error(sts = status);
                  }
               }
               retstat = 0;
               init_success = 0;
               if( msg) *msg = EXe_cell;
               return(0);
            }
            else
            {
               /* set up tmpslot number for NOD to use               */

               for(tmpslot = 0; ((tmpslot < EX_MAX_MODULES)
                   && (module_table[tmpslot].obj_space_num != 0)); tmpslot++);
               module_table[tmpslot].obj_space_num = os_num;
               module_table[tmpslot].module_my_id = module_id;
               module_table[tmpslot].filed_id = filed_id;
               module_table[tmpslot].no_scn_menu = 0;
               if( read_only == 1)
               {
                  module_table[tmpslot].permis_flag = EX_read_only;
               }
               if ( activate )
               {
                  EX_active_module = module_id;
                  EX_active_OS_num = os_num;
                  EX_ACTINV_OS_num = EX_active_OS_num;
               }
            }
         }
      }
   }

   if(init_success)      *mod_id = module_id;
   if( (init_success) && activate )
   {
#ifdef TIMING_TEST
      EX_end_timing("Exec wake_up until mod.wakup");
#endif

      status=om$send(mode = OM_e_wrt_object,
          msg = message module.wake_up(EX_visible),
          senderid = EX_exec_id,
          targetid = module_id,
          targetos = os_num);
      check_error_status(status,
          "IN EXEC module_construct (module.wake_up) error");

      ex$message(msgnumb = EX_S_Clear);
      if ( (1&status))
      {
         /* send sleep to old module */
         if(module_table[active_module_num].obj_space_num != 0
             && tmpslot != active_module_num )
         {
            /* old module exists send deactive */
            /* same modtype do not deactivate menu */
            deact_flag = 1;

            status=om$send(mode = OM_e_wrt_object,
                msg = message module.GRmd_deactive(deact_flag),
                senderid = EX_exec_id,
                targetid = module_table[active_module_num].module_my_id,
                targetos = module_table[active_module_num].obj_space_num);
            check_error_status(status,
                "IN EXEC module_construct (module.deactive) error");
         }
         else
         {
            ;
#           if debug
            printf("\n old module does not exists \n");
#           endif
         }
         no_modules = 0;
         active_module_num = tmpslot;

         if(!no_modules)
         {
            EX_active_module = module_table[active_module_num].module_my_id;
            EX_active_OS_num =module_table[active_module_num].obj_space_num;
            EX_ACTINV_OS_num = EX_active_OS_num;
            EX_file_init_cmd( EX_cmdlist_ptr );
            if (ex$is_batch() && first)
               {
               /*this will be first thing executed it is filo*/
               first = 0;
               EX_session_init_cmd( EX_cmdlist_ptr );
               }
            EX_execute_mod();
         } /* if(!no_modules) */
      }
      else /* wake up failed restore tmpslot */
      {
         module_table[tmpslot].obj_space_num = 0;
         module_table[tmpslot].module_my_id = NULL_OBJID;
         module_table[tmpslot].filed_id = NULL_OBJID;
         module_table[tmpslot].permis_flag = EX_read_write;
         module_table[tmpslot].no_scn_menu = 0;
         retstat = 0;
         if (msg)
         {
            if( status == OM_E_NO_OS_AVAIL )
            {
               *msg = status;
            }
            else
            {
               *msg = EXe_module_wakeup;
            }
         }
      }
   }
   else /* init failed clean up tmpslot */
   {
      module_table[tmpslot].obj_space_num = 0;
      module_table[tmpslot].module_my_id = NULL_OBJID;
      module_table[tmpslot].filed_id = NULL_OBJID;
      module_table[tmpslot].permis_flag = EX_read_write;
      module_table[tmpslot].no_scn_menu = 0;
      retstat = 0;
      if(msg) *msg = EXe_module_init;

   }
   if(retstat) EX_call_firstcmd();
   return(retstat);
}


int
EX_get_seed_file( seedfile,temp_file )
char *seedfile;
char *temp_file;
{
   char   tmp_file[OM_K_MAXOSNAME_LEN];
   char new_string[OM_K_MAXOSNAME_LEN],  *curr_wd;
   char   fname[40];

   int result, status,i, seed_found;


   *temp_file = '\0';
   if ( seedfile[0] != '\0' )
   /* seed file name defined in command line */
   {
      if ( seedfile[0] == '/' ) /* use specified full path */
      {
         strcpy(tmp_file,seedfile);
         result = file_exists(tmp_file,0,0,new_string);
         if (result < 0) /* file not found */
         {
            return(0);
         }
         else
         {
            strcpy(temp_file,new_string);
            return(1);
         }
      }
      else
      {
         strcpy(fname, seedfile);
      }
   }
   else
   {
      strcpy(fname, "seed_file");
   }

   tmp_file[0] = '\0';
   curr_wd = getenv("PWD");
   if( curr_wd == NULL )
      strcpy( tmp_file, "." );
   else
      strcpy(tmp_file,curr_wd);

   strcat(tmp_file,"/");
   strcat(tmp_file,fname);
   status = file_exists(tmp_file,0,0,new_string);
   if( ( status >= 0) && EX_is_reg_file(new_string) ) /* file exists */
   {
      strcpy(temp_file,new_string);
      return(1); /* EX_seed_file_found = 1; */
   }
   else
   {
      seed_found = FALSE;
      status = TRUE;
      for(i=0;status == TRUE; i++)
      {
         if(status=ex$get_path(index=i,path=tmp_file,len=sizeof(tmp_file) ) )
         {
            strcat(tmp_file,"config/");
            strcat(tmp_file,fname);
            result = file_exists(tmp_file,0,0,new_string);
            if(( result >= 0) && EX_is_reg_file(new_string) ) /* file exists */
            {
               strcpy(temp_file,new_string);
               status = FALSE;
               seed_found = TRUE;
            }
         }
      }
      return(seed_found);
   }

}


int
EX_retrieve_module( msg,inputstring, seedfile, create, activate, save, osnum, modid)
int *msg;
char *inputstring; /* file name */
int create;   /* flag if create == 1, create if file is not exist already */
/*      if file is an old file, create flag will be ignored */
char *seedfile;/* name of seedfile to use */
int activate; /* flag if activate == 1, make the newly created module as  */
/*         the current active module                        */
int save;     /* flag if there is an existing file EXEC have to close it  */

/*      this flag tells EXEC whether to save the file or not*/
OMuword *osnum;
OM_S_OBJID *modid;
{
   OM_S_OBJID filed_id;
   OM_S_OBJID mod_id;
   struct construct_args
   {
      char           *s_name;        /* pointer to name string */
      OMuint          i_initsize;     /* NULL =>use default */
      int            i_extsize;      /* negative number => no extension */
      OMuint         i_init_number_objects; /* NULL =>use default */
      int            i_extcount;     /* negative number => no extend total
                          object count */
      OMuint         i_number_objs;  /* number of objects in space after
                          construct. 1=> "fresh OS" */
   } os_args;
   int status,i,result,new_module;
   int retstat;
   uword os_num;
   char     string[OM_K_MAXOSNAME_LEN],
   tmp_file[OM_K_MAXOSNAME_LEN];
   char *tttmp;
   char na_me[100];
   int  EX_seed_file_found;
   int  EX_file_read_only;
   int  tmp_stat;
   int  notfound;
   int  lastfile;
#ifndef NT
   struct stat fbuf;
#else
   struct _stat fbuf;
#endif
   FILE *fp;

   retstat = 1;
   if ( strlen(inputstring) > OM_K_MAXOSNAME_LEN -1)
       {
        ex$message(msgnumb = EX_F_MaxPathFilename,type ="%s%",
                                 var=inputstring);
        retstat = 0;
       }
   else if (strlen(seedfile) > OM_K_MAXOSNAME_LEN -1)
       {
        ex$message(msgnumb = EX_F_MaxPathFilename,type ="%s%",
                                 var=seedfile);
        retstat = 0;
       }

   else if  (!(EX_invalid_char_in_filename(inputstring)) ||(inputstring[0] == '\0'))
       {
        ex$message(msgnumb = EX_F_InvalidFilename,type ="%s%",
                                 var=inputstring);
       retstat = 0;
       }
   else
   {
      strcpy( string, inputstring );
      /*get full path and test for filename too long*/
      status = EX_set_up_full_path_for_filename(string);
      if ( status == EX_F_MaxPathFilename)
      {
        ex$message(msgnumb = EX_F_MaxPathFilename,type ="%s%",
                                 var=inputstring);
        retstat = 0;
      }

      else if (status == EX_F_MaxFileName)
      {
        ex$message(msgnumb = EX_F_MaxFileName,type ="%s%",
                                  var=inputstring);
        retstat = 0;
      }

    }
    if (!retstat)
       {

        if(msg) *msg = EXe_no_filename;
        return(retstat);
       }



   os_args.s_name = NULL;                /* pointer to name string */
   os_args.i_initsize = 0;            /* NULL =>use default */
   os_args.i_extsize = 0;             /* negative number=>no extension */
   os_args.i_init_number_objects = 0; /* NULL =>use default */
   os_args.i_extcount = 0;            /* negative number => no extend
                                               total object count */
   os_args.i_number_objs = 0;         /* number of objects in space after
                                              construct. 1=> "fresh OS" */

   /*********************************/
   /***     RETRIEVE           ******/
   /*********************************/

   EX_seed_file_found = 0;
   EX_file_read_only  = 0;
   notfound = TRUE;
   if(msg) *msg = EX_succ;
   for(i=0; i<EX_MAX_MODULES; i++)
   {
      if (module_table[i].obj_space_num == 0) break;
   }
   if( i > 0 )
   {
      EX_close1(&lastfile,save);
   }
   for(i=0; i<EX_MAX_MODULES; i++)
   {
      if (module_table[i].obj_space_num == 0) break;
   }

   if ( i < EX_MAX_MODULES)
   {

      result = EX_check_file(string,TRUE);
      retstat = 1;
      switch ( result )
      {
      case EX_S_BadDir:
         retstat = 0;
         if(msg) *msg = EXe_bad_dir;
         break;

      case EX_S_NotDir:
         retstat = 0;
         if(msg) *msg = EXe_not_dir;
         break;

      case EX_S_Access:
         retstat = 0;
         if(msg) *msg = EXe_access;
         break;

      case EX_S_NoLink:
         retstat = 0;
         if(msg) *msg = EXe_no_link;
         break;

      case EX_S_MultiHop:
         retstat = 0;
         if(msg) *msg = EXe_multihop;
         break;

      case EX_S_NoReadPerm:
         retstat = 0;
         if(msg) *msg = EXe_no_read_perm;
         break;

      case 1:
         retstat = 0;
         if(msg) *msg = EX_erro;

      default:
         break;
      }
      if( retstat == 0 ) return(retstat);
      if (result < 0)
      {
         /* check if in master file table */
         for(i = 0; i< EX_MAX_MODULES && notfound; i++)
         {
          if (module_table [i].obj_space_num)
           {
            if( !strcmp(module_data[module_table[i].obj_space_num]->CS_OS_name,
                string ))   /* same name */
            {
               notfound = FALSE;
               retstat = 0;
               if(msg) *msg = EXe_file_curr_open;
               return(retstat);
            }
           }
         }
         /* check if in invisible table */
         for(i=0; ((i<EX_MAX_INVIS_MODULES)    &&
             (invisible_table[i].obj_space_num!=0));i++)
         {
            if( !strcmp(module_data[invisible_table[i].obj_space_num]->CS_OS_name,
                string ))   /* same name */
            {
               notfound = FALSE;
               retstat = 0;
               if(msg) *msg = EXe_file_curr_open;
               return(retstat);
            }
         }


         if( create != TRUE ) /* from command line */
         {
            retstat = 0;
            if(msg) *msg = EXe_no_create;
            return(retstat);

         }
         else /* create set to true */
         {
            /* get seed file name */

#if defined (CLIX)
               if ( seedfile[0] != 0 )
               {
               int nbytes;
               char *seedptr;
                seedptr =  strrchr(seedfile,'/');
                if (seedptr)
                 {
                 seedptr++;
                 nbytes = strlen(seedptr);
                 }
                else
                 nbytes = strlen(seedfile);
                 if ( nbytes > 14)
                  {
                  retstat = 0;
                  if(msg) *msg = EXe_no_create;
                  return(retstat);
                  }
                }
#endif



            EX_seed_file_found = EX_get_seed_file( seedfile, tmp_file );
         }
      }
      /* else old file on disk */

      os_args.s_name = ( EX_seed_file_found ) ? tmp_file : string;
      strcpy(na_me, ":");
      tttmp = strrchr(string,'/');
      strcat(na_me,tttmp+1);

      status = om$construct_os(classname = "OMFiledOS",
          osnum = &os_num,
          p_objid = &filed_id,
          osname = os_args.s_name,
          resultcount = &os_args.i_number_objs,
          sameosflag = 1,
          di_logical = na_me);


      if( (status == OM_I_READ_FROM_FILE) ||
          (status == OM_I_READ_FROM_RO_FILE) )
      {
         new_module =  0 ;
         if(msg) *msg = EXi_read_from_file;
      }
      else
      {
         new_module = 1;
      }
      if( status == OM_I_READ_FROM_RO_FILE)
      {
         if( EX_seed_file_found != 1 )
         {
            EX_file_read_only = 1;
         }
         if(msg) *msg = EXi_read_from_RO_file;
      }

      if(status == OM_W_OBJSPACE_EXISTS)
      {
         retstat = 0;
         if(msg) *msg = EXe_os_exists;
      }
      else if( status == UNIX_E_ENOENT )
      {
         retstat = 0;
         if(msg) *msg = EXe_enoent;
      }
      else if( status == OM_E_INACCESSABLE_FILE )
      {
#ifndef NT
         result = stat(os_args.s_name,&fbuf);
#else
         result = _stat(os_args.s_name,&fbuf);
#endif
         if( result == -1 )
         {
            if (errno == ENOENT)
            {
               fp = (FILE *) fopen(os_args.s_name,"a");
               if( !fp )
               {
                  retstat = 0;
                  if(msg) *msg = EXe_bad_dir;
               }
               else
                  /* if we reached here, something went wrong. */
                  fclose(fp);
            }
            else if ( errno == ENOTDIR )
            {
               retstat = 0;
               if(msg) *msg = EXe_not_dir;
            }
            else if ( errno == EACCES )
            {
               retstat = 0;
               if(msg) *msg = EXe_access;
            }
#ifndef NT
            else if ( errno == ENOLINK )
            {
               retstat = 0;
               if(msg) *msg = EXe_no_link;
            }
            else if ( errno == EMULTIHOP )
            {
               retstat = 0;
               if(msg) *msg = EXe_multihop;
            }
#endif
         }
         else
         {
            fp = (FILE *) fopen(os_args.s_name,"r");
            if (!fp)
            {
               retstat = 0;
               if(msg) *msg = EXe_no_read_perm;
            }
            else
               /* if we reached here , something went wrong */
               fclose(fp);
         }
         string[0] = '\0';
      }
      else if (status == OM_F_VERSION_MISMATCH)
      {
         retstat = 0;
         if(msg) *msg = EXe_ver_mis;
      }
      else if( 1 & status )
      {
         tmp_stat = 1;
         if( EX_seed_file_found )
         {
            if (OM_Gf_fileLocking)
            {
               /* The seed file must not be locked to any user.
                * Always make sure its lockfile access is READ.
                */
               sprintf(OM_Gp_lockFileRec->osnum, "%5d", os_num);
               som_modifyAccess(OM_GA_lockFiles[os_num]->name, 'R');
            }
            status=om$change_os_name( osnum = os_num,
                new_osname = string,
                overwrite = OM_e_overwrite);
            if( !( 1 & status) )
            {
               tmp_stat = 0;
               retstat = 0;
               if(msg) *msg = EXe_change_name;
               om$report_error(sts = status);
               if( status == OM_W_ISODIRONOS)
               {
                  printf("Seed file can not have iso in it");
                  if(msg) *msg = EXe_iso_in_seed;
               }
            }
         }
         if( tmp_stat )
         {
            tttmp = strrchr(string,'/');
            strcpy( EX_global_var.filename,tttmp+1);

            retstat = EX_module_construct( msg,os_num,filed_id, new_module,
                EX_file_read_only, activate, &mod_id);
            *osnum = os_num;
            *modid = mod_id;
         }
      }
      else
      {
         retstat = 0;
         if(msg) *msg = EXe_os_construct;
         printf("Can not construct object space\n");
         om$report_error(sts=status);
      }

   } /* if(i<EX_MAX_MODULES) */
   else
   {
      if( msg) *msg = EXe_max_module;
      retstat = 0;
   }

   return(retstat);
} /* method retrieve execute */

EX_retrieve_function(function_to_execute,function_previous)
int (*function_to_execute)();
int (**function_previous)();
{
*function_previous = EX_call_function_on_retrieve;
EX_call_function_on_retrieve = function_to_execute;
return(1);
}

end implementation EX_retri;

