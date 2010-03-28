class implementation COtext;

#include <stdio.h>
#include "OMmacros.h";
#include <alloca.h>
#define err_print(string) fprintf(stderr,"Error in %s line %i: %s\n",__FILE__,__LINE__,string)
#define TEXT_LENGTH 300
%safe
   unsigned char *text_string, ESC_char;
   FILE *in_fd=NULL,*out_fd=NULL;
   short current_font=0,text_length=0,num_disp_chars,i;
   int font_flags=33,creat_input=0,retval;
   long msg;   
   double drand48();
%endsafe

main()
{
   short count;
     
   in_fd=NULL;
   out_fd=NULL;
   creat_input=0;
         
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

   text_string=(unsigned char *)alloca(TEXT_LENGTH);
   ESC_char=27;
   text_length=0;
   
   /* create some test cases */
   
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='h';
   text_length+=8; /* leave room for a double */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='v';
   text_length+=8; /* leave room for a double */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='x';
   text_length+=8; /* leave room for a double */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='y';
   text_length+=8; /* leave room for a double */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='s';
   text_length+=8; /* leave room for a double */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='f';
   text_length+=2; /* leave room for a short */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='m';
   text_length+=17; /* leave room for a char and two doubles */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='F';
   text_length+=2; /* leave room for two chars */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='E';
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='M';
   text_length+=18; /* leave room for two chars and two doubles */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='w';
   text_length+=1; /* leave room for a char */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='p';
   text_length+=1; /* leave room for a char */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='C';
   text_length+=8; /* leave room for a double */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]=ESC_char;
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='\n';
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='J';
   text_length+=8; /* leave room for a double */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='H';
   text_length+=8; /* leave room for a double */
   text_string[text_length++]=ESC_char;   
   text_string[text_length++]='j';
   text_length+=8; /* leave room for a double */
   
   GRnum_disp_char(&msg,text_string,&text_length,current_font,font_flags,&num_disp_chars);
   
   if (msg!=MSSUCC)
   {
     err_print("Error in GRnum_disp_char");
     goto wrapup;
   }

   if (num_disp_chars!=2)
   {
     err_print("Number of displayable characters not correctly found");
     goto wrapup;
   }  
   
   fprintf(out_fd,"Number of displayable characters correctly found (%hi)\n",num_disp_chars);
   
   for (count=0;count<100;count++)
   {
   
   if (getstring()) goto wrapup;
   
   GRnum_disp_char(&msg,text_string,&text_length,current_font,font_flags,&num_disp_chars);
   
   if (msg!=MSSUCC)
   {
     err_print("Error in GRnum_disp_char");
     goto wrapup;
   }
   
   if (num_disp_chars==text_length)
   fprintf(out_fd,"Number of displayable characters correctly found (%hi)\n",num_disp_chars);
   else
   {
     err_print("Error in GRnum_disp_char");
     goto wrapup;
   }
   
   }
   wrapup:
   
   if (out_fd!=NULL) fclose(out_fd);
   if (in_fd!=NULL) fclose(in_fd);
   
}

int getstring()
{
  
   if (creat_input)
   {
      text_length=(short)(TEXT_LENGTH*drand48());
      if (fprintf(in_fd,"%hi\n",text_length)<0)
      {
	 err_print("error writing to input file");
	 return 1;
      }
      for(i=0;i<text_length;i++)
      {
        text_string[i]=(char)(95*drand48()+32);
        if (fprintf(in_fd,"%c",text_string[i])<0)
        {
           err_print("error writing to input file");
           return 1;
        }
      }
      if (fprintf(in_fd,"\n")<0)
      {
         err_print("error writing to input file");
         return 1;
      }
   }
   else
   {
      retval=fscanf(in_fd,"%hi\n",&text_length);
      if (retval!=1)
	 if (retval==EOF)
	 {
	    err_print("end of file reached while reading from input/master");
	    return 1;
	 }
	 else
	 {
	    err_print("error while reading from input/master");
	    return 1;
	 }
      for (i=0;i<text_length;i++)
      {
         retval=fscanf(in_fd,"%c",&text_string[i]);
         if (retval!=1)
   	    if (retval==EOF)
	    {
	       err_print("end of file reached while reading from input/master");
	       return 1;
	    }
	    else
	    {
	       err_print("error while reading from input/master");
	       return 1;
	    }
      }
   }
   return 0;
}


end implementation COtext;
