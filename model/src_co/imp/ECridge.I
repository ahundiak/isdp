/*
 DESCRIPTION
    
    This is the command object for Add/Remove material functionality.

 HISTORY

    Rustagi : ????????   Creation
    Sanjay  : 03/08/94   Modified to make the functionality associative.
    Sanjay  : 03/09/94   Fixed a bug related to giving a snap point in dynamics.
    Sanjay  : 05/25/94   Fixed a bug related to projection direction in case of
                         projected and one-sided case.
    Sanjay  : 06/06/94   Total Re-Write. Fixed many problems. They are:
                         a. Fixed all the memory leaks.
                         b. Fixed the problems related to running PPL files. 
                            Earlier it used to crash.
                         c. Whereever possible moved malloc to alloca. 
                         d. Added two variables to the instance data and 
                            removed the unnecessary ones. 
                         e. Fixed all the problems related to "dyanmics off" 
                            and "play back" 
                         f. Removed the duplicate calls to "GRvg.GRdetplane" 
                            instead added an argument to the instance data
                            which will store the profile plane normal.
                         g. Modified the way the dynamcis arrow shown when 
                            "Projected, finite, symmetric, non-normal" option 
                            is selected. Earlier it used to show an arrow in 
                            one direction. Now it shows two arrows on either 
                            side of pivot point because it is symmetric.
                         h. Proper initialization of the instance data.
                         i. Whereever it is required, changed the logic also.
                         j. Modified the way the dyanmics functions behave. 
                            Earlier they used get the geometry each and every 
                            time. 
                         k. Now the "instance data" population depends on the 
                            output from "co$getevent" macro rather than the 
                            dynamics functions. This will solve all the 
                            problems related to getting the data from events. 
    Sanjay : 06/08/94    Instead of storing the material addition direction a 
                         flag which indicates the material additon direction 
                         is stored in the parent information structure. Added  
                         code to calculate the boolean flag. See documentation 
                         for more details.
    Sanjay : 09/19/94    Added code to not to select the same same surface as 
                         From and To Surfaces in case of planes and ref. planes.
    Sanjay : 08/02/95    Don't locate the soilds from reference files as base 
                         solids. 
    Sanjay : 08/03/95    I don't know, when will we do "RIGHT THINGS RIGHT". 
                         Somebody forgot to set the "POST310" bit on this class
                         of objects. 
    Sanjay : 09/06/95    Modified the command not to prompt for "Enter start 
                         point/move on for profile plane" in case of projected
                         finite option.
    Sanjay : 09/07/95    Modified the command not to prompt for "Select rev. 
                         side" in case of from-to. That way the material will
                         always be added in the quardant in  which the profile 
                         sits.
*/

class implementation ECridge;

#include <math.h>
#include "OMmacros.h"
#include "bsvalues.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "lcdef.h"
#include "lc.h"
#include "madef.h"
#include "exmacros.h" 
#include "lcmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "EC_I.h"
#include "EC_M.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "EMSaction.h"
#include "emserr.h"
#include "EMSasopts.h"
#include "EMSdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "EMSasmacros.h"
#include "dpstruct.h"
#include "bsconic.h"
#include "EMSasopts.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSlogic.h"
#include "emsdattyp.h"
#include "EMSopt.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsfeaopts.h"
#include "EMSsfintsort.h"

#include "REaddrmfea.h"
#include "EMSfeadef.h"
#include "EMSasfeatdef.h"
#include "addrmopts.h"

#ifndef EMScmacros_include
#include "EMScmacros.h"
#endif

#ifndef EMSlogic_include
#include "EMSlogic.h"
#endif

#ifndef bserr_include
#include "bserr.h"
#endif

#ifndef bsparameters_include
#include "bsparameters.h"
#endif

#include "bsvalues.h"
#include "bscollin.h"
#include "bspl_of_cv.h"
#include "bsarclength.h"
#include "bsrev_cv.h"
#include "bssfnormal.h"
#include "bspl_tan_tc.h"
#include "bspl_nor_tc.h"
#include "bscvarrevt.h"
#include "bsnorvec.h"
#include "bsprptoncv.h"
#include "bsdistptli.h"
#include "bsprepcarc.h"
#include "bsdistptpt.h"
#include "bsdistptpts.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsptlngen.h"
#include "bsmkvec.h"
#include "bsproj0.h"
#include "bsprepcirc.h"
#include "bscvtstclsd.h"
#include "bscveval.h"
#include "bscollinmn2.h"
#include "bsplane3pt.h"
#include "bspl_cv_int.h"
#include "bspartofcv.h"
#include "bsmdstptcv.h"
#include "bststcvdegn.h"
#include "bsprepcircp.h"
#include "bspl_cv_int.h"

#include "PWminimum.h"
#include "PWapi/dbgobjs.h"

#define FAIL 0
#define NUM_STATIC_GEOMPARMS	10

/* Additional ME.super_cmd->mytype constants for debug */

#define PLACE_PROTRUSION_DEBUG  99
#define PLACE_CUTOUT_DEBUG  98

/* for me->const_state use */

#define INIT 0
#define EXEC 1
#define DONE 2 
#define UNDO 3 
#define DNUD 4 

/* These define statements are for the sake of clarity */

#define LOCATE_PROFILE 0
#define LOCATE_FROM_SURFACE 1
#define LOCATE_TO_SURFACE 2
#define LOCATE_AXIS 3
#define LOCATE_TRACE_CURVE 4
#define LOCATE_SOLID 5

/* command states */

#define BEGIN_STATE                       0
#define SELECT_PROFILE                    1 
#define SELECT_ADD_MAT_SIDE               2
#define ENT_2nd_PT_OF_PRJ_VEC             3
#define SELECT_PRJ_SIDE                   4
#define SELECT_REV_SIDE                   5
#define SELECT_FROM_SURF_OR_REF_PLN       6
#define SELECT_TO_SURF_OR_REF_PLN         7
#define ENTER_START_PLANE                 8
#define ENTER_SYMMETRIC_DIST              9 
#define ENTER_DISTANCE                    10
#define SELECT_AXIS                       11 
#define ENTER_START_ANGLE                 12 
#define ENT_SYMM_SWEEP_ANG                13
#define ENT_SWEEP_ANGLE                   14
#define SELECT_TRACE_CURVE                15
#define SELECT_SOLID                      16
#define FEATURE_PLACEMENT_STATE           17 

#define FORM1                             1
#define FORM2                             2

#ifdef DEBUG
#define ERROR(sts, msg, error_message) \
 {\
    if(! (1 & sts & msg))\
    {\
        printf("\nIn ECridge: %s\n", error_message); \
        sts = FAIL; \
        goto ret_end;\
    }\
 }
#else
#define ERROR(sts, msg, error_message) \
 {\
    if(! (1 & sts & msg))\
    {\
        sts = FAIL; \
        goto ret_end;\
    }\
 }
#endif

/* imports */

from GRgraphics  import GRdisplay,GRdelete;
from EMSdpr      import EMundo, EMsetprops;
from EMSassoc    import EMpack_paraminfo,EMlocate_geomparam;
from GRvg        import GRdetplane, GRgetsize, GRgetgeom, GRgetrang,GRchgprops;
from GRcurve     import EMcrvcrvint, GRendpts;
from EMScnstr    import EMinit;
from NDnode      import NDdisconnect;
/* externs */

extern OMuword OPP_GRcurve_class_id, OPP_GRbspline_class_id;
extern OMuword OPP_GRlinear_class_id, OPP_GR3dpoint_class_id;
extern OMuword OPP_EMSdatpln_class_id, OPP_EMSsurface_class_id;
extern OMuword OPP_EMSsubbs_class_id, OPP_EMSslboolfea_class_id;
extern OMuword OPP_EMSslfeature_class_id, OPP_EMSplane_class_id;
extern OMuword OPP_SKgeometry_class_id, OPP_GAcurve_class_id;
extern OMuword OPP_EMSsolid_class_id, OPP_EMSsfrembnd_class_id;
extern OMuword OPP_EMSasptcnstr_class_id,OPP_EMSparvcnstr_class_id; 
extern OMuword OPP_EMScnstrtxt_class_id;

extern short _Pathway, _pathway_trim, _pathway_orient;

extern unsigned int OM_Gf_verbose_warning;

extern IGRlong EFlocate_action_handler(), EMgetvggeom();
extern IGRboolean EFloop_curves_locatable();
extern IGRboolean EFedge_curves_locatable();
extern IGRboolean EFboundary_curves_locatable();
extern IGRlong EMcreate_add_rem_mat_feature_projected();
extern IGRboolean EFisAncestryValid();
extern IGRlong EFdisplay_curve_normal_or_tangent();
extern IGRlong EFdetermine_direction();
extern IGRboolean EFboreline();

%safe
static IGRint EFpivotline(), EFsymmlinedyn(), EFlinedyn(), EFsymmarcdyn();
static IGRint EFarrlinedyn(), EFarcdyn();
static IGRboolean aflag;
%endsafe

/*
 * This is for my reference.
 *
 * Sequence for locating different elements.
 *
 * 1. locate profile
 * 2. locate "from" surface.
 * 3. locate "to" surface.
 * 4. locate "axis"
 * 5. locate "trace curve"
 * 6. locate "solid"
 */ 

method init(int type; char *str_ptr)
{
   IGRlong  sts;
   IGRint   event, ret;
   IGRint   ECridge_process_form();

   sts = OM_S_SUCCESS;

   /*
    * Initialize the instance data of the object
    */
   ME.super_cmd->state       = BEGIN_STATE;
   ME.super_cmd->form_id     = NULL_OBJID;
   me->projected             = TRUE;
   me->revolved              = FALSE;
   me->skinned               = FALSE;
   me->from_to               = FALSE;
   me->from_surf_id.objid    = NULL_OBJID;
   me->to_surf_id.objid      = NULL_OBJID;
   me->proj_dist             = 0.0;
   me->sweep_angle           = 0.0;
   me->thru_all              = FALSE;
   me->thru_next             = FALSE;
   me->to_next               = FALSE;
   me->finite                = FALSE;
   me->symmetric             = FALSE;
   me->normal                = TRUE;
   me->is_close              = TRUE;
   me->numobjs               = 0;
   me->const_state           = INIT;
   me->form1                 = NULL;
   me->form_displayed        = FALSE;
   me->construct_id.objid    = NULL_OBJID;

   memset( me->axis_vec,         0, sizeof(IGRvector) );
   memset( me->pivot_pnt,        0, sizeof(IGRpoint) );
   memset( me->matadd_vector,    0, sizeof(IGRvector) );
   memset( me->projection_vec,   0, sizeof(IGRvector) );
   memset( me->vec_nor_prfpln,   0, sizeof(IGRvector) );
   memset( me->vec_along_prfpln, 0, sizeof(IGRvector) );
   memset( &(me->locate_event),  0, sizeof(struct GRevent) ); 
   memset( &(me->locate_stack),  0, sizeof(struct GRlc_stack) );
   for (event=0; event<6; event++)
   {
     memset (&(me->loc_events[event]), 0, sizeof(struct GRevent) );
     me->loc_events[event].located_object[0].located_obj.objid = NULL_OBJID;
     me->loc_events[event].located_object[1].located_obj.objid = NULL_OBJID;
   }

   /* 
    * Initialise my parent stuff 
    */
   sts = om$send( mode     = OM_e_wrt_message,
                  msg      = message COconst.init( type, str_ptr),
                  targetid = my_id);
   ERROR(sts, 1, "init.init error")

   if(ME.super_cmd->mytype == PLACE_PROTRUSION)
   {
      me->thru_all = FALSE;
      me->to_next = TRUE;

      ret = FIf_new(FORM1, "MDProtrusion", ECridge_process_form,
                    &ME.ECridge->form1);
      if(ret) return (OM_E_ABORT);
   }
   else if(ME.super_cmd->mytype == PLACE_CUTOUT)
   {
      me->thru_all = TRUE;
      me->to_next = FALSE;
      ret = FIf_new(FORM2, "EMCutout1", ECridge_process_form,
                    &ME.ECridge->form1);
      if(ret) return (OM_E_ABORT);
   }
  
ret_end:
   return(sts);
} /* init */

method wakeup(int pos)
{
   IGRint            ret;
   IGRlong           msg, sts;
   IGRboolean        state;
   enum GRdpmode     DisplayMode;
   struct GRlc_info  *info=NULL;
 
   /*
    * Check whether the associative lock is on/off. If it is on then high light
    * the same otherwise don't do anything.
    */
   gr$get_associative_flag(buffer = &state);

   if(state)
   {
      me->associative = TRUE;
      GRdisplay_associative_button(TRUE);
   }
   else me->associative = FALSE;

   /*  
    * Display the command name in the messgage strip
    */
   if(ME.super_cmd->mytype == PLACE_PROTRUSION)
   {
      ex$message(msgnumb = EM_M_AddMtl)
   }
   else if(ME.super_cmd->mytype == PLACE_CUTOUT)
   {
      ex$message(msgnumb = EM_M_RmMtl)
   }

   msg          = EMS_S_Success;
   sts          = OM_S_SUCCESS;
   DisplayMode  = GRbd;
  
   if(me->const_state == DONE || me->const_state == DNUD)
   {
      info = &me->loc_events[LOCATE_SOLID].located_object[0];
      if(om$is_objid_valid(objid = me->construct_id.objid) == OM_S_SUCCESS)
      {
         sts = om$send( msg = message GRgraphics.GRdisplay(&msg,
                                      &info->module_info.md_env.matrix_type,
                                      info->module_info.md_env.matrix,
                                      &DisplayMode, &info->module_info.md_id),
                        targetid = me->construct_id.objid,
                        targetos = me->construct_id.osnum);
         ERROR(sts, msg, "wakeup.GRdisplay(1) error")
      }
      else
      if(om$is_objid_valid(objid = info->located_obj.objid) == OM_S_SUCCESS)
      {
         sts = om$send( msg = message GRgraphics.GRdisplay(&msg,
                                      &info->module_info.md_env.matrix_type,
                                      info->module_info.md_env.matrix,
                                      &DisplayMode, &info->module_info.md_id),
                        targetid = info->located_obj.objid,
                        targetos = info->located_obj.osnum);
         ERROR(sts, msg, "wakeup.GRdisplay error")
      }
   }

   /*
    * If asked for the options form, display it
    */ 
   if(me->form_displayed == TRUE)
      ret = FIf_display(ME.ECridge->form1);

ret_end:
   return(OM_S_SUCCESS);

} /* wakeup() */

method super_cmd.sleep(int pos)
{
   IGRlong        msg, sts, *response,junk;
   enum GRdpmode  DisplayMode;

   sts          = OM_S_SUCCESS;
   msg          = EMS_S_Success;
   DisplayMode  = GRbdhe;

   response = (IGRlong *) &junk;
   sts      = dp$erase_hilite(msg = &msg);
   ERROR(sts, msg, "dp$erase_hilite error")

   /*
    * If asked for the sleep, then de-highlight the associative button and
    * check-off the form and also clear all the  message fields
    */ 
   if(me->associative)
      GRdisplay_associative_button(FALSE); 
   if(me->form_displayed == TRUE)
      FIf_erase(ME.ECridge->form1);
  
   ex$message(msgnumb = EMS_P_ClearPromptField)
   ex$message(msgnumb = EMS_S_ClearStatusField)
   ex$message(msgnumb = EM_M_ClearMessageField)
  
ret_end:
   return(OM_S_SUCCESS);

} /* end of sleep */

method delete(int f_defer_flag)
{
   IGRlong  sts;
   sts = om$send( mode      = OM_e_wrt_message, 
                  msg       = message COroot.delete(1),
                  targetid  = my_id);
   ERROR(sts, 1, "delete.me error")

ret_end:
   return(sts);
} /* delete */


method execute(int *response; char *response_data; int pos)
{ /* beggining of execute */
 
 /* general variables declaration */
 BSrc            rc;
 IGRint          event_size, type, i;
 IGRchar         locate_prompt[52], accept_prompt[52], relocate_prompt[52];
 IGRchar         cmd_string_raw[60], cmd_string[80];
 GRrange         range;
 IGRlong         sts, msg_loc, event_mask, num_bytes, feaopts, matopts;
 IGRlong         locate_mask, accept_mask, object_was_located, display_flag;
 IGRpoint        proj_pnt, junkpt, wpt, prof_tan[2], cross_vec, prof_pnt;
 IGRpoint        loctmp1, loctmp2, start_pnt, stop_pnt, loctmp_vec, cursor_pt;
 IGRvector       vector, unit_vec, tmp_vec, vec0, vec1, NORMAL;
 IGRdouble       parval, temp_pt[2][3], value1, value2, line[2][3];
 IGRdouble       cht, radius, points[2][3], other_points[2][3], max_len;
 IGRdouble       zero, arcln, arctol, loc_value, ang_val, lentol, wdist; 
 IGRushort       options;
 IGRboolean      success, world, is_degen1, is_degen2, stat_func, degen_curve;
 IGRboolean      loop_locatable, edge_locatable, bdry_locatable, ok=TRUE;
 IGRboolean      curve_reversed=FALSE;

 /* variables needed for locating the objects */
 IGRlong                putque_size;
 OMuword                rclass, eliclass, reject_classid;
 GRobjid                *display_ids;
 struct GRid            tmp_id;
 struct GRevent         event, acc_event, loc_event;
 OM_S_CLASSLIST         rtree_classes, elig_classes;
 enum  GRdpmode         DisplayMode;
 struct GRlc_info       *info=NULL;
 struct IGRdisplay      disp_attr;
 struct IGRpolyline     polyline, other_polyline;
 struct GRlc_locate     attributes;
 struct dynfunc_args    dynargs;
 struct GRvg_construct  const_args;
 struct EMSaction_handler dont_locate;

 /* variables related to the profile, surface and solid geometrices */
 struct GRid          prof_id, refplnid, trac_id , cnstr_grid,cnstr1_grid,disid;
 struct IGResbc       ele_attr;
 struct IGRplane      plane_of_curve;
 struct IGRbsp_curve  *profgeom=NULL, *geom_axis=NULL;
 struct GRmd_env   mod;
 IGRshort mattyp;
 IGRdouble *mat;
 IGRpoint blinept1,blinept2;
 struct IGRline  bline;
 IGRint num_geom_params,num_aspt_parents,subtype,cnstrobjs;
 GRobjid *geom_params;
 IGRshort param_types,j;
 GRobjid paramobj; 
 long send_rc;
 struct GRevent *ev;
 struct GRid           aspt_parents[2],axid;
 struct EMSasptinfo    asptinfo; 
 OM_S_CHANSELECT to_text;
 OM_S_OBJECT_LINKAGE *text_ids;
 OMuint num_objs;
 IGRuint num_text;
 OMuword classid;
 enum GRdpmode  mode;
 /* Variables for Recompute Information */
 struct EMSAddRm_RecompInfo   recomp_info;
 struct EMSAddRm_ParentInfo   parent_info;

 extern       IGRlong EFplace_feature();
 IGRlong      EMget_profile_refpln_id();
 IGRboolean   MatInsideYesNo(), GetRightNormal();
 IGRboolean   AddRmGetNormalOfPlaneOfPts();
 
 sts = BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
 sts = BSEXTRACTPAR(&rc, BSTOLARCLEN, arctol);
 sts = BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);


 /* Initailize the return status */
 sts           = OM_S_SUCCESS;
 msg_loc       = EMS_S_Success;

 /* Initialize the local variables */ 
 feaopts               = NULL;
 matopts               = NULL;
 *response             = TERMINATE; 
 event_size            = sizeof(struct GRevent);
 display_ids           = NULL;
 degen_curve           = FALSE;

 /* Allocate the memory for the plane of the profile */
 plane_of_curve.point    = (double *) alloca (sizeof (IGRpoint));
 plane_of_curve.normal   = (double *) alloca (sizeof (IGRvector));
 world = TRUE;

 /* Allocate the memory for the dynamic function arguments */
 num_bytes = BSCIRCLE_NUM_POLES_MAX * sizeof(IGRpoint);

 for( i=0; i<3; i++ )
 {
    dynargs.curvebuff[i].poles   = (IGRdouble *) alloca( num_bytes );
    dynargs.curvebuff[i].knots   = (IGRdouble *) alloca( 
                                   BSCIRCLE_NUM_KNOTS_MAX * sizeof(IGRdouble));
    dynargs.curvebuff[i].weights = (IGRdouble *) alloca( num_bytes );
 }

 /* Initialize the dynargs structure */
 dynargs.cmd_id.objid             = my_id;
 dynargs.cmd_id.osnum             = OM_Gw_current_OS;
 dynargs.arrow_head[0].num_points = 3;
 dynargs.arrow_head[1].num_points = 3;
 dynargs.arrow_head[0].points     = (IGRdouble *)dynargs.arrow_points[0];
 dynargs.arrow_head[1].points     = (IGRdouble *)dynargs.arrow_points[1];
 dynargs.arrow_vector.points      = (IGRdouble *)dynargs.arrow_vector_pts;
 dynargs.arrow_vector.num_points  = 2;

 loop_locatable = FALSE;
 edge_locatable = FALSE;
 bdry_locatable = FALSE;


 /* Display the command name in the command strip */
 if(ME.super_cmd->mytype == PLACE_PROTRUSION)
 {
    ex$message(msgnumb = EM_M_AddMtl)
    matopts |= EMSadd_material;
 }
 else if(ME.super_cmd->mytype == PLACE_CUTOUT)
 {
    ex$message(msgnumb = EM_M_RmMtl)
    matopts |= EMSremove_material;
 }
 else if(ME.super_cmd->mytype == PLACE_PROTRUSION_DEBUG)
 {
    ex$message(msgnumb = EM_M_AddMtl, buff=cmd_string_raw, buffer_size=60);
    strcpy (cmd_string, cmd_string_raw);
    strcat (cmd_string, " -- Debug");
    UI_message (cmd_string);
    matopts |= EMSadd_material;
 }
 else if(ME.super_cmd->mytype == PLACE_CUTOUT_DEBUG)
 {
    ex$message(msgnumb = EM_M_RmMtl, buff=cmd_string_raw, buffer_size=60);
    strcpy (cmd_string, cmd_string_raw);
    strcat (cmd_string, " -- Debug");
    UI_message (cmd_string);
    matopts |= EMSremove_material;
 }

 if(me->const_state != DONE)
 {
   ex$message(msgnumb = EMS_I_InvkStatusFrm)
   GRstatus_display_button(1);
 }

 disp_attr.color = ME.COconst->ActiveDisplay.color;
 disp_attr.weight = ME.COconst->ActiveDisplay.weight;
 disp_attr.style = ME.COconst->ActiveDisplay.style;

 /* switch for the command object states */ 
 do
 {
   switch(ME.super_cmd->state)
   {
     /* ------------------------------------------------------------------- *
      *                           Initial State                             *
      * ------------------------------------------------------------------- */

     case BEGIN_STATE:
       ME.super_cmd->state = SELECT_PROFILE;
       if (ME.super_cmd->mytype == PLACE_PROTRUSION_DEBUG ||
           ME.super_cmd->mytype == PLACE_CUTOUT_DEBUG)
       {
         struct GRmd_env md_env;
         gr$get_module_env (buffer = &md_env);
         pwInitDbgObject (md_env.md_id.osnum);
       }
       break;

     /* ------------------------------------------------------------------- *
      *                        Select The Profile                           *
      * ------------------------------------------------------------------- */

     case SELECT_PROFILE:
     {

       memset( &dont_locate, 0, sizeof(struct EMSaction_handler) );

       if(me->const_state == DONE)
       {
         ex$message(msgnumb = EMS_I_ProcessCompBackUpToUndo)
       }

       reject_classid = OPP_GR3dpoint_class_id;
       dont_locate.next = NULL;
       dont_locate.option = 2;
       dont_locate.type = 3;
       dont_locate.num_objects = 1;
       dont_locate.objects.classids = &reject_classid;

       display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
       locate_mask  = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
       accept_mask  = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
    
       if (me->skinned) 
         ex$message(msgnumb = EMS_P_00166, buff = locate_prompt)
       else
         ex$message(msgnumb = EMS_P_IdentifyProfile, buff = locate_prompt)
       ex$message(msgnumb = EMS_P_00038 , buff = accept_prompt)
       ex$message(msgnumb = EMS_I_ProfileNotFound, buff = relocate_prompt)

       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_PLANAR_ONLY |
                                 LC_RW;
       aflag = pwIsActivationOn();
       if (aflag)
       {
       attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                                 LC_NO_REF_HEADER | LC_REF_OBJECTS;
       /** Removed NO_REF_OBJECTS for RFA **/
       }
       else
       {
       attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                                 LC_NO_REF_HEADER | LC_NO_REF_OBJECTS;
       }

       strcpy(attributes.classes, "GRcurve");

       rclass                    = OPP_GRcurve_class_id;
       eliclass                  = OPP_GRcurve_class_id;
       rtree_classes.w_count     = 1;
       elig_classes.w_count      = 1;
       rtree_classes.w_flags     = OM_CLST_subclass;
       elig_classes.w_flags      = OM_CLST_subclass;
       rtree_classes.p_classes   = &rclass;
       elig_classes.p_classes    = &eliclass;
     
       stat_func = lc$locate( rc                = &object_was_located,
                              event1            = &me->locate_event,
                              event2            = &acc_event,
                              event3            = &loc_event,
                              mask1             = locate_mask,
                              mask2             = accept_mask,
                              eventsize         = &event_size,
                              display_flag      = display_flag,
                              response          = response,
                              response_data     = response_data,
                              locate_prompt     = locate_prompt,
                              acc_prompt        = accept_prompt,
                              relocate_prompt   = relocate_prompt,
                              act_handler       = EFlocate_action_handler,
                              act_args          = &dont_locate,
                              attributes        = &attributes,
                              stack             = &me->locate_stack,
                              rtree_classes     = &rtree_classes,
                              eligible_classes  = &elig_classes); 

       ex$message(msgnumb = EMS_P_ClearPromptField)
       ex$message(msgnumb = EMS_S_ClearStatusField)

       OM_BLOCK_MOVE(&loc_event, &event, event_size);
       if(stat_func == FALSE)
       {
         ex$message(msgnumb = EMS_E_FailInputProcExit)
         *response = TERMINATE;
         goto ret_end;
       }

       /* If the object is not located */
       if(!object_was_located)
       {
         switch(loc_event.response)
         {
           case EX_BACK_UP:
             if(me->const_state == DONE)
             {
               IGRushort option;
               IGRint display_count, involk_count;
    
               display_ids = NULL;
               display_count = involk_count = 0; 
               option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;
               info = &me->loc_events[LOCATE_SOLID].located_object[0];
               sts = om$send(msg = message EMSdpr.EMundo(&msg_loc,
                                           &option, &info->module_info, NULL, 
                                           NULL, NULL, &display_ids, 
                                           &display_count, &involk_count),
                             targetid = me->construct_id.objid,
                             targetos = me->construct_id.osnum);
               ERROR(sts, msg_loc, "execute.EMundo error");

               me->const_state = DNUD;

               /*
                * Redraw the profile.
                */
               DisplayMode = GRbd;
               info = &me->loc_events[LOCATE_PROFILE].located_object[0];
               sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                   &info->module_info.md_env.matrix_type,
                                   info->module_info.md_env.matrix,
                                   &DisplayMode,
                                   &info->module_info.md_id),
                             targetid = info->located_obj.objid,
                             targetos = info->located_obj.osnum);
               ERROR(sts, msg_loc, "execute.GRgraphics.GRdisplay error")
               ME.super_cmd->state = SELECT_SOLID;
             }
             else
               ME.super_cmd->state = BEGIN_STATE;
             break;

           default:
             sts = OM_S_SUCCESS;
             goto  ret_end;

         }/* end of the switch(loc_event.response) */

       } /* if(!object_was_located) */

       else /* if the object is located */

       {
         sts = dp$erase_hilite(msg = &msg_loc);
         ERROR(sts, msg_loc, "execute.erase_hilite error")
         OM_BLOCK_MOVE(&loc_event, &me->loc_events[LOCATE_PROFILE], event_size);
         me->numobjs ++;

         switch(acc_event.response)
         {
           case EX_DATA:

           /*
            * Calculate the profile plane normal once, so that it is not 
            * required to calculate wherever it is not needed as it is 
            * stored in the instance data of the object.
            */ 
           info = &me->loc_events[LOCATE_PROFILE].located_object[0];
           sts = om$send( msg = message GRvg.GRdetplane(&msg_loc,
                                        &info->module_info.md_env.matrix_type,
                                        info->module_info.md_env.matrix,
                                        &plane_of_curve ),
                          targetid = info->located_obj.objid,
                          targetos = info->located_obj.osnum);
           if( !(1&sts&msg_loc) )
           {
               ex$message(msgnumb = EMS_S_IndetminPlane)
               sleep(1);
               ME.super_cmd->state = SELECT_PROFILE;
               break;
           }

           BSnorvec(&rc, plane_of_curve.normal);

           OM_BLOCK_MOVE (plane_of_curve.point, 
                     me->loc_events[LOCATE_PROFILE].located_object[1].proj_pnt, 
                     sizeof (IGRpoint));
           /*
            * Find if the located curve is closed or not.
            */
           info = &me->loc_events[LOCATE_PROFILE].located_object[0];
           tmp_id.objid = info->located_obj.objid;
           tmp_id.osnum = info->located_obj.osnum;

           sts = om$send( msg = message GRvg.GRgetsize(&msg_loc,
                                        &info->module_info.md_env.matrix_type,
                                        info->module_info.md_env.matrix, 
                                        &num_bytes),
                          targetid = tmp_id.objid,
                          targetos = tmp_id.osnum);

           ERROR(sts, msg_loc, "execute.GRvg.GRgetsize error")

           /*
            * Allocate the memory for the profile geometry 
            */
           profgeom = (struct IGRbsp_curve *) alloca( num_bytes );
           if( !profgeom ) 
           {
             printf("ECridge.execute: Insufficient Memory \n");
             sts = OM_E_ABORT; 
             goto  ret_end;
           }

           sts = om$send( msg = message GRvg.GRgetgeom(&msg_loc,
                                        &info->module_info.md_env.matrix_type,
                                        info->module_info.md_env.matrix,
                                        (IGRchar *)profgeom),
                          targetid = tmp_id.objid,
                          targetos = tmp_id.osnum);
           ERROR(sts, msg_loc, "execute.GRvg.GRgetgeom error")

           if (!profgeom->phy_closed && me->skinned)
           {
             ex$message(msgnumb = EMS_I_00014)
             ME.super_cmd->state = SELECT_PROFILE;
             break;
           }

           // Check for degenracy of the profile selected
           (void) BStstcvdegn( profgeom, &degen_curve, &rc);
           if( degen_curve )
           {
             ex$message(msgnumb = EMS_E_BsMathErIsDgnC)
             sleep(1);
             ME.super_cmd->state = SELECT_PROFILE;
             break; 
           }

           BSmdstptcv (profgeom, loc_event.located_object[0].proj_pnt, 
                       &parval, me->pivot_pnt, &wdist, &rc );
           if( BSERROR(rc) ) goto ret_end;

           OM_BLOCK_MOVE (me->pivot_pnt, loc_event.located_object[0].proj_pnt,
                          sizeof (IGRpoint));
           OM_BLOCK_MOVE( me->pivot_pnt, dynargs.the_point, sizeof(IGRpoint));

           /*
            * store the profile normal in the instance data and the profile
            * plane point in the locate event structure of the instance data.
            */
           OM_BLOCK_MOVE (me->pivot_pnt,
              me->loc_events[LOCATE_PROFILE].located_object[0].proj_pnt,
              sizeof(IGRpoint) );
           OM_BLOCK_MOVE (me->pivot_pnt, plane_of_curve.point, 
                          sizeof (IGRpoint));

           /*
            * get the right profile normal
            */
           if (!EFisAncestryValid(&msg_loc, tmp_id.objid, tmp_id.osnum,
                                  OPP_SKgeometry_class_id, FALSE) && 
               !EFisAncestryValid(&msg_loc, tmp_id.objid, tmp_id.osnum,
                                  OPP_GAcurve_class_id, FALSE))
           {
             if (AddRmGetNormalOfPlaneOfPts (profgeom->num_poles, 
                                             profgeom->poles, 
                 profgeom->rational ? profgeom->weights : NULL, NORMAL))
             {
               OM_BLOCK_MOVE (NORMAL, me->vec_nor_prfpln, sizeof(IGRvector));
               OM_BLOCK_MOVE (NORMAL, plane_of_curve.normal, sizeof(IGRvector));
             }
             else if (OM_Gf_verbose_warning)
             {
               printf ("\nAddRm Msg : Unable to calculate the right normal\n");
             }
           }

           /*
            * store the profile normal in the instance data.
            */
           OM_BLOCK_MOVE (plane_of_curve.normal, me->vec_nor_prfpln,
                          sizeof(IGRvector) );
 
           /*
            * if the projection is normal then this information needs to be
            * stored in the instance data.
            */
           if( me->normal )
           {
             me->projection_vec[0] = plane_of_curve.normal[0];
             me->projection_vec[1] = plane_of_curve.normal[1];
             me->projection_vec[2] = plane_of_curve.normal[2];
           }
 
           OM_BLOCK_MOVE( me->pivot_pnt, dynargs.the_point, sizeof(IGRpoint));
           OM_BLOCK_MOVE( me->projection_vec, dynargs.vec_nor_prfpln,
                          sizeof(IGRvector));
 
           (void)BScvtstclsd(profgeom, &rc);
           me->is_close = profgeom->phy_closed;

           if(!me->is_close)
             ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
           else
           {
             if(me->projected)
             {
               if(!me->normal)
               {
                 if(me->finite)
                   ME.super_cmd->state = ENTER_START_PLANE;
                 else
                   ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
               }
               else
               {
                 if(me->thru_all)
                   ME.super_cmd->state = SELECT_SOLID;
                 else if(me->to_next || me->thru_next)
                   ME.super_cmd->state = SELECT_PRJ_SIDE; 
                 else if(me->from_to)
                   ME.super_cmd->state = SELECT_FROM_SURF_OR_REF_PLN; 
                 else if(me->finite)
                   ME.super_cmd->state = ENTER_START_PLANE;
               }
             } /* if(me->projected) */
             else if(me->revolved)
               ME.super_cmd->state = SELECT_AXIS;
             else if(me->skinned)
               ME.super_cmd->state = SELECT_TRACE_CURVE;
           } /* the curve is physically closed */
           break;

           case EX_BACK_UP:
           if(me->const_state == DONE)
           {
             IGRint     display_count, involk_count;
             IGRushort  option; 

             option = NULL; 
             display_count = involk_count = 0;
             display_ids = NULL;
             option = EMS_UNDO_DELETE | EMS_DO_DISPLAY;

             info = &me->loc_events[LOCATE_SOLID].located_object[0];
             sts = om$send( msg = message EMSdpr.EMundo(&msg_loc,
                                          &option, &info->module_info, NULL, 
                                          NULL, NULL, &display_ids, 
                                          &display_count, &involk_count),
                            targetid = me->construct_id.objid,
                            targetos = me->construct_id.osnum);
             ERROR(sts, msg_loc, "execute.EMundo error")

             /*
              * Redraw the profile.
              */
            DisplayMode = GRbd;
            info = &me->loc_events[LOCATE_PROFILE].located_object[0];
            sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                 &info->module_info.md_env.matrix_type,
                                 info->module_info.md_env.matrix,
                                 &DisplayMode,
                                 &info->module_info.md_id),
                          targetid = info->located_obj.objid,
                          targetos = info->located_obj.osnum);
            ERROR(sts, msg_loc, "execute.GRgraphics.GRdisplay error")

            ME.super_cmd->state = SELECT_PROFILE;
          }
          else
            ME.super_cmd->state = BEGIN_STATE;

          break;

          case EX_FORM_FINISHED:
            break;

          default:
          /* 
           * Avoiding the undo of the model not produced during this state
           * execution.
           */
          if(me->const_state == DONE)
            me->const_state = DNUD;
          sts = OM_S_SUCCESS;
          goto  ret_end;
          /* return(OM_S_SUCCESS); */
        }  /* switch(acc_event.response) */
      } /* the object was located */
    } /* case SELECT_PROFILE */
    break;

    /* ------------------------------------------------------------------- *
     *                Select The Material Addition Side                    *
     * ------------------------------------------------------------------- */

    case SELECT_ADD_MAT_SIDE:
    {
      if(ME.super_cmd->mytype == PLACE_PROTRUSION)
        ex$message(msgnumb = EMS_P_SeleAddmatSide) 
      else
        ex$message(msgnumb = EMS_P_SeleRemmatSide)

      dynargs.tmp_bool = TRUE; /* arrow dynamics in the plane of profile */
      sts = om$send(msg = message ECridge.ECridge_perform_dynamics(&msg_loc,
                                  &dynargs ),
                    senderid = NULL_OBJID,
                    targetid = my_id,
                    targetos = OM_Gw_current_OS);
      ERROR(sts, msg_loc, "execute.ECridge.ECridge_perform_dynamics error")

      /*
       * Finally get this event.
       */
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
      sts = co$getevent( msg            = &msg_loc,
                         event_mask     = event_mask,
                         response       = response,
                         response_data  = response_data,
                         event          = &acc_event);
      ERROR(sts, msg_loc, "co$getevent error")

      OM_BLOCK_MOVE (me->loc_events[LOCATE_PROFILE].located_object[0].proj_pnt,
                     prof_pnt, sizeof (IGRpoint));

      switch(acc_event.response)
      {
        case EX_DATA:
          
          /*
           * we have accepted point in the acc_event. So take this point as the
           * cursor point and project this cursor point on an inf. line along
           * the material addtion direction.
           */
          cursor_pt[0] = acc_event.event.button.x;           
          cursor_pt[1] = acc_event.event.button.y;           
          cursor_pt[2] = acc_event.event.button.z;           

          OM_BLOCK_MOVE (cursor_pt, line[0], sizeof(IGRpoint) );
          for(i=0; i<3; i++)
            line[1][i] = line[0][i] + dynargs.vec_along_prfpln[i];

          (void) BSproj0( &rc, cursor_pt, line, proj_pnt );
          /* if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;} */

          sts = BSmkvec (&rc, vector, dynargs.the_point, proj_pnt); 
          if(rc != BSSUCC){sts = EMS_E_BSerror; goto ret_end;}
          BSnorvec(&rc, vector);

          me->matadd_vector[0] = vector[0];
          me->matadd_vector[1] = vector[1];
          me->matadd_vector[2] = vector[2];

          if(me->projected)
          {
            if(!me->normal)
            {
              if(me->finite)
                ME.super_cmd->state = ENTER_START_PLANE;
              else
                ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
            }
            else
            {
              if(me->thru_all)
                ME.super_cmd->state = SELECT_SOLID;
              else if(me->to_next || me->thru_next)
                ME.super_cmd->state = SELECT_PRJ_SIDE;
              else if(me->from_to)
                ME.super_cmd->state = SELECT_FROM_SURF_OR_REF_PLN; 
              else if(me->finite)
                ME.super_cmd->state = ENTER_START_PLANE;
            }
          }
          else if(me->revolved)
            ME.super_cmd->state = SELECT_AXIS;
          else if(me->skinned)
            ME.super_cmd->state = SELECT_TRACE_CURVE;
          break;

        case EX_FORM_FINISHED:
          break;

        case EX_BACK_UP:
          ME.super_cmd->state = SELECT_PROFILE; 
          break; 

        default:
          sts = OM_S_SUCCESS;
          goto  ret_end;
      } 
    }
    break;

    /* ------------------------------------------------------------------- *
     *             Enter Start Point of the Projection Vector              *
     * ------------------------------------------------------------------- */

    case ENTER_START_PLANE :
    {
      /*****
      ex$message(msgnumb = EMS_P_InputStptOrMvon)

      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_FORM_FINISHED;
      sts = co$getevent( msg            = &msg_loc,
                         event_mask     = event_mask,
                         response       = response,
                         response_data  = response_data,
                         event          = &acc_event);
      ERROR(sts, msg_loc, "co$getevent error")
      *****/

      acc_event.response = EX_RJT_MOVEON;
      
      switch(acc_event.response)
      {
        case EX_DATA:
        {
          cursor_pt[0] = acc_event.event.button.x;
          cursor_pt[1] = acc_event.event.button.y;
          cursor_pt[2] = acc_event.event.button.z;

          OM_BLOCK_MOVE (cursor_pt, me->pivot_pnt, sizeof(IGRpoint) ); 
          OM_BLOCK_MOVE (cursor_pt, dynargs.the_point, sizeof(IGRpoint) ); 
 
          if( !me->normal )
             ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
          else
          {
            if(me->symmetric)
              ME.super_cmd->state = ENTER_SYMMETRIC_DIST;
            else
              ME.super_cmd->state = ENTER_DISTANCE;
          }
        }
        break;

        case EX_RJT_MOVEON:
        {
          OM_BLOCK_MOVE( 
             me->loc_events[LOCATE_PROFILE].located_object[0].proj_pnt,
             &me->pivot_pnt[0], sizeof(IGRpoint));
          if( !me->normal )
            ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
          else
          {
            if(me->symmetric)
              ME.super_cmd->state = ENTER_SYMMETRIC_DIST;
            else
              ME.super_cmd->state = ENTER_DISTANCE;
          }
        }
        break;

        case EX_BACK_UP:
        {
          if(me->is_close)
            ME.super_cmd->state = SELECT_PROFILE;
          else
            ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
        }
        break;

        case EX_FORM_FINISHED:
        break;

        default : 
          sts = OM_S_SUCCESS;
          goto ret_end;
      }
    }
    break;

    /* ------------------------------------------------------------------- *
     *             Enter Second Point of the Projection Vector             *
     * ------------------------------------------------------------------- */

    case ENT_2nd_PT_OF_PRJ_VEC:
    {
      ex$message(msgnumb = EMS_P_Entsecndptprjvec)

      points[0][0]        = me->pivot_pnt[0];
      points[0][1]        = me->pivot_pnt[1];
      points[0][2]        = me->pivot_pnt[2];
      polyline.num_points = 2;
      polyline.points     = &points[0][0];

      /*
       * Build the display buffer.
       */
      dp$build_dis_buffer( buffer      = &dynargs.disbuf[0],
                           type        = IGRPY,
                           display_att = &ME.COconst->ActiveDisplay,
                           geometry    = &polyline);

      /*
       * If it is symmetric option is selected, then we should show the 
       * symmetric arrow otherwise one sided arrow.
       */
      if( me->finite && me->symmetric )
      {
        dynargs.tmp_bool          = TRUE;
        other_points[0][0]        = me->pivot_pnt[0];
        other_points[0][1]        = me->pivot_pnt[1];
        other_points[0][2]        = me->pivot_pnt[2];
        other_polyline.num_points = 2;
        other_polyline.points     = &other_points[0][0];
  
        dp$build_dis_buffer( buffer      = &dynargs.disbuf[1],
                             type        = IGRPY,
                             display_att = &ME.COconst->ActiveDisplay,
                             geometry    = &other_polyline);
      }
      else
      {
        dynargs.tmp_bool = FALSE;
      }

      /*
       * Invoke dynamics.
       */ 
      dp$dynamics(dyn_fun = EFpivotline, information = &dynargs);

      event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_FORM_FINISHED;
      sts = co$getevent( msg            = &msg_loc,
                         event_mask     = event_mask,
                         response       = response,
                         response_data  = response_data,
                         event          = &acc_event);
      ERROR(sts, msg_loc, "co$getevent error")

      switch(acc_event.response)
      {
        case EX_DATA:
        /*
         * Bug related to snap point :
         *  Earlier the second of the polyline was containing the cursor point
         *  which is different from the given snap point and this snap point is
         *  the button point, that's why copy the button point as the second pt
         *  of the polyline. -- Sanjay
         */
        cursor_pt[0] = acc_event.event.button.x;           
        cursor_pt[1] = acc_event.event.button.y;           
        cursor_pt[2] = acc_event.event.button.z;           

        sts = BSmkvec( &rc, vector, me->pivot_pnt, cursor_pt ); 
        if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
        BSnorvec(&rc, vector);

        me->projection_vec[0] = vector[0];
        me->projection_vec[1] = vector[1];
        me->projection_vec[2] = vector[2];

        loc_value = BSdistptpt(&rc, me->pivot_pnt, cursor_pt );
        if(rc != BSSUCC) { sts = EMS_E_BSerror; goto ret_end;}

        if( me->finite && me->symmetric )
          loc_value *= 2.0;

        /*
         * If the projection distance is less than the cht "Error Out"
         */
        if(loc_value < cht) 
        {
          ex$message(msgnumb = EMS_E_DepthGtrCht)
          break;
        }
        me->proj_dist = loc_value;
  
        if(me->thru_all)
          ME.super_cmd->state = SELECT_SOLID;
        else if(me->to_next || me->thru_next)
          ME.super_cmd->state = SELECT_SOLID; 
        else if(me->from_to)
          ME.super_cmd->state = SELECT_FROM_SURF_OR_REF_PLN;
        else if(me->finite) 
          ME.super_cmd->state = SELECT_SOLID;
        break;

        case EX_BACK_UP:
          /***
          if(me->finite)
            ME.super_cmd->state = ENTER_START_PLANE;
          else
          ***/
          if(me->is_close)
            ME.super_cmd->state = SELECT_PROFILE;
          else
            ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
          break; 

        case EX_FORM_FINISHED:
          break;

        default:
          sts = OM_S_SUCCESS;
          goto  ret_end;
      }
    }
    break;

    /* ------------------------------------------------------------------- *
     *                    Select The Projection Side                       *
     * ------------------------------------------------------------------- */
 
    case SELECT_PRJ_SIDE:
    {
      ex$message(msgnumb = EMS_P_SelePrjSideRej)

      dynargs.tmp_bool = FALSE; /* arrow dynamics perpandicular to the
                             plane of the profile */
      sts = om$send(msg = message ECridge.ECridge_perform_dynamics(&msg_loc,
                                  &dynargs ),
                    senderid = NULL_OBJID,
                    targetid = my_id,
                    targetos = OM_Gw_current_OS); 
      ERROR(sts, msg_loc, "execute.ECridge.ECridge_perform_dynamics error")

      /*
       * Finally get this event.
       */
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
      sts = co$getevent(msg            = &msg_loc,
                        event_mask     = event_mask,
                        response       = response,
                        response_data  = response_data,
                        event          = &acc_event);
      ERROR(sts, msg_loc, "co$getevent error")

      switch(acc_event.response)
      {
        case EX_DATA:

          /*
           * we have accepted point in the acc_event. So take this point as 
           * the cursor point and project this cursor point on an inf. line 
           * along the Projection direction.
           */
          cursor_pt[0] = acc_event.event.button.x;
          cursor_pt[1] = acc_event.event.button.y;
          cursor_pt[2] = acc_event.event.button.z;

          OM_BLOCK_MOVE( dynargs.the_point, line[0], sizeof(IGRpoint) );
          for(i=0; i<3; i++)
            line[1][i] = line[0][i] + dynargs.vec_nor_prfpln[i];

          (void) BSproj0( &rc, cursor_pt, line, proj_pnt );
          if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

          sts = BSmkvec( &rc, vector, dynargs.the_point, proj_pnt );
          if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
          BSnorvec(&rc, vector);

          me->projection_vec[0] = vector[0];
          me->projection_vec[1] = vector[1];
          me->projection_vec[2] = vector[2];

          if(me->to_next || me->thru_next || me->finite )
            ME.super_cmd->state = SELECT_SOLID;
          break;

        case EX_BACK_UP:
          if( me->finite && me->normal )
             ME.super_cmd->state = ENTER_DISTANCE;
          else
          {
             if(me->is_close)
                ME.super_cmd->state = SELECT_PROFILE; 
              else 
                ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
          }
          break; 

        case EX_FORM_FINISHED:
          break;

        default: 
          sts = OM_S_SUCCESS;
          goto  ret_end;
      } /* switch(acc_event.response) */
    }
    break;

    /* ------------------------------------------------------------------- *
     *                    Select The Revolution Side                       *
     * ------------------------------------------------------------------- */

    case SELECT_REV_SIDE:
    {
      IGRpoint   axis_stpt, axis_endpt, center, arc_stpt;

      /*
       * Control comes to this state only in case of revolved/from-to/to-next
       * option. 
       */

      /*
       * Justification for FromTo option 
       * -------------------------------
       * In this case the secondary solid to be generated comprises of a 
       * closed surface i.e. surface of revolution and the from to surf-
       * aces selected are along this closed surface, in  which case the 
       * question "which side to keep" arises and this state resolves the 
       * ambiguity.
       *
       * Clarification :
       * ---------------
       * The above said problem can be easily understood by the following
       * problem description. If a part of closed curve is to be extracted
       * just specifying the two end points is not enough but one more
       * point between the two end points is required. In our case the two
       * end points represents from and to surfaces and the middle point
       * will be obtained from this state.
       */

      /*  
       * display the prompt "Select Revoltuion side"
       */
      ex$message( msgnumb = EMS_P_SeleRevSideRej )

      /*
       * In case of from to option, an arc need to be drawn from surface,
       * where as incase of to-next option an arc need to be drawn from
       * the plane of the profile. So, fill up the arc start point accor-
       * dingly.
       */
      if( me->from_to && 
          (me->loc_events[LOCATE_FROM_SURFACE].response != EX_RJT_MOVEON) )
      {
        GRrange  from_surf_range;

        info = &me->loc_events[LOCATE_FROM_SURFACE].located_object[0];
        world = TRUE;

        sts = om$send( msg = message GRvg.GRgetrang( &msg_loc,
                                     &info->module_info.md_env.matrix_type,
                                     info->module_info.md_env.matrix, &world,
                                     from_surf_range ),
                       senderid = NULL_OBJID, 
                       targetid = me->from_surf_id.objid,
                       targetos = me->from_surf_id.osnum );
        ERROR( sts, msg_loc, "ECridge.GRcurve.GRendpts error" );

        OM_BLOCK_MOVE(from_surf_range, arc_stpt, sizeof(IGRpoint) );
      }
      else
      {
        OM_BLOCK_MOVE(me->pivot_pnt, arc_stpt, sizeof(IGRpoint) );
      }
    
      /*
       * get the axis end points 
       */
      info = &me->loc_events[LOCATE_AXIS].located_object[0];

      sts = om$send( msg = message GRcurve.GRendpts( &msg_loc, 
                                   &info->module_info.md_env.matrix_type, 
                                   info->module_info.md_env.matrix,
                                   axis_stpt, axis_endpt ),
                     senderid = NULL_OBJID,
                     targetid = info->located_obj.objid,
                     targetos = info->located_obj.osnum );

      ERROR( sts, msg_loc, "ECridge.GRcurve.GRendpts error" );

      /*
       * get the perpendicular distance from the pivot point to the axis, 
       * which is nothing but the radius of the arc which we will be going
       * draw.
       */
      sts = BSdistptli( &rc, &arc_stpt[0], axis_stpt, axis_endpt, 
                        &radius);
      if( rc != BSSUCC )
      {    
         sts = EMS_E_BSerror;
         goto ret_end;
      }

      OM_BLOCK_MOVE( axis_stpt, &dynargs.axis_ends[0][0], sizeof(IGRpoint) );
      OM_BLOCK_MOVE( axis_endpt, &dynargs.axis_ends[1][0], sizeof(IGRpoint) );

      /* 
       * project the pivot point on to the axis, which is nothing but the
       * center of the circle.
       */
      sts = BSproj0( &rc, arc_stpt, dynargs.axis_ends, center );
      if( rc != BSSUCC )
      {    
         sts = EMS_E_BSerror;
         goto ret_end;
      }

      /*
       * prepare circular arc
       */
      sts = BSprepcircp( &rc, center, arc_stpt, me->axis_vec, 
                        &dynargs.curvebuff[0], unit_vec, &type );
      if( rc != BSSUCC )
      {    
         sts = EMS_E_BSerror;
         goto ret_end;
      }

      ele_attr.is_polydis = FALSE;
      ele_attr.is_curvedis = TRUE;

      dynargs.display_stuff = &ME.COconst->ActiveDisplay;
      OM_BLOCK_MOVE( me->axis_vec, dynargs.tmp_vec, sizeof(IGRvector));

      OM_BLOCK_MOVE( center, dynargs.center, sizeof(IGRvector));
      OM_BLOCK_MOVE( &arc_stpt[0], &dynargs.curvebuff[1].poles[0],
                     sizeof(IGRpoint) );

      dp$build_dis_buffer( buffer = &dynargs.disbuf[0],
                           type = IGRBC,
                           display_att = dynargs.display_stuff,
                           ele_spec_att = &ele_attr,
                           geometry = &dynargs.curvebuff[1] );
   
      /*
       * perform the dynamics
       */ 
      dp$dynamics( dyn_fun = EFarcdyn, information = &dynargs );

      /*
       * get the event
       */
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
      sts = co$getevent( msg = &msg_loc,
                         event_mask = event_mask,
                         response = response,
                         response_data = response_data,
                         event = &acc_event );
      ERROR( sts, msg_loc, "ECridge: co$getevent error");

      switch( acc_event.response )
      {
        case EX_DATA :

          /*
           * get the accepted events point, find the minimum distance point
           * from this curve to the circle, and if the parameter at this
           * point happened to be more than 0.5, then we have to reverse the
           * direction of revolution i.e. nothing but reversing the axis of
           * revolution.
           */
          cursor_pt[0] = acc_event.event.button.x;
          cursor_pt[1] = acc_event.event.button.y;
          cursor_pt[2] = acc_event.event.button.z;

          BSmdstptcv( &dynargs.curvebuff[0], cursor_pt, &parval, junkpt, 
                      &loc_value, &rc );
          if( rc != BSSUCC ) 
          { 
            sts = EMS_E_BSerror;
            goto ret_end;
          }

          if( parval > 0.5 )
          {
            for(i=0; i<3; i++)
              me->axis_vec[i] *= -1.0;
          }
        
          if( me->finite )
            ME.super_cmd->state = ENT_SWEEP_ANGLE;
          else
            ME.super_cmd->state = SELECT_SOLID;

          break;

        case EX_BACK_UP : 
          if( me->from_to )
            ME.super_cmd->state = SELECT_TO_SURF_OR_REF_PLN;
          else
            ME.super_cmd->state = SELECT_AXIS;
          break;

        case EX_FORM_FINISHED:
          break;

        default :
          sts = OM_S_SUCCESS;
          goto ret_end;
      } /* end of the switch( acc_event.response ) */
    }
    break;

    /* ------------------------------------------------------------------ *
     *                  Select From Surface / Ref. plane                  *
     * ------------------------------------------------------------------ */

    case SELECT_FROM_SURF_OR_REF_PLN:
    {
      OMuword eleclass[2], prof_class, rejclass[2];

      ex$message(msgnumb = EMS_P_SelefrmSurRefplnMovn) 

      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      /*
      rclass = OPP_EMSsubbs_class_id;
      */
      rclass = OPP_EMSsurface_class_id;
      rtree_classes.p_classes = &rclass;
    
      elig_classes.w_count = 2;
      elig_classes.w_flags = OM_CLST_subclass;
      /*
      eleclass[0] = OPP_EMSsubbs_class_id;
      */
      eleclass[0] = OPP_EMSsurface_class_id;
      eleclass[1] = OPP_EMSdatpln_class_id;
      elig_classes.p_classes = &eleclass[0]; 

      rejclass[0] = OPP_EMSsolid_class_id;
      rejclass[1] = OPP_EMSsfrembnd_class_id;
      dont_locate.next = NULL;
      dont_locate.option = 2;
      dont_locate.type = 3;
      dont_locate.num_objects = 2;
      dont_locate.objects.classids = rejclass;
    
      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask  = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_FORM_FINISHED;
      accept_mask  = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_FORM_FINISHED;
      ex$message(msgnumb = EMS_P_SelefrmSurRefplnMovn, buff = locate_prompt)
      ex$message(msgnumb = EMS_P_00038, buff = accept_prompt)
      ex$message(msgnumb = EMS_I_SurPrfplnNotfound, buff = relocate_prompt)
     
      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
    
      /*
       * Commented  ---> Sanjay 18th May' 94.
         attributes.owner_action =  LC_RIGID_COMP | LC_FLEX_COMP |
                           LC_NO_REF_HEADER | LC_REF_OBJECTS |
                           LC_HANDLES | LC_LOCALMOD;
       */

      /* 
       * Modified to Identify the composite surfaces also as from and to 
       * surfaces 
       */
      attributes.owner_action =  LC_RIGID_OWNER | LC_RIGID_COMP | 
                                 LC_FLEX_COMP | LC_NO_REF_HEADER | 
                                 LC_REF_OBJECTS | LC_HANDLES | LC_LOCALMOD;

      stat_func = lc$locate( rc                = &object_was_located,
                             event1            = &me->locate_event,
                             event2            = &acc_event,
                             event3            = &loc_event,
                             mask1             = locate_mask,
                             mask2             = accept_mask,
                             eventsize         = &event_size,
                             display_flag      = display_flag,
                             response          = response,
                             response_data     = response_data,
                             locate_prompt     = locate_prompt,
                             acc_prompt        = accept_prompt,
                             relocate_prompt   = relocate_prompt,
                             act_handler       = EFlocate_action_handler,
                             act_args          = &dont_locate,
                             attributes        = &attributes,
                             stack             = &me->locate_stack,
                             rtree_classes     = &rtree_classes,
                             eligible_classes  = &elig_classes);
 
      ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_S_ClearStatusField)

      if(stat_func == FALSE)
      {
        ex$message(msgnumb = EMS_E_FailInputProcExit)
        *response = TERMINATE;
        goto ret_end;
      }

      if(!object_was_located)
      {
        switch(loc_event.response)
        {
          case EX_BACK_UP:
          {
            if( me->projected )
            {
              if(!me->is_close)
              {
                if(me->normal)
                  ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
                  else
                  ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
              }
              else /* the profile is close */
              {
                if(me->normal)
                  ME.super_cmd->state = SELECT_PROFILE;
                else
                  ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC; 
              }
            }
            else if( me->revolved )
              ME.super_cmd->state = SELECT_AXIS; 
            else if( me->skinned )
              ME.super_cmd->state = SELECT_TRACE_CURVE; 
          }
          break;

          case EX_RJT_MOVEON:
          {
            /*
             * Get the reference plane to which the profile is associated.
             * There is no reference plane associated with the composite 
             * curves, in which case make the reference plane id as NULL
             * OBJID.
             */
            info = &me->loc_events[LOCATE_PROFILE].located_object[0];
            prof_id.objid = info->located_obj.objid;
            prof_id.osnum = info->located_obj.osnum;

            sts = om$get_classid( objid = prof_id.objid,
                                  osnum = prof_id.osnum,
                                  p_classid = &prof_class );

            if( om$is_ancestry_valid( subclassid = prof_class,
                      superclassid = OPP_SKgeometry_class_id) == OM_S_SUCCESS )
            { // if the chosen profile is a profile class
              sts = EMget_profile_refpln_id( &msg_loc, &prof_id, &refplnid, 
                                             &success);
              if(!(1&sts)) goto ret_end;
            }
            else // chosen profile is a composite curve
            {
              success = TRUE; 
              refplnid.objid = NULL_OBJID;
              refplnid.osnum = 0;
            }

            if(success)
            {
              me->from_surf_id.objid = refplnid.objid;
              me->from_surf_id.osnum = refplnid.osnum; 
              OM_BLOCK_MOVE(&loc_event, &me->loc_events[LOCATE_FROM_SURFACE],
                            event_size);

              /*
               * Filling up the useful information in this structure.
               */
              me->loc_events[LOCATE_FROM_SURFACE].located_object[0].
                  located_obj.objid = refplnid.objid;
              me->loc_events[LOCATE_FROM_SURFACE].located_object[0].
                  located_obj.osnum = refplnid.osnum;

              OM_BLOCK_MOVE(
               &me->loc_events[LOCATE_PROFILE].located_object[0].module_info,
               &me->loc_events[LOCATE_FROM_SURFACE].located_object[0].
               module_info, sizeof(struct GRmd_env));

              OM_BLOCK_MOVE(me->pivot_pnt, 
               me->loc_events[LOCATE_FROM_SURFACE].located_object[0].proj_pnt,
               3 * sizeof(IGRdouble));

              ME.super_cmd->state = SELECT_TO_SURF_OR_REF_PLN;
            }
            else
            {
              ex$message(msgnumb = EMS_I_SurPrfplnNotfound)
              sts = OM_S_SUCCESS;
              goto  ret_end;
              /* return(OM_S_SUCCESS); */
            }
          }
          break;

          default:
            sts = OM_S_SUCCESS;
            goto  ret_end;

        } /* switch(loc_event.response) */

      }

      else /* It means the object was located */

      {
        sts = dp$erase_hilite(msg = &msg_loc);
        ERROR(sts, msg_loc, "execute.rease_hilite error")

        OM_BLOCK_MOVE( &loc_event, 
                       &me->loc_events[LOCATE_FROM_SURFACE], event_size);
        me->numobjs ++;

        switch(acc_event.response)
        {
          case EX_DATA:
            refplnid.objid = me->loc_events[LOCATE_FROM_SURFACE].
                               located_object[0].located_obj.objid;
            refplnid.osnum = me->loc_events[LOCATE_FROM_SURFACE].
                             located_object[0].located_obj.osnum;
            me->from_surf_id.objid = refplnid.objid;
            me->from_surf_id.osnum = refplnid.osnum;

            ME.super_cmd->state = SELECT_TO_SURF_OR_REF_PLN;
            break;

         case EX_BACK_UP:
           if( me->projected )
           {
             if(!me->is_close)
             {
               if(me->normal)
                 ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
               else
                 ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
             }
             else /* the profile is close */
             {
               if(me->normal)
                 ME.super_cmd->state = SELECT_PROFILE;
               else
                 ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
             }
           }
           else if( me->revolved )
             ME.super_cmd->state = SELECT_AXIS; 
           else if( me->skinned )
             ME.super_cmd->state = SELECT_TRACE_CURVE; 
           break;

        case EX_FORM_FINISHED:
          break;

        default:
          sts = OM_S_SUCCESS;
          goto  ret_end;
          /* return(OM_S_SUCCESS); */
        } /* switch(acc_event.response) */
      } /* the object was located */
    }
    break;
 
    /* ------------------------------------------------------------------ *
     *                  Select To Surface / Ref. plane                    *
     * ------------------------------------------------------------------ */

    case SELECT_TO_SURF_OR_REF_PLN:
    {
      OMuword eleclass[2], classid, rejclass[2];
      struct EMSaction_handler dont_locate_from_surf;
      
      if( me->revolved && 
          me->loc_events[LOCATE_FROM_SURFACE].response == EX_RJT_MOVEON )
        ex$message(msgnumb = EMS_P_SeleToSurfRefplnMvon)
      else
        ex$message(msgnumb = EMS_P_SeleToSurfRefpln)

      rtree_classes.w_count = 1;
      rtree_classes.w_flags = OM_CLST_subclass;
      /*
      rclass = OPP_EMSsubbs_class_id;
      */
      rclass = OPP_EMSsurface_class_id;
      rtree_classes.p_classes = &rclass;

      elig_classes.w_count = 2;
      elig_classes.w_flags = OM_CLST_subclass;
      /*
       eleclass[0] = OPP_EMSsubbs_class_id;
      */
      eleclass[0] = OPP_EMSsurface_class_id;
      eleclass[1] = OPP_EMSdatpln_class_id;
      elig_classes.p_classes = &eleclass[0]; 

      rejclass[0] = OPP_EMSsolid_class_id;
      rejclass[1] = OPP_EMSsfrembnd_class_id;
      dont_locate.next = NULL;
      dont_locate.option = 2;
      dont_locate.type = 3;
      dont_locate.num_objects = 2;
      dont_locate.objects.classids = rejclass; 

      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask  = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON |GRm_FORM_FINISHED;
      accept_mask  = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON |GRm_FORM_FINISHED;

      ex$message(msgnumb = EMS_P_SeleToSurfRefpln, buff = locate_prompt)
      ex$message(msgnumb = EMS_P_00038, buff = accept_prompt)
      ex$message(msgnumb = EMS_I_SurPrfplnNotfound, buff = relocate_prompt)

      attributes.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;

      /*
       * Commented  ---> Sanjay May 18th 94.
          attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                           LC_NO_REF_HEADER | LC_REF_OBJECTS |
                           LC_HANDLES | LC_LOCALMOD;
       */

      /*
       * Modified to Identify the composite surfaces also as from and to 
       * surfaces 
       */  
      attributes.owner_action = LC_RIGID_OWNER | LC_RIGID_COMP | 
                                LC_FLEX_COMP | LC_NO_REF_HEADER | 
                                LC_REF_OBJECTS | LC_HANDLES | LC_LOCALMOD;

      /*
       * 'FROM AND TO SURFACES CAN BE SAME' but this is invalid if From 
       * surface selected is a REFERENCE PLANE OR PLANAR SURFACE as it 
       * results in ZERO length feature. So, if the from surface is a 
       * planar surface/reference plane we should have an action handler
       * NOT to select the same as TO surface. If the profile is a COMPOSITE
       * CURVE and the from surface is same as profile plane then from surface
       * is pointing to NULL_OBJID, so check for the same and use the action
       * handler.
       */
      if( me->from_surf_id.objid != NULL_OBJID )
      {
        sts = om$get_classid( objid = me->from_surf_id.objid,
                              osnum = me->from_surf_id.osnum,
                              p_classid = &classid );
        ERROR(sts, sts, "om$get_classid error")
  
        if( (om$is_ancestry_valid( subclassid = classid, 
                   superclassid = OPP_EMSdatpln_class_id) == OM_S_SUCCESS) ||
            (om$is_ancestry_valid( subclassid = classid,
                   superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS) )
        {
           dont_locate_from_surf.next         = NULL;
           dont_locate_from_surf.type         = 1;
           dont_locate_from_surf.option       = 0;
           dont_locate_from_surf.num_objects  = 1;
           dont_locate_from_surf.objects.id   = &me->from_surf_id;
           dont_locate.next = &dont_locate_from_surf;
        }
      }
       
      stat_func = lc$locate(rc = &object_was_located,
                            event1 = &me->locate_event,
                            event2 = &acc_event,
                            event3 = &loc_event,
                            mask1 = locate_mask,
                            mask2 = accept_mask,
                            eventsize = &event_size,
                            display_flag = display_flag,
                            response = response,
                            response_data = response_data,
                            locate_prompt = locate_prompt,
                            acc_prompt = accept_prompt,
                            relocate_prompt = relocate_prompt,
                            act_handler = EFlocate_action_handler,
                            act_args = &dont_locate, 
                            attributes = &attributes,
                            stack = &me->locate_stack,
                            rtree_classes = &rtree_classes,
                            eligible_classes = &elig_classes);
      
      ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_S_ClearStatusField)
      if(stat_func == FALSE)
      {
        ex$message(msgnumb = EMS_E_FailInputProcExit)
        *response = TERMINATE;
        goto ret_end;
      }

      if(!object_was_located)
      {
        switch(loc_event.response)
        {
          case EX_BACK_UP:
            ME.super_cmd->state = SELECT_FROM_SURF_OR_REF_PLN;
          break;

          case EX_RJT_MOVEON:
            if(me->revolved && 
               me->loc_events[LOCATE_FROM_SURFACE].response == EX_RJT_MOVEON)
            {
              OM_BLOCK_MOVE( &me->loc_events[LOCATE_FROM_SURFACE],
                             &me->loc_events[LOCATE_TO_SURFACE],
                             event_size );
              ME.super_cmd->state = SELECT_REV_SIDE;
            }
            else
            {
              ME.super_cmd->state = SELECT_TO_SURF_OR_REF_PLN;
            }
          break;

          default:
            sts = OM_S_SUCCESS;
            goto  ret_end;

        } /* switch(loc_event.response) */

      }

      else /* It means the object was located */

      {
        sts = dp$erase_hilite(msg = &msg_loc);
        ERROR(sts, msg_loc, "execute.rease_hilite error")
        OM_BLOCK_MOVE(&loc_event, &me->loc_events[LOCATE_TO_SURFACE], 
                      event_size);
        me->numobjs ++;

        switch(acc_event.response)
        {
          case EX_DATA:
            refplnid = me->loc_events[LOCATE_TO_SURFACE].located_object[0].
                       located_obj;
            me->to_surf_id = refplnid;

            /** The command state is now forced to move to the determination***
            *** of the revolution side for revolved from - to guys          ***
            *** TR # 119601956 - Sp.Balamrugan                              **/
            if(me->revolved)
            ME.super_cmd->state = SELECT_REV_SIDE;
            else
            ME.super_cmd->state = SELECT_SOLID;

            break;

          case EX_BACK_UP:
              ME.super_cmd->state = SELECT_FROM_SURF_OR_REF_PLN;
            break;

          case EX_FORM_FINISHED:
            break;

          default:
            sts = OM_S_SUCCESS;
            goto  ret_end; 
            /* return(OM_S_SUCCESS); */
        } /* switch(acc_event.response) */
      } /* the object was located */
    }
    break;

    /* ------------------------------------------------------------------ *
     *                Select From To Revolution side                      *
     * ------------------------------------------------------------------ */
  
/* 
    case SELECT_FROMTO_REVOLUTION_SIDE :
    {
*/
      /*
       * Justification : 
       * ---------------
       * This state comes into picture only in case of revolved/from-to 
       * option. In which case the secondary solid to be generated com-
       * prises of a closed surface i.e. surface of revolution and the 
       * from to surfaces selected are along this closed surface, in 
       * which case the question "which side to keep" arises and this
       * state resolves the ambiguity. 
       *
       * Clarification :
       * ---------------
       * The above said problem can be easily understood by the following
       * problem description. If a part of closed curve is to be extracted
       * just specifying the two end points is not necessary but one more
       * point between the two end points is required. In our case the two
       * end points represents from and to surfaces and the middle point
       * will be obtained from this state.
       */
      
      /* 
       * special cases, think in the following what needs to be done. 
        
        if(me->from_surf_id.objid == NULL_OBJID &&
           me->to_surf_id.objid == NULL_OBJID )
        else if(me->from_surf_id.objid == NULL_OBJID)
        else if(me->to_surf_id.objid == NULL_OBJID)
       *
       */
   
      /* display the prompt */ 
/*
      ex$message (msgnumb = EMS_P_SelectFromToRevSide)

    }
    break;
*/
    

    /* ------------------------------------------------------------------ *
     *                  Enter Symmetric Distance                          * 
     * ------------------------------------------------------------------ */

    case ENTER_SYMMETRIC_DIST:
    {
      ex$message(msgnumb = EMS_P_EntSymmetDist)

      /*
       *The input can either be through the dynamic display or  a keyin value
       */
      points[0][0]         = me->pivot_pnt[0];
      points[0][1]         = me->pivot_pnt[1];
      points[0][2]         = me->pivot_pnt[2];
      polyline.num_points  = 2;
      polyline.points      = &points[0][0];

      /*
       * Bulid the display buffer.
       */
      dp$build_dis_buffer( buffer       = &dynargs.disbuf[0],
                           type         = IGRPY,
                           display_att  = &ME.COconst->ActiveDisplay,
                           geometry     = &polyline);

      other_points[0][0]         = me->pivot_pnt[0];
      other_points[0][1]         = me->pivot_pnt[1];
      other_points[0][2]         = me->pivot_pnt[2];
      other_polyline.num_points  = 2;
      other_polyline.points      = &other_points[0][0];
 
      dp$build_dis_buffer( buffer       = &dynargs.disbuf[1],
                           type         = IGRPY,
                           display_att  = &ME.COconst->ActiveDisplay,
                           geometry     = &other_polyline);

      OM_BLOCK_MOVE( me->vec_nor_prfpln, dynargs.vec_nor_prfpln, 
                     sizeof(IGRvector) );

      /*
       * Invoke dynamics
       */
      dp$dynamics(dyn_fun = EFsymmlinedyn, information = &dynargs);       

      event_mask = GRm_VALUE | GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | 
                   GRm_FORM_FINISHED;

      sts = ems$getevent( msg            = &msg_loc,
                          event_mask     = event_mask,
                          value_type     = GRIO_DISTANCE,
                          response       = (long *) response,
                          response_data  = response_data,
                          event          = &acc_event);
      if (!(1&sts) || msg_loc == MSFAIL)
      {
        if (OM_Gf_verbose_warning) 
          fprintf(stderr, "\nIn ECridge: ems$getevent error\n");
        sts = FAIL; 
        goto ret_end;
      }

      if (msg_loc == GRw_no_value)
      {
        ex$message (msgnumb = EMS_I_00006);
        break;
      }

      switch(acc_event.response)
      {
        case EX_DATA:
          /* 
           * find the symmetric distance incase the input is being entered
           * via dynamic display.
           */ 
          cursor_pt[0] = acc_event.event.button.x;
          cursor_pt[1] = acc_event.event.button.y;
          cursor_pt[2] = acc_event.event.button.z;

          OM_BLOCK_MOVE( me->pivot_pnt, line[0], sizeof(IGRpoint) );
          for(i=0; i<3; i++)
             line[1][i] = line[0][i] + me->vec_nor_prfpln[i];

          (void) BSproj0( &rc, cursor_pt, line, proj_pnt );
          if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

          loc_value = BSdistptpt( &rc, me->pivot_pnt, proj_pnt );
          if(rc != BSSUCC) { sts = EMS_E_BSerror; goto ret_end;}

          loc_value *= 2.0;

          if(loc_value < cht)
          {
            ex$message(msgnumb = EMS_E_DepthGtrCht)
            break;
          }
          me->proj_dist = loc_value;

          ME.super_cmd->state = SELECT_SOLID;
          break;

        case EX_VALUE:
          loc_value = acc_event.event.value;
          if(loc_value < cht)
          {
            ex$message(msgnumb = EMS_E_DepthGtrCht)
            break;
          }
          me->proj_dist = loc_value;
          ME.super_cmd->state = SELECT_SOLID;
          break;

       case EX_BACK_UP:
         /*** 
         ME.super_cmd->state = ENTER_START_PLANE; 
         else
         ***/
         if (me->is_close)
           ME.super_cmd->state = SELECT_PROFILE;
         else
           ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
         break;

       case EX_FORM_FINISHED:
         break;

       default:
         sts = OM_S_SUCCESS;
         goto  ret_end;

      }/* switch(acc_event.response) */
    }
    break;

    /* ------------------------------------------------------------------ *
     *                  Enter Projection Distance                         * 
     * ------------------------------------------------------------------ */

    case ENTER_DISTANCE:
    {
      IGRdouble loc_value;

      /*
       * In the the value is expected to be entered either through the
       * mouse or through the key in.
       */
      ex$message(msgnumb = EMS_P_EntrDist)

      points[0][0]         = me->pivot_pnt[0];
      points[0][1]         = me->pivot_pnt[1];
      points[0][2]         = me->pivot_pnt[2];
      polyline.num_points  = 2;
      polyline.points      = &points[0][0];

      /*
       * Build the display buffer.
       */
      dp$build_dis_buffer( buffer       = &dynargs.disbuf[0],
                           type         = IGRPY,
                           display_att  = &ME.COconst->ActiveDisplay,
                           geometry     = &polyline);

      OM_BLOCK_MOVE( me->vec_nor_prfpln, dynargs.vec_nor_prfpln, 
                     sizeof(IGRvector) );

      /*
       * Invoke dynamics.
       */ 
      dp$dynamics(dyn_fun = EFlinedyn, information = &dynargs);

      event_mask = GRm_VALUE | GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | 
                   GRm_FORM_FINISHED;

      sts = ems$getevent( msg            = &msg_loc,
                          event_mask     = event_mask,
                          value_type     = GRIO_DISTANCE,
                          response       = (long *) response,
                          response_data  = response_data,
                          event          = &acc_event);
      if (!(1&sts) || msg_loc == MSFAIL)
      {
        if (OM_Gf_verbose_warning)
          fprintf(stderr, "\nIn ECridge: ems$getevent error\n");
        sts = FAIL;
        goto ret_end;
      }

      if (msg_loc == GRw_no_value)
      {
        ex$message (msgnumb = EMS_I_00006);
        break;
      }

      switch(acc_event.response)
      {
        case EX_DATA:
          /*
           * calculate the projection distance 
           */
          cursor_pt[0] = acc_event.event.button.x;
          cursor_pt[1] = acc_event.event.button.y;
          cursor_pt[2] = acc_event.event.button.z;

          OM_BLOCK_MOVE( me->pivot_pnt, line[0], sizeof(IGRpoint) );
          for(i=0; i<3; i++)
             line[1][i] = line[0][i] + me->vec_nor_prfpln[i];

          (void) BSproj0( &rc, cursor_pt, line, proj_pnt );
          if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

          loc_value = BSdistptpt(&rc, me->pivot_pnt, proj_pnt );
          if(rc != BSSUCC) { sts = EMS_E_BSerror; goto ret_end;}

          if(loc_value < cht)
          {
            ex$message(msgnumb = EMS_E_EntdValuGtrCht)
            break;
          }
          me->proj_dist = loc_value; 

          /*
           * if normal to the profile option is selected, check whether the 
           * given data point is in the direction of the normal or opposite 
           * to it, if it is opposite change the projection direction
           */  
          if( me->normal && me->projected )
          {
            for(i=0; i<3; i++) 
              tmp_vec[i] = cursor_pt[i] -  me->pivot_pnt[i] ;
            BSnorvec(&rc, tmp_vec);

            if( (BSdotp(&rc, tmp_vec, me->projection_vec)) < 0.0 )
            {
              for( i=0; i<3; i++ )
                me->projection_vec[i] *= -1.0;
            }
          }    
          ME.super_cmd->state = SELECT_SOLID;
          break;

        case EX_VALUE:
          loc_value = acc_event.event.value;
          if(loc_value < cht)
          {
            ex$message(msgnumb = EMS_E_EntdValuGtrCht)
          break;
          }
          me->proj_dist = loc_value;

          /*
           * one question always araises here, as to why one should
           * select the projection side as the distance already been
           * given. This is because as the user keyed-in the distance
           * (may be by keeping the cursor outside the EMS window),
           * we don't know along which direction he wants to move. 
           * That's why this state exists only in case of only if the
           * user keys-in the distance. 
           */
          ME.super_cmd->state = SELECT_PRJ_SIDE;

          break;

        case EX_BACK_UP:
          /***
          ME.super_cmd->state = ENTER_START_PLANE;
          else
          ***/
          if (me->is_close)
            ME.super_cmd->state = SELECT_PROFILE;
          else
            ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
          break;

        case EX_FORM_FINISHED:
          break;

        default:
          sts = OM_S_SUCCESS;
          goto  ret_end;
          /* return(OM_S_SUCCESS); */
      }/* switch(acc_event.response) */
    }
    break;

    /* ------------------------------------------------------------------- *
     *                        Select Axis Of Revolution                    *
     * ------------------------------------------------------------------- */

    case SELECT_AXIS:
    {
/****
      loop_locatable = EFloop_curves_locatable();
      edge_locatable = EFedge_curves_locatable();
      bdry_locatable = EFboundary_curves_locatable();

      if(loop_locatable) 
        EFset_locate_eligibility(&msg_loc, 0, "EMSloop");
      if(edge_locatable)
        EFset_locate_eligibility(&msg_loc, 0, "EMSedge");
      if(bdry_locatable)
        EFset_locate_eligibility(&msg_loc, 1, "EMSboundary");
****/

      loop_locatable = EFloop_curves_locatable();
      if(loop_locatable) 
        EFset_locate_eligibility(&msg_loc, 0, "EMSloop");

      reject_classid = OPP_GR3dpoint_class_id;
      dont_locate.next = NULL;
      dont_locate.option = 2;
      dont_locate.type = 3;
      dont_locate.num_objects = 1;
      dont_locate.objects.classids = &reject_classid;
     
      display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
      accept_mask = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
     
      ex$message(msgnumb = EMS_P_SelectAxis, buff = locate_prompt)
      ex$message(msgnumb = EMS_P_00038, buff = accept_prompt)
      ex$message(msgnumb = EMS_P_LineAxisNotFound, buff = relocate_prompt)
     
      attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_PLANAR_ONLY |
                                LC_RW;
      aflag = pwIsActivationOn();
      if (aflag)
      {
      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                                LC_NO_REF_HEADER | LC_REF_OBJECTS;
      /** Removed NO_REF_  for RFA  **/
      }
      else
      {
      attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                                LC_NO_REF_HEADER | LC_NO_REF_OBJECTS;
      }

      strcpy(attributes.classes, "GRcurve");

      rtree_classes.w_count    = 1;
      elig_classes.w_count     = 1;
      rtree_classes.w_flags    = OM_CLST_subclass;
      elig_classes.w_flags     = OM_CLST_subclass;
      rclass                   = OPP_GRcurve_class_id;
      eliclass                 = OPP_GRcurve_class_id;
      rtree_classes.p_classes  = &rclass;
      elig_classes.p_classes   = &eliclass;
     
      stat_func = lc$locate(   rc = &object_was_located,
                               event1 = &me->locate_event,
                               event2 = &acc_event,
                               event3 = &loc_event,
                               mask1 = locate_mask,
                               mask2 = accept_mask,
                               eventsize = &event_size, 
                               display_flag = display_flag,
                               response = response,
                               response_data = response_data,
                               locate_prompt = locate_prompt,
                               acc_prompt = accept_prompt,
                               relocate_prompt = relocate_prompt,
                               act_handler = EFlocate_action_handler,
                               act_args = &dont_locate,
                               attributes = &attributes,
                               stack = &me->locate_stack,
                               rtree_classes = &rtree_classes,
                               eligible_classes = &elig_classes);

      ex$message(msgnumb = EMS_P_ClearPromptField)
      ex$message(msgnumb = EMS_S_ClearStatusField)

      if(stat_func == FALSE)
      {
        ex$message(msgnumb = EMS_E_FailInputProcExit)
        *response = TERMINATE;
        goto ret_end;
      }

      if(!object_was_located)
      {
        switch(loc_event.response)
        {
          case EX_BACK_UP:
            if( me->is_close )
              ME.super_cmd->state = SELECT_PROFILE;
            else
              ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
            break;

          default:
            sts = OM_S_SUCCESS;
            goto  ret_end;
        }
      }
      else
      { 
        sts = dp$erase_hilite(msg = &msg_loc);
        ERROR(sts, msg_loc, "execute.erase_hilite error")
        OM_BLOCK_MOVE(&loc_event, &me->loc_events[LOCATE_AXIS], event_size); 
        me->numobjs ++;
       
        switch(acc_event.response)
        {
          case EX_DATA:
            /*
             * Check if the selected element is a linear element or not.
             */
           info = &me->loc_events[LOCATE_AXIS].located_object[0];
           tmp_id.objid = info->located_obj.objid;
           tmp_id.osnum = info->located_obj.osnum;

         /**** Check to avoid parametric elements -Sp.B for TR # 119603620**/
 
         if (!(EFisAncestryValid(&msg_loc, tmp_id.objid, tmp_id.osnum,
                                  OPP_GRlinear_class_id,FALSE)))
         {
          ex$message(msgnumb = EMS_S_NonLnCmpNotAl)
             break;
         }
 

           sts = om$send( msg = message GRvg.GRgetsize(&msg_loc,
                                &info->module_info.md_env.matrix_type,
                                info->module_info.md_env.matrix,
                                &num_bytes),
                          targetid = tmp_id.objid,
                          targetos = tmp_id.osnum);
           ERROR(sts, msg_loc, "execute.GRvg.GRgetsize error")

           geom_axis = (struct IGRbsp_curve *) alloca (num_bytes);
           if( !geom_axis )
           {
             sts = OM_E_ABORT;
             goto  ret_end; 
           }

           sts = om$send( msg = message GRvg.GRgetgeom(&msg_loc,
                                &info->module_info.md_env.matrix_type,
                                info->module_info.md_env.matrix,
                                (IGRchar *)geom_axis),
                          targetid = tmp_id.objid,
                          targetos = tmp_id.osnum);
           ERROR(sts, msg_loc, "execute.GRvg.GRgetgeom error")

           if(geom_axis->order > 2)
           {
             ex$message(msgnumb = EMS_S_NonLnCmpNotAl)
             break;
           }
           else
           {
             sts = BSmkvec( &rc, me->axis_vec, &geom_axis->poles[0],
                            &geom_axis->poles[3]);
             BSnorvec( &rc, me->axis_vec );

             if( me->thru_all )
               ME.super_cmd->state = SELECT_SOLID;
             else if( me->to_next || me->thru_next )
               ME.super_cmd->state = SELECT_REV_SIDE;
             else if( me->from_to )
               ME.super_cmd->state = SELECT_FROM_SURF_OR_REF_PLN; 
             else if( me->finite )
             {
               if( me->symmetric )
                 ME.super_cmd->state = ENT_SYMM_SWEEP_ANG;
               else
                 ME.super_cmd->state = SELECT_REV_SIDE;
             }
           }
           break;

         case EX_BACK_UP:
           if( me->is_close )
             ME.super_cmd->state = SELECT_PROFILE;
           else
             ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
           break;

         default:
           sts = OM_S_SUCCESS; 
           goto  ret_end; 
         /* return(OM_S_SUCCESS); */
        } /* switch */
      }/* object was located */
      if(loop_locatable)
        EFset_locate_eligibility(&msg_loc, 0, "EMSloop");
    }/* case SELECT_AXIS */
    break;

    /* --------------------------------------------------------------------- *
     *                       Enter Start Angle                               *
     * --------------------------------------------------------------------- */

    case ENTER_START_ANGLE :
    {
      ex$message( msgnumb = EMS_P_00056 );

      /*
       * Get the event. 
       */
      event_mask = GRm_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_FORM_FINISHED;
      sts = co$getevent(msg = &msg_loc,
                        event_mask = event_mask,
                        response = response,
                        response_data = response_data,
                        event = &acc_event);

      if( msg_loc == GRw_no_value )
      {
         /* 
          * As the user keyed in ENTER, take the default value.
          */
         me->loc_events[LOCATE_PROFILE].values[0] = 0.0;
         ME.super_cmd->state = SELECT_SOLID;
         msg_loc = EMS_S_Success;
      }
      else
      {
         switch( acc_event.response )
         {
           case EX_VALUE :
             /*
              * store the starting angle in the locate event structure of the 
              * profile.
              */ 
             me->loc_events[LOCATE_PROFILE].values[0] = acc_event.event.value;
             ME.super_cmd->state = SELECT_SOLID;
           break;
   
           case EX_RJT_MOVEON : 
             /*
              * store the starting angle in the locate event structure of the
              * profile.
              */
             me->loc_events[LOCATE_PROFILE].values[0] = 0.0;
             ME.super_cmd->state = SELECT_SOLID;
           break;
     
           case EX_BACK_UP : 
           {
             if( me->symmetric )
               ME.super_cmd->state = ENT_SYMM_SWEEP_ANG;
             else
               ME.super_cmd->state = ENT_SWEEP_ANGLE;
           }
           break;
 
           case EX_FORM_FINISHED :
             break;
          
           default :
             sts = OM_S_SUCCESS;
             goto ret_end;
         }
      } 
    }
    break;


    /* --------------------------------------------------------------------- *
     *                   Enter Symmetric Sweep Angle                         *
     * --------------------------------------------------------------------- */

    case ENT_SYMM_SWEEP_ANG:
    {
      /*
       * Here the dynamic display is going to be a bit tricky. Take the pivot
       * point, find its distance from the axis selected in the previous step
       * which is the radius of the circular arc going to be drawn for the 
       * dynamic display.
       */
      ex$message(msgnumb = EMS_P_EntSymmSweepAng)
 
      info = &me->loc_events[LOCATE_AXIS].located_object[0];
      sts = om$send(msg = message GRcurve.GRendpts(&msg_loc,
                            &info->module_info.md_env.matrix_type,
                            info->module_info.md_env.matrix,
                            start_pnt, stop_pnt),
                       senderid = NULL_OBJID,
                       targetid = info->located_obj.objid,
                       targetos = info->located_obj.osnum);
      if(!(1&sts)) goto ret_end; 
 
      sts = BSdistptli(&rc, &me->pivot_pnt[0], start_pnt, stop_pnt, &radius);
      if(rc != BSSUCC) {sts = EMS_E_BSerror; goto ret_end;}
    
      OM_BLOCK_MOVE(start_pnt, &dynargs.axis_ends[0][0], sizeof(IGRpoint));
      OM_BLOCK_MOVE(stop_pnt, &dynargs.axis_ends[1][0], sizeof(IGRpoint));
    
      sts = BSproj0(&rc, &me->pivot_pnt[0], dynargs.axis_ends, proj_pnt);
      if(rc != BSSUCC) {sts = EMS_E_BSerror; goto ret_end;}
 
      sts = BSprepcircp( &rc, proj_pnt, me->pivot_pnt, me->axis_vec, 
                         &dynargs.curvebuff[0], unit_vec, &type);
      if(rc != BSSUCC) {sts = EMS_E_BSerror; goto ret_end;}
      
      dynargs.display_stuff = &ME.COconst->ActiveDisplay;
    
      OM_BLOCK_MOVE(proj_pnt, dynargs.center, sizeof(IGRpoint));
      OM_BLOCK_MOVE(me->axis_vec, dynargs.tmp_vec, sizeof(IGRvector));
      OM_BLOCK_MOVE(me->pivot_pnt, dynargs.the_point, sizeof(IGRvector));
    
      ele_attr.is_polydis = FALSE;
      ele_attr.is_curvedis = TRUE;
      OM_BLOCK_MOVE(&me->pivot_pnt[0], &dynargs.curvebuff[1].poles[0],
                   sizeof(IGRpoint));
      OM_BLOCK_MOVE(&me->pivot_pnt[0], &dynargs.curvebuff[2].poles[0],
                   sizeof(IGRpoint));
    
      dp$build_dis_buffer(buffer = &dynargs.disbuf[0],
                         type = IGRBC,
                         display_att = dynargs.display_stuff,
                         ele_spec_att = &ele_attr,
                         geometry = &dynargs.curvebuff[1]);
 
      dp$build_dis_buffer(buffer = &dynargs.disbuf[1],
                         type = IGRBC,
                         display_att = dynargs.display_stuff,
                         ele_spec_att = &ele_attr,
                         geometry = &dynargs.curvebuff[2]);
    
      dynargs.plane_surf.poles = (IGRdouble *)dynargs.pln_poles;
      dynargs.plane_surf.weights = NULL;
      dynargs.plane_surf.u_knots = (IGRdouble *)dynargs.pln_u_knots;
      dynargs.plane_surf.v_knots = (IGRdouble *)dynargs.pln_v_knots;
      dynargs.tmp_bool = TRUE; /* the display should be symmetric */
    
      dp$dynamics(dyn_fun = EFsymmarcdyn, information = &dynargs);
 
      /*
       * Getting the event finally.
       */
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_VALUE | GRm_RJT_MOVEON | 
                   GRm_FORM_FINISHED;

      sts = ems$getevent (msg = &msg_loc,
                          event_mask = event_mask,
                          value_type = GRIO_DISTANCE,
                          response = (long *) response,
                          response_data = response_data,
                          event = &acc_event);
      if (!(1&sts) || msg_loc == MSFAIL)
      {
        if (OM_Gf_verbose_warning)
          fprintf(stderr, "\nIn ECridge: ems$getevent error\n");
        sts = FAIL;
        goto ret_end;
      }

      me->loc_events[LOCATE_PROFILE].values[0] = 0.0;

      if( msg_loc == GRw_no_value )
      {
         /*
          * As the user keyed in ENTER, take the default value.
          */
         me->sweep_angle = 360.0;
         me->loc_events[LOCATE_PROFILE].values[0] = 0.0;
         ME.super_cmd->state = SELECT_SOLID;
         msg_loc = EMS_S_Success;
      }
      else
      {
         switch(acc_event.response)
         {
           case EX_DATA:
           {
             /*
              * Get the length of the arcs.
              */
             cursor_pt[0] = acc_event.event.button.x;
             cursor_pt[1] = acc_event.event.button.y;
             cursor_pt[2] = acc_event.event.button.z;
    
             BSmdstptcv( &dynargs.curvebuff[0], cursor_pt, &parval, junkpt, 
                         &loc_value, &rc );
             if(rc != BSSUCC)
             { 
               sts = EMS_E_BSerror; 
               goto ret_end;
             } 
    
             zero = 0.0;
             parval = ((parval > 0.5) ? (1.0 - parval) : parval);
    
             sts = BSarclength(&rc, &dynargs.curvebuff[0], &zero, &parval, &arcln);
             if(rc != BSSUCC) {sts = EMS_E_BSerror; goto ret_end;}
    
             if(arcln < arctol)
             {
               ex$message(msgnumb = EMS_E_EntdValuGtrCht)
             }
             else
             {
               /* 
                * Find the angle and store this information.
                */
               max_len = M_PI * radius;
               ang_val = ((arcln > max_len) ? (2.0 * max_len - arcln) : arcln) / radius;
    
               /*
                * Converting to degress.
                */
               sts = MAraddeg(&msg_loc, &ang_val, &ang_val);
               me->sweep_angle = ang_val * 2.0; /* because of symmetry */
   
               if( fabs(360.0 - me->sweep_angle) > lentol )
                 ME.super_cmd->state = ENTER_START_ANGLE;
               else
                 ME.super_cmd->state = SELECT_SOLID;
             }
           }
           break;
    
           case EX_VALUE:
           {
             ang_val = acc_event.event.value;
             if(ang_val < 0.0)
             {
               ex$message(msgnumb = EMS_E_InvalidAngle)
             }
             else
             {
               me->sweep_angle = ang_val;
               if( fabs(360.0 - me->sweep_angle) > lentol )
                 ME.super_cmd->state = ENTER_START_ANGLE;
               else
                 ME.super_cmd->state = SELECT_SOLID;
             }
           }
           break;
       
           case EX_RJT_MOVEON :
           {
             me->sweep_angle = 360.0;
             me->loc_events[LOCATE_PROFILE].values[0] = 0.0;
             ME.super_cmd->state = SELECT_SOLID;
           }
           break;
    
           case EX_BACK_UP:
             ME.super_cmd->state = SELECT_AXIS;
             break;
    
           case EX_FORM_FINISHED:
             break;
    
           default:
             sts = OM_S_SUCCESS;
             goto  ret_end;
    
         } /* end of the switch(acc_event.response) */
      }
    }
    break;

    /* --------------------------------------------------------------------- *
     *                           Enter Sweep Angle                           *
     * --------------------------------------------------------------------- */
 
    case ENT_SWEEP_ANGLE:
    {
      ex$message(msgnumb = EMS_P_EntSweepAng)
      info = &me->loc_events[LOCATE_AXIS].located_object[0];
      sts = om$send( msg = message GRcurve.GRendpts(&msg_loc,
                           &info->module_info.md_env.matrix_type,
                           info->module_info.md_env.matrix,
                           start_pnt, stop_pnt),
                     senderid = NULL_OBJID,
                     targetid = info->located_obj.objid,
                     targetos = info->located_obj.osnum);
      if(!(1&sts)) goto ret_end; 
 
      sts = BSdistptli(&rc, &me->pivot_pnt[0], start_pnt, stop_pnt, &radius);
      if(rc != BSSUCC) {sts = EMS_E_BSerror; goto ret_end;}
    
      OM_BLOCK_MOVE(start_pnt, &dynargs.axis_ends[0][0], sizeof(IGRpoint));
      OM_BLOCK_MOVE(stop_pnt, &dynargs.axis_ends[1][0], sizeof(IGRpoint));
    
      sts = BSproj0(&rc, &me->pivot_pnt[0], dynargs.axis_ends, proj_pnt);
      if(rc != BSSUCC) {sts = EMS_E_BSerror; goto ret_end;}
 
      sts = BSprepcircp( &rc, proj_pnt, me->pivot_pnt, me->axis_vec, 
                         &dynargs.curvebuff[0], unit_vec, &type);
      if(rc != BSSUCC) {sts = EMS_E_BSerror; goto ret_end;}
 
      ele_attr.is_polydis  = FALSE;
      ele_attr.is_curvedis = TRUE;
    
      dynargs.display_stuff = &ME.COconst->ActiveDisplay;
      OM_BLOCK_MOVE(&me->pivot_pnt[0], &dynargs.curvebuff[1].poles[0],
                    sizeof(IGRpoint));
      dp$build_dis_buffer( buffer = &dynargs.disbuf[0],
                           type = IGRBC,
                           display_att = dynargs.display_stuff,
                           ele_spec_att = &ele_attr,
                           geometry = &dynargs.curvebuff[1]);
    
      OM_BLOCK_MOVE(proj_pnt, dynargs.center, sizeof(IGRpoint));
      OM_BLOCK_MOVE(me->axis_vec, dynargs.tmp_vec, sizeof(IGRvector));
      OM_BLOCK_MOVE(me->pivot_pnt, dynargs.the_point, sizeof(IGRvector));
    
      dynargs.plane_surf.poles = (IGRdouble *)dynargs.pln_poles;
      dynargs.plane_surf.weights = NULL;
      dynargs.plane_surf.u_knots = (IGRdouble *)dynargs.pln_u_knots;
      dynargs.plane_surf.v_knots = (IGRdouble *)dynargs.pln_v_knots;
      dynargs.tmp_bool = FALSE; /* one sided display */
    
      dp$dynamics(dyn_fun = EFsymmarcdyn, information = &dynargs);

      /* initialize the start angle */ 
      me->loc_events[LOCATE_PROFILE].values[0] = 0.0;

      /*
       * Getting the event finally.
       */
      event_mask = GRm_DATA | GRm_BACK_UP | GRm_VALUE | GRm_RJT_MOVEON |  
                   GRm_FORM_FINISHED;

      sts = ems$getevent (msg = &msg_loc,
                          event_mask = event_mask,
                          value_type = GRIO_DISTANCE,
                          response = (long *) response,
                          response_data = response_data,
                          event = &acc_event);
      if (!(1&sts) || msg_loc == MSFAIL)
      {
        if (OM_Gf_verbose_warning)
          fprintf(stderr, "\nIn ECridge: ems$getevent error\n");
        sts = FAIL;
        goto ret_end;
      }

      if( msg_loc == GRw_no_value )
      {
         /*
          * As the user keyed in ENTER, take the default value.
          */
         me->sweep_angle = 360.0;
         me->loc_events[LOCATE_PROFILE].values[0] = 0.0;
         ME.super_cmd->state = SELECT_SOLID;
         msg_loc = EMS_S_Success;
      }
      else
      {
         switch(acc_event.response)
         {
           case EX_DATA:
           {
             /*
              * Get the length of the arcs.
              */
             cursor_pt[0] = acc_event.event.button.x;
             cursor_pt[1] = acc_event.event.button.y;
             cursor_pt[2] = acc_event.event.button.z;
    
             BSmdstptcv( &dynargs.curvebuff[0], cursor_pt, &parval, junkpt,
                         &loc_value, &rc );
             if(rc != BSSUCC)
             {
               sts = EMS_E_BSerror;
               goto ret_end;
             }
    
             zero = 0.0;

             sts = BSarclength(&rc, &dynargs.curvebuff[0], &zero, &parval, &arcln);
             if(rc != BSSUCC) {sts = EMS_E_BSerror; goto ret_end;}
    
             if(arcln < arctol)
             {
               ex$message(msgnumb = EMS_E_EntdValuGtrCht)
             }
             else
             {
               /* 
                * Find the angle and store this information.
                */
               ang_val = arcln/radius;
    
               /*
                * Converting to degress.
                */
               sts = MAraddeg(&msg_loc, &ang_val, &ang_val);
               me->sweep_angle = ang_val;
   
               if( fabs(360.0 - me->sweep_angle) > lentol )
                 ME.super_cmd->state = ENTER_START_ANGLE;
               else 
                 ME.super_cmd->state = SELECT_SOLID;
             }
           }
           break;
    
           case EX_VALUE:
           {
             ang_val = acc_event.event.value;
    
             if(ang_val < 0.0)
             {
               ex$message(msgnumb = EMS_E_InvalidAngle)
             }
             else
             {
               me->sweep_angle = ang_val;
   
               if( fabs(360.0 - me->sweep_angle) > lentol )
                 ME.super_cmd->state = ENTER_START_ANGLE;
               else 
                 ME.super_cmd->state = SELECT_SOLID;
             }
           }
           break;
   
           case EX_RJT_MOVEON :
           {
             me->sweep_angle = 360.0;
             me->loc_events[LOCATE_PROFILE].values[0] = 0.0;
             ME.super_cmd->state = SELECT_SOLID;
           }
           break;
   
           case EX_BACK_UP:
             ME.super_cmd->state = SELECT_REV_SIDE;
             break;
    
           case EX_FORM_FINISHED:
             break;
    
           default:
             sts = OM_S_SUCCESS;
             goto  ret_end;
         } /* end of the switch(acc_event.response) */
      }
    }
    break;
 
    /* ------------------------------------------------------------------- *
     *                         Select Trace Curve                          *
     * ------------------------------------------------------------------- */
   
    case SELECT_TRACE_CURVE:
    {
       struct GRmdenv_info prof_env, trac_env;

       info = &me->loc_events[LOCATE_TRACE_CURVE].located_object[0];

       if (info->located_obj.objid != NULL_OBJID)
       {
         curve_reversed = info->geom_parms.polygon_inx;

         sts = EFdisplay_curve_normal_or_tangent (info, NULL, FALSE,
                                        curve_reversed, my_id, GRbe,
                                        &info->module_info, &disp_attr,
                                        &msg_loc);
         ERROR(sts, msg_loc, "execute.EFdisplay_curve_normal_or_tangent error")
       }

       ex$message(msgnumb = EMS_P_SelectTracCurve)
    
       reject_classid               = OPP_GR3dpoint_class_id;
       dont_locate.next             = NULL;
       dont_locate.option           = 2;
       dont_locate.type             = 3;
       dont_locate.num_objects      = 1;
       dont_locate.objects.classids = &reject_classid;
     
       display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT;
       locate_mask  = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
       accept_mask  = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
     
       ex$message(msgnumb = EMS_P_SelectTracCurve, buff = locate_prompt)
       ex$message(msgnumb = EMS_P_00038, buff = accept_prompt)
       ex$message(msgnumb = EMS_I_TracCvNotFnd, buff = relocate_prompt)
     
       attributes.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW;

       aflag = pwIsActivationOn();
       if (aflag)
       {
       attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                                LC_NO_REF_HEADER | LC_REF_OBJECTS;
       /** Remove LC_NO_REF for RFA **/
       }
       else
       {
       attributes.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
                                LC_NO_REF_HEADER | LC_NO_REF_OBJECTS;
       }

       strcpy(attributes.classes, "GRcurve");
     
       rtree_classes.w_count   = 1;
       elig_classes.w_count    = 1;
       rtree_classes.w_flags   = OM_CLST_subclass;
       elig_classes.w_flags    = OM_CLST_subclass;
       rclass                  = OPP_GRcurve_class_id;
       eliclass                = OPP_GRcurve_class_id;
       rtree_classes.p_classes = &rclass;
       elig_classes.p_classes  = &eliclass;
     
       aflag = pwIsActivationOn();
       if (aflag)
       {
       extern IGRlong RFlocate_ref_plane_handler();
       GRspacenum osn;
       osn = pwGetActiveOs(); 
       lc$locate( rc                = &object_was_located,
                  event1            = &me->locate_event,
                  event2            = &acc_event,
                  event3            = &loc_event,
                  mask1             = locate_mask,
                  mask2             = accept_mask,
                  display_flag      = display_flag,
                  response          = response,
                  response_data     = response_data,
                  locate_key        = EMS_P_00032,
                  acc_key           = EMS_P_00038,
                  relocate_key      = EMS_I_00012,
                  attributes        = &attributes,
                  stack             = &me->locate_stack,
                  act_handler       = RFlocate_ref_plane_handler,
                  act_args          = &osn,
                  rtree_classes     = &rtree_classes,
                  eligible_classes  = &elig_classes);
       }
       else
       {
       stat_func = lc$locate( rc = &object_was_located,
                              event1 = &me->locate_event,
                              event2 = &acc_event,
                              event3 = &loc_event,
                              mask1 = locate_mask,
                              mask2 = accept_mask,
                              eventsize = &event_size,
                              display_flag = display_flag,
                              response = response,
                              response_data = response_data,
                              locate_prompt = locate_prompt,
                              acc_prompt = accept_prompt,
                              relocate_prompt = relocate_prompt,
                              act_args = &dont_locate,
                              attributes = &attributes,
                              stack = &me->locate_stack,
                              rtree_classes = &rtree_classes,
                              eligible_classes = &elig_classes); 
        }
       ex$message(msgnumb = EMS_P_ClearPromptField)
       ex$message(msgnumb = EMS_S_ClearStatusField)
       OM_BLOCK_MOVE(&loc_event, &event, event_size);

       if(stat_func == FALSE)
       {
         ex$message(msgnumb = EMS_E_FailInputProcExit)
         *response = TERMINATE;
         goto ret_end;
       }

       if(!object_was_located)
       {
         switch(me->locate_event.response)
         {
           case EX_BACK_UP:
             if(me->is_close)
               ME.super_cmd->state = SELECT_PROFILE;
             else
               ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
             break;

           default: 
             sts = OM_S_SUCCESS;
             goto  ret_end;
         }
       }
       else
       {
         sts = dp$erase_hilite(msg = &msg_loc);
         ERROR(sts, msg_loc, "execute.erase_hilite error")

         switch(acc_event.response)
         {
           case EX_DATA:
           {
             IGRint     n_int=0, n_seg=0;
             IGRdouble  *int_points=NULL, *u=NULL, *a=NULL, *b=NULL;
             struct IGRbsp_curve *trace_geom=NULL;

             OM_BLOCK_MOVE (&loc_event, &me->loc_events[LOCATE_TRACE_CURVE], 
                            event_size);
             me->numobjs ++;

             /*
              * For the skin solid generation it is must that the trace curve
              * intersects with the plane of the cross section curve. So, check
              * for the same and issue a message if it is not so.
              */

             info = &me->loc_events[LOCATE_PROFILE].located_object[0];
             prof_id.objid = info->located_obj.objid;
             prof_id.osnum = info->located_obj.osnum;
             OM_BLOCK_MOVE( &info->module_info.md_env, &prof_env,
                            sizeof(struct GRmdenv_info));

             OM_BLOCK_MOVE( 
                   me->loc_events[LOCATE_PROFILE].located_object[0].proj_pnt, 
                   &me->pivot_pnt[0], sizeof(IGRpoint));

             info = &me->loc_events[LOCATE_TRACE_CURVE].located_object[0];
             trac_id.objid = info->located_obj.objid;
             trac_id.osnum = info->located_obj.osnum;
             OM_BLOCK_MOVE( &info->module_info.md_env, &trac_env,
                            sizeof(struct GRmdenv_info));

             /*
              * Get the geometry of the trace curve 
              */
             sts = EMgetvggeom(&msg_loc, &info->module_info.md_env.matrix_type,
                          info->module_info.md_env.matrix, &trac_id, 
                          &trace_geom, NULL );
             ERROR(sts, msg_loc, "execute.GRvg.GRgetgeom error")

             /*
              * Test whether there is an intersection between the trace curve
              * and the plane of the cross-section
              */
             int_points = (double *) om$malloc( size = trace_geom->num_poles *
                                                       3 * sizeof(IGRdouble) );
             u = (double *) om$malloc( size = trace_geom->num_poles *
                                              sizeof(IGRdouble) );
             a = (double *) om$malloc( size = trace_geom->num_poles *
                                              sizeof(IGRdouble) ); 
             b = (double *) om$malloc( size = trace_geom->num_poles *
                                              sizeof(IGRdouble) ); 

             ok = BSpl_cv_int( &msg_loc, trace_geom, me->pivot_pnt, 
                               me->vec_nor_prfpln, &n_int, int_points, u, 
                               &n_seg, a, b );

             om$dealloc( ptr = int_points ); om$dealloc( ptr = u );
             om$dealloc( ptr = a ); om$dealloc( ptr = b );
             om$dealloc( ptr = trace_geom); trace_geom = NULL;

             if( !ok || !n_int )
             {
               ex$message(msgnumb = EMS_I_TrcIntWithPrfpln)
               break;
             }

             me->loc_events[LOCATE_TRACE_CURVE].response = acc_event.response;
             me->loc_events[LOCATE_TRACE_CURVE].event.button.x = 
               me->loc_events[LOCATE_TRACE_CURVE].located_object[0].proj_pnt[0];
             me->loc_events[LOCATE_TRACE_CURVE].event.button.y = 
               me->loc_events[LOCATE_TRACE_CURVE].located_object[0].proj_pnt[1];
             me->loc_events[LOCATE_TRACE_CURVE].event.button.z = 
               me->loc_events[LOCATE_TRACE_CURVE].located_object[0].proj_pnt[2];

             EFdetermine_direction (&me->loc_events[LOCATE_TRACE_CURVE], my_id,
                                    &msg_loc);

             info = &me->loc_events[LOCATE_TRACE_CURVE].located_object[0];

             curve_reversed = info->geom_parms.polygon_inx;
             
             sts = EFdisplay_curve_normal_or_tangent (info, NULL, FALSE,
                                            curve_reversed, my_id, GRbd, 
                                            &info->module_info, &disp_attr, 
                                            &msg_loc);
             ERROR(sts, msg_loc, "execute.EFdisplay_curve_normal_or_tangent error")
             if( me->from_to )
               ME.super_cmd->state = SELECT_FROM_SURF_OR_REF_PLN;
             else
               ME.super_cmd->state = SELECT_SOLID;
           }
           break;

           case EX_BACK_UP:
           {
             OM_BLOCK_MOVE (&loc_event, &me->loc_events[LOCATE_TRACE_CURVE], 
                            event_size);

             info = &me->loc_events[LOCATE_TRACE_CURVE].located_object[0];

             if (info->located_obj.objid != NULL_OBJID)
             {
               curve_reversed = info->geom_parms.polygon_inx;

               sts = EFdisplay_curve_normal_or_tangent (info, NULL, FALSE,
                                              curve_reversed, my_id, GRbe,
                                              &info->module_info, &disp_attr,
                                              &msg_loc);
               ERROR(sts, msg_loc, "execute.EFdisplay_curve_normal_or_tangent error")
             }

             if(!me->is_close)
               ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
             else
               ME.super_cmd->state = SELECT_PROFILE;
           }
           break;

           case EX_FORM_FINISHED:

           break;
           
           default:
           {
             sts = OM_S_SUCCESS;
             goto  ret_end;
           }

         } /* end of the switch(acc_event.response) */

       } /* the object was located */ 

    } /* SELECT_TRACE_CURVE */

    break;

    /* ------------------------------------------------------------------- *
     *                       Select Base Solid                             *
     * ------------------------------------------------------------------- */
     
    case SELECT_SOLID:
    {
       IGRboolean  compute_matside=FALSE;

       /*
        * I would like to maximum calculations before the final solid is 
        * selected, so that the actual processing time will become less.
        */
       
       /*
        * In case of projected, finite option, the start point which is 
        * input, indicates that the secondary solid should be projected
        * from that point, so calculate the distance between the profile
        * plane and the input start point taking into consideration the 
        * projection vector. Store the calculated distance in the locate
        * profile event structure. 
        */
       if( me->projected && me->finite )
       {
         // get the located point of the profile.
         OM_BLOCK_MOVE(
            me->loc_events[LOCATE_PROFILE].located_object[0].proj_pnt,
            loctmp1, sizeof(IGRpoint) );

         if( BSdistptpt( &rc, loctmp1, me->pivot_pnt) > lentol )
         {
           IGRpoint  intpt;
  
           // calculate the intersection point of the profile plane and the 
           // projection vector.
  
           OM_BLOCK_MOVE(
              me->loc_events[LOCATE_PROFILE].located_object[0].proj_pnt, 
              plane_of_curve.point, sizeof(IGRpoint) );
           OM_BLOCK_MOVE( me->vec_nor_prfpln, plane_of_curve.normal,
                          sizeof(IGRvector) );
 
           OM_BLOCK_MOVE( me->pivot_pnt, line[0], sizeof(IGRpoint) );
  
           for(i=0; i<3; i++)
             line[1][i] = line[0][i] + me->vec_nor_prfpln[i];
          
           BSxlnpl( &rc, me->vec_nor_prfpln, me->loc_events[LOCATE_PROFILE].
                    located_object[1].proj_pnt, line[0], line[1], intpt );
           if( rc != BSSUCC ) { sts = EMS_E_BSerror; goto ret_end; }
  
           /*
            * calculate the distance between the intersection point and the 
            * starting point of projection vector and store it in the located
            * event structure of the profile. Also need to calculate is whether
            * the starting point selected is 
            */
           me->loc_events[LOCATE_PROFILE].values[0] = BSdistptpt(&rc, line[0],
                                                              intpt); 
           BSmkvec( &rc, vector, intpt, line[0] );
           if( rc != BSSUCC ) { sts = EMS_E_BSerror; goto ret_end; }
  
           BSnorvec( &rc, vector );
  
           if( BSdotp(&rc, vector, me->vec_nor_prfpln) < 0.0 ) 
             me->loc_events[LOCATE_PROFILE].values[0] *= -1.0;
         }
         else
         {
           me->loc_events[LOCATE_PROFILE].values[0] = 0.0;
         }
       }
  
       /*
        * Compute the material addition side :
        * ------------------------------------
        * After calculating the matadd_side which is a boolean flag,(Ref.
        * to the following notes) store a negitive value -10.1234 if the
        * material addition is outside, otherwise store a positive value 
        * 10.1234 in the first field of matadd_vector of the instance data.
        * One can enter into this state any number of times, so to avoid 
        * the calculations, check the value of mattadd_vector[0] againast
        * values stored, if it is not matching with any of the above values
        * then perform the calculations, otherwise no need to any calcul-
        * ations.
        */
       compute_matside = ( (fabs(fabs(me->matadd_vector[0]) - 10.1234) > 
                           lentol)? TRUE : FALSE );

       if( compute_matside )
       {
         /*
          * Material addition side : 
          * ------------------------
          * Actually, one should store the material addition direction only 
          * in case of open profiles. But After the feature created by using 
          * a closed profile and by using "Edit Profile" command one can mo-
          * dify the profile, so there is a chance that the closed  profile 
          * may become open or vice versa. Instead of storing the actual mat-
          * erial addition direction, we will store a boolean flag for  both
          * closed and open profiles that is : 
          * 
          * if (T * N) . M > zero then  material side = 1 i.e. the profile 
          *                             will be closed in the same direction
          *                             it is created.
          * if (T * N) . M < zero then  material side = -1 i.e. the profile
          *                             will be closed in the opposite dire-
          *                             ction it is created. 
          *
          *
          * Here : T - tangent to the profile.
          *        N - Normal of the profile plane.
          *        M - Material addition direction.
          *                               
          */
  
         if( me->is_close ) /* closed profile */
         {
            IGRboolean       reversed, inside=TRUE;
            struct GRid      prof_grid;
            struct GRmd_env  md_env;

            prof_grid = me->loc_events[LOCATE_PROFILE].located_object[0].
                          located_obj;
            md_env    = me->loc_events[LOCATE_PROFILE].located_object[0]. 
                          module_info;
            /*
             * First set the direction of the mat_add side to false 
             */
            reversed = FALSE;
  
            /*
             * Then see whether it is inside or out side with this direction
             */
            ok = MatInsideYesNo( &msg_loc, me->vec_nor_prfpln, &prof_grid,
                                 &md_env, reversed, &inside );
            EMerr_hndlr( !ok, sts, OM_E_ABORT, ret_end );
  
            if( !inside )
                reversed = TRUE;
  
            me->matadd_vector[0] = ((reversed) ? -10.1234 : 10.1234) ;
  
         }
         else /* open profile */
         {
            if( !profgeom )
            { 
              IGRshort     mat_type;
              IGRdouble    *mat; 
              struct GRid  prof_grid; 
  
              prof_grid = me->loc_events[LOCATE_PROFILE].located_object[0].
                          located_obj;
              mat_type  = me->loc_events[LOCATE_PROFILE].located_object[0]. 
                          module_info.md_env.matrix_type;
              mat       = me->loc_events[LOCATE_PROFILE].located_object[0].
                          module_info.md_env.matrix;
  
              sts = om$send( msg = message GRvg.GRgetsize(&msg_loc, 
                                           &mat_type, mat, &num_bytes),
                            targetid = prof_grid.objid,
                            targetos = prof_grid.osnum); 
              ERROR(sts, msg_loc, "execute.GRvg.GRgetsize error")
  
              profgeom = (struct IGRbsp_curve *) alloca( num_bytes );
  
              sts = om$send( msg = message GRvg.GRgetgeom(&msg_loc, 
                                           &mat_type, mat, 
                                           (IGRchar *)profgeom),
                             targetid = prof_grid.objid,
                             targetos = prof_grid.osnum);
              ERROR(sts, msg_loc, "execute.GRvg.GRgetgeom error")
           }
  
           /*
            * get the parameter value of the curve at the pivot point.
            */
           OM_BLOCK_MOVE (me->loc_events[LOCATE_PROFILE].located_object[0].
                          proj_pnt, proj_pnt, sizeof (IGRpoint));
           BSmdstptcv (profgeom, proj_pnt, &parval, wpt, &wdist, &rc);
           if( BSERROR(rc) ) goto ret_end;
     
           /*
            * get the tangent to the profile. 
            */
           BScveval (profgeom, parval, 1, prof_tan, &rc);
           if (BSERROR(rc)) goto ret_end;
           BSnorvec (&rc, prof_tan[1]); 
           if (BSERROR(rc)) goto ret_end;
    
           /*
            * Now find  (T*N).M value
            */
           BScrossp (&rc, prof_tan[1], me->vec_nor_prfpln, cross_vec);  
           if(BSERROR(rc)) goto ret_end;
      
           loc_value = BSdotp (&rc, cross_vec, me->matadd_vector);
           if (BSERROR(rc)) goto ret_end;
    
           me->matadd_vector[0] = ((loc_value < 0.0) ? -10.1234 : 10.1234) ;
         }
       }

       dp$erase_hilite(msg = &msg_loc);

       display_flag = ALL_WINDOWS | ELEM_HILIGHT;
       locate_mask  = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
       accept_mask  = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
       
       elig_classes.w_count     = 1;
       eliclass                 = OPP_EMSsolid_class_id;
       elig_classes.p_classes   = &eliclass;
       elig_classes.w_flags     = OM_CLST_subclass;
     
       rtree_classes.w_count    = 1;
       rclass                   = OPP_EMSsubbs_class_id;
       rtree_classes.w_flags    = OM_CLST_subclass;
       rtree_classes.p_classes  = &rclass;
        
       attributes.properties    = LC_LC_ONLY | LC_DP_ONLY | LC_RW;

       aflag = pwIsActivationOn();
       if (aflag)
       {
       attributes.owner_action  = LC_RIGID_OWNER | LC_FLEX_COMP |
                                  LC_NO_REF_HEADER | LC_REF_OBJECTS |
                                  LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;
       /** Removed NO_REF_OBJECTS for RFA **/
       }
       else
       {
       attributes.owner_action  = LC_RIGID_OWNER | LC_FLEX_COMP |
                                  LC_NO_REF_HEADER | LC_NO_REF_OBJECTS |
                                  LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;
       }

       aflag = pwIsActivationOn();
       if (aflag)
       {
       extern IGRlong RFlocate_ref_plane_handler();
       GRspacenum osn;
       osn = pwGetActiveOs(); 
       lc$locate( rc                = &object_was_located,
                  event1            = &me->locate_event,
                  event2            = &acc_event,
                  event3            = &loc_event,
                  mask1             = locate_mask,
                  mask2             = accept_mask,
                  display_flag      = display_flag,
                  response          = response,
                  response_data     = response_data,
                  locate_key        = EMS_P_00032,
                  acc_key           = EMS_P_00038,
                  relocate_key      = EMS_I_00012,
                  attributes        = &attributes,
                  stack             = &me->locate_stack,
                  act_handler       = RFlocate_ref_plane_handler,
                  act_args          = &osn,
                  rtree_classes     = &rtree_classes,
                  eligible_classes  = &elig_classes);
       }
       else
       {
       lc$locate( rc                = &object_was_located,
                  event1            = &me->locate_event,
                  event2            = &acc_event,
                  event3            = &loc_event,
                  mask1             = locate_mask,
                  mask2             = accept_mask,
                  display_flag      = display_flag,
                  response          = response,
                  response_data     = response_data,
                  locate_key        = EMS_P_00032,
                  acc_key           = EMS_P_00038,
                  relocate_key      = EMS_I_00012,
                  attributes        = &attributes,
                  stack             = &me->locate_stack,
                  rtree_classes     = &rtree_classes,
                  eligible_classes  = &elig_classes);
        }
 
       /*
        * Clear the prompt 
        */
       ex$message(msgnumb = EMS_P_00000);

       if(!object_was_located)
       {
         switch(loc_event.response) 
         {
           case EX_BACK_UP:
           {
             if(me->projected)
             {
               if(me->normal)
               {
                 if(me->to_next || me->thru_next)
                   ME.super_cmd->state = SELECT_PRJ_SIDE;
                 else if(me->from_to)
                   ME.super_cmd->state = SELECT_TO_SURF_OR_REF_PLN;
                 else if(me->finite)
                 {
                   if(me->symmetric)
                     ME.super_cmd->state = ENTER_SYMMETRIC_DIST;
                   else
                     ME.super_cmd->state = ENTER_DISTANCE;
                 }
                 else if(me->thru_all)
                 {
                   if(!me->is_close)
                     ME.super_cmd->state = SELECT_ADD_MAT_SIDE;
                   else
                     ME.super_cmd->state = SELECT_PROFILE;
                 }
               }
               else /* the projection is non-normal */
               {
                 if(me->to_next || me->thru_next)
                   ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
                 else if(me->from_to)
                   ME.super_cmd->state = SELECT_TO_SURF_OR_REF_PLN;
                 else if(me->finite)
                   ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
               } 
             }
             else if(me->revolved)
             {
               if (me->finite)
               {
                 if(me->symmetric)
                   ME.super_cmd->state = ENT_SYMM_SWEEP_ANG;
                 else 
                   ME.super_cmd->state = ENT_SWEEP_ANGLE;
               }
               else if (me->thru_all)
               {
                 ME.super_cmd->state = SELECT_AXIS;
               }
               else if (me->to_next || me->thru_next)
               {
                 ME.super_cmd->state = SELECT_REV_SIDE;
               }
               else if (me->from_to)
               {
                 ME.super_cmd->state = SELECT_REV_SIDE;
               }
             }
             else if(me->skinned)
               ME.super_cmd->state = SELECT_TRACE_CURVE;
           }

           default:
             sts = OM_S_SUCCESS;
             goto  ret_end;
         }

       } /* if(!object_was_located) */

       else

       {
         OM_BLOCK_MOVE(&loc_event, &me->loc_events[LOCATE_SOLID], event_size);
         me->numobjs ++;

         /*
          * put the accept event on the queue
          */
         putque_size = sizeof(acc_event.event) + sizeof(IGRint);
         sts = ex$putque(msg = &msg_loc, response = response,
                       byte = &putque_size, buffer = (char *)&acc_event.event);
         ERROR(sts, msg_loc, "ex$putque error") 
         ME.super_cmd->state = FEATURE_PLACEMENT_STATE;
         sts = dp$erase_hilite(msg = &msg_loc);
       }
    }
    break;

    /* ------------------------------------------------------------------- *
     *                      Process the Feature                            *
     * ------------------------------------------------------------------- */

    case FEATURE_PLACEMENT_STATE:
    {
      OMuword     prof_class;
      struct GRid prof_grid;

      prof_grid = me->loc_events[LOCATE_PROFILE].located_object[0].located_obj;

      ex$message(msgnumb = EMS_P_00038)

      event_mask = GRm_DATA | GRm_BACK_UP | GRm_FORM_FINISHED;
      sts = ems$getevent( msg           = &msg_loc, 
                          event_mask    = event_mask,
                          response      = (IGRlong *)response, 
                          response_data = response_data,
                          event         = &event);
      if(!(1&sts)) { sts = FAIL; goto ret_end; }

      switch(event.response)
      {
        case EX_DATA:
        {
          ex$message(msgnumb = EMS_I_00003)
          const_args.msg = &msg_loc;
          const_args.newflag = FALSE;
          const_args.geometry = NULL;
          const_args.class_attr = NULL;
          const_args.name = NULL;
          const_args.env_info = 
                &me->loc_events[LOCATE_SOLID].located_object[0].module_info;
          const_args.level = ME.COconst->ActiveLevel;
          const_args.display = &ME.COconst->ActiveDisplay;
          const_args.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
          me->construct_id.osnum = 
             me->loc_events[LOCATE_SOLID].located_object[0].located_obj.osnum; 

          /*
           * Perform the actual feature placement operation.
           */
          info = &me->loc_events[LOCATE_SOLID].located_object[0];
          world = TRUE;
          sts = om$send( msg = message GRvg.GRgetrang(&msg_loc,
                                       &info->module_info.md_env.matrix_type,
                                       info->module_info.md_env.matrix,
                                       &world, range),
                         senderid = NULL_OBJID,
                         targetid = info->located_obj.objid,
                         targetos = info->located_obj.osnum);
          if(!(1&sts)) goto ret_end;

          if(me->thru_all)
          {
            feaopts |= EMSfeature_thru_all;
            for(i=0; i<3; i++)
            {
             temp_pt[0][i] = me->pivot_pnt[i];
             temp_pt[1][i] = me->pivot_pnt[i] + me->projection_vec[i];
            }
            (void)BSproj0(&rc, &range[0], temp_pt, loctmp1);
            (void)BSproj0(&rc, &range[3], temp_pt, loctmp2);

            /*
             * form a vector between the pivot point & loctmp's
             */
            sts = BSmkvec(&rc, vec0, me->pivot_pnt, loctmp1);
            if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

            value1 = BSlenvec(&rc, vec0);
            if(value1 > -lentol && value1 < lentol)
              is_degen1 = TRUE;
            else
              is_degen1 = FALSE;
   
            sts = BSmkvec(&rc, vec1, me->pivot_pnt, loctmp2);
            if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
            
            value2 = BSlenvec(&rc, vec1);
            if(value1 > -lentol && value1 < lentol)
              is_degen2 = TRUE;
            else
              is_degen2 = FALSE;

            if(!is_degen1 && !is_degen2)
            {
              if(value1 > value2) 
                OM_BLOCK_MOVE(vec0, me->projection_vec, sizeof(IGRvector)); 
              else
                OM_BLOCK_MOVE(vec1, me->projection_vec, sizeof(IGRvector));
            }
            else if(is_degen1)
              OM_BLOCK_MOVE(vec1, me->projection_vec, sizeof(IGRvector));
            else if(is_degen2)
              OM_BLOCK_MOVE(vec0, me->projection_vec, sizeof(IGRvector));
            else
              ex$message(msgnumb = EMS_E_LogicWrong); 
          }
          else if(me->to_next)
            feaopts |= EMSfeature_to_next;
          else if(me->from_to)
          {
            feaopts |= EMSfeature_from_to;
            for(i=0; i<3; i++)
            {
              temp_pt[0][i] = me->pivot_pnt[i];
              temp_pt[1][i] = me->pivot_pnt[i] + me->projection_vec[i];
            }

            (void)BSproj0(&rc,
               me->loc_events[LOCATE_FROM_SURFACE].located_object[0].proj_pnt,
               temp_pt, loctmp1);
            (void)BSproj0(&rc,
               me->loc_events[LOCATE_TO_SURFACE].located_object[0].proj_pnt,
               temp_pt, loctmp2);
            sts = BSmkvec(&rc, loctmp_vec, loctmp1, loctmp2);

            OM_BLOCK_MOVE(loctmp_vec, me->projection_vec, sizeof(IGRvector));
          }
          else if(me->finite)
          {
            feaopts |= EMSfeature_finite;
            if(me->symmetric)
            {
              for(i=0; i<3; i++)
              {
                temp_pt[0][i]=me->pivot_pnt[i] + (me->proj_dist/2.0) *
                                                 me->projection_vec[i];
                temp_pt[1][i]=me->pivot_pnt[i] - (me->proj_dist/2.0) *
                                                 me->projection_vec[i];
              }
              sts = BSmkvec(&rc, loctmp_vec, temp_pt[0], temp_pt[1]);
              OM_BLOCK_MOVE(loctmp_vec, me->projection_vec, sizeof(IGRvector));
            }
          }
          else if(me->thru_next)
          {
            feaopts |= EMSfeature_thru_next;
          }

          /*
           * Computing the projection stop point 
           */
          BSnorvec(&rc, &me->projection_vec[0]);

          /*
           * If it is a skinned option, erase the tangent vector drawn.
           */
          if (me->skinned)
          {
            info = &me->loc_events[LOCATE_TRACE_CURVE].located_object[0];

            curve_reversed = info->geom_parms.polygon_inx;

            sts = EFdisplay_curve_normal_or_tangent (info, NULL, FALSE,
                                           curve_reversed, my_id, GRbe,
                                           &info->module_info, &disp_attr,
                                           &msg_loc);
            ERROR(sts, msg_loc, "execute.EFdisplay_curve_normal_or_tangent error")
          }

          /* ------------------------------------------------------------- *
           *             Populate the recompute Information                *
           * ------------------------------------------------------------- */
          recomp_info.props = 0;
          recomp_info.fprops = 0;

          /* 
           * solid type:
           *  Projected/Revolved/Skinned
           */
          if( me->projected )
            recomp_info.props |= EMSAddRm_Project;
          else if( me->revolved )
            recomp_info.props |= EMSAddRm_Revolve;
          else if( me->skinned )
            recomp_info.props |= EMSAddRm_Skinned;

          /* 
           * solid extent: 
           *   ToNext/ThruNext/FromTo/Finite/Finite&Symmetric/ThruAll
           */
          if((feaopts & EMSfeature_to_next)||(feaopts & EMSfeature_thru_next))
            recomp_info.props |= EMSAddRm_ToNext;
          else if( feaopts & EMSfeature_from_to )
            recomp_info.props |= EMSAddRm_FromTo;
          else if( feaopts & EMSfeature_finite )
          {
            recomp_info.props |= EMSAddRm_Finite;
            if( me->symmetric )
              recomp_info.props |= EMSAddRm_Symmetric;
          }
          else if( feaopts & EMSfeature_thru_all )
            recomp_info.props |= EMSAddRm_ThruAll;

          /* 
           * profile options :
           *  a. open/closed profile
           *  b. profile/composite curve
           *  c. material addition side 
           *  d. projection along normal
           */
          recomp_info.props |= (me->is_close ? NULL : EMSAddRm_ProfOpen);

          /*
           * if it is skinned, then set the bit corrsponding the trace curve 
           * reversal.
           */
          if (me->skinned)
          {
            info = &me->loc_events[LOCATE_TRACE_CURVE].located_object[0];
            curve_reversed = info->geom_parms.polygon_inx;
    
            if (curve_reversed)
              recomp_info.props |= EMSAddRm_ReverseTrace;
          }
          
         
          sts = om$get_classid( objid = prof_grid.objid,
                                osnum = prof_grid.osnum,
                                p_classid = &prof_class ); 
          if ((om$is_ancestry_valid( subclassid = prof_class, 
                  superclassid = OPP_SKgeometry_class_id) != OM_S_SUCCESS) &&
              (om$is_ancestry_valid( subclassid = prof_class,
                  superclassid = OPP_GAcurve_class_id) != OM_S_SUCCESS))
            recomp_info.props |= EMSAddRm_ProfComposite;

          recomp_info.props |= ((me->matadd_vector[0] > 0.0) ? 
                                EMSAddRm_MatInside : NULL);
          recomp_info.props |= ((me->projected && me->normal) ? 
                                EMSAddRm_ProjNormal : NULL);

          /* FROM and TO surface information */
          if( me->from_to )
          {
             if( me->from_surf_id.objid == NULL_OBJID )
               recomp_info.props |= EMSAddRm_NoFromSurf;
             if( me->to_surf_id.objid == NULL_OBJID )
               recomp_info.props |= EMSAddRm_NoToSurf;
          }

          /* ------------------------------------------------------------- *
           *                 Populate the parent information               *
           * ------------------------------------------------------------- */

          /* 
           * Profile information
           * -------------------
           */
          OM_BLOCK_MOVE( 
            &(me->loc_events[LOCATE_PROFILE].located_object[0].located_obj),
            &(parent_info.profile.grid), sizeof(struct GRid) );
          OM_BLOCK_MOVE( 
            &(me->loc_events[LOCATE_PROFILE].located_object[0].module_info),
            &(parent_info.profile.env), sizeof(struct GRmd_env) );

          /*
           * Sweep Direction / Axis of Revolution / Trace curve info.
           * --------------------------------------------------------
           */
          if( me->projected )
          {
            parent_info.sweep_dir.projection_vec.type = EMSdatainfo_numeric;
            OM_BLOCK_MOVE( &me->projection_vec,
                           &(parent_info.sweep_dir.projection_vec.vec[0]),
                           sizeof( IGRvector ) );
          }
          else if( me->revolved )
          {
            parent_info.sweep_dir.rotational_axis[0].type = 
                                                     EMSdatainfo_numeric;
            parent_info.sweep_dir.rotational_axis[1].type = 
                                                     EMSdatainfo_numeric;

            info = &me->loc_events[LOCATE_AXIS].located_object[0];
            sts = om$send( msg = message GRcurve.GRendpts(&msg_loc,
                                 &info->module_info.md_env.matrix_type,
                                 info->module_info.md_env.matrix,
                                 start_pnt, stop_pnt),
                           senderid = NULL_OBJID,
                           targetid = info->located_obj.objid,
                           targetos = info->located_obj.osnum);
            if(!(1&sts)) goto ret_end;

            loc_value = BSdistptpt( &msg_loc, start_pnt, stop_pnt );
            for(i=0; i<3; i++)
               stop_pnt[i] = start_pnt[i] + me->axis_vec[i] * loc_value;

            OM_BLOCK_MOVE( start_pnt,
                           (parent_info.sweep_dir.rotational_axis[0].pt),
                           sizeof( IGRvector ) );
            OM_BLOCK_MOVE( stop_pnt,
                           (parent_info.sweep_dir.rotational_axis[1].pt),
                           sizeof( IGRvector ) );
          }
          else if( me->skinned )
          {
            OM_BLOCK_MOVE(
             &me->loc_events[LOCATE_TRACE_CURVE].located_object[0].located_obj,
             &(parent_info.sweep_dir.trace_curve.grid),
             sizeof( struct GRid ) );
            OM_BLOCK_MOVE(
             &me->loc_events[LOCATE_TRACE_CURVE].located_object[0].module_info,
             &(parent_info.sweep_dir.trace_curve.env),
             sizeof( struct GRmd_env ) );
          }

     
          /*
           * If finite, store projection distance / sweep angle
           */
          if( me->finite )
          {
            if( me->projected )
            {
              parent_info.sweep_extent.start_sweep_dist[0].type = 
                                                       EMSdatainfo_numeric;
              parent_info.sweep_extent.start_sweep_dist[1].type = 
                                                       EMSdatainfo_numeric;
              parent_info.sweep_extent.start_sweep_dist[0].val = 
                                     me->loc_events[LOCATE_PROFILE].values[0];
              parent_info.sweep_extent.start_sweep_dist[1].val = 
                                                             me->proj_dist;
            }
            else if( me->revolved )
            {
              parent_info.sweep_extent.start_sweep_angle[0].type = 
                                                       EMSdatainfo_numeric;
              parent_info.sweep_extent.start_sweep_angle[1].type = 
                                                       EMSdatainfo_numeric;
              parent_info.sweep_extent.start_sweep_angle[0].val = 
                                     me->loc_events[LOCATE_PROFILE].values[0];
              parent_info.sweep_extent.start_sweep_angle[1].val = 
                                                           me->sweep_angle;
            }
          }

          /*
           * If from_to, store the from and to surface ids
           */
          if( feaopts & EMSfeature_from_to )
          {
            OM_BLOCK_MOVE( &(me->from_surf_id),
                           &(parent_info.sweep_extent.from_to_surfaces[0].grid),
                           sizeof( struct GRid ) );
            OM_BLOCK_MOVE( &(me->to_surf_id),
                           &(parent_info.sweep_extent.from_to_surfaces[1]).grid,
                           sizeof( struct GRid ) );
            OM_BLOCK_MOVE( &(me->loc_events[LOCATE_FROM_SURFACE].located_object[0].module_info),
                           &(parent_info.sweep_extent.from_to_surfaces[0].env),
                           sizeof( struct GRmd_env ) );
            OM_BLOCK_MOVE( &(me->loc_events[LOCATE_TO_SURFACE].located_object[0].module_info),
                           &(parent_info.sweep_extent.from_to_surfaces[1]).env,
                           sizeof( struct GRmd_env ) );
          }

          /*
           * Store the base solid id and module environment
           */
         OM_BLOCK_MOVE( &me->loc_events[LOCATE_SOLID].located_object[0].
                         located_obj, &(parent_info.base_solid.grid) ,
                         sizeof( struct GRid ) );
          OM_BLOCK_MOVE( &me->loc_events[LOCATE_SOLID].located_object[0].
                         module_info, &(parent_info.base_solid.env) ,
                         sizeof( struct GRmd_env ) );
          options =  (me->associative ? NULL : EMSasconst_notassociative);

          /*
           * Clear the prompt 
           */
          ex$message(msgnumb = EMS_P_00000);

          if (_Pathway)
          {
            _pathway_trim  =1;
            _pathway_orient=1;
          }

          /*
           * Place the feature.
           */
          sts = EFplace_feature( &msg_loc, options,
                                 ((matopts & EMSadd_material) ? 
                                    EMS_ASSOC_FEATURE_ADD_MATERIAL :
                                    EMS_ASSOC_FEATURE_REMOVE_MATERIAL) ,
                                 (IGRchar *) &recomp_info, 
                                 (IGRchar *) &parent_info,
                                 &const_args, &me->construct_id );

          /*
           * If the feature is successful, then set the POST310 bit in 
           * the dpr properties.
           */
          if (1&sts&msg_loc)
          {
            IGRboolean action = TRUE;
            IGRushort  bit=EMS_POST310_OBJECT;
            IGRlong    sts1=OM_S_SUCCESS, msg1=EMS_S_Success;

            sts1 = om$send (msg = message EMSdpr.EMsetprops (&msg1,
                                      &action, &bit),
                                      targetid = me->construct_id.objid,
                                      targetos=me->construct_id.osnum);
	if (!(1&sts1&msg1) && OM_Gf_verbose_warning)
            {
        fprintf (stderr,"Add/Remove : Post310 bit is not set on the feature\n");
            }
          }

          if (_Pathway)
          {
            _pathway_trim  =0;
            _pathway_orient=0;
          }

          if(!(1&sts&msg_loc))
          {
            if( msg_loc == EMS_E_Fail )
            {
               ex$message( msgnumb = EMS_I_ErrorInConstruction)
               sleep(3);
            }
            me->const_state = EXEC;
         
            /*
             * Redraw the original profile.
             */  
            info = &me->loc_events[LOCATE_PROFILE].located_object[0];
            DisplayMode = GRbd;
            sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                       &info->module_info.md_env.matrix_type,
                                        info->module_info.md_env.matrix,
                                        &DisplayMode, 
                                        &info->module_info.md_id),
                          targetid = info->located_obj.objid,
                          targetos = info->located_obj.osnum);
            if(!(1&sts)) goto ret_end;
          }
          else
          {
/**************For TR# 119601976 ****************************************
        This is the fix made to make the axis associative to the
        Add/Remove feature created. A coincident constraint is
        placed between the parameteric point of the feature and the end
        point of the axis element and a parallel constraint is placed
        between the parameteric axis of the feature and axis element.
							..ashok
*************************************************************************/

        if( me->revolved && me->associative)
          {
          sts = gr$get_module_env(buffer = &mod);
          mattyp = mod.md_env.matrix_type;
          mat =    mod.md_env.matrix;
          bline.point1 = blinept1;
          bline.point2 = blinept2;
          param_types = 1;
          geom_params = NULL;
   sts=EFboreline(&msg_loc,my_id,&me->loc_events[LOCATE_SOLID],&bline);
   sts = om$send (msg = message EMSassoc.EMlocate_geomparam (&msg_loc, NULL,
             &mattyp, mat, param_types, &bline, NUM_STATIC_GEOMPARMS, NULL,
             &num_geom_params,&geom_params),
             targetid = me->construct_id.objid,
             targetos = me->construct_id.osnum);

	 if(!(1&sts)) goto ret_end;

	    paramobj = *geom_params;
            axid.objid = paramobj;
            axid.osnum = me->construct_id.osnum;

        ev = &me->loc_events[LOCATE_AXIS];
        subtype = me->loc_events[LOCATE_AXIS].subtype;
        num_aspt_parents = ev->num_id;
        for (i=0; i<num_aspt_parents; i++)
            aspt_parents[i] = ev->located_object[i].located_obj;

        asptinfo.type = subtype;
        OM_BLOCK_MOVE (&ev->event.button.x, asptinfo.pts[0], sizeof (IGRpoint));
        asptinfo.win_pln.objid = ev->event.button.objid;
        asptinfo.win_pln.osnum = ev->event.button.osnum;

        sts = om$construct (classid =  OPP_EMSasptcnstr_class_id,
                                  msg = message EMScnstr.EMinit (&send_rc,
                                        EMScnstr_connect_geomhandle, &mod,
                                        num_aspt_parents,aspt_parents,NULL,
                                        (char *) &asptinfo,
                                         1,&axid),
                                 osnum = me->construct_id.osnum,
                                 p_objid = &cnstr_grid.objid);

	 if(!(1&sts)) goto ret_end;

	   param_types = 2;
          geom_params = NULL;
   sts=EFboreline(&msg_loc,my_id,&me->loc_events[LOCATE_SOLID],&bline);
   sts = om$send (msg = message EMSassoc.EMlocate_geomparam (&msg_loc, NULL,
             &mattyp, mat, param_types, &bline, NUM_STATIC_GEOMPARMS, NULL,
             &num_geom_params,&geom_params),
             targetid = me->construct_id.objid,
             targetos = me->construct_id.osnum);
	 if(!(1&sts)) goto ret_end;

            paramobj = *geom_params;
            axid.objid = paramobj;
            axid.osnum = me->construct_id.osnum;

        sts = om$construct (classid =  OPP_EMSparvcnstr_class_id,
                                  msg = message EMScnstr.EMinit (&send_rc,
                                        EMScnstr_connect_geomhandle, &mod,
            1,&me->loc_events[LOCATE_AXIS].located_object[0].located_obj, NULL,
                                        NULL,1,&axid),
                                        osnum = me->construct_id.osnum,
                                        p_objid = &cnstr1_grid.objid);
	  if(!(1&sts)) goto ret_end;
        cnstrobjs = cnstr_grid.objid;
        for(i=0;i<=1;i++)
        {
	 sts = om$make_chanselect(channame = "GRcmpowner.to_components",
                                    p_chanselect = &to_text);

        sts = om$get_channel_count( objid = cnstrobjs,
                                       osnum = me->construct_id.osnum,
                                        p_chanselect = &to_text,
                                        count = &num_text);

        text_ids = (OM_S_OBJECT_LINKAGE *)alloca (sizeof(OM_S_OBJECT_LINKAGE) *
                                        num_text);

          sts = om$get_channel_objects(objid = cnstrobjs,
                                          osnum = me->construct_id.osnum,
                                          p_chanselect = &to_text,
                                          list = text_ids,
                                          size = num_text,
                                          count = &num_objs);
          for(j=0;j<num_text;j++)
          {
           sts = om$get_classid(osnum = text_ids[j].osnum,
                                objid = text_ids[j].S_objid,
                                p_classid = &classid);
         disid.objid = text_ids[j].S_objid;
	 disid.osnum =  text_ids[j].osnum;
        if(classid == OPP_EMScnstrtxt_class_id)
        {
        sts = om$send(msg = message NDnode.NDdisconnect(0, NULL),
                               targetid =text_ids[j].S_objid,
                               targetos =text_ids[j].osnum);

                mode = GRbehe;
                om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
                                    &mod.md_env.matrix_type,
                                    mod.md_env.matrix,&mode,
                                    &mod.md_id),
                      targetid = text_ids[j].S_objid,
                      targetos =text_ids[j].osnum);


         sts = om$send(msg = message GRgraphics.GRdelete(&msg_loc,&mod),
                                  targetid =text_ids[j].S_objid,
                                  targetos =text_ids[j].osnum);
	  if(!(1&sts)) goto ret_end;
        }
       }
        cnstrobjs = cnstr1_grid.objid;
      }
              }
/************Fix for TR# 119601976 ends here **************************/

            me->const_state = DONE;
            ex$message( msgnumb = EMS_I_ProcessCompBackUpToUndo) 
          }
          ME.super_cmd->state = BEGIN_STATE;
        }
        break;

        case EX_BACK_UP:
        {
          if(me->projected)
          {
            if(me->normal)
            {
              if(me->to_next)
                ME.super_cmd->state = SELECT_PRJ_SIDE;
              else if(me->from_to)
                ME.super_cmd->state = SELECT_TO_SURF_OR_REF_PLN;
              else if(me->finite)
              {
                if(me->symmetric)
                  ME.super_cmd->state = ENTER_SYMMETRIC_DIST;
                else
                  ME.super_cmd->state = ENTER_DISTANCE;
              }
            }
            else /* the projection is non-normal */
            {
              if(me->to_next)
                ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
              else if(me->from_to)
                ME.super_cmd->state = SELECT_TO_SURF_OR_REF_PLN;
              else if(me->finite)
                ME.super_cmd->state = ENT_2nd_PT_OF_PRJ_VEC;
            }
          }
          else if(me->revolved) /* revolved option */
          {
             if (me->finite)
             {
               if(me->symmetric)
                 ME.super_cmd->state = ENT_SYMM_SWEEP_ANG;
               else
                 ME.super_cmd->state = ENT_SWEEP_ANGLE;
             }
             else if (me->thru_all)
             {
               ME.super_cmd->state = SELECT_AXIS;
             }
             else if (me->to_next || me->thru_next)
             {
               ME.super_cmd->state = SELECT_REV_SIDE;
             }
             else if (me->from_to)
             {
               ME.super_cmd->state = SELECT_TO_SURF_OR_REF_PLN;
             }
          }
          else if(me->skinned) /* skinned option */
            ME.super_cmd->state = SELECT_TRACE_CURVE;
        }
        break;

        case EX_FORM_FINISHED:
          break;

        default:
          sts = OM_S_SUCCESS;
           goto  ret_end;
          /* return(OM_S_SUCCESS); */
      } /* switch */
   }
   break;

   } /* the outermost switch statement */
 }while(TRUE);
ret_end:
  GRstatus_display_button(0);
  if(loop_locatable)
     EFset_locate_eligibility(&msg_loc, 0, "EMSloop");
  return(sts);

} /* End of execute */

#argsused
static IGRint EFlinedyn(dynargs,
              cursor_pt,
              matrix,
              objects,
              num_objects,
              buffer,
              num_buffers,
              in_dummy1,
              in_dummy2,
              in_dummy3,
              out_dummy1,
              out_dummy2,
              out_dummy3)
struct dynfunc_args *dynargs;
struct DPele_header **buffer;
struct GRid **objects;
struct EX_button *cursor_pt;
IGRint *num_objects, *num_buffers;
IGRdouble *matrix;
IGRchar **in_dummy1, **in_dummy2, **in_dummy3;
IGRchar **out_dummy1, **out_dummy2, **out_dummy3;
{
   BSrc        rc;
   IGRint      i;
   IGRlong     sts;
   IGRpoint    curpt, projpt;
   IGRdouble   line[2][3];

   sts = OM_S_SUCCESS;

   OM_BLOCK_MOVE( dynargs->disbuf[0].geometry.polyline->points, line[0],
                  sizeof(IGRpoint) );
   for(i=0; i<3; i++)
      line[1][i] = line[0][i] + dynargs->vec_nor_prfpln[i];

   curpt[0] = cursor_pt->x;
   curpt[1] = cursor_pt->y;
   curpt[2] = cursor_pt->z;
  
   (void)BSproj0(&rc, curpt, line, projpt);
   if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
  
   dynargs->disbuf[0].geometry.polyline->points[3] = projpt[0];
   dynargs->disbuf[0].geometry.polyline->points[4] = projpt[1];
   dynargs->disbuf[0].geometry.polyline->points[5] = projpt[2];
   *buffer = dynargs->disbuf;
   *num_buffers = 1;

ret_end:
   return(TRUE);
}

#argsused
static IGRint EFpivotline(dynargs,
              cursor_pt,
              matrix,
              objects,
              num_objects,
              buffer,
              num_buffers,
              in_dummy1,
              in_dummy2,
              in_dummy3,
              out_dummy1,
              out_dummy2,
              out_dummy3)
struct dynfunc_args *dynargs;
struct DPele_header **buffer;
struct GRid **objects;
struct EX_button *cursor_pt;
IGRint *num_objects, *num_buffers;
IGRdouble *matrix;
IGRchar **in_dummy1, **in_dummy2, **in_dummy3;
IGRchar **out_dummy1, **out_dummy2, **out_dummy3;
{
   BSrc       rc;
   IGRint     i; 
   IGRpoint   curpt;
   IGRdouble  dist;

   curpt[0] = cursor_pt->x;
   curpt[1] = cursor_pt->y;
   curpt[2] = cursor_pt->z;

   dynargs->disbuf[0].geometry.polyline->points[3] = curpt[0];
   dynargs->disbuf[0].geometry.polyline->points[4] = curpt[1];
   dynargs->disbuf[0].geometry.polyline->points[5] = curpt[2];

   /*
    * If the symmetric option is selected, we need to draw two arrows pointing
    * in opposite direction. In which case number of buffers will be two cont-
    * aining two poly lines.
    */
   if( dynargs->tmp_bool ) /* If Symmetric Option is Selected */
   {
      /*
       * Then make a vector from the pivot point to the cursor point and 
       * populate the second buffers second point by just moving in the 
       * opposite to the direction of the vector calculated.
       */ 
      BSmkvec( &rc, dynargs->curr_vec, 
               &(dynargs->disbuf[0].geometry.polyline->points[0]), curpt );
      BSnorvec( &rc, dynargs->curr_vec );

      dist = BSdistptpt( &rc, 
                         &(dynargs->disbuf[0].geometry.polyline->points[0]),
                         curpt );

      for(i=0; i<3; i++)
        dynargs->disbuf[1].geometry.polyline->points[i+3] = 
                           dynargs->disbuf[1].geometry.polyline->points[i] - 
                           dist *dynargs->curr_vec[i];
      *num_buffers = 2;
   }
   else
   {   
      *num_buffers = 1;
   }

   *buffer = dynargs->disbuf;
 
   return(TRUE);
}

#argsused
static IGRint EFarrlinedyn(dynargs,
                       cursor_pt,
                       matrix,
                       objects,
                       num_objects,
                       buffer,
                       num_buffers,
                       in_dummy1,
                       in_dummy2,
                       in_dummy3,
                       out_dummy1,
                       out_dummy2,
                       out_dummy3)
struct dynfunc_args *dynargs;
struct DPele_header **buffer;
struct GRid **objects;
struct EX_button *cursor_pt;
IGRint *num_objects, *num_buffers;
IGRdouble *matrix;
IGRchar **in_dummy1, **in_dummy2, **in_dummy3;
IGRchar **out_dummy1, **out_dummy2, **out_dummy3;
{
   BSrc          rc;
   IGRint        i;
   IGRlong       sts, msg_loc;
   IGRpoint      curpt, projpt, arrow_points[2][3];
   IGRdouble     line[2][3], junk_value, junk_arrow_vec[2][3];
   extern void   EMgetarrowheads();
  
   sts = OM_S_SUCCESS;
 
   /*
    * consider the pivot the point as the starting point of the arrow
    */ 
   line[0][0] = dynargs->the_point[0];
   line[0][1] = dynargs->the_point[1];
   line[0][2] = dynargs->the_point[2];
  
   if(dynargs->tmp_bool)
   {
     for(i=0; i<3; i++)
       line[1][i] = line[0][i] + dynargs->vec_along_prfpln[i];
   }
   else
   {
     for(i=0; i<3; i++)
       line[1][i] = line[0][i] + dynargs->vec_nor_prfpln[i];
   }

   /*
    * 15 times the window tol is taken as the size of the arrow
    */
   junk_value = 15 * dynargs->win_tol;
 
   /*
    * get the cursor point and project the cursor point on the infinite line
    * along the projection direction and get the projected point. Make a ve-
    * ctor out of the pivot point and the projected point and draw an arrow 
    * with junk_length as the length along this direction.
    */ 
   curpt[0] = cursor_pt->x;
   curpt[1] = cursor_pt->y;
   curpt[2] = cursor_pt->z;
  
   (void)BSproj0(&rc, curpt, line, projpt);
   if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
   
   sts = BSmkvec(&rc, dynargs->curr_vec, dynargs->the_point, projpt);
   BSnorvec(&rc, dynargs->curr_vec);
  
   OM_BLOCK_MOVE( dynargs->the_point, junk_arrow_vec[0], 3*sizeof(IGRdouble) );
   for(i=0; i<3; i++)
      junk_arrow_vec[1][i] = junk_arrow_vec[0][i] + 
                                 junk_value * dynargs->curr_vec[i];

   /*
    * get the arrow heads (>) and build the buffer.
    */
   junk_value = 1.0;
   EMgetarrowheads(&msg_loc, junk_arrow_vec, arrow_points, junk_value);

   OM_BLOCK_MOVE( arrow_points[0],   
                  (dynargs->disbuf[0].geometry.polyline->points),
                  3 * sizeof(IGRpoint) );

   OM_BLOCK_MOVE( arrow_points[1],   
                  (dynargs->disbuf[1].geometry.polyline->points),
                  3 * sizeof(IGRpoint) );
   /*
    * build the buffer for the arrow of correct length
    */
   OM_BLOCK_MOVE( junk_arrow_vec,   
                  (dynargs->disbuf[2].geometry.polyline->points),
                  2 * sizeof(IGRpoint) );
  
   *buffer = dynargs->disbuf;
   *num_buffers = 3;

ret_end:
   return(TRUE);
}

#argsused
static IGRint EFsymmlinedyn(dynargs,
                       cursor_pt,
                       matrix,
                       objects,
                       num_objects,
                       buffer,
                       num_buffers,
                       in_dummy1,
                       in_dummy2,
                       in_dummy3,
                       out_dummy1,
                       out_dummy2,
                       out_dummy3)
struct dynfunc_args *dynargs;
struct DPele_header **buffer;
struct GRid **objects;
struct EX_button *cursor_pt;
IGRint *num_objects, *num_buffers;
IGRdouble *matrix;
IGRchar **in_dummy1, **in_dummy2, **in_dummy3;
IGRchar **out_dummy1, **out_dummy2, **out_dummy3;
{
   BSrc        rc;
   IGRint      i;
   IGRlong     sts;
   IGRpoint    point, curpt, projpt, neg_projpt;
   IGRdouble   line[2][3], scalar;

   sts = OM_S_SUCCESS;
   scalar = -1.0;

   OM_BLOCK_MOVE( dynargs->disbuf[0].geometry.polyline->points, 
                  point, sizeof(IGRpoint) );

   OM_BLOCK_MOVE( point, line[0], sizeof(IGRpoint) );
   for(i=0; i<3; i++)
      line[1][i] = line[0][i] + dynargs->vec_nor_prfpln[i];

   curpt[0] = cursor_pt->x;
   curpt[1] = cursor_pt->y;
   curpt[2] = cursor_pt->z;
  
   (void)BSproj0(&rc, curpt, line, projpt);
   if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

   sts = BSmkvec(&rc, dynargs->curr_vec, point, projpt);
   if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

   sts = BSmvecsclr(&rc, &scalar, dynargs->curr_vec);
   if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

   for(i=0; i<3; i++)
      neg_projpt[i] = point[i] + dynargs->curr_vec[i];
  
   dynargs->disbuf[0].geometry.polyline->points[3] = projpt[0];
   dynargs->disbuf[0].geometry.polyline->points[4] = projpt[1];
   dynargs->disbuf[0].geometry.polyline->points[5] = projpt[2];
  
   dynargs->disbuf[1].geometry.polyline->points[3] = neg_projpt[0];
   dynargs->disbuf[1].geometry.polyline->points[4] = neg_projpt[1];
   dynargs->disbuf[1].geometry.polyline->points[5] = neg_projpt[2];
  
   *buffer = dynargs->disbuf;
   *num_buffers = 2;

ret_end:
   return(TRUE);
}

#argsused
static IGRint EFsymmarcdyn(dynargs,
                       cursor_pt,
                       matrix,
                       objects,
                       num_objects,
                       buffer,
                       num_buffers,
                       in_dummy1,
                       in_dummy2,
                       in_dummy3,
                       out_dummy1,
                       out_dummy2,
                       out_dummy3)
struct dynfunc_args *dynargs;
struct DPele_header **buffer;
struct GRid **objects;
struct EX_button *cursor_pt;
IGRint *num_objects, *num_buffers;
IGRdouble *matrix;
IGRchar **in_dummy1, **in_dummy2, **in_dummy3;
IGRchar **out_dummy1, **out_dummy2, **out_dummy3;
{
   BSrc        rc;
   IGRint      type, i;
   IGRlong     sts;
   IGRpoint    tmp_pnt, junk_pt, curpt, tmp_vec;
   IGRdouble   u, dist;
   IGRvector   unit_vec;


   sts = OM_S_SUCCESS;
  
   curpt[0] = cursor_pt->x;
   curpt[1] = cursor_pt->y;
   curpt[2] = cursor_pt->z;

   /*
    * Find the minimum distance point from the cursor point to the circle.
    */
   (void)BSmdstptcv(&dynargs->curvebuff[0], curpt, &u, tmp_pnt, &dist, &rc);
   if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
  
   /*
    * if dynargs->tmp_bool is TRUE  : Symmetric Sweep 
    *                      is FALSE : One sided Sweep
    * In case of symmetric sweep, we will draw two arcs from the starting point 
    * of the incoming circle.
    */ 
   if( dynargs->tmp_bool && u > 0.5 )
   {
      for(i=0; i<3; i++)
         tmp_vec[i] = -dynargs->tmp_vec[i];
   }
   else
   {
      OM_BLOCK_MOVE( dynargs->tmp_vec, tmp_vec, sizeof(IGRvector) ); 
   }

   /*
    * Creating the circular arc
    */
   sts = BSprepcarc( &rc, dynargs->the_point, dynargs->center, tmp_pnt,
                     tmp_vec, &dynargs->curvebuff[1], unit_vec, &type);
   if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
  
   if(dynargs->tmp_bool)
   {
      u = 1.0 - u;
      (void)BScveval( &dynargs->curvebuff[0], u, 0, &junk_pt, &rc );
      if(rc != BSSUCC){sts = EMS_E_BSerror; goto ret_end;}

      for(i=0; i<3; i++)
         tmp_vec[i] = - tmp_vec[i];

      sts = BSprepcarc( &rc, dynargs->the_point, dynargs->center, junk_pt,
                        tmp_vec, &dynargs->curvebuff[2], unit_vec, 
                        &type );
      if(rc != BSSUCC){sts = EMS_E_BSerror; goto ret_end;}
   }
  
   *buffer = dynargs->disbuf;
   if(dynargs->tmp_bool)
      *num_buffers = 2;
   else
      *num_buffers = 1;

ret_end:
   return(TRUE);
}

method ECridge_perform_dynamics(IGRlong *msg; struct dynfunc_args *dynargs )
{
   BSrc                    rc;
   IGRlong                 sts, msg_loc, num_bytes;
   IGRpoint                point1;
   IGRshort                mat_type;
   IGRvector               vec1, tmp_vec;
   IGRdouble               poles[4][3], u_knots[4], v_knots[4];
   IGRdouble               uval, a=1.0, b=1.0,  *mat;
   IGRboolean              oncurve, flag;
   struct GRid             prof_id;
   struct IGRplane         other_plane;
   struct IGRbsp_curve     *geom=NULL;
   struct IGRbsp_surface   plane;
   
   sts = OM_S_SUCCESS;
   msg_loc = EMS_S_Success;
  
   other_plane.point   = point1;
   other_plane.normal  = vec1;
 
   plane.poles   = (IGRdouble *)poles;
   plane.weights = NULL;
   plane.u_knots = (IGRdouble *)u_knots;
   plane.v_knots = (IGRdouble *)v_knots;
  

   OM_BLOCK_MOVE( me->vec_nor_prfpln, dynargs->vec_nor_prfpln,
                  sizeof(IGRvector) );

   OM_BLOCK_MOVE( me->pivot_pnt, dynargs->the_point, sizeof(IGRpoint));

   if( dynargs->tmp_bool ) /* if dynamics required in the plane of the profile
                              we need to calculate the vector in the plane of
                              the profile */ 
   {
      prof_id   = me->loc_events[LOCATE_PROFILE].located_object[0].located_obj;
      mat_type  = me->loc_events[LOCATE_PROFILE].located_object[0].
                  module_info.md_env.matrix_type;
      mat       = me->loc_events[LOCATE_PROFILE].located_object[0].
                  module_info.md_env.matrix;
      /*
       * Getting the size and geometry of the curve.
       */
      sts = om$send( msg = message GRvg.GRgetsize( &msg_loc, &mat_type, mat,
                                   &num_bytes),
                     targetid = prof_id.objid,
                     targetos = prof_id.osnum);
      ERROR(sts, msg_loc, "ECridge_perform_dynamics.GRvg.GRgetsize error")

      geom = (struct IGRbsp_curve *) alloca ( num_bytes );
      if( !geom )
      {
         printf("ECridge_perform_dynamics: Insufficient Memory \n");
         sts = OM_E_ABORT;
         goto  ret_end;
      }

      sts = om$send( msg = message GRvg.GRgetgeom( &msg_loc, &mat_type, mat,
                                   (IGRchar *)geom ),
                     targetid = prof_id.objid,
                     targetos = prof_id.osnum);
      ERROR(sts, msg_loc, "ECridge_perform_dynamics.GRvg.GRgetgeom error")

      sts = BSprptoncv(&rc, geom, me->pivot_pnt, &uval, &oncurve);
      if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

#ifdef DEBUG
      printf("geom->order : %d\n", geom->order );
#endif

      if(geom->order > 2)
      {
         BSpl_tan_tc(geom, uval, a, b, &plane, &rc);
         if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

         BSsfnormal(&plane, tmp_vec, &rc);
         if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}
         BSnorvec(&rc, tmp_vec);

         me->vec_along_prfpln[0] = tmp_vec[0];
         me->vec_along_prfpln[1] = tmp_vec[1];
         me->vec_along_prfpln[2] = tmp_vec[2];
      }
      else
      {
         flag = FALSE;
         BSpl_nor_tc( &rc, geom, &uval, &flag, NULL, other_plane.point,
                      other_plane.normal, NULL);
         if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

         flag = BScrossp( &rc, me->vec_nor_prfpln, (other_plane.normal),
                          tmp_vec );
         if(rc != BSSUCC){ sts = EMS_E_BSerror; goto ret_end;}

#ifdef DEBUG
         printf(" %x %x\n", me->vec_nor_prfpln, me->vec_along_prfpln );
#endif

         BSnorvec(&rc, tmp_vec);
         OM_BLOCK_MOVE( tmp_vec, me->vec_along_prfpln, sizeof(IGRvector) );
      }

      OM_BLOCK_MOVE( me->vec_along_prfpln, dynargs->vec_along_prfpln,
                     sizeof(IGRvector));
   }

   dynargs->display_stuff = &ME.COconst->ActiveDisplay;

   /*
    * get the display unit tolerance i.e. minimum distance between two 
    * distinguishable points in the window. This is used to  calculate 
    * the size of the arrow to be drawn on the screen. 
    */
   me->window.objid = me->locate_event.event.button.objid;
   me->window.osnum = me->locate_event.event.button.osnum;
   ECget_window_dittol( &me->window, &dynargs->win_tol );
 
   /*
    * Fill up the display buffers 
    */ 
   dp$build_dis_buffer( buffer       = &(dynargs->disbuf[0]),
                        type         = IGRPY,
                        display_att  = dynargs->display_stuff,
                        geometry     = &(dynargs->arrow_head[0]) );

   dp$build_dis_buffer( buffer       = &(dynargs->disbuf[1]),
                        type         = IGRPY,
                        display_att  = dynargs->display_stuff,
                        geometry     = &(dynargs->arrow_head[1]) );

   dp$build_dis_buffer( buffer       = &(dynargs->disbuf[2]),
                        type         = IGRPY,
                        display_att  = dynargs->display_stuff,
                        geometry     = &(dynargs->arrow_vector) );

   /*
    * Call the dynamics function
    */ 
   dp$dynamics(dyn_fun = EFarrlinedyn, information = dynargs);
  
ret_end:
   return(sts);
}

IGRlong EMget_profile_refpln_id(msg,
                                profile,
                                refplnid,
                                success)
IGRlong *msg;
struct GRid *profile;
struct GRid *refplnid;
IGRboolean *success;
{  
   IGRint            count, i;
   IGRlong           sts, msg_loc;
   OMuword           classid;
   struct GRid       owner, *paramids=NULL;
   OM_S_CHANSELECT   to_owners;

   sts       = OM_S_SUCCESS;
   *msg      = EMS_S_Success;
   *success  = FALSE;
  
   EMmake_chanselect(GRconnector_to_owners, &to_owners);

   // get the owner id.

   owner.objid = NULL_OBJID;
   sts = om$get_objid_at_index( objid         = profile->objid,
                                osnum         = profile->osnum,
                                index         = 0,
                                p_chanselect  = &to_owners,
                                objidaddr     = &owner.objid,
                                osnumaddr     = &owner.osnum);

   if(!IF_NULL_OBJID(owner.objid))
   {
      /*
       * get all the parents of the of the owner found in the last step.
       */
      sts = om$send( msg = message EMSassoc.EMpack_paraminfo(&msg_loc,
                                   NULL, NULL, NULL, NULL, NULL, &count,
                                   &paramids, NULL, NULL, NULL, 
                                   OM_e_wrt_object ),
                     senderid = NULL_OBJID,
                     targetid = owner.objid,
                     targetos = owner.osnum);
      if(!(1&sts&msg_loc)) goto ret_end;

      for(i=0; i<count; i++)
      {
         sts = om$get_classid( objid      = paramids[i].objid,
                               osnum      = paramids[i].osnum,
                               p_classid  = &classid);
         if(!(1&sts)) goto ret_end;

         if(om$is_ancestry_valid( subclassid    = classid,
                                  superclassid  = OPP_EMSdatpln_class_id) 
                                  == OM_S_SUCCESS )
         {
            refplnid->objid = paramids[i].objid;
            refplnid->osnum = paramids[i].osnum; 
            *success = TRUE;
            break;
         }
      }
   }

ret_end:
   return(sts);
}

#argsused
static IGRint EFarcdyn(dynargs,
                       cursor_pt,
                       matrix,
                       objects,
                       num_objects,
                       buffer,
                       num_buffers,
                       in_dummy1,
                       in_dummy2,
                       in_dummy3,
                       out_dummy1,
                       out_dummy2,
                       out_dummy3)
struct dynfunc_args *dynargs;
struct DPele_header **buffer;
struct GRid **objects;
struct EX_button *cursor_pt;
IGRint *num_objects, *num_buffers;
IGRdouble *matrix;
IGRchar **in_dummy1, **in_dummy2, **in_dummy3;
IGRchar **out_dummy1, **out_dummy2, **out_dummy3;
{
   BSrc       rc;
   IGRint     i;
   IGRlong    sts;
   IGRpoint   pt, mpt;
   IGRdouble  par, dist;
   struct IGRbsp_curve  *arc;

   sts = OM_S_SUCCESS;

   pt[0] = cursor_pt->x;
   pt[1] = cursor_pt->y;
   pt[2] = cursor_pt->z;

   BSmdstptcv( &dynargs->curvebuff[0], pt, &par, mpt, &dist, &rc );  
   if(rc != BSSUCC) 
   { 
     sts = EMS_E_BSerror; 
     goto ret_end; 
   }

   arc = &(dynargs->curvebuff[1]);

   arc->num_poles = (IGRlong) 3;
   arc->order = (IGRshort) 3;
   arc->rational = TRUE;
   arc->periodic = FALSE;
   arc->num_knots = (IGRlong) 6;
   arc->non_uniform = FALSE;
   arc->num_boundaries = (IGRshort) 0;
   arc->bdrys = NULL;
   arc->planar = dynargs->curvebuff[0].planar;
   arc->phy_closed = FALSE;
   for(i=0; i<3; i++)
     arc->knots[i] = 0.0;
   for(i=3; i<6; i++)
     arc->knots[i] = 1.0;
   arc->weights[0] = 1.0;
   arc->weights[1] = 0.5;
   arc->weights[2] = 1.0;
   
   if( par < 0.5 )
   {
      /* 
       * create a circular arc of 120 deg. in the same direction as the circle.
       */
      OM_BLOCK_MOVE( dynargs->curvebuff[0].poles, arc->poles, 
                     3 * sizeof(IGRpoint) ); 
   }
   else
   {
      /*
       * create a circular arc of 120deg in the reverse direction of the circle
       */
      OM_BLOCK_MOVE( &(dynargs->curvebuff[0].poles[4*3]), arc->poles,
                     3 * sizeof(IGRpoint) );
   }

   *buffer = dynargs->disbuf;
   *num_buffers = 1;

ret_end:
   return(sts);
}

IGRboolean GetRightNormal
(
struct IGRbsp_curve  *cv,
IGRdouble            *normal,
IGRdouble            *right_normal
)
{
  BSrc       rc;
  IGRint     i=0,j=0;
  IGRvector  vec1, vec2;
  IGRpoint   origin, pt1, pt2;
  IGRdouble  lentol;
  IGRboolean found=FALSE;
 
  BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
 
  for (i=0; i<cv->num_poles-2; i++)
  {
    OM_BLOCK_MOVE (&cv->poles[(i+1)*3], origin, sizeof(IGRpoint));
    OM_BLOCK_MOVE (&cv->poles[i*3], pt1, sizeof(IGRpoint));
    OM_BLOCK_MOVE (&cv->poles[(i+2)*3], pt2, sizeof(IGRpoint));
 
    if (cv->rational)
    {
      for (j=0; j<3; j++)
      {
        origin[j] /= cv->weights[i+1];
        pt1[j] /= cv->weights[i];
        pt2[j] /= cv->weights[i+2];
      }
    }
 
    BSmkvec (&rc, vec1, origin, pt1);
    BSmkvec (&rc, vec2, origin, pt2);
 
    BSnorvec (&rc, vec1);
    BSnorvec (&rc, vec2);
 
    BScrossp (&rc, vec1, vec2, right_normal);
    BSnorvec (&rc, right_normal);
 
    if (fabs(fabs(BSdotp (&rc, normal, right_normal)) - 1.0) < lentol)
    {
      found = TRUE;
      break;
    }
 
  }
 
  if (cv->num_poles == 2)
  {
    OM_BLOCK_MOVE (&cv->poles[3], origin, sizeof(IGRpoint));
    OM_BLOCK_MOVE (&cv->poles[0], pt1, sizeof(IGRpoint));
 
    if (cv->rational)
    {
      for (j=0; j<3; j++)
      {
        origin[j] /= cv->weights[1];
        pt1[j] /= cv->weights[0];
      }
    }
 
    BSmkvec (&rc, vec1, origin, pt1);
    BSnorvec (&rc, vec1);
 
    BSorthovec (&rc, vec1, vec2);
 
    if (fabs (fabs(BSdotp(&rc, normal, vec2)) - 1.0) < lentol)
    {
      found = TRUE;
      OM_BLOCK_MOVE (vec2, right_normal, sizeof(IGRvector));
    }
    else
    {
      BScrossp (&rc, vec1, vec2, right_normal);
      BSnorvec (&rc, right_normal);
 
      if (fabs (fabs(BSdotp(&rc, normal, right_normal)) - 1.0) < lentol)
      {
        found = TRUE;
      }
    }
  }
 
  if (!found)
    OM_BLOCK_MOVE (normal, right_normal, sizeof(IGRvector));

  return found; 
}

IGRboolean AddRmGetNormalOfPlaneOfPts
(
IGRint     numpts,
IGRdouble  *p_pts,
IGRdouble  *p_wts,
IGRdouble  *normal
) 
{
  BSrc       rc=BSSUCC;
  IGRint     i=0,j=0, n_normal1=0, n_normal2=0;
  IGRvector  vec1, vec2, normal1, normal2, vec;
  IGRpoint   origin, pt1, pt2;
  IGRdouble  lentol=0, sqlentol=0;

  if (numpts < 3)
    return FALSE;

  BSEXTRACTPAR (&rc, BSTOLLENVEC, lentol);
  sqlentol = lentol * lentol;
 
  for (i=0; i<numpts-2; i++)
  {
    OM_BLOCK_MOVE (&p_pts[(i+1)*3], origin, sizeof(IGRpoint));
    OM_BLOCK_MOVE (&p_pts[i*3], pt1, sizeof(IGRpoint));
    OM_BLOCK_MOVE (&p_pts[(i+2)*3], pt2, sizeof(IGRpoint));
 
    if (p_wts)
    {
      for (j=0; j<3; j++)
      {
        origin[j] /= p_wts[i+1];
        pt1[j] /= p_wts[i];
        pt2[j] /= p_wts[i+2];
      }
    }
 
    if (BSdistptpts (&rc, origin, pt1) < sqlentol || 
        BSdistptpts (&rc, origin, pt2) < sqlentol)
      continue;

    BSmkvec (&rc, vec1, origin, pt1);
    BSmkvec (&rc, vec2, origin, pt2);
 
    BSnorvec (&rc, vec1);
    BSnorvec (&rc, vec2);
 
    BScrossp (&rc, vec1, vec2, vec);
    BSnorvec (&rc, vec);

    if (BSlenvec (&rc, vec) < MINDOUBLE)
      continue;

    if (!n_normal1)
    {
      n_normal1 = 1;
      OM_BLOCK_MOVE (vec, normal1, sizeof (IGRvector));
    }
    else
    {
      if (BSdotp (&rc, vec, normal1) > 0.0)
        n_normal1 ++;
      else 
      {
        if (!n_normal2)
        {
          n_normal2 = 1;
          OM_BLOCK_MOVE (vec, normal2, sizeof (IGRvector));
        }
        else
          n_normal2 ++;
      }
    }

    if (n_normal1 && n_normal2)
      break;
  }

  if (n_normal1 && n_normal2)
  {
    if ((normal1[0] - normal2[0]) > lentol || 
        (normal1[1] - normal2[1]) > lentol || 
        (normal1[2] - normal2[2]) > lentol)
      OM_BLOCK_MOVE (normal1, normal, sizeof (IGRvector));
    else
      OM_BLOCK_MOVE (normal2, normal, sizeof (IGRvector));
      
  }
  else if (n_normal1)
    OM_BLOCK_MOVE (normal1, normal, sizeof (IGRvector));
  else
    return FALSE;

  return TRUE;
}


end implementation ECridge;



