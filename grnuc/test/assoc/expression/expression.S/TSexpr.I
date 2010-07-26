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
#include "nddef.h"
#include "ndmacros.h"


from FIdirform  import update;

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
   Test of associative expressions.
*/
{
  FILE        *fet;
  char        **lines = NULL, line1 [DI_PATH_MAX], line [DI_PATH_MAX];
  char        exp_name [DI_PATH_MAX];
  int         i, count, status, mode;
  GRspacenum  osnum;
  GRobjid     objid;
  char *ptr,  *name_ptr;
  OM_S_OBJID  expr_id;
  OMuword     expr_osnum;
  double      expr_value;
  struct GRmd_env md_env;  
  /*
   * Read expressions from the input file (input/expr.test) and create those guys.
   */
  if (fet = fopen ( "input/expr.test", "r" ))
  {
    for (count = 0; read_line ( fet, line ); count++)
    {
      switch (line[0])
      {
        case '1': /* Create a new expression */

          ptr = &line[1];
          strcpy ( line1, ptr );
          status = exp$create ( exp_syntax = ptr, p_exp_id = &objid, p_osnum = &osnum );
          if (status & 1)
          {
            if (strcmp ( ptr, line1 ))
              fprintf ( stderr, "%s at line %d: input '%s' was modified into '%s'\n",
                  __FILE__, __LINE__, line1, ptr );
          }
          else
            fprintf ( stderr, "%s at line %d: cannot create '%s'\n", __FILE__, __LINE__, line );
    
          break;
          
        case '2':  /* Modify by name an existing expression */
          
          ptr = &line[1];
          name_ptr = exp_name;
          
          while (*ptr == ' ')
            ptr++;
            
          while (*ptr != ' ')
          {
            *name_ptr = *ptr;
            name_ptr++;
            ptr++;
          }
          *name_ptr = '\0';
          
          strcpy ( line1, ptr );
          status = exp$modify ( exp_syntax = ptr, exp_name = exp_name);
          if (!(status & 1))
            fprintf ( stderr, "%s at line %d: cannot create '%s'\n", __FILE__, __LINE__, line );
          else
            if (strcmp ( ptr, line1 ))
              fprintf ( stderr, "%s at line %d: input '%s' was modified into '%s'\n", __FILE__, __LINE__, line1, line );
          
          break;

        case '3':  /* Modify by objid an existing expression */          
          
          ptr = &line[1];
          name_ptr = exp_name;
          
          while (*ptr == ' ')
            ptr++;
            
          while (*ptr != ' ')
          {
            *name_ptr = *ptr;
            name_ptr++;
            ptr++;
          }
          *name_ptr = '\0';

          status = exp$translate (exp_name = exp_name, p_exp_id = &expr_id, p_osnum = &expr_osnum);
          if (!(status & 1))
            fprintf ( stderr, "%s at line %d: cannot access '%s'\n", __FILE__, __LINE__, exp_name);
          else
          {
            strcpy ( line1, ptr );
            status = exp$modify ( exp_syntax = ptr, exp_id = expr_id, osnum = expr_osnum);
            if (!(status & 1))
              fprintf ( stderr, "%s at line %d: cannot create '%s'\n", __FILE__, __LINE__, line );
            else
              if (strcmp ( ptr, line1 ))
                fprintf ( stderr, "%s at line %d: input '%s' was modified into '%s'\n", __FILE__, __LINE__, line1, line );
          }            
          break;

        case '4':  /* Delete an existing expression */          
          
          ptr = &line[1];
          name_ptr = exp_name;
          
          while (*ptr == ' ')
            ptr++;
            
          while (*ptr != ' ')
          {
            *name_ptr = *ptr;
            name_ptr++;
            ptr++;
          }
          *name_ptr = '\0';
      
          ex$get_cur_mod ( id = &md_env.md_id.objid, osnum = &md_env.md_id.osnum );
          md_env.md_env.matrix_type = MAIDMX;
          for (i = 1; i < 15; i++)
            md_env.md_env.matrix [i] = 0.0;
          for (i = 0; i < 16; i += 5)
            md_env.md_env.matrix [i] = 1.0;
                
          status = exp$delete (exp_name = exp_name, p_md_env = &md_env);
          if (!(status & 1))
            fprintf ( stderr, "%s at line %d: cannot delete '%s'\n", __FILE__, __LINE__, exp_name );

          break;
          
        case '5':  /* Create an expression by value */
          
          ptr = &line[1];
          name_ptr = exp_name;
          
          while (*ptr == ' ')
            ptr++;
            
          while (*ptr != ' ')
          {
            *name_ptr = *ptr;
            name_ptr++;
            ptr++;
          }
          *name_ptr = '\0';

          sscanf(ptr, "%lf", &expr_value);

          status = exp$create ( exp_name = exp_name, exp_value = expr_value, osnum = 2, 
                                p_exp_id = &objid, p_osnum = &osnum );
          if (!(status & 1))
            fprintf ( stderr, "%s at line %d: cannot create '%s'\n", __FILE__, __LINE__, line );
          
          break;
       
          
        case '6':  /* Create an expression when the LHS and RHS are given separately*/
                   /* Old style expressions, check for regression */
                   
          ptr = &line[1];
          name_ptr = exp_name;
          
          while (*ptr == ' ')
            ptr++;
            
          while (*ptr != ' ')
          {
            *name_ptr = *ptr;
            name_ptr++;
            ptr++;
          }
          *name_ptr = '\0';
          
          strcpy ( line1, ptr );
          status = exp$create ( exp_name = exp_name, exp_syntax = ptr, 
                                p_exp_id = &objid, p_osnum = &osnum );

          if (!(status & 1))
            fprintf ( stderr, "%s at line %d: cannot create '%s'\n", __FILE__, __LINE__, line );
          else
            if (strcmp ( ptr, line1 ))
              fprintf ( stderr, "%s at line %d: input '%s' was modified into '%s'\n", __FILE__, __LINE__, line1, line );
          
          break;


        case '7':  /* Enter a initial value for an existing expression */          
          
          ptr = &line[1];
          name_ptr = exp_name;

          while (*ptr == ' ')
            ptr++;
            
          while (*ptr != ' ')
          {
            *name_ptr = *ptr;
            name_ptr++;
            ptr++;
          }
          *name_ptr = '\0';

          sscanf(ptr, "%lf", &expr_value);

          status = exp$translate (exp_name = exp_name, p_exp_id = &expr_id, p_osnum = &expr_osnum);
          if (!(status & 1))
            fprintf ( stderr, "%s at line %d: cannot access '%s'\n", __FILE__, __LINE__, exp_name);
          else
          {
             status = om$send(msg = message expression.put_value(expr_value),
                              senderid = NULL_OBJID,
                 	        targetos = expr_osnum, 
                 	        targetid = expr_id);
             if ( ( ! ( status & 0x00000001 ) ) ) 
             {
               fprintf (stderr,  "\nError at line %d of the file %s :\n" , __LINE__, __FILE__ ); 
             }            

             status = om$send(msg = message expression.NDchange_node( NULL ),
                              senderid = NULL_OBJID,
                 	        targetos = expr_osnum, 
                 	        targetid = expr_id);
             if ( ( ! ( status & 0x00000001 ) ) ) 
             { 
               printf ( "\nError at line %d of the file %s :\n" , __LINE__, __FILE__ ); 
             }
          }
          break;

        case '8':  /* Execute the batch */

          nd$mod_batch ( request = ND_INQ, p_ret_mode = &mode );
          if (mode == ND_IMMEDIATE)
            nd$exec_batch ();
          break;          
      }
    }
    fclose ( fet );
   }
   else
     fprintf ( stderr, "%s at line %d: cannot open input/expr.test\n", __FILE__, __LINE__ );


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
