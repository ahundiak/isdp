class implementation SKvariable;

#include <alloca.h>
#include <math.h>
#include "exmacros.h"
#include "dp.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSopt.h"

from SKmgr       import SKmergemgr, SKcompute, SKconstr_update, SKmgrprops, SKget_xymat;
from SKcompcurve import SKclose;
from GRconnector import GRrigidconn, GRdisconn;
from SKgeometry  import SKgetmgr, SKrecompute_yourself;
from GRgraphics  import GRdelete, GRdisplay;
from GRconic     import GRgetarc;


struct component
/*
 * This structure represents an SKline or an SKarc.
 */
{
  GRobjid comp_id	/* The objid of the component				*/;
  GRobjid p [4]		/* The first, second, third, and fourth SKpoint	objid	*/;
};


SKis_in_component ( objid1, objid2, p_component )
GRobjid          objid1		/* The first objid			IN  */;
GRobjid          objid2		/* The second objid (can be NULL_OBJID)	IN  */;
struct component *p_component	/* The component to analyze		IN  */;
/*
 * This procedure checks if objid1 and objid2 are SKpoint of p_component.
 */
{
  int i;

  if (p_component->comp_id != NULL_OBJID)
    for (i = 0; i < 4; i++)
      if (p_component->p [i] == objid1)
      {
        if (objid2 == NULL_OBJID)
          return TRUE;
        else
          for (i = 0; i < 4; i++)
            if (p_component->p [i] == objid2)
              return TRUE;
        break;
      }

  return FALSE;        
}


/*

Name
  SKsort_composite

Abstract

Synopsis

Description

 This routine sorts the composite curve so that first is the first point
 and second is the second point. It is assumed that first and second are
 in fact connected. This is called primarily after merging two composite
 curves so that the resulting composite is oriented properly. If first is
 NULL_OBJID then the orientation is chosen by the routine.

Return Value

Notes

Index

Keywords
  composite,profile

History
  ???????? : Henry Bequet : created.
  02/03/94 : Rajiv Agrawal : Added std. header and fixed a bug that was adding the
                             SKptvars to the geometry wrongly. (TR119416588)

 */
SKsort_composite ( msg, manager, composite, first, second, compute )
long        *msg	/* The return status				OUT */;
struct GRid *manager    /* The SKmgr we are working with		IN  */;
struct GRid *composite	/* The composite curve to be sorted		IN  */;
GRobjid     first	/* The first point				IN  */;
GRobjid     second	/* The second point				IN  */;
int         compute     /* Compute the profile after sorting?		IN  */;
{
  int                 i, j, l, stat_OM, deleted;
  OMuint              count;
  OM_S_CHANSELECT     to_comps, to_defpts, to_owners, to_geoms;
  OM_S_OBJECT_LINKAGE *components;
  struct component    *list, *sorted_list;
  GRobjid             target_objid;
  long                owner_index = OM_K_MAXINT, msg_loc;
  struct GRmd_env     md_env;
  short               mattyp_to_lxyz;
  IGRmatrix           mat_to_lxyz;
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ex$get_cur_mod ( id = &md_env.md_id.objid, osnum = &md_env.md_id.osnum );
  EMidmatrix ( &msg_loc, &md_env.md_env.matrix_type, md_env.md_env.matrix );

  stat_OM = om$send (msg = message SKmgr.SKget_xymat ( &msg_loc,
      SK_OPT_GET_XY_TO_LXYZ, NULL, NULL, &mattyp_to_lxyz, mat_to_lxyz ), 
      senderid = NULL_OBJID, 
      targetid = manager->objid, targetos = manager->osnum );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_Fail, ret_end );

  EMmake_chanselect ( GRcmpowner_to_components, &to_comps );
  EMmake_chanselect ( GRconnector_to_owners, &to_owners );
  
  /*
   * We get all the objects of the composite curve (lines and arcs)
   */
  stat_OM = om$get_channel_count ( osnum = composite->osnum, objid = composite->objid,
      p_chanselect = &to_comps, count = &count );
  EMerr_hndlr ( EMSerror ( stat_OM ) && count, *msg, EMS_E_Fail, ret_end );
  components = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
  stat_OM = om$get_channel_objects ( list = components, size = count, 
      count = &count, osnum = composite->osnum, objid = composite->objid, 
      p_chanselect = &to_comps );
  EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
  
  /*
   * We build the list of components.
   */
  list = (struct component *)alloca ( count * sizeof ( struct component ) );
  sorted_list = (struct component *)alloca ( count * sizeof ( struct component ) );
  EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
  EMmake_chanselect ( SKvariable_to_geometries, &to_geoms );
  for (i = 0, deleted = 0; i < count; i++)
  {
    OM_S_OBJECT_LINKAGE points [4];
    OMuint              nb_points;
    
    list [i - deleted].comp_id = components [i].S_objid;
    stat_OM = om$get_channel_objects ( list = points, size = 4, 
      count = &nb_points, osnum = components [i].osnum, objid = components [i].S_objid, 
      p_chanselect = &to_defpts );
    EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
    list [i - deleted].p [2] = NULL_OBJID;
    list [i - deleted].p [3] = NULL_OBJID;
    for (j = 0; j < nb_points; j++)
      list [i - deleted].p [j] = points [j].S_objid;
    if (!nb_points)
      deleted++;
  }
  count -= deleted;
  
  /*
   * Do we have a first and a second?
   */
  if (first == NULL_OBJID)
  {
    int nb_connected;
    
    for (i = 0; (i < count) && (first == NULL_OBJID); i++)
    {
      for (l = 0; (l < 3) && (first == NULL_OBJID); l++)
      {
        if (list [i]. p[l] == NULL_OBJID)
          continue;
        for (j = 0, nb_connected = 0; (j < count) && (nb_connected != 2); j++)
          if (list [i].p [l] == list [j]. p [0] || 
              list [i].p [l] == list [j]. p [1] || list [i].p [l] == list [j]. p [2])
            nb_connected++;
        if (nb_connected == 1)
        {
          switch (l)
          {
            case 0: second = list [i].p [list [i].p [2] == NULL_OBJID ? 1 : 2];
                    break;
            case 1: if (list [i].p [2] == NULL_OBJID)
                      second = list [i]. p [0];
                    else
                      continue;
                    break;
            case 2: second = list [i].p [0];
                    break;
          }
          first = list [i].p [l];
        }
      }
    }

    /*
     * first will be NULL_OBJID when the composite is closed.
     */          
    if (first == NULL_OBJID)
    {
      first = list [0].p [0];
      second = list [0].p [list [0].p [2] == NULL_OBJID ? 1 : 2];
    }
  }

  /*
   * We sort the list starting at the curve connected to first and second.
   */
  for (i = 0; i < count; i++)
    if (SKis_in_component ( first, second, &list [i] ))
    {
      sorted_list [0].comp_id = list [i].comp_id;
      sorted_list [0].p [0] = first;
      if (list [i].p [2] == NULL_OBJID)  /* SKline object */
      {
        sorted_list [0].p [1] = second;
        sorted_list [0].p [2] = NULL_OBJID;
        sorted_list [0].p [3] = NULL_OBJID;
      }
      else if (list [i].p [3] == NULL_OBJID) /* SKarc object */
      {
        sorted_list [0].p [2] = second;
        sorted_list [0].p [1] = list [i].p [1];
        sorted_list [0].p [3] = NULL_OBJID;
      }
      else  /* SKbspline object */
      {
        sorted_list [0].p [3] = second;
        if (first == list [i]. p [0])
        {
          sorted_list [0].p [1] = list [i].p [1];
          sorted_list [0].p [2] = list [i].p [2];
        }
        else
        {
          sorted_list [0].p [1] = list [i].p [2];
          sorted_list [0].p [2] = list [i].p [1];
        }
      }
      
      list [i].comp_id = NULL_OBJID;
      break;
    }

  for (i = 1, target_objid = second; i < count; i++)
  {
    for (j = 0; j < count; j++)
      if (SKis_in_component ( target_objid, NULL_OBJID, &list [j] ))
      {
        sorted_list [i].comp_id = list [j].comp_id;
        sorted_list [i].p [0] = target_objid;
        if (list [j].p [2] == NULL_OBJID)  /* SKline object */
        {
          target_objid = 
              sorted_list [i].p [1] = list [j]. p [list [j].p [0] == target_objid ? 1 : 0];
          sorted_list [i].p [2] = NULL_OBJID;
          sorted_list [i].p [3] = NULL_OBJID;          
        }
        else if (list[j].p[3] == NULL_OBJID) /* SKarc object */
        {
          target_objid = 
              sorted_list [i].p [2] = list [j]. p [list [j].p [0] == target_objid ? 2 : 0];
          sorted_list [i].p [1] = list [j]. p [1];
          sorted_list [i].p [3] = NULL_OBJID;
        }
        else  /* SKbspline object */
        {
          target_objid = 
              sorted_list [i].p [3] = list [j]. p [list [j].p [0] == target_objid ? 3 : 0];
          if (list [j].p [0] == sorted_list [i].p [0])
          {
            sorted_list [i].p [1] = list [j]. p [1];
            sorted_list [i].p [2] = list [j]. p [2];
          }
          else  /* bspline has been reversed .. change the poles */
          {
            sorted_list [i].p [1] = list [j]. p [2];
            sorted_list [i].p [2] = list [j]. p [1];
          }
        }
        list [j].comp_id = NULL_OBJID;
        break;
      }
  }
  
  /*
   * We disconnect each component and then reconnect it in the specified order.
   * The points can be disconnected.
   */
  for (i = 0; i < count; i++)
  {
    stat_OM = om$send ( msg = message GRconnector.GRdisconn ( &msg_loc, composite ),
        targetos = composite->osnum, targetid = sorted_list [i].comp_id, 
        senderid = NULL_OBJID );
    EMerr_hndlr ( EMSerror ( stat_OM && msg_loc ), *msg, EMS_E_Fail, ret_end );
  }
  
  for (i = 0; i < count; i++)
  {
    OM_S_OBJECT_LINKAGE points [4];
    OMuint              nb_points;
    
    stat_OM = om$send ( msg = message GRconnector.GRrigidconn ( &msg_loc,
        composite, &owner_index ), targetos = composite->osnum, 
        targetid = sorted_list [i].comp_id, senderid = NULL_OBJID );
    EMerr_hndlr ( EMSerror ( stat_OM && msg_loc ), *msg, EMS_E_Fail, ret_end );

    /*
     * Check the order of the SKpoints.
     */
    stat_OM = om$get_channel_objects ( list = points, size = 4, 
      count = &nb_points, osnum = composite->osnum, objid = sorted_list [i].comp_id, 
      p_chanselect = &to_defpts );
    EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
    
    if (sorted_list [i].p [0] != points [0].S_objid)
    {
      int last_index = 0;
   
      /*
       * Disconnect and re-connect those guys.
       */
      stat_OM = om$send ( msg = message Root.wild_disconnect ( to_defpts ),
          targetid = sorted_list [i].comp_id, targetos = composite->osnum, senderid = NULL_OBJID );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_Fail, ret_end );
      
      for (j = 0; j < 4; j++)
        if (sorted_list [i].p [j] != NULL_OBJID)
        {
          /*
           * Attach the geometric element at the end of the channel for SKptvar.
           */
          stat_OM = om$send (msg = message Root.connect ( to_defpts, OM_K_MAXINT,
              sorted_list [i].p [j], composite->osnum, to_geoms, OM_K_MAXINT ), 
              targetid = sorted_list [i].comp_id, 
              targetos = composite->osnum, senderid = NULL_OBJID );
          EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
          last_index = j;
        }
        
      if (last_index == 2)  /* last component was an SKarc */
        SKtgctrprps ( composite->osnum, sorted_list [i].p [1] );
    }
  }
    
  if (compute)
  {      
    /*
     * Re-generate the geometry as well (re-compute the manager)
     */
    ex$get_cur_mod ( id = &md_env.md_id.objid, osnum = &md_env.md_id.osnum );
    EMidmatrix ( &msg_loc, &md_env.md_env.matrix_type, md_env.md_env.matrix );
    stat_OM = om$send ( msg = message SKmgr.SKmgrprops ( &msg_loc, 
                              SK_CHGPROPS_ON, SK_MGR_OUTOFDATE, NULL ), 
                        senderid = NULL_OBJID,
                        targetid = manager->objid, targetos = manager->osnum );
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
    stat_OM = om$send ( msg = message SKmgr.SKcompute ( &msg_loc, NULL, 
                              &md_env, NULL, NULL, NULL, NULL ), 
                        senderid = NULL_OBJID,
                        targetid = manager->objid, targetos = manager->osnum );
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), *msg, EMS_E_OMerror, ret_end );
    stat_OM = om$send ( msg = message SKmgr.SKconstr_update ( &msg_loc,
                              SK_UPDATE_IMPCONSTRS | SK_UPDATE_ERASE | SK_UPDATE_DRAW, 
                              NULL, &md_env ),
                        senderid = NULL_OBJID, 
                        targetid = manager->objid, targetos = manager->osnum );
    EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  }

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKsort_composite" );
  return stat_OM;
}


SKtgctrprps ( osnum, objid )
GRspacenum osnum	/* The osnum of the object			IN  */;
GRobjid    objid	/* The objid of the object			IN  */;
/*
 * This routine changes the properties of the center of an arc when the cc
 * has been reversed so that arcs don't flip.
 */
{
  unsigned short props = 0;
  int            stat_OM;
  long           msg_loc;
  
  stat_OM = om$send ( msg = message SKvariable.SKgetprops ( &msg_loc, &props ),
    senderid = NULL_OBJID, targetos = osnum, targetid = objid );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), msg_loc, EMS_E_OMerror, ret_end );

  if (props & SK_VAR_NEGDIRGEOM)
    props &= ~SK_VAR_NEGDIRGEOM;
  else
    props |= SK_VAR_NEGDIRGEOM;
    
  om$send ( msg = message SKvariable.SKchgprops ( &msg_loc, (short)EMS_O_SET, props ),
    senderid = NULL_OBJID, targetos = osnum, targetid = objid );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), msg_loc, EMS_E_OMerror, ret_end );

ret_end:  
  return OM_S_SUCCESS;
}


end implementation SKvariable;

