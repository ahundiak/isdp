class implementation SKasptgrnd;

#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"
#include "emsdef.h"

from SKvariable import SKintdelete;

method GRgetobjinfo(long *msg; struct GRobj_info *info)
{
  OMuint count;
  OM_S_CHANSELECT chan_to_parents;

  *msg = MSSUCC;
 
  EMmake_chanselect (NDfather_father, &chan_to_parents);
  count = 0;
  om$get_channel_count (object = me, p_chanselect = &chan_to_parents,
                        count = &count);
  if (count)
  {
    ex$message ( buff = info->type, msgnumb = EMS_S_AssocGroundConstraint );
  }
  else
  {
    ex$message ( buff = info->type, msgnumb = EMS_S_GroundConstraint );
  }

  return OM_S_SUCCESS;
}

method debug()
{
  om$send (mode = OM_e_wrt_parent, msg = message SKasptgrnd.debug(),
   targetid = my_id);

  fprintf (stderr, "\tAspt inx : %d\n", ME.SKasptgrnd->asptinx);

  return (OM_S_SUCCESS);
}

method NDdisplay(int dp_type;enum GRdpmode pen;struct GRmd_env *env)
{
  return (OM_S_SUCCESS);
}

method ASreturn_go(struct GRid *go;short *mat_type;double *matrix)
{
  return (OM_S_SUCCESS);
}

/*

Name
  NDmove_to_root

Abstract
  Delete yourself and your underlying variable.
  
Synopsis

Description
  NDmove_to_root will be called when the parent ASsource object gets deleted.
  In this case, there is no need for me to exist.  Delete my SKptvar which
  will kill all the associated constraints.
  
Return Value

Notes

Index

Keywords
  associative,delete,ground

History
  09/01/93 : Rajiv Agrawal : created

 */

method NDmove_to_root (long *msg; struct GRid *src_grid;
		       struct GRmd_env *md_env)
{
  struct GRid     mgr;
  OM_S_CHANSELECT to_ptvars;
  
  mgr.osnum = OM_Gw_current_OS;
  om$send ( msg = message SKconstraint.SKgetmgr ( msg, &mgr.objid ), 
            targetid = my_id );

  /*
   * send a intdelete to the my variables
   */
  EMmake_chanselect (SKconstraint_to_variables, &to_ptvars);
  
  om$send ( msg = message SKvariable.SKintdelete(msg, NULL, md_env),
            p_chanselect = &to_ptvars);
  
  /*
   * Check if the profile split due to the above deletion.
   */
  SKsplit_profile ( msg, &mgr );
  
  return (OM_S_SUCCESS);  
}

end implementation SKasptgrnd;
