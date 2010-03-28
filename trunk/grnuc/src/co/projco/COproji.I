class implementation COproj;



#include <coimport.h>
%safe
#include <math.h>
%endsafe
#include <grownerdef.h>
#include <growner.h>
#include <grsymdef.h>
#include <grsym.h>
#include <grsymmacros.h>
#include <detaildef.h>

#define MAETA 1.0e-10

from GRgraphics import GRdisplay, GRdelete, GRcopy, GRxform, GRaltconstruct;
from GRlinear   import GRgetpolyline, GRputpolyline;
from GRdrawview import GRget_model_matrix, GRget_component_id;
from GRgencs    import GRgetmatrix;
from GRvg       import GRgenabsg;
from GRconic    import GRgetarc;



method arg_name_to_value ( int addr_mode ; char * class_name ; char * arg ; COB_arg_union * data ; int * ret_type ; char * is_const )
{
  int		  status = OM_S_SUCCESS;

    *ret_type = _COB_UNKNOWN_ARG;
    *is_const = 0;

    if ( class_name[0] ) 
    {
        if ( !strcmp ( arg, "project_state" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->project_state);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->project_state;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "num_points" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->num_points);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular )
            {
                data->i = (int)me->num_points;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "num_objects" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->num_objects);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->num_objects;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "objects" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) (&me->objects);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
            else if ( addr_mode == _COB_regular ) 
            {
                data->i = (int)me->objects;
                *ret_type = _COB_arg_i;
            }
        }
        else if ( !strcmp ( arg, "points" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)(&me->points[0][0]);
                *ret_type = _COB_arg_p;
            }
        }
    }

    if ( *ret_type == _COB_UNKNOWN_ARG ) 
    {
        om$send ( targetid = my_id,
                  mode = OM_e_wrt_message,
                  msg = message CEO_LOCATE.arg_name_to_value ( addr_mode,
                                                               class_name,
                                                               arg,
                                                               data,
                                                               ret_type,
                                                               is_const ) );
    }

    return OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method gather_leaf_objects (IGRint * msg)
{
  int		  status = OM_S_SUCCESS;

    IGRint              om_msg = OM_S_SUCCESS, ok;
    
    *msg = MSSUCC;

    /*
     * Remove the fence from the graphic set if it 
     * exists.
     */
    gr$gsremove_fence ( msg = &ok,
                        p_chanselect = &me->located_chansel );
                                            

    if (me->objects) free (me->objects);
    me->num_objects = 0;

    EMunwind_stupid_sets ( &me->event3.located_object[0],
                           TRUE,
                           TRUE,
                           my_id,
                           &me->num_objects,
                           &me->objects,
                           msg );

    if (!(om_msg & *msg & 1) ) *msg = MSFAIL;
    
    return (OM_S_SUCCESS);
quit:
  return OM_S_SUCCESS;
}

method store_view_info (IGRint * msg; IGRint type; struct GRevent * event)
{
  int		  status = OM_S_SUCCESS;

    IGRlong        om_msg = OM_S_SUCCESS, ok;
    IGRshort	  four = 4;
    IGRdouble     t1_matrix[16], t2_matrix[16], t3_matrix[16], cs_matrix[16];
    IGRdouble   * matrix, * origin, * normal;
    struct GRid * id, cs_id;
    IGRint        i;
    struct IGRplane plane;
            
    if (type == 0)
    {
        id = &me->from_id;
        matrix = me->from_matrix;
        origin = me->from_origin;
        normal = me->from_normal;
    }
    else
    {
        id = &me->to_id;
        matrix = me->to_matrix;
        origin = me->to_origin;
        normal = me->to_normal;
    }
    
    *id = event->located_object[0].located_obj;
    
    om_msg = om$send ( msg = message GRdrawview.GRget_model_matrix ( (IGRlong *)msg,
                                                                     &me->ModuleInfo,
                                                                     1,
                                                                     matrix ),
                       targetid = id->objid,
                       targetos = id->osnum );

    if (om_msg & *msg & 1)
    {
        origin[0] = matrix[3];
        origin[1] = matrix[7];
        origin[2] = matrix[11];
        
        matrix[3] = matrix[7] = matrix[11] = 0.0;

        /*
         * Get the normal to the drawing view plane.
         */
        om_msg = om$send ( msg = message GRdrawview.GRget_component_id
                                                                ( (IGRlong *)msg,
                                                                  GR_DV_CS,
                                                                  1,
                                                                  &cs_id,
                                                                  &i ),
                           targetid = id->objid,
                           targetos = id->osnum );
                           
        if (om_msg & *msg & 1)
        {
            om_msg = om$send ( msg = message GRgencs.GRgetmatrix ( (IGRlong *)msg, 
                                                                   cs_matrix ),
                               targetid = cs_id.objid,
                               targetos = cs_id.osnum );
                               
            if (om_msg & *msg & 1)
            {
                normal[0] = cs_matrix[2];
                normal[1] = cs_matrix[6];
                normal[2] = cs_matrix[10];
            }
        }
    }

    if (!(om_msg & *msg & 1)) 
    {
        *msg = MSFAIL;
    }
    else if (type == 1) /* Have both views. */
    {
        /*
         * Get the project state.
         */
        for (i=0; i<16; ++i)
        {
            if ( fabs(me->to_matrix[i]) != fabs(me->from_matrix[i]) ) 
            {
                break;
            }
        }
        
        /*
         * A project state of 1 indicates that the two views are 180
         * degrees apart, and the element should be transformed. A
         * project state of 0 indicates that the two views are orthogonal
         * , and the keypoints on the element should be projected as
         * constuction lines.
         */
        me->project_state = (i==16);

        /*
         * Get the transformation matrix.
         */
        MAidmx(&ok, t1_matrix);
    
        t1_matrix[3]  = -(me->from_origin[0]);
        t1_matrix[7]  = -(me->from_origin[1]);
        t1_matrix[11] = -(me->from_origin[2]);

        /*
         * Get transformation matrix to the to_view's orientation.
         */
        MAinvmx ( &ok, &four, me->from_matrix, t3_matrix);
        
        MAmulmx ( &ok, 
                  &four, &four, &four,
                  me->to_matrix,
                  t3_matrix,
                  t2_matrix );

        MAmulmx ( &ok, 
                  &four, &four, &four,
                  t2_matrix,
                  t1_matrix,
                  t3_matrix );

        /*
         * Get the translation matrix to the to_view's origin.
         */
        MAidmx(&ok, t1_matrix);
        t1_matrix[3]  =  me->to_origin[0];
        t1_matrix[7]  =  me->to_origin[1];
        t1_matrix[11] =  me->to_origin[2];

        MAmulmx ( &ok, 
                  &four, &four, &four,
                  t1_matrix,
                  t3_matrix,
                  me->t_matrix );

        /*
         * Get the matrix which projects to the drawing plane.
         */
        plane.point = me->to_origin;
        plane.normal = me->to_normal;
               
        MAplpromx ( &ok, &plane, me->p_matrix );
    }
    
    return (OM_S_SUCCESS);
quit:
  return OM_S_SUCCESS;
}

method extract_points (IGRint * msg)
{
  int		  status = OM_S_SUCCESS;

    IGRlong                om_msg = OM_S_SUCCESS;
    IGRint                i, k, l, m;
    struct GRid         * gr_id;
    struct GRmd_env     * gr_env;
    struct IGRbsp_curve * bsp_p;
    struct IGRarc         arc;

    *msg = MSSUCC;
    
    me->num_points = 0;

    /*
     * Gather points from the graphic objects.
     */
    for (i=0; i<me->num_objects; ++i)
    {
        gr_id = &me->objects[i].located_obj;
        gr_env = &me->objects[i].module_info;
            
        /*
         * Generate the abstract geometry.
         */
        om_msg = om$send ( msg = message GRvg.GRgenabsg ( (IGRlong *)msg,
                                                          &gr_env->md_env.matrix_type,
                                                          gr_env->md_env.matrix,
                                                          (IGRchar **)&bsp_p ),
                           targetid = gr_id->objid,
                           targetos = gr_id->osnum );


        if (!(om_msg & *msg & 1)) 
        {
            *msg = MSINARG;
            continue;
        }
            
        /*
         * If this is a second order, non-rational, uniform bspline, 
         * project the poles.
         *
         * NOTE: These are points, line segments, line strings, 
         *       orthogonal polygons and the like.
         */
        if ((bsp_p->order == 2) && 
            (bsp_p->non_uniform == 0) &&
            (bsp_p->rational == 0) )
        {
            me->num_points += bsp_p->num_poles;

            /*
             * If there is not enough room in the current point buffer
             * allocate some more.
             */
            if (me->num_points > om$dimension_of (varray = me->points))
            {
                om$vla_set_dimension ( varray = me->points,
                                       size = me->num_points + 10);
            }

            for (k=0, l=me->num_points - bsp_p->num_poles; k<bsp_p->num_poles; ++k, ++l)
            {
                m = k * 3;

                me->points[l][0] = bsp_p->poles[m];
                me->points[l][1] = bsp_p->poles[m+1];
                me->points[l][2] = bsp_p->poles[m+2];
            }
        }
        else if (bsp_p->order >= 3)
        {
            /*
             * If the geometry is not closed.
             */
            if (bsp_p->phy_closed == 0)
            {
                me->num_points += 2;

                /*
                 * If there is not enough room in the current point buffer
                 * allocate some more.
                 */
                if (me->num_points > om$dimension_of (varray = me->points))
                {
                    om$vla_set_dimension ( varray = me->points, 
                                           size = me->num_points + 10);
                }

                /*
                 * Add the end points of the geometry.
                 */
                k = me->num_points - 2;
                  
                me->points[k][0] = bsp_p->poles[0];
                me->points[k][1] = bsp_p->poles[1];
                me->points[k][2] = bsp_p->poles[2];

                ++k;
                l = (bsp_p->num_poles * 3) - 3;
                    
                me->points[k][0] = bsp_p->poles[l];
                me->points[k][1] = bsp_p->poles[l+1];
                me->points[k][2] = bsp_p->poles[l+2];
            }

            /*
             * If this is a third order, non_uniform, rational bspline,
             * get the range in local coordinates and project the extents.
             *
             * NOTE: These are circles, circular arcs, ellipses, elliptical
             *       arcs and other conics.
             */
            if ((bsp_p->order == 3) &&
                (bsp_p->non_uniform == 1) &&
                (bsp_p->rational == 1) )
            {
                /*
                 * Temporary KLUDGE!!! Pray it's a conic otherwise this
                 * element's range points will not be projected.
                 */
                om_msg = om$send ( msg = message GRconic.GRgetarc( (IGRlong *)msg,
                                                                   &gr_env->md_env.matrix_type,
                                                                   gr_env->md_env.matrix,
                                                                   &arc ),
                                   targetid = gr_id->objid,
                                   targetos = gr_id->osnum );

                if (om_msg & *msg & 1)
                {
                    me->num_points += 2;
                    
                    /*
                     * If there is not enough room in the current point buffer
                     * lop off some more.
                     */
                    if (me->num_points > om$dimension_of (varray = me->points))
                    {
                        om$vla_set_dimension ( varray = me->points, 
                                               size = me->num_points + 10);
                    }
                        
                    /*
                     * Get the extents.
                     */
                    MAarextents ( msg,
                                  &arc, 
                                  me->points[me->num_points - 2],
                                  me->points[me->num_points - 1]);
                }
                else 
                {
                    om_msg = OM_S_SUCCESS;
                    *msg = MSSUCC;
                }
            }
        }
        else *msg = MSINARG;
    }

    if (!(om_msg & *msg & 1)) 
    {
        if (*msg == MSINARG)
        {
            if ((om_msg & 1) && (me->num_objects > 1))
            {
                *msg = MSSUCC;
            }
        }
        else *msg = MSFAIL;
    }

    return (OM_S_SUCCESS);
quit:
  return OM_S_SUCCESS;
}

method transform_elements (IGRint * msg)
{
  int		  status = OM_S_SUCCESS;

    IGRlong      om_msg = OM_S_SUCCESS, ok;
    IGRshort    four = 4;
    IGRdouble   matrix[16];
    IGRshort    matrix_type;
    struct GRid cp_id;
    enum GRdpmode mode = GRbd;
    IGRint      i;
    OMuword     classid;
    
    MAmulmx (&ok, &four, &four, &four, me->p_matrix, me->t_matrix, matrix);

    MAtypemx ( &ok, matrix, &matrix_type );
    
    for (i=0; i<me->num_objects; ++i)
    {
        /*
         * If this object is a fence, a coordinate system or a text
         * element reject it .
         */
        om$get_classid ( osnum = me->objects[i].located_obj.osnum,
                         objid = me->objects[i].located_obj.objid,
                         p_classid = &classid );

        if ( (om$is_ancestry_valid (superclassid = OPP_GRlbsys_class_id,
                                    subclassid   = classid) == OM_S_SUCCESS ) ) 
        {
            *msg = MSINARG;
            continue;
        }

        /*
         * Copy the graphic object.
         */
        om_msg = om$send ( msg = message GRgraphics.GRcopy ( (IGRlong *)msg,
                                                             &me->objects[i].module_info,
                                                             &me->ModuleInfo,
                                                             &cp_id.objid ),
                           targetid = me->objects[i].located_obj.objid,
                           targetos = me->objects[i].located_obj.osnum );

        if (om_msg & *msg & 1)
        {                  
            cp_id.osnum = me->ModuleInfo.md_id.osnum;

            /*
             * Transform the graphics object.
             */
            om_msg = om$send ( msg = message GRgraphics.GRxform ( (IGRlong *)msg,
                                                                  &me->ModuleInfo,
                                                                  &matrix_type,
                                                                  matrix,
                                                                  &cp_id.objid ),
                               targetid = cp_id.objid,
                               targetos = cp_id.osnum );

            if (om_msg & *msg & 1)
            {
                om_msg = om$send ( msg = message GRgraphics.GRdisplay 
                                                ( (IGRlong *)msg,
                                                  &me->ModuleInfo.md_env.matrix_type,
                                                  me->ModuleInfo.md_env.matrix,
                                                  &mode,
                                                  &me->ModuleInfo.md_id ),
                                   targetid = cp_id.objid,
                                   targetos = cp_id.osnum );
            }
            else
            {
                om$send ( msg = message GRgraphics.GRdelete ( &ok, 
                                                              &me->ModuleInfo ),
                          targetid = cp_id.objid,
                          targetos = cp_id.osnum );
            }
        }
    }

    if (!(om_msg & *msg & 1))
    {
        if (*msg == MSINARG)
        {
            if ((om_msg & 1) && (me->num_objects > 1))
            {
                *msg = MSSUCC;
            }
        }
        else *msg = MSFAIL;
    }

    return (OM_S_SUCCESS);
quit:
  return OM_S_SUCCESS;
}

method project_points (IGRint * msg)
{
  int		  status = OM_S_SUCCESS;

    IGRlong      om_msg = OM_S_SUCCESS, ok;
    IGRlong      i, j, nret, t_num;
    IGRdouble   (* t_points)[3];
    IGRdouble   p_vector[3], p_dot;
    IGRdouble   p_normal[3];
    struct var_list list[2];
    IGRdouble   window_vol[16];
    struct GRid window_id, line_id;
    struct IGRpolyline polyline;
    IGRdouble   ext_points[6];
    struct IGRline     org_line, ext_line;
    IGRdouble   line_points[6];
    struct GRvg_construct cnst_args;
    enum GRdpmode mode;

    *msg =  MSSUCC;

    window_id.objid = me->event1.event.button.objid;
    window_id.osnum = me->event1.event.button.osnum;

    if (me->num_points > 0)
    {
        ++me->num_points;

        /*
         * Get enough space for the transformed points.
         */
        if ( (me->num_points * 2) > om$dimension_of (varray = me->points))
        {
            om$vla_set_dimension ( varray = me->points, 
                                   size = me->num_points * 2 );
        }

        t_points = &(me->points[me->num_points]);
        
        /*
         * Set the last point to a bogus point 1,1,1 off the 
         * from_origin. This will be used when determining the 
         * projection plane's normal.
         */
        for (i=0; i<3; ++i) 
        {
            me->points[me->num_points - 1][i] = me->from_origin[i] + 1.0;
        }

        /*
         * Flatten the original points onto the drawing plane.
         */
        MAptsxform (&ok, &me->num_points, me->p_matrix, me->points, t_points );
    
        /*
         * Transform the points to the to view.
         */
        MAptsxform (&ok, &me->num_points, me->t_matrix, t_points, t_points );

        --me->num_points;

        /*
         * Get the normal to the projection plane.
         */
        for (i=0; i<3; ++i) 
        {
            p_vector[i] = t_points[me->num_points][i] - me->to_origin[i];
        }   

        for (i=0; i<3; ++i)
        {
            MAdotvc(&ok, &me->t_matrix[i*4], p_vector, &p_dot);
    
            if ( (p_dot > -MAETA) && (p_dot < MAETA) )
            {
                for (j=0; j<3; ++j) 
                {
                    p_normal[j] = me->t_matrix[(i*4)+j];
                }
                break;
            }
        }

        /*
         * If this is a principle view.
         */
        if (i<3)
        {
            /*
             * Flatten the transformed points onto the drawing plane.
             */
            MAptsxform (&ok, &me->num_points, me->p_matrix, t_points, t_points);
        }
        else /* Non-aligned view. */
        {
            me->num_points = 0;

            if (me->num_objects > 0) 
            {
                om_msg = om$send ( msg = message COproj.transform_elements (msg),
                                   targetid = my_id );
            }
        }
    }

    if (me->num_points > 0)
    {
        list[0].var = WLD_VOLUME;
        list[0].var_ptr = (IGRchar *)window_vol;
        list[0].num_bytes = 6 * sizeof (IGRdouble);
        list[0].bytes_returned = &nret;
       
        list[1].var = END_PARAM;
       
        om_msg = dp$inq_set_gragad ( msg = msg,
                                     inq0_set1 = 0,
                                     osnum = window_id.osnum,
                                     gragad_objid = window_id.objid,
                                     which_error = &ok,
                                     var_list = list );

        polyline.num_points = 2;
        polyline.points = ext_points;
      
        org_line.point1 = line_points;
        org_line.point2 = &line_points[3];
        
        ext_line.point1 = ext_points;
        ext_line.point2 = &ext_points[3];
        
        cnst_args.msg = (IGRlong *)msg;
        cnst_args.env_info = &me->ModuleInfo;
        cnst_args.newflag = 0;
        cnst_args.level = me->ActiveLevel;
        cnst_args.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        cnst_args.geometry = (IGRchar *)&polyline;
        cnst_args.display = &me->ActiveDisplay;
        cnst_args.class_attr = NULL;
        cnst_args.name = NULL;

        /*
         * Project the points.
         */
        t_num = 0;
        mode = GRbd;
        line_id.osnum = me->ModuleInfo.md_id.osnum;
    
        for (i=0; i<me->num_points; i=i+1)
        {
            for (j=0; j<t_num; j=j+1)
            {
                /*
                 * Don't allow duplicate points to be projected.
                 */
                if ( (t_points[i][0] - me->points[j][0] > -MAETA) &&
                     (t_points[i][0] - me->points[j][0] <  MAETA) &&
                     (t_points[i][1] - me->points[j][1] > -MAETA) &&
                     (t_points[i][1] - me->points[j][1] <  MAETA) &&
                     (t_points[i][2] - me->points[j][2] > -MAETA) &&
                     (t_points[i][2] - me->points[j][2] <  MAETA) )
                {
                    break;
                }
            }

            if (j == t_num) /* Not a duplicate */
            {
                line_points[0] = me->points[j][0] = t_points[i][0]; 
                line_points[1] = me->points[j][1] = t_points[i][1];
                line_points[2] = me->points[j][2] = t_points[i][2];
            
                line_points[3] = line_points[0] + p_normal[0];
                line_points[4] = line_points[1] + p_normal[1];
                line_points[5] = line_points[2] + p_normal[2];

                MAlncbclip (&ok,&org_line,window_vol,&window_vol[3],&ext_line);
        
                om_msg = om$construct ( classname = "GR3dlineseg",
                                        osnum = me->ModuleInfo.md_id.osnum,
                                        p_objid = &line_id.objid,
                                        msg = message GRgraphics.GRaltconstruct 
                                                                ( &cnst_args )
                                      );

                if (om_msg & *msg & 1)
                {
                    om$send ( msg = message GRgraphics.GRdisplay ( (IGRlong *)msg,
                                                                   &me->ModuleInfo.md_env.matrix_type,
                                                                   me->ModuleInfo.md_env.matrix,
                                                                   &mode,
                                                                   &me->ModuleInfo.md_id ),
                              targetid = line_id.objid,
                              targetos = line_id.osnum );
                }

                ++t_num;
            }
        }
    }
    
    if (!(om_msg & *msg & 1)) *msg = MSFAIL;
    
    return (OM_S_SUCCESS);
quit:
  return OM_S_SUCCESS;
}

method free_buffer ( IGRchar * buffer )
{
  int		  status = OM_S_SUCCESS;

    if (buffer) free (buffer);
quit:
  return OM_S_SUCCESS;
}

end implementation COproj;
