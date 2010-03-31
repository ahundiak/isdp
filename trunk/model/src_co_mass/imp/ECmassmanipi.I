/* ###################   APOGEE COMPILED   ################## */
class implementation ECmassmanip;

# include "EMS.h"
# include <stdio.h>

%safe
#include <math.h>
%endsafe

# include "emsdattyp.h"
# include "emsdef.h"
# include "csdef.h"
# include "bsdefs.h"
# include "bserr.h"
# include "bsparameters.h"
# include "madef.h"
# include "emsmass.h"
# include "EMSlogic.h"
# include "EMS_I.h"
# include "EMS_P.h"
# include "EMS_M.h"
# include "EMS_E.h"

# include "griomacros.h"
# include "lcmacros.h"
# include "OMmacros.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "dpmacros.h"
# include "EMScmacros.h"
# include "DIdef.h" /* DI_PATH_MAX */
# include "msdef.h"
# include "msmacros.h"
# include "ECmsg.h"
# include "ECcmd.h"
# include "EMSpromacros.h"

#include "bseig3x3.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

# define MAX_CHAR_LEN 80

from EMSmassprop import EMreadprop,
                        EMget_geometry,
                        EMedit_mass_prop;
from GRgraphics  import GRdelete;
from GRgraphics  import GRdisplay;
from GRvg        import GRgetname,
                        GRgetrang;

extern OMuword OPP_EMSmassprop_class_id;
extern OMuword OPP_GRbspline_class_id;

/*
 * History:
 * ??/??/87 : GK : Creation
 * 11/01/88 : pp : Added code to output the triad to database as an option
 * 07/24/89 : gupta : Support for active coordinate system, etc...rewrite
 * 02/16/90 : pp    : Made changes to support outputting first area moments
 *                    for planar sections to fulfill NAVSEA MMR.
 * 07/27/90 :Inasu  : For the case change area props, the value of polar
 *                    moment of inertia is set to zero before transformation.
 *                     (Fix for TR 90N1955)  
 *
 * 06/16/93 : Sudha : Modified for BSprototype ansification
 *
 */


/*------------------------------------------------------ */

method init(int type; char *str_ptr)
{
 ME.super_cmd->state = 0;
 me->stderr_only = TRUE;

  return (OM_S_SUCCESS);
}

/* ----------------------------------------------------------- */

method sleep (int pos )
{
 ex$message (msgnumb = EMS_P_ClearPromptField);
 ex$message (msgnumb = EMS_I_ClearStatusField);
 ex$message (msgnumb = EM_M_ClearMessageField);

 return (OM_S_SUCCESS);
}

/* ----------------------------------------------------------- */

method wakeup ( int pos )
{
 IGRlong               bytes_in, bytes_out, msg;

 msg = 1;
 bytes_in = sizeof(struct IGRdisplay);
 gr$get_active_display(msg = &msg, 
                       sizbuf = &bytes_in,
                       buffer = &me->active_symbology.display_attr,
                       nret = &bytes_out);
 if (!(1 & msg))
  {
    fprintf(stderr, "ECmassmanip:get_active_display error %d", msg);
    return(OM_E_ABORT);
  }

 return ( OM_S_SUCCESS );
}

/* ------------------------------------------------------------ */

method execute ( int *response; char *response_data; int pos )
{

  IGRlong             status, msg, event_mask1, event_mask2,
                      size, i, display_flag, EFrblineseg(),
                      ECdisplayPointSetBuffer();
/* IGRlong	      two = 2 */
  struct GRevent      event, accev;
  struct GRlc_locate  attributes;
  OM_S_CLASSLIST      rtree_classes, elig_classes;
  IGRboolean          world = TRUE;
  OMuword             rclass, eliclass[2];
  OMuint              count, chan_count;
  IGRint              coord_type;
  IGRpoint            act_centroid;
  IGRpoint            old_vol_centroid, vol_centroid;
  IGRdouble	          prop[NUMB_PROPS], area_props[NUMB_PROPS],
                      factor, scratch, eig_matrix[3][3],
                      x_axis[3], y_axis[3], z_axis[3], y_dirn[3], 
                      line_ends[6], my_geom[9], rect_origin[3];
  IGRdouble           solid_range[6];
  static IGRdouble    identity_matrix[9] = {1.0,  0.0,  0.0, 
                                            0.0,  1.0,  0.0, 
                                            0.0,  0.0,  1.0 };
  /*void                MSdrawtriadn(), MSdisplay_prop(), 
                      MScnvtprop();*/
  enum	GRdpmode      DisplayMode;
  FILE                *prop_file;
  extern IGRdouble    sqrt();
  IGRboolean          log_status;
  IGRchar             master_units[MAX_CHAR_LEN];
  IGRchar             display_message[80];
  IGRchar             misc_str[80];
  IGRchar             loc_prompt[MAX_CHAR_LEN], 
                      acc_prompt[MAX_CHAR_LEN],
                      reloc_prompt[MAX_CHAR_LEN];
  IGRchar             object_name[DI_PATH_MAX],
                      c_name[80];
  OM_S_CHANSELECT     to_comps, to_object;
  OM_S_OBJECT_LINKAGE  chan_object;
  OM_S_OBJECT_LINKAGE  *child_objects;


#define     INIT                0
#define	    GET_DESIGNATOR      1
#define	    OUTPUT_FILE_NAME    9
#define	    GET_ORIENTATION     2
#define	    GET_ORIGIN          3
#define	    GET_X_AXIS          4
#define	    GET_Y_DIRECTION     5
#define     PROCESS             7
#define     GET_PROPERTIES      8

#define	    ACTIVE_AT_CENTROID  1
#define	    PRINCIPAL           2
#define	    GENERAL             3

ex$message ( msgnumb = EM_M_ManipMassAreaProps);

size = sizeof(struct GRevent);

status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
status = om$make_chanselect (channame = "EMSmassprop.to_object",
                             p_chanselect = &to_object);
if (! (1 & status)) goto wrapup;

  do
   {
     switch (ME.super_cmd->state)
       {
       case INIT:

       case GET_DESIGNATOR:

             event_mask1 = GRm_DATA | GRm_BACK_UP;
             event_mask2 = GRm_DATA;
             ex$message(msgnumb = EMS_P_IdmassareaD, buff = loc_prompt);
             display_flag = 6;

             ex$message(msgnumb = EMS_P_AcceptReject, buff = acc_prompt);
             ex$message(msgnumb = EMS_P_Designotfound, buff = reloc_prompt);
             attributes.properties = 0x11 | LC_RW;
             attributes.owner_action = LC_RIGID_OWNER |
                                       LC_REF_OBJECTS |
                                       LC_NO_REF_HEADER;
             strcpy(attributes.classes, "EMSmassprop");

             rtree_classes.w_count = 1;
             elig_classes.w_count = 1;
             rtree_classes.w_flags = elig_classes.w_flags = 
                                     OM_CLST_subclass;

             rclass = OPP_GRbspline_class_id;
             eliclass[0] = OPP_EMSmassprop_class_id;

             rtree_classes.p_classes = &rclass;
             elig_classes.p_classes = &eliclass[0];

             status = lc$locate(rc = &msg,
                                event1 = &me->event_1, 
                                event2 = &accev,
                                mask1 = event_mask1, 
                                mask2 = event_mask2,
                                eventsize = &size, 
                                display_flag = display_flag,
                                response = response, 
                                response_data = response_data, 
                                locate_prompt = loc_prompt, 
                                acc_prompt = acc_prompt,
                                relocate_prompt = reloc_prompt, 
                                attributes = &attributes, 
                                stack = &me->stack,
                                rtree_classes = &rtree_classes, 
                                eligible_classes = &elig_classes);

             ex$message (msgnumb = EMS_S_ClearStatusField);
             ex$message (msgnumb = EMS_P_ClearPromptField);
             if (status == FALSE)
              {
               ex$message ( msgnumb = EMS_E_FailInputProcExit);
               *response = TERMINATE;
               goto wrapup;
              }
             if (msg == FALSE)
              {
               if (me->event_1.response == EX_BACK_UP)
                   break;
               else
                   return(OM_S_SUCCESS);    /*goto wrapup;*/
              }

             switch (accev.response)
              {
               case EX_DATA:
                    me->designator_id.objid =
                                accev.located_object[0].located_obj.objid;
                    me->designator_id.osnum =
                                accev.located_object[0].located_obj.osnum;

                    OM_BLOCK_MOVE(&accev.located_object[0].module_info,
                                  &me->ModuleInfo,
                                  sizeof(struct GRmd_env));
                    ME.super_cmd->state = GET_PROPERTIES;
                    break;
               default:
                    return(OM_S_SUCCESS);		/*goto wrapup;*/
              }
             break;


       case GET_PROPERTIES:

            status = om$send(msg = message EMSmassprop.EMreadprop (&msg,
                                   &me->ModuleInfo, &me->op_type,
                                   &me->in_orient, me->prop,
                                   me->in_origin, me->in_glo_loc,
                                   me->prin_glo_loc, &me->density),
                             targetid = me->designator_id.objid,
                             targetos = me->designator_id.osnum);
            if (! (1 & status & msg)) goto wrapup;
            ME.super_cmd->state = OUTPUT_FILE_NAME;
       break;

       case OUTPUT_FILE_NAME:

           ex$message(msgnumb = EMS_P_EnterOputFileNam, buff = display_message);
            status = co$getevent(msg = &msg,
                                event_mask = GRm_TEXT_VALUE |
                                             GRm_BACK_UP    |
                                             GRm_RJT_MOVEON,
                                prompt = display_message,
                                response = response,
                                response_data = response_data,
                                event = &event);
            if (msg == GRw_no_value) event.response = EX_RJT_MOVEON;

            if (! status) goto wrapup;
            else if (event.response IS GR_UNKNOWN_TYPE)
                     return(OM_S_SUCCESS);
            else if (event.response IS EX_BACK_UP)
  	                ME.super_cmd->state = GET_DESIGNATOR;
            else if (event.response IS EX_RJT_MOVEON)
             {
              me->stderr_only = TRUE;
              ME.super_cmd->state = GET_ORIENTATION;
             }
            else
             {
              me->stderr_only = FALSE;
              strcpy(me->dest_file_name, event.event.keyin);

              /* does a file by this name exist. if so warn the user */

              if (me->dest_file_name[0] IS 0) break; /* return was hit */

              prop_file = (FILE *) fopen(me->dest_file_name, "r");

              if (prop_file)
               ex$message ( msgnumb = EMS_I_FileExistsWillApp);
              fclose(prop_file);
              ME.super_cmd->state = GET_ORIENTATION;
             }

            break;

       case GET_ORIENTATION:

            me->dest_orient = (me->op_type == MASS_PROPERTIES) ? 1 : 3;

            if (me->op_type == AREA_PROPERTIES)
           ex$message(msgnumb = EMS_P_EnterOrientA, buff = display_message)
            else
           ex$message(msgnumb = EMS_P_EnterOrientB, buff = display_message)
            
            status = co$getevent (msg = &msg,
                     event_mask =GRm_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP,
                     value_type = GRIO_SCALAR,
                     prompt = display_message,
                     response = response,
                     response_data = response_data,
                     event = &event);
            if (! status)
                goto wrapup;
            else
            if (event.response IS GR_UNKNOWN_TYPE)
                return(OM_S_SUCCESS);
            else if (event.response IS EX_BACK_UP)
             {
              ME.super_cmd->state = OUTPUT_FILE_NAME;
              break;
             }
            else if(event.response IS EX_RJT_MOVEON)
             {
              /* okay, take default */           
             }
            else if(msg ISNT GRw_no_value)
             {
              me->dest_orient = (int) event.event.value;

              if (me->op_type == AREA_PROPERTIES)
               {
                if (me->dest_orient == 1) me->dest_orient = 2;
                else if (me->dest_orient == 2) me->dest_orient = 3;
               }
             }

            if ((me->dest_orient IS ACTIVE_AT_CENTROID) &&
                (me->op_type == MASS_PROPERTIES))
             {
              ex$message ( msgnumb = EMS_S_ActiveCoordSys);
             }
            else if(me->dest_orient IS PRINCIPAL)		/* 2 */
             {
              ex$message (msgnumb = EMS_I_PrincipleOrient);
             }
            else
             {
              ex$message (msgnumb = EMS_I_GeneralOrient);
              me->dest_orient = GENERAL;
             }
	
            if (me->dest_orient IS GENERAL)
                ME.super_cmd->state = GET_ORIGIN;
            else
             {
              me->dest_origin[0] = me->prop[2];
              me->dest_origin[1] = me->prop[3];
              me->dest_origin[2] = me->prop[4];

              ME.super_cmd->state = PROCESS;
             }
       break;

       case GET_ORIGIN:

            status = co$getevent (msg = &msg,
                     event_mask = GRm_DATA | GRm_BACK_UP,
                     msgnum = EMS_P_00113,
                     response = response,
                     response_data = response_data,
                     event = &event);
            if (! status)
                goto wrapup;
            else if (event.response IS GR_UNKNOWN_TYPE)
                     return (OM_S_SUCCESS);
            else if (event.response IS EX_BACK_UP)
             {
              ME.super_cmd->state = GET_ORIENTATION;
              break;
             }
            else
             {
              me->dest_origin[0] = event.event.button.x;
              me->dest_origin[1] = event.event.button.y;
              me->dest_origin[2] = event.event.button.z;

              ME.super_cmd->state = GET_X_AXIS;
             }
       break;

       case GET_X_AXIS:

            ex$message (msgnumb = EMS_P_InputXAxis);

            status = EFrblineseg (me->dest_origin,
                                  &me->active_symbology.display_attr);

            status = co$getevent (msg = &msg,
                     event_mask = GRm_DATA | GRm_BACK_UP,
                     response = response,
                     response_data = response_data,
                     event = &event);
            if (! status)
                goto wrapup;
            else if (event.response IS GR_UNKNOWN_TYPE)
                return(OM_S_SUCCESS);
            else if (event.response IS EX_BACK_UP)
             {
              ME.super_cmd->state = GET_ORIGIN;
              break;
             }
            else
             {
              me->x[0] = event.event.button.x;
              me->x[1] = event.event.button.y;
              me->x[2] = event.event.button.z;

              line_ends[0] = me->dest_origin[0];
              line_ends[1] = me->dest_origin[1];
              line_ends[2] = me->dest_origin[2];
              line_ends[3] = me->x[0];
              line_ends[4] = me->x[1];
              line_ends[5] = me->x[2];
 
/*
              status = ECdisplayPointSetByBuffer (&msg,
                             me->active_symbology.display_attr,
                             me->ModuleInfo, my_id, two, line_ends, TRUE);
*/

              ME.super_cmd->state = GET_Y_DIRECTION;
             }
       break;

       case GET_Y_DIRECTION:

            ex$message (msgnumb = EMS_P_InputPosiYDirect);

            status = EFrblineseg (me->dest_origin,
                                  &me->active_symbology.display_attr);

            status = co$getevent (msg = &msg,
                     event_mask = GRm_DATA | GRm_BACK_UP,
                     response = response,
                     response_data = response_data,
                     event = &event);
            if (! status)
                goto wrapup;
            else if (event.response IS GR_UNKNOWN_TYPE)
                     return(OM_S_SUCCESS);
            else if (event.response IS EX_BACK_UP)
             {
              ME.super_cmd->state = GET_X_AXIS;
              break;
             }
            else
             {
              y_dirn[0] = event.event.button.x;
              y_dirn[1] = event.event.button.y;
              y_dirn[2] = event.event.button.z;

              line_ends[0] = me->dest_origin[0];
              line_ends[1] = me->dest_origin[1];
              line_ends[2] = me->dest_origin[2];
              line_ends[3] = y_dirn[0];
              line_ends[4] = y_dirn[1];
              line_ends[5] = y_dirn[2];

/*
              status = ECdisplayPointSetByBuffer (&msg,
                             me->active_symbology.display_attr,
                             me->ModuleInfo, my_id, two, line_ends, TRUE);
*/

              /* compute the global to local transformation */
	
              /* check for collinearity - later*/
	
              x_axis[0] = me->x[0] - me->dest_origin[0];
              x_axis[1] = me->x[1] - me->dest_origin[1];
              x_axis[2] = me->x[2] - me->dest_origin[2];
	
              y_axis[0] = y_dirn[0] - me->dest_origin[0];
              y_axis[1] = y_dirn[1] - me->dest_origin[1];
              y_axis[2] = y_dirn[2] - me->dest_origin[2];
	

              log_status = BScrossp (&msg, x_axis, y_axis, z_axis);
	
              log_status = BScrossp (&msg, z_axis, x_axis, y_axis);
	
              scratch = sqrt (x_axis[0]*x_axis[0] + x_axis[1]*x_axis[1] +
                              x_axis[2]*x_axis[2]);

              x_axis[0] /= scratch;
              x_axis[1] /= scratch;
              x_axis[2] /= scratch;
	
              scratch = sqrt (y_axis[0]*y_axis[0] +
                              y_axis[1]*y_axis[1] +
                              y_axis[2]*y_axis[2]);

              y_axis[0] /= scratch;
              y_axis[1] /= scratch;
              y_axis[2] /= scratch;
	
              scratch = sqrt (z_axis[0]*z_axis[0] +
                              z_axis[1]*z_axis[1] +
                              z_axis[2]*z_axis[2]);

              z_axis[0] /= scratch;
              z_axis[1] /= scratch;
              z_axis[2] /= scratch;
	
	
              me->dest_glo_loc[0] = x_axis[0];
              me->dest_glo_loc[1] = x_axis[1];
              me->dest_glo_loc[2] = x_axis[2];
              me->dest_glo_loc[3] = y_axis[0];
              me->dest_glo_loc[4] = y_axis[1];
              me->dest_glo_loc[5] = y_axis[2];
              me->dest_glo_loc[6] = z_axis[0];
              me->dest_glo_loc[7] = z_axis[1];
              me->dest_glo_loc[8] = z_axis[2];
	
              ME.super_cmd->state = PROCESS;
             }
       break;

       case PROCESS:

            ex$message (msgnumb = EMS_I_Processing);
            ex$message (msgnumb = EMS_P_ClearPromptField);

            if (me->dest_orient ISNT GENERAL)
             {
              if (me->dest_orient IS PRINCIPAL)
               {
                for (i=0; i<9; i++) 
                     me->dest_glo_loc[i] = identity_matrix[i];
               }
              else
               {
                MSget_active_csystem(&msg, me->ModuleInfo,
                                     me->dest_glo_loc);
                if (! (1 & msg)) goto wrapup;
               }
             }

            for (i=0; i<NUMB_PROPS; i++) prop[i] = 0.0;

            if (me->op_type == AREA_PROPERTIES)
             {
              area_props[0] =  0.0;
              area_props[1] =  me->prop[11];
              area_props[2] =  me->prop[2];
              area_props[3] =  me->prop[3];
              area_props[4] =  me->prop[4];
              area_props[5] =  me->prop[14];
              area_props[6] =  me->prop[15];
/* In the case of Area Props,polar moment of inertia doesnot contribute for
   transformation. So it is set to zero */
              area_props[7] =  0.0; /* me->prop[14] + me->prop[15]; */
              area_props[8] =  me->prop[16];
              area_props[9] =  0.0;
              area_props[10] = 0.0;
              area_props[11] = me->prop[11];

              if (me->dest_orient IS PRINCIPAL)
               {
                for (i=0; i<6; i++)
                     me->dest_glo_loc[i] = me->prin_glo_loc[i];
                for (i=6; i<9; i++)
                     me->dest_glo_loc[i] = 0.0;
               }

              MScnvtprop (area_props, me->in_origin, me->in_glo_loc,
                          prop, me->dest_origin, me->dest_glo_loc);
             }
            else
             {
              MScnvtprop (me->prop, me->in_origin, me->in_glo_loc,
                          prop, me->dest_origin, me->dest_glo_loc);
             }


            if (me->op_type == MASS_PROPERTIES)
             {
              if (me->dest_orient IS PRINCIPAL)
               {
                status = 1;
                eig_matrix[0][0] =  prop[5];
                eig_matrix[0][1] = -prop[8];
                eig_matrix[0][2] = -prop[10];
  
                eig_matrix[1][0] = -prop[8];
                eig_matrix[1][1] =  prop[6];
                eig_matrix[1][2] = -prop[9];
  
                eig_matrix[2][0] = -prop[10];
                eig_matrix[2][1] = -prop[9];
                eig_matrix[2][2] =  prop[7];

                BSeig3x3 (eig_matrix, (IGRint *)&status, &prop[5], (IGRvector *)me->dest_glo_loc,
                          &msg);

                prop[8] = 0.0;
                prop[9] = 0.0;
                prop[10] = 0.0;
               }
             }

            if (me->op_type == AREA_PROPERTIES)
             {
              prop[14] = prop[5];
              prop[15] = prop[6];
              prop[16] = (me->dest_orient IS PRINCIPAL) ? 0.0 : prop[8];
              for (i=5; i<11; i++) prop[i] = me->dest_glo_loc[i-5];
              me->dest_orient = 0;
             }

	        status = om$send(msg = message EMSmassprop.EMedit_mass_prop(
                                   &msg, &me->ModuleInfo, TRUE, prop,
                                   me->density, me->dest_origin,
                                   me->dest_glo_loc, me->dest_orient),
                            targetid = me->designator_id.objid,
                            targetos = me->designator_id.osnum);
            if (! (1 & status & msg)) goto wrapup;

/*
 * Only if area properties are being computed should this be called.
 * The following effort is to compute the first area moments for planar
 * areas.
 */


            if ((me->op_type == AREA_PROPERTIES) &&
                ((prop[5]*prop[5] + prop[6]*prop[6] + prop[7]*prop[7]) 
                > 0.95)) /* area properties and axis defined */
            {
             status = MSget_first_area_moments(me->dest_origin,
                      &prop[2],prop,&prop[18], &prop[19]);
             if (!status) goto wrapup;
            }

/* end pp */
            MSconvert_to_active_coordinates (&msg, me->ModuleInfo,
                                             &prop[2], act_centroid,
                                             &coord_type, c_name);
            if (! (1 & msg)) goto wrapup;

            for (i=0; i<3; i++)
              prop[2+i] = act_centroid[i];

            MSconvert_to_active_coordinates (&msg, me->ModuleInfo,
                                             me->dest_origin,
                                             rect_origin,
                                             &coord_type, c_name);
            if (! (1 & msg)) goto wrapup;
            if (me->op_type == MASS_PROPERTIES)
            {
             if (prop[19] == 0.01234)
             {
               for (i=0; i<3; i++)
                 old_vol_centroid[i] = prop[16+i];
               MSconvert_to_active_coordinates (&msg, me->ModuleInfo,
                                             &prop[16], vol_centroid,
                                             &coord_type, c_name);
               if (! (1 & msg)) goto wrapup;
               for (i=0; i<3; i++)
                 prop[16+i] = vol_centroid[i];
             }
            }

            strcpy(object_name, " ");

            status = om$get_channel_objects (
                            osnum = me->designator_id.osnum,
                            objid = me->designator_id.objid,
                            p_chanselect = &to_object,
                            list = &chan_object,
                            size = 1,
                            count = &count);
            if (! (1 & status)) goto wrapup;

            status = om$send(msg = message GRvg.GRgetrang(&msg, 
                                   &me->ModuleInfo.md_env.matrix_type,
                                   me->ModuleInfo.md_env.matrix,
                                   &world, &solid_range[0]),
                             targetid = chan_object.S_objid,
                             targetos = chan_object.osnum);
	        if (! (1 & status & msg))
             {
              status = OM_S_SUCCESS;

              /* for accumulated designator not associated */

              status = om$send(msg = message
                                     EMSmassprop.EMget_geometry(&msg,
                                     my_geom),
                               targetid = me->designator_id.objid,
                               targetos = me->designator_id.osnum);
              if (! (1 & status & msg)) goto wrapup;

              me->sld = 0.0;
              for (i=0; i<3; i++)
               {
                scratch = BSdistptpt(&msg, &me->prop[2], &my_geom[i*3]);
                if (scratch > me->sld) me->sld = scratch;
               }
             }
            else
             {
              me->sld = BSdistptpt(&msg,&solid_range[0], &solid_range[3]);
              me->sld *= 0.2;
             }

	        status = om$send(msg = message GRvg.GRgetname (&msg,
                                   object_name),
                             targetid = chan_object.S_objid,
                             targetos = chan_object.osnum);
            if (! (1 & status & msg))
             {
              strcpy(object_name, " ");
              status = OM_S_SUCCESS;
             }

            MSget_master_string(&msg, me->designator_id.osnum,
                                master_units, &factor);
            
            ex$message(msgnumb = EMS_S_Manips, buff = misc_str);
            status = -1;
/************************************************************************
            MSdisplay_prop(me->stderr_only, me->dest_file_name,
                           me->dest_orient, status, misc_str,
                           me->dest_glo_loc, rect_origin, prop, factor,
                           master_units, coord_type, c_name,
                           object_name);
************************************************************************/
            ems$display_prop(
                     stderr_only = me->stderr_only,
                     filename = me->dest_file_name,
                     option = me->dest_orient,
                     object_index =  status,
                     object_descr = misc_str,
                     global_to_local = me->dest_glo_loc,
                     props = prop,
                     origin = rect_origin,
                     factor = factor,
                     master_units = master_units,
                      coord_type = coord_type,
                     coord_name = c_name,
                     object_name = object_name);  

            prop[2] = me->dest_origin[0];	/* fudge */
            prop[3] = me->dest_origin[1];
            prop[4] = me->dest_origin[2];

            if (me->op_type == MASS_PROPERTIES)
            {
             if (prop[19] == 0.01234)
             {
               for (i=0; i<3; i++)
                 prop[16+i]=old_vol_centroid[i];
             }
            }

            me->construct_list.msg = &me->msg;
            me->construct_list.env_info = &me->construct_env;
            me->construct_list.display = &me->display;

            MSfill_construct_list (&msg, NULL, &me->construct_list);

            count = 0;
            status = om$get_channel_count(osnum = me->designator_id.osnum,
                                          objid = me->designator_id.objid,
                                          p_chanselect = &to_comps,
                                          count = &count);
            if (! (1 & status)) goto wrapup;

            if (count)
             {
              child_objects = NULL;

              child_objects = (OM_S_OBJECT_LINKAGE *) om$malloc(size = 
                               count * (sizeof (OM_S_OBJECT_LINKAGE)));
              if (! child_objects) goto wrapup;

              status = om$get_channel_objects (
                                      osnum = me->designator_id.osnum,
                                      objid = me->designator_id.objid,
                                      p_chanselect = &to_comps,
                                      list = child_objects,
                                      size = count,
                                      count = &chan_count);
              if (! (1 & status)) goto wrapup;

              DisplayMode = GRbehe;

              for (i=0; i<chan_count; i++)
               {
                status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                                &me->ModuleInfo.md_env.matrix_type,
                                me->ModuleInfo.md_env.matrix,&DisplayMode,
                                &me->construct_list.env_info->md_id),
                         targetid = child_objects[i].S_objid,
                         targetos = child_objects[i].osnum);      
                if (! (1 & status & msg)) goto wrapup;

                status = om$send(msg = message GRgraphics.GRdelete(&msg,
                                       &me->ModuleInfo),
                         targetid = child_objects[i].S_objid,
                         targetos = child_objects[i].osnum);      
                if (! (1 & status & msg)) goto wrapup;
               }

              if (child_objects) om$dealloc(ptr = child_objects);
             }          

            OM_BLOCK_MOVE(&me->ModuleInfo,
                          me->construct_list.env_info,
                          sizeof(struct GRmd_env));
/****************************************************************************
            MSdrawtriadn (&msg, me->dest_orient, me->dest_glo_loc,me->sld,
                          prop, &me->ModuleInfo,
                          &me->active_symbology.display_attr, my_id,
                          TRUE, &me->construct_list, &me->designator_id);
****************************************************************************/
            ems$drawtriadn (
                      msg = &msg,
                    option = me->dest_orient,
                      axes = me->dest_glo_loc,
                      solid_range = me->sld,
                           props = prop,
                        moduleinfo = &me->ModuleInfo,
                        display_attr = &me->active_symbology.display_attr,
                            comobj_id = my_id,
                        construction_args = &me->construct_list,
                           massprop_id = &me->designator_id);
            if (! (1 & msg)) goto wrapup;

            ex$message (msgnumb = EMS_I_ClearStatusField);
            ME.super_cmd->state = GET_DESIGNATOR;
       break;

       default:

            *response = TERMINATE;
            return (OM_S_SUCCESS);
      }

   } while (TRUE);

wrapup:
   *response = TERMINATE;
   return(status);
 }

end implementation ECmassmanip;

