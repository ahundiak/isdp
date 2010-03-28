class implementation expression;


#include <stdio.h>
#include <memory.h>
#include <limits.h>
#include <sys/types.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"
#include "expression.h"
#include "expmacros.h"

char read_line ( fet, line )
                 FILE *fet;
                 char *line;
/*
   This routine reads a line on the file specified by fet.  Lines starting
   with a '#' are skipped.
*/
{
  char not_eof, *ptr;

  do
  {
    ptr = line;
    do
     not_eof = fread ( ptr++, 1, 1, fet );
    while (not_eof && (*(ptr - 1) != '\n'));
  }
  while ((*line == '#') && *line && not_eof);
  *(ptr - 1) = '\0';

  return not_eof;
}


main ()
/*
   Basic test of associative expressions.
*/
{
  FILE        *fet;
  char        **lines = NULL, line1 [DI_PATH_MAX], line [DI_PATH_MAX];
  int         i, count, status;
  struct GRid *grids = NULL;
  GRspacenum  osnum;
  GRobjid     objid;

  /*
   * Read expressions from the input file (input/exp.create) and create those guys.
   */
  if (fet = fopen ( "input/exp.create", "r" ))
  {
    for (count = 0; read_line ( fet, line ); count++)
    {
      strcpy ( line1, line );
      status = exp$create ( exp_syntax = line, p_exp_id = &objid, p_osnum = &osnum );
      if (status & 1)
      {
        if (strcmp ( line, line1 ))
          fprintf ( stderr, "%s at line %d: input '%s' was modified into '%s'\n",
              __FILE__, __LINE__, line1, line );
        
        if (!(count % 32))
        {
          if (count)
            grids = (struct GRid *)realloc ( grids, (count + 32) * sizeof ( struct GRid ) );
          else
            grids = (struct GRid *)malloc ( 32 * sizeof ( struct GRid ) );

          if (!grids)
          {
            fprintf ( stderr, "%s at line %d: cannot malloc\n", __FILE__, __LINE__ );
            break;
          }
        }
        
        grids [count].osnum = osnum;
        grids [count].objid = objid;
      }
      else
        fprintf ( stderr, "%s at line %d: cannot create '%s'\n", __FILE__, __LINE__, line );
    }
    fclose ( fet );
  }
  else
    fprintf ( stderr, "%s at line %d: cannot open input/exp.create\n", __FILE__, __LINE__ );
  
  /*
   * Read expressions from the input file (input/exp.modify) and modify those guys
   */
  if (fet = fopen ( "input/exp.modify", "r" ))
  {
    for (i = 0; read_line ( fet, line ); i++)
    {
      strcpy ( line1, line );
      status = exp$modify ( exp_syntax = line, exp_id = grids [i].objid, osnum = grids [i].osnum );
      if (!(status & 1))
        fprintf ( stderr, "%s at line %d: cannot create '%s'\n", __FILE__, __LINE__, line );
      else
        if (strcmp ( line, line1 ))
          fprintf ( stderr, "%s at line %d: input '%s' was modified into '%s'\n", __FILE__, __LINE__, line1, line );
    }
    fclose ( fet );
  }
  else
    fprintf ( stderr, "%s at line %d: cannot open input/exp.modify\n", __FILE__, __LINE__ );

  /* 
   * As a final test, we dump the directory contents to the masterout file.
   */
  if (fet = fopen ( "output/masterout", "r" ))
  {
    fclose ( fet );
    fet = fopen ( "output/newout", "w" );
  }
  else
    fet = fopen ( "output/masterout", "w" );
  
  if (!fet)
    fprintf ( stderr, "CANNOT open masterout/newout\n" );
  else
  {
    status = di$find ( regexp = "*", ptr = &count, lines = &lines, options = OPT_TRAILER );
    if ((status != DIR_S_SUCCESS) || !count)
      fprintf ( stderr, "%s at line %d: error in find\n", __FILE__, __LINE__ );
    else
      for (i = 0; i < count; i++)
      {
        fprintf ( fet, "%s\n", lines [i] );
        free ( lines [i] );
      }

    free ( lines );
    
    fclose ( fet );
  }

  return OM_S_SUCCESS;
}

end implementation expression;
