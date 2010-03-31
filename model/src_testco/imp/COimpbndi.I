/* ###################   APOGEE COMPILED   ################## */
/*
 This command was originally written by Richard Watson and was
 later taken over by Sunit Managalvedhekar.

 rc  : 07/02/87 : Modified such that more than 20 curves can be located 
                  in imposing boundaries.
 rlw : 04/27/88 : Put in message subsystem, made performance and code space
                  improvements.
 SM  : 06-May-88: Added argument 'imp_options' in the message send 
                  EMimpose_boundaries. This is required for the 'auto_nest'
                  capability. No point in area given means the user intends
                  auto nesting.
 rlw : 02/01/89 : Graphic group points showing problem areas.
 SM  : 06-Feb-89: Took out the check for booleans being in the tree and
                  allow boundary imposition on a surface of a solid.
                  Also, fixed a bug in sleep override -
                  The 'response' pointer was not initialized to good memory
                  location and the ERROR macro accesses it. So if there is
                  any error in sleep it will access forbidden memory and
                  thus fault. Fixed it by initializing response to local
                  memory in sleep override.
 SM  : 28-Feb-89: Added NULL for curve buffs in EMSsurface.EMimpose_boundaries
                  (new argument).
 SM  : 21-Mar-89: In all the GRdisplay sends, changed the display_info argument
                  to '&me->ModuleInfo->md_id'. I did this because the curves
                  located can be in a reference file and the md_id from that
                  element's locate info is not the active one. For consistency
                  and safety all the message sends were changed thusly.
22 May 1989 jBk Changed from use of GRgetevent to co$getevent.

                Changed comments from referring to GRlclocate to
                refer to lc$locate.
12 Jun 1989 jBk Moved UI_message from wakeup to execute;

                enhanced wakeup to send to self wrt parent.

23 Nov 1989 SM  Supported operations of placing features and splitting
		areas by adding 2 mytypes. These used to be seperate
		commands.
 mrm    06/03/91  Use associative function
        06/18/91  Change interface to use an arrow for area/hole
 scw    08/08/91  Converted to use gr$dpb associative flag
 DLB    12/20/91  Fix problems in area side algorithm.
 DLB    01/21/91  Always go thru assoc
 Tapadia 5/25/92  Modified for message sub-system compliance
 Jack   10/16/92  For mytype==PlcFea, set ASbroadcast_in_progress = TRUE
                  just before the call to EMimpose_boundaries and reset
                  it when it returns.  This is to allow a surface feature
                  to be placed on a surface that has a surface impose
                  boundary state on it when associativity is turned off.
                  
 Sudha  07/05/93  Modified for BSprototypes ansification
 scw    08/14/94  clarified sleep method

*/

class implementation COimpbnd;

#include "EMS.h"
#if DEBUG
#include <stdio.h>
#endif
# ifndef griodef_include
# include "griodef.h"
# endif
# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif
# ifndef igrdp_include
# include "igrdp.h"
# endif
# ifndef dpstruct_include
# include "dpstruct.h"
# endif
#include "igrdef.h"                     /* Has IGRPY */
# ifndef griodef_include
# include "griodef.h"
# endif

#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "local_dsp.h"  /* Local display macro */
#include "exmacros.h"   /* Has ex$putque */
#include "dpmacros.h"   /* Has dp$erase_hilite */
#include "msmacros.h"   /* Has message subsystem macros */
#include "maerr.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "OMmacros.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "lcmacros.h"
#include "EMSmsgdef.h"
#include "griomacros.h"    /* co$getevent */
#include "EMSdpb.h"
#include "EMSasopts.h"
#include "emsdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSaction.h"
#include "emsdef.h"
#include "emsmacros.h"
#include "EMSifmacros.h"
#include "EMSascmacros.h"
#include "maunitvc.h"
#include "mascalvc.h"
#include "macrossvc.h"
#include "mabrlncon.h"
#include "bsptnorsf.h"

#define TRUE  1
#define FALSE 0
#define NO_POINT -1

#define INCREMENT     10

/* command states */
#define BEGIN_STATE             0
#define LOCATE_SURFACE          1
#define INDICATE_SIDE   2
#define LOCATE_BOUNDARIES       3
#define IMPOSE_BOUNDARIES       4
#define UNHILITE_BOUNDARIES     5

/* mytypes */
#define	ImpBnd	0
#define PlcFea	1
#define SplitArea 2

extern OMuword OPP_GRcompcurve_class_id;

#if DEBUG
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    fprintf(stderr, "\n*************************");\
    fprintf(stderr, "\nIn COimpbnd error condition encountered");\
    *response = TERMINATE;\
    fprintf(stderr, "\n%s", error_message);\
    fprintf(stderr, "\nError number %d", error_number);\
    om$report_error(sts = sts_stupid);\
    fprintf(stderr, "\n*************************");\
    return(OM_E_ABORT);\
   }\
 }
#else
#define ERROR(sts_stupid, error_number, error_message)\
 {\
  if(!(sts_stupid & 1))\
   {\
    *response = TERMINATE;\
    ex$message(msgnumb = EMS_F_0002)\
    return(OM_E_ABORT);\
   }\
 }
#endif

from GRgraphics import GRdisplay, GRlnproject, GRgetrang,
		       GRptproject, GRdelete;
from GRcurve import    EMcvtanorm;
from EMSsurface import EMimpose_boundaries, EMgetactiveid, EMisClassInTree;
from EMSsubbs import   EMmk_nat_bdry, EMsftanorm;
from GRvg import       GRgetsize, GRgetgeom;
from EMSloopset import EMpt_location;

/*extern IGRlong EFbuild_graphic_group();*/
extern IGRint EMdpb_getinfo();
extern IGRint DPdrawcross();
extern OM_S_OBJID current_creator;

extern OMuword OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id;
extern OMuword OPP_GRbspline_class_id, OPP_GRcurve_class_id;
extern OMuword OPP_EMSsfboolean_class_id; 

static void DLB_ptnorsf(msg, sfid, sfos, sfenv, pt, projpt, projparm)
IGRlong *msg;
GRobjid sfid;
OMuword sfos;
struct GRmd_env *sfenv;
IGRpoint pt, projpt;
struct GRparms *projparm;
{ /*DLB ADDITION*/
  struct IGRbsp_surface *surf_geom;
  IGRlong               surf_size, sts;

  sts = om$send(msg = message GRvg.GRgetsize(msg,         
                      &sfenv->md_env.matrix_type,
                      sfenv->md_env.matrix,
                      &surf_size),
		senderid = sfid,
                targetid = sfid,
                targetos = sfos);
  if (!(1 & sts & *msg)) goto wrapup;
               
  surf_geom = (struct IGRbsp_surface *) alloca(surf_size);
  
  sts = om$send(msg = message GRvg.GRgetgeom(msg,
                      &sfenv->md_env.matrix_type,
                      sfenv->md_env.matrix,
                      (char *)surf_geom),
		senderid = sfid,
                targetid = sfid,
                targetos = sfos);
  if (!(1 & sts & *msg)) goto wrapup;

  { /*INTENTIONAL*/
    IGRdouble dist;
    IGRint    num_pt;

    (void) BSptnorsf(surf_geom, pt, &num_pt, 
                     &projparm->u, &projparm->v,
                     projpt,
                     &dist, msg);
    if (BSERROR(*msg))
    {
      *msg = EMS_E_BSerror;
    }
  }        

  wrapup:
   return;
}

method wakeup(int pos)
{
    IGRlong        i, msg, sts;
    enum           GRdpmode DisplayMode;
    struct         GRlc_info *info;

    sts = om$send (mode = OM_e_wrt_parent,
                   msg = message COimpbnd.wakeup (pos),
                   targetid = my_id);
    if (!(1 & sts)) return(OM_E_ABORT);

    DisplayMode = GRhd;
    for (i = 1; i <= ME.COimpbnd->numcrv; i++)
    {
        info = &ME.COimpbnd->locobj[i];
        sts = om$send(msg = message GRgraphics.GRdisplay
                           (&msg,
                            &info->module_info.md_env.matrix_type,
                            info->module_info.md_env.matrix, 
                            &DisplayMode, &me->ModuleInfo.md_id),
                      targetid = info->located_obj.objid,
                      targetos = info->located_obj.osnum);
        if (!(1 & sts)) return(OM_E_ABORT);
    }

    /* Get the dpb variables */

    sts = EMdpb_getinfo (&msg, &me->dpb_info);
    gr$get_associative_flag( buffer = &me->associative_flag ); 

    if (me->associative_flag)
        GRdisplay_associative_button(TRUE);

    return(OM_S_SUCCESS);
}

method super_cmd.sleep(int pos)
{
    IGRlong        msg, sts, *response;
    IGRlong        junk;

    response = (IGRlong *) &junk;
    sts = dp$erase_hilite(msg = &msg);
    ERROR(sts, msg, "dp$erase_hilite error")

    if (me->associative_flag)
        GRdisplay_associative_button(FALSE);

    return(OM_S_SUCCESS);
}

method execute(int *response; char *response_data; int pos)
{
 enum           GRdpmode DisplayMode;
 IGRchar        locate_prompt[80];
 IGRboolean     world;
 IGRushort      map_options, imp_options;
 IGRint         size, object_was_located, display_flag, sts;
 IGRlong        putque_size, msg;
 IGRint         locate_mask, accept_mask, i, j;
 OMuint         count;
 IGRlong        number_of_points, number_of_bad_curves, bad_curve_indices[50];
 IGRdouble      point1[3], point2[3], chtol;
 IGRdouble      *area_pt;
 IGRdouble      origin[3], normal[3], tangent[3], vector[3], range[6], poly[6];
 IGRpoint       projpt, *points;
 struct GRparms projparms;
 struct IGRline bore_line;
 struct GRevent event, accept_event;
 struct GRlc_locate attributes;
 struct GRid    surf, *firstcurve,targetgrid;
 struct IGRdisplay display;
 struct GRlc_info *obj;
 OM_S_CHANSELECT to_loopset, to_components;
 IGRboolean save_broadcast_flag;
 extern IGRboolean ASbroadcast_in_progress;
 OM_S_CHANSELECT                  to_owners;

/*
 * Initialize
 */
 sts = OM_S_SUCCESS;
 size = sizeof(event);
 bore_line.point1 = &point1[0];
 bore_line.point2 = &point2[0];
 EMmake_chanselect(GRconnector_to_owners, &to_owners);

 if(ME.super_cmd->mytype == ImpBnd)
  ex$message(msgnumb = EM_M_0098)
 else if(ME.super_cmd->mytype == PlcFea)
  ex$message(msgnumb = EM_M_PlaceSfFea)
 else
  ex$message(msgnumb = EM_M_SplitSurfArea)

/*
 * Enter infinite loop
 */
 do
  {
   switch(ME.super_cmd->state)
    {
/*
 * Room for growth
 */
     case BEGIN_STATE:
      ME.super_cmd->state = LOCATE_SURFACE;
/*
 * Get the surface
 */
     case LOCATE_SURFACE:
      me->reverse = FALSE;
      locate_mask = GRm_DATA | GRm_BACK_UP;
      accept_mask = GRm_DATA;
      {
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_ALL;                   /* Erase the hilite plane */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_WRITE_ONLY;                  /* I'm going to change this guy */
/*     strcpy(attributes.classes, "EMSsubbs"); */
       attributes.owner_action = 
        LC_LOCALMOD    | 
        LC_FLEX_COMP   | 
        LC_RIGID_COMP  |                /* We want the surface itself */
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_EMSsubbs_class_id;
       e_classes[0] = OPP_EMSsubbs_class_id;
        lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_key =           EMS_P_00031,
         acc_key =              ME.super_cmd->mytype == ImpBnd ? EMS_P_00047
							       : EMS_P_00038,
         relocate_key =         EMS_I_00011,
         attributes =           &attributes,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);
      }
      if (!object_was_located)
       {
        if (ME.COimpbnd->locate_event.response == EX_BACK_UP)
         ME.super_cmd->state = BEGIN_STATE;
        else
         return(OM_S_SUCCESS);
       }
      else
       {
        ME.COimpbnd->locobj[0] = accept_event.located_object[0];

	/*
 	 * Put the accept event on the queue
         */
	if(ME.super_cmd->mytype == ImpBnd)
	 {
          putque_size = sizeof(accept_event.event) + sizeof (IGRint) ;
          sts = ex$putque(msg = &msg, response = response,
                          byte = &putque_size, buffer = (char *)&accept_event.event);
          ERROR(sts, msg, "ex$putque error")
         }
        ME.super_cmd->state = LOCATE_BOUNDARIES;

        sts = dp$erase_hilite(msg = &msg);
        ERROR(sts, msg, "dp$erase_hilite error")

       } /* ELSE FOR if (!object_was_located) */

      break;

    case INDICATE_SIDE:    /* allow side choice for area/hole */
    {
      IGRboolean have_cc=FALSE;
      IGRpoint proj_cv_xyz;

      /* set up display vector parameters */

      i = sizeof(struct IGRdisplay);
      gr$get_active_display(msg=&msg,sizbuf=&i,buffer = &display,nret=&i);

      OM_BLOCK_MOVE(me->locobj[1].proj_pnt, origin, sizeof(IGRdouble) * 3);

      /* get a vector tangent to the first boundary at the locate point */

      /*
       * Changed the object who is going to receive the following message to
       * be the leaf, since composite curves have rejected the same.
       */

      obj = &me->locobj[1];

      firstcurve = &ME.COimpbnd->locobj[1].located_obj;

      if (EFisAncestryValid(&msg, firstcurve->objid, firstcurve->osnum, 
                          OPP_GRcompcurve_class_id, FALSE))
      {
       have_cc = TRUE;
       targetgrid = obj->geom_parms.leaf_id;
      }
      else
       targetgrid = obj->located_obj;
    
      sts = om$send(msg = message GRcurve.EMcvtanorm
                    (&msg, &obj->module_info.md_env.matrix_type,
                     obj->module_info.md_env.matrix,
                     (struct GRvg_construct *)NULL,
                     (IGRlong)1, &obj->geom_parms,
                     &obj->geom_parms, &obj->geom_parms,
                     (IGRdouble)1.0, (IGRdouble *)NULL,
                     (IGRboolean)TRUE, (IGRboolean)FALSE, poly,
                     (OM_S_OBJID *)NULL),
                    targetid = targetgrid.objid,
                    targetos = targetgrid.osnum);
      ERROR(sts,msg,"GRcurve.EMcvtanorm");

      tangent[0] = poly[3] - poly[0];
      tangent[1] = poly[4] - poly[1];
      tangent[2] = poly[5] - poly[2];

      /* get the range of the boundary */

      world = TRUE;

      sts = om$send(msg = message GRgraphics.GRgetrang
                    (&msg, &obj->module_info.md_env.matrix_type,
                     obj->module_info.md_env.matrix, &world, range),
                    targetid = obj->located_obj.objid,
                    targetos = obj->located_obj.osnum);
      ERROR(sts,msg,"GRgraphics.GRgetrang");

#ifdef DEBUG
/*************************************************************************
      EFdraw_vector_on_screen(my_id, &display, &me->ModuleInfo, GRbd,
                              me->reverse, poly, tangent, range, &msg);
*************************************************************************/
      ems$draw_vector_on_screen(senderid = my_id,
                                display = &display,
                                display_mdenv = &me->ModuleInfo,
                                mode = GRbd,
                                reverse_vector = me->reverse,
                                point = poly,
                                vector = tangent,
                                range = range,
                                  msg = &msg);
#endif

      /* get the normal for the surface at the projection pt.  Project the
       * point on the curve to the surf along the surf normal.
       */

      (void) DLB_ptnorsf(&msg,
      		         me->locobj[0].located_obj.objid,
      		         me->locobj[0].located_obj.osnum,
      		         &me->locobj[0].module_info,
      		         origin,
      		         proj_cv_xyz,
      		         &projparms);
      ERROR(sts, msg, "DLB_ptnorsf");

      obj = &me->locobj[0];

      sts = om$send(msg = message EMSsubbs.EMsftanorm
                         (&msg, &obj->module_info.md_env.matrix_type,
                          obj->module_info.md_env.matrix,
                          (struct GRvg_construct *)NULL,
                          (IGRlong)1, &projparms.u,
                          (IGRlong)1, &projparms.v,
                          (IGRdouble)1.0, (IGRdouble *)NULL,
                          (IGRboolean)FALSE, (IGRboolean)TRUE, poly,
                          (OM_S_OBJID *)NULL),
                    targetid = obj->located_obj.objid,
                    targetos = obj->located_obj.osnum);

      ERROR(sts,msg,"EMSsubbs.EMsftanorm");

      normal[0] = poly[3] - poly[0];
      normal[1] = poly[4] - poly[1];
      normal[2] = poly[5] - poly[2];

#ifdef DEBUG
/************************************************************************
      EFdraw_vector_on_screen(my_id, &display, &me->ModuleInfo, GRbd,
                              me->reverse, poly, normal, range, &msg);
************************************************************************/
      ems$draw_vector_on_screen(senderid = my_id,
                                display = &display,
                                display_mdenv = &me->ModuleInfo,
                                         mode = GRbd,
                                     reverse_vector = me->reverse,
                                              point = poly,
                                             vector = normal,
                                              range = range,
                                                msg = &msg);    
#endif

      /* cross the boundary tangent and surface normal to get a vector */

      MAcrossvc(&msg, tangent, normal, vector);

      /* draw the vector */
/************************************************************************
      EFdraw_vector_on_screen(my_id, &display, &me->ModuleInfo, GRhd,
                              me->reverse, origin, vector, range, &msg);
************************************************************************/
      ems$draw_vector_on_screen(senderid = my_id,
                                 display = &display,
                                display_mdenv = &me->ModuleInfo,
                                         mode = GRhd,
                                     reverse_vector = me->reverse,
                                     point = origin,
                                     vector = vector,
                                      range = range,
                                        msg = &msg);

      /* ask whether direction shown is okay */

/*
      c = "Accept area side, move on to reverse, or back up to auto-nest";
*/
      sts = co$getevent(msg = &msg,
                        event_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON,
      			msgnum = EMS_P_AccArSiMoRevAuto,
                        response = response,
                        response_data = response_data,
                        event = &event);

      ex$message(msgnumb = EMS_I_00000);

      /* erase the vector */
/***************************************************************************
      EFdraw_vector_on_screen(my_id, &display, &me->ModuleInfo, GRbehe,
                              me->reverse, origin, vector, range, &msg);
***************************************************************************/
      ems$draw_vector_on_screen(
                         senderid = my_id,
                          display = &display,
                          display_mdenv = &me->ModuleInfo,
                                   mode = GRbehe,
                              reverse_vector = me->reverse,
                                       point = origin,
                                      vector = vector,
                                        range = range,
                                       msg = &msg);       

      if (event.response == GR_UNKNOWN_TYPE)
          return(OM_S_SUCCESS);
      else if (event.response == EX_BACK_UP)
      {
          /* use auto-nesting */

          me->state = IMPOSE_BOUNDARIES;
          me->reverse = FALSE;
          ME.COimpbnd->uv_in_area[0] = NO_POINT;
          ME.COimpbnd->uv_in_area[1] = NO_POINT;
          break;
      }
      else if (event.response == EX_RJT_MOVEON)
      {
          me->reverse = TRUE;
      }
      else /* (event.response == EX_DATA) */
      {
          me->reverse = FALSE;
      }

      /* move along the vector a small amount to obtain a uv point
         on the surface to define as the area */
      
      MAunitvc(&msg, vector, vector);

      /***************
      BSEXTRACTPAR(&msg, BSTOLKNOT, knottol);
      knottol *= 1000.0;
      ***************/

      /*Use cht * 2 instead - DLB*/
      BSEXTRACTPAR(&msg, BSTOLCHRDHT, chtol);
      chtol *= 2.0;
      
      MAscalvc(&msg, &chtol, vector, vector);

      if (me->reverse)
      {
          proj_cv_xyz[0] -= vector[0];
          proj_cv_xyz[1] -= vector[1];
          proj_cv_xyz[2] -= vector[2];
      }
      else
      {
          proj_cv_xyz[0] += vector[0];
          proj_cv_xyz[1] += vector[1];
          proj_cv_xyz[2] += vector[2];
      }

      obj = &me->locobj[0];
      sts = om$send(msg = message GRgraphics.GRptproject
                         (&msg, &obj->module_info.md_env.matrix_type,
                          obj->module_info.md_env.matrix, proj_cv_xyz,
                          projpt, &projparms),
                    targetid = obj->located_obj.objid,
                    targetos = obj->located_obj.osnum);

      ERROR(sts,msg,"GRgraphics.GRptproject");

#ifdef DEBUG
      display.color += 1;
      ECdisplayPointSetByBuffer(&msg, display, me->ModuleInfo, my_id,
                                1, projpt, TRUE);
#endif

      ME.COimpbnd->uv_in_area[0] = projparms.u;
      ME.COimpbnd->uv_in_area[1] = projparms.v;
      ME.super_cmd->state = IMPOSE_BOUNDARIES;

      break;
    }

/*
 * Loop around until all curves have been input
 */
     case LOCATE_BOUNDARIES:

      me->reverse = FALSE;
      locate_mask = GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON;
      accept_mask = GRm_DATA;
      if (ME.COimpbnd->numcrv)
       {
        i = ME.COimpbnd->numcrv + 1;
        ex$message(
         msgnumb = EMS_P_00128,
         type = "%d",
         var = `i`,
         buff = locate_prompt)
       }
      else
       {
        ex$message(
         msgnumb = EMS_P_00127,
         buff = locate_prompt)
       }
      {
       OMuword          r_classes[5], e_classes[5];
       OM_S_CLASSLIST   rtree_classes, eligible_classes;

       display_flag = 
        ELEM_HILIGHT            |       /* Hilite the whole element */
        NO_PROJ_ACCEPT_POINT    |       /* Don't project the accept point */
        ACC_REJ_CYCLE           |       /* Run through accept reject cycle */
        RELOCATE                |       /* Relocate if none found */
        LC_REGULAR_HIGHLIGHT    |       /* Use regular hilite not 1/2 */
        LC_ERASE_LOC_ELEMENT;           /* Don't erase hilite */
       attributes.properties = 
        LC_LC_ONLY              |       /* Locate locatable objects */
        LC_DP_ONLY              |       /* Locate displayable objects */
        IGN_MOD_BIT             |       /* Ignore modified and new props */
        LC_PLANAR_NON_PLANAR    |       /* Planarity doesn't matter */
        LC_RW;                          /* I'm only going to read */
/*     strcpy(attributes.classes, "GRcurve"); */
       attributes.owner_action = 
        LC_FLEX_COMP   |
        LC_RIGID_COMP  |
        LC_RIGID_OWNER |
        LC_REF_OBJECTS |                /* Objects in ref. files are O.K. */
        LC_NO_REF_HEADER;               /* No reference file headers */
       rtree_classes.w_count = 1;
       rtree_classes.w_flags = OM_CLST_subclass;
       rtree_classes.p_classes = &r_classes[0];
       eligible_classes.w_count = 1;
       eligible_classes.w_flags = OM_CLST_subclass;
       eligible_classes.p_classes = &e_classes[0];
       r_classes[0] = OPP_GRbspline_class_id;
       e_classes[0] = OPP_GRcurve_class_id;
       {
         extern      IGRlong EFlocate_action_handler();
         struct      EMSaction_handler already_located;
         IGRint      inx;
         IGRboolean  use_act = TRUE;

         if(me->numcrv > RLW_STACK_SIZE)
          use_act = FALSE;

         if(use_act)
          {
           already_located.next = NULL;
           already_located.option = 0;  /* Do not locate objects in the list*/
           already_located.type = 0; /* array of GRlc_info pointers */
           already_located.num_objects = me->numcrv;
           for(inx=0; inx<me->numcrv; inx++)
            already_located.objects.lc_info[inx] = &me->locobj[inx+1];
          }

        lc$locate(
         rc =                   &object_was_located,
         event1 =               &me->locate_event,
         event2 =               &accept_event,
         mask1 =                locate_mask,
         mask2 =                accept_mask,
         display_flag =         display_flag,
         unhilight_mode =       (enum GRdpmode ) GRhd,  /* Don't unhilite */
         locate_prompt =        locate_prompt,
         acc_key =              EMS_P_00045,
         relocate_key =         EMS_I_00010,
         attributes =           &attributes,
         act_handler = 		use_act ? EFlocate_action_handler : NULL,
         act_args = 		use_act ? &already_located : NULL,
         stack =                &me->locate_stack,
         rtree_classes =        &rtree_classes,
         eligible_classes =     &eligible_classes);
        }
      }
      ex$message(msgnumb = EMS_I_00000)
      if (!object_was_located)
       {
        if (ME.COimpbnd->locate_event.response == EX_BACK_UP)
         {
          if (ME.COimpbnd->numcrv)
           {
            struct      GRlc_info *info;

            info = &ME.COimpbnd->locobj[ME.COimpbnd->numcrv];
            DisplayMode = GRhe;
            sts = om$send(
             msg = message GRgraphics.GRdisplay(
              &msg,
              &info->module_info.md_env.matrix_type,
              info->module_info.md_env.matrix, 
              &DisplayMode,
              &me->ModuleInfo.md_id),
             targetid = info->located_obj.objid,
             targetos = info->located_obj.osnum);
            ME.COimpbnd->numcrv--;
           }
          else
           ME.super_cmd->state = LOCATE_SURFACE;
         }
        else if (ME.COimpbnd->locate_event.response == EX_RJT_MOVEON)
         {
          if (ME.COimpbnd->numcrv)
              ME.super_cmd->state = (ME.super_cmd->mytype == ImpBnd) ?
                  INDICATE_SIDE : IMPOSE_BOUNDARIES;
         }
        else
         return(OM_S_SUCCESS);
       }
      else      /* an object was located */
      {
         OMuint  vla_size;
         struct GRid owner;
         IGRint inx;

         /* Make sure the owner composite curve has not already been
            located.
         */
         owner.objid = NULL_OBJID;
         sts = om$get_objid_at_index(
               objid = accept_event.located_object[0].located_obj.objid, 
               osnum = accept_event.located_object[0].located_obj.osnum, 
               p_chanselect = &to_owners, index = 0, objidaddr = &owner.objid, 
               osnumaddr = &owner.osnum);
         if(!IF_NULL_OBJID(owner.objid))
          {
	   for(inx = 0; inx<me->numcrv; inx++)
	    {
	     if(IF_EQ_GRID(me->locobj[inx+1].located_obj, owner))
	      {
	       ex$message(msgnumb = EMS_I_CvAlreadyLocated);
               return(OM_S_SUCCESS);
              }
	    }
          }
         else sts = OM_S_SUCCESS;

          /*
           * Check if enough space is available to save
           * the located boundary.
           */

          vla_size = om$dimension_of (varray = ME.COimpbnd->locobj);
          if ((ME.COimpbnd->numcrv + 2)  > vla_size)
          {
              sts = om$vla_set_dimension (varray = ME.COimpbnd->locobj,
                                          size = vla_size + INCREMENT);
              ERROR (sts, 1, "vla_set_dimension");
          }
          ME.COimpbnd->numcrv++;
          ME.COimpbnd->locobj[ME.COimpbnd->numcrv] = 
              accept_event.located_object[0];
          putque_size = sizeof(accept_event.event) + sizeof (IGRint);
          sts = ex$putque(msg = &msg, response = response,
                          byte = &putque_size, buffer = (char *)&accept_event.event);
          ERROR(sts, msg, "ex$putque error");

          if (ME.COimpbnd->numcrv == 1) /* first boundary located */
          {
              /* Project the locate point onto the object.  This will be
                 used to draw the vector to indicate side later on.  It
                 is projected here since the locate point will be lost
                 by the time the vector is needed, and the accept point
                 is used to identify another boundary, so it really
                 should not be used to project onto the first boundary. */

              IGRlong which_error;
              IGRdouble mx[16], t;
              IGRpoint pt, pt1, pt2;
              struct var_list varlist[2];
              struct IGRline line;

              varlist[0].var = VIEW_ROTATION;
              varlist[0].var_ptr = (IGRchar *)mx;
              varlist[0].num_bytes = sizeof(IGRdouble)*16;
              varlist[0].bytes_returned = &which_error;
              varlist[1].var = END_PARAM;
  
              dp$inq_set_gragad(msg = &msg,
                                osnum = accept_event.event.button.osnum,
                                gragad_objid = accept_event.event.button.objid,
                                which_error = &which_error,
                                var_list = varlist);
              ERROR(1, msg, "dp$inq_set_gragad");

              pt[0] = me->locate_event.event.button.x;
              pt[1] = me->locate_event.event.button.y;
              pt[2] = me->locate_event.event.button.z;
              line.point1 = pt1;
              line.point2 = pt2;

              MAbrlnconstr(&msg, pt, mx, &line);

              obj = accept_event.located_object;
              sts = om$send(msg = message GRgraphics.GRlnproject
                                 (&msg, &obj->module_info.md_env.matrix_type,
                                  obj->module_info.md_env.matrix, &line, pt,
                                  obj->proj_pnt, &t, &obj->geom_parms), 
                            targetid = obj->located_obj.objid,
                            targetos = obj->located_obj.osnum);
              ERROR(sts, msg, "GRgraphics.GRlnproject");

              /* Save the locate event.  It will be used later to get a
                 surface normal. */

              me->first_bound_event = me->locate_event;
          }
      }
      break;
/*
 * Impose the boundaries on the surface
 */
     case IMPOSE_BOUNDARIES:

      ex$message(msgnumb = EMS_P_00000)
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " . ")
      DisplayMode = GRbe;
      {
       struct   GRlc_info *info;

       info = &ME.COimpbnd->locobj[0];
       sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
            &info->module_info.md_env.matrix_type,
            info->module_info.md_env.matrix, 
            &DisplayMode, &me->ModuleInfo.md_id),
            targetid = info->located_obj.objid,
            targetos = info->located_obj.osnum);
       ERROR(sts, msg, "GRdisplay error")
      }
      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " .. ")

      /* If the surface has no loopset, create a natural loopset on it.
         This is necessary here so that the creator_id stuff will get
         set up properly in the associative function.  It doesn't hurt
         anything to do this here even if associativity is off. */

      EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
      surf = ME.COimpbnd->locobj[0].located_obj;
      sts = om$get_channel_count(osnum = surf.osnum,
                                 objid = surf.objid,
                                 p_chanselect = &to_loopset,
                                 count = &count);
      ERROR(sts, 1, "om$get_channel_count to_loopset")
      if(!count)
      {
          current_creator = NULL_OBJID;
          sts = om$send (msg = message EMSsubbs.EMmk_nat_bdry
                              (&msg,
                               &ME.COimpbnd->locobj[0].module_info.md_env,
                               NULL),
                         targetid = surf.objid,
                         targetos = surf.osnum); 
          current_creator = NULL_OBJID;
          ERROR(sts, msg, "EMSsubbs.EMmk_nat_bdry")
      }

      current_creator = NULL_OBJID;
      if ((ME.super_cmd->mytype != PlcFea) &&
          (ME.super_cmd->mytype != SplitArea))
      {
        struct GRid result;
        struct GRvg_construct construct;

        construct.msg = &msg;
        construct.env_info = &ME.CObuild->ModuleInfo;
        construct.newflag = FALSE;
        construct.geometry = NULL;
        construct.class_attr = NULL;
        construct.level = ME.CObuild->ActiveLevel;
        construct.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        construct.display = &ME.CObuild->ActiveDisplay;
        construct.name = NULL;
        result.objid = NULL_OBJID;
        area_pt = ME.COimpbnd->uv_in_area;
        number_of_points = 0;
        points = NULL;
        number_of_bad_curves = 0;

#ifdef DEBUG
        printf("COimpbnd: uv_in_area = %g, %g\n",
               me->uv_in_area[0], me->uv_in_area[1]);
#endif
	/*
	 * Determine the index of leaf component if a composite curve was
	 * locate.
	 */
        firstcurve = &ME.COimpbnd->locobj[1].located_obj;
        if (EFisAncestryValid(&msg, firstcurve->objid, firstcurve->osnum, 
                          OPP_GRcompcurve_class_id, FALSE))
        {
           OM_S_OBJID *leafid;
           OMuint leaf_index;

           EMmake_chanselect(GRcmpowner_to_components, &to_components);

           leafid = &ME.COimpbnd->locobj[1].geom_parms.leaf_id.objid;
  
           sts = om$get_index(objid_c = firstcurve->objid,
                             osnum_c = firstcurve->osnum,
                             p_chanselect = &to_components,
                             objid = *leafid,
                             osnum2 = firstcurve->osnum,
                             indexaddr = &leaf_index);
           if (!(1&sts)) return (OM_E_ABORT);
           *leafid = leaf_index;
         }

         /* call a function to set up the boundaries associatively */
/****************************************************************************
         sts = EFimpose_boundaries(&msg, 
	       			    (me->associative_flag ? 
     			    			       NULL :
                                                       EFfunc_PLACE_NON_ASSOC),
         			    &ME.COimpbnd->locobj[0],
                                    ME.COimpbnd->numcrv,
                                    &ME.COimpbnd->locobj[1],
                                    area_pt,
                                    (area_pt[0] == NO_POINT ? FALSE : TRUE),
                                    me->reverse, chtol, 
                                    &construct, &number_of_points, &points,
                                    &number_of_bad_curves, bad_curve_indices,
                                    &result);
****************************************************************************/
          sts = ems$impose_boundaries(msg = &msg,
               options = (me->associative_flag ? NULL : EFfunc_PLACE_NON_ASSOC),
               surface = &ME.COimpbnd->locobj[0],
               num_bdrys = ME.COimpbnd->numcrv,
               bdrys = &ME.COimpbnd->locobj[1],
               point = area_pt,
               point_in_area = (area_pt[0] == NO_POINT ? FALSE : TRUE),
               reverse = me->reverse,
               dist_along_vect =  chtol, 
               construction_list = &construct,
               num_out_points = &number_of_points,
               out_points = &points,
               num_bad_crvs = &number_of_bad_curves,
               bad_crvs = bad_curve_indices,
               resultant_surface = &result);  
#ifdef DEBUG
         printf("COimpbnd: EFimpose_boundaries: %#x, %#x, result = %d, %d\n",
                 sts, msg, result.osnum, result.objid);
#endif
      }
      else
      {
          number_of_points = 0;
          points = NULL;
          number_of_bad_curves = 0;

          map_options = EMMapBnd_WantStatMsg | EMMapBnd_WantBadCurves |
                        EMMapBnd_StrokeIfNeeded;

          imp_options = EMImpBnd_WantStatMsg;
          area_pt = NULL;

          if(ME.super_cmd->mytype == PlcFea)
          {
            imp_options |= EMImpBnd_PlaceFeatures | EMImpBnd_NoStateTree;
            map_options |= EMMapBnd_NoValidate | EMMapBnd_NoFixing;
          }
          else if(ME.super_cmd->mytype == SplitArea)
          {
            map_options |= EMMapBnd_NoValidate | EMMapBnd_NoFixing 
                           | EMMapBnd_ClipBdryArea;
            imp_options |= EMImpBnd_DegenerateBdrys | EMImpBnd_BdryIsArea;
          }
          else
          {
            if(ME.COimpbnd->uv_in_area[0] == NO_POINT)
             imp_options |= EMImpBnd_AutoNest;
            else
             area_pt = ME.COimpbnd->uv_in_area;
          }

          surf = ME.COimpbnd->locobj[0].located_obj;

          if(ME.super_cmd->mytype == PlcFea)
          {
           save_broadcast_flag = ASbroadcast_in_progress;
           ASbroadcast_in_progress = TRUE;
          }

          sts = om$send(msg = message EMSsurface.EMimpose_boundaries(
                         &msg,
                         ME.COimpbnd->numcrv,
                         NULL,                      /* no curve buffers */
                         &ME.COimpbnd->locobj[1],   /* curve objects */
                         area_pt,                   /* point */
                         TRUE,                      /* point is in area */
                         &ME.COimpbnd->locobj[0].module_info, 
                         &number_of_points,         
                         &points,
                         &number_of_bad_curves,
                         bad_curve_indices,
                         NULL,
                         NULL, 
                         NULL, 
                         NULL, 
                         map_options, 
                         imp_options,
                         NULL),
                        targetid = surf.objid, targetos = surf.osnum);
          /*
           * Don't put any code between the above call to 
           * EMimpose_boundaries and resetting the ASbroadcast
           * variable.  It must get reset for mytype==PlcFea
           *                                     - Jack (10/16/92)
           */
          if(ME.super_cmd->mytype == PlcFea)
             ASbroadcast_in_progress = save_broadcast_flag;
   



      }
      current_creator = NULL_OBJID;

      if(msg == EMS_I_NoMoreLoops)
       ex$message(msgnumb = EMS_F_0003)
      else if (!(1 & sts))
       ex$message(msgnumb = EMS_F_0004)

      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " ... ")
      ME.super_cmd->state = UNHILITE_BOUNDARIES;

      break;
/*
 * Unhighlight the boundaries and redraw the surface
 */
     case UNHILITE_BOUNDARIES:

      ex$message(msgnumb = EMS_I_00004, type = "%s", var = " .... ")
      DisplayMode = GRhe;
      for (j = 0, i = 1; i <= ME.COimpbnd->numcrv; i++)
       {
        if ((number_of_bad_curves == 0) ||
            ((j < number_of_bad_curves) &&
             (bad_curve_indices[j] != (i - 1))))
         {
          struct        GRlc_info *info;
          
          info = &ME.COimpbnd->locobj[i];
          sts = om$send(
            msg = message GRgraphics.GRdisplay(
             &msg,
             &info->module_info.md_env.matrix_type,
             info->module_info.md_env.matrix, 
             &DisplayMode,
             &me->ModuleInfo.md_id),
            targetid = info->located_obj.objid,
            targetos = info->located_obj.osnum);
           ERROR(sts, msg, "GRdisplay error")
         }
        else            /* Bad curve was found */
         j++;
       }
      ME.COimpbnd->numcrv = 0;
      DisplayMode = GRbd;
      {
       struct   GRlc_info *info;

       info = &ME.COimpbnd->locobj[0];
       sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
                   &info->module_info.md_env.matrix_type,
                   info->module_info.md_env.matrix, 
                   &DisplayMode,
                   &me->ModuleInfo.md_id),
                   targetid = info->located_obj.objid,
                   targetos = info->located_obj.osnum);
        ERROR(sts, msg, "GRdisplay error")
      }
      ME.super_cmd->state = BEGIN_STATE;
      if (number_of_points)
       {
        IGRlong EMoutput_point();
        GRobjid point_set;
        struct  GRvg_construct construct_list;
        struct  GRid *point_ids = NULL;

        point_ids = (struct GRid *) 
                    alloca(number_of_points * sizeof(struct GRid));
        construct_list.msg = &msg;
        construct_list.env_info = &ME.CObuild->ModuleInfo;
        construct_list.newflag = FALSE;
        construct_list.geometry = NULL;
        construct_list.class_attr = NULL;
        construct_list.level = ME.CObuild->ActiveLevel;
        construct_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
        construct_list.display = &ME.CObuild->ActiveDisplay;
        construct_list.name = NULL;
        sts = EMoutput_point(
          &msg,
          my_id,
          &construct_list,
          number_of_points,
          points,
          point_ids);
        ERROR(sts, msg, "LOCAL_DISPLAY error")
        free(points);
        if (number_of_points > 1)
         {
          sts = EFbuild_graphic_group(
            number_of_points,
            NULL,                       /* No GRobjid */
            point_ids,
            &construct_list,
            &point_set,
            &msg);
          ERROR(sts, msg, "EFbuild_graphic_group error")
         } /* if (number_of_points > 1) */
        else
         point_set = point_ids[0].objid;
        DisplayMode = GRbd;
        sts = om$send(msg = message GRgraphics.GRdisplay(&msg,
              &ME.CObuild->ModuleInfo.md_env.matrix_type,
              ME.CObuild->ModuleInfo.md_env.matrix, 
              &DisplayMode,
              &ME.CObuild->ModuleInfo.md_id),
              targetid = point_set, 
              targetos = point_ids[0].osnum);
        ERROR(sts, msg, "GRdisplay error")
       }
      if (number_of_points ||
          number_of_bad_curves)
       ex$message(msgnumb = EMS_I_00074)
      else
       ex$message(msgnumb = EMS_I_00000)
      break;
/*
 * Something has messed up our state table
 */
     default:
      ERROR(OM_E_ABORT, 0, "Default state reached")
    }
  }
 while(TRUE);
}

#if HAVE_THIS_IN_GOOD_SHAPE
             /* Take the proj pnt on the curve and do a pt_location on the
              * surface.  If in hole or on edge then ask for the bound point
              * again.
              */
             { /*INTENTIONAL*/
	       IGRpoint 	    sf_pnt;
	       IGRdouble            uv_pnt[2];
               struct EMSptloc_info pnt_location;
	       struct GRparms       sf_parms;
	       struct GRlc_info     *sf_obj;
	       OM_S_CHANSELECT      to_loopset;
	       struct EMSpartolbasis partolbasis;

	       sf_obj = &me->locobj[0];

               (void) DLB_ptnorsf(&msg,
               		          sf_obj->located_obj.objid,
               		          sf_obj->located_obj.osnum,
               		          &sf_obj->module_info,
               		          obj->proj_pnt,
               		          sf_pnt,
               		          &sf_parms);
               ERROR(sts, msg, "DLB_ptnorsf pt_loc");

	       uv_pnt[0] = sf_parms.u;
	       uv_pnt[1] = sf_parms.v;

	       partolbasis.is_valid = FALSE;	       
	       partolbasis.in_world = TRUE;
	       partolbasis.mattyp = &sf_obj->module_info.md_env.matrix_type;
	       partolbasis.mat = sf_obj->module_info.md_env.matrix;

	       EMmake_chanselect(EMSsubbs_to_loopset, &to_loopset);

	       pnt_location.options = NULL;
	       sts = om$send(msg = message EMSloopset.EMpt_location(&msg, 
	       			   uv_pnt,
	       			   &pnt_location,
	       			   &partolbasis),
	       	             senderid = sf_obj->located_obj.objid,
	       	             targetos = sf_obj->located_obj.osnum,
	       	             p_chanselect = &to_loopset);
               ERROR(sts,msg,"pt_location");
 
	       if (pnt_location.location != EMS_L_INAREA)
	       {
	         ME.COimpbnd->numcrv--;
                 me->state = IMPOSE_BOUNDARIES;
		 ex$message(msgnumb = EMS_E_BndPtInArRegSur);
	       }
            }
#endif

end implementation COimpbnd;
