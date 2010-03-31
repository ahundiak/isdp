class implementation ECretriprt;

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
/*#include <dload.h>*/

#include "igetypedef.h"
#include "igrtypedef.h"
#include <gr.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "asmprtmac.h"
#include "asmfilemac.h"
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

#define EXTERN extern
#include "asmglobals.h"

#ifdef SUNOS5
%undef sleep
#endif
from module import mod_init,wake_up,sleep,execute_mod,GRmd_deactive,GRmd_active, mod_info;
from cmdserver import wakeup_cs;
from OMFiledOS import set_state,write;
from IGEwindow import clear;

#define debug  0
#define tabledebug  0
#define EX_RETRIEVE_TYPE 1

/*************************************************************************
These statics are of no use in this overridden command object, because
all these variables are set/used inside the functions defined in 
EX_retrii.I (the original retrieve command object implementation file)
%safe
static int (*EX_call_function_on_retrieve)() = 0;
static int first = 1;
static int first_menu = 1;
static int have_file = 0;
static char mloc_file_name[257];
%endsafe
***************************20/04/94 *****************************************/
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
%safe
static int (*old_sav_function)() = 0;
%endsafe

static int save_function( char *filename )
{
int om_msg;
long msg;
struct GRid pid;
char filepath[OM_K_MAXOSNAME_LEN];
char file[128], *tttmp;
EMattr number, revi, descr;

    if( old_sav_function )
        (*old_sav_function)(filename);

    /* 
     * Now, get the part info (if present) and enter into the ASCII file
     */
    om_msg = asm$get_file_part( msg = &msg,
                                part_id = &pid );

    if(!(om_msg & msg & 1)) /* Not a file part */
        return( OM_S_SUCCESS );

    strcpy( filepath, filename );
    om_msg = asm$get_part_identity( msg = &msg,
				number = &number,
				revision = &revi,
				part_id = &pid );

    if( msg & om_msg & 1 )
    {
	om_msg = asm$get_part_identity( msg = &msg,
					description = &descr,
					part_id = &pid );

	tttmp = strrchr( filepath, '/' );
	if( tttmp )
	{
	    strcpy(file, tttmp+1);
	    *(filepath+(tttmp-filepath)) = 0;
	}
	om_msg = asm$add_directory_part( msg = &msg,
				dir = filepath,
				filename = file,
				numb = number.value.data.s,
				rev = revi.value.data.s,
				desc = descr.value.data.s );
    }
    else
        verbose(printf("getpartidentity failed\n"));

    return(OM_S_SUCCESS);
}

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
   tmp_file[OM_K_MAXOSNAME_LEN], tmp1_file[OM_K_MAXOSNAME_LEN];
   char 	new_string[OM_K_MAXOSNAME_LEN];

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

   EMattr 	*attrs = NULL, numb, rev, desc, itnum;
   IGRint 	numattr;
   long   	mymsg;
   int    	statusform = 0;
   struct 	GRid partid;
   char         act_filename[OM_K_MAXOSNAME_LEN];

   int          (*prev_function)() = 0, (*dummy_function)() = 0;

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
   goahead = 0;

   if( first == 1 )
   {
  /* TR#119603475 "Retrieve" is responsible for deleting the copyright form, 
   * not the "Retrieve Part" --Commenting the below code -bbkr 28/10/96
   *
   *     if( ex$is_interactive() )
   *       {
   *      EX_end_copyright();
   *  #ifdef X11
   *      XSetIOErrorHandler(EX_DefaultIOError );
   *  #endif
   *   }
   */
      first = 0;

      /* 
       * Setup the Save function to be executed on every save
       */
      ex$save_function( function = save_function,
                         previous_function = &old_sav_function );
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
      ex$message(msgnumb = EX_M_RetrClose);
      goahead = FALSE;
      retri_goahead = FALSE;

      strcpy(tmp1_file,
      module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);
      do
      {
         prompt_status = ex$create_prompt(message_no = EX_P_Save,
             left_prompt = EX_P_Yes,
             right_prompt = EX_P_No,
             string = tmp1_file,
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
		  EX_save_module( active_module_num, 1 );
                  EMdelete_windows();

                  save_flag = 1;
                  goahead = TRUE;
                  retri_goahead = TRUE;
               }
            }/*end if ans 'y'*/
            else if (prompt_status == EX_RIGHT_MATCH )
            {
	       EMdelete_windows();
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
      ex$message(msgnumb = EX_S_Clear);
   }/*end if have a file open close it - see comment below */
   /*
    * Deleted the if( goahead ) branch, to close the existing module 
    */

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
                  statusform = 1; /* added */
                  status = ex$prtfile_form(title = "Retrieve Options",
                      returned_filename = string,
                      seedfile = EX_seedfile,
                      form_type = EX_RETRIEVE_FILE_FORM,
		      number = &numb,
		      revision = &rev,
		      attribs = &attrs,
		      numattr = &numattr,
                      response = response,
                      response_data = response_data);
/* New case added for restarting the command on cancelling SD form */
       		  if( *response == EM_FORM_CANCELLED )
        	  {
                        statusform = 0;
                	response_data[0] = '\0';
	         	EX_init_keyboard();
        	        UI_echo("");
                	string[0] = '\0';
			*response = RESET;
	          }
                  else if ( *response != EX_FORM_FINISHED )
                  {
                    /*expect it to be FORM_FINISHED*/
                     /* CAN NOT STACK RETRIEVE COMMAND,
                     SINCE THERE IS NO MODULE FOR ANY OPERATION */
                     retrieve_error(0,string,response);/*set up error*/
                     statusform = 0;
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
                      statusform = 0;
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

	/* Now check if there is a function to be executed on retrieve */
        ex$retrieve_function ( function = dummy_function,
                          previous_function = &prev_function );

        if ( prev_function )
         {
         status = (*prev_function)(string);

         /* reset the function to be executed on retrieve */
         ex$retrieve_function ( function = prev_function,
                          previous_function = &dummy_function );
         if ( !status )
           {
             retrieve_error(0,string,response);
             return (OM_S_SUCCESS);
           }
         }

         goodfile =  EX_invalid_char_in_filename(string);
         if (!goodfile)
             {
             retrieve_error(EX_F_InvalidFilename,string,response);
                                                   /*set up error*/
             }
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
            verbose(printf(" retrieve file ( file name generic error)\n"));
         }

         if (result < 0)  /* file is not on disk */
         {
            /* check if in master file table */
            int kkkk;

            notfound = TRUE;
            for(i = 0; i< EX_MAX_MODULES && notfound ; i++)
            {
	       /* The current module is still open which is anyway going 
                * to be closed at the end, so skip it - added 
                */ 
	       if( i == active_module_num )
		    continue;

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

      /***** Close the old file - added *******/
      if( goahead )
      {
          close_oldone( save_flag, tmp1_file, my_id );
      }


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
            result = EX_check_file(os_args.s_name,TRUE);
            if ( result > 1 ) ex$message(msgnumb = result,justification=LEFT_JUS,time=4);
            if ( result == 1 ) verbose(printf(" generic error\n"));
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
            verbose(printf("retrieve file : no dynamic memory available\n"));
            verbose(printf("clean up ipc structures /or expand swap space\n"));
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
                     verbose(printf("Seed file can not have iso in it"));
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
            verbose(printf("Can not construct object space\n"));
            om$report_error(sts=status);
            *response = -1;
         }
/*****  if the user has some attrs defined through the
        status display form, add these attrs to the newfile. If no attrs defined
        take the partnumber as filename, revision as 1, itemno as 1 and quantity
	as 1.
        Also, add an entry in the ascii file 
*****/
	if( *response != -1 && *response != EX_EXIT ) /* Retrieve successful */
	{
		EMinitialise();
		if( !statusform )
		{
			numattr = 3;
			attrs = (EMattr *)malloc( 3 * sizeof(EMattr));
			/* The partnumber will be default to the filename,
	       	           and all other attributes as defined in the seed file
			*/	
			tttmp = strrchr( string, '/' );
			if( tttmp )
			fill_attr( EM_PART_ATTR,EM_STRING,"number",
				"Part Number",tttmp+1,&numb );
			else
			fill_attr( EM_PART_ATTR,EM_STRING,"number",
				"Part Number",string,&numb );
			fill_attr( EM_PART_ATTR,EM_STRING,"revision",
				"Part Revision","1", &rev );
			fill_attr( EM_PART_ATTR, EM_STRING,"description",
				"Part Description","File Part", &attrs[0] );
			fill_attr( EM_COMMON_ATTR,EM_STRING,"itemno",
				"Item Number","1", &attrs[1] );
			fill_attr( EM_INSTANCE_ATTR,EM_INTEGER,"quantity",
				"Quantity","1", &attrs[2] );
		}
		/* Find out if the retrieved file has a file_part definition */
		status = asm$get_file_part( msg = &mymsg,
				   part_id = &partid );
		if( status & mymsg & 1 )
		{
                IGRboolean old_system_mode;
		EMattr att;

			status = asm$get_attribute(
						msg = &mymsg,
						id = &partid,
						name = "number",
						attribute = &att );
			if( !strcmp(att.value.syntax, "seed_file"))
			{
                                /* Go to system mode */
                                old_system_mode = EMdesc_set_system_mode(TRUE);
                                if( numb.value.syntax[0] )
                                {
				    status = asm$mod_attribute(msg = &mymsg,
				        	id = &partid,
					        name = "number",
					        attribute = &numb );
                                }
                                if( rev.value.syntax[0] )
                                {
				    status = asm$mod_attribute(msg = &mymsg,
				        	id = &partid,
					        name = "revision",
					        attribute = &rev );
                                }
                                /* Go to old system mode */
                                EMdesc_set_system_mode(old_system_mode);
			}
		}
		else /* Not a file_part, create one */
		{
			if( numattr == 0 )
			{
				attrs = (EMattr *)malloc( 1*sizeof(EMattr));
				attrs[0] = desc;
				numattr = 1;
			}

			status = asm$create_file_part ( msg = &mymsg,
               		        number = numb.value.syntax,
                        	revision = rev.value.syntax,
                                part_id = &partid,
       		                num_attributes = numattr,
               		        attributes = attrs );
			if(!( status & mymsg & 1 ))
		           verbose(printf("Create File part failed\n"));

		        status = asm$mod_attribute(msg = &mymsg,
				        	id = &partid,
					        name = "number",
					        attribute = &numb );

		        status = asm$mod_attribute(msg = &mymsg,
				        	id = &partid,
					        name = "revision",
					        attribute = &rev );
		}
		tttmp = strrchr( string, '/' );
		if( tttmp )
		{
			strcpy(tmp_file, tttmp+1);
			*(string+(tttmp-string)) = 0;
		}
	} /* End Successful Retrieve */
      }
   } /* end if(i<EX_MAX_MODULES) */
   else
   {
      ex$message(msgnumb = EX_F_MaxModule);
   }

   EX_create = FALSE;
   return(OM_S_SUCCESS);
} /* method retrieve execute */



close_oldone( int sav_flg, char *filepath, OM_S_OBJID id )
{
int sts, status, j;
long mymsg;
struct GRid partid;
char *tttmp, file[256];
EMattr number, revi, descr;

         ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
         ex$message(msgnumb = EX_S_CloseInProg);

         /* close visible will send clear stack message to command server */
         /* so we need to inform cmdserver not to delete this retrieve cmd*/
         EX_cmdserver_save_last_cmd();

/***** Write the file part information into the ascii file ******/
	 if( sav_flg )
	 {
		sts =  asm$get_file_part (msg = &mymsg,
                		          part_id = &partid);
		if( mymsg & sts & 1 )
		{
			sts = asm$get_part_identity( msg = &mymsg,
						     number = &number,
						     revision = &revi,
						     part_id = &partid );
			if( mymsg & sts & 1 )
			{
				sts = asm$get_part_identity( msg = &mymsg,
							     description = &descr,
							     part_id = &partid );
				if(!( mymsg & sts & 1 ))
				{
				  mymsg = ASM_S_SUCCESS;
				  sts = OM_S_SUCCESS;
				  descr.value.data.s[0] = '\0';
				}
				
				tttmp = strrchr( filepath, '/' );
				if( tttmp )
				{
					strcpy(file, tttmp+1);
					*(filepath+(tttmp-filepath)) = 0;
				}
				sts = asm$add_directory_part( msg = &mymsg,
						dir = filepath,
						filename = file,
						numb = number.value.data.s,
						rev = revi.value.data.s,
						desc = descr.value.data.s );
			}
			else
				verbose(printf("Failed to get part identity\n"));
		}
	 }
         sav_flg = 0;
         if( close_visible(sav_flg, id) == 1 )/*1 for save,0 for nosave*/
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
                            senderid = id,
                            targetid = module_table[active_module_num].module_my_id,
                            targetos = module_table[active_module_num].obj_space_num);

                    check_error_status(status,
                            "IN EXEC wake_up (module.active) error");
                    break;
                }
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
        ex$message(msgnumb = EX_S_Clear);
	return( 1 );
}

EMdelete_windows()
{
  IGRlong msg,om_msg;
  IGRint sizbuf,i;
  IGRint count;
  struct GRmd_env act_mod;
  struct GRid  sv_ids[20];
  OM_S_CHANSELECT winsup;

  msg = ASM_S_SUCCESS;
  om_msg = OM_S_SUCCESS;

  sizbuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &msg,
                    buffer = &act_mod,
                    sizbuf = &sizbuf);


          dp$get_gragad_id(msg = &msg,
                           mod_GRid = &act_mod.md_id,
                           name = "*",
                           numberofids = &count,
                           array_size = 20,
                           found_GRids = sv_ids);

          if((1& msg) && count)
           {
              winsup.type = OM_e_name;
              winsup.u_sel.name = "IGEgadget.to_parent";

              for(i=0; i < count; i++)
               {
                 om_msg = om$send(msg = message IGEwindow.clear(&msg),
                                  senderid = sv_ids[i].objid,
                                  p_chanselect  = &winsup,
                                  targetos =  act_mod.md_id.osnum);
               }
           }


  return(1);
}

end implementation ECretriprt;

