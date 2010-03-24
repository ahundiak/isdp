class implementation EX_exit;
#include <stdio.h>
#include <exdef.h>
#include <ex.h>
#include <execmsg.h>
#include <exmacros.h>
#include <expriv.h>
#include <EXproduct.h>
#include <exms.h>
#include <msdef.h>
#include <msmacros.h>
#include <sys/types.h>
#include <string.h>
#include <exproto.h>

#include "exudata.h"

/*helpnt*/
#ifndef NT
#include <sys/ipc.h>
#include <sys/sem.h>
#endif
extern struct module_params **module_data;
extern struct EX_visible_module *module_table;
extern OM_S_OBJID EX_exec_id;
extern OM_S_OBJID EX_cmdserver_id;
extern struct EX_cmd_cntrl *EX_cmdlist_ptr;
extern int EX_same_file;
extern uword EX_ACTINV_OS_num;

%safe
static int EX_exit_final_state = 0;
%endsafe

method execute(int *response; char *response_data; int pos)
{
   int num_open, save_all,i,close_flag;
   int goahead;
   long num_byte;
   int resp;
   int status;
   long mmsg;
   char buf[20];
   char na_me[100];
   int prompt_status;
   
WereExiting();
   if (EX_exit_final_state > 0)
      ME.super_cmd->state = EX_exit_final_state;


if( ME.super_cmd->state == 0 )
{
   ME.EX_exit->shutdown = 0;
   ex$message(msgnumb = EX_M_Exit);
   goahead = FALSE;
   num_open = 0;
   for(i=(EX_MAX_MODULES-1);i>=0;i--)
   {
      ME.EX_exit->save[i] = FALSE;
      if(module_table[i].obj_space_num!=0)   num_open++;
   }
   if (num_open == 1)
   {
    /* bbkr - TR#119700213 */
     exUDataActref rfact;
     status = exRecvUData(EX_UDATA_ACTREF, (char *)&rfact);

     if (rfact.aflag)
     {
       ex$message(in_buff = "Deactivate the Activated Part.",
                  field = ERROR_FIELD,
                  time = MS_SLEEP_TIME);
       status = ex$clear_event_queue ( );
       *response = TERMINATE;
       response_data[0]='\0';
       return(1);
     }
	   strcpy(na_me,module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);           
	   do
	   {
           prompt_status = ex$create_prompt(message_no = EX_P_Save,
                                        left_prompt = EX_P_Yes,
                                        right_prompt = EX_P_No,
                                        string = na_me,
                                        response = response,
                                        response_data = response_data);

	       if(*response == RESET)
	       {
		  response_data[0] = '\0';
		  EX_init_keyboard();
		  UI_echo(" ");
	       }
	       else if(*response == D_RESET)
	       {
		  response_data[0] = '\0';
		  EX_init_keyboard();
		  UI_echo(" ");
		  *response = TERMINATE;
	       }
	       else if ( *response == STRING )
	       {
  		   if (prompt_status == EX_LEFT_MATCH) 
		  {
           if( module_table[active_module_num].permis_flag == EX_read_only)
             {
  	         na_me[0]='\0';
	         strcpy(na_me,module_data[module_table[active_module_num].obj_space_num]->CS_OS_name);           
             ex$message(msgnumb = EX_S_Var1, type="%s",var=na_me);
             ex$message(msgnumb = EX_F_UseSaveas);
		     *response = TERMINATE;
              }
          else 
              {/*not read only proceed*/
		      goahead = TRUE;
		      ME.super_cmd->state = 2;
 		      }
          }/*end if 'y'*/
		  else if (prompt_status == EX_RIGHT_MATCH) 
		  {
		       goahead = TRUE;
		       ME.super_cmd->state = 1;
		  }
	       }
           }
	   while(*response == RESET);
   }
   else   /* more than one file opened */
   {
       /*UI_prompt("Save all files? y/n >");*/
       do
       {
         prompt_status = ex$create_prompt(message_no = EX_P_SaveAll,
                                        left_prompt = EX_P_Yes,
                                        right_prompt =EX_P_No,
                                        response = response,
                                        response_data = response_data);

           if(*response == RESET)
           {
              response_data[0] = '\0';
              EX_init_keyboard();
              UI_echo(" ");
           }
           else if(*response == D_RESET)
           {
              response_data[0] = '\0';
              EX_init_keyboard();
              UI_echo(" ");
	      *response = TERMINATE;
           }
	   else if ( *response == STRING )
     	   {
               if ((prompt_status == EX_LEFT_MATCH ) ||
                        (prompt_status == EX_RIGHT_MATCH))
               {
		   goahead = TRUE;
	       }
	   }
       }
       while(*response == RESET );

       if( goahead )
       {
	  ME.super_cmd ->state = 3;
	  save_all = FALSE;
	  if (prompt_status == EX_LEFT_MATCH ) /* save all files */
	  {
	     save_all = TRUE;
	  }
          for(i=(EX_MAX_MODULES-1);i>=0;i--)
          {
             if(module_table[i].obj_space_num!=0)
             {
                if( module_table[i].permis_flag == EX_read_only)
		{
  		   na_me[0]='\0';
		   strcpy(na_me,module_data[module_table[i].obj_space_num]->CS_OS_name);           
		   ex$message(msgnumb = EX_S_Var1, type="%s",var=na_me);
		   ex$message(msgnumb = EX_F_ReadOnly);
		}
		else
		{
		   if ( ! save_all )  /* not all files */
		   {
		      response_data[0] = '\0';
	          strcpy(na_me,module_data[module_table[i].obj_space_num]->CS_OS_name);
		       do
		       {
                prompt_status = ex$create_prompt(message_no = EX_P_Save,
                                        left_prompt = EX_P_Yes,
                                        right_prompt = EX_P_No,
                                        string = na_me,
                                        response = response ,
                                        response_data = response_data);

			   if(*response == RESET)
			   {
			      response_data[0] = '\0';
			      EX_init_keyboard();
			      UI_echo(" ");
			   }
			   else if ( *response == STRING )
			   {
			       if (prompt_status == EX_LEFT_MATCH ) /* save */
			       {
				  ME.EX_exit->save[i] = TRUE;
			       }
			       else if (prompt_status == EX_RIGHT_MATCH ) 
			       {
				   goahead = TRUE;
			       }
			       else
			       {
				   goahead = FALSE;
   				   goto exexitact;
			       }
			   }
			   else 
			   {
			       goahead = FALSE;
   			       goto exexitact;
			   }
		    }
		       while( *response == RESET );
		   }
		   else
		   {
			ME.EX_exit->save[i] = TRUE;
		   }
		}
             }
          }  /* end for */
  exexitact:
              ;
     } /* goahead  */
   } /* end of more than 1 module opened */
}



if ( ME.super_cmd->state > 0 )
{
    if ( EX_exit_final_state == 0 )
    {
        if (ME.EX_exit-> shutdown == 0 )
        {  
           EX_shutdowncmd(EX_cmdlist_ptr );
	   ME.EX_exit->shutdown = 1;
        }
        num_byte = sizeof(buf);
        resp = EX_CMD_KEY;
        strcpy(buf,"EXEx");
        status = ex$putque( msg = &mmsg,
		       pos=BACK,
       		       response=&resp ,
		       byte=&num_byte,
		       buffer=buf ); 
        if( ! (1&status))
        {
           printf("IN EX_shutdowncmd can not put q shutdown key EXEx\n");
        }
        num_byte = sizeof(buf);
        resp = EX_EXIT;
        strcpy(buf,"EX_EXIT");
        status = ex$putque( msg = &mmsg,
		       pos=BACK,
       		       response=&resp ,
		       byte=&num_byte,
		       buffer=buf ); 
        if( ! (1&status))
        {
           printf("IN EX_shutdowcmd can not put q shutdown exit \n");
        }

	EX_exit_final_state = ME.super_cmd->state ;
    
	resp = CLEAR_STACK;
	num_byte = sizeof(buf);
	strcpy(buf," ");
	status = ex$putque( msg = &mmsg, pos=FRONT, response=&resp ,
			       byte=&num_byte, buffer=buf ); 
	if( ! (1&status))
	{
	  printf("IN EX_exit  can not put q clear_stack\n");
	}
    }
    else
        EX_exit_final_state = 0;

    
    EX_get_input(response,response_data,0);
    if(*response == EX_EXIT)
    {
         ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
         ex$message(msgnumb = EX_S_ExitInProg);	    
         status = 1;
         switch ( ME.super_cmd->state )
	 {
             case 1:    
		     close_visible(EX_exitOnClose, EX_exec_id);
		     break;
	     case 2:
                     /* Tell close_visible that we're exiting and to
                      * save the file.
                      */

                     status = close_visible(EX_exitOnClose | EX_saveOnClose,
                        EX_exec_id);
		     break;
	     case 3:
		    for (i=(EX_MAX_MODULES-1); i>=0; i--)
  		    {
		       if (module_table[i].obj_space_num != 0)
		       {
			   close_flag = EX_exitOnClose;
		           if (ME.EX_exit->save[i])
			      close_flag |= EX_saveOnClose;
	
   			 /* set up the current global, because i is from EX_MAX_MODULES
			   and the current module may not be the highest index i    */
	    		   EX_active_module = module_table[i].module_my_id;
			   EX_active_OS_num = module_table[i].obj_space_num;
                           EX_ACTINV_OS_num = EX_active_OS_num;
   			   status = close_visible(close_flag, EX_exec_id);
		       }
		    }
		    break;
             default:
	           status = 0;
		   break;

	 }

	 *response = (status == 1 ) ? EX_EXIT : TERMINATE;
         ex$message(msgnumb = EX_S_Clear);
         ex$message(msgnumb = EX_M_Clear);    

    }
}
    return(1);
    
} 


void EX_exit1(save)
int save;
{
    int i;

    save |= EX_exitOnClose;   /* Tells close_visible we're exiting */
    for (i=(EX_MAX_MODULES-1); i>=0; i--)
    {
       if (module_table[i].obj_space_num!=0)
       {
          /* set up the current global, because i is from EX_MAX_MODULES
             and the current module may not be the highest index i    */
		 
          EX_active_module = module_table[i].module_my_id;
          EX_active_OS_num = module_table[i].obj_space_num;
          EX_ACTINV_OS_num = EX_active_OS_num;
          close_visible(save, EX_exec_id);
       }
    }
    IGEExit(0);
}

end implementation EX_exit;
