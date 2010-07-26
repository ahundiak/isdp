/* #######################    APOGEE COMPILED   ######################## */

class implementation COrclpnt;

#include <exdef.h>
#include <expriv.h>
#include <exmacros.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <igrtypedef.h>
#include <igetypedef.h>
#include <igrdp.h>
#include <gr.h>
#include <godef.h>
#include <go.h>
#include <griodef.h>
#include <grio.h>
#include <griomacros.h>
#include <grmessage.h>
#include <execmsg.h>
#include <msdef.h>
#include <msmacros.h>
#include <exlocale.h>
#include "dpgraphics.h"

#define debug 0 


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

extern struct EX_button EX_recallpnt[];  /* 10 pnts */
extern int   EX_pnt_entry, EX_pnt_entry_full;


/***********************************************************************/
/************************* EX_rclpnt wakeup method    ******************/
/***********************************************************************/

method wakeup(int pos)
{
   /*UI_message("Recall Points");*/
   ex$message(msgnumb = GRC_M_RecalPt);
   
   return(OM_S_SUCCESS);
}
/***********************************************************************/
/************************* EX_rclpnt sleep  method    ******************/
/***********************************************************************/

method super_cmd.sleep(int pos)
{
  IGRlong msg;
   UI_echo("");
   /*UI_prompt("");*/
   /*UI_status("");*/
   ex$message(msgnumb = EX_P_Clear,justification = RIGHT_JUS);
   ex$message(msgnumb = EX_S_Clear);

   DPerasecross(&msg);
   return(OM_S_SUCCESS);
}

/***********************************************************************/
/************************* EX_rclpnt execute method     ****************/
/***********************************************************************/

method execute(int *response; char *response_data; int pos)
{

    int   current, i, count, status, not_exit;
    int   temp_response;
    long  buff_size, index, msg;
    int   *subtype;
    struct EX_button *button;
    char  dismsg[EX_RCL_MAX_LEN];
    char  c;
    struct GRmd_env mod;
    struct EX_logkbd_buf log_buf;        

    not_exit = TRUE;
    index = 0;
    current = EX_pnt_entry ;
    buff_size = sizeof(struct EX_button);

    ex$get_cur_mod( id = & mod.md_id.objid , osnum = & mod.md_id.osnum );


  while( not_exit )
  {

    /*UI_prompt("Use up/down arrow key to recall previous point");*/
    /*UI_status("Use return key to accept point");*/
    ex$message(msgnumb = GR_P_UseArwKyRecalPt);
    ex$message(msgnumb = GR_I_UseRetKyAccPt);
    
    subtype = (int *)response_data + sizeof(struct EX_button);
    *subtype = GRst_REGULAR;
    ((struct GRevent *)response_data)->subtype = GRst_REGULAR;
    EX_get_input(response,response_data,EX_ALL_CHAR_MODE);

    switch( *response)
    { 
       case  D_RESET:
             *response = TERMINATE;
	     not_exit = FALSE;
	     break;
       case  RESET :
             break;
       case  DATA :
             button = (struct EX_button *)response_data;
             if( (*subtype == GRst_PREC_WLD) ||
	         (*subtype == GRst_DELTA_WLD) ||
		 (*subtype == GRst_DELTA_VIEW) ||
		 (*subtype == GRst_DIST_DIR) )
             {
                EX_recallpnt[EX_pnt_entry].x = button->x;
                EX_recallpnt[EX_pnt_entry].y = button->y;
                EX_recallpnt[EX_pnt_entry].z = button->z;
                temp_response = DATA;
                status = ex$putque( msg=&msg, pos=FRONT,
        	                    response = &temp_response,
        			    byte = &buff_size,
        			    buffer = (char *) &EX_recallpnt[EX_pnt_entry]);
	     }

             *response = TERMINATE;
             not_exit = FALSE;

             break;
       case  CHAR:
             	     	     	     
          count = strlen(response_data);

          for (i= 0; i< count; i++)	  
          {
              c = response_data[i];
              switch (c)
              {
                case  CARRIGE :
                    if (index > 0)
		    {
                        index++;
                        dismsg[index]='\0';
                        temp_response = CMD_STRING;
                        status = ex$putque( msg=&msg,pos=FRONT,
			                    response = &temp_response,
					    byte=&index,
					    buffer=dismsg);
                        index = 0;	
			not_exit = FALSE;				    
			*response = TERMINATE;
		    }
                    else  /* usr accept the point by <cr> */
		    {
                        temp_response = DATA;
                        status = ex$putque( msg=&msg,pos=FRONT,
			                    response = &temp_response,
					    byte=&buff_size,
					    buffer=(char *)&EX_recallpnt[EX_pnt_entry]);

                        *response = TERMINATE;
                        not_exit = FALSE;

                    }
                    break;

                 case  DEL     :
                    if(index >0)
         	    {
                       index--;
                       dismsg[index] = '\0';
                       UI_echo(dismsg);
         	    }
                    break;

                 case  FUNC    :
                       c = response_data[++i]; 
 		       status = EX_translate_funckey(c,&log_buf);
/*                       *response = TERMINATE;
                       not_exit = FALSE;
  */                  break;

                 case  TAB  :
                 case  FEED :
                 case  ESC     :
                 case  SUIMP   :
                 case  HOLD    :
                 case  BACK :
                 case  LEFT_ARROW    :
                 case  EX_LEFT_ARROW    :
                 case  RIGHT_ARROW   :
                 case  EX_RIGHT_ARROW   :
                    break;
                 case  DOWN_ARROW    :
                 case  EX_DOWN_ARROW    :
                   index = 0;
                   UI_echo(" ");
#if debug
                   printf("DOWN  current = %d, EX_pnt_entry = %d, \n", 
                           current, EX_pnt_entry);
                   printf("      EX_pnt_entry_full = %d, ",
                           EX_pnt_entry_full);
                   printf("EX_RCL_MAX_ENTRY = %d\n", EX_RCL_MAX_ENTRY);
#endif
                   if (current == EX_pnt_entry)
                   {
#ifdef X11
                      XBell(EXdisplay,0);
#else
                      keybd_bell(0);
#endif
                   }
                   else
                   { 
                      current++;
                      if(current >= EX_RCL_MAX_ENTRY ) current = 0;
                      gr$put_last_point( msg = &msg,
		                         sizbuf = &buff_size,
					 buffer = &EX_recallpnt[current]);
                      EX_recallpnt[EX_pnt_entry] = EX_recallpnt[current];
                      DPdrawcross(&msg,&EX_recallpnt[EX_pnt_entry]);
                      COdiscoords(&msg,&EX_recallpnt[EX_pnt_entry], &mod,KEYIN_FIELD,LEFT_JUS);

#ifndef IDRAW
                      status=co$update_current_point_form(msg = &msg);
#endif
                   }
                   break;
                case  UP_ARROW      :
                case  EX_UP_ARROW   :
                   index = 0;
                   current--;
#if debug
                   printf("UP    current = %d, EX_pnt_entry = %d, \n", 
                           current, EX_pnt_entry);
                   printf("      EX_pnt_entry_full = %d, ",
                           EX_pnt_entry_full);
                   printf("EX_RCL_MAX_ENTRY = %d\n", EX_RCL_MAX_ENTRY);
#endif
                   if(current < 0)
                   {
                      if( EX_pnt_entry_full == 1)
                      {
                          current = EX_RCL_MAX_ENTRY - 1;
                      }
                      else
                      {
#ifdef X11
                          XBell(EXdisplay,0);
#else
                          keybd_bell(0);
#endif
                          current = 0;
                      }
                   }    
                   if (current != EX_pnt_entry)
                   { 
                      gr$put_last_point( msg = &msg,
		                         sizbuf = &buff_size,
					 buffer = &EX_recallpnt[current]);
                      EX_recallpnt[EX_pnt_entry] = EX_recallpnt[current];
                      DPdrawcross(&msg,&EX_recallpnt[EX_pnt_entry]);
                      COdiscoords(&msg,&EX_recallpnt[EX_pnt_entry], &mod,KEYIN_FIELD,LEFT_JUS);

#ifndef IDRAW
                      status=co$update_current_point_form(msg = &msg);
#endif
                   }
                   else
                   {
#ifdef X11
                      XBell(EXdisplay,0);
#else
                      keybd_bell(0);
#endif
                   }
                   break;
  
                default :
                   UI_echo(" ");
                   dismsg[index] = c;
                   dismsg[index+1] = '\0';
                   UI_echo(dismsg);
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
end implementation COrclpnt;
