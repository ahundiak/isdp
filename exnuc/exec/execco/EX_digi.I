class implementation EX_dig;

#include "exsysdep.h"
#include <stdio.h>
#include <OMindex.h>
#include <OMminimum.h>
#include <ex.h>
#include <expriv.h>
#include <exmacros.h>
#include <execmsg.h>
#include <string.h>
#include <exproto.h>
#include <MS.h>

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <limits.h>

extern Display *EXdisplay;
extern int      EXscreen;
extern int      Help_active();

#define MAX_WINDOW    40
#define MAX_REGION    20
#define MAX_TOTAL     60
extern unsigned int EX_win[MAX_TOTAL];
extern int          EX_scr[MAX_TOTAL];
#endif

#define debug  0
#define BUFSIZE  512

from IGEdigwin import create;
from IGEgadget import activate;
from IGEwsys   import clear;

extern struct EXevent_queue *event_queue_front;
extern struct EX_pmenu_entry EX_paper_menu[EX_PMENU_NUM]; 

/***********************************************************************/
/************************* EX_dig sleep method ***********************/
/***********************************************************************/

method super_cmd.sleep(int pos)
{
    ex$message(msgnumb = EX_M_Clear);
    ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
    ex$message(msgnumb = EX_S_Clear);
    return(OM_S_SUCCESS);
 }

/***********************************************************************/
/************************* EX_dig wakeup method *********************/
/***********************************************************************/

method wakeup(int pos)
{
   if (ME.super_cmd->mytype == 0 )
   {
       ex$message(msgnumb = EX_M_LoadMenu);
   }
   else if (ME.super_cmd->mytype == 1 )
   {
       ex$message(msgnumb = EX_M_DetachMenu);
   }
   
   return(OM_S_SUCCESS);
}

/***********************************************************************/
/************************* EX_dig execute method ********************/
/***********************************************************************/
method execute(int *response; char *response_data; int pos)
{
  OM_S_OBJID win_objid, old_win_objid ; 
  long msg;
  int not_exit;
  int mode, status, file_status;
  int i,j,entry_found, number_objs;
  int fm; /* non zero for floating menu , 0 for digitizer */
  int origx,origy;
#if defined (ENV5)
  int digix,digiy; /* abs digitizer area */
#endif


  struct EX_button *my_pnt;
  OM_S_OBJID  mod_id;
  OMuword osnum, mod_osnum;
  char path[256];
  char class_name[OM_K_MAXCLASS_LEN];
  char new_string[OM_K_MAXOSNAME_LEN];

  extern struct EX_pmenu_entry EX_paper_menu[];
  char result[100];  
/*  char  s[BUFSIZE];*/
  int   file_found=0;
  struct EX_paper_cmd *cmdptr;
  int    num_cmd;
  int    index_num, old_index_num,prompt_status;

#if defined( CLIX ) && defined( X11 )
  int    dig_avail, flt_avail;
#endif

  not_exit = TRUE;
  mode = EX_LINE_MODE;
  fm = -1;
  osnum = 1;


if( ME.super_cmd->mytype == 0 )  /* attach paper menu */
{
      
  while( not_exit )
  {
  
     switch(ME.super_cmd->state)
     {
      case 0: 
#if defined ( ENV5 )             
             if( (status = Inq_dig_fm(&digix,&digiy)) == 0)
             {
               fm = 1;  /* indicate floating menu */
             }
	     else
	     {
	       if( (status = Inq_dig(&digix,&digiy)) == 0)
	       {
	          fm = 0;
	       }
	       else
	       {
		   /*UI_error("No digitizer attached to workstation\n");*/
		   ex$message(msgnumb = EX_F_NoDigitizer);
		   *response = TERMINATE;            
		   not_exit = FALSE;
	       }
	     }
#endif
#if defined( CLIX ) && defined( X11 )
             
             XQueryDigitizerAvailable( EXdisplay, &dig_avail, &flt_avail );
             if( dig_avail )
	     {
	        if( flt_avail) fm = 1;
		else fm = 0;
	     }
	     else
	     {
		   ex$message(msgnumb = EX_F_NoDigitizer);
		   *response = TERMINATE;            
		   not_exit = FALSE;
	     }
#endif

             if ( fm >= 0 )
             {
                 entry_found = FALSE;

                 for (i=0; i<EX_PMENU_NUM; i++)
		 {
                     if( EX_paper_menu[i].win_id == NULL_OBJID )
		     {
		         entry_found = TRUE;
			 break;
	             }
 		 }
                 if ( entry_found )
		 {
                    if ( event_queue_front == 0 )
                    {
                        UI_prompt( "Keyin menu file name >");
                        ex$message(msgnumb = EX_P_GetFName,justification = RIGHT_JUS);
                    }
                    file_found = FALSE;
                    EX_get_keyin( response, response_data, mode);
		 }
		 else
		 {
                     /*UI_error("Paper Menu Entry Full");*/
                     ex$message(msgnumb = EX_F_PMenuFull);
		     *response = TERMINATE;
		     not_exit = FALSE;
		 }
             }    
    
             if (*response == STRING)
             {
                 if ( strchr (response_data,'/') ) /* user specified / */
                 {                  
                     strcpy(path,response_data);
                     module_build_path(path); 
		     file_status = file_exists(path,0,0,new_string);
		     if ( file_status < 0 ) /* file not exists */
                     {
			ex$message(msgnumb = EX_F_FileNotExist);
			*response = TERMINATE;
			not_exit = FALSE;  
			break;
		     }
		     else
		     {
                         strcpy(ME.EX_dig->path,path);
                         file_found = TRUE;
		     }
                 }
                 else   /* user did not specify / , assume in path */
                 {
                 /* in current directory ? */
                    status = TRUE;	
  	            strcpy(path,response_data);
 	            file_status = file_exists(path,0,0,new_string);
	            if ( file_status >= 0 ) /* file exists */
                    {
                       file_found = TRUE; 
	               status = FALSE;  /* stop the for loop */
                       strcpy(ME.EX_dig->path,path);
	            }
                 /* in config path ? */
    		    for( j=0; status == TRUE; j++)
		    {
                       status = ex$get_path( index=j, path=path, len=sizeof(path) );
                       if ( status )
		       {
                          strcat(path,"config/");
		          strcat(path,response_data);
                          strcpy(ME.EX_dig->path,path);
		       }

		       file_status = file_exists(path,0,0,new_string);
		       if ( file_status >= 0 ) /* file exists */
                       {
                          file_found = TRUE;
		          status = FALSE;  /* stop the for loop */
		       }
		    } /* end for j */
		    if ( !file_found)
		    {
                       ex$message(msgnumb = EX_F_FileNotExist);
                       not_exit = FALSE;
                       *response = TERMINATE;
  	            }
                 }

		 /* we found the file , since we did not change *response */
                 /* go for case 1 */
		 
                 if (file_found ) ME.super_cmd->state = 1;

             }
             else if( *response == D_RESET )
	     {
                  not_exit = FALSE;
                  *response = TERMINATE;
	     }
             else if( *response == RESET)
	     {
		  EX_init_keyboard();   
                  ex$message(field = KEYIN_FIELD, msgnumb = EX_M_Clear); 
	     }
             else
	     {
                  not_exit = FALSE;
	     }
             break;
             
      case 1:    /* got file name */


             ex$message(msgnumb = EX_P_IdenOrg,justification = RIGHT_JUS);
#if defined ( ENV5 )             
             if( (status = Inq_dig_fm(&digix,&digiy)) == 0)
             {
               fm = 1;  /* indicate floating menu */
             }
	     else
	     {
	       if( (status = Inq_dig(&digix,&digiy)) == 0)
	       {
	          fm = 0;
	       }
	       else
	       {
		   /*UI_error("No digitizer attached to workstation\n");*/
		   ex$message(msgnumb = EX_F_NoDigitizer);
		   *response = TERMINATE;            
		   not_exit = FALSE;
	       }
	     }
#endif
#if defined( CLIX ) && defined( X11 )
             
             XQueryDigitizerAvailable( EXdisplay, &dig_avail, &flt_avail );
             if( dig_avail )
	     {
	        if( flt_avail) fm = 1;
		else fm = 0;
	     }
	     else
	     {
		   ex$message(msgnumb = EX_F_NoDigitizer);
		   *response = TERMINATE;            
		   not_exit = FALSE;
	     }
#endif

             status = ex$set_abs_dig(fm=fm);
             if (! (1&status) )
             {
                 printf(" construct abs digitizer error\n");
                 *response = TERMINATE;
                 not_exit = FALSE;
                 return(0);
             }

             EX_get_input( response, response_data, mode); 
             if( *response == ABS_DIG )
             {
                 ex$message(msgnumb = EX_S_Loading);
                 ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
                 my_pnt = (struct EX_button *)response_data;
                 origx = (int) my_pnt->x;                       
                 origy = (int) my_pnt->y;

                 status = ex$clear_abs_dig();
                 if(!(1&status))
                 {
                     printf("\n can not delete IGEabsdig\n");
                 }

	      /* check to see if menu already attached before */

		 cmdptr = NULL;
		 num_cmd = 0;
		 old_win_objid = NULL_OBJID;
                 old_index_num = -1;
		 for (i=0; i<EX_PMENU_NUM; i++)
		 {
		     if(!strcmp(EX_paper_menu[i].menu_name,ME.EX_dig->path))
   		     {
                         old_index_num = i;
			 cmdptr = EX_paper_menu[i].p_cmd;
			 num_cmd  = EX_paper_menu[i].num_of_cmds;
                         old_win_objid = EX_paper_menu[i].win_id;
			 break;
		     }
 		 }
	         
              /* construct IGEdigwin */	
                 status = om$construct(classname = "IGEdigwin",
					   osnum = osnum,
					 p_objid = &win_objid,
                               msg = message IGEdigwin.create (fm,origx,origy,
			                 ME.EX_dig->path, &num_cmd, &cmdptr) );

                 if (! (1&status) )
                 {
                    om$report_error(sts=status);
                    printf(" construct IGEdigwin error <%s>\n",ME.EX_dig->path);
                    ME.super_cmd->state = 0;
                 }
		 else
		 {
		     status = om$send(msg = message IGEgadget.activate(&msg,-1),
                                     targetid = win_objid,
                                     targetos = osnum);
                     if(!(1&status))
                     {
                        om$report_error(sts=status);
                        printf("IGEdigwin activate error <%s>\n",ME.EX_dig->path);
                        ME.super_cmd->state = 0;
                     }
                     else
		     {
                        index_num = -1;
			entry_found = FALSE;
			for (i=0; i<EX_PMENU_NUM; i++)
			{
			    if( EX_paper_menu[i].win_id == NULL_OBJID )
   			    {
				entry_found = TRUE;
                                index_num = i;
				EX_paper_menu[i].win_id = win_objid;
				EX_paper_menu[i].p_cmd = cmdptr;
				EX_paper_menu[i].num_of_cmds = num_cmd;
				strcpy(EX_paper_menu[i].menu_name,ME.EX_dig->path);
				break;
			    }
 			}
                        /* delete old window */
			/* add to the table first, after delete then update */
			/* because delete will free mem if last one deleted */
                        if( old_win_objid != NULL_OBJID )
			{
                           status = om$send(msg = message IGEdigwin.delete(0),
	                            targetid = old_win_objid,
                                    targetos = osnum);
                           if(!(1&status))
                           {
                              om$report_error(sts=status);
                              printf("\n IN EX_digi.I IGEdigwin delete error\n");
                           }
			}
                        /* update new entry */
                        if( old_index_num != -1 && index_num != -1 )
			{
                   	    EX_paper_menu[old_index_num].win_id = 
			         EX_paper_menu[index_num].win_id ;
			    EX_paper_menu[index_num].win_id = NULL_OBJID;
			    EX_paper_menu[index_num].p_cmd = NULL;
			    EX_paper_menu[index_num].num_of_cmds = 0;
			}
			ME.super_cmd->state = 2; 
                     }
                 }
             }
             else if( *response == D_RESET )
	     {
                 status = ex$clear_abs_dig();
                 if(!(1&status))
                 {
                     printf("\n can not delete IGEabsdig\n");
                 }
#                if debug
                    printf("clear abs dig success,  origx= %d,  origy=%d\n", origx, origy);
#                endif 
                 not_exit = FALSE;
                 *response = TERMINATE;
	     }
             else if ( *response == RESET )
	     {
                 status = ex$clear_abs_dig();
                 if(!(1&status))
                 {
                     printf("\n can not delete IGEabsdig\n");
                 }
#                if debug
                    printf("clear abs dig success,  origx= %d,  origy=%d\n", origx, origy);
#                endif 
                 ME.super_cmd->state = 0;   
             }
             else
	     {
                 status = ex$clear_abs_dig();
                 if(!(1&status))
                 {
                     printf("\n can not delete IGEabsdig\n");
                 }
                 not_exit = FALSE;
	     }

             ex$message(msgnumb = EX_S_Clear);
             break;

      case 2: /* load success, check for screen menu */
      
             number_objs = 0;
             ex$get_cur_mod (id = &mod_id, osnum = &mod_osnum);

             if ( MS_menus_displayed() )
	     {
              /*   UI_prompt("Do you want to delete screen menus? y/n ");*/
               prompt_status = ex$create_prompt(message_no = EX_P_DelScnMenu,
                                        left_prompt =EX_P_Yes,
                                        right_prompt =EX_P_No,
                                        response = response,
                                        response_data =response_data);


                 if( *response == STRING )
                 {
                    if( prompt_status == EX_LEFT_MATCH    )
		    {
                       MS_erase_menus(); 

		    }
                    EX_set_mod_no_scn_menu(mod_osnum);
                    not_exit = FALSE;
		    *response = TERMINATE;
                 }
                 else if( *response == D_RESET )
                 {
                     not_exit = FALSE;
                     *response = TERMINATE;
                 }
                 else if ( *response == RESET )
	         {
                     response_data[0] = '\0';
		     EX_init_keyboard();
		     UI_echo(" ");
                 }
                 else
	         {
                    not_exit = FALSE;
	         }
	     }
             not_exit = FALSE;
	     *response = TERMINATE;

             break;
      default:
         break;
     }

  }   
  ex$message(msgnumb = EX_S_Clear);
  return(OM_S_SUCCESS);
}
else if( ME.super_cmd->mytype == 1 )  /* detach paper menu */
{
#if defined ( ENV5 )             
    if( (status = Inq_dig_fm(&digix,&digiy)) == 0)
    {
       fm = 1;  /* indicate floating menu */
    }
    else
    {
       if( (status = Inq_dig(&digix,&digiy)) == 0)
       {
           fm = 0;
       }
       else
       {
 	   /*UI_error("No digitizer attached to workstation\n");*/
	   ex$message(msgnumb = EX_F_NoDigitizer);
	   *response = TERMINATE;            
	   not_exit = FALSE;
       }
   }


#endif
#if defined( CLIX ) && defined( X11 )
             
    XQueryDigitizerAvailable( EXdisplay, &dig_avail, &flt_avail );
    if( dig_avail )
    {
       if( flt_avail) fm = 1;
       else fm = 0;
    }
    else
    {
       ex$message(msgnumb = EX_F_NoDigitizer);
       *response = TERMINATE;            
       not_exit = FALSE;
    }

#endif
    if( fm >= 0 )
    {
      status = FALSE;  /* stop the for loop */
      for (i=EX_PMENU_NUM - 1; i> -1; i--)
      {
	if(EX_paper_menu[i].win_id != NULL_OBJID) 
   	{
           /*UI_prompt( "Do you want to delete <file> >");*/
         prompt_status = ex$create_prompt(message_no = EX_P_Delete,
                                        left_prompt =EX_P_Yes,
                                        right_prompt =EX_P_No,
                                        string = EX_paper_menu[0].menu_name,
                                        response = response,
                                        response_data =response_data);




           status = TRUE;    
           if (*response == STRING)
           {
              if( prompt_status == EX_LEFT_MATCH    )
              {
                 win_objid = EX_paper_menu[i].win_id;
	         ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);

                 status = om$is_objid_valid(osnum = osnum, objid = win_objid);
	         if ( 1 & status )
	         {
                    status = om$get_classname( osnum = osnum, objid = win_objid,
	                                   classname = class_name);
                    if( 1 & status )
                    {
	               if( ! strcmp( "IGEdigwin", class_name ) )
                       {        					
                          status = om$send(msg = message IGEdigwin.delete(0),
	                              targetid = win_objid, targetos = osnum);
                          if(!(1&status))
                          {
                             om$report_error(sts=status);
                             printf("\n IN EX_digi.I IGEdigwin delete error\n");
                          }
                          else
			  {
                             strcat( strcpy(result,EX_paper_menu[i].menu_name)," detached");

			     EX_paper_menu[i].win_id = NULL_OBJID;
			     EX_paper_menu[i].p_cmd = NULL;
			     EX_paper_menu[i].menu_name[0] = '\0';
                             ex$message(msgnumb = EX_S_Var1, type="%s",var=result); 
                             sleep(3);
			  }
                       }
                       else
	               {
                          /*UI_error("no paper menu attached 3\n");*/
                          ex$message(msgnumb = EX_S_NoPaperMenu);
                          not_exit = FALSE;
                          *response = TERMINATE;
		       }
                    }
                    else
	            {
                       /*UI_error("no paper menu attached 2\n");*/
                       ex$message(msgnumb = EX_S_NoPaperMenu);
                       not_exit = FALSE;
                       *response = TERMINATE;
	            }
	         }
	         else
	         {
                    /*UI_error("no paper menu attached\n");*/
                    ex$message(msgnumb = EX_S_NoPaperMenu);
                    not_exit = FALSE;
                    *response = TERMINATE;
                 }
             }
	   }
           else if( *response == D_RESET )
	   {
                not_exit = FALSE;
                *response = TERMINATE;
	   }
           else if( *response == RESET)
	   {
		EX_init_keyboard();   
                UI_echo(" ");
     	   }
           else
	   {
                not_exit = FALSE;
           }
        }
      }
    }
    ME.super_cmd->state = 0;
    *response = TERMINATE;
 }
 return(OM_S_SUCCESS);
}

end implementation EX_dig;
