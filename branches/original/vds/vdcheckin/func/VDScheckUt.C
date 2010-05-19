/* $Id: VDScheckUt.C,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/func / VDScheckUt.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDScheckUt.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:57  cvs
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
 * Revision 1.2  1996/05/03  15:44:10  pinnacle
 * Replaced: vdcheckin/func/VDScheckUt.C for:  by sljenks for vds.240
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
 *	05/01/96	slj		changed malloc, free to _MALLOC, _FREE
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 30 Dec 91	  creation date.
/*
/* */

#include <stdio.h>

#include "OMminimum.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "vdsmacros.h"
#include "VDmem.h"
#include "VDScheckdef.h"

#include "part.h"

#define MAX_CHAR_LINE             81


#define NB_ALLOC 2

/* 
/*  Read an ascii file describing the GRpart attribute.
/*  The pointer (part_attr) is allocated in this funstion and have to be 
/*  freed by the caller.
/*  
/* */
VDSReadPartInfo(
  char 		    *file ,   	     /* name of the ascii file 	      (I) */
  int		    *nb_attr,        /* nb elements of part_attr      (O) */
  struct VDpart_attr  **part_attr )  /* attributes info		      (O) */
{
 FILE   *fp;
 char 	 buffer[MAX_CHAR_LINE], *ptr=NULL, *next_ptr=NULL, *line;
 char 	 tmp[15];
 int	 i, nb_alloc;
 char    sep;
 int	 status;
 
 status = TRUE;
 sep = ',';  /* It is the separator */

 *nb_attr = 0;
 nb_alloc = 0;

 /* try to open the ascii file */
 if(vd$openfile(file_name    = file,
                product_name = "Vds",
		sub_path     = "config",
		cur_dir      = TRUE,
		p_file       = &fp) == 0)
  {
   /* no ascii file found */
   return 0;
  }
 
 while(fgets(buffer,MAX_CHAR_LINE-1, fp) != NULL)
  {
   short blank_line;

   line = &buffer[0];

   /*"buffer line: <%s>, length: %d\n", buffer , strlen(buffer) */
   /*| Take out the blank line */
   if(strlen(buffer) < 1) continue;
   buffer[strlen(buffer)-1] = '\0'; /* To take into account the return */

   blank_line = 1;
   for(i=0;i<strlen(buffer);i++)
     if(buffer[i] != ' ' && buffer[i] != '\t') { blank_line = 0; break; }
   if(blank_line) continue;

   /*| take out the first blanc charracters */
   for(i=0;i<strlen(buffer);i++)
    {
     if(buffer[i] != ' ' && buffer[i] != '\t') { ptr = &buffer[i]; break; }
    }

   /*| Take out the comment line (starting by #) */
   if(ptr[0] == '#') continue;

   if(nb_alloc < *nb_attr + 1)
    {
     /* Alloc the part_attr structure */
     if(nb_alloc == 0)
      {
       /* first allocation */
       *part_attr = _MALLOC (NB_ALLOC, struct VDpart_attr);
       _CheckAlloc (part_attr, "malloc:part_attr", status, FALSE, quit);
      } 
     else
      {
       /* reallocation */
       *part_attr = _REALLOC (*part_attr, NB_ALLOC + nb_alloc, struct VDpart_attr);
       _CheckAlloc (part_attr, "realloc:part_attr", status, FALSE, quit);
      }
     nb_alloc += NB_ALLOC;
    }

   /* Get the GRpart att name and type, the part name and type */
   if(VDSGetNextWord(ptr, (*part_attr)[*nb_attr].GRpart_column, 21, sep, &next_ptr) == 0)
    {
     printf("Warning, syntax error for: \n");
     printf("=> %s\n", line);
     continue;
    }

   ptr = next_ptr;
   if(VDSGetNextWord(ptr, tmp, 15, sep, &next_ptr) == 0)
    {
     printf("Warning, syntax error for: \n");
     printf("=> %s\n", line);
     continue;
    }
   if(tmp[0] == 'D' || tmp[0] == 'd') (*part_attr)[*nb_attr].GRpart_type =  GR_DYNAMIC_ATTR;
   else if(tmp[0] == 'S' || tmp[0] == 's') (*part_attr)[*nb_attr].GRpart_type =  GR_STATIC_ATTR;
   else 
    {
     printf("Bad GRpart type (DYNAMIC/STATIC) for: \n");
     printf("=> %s\n", line);
     continue;
    }

   ptr = next_ptr;
   if(VDSGetNextWord(ptr, (*part_attr)[*nb_attr].part_name, 21, sep, &next_ptr) == 0)
    {
     printf("Warning, syntax error for: \n");
     printf("=> %s\n", line);
     continue;
    }

   ptr = next_ptr;
   if(VDSGetNextWord(ptr, tmp, 15, sep, &next_ptr) == 0)
    {
     printf("Warning, syntax error for: \n");
     printf("=> %s\n", line);
     continue;
    }
   if(tmp[0] == 'D' || tmp[0] == 'd') (*part_attr)[*nb_attr].part_type = DYN;
   else if(tmp[0] == 'S' || tmp[0] == 's') (*part_attr)[*nb_attr].part_type = STAT;
   else if(tmp[0] == 'U' || tmp[0] == 'u') (*part_attr)[*nb_attr].part_type = USER;
   else 
    {
     printf("Bad GRpart type (DYNAMIC/STATIC/USER) for:\n");
     printf("=> %s\n", line);
     continue;
    }

   *nb_attr += 1;
  } /* end while */


quit:

 fclose(fp);
 return (status);
}

 

