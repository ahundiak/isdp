/*

Name
  SKmakejacobian

Abstract
  Calculate the jacobian row for relative orientation angle constraints.
  
Synopsis

Description

Return Value

Notes
  Known BUGS
    Using the angle of this constraint as a variable is not yet supported.
    The changes need to be consistent with the file SKppmkjacob.I, where
    this option is supported.

  We are currently checking the class of the constraint to see if we are
  dealing with a parallel, normal, collinear or a relative angle constraint.
  Since this violates object-oriented programming, we should write separate
  separate make-jacobian methods at a later date.
 
Index

Keywords
  angle, constraint, jacobian

History
  08/03/93 : Rajiv Agrawal : added doc header.  Checking the constraint class to
                             determine the type of the constraint as opposed to
                             the angle value.  (TR11920316).
  12/22/93 : G M K         : TR # 119314641 :Update unsolved vars based on solved vars.
  12/28/93 : G M K         : TR # 119314660 :Update unsolved vars based on solved vars for
  			     SKtangency class constraints.
  01/21/94 : Satya         : The fix for TR119314641 is valid for parallel constraints
                             only.  Fixes arc flipping.  (TR119415607).
  01/26/94 : Rajiv Agrawal : Rewrote the code to that sets the EMS_I_OutOfBounds flag. 
                             Previous one was completely wrong.
  01/27/94 : G M K & Satya : Wrote code to get a good guess for collinear constraints.
                             (TR119312545 & TR119415610).
  
 */

class implementation SKrelornt;

#include <math.h>
#include <values.h>
#include "emsdebug.h"

#define SOLVED -1

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1

%safe
static IGRint SKget_arc3rd_ptvar();
static void SKget_unmatched_ptvar();
%endsafe

from SKvariable import SKgetvar;

extern GRclassid OPP_SKparallel_class_id, OPP_SKnormal_class_id, OPP_SKcollinear_class_id,
                 OPP_SKrelang_class_id,OPP_SKtangency_class_id,OPP_SKarc_class_id;

method SKmakejacobian (IGRlong *msg; IGRushort options;
                       struct SKsolvevars *solvedvars, *unsolvedvars;
                       IGRdouble *jacobian; IGRdouble *funcval)
{
  IGRboolean 		is_parallel, is_normal, is_collinear, is_arbit, is_midcommon;
  IGRboolean 		use_sine_formula, adjreq, accreq;
  IGRint 		i, j, k, inx, var_inx[2][2][2], varinx;
  IGRlong 		stat_OM, msg_loc;
  IGRdouble 		angle, var[2][2][2],point[2][2][3];
  IGRdouble 		delx1, dely1, delx2, dely2, len1, len2;
  IGRdouble		len1_len2=0.0, len2_len1=0.0;
  IGRdouble 		diff_value=0.0, trigval, addterm, chkterm, lentol;
  GRobjid 		ptobjs[2][2];
  GRclassid 	        myclass;
  struct GRid 		my_grid;
  struct SKsolvevars 	*varnode[2][2][2];
  extern IGRboolean 	SKvarlistinx();
  
  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /*
   * Obtain the relative orientation of the line-elements that this object is 
   * constraining.
   */

  stat_OM = om$send (msg = message SKrelornt.SKgetrelornt (&msg_loc,
                           solvedvars, &angle, ptobjs), 
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_InvalidCase, ret_end);

  if (ME.SKconstraint->props & SK_UNITSCONVERT)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &angle, GRIO_ANGLE, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }

  if (ME.SKconstraint->props & SK_SUPPLEMENT)
    angle = 180 - angle;

  if (angle < 0)
    angle = angle + 180;

  om$get_classid ( objid = my_id, p_classid = &myclass );

  is_parallel = is_normal = is_collinear = is_arbit = is_midcommon = FALSE;
  if (myclass == OPP_SKparallel_class_id)
    is_parallel = TRUE;
  else if (myclass == OPP_SKnormal_class_id)
    is_normal = TRUE;
  else if (myclass == OPP_SKcollinear_class_id)
    is_collinear = TRUE;
  else if (myclass == OPP_SKrelang_class_id)
    is_arbit = TRUE;
  else
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);

  if (ptobjs[FIRST][FIRST] == ptobjs[SECOND][FIRST])
    is_midcommon = TRUE;

  /*
   * Determine the unknown variables in this equation and obtain their indices.
   * Also, find out the current values of the involved variables (both the
   * known and the unknown variables).
   */

  for (i=FIRST; i<=SECOND; i++)
  {
    for (j=FIRST; j<=SECOND; j++)
    {
      for (k=X; k<=Y; k++)
      {
        if (SKvarlistinx (unsolvedvars, ptobjs[i][j], k == X ? VAR_X : VAR_Y,
            &varnode[i][j][k], &varinx))
          var_inx[i][j][k] = varinx;
        else
        if (SKvarlistinx (solvedvars, ptobjs[i][j], k == X ? VAR_X : VAR_Y,
               &varnode[i][j][k], &varinx))
          var_inx[i][j][k] = SOLVED;
        else
            {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);}
      }
    }
  }

  /*
   * If we want to take a better guess at the solution, we can see if any
   * of the connected variables are known.  Based on their change, we can
   * update the unsolvedvars value.
   */
  if (options & SK_JACOB_UPDATE_GUESS)
  {
    for (i=FIRST; i<=SECOND; i++)
      for (j=FIRST; j<=SECOND; j++)
      {
        stat_OM = om$send ( msg = message SKvariable.SKgetvar 
                                  (&msg_loc, NULL, NULL, NULL, point[i][j]),
                            targetid = ptobjs[i][j]);
      }

    /*
     * If the constraint is parallel, then preserve the length of the lines
     * to determine a good guess for the unknown.
     */
    if ( is_parallel )
    {
      for (i=FIRST; i<=SECOND; i++)
      {
        if (var_inx[i][FIRST][X] != SOLVED && var_inx[i][SECOND][X] == SOLVED)
          varnode[i][FIRST][X]->var[X] = point[i][FIRST][X] + 
                              (varnode[i][SECOND][X]->var[X] - point[i][SECOND][X]);
        else if (var_inx[i][SECOND][X] != SOLVED && var_inx[i][FIRST][X] == SOLVED)
          varnode[i][SECOND][X]->var[X] = point[i][SECOND][X] + 
                              (varnode[i][FIRST][X]->var[X] - point[i][FIRST][X]);
  
        if (var_inx[i][FIRST][Y] != SOLVED && var_inx[i][SECOND][Y] == SOLVED)
          varnode[i][FIRST][Y]->var[Y] = point[i][FIRST][Y] + 
                              (varnode[i][SECOND][Y]->var[Y] - point[i][SECOND][Y]);
        else if (var_inx[i][SECOND][Y] != SOLVED && var_inx[i][FIRST][Y] == SOLVED)
          varnode[i][SECOND][Y]->var[Y] = point[i][SECOND][Y] + 
                            (varnode[i][FIRST][Y]->var[Y] - point[i][FIRST][Y]);
      }
    } 
    /*
     * if the constraint is SKtangency class, update the arc's two ptvars 
     * according to the arc's third ptvar solved values.
     */
    else if ( is_midcommon && is_normal )
    {
      OMuint count=0,ind=0,ind1[2];
      IGRint ptvar_inx[2],sts;
      IGRdouble pt[3];
      GRclassid  classid;
      GRobjid    ptvar[2];
      struct SKsolvevars  *ptvarnode[2];
      OM_S_OBJECT_LINKAGE objlist;
      OM_S_CHANSELECT chan_to_super;
      
      EMmake_chanselect (SKconstraint_to_super_constrs, &chan_to_super);
      om$get_channel_objects (object = me, p_chanselect = &chan_to_super,
                              size = 1, list = &objlist, count = &count);
      if (count)
      {
        om$get_classid ( objid =objlist.S_objid, osnum = objlist.osnum,
                         p_classid = &classid );
        if ( classid == OPP_SKtangency_class_id )
        {
          sts = SKget_arc3rd_ptvar( objlist.S_objid, ptobjs, ptvar, ind1 );
          ind = ind1[0];
          if ( 1 & sts )
          {
            for (k=X; k<=Y; k++)
            {
              if (SKvarlistinx (unsolvedvars, ptvar[0], k == X ? VAR_X : VAR_Y,
                                &ptvarnode[k], &varinx))
                ptvar_inx[k] = varinx;
              else
              if (SKvarlistinx (solvedvars, ptvar[0], k == X ? VAR_X : VAR_Y,
                                &ptvarnode[k], &varinx))
                ptvar_inx[k] = SOLVED;
              else
                /* 
                 * Some times required ptvar info won't be there in unsolvedvars or solvedvars
                 * Here I no need to do anything simply exit from the UPDATE_GUESS
                 */
                goto Update_Guess_Over; 
            }

            stat_OM = om$send ( msg = message SKvariable.SKgetvar 
                                      (&msg_loc, NULL, NULL, NULL, pt),
                            targetid = ptvar[0] );
            if ( !(1 & stat_OM & msg_loc) ) goto Update_Guess_Over; 
            
            if ( var_inx[ind][FIRST][X] != SOLVED && var_inx[ind][SECOND][X] != SOLVED && 
                 ptvar_inx[X] == SOLVED )
            {
               varnode[ind][FIRST][X]->var[X] = point[ind][FIRST][X] + (ptvarnode[X]->var[X] - pt[X]);
               varnode[ind][SECOND][X]->var[X] = point[ind][SECOND][X] + (ptvarnode[X]->var[X] - pt[X]);
            }
            if ( var_inx[ind][FIRST][Y] != SOLVED && var_inx[ind][SECOND][Y] != SOLVED && 
                 ptvar_inx[Y] == SOLVED )
            {
               varnode[ind][FIRST][Y]->var[Y] = point[ind][FIRST][Y] + (ptvarnode[Y]->var[Y] - pt[Y]);
               varnode[ind][SECOND][Y]->var[Y] = point[ind][SECOND][Y] + (ptvarnode[Y]->var[Y] - pt[Y]);
            }
            
          }
        }
      }
    }
    /*
     * Update the unsolved vars depending upon the solved vars for better starting values. 
     * In case of collinear constraint the unsolved vars are updated based on the solved var.
     * A special case of the collinear constraint is tangency between two arcs. Here in addition
     * to the updation of above unsolved vars, the other end points of the arcs are also updated
     * in the same fashion.      -- GMK 01/28/94
     */
    else if ( is_midcommon && is_collinear )
    {
      IGRint                    ind11,ind12,ind21,ind22;
      OMuint                    count=0,ind1[2];
      IGRint                    sts,ii;
      IGRboolean                tangency_flag = FALSE;
      IGRdouble                 pt[2][3];
      GRclassid                 classid;
      GRobjid                   ptvar[2];
      struct SKsolvevars        *ptvarnode;
      OM_S_OBJECT_LINKAGE       objlist;
      OM_S_CHANSELECT           chan_to_super;
      
      EMmake_chanselect (SKconstraint_to_super_constrs, &chan_to_super);
      om$get_channel_objects (object = me, p_chanselect = &chan_to_super,
                              size = 1, list = &objlist, count = &count);
      if (count)
      {
        om$get_classid ( objid =objlist.S_objid, osnum = objlist.osnum,
                         p_classid = &classid );
        if ( classid == OPP_SKtangency_class_id )
        {
          /*
           * Find the endpoints of the arcs involved in the tangency constraint, other than the
           * collinear points
           */
          sts = SKget_arc3rd_ptvar( objlist.S_objid, ptobjs, ptvar, ind1 );
          tangency_flag = TRUE;
	  for ( i=0; i<2; i++ )
	  {
            if ( ptvar[i] != NULL_OBJID )
  	      om$send ( msg = message SKvariable.SKgetvar 
                              (&msg_loc, NULL, NULL, NULL, pt[i]),
                        targetid = ptvar[i] );
          }
	}
      }

      for ( i=FIRST; i<=SECOND; i++ )
      {
        for ( j=FIRST; j<=SECOND; j++ )
        {
          if ( i == FIRST )
          {
            if ( j == FIRST )
            {
              ind11 = FIRST;  ind12 = SECOND;
              ind21 = SECOND; ind22 = SECOND;
            }
            else
            {
              ind11 = FIRST;  ind12 = FIRST;
              ind21 = SECOND; ind22 = SECOND;
            }
          }
          else
          {
            if ( j == FIRST )
              continue;    /* no need to process since is_midcommon is TRUE. */
            ind11 = FIRST; ind12 = FIRST;
            ind21 = FIRST; ind22 = SECOND;
          }

          for ( k=X; k<=Y; k++ ) 
          {
            if (var_inx[i][j][k] == SOLVED)
            {
              if ( (var_inx[ind11][ind12][k] != SOLVED ) && 
                   (var_inx[ind21][ind22][k] != SOLVED ) )
              {
                varnode[ind11][ind12][k]->var[k] = point[ind11][ind12][k] + 
                        (varnode[i][j][k]->var[k] - point[i][j][k]);
                varnode[ind21][ind22][k]->var[k] = point[ind21][ind22][k] + 
                        (varnode[i][j][k]->var[k] - point[i][j][k]);

                /*
                 * If this is a tangency constraint, then update the guess for the
                 * endpoints of the arcs also (if they are unsolved).
                 */
                if ( tangency_flag )
                {
                  for ( ii=0; ii<2; ii++ )
                  {
                    if ( ptvar[ii] != NULL_OBJID ) 
                    {
                      if (SKvarlistinx (unsolvedvars, ptvar[ii], k == X ? VAR_X : VAR_Y,
                                        &ptvarnode, &varinx))
                      {
                        ptvarnode->var[k] =  pt[ii][k] + 
                                             (varnode[i][j][k]->var[k] - point[i][j][k]);
                      }
                    }
                  }
                }
              }
            }
          }     
        }
      }
    }
  }
Update_Guess_Over:
 
  for (i=FIRST; i<=SECOND; i++)
  {
    for (j=FIRST; j<=SECOND; j++)
    {
       var[i][j][X] = varnode[i][j][X]->var[X];
       var[i][j][Y] = varnode[i][j][Y]->var[Y];
    }
  }

  /*
   * Plug in the appropriate values in the row of the Jacobian matrix
   */

  adjreq = options & SK_JACOB_ADJACENCY;
  accreq = options & SK_JACOB_ACCURACY;

  delx1 = var[FIRST][SECOND][X] - var[FIRST][FIRST][X];
  dely1 = var[FIRST][SECOND][Y] - var[FIRST][FIRST][Y];
  delx2 = var[SECOND][SECOND][X] - var[SECOND][FIRST][X];
  dely2 = var[SECOND][SECOND][Y] - var[SECOND][FIRST][Y];

  len1 = sqrt ( delx1 * delx1 + dely1 * dely1 );
  len2 = sqrt ( delx2 * delx2 + dely2 * dely2 );
  if (is_parallel || is_collinear)
  {
    use_sine_formula = TRUE;
    trigval = 0.0;
  }
  else
  {
    use_sine_formula = FALSE;
    if (is_normal)
      trigval = 0.0;
    else
    {
      trigval = cos (angle * (M_PI / 180.0));
      len1_len2 = len1 / len2;
      len2_len1 = len2 / len1;
    }
  }

  if (jacobian)
  {
    if ((inx = var_inx[FIRST][FIRST][X]) != SOLVED)
    {
      if (adjreq)
        jacobian[inx] = TRUE;
      else
      {
        addterm = trigval ? trigval * len2_len1 * delx1 : 0.0;
        if (use_sine_formula)
          jacobian[inx] = -dely2 + addterm;
        else
          jacobian[inx] = -delx2 + addterm;
      }
    }
  
    if ((inx = var_inx[FIRST][FIRST][Y]) != SOLVED)
    {
      if (adjreq)
        jacobian[inx] = TRUE;
      else
      {
        addterm = trigval ? trigval * len2_len1 * dely1 : 0.0;
        if (use_sine_formula)
          jacobian[inx] = delx2 + addterm;
        else
          jacobian[inx] = -dely2 + addterm;
      }
    }
  
    if ((inx = var_inx[FIRST][SECOND][X]) != SOLVED)
    {
      if (adjreq)
        jacobian[inx] = TRUE;
      else
      {
        addterm = trigval ? trigval * len2_len1 * delx1 : 0.0;
        if (use_sine_formula)
          jacobian[inx] = dely2 - addterm;
        else
          jacobian[inx] = delx2 - addterm;
      }
    }
  
    if ((inx = var_inx[FIRST][SECOND][Y]) != SOLVED)
    {
      if (adjreq)
        jacobian[inx] = TRUE;
      else
      {
        addterm = trigval ? trigval * len2_len1 * dely1 : 0.0;
        if (use_sine_formula)
          jacobian[inx] = -delx2 - addterm;
        else
          jacobian[inx] = dely2 - addterm;
      }
    }
  
    if ((inx = var_inx[SECOND][FIRST][X]) != SOLVED)
    {
      if (adjreq)
        jacobian[inx] = TRUE;
      else
      {
        addterm = trigval ? trigval * len1_len2 * delx2 : 0.0;
        if (use_sine_formula)
          jacobian[inx] = dely1 + addterm + (is_midcommon ?
                                              jacobian[inx] : 0.0);
        else
          jacobian[inx] = -delx1 + addterm + (is_midcommon ?
                                               jacobian[inx] : 0.0);
      }
    }
  
    if ((inx = var_inx[SECOND][FIRST][Y]) != SOLVED)  
    {
      if (adjreq)
        jacobian[inx] = TRUE;
      else
      {
        addterm = trigval ? trigval * len1_len2 * dely2 : 0.0;
        if (use_sine_formula)
          jacobian[inx] = -delx1 + addterm + (is_midcommon ?
                                               jacobian[inx] : 0.0);
        else
          jacobian[inx] = -dely1 + addterm + (is_midcommon ?
                                               jacobian[inx] : 0.0);
      }
    }
  
    if ((inx = var_inx[SECOND][SECOND][X]) != SOLVED)  
    {
      if (adjreq)
        jacobian[inx] = TRUE;
      else
      {
        addterm = trigval ? trigval * len1_len2 * delx2 : 0.0;
        if (use_sine_formula)
          jacobian[inx] = -dely1 - addterm;
        else
          jacobian[inx] = delx1 - addterm;
      }
    }
  
    if ((inx = var_inx[SECOND][SECOND][Y]) != SOLVED)  
    {
      if (adjreq)
        jacobian[inx] = TRUE;
      else
      {
        addterm = trigval ? trigval * len1_len2 * dely2 : 0.0;
        if (use_sine_formula)
          jacobian[inx] = delx1 - addterm;
        else
          jacobian[inx] = dely1 - addterm;
      }
    }
  }

  if (funcval)
  {
    addterm = trigval ? trigval * len1 * len2 : 0.0;
    if (use_sine_formula)
      *funcval = -(delx1 * dely2 - dely1 * delx2 - addterm);
    else
      *funcval = -(delx1 * delx2 + dely1 * dely2 - addterm);
  }

  /*
   * If the option to check accuracy was set then obtain the relevant
   * tolerances and check.
   */
  if (accreq)
  {
    SKgettol (&lentol, NULL);
    if (is_normal)
    {
      diff_value = fabs(delx1*delx2 + dely1*dely2);
      if (diff_value > lentol)
        *msg = EMS_I_OutOfBounds;
    }
    else if (is_collinear || is_parallel)
    {
      diff_value = fabs(delx1 * dely2 - dely1 * delx2);
      if (diff_value > lentol)
        *msg = EMS_I_OutOfBounds;
    }
    else
    {
      chkterm = delx1 * delx2 + dely1 * dely2;
      if (fabs(len1) > lentol && fabs(len2) > lentol)
      {
        diff_value = fabs(trigval - (delx1 * delx2 + dely1 * dely2)/ (len1 * len2));
        if (diff_value > lentol)
          *msg = EMS_I_OutOfBounds;
      }
    }
  }

  DEBUG_REPORT (accreq, "Relangle residual", my_id, diff_value);

ret_end:
  EMWRAPUP ( *msg, stat_OM, "SKrelornt.SKmakejacobian" );
  return stat_OM;
}

/*

Name
  SKget_arc3rd_ptvar

Description
  It gets the arc's third ptvar which is used for UPDATE_GUESSing for the other 2 points.

Synopsis

Return Value
  TRUE if success

Notes

Index

History
  12/28/93 : G Mallikarjuna : created

 */

static IGRint SKget_arc3rd_ptvar( tangency_id, ptobjs, ptvar, index )
GRobjid tangency_id;   /* IN */
GRobjid ptobjs[2][2];  /* IN */
GRobjid ptvar[2];      /* OUT */
IGRint  index[2];      /* OUT */
{
  IGRint                i;
  IGRlong               status=TRUE;
  OMuint                count=0,count1=0;
  IGRint                ptvar_count=0;
  GRclassid             classid;
  GRobjid               pt_vars[3];
  struct GRid           grid,tangency_ptvar;
  OM_S_OBJECT_LINKAGE   objlist[3];
  OM_S_CHANSELECT       chan_to_geom, chan_to_defpts, chan_to_vars;
      
  EMmake_chanselect (SKvariable_to_geometries, &chan_to_geom);
  EMmake_chanselect (SKconstraint_to_variables, &chan_to_vars);
  EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
  
  index[0] = 0;
  index[1] = 0;
  ptvar[0] = NULL_OBJID;
  ptvar[1] = NULL_OBJID;

  status = om$get_objid_at_index(objid = tangency_id, p_chanselect = &chan_to_vars,
                                 index = 0, objidaddr = &tangency_ptvar.objid, 
                                 osnumaddr = &tangency_ptvar.osnum);
  if ( !(1 & status) ) goto ret_end; 

  om$get_channel_count (objid = tangency_ptvar.objid, p_chanselect = &chan_to_geom,
                        count = &count);
  for ( i=0; i<count; i++)
  {
    status = om$get_objid_at_index(objid = tangency_ptvar.objid, 
                                   p_chanselect = &chan_to_geom,
                                   index = i, 
                                   objidaddr = &grid.objid, 
                                   osnumaddr = &grid.osnum);
    if ( !(1 & status) ) goto ret_end; 
    status = om$get_classid ( objid = grid.objid, osnum = grid.osnum, 
                              p_classid = &classid );
    if ( !(1 & status) ) goto ret_end; 
 
    if ( classid == OPP_SKarc_class_id )
    {
      om$get_channel_objects (objid = grid.objid, osnum = grid.osnum , 
                              p_chanselect = &chan_to_defpts,
                              size = 3, list = objlist, count = &count1);
      if ( count1 != 3 ) { status = FALSE; goto ret_end; }
      pt_vars[0] = objlist[0].S_objid;
      pt_vars[1] = objlist[1].S_objid;
      pt_vars[2] = objlist[2].S_objid;
      
      SKget_unmatched_ptvar( ptobjs, pt_vars, &ptvar[ptvar_count], &index[ptvar_count] );
      ptvar_count++;
      if ( ptvar_count >= 2 ) goto ret_end;
    }
  }

ret_end:
  return(status);
}

static void SKget_unmatched_ptvar( colli, ptvars, ptvar, index )
GRobjid colli[2][2]; /* IN  */
GRobjid ptvars[3];   /* IN  */
GRobjid *ptvar;      /* OUT */
int     *index;      /* OUT */   
{
  int ii,ind1=0,ind2=0,jj;
  GRobjid gmk_ptvars[3];

  gmk_ptvars[0] = colli[FIRST][FIRST];
  gmk_ptvars[1] = colli[FIRST][SECOND];
  gmk_ptvars[2] = colli[SECOND][SECOND];
  for ( ii=0; ii<3; ii++)
  {
    if ( ( ptvars[ii] != gmk_ptvars[0] ) && 
         ( ptvars[ii] != gmk_ptvars[1] ) &&
         ( ptvars[ii] != gmk_ptvars[2] ) )
    {
      *ptvar = ptvars[ii];

      if ( ii == 0 )
      {
        ind1 = 1; ind2 = 2;
      }
      else if ( ii == 1 )
      {
        ind1 = 0; ind2 = 2;
      }
      else 
      {
        ind1 = 0; ind2 = 1;
      }

      for ( jj = FIRST; jj <= SECOND; jj++ )
      {
        if(((ptvars[ind1] == colli[jj][FIRST]) && (ptvars[ind2] == colli[jj][SECOND])) ||
           ((ptvars[ind1] == colli[jj][SECOND]) && (ptvars[ind2] == colli[jj][FIRST])))
          *index = jj;
      }
      return;
    }
  }
  *ptvar = NULL_OBJID;
}

end implementation SKrelornt;

