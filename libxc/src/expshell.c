/*  this function try to expand shell variables */
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <errno.h>
#include <string.h>
#include "error.h"
#ifdef MAIN
extern int errno;
main()
{
  char buf[256];
  char out_buf[512];
  int  status;
  int size; 
  char *tmp;
 while(1)
 {
     printf("Enter string with shell variables\n>:");
     tmp = gets(buf);

     if( status == EOF ) break;
      size = sizeof(buf);       
/*      status = expand_shell( buf, &size ,0);
      printf("after expand status=<%d>  buf=<%s> size=<%d> \n\n\n",status,buf,size);
  */    status = expand_shell( buf, &size ,1);
      printf("after expand status=<%d>  buf=<%s> size=<%d> \n\n\n",status,buf,size);
 }
}
#endif

#define  SYNTAX_ERR   0
#define  Q_ERR        1
#define  Q1_ERR       2
#define  SIZE_ERR     3


static char err_prifix[]="expand_shell: ";

static char *exp_sh_msg[] = {
/* SYNTAX_ERR */           "syntax error <%s>\n",
/* Q_ERR      */	   "<%s>: %s\n",
/* Q1_ERR     */	   "<%s>: parameter null or not set\n",
/* SIZE_ERR   */	   "buffer size not large enough, need <%d>\n"
	   		    };
ERRDESCR exp_sh_errdescr = { 
             { ERR_DFLT, ERR_DFLT, ERR_DFLT, ERR_DFLT },          /* handler */
             { err_prifix, err_prifix, err_prifix, err_prifix },  /* prefixes */
             exp_sh_msg                                           /* msg table*/
	     		   };

int expand_shell( buf, siz, flag )
/***********************************************************************
                                                                        
    This function will expand shell variables in the buffer buf.        
    
    The shell variable can be specified as :                      

        1. $PARAMETER                                             
        2. ${PARAMETER}                                           
        3. ${PARAMETER:-word}                                     
        4. ${PARAMETER:=word}                                     
        5. ${PARAMETER:?word}                                     
        6. ${PARAMETER:+word}

    Note: ( The : is optional.)
                                                                        

    buf  -- pointer to the input buffer                                  
    siz  -- pointer to int which contain the size of the buffer allocated
    flag -- for case 1 and 2 only                                       
         0  if the shell variable is not defined, substitute      
            the variable with NULL.                                 
                                                                        
                 ex:   "$NOT_DEF/xx"  becomes    "/xx"                  
                                                                         
         1  if the shell variable is not defined, leave the original
            string intact.
                                                                        
                 ex:   "$NOT_DEF/xx"  becomes    "$NOT_DEF/xx"          
                                                                          


DIAGNOSTICS

    return 0  for success and siz will contain the length of the       
              expanded string in the buffer.                            
           -1 for syntax error.
           -2 for size error.    
              The size of buf is too small for the expanded string.
              siz will contain the length needed for the expanded string.
           -3 for case 5 only. if parameter is not defined then print     
              word and return -3. if word is omitted then a standard message
	      is printed.
                                                                       


SEE ALSO

     sh(1) ksh(1)


WARNINGS

     In the above, word is not expanded unless it is to be used as the 
     substituted string. if word contain shell command, it will not be
     handled.  ex: ${d:-`pwd`}  pwd will not be changed to the current
     directory.
**********************************************************************/

char *buf;
int *siz;
int flag; 
{
  register char *in,*out; /* pointer to input/output buffer */
  register int i;
  register int out_siz;   /* size of the expanded string    */
  register char *parameter;
  register char *tt,*vv;
  register char *dollar;  /* pointer to dollar sign */
  register char *brace1;  /* pointer to {           */
  register char *brace2;  /* pointer to }           */
  register char *var;
  register int p_flag,    /* + */
	       m_flag,    /* - */
	       e_flag,    /* = */
	       q_flag;    /* ? */

  int len;
  int buf_siz;            /* size of input buf             */
  int buf_len;            /* length of string in buf       */
  char out_buf[512];      
  char var_name[256];     /* contain shell var name        */
  char substitu[512];
  char *end,*string;

  buf_siz = *siz;
  *siz = 0;
  out_siz = 0;
  in = buf;
  out = out_buf;
  out_buf[0] = '\0';
  buf_len = strlen(in);
  end = buf + buf_len;
  
     if( !(dollar = strchr(in,'$')) )
     {
        *siz = buf_len;
        return(0);
     }

     while (  dollar != NULL && in < end  )
     {
         brace1=brace2=parameter=NULL;
         p_flag = m_flag = e_flag = q_flag = 0;
         var_name[0] = '\0';
	 substitu[0] = '\0';
         while( in < dollar )
	 {
	   *out++ = *in++;
	   out_siz++;
	 }
         *out='\0';

	 if ( (dollar > in ) && ( *(dollar - 1) == '\\' ) )
	 {
            *out++ = *in++; /* $ sign */
            *out='\0';
            out_siz++;
	    dollar = strchr(in,'$');
	 }
	 else  /* process shell var */
	 {
            if ( *(parameter = dollar+1) == '{' )
	    {
	       brace1 = parameter;
	       parameter++;
	       brace2=strchr( parameter,'}');
               if (brace2 == NULL )
	       {
                  *siz = buf_len;
	          report_error(&exp_sh_errdescr,SYNTAX_ERR, ERR_ERROR,0,buf);
		  return(-1);  /* syntax error */
	       }
	       else
	       {
	          in = brace2 + 1;
	       }
	    }

            /* get the var */		                 
            i=0;
	    while( isalnum(*parameter)  || (*parameter) == '_' )
	    {
               var_name[i++] = *parameter++;		    
            }
	    var_name[i] = '\0';
            if( !brace2 ) in = parameter;
            if(brace1)
	    {
               if (*parameter == ':')
               {
                  tt=parameter+1;
               }
	       else
	       {
	          tt=parameter;
	       }
               /* get flag */
	       if      ( *tt == '+' )    p_flag++;
	       else if ( *tt == '-' )    m_flag++;
	       else if ( *tt == '=' )    e_flag++;
	       else if ( *tt == '?' )    q_flag++;
               else if ( *tt == '}' )    ;
	       else   
	       {
                  *siz = buf_len;
  	          report_error(&exp_sh_errdescr,SYNTAX_ERR, ERR_ERROR,0,buf);
		  return(-1); /* syntax error */
	       }
               tt++;
               /* get word */
               for(  i= 0; tt < brace2 ;i++ )
               {
                  substitu[i] = *tt++;
	       }
               substitu[i]= '\0';
            }
            var = getenv(var_name);
	    if( var )  /* var defined */
	    {
               if (p_flag)
	       {
                 /* cp substitu var */
                   vv=substitu;
                   len = sizeof(substitu);
                   expand_shell( substitu, &len, 0 );
	       }
	       else
	       {
                 /* cp shell var */
                   len = strlen(var);
		   vv=var;
	       }
               for( i=0 ; i < len; i++)
               {
                  *out++ = *vv++;
		  out_siz++;
	       }
               *out='\0';
            }
	    else  /* shell var not defined */
	    {
               if (m_flag | e_flag)
	       {
                 /* cp substitu var */
                   vv=substitu;
                   len = sizeof(substitu);
                   expand_shell( substitu, &len, 0); 
                   for( i=0 ; i < len; i++)
                   {
                      *out++ = *vv++;
	              out_siz++;
	           }
                   *out='\0';
	       }
	       if( e_flag )
	       {
                  string = malloc( strlen(var_name) + strlen(substitu) + 10 );
		  if( string != NULL )
		  {
                     strcpy(string,var_name);
		     strcat(string,"=");
		     strcat(string,substitu);
		     putenv(string);
		  }
	       }
	       if( q_flag )
	       {
	          if ( substitu[0] != '\0')
		  {
		    /* printf("<%s>\n",substitu); */
		     report_error(&exp_sh_errdescr,Q_ERR, ERR_ERROR,0,var_name,substitu);
		  }
		  else
		  {
		     /* printf("<%s>: parameter null or not set\n",var_name);*/
		     report_error(&exp_sh_errdescr,Q1_ERR, ERR_ERROR,0, var_name);
		  }
                  *siz = buf_len;
                  return(-3);
	       }
	       if( flag && !m_flag && !e_flag && !p_flag && !q_flag )
	       {
                   *out++ = '$';
		   out_siz++;
                   if(brace1)
		   {
                     *out++ = '{';
                     out_siz++;
		   }
                 /* cp shell var name */
                   vv=var_name;
		   len = strlen(var_name);
                   for( i=0 ; i < len; i++)
                   {
                      *out++ = *vv++;
	              out_siz++;
	           }
                   if(brace1)
		   {
                     *out++ = '}';
                     out_siz++;
		   }
                   *out='\0';
	       }      
	    }
         }
         dollar = strchr( in, '$' );
     }    
     while ( in < end )
     {
       *out++ = *in++;
       out_siz++;
     }
     *out='\0';
     if( out_siz > buf_siz )
     {
        *siz = out_siz;
        report_error(&exp_sh_errdescr,SIZE_ERR, ERR_ERROR,0,out_siz);
        return(-2); /* size error */
     }
     strcpy(buf,out_buf);

  *siz = out_siz;
  return(0);
}
	 
	 
         
