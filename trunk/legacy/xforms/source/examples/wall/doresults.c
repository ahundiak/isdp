/*  void do_results()
 *
 *  This routine will be called once immediately before
 *  exiting.  It will write the resulting values out
 *  to a file called wall.out.  The values for the
 *  the gadgets have been put in a structure (defined
 *  in ex1.h) called wall.
 */

#include <stdio.h>
#include <FI.h>
#include <FIdyn.h>
#include "ex1.h"
#include "ex1gvare.h"


void do_results()
{
  FILE *wall_file;

/*
 *  Open the file for writing and check for errors.
 */
  wall_file = fopen( "wall.out", "w" );
  if ( wall_file == (FILE *)0 )
    return;
/*
 *  Print the values the values from the wall structure
 *  in formatted ascii.
 */
  fprintf( wall_file, "Description of wall design\n\n" );
  fprintf( wall_file, "  name of wall is %s\n", wall.name );
  fprintf( wall_file, "  dimensions of wall are: length = %lf, height = %lf\n",
           wall.length, wall.height );
  fprintf( wall_file, "  style of door is %d with lock of %d\n",
           wall.door_style, wall.lock );
  fprintf( wall_file, "  style of window is %d\n", wall.window_style );

/*
 *  Close the output file.
 */
  fclose( wall_file );

}
