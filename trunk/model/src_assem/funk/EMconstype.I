class implementation EMconstr;

#include <stdio.h>
#include <limits.h>
#include <sys/types.h>
#include <malloc.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "msdef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include <alloca.h>
#include "assemconstr.h"

extern GRclassid OPP_EMmate_class_id;
extern GRclassid OPP_EMalign_class_id;
extern GRclassid OPP_EMinsert_class_id;
extern GRclassid OPP_EMground_class_id;

int EMgetconstrtype (constr_grid, ptype)
struct GRid constr_grid;
unsigned int *ptype;
{
  GRclassid classid = 0;

  om$get_classid (objid = constr_grid.objid, 
  osnum = constr_grid.osnum, p_classid = &classid);

  if (om$is_ancestry_valid (subclassid = classid,
       superclassid = OPP_EMmate_class_id) == OM_S_SUCCESS)
    *ptype = MATE;
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_EMalign_class_id) == OM_S_SUCCESS)
    *ptype = ALIGN;
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_EMinsert_class_id) == OM_S_SUCCESS)
    *ptype = INSERT;
  else if (om$is_ancestry_valid (subclassid = classid,
            superclassid = OPP_EMground_class_id) == OM_S_SUCCESS)
    *ptype = GROUND;
  else
    *ptype = NULL_CONSTR;    

  return (EMS_S_Success);

}

end implementation EMconstr;

