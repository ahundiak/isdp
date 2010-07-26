
#include <exdef.h>
#include <ctype.h>
#include <string.h>

#define debug 0

extern char EX_keybuff[];
extern EX_index;

 
/*****************************  special_keyin ****************************/
/*                                                                       */
/*      This routine checks to see if EX_keybuff contains a special      */
/*      <esc> keyin.  The routine returns a 1 if a special keyin is      */
/*      detected, it returns a 0 if it is not a special keyin.           */
/*                                                                       */
/*************************************************************************/
#argsused
special_keyin(response,response_data)
 int *response;
 char *response_data;
{
  int len, j;
  char tempstring[257];
  char *nonblank;

  strcpy(tempstring,EX_keybuff);
  len = strlen(tempstring);

  /* strip off trailing blanks */

  j = len - 1;
  while( tempstring[j] == 040 )
  {
       tempstring[j] = '\0';
       --j;
  }

  nonblank = tempstring;
  while( isspace(*nonblank) )   nonblank++;
  
  if (*nonblank == '<')
  {
     if(!strncmp(nonblank, "<esc>", 5)) 
     {
        /* since the string has an <esc> at front, strip it off */
        nonblank += 5;
        strcpy(EX_keybuff,nonblank); 
        *response = CMD_STRING;
        return(1);
     }
  }

  strcpy(EX_keybuff,nonblank); 
  return(0);
 } /* special_keyin */
