class implementation COtext;

#include <stdio.h>
#include <alloca.h>
#include "OMmacros.h"

#define err_print(string) fprintf(stderr,"Error in %s line %i: %s\n",__FILE__,__LINE__,string)
#define TEXT_LENGTH 300
#define READ 'r'
#define WRITE 'w'


main()
{
   /*                                                                         */
   /* Check if escape sequences are found                                     */
   /*                                                                         */
   
   char *text_string, ESC_char;
   short text_buf_size,text_length,num_chars,creat_input=0,start_position;
   long msg,rc;
   int retval;
   FILE *out_fd=NULL,*in_fd=NULL;
   double d;
   double drand48();
   IGRboolean multi_mode=0;



   /* check if masterout exists */

   if ((out_fd = fopen("./output/masterout","r"))==NULL)/* if not, create it */
   {
      fclose(out_fd);
      if ((out_fd = fopen("./output/masterout","w"))==NULL)
      {
         err_print("Cannot create/open masterout file");
         goto wrapup;
      }
   }
   else if ((out_fd = fopen("./output/newout","w"))==NULL) /* open newout */
   {
      err_print("Cannot create/open newout file");
      goto wrapup;
   }

   if ((in_fd=fopen("./input/master","r"))==NULL)
   {
      creat_input=1;
      if ((in_fd=fopen("./input/master","w"))==NULL)
      {
	 err_print("Cannot create/open master input file");
	 goto wrapup;
      }
   }


   text_string=(char *)alloca(TEXT_LENGTH);
   text_buf_size=TEXT_LENGTH;
   ESC_char=27;
 


   /* horizontal move */

   
   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is a text string%c%c", ESC,'h');
   
      start_position=strlen("this is a text string");
      OM_BLOCK_MOVE(&d,&text_string[start_position+2],8);
      text_length+=8;

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }

   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is %c%c%lftext", ESC_char,'h',d);
   
      start_position=strlen("this is ");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"%c%c%lfthis is text", ESC_char,'h',d);
   
      start_position=strlen("");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is a text string%c%c%lfto test", ESC_char,'v',d);
   
      start_position=strlen("this is a text string");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else

   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is %c%c%lftext", ESC_char,'v',d);
   
      start_position=strlen("this is ");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"%c%c%lfthis is text", ESC_char,'v',d);
   
      start_position=strlen("");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }



   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is a text string%c%c%lfto test", ESC_char,'v',d);
   
      start_position=strlen("this is a text string");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is a text string%c%c%lfto test", ESC_char,'x',d);
   
      start_position=strlen("this is a text string");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is %c%c%lftext", ESC_char,'x',d);
   
      start_position=strlen("this is ");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }



   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"%c%c%lfthis is text", ESC_char,'x',d);
   
      start_position=strlen("");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is a text string%c%c%lfto test", ESC_char,'y',d);
   
      start_position=strlen("this is a text string");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is %c%c%lftext", ESC_char,'y',d);
   
      start_position=strlen("this is ");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"%c%c%lfthis is text", ESC_char,'y',d);
   
      start_position=strlen("");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is a text string%c%c%lfto test", ESC_char,'s',d);
   
      start_position=strlen("this is a text string");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is %c%c%lftext", ESC_char,'s',d);
   
      start_position=strlen("this is ");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"%c%c%lfthis is text", ESC_char,'s',d);
   
      start_position=strlen("");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is a text string%c%c%i", ESC_char,'w',((int)(d*1000))%31);
   
      start_position=strlen("this is a text string");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=3)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is %c%c%itext", ESC_char,'w',((int)(d*1000))%31);
   
      start_position=strlen("this is ");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=3)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"%c%c%ithis is text", ESC_char,'w',((int)(d))*1000%31);
   
      start_position=strlen("");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=3)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is a text string%c%c%lfto test", ESC_char,'C',d);
   
      start_position=strlen("this is a text string");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"this is %c%c%lftext", ESC_char,'C',d);
   
      start_position=strlen("this is ");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   if (creat_input)
   {
      d=drand48();
      if (fprintf(in_fd,"%lf\n",d)<0)
      {
	 err_print("error writing to input file");
	 goto wrapup;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%lf",&d);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    goto wrapup;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    goto wrapup;
	 }
   }

   text_length= sprintf(text_string,"%c%c%lfthis is text", ESC_char,'C',d);
   
      start_position=strlen("");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=10)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   text_length= sprintf(text_string,"this is a text string%c%cdeffrac,", ESC_char,'f');
   
      start_position=strlen("this is a text string");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=4)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   text_length= sprintf(text_string,"this is %c%cdeffrac,text", ESC_char,'f');
   
      start_position=strlen("this is ");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=4)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   text_length= sprintf(text_string,"%c%cdeffrac,this is text", ESC_char,'f');
   
      start_position=strlen("");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=4)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   text_length= sprintf(text_string,"this is a text string%c%cdefault,", ESC_char,'f',d);
   
      start_position=strlen("this is a text string");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=4)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   text_length= sprintf(text_string,"this is %c%cdefault,text", ESC_char,'f');
   
      start_position=strlen("this is ");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   

   if (num_chars!=4)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }


   text_length= sprintf(text_string,"%c%cdefault,this is text", ESC_char,'f');
   
      start_position=strlen("");

   w_string(out_fd,text_string,&text_length,WRITE);

   rc = GRfwd_esc_seq(&msg,text_string,&text_length,&multi_mode,&start_position,&num_chars);
   
   if (num_chars!=4)
   {
      err_print("escape sequence not correctly found");
      goto wrapup;
   }

  

   wrapup:

   if (out_fd!=NULL) fclose(out_fd);
   if (in_fd!=NULL) fclose(in_fd);
   return 1;
}



int w_string(file,string,length,mode)

FILE *file;            /* pointer to an open file */
char *string; /* text string */
short *length;         /* number of bytes in text string */
char  mode;            /* read (READ) or write (WRITE) mode */

/* this functions writes a text string and its length to the file pointed
   to by argument file.  Format of the output is:

   <string length>\n
   <text string>\n

*/


{
   short i;

   switch(mode)
   {
      case WRITE:
      {
         if (fprintf(file,"%i\n",*length)<0)
         {
            err_print("Error writing length of string to file");
            return 0;
         }
         for (i=0;i<*length;i++)
            if (fprintf(file,"%c",string[i])<0)
            {
               err_print("Error writing string to file");
               return 0;
            }

         if (fprintf(file,"\n")<0)
         {
            err_print("Error writing string to file");
            return 0;
            }
      break;
      }
      case READ:
      {
         if (fscanf(file,"%i\n",length)<0)
         {
            err_print("Error writing length of string to file");
            return 0;
         }
         fread(string,1,*length,file);
      break;
      }
      default: return 0;

   }
   return 1;
}


end implementation COtext;
