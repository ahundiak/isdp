/*
 * Copyright (c) 1989
 * Intergraph Corporation; All Rights Reserved
 * Including Application Programs, File Formats, and Visual Displays

 rtns.c - program routines

06/28/89  rlk initial program
11/22/89  rlk added str_pos
routines include:

  str_pos
  midstring
  rj
  lj
  cj
  pos
*/

#include <ctype.h>
#include <string.h>
#include <memory.h>

/****************************************************************************
        Name: str_pos
 Description: returns the position of string1 in string2
  Entry cond: caseflag 0=case sensitive
   Exit cond: 
Funcs called: none
****************************************************************************/
int str_pos(searchstr,targstr,caseflag)
char *searchstr,*targstr;
int caseflag;
{
  int c,c1;

  c= c1 =0;
  if (searchstr[0]==0 || targstr[0]==0)
  {
    return(0);
  }/* if searchstr[0]*/
  else
  {
    while (targstr[c] && searchstr[c1])
    {
      if (caseflag)
      {
        if (toupper(targstr[c]) == toupper(searchstr[c1]))
          c1++;
        else
          c1=0;
        c++;
      }/* if caseflag */
      else
      {
        if (targstr[c]==searchstr[c1])
          c1++;
        else
          c1=0;
        c++;
      }/* if caseflag else */
    }/* while */
    if (searchstr[c1]==0)
      return(c-c1+1);
    else
      return(0);
  }/* if searchstr[0] else */
}/* str_pos */

/****************************************************************************
        Name: midstring
 Description: returns the part of a string starting from x for y chars
  Entry cond: 
   Exit cond: 
Funcs called: none
****************************************************************************/
void midstring(outstring,instring,start,many)
char *outstring,*instring;
int start,many;
{
  int i,j;

  memset(outstring,'\0',many+1);
  j = 0;
  for (i = start-1; i <= start +many-2; i++)
  {
    outstring[j] = instring[i];
    j++;    
  }
}/* midstring */
/****************************************************************************
        Name: rpt
 Description: Creates a string composed of a certain number of repetitions
              of a string/char
  Entry cond: 
   Exit cond: 
Funcs called: 
****************************************************************************/
void rpt(rstr,buffer,repts)
char *rstr,*buffer;
int repts;
{
  int c,c1,c2;
  
  for (c=c1=c2=0; c < repts; c++,c1=0)
  {
    while (rstr[c1])
    {
      buffer[c2] = rstr[c1];
      c1++;
      c2++;
    }
  }
  buffer[c2] =0;
}/* rpt */
/****************************************************************************
        Name: rj
 Description: Right justify a string in a field of spaces
  Entry cond: 
   Exit cond: 
Funcs called: 
****************************************************************************/
void rj(rstr,buffer,fieldwidth)
char *rstr,*buffer;
int fieldwidth;
{
  int t,t1,lr;

  for (lr=0; rstr[lr]; lr++);
  if (lr <= fieldwidth)
  {
    t1 = fieldwidth-lr-1;
    for (t=0; t<=t1; t++)
      buffer[t] = ' ';
    for (t1=0, fieldwidth--; t<=fieldwidth; t++,t1++)
      buffer[t] = rstr[t1];
    buffer[t] = 0;
  }
  else
  {
    buffer[fieldwidth] = 0;
    for (fieldwidth--,lr--; fieldwidth >=0; fieldwidth--,lr--)
      buffer[fieldwidth] = rstr[lr];
  }
}/* rj */
/****************************************************************************
        Name: lj
 Description: left justify a string in a field of spaces
  Entry cond: 
   Exit cond: 
Funcs called: 
****************************************************************************/
void lj(rstr,buffer,fieldwidth)
char *rstr,*buffer;
int fieldwidth;
{
  int t,lr;

  for (lr=0; rstr[lr]; lr++);
  if (lr <= fieldwidth)
  {
    fieldwidth--;
    for (t=0; rstr[t]; t++)
      buffer[t] = rstr[t];
    for (; t<=fieldwidth; t++)
      buffer[t] = ' ';
    buffer[t] = 0;
  }
  else
  {
    fieldwidth--;
    for (t=0; t<=fieldwidth; t++)
      buffer[t] = rstr[t];
    buffer[t] = 0;
  }
}/* lj */
/****************************************************************************
        Name: cj
 Description: centers a string in a field of spaces
  Entry cond: 
   Exit cond: 
Funcs called: 
****************************************************************************/
void cj(rstr,buffer,fieldwidth)
char *rstr,*buffer;
int fieldwidth;
{
  int t,t1,lr,lc,rc;

  lr = strlen(rstr);
  if (lr <= fieldwidth)
  {
    lc = (t1=fieldwidth - lr)>>1;
    rc = lc+(t1 & 0x0001);

    for (t=0, lc--; t<=lc; t++)
      buffer[t] = ' ';
    for (t1 =0, lr--; t1<=lr; t++,t1++)
      buffer[t] = rstr[t1];
    for (rc +=t; t<rc; t++)
      buffer[t] =' ';
    buffer[t] = 0;
  }
  else
  {
    for (t=0,fieldwidth--; t<=fieldwidth; t++)
      buffer[t] = rstr[t];
    buffer[t] = 0;
  }
}/* cj */
/****************************************************************************
        Name: copy
 Description: returns a substring
  Entry cond: 
   Exit cond: 
Funcs called: none
****************************************************************************/
void copy(source,pos,numchars,dest)
char *source;
int pos,numchars;
char *dest;
{
  int c;
  
  if (pos <= strlen(source))
  {
    for (c=0, pos--,numchars--;
      ((source[pos]) && (c <=numchars));pos++,c++)
      dest[c]=source[pos];
    dest[c]=0;
  }
  else
    dest[0] = 0;
  return(dest);    
}/* copy */
/****************************************************************************
        Name: trim_lead
 Description: deletes leading blanks
  Entry cond: 
   Exit cond: 
Funcs called: none
****************************************************************************/
void trim_lead(st)
char *st;
{
  int c,c1;
  
  c1=0;
  for (c=0; (((unsigned)st[c]<=32) && (st[c])); c++);
  if (st[c])
  {
    while (st[c])
    {
      st[c1] = st[c];
      c1++;
      c++;
    }
  }
  st[c1]=0;
}/* trim_lead */

/****************************************************************************
        Name: trim_trail
 Description: deletes trailing blanks, tabs, etc
  Entry cond: 
   Exit cond: 
Funcs called: none
****************************************************************************/
void trim_trail(st)
char *st;
{
  int c;
  
  if (st[0])
  {
    for (c=0; st[c]; c++);
    for (c--;((c>0) && ((unsigned)st[c] <=32)); c--);
    if ((unsigned)st[c] >32)
      st[c+1]=0;
    else
      st[c]=0;
  }
}/* trim_trail */

/****************************************************************************
        Name: trim_trail_spaces
 Description: deletes trailing blanks only
  Entry cond: 
   Exit cond: 
Funcs called: none
****************************************************************************/
void trim_trail_spaces(st)
char *st;
{
  int c;
  
  if (st[0])
  {
    for (c=0; st[c]; c++);
    for (c--;((c>0) && ((unsigned)st[c] ==32)); c--);
    if ((unsigned)st[c] ==32)
      st[c]=0;
    else
      st[c+1]=0;
  }
}/* trim_trail_spaces */
/****************************************************************************
        Name: delete
 Description: deletes a number of chars from a string
  Entry cond: 
   Exit cond: 
Funcs called: none
****************************************************************************/
void delete(dlstr,start,numchars)
char *dlstr;
int start,numchars;
{
  char temp[5000];
  int h,i;

  h = strlen(dlstr);
  i = start + numchars;
  midstring(temp,dlstr,i,h-i+1);
  strcpy(dlstr,temp);

}/* delete */
/****************************************************************************
        Name: num_chars
 Description: count how many times a char appears in a string
  Entry cond: 
   Exit cond: 
Funcs called: none
****************************************************************************/
int num_chars(ch,st)
char ch,*st;
{
  int c,numchs;

  for (c=numchs=0; st[c];c++)
    numchs +=(st[c]==ch);
  return(numchs);
}/* num_chars */
/****************************************************************************
        Name: pos
 Description: position of the first occurrence of a char
  Entry cond: 
   Exit cond: 
Funcs called: none
****************************************************************************/
int pos(ch,st)
char ch,*st;
{
  int c;

  if ((st[0]!=ch) && (st[0]))
  {
    for (c=0; (st[c] && st[c] !=ch); c++);
    if (st[c])
    {
      c++;
      return(c);
    }
    else
      return(0);
  }
  else
  {
    if (st[0])
      return(1);
    else
      return(0);
  }    
}/* pos */

