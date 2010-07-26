class implementation GRreffile;

#include <stdio.h>
#include <memory.h>
#include <limits.h>
#include <sys/types.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "DEso.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"
#include "refdef.h"
#include "ref.h"

#include "DEsomacros.h"


from GRcontext import GRgetmodule_env;


main ()
{
  long              msg;
  int               status;
  char              my_file [DI_PATH_MAX];
  struct GRmd_env   md_env;
  struct IGRdisplay symb;
  struct IGRlbsys   lbsys;
  OMuword           osnum;
  
  /* we need to create the reference file (save the current file as f1) */
  ex$filename ( name = my_file, len = DI_PATH_MAX );
  status = ex$save_module ( ftype = EX_visible,
                            filename = my_file, 
                            newfilename = "f1" ) ;
  if (status != 1)
  {
    fprintf ( stderr, "CANNOT save module as f1\n" );
    return 0;
  }
  
  /* first attach the reference file */
  ex$get_cur_mod ( id = &md_env.md_id.objid, 
                   osnum = &md_env.md_id.osnum );
  md_env.md_env.matrix_type = MAIDMX;
  symb.color = 0;
  symb.style = 0;
  symb.weight = 0;
  lbsys.matrix [0] = 1.0; lbsys.matrix [1] = 0.0; lbsys.matrix [2] = 0.0;
  lbsys.matrix [3] = -3600.0; 
  lbsys.matrix [4] = 0.0; lbsys.matrix [5] = 1.0; lbsys.matrix [6] = 0.0; 
  lbsys.matrix [7] = 1300.0; 
  lbsys.matrix [8] = 0.0; lbsys.matrix [9] = 0.0; lbsys.matrix [10] = 1.0; 
  lbsys.matrix [11] = 0.0; 
  lbsys.matrix [12] = 0.0; lbsys.matrix [13] = 0.0; lbsys.matrix [14] = 0.0; 
  lbsys.matrix [15] = 1.0;
  
  GRattach_file ( &msg, NULL, "f1", &md_env, &symb, 0, 0, "window", "1", &lbsys );

  /* check the reference file */
  osnum = 3;
  GRcheckref ( &msg, NULL, NULL, NULL, &osnum );
  if (msg != MSSUCC)
    printf ( "%s @ line %d: GRcheckref problem\n", __FILE__, __LINE__ );

  /* check the module */
  GRcheckref ( &msg, NULL, NULL, NULL, &(md_env.md_id.osnum) );
  if (msg == MSSUCC)
    printf ( "%s @ line %d: GRcheckref problem\n", __FILE__, __LINE__ );
  
  unlink ( "f1" );

  return 1;
}


end implementation GRreffile;

