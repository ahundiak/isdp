#include <stdio.h>
#include <stdarg.h>
#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/printerr.h"
#include "PWapi/errlogfile.h"
#include "PWapi/strfunc.h"

/*
  DESCRIPTION

  The following functions get the strings corresponding to portions of the
  error code - subsystem, code, and the codetype. Another function, the
  more typically used function, is the one defined later in this file,
  which returns the entire concatenated string corresponding to the 
  error code.

  These functions must be kept up-to-date w.r.t to the tables (found
  in include files) that contain the sub-codes. The return values of these
  functions is the number of characters in the string being returned.
*/
int pwGetSubsysString
(
  unsigned int holder,
  char *str
)
{
  switch (GetSubsys (holder))
  {
    case PW_K_Pathway:
      strcpy (str, "Pathway");
      break;

    case PW_K_Trimming:
      strcpy (str, "Trimming");
      break;

    case PW_K_Orientation:
      strcpy (str, "Orientation");
      break;

    case PW_K_PtLocation:
      strcpy (str, "PtLocation");
      break;

    case PW_K_PathwayMath:
      strcpy (str, "PathwayMath");
      break;

    case PW_K_BspMath:
      strcpy (str, "BspMath");
      break;

    case PW_K_OM:
      strcpy (str, "OM");
      break;

    case PW_K_EMS:
      strcpy (str, "EMS");
      break;

    case PW_K_MessageString:
      strcpy (str, "MessageString");
      break;

    default:
      strcpy (str, "Unknown System");
  }

  return (strlen (str));
}

int pwGetErrCodeString
(
  unsigned int holder,
  char *str
)
{
  switch (GetCode (holder))
  { 
    case PW_K_Nothing:
      strcpy (str, "");
      break;

    case PW_K_DynamicMemory:
      strcpy (str, "Dynamic Memory");
      break;

    case PW_K_Interrupt:
      strcpy (str, "Interrupt");
      break;

    case PW_K_Internal:
      strcpy (str, "Internal");
      break;

    case PW_K_NotImplemented:
      strcpy (str, "Not Implemented");
      break;

    case PW_K_Memory:
      strcpy (str, "Memory");
      break;

    case PW_K_InvalidArg:
      strcpy (str, "Invalid Argument");
      break;

    case PW_K_EndOfData:
      strcpy (str, "End Of Data");
      break;

    case PW_K_Sequence:
      strcpy (str, "Sequence");
      break;

    case PW_K_Close:
      strcpy (str, "Close");
      break;

    case PW_K_Open:
      strcpy (str, "Open");
      break;

    case PW_K_Unique:
      strcpy (str, "Unique");
      break;

    case PW_K_Ambiguous:
      strcpy (str, "Ambiguous");
      break;

    case PW_K_Cycle:
      strcpy (str, "Cycle");
      break;

    case PW_K_Mixture:
      strcpy (str, "Mixture");
      break;

    case PW_K_Modified:
      strcpy (str, "Modified");
      break;

    case PW_K_UnModified:
      strcpy (str, "Not Modified");
      break;

    case PW_K_Found:
      strcpy (str, "Found");
      break;

    case PW_K_NotFound:
      strcpy (str, "Not Found");
      break;

    case PW_K_Bounds:
      strcpy (str, "Bounds");
      break;

    case PW_K_Coincident:
      strcpy (str, "Coincident");
      break;

    case PW_K_Degenerate:
      strcpy (str, "Degenerate");
      break;

    case PW_K_Planar:
      strcpy (str, "Planar");
      break;

    case PW_K_NonPlanar:
      strcpy (str, "Non-Planar");
      break;

    case PW_K_Orient:
      strcpy (str, "Orientation");
      break;

    case PW_K_NonOrient:
      strcpy (str, "No Orientation");
      break;

    case PW_K_Intersect:
      strcpy (str, "Intersection");
      break;

    case PW_K_NoIntersect:
      strcpy (str, "No Intersection");
      break;

    case PW_K_Tolerance:
      strcpy (str, "Tolerance");
      break;

    default:
      strcpy (str, "Unknown Error Code");
  }

  return (strlen (str));
}

int pwGetErrCodeTypeString
(
  unsigned int holder,
  char *str
)
{
  switch (GetCodeType (holder))
  {
    case PW_K_Success:
      strcpy (str, "Success");
      break;

    case PW_K_Information:
      strcpy (str, "Information");
      break;

    case PW_K_Error:
      strcpy (str, "Error");
      break;

    case PW_K_Warning:
      strcpy (str, "Warning");
      break;

    case PW_K_Fatal:
      strcpy (str, "Fatal");
      break;

    default:
      strcpy (str, "Unknown Error Code Type");
  }

  return (strlen (str));
}

/*
  DESCRIPTION

  This function outputs the ASCII string corresponding to the code
  input. It puts together the 3 pieces of the code and returns a single
  string. Certain 'foreign' sub-system's detailed codes are not known here
  and hence that part of the error string is skipped.
*/
int pwGetErrorString 
(
  PWresult code,
  char *errstr
)
{
  char str[PW_K_MaxCharOnLine+1];
  int subsys;

  pwGetSubsysString (code, str);
  strcpy (errstr, str);

  pwGetErrCodeTypeString (code, str);
  strcat (errstr, " - ");
  strcat (errstr, str);

  subsys = GetSubsys (code);
  if (! (subsys == PW_K_OM || 
         subsys == PW_K_EMS ||
         subsys ==  PW_K_MessageString))
  {
    pwGetErrCodeString (code, str);
    if (strlen (str))
    {
      strcat (errstr, " - ");
      strcat (errstr, str);
    }
  }

  return (strlen (errstr));
}

/*
  DESCRIPTION

  Function used to print the string corresponding to the condition code to
  a given file. The file's pointer is input. If a NULL is passed in for the
  file-pointer, this function will print to stderr. Returns the number of
  characters printed. In the case of 'foreign' sub-systems, the full
  functionality of this function cannot be achieved. In that case, we do
  the best we can.
*/
int pwPrintCode 
(
  FILE *fp,
  PWresult code
)
{
  char errstr[PW_K_MaxCharOnLine+1];
  int len=0, subsys;
  
  subsys = GetSubsys (code);
  if (subsys == PW_K_OM && (fp == stderr || fp == stdout))
  {
    som_report_error (code);
  }
  else if (subsys == PW_K_EMS || subsys == PW_K_MessageString)
  {
    EFprintcode (fp, code);
    fprintf (fp, "\n");
  }
  else
  {
    len = pwGetErrorString (code, errstr);
    if (fp)
      fprintf (fp, "%s\n", errstr);
    else
      fprintf (stderr, "%s\n", errstr);
  }

  return (len);
}

/*
  DESCRIPTION

  The following set of functions used by the wrapper macros to print
  ASCII information into the appropriate I/O streams. Besides the code, 
  these function are provided with additional information which gets
  printed as well. 


  NOTES

  Each of these functions inputs the code and an arbitrary string that
  is typically the name of the function where this code was established.
  In addition, some of these functions take in object-id(s) and 
  algebraic values.
*/
void pwPrintError 
(
  PWresult code,
  char *str
)
{
  if (code)
  {
    pwPrintCode (stderr, code);
    if (pwGetErrLogFile())
      pwPrintCode (pwGetErrLogFile(), code);
  }

  fprintf (stderr, "%s\n", str);
  if (pwGetErrLogFile())
    fprintf (pwGetErrLogFile(), "%s\n", str);

  fprintf (stderr, "\n");
  if (pwGetErrLogFile())
    fprintf (pwGetErrLogFile(), "\n");

  return;
}

void pwPrintErrorId 
(
  PWresult code,
  char *str, 
  PWobjid id
)
{
  if (code)
  {
    pwPrintCode (stderr, code);
    if (pwGetErrLogFile())
      pwPrintCode (pwGetErrLogFile(), code);
  }

  fprintf (stderr, "%s - ", str);
  fprintf (stderr, "%d\n", id);
  if (pwGetErrLogFile())
  {
    fprintf (pwGetErrLogFile(), "%s - ", str);
    fprintf (pwGetErrLogFile(), "%d\n", id);
  }

  fprintf (stderr, "\n");
  if (pwGetErrLogFile())
    fprintf (pwGetErrLogFile(), "\n");

  return;
}

void pwPrintErrorIdVal 
(
  PWresult code,
  char *str,
  PWobjid id, 
  double val
)
{
  if (code)
  {
    pwPrintCode (stderr, code);
    if (pwGetErrLogFile())
      pwPrintCode (pwGetErrLogFile(), code);
  }

  fprintf (stderr, "%s - ", str);
  fprintf (stderr, "%d (%7.12lf)\n", id, val);
  if (pwGetErrLogFile())
  {
    fprintf (pwGetErrLogFile(), "%s - ", str);
    fprintf (pwGetErrLogFile(), "%d (%7.12lf)\n", id, val);
  }

  fprintf (stderr, "\n");
  if (pwGetErrLogFile())
    fprintf (pwGetErrLogFile(), "\n");

  return;
}

void pwPrintErrorIdId 
(
  PWresult code,
  char *str,
  PWobjid id1,
  PWobjid id2
)
{
  if (code)
  {
    pwPrintCode (stderr, code);
    if (pwGetErrLogFile())
      pwPrintCode (pwGetErrLogFile(), code);
  }

  fprintf (stderr, "%s - ", str);
  fprintf (stderr, "%d and %d\n", id1, id2);
  if (pwGetErrLogFile())
  {
    fprintf (pwGetErrLogFile(), "%s - ", str);
    fprintf (pwGetErrLogFile(), "%d and %d\n", id1, id2);
  }

  fprintf (stderr, "\n");
  if (pwGetErrLogFile())
    fprintf (pwGetErrLogFile(), "\n");

  return;
}

/*
  ABSTRACT 

  Function that takes in a string (filename) and an int (line-number) and
  prints it to the appropriate output(s) streams. Used in the "error" check
  macros.
*/

void pwPrintFileLine
(
  char *filename,
  int linenum
)
{
  if (pwGetDebugLevel() >= PW_K_DebugWarning)
  {
    fprintf (stderr, "File: %s -- Line: %d\n", filename, linenum);
    if (pwGetErrLogFile())
      fprintf (pwGetErrLogFile(), "File: %s -- Line: %d\n", filename, linenum);
  }
  return;
}

/*
  DESCRIPTION

  "printf"-like function to be used to output debug statements in the code.
  This call will have an affect only if the current system debug level is 
  greater than or equal to the level specified as an argument to this 
  function (eg: debug-level set to PW_K_DebugWarn or PW_K_DebugTrace). 
  "DebugWarn" is typically used to warn of weird conditions encountered (eg:
  non-typical degenerate segments, topological mismatches, etc). "DebugTrace"
  is typically used to enhance the trace capability (eg: number of
  intersections, residual error, etc).

  The second argument is a "printf" format string (eg: "Sfs: %d and %d prob\n")
  and the third 'argument' is a list of variable arguments, precisely
  as in the regular "printf" call (eg: objid1, objid2);

  
  NOTES

  Currently, only three types of formats are accepted -- %d, %lf and %s. And
  these must be present in the format string exactly as such (without the 
  number of precision digits, etc). Further, these must be preceded and 
  succeeded by atleast one blank space. This limitation is in-place since
  an unsophisticated 'token' checker is being used. It can be removed if
  needed, later on.
*/

void pwDebugLine
(
  int debug_level,
  char *format,
  ...
)
{
  PWboolean more_fields;
  char token[PW_K_MaxStringLen+1];
  int num_fields=0;
  int store_int;
  double store_double;
  char *store_str;
  va_list args_stack;

  if (pwGetDebugLevel() >= debug_level)
  {
    va_start (args_stack, format);
    do
    {
      if (more_fields = pwFieldInStr (num_fields++, format, token))
      {
        if (strcmp (token, "%d") == STRING_MATCH)
        {
          store_int = va_arg (args_stack, int);
          fprintf (stderr, " %d", store_int);
          if (pwGetErrLogFile())
            fprintf (pwGetErrLogFile(), " %d", store_int);
        }
        else if (strcmp (token, "%lf") == STRING_MATCH)
        {
          store_double = va_arg (args_stack, double);
          fprintf (stderr, " %lf", store_double);
          if (pwGetErrLogFile())
            fprintf (pwGetErrLogFile(), " %lf", store_double);
        }
        else if (strcmp (token, "%s") == STRING_MATCH)
        {
          store_str = va_arg (args_stack, char *);
          fprintf (stderr, " %s", store_str);
          if (pwGetErrLogFile())
            fprintf (pwGetErrLogFile(), " %s", store_str);
        }
        else
        {
          fprintf (stderr, " %s", token);
          if (pwGetErrLogFile())
            fprintf (pwGetErrLogFile(), " %s", token);
        }
      }
    }
    while (more_fields);
    va_end (args_stack);

    fprintf (stderr, "\n", token);
    if (pwGetErrLogFile())
      fprintf (pwGetErrLogFile(), "\n", token);
  }
  return;
}
