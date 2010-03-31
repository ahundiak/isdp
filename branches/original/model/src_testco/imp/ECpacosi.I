/* ###################   APOGEE COMPILED   ################## */
class implementation ECpacos;
/*
History

   10/20/93   dfl , HDC creation.
   06/02/95   dfl , HDC fixes 
 */


#define dflT1 0

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
#include "bserr.h"
#include "bsicmpcvoff.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
/* #include "lcdef.h" */
#include "lcmacros.h"
#include "dpmacros.h"
#include "OMobjectcomm.h"
#include "exmacros.h"		/* ex$putqueue() */
#include "EC_M.h"
#include "EC_S.h"
#include "EC_P.h"
#include "EC_I.h"
#include "dpdef.h"
#include "dp.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMSasmacros.h"
#include "RAPdefs.h"
/* #include "exdef.h" */
/*#include "pac.h"*/

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

/* for arrow length computing ( 1/10 of window diagonal) */
#define LENGTH_FRACTION 	0.25 
#define RANGE_DIV 		0.4

/* gadget values */
#define NORMAL_TO_SURFACE	0
#define ALONG_VECTOR		1
#define NO_OFFSET		0
#define OFFSET			1


/* Forms form and gadget processing */
#define FORM1 			1
#define G_ACCEPT 		1
#define G_NORMAL_TO_SURFACE	24
#define G_ALONG_VECTOR		25
#define G_PROJECT_ONLY		27
#define G_PROJECT_AND_OFFSET	28
#define G_DISTANCE_STARTPOINT	19
#define G_DISTANCE_ENDPOINT	21
#define G_NAME_LAWCURVE         29
#define G_STARTPOINT_TXT        18
#define G_ENDPOINT_TXT          20
#define G_LAWCURVE_TXT          22


/* option Form position */
#define WLOX                    0/*750*/
#define WLOY                    50/*125*/

/* plane type for planar curves */
#define PLANE			0

/* command execute states */
#define SELECT_CURVE       	1
#define SELECT_SURFACE	 	2
#define SELECT_REFPLANE         3
#define SELECT_VECTOR           4
#define OFFSET_DIRECTION 	5
#define PROCESS         	6


#define X2                      3
#define Y2                      4
#define Z2                      5

extern OMuword 			OPP_EMScomposite_class_id;
extern OMuword 			OPP_GR3dlineseg_class_id;
extern OMuword 			OPP_GRbspline_class_id;
extern OMuword 			OPP_GRcurve_class_id;
extern OMuword 			OPP_EMSdatpln_class_id;
extern OMuword 			OPP_EMSplane_class_id;
extern OMuword 			OPP_EMSsurface_class_id;
extern OMuword 			OPP_EMSsubbs_class_id;
extern OMuword 			OPP_GRbcsubbc_class_id;
extern OMuword                  OPP_GRlinear_class_id;



from GRgraphics import 	GRlnproject, GRdisplay, GRgetrang, GRdelete, 
                       	GRgetobjinfo, GRptproject;
from GRvg import 	GRgetattr, GRdetplane, GRgeomprops, GRgetgeom, 
                 	GRgetsize, GRconstruct;
from GRcurve import 	EMcvoffset, GRgenabsg, GRmidpoint, GRendpts;
from EMSsubbs import 	EMsfcvoffset, EMsftanorm;

/*from ECcomparm import   ECputcps, ECgetcps;*/



method init (IGRint type; IGRchar *string) 
{

  IGRchar 	errmsg[EMMAXERRMSG_LEN]; 
  IGRint 	sts;
  /*int 		XXXXX;*/

#if dflT1
  printf("in init \n"); 
#endif

  me->init_on = TRUE;
  me->error_flag = FALSE;
  me->compar_var.projection_type = ALONG_VECTOR;
  me->compar_var.offset = NO_OFFSET;
  me->compar_var.dist_at_stpt = 0.0;
  me->compar_var.dist_at_ept = 0.0;
  strcpy(me->compar_var.lawcurve_name,"");
  me->sleep_state = SELECT_CURVE;

  sts = om$send (
        mode = OM_e_wrt_parent,
        msg = message ECpacos.init (type, string),
        targetid = my_id);


  strcpy (errmsg, "ECpacos.init");



  me->form_requested = FALSE;
  me->form_id = NULL_OBJID;
  me->active_form_name[0] = '\0';

  ex$message(msgnumb = EMS_I_InvkStatusFrm);

  me->make_permanent = FALSE;

  /*sts = om$send( msg = message ECelement.ECtestcps(
                        "PrAsCvOSf", 
                        (IGRchar *) &me->compar_var,
                        sizeof(struct compar_struct),
                        &me->mc_objid,
                        &me->osnum),
                 targetid = my_id);*/
  if (!(1 & sts))
     return (OM_E_ABORT);
 
  return sts;
  
}

    
method wakeup (int pos) 
{

  IGRint sts = OM_S_SUCCESS;
  /*OM_S_OBJID lisnr_id;*/

  sts = om$send (msg= message ECpacos.wakeup(pos),
                 mode = OM_e_wrt_parent,
                 targetid = my_id);

  ME.super_cmd->state = me->sleep_state;
 
#if dflT1
  printf("in wakeup\n"); 
#endif

  gr$get_associative_flag ( buffer = &me->is_associative );

  if (me->is_associative)
    GRdisplay_associative_button(TRUE);

  ex$message(msgnumb = EMS_I_InvkStatusFrm);
  GRstatus_display_button(TRUE);
   /* see if the listener object exists */

   /*
   sts = ex$get_objid_from_NOD(NODname = NOD_NAME,
                                objname = LISTENER_NAME,
                                pobjid = &lisnr_id,
                                modid = OM_GO_TransOS_0,
                                mod_osnum = OM_Gw_TransOSnum_0);

   if (sts != OM_S_SUCCESS)
     me->recording = FALSE;
   else
     me->recording = TRUE;
   */

  return sts;  

}



method sleep(int pos) 
{

    IGRint 	sts;
 
#if dflT1
  printf("in sleep\n"); 
#endif
    
    /*clear fields */
    ex$message( field=PROMPT_FIELD,
             msgnumb = EMS_P_00000 );
    ex$message( field = ERROR_FIELD,
             msgnumb = EMS_I_00000 );
    ex$message (field=MESSAGE_FIELD,
             msgnumb = EMS_I_00000 );

    if (me->is_associative)
      GRdisplay_associative_button(FALSE);

    if(me->form_requested) {
      sts = FIf_erase(me->oform);
      me->form_requested = 0;
    }

    GRstatus_display_button(FALSE);

    sts = om$send (
        mode = OM_e_wrt_parent,
        msg = message ECpacos.sleep (pos),
        targetid = my_id);

    ME.ECelement->elem_hilit = FALSE;
    me->sleep_state = ME.super_cmd->state;

    return(sts); 
}

method status_disp() {

  IGRlong 	status, EMmsg;
  IGRint	ret;
  IGRint 	ECpacos_process_form();

#if dflT1
  printf("in status_disp\n"); 
#endif

  status = OM_S_SUCCESS;
  EMmsg = 1;
  
  if(me->form_requested)
   return(status);

  ret = FIf_new (FORM1, 
                 "EMProjAsCurv", 
                 ECpacos_process_form, 
                 &me->oform);
  if (ret) {
      status = FALSE;
      goto wrapup;
  }

  ret = FIf_set_cmd_oid_os(me->oform, 
                           my_id, 
                           OM_Gw_current_OS);
  if (ret) {
      status = FALSE;
      goto wrapup;
  }

    ret = FIf_set_location (me->oform, WLOX, WLOY);
    if (ret) {
       status = FALSE;
      goto wrapup;
    }
  

    ret = FIf_display(me->oform);
    if (ret) {
     status = FALSE;
     goto wrapup;
    }

    me->form_requested = TRUE;


wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);

 ret = FIg_set_value (me->oform, G_DISTANCE_STARTPOINT, me->compar_var.dist_at_stpt);
 ret = FIg_set_value (me->oform, G_DISTANCE_ENDPOINT, me->compar_var.dist_at_ept);
 ret = FIg_set_text (me->oform, G_NAME_LAWCURVE, me->compar_var.lawcurve_name);
 if (me->compar_var.projection_type == ALONG_VECTOR) {
  ret = FIg_set_state (me->oform, G_ALONG_VECTOR, 1);
  ret = FIg_set_state (me->oform, G_NORMAL_TO_SURFACE, 0);
    me->compar_var.offset = NO_OFFSET;
    FIg_disable(me->oform, G_PROJECT_AND_OFFSET);
    FIg_disable(me->oform, G_PROJECT_ONLY);
    FIg_disable(me->oform, G_DISTANCE_STARTPOINT);
    FIg_disable(me->oform, G_DISTANCE_ENDPOINT);
    FIg_disable(me->oform, G_NAME_LAWCURVE);
    FIg_disable(me->oform, G_STARTPOINT_TXT);
    FIg_disable(me->oform, G_ENDPOINT_TXT);
    FIg_disable(me->oform, G_LAWCURVE_TXT);
 } else {
  ret = FIg_set_state (me->oform, G_ALONG_VECTOR, 0);
  ret = FIg_set_state (me->oform, G_NORMAL_TO_SURFACE, 1);
    FIg_enable(me->oform, G_PROJECT_AND_OFFSET);
    FIg_enable(me->oform, G_PROJECT_ONLY);
    FIg_enable(me->oform, G_DISTANCE_STARTPOINT);
    FIg_enable(me->oform, G_DISTANCE_ENDPOINT);
    FIg_enable(me->oform, G_NAME_LAWCURVE);
    FIg_enable(me->oform, G_STARTPOINT_TXT);
    FIg_enable(me->oform, G_ENDPOINT_TXT);
    FIg_enable(me->oform, G_LAWCURVE_TXT);
 }
 if (me->compar_var.offset == NO_OFFSET) {
  ret = FIg_set_state (me->oform, G_PROJECT_ONLY, 1);
  ret = FIg_set_state (me->oform, G_PROJECT_AND_OFFSET, 0);
 } else {
  ret = FIg_set_state (me->oform, G_PROJECT_ONLY, 0);
  ret = FIg_set_state (me->oform, G_PROJECT_AND_OFFSET, 1);
 }
  
  return (status); 
}


IGRint ECpacos_process_form (form_label, gadget_label, value,
form_ptr) 
  int form_label, gadget_label; double value; Form form_ptr; 
{

  IGRint stat_func, stat_OM;
  IGRlong msg_loc;
  GRobjid cmdobj;
  GRspacenum cmdos;


#if dflT1
  printf("in process form\n"); 
#endif

  stat_OM = OM_S_SUCCESS;

  stat_func = FIf_get_cmd_oid_os (form_ptr, &cmdobj, &cmdos);
  if (stat_func)
    return (OM_E_ABORT);

  stat_OM = om$send (msg = message ECpacos.do_form (&msg_loc,
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


method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value) 
{

 IGRlong        sts;
 IGRdouble	dists,
                diste;
 IGRchar        lawcurve_name[MAX_CHAR + 1];
 /* int XXXXX; */
 IGRint toggle;
 IGRint ret;

 sts = OM_S_SUCCESS;

 if (form_label == FORM1) {
 switch (gadget_label)
  {

   case G_ACCEPT:

    ret = FIg_get_state(me->oform, G_ALONG_VECTOR,
        &toggle);
    if (toggle == TRUE) 
      me->compar_var.projection_type = ALONG_VECTOR;
    else
      me->compar_var.projection_type = NORMAL_TO_SURFACE;
 
    ret = FIg_get_state(me->oform, G_PROJECT_ONLY,
                        &toggle);
    if (toggle == TRUE)
       me->compar_var.offset = NO_OFFSET;
    else
       me->compar_var.offset = OFFSET;


    FIg_get_value(me->oform,G_DISTANCE_ENDPOINT,&diste);
    FIg_get_value(me->oform,G_DISTANCE_STARTPOINT,&dists);
    FIg_get_text(me->oform,G_NAME_LAWCURVE,lawcurve_name);
    me->compar_var.dist_at_stpt = dists;
    me->compar_var.dist_at_ept = diste;
    strcpy(me->compar_var.lawcurve_name, lawcurve_name);   

#if dflT1
    printf ("project type toggle %d\n", me->compar_var.projection_type);
    printf ("offset toggle %d\n", me->compar_var.offset);
#endif

    if(me->compar_var.projection_type == ALONG_VECTOR)
      if(me->compar_var.offset == NO_OFFSET) {
        ex$message(msgnumb = EMS_I_PdPp4)
      } else {
        ex$message(msgnumb = EMS_I_PdPp2)
      }
    else
      if(me->compar_var.offset == NO_OFFSET) {
        ex$message(msgnumb = EMS_I_PdPp3)
      } else
        ex$message(msgnumb = EMS_I_PdPp1);
    if(me->form_requested) {
      FIf_erase(me->oform);
      me->form_requested = FALSE;
    }
    me->error_flag = FALSE;

    break;

   case G_ALONG_VECTOR:
#if dflT1
    printf("along vector button pressed \n");
#endif
    FIg_disable(me->oform, G_PROJECT_AND_OFFSET);
    FIg_disable(me->oform, G_PROJECT_ONLY);
    FIg_disable(me->oform, G_DISTANCE_STARTPOINT);
    FIg_disable(me->oform, G_DISTANCE_ENDPOINT);
    FIg_disable(me->oform, G_NAME_LAWCURVE);
    FIg_disable(me->oform, G_STARTPOINT_TXT);
    FIg_disable(me->oform, G_ENDPOINT_TXT);
    FIg_disable(me->oform, G_LAWCURVE_TXT);
    break;

   case G_NORMAL_TO_SURFACE:
#if dflT1
    printf("normal to surface button pressed \n");
#endif
    FIg_enable(me->oform, G_PROJECT_AND_OFFSET);
    FIg_enable(me->oform, G_PROJECT_ONLY);
    FIg_enable(me->oform, G_DISTANCE_STARTPOINT);
    FIg_enable(me->oform, G_DISTANCE_ENDPOINT);
    FIg_enable(me->oform, G_NAME_LAWCURVE);
    FIg_enable(me->oform, G_STARTPOINT_TXT);
    FIg_enable(me->oform, G_ENDPOINT_TXT);
    FIg_enable(me->oform, G_LAWCURVE_TXT);
    break;


   case G_PROJECT_ONLY:
#if dflT1
    printf("project only button pressed \n");
#endif
    break;

   case G_PROJECT_AND_OFFSET:
#if dflT1
    printf("project and offset button pressed \n");
#endif
    break;

   case G_DISTANCE_STARTPOINT:
    FIg_get_value(me->oform,G_DISTANCE_STARTPOINT,&dists);
#if dflT1
    printf("distance at startpoint %f\n", dists);
#endif
    break;

   case G_DISTANCE_ENDPOINT:

    FIg_get_value(me->oform,G_DISTANCE_ENDPOINT,&diste);
#if dflT1
    printf("distance at endpoint %f\n", diste);
#endif

    break;

   case G_NAME_LAWCURVE:

    FIg_get_text (me->oform,G_NAME_LAWCURVE, lawcurve_name);
#if dflT1
    printf("lawcurve name  %s\n", lawcurve_name);
#endif
    break;
   
   default:
    ret = FIf_erase(me->oform);
    me->form_requested = FALSE;

    break;


 } /* end switch (gadget_label) */ 
}

 return(OM_S_SUCCESS); 
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean 		wo;
  IGRboolean            stat_func;
  IGRboolean            escape;
  /*IGRboolean            in_world_system = TRUE;*/

  int 			XXXXX;
  IGRint 		point_size;
  IGRint 		display_flag;

  IGRchar		ksl;
  IGRchar 		errmsg[EMMAXERRMSG_LEN]; 
  IGRchar               classname[OM_K_MAXCLASS_LEN];
  IGRchar 		loc_prompt[54], 
                        acc_prompt[54], 
                        reloc_prompt[54];
  IGRlong 		ret_stat;
  IGRlong 		event_size;
  IGRlong 		stat_OM, msg_loc, sts;
  IGRlong 		loc_mask, acc_mask;

  IGRdouble		range[6];
  IGRdouble 		vwvolume[6];
  IGRdouble             norm_pts1[6], norm_pts2[6]; /* PACOS */
  IGRvector 		plane_normal; 

  IGRpoint              start_pnt, 
                        end_pnt, 
                        proj_start_pnt, 
                        proj_end_pnt; /* PACOS */
  IGRpoint 		plane_point;

  IGRvector             norm_vec1, norm_vec2; /* PACOS */
  struct GRparms        proj_parms1, proj_parms2; /* PACOS */  
  struct GRevent 	accev, 
                        event;
  struct GRlc_locate 	lc_attr;
  struct GRvg_construct const_list;
  struct IGRplane 	plane;
  struct GRprops 	geom_props;
  struct var_list 	var_list_of[2];
  enum GRdpmode 	dpmode;
  OM_S_CLASSLIST 	rtree_classes, eligible_classes;
  OMuword 		r_classes[5], 
                        e_classes[5];

  extern IGRdouble 	BSdotp();
  extern void           GRput_keybuff();
  extern IGRint         FI_process_forms();
  extern IGRdouble      fabs(IGRdouble);
  extern IGRdouble 	BSdistptpt();
  /*extern void 		BScveval();*/
  extern IGRboolean 	BSnorvec();
  extern IGRboolean 	BScrossp();
  extern IGRboolean     BSfreecv(),
                        BSplane3pt(), 
			BSprj_cv_pl();

  extern void		BSallocv();
  extern IGRint LCdef_cursor();
  extern IGRint LCrestore_cursor();
  extern IGRint 	EMgetvggeom(IGRlong *, IGRshort *,IGRmatrix,
                                    struct GRid *,IGRchar **, IGRint *);

#if dflT1
  printf("in execute\n");
#endif

  ex$message(msgnumb = EMS_P_ClearPromptField);
  ex$message(msgnumb = EM_M_PrAsCrSr);
 
  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  escape = FALSE;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECpacos.execute");

  do 
    {
    switch (ME.super_cmd->state)
      {
      case SELECT_CURVE:

#if dflT1
  printf("in execute state SELECT CURVE\n");
#endif

        if (ME.ECelement->elem_hilit) {
          stat_OM = dp$erase_hilite(msg = &msg_loc);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
        }

        event.event.keyin[0] = '\0';

	ex$message(msgnumb = EMS_P_PcCv, buff = loc_prompt);

        if(! me->error_flag) {
           if (me->compar_var.projection_type == ALONG_VECTOR)
             if(me->compar_var.offset == NO_OFFSET)
               ex$message(msgnumb = EMS_I_PdPp4)
             else
               ex$message(msgnumb = EMS_I_PdPp2)
           else 
             if(me->compar_var.offset == NO_OFFSET)
               ex$message(msgnumb = EMS_I_PdPp3)
             else
               ex$message(msgnumb = EMS_I_PdPp1);
        }
        LCdef_cursor();
        me->error_flag = FALSE;
        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
        stat_func = co$getevent(
                  msg = &msg_loc,
                  mode = EX_ALL_CHAR_MODE | EX_LINE_MODE,
                  event_mask = (GRm_STRING | 
                                GRm_DATA |
                                /*GRm_CHAR | */
                                GRm_RJT_MOVEON | 
                                GRm_BACK_UP),
                  prompt = loc_prompt,
                  response = response,
                  response_data = response_data,
                  event = &event);
        LCrestore_cursor();
        if (stat_func == FALSE) {
#if dflT1
printf("in co$getevent stat_func = false\n");
#endif
                    
	  	    ex$message(msgnumb = EMS_E_FailInputProcExit);
          	    *response = TERMINATE;
          	    goto ret_end;
        }
        if (msg_loc != MSSUCC) {
#if dflT1
printf("in co$getevent msg_loc != MSSUCC\n");
#endif
          goto ret_end;
        }



        switch(*response) 
        {
          case EX_BACK_UP:
          case EX_RJT_MOVEON:
#if dflT1
printf("in co$getevent ex backup\n");
#endif
            ME.super_cmd->state = SELECT_CURVE;

            goto ret_end;


          case EX_DATA:
        

            event_size = sizeof(struct EX_button);
            stat_func = ex$putque(
                            msg = &msg_loc,
                            pos = FRONT,
                            response = response,
                            byte = &event_size,
                            buffer = (char *) &event.event.button);
            break;



          case EX_CHAR:
          case EX_STRING:
#if dflT1
printf("in co$getevent ex_char\n");
#endif
            ksl = response_data[0];
            if (ksl == '\033') { /* escape */
              event.event.keyin[0] = ksl;
              event.event.keyin[1] = '\0';
              GRput_keybuff(event.event.keyin);
              ex$message(field=KEYIN_FIELD,msgnumb=EMS_I_escape);
              break;
            } 
            if(ksl != 'o' && ksl != 'p' && ksl != 'v' && ksl != 'n') 
              goto ret_end;


            if ((ksl == 'o') && 
                      (me->compar_var.projection_type == NORMAL_TO_SURFACE)) 
              me->compar_var.offset = OFFSET;
            else if (ksl == 'p')
              me->compar_var.offset = NO_OFFSET;
            else if (ksl == 'v') {
              me->compar_var.projection_type  = ALONG_VECTOR;
              me->compar_var.offset = NO_OFFSET;
            } else if (ksl == 'n') {
              me->compar_var.projection_type = NORMAL_TO_SURFACE;
            };

            event.event.keyin[1] = '\013';
            GRput_keybuff(event.event.keyin);
            response_data[0] = '\0';
            /* event.event.keyin[0] = '\0';*/
            
          default:
#if dflT1
printf("in co$getevent default\n");
#endif
            goto ret_end;
        } 
              


        loc_mask = GRm_DATA |
                   GRm_BACK_UP;
        acc_mask = GRm_DATA;

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
                       PROJ_ACCEPT_POINT; 
                     /*  LC_ACC_ONE_ELEMENT; */


        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

        r_classes[0] = OPP_GRbspline_class_id;
    	e_classes[0] = OPP_GRcurve_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];

    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &accev,
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

	/*ex$message(msgnumb = EMS_I_ClearStatusField);
	ex$message(msgnumb = EMS_P_ClearPromptField);*/

        if (stat_func == FALSE)
          {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
          }
        if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
            break;
          else
            goto ret_end;
          }


        switch (accev.response)
          {
          case EX_DATA:
            ME.ECpacos->curve_info = accev.located_object[0];
            ME.ECelement->elem_hilit = TRUE;
            ME.ECelement->elem.located_obj.objid = accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = accev.located_object[0].
                                         located_obj.osnum;
            /* determine class name */

            stat_OM = om$get_classname (objid = ME.ECelement->elem.located_obj.objid,
                                        osnum = ME.ECelement->elem.located_obj.osnum,
                                        classname = classname);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);


            stat_OM = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &geom_props),
                              senderid = my_id,
                              targetid = ME.ECelement->elem.located_obj.objid,
                              targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
            
            me->phy_closed = geom_props.phy_closed ? TRUE : FALSE;
            me->is_planar = geom_props.planar ? TRUE : FALSE;


            ME.super_cmd->state = SELECT_SURFACE;
            /*ex$message(msgnumb = EMS_M_SsOp);*/

            break;


          default:
#if dflT1
printf("in lc$locate default\n");
#endif
            goto ret_end;
          }
        
          break;



      case SELECT_SURFACE:
#if dflT1
  printf("in execute state SELECT_SURFACE\n");
#endif

        dpmode  = GRhhd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->curve_info.located_obj.objid,
                          targetos = me->curve_info.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                              ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        ex$message(msgnumb = EMS_P_AcwSMv, buff = loc_prompt);
        /*ex$message(msgnumb = POC_P_GetOrPlaneRej, buff = loc_prompt);*/
    
        if(! me->error_flag) {
           if (me->compar_var.projection_type == ALONG_VECTOR)
             if(me->compar_var.offset == NO_OFFSET)
               ex$message(msgnumb = EMS_I_PdPp4)
             else
               ex$message(msgnumb = EMS_I_PdPp2)
           else 
             if(me->compar_var.offset == NO_OFFSET)
               ex$message(msgnumb = EMS_I_PdPp3)
             else
               ex$message(msgnumb = EMS_I_PdPp1);
        }

        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY |
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        loc_mask = GRm_DATA | 
                   GRm_RJT_MOVEON |
                   GRm_BACK_UP;

        acc_mask = GRm_DATA | 
                   GRm_BACK_UP;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       /*LC_ACC_ONE_ELEMENT | */
                       LC_ERASE_LOC_ELEMENT;
 
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0]   = OPP_EMSsubbs_class_id;
       e_classes[0] = OPP_EMSsubbs_class_id;
       lc_attr.owner_action = lc_attr.owner_action | LC_HANDLES;
        

        *response = 1;
        response_data[0] = '\0';

        stat_func = lc$locate(rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &accev,
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

	/*ex$message(msgnumb = EMS_I_ClearStatusField);*/
	/*ex$message(msgnumb = EMS_P_ClearPromptField);*/ 
        if (stat_func == FALSE)
        {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
        }

        if (msg_loc == FALSE)
        {
          if (ME.ECelement->locev.response == EX_BACK_UP) {
            ME.super_cmd->state = SELECT_CURVE;
            break;
          }
        }; /* else
            goto ret_end;
        }*/

        switch (*response)
        {
         case EX_DATA:
            
            me->project_onto_refplane = FALSE;
            me->surface_info = accev.located_object[0];
            /* half highlight curve */
            dpmode  = GRhhd;
            stat_OM = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay (&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &dpmode, &me->md_env.md_id),
                              senderid = my_id,
                              targetid = me->curve_info.located_obj.objid,
                              targetos = me->curve_info.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
            ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            /* highlight plane */
            dpmode  = GRhd;
            stat_OM = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay (&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &dpmode, &me->md_env.md_id),
                              senderid = my_id,
                              targetid = me->surface_info.located_obj.objid,
                              targetos = me->surface_info.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);


            if (me->compar_var.projection_type == ALONG_VECTOR)
               ME.super_cmd->state = SELECT_VECTOR;
            else
               if (me->compar_var.offset == NO_OFFSET)
                 ME.super_cmd->state = PROCESS;
               else
                 ME.super_cmd->state = OFFSET_DIRECTION;
       

            break;

        case EX_RJT_MOVEON:
#if dflT1
 printf("in SELECT SURFACE: EX_RJT_MOVEON\n");
#endif
            ME.super_cmd->state = SELECT_REFPLANE;
            break;

	default:
#if dflT1
 printf("in SELECT SURFACE: default\n");
#endif
            goto ret_end;
        }
        break;


      case SELECT_REFPLANE:
#if dflT1
  printf("in execute state SELECT REFPLANE\n");
#endif

 
        ex$message(msgnumb = EMS_P_SeRfPl, buff =loc_prompt);
        dpmode  = GRhhd;
        stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (
                                 &msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, 
                                 &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->curve_info.located_obj.objid,
                          targetos = me->curve_info.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                              ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        /*me->compar_var.offset = NO_OFFSET;*/
        if(! me->error_flag) {
           if (me->compar_var.projection_type == ALONG_VECTOR)
             if(me->compar_var.offset == NO_OFFSET)
               ex$message(msgnumb = EMS_I_PdPp4)
             else
               ex$message(msgnumb = EMS_I_PdPp2)
           else 
             if(me->compar_var.offset == NO_OFFSET)
               ex$message(msgnumb = EMS_I_PdPp3)
             else
               ex$message(msgnumb = EMS_I_PdPp1);
        }
    

        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY |
                             LC_PLANAR_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER;

        loc_mask = GRm_DATA | 
                   GRm_BACK_UP;

        acc_mask = GRm_DATA | 
                   GRm_BACK_UP;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       LC_ACC_ONE_ELEMENT | 
                       LC_ERASE_LOC_ELEMENT;
 
        rtree_classes.w_count = 1;
        eligible_classes.w_count = 2;
        r_classes[0] = OPP_GRvg_class_id;
        e_classes[0] = OPP_EMSsubbs_class_id;
        e_classes[1] = OPP_EMSdatpln_class_id;
        e_classes[2] = OPP_EMSplane_class_id;

        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

        rtree_classes.p_classes = &r_classes[0];
        eligible_classes.p_classes = &e_classes[0];

        /*lc_attr.properties = lc_attr.properties | LC_PLANAR_ONLY;*/
        lc_attr.owner_action = lc_attr.owner_action | LC_HANDLES;

        

        stat_func = lc$locate(rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &accev,
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

        if (stat_func == FALSE)
        {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
        }


        if (msg_loc == FALSE)
        {
          if (ME.ECelement->locev.response == EX_BACK_UP) {
            ME.super_cmd->state = SELECT_CURVE;
            break;
        } else
            goto ret_end;
        }

        switch (accev.response)
        {
         case EX_DATA:
            
            me->project_onto_refplane = TRUE;
            me->surface_info = accev.located_object[0];

            /* highlight plane */
            dpmode  = GRhd;
            stat_OM = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay (&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &dpmode, &me->md_env.md_id),
                              senderid = my_id,
                              targetid = me->surface_info.located_obj.objid,
                              targetos = me->surface_info.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);


            /*determine plane normal */
            plane.point = (IGRdouble *) &plane_point[0];
            plane.normal = (IGRdouble *) &plane_normal[0];
            stat_OM = om$send(mode = OM_e_wrt_object,
                              msg = message GRvg.GRdetplane(&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &plane),
                              senderid = my_id,
                              targetid = me->surface_info.located_obj.objid,
                              targetos = me->surface_info.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);

            me->vector[X] = plane.normal[X];
            me->vector[Y] = plane.normal[Y];
            me->vector[Z] = plane.normal[Z]; 

           if (me->compar_var.projection_type == ALONG_VECTOR)
               ME.super_cmd->state = SELECT_VECTOR;
            else
               if (me->compar_var.offset == NO_OFFSET)
                 ME.super_cmd->state = PROCESS;
               else
                 ME.super_cmd->state = OFFSET_DIRECTION;

            break;

          case EX_RJT_MOVEON:
            ME.super_cmd->state = SELECT_SURFACE;
            break;

          default:
            goto ret_end;

	  }


        break;

      case SELECT_VECTOR:
#if dflT1
printf("case SELECT VECTOR\n");
#endif


        loc_mask = GRm_DATA | 
                   GRm_BACK_UP;
        acc_mask = GRm_DATA;

	ex$message(msgnumb = EMS_P_SeVec, buff = loc_prompt);

        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
    
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
                       PROJ_ACCEPT_POINT; 
                       /*LC_ACC_ONE_ELEMENT;*/


        rtree_classes.w_count = 1;
        eligible_classes.w_count = 1;
        rtree_classes.w_flags = eligible_classes.w_flags 
                              = OM_CLST_subclass;

        r_classes[0] = OPP_GRbspline_class_id;
    	e_classes[0] = OPP_GRlinear_class_id;

    	rtree_classes.p_classes = &r_classes[0];
    	eligible_classes.p_classes = &e_classes[0];

    	stat_func = lc$locate(
              	rc = &msg_loc,
              	event1 = &ME.ECelement->locev, 
              	event2 = &accev,
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

	/*ex$message(msgnumb = EMS_I_ClearStatusField);
	ex$message(msgnumb = EMS_P_ClearPromptField);*/

        if (stat_func == FALSE)
          {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
          }
        if (msg_loc == FALSE)
          {
          if (ME.ECelement->locev.response == EX_BACK_UP)
            break;
          else
            goto ret_end;
          }


        switch (accev.response)
          {
          case EX_DATA:
            ME.ECpacos->vector_info = accev.located_object[0];
            dpmode  = GRhd;
            stat_OM = om$send(mode = OM_e_wrt_object,
                          msg = message GRgraphics.GRdisplay (&msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                          targetid = me->vector_info.located_obj.objid,
                          targetos = me->vector_info.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
            ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
            ME.ECelement->elem.located_obj.objid = accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = accev.located_object[0].
                                         located_obj.osnum;
            /* determine class name */

            /*stat_OM = om$get_classname (objid = ME.ECelement->elem.located_obj.objid,
                                        osnum = ME.ECelement->elem.located_obj.osnum,
                                        classname = classname);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);*/


            /*stat_OM = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &geom_props),
                              senderid = my_id,
                              targetid = ME.ECelement->elem.located_obj.objid,
                              targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
            
            me->phy_closed = geom_props.phy_closed ? TRUE : FALSE;
            me->is_planar = geom_props.planar ? TRUE : FALSE; */


            ME.super_cmd->state = PROCESS;
            /*ex$message(msgnumb = EMS_M_SsOp);*/

            break;

          case EX_BACK_UP:

            if (me->project_onto_refplane)
               ME.super_cmd->state = SELECT_REFPLANE;
            else
               ME.super_cmd->state = SELECT_SURFACE;
            break;

          default:
            goto ret_end;
          }
        
          break;


      case OFFSET_DIRECTION:
#if dflT1
  printf("in execute state OFFSET DIRECTION\n");
#endif

        /* Find the direction to project the curve */

        sts = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                            &me->md_env.md_env.matrix_type,
                            me->md_env.md_env.matrix,
                            start_pnt,
                            end_pnt),
                      targetid = me->curve_info.located_obj.objid,
                      targetos = me->curve_info.located_obj.osnum,
                      senderid = my_id);
        EMomerr_hndlr ( sts, ret_end, "GRcurve.GRendpts");
        

        sts = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                            &me->md_env.md_env.matrix_type,
                            me->md_env.md_env.matrix,
                            start_pnt,
                            proj_start_pnt,
                            &proj_parms1),
                      senderid = my_id,
                      targetid = me->surface_info.located_obj.objid,
                      targetos = me->surface_info.located_obj.osnum);                          
        EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRptproject");

        sts = om$send(msg = message GRgraphics.GRptproject(&msg_loc,
                            &me->md_env.md_env.matrix_type,
                            me->md_env.md_env.matrix,
                            end_pnt,
                            proj_end_pnt,
                            &proj_parms2),
                      senderid = my_id,
                      targetid = me->surface_info.located_obj.objid,
                      targetos = me->surface_info.located_obj.osnum);                          
        EMomerr_hndlr ( sts, ret_end, "GRgraphics.GRptproject");

        /*sts = om$send(mode= OM_e_wrt_object,
                      msg = message GRvg.GRgetrang(&msg_loc,
                            &me->md_env.md_env.matrix_type,
                            me->md_env.md_env.matrix,
                            &in_world_system,
                            range),
                      senderid = my_id,
                      targetid = me->surface_info.located_obj.objid,
                      targetos = me->surface_info.located_obj.osnum);
        EMomerr_hndlr ( sts, ret_end, "GRvg.GRgetrang");*/


        /* determine range box */
        wo = TRUE;

        var_list_of[0].var = VW_VOLUME;
        var_list_of[0].var_ptr =  (IGRchar *) vwvolume;
        var_list_of[0].num_bytes = sizeof (IGRdouble) * 6;
        var_list_of[0].bytes_returned = (IGRlong *) &ret_stat;
        var_list_of[1].var = END_PARAM;

        sts = dp$inq_set_gragad (msg = &msg_loc,
                                 gragad_objid = me->locate_stack.window.objid,
                                 osnum = me->locate_stack.window.osnum,
                                 which_error = &ret_stat,
                                 var_list = var_list_of);

	point_size = sizeof(IGRpoint);

        OM_BLOCK_MOVE(&vwvolume[0], &range[0], point_size);
        OM_BLOCK_MOVE(&vwvolume[3], &range[3], point_size);
              
        
        /* function EFdraw_vector_on_screen already takes 1/4 of 
        diagonal, so multiply upper corner by RANGE_DIV */

        range[3] = range[0] + ((range[3] - range[0]) * RANGE_DIV); 
        range[4] = range[1] + ((range[4] - range[1]) * RANGE_DIV);
        range[2] = range[5] = 0.0; 
        range[5] = range[2] + ((range[5] - range[2]) * RANGE_DIV); 


        if(!(me->project_onto_refplane)) {
        sts = om$send(msg = message EMSsubbs.EMsftanorm(&msg_loc,
                            &me->md_env.md_env.matrix_type,
                            me->md_env.md_env.matrix,
                            NULL,
                            1, &proj_parms1.u,
                            1, &proj_parms1.v,
                            1.0,
                            NULL,                /* natural normal */   
                            FALSE,
                            TRUE,
                            norm_pts1,
                            NULL),
                      targetid = me->surface_info.located_obj.objid,
                      targetos = me->surface_info.located_obj.osnum,
                      senderid = NULL_OBJID);
        EMomerr_hndlr ( sts, ret_end, "EMSsubbs.EMsftanorm");

        sts = om$send(msg = message EMSsubbs.EMsftanorm(&msg_loc,
                            &me->md_env.md_env.matrix_type,
                            me->md_env.md_env.matrix,
                            NULL,
                            1, &proj_parms2.u,
                            1, &proj_parms2.v,
                            1.0,
                            NULL,                /* natural normal */   
                            FALSE,
                            TRUE,
                            norm_pts2,
                            NULL),
                      targetid = me->surface_info.located_obj.objid,
                      targetos = me->surface_info.located_obj.osnum,
                      senderid = NULL_OBJID);
        EMomerr_hndlr ( sts, ret_end, "EMSsubbs.EMsftanorm");

        norm_vec1[0] = norm_pts1[3] - norm_pts1[0];
        norm_vec1[1] = norm_pts1[4] - norm_pts1[1];
        norm_vec1[2] = norm_pts1[5] - norm_pts1[2];

        norm_vec2[0] = norm_pts2[3] - norm_pts2[0];
        norm_vec2[1] = norm_pts2[4] - norm_pts2[1];
        norm_vec2[2] = norm_pts2[5] - norm_pts2[2];
      } else {
        norm_vec1[X] = me->vector[X];          
        norm_vec1[Y] = me->vector[Y];          
        norm_vec1[Z] = me->vector[Z];          
        norm_vec2[X] = me->vector[X];          
        norm_vec2[Y] = me->vector[Y];          
        norm_vec2[Z] = me->vector[Z];          
      }

         EFdraw_vector_on_screen(
          NULL_OBJID,
          &me->active_display,
          &me->md_env,
          GRhd,
          FALSE,
          proj_start_pnt,
          norm_vec1,
          range,
          &msg_loc);

        EFdraw_vector_on_screen(
          NULL_OBJID,
          &me->active_display,
          &me->md_env,
          GRhd,
          FALSE,
          proj_end_pnt,
          norm_vec2,
          range,
          &msg_loc);


        ex$message(msgnumb=EMS_P_AcOfDi);

        event_size = sizeof (struct GRevent);

        stat_func = EMSokay (co$getevent (
          msg = &msg_loc,
          event_mask = GRm_DATA | 
                       GRm_BACK_UP| 
                       GRm_RJT_MOVEON,
          response = response,
          response_data = response_data,
        event = &event
        ));

        ex$message(msgnumb=EMS_P_ClearPromptField);
        if (stat_func == FALSE)
         {
          ex$message(msgnumb=EMS_E_FailInputProcExit);
          *response = TERMINATE;
          goto ret_end;
         }

         if (msg_loc != MSSUCC)
          goto ret_end;


        switch(event.response)
         {
          case EX_DATA:

            me->right_side = TRUE;
            ME.super_cmd->state = PROCESS;
            break;


          case EX_BACK_UP:

            dpmode  = GRhe;
            stat_OM = om$send(mode = OM_e_wrt_object,
                              msg = message GRgraphics.GRdisplay (&msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, &me->md_env.md_id),
                              senderid = my_id,
                              targetid = me->surface_info.located_obj.objid,
                              targetos = me->surface_info.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
            ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);


            EFdraw_vector_on_screen(
              NULL_OBJID,
              &me->active_display,
              &me->md_env,
              GRhe,
              FALSE,
              proj_start_pnt,
              norm_vec1,
              range,
              &msg_loc);

            EFdraw_vector_on_screen(
              NULL_OBJID,
              &me->active_display,
              &me->md_env,
              GRhe,
              FALSE,
              proj_end_pnt,
              norm_vec2,
              range,
              &msg_loc);


            ME.super_cmd->state = SELECT_SURFACE;
            break;

          case EX_RJT_MOVEON:

            EFdraw_vector_on_screen(
              NULL_OBJID,
              &me->active_display,
              &me->md_env,
              GRhe,
              FALSE,
              proj_start_pnt,
              norm_vec1,
              range,
              &msg_loc);

            EFdraw_vector_on_screen(
              NULL_OBJID,
              &me->active_display,
              &me->md_env,
              GRhe,
              FALSE,
              proj_end_pnt,
              norm_vec2,
              range,
              &msg_loc);


            EFdraw_vector_on_screen(
              NULL_OBJID,
              &me->active_display,
              &me->md_env,
              GRhd,
              TRUE,
              proj_start_pnt,
              norm_vec1,
              range,
              &msg_loc);

            EFdraw_vector_on_screen(
              NULL_OBJID,
              &me->active_display,
              &me->md_env,
              GRhd,
              TRUE,
              proj_end_pnt,
              norm_vec2,
              range,
              &msg_loc);

            me->right_side = FALSE;



            ME.super_cmd->state = PROCESS;
            break;

          default:
            goto ret_end;
         }

         break;


      case PROCESS:

#if dflT1
  printf("in execute state case PROCESS\n");
#endif
	ex$message(msgnumb = EMS_S_Processing);



/* here comes the associativity connection */

 {
    IGRint 		as_p_ctrl_size;
    IGRint 		num_parents;
    IGRchar 		*char_info = NULL;
    OM_S_OBJID 		res_id;
    struct 		as_project_ctrl {
                          IGRint        projection_type;
                          IGRint        offset;
                          IGRint        right_side;
                          IGRint        project_onto_refplane;
                          IGRchar       lawcurve_name[MAX_CHAR + 1];    
    };

    struct as_project_ctrl 	*projectptr = NULL; 
    struct EMSobject_info    	objects[4]; 
    struct EMSvalue_info  	value; 

    as_p_ctrl_size = sizeof (struct as_project_ctrl);

    projectptr = (struct as_project_ctrl *) stackalloc(as_p_ctrl_size);
    if (! projectptr) {
	ex$message(msgnumb = EMS_E_NoMem);
        *response = TERMINATE;
        goto ret_end;
    }

    /* put the  associative options together */
    projectptr->projection_type = me->compar_var.projection_type;
    projectptr->offset = me->compar_var.offset;
    projectptr->right_side = me->right_side;
    projectptr->project_onto_refplane = me->project_onto_refplane;
    strcpy(projectptr->lawcurve_name, me->compar_var.lawcurve_name);
    
    /* 2-5 parents exist; the curve object, the 
       surface or orientation plane object, the vector line,
       if ALONG_VECTOR and the
       start and end offset distances if offset = TRUE*/
    num_parents = 2;

    /* curve object */
    objects[0].grid = me->curve_info.located_obj;
    objects[0].env = me->curve_info.module_info;

    /* surface or orietation plane object */
    objects[1].grid = me->surface_info.located_obj;
    objects[1].env = me->surface_info.module_info;


    /* look if curve shall be offsetted normal to surface */
    if (me->compar_var.projection_type == NORMAL_TO_SURFACE &&
        me->compar_var.offset == OFFSET) {
        num_parents = 4;
        /*contruct expression objects */
        value.val = me->compar_var.dist_at_stpt;
        value.type = EMSdatainfo_numeric;
        stat_OM = EMgetparval_object (&msg_loc, 
                                     ME.ECelement->md_env.md_id.osnum, 
                                     NULL, 
                                     &value, 
                                     &objects[2]);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
         	  ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
         	  ret_end);
       
        value.val = me->compar_var.dist_at_ept;
        value.type = EMSdatainfo_numeric;
        stat_OM = EMgetparval_object (&msg_loc, 
                                     ME.ECelement->md_env.md_id.osnum, 
                                     NULL, 
                                     &value, 
                                     &objects[3]);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
         	  ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
         	  ret_end);
       
      }

    if (me->compar_var.projection_type == ALONG_VECTOR) {
           /* vector object */
       num_parents = 3;
       objects[2].grid = me->vector_info.located_obj;
       objects[2].env = me->vector_info.module_info;
     }
  
    /* set up construction list */
    const_list.msg = &msg_loc;
    const_list.env_info = &me->md_env;
    const_list.newflag = FALSE;
    const_list.level = ME.ECelement->active_level;
    const_list.properties = GRIS_DISPLAYABLE | 
                            GRIS_NEW | 
                            GRIS_LOCATABLE;
    const_list.geometry = NULL;
    const_list.display = &ME.ECelement->active_display;
    const_list.class_attr = NULL;
    const_list.name = NULL;

    XXXXX = 1;
    /* place associative function */
    sts    = ems$associative_element_by_function(
                msg = &msg_loc,
                associative =  me->is_associative ? TRUE : FALSE,  
                num_parents = num_parents,
                parents = &objects,
                info_size = as_p_ctrl_size,
                info = (IGRchar *) projectptr,
                function_name = "EFas_prcv",
                construct_list = &const_list,
                created_id = &res_id);
    /*EMerr_hndlr(!(1&sts), msg_loc, EMS_E_ConstFail,ret_end);*/
    /*EMerr_hndlr(!(1&sts&msg_loc), *msg_loc, *msg_loc, ret_end);*/

    /* display the projected curve */
    if(1&stat_OM&msg_loc) {
      dpmode = GRbd;
                          
      sts = om$send (msg = message GRgraphics.GRdisplay(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode,
                          &me->md_env.md_id),
                   targetid = res_id,
                   targetos = const_list.env_info->md_id.osnum);
      if (!(1 & sts & msg_loc))  return (OM_E_ABORT);
    } else
      me->error_flag = TRUE;

    /* free assoc info memory */
    if (projectptr) {
      stackfree(offsetptr);
    }
  }      
    event.event.keyin[0] = '\0';
    GRput_keybuff(event.event.keyin);
    ME.super_cmd->state = SELECT_CURVE;

     break;


   default:
     ex$message(msgnumb = EMS_F_CommandIllegalState);
     printf ("Command is in illegal state - %d\n", ME.super_cmd->state);
     *response = TERMINATE;
     goto ret_end;
   }
 } while (TRUE);

ret_end:
#if dflT1
  printf("*** return end ***\n");
#endif
  return (stat_OM);
}

end implementation ECpacos;

