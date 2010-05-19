/* $Id: VDSLocUt.c,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/func / VDSLocUt.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSLocUt.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
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

/************************************************************************/
/*                 VDSLocUt.c                                           */
/************************************************************************/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#include <VDmsg.h>

#define EXPAND 1
#define FILL_TABLE 2

/* Two list are construct : one for the positive expression     */
/* and one for the negative.                                    */


/* Pointer for positve list */
char **VDreg;
int  VDcur_ln, VDnb_alloc_ln;

/* Pointer for negative list */
char **VDNreg;
int VDNcur_ln,VDNnb_alloc_ln;

extern int the_lex_return;

extern char *lex_errmsg;
extern long lex_errkey;

/* Variables for lex */
char    *VDinput_stream; 
int     VDinput_index;

#define SIZE_ALLOC    1200   
#define ALLOC_INCR     100
#define EXP_MAX_LEN    128

#define MAX_REC_CALL  100 /* Maximum number of variables */

/*************************************************************/
/*           Fill the  array of expression                   */
/*           Return 0 if problem else 1                      */
/*************************************************************/

int fill_reg(exp,type,prefix,suffix,VDReg,VDCur_ln,VDNb_alloc_ln)
char    *exp;           /* (I) the expression to expand      		*/
int	type;           /* (I) the type of expression        		*/
char    *prefix;        /* (I) the prefix to concat with exp 		*/
char    *suffix;        /* (I) the suffix to concat with exp 		*/
char  ***VDReg;         /* (I/O) the adresse of the list of expression  */
int     *VDCur_ln;      /* (I/O) the current line of the list of exp    */
int     *VDNb_alloc_ln; /* (I/O) the number of line which are allocated */ 
{
  int i;
 char tmp[EXP_MAX_LEN];  /* Max is 110 by def */
  char *pt, *strchr();
  int  index1, index2, step, len;

  switch(type)
  {
  case EXPAND:
     /*  prefix[12-34,5] */
     /*  [12-34,5]suffix */   
    
    len = strlen(exp);
    if(len >= EXP_MAX_LEN) return 0;
    strcpy(tmp, exp);
    pt = strchr(tmp,',');
    if(pt == NULL)
     {
      step = 1;
     }
    else 
     {
      *pt = '\0';
      len = strlen(&pt[1]);
      pt[len] = '\0'; /* take off the ] */
      step = atol(&pt[1]);
     }
    /* get indexs */
    if(tmp[1] == '-') 
      pt = strchr(tmp+2,'-');
    else
      pt = strchr(tmp,'-');
    if(pt == NULL) return 0;
    *pt = '\0';
    len = strlen(&pt[1]);
    pt[1+len] = '\0'; 
    index1 = atol(&tmp[1]);
    index2 = atol(&pt[1]);
    if(index1 > index2) /* swap index1 index2 */ 
    {
      long ltmp;
      ltmp = index1;
      index1 = index2;
      index2 = ltmp;
    }
    for(i=index1;i<=index2;i=i+step) 
     {
      sprintf(tmp,"%d",i);
      fill_reg(tmp,FILL_TABLE,prefix,suffix,VDReg,VDCur_ln,VDNb_alloc_ln);
     }
    return 1;


  case FILL_TABLE:

  if(strlen(prefix) + strlen(suffix) < 1)
     if(exp == NULL) return 1;
     else
        if(strlen(exp) < 1) return 1; 
         
  
  if(strlen(prefix) + strlen(suffix) + strlen(exp) >= EXP_MAX_LEN)
  {
     lex_errkey = VD_E_LocExpLong;
     return 0;   
  }

  strcpy(tmp,prefix);
  if(exp != NULL) strcat(tmp,exp);
  strcat(tmp,suffix);

   if(*VDCur_ln >= *VDNb_alloc_ln)
   {
    unsigned size;
    if(*VDNb_alloc_ln == 0)
     {
      /* First allocation */
      *VDReg = (char **) calloc(ALLOC_INCR,sizeof(char *));
      if(*VDReg == NULL)
       {
        printf("Bad dynamic allocation\n");
	return 0;
       }
    }
    else
     {
      /* Reallocation */
      size = (*VDNb_alloc_ln + ALLOC_INCR) * sizeof(char *);
      *VDReg = (char **) realloc(*VDReg, size);
      if(*VDReg == NULL)
       {
        printf("Bad dynamic reallocation\n");
	return 0;
       }
     }
    *VDNb_alloc_ln += ALLOC_INCR;
    for(i= *VDCur_ln;i< *VDNb_alloc_ln;i++) (*VDReg)[i] = NULL;
   }  
   
  /* Allocation of the line */
  (*VDReg)[*VDCur_ln] = (char *) malloc((strlen(tmp) + 1) * sizeof(char));
  if((*VDReg)[*VDCur_ln] == NULL)
   {
    printf("Bad dynamic allocation of the line\n");
    return 0;
   }
  
  strcpy((*VDReg)[*VDCur_ln], tmp);
  (*VDCur_ln)++;
  break;
 
  }
  return 1; 
}


/**************************************************************************/
/*		 supress all variables in a string                        */
/*        A variable is preceded by a '$' (ex $VAR)                       */
/*         return 1 if OK else 0                                          */
/*     The size_alloc determines how many chars are free in the input     */
/*      string. If it is 0 we must reallocated.                           */
/**************************************************************************/

static int vds_supress_variable(instr,outstr,size_alloc,max_call)
char **instr;           /*  (I) The input string (with variable)       */
char **outstr ;         /*  (O) The output string (size unknown)       */
int size_alloc;         /*  (I) size which stay to be allocated        */
int max_call;           /*  (I) the max of recursive call              */ 
{
char *pt1,*pt2;
char var[EXP_MAX_LEN],return_exp[EXP_MAX_LEN];
int i;
int found;

    /* First verify we are not in an infinite loop  */
    if(max_call == 0)
    {
      lex_errkey = VD_E_LocMuchVar;
      return 0;
    } 

    pt1 = strchr(*instr,'$');
    if(pt1 == NULL) /* The search is finish */
    {
      *outstr = (char *)malloc(strlen(*instr)+2); 
      if(*outstr == NULL)
      {
        printf("Bad Dynamic allocation\n");
        return 0;
      }
       strcpy(*outstr,*instr);
       return 1;
    }

    /* Character before variable must be , */
    if(pt1 > *instr && *(pt1-1) != ',')
    {
        lex_errkey = VD_E_LocExpPCom;
        return 0;
     } 
          
   
    pt2 = pt1;

    i = 0;
    while(1)
    {
       pt2++;
       /* a variable contain only alphanumeric char or '_' */
       if(!isalnum(*pt2) && *pt2 != '_')
        { 
          if(*pt2 != ',' && *pt2 != '\0')
          {
       		lex_errkey = VD_E_LocExpTCom;
                return 0; 
          }
          break;
        }

        var[i] = *pt2;
        i++;
        if(i >= EXP_MAX_LEN) 
        {  
           lex_errkey = VD_E_LocVarLong;
           return 0;
         }
    }

    var[i] = '\0';
 
    strcpy(return_exp,""); 
    if(!VDSget_contend(var,return_exp, &found))
    {
        printf("OM_error call VDSget_contend\n");
        return 0;
    }    
        
    if(found == 0)
    {
     lex_errkey = VD_E_LocVarFound;
     lex_errmsg = (char *)malloc(strlen(var) + 5);
     if(lex_errmsg) sprintf(lex_errmsg," $%s",var); 
     return 0;
    }
    
    /* Now replace the variable name by the return_exp */
    /* pt2 is pointing to the end of variable and pt1 is pointing to the dollar */

    if(size_alloc < EXP_MAX_LEN)
    {
     int len ;
     len = sizeof(strlen(*instr)) + SIZE_ALLOC;

      *instr = (char *)realloc(*instr,len);
      if(*instr == NULL)
      {
         printf("Bad Dynamic Reallocation\n");
         return 0;
       }
       size_alloc = SIZE_ALLOC;   
    }
   
    size_alloc -= strlen(return_exp);  

    strcat(return_exp,pt2);
    *pt1 = '\0'; /* So the dollar becomes end of *instr */  
    strcat(*instr,return_exp);
   
    /* Now recursive call */
    return(vds_supress_variable(instr,outstr,size_alloc,max_call - 1));

}   



/************************************************************************/
/*                                                                      */
/*  vds_getreg:     							*/	
/*                                                                      */
/*      Given an regular expression, return it in an expand format      */
/*   understadable by the directory sub-system.                         */
/*									*/
/*   out_reg is a array of strings which is allocated by the function   */
/*   and should be deallocated by the user like:			*/
/*									*/	
/* 									*/
/* if(nb_reg> 0)							*/
/*   {									*/
/*    for(i=0;i<nb_reg;i++) free(out_reg[i]);				*/
/*    free(out_reg);							*/	
/*   }									*/
/*  }									*/
/*                                                                      */
/*  									*/
/************************************************************************/

vds_getreg(in_reg, out_reg, nb_reg,out_no_reg,nb_no_reg,err_key,error_msg)
char   *in_reg;		/* (I) input expression		          */
char ***out_reg;	/* (O) output expanded expression  	  */
int    *nb_reg;		/* (O) Number of reg exp found            */
char ***out_no_reg;	/* (O) expanded expression with negation  */
int    *nb_no_reg;      /* (O) Nb of reg exp with negation found */
long   *err_key;        /* (O) The key in msgfile of a possible syntax error */
char *error_msg;        /* (O) A possible syntax error message    */
{
 char *no_var_in_reg = NULL;
 char *save_in_reg = NULL;
 int status = 0;
 int i;

 *nb_reg = *nb_no_reg = 0;
 *out_reg = *out_no_reg = NULL; 
 lex_errkey = 0;
 lex_errmsg = NULL;

 VDreg = VDNreg = NULL; 

 /* The in_reg will be modified : more prudent to save it */ 
 save_in_reg = (char *)malloc(SIZE_ALLOC ); 
 if(save_in_reg == NULL)
  {
     printf("System error : bad dynamic allocation\n");
     goto cleanup;
  }  
 strcpy(save_in_reg,in_reg);

 if(!vds_supress_variable(&save_in_reg,&no_var_in_reg,
                          SIZE_ALLOC - strlen(in_reg) - 1, MAX_REC_CALL))
     goto cleanup;


 VDcur_ln       =  VDNcur_ln  = 0;
 VDnb_alloc_ln  =  VDNnb_alloc_ln = 0;

 VDinput_index  =  0;

 VDinput_stream = no_var_in_reg;


 the_lex_return = 0; /* Awful but we can't force lex to return a value */
 /* So if syntax error the_lex_return will be modified */ 
 
 vdyylex();
 if( the_lex_return != 0)
 {
   /* Some memory can have been allocated , we must free it now*/
   if( VDcur_ln > 0  && VDreg != NULL)
   {
      for(i = 0 ; i < VDcur_ln ; i++) if(VDreg[i]) free(VDreg[i]);
      free(VDreg);
    }
   if( VDNcur_ln > 0  && VDNreg != NULL)
   {
      for(i = 0 ; i < VDNcur_ln ; i++) if(VDNreg[i]) free(VDNreg[i]);
      free(VDNreg);
    }

      goto cleanup;
 }
 
 *nb_reg =  VDcur_ln;
 *out_reg = VDreg;
 *nb_no_reg = VDNcur_ln;
 *out_no_reg = VDNreg;
  status = 1; 

cleanup:
 *err_key = lex_errkey;
 if(lex_errmsg){
     strncpy(error_msg,lex_errmsg,19);
     error_msg[19] = '\0';
     free(lex_errmsg);
  }
 else
    error_msg[0] ='\0';
 if(no_var_in_reg) free(no_var_in_reg);
 if(save_in_reg)   free(save_in_reg);
 return status;
}

