/* $Id: VDSdbstr.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbstr.c
 *
 * Description:
 *	String routines used by AddPart.rc
 *		Nearly the same functions defined in VDSdbstring.c.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbstr.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
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
 * Revision 1.2  1996/05/20  17:39:14  pinnacle
 * Replaced: vddb/source/VDSdbstr.c for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1996/05/20  17:35:04  pinnacle
 * Created: vddb/source/VDSdbstr.c by tlbriggs for vds.240
 *
 * Revision 1.3  1996/04/22  15:14:52  pinnacle
 * Replaced: vddb/source/VDSdbstr.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbstr.c for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/18/96   tlb		Add prototypes
 *				Add DOUBLE
 *	04/22/96     tlb	Fix log comment problem 
 *	05/20/96     tlb	Fix prototype file name
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include 	<string.h>
#include	"VDSdbstr.h"
#include	"VDSdbio.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

#define         FLOAT           "float"
#define  	DOUBLE		"double"

#define         QUOTE           '\''
#define         OBRA            '['
#define         CBRA            ']'
#define         OPAR            '('
#define         CPAR            ')'
#define         PIPE            '|'


/*----------------------------------------------------------------------------*/


int VDSdbsplit_line ( string, line)

   char		 string[];	/* string to analyse  (I)		      */
   struct MFlin  *line;		/* structure to fill  (O)		      */

  {

   /***************************************************************************/
   /*									      */
   /*   This routine split a string from an ASCII file into separated data    */
   /* and a MFlin structure.						      */
   /*									      */
   /*   Algorithm :							      */
   /*			1)  initialization of variables			      */
   /*			2)  suppress '\n' caracter at the end of the string   */
   /*			3)  count and store '=' caracters		      */
   /*			4)  count and store '(' caracters		      */
   /*			5)  count and store ')' caracters		      */
   /*			6)  test consistency between parenthesis' positions   */
   /*			7)  fill MFlin structure with texts and units	      */
   /*									      */
   /***************************************************************************/

   int  i;		/* loop index					      */
   int  j;		/* loop index					      */
   int  k;		/* loop index					      */
   int  len;		/* length of input string			      */
   int  neq = 0;	/* number of '=' in the input string		      */
   int  nop = 0;	/* number of '(' in the input string		      */
   int  nsp = 0;	/* number of ')' in the input string		      */
   int  eq[VDS_BUF_MAX_CHAR];	/* position of the '=' in the input string    */
   int  op[VDS_BUF_MAX_CHAR];	/* position of the '(' in the input string    */
   int  sp[VDS_BUF_MAX_CHAR];	/* position of the ')' in the input string    */
   char temp[VDS_BUF_MAX_WORD+10];/* work string			      */
 

#ifdef STEP
   printf ( "Enter in  VDSdbsplit_line\n");
#endif

   
   /* initialization */
   for (i=0;i<VDS_BUF_MAX_CHAR;i=i+1)
     {
      eq[i] = 0;
      op[i] = 0;
      sp[i] = 0;
     }
   for (j=0; j<VDS_BUF_MAX_WORD+10; j=j+1)
     {
      temp[j]    = 0;
     }
   
   /* Exit for null file */
   len = strlen ( string);
   if ( len == 0)
     {
      goto quit;
     }

   /* Change \n by \0 */ 
   if ( string[len-1] == BACK_N )
      string[len-1] = 0;

   /* Searching = characters */
   for ( i=0; i<len; i=i+1)
     {
      if ( string[i] == EQUAL)
        {
         neq=neq+1;
         eq[neq] = i;
        }

      /* for I/MCL only 
      if ( string[i] == QUOTE)
         string[i] = BLANK;
      */
     }
   neq=neq+1;
   eq[neq] = len-1;
   neq=neq+1;

   /* Searching '(' and ')' characters */
   for ( i=0; i<neq; i=i+1)
     {
      for ( j=eq[i]; j<eq[i+1]; j=j+1)
        {
         switch ( string[j])
           {
            case OPAR :
              {
               op[nop]  =j;
               nop=nop+1;
               break;
              }
            case CPAR :
              {
               sp[nsp]  =j;
      	       nsp=nsp+1;
               break;
              }
            default   :
               ;
           }
        }
     }

   /* Exit if ('s number is different of )'s number */
   if ( nop != nsp)
     {
      printf ( "syntax error : %d open parentheses for %d shut parentheses\n",
               nop, nsp);
      goto quit;
     }

   nop = 0; nsp = 0; /* To skip doing special things for paranthesis */

   /* Extracting text and unit strings */
   line->seg_num = neq-1;
   j = 0;
   for ( i=0; i<neq-1; i=i+1)
      {
       if ( (op[j] < eq[i+1]) && (j < nop) && (j < nsp) )
         {
          if ( string[eq[i]] == EQUAL)
            {
             for ( k=eq[i]+1; k<op[j]; k=k+1)
                temp[k-eq[i]-1] = string[k];
             temp[op[j]-eq[i]-1] = 0;
            }
          else
            {
             for ( k=eq[i]; k<op[j]; k=k+1)
                temp[k-eq[i]] = string[k];
             temp[op[j]-eq[i]] = 0;
            }
          /*strcpy ( line->name[i].text, temp); */
 	  if( strlen(temp) < (VDS_BUF_MAX_WORD+2) )
	    sprintf( line->name[i].text,"%s\0",temp);
	  else
	  {
	    printf("Length of the value <%s> too long %d \n", temp,strlen(temp));
	    return 0;
	  }
          if ( (sp[j] < eq[i+1]) && (op[j] < sp[j]) )
            {
             for ( k=op[j]+1; k<sp[j]; k=k+1)
                temp[k-op[j]-1] = string[k];
             temp[sp[j]-op[j]-1] = 0;
             strcpy ( line->name[i].unit, temp);
             j=j+1;
            }
          else
             printf ( " error : op=%d  sp=%d  eq=%d\n", op[j], sp[j], eq[i+1]);
	 }
       else
         {
          if ( string[eq[i]] == EQUAL)
            {
             for ( k=eq[i]+1; k<eq[i+1]; k=k+1)
                temp[k-eq[i]-1] = string[k];
             temp[eq[i+1]-eq[i]-1] = 0;
            }
          else
            {
             for ( k=eq[i]; k<eq[i+1]; k=k+1)
                temp[k-eq[i]] = string[k];
             temp[eq[i+1]-eq[i]] = 0;
            }
/*          strcpy ( line->name[i].text, temp); */

 	  if( strlen(temp) < (VDS_BUF_MAX_WORD+2) )
	    sprintf( line->name[i].text,"%s\0",temp);
	  else
	  {
	    printf("Length of the value <%s> too long %d \n", temp, strlen(temp));
	    return 0;
	  }
          strcpy ( line->name[i].unit, "");
         }
      }

quit :

   return ( 1);
  }


/*----------------------------------------------------------------------------*/


int VDSdbconvert ( string)

   char	string[];	/* datatype to translate to PDM rules		      */

  {
 
   /***************************************************************************/
   /*									      */
   /*   This routine convert a datatype from the ASCII file to a datatype     */
   /* coherent with PDM rules.						      */
   /*									      */
   /*   Algorithm :							      */
   /*			1)  initialization of variables			      */
   /*			2)  locate '[' position 			      */
   /*			3)  locate ']' position 			      */
   /*			4)  test consistency between brackets' positions      */
   /*			5)  replace brackets by parenthesis		      */
   /*			6)  replace "float" by "double"			      */
   /*									      */
   /***************************************************************************/

   int	i;		/* loop index					      */
   int	len = 0;	/* length of the input string			      */
   int	ob  = 0;	/* position of '['				      */
   int	cb  = 0;	/* position of ']'				      */


#ifdef STEP
   printf ( "Enter in  VDSdbconvert\n");
#endif

   /* length of the string */
   len = strlen ( string);
   
   /* scanning for brackets */
   if ( len == NULL)
     {
      printf ("error : null string to convert\n");
      goto quit;
     }
   else
     {
      for ( i=0; i<len; i=i+1)
        {
         switch ( string[i])
           {
            case OBRA :
              {
               ob = i;
               break;
              }
            case CBRA :
              {
               cb = i;
               break;
              }
            default   :
               ;
           }
        }     

      if ( (ob < cb) && (cb <= len) )
        {
         /* replace brackets by parenthesis */
         string[ob] = OPAR;
         string[cb] = CPAR;
        }
      else if ( (ob == 0) && (cb == 0) )
        {
         /* replace "float" by "double */
         if ( strcmp ( string, FLOAT) == 0)
            strcpy ( string, DOUBLE);
        }
      else
        {
         printf ( "error : unbalanced brackets, ob=%d, cb=%d, len=%d\n",
                 				   ob,    cb,     len);
         goto quit;
        }
     }
quit :
 	  	  	  	  	 
   return ( 1);

  }


/*----------------------------------------------------------------------------*/


int VDSdbdecrypt_string ( input, key, column, format, p_num)

   char	*input;		/* string to analyse	(I)			      */
   char	*key;		/* key word	 	(O)			      */
   char	*column;	/* attribute name	(O)			      */
   char	*format;	/* attribute datatype	(O)			      */
   int	*p_num;		/* attribute number	(O)			      */

  {
 
   /***************************************************************************/
   /*									      */
   /*   This routine extract significant attributes from a crypted string.    */
   /*									      */
   /*   Algorithm :							      */
   /*			1)  initialization of variables			      */
   /*			2)  locate '|' position 			      */
   /*			3)  split the input string into known elements	      */
   /*									      */
   /***************************************************************************/
 
   int	i;		/* loop index					      */
   int	len;		/* string length				      */
   int	three;		/* key word length				      */
   int	n = 0;		/* number of '|'				      */
   int	npipe[2];	/* position of '|' in the string		      */
   char order[VDS_BUF_MAX_WORD];/* string for attribute number 			      */

#ifdef STEP
   printf ( "Enter  in VDSdbdecrypt_string\n");
#endif

   /*initialization */
   key[0]    = 0;
   column[0] = 0;
   format[0] = 0;
   *p_num    = 0;

   len      = strlen (input);
   three    = strlen (DL);
   order[0] = 0;
   npipe[0] = 0;
   npipe[1] = 0;

#ifdef STEP
   printf ("testing : <%s>\n", input);
#endif

   for ( i=0; i<len; i++)
     {
      if ( input[i] == PIPE)
        {
         npipe[n] = i;
         n++;
        }
     }

#ifdef STEP
   printf ("pipe1=%d, pipe2=%d, n=%d\n", npipe[0], npipe[1], n);
#endif

   switch (n) 
     {
      case 0:
        strcpy ( column, input);
        break;

      case 1:
        for ( i = 0; i < npipe[0]; i++)
           column[i] = input[i];
        column[npipe[0]] = 0;

        for ( i = npipe[0] + 1; i <= len; i++)
           format[i - npipe[0] - 1] = input[i];
        break;

      case 2:
        for ( i = 0; i < three; i++)
           key[i] = input[i];
        key[three] = 0;

        for ( i = three; i < npipe[0]; i++)
           order[i-three] = input[i];
        order[npipe[0]] = 0;
        *p_num = atoi ( order);

        for ( i = npipe[0] + 1; i < npipe[1]; i++)
           column[i - npipe[0] - 1] = input[i];
        column[npipe[1] - npipe[0] - 1] = 0;

        for ( i = npipe[1] + 1; i <= len; i++)
           format[i - npipe[1] - 1] = input[i];
        break;

      default:
        printf ( "VDSdbdecrypt_string : bad formated input string : <%s>\n", 
                 input);
     }

   return 1;
  }


/*----------------------------------------------------------------------------*/


int VDSdbget_value ( input, key, output)

   char	*input;		/* string to analyse	(I)			      */
   char	*key;		/* key word	 	(I)			      */
   char	*output;	/* resulting string	(O)			      */

  {
 
   int  i;
   int  linput;
   int  lkey;
   char string[VDS_BUF_MAX_LONG];

   linput = strlen ( input);
   lkey   = strlen ( key);

   for ( i=lkey; i<linput; i++)
       string[i-lkey] = input[i];
 
   string[linput-lkey-1] = 0;

   strcpy ( output, string);

   return (1);
  }
