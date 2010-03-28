class implementation ci_mac_def;


#define AS_DEBUG	/* debug pre-processor */

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method NDprint_root( struct GRmd_env *md_env ;
                    FILE       *stream )
{
  int         i;

  fprintf(stream,"\n//  feet definition ");
  for (i=0 ; i<me->feet_num; i++)
  {
  }

  fprintf(stream, 
    "\nsend ci_mac_def.ACplace( &suc, \"%s\",", me->macro_name );
  fprintf( stream, 
    "\n     %d, temp_names, temp_types,\n", me->tot_temp );
  fprintf(stream, 
  "\n       %d, temp_feet_index, temp_feet_names,\n", me->temp_feet_num );
  fprintf(stream, 
    "\n     %d, intern_feet_names, inter_feet_types\n", me->intern_feet_num );
  fprintf(stream, 
    "\n     %d, extern_feet_names, extern_feet_types\n", me->extern_feet_num );
  fprintf(stream, 
    "\nsend ci_mac_def.ACedit_macro(&suc,%d,%d,up,us,tstr,ds,map) to MACHDR;"
    ,me->tot_up, me->tot_temp);
  fprintf(stream, 
    "\nsend ACmac.ACremove_all(1) to MACHDR;");

  return(1);
}
end implementation ci_mac_def;
