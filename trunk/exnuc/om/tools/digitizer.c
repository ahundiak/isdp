#include <stdio.h>
#include <sdl.h>
#include <tools.h>
#include <ctype.h>
#include <signal.h>

#define  debug 0
FILE *fp;
main()
{
    int mask = 1;
    int em;
    int got_button,got_keyin;
    int count;
    int w_no,x,y,x1,y1,button,tran,time;
    int xx1,yy1,xx2,yy2;
    int fm1,rno,rno1, region;
    int atoi(), resp = 0;
    char kbd[512];
    FILE *fopen();


    extern FILE *fp;

    EX_set_interrupt();
    Enter_tools();
    Enable_events(BUTTON_EVENT | KEYIN_EVENT);
    Set_message_mode(1);
    Set_keyin_buffer(kbd,100);
    showcursor(0);
    flushbuffer(0);

    Inq_dig(&x,&y);
    Create_dig_region(0,0,0,x,y,&rno);   
    Inq_trackarea(&fm1,&xx1,&yy1,&xx2,&yy2);
/*    Set_trackarea(0,0,0,5000,5000);*/
    Process_keyin(1,3,"Input paper menu file name > ");

    Wait_for_next(KEYIN_EVENT,&em);         
    Get_keyin_data(&count);    

    fp =  (FILE *) fopen(kbd,"w"); 
    if (fp)
    {        
        Set_dig_btn(rno,mask);

        got_button = 0;
        while( !got_button)
        {
            Clear_button_data();

            Display_message(1,3,"Give origin (lower left corner of menu, use command button only)");
            Wait_for_next(BUTTON_EVENT, &em);
            Get_button_data(&w_no,&x,&y,&button,&tran,&time);
#if debug
            printf("w_no=%d x=%d y=%d button=%d tran=%d\n",w_no,x,y,button,tran);
#endif
            if ( tran == DOUBLE_CLICK) 
            {
               getout( rno,fp);                
            }
            if ( tran & ( DOWN | SINGLE_CLICK ) )
            {
                 got_button = 1;
            }
        }


        got_button = 0;  
        while( !got_button)
        {
            Clear_button_data();

            Display_message(1,3, "Give diagonal point (upper right corner of menu, use command button only)");

            Wait_for_next(BUTTON_EVENT, &em);
            Get_button_data(&w_no,&x1,&y1,&button,&tran,&time);
#if debug
            printf("w_no=%d x=%d y=%d button=%d tran=%d\n",w_no,x,y,button,tran);
#endif
            if( tran & ( DOWN | SINGLE_CLICK ) )
            {
                 got_button = 1;
            }
            else
            if (tran == DOUBLE_CLICK) 
            {
                 getout(rno,fp);
            }
         }
         printf("ext_x = %d, ext_y = %d\n",x1-x,y1-y);
      
         fprintf(fp,"%d %d\n",x1-x,y1-y);

         Delete_dig_region(rno);        
         Create_dig_region(0,x,y,x1,y1,&rno1);   


         Set_dig_btn(rno1,mask);       
         button = 0;

         while( 1 )
         {
            

             got_button = 0;
             while (!got_button  )
             {
                 Clear_button_data();

                 Display_message(1,3,"Enter 1st diagonal point of box (command button only,double command to exit)");
                 Wait_for_next(BUTTON_EVENT, &em);
                 Get_button_data(&w_no,&x,&y,&button,&tran,&time);
#if debug
                 printf("w_no=%d x=%d y=%d button=%d tran=%d\n",w_no,x,y,button,tran);
#endif
                 if ( tran == DOUBLE_CLICK )
                 {
                     getout(rno1,fp);
                 }
                 else if (tran & ( DOWN | SINGLE_CLICK )  )
                 {
                     Digposition(rno1,&x,&y,&region);
                     if(region)
                     {
                        printf("x = %d  y= %d \n",x,y);
                        got_button = 1;
/*                        Keybdbell(0); */
                     }
                 }
              }



             got_button = 0;
             while( !got_button )
             {
                 Clear_button_data();

                 Display_message(1,3,"Enter 2nd diagonal point of box (command button only,double command to exit)");

                 Wait_for_next(BUTTON_EVENT, &em);
                 Get_button_data(&w_no,&x1,&y1,&button,&tran,&time);

#if debug
                 printf("w_no=%d x=%d y=%d button=%d tran=%d\n",w_no,x,y,button,tran);
#endif

                 if ( tran == DOUBLE_CLICK )
                 {
                     getout(rno1,fp);
                 }
                 else if (tran & ( DOWN | SINGLE_CLICK )  )
                 {

                   Digposition(rno1,&x1,&y1,&region);
                   if(region)
                   {
                     printf("x1= %d  y1= %d \n",x1,y1);
/*                      Keybdbell(0); */
                     got_button = 1;
                   }
                }
             }
             if ( x1 < x)  x1 ^= x ^= x1 ^= x;
             if ( y1 < y)  y1 ^= y ^= y1 ^= y;

            printf("box x_ext = %d box y_ext= %d\n",x1-x,y1-y);
            
            if( (x1 - x) <= 200 || (y1 - y) <= 200)
            {
                Display_message(1,3,"points are the same/too close,  re-enter please");    
                printf("points are the same/too close,  re-enter please\n\n");
                got_button = 0;
                button = 0;
                Keybdbell(1);
                sleep(4);
            }
            else
            {
                got_keyin = 0;
                while( !got_keyin )
                {             
                   Clear_keyin_data();
		   
                   Process_keyin(1,3,"keyin response associated with this box > ");
                   Wait_for_next(KEYIN_EVENT ,&em);

                   Get_keyin_data(&count);    
                   if ( strlen(kbd) < 1 || strlen(kbd) >2 )
                   {
                      printf("keyin a number please\n");
                      Keybdbell(0);
                      sleep(1);
                      Keybdbell(0);
                      got_keyin = 0;
                   }
                   else
                   {
		      resp = atoi(kbd);	
                      if ( resp == 0 )
		      {
		         printf(" keyin a number please\n");
                         Keybdbell(0);
                         sleep(1);
                         Keybdbell(0);
			 got_keyin = 0;
		      }
		      else
		      {
                         printf("     response = %d\n",resp);    
                         Clear_message(1);
                         got_keyin = 1;
		      }
                   }
               }               
                got_keyin = 0;
                while( !got_keyin )
                {             
                   Clear_keyin_data();
		   
                   Process_keyin(1,3,"keyin command key/string associated > ");
                   Wait_for_next(KEYIN_EVENT,&em);
                   Get_keyin_data(&count);    
                   if ( strlen(kbd) < 1)
                   {
                      Keybdbell(0);
                      sleep(1);
                      Keybdbell(0);
                      got_keyin = 0;
                   }
                   else
                   {
                      printf("     cmd_string = %s\n\n",kbd);    
                      fprintf(fp,"%d,%d,%d,%d,%d,%s\n",x,y,x1,y1,resp,kbd);
                      Clear_message(1);
                      got_keyin = 1;
                   }
               }               
            }
        }
    }
    else
    {
        Exit_tools();
        printf("\ncan not open output file\n");
    }   
    exit(1);
}

getout( rno1, fp)
 int rno1;
 FILE *fp;
{
          Delete_dig_region(rno1);
          fclose(fp);
          Exit_tools(); 
          exit(1);
}




static void   (*oldhup)();
static void   (*oldint)();
static void   (*oldquit)();
static void   (*oldill)();
static void   (*oldiot)();
static void   (*oldemt)();
static void   (*oldfpe)();
static void   (*oldbus)();
static void   (*oldsegv)();
static void   (*oldsys)();
static void   (*oldpipe)();
static void   (*oldterm)();


void EX_interrupt_dig(signo)
int signo;
{
   fflush(stdout);

   if ((oldhup != SIG_IGN) && (oldhup != SIG_DFL) ) oldhup(signo);
   fclose(fp);
   exit(signo);
}


int EX_set_interrupt()
{
extern  void EX_interrupt_dig();      



  oldint = signal(SIGINT,EX_interrupt_dig);
  oldquit= signal(SIGQUIT,EX_interrupt_dig);      
  oldill = signal(SIGILL,EX_interrupt_dig);
  oldiot = signal(SIGIOT,EX_interrupt_dig);
  oldemt = signal(SIGEMT,EX_interrupt_dig);
  oldfpe = signal(SIGFPE,EX_interrupt_dig);
  oldbus = signal(SIGBUS,EX_interrupt_dig);
  oldsegv= signal(SIGSEGV,EX_interrupt_dig);
  oldsys = signal(SIGSYS,EX_interrupt_dig);	
  oldpipe= signal(SIGPIPE,EX_interrupt_dig);
  oldterm= signal(SIGTERM,EX_interrupt_dig);
  return(1);

}


