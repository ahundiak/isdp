/*
  ABSTRACT

  Handles the GRprint and GRread messages to simply output (and read) the
  ids of the object. That is, only the header is output. The data relating
  to the object is printed out as NULL (keyword). This behaviour should be
  overridden, except in case where simply a record is needed of the 
  existence of this object.


  HISTORY

  SS  :  03/26/96  :  Creation
*/

class implementation EMSsurface;

#include <string.h>
#include <math.h>
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWapi/clsid.h"
#include "PWapi/prminim.h"
#include "PWapi/rdminim.h"

#define MATCH 0

method GRprint
(
  FILE *file;
  IGRint num_indent;
  IGRboolean print_super_class;
  IGRboolean print_full_format; 
)
{
  char space=' ', indent[GR_MAX_CHAR];
  PWresult result=PW_K_Success;

  if (num_indent)
    memset (indent, space, num_indent * sizeof (char));
  indent[num_indent] = '\0';

  pwPrintId (file, num_indent, my_id, OS);
  fprintf (file, "%s  NULL\n", indent);

  return (result);
}


method GRread
(
  FILE *file;
  IGRboolean read_super_class;
  IGRboolean read_full_format;
)
{
  char line[GR_MAX_CHAR], *token, whitespace[4]=" \n\t";
  PWresult result=PW_K_Success;

  /*
   * Assume the file is positioned to read this class's specific data.
   * In this override, the only data that can be read is NULL. This in
   * fact, leaves this object alone.
   */

  if (fgets (line, GR_MAX_CHAR, file))
  {
    token = strtok (line, whitespace);
    OnErrorState (strcmp (token, "NULL") != MATCH, result,
     SetError (PW_K_Pathway, PW_K_BadData), wrapup);
  }
  else
  {
    OnErrorState (TRUE, result, SetError (PW_K_Pathway, PW_K_EndOfData),
     wrapup);
  }

wrapup:
  PW_WrapupId (result, "EMsfprtread.I-GRread", my_id);
  return (result);
}

end implementation EMSsurface;
