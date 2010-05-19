/* $Id: SMReadSetUp.C,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        SMcomp/SMReadSetUp.C
 *
 * Description:
 *
 *      This file implement functions used for the compartment setup.
 *
 * Dependencies:
 *
 *
 * Revision History:
 *	$Log: SMReadSetUp.C,v $
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
 *      05/01/93  J. Jasinczuck: Creation date.
 *
 * -------------------------------------------------------------------------
 */

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "wl.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "godef.h"
#include "go.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include "msdef.h"
#include "msmacros.h"

#include "SMCompForm.h"
#include "vdsmacros.h"


#include "SMmsg.h"

#define NB_MAX_ATTR      25
#define MAX_READ_BUFFER 256

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMReadCompSetup

  Abstract
        The function reads in an ascii file all the parameters for the
        compartment setup and set them in a ACrg_coll.

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/
int SMReadCompSetup(
char         *name_file,   /* [I] Name of the file containing ship_type */
struct GRid  *coll         /* [O] Created ACrg                          */
)
/*
-fi */
{
  FILE             *fp,*fptr;
  char 	           buffer[MAX_READ_BUFFER], *ptr,*next_ptr,*pt;
  int              i;
  int              line = 0;
  char             word[ATTR_TXT],name[ATTR_TXT],ppl_name[ATTR_TXT];
  char             name_symb[ATTR_TXT],track[ATTR_TXT],tmp[ATTR_TXT];
  char             save_static[ATTR_TXT];
  struct ACrg_coll ACrg[5];
  int              nb_att = 0;

  coll->objid = NULL_OBJID;

  fp = NULL;
  /* Have to look inside the config */
  vd$openfile(file_name 	= name_file,
	      product_name 	= "Vds",
	      sub_path	        = "config",
	      cur_dir	  	= TRUE,
	      p_file	  	= &fp);
  if(fp == NULL)
   {ex$message(msgnumb = SM_E_NoDefSetup); return 0;}

  /* Initialize no compart tracking and no attribut for symbology */ 
  strcpy(ACrg[0].name,SYMB_ATT_STR);
  ACrg[0].desc.type = AC_ATTRIB_TEXT;
  strcpy(ACrg[0].desc.value.att_txt,"dead_weight");
  
  strcpy(ACrg[1].name,TRACKING_STR);
  ACrg[1].desc.type = AC_ATTRIB_TEXT;
  strcpy(ACrg[1].desc.value.att_txt, "no");

  nb_att = 2;

  while(fgets(buffer,MAX_READ_BUFFER-1, fp) != NULL)
   {
     line++;
     buffer[MAX_READ_BUFFER -1] = '\0';
     if(strlen(buffer) < 1) continue;  /* Take out the blank line */
     buffer[strlen(buffer)-1] = '\0'; /* To take into account the return */
     
     /* Skip blank characters */
     i = 0;
     while(isspace(buffer[i]) && buffer[i] != '\0') i++;
     ptr = &buffer[i];
     
     if(*ptr == '#') continue; /* A comment line (starting by #) */
     
     if(*ptr == '\0') continue; /* Blank line */
      
     if(VDSGetNextWord(ptr, word,ATTR_TXT, ',', &next_ptr) == 0)
      {
	printf("Warning, syntax error line %d : => %s\n",line,ptr);
	goto wrapup;
      }
    
     if(strncmp("PPL_ATTRIBUT",ptr,12) == 0)
      {
	if(nb_att >= 5)
	 {printf("Warning Tout much ppl attribut\n"); continue;}

	if(!next_ptr)
	  {printf("Warning,syntax error line %d : => %s\n",line,ptr); continue;}
	else
	  ptr = next_ptr;
      
	if(VDSGetNextWord(ptr, ppl_name,ATTR_TXT, ',', &next_ptr) == 0)
	 {
	   printf("Warning, syntax error line %d : => %s\n",line,ptr);
	   continue;
	 }
	
	ppl_name[ATTR_TXT -1] = '\0';

	if(pt = strstr(ppl_name,".")) *pt = '\0'; /* Dont save extension */
	if(ppl_name[0] == '\0' || strlen(ppl_name) > 12) 
	 {
	    ex$message(msgnumb = SM_E_CmBadPPL,type = "%s",var = `name`);
	    continue;
	  }
        
	/* Verify that ppl file exists */
	fptr = NULL;
	strcpy(tmp,ppl_name);
	strcat(tmp,".e");
	vd$openfile(file_name	   = tmp,
		    product_name   = "Vds",
		    sub_path	   = "ppl/bin",
		    cur_dir	   = TRUE,
		    p_file	   = &fptr );
	if( fptr == NULL )
	 {
	   ex$message( msgnumb = SM_E_CmNoFile, type = "%s",var = `ppl_name`);
	   continue;
	 }
	else fclose(fptr);

	strcpy(ACrg[nb_att].name,"PPL_FILE");
	ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
	strcpy(ACrg[nb_att].desc.value.att_txt,ppl_name);
	nb_att++;
	continue;
      }
     
     if(strncmp("DEF_SYMBOLOGY",ptr,13) == 0)
      {
	if(!next_ptr)
	 {printf("Warning,syntax error line %d : => %s\n",line,ptr); continue;}
	else
	  ptr = next_ptr;
	if(VDSGetNextWord(ptr,name_symb, ATTR_TXT, ',', &next_ptr) == 0)
	 {
	   printf("Warning, syntax error line %d : => %s\n",line,ptr);
	   continue;
	 }
	name_symb[ATTR_TXT -1] = '\0';
	strcpy(ACrg[0].name,SYMB_ATT_STR);
	ACrg[0].desc.type = AC_ATTRIB_TEXT;
	strcpy(ACrg[0].desc.value.att_txt,name_symb);
      }
     
     if(strncmp("COMP_TRACKING",ptr,13) == 0)
       {
	 if(!next_ptr)
	  {printf("Warning,syntax error line %d : => %s\n",line,ptr); continue;}
	 else
	   ptr = next_ptr;

	 if(VDSGetNextWord(ptr,track, ATTR_TXT, ',', &next_ptr) == 0)
	 {
	   printf("Warning, syntax error line %d : => %s\n",line,ptr);
	   continue;
	 }
	 track[ATTR_TXT -1] = '\0';
	 if(strcmp(track,"yes") && strcmp(track,"no"))
	  {
	    printf("Warning, \"yes\" or \"no\" expected : file %s ,line %d\n",
		   name_file,line); 
            continue;
	  }
	 strcpy(ACrg[1].name,TRACKING_STR);
	 ACrg[1].desc.type = AC_ATTRIB_TEXT;
	 strcpy(ACrg[1].desc.value.att_txt, track);
       }

     if(strncmp("SAVE_STATIC",ptr,11) == 0)
      {
	if(!next_ptr)
	 {printf("Warning,syntax error line %d : => %s\n",line,ptr); continue;}
	else
	  ptr = next_ptr;

	if(VDSGetNextWord(ptr,save_static, ATTR_TXT, ',', &next_ptr) == 0)
	 {
	   printf("Warning, syntax error line %d : => %s\n",line,ptr);
	   continue;
	 }
	 save_static[ATTR_TXT -1] = '\0';
	 if(strcmp(save_static,"yes") && strcmp(save_static,"no"))
	  {
	    printf("Warning, \"yes\" or \"no\" expected : file %s ,line %d\n",
		   name_file,line); 
            continue;
	  }
	 /*   Set save or not save cache       */ 
	SMSetFlagCache("compartment",(strcmp(save_static,"yes") == 0));
      }
   }

#ifdef JJ_DEBUG     
  print_options(ACrg,nb_att);
#endif
    
/*     if(!SMGetSetupObj(coll,ACrg,nb_att)) Correction PL april 1994 bad arguments */
     if(!SMGetSetupObj(coll)) 
      {printf("Error retrieving setup object\n"); goto wrapup;}
       
     if(!SMSetSetupObj(coll,ACrg,nb_att))
      {printf("Error setting setup object\n"); goto wrapup;}

     if(fp) fclose(fp);
     return 1;
  
   wrapup:
     printf("Incorrect file format %s\n",name_file);
     if(fp) fclose(fp);
     return 0;
} 

#ifdef JJ_DEBUG

int print_options(ACrg,nb_att)
struct ACrg_coll *ACrg;
int nb_att;
{
  int i;
  
  for(i=0;i<nb_att;i++)
   {
     printf("%s %s\n\n",ACrg[i].name,ACrg[i].desc.value.att_txt);
   }
  return 1;
}

#endif
