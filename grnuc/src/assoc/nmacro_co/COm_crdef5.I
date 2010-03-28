class implementation COm_crdef;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "nddef.h"
#include "ndmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"


#define AS_DEBUG

from NDnode    import NDgive_structure;
from ci_mac_def import ACplace;
from GRvg import GRgetname;

COm_generate_name(name,prefix,size,index,type,obj)
char *name,*prefix;
int size,index,type;
struct GRid *obj;
/*.COm_generate_name*/
{
char exp_name[DI_PATH_MAX];
char *c,*strrchr();
long status,msg;
int prefix_len;


/*"prefix %s,size %d,index %d,type %x,obj %d %d\n",prefix,size,index,type,obj->objid,obj->osnum*/

prefix_len = strlen(prefix);
status = 0;
c = NULL;
if(type&parameter_generic)
 {
  status = di$untranslate(objid = obj->objid,
                          osnum = obj->osnum,
                          objname = exp_name);
  if(status&1) c = strrchr(exp_name,':');
 }
else
 {
  status = om$send(msg = message GRvg.GRgetname(&msg,exp_name),
		   senderid = NULL_OBJID,
  		   targetid = obj->objid,
                   targetos = obj->osnum);
  if(status&msg&1) c = strrchr(exp_name,':');
 }

if(c != NULL && strncmp(c,prefix,prefix_len))
 {
  strncpy(name,c+1,size);
  name[size-1] = '\0';
 }
else
 {
  sprintf(name,"%s%02d",prefix,index);
 }
/*"return name %s\n",name */

return(OM_S_SUCCESS);
}
end implementation COm_crdef;
