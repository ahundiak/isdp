#include <stdio.h>
#include <malloc.h>
#include <string.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/rdminim.h"

static PWboolean read_pt
(
  FILE *file,
  double *pt,
  PWboolean is_3d
);

#define STRING_MATCH 0



PWboolean pwReadPt2d 
(
  FILE *file,
  PWpoint2d pt
)
{
  return (read_pt (file, (double *) pt, FALSE));
}

PWboolean pwReadPt 
(
  FILE *file,
  PWpoint pt
)
{
  return (read_pt (file, (double *) pt, TRUE));
}

PWboolean pwReadId
( 
  FILE *file,
  PWobjid *objid,
  PWosnum *os,
  char classname[PW_K_MaxStringLen]
)
{
  PWboolean is_success = FALSE;
  char line[PW_K_MaxCharOnLine+1];

  while (fgets (line, PW_K_MaxCharOnLine, file))
  {
    if (pwReadIdFromString (line, objid, os, classname))
    {
      is_success = TRUE;
      break;
    }
    else 
      continue;
  }

  return (is_success);
}



PWboolean pwReadIdFromString
(
  char *line,
  PWobjid *objid,
  PWosnum *os,
  char classname[PW_K_MaxStringLen]
)
{
  PWboolean is_success=TRUE;
  char token[PW_K_MaxCharOnLine+1], *p_token;

  OnErrorState (pwNumFields (line) != 3, is_success, FALSE, wrapup);

  if (pwFieldInStr (FIRST, line, token) && 
      strcmp (token, "+") == STRING_MATCH &&
      pwFieldInStr (THIRD, line, token) && 
      token[0] == '[') /* Kluge for now, until below statement can be made */
/*    pwRegExpMatch (token, "[*,*]")) */
  {
    p_token = strtok (token, "[,");
    *objid = atoi (p_token);
    p_token = strtok (NULL, "[,");
    *os = atoi (p_token);

    pwFieldInStr (SECOND, line, classname);
  }
  else 
  {
    OnErrorState (TRUE, is_success, FALSE, wrapup);
  }

wrapup:
  return (is_success);
}


/*------------------- STATIC FUNCTIONS --------------------------------------*/

static PWboolean read_pt 
(
  FILE *file,
  double *pt,
  PWboolean is_3d
)
{
  char line[PW_K_MaxCharOnLine+1], filename[PW_K_MaxCharOnLine+1];
  char token[PW_K_MaxCharOnLine+1];
  int inx;
  FILE *intfile;
  PWboolean is_success = FALSE;

  while (fgets (line, PW_K_MaxCharOnLine, file))
  {
    if (pwNumFields (line) < 2)
      continue;

    inx = pwGetInxOfField (FIRST, line);
    pwFieldInStr (FIRST, line, token);
    if (strcmp (token, "+") == STRING_MATCH &&
        pwCvtypeFromString (&line[inx+1]) == 
         (is_3d ? PWcvdata_pt : PWcvdata_pt2d))
    {
      if (!fgets (line, PW_K_MaxCharOnLine, file))
        break;

      if (is_3d ? !sscanf (line, "%lf %lf %lf", &pt[X], &pt[Y], &pt[Z]) :
                  !sscanf (line, "%lf %lf", &pt[X], &pt[Y]))
      {
        sscanf (line, "%s", filename);
        if (intfile = fopen (filename, "r"))
        {
          is_success = read_pt (intfile, pt, is_3d);
          fclose (intfile);
        }
      }
      else
      {
        is_success = TRUE;
      }
      break;
    }
  }

  return (is_success);
}

