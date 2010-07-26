class implementation COtext;

#include "cotxmacros.h"
#include <stdio.h>
#include <alloca.h>
#include <string.h>

#define err_print(string) fprintf(stderr,"Error in %s line %i: %s\n",__FILE__,__LINE__,string)
#define READ 'r'
#define WRITE 'w'

extern DEcheck_display();

main()
{
   
    IGRlong                     rc;         /* status return code           */
    IGRint               i;
    OMuword              module_os;
    OM_S_OBJID           module_id;   
    long                 msg;
    char                 *text_string;
    short                text_length;
    IGRmatrix            rot_matrix;
    struct GRid          text_objid;
    IGRpoint             point;
    FILE                 *in_fd=NULL,*out_fd=NULL;
    struct IGRdisplay    active_disp;
    short                number;

 
    text_string=(char *)alloca(100);
    for(i=1;i<15;i++) rot_matrix[i]=0.0;
    rot_matrix[0]=rot_matrix[5]=rot_matrix[10]=rot_matrix[15]=1.0;

    /* check if masterout exists */

    if ((out_fd = fopen("./output/masterout","rb"))==NULL)/* if not, create it */
    {  
       fclose(out_fd);
       if ((out_fd = fopen("./output/masterout","wb"))==NULL)
       {
	  err_print("Cannot create/open masterout file");
	  goto wrapup;
       }
    }
    else if ((out_fd = fopen("./output/newout","wb"))==NULL) /* open newout */
    { 
       err_print("Cannot create/open newout file");
       goto wrapup;
    }
    
    if ((in_fd=fopen("./input/master","rb"))==NULL)
       create_input();

    if ((in_fd=fopen("./input/master","rb"))==NULL)
    {
       err_print("Cannot create/open master input file");
       goto wrapup;
    }

    rc = ex$get_cur_mod( id = &module_id,
		       osnum = &module_os);

    if(!(rc & 1)) 
    {
	err_print("Error: getting current module id/os");
	goto wrapup;
     }




     fscanf(in_fd,"%i",&number);
     while(number--)
     {
	w_string(in_fd,text_string,&text_length,READ);
	w_string(out_fd,text_string,&text_length,WRITE);
        w_dbl_matrx(in_fd,point,&i,READ);
        w_dbl_matrx(out_fd,point,&i,WRITE);
        w_active_display_struct(in_fd,&active_disp,READ);
        w_active_display_struct(out_fd,&active_disp,WRITE);

	rc = co$place_text(msg=&msg,
			   text_string=text_string,
			   text_length=&text_length,
			   origin=point,
			   ActiveDisplay=&active_disp,
			   rot_matrix=rot_matrix,
			   buffer=&text_objid);

	if(!(rc & 1)) 
	{
	   err_print("error placing text");
	   goto wrapup;
	}
     }

   DEcheck_display();
   
   wrapup:
  
   if (out_fd!=NULL) fclose(out_fd);
   if (in_fd!=NULL) fclose(in_fd);

   return 1;
}

create_input()
{
    FILE *in_fd=NULL;
    char *text_string;
    short text_length;
    int number;
    struct IGRdisplay disp_attr;
    IGRpoint point;



    if ((in_fd=fopen("./input/master","wb"))==NULL) return 0; /* open input file */

    /* write the number of sets of data in file */

    number=19;

    fprintf(in_fd,"%i\n",number);

    /* initialize data */

    number=3; /* number of elements in IGRpoint array */
    
    text_string=(char *)alloca(100);

    point[0]=point[2]=0.0;
    point[1]=-1000;
    disp_attr.color=1;
    disp_attr.weight=0;
    disp_attr.style=0;

    /* check if <esc>\r escape sequence works */
    text_string=strcpy(text_string,"this is multiline text");
    text_string[22]=27;
    text_string[23]='\n';
    text_string[24]='S';
    text_string[25]='e';
    text_string[26]='c';
    text_string[27]='o';
    text_string[28]='n';
    text_string[29]='d';
    text_string[30]=' ';
    text_string[31]='l';
    text_string[32]='i';
    text_string[33]='n';
    text_string[34]='e';
    text_length=35;
       w_string(in_fd,text_string,&text_length,WRITE);
       w_dbl_matrx(in_fd,point,&number,WRITE);
       w_active_display_struct(in_fd,&disp_attr,WRITE);


    /* check for line weight of 2 */
    disp_attr.color++;
    disp_attr.weight=2;
    point[0]=400.0;
    point[1]=-800;
    point[2]=-10;
    text_string=strcpy(text_string,"this is a text string");
    text_length=strlen(text_string);
       w_string(in_fd,text_string,&text_length,WRITE);
       w_dbl_matrx(in_fd,point,&number,WRITE);
       w_active_display_struct(in_fd,&disp_attr,WRITE);

    disp_attr.color++;
    disp_attr.weight=1;
    point[1]+=200.0;
    text_string=strcpy(text_string,"THIS IS ALL CAPS");
    text_length=strlen(text_string);
       w_string(in_fd,text_string,&text_length,WRITE);
       w_dbl_matrx(in_fd,point,&number,WRITE);
       w_active_display_struct(in_fd,&disp_attr,WRITE);
    
    for (disp_attr.color=0;disp_attr.color<16;disp_attr.color++)
    {
       disp_attr.weight=disp_attr.color%4;
       point[1]+=200.0;
       sprintf(text_string,"Color= %i, Weight= %i",disp_attr.color,disp_attr.weight);
       text_length=strlen(text_string);
	  w_string(in_fd,text_string,&text_length,WRITE);
	  w_dbl_matrx(in_fd,point,&number,WRITE);
	  w_active_display_struct(in_fd,&disp_attr,WRITE);
       
     }
    if (in_fd!=NULL) fclose(in_fd);
    return 0;
}


int w_string(file,string,length,mode)

FILE *file;            /* pointer to an open file */
unsigned char *string; /* text string */
short *length;          /* number of bytes in text string */
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

int w_dbl_matrx(file,matrix,size,mode)

FILE   *file;    /* pointer to an open file */
double matrix[]; /* matrix/array of doubles */
int    *size;     /* number of elements in matrix/array */
char   mode;     /* read (READ) or write (WRITE) mode */

/* this function writes a matrix of type double to the file pointed to 
   by the argument file.  The output has the following format:

   <size of array/number of elements>\n
   <matrix[0]>\n
   <matrix[1]>\n
   .
   .
   .
   <matrix[size-1]>\n

*/

{
   short i;
   
   switch(mode)
   {
      case WRITE:
      {
	 if (fprintf(file,"%i\n",*size)<0) 
	 {
	    err_print("Error writing size of double matrix to file");
	    return 0;
	 }
	 for (i=0;i<*size;i++) 
	    if (fprintf(file,"%e\n",matrix[i])<0)
	    {
	       err_print("Error writing double matrix to file");
	       return 0;
	    }
	 break;
      }
      case READ:
      {
	 if (fscanf(file,"%i\n",size)<0) 
	 {
	    err_print("Error reading size of double matrix from file");
	    return 0;
	 }
	 for (i=0;i<*size;i++) 
	    if (fscanf(file,"%le\n",&matrix[i])<0)
	    {
	       err_print("Error writing double matrix to file");
	       return 0;
	    }
         break;
      }
      default: return 0;
   }
   return 1;
}


int w_active_display_struct(file,act_disp,mode)

FILE   *file;               /* pointer to an open file */
struct IGRdisplay *act_disp; /* active display structure */
char   mode;                /* read (READ) or write (WRITE) mode */

/* this function writes a structure of type IGRdisplay to file pointed to
by the argument file. The format of the output is:

<act_disp.color>\n
<act_disp.weight>\n
<act_disp.style>\n

*/ 

{
   switch (mode)
   {
      case WRITE:
      {
	 if (fprintf(file,"%i\n",act_disp->color)<0)
	 {
	    err_print("Error writing display struct to file");
	    return 0;
	 }

	 if (fprintf(file,"%i\n",act_disp->weight)<0)
	 {
	    err_print("Error writing display struct to file");
	    return 0;
	 }

	 if (fprintf(file,"%i\n",act_disp->style)<0)
	 {
	    err_printf("Error writing display struct to file");
	    return 0;
	 }
	 break;
      }
      case READ:
      {
	 int tmp;
	 if (fscanf(file,"%hi\n",&act_disp->color)<0)
	 {
	    err_print("Error reading display struct from file");
	    return 0;
	 }

	 if (fscanf(file,"%i\n",&tmp)<0)
	 {
	    err_print("Error reading display struct from file");
	    return 0;
	 }
	 act_disp->weight=tmp;

	 if (fscanf(file,"%i\n",&tmp)<0)
	 {
	    err_printf("Error reading display struct from file");
	    return 0;
	 }
	 act_disp->style=tmp;
	 break;
      }
      default: return 0;
   }


return 1;
}


end implementation COtext;
