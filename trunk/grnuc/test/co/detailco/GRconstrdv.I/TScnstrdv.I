class implementation GRdrawview;

#include <stdio.h>
#include <memory.h>
#include <limits.h>
#include <sys/types.h>
#include "msdef.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "exdef.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igrdp.h"
#include "DEso.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"
#include "refdef.h"
#include "ref.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

extern DEcheck_display();
extern TSsetGraphicsATPflag();

main ()
{
  long              msg;
  int               i;
  struct GRmd_env   md_env;
  struct GRhesym    visible_symbology;
  unsigned short    properties;
  unsigned int      ref_properties;
  struct IGRdisplay display;
  struct IGRlbsys   lbsys;
  short             level;
  int               orientation;
  struct GRrf_info  rf_info;
  IGRmatrix         rotation;
  IGRpoint          origin;
  struct GRid       dv_id;
  struct GRid       cs_id;
  FILE              *fet;
      
  TSsetGraphicsATPflag ( 0 );

  /* this test routine requires a reference file called part.dgn */
  if (fet = fopen ( "part.dgn", "r" ))
    fclose ( fet );
  else
  {
    fprintf ( stderr, "%s at line %d: no part.dgn file\n", __FILE__, __LINE__ );
    return OM_E_ABORT;
  }
  
  ex$get_cur_mod ( id = &md_env.md_id.objid, 
     osnum = &md_env.md_id.osnum );
  md_env.md_env.matrix_type = MAIDMX;
  for (i = 0; i < 16; i++)
    md_env.md_env.matrix [i] = 0.0;
  md_env.md_env.matrix [0] = 1.0;
  md_env.md_env.matrix [5] = 1.0;
  md_env.md_env.matrix [10] = 1.0;
  md_env.md_env.matrix [15] = 1.0;

  /* we set the visible edge symbology to co=red/ls=1/wt=2 */
  visible_symbology.flags = 0;
  visible_symbology.color = 2;
  visible_symbology.style = 1;
  visible_symbology.weight = 2;  
  gr$put_visible_edge_sym ( buffer = &visible_symbology );
  
  /* we attach 2 drawing views and one reference file */
  properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  display.color = 1;
  display.style = 0;
  display.weight = 0;
  level = 0;
  orientation = 0;
  rf_info.filename = "part.dgn";
  rf_info.named_view = "iso";
  rf_info.clip_poly = NULL;
  rf_info.prism_classname = NULL;
  rf_info.description = NULL;
  ref_properties = GRRF_IS_READ_ONLY;
  rf_info.ref_properties = &ref_properties;
  rf_info.scale = "1";
  
  for (i = 0; i < 16; i++)
    rotation [i] = 0.0;
  rotation [0] = rotation [5] = rotation [10] = rotation [15] = 1.0;
  origin [0] = 0.0;  
  origin [1] = 0.0;  
  origin [2] = 0.0;  
  GRconstruct_dv ( &msg, &md_env, properties, &display, level, NULL, "", orientation, 
                   &rf_info, "GRdrawview", rotation, origin, "1", &dv_id, &cs_id );
  origin [1] = 5.0;  
  GRconstruct_dv ( &msg, &md_env, properties, &display, level, NULL, "", orientation, 
                   &rf_info, "GRdrawview", rotation, origin, "1", &dv_id, &cs_id );
  origin [1] = 10.0;  
  GRconstruct_dv ( &msg, &md_env, properties, &display, level, NULL, "", orientation, 
                   &rf_info, "GRdrawview", rotation, origin, "1", &dv_id, &cs_id );

  lbsys.matrix [0] = 1.0; lbsys.matrix [1] = 0.0; lbsys.matrix [2] = 0.0;
  lbsys.matrix [3] = 0.0; 
  lbsys.matrix [4] = 0.0; lbsys.matrix [5] = 1.0; lbsys.matrix [6] = 0.0; 
  lbsys.matrix [7] = 15.0; 
  lbsys.matrix [8] = 0.0; lbsys.matrix [9] = 0.0; lbsys.matrix [10] = 1.0; 
  lbsys.matrix [11] = 0.0; 
  lbsys.matrix [12] = 0.0; lbsys.matrix [13] = 0.0; lbsys.matrix [14] = 0.0; 
  lbsys.matrix [15] = 1.0;

  GRattach_file ( &msg, "part.dgn", &md_env, &display, 0, 0, "iso", "1", &lbsys );
    
  /* we display */
  TSsetGraphicsATPflag ( 1 );
  DEcheck_display ();
  
  return OM_S_SUCCESS;  
}


end implementation GRdrawview;
