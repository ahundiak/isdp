#ifdef ENV5
#include <tools.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <journal.h>

#define function_key 0xfffffffc
#define BLKSIZE 256
#define TRUE 1

main(argc, argv)
int argc;
char *argv[];
{
int window;
int file_done;
int icon;
int timer;
int first_flag;
int rewind_flag;
int modify, delete;
char c[10];
int menu;
FILE *pbk, *from, *to, *asciiout = NULL;
int nbytes;
int status;
int done;
int event;
char keybuf[255];
char func_char;
char *strchr();

char cmd_string[256];
struct echo_button button;
struct echo_refresh_button refresh_button;
struct echo_collapse_button collapse_button;
struct echo_delete_button delete_button;
int event_no;
char *dot, *dash = NULL;
char outfile[256];
char outf[256];
char infile[256];
char seq_no_char[128];
int  seq_no = 0;
int  print_flag, last_seq = 0;
char fbuf[BLKSIZE];
char delete_char;

delete = 0;
first_flag = 1;
if (argc == 1)
 {
 printf("Input journal filename to be processed ");
 scanf("%s", infile);
 }
else
 {
 strcpy(infile, argv[1]);
 }
pbk = fopen(infile, "r");
if (!pbk )
   {
   printf( " No journal file  %s found\n", infile );
   goto exi;
   }
fclose ( pbk );   
modify = 0;	
event_no = 0;
done = 0;

if (argc <= 2)
 {
 fprintf(stdout,"[b]browse or  [d]delete events? ");
 scanf("%s", c);
 }
else 
 {
 strcpy(c, argv[2]);
 }



if (c[0] == 'd' )
 {
  strcpy(outfile, infile);
  dot = (char *) strchr (outfile,'.');
  if (dot)
   {
    *dot=0;
   }
  delete = TRUE;

  strcat(outfile, ".mjl");
  from = fopen(infile, "r");

  to = fopen(outfile, "w+");
  if (!to)
  {
  printf("Cannot open output file\n");
  goto exi;
  }
  done = 0;
  while (!done)
   {
    status = fread(fbuf,sizeof(char),256,  from);
    if (status)
      {
      fwrite(fbuf, sizeof(char),status, to);
      }
    else
      {
      done = 1;
      }
   }
  fclose(from);
  rewind(to);
  fread(&event, 4, 1, to);
  event = 1;/*modify bit*/
  fseek(to, -4, 1);
  fwrite(&event, 4, 1, to);
  pbk = to;
 }
else
 {
  pbk = fopen(infile, "r");
  strcpy(outf, infile);
  dot = (char *) strchr (outf,'.');
   if (dot)
    {
     *dot=0;
    }

  if ( argc <= 3)
   {
    outf[0] = 0;
    printf ("Input ascii output filename  ");
    scanf("%s", outf);
   }
  else
   {
    strcpy(outf, argv[3]);
   }
  if (!strcmp(outf, "pg"))
   {
    asciiout = stdout;
   }
  else
   {
   file_done = 0;
   while (!file_done)
   {
     asciiout = fopen(outf, "r");/*direct to file*/

     if (asciiout)
     {
     /*file exists*/
     fclose (asciiout);
     printf(" Output file %s exists,overwrite y/n ",outf);
     scanf("%s",seq_no_char);
     if ( !(strcmp(seq_no_char,"n")) )
     {
      outf[0] = 0;
      printf ("Input ascii output filename  ");
      scanf("%s", outf);
     }
     else
     {
     fclose (asciiout);
     file_done = TRUE;
     seq_no_char[0] = 0;
     }
    }
    else
    file_done = TRUE;
   }
   asciiout = fopen(outf, "w");/*direct to file*/
   if (!asciiout)
   {
   printf("Cannot open output file\n");
   goto exi;
   }
   }
 }
if (( delete == TRUE))
 {
 asciiout = stdout;	
 printf("\n\nA modified journal file %s will be created from %s\n \n",
                            outfile, infile);
 }
rewind_flag = TRUE;
while ( rewind_flag )
{
rewind(pbk);
print_flag = TRUE;

if ( delete == TRUE )
 {
 print_flag = 0;/*not printing anything except that sequence*/	
  if ( argc >= 4)
  {
  strcpy(seq_no_char,argv[3]);
  }
  else
  {
   fprintf(asciiout,"Enter sequence number to delete ");
   scanf("%s", seq_no_char);
  }
 seq_no = 0;
 last_seq = atoi(seq_no_char);
 }
rewind_flag = 0;
done = 0;
status = fread(&event, 4, 1, pbk);/*flag word*/
event_no = 0;
while(!done && !rewind_flag)
 {

  nbytes = 4;
  status = fread(&event, nbytes, 1, pbk);
  if(!status)
   {
    done =1;
    goto exi;
   }
 else
   {
   delete_char = ' ';
   if( event < 0 )
    {
    event = event & 0x7fffffff;


    if ( print_flag ) 
     {
     delete_char = 'd';
     }
    }
   switch (event)
    {
    case 1:
      event_no++;
      nbytes = 0;
      status = fread(&nbytes, 1, 1, pbk);
      status = fread(keybuf, 1, nbytes, pbk);
      if ( keybuf[0] == function_key )
        {

         status = fread(&event, 4, 1, pbk);	
         status = fread(&nbytes, 1, 1, pbk);
         status = fread(&func_char, 1, nbytes, pbk);
        }
      if ((( event_no == last_seq) && delete ) ||
           ( ((event_no >= seq_no)  && (event_no <= last_seq) && delete )
                       && dash ))
          {
          if (keybuf[0] == function_key)
             {
             nbytes = -12;
             }  
          else
             {
             nbytes = -6;
             }
          fseek(pbk, nbytes, 1);
          fread(&event, 4, 1, pbk);
          event = event | 0x80000000;
          fseek(pbk, -4, 1);
          fwrite(&event, 4, 1, pbk);
          nbytes = 0;
          fread(&nbytes, 1, 1, pbk);/*ready for next event*/
          fread(keybuf, nbytes, 1, pbk);
          if (keybuf[0] == function_key)
           {
           fread(&event, 4, 1, pbk);
           event = event | 0x80000000;
           fseek(pbk, -4, 1);
           fwrite(&event, 4, 1, pbk);
           fread(&nbytes, 1, 1, pbk);/*ready for next event*/
           fread(keybuf, nbytes, 1, pbk);/*ready for next event*/
           }
          if ( event_no == last_seq )
           {
           goto exi;
           }
          }/*end if delete*/

       if (print_flag)
         {
         if ( keybuf[0] == function_key )
          {
              fprintf(asciiout,"%c <%d> function keyin %d \n",delete_char, 
                                     event_no, func_char);
          }
         else
          {
	  if (keybuf[0] == 0xd)
	    {
	     fprintf (asciiout, "%c <%d> <CR>\n",delete_char,  event_no);
            }
          else
            {
	     if ( !(keybuf[0] & 0x80))
	       {
               fprintf(asciiout,"%c <%d> keyin %s \n",delete_char,
                                           event_no, keybuf);
               }
             else
               {
                fprintf(asciiout,"%c <%d> hex keyin %x\n",delete_char, 
                                       event_no, keybuf[0]);
               }
            }
          }
        }
      break;

    case 2: 
      event_no++;
      nbytes = sizeof(struct echo_button);
      status = fread(&button, nbytes, 1, pbk);
	
      if ((( event_no == last_seq) && delete ) ||
           ( ((event_no >= seq_no)  && (event_no <= last_seq) && delete )
                       && dash ))
          {
          nbytes = -( sizeof (struct echo_button ) + 4);
          fseek(pbk, nbytes, 1);
          fread(&event, 4, 1, pbk);
          event = event | 0x80000000;
          fseek(pbk, -4, 1);
          fwrite(&event, 4, 1, pbk);
          if (event_no == last_seq)
           {
           /*if only had one to delete rewind and get next*/
            goto exi;
           }
          else 
           {/*read event to put at next event*/
           nbytes = sizeof(struct echo_button);	
           status = fread(&button, nbytes, 1, pbk);	
           /**/}
        }/*end if delete*/
       else if (print_flag)
        {
         fprintf(asciiout,"%c <%d> window number =%d\n",delete_char, 
                                    event_no,  button.window);
         fprintf(asciiout,"       button x=%d \n", button.x);   
         fprintf(asciiout,"       button y=%d \n", button.y);   
         switch ( button.btype )
          {
           case LEFT_BUTTON:
            fprintf(asciiout,"       left button\n");
            break;
     
           case MIDDLE_BUTTON:
            fprintf(asciiout,"       middle button\n");
            break;
      
           case RIGHT_BUTTON:
            fprintf(asciiout,"       right button\n");
            break;
           }

         switch ( button.state )
           {
           case UP:
            fprintf(asciiout,"       up");
            break;

           case DOWN:
            fprintf(asciiout,"       down");
            break;

           case SINGLE_CLICK:
            fprintf(asciiout,"       single click");
            break;

           case DOUBLE_DOWN:
            fprintf(asciiout,"       double down");
            break;

           case DOUBLE_CLICK:
            fprintf(asciiout,"       double click");
            break;

           case TRIPLE_DOWN:
            fprintf(asciiout,"       triple down");
            break;

           case UP_DOWN_UP:
            fprintf(asciiout,"       up down up");
            break;

           case UP_DOWN:
            fprintf(asciiout,"       up down");
            break;
          }
         fprintf(asciiout," \n");
        }
       break;



    case TIMER_EVENT: 
      event_no++;

      if ((( event_no == last_seq) && delete ) ||
           ( ((event_no >= seq_no)  && (event_no <= last_seq) && delete )
                       && dash ))
       {
          nbytes = -4;
          fseek(pbk, nbytes, 1);
          fread(&event, 4, 1, pbk);
          event = event | 0x80000000;
          fseek(pbk, -4, 1);
          fwrite(&event, 4, 1, pbk);
          if (event_no == last_seq)
           {
           /*if only had one to delete rewind and get next*/
            goto exi;
           }
          else 
           {/*read event to put at next event*/
            nbytes = sizeof(int);
            status = fread(&timer, nbytes, 1, pbk);
           }
        }/*end if delete*/
       else if (print_flag)
        {
         nbytes = sizeof(int);
         status = fread(&timer, nbytes, 1, pbk);
         fprintf(asciiout,"%c <%d> timer no =%d\n",delete_char, 
                                    event_no, timer);

        }
       break;

    case REFRESH_EVENT: 
      event_no++;
      nbytes = sizeof(struct echo_refresh_button);
      status = fread(&refresh_button, nbytes, 1, pbk);

      if ((( event_no == last_seq) && delete ) ||
           ( ((event_no >= seq_no)  && (event_no <= last_seq) && delete )
                       && dash ))
         {
          nbytes = -( sizeof (struct echo_refresh_button ) + 4);
          fseek(pbk, nbytes, 1);
          fread(&event, 4, 1, pbk);
          event = event | 0x80000000;
          fseek(pbk, -4, 1);
          fwrite(&event, 4, 1, pbk);
          if (event_no == last_seq)
           {
           /*if only had one to delete rewind and get next*/
            goto exi;
           }
          else 
           {/*read event to put at next event*/
           nbytes = sizeof(struct echo_refresh_button);	
           status = fread(&refresh_button, nbytes, 1, pbk);	
           /**/}
         }/*end if delete*/ 
        else if (print_flag)
         {
	 fprintf(asciiout, "  <info>refresh event\n");
          fprintf(asciiout,"%c <%d> window number =%d\n",delete_char, 
                                    event_no,  refresh_button.window);
         fprintf(asciiout,"       button vs_no=%d \n", refresh_button.vs_no);
         fprintf(asciiout,"       button x=%d \n", refresh_button.x);   
         fprintf(asciiout,"       button y=%d \n", refresh_button.y);   
         fprintf(asciiout,"       button x2=%d \n", refresh_button.x2);   
         fprintf(asciiout,"       button y2=%d \n", refresh_button.y2);   
         fprintf(asciiout,"       button ax1=%d \n", refresh_button.ax1);   
         fprintf(asciiout,"       button ay1=%d \n", refresh_button.ay1);   
         fprintf(asciiout,"       button ax2=%d \n", refresh_button.ax2);   
         fprintf(asciiout,"       button ay2=%d \n", refresh_button.ay2);   
         fprintf(asciiout,"       button opmask=%d \n", refresh_button.opmask);
         fprintf(asciiout," \n");
         }
       break;

    case COLLAPSE_EVENT: 
      event_no++;
      nbytes = sizeof(struct echo_collapse_button);
      status = fread(&collapse_button, nbytes, 1, pbk);

      if ((( event_no == last_seq) && delete ) ||
           ( ((event_no >= seq_no)  && (event_no <= last_seq) && delete )
                       && dash ))
          {
          nbytes = -(sizeof(struct echo_collapse_button) + 4);	
          fseek(pbk, nbytes, 1);
          fread(&event, 4, 1, pbk);
          event = event | 0x80000000;
          fseek(pbk, -4, 1);
          fwrite(&event, 4, 1, pbk);
          if (event_no == last_seq)
           {
           /*if only had one to delete rewind and get next*/
            goto exi;
           }
          else 
           {/*read event to put at next event*/
           nbytes = sizeof(struct echo_collapse_button);	
           status = fread(&collapse_button, nbytes, 1, pbk);	
           /**/}
         }/*end if delete*/
        else if (print_flag)
         {
	 fprintf(asciiout, " <info> collapse event\n");	
          fprintf(asciiout,"%c <%d> menu window number =%d\n",delete_char, 
                                    event_no,  collapse_button.window);

         fprintf(asciiout,"       button opmask=%d \n", collapse_button.opmask);   


         fprintf(asciiout," \n");

         }
       break;

    case DELETE_EVENT: 
      event_no++;
      nbytes = sizeof(struct echo_delete_button);
      status = fread(&delete_button, nbytes, 1, pbk);


      if ((( event_no == last_seq) && delete) ||
           ( ((event_no >= seq_no)  && (event_no <= last_seq) && delete )
                       && dash ))
          {
          nbytes = -( sizeof (struct echo_delete_button ) + 4);
          fseek(pbk, nbytes, 1);
          fread(&event, 4, 1, pbk);
          event = event | 0x80000000;
          fseek(pbk, -4, 1);
          fwrite(&event, 4, 1, pbk);
          if (event_no == last_seq)
           {
           /*if only had one to delete rewind and get next*/
            goto exi;
           }
          else 
           {/*read event to put at next event*/
           nbytes = sizeof(struct echo_delete_button);	
           status = fread(&delete_button, nbytes, 1, pbk);	
           /**/}
         }/*end if delete*/
        else if (print_flag)
         {
	 fprintf(asciiout, " <info> delete event\n");	
          fprintf(asciiout,"%c <%d> menu window number =%d\n",delete_char, 
                                    event_no,  delete_button.window);

         fprintf(asciiout," \n");
         }
       break;


    case WINDOW_USER_ICON_EVENT: 
      event_no++;
      nbytes = sizeof(int);
      status = fread(&window, 4, 1, pbk);
      status = fread(&icon, 4, 1, pbk);

      if ((( event_no == last_seq) && delete) ||
           ( ((event_no >= seq_no)  && (event_no <= last_seq) && delete )
                       && dash ))
          {
          nbytes = -( sizeof (struct echo_delete_button ) + 4);
          fseek(pbk, nbytes, 1);
          fread(&event, 4, 1, pbk);
          event = event | 0x80000000;
          fseek(pbk, -4, 1);
          fwrite(&event, 4, 1, pbk);
          if (event_no == last_seq)
           {
           /*if only had one to delete rewind and get next*/
            goto exi;
           }
          else 
           {/*read event to put at next event*/
           nbytes = sizeof(struct echo_delete_button);	
           status = fread(&delete_button, nbytes, 1, pbk);	
           /**/}
         }/*end if delete*/
        else if (print_flag)
         {

          fprintf(asciiout,"%c <%d> window =%d\n",delete_char, 
                                    event_no,  window);

          fprintf(asciiout,"%c <%d> window =%d\n",delete_char, 
                                    event_no,  icon);
         fprintf(asciiout," \n");
         }
       break;


    case JNL_INFO_EVENT:

       status = fread(&event, 4, 1, pbk);
       switch ( event )
       {

       case JNL_STOPSIGN:
       status = fread(&menu,4, 1, pbk);
       if (( print_flag ))
        {
          fprintf (asciiout,  "  <info> stopsign hit,buffers saved =  %d\n",
                                                      menu);
        }
       break;


       case JNL_WINDOW_CHANGE:
       status = fread(&menu,4, 1, pbk);
       if (( print_flag ))
        {
          fprintf (asciiout,  "  <info> window created %d\n",  menu);
        }
       break;

       case JNL_TIMER_NO:
       status = fread(&menu,4, 1, pbk);
       if (( print_flag ) )
        {
          fprintf (asciiout,  "  <info> timer set %d\n",  menu);
        }
       break;

       case JNL_CHAR:

       status = fread(&nbytes, 4, 1, pbk);
       if ( nbytes )
        {
        status = fread(&cmd_string[0], nbytes, 1, pbk);
        }
       cmd_string[nbytes] = 0;
       if (( print_flag ) )
        {
         if ( event == JNL_CHAR ) 
           {
            fprintf(asciiout,"  <info> wake up command %s\n",  cmd_string);
           }
         else
           {
           fprintf(asciiout,"  <info>  %s\n",   cmd_string);  
	   } 
	 }
       break;

       default:
        fprintf(asciiout,"%d", event);
        break;
       }
      break;

    default:   
         fprintf(asciiout, " event %x", event);

      break;
   }/*end switch*/
  }/*end while*/
 }
}/*end rewind_flag*/
exi:
fclose (pbk);
}
#elif defined(X11)
#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Intrinsic.h>
#include <journal.h>

#define function_key 0xfffffffc
#define BLKSIZE 256
#define TRUE 1

main(argc, argv)
int argc;
char *argv[];
{
Display       *EXdisplay;
int file_done;
int rewind_flag;
int modify, delete;
char c[10];

FILE *pbk, *from, *to, *asciiout=0;
int nbytes;
int status;
int done;
XEvent event;


char *strchr();
char char_string[1024];


int event_no;


char *dot, *dash;
char outfile[256];
char outf[256];
char infile[256];
char seq_no_char[128];
int  seq_no, print_flag, last_seq=0;
char fbuf[BLKSIZE];
char delete_char;
int first_flag;
Widget toplevel;
char str[255];

int event_flag;
#if defined (CLIX)
toplevel = XtInitialize( argv[0], argv[0], NULL, 0, (int *) &argc, argv);
#elif defined (IRIX5)
toplevel = XtInitialize( argv[0], argv[0], NULL, 0, (int *) &argc, argv);
#else
toplevel = XtInitialize( argv[0], argv[0], NULL, 0, (unsigned int *) &argc, argv);
#endif
EXdisplay = XtDisplay( toplevel );

delete = 0;

first_flag = 1;
if (argc == 1)
 {
 printf("Input journal filename to be processed ");
 scanf("%s", infile);
 }
else
 {
 strcpy(infile, argv[1]);
 }
pbk = fopen(infile, "r");
if (!pbk )
   {
   printf( " No journal file  %s found\n", infile );
   goto exi;
   }
fclose ( pbk );   
modify = 0;	
event_no = 0;
done = 0;

if (argc <= 2)
 {
 fprintf(stdout,"[b]browse or  [d]delete events? ");
 scanf("%s", c);
 }
else 
 {
 strcpy(c, argv[2]);
 }



if (c[0] == 'd' )
 {
  strcpy(outfile, infile);
  dot = (char *) strchr (outfile,'.');
  if (dot)
   {
    *dot=0;
   }
  delete = TRUE;

  strcat(outfile, ".mjl");
  from = fopen(infile, "r");

  to = fopen(outfile, "w+");
  if( !to)
  {
  printf("Cannot open output file\n");
  goto exi;
  }
  done = 0;
  while (!done)
   {
    status = fread(fbuf,sizeof(char),256,  from);
    if (status)
      {
      fwrite(fbuf, sizeof(char),status, to);
      }
    else
      {
      done = 1;
      }
   }
  fclose(from);
  rewind(to);
  fread(&event, 4, 1, to);
  event_flag = 1;/*modify bit*/
  fseek(to, -4, 1);
  fwrite(&event_flag, 4, 1, to);
  pbk = to;
 }
else
 {
  pbk = fopen(infile, "r");
  strcpy(outf, infile);
  dot = (char *) strchr (outf,'.');
   if (dot)
    {
     *dot=0;
    }

  if ( argc <= 3)
   {
    outf[0] = 0;
    printf ("Input ascii output filename  ");
    scanf("%s", outf);
   }
  else
   {
    strcpy(outf, argv[3]);
   }
  if (!strcmp(outf, "pg"))
   {
    asciiout = stdout;
   }
  else
   {
   file_done = 0;
   while (!file_done)
   {
     asciiout = fopen(outf, "r");/*direct to file*/

     if (asciiout)
     {
     /*file exists*/
     fclose (asciiout);
     printf(" Output file %s exists,overwrite y/n ",outf);
     scanf("%s",seq_no_char);
     if ( !(strcmp(seq_no_char,"n")) )
     {
      outf[0] = 0;
      printf ("Input ascii output filename  ");
      scanf("%s", outf);
     }
     else
     {
     fclose (asciiout);
     file_done = TRUE;
     seq_no_char[0] = 0;
     }
    }
    else
    file_done = TRUE;
   }
   asciiout = fopen(outf, "w");/*direct to file*/
   if (!asciiout)
   {
    printf("Cannot open output file\n");
    goto exi;
   }
   }
 }
if (( delete == TRUE))
 {
 asciiout = stdout;	
 printf("\n\nA modified journal file %s will be created from %s\n \n",
                            outfile, infile);
 }
rewind_flag = TRUE;
while ( rewind_flag )
{
rewind(pbk);
print_flag = TRUE;

if ( delete == TRUE )
 {
 print_flag = 0;/*not printing anything except that sequence*/	
  if ( argc >= 4)
  {
  strcpy(seq_no_char,argv[3]);
  }
  else
  {
   fprintf(asciiout,"Enter sequence number to delete ");
   scanf("%s", seq_no_char);
  }
 seq_no = 0;
 last_seq = atoi(seq_no_char);
 }

rewind_flag = 0;
done = 0;
status = fread(&event, 4, 1, pbk);/*flag word*/
event_no = 0;
while(!done && !rewind_flag)
 {

  nbytes = sizeof (XEvent);
  status = fread(&event, nbytes, 1, pbk);
  if(!status)
   {
    done =1;
    goto exi;
   }

 else
   {
   delete_char = ' ';
   if( event.type < 0 )
    {
    event.type = event.type & 0x7fffffff;
    if ( print_flag ) 
     {
     delete_char = 'd';
     }
    }
   }
  fflush(asciiout);
  switch (event.type)
  {
          case JNL_INFO_EVENT:

            if (( event.xany.serial == JNL_STOPSIGN ) && print_flag)
             fprintf(asciiout,"<<<<< stopsign hit,buffers saved = %d  >>>>>\n",
                                                         event.xany.window);

            if (( event.xany.serial == JNL_WINDOW_CHANGE )
                                       && print_flag)
            {
                if (!event.xbutton.x)
                {
                fprintf(asciiout,"<<<<< Window <%x> created >>>>>\n",
                                                  event.xany.window);
                }
                else
                {
                nbytes = event.xbutton.x;
                status = fread(char_string, nbytes, 1, pbk);
                char_string[nbytes] = 0;
                if (print_flag)
                fprintf(asciiout,"  <info> grnuc dynamics data \n");
                }
            }
 

              
            else if ((event.xany.serial == JNL_BUTTON_COUNT) && print_flag)
              {
              switch (event.xbutton.x)
               {
               case 1:
               fprintf (asciiout,"     button state DOWN \n");
               break;

               case 2:
               fprintf (asciiout,"     button state SINGLE CLICK \n");
               break;

               case 3:
               fprintf (asciiout,"     button state DOUBLE DOWN\n");
               break;

               case 4:
               fprintf (asciiout,"     button state DOUBLE CLICK\n");
               break;

               case 5:
               fprintf (asciiout,"     button state TRIPLE DOWN\n");
               break;
               }
              break;
             }
            else if (event.xany.serial == JNL_CHAR)
             {
              nbytes = event.xbutton.x;
              status = fread(char_string, nbytes, 1, pbk);
              char_string[nbytes] = 0;
              if (print_flag)
              fprintf(asciiout,"  <info> wake up command %s\n",  char_string);
             }

            break;

          case KeyPress :
           event_no++;
           if (( event_no == last_seq) && delete )
            {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
           else if (print_flag)
            {
            event.xkey.display = EXdisplay;
            nbytes = XLookupString( &event.xkey,str ,255, 0, 0 );
            fprintf(asciiout,"%c <%d>key press %c \n",delete_char,
                                                     event_no,str[0]);
            }
            break;

          case KeyRelease:
            break;

          case ButtonRelease :
            event_no++;
           if (( event_no == last_seq) && delete )
            {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
           else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> button release window %x \n",
                         delete_char,event_no,
                         event.xany.window);
 
             fprintf(asciiout,"     x = %d  \n",event.xbutton.x);
             fprintf(asciiout,"     y = %d  \n",event.xbutton.y);
             switch (event.xbutton.button-1)
              {
              case 0:
              fprintf(asciiout,"     LEFT_BUTTON\n");
              break;

              case 1:
              fprintf(asciiout,"     MIDDLE_BUTTON\n");
              break;

              case 2:
              fprintf(asciiout,"     RIGHT_BUTTON\n");
              break;
              }
            fprintf(asciiout,"     time stamp = %u  \n",event.xbutton.time);
             }
            break;

          case ButtonPress:
            event_no++;
           if (( event_no == last_seq) && delete )
            {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
           else if (print_flag)
             {

             fprintf(asciiout,"%c <%d> button press window %x \n",
                         delete_char,event_no,
                         event.xany.window);

             fprintf(asciiout,"     x = %d  \n",event.xbutton.x);
             fprintf(asciiout,"     y = %d  \n",event.xbutton.y);
             switch (event.xbutton.button-1)
              {
              case 0:
              fprintf(asciiout,"     LEFT_BUTTON\n");
              break;

              case 1:
              fprintf(asciiout,"     MIDDLE_BUTTON\n");
              break;

              case 2:
              fprintf(asciiout,"     RIGHT_BUTTON\n");
              break;
              }
            fprintf(asciiout,"     time stamp = %u  \n",event.xbutton.time);
             }
            break;

    	  case ConfigureNotify:
            event_no++;
           if (( event_no == last_seq) && delete )
            {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
           else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> ConfigureNotify window %x  \n",
                                  delete_char,event_no,
                                   event.xany.window);
             }
            break;
          case DestroyNotify:
            event_no++;
           if (( event_no == last_seq) && delete )
            {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
           else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> DestroyNotify  window %x \n",
                                  delete_char,event_no,
                                  event.xany.window);
             }
            break;
          case UnmapNotify:
            event_no++;
            if (( event_no == last_seq) && delete )
             {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
            else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> UnmapNotify window %x  \n",
                                              delete_char,event_no,
                                              event.xany.window);
             }
            break;
          case MapNotify:
            event_no++;
            if (( event_no == last_seq) && delete )
             {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
            else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> MapNotify  window %x \n",
                                      delete_char,event_no,
                                      event.xany.window);
             }
            break;

          case CirculateNotify:
            event_no++;
            if (( event_no == last_seq) && delete )
             {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
            else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> CirculateNotify  \n",
                                      delete_char,event_no);
             }
            break;

          case CreateNotify:
            event_no++;
            if (( event_no == last_seq) && delete )
             {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
            else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> CreateNotify  \n",
                                      delete_char,event_no);
             }
            break;

          case GravityNotify:
            event_no++;
            if (( event_no == last_seq) && delete )
             {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
            else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> GravityNotify  \n",
                                      delete_char,event_no);
             }
            break;

          case ReparentNotify:
            event_no++;
            if (( event_no == last_seq) && delete )
             {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
            else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> ReparentNotify  \n",
                                      delete_char,event_no);
             }
            break;

/*          case MotionNotify:
            event_no++;
            fprintf(asciiout,"<%d> MotionNotify  \n",event_no);
            break;*/

          case Expose:
            event_no++;
            if (( event_no == last_seq) && delete )
             {
             nbytes = -( sizeof ( XEvent ));
             fseek(pbk, nbytes, 1);
             fread(&event, 4, 1, pbk);
             event.type = event.type | 0x80000000;
             fseek(pbk, -4, 1);
             fwrite(&event, 4, 1, pbk);
             goto exi;
             }
            else if (print_flag)
             {
             fprintf(asciiout,"%c <%d> Expose window %x  \n",
                                delete_char,event_no,
                                event.xany.window);
             }
            break;

          default:
           break;
     }/*end switch*/

  }/*end while*/
}/*end rewind_flag*/
exi:
fclose (pbk);
}
#else
#error Unknown windowing system
#endif
