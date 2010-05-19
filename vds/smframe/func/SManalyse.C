/* $Id: SManalyse.C,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smframe/func / SManalyse.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SManalyse.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.5  1999/05/06  15:36:14  pinnacle
 * (No comment)
 *
 * Revision 1.4  1999/01/08  14:21:14  pinnacle
 * tr179802559
 *
 * Revision 1.3  1998/10/28  23:12:22  pinnacle
 * tr179802227
 *
 * Revision 1.2  1998/10/19  21:21:56  pinnacle
 * TR179801963: Check for step number = 0 in 'Reinforced' field
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.4  1996/05/13  16:06:40  pinnacle
 * Replaced: smframe/func/SManalyse.C for:  by jwfrosch for vds.240
 *
 * Revision 1.3  1996/05/10  18:59:42  pinnacle
 * Replaced: ./smframe/func/SManalyse.C for:  by azuurhou for vds.240
 *
 * Revision 1.2  1996/04/17  14:42:44  pinnacle
 * Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
 *
 * Revision 1.1  1995/04/05  21:35:06  pinnacle
 * Created: smframe/func/SManalyse.C by tdumbach r#
 * rno
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
 *	10/19/98	ejm	TR179801963: Place Plane System
 *				Crashes when zero entered in Reinforced field of
 *				form, SMFrmSect, as follows: [1-10,0].
 *				Code now checks for zero in function,Expression.
 *	10/28/98	ylong   TR179802227
 *	01/04/99	ah      TR179802559 Previous fix broke stuff
 *	05/06/99	Ming 	TR179900514 and TR179900515
 * -------------------------------------------------------------------*/

/*   VDanalyse.C  */
/*  Analyse of a string defining some sections for the frame system */

#include <stdio.h>
#include <malloc.h>
#include <ctype.h>
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/* #define DEBUG 1 */
#define ALLOC_INCR 100

static int sizealloc ;


/* An expression is [num1-num2,pas] or  [num1-num2] */

static int Expression(cur,int_array,index,nb_elem)
char	**cur;
int	**int_array;
int	*index;
int	*nb_elem;
{
  char moins,virg,croch;
  int i;
  int nmatch;
  int n;
  int deb,fin,pas;
  char *p_cur; 

#ifdef DEBUG
  printf("expression <%s>\n",*cur);
#endif

  // TR179802559 Init the variables
  deb = fin = pas = 0;
  moins = virg = croch = 0;
  
  p_cur = *cur + 1; /* Match apres le crochet '[' */

  nmatch = sscanf(p_cur,"%d%c%d%c%d%c",&deb,&moins,&fin,&virg,&pas,&croch); 
    /* We want match for exemple [2-10,3] or [2-10] */

  if(deb <= fin && pas < 0) {
    // printf("deb %d, fin %d, pas %d\n",deb,fin,pas);
    return 0;    /*TR179802227 by ylong */
  }
  
  if(nmatch < 4)
   {
#ifdef DEBUG
     printf("Pas une expression \n");
#endif
     return 0;
   }

  if(moins != '-' )
   {
#ifdef DEBUG
     printf("Manque signe moins\n");
#endif
     return 0;
   }

  if(nmatch == 6 && (virg != ',' || croch != ']'))
   {
#ifdef DEBUG
     printf("Manque virgule\n");
#endif
    return 0;
   }

  if(nmatch == 6 && pas == 0)
   {
#ifdef DEBUG
     printf("Step number in 'Reinforced' string cannot equal 0\n");
#endif
    return 0;
   }

  if(nmatch < 6)
    if(virg != ']')
     {
#ifdef DEBUG
       printf("Crochet pas ferme\n");
#endif
     }
    else
      pas = 1; /* Exp if for exemple [2-10] */

  
  if(deb > fin)
  {
#ifdef DEBUG
     printf("Deb > fin\n");
#endif
     return 0;
  }
 
  /* TR179900514 and TR179900515 */
  if( pas == 0 )
  {
#ifdef DEBUG
    printf("pas == 0\n");
#endif
    return 0;
  }

  n = (fin - deb)/pas + 1; /* Count number of element */

  if(n + *nb_elem > sizealloc)
  {
     *int_array = _REALLOC(*int_array, (n + *nb_elem+ALLOC_INCR),int);
     if(*int_array == NULL)
      {
	printf("Not enough memory\n");
	sizealloc = 0 ;
	return 0;
      }
     else
       sizealloc = n + *nb_elem + ALLOC_INCR;
  }
  
  /* Fill array of element */
  n = 0;
  i = *index;
  while((deb + n * pas) <= fin)
  {
     (*int_array)[i] = deb + n * pas;
     i++;
     n++;
  }

  /* Position to the end of the expression */
  *nb_elem += n;
  *index = i;
  while((*p_cur != ']') && (*p_cur != '\0'))
    p_cur++;

  if(*p_cur == '\0')
  {
     	__DBGpr_com(" Brackets not closed ");
	_FREE ( *int_array );
	*int_array = NULL ;
	return 0;
  }
  else
	p_cur++;

	__DBGpr_int("expression found # elem", n );

	*cur = p_cur;
	return 1;
}

/* Parse a number */

static int Number(cur,int_array,index,nb_elem)
char **cur;
int **int_array;
int  *index;
int *nb_elem;
{
  int number;

  if(sscanf(*cur,"%d",&number) != 1)
    return 0;
  if(**cur == '-') (*cur)++;
  while(isdigit(**cur) && (**cur != '\0'))
    (*cur)++;
  
  if(*nb_elem + 2 > sizealloc)
    *int_array = _REALLOC(*int_array, (*nb_elem+ALLOC_INCR),int);
  if(*int_array == NULL)
   {
     printf("Not ernough memory\n");
     sizealloc = 0 ;
     return 0;
   }
  else
    sizealloc = (*nb_elem + ALLOC_INCR);

   (*int_array)[*index] = number;
  
  (*index)++;
  *nb_elem += 1;
  return 1;
}

/* Analyse an expression to determine the selected number */
/* Expressions valid are of the form Exp1,Exp2,Exp3,... */
/* where Exp is of the form [from-to] or [from-to,step] or is a number */
/* It allocated the int_array which must be deallocated by the caller  */ 
/* Return 1 if OK and 0 if error */

SMFrmAnalyseExp(expr,int_array,nb_elem,syn_error)
char	*expr;		/* [I] The expression to analyse */
int	**int_array;	/* [O] Pointer to the array to be allocated */ 
int	*nb_elem;	/* [O] Number of integer in the int_array */
char	*syn_error;	/* [O] pointer to char for syntax error */
{
	char	*cur;
	int	index;

	SetProc( SMFrmAnalyseExp ); Begin

	cur		= expr;
	index		= 0;
	sizealloc	= 0;
	*nb_elem	= 0;
	*int_array	= NULL;

	if( expr[0] == '\0' ) return 1;  
  
	*int_array = _CALLOC( ALLOC_INCR, IGRint );
	if( *int_array == NULL ){
		printf("Not enough memory\n");
		End
		return 0 ;
	}

	sizealloc = ALLOC_INCR;

	while( 1 ){

	  __DBGpr_str(" To Analyse ", cur );	
	  switch( *cur ){
	  case '\0':	return 1;
	  case ',' :	cur++;	break;
	  case '[' :

	    if( ! Expression( &cur, int_array, &index, nb_elem )){
	      strncpy(syn_error,cur,14);
	      syn_error[15] = '\0';
	      if ( *int_array ) _FREE ( *int_array );
	      End
	      return 0;
	    }
	    break;

	  case '-' :
	    if( ! Number( &cur, int_array, &index, nb_elem )){
		strncpy(syn_error,cur,5);
		syn_error[5] = '\0';
		return 0;
	    }
	    break;
	  default:
	    if(isdigit(*cur)){
	      if(!Number(&cur,int_array,&index,nb_elem)){
	        strncpy(syn_error,cur,5);
	        syn_error[5] = '\0';
	        return 0;
	      }
	    }
	    else{
	      syn_error[0] = *cur;
	      syn_error[1] = '\0'; 
	      return 0;
	    }
	  } /* switch */
	}
}	  

#ifdef TEST
main()
{
  char exp[240];
  int *result = NULL;
  int nb_elem;
  int i;
  char syn_error[40];

  printf("Entrez chaine a analyser\n");
  gets(exp);
  if(!SMFrmAnalyseExp(exp,&result,&nb_elem,syn_error))
   {
     printf("Syntax error %s\n",syn_error);
     exit();
   }

  printf("Nb_Elem found %d\n",nb_elem);
  printf("Element found :");
  for(i = 0 ; i < nb_elem ; i++)
   {
     if(i % 15 == 0) printf("\n");
     printf("%d ",result[i]);
   }
  _FREE(result);
  printf("\n");
}
#endif



