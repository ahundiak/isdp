/*
$Log: UTstring.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:39  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:53  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:54  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:51:49  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:10  root
 * COMMENT : Corresponds to Rel201.4 in 2.0.1 RCS
 *
 * Revision 201.4  1992/08/07  15:41:01  grnuc20
 * COMMENT : ANSI C conversion fixes
 *
 * Revision 201.3  1992/07/13  20:42:19  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include <math.h>
#include <ctype.h>
#include <string.h>
#include <itools.h>
#include "FSBmap.h"
#include "FFdef.h"
#include "FFmacros.h"
#include "FFstructs.h"
#include "FFerrdef.h"



/***************************************************************************/
/*          INDEX OF STRING ROUTINES AND CHARACTER OPERATIONS              */
/***************************************************************************/
/*
    chr                 fgetstab            getbufint
    isndelim            isnumstr            isoperator 
    islower_alpha       tolower_alpha       isupper_alpha
    toupper_alpha       isnumeric           isalphanumeric
    isstrstr            ord                 skipchar
    skiptochar          straddesc           strccat
    strccnt             strccpy             strCdel
    strcdup             strcindex           strcleft
    strcleftright       strcright           strcsqz
    strcsub             strcsubindex        strexist
    strileft            striright           strisub
    strlshft            strnleft            strnright
    strrcpy             strssub             strwidth
    strwsub             strzero             strfind
    move_bytes          move_ubytes         UT_find_GGlist
    UT_find_path
*/

/***************************************************************************/
/*                       MISCELLANEOUS STRING ROUTINES                     */
/***************************************************************************/

char chr(x) int x; { return ( ((char)(x)) ); }     /* char of ordinal */



char *fgetstab( buf,maxbuf,tabchar,in )

	char buf[];
	int maxbuf,tabchar;
	FILE *in;
{

   /* 'tabchar' is some arbitrary char that delineates columns */
   /* EOF are automatically stripped from buffer, but NOT linefeeds  */
   int ch,i=0;

   while ( ((ch = getc(in)) != tabchar) && 
	    (ch != '\n') && (ch != EOF) && 
	    (i < (maxbuf-1)) )
   { buf[i++] = ch; }
   if (ch == '\n')  buf[i++] = ch;
   buf[i] = 0;   /* make into a string */
   return (buf);
} /*fgetstab*/


int isndelim(c)
int c;
{
  /* allowed delimiters for numbers */
  return ((c=='+') || (c=='-') || (c=='.'));
}


int isnumstr (str)
char str[];
{
  /* test str for non-numerics: return 0 if not convertable to a number */
  int ch=0, slen=strlen(str), sndx=0, retval=1;
  double fval;

  if (str[0]) /* if string not null */
  {
    for (sndx=0; sndx<slen; sndx++) 
    {
      ch = str[sndx];
      if ( (!isdigit(ch)) && (!isndelim(ch)) ) retval = 0;
    }
    if (retval) retval = sscanf(str,"%f",&fval);
    retval = (retval <= 0) ? 0 : 1;
  }
  else retval = 0;  /* null string */
  return (retval);
} /*isnumstr*/


int isoperator(c)
int c;
{
  /* return 1 if c = operator, else return 0 */
  if (isalnum(c)) return(0);
  switch(c)
  {
    case '{': case '}': case '|': case '^': case '?': case '<':
    case '>': case '=': case '+': case '-': case '*': case '/':
    case '&': case '%': case '$': case '#': case '!': return(1);
    default : return(0);
  }
}/*isoperator*/




islower_alpha(  Chara )

char Chara;
{

   if ( !((Chara < 97) || (Chara > 122)) )
       return( 1 );
     else
       return( 0 );
}




tolower_alpha( Chara )
	char *Chara;
{

   if ( !((*Chara < 97) || (*Chara > 122)) )
       return( 1 );
     else if ( !((*Chara < 65) || (*Chara > 90)) ) {
       (*Chara) += 32;
       return( 1 );
       }
     else
       return( 0 );
}




isupper_alpha( Chara )

	char Chara;
{

   if ( !((Chara < 65) || (Chara > 90)) )
       return( 1 );
     else
       return( 0 );
}




toupper_alpha( Chara )

	char *Chara;
{

   if ( !((*Chara < 65) || (*Chara > 90)) )
       return( 1 );
     else if ( !((*Chara < 97) || (*Chara > 122)) ) {
       (*Chara) -= 32;
       return( 1 );
       }
     else
       return( 0 ) ;
}




isnumeric( Chara )

	char Chara;
{

   if ( ((Chara < 48) || (Chara > 57)) && (!((Chara == '.') || (Chara == ','))) )
       return( 0 );
     else
       return( 1 );
}




isalphanumeric( Chara )

	char Chara;
{
	int test;

   test = isnumeric( Chara );
   if (!(test))
      test = isalpha( Chara );
      
   if ( !(test) )
      return( 0 );
    else
      return( 1 );
}



int isstrstr (str)
char str[];
{
  /* Return 1 if str is itself a string, else return 0 */
  /* Note: a string has no quotes: delimiter is trailing NULL */
  /* If string has no NULL, the next NULL in memory will be */
  /* the string's NULL, thus no index range check possible */
  /* without explicit dimension in argument list */
  /* HOWEVER, str[] that entirely contains a string has 2 quotes */
  int retval;

  retval = ((str[0] == '\"') && (str[strlen(str)-1] == '\"'));
  if (retval) retval = (strccnt (str,'\"') == 2); 
  return (retval);
} /*isstrstr*/



int  ord(x) char x; { return ( ((int)(x)) ); }     /* ordinal of char */ 


char *skipchar(buf,argch)
char *buf;
int argch;
{
  while (*buf++ == argch);
  return(buf);
} /*skipchar*/


char *skiptochar(buf,argch)
char *buf;
int argch;
{
  while ((*buf != argch) && (*buf != '\n') && (*buf != EOF)) { ++buf; }   
  return(buf);
} /*skiptochar*/


int straddesc (str,ch)
char str[];
int ch;
{
  /* if ch's are imbedded in str without backslash, insert a backslash */
  int insert=0, retval=0, strndx=0, slen = strlen(str);
  char tmpstr[256], chstr[2];
  char *strzero();

  if (str[0])     /* if string not null */
  {
     strzero (chstr,2);
     strzero (tmpstr,256);
     strcpy  (chstr,"\\");
     strcpy  (tmpstr,str);
     /* decrementing obviates need to sync indices of str and tmpstr */
     for (strndx=slen; strndx>=0; strndx--)
     {
        if (str[strndx] == ch)
        {
          strisub (tmpstr,chstr,strndx-1,strndx);
          insert = retval = 1;
        }
     }
     if (insert) strcpy (str,tmpstr);
  }
  else retval = 0;   /* string is null */
  return (retval);
} /*straddesc*/


char *strccat(buf,c)
char buf[];
int c;
{
   /* cat char c to string buf: assume buf big enough */
   buf[strlen(buf)] = c;  
   buf[strlen(buf)+1] = 0;  
   return(buf);
}/*strccat*/


int strccnt (buf,c)
char buf[];
int c;
{
   /* count number of c's in buf */
   int i=0, cnt=0, buflen=strlen(buf);
   for (i=0; i<buflen; i++) 
      if (c == buf[i]) ++cnt;
   return (cnt);
} /*strccnt*/


char *strccpy(d,s,c)
char d[],s[];
int c;
{
   /* copy s into d upto char c */
   int i=0, ch=0, slen = strlen(s);
   while ((ch = s[i]) != c)
   {
     d[i] = ch;   ++i;
     if (i > slen) goto strccpy_exit;
   }
   strccpy_exit:  d[i] = 0;
   return (d);
} /*strccpy*/


int strCdel( buf, c, dir )
char buf[];
int c,dir;
{
  /* delete leading or trailing c's: if dir==0: lead, ==1: trail, ==2: both */
  /* eg: strcdel (buf,'0',1): delete trailing '0' */
  /* return count of deleted chars, and pass back modified buf in arg list*/
  int i,icnt=0, blen; 
  if(buf[0])  
  {
     /* this first, else index count will be off */
     if ((dir==1) || (dir==2))
     {
       /* delete trailing c's */
       blen=strlen(buf);
       i = blen - 1;
       while ((i >= 0) && (buf[i] == c)) {--i; ++icnt;}
       buf [++i] = 0;  /* make new string */
     } /*if dir == 1*/

     if ((dir==0) || (dir==2))
     {
       /* delete leading c's */
       /* eg: strcdel (buf,' ',0): delete leading ' ' */
       blen=strlen(buf);
       i=0;
       while ((i<blen) && (buf[i] == c)) {++i; ++icnt;}
       strcpy (buf,&buf[i]);
     } /*if dir == 0*/

  } /* if buf not null */
  return (icnt);
} /*strcdel*/


char *strcdup(str,c,cnt)
char str[];
int c,cnt;
{
   /* duplicate c cnt times and cat to str */
   int i=0;
   for (i=0; i<cnt; i++)
   {
      strccat(str,c);
   }
   return (str);
} /*strcdup*/


int strcindex(buf,c)
char buf[];
int c;
{
   /* returns index of first c in buf, where index == 0..strlen(buf)-1 */
   int i=0, retval = -1, ch = buf[0];
   while ((ch != c) && (ch != 0)) { ch = buf[++i]; }
   if (buf[i] == c)  retval = i;  else retval = -1;
   return(retval);
}/*strcindex*/


int strclast(buf,c)
char buf[];
int c;
{
  /* returns index of last c in buf, else return -1 (non-index number) */
  /* check for null also possible, but is redundant with strlen        */
  int i=0;
  for (i=strlen(buf); i>= 0; i--)
  {
     if (buf[i] == c) return (i);
  }
  return (-1);
} /*strclast*/


int strcleft(buf,c)
char buf[];
int c;
{
  /* returns number of chars from [0]..['c'] */
  int left;
  left = ((left = strcindex(buf,c)) < 0) ? 0 : left;
  return (left);
} /*strcleft*/


int strcleftright(buf,c,left,right)
char buf[];
int c, *left, *right;
{
  /* returns number of chars to left and right of c */
  /* returns left = strlen(buf), and right = 0 if no c in buf */
  *left = strcleft(buf,c);
  *right = strcright(buf,c);
  if (*left <= 0) {*left = *right; *right = 0; }
  return(c);
} /*strcleftright*/


int strcright(buf,c)
char buf[];
int c;
{
  /* returns number of chars from ['c']..strlen */
  int right;
  right = strlen(buf) - strcindex(buf,c) - 1;
  return (right);
} /*strcright*/


int strcsqz (buf,c,r1,r2)
char buf[];
int c, r1, r2;
{
   int buflen, i,r1index, r2index, tmp;
   int first, strccnt(), strcindex();

   /* r1, r2 are occurrence event numbers of c in buf */
   /* r1 <  r2 : range = r1..r2 */
   /* r1 == r2 : return count of occurrences of c in buf */
   /* r1 >  r2 : range = r1..strlen(buf) */
   /* example: cnt = strcsqz (buf,'L',3,4)  : cnt = number of chars */
   /*          between the 3rd and 4th occurrence of 'L' in buf     */
   /*          If the 4th doesn't exist, buflen is assumed          */

   buflen = strlen(buf);

   /* find first index */
   if ((first = strcindex (buf,c)) < 0) return (0);

   if (r1 == r2) return (strccnt (buf,c));

   /* find r1index */
   if (r1 == 0)  
   {
      r1index = 0;
      if (r2 == 1) return (first);
   }
   else if (r1 == 1)  r1index = first;
   else
   {
     r1index = tmp = first;
     for (i=2; i<= r1; i++)
     {
	tmp = strcindex (&buf[tmp+=1],c);
	r1index = r1index + tmp + 1;
     }
     if (tmp < 0) return (0);   /* occurrence r1 not in buf */
   }

   if (r1 > r2) return (buflen - r1index - 1);

   /* find r2index */
        r2index = tmp = r1index;
        for (i=r1+1; i<= r2; i++)
        {
           tmp = strcindex (&buf[tmp += 1],c);
           r2index = r2index + tmp + 1;
        }
        if (tmp < 0) return (buflen - r1index - 1);
        else if (r2index == r1index) return (0);
        else  return (r2index - r1index - 1);
}  /*strcsqz*/


char *strcsub(buf,c)
char buf[];
int c;
{
  /* substitute c into buf at location [0] */
  buf[0] = c;
  return(buf);
} /*strcsub*/


char *strcsubindex(buf,n,c)
char buf[];
int n,c;
{
  /* assumes buf at &buf[0] and buf dimensioned large enough */
  /* substitute c at index n of buf, and expand buf if needed */
  int i=0;
  if (n < 0) n = -n;
  if (n < strlen(buf)) buf[n] = c; 
  else
  {
    for (i=strlen(buf); i<=n; i++) buf[i] = ' ';
    buf[n] = c; buf[n+1] = 0;
  }
  return(buf);
} /*strcsubindex*/


int strexist (list,string,maxlist)
char *list[], *string;
int maxlist;
{
   /* if string in list of maxlist number of strings, return TRUE */
   int retval=0, ndx=0;
   for (ndx=0; ndx<maxlist; ndx++)
     if (strcmp (list[ndx], string) == 0) retval = 1;
   return (retval);
} /*strexist*/


int strileft(buf,cindex,c)
char buf[];
int c,cindex;
{
  /* return index of next occurrence of c to the left of index cindex */
  /* if c not found, return 0: beginning of buf */
  int left = cindex;
  if (left < 0) left = 0;
  else
  {
    --left;   /* start one char left of c */
    while ( (buf[left] != c) && (left >= 0) ) --left;
    if  (left <  0) ++left;
    left = cindex - left;
  }
  return (left);
} /*strileft*/


int striright(buf,cindex,c)
char buf[];
int c,cindex;
{
  /* return index of next occurrence of c to the right of index cindex */
  /* if c not found, return strlen(buf) */
  int right = cindex;
  if (right < 0) right = strlen(buf);
  else 
  {
    ++right;   /* start one char right of c */
    while ((buf[right] != c) && (right < strlen(buf)) )  ++right;
    if (right >= strlen (buf)) 
       right = right - cindex - 1;
  }
  return (right);
} /*striright*/


int strisub(oldstr,insstr,s,f)
char oldstr[], insstr[];
int s,f;
{
   /* substitute insstr for whatever is between indices s and f in oldstr */
   /* return index of char that follows last char of insstr */
   /* oldstr is assumed to be dimensioned large enough */
   char tmp1[256], tmp2[256];
   strcpy (tmp1,oldstr);
   tmp1[s+1] = 0;
   strcpy (tmp2,tmp1);
   strcat (tmp2,insstr);
   strcat (tmp2,&oldstr[f]);
   strcpy (oldstr,tmp2);
   return (s + strlen(insstr) + 1);   /* reset oldstr index */
} /*strisub*/


char *strlshft (buf,cindex,shift)
char buf[];
int cindex, shift;
{
   /* shift buf elements left by shift indices */
   int i=0,j=0, buflen=strlen(buf);
   i = cindex;
   if ((shift>0) && (cindex < buflen))
   {
      for (j=0; j<shift; j++)
      {
	buflen = strlen(buf);
        for (i=cindex--; i<buflen-1; i++)
           buf[i] = buf[i+1];
        buf[i] = 0; /* actually redundant, but it is explicit */
      }
   }
   return (buf);
} /*strlshft*/


int strnleft(buf,c)
char buf[];
int c;
{
  /* return index of furthest-left-of-c-yet-contiguous digit */
  /* if c not found, return 0: beginning of buf */
  int left = 0, cindex=0;
  cindex = strcindex (buf,c);
  left = cindex;
  if (left <= 0) left = 0;
  else
  {
    --left;   /* start one char left of c */
    while (isdigit(buf[left]) && (left >= 0)) --left;
    if  ( (!isdigit (buf[left])) || (left <  0)) ++left;
  }
  return (left);
} /*strnleft*/


int strnright(buf,c)
char buf[];
int c;
{
  /* return index of furthest-right-of-c-yet-contiguous digit */
  /* if c not found, return strlen(buf) */
  int cindex = strcindex (buf,c);
  int right=0;
  right = cindex;
  if (right < 0) right = strlen(buf);
  else 
  {
    ++right;   /* start one char right of c */
    while (isdigit (buf[right]) && (right < strlen(buf)) )  ++right;
    if ( (!isdigit (buf[right])) || (right >= strlen (buf)) ) 
       right = right - cindex - 1;
  }
  return (right);
} /*strnright*/


char *strrcpy (dbufd,sbufs,sstart,send)
char dbufd[], sbufs[];
int sstart, send;
{
   int i=0;
   for (i=sstart; i<send; i++) { dbufd[i] = sbufs[i]; }
   dbufd[i] = 0;
   return(dbufd);
} /*strrcpy*/


char *strssub (dbuf,vbuf,sbuf)
char dbuf[], vbuf[], sbuf[];
{
   /* substitute sbuf for all substring occurrences of vbuf in dbuf */
   int i = 0, j = 0;
   char tmp[256];
   while (j < strlen(dbuf))
   {
     while ((vbuf[0] != dbuf[j]) && (j < strlen(dbuf))) 
     { 
       ++j;
     } 
     while ((vbuf[i] == dbuf[j]) && (i < strlen(vbuf)) && (j < strlen(dbuf)))
       {
	  ++i;  ++j; 
       }
     if (i == strlen(vbuf))
     {
       dbuf[j-i] = 0;
       strcpy (tmp,dbuf);
       strcat (tmp,sbuf);
       strcat (tmp,&dbuf[j]);
       strcpy (dbuf,tmp);
       j = j - i + strlen(sbuf);
       i = 0;
     }
     else { i = 0; ++j; }
   } /* while j < strlen(dbuf) */
   return (dbuf);
}/*strssub*/


char *strwidth(str,colwidth,just)
char str[];
int colwidth,just;
{
   /* strwidth() pads or truncates string to colwidth */
   /* padding with blanks on left, center, or right   */
   /* if just = 0,1,2 */

   char *_tmpstring_;
   int slen = strlen(str), str_flag=0;
   char *strzero();

   str_flag = isstrstr (str);  /*preserve string quotes*/

   /* simply return if slen == colwidth */
   if (slen > colwidth)
   {
      /* if str_flag, the 2 quotes will be at [0] and [colwidth-1] */
      if (str_flag) str [colwidth-1] = '\"';
      str[colwidth] = 0;
   }
   else if (slen < colwidth)
   {
      /* pad string based on justification, and return */
      _tmpstring_ = (char *)malloc ((unsigned)(colwidth + 1));
      strzero   (_tmpstring_, (colwidth + 1));
      switch (just)
      {
	 case 0:  /* left padding */
		  if (str_flag) strcpy (_tmpstring_, "\"");
		  strcdup (_tmpstring_,' ',(colwidth-slen));
		  if (str_flag)
		     strcat  (_tmpstring_, &str[1]);
		  else
		     strcat  (_tmpstring_, str);
		  if (str_flag) strcat (_tmpstring_, "\"");

		  /* make sure _tmpstring_ is a string */
		  _tmpstring_[colwidth] = 0;  

		  strcpy  (str, _tmpstring_);
		  break;

	 case 1:  /* left and right padding, with odd pad on right */
		  if (str_flag)
		  {
		     strcpy (_tmpstring_, "\"");
		     strcdup (_tmpstring_,' ',(colwidth-slen)/2);
		     strcat  (_tmpstring_, &str[1]);
		     _tmpstring_[strlen(_tmpstring_)-1] = 0;
		     if ( ((colwidth-slen)%2) != 0)
		        strcdup (_tmpstring_,' ', (1+(colwidth-slen)/2) );
		     else 
		        strcdup (_tmpstring_,' ', (colwidth-slen)/2 );
		     strcat (_tmpstring_, "\"");
		  }
		  else
		  {
		     strcdup (_tmpstring_,' ',(colwidth-slen)/2);
		     strcat  (_tmpstring_, str);
		     if ( ((colwidth-slen)%2) != 0)
		        strcdup (_tmpstring_,' ', (1+(colwidth-slen)/2) );
		     else 
		        strcdup (_tmpstring_,' ', (colwidth-slen)/2 );
		  }

		  /* make sure _tmpstring_ is a string */
		  _tmpstring_[colwidth] = 0; 

		  strcpy  (str, _tmpstring_);
		  break;

	 case 2:  /* right padding */
		  if (str_flag) str[strlen(str)-1] = 0;
		  strcdup (str,' ',(colwidth-slen));
		  str[colwidth] = 0;   /* make sure str is a string */
		  if (str_flag) str[colwidth-1] = '\"';
		  break;

	 default: break;
      } /*switch just*/
      free (_tmpstring_);

   }   /* else slen < colwidth */

   return (str);
} /*strwidth*/


char *strwsub (dbuf,vbuf,sbuf)
char dbuf[], vbuf[], sbuf[];
{
   /* substitute sbuf for all occurrences of variable vbuf in dbuf */
   /* a variable starts with an alpha and ends with non-alphanumeric */
   int i = 0, j = 0;
   char tmp[256];
   while (j < strlen(dbuf))
   {
     while ((vbuf[0] != dbuf[j]) && (j < strlen(dbuf))) 
     { 
       ++j;
     } 

     if (j==0)
     {
       while ((vbuf[i]==dbuf[j]) && (i<strlen(vbuf)) && (j<strlen(dbuf)))
       {
	  ++i;  ++j; 
       }
     }/*if j==0*/
     else if (j > 0)
     {
       if (!isalpha (dbuf[j-1]))
       {
         while ((vbuf[i]==dbuf[j]) && (i<strlen(vbuf)) && (j<strlen(dbuf)))
         {
            ++i;  ++j; 
         }
       }
     } /*else if j > 0 */


     if (!isalnum (dbuf[j]))
     {
       if (i == strlen(vbuf))
       {
         dbuf[j-i] = 0;
         strcpy (tmp,dbuf);
         strcat (tmp,sbuf);
         strcat (tmp,&dbuf[j]);
         strcpy (dbuf,tmp);
         j = j - i + strlen(sbuf);
         i = 0;
       }
       else { i = 0; ++j; }
     }
     else { i = 0; ++j; }
   } /* while j < strlen(dbuf) */
   return (dbuf);
}/*strwsub*/


char *strzero(str,cnt)
char str[];
int cnt;
{
   int i=0;
   for (i=0; i<cnt; i++)  str[i] = 0;
   return (str);
} /*strzero*/

int getbufint(buf,lastdigit)
char buf[];
int *lastdigit;
{
   int i=0, num=0, sign=1;
   /* lastdigit is the index of last digit of num */
   /*   it is  NOT the index of next char after last digit*/
   /* skip leading non-numerics */
   *lastdigit = 0;
   while (((buf[i] < '0') || (buf[i] > '9')) && (buf[i])) 
   { *lastdigit = i; ++i; }

   sign = (buf[i-1] == '-') ? (-1) : (1);

   while ((buf[i] >= '0') && (buf[i] <= '9'))  
   {
     num = 10 * num + (buf[i] - '0');
     *lastdigit = i;  ++i;
   } /*while buf*/
  return (sign * num);
} /*getbufint*/


char *getbufstr(buf,lastdigit)
char buf[];
int *lastdigit;
{
   int c=0, i=0;
   char tmpbuf[128], *strzero(), *strccat();
   /* lastdigit is the index of last char of string */
   /*   it is  NOT the index of next char after last char in string*/
   /* skip leading whitespace */
   *lastdigit = 0;
   while ((c=buf[i]) && iswhitespace(c))
   { *lastdigit = i; ++i; }

   strzero (tmpbuf,128);
   while ((c=buf[i]) && !iswhitespace(c))
   {
     strccat (tmpbuf, c); *lastdigit = i;  ++i;
   } /*while buf*/
   tmpbuf [127] = 0;  /* only need to make string if strccat >128 c's */
  return (tmpbuf);
} /*getbufstr*/

int iswhitespace (c)
int c;
{
  return ((c == ' ') || (c == '\b') || (c == '\t'));
} /*iswhitespace*/




char   *strfind(char_string, cmpstring)

	char   *char_string,
               *cmpstring;

{

	int  count1, len1, len2, test;
        char *char_ptr1;

   len1 = strlen( char_string );
   len2 = strlen( cmpstring );

   for( test = 1, count1 = 0, char_ptr1 = char_string + count1;
        (count1 <= (len1 - len2)) && (test != 0);
        count1++) {
      test = 1;
      test = strncmp(char_ptr1, cmpstring, len2);
      if (test != 0) char_ptr1++;
      }

   if (test == 0)
       return( char_ptr1 );
     else {
       char_ptr1 = '\0';
       return( char_ptr1 );
       }
}




short  *strfind16(char_string, cmpstring)

	short   *char_string,
                *cmpstring;

{

	int    count1, len1, len2, test;
        short *char_ptr1;

   len1 = strlen16( char_string );
   len2 = strlen16( cmpstring );

   for( test = 1, count1 = 0, char_ptr1 = char_string + count1;
            (count1 <= (len1 - len2))
         && (strncmp16(char_ptr1, cmpstring, len2) != 0);
        count1++, char_ptr1++ );

   if( (strncmp16(char_ptr1, cmpstring, len2)) != 0 )
       return( char_ptr1 );
     else
       return( (short)0 );
}




/**************************************************************************
 *  MOVE_UBYTES                                                           *
 *  moves n unsigned bytes from the source array to the destination array *
 *  s_array & d_array are pointers to the source, destination             *
 **************************************************************************/

move_ubytes(s_array, d_array, n)

        unsigned char *s_array,
                      *d_array;
                 int   n;

{
                 int   ii;
        unsigned char *sarr, *darr;

    if (n <= 0)
        return;

    for( ii = 0, sarr = s_array, darr = d_array; ii < n; ii++, sarr++, darr++ )
       *darr = *sarr;

    return;

}




/**************************************************************************
 *  MOVE_BYTES                                                            *
 *  moves n unsigned bytes from the source array to the destination array *
 *  s_array & d_array are pointers to the source, destination             *
 **************************************************************************/

move_bytes(s_array, d_array, n)

        char *s_array,
             *d_array;
        int   n;

{
        int   ii;
        char *sarr, *darr;

    if (n <= 0)
        return;

    for( ii = 0, sarr = s_array, darr = d_array; ii < n; ii++, sarr++, darr++ )
       *darr = *sarr;

    return;

}




GGitem_list *UT_find_GGitem_list( typeface_name, typeface_names,
                                    num_typefaces, typeface_index )

	GGlist       typeface_name;
        GGitem_list *typeface_names;
        int           num_typefaces;
        int          *typeface_index;

{
        int           test, count, len1, len2;
	GGitem_list  *typeface_ptr;

   test = 1;
   for( count = 0, typeface_ptr = typeface_names;
        count < num_typefaces;
        count++, typeface_ptr++) {
       len1 = strlen16( typeface_ptr->item );
       len2 = strlen16( typeface_name );
       if( len1 == len2 )
          test = strcmp16(typeface_ptr->item, typeface_name);
       if (test == 0) break;
       }

   if (test == 0) {
       *typeface_index = count;
       return( typeface_ptr );
       }
     else {
      *typeface_index = 0;
      return( NULL );
      }
}




GGlist *UT_find_GGlist( typeface_name, typeface_names,
                        num_typefaces, typeface_index, len )

	GGlist        typeface_name;
        GGlist       *typeface_names;
        int           num_typefaces;
        int          *typeface_index, len;

{
        int      test, count;
	GGlist  *typeface_ptr;

   test = 1;
   for( count = 0, typeface_ptr = typeface_names;
       count < num_typefaces;
        count++, typeface_ptr++) {
       test = strncmp16(typeface_ptr, typeface_name, len);
       if (test == 0) break;
       }

   if (test == 0) {
       *typeface_index = count;
       return( typeface_ptr );
       }
     else {
      *typeface_index = 0;
      return( NULL );
      }
}




UT_find_path( typeface_changes,  end_changes, typepath_ptr, typeface )

	Typepath  *typeface_changes;
        Typepath  *end_changes;
        Typepath **typepath_ptr;
        Typepath   typeface;

{
        int        test;
        short      null_str;
	Typepath  *typeface_ptr;

   test     = 1;
   null_str = 0;
   for( typeface_ptr = typeface_changes;
        typeface_ptr < end_changes;
        typeface_ptr++) {
       if( typeface_ptr[0] == 0 ) {
          null_str = 1;
          break;
          }
       if( (strcmp16(typeface_ptr, typeface )) == 0 ) break;
       }

   if( ((strcmp16(typeface_ptr, typeface )) == 0 ) && (! null_str) )
      *typepath_ptr = NULL;
     else
      *typepath_ptr = typeface_ptr;

   return;

}
