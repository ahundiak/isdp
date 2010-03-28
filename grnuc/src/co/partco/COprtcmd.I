/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>
#include <dpdef.h>
#include <dp.h>
#include <dpmacros.h>
#include <comiscmac.h>
#include <coplcmac.h>
#include <cotxmacros.h>


from GRgraphics import GRdisplay, GRdelete, GRaltconstruct;
from GRlinear   import GRgetpolyline, GRputpolyline;

method construct (IGRint * msg; IGRint object; IGRint dynamics)
{
    IGRint              om_msg = OM_S_SUCCESS;
    IGRchar             * attr_p[100], * value_p[100];
    IGRchar             ** attr_pp, ** value_pp;
    struct IGRpolyline  polyline;
    IGRdouble           points[15], t_points[12];
    IGRdouble           * point1, * point2, * point3, * point4;
    IGRdouble           * t_point1, * t_point2, * t_point3, * t_point4;
    IGRint              i, j, action;
    IGRshort            len;
    struct IGRline      project_line;
    IGRdouble           project_point[3];
    IGRdouble           parm;
    IGRmatrix           wld_to_vw, vw_to_wld;
    struct GRvg_construct constr_args;
    struct GRid         text[50], line[50];
    enum GRdpmode       mode;
    struct GRid         gr_id, window_id;
    struct var_list     var_list[2];
    IGRint              num, which_error;
    IGRshort            four = 4;
    struct GRmd_env     NullInfo;

    *msg = MSSUCC;

    if (dynamics)
    {
        NullInfo = me->ModuleInfo;
        NullInfo.md_id.objid = NULL_OBJID;
    }
    
    point1 = &points[0];
    point2 = &points[3];
    point3 = &points[6];
    point4 = &points[9];

    t_point1 = &t_points[0];
    t_point2 = &t_points[3];
    t_point3 = &t_points[6];
    t_point4 = &t_points[9];

    constr_args.msg = (long *)msg;
    constr_args.env_info = (dynamics) ? &NullInfo : &me->ModuleInfo;
    constr_args.newflag = FALSE;
    constr_args.level = me->Attr[0].Level;
    constr_args.properties = GRIS_NEW | GRIS_DISPLAYABLE | GRIS_LOCATABLE;
    constr_args.geometry = NULL;
    constr_args.display = &me->Attr[0].dpb_Display;
    constr_args.class_attr = NULL;
    constr_args.name = NULL;
    
    mode = GRbd;
    
    switch (object)
    {
        case CO_part:

           if (me->num_attrs > 100)
           {
              attr_pp = (char **)om$malloc ( size = me->num_attrs * sizeof(IGRchar *) );
              value_pp = (char **)om$malloc ( size = me->num_attrs * sizeof(IGRchar *) );
           }
           else
           {
                attr_pp = attr_p;
                value_pp = value_p;
            }

            if (attr_pp && value_pp)
            {
                for (i=0; i<me->num_attrs; ++i)
                {
                    attr_pp[i] = &me->attr[i][0];
                    value_pp[i] = &me->value[i][0];
                }
    
                /*
                 * Construct the part for the graphic and attribute
                 * data.
                 */

                om_msg = co$part_construct ( msg = msg,
                                             mod_env = &me->ModuleInfo,
                                             part = &me->part,
                                             attr = attr_pp,
                                             value = value_pp,
                                             type = me->type,
                                             num = me->num_attrs,
                                             object = me->object,
                                             num_objects = me->num_objects );
                if (me->num_attrs > 100)
                {
                    om$dealloc ( ptr = attr_pp );
                    om$dealloc ( ptr = value_pp );
                }
            }   
            break;
            
        case CO_parts_list:
            for (i=1, j=0; j<me->num_processed; i+= 2, ++j)
            {
                text[j] = me->object[i].obj_id;
            }

            for (i=2, j=0; j<me->num_processed; i+= 2, ++j)
            {
                line[j] = me->object[i].obj_id;
            }

            for (i=0; i<me->num_processed; ++i)
            {
                attr_p[i]  = me->format[i].attr;
                value_p[i] = me->format[i].justification;
            }
                       
            om_msg = 
            co$part_construct_partslist ( msg = msg,
                                          mod_env = &me->ModuleInfo,
                                          partslist = &me->part,
                                          block = &me->object[0].obj_id,
                                          cols = me->num_processed,
                                          attr = attr_p,
                                          just = value_p,
                                          text = text,
                                          line = line );
            break;
            
        case CO_parts_list_block:

            point1[0] = me->events[0].event.button.x;
            point1[1] = me->events[0].event.button.y;
            point1[2] = me->events[0].event.button.z;

            point2[0] = me->events[1].event.button.x;
            point2[1] = me->events[1].event.button.y;
            point2[2] = me->events[1].event.button.z;

            window_id.objid = me->events[0].event.button.objid;
            window_id.osnum = me->events[0].event.button.osnum;

            var_list[0].var             = WLD_TO_VIEW;
            var_list[0].var_ptr         = (IGRchar *)wld_to_vw;
            var_list[0].num_bytes       = sizeof(IGRdouble) * 16;
            var_list[0].bytes_returned  = (long *)&which_error;
                        
            var_list[1].var             = END_PARAM;
                        
            om_msg = dp$inq_set_gragad ( msg = msg,
                                         osnum = window_id.osnum,
                                         gragad_objid = window_id.objid,
                                         which_error = &which_error,
                                         var_list = var_list );
            num = 2;
            MAptsxform (msg, &num, wld_to_vw, points, t_points);
                       
            /*
             * If the block was entered right to left reverse the
             * points.
             */
            if (t_point1[0] > t_point2[0])
            {
                t_point3[0] = t_point1[0];
                t_point3[1] = t_point2[1];
                t_point3[2] = t_point1[2];
                
                t_point1[0] = t_point2[0];
            }
            else if (t_point1[0] < t_point2[0])
            {
                for (i=0; i<3; i=i+1) t_point3[i] = t_point2[i];
            }
            else *msg = MSFAIL;  /* parts list has zero width */

            if (*msg & 1)
            {                      
                t_point2[0] = t_point1[0];
                t_point2[1] = t_point3[1];
                t_point2[2] = t_point1[2];
                        
                t_point4[0] = t_point3[0];
                t_point4[1] = t_point1[1];
                t_point4[2] = t_point1[2];

                four = 4;
                MAinvmx (msg, &four, wld_to_vw, vw_to_wld);
                       
                num = 4;
                MAptsxform (msg, &num, vw_to_wld, t_points, points);
            
                polyline.num_points = num;
                polyline.points = points;

                constr_args.geometry = (char *)&polyline;
            
                om_msg = 
                  om$construct( classname = "GR3dlinestr",
                                osnum = me->ModuleInfo.md_id.osnum,
                                p_objid = &gr_id.objid,
                                msg = message GRgraphics.GRaltconstruct(
                                                  &constr_args)
                               );
                                  
                if (om_msg & *msg & 1) 
                {
                   gr_id.osnum = me->ModuleInfo.md_id.osnum;
    
                   if ((me->num_objects + 1) > om$dimension_of(varray = me->object))
                   {
                      om$vla_set_dimension ( varray = me->object,
                                             size = me->num_objects + 5 );
                   }
            
                   if ((me->num_objects + 1) < om$dimension_of (varray = me->object))
                   {
                      me->object[me->num_objects].obj_id = gr_id;
                      me->object[me->num_objects++].mod_env = me->ModuleInfo;

                      if (!dynamics)
                      {
                         mode = GRbd;
                         om$send ( msg = message GRgraphics.GRdisplay
                                             ( (long *)msg,
                                              &me->ModuleInfo.md_env.matrix_type,
                                               me->ModuleInfo.md_env.matrix,
                                              &mode,
                                              &me->ModuleInfo.md_id ),
                                   targetid = gr_id.objid,
                                   targetos = gr_id.osnum );
                      }
                   }
                   else *msg = MSFAIL;
                }
                else *msg = MSFAIL;
            }
            
            break;

        case CO_parts_list_title:
        case CO_parts_list_divider:

            polyline.num_points = 4;
            polyline.points = points;
            
            gr_id = me->object[0].obj_id; /* gr_id is the list outline */
            
            /*
             * Get the points which make up the header.
             */
            action = 1;
            om_msg = om$send( msg = message GRlinear.GRgetpolyline
                                            ( (long *)msg,
                                             &me->ModuleInfo.md_env.matrix_type,
                                             me->ModuleInfo.md_env.matrix,
                                             &action,
                                             &polyline ),
                              targetid = gr_id.objid,
                              targetos = gr_id.osnum );

            if (om_msg & *msg & 1)
            {
                project_line.point1 = point1;
                project_line.point2 = point4;

                /*
                 * Project the input point to the horizontal projection vector.
                 */                
                MAptlnproj ( msg, 
                             &me->events[2].event.button.x,
                             &project_line,
                             project_point,
                             &parm );

                if (*msg & 1)
                {
                    if (object == CO_parts_list_title)
                    {
                        project_point[0] += (point2[0] - point1[0])/2;
                        project_point[1] += (point2[1] - point1[1])/2;
                        project_point[2] += (point2[2] - point1[2])/2;

                        GRget_window_matrix ( msg,
                                              me->events[2].event.button.osnum,
                                              me->events[2].event.button.objid,
                                              wld_to_vw,
                                              NULL );
                                          
                        /*
                         * Set the text justification to left, center (2).
                         */
                        me->Attr[0].TextSymb.Active_just = 2;
                            
                        len = strlen (me->format[me->num_processed].title);
                            
                        om_msg =
                        co$place_text ( 
			   msg = msg,
                           text_string = me->format[me->num_processed].title,
                           text_length = &len,
                           origin = project_point,
                           rot_matrix = wld_to_vw,
                           ModuleInfo = (dynamics) ? 
                                           &NullInfo : &me->ModuleInfo,
                           ActiveDisplay = &me->Attr[0].dpb_Display,
                           ActiveLevel = me->Attr[0].Level,
                           TextSymb = &me->Attr[0].TextSymb,
                           ActiveAngle = 0.0,
                           buffer = &gr_id,
                           flags = 0 );
                    }
                    else
                    {
                        /*
                         * Start the line between point 1 and point 2.
                         */
                        for (i=0; i<3; ++i) t_point1[i] = project_point[i];

                        /*
                         * And the other point the extension to the header height.
                         */
                        for (i=0; i<3; ++i)
                        {
                            t_point2[i] = point2[i] + 
                                          (project_point[i] - point1[i]);
                        }
                            
                        polyline.num_points = 2;
                        polyline.points = t_points;

                        constr_args.geometry = (char *)&polyline;
                
                        om_msg = om$construct( 
				    classname = "GR3dlineseg",
                                    osnum = me->ModuleInfo.md_id.osnum,
                                    p_objid = &gr_id.objid,
                                    msg = message GRgraphics.GRaltconstruct(
				       &constr_args)
                                 );
                                  
                    }

                    if (om_msg & *msg & 1)
                    {
                        if ((me->num_objects + 1) > 
			       om$dimension_of(varray = me->object))
                        {
                            om$vla_set_dimension ( varray = me->object,
                                                   size = me->num_objects + 5 );
                        }
            
                        if ((me->num_objects + 1) < 
			       om$dimension_of (varray = me->object))
                        {
                            gr_id.osnum = me->ModuleInfo.md_id.osnum;
                            
                            me->object[me->num_objects].obj_id = gr_id;
                            me->object[me->num_objects++].mod_env =
			       me->ModuleInfo;

                            if (!dynamics)
                            {
                                mode = GRbd;
                                om$send( 
				   msg = message GRgraphics.GRdisplay
                                            ( (long *)msg,
                                             &me->ModuleInfo.md_env.matrix_type,
                                              me->ModuleInfo.md_env.matrix,
                                             &mode,
                                             &me->ModuleInfo.md_id ),
                                   targetid = gr_id.objid,
                                   targetos = gr_id.osnum );
                            }
                        }
                    }
                    else *msg = MSFAIL;
                }
            }
            else *msg = MSFAIL;

            break;
    }
    
    if (!(om_msg & 1) ) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method stack_delete (IGRint * msg; IGRint number; IGRint erase)
{
    IGRint          om_msg = OM_S_SUCCESS;
    enum GRdpmode   mode;
    IGRint          high, low, i;

    *msg = MSSUCC;
    
    mode = GRbe;
    high = me->num_objects - 1;
    low  = me->num_objects - number;
    
    for (i=high; i>=low; --i)
    {
        if (erase)
        {
            om_msg = 
            om$send ( msg = message GRgraphics.GRdisplay( 
			       (long *)msg,
                              &me->ModuleInfo.md_env.matrix_type,
                               me->ModuleInfo.md_env.matrix,
                              &mode,
                              &me->ModuleInfo.md_id ),
                      targetid = me->object[i].obj_id.objid,
                      targetos = me->object[i].obj_id.osnum );
        }

        om_msg = 
        om$send ( msg = message GRgraphics.GRdelete( 
			   (long *)msg, 
			  &me->object[i].mod_env ),
                  targetid = me->object[i].obj_id.objid,
                  targetos = me->object[i].obj_id.osnum );
    }
    
    me->num_objects -= number;
    
    if (!(om_msg & *msg & 1)) *msg = MSFAIL;
    
    return (OM_S_SUCCESS);
}
end implementation COpart;
