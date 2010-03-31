/* ###################   APOGEE COMPILED   ################## */
/*
   DESCRIPTION: 

     This command object is to construct tube surface/solid arround linear
     elements. User locates a linear curve element and specifies
     a tube radius. At every vertex of the linear element a bend radius
     is obtained. Based on this input the surface/solid is calculated,
     constructed and displayed.

   HISTORY:

7/05/93 Sudha   Modified for BSprototypes ansification
6/02/92 Rustagi Modified for Message Sub-system Compliance  
10/05/91    DLB Added & to event_size in lc$locate.
08 Aug 1991 scw Converted to use gr$dpb associative flag

22 May 1989 jBk Replaced GRm_STRING mask with GRm_TEXT_VALUE.

19 May 1989 jBk Changed references of GRgetevent to co$getevent.

15 May 1989 jBk Removed wakeup implementation.

    dhm        2/24/89 :   changed to work for reference file objects and
                           to use the active module environment for
                           displays and constructs.
    rlw        02/17/89 :  Fixed my fix
    rlw        02/10/89 :  Added support for linear composite curves
    SS         01/05/87 :  Changed the code to a linear format and
                           removed saveset-channel. Converted it for 1.1.
    PP         06/23/87 :  The command object was somehow not recognising
                           string input while entering bend radii. Made
                           appropriate changes.
    PP         05/22/87 :  Made changes for the construction of
                           a solid tube
    krp        10/02/86 :  Genesis date.
*/
        
class implementation ECtubesur;

#include "EMS.h"
#include "OMmacros.h"

# include "griomacros.h" /* co$getevent */

#include "bserr.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "DIdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasopts.h"
#include "EMSdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EC_M.h"
#include "EC_S.h"
#include "EMSascmacros.h"
#include "bsdistptpt.h"

#define X 0
#define Y 1
#define Z 2

#define TUBE_RAD     0

#define TUBE_SURFACE 0
#define TUBE_SOLID   1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_EMSgenbs_class_id, OPP_EMSsfsolid_class_id;
extern GRclassid OPP_GRbspline_class_id, OPP_GRcurve_class_id;

from GRgraphics import GRdisplay;
from EMSgenbs import EMplctbesrf;
from EMSsfsolid import EMcap_thyself;

method wakeup(int pos)
{
 IGRint       sts;
 IGRboolean   state;

 sts = om$send ( mode = OM_e_wrt_parent,
                 msg = message ECtubesur.wakeup (pos),
                 targetid = my_id );

 gr$get_associative_flag( buffer = &state );
 GRdisplay_associative_button(state);

 return sts;
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRint event_size, num_vertices = 0, curr_inx, i;
  IGRlong stat_OM, msg_loc, stat_func;
  IGRlong window_disp, event_mask1, event_mask2;
  IGRdouble radius;
  IGRdouble (*vertices)[3], *vertex, *radii;
  GRobjid const_sfobjid, const_slobjid;
  struct GRevent accev, event;
  struct GRlc_locate lc_attr;
  struct IGRbsp_curve *crv;
  struct GRmdenv_info *mdenv_info;
  enum GRdpmode dpmode;
  enum EMSdatatype datatype;
  OMuword rclass, eliclass;
  OM_S_CLASSLIST rtree_classes, elig_classes;
  IGRint EMgetvggeom();
  IGRboolean    constant_radius = FALSE;
  extern   void EMinitvgcnstr();
  extern   void EMgetvgcnstr();   
  IGRchar locate_prompt[52], accept_prompt[52], relocate_prompt[52];
  struct GRvg_construct *construction_list=NULL;
  IGRpoint	xyz;

  stat_OM = OM_S_SUCCESS;
  *response = TERMINATE;

  crv = NULL;
  event_size = sizeof (struct GRevent);

  if (ME.super_cmd->mytype == TUBE_SURFACE)
    ex$message(msgnumb = EM_M_PlacTbSrf)
  else if (ME.super_cmd->mytype == TUBE_SOLID)
    ex$message(msgnumb = EM_M_PlacTuSol)
  else
    EMomerr_exit (stat_OM = OM_E_ABORT, ret_end);    

  do 
    {
    switch (ME.super_cmd->state)
      {
      case 0:
        if (ME.ECelement->elem_hilit)
          {
          dpmode = GRbdhe;
          mdenv_info = &ME.ECelement->elem.module_info.md_env;
          stat_OM = om$send(msg = message GRgraphics.GRdisplay
                     (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
                     &dpmode, &ME.ECelement->md_env.md_id),
                     targetid = ME.ECelement->elem.located_obj.objid,
                     targetos = ME.ECelement->elem.located_obj.osnum);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
          ME.ECelement->elem_hilit = FALSE;
          }

        event_mask1 = GRm_DATA | GRm_BACK_UP;
        event_mask2 = GRm_DATA;

        window_disp =  ELEM_HILIGHT;

	ex$message(msgnumb = EMS_P_IdeLinearEle, buff = locate_prompt);
	ex$message(msgnumb = EMS_P_00038, buff = accept_prompt);
	ex$message(msgnumb = EMS_S_LinElmNtFnd, buff = relocate_prompt);

        strcpy (lc_attr.classes, "GRbspline");
        lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;
        lc_attr.owner_action = LC_RIGID_COMP | LC_FLEX_COMP |
              LC_REF_OBJECTS |     /* locate reference objects */
              LC_NO_REF_HEADER;    /* no reference file header */
    
        rtree_classes.w_count = 1;
        elig_classes.w_count = 1;
        rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;
        rtree_classes.p_classes = &rclass;
        elig_classes.p_classes = &eliclass;
        rclass = OPP_GRbspline_class_id;
        eliclass = OPP_GRcurve_class_id;

/****
DLB 10/5/91	Added & to event_size.  Crash on SUN.
****/
        lc$locate (rc = &msg_loc, event1 = &ME.ECelement->locev,
                   event2 = &accev, mask1 = event_mask1, mask2 = event_mask2,
                   eventsize = &event_size, display_flag = window_disp,
                   response = response, response_data = response_data,
                   locate_prompt = locate_prompt,
                   acc_prompt = accept_prompt,
                   relocate_prompt = relocate_prompt,
                   attributes = &lc_attr, stack = &ME.ECelement->locate_stack,
                   rtree_classes = &rtree_classes, 
                   eligible_classes = &elig_classes);
        ex$message(msgnumb = EMS_S_ClearStatusField);
        ex$message(msgnumb = EMS_P_ClearPromptField);
        if (msg_loc == LC_NO_OBJ_LOCATED)
          goto ret_end;

        switch (accev.response)
          {
          case EX_DATA:
            ME.ECelement->elem_hilit = TRUE;
            ME.ECelement->elem.located_obj.objid = accev.located_object[0].
                                         located_obj.objid;
            ME.ECelement->elem.located_obj.osnum = accev.located_object[0].
                                         located_obj.osnum;
            ME.ECelement->elem.module_info = accev.located_object[0].
                                         module_info;
  
            mdenv_info = &ME.ECelement->elem.module_info.md_env;
            stat_OM = EMgetvggeom (&msg_loc, &mdenv_info->matrix_type,
                       mdenv_info->matrix, &ME.ECelement->elem.located_obj,
                       &crv, &datatype);
            EMomerr_exit (stat_OM, ret_end);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
           
            if (crv->order > 2)
              {
              ex$message(msgnumb = EMS_S_LinElmNtFnd);
              om$dealloc (ptr = crv);
              crv = NULL;
              break;
              }
            else
              {
              BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, ME.ECtubesur->lentol);
              num_vertices = crv->num_poles-1;
              ME.ECtubesur->num_vertices = num_vertices;
              om$vla_set_dimension (varray = ME.ECtubesur->vertices,
               size = num_vertices);
              om$vla_set_dimension (varray = ME.ECtubesur->radii,
               size = num_vertices);
              OM_BLOCK_MOVE (crv->poles, ME.ECtubesur->vertices, 
               num_vertices * 3 * sizeof (IGRdouble));
              om$dealloc (ptr = crv);
              crv = NULL;
              ME.ECtubesur->curr_inx = 0;
              }

            ME.super_cmd->state = 1;
            break;
          default:
            goto ret_end;
          }
        break;

      case 1:

        curr_inx = ME.ECtubesur->curr_inx;
        num_vertices = ME.ECtubesur->num_vertices;
        vertices = ME.ECtubesur->vertices;
        radii = ME.ECtubesur->radii;
        if (curr_inx == TUBE_RAD)
          ex$message(msgnumb = EMS_P_EntubeRad)
        else if (curr_inx < num_vertices)
          ex$message(msgnumb = EMS_P_EntBlenDRad)
        else
          {
          ME.super_cmd->state = 2;
          break;
          }
        vertex = vertices[curr_inx];

        EFrblineseg (vertex, &ME.ECelement->active_display);
/*
        event_mask = GRm_DATA | GRm_DIST | 
                     (curr_inx == TUBE_RAD? NULL : GRm_TEXT_VALUE) | 
                     GRm_BACK_UP;
        stat_func = GRgetevent (&msg_loc, &event_mask, &event_size, &event, 
                                response, response_data);
*/
        stat_func = EMSokay (co$getevent (
            msg = &msg_loc,
            event_mask = GRm_DATA | GRm_VALUE | GRm_BACK_UP |
                (curr_inx == TUBE_RAD? NULL : GRm_TEXT_VALUE),
            value_type = GRIO_DISTANCE,
            response = response,
            response_data = response_data,
            event = &event
        ));

        ex$message(msgnumb = EMS_P_ClearPromptField);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        if (msg_loc == GRw_no_value)
          {
          event.response = EX_STRING;
          event.event.keyin[0] = 'L';
          }
        else if (msg_loc != MSSUCC)
          goto ret_end;

        switch (event.response)
          {
          case EX_DATA:
          case EX_VALUE:
            if (event.response == EX_DATA) {
	      xyz[0] = event.event.button.x;
	      xyz[1] = event.event.button.y;
	      xyz[2] = event.event.button.z;
              radius = BSdistptpt (&msg_loc, xyz/*&event.event.button*/, vertex);
            }
            else
              radius = event.event.value;
            if (radius < ME.ECtubesur->lentol)
              {
              ex$message(msgnumb = EMS_S_RadTooSmal);
              break;
              }
            else if (curr_inx != TUBE_RAD && radius < radii[TUBE_RAD])
              {
              ex$message(msgnumb = EMS_S_RadMstLar); 
              break;
              }
            radii[curr_inx] = radius;
            ME.ECtubesur->curr_inx++;
            break;

          case EX_STRING:
            switch (toupper (event.event.keyin[0]))
              {
              case 'T':
                radii[curr_inx] = radii[TUBE_RAD];
                ME.ECtubesur->curr_inx++;
                break;
              case 'A':
                for (i=curr_inx; i<num_vertices; i++)
                  radii[i] = radii[curr_inx-1];
                ME.ECtubesur->curr_inx = num_vertices;
                if (curr_inx == 1) constant_radius = TRUE;
                break;
              case 'L':
                radii[curr_inx] = radii[curr_inx-1];
                ME.ECtubesur->curr_inx++;
                break;
              default:
                ex$message(msgnumb = EMS_S_BadOption);
              }
            break;

          case EX_BACK_UP:
            if (curr_inx == TUBE_RAD)
              ME.super_cmd->state = 0;
            else
              ME.ECtubesur->curr_inx--;
            break;
          default:
            goto ret_end;
          }
        break;

      case 2:

        ex$message(msgnumb = EMS_S_Processing);
        dpmode = GRbdhe;
        mdenv_info = &ME.ECelement->elem.module_info.md_env;
        stat_OM = om$send(msg = message GRgraphics.GRdisplay
                   (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
                   &dpmode, &ME.ECelement->md_env.md_id),
                   targetid = ME.ECelement->elem.located_obj.objid,
                   targetos = ME.ECelement->elem.located_obj.osnum);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
        ME.ECelement->elem_hilit = FALSE;

        {
            IGRboolean              assoc_placement;
            IGRint                  j, k, num_bend_radii;
            struct EMSobject_info   loc_curve;
            struct EMSvalue_info    loc_radius;
            struct EMSvalue_info  * loc_bend_radii;

            gr$get_associative_flag( buffer = &assoc_placement );

            loc_curve.grid = ME.ECelement->elem.located_obj;
            loc_curve.env  = ME.ECelement->elem.module_info;

            loc_radius.type = EMSdatainfo_numeric;
            loc_radius.val  = ME.ECtubesur->radii[0];

            if (!constant_radius)
            {
                num_bend_radii = num_vertices - 1;
                loc_bend_radii = (struct EMSvalue_info *)stackalloc(num_bend_radii * sizeof(struct EMSvalue_info));

                for (j=0, k=1; j<num_bend_radii; ++j)
                {
                    loc_bend_radii[j].type = EMSdatainfo_numeric;
                    loc_bend_radii[j].val  = ME.ECtubesur->radii[k++];
                }
            }
            else {
		num_bend_radii = 0;
		loc_bend_radii = 0;
	    }
/*****************************************************************************
            stat_OM = EMplace_tube ( &msg_loc,
                                     assoc_placement ? NULL : EMSasconst_notassociative,
                                     &ME.ECelement->md_env,
                                     ME.ECelement->active_level,
                                     &ME.ECelement->active_display,
                                     NULL,
                                     NULL,
                                     &loc_curve,
                                     &loc_radius,
                                     num_bend_radii,
                                     loc_bend_radii,
                                     (ME.super_cmd->mytype == TUBE_SOLID),
                                     &const_sfobjid );
******************************************************************************/
           construction_list = (struct GRvg_construct *) om$malloc(size =
                                            sizeof(struct GRvg_construct));
           EMinitvgcnstr(&msg_loc, &ME.ECelement->md_env,
                         &ME.ECelement->active_display,
                         NULL, construction_list);
           EMgetvgcnstr(NULL, NULL, &ME.ECelement->md_env,
                        ME.ECelement->active_level,
                        &ME.ECelement->active_display,
                        NULL, NULL, construction_list);  
           stat_OM = ems$place_tube(msg = &msg_loc,
               options = assoc_placement ? NULL : EMSasconst_notassociative,
               construction_list = construction_list,
               axis_curve = &loc_curve,
               tube_radius = &loc_radius,
               num_bend_radii = num_bend_radii,
               bend_radii = loc_bend_radii,
               is_solid  = (ME.super_cmd->mytype == TUBE_SOLID),
               tube_obj = &const_sfobjid );   
            const_slobjid = const_sfobjid;

            if (loc_bend_radii) stackfree (loc_bend_radii);
        }
/*
        const_list.msg = &msg_loc;
        const_list.env_info = &ME.ECelement->md_env;
        const_list.newflag = FALSE;
        const_list.level = ME.ECelement->active_level;
        const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;
        const_list.display = &ME.ECelement->active_display;
        const_list.class_attr = NULL;
        const_list.name = NULL;

        stat_OM = om$construct (classid = OPP_EMSgenbs_classkd,
                   osnum = ME.ECelement->md_env.md_id.osnum,
                   msg = message EMSgenbs.EMplctbesrf
                   (&msg_loc, &ME.ECelement->elem.module_info,
                   ME.ECelement->elem.located_obj, 
                   ME.ECtubesur->radii[TUBE_RAD],
                   &ME.ECtubesur->radii[TUBE_RAD+1], &const_list),
                   p_objid = &const_sfobjid);
*/
        if(construction_list)
          {
          om$dealloc(ptr = construction_list);
          construction_list=NULL;
          }
        if (!(1&stat_OM&msg_loc))
        {
        if (ME.super_cmd->mytype == TUBE_SURFACE)
          ex$message(msgnumb = EMS_S_TubeSfNtCons)
        else
          ex$message(msgnumb = EMS_S_TubeSolNtCons);
        ME.super_cmd->state = 0;
        break;
        }
/*
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
*/

/*
        if (ME.super_cmd->mytype == TUBE_SOLID)
        {
          stat_OM = om$construct (classid = OPP_EMSsfsolid_classkd,
                     osnum = ME.ECelement->md_env.md_id.osnum,
                     msg = message EMSsfsolid.EMcap_thyself
                     (&msg_loc, &const_list, &const_sfobjid),
                     p_objid = &const_slobjid);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

          if (!(1&stat_OM&msg_loc))
          {
            if (ME.super_cmd->mytype == TUBE_SOLID)
              ex$message(msgnumb = EMS_S_TubeSolNtCons)
            ME.super_cmd->state = 0;
            break;
          }
        }
*/
        ex$message(msgnumb = EMS_S_ClearStatusField);

        dpmode = GRbd;
        mdenv_info = &ME.ECelement->md_env.md_env;
        stat_OM = om$send(msg = message GRgraphics.GRdisplay
                   (&msg_loc, &mdenv_info->matrix_type, mdenv_info->matrix,
                   &dpmode, &ME.ECelement->md_env.md_id),
                   targetid = (ME.super_cmd->mytype == TUBE_SURFACE ?
                               const_sfobjid : const_slobjid), 
                   targetos = ME.ECelement->md_env.md_id.osnum);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);
 
        if (ME.super_cmd->mytype == TUBE_SURFACE)
          ex$message(msgnumb = EMS_S_TubeSfCons)
        else
          ex$message(msgnumb = EMS_S_TubeSolCons);

        ME.super_cmd->state = 0;
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  /* fix for mlk */
  if(construction_list)
    om$dealloc(ptr = construction_list);
  if (crv)
    om$dealloc(ptr = crv);
  if (EMSerror (stat_OM))
    *response = TERMINATE;
  stat_func = TRUE;
  EMWRAPUP (stat_func, stat_OM, "ECtubesur.execute");
  return (stat_OM);
}

end implementation ECtubesur;

