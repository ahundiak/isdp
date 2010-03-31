#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "PWminimum.h"

#define MATCH 0

/*
  DESCRIPTION

  The following function returns TRUE if the characters in the 
  string - 'match', are found anywhere in the string - 'str'. But they must
  be found successively, ie, the second character in 'match' cannot be found
  BEFORE the first character. The look-up is case insensitive.
*/

PWboolean pwFuzzyMatch
(
  char *str,
  char *match
)
{
  int i, j, strinx, str_len, match_len, num_matched;
  
  str_len = strlen (str);
  match_len = strlen (match);
  num_matched = 0;

  if (str_len >= match_len)
  {
    strinx = 0;
    for (i=0; i<match_len; i++)
    {
      for (j=strinx; j<str_len; j++)
      {
        if (toupper (str[j]) == toupper (match[i]))
        {
          num_matched++;
          strinx++;
          break;
        }
      }
    }
  }

  return (num_matched == match_len);
}


/*
  DESCRIPTION

  The following function treats the "match" input string as one that can
  potentially contain the special regular expression character - '*'. Using
  the semantics of the wild character, if a match is found with the input
  "str" then a TRUE is returned, else FALSE.
*/

/*ARGSUSED*/
PWboolean pwRegExpMatch
(
  char *str,
  char *match
)
{
  return (TRUE);
}


/*
  DESCRIPTION

  This function returns the number of fields in a given NULL terminated
  string. A field comprises of consecutive non-white space characters.
*/

int pwNumFields
(
  char *str
)
{
  int i, len, num_fields;
  PWboolean whitespace_state;

  len = strlen (str);
  num_fields = 0;
  whitespace_state = TRUE;
  for (i=0; i<len; i++)
  {
    if (!isspace (str[i]) && whitespace_state)
    {
      whitespace_state = FALSE;
      num_fields++;
    }
    else if (isspace (str[i]) && !whitespace_state)
    {
      whitespace_state = TRUE;
    }
  }

  return (num_fields);
}


/*
  DESCRIPTION

  This function returns the byte index of the starting character of the
  'n'th field in a given string. 'n' is an index and, therefore, to indicate
  the first field one passes in 0, for the second field one passes in 1 and 
  so on. If 'n' is out-of-bounds for this string, this function returns EOF.
*/

int pwGetInxOfField
(
  int n,
  char *str
)
{
  int i, len, inx, num_fields;
  PWboolean whitespace_state;

  len = strlen (str);
  num_fields = 0;
  whitespace_state = TRUE;
  inx = EOF;
  for (i=0; i<len; i++)
  {
    if (!isspace (str[i]) && whitespace_state)
    {
      whitespace_state = FALSE;
      num_fields++;
    }
    else if (isspace (str[i]) && !whitespace_state)
    {
      whitespace_state = TRUE;
    }
  
    if (!whitespace_state && n == num_fields-1)
    {
      inx = i;
      break;
    }
  }

  return (inx);
}

/*
  DESCRIPTION

  This function returns the 'n'th field as a NULL-terminated string. Here
  'n' is an index, hence reference to the first field is by n=0, the second
  field is by n=1, and so on. The caller must provide enough space for the
  output (a safe size is the length of the input string itself). If 'n' is out
  of bounds, the value of the function is FALSE, else it is TRUE.
*/

PWboolean pwFieldInStr
(
  int n,
  char *str,
  char *field
)
{
  int inx;
  PWboolean funcval=FALSE;

  if ((inx = pwGetInxOfField (n, str)) != EOF)
  {
    sscanf (&str[inx], "%s", field);
    funcval = TRUE;
  }

  return (funcval);
}

