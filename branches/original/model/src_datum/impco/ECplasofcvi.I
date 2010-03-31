/* ###################   APOGEE COMPILED   ################## */
class implementation ECplasofcv;
/*

History

20 Aug 1993 dfl forms input         added
                kb shortcut letters  "
                orientation plane    "
                projection plane     "
                vector arrows        "
                associativity        "
                autodimensioning     "
                fillet              deleted


9 June 1992 Tapadia Modified for message sub system compliance

09 Oct 1989 rlw Modified to support offset of non-planar curves.
                Also modified to use accept point to indicate offset side.

22 May 1989 jBk Replaced GRm_STRING masks with GRm_TEXT_VALUE.

19 May 1989 jBk Changed references of GRgetevent to co$getevent,
                including modification to use new value_type
                argument.

11 May 1989 jBk Moved prompt clearance and command name
                presenting from wakeup to execute;

                eliminated wakeup;

                Modified sleep to send to parent and not do any
                erasing or field presenting;

                removed references to me^^ECplasofcv.mod_info in
                favor of pre-existing and unutilized
                me^^EClement.md_env;

                removed gr$get calls and some initializations
                which occur in ECelement's init from this init
                while adding a send to parent of init.

dhm  01/20/89   Initialized const_list->msg.

RV   ??/??/88   creation date.
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
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMSasmacros.h"
#include "exdef.h"
/*#include "paoc.h"*/

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


/* Forms form and gadget processing */
#define FORM1 			1
#define ACCEPT_BUTTON 		1
#define DISTANCE_TOGGLE_C 	13
#define DISTANCE_TOGGLE_M       14
#define PROJECT_TOGGLE_OFF      11
#define AUTODIM_LIGHT           12
#define AUTODIM_TEXT            19

#define ON                      1
#define OFF                     0

#define ST1 			0 /* common distance offset */
#define ST2 			1 /* multiple distances offset */
#define ST3 			0 /* project to plane is off */
#define ST4 			1 /* project to plane is on */

#define ST1_TEXT 		"Common"
#define ST2_TEXT 		"Multiple"
#define ST3_TEXT 		"off"
#define ST4_TEXT 		"on"

/* option Form position */
#define WLOX                    0/*750*/
#define WLOY                    50/*125*/

/* plane type for planar curves */
#define PLANE			0

/* command execute states */
#define GET_CURVE       	1
#define ORIENTATION_PLANE 	2
#define DIR_POINT       	3
#define OFF_DIST        	4
#define PROJECT_PLANE 		5
#define PROCESS         	6

/* offset control bits */
#define ORIENTATION             1
#define PROJECTION              2
#define UNIFORM                 4
#define COMPOSITE               8
#define FILLET                  16
#define LOOPS                   32
#define RIGHTSIDE               64
#define PLANAR			128
#define CLOSED                  256

extern OMuword 			OPP_EMScomposite_class_id;
extern OMuword 			OPP_GR3dlineseg_class_id;
extern OMuword 			OPP_GRbspline_class_id;
extern OMuword 			OPP_GRcurve_class_id;
extern OMuword 			OPP_EMSdatpln_class_id;
extern OMuword 			OPP_EMSplane_class_id;
extern OMuword 			OPP_EMSsurface_class_id;
extern OMuword 			OPP_EMSsubbs_class_id;
extern OMuword 			OPP_GRbcsubbc_class_id;



from GRgraphics import 	GRlnproject, GRdisplay, GRgetrang, GRdelete, 
                       	GRgetobjinfo;
from GRvg import 	GRgetattr, GRdetplane, GRgeomprops, GRgetgeom, 
                 	GRgetsize, GRconstruct;
from GRcurve import 	EMcvoffset, GRgenabsg, GRmidpoint;
from EMSsubbs import 	EMsfcvoffset;
from EMSassoc import    EMget_info;

      
method init (IGRint type; IGRchar *string) 
{

  IGRchar 	errmsg[EMMAXERRMSG_LEN]; 
  IGRint 	sts;

#if dflT1
  printf("in init \n"); 
#endif

  me->init_on = TRUE;
  me->error_flag = FALSE;
  me->projection_toggle = FALSE;
  me->multiple_dist_toggle = FALSE;
  me->sleep_state = GET_CURVE;

  sts = om$send (
        mode = OM_e_wrt_parent,
        msg = message ECplasofcv.init (type, string),
        targetid = my_id);


  strcpy (errmsg, "ECplasofcv.init");


  me->remove_loops = TRUE;
  me->next_comp = 0;
  me->is_uniform = TRUE;
  me->is_to_project = FALSE;

  me->form_requested = FALSE;
  me->form_id = NULL_OBJID;
  me->active_form_name[0] = '\0';

  ex$message(msgnumb = EMS_I_InvkStatusFrm);

  me->form_requested = 0;
 
  return sts;
  
}

method wakeup (int pos) 
{

  IGRint sts = OM_S_SUCCESS;

  sts = om$send (msg= message ECplasofcv.wakeup(pos),
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
        msg = message ECplasofcv.sleep (pos),
        targetid = my_id);

    ME.ECelement->elem_hilit = FALSE;
    me->sleep_state = ME.super_cmd->state;

    return(sts); 
}

method status_disp() {

  IGRlong 	status, EMmsg;
  /*OM_S_OBJID 	set_id = NULL_OBJID;*/
  IGRint 		ret;
  IGRint 	ECplasofcv_process_form();

#if dflT1
  printf("in status_disp1\n"); 
#endif

  status = OM_S_SUCCESS;
  EMmsg = 1;

  if(me->form_requested)
   return(status);
  
  ret = FIf_new (FORM1, 
                 "EMPlOffCurve", 
                 ECplasofcv_process_form, 
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
  

    if(me->is_associative) {
       FIg_disable(me->oform,DISTANCE_TOGGLE_M);
       if((! me->is_to_project) && me->is_uniform) {
         FIg_enable(me->oform,AUTODIM_LIGHT);
         FIg_enable(me->oform,AUTODIM_TEXT);
         FIg_set_value(me->oform, AUTODIM_LIGHT, (IGRdouble) ON);
         ex$message(msgnumb = EMS_I_AuDiOn);
       } else {
         FIg_set_value(me->oform, AUTODIM_LIGHT, (IGRdouble) OFF);
         FIg_disable(me->oform,AUTODIM_LIGHT);
         FIg_disable(me->oform,AUTODIM_TEXT);
         ex$message(msgnumb = EMS_I_AuDiOf);
       }
    } else {
         FIg_set_value(me->oform, AUTODIM_LIGHT, (IGRdouble) OFF);
         FIg_disable(me->oform,AUTODIM_LIGHT);
         FIg_disable(me->oform,AUTODIM_TEXT);
         ex$message(msgnumb = EMS_I_AuDiOf);
    }
    ret = FIf_display(me->oform);
    if (ret) {
     status = FALSE;
     goto wrapup;
    }

    if (me->is_uniform) 
       me->multiple_dist_toggle = FALSE;
    else 
       me->multiple_dist_toggle = TRUE;
        
    me->form_requested = TRUE;



wrapup:
 if (!(1&status&EMmsg))
   return (OM_E_ABORT);

  if(me->init_on) {
     ret = FIg_set_state (me->oform, DISTANCE_TOGGLE_C, !(me->multiple_dist_toggle));
     ret = FIg_set_state (me->oform, DISTANCE_TOGGLE_M, me->multiple_dist_toggle);

     ret = FIg_set_state (me->oform, PROJECT_TOGGLE_OFF, OFF);
     me->init_on = FALSE;
  } else {
    if (me->multiple_dist_toggle) {
     ret = FIg_set_state (me->oform, DISTANCE_TOGGLE_C, OFF);
     ret = FIg_set_state (me->oform, DISTANCE_TOGGLE_M, ON);
    } else {
     ret = FIg_set_state (me->oform, DISTANCE_TOGGLE_C, ON);
     ret = FIg_set_state (me->oform, DISTANCE_TOGGLE_M, OFF);
    }
    if (me->projection_toggle) {
     ret = FIg_set_state (me->oform, PROJECT_TOGGLE_OFF, ON);
    } else {
     ret = FIg_set_state (me->oform, PROJECT_TOGGLE_OFF, OFF);
    }
  }
  return (status); 
}


IGRint ECplasofcv_process_form (form_label, gadget_label, value,
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

  stat_OM = om$send (msg = message ECplasofcv.do_form (&msg_loc,
                                                       form_label,
                                                       gadget_label, 
                                                       value),
                     senderid = NULL_OBJID, 
                     targetid = cmdobj, 
                     targetos = cmdos);
  if(! (stat_OM & 1))
    return (OM_E_ABORT); return (stat_OM); 

}


method do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value) 
{

 /*IGRint	update_form, stat_func;*/
 IGRlong        sts;
 int XXXXX;
 IGRint toggle;
 IGRint ret;
 /*GRobjid cmdobj;
 GRspacenum cmdos;*/

 sts = OM_S_SUCCESS;

 if (form_label == FORM1) {
 switch (gadget_label)
  {

   case ACCEPT_BUTTON:
#if dflT1
    printf ("distance toggle %d\n", me->multiple_dist_toggle);
    printf ("projection toggle %d\n", me->projection_toggle);
#endif
    me->form_requested = 0;
    me->error_flag = FALSE;

    ret = FIf_erase(me->oform);


    break;


   case DISTANCE_TOGGLE_C:
#if dflT1
    printf("distance button common pressed \n");
#endif

    ret = FIg_get_state(me->oform, DISTANCE_TOGGLE_C,
        &toggle);

    if (toggle == ON) {
      me->is_uniform = TRUE;
      me->multiple_dist_toggle = FALSE;
      if(me->projection_toggle) {
        ex$message(msgnumb = EMS_I_OdPp3);
      } else {
        ex$message(msgnumb = EMS_I_OdPp1);
        if(me->is_associative) {
          FIg_enable(me->oform,AUTODIM_LIGHT);
          FIg_enable(me->oform,AUTODIM_TEXT);
          FIg_set_value(me->oform, AUTODIM_LIGHT, (IGRdouble) ON);
          ex$message(msgnumb = EMS_I_AuDiOn);
        }
      }
    } else {
      me->is_uniform = FALSE; 
      me->multiple_dist_toggle = TRUE;
      if(me->projection_toggle)  {
        ex$message(msgnumb = EMS_I_OdPp4);
      } else {
        ex$message(msgnumb = EMS_I_OdPp2);
      }
    }

    break;


   case DISTANCE_TOGGLE_M:
#if dflT1
    printf("distance button multiple pressed \n");
#endif

    FIg_get_state(me->oform, DISTANCE_TOGGLE_M,
        &toggle);

    if (toggle == ON) {
     if (me->is_associative) {
        ex$message(msgnumb = EMS_E_AsMdEx);
        FIg_set_state(me->oform, DISTANCE_TOGGLE_M,
           OFF);
        FIg_set_state(me->oform, DISTANCE_TOGGLE_C,
           ON);
     } else {
        FIg_set_value(me->oform, AUTODIM_LIGHT, (IGRdouble) OFF);
        FIg_disable(me->oform,AUTODIM_LIGHT);
        FIg_disable(me->oform,AUTODIM_TEXT);
        ex$message(msgnumb = EMS_I_AuDiOf);
        me->is_uniform = FALSE; 
        me->multiple_dist_toggle = TRUE;
        if(me->projection_toggle) {
          ex$message(msgnumb = EMS_I_OdPp4);
        } else {
          ex$message(msgnumb = EMS_I_OdPp2);
        }

      }
     } else {
      me->is_uniform = TRUE;
      me->multiple_dist_toggle = FALSE;
      if(me->projection_toggle) {
        ex$message(msgnumb = EMS_I_OdPp3);
      } else {
        ex$message(msgnumb = EMS_I_OdPp1);
      }
    }

    break;


   case AUTODIM_LIGHT:

    break;



   case PROJECT_TOGGLE_OFF:
#if dflT1
    printf("project button OFF pressed \n");
#endif

    FIg_get_state(me->oform, PROJECT_TOGGLE_OFF,
                        &toggle);

    if (toggle == ON) {
      FIg_set_value(me->oform, AUTODIM_LIGHT, (IGRdouble) OFF);
      FIg_disable(me->oform,AUTODIM_LIGHT);
      FIg_disable(me->oform,AUTODIM_TEXT);
      ex$message(msgnumb = EMS_I_AuDiOf);
      me->projection_toggle = TRUE;
      me->is_to_project = TRUE;
      if(me->multiple_dist_toggle) {
        ex$message(msgnumb = EMS_I_OdPp4);
      } else {
        ex$message(msgnumb = EMS_I_OdPp3);
      }
    } else {
      if(me->is_associative) {
         FIg_enable(me->oform,AUTODIM_LIGHT);
         FIg_enable(me->oform,AUTODIM_TEXT);
         FIg_set_value(me->oform, AUTODIM_LIGHT, (IGRdouble) ON);
         ex$message(msgnumb = EMS_I_AuDiOn);
      } else {
         FIg_set_value(me->oform, AUTODIM_LIGHT, (IGRdouble) OFF);
         FIg_disable(me->oform,AUTODIM_LIGHT);
         FIg_disable(me->oform,AUTODIM_TEXT);
         ex$message(msgnumb = EMS_I_AuDiOf);
      }
      me->projection_toggle = FALSE; 
      me->is_to_project = FALSE;
      if(me->multiple_dist_toggle) {
        ex$message(msgnumb = EMS_I_OdPp2);
      } else {
        ex$message(msgnumb = EMS_I_OdPp1);
      }
    }

    break;


   default:
    ret = FIf_erase(me->oform);
    break;


 } /* end switch (gadget_label) */ }
 return(OM_S_SUCCESS); 

}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean 		wo;
  IGRboolean 		reverse;
  IGRboolean            stat_func;

  int 			XXXXX;
  /*int			abul = 1;*/
  IGRint 		tcount;
  IGRint 		point_size;
  IGRint 		display_flag;
  /*IGRint		data_type;*/

  IGRint 		num_elements,
                        irc,
                        j;

  /*IGRchar		*cur_ptr = NULL;*/
  /*IGRchar		abu[1];*/
  IGRchar		ksl;
  IGRchar 		errmsg[EMMAXERRMSG_LEN], 
                        prompt[MAX_PROMPT_SIZE];
  /*IGRchar 		temp_prompt[MAX_PROMPT_SIZE];*/
  IGRchar               classname[OM_K_MAXCLASS_LEN];
  IGRchar 		loc_prompt[54], 
                        acc_prompt[54], 
                        reloc_prompt[54];
  IGRchar 		*generic_pointer = NULL;

  /*IGRlong             no_objs;*/
  /*IGRlong 		ret_bytes;*/
  IGRlong 		ret_stat;
  IGRlong 		event_size;
  IGRlong 		stat_OM, msg_loc, sts;
  IGRlong 		loc_mask, acc_mask;
  IGRlong 		i;
  /*IGRlong               size;*/

  IGRdouble		range[6];
  IGRdouble             mdis;
  IGRdouble 		t, dotp;
  IGRdouble 		vwvolume[6],
                        x, y , z;
  IGRdouble		poles[16][3];
  IGRdouble		weights[16];
  IGRdouble		u_knots[4], 
                        v_knots[4];

  IGRvector 		plane_normal, 
                        sidevec,
                        svec, 
                        crossp;

  IGRpoint 		plane_point;
  IGRpoint		projpnt;
  IGRpoint 		pnt1, 
                        pnt2, 
                        line_pt, 
                        cveval[2],
                        points[3];

  /*struct EX_button      set_button;*/  
  struct IGRline 	boreline;
  struct GRevent 	accev, 
                        event;
  struct GRlc_locate 	lc_attr;
  struct GRvg_construct const_list;
  /*struct IGResbc 	esbc;*/
  /*struct GRid 		cvoffset_id, 
                        cv2offset_id;*/
  struct IGRplane 	plane;
  struct GRparms 	proj_parms;
  struct GRprops 	geom_props;
  struct var_list 	var_list_of[2];
  /*struct GRlc_info	offcurve_info;*/
  /*struct IGRbsp_curve 	*cur_geom = NULL;*/
  /*struct GRobj_info 	info;*/
  struct IGRbsp_curve 	*closest_crv_geom = NULL;
  /*struct IGRbsp_curve	*proj_bsp_curve = 0;*/
  /*struct IGRbsp_curve	*bsp_curve = 0;*/
  struct IGRbsp_surface plane3pt;
  /*struct GRid		pro_curve_id;*/
  enum GRdpmode 	dpmode;
  OM_S_CLASSLIST 	rtree_classes, eligible_classes;
  OMuword 		r_classes[5], 
                        e_classes[5];
  GRobjid 		closest_crv_id;
  OM_S_CHANSELECT 	to_comps;
  OMuword 		class_id;
  OM_S_OBJECT_LINKAGE 	*oblist = NULL;
  /*OM_S_OBJID		*o_objs;*/
  BSrc 			rc;

  extern IGRdouble 	BSdotp();
  extern IGRdouble      fabs(IGRdouble);
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
  ex$message(msgnumb = EM_M_PlAsOfCr);
 
  *response = TERMINATE;
  stat_OM = OM_S_SUCCESS;
  event_size = sizeof (struct GRevent);
  strcpy (errmsg, "ECplasofcv.execute");

  do 
    {
    switch (ME.super_cmd->state)
      {
      case GET_CURVE:

#if dflT1
  printf("in execute state GET CURVE\n");
#endif
        me->is_to_project = me->projection_toggle;

        if (ME.ECelement->elem_hilit) {
          stat_OM = dp$erase_hilite(msg = &msg_loc);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
        }
        event.event.keyin[0] = '\0';

        loc_mask = GRm_DATA | 
                   GRm_BACK_UP;
        acc_mask = GRm_DATA;

	ex$message(msgnumb = EMS_M_PcCv, buff = loc_prompt);

        if(! me->error_flag) {
           if(! (me->is_uniform))
             if(me->projection_toggle)
               ex$message(msgnumb = EMS_I_OdPp4)
             else
               ex$message(msgnumb = EMS_I_OdPp2)
           else 
             if(me->projection_toggle)
               ex$message(msgnumb = EMS_I_OdPp3)
             else
               ex$message(msgnumb = EMS_I_OdPp1);
        }

        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_I_00010, buff = reloc_prompt);
        LCdef_cursor();
    
        stat_func = co$getevent(
                  msg = &msg_loc,
                  mode = EX_ALL_CHAR_MODE | EX_LINE_MODE,
                  event_mask = (GRm_DATA | 
                                GRm_STRING | 
                                GRm_RJT_MOVEON | 
                                GRm_BACK_UP),
                  prompt = loc_prompt,
                  response = response,
                  response_data = response_data,
                  event = &event);
        LCrestore_cursor();

        if (stat_func == FALSE) {
	  	    ex$message(msgnumb = EMS_E_FailInputProcExit);
          	    *response = TERMINATE;
          	    goto ret_end;
        }
        if (msg_loc != MSSUCC)
          goto ret_end;



        switch(*response) 
        {
          case EX_BACK_UP:
          case EX_RJT_MOVEON:
            ME.super_cmd->state = GET_CURVE;
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

            ksl = response_data[0];
            if (ksl == '\033') { /* escape */
              event.event.keyin[0] = ksl;
              event.event.keyin[1] = '\0';
              GRput_keybuff(event.event.keyin);
              ex$message(field=KEYIN_FIELD,msgnumb=EMS_I_escape);
              break;
            } 
            if (ksl != 'c' && ksl != 'm') 
              goto ret_end;

            event.event.keyin[1] = '\013';
            GRput_keybuff(event.event.keyin);

            if (ksl == 'c')  
              me->is_uniform = TRUE;
            else if (ksl == 'm') {
                if (me->is_associative) {
                  ex$message(msgnumb = EMS_E_AsMdEx);
                  me->is_uniform = TRUE;
                } else {             
                  me->is_uniform = FALSE;
                }
	    }
             

          default:
            goto ret_end;
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

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       PROJ_ACCEPT_POINT | 
                       LC_ACC_ONE_ELEMENT;


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

        /* check associativity and multiple distances for exclusion */
        if(me->is_associative && ( ! me->is_uniform)) 
        {
          ex$message(msgnumb = EMS_E_AsMdEx);
          me->error_flag = TRUE;
          ME.super_cmd->state = GET_CURVE;
          stat_OM = dp$erase_hilite(msg = &msg_loc);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
          break;
        }



        switch (accev.response)
          {
          case EX_DATA:
            ME.ECplasofcv->curve_info = accev.located_object[0];
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

            stat_OM = om$get_classid(
                        objid = ME.ECelement->elem.located_obj.objid,
                        osnum = ME.ECelement->elem.located_obj.osnum,
                        p_classid = &class_id);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
 
            stat_OM = om$is_ancestry_valid(subclassid = class_id, 
                          superclassid = OPP_EMScomposite_class_id);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            if (stat_OM != OM_S_SUCCESS)
            {
                stat_OM = OM_S_SUCCESS;
                me->num_comps = 1;
                me->is_composite = FALSE;
                me->is_uniform = TRUE;
            }
            else
            {
                me->is_composite = TRUE;
                stat_OM = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

                stat_OM = om$get_channel_count(
                        objid = ME.ECelement->elem.located_obj.objid,
                        osnum = ME.ECelement->elem.located_obj.osnum,
                                p_chanselect = &to_comps,
                                count = (OMuint *)&me->num_comps);
                EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
  
                oblist  = (OM_S_OBJECT_LINKAGE *) om$malloc(
                           size = (me->num_comps)*sizeof(OM_S_OBJECT_LINKAGE));
                EMerr_hndlr(!oblist, *response, TERMINATE, ret_end);

                stat_OM = om$get_channel_objects(
                             objid = ME.ECelement->elem.located_obj.objid,
                             osnum = ME.ECelement->elem.located_obj.osnum,
                             p_chanselect = &to_comps,
                             list = oblist,
                             size = (OMuint)me->num_comps,
                             count = (OMuint *)&me->num_comps);
                EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);

                num_elements = om$dimension_of(varray = me->comp_ids); 
                if (me->num_comps > num_elements)
                {
                  stat_OM = om$vla_set_dimension(varray = me->comp_ids,
                                                size = me->num_comps);
                  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                  ret_end, errmsg);

                  stat_OM = om$vla_set_dimension(varray = me->comp_dis,
                                                size = me->num_comps);
                  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                  ret_end, errmsg);

                  stat_OM = om$vla_set_dimension(varray = me->off_code,
                                                size = me->num_comps);
                  EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                  ret_end, errmsg);
                }      
                for (i=0; i<me->num_comps; i++) 
                     me->comp_ids[i] = oblist[i].S_objid;
                if (oblist) om$dealloc(ptr = oblist);
            }

            projpnt[X] = accev.located_object[0].proj_pnt[X];
            projpnt[Y] = accev.located_object[0].proj_pnt[Y];
            projpnt[Z] = accev.located_object[0].proj_pnt[Z];

            plane.point = (IGRdouble *) &plane_point[0];
            plane.normal = (IGRdouble *) &plane_normal[0];
            stat_OM = om$send(mode = OM_e_wrt_object,
                              msg = message GRvg.GRdetplane(&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &plane),
                              senderid = my_id,
                              targetid = ME.ECelement->elem.located_obj.objid,
                              targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                    ret_end, errmsg);

            if(me->is_planar && msg_loc == MSSUCC) {
               me->vector[X] = plane.normal[X];
               me->vector[Y] = plane.normal[Y];
               me->vector[Z] = plane.normal[Z];
               /* create a plane, because its needed for recomputation
                  if a planar curve is changed to 3D */
               /* determine greatest vector value */

               x = fabs(plane.normal[X]);
               y = fabs(plane.normal[Y]);
               z = fabs(plane.normal[Z]);
               if (x < y) 
                j = 1;
               else 
                j = 2;
               if (j == 2) {
                 if (z < y)
                  j = 3;
               } 
               if (j == 1) {
                 if (z < x)
                  j = 3;
               } 
               if (j == 1) {
                  svec[0] = 0;
                  svec[1] = plane.normal[2] * -1.0;
                  svec[2] = plane.normal[1];
               }
               if (j == 2) {
                  svec[1] = 0;
                  svec[0] = plane.normal[2] * -1.0;
                  svec[2] = plane.normal[0];
               }
               if (j == 3) {
                  svec[2] = 0;
                  svec[1] = plane.normal[0] * -1.0;
                  svec[0] = plane.normal[1];
               }

               /* point 2 on plane */
               points[1][0] =  plane.point[0] + svec[0];
               points[1][1] =  plane.point[1] + svec[1];
               points[1][2] =  plane.point[2] + svec[2];

               /* point 3 on plane */
               BScrossp(&rc, plane.normal, svec, crossp);
               EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);
 
               points[2][0] = plane.point[0] + crossp[0];
               points[2][1] = plane.point[1] + crossp[1];
               points[2][2] = plane.point[2] + crossp[2];

               points[0][0] = plane.point[0];
               points[0][1] = plane.point[1];
               points[0][2] = plane.point[2];
      
               plane3pt.poles = (double *) &poles[0][0];
               plane3pt.weights = (double *) &weights[0];
               plane3pt.u_knots = (double *) &u_knots[0];
               plane3pt.v_knots = (double *) &v_knots[0];

               sts = BSplane3pt(&irc,
                                points[0],
                                points[1],
                                points[2],
                                &plane3pt);
               EMerr_hndlr (irc != BSSUCC, *response, TERMINATE, ret_end);

               const_list.msg = &msg_loc;
               const_list.env_info = &me->md_env;
               const_list.newflag = FALSE;
               const_list.level = ME.ECelement->active_level;
               const_list.properties = GRIS_NEW;
                                /*       | GRIS_DISPLAYABLE
                                       | GRIS_LOCATABLE;  */
               const_list.geometry = (IGRchar *) &plane3pt;
               const_list.display = &ME.ECelement->active_display;
               const_list.class_attr = NULL;
               const_list.name = NULL;

               me->plnobj.osnum = const_list.env_info->md_id.osnum;
               stat_OM = om$construct(classid = OPP_EMSplane_class_id,
                                      msg = message GRgraphics.GRconstruct(&const_list),
                                      p_objid = &me->plnobj.objid,
                                      osnum = me->plnobj.osnum);
               EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                 ret_end, errmsg);
               EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
                 ret_end);
                                                          
               me->plane_constructed = TRUE;
               me->is_oriented = TRUE;                                                  
               ME.super_cmd->state = DIR_POINT;
               ex$message(msgnumb = EMS_P_AccWiPtOnSiToOffsetRej);
            } else {
               me->plane_constructed = FALSE;
               ME.super_cmd->state = ORIENTATION_PLANE;
               ex$message(msgnumb = EMS_P_GetOrPlaneRej);
            }

            break;


          default:
            goto ret_end;
          }
        
          break;



      case ORIENTATION_PLANE:
#if dflT1
  printf("in execute state ORIENTATION_PLANE\n");
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

        if(! me->error_flag) {
           if(! (me->is_uniform))
             if(me->projection_toggle)
               ex$message(msgnumb = EMS_I_OdPp4)
             else
               ex$message(msgnumb = EMS_I_OdPp2)
           else 
             if(me->projection_toggle)
               ex$message(msgnumb = EMS_I_OdPp3)
             else
               ex$message(msgnumb = EMS_I_OdPp1);
        }

        ex$message(msgnumb = EMS_P_00038, buff = acc_prompt);
        ex$message(msgnumb = EMS_P_GetOrPlaneRej, buff = loc_prompt);
    
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
        /*ex$message(msgnumb = EMS_P_AccWiPtOnSiToOffsetRej, buff = acc_prompt);*/
        

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
            ME.super_cmd->state = GET_CURVE;
            break;
        } else
            goto ret_end;
        }

        switch (accev.response)
        {
         case EX_DATA:
            
            me->or_pln_info = accev.located_object[0];
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
                              targetid = me->or_pln_info.located_obj.objid,
                              targetos = me->or_pln_info.located_obj.osnum);
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
                              targetid = me->or_pln_info.located_obj.objid,
                              targetos = me->or_pln_info.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);

            me->vector[X] = plane.normal[X];
            me->vector[Y] = plane.normal[Y];
            me->vector[Z] = plane.normal[Z]; 

            ME.super_cmd->state = DIR_POINT;
            break;

        case EX_RJT_MOVEON:
            ME.super_cmd->state = GET_CURVE;
            break;

	default:
            goto ret_end;
        }
        break;

      case DIR_POINT:

#if dflT1
  printf("in execute state DIR_POINT\n");
#endif
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


        acc_mask = GRm_DATA;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       LC_ERASE_LOC_ELEMENT;

        if(! me->error_flag) {
           if(! (me->is_uniform))
             if(me->projection_toggle)
               ex$message(msgnumb = EMS_I_OdPp4)
             else
               ex$message(msgnumb = EMS_I_OdPp2)
           else 
             if(me->projection_toggle)
               ex$message(msgnumb = EMS_I_OdPp3)
             else
               ex$message(msgnumb = EMS_I_OdPp1);
        }

	ex$message(msgnumb = EMS_P_InPtOnSideOffset, buff = prompt); 

        stat_func = EMSokay (co$getevent (msg = &msg_loc,
                                          event_mask = GRm_DATA | GRm_BACK_UP,
                                          prompt = prompt,
                                          response = response,
                                          response_data = response_data,
                                          event = &event));
	/*ex$message(msgnumb = EMS_P_ClearPromptField);*/
        if (stat_func == FALSE)
          {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
          }

        if (msg_loc != MSSUCC)
          goto ret_end;


        switch (event.response)
          {

          case EX_DATA:

            ME.ECplasofcv->off_dirpt[X] = event.event.button.x;
            ME.ECplasofcv->off_dirpt[Y] = event.event.button.y;
            ME.ECplasofcv->off_dirpt[Z] = event.event.button.z;

            boreline.point1 = pnt1;  /* allocates storage for */
            boreline.point2 = pnt2;  /* the boreline          */

            EFboreline(&msg_loc, my_id, &event, &boreline);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);



            stat_OM = om$send(msg = message GRgraphics.GRlnproject(&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &boreline,
                                     line_pt, 
                                     me->pt_on_crv, 
                                     &t, 
                                     &proj_parms),
                              senderid = my_id,
                              targetid = ME.ECelement->elem.located_obj.objid,
                              targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            if (me->is_composite) 
              closest_crv_id = proj_parms.leaf_id.objid;
            else  
              closest_crv_id = ME.ECelement->elem.located_obj.objid;

            /* now determine if right_side = TRUE or FALSE */
           
            stat_OM = om$send(msg = message GRcurve.GRgenabsg(&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &generic_pointer),
                              senderid = my_id,
                              targetid = closest_crv_id,
                              targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            closest_crv_geom = (struct IGRbsp_curve *) generic_pointer;


            BScveval(closest_crv_geom, proj_parms.u, 1, cveval, &rc);

            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

            sidevec[X] = line_pt[X] - cveval[0][X];
            sidevec[Y] = line_pt[Y] - cveval[0][Y];
            sidevec[Z] = line_pt[Z] - cveval[0][Z];

            BScrossp(&rc, cveval[1], me->vector, crossp);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

            BSnorvec(&rc, sidevec);

            dotp = BSdotp(&rc, crossp, sidevec);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

            me->right_side = (dotp >= 0 ? TRUE : FALSE);
            
            me->arrvec[0] = crossp[0];
            me->arrvec[1] = crossp[1];
            me->arrvec[2] = crossp[2];

            me->next_comp = 0;
            ME.super_cmd->state = OFF_DIST;
            break;

          case EX_BACK_UP:

            ME.super_cmd->state = GET_CURVE;
            break;

          case TERMINATE:
           if (me->plane_constructed) {
             me->plane_constructed = FALSE;
             stat_OM = om$send ( msg = message GRgraphics.GRdelete(
                                        &msg_loc,
                                        const_list.env_info),
                                targetid = me->plnobj.objid,
                                targetos = me->plnobj.osnum);
             EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
             EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
#if dflT1
             printf("in dir point und default\n");
#endif
           }
           goto ret_end;

          default:
            ME.super_cmd->state = DIR_POINT;
            goto ret_end;
          }
        break;


  
      case OFF_DIST:
#if dflT1
  printf("in execute state OFF_DIST\n");
#endif
        if (me->is_uniform) {
	  ex$message(msgnumb = EMS_P_Kidl, buff = prompt); 
         me->next_comp = 0;
        } else {
            if (me->next_comp == 0) {
	      ex$message(msgnumb = EMS_P_Kidl, buff = prompt); 
            } else {
               mdis = me->comp_dis[me->next_comp - 1];
               ex$message(msgnumb = EMS_P_Kidlm, buff = prompt, type = "%f",
                     var = `mdis`);
            }
	  /*ex$message(msgnumb = EMS_P_BackToChaOffMode,buff = temp_prompt);
	  strcat(prompt, temp_prompt);*/

          stat_OM = dp$erase_hilite(msg = &msg_loc);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
              ret_end, errmsg);
       	  EMerr_hndlr(EMis_error(msg_loc),*response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
        }

        dpmode = GRhd;
        stat_OM = om$send(msg = message GRgraphics.GRdisplay (&msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 &dpmode, &me->md_env.md_id),
                          senderid = my_id,
                          targetid = (me->is_uniform ? 
                                ME.ECelement->elem.located_obj.objid :
                                me->comp_ids[me->next_comp]),
                          targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);


        /* determine range box */
        wo = TRUE;

        var_list_of[0].var = VW_VOLUME;
        var_list_of[0].var_ptr =  (IGRchar *) vwvolume;
        var_list_of[0].num_bytes = sizeof (IGRdouble) * 6;
        var_list_of[0].bytes_returned = (IGRlong *) &ret_stat;
        var_list_of[1].var = END_PARAM;

        /* get view volume  */
        sts = dp$inq_set_gragad (msg = &msg_loc,
                                 gragad_objid = me->locate_stack.window.objid,
                                 osnum = me->locate_stack.window.osnum,
                                 which_error = &ret_stat,
                                 var_list = var_list_of);

	point_size = sizeof(IGRpoint);

        OM_BLOCK_MOVE(&vwvolume[0], &range[0], point_size);
        OM_BLOCK_MOVE(&vwvolume[3], &range[3], point_size);
        
	/* compute range */
        /* the arrow length should be 1/10 of the window diagonal
        function EFdraw_vector_on_screen already takes 1/4 of 
        diagonal, so multiply upper corner by RANGE_DIV */

        range[3] = range[0] + ((range[3] - range[0]) * RANGE_DIV); 
        range[4] = range[1] + ((range[4] - range[1]) * RANGE_DIV);
        range[2] = range[5] = 0.0; 
        range[5] = range[2] + ((range[5] - range[2]) * RANGE_DIV); 


	/* get a point wherefrom to draw the arrow */
        if (! me->is_uniform) {
        stat_OM = om$send(msg = message GRcurve.GRmidpoint (&msg_loc,
                                 &me->md_env.md_env.matrix_type,
                                 me->md_env.md_env.matrix,
                                 NULL, 
                                 me->pt_on_crv),
                          senderid = my_id,
                          targetid = (me->is_composite ?
                                        me->comp_ids[me->next_comp] : 
                                        ME.ECelement->elem.located_obj.objid),
                          targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
           ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

        
/******************************************************************************/
            closest_crv_id = me->comp_ids[me->next_comp];
            stat_OM = om$send(msg = message GRcurve.GRgenabsg(&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &generic_pointer),
                              senderid = my_id,
                              targetid = closest_crv_id,
                              targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            closest_crv_geom = (struct IGRbsp_curve *) generic_pointer;

            BScveval(closest_crv_geom, proj_parms.u, 1, cveval, &rc);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

            BScrossp(&rc, cveval[1], me->vector, crossp);
            EMerr_hndlr (rc != BSSUCC, *response, TERMINATE, ret_end);

	    /* this is the arrow vector */ 
            me->arrvec[0] = crossp[0];
            me->arrvec[1] = crossp[1];
            me->arrvec[2] = crossp[2];
        }



/******************************************************************************/


        reverse = FALSE; 
        BSnorvec(&rc, me->arrvec);
        if (! me->right_side) {
           reverse = TRUE;
           /*me->arrvec[0] *= -1;
           me->arrvec[1] *= -1;
           me->arrvec[2] *= -1;*/
        }

	ex$message(field = PROMPT_FIELD, justification = RIGHT_JUS,
		   in_buff = prompt);

        
        EFdraw_vector_on_screen(my_id, 
                                &me->active_display, 
                                &me->md_env,
                                GRbd, 
                                reverse, 
                                me->pt_on_crv, 
                                me->arrvec, 
                                range, 
                                &msg_loc);


        stat_func = EMSokay (co$getevent (msg = &msg_loc,
                                          event_mask = GRm_DATA | 
                                                       GRm_VALUE | 
                                                       GRm_BACK_UP,
                                          value_type = GRIO_DISTANCE,
                                          response = response,
                                          response_data = response_data,
                                          event = &event));

	ex$message(msgnumb = EMS_P_ClearPromptField);

        if (stat_func == FALSE) {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
        }

        if (msg_loc == GRw_no_value) {
		ex$message(msgnumb = EMS_I_00006);
          	break;
        }

        if (msg_loc != MSSUCC)
          goto ret_end;


        switch (event.response)
          {
          case EX_DATA:

            EFdraw_vector_on_screen(my_id, 
                                    &me->active_display, 
                                    &me->md_env,
                                    GRbe, 
                                    reverse, 
                                    me->pt_on_crv, 
                                    me->arrvec, 
                                    range, 
                                    &msg_loc);
            boreline.point1 = pnt1;  /* allocates storage for */
            boreline.point2 = pnt2;  /* the boreline          */

            EFboreline(&msg_loc, my_id, &event, &boreline);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
            stat_OM = om$send(msg = message GRgraphics.GRlnproject(&msg_loc,
                         &me->md_env.md_env.matrix_type,
                         me->md_env.md_env.matrix,
                         &boreline,
                         line_pt, me->pt_on_crv, &t, &proj_parms),
                      senderid = my_id,
                      targetid = ME.ECelement->elem.located_obj.objid,
                      targetos = ME.ECelement->elem.located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);


            /*me->comp_dis[me->next_comp]  = 
                      BSdistptpt (&msg_loc, 
                                  ME.ECplasofcv->pt_on_crv, 
                                  &event.event.button.x);*/
            me->comp_dis[me->next_comp]  = 
                      BSdistptpt (&msg_loc, 
                                  ME.ECplasofcv->pt_on_crv, 
                                  &line_pt);
            EMerr_hndlr (msg_loc != BSSUCC, *response, TERMINATE, ret_end);

            me->off_code[me->next_comp] = BSCONSTOFF;

            if (me->is_uniform || me->next_comp + 1 == me->num_comps) {
               if (me->is_to_project) 
                 ME.super_cmd->state = PROJECT_PLANE;
               else
                 ME.super_cmd->state = PROCESS;
            }
            else me->next_comp++;
            break;


          case EX_VALUE:

            EFdraw_vector_on_screen(my_id, 
                                    &me->active_display, 
                                    &me->md_env,
                                    GRbe, reverse, 
                                    me->pt_on_crv, 
                                    me->arrvec, 
                                    range, 
                                    &msg_loc);

            if (event.event.value < 0.0) {             
		ex$message(msgnumb = EMS_I_DistMustBepositive);
              	break;
            }

            me->comp_dis[me->next_comp] = event.event.value;
            me->off_code[me->next_comp] = BSCONSTOFF;

            if (me->is_uniform || me->next_comp + 1 == me->num_comps) {
               if (me->is_to_project) 
                 ME.super_cmd->state = PROJECT_PLANE;
               else
                 ME.super_cmd->state = PROCESS;
            }
            else 
               me->next_comp++;

            break;


          case EX_BACK_UP:
             EFdraw_vector_on_screen(my_id, 
                                     &me->active_display, 
                                     &me->md_env,
                                     GRbe, reverse, 
                                     me->pt_on_crv, 
                                     me->arrvec, 
                                     range, 
                                     &msg_loc);

            if (me->is_uniform) {

                stat_OM = dp$erase_hilite(msg = &msg_loc);
                EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
                EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
                ME.super_cmd->state = DIR_POINT;
            } else  {
                stat_OM = dp$erase_hilite(msg = &msg_loc);
                EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
                EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
                ME.ECelement->elem_hilit = FALSE;
                if (me->next_comp > 0) {
                   ME.super_cmd->state = OFF_DIST;
                   me->next_comp--;
                } else
                   ME.super_cmd->state = DIR_POINT;
            }

            break;

          case TERMINATE:
           if (me->plane_constructed) {
             me->plane_constructed = FALSE;
             stat_OM = om$send ( msg = message GRgraphics.GRdelete(
                                        &msg_loc,
                                        const_list.env_info),
                                targetid = me->plnobj.objid,
                                targetos = me->plnobj.osnum);
             EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
             EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
#if dflT1
             printf("in distance und default\n");
#endif
           }
           goto ret_end;

          default:
             EFdraw_vector_on_screen(my_id, 
                                     &me->active_display, 
                                     &me->md_env,
                                     GRbe, 
                                     reverse, 
                                     me->pt_on_crv, 
                                     me->arrvec, 
                                     range, 
                                     &msg_loc);
            goto ret_end;
          }

        if (! me->is_uniform) {
          stat_OM = dp$erase_hilite(msg = &msg_loc);
          EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                   ret_end, errmsg);
          EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
          ME.ECelement->elem_hilit = FALSE;
        }

        break;
   


      case PROJECT_PLANE:
#if dflT1
  printf("in execute state case PROJECT_PLANE\n");
#endif
        loc_mask = GRm_DATA | 
                   GRm_BACK_UP |
                   GRm_RJT_MOVEON;
        acc_mask = GRm_DATA;
 
        lc_attr.properties = LC_LC_ONLY | 
                             LC_DP_ONLY |
                             LC_PLANAR_ONLY | 
                             LC_RW | 
                             IGN_MOD_BIT;
     

        lc_attr.owner_action = LC_RIGID_COMP | 
                               LC_RIGID_OWNER |
                               LC_FLEX_COMP | 
                               LC_REF_OBJECTS | 
                               LC_NO_REF_HEADER |
                               LC_EXTERN_CONSTRAINED |
                               LC_ASSOCIATIVE;

        display_flag = ALL_WINDOWS | 
                       ELEM_HILIGHT | 
                       LC_ERASE_LOC_ELEMENT;

        rtree_classes.w_count = 1;
        eligible_classes.w_count = 2;
        r_classes[0] = OPP_GRvg_class_id;
        e_classes[1] = OPP_EMSsubbs_class_id;
        e_classes[0] = OPP_EMSdatpln_class_id;
        e_classes[2] = OPP_EMSplane_class_id;

        rtree_classes.p_classes = &r_classes[0];
        eligible_classes.p_classes = &e_classes[0];

        rtree_classes.w_flags = eligible_classes.w_flags = OM_CLST_subclass;

        lc_attr.owner_action = lc_attr.owner_action | LC_HANDLES;
        ex$message(msgnumb = EMS_P_AccProPln, buff = acc_prompt);
        ex$message(msgnumb = EMS_P_PiProPln, buff = loc_prompt);
        

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

	/*ex$message(msgnumb = EMS_I_ClearStatusField);
	ex$message(msgnumb = EMS_P_ClearPromptField);*/ 
        if (stat_func == FALSE) {
	  	ex$message(msgnumb = EMS_E_FailInputProcExit);
          	*response = TERMINATE;
          	goto ret_end;
        }



        if (msg_loc == FALSE) {
          if (ME.ECelement->locev.response == EX_BACK_UP) {
            ME.super_cmd->state = ME.super_cmd->state = OFF_DIST;
            break;
          } else
            if (ME.ECelement->locev.response == EX_RJT_MOVEON) {
              /*me->projection_toggle = 0;*/
              me->is_to_project = FALSE;
              ME.super_cmd->state = PROCESS;
              break;
            }
            else
              goto ret_end;
        }

        if (ME.ECelement->locev.response == EX_RJT_MOVEON) {
         me->is_to_project = FALSE;
         ME.super_cmd->state = PROCESS;
         break;
        }
        XXXXX = 3;
        switch (accev.response)
        {
         case EX_DATA:
            
            me->pro_pln_info = accev.located_object[0];
            me->is_to_project = TRUE;



            stat_OM = om$send(msg = message GRvg.GRgeomprops(&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &geom_props),
                              senderid = my_id,
                              targetid = accev.located_object[0].located_obj.objid,
                              targetos = accev.located_object[0].located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            if (geom_props.type == 0 && geom_props.subtype == 6) 
               me->is_refplane = TRUE;
            else 
               me->is_refplane = FALSE;



            plane.point = (IGRdouble *) &plane_point[0];
            plane.normal = (IGRdouble *) &plane_normal[0];
            stat_OM = om$send(mode = OM_e_wrt_object,
                              msg = message GRvg.GRdetplane(&msg_loc,
                                     &me->md_env.md_env.matrix_type,
                                     me->md_env.md_env.matrix,
                                     &plane),
                              senderid = my_id,
                              targetid = accev.located_object[0].located_obj.objid,
                              targetos = accev.located_object[0].located_obj.osnum);
            EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                            ret_end, errmsg);
            EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);

            ME.super_cmd->state = PROCESS;
            break;

          case EX_RJT_MOVEON:
           XXXXX = 2;
           me->is_to_project = FALSE;
           ME.super_cmd->state = PROCESS;
           break; 

          case TERMINATE:
           if (me->plane_constructed) {
             me->plane_constructed = FALSE;
             stat_OM = om$send ( msg = message GRgraphics.GRdelete(
                                        &msg_loc,
                                        const_list.env_info),
                                targetid = me->plnobj.objid,
                                targetos = me->plnobj.osnum);
             EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
             EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
#if dflT1
             printf("in project plane und terminate\n");
#endif
           }
           goto ret_end;

         default:
           goto ret_end;
        }
        break;



      case PROCESS:

#if dflT1
  printf("in execute state case PROCESS\n");
#endif
	ex$message(msgnumb = EMS_S_Processing);

        stat_OM = dp$erase_hilite(msg = &msg_loc);
        EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
             ret_end, errmsg);
        EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
        ME.ECelement->elem_hilit = FALSE;



/* here comes the associativity connection */


 {
    IGRint 		as_o_ctrl_size;
    IGRint 		num_parents;
    IGRchar 		*char_info = NULL;
    IGRchar             *infoblock = NULL;
    OM_S_OBJID 		res_id;
    struct 		as_offset_control {
      unsigned int        offset_control; /* contains a bit mask controlling                                             how to offset */
      IGRint              no_of_distances; /* number of offset distances for
                                              composite curves and 
                                              non-uniform mode */ 
      char                char_data[1];
    };
    struct as_offset_control 	*offsetptr = NULL; 
    struct EMSobject_info    	objects[5]; 
    struct EMSvalue_info  	value; 
 
    if (me->is_uniform) 
      tcount = 1;
    else
      tcount = me->num_comps;

    as_o_ctrl_size = sizeof (struct as_offset_control);
    as_o_ctrl_size += (tcount * sizeof (IGRdouble));
    as_o_ctrl_size += (tcount * sizeof (IGRint)) + 1;

    offsetptr = (struct as_offset_control *) stackalloc(as_o_ctrl_size);
    if (! offsetptr) {
	ex$message(msgnumb = EMS_E_NoMem);
        *response = TERMINATE;
        goto ret_end;
    }
      
    /* set as_offset_control bits */

    offsetptr->offset_control = 0;
    if (me->is_oriented) offsetptr->offset_control |= ORIENTATION;
    XXXXX = 1;
    if (me->is_to_project) offsetptr->offset_control |= PROJECTION;
    if (me->is_uniform) offsetptr->offset_control |= UNIFORM;
    if (me->is_composite) offsetptr->offset_control |= COMPOSITE;
    offsetptr->offset_control |= LOOPS;
    if (me->right_side) offsetptr->offset_control |= RIGHTSIDE;
    if (me->is_planar) offsetptr->offset_control |= PLANAR;
    offsetptr->no_of_distances = me->num_comps;
    if (me->phy_closed) offsetptr->offset_control |= CLOSED;

    /* put the distances into assoc info buffer */
    char_info = offsetptr->char_data;
    for (i=0;i < tcount;i++) {
       OM_BLOCK_MOVE(&me->comp_dis[i],char_info,sizeof(IGRdouble));
       char_info +=  sizeof(IGRdouble) + 1;
    }

    /* put the offset code into assoc info buffer */
    for (i=0;i < tcount;i++) {
       OM_BLOCK_MOVE(&me->off_code[i], char_info, sizeof(IGRint));
       char_info +=  sizeof(IGRint) + 1;
    }
    
    /* at least 2 parents exist; the curve object and the 
       orientation plane object */
    num_parents = 2;

    /* curve object */
    objects[0].grid = me->curve_info.located_obj;
    objects[0].env = me->curve_info.module_info;

    /* orietation plane object */
    if (! me->plane_constructed) {
       objects[1].grid = me->or_pln_info.located_obj;
       objects[1].env = me->or_pln_info.module_info;
    } else {
       objects[1].grid = me->plnobj;
       objects[1].env = ME.ECelement->md_env;
    }

    /* put the project plane  object into the parent array if the 
       project plane exists */
    if (me->is_to_project) {
       objects[num_parents].grid = me->pro_pln_info.located_obj;
       objects[num_parents].env = me->pro_pln_info.module_info;
       num_parents += 1;
    }
     /*create a parametric object of the offset distance if 
       the offset distance is uniform */
    if (me->is_uniform) {
        value.val = me->comp_dis[0];
       value.type = EMSdatainfo_numeric;
       stat_OM = EMgetparval_object (&msg_loc, 
                                     ME.ECelement->md_env.md_id.osnum, 
                                     NULL, 
                                     &value, 
                                     &objects[num_parents]);
       EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
         	  ret_end, errmsg);
       EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, 
         	  ret_end);
       num_parents += 1;
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



    /* check associativity and multiple distances for exclusion */
    if(me->is_associative && (! me->is_uniform)) {
       ex$message(msgnumb = EMS_E_AsMdEx);
       me->error_flag = TRUE;
       ME.super_cmd->state = GET_CURVE;
       stat_OM = dp$erase_hilite(msg = &msg_loc);
       EMomerr_hndlr_action (stat_OM, *response = TERMINATE; goto
                ret_end, errmsg);
       EMerr_hndlr (EMis_error (msg_loc), *response, TERMINATE, ret_end);
       ME.ECelement->elem_hilit = FALSE;
       ME.super_cmd->state = GET_CURVE;
       break;
    }


     /* place associative function */
    sts       = ems$associative_element_by_function(
                msg = &msg_loc,
                associative = ( me->is_associative ? TRUE : FALSE),
                num_parents = num_parents,
                parents = &objects,
                info_size = as_o_ctrl_size,
                info = (IGRchar *) offsetptr,
                function_name = "EFas_ofcv",
                construct_list = &const_list,
                created_id = &res_id);

    if(! (1&msg_loc&sts)) {
         ex$message(msgnumb=EMS_S_OfstCrvCantBeCrtd);
         ME.super_cmd->state = GET_CURVE;
         goto ret_end;
    }
    /*EMerr_hndlr(!(1&sts), msg_loc, EMS_E_Fail, ret_end);*/

    if (me->is_associative && !me->is_to_project) {

       sts = EEplace_autodim(&msg_loc,
                             &const_list,
                             offsetptr->offset_control,
                             my_id,
                             res_id);

   }
    /* display the offset curve */
    dpmode = GRbd;
    sts = om$send (msg = message GRgraphics.GRdisplay(&msg_loc,
                          &me->md_env.md_env.matrix_type,
                          me->md_env.md_env.matrix,
                          &dpmode,
                          &me->md_env.md_id),
                   targetid = res_id,
                   targetos = const_list.env_info->md_id.osnum);
    if (!(1 & sts & msg_loc))  return (OM_E_ABORT);

    /* free assoc info memory */
    if (offsetptr) {
      stackfree(offsetptr);
    }
  }      

    ME.super_cmd->state = GET_CURVE;

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

end implementation ECplasofcv;

