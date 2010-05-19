/*
 *	File dloaded in VDS.  Suppress error message during display of
 *	collectors (during navigate)  - rmn
 */

class implementation COm_crdef;

#include <sys/param.h>
#include "OMmacros.h"
#include "AS_status.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "exmacros.h"

#ifdef NO
char *COm_crdef_form_ptr = NULL;
char *COm_crdef_option_ptr = NULL;
int COm_crdef_nb_command = 0; 

static int x_memo = -1,
       y_memo = -1,
       s_memo = -1;

#endif

from GRvg import GRgetobjinfo;
from GRgraphics import GRdisplay;
from NDnode import ASreturn_go;
from NDmacro import ACreturn_foot;
from expression import list;

COm_hilite_elem(obj,type,dp_mode,md_env)
struct GRid *obj;
int type;
enum GRdpmode dp_mode;
struct GRmd_env *md_env;

/*.COm_hilite_elem*/
{
long msg,status;
struct GRobj_info info;
char formula[MAXPATHLEN];
struct GRmd_env display_env;
struct GRid display_id;

/*"hilite element %d type %d\n",obj->objid,type*/

  display_id = *obj;
  display_env = *md_env;

if(!(type & parameter_generic) || (type == ~0))
 {
  status = om$send(msg = message GRvg.GRgetobjinfo(&msg, &info),
		   senderid = NULL_OBJID,
                   targetid = obj->objid,
                   targetos = obj->osnum);

  om$send(msg = message NDmacro.ACreturn_foot(&msg,"",&display_id,
					        &display_env.md_env.matrix_type,
					         display_env.md_env.matrix),
		   senderid = NULL_OBJID,
                   targetid = obj->objid,
                   targetos = obj->osnum);
		   
  if(!(status&1)) status = om$send(msg = message GRvg.GRgetobjinfo(&msg, &info),
		   senderid = NULL_OBJID,
                   targetid = display_id.objid,
                   targetos = display_id.osnum);
  if((status&msg&1)) UI_status(info.type);
	      
  dp_mode = GRhdo;
/*" display obj %d %d\n",display_id.objid,display_id.osnum */
/*" md_id %d %d\n",display_env.md_id.objid,display_env.md_id.osnum */
  status = om$send(msg = message GRgraphics.GRdisplay (&msg,
					        &display_env.md_env.matrix_type,
					         display_env.md_env.matrix,
					&dp_mode,&display_env.md_id),
		   senderid = NULL_OBJID,
                   targetid = display_id.objid,
                   targetos = display_id.osnum);
/*
  as$status();
*/
 }
else
 {
  /* To beheave properly with pretend */
  status = om$send(msg = message NDnode.ASreturn_go(&display_id,
                                                &display_env.md_env.matrix_type,
                                                 display_env.md_env.matrix),
                   senderid = NULL_OBJID,
                   targetid = obj->objid,
                   targetos = obj->osnum);
  if(!(status&1)) display_id = *obj;

  status = om$send(msg = message GRgraphics.GRdisplay (&msg,
					        &display_env.md_env.matrix_type,
					         display_env.md_env.matrix,
					&dp_mode,&display_env.md_id),
		   senderid = NULL_OBJID,
                 targetid = display_id.objid,
                 targetos = display_id.osnum);

  status=om$send(msg = message expression.list(formula),
		 senderid = NULL_OBJID,
                 targetid = display_id.objid,
                 targetos = display_id.osnum);
  if(status &1) UI_status(formula);
 }
 return(status); 
}

end implementation COm_crdef;
