class implementation COdetail;



#include <coimport.h>
#include <FI.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DImacros.h>
#include <DIprims.h>
#include <gr.h>

from IGEgragad    import DPwnarea;
from DPlvldir     import convert_lev_string;
from GRgraphics   import GRdelete, GRdisplay, GRxform;
from GRvg         import GRgetgeom, GRchgname;
from GRreffile    import GRchglevels, GRxformref, GRinquireref;
from GRreffile    import GRgetenvironment;
from GRdvalign    import GRdvalign_init;
from GRowner      import GRset_active_owner, GRclear_active_owner;
from GRgencs      import GRcssetscale;
from GRdrawview   import GRcomponent_add, GRcomponent_delete, 
                         GRget_model_matrix, GRget_model_geometry,
                         GRget_drawview_scale, GRattach_model, 
                         GRscale_drawing_view, GRcopy_drawing_view,
                         GRget_component_id;

extern int COtool_ci_strcmp ();



method arg_name_to_value ( int addr_mode ; char * class_name ; char * arg ; COB_arg_union * data ; int * ret_type ; char * is_const )
{
  int		  status = OM_S_SUCCESS;

    *ret_type = _COB_UNKNOWN_ARG;
    *is_const = 0;

    if ( class_name[0] ) 
    {
        if ( !strcmp ( arg, "model" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->model;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "view" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->view;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "window_id" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *)(&me->window_id);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "window_matrix" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->window_matrix;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "dv_id1" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *)(&me->dv_id1);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "dv_id2" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *)(&me->dv_id2);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "name" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->name;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "text_name" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->text_name;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "text_scale" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->text_scale;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "point1" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->point1;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "point2" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->point2;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "line_base" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *)(&me->line_base);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "scale" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *)(&me->scale);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "ref_id" ) )
        {
            if ( addr_mode == _COB_address )
            {
                data->p = (char *)(&me->ref_id);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp (arg, "ref_id.osnum") )
        {
            if ( addr_mode == _COB_address )
            {
                data->p = (char *)(&me->ref_id.osnum);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp (arg, "ref_id.objid") )
        {
            if ( addr_mode == _COB_address )
            {
                data->p = (char *)(&me->ref_id.objid);
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "directory" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *)me->directory;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "option" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *)&me->option;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( !strcmp ( arg, "cmd_mode" ) ) 
        {
            if ( addr_mode == _COB_address ) 
            {
                data->p = (char *)&me->cmd_mode;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
    }

    if ( *ret_type == _COB_UNKNOWN_ARG ) 
    {

        om$send ( targetid = my_id,
                  mode = OM_e_wrt_message,
                  msg = message CEO_GSLOCATE.arg_name_to_value ( addr_mode,
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

method construct_drawsheet ()
{
  int		  status = OM_S_SUCCESS;

     long             ok;
     double           vw_vol[6], 
                         delta;
     struct GRid         ds_id, 
                         gr_id;
     unsigned short   prop;
     extern int       GRconstruct_ds();
     struct ds_standard  std;

     me->ret = OM_S_SUCCESS;

     prop =  (GRIS_LOCATABLE | GRIS_DISPLAYABLE);

     status = gr$get_default_standard ( msg = &ok,
                                        standard = &std );
     _err_ck2(status,ok);

     /*
      * Construct the drawing sheet.
      */
     status = GRconstruct_ds(&me->ret,
                             &me->ModuleInfo,
                             me->ActiveLevel,
                             &me->ActiveDisplay,
                             prop,
                             me->name,
                             std.projection_angle,
                             me->sheet.width,
                             me->sheet.height,
                             &me->event1,
                             me->sheet.filetype,
                             me->sheet.file,
                             me->sheet.view,
                             me->sheet.name,
                             &ds_id);

     /*
      * If the drawing sheet was successfully created
      */
     if ( me->ret & status & 1 ) {

          /*
           * If the user requested an auto-fit, fit the button's window 
           * to the drawing sheet.
           */ 
          if ( me->auto_fit )
          { 
               short        four = 4,
                               matrix_type;
               long         one = 1,
                               ret_bytes,
                               which_error;
               double       sheet_size[3],
                               tsheet_size[3],
                               inv_matrix[16];
               double       rotation[16];
               IGRboolean      b_status;
               struct var_list gad_list[2];

               gr_id.objid = me->event1.event.button.objid;
               gr_id.osnum = me->event1.event.button.osnum;

               delta = me->sheet.height * 0.025;

               vw_vol[0] = me->event1.event.button.x;
               vw_vol[1] = me->event1.event.button.y;
               vw_vol[2] = me->event1.event.button.z;

               tsheet_size[0] = me->sheet.width;
               tsheet_size[1] = me->sheet.height;
               tsheet_size[2] = 0;

               gad_list[0].var = VIEW_ROTATION;
               gad_list[0].var_ptr = (IGRchar *)rotation;
               gad_list[0].num_bytes = sizeof(double)*16;
               gad_list[0].bytes_returned = &ret_bytes;

               gad_list[1].var = END_PARAM;

               status = dp$inq_set_gragad( msg          = &ok,
                                           osnum        =  gr_id.osnum,
                                           gragad_objid =  gr_id.objid,
                                           which_error  = &which_error,
                                           var_list     =  gad_list );
               _err_ck2(status,ok);

               b_status = MAtrnmx( &ok,
                                   &four,
                                    rotation,
                                    inv_matrix );

               b_status = MAtypemx( &ok,
                                     inv_matrix,
                                    &matrix_type );

               b_status = MAoptsxform( &ok,
                                       &one,
                                       &matrix_type,
                                        inv_matrix,
                                        tsheet_size,
                                        sheet_size );

               vw_vol[3] = vw_vol[0] + sheet_size[0];
               vw_vol[4] = vw_vol[1] + sheet_size[1];
               vw_vol[5] = vw_vol[2] + sheet_size[2];

               vw_vol[0] -= delta;
               vw_vol[1] -= delta;
               vw_vol[2] -= delta;
               vw_vol[3] += delta;
               vw_vol[4] += delta;
               vw_vol[5] += delta;

               om$send(mode = OM_e_wrt_object,
                       msg = message IGEgragad.DPwnarea(&ok,
                                                        0, 
                                                        vw_vol, 
                                                        (IGRboolean)TRUE),
                       senderid = my_id,
                       targetid = gr_id.objid,
                       targetos = gr_id.osnum);
          }
          else {

               me->DisplayMode = GRbd;

               status = om$send (msg = message GRgraphics.GRdisplay 
                                        ( &ok,
                                          &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix, 
                                          &me->DisplayMode,
			                  &me->ModuleInfo.md_id),
                                 targetid = ds_id.objid,
                                 targetos = ds_id.osnum);
               _err_ck2(status,ok);
          }

          /* 
           * If the user wants the new sheet made the active owner, clear
           * the previous active owner and set the new active owner.
           */
          if ( me->auto_active ) { 

               status = gr$get_active_owner ( msg = &ok, 
                                              mod_id = &me->ModuleInfo.md_id,
                                              active_owner = &gr_id);

               /*
                * If there is an active owner clear it.
                */
               if (status & ok & 1)
               {
                    /*
                     *  Clear the active owner.
                     */

                    status = om$send(
                         msg = message GRowner.GRclear_active_owner(&ok,
                                                                    &me->ModuleInfo),
                         targetid = gr_id.objid,
                         targetos = gr_id.osnum);
               }

               ok = OM_S_SUCCESS;

               status = om$send ( msg = message GRowner.GRset_active_owner 
                                             (&ok,
                                              &me->ModuleInfo),
                                  targetid = ds_id.objid,
                                  targetos = ds_id.osnum );
               _err_ck2(status,ok);

          }
     }
quit:
  return OM_S_SUCCESS;
}

method set_active_owner ( OM_S_CHANSELECT * p_chansel )
{
  int		  status = OM_S_SUCCESS;

    struct GRmd_env   mod_env;
    struct GRid       owner_id;

    me->ret = MSSUCC;

    if ( p_chansel ) {
        status = gr$gspass ( msg = &me->ret,
                             pass_msg = message GRowner.GRset_active_owner
                                                    (&me->ret, &mod_env),
                             path = &mod_env,
                             p_chanselect = p_chansel);
    }
    else {
        status = gr$get_active_owner ( msg = &me->ret, 
                                       mod_id = &me->ModuleInfo.md_id,
                                       active_owner = &owner_id );

        if (status & me->ret & 1) {
            /*
             *  Clear the active owner.
             */
            status = om$send(msg = message GRowner.GRclear_active_owner 
                                                    (&me->ret, &me->ModuleInfo),
                             targetid = owner_id.objid,
                             targetos = owner_id.osnum);
        }
        else me->ret = MSSUCC;
    }
quit:
  return OM_S_SUCCESS;
}

method attach_model ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    struct GRmd_env   mod_env;
    int            ref_props = GRIS_MODEL_ATTACHMENT;
    char           write [MAXPATHLEN];

    *sts = MSSUCC;

    ex$message ( msgnumb = GR_I_WRITE1, buff = &write [0] );
    ex$message ( msgnumb = GR_I_WRITE2, buff = &write [1] );

    if (me->mode==write[0] || me->mode==write[1])
        GRmake_writable (sts, me->model,NULL);
    else
        ref_props |= GRRF_IS_READ_ONLY;


    status = gr$gspass ( msg = sts,
                         pass_msg = message GRdrawview.GRattach_model 
                                            ( (IGRlong *)sts,
                                              &mod_env, 
                                              me->model, 
                                              me->view,
                                              GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE,
                                              ref_props,
                                              me->ActiveLevel, 
                                              &me->ActiveDisplay ),
                         path = &mod_env,
                         p_chanselect = &me->located_chansel);

    if ( status == OM_I_DUPLICATE_OS )
    {
        *sts = status;
    }

    status = OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method dynamics ( int dynamics ; int * sts )
{
  int		  status = OM_S_SUCCESS;

IGRlong           *sts1;
struct GRid       my_GRid;
struct GRmd_env   mod_env;

   sts1 = (IGRlong *)sts;

   my_GRid.osnum = OM_Gw_current_OS;
   my_GRid.objid = my_id;
   mod_env = me->ModuleInfo;
   mod_env.md_id.objid = NULL_OBJID;
      
   if ((dynamics == 0) || (dynamics == 1))
   {
   int            flag;
   IGRpoint          point;
   struct GRid       object_id;

      point[0] = 0;
      point[1] = 0;
      point[2] = 0;

      flag = FALSE;      
      if (dynamics == 0)
      {  
      short            length;

         if (me->text_name[0] != '\0')
         {
            flag = TRUE;
            length = (short) strlen (me->text_name);
            status = co$place_text (  msg = sts1,
                     text_string = me->text_name,
                     text_length = &length,
                     origin = point,
                     rot_matrix = me->window_matrix,
                     ActiveDisplay = &me->ActiveDisplay,
                     ActiveLevel = me->ActiveLevel,
                     ModuleInfo = &mod_env,
                     ActiveAngle = 0.0,
                     flags = 0,
                     objid = me->window_id.objid,
                     buffer = &object_id);
         }
      }else if (dynamics == 1)
      {
      short            length;

         if (me->text_scale[0] != '\0')
         {
            flag = TRUE;
            length = (short) strlen (me->text_scale);
            status = co$place_text (  msg = sts1,
                     text_string = me->text_scale,
                     text_length = &length,
                     origin = point,
                     rot_matrix = me->window_matrix,
                     ActiveDisplay = &me->ActiveDisplay,
                     ActiveLevel = me->ActiveLevel,
                     ModuleInfo = &mod_env,
                     ActiveAngle = 0.0,
                     flags = 0,
                     objid = me->window_id.objid,
                     buffer = &object_id);
         }
      }
      if (flag)
      {
         DYtranslate_element_init (point, &object_id);

         status = om$send (msg = message GRgraphics.GRdelete (sts1, 
                  &mod_env),
                  targetid = object_id.objid,
                  targetos = object_id.osnum);
      }
   }else if (dynamics == 2)
   {
   IGRpoint          point;
   struct GRid       object_id;
   struct IGRlbsys   lb;

      point[0] = 0;
      point[1] = 0;
      point[2] = 0;

      if ( (me->mytype == CO_auxview) || 
           ((me->mytype == CO_drawview) && (me->cmd_mode == CO_auxview)) ) 
      {
         lb = me->dyn_lbsys;
         lb.matrix[3] = lb.matrix[7] = lb.matrix[11] = 0.0;
      }
      else 
      {
         MAidmx(sts1, lb.matrix);
      }

      status = GRconstruct_cs (sts1, &mod_env, me->ActiveLevel, 
               &me->ActiveDisplay, GRIS_DISPLAYABLE, NULL, "GRgencs", 
               &lb, &object_id);

      if ( (me->mytype == CO_auxview) ||
           ((me->mytype == CO_drawview) && (me->cmd_mode == CO_auxview)) ) 
      {
         DYtranslate_element_init (point, &object_id);
      }
      else
      {
         DYtranslate_element_vi_init (point, &object_id);
      }

      status = om$send (msg = message GRgraphics.GRdelete (sts1, &mod_env),
               targetid = object_id.objid,
               targetos = object_id.osnum);
   }else if (dynamics == 3)
   {
   struct GRevent    *base_event[1];  /* points to base of vector */

      base_event[0] = &me->line_base;
      DYrblinear (base_event, &me->ActiveDisplay);
   }else if (dynamics == 4)
   {
   struct IGRline line;

      line.point1 = me->point1;
      line.point2 = me->point2;
      DYauxview_init (&mod_env, me->matrix, me->origin,
         &me->normal, &line, &my_GRid, &me->located_chansel);
   }else if (dynamics == 5)
   {
      DYprinview_init (&mod_env, me->origin, &me->model_lbsys, 
         &me->projection_angle, &my_GRid, &me->located_chansel);
   }else if ( (dynamics == 6) || (dynamics == 7) )
   {
      struct GRid       cs_id;
      IGRpoint          handle; 
      IGRpoint          handle_norm;
      double         radius;
      char	        old_weight;


      MA2ptdis(sts, me->origin, me->point1, &radius);
      radius = radius / 2.0;

      /*
       * Construct the default cooridinate system translated to the default point
       */
      me->dyn_lbsys.matrix[3]  = me->point1[0];
      me->dyn_lbsys.matrix[7]  = me->point1[1];
      me->dyn_lbsys.matrix[11] = me->point1[2];

      old_weight = me->ActiveDisplay.weight;
      me->ActiveDisplay.weight = 2;

      status = GRconstruct_cs (sts1, &mod_env, me->ActiveLevel, 
               &me->ActiveDisplay, GRIS_DISPLAYABLE, NULL, "GRgencs", 
               &me->dyn_lbsys, &cs_id);

      me->ActiveDisplay.weight = old_weight;

      handle[0] = me->point1[0] + me->dyn_lbsys.matrix[0];
      handle[1] = me->point1[1] + me->dyn_lbsys.matrix[4];
      handle[2] = me->point1[2] + me->dyn_lbsys.matrix[8];

      handle_norm[0] = me->point1[0] + me->dyn_lbsys.matrix[1];
      handle_norm[1] = me->point1[1] + me->dyn_lbsys.matrix[5];
      handle_norm[2] = me->point1[2] + me->dyn_lbsys.matrix[9];

      DYaux_cs_rotate ( sts1,
                        ((dynamics == 6) ? 0 : 1),
                        me->point1,
                        handle,
                        handle_norm,
                        &radius,
                        &mod_env,
                        &cs_id );

      status = om$send ( msg = message GRgraphics.GRdelete( sts1,
                                                            &mod_env ),
                         targetid = cs_id.objid,
                         targetos = cs_id.osnum );
                                    
   }
quit:
  return OM_S_SUCCESS;
}

method xcopy_drawview ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong        *sts1;
    int            env_prop = 0;
    short          matrix_type;
    struct GRid       my_GRid;
    struct GRid       obj_id;
    struct GRobj_env  obj_info;
    struct GRid       ref_id;
    int            type;

    sts1 = (IGRlong *)sts;

    my_GRid.osnum = OM_Gw_current_OS;
    my_GRid.objid = my_id;

    ref_id.objid = NULL_OBJID;
    ref_id.osnum = me->ModuleInfo.md_id.osnum;

    status = GRgsget_simple_object ( sts1, 
                                     &my_GRid, 
                                     &me->located_chansel, 
                                     &obj_info );

    obj_id.osnum = me->ModuleInfo.md_id.osnum;
    status = om$send (msg = message GRdrawview.GRcopy_drawing_view (sts1,
                                                                    &obj_info.mod_env, 
                                                                    &me->ModuleInfo, 
                                                                    &obj_id.objid),
                      targetid = obj_info.obj_id.objid,
                      targetos = obj_info.obj_id.osnum);

    MAtypemx (sts1, me->matrix, &matrix_type);
    status = om$send (msg = message GRgraphics.GRxform(sts1, 
                                                       &me->ModuleInfo,
                                                       &matrix_type, 
                                                       me->matrix, 
                                                       &obj_id.objid),
                      targetid = obj_id.objid,
                      targetos = obj_id.osnum);

    /*
     * Get the reference file component id if a ref is attached.
     */
    status = om$send (msg = message GRdrawview.GRget_component_id (sts1,
                                                                   GR_DV_REFFILE, 
                                                                   1, 
                                                                   &ref_id, 
                                                                   &type),
                      targetid = obj_id.objid,
                      targetos = obj_id.osnum );

    /*
     * If a reference file is attached then modify the clipping polygon.
     */
    if ( (status & *sts1 & 1)/* && (me->mytype != CO_drawview)*/ ) 
        GRformdvprism ( sts1, &me->ModuleInfo, me->window_matrix, &ref_id );

    /*
     *  Disconnect the previously created object from myself
     */
    status = gr$gsempty ( msg = sts1, 
                          p_chanselect = &me->located_chansel );

    if (status & 1)
        status = GRgsadd_object ( sts1, 
                                  &obj_id, 
                                  &me->ModuleInfo,
                                  &env_prop, 
                                  &my_GRid, 
                                  &me->located_chansel );
    status = OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method construct_text ( int type )
{
  int		  status = OM_S_SUCCESS;

    short          length;
    IGRpoint          point;
    struct GRid       text_id;
    struct GRmd_env   mod_env;
    char           *text;

    me->ret = MSSUCC;
 
    text = (type == CO_name) ? me->text_name : me->text_scale;

    if (*text) {
        length = (short) strlen (text);
        point[0] = me->event1.event.button.x;
        point[1] = me->event1.event.button.y;
        point[2] = me->event1.event.button.z;

        status = co$place_text ( msg = &me->ret,
                                 text_string = text,
                                 text_length = &length,
                                 origin = point,
                                 rot_matrix = me->window_matrix,
                                 ActiveDisplay = &me->ActiveDisplay,
                                 ActiveLevel = me->ActiveLevel,
                                 ModuleInfo = &me->ModuleInfo,
                                 ActiveAngle = 0.0,
                                 mode = GRbd,
                                 objid = me->window_id.objid,
                                 classname = (type == CO_scale) ? 
                                 "GRdvtext" : NULL,
                                 buffer = &text_id );

        status = gr$gspass ( msg = &me->ret,
                             pass_msg = message GRdrawview.GRcomponent_add 
                                                        ( &me->ret,
                                                          &mod_env, 
                                                          &text_id, 
                                                          (type==CO_name) ?
                                                          GR_DV_TEXTNAME : GR_DV_TEXTSCALE ), 
                             path = &mod_env,
                             p_chanselect = &me->located_chansel );
    }
quit:
  return OM_S_SUCCESS;
}

method get_drawview_info ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRlong      *sts1;
    short        matrix_type;
    struct GRmd_env mod_env;
    struct IGRlbsys lb;

    sts1 = (IGRlong *)sts;

    MAtypemx (sts, me->window_matrix, &matrix_type);
    gr$gspass ( msg = sts1,
                pass_msg = message GRdrawview.GRget_model_geometry 
                                                        ( sts1,
                                                          &mod_env, 
                                                          &me->model_lbsys ),
                path = &mod_env,
                p_chanselect = &me->located_chansel);

    gr$gspass ( msg = sts1,
                pass_msg = message GRvg.GRgetgeom ( sts1, 
                                                    &mod_env.md_env.matrix_type, 
                                                    mod_env.md_env.matrix, 
                                                    (IGRchar *)&lb ),
                path = &mod_env,
                p_chanselect = &me->located_chansel );

    me->origin[0] = lb.matrix[3];
    me->origin[1] = lb.matrix[7];
    me->origin[2] = lb.matrix[11];

quit:
  return OM_S_SUCCESS;
}

method get_auxview_normal ( long * sts )
{   
  int		  status = OM_S_SUCCESS;

    int          i;
    IGRpoint        direction;
    IGRpoint        prj_point;
    double       radians;
    double       t;
    struct IGRline  line;

    /*
     *  Generate the direction rotation matrix;
     */
    radians = PI/2;
    direction[0] = me->point2[0] - me->point1[0];
    direction[1] = me->point2[1] - me->point1[1];
    direction[2] = me->point2[2] - me->point1[2];
 
    MAgrotmx (sts, direction, me->origin, &radians, me->matrix);

    /* 
     *  Project the origin of the drawing view onto the folding line.
     */
    line.point1 = me->point1;
    line.point2 = me->point2;
    MAptlnproj (sts, me->origin, &line, prj_point, &t);

    /*
     *  Form a line normal to the folding line through the project origin
     *  and in the plane of view.
     */
    me->normal.point1 = me->normal_point1;
    me->normal.point2 = me->normal_point2;
    MAlpfrln(sts, &line, prj_point, &me->window_matrix[8], &me->normal);

    for (i=0; i < 3; ++i) {
        me->vector[i] = me->normal.point2[i] - me->normal_point1[i];
    }
quit:
  return OM_S_SUCCESS;
}

method get_auxview_matrix ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    int      i;
    short    four = 4;
    IGRpoint    tpoint;
    IGRmatrix   matrix;
    IGRmatrix   tmatrix;
    
    tpoint[0] = me->event1.event.button.x;
    tpoint[1] = me->event1.event.button.y;
    tpoint[2] = me->event1.event.button.z;
    GRauxview_build_rot_matrix ( sts, 
                                 me->origin, 
                                 &me->normal, 
                                 tpoint, 
                                 tmatrix );

    for (i=0; i < 16; ++i) matrix[i] = me->matrix[i];
    MAmulmx (sts, &four, &four, &four, tmatrix, matrix, me->matrix);
quit:
  return OM_S_SUCCESS;
}

method get_principal_drawview_matrix ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRpoint    tpoint;

    tpoint[0] = me->event1.event.button.x;
    tpoint[1] = me->event1.event.button.y;
    tpoint[2] = me->event1.event.button.z;

    GRprinview_build_rot_matrix ( sts, 
                                  &me->projection_angle,
                                  me->window_matrix, 
                                  me->origin, 
                                  &me->model_lbsys, 
                                  tpoint,
                                  me->vector, 
                                  me->matrix, 
                                  NULL, 
                                  NULL );
quit:
  return OM_S_SUCCESS;
}

method get_name_from_matrix ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    short                   four = 4;
    int                     type,size;
    IGRlong                 ok;
    IGRlong                *sts1;
    IGRmatrix               matrix;
    IGRmatrix               tmatrix;
    struct GRmd_env         mod_env;
    struct GRid             ref_id;
    struct GRinquire_list   inq_lst[2];
    struct GRmd_env         sv_env;

    sts1 = (IGRlong *)sts;

    gr$gspass ( msg = &ok,
                pass_msg = message GRdrawview.GRget_model_matrix 
                                            ( sts1, 
                                              &mod_env,
                                              TRUE, 
                                              tmatrix ),
                path = &mod_env,
                p_chanselect = &me->located_chansel );

    MAmulmx (sts1, &four, &four, &four, me->window_matrix, tmatrix, matrix);


    /*
     * If there is a reference file use it's osnum when naming the views.
     * otherwise use the master file's osnum.
     */

    ref_id.objid = NULL_OBJID;
    ref_id.osnum = mod_env.md_id.osnum;

    gr$gspass ( msg = &ok,
                pass_msg = message GRdrawview.GRget_component_id 
                                            ( sts1, 
                                              GR_DV_REFFILE,
                                              1,
                                              &ref_id,
                                              &type ),
                path = &mod_env,
                p_chanselect = &me->located_chansel);

    if ( ok & *sts1 & 1 ) {

	IGRboolean pass_to_other_spaces = FALSE;

        size = sizeof(struct GRmd_env);
        inq_lst[0].var = ENVIRONMENT_INFO;
        inq_lst[0].var_ptr = (char *) &sv_env;
        inq_lst[0].num_requested = size;
        inq_lst[0].num_returned = size;
        inq_lst[1].var = END_REPORT_REQUEST;

        status = om$send ( msg = message GRreffile.GRinquireref
                                            ( sts1, 
                                              &mod_env, 
                                              inq_lst, 
                                              (IGRint *)&ok,
					      &pass_to_other_spaces,
                                              NULL ),
                           targetid = ref_id.objid,
                           targetos = ref_id.osnum );

        if ( !(status & *sts1 & 1) ) 
            sv_env.md_id.osnum = 0; /** mod_env.md_id.osnum; **/
    }
    else sv_env.md_id.osnum = 0; /** mod_env.md_id.osnum; **/
    
    /*
     * Get a name for the matrix
     */

    GRdvid_matrix(sts1, matrix, me->text_name, sv_env.md_id.osnum);

quit:
  return OM_S_SUCCESS;
}

method construct_default_cs ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    int          i;
    short        four = 4;
    IGRlong     *sts1;
    double       scale[3],s;
    struct IGRlbsys tlb;
    struct IGRlbsys lb;
    struct GRmd_env mod_env;
    IGRvector       x,y,z,vec,angle;
    char         old_weight;

    sts1 = (IGRlong *)sts;

    status = gr$gspass ( msg = sts1,
                         pass_msg = message GRvg.GRgetgeom ( sts1,
                                                             &mod_env.md_env.matrix_type, 
                                                             mod_env.md_env.matrix, 
                                                             (IGRchar *)&tlb ),
                         path = &mod_env,
                         p_chanselect = &me->located_chansel);

    if ((me->mytype == CO_auxview ) ||
       ((me->mytype == CO_drawview) && (me->cmd_mode == CO_auxview)) ) 
    {
        z[0] = me->window_matrix[8];
        z[1] = me->window_matrix[9];
        z[2] = me->window_matrix[10];

        vec[0] = me->window_matrix[0];
        vec[1] = me->window_matrix[1];
        vec[2] = me->window_matrix[2];
        MAang2vc(sts1, vec, me->vector, angle);
        if ( ((angle[0] > (.25*PI)) && (angle[0] <= (.75*PI))) ||
             ((angle[0] > (1.25*PI)) && (angle[0] <= (1.75*PI))) )
        {
            x[0] = me->point2[0] - me->point1[0];
            x[1] = me->point2[1] - me->point1[1];
            x[2] = me->point2[2] - me->point1[2];

            MAdotvc(sts1,x,&me->window_matrix[0],&s);

            if (s < 0.0) {
                x[0] = -x[0];
                x[1] = -x[1];
                x[2] = -x[2];
            }
        }
        else {
            x[0] = me->vector[0];
            x[1] = me->vector[1];
            x[2] = me->vector[2];

            MAdotvc(sts1,x,&me->window_matrix[0],&s);

            if (s < 0.0) {
                x[0] = -x[0];
                x[1] = -x[1];
                x[2] = -x[2];
            }
        }

        MAcrossvc(sts1, z, x, vec);
        MAunitvc(sts1, vec, y);
        MAcrossvc(sts1, y, z, x);

        lb.matrix[0]  = x[0];
        lb.matrix[1]  = y[0];
        lb.matrix[2]  = z[0];
        lb.matrix[4]  = x[1];
        lb.matrix[5]  = y[1];
        lb.matrix[6]  = z[1];
        lb.matrix[8]  = x[2];
        lb.matrix[9]  = y[2];
        lb.matrix[10] = z[2];
        lb.matrix[12] = 0.0;
        lb.matrix[13] = 0.0;
        lb.matrix[14] = 0.0;
        lb.matrix[15] = 1.0;

    }
    else MAtrnmx(sts1, &four, me->window_matrix, lb.matrix);

    lb.matrix[3] = tlb.matrix[3];
    lb.matrix[7] = tlb.matrix[7];
    lb.matrix[11] = tlb.matrix[11];

    for (i=0; i < 3; ++i) {
        lb.diag_pt1[i] = 0.0;
        lb.diag_pt2[i] = 0.0;
    }

    /*
     * Save the description of the coordinate system's geometry.
     */
    me->dyn_lbsys = lb;

    /*
     *  Construct the coordinate system.
     */
    old_weight = me->ActiveDisplay.weight;
    me->ActiveDisplay.weight = 0;
    status = GRconstruct_cs ( sts1, 
                              &me->ModuleInfo, 
                              me->ActiveLevel,
                              &me->ActiveDisplay,
                              GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE,
                              NULL, 
                              "GRdvcs", 
                              &lb, 
                              &me->cs_id );
    me->ActiveDisplay.weight = old_weight;

    /*
     *  Get the scale of the drawing view.
     */
    status = gr$gspass ( msg = sts1,
                         pass_msg = message GRdrawview.GRget_drawview_scale 
                                                    ( sts1,
                                                      &mod_env,
                                                      NULL, 
                                                      scale ),
                         path = &mod_env,
                         p_chanselect = &me->located_chansel);

    /*
     *  Set the scale of the coordinate system.
     */
    status = om$send (msg = message GRgencs.GRcssetscale ( sts1, 
                                                           CS_ABSOLUTE,
                                                           scale ),
                      targetid = me->cs_id.objid, 
                      targetos = me->cs_id.osnum);

    /*
     *  Connect the coordinate system to the drawing view.
     */
    status = gr$gspass ( msg = sts1,
                         pass_msg = message GRdrawview.GRcomponent_add 
                                                        ( sts1,
                                                          &mod_env, 
                                                          &me->cs_id, 
                                                          GR_DV_CS ),
                         path = &mod_env,
                         p_chanselect = &me->located_chansel);
 
    status = OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method construct_x_aligned_cs ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    short           four = 4;
    double          scale[3];
    IGRlong        *sts1;
    IGRpoint        point;
    IGRmatrix       matrix;
    struct IGRlbsys lb;
    struct GRmd_env mod_env;
    IGRpoint        handle, handle_norm, proj_point;
    struct IGRline  fold_line, norm_line;
    char	    old_weight;

   sts1 = (IGRlong *)sts;
   *sts1 = MSSUCC;

   /*
    *  Delete the original coordinate system.
    */
    status = gr$gspass ( msg = sts1,
                         pass_msg = message GRdrawview.GRcomponent_delete 
                                                         ( sts1,
                                                           &mod_env, 
                                                           GR_DV_CS ),
                         path = &mod_env,
                         p_chanselect = &me->located_chansel);
    
    /*
     * If auxiliary view project the button event onto either the
     * folding line or the normal to the folding line which ever is
     * nearer.
     */
    if ((me->mytype == CO_auxview) ||
       ((me->mytype == CO_drawview) && (me->cmd_mode == CO_auxview)) ) 
    {
        handle[0] = me->point1[0] + me->dyn_lbsys.matrix[0];
        handle[1] = me->point1[1] + me->dyn_lbsys.matrix[4];
        handle[2] = me->point1[2] + me->dyn_lbsys.matrix[8];

        handle_norm[0] = me->point1[0] + me->dyn_lbsys.matrix[1];
        handle_norm[1] = me->point1[1] + me->dyn_lbsys.matrix[5];
        handle_norm[2] = me->point1[2] + me->dyn_lbsys.matrix[9];

        fold_line.point1 = me->point1;
        norm_line.point1 = me->point1;
        fold_line.point2 = handle;
        norm_line.point2 = handle_norm;

        GRptnlineproj( sts1,
                       &(fold_line),
                       &(norm_line),
                       &(me->event1.event.button.x),
                       proj_point );

        me->event1.event.button.x = proj_point[0];
        me->event1.event.button.y = proj_point[1];
        me->event1.event.button.z = proj_point[2];
    }
   
    /*
     *  Define matrix for coordinate system.
     */
    point[0] = me->event1.event.button.x - me->point1[0];
    point[1] = me->event1.event.button.y - me->point1[1];
    point[2] = me->event1.event.button.z - me->point1[2];

    MAxrotmx(sts1, point, matrix);
    MAtrnmx(sts1, &four, matrix, lb.matrix);
    lb.matrix[3]  =  me->point1[0];
    lb.matrix[7]  =  me->point1[1];
    lb.matrix[11] =  me->point1[2];

    /*
     *  Construct the coordinate system.
     */
    old_weight = me->ActiveDisplay.weight;
    me->ActiveDisplay.weight = 0;
    status = GRconstruct_cs ( sts1, 
                              &me->ModuleInfo, 
                              me->ActiveLevel, 
                              &me->ActiveDisplay, 
                              GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE,
                              NULL, 
                              "GRdvcs", 
                              &lb, 
                              &me->cs_id );
    me->ActiveDisplay.weight = old_weight;

    /*
     *  Get the scale of the drawing view.
     */
    status = gr$gspass ( msg = sts1,
                         pass_msg = message GRdrawview.GRget_drawview_scale 
                                                    ( sts1,
                                                      &mod_env, 
                                                      NULL, 
                                                      scale ),
                         path = &mod_env,
                         p_chanselect = &me->located_chansel);

    /*
     *  Set the scale of the coordinate system.
     */
    status = om$send ( msg = message GRgencs.GRcssetscale ( sts1, 
                                                            CS_ABSOLUTE,
                                                            scale ),
                       targetid = me->cs_id.objid, 
                       targetos = me->cs_id.osnum);

    /*
     *  Connect the coordinate system to the drawing view.
     */
    status = gr$gspass ( msg = sts1,
                         pass_msg = message GRdrawview.GRcomponent_add 
                                                        ( sts1,
                                                          &mod_env, 
                                                          &me->cs_id, 
                                                          GR_DV_CS ), 
                         path = &mod_env,
                         p_chanselect = &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method transform_cs ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    short           matrix_type;
    IGRlong        *sts1;
    IGRmatrix       matrix;
    struct IGRlbsys lb;

    sts1 = (IGRlong *)sts;

    /*
     *  Get the coordinate system origin.
     */
    status = om$send ( msg = message GRvg.GRgetgeom ( 
                                         sts1, 
                                         &me->ModuleInfo.md_env.matrix_type, 
                                         me->ModuleInfo.md_env.matrix, 
                                         (IGRchar *)&lb),
                       targetid = me->cs_id.objid,
                       targetos = me->cs_id.osnum);

    /*
     *  Build a translation matrix.
     */
    MAidmx(sts1, matrix);

    matrix[3]  =  me->event1.event.button.x - lb.matrix[3];
    matrix[7]  =  me->event1.event.button.y - lb.matrix[7];
    matrix[11] =  me->event1.event.button.z - lb.matrix[11];

    /*
     *  Transform the coordinate system.
     */
    MAtypemx (sts1, matrix, &matrix_type);
    status = om$send ( msg = message GRgraphics.GRxform ( sts1, 
                                                          &me->ModuleInfo,
                                                          &matrix_type, 
                                                          matrix, 
                                                          &me->cs_id.objid ),
                       targetos = me->cs_id.osnum,
                       targetid = me->cs_id.objid);

    status = OM_S_SUCCESS;
quit:
  return OM_S_SUCCESS;
}

method construct_drawview ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    int      msg;
    int      properties;
    int      ref_properties;
    int      env_prop = 0;
    struct GRid dv_id;
    struct GRid my_GRid;
    char     write[MAXPATHLEN];

    *sts = MSSUCC;

    ex$message ( msgnumb = GR_I_WRITE1, buff = &write [0] );
    ex$message ( msgnumb = GR_I_WRITE2, buff = &write [1] );

    my_GRid.objid = my_id;
    my_GRid.osnum = OM_Gw_current_OS;
    me->origin[0] = me->event1.event.button.x;
    me->origin[1] = me->event1.event.button.y;
    me->origin[2] = me->event1.event.button.z;

    if (me->model[0] != '\0')
       me->ref_info.filename = me->model;
    if (me->view[0] != '\0')
       me->ref_info.named_view = me->view;
    if (me->text_scale[0] != '\0')
       me->ref_info.scale = me->text_scale;

    ref_properties = GRIS_MODEL_ATTACHMENT;
    if (!(me->mode == write[0] || me->mode == write[1]))
        ref_properties |= GRRF_IS_READ_ONLY;

    properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    me->ref_info.ref_properties = (int unsigned *) &ref_properties;
 
    if (me->orientation) {
        status = GRconstruct_dv ( (IGRlong *)sts, 
                                  &me->ModuleInfo, properties,
                                  &me->ActiveDisplay, 
                                  me->ActiveLevel, 
                                 (me->name[0] == '\0') ? 
                                 NULL : me->name,
                                 (me->desc[0] == '\0') ? 
                                 NULL : me->desc,
                                 &me->orientation, 
                                 &me->ref_info,
                                 "GRdrawview", 
                                 me->window_matrix, 
                                 me->origin,
                                 me->text_scale, 
                                 &dv_id, 
                                 NULL );
    }
    else {
        status = GRconstruct_dv ( (IGRlong *)sts, 
                                  &me->ModuleInfo, 
                                  properties,
                                  &me->ActiveDisplay, 
                                  me->ActiveLevel, 
                                  (me->name[0] == '\0') ? 
                                  NULL : me->name,
                                  (me->desc[0] == '\0') ? 
                                  NULL : me->desc,
                                  NULL, 
                                  &me->ref_info, 
                                  "GRdrawview",
                                  me->window_matrix, 
                                  me->origin, 
                                  me->text_scale,
                                  &dv_id, 
                                  NULL );
    }

    if (status & *sts & 1) {
        /*
         *  Disconnect the previously created object from myself
         */
        status = gr$gsempty ( msg = &msg, 
                              p_chanselect = &me->located_chansel );

        if (status & 1) 
            status = GRgsadd_object ( &msg, 
                                      &dv_id, 
                                      &me->ModuleInfo,
                                      &env_prop, 
                                      &my_GRid, 
                                      &me->located_chansel );
    }
    else {
        /*
         *  Allow sts to be passed back with the return code.
         */
        status = OM_S_SUCCESS;
        if (*sts == MSSUCC) *sts = MSFAIL;
    }
quit:
  return OM_S_SUCCESS;
}

method align_drawing_views ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    GRobjid  objid;

    status = om$construct( osnum = me->ModuleInfo.md_id.osnum,
                           classname = "GRdvalign",
                           msg = message GRdvalign.GRdvalign_init( 
                                                     (IGRlong *)sts, 
                                                     &me->dv_id1,
                                                     &me->dv_id2, 
                                                     me->vector ),
                           p_objid = &objid);
quit:
  return OM_S_SUCCESS;
}

method define_drawview_orientation ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    int          i,msg;
    int          length;
    char         string1 [80];
    char         string2 [80];
    IGRmatrix       matrix;
    struct var_list var_list[2];
    long         which_error;
    long         nret;

    *sts = MSSUCC;
 
    strncpy (string1, me->event1.event.keyin,79);

    /*
     * See if there is a principle saved view named string1 in the
     * drawing file.
     */

    var_list[0].var = VIEW_ROTATION;
    var_list[0].var_ptr = (char *) matrix;
    var_list[0].num_bytes = sizeof(double) * 16;
    var_list[0].bytes_returned = &nret;
    var_list[1].var = END_PARAM;
 
    *sts = dp$inq_set_saved_view ( msg = &msg,
                                   osnum = me->ModuleInfo.md_id.osnum,
                                   vw_name = string1,
                                   which_error = &which_error,
                                   var_list = var_list );

    length = strlen (string1);
    for (i = 0; i < length; ++i) string1[i] = tolower(string1[i]);

    /*
     * If there was a principle saved view named string1 in the
     * drawing file get the real name for the view.(specify NULL).
     */

    if ( *sts & msg & 1) GRdvid_matrix((IGRlong *)sts, matrix, string1, NULL);

    ex$message (msgnumb = GR_I_Top, buff = string2);

    length = strlen (string2);
    for (i=0; i<length; ++i) string2[i] = tolower(string2[i]);

    if (!COtool_ci_strcmp (string1, string2)) me->orientation |= GR_DV_TOP;
    else 
    {
        ex$message (msgnumb = GR_I_Front, buff = string2);
        length = strlen (string2);
        for (i=0; i<length; ++i) string2[i] = tolower(string2[i]);
        if (!COtool_ci_strcmp (string1, string2)) {
            me->orientation |= GR_DV_FRONT;
        }
        else 
        {
            ex$message (msgnumb = GR_I_Left, buff = string2);

            length = strlen (string2);
            for (i=0; i<length; ++i) string2[i] = tolower(string2[i]);

            if (!COtool_ci_strcmp (string1, string2)) {
                me->orientation |= GR_DV_LEFT;
            }
            else 
            {
                ex$message (msgnumb = GR_I_Back, buff = string2);

                length = strlen (string2);
                for (i=0; i<length; ++i) string2[i] = tolower(string2[i]);

                if (!COtool_ci_strcmp (string1, string2)) {
                    me->orientation |= GR_DV_BACK;
                }
                else 
                {
                    ex$message (msgnumb = GR_I_Right, buff = string2);

                    length = strlen (string2);
                    for (i=0; i<length; ++i) string2[i] = tolower(string2[i]);

                    if (!COtool_ci_strcmp (string1, string2)) {
                        me->orientation |= GR_DV_RIGHT;
                    }
                    else 
                    {
                        ex$message (msgnumb = GR_I_Bottom, buff = string2);

                        length = strlen (string2);
                        for (i=0; i<length; ++i) string2[i] = tolower(string2[i]);

                        if (!COtool_ci_strcmp (string1, string2)) {
                            me->orientation |= GR_DV_BOTTOM;
                        }
                        else 
                        {
                           ex$message (msgnumb = GR_I_Iso, buff = string2);

                           length = strlen (string2);
                           for (i=0; i<length; ++i) string2[i] = tolower(string2[i]);

                           if (!COtool_ci_strcmp (string1, string2)) {
                               me->orientation |= GR_DV_ISO;
                           }
                           else *sts = MSFAIL;
                        }
		    }
                }
            }
        }
    }
quit:
  return OM_S_SUCCESS;
}

method build_drawview_layers ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    short ret_nlayers;
    short layer;
    char  string[4];
    int   i;
    GRobjid  mgr_id;
   
    string[0] = tolower (me->event1.event.keyin[0]);
    string[1] = tolower (me->event1.event.keyin[1]);
    string[2] = tolower (me->event1.event.keyin[2]);
    string[3] = tolower (me->event1.event.keyin[3]);

    if (!strcmp ("all", string)) {
        for (i=0; i < DP_NUM_OF_LEVELS; i++)
            me->layer_mask_buffer[i/32] |= (1<<(i % 32));
    }
    else {
        struct GRmd_env rf_env;
        IGRlong         *sts1, ok;
        GRspacenum      reset_osn=NULL;
        struct GRid     ref_id;
        int             type;

        sts1 = (IGRlong *)sts;

        ref_id.objid = NULL_OBJID;
        ref_id.osnum = me->ModuleInfo.md_id.osnum;
        gr$gspass ( msg = &ok,
                pass_msg = message GRdrawview.GRget_component_id
                                            ( sts1,
                                              GR_DV_REFFILE,
                                              1,
                                              &ref_id,
                                              &type ),
                path = &me->ModuleInfo,
                p_chanselect = &me->located_chansel);

      if(ok & *sts1 & 1)
      {  

       status = gr$gspass (msg = sts1,
         pass_msg = message GRreffile.GRgetenvironment (sts1, &me->ModuleInfo,
         &rf_env),
         p_chanselect = &me->located_chansel);

        reset_osn = me->ModuleInfo.md_id.osnum;
        me->ModuleInfo.md_id.osnum = rf_env.md_id.osnum;
      }

        status = GRget_global_mgr_id ( sts, 
                                       "DPLVLDIR", 
                                       me->ModuleInfo.md_id.osnum, 
                                       &mgr_id );

        for (i=0; i < (DP_NUM_OF_LEVELS/32 + 1); i++)
            me->layer_mask_buffer[i] = 0;

        status = om$send ( msg = message DPlvldir.convert_lev_string (
                                           (int *)sts, 
                                           me->event1.event.keyin, 
                                           &ret_nlayers, 
                                           &layer,
                                           (IGRlong *)me->layer_mask_buffer ),
                           targetid = mgr_id,
                           targetos = me->ModuleInfo.md_id.osnum);

        if(!status || !(1 & *sts))
        {
          ex$message ( msgnumb = GR_E_InvLy );
        }
        else
          UI_status ( "  ");  

       if(reset_osn)
        me->ModuleInfo.md_id.osnum = reset_osn;

    }
quit:
  return OM_S_SUCCESS;
}

method store_reference_file_scale ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   sscanf (me->event1.event.keyin, "%lf", &me->scale);
quit:
  return OM_S_SUCCESS;
}

method scale_reference_file ( long * sts )
{
  int		  status = OM_S_SUCCESS;

IGRlong          *sts1;
IGRmatrix         matrix;
double            scale_vc[4];
IGRpoint          tpoint;
struct GRmd_env   mod_env;

   sts1 = (IGRlong *)sts;

   if (me->scale < 1e-5)
	me->scale = 1.0;

   tpoint[0] = me->event1.event.button.x;
   tpoint[1] = me->event1.event.button.y;
   tpoint[2] = me->event1.event.button.z;
   scale_vc[0] = me->scale;
   scale_vc[1] = me->scale;
   scale_vc[2] = me->scale;
   scale_vc[3] = 1.0;

   MAgscamx (sts1, me->window_matrix, tpoint, scale_vc, matrix);

   status = gr$gspass ( msg = sts1,
            pass_msg = message GRreffile.GRxformref (sts1,
            &mod_env.md_env.matrix_type, mod_env.md_env.matrix, matrix),
            path = &mod_env,
            p_chanselect = &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method change_drawview_layers (int *sts; int flag)
{
  int		  status = OM_S_SUCCESS;

  IGRlong   *sts1;
  short      s_flag = flag;

   sts1 = (IGRlong *)sts;

   status = gr$gspass (msg = sts1,
            pass_msg = message GRreffile.GRchglevels (sts1, &s_flag,
            me->layer_mask_buffer),
            p_chanselect = &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method scale_drawview (long *sts; int flag)
{
  int		  status = OM_S_SUCCESS;

IGRpoint    point;

   point[0] = me->event1.event.button.x;
   point[1] = me->event1.event.button.y;
   point[2] = me->event1.event.button.z;
   
   status = gr$gspass ( msg = (IGRlong *)sts,
            pass_msg = message GRdrawview.GRscale_drawing_view ((IGRlong *)sts,
            &me->ModuleInfo, &flag, me->text_scale, point),
            p_chanselect = &me->located_chansel);
quit:
  return OM_S_SUCCESS;
}

method echo_mode ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRboolean assoc_flag;
  char       tmp [MAXPATHLEN];

  *sts = MSSUCC;
  gr$get_associative_flag ( sizbuf = sizeof ( IGRboolean ), buffer = &assoc_flag );

  /* Check if the file is in the list of writable files */
  GRis_writable ( (IGRlong *)sts, me->model, 0, (OMuword)0 );
  if (*sts == MSSUCC)
    /* The file is writable (flag is ON and it is in the list) */
    me->mode = 'W';
  else
    /* see if the file is open */
    if (ex$is_file_open ( name = me->model ))
    {
      extern char   *getenv();
      extern IGRint  GRcondense_path();

      long    msg;
      OMuword osnum = 0;
      char   *current_dir,
              model_file_name[MAXPATHLEN];
    
      /* The file is writable if it is the module and read-only otherwise;
       * need a full path name before calling om$os_name_to_number
       */

      if (me->model[0] == '/')
      {
        strcpy(model_file_name, me->model);
      }
      else
      {
        if ((current_dir = getenv("PWD")) &&
            ((strlen(current_dir) + strlen(me->model) + 1) < MAXPATHLEN))
        {
          strcpy(model_file_name, current_dir);
          strcat(model_file_name, "/");
          strcat(model_file_name, me->model);
        }
      }

      /* need to remove any relative paths from the path */

      GRcondense_path(&msg, model_file_name);

      om$os_name_to_number ( osname = model_file_name, p_osnum = &osnum );

      if (osnum)
      {
        GRcheckref ( &msg, NULL, NULL, NULL, &osnum );

        if (msg != MSSUCC) 
        {
            me->mode = 'W';
        }
        else
        {
            IGRlong status, ok;

            status = GRis_nested_writable (&ok,model_file_name);

            me->mode =  (status & ok & 1) ? 'W' : 'R';
        }
      }
      else
        me->mode = 'W';
      *sts = MSSUCC;
    }
    else
      /* It's a new file, the assoc flag is used to determine the attachment mode */
      if (assoc_flag)
      {
        FILE *fet;
        
        /* in order for the file to be read/write, we must have the write permission */
        fet = fopen ( me->model, "r+" );
        if (!fet)
        {
          me->mode = 'R';
          *sts = MSSUCC;
        }
        else
        {
          /* Associativity is ON, the file is not already open and we can write to it */
          me->mode = 'W';
          fclose ( fet );
        }
      }       
      else
        me->mode = 'R';

  ex$message ( msgnumb = me->mode == 'W' ? GR_I_RWFILE : GR_I_ROFILE,
               type = "%s",  
               buff = tmp,
               var = `me->model` );
  UI_status ( tmp );
quit:
  return OM_S_SUCCESS;
}

method status_disp ( )
{
  int		  status = OM_S_SUCCESS;

  char *form_ptr;
  int index, msg;

  status = om$send( msg = message CEO.get_form_ptr( STATUS_FORM, &form_ptr,
                                                    &index, &msg ),
                    targetid = my_id ); 

  if ( status & 1 ) {
    if ( form_ptr  ) {
/*
 *  Command has a status display form & we are controling when the form
 *  will be displayed
 */
      if ( me->option == DISABLEOPT_MODE )
        me->form_requested = 0;
      else
        me->form_requested = 1;
    }
    else {
/*
 *  Command does not have a status display form
 */
      status = om$send( msg = message CEO.status_disp(),
                        mode = OM_e_wrt_message, targetid = my_id ); 
    }  
  }
quit:
  return OM_S_SUCCESS;
}

end implementation COdetail;
