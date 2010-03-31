/*
  CAVEAT

  A whole new command has been inserted into the body of the original 
  command. The new command was developed on a 3.3 platform with it's
  own class (EC31addrmfix). But the requirement turned out to be to produce a 
  d-loadable command on top of 3.2. Hence, the code was inserted verbatim, 
  except of course for the changes necessitated by not having the persistence
  of the command-object object.

  The new 3.3 command-object (EC31addrmfix) has since been removed from the
  3.3 RCS and now manifests itself solely within this command.

  Another command has been inserted here -- "z display graphics object"

  
  HISTORY

  SS  :  03/15/96  :  Creation
*/

class implementation ECtest;

/*------------ Inserted from EC31addrmfi.I in 3.3 -------------------*/

#include <stdio.h>
#include "exmacros.h"
#include "EMSasfeatdef.h"
#include "REaddrmfea.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/os.h"
#include "PWapi/sfdntrav.h"
#include "PWapi/objquery.h"
#include "PWapi/featquery.h"

#define CHK_FILE_VER	0
#define GET_LOG_FILE	1
#define CONFIRM_STATE	2
#define GET_ID_STATE	3
#define PROCESS_STATE	4

%safe
struct s_addrmfix
{
  int num_chged;
  PWboolean print_only;
  FILE *logfile;
};

static void FlipInsideOut
(
  PWosnum os,
  int num_dprs,
  PWobjid *dprs,
  PWboolean print_only,
  FILE *logfile,
  int *num_chged
);

static void CorrectOne
(
  PWosnum os,
  PWobjid node_objid,
  FILE *logfile,
  int *num_chged
);

static PWresult addrmfix
(
  PWobjid csf,
  PWosnum os,
  void *args
);
%endsafe

%safe
static char logfile_name[GR_MAX_CHAR] = "";
%endsafe

extern PWclassid OPP_EMSsfdpr_class_id, OPP_EMSsubbs_class_id;
extern PWclassid OPP_EMSsffeature_class_id;
extern PWclassid OPP_EMSsurface_class_id, OPP_GRcurve_class_id;

from EMSassoc import EMget_info, EMput_info;

/*------------ End Insert ----------------------------------------*/

#include "EMSopt.h"
#include "EC_M.h"
#include <stdio.h>
#include <ctype.h>

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define GETBDRY		0
#define GETBDRY_REDUCE	1
#define FIX_31_ADDRM	2
#define DISPLAY_GR	3

from GRgraphics import GRdisplay;
from EMScompsurf import EMtree_traverse;
from EMSsubbs import EMpassloop;
from EMSloopset import EMlsgetbdry;

extern GRclassid OPP_EMScompsurf_class_id, OPP_EMSsubbs_class_id;

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRchar str[80], keyin;
  IGRboolean stat_func;
  IGRlong msg_loc, stat_OM;
  GRclassid elemclass;
  struct GRid *elemid;
  struct GRmd_env *elemenv;
  struct IGResbc esbc;
  struct GRvg_construct constcv_list;
  struct GRmd_env *env;
  enum EMSuser_responses useract;

/*--------------- Inserted command "z display graphics object" -----------*/
if (ME.super_cmd->mytype == DISPLAY_GR)
    {
    IGRlong msg_loc, stat_func, eventmask;
    GRobjid objid;
    GRspacenum osnum;
    struct GRevent event;
    IGRboolean done=FALSE;
    FILE *file;

    UI_message ("Display Object by Id");
    
    stat_OM = OM_S_SUCCESS;

    osnum = EMgetint ("Enter OS number [2]", NULL, TRUE, 2);

    do 
      {
      UI_prompt ("Enter object-id / filename");
      UI_status ("If filename input, it must contain only object-ids");
      eventmask = GRm_VALUE | GRm_TEXT_VALUE;
      stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                   value_type = GRIO_SCALAR, response = response,
                   response_data = response_data, event = &event);
      UI_prompt ("");
      UI_status ("");

      switch (event.response)
        {
        case EX_STRING:
          if (! (file = fopen (event.event.keyin, "r")))
            {
            sprintf (str, "Could not open %s", event.event.keyin);
            UI_status (str);
            break;
            }

          while (fscanf (file, "%d", &objid) != EOF)
            {
            if (!omIsObjidValid (objid, osnum) ||
                (!omIsAncestryValid (omClassidFromObjid (objid, osnum), 
                  OPP_GRcurve_class_id) &&
                 !omIsAncestryValid (omClassidFromObjid (objid, osnum), 
                  OPP_EMSsurface_class_id)))
              {
              sprintf (str, "Object-%d not displayable", objid);
              UI_status (str);
              sleep (2);
              }
            else
              {
              EMdbgdisp (objid, osnum, 0); 
              }
            }
          fclose (file);
          break;

        case EX_VALUE:
          objid = event.event.value;
          if (!omIsObjidValid (objid, osnum) ||
              (!omIsAncestryValid (omClassidFromObjid (objid, osnum), 
                OPP_GRcurve_class_id) &&
               !omIsAncestryValid (omClassidFromObjid (objid, osnum), 
                OPP_EMSsurface_class_id)))
            {
            sprintf (str, "Object-%d not displayable", objid);
            UI_status (str);
            sleep (2);
            }
          else
            {
            EMdbgdisp (objid, osnum, 0); 
            }
          break;
 
        default:
          done = TRUE;
        }
      }
    while (!done);

    goto ret_end;
    }
/*--------------  End Insert command "z display graphics object" -----------*/



/*--------------- Inserted from super_cmd.execute of EC31addrmfi.I --------*/

else if (ME.super_cmd->mytype == FIX_31_ADDRM)
{
  IGRchar str[GR_MAX_CHAR], substr[GR_MAX_CHAR];
  IGRchar filename[PW_K_MaxCharFilename];
  IGRlong msg_loc, stat_func, stat_OM, event_mask;
  IGRint i, ver[4], num_dprs, num_chged;
  PWresult result=PW_K_Success;
  PWobjid *dprs=NULL;
  PWosnum os;
  struct GRevent event;
  enum PWfeattype feattype;
  FILE *logfile=NULL;

  /*
   * Following data was instance data in EC31addrmfix.S
   */

  char *m_logfile=NULL;
  PWboolean m_print_only=FALSE, m_correct_one=FALSE;
  int m_num_dprs=0;
  PWobjid *m_dprs=NULL, m_node_objid=PW_K_NullObjid;



  stat_OM = OM_S_SUCCESS;

  UI_message ("Fix EMS 3.1 Add/Remove Inside/Outside Parameter");

  do
  {
    switch (ME.super_cmd->state)
    {
      case CHK_FILE_VER:
        result = omGetProdVersion (ME.ECelements->active_md_env.md_id.osnum, 
                  "I/MODEL", ver);
        if (ver[0] == 3 && ver[1] == 1)
        {
          ME.super_cmd->state = GET_LOG_FILE;
          break;
        }

        sprintf (str, "Not a 3.1 file: I/MODEL version is %d.%d. Exiting...",
         ver[0], ver[1]);
        UI_status (str);
        UI_prompt ("Hit any key");
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, m_wrapup);
        UI_prompt ("");

        stat_OM = OM_E_ABORT;
        goto m_wrapup;

      case GET_LOG_FILE:
        if (!strlen (logfile_name))
          strcpy (substr, "stderr");
        else
          strcpy (substr, logfile_name);
        sprintf (str, "Log Filename [%s]", substr);
        UI_prompt (str);
        event_mask = GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RJT_MOVEON;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, m_wrapup);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
  
        switch (event.response)
        {
          case EX_STRING:
            if (! (logfile = fopen (event.event.keyin, "a")))
            {
              sprintf (str, "Could not open %s", event.event.keyin);
              UI_status (str);
              break;
            }
            else
            {
              m_logfile = (char *) logfile;
              strcpy (logfile_name, event.event.keyin);
              ME.super_cmd->state = CONFIRM_STATE;
            }
            break;

          case EX_RJT_MOVEON:
            if (strlen (logfile_name))
            {
              if (! (logfile = fopen (logfile_name, "w")))
              {
                sprintf (str, "Could not open %s", logfile_name);
                UI_status (str);
                break;
              }
              else
              {
                m_logfile = (char *) logfile;
              }
            }
            else
            {
              m_logfile = (char *) stderr;
            }
            ME.super_cmd->state = CONFIRM_STATE;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = CHK_FILE_VER;
            break;

          default:
            UI_status ("Exiting...");
            sleep (1);
            stat_OM = OM_E_ABORT;
            goto m_wrapup;
        }
        break;

      case CONFIRM_STATE:
        num_dprs = 0;
        dprs = NULL;
        result = pwGetRtreeTopOwners (1, &OPP_EMSsfdpr_class_id, 0, NULL,
                  OPP_EMSsubbs_class_id, 
                  ME.ECelements->active_md_env.md_id.osnum, &num_dprs, &dprs);
        OnErrorCode (result, m_wrapup);

        logfile = (FILE *) m_logfile;

        ex$filename (name = filename, len = PW_K_MaxCharFilename);
        fprintf (logfile, "\nFile: %s\n", filename);
        fprintf (logfile, "Number of feature trees in file = %d\n", num_dprs);
        for (i=0; i<num_dprs; i++)
          fprintf (logfile, "%d) %d\n", i+1, dprs[i]);
        fflush (logfile);

        m_num_dprs = num_dprs;
        if (num_dprs && dprs)
        {
          m_dprs = (PWobjid *) alloca (num_dprs * sizeof (GRobjid));

          memcpy (m_dprs, dprs, num_dprs * sizeof (GRobjid));

          free (dprs);
          dprs = NULL;
        }

        sprintf (str, 
         "%d Feature trees found. [C]orrect all / Correct (o)ne / (p)rint",
         num_dprs);
        UI_prompt (str);
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, m_wrapup);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
 
        switch (event.response)
        {
          case EX_STRING:
            if (toupper (event.event.keyin[0]) == 'C')
            {
              m_print_only = FALSE;
              m_correct_one = FALSE;
              ME.super_cmd->state = PROCESS_STATE;
            }
            else if (toupper (event.event.keyin[0]) == 'O')
            {
              m_print_only = FALSE;           
              m_correct_one = TRUE;
              ME.super_cmd->state = GET_ID_STATE;
            }
            else if (toupper (event.event.keyin[0]) == 'P')
            {
              m_print_only = TRUE;           
              m_correct_one = FALSE;
              ME.super_cmd->state = PROCESS_STATE;
            }
            break;

          case EX_RJT_MOVEON:
            m_print_only = FALSE;           
            m_correct_one = TRUE;
            ME.super_cmd->state = PROCESS_STATE;
            break;

          default:
            UI_status ("Exiting...");
            sleep (1);
            stat_OM = OM_E_ABORT;
            goto m_wrapup;
        }
        break;

      case GET_ID_STATE:
        UI_prompt ("Enter ObjectId of Feature Node");
        event_mask = GRm_VALUE;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, m_wrapup);
        UI_prompt ("");
 
        switch (event.response)
        {
          case EX_VALUE:
            m_node_objid = event.event.value;
            os = ME.ECelements->active_md_env.md_id.osnum;
            feattype = pwFeatureType (m_node_objid, os);
            if (!(feattype == PWfeat_addmaterial || 
                  feattype == PWfeat_removematerial))
            {
              UI_status ("Not an Add/Remove Feature Object");
              sleep (1);
              break;
            }
            else
            {
              EMdbgdisp (m_node_objid, os, 0); 
            }
            ME.super_cmd->state = PROCESS_STATE;
            break;

          default:
            UI_status ("Exiting...");
            sleep (1);
            stat_OM = OM_E_ABORT;
            goto m_wrapup;
        }       
        break;

      case PROCESS_STATE:
        UI_status ("");
    
        logfile = (FILE *) m_logfile;
        if (!m_correct_one)
          FlipInsideOut (ME.ECelements->active_md_env.md_id.osnum, 
           m_num_dprs, m_dprs, m_print_only, logfile, &num_chged);
        else
          CorrectOne (ME.ECelements->active_md_env.md_id.osnum, m_node_objid,
           logfile, &num_chged);

        if (logfile && logfile != stderr)
          fclose (logfile);
        logfile = NULL;

        if (m_correct_one)
        {
          sprintf (str, "%d -- Add/Rem Feature modified", m_node_objid);
          UI_status (str);
        }
        else
        {
          sprintf (str, "Number Add/Rem Features modified = %d", num_chged);
          UI_status (str);
          sleep (2);
        }

        if (m_correct_one)
        {
          ME.super_cmd->state = GET_ID_STATE;
          break;
        }

        stat_OM = OM_E_ABORT;
        goto m_wrapup;

      default:
        stat_OM = OM_E_ABORT;
        goto m_wrapup;
    }
  }
  while (TRUE);

m_wrapup:
  if (dprs)
    free (dprs);

  if (EMSerror (stat_OM))
    *response = TERMINATE;
  return (stat_OM);
}

/*--------------- End Inserted --------------------------------------------*/

  sprintf (str, "%s %d", "Test command", ME.super_cmd->mytype);
  UI_message (str);

  env = &ME.ECelements->active_md_env;

  constcv_list.msg = &msg_loc;
  constcv_list.env_info = env;
  constcv_list.newflag = FALSE;
  constcv_list.level = ME.ECelements->active_level;
  constcv_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  constcv_list.geometry = NULL;
  constcv_list.display = &ME.ECelements->active_display;
  esbc.is_polydis = FALSE;
  esbc.is_curvedis = TRUE;
  constcv_list.class_attr = (char *)&esbc;
  constcv_list.name = NULL;

  do
  {
  stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
             &useract, response, response_data, "element", 
             NULL, NULL, NULL, NULL, NULL),
             targetid = my_id);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT, ret_end);
  if (!ME.ECelements->num_elems)
	goto ret_end;
  elemid = &ME.ECelements->elems[0].located_obj;
  elemenv = &ME.ECelements->elems[0].module_info;
  stat_OM = om$get_classid (objid = elemid->objid, osnum = elemid->osnum,
             p_classid = &elemclass);
  EMomerr_exit (stat_OM, ret_end);

  switch (ME.super_cmd->mytype)
    {
    case GETBDRY:
    case GETBDRY_REDUCE:
      {
      IGRushort opts;
      IGRboolean got;
      IGRshort *mattyp;
      IGRdouble *mat;
      IGRint i, num_polys;
      GRobjid linid;
      struct IGRpolyline *uvpolys = NULL, *xyzpolys = NULL;
      struct EMSpartolbasis partolbas;
      enum GRdpmode dpmode;
      extern EFplace_line_string();

      opts = EMS_GETB_COMPATIBLEUV | EMS_GETB_COMPATIBLEXYZ |
	  (ME.super_cmd->mytype == GETBDRY_REDUCE ? EMS_GETB_REDUCEDATA : NULL);
      mattyp = &elemenv->md_env.matrix_type;
      mat = elemenv->md_env.matrix;
      partolbas.is_valid = FALSE;
      partolbas.mattyp = mattyp;
      partolbas.mat = mat;
      got = FALSE;

      stat_OM = om$is_ancestry_valid (subclassid = elemclass, 
                 superclassid = OPP_EMScompsurf_class_id);
      if (stat_OM == OM_S_SUCCESS)
        {
        stat_OM = om$send (msg = message EMScompsurf.EMtree_traverse (&msg_loc,
                   message EMSsubbs.EMpassloop (&msg_loc, 
                   message EMSloopset.EMlsgetbdry (&msg_loc, mattyp, mat,
                   NULL, &partolbas, opts,
                   &num_polys, &xyzpolys, &uvpolys, NULL, NULL, NULL)),
                   1, &OPP_EMSsubbs_class_id, TRUE), targetid = elemid->objid,
                   targetos = elemid->osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         loc_end);
        got = TRUE;
        }
      else
        {
        stat_OM = om$is_ancestry_valid (subclassid = elemclass, 
                   superclassid = OPP_EMSsubbs_class_id);
        if (stat_OM == OM_S_SUCCESS)
          {
          stat_OM = om$send (msg = message EMSsubbs.EMpassloop (&msg_loc, 
                     message EMSloopset.EMlsgetbdry (&msg_loc,
                     mattyp, mat,
                     NULL, &partolbas, opts,
                     &num_polys, &xyzpolys, &uvpolys, NULL, NULL, NULL)),
                     targetid = elemid->objid, targetos = elemid->osnum);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           loc_end);
          got = TRUE;
          }
        }

      if (got)
        {
        EFgetchar (stdout, "Print to file? (y/n) [n] ", &keyin);

        for (i=0; i<num_polys; i++)
          {
          stat_func = EFplace_line_string (NULL_OBJID, &constcv_list,
                       xyzpolys[i].num_points, xyzpolys[i].points, &linid,
                       &msg_loc);
          EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, loc_end);

          dpmode = GRbd;
          stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                     mattyp, mat, &dpmode, &elemenv->md_id), targetid = linid,
                     targetos = env->md_id.osnum);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           loc_end);

          if (toupper (keyin) == 'Y')
            polyfile (uvpolys[i].num_points, uvpolys[i].points);
          }
        }

      loc_end:
      if (xyzpolys)
        {
        for (i=0; i<num_polys; i++)
          if (xyzpolys[i].points)
            om$dealloc (ptr = xyzpolys[i].points);
        om$dealloc (ptr = xyzpolys);
        }
      if (uvpolys)
        {
        for (i=0; i<num_polys; i++)
          if (uvpolys[i].points)
            om$dealloc (ptr = uvpolys[i].points);
        om$dealloc (ptr = uvpolys);
        }
      }
      ME.ECelements->num_elems = 0;
      ME.ECelements->num_events= 0;
      break;

    default:
      stat_OM = OM_E_ABORT;
    }
  }
  while (TRUE);

ret_end:
  if (EMSerror (stat_OM))
    *response = TERMINATE;
  return (stat_OM);
}

/*--- STATIC FUNCTIONS: Inserted from EC31addrmfi.I ------------------------*/

static void FlipInsideOut
(
  PWosnum os,
  int num_dprs,
  PWobjid *dprs,
  PWboolean print_only,
  FILE *logfile,
  int *num_chged
)
{
  int i;
  PWresult result=PW_K_Success;
  struct s_addrmfix d_addrmfix;

  *num_chged = 0;

  d_addrmfix.num_chged = 0;
  d_addrmfix.print_only = print_only;
  d_addrmfix.logfile = logfile;

  for (i=0; i<num_dprs; i++)
  {
    fprintf (logfile, "\tProcessing DPR %d\n", dprs[i]);\

    result = pwTraverseCSfCSfs (dprs[i], os, TRUE, 
              (PWresult (*)()) addrmfix, (void *) &d_addrmfix);
    if (GetCode (result) ==  PW_K_Interrupt)
      goto wrapup;
  }

wrapup:
  *num_chged = d_addrmfix.num_chged;
  return;
}

static void CorrectOne
(
  PWosnum os,
  PWobjid node,
  FILE *logfile,
  int *num_chged
)
{
  struct s_addrmfix d_addrmfix;

  *num_chged = 0;

  d_addrmfix.num_chged = 0;
  d_addrmfix.print_only = FALSE;
  d_addrmfix.logfile = logfile;

  addrmfix (node, os, (void *) &d_addrmfix);
  *num_chged = d_addrmfix.num_chged;

  return;
}


static PWresult addrmfix
(
  PWobjid csf,
  PWosnum os,
  void *args
)
{
  IGRlong msg;
  PWresult result=PW_K_Success;
  struct s_addrmfix *p_addrmfix;
  unsigned int type, info_size=0;
  struct EMSAddRm_RecompInfo recomp_info, *p_recomp_info;
  FILE *logfile;

  p_addrmfix = (struct s_addrmfix *) args;

  if (omIsAncestryValid 
       (omClassidFromObjid (csf, os), OPP_EMSsffeature_class_id))
  {
    result = om$send (msg = message EMSassoc.EMget_info (&msg, NULL,
              &type, &info_size, NULL), targetid = csf, targetos = os,
              senderid = PW_K_NullObjid);
    OnErrorCode (result, wrapup);

    if (type == EMS_ASSOC_FEATURE_ADD_MATERIAL ||    
        type == EMS_ASSOC_FEATURE_REMOVE_MATERIAL)
    {
      logfile = p_addrmfix->logfile;
  
      if (type == EMS_ASSOC_FEATURE_ADD_MATERIAL)
        fprintf (logfile, "\t  Add Material %d (", csf);
      else 
        fprintf (logfile, "\t  Remove Material %d (", csf);

      p_recomp_info = &recomp_info;
      result = om$send (msg = message EMSassoc.EMget_info (&msg, NULL,
                &type, &info_size, (char **) &p_recomp_info),
                targetid = csf, targetos = os, senderid = PW_K_NullObjid);
      OnErrorCode (result, wrapup);

      if (recomp_info.props & EMSAddRm_Project)
        fprintf (logfile, "Proj ");
      else if (recomp_info.props & EMSAddRm_Revolve)
        fprintf (logfile, "Rev ");
      else if (recomp_info.props & EMSAddRm_Skinned)
        fprintf (logfile, "Skin ");
      else
        fprintf (logfile, "??? ");

      if (recomp_info.props & EMSAddRm_ToNext )
        fprintf (logfile, "ToNxt ");
      else if (recomp_info.props & EMSAddRm_FromTo)
      {
        fprintf (logfile, "FromTo-");
        if (recomp_info.props & EMSAddRm_NoFromSurf)
          fprintf (logfile, "HasFromSf-");
        else
          fprintf (logfile, "NoFromSf-");

        if (recomp_info.props & EMSAddRm_NoToSurf)
          fprintf (logfile, "HasToSf ");
        else
          fprintf (logfile, "NoToSf ");
      }
      else if (recomp_info.props & EMSAddRm_Finite)
      {
        fprintf (logfile, "Finite-");
        if (recomp_info.props & EMSAddRm_Symmetric)
          fprintf (logfile, "Symm ");
        else
          fprintf (logfile, "Oneside ");
      } 
      else if (recomp_info.props & EMSAddRm_ThruAll)
        fprintf (logfile, "ThruAll ");
      else
        fprintf (logfile, "??? ");

      if (recomp_info.props & EMSAddRm_MatInside)
        fprintf (logfile, "MatInside ");
      else
        fprintf (logfile, "MatOutside ");
     
      if (recomp_info.props & EMSAddRm_ProfOpen)
        fprintf (logfile, "Open-profile");
      else
        fprintf (logfile, "Closed-profile");

      fprintf (logfile, ")\n");

      if (!p_addrmfix->print_only)
      {
        fprintf (logfile, "\t  *** Toggling Mat In/Out flag ***\n");
        if (recomp_info.props & EMSAddRm_MatInside)
          recomp_info.props &= ~EMSAddRm_MatInside;
        else
          recomp_info.props |= EMSAddRm_MatInside;
        result = om$send (msg = message EMSassoc.EMput_info (&msg, NULL,
                  type, info_size, (char *) &recomp_info), 
                  targetid = csf, targetos = os, senderid = PW_K_NullObjid);
        OnErrorCode (result, wrapup);

        p_addrmfix->num_chged++;
      }
    } 
  }

wrapup:
  return (PW_K_Success);
}

/*--- End Insert ----------------------------------------------------------*/

end implementation ECtest;
