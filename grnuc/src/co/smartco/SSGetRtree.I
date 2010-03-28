/*

Name
  SSGetRtree.I

Description

Notes


 */
class implementation Root;

#include <math.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"


/*

Name
  SSGetRtree

Abstract
 Returns the range tree and module grids

Synopsis
  void SSGetRtree ( p_tree, p_mod )

Description

Return Value
 none

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

void SSGetRtree ( p_tree, p_mod )
struct GRid *p_tree	/* The GRid of the range tree			OUT */;
struct GRid *p_mod	/* The GRid of the module			OUT */;
{
  OM_S_CHANSELECT     chan;
  OM_S_OBJECT_LINKAGE list [1];
  unsigned int        count;
  
  om$make_chanselect ( channame = "module.primary", p_chanselect = &chan );
  ex$get_cur_mod ( id = &p_mod->objid, osnum = &p_mod->osnum );
  om$get_channel_objects ( osnum = p_mod->osnum, objid = p_mod->objid,
    count = &count, size = 1, p_chanselect = &chan, list = list );
  p_tree->osnum = list [0].osnum;
  p_tree->objid = list [0].S_objid;
}

end implementation Root;
