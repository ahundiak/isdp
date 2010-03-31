product_name   "$MODEL"
command_string "chamfer",0,EMPCh
class          ECchamfer
super_class    ECconst
spec_path      "$MODEL/spec"

specification
/*
Abstract
        This command object class gathers the data and calls the
        methods needed to construct a chamfer between 2 linear
        elements.

History
        LL       16/10/87        date of creation
        LL       14/1/88         converted to version 1.1
        gupta    01/25/88        fixed bugs
        dhm      6/1/88          added Jeff J.'s code.
        rlw      01/05/89        Fixed command key
        dhm      03/23/89        Fixed display located channel problem by
                                 initializing event1's module_info.
        Carlos   05/11/92        Changed locate statements on states
                                 'start' and 'next'.
*/
instance
{
  IGRpoint      setback_point1, setback_point2, isect_point;
  IGRdouble     alpha;
}

implementation
/*
Abstract
        This method gathers the information needed to chamfer two
        linear elements. It takes in the point of intersection of
        two elements, two offset distances/one offset and an angle.
*/

#include "EMS.h"
#include "msdef.h"   /*MS message definitions */
#include <stdio.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "ECcmd_def.h"
#include "emserr.h"
#include "emsdef.h"
#include "exmacros.h"
#include "bsparameters.h"
#include "bserr.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "grmsg.h"

from GRgraphics import GRdisplay;
from GRvg import GRgetsize;
from GRvg import GRgetgeom;
from GRvg import EMpratpt;
from GRcurve import GRptalong;
from GRcurve import GRptextend;
from GRcurve import GRendpts;

state_table
#include "msdef.h"
#include "EMSlogic.h"
#include "lcdef.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "grmsg.h"


state start
   execute              init_event1_md_env
   highlight_located    0      /* dehighlighted located channel */
   disconnect_located   1      /* disconnect objects from locate channel */
   message_key          EM_M_Chmf
   prompt_key           GR_P_Id1stLn
   accept_key           EMS_P_AccSelSecLn
   relocate_key         EMS_P_LineNotFound
   locate_class         "GR3dlineseg"
   locate_display       "ELEM_HILIGHT | ONE_WINDOW"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY"
   locate_owner         "LC_FLEX_COMP"
   status_key           EMS_S_ClearStatusField
   filter               locate_noauto
   on EX_BACK_UP        state start
   on EX_DATA           do status_key EMS_S_ClearStatusField
                        do ECcmd.EMsave_located_object(&me->event1,
                                 &me->located_obj[0])
                        do ECcmd.EMpush_button_on_stack(&me->event1)
                        state next

state next 
   prompt_key          GR_P_Id2ndLn
   accept_key          EMS_P_00038
   relocate_key        EMS_P_LineNotFound
   locate_class        "GR3dlineseg"
   locate_display       "ELEM_HILIGHT | ONE_WINDOW"
   locate_properties    "LC_LC_ONLY | LC_DP_ONLY"
   locate_owner         "LC_FLEX_COMP"
   status_key          EMS_S_ClearStatusField
   filter              locate_noauto
   on EX_BACK_UP       do highlight_located 0
                       state start
   on EX_DATA          do status_key EMS_S_ClearStatusField
                       do ECcmd.EMsave_located_object(&me->event1,
                                             &me->located_obj[1])
                       do intersect(&me->located_obj[0],
                                    &me->located_obj[1], me->isect_point)
                          on MSFAIL    state inter_err  
                       state keyin_setback1

state keyin_setback1
   prompt_key          EMS_P_KyInSetBkDsOnLn1
   filter              get_event
   on EX_BACK_UP       do dehilite_curve
                       state next
   on DISTANCE         do status_key EMS_S_ClearStatusField
                       do check_distance(&me->ret,
                                         &me->event1.event.value)
                       on MSINARG state err_in_size1   
                       do process1(me->located_obj, me->setback_point1,
                                   me->isect_point)
                          on MSFAIL      state err_in_size1
                       state keyin_angle

state keyin_angle
   execute             ECconst.EMdisplay_construct_lines(&me->ret, 1, 
                                     me->setback_point1, GRbd)
   prompt_key          EMS_P_KyInAnNnMvOn
   filter              get_event
   execute             ECconst.EMdisplay_construct_lines(&me->ret, 1, 
                                     me->setback_point1, GRbehe)
   on EX_BACK_UP       state keyin_setback1
   on ANGLE=0          state keyin_setback2
   on ANGLE            do status_key EMS_S_ClearStatusField
                       do store_angle (&me->alpha, &me->event1)
                       do process2
                          on MSINARG     state invalid_angle
                          on MSFAIL      state err_in_const
                       state start
   on EX_RJT_MOVEON    state keyin_setback2    

state keyin_setback2
    prompt_key         EMS_P_KyInSetBkDsOnLn2
    filter             get_event
    on EX_BACK_UP      state keyin_angle
    on DISTANCE        do status_key EMS_S_ClearStatusField
                       do check_distance(&me->ret,
                                         &me->event1.event.value)
                       on MSINARG state err_in_size2   
                      
                       do process1(&me->located_obj[1], me->setback_point2,
                                   me->isect_point)
                          on MSFAIL        state err_in_size2
                       do process2
                          on MSFAIL     state err_in_const
                       state start

state inter_err
    status_key         EMS_E_ErrLnDNIsect
    on ELSE            state start

state err_in_size1
    status_key         EMS_E_ErrInvDs
    on ELSE            state keyin_setback1

state err_in_size2
    status_key         EMS_E_ErrInvDs
    on ELSE            state keyin_setback2

state err_in_const
    prompt_key         EMS_P_ClearPromptField
    status_key         EMS_I_ErrorInConstruction
    on ELSE            state start

state invalid_angle
    prompt_key         EMS_P_ClearPromptField
    status_key         EMS_E_ErrInvAn
    on ELSE            state keyin_angle


action init_event1_md_env
{
  OM_BLOCK_MOVE(&me->ModuleInfo, &me->event1.located_object[0].module_info,
                sizeof(struct GRmd_env));

}


action init
{
    status = om$send(mode = OM_e_wrt_message,
                      msg = message CEO_LOCATE.init(type, str_ptr),
                      targetid = my_id);
    EMomerr_hndlr(status, quit, "CEO_LOCATE init");

    status = om$send(mode = OM_e_wrt_message,
                     msg = message ECconst.init(type, str_ptr),
                     targetid = my_id);
    EMomerr_hndlr(status, quit, "ECconst init");
    me->alpha = NULL;
}

action dehilite_curve
{
  IGRlong    msg;
        
        me->DisplayMode = GRhe;
        status = om$send(msg = message GRgraphics.GRdisplay(&msg,
                              &me->ModuleInfo.md_env.matrix_type,
                              me->ModuleInfo.md_env.matrix,
                              &me->DisplayMode, &me->ModuleInfo.md_id),
                       senderid = my_id,
                       targetid = me->located_obj[1].located_obj.objid,
                       targetos = me->located_obj[1].located_obj.osnum);
      EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
      EMerr_hndlr(EMis_error(msg), me->ret, MSFAIL, ret_end); 

ret_end:
   return (status);
}

action intersect(struct GRlc_info *line1; struct GRlc_info *line2; 
                               IGRpoint isect_point)
{
    IGRlong            msg_loc,size;
    struct IGRline     ln1, ln2;
    struct IGRbsp_curve *cv1, *cv2;
    IGRchar            errmsg[EMMAXERRMSG_LEN];
    IGRdouble          tol, t1, t2;

    me->ret = MSSUCC;
    strcpy (errmsg, "GRsubbc.EMchamfer");
    cv1 = NULL;
    cv2 = NULL;

    status = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRgetsize(&msg_loc,
                            &line1->module_info.md_env.matrix_type,
                            line1->module_info.md_env.matrix, &size),
                 senderid = my_id,
                 targetid = line1->located_obj.objid,
                 targetos = line1->located_obj.osnum);
    EMomerr_hndlr (status, ret_end, errmsg);
    EMerr_hndlr (EMis_error (msg_loc), me->ret, msg_loc, ret_end);
    cv1 = (struct IGRbsp_curve *) om$malloc (size = size);
    EMerr_hndlr (!cv1, me->ret, MSNOMEM, ret_end);

    status = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRgetgeom (&msg_loc,
                             &line1->module_info.md_env.matrix_type, 
                             line1->module_info.md_env.matrix, (char *)cv1),
                 senderid = my_id,
                 targetid = line1->located_obj.objid,
                 targetos = line1->located_obj.osnum);
    EMomerr_hndlr (status, ret_end, errmsg);
    EMerr_hndlr (EMis_error (msg_loc), me->ret, msg_loc, ret_end);

    status = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRgetsize(&msg_loc,
                              &line2->module_info.md_env.matrix_type,
                              line2->module_info.md_env.matrix, &size),
                 senderid = my_id,
                 targetid = line2->located_obj.objid,
                 targetos = line2->located_obj.osnum);
    EMomerr_hndlr (status, ret_end, errmsg);
    EMerr_hndlr (EMis_error (msg_loc), me->ret, msg_loc, ret_end);
    cv2 = (struct IGRbsp_curve *) om$malloc (size = size);
    EMerr_hndlr (!cv2, me->ret, MSNOMEM, ret_end);

    status = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRgetgeom (&msg_loc,
                              &line2->module_info.md_env.matrix_type,
                             line2->module_info.md_env.matrix, (char *)cv2),
                 senderid = my_id,
                 targetid = line2->located_obj.objid,
                 targetos = line2->located_obj.osnum);
    EMomerr_hndlr (status, ret_end, errmsg);
    EMerr_hndlr (EMis_error (msg_loc), me->ret, msg_loc, ret_end);
    tol = .0001;

    ln1.point1 = &cv1->poles[0];
    ln1.point2 = &cv1->poles[(cv1->num_poles-1)*3];
    ln2.point1 = &cv2->poles[0];
    ln2.point2 = &cv2->poles[(cv2->num_poles-1)*3];

    MA2lnisect(&msg_loc, &ln1, &ln2, &tol, isect_point, &t1, &t2);
    EMerr_hndlr (msg_loc != MSSUCC, me->ret, MSFAIL, ret_end);

ret_end:
    if(cv1)
    {
        om$dealloc (ptr = cv1);
    }
    if(cv2)
    {
     om$dealloc (ptr = cv2);
    }

}

action check_distance(int *sts; IGRdouble *value)
{
    if (*value <= 0)
    {
       *sts = MSINARG;
    }
}

action process1(struct GRlc_info *ln; IGRpoint point; IGRpoint isect_point)
{
    IGRlong              msg_loc, sts, size;
    IGRpoint             point1, point2;
    struct IGRbsp_curve  *cv_line;
/*    struct GRparms       parm1, parm2; */
    IGRdouble            sqr_dist, dist1, dist2, input_dist;
    extern IGRdouble     BSdistptpt();
    IGRchar           errmsg[EMMAXERRMSG_LEN];

    me->ret = MSSUCC;
    strcpy (errmsg, "error in process1");
    cv_line = NULL;
    input_dist = me->event1.event.value;

    status = om$send(mode = OM_e_wrt_object, 
                 msg = message GRvg.GRgetsize(&msg_loc, 
                         &ln->module_info.md_env.matrix_type, 
                         ln->module_info.md_env.matrix, &size), 
            senderid = my_id, 
            targetid = ln->located_obj.objid, 
            targetos = ln->located_obj.osnum);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error (msg_loc), me->ret, MSFAIL, ret_end);

    cv_line = (struct IGRbsp_curve *) om$malloc (size = size);
    EMerr_hndlr (!cv_line, me->ret, MSNOMEM, ret_end);

    status = om$send (mode = OM_e_wrt_object, 
                  msg = message GRvg.GRgetgeom (&msg_loc, 
                          &ln->module_info.md_env.matrix_type, 
                          ln->module_info.md_env.matrix, (char *)cv_line),
             senderid = my_id, 
             targetid = ln->located_obj.objid,
            targetos = ln->located_obj.osnum);
    EMomerr_hndlr (status, ret_end, errmsg);
    EMerr_hndlr (EMis_error (msg_loc), me->ret, MSFAIL, ret_end);

     point1[0] = isect_point[0];
     point1[1] = isect_point[1];
     point1[2] = isect_point[2];

     dist1 = BSdistptpt(&msg_loc, isect_point, &cv_line->poles[0]);
     EMerr_hndlr(msg_loc != BSSUCC, me->ret, MSFAIL, ret_end);

     dist2 = BSdistptpt(&msg_loc, isect_point,
                        &cv_line->poles[(cv_line->num_poles-1)*3]);
     EMerr_hndlr(msg_loc != BSSUCC, me->ret, MSFAIL, ret_end);
 
     if (dist1 > dist2)
     {
        sqr_dist = dist1;
        point2[0] = cv_line->poles[0];
        point2[1] = cv_line->poles[1];
        point2[2] = cv_line->poles[2];
     }
     else
     {
        sqr_dist = dist2;
        point2[0] = cv_line->poles[((cv_line->num_poles-1)*3)];
        point2[1] = cv_line->poles[((cv_line->num_poles-1)*3)+1];
        point2[2] = cv_line->poles[((cv_line->num_poles-1)*3)+2];
     }

     point[0] = point1[0] + input_dist * ((point2[0] - point1[0])/ sqr_dist);
     point[1] = point1[1] + input_dist * ((point2[1] - point1[1])/ sqr_dist);
     point[2] = point1[2] + input_dist * ((point2[2] - point1[2])/ sqr_dist);

/******  Take out for now *******************************************

    status = om$send(msg = message GRvg.EMpratpt(&msg_loc, 
                       &ln->module_info.md_env.matrix_type, 
                       ln->module_info.md_env.matrix, point1, &parm1.u,
                       &num_parm), 
                 senderid = my_id, 
                 targetid = ln->located_obj.objid, 
                 targetos = ln->located_obj.osnum);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), me->ret, MSFAIL, ret_end);

    status = om$send(msg = message GRvg.EMpratpt(&msg_loc, 
                       &ln->module_info.md_env.matrix_type, 
                       ln->module_info.md_env.matrix, point2, &parm2.u,
                       &num_parm), 
                 senderid = my_id, 
                 targetid = ln->located_obj.objid, 
                 targetos = ln->located_obj.osnum);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), me->ret, MSFAIL, ret_end);

    status = om$send(msg = message GRcurve.GRptalong(&msg_loc,
                            &ln->module_info.md_env.matrix_type, 
                            ln->module_info.md_env.matrix, 
                            point1,point2, &parm1, &parm2,
                            &input_dist, point), 
            senderid = my_id,
            targetid = ln->located_obj.objid, 
            targetos = ln->located_obj.osnum);
    EMomerr_hndlr (status, ret_end, errmsg);
    EMerr_hndlr (EMis_error (msg_loc), me->ret, MSFAIL, ret_end);            

*********************************************************************/

ret_end:
    if (cv_line)
   {
    om$dealloc (ptr = cv_line);
   }
}       

action store_angle (IGRdouble *alpha; struct GRevent *event)
{
    me->ret =  MSSUCC;
    status = OM_S_SUCCESS;

    *alpha = event->event.value;

}

action process2
{
    IGRlong              msg;
    GRobjid              chamfer_id; /* the object id of the chamfer */
    IGRlong  size, num_bytes;
    IGRchar  errmsg[EMMAXERRMSG_LEN];
    IGRpoint point_1, point_2, start_pt, end_pt;

    me->ret = MSSUCC;    
    strcpy(errmsg, "GRsubbc.EMchamfer");
    ex$message(msgnumb = EMS_P_ClearPromptField);
    ex$message(msgnumb = EMS_I_00003);

    me->DisplayMode = GRbehe;
    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[0].module_info.md_env.matrix_type,
                            me->located_obj[0].module_info.md_env.matrix,
                            &me->DisplayMode,
                            &me->located_obj[0].module_info.md_id),
                senderid = my_id,
                targetid = me->located_obj[0].located_obj.objid, 
                targetos = me->located_obj[0].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
    EMerr_hndlr(EMis_error(msg), me->ret, MSFAIL, ret_end);

    me->DisplayMode = GRbehe;
    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[1].module_info.md_env.matrix_type,
                            me->located_obj[1].module_info.md_env.matrix, 
                            &me->DisplayMode,
                            &me->located_obj[1].module_info.md_id),
                senderid = my_id,
                targetid = me->located_obj[1].located_obj.objid, 
                targetos = me->located_obj[1].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
    EMerr_hndlr(EMis_error(msg), me->ret, MSFAIL, ret_end);

    /* Needed to set the point that init_construct is
     * going to use to get the construct environment
     * for the construct_list.
     */
    me->point[0][0] = me->setback_point1[0];
    me->point[0][1] = me->setback_point1[1];
    me->point[0][2] = me->setback_point1[2];
    me->num_points = 1;

    status = om$send(mode = OM_e_wrt_message,
                     msg = message ECconst.init_construct(sts),
                     targetid = my_id);
    EMomerr_hndlr(status, ret_end, "ECconst.init_construct error");
    EMerr_hndlr(EMis_error(*sts), me->ret, MSFAIL, ret_end);

    status = EMchamfer(&msg,
                       &me->located_obj[0].module_info.md_env.matrix_type,
                       me->located_obj[0].module_info.md_env.matrix,
                       me->located_obj[0].located_obj.objid, 
                       &me->construct_list, me->located_obj[1],
                       me->setback_point1, me->setback_point2, 
                       me->isect_point, me->alpha, &chamfer_id);
    EMomerr_hndlr(status, ret_end, "EMchamfer error")
    EMerr_hndlr(EMis_error(msg), me->ret, msg, ret_end);

    status = om$send(mode = OM_e_wrt_object, 
                     msg = message GRcurve.GRendpts(&msg, 
                           &me->located_obj[0].module_info.md_env.matrix_type,
                           me->located_obj[0].module_info.md_env.matrix,  
                           start_pt, end_pt), 
                     senderid = my_id, 
                     targetid = chamfer_id,
                targetos = me->located_obj[1].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr (EMis_error(msg), me->ret, MSFAIL, ret_end);

    status = om$send(mode = OM_e_wrt_object, 
                     msg = message GRcurve.GRptextend(&msg, 
                           &me->located_obj[0].module_info, 
                           me->isect_point, start_pt, point_1), 
                     senderid = my_id, 
                     targetid = me->located_obj[0].located_obj.objid, 
                     targetos = me->located_obj[0].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr (EMis_error(msg), me->ret, MSFAIL, ret_end);

    status = om$send(mode = OM_e_wrt_object, 
                     msg = message GRcurve.GRptextend(&msg, 
                           &me->located_obj[1].module_info, 
                           me->isect_point, end_pt, point_2), 
                     senderid = my_id, 
                     targetid = me->located_obj[1].located_obj.objid, 
                     targetos = me->located_obj[1].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, errmsg);
    EMerr_hndlr (EMis_error(msg), me->ret, MSFAIL, ret_end);

    me->DisplayMode = GRbd;
    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[0].module_info.md_env.matrix_type,
                            me->located_obj[0].module_info.md_env.matrix,
                            &me->DisplayMode,
                            &me->located_obj[0].module_info.md_id),
                senderid = my_id,
                targetid = me->located_obj[0].located_obj.objid, 
                targetos = me->located_obj[0].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
    EMerr_hndlr(EMis_error(msg), me->ret, MSFAIL, ret_end);

    me->DisplayMode = GRbd;
    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRgraphics.GRdisplay(&msg,
                            &me->located_obj[1].module_info.md_env.matrix_type,
                            me->located_obj[1].module_info.md_env.matrix, 
                            &me->DisplayMode,
                            &me->located_obj[1].module_info.md_id),
                senderid = my_id,
                targetid = me->located_obj[1].located_obj.objid, 
                targetos = me->located_obj[1].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
    EMerr_hndlr(EMis_error(msg), me->ret, MSFAIL, ret_end);

    size = sizeof(struct GRmd_env);
    gr$get_display_env(msg = &msg,
                       sizbuf = &size,
                       buffer = &me->ModuleInfo,
                       nret = &num_bytes);
    EMerr_hndlr(EMis_error(msg), status, OM_E_ABORT, ret_end);

    me->DisplayMode = GRbd;
    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRgraphics.GRdisplay(&msg,
                                &me->ModuleInfo.md_env.matrix_type,
                                me->ModuleInfo.md_env.matrix,
                                &me->DisplayMode, &me->ModuleInfo.md_id),
                senderid = my_id,
                targetid = chamfer_id,
                targetos = me->located_obj[1].located_obj.osnum);
    EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
    EMerr_hndlr(EMis_error(msg), me->ret, MSFAIL, ret_end);

ret_end:
    ex$message(msgnumb = EMS_S_ClearStatusField);
}


action arg_name_to_value
        /* Incoming */
/*  int           addr_mode;    /* == _COB_regular  for regular data  */
                                /* == _COB_indirect for "*<arg>"      */
                                /* == _COB_address  for "&<arg>"      */
/*  char        * class_name;   /* not NULL => argname used to start  */
                                /*   with "me(class_name)->" of some  */
                                /*   form; now this has been stripped */
                                /* NULL => original arg had no "me->" */
/*  char        * arg;          /* arg string to find a value for     */
        /* Outgoing */
/*  COB_arg_union * data;       /* value of arg string variable       */
/*  int         * ret_type;     /* type of value found for arg string */
                                /*   (see COB_arg.h)                  */
/*  char        * is_const;)    /* set to 1 => this variable value is */
                                /*   "constant" and needn't be looked */
                                /*   up ever again                    */
/*
  translate a string into its variable name value
  Jeff Johnson's code.
*/

{
  int              arg_num;
  char           * ch = '\0';


  * ret_type = _COB_UNKNOWN_ARG;
  * is_const = 0;

  if ( class_name[0] )  /*** arg string used to begin with "me->" ***/
    {
        /**************************************************************/
        /*                ECchamfer instance data                     */
        /**************************************************************/
      if ( !strcmp(arg, "alpha") )
        {
          if ( addr_mode == _COB_regular )
            {
              data->d = ME.ECchamfer->alpha;
              * ret_type = _COB_arg_d;
            }
          else if ( addr_mode == _COB_address )
            {
              data->p = (char *) & ME.ECchamfer->alpha;
              * ret_type = _COB_arg_p;
              * is_const = 1;
            }
        } /*** ME.ECchamfer->alpha ***/
      else if ( ! strcmp ( arg, "setback_point1" ) )
        {
          if ( addr_mode == _COB_regular )
            {
              data->p = (char *) ME.ECchamfer->setback_point1;
              * ret_type = _COB_arg_p;
              * is_const = 1;
            }
        }  /*** ME.ECchamfer->setback_point1 ***/
      else if ( ! strncmp ( arg, "setback_point1[", 15 ) )
        {
          /*** get the # within the [ ]'s ***/
          arg_num = COB_fetch_first_arg_num ( arg, &ch );

#define IGR_POINT_DIM   3
          if ( arg_num < 0  ||  arg_num >= IGR_POINT_DIM )
            {
              fprintf ( stderr,
                "\nECchamfer.arg_name_to_value():  Reference to ME.ECchamfer->setback_point1[%d]\n\tin state table argument is invalid\n\n", arg_num );
            }
          else
            {
              if ( addr_mode == _COB_regular )
                {
                  data->d = ME.ECchamfer->setback_point1 [arg_num];
                  * ret_type = _COB_arg_d;
                }
              else if ( addr_mode == _COB_address )
                {
                  data->p = (char *) & ME.ECchamfer->setback_point1 [arg_num];
                  * ret_type = _COB_arg_p;
                  * is_const = 1;
                }
            }
        }  /*** ME.ECchamfer->setback_point1[x] ***/
      else if ( ! strcmp ( arg, "setback_point2" ) )
        {
          if ( addr_mode == _COB_regular )
            {
              data->p = (char *) ME.ECchamfer->setback_point2;
              * ret_type = _COB_arg_p;
              * is_const = 1;
            }
        }  /*** ME.ECchamfer->setback_point2 ***/
      else if ( ! strncmp ( arg, "setback_point2[", 15 ) )
        {
          /*** get the # within the [ ]'s ***/
          arg_num = COB_fetch_first_arg_num ( arg, &ch );

#define IGR_POINT_DIM   3
          if ( arg_num < 0  ||  arg_num >= IGR_POINT_DIM )
            {
              fprintf ( stderr,
                "\nECchamfer.arg_name_to_value():  Reference to ME.ECchamfer->setback_point2[%d]\n\tin state table argument is invalid\n\n", arg_num );
            }
          else
            {
              if ( addr_mode == _COB_regular )
                {
                  data->d = ME.ECchamfer->setback_point2 [arg_num];
                  * ret_type = _COB_arg_d;
                }
              else if ( addr_mode == _COB_address )
                {
                  data->p = (char *) & ME.ECchamfer->setback_point2 [arg_num];
                  * ret_type = _COB_arg_p;
                  * is_const = 1;
                }
            }
        }  /*** ME.ECchamfer->setback_point2[x] ***/
      else if ( ! strcmp ( arg, "isect_point" ) )
        {
          if ( addr_mode == _COB_regular )
            {
              data->p = (char *) ME.ECchamfer->isect_point;
              * ret_type = _COB_arg_p;
              * is_const = 1;
            }
        }  /*** ME.ECchamfer->isect_point ***/
      else if ( ! strncmp ( arg, "isect_point[", 12 ) )
        {
          /*** get the # within the [ ]'s ***/
          arg_num = COB_fetch_first_arg_num ( arg, &ch );

#define IGR_POINT_DIM   3
          if ( arg_num < 0  ||  arg_num >= IGR_POINT_DIM )
            {
              fprintf ( stderr,
                "\nECchamfer.arg_name_to_value():  Reference to ME.ECchamfer->isect_point[%d]\n\tin state table argument is invalid\n\n", arg_num );
            }
          else
            {
              if ( addr_mode == _COB_regular )
                {
                  data->d = ME.ECchamfer->isect_point [arg_num];
                  * ret_type = _COB_arg_d;
                }
              else if ( addr_mode == _COB_address )
                {
                  data->p = (char *) & ME.ECchamfer->isect_point [arg_num];
                  * ret_type = _COB_arg_p;
                  * is_const = 1;
                }
            }
        }  /*** ME.ECchamfer->isect_point[x] ***/
    }
  else  /*** arg string did not begin with "me->" ***/
    {
    }

        /*** if it's unknown, send it to parent ***/
  if ( * ret_type == _COB_UNKNOWN_ARG )
    {
      status = om$send ( targetid = my_id,
                         mode = OM_e_wrt_message,
                         msg = message ECcmd.arg_name_to_value (
                                        addr_mode, class_name, arg,
                                        data, ret_type, is_const ) );
      _check ( status );
    }

} /*** end of ECchamfer.arg_name_to_value method ***/
