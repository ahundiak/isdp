class implementation COpdu;


#include <PDUintdef.h>
#include <msmacros.h>
#include <msdef.h>
#include <godef.h>
#include <dpmacros.h>
#include <lcmacros.h>
#include <grdpbmacros.h>
#include <dpdef.h>
#include <dperr.h>
#include <PDUforms.h>
#include <PDUform_def.h>
#include <FI.h>

#define LOGOUT_BTN 82
#define LOGOUT 20
#define DELETE_CATALOG 34

from    GRgraphics  import      GRdelete;
from    GRreffile   import      GRgetdescription;

IGRpoint PDU_origin_point;

extern struct    PDUrefresh *refresh;
extern IGRint    PDU_invis_file_index;	/** 10/89 lmm **/
extern struct GRid    PDU_invis_newmod;
extern struct GRid    *PDU_part_id;
extern struct GRid    *PDU_origin_id;
extern IGRmatrix      PDUrot_mat;
extern IGRshort       PDU_store_point;
extern IGRshort       PDU_store_view;
extern IGRdouble      PDU_point[3];
extern IGRint         PDU_message_type;
extern IGRint         PDU_prompt_type;
extern IGRchar        *PDU_viewname;
struct GRid           PDU_window_id;
extern IGRshort       PDU_refresh_populated;
extern IGRshort       PDU_prompt_response;
extern IGRshort       PDU_list_parts;
extern IGRshort       PDU_list_origins;
extern IGRchar        PDU_status_string[54];
extern struct         PDUforms forms;
extern IGRint         PDU_command;


/************************************************************************
 * This action invokes the function PDUinternal, which uses the command *
 * type from the refresh area to call the appropriate  function to      *
 * perform the required actions internal to ems.  The resulting status  *
 * is returned in the refresh area.					*
 ************************************************************************/



method pdu_internal ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  refresh->command = me->mytype;

  *sts = PDUinternal ();

  refresh->status = *sts;
  quit:
  return OM_S_SUCCESS;
}

method pdu_external ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  refresh->command = me->mytype;

  *sts = PDUexternal ();

  refresh->status = *sts;
  quit:
  return OM_S_SUCCESS;
}

method display_command ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  status = PDUmessage (me->mytype, 'c');
  _pdm_status ("PDUmessage", status);

  *sts = PDM_S_SUCCESS;
  quit:
  return OM_S_SUCCESS;
}

method disp_cmd_cancelled ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  int display = FALSE;

  status = PDUmessage (PDM_E_CMD_CANCELLED, 's');
  _pdm_status ("PDUmessage", status);

  if (refresh->command == PDC_M_LOGOUT)
    {
    if (forms.design_form_id)
      {
      FIf_is_displayed(forms.design_form_id, &display);
      if (display)
        FIg_enable(forms.design_form_id, LOGOUT);
      }
    if (forms.local_files_form_id)
      {
      FIf_is_displayed(forms.local_files_form_id, &display);
      if (display)
        FIg_enable(forms.local_files_form_id, LOGOUT_BTN);
      }
    }
  else if (refresh->command == PDC_M_DELETE_CATALOG)
    {
    if (forms.cat_name_form_id)
      {
      FIf_is_displayed(forms.cat_name_form_id, &display);
      if (display)
        FIg_enable(forms.cat_name_form_id, DELETE_CATALOG);
      }
    }
  else if ((refresh->command == PDC_M_DELETE_BOM_FORMAT) ||
           (refresh->command == PDC_M_DEL_BOM_SUM_PR_FORM) ||
           (refresh->command == PDC_M_DEL_BOM_EXP_PR_FORM) ||
           (refresh->command == PDC_M_DEL_BOM_PARTS_LIST_PR_FORM) ||
           (refresh->command == PDC_M_DEL_BOM_WHERE_BOM_PR_FORM) ||
           (refresh->command == PDC_M_DEL_BOM_WHERE_USED_PR_FORM) ||
           (refresh->command == PDC_M_DELETE_LOC_DISP_FORMAT) ||
           (refresh->command == PDC_M_DELETE_CATLIST_FORMAT))
    {
    if (forms.report_form_id)
      {
      FIf_is_displayed(forms.report_form_id, &display);
      if (display)
        FIg_enable(forms.report_form_id, 20);
      }
    }
  else if (refresh->command == PDC_M_DELETE_BOM)
    {
    if (forms.report_form_id)
      {
      FIf_is_displayed(forms.report_form_id, &display);
      if (display)
        FIg_enable(forms.report_form_id, 63);
      }
    }
  *sts = PDM_S_SUCCESS;
  quit:
  return OM_S_SUCCESS;
}

method display_status ( long * sts )
{
  int		  status = OM_S_SUCCESS;


  status = PDUmessage (refresh->status, 's');
  _pdm_status ("PDUmessage", status);

  /*switch ( me->mytype )
     {
     case  PDC_M_PLACE_PART:
     case  PDC_M_ALIGN_PART:
     case  PDC_M_COPY_PART:
     case  PDC_M_PLACE_VIEW:
     case  PDC_M_ATTACH_PART:
     case  PDC_M_EDIT_PART:
     case  PDC_M_CHECKIN:
		sleep(5);

     default:
	   break;
     }
   */
   *sts = PDM_S_SUCCESS;
  quit:
  return OM_S_SUCCESS;
}

method display_status_message ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   _pdm_debug("In the action display_status_message", 0);
   strcpy(ME.CEO->status, PDU_status_string);
   *sts = PDM_S_SUCCESS;
   _pdm_debug("ME.CEO->status = <%s>", ME.CEO->status);
  quit:
  return OM_S_SUCCESS;
}

method get_message_type ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   *sts = PDU_message_type;
  quit:
  return OM_S_SUCCESS;
}

method get_prompt_type ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   *sts = PDU_prompt_type;
  quit:
  return OM_S_SUCCESS;
}

method pdu_chg_wf_state ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  _pdm_debug("In the method COpdu.pdu_chg_wf_state refresh->status = %d", refresh->status);
  /* call message processor to set state work controller */
  PDUmessage_trans ( refresh->status, 's' );
  quit:
  return OM_S_SUCCESS;
}

method pdu_validate_wf ( long * sts )
{
  int		  status = OM_S_SUCCESS;


  refresh->command = me->mytype;

  /* call message processor to kick off PDMfunction work controller */
  *sts = PDUmessage_trans ( refresh->command, 'v' );

  refresh->status = *sts;

  quit:
  return OM_S_SUCCESS;
}

method pdu_cleanup ( long * sts )
{
  int		  status = OM_S_SUCCESS;


   switch ( me->mytype )
      {
      case PDC_M_DEFINE_ORIGIN:
      case PDC_M_DEFINE_INVIS_ORIGIN:
	refresh->view = NULL;
	break;
      default:
	break;
      }

  *sts = PDM_S_SUCCESS;
  quit:
  return OM_S_SUCCESS;
}

method close_invis_file ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  /** close invisible file 10/89 lmm **/
  if ( PDU_invis_file_index != -1)
     PDUclose_invis_file ( PDU_invis_file_index );

  PDU_invis_file_index = -1;

  *sts = PDM_S_SUCCESS;
  quit:
  return OM_S_SUCCESS;
}

method disconnect_located ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  /*   Disconnect the previously located object from myself */
  *sts =  lc$wild_disconnect ( p_chanselect = &me->located_chansel );
  _pdm_rstatus ("lc$wild_disconnect", *sts);

  if ( 1&(*sts) )
     *sts = PDM_S_SUCCESS;
  refresh->status = *sts;
  quit:
  return OM_S_SUCCESS;
}

method save_point ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   /* Dump point to debug */
   PDUdump_point(me->event1.event.button);

   PDU_point[0] = me->event1.event.button.x;
   PDU_point[1] = me->event1.event.button.y;
   PDU_point[2] = me->event1.event.button.z;

   PDU_window_id.objid = me->event1.event.button.objid;
   PDU_window_id.osnum = me->event1.event.button.osnum;

   PDU_store_point = TRUE;
  quit:
  return OM_S_SUCCESS;
}

method display_design_form ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   _pdm_debug("In the display_design_form action", 0);

   *sts = PDUdisplay_design_form();
  quit:
  return OM_S_SUCCESS;
}

method check_default_view ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   _pdm_debug("In the check_default_view action", 0);

   *sts = PDUcheck_default_view();
  quit:
  return OM_S_SUCCESS;
}

method store_view ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   _pdm_debug("In store_view action", 0);

   *sts = PDM_S_SUCCESS;
    refresh->status = PDM_S_SUCCESS;

   /*  ALR   12/28/93  Validate string against illegal char TR 139309988 */
   /*  ALR  2/8/94  TR139416623 */

   if ((char *)strchr(me->event1.event.keyin,',') ||
       (char *)strchr(me->event1.event.keyin,'*') ||
       (char *)strchr(me->event1.event.keyin,':') ||
       (strlen(me->event1.event.keyin) > 40))
       {
          PDU_viewname = NULL;
         *sts = PDM_E_INVALID_VIEW_NAME;
          refresh->status = PDM_E_INVALID_VIEW_NAME;
       }
   else
    { 
     PDUfill_in_string(&PDU_viewname, me->event1.event.keyin);
     PDU_store_view = TRUE;
    }
   _pdm_debug("PDU_viewname = <%s>", PDU_viewname);
  quit:
  return OM_S_SUCCESS;
}

method default_view ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   _pdm_debug("In default_view action", 0);
   PDUfill_in_string(&PDU_viewname, "PDUview");
   PDU_store_view = TRUE;
   _pdm_debug("PDU_viewname = <%s>", PDU_viewname);
  quit:
  return OM_S_SUCCESS;
}

method save_default_view ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRdouble	sv_origin [3];
  struct GRid	savedvw_mgr, window;
  IGRchar       *rot_mat_string;
  IGRchar       *vw_rot_name;
  OM_S_OBJID    osid;
  OMuword       osnum;
  IGRlong       msg;                        /* return status */
  IGRint        num_win;                    /* number of window gragads found */
  GRobjid       gragad_id;                  /* window graphic gadget */

  _pdm_debug("In the method COpdu.save_default_view", 0);

  *sts = MSSUCC;
  status = OM_S_SUCCESS;
   msg = MSSUCC;
  num_win = 0;
  gragad_id = NULL_OBJID;

  if ( (1&status) && (*sts == MSSUCC) )
     {
     /* get active module info */
     status = ex$get_cur_mod ( id = &osid, osnum = &osnum );
     _pdm_status ("ex$get_cur_mod", status);

     _pdm_debug("active osnum = %d", osnum);
     _pdm_debug("active osid = %d", osid);

     rot_mat_string = (IGRchar *) malloc
                                  ( PDU_K_ORIENTATION_LEN * sizeof (IGRchar) );
     status = PDUmatrix_to_string ( PDU_REPORT_ORIENTATION, PDUrot_mat,
                                    rot_mat_string);
     _pdm_status ("PDUmatrix_to_string", status);
     _pdm_debug ("rot_mat_string = %s", rot_mat_string );

     status = PDUset_invis_vwname ( rot_mat_string, &vw_rot_name );
     _pdm_status ("PDUset_invis_vwname", status);

     /* set up gadget id for view from event structure */
     _pdm_debug("PDU_invis_newmod.osnum = <%d>", PDU_invis_newmod.osnum);
     _pdm_debug("PDU_invis_newmod.objid = <%d>", PDU_invis_newmod.objid);

     _pdm_debug("Looking for gadget with name <%s>", vw_rot_name);
     status = dp$get_gragad_id ( msg = &msg,
                                    mod_GRid = &(PDU_invis_newmod),
                                    name = vw_rot_name,
                                    array_size = 1,
                                    numberofids = &num_win,
                                    found_GRids = &window );
     _pdm_status2 ("dp$get_gragad_id", status, msg);
     _pdm_debug("num_win = <%d>", num_win);

     _pdm_debug("window.objid of active module = <%d>", window.objid);
     _pdm_debug("window.osnum of active module = <%d>", window.osnum);

     /* set up saved view origin from indicator info structure */
     sv_origin[0] = 0.0;
     sv_origin[1] = 0.0;
     sv_origin[2] = 0.0;

     _pdm_debug("saved view origin.x = %lf", sv_origin[0]);
     _pdm_debug("saved view origin.y = %lf", sv_origin[1]);
     _pdm_debug("saved view origin.z = %lf", sv_origin[2]);

      /* set up global variable for origin point */
     PDU_origin_point[0] = sv_origin[0];
     PDU_origin_point[1] = sv_origin[1];
     PDU_origin_point[2] = sv_origin[2];

     _pdm_debug("PDU_origin_point[0] = %lf", PDU_origin_point[0]);
     _pdm_debug("PDU_origin_point[1] = %lf", PDU_origin_point[1]);
     _pdm_debug("PDU_origin_point[2] = %lf", PDU_origin_point[2]);

     /* view name was already verified */
     /* construct a saved view */

     _pdm_debug("vw_name = <%s>",refresh->view);
     _pdm_debug("Calling dp$savvw_cons", 0);

     status = dp$savvw_cons ( msg = sts,
                              osnum = &(PDU_invis_newmod.osnum),
			      vw_name = refresh->view,
			      gg_id = &window,
			      descript = "View containing a PDM origin",
			      origin = sv_origin );
     _pdm_rstatus2 ("dp$savvw_cons", status, *sts);

     if (*sts != MSSUCC)
       {
        if ( *sts == DPDUPLICNM )
         {
         _pdm_debug("A duplicate view exists", 0);
         *sts = PDM_E_SAVED_VIEW;
         }

       _pdm_debug("Closing invisible file", 0);
       status = PDUclose_invis_file ( PDU_invis_file_index );
       _pdm_status("PDUclose_invis_file", status);
       PDU_invis_file_index = -1;
       return(status);
       } 

     _pdm_debug ("constructed view name = <%s>", refresh->view);

     if ( (1&status) && (*sts == MSSUCC) )
	*sts = PDM_S_SUCCESS;
     }

  refresh->status = *sts;
quit:
  return OM_S_SUCCESS;
}

method store_GRpart_id ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint        obj_count = 2;
   struct PDUid  co;
   struct PDUid  located_GRpart[2];


   _pdm_debug("In the action store_GRpart_id", 0);

   co.objid = my_id;
   co.osnum = OM_Gw_current_OS;
   
   /* Get obj id of located GRpart */
   status = PDUget_objects (
                            &co, 
                            &me->located_chansel,
                            located_GRpart,
                            &obj_count
                           );
   _pdm_status ("PDUget_object", status);

   _pdm_debug("located GRpart id = %d", located_GRpart[0].objid);
   _pdm_debug("located GRpart osnum = %d", located_GRpart[0].osnum);

   /* Store part id in PDU_part_id */
   PDU_part_id = (struct GRid *) malloc (sizeof(struct GRid));

   PDU_part_id->objid = located_GRpart[0].objid;
   PDU_part_id->osnum = located_GRpart[0].osnum; 

   *sts = PDM_S_SUCCESS;
  quit:
  return OM_S_SUCCESS;
}

method store_origin_id ( long * sts )
{
  int		  status = OM_S_SUCCESS;

   IGRint        obj_count = 2;
   struct PDUid  co;
   struct PDUid  located_origin[2];


   _pdm_debug("In the action store_origin_id", 0);

   co.objid = my_id;
   co.osnum = OM_Gw_current_OS;

   /* Get obj id of located origin */
   status = PDUget_objects (
                            &co,
                            &me->located_chansel,
                            located_origin,
                            &obj_count
                           );
   _pdm_status ("PDUget_object", status);

   _pdm_debug("located origin id = %d", located_origin[0].objid);
   _pdm_debug("located origin osnum = %d", located_origin[0].osnum);

   /* Store origin id in PDU_origin_id */
   PDU_origin_id = (struct GRid *) malloc (sizeof(struct GRid));

   PDU_origin_id->objid = located_origin[0].objid;
   PDU_origin_id->osnum = located_origin[0].osnum;

   *sts = PDM_S_SUCCESS;
  quit:
  return OM_S_SUCCESS;
}

method init ( int type ; char * str_ptr )
{
  int		  status = OM_S_SUCCESS;

  /* send parent init */
  status = om$send ( msg = message CEO_LOCATE.init( type, str_ptr ),
		     mode = OM_e_wrt_message,
		     targetid = my_id );
  _pdm_status ("CEO_LOCATE.init", status);

  if ( 1&status )
     {
     /* initialize default values for user input */
     strcpy(me->quantity, PDU_DEFAULT_QUANTITY);
     strcpy(me->usage_id, PDU_DEFAULT_USAGE);
     me->ptr_info.history = NULL;
     me->ptr_info.index = NULL;
     me->ptr_info.type = 'G';
     me->view_info.info = (IGRchar *) NULL;
     me->view_info.levels = 0;

     /* make sure refresh area is allocated */
     if ( refresh == NULL )
	{
	status = PDUalloc_refresh ();
	_pdm_status("PDUalloc_refresh", status);
	}
     }
  quit:
  return OM_S_SUCCESS;
}

method debug ( )
{
  int		  status = OM_S_SUCCESS;

  IGRlong	status1 = PDM_S_SUCCESS;
  /* send parent debug */
  status = om$send ( msg = message Root.debug(),
		     mode = OM_e_wrt_message,
		     targetid = my_id );
  _pdm_rstatus ("Root.debug", status);

  /* send my debug */
  om$send ( msg = message COpdu.mydebug(&status1), targetid = my_id );
  quit:
  return OM_S_SUCCESS;
}

method mydebug ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  if ( PDM_debug_on )
     {
     printf("PDU -- \n");
     printf("PDU -- ************** Entering Class Debugger **************\n");
     printf("PDU -- \n");
     printf("PDU -- Instance data for COpdu parent class:\n");
     printf("PDU -- ME.super_cmd->state = %d\n", ME.super_cmd->state);
     printf("PDU -- ME.CEO->msg    = %s\n", ME.CEO->msg);
     printf("PDU -- ME.CEO->prompt = %s\n", ME.CEO->prompt);
     printf("PDU -- ME.CEO->status = %s\n", ME.CEO->status);
     printf("PDU -- ME.CEO->const_class = %s\n", ME.CEO->const_class);

     printf("PDU -- \n");
     printf("PDU -- Instance data for COpdu:\n");
     printf("PDU -- ME.COpdu->quantity = %s\n", me->quantity);
     printf("PDU -- ME.COpdu->usage_id = %s\n", me->usage_id);
     printf("PDU -- ME.COpdu->part.objid = %d\n", me->part.objid);
     printf("PDU -- ME.COpdu->part.osnum = %d\n", me->part.osnum);
     printf("PDU -- \n");
     printf("PDU -- ************** Exiting Class Debugger **************\n");
     printf("PDU -- \n");
     }
  quit:
  return OM_S_SUCCESS;
}

method verify_command ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRlong	msg = PDM_S_SUCCESS;

  _pdm_debug("In the method COpdu.verify_command", 0);


  /* let certain commands proceed regardless of login status */
  refresh->command = me->mytype;
  switch ( me->mytype )
     {
     case PDC_M_DEBUG_ON:
     case PDC_M_DEBUG_OFF:
        *sts = PDM_S_SUCCESS;
	break;

     case PDC_M_LOGIN_USER:
        *sts = PDUverify_login();
	_pdm_status("PDUverify_login", *sts);
	break;

     default:
	*sts = PDM_S_SUCCESS;
	_pdm_status("PDUverify_login", *sts);
	break;
     }

  if ( *sts != PDM_S_SUCCESS )	/* user is not logged in to PDM */
     {
   if ( me->mytype != PDC_M_LOGIN_USER )
	{
	/* block command execution if not PDC_M_LOGIN */
	*sts = PDM_E_LOGIN;
	}
     else
	*sts = PDM_S_SUCCESS;
     }
  else					/* user is logged in to PDM */
     {
     if ( me->mytype == PDC_M_LOGIN_USER )
	{
	/* block PDC_M_LOGIN command execution if already logged in */
	*sts = NULL;
	}
     }

  if ( 1 & *sts )
     {
      /* verify that command pre-conditions are satisfied at this time */
      *sts = PDUverify_command ( me->mytype );
      _pdm_status("PDUverify_command", *sts);

      if ((PDU_command == PDC_M_DEACTIVATE_CHECKIN) && 
         (me->mytype == PDC_M_DEACTIVATE_PART))
       *sts = PDM_I_PART_CHECKIN;
     }

  if ((PDU_command == PDC_M_DEACTIVATE_CHECKIN) && (*sts == PDM_I_PART_CHECKIN))
    refresh->status = PDM_S_SUCCESS;
  else
   refresh->status = *sts;
  quit:
  return OM_S_SUCCESS;
}

method list_parts ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  _pdm_debug("in list_parts", 0);
  PDU_list_parts = TRUE;
  *sts = PDM_S_SUCCESS;
  refresh->status = *sts;
  quit:
  return OM_S_SUCCESS;
}

method list_origins ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  _pdm_debug("in list_origins", 0);
  PDU_list_origins = TRUE;
  *sts = PDM_S_SUCCESS;
  refresh->status = *sts;
  quit:
  return OM_S_SUCCESS;
}

method check_origins ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  status = PDUdo_origins_exist(0, 1);
  _pdm_status ("PDUdo_origins_exist", status);

  if (!status)
     *sts = PDM_I_ORIGIN_NOT_FOUND;

  else
      *sts = PDM_E_ORIGIN_ALREADY_EXISTS;
  quit:
  return OM_S_SUCCESS;
}

end implementation COpdu;
