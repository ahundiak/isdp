class implementation SKconstraint;

#include <alloca.h>
#include "nddef.h"
#include "asbox.h"
#include "msmacros.h"
#include "ECmsg.h"

extern GRclassid OPP_SKcompcurve_class_id, OPP_SKconstraint_class_id, 
                 OPP_GRundo_class_id, OPP_SKexplicit_class_id, OPP_SKmgr_class_id;


method GRdelete (long *msg; struct GRmd_env *md_env)
{
  long            stat_OM, msg_loc;
  OM_S_CHANSELECT chan_to_comps;
  struct GRid     mgr;
  GRclassid       classid;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Unconditionally delete my handle (including turning off the
   * invisible handle property).
   */
  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);

  om$send ( msg = message GRgraphics.GRdelete ( &msg_loc, md_env ),
   p_chanselect = &chan_to_comps );

  om$send ( msg = message Root.wild_disconnect ( chan_to_comps ),
   targetid = my_id );

  ME.SKconstraint->props &= ~SK_INVISIBLEHNDL;

  /*
   * If I am an explicit constraint, my effect of providing an explicit 
   * value to this constraint is no longer there. Therefore, turn my
   * NOVALUE property on. No need to check for classid, since this action
   * does not matter for an implicit constraint.
   */
  ME.SKconstraint->props |= SK_NOVALUE;

  /*
   * Send the internal delete which must clean up my residue
   */
  om$send ( msg = message SKconstraint.SKintdelete (&msg_loc,
   NULL, md_env), targetid = my_id);

  /*
   * We try to split the profile unless the entire thing is going away.
   */
  if (om$get_classid ( osnum = sender_os, objid = sender_id, p_classid = &classid ) & 1)
    if (classid == OPP_GRundo_class_id)
    {
      mgr.osnum = OM_Gw_current_OS;
      stat_OM = om$send ( msg = message SKconstraint.SKgetmgr ( msg, &mgr.objid ), 
       targetid = my_id );
      if (stat_OM & *msg & 1)
        SKsplit_profile ( msg, &mgr );
    }
  
  EMWRAPUP ( *msg, stat_OM, "SKconstraint.GRdelete" );
  return stat_OM;
}


SKadd_objid_to_list ( msg, p_list, p_count, objid )
long	*msg	/* The return status					OUT */;
GRobjid **p_list/* The list of objids					OUT */;
int     *p_count/* The number of elements in the list do far		OUT */;
GRobjid objid	/* The objid to be added				IN  */;
/*
 * This procedure adds objid to p_list and allocates memory as needed. It returns 
 * TRUE (1) if the objid was added and 0 otherwise (already there or no memory)
 */
{
  int i;
  
  *msg = EMS_S_Success;

  /*
   * We make sure this is a new objid
   */
  for (i = 0; i < *p_count; i++)
    if ((*p_list) [i] == objid)
      break;

  if (i == *p_count)
  {
    if (!(*p_count % 16))
    {
      if (*p_list)
        *p_list = (GRobjid *)realloc ( *p_list, (*p_count + 16) * sizeof ( GRobjid ) );
      else
        *p_list = (GRobjid *)malloc ( 16 * sizeof ( GRobjid ) );
      if (!*p_list)
      {
        *msg = EMS_E_NoDynamicMemory;
        return 0;
      }
    }
    (*p_list) [(*p_count)++] = objid;
    
    return 1;
  }
  else
    return 0;
}


/*

Name
  SKsplit_profile

Abstract
  Checks if the profile group can be split into smaller SKmgrs.
  
Synopsis

Description
  This routine tries to see if all the curves under the SKmgr group
  can be reached thru constraints.  If there are certain isolated
  portions, then the SKmgr is split.
  
Return Value

Notes

Index

Keywords

History
  11/19/93 : Rajiv Agrawal : Added special case handling of SKpoints that belong to
                             another geometric element e.g. SKarc, SKcircle, SKbspline.

 */
SKsplit_profile ( msg, p_mgr )
long        *msg	/* The return status				OUT */;
struct GRid *p_mgr	/* The manager to work with			IN  */;
/*
 * This procedure attempts to split a combined profile into several. It gets invoked
 * every time a constraint is deleted.
 */
{
  IGRboolean          split_occurred = FALSE;
  IGRushort           gmtype;
  long                stat_OM;
  unsigned int	      comp_count, geom_count;
  int                 i, j, k, current_count;
  OM_S_CHANSELECT     to_comps, to_geoms, to_vars_mgr, to_constrs_mgr,
                      to_vars, to_constrs, 
                      to_parents, to_children, to_defpts;
  OM_S_OBJECT_LINKAGE *list, *parents;
  GRobjid             *connected = NULL, *constrs = NULL, *vars = NULL, *geoms = NULL, new_mgr;
  int                 nb_connected = 0, *done, nb_constrs = 0, nb_vars = 0, 
                      nb_geoms = 0;
  OMuint              nb_parents = 0;
  long		      owner_index;
  struct GRid         new_mgr_grid, ptvar;
  extern void 	      SKgetgeomtype();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * We need to have more than one curve for a split to be possible. If the
   * manager has been deleted return quietly.
   */  
  if (om$is_objid_valid ( osnum = p_mgr->osnum, 
                          objid = p_mgr->objid ) != OM_S_SUCCESS)
    goto ret_end;

  EMmake_chanselect ( GRcmpowner_to_components, &to_comps );
  stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = p_mgr->objid, 
                                   p_chanselect = &to_comps, count = &comp_count );
  if (comp_count < 2 || !(stat_OM & 1))
    goto ret_end;

  EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
  EMmake_chanselect ( SKvariable_to_geometries, &to_geoms );
  EMmake_chanselect ( SKvariable_to_mgr, &to_vars_mgr );
  EMmake_chanselect ( SKmgr_to_vars, &to_vars );
  EMmake_chanselect ( SKconstraint_to_mgr, &to_constrs_mgr );
  EMmake_chanselect ( SKmgr_to_constrs, &to_constrs );
  EMmake_chanselect ( NDfather_father, &to_parents );
  EMmake_chanselect ( NDchildren_children, &to_children );

  /*
   * For each SKgeometry, we check if can be split or not. If yes, then we split.
   */
  list = (OM_S_OBJECT_LINKAGE *)alloca ( comp_count * sizeof ( OM_S_OBJECT_LINKAGE ) );
  stat_OM = om$get_channel_objects ( list = list, size = comp_count, count = &comp_count,
                                     osnum = p_mgr->osnum, objid = p_mgr->objid, 
                                     p_chanselect = &to_comps );
  if (!(stat_OM & 1)) goto ret_end;
  
  done = (int *)alloca ( comp_count * sizeof ( int ) );
  memset ( done, 0, comp_count * sizeof ( int ) );
  current_count = comp_count;
  for (i = 0; (i < comp_count) && (current_count > 1) && (*msg & 1) ; i++) 
  {
    SKgetgeomtype (list[i].S_objid, list[i].osnum, &gmtype);
    if (gmtype & SK_POINT)
    {
      om$get_objid_at_index ( objid = list[i].S_objid, osnum = list[i].osnum,
                              p_chanselect = &to_defpts,
                              index = 0,
                              objidaddr = &ptvar.objid, osnumaddr = &ptvar.osnum );
      om$get_channel_count ( objid = ptvar.objid, osnum = ptvar.osnum, 
                             p_chanselect = &to_geoms,
                             count = &geom_count );
      if (geom_count > 1 ) 
      {
         done[i] = TRUE;
         --current_count;
      }
    }
    if (!done [i])
    {
      SKconnected_geometry ( msg, &nb_connected, &connected, 
                             &nb_constrs, &constrs, &nb_vars, 
                             &vars, p_mgr, list [i].S_objid, current_count );

      /*
       * If the curve touches all the other curves then the profile cannot be split
       */
      if (nb_connected >= current_count)
        goto ret_end;

      split_occurred = TRUE;
      /*
       * Step1: We create a new SKmgr
       */
      stat_OM = om$construct_and_copy ( osnum = p_mgr->osnum, objid = p_mgr->objid,
                                        p_objid = &new_mgr, obj_osnum = p_mgr->osnum );
      EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
      
      /*
       * Step 2: We connect all the variables to the new SKmgr (matrix and all the
       * rest is ok). Undo must be reset.
       */
      for (j = 0; j < nb_vars; j++)
      {
        stat_OM = om$send (msg = message Root.wild_disconnect ( to_vars_mgr ), 
                           targetos = p_mgr->osnum, targetid = vars [j], 
                           senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
        stat_OM = om$send (msg = message Root.connect ( to_vars_mgr, OM_K_MAXINT,
                                 new_mgr, p_mgr->osnum, to_vars, 0), 
                           targetid = vars [j], 
                           targetos = p_mgr->osnum, senderid = NULL_OBJID );
        EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
      }
      
      /*
       * Step 3: We connect all the constraints to the new SKmgr (if they were connected to the
       * old one)
       */
      for (j = 0; j < nb_constrs; j++)
      {
        stat_OM = om$is_objid_on_channel ( osnum_c = p_mgr->osnum, objid_c = constrs [j],
                                           p_chanselect = &to_constrs_mgr, 
                                           osnum2 = p_mgr->osnum, 
                                           objid = p_mgr->objid );
        if (stat_OM == OM_S_SUCCESS)
        {
          stat_OM = om$send (msg = message Root.wild_disconnect ( to_constrs_mgr ), 
                             targetos = p_mgr->osnum, 
                             targetid = constrs [j], senderid = NULL_OBJID );
          EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
          stat_OM = om$send (msg = message Root.connect ( to_constrs_mgr, OM_K_MAXINT,
                                   new_mgr, p_mgr->osnum, to_constrs, 0), 
                             targetid = constrs [j], 
                             targetos = p_mgr->osnum, senderid = NULL_OBJID );
          EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
        }
      }
      
      /*
       * Step 4: We connect all the geometries to the new SKmgr. The geometries are
       * the ones connected to the variables we have selected. It is faster to grab the
       * entire list first since we are going to have lots of duplicates.
       */
      for (j = 0; j < nb_vars; j++)
      {
        OM_S_OBJECT_LINKAGE *list;
        unsigned int        count;
    
        stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = vars [j],
         p_chanselect = &to_geoms, count = &count );
        if (count && (stat_OM & 1))
        {
          list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
          stat_OM = om$get_channel_objects ( osnum = p_mgr->osnum, objid = vars [j],
           p_chanselect = &to_geoms, count = &count, size = count, list = list );
          for (k = 0; (k < count) && (*msg & 1); k++)
            SKadd_objid_to_list ( msg, &geoms, &nb_geoms, list [k].S_objid );
        }
      }
      
      for (j = 0; j < nb_connected; j++)
        SKadd_objid_to_list ( msg, &geoms, &nb_geoms, connected [j] );
    
      /*
       * Step5: We want the curve we are spliting apart to be connected to the new SKmgr.
       * Note that the curves connected to the composite curve don't need to be touched.
       */
      new_mgr_grid.osnum = p_mgr->osnum;
      new_mgr_grid.objid = new_mgr;  
      owner_index = OM_K_MAXINT;
      for (j = 0; j < nb_geoms; j++)
      {
        *msg = EMS_S_Success;
        om$send (msg = message GRconnector.GRdisconn ( msg, p_mgr ), 
         targetos = p_mgr->osnum, targetid = geoms [j], senderid = NULL_OBJID );
        if (*msg & 1)
        { 
    
          stat_OM = om$send (msg = message GRconnector.GRrigidconn ( msg, &new_mgr_grid, 
           &owner_index ), targetos = p_mgr->osnum, targetid = geoms [j], 
           senderid = NULL_OBJID );
          EMerr_hndlr ( EMSerror ( stat_OM & *msg), *msg, EMS_E_OMerror, ret_end );
        }
        else
        {
          *msg = EMS_S_Success;
          stat_OM = OM_S_SUCCESS;
        }
      }
      
      /*
       * Step 6: We copy the reference plane (and other parents, if any)
       */
      stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = p_mgr->objid,
                                       p_chanselect = &to_parents, count = &nb_parents );
      if (nb_parents && (stat_OM & 1))
      {
        parents = (OM_S_OBJECT_LINKAGE *)alloca ( nb_parents * sizeof ( OM_S_OBJECT_LINKAGE ) );
        stat_OM = om$get_channel_objects ( osnum = p_mgr->osnum, objid = p_mgr->objid,
         p_chanselect = &to_parents, count = &nb_parents, size = nb_parents, list = parents );

        for (k = 0; k < nb_parents; k++)
        {
          stat_OM = om$send (msg = message Root.connect ( to_parents, OM_K_MAXINT,
           parents [k].S_objid, p_mgr->osnum, to_children, 0 ), 
           targetid = new_mgr, targetos = p_mgr->osnum, senderid = NULL_OBJID );
          EMerr_hndlr ( EMSerror ( stat_OM ), *msg, EMS_E_OMerror, ret_end );
        }
      }
  
      /*
       * We update the list of processed curves
       */
      for (j = 0; j < nb_connected; j++)
      {
        for (k = 0; k < comp_count; k++)
          if (list [k].S_objid == connected [j])
            break;
        if (k == comp_count)
          printf ( "BUG in file %s at line %d: curve not found\n", __FILE__, __LINE__ );
        else
          done [k] = 1;
      }

      /*
       * The curves we have processed are no longer taken into account.
       */
      current_count -= nb_connected;

      if (connected) 
      {
        free ( connected );
        connected = NULL;
        nb_connected = 0;
      }
      if (vars) 
      {
        free ( vars );
        vars = NULL;
        nb_vars = 0;
      }
      if (constrs) 
      {
        free ( constrs );
        constrs = NULL;
        nb_constrs = 0;
      }
      if (geoms) 
      {
        free ( geoms );
        geoms = NULL;
        nb_geoms = 0;
      }
    }
  }
  
ret_end:
  if (vars) free ( vars );
  if (constrs) free ( constrs );
  if (connected) free ( connected );
  if (geoms) free ( geoms );
  if (split_occurred)
  {
    ex$message (msgnumb = EMS_I_ProfileGroupSplit);
  }
  EMWRAPUP ( *msg, stat_OM, "SKsplit_profile" );
  return stat_OM;
}


SKfind_curves ( msg, p_count, p_curves, varid, p_mgr )
long        *msg	/* The return status				OUT */;
int         *p_count	/* The number of curves we found		OUT */;
GRobjid     **p_curves 	/* The curves we found				OUT */;
GRobjid     varid	/* The variable to get the curve from		IN  */;
struct GRid *p_mgr	/* The SKetch manager we are working with	IN  */;
/*
 * This routine returns the curve the variable is a part of.
 */
{
  OM_S_CHANSELECT     to_geoms, to_owners;
  OM_S_OBJECT_LINKAGE *list;
  int                 i;
  OMuint              count;
  long                stat_OM;
  struct GRid         owner;

  *msg = EMS_S_Success;
  EMmake_chanselect ( SKvariable_to_geometries, &to_geoms );
  EMmake_chanselect ( GRconnector_to_owners, &to_owners );
  stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = varid,
                                   p_chanselect = &to_geoms, count = &count );
  if (count && (stat_OM & 1))
  {
    list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
    stat_OM = om$get_channel_objects ( list = list, size = count,
                                       count = &count, osnum = p_mgr->osnum, 
                                       objid = varid, p_chanselect = &to_geoms );
    if (!(stat_OM & 1)) goto ret_end;
    
    /*
     * For each curve, we get the owner unless the owner is the Sketch manager itself
     */
    for (i = 0; i < count; i++)
    {
      stat_OM = om$get_objid_at_index ( osnum = p_mgr->osnum, objid = list [i].S_objid,
                                        p_chanselect = &to_owners, objidaddr = &owner.objid, 
                                        osnumaddr = &owner.osnum,
                                        index = 0 );
      SKadd_objid_to_list ( msg, p_curves, p_count, 
                            owner.objid == p_mgr->objid ? list [i].S_objid : owner.objid );
    }
  }
  else
  {
    *p_count = 0;
    /*
     * Invalid channel -> getting the curve of a constrained constraint.
     */
    if (stat_OM == OM_E_INVCHAN) stat_OM = OM_S_SUCCESS;
  }

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKfind_curves");
  return stat_OM;
}


SKconnected_geometry ( msg, nb_connected, connected, nb_constrs, constrs, 
                       nb_vars, vars, p_mgr, curve, upper_limit )
long        *msg	  /* The return status				OUT */;
int         *nb_connected /* The number of connected curves		OUT */;
GRobjid     **connected	  /* The connected curves				OUT */;
int         *nb_constrs	  /* The number of constraints			OUT */;
GRobjid     **constrs	  /* The constraints				OUT */;
int         *nb_vars	  /* The number of variables			OUT */;
GRobjid     **vars	  /* The variables				OUT */;
struct GRid *p_mgr	  /* The manager to work with			IN  */;
GRobjid     curve	  /* The curve to be removed from the profile	IN  */;
int         upper_limit	  /* Stop when nb_connected == upper_limit	IN  */;
/*
 * This procedure finds the curves curve is connected to through constraints.
 */
{
  long            	stat_OM;
  int             	i, j, k, nb_tmp_curves = 0;
  OM_S_CHANSELECT 	to_vars, to_constrs;
  GRobjid         	*tmp_curves = NULL;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  SKadd_objid_to_list ( msg, connected, nb_connected, curve );
  /*
   * Get the list of constraints and variables for the curve
   */
  SKget_varcnstr_of_geometry ( msg, nb_constrs, constrs, nb_vars, vars, p_mgr, curve );
  
  /*
   * We scan the constraints and add any new curve (and its related constraints and variables).
   */
  EMmake_chanselect ( SKconstraint_to_variables, &to_vars );
  EMmake_chanselect ( SKvariable_to_constraints, &to_constrs );
  for (i = 0; i < *nb_constrs; i++)
  {
    OMuint              tmp_count_vars;
    OM_S_OBJECT_LINKAGE *tmp_vars;

    stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = (*constrs) [i],
                                     p_chanselect = &to_vars, count = &tmp_count_vars );
    if (tmp_count_vars && (stat_OM & 1))
    {
      tmp_vars = (OM_S_OBJECT_LINKAGE *)alloca ( tmp_count_vars * sizeof ( OM_S_OBJECT_LINKAGE ) );
      stat_OM = om$get_channel_objects ( list = tmp_vars, size = tmp_count_vars, 
                                         count = &tmp_count_vars, osnum = p_mgr->osnum, 
                                         objid = (*constrs) [i], 
                                         p_chanselect = &to_vars );
      if (!(stat_OM & 1)) goto ret_end;
      
      for (j = 0; j < tmp_count_vars; j++)
      {
        SKfind_curves ( msg, &nb_tmp_curves, &tmp_curves, tmp_vars [j].S_objid, p_mgr );
        if (nb_tmp_curves)
        {
          for (k = 0; k < nb_tmp_curves; k++)
          {
            if (SKadd_objid_to_list ( msg, connected, nb_connected, tmp_curves [k] ))
            {
              /*
               * New curve!
               */
              if (*nb_connected == upper_limit) goto ret_end;
              SKget_varcnstr_of_geometry ( msg, nb_constrs, constrs, nb_vars, vars, 
                                           p_mgr, tmp_curves [k] );
            }
          }
  
          if (tmp_curves) 
          {
            free ( tmp_curves );  
            tmp_curves = NULL;
            nb_tmp_curves = 0;
          }
        }
        else
        {
          /*
           * We didn't find any curve. There are 3 possibilities:
           * 	1. The curve was already in the list
           * 	2. The constraint is a super-constraint
           * 	3. We have an associative ground (no curve to find)
           */
          OMuint              tmp_count_constrs;
          OM_S_OBJECT_LINKAGE *tmp_constrs;
          int                 ConstraintIndex;
      
          /*
           * If this fails then we have a super constraint
           */
          stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = tmp_vars [j].S_objid,
                                           p_chanselect = &to_constrs, count = &tmp_count_constrs );
          if (stat_OM & 1)
          {
            /*
             * It succeeded so the curve was already there or we have an associative ground
             */
            if (SKadd_objid_to_list ( msg, vars, nb_vars, tmp_vars [j].S_objid ))
            {
              /*
               * We have an associative ground
               */
              if (tmp_count_constrs && (stat_OM & 1))
              {
                tmp_constrs = (OM_S_OBJECT_LINKAGE *)alloca ( tmp_count_constrs * sizeof ( OM_S_OBJECT_LINKAGE ) );
                stat_OM = om$get_channel_objects ( list = tmp_constrs, size = tmp_count_constrs, 
                 count = &tmp_count_constrs, osnum = p_mgr->osnum, objid = tmp_vars [j].S_objid,
                 p_chanselect = &to_constrs );
                if (!(stat_OM & 1)) goto ret_end;
              
                for (ConstraintIndex = 0; ConstraintIndex < tmp_count_constrs; ConstraintIndex++)
                  SKadd_objid_to_list ( msg, constrs, nb_constrs, tmp_constrs [ConstraintIndex].S_objid );
              }
            }
          }
          else
            /*
             * Invalid channel, it is a super-constraint
             */
            stat_OM = 1;
        }
      }
    }
  }

ret_end:
  if (tmp_curves) free ( tmp_curves );  
  EMWRAPUP ( *msg, stat_OM, "SKconnected_geometry" );
  return stat_OM;
}


SKget_varcnstr_of_geometry ( msg, p_count_constrs, p_constrs, p_count_vars, p_vars, p_mgr, curve )
long        *msg		/* The return status			OUT */;
int         *p_count_constrs	/* The number of constraints		OUT */;
GRobjid     **p_constrs		/* The constraints			OUT */;
int         *p_count_vars	/* The number of variables		OUT */;
GRobjid     **p_vars		/* The variables			OUT */;
struct GRid *p_mgr		/* The manager to work with		IN  */;
GRobjid     curve		/* The curve to be processed		IN  */;
/*
 * This function returns the constraints connected to a given geometry
 */
{
  OM_S_CHANSELECT to_constrs, to_defpts, to_comps, to_super_constrs, to_vars;
  long            stat_OM;
  OMuint          tmp_count_constrs, tmp_count_vars;
  int             i, j, k, first_var, first_constr;
  GRclassid       classid;

  /*
   * We save the first variable/constraint index that is filled out by this routine
   * so that we don't re-process variables/constraints processed by previous calls
   * This is only a speed issue.
   */
  first_var = *p_count_vars; 
  first_constr = *p_count_constrs;

  /*
   * In the case of a composite curve, we loop through the components
   */
  stat_OM = om$get_classid ( osnum = p_mgr->osnum, objid = curve, p_classid = &classid );
  if (!(stat_OM & 1)) goto ret_end;

  if (om$is_ancestry_valid ( subclassid = classid, 
       superclassid = OPP_SKcompcurve_class_id ) == OM_S_SUCCESS)
  {
    OM_S_OBJECT_LINKAGE *list;
    OMuint              count;
    
    EMmake_chanselect ( GRcmpowner_to_components, &to_comps );
    stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = curve,
      p_chanselect = &to_comps, count = &count );
    if (count && (stat_OM & 1))
    {
      list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
      stat_OM = om$get_channel_objects ( list = list, size = count, 
       count = &count, osnum = p_mgr->osnum, objid = curve, p_chanselect = &to_comps );
      if (!(stat_OM & 1)) goto ret_end;
      
      for (i = 0; (i < count) && (*msg & 1); i++)
        SKget_varcnstr_of_geometry ( msg, p_count_constrs, p_constrs, p_count_vars, 
         p_vars, p_mgr, list [i].S_objid );
    }

    goto ret_end;
  }
  
  /*
   * We get the points (variables) and then all the constraints connected to those points
   */
  EMmake_chanselect ( SKgeometry_to_defpts, &to_defpts );
  stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = curve,
   p_chanselect = &to_defpts, count = &tmp_count_vars );
  if (tmp_count_vars && (stat_OM & 1))
  {
    OM_S_OBJECT_LINKAGE *tmp_list = 0;

    tmp_list = (OM_S_OBJECT_LINKAGE *)alloca ( tmp_count_vars * sizeof ( OM_S_OBJECT_LINKAGE ) );
    stat_OM = om$get_channel_objects ( list = tmp_list, size = tmp_count_vars, 
     count = &tmp_count_vars, osnum = p_mgr->osnum, objid = curve, p_chanselect = &to_defpts );
    if (!(stat_OM & 1)) goto ret_end;
    for (i = 0; (i < tmp_count_vars) && (*msg & 1); i++)
      SKadd_objid_to_list ( msg, p_vars, p_count_vars, tmp_list [i].S_objid );
  }

  /*
   * We grab all the constraints connected to variables
   */  
  EMmake_chanselect ( SKvariable_to_constraints, &to_constrs );
  for (i = first_var, tmp_count_constrs = 0; i < *p_count_vars; i++)
  {
    OMuint              count = 0;
    OM_S_OBJECT_LINKAGE *tmp_list = 0;
       
    stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = (*p_vars) [i],
     p_chanselect = &to_constrs, count = &count );
    if (count && (stat_OM & 1))
    {
      tmp_list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
      stat_OM = om$get_channel_objects ( list = tmp_list, size = count, count = &count,
       osnum = p_mgr->osnum, objid = (*p_vars) [i], p_chanselect = &to_constrs );
      if (!(stat_OM & 1)) goto ret_end;
    }

    /*
     * Add the constraints we've found so far
     */    
    for (j = 0; (j < count) && (*msg & 1); j++)
      if (SKadd_objid_to_list ( msg, p_constrs, p_count_constrs, tmp_list [j].S_objid ))
        tmp_count_constrs++;
  }

  /*
   * If we have any super-constraints (equality, ...) then we add all the constraints
   * the super-constraints are connected to.
   */
  EMmake_chanselect ( SKconstraint_to_super_constrs, &to_super_constrs );
  EMmake_chanselect ( SKconstraint_to_variables, &to_vars );
  for (i = first_constr; i < first_constr + tmp_count_constrs; i++)
  {
    OMuint              count, count2;
    OM_S_OBJECT_LINKAGE *tmp_list = NULL, *tmp_list2 = NULL;
       
    stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = (*p_constrs) [i],
     p_chanselect = &to_super_constrs, count = &count2 );
    if (count2 && (stat_OM & 1))
    {
      tmp_list2 = (OM_S_OBJECT_LINKAGE *)alloca ( count2 * sizeof ( OM_S_OBJECT_LINKAGE ) );
      stat_OM = om$get_channel_objects ( list = tmp_list2, size = count2, count = &count2,
       osnum = p_mgr->osnum, objid = (*p_constrs) [i], p_chanselect = &to_super_constrs );
      if (!(stat_OM & 1)) goto ret_end;
    }
    
    for (j = 0; j < count2; j++)
    {
      stat_OM = om$get_channel_count ( osnum = p_mgr->osnum, objid = tmp_list2 [j].S_objid,
       p_chanselect = &to_vars, count = &count );
      if (count && (stat_OM & 1))
      {
        tmp_list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
        stat_OM = om$get_channel_objects ( list = tmp_list, size = count, count = &count,
         osnum = p_mgr->osnum, objid = tmp_list2 [j].S_objid, p_chanselect = &to_vars );
        if (!(stat_OM & 1)) goto ret_end;
      }

      /*
       * Add the constraints we've found (including the super constraint).
       */    
      for (k = 0; (k < count) && (*msg & 1); k++)
      {
        stat_OM = om$get_classid ( osnum = p_mgr->osnum, objid = tmp_list [k].S_objid, 
         p_classid = &classid );
        if (!(stat_OM & 1)) goto ret_end;

        if ((om$is_ancestry_valid ( subclassid = classid, 
             superclassid = OPP_SKconstraint_class_id ) == OM_S_SUCCESS) ||
            (om$is_ancestry_valid ( subclassid = classid, 
             superclassid = OPP_SKexplicit_class_id ) == OM_S_SUCCESS))
          if (SKadd_objid_to_list ( msg, p_constrs, p_count_constrs, tmp_list [k].S_objid ))
            tmp_count_constrs++;
      }

      if (SKadd_objid_to_list ( msg, p_constrs, p_count_constrs, tmp_list2 [j].S_objid ))
        tmp_count_constrs++;
    }
  }
  
ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKget_constraints_of_geometry" );
  return stat_OM;
}


end implementation SKconstraint;
