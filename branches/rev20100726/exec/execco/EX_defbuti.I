
class implementation EX_defbut;

#include <execmsg.h>
#include <igewindef.h>
#include <igewinmacros.h>
/*********************************************************************/
/*******************  EX_defbut wakeup method  ************************/
/*********************************************************************/

method wakeup(int pos)
{
/*    UI_message("Define Input Generator");*/
      ex$message(msgnumb = EX_M_DefInGen);

    return(OM_S_SUCCESS);
}

/*********************************************************************/
/*******************  EX_defbut execute method  ***********************/
/*********************************************************************/

method execute(int *response; char *response_data;int pos)
{
  int status;
  int scn,x,y,vsnum;
  int not_exit = TRUE;



  while( not_exit)
  {
/*     UI_prompt("Select Input Generator Command"); */
       ex$message(msgnumb = EX_P_SelInGen,justification = RIGHT_JUS);

       IGEinq_mouse_pos( &scn,&x,&y); 
       /* scn=0 right screen, 1 left screen */

       ige$inq_term_info( screen_no = scn, vs_no = &vsnum);
       MS_process_pocket(vsnum,x,y);

       EX_get_input(response,response_data,0);
       if ( (*response == D_RESET)  )
       {
             *response = TERMINATE;
             not_exit = FALSE;
       }
       else if ( *response == RESET)
       {
             ;/* do nothing */
       }
       else if( (*response == STRING ) || (*response == CMD_STRING)
                     || (*response == EX_CMD_KEY) )
       {
            status = EX_define_input_generator( response, response_data);
	    if ( status )
            {
              *response = TERMINATE;
              not_exit = FALSE;
    	    }
	    else 
	    {
               printf("status from EX_define_input_gen=<%d>\n",status);
                ex$message(msgnumb = EX_S_Invalid);
	    }
       }
       else
       {
              *response = TERMINATE;
              not_exit = FALSE;
       }

   }/*end while not exit*/
   ex$message(msgnumb = EX_S_Clear);

  return(OM_S_SUCCESS);
  }

end implementation EX_defbut;
