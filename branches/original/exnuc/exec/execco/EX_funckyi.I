
class implementation EX_funcky;

#include <exmacros.h>
#include <execmsg.h>
#include <string.h>
#include <stdio.h>
#include <exproto.h>

#define debug 0




/***********************************************************************/
/************************* EX_funcky wakeup method *********************/
/***********************************************************************/

method wakeup(int pos)
{
   ex$message(msgnumb = EX_M_LoadFunKey);
   return(OM_S_SUCCESS);
}

/***********************************************************************/
/************************* EX_funcky execute method ********************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{
  extern char CS_path_name[];    
  int not_exit, j;
  int mode, status, result;
  char path[256];
  int EX_load_funckey();

  not_exit = TRUE;
  mode = 1;
      
   while( not_exit )
   {
      switch(ME.super_cmd->state)
      {
          case 0:  /* on inter pro 32 */

             /*UI_prompt( "Keyin function file name >");*/
             ex$message(msgnumb = EX_P_GetFKeyName,justification = RIGHT_JUS);
             EX_get_keyin( response, response_data, mode);

             if (*response == STRING)
             {
                 /*UI_status("Loading");*/
                 ex$message(msgnumb = EX_S_Loading);
                 if ( strchr (response_data,'/') ) /* user specified / */
                 {                  
                     strcpy(path,response_data);
                     module_build_path(path);
		     status = EX_load_funckey( EX_UPDATE,path);
		     if (! (1 & status) )
		     {
	                ex$message(msgnumb = EX_F_CanNotLFkey);
			printf("can not load function key %s\n",path);	
		     }
		     else
		     {
			 *response = TERMINATE;
			 not_exit = FALSE;
		     } 
                 }
                 else   /* user did not specify / , assume in mod_type_x */
                 {
                 /* in current directory ? */
                    status = TRUE;	
                    result = 0;
  	            strcpy(path,response_data);
		    result = EX_load_funckey( EX_UPDATE,path);
		    if (1 & result )  /* load function key success */
		    {
	               status = FALSE;  /* stop the for loop */
	            }
                 /* check config path */ 
		    for( j=0;status == TRUE; j++)
		    {
		       status = ex$get_path( index=j, path=path, len=sizeof(path) );
                       if (status)
		       {
			   strcat(path,"config/");
			   strcat(path,response_data);
			   result = EX_load_funckey( EX_UPDATE,path);
			   if (1 & result )
			   {
			       *response = TERMINATE;
			       not_exit = FALSE;
			       break;
			   } 
                       }
		    }
		    if( ! result )
		    {
	                ex$message(msgnumb = EX_F_CanNotLFkey);
			printf("can not load function key %s\n",path);	
		    }
		 }
             }
             else 
             {
                not_exit = FALSE;                       
             }
             /*UI_status(" ");*/
             ex$message(msgnumb = EX_S_Clear);
             break;

          default:
             break;
      }

   }   

   return(OM_S_SUCCESS);

}

end implementation EX_funcky;
