class implementation ECdbgsend;

/*
HISTORY

12 May 1989 jBk      removed methods init and wakeup.
30 Apr 1991 WBC      Commented out references to MSCEXISTS bits for loops and
                     edges since they are no longer being used.
29 May 1991          Restored references to MSCEXISTS bits since they are
                      being used again.
08 Aug 1991 scw      Converted to use gr$dpb associative flag
19 May 1992 NP       Added toggle for timer clocks.
22 May 1992 Rustagi  Modefied for Message Sub-system Compliance. 
17 Jun 1993 NP       Added toggle for fixing/not fixing math intersections 
23 Jun 1993 Janaka   Added the toggle to change the 3-edge 2cx1cv solution.
08 July 1993 Janaka  Added the toggle to force blends as the only vertex
                     solution in rounding.
03 Sep 1996 Aditya   Added toggle to process topological interaction rounding.
*/

#include "EMS.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "igrdp.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "godef.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "EMSmsgdef.h"
#include "EMSlcdef.h"
#include "EMSlc.h"
#include "EC_M.h"
#include "EC_I.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "grgsmacros.h"
#include "EMSobjmgrdef.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSdpb.h"

from OMObjSpace import pass;
from EMSloopset import EMset_props, EMdebug_send;
from EMSloop import EMset_props;
from EMSedge import EMset_props;

extern GRclassid OPP_EMSshobjmgr_class_id, OPP_EMScpmgr_class_id;
extern GRclassid OPP_EMSshovflow_class_id, OPP_EMScleaner_class_id;
extern GRclassid OPP_EMSloopset_class_id, OPP_EMSloop_class_id;
extern GRclassid OPP_EMSedge_class_id;

%safe
IGRboolean _ems_debug=0, _ems_debug_to_file=0;
FILE *_ems_debug_file=NULL;

IGRboolean _new_sfsfint_math = 1;
IGRboolean _use_infinite_plane = 0;
IGRboolean _create_special_partial_surfaces = 1; /* This global is no longer used, it became
                                                    redundant with WANT_POST220_BEHAVIOR */
IGRboolean _fit_sfsfint_xyz_data = 1;
IGRboolean _use_timers=0;
IGRboolean _keep_fillets_patches=0;
IGRboolean _process_tply_interaction=1;
IGRint rnd_2cx1cv_bln	= 0;
IGRint rnd_with_blns_only   = 0;
IGRboolean blend_with_setback =0;
IGRboolean EMSintfWriteFlag = 0;      /* Global used in ECintfi.I */
int pp_output_igds_ems_log = 0;
int pp_igds_ems_num_calls = 0;
int pp_increment = 0;
int pp_output_ems_igds_log = 0;
int pp_ems_igds_num_calls = 0;
int pp_increment_ems_igds = 0;
short _sm_convert_into_plane = 1;
short _sm_skip_int_refinement = 0;
short _sm_use_new_stitching_algorithm = 1;

IGRboolean _allow_intersection_fixing = 1; /* to error out/not error out  if 
                                            * intersections fixed.
                                            */
IGRboolean _skip_intersection_fixing = 0;  /* To fix or not to fix, that is the
                                            * question.
                                            */
IGRboolean WANT_POST220_BEHAVIOR = 1;

IGRboolean _use_runtime_range_support=1;
%endsafe

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func;
  IGRlong msg_loc, stat_OM, eventmask;
  GRobjid mgrobj, osobj;
  GRspacenum osnum;
  struct GRevent event;
  IGRboolean assoc_flag;
  OM_S_CLASSLIST classlist;
  extern void EMremmgr();
  extern IGRlong EMgetmgr(); 

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == 0)
    ex$message(msgnumb = EM_M_DebSenMsg)
  else if (ME.super_cmd->mytype == 1)
    ex$message(msgnumb = EM_M_Togtaggle)
  else if (ME.super_cmd->mytype == 2)
    ex$message(msgnumb = EM_M_ZModSpcount)
  else if (ME.super_cmd->mytype == 3)
    ex$message(msgnumb = EM_M_ZThemModSpcount)
  else if (ME.super_cmd->mytype == 4)
    ex$message(msgnumb = EM_M_TogsfintMath)
  else if (ME.super_cmd->mytype == 5)
    ex$message(msgnumb = EM_M_TogInfPlUsage)
  else if (ME.super_cmd->mytype == 6)
    ex$message(msgnumb = EM_M_Togassplace)
  else if (ME.super_cmd->mytype == 7)
    ex$message(msgnumb = EM_M_TogSpPartsfpl)
  else if (ME.super_cmd->mytype == 8)
    ex$message(msgnumb = EM_M_Togsfintdat)
  else if (ME.super_cmd->mytype == 9)
    ex$message(msgnumb = EM_M_Togticlk)

  /* WHAT ABOUT mytype == 10??? ***************/
/*
  else if (ME.super_cmd->mytype == 11)
    ex$message(msgnumb = EM_M_ZToggleIntrFixing)
  else if (ME.super_cmd->mytype == 12)
    ex$message(msgnumb = EM_M_ZToggleSkipFixing)
  else if (ME.super_cmd->mytype == 13)
    ex$message(msgnumb = EM_M_ToggleRnd2cx1cvSol )
  else if (ME.super_cmd->mytype == 14)
    ex$message(msgnumb = EM_M_ToggleRndBlnSolu )
*/
  else if (ME.super_cmd->mytype == 15)
    UI_message ("Toggle Internal Debug");
  else if (ME.super_cmd->mytype == 16)
    UI_message ("Display Graphics Object");


  if (ME.super_cmd->mytype == 0)
    EMdebug_send();
  else if (ME.super_cmd->mytype == 1)
    {
    OM_Gf_tagging_enabled = !OM_Gf_tagging_enabled;
    if (OM_Gf_tagging_enabled)
      ex$message(msgnumb = EMS_S_TagEnble)	
    else
      ex$message(msgnumb = EMS_S_TagDisble) 
    ems_sleep (2);
    }
  else if (ME.super_cmd->mytype == 2)
    {
    ex$message(msgnumb = EMS_P_EntOsnum);
    eventmask = GRm_VALUE;
    stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                 value_type = GRIO_SCALAR, response = response,
                 response_data = response_data, event = &event);
    ex$message(msgnumb = EMS_P_ClearPromptField);
    if (!EMSerror (stat_func))
      {
      if (event.response == EX_VALUE)
        {
        osnum = event.event.value;

        mgrobj = NULL_OBJID;
        stat_OM = EMgetmgr (&msg_loc, osnum, OPP_EMScpmgr_class_id,
                   EMScp_sfbdry, &mgrobj);

        stat_OM = om$send (msg = message Root.delete (TRUE), 
                   targetid = mgrobj, targetos = osnum);
       
        stat_OM = EMgetmgr (&msg_loc, osnum, OPP_EMSshobjmgr_class_id,
                   EMSshobj_sfbdry, &mgrobj);

        stat_OM = om$send (msg = message Root.delete (TRUE), 
                   targetid = mgrobj, targetos = osnum);
        }
      }
    }
  else if (ME.super_cmd->mytype == 3)
    {
    ex$message(msgnumb=EMS_P_EntOsnum);
    eventmask = GRm_VALUE;
    stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                 value_type = GRIO_SCALAR, response = response,
                 response_data = response_data, event = &event);
    ex$message(msgnumb = EMS_P_ClearPromptField);
    if (!EMSerror (stat_func))
      {
      if (event.response == EX_VALUE)
        {
        osnum = event.event.value;

        mgrobj = NULL_OBJID;
        EMgetmgr (&msg_loc, osnum, OPP_EMScpmgr_class_id, EMScp_sfbdry,
         &mgrobj);
        EMremmgr (&msg_loc, osnum, OPP_EMScpmgr_class_id, EMScp_sfbdry);

        EMgetmgr (&msg_loc, osnum, OPP_EMSshobjmgr_class_id, EMSshobj_sfbdry,
         &mgrobj);
        EMremmgr (&msg_loc, osnum, OPP_EMSshobjmgr_class_id, EMSshobj_sfbdry);

        stat_OM = om$osnum_to_oso_objid (osnum = osnum, p_objid = &osobj);
        if (EMSerror (stat_OM))
          {
          ex$message(msgnumb = EMS_E_CnotfinOS);
          goto ret_end;
          }
        classlist.w_count = 1;
        classlist.w_flags = OM_CLST_subclass;

        classlist.p_classes = &OPP_EMScpmgr_class_id;
        stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
                   OM_e_wrt_message, message Root.delete (TRUE)),
                   targetid = osobj, targetos = osnum);

        classlist.p_classes = &OPP_EMSshobjmgr_class_id;
        stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
                   OM_e_wrt_message, message Root.delete (TRUE)),
                   targetid = osobj, targetos = osnum);

        classlist.p_classes = &OPP_EMSshovflow_class_id;
        stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
                   OM_e_wrt_message, message Root.delete (TRUE)),
                   targetid = osobj, targetos = osnum);

        classlist.p_classes = &OPP_EMScleaner_class_id;
        stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
                   OM_e_wrt_message, message Root.delete (TRUE)),
                   targetid = osobj, targetos = osnum);


        classlist.p_classes = &OPP_EMSloopset_class_id;
        stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
                   OM_e_wrt_object, message EMSloopset.EMset_props
                   (&msg_loc, EMLS_SHELL, EMS_O_OFF)), 
                   targetid = osobj, targetos = osnum);

        classlist.p_classes = &OPP_EMSloop_class_id;
        stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
                   OM_e_wrt_object, message EMSloop.EMset_props
                   (&msg_loc, EMLP_MSCEXISTS, EMS_O_OFF)), 
                   targetid = osobj, targetos = osnum);

        classlist.p_classes = &OPP_EMSedge_class_id;
        stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
                   OM_e_wrt_object, message EMSedge.EMset_props
                   (&msg_loc, /* EMED_MSCCOMMON | */ EMED_MSCEXISTS, EMS_O_OFF)),
                   targetid = osobj, targetos = osnum);
        }
      }
    }
  else if (ME.super_cmd->mytype == 4)
    {
    _new_sfsfint_math = !_new_sfsfint_math;
    if (_new_sfsfint_math)
      ex$message(msgnumb = EMS_S_NwMathRuAct)
    else
      ex$message(msgnumb = EMS_S_OlMathRuAct);
    ems_sleep (2);
    }
  else if (ME.super_cmd->mytype == 5)
    {
    _use_infinite_plane = !_use_infinite_plane;
    if (_use_infinite_plane)
      ex$message(msgnumb = EMS_S_InfPlUsAct)
    else
      ex$message(msgnumb = EMS_S_NoInfPlUse);
    ems_sleep (2);
    }
  else if (ME.super_cmd->mytype == 6)
    {
    gr$get_associative_flag( buffer = &assoc_flag );
    if (EMSerror (stat_OM))
      {
      ex$message(msgnumb = EMS_S_IntErrOcc);
      goto ret_end;
      }

    if (assoc_flag)
      assoc_flag = FALSE;
    else
      assoc_flag = TRUE;

    gr$put_associative_flag( buffer = &assoc_flag );

    if (EMSerror (stat_OM))
      {
      ex$message(msgnumb = EMS_S_IntErrOcc);
      goto ret_end;
      }

    if (assoc_flag)
      ex$message(msgnumb = EMS_S_AssPlaAct)
    else
      ex$message(msgnumb = EMS_S_NonassPlact);
    ems_sleep (2);
    }
  else if (ME.super_cmd->mytype == 7)
    {
    _create_special_partial_surfaces = !_create_special_partial_surfaces;
    if (_create_special_partial_surfaces)
      ex$message(msgnumb = EMS_S_SpePartSfgen)
    else
      ex$message(msgnumb = EMS_S_NoSpePartSfgen);
    ems_sleep (2);
    }
  else if (ME.super_cmd->mytype == 8)
    {
/*****************
     ex$message(msgnumb = EMS_S_SuintDatFtNotAv);
    _fit_sfsfint_xyz_data = 0;
******************/

    _fit_sfsfint_xyz_data = !_fit_sfsfint_xyz_data;
    if (_fit_sfsfint_xyz_data)
      ex$message(msgnumb = EMS_S_SfintDatWbeFt)
    else
      ex$message(msgnumb = EMS_S_SfintDatWNbeFt);

    ems_sleep (3);
    }
  else if (ME.super_cmd->mytype == 9)
    {
    _use_timers = !_use_timers;
    if (_use_timers)
      ex$message(msgnumb = EMS_S_TimClkAct)
    else
      ex$message(msgnumb = EMS_S_TimClkNoAct);
    ems_sleep (3);
    }
  else if (ME.super_cmd->mytype == 10)
    {
    _keep_fillets_patches = !_keep_fillets_patches;
    if (_keep_fillets_patches)
	ex$message(msgnumb = EMS_S_KeepFillPat)
    else
	ex$message(msgnumb = EMS_S_DoNotKeepFillPat);
    ems_sleep (3);
    }
  else if (ME.super_cmd->mytype == 11)
    {
    _allow_intersection_fixing = !_allow_intersection_fixing;
    if (_allow_intersection_fixing)
	ex$message(msgnumb = EMS_S_NoErrorOnIntrFixing)
    else
	ex$message(msgnumb = EMS_S_ErrorOnIntrFixing);
    ems_sleep (3);
    }
   else if (ME.super_cmd->mytype == 12)
    {
    _skip_intersection_fixing = !_skip_intersection_fixing;
    if (_skip_intersection_fixing)
        ex$message(msgnumb = EMS_S_SkipIntrFixing)
    else
        ex$message(msgnumb = EMS_S_DontSkipIntrFixing);
    ems_sleep (3);
    } 
   else if (ME.super_cmd->mytype == 13)
    {
     rnd_2cx1cv_bln = !rnd_2cx1cv_bln;
     if( rnd_2cx1cv_bln )
        ex$message(msgnumb = EMS_S_Rnd2cx1cvBlend )
     else
        ex$message(msgnumb = EMS_S_Rnd2cx1cvIntersect );
     ems_sleep (3);
    } 
   else if (ME.super_cmd->mytype == 14)
    {
     rnd_with_blns_only = !rnd_with_blns_only;
     if( rnd_with_blns_only )
        ex$message(msgnumb = EMS_S_RndBlnOnly )
     else
        ex$message(msgnumb = EMS_S_RndSpecificSolu );
     ems_sleep (3);
    }
  else if (ME.super_cmd->mytype == 15)
    {
    _ems_debug = !_ems_debug;
    if (_ems_debug)
      UI_status ("Internal Debug ON");
    else
      UI_status ("Internal Debug OFF");
    ems_sleep (3);

    if (_ems_debug)
      {
      IGRchar filename[50];
      IGRint yes;

      printf ("Debug to a file? (1/0) _: ");
      scanf ("%d", &yes);
      if (yes)
        {
        printf ("Filename _: ");
        scanf ("%s", filename);
        _ems_debug_file = fopen (filename, "w");
        if (!_ems_debug_file)
          {
          fprintf (stderr, "Error opening file - %s\n", filename);
          _ems_debug_to_file = FALSE;
          }
        else
          _ems_debug_to_file = TRUE;
        }
      else
        _ems_debug_to_file = FALSE;
      }
    else
      {
      if (_ems_debug_to_file)
        fclose (_ems_debug_file);
      _ems_debug_to_file = FALSE;
      _ems_debug_file = NULL;
      }
    }
  else if (ME.super_cmd->mytype == 16)
    {
    GRobjid objid;

    ex$message(msgnumb = EMS_P_EntOsnum);
    eventmask = GRm_VALUE;
    co$getevent (msg = &msg_loc, event_mask = eventmask,
                 value_type = GRIO_SCALAR, response = response,
                 response_data = response_data, event = &event);
    ex$message(msgnumb = EMS_P_ClearPromptField);
    if (event.response == EX_VALUE)
      osnum = event.event.value;
    else
      goto ret_end;

    ex$message(msgnumb = EMS_P_EntObjid);
    eventmask = GRm_VALUE;
    co$getevent (msg = &msg_loc, event_mask = eventmask,
                 value_type = GRIO_SCALAR, response = response,
                 response_data = response_data, event = &event);
    ex$message(msgnumb = EMS_P_ClearPromptField);
    if (event.response == EX_VALUE)
      objid = event.event.value;
    else
      goto ret_end;

    EMdbgdisp (objid, osnum, 0);
    }
  else if (ME.super_cmd->mytype == 17)
    {
    _use_runtime_range_support = !_use_runtime_range_support;
    if (_use_runtime_range_support)
      UI_status ("USING run-time surface range support");
    else
      UI_status ("NOT USING run-time surface range support");
    ems_sleep (3);
    }
   else if (ME.super_cmd->mytype == 18)
    {
     blend_with_setback = !blend_with_setback;
     if( blend_with_setback )
        ex$message(msgnumb = EMS_S_BlendSetBackSol )
     else
        ex$message(msgnumb = EMS_S_BlendNonSetBackSol );
     ems_sleep (3);
    } 
   else if (ME.super_cmd->mytype == 19)
    {
     _process_tply_interaction = !_process_tply_interaction;
     if( _process_tply_interaction )
        ex$message(msgnumb = EMS_S_ProcRndTplyIntn )
     else
        ex$message(msgnumb = EMS_S_DonotProcRndTplyIntn );
     ems_sleep (3);
    }
 
ret_end:
  *response = TERMINATE;
  return (OM_S_SUCCESS);
}

end implementation ECdbgsend;
