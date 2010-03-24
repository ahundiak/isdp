class implementation EX_rclkeyin;

#include <exmacros.h>
#include <exdef.h>
#include <expriv.h>
#include <execmsg.h>
#include <exlocale.h>
#include <string.h>
#include <exproto.h>
#include <exlocale.h>

#define debug 0

#ifdef X11
#   ifdef keybd_bell
#      undef keybd_bell
#   endif
#   define keybd_bell(n)
#endif

#define  ESCAPE_key      0x1b
#define  BACK            010
#define  TAB             011
#define  FEED            012
#define  CARRIGE         015
#define  ESC             033
#define  DEL             127
#define  SUIMP           0xffffff81
#define  HOLD            0xffffff82
#define  LEFT_ARROW      0xffffff80
#define  RIGHT_ARROW     0xffffff84
#define  DOWN_ARROW      0xffffff83
#define  UP_ARROW        0xffffff85
#define  FUNC            0xfffffffc
#define  FUNC1           0xfffffffe
#define  ENTER 		 0xffffff8d


extern char  EX_keyin_cmd[EX_RCL_MAX_ENTRY][EX_RCL_MAX_LEN]; /* 10 cmds, 80 char each */
extern char  EX_keybuff[];
extern int   EX_index; 
extern short EX_linebuffer_flag;
extern int   EX_entry, EX_entry_full;
extern UI_prompt();

/***********************************************************************/
/************************* EX_rclkeyin wakeup method ******************/
/***********************************************************************/

method wakeup(int pos)
{
   ex$message(msgnumb = EX_M_RclKeyin);
   return(OM_S_SUCCESS);
}
/***********************************************************************/
/************************* EX_rclkeyin sleep  method ******************/
/***********************************************************************/

method super_cmd.sleep(int pos)
{
   ex$message(field = KEYIN_FIELD, msgnumb = EX_M_Clear); 
   ex$message(msgnumb = EX_S_Clear); 
   return(OM_S_SUCCESS);
}

/***********************************************************************/
/************************* EX_rclkeyin execute method  ****************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{

    char  rest[EX_RCL_MAX_LEN];
    char  dismsg[EX_RCL_MAX_LEN];
    char  outmsg[EX_RCL_MAX_LEN];
    int   current , index;
    int   rindex, i;
    long  longEX_index;
    char c;
    int count;
    short entry;
    int status, not_exit;
    long msg;
    
    struct EX_logkbd_buf log_buf;

    not_exit = TRUE;

     current = 0;
     index = 0;
     rindex = EX_RCL_MAX_LEN - 1;
     rest[rindex] = '\0';
     rest[rindex-1] ='_';
     current = EX_entry;
  while( not_exit )
  {

    /*UI_prompt("Use arrow key to recall previous keyin");*/
    ex$message(msgnumb = EX_P_UseArrow,justification = RIGHT_JUS);
    EX_get_input(response,response_data,EX_ALL_CHAR_MODE);

    switch( *response)
    { 
       case  D_RESET:
             *response = TERMINATE;
	     not_exit = FALSE;
	     break;
       case  RESET :
             break;
       case  EX_CHAR:
             	     	     	     
          count = strlen(response_data);

          for (i= 0; i< count; i++)	  
          {
              c = response_data[i];
              switch (c)
              {
                case  TAB  :
                    break;
                case  FEED :
                    break;
                case  ENTER:
                case  CARRIGE :

                    current = EX_entry;
                    if (rindex < EX_RCL_MAX_LEN - 1)
                    {
                       strcat(EX_keyin_cmd[EX_entry],&rest[rindex]); 
                    }
                    strcpy(EX_keybuff,EX_keyin_cmd[EX_entry]);

                    if(EX_keybuff[0] != ESCAPE_key)
                       {
                       *response = STRING;
                       }
                    else
                       {
                       *response = CMD_STRING;
                       strip_esc_key(EX_keybuff);
                       }

                    EX_index = strlen(EX_keybuff);
                    EX_keybuff[EX_index] = 0;
                    EX_index++;
                    longEX_index = EX_index;/*ascii*/
                    status = ex$putque(msg = &msg, 
                                  pos = FRONT, 
                                  response = response, 
                                  byte = &longEX_index, 
                                  buffer = EX_keybuff);
                    EX_index = 0;
                    index = 0;   
                    EX_entry++;
                    if (EX_entry >= EX_RCL_MAX_ENTRY)
                    {
                        EX_entry = 0;
                        EX_entry_full = 1;
                    }
                    rindex = EX_RCL_MAX_LEN - 2;
                    rest[rindex] = '\0';
                    rest[rindex-1] = '_';
                    current = EX_entry;    
                    *response = TERMINATE;
                    not_exit = FALSE;
                    EX_init_keyboard();
                    UI_echo(" ");
                    break;
                 case  ESC     :
                    break;
                 case  DEL     :
                    if(index >0)
         	    {
                       index--;
                       EX_keyin_cmd[EX_entry][index] = '\0';
                       strcat(strcpy(dismsg,EX_keyin_cmd[EX_entry]),&rest[rindex-1]);
                       pad_escape(dismsg,outmsg);
                       UI_echo(outmsg);
         	    }
                    break;
                 case  SUIMP   :
                    break;
                 case  HOLD    :
                    break;
                 case  BACK :
     
                 case  LEFT_ARROW    :
		 case  EX_LEFT_ARROW:
                    if( index > 0 )
                    {
                       index--;
                       rindex--;
                       rest[rindex] = EX_keyin_cmd[EX_entry][index];
                       rest[rindex - 1] = '_';
                       EX_keyin_cmd[EX_entry][index] = '\0';
                       strcat(strcpy(dismsg,EX_keyin_cmd[EX_entry]),&rest[rindex-1]);
                       pad_escape(dismsg,outmsg);
                       UI_echo(outmsg);
                    }
                    break;
                 case  RIGHT_ARROW   :
                 case  EX_RIGHT_ARROW   :
                    if( rindex < EX_RCL_MAX_LEN - 1)
                    {
                        EX_keyin_cmd[EX_entry][index] = rest[rindex];
                        index++;
                        rest[rindex] = '_';
                        rindex++;
                        strcat(strcpy(dismsg,EX_keyin_cmd[EX_entry]),&rest[rindex-1]);
                        pad_escape(dismsg,outmsg);
                        UI_echo(outmsg);
                    }
                    break;
                 case  DOWN_ARROW    :
                 case  EX_DOWN_ARROW    :
                   rindex = EX_RCL_MAX_LEN - 1;
                   rest[rindex] = '\0';
                   rest[rindex-1] ='_';
      
                   UI_echo(" ");
                   if (current == EX_entry)
                   {
#ifndef NT
                      keybd_bell(0);
#endif
                      index = 0;
                   }
                   else
                   { 
                      current++;
                      if(current >= EX_RCL_MAX_ENTRY ) current = 0;
                      strcpy(EX_keyin_cmd[EX_entry],EX_keyin_cmd[current]);
                      index = strlen(EX_keyin_cmd[EX_entry]);
                      strcat(strcpy(dismsg,EX_keyin_cmd[EX_entry]),&rest[rindex-1]);
                      pad_escape(dismsg,outmsg);
                      UI_echo(outmsg);
                   }
                   break;
                case  UP_ARROW      :
                case  EX_UP_ARROW      :    
                   rindex = EX_RCL_MAX_LEN - 1;
                   rest[rindex] = '\0';
                   rest[rindex-1] ='_';
    
                   UI_echo(" ");
                   current--;
                   if(current < 0)
                   {
                      if( EX_entry_full == 1)
                      {
                          current = EX_RCL_MAX_ENTRY - 1;
                      }
                      else
                      {
#ifndef NT
                          keybd_bell(0);
#endif
                          current = 0;
                      }
                   }    
                   if (current != EX_entry)
                   { 
  
                      strcpy(EX_keyin_cmd[EX_entry],EX_keyin_cmd[current]);
                      index = strlen(EX_keyin_cmd[EX_entry]);
                      strcat(strcpy(dismsg,EX_keyin_cmd[EX_entry]),&rest[rindex-1]);
                      pad_escape(dismsg,outmsg);
                      UI_echo(outmsg);
                   }
                   else
                   {
#ifndef NT
                      keybd_bell(0);
#endif
                      current++;
                   }
                   break;
                case  FUNC    :
		case  FUNC1 :
                      c = response_data[++i]; 
                      entry = (short)(unsigned char)c;
		      status = EX_translate_funckey(entry,&log_buf);

                   break;
                default :

		    if ( ( unsigned char ) c & 0x80 )
		    { /*if sign bit set may have come from keypad*/
		      if( (( 0xb0 <= (unsigned char) c) && 
			( (unsigned char) c <= 0xb9 )) ||
			( (unsigned char) c == 0x8d ) ||
			( (unsigned char) c == 0xbd ) ||
			( ( 0xaa <= (unsigned char) c) && 
			( (unsigned char) c <= 0xaf )) 	 )
		      { /*b0-b9 are 0-9,8d = enter,ae = decimal*/
			 c = ( c & 0x7f ); /*pth valid ascii char from keypad*/
		      }
		    }/*end if & 80 */

                   UI_echo(" ");
                   EX_keyin_cmd[EX_entry][index] = c;
                   EX_keyin_cmd[EX_entry][index+1] = '\0';
                   strcat(strcpy(dismsg,EX_keyin_cmd[EX_entry]),&rest[rindex-1]);
                   pad_escape(dismsg,outmsg);
                   UI_echo(outmsg);
                   index++;   
                   break;
              }
    
          }
	  break; 
        default:
          not_exit = FALSE;
	  break; 
     }
   }
   return(1);
}
end implementation EX_rclkeyin;
