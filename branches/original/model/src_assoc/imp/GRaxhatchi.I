class implementation GRaxhatch;

#include "bserr.h"
#include "bsparameters.h"
#include "emssfintdef.h" /* For EMSINT_TRIM... */
#include "asbox.h" /* For NULL_GRID */
#include "nddef.h"
#include "GRaxhatch.h"
#include "grerr.h"
#include "dpmacros.h"
#include "OMprimitives.h"

extern GRclassid OPP_ASsource_class_id;

method GRxhadd_bdry(IGRlong                *msg; 
                    IGRint                  num_boundaries;
                    struct EMSobject_info  *boundaries)

/* *******************************************************************

Description

 This method adds boundaries to the crosshatch element (the crosshatch
 pattern will not go through the boundary elements).

Arguments
 Input
  num_boundaries : number of boundary elements to be added
  boundaries : object ids, osnums and environments of the boundary
               elements

 Output
  msg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: If all goes well.
  MSFAIL: If there is failure

History
 11/01/91 : WBC  : Creation
 08/22/94 :Vidya : fix for TR 119420775 , checks to see if boundaries
		   are ASsource and sends in the actual objects
 09/19/94 : Vidya : om-macro call is replaced by EFisAncestryValid() which
		    returns either success or failure. 
*********************************************************************** */

{
    IGRlong          temp_msg;
    IGRint           status;
    struct GRid     *source_list;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;
    source_list = NULL;

    source_list = (struct GRid *)alloca(sizeof(struct GRid) * num_boundaries);

    if (source_list)
    {
        status = om$send(msg = message EMSassoc.EMmake_source(&temp_msg, NULL,
                                                              num_boundaries,
                                                              boundaries,
                                                              source_list),
                         targetid = my_id);

        if (1 & status & temp_msg)
        {
            status = om$send(msg = message NDnode.NDconnect(num_boundaries,
                                                            source_list,
                                                            NULL_GRID, ND_ADD),
                             targetid = my_id);
        }
        else
            *msg = MSFAIL;
    }
    else
        *msg = MSFAIL;

    return(status);
}

method GRxhremove_bdry(IGRlong         *msg; 
                       IGRint           num_boundaries;
                       struct GRid     *boundaries)

/* *******************************************************************

Description

 This method removes boundaries from the crosshatch element.

Arguments
 Input
  num_boundaries : number of boundary elements to be removed
  boundaries : object ids and osnums of the boundary elements

 Output
  msg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: If all goes well.
  MSFAIL: If there is failure

History
 11/01/91 : WBC  : Creation
*********************************************************************** */

{
    IGRdouble        matrix[16];
    IGRint           status,
                     index,
                     index2,
                     count,
                     num_roots;
    struct GRid      go_grid,
                    *roots;
    OM_S_CHANSELECT  chanselect;
    IGRshort         matrix_type;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;
    num_roots = 0;

    /* get the object ids of my boundaries and compare them to the boundaries
     * to be deleted and if there is a match, disconnect the root object
     * corresponding to the boundary object to be removed
     */

    om$make_chanselect(channame = "NDfather.father",
                       p_chanselect = &chanselect);

    status = om$get_channel_count(objid = my_id,
                                  p_chanselect = &chanselect,
                                  count = (OMuint *)&count);

    roots = NULL;
    roots = (struct GRid *) alloca(count * sizeof(struct GRid));

    if (! roots)
    {
        *msg = MSFAIL;
        goto wrapup;
    }

    for (index = 1; index < count; index++)
    {
        status = om$send(msg = message NDnode.ASreturn_go(&go_grid,
                                                          &matrix_type,
                                                          matrix),
                         p_chanselect = &chanselect,
                         from = index,
                         to = index);
        if (1 & status)
        {
            for (index2 = 0; index2 < num_boundaries; index2++)
            {
                if ((go_grid.objid == boundaries[index2].objid) &&
                    (go_grid.osnum == boundaries[index2].osnum))
                {
                    status = om$get_objid_at_index(objid = my_id,
                                                   p_chanselect = &chanselect,
                                                   index = index,
                                                   objidaddr = &roots[num_roots].objid,
                                                   osnumaddr = &roots[num_roots].osnum);
                    if (1 & status)
                    {
                        num_roots++;
                    }

                    break;
                }
            }
        }
    }

    if (num_roots)
    {
        status = om$send(msg = message NDnode.NDdisconnect(num_roots, roots),
                         targetid = my_id);
    }

wrapup:

    return(status);
}

method GRxhget_definition(IGRlong               *msg; 
                          IGRshort              *alt_color;
                          IGRdouble             *alt_angle;
                          IGRdouble             *alt_spacing;
                          IGRdouble             *origin;
                          struct GRxhatchpat    *pattern_def;
                          struct GRid           *window_grid)

/* *******************************************************************

Description

 This method gets the crosshatch parameters of a crosshatch object.

Arguments
 Output
  msg : Completion message.
  alt_color : the color of the crosshatch elements
  alt_angle : the angle of the crosshatching pattern elements
  alt_spacing : the spacing between crosshatching pattern elements
  origin : origin point of the crosshatching pattern elements
  pattern_def : pattern used to crosshatch

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: Always returns success.

History
 11/01/91 : WBC  : Creation
*********************************************************************** */

{
  struct GRaxhatch_info  *info;

  *msg = MSSUCC;
  info = (struct GRaxhatch_info *) me->info;

  *alt_color = info->xhatch_color;
  *alt_angle = info->xhatch_angle;
  *alt_spacing = info->xhatch_spacing;
  origin[0] = info->origin[0];
  origin[1] = info->origin[1];
  origin[2] = info->origin[2];
  *pattern_def = info->pattern_def;
  *window_grid = info->window_grid;
  
  return(OM_S_SUCCESS);
}

method GRxhput_definition(IGRlong                *msg; 
                          IGRshort               *alt_color;
                          IGRdouble              *alt_angle;
                          IGRdouble              *alt_spacing;
                          IGRdouble              *origin;
                          struct GRxhatchpat     *pattern_def;
                          struct GRid            *window_grid)

/* *******************************************************************

Description

 This method sets the crosshatch parameters of a crosshatch object.

Arguments
 Input
  alt_color : the color of the crosshatch elements
  alt_angle : the angle of the crosshatching pattern elements
  alt_spacing : the spacing between crosshatching pattern elements
  origin : origin point of the crosshatching pattern elements
  pattern_def : pattern used to crosshatch

 Output
  msg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: Always returns success.

History
 11/01/91 : WBC  : Creation
*********************************************************************** */

{
  struct GRaxhatch_info  *info;

  *msg = MSSUCC;
  info = (struct GRaxhatch_info *) me->info;

  info->xhatch_color = *alt_color; 
  info->xhatch_angle = *alt_angle;
  info->xhatch_spacing = *alt_spacing;
  info->origin[0] = origin[0]; 
  info->origin[1] = origin[1];
  info->origin[2] = origin[2];
  info->pattern_def = *pattern_def;
  info->window_grid = *window_grid;

  return(OM_S_SUCCESS);
}

method GRxhcompute(IGRlong               *msg;
                   struct GRid           *elem_to_xhatch;
                   struct GRmd_env       *module_info;
                   IGRint                 num_boundaries;
                   struct GRid           *boundaries;
                   struct GRaxhatch_info *xhatch_info;
                   struct GRid           *xhatch_gg)

/* *******************************************************************

Description

   This method will construct the lines which represent the crosshatching.
   This method is envoked when the crosshatching is initially created
   and if the crosshating is assocative whenever the primary element
   or one of the boundaries is modified or manipulated.

Arguments
 Input
  elem_to_xhatch : the element to be crosshatched
  module_info : Module enviroment the crosshatching
                lines are to be conntructed in.
  num_boundaries : the number of boundaries the crosshatch element has
  boundaries : grids of the boundaries
  xhatch_info : crosshatching parameters (spacing, angle, etc.)
  xhatch_gg : The object id and object space # of a graphic group
              the constructed lines will be in.  If NULL_objid is
              passed in as the objid, the method will contruct a
              graphic group.

 Output
  msg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: If successful.
  MSFAIL: If failure.

History
 11/01/91 : WBC  : Creation
*********************************************************************** */

{
  extern IGRint                GRgenerate_crosshatch();

  IGRlong                      status;   
  IGRlong                      index = 0;
  IGRlong                      conn_flag = 1;
  IGRint                       count,sts;
  IGRint                       ii,i,j;
  struct GRmd_env              mod_env;
  struct GRid                 *objects = NULL,
                               my_grid;

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  status = om$send(msg = message  GRowner.GRget_number_components(msg,
                                                                  &count), 
                   targetid = xhatch_gg->objid,
                   targetos = xhatch_gg->osnum);

  if( (status & 1) && (*msg & 1) )
    {
      if(count > 0)
      {
        objects = (struct GRid *)om$malloc(size=(sizeof(struct GRid))*count);
        if(objects == NULL) return(OM_E_NODYNMEM);
      
        status = om$send(msg = message GRowner.GRget_components(msg,
							      &mod_env,
  							      objects,
							      count,
							      &count,
							      0,
							      OM_K_MAXINT), 
		       targetid = xhatch_gg->objid,
		       targetos = xhatch_gg->osnum);

        /* if any of the boundaries have been added to the crosshatching
         * graphic group, don't delete them
         */

        for(i=0; i<count; i++)
	  {
	    for(j=0; j<num_boundaries; j++)
	      {
	        if((boundaries[j].objid == objects[i].objid) &&
		  (boundaries[j].osnum == objects[i].osnum) )
		  {
		    objects[i].objid = NULL_OBJID;
		  }
	      }

	    if(objects[i].objid != NULL_OBJID)
	      {
	        status = om$send(msg = message GRconnector.GRdisconn(msg,
		  						   xhatch_gg),
	  	  	         targetid = objects[i].objid,
			         targetos = objects[i].osnum);

	         status = om$send(msg = message GRgraphics.GRdelete(msg,
	  							  module_info),
	  	   	          targetid = objects[i].objid,
			          targetos = objects[i].osnum);
	      }
	  }
        if(objects) om$dealloc(ptr = objects);
      }
    }
  else
    {
      xhatch_gg->osnum = OM_Gw_current_OS;
      status = om$construct(osnum = xhatch_gg->osnum,
    			    classname = "GRxhgg",
			    p_objid = &xhatch_gg->objid);

      status = om$send(msg = message GRconnector.GRflexconn( msg,
                                                             &conn_flag,
							     &my_grid, 
							     &index,
							     &index),
		       targetid = xhatch_gg->objid,
		       targetos = xhatch_gg->osnum);
    }

  /* call compute function */
  if(xhatch_info->xhatch_spacing == 0 && xhatch_info->pattern_def.num_angles==1 &&
     xhatch_info->pattern_def.pass[0].num_lines==1 && 
     xhatch_info->pattern_def.pass[0].lines[0].perp_dist_next_line!=0)
    {
     xhatch_info->xhatch_spacing = xhatch_info->pattern_def.pass[0].lines[0].perp_dist_next_line;
      xhatch_info->pattern_def.pass[0].lines[0].perp_dist_next_line = 0;
    }
/* begin of fix for TR 119420775 */
/* check to see if the boundaries are ASsource objects
 * if so, get the actual ids to which they are connected to
 */
  for(ii = 0; ii< num_boundaries;ii++)
    {
 
    if (EFisAncestryValid(msg,boundaries[ii].objid,
                                boundaries[ii].osnum,
                                OPP_ASsource_class_id, TRUE))
      {
      struct GRid go;
      struct GRmd_env obj_env;
      sts=om$send(msg = message NDnode.ASreturn_go(&go,
                                                   &obj_env.md_env.matrix_type,
                                                   obj_env.md_env.matrix),
                    targetid = boundaries[ii].objid,
                    targetos = boundaries[ii].osnum);
      if(!(sts & 1)) return(sts);
      boundaries[ii].objid = go.objid;
      }
    } /* end of fix for TR 119420775 */

  sts = GRgenerate_crosshatch(msg,
                              elem_to_xhatch,
                              num_boundaries,
                              boundaries,
	  		      &xhatch_info->window_grid,
                              xhatch_gg,
   			      my_grid,
                              xhatch_info->xhatch_color,
                              xhatch_info->xhatch_spacing,
                              xhatch_info->xhatch_angle,
                              &xhatch_info->pattern_def,
                              xhatch_info->origin,
			      module_info,
			      TRUE);
  if (! (1 & sts & *msg))
  {
    status = OM_E_ABORT;
  }

  return(status);
}

method GRxhget_gg(IGRlong         *msg; 
                  struct GRid     *xhatch_gg)

/* *******************************************************************

Description

 This method gets the crosshatch object's graphic group object.

Arguments
 Output
  msg : Completion message.
  xhatch_gg : object id and osnum of the crosshatch object's 
              crosshatch graphic group (which is connected to all
              the crosshatch elements)

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: If success.
  MSFAIL: If failure.

History
 11/01/91 : WBC  : Creation
*********************************************************************** */

{
    IGRlong                      status;   
    OM_S_CHANSELECT              chansel;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    status = om$make_chanselect(chanaddr     = &me->to_components,
     		                p_chanselect = &chansel );

    status = om$get_objid_at_index(objid = my_id, 
   				   p_chanselect = &chansel,
				   index = 0, 
				   objidaddr = &xhatch_gg->objid, 
				   osnumaddr = &xhatch_gg->osnum);

    if(! (status & 1))
        *msg = MSFAIL;

    return(status);
}

method GRdisplay(IGRlong *msg; 
                 IGRshort *type; 
	         IGRmatrix matrix;
		 enum GRdpmode *mode; 
		 struct GRid *display_info)

/* *******************************************************************

Description

 This method sends the GRdisplay message out the object's
 to_components channel.

Arguments
 Input
  type : matrix type
  matrix : display environment matrix
  mode : display mode
  display_info : display information

 Output
  msg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: If success.
  MSFAIL: If failure.

History
 11/08/91 : WBC  : Creation
*********************************************************************** */

{
  IGRlong                      status;   
  OM_S_CHANSELECT              chansel;
  
  status = om$make_chanselect(channame     = "GRcmpowner.to_components",
			      p_chanselect = &chansel );

  status = om$send(msg = OPPmargs,
		   p_chanselect = &chansel);

  return(status);
}

method GRlocate_owner ( IGRlong *msg;
                        struct GRlc_cvl *cvl;
                        struct GRlc_path *path;
                        IGRint *path_position)

/* *******************************************************************

Description

 This method returns GR_I_NO_RESPONSE so that its components will
 locate themselves if they are eligible.

Arguments
 Input
  cvl : locate information
  path : located elements
  path_position : last located element

 Output
  msg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: If success.
  MSFAIL: If failure.

History
 11/20/91 : WBC  : Creation
*********************************************************************** */

{
    *msg = GR_I_NO_RESPONSE;
    return(OM_S_SUCCESS);
}

method NDparent_deleted(IGRlong *msg;
                        IGRint count_deleted; struct GRid list_deleted [];
                        struct GRid *new_obj; struct GRmd_env *md_env)

/* *******************************************************************

Description

 This method checks to see which parents are being deleted and if the
 crosshatch's outer boundary (the element that's crosshatch) is being
 deleted, the crosshatch object is erased and deleted.  If only internal
 boundaries are being deleted, they are disconnected from the myself
 and the crosshatch is recomputed.

Arguments
 Input
  count_deleted : number of parents being deleted
  list_deleted : the parents being deleted
  md_env : module environment of the objects

 Output
  msg : Completion message.
  new_obj : resultant object after the deleted parents are taken into
            account; in this case will always return my_id

Notes
 Upon exit the completion code will be one of the following:
  MSSUCC: If success.
  MSFAIL: If failure.

History
 11/21/91 : WBC  : Creation
*********************************************************************** */

{
    IGRlong                 status;
    IGRint                  index,
                            count;
    OM_S_CHANSELECT         chansel;
    IGRmatrix              *matr[1];
    struct GRid             xhatched_obj,
                            my_grid,
                            gg_grid,
                           *parents=NULL;
    struct GRaxhatch_info  *xhatch_info;
    IGRboolean              xhatched_obj_deleted;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    if (new_obj)
    {
        new_obj->osnum = OM_Gw_current_OS;
        new_obj->objid = my_id;
    }

    /* determine if the object that is crosshatched is being deleted and if
     * it is, delete the crosshatch object; otherwise disconnect the deleted
     * parents and recompute the crosshatch
     */

    om$make_chanselect(channame = "NDfather.father",
		       p_chanselect = &chansel);

    status = om$get_objid_at_index(objid = my_id, 
                                   p_chanselect = &chansel,
			           index = 0, 
			           objidaddr = &xhatched_obj.objid,
			           osnumaddr = &xhatched_obj.osnum);
    if (! (1 & status))
    {
        *msg = MSFAIL;
        goto wrapup;
    }

    xhatched_obj_deleted = FALSE;

    for (index = 0; index < count_deleted; index++)
    {
        if ((list_deleted[index].objid == xhatched_obj.objid) &&
            (list_deleted[index].osnum == xhatched_obj.osnum))
        {
            xhatched_obj_deleted = TRUE;
            break;
        }
    }

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    matr[0] = (IGRmatrix *) md_env->md_env.matrix;

    dp$display(msg = msg,
               mode = GRbe,
               oids = &my_grid,
               mtx_type = &md_env->md_env.matrix_type,
               matrix = matr);

    if (xhatched_obj_deleted)
    {
        /* disconnect all parents */

        om$send(msg = message NDnode.NDdisconnect(0,NULL),
                targetid = my_id);

        status = om$send(msg = message GRgraphics.GRdelete(msg, md_env),
                         targetid = my_id);
    }
    else  /* not deleting the crosshatched object */
    {
        om$send(msg = message NDnode.NDdisconnect(count_deleted,
                                                  list_deleted),
                targetid = my_id);

        status = om$send(msg = message GRaxhatch.GRxhget_gg(msg, &gg_grid),
                         targetid = my_id);
        if (! (1 & status & *msg))
        {
            *msg = MSFAIL;
            goto wrapup;
        }

        status = om$get_channel_count(objid = my_id,
                                      p_chanselect = &chansel,
                                      count = (OMuint *)&count);

        if ((1 & status) &&
            (count))
        {
            parents = NULL;
            parents = (struct GRid *) alloca(count * sizeof(struct GRid));

            if (! parents)
            {
                *msg = MSFAIL;
                goto wrapup;
            }

            for (index = 1; index < count; index++)
            {
                status = om$get_objid_at_index(objid = my_id, 
                                               p_chanselect = &chansel,
	                                       index = index,
	                                       objidaddr = &parents[index - 1].objid,
		    	                       osnumaddr = &parents[index - 1].osnum);
                if (! (1 & status))
                {
                    *msg = MSFAIL;
                    goto wrapup;
                }
            }
        }

        xhatch_info = (struct GRaxhatch_info *) me->info;

        status = om$send(msg = message GRaxhatch.GRxhcompute(msg,
                                                       &xhatched_obj, md_env,
                                                       index - 1, parents,
                                                       xhatch_info,
                                                       &gg_grid),
                         targetid = my_id);
        if (! (1 & status & *msg))
        {
            *msg = MSFAIL;
            goto wrapup;
        }

            dp$display(msg = msg,
                       mode = GRbd,
                       oids = &my_grid,
                       mtx_type = &md_env->md_env.matrix_type,
                       matrix = matr);
    }

wrapup:

    return(status);
}

end implementation GRaxhatch;
