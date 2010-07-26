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
#include "exdef.h"
#include "exmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"

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
  FILE            *fet;
  char            line1 [DI_PATH_MAX], line [DI_PATH_MAX];
  int             i, count, status, nb_assoc;
  struct GRid     *grids = NULL, as_prov;
  GRspacenum      osnum;
  GRobjid         objid;
  struct GRmd_env md_env;

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
   * Generate a ppl program (graph printer) with those expressions
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
    ex$get_cur_mod ( id = &md_env.md_id.objid, osnum = &md_env.md_id.osnum );
    md_env.md_env.matrix_type = MAIDMX;
    for (i = 1; i < 15; i++)
      md_env.md_env.matrix [i] = 0.0;
    for (i = 0; i < 16; i += 5)
      md_env.md_env.matrix [i] = 1.0;

    asprinter_init ( &md_env, fet, 0 );

    /* make source with located objects */
    nb_assoc = 0;
    for (i = 0; i < count; i++)
    {
      status = as$make_source ( go_grid = grids [i],
        as_os = OM_Gw_current_OS, mod_env = &md_env, as_grid = &as_prov );
      if (status & 1) 
        grids [nb_assoc++] = as_prov;
    }

    /* Get the real roots of the associative elements */
    nd$get_graph ( p_root = grids, nb_root = nb_assoc );
    nd$get_list_in_graph ( acc_type = ND_ROOT, p_count = &count, size = count,
        list = grids );
    asprinter_exec_print ( count, grids );
  }

  /* end the graph printer */
  asprinter_end ();

  /* close the file */
  fclose ( fet );

  return OM_S_SUCCESS;
}

end implementation expression;
