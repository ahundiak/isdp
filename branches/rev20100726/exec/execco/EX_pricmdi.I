class implementation EX_pricmd;

#include <exmacros.h>
#include <execmsg.h>
#include <execcmd.h>
#include <expriv.h>
#include <UMS.h>
#define debug 0



/***********************************************************************/
/************************* EX_funcky wakeup method *********************/
/***********************************************************************/

method wakeup(int pos)
{
/*     UI_message("Print Command");*/
   ex$message(msgnumb = EXC_M_PrintCmd); 
   return(OM_S_SUCCESS);
}

/***********************************************************************/
/************************* EX_funcky execute method ********************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{
  extern char CS_path_name[];    
  extern struct EX_global EX_global_var;
  int not_exit;
  int mode, status,kmode;
  char path[UMS_MAX_BUFLEN];
  struct EX_cmd cmdstr;


  not_exit = TRUE;
  mode = 1;
      
   while( not_exit )
   {

  /*           UI_prompt( "Keyin output file name/or select button >");*/
             ex$message(msgnumb = EX_P_GetBtn,justification = RIGHT_JUS); 
             EX_get_input( response, response_data, mode);


         if (*response == STRING)
          {
               /*  UI_status("Writing to output file");*/
                  ex$message(msgnumb = EX_S_WriteFile); 
                 if ( strchr (response_data,'/') ) /* user specified / */
                 {                  
                     strcpy(path,response_data);
                 }
                 else   /* user did not specify / , assume in cwd */
                 {
                     strcpy(path, EX_global_var.working_dir);
		     strcat( path,response_data);
		 }
		 status = EX_print_cmd(path);
		 if (! (1 & status) )
		 {
	            /*ex$message(msgnumb = EX_F_CanNotLFkey); */
		    printf("can not write to output %s\n",path);	
		 }
                 *response = TERMINATE;
		 not_exit = FALSE;
        }/*end if STRING*/
       else if (( *response == CMD_STRING) || ( *response == EX_CMD_KEY))
        {
                 kmode = EX_CMD_KEY;
		 if( *response == CMD_STRING ) kmode = EX_STRING; 
                 status = ex$get_cmd_info(string=response_data,mode=kmode,
		                          cmdstr=&cmdstr);                   
                 if( status == 0 )
		 {
		    UI_status("INVALID COMMAND"); 
                    if( *response == CMD_STRING )
		    {
		        strcpy(path, "string=");
		    }
		    else
		    {
		        strcpy(path,"cmd key=");
		    }
		    strcat(path,response_data);
		    path[50] = '\0';
		    UI_echo(path);
		 }/*end if bad status*/
                 else
		 {
                    strcpy(path,"cmd key=");
  	  	    strcat(path, cmdstr.command_key);
		    UI_echo(path);
            strncpy(path, cmdstr.command_name_ptr,
                                        UMS_MAX_BUFLEN);

	  	    UI_status(path);

                }
	     }
             else if ( *response == EX_POCKET )
	     {     
	        not_exit = FALSE;
	     }
             else 
             {
                UI_echo("");
                not_exit = FALSE;                       
                *response = TERMINATE; 
             }
             /*UI_status(" ");*/


   }   
   ex$message(msgnumb = EX_S_Clear);
   return(OM_S_SUCCESS);

}

end implementation EX_pricmd;
