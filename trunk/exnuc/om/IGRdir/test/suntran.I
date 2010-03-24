class implementation Root;

#include <stdio.h>
#include <time.h>
#include "OMprimitives.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMminimum.h"

suntran ()
{
    FILE       *fet;
    DIobjid     objid;
    DIspacenum  osnum;
    DIchar      *path,
		line [500];

    di$cd ( dirname = ":" );

    rm_minus_r ( ":transient" );

    /* build directory structure using mkdir_dir */
    if ( fet = fopen("in/smkdir.in","r") )
    {
      while ( read_line ( fet, line ))
        mkdir_dir ( line );

      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/smkdir.in\n" );

    di$cd ( dirname = ":transient", p_osnum = &osnum );

    om$construct( osnum = osnum, classname = "dummy", p_objid = &objid ); 

    /* add names using addname */
    if ( fet = fopen("in/saddname.in","r") )
    {
      while ( read_line ( fet, line ))
        addname ( line, objid );

      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/saddname.in\n" );


   
    /* get the path for untranslate */
    if ( fet = fopen("in/spath.in","r") )
    {
     while(read_line ( fet, line ))
      {
        if ( line[0] == '\0' )
          path = NULL;
        else
          path = line;

        suntrans ( objid, osnum, path );
      }
      fclose ( fet );
    }
    else
      fprintf ( stderr, "CANNOT open in/spath.in\n" );


  return DIR_S_SUCCESS;
}

end implementation Root;
