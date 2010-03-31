/* -----------------
 * FOR EMS 4.0
 * Creation : Sanjay
 * -----------------
 */ 
class implementation Root;

#include "math.h"
#include "values.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "ex.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "emsdattyp.h" 
#include "EMSmsgdef.h"  
#include "EMSlogic.h"
#include "OMprimitives.h"
#include "OMmacros.h"    
#include "emserr.h"                    
#include "emsinterdef.h"
#include "EMSprop.h"
#include "dpmacros.h"
#include "emscvexten.h"
#include "emsfeaopts.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "emsmacros.h"

#include "addrmopts.h"
#include "addprot.h"

/* Imports */
from GRvg         import GRgetrang, GRdetplane, GRgeomprops, GRpostabsg;
from GRgraphics   import GRcopy, GRxform, GRdelete;
from GRconnector  import GRdisconn, GRrigidconn;

/*
 * Function for GRgraphics.GRcopy
 */
IGRboolean  CopyObject(
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
GRobjid         *copyid)
{
  IGRlong  sts=OM_S_SUCCESS, msg=EMS_S_Success;

  sts = om$send( msg = message GRgraphics.GRcopy( &msg, env, env, copyid ),
                 senderid = id,
                 targetid = id,
                 targetos = os );
  if( !(1&sts&msg) )
    return FALSE;
  else
    return TRUE;
}

/*
 * Function for GRgraphics.GRxform
 */
IGRboolean XformObject(
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
IGRshort        *matrix_type,
IGRdouble       *matrix,
GRobjid         *xformid)
{
  IGRlong  sts=OM_S_SUCCESS, msg=EMS_S_Success;

  sts = om$send( msg = message GRgraphics.GRxform( &msg, env, matrix_type,
                               matrix, xformid ),
                 senderid = id,
                 targetid = id,
                 targetos = os );
  if( !(1&sts&msg) )
    return FALSE;
  else
    return TRUE;
}

/*
 * Function for GRvg.GRgeomprops
 */
IGRboolean GetObjectGeomProps(
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
struct GRprops  *props )
{
  IGRlong  sts=OM_S_SUCCESS, msg=EMS_S_Success;

  sts = om$send( msg = message GRvg.GRgeomprops( &msg, 
                                    &env->md_env.matrix_type,
                                    env->md_env.matrix, props ),
                 senderid = id,
                 targetid = id,
                 targetos = os );
  if( !(1&sts&msg) )
    return FALSE;
  else
    return TRUE;
}

/*
 * Function for GRvg.GRgetrang
 */
IGRboolean GetObjectRange(
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
IGRdouble       *range )
{
  IGRlong     sts=OM_S_SUCCESS, msg=EMS_S_Success;
  IGRboolean  world=TRUE;

  sts = om$send( msg = message GRvg.GRgetrang( &msg, &env->md_env.matrix_type, 
                               env->md_env.matrix, &world, range ),
                 senderid = id,
                 targetid = id,
                 targetos = os );
  if( !(1&sts&msg) )
    return FALSE;
  else
    return TRUE;

}

/*
 * Function for GRvg.GRdetplane
 */
IGRboolean GetCvOrSfPlane( 
GRobjid         id,
OMuword         os,
struct GRmd_env *env,
struct IGRplane *plane )
{
  IGRlong     sts=OM_S_SUCCESS, msg=EMS_S_Success;

  sts = om$send( msg = message GRvg.GRdetplane( &msg, &env->md_env.matrix_type,
                               env->md_env.matrix, plane ),
                 senderid = id,
                 targetid = id,
                 targetos = os );
  if( !(1&sts&msg) )
    return FALSE;
  else
    return TRUE;
}


/*
 * GRdelete DeleteObject()
 */
IGRboolean DeleteObject(
GRobjid         *obj,
struct GRmd_env *env
)
{
  GRobjid mdid;
  IGRlong loc_msg=EMS_S_Success;
  IGRint sts=OM_S_SUCCESS;

  if(*obj != NULL_OBJID) {
    mdid = env->md_id.objid;
    // env->md_id.objid = NULL_OBJID;
    sts = om$send (msg = message GRgraphics.GRdelete(&loc_msg, env),
                   senderid = *obj,
                   targetid = *obj,
                   targetos = env->md_id.osnum);
    env->md_id.objid = mdid;
    *obj = NULL_OBJID;
  }

  if(!(1&sts&loc_msg))
    return FALSE;
  else
    return TRUE;
}

IGRint GetObjectNumCompsOnChannel
(
GRobjid          id,
OMuword          os,
OM_S_CHANSELECT  *to_components
)
{
  IGRuint  num=0;
  IGRlong  sts, msg;

  sts = om$get_channel_count (osnum = os,
                              objid = id,
                              p_chanselect = to_components,
                              count = &num);
  if(!(sts&1))
    num = 0;

  return num;    
}

IGRboolean GetObjectCompsOnChannel
(
GRobjid          id,
OMuword          os,
IGRint           num,
OM_S_CHANSELECT  *to_components,
GRobjid          *comps
)
{
  IGRint               i; 
  IGRuint              tnum=0;
  IGRlong              sts;
  OM_S_OBJECT_LINKAGE  *list=NULL;

  list = (OM_S_OBJECT_LINKAGE *) alloca (num * sizeof(OM_S_OBJECT_LINKAGE));
  if(!list)
    return FALSE;

  sts = om$get_channel_objects (objid = id, osnum = os,
                                p_chanselect = to_components,
                                count = &tnum,
                                size = num, list = list );
  if(!(1&sts) || (num != tnum))
    return FALSE; 

  for(i=0; i<num; i++)
    comps[i] = list[i].S_objid;

  return TRUE;
}

GRobjid GetObjectAtIndexOnChannel
(
GRobjid          id,
OMuword          os,
IGRint           index,
OM_S_CHANSELECT  *to_components
)
{ 
  IGRlong              sts=OM_S_SUCCESS;
  GRobjid              retid;
  OMuword              retos;

  sts = om$get_objid_at_index (objid = id, osnum = os, 
                               index = index, 
                               objidaddr = &retid, osnumaddr = &retos,
                               p_chanselect = to_components);
  if (!(sts &1))
    return NULL_OBJID;
  else
    return retid; 
}

IGRint GetObjectIndexOnChannel
(
GRobjid   id,
OMuword   os,
GRobjid   fromid,
GRobjid   fromos,
OM_S_CHANSELECT  *to_components
)
{
  IGRlong  sts=OM_S_SUCCESS;
  IGRuint  index;

  sts = om$get_index (objid_c = fromid, osnum_c = fromos, 
                      objid = id, osnum2 = os, p_chanselect = to_components, 
                      indexaddr = &index);
  if (!(1&sts))
    return -1;
  else
    return index;
}

IGRboolean DisconnectObject
(
GRobjid fromid,
OMuword fromos,
GRobjid compid,
OMuword compos
)
{
  IGRlong     sts=OM_S_SUCCESS, msg=EMS_S_Success;
  struct GRid grid;

  grid.objid = fromid;
  grid.osnum = fromos;

  sts = om$send (msg = message GRconnector.GRdisconn (&msg, &grid),
                 senderid = compid,
                 targetid = compid,
                 targetos = compos);
  if (!(1&sts&msg))
    return FALSE;
  else
    return TRUE;
}

IGRboolean ConnectObject
(
GRobjid    id,
OMuword    os,
GRobjid    toid,
OMuword    toos,
IGRlong    index
)
{
  IGRlong      sts=OM_S_SUCCESS, loc_msg=EMS_S_Success;
  struct GRid  grid;

  grid.objid = toid;
  grid.osnum = toos;

  sts = om$send (msg = message GRconnector.GRrigidconn (&loc_msg,
                               &grid, &index),
                 senderid = id,
                 targetid = id,
                 targetos = os );
  if (!(1&sts&loc_msg))
    return FALSE;
  else
    return TRUE;
}

IGRboolean PostObjectGeom
(
GRobjid              id,
OMuword              os,
struct GRmd_env      *env,
struct IGRbsp_curve  *newgeom,
GRobjid              *newid
)
{
  IGRlong             sts, msg;
  struct GRpost_info  info;

  info.construct_flag = FALSE;
  sts = om$send (msg = message GRvg.GRpostabsg (&msg, env, &info,  
                                                (IGRchar *) newgeom, newid),
                 senderid = NULL_OBJID,
                 targetid = id,
                 targetos = os );
  if (!(1&sts&msg))
    return FALSE;
  else
    return TRUE;
}

OMuword GetObjectClass 
(
GRobjid  id,
OMuword  os
)
{
  OMuword   classid;

  om$get_classid (objid = id,
                  osnum = os,
                  p_classid = &classid);

  return classid;
}

end implementation Root;
