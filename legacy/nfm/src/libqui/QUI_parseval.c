#include "machine.h"
#include "QUI.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <memory.h>

#define NUMBER 2
#define STRING 0

/******************************************************************************

Doc: SQF_num_chars

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: SQF_parseval.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine counts the number of times a character appears
             in a string

Examples: SQF_num_chars("|","a|b|c")

Return Status: number of occurances of character, 0 if none

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header

******************************************************************************/

long SQF_num_chars(ch,st)
char ch; /* I - character to look for */
char *st;/* I - string to parse */
{
  char *ptr;
  long cnt=0;

  ptr = strchr( st, ch);
  while (ptr)
  {
    cnt++;
    ptr = strchr( ++ptr, ch);
  }
  return(cnt);
}/* SQF_num_chars */

/******************************************************************************

Doc: SQF_make_op

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: SQF_parseval.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine translates the given number into a relational 
             operator

Examples: SQF_make_op(1,oper);

Return Status: None

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header

******************************************************************************/

SQF_make_op( oper, symbol)
/* this routine returns a mathematical symbol given an integer */
long oper; /* I - number to translate */
char *symbol; /* O - mathematical operator returned */

{
  switch(oper)
  {
    case QUI_OPVAL1: strcpy(symbol, QUI_OPSTR1);break;
    case QUI_OPVAL2: strcpy(symbol, QUI_OPSTR2);break;
    case QUI_OPVAL3: strcpy(symbol, QUI_OPSTR3);break;
    case QUI_OPVAL4: strcpy(symbol, QUI_OPSTR4);break;
    case QUI_OPVAL5: strcpy(symbol, QUI_OPSTR5);break;
    case QUI_OPVAL6: strcpy(symbol, QUI_OPSTR6);break;
    case QUI_OPVAL7: strcpy(symbol, QUI_OPSTR7);break;
  }
  return;
}

/******************************************************************************

Doc: parse_star

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: SQF_parseval.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine parses and input string for asterisk,
             translating it to RIS syntax

Examples: parse_star(hld, pos_star, item_name, type, sign, valstr)

Return Status: None

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header
       10/01/91 - JWA - corrected problem with >= and <= cases

******************************************************************************/

void parse_star(hld, pos_star, item_name, type, sign, valstr)

char *hld;     /* I - the string to parse */
long pos_star; /* I - the position of the asterisk */
long type;     /* I - the type of the attribute */
long sign;     /* I - the operator for the trio */
char *item_name;/* I - the attribute name */
char *valstr;   /* O - the RIS syntax for the string */

{
    char wrk[160], front[160], back[160], flds[2][160], dummy[160];
    long pos_colon, num_star, num_colon;
    
    num_colon=SQF_num_chars(':', hld);
    num_star=SQF_num_chars('*',hld);
    
    if (num_colon>0)
      pos_colon = strchr(hld,':') - hld;
    else 
      pos_colon=0;

    if (pos_star>0)
    {
      strcpy(front, hld);
      front[pos_star]=0;
      if (pos_star<strlen(hld)-1)
        strcpy(back, &hld[pos_star+1]);
      else
        back[0]=0;
    }    
    else
    {
      back[0]=0;
      front[0]=0;
    }
    switch (sign)
    {
        case QUI_OPVAL1:  /*  =  */
              if (type != STRING)
              {
                strcpy(wrk,hld);
                wrk[pos_star]=0;
                if (atoi(wrk))           
                  sprintf(valstr, 
"((%s = %d) OR ( %s >= %d0 AND %s < %d0 ) OR ( %s >= %d00 AND %s < %d00 ) OR ( %s >= %d000 AND %s < %d000 ))", 
                          item_name, atoi(wrk),
                          item_name, atoi(wrk),item_name,atoi(wrk)+1, 
                          item_name, atoi(wrk),item_name,atoi(wrk)+1, 
                          item_name, atoi(wrk),item_name,atoi(wrk)+1);
                else
                  sprintf(valstr, "%s >= 0", item_name);
              }
              else
              {
                strcpy(wrk, hld);
                while (num_star!=0)
                {
                  pos_star = strchr(wrk,'*') - wrk;
                  strcpy(front, wrk);
                  front[pos_star]=0;
                  if (pos_star<strlen(wrk)-1)
                    strcpy(back, &wrk[pos_star+1]);
                  else
                    back[0]=0;
                  sprintf(wrk, "%s%c%s", front, '%', back);
                  num_star=SQF_num_chars('*',wrk);
                }
                sprintf(valstr, "%s LIKE '%s'", item_name, wrk);
              }/* if string */
              break;

        case QUI_OPVAL2:  /*  !=  */
              if (type != STRING)
              {
                strcpy(wrk,hld);
                wrk[pos_star]=0;
                if (atoi(wrk))           
                  sprintf(valstr, 
"((%s = %d) OR ( %s >= %d0 AND %s < %d0 ) OR ( %s >= %d00 AND %s < %d00 ) OR ( %s >= %d000 AND %s < %d000 ))", 
                          item_name, atoi(wrk),
                          item_name, atoi(wrk),item_name,atoi(wrk)+1, 
                          item_name, atoi(wrk),item_name,atoi(wrk)+1, 
                          item_name, atoi(wrk),item_name,atoi(wrk)+1);
                else
                  sprintf(valstr, "%s >= 0", item_name);
              }
              else
              {
                strcpy(wrk, hld);
                while (num_star!=0)
                {
                  pos_star = strchr(wrk,'*') - wrk;
                  strcpy(front, wrk);
                  front[pos_star]=0;
                  if (pos_star<strlen(wrk)-1)
                    strcpy(back, &wrk[pos_star+1]);
                  else
                    back[0]=0;
                  sprintf(wrk, "%s%c%s", front, '%', back);
                  num_star=SQF_num_chars('*',wrk);
                }
                sprintf(valstr, "%s NOT LIKE '%s'", item_name, wrk);
              }/* if string */
              break;

/*  Commented out 2/22/93 - Glenn Scott

              if (type != STRING)
                sprintf(valstr, "%s %s %d", item_name, QUI_OPSTR2, atoi(wrk));
              else
              {
                sprintf(valstr, "( %s < '%s%s' OR %s > '%s~%s' )", 
                        item_name, front, back, item_name, front, back);
              }
              break;
*/
        case QUI_OPVAL3:  /*  <  */
              if (type != STRING)
                sprintf(valstr, "%s %s %d", item_name, QUI_OPSTR3, atoi(wrk));
              else
              {
                sprintf(valstr, "%s %s '%s'", item_name, QUI_OPSTR3, front);
              }/* if string */
              break;

        case QUI_OPVAL4:  /*  >  */
              if (type != STRING)
                sprintf(valstr, "%s %s %d", item_name, QUI_OPSTR4, atoi(front));
              else
              {
                strcpy(wrk, hld);
                wrk[pos_star]=0;
                sprintf(valstr, "%s %s '%s'",item_name, QUI_OPSTR4, front);
              }/* if string */
              break;

        case QUI_OPVAL5:  /*  <=  */
              if (type != STRING)
                sprintf(valstr, "%s %s %d", item_name, QUI_OPSTR5, atoi(front));
              else
              {
                if (front[0])
                  sprintf(valstr, 
                          "%s < '%s~%s' or %s LIKE '%s%c%s'",
                          item_name, front, back, item_name, front, '%', back);
                else
                  sprintf(valstr, "%s LIKE '%c%s'",item_name,'%',back);
              }/* if string */
              break;

        case QUI_OPVAL6:  /*  >=  */
              if (type != STRING)
                sprintf(valstr, "%s %s %d", item_name, QUI_OPSTR6, front);
              else
              {
                if (front[0])
                  sprintf(valstr, 
                          "%s > '%s~%s' or %s LIKE '%s%c%s'",
                         item_name, front, back, item_name, front, '%', back);
                else
                  sprintf(valstr, "%s LIKE '%c%s'",item_name,'%',back);
              }/* if string */
              break;

        case QUI_OPVAL7:  /*  ><  */
              strcpy(flds[0], hld);
              flds[0][pos_colon]=0;
              if (pos_colon<strlen(hld)-1)
                strcpy(wrk, &hld[pos_colon+1]);
              else
                wrk[0]=0;
              strcpy(flds[1],wrk);
              if (type != STRING)
              {
                num_star=SQF_num_chars('*',flds[0]);
                if (num_star>0)
                  pos_star = strchr(flds[0],'*') - flds[0];
                else 
                  pos_star=0;
                if (pos_star==0)
                  strcpy(wrk, "0");
                else
                {
                  strcpy(wrk,flds[0]);
                  wrk[pos_star]=0;
                }
                sprintf(valstr, "%s between %d and ", 
                        item_name, atoi(wrk));
                num_star=SQF_num_chars('*',flds[1]);
                if (num_star>0)
                  pos_star = strchr(flds[1],'*') - flds[1];
                else 
                  pos_star=0;
                if (pos_star==0)
                  strcpy(wrk, "0");
                else
                {
                  strcpy(wrk,flds[1]);
                  wrk[pos_star]=0;
                }
                sprintf(wrk,"%d",atoi(wrk));
                strcat(valstr, wrk);
              }
              else
              {
                num_star=SQF_num_chars('*',flds[0]);
                if (num_star>0)
                  pos_star = strchr(flds[0],'*') - flds[0];
                else 
                  pos_star=0;
                if (pos_star>0)
                {
                  strcpy(front, flds[0]);
                  front[pos_star]=0;
                  if (pos_star<strlen(flds[0])-1)
                    strcpy(back, &flds[0][pos_star+1]);
                  else
                    back[0]=0;
                }    
                else
                {
                  back[0]=0;
                  front[0]=0;
                }
                strcpy(wrk, flds[0]);
                if (num_star>0)
                  wrk[pos_star]=0;
                sprintf(valstr, "( %s >= '%s%s' AND %s <= ", 
                        item_name, wrk, back, item_name);
                num_star=SQF_num_chars('*',flds[1]);
                if (num_star>0)
                  pos_star = strchr(flds[1],'*') - flds[1];
                else 
                  pos_star=0;
                if (pos_star>0)
                {
                  strcpy(front, flds[1]);
                  front[pos_star]=0;
                  if (pos_star<strlen(flds[1])-1)
                    strcpy(back, &flds[1][pos_star+1]);
                  else
                    back[0]=0;
                }    
                else
                {
                  back[0]=0;
                  front[0]=0;
                }
                strcpy(wrk, flds[1]);
                if (num_star>0)
                  wrk[pos_star]=0;
                sprintf(dummy, "'%s~%s' )", wrk, back);
                strcat(valstr, dummy);
              }/* if string */
              break;
    }
}

/******************************************************************************

Doc: parse_qmark

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: SQF_parseval.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine parses the input string, translating the
             questiong marks to valid RIS syntax

Examples: parse_qmark(hld, pos_qmark, item_name, type, sign, valstr)

Return Status: None

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header

******************************************************************************/

void parse_qmark(hld, pos_qmark, item_name, type, sign, valstr)

char *hld;     /* I - the string to parse */
long pos_qmark; /* I - the position of the question mark */
long type;     /* I - the type of the attribute */
long sign;     /* I - the operator for the trio */
char *item_name;/* I - the attribute name */
char *valstr;   /* O - the RIS syntax for the string */

{
    char wrk[160],front[160],back[160],flds[2][160],dummy[160];
    long pos_colon, num_qmark, num_colon;
    
    num_colon=SQF_num_chars(':',hld);
    if (num_colon>0)
      pos_colon = strchr(hld,':') - hld;
    else 
      pos_colon=0;

    num_qmark=SQF_num_chars('?',hld);

    if (pos_qmark>0)
    {
      strcpy(front, hld);
      front[pos_qmark]=0;
      if (strlen(hld)-1 > pos_qmark)
        strcpy(back, &hld[pos_qmark+1]);
      else
        back[0] = 0;
    }    
    else
    {
      back[0]=0;
      front[0]=0;
    }
    switch (sign)
    {
      case 1:
              if (type != STRING)
              {
                strcpy(wrk, hld);
                wrk[pos_qmark]=0;
                if (!atoi(back))
                  sprintf(valstr, "( (%s = %d) OR ( %s >= %d0 AND %s < %d0 )", 
           item_name, atoi(wrk),item_name, atoi(wrk),item_name,atoi(wrk)+1);
                else
                  sprintf(valstr, "( %s >= %d0%d AND %s <= %d9%d )", 
               item_name, atoi(wrk),atoi(back),item_name,atoi(wrk),atoi(back));
              }
              else
              {
                strcpy(wrk, hld);
                while (num_qmark!=0)
                {
                  pos_qmark = strchr(wrk,'?') - wrk;
                  strcpy(front, wrk);
                  front[pos_qmark]=0;
                  if (pos_qmark<strlen(wrk)-1)
                    strcpy(back, &wrk[pos_qmark+1]);
                  else
                    back[0]=0;
                  sprintf(wrk, "%s%c%s", front, '_', back);
                  num_qmark=SQF_num_chars('?',wrk);
                }
                sprintf(valstr, "%s LIKE '%s'", 
                        item_name, wrk);
              }/* if string */
              break;
	case 2:
              strcpy(wrk, hld);
              wrk[pos_qmark]=0;
              if (type != STRING)
                if (!atoi(back))
                  sprintf(valstr, "%s < %d0", item_name, atoi(wrk));
                else
                  sprintf(valstr,"%s < %d0%d",item_name,atoi(wrk),atoi(back));
              else
              {
                sprintf(valstr, "%s < '%s'", item_name, wrk);
              }/* if string */
              break;
	case 3:
              strcpy(wrk, hld);
              wrk[pos_qmark]=0;
              if (type != STRING)
                if (!atoi(back))
                  sprintf(valstr, "%s >= %d0",item_name,atoi(wrk)+1);
                else
                  sprintf(valstr,"%s >= %d9%d",item_name,atoi(wrk),atoi(back));
              else
              {
                sprintf(valstr, "%s > '%s~%s'",item_name, wrk, back);
              }/* if string */
              break;
	case 4:
              strcpy(wrk, hld);
              wrk[pos_qmark]=0;
              if (type != STRING)
                if (!atoi(back))
                  sprintf(valstr, "%s < %d0", item_name, atoi(wrk)+1);
                else
                  sprintf(valstr,"%s <= %d9%d",item_name,atoi(wrk),atoi(back));
              else
              {
                sprintf(valstr, "( %s < '%s' OR %s LIKE %s_%s )",
                        item_name, wrk, item_name, wrk, back);
              }/* if string */
              break;
	case 5:
              strcpy(wrk, hld);
              wrk[pos_qmark]=0;
              if (type != STRING)
                if (!atoi(back))
                  sprintf(valstr, "%s >= %d0", item_name, atoi(wrk));
                else
                  sprintf(valstr,"%s >= %d0%d",item_name,atoi(wrk),atoi(back));
              else
              {
                sprintf(valstr, "( %s LIKE %s_%s OR %s > '%s~%s' )",
                        item_name, wrk, back, item_name, wrk, back);
              }/* if string */
              break;
	case 6:
              strcpy(wrk, hld);
              wrk[pos_qmark]=0;
              if (type != STRING)
                if (!atoi(back))
                  sprintf(valstr, "( %s < %d0 OR %s > %d0 )", 
                          item_name, atoi(wrk), item_name, atoi(wrk)+1);
                else
                  sprintf(valstr, "( %s < %d0%d OR %s > %d9%d )",
               item_name,atoi(wrk),atoi(back),item_name,atoi(wrk),atoi(back));
              else
              {
                sprintf(valstr, "%s not LIKE '%s_%s'", 
                        item_name, wrk, back);
              }/* if string */
              break;
	case 7:
              strcpy(flds[0], hld);
              flds[0][pos_colon]=0;
              strcpy(wrk, &hld[pos_colon+1]);
              strcpy(flds[1],wrk);
              num_qmark = SQF_num_chars('?', flds[0]);
              if (num_qmark>0)
                pos_qmark = strchr(flds[0],'?') - flds[0];
              else
                pos_qmark = 0;
              if (pos_qmark>0)
              {
                strcpy(front, flds[0]);
                front[pos_qmark]=0;
                if (pos_qmark<strlen(flds[0])-1)
                  strcpy(back, &flds[0][pos_qmark+1]);
                else
                  back[0]=0;
              }    
              else
              {
                back[0]=0;
                front[0]=0;
              }
              strcpy(wrk, flds[0]);
              wrk[pos_qmark]=0;
              if (type != STRING)
                if (!atoi(back))
                  sprintf(valstr, "( %s >= %d0 AND %s <= ", 
                          item_name, atoi(wrk), item_name);
                else
                  sprintf(valstr, "( %s >= %d0%d AND %s <= ", 
                          item_name,atoi(wrk),atoi(back),item_name);
              else
              {
                sprintf(valstr, 
                "(( %s LIKE '%s_%s' OR %s > '%s~' ) AND ( %s LIKE ", 
	                item_name, wrk, back, item_name, wrk, item_name);
                num_qmark = SQF_num_chars('?',flds[1]);
                if (num_qmark>0)
                  pos_qmark = strchr(flds[1],'?') - flds[1];
                else
                  pos_qmark = 0;
                if (pos_qmark>0)
                {
                  strcpy(front, flds[1]);
                  front[pos_qmark]=0;
                  if (pos_qmark<strlen(flds[1])-1)
                    strcpy(back, &flds[1][pos_qmark+1]);
                  else
                    back[0]=0;
                }    
                else
                {
                  back[0]=0;
                  front[0]=0;
                }
                strcpy(wrk, flds[1]);
                if (num_qmark>0)
                  wrk[pos_qmark]=0;
                if (type != STRING)
                  if (!atoi(back))
                    sprintf(dummy, "%d0 )", atoi(wrk)+1);
                  else
                    sprintf(dummy, "%d9%d )", atoi(wrk), atoi(back));
                else
                {
                  sprintf(dummy, 
                          "'%s_%s' OR %s < '%s!' )", 
                          wrk, back, item_name, wrk);
                }
                strcat(valstr, dummy);
              }/* if string */
              break;
    }
}

/******************************************************************************

Doc: parse_colon

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: SQF_parseval.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine parses the input string for colons and
             translates to a valid RIS syntax

Examples: parse_colon(hld, num_colon, item_name, type, sign, valstr)

Return Status: None

History: 6/7/90 - JWA - original code
         9/4/91 - JWA - added header

******************************************************************************/

void parse_colon(hld, num_colon, item_name, type, sign, valstr)

char *hld;     /* I - the string to parse */
long num_colon; /* I - the number of colons in the string */
long type;     /* I - the type of the attribute */
long sign;     /* I - the operator for the trio */
char *item_name;/* I - the attribute name */
char *valstr;   /* O - the RIS syntax for the string */

{
    char wrk[160], flds[2][160], tmps[2][160];

    sign=sign;
    strcpy(flds[0],hld);
    flds[0][num_colon]=0;
    if (flds[0][num_colon-1]==' ') flds[0][num_colon-1]=0;
    if (num_colon<strlen(hld)-1)
    {
      if (hld[num_colon+1]==' ')
        strcpy(wrk,&hld[num_colon+2]);
      else
        strcpy(wrk,&hld[num_colon+1]);
    }
    else
      wrk[0]=0;
    strcpy(flds[1],wrk);
    if (type != STRING)
    {
      sprintf(wrk,"(%s between %s and %s)",item_name,flds[0],
        flds[1]);
      strcpy(valstr,wrk);
    }
    else
    {
      if (flds[0][0]==' ') strcpy(tmps[0],&flds[0][1]);
      else strcpy(tmps[0],flds[0]);
      if (tmps[0][strlen(tmps[0])-1]==' ') tmps[0][strlen(tmps[0])-1]=0;
      if (flds[1][0]==' ') strcpy(tmps[1],&flds[1][1]);
      else strcpy(tmps[1],flds[1]);
      if (tmps[1][strlen(tmps[1])-1]==' ') tmps[1][strlen(tmps[1])-1]=0;
      sprintf(wrk,"(%s between '%s' and '%s')",item_name,tmps[0],tmps[1]);
      strcpy(valstr,wrk);
    }/* if number*/
}

/******************************************************************************

Doc: SQF_parseval

	Copyright (c) 1991
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source: SQF_parseval.c

Author: James Albersheim

Date: Sept. 4, 1991

SDM Number: 

Description: This routine parses the input string, translating it
             to valid RIS syntax.

Examples: SQF_parseval(item_name,type,sign,invalue,outvalue)

Return Status: None

History: 6/7/90 - JWA - original code
        7/22/91 - EAW - fixed is between case for dates
         9/4/91 - JWA - added header
       10/04/91 - JWA - added comment to indicate non-portable code
        3/19/92 - Glenn Scott - removed last EAW changes for I/NFM

******************************************************************************/

void QUI_parseval(item_name,type,sign,invalue,outvalue)
char  *item_name; /* I - name of the attribute */
long  type;       /* I - type of the attribute */
long  sign;       /* I - operator for the trio */
char  *invalue;   /* I - input string          */
char  *outvalue;  /* O - resulting RIS string  */
{

  long i,num_or,num_colon,num_star,num_qmark,j,len;
  long pos_star, pos_qmark, pos_colon, pos_or;
  char wrk[160],signstr[20],valstr[320],flds[20][160],hld[160];
  char dumstr[320], default_time[20];
  void QUI_tic_to_tics();

  static  char  *fname = "QUI_parseval";

  _NFIdebug ((fname, "item_name = <%s>\n", item_name));
  _NFIdebug ((fname, "invalue = <%s>\n", invalue));
  _NFIdebug ((fname, "type = <%d>\n", type));
  _NFIdebug ((fname, "sign = <%d>\n", sign));

  for (i=1; i<20; i++)
    strcpy(flds[i],"");

/* restrict value to less than 160 characters, truncate before last "or"
   before 160 */  

  len = strlen(invalue);
  if (len>160) 
  {
    invalue[159]=0;
    num_or = SQF_num_chars('|',invalue);
    if (num_or>0)
      pos_or = strrchr(invalue,'|') - invalue;
    else
      pos_or = 160;
    if (pos_or > 79)
      invalue[pos_or-1]=0;
    else
      invalue[159]=0;
  }

  pos_or=0;
  num_or=0; 
  num_colon=0; 
  num_star=0; 

  strcpy(hld,invalue);

  if( type == STRING )
  {
     /*  If the input character string value is in tic marks -- get
      *	 rid of them because they will be put in tics again at the 
      *  end of this routine.
      */
     if( (hld[0] == '\'') && (hld[len-1] == '\'') )
     {
	for( i=0; i<(len-2); ++i )
	    wrk[i] = hld[i+1];
	wrk[len-2] = '\0';
	strcpy( hld, wrk );
     }
     /*  Check to see if the value has tic marks in it */
     _NFIdebug(( fname, "Before tic check <%s>\n", hld ));
     QUI_tic_to_tics( hld, wrk );
     _NFIdebug(( fname, "After tic check <%s>\n", wrk ));
     strcpy( hld, wrk );
  }

  SQF_make_op(sign, signstr);

  /*  Added - Glenn Scott 3/19/92  */

  if (type == QUI_TIMESTAMP_TYPE)
      strcat (signstr, " TIMESTAMP");

  /* build or string */

  num_or   =SQF_num_chars('|',hld);
  if (num_or>0)
    pos_or = strchr(hld,'|') - hld;
  else 
    pos_or=0;

  /*  Added check for TIMESTAMP - Glenn Scott 3/19/92  */

  if (type != QUI_TIMESTAMP_TYPE)
      num_colon=SQF_num_chars(':',hld);
  if (num_colon>0)
    pos_colon = strchr(hld,':') - hld;
  else 
    pos_colon=0;

  num_star =SQF_num_chars('*',hld);
  if (num_star>0)
    pos_star = strchr(hld,'*') - hld;
  else 
    pos_star=0;

  num_qmark=SQF_num_chars('?',hld);
  if (num_qmark>0)
    pos_qmark = strchr(hld,'?') - hld;
  else 
    pos_qmark=0;

  if (num_or !=0)
  {
    for (j=1; j<=num_or+1; j++)
    {
      if (j>num_or)
        i=0;
      else
        i = strchr(hld,'|') - hld;
      if (i==0)
      {
        if (hld[0]==' ')
          strcpy(flds[j],&hld[1]);
        else
          strcpy(flds[j],hld);
      }
      else
      {
        strcpy(flds[j],hld);
        flds[j][i]=0;
        if (flds[j][i-1]==' ') flds[j][i-1]=0;
        if (hld[i+1]==' ') 
          strcpy(wrk,&hld[i+2]);
        else
          strcpy(wrk,&hld[i+1]);
        strcpy(hld,wrk);
      }
    }
    if (type != STRING)
    {
      strcpy(valstr,"(");
      for (j=1; j<=num_or+1; j++)
      {
        /*  Added check for TIMESTAMP - Glenn Scott 3/19/92  */

        if (type != QUI_TIMESTAMP_TYPE)
            num_colon = SQF_num_chars(':',flds[j]);
        if (num_colon>0)
          pos_colon = strchr(flds[j],':') - flds[j];
        else 
          pos_colon=0;

        num_star = SQF_num_chars('*',flds[j]);
        if (num_star>0)
          pos_star = strchr(flds[j],'*') - flds[j];
        else 
          pos_star=0;

        num_qmark = SQF_num_chars('?',flds[j]);
        if (num_qmark>0)
          pos_qmark = strchr(flds[j],'?') - flds[j];
        else 
          pos_qmark=0;

        if (num_star!=0)
          parse_star(flds[j], pos_star, item_name, type, sign, dumstr);
        else
          if (num_qmark!=0)
            parse_qmark(flds[j], pos_qmark, item_name, type, sign, dumstr);
          else if (num_colon!=0)
                 parse_colon(flds[j],pos_colon,item_name,type,sign,dumstr);
               else
                 sprintf(dumstr, "%s = %s", item_name, flds[j]);
        strcat(valstr,dumstr);
        if (j!=num_or+1)
          strcat(valstr, " or ");
        else
          strcat(valstr, ")");
        dumstr[0]=0;
      }
    }
    else
    {
      _NFIdebug(( fname, "type is STRING **\n" ));

      strcpy(valstr,"(");
      for (j=1; j<=num_or+1; j++)
      {
        /*  Added check for TIMESTAMP - Glenn Scott 3/19/92  */

        if (type != QUI_TIMESTAMP_TYPE)
            num_colon=SQF_num_chars(':',flds[j]);
        if (num_colon>0)
          pos_colon = strchr(flds[j],':') - flds[j];
        else 
          pos_colon=0;

        num_star =SQF_num_chars('*',flds[j]);
        if (num_star>0)
          pos_star = strchr(flds[j],'*') - flds[j];
        else 
          pos_star=0;

        num_qmark=SQF_num_chars('?',flds[j]);
        if (num_qmark>0)
          pos_qmark = strchr(flds[j],'?') - flds[j];
        else 
          pos_qmark=0;

        if (num_star!=0)
          parse_star(flds[j], pos_star, item_name, type, sign, dumstr);
        else
          if (num_qmark!=0)
            parse_qmark(flds[j], pos_qmark, item_name, type, sign, dumstr);
          else if (num_colon!=0)
                 parse_colon(flds[j],pos_colon,item_name,type,sign,dumstr);
               else
		 {
                 sprintf(dumstr, "%s = '%s'", item_name, flds[j]);
		 }
        strcat(valstr,dumstr);
        if (j!=num_or+1)
          strcat(valstr, " or ");
        else
          strcat(valstr, ")");
        dumstr[0]=0;
      }
    }/* num_or*/
  }/* if or */

  else if (num_star != 0)
  {
    parse_star(hld, pos_star, item_name, type, sign, valstr);
  }/* if star */
  else if (num_qmark != 0)
  {
    parse_qmark(hld, pos_qmark, item_name, type, sign, valstr);
  }/* if question mark */
  else if (num_colon !=0)
  {
    parse_colon(hld, pos_colon, item_name, type, sign, valstr);
  }/* if colon */
  else
  {
    strcpy (default_time, "");
    if (type == QUI_TIMESTAMP_TYPE)
      {
        if ((strstr (hld, ":")) == NULL)
            strcpy (default_time, ":00:00:00");
      }

    /*  Added check for TIMESTAMP - Glenn Scott 3/19/92  */

    if ((type != STRING) && (type != QUI_TIMESTAMP_TYPE))
      sprintf(valstr,"%s %s %s%s",item_name,signstr,hld, default_time);
    else
    {
        sprintf(valstr,"%s %s '%s%s'",item_name,signstr,hld, default_time);
    }
  }
  sprintf(outvalue, "(%s)", valstr);
}/* parse */

void QUI_tic_to_tics( in, out )
    char *in;
    char *out;
{
    while( *in )
    {
        if( *in == '\'' )
        {
            *out = '\'';
            ++out;
        }
        *out++ = *in++;
    }
    *out = '\0';
}
