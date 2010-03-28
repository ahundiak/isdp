class implementation COtext;

#include <stdio.h>
#include "OMmacros.h";
#include <alloca.h>
#define err_print(string) fprintf(stderr,"Error in %s line %i: %s\n",__FILE__,__LINE__,string)
#define TEXT_LENGTH 300

main()
{
   unsigned char *text_string, ESC_char;
   FILE *out_fd=NULL;
   short text_buf_size,prev_font=1,current_font=0,text_length=0;
   int font_flags=33;
   long msg;   
   
      
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

   text_string=(unsigned char *)alloca(TEXT_LENGTH);
   text_buf_size=TEXT_LENGTH;
   ESC_char=27;
   
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
   
   GRstrip_esc_sequences(&msg,prev_font,current_font,font_flags,text_string, &text_length);
   
   if (msg!=MSSUCC)
   {
     err_print("Error in GRstrip_esc_sequences");
     goto wrapup;
   }
   
   if ((text_length!=2)||(text_string[0]!=ESC_char)||(text_string[1]!='\n'))
   {
     err_print("Escape sequences not properly stripped");  
     goto wrapup;
   }  
   
   fprintf(out_fd,"Escape sequences correctly stripped");
   
   wrapup:
   
   if (out_fd!=NULL) fclose(out_fd);
   
}

end implementation COtext;
