
class implementation EX_swapmenu;

#include <exdef.h>
#include <exmacros.h>
#include <execmsg.h>
#include <execcmd.h>
#include <OMminimum.h>
#include <MS.h>

#define debug 0

extern OM_S_OBJID EX_menu_id;

/***********************************************************************/
/************************* EX_swapmenu wakeup method *********************/
/***********************************************************************/

method wakeup(int pos)
{
             switch ( ME.super_cmd->mytype )
	     {
	        case EX_MENU_PANEL: 
	             ex$message(msgnumb = EXC_M_AtPnMn);
		     break;

		case EX_MENU_POCKET:    
	             ex$message(msgnumb = EXC_M_AtPcMn);
		     break;
                case EX_MENU_BAR: 
	             ex$message(msgnumb = EXC_M_AtBrMn);
		     break;
		case EX_MENU_F_KEY:     
	             ex$message(msgnumb = EX_M_LoadFunKey);
		     break;
	        default  :
                     break; 
	     }

   return(OM_S_SUCCESS);
}

/***********************************************************************/
/************************* EX_swapmenu execute method ********************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{
  extern char CS_path_name[];    
  int not_exit;
  int mode;
  int menu_type;

  not_exit = TRUE;
  mode = 1;
      
   while( not_exit )
   {
      switch(ME.super_cmd->state)
      {
          case 0:  /* on inter pro 32 */

             switch ( ME.super_cmd->mytype )
	     {
	        case EX_MENU_PANEL: 
/*                     UI_prompt( "Keyin menu panel file name >");*/
	             ex$message(msgnumb = EX_P_GetPanel,justification = RIGHT_JUS);
		     menu_type = PANEL_MENU;
		     break;
		case EX_MENU_POCKET:    
/*                     UI_prompt( "Keyin pocket menu file name >");*/
	             ex$message(msgnumb = EX_P_GetPocket,justification = RIGHT_JUS);		     
		     menu_type = POCKET_MENU;
		     break;
                case EX_MENU_BAR: 
/*                     UI_prompt( "Keyin menu bar file name >");*/
	             ex$message(msgnumb = EX_P_GetStrip,justification = RIGHT_JUS);
		     menu_type = BAR_MENU;
		     break;
/*		case EX_MENU_F_KEY:     
	             ex$message(msgnumb = EX_P_GetFKeyName,justification = RIGHT_JUS);
		     menu_type = FUNC_KEY;
		     break; 
*/		     
	        default  :
                    menu_type = -1;
		    not_exit = FALSE;
		    *response = TERMINATE;
	     }
             EX_get_keyin( response, response_data, mode);

             if ((*response == STRING) && ( strlen(response_data)))
             {
                 /*UI_status("Loading");*/
                 ex$message(msgnumb = EX_S_Loading);
		 MS_swap_menu( menu_type,response_data);
		 not_exit = FALSE;
		 *response = TERMINATE;
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

end implementation EX_swapmenu;
