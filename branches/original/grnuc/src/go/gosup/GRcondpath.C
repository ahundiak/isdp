/*

Name
  GRcondense_path

Abstract
  This function will take a full path name and will condense it by removing
relative path portions.

Synopsis

    Type         Value   Input/Output                  Description
  ----------- ---------- ------------ ----------------------------------------
  IGRlong     *msg       Input        Return code:
                                        MSSUCC => successful
                                        MSFAIL => failure; the input text
                                                  string was longer than
                                                  MAXPATHLEN
  IGRchar     *path      Input/Output Full path / Full path with relative
                                      path indicators removed

Description
  This function removes the relative path indicators ./ and ../ from the
  input full path name.  It will also remove duplicate / characters.

Notes
  This code was almost totally copied from the EXNUC function fix_directory
which is in the file set_paths.C.

Return Value
  type:  IGRint
  values: 1 if successful
          0 if failure (input string was longer than MAXPATHLEN)

Keywords
  function

History
  11/16/93 : Bill Cecil : Created

*/

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include <sys/param.h>


IGRint GRcondense_path(msg, path)

IGRlong	  *msg;
IGRchar	  *path;
{
    char temp[MAXPATHLEN];
    int i, j, k;

    *msg = MSSUCC;
    temp[0] = '\0';

    if ((k = strlen(path))  >= MAXPATHLEN)
    {
        *msg = MSFAIL;
        goto wrapup;
    }

    for(i = 0, j = (-1); i < k;)
    {
        switch(path[i])
        {
            case '/': 
                temp[++j]=path[i++];
                while(path[i]=='/')i++;
                break;

            case '.':
                switch(path[++i])
                {
                    case '/':
                        while(path[i]=='/')i++;
                        break;

                    case '.':
                        if(path[++i]=='/')
                        {
                            while(path[i]=='/')i++;
                            do
                                temp[j]='\0';
                            while(temp[--j]!='/');
                         }
                         else
                         {
                             temp[++j]=path[i-2];
                             temp[++j]=path[i-1];
                             temp[++j]=path[i++];
                         }
                         break;

                     default:
                         temp[++j]=path[i-1];
                         temp[++j]=path[i++];
                         break;
                 } /* switch */
                 break;

            default:
                temp[++j]=path[i++];
                break;

        } /* switch */
    } /* for loop */ 

    if (j > 0 ) temp[++j] = '\0';
    strcpy(path,temp);

wrapup:

    return(1 & *msg);
}
