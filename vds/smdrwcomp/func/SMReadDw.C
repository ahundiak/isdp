/* $Id: SMReadDw.C,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwcomp/func / SMReadDw.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMReadDw.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*  
   File     SMReadDw.C  
   Date     November 92          
   Auteur   Jean Jasinczuk

   Description : Parsing of the file to determine drawing parameter
                  Main function to call is SMReadDrawParam
 History:

 01 Jun 93	Raju		Added FLOOR and ATTRIBUTE options
*/

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "godef.h"
#include "go.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "vdsmacros.h"
#include "SMdef.h"
#include "SMDwDef.h"
#include "gotextdef.h"


#define STATE_CONTOUR      1
#define STATE_NAME         2
#define STATE_COG          3
#define STATE_PLANE        4
#define STATE_LINE         5
#define STATE_MIN_MAX_LINE 6
#define STATE_EXTRACT	   7

#define I_CONTOUR 0
#define I_NAME    1
#define I_COG     2
#define I_PLANE   3
#define I_LINE    4
#define	I_EXTRACT 5

/* ------------------ static int RetreiveStructNum ------------------ */

static int RetreiveStructNum(state,ind)
int state;      /* [I] Present state of automata */
int *ind;       /* [O] Indice of structure to fill */
{
  switch(state)
   {
   case STATE_CONTOUR:
     *ind = I_CONTOUR; break;
   case STATE_NAME:
     *ind = I_NAME; break;
   case STATE_COG:
      *ind = I_COG; break;
   case STATE_PLANE:
     *ind = I_PLANE; break;
   case STATE_LINE:
     *ind = I_LINE; break;
   case STATE_EXTRACT:
     *ind = I_EXTRACT; break;
   default:
     return 0;
   }
  return 1;
}

/* ------------------ static int RetJustif ------------------ */

static int RetJustif(word,Symb)
char *word;             /* [I] word to analyse */
struct SMDwSymb *Symb;	/* [O] Symbology of name */
{
  int i;
  static char *name_justif[] =
   {"LEFT_BOTTOM","LEFT_BASE","LEFT_CENTER","LEFT_CAP","LEFT_TOP",
    "CENTER_BOTTOM","CENTER_BASE","CENTER_CENTER","CENTER_CAP","CENTER_TOP",
    "RIGHT_BOTTOM","RIGHT_BASE","RIGHT_CENTER","RIGHT_CAP","RIGHT_TOP"};
  static short symb_justif[] =
    {LEFT_BOTTOM,LEFT_BASE,LEFT_CENTER,LEFT_CAP,LEFT_TOP,
    CENTER_BOTTOM,CENTER_BASE,CENTER_CENTER,CENTER_CAP,CENTER_TOP,
    RIGHT_BOTTOM,RIGHT_BASE,RIGHT_CENTER,RIGHT_CAP,RIGHT_TOP};

  for( i = 0; i < 15; i++)
    if(strncmp(word,name_justif[i],strlen(name_justif[i])) == 0)
     {
       Symb->options  = (Symb->options & ~0xF00000) | SMDWTXUSR;
       Symb->TextJust = symb_justif[i];
       return 1;
     }
  return 0;
}
		 
/* ------------------ static int Read_Color ------------------ */

static int Read_Color(ptr,next_ptr,state,Symb,osnum)
char *ptr;              /* [I] Line to analyse */
char **next_ptr;        /* [I] Next token */                            
int state;		/* [I] Present state of automata */             
struct SMDwSymb Symb[];	/* [O] Array of symbology of different object */
OMuword osnum;          /* [I] Current osnum */
{
  IGRint val_int = 0;
  char word[80];
  int ind;

  if(!RetreiveStructNum(state,&ind)) return 0;
 
  if(VDSGetNextWord(ptr, word, 79,'#',next_ptr) == 0)
    return 1; 
  
  if(isdigit(word[0]))
    if(sscanf(word,"%d",&val_int) != 1) return 0;     
    else
     {
       Symb[ind].options = (Symb[ind].options & ~0xF) | SMDWCLUSR;
       Symb[ind].symb.display_attr.color = val_int; 
       return 1;
     }
  else if(isalpha(word[0]))
    if(strncmp(word,"OBJECT",6) == 0)
     {
       Symb[ind].options = (Symb[ind].options & ~0xF) | SMDWCLOBJ;
       return 1;
     }
    else
      if(ige$get_color_from_name(name = word,
			color = (IGRshort *)&Symb[ind].symb.display_attr.color,
			mod_osnum = osnum) != OM_S_SUCCESS)
	return 0;
      else
       {
	 Symb[ind].options = (Symb[ind].options & ~0xF) | SMDWCLUSR;
	 return 1;
       }

  return 0;
}

/* ------------------ static int Read_Level ------------------ */

static int Read_Level(ptr,next_ptr,state,Symb)
char *ptr;              /* [I] Line to analyse */
char **next_ptr;        /* [I] Next token */                            
int state;              /* [I] Present state of automata */             
struct SMDwSymb Symb[]; /* [O] Array of symbology of different object */
{
  IGRint val_int = 0;
  char word[80];
  int ind;

  if(!RetreiveStructNum(state,&ind)) return 0;
 
  if(VDSGetNextWord(ptr, word, 79,'=',next_ptr) == 0)
    return 1; 
  
  if(isdigit(word[0]))
    if(sscanf(word,"%d",&val_int) != 1) return 0;     
    else
     {
       Symb[ind].options = (Symb[ind].options & ~0xF0) | SMDWLVUSR;
       Symb[ind].symb.level = val_int; 
       return 1;
     }

  if(strcmp(word,"OBJECT") == 0)
   {
     Symb[ind].options = (Symb[ind].options & ~0xF0) | SMDWLVOBJ;
     return 1;
   }
  return 0;
}

/* ------------------ static int Read_Weight ------------------ */

static int Read_Weight(ptr,next_ptr,state,Symb)
char *ptr;              /* [I] Line to analyse */
char **next_ptr;        /* [I] Next token */                            
int state;		/* [I] Present state of automata */             
struct SMDwSymb Symb[];	/* [O] Array of symbology of different object */
{
  IGRint val_int = 0;
  char word[80];
  int ind;

  if(!RetreiveStructNum(state,&ind)) return 0;
 
  if(VDSGetNextWord(ptr, word, 79,'=',next_ptr) == 0)
    return 1; 
  
  if(isdigit(word[0]))
    if(sscanf(word,"%d",&val_int) != 1) return 0;     
    else
     {
       Symb[ind].options = (Symb[ind].options & ~0xF00) | SMDWWTUSR;
       Symb[ind].symb.display_attr.weight = val_int; 
       return 1;
     }

  if(strcmp(word,"OBJECT") == 0)
   {
     Symb[ind].options = (Symb[ind].options & ~0xF00) | SMDWWTOBJ;
     return 1;
   }
  return 0;
}

/* ------------------ static int Read_Style ------------------ */

static int Read_Style(ptr,next_ptr,state,Symb)
char *ptr;              /* [I] Line to analyse */
char **next_ptr;        /* [I] Next token */                            
int state;		/* [I] Present state of automata */             
struct SMDwSymb Symb[];	/* [O] Array of symbology of different object */
{
  IGRint val_int = 0;
  char word[80];
  int ind;

  if(!RetreiveStructNum(state,&ind)) return 0;
 
  if(VDSGetNextWord(ptr, word, 79,'=',next_ptr) == 0)
    return 1; 
  
  if(isdigit(word[0]))
    if(sscanf(word,"%d",&val_int) != 1) return 0;     
    else
     {
       Symb[ind].options = (Symb[ind].options & ~0xF000) | SMDWSTUSR;
       Symb[ind].symb.display_attr.style = val_int; 
       return 1;
     }

  if(strcmp(word,"OBJECT") == 0)
   {
     Symb[ind].options = (Symb[ind].options & ~0xF000) | SMDWSTOBJ;
     return 1;
   }
  return 0;
}

/* ------------------ static int Read_Extract ------------------ */

static int Read_Extract(ptr,next_ptr,state,Symb)
char *ptr;              /* [I] Line to analyse */
char **next_ptr;        /* [I] Next token */                            
int state;		/* [I] Present state of automata */             
struct SMDwSymb Symb[];	/* [O] Array of symbology of different object */
{
  char word[80];
  int ind;

  if(!RetreiveStructNum(state,&ind)) return 0;
 
  if(VDSGetNextWord(ptr, word, 79,'=',next_ptr) == 0)
    return 1; 
  
  if(strcmp(word,"CROSS_SECTION") == 0)
   {
     Symb[ind].options = (Symb[ind].options & ~0xF0000000) | SMDWEXTCS;
     return 1;
   }
  else if(strcmp(word,"FLOOR") == 0)
   {
     Symb[ind].options = (Symb[ind].options & ~0xF0000000) | SMDWEXTFLR;
     return 1;
   }
  return 0;
}

/* ------------------------- SMSetDrawParam ---------------------------- */
/*                           MAIN FUNCTION                               */
/* Read all the parameters for drawing in a file and set them            */

int SMReadDrawParam(name_file,osnum)
char *name_file;  /* [I] Name of the file containing ship_type */
OMuword osnum;    /* [I] Current osnum */
{
  FILE *fp;
  char 	buffer[MAX_CHAR_LINE], *ptr,*next_ptr;
  int i;
  int state;
  int line = 0;
  char word[80];
  struct SMDwSymb Symb[6];
  IGRboolean Crt[6];

  fp = NULL;
  /* Have to look inside the config */
  vd$openfile(  file_name 	= name_file,
	      product_name 	= "Vds",
	      sub_path	        = "config",
	      cur_dir	  	= TRUE,
	      p_file	  	= &fp);
  if(fp == NULL)
   {printf("Error,cannot open the file: %s\n",name_file); return 0;}

  /* Initialize to no display */
  for(i=0;i<6;i++) Crt[i] = FALSE;

  state = 0;
  while(fgets(buffer,MAX_CHAR_LINE-1, fp) != NULL)
   {
     line++;
     if(strlen(buffer) < 1) continue;  /* Take out the blank line */
     buffer[strlen(buffer)-1] = '\0'; /* To take into account the return */
     
     /* Skip blank characters */
     i = 0;
     while(isspace(buffer[i]) && buffer[i] != '\0') i++;
     ptr = &buffer[i];
     
     if(*ptr == '#') continue; /* A comment line (starting by #) */
     
     if(*ptr == '\0') continue; /* Blank line */
      
     if(VDSGetNextWord(ptr, word, 79, '=', &next_ptr) == 0)
      {
	printf("Warning, syntax error line %d : => %s\n",line,ptr);
	goto wrapup;
      }

     
     if(strncmp("COMPART",ptr,7) == 0) continue;
       
     if(strncmp("CONTOUR",ptr,7) == 0)
      {
	state = STATE_CONTOUR;
	Crt[I_CONTOUR] = TRUE;
	Symb[I_CONTOUR].options = SMDWCLACT | SMDWLVACT |
	                         SMDWWTACT | SMDWSTACT ;
	continue;
      }

     if(strncmp("PLANE",ptr,5) == 0)
      {
	state = STATE_PLANE;
	Crt[I_PLANE] = TRUE;
	Symb[I_PLANE].options = SMDWCLACT | SMDWLVACT | SMDWWTACT | SMDWSTACT ;
	continue;
      }
     
     if(strncmp("NAME",ptr,4) == 0)
      {
	state = STATE_NAME;
	Crt[I_NAME] = TRUE;
	Symb[I_NAME].options = SMDWCLACT | SMDWLVACT | SMDWWTACT | SMDWSTACT
	                  | SMDWTXACT | SMDWATTOBJ;
	continue;
      }

     if(strncmp("COG",ptr,3) == 0)
      {
	state = STATE_COG;
	Crt[I_COG] = TRUE;
	Symb[I_COG].options = SMDWCLACT | SMDWLVACT | SMDWWTACT | SMDWSTACT;
	continue;
      }
     
     if(strncmp("EXTRACT_TYPE",ptr,12) == 0)
      {
	state = STATE_EXTRACT;
	Crt[I_EXTRACT] = TRUE;
	Symb[I_EXTRACT].options = SMDWEXTCS;
	continue;
      }

     if(strncmp("LEVEL",ptr,5) == 0)
       {
	 if ( state == STATE_EXTRACT )
	 {
	    printf("File %s line %d <%s>\n",name_file,line,ptr); 
	    printf("Warning: LEVEL unexpected here. Entry ignored\n");
	    continue;
	 }
	 ptr = next_ptr;
	 if(!Read_Level(ptr,&next_ptr,state,Symb))
	  {
	    printf("File %s line %d <%s>\n",name_file,line,ptr); 
	    printf("Warning: incorrect level \n");
	 }
	 continue;
       }
	
     if(strncmp("COLOR",ptr,5) == 0)
       {
	 if ( state == STATE_EXTRACT )
	 {
	    printf("File %s line %d <%s>\n",name_file,line,ptr); 
	    printf("Warning: COLOR unexpected here. Entry ignored\n");
	    continue;
	 }
	 ptr = next_ptr;
	 if(!Read_Color(ptr,&next_ptr,state,Symb,osnum))
	  {
	    printf("File %s line %d <%s>\n",name_file,line,ptr); 
	    printf("Warning: incorrect color\n");
	  }
	 continue;
       }

     if(strncmp("STYLE",ptr,5) == 0)
      {
	if ( state == STATE_EXTRACT )
	{
	   printf("File %s line %d <%s>\n",name_file,line,ptr); 
	   printf("Warning: STYLE unexpected here. Entry ignored\n");
	   continue;
	}
	ptr = next_ptr;
	if(!Read_Style(ptr,&next_ptr,state,Symb))
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr); 
	   printf("Warning: incorrect style\n");
	 }
	continue;
      }

     if(strncmp("WEIGHT",ptr,6) == 0)
      {
	if ( state == STATE_EXTRACT )
	{
	   printf("File %s line %d <%s>\n",name_file,line,ptr); 
	   printf("Warning: WEIGHT unexpected here. Entry ignored\n");
	   continue;
	}
	ptr = next_ptr;
	if(!Read_Weight(ptr,&next_ptr,state,Symb))
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr); 
	   printf("Warning: incorrect weight\n");
	 }
	continue;
      }
     
     if(strncmp("JUSTIF",ptr,6) == 0)
      {
	ptr = next_ptr;
	if(state != STATE_NAME)
	 {
	   printf("Syntax error line %d <%s>\n",line,ptr);
	   goto wrapup;
	 }
	if(VDSGetNextWord(ptr, word, 79, '#', &next_ptr) != 0)
	  if(!RetJustif(word,&Symb[I_NAME]))
	   {
	     printf("File %s line %d <%s>\n",name_file,line,ptr); 
	     printf("Warning: incorrect justification \n");
	   }
	continue;
      }
     
     if(strncmp("ATTRIBUTE",ptr,9) == 0)
      {
	ptr = next_ptr;
	if(state != STATE_NAME)
	 {
	   printf("Syntax error line %d <%s>\n",line,ptr);
	   goto wrapup;
	 }
	if(VDSGetNextWord(ptr, word, 79, '#', &next_ptr) != 0)
	{
	  Symb[I_NAME].options = (Symb[I_NAME].options & ~0xF000000) | SMDWATTUSR;
	  strcpy( Symb[I_NAME].AttName, word );
	}
	continue;
      }

     if(strncmp("EXTRACT",ptr,9) == 0)
      {
	if(state != STATE_EXTRACT)
	 {
	   printf("Syntax error line %d <%s>\n",line,ptr);
	   goto wrapup;
	 }
	ptr = next_ptr;
	if(!Read_Extract(ptr,&next_ptr,state,Symb))
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr); 
	   printf("Warning: incorrect extract type\n");
	 }
	continue;
      }

     if(strncmp("LINE",ptr,4) == 0)
      {
	if(state != STATE_CONTOUR)
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr);
	   printf("Syntax error: word <LINE> unexpected here\n");
	   goto wrapup;
	 }
	ptr = next_ptr;
	Symb[I_LINE].options = SMDWCLACT | SMDWLVACT | SMDWWTACT
	                       | SMDWSTACT | SMDWCTLNAUTO;
	Crt[I_LINE] = TRUE;
	state = STATE_LINE;
	continue;
      }

     if(strncmp("LENGTH_LINE",ptr,11) == 0)
      {
	if(state != STATE_LINE)
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr);
	   printf("Warning: word <LENGTH_LINE> unexpected here. Ignore it\n");
	   continue;
	 }
	ptr = next_ptr;
	if(sscanf(next_ptr,"%lf",&Symb[I_LINE].lens) != 1)
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr);
	   printf("Incorrect value: expected a number. Ignore entry\n");
	   continue;
	 }
	Symb[I_LINE].options = (Symb[I_LINE].options & ~0xF0000) | SMDWCTLNUSR;
	continue;
      }
     
     if(strncmp("MIN_LENGTH_LINE",ptr,15) == 0)
      {
	if(state != STATE_LINE && state != STATE_MIN_MAX_LINE)
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr);
	   printf("Warning: word <MIN_LENGTH_LINE> unexpected here.Ignore it\n"); 
	   continue;
	 }
	ptr = next_ptr;
	if(sscanf(next_ptr,"%lf",&Symb[I_LINE].lens) != 1)
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr);
	   printf("Incorrect value: expected a number. Ignore entry\n");
	   continue;
	 }
	Symb[I_LINE].options = SMDWCTLNMM;
	state = STATE_MIN_MAX_LINE;
	continue;
      }

     if(strncmp("MAX_LENGTH_LINE",ptr,15) == 0)
      {
	if(state != STATE_LINE && state != STATE_MIN_MAX_LINE)
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr);
	   printf("Warning: word <MAX_LENGTH_LINE> unexpected here.Ignore entry\n"); 
	   continue;
	 }
	ptr = next_ptr;
	if(sscanf(next_ptr,"%lf",&Symb[I_LINE].MaxLens) != 1)
	 {
	   printf("File %s line %d <%s>\n",name_file,line,ptr);
	   printf("Incorrect value: expected a number. Ignore entry\n");
	   continue;
	 }
	Symb[I_LINE].options = SMDWCTLNMM;
	state = STATE_MIN_MAX_LINE;
	continue;
      }

     printf("File %s line %d \n",name_file,line);
     printf("Warning: <%s> unexpected here.Ignore entry\n",ptr);  
   }

  if(!(SMSetDwPr(Crt[I_PLANE],&Symb[I_PLANE],Crt[I_CONTOUR],&Symb[I_CONTOUR],
		 Crt[I_LINE], &Symb[I_LINE], Crt[I_COG], &Symb[I_COG],
		 Crt[I_NAME],&Symb[I_NAME],Crt[I_EXTRACT],&Symb[I_EXTRACT],NULL) & 1))
   {
    printf("Error SMSetDwPr \n");
   }

#ifdef JJ_DEBUG  
  if(!(SMGetDwPr(&Crt[I_PLANE],&Symb[I_PLANE],&Crt[I_CONTOUR],&Symb[I_CONTOUR],
		 &Crt[I_LINE], &Symb[I_LINE], &Crt[I_COG],&Symb[I_COG],
		 &Crt[I_NAME],&Symb[I_NAME], &Crt[I_EXTRACT],&Symb[I_EXTRACT], NULL) & 1))
    printf("Error SMGetDwPr \n");
   

  for(i=0;i<6;i++)
    print_draw_options(Crt,Symb,i);
#endif


  if(fp) fclose(fp);
  return 1;
  
 wrapup:
  printf("Bad file format %s\n",name_file);
  if(fp) fclose(fp);
  return 0;
} 

#ifdef JJ_DEBUG
int print_draw_options(Crt,Symb,i)
IGRboolean Crt[];
struct SMDwSymb	Symb[];
int i;
{
  static char *att[] = {"Contour","Name","Cog","Plane","Line","Extract"};
 
 if(Crt[i])
  {
    printf("\n%s option %x\n",att[i],Symb[i].options);
    if( i == 5 ) return 1;

    if(Symb[i].options & SMDWCLUSR) 
      printf("Color user %d\n",Symb[i].symb.display_attr.color);
    else if(Symb[i].options & SMDWCLOBJ) 
      printf("Color Obj \n");
    else if(Symb[i].options & SMDWCLACT) 
       printf("Color Act \n");

    if(Symb[i].options & SMDWLVUSR)
      printf("Level user %d\n",Symb[i].symb.level);
    else if(Symb[i].options & SMDWLVOBJ) 
      printf("Level Obj \n");
    else if(Symb[i].options & SMDWLVACT) 
      printf("Level Act \n");

    if(Symb[i].options & SMDWWTUSR)
       printf("Weight user  %d\n",Symb[i].symb.display_attr.weight);
    else if(Symb[i].options & SMDWWTOBJ) 
      printf("Weight Obj \n");
    else if(Symb[i].options & SMDWWTACT) 
      printf("Weight Act \n");

    if(Symb[i].options & SMDWSTUSR )
      printf("Style user %d\n",Symb[i].symb.display_attr.style);
    else if(Symb[i].options & SMDWSTOBJ) 
      printf("Style Obj \n");
    else if(Symb[i].options & SMDWSTACT) 
      printf("Style Act \n");
    
    if(i == I_NAME)
     {
       if(Symb[i].options & SMDWTXUSR)
	 printf("Text Justif user defined value = %d\n",Symb[i].TextJust);
       else if(Symb[i].options & SMDWTXACT)
	 printf("Text Justif actif\n");

       if(Symb[i].options & SMDWATTUSR)
	 printf("Name Attribute user defined, Attribute = %s\n",Symb[i].AttName);
       else if(Symb[i].options & SMDWATTOBJ)
	 printf("Name Attribute : Default  [ Compartment Name ]\n");
     }

    if(i == I_LINE)
     {
       if(Symb[i].options & SMDWCTLNUSR)
	 printf("Line user defined value = %g\n",Symb[i].lens);
       else if(Symb[i].options & SMDWCTLNMM)
	printf("Line min max value = %g %g\n",Symb[i].lens,Symb[i].MaxLens);
       else if(	Symb[i].options & SMDWCTLNAUTO)
	 printf("Line auto computed\n");
     }
  }
  else
    printf("\n%s Not display\n",att[i]);

  return 1;
}
#endif
