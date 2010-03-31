/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"

/* pathway flags */
extern IGRboolean _pathway_trim, _pathway_orient;

from EMSedge import EMgetxyzobj;

method EMget_free_edge(IGRlong *msg;
		       struct GRlc_info *comp_sf)

/*
Abstract

    This method gets the list of free edges of from a composite surface.

Arguments

    *msg       IGRlong            error return code
    *comp_sf   struct GRlc_info   located composite surface

Notes
    EMS_S_Success    returns if all goes well
    EMS_E_Fail       returns if any error occurs

    It is assumed that all the component objects are individual single
    surfaces.

Files
    EMcsfedge.I

History
    JSY   10/06/92    Creation.
*/

{
  struct GRid *edges = NULL, *mscedges, tmpid, grpid;
  IGRint bufsiz = 0, num_edges = 0, i;
  struct GRmd_env md_env;
  GRobjid mscobj, cv_grps;
  struct EMSinters *inters;
  struct EMSdataselect xyzobj;
  IGRshort act_level;
  struct IGRdisplay act_display;
  struct GRvg_construct cnst;
  IGRlong msg_loc, status, sizbuf, nret;
  IGRboolean save_pathway_trim, save_pathway_orient;
  extern struct EMSintobj *EMmakeintlist();
  extern IGRlong EMintersect_surfaces();
  extern void EMinters_free();

  /*
   * Initalize
   */
  status = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  /* get all the edges of the outer boundaries */
  status = om$send(msg = message EMSsurface.EMgetedges(&msg_loc,
						       EMS_OPT_CONNECTABLE,
						       &edges,
						       &bufsiz,
						       &num_edges,
						       NULL,
						       NULL,
						       NULL,
						       NULL),
		   targetid = comp_sf->located_obj.objid,
		   targetos = comp_sf->located_obj.osnum);
  EMerr_hndlr(EMSerror(status), *msg, EMS_E_Fail, ret_end);
  
  sizbuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg = &msg_loc,
		    sizbuf = &sizbuf,
		    buffer = &md_env,
		    nret = &nret);
  
  mscedges = (struct GRid *) om$malloc(size = sizeof(struct GRid) * num_edges);
  EMerr_hndlr(!mscedges, *msg, EMS_E_NoDynamicMemory, ret_end);

  /* get each edge's model space counterpart */
  for (i = 0; i < num_edges; i++)
  {
    status = om$send(msg = message EMSedge.EMgetxyzobj(&msg_loc,
						       NULL,
						       &md_env.md_env,
						       NULL,
						       NULL,
						       NULL,
						       NULL,
						       OM_Gw_current_OS,
						       &mscobj),
		     targetid = edges[i].objid,
		     targetos = edges[i].osnum);

    status = om$send(msg = message GRgraphics.GRcopy(&msg_loc,
						     &md_env,
						     &md_env,
						     &mscedges[i].objid),
		     targetid = mscobj,
		     targetos = md_env.md_id.osnum);
    mscedges[i].osnum = md_env.md_id.osnum;
  }

  /* make inters list */
  inters = NULL;
  tmpid.objid = NULL_OBJID;
  tmpid.osnum = md_env.md_id.osnum;
  for (i = 0; i < num_edges; i++)
  {
    xyzobj.datatype = EMSdata_object;
    xyzobj.data.object = &mscedges[i];

    EMmakeintlist(&msg_loc,
		&inters,
		NULL,
		&tmpid,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		&xyzobj,
		NULL,
		NULL,
		FALSE,
		FALSE,
		NULL,
		NULL,
		NULL,
		NULL,
                NULL, 
                NULL,
		TRUE,
		FALSE);
  }

  /* set up construction argument */
  sizbuf = sizeof(IGRshort);
  gr$get_active_level(msg = &msg_loc,
		      sizbuf = &sizbuf,
		      buffer = &act_level,
		      nret = &nret);
  sizbuf = sizeof(struct IGRdisplay);
  gr$get_active_display(msg = &msg_loc,
			sizbuf = &sizbuf,
			buffer = &act_display,
			nret = &nret);
  cnst.msg = msg;
  cnst.newflag = 0;
  cnst.level = act_level;
  cnst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  cnst.display = &act_display;
  cnst.name = NULL;
  cnst.class_attr = NULL;
  cnst.env_info = &md_env;
  cnst.geometry = NULL;

  save_pathway_trim = _pathway_trim;
  save_pathway_orient = _pathway_orient;
  _pathway_trim = 0;
  _pathway_orient = 0;

  /* trace out free edge list and put it into graphic group */
  status = EMintersect_surfaces(&msg_loc,
				NULL,
				&md_env.md_env,
				0,
				NULL,
				NULL,
				EMS_SFINT_SKIPSFINT | EMS_SFINT_CHTTRACETOL,
				NULL,
				NULL,
				NULL,
				&cnst,
				NULL,
				&inters,
				NULL,
				NULL,
				NULL,
				&cv_grps,
				NULL,
				NULL);

  _pathway_trim = save_pathway_trim;
  _pathway_orient = save_pathway_orient;

  EMerr_hndlr(EMSerror(status), *msg, EMS_E_Fail, ret_end);

  /* display graphic group in highlight */
  grpid.objid = cv_grps;
  grpid.osnum = md_env.md_id.osnum;
  gr$display_object(object_id = &grpid,
		    mode = GRhd);

  /* free memory */
  if (mscedges)
    om$dealloc(ptr = mscedges);
  EMinters_free(inters, MAXINT);

ret_end:
  return(status);
}

end  implementation EMScompsurf;
