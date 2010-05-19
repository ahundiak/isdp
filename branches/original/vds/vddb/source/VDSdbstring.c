/* $Id: VDSdbstring.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbstring.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbstring.c,v $
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
 * Revision 1.5  1996/05/20  03:33:36  pinnacle
 * Replaced: vddb/source/VDSdbstring.c for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1996/05/08  23:02:18  pinnacle
 * Replaced: vddb/source/VDSdbstring.c for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1996/04/22  15:14:58  pinnacle
 * Replaced: vddb/source/VDSdbstring.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbstring.c for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/15/96   tlb		Use VDS memory checking
 *				Add prototypes
 *				Modify VDSstrcpy
 *				Add DOUBLE from VDSdbstr.h
 *				Rename VDSdbstr.h constants 
 *	04/22/96     tlb	Fix log comment problem 
 *	05/08/96     tlb  	Change prototype file name
 *				Remove VDSget_value, VDSstrcpy
 *	05/09/96     tlb	From VDSload.C: VDBpadstr, 
 *					VDBdelTrailSpaces,  VDBdelLeadSpaces
 *				Use error handling routines
 *				VDSconvert - convert to boolean
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include 	<string.h>
#include 	<pwd.h>
#include	"VDSdberrdef.h"
#include	"VDSdbstr.h"
#include	"VDSdbio.h"
#include	"VDmem.h"
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

int VDSsplit_line ( 
   			char		string[],  /* string to analyse  (I) */
   			struct MFlin	*line	   /* structure to fill  (O) */
			)
{
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
   char temp[VDS_BUF_MAX_WORD]; /* work string				     
*/
   int  status;
 

#ifdef STEP
   printf ( "Enter in  VDSsplit_line\n");
#endif

   
   /* initialization */
   status = VDS_S_SUCCESS; 
   for (i=0;i<VDS_BUF_MAX_CHAR;i=i+1)
     {
      eq[i] = 0;
      op[i] = 0;
      sp[i] = 0;
      for (j=0; j<VDS_BUF_MAX_WORD; j=j+1)
        {
         temp[j]    = 0;
        }
     }
   status = VDS_S_SUCCESS; 
   
   /* Exit for null file */
   len = strlen ( string);
   if ( len == 0)
     {
       status = VDS_E_FAILURE; 
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

      if ( string[i] == QUOTE)
         string[i] = BLANK;
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
      VDSprintErr ("\t", "syntax error in buffer: %d open parentheses for %d shut parentheses\n",
               nop, nsp);
      status = VDS_E_FAILURE; 
      goto quit;
     }

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
          strcpy ( line->name[i].text, temp);
          if (i == 1)
             j = nop -1;
          if ( (sp[j] < eq[i+1]) && (op[j] < sp[j]) )
            {
             for ( k=op[j]+1; k<sp[j]; k=k+1)
                temp[k-op[j]-1] = string[k];
             temp[sp[j]-op[j]-1] = 0;
             strcpy ( line->name[i].unit, temp);
#ifdef TRACE
             printf("line->name[%d].unit : <%s>\n", i, line->name[i].unit);
#endif
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
          strcpy ( line->name[i].text, temp);
          strcpy ( line->name[i].unit, NULLSTR);
         }
      }

quit :

#ifdef STEP
   /* printf ( "Exit from VDSsplit_line, status = %d\n", refresh->status); */
#endif

   return status; 
}


/*----------------------------------------------------------------------------*/


   /***************************************************************************/
   /*									      */
   /*   This routine convert a datatype from the ASCII file to a datatype     */
   /* coherent with PDM rules.						      */
   /*									      */
   /*									      */
   /*  Returns: TRUE/FALSE									      */
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

int VDSconvert ( char	string[]  /* datatype to translate to PDM rules */)
{
   int	i;		/* loop index					      */
   int	len = 0;	/* length of the input string			      */
   int	ob  = 0;	/* position of '['				      */
   int	cb  = 0;	/* position of ']'				      */
   int  status = TRUE;


#ifdef STEP
   printf ( "Enter in  VDSconvert\n");
#endif

   /* length of the string */
   len = strlen ( string);
   
   /* scanning for brackets */
   if ( len == NULL)
     {
      VDSprintErr ("\t\t", "VDSconvert: null string to convert\n");
      status = FALSE; 
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
         VDSprintErr ("\t", "VDSconvert: unbalanced brackets, ob=%d, cb=%d, len=%d\n",
                 				   ob,    cb,     len);
         status = FALSE; 
         goto quit;
        }
     }
quit :
 	  	  	  	  	 
#ifdef STEP
/*
   printf ( "Exit from VDSconvert, status = %d\n", refresh->status );
*/
#endif

   return status;
}


/*----------------------------------------------------------------------------*/
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
int VDSdecrypt_string ( 
   		char	*input,		/* string to analyse	(I)	*/
   		char	*key,		/* key word	 	(O)	*/
   		char	*column,	/* attribute name	(O)	*/
   		char	*format,	/* attribute datatype	(O)	*/
   		int	*p_num		/* attribute number	(O)	*/
   		)
{
   int	i;		/* loop index					      */
   int	len;		/* string length				      */
   int	three;		/* key word length				      */
   int	n = 0;		/* number of '|'				      */
   int	npipe[2];	/* position of '|' in the string		      */
   char order[VDS_BUF_MAX_WORD];/* string for attribute number 			      */
   int  status;

   /*initialization */
   key[0]    = 0;
   column[0] = 0;
   format[0] = 0;
   *p_num    = 0;

   len      = strlen(input);
   three    = strlen(DL);
   order[0] = 0;
   npipe[0] = 0;
   npipe[1] = 0;

   status = VDS_S_SUCCESS;

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
        status = VDS_S_SUCCESS;
        break;

      case 1:
        for ( i = 0; i < npipe[0]; i++)
           column[i] = input[i];
        column[npipe[0]] = 0;

        for ( i = npipe[0] + 1; i <= len; i++)
           format[i - npipe[0] - 1] = input[i];
        /*refresh->status = PDM_S_SUCCESS; */
        break;

      case 2:
        for ( i = 0; i < three; i++)
           key[i] = input[i];
        key[three] = 0;

        for ( i = three; i < npipe[0]; i++)
           order[i-three] = input[i];
        order[npipe[0]-three] = 0;
        *p_num = atoi(order);

#ifdef STEP
   printf ("order : <%s>, order = %d\n", order, *p_num);
#endif

        for ( i = npipe[0] + 1; i < npipe[1]; i++)
           column[i - npipe[0] - 1] = input[i];
        column[npipe[1] - npipe[0] - 1] = 0;

        for ( i = npipe[1] + 1; i <= len; i++)
           format[i - npipe[1] - 1] = input[i];
        status = VDS_S_SUCCESS;
        break;

      default:
        VDSprintErr ("\t", "VDSdecrypt_string : bad formated input string : <%s>\n", 
                 input);
        status = VDS_E_FAILURE;
     }

#ifdef STEP
   /* printf ( "Exit from VDSdecrypt_string, status = %d\n", refresh->status); */
#endif

   return status; 
}


/*----------------------------------------------------------------------------*/

int VDSextract_cofilename ( 
   	char		input[],	/* string to analyse  (I)     */
   	char		path[],		/* cofilepath 	      (O)     */
   	char		name[]		/* cofilename 	      (O)     */
	)
{

   int		i = 0;
   int		len = 0;
   int		last = 0;


#ifdef TRACE
   printf ("input string : <%s>\n", input);
#endif


   len = strlen ( input);
   strcpy(path,"");
   strcpy(name,input);


   for ( i=0; i<len; i++)
     {
      if ( input[i] == SLASH) last = i;
     }

   if (last != 0)
     {
      for ( i=0; i<last; i++) path[i]=input[i];
      path[i]=0;

      for ( i=(last+1); i<len; i++) name[i-last-1] = input[i];
      name[i-last-1]=0;
     }

#ifdef TRACE
      printf ("path : <%s>\tcofilename : <%s>\n", path, name);
#endif
  
      
   return ( VDS_S_SUCCESS);
}

/*----------------------------------------------------------------------------*/
/* Function: vdlogname().

  Returns : *char
	    (the login name of the user).

*/
char *VDlogname()
{
    struct passwd *VDSpasswd_ptr;

    VDSpasswd_ptr = getpwuid (getuid ());
    return (VDSpasswd_ptr->pw_name);
}

/* --------------------------------------------------------------------------
Doc :  VDBpadstr

  Desc : This function pads a string 'str'with the given char upto
         str[maxlen-2] and puts a null char at str[maxlen-1].
         If str is longer than maxlen-1, it truncates to maxlen-1.

  Return values:
  1 - always
----------------------------------------------------------------------------*/
long VDBpadstr (
 char  *str,
 int   maxlen,
 char  pc
)
{
int len, ii;


    len = strlen ( str );
    for ( ii = len; ii < maxlen-1; ii++ )
      str[ii] = pc;
    str[maxlen-1] = '\0';
    return 1;
}

/* --------------------------------------------------------------------------
Doc :  VDBdelTrailSpaces

  Desc : It deleted trailing space characters from given string.

----------------------------------------------------------------------------*/
void VDBdelTrailSpaces (
char *str
)
{
int len;


   len = strlen( str );

   while( isspace(str[len-1]) )
    len--;

   str[len] = '\0';
}

/* --------------------------------------------------------------------------
Doc :  VDBdelLeadSpaces

  Desc : It deletes leading space characters from a string.

----------------------------------------------------------------------------*/
void VDBdelLeadSpaces (
char *str
)

{
int len, ii, nonspace;

    len = strlen( str );

    nonspace = 0;

    while( isspace( str[nonspace] ) )
      nonspace++;

    for( ii=0; ii< len-nonspace; ii++)
     str[ii] = str[nonspace+ii];

    str[len-nonspace] = '\0';
}


