class implementation exec;
#include <stdio.h>
#include <OMerrordef.h>
#include <UNIXerrdef.h>
#include <string.h>
#include <ctype.h>
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
#include <sys/types.h>
#include <sys/stat.h>
#include <exlanguage.h>
#include <version.h>
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include <exproto.h>
#include <exlocale.h>

#ifdef SUNOS5
%undef sleep
#endif

from module import wake_up,sleep,execute_mod;

from OMFiledOS import set_state,write;
from cmdserver import sleep_cs, init_cs, wakeup_cs, exec_cs,clear_stack;

extern struct module_params **module_data;
extern struct EX_visible_module *module_table;
extern OM_S_OBJID EX_exec_id;
extern OM_S_OBJID EX_cmdserver_id;
extern struct EX_cmd_cntrl *EX_cmdlist_ptr;
extern int no_modules;
extern int EX_same_file;
extern char *getenv();
extern int timer_no;
extern int EX_help_proc_exist;
extern struct diacritic *EX_diacritic;
extern int EX_ndiacritic;
extern int EX_process_unknowns;
extern  int     OM_Gi_number_of_appl_ids;
extern  INGR_p_PRODUCT_DEF OM_GA_appl_version[];
extern char *EX_search_path;
extern char EX_runname[20];
extern char *EX_dependencies;
extern struct EX_prod_def *EX_product_list;


%safe
static int (*EX_call_function_on_exit)() = 0;
static int (*EX_call_function_on_exit_no_save)() = 0;
%endsafe

/**************************************************/
/*      this function takes message #             */
/*      and inserts them into another             */
/*      message to create a keyin prompt          */
/*                                                */
/*      it then gets the input and return         */
/*      which the inputs matches                  */
/*      return EX_NO_MATCH for no match           */
/*      return EX_LEFT_MATCH for left match       */
/*      return EX_RIGHT_MATCH for right match     */
/**************************************************/

int EX_create_prompt(message_number,left_prompt_number,
                        right_prompt_number,string,response,response_data)
int message_number;
int left_prompt_number;
int right_prompt_number;
char *string;
int *response;
char *response_data;
{
    char          *lower_ptr, *left_ptr, *right_ptr, *temp_ptr;
    char          lower_char[1024];
    int           not_finished, i, prompt_counter, found, status;
    int 		  statusl, statusr;
    char prompt1[128];
    char prompt2[128];

  lower_ptr = lower_char;
  lower_char[0] = 0;
  not_finished = 1;
  prompt_counter = 0;
  statusl = ex$message(msgnumb = left_prompt_number, buff = prompt1);
  statusr = ex$message(msgnumb = right_prompt_number, buff = prompt2);
  if ( string )
   {
   ex$message(msgnumb = message_number,justification = RIGHT_JUS,
                     type = "%s%s%s", var = `prompt1,prompt2,string`,
                     ret_status = &status);
   }
  else
   {
    ex$message(msgnumb = message_number,justification = RIGHT_JUS,
                  type = "%s%s", var = `prompt1,prompt2`,
                  ret_status = &status);
   }
  if (  status && statusl && statusr )
  {
  EX_get_input(response,response_data,0);
  if ( *response == STRING)
   {
   while ( not_finished )
    {
    if ( prompt_counter == 0 )
     {   
      temp_ptr = prompt1;
      lower_ptr = lower_char;
     }
    else if ( prompt_counter == 1 )
     {
      temp_ptr = prompt2;
      lower_ptr = lower_char;
     }
    else
     {
     temp_ptr = response_data;
     lower_ptr = lower_char;
     }
    while  ( *temp_ptr != 0 )
    {
      if (( (unsigned char) *temp_ptr <= 0x7f ) || ( !EX_ndiacritic ))
       {
        *lower_ptr = tolower ( *temp_ptr );
        ++temp_ptr;
        ++lower_ptr;
       }
      else
       {
         /*foreign language translate*/
         found = 0;
         for ( i = 0 ; i < EX_ndiacritic ; i++ )
              {
              if ((unsigned char) *temp_ptr == (unsigned char)EX_diacritic[i].diacritic )
               {
               strncpy ( lower_ptr , EX_diacritic[i].lower_char,
                                         EX_diacritic[i].nbytes );
               lower_ptr = lower_ptr + EX_diacritic[i].nbytes;
               ++temp_ptr;
               i = EX_ndiacritic;
               found = 1;
               }/*end if ==*/
              }/*end for*/
            if (!found)
             {
             *lower_ptr = tolower ( *temp_ptr );
		     ++temp_ptr;
             ++lower_ptr;
             }
        }/*end else foreign char*/
    }
    *lower_ptr = 0; /*null last byte*/
    if ( prompt_counter == 0 )
     {
     strcpy ( prompt1, lower_char );
     prompt_counter++;
     }
    else if (prompt_counter == 1)
     {
     strcpy ( prompt2, lower_char );
     prompt_counter++;
     }
    else
     {
     /*response_data is lower case in lower_char*/
     not_finished = 0;
     }

  }
 /*find the match*/
  not_finished = strlen (response_data);
  left_ptr = prompt1;
  right_ptr = prompt2;
  lower_ptr = lower_char;

  while ( not_finished )
   {
    if ((*left_ptr == *lower_ptr) && (*right_ptr != *lower_ptr))
                 return (EX_LEFT_MATCH);   
    if ((*left_ptr != *lower_ptr) && (*right_ptr == *lower_ptr))
                 return (EX_RIGHT_MATCH);   
    if ((*left_ptr != *lower_ptr) && (*right_ptr != *lower_ptr))
                 return (EX_NO_MATCH);   
    if ((*left_ptr == *lower_ptr) && (*right_ptr == *lower_ptr))
       {
       left_ptr++;
       right_ptr++;
       lower_ptr++;
       not_finished--;
       }
   }

   }/*end if string*/
  return (EX_NO_MATCH); 
  }/*end if have valid message*/
 else
  {
  return ( EX_INVALID_PROMPT );
  }

} 

/**************************************************/
/*                                                */
/*        close_visible                           */
/*                                                */
/**************************************************/

close_visible(save_flag, my_id)
int         save_flag;
OM_S_OBJID  my_id;
{
   int   status,
         i, j,
         result,
         sav_mod_num;
   char  file1[OM_K_MAXOSNAME_LEN],
         file2[OM_K_MAXOSNAME_LEN],
         nfile[OM_K_MAXOSNAME_LEN],
         new_string[OM_K_MAXOSNAME_LEN];

   backup_filenames(active_module_num, nfile, file1);

   /* nfile  -- filename.bk#      */
   /* file1  -- filename.BK#      */
   /* #      -- table slot number */
   /*          (active module num)*/

   /* clear command stack */

   status = om$send(mode = OM_e_wrt_object,
      msg = message cmdserver.clear_stack(),
      senderid = my_id,
      targetid=EX_cmdserver_id,
      targetos = OM_Gw_TransOSnum_0);

   status = om$send(mode = OM_e_wrt_object,
                     msg = message
                        OMFiledOS.set_state(save_flag & EX_saveOnClose),
                senderid = my_id,
                targetid = module_table[active_module_num].filed_id,
                targetos = module_table[active_module_num].obj_space_num);
   if (!(1 & status))
   {
      printf("OM_send (OMFiledOS.set_state) error\n");
      om$report_error(sts = status);
      return(0);
   }

   strcpy(new_string, module_data[module_table[active_module_num].
      obj_space_num]->CS_OS_name);

   if (save_flag & EX_saveOnClose)
   {
         /* call user function if it exists*/

         if (EX_call_function_on_exit) 
         {
            char exit_string[OM_K_MAXOSNAME_LEN];

            strcpy(exit_string, new_string);

            /*is exit only call user function*/

            status = (*EX_call_function_on_exit)(exit_string, 0);
            if (!(1 & status))
            {
               printf("close_visible error from user function <%s>\n",new_string);
               om$report_error(sts = status);
            }
         }
      }
      else
      {
         if (EX_call_function_on_exit_no_save) 
         {
            char exit_string[OM_K_MAXOSNAME_LEN];

            strcpy(exit_string, new_string);

            /*is exit only call user function*/

            status = (*EX_call_function_on_exit_no_save)(exit_string, 0);
            if (!(1 & status))
            {
               printf("close_visible error from user function <%s>\n",new_string);
               om$report_error(sts = status);
            }
         }
     
     }
   status = om$send(mode = OM_e_wrt_object,
                   msg = message module.sleep(EX_REAL_SLEEP),
              senderid = my_id,
              targetid = module_table[active_module_num].module_my_id,
              targetos = module_table[active_module_num].obj_space_num);
   check_error_status(status, "OM_send (module.sleep) error");
   if (1&status) /* sleep success */
   {
      char mount_name [DI_PATH_MAX];
     
      /*
       * We save the mount name (to re-mount if write fails) and we un-mount.
       */
      di$give_pathname(osnum = module_table[active_module_num].obj_space_num,
         pathname = mount_name);
      di$umount(dirname = mount_name);
      if (save_flag & EX_saveOnClose)
      {
         status = om$send(mode = OM_e_wrt_object,
                     msg = message OMFiledOS.write(new_string),
                senderid = EX_exec_id,
                targetid = module_table[active_module_num].filed_id,
                targetos = module_table[active_module_num].obj_space_num);
         if (!(1 & status))
         {
            printf("close_visible cannot write os out <%s>\n",new_string);

            /*
             * We re-mount with the same name
             */

            di$mount(logical = mount_name,
                osnum = module_table[active_module_num].obj_space_num);
            ex$message(msgnumb = EX_F_FileNotSave);	   
            om$report_error(sts = status);
            status=om$send(mode = OM_e_wrt_object,
                           msg = message module.wake_up(EX_visible),
                      senderid = my_id,
                      targetid = module_table[active_module_num].module_my_id,
                      targetos = module_table[active_module_num].obj_space_num);
            check_error_status(status, "OM_send (module.wake_up) error");
            return(0);
         }

         /* write success, check file size */

      }

   if (save_flag & EX_saveOnClose)
   {
         /* call user function if it exists*/

         if (EX_call_function_on_exit) 
         {
            char exit_string[OM_K_MAXOSNAME_LEN];

            strcpy(exit_string, new_string);

            /*is exit only call user function*/

            status = (*EX_call_function_on_exit)(exit_string, 0);
            if (!(1 & status))
            {
               printf("close_visible error from user function <%s>\n",new_string);
               om$report_error(sts = status);
            }
         }
      }
      else
      {
         if (EX_call_function_on_exit_no_save) 
         {
            char exit_string[OM_K_MAXOSNAME_LEN];

            strcpy(exit_string, new_string);

            /*is exit only call user function*/

            status = (*EX_call_function_on_exit_no_save)(exit_string, 0);
            if (!(1 & status))
            {
               printf("close_visible error from user function <%s>\n",new_string);
               om$report_error(sts = status);
            }
         }
     
     }


      status = om$send(mode = OM_e_wrt_object,
                     msg = message OMFiledOS.set_state(0), /* don't write */
                senderid = my_id,
                targetid = module_table[active_module_num].filed_id,
                targetos = module_table[active_module_num].obj_space_num);
      if (!(1 & status))
      {
         printf("OM_send (OMFiledOS.set_state) error\n");
         om$report_error(sts = status);
         return(0);
      }
      else  /* set state success */
      {
         status = om$send(mode = OM_e_wrt_object,
                          msg = message OMFiledOS.delete(0),
                     senderid = my_id,
                     targetid = module_table[active_module_num].filed_id,
                     targetos = module_table[active_module_num].obj_space_num);
         if (!(1 & status))
         {
            printf("OM_send (OMFiledOS.delete) error\n");
            om$report_error(sts = status);
         }
         else
            EX_close_rec_echo(1);   /*delete journal file*/ 
      }
   }  
   else /* sleep failed  */
   {
      printf("close_visible send module.sleep failed <%s>\n",new_string);
      ex$message(msgnumb = EX_F_FileNotSave);	   
      om$report_error(sts = status);
      status=om$send(mode = OM_e_wrt_object,
                      msg = message module.wake_up(EX_visible),
                 senderid = my_id,
                 targetid = module_table[active_module_num].module_my_id,
                 targetos = module_table[active_module_num].obj_space_num);
      check_error_status(status, "OM_send (module.wake_up) error");
      return(0);
   }

   remove_backup(file1);
   module_table[active_module_num].obj_space_num = 0;
   module_table[active_module_num].module_my_id = NULL_OBJID;
   module_table[active_module_num].filed_id = NULL_OBJID;
   module_table[active_module_num].permis_flag = EX_read_write;       
   module_table[active_module_num].no_scn_menu = 0;

   sav_mod_num = active_module_num;
   if (active_module_num != 0)
      active_module_num--;
   for (i = (sav_mod_num + 1),j = sav_mod_num; i < EX_MAX_MODULES; i++)
   {
      if (module_table[i].obj_space_num != 0)
      {
         backup_filenames(i, nfile, file1);
         module_table[j] = module_table[i];
         result = file_exists(file1, 0, 0, nfile);
         if ( !result )
         {
            backup_filenames(j, nfile, file2);
            EX_mv(file1, file2);
         }
         module_table[i].obj_space_num = 0;
         module_table[i].module_my_id = NULL_OBJID;
         module_table[i].filed_id = NULL_OBJID;
         module_table[i].permis_flag = EX_read_write;       
         module_table[i].no_scn_menu = 0;
         j++;
      }
      else 
         break;
   }

   if (module_table[0].obj_space_num == 0)
      no_modules = 1;
   if (EX_same_file == 1)
      EX_same_file = 0;

#ifndef NT
   if (!(save_flag & EX_exitOnClose) && EX_process_unknowns)
   {
      /* saw001 10/92  Cleaning up application version stamps,
       * product config search path, etc., brought into memory
       * when this file was retrieved and products added to
       * EX_search_path and EX_dependencies by EX_force_product_dload.
       * We're effectively doing a switch_prod to EX_runname (to
       * arrive at the normal configuration for the product we're
       * already running), but without any new dynamic loading.
       *
       * We'll only come thru here if we are not about to exit
       * anyway and if the EX_process_unknowns flag is on (EMS
       * turns it on as of 2.1).
       */

      int                  ii, jj,
                           sizebuf = 512;
      int                  numProd = 0;
      struct EX_prod_def   **prodArray;
      INGR_p_PRODUCT_DEF   *appArray;
      char                 *ptr1, *ptr2,
                           product[512];

#ifdef DEBUG
int i, j;
printf("\nclose_visible: EX_search_path is\n<%s>\nOM_Gi_number_of_appl_ids: %d\n",
   EX_search_path, OM_Gi_number_of_appl_ids);
for(i=j=0; (i<MAXNUMAPPVER) && (j<OM_Gi_number_of_appl_ids); i++)
{
   if (!OM_GA_appl_version[i])
   {
      printf("[%d]:NULL\n", i);
      continue;
   }
   j++;
   printf("[%d]:%s  0x%x\n",
      i,
      OM_GA_appl_version[i]->curr_version,
      OM_GA_appl_version[i]->appl_specifics);
}
#endif

      ptr1 = EX_search_path;
      if (!(1&EX_set_srch_path()))
      {
         fprintf(stderr, "close_visible: Warning - failed to reset EX_search_path\n");
         EX_search_path = ptr1;
         return(1);
      }
      om$dealloc(ptr=ptr1);      /* Get rid of old list */

      ptr1 = EX_dependencies;
      /* Get prod names */
      if (!EX_get_srch_path1(EX_runname, 0, &product[0], &sizebuf))
         return(0);
      if (!(EX_dependencies = (char *) om$malloc(size = strlen(product) + 1)))
         return OM_E_NODYNMEM;
      strcpy(EX_dependencies, product);
      om$dealloc(ptr=ptr1);      /* Get rid of old EX_dependencies */
      EX_get_srch_path(NULL, &numProd);
      if (!(prodArray = (struct EX_prod_def **)
         om$calloc(size = 4, num = numProd)))
      {
         fprintf(stderr, "close_visible: could not allocate %d bytes.\n",
            numProd * 4);
         return(OM_E_NODYNMEM);
      }
      ii = 0;
      ptr1 = &product[0];
      while((ii < numProd) && (ptr2 = strchr(ptr1, ':')))
      {
         *ptr2 = '\0';
         if (EX_get_prod_def(&prodArray[ii], (char *) NULL, ptr1,
            (char *) NULL))
            ii++;
         ptr1 = ++ptr2;
      }
      numProd = ii;  /* Num entries in EX_dependencies might be less
                        than num in EX_search_path */

      /* Reconstruct the array of application version stamps based
       * on the product list.
       */

      for (ii=OM_Gi_number_of_appl_ids=0; ii<numProd; ii++)
      {
         if (appArray = prodArray[ii]->ingr)
         {
            for (jj=0; appArray[jj] && (jj<MAXNUMAPPVER); jj++)
               OM_GA_appl_version[OM_Gi_number_of_appl_ids++] = appArray[jj];
         }
      }
      if (prodArray)
         om$dealloc(ptr=prodArray);

#ifdef DEBUG
printf("\nLeaving close_visible: EX_search_path is\n<%s>\nOM_Gi_number_of_appl_ids: %d\n",
   EX_search_path, OM_Gi_number_of_appl_ids);
for(i=j=0; (i<MAXNUMAPPVER) && (j<OM_Gi_number_of_appl_ids); i++)
{
   if (!OM_GA_appl_version[i])
   {
      printf("[%d]:NULL\n", i);
      continue;
   }
   j++;
   printf("[%d]:%s  0x%x\n",
      i,
      OM_GA_appl_version[i]->curr_version,
      OM_GA_appl_version[i]->appl_specifics);
}
#endif
   }  /* if (EX_process_unknowns) */
#endif
   return(1);
} /* close_visible */


/**************************************************/
/*                                                */
/*        pass on                                 */
/*                                                */
/**************************************************/


method passon  (
                       OM_p_MESSAGE     pass_msg;
                       IGRchar          *chan;
                       IGRint           strt_index;
                       IGRint           end_index)
{
    static OM_S_CHANSELECT chandef1;
    static char last_name[OM_K_MAXCHANNAME_LEN+1] = { '\0' };

    if (strcmp ( last_name, chan ))
    {
      int ret_stat;
      
      chandef1.type = OM_e_num;
      ret_stat = om$get_channel_number ( channame = chan,
                                         p_channum = &chandef1.u_sel.number );
      if (!(ret_stat & 1))
      {
        chandef1.type = OM_e_name;
        chandef1.u_sel.name = chan;
        *last_name = '\0';
      }
      else
        strcpy ( last_name, chan );
    }
#ifdef ENV5
    strt_index  += MAX_REGION;
    end_index   += MAX_REGION;
#endif
    return (om$send(mode = OM_e_wrt_object,
                     msg = pass_msg,
                senderid = my_id,
            p_chanselect = &chandef1,
                    from = strt_index,
                      to = end_index));
}


/**************************************************/
/*                                                */
/*        wake up                                 */
/*                                                */
/**************************************************/
static  int response;
static  char *response_data;
method wake_up()
{

  int status,stat;
  long num_byte;
  IGRlong msg;
  int resp;
  char buf[20];

  no_modules = 1;
     
  ex$message(msgnumb = EX_M_ExecSvc);

  status = ex$start_cmdserver( init = TRUE, exec = TRUE ); 

  while(status != EX_EXIT)
  {  
   ex$message(msgnumb = EX_S_Clear);	      
   stat = ex$create_prompt(message_no = EX_P_RetExit,
                           left_prompt = EX_P_Retrieve,
                           right_prompt =EX_P_Exit,
                           string = (char *) NULL,
                           response = &response,
                           response_data = response_data);

   ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
     if ((response == CMD_STRING) || (response == STRING) ) 
     {
       if (stat != EX_NO_MATCH)
        {
        if (stat == EX_LEFT_MATCH)
         {/*retrieve was response*/
 		 num_byte = sizeof(buf);
		 resp = EX_CMD_KEY;
		 strcpy(buf,"EXRtFl");
		 status = ex$putque( msg = &msg, pos=FRONT, response=&resp ,
				     byte=&num_byte, buffer=buf ); 
		 if( ! (1&status))
		 {
		      printf("IN EXEC wake_up  can not put q EXRetrFile\n");
		 }
                 status = EX_start_cmdserver( 0, 1);
        }/*end if retrieve*/
       else
        {
                status = EX_EXIT;
        }
       }
	 else if( !strcmp(response_data, "ompms") ||
                          !strcmp(response_data,"om pms") )
         {
/*helpnt*/
#ifndef NT
            OM_PMS();  
#endif
	 }
	 
     }
  }

  return(OM_S_SUCCESS);
} /* method wake_up */

int 
EX_execute_mod()
{
   int status;
       status = om$send(mode = OM_e_wrt_object,
	    msg = message module.execute_mod(NULL,NULL),
	    senderid = EX_exec_id,
	    targetid = module_table[active_module_num].module_my_id,
	    targetos = module_table[active_module_num].obj_space_num);
       check_error_status(status,
		 "IN EXEC execute_mod (module.execute) error");
   return(1);
}

int EX_start_cmdserver( init, exec )
int init,exec;
{

  int status=1;
  int dummy;
  OM_S_OBJID   dummy_id; 
  static int save_resp_data = 0;

  if( save_resp_data == 0 )
  {
      response_data = (char *)om$malloc(size = 1032);
      dummy = (int) response_data;  /* align problem, */
      dummy &= 0xfffffffc;
      dummy += 8;
      response_data = (char *) dummy;
      save_resp_data = 1;
  }

  /*  construct cmdserver , flag == 1 execute only */
  if( init > 0 )
  {
    status = 0;

    status = om$construct(osnum  = OM_Gw_TransOSnum_0,
		       classname = "cmdserver",
			 p_objid = &dummy_id,
			neighbor = OM_GS_NULL_NEIGHBOR);
        check_error_status(status,"In EX_start_cmdserver construct cmdserver object error");
    if(!(1&status))      return(0);
    EX_cmdserver_id = dummy_id;

    status = 0;
    status = om$send(mode = OM_e_wrt_object,
		      msg = message cmdserver.init_cs(),
		 senderid = EX_exec_id,
		 targetos = OM_Gw_TransOSnum_0,
		 targetid = dummy_id);
    check_error_status(status,"In EX_start_cmdserver cmdserver.init error");
    if(!(1&status)) return(0);
    status = 0;
    
    status = om$send(mode = OM_e_wrt_object,
		      msg = message cmdserver.wakeup_cs(),
		 senderid = EX_exec_id,
		 targetos = OM_Gw_TransOSnum_0,
		 targetid = dummy_id);

    check_error_status(status,"In EX_start_cmdserver cmdserver.wakeup_cs error");
    if(!(1&status)) return(0);

    EX_session_init_cmd( EX_cmdlist_ptr );
  }

  if( exec > 0 )
  {
      status = om$send(mode = OM_e_wrt_object,
		       msg = message cmdserver.exec_cs(&response,response_data,0),
		  senderid = EX_exec_id,
		  targetos = OM_Gw_TransOSnum_0,
		  targetid = EX_cmdserver_id);

      if ( *(int *)response_data == EX_EXIT ) status = EX_EXIT;
      if ( *(int *)response_data == EX_CMDSVR_RETURN ) status = EX_CMDSVR_RETURN;
  }
  return(status);
}


/* for hidden line group only */
int EX_save_backup_file( file_name)
char *file_name;
{
  char file1[OM_K_MAXOSNAME_LEN],
       file2[OM_K_MAXOSNAME_LEN],
       nfile[OM_K_MAXOSNAME_LEN];
  int status;
     
  backup_filenames(active_module_num,nfile,file1);
 /* nfile  -- filename.bk#      */
 /* file1  -- filename.BK#      */
 /* #      -- table slot number */
 /*          (active module num)*/

  status = file_exists(file1,0,0,file2);
  if( !status )
  {
       EX_mv(file1, file_name);
       return(0);
  } 
  return(1);
}

int EX_stop_auto_backup()
{
    /*  return 1  -- no timer set ( no auto backup set ) */
    /*         0  -- success                             */
    /*        -1  -- error from tools                    */ 
   int status;
   status = 1;
#ifdef ENV5
   if ( timer_no != -1 ) 
   {
      status = Stop_timer(timer_no);
      if(status == 0 ) timer_no = -1;
   }
#endif
   return(status);
}

extern struct EX_cmd_cntrl *EX_cmdlist_ptr;
%safe
static  char old_run_name[20] = {0};
%endsafe
static  struct EX_cmd_cntrl *old_cmdlist_ptr;


int EX_context_switch_to(exec_name)
char *exec_name;
{
  int back,status;
  long msg;
  char msgtext[20],usr_pth[256];
  char *tmp_srch,*tmp1_srch;
  
  back = 0;
  if ( !strcmp( exec_name, EX_runname) ) return(1); /* same as current */
  
  status = get_modtype_data(exec_name,msgtext, NULL, NULL,NULL, NULL);
  if( ! (1&status) )
  {
     printf( " can not get logo of <%s>\n",EX_runname);
     return(0); 
  }       
  else
  {

     strcpy (old_run_name, EX_runname);

     strncpy(EX_runname, exec_name, 20);
     EX_runname[19] = '\0';


     EX_set_logo(msgtext);
     module_set_pathname( EX_runname );
     if( !( 1 & EX_set_srch_path() ) ) 
     {
        printf("can not set srch path of <%s> \n",EX_runname);
        strcpy (EX_runname, old_run_name);
        EX_cmdlist_ptr = old_cmdlist_ptr ;
        return(0);
     }
     else
     {
	/* Fix for TR# 119701033. While switch proding to Ultra the
         user path from the string EX_search_path is being removed
        and the menus are brought and then the string is set to normal*/

       if(!strcmp(EX_runname,"Emsultra"))
        {
        usr_pth[0]='\0';
        tmp_srch=NULL;
        tmp1_srch = NULL;
        tmp_srch = (char *)malloc((sizeof(char)* (strlen(EX_search_path)+1)));
        tmp1_srch =(char *)malloc((sizeof(char)* (strlen(EX_search_path)+1)));
        strcpy(tmp1_srch,EX_search_path);
        EX_get_user_srch_path(usr_pth);
        if(usr_pth[0]!='\0')
        {
        tmp_srch = strchr(EX_search_path,':');
        tmp_srch = tmp_srch +1;
        strcpy(EX_search_path,tmp_srch);
        }
        }
        EX_cmddetach( &msg , -1);
        EX_init_locale();
        ms$init();
        FEI_set_form_icon_path();
        EX_construct_and_display_menus();
        EX_init_session();
	if(!strcmp(EX_runname,"Emsultra"))
        {
       if(usr_pth[0]!='\0')
        {
        strcpy(EX_search_path,tmp1_srch);
        }
        if(!tmp1_srch)
        free(tmp1_srch);
        if(!tmp_srch)
        free(tmp_srch);
        }
        if ( EX_help_proc_exist )
       {
       if(!(( (strcmp(EX_runname,"Emsultra")==0)&&(strcmp(old_run_name,"Emspp")==0))
       ||((strcmp(EX_runname,"Emspp")==0)&&(strcmp(old_run_name,"Emsultra")==0))))
         {
          Help_kill();
          ex$help_init();    
         }
	 }
#ifndef NT
        EX_product_dload();
#endif

        /*  Update any TagCons for classes which may not have been
        **  known until now due to the switchprod in progress
        */

        som_tagcon_switchprod_update ();

        /* command table */
        status = om$send(mode = OM_e_wrt_object,
		       msg = message cmdserver.wakeup_cs(),
		  senderid = EX_exec_id,
		  targetos = OM_Gw_TransOSnum_0,
		  targetid = EX_cmdserver_id);

        return(1);
     }
  }
}


int EX_context_switch_1(exec_name)
char *exec_name;
{
  int back,status;
  char msgtext[20];

  back = 0;
  if ( !strcmp( exec_name, EX_runname) ) return(1); 
  
  status = get_modtype_data(exec_name,msgtext, NULL, NULL,NULL, NULL);
  if( ! (1&status) )
  {
     printf( " can not get logo of <%s>\n",EX_runname);
     return(0); 
  }       
  else
  {
     if ( !strcmp( exec_name, old_run_name) )
     {
        back = 1;
        strcpy(EX_runname,old_run_name );
        old_run_name[0] = '\0';
     }
     else
     {  
        strcpy (old_run_name, EX_runname);
     }
 
     strncpy(EX_runname, exec_name, 20);
     EX_runname[19] = '\0';


     EX_set_logo(msgtext);
     module_set_pathname( EX_runname );
     if( !( 1 & EX_set_srch_path() ) ) 
     {
        printf("can not set srch path of <%s> \n",EX_runname);
        strcpy (EX_runname, old_run_name);
        EX_cmdlist_ptr = old_cmdlist_ptr ;
        return(0);
     }
     else
     {

        FEI_set_form_icon_path();
        EX_construct_and_display_menus();
        return(1);
     }
  }
}

static char EX_logo_name[16];

int EX_set_logo( logo )
char *logo;
{
  strncpy( EX_logo_name ,logo ,15);
  EX_logo_name[15] = '\0';
  return(1);
}

EX_get_mloc_file( file_name , have_file )
char *file_name;
int *have_file;
{
    register char *tmp,*name;
    register int i;
    char mloc_name[20];
    FILE *fp;
    FILE *fpout;
    char tmp_name[20];
    char file2[OM_K_MAXOSNAME_LEN];
    int status;
    char tmp_logo[16];

    name = file_name;        
    tmp = strrchr(EX_logo_name, '/' );
    if ( !tmp )
    {
       tmp = EX_logo_name;
    }
    else
    {  
       tmp++;  /* do not want / */
    }
    strncpy(tmp_logo,tmp,8);
    tmp_logo[8] = 0;
    tmp = tmp_logo;

    i = 0;
    *file_name++ = '.';
    while( *tmp  )
    {
       if( i++ < 8 )
       {  
         *file_name++ = tolower( *tmp );
    	 tmp++;
       }
    }
    *file_name = '\0';
    strcat( name , "_mloc");
    status = file_exists(name,0,0,file2);
    *have_file = FALSE;
    if ( status )
      {
      /* .file did not exist look for ems_mloc*/
      strcpy ( mloc_name,name );/*save new mloc file*/

      tmp = strrchr(EX_logo_name, '/' );
      if ( !tmp )
       {
       tmp = EX_logo_name;
       }
      else
       {  
       tmp++;  /* do not want / */
       }
      strncpy(tmp_logo,tmp,9);
      tmp_logo[9] = 0;
      tmp = tmp_logo;
      i = 0;
      while( *tmp  )
       {
       if( i < 9 )
        {  
         tmp_name[i] = tolower( *tmp );
	     tmp++;
         i++;
        }
       }
      tmp_name[i] = '\0';
      strcat( tmp_name , "_mloc");
      if ( fp = (FILE *) fopen ( tmp_name, "r" ) )
        {

        char menu_type[64];
        int  xlo,ylo,xhi,yhi;
        int  num_read = 0;
        fpout = (FILE *) fopen ( mloc_name, "w" );
        *have_file = TRUE;
        for (;;)
         {
	      num_read = fscanf ( fp, "%s%d%d%d%d", 
				menu_type, &xlo, &ylo, &xhi, &yhi );
                    
	      if ( num_read != EOF )
            {
             ylo = ylo + 55;
             yhi = yhi + 55;

             fprintf(fpout,"%s %d %d %d %d\n",menu_type,
                            xlo,ylo,xhi,yhi);
            }
          else
            {
             break;
            }      
         }
         fclose (fp);
         fclose (fpout);
         EX_rm(tmp_name);
        }
       strcpy(name,mloc_name);
       }
      else
       {
       *have_file = TRUE;
       }       
    return(1);
}


EX_exit_function(function_to_execute,function_previous )
int (*function_to_execute)();
int (**function_previous)();
{
*function_previous = EX_call_function_on_exit;
EX_call_function_on_exit = function_to_execute;
return(1);
}


EX_exit_function_no_save(function_to_execute,function_previous )
int (*function_to_execute)();
int (**function_previous)();
{
*function_previous = EX_call_function_on_exit_no_save;
EX_call_function_on_exit_no_save = function_to_execute;
return(1);
}

end implementation exec;
