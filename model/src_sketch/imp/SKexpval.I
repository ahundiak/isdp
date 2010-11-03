class implementation SKexplicit;

#include <string.h>
#include "exdef.h"
#include "exmacros.h"
#include "DIdef.h"
#include "expression.h"
#include "dimdef.h"
#include "dimplcmacros.h"
#include "EMSasnucdef.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_SKptpt_class_id, OPP_SKrelang_class_id;
extern GRclassid OPP_SKfixang_class_id, OPP_SKradial_class_id;

from DMroot import inq_geom_type;
from SKmgr import SKmgrprops, SKsaveolddim;

/*

Name
  SKexplicit methods

Abstract
  Methods to create and modify explicit constraint expressions

Synopsis

Description

Return Value

Notes

Index

Keywords

History
  12/16/93 : Rajiv Agrawal : moved the code to save old dimension value before
                             it gets modified.

  04/25/94 : Satya         : md_env.md_env.matrix was not initialized --
			     TR# 119418290 

  01/09/95 : Satya         : Checked in the fix into EMS 3.2

 */


method modify ( char *name; char *syntax ; short *msg )
{
  char                geom_type;
  short               s_msg_loc;
  OMuint              count;
  long                stat_OM, msg_loc;
  GRobjid             mgrobj;
  struct GRid         dim_grid;
  struct GRmd_env     md_env;
  OM_S_CHANSELECT     chan_to_parents, chan_to_comps;
  OM_S_OBJECT_LINKAGE objlist;

  stat_OM = OM_S_SUCCESS;
  *msg = TRUE;

  /*
   * If this expression is being modified, the old value of this dimension
   * needs to be recorded as the save state information in the manager.
   * Also, the sketch needs to be marked as out of date. 
   */

  stat_OM = om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &mgrobj),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, FALSE, ret_end);

  stat_OM = om$send (msg = message SKmgr.SKsaveolddim (&msg_loc, 
						       NULL,
      						       ME.expression->value, 
						       my_id), 
		     targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, FALSE, ret_end);

  stat_OM = om$send (msg = message SKmgr.SKmgrprops (&msg_loc, 
						     SK_CHGPROPS_ON,
      						     SK_MGR_OUTOFDATE, 
						     NULL), 
		     targetid = mgrobj);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, FALSE, ret_end);

  /*
   * Invoke the default method to actually perform the modify
   */
  stat_OM = om$send (mode = OM_e_wrt_message, 
      		     msg = message expression.modify ( name, 
						       syntax, 
						       &s_msg_loc ),
                     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM), *msg, FALSE, ret_end);

  /* if the expression could not be computed for some reasons (bad syntax),
     we exit -> the parser has already returned output */

  if (s_msg_loc != EXP_S_SUCCESS)
  {
    *msg = s_msg_loc;
    return stat_OM;
  }

  /*
   * The dimension handle owned by this object needs to have it's type set 
   * to implicit if this expression has any parents driving it.
   */

  EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
  count = 0;
  om$get_channel_objects (object = me, 
			  p_chanselect = &chan_to_comps,
                          count = &count, 
			  size = 1, 
			  list = &objlist);
  if (count)
  {
    md_env.md_env.matrix_type = MAIDMX;

    ex$get_modid (mod_osnum = OM_Gw_current_OS,
                  mod_id = &md_env.md_id.objid);

    md_env.md_id.osnum = OM_Gw_current_OS;
    /*** The module environment matrix should be intitialized to identity
	 matrix  --- Satya **/
    MAidmx(&msg_loc,md_env.md_env.matrix);

    dim_grid.objid = objlist.S_objid;
    dim_grid.osnum = OM_Gw_current_OS;

    geom_type = NULL;
    om$send (msg = message DMroot.inq_geom_type (&geom_type),
             targetid = dim_grid.objid);

    EMmake_chanselect (NDfather_father, &chan_to_parents);
    count = 0;
    om$get_channel_count (object = me, 
			  p_chanselect = &chan_to_parents,
                          count = &count);
    if (count && !(geom_type & DIM_IMPLICIT))
    {
      dm$set_type (type = DIM_IMPLICIT, 
		   update = TRUE, 
		   md_env = &md_env,
                   dim_grid = &dim_grid);
    }
    else if (!count && geom_type & DIM_IMPLICIT)
    {
      dm$set_type (type = DIM_IMPLICIT, 
		   op_code = BIT_CLEAR, 
		   update = TRUE,
                   md_env = &md_env, 
		   dim_grid = &dim_grid);
    }
  }

ret_end:
  msg_loc = *msg;
  EMWRAPUP (msg_loc, stat_OM, "SKexplicit.modify");
  return (stat_OM);
}


method SKcreate_expression (long *msg; char *name; double value)
{
  char              expression[GR_MAX_CHAR], dim_name[GR_MAX_CHAR];
  short             msg_loc;
  int               type;
  long              stat_OM;
  GRclassid         myclass;
  extern IGRboolean EMdefnewname();
  struct GRid my_grid;
  IGRboolean is_removed;

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  sprintf (expression, "%lf", value);
  if (name)
    strcpy (dim_name, name);
  else
  {
    om$get_classid (object = me, p_classid = &myclass);

    if (om$is_ancestry_valid (subclassid = myclass,
        superclassid = OPP_SKptpt_class_id) == OM_S_SUCCESS)
      type = EMSdistance;
    else if (om$is_ancestry_valid (subclassid = myclass,
        superclassid = OPP_SKrelang_class_id) == OM_S_SUCCESS)
      type = EMSangle;
    else if (om$is_ancestry_valid (subclassid = myclass,
        superclassid = OPP_SKfixang_class_id) == OM_S_SUCCESS)
      type = EMSangle;
    else if (om$is_ancestry_valid (subclassid = myclass,
        superclassid = OPP_SKradial_class_id) == OM_S_SUCCESS)
      type = EMSraddist;
    else
      type = EMSscalar;

    EMdefnewname (dim_name, OM_Gw_current_OS, type);
  }

  stat_OM = om$send (msg = message expression.create (dim_name, expression,
      &msg_loc), targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
 
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  stat_OM = NDremove_from_batch_list(my_grid, &is_removed);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);  
  
  
ret_end:
  EMWRAPUP (*msg, stat_OM, "SKcreate_expression");
  return (stat_OM);
}


/*
 * We need to remember old dimension values to support undo for the profile.
 * When the SKmgr.SKsavestate is sent, the dimensions may have been modified
 * already (for instance if Edit Dimension is used). We need to support an
 * array of these values because delay can be on, resulting of several dimensions
 * being modified before SKmgr.SKsavestate is sent.
 */
%safe
static double      *SKlast_values;
static struct GRid *SKlast_dims;
static int         SKcount = 0;
%endsafe


void SKforget_dims ()
/*
 * Clear the array of dims.
 */
{
  if (SKcount)
  {
    SKcount = 0;
    free ( SKlast_dims );
    free ( SKlast_values );
  }
}


SKget_last_dim ( osnum, objid, p_value )
GRspacenum  osnum    /* The osnum of the dim				IN  */;
GRobjid     objid    /* The objid of the dim				IN  */;
IGRdouble  *p_value /* Its value          				OUT */;
{
  int i;
  
  for (i = 0;i < SKcount; i++)
    if (osnum == SKlast_dims [i].osnum && objid == SKlast_dims [i].objid)
    {
      *p_value = SKlast_values [i];
      SKlast_dims [i].osnum = 0;
      SKlast_dims [i].objid = NULL_OBJID;

      return 1;
    }

  return 0;
}


method SKputval ( long *msg; unsigned short opts; double value; char *rhs)
{
  char                geom_type, *p_valstr, name[DI_PATH_MAX], valstr[20];
  char                save_pretty_print[EXP_MAX_LEN];
  short               s_msg_loc;
  OMuint              count;
  long                stat_OM, msg_loc;
  GRobjid             mgrobj=NULL_OBJID;
  struct GRid         dim_grid;
  struct GRmd_env     md_env;
  enum OM_e_wrt_flag  wrt_flag;
  OM_S_CHANSELECT     chan_to_comps, chan_to_parents;
  OM_S_OBJECT_LINKAGE objlist;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Change the value of the variable without
   * making the SKmgr out of date.  Used for Show Underconstrained
   * Profile command.  - Rajiv 10/19/92
   */
  if (opts & SK_UPDATE_DONOTPOST)
  {
    ME.expression->value = value;
    goto ret_end;    
  }
  
  /*
   * Save the my value (SKmgr.SKsavestate is gonna call me
   */
  if (SKcount)
  {
    SKlast_dims = (struct GRid *)realloc ( SKlast_dims, 
        (SKcount + 1) * sizeof ( struct GRid ) );
    SKlast_values = (double *)realloc ( SKlast_values, 
        (SKcount + 1) * sizeof ( double ) );
  }
  else
  {
    SKlast_dims = (struct GRid *)malloc ( sizeof ( struct GRid ) );
    SKlast_values = (double *)malloc ( sizeof ( double ) );
  }
  
  if (SKlast_values && SKlast_dims)
  {
    SKlast_dims [SKcount].osnum = OM_Gw_current_OS;
    SKlast_dims [SKcount].objid = my_id;
    SKlast_values [SKcount] = me->value;
    SKcount++;
  }
  
  /*
   * Mark this sketch as out of date
   */

  om$send (msg = message SKconstraint.SKgetmgr (&msg_loc, &mgrobj),
           targetid = my_id);

  if (msg_loc == EMS_I_NotFound)
  {
     goto next;
  }

  om$send (msg = message SKmgr.SKmgrprops (&msg_loc, 
					   SK_CHGPROPS_ON,
      				           SK_MGR_OUTOFDATE, 
					   NULL), 
	   targetid = mgrobj);

  /*
   * Obtain the name and modify the expression
   */

  stat_OM = om$send (msg = message SKexplicit.SKgetname (&msg_loc, 
							 NULL,
                                                         name), 
		     targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  if (msg_loc != EMS_I_NotFound)
  {
    wrt_flag = opts & SK_OPT_SAVE_OLD_VALUE ? 
        OM_e_wrt_object : OM_e_wrt_message;
    if (rhs)
      p_valstr = rhs;
    else
    {
      sprintf (valstr, "%lf", value);
      p_valstr = valstr;
    }

    strncpy (save_pretty_print, ME.expression->pretty_print, EXP_MAX_LEN-1);

    save_pretty_print[EXP_MAX_LEN-1] = NULL;

    stat_OM = om$send (mode = wrt_flag, 
                       msg = message expression.modify (name, 
							p_valstr, 
							&s_msg_loc),
        	       targetid = my_id);

    /* if the expression could not be computed for some reasons (bad syntax),
       we exit -> the parser has already returned output */

    if (s_msg_loc != EXP_S_SUCCESS)
    {
      if (s_msg_loc == EXP_E_LOOP)
        *msg = EMS_I_Cycle;
      else
        *msg = s_msg_loc;

      return OM_S_SUCCESS;
    }

    if (!strncmp (save_pretty_print, ME.expression->pretty_print, 
	          EXP_MAX_LEN))
      *msg = EMS_I_Useless;

    if (wrt_flag == OM_e_wrt_message)
    {
      /*
       * The dimension handle owned by this object needs to have it's type set 
       * to implicit if this expression has any parents driving it; to
       * non-implicit if no parents driving it.
       */

      EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
      count = 0;
      om$get_channel_objects (object = me, 
			      p_chanselect = &chan_to_comps,
          		      count = &count, 
			      size = 1, 
			      list = &objlist);
      if (count)
      {
        md_env.md_env.matrix_type = MAIDMX;

        ex$get_modid (mod_osnum = OM_Gw_current_OS,
                      mod_id = &md_env.md_id.objid);
        md_env.md_id.osnum = OM_Gw_current_OS;

        dim_grid.objid = objlist.S_objid;
        dim_grid.osnum = OM_Gw_current_OS;

        geom_type = NULL;
        om$send (msg = message DMroot.inq_geom_type (&geom_type),
                 targetid = dim_grid.objid);

        EMmake_chanselect (NDfather_father, &chan_to_parents);
        count = 0;
        om$get_channel_count (object = me, 
			      p_chanselect = &chan_to_parents,
            		      count = &count);
        if (count && !(geom_type & DIM_IMPLICIT))
        {
          dm$set_type (type = DIM_IMPLICIT, update = TRUE, md_env = &md_env,
                       dim_grid = &dim_grid);
        }
        else if (!count && geom_type & DIM_IMPLICIT)
        {
          dm$set_type (type = DIM_IMPLICIT, op_code = BIT_CLEAR, update = TRUE,
                       md_env = &md_env, dim_grid = &dim_grid);
        }
      }
    }
  }

next:
  ME.expression->value = value;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKexplicit.SKputval");
  return(stat_OM);
}

method SKstoreval(long *msg; double value)
{
  *msg = EMS_S_Success;

  ME.expression->value = value;
  ME.SKconstraint->props &= ~SK_NOVALUE;

  return (OM_S_SUCCESS);
}

end implementation SKexplicit;
