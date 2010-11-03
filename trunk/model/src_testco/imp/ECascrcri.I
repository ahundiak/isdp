/* ###################   APOGEE COMPILED   ################## */
class implementation ECascrcr;
/*
ABSTRACT


        This command object includes the following functionalities

        o  create an associative curve from a linestring
        o  curve parameter editing
           o  order
           o  spans
           o  poles
           o  smoothing factor
           o  iterative improvement
           o  knot vector
              o  uniform 
              o  half uniform
              o  not a knot
              o  from ref curve
              o  free (edit knot values)
              o  interactive (manipulate knots interactively)
           o  parameter vector
              o equidistant
              o centripedal
              o chordal
              o AFFIN_INV
              o ref curve
              o free
              o project
        o  linestring editing
           o edit/move vertex
           o insert vertex
           o delete vertex
           o undo
           o add/delete fixpoint
           o add/delete tangency in vertex
           o add/delete factors (weight)
           o add/delete curvature in vertex
        o  curve analysis
           o show distance 
           o show curvature
           o show poles
           o show knots
History
           dfl    created  04/94 except analysis 
           uwa       "       "   analysis
           scw     03/21/97   Removed FILE fp* global (causes PDM crash)

 */

#ifndef OM_DEFINE_ERRMSG
#define OM_DEFINE_ERRMSG
#endif

#define dflT1 0
#define dflT2 0
#define dflT5 0
#define dflT_tabins 0

#include "memory.h"
#include "EMS.h"
#include "OMerrordef.h"
/* igemacros replacement */

# ifndef grdpbmacros_include
# include "grdpbmacros.h" /* gr$get_active_display */
# endif
/* end of igemacros.h replacement */

/* grutildef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grutildef.h replacement */

/* grvaluedef.h replacement */

# ifndef griodef_include
# include "griodef.h"
# endif

/* end of grvaluedef.h replacement */
/*#include "grdef.h"*/
#include "igrdef.h"
#include "codef.h"
#include "msdef.h"

#include "griomacros.h" /* co$getevent */
#include "grgsmacros.h"
#include "grmacros.h"
#include "grwireframe.h"
#include "comiscmac.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "math.h"
#include "comisc.h"
#include "nddef.h"
#include "ndmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "lcmacros.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpezmac.h"
#include "coplcmac.h"
#include "dpstruct.h"
#include "OMobjectcomm.h"
#include "exmacros.h"		/* ex$putqueue() */
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_I.h"
#include "dpdef.h"
#include "dp.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMSasmacros.h"
#include "nddef.h"
#include "exdef.h"
#include "ecascrcr.h"


/*vvvvv*/
#if defined ( NT )
#if 0 /* because opp cannot handle it */
#include <windows.h>
#endif
#endif

#ifdef X11
#include <X11/Xlib.h>
#unclude <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0 /* because opp cannot handle it */
#if defined ( X11 )
#include <XFIproto_pub.h>
#elif defined ( ENV5 )
#include <FIproto_pub.h>
#elif defined ( NT )
#include <shampub.h>
#endif
#else
#include <FI.h>
#endif
#else
#include <FI.h>
#endif
/*^^^^^*/
/* structure for dynamic point function */
    struct istruct {
       struct DPele_header point_element;   /* display buffer */
       struct IGRbsp_curve *curve;
       Form *mform;
       IGRdouble *pknot;
       IGRdouble *nknot;
       IGRdouble *knot;
    }; 

extern IGRboolean BSnorvec();
extern IGRboolean BScumdist();
extern IGRdouble 	BSdotp();
extern void BScveval();
extern IGRdouble      fabs(IGRdouble);
/*extern IGRint strlen();*/
IGRint dist_process_form ();
IGRint cvra_process_form ();
IGRint spol_process_form ();
IGRint sknt_process_form ();
IGRint tool, wool;

extern OMuword 			OPP_EMScomposite_class_id;
extern OMuword 			OPP_GR3dpoint_class_id;
extern OMuword 			OPP_GR3dlineseg_class_id;
extern OMuword 			OPP_GR3dlinestr_class_id;
extern OMuword 			OPP_GA3dlinestr_class_id;
extern OMuword 			OPP_GRbspline_class_id;
extern OMuword 			OPP_GRcurve_class_id;
extern OMuword 			OPP_EMSdatpln_class_id;
extern OMuword 			OPP_EMSplane_class_id;
extern OMuword 			OPP_EMSsurface_class_id;
extern OMuword 			OPP_EMSsubbs_class_id;
extern OMuword 			OPP_GRbcsubbc_class_id;
extern OMuword                  OPP_GRlinear_class_id;
extern OMuword                  OPP_GAbspline_class_id;


from GRgraphics import 	GRlnproject, GRdisplay, GRgetrang, GRdelete, 
                       	GRgetobjinfo, GRptproject;
from GRvg import 	GRgetattr, GRdetplane, GRgeomprops, GRgetgeom,
                        GRgetprops, GRchgprops, 
                 	GRgetsize, GRconstruct, GRprojpt, EMptatpr;
from EMSsubbs import EMtoggle_polygon;
from GR3dlinestr import GRgetpolyline, GRputpolyline;
from GRlinear import    GRvtadjseg, GRdelvertex;
from GRcurve import 	EMcvoffset, GRgenabsg, GRmidpoint, GRinsvertex;
from EMSassoc import    EMget_info, EMput_info;
from NDnode   import    NDget_objects;
from ASnode   import    NDchange_connect;

IGRint Create_line_dynamics_function(
    struct DPele_header *DYinfo,
    struct EX_button    *point,
    IGRdouble *matrix,
    struct GRid **objects,
    IGRint *num_objects,
    struct DPele_header **buffers,
    IGRint *num_buffers,
    IGRchar *dummy_in1,
    IGRchar *dummy_in2,
    IGRchar *dummy_in3,
    IGRchar **dummy_out1,
    IGRchar **dummy_out2,
    IGRchar **dummy_out3)
{
 /* 
    ABSTRACT  dynamic function which feeds the mouse position point
              into a polyline structure
 */

    /* Assign new mouse position to be second point of line */
    DYinfo->geometry.polyline->points[X2] = point->x;
    DYinfo->geometry.polyline->points[Y2] = point->y;
    DYinfo->geometry.polyline->points[Z2] = point->z;

    *buffers = DYinfo;

    /* We are only drawing 1 graphic object. */
    *num_buffers = 1;

    return(TRUE);
}
IGRint Create_point_dynamics_function(
    struct istruct *infos,
    struct EX_button    *point,
    IGRdouble *matrix,
    struct GRid **objects,
    IGRint *num_objects,
    struct DPele_header **buffers,
    IGRint *num_buffers,
    IGRchar *dummy_in1,
    IGRchar *dummy_in2,
    IGRchar *dummy_in3,
    IGRchar **dummy_out1,
    IGRchar **dummy_out2,
    IGRchar **dummy_out3)
{
 /* 
    ABSTRACT  dynamic function which projects the mouse position 
              onto a curve
 */
    IGRlong msg;
    IGRpoint p, ppp;
    struct DPele_header *DYinfo;
    struct GRparms proparms;
    IGRdouble tolr = 0;
    IGRchar fmessage[MSG_F_L];
    tolr = 0.01;
    /* Assign new mouse position after projecting onto curve */
    DYinfo = &infos->point_element;
    p[X] = point->x;
    p[Y] = point->y;
    p[Z] = point->z;
    MAptbcproj(&msg, p, infos->curve, &tolr, ppp, &proparms.u);
    *infos->knot = proparms.u;
    sprintf(fmessage,"u = %1.3f", proparms.u);
    put_msg(infos->mform, M_MSG_F, fmessage);
    DYinfo->geometry.point_set->points[0] = ppp[X];
    DYinfo->geometry.point_set->points[1] = ppp[Y];
    DYinfo->geometry.point_set->points[2] = ppp[Z];

    *buffers = DYinfo;

    /* We are only drawing 1 graphic object. */
    *num_buffers = 1;

    return(TRUE);
}

IGRint Create_line_dynamics_buffer(IGRint *no_pts, struct GRevent *ev)
{
 /* 
    ABSTRACT  dynamic setup function to setup the DPele_header
              structure for a polyline;

    INPUT     
              IGRint *no_pts      -  points to no of points int
              struct GRevent *ev  -  points to one or two point events

    OUTPUT    struct GRevent *ev  -  points to a second or third point
                                     event
 */
    int sts;

    struct DPele_header line_element;   /* display buffer */
    struct IGRpolyline line;    /* line geometry */
    IGRdouble points[9];        /* coordinates of line buffer */

    /* Active color, style, weight, etc */
    struct IGRdisplay default_display;  
          
    /*
       * get default display symbology from Default Parameter Block (DPB)
       * and then go on to next command state
    */
    sts = gr$get_active_display( buffer = &default_display );

    /* Assign first point of line into dynamics buffer.  */
    points[0] = ev[0].event.button.x;
    points[1] = ev[0].event.button.y;
    points[2] = ev[0].event.button.z;
    if(*no_pts == 2) {
      points[6] = ev[2].event.button.x;
      points[7] = ev[2].event.button.y;
      points[8] = ev[2].event.button.z;
    }
    line.points = points;
    line.num_points = *no_pts+1;

    /* Put together our display buffer */
    dp$build_dis_buffer(
        buffer = &line_element,
        display_att = &default_display,
        geometry = &line,
        type = IGRPY);


    /* Start the dynamics display */
    dp$dynamics(dyn_fun = Create_line_dynamics_function,
                information = &line_element);
    return(OM_S_SUCCESS);
}

IGRint Create2_line_dynamics_buffer(IGRint *no_pts, IGRdouble *p)
{
    int sts;

    struct DPele_header line_element;   /* display buffer */
    struct IGRpolyline line;    /* line geometry */
    IGRdouble points[9];        /* coordinates of line buffer */

    /* Active color, style, weight, etc */
    struct IGRdisplay default_display;  
          
    /*
       * get default display symbology from Default Parameter Block (DPB)
       * and then go on to next command state
    */
    sts = gr$get_active_display( buffer = &default_display );

    /* Assign first point of line into dynamics buffer.  */
    points[0] = p[X];
    points[1] = p[Y];
    points[2] = p[Z];
    if(*no_pts == 2) {
      points[6] = p[6];
      points[7] = p[7];
      points[8] = p[8];
    }
    line.points = points;
    line.num_points = *no_pts+1;

    /* Put together our display buffer */
    dp$build_dis_buffer(
        buffer = &line_element,
        display_att = &default_display,
        geometry = &line,
        type = IGRPY);


    /* Start the dynamics display */
    dp$dynamics(dyn_fun = Create_line_dynamics_function,
                information = &line_element);
    p[X2] = points[X2];
    p[Y2] = points[Y2];
    p[Z2] = points[Z2];
    return(OM_S_SUCCESS);
}
IGRint Create_point_dynamics_buffer(IGRdouble *p, 
                                    struct IGRbsp_curve *curve,
                                    Form *mform,
                                    IGRint color,
                                    IGRint weight,
                                    IGRdouble *sknot)
{
  
 /* 
    ABSTRACT  dynamic setup function to setup the DPele_header
              for a dynamic point moving on a curve

    INPUT     
              IGRdouble *p         -      current point
              struct IGRbsp_curve  -      curve structure
              Form *mform          -      form where to output the
                                          current u-parameter value
              IGRint color         -      color for dynamic point
              IGRint               -      weight for dynamic point
              
              IGRdouble *sknot     -      u-parameter at current point

    OUTPUT    
              IGRdouble *sknot     -      u-parameter of moving point
                                          when accept event occurs
 */
    struct DPele_header point_element;   /* display buffer */
    struct IGRpointset point;

    int sts = 0;

    struct istruct infos;

    /* Active color, style, weight, etc */
    struct IGRdisplay default_display;  
    sts = gr$get_active_display( buffer = &default_display );
    default_display.color = (short unsigned) color;
    default_display.weight = (IGRuchar) weight;

    /* fill info structure */
    infos.curve = curve;
    infos.mform = mform;
    infos.knot = sknot;

    /*
       * get default display symbology from Default Parameter Block (DPB)
       * and then go on to next command state
    */

    /* Assign first point of line into dynamics buffer.  */

    point.num_points = 1;
    point.points = p;
    /*point_element.dis_att = &default_display;*/
    infos.point_element = point_element;
    /* Put together our display buffer */
    dp$build_dis_buffer(
        buffer = (&infos.point_element),
        display_att = &default_display,
        geometry = &point,
        type = IGRPS);


    /* Start the dynamics display */
    dp$dynamics(dyn_fun = Create_point_dynamics_function,
                information = &infos);
    return(OM_S_SUCCESS);
}

method status_disp()
{
 IGRlong status, EMmsg;
 IGRint  ret, opt_acc_process_form();

 #if dflT1
  fprintf(stderr,"\nStart : method status_disp"); 
 #endif
 status = OM_S_SUCCESS;
 EMmsg = 1;

 if(me->optform_requested)
   goto wrapup;

 ret = FIf_new (OPTFORM,"EMAsCrvCr30",opt_acc_process_form,&me->optform); 
 if ( ret ) {
  status = FALSE;
  goto wrapup;
 }
 ret = FIf_set_cmd_oid_os(me->optform,my_id,OM_Gw_current_OS); 
 if ( ret ) { 
  status = FALSE;
  goto wrapup;
 }

 ret = FIf_set_location (me->optform, opt_WLOX, opt_WLOY);
 if ( ret ) { 
   status = FALSE;
   goto wrapup;
 }
 ret = FIf_display(me->optform);
 if ( ret ) {
  status = FALSE;
  goto wrapup;
 }
 me->optform_requested = TRUE;

 wrapup:
 if ( !(1&status&EMmsg) )
   return (OM_E_ABORT);

 return (status); 
}

IGRint opt_acc_process_form ( IGRint    form_label  , 
                          IGRint    gadget_label, 
                          IGRdouble value       , 
                          Form      form_ptr    )
{
 IGRint stat_func, stat_OM;
 IGRlong msg_loc;
 GRobjid cmdobj;
 GRspacenum cmdos;
 #if dflT1
  printf("\nStart : opt_process_form"); 
 #endif
 stat_OM = OM_S_SUCCESS;
 stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
 if (stat_func)
  return ( OM_E_ABORT );
 stat_OM = om$send (msg = message ECascrcr.opt_do_form (&msg_loc,
                          form_label, gadget_label, value),
               senderid = NULL_OBJID, 
               targetid = cmdobj, 
               targetos = cmdos);
 #if dflT1
  printf("\nEnde  : opt_process_form"); 
 #endif
 if( !(stat_OM & 1) )
  return ( OM_E_ABORT );
 return ( stat_OM ); 
}



method opt_do_form ( IGRlong   *msg        ;
                     IGRint    form_label  ;
                     IGRint    gadget_label; 
                     IGRdouble value       )
{
 IGRlong sts, stat_OM;
 IGRint  ret;
 #if dflT1
  fprintf(stderr,"\nStart : method optdo_form");
 #endif
 sts = OM_S_SUCCESS;
 if ( form_label==OPTFORM )
 {
  switch ( gadget_label )
  {
   case OPTF_EXSA_B:
    #if dflT1
     fprintf(stderr,"\n case OPTF_EXSA_B");
    #endif
    me->optform_requested = FALSE;
    me->error_flag = FALSE;
    ret = FIf_erase(me->optform);
   break;
   case OPTF_QUIT_B:
    #if dflT1
     fprintf(stderr,"\n case OPTF_QUIT_B");
    #endif
    me->optform_requested = FALSE;
    me->error_flag = FALSE;
    ret = FIf_erase(me->optform);
   break;
   case OPTF_CVRA_B:
    #if dflT1
     fprintf(stderr,"\n case OPTF_CVRA_B");
    #endif
    if(!me->cvraform_requested) {
       stat_OM = om$send ( msg = message ECascrcr.cvra_disp(),targetid = my_id );
       me->cvraform_requested = TRUE;
    }
    
   break;

   case OPTF_DIST_B:
    #if dflT1
     fprintf(stderr,"\n case OPTF_DIST_B");
    #endif
    if(!me->distform_requested) {
       stat_OM = om$send ( msg = message ECascrcr.dist_disp(),targetid = my_id );
       me->distform_requested = TRUE;
    }
   break;
   case OPTF_SPOL_B:
    #if dflT1
     fprintf(stderr,"case OPTF_SPOL_B\n");
    #endif
    if(!me->spolform_requested) {
       stat_OM = om$send ( msg = message ECascrcr.spol_disp(),targetid = my_id );
       me->spolform_requested = TRUE;
    }
   break;
   case OPTF_SKNT_B:
    #if dflT1
     fprintf(stderr,"\n case OPTF_SKNT_B");
    #endif
    if(!me->skntform_requested) {
       stat_OM = om$send ( msg = message ECascrcr.sknt_disp(),targetid = my_id );
       me->skntform_requested = TRUE;
    }
   break;
   default:
    #if dflT1
     fprintf(stderr,"\n case default : method opt_do_form");
    #endif
   break;
  }
 }
 #if dflT1
  fprintf(stderr,"\nEnde  : method optdo_form");
  ;
 #endif
 return ( OM_S_SUCCESS ); 
}


method draw_curve_and_tools(IGRlong *msg)
{
 /* 
    ABSTRACT  a method which sends messages to this object to draw
              a curve and switched-on analysis tools
 */
   
   IGRlong msg_loc, stat_OM;
   enum GRdpmode 	        dpmode;

   *msg = OM_S_SUCCESS;

    if(me->mainform_requested)
       put_msg(&me->mainform,M_MSG_F,CLEAR_MSG);
    else if(me->edtform_requested)
       put_msg(&me->edtform,E_MSG_F,CLEAR_MSG);

    if(me->curve_exists) {
      stat_OM = om$send(msg = message ECascrcr.erase_analysis_tools(
                             &msg_loc),
                      targetid = my_id);
    }
    if(me->ls_is_visible) {
      dpmode = GRbd;
      stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->ls_info.located_obj.objid,
                          targetos = me->ls_info.located_obj.osnum);
    }
    if(me->curve_exists) {
      dpmode = GRbd;
      stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->curve_id.objid,
                          targetos = me->curve_id.osnum);
    }

    stat_OM = om$send(msg = message ECascrcr.create_as_curve(
                               &msg_loc),
                        targetid = my_id);

    TEST_ERROR(stat_OM,msg_loc,"create_as_curve",function_end);

    if(me->new_curve_created) {
      if (me->show_curvature) {
         stat_OM = om$send(msg = message ECascrcr.cvra_exec(
                             &msg_loc),
                      targetid = my_id);
      }
      if (me->show_distance) {
         stat_OM = om$send(msg = message ECascrcr.dist_exec(
                             &msg_loc),
                      targetid = my_id);
      }
      if (me->show_poles) {
         stat_OM = om$send(msg = message ECascrcr.spol_exec(
                             &msg_loc),
                      targetid = my_id);
      }
      if (me->show_knots) {
         stat_OM = om$send(msg = message ECascrcr.sknt_exec(
                             &msg_loc),
                      targetid = my_id);
      }
    }
 stat_OM = OM_S_SUCCESS;

 function_end:
   return(stat_OM);
}

method init (IGRint type; IGRchar *string) 
{
  /***init***/
  IGRlong       msg_loc;
  IGRchar 	errmsg[EMMAXERRMSG_LEN]; 
  IGRint 	sts;

#if dflT1
  printf("in init \n"); 
#endif
  me->to_next_linestring = FALSE;
  me->vaction = FALSE;
  me->init_on = TRUE;
  me->error_flag = FALSE;
  me->commandstate = GET_LINESTRING;
  me->command = PROCESS_SELECT;
  me->highl_pt.objid = 0;
  me->ls_is_visible = TRUE;
  me->show_curvature = FALSE;
  me->first_point = FALSE;
  me->show_distance = FALSE;
  me->show_poles = FALSE;
  me->show_knots = FALSE;
  me->fxpos = main_WLOX;
  me->fypos = main_WLOY; 
  me->nlcids = 0;
  
  /* set up color and weight for selection point */
  me->sptwt = (IGRuchar) 5.0;
  me->sptco = 2;
  sts = om$send (
        mode = OM_e_wrt_parent,
        msg = message ECascrcr.init (type, string),
        targetid = my_id);

  sts   = om$send ( msg      = message ECascrcr.set_defaults(&msg_loc),
                   targetid = my_id);

  strcpy (errmsg, "ECascrcr.init");


  me->optform_requested = FALSE;
  me->mainform_requested = FALSE;
  me->edtform_requested = FALSE;
  me->form_id = NULL_OBJID;
  me->active_form_name[0] = '\0';

  ex$message(msgnumb = EMS_I_InvkStatusFrm);

 
  return sts;
  
}

method wakeup (int pos) 
{
  /***wakeup***/

  IGRint sts = OM_S_SUCCESS;

  sts = om$send (msg= message ECascrcr.wakeup(pos),
                 mode = OM_e_wrt_parent,
                 targetid = my_id);

  ME.super_cmd->state = me->commandstate;
  me->vaction = FALSE;
 
#if dflT1
  printf("in wakeup\n"); 
#endif

  gr$get_associative_flag ( buffer = &me->is_associative );

  if (me->is_associative)
    GRdisplay_associative_button(TRUE);

  if(me->edtform_requested) 
       FIf_display(me->edtform);
  if(me->mainform_requested) 
       FIf_display(me->mainform);
  if(me->optform_requested) 
       FIf_display(me->optform);
  if(me->distform_requested) 
       FIf_display(me->distform);
  if(me->cvraform_requested) 
       FIf_display(me->cvraform);
  if(me->skntform_requested) 
       FIf_display(me->skntform);
  if(me->spolform_requested) 
       FIf_display(me->spolform);
  ex$message(msgnumb = EMS_I_InvkStatusFrm);
  ex$message (msgnumb = EM_M_AsCrCrLs);
  GRstatus_display_button(TRUE);

  return sts;  

}

method sleep(int pos) 
{
    /***sleep***/

    IGRint 	sts;
    IGRlong msg_loc;
 
#if dflT1
  printf("in sleep\n"); 
#endif

    /* clear highlighted point */    
    if(!(me->highl_pt.objid == 0)) {
      gr$delete_object(msg = &msg_loc,
                    md_env = NULL,
                    object_id = &me->highl_pt);
    }

    /*clear fields */
    ex$message( field=PROMPT_FIELD,
             msgnumb = EMS_P_00000 );
    ex$message( field = ERROR_FIELD,
             msgnumb = EMS_I_00000 );

    if (me->is_associative)
      GRdisplay_associative_button(FALSE);


    if(me->edtform_requested) 
       FIf_erase(me->edtform);
    if(me->mainform_requested) 
       FIf_erase(me->mainform);
    if(me->optform_requested) 
       FIf_erase(me->optform);
    if(me->distform_requested) 
       FIf_erase(me->distform);
    if(me->cvraform_requested) 
       FIf_erase(me->cvraform);
    if(me->skntform_requested) 
       FIf_erase(me->skntform);
    if(me->spolform_requested) 
       FIf_erase(me->spolform);

    GRstatus_display_button(FALSE);

    sts = om$send (
        mode = OM_e_wrt_parent,
        msg = message ECascrcr.sleep (pos),
        targetid = my_id);

    ME.ECelement->elem_hilit = FALSE;
    me->commandstate = ME.super_cmd->state;

    return(sts); 
}
method main_disp() 
{
  /***main_disp***/

  IGRlong 	status, EMmsg;
  /*OM_S_OBJID 	set_id = NULL_OBJID;*/
  IGRint 		ret;
  IGRint 	main_process_form();
  IGRchar fmessage[MSG_F_L];

#if dflT1
  printf("in main_disp1\n"); 
#endif

  status = OM_S_SUCCESS;
  EMmsg = 1;
 
  if(me->mainform_requested)
   return(OM_S_SUCCESS);
 
  ret = FIf_new (MAINFORM, 
                 "EMAsCrvCr10", 
                 main_process_form, 
                 &me->mainform);
  if (ret) {
      status = FALSE;
      goto wrapup;
  }

  ret = FIf_set_cmd_oid_os(me->mainform, 
                           my_id, 
                           OM_Gw_current_OS);
  if (ret) {
      status = FALSE;
      goto wrapup;
  } 

  ret = FIf_set_location (me->mainform, me->fxpos, me->fypos);
  if (ret) {
     status = FALSE;
     goto wrapup;
  }
  if (me->show_curvature)
        FIg_set_state(me->mainform, M_SHCU_B,TRUE);
  if (me->show_distance)
        FIg_set_state(me->mainform, M_SGDI_B,TRUE);
  if (me->show_poles)
        FIg_set_state(me->mainform, M_SHPO_B,TRUE);
  if (me->show_knots)
          FIg_set_state(me->mainform, M_SHKN_B,TRUE);
 
  FIg_set_value(me->mainform, M_ORDER_F, (double)me->mfp.order);
  FIg_set_value(me->mainform, M_SPANS_F, (double)me->mfp.nspans);
  FIg_set_value(me->mainform, M_POLES_F, (double)me->mfp.npole);
  FIg_set_value(me->mainform, M_SMOOTH_F,(double)me->mfp.smfac);
  FIg_set_text(me->mainform, M_PARA_F, me->mfp.para_type);
  FIg_set_text(me->mainform, M_KNOT_F, me->mfp.knot_type);
  FIg_erase(me->mainform,M_POWER_F);
  FIg_erase(me->mainform,M_FREE_T);
  FIg_erase(me->mainform,M_FREE_F);
  FIg_erase(me->mainform,M_FREE_MCF);
  FIg_erase(me->mainform,M_AFREE_B);
  FIg_erase(me->mainform,M_RFREE_B);
  FIg_erase(me->mainform,M_KKNOT_T);
  FIg_erase(me->mainform,M_KMOV_B);
  FIg_erase(me->mainform,M_KINS_B);
  FIg_erase(me->mainform,M_KDUP_B);
  FIg_erase(me->mainform,M_KDEL_B);
  FIg_erase(me->mainform,M_KACC_B);
  if(me->all_fixpts_set) {
    FIg_disable(me->mainform, M_ITERA_F);
    FIg_disable(me->mainform, M_APTOL_F);
  } else {
    FIg_enable(me->mainform, M_ITERA_F);
    FIg_enable(me->mainform, M_APTOL_F);
  }

  sprintf(fmessage,"Linestring ID = %d", me->lsname);
  ret = FIg_set_text (me->mainform, M_MSG_F, fmessage);

  ret = FIf_display(me->mainform);
  if (ret) {
   status = FALSE;
   goto wrapup;
  }

  me->mainform_requested = TRUE;

  

wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);

  return (status); 
}


IGRint main_process_form (form_label, gadget_label, value,
form_ptr) 
  int form_label, gadget_label; IGRdouble value; Form form_ptr;
{
  /***main_process_form***/

  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;


#if dflT1
  printf("in process main form\n"); 
#endif

  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECascrcr.main_do_form (&msg_loc,
                                                       form_label,
                                                       gadget_label, 
                                                       value),
                     senderid = NULL_OBJID, 
                     targetid = cmdobj, 
                     targetos = cmdos);
  if(! (stat_OM & 1)) {
    return (OM_E_ABORT); 
  }

  return (stat_OM); 

}


method main_do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value) 
{
 /***main_do_form***/

 IGRlong        stat_OM, sts, msg_loc;
 IGRint i;
 enum GRdpmode dpmode;
 IGRint  toggle=0;
 IGRushort color;
 IGRdouble  fvalue=0.0;
 IGRpoint p, mvp;
 IGRint ret;
 IGRint sel_flag, r_pos;
 IGRint row=0, drow=0, pos=0;
 struct GRsymbology s;

 sts = OM_S_SUCCESS;
 stat_OM = OM_S_SUCCESS;
 strcpy(me->errmsg,"ECascrcr.main_do_form");
 
 if (form_label == MAINFORM) {
 switch (gadget_label)
  {
   case ACCEPT_B:

    me->mainform_requested = FALSE;
    me->error_flag = FALSE;
    FIf_get_location(me->mainform,&me->fxpos, &me->fypos);
    ret = FIf_erase(me->mainform);
    if(me->optform_requested) {
     FIf_erase(me->optform);
     me->optform_requested = FALSE;
    }
    if(me->cvraform_requested) {
     FIf_erase(me->cvraform);
     me->cvraform_requested = FALSE;
    }
    if(me->distform_requested) {
     FIf_erase(me->distform);
     me->distform_requested = FALSE;
    }
    if(me->spolform_requested) {
     FIf_erase(me->spolform);
     me->spolform_requested = FALSE;
    }
    if(me->skntform_requested) {
     FIf_erase(me->skntform);
     me->skntform_requested = FALSE;
    }

    stat_OM = om$send(msg = message ECascrcr.erase_analysis_tools(
                             &msg_loc),
                      targetid = my_id);
    if(!me->ls_is_visible) {
       me->ls_is_visible = TRUE;
       gr$get_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       color = s.display_attr.color;
       s.display_attr.color = 1;
       gr$put_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       gr$display_object (object_id = &me->ls_info.located_obj,
                    md_env = NULL,
                    mode = GRbd);
    } else {
       dpmode = GRbd;
       stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->ls_info.located_obj.objid,
                          targetos = me->ls_info.located_obj.osnum);
     }
    if(me->curve_exists) {
      dpmode = GRbd;
      stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->curve_id.objid,
                          targetos = me->curve_id.osnum);
    }

    switch_to_process_state(&me->accev,PROCESS_STOP_COMMAND);
    
    break;

  case M_ANLS_B:
#if dflT1
    printf("analyze  linestring\n");
#endif

    FIg_get_state(me->mainform, M_ANLS_B, &toggle);
    stat_OM = om$send(msg = message ECascrcr.find_max_angle(
                            &msg_loc),
                      targetid = my_id);


    TEST_ERROR(stat_OM,msg_loc,"find_max_angle",function_end);

    FIg_set_state_off(me->mainform, M_ANLS_B);

    break;


   case M_NEXTLS_B:
#if dflT1
    printf("process next linestring\n");
#endif
    stat_OM = om$send(msg = message ECascrcr.erase_analysis_tools(
                             &msg_loc),
                      targetid = my_id);
    if(!me->ls_is_visible) {
       me->ls_is_visible = TRUE;
       gr$get_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       color = s.display_attr.color;
       s.display_attr.color = 1;
       gr$put_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       gr$display_object (object_id = &me->ls_info.located_obj,
                    md_env = NULL,
                    mode = GRbd);
    } else {
       dpmode = GRbd;
       stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->ls_info.located_obj.objid,
                          targetos = me->ls_info.located_obj.osnum);
     }
    if(me->curve_exists) {
      dpmode = GRbd;
      stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->curve_id.objid,
                          targetos = me->curve_id.osnum);
    }
    for(i=0;i<me->nta;i++)
      me->tat[i].nvno = 0;
    for(i=0;i<me->nfp;i++)
      me->fxt[i].nvno = 0;
    for(i=0;i<me->nfa;i++)
      me->fat[i].nvno = 0;
    me->from_curve_creation = FALSE;
    me->curve_exists = FALSE;
    me->new_curve_created = FALSE;
    me->free_type_on = FALSE;
    me->free_para_type = FALSE;
    me->free_knot_type = FALSE;
    me->all_fixpts_set = FALSE;
    me->linestring_was_modified = FALSE;
    me->reference_curve = FALSE;
    me->command = PROCESS_NEXT_LS;
    switch_to_process_state(&me->accev,PROCESS_NEXT_LS);
    
    break;


   case M_DRCV_B:                  
   /* draw curve button */
#if dflT1
    printf("draw curve button pressed \n");
#endif
    /*switch_to_process_state(&me->accev, PROCESS_DRAW_CURVE);
    break;*/

    FIg_get_state(me->mainform, M_DRCV_B, &toggle);
    stat_OM = om$send(msg = message ECascrcr.draw_curve_and_tools(
                            &msg_loc),
                      targetid = my_id);
    TEST_ERROR(stat_OM,msg_loc,"draw_curve_and_tools",function_end);

    FIg_set_state_off(me->mainform, M_DRCV_B);

  
    break;

   case M_EDLS_B:
   /* edit linestring button */
#if dflT1
    printf("edit linestring button pressed \n");
#endif
    FIf_get_location(me->mainform, &me->fxpos, &me->fypos);
    ret = om$send (msg = message ECascrcr.edt_disp(),
                   targetid = my_id);
    break;

   case M_ORDER_F:                 
   /* curve order field */
#if dflT1
    printf("curve order field \n");
#endif
    FIg_get_value(me->mainform, M_ORDER_F, &fvalue);
    me->mfp.order = (IGRint) fvalue;
    if(me->mfp.order < MIN_CV_ORDER) {
      me->mfp.order = MIN_CV_ORDER;
      FIg_set_value(me->mainform, M_ORDER_F, (IGRdouble)me->mfp.order); 
    }
    if(me->mfp.order > MAX_CV_ORDER) {
      me->mfp.order = MAX_CV_ORDER;
      FIg_set_value(me->mainform, M_ORDER_F, (IGRdouble)me->mfp.order); 
    }
    if(me->mfp.npole < me->mfp.order) {
       me->mfp.npole = me->mfp.order;
       FIg_set_value(me->mainform, M_POLES_F,(IGRdouble) me->mfp.npole);
    }
    me->mfp.nspans  = me->mfp.npole  - me->mfp.order + 1;
    FIg_set_value(me->mainform, M_SPANS_F,(IGRdouble) me->mfp.nspans); 
    /*me->nknot = me->mfp.npole + me->mfp.order;*/

    if (!strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type))) {
      strcpy(me->mfp.knot_type,UNIFORM_T);
      FIg_set_text(me->mainform,M_KNOT_F,me->mfp.knot_type);
    }
    stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                            &msg_loc),
                      targetid = my_id);

    break;

   
   case M_SPANS_F:  
   /* curve no of spans field */
#if dflT1
    printf("curve no spans field \n");
#endif
    FIg_get_value(me->mainform, M_SPANS_F, &fvalue);
    me->mfp.nspans = (IGRint) fvalue;
    me->mfp.npole = me->mfp.nspans + me->mfp.order - 1;
    fvalue = (IGRdouble) me->mfp.npole;
    FIg_set_value(me->mainform, M_POLES_F, fvalue);

    /*me->nknot = me->mfp.npole + me->mfp.order;*/
    stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                            &msg_loc),
                      targetid = my_id);


    break;

   case M_POLES_F:                 
   /* curve no of poles field */
#if dflT1
    printf("curve no of poles field \n");
#endif
    FIg_get_value(me->mainform, M_POLES_F, &fvalue);
    me->mfp.npole = (IGRint) fvalue;
    if(me->mfp.npole < me->mfp.order) {
       me->mfp.npole = me->mfp.order;
       FIg_set_value(me->mainform, M_POLES_F, (IGRdouble)me->mfp.npole);
    }
    me->mfp.nspans  = me->mfp.npole  - me->mfp.order + 1;
    fvalue = (IGRdouble) me->mfp.nspans;
    FIg_set_value(me->mainform, M_SPANS_F, fvalue); 
    
    if (!strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type))) {
      strcpy(me->mfp.knot_type,UNIFORM_T);
      FIg_set_text(me->mainform,M_KNOT_F,me->mfp.knot_type);
    }
    stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                            &msg_loc),
                      targetid = my_id);

    break;

   case M_SMOOTH_F:                
   /* curve smoothing field */
#if dflT1
    printf("smoothing field \n");
#endif
    FIg_get_value(me->mainform, M_SMOOTH_F, &fvalue);
    me->mfp.smfac = fvalue;
    break;

   case M_ITERA_F:                
   /* iterative improvement field */
#if dflT1
    printf("iterative improvement field \n");
#endif
    FIg_get_value(me->mainform, M_ITERA_F, &fvalue);
    me->mfp.opt_iter = fvalue;
    break;

   case M_APTOL_F:                
   /* approximation toleance field */
#if dflT1
    printf("approximation tolerance field \n");
#endif
    FIg_get_value(me->mainform, M_APTOL_F, &fvalue);
    break;


   case M_PARA_F:                  
   /* curve parameter field */
#if dflT1
    printf("curve parameter field \n");
#endif

    strcpy(me->old_para_type,me->mfp.para_type);
    FIg_get_text(me->mainform, M_PARA_F, me->mfp.para_type);
    if (!strncmp(me->mfp.para_type,REF_CURVE_T,strlen(me->mfp.para_type))) {
       put_msg(&me->mainform,M_MSG_F,IDENT_REF_CURVE);
       FIg_disable(me->mainform,M_ORDER_F);
       FIg_disable(me->mainform,M_SPANS_F);
       FIg_disable(me->mainform,M_POLES_F);
       FIg_disable(me->mainform,M_SMOOTH_F);
       FIg_disable(me->mainform,M_ITERA_F);
       FIg_disable(me->mainform,M_APTOL_F);
       FIg_disable(me->mainform,M_PARA_F);
       FIg_disable(me->mainform,M_KNOT_F);
       FIg_disable(me->mainform,M_EDLS_B);
       FIg_disable(me->mainform,M_DRCV_B);
       FIg_disable(me->mainform,M_ANLS_B);
       FIg_disable(me->mainform,M_NEXTLS_B);
       FIg_disable(me->mainform,M_SHCU_B);
       FIg_disable(me->mainform,M_SGDI_B);
       FIg_disable(me->mainform,M_SHPO_B);
       FIg_disable(me->mainform,M_SHKN_B);
       FIg_disable(me->mainform,M_PDIST_B);
       FIg_disable(me->mainform,M_PCURV_B);
       FIg_disable(me->mainform,M_PPOLE_B);
       FIg_disable(me->mainform,M_PKNOT_B);
       FIg_disable(me->mainform,M_LSVISIBLE_B);
       me->reference_curve = TRUE;
       ex$message (msgnumb = EMS_P_IDRCURVE);
       me->command = PROCESS_SEL_REF_CURVE_PARAS;
       /*switch_to_process_state(&me->accev, PROCESS_SEL_REF_CURVE_PARAS);*/
    } else if (strncmp(me->mfp.para_type,FREE_T,strlen(me->mfp.para_type))) {
      stat_OM = om$send(msg = message ECascrcr.comp_para_vector(
                             &msg_loc),
                      targetid = my_id);
    }
    FIfld_set_num_rows(me->mainform,M_FREE_MCF,me->npara);

    /* fill para vector in main form */ 
    for(i=0;i<me->npara;i++) {
      FIfld_set_value(me->mainform, M_FREE_MCF, i, 0, (IGRdouble)i,0);
      FIfld_set_value(me->mainform, M_FREE_MCF, i, 1, me->paras[i],0);
    }
    if (!strncmp(me->mfp.para_type,POWER_T,strlen(me->mfp.para_type))) {
       FIg_display(me->mainform,M_POWER_F);
       put_msg(&me->mainform,M_MSG_F,ENTER_POWER);
       ex$message (msgnumb = EMS_P_ENTER_POWER);
       FIg_disable(me->mainform,M_ORDER_F);
       FIg_disable(me->mainform,M_SPANS_F);
       FIg_disable(me->mainform,M_POLES_F);
       FIg_disable(me->mainform,M_SMOOTH_F);
       FIg_disable(me->mainform,M_ITERA_F);
       FIg_disable(me->mainform,M_APTOL_F);
       FIg_disable(me->mainform,M_PARA_F);
       FIg_disable(me->mainform,M_KNOT_F);
       FIg_disable(me->mainform,M_EDLS_B);
       FIg_disable(me->mainform,M_DRCV_B);
       FIg_disable(me->mainform,M_ANLS_B);
       FIg_disable(me->mainform,M_NEXTLS_B);
       FIg_disable(me->mainform,M_SHCU_B);
       FIg_disable(me->mainform,M_SGDI_B);
       FIg_disable(me->mainform,M_SHPO_B);
       FIg_disable(me->mainform,M_SHKN_B);
       FIg_disable(me->mainform,M_PDIST_B);
       FIg_disable(me->mainform,M_PCURV_B);
       FIg_disable(me->mainform,M_PPOLE_B);
       FIg_disable(me->mainform,M_PKNOT_B);
       FIg_disable(me->mainform,M_LSVISIBLE_B);
    }
    else if (!strncmp(me->mfp.para_type,FREE_T,strlen(me->mfp.para_type))) {
       me->free_para_type = TRUE;
       me->free_knot_type = FALSE;
       FIg_set_text(me->mainform, M_FREE_F, "Parameter");
       FIg_disable(me->mainform,ACCEPT_B);
       FIg_disable(me->mainform,M_ORDER_F);
       FIg_disable(me->mainform,M_SPANS_F);
       FIg_disable(me->mainform,M_POLES_F);
       FIg_disable(me->mainform,M_SMOOTH_F);
       FIg_disable(me->mainform,M_EDLS_B);
       FIg_disable(me->mainform,M_ITERA_F);
       FIg_disable(me->mainform,M_APTOL_F);
       /*FIg_disable(me->mainform,M_DRCV_B);*/
       FIg_disable(me->mainform,M_LSVISIBLE_B);
       FIg_disable(me->mainform,M_NEXTLS_B);
       FIg_disable(me->mainform,M_ANLS_B);
       FIg_erase(me->mainform,M_BORDER_L);
       FIg_erase(me->mainform,M_SHKN_B);
       FIg_erase(me->mainform,M_SHPO_B);
       FIg_erase(me->mainform,M_SHCU_B);
       FIg_erase(me->mainform,M_SGDI_B);
       FIg_erase(me->mainform,M_PARA_T);
       FIg_erase(me->mainform,M_KNOT_T);
       FIg_erase(me->mainform,M_PARA_F);
       FIg_erase(me->mainform,M_KNOT_F);
       FIg_erase(me->mainform,M_PDIST_B);
       FIg_erase(me->mainform,M_PCURV_B);
       FIg_erase(me->mainform,M_PPOLE_B);
       FIg_erase(me->mainform,M_PKNOT_B);
       FIg_display(me->mainform,M_FREE_T);
       FIg_display(me->mainform,M_FREE_F);
       FIg_display(me->mainform,M_FREE_MCF);
       FIg_display(me->mainform,M_AFREE_B);
       FIg_display(me->mainform,M_RFREE_B);

     } else {
       me->free_para_type = FALSE;
     }

    break;

   case M_KNOT_F:                  
   /* curve knot field */
#if dflT1
    printf("curve knot field \n");
#endif
    strcpy(me->old_knot_type,me->mfp.knot_type);
    strcpy(me->mfp.knot_type,"            ");
    FIg_get_text(me->mainform, M_KNOT_F, me->mfp.knot_type);
    if (!strncmp(me->mfp.knot_type,INTERACTIVE_T,strlen(me->mfp.knot_type))) {
      if(!me->curve_exists) {
        put_msg(&me->mainform,M_MSG_F,NO_CURVE_EXISTS);
        stat_OM = WARN;
        *msg = INFO;
        goto function_end;
      }
    }
    if (!strncmp(me->mfp.knot_type,REF_CURVE_T,strlen(me->mfp.knot_type))) {
       put_msg(&me->mainform,M_MSG_F,IDENT_REF_CURVE);
       ex$message (msgnumb = EMS_P_IDRCURVE);
       FIg_disable(me->mainform,M_ORDER_F);
       FIg_disable(me->mainform,M_SPANS_F);
       FIg_disable(me->mainform,M_POLES_F);
       FIg_disable(me->mainform,M_SMOOTH_F);
       FIg_disable(me->mainform,M_ITERA_F);
       FIg_disable(me->mainform,M_APTOL_F);
       FIg_disable(me->mainform,M_PARA_F);
       FIg_disable(me->mainform,M_KNOT_F);
       FIg_disable(me->mainform,M_EDLS_B);
       FIg_disable(me->mainform,M_DRCV_B);
       FIg_disable(me->mainform,M_NEXTLS_B);
       FIg_disable(me->mainform,M_ANLS_B);
       FIg_disable(me->mainform,M_SHCU_B);
       FIg_disable(me->mainform,M_SGDI_B);
       FIg_disable(me->mainform,M_SHPO_B);
       FIg_disable(me->mainform,M_SHKN_B);
       FIg_disable(me->mainform,M_PDIST_B);
       FIg_disable(me->mainform,M_PCURV_B);
       FIg_disable(me->mainform,M_PPOLE_B);
       FIg_disable(me->mainform,M_PKNOT_B);
       FIg_disable(me->mainform,M_LSVISIBLE_B);
       me->reference_curve = TRUE;
       /*switch_to_process_state(&me->accev, PROCESS_SEL_REF_CURVE_KNOTS);*/
       me->command = PROCESS_SEL_REF_CURVE_KNOTS;
       goto function_end;
    } else if (strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type))
       && strncmp(me->mfp.knot_type,INTERACTIVE_T,
              strlen(me->mfp.knot_type))) { 
      stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                             &msg_loc),
                      targetid = my_id);
    }
    FIfld_set_num_rows(me->mainform,M_FREE_MCF,me->nknot);

    /* fill knot vector in main form */ 
    for(i=0;i<me->nknot;i++) {
      FIfld_set_value(me->mainform, M_FREE_MCF, i , 0, (IGRdouble)i,0);
      FIfld_set_value(me->mainform, M_FREE_MCF, i, 1, me->knots[i],0);
    }
    if (!strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type))
       || !strncmp(me->mfp.knot_type,INTERACTIVE_T,
              strlen(me->mfp.knot_type))) { 
       FIg_set_text(me->mainform, M_FREE_F, "Knots");
       FIg_disable(me->mainform,ACCEPT_B);
       FIg_disable(me->mainform,M_ORDER_F);
       FIg_disable(me->mainform,M_SPANS_F);
       FIg_disable(me->mainform,M_POLES_F);
       FIg_disable(me->mainform,M_SMOOTH_F);
       FIg_disable(me->mainform,M_EDLS_B);
       FIg_disable(me->mainform,M_ITERA_F);
       FIg_disable(me->mainform,M_APTOL_F);
       FIg_disable(me->mainform,M_ANLS_B);
       FIg_disable(me->mainform,M_NEXTLS_B);
       FIg_disable(me->mainform,M_LSVISIBLE_B);
       FIg_erase(me->mainform,M_SHKN_B);
       FIg_erase(me->mainform,M_SHPO_B);
       FIg_erase(me->mainform,M_SHCU_B);
       FIg_erase(me->mainform,M_SGDI_B);
       FIg_erase(me->mainform,M_PARA_T);
       FIg_erase(me->mainform,M_KNOT_T);
       FIg_erase(me->mainform,M_PARA_F);
       FIg_erase(me->mainform,M_KNOT_F);
       FIg_erase(me->mainform,M_PDIST_B);
       FIg_erase(me->mainform,M_PCURV_B);
       FIg_erase(me->mainform,M_PPOLE_B);
       FIg_erase(me->mainform,M_PKNOT_B);
    }
    if (!strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type))) {
       me->free_knot_type = TRUE;
       me->free_para_type = FALSE;
       FIg_erase(me->mainform,M_BORDER_L);
       FIg_display(me->mainform,M_FREE_T);
       FIg_display(me->mainform,M_FREE_F);
       FIg_display(me->mainform,M_FREE_MCF);
       FIg_display(me->mainform,M_AFREE_B);
       FIg_display(me->mainform,M_RFREE_B);
     } else {
       me->free_knot_type = FALSE;
     }

    if (!strncmp(me->mfp.knot_type,INTERACTIVE_T,strlen(me->mfp.knot_type))) {
       FIg_erase(me->mainform,M_SHOW_T);
       FIg_disable(me->mainform,M_DRCV_B);
       FIg_display(me->mainform,M_KKNOT_T);
       FIg_display(me->mainform,M_KMOV_B);
       FIg_display(me->mainform,M_KINS_B);
       FIg_display(me->mainform,M_KDUP_B);
       FIg_display(me->mainform,M_KDEL_B);
       FIg_display(me->mainform,M_KACC_B);
       me->inter_knot_manip = TRUE;
       stat_OM = om$send (msg = message ECascrcr.draw_knot(
                                &msg_loc,
                                TRUE),
                          targetid = my_id);
    }

    break;

   case M_FREE_MCF:                  
   /* mcf free field */
#if dflT1
    printf("mcf free field \n");
#endif
    me->form_event_handling = TRUE;
    me->XXXXX = 7000;
    FIfld_get_active_row(me->mainform, M_FREE_MCF, &row, &pos);
    if(me->free_para_type) {
      FIfld_get_value(me->mainform, M_FREE_MCF, row, 1, 
                       &me->paras[row],&sel_flag,&r_pos);
      me->edt_row = row;
      me->edt_pos = pos;

      p[X] = me->vxt[row].xp;
      p[Y] = me->vxt[row].yp;
      p[Z] = me->vxt[row].zp;
   
      me->form_event_handling = TRUE;
      stat_OM = om$send(msg = message ECascrcr.select_ls_point(
                               &msg_loc,
                               p,
                               &drow,
                               &pos),
                        targetid = my_id);
    } else if(me->free_knot_type) {
       FIfld_get_value(me->mainform, M_FREE_MCF, row, 1, 
                       &me->knots[row],&sel_flag,&r_pos);

       stat_OM = om$send(msg = message ECascrcr.select_cv_point(
                               &msg_loc,
                               p,
                               &me->knots[row],
                               mvp,
                               &i),
                         targetid = my_id);
    }

 

    break;

   case M_RFREE_B:
   /* reject free button */
#if dflT1
    printf(" reject free button \n");
#endif
       FIg_erase(me->mainform,M_FREE_T);
       FIg_erase(me->mainform,M_FREE_F);
       FIg_erase(me->mainform,M_FREE_MCF);
       FIg_erase(me->mainform,M_AFREE_B);
       FIg_erase(me->mainform,M_RFREE_B);
       FIg_display(me->mainform,M_BORDER_L);
       FIg_display(me->mainform,M_SHKN_B);
       FIg_display(me->mainform,M_SHPO_B);
       FIg_display(me->mainform,M_SHCU_B);
       FIg_display(me->mainform,M_SGDI_B);
       FIg_display(me->mainform,M_PARA_T);
       FIg_display(me->mainform,M_KNOT_T);
       FIg_display(me->mainform,M_PARA_F);
       FIg_display(me->mainform,M_KNOT_F);
       FIg_display(me->mainform,M_PDIST_B);
       FIg_display(me->mainform,M_PCURV_B);
       FIg_display(me->mainform,M_PPOLE_B);
       FIg_display(me->mainform,M_PKNOT_B);
       FIg_display(me->mainform,M_MSG_F);
       FIg_enable(me->mainform,ACCEPT_B);
       FIg_enable(me->mainform,M_ORDER_F);
       FIg_enable(me->mainform,M_SPANS_F);
       FIg_enable(me->mainform,M_POLES_F);
       FIg_enable(me->mainform,M_SMOOTH_F);
       FIg_enable(me->mainform,M_EDLS_B);
       if(me->all_fixpts_set) {
         FIg_disable(me->mainform, M_ITERA_F);
         FIg_disable(me->mainform, M_APTOL_F);
       } else {
         FIg_enable(me->mainform, M_ITERA_F);
         FIg_enable(me->mainform, M_APTOL_F);
       }
       FIg_enable(me->mainform,M_DRCV_B);
       FIg_enable(me->mainform,M_NEXTLS_B);
       FIg_enable(me->mainform,M_ANLS_B);
       FIg_enable(me->mainform,M_LSVISIBLE_B);
       put_msg(&me->mainform, E_MSG_F, CLEAR_MSG);

       break;

   case M_AFREE_B:
   /* accept free button */
#if dflT1
    printf(" accept free button \n");
#endif
       FIg_erase(me->mainform,M_FREE_T);
       FIg_erase(me->mainform,M_FREE_F);
       FIg_erase(me->mainform,M_FREE_MCF);
       FIg_erase(me->mainform,M_AFREE_B);
       FIg_erase(me->mainform,M_RFREE_B);
       FIg_display(me->mainform,M_BORDER_L);
       FIg_display(me->mainform,M_SHKN_B);
       FIg_display(me->mainform,M_SHPO_B);
       FIg_display(me->mainform,M_SHCU_B);
       FIg_display(me->mainform,M_SGDI_B);
       FIg_display(me->mainform,M_PARA_T);
       FIg_display(me->mainform,M_KNOT_T);
       FIg_display(me->mainform,M_PARA_F);
       FIg_display(me->mainform,M_KNOT_F);
       FIg_display(me->mainform,M_PDIST_B);
       FIg_display(me->mainform,M_PCURV_B);
       FIg_display(me->mainform,M_PPOLE_B);
       FIg_display(me->mainform,M_PKNOT_B);
       FIg_display(me->mainform,M_MSG_F);
       FIg_enable(me->mainform,ACCEPT_B);
       FIg_enable(me->mainform,M_ORDER_F);
       FIg_enable(me->mainform,M_SPANS_F);
       FIg_enable(me->mainform,M_POLES_F);
       FIg_enable(me->mainform,M_SMOOTH_F);
       FIg_enable(me->mainform,M_EDLS_B);
       if(me->all_fixpts_set) {
         FIg_disable(me->mainform, M_ITERA_F);
         FIg_disable(me->mainform, M_APTOL_F);
       } else {
         FIg_enable(me->mainform, M_ITERA_F);
         FIg_enable(me->mainform, M_APTOL_F);
       }
       FIg_enable(me->mainform,M_DRCV_B);
       FIg_enable(me->mainform,M_NEXTLS_B);
       FIg_enable(me->mainform,M_ANLS_B);
       FIg_enable(me->mainform,M_LSVISIBLE_B);

       if(me->free_para_type) {
          for(i=0;i<me->npara;i++) {
            FIfld_get_value(me->mainform, M_FREE_MCF, i, 1, 
                            &me->paras[i],&sel_flag,&r_pos);
          }
          me->free_para_type = FALSE;
       } else if(me->free_knot_type) {
          for(i=0;i<me->nknot;i++) {
            FIfld_get_value(me->mainform, M_FREE_MCF, i, 1, 
                            &me->knots[i],&sel_flag,&r_pos);
          }
          me->free_knot_type = FALSE; 
       }
    put_msg(&me->mainform, E_MSG_F, CLEAR_MSG);
    break;

   case M_POWER_F:                  
   /* curve power field */
#if dflT1
    printf("curve power field \n");
#endif
    FIg_get_value(me->mainform, M_POWER_F, &me->mfp.power);
    me->XXXXX = 1717; 
    stat_OM = om$send(msg = message ECascrcr.comp_para_vector(
                             &msg_loc),
                      targetid = my_id);
    
    for(i=0;i<me->nvx;i++) {
      FIfld_set_value(me->mainform, M_FREE_MCF, i, 0, i,0);
      FIfld_set_value(me->mainform, M_FREE_MCF, i, 1, me->paras[i],0);
    }

    FIg_erase(me->mainform,M_POWER_F);
    FIg_enable(me->mainform,M_ORDER_F);
    FIg_enable(me->mainform,M_SPANS_F);
    FIg_enable(me->mainform,M_POLES_F);
    FIg_enable(me->mainform,M_SMOOTH_F);
    FIg_enable(me->mainform,M_PARA_F);
    FIg_enable(me->mainform,M_KNOT_F);
    FIg_enable(me->mainform,M_EDLS_B);
    FIg_enable(me->mainform,M_DRCV_B);
    FIg_enable(me->mainform,M_ANLS_B);
    FIg_enable(me->mainform,M_NEXTLS_B);
    FIg_enable(me->mainform,M_SHCU_B);
    FIg_enable(me->mainform,M_SGDI_B);
    FIg_enable(me->mainform,M_SHPO_B);
    FIg_enable(me->mainform,M_SHKN_B);
    FIg_enable(me->mainform,M_PDIST_B);
    if(me->all_fixpts_set) {
      FIg_disable(me->mainform, M_ITERA_F);
      FIg_disable(me->mainform, M_APTOL_F);
    } else {
      FIg_enable(me->mainform, M_ITERA_F);
      FIg_enable(me->mainform, M_APTOL_F);
    }
    FIg_enable(me->mainform,M_PCURV_B);
    FIg_enable(me->mainform,M_PPOLE_B);
    FIg_enable(me->mainform,M_PKNOT_B);
    FIg_enable(me->mainform,M_LSVISIBLE_B);
    put_msg(&me->mainform,M_MSG_F,CLEAR_MSG);
    
    break;



   case M_KMOV_B:
   /* move knot button */
#if dflT1
    printf("move knot button \n");
#endif
   FIg_get_state(me->mainform, M_KMOV_B, &toggle);
   if(toggle) {
     put_msg(&me->mainform,M_MSG_F,SELECT_KNOT_TOMOV);
     FIg_set_state_off(me->mainform, M_KDUP_B);
     FIg_set_state_off(me->mainform,M_KINS_B);
     FIg_set_state_off(me->mainform,M_KDEL_B);
     me->command = PROCESS_MOVE_KNOT;
   } else {
      FIg_set_state_off(me->mainform,M_KMOV_B);
      me->command = PROCESS_SELECT;
   }
   break;

   case M_KDUP_B:
   /* duplicate knot button */
#if dflT1
    printf("duplicate knot button \n");
#endif
   FIg_get_state(me->mainform, M_KDUP_B, &toggle);
   if(toggle) {
     put_msg(&me->mainform,M_MSG_F,SELECT_KNOT_TODUP);
     FIg_set_state_off(me->mainform, M_KMOV_B);
     FIg_set_state_off(me->mainform,M_KINS_B);
     FIg_set_state_off(me->mainform,M_KDEL_B);
     me->command = PROCESS_DUPL_KNOT;
   } else {
      FIg_set_state_off(me->mainform, M_KDUP_B);
      me->command = PROCESS_SELECT;
   }
   break;

   case M_KINS_B:
   /* insert knot button */
#if dflT1
    printf("insert knot button \n");
#endif
   FIg_get_state(me->mainform, M_KINS_B, &toggle);
   if(toggle) {
     put_msg(&me->mainform,M_MSG_F,SELECT_POINT_TOINS);
     FIg_set_state_off(me->mainform, M_KMOV_B);
     FIg_set_state_off(me->mainform,M_KDUP_B);
     FIg_set_state_off(me->mainform,M_KDEL_B);
     me->command = PROCESS_INS_KNOT;
   } else {
      FIg_set_state_off(me->mainform, M_KINS_B);
      me->command = PROCESS_SELECT;
   }
   break;

   case M_KDEL_B:
   /* delete knot button */
#if dflT1
    printf("delete knot button \n");
#endif
   FIg_get_state(me->mainform, M_KDEL_B, &toggle);
   if(toggle) {
     put_msg(&me->mainform,M_MSG_F,SELECT_KNOT_TODEL);
     FIg_set_state_off(me->mainform, M_KMOV_B);
     FIg_set_state_off(me->mainform,M_KINS_B);
     FIg_set_state_off(me->mainform,M_KDUP_B);
     me->command = PROCESS_DEL_KNOT;
   } else {
      FIg_set_state_off(me->mainform, M_KDEL_B);
      me->command = PROCESS_SELECT;
   }
   break;

   case M_KACC_B:
   /*  knot accept button */
#if dflT1
    printf("knot accept button \n");
#endif
    FIg_set_text(me->mainform, M_KNOT_F, FREE_T);
    strcpy(me->mfp.knot_type,FREE_T);
    stat_OM = om$send (msg = message ECascrcr.draw_knot(
                                &msg_loc,
                                FALSE),
                          targetid = my_id);
    FIg_set_state_off(me->mainform,M_KMOV_B);
    FIg_set_state_off(me->mainform,M_KINS_B);
    FIg_set_state_off(me->mainform,M_KDUP_B);
    FIg_set_state_off(me->mainform,M_KDEL_B);
    FIg_erase(me->mainform,M_KKNOT_T);
    FIg_erase(me->mainform,M_KMOV_B);
    FIg_erase(me->mainform,M_KINS_B);
    FIg_erase(me->mainform,M_KDEL_B);
    FIg_erase(me->mainform,M_KDUP_B);
    FIg_erase(me->mainform,M_KACC_B);
    FIg_display(me->mainform,M_BORDER_L);
    FIg_display(me->mainform,M_SHOW_T);
    FIg_display(me->mainform,M_SHKN_B);
    FIg_display(me->mainform,M_SHPO_B);
    FIg_display(me->mainform,M_SHCU_B);
    FIg_display(me->mainform,M_SGDI_B);
    FIg_display(me->mainform,M_PARA_T);
    FIg_display(me->mainform,M_KNOT_T);
    FIg_display(me->mainform,M_PARA_F);
    FIg_display(me->mainform,M_KNOT_F);
    FIg_display(me->mainform,M_PDIST_B);
    FIg_display(me->mainform,M_PCURV_B);
    FIg_display(me->mainform,M_PPOLE_B);
    FIg_display(me->mainform,M_PKNOT_B);
    FIg_display(me->mainform,M_MSG_F);
    FIg_enable(me->mainform,ACCEPT_B);
    FIg_enable(me->mainform,M_ORDER_F);
    FIg_enable(me->mainform,M_SPANS_F);
    FIg_enable(me->mainform,M_POLES_F);
    FIg_enable(me->mainform,M_SMOOTH_F);
    FIg_enable(me->mainform,M_EDLS_B);
    if(me->all_fixpts_set) {
      FIg_disable(me->mainform, M_ITERA_F);
      FIg_disable(me->mainform, M_APTOL_F);
    } else {
      FIg_enable(me->mainform, M_ITERA_F);
      FIg_enable(me->mainform, M_APTOL_F);
    }
    FIg_enable(me->mainform,M_DRCV_B);
    FIg_enable(me->mainform,M_NEXTLS_B);
    FIg_enable(me->mainform,M_ANLS_B);
    FIg_enable(me->mainform,M_LSVISIBLE_B);
    me->inter_knot_manip = FALSE;
    me->command = PROCESS_SELECT;
    put_msg(&me->mainform, E_MSG_F, CLEAR_MSG);
    break;


   case M_SHCU_B:                  
   /* show curvature button */
#if dflT1
    printf("show curvature button \n");
#endif
    FIg_get_state(me->mainform, M_SHCU_B, &toggle);
    if(toggle) 
      me->show_curvature = TRUE;
    else
      me->show_curvature = FALSE;
    
    break;

   case M_SGDI_B:                  
   /* show distance button */
#if dflT1
    printf("show distance button \n");
#endif
    FIg_get_state(me->mainform, M_SGDI_B, &toggle);
    if(toggle) 
      me->show_distance = TRUE;
    else
      me->show_distance = FALSE;
    break;

   case M_SHPO_B:                  
   /* show poles button */
#if dflT1
    printf("show poles button \n");
#endif
    FIg_get_state(me->mainform, M_SHPO_B, &toggle);
    if(toggle) 
      me->show_poles = TRUE;
    else
      me->show_poles = FALSE;
    break;


   case M_PDIST_B:
   /* show distance options form */
#if dflT1
    printf("show distance options form \n");
#endif
    if(!me->distform_requested) {
      stat_OM = om$send(msg = message ECascrcr.dist_disp(),
                      targetid = my_id);
      FIg_set_state(me->mainform, M_SGDI_B, TRUE);
      me->distform_requested = TRUE;
      me->show_distance = TRUE;
    }
    break;


   case M_PCURV_B:
   /* show curvature options form */
#if dflT1
    printf("show curvature options form \n");
#endif
    if(!me->cvraform_requested) {
      stat_OM = om$send(msg = message ECascrcr.cvra_disp(),
                      targetid = my_id);
      FIg_set_state(me->mainform, M_SHCU_B, TRUE);
      me->show_curvature = TRUE;
      me->cvraform_requested = TRUE;
    }
    break;

   case M_PPOLE_B:
   /* show poles options form */
#if dflT1
    printf("show poles options form \n");
#endif
    if(!me->spolform_requested) {
      stat_OM = om$send(msg = message ECascrcr.spol_disp(),
                      targetid = my_id);
      FIg_set_state(me->mainform, M_SHPO_B, TRUE);
      me->show_poles = TRUE;
      me->spolform_requested = TRUE;
    }
    break;


   case M_PKNOT_B:
   /* show knots options form */
#if dflT1
    printf("show knots options form \n");
#endif
    if(!me->skntform_requested) {
      stat_OM = om$send(msg = message ECascrcr.sknt_disp(),
                      targetid = my_id);
      FIg_set_state(me->mainform, M_SHKN_B, TRUE);
      me->show_knots = TRUE;
      me->skntform_requested = TRUE;
    }
    break;


   case M_SHKN_B:                  
   /* show knots button */
#if dflT1
    printf("show knots button \n");
#endif
    FIg_get_state(me->mainform, M_SHKN_B, &toggle);
    if(toggle) 
      me->show_knots = TRUE;
    else
      me->show_knots = FALSE;
    break;

  case M_LSVISIBLE_B:
   /* show visibility button */
#if dflT1
    printf("show visibility button \n");
#endif
      dpmode = GRbdhe;
      stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->ls_info.located_obj.objid,
                          targetos = me->ls_info.located_obj.osnum);
    if(me->ls_is_visible) {
       me->ls_is_visible = FALSE;
       gr$get_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       color = s.display_attr.color;
       s.display_attr.color = 0;
       gr$put_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       gr$display_object (object_id = &me->ls_info.located_obj,
                    md_env = NULL,
                    mode = GRbd);
    } else {
       me->ls_is_visible = TRUE;       
       gr$get_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       color = s.display_attr.color;
       s.display_attr.color = 1;
       gr$put_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       gr$display_object (object_id = &me->ls_info.located_obj,
                    md_env = NULL,
                    mode = GRbd);
    }
    if(me->curve_exists) {
      dpmode = GRbd;
      stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->curve_id.objid,
                          targetos = me->curve_id.osnum);
    }
    break;


   default:

    break;


 } /* end switch (gadget_label) */ }

 function_end:
   return(stat_OM); 

}

method edt_disp() 
{
  /***edt_disp***/
  IGRlong 	status, EMmsg, msg_loc;
  /*OM_S_OBJID 	set_id = NULL_OBJID;*/
  IGRint 		ret;
  IGRint 	edt_process_form();
  

#if dflT1
  printf("in edt_disp1\n"); 
#endif

  status = OM_S_SUCCESS;
  EMmsg = 1;
  
  ret = FIf_erase(me->mainform);
  me->mainform_requested = FALSE;

  ret = FIf_new (EDTFORM, 
                 "EMAsCrvCr20", 
                 edt_process_form, 
                 &me->edtform);
  if (ret) {
      status = FALSE;
      goto wrapup;
  }

  FIg_disable(me->edtform, E_MCOL_F);

  ret = FIf_set_cmd_oid_os(me->edtform, 
                           my_id, 
                           OM_Gw_current_OS);
  if (ret) {
      status = FALSE;
      goto wrapup;
  } 

  if (!me->edtform_requested) {
    ret = FIf_set_location (me->edtform, me->fxpos, me->fypos);
    if (ret) {
       status = FALSE;
      goto wrapup;
    }
    /* set max no of rows  */
    /*ret = FIfld_set_num_rows(me->edtform, E_MCOL_F, 0);
    ret = FIfld_set_num_rows(me->edtform, E_VERTEX_F, 0);*/
    if (ret) {
       status = FALSE;
      goto wrapup;
    }
    /* fill the visible rows with vertex of linestring */
    ret = om$send (msg = message ECascrcr.fill_form_tbl(
                          &msg_loc),
                   targetid = my_id);

    if(!(1&ret&msg_loc)) {
       status = FALSE;
       goto wrapup;
    }

    ret = FIf_display(me->edtform);
    if (ret) {
     status = FALSE;
     goto wrapup;
    }

    me->edtform_requested = TRUE;

  }

wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);

  return (status); 
}


IGRint edt_process_form (form_label, gadget_label, value,
form_ptr) 
  int form_label, gadget_label; IGRdouble value; Form form_ptr;
{
  /***edt_process_form***/
  IGRint stat_func;
  IGRlong msg_loc, stat_OM;
  GRobjid cmdobj;
  GRspacenum cmdos;


#if dflT1
  printf("in process table form\n"); 
#endif

  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECascrcr.edt_do_form (&msg_loc,
                                                       form_label,
                                                       gadget_label, 
                                                       value),
                     senderid = NULL_OBJID, 
                     targetid = cmdobj, 
                     targetos = cmdos);
  if(! (stat_OM & 1))
    return (OM_E_ABORT); 

  return (stat_OM); 

}


method edt_do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value) 
{
 /***edt_do_form***/

 IGRint toggle;
 IGRlong stat_OM, rc;
 IGRlong        sts, msg_loc;
 IGRint ret;
 enum GRdpmode  dpmode;
 IGRint i=0, j=0, row=0, pos=0, old_row=0, col=0,  pos2=0, sel=0, dummy=0;
 IGRint drow=0;
 IGRushort color;
 IGRdouble  fvalue=0.0;
 IGRdouble  p[3];
 IGRpoint   pt, pnt1, pnt[2];
 IGRchar fmessage[MSG_F_L];
 /*IGRint                response2;
 IGRchar               response_data2[70];*/
 IGRvector  w;
 struct GRsymbology s;


 sts = OM_S_SUCCESS;
 stat_OM = OM_S_SUCCESS;
 me->form_event_handling = TRUE;

 ex$message (msgnumb = EMS_I_00000);
 if (form_label == EDTFORM) {
 switch (gadget_label)
  {
   case ACCEPT_B:

    me->edtform_requested = FALSE;
    me->error_flag = FALSE;
   
    FIf_get_location(me->edtform,&me->fxpos, &me->fypos);
    ret = FIf_erase(me->edtform);
    if(me->all_fixpts_set) {
      FIg_disable(me->mainform, M_ITERA_F);
      FIg_disable(me->mainform, M_APTOL_F);
    } else {
      FIg_enable(me->mainform, M_ITERA_F);
      FIg_enable(me->mainform, M_APTOL_F);
    }
    FIg_erase(me->mainform,M_POWER_F);
    FIg_erase(me->mainform,M_FREE_T);
    FIg_erase(me->mainform,M_FREE_F);
    FIg_erase(me->mainform,M_FREE_MCF);
    FIg_erase(me->mainform,M_AFREE_B);
    FIg_erase(me->mainform,M_RFREE_B);
    FIg_erase(me->mainform,M_KKNOT_T);
    FIg_erase(me->mainform,M_KMOV_B);
    FIg_erase(me->mainform,M_KINS_B);
    FIg_erase(me->mainform,M_KDUP_B);
    FIg_erase(me->mainform,M_KDEL_B);
    FIg_erase(me->mainform,M_KACC_B);
    ret = om$send (msg = message ECascrcr.main_disp(),
                   targetid = my_id);

    break;

   case E_UNDO_B:
   /* undo button */
#if dflT1
    printf("undo button pressed \n");
#endif
    FIg_get_state(me->edtform, E_UNDO_B, &toggle);
    if(toggle) {
      set_gadget_active_inactive(&me->edtform, 15,
          E_MCOL_F, OFF, E_INS_B, OFF, E_AFIX_B, OFF,
          E_TA1_B, OFF, E_EDT_B, OFF, E_DEL_B, OFF,
          E_CURV_B, OFF, E_SHFIX_B, OFF, E_MOV_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_SIFIX_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);


      stat_OM = om$send (msg = message ECascrcr.undo_last_edit(&msg_loc),
                          targetid = my_id);

      set_gadget_active_inactive(&me->edtform, 15,
          E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
          E_TA1_B, ON, E_EDT_B, ON, E_DEL_B, ON,
          E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
          E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);


      FIg_set_state_off(me->edtform, E_UNDO_B);
    }                            

    me->command = PROCESS_SELECT;
    break;


  case E_LSVISIBLE_B:
   /* show visibility button */
#if dflT1
    printf("show visibility button \n");
#endif
      dpmode = GRbdhe;
      stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->ls_info.located_obj.objid,
                          targetos = me->ls_info.located_obj.osnum);
    if(me->ls_is_visible) {
       me->ls_is_visible = FALSE;
       gr$get_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       color = s.display_attr.color;
       s.display_attr.color = 0;
       gr$put_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       gr$display_object (object_id = &me->ls_info.located_obj,
                    md_env = NULL,
                    mode = GRbd);
    } else {
       me->ls_is_visible = TRUE;       
       gr$get_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       color = s.display_attr.color;
       s.display_attr.color = 1;
       gr$put_symbology (object_id = &me->ls_info.located_obj,
                   symb = &s);
       gr$display_object (object_id = &me->ls_info.located_obj,
                    md_env = NULL,
                    mode = GRbd);
    }
    if(me->curve_exists) {
      dpmode = GRbd;
      stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->curve_id.objid,
                          targetos = me->curve_id.osnum);
    }
    break;


   case E_EDT_B:                  
   /* edit vertex button */
#if dflT1
    printf("edit vertex button pressed \n");
#endif
    FIg_get_state(me->edtform, E_EDT_B, &toggle);
    if(toggle && me->command != PROCESS_EDIT_VERTEX) {
      put_msg(&me->edtform, E_MSG_F, SEL_ROW);
      ex$message (msgnumb = EMS_P_SEL_ROW);
      set_gadget_active_inactive(&me->edtform, 15,
          E_MCOL_F, ON, E_INS_B, OFF, E_AFIX_B, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF, E_DEL_B, OFF,
          E_CURV_B, OFF, E_SHFIX_B, OFF, E_MOV_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_SIFIX_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);
      me->command = PROCESS_EDIT_VERTEX;
    };
    if (!toggle) {
      put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
      ex$message (msgnumb = EMS_I_00000);
      set_gadget_active_inactive(&me->edtform, 15,
          E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
          E_TA1_B, ON, E_UNDO_B, ON, E_DEL_B, ON,
          E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
          E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);

      stat_OM = om$send (msg = message ECascrcr.process_edit(
                                &msg_loc),
                         targetid = my_id);

      FIg_set_state_off(me->edtform, E_EDT_B);
      me->command = PROCESS_SELECT;
    }                            

    break;


   case E_MOV_B:                  
   /* move vertex button */
#if dflT1
    printf("move vertex button pressed \n");
#endif
    FIg_get_state(me->edtform, E_MOV_B, &toggle);
    if(toggle && me->command != PROCESS_MOVE_VERTEX) {
      put_msg(&me->edtform, E_MSG_F, SEL_LS);
      ex$message (msgnumb = EMS_P_SEL_LS);
      set_gadget_active_inactive(&me->edtform, 16,
          E_MCOL_F, OFF , E_INS_B, OFF, E_AFIX_B, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF, E_DEL_B, OFF, E_VERTEX_F, OFF,
          E_CURV_B, OFF, E_SHFIX_B, OFF, E_EDT_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_SIFIX_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF);
      me->command = PROCESS_MOVE_VERTEX;
    };
    if (!toggle) {
      put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
      ex$message (msgnumb = EMS_I_00000);
      set_gadget_active_inactive(&me->edtform, 16,
          E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
          E_TA1_B, ON, E_UNDO_B, ON, E_DEL_B, ON, E_VERTEX_F, ON,
          E_CURV_B, ON, E_SHFIX_B, ON, E_EDT_B, ON,
           E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON);

      FIg_set_state_off(me->edtform, E_MOV_B);
      me->command = PROCESS_SELECT;
    }                            

    break;

   case E_VERTEX_F:                  
   /* select vertex field */
#if dflT1
    printf("select vertex field \n");
#endif
      FIfld_get_active_row(me->edtform, E_VERTEX_F, &row, &pos);
      me->edt_row = row;
      if (row == 0)
        me->first_point = TRUE;
      else
        me->first_point = FALSE;
      me->edt_pos = pos;
#if dflT1
      printf("multi col field edited \n");
      printf("row = %d pos = %d\n", row, pos);
#endif
      put_msg(&me->edtform, E_MSG_F, SEL_ROW);
      ex$message (msgnumb = EMS_P_SEL_ROW);

      FIfld_set_active_row(me->edtform, E_MCOL_F, row, 0);
      FIfld_set_active_row(me->edtform, E_VERTEX_F, row, 0);

      FIfld_get_value(me->edtform, E_MCOL_F, row, XC, &p[X],&sel,&pos2);
      FIfld_get_value(me->edtform, E_MCOL_F, row, YC, &p[Y],&sel,&pos2);
      FIfld_get_value(me->edtform, E_MCOL_F, row, ZC, &p[Z],&sel,&pos2);
   
   
      stat_OM = om$send(msg = message ECascrcr.select_ls_point(
                               &msg_loc,
                               p,
                               &drow,
                               &pos),
                        targetid = my_id);
 
      switch(me->command) {
#if dflT_tabins
        case PROCESS_INSERT_VERTEX:
          if(me->blank_row) 
            break;
          FIg_enable(me->edtform, E_MCOL_F);

          FIfld_insert_blank_row(me->edtform, E_MCOL_F, row);
          /*me->something_done = TRUE;*/
          me->blank_row = TRUE;
          me->blank_row_no = row;          
          break;
#endif
          
        case PROCESS_CURVATURE:
     
#if dflT1
           printf("process curvature\n");
#endif
               switch_to_process_state(&me->accev, PROCESS_CURVATURE);

          break;
            
        case PROCESS_TOGGLE_FIXPT:

          if(me->vxt[row].fxp[0] == '*') {
            me->vxt[row].fxp[0] = ' ';
            FIfld_set_text(me->edtform, E_MCOL_F, row, FXC, "  ",0);
            me->nfp -= 1;
            me->ncon -= 1;
            pnt1[X] = me->vxt[row].xp;
            pnt1[Y] = me->vxt[row].yp;
            pnt1[Z] = me->vxt[row].zp;
            j = 1;
            stat_OM = ECdisplayPointSetByBuffer(
                         &msg_loc,
                         me->active_display,
                         me->md_env,
                         my_id,
                         j,
                         pnt1,
                         FALSE);
          } else {
            me->vxt[row].fxp[0] = '*';
            FIfld_set_text(me->edtform, E_MCOL_F, row, FXC, "* ",0);
            me->nfp += 1;
            me->ncon += 1;
            if (!strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type))) {
              strcpy(me->mfp.knot_type,UNIFORM_T);
              FIg_set_text(me->mainform,M_KNOT_F,me->mfp.knot_type);
            }
            stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                                    &msg_loc),
                              targetid = my_id);
          }
          break;
 

        case PROCESS_DELETE_VERTEX:
#if dflT1
           printf("process delete vertex\n");
#endif
           stat_OM = om$send (msg = message ECascrcr.process_delete(
                                     &msg_loc,
                                     &row,
                                     &pos),
                              targetid = my_id);

           break;

        case PROCESS_EDIT_VERTEX:
#if dflT1
           printf("process edit vertex\n");
#endif
           break;
        case PROCESS_SET_TANGENT:
#if dflT1
           printf("process tangent\n");
#endif
               switch_to_process_state(&me->accev, PROCESS_SET_TANGENT);

               break;

        default:
          break;
      }
    old_row = row;
    break;
    
#if dflT_tabins

   case E_INS_B:
   /* insert vertex button */
#if dflT1
    printf("insert vertex button pressed\n");
#endif
    FIg_get_state(me->edtform, E_INS_B, &toggle);
    if(toggle && me->command != PROCESS_INSERT_VERTEX) {
      me->something_done = FALSE;
      me->command = PROCESS_INSERT_VERTEX;
      me->blank_row = FALSE;
      me->blank_row_no = 999999;
      put_msg(&me->edtform, E_MSG_F, SEL_ROW);
      ex$message (msgnumb = EMS_P_SEL_ROW );
      set_gadget_active_inactive(&me->edtform, 15,
          E_MCOL_F, OFF, E_EDT_B, OFF, E_MOV_B, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF, E_AFIX_B, OFF,
          E_CURV_B, OFF,E_DEL_B,OFF, E_SHFIX_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_SIFIX_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);
    };
    if (!toggle) {
     if(me->something_done) {
      me->XXXXX = 2256;
      me->something_done = FALSE;
      row = me->blank_row_no;
      me->sel_pt[X] = me->vxt[row].xp;
      me->sel_pt[Y] = me->vxt[row].yp;
      me->sel_pt[Z] = me->vxt[row].zp;
      put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
      ex$message (msgnumb = EMS_I_00000);
      me->nvx += 1;
      me->npara += 1;
      FIfld_insert_blank_row(me->edtform, E_VERTEX_F, row);
      for (i=0; i < me->nvx; i++) {
        fvalue = (IGRdouble) i;
        FIfld_set_value(me->edtform, E_VERTEX_F, i, 0, fvalue, 0);
        me->vxt[i].nvno = i;
      }

      for(i=me->nvx;i>row;i--) {
        me->vxt[i].xp = me->vxt[i-1].xp;
        me->vxt[i].yp = me->vxt[i-1].yp;
        me->vxt[i].zp = me->vxt[i-1].zp;
        me->vxt[i].fxp[0] = me->vxt[i-1].fxp[0];
        me->vxt[i].fac = me->vxt[i-1].fac;
        me->vxt[i].ta[0] = me->vxt[i-1].ta[0];
        me->vxt[i].tav[X] = me->vxt[i-1].tav[X];
        me->vxt[i].tav[Y] = me->vxt[i-1].tav[Y];
        me->vxt[i].tav[Z] = me->vxt[i-1].tav[Z];
      }
      FIfld_get_value(me->edtform, E_MCOL_F, row, XC, &p[X],&sel,&pos2);
      FIfld_get_value(me->edtform, E_MCOL_F, row, YC, &p[Y],&sel,&pos2);
      FIfld_get_value(me->edtform, E_MCOL_F, row, ZC, &p[Z],&sel,&pos2);
      me->vxt[row].xp = p[X];
      me->vxt[row].yp = p[Y];
      me->vxt[row].zp = p[Z];

      me->vxt[row].ta[0] = ' ';

      FIfld_get_text(me->edtform, E_MCOL_F, row, FXC, 1,
                     &me->vxt[row].fxp,&sel, &pos); 
      FIfld_get_value(me->edtform, E_MCOL_F, row, FAC, 
                      &me->vxt[row].fac,&sel,&pos2);
      boreline.point1 = pnt1;
      boreline.point2 = pnt2;
      pnt1[X] = p[X];
      pnt1[Y] = p[Y];
      pnt1[Z] = p[Z];
      stat_OM = om$send (msg = message ECascrcr.insert_vertex(
                               &msg_loc,
                               me->sel_pt,
                               row,
                               &boreline,
                               &dum1),
                         targetid=my_id);

        FIfld_set_active_row(me->edtform, E_MCOL_F, row, 0); 
        FIfld_set_active_row(me->edtform, E_VERTEX_F, row, 0); 
#if dflT5
        for(i=0;i<me->nvx;i++) 
          printf("i= %d nvno= %d  vxt[i]x= %f  vxt[i]y= %f  vxt[i]z %f\n",
                 i, me->vxt[i].nvno,me->vxt[i].xp, me->vxt[i].yp, me->vxt[i].zp);
        for(i=0;i<me->nvx;i++) {
          FIfld_get_value(me->edtform,E_VERTEX_F,i,0,&fvalue,&sel,&pos);
          FIfld_get_value(me->edtform,E_MCOL_F,i,XC,&xp,&sel,&pos);
          FIfld_get_value(me->edtform,E_MCOL_F,i,YC,&yp,&sel,&pos);
          FIfld_get_value(me->edtform,E_MCOL_F,i,ZC,&zp,&sel,&pos);
          printf("i= %d nvno= %d  edtx= %f  edty= %f  edtz %f\n",
                 i, (int)fvalue,xp, yp, zp); 
        }
#endif         
      } else if(me->blank_row) {
        FIfld_set_active_row(me->edtform, E_MCOL_F, me->blank_row_no, 0); 
        FIfld_delete_rows(me->edtform, E_MCOL_F, me->blank_row_no, 1);
        me->blank_row = FALSE;
        me->blank_row_no = 999999;
      }
      set_gadget_active_inactive(&me->edtform, 15,
          E_MCOL_F, OFF, E_EDT_B, ON, E_MOV_B, ON,
          E_TA1_B, ON, E_UNDO_B, ON, E_AFIX_B, ON,
          E_CURV_B, ON,E_DEL_B,ON, E_SHFIX_B, ON,
          E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);

      me->undo_type = UNDO_COMPLETED;
      me->undo_num = 0;
      FIg_set_state_off(me->edtform, E_INS_B);
      me->command = PROCESS_SELECT;
    }
                            
    break;
#endif

   case E_INS_B:
   /* insert vertex button */
#if dflT1
    printf("insert vertex button pressed\n");
#endif
    FIg_get_state(me->edtform, E_INS_B, &toggle);
    if(toggle && me->command != PROCESS_INSERT_VERTEX) {
      me->something_done = FALSE;
      me->command = PROCESS_INSERT_VERTEX;
      me->blank_row = FALSE;
      me->blank_row_no = 999999;
      put_msg(&me->edtform, E_MSG_F, SEL_LS);
      ex$message (msgnumb = EMS_P_SEL_LS);
      set_gadget_active_inactive(&me->edtform, 16,
          E_MCOL_F, OFF, E_EDT_B, OFF, E_VERTEX_F, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF, E_AFIX_B, OFF,
          E_CURV_B, OFF,E_DEL_B,OFF, E_SHFIX_B, OFF, E_MOV_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_SIFIX_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF);
    };
    if(!toggle) {
      set_gadget_active_inactive(&me->edtform, 16,
          E_MCOL_F, OFF, E_EDT_B, ON, E_VERTEX_F, ON,
          E_TA1_B, ON, E_UNDO_B, ON, E_AFIX_B, ON,
          E_CURV_B, ON,E_DEL_B,ON, E_SHFIX_B, ON, E_MOV_B, ON,
          E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON);

      me->undo_type = UNDO_COMPLETED;
      me->undo_num = 0;
      FIg_set_state_off(me->edtform, E_INS_B);
      put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
      ex$message (msgnumb = EMS_I_00000);
      me->command = PROCESS_SELECT;
    }
    break;

   case E_DEL_B:
   /* delete vertex button */
#if dflT1
    printf("delete vertex button pressed \n");
#endif
    FIg_get_state(me->edtform, E_DEL_B, &toggle);
    if(toggle && me->nvx < 3) {
      put_msg(&me->edtform, E_MSG_F, DEL_NOT_1_LINE);
      ex$message (msgnumb = EMS_I_DEL_NOT_1_LINE);
      FIg_set_state_off(me->edtform, E_DEL_B);
    }
    else if(toggle) {
      me->command = PROCESS_DELETE_VERTEX;
      put_msg(&me->edtform, E_MSG_F, SEL_ROW);
      ex$message (msgnumb = EMS_P_SEL_ROW);
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, OFF, E_EDT_B, OFF, E_AFIX_B, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF,E_MCOL_F, OFF,
          E_CURV_B, OFF, E_SHFIX_B, OFF, E_MOV_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_SIFIX_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);
    }
    else {
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, ON, E_EDT_B, ON, E_AFIX_B, ON, 
          E_TA1_B, ON, E_UNDO_B, ON,E_MCOL_F, OFF,
          E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
          E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
      put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
      ex$message (msgnumb = EMS_I_00000);
      me->delete_row = FALSE;
      me->command = PROCESS_SELECT;
    }                            
    break;

   case E_MCOL_F:
   /* multi row column edit field */
#if dflT1
    printf("edit multi row and column field \n");
#endif
    FIfld_get_active_row(me->edtform, E_MCOL_F, &row, &pos);
    /*FIfld_set_active_row(me->edtform, E_MCOL_F, row, 0);
    FIfld_set_active_row(me->edtform, E_VERTEX_F, row, 0);*/
    FImcf_get_active_col(me->edtform, E_MCOL_F, &col, &dummy);
    me->edt_row = row;
    me->edt_pos = pos;
    me->edt_col = col;
#if dflT1
    printf("multi col field edited \n");
    printf("row = %d pos = %d  col = %d\n", row, pos, col);
#endif


    switch(me->command) {
#if dflT_tabins    
      case PROCESS_INSERT_VERTEX:
        if (row != me->blank_row_no) {
          if(me->something_done) {
             row = me->blank_row_no;
             put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
             ex$message (msgnumb = EMS_I_00000);
             me->nvx += 1;
             me->npara += 1;
             FIfld_insert_blank_row(me->edtform, E_VERTEX_F, row);
             for (i=0; i < me->nvx; i++) {
               fvalue = (IGRdouble) i;
               FIfld_set_value(me->edtform, E_VERTEX_F, i, 0, fvalue, 0);
               me->vxt[i].nvno = i;
             }
             for(i=me->nvx;i>row;i--) {
               me->vxt[i].xp = me->vxt[i-1].xp;
               me->vxt[i].yp = me->vxt[i-1].yp;
               me->vxt[i].zp = me->vxt[i-1].zp;
               me->vxt[i].fxp[0] = me->vxt[i-1].fxp[0];
               me->vxt[i].fac = me->vxt[i-1].fac;
               me->vxt[i].ta[0] = me->vxt[i-1].ta[0];
               me->vxt[i].tav[X] = me->vxt[i-1].tav[X];
               me->vxt[i].tav[Y] = me->vxt[i-1].tav[Y];
               me->vxt[i].tav[Z] = me->vxt[i-1].tav[Z];
             }
             FIfld_get_value(me->edtform, E_MCOL_F, row, XC, &p[X],&sel,&pos2);
             FIfld_get_value(me->edtform, E_MCOL_F, row, YC, &p[Y],&sel,&pos2);
             FIfld_get_value(me->edtform, E_MCOL_F, row, ZC, &p[Z],&sel,&pos2);
             me->vxt[row].xp = p[X];
             me->vxt[row].yp = p[Y];
             me->vxt[row].zp = p[Z];
             me->vxt[row].ta[0] = ' ';

             FIfld_get_text(me->edtform, E_MCOL_F, row, FXC, 1,
                            &me->vxt[row].fxp,&sel, &pos); 
             FIfld_get_value(me->edtform, E_MCOL_F, row, FAC, 
                            &me->vxt[row].fac,&sel,&pos2);
             boreline.point1 = pnt1;
             boreline.point2 = pnt2;
             pnt1[X] = p[X];
             pnt1[Y] = p[Y];
             pnt1[Z] = p[Z];
             stat_OM = om$send (msg = message ECascrcr.insert_vertex(
                                  &msg_loc,
                                  pnt1,
                                  row,
                                  &boreline,
                                  &dum1),
                           targetid=my_id);
             set_gadget_active_inactive(&me->edtform, 15,
              E_MCOL_F, OFF, E_EDT_B, ON, E_MOV_B, ON,
              E_TA1_B, ON, E_UNDO_B, ON, E_AFIX_B, ON,
              E_CURV_B, ON,E_DEL_B,ON, E_SHFIX_B, ON,
              E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
              E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
             FIg_set_state_off(me->edtform, E_INS_B);
             me->command = PROCESS_SELECT;
          } else {
             FIfld_set_active_row(me->edtform, E_MCOL_F, me->blank_row_no, pos); 
             FIfld_delete_rows(me->edtform, E_MCOL_F, me->blank_row_no, 1);
             me->blank_row = FALSE;
             me->blank_row_no = 999999;
             me->undo_type = UNDO_COMPLETED;
             me->undo_num = 0;
             FIg_set_state_off(me->edtform, E_INS_B);
             put_msg(&me->edtform, E_MSG_F, WRONGROW);
             ex$message (msgnumb = EMS_I_WRONGROW);
             set_gadget_active_inactive(&me->edtform, 14,
               E_MCOL_F, ON, E_EDT_B, ON,
               E_TA1_B, ON, E_UNDO_B, ON, E_AFIX_B, ON, 
               E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
               E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON,
               E_SIFIX_B, ON ,E_ACC_B, ON, E_LSVISIBLE_B, ON, 0,0,0,0);
             FIg_set_state_off(me->edtform, E_INS_B);
             me->command = PROCESS_SELECT;
	   }
          } else {
               me->something_done = TRUE;
        }
        break;
#endif       
      case PROCESS_EDIT_VERTEX:

        me->XXXXX = 2255;
        me->vxt[row].edt_flag = 'x';

        break;
   
      default:
        break;    
    }

    break;

   case E_AFIX_B:                   
   /* set/delete all fixpoints */
#if dflT1
    printf("set/delete all fixpoints button pressed \n");
#endif
    FIg_get_state(me->edtform, E_AFIX_B, &toggle);
    if(toggle) {
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, OFF, E_EDT_B, OFF, E_SIFIX_B, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF,E_MCOL_F, OFF,
          E_CURV_B, OFF, E_SHFIX_B, OFF, E_MOV_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_DEL_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);
     if(me->all_fixpts_set) {
      me->nfp = me->nvx;
      for(i=0;i < me->nvx;i++) {
        if(me->vxt[i].ta[0] != '*') {
          me->vxt[i].fxp[0] = ' ';
          FIfld_set_text(me->edtform, E_MCOL_F, i, FXC, "  ",0);
          me->nfp -= 1;
          me->ncon -= 1;
        }
      }
      me->all_fixpts_set = FALSE;
     } else {
      for(i=0;i < me->nvx;i++) {
        if(me->vxt[i].fxp[0] != '*') {
          me->nfp += 1;
          me->ncon += 1;
        }
        me->vxt[i].fxp[0] = '*';
        FIfld_set_text(me->edtform, E_MCOL_F, i, FXC, "* ",0);
        
      }
      me->all_fixpts_set = TRUE;
     }

     if (!strncmp(me->mfp.knot_type,FREE_T,strlen(me->mfp.knot_type))) {
       strcpy(me->mfp.knot_type,UNIFORM_T);
       FIg_set_text(me->mainform,M_KNOT_F,me->mfp.knot_type);
     }
     stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                            &msg_loc),
                      targetid = my_id);

    FIg_set_state_off(me->edtform, E_AFIX_B);
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, ON, E_EDT_B, ON, E_SIFIX_B, ON,
          E_TA1_B, ON, E_UNDO_B, ON,E_MCOL_F, OFF,
          E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON, 
          E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_DEL_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
    me->command = PROCESS_SELECT;
    }

    break;

   case E_SIFIX_B:                   
   /* toggle fixpoints */
#if dflT1
    printf("toggle fixpoint button pressed \n");
#endif
    FIg_get_state(me->edtform, E_SIFIX_B, &toggle);
    if(toggle) {
      put_msg(&me->edtform, E_MSG_F, SEL_ROW);
      ex$message (msgnumb = EMS_P_SEL_ROW);
      me->command = PROCESS_TOGGLE_FIXPT;
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, OFF, E_EDT_B, OFF, E_AFIX_B, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF,E_MCOL_F, OFF,
          E_CURV_B, OFF, E_SHFIX_B, OFF, E_MOV_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_DEL_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);
    } else {
      put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
      ex$message (msgnumb = EMS_I_00000);
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, ON, E_EDT_B, ON, E_AFIX_B, ON, 
          E_TA1_B, ON, E_UNDO_B, ON,E_MCOL_F, OFF,
          E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
          E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_DEL_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
      me->command = PROCESS_SELECT;
    }                            
    break;

  case E_SHFIX_B:
   /* show all fixpoints */
#if dflT1
    printf("show all fixpoints button pressed \n");
#endif
    FIg_get_state(me->edtform, E_SHFIX_B, &toggle);
    if(toggle) {
      me->command = PROCESS_SHOW_FIXPT;
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, OFF, E_EDT_B, OFF, E_AFIX_B, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF,E_MCOL_F, OFF,
          E_CURV_B, OFF, E_SIFIX_B, OFF, E_MOV_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_DEL_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);
      j = 1;
      for(i=0;i < me->nvx;i++) {
        pnt1[X] = me->vxt[i].xp;
        pnt1[Y] = me->vxt[i].yp;
        pnt1[Z] = me->vxt[i].zp;
        if(me->vxt[i].fxp[0] == ' ') {
          stat_OM = ECdisplayPointSetByBuffer(
                         &msg_loc,
                         me->active_display,
                         me->md_env,
                         my_id,
                         j,
                         pnt1,
                         FALSE);
        }    
      }                 
    
      dpmode  = GRbd;
      stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->ls_info.located_obj.objid,
                          targetos = me->ls_info.located_obj.osnum);
      for(i=0;i < me->nvx;i++) {
        pnt1[X] = me->vxt[i].xp;
        pnt1[Y] = me->vxt[i].yp;
        pnt1[Z] = me->vxt[i].zp;
        if(me->vxt[i].fxp[0] == '*') {
          stat_OM = ECdisplayPointSetByBuffer(
                         &msg_loc,
                         me->active_display,
                         me->md_env,
                         my_id,
                         j,
                         pnt1,
                         TRUE);    
        }
      }
      if(me->nfp == 0) {
       sprintf(fmessage,"No fixpoints ");
      } else if(me->nfp == me->nvx) {
       sprintf(fmessage,"All points are fix");
      } else {
       sprintf(fmessage,"Number of fixpoints =  %d ", me->nfp);
      }
      FIg_set_text(me->edtform, E_MSG_F, fmessage);
      FIg_set_state_off(me->edtform, E_SHFIX_B);
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, ON, E_EDT_B, ON, E_AFIX_B, ON, 
          E_TA1_B, ON, E_UNDO_B, ON,E_MCOL_F, OFF,
          E_CURV_B, ON, E_SIFIX_B, ON, E_MOV_B, ON,
          E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_DEL_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
      me->command = PROCESS_SELECT;
    }                            
    break;


   case E_JUMP_F:                  
   /* jump to vertex no field */
#if dflT1
     printf("jump to vertex field  \n");
#endif
     FIg_get_value(me->edtform, E_JUMP_F, &fvalue);
     row = (int) fvalue;
     if (row >= me->nvx)
       row = me->nvx;
     if (row < 0)
       row = 0;
     if (row == 0)
       me->first_point = TRUE;
     FIfld_set_active_row(me->edtform, E_MCOL_F, row, 0);
     FIfld_set_active_row(me->edtform, E_VERTEX_F, row, 0);
     FIfld_get_value(me->edtform, E_MCOL_F, row, XC, &p[X],&sel,&pos2);
     FIfld_get_value(me->edtform, E_MCOL_F, row, YC, &p[Y],&sel,&pos2);
     FIfld_get_value(me->edtform, E_MCOL_F, row, ZC, &p[Z],&sel,&pos2);

     stat_OM = om$send(msg = message ECascrcr.select_ls_point(
                            &msg_loc,
                            p,
                            &drow,
                            &pos),
                     targetid = my_id);

     break;

   case E_JUMPF_B:                  
   /* jump to first vertex button */
#if dflT1
    printf("jump to first vertex  \n");
#endif
     row = 0;
     me->first_point = TRUE;
     FIfld_set_active_row(me->edtform, E_MCOL_F, row, 0);
     FIfld_set_active_row(me->edtform, E_VERTEX_F, row, 0);
     FIfld_get_value(me->edtform, E_MCOL_F, row, XC, &p[X],&sel,&pos2);
     FIfld_get_value(me->edtform, E_MCOL_F, row, YC, &p[Y],&sel,&pos2);
     FIfld_get_value(me->edtform, E_MCOL_F, row, ZC, &p[Z],&sel,&pos2);

     stat_OM = om$send(msg = message ECascrcr.select_ls_point(
                            &msg_loc,
                            p,
                            &drow,
                            &pos),
                     targetid = my_id);
     break;

   case E_JUMPL_B:                  
   /* jump to last vertex button */
#if dflT1
    printf("jump to last vertex  \n");
#endif
     row = me->nvx -1;
     me->first_point = FALSE;
     FIfld_set_active_row(me->edtform, E_MCOL_F, row, 0);
     FIfld_set_active_row(me->edtform, E_VERTEX_F, row, 0);
     FIfld_get_value(me->edtform, E_MCOL_F, row, XC, &p[X],&sel,&pos2);
     FIfld_get_value(me->edtform, E_MCOL_F, row, YC, &p[Y],&sel,&pos2);
     FIfld_get_value(me->edtform, E_MCOL_F, row, ZC, &p[Z],&sel,&pos2);

     stat_OM = om$send(msg = message ECascrcr.select_ls_point(
                            &msg_loc,
                            p,
                            &drow,
                            &pos),
                     targetid = my_id);
     break;


   case E_TA1_B:                   
   /* set/delete tangent constraint */
#if dflT1
    printf("set/del tangent constraint button pressed \n");
#endif

    FIg_get_state(me->edtform, E_TA1_B, &toggle);
    if(toggle && me->command != PROCESS_SET_TANGENT) {
      put_msg(&me->edtform, E_MSG_F, SEL_ROW);
      ex$message (msgnumb = EMS_P_SEL_ROW);
      set_gadget_active_inactive(&me->edtform, 15,
          E_MCOL_F, OFF, E_INS_B, OFF, E_AFIX_B, OFF,
          E_EDT_B, OFF, E_UNDO_B, OFF, E_DEL_B, OFF,
          E_CURV_B, OFF, E_SHFIX_B, OFF, E_MOV_B, OFF,
          E_SHTA_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF,
          E_SIFIX_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);
      me->command = PROCESS_SET_TANGENT;
    };
    if (!toggle) {
      if (me->locate_on) {
          put_msg(&me->edtform, E_MSG_F, LOCATE_RJT_MOVEON);
      } else {
         put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
         ex$message (msgnumb = EMS_I_00000);
         set_gadget_active_inactive(&me->edtform, 15,
            E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
            E_EDT_B, ON, E_UNDO_B, ON, E_DEL_B, ON,
            E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
            E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
            E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);

          
         FIg_set_state_off(me->edtform, E_TA1_B);
         me->command = PROCESS_SELECT;
      }
    }                            

    break;

#if dflT8
   case E_SPTCO_F:
#if dflT1
    printf("selection point color field \n");
#endif
     FIg_get_value(me->edtform, E_SPTCO_F, &sptco);
     me->sptco = (IGRint) sptco;
    
    break;

   case E_SPTWT_F:
#if dflT1
    printf("selection point weight field \n");
#endif
     FIg_get_value(me->edtform, E_SPTWT_F, &sptwt);
     me->sptwt = (IGRuchar) sptwt;
    
    break;

#endif

  case E_DRCV_B:
#if dflT1
    printf("draw curve button \n");
#endif


    stat_OM = om$send(msg = message ECascrcr.draw_curve_and_tools(
                            &msg_loc),
                      targetid = my_id);
    TEST_ERROR(stat_OM,msg_loc,"draw_curve_and_tools",function_end);

    FIg_set_state_off(me->edtform, E_DRCV_B);
    break;


  case E_SHTA_B:
#if dflT1
    printf("show all tangents button \n");
#endif

    FIg_get_state(me->edtform, E_SHTA_B, &toggle);
    if(toggle) {
      me->command = PROCESS_SHOW_TA;
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, OFF, E_EDT_B, OFF, E_AFIX_B, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF,E_MCOL_F, OFF,
          E_CURV_B, OFF, E_SIFIX_B, OFF, E_MOV_B, OFF,
          E_SHFIX_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_DEL_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);
      if(me->tangent_on_screen) {
        me->tangent_on_screen = FALSE;
        dpmode = GRbe;
      } else {
        me->tangent_on_screen = TRUE;
        dpmode = GRbd;
      }        
      for(i=0;i < me->nvx;i++) {
        pnt[0][X] = me->vxt[i].xp;
        pnt[0][Y] = me->vxt[i].yp;
        pnt[0][Z] = me->vxt[i].zp;
        if(me->vxt[i].ta[0] == '*') {
          stat_OM = om$send(msg = message ECascrcr.draw_vector(
                                   &msg_loc,
                                   pnt[0],
                                   dpmode,
                                   FALSE,
                                   me->vxt[i].tav),
                            targetid = my_id);
        }    
      }                 
    
      FIg_set_state_off(me->edtform, E_SHTA_B);
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, ON, E_EDT_B, ON, E_AFIX_B, ON, 
          E_TA1_B, ON, E_UNDO_B, ON,E_MCOL_F, OFF,
          E_CURV_B, ON, E_SIFIX_B, ON, E_MOV_B, OFF,
          E_SHFIX_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_DEL_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
      me->command = PROCESS_SELECT;
    }                            
    break;

  case E_CURV_B:
#if dflT1
    printf("toggle  curvature button pressed\n");
#endif
    FIg_get_state(me->edtform, E_CURV_B, &toggle);
    if(toggle) {
      me->command = PROCESS_CURVATURE;
      set_gadget_active_inactive(&me->edtform, 15,
          E_INS_B, OFF, E_EDT_B, OFF, E_AFIX_B, OFF,
          E_TA1_B, OFF, E_UNDO_B, OFF,E_MCOL_F, OFF,
          E_SHTA_B, OFF, E_SIFIX_B, OFF, E_MOV_B, OFF,
          E_SHFIX_B, OFF, E_SHCURVA_B, OFF, E_DRCV_B, OFF, 
          E_DEL_B, OFF, E_ACC_B, OFF, E_LSVISIBLE_B, OFF,0,0);
      put_msg(&me->edtform, E_MSG_F, SEL_FIRST_OR_LAST);
      ex$message (msgnumb = EMS_P_SEL_FIRST_OR_LAST);
    } else {
      if (me->locate_on) {
          put_msg(&me->edtform, E_MSG_F, LOCATE_RJT_MOVEON);
      } else {
         set_gadget_active_inactive(&me->edtform, 15,
             E_INS_B, ON, E_EDT_B, ON, E_AFIX_B, ON,
             E_TA1_B, ON, E_UNDO_B, ON,E_MCOL_F, OFF,
             E_SHTA_B, ON, E_SIFIX_B, ON, E_MOV_B, ON,
             E_SHFIX_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
             E_DEL_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
         put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
         ex$message (msgnumb = EMS_I_00000);
         me->command = PROCESS_SELECT;
      }
    }
    break;
#if dflT9
  case E_CURV_F:
#if dflT1
    printf("curvature field edited\n");
#endif
    FIg_get_value(me->edtform,E_CURV_F,&fvalue);
    if(me->edt_row == 0) {
      me->mfp.opt_curv0 = 1;
      me->mfp.rad0 = fvalue;
      if(fvalue == 0.0)
        me->mfp.opt_curv0 = 2;
    } else if(me->edt_row == me->nvx-1) {
      me->mfp.opt_curv1 = 1;
      me->mfp.rad1 = fvalue;
      if(fvalue == 0.0)
        me->mfp.opt_curv1 = 2;
    }
    me->mfp.cv_vector[X] = 0.0;
    me->mfp.cv_vector[Y] = 0.0;
    me->mfp.cv_vector[Z] = 0.0;
    me->mfp.cv_vector[X2] = 0.0;
    me->mfp.cv_vector[Y2] = 0.0;
    me->mfp.cv_vector[Z2] = 0.0;
    set_gadget_active_inactive(&me->edtform, 16,
          E_INS_B, ON, E_EDT_B, ON, E_AFIX_B, ON, 
          E_TA1_B, ON, E_UNDO_B, ON,E_MCOL_F, OFF, E_MOV_B, ON,
          E_SHTA_B, ON, E_SIFIX_B, ON, E_CURV_F, OFF,
          E_SHFIX_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
          E_DEL_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
    FIg_set_state_off(me->edtform, E_CURV_F);
    FIg_set_state_off(me->edtform, E_CURV_B);
    put_msg(&me->edtform, E_MSG_F, RADIUS_PICKED);
    ex$message (msgnumb = EMS_I_RADIUS_PICKED);
    me->command = PROCESS_SELECT;
    
    break;
#endif

  case E_SHCURVA_B:
#if dflT1
    printf("show curvature button \n");
#endif
    if(me->curvature_on_screen) {
        me->curvature_on_screen = FALSE;
        dpmode = GRbe;
    } else {
        me->curvature_on_screen = TRUE;
        dpmode = GRbd;
    }
    if(me->mfp.opt_curv0) {
      pt[X] = me->vxt[0].xp;
      pt[Y] = me->vxt[0].yp;
      pt[Z] = me->vxt[0].zp;
      w[X] = me->vxt[0].tav[X];
      w[Y] = me->vxt[0].tav[Y];
      w[Z] = me->vxt[0].tav[Z];
      stat_OM = om$send(msg = message ECascrcr.draw_vector(
                                   &msg_loc,
                                   pt,
                                   dpmode,
                                   FALSE,
                                   w),
                      targetid = my_id);
      w[X] = me->mfp.cv_vector[X] / me->rho;
      w[Y] = me->mfp.cv_vector[Y] / me->rho;
      w[Z] = me->mfp.cv_vector[Z] / me->rho;
      BSnorvec(&rc, w);
      stat_OM = om$send(msg = message ECascrcr.draw_vector(
                                   &msg_loc,
                                   pt,
                                   dpmode,
                                   FALSE,
                                   w),
                      targetid = my_id);
    }
    if(me->mfp.opt_curv1) {
      j = me->nvx - 1;
      pt[X] = me->vxt[j].xp;
      pt[Y] = me->vxt[j].yp;
      pt[Z] = me->vxt[j].zp;
      w[X] = me->vxt[j].tav[X];
      w[Y] = me->vxt[j].tav[Y];
      w[Z] = me->vxt[j].tav[Z];
      stat_OM = om$send(msg = message ECascrcr.draw_vector(
                                   &msg_loc,
                                   pt,
                                   dpmode,
                                   FALSE,
                                   w),
                      targetid = my_id);

      w[X] = me->mfp.cv_vector[X2] / me->rho;
      w[Y] = me->mfp.cv_vector[Y2] / me->rho;
      w[Z] = me->mfp.cv_vector[Z2] / me->rho;
      BSnorvec(&rc, w);
      stat_OM = om$send(msg = message ECascrcr.draw_vector(
                                   &msg_loc,
                                   pt,
                                   dpmode,
                                   FALSE,
                                   w),
                      targetid = my_id);
    }


    break;


   default:
    FIf_get_location(me->edtform,&me->fxpos, &me->fypos);
    break;


   } /* end switch (gadget_label) */ 
 }
 function_end:

    return(stat_OM); 

}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  /***execute***/
  IGRboolean            stat_func;
  IGRboolean            alloncv;
  IGRboolean            inserted;
  IGRboolean            not_finito;

  IGRint                num_vals=0, nallpts=0;
  IGRint                action=0;
  IGRint                p1seg=0;
  IGRint 		display_flag=0;
  IGRint                row=0, pos=0;
  IGRint                event_mask=0;
  IGRint                vix=0;
  IGRint                c=0;

  IGRint                no_pts=0, num_ele=0;
  IGRint                ret=0;
  IGRint                top=0;

  OM_S_CHANSELECT 	to_comps;
  OM_S_OBJECT_LINKAGE 	*oblist = NULL;
  OMuword 		class_id;
  IGRchar		ksl;
  IGRchar 		errmsg[EMMAXERRMSG_LEN]; 
  IGRchar               fmessage[MSG_F_L];

  IGRchar 		loc_prompt[54], 
                        acc_prompt[54], 
                        reloc_prompt[54];
  IGRchar 		*generic_pointer = NULL;
  IGRchar               *info = NULL;

  IGRlong 		event_size=0;
  IGRlong               size=0;
  IGRlong 		stat_OM, msg_loc, sts;
  IGRlong 		loc_mask, acc_mask;
  IGRlong               msg;
  IGRlong 		i=0, j=0, k=0;

  IGRdouble             cht=0.0;
  IGRdouble             xdiff=0.0, ydiff=0.0, zdiff=0.0;
  IGRdouble             fp=0.0, ip=0.0;
  IGRdouble             xtemp[3];
  IGRdouble             ppt[6];
  IGRdouble             dist=0.0;
  IGRdouble             di=0.0;
  IGRdouble             temp=0.0;
  IGRdouble 		t=0.0;
  IGRdouble             fvalue=0.0;
  IGRdouble             dypts[9];
  IGRdouble             sknot=0.0;
  IGRdouble             *nodevals;
  struct IGRpolyline polyline;
  IGRpoint              plt;
  IGRpoint              p0;
  IGRpoint              cp,
                        mvpt, 
                        ppp;
  IGRpoint 		pnt1, 
                        pnt2,
                        spoint[2], 
                        cveval[3];

  struct IGRdisplay     mdis;
  struct GRparms        proparms;
  struct IGRline 	boreline;
  struct GRevent 	event; 

  struct GRlc_locate 	lc_attr;

  struct IGRbsp_curve 	*closest_crv_geom = NULL;
  struct IGRbsp_curve   *crv = NULL;

  enum GRdpmode 	dpmode;
  OM_S_CLASSLIST 	rtree_classes, eligible_classes;
  OMuword 		r_classes[5], 
                        e_classes[5];
  BSrc 			rc;

  extern IGRdouble 	BSdotp();
  extern IGRdouble 	BSdistptpt();
  extern void 		BScveval();
  extern IGRboolean 	BSnorvec();
  extern IGRboolean 	BScrossp();
  extern IGRboolean     BSfreecv(),
                        BSplane3pt(), 
			BSprj_cv_pl();

  extern void		BSallocv();
  extern IGRint 	EMgetvggeom(IGRlong *, IGRshort *,IGRmatrix,
                                    struct GRid *,IGRchar **, IGRint *);


#if dflT1
  printf("in execute\n");
#endif

  ex$message(msgnumb = EMS_P_ClearPromptField);
 
  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "MCplasofcv.execute");

  do {

    switch (ME.super_cmd->state) {

      case GET_LINESTRING:

#if dflT1
  printf("in execute state GET LINESTRING\n");
#endif


        if (ME.ECelement->elem_hilit) {
          stat_OM = dp$erase_hilite(msg = &msg_loc);

          ME.ECelement->elem_hilit = FALSE;
        }

        loc_mask = GRm_DATA | 
                   GRm_RJT_MOVEON |
                   GRm_BACK_UP;
        acc_mask = GRm_DATA;

	ex$message(msgnumb = EMS_M_SeLs, buff = loc_prompt);


        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
    
        ex$message (msgnumb = EM_M_AsCrCrLs);
        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       /* LC_ACC_ONE_ELEMENT | */
                       PROJ_ACCEPT_POINT;


        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

        r_classes[0] = OPP_GRbspline_class_id;
    	e_classes[0] = OPP_GR3dlinestr_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];

    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &me->accev,
              	mask1 = loc_mask, 
              	mask2 = acc_mask,
              	eventsize= (int *)&event_size, 
              	display_flag = display_flag,
              	response = response,
              	response_data = response_data, 
              	locate_prompt = loc_prompt, 
              	acc_prompt = acc_prompt,
              	relocate_key = EMS_I_00010, 
              	attributes = &lc_attr, 
              	stack = &ME.ECelement->locate_stack, 
              	rtree_classes = &rtree_classes, 
              	eligible_classes = &eligible_classes);

	ex$message(msgnumb = EMS_P_ClearPromptField);

        if (stat_func == FALSE)
          {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto command_end;
          }
        /* if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
            break;
          else
            goto command_end;
          } */


        switch (me->accev.response) {

	  case EX_BACK_UP:
            ME.super_cmd->state = me->commandstate = GET_LINESTRING;

            goto command_end;

	  case EX_RJT_MOVEON:

	    ex$message(msgnumb = EMS_M_SeCuCcLs, buff = loc_prompt);

            me->nlcids = 0;
            nallpts = 0;

            ME.super_cmd->state = me->commandstate = CREATE_LINESTRING;

            goto command_end;


          case EX_DATA:
            ME.ECascrcr->ls_info = me->accev.located_object[0];
            ME.ECelement->elem_hilit = TRUE;
            ME.ECelement->elem.located_obj.objid = me->accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = me->accev.located_object[0].
                                         located_obj.osnum;

            me->lsname = (IGRint) ME.ECelement->elem.located_obj.objid;

            stat_OM = om$send (msg = message ECascrcr.get_poly_instances(
                                      &msg_loc),
                               targetid = my_id);
            TEST_ERROR(stat_OM,msg_loc,"ECascrcr.get_poly_instances",command_end);
            me->XXXXX = 1818;
            stat_OM = om$send (msg = message ECascrcr.search_for_curve(
                                      &msg_loc,
                                      &info),
                               targetid = my_id);

               stat_OM = om$send(msg = message ECascrcr.fill_tables(
                                     &msg_loc,
                                     (struct v_info *) info),
                              targetid = my_id);

            if(!me->to_next_linestring) {
               stat_OM = om$send(msg = message ECascrcr.determine_dist_length(
                            &msg_loc,
                            &di),
                      targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"determine_dist_length", command_end);
               me->cv.cvra_fm.leth = -di;
               me->cv.dist_fm.leth = di;
               me->cv.dist_fm.alln = OFF; 
               me->cv.dist_fm.loca = OFF; 
	    }

            if(me->mainform_requested) {
               sprintf(fmessage,"Linestring ID = %d", me->lsname);
               ret = FIg_set_text (me->mainform, M_MSG_F, fmessage);
	    }
            ME.super_cmd->state = me->commandstate = PROCESS;
            me->command = PROCESS_SELECT; 

            break;


          default:
            goto command_end;
          }
        
          break;

      case CREATE_LINESTRING:
#if dflT1
  printf("in execute state CREATE_LINESTRING\n");
#endif


        if (ME.ECelement->elem_hilit) {
          stat_OM = dp$erase_hilite(msg = &msg_loc);

          ME.ECelement->elem_hilit = FALSE;
        }

        loc_mask = GRm_DATA | 
                   GRm_RJT_MOVEON |
                   GRm_BACK_UP;
        acc_mask = GRm_DATA;

	ex$message(msgnumb = EMS_M_SeCuCcLs, buff = loc_prompt);


        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
    
        ex$message (msgnumb = EM_M_AsCrCrLs);
        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       LC_REGULAR_HIGHLIGHT |
                       LC_ACC_ONE_ELEMENT | 
                       PROJ_ACCEPT_POINT;


        rtree_classes.w_count = 1;
        eligible_classes.w_count = 2;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

        r_classes[0] = OPP_GRbspline_class_id;
    	e_classes[0] = OPP_GRbspline_class_id;
    	e_classes[1] = OPP_EMScomposite_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];

    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &me->accev,
              	mask1 = loc_mask, 
              	mask2 = acc_mask,
              	eventsize= (int *)&event_size, 
              	display_flag = display_flag,
              	response = response,
              	response_data = response_data, 
              	locate_prompt = loc_prompt, 
              	acc_prompt = acc_prompt,
              	relocate_key = EMS_I_00010, 
              	attributes = &lc_attr, 
              	stack = &ME.ECelement->locate_stack, 
              	rtree_classes = &rtree_classes, 
              	eligible_classes = &eligible_classes);

	ex$message(msgnumb = EMS_P_ClearPromptField);

        if (stat_func == FALSE)
          {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto command_end;
          }
        /* if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
            break;
          else
            goto command_end;
          } */


        switch (me->accev.response) {


	  case EX_BACK_UP:

#if dflT1
 printf("EX_BACK_UP\n");
#endif
            /*
                reverse the curve direction indicator 
                goto GET_LINESTRING 
            */
            stat_OM = om$send (msg = message ECascrcr.draw_vector(
                                         &msg_loc,
                                         spoint[0],
                                         GRbe,
                                         me->s[i].cdir,
                                         spoint[1]),
                                   targetid = my_id);


            if(me->s[i].cdir == FALSE)
              me->s[i].cdir = TRUE;
            else
              me->s[i].cdir = FALSE;

            stat_OM = om$send (msg = message ECascrcr.draw_vector(
                                         &msg_loc,
                                         spoint[0],
                                         GRbd,
                                         me->s[i].cdir,
                                         spoint[1]),
                                   targetid = my_id);

            TEST_ERROR(stat_OM,stat_OM,"ECascrcr.draw_vector",command_end);

            ME.super_cmd->state = me->commandstate = CREATE_LINESTRING;

            goto command_end;

	  case EX_RJT_MOVEON:
#if dflT1
 printf("EX_RJT_MOVEON\n");
#endif
            /* create a complete linestring here
               if there are objects located
            .
            .
            . */


            if(me->nlcids == 0)
               goto command_end;
#if dflT9
 for(i=0;i < me->nlcids; i++) {
 printf ("id = %d   os = %d \n", 
             me->lcids[i].objid,
             me->lcids[i].osnum);
 }
#endif
            /*
             find all comp curves and replace them by their segments
            */
            for(i=0;i<me->nlcids;i++) {
               stat_OM = om$get_classid(
                 objid = me->lcids[i].objid,
                 osnum = me->lcids[i].osnum,
                 p_classid = &class_id);

               TEST_ERROR(stat_OM,stat_OM,"ECascrcr.get_classid",command_end);
 
               stat_OM = om$is_ancestry_valid(subclassid = class_id, 
                      superclassid = OPP_EMScomposite_class_id);

               if(stat_OM == OM_S_SUCCESS) {
                stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

                stat_OM = om$get_channel_count(
                        objid = me->lcids[i].objid,
                        osnum = me->lcids[i].osnum,
                                p_chanselect = &to_comps,
                                count = (OMuint *)&me->num_comps);
                EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                command_end, errmsg);
  
                oblist  = (OM_S_OBJECT_LINKAGE *) om$malloc(
                           size = (me->num_comps)*sizeof(OM_S_OBJECT_LINKAGE));
                EMerr_hndlr(!oblist, *response, TERMINATE, command_end);

                stat_OM = om$get_channel_objects(
                             objid = me->lcids[i].objid,
                             osnum = me->lcids[i].osnum,
                             p_chanselect = &to_comps,
                             list = oblist,
                             size = (OMuint)me->num_comps,
                             count = (OMuint *)&me->num_comps);
                EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                command_end, errmsg);
                me->lcids[i].objid = oblist[0].S_objid;
                me->lcids[i].osnum = oblist[0].osnum;
                if (me->num_comps > 1) {
                  /* now reserve vla space for the other components */
                  num_ele = om$dimension_of(varray = me->lcids); 
                  if ((me->nlcids+me->num_comps-1) > num_ele) {
                    stat_OM = om$vla_set_dimension(varray = me->lcids,
                                   size = me->nlcids+me->num_comps+4);
                    TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",command_end);
                    stat_OM = om$vla_set_dimension(varray = me->s,
                                   size = me->nlcids+me->num_comps+4);
                    TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",command_end);
		  }
                  for(j=me->nlcids+me->num_comps-2,k=1;j >= i+me->num_comps;j--,k++) 
                    me->lcids[j] = me->lcids[me->nlcids-k];
                  me->nlcids += me->num_comps-1;
                  for (j=i+1,k=1; k<me->num_comps; j++,k++) {
                     me->lcids[j].objid = oblist[k].S_objid;
                     me->lcids[j].osnum = oblist[k].osnum;
 		  }
                  if (oblist) om$dealloc(ptr = oblist);
                    i += me->num_comps-1;
	        }
              }
	     }
#if dflT9
 for(i=0;i < me->nlcids; i++) {
    printf ("id = %d   os = %d \n", 
             me->lcids[i].objid,
             me->lcids[i].osnum);
 }
#endif



            /* loop 
              - get classid of object
              - if linestring (get poly-instances)
              - if not linestring
                - compute nodes
                - create vertices
            */ 
            for(i=0;i<me->nlcids;i++) {
               stat_OM = om$get_classid(
                 objid = me->lcids[i].objid,
                 osnum = me->lcids[i].osnum,
                 p_classid = &class_id);

               TEST_ERROR(stat_OM,stat_OM,"ECascrcr.get_classid",command_end);
 
               stat_OM = om$is_ancestry_valid(subclassid = class_id, 
                      superclassid = OPP_GR3dlinestr_class_id);

               if(stat_OM == OM_S_SUCCESS) {
                action = 0;
                stat_OM = om$send (msg = message GR3dlinestr.GRgetpolyline(
                           &msg_loc,
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
                           &action,
                           &polyline),
                    targetid = me->lcids[i].objid,
                    targetos = me->lcids[i].osnum);
                TEST_ERROR(stat_OM,msg_loc,"GRgetpolyline1",command_end);


                size = (polyline.num_points * 3) * sizeof(IGRdouble);
                me->s[i].lcptrs = (IGRdouble *) stackalloc(size);
                if(!me->s[i].lcptrs) 
                  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,
                               "stackalloc(polypts)",command_end);

                polyline.points = me->s[i].lcptrs;
                action = 1; /* get polyline itself */
                stat_OM = om$send (msg = message GR3dlinestr.GRgetpolyline(
                           &msg_loc,
                           &me->md_env.md_env.matrix_type,
                           me->md_env.md_env.matrix,
                           &action,
                           &polyline),
                    targetid = me->lcids[i].objid,
                    targetos = me->lcids[i].osnum);
                TEST_ERROR(stat_OM,msg_loc,"GRgetpolyline2",command_end);
                me->s[i].npts = polyline.num_points;
                nallpts += polyline.num_points;
	      } else {
                /* 
                  - get the bsp struct
                  - get the knot vector
                  - compute the nodes (u)
                  - malloc (me->lcptrs[i])  and compute the x,y,z 
                */
                   
                stat_OM = om$send( msg = message GRvg.GRgetsize(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  &size ),
                            targetos = me->lcids[i].osnum,
                            targetid = me->lcids[i].objid );
                TEST_ERROR(stat_OM,msg_loc,"GRgetsize",command_end);

                crv = (struct IGRbsp_curve *) stackalloc( size );
                if(!crv) 
                  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"stackalloc(crv)",
                               command_end);
 
                stat_OM = om$send( msg = message GRvg.GRgetgeom(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  (IGRchar *)crv),
                            targetos = me->lcids[i].osnum,
                            targetid = me->lcids[i].objid );
                
                size = crv->num_poles * sizeof(IGRdouble);
                nodevals = (IGRdouble *) stackalloc(size);
                if(!nodevals) 
                  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"stackalloc(nodevals)",
                               command_end);
                BSnodevals(crv->order, crv->num_knots, crv->knots, 0,
                           &num_vals, nodevals, &sts);
                TEST_MATH_ERROR(sts,"BSnodevals",command_end);
                me->s[i].npts = num_vals;
                nallpts += num_vals;
#if dflT2
 printf("num_vals= %d\n",num_vals);
#endif
                size = (num_vals * 3) * sizeof(IGRdouble);
                me->s[i].lcptrs = (IGRdouble *) stackalloc(size);
                if(!me->s[i].lcptrs) 
                  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,
                               "stackalloc(polypts)",command_end);
                for(k=0,j=0; j<num_vals*3-2; k++,j=j+3) {
                   BScveval(crv, *(nodevals + k), 0, 
                            (IGRpoint *) &me->s[i].lcptrs[j], &sts); 
                   TEST_MATH_ERROR(sts,"BScveval",command_end);
		}
	      }
	     }
#if dflT2
for (i=0;i<me->nlcids;i++) {
  printf("id = %d  os = %d\n", me->lcids[i].objid, me->lcids[i].osnum);
  for (j=0; j<me->s[i].npts*3-2; j=j+3) {
    printf(" %f  %f  %f\n", me->s[i].lcptrs[j], 
                            me->s[i].lcptrs[j+1],
                            me->s[i].lcptrs[j+2]);
  }
}
#endif 

            /*
              reverse some point sets if curve direction is true
            */
            not_finito = TRUE;
            for (i=0; i < me->nlcids; i++) {
             top = me->s[i].npts*3;
             fp = modf(me->s[i].npts/2,&ip);
             if(me->s[i].cdir == TRUE) {
               not_finito = TRUE;
               for(j=0; not_finito; j=j+3) {
                 xtemp[2] = me->s[i].lcptrs[top-j-1];
                 xtemp[1] = me->s[i].lcptrs[top-j-2];
                 xtemp[0] = me->s[i].lcptrs[top-j-3];
                 me->s[i].lcptrs[top-j-1] = 
                   me->s[i].lcptrs[j+2];
                 me->s[i].lcptrs[top-j-2] = 
                   me->s[i].lcptrs[j+1];
                 me->s[i].lcptrs[top-j-3] = 
                   me->s[i].lcptrs[j];
                 me->s[i].lcptrs[j+2] = xtemp[2];
                 me->s[i].lcptrs[j+1] = xtemp[1];
                 me->s[i].lcptrs[j] = xtemp[0];
                 if(fp == 0.0 && (int) ((j/3)+1) == (int) ip)
                     not_finito = FALSE;
                 if(!(fp == 0.0) && (int)(j/3) == (int) ip)
                     not_finito = FALSE;                
              }
             }
            } 

            /* put all points in an array of points  and eliminate
               duplicate points 
            */
            num_ele = om$dimension_of(varray = me->opts); 
            if ((nallpts) > num_ele) {
              stat_OM = om$vla_set_dimension(varray = me->opts,
                                   size = nallpts*3 + 15);
              TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",command_end);
            }
            BSEXTRACTPAR(&sts, BSTOLCHRDHT, cht);
            me->opts[0] = me->s[0].lcptrs[0];
            me->opts[1] = me->s[0].lcptrs[1];
            me->opts[2] = me->s[0].lcptrs[2];
            for(i=0,k=3;i<me->nlcids;i++) {
              for(j= (i==0) ? 3 : 0;j < me->s[i].npts*3-2;j=j+3,k=k+3) {
                me->opts[k] = me->s[i].lcptrs[j];
                me->opts[k+1] = me->s[i].lcptrs[j+1];
                me->opts[k+2] = me->s[i].lcptrs[j+2];
                xdiff = fabs(me->opts[k] - me->opts[k-3]);
                ydiff = fabs(me->opts[k+1] - me->opts[k-2]);
                zdiff = fabs(me->opts[k+2] - me->opts[k-1]);
                if(xdiff < cht && ydiff < cht && zdiff < cht) {
                  nallpts -= 1;
                  k -=3;
		}
              }
            }
#if dflT2
   printf("nallpts= %d\n",nallpts);

  for(i=0; i<nallpts*3-2;i=i+3) 
   printf("%f   %f   %f\n", me->opts[i], me->opts[i+1], me->opts[i+2]);
#endif    

            /* construct a linestring  object */

            /* me->ls_id.osnum = const_list.env_info->md_id.osnum; */

            stat_OM = dp$erase_hilite(msg = &msg_loc);

            gr$place_linear_object(msg = &msg_loc,
                                   num_points = nallpts,
                                   points = me->opts,
                                   object_id = &me->ls_id,
                                   display_flag = 1);

            me->accev.located_object[0].located_obj.objid = me->ls_id.objid;
            me->accev.located_object[0].located_obj.osnum = me->ls_id.osnum;
            ME.ECascrcr->ls_info = me->accev.located_object[0];
            ME.ECelement->elem_hilit = TRUE;
            ME.ECelement->elem.located_obj.objid = me->accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = me->accev.located_object[0].
                                         located_obj.osnum;

            me->lsname = (IGRint) ME.ECelement->elem.located_obj.objid;

            stat_OM = om$send (msg = message ECascrcr.get_poly_instances(
                                      &msg_loc),
                               targetid = my_id);
            TEST_ERROR(stat_OM,msg_loc,"ECascrcr.get_poly_instances",command_end);

            stat_OM = om$send (msg = message ECascrcr.search_for_curve(
                                      &msg_loc,
                                      &info),
                               targetid = my_id);

               stat_OM = om$send(msg = message ECascrcr.fill_tables(
                                     &msg_loc,
                                     (struct v_info *) info),
                              targetid = my_id);

            if(!me->to_next_linestring) {
               stat_OM = om$send(msg = message ECascrcr.determine_dist_length(
                            &msg_loc,
                            &di),
                      targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"determine_dist_length", command_end);
               me->cv.cvra_fm.leth = -di;
               me->cv.dist_fm.leth = di;
               me->cv.dist_fm.alln = OFF; 
               me->cv.dist_fm.loca = OFF; 
	    }

            if(me->mainform_requested) {
               sprintf(fmessage,"Linestring ID = %d", me->lsname);
               ret = FIg_set_text (me->mainform, M_MSG_F, fmessage);
	    }
	    ex$message(msgnumb = EMS_I_00000);


            ex$message(msgnumb = EMS_P_00038);
            ex$message(msgnumb = EMS_I_00010);
	    ex$message(msgnumb = EMS_I_00000, buff = loc_prompt);


            ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
            ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
            ME.super_cmd->state = me->commandstate = PROCESS;
            me->command = PROCESS_SELECT; 

            goto command_end;

          case EX_DATA:
#if dflT1
 printf("EX_DATA\n");
#endif

            /* 
            put the object into a locate array, if it is not already
            stored in the array. 
            if necessary vla$set_dimension of the array
            */
            dpmode  = GRhd;
            stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->accev.located_object[0].located_obj.objid,
                          targetos = me->accev.located_object[0].located_obj.osnum);
            me->nlcids += 1;
            num_ele = om$dimension_of(varray = me->lcids); 
            if (me->nlcids > num_ele) {
              stat_OM = om$vla_set_dimension(varray = me->lcids,
                                   size = me->nlcids+4);
              TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",command_end);
              stat_OM = om$vla_set_dimension(varray = me->s,
                                   size = me->nlcids+me->num_comps+4);
              TEST_ERROR(stat_OM,stat_OM,"vla_set_dimension",command_end);
            }

            for(i=1; i < me->nlcids; i++) { 
              if(me->lcids[i].objid == 
                  me->accev.located_object[0].located_obj.objid
              && me->lcids[i].osnum == 
                  me->accev.located_object[0].located_obj.osnum) {
                me->nlcids -= 1;
                ME.super_cmd->state = me->commandstate = 
                                      CREATE_LINESTRING;
                goto command_end;
              }
            }
            i = me->nlcids-1;
            me->lcids[i] = me->accev.located_object[0].located_obj;
            stat_OM = om$get_classid(
                 objid = me->lcids[i].objid,
                 osnum = me->lcids[i].osnum,
                 p_classid = &class_id);

            TEST_ERROR(stat_OM,stat_OM,"ECascrcr.get_classid",command_end);
 
            stat_OM = om$is_ancestry_valid(subclassid = class_id, 
                      superclassid = OPP_GR3dpoint_class_id);

            if(stat_OM == OM_S_SUCCESS) {
               ex$message(msgnumb = EMS_M_IdNx, buff = loc_prompt);
            } else {
                ex$message(msgnumb = EMS_M_IdNxMvRe, buff = loc_prompt);
                stat_OM = om$send( msg = message GRvg.GRgetsize(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  &size ),
                            targetos = me->lcids[i].osnum,
                            targetid = me->lcids[i].objid );
                TEST_ERROR(stat_OM,msg_loc,"GRgetsize",command_end);

                crv = (struct IGRbsp_curve *) stackalloc( size );
                if(!crv) 
                  REPORT_ERROR(stat_OM,OM_E_NODYNMEM,"stackalloc(crv)",
                               command_end);
 
                stat_OM = om$send( msg = message GRvg.GRgetgeom(
                                  &msg_loc,
                                  &me->md_env.md_env.matrix_type,
                                  me->md_env.md_env.matrix,
                                  (IGRchar *)crv),
                            targetos = me->lcids[i].osnum,
                            targetid = me->lcids[i].objid );
                
                BScveval(crv, 0.0, 1, spoint, &sts); 
                BSnorvec(&sts, &spoint[1]);
                me->s[i].cdir = FALSE;
                stat_OM = om$send (msg = message ECascrcr.draw_vector(
                                         &msg_loc,
                                         spoint[0],
                                         GRbd,
                                         FALSE,
                                         spoint[1]),
                                   targetid = my_id);
;
                TEST_ERROR(stat_OM,stat_OM,"ECascrcr.draw_vector",command_end);
	    }		 


            ME.super_cmd->state = me->commandstate = CREATE_LINESTRING;

            break;


          default:
#if dflT1
 printf("default\n");
#endif
            goto command_end;
          }
        
          break;



      case PROCESS:
#if dflT1
  printf("in execute state PROCESS\n");
#endif

        dpmode  = GRhe;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->ls_info.located_obj.objid,
                          targetos = me->ls_info.located_obj.osnum);

     if(me->edtform_requested == FALSE) {
      if(me->mainform_requested == FALSE) {
        stat_OM = om$send(msg = message ECascrcr.main_disp(),
                          targetid = my_id); 
      }
     }

     if(me->from_curve_creation) {
        stat_OM = om$send(msg = message ECascrcr.search_for_curve(
                                &msg_loc,
                                &info),
                          targetid = my_id);
        me->from_curve_creation = FALSE;
     }

     do {
    
	ex$message(msgnumb = EMS_I_00000, buff = loc_prompt);


        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
        if((me->command == PROCESS_SEL_REF_CURVE_KNOTS)
          || (me->command == PROCESS_SEL_REF_CURVE_PARAS))
	  ex$message(msgnumb = EMS_P_IDRCURVE, buff = loc_prompt);
        stat_func = co$getevent(
                  msg = &msg_loc,
                  /*mode = EX_ALL_CHAR_MODE,*/
                  event_mask = (GRm_DATA | 
                                GRm_CHAR | 
                                GRm_RJT_MOVEON | 
                                GRm_BACK_UP),
                  prompt = loc_prompt,
                  response = response,
                  response_data = response_data,
                  event = &me->accev);

        if (stat_func == FALSE) {
	  	    ex$message(msgnumb = EMS_E_FailInputProcExit);
          	    *response = TERMINATE;
          	    goto command_end;
        }
    
        me->form_event_handling = FALSE;
        switch (me->accev.response) {

	  case EX_BACK_UP:
	  case EX_RJT_MOVEON:
               if(PROCESS_SEL_REF_CURVE_KNOTS) {
                  me->reference_curve = FALSE;
                  strcpy(me->mfp.knot_type, me->old_knot_type);
                  FIg_set_text(me->mainform,M_KNOT_F,me->mfp.knot_type);
                  FIg_enable(me->mainform,M_ORDER_F);
                  FIg_enable(me->mainform,M_SPANS_F);
                  FIg_enable(me->mainform,M_POLES_F);
                  FIg_enable(me->mainform,M_SMOOTH_F);
                  FIg_enable(me->mainform,M_ITERA_F);
                  FIg_enable(me->mainform,M_APTOL_F);
                  FIg_enable(me->mainform,M_KNOT_F);
                  FIg_enable(me->mainform,M_PARA_F);
                  FIg_enable(me->mainform,M_EDLS_B);
                  FIg_enable(me->mainform,M_DRCV_B);
                  FIg_enable(me->mainform,M_SHCU_B);
                  FIg_enable(me->mainform,M_SGDI_B);
                  FIg_enable(me->mainform,M_SHPO_B);
                  FIg_enable(me->mainform,M_SHKN_B);
                  FIg_enable(me->mainform,M_PDIST_B);
                  FIg_enable(me->mainform,M_PCURV_B);
                  FIg_enable(me->mainform,M_PPOLE_B);
                  FIg_enable(me->mainform,M_PKNOT_B);
                  FIg_enable(me->mainform,M_LSVISIBLE_B);
	       }
               if(PROCESS_SEL_REF_CURVE_PARAS) {
                  me->reference_curve = FALSE;
                  strcpy(me->mfp.para_type, me->old_para_type);
                  FIg_set_text(me->mainform,M_PARA_F,me->mfp.para_type);
                  FIg_enable(me->mainform,M_ORDER_F);
                  FIg_enable(me->mainform,M_SPANS_F);
                  FIg_enable(me->mainform,M_POLES_F);
                  FIg_enable(me->mainform,M_SMOOTH_F);
                  FIg_enable(me->mainform,M_ITERA_F);
                  FIg_enable(me->mainform,M_APTOL_F);
                  FIg_enable(me->mainform,M_KNOT_F);
                  FIg_enable(me->mainform,M_PARA_F);
                  FIg_enable(me->mainform,M_EDLS_B);
                  FIg_enable(me->mainform,M_DRCV_B);
                  FIg_enable(me->mainform,M_SHCU_B);
                  FIg_enable(me->mainform,M_SGDI_B);
                  FIg_enable(me->mainform,M_SHPO_B);
                  FIg_enable(me->mainform,M_SHKN_B);
                  FIg_enable(me->mainform,M_PDIST_B);
                  FIg_enable(me->mainform,M_PCURV_B);
                  FIg_enable(me->mainform,M_PPOLE_B);
                  FIg_enable(me->mainform,M_PKNOT_B);
                  FIg_enable(me->mainform,M_LSVISIBLE_B);
	       }
               /*me->free_knot_type = FALSE;
               me->inter_knot_manip = FALSE;*/
               if(me->edtform_requested) {
                 set_gadget_active_inactive(&me->edtform, 16,
                  E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
                  E_EDT_B, ON, E_UNDO_B, ON, E_DEL_B, ON, E_TA1_B, ON,
                  E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
                  E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                  E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON);
                  FIg_set_state_off(me->edtform, E_TA1_B);
                  FIg_set_state_off(me->edtform, E_INS_B);
                  FIg_set_state_off(me->edtform, E_SIFIX_B);
                  FIg_set_state_off(me->edtform, E_DEL_B);
                  FIg_set_state_off(me->edtform, E_MOV_B);
                  FIg_set_state_off(me->edtform, E_CURV_B);
                  FIg_set_state_off(me->edtform, E_EDT_B);
                  put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
	       }
               if(me->mainform_requested)
                  put_msg(&me->mainform, M_MSG_F, CLEAR_MSG);
               ex$message (msgnumb = EMS_I_00000);
               me->command = PROCESS_SELECT;
               ME.super_cmd->state = me->commandstate = 
                       PROCESS;
               goto command_end;
 
	  case EX_DATA:
          
            me->sel_pt[X] = me->accev.event.button.x;
            me->sel_pt[Y] = me->accev.event.button.y;
            me->sel_pt[Z] = me->accev.event.button.z;
            pos = 0;
            if(!me->reference_curve) {
              if (!me->free_knot_type && !me->inter_knot_manip) {
                stat_OM = om$send(msg = message ECascrcr.select_ls_point(
                                     &msg_loc,
                                     me->sel_pt,
                                     &row,
                                     &pos),
                              targetid = my_id);
                me->edt_row = row;
	      } else {
                stat_OM = om$send(msg = message ECascrcr.select_cv_point(
                                     &msg_loc,
                                     me->sel_pt,
                                     &proparms.u,
                                     mvpt,
                                     &vix),
                              targetid = my_id);
                me->vix = vix;
              }
            }

            switch(me->command) {

            case PROCESS_SELECT:
   

               break;


	    case PROCESS_NEXT_LS:

               
               event_size = sizeof(struct EX_button);
               stat_func = ex$putque(
                            msg = &msg_loc,
                            pos = FRONT,
                            response = response,
                            byte = &event_size,
                            buffer = (char *) &me->accev.event.button);
                 ME.super_cmd->state = me->commandstate = GET_LINESTRING;
               
               me->to_next_linestring = TRUE;
               goto command_end;

	    case PROCESS_SEL_REF_CURVE_KNOTS:

               me->XXXXX = 2251;
               event_size = sizeof(struct EX_button);
               stat_func = ex$putque(
                            msg = &msg_loc,
                            pos = FRONT,
                            response = response,
                            byte = &event_size,
                            buffer = (char *) &me->accev.event.button);
              

               ME.super_cmd->state = me->commandstate = 
                       GET_REF_CURVE;
               goto command_end;

	    case PROCESS_SEL_REF_CURVE_PARAS:


               event_size = sizeof(struct EX_button);
               stat_func = ex$putque(
                            msg = &msg_loc,
                            pos = FRONT,
                            response = response,
                            byte = &event_size,
                            buffer = (char *) &me->accev.event.button);
              

               ME.super_cmd->state = me->commandstate = 
                       GET_REF_CURVE;
              goto command_end;


	    case PROCESS_INS_KNOT:
               if(proparms.u == 0.0 || proparms.u == 1.0) {
                 put_msg(&me->mainform,M_MSG_F, KNOT_NOT_TOSELECT);
                 goto command_end;
               }
               stat_OM = om$send(msg = message ECascrcr.draw_knot(
                                       &msg_loc,
                                       FALSE),
                                 targetid = my_id);
               me->nknot += 1;
               /* compute new knot vector */

               c = om$dimension_of(varray = me->knots); 
               if (me->nknot > c) {
                  stat_OM = om$vla_set_dimension(varray = me->knots,
                                   size = me->nknot+3);
                  TEST_ERROR(stat_OM,stat_OM,"ECascrcr.vla_set_dimension",command_end);
               }
               inserted = FALSE;
               for(i=0;(i<me->nknot) && (!inserted);i++) {
                  if (proparms.u < me->knots[i]) {
                    for(j=me->nknot-1;j>i;j--)
                       me->knots[j] = me->knots[j-1];
                    me->knots[i] = proparms.u; 
                    inserted = TRUE;
                  }
               }             
               me->mfp.nspans = me->nknot - (2 * me->mfp.order) + 1;
               me->mfp.npole = me->mfp.nspans + me->mfp.order -1;
               FIg_set_value(me->mainform, M_SPANS_F, 
                             (IGRdouble) me->mfp.nspans);            
               FIg_set_value(me->mainform, M_POLES_F, 
                             (IGRdouble) me->mfp.npole);
               stat_OM = om$send(msg = message ECascrcr.draw_curve_and_tools(
                                       &msg_loc),
                                 targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_curve_and_tools",command_end);
               stat_OM = om$send(msg = message ECascrcr.draw_knot(
                                       &msg_loc,
                                       TRUE),
                                 targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_knot",command_end);

               goto command_end;


	    case PROCESS_DEL_KNOT:
               if(me->knots[vix] == 0.0 || me->knots[vix] == 1.0) {
                 put_msg(&me->mainform,M_MSG_F, KNOT_NOT_TOSELECT);
                 goto command_end;
               }
               stat_OM = om$send(msg = message ECascrcr.draw_knot(
                                       &msg_loc,
                                       FALSE),
                                 targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_knot",command_end);
               me->nknot -=1;
               for(i=me->vix;i<me->nknot;i++) 
                 me->knots[i] = me->knots[i+1];
               me->mfp.nspans = me->nknot - (2 * me->mfp.order) + 1;
               me->mfp.npole = me->mfp.nspans + me->mfp.order -1;
               FIg_set_value(me->mainform, M_SPANS_F, 
                             (IGRdouble) me->mfp.nspans);            
               FIg_set_value(me->mainform, M_POLES_F, 
                             (IGRdouble) me->mfp.npole);
               stat_OM = om$send(msg = message ECascrcr.draw_curve_and_tools(
                                       &msg_loc),
                                 targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_curve_and_tools",command_end);
               stat_OM = om$send(msg = message ECascrcr.draw_knot(
                                       &msg_loc,
                                       TRUE),
                                 targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_knot",command_end);

               goto command_end;
	    
            case PROCESS_DUPL_KNOT:
               put_msg(&me->mainform,M_MSG_F,SELECT_KNOT_TODUP);
               me->XXXXX = 1357;
               if(me->knots[vix] == 0.0 || me->knots[vix] == 1.0) {
                 put_msg(&me->mainform,M_MSG_F, KNOT_NOT_TOSELECT);
                 goto command_end;
               }
               stat_OM = om$send(msg = message ECascrcr.draw_knot(
                                       &msg_loc,
                                       FALSE),
                                 targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_knot",command_end);
               c = 1; 
               sknot = me->knots[me->vix];
               for(i=me->vix+1;i<me->nknot;i++) {
                  if(sknot == me->knots[i])
                    c += 1;
	       }
               if(c == me->mfp.order - 1) {   
                 put_msg(&me->mainform,M_MSG_F, KNOT_DUPLICATES_LIMIT);
                 goto command_end;
               }
               me->nknot += 1;
               /* compute new knot vector */

               c = om$dimension_of(varray = me->knots); 
               if (me->nknot > c) {
                  stat_OM = om$vla_set_dimension(varray = me->knots,
                                   size = me->nknot);
                  TEST_ERROR(stat_OM,stat_OM,"ECascrcr.vla_set_dimension",command_end);
               }
               for(i=me->nknot-1;i>me->vix+1;i--)
                  me->knots[i] = me->knots[i-1];
               me->knots[vix+1] = me->knots[vix];
               me->mfp.nspans = me->nknot - (2 * me->mfp.order) + 1;
               me->mfp.npole = me->mfp.nspans + me->mfp.order -1;
               FIg_set_value(me->mainform, M_SPANS_F, (IGRdouble) me->mfp.nspans);            FIg_set_value(me->mainform, M_POLES_F, (IGRdouble) me->mfp.npole);
               stat_OM = om$send(msg = message ECascrcr.draw_curve_and_tools(
                                       &msg_loc),
                                 targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_curve_and_tools",command_end);
               stat_OM = om$send(msg = message ECascrcr.draw_knot(
                                       &msg_loc,
                                       TRUE),
                                 targetid = my_id);
               TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_knot",command_end);

               goto command_end;



	    case PROCESS_MOVE_KNOT:
               if(me->knots[vix] == 0.0 || me->knots[vix] == 1.0) {
                 put_msg(&me->mainform,M_MSG_F, KNOT_NOT_TOSELECT);
                 goto command_end;
               }
                  
               stat_OM = om$send( msg = message GRvg.GRgetsize(
                             &msg_loc,
                             &me->md_env.md_env.matrix_type,
                             me->md_env.md_env.matrix,
                             &size ),
                       targetos = me->curve_id.osnum,
                       targetid = me->curve_id.objid );


               closest_crv_geom = (struct IGRbsp_curve *) stackalloc( size );
               if(!closest_crv_geom)
                 REPORT_ERROR(stat_OM,OM_E_NODYNMEM,
                    "stackalloc(closest_crv_geom)", command_end);
 
               stat_OM = om$send( msg = message GRvg.GRgetgeom(
                             &msg_loc,
                             &me->md_env.md_env.matrix_type,
                             me->md_env.md_env.matrix,
                             (IGRchar *)closest_crv_geom ),
                       targetos = me->curve_id.osnum,
                       targetid = me->curve_id.objid );
              mdis = me->active_display;
              mdis.color = (short unsigned)me->cv.sknt_fm.ptsc;
              mdis.weight = (IGRuchar) me->cv.sknt_fm.ptsw;
              k = 1;
              stat_OM = ECdisplayPointSetByBuffer(
                         &msg_loc,
                         mdis,
                         me->md_env,
                         my_id,
                         k,
                         mvpt,
                         FALSE);

              Create_point_dynamics_buffer(mvpt, 
                                           closest_crv_geom,
                                           &me->mainform, 
                                           me->cv.sknt_fm.ptsc,
                                           me->cv.sknt_fm.ptsw,
                                           &sknot);
              me->accev.event.button.x = mvpt[X];
              me->accev.event.button.y = mvpt[Y];
              me->accev.event.button.z = mvpt[Z];
              me->sknot = sknot;
              me->XXXXX= 5020;
              ME.super_cmd->state = me->commandstate = 
                       GET_KMOVE_POINT;
              goto command_end;


	    case PROCESS_MOVE_VERTEX:


              stat_OM = om$send(msg = message ECascrcr.det_neighb2(
                                       &msg_loc,
                                       row,
                                       &no_pts,
                                       dypts),
                                targetid = my_id);
                     
              me->XXXXX = 9119;    
              me->no_pts = no_pts;
              me->edt_row = row;
              me->edt_pos = pos;
              Create2_line_dynamics_buffer(&no_pts,dypts);
              me->ev[0].event.button.x = dypts[X2];
              me->ev[0].event.button.y = dypts[Y2];
              me->ev[0].event.button.z = dypts[Z2];
              ME.super_cmd->state = me->commandstate = 
                       GET_MOVE_POINT;
              goto command_end;


	    case PROCESS_INSERT_VERTEX:
              if(me->blank_row) {
                put_msg(&me->edtform,E_MSG_F, SEL_IN_TABL);
                goto command_end;
              }
              me->something_done = TRUE;
              boreline.point1 = pnt1;
              boreline.point2 = pnt2;
              EFboreline(&msg_loc,my_id, &me->accev, &boreline);

              stat_OM = om$send(msg = message ECascrcr.det_neighbours(
                                       &msg_loc,
                                       pnt1,
                                       &boreline,
                                       &no_pts,
                                       dypts),
                                targetid = my_id);
              me->no_pts = no_pts;
              me->ev[0] = me->accev;
              me->ev[2] = me->accev;
              me->ev[0].event.button.x = dypts[X];
              me->ev[0].event.button.y = dypts[Y];
              me->ev[0].event.button.z = dypts[Z];
              me->ev[2].event.button.x = dypts[6];
              me->ev[2].event.button.y = dypts[7];
              me->ev[2].event.button.z = dypts[8];
              me->edt_row = row;
              me->edt_pos = pos;
              me->XXXXX = 1111;
              /*Create_line_dynamics_buffer(&me->no_pts,&me->ev[0]);*/
              Create_line_dynamics_buffer(&me->no_pts,me->ev);
              ME.super_cmd->state = me->commandstate = 
                       GET_INSERT_POINT;
              goto command_end;
          
	    case PROCESS_DELETE_VERTEX:
               pos = 0;
               stat_OM = om$send (msg = message ECascrcr.process_delete(
                                         &msg_loc,
                                         &row,
                                         &pos),
                                  targetid = my_id);
               

               break;

	     case PROCESS_TOGGLE_FIXPT:

               if(me->vxt[row].fxp[0] == '*') {
                 me->vxt[row].fxp[0] = ' ';
                 me->all_fixpts_set = FALSE;
                 FIfld_set_text(me->edtform, E_MCOL_F, row, FXC, "  ",0);
                 me->nfp -= 1;
                 me->ncon -= 1;
               } else {
                 me->vxt[row].fxp[0] = '*';
                 FIfld_set_text(me->edtform, E_MCOL_F, row, FXC, "* ",0);
                 me->nfp += 1;
                 me->ncon += 1;
                 if (!strncmp(me->mfp.knot_type,FREE_T,
                              strlen(me->mfp.knot_type))) {
                   strcpy(me->mfp.knot_type,UNIFORM_T);
                   FIg_set_text(me->mainform,M_KNOT_F,me->mfp.knot_type);
                 }
                 stat_OM = om$send(msg = message ECascrcr.comp_knot_vector(
                                         &msg_loc),
                                   targetid = my_id);
                 TEST_ERROR(stat_OM,msg_loc,"ECascrcr.comp_knot_vector", command_end);
               }
               break;


	    case PROCESS_SET_TANGENT:

               if(me->vxt[row].ta[0] == '*') {
                 stat_OM = om$send(msg = message ECascrcr.delete_tangent(
                                          &msg_loc,
                                          row),
                                   targetid = my_id);
                 put_msg(&me->edtform, E_MSG_F, TANGENT_REMOVED);
                 ex$message (msgnumb = EMS_I_TANGENT_REMOVED);
                 me->command = PROCESS_SET_TANGENT;
                 ME.super_cmd->state = me->commandstate = PROCESS;
               } else { 
                 ME.super_cmd->state = GET_TANGENT_OR_CURVATURE;
               }
               goto command_end;

	    case PROCESS_CURVATURE:
               
               if(row == 0) {
                 if(me->mfp.opt_curv0 == 0) {
                   ME.super_cmd->state = GET_TANGENT_OR_CURVATURE;
                 } else {
                   stat_OM = om$send(msg = message ECascrcr.delete_curvature(
                                            &msg_loc,
                                            row),
                                     targetid = my_id);
                 put_msg(&me->edtform, E_MSG_F, CURVATURE_REMOVED);
                 ex$message (msgnumb = EMS_I_CURVATURE_REMOVED);
                 me->command = PROCESS_CURVATURE;
                 ME.super_cmd->state = me->commandstate = PROCESS;
                 }
               } else {
                 if(me->mfp.opt_curv1 == 0) {
                   ME.super_cmd->state = GET_TANGENT_OR_CURVATURE;
                 } else {
                   stat_OM = om$send(msg = message ECascrcr.delete_curvature(
                                            &msg_loc,
                                            row),
                                     targetid = my_id);
                 put_msg(&me->edtform, E_MSG_F, CURVATURE_REMOVED);
                 ex$message (msgnumb = EMS_I_CURVATURE_REMOVED);
                 me->command = PROCESS_CURVATURE;
                 ME.super_cmd->state = me->commandstate = PROCESS;
                 }
               }  
               goto command_end;


	    default:
               goto command_end;

	  } /* end switch me->command  */
            
            break;

          case EX_CHAR:

            ksl = me->accev.event.keyin[0];
            switch(ksl) {
              

	    case PROCESS_NEXT_LS:

               
               event_size = sizeof(struct EX_button);
               stat_func = ex$putque(
                            msg = &msg_loc,
                            pos = FRONT,
                            response = response,
                            byte = &event_size,
                            buffer = (char *) &me->accev.event.button);
               ME.super_cmd->state = me->commandstate = GET_LINESTRING;
               me->to_next_linestring = TRUE;
               goto command_end;

	    case PROCESS_DRAW_CURVE:
              
              stat_OM = om$send (msg = message ECascrcr.draw_curve_and_tools(
                                       &msg_loc),
                                 targetid = my_id);

              TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_curve_and_tools",command_end);
              FIg_set_state_off(me->mainform, M_DRCV_B);

              break;

	      case PROCESS_CURVATURE:
               if(row == 0) {
                 if(me->mfp.opt_curv0 == 0) {
                   ME.super_cmd->state = GET_TANGENT_OR_CURVATURE;
                 } else {
                   stat_OM = om$send(msg = message ECascrcr.delete_curvature(
                                            &msg_loc,
                                            row),
                                     targetid = my_id);
                 put_msg(&me->edtform, E_MSG_F, CURVATURE_REMOVED);
                 ex$message (msgnumb = EMS_I_CURVATURE_REMOVED);
                 me->command = PROCESS_CURVATURE;
                 ME.super_cmd->state = me->commandstate = PROCESS;
                 }
               } else {
                 if(me->mfp.opt_curv1 == 0) {
                   ME.super_cmd->state = GET_TANGENT_OR_CURVATURE;
                 } else {
                   stat_OM = om$send(msg = message ECascrcr.delete_curvature(
                                            &msg_loc,
                                            row),
                                     targetid = my_id);
                 put_msg(&me->edtform, E_MSG_F, CURVATURE_REMOVED);
                 ex$message (msgnumb = EMS_I_CURVATURE_REMOVED);
                 me->command = PROCESS_CURVATURE;
                 ME.super_cmd->state = me->commandstate = PROCESS;
                 }
               }  
               goto command_end;



	      case PROCESS_SET_TANGENT:

                row = me->edt_row;
                pos = me->edt_pos;

               if(me->vxt[row].ta[0] == '*') {
                 stat_OM = om$send(msg = message ECascrcr.delete_tangent(
                                          &msg_loc,
                                          row),
                                   targetid = my_id);
                 put_msg(&me->edtform, E_MSG_F, TANGENT_REMOVED);
                 ex$message (msgnumb = EMS_I_TANGENT_REMOVED);
                 me->command = PROCESS_SET_TANGENT;
                 ME.super_cmd->state = me->commandstate = PROCESS;
               } else { 
                 ME.super_cmd->state = GET_TANGENT_OR_CURVATURE;
               }
               goto command_end;
               
              case PROCESS_STOP_EDITING:
#if dflT1
                printf("stop linestring editing\n");
#endif
                break;

              case PROCESS_STOP_COMMAND:
#if dflT1
                printf("stop< command\n");
#endif
                me->commandstate = FINISH;
                *response = TERMINATE;
                goto command_end;

              default:
                if (ksl == '\374') {
                  *response = TERMINATE;
                }
                goto command_end;
            } /* switch ksl */
            break; 

          default:
            goto command_end;

      } /* switch accev->response from co$getevent  */

   } while(me->commandstate == PROCESS); 

   break;


  case GET_TANGENT_OR_CURVATURE:
#if dflT1
        printf("in GET_TANGENT_OR_CURVATURE\n");
#endif
     row = me->edt_row;
        loc_mask = GRm_CHAR |
                   GRm_RJT_MOVEON |
                   GRm_DATA | 
                   GRm_BACK_UP;
        acc_mask = GRm_CHAR |
                   GRm_DATA;

        display_flag = ALL_WINDOWS  |
                       /*LC_ACC_ONE_ELEMENT |*/
                       ELEM_HILIGHT; 
                       /*PROJ_ACCEPT_POINT;*/ 

        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

        r_classes[0] = OPP_GRbspline_class_id;
    	e_classes[0] = OPP_GRcurve_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];


  
        put_msg(&me->edtform, E_MSG_F, SEL_TANG_OR_LINE); 
        ex$message (msgnumb = EMS_P_SEL_POI_OR_LINE);
	ex$message(msgnumb = EMS_P_SEL_POI_OR_LINE, buff = loc_prompt);
        ex$message (msgnumb = EMS_I_00000);
        me->locate_on = TRUE;
    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &me->accev,
              	mask1 = loc_mask, 
              	mask2 = acc_mask,
              	eventsize= (int *)&event_size, 
              	response = response,
              	response_data = response_data, 
              	display_flag = display_flag,
              	attributes = &lc_attr, 
              	locate_prompt = loc_prompt, 
              	acc_prompt = acc_prompt,
              	stack = &ME.ECelement->locate_stack, 
              	relocate_key = EMS_I_00010); 

        me->locate_on = FALSE;
	ex$message(msgnumb = EMS_P_ClearPromptField);

          stat_OM = dp$erase_hilite(msg = &msg_loc);

        if (stat_func == FALSE) {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto command_end;
        }
        if (msg_loc == FALSE) 
          if (ME.ECelement->locev.response == EX_BACK_UP)
            break;
          else if ((ME.ECelement->locev.response == EX_RJT_MOVEON)) {
            if(PROCESS_SET_TANGENT) {
              set_gadget_active_inactive(&me->edtform, 15,
                E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
                E_EDT_B, ON, E_UNDO_B, ON, E_DEL_B, ON,
                E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
                E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
              FIg_set_state_off(me->edtform, E_TA1_B);
            }
            if(PROCESS_CURVATURE) {
              set_gadget_active_inactive(&me->edtform, 15,
                E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
                E_EDT_B, ON, E_UNDO_B, ON, E_DEL_B, ON,
                E_TA1_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
                E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
              FIg_set_state_off(me->edtform, E_CURV_B);
            }
            put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
            ex$message (msgnumb = EMS_I_00000);
            me->command = PROCESS_SELECT;
            ME.super_cmd->state = me->commandstate = PROCESS;
            goto command_end;
        }
        


        switch(me->accev.response)
        {
          
	  case EX_RJT_MOVEON:
            if(PROCESS_SET_TANGENT) {
              set_gadget_active_inactive(&me->edtform, 15,
                E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
                E_EDT_B, ON, E_UNDO_B, ON, E_DEL_B, ON,
                E_CURV_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
                E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
              FIg_set_state_off(me->edtform, E_TA1_B);
            }
            if(PROCESS_CURVATURE) {
              set_gadget_active_inactive(&me->edtform, 15,
                E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
                E_EDT_B, ON, E_UNDO_B, ON, E_DEL_B, ON,
                E_TA1_B, ON, E_SHFIX_B, ON, E_MOV_B, ON,
                E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON,0,0);
              FIg_set_state_off(me->edtform, E_CURV_B);
            }
            put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
            ex$message (msgnumb = EMS_I_00000);
            me->command = PROCESS_SELECT;
            ME.super_cmd->state = me->commandstate = PROCESS;
            goto command_end;

          case EX_DATA:
#if dflT1
     printf("in process_tangent case EX_DATA\n");
#endif
            boreline.point1 = pnt1;  /* allocates storage for */
            boreline.point2 = pnt2;  /* the boreline          */

            EFboreline(&msg_loc, my_id, &me->accev, &boreline);

            cp[X] = me->accev.event.button.x;
            cp[Y] = me->accev.event.button.y;
            cp[Z] = me->accev.event.button.z;

            stat_OM = om$send(msg = message GRgraphics.GRlnproject(
                                     &msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &boreline,
                                     cp, 
                                     ppp, 
                                     &t, 
                                     &proparms),
                    senderid = my_id,
                    targetid = me->accev.located_object[0].located_obj.objid,
                    targetos = me->accev.located_object[0].located_obj.osnum);

            TEST_ERROR(stat_OM,msg_loc,"GRlnproject",command_end);
            stat_OM = om$send(msg = message GRcurve.GRgenabsg(&msg_loc,
                            &me->md_env.md_env.matrix_type,
                            me->md_env.md_env.matrix,
                            &generic_pointer),
                      senderid = my_id,
                      targetid = me->accev.located_object[0].located_obj.objid,
                      targetos = me->accev.located_object[0].located_obj.osnum);
            
            if (!(stat_OM & OM_S_SUCCESS)) {
               put_msg(&me->edtform, M_MSG_F, WRONG_ELEMENT);
               ex$message (msgnumb = EMS_I_WRONG_ELEMENT);
               stat_OM = INFO;
               me->command = PROCESS_SELECT;
               ME.super_cmd->state = me->commandstate = PROCESS;
               goto command_end;
            }

            closest_crv_geom = (struct IGRbsp_curve *) generic_pointer;


            BScveval(closest_crv_geom, proparms.u, 2, cveval, &rc);

            if(me->command == PROCESS_SET_TANGENT) {
              stat_OM = om$send (msg = message ECascrcr.comp_and_disp_tangent(
                                        &msg_loc,
                                        row,
                                        cveval[1]),
                                 targetid = my_id);
              put_msg(&me->edtform, E_MSG_F, TANGENT_PICKED);
              ex$message (msgnumb = EMS_I_TANGENT_PICKED);
              me->command = PROCESS_SET_TANGENT;
              ME.super_cmd->state = me->commandstate = PROCESS;
	    } else if (me->command == PROCESS_CURVATURE) {
              stat_OM = om$send (msg = message ECascrcr.comp_and_disp_curvat(
                                        &msg_loc,
                                        row,
                                        cveval[2],
                                        cveval[1]),
                                 targetid = my_id);
              put_msg(&me->edtform, E_MSG_F, CURVATURE_PICKED);
              ex$message (msgnumb = EMS_I_CURVATURE_PICKED);
              me->command = PROCESS_CURVATURE;
              ME.super_cmd->state = me->commandstate = PROCESS;
            }

            goto command_end;

       default:
#if dflT1
     printf("in process_tangent case default\n");
#endif
            ME.super_cmd->state = GET_TANGENT_OR_CURVATURE;
            goto command_end;
       }



     case GET_USTART:
      #if dflT1
       printf("\nIn: ME.super_cmd->state - case GET_USTART tool = 0");
      #endif
      loc_mask = GRm_DATA | GRm_VALUE | GRm_BACK_UP;
      acc_mask = GRm_DATA | GRm_VALUE;
      ex$message(msgnumb = EMS_M_IgGvust, buff = loc_prompt);
      stat_func = co$getevent( msg = &msg_loc,
                     event_mask    = ( GRm_DATA       | GRm_VALUE   |
                                       GRm_RJT_MOVEON | GRm_BACK_UP ),
                     prompt        = loc_prompt,
                     response      = response,
                     response_data = response_data,
                     event         = &event);
      if ( stat_func==FALSE )
      {
       ex$message(msgnumb = EMS_E_FailInputProcExit);
       *response = TERMINATE;
       goto command_end;
      }
      if (msg_loc != MSSUCC)
       goto command_end;
      switch(event.response) 
      {
       case EX_BACK_UP:
       case EX_RJT_MOVEON:
        #if dflT1
         printf("\nIn: ME.super_cmd->state - case GET_USTART tool = 0");
         printf("\nIn: ME.super_cmd->state - case EX_BACK_UP:");
         printf("\nIn: ME.super_cmd->state - case EX_RJT_MOVEON:");
        #endif
        ME.super_cmd->state = PROCESS;
        goto command_end;
       case EX_DATA:
        #if dflT1
         printf("\nIn: ME.super_cmd->state - case GET_USTART tool = 0");
         printf("\nIn: ME.super_cmd->state - case EX_DATA");
        #endif    
        plt[0] = event.event.button.x; 
        plt[1] = event.event.button.y; 
        plt[2] = event.event.button.z;
        alloncv = TRUE;
        BSmdstptscv((IGRint)1, plt, crv, &me->cv.cvra_fm.ustr
                             , ppt, &dist,&alloncv, &rc);
        if ( me->cv.cvra_fm.anzn==1 )
         ME.super_cmd->state = PROCESS;
        else
         ME.super_cmd->state = GET_UEND;
       break;
       case EX_VALUE:
        #if dflT1
         printf("\nIn: ME.super_cmd->state - case GET_USTART tool = 0");
         printf("\nIn: ME.super_cmd->state - case EX_VALUE");
        #endif
        me->cv.cvra_fm.ustr = event.event.value;
        if ( me->cv.cvra_fm.anzn )
         ME.super_cmd->state = PROCESS;
        else
         ME.super_cmd->state = GET_UEND;
       break;
      }
      #if dflT1
       printf("\nEnde  : ME.super_cmd->state case PROCESS tool = 0");
      #endif
     break; 
           
     case GET_UEND:
      #if dflT1
       printf("\nStart : ME.super_cmd->state - case GET_UEND tool = 0");
      #endif
      loc_mask = GRm_DATA | GRm_VALUE | GRm_BACK_UP;
      acc_mask = GRm_DATA | GRm_VALUE;
      ex$message(msgnumb = EMS_M_IgGvuen, buff = loc_prompt);
      stat_func = co$getevent ( msg = &msg_loc,
                      event_mask    = ( GRm_DATA | GRm_VALUE |
                                        GRm_RJT_MOVEON | GRm_BACK_UP),
                      prompt        = loc_prompt,
                      response      = response,
                      response_data = response_data,
                      event         = &event);
      if ( stat_func==FALSE )
      {
       ex$message(msgnumb = EMS_E_FailInputProcExit);
       *response = TERMINATE;
       goto command_end;
      }
      if ( msg_loc!=MSSUCC )
       goto command_end;
      switch(event.response) 
      {
       case EX_BACK_UP:
       case EX_RJT_MOVEON:
        #if dflT1
         printf("\nStart : ME.super_cmd->state case PROCESS tool = 0");
         printf("\ncase EX_BACK_UP: case EX_RJT_MOVEON:");
        #endif
        ME.super_cmd->state = GET_USTART;
        goto command_end;
       case EX_DATA:
        #if dflT1
         printf("\ncase EX_DATA tool = 0");
        #endif
        plt[0] = event.event.button.x; 
        plt[1] = event.event.button.y; 
        plt[2] = event.event.button.z;
        alloncv = TRUE;
        BSmdstptscv((IGRint)1,plt, crv, &me->cv.cvra_fm.uend
                             ,ppt,&dist, &alloncv, &rc);
        ME.super_cmd->state = PROCESS;
       break;
       case EX_VALUE:
        #if dflT1
         printf("\ncase EX_VALUE tool = 0");
        #endif
        me->cv.cvra_fm.uend = event.event.value;
        ME.super_cmd->state = PROCESS;
       break;
      }
      #if dflT1
       printf("\nEnde  : ME.super_cmd->state - case GET_UEND tool = 0");
      #endif
     break;            
     case GET_UPAR:
      #if dflT1
       printf("\nStart : ME.super_cmd->state - case GET_UPAR tool = 0");
      #endif
      loc_mask = GRm_DATA | GRm_VALUE | GRm_BACK_UP;
      acc_mask = GRm_DATA | GRm_VALUE;
      ex$message(msgnumb = EMS_M_IgGvupa, buff = loc_prompt);
      stat_func = co$getevent(
                    msg           = &msg_loc,
                    event_mask    = ( GRm_DATA     | GRm_VALUE  |
                                    GRm_RJT_MOVEON | GRm_BACK_UP ),
                    prompt        = loc_prompt,
                    response      = response,
                    response_data = response_data,
                    event         = &event);
      if (stat_func == FALSE)
      {
       ex$message(msgnumb = EMS_E_FailInputProcExit);
       *response = TERMINATE;
       goto command_end;
      }
      if (msg_loc != MSSUCC)
       goto command_end;
      switch(event.response) 
      {
       case EX_BACK_UP:
       case EX_RJT_MOVEON:
        #if dflT1
         printf("\ncase EX_BACK_UP: case EX_RJT_MOVEON:"); 
        #endif
       ME.super_cmd->state = PROCESS;
        goto command_end;
       case EX_DATA:
        #if dflT1
         printf("\ncase EX_DATA:");
        #endif
        plt[0] = event.event.button.x; 
        plt[1] = event.event.button.y; 
        plt[2] = event.event.button.z;
        alloncv = TRUE;
        BSmdstptscv((IGRint)1,plt, crv, &me->cv.cvra_fm.ustr,
                              ppt,&dist, &alloncv, &rc);
        ME.super_cmd->state = PROCESS;
       break;
       case EX_VALUE:
        #if dflT1
         printf("\ncase EX_VALUE:");
        #endif 
        me->cv.cvra_fm.ustr = event.event.value;
        ME.super_cmd->state = PROCESS;
       break;
      }
      #if dflT1
       printf("\nStart : ME.super_cmd->state - case GET_UPAR tool = 0");
      #endif
     break;            
     case GET_ACCPT:
      #if dflT1
       printf("\nStart : ME.super_cmd->state - case GET_ACCPT tool = 0");
      #endif
      loc_mask = GRm_DATA | GRm_VALUE | GRm_BACK_UP;
      acc_mask = GRm_DATA | GRm_VALUE;
      ex$message(msgnumb = EMS_M_IgShpnt, buff = loc_prompt);
      stat_func = co$getevent(
                    msg = &msg_loc,
                    event_mask = (GRm_DATA       | GRm_VALUE  |
                                  GRm_RJT_MOVEON | GRm_BACK_UP),
                    prompt = loc_prompt,
                    response = response,
                    response_data = response_data,
                    event = &event);
      if (stat_func == FALSE)
      {
       ex$message(msgnumb = EMS_E_FailInputProcExit);
       *response = TERMINATE;
       goto command_end;
      }
      if (msg_loc != MSSUCC)
       goto command_end;
      switch(event.response) 
      {
       case EX_BACK_UP:
       case EX_RJT_MOVEON:
        #if dflT1
         printf("\ncase EX_EX_BACK_UP: case EX_RJT_MOVEON:"); 
        #endif 
        ME.super_cmd->state = PROCESS;
        goto command_end;
      }
      #if dflT1
       printf("\nEnde  : ME.super_cmd->state - case GET_ACCPT tool = 0");
      #endif
     break;



   case GET_INSERT_POINT:
      #if dflT1
       printf("state GET_INSERT_POINT\n");
      #endif

      stat_OM = OM_S_SUCCESS;
      event_mask = GRm_VALUE | 
                   GRm_RJT_MOVEON | 
                   GRm_DATA | 
                   GRm_BACK_UP;
      sts = co$getevent( msg = &msg,
                            event_mask = event_mask,
                            /*prompt = SECOND_PT_PROMPT,*/
                            response = (IGRlong *) response,
                            response_data = response_data,
                            event = &me->ev[1]);
      me->XXXXX = 157;
      if(*response == TERMINATE) 
                goto command_end;
      if((*response == EX_RJT_MOVEON) || !(1&sts)) {
                put_msg(&me->edtform, E_MSG_F, SEL_ROW);
                ex$message (msgnumb = EMS_P_SEL_ROW);
                set_gadget_active_inactive(&me->edtform, 16,
                 E_MCOL_F, OFF, E_EDT_B, ON, E_AFIX_B, ON,
                 E_TA1_B, ON, E_UNDO_B, ON, E_VERTEX_F, ON,
                 E_CURV_B, ON,E_DEL_B,ON, E_SHFIX_B, ON, E_MOV_B, ON,
                 E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                 E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON);
                FIg_set_state_off(me->edtform, E_INS_B);
                ME.super_cmd->state = me->commandstate = PROCESS;
                me->command = PROCESS_SELECT;
                goto command_end; 
      } 
      if(*response == EX_BACK_UP) {
                ME.super_cmd->state = me->commandstate = PROCESS;
                me->command = PROCESS_INSERT_VERTEX;
                goto command_end; 
      }
      if(*response == EX_DATA) {       
               row = me->edt_row;
               pos = me->edt_pos;
               boreline.point1 = pnt1;
               boreline.point2 = pnt2;
               boreline.point1[X] = me->ev[1].event.button.x;
               boreline.point1[Y] = me->ev[1].event.button.y;
               boreline.point1[Z] = me->ev[1].event.button.z;

               p0[X]= me->sel_pt[X];
               p0[X]= me->sel_pt[Y];
               p0[X]= me->sel_pt[Z];
               stat_OM = om$send(msg = message ECascrcr.insert_vertex(
                                        &msg_loc, 
                                        /*pnt1,*/
                                        p0,
                                        row,
                                        &boreline,
                                        &p1seg),
                                 targetid = my_id);

               me->nvx += 1;
               me->npara += 1;
               if(p1seg) 
                row += 1;

               me->XXXXX = 15773;

               FIfld_set_num_rows(me->edtform,E_MCOL_F, me->nvx);
               FIfld_insert_blank_row(me->edtform, E_MCOL_F, row);
               FIfld_set_value(me->edtform, E_MCOL_F, row, VNC,(double)row,FALSE);
               FIfld_set_value(me->edtform, E_MCOL_F, row, XC,pnt1[X],FALSE);
               FIfld_set_value(me->edtform, E_MCOL_F, row, YC,pnt1[Y],FALSE);
               FIfld_set_value(me->edtform, E_MCOL_F, row, ZC,pnt1[Z],FALSE);



               FIfld_set_num_rows(me->edtform,E_VERTEX_F, me->nvx);
               FIfld_insert_blank_row(me->edtform, E_VERTEX_F, row);
               for (i=0; i < me->nvx; i++) {
                 fvalue = (IGRdouble) i;
                 FIfld_set_value(me->edtform, E_VERTEX_F, i, 0, fvalue, 0);
                 me->vxt[i].nvno = i;
               }
               /*FIfld_set_value(me->edtform, E_VERTEX_F, me->nvx, 0, 
                              (double)0, 0);*/
               for(i=me->nvx;i>row;i--) {
                 me->vxt[i].xp = me->vxt[i-1].xp;
                 me->vxt[i].yp = me->vxt[i-1].yp;
                 me->vxt[i].zp = me->vxt[i-1].zp;
                 me->vxt[i].fxp[0] = me->vxt[i-1].fxp[0];
                 me->vxt[i].fac = me->vxt[i-1].fac;
                 me->vxt[i].ta[0] = me->vxt[i-1].ta[0];
                 me->vxt[i].tav[X] = me->vxt[i-1].tav[X];
                 me->vxt[i].tav[Y] = me->vxt[i-1].tav[Y];
                 me->vxt[i].tav[Z] = me->vxt[i-1].tav[Z];
               }

               me->vxt[row].xp = pnt1[X];
               me->vxt[row].yp = pnt1[Y];
               me->vxt[row].zp = pnt1[Z];
               me->vxt[row].ta[0] = ' ';
               me->vxt[row].fxp[0] = ' ';
               me->vxt[row].fac = 0.0;
               me->vxt[row].tav[X] = 0.0;
               me->vxt[row].tav[Y] = 0.0;
               me->vxt[row].tav[Z] = 0.0;
               FIfld_set_active_row(me->edtform, E_MCOL_F, row, pos); 
               FIfld_set_active_row(me->edtform, E_VERTEX_F, row, pos); 
               me->XXXXX = 2257;
#if dflT5
        for(i=0;i<me->nvx;i++) 
          printf("i= %d nvno= %d  vxt[i]x= %f  vxt[i]y= %f  vxt[i]z %f\n",
                 i, me->vxt[i].nvno,me->vxt[i].xp, me->vxt[i].yp, me->vxt[i].zp);
        for(i=0;i<me->nvx;i++) {
          FIfld_get_value(me->edtform,E_VERTEX_F,i,0,&fvalue,&sel,&pos);
          FIfld_get_value(me->edtform,E_MCOL_F,i,XC,&xp,&sel,&pos);
          FIfld_get_value(me->edtform,E_MCOL_F,i,YC,&yp,&sel,&pos);
          FIfld_get_value(me->edtform,E_MCOL_F,i,ZC,&zp,&sel,&pos);
          printf("i= %d nvno= %d  edtx= %f  edty= %f  edtz %f\n",
                 i, (int)fvalue,xp, yp, zp); 
        }
#endif         
               set_gadget_active_inactive(&me->edtform, 16,
                E_MCOL_F, OFF, E_EDT_B, ON, E_AFIX_B, ON,
                E_TA1_B, ON, E_UNDO_B, ON, E_VERTEX_F, ON,
                E_CURV_B, ON,E_DEL_B,ON, E_SHFIX_B, ON, E_MOV_B, ON,
                E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON);
               FIg_set_state_off(me->edtform, E_INS_B);

               me->undo_type = UNDO_COMPLETED;
               me->undo_num = 0;
               ME.super_cmd->state = me->commandstate = PROCESS;
               me->command = PROCESS_SELECT;
               put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
               ex$message (msgnumb = EMS_I_00000);
               goto command_end;
              } else { 
               goto command_end;        
	     }


   case GET_MOVE_POINT:
#if dflT1
       printf("state GET_MOVE_POINT\n");
#endif

      stat_OM = OM_S_SUCCESS;
      event_mask = GRm_VALUE | 
                   GRm_RJT_MOVEON | 
                   GRm_DATA | 
                   GRm_BACK_UP;

      sts = co$getevent( msg = &msg,
                            event_mask = event_mask,
                            /*prompt = SECOND_PT_PROMPT,*/
                            response = (IGRlong *) response,
                            response_data = response_data,
                            event = &me->ev[0]);
      if(*response == TERMINATE) 
                goto command_end;
      if((*response == EX_RJT_MOVEON) || !(1&sts)) {
                put_msg(&me->edtform, E_MSG_F, SEL_ROW);
                ex$message (msgnumb = EMS_P_SEL_ROW);
                set_gadget_active_inactive(&me->edtform, 16,
                 E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
                 E_TA1_B, ON, E_UNDO_B, ON, E_EDT_B, ON,
                 E_CURV_B, ON,E_DEL_B,ON, E_SHFIX_B, ON, E_VERTEX_F, ON,
                 E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                 E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON);
                FIg_set_state_off(me->edtform, E_MOV_B);
                ME.super_cmd->state = me->commandstate = PROCESS;
                me->command = PROCESS_SELECT;
                goto command_end; 
      }        
      if(*response == EX_BACK_UP) {
                ME.super_cmd->state = me->commandstate = PROCESS;
                me->command = PROCESS_MOVE_VERTEX;
                goto command_end; 
      }
      if(*response == EX_DATA) {       
              row = me->edt_row;
              pos = me->edt_pos;
              /*boreline.point1 = pnt1;
              boreline.point2 = pnt2;*/
              /*boreline.point1 = pnt1;
              boreline.point2 = pnt2;
              EFboreline(&msg_loc,my_id, &me->accev, &boreline);*/
              FIfld_set_value(me->edtform, E_MCOL_F, row, XC, 
                              me->ev[0].event.button.x,0); 
              FIfld_set_value(me->edtform, E_MCOL_F, row, YC, 
                              me->ev[0].event.button.y,0); 
              FIfld_set_value(me->edtform, E_MCOL_F, row, ZC, 
                              me->ev[0].event.button.z,0);
              /*FIfld_set_value(me->edtform, E_MCOL_F, row, XC, 
                              pnt1[X],0); 
              FIfld_set_value(me->edtform, E_MCOL_F, row, YC, 
                              pnt1[Y],0); 
              FIfld_set_value(me->edtform, E_MCOL_F, row, ZC, 
                              pnt1[Z],0);*/
              me->vxt[row].edt_flag = 'x';
              stat_OM = om$send(msg = message ECascrcr.process_edit(
                                       &msg_loc),
                                targetid = my_id);

               set_gadget_active_inactive(&me->edtform, 16,
                E_MCOL_F, OFF, E_INS_B, ON, E_AFIX_B, ON,
                E_TA1_B, ON, E_UNDO_B, ON, E_EDT_B, ON,
                E_CURV_B, ON,E_DEL_B,ON, E_SHFIX_B, ON, E_VERTEX_F, ON,
                E_SHTA_B, ON, E_SHCURVA_B, ON, E_DRCV_B, ON, 
                E_SIFIX_B, ON, E_ACC_B, ON, E_LSVISIBLE_B, ON);
                FIg_set_state_off(me->edtform, E_MOV_B);

               put_msg(&me->edtform, E_MSG_F, CLEAR_MSG);
               ex$message (msgnumb = EMS_I_00000);
               me->command = PROCESS_SELECT;
               ME.super_cmd->state = me->commandstate = PROCESS;
               goto command_end;
	    } else {
               goto command_end;
	    }



  case GET_REF_CURVE:
#if dflT1
        printf("in GET_REF_CURVE\n");
#endif
        loc_mask = GRm_CHAR |
                   GRm_RJT_MOVEON |
                   GRm_DATA | 
                   GRm_BACK_UP;
        acc_mask = GRm_CHAR |
                   GRm_DATA;

        display_flag = ALL_WINDOWS  |
                       /*LC_ACC_ONE_ELEMENT |*/
                       ELEM_HILIGHT; 
                       /*PROJ_ACCEPT_POINT;*/ 

        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

        r_classes[0] = OPP_GRbspline_class_id;
    	e_classes[0] = OPP_GRcurve_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];


  
        me->locate_on = TRUE;
    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &me->accev,
              	mask1 = loc_mask, 
              	mask2 = acc_mask,
              	eventsize= (int *)&event_size, 
              	response = response,
              	response_data = response_data, 
              	display_flag = display_flag,
              	attributes = &lc_attr, 
              	locate_prompt = loc_prompt, 
              	acc_prompt = acc_prompt,
              	stack = &ME.ECelement->locate_stack, 
              	relocate_key = EMS_I_00010); 

        dpmode  = GRhe;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->accev.located_object[0].located_obj.objid,
                          targetos = me->accev.located_object[0].located_obj.osnum);
       FIg_enable(me->mainform,M_ORDER_F);
       FIg_enable(me->mainform,M_SPANS_F);
       FIg_enable(me->mainform,M_POLES_F);
       FIg_enable(me->mainform,M_SMOOTH_F);
       FIg_enable(me->mainform,M_ITERA_F);
       FIg_enable(me->mainform,M_APTOL_F);
       /*if(me->command == PROCESS_SEL_REF_CURVE_PARAS)*/ 
          FIg_enable(me->mainform,M_KNOT_F);
       /*if(me->command == PROCESS_SEL_REF_CURVE_KNOTS)*/ 
          FIg_enable(me->mainform,M_PARA_F);
       FIg_enable(me->mainform,M_EDLS_B);
       FIg_enable(me->mainform,M_DRCV_B);
       FIg_enable(me->mainform,M_SHCU_B);
       FIg_enable(me->mainform,M_SGDI_B);
       FIg_enable(me->mainform,M_SHPO_B);
       FIg_enable(me->mainform,M_SHKN_B);
       FIg_enable(me->mainform,M_PDIST_B);
       FIg_enable(me->mainform,M_PCURV_B);
       FIg_enable(me->mainform,M_PPOLE_B);
       FIg_enable(me->mainform,M_PKNOT_B);
       FIg_enable(me->mainform,M_LSVISIBLE_B);
       FIg_enable(me->mainform,M_ANLS_B);
       FIg_enable(me->mainform,M_NEXTLS_B);
        me->locate_on = FALSE;
        me->reference_curve = FALSE;
	ex$message(msgnumb = EMS_P_ClearPromptField);

        if (stat_func == FALSE) {
            put_msg(&me->mainform, M_MSG_F, CLEAR_MSG);
            ex$message (msgnumb = EMS_I_WRONG_ELEMENT);
            me->wrong_element = TRUE;
            me->command = PROCESS_SELECT;
            ME.super_cmd->state = me->commandstate = PROCESS;
          	goto command_end;
        }
        if (msg_loc == FALSE) 
          if (ME.ECelement->locev.response == EX_BACK_UP) {
            me->reference_curve = TRUE;
            me->wrong_element = TRUE;
            break;
          } else if ((ME.ECelement->locev.response == EX_RJT_MOVEON)) {
            put_msg(&me->mainform, M_MSG_F, CLEAR_MSG);
            ex$message (msgnumb = EMS_I_00000);
            me->wrong_element = TRUE;
            me->command = PROCESS_SELECT;
            ME.super_cmd->state = me->commandstate = PROCESS;
            goto command_end;
        }
        

        
        switch(me->accev.response)
        {
	  case EX_RJT_MOVEON:
            put_msg(&me->mainform, E_MSG_F, CLEAR_MSG);
            ex$message (msgnumb = EMS_I_00000);
            me->command = PROCESS_SELECT;
            ME.super_cmd->state = me->commandstate = PROCESS;
            goto command_end;

          case EX_BACK_UP:
            me->reference_curve = TRUE;
            break;
          
          case EX_DATA:
#if dflT1
     printf("in get ref curve case EX_DATA\n");
#endif

           me->ref_curve_id = me->accev.located_object[0].located_obj;
            stat_OM = om$get_classid(
              objid = me->ref_curve_id.objid,
              osnum = me->ref_curve_id.osnum,
              p_classid = &class_id);
            TEST_ERROR(stat_OM,stat_OM,"ECascrcr.get_classid",command_end);
 
            stat_OM = om$is_ancestry_valid(subclassid = class_id, 
                      superclassid = OPP_GRbspline_class_id);

           if(stat_OM != OM_S_SUCCESS) {
              put_msg(&me->mainform, M_MSG_F, CLEAR_MSG);
              ex$message (msgnumb = EMS_I_WRONG_ELEMENT);
              /*me->wrong_element = TRUE;*/
              if(me->command == PROCESS_SEL_REF_CURVE_PARAS) {
                strcpy(me->mfp.para_type,me->old_para_type);
                FIg_set_text(me->mainform,M_PARA_F,me->mfp.para_type);
              } else {
                strcpy(me->mfp.knot_type,me->old_knot_type);
                FIg_set_text(me->mainform,M_KNOT_F,me->mfp.knot_type);
              }
              me->command = PROCESS_SELECT;
              ME.super_cmd->state = me->commandstate = PROCESS;
              goto command_end;
	  }
              
           if (me->command == PROCESS_SEL_REF_CURVE_KNOTS)
             stat_OM = om$send (msg = message ECascrcr.comp_knot_vector(
                                      &msg_loc),
                                targetid = my_id);
           else if(me->command == PROCESS_SEL_REF_CURVE_PARAS) 
             stat_OM = om$send (msg = message ECascrcr.comp_para_vector(
                                      &msg_loc),
                                targetid = my_id);
           put_msg(&me->mainform, E_MSG_F, CLEAR_MSG);
           ex$message (msgnumb = EMS_I_00000);
           me->command = PROCESS_SELECT;
           ME.super_cmd->state = me->commandstate = PROCESS;
           goto command_end;

        }


   case GET_KMOVE_POINT:
#if dflT1
       printf("state GET_KMOVE_POINT\n");
#endif

      stat_OM = OM_S_SUCCESS;
      event_mask = GRm_VALUE | 
                   GRm_RJT_MOVEON | 
                   GRm_DATA | 
                   GRm_BACK_UP;

      sts = co$getevent( msg = &msg,
                            event_mask = event_mask,
                            /*prompt = SECOND_PT_PROMPT,*/
                            response = (IGRlong *) response,
                            response_data = response_data,
                            event = &me->accev);
      if(*response == TERMINATE) 
                goto command_end;
      if((*response == EX_RJT_MOVEON) || !(1&sts)) {
                put_msg(&me->mainform, M_MSG_F, CLEAR_MSG);
                ME.super_cmd->state = me->commandstate = PROCESS;
                me->command = PROCESS_SELECT;
                FIg_set_state_off(me->mainform,M_KMOV_B);
                goto command_end; 
      }        
      if(*response == EX_BACK_UP) {
                ME.super_cmd->state = me->commandstate = PROCESS;
                me->command = PROCESS_MOVE_KNOT;
                goto command_end; 
      }
      if(*response == EX_DATA) { 
                j = 1;
                /*mdis = me->active_display;
                mdis.color = (short unsigned)me->cv.sknt_fm.ptsc;
                mdis.weight = (IGRuchar) me->cv.sknt_fm.ptsw;
                stat_OM = ECdisplayPointSetByBuffer(
                         &msg_loc,
                         mdis,
                         me->md_env,
                         my_id,
                         j,
                         mvpt,
                         TRUE);*/
                me->XXXXX = 7676;
                stat_OM = om$send(msg = message ECascrcr.draw_knot(
                                        &msg_loc,
                                        FALSE),
                                  targetid = my_id);
                me->knots[me->vix] = me->sknot;
                for(i=me->mfp.order;i<me->nknot-me->mfp.order;i++) {
                   if(me->knots[i] >  me->knots[i+1]) {
                     temp = me->knots[i];
                     me->knots[i] = me->knots[i+1];
                     me->knots[i+1] = temp;
                   }
		}
                for(i=me->nknot-me->mfp.order-1;i>me->mfp.order-1;i--) {
                   if(me->knots[i] <  me->knots[i-1]) {
                     temp = me->knots[i];
                     me->knots[i] = me->knots[i-1];
                     me->knots[i-1] = temp;
                   }
		}
                stat_OM = om$send(msg = message ECascrcr.draw_curve_and_tools(
                                  &msg_loc),
                targetid = my_id);
                TEST_ERROR(stat_OM,msg_loc,"ECascrcr.draw_curve_and_tools",command_end);
                stat_OM = om$send(msg = message ECascrcr.draw_knot(
                                        &msg_loc,
                                        TRUE),
                                  targetid = my_id);
 
                /*put_msg(&me->mainform, M_MSG_F, SELECT_KNOT_TOMOV);*/
                ex$message (msgnumb = EMS_I_00000);
                /*FIg_set_state_off(me->mainform,M_KMOV_B);*/
                me->command = PROCESS_MOVE_KNOT;
                ME.super_cmd->state = me->commandstate = PROCESS;
                goto command_end;
      } else {
                goto command_end;
      }

   default:
     ex$message(msgnumb = EMS_F_CommandIllegalState);
     printf ("Command is in illegal state - %d\n", ME.super_cmd->state);
     *response = TERMINATE;
     goto command_end;

   } /*  main EXECUTE cases end switch super_cmd->state */
 } while (me->commandstate != FINISH); /* end do  */

command_end:

#if dflT1
  printf("*** return end ***\n");
#endif
  return (stat_OM);
}

end implementation ECascrcr;

