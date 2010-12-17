/* $Revision: 1.1 $ */
#include "dba.ext"

/*
Function: dba_is_wild_hit
Author:   G. I. Huey
Date:     1-Jun-94

Description:  This program checks a wild card string against a user
              supplied string and sees if there is a match.  If
              no match occured a null is returned. Otherwise a 1 is
              returned.  The wild cards are '*' and '?'.
*/

int dba_is_wild_hit(wild_buf, str_buf)
char *wild_buf, *str_buf;
{
  char *strchr(), *strstr();
  char *wild_ptr, *str_ptr, *sav_ptr;
  int  loop, match = 0;

  wild_ptr = wild_buf;
  str_ptr  = str_buf;
  sav_ptr  = 0;
  loop     = 1;

  while(loop)
  {
    switch(*wild_ptr)
    {
      case '*' :
        while (*wild_ptr == '*') wild_ptr++;
        if (*wild_ptr == '\0')
        {
          loop  = 0;
          match = 1;
          break;
        }

        /*
        ** Check see for second wild card
        */

        if (!strchr(wild_ptr, '*'))
        {
          /*
          ** No, the end of the string must match therefor lets point
          ** to the end of the string minius the characters left to check.
          */

          if (strlen(wild_ptr) > strlen(str_ptr))
          {
             loop = 0;
             break;
          }
          str_ptr = str_ptr + strlen(str_ptr) - strlen(wild_ptr);
          sav_ptr = 0;
        }
        else
        {
          if (*wild_ptr == '?') break;

          /*
          ** Save the pointer in case we need to look for a second match
          */

          sav_ptr = wild_ptr;
          str_ptr = strchr(str_ptr, *wild_ptr);
          if (!str_ptr)
          {
            loop  = 0;
          }
        }
        break;

      case '?' :
        ++wild_ptr;
        ++str_ptr;

        /*
        ** Check and see if we ran out of wild cards and string
        ** If so, we have a match.
        */

        if (*wild_ptr == '\0' && *str_ptr == '\0')
        {
           loop  = 0;
           match = 1;
        }
        break;

      default :
        if (*wild_ptr != *str_ptr)
        {
          if (sav_ptr)
          {
            /*
            ** At this point search failed.  Make sure that we still
            ** don't have a match later on.
            */

            str_ptr = strchr(str_ptr, *sav_ptr);
            if (str_ptr)
            {
              wild_ptr = sav_ptr;
            }
            else
            {
              loop = 0;
              break;
            }
          }
          else
          {
            loop = 0;
            break;
          }
        }
        ++wild_ptr;
        ++str_ptr;
        if (*wild_ptr == '\0' && *str_ptr == '\0')
        {
          loop  = 0;
          match = 1;
        }
        break;
    }
    if (*wild_ptr == '\0' || *str_ptr == '\0') loop = 0;
  }
  return(match);
}
