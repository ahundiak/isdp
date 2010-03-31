/*
  DESCRIPTION

    Solely meant for use by the Debuggers, Inc. If this file is meant for
    your eyes, the chances are, you already know all about it. Hence,
    no more need be said. 

  NOTES

   To add a message to the library such that it can now be invoked by a call
   to the function EMdebug_send:
     i) make the suitable addition to the file EMSmsgfile found in the
        model/src_util directory. To the bottom of this file add the line:
           classname.msgname key
        for example: 
           EMSedge.EMset_props 2
        N.B: The key should be a unique number on which a switch statement
        must case. If the defining class name is used, there is
        no confusion to a third person using it.
    ii) If the message has to be imported, include the import statement in
        this file.
   iii) Also, put in a defined constant below which names the key you
        used. Heaven forbid, if this file has to be debugged, it improves
        readability.
    iv) In the switch statement, do your thing. 
   Dynamic loadability of this method gives some flexibility.

   Some functions at the top of the file are provided to do some
   oft repeated tasks. Set the parametric tolerances, get part-edge
   information, etc. Please add similar things after these functions.

  HISTORY

    SS  :  03/08/88  :  Creation
    SS  :  03/11/88  :  Modified to make the addition of message-keys a
                        little better.
   Jack :  07/02/93  :  Added EMSdpr.EMgetSSI message send.
*/

class implementation EMSloopset;

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "EMSlmdef.h"
#include "EMSobjmgrdef.h"
#include "madef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "emsinter.h"
#include "emssfint.h"
#include "emsdattyp.h"
#include "bserr.h"
#include "bsparameters.h"

struct locgetshobj
  {
  IGRint numobjs;
  GRobjid *objs;
  };

/*
 * Locally global memory for use within this
 * method.
 */

static IGRchar _filename[50];
static IGRshort _mattyp;

%safe
static short first_time = TRUE;
%endsafe

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;


#define EMSloop_EMlpinit		0
#define EMSedge_EMptloc			1
#define EMSedge_EMsetprops		2
#define EMSloop_EMsetprops		3
#define EMSedge_EMdisplay		4
#define GRgraphics_GRdisplay		5
#define GRcurve_GRendpts		6
#define EMSsubbs_EMmake_frt		7
#define Root_delete			8
#define EMSedge_EMputpygeom		9
#define EMSedge_EMset_type		10
#define EMSloopset_EMpt_location 	11
#define EMSloopset_EMlsparttrim		12
#define EMSloop_EMpt_location		13
#define EMSloop_EMmodify_edge		14
#define Read_curve_and_call_math	15
#define Read_surface_and_call_math	16
#define EMSboundary_EMvalidate		17
#define EMSsurface_EMvalidate		18
#define Validate_msc_objects		19
#define EMSedge_EMptproject		20
#define EMSedge_EMstroke_iso_edge	21
#define EMSloop_EMptinside		22
#define Change_msc_watermark		23
#define EMSedge_EMgetvtxedges		24
#define EMSsubbs_EMgetbsdef		25
#define EMSedge_EMgetsurface_info       26
#define EMSsurface_EMgetactiveid        27
#define EMSdpr_EFget_roots              28
#define EMSdpr_EFget_roots_and_batch    29
#define EMSsubbs_EMpartolbasis		30
#define EMSdpr_EMgetSSI                 31
#define Root_wild_disconnect            32
#define GRgraphics_GRcopy	        33

from EMSloop import EMlpinit, EMset_props, EMpt_location, EMmodify_edge, 
		    EMptinside;
		
from EMSedge import EMpt_location, EMset_props, EMdisplay, EMset_type, 
		    EMptproject, EMstroke_iso_edge, EMget_props, 
		    EMgetvtxedges;
from EMSsurface import EMgetactiveid;

from EMSdpr  import EMgetSSI;

from GRcurve import GRendpts;

from GRvg import GRgetsymb, GRputsymb;

from EMSsubbs import EMmake_frt, EMgetbsdef, EMpartolbasis;
from EMSedge import EMputpygeom;
from EMSobjmgr import EMvalidate;
from EMSshobjmgr import EMgetshobj, EMgetwatermark, EMchgwatermark;
from OMObjSpace import pass;

extern GRclassid OPP_EMSloopset_class_id;
extern OMuword OPP_EMSsolid_class_id, OPP_EMSsurface_class_id;

extern EFget_roots();
extern EFget_roots_and_batch();

static void getptolbasis (ptolbas)
struct EMSpartolbasis *ptolbas;
{
  IGRchar keyin;

  EFgetchar (stderr, "Get tolerance from the surface ? [n] ", &keyin);
  if (toupper (keyin) == 'Y')
    {
    ptolbas->is_valid = FALSE;
    ptolbas->in_world = TRUE;
    _mattyp = MAIDMX;
    ptolbas->mattyp = (IGRshort *) &_mattyp;
    ptolbas->mat = NULL;
    }
  else
    {
    printf ("Tolerance _: ");
    scanf ("%lf", &ptolbas->tol);
    ptolbas->is_valid = TRUE;
    }
}


static IGRboolean prtmsgnames()
{
  IGRboolean stat_func;
  IGRchar msgname[40];
  IGRint msgkey;
  FILE *datfile;
  
  if(first_time)
   strcpy (_filename, "../../model/src_util/EMSmsgfile");
  first_time = FALSE;
  datfile = fopen (_filename, "r");
  if (!datfile)
    {
    printf ("Message filename _: ");
    scanf ("%s", _filename);
    datfile = fopen (_filename, "r");
    }

  if (datfile)
    {
    printf ("Currently, the sendable messages are:\n");
    while (fscanf (datfile, "%s %d", msgname, &msgkey) != EOF)
      printf ("%d: %s\n", msgkey, msgname);
    printf ("To add to the list, see EMlsdbgsend.I\n\n");
    fclose (datfile);
    stat_func = TRUE;
    }
  else
    {
    fprintf (stderr, "%s cannot be opened\n", _filename);
    fprintf (stderr, "Check this path\n");
    stat_func = FALSE;
    first_time = TRUE;
    }

  return (stat_func);
}

static IGRboolean getpygeom (dim, pygeom)
IGRshort dim;
struct IGRpolyline *pygeom;
{
  IGRboolean stat_func;
  IGRchar keyin, filename[20];
  IGRint i, num_points;
  FILE *datfile;

  stat_func = FALSE;
  datfile = stdin;

  EFgetchar (stderr, "Get geometry from a file ? [n] ", &keyin);
  if (toupper (keyin) == 'Y')
    {
    printf ("Filename _: ");
    scanf ("%s", filename);
    datfile = fopen (filename, "r");
    if (!datfile)
      {
      fprintf (stderr, "Error opening file\n");
      goto ret_end;
      }
    fscanf (datfile, "%d", &num_points);
    }
  else
    {
    printf("Num Points-> ");
    scanf("%d", &num_points);
    }

  if (!pygeom->num_points || !pygeom->points || 
      pygeom->num_points<num_points)
    {
    pygeom->points = (IGRdouble *) om$malloc (size = num_points *
                      dim * sizeof(IGRdouble));
    if (!pygeom->points)
      goto ret_end;
    }
  for (i=0; i<num_points; i++)
    {
    if (datfile == stdin)
      printf ("Point %d) ", i+1);
    if (dim == 2)
     fscanf (datfile, "%lf %lf", &pygeom->points[2*i], 
      &pygeom->points[2*i+1]);
    else if (dim == 3)
     fscanf (datfile, "%lf %lf %lf", &pygeom->points[2*i], 
      &pygeom->points[2*i+1], &pygeom->points[2*i+2]);
    else
     goto ret_end;
    }
  pygeom->num_points = num_points;
  stat_func = TRUE;

ret_end:
  if (datfile != stdin)
    fclose (datfile);
  return (TRUE);
}


static IGRboolean getshells (numobjs, objs, objstruct)
IGRint numobjs;
GRobjid *objs;
struct locgetshobj *objstruct;
{
  IGRint blksize;

  blksize = numobjs + objstruct->numobjs;
  if (!objstruct->objs)
    objstruct->objs = (GRobjid *) om$malloc (size = blksize *
                       sizeof (GRobjid));
  else
    objstruct->objs = (GRobjid *) om$realloc (size = blksize *
                       sizeof (GRobjid), ptr = (char *)objstruct->objs);
  if (!objstruct->objs)
    return (FALSE);
  else
    {
    OM_BLOCK_MOVE (objs, &objstruct->objs[objstruct->numobjs], numobjs *
     sizeof (GRobjid));
    objstruct->numobjs += numobjs;
    return (TRUE);
    }
}

static IGRint getkey()
{
  IGRboolean search;
  IGRint inkey, msgkey, filekey;
  IGRchar msgname[40];
  FILE *datfile;

  msgkey = MAXINT;
  printf ("Input message index _: ");
  scanf ("%d", &inkey);
  datfile = fopen (_filename, "r");
  if (datfile)
    {
    search = TRUE;
    while (search)
      {
      if (fscanf (datfile, "%s %d", msgname, &filekey) != EOF)
        {
        if (inkey == filekey)
          {
          msgkey = filekey;
          search = FALSE;
          }
        }
      else
        search = FALSE;
      }
    fclose (datfile);
    }
  else
    printf ("%s open failure\n", _filename);

  return (msgkey);
}

static long getchannel (prompt, chan)
char *prompt;
OM_S_CHANSELECT *chan;
{
  int chaninx;

  printf ("GRconnector.to_owners          0\n");
  printf ("GRcmpowner.to_components       1\n");
  printf ("GRnotify.notification          2\n");
  printf ("EMSrequester.to_helpers        3\n");
  printf ("EMShelper.to_requesters        4\n");
  printf ("EMSsubbs.to_loopset            5\n");
  printf ("EMSloopset.to_surface          6\n");
  printf ("EMSloopset.to_loops            7\n");
  printf ("EMSloop.to_outter              8\n");
  printf ("EMSloop.to_inner               9\n");
  printf ("EMSbd.owner_to_comps           10\n");
  printf ("EMSedge.to_owner               11\n");
  printf ("EMSedge.to_common_edge         12\n");
  printf ("EMSfeaturelp.to_surface        13\n");
  printf ("EMScleaner.to_objmgr           14\n");
  printf ("EMSobjmgr.to_cleaner           15\n");
  printf ("EMSshovflow.to_shobjmgr        16\n");
  printf ("EMSshobjmgr.to_overflow        17\n");
  printf ("EMSxsection.to_model           18\n");
  printf ("EMSsfspltwsf.to_mirror_image   19\n");
  printf ("module.primary                 20\n");
  printf ("GRgrset.to_owners              21\n");
  printf ("ci.executor_to_graphic         22\n");
  printf ("NDfather.father                23\n");
  printf ("NDchildren.children            24\n");
  printf ("SKconstraint.to_mgr            25\n");
  printf ("SKconstraint.to_variables      26\n");
  printf ("SKconstraint.to_super_constrs  27\n");
  printf ("SKgeometry.to_defpts	          28\n");
  printf ("SKinterface.to_member_constrs  29\n");
  printf ("SKmgr.to_vars                  30\n");
  printf ("SKmgr.to_constrs               31\n");
  printf ("SKvariable.to_constraints      32\n");
  printf ("SKvariable.to_geometries       33\n");
  printf ("SKvariable.to_mgr	          34\n");
  printf ("\n");
  printf ("%s", prompt);
  scanf ("%d", &chaninx);
  return (EMmake_chanselect (chaninx, chan));
}


method EMdebug_send(IGRlong *msg)
{
  IGRshort idmattyp;
  IGRint toos;
  IGRlong stat_OM, msg_loc;
  IGRmatrix idmat;  
  GRobjid toobj, fromobj;
  void EMidmatrix();
  IGRint msgkey;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Some useful data that might be generic enough to be
   * useful in atleast more than one case.
   */

  EMidmatrix (&msg_loc, &idmattyp, idmat);

  while (TRUE)
  {
  printf ("Targetid (0, to terminate) _: ");
  scanf ("%d", &toobj);
  if (!toobj)
    break;

  printf ("Targetos _: (0, for current os) _: ");
  scanf ("%d", &toos);
  if (!toos)
    toos = OM_Gw_current_OS;

  printf ("Senderid (0, if no big deal) _: ");
  scanf ("%d", &fromobj);
  if (!fromobj) 
    fromobj = NULL_OBJID;

  EMerr_hndlr (!prtmsgnames(), *msg, EMS_E_Fail, ret_end);
  switch (msgkey = getkey())
    {
    case EMSdpr_EMgetSSI:
      {
        /*
         * This code will allow you to specify a dpr state and look at
         * its save state information(SSI).  This is helpful since just
         * sending a debug to the object will not yield all of the SSI.
         */       

        union EMSssi_table            *ssi = NULL;
        struct EMSboolssi_table       *my_info = NULL;
                        
        stat_OM = om$send (msg = message EMSdpr.EMgetSSI (&msg_loc, &ssi), 
                      targetid = toobj, targetos = toos, senderid = fromobj);
       
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
                                                           
        my_info = &ssi->bool_info;
                                                                       
        /*
         * Stop here in debug and look at my_info
         */

         break;

      }

    case EMSsubbs_EMpartolbasis:
      {
      IGRboolean world=TRUE;
      IGRshort mattyp;
      IGRdouble ptol;
      IGRmatrix mat;

      EMidmatrix (&msg_loc, &mattyp, mat);
      stat_OM = om$send (msg = message EMSsubbs.EMpartolbasis (&msg_loc,
                 &mattyp, mat, &world, TRUE, &ptol),
                 targetid = toobj, targetos = toos, senderid = fromobj);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
      printf ("Surface parametric tolerance _: %9.14e\n", ptol);
      }
      break;
    case EMSloop_EMlpinit:
      {
      IGRushort props;
      IGRint propsi;
      struct EMSpartolbasis ptolbas;

      printf ("Props in _: 0x");
      scanf ("%x", &propsi); props = propsi;
      getptolbasis (&ptolbas);
      stat_OM = om$send (msg = message EMSloop.EMlpinit (&msg_loc, props,
                 &ptolbas, NULL), targetid = toobj, targetos = toos,
                 senderid = fromobj);
      }
      break;
    case EMSedge_EMptloc:
      {
      IGRdouble point[2];
      struct EMSptloc_info location;
      struct EMSpartolbasis ptolbas;
 
      printf ("Point for location _: ");
      scanf ("%lf %lf", &point[0], &point[1]);
      getptolbasis (&ptolbas);
      stat_OM = om$send (msg = message EMSedge.EMpt_location (&msg_loc,
                 point, &location, NULL, &ptolbas), targetid = toobj,
                 targetos = toos, senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end)
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      printf ("\tlocation is %d\n", location.location);
      }
      break;
    case EMSloop_EMsetprops:
      {
      IGRint option, propsi;
      IGRushort props;

      printf ("Option (EMSopt.h) _: ");
      scanf ("%d", &option);
      printf ("Props _: 0x");
      scanf ("%x", &propsi); props = propsi;
      stat_OM = om$send (msg = message EMSloop.EMset_props (&msg_loc, 
                 props, option), targetid = toobj, targetos = toos,
                 senderid = fromobj);
      }
      break;
    case EMSedge_EMsetprops:
      {
      IGRint option, propsi;
      IGRushort props;

      printf ("Option (EMSopt.h) _: ");
      scanf ("%d", &option);
      printf ("Props _: 0x");
      scanf ("%x", &propsi); props = propsi;
      stat_OM = om$send (msg = message EMSedge.EMset_props (&msg_loc, 
                 props, option), targetid = toobj, targetos = toos,
                 senderid = fromobj);
      }
      break;
    case EMSedge_EMdisplay:
      {
      IGRshort dispflag;
      enum GRdpmode dispmode;
      IGRint junk;

      dispmode = GRhd;
      /*dispflag = EMS_WHL_EDGE;*/
      printf ("Display Flag (EMSlmdef.h)(0 for whole edge) _: ");
      scanf ("%d", &junk);
      dispflag = junk;
      stat_OM = om$send (msg = message EMSedge.EMdisplay (&msg_loc,
                 NULL, &idmattyp, idmat, &dispmode, NULL,
                 dispflag, NULL), targetid = toobj, targetos = toos,
                 senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
      break;
    case GRgraphics_GRdisplay:
      {
      IGRint bytes_in, bytes_out;
      enum GRdpmode dispmode;
      struct GRmd_env mdenv;
      struct GRsymbology symb;

      bytes_in = sizeof (struct GRmd_env);
      gr$get_module_env (msg = &msg_loc, sizbuf = &bytes_in, buffer = &mdenv,
       nret = &bytes_out);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      om$send (msg = message GRvg.GRgetsymb (&msg_loc, &symb),
       targetid = toobj, targetos = toos, senderid = fromobj);
      symb.display_attr.weight += 2;
      om$send (msg = message GRvg.GRputsymb (&msg_loc, &symb),
       targetid = toobj, targetos = toos, senderid = fromobj);

      dispmode = GRbd;
      om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
       &mdenv.md_env.matrix_type, mdenv.md_env.matrix,
       &dispmode, &mdenv.md_id), targetid = toobj,
       targetos = toos, senderid = fromobj);

      symb.display_attr.weight -= 2;
      om$send (msg = message GRvg.GRputsymb (&msg_loc, &symb),
       targetid = toobj, targetos = toos, senderid = fromobj);
      }
      break;
    case GRcurve_GRendpts:
      {
      IGRpoint startpt, stoppt;

      stat_OM = om$send (msg = message GRcurve.GRendpts (&msg_loc,
                 &idmattyp, idmat, startpt, stoppt), targetid = toobj,
                 targetos = toos, senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      
      printf ("Start point : %lf, %lf, %lf\n", startpt[0], startpt[1],
       startpt[2]);
      printf ("Stop point : %lf, %lf, %lf\n", stoppt[0], stoppt[1],
       stoppt[2]);
      break;
      }

    case EMSsubbs_EMgetbsdef:
      {
      GRobjid srfid;
      struct IGRbsp_surface srf;

      printf("Surf id _: ");
      scanf ("%d", &srfid);
      stat_OM = om$send (msg = message EMSsubbs.EMgetbsdef (&msg_loc, &srf), 
                 targetid = srfid, targetos = toos, senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      prtbsps_def (&srf);
      break;
      }

    case EMSsubbs_EMmake_frt:
      {
	GRobjid		loopid = NULL_OBJID;
	
	printf("P loop id-> ");
	scanf("%d", &loopid);
	stat_OM = om$send(msg = message EMSsubbs.EMmake_frt(&msg_loc, loopid), 
				targetid = toobj, targetos = toos, 
				senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      break;
      }
    case Root_delete:
      {
	stat_OM = om$send(msg = message Root.delete(TRUE), 
				targetid = toobj, targetos = toos, 
				senderid = fromobj);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        break;
      }
    case Root_wild_disconnect:
      {
        int i;
        OM_S_CHANSELECT chan;

        printf ("Disconnect objects from %d [%d]:\n", toobj, toos);

        for (i=0; i<2; i++)
        {
          stat_OM = getchannel ("Channel _: ", &chan);
          if (EMSerror (stat_OM))
          {
            printf ("Channel not found. Pick again\n");
            continue;
          }
        }
        EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);

	stat_OM = om$send (msg = message Root.wild_disconnect (chan), 
                   targetid = toobj, targetos = toos, senderid = fromobj);
        EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_OMerror, ret_end);
        break;
      }
    case EMSedge_EMputpygeom:
      {
	IGRint		before_ptinx, i = 0;
	IGRboolean	reverse = FALSE, check_constraints = FALSE;
	struct IGRpolyline	pygeom;
	struct EMSpartolbasis partolbasis;
	
	printf("Before Ptinx (starting at 0)-> ");
	scanf("%d", &before_ptinx);
	printf("Reverse? (1/0)-> ");
	scanf("%d", &i);
	reverse =  i ? TRUE : FALSE;
	
	if (!getpygeom (2, &pygeom))
          {
          *msg = EMS_E_Fail;
          goto ret_end;
          }
		
	printf("Check Partedge Constraints? (1/0)-> ");
	scanf("%d", &i);
	check_constraints = i ? TRUE : FALSE;
	
	getptolbasis(&partolbasis);
	stat_OM = om$send(msg = message EMSedge.EMputpygeom
			(msg, before_ptinx, reverse, &pygeom, 
			 check_constraints, &partolbasis, NULL,
			 NULL, &idmattyp, idmat), 
			targetid = toobj, targetos = toos, 
			senderid = fromobj);
	if(pygeom.points) om$dealloc(ptr = pygeom.points);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        break;
      }
    case EMSedge_EMset_type:
      {
	IGRuchar	type = 0;
	IGRint			junk = 0;
	
	printf("Edge Type-> ");
	scanf("%d", &junk);
	type = junk;
	stat_OM = om$send(msg = message EMSedge.EMset_type(msg, type), 
				targetid = toobj, targetos = toos, 
				senderid = fromobj);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        break;
      }
    case EMSloopset_EMpt_location:
    case EMSloop_EMpt_location:
      {
      IGRint i;
      IGRdouble uvpt[4];
      struct IGRpolyline pygeom;
      struct EMSpartolbasis ptolbas;
      struct EMSptloc_info ptloc_info;

      getptolbasis (&ptolbas);
      printf ("Tolerance - %7.12lf\n", ptolbas.tol);
      pygeom.num_points = 2;
      pygeom.points = uvpt;

      if (!getpygeom (2, &pygeom))
        {
        *msg = EMS_E_Fail;
        goto ret_end;
        }
      printf ("Location point - %7.12lf, %7.12lf\n", uvpt[0], uvpt[1]);

      printf ("Options for point location _: 0x");
      scanf ("%x", &i);
      ptloc_info.options = i;

      if(msgkey == EMSloopset_EMpt_location)
       stat_OM = om$send (msg = message EMSloopset.EMpt_location (&msg_loc,
                 uvpt, &ptloc_info, &ptolbas), targetid = toobj,
                 targetos = toos, senderid = fromobj);
      else
       stat_OM = om$send (msg = message EMSloop.EMpt_location (&msg_loc,
                 uvpt, &ptloc_info, &ptolbas), targetid = toobj,
                 targetos = toos, senderid = fromobj);

      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      printf ("Location - %d\n", ptloc_info.location);
      printf ("Loop id - %d\n", ptloc_info.loop_id);
      printf ("Num located edges - %d\n", ptloc_info.num_located_edges);
      for (i=0; i<ptloc_info.num_located_edges; i++)
        {
        printf (" %d) Located edge - %d\n", i, ptloc_info.edge[i].edge_id);
        printf ("    Minimum distance - %7.12lf\n",
         ptloc_info.edge[i].nst_pt.dist);
        printf ("    Location on edge - %d\n",
         ptloc_info.edge[i].nst_pt.location);
        }
      }
      break;
    case EMSloopset_EMlsparttrim:
      {
      IGRint options, num_bdrys;
      struct IGRpolyline pygeom;
      struct EMSpartolbasis ptolbas;
      struct EMSdataselect data;
      struct EMSpypoint *bdrys;
      struct EMSsfintedpar *bdry_parms;
      extern void EMpypoint_free(), EMsfintedpar_free();

      getptolbasis (&ptolbas);
      pygeom.num_points = 0;
      pygeom.points = NULL;

      if (!getpygeom (2, &pygeom))
        {
        *msg = EMS_E_Fail;
        goto ret_end;
        }
      data.datatype = EMSdata_poly2d;
      data.data.poly = &pygeom;

      printf ("0x01 - BDRYISAREA\n0x02 - CUTTING\n0x10 - REMZEROEND\n");
      printf ("0x20 - MOREPRECISE\n0x200 - PROCOVERLAP\n");
      printf ("\nOptions for part trim _: 0x");
      scanf ("%x", &options);

      stat_OM = om$send (msg = message EMSloopset.EMlsparttrim (&msg_loc,
                 &data, &ptolbas, options, &num_bdrys, &bdrys, &bdry_parms),
                 targetid = toobj, targetos = toos, senderid = fromobj);
      om$dealloc (ptr = pygeom.points);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      if (num_bdrys)
        {
        prtpy (bdrys);
        prted (bdry_parms);
        EMpypoint_free (bdrys, MAXINT);
        EMsfintedpar_free (bdry_parms, MAXINT);
        }
      else
        printf ("No boundaries returned\n");
      }
      break;
    case EMSloop_EMmodify_edge:
      {
      IGRboolean update_range;
      IGRint i, genint, num_edges;
      IGRlong option;
      GRobjid edges[5], ref_edge;

      printf ("EMS_INS_AFTER - 1\nEMS_INS_BEFORE - 2\nEMS_INS_REPLACE - 3\n");
      printf ("EMS_INS_ATBEGIN - 4\nEMS_INS_ATEND - 5\n");
      printf ("EMS_DEL_EDGE_RESTORE_LOOP - 6\n");
      printf ("\nOption (1/2/3/4/5/6) _: ");
      scanf ("%d", &option);
      if (option > 6 || option < 1)
        break;

      if (option == EMS_DEL_EDGE_RESTORE_LOOP)
        {
        printf ("Num replacement edges (Max 5) _: ");
        scanf ("%d", &num_edges);
        if (num_edges > 5)
          break;
        }
      else
        num_edges = 1;

      for (i=0; i<num_edges; i++)
        {
        printf ("Edge %d) _: ");
        scanf ("%d", &edges[i]);
        }

      if (option != EMS_INS_ATBEGIN && option != EMS_INS_ATEND)
        {
        printf ("Reference edge _: ");
        scanf ("%d", &ref_edge);
        }
      else
        ref_edge = NULL_OBJID;

      printf ("Update range? (1/0) _: ");
      scanf ("%d", &genint);
      update_range = genint;

      stat_OM = om$send (msg = message EMSloop.EMmodify_edge (&msg_loc,
                 option, num_edges, ref_edge, edges, update_range),
                 targetid = toobj, targetos = toos, senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_LoopError, ret_end);
      break;
      }

    case Read_curve_and_call_math:
    case Read_surface_and_call_math:
      {
      IGRboolean stat_func;
      IGRchar filename[30];
      IGRint i;
      struct IGRbsp_curve cv;
      struct IGRbsp_surface sf;
      FILE *datfile;
      IGRboolean BSreadbspc(), BSreadbsps();
 
      cv.poles = NULL;
      cv.knots = NULL;
      cv.weights = NULL;
      cv.bdrys = NULL;

      sf.poles = NULL;
      sf.u_knots = NULL;
      sf.v_knots = NULL;
      sf.weights = NULL;
      sf.bdrys = NULL;

      printf ("Input data file _: ");
      scanf ("%s", filename);
      datfile = fopen (filename, "r");

      if (msgkey == Read_curve_and_call_math)
        stat_func = BSreadbspc (datfile, &cv);
      else
        stat_func = BSreadbsps (datfile, &sf);
      if (!stat_func)
        {
        fprintf (stderr, "Read failed\n");
        fclose (datfile);
        continue;
        }

      /*
       * Call the function you need to invoke and
       * print results. Do not forget to clean up
       * the mess before you leave (everything besides
       * the input curve/surface). On error please branch
       * to cleanup_cvsf.
       */

      {
      IGRint num_points;
      IGRlong msg_loc;
      IGRdouble *points, *params;
      extern void BSchtptstcv();

      points = NULL;
      params = NULL;
      BSchtptstcv (&cv, &num_points, &points, &params, &msg_loc);
      if (msg_loc != BSSUCC)
        fprintf (stderr, "Error - %d\n", msg_loc);
      else
        {
        fprintf (stderr, "num_points - %d\n", num_points);
        for (i=0; i<num_points; i++)
          fprintf (stderr, "%d) %7.12lf\n", i, params[i]);
        }

      if (points)
        om$dealloc (ptr = points);
      if (params)
        om$dealloc (ptr = params);
      }

    /*  cleanup_cvsf:  this label is no longer referenced */
      if (msgkey == Read_curve_and_call_math)
        {
        if (cv.poles)
          om$dealloc (ptr = cv.poles);
        if (cv.knots)
          om$dealloc (ptr = cv.knots);
        if (cv.weights)
          om$dealloc (ptr = cv.weights);
        if (cv.bdrys)
          om$dealloc (ptr = cv.bdrys);
        }
      else
        {
        if (sf.poles)
          om$dealloc (ptr = sf.poles);
        if (sf.u_knots)
          om$dealloc (ptr = sf.u_knots);
        if (sf.v_knots)
          om$dealloc (ptr = sf.v_knots);
        if (sf.weights)
          om$dealloc (ptr = sf.weights);
        if (sf.bdrys)
          { 
          for (i=0; i<sf.num_boundaries; i++)
            if (sf.bdrys[i].points)
              om$dealloc (ptr = sf.bdrys[i].points);
          om$dealloc (ptr = sf.bdrys);
          }
        }

      break;
      }

    case EMSboundary_EMvalidate:
    case EMSsurface_EMvalidate:
     {
      IGRint	autoc;
      IGRboolean issurf = FALSE, isbdry = FALSE;
      OMuword  gen_classid;
      struct GRmd_env env;
      IGRushort option = EMSvalidateEdgeMatch;
      GRobjid cancer = NULL_OBJID;

      env.md_env.matrix_type = idmattyp;
      OM_BLOCK_MOVE(idmat, env.md_env.matrix, sizeof(IGRmatrix));

      stat_OM = om$get_classid(objid = toobj, osnum = toos,
                  p_classid = &gen_classid);
      stat_OM = om$is_ancestry_valid(subclassid = gen_classid,
                                superclassid = OPP_EMSsolid_class_id);
      if (stat_OM == OM_S_SUCCESS) {option |= EMSvalidateSolid; issurf = TRUE;}
      else
       {
        stat_OM = om$is_ancestry_valid(subclassid = gen_classid,
                                superclassid = OPP_EMSsurface_class_id);
        if (stat_OM == OM_S_SUCCESS) issurf = TRUE;
	else isbdry = TRUE;
       }

      printf("Auto correct? (1/0)-> ");
      scanf("%d", &autoc);
      if(autoc) option |= EMSvalidateAutoCorrect;
      stat_OM = om$send(msg = message GRgraphics.EMvalidate(&msg_loc, &env, 
			    NULL, &cancer, &option, NULL, NULL),
                        targetid = toobj, targetos = toos, 
			senderid = fromobj);
      break;
     }

    case Validate_msc_objects:
      {
      IGRboolean found;
      IGRushort props;
      IGRint i, j, numobjs, numshobjs, osnum, severity;
      GRobjid osobj, shmgrobj, *shobjs, *objs;
      struct locgetshobj locgetshobj;
      OM_S_CLASSLIST classlist;

      objs = NULL;
      locgetshobj.objs = NULL;

      printf ("Object space to validate _: ");
      scanf ("%d", &osnum);

      stat_OM = om$osnum_to_oso_objid (osnum = osnum, p_objid = &osobj);
      EMomerr_exit (stat_OM, local_end);

      printf ("Object id of the shell-manager if known (else 0) _: ");
      scanf ("%d", &shmgrobj);
      if (!shmgrobj)
        {
        stat_OM = EMgetmgr (&msg_loc, osnum, OPP_EMSshobjmgr_class_id,
                   EMSshobj_sfbdry, &shmgrobj);
        EMomerr_exit (stat_OM, local_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, local_end);
        }

      /*
       * Send the validate message to the shell-manager
       */

      stat_OM = om$send (msg = message EMSobjmgr.EMvalidate (&msg_loc,
                 EMS_OBJMGR_LABELSPEC | EMS_OBJMGR_CORRECT, NULL, NULL,
                 &severity), targetid = shmgrobj, targetos = osnum,
                senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, local_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, local_end);

      fprintf (stderr, "Severity - %d\n", severity);

      /*
       * Validate all loopset-shells
       */

      printf ("Validate loopset shells ? (1/0) _: ");
      scanf ("%d", &i);
      if (i == 0)
        goto local_end;

      classlist.w_count = 1;
      classlist.w_flags = OM_CLST_subclass;
      classlist.p_classes = &OPP_EMSloopset_class_id;
      numobjs = 0;
      objs = NULL;
      stat_OM = om$send (msg = message OMObjSpace.pass (&classlist,
                 OM_e_wrt_object, message EMSboundary.EMreturn_my_id
                 (&msg_loc, &numobjs, &objs)), targetid = osobj,
                 targetos = osnum, senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, local_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, local_end);

      locgetshobj.numobjs = 0;
      stat_OM = om$send (msg = message EMSshobjmgr.EMgetshobj (&msg_loc,
                 OPP_EMSloopset_class_id, EMSshell_classvfunc, NULL,
                 NULL, (char *)&locgetshobj, getshells, NULL), 
                 targetid = shmgrobj,
                 targetos = osnum, senderid = NULL_OBJID);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      numshobjs = locgetshobj.numobjs;
      shobjs = locgetshobj.objs;

      for (i=0; i<numobjs; i++)
        {
        stat_OM = om$send (msg = message EMSloopset.EMget_props (&msg_loc,
                   &props), targetid = objs[i], targetos = osnum,
                   senderid = NULL_OBJID);
        EMomerr_exit (stat_OM, local_end);

        if (props & EMLS_SHELL)
          {
          found = FALSE;
          for (j=0; j<numshobjs; j++)
            if (objs[i] == shobjs[j])
              {
              objs[i] = NULL_OBJID;
              found = TRUE;
              break;
              }
          if (!found)
            fprintf (stderr, "Loopset with no shobjmgr entry - %d\n", objs[i]);
          }
        }

      for (i=0; i<numshobjs; i++)
        for (j=0; j<numobjs; j++)
          if (shobjs[i] == objs[j])
            fprintf (stderr, "Loopset in shobjmgr with no props - %d\n",
             shobjs[i]);

      local_end:
      if (objs)
        om$dealloc (ptr = objs);
      if (locgetshobj.objs)
        om$dealloc (ptr = locgetshobj.objs);
      }
      break;

    case Change_msc_watermark:
      {
      IGRint watermark;

      stat_OM = om$send (msg = message EMSshobjmgr.EMgetwatermark (&watermark),
                 targetid = toobj, targetos = toos, senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end);
      fprintf (stderr, "Current watermark %d\n", watermark);

      printf ("New watermark _: ");
      scanf ("%d", &watermark);

      stat_OM = om$send (msg = message EMSshobjmgr.EMchgwatermark (watermark),
                 targetid = toobj, targetos = toos, senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end);
      break;
      }

    case EMSedge_EMptproject:
      {
      IGRdouble uvpt[4];
      struct EMSproj_info proj_info;
      struct EMSpartolbasis ptolbas;
      struct IGRpolyline pygeom;

      getptolbasis (&ptolbas);
      printf ("Tolerance - %7.12lf\n", ptolbas.tol);
      pygeom.num_points = 2;
      pygeom.points = uvpt;

      if (!getpygeom (2, &pygeom))
        {
        *msg = EMS_E_Fail;
        goto ret_end;
        }
      printf ("Projection point - %7.12lf, %7.12lf\n", uvpt[0], uvpt[1]);

      stat_OM = om$send (msg = message EMSedge.EMptproject (&msg_loc,
                 uvpt, 1, &proj_info, NULL, &ptolbas), targetid = toobj,
                 targetos = toos, senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      printf ("proj_pt - %7.12lf, %7.12lf\n", proj_info.proj_pt[0], 
					      proj_info.proj_pt[1]);
      printf ("dist - %7.12lf\n", proj_info.dist);
      printf ("param - %d %7.12lf\n", proj_info.param.span_inx, 
				    proj_info.param.param);
      printf ("tangent - %7.12lf, %7.12lf\n", proj_info.tangent[0], 
					      proj_info.tangent[1]);
      printf ("location - %d\n", proj_info.location);
      }
      break;

    case EMSedge_EMstroke_iso_edge:
     {
      struct EMSpartolbasis	ptolbas;
      IGRint i, junk = 0;
      struct IGRpolyline	geom;
      IGRushort		props = NULL;

      stat_OM = om$send (msg = message EMSedge.EMget_props (&msg_loc, &props), 
                 targetid = toobj, targetos = toos, senderid = fromobj);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      if(props & EMED_ISO)
       {
        getptolbasis (&ptolbas);
        printf ("Tolerance - %7.12lf\n", ptolbas.tol);
        printf("Update instance data? (1/0)-> ");
        scanf("%d", &junk);
        geom.points = NULL;
        geom.num_points = 0;
        stat_OM = om$send (msg = message EMSedge.EMstroke_iso_edge (&msg_loc,
                 idmat, &idmattyp, NULL, NULL, FALSE, &ptolbas, toobj, 
                 &geom, junk), targetid = toobj, targetos = toos,
                 senderid = fromobj);
        EMomerr_exit (stat_OM, ret_end);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
        printf("Stroked geometry - \n");
        for (i=0; i<geom.num_points; i++)
         printf ("\tPoint %2d) %5.12lf %5.12lf\n", i, geom.points[i*2], 
						     geom.points[i*2+1]);
        if(geom.points) om$dealloc(ptr = geom.points);
       }
      else
       printf("This aint an iso edge\n");
      break;
     }

    case EMSloop_EMptinside:
      {
      IGRint i;
      IGRdouble uvpt[2], dist;
      struct EMSpartolbasis ptolbas;

      getptolbasis (&ptolbas);
      while(TRUE)
       {
        printf ("Callinx(-1 to termiate)-> ");
        scanf ("%d", &i);
        if(i==-1) break;

        stat_OM = om$send (msg = message EMSloop.EMptinside(&msg_loc,
                            (OMuint *)&i, &ptolbas, 1, uvpt, &dist), 
                          targetid = toobj, targetos = toos, senderid = fromobj);
	if(!(1&msg_loc&stat_OM))
	 {
	  EMWRAPUP(msg_loc, stat_OM, "No Point Found");
	  msg_loc = EMS_S_Success;
	  stat_OM = OM_S_SUCCESS;
	 }
	else
	 {
          printf("Point - %7.12lf, %7.12lf\n", uvpt[0], uvpt[1]);
          printf("Mindist - %7.12lf\n", dist);
         }

       }

      }
      break;

    case EMSedge_EMgetvtxedges:
     {
      GRobjid		*edges = NULL;
      IGRint		num_edges = 0, i;
      IGRboolean	*is_rightend = NULL, right_vtx, include_deg, 
			include_onlydominant;
      
      printf("right_vtx(1/0)->");
      scanf("%d", &i);
      right_vtx = i ? TRUE : FALSE;

      printf("include_degenerate(1/0)->");
      scanf("%d", &i);
      include_deg = i ? TRUE : FALSE;

      printf("include_onlydominant(1/0)->");
      scanf("%d", &i);
      include_onlydominant = i ? TRUE : FALSE;

      stat_OM = om$send (msg = message EMSedge.EMgetvtxedges(&msg_loc,
                 include_deg ? NULL : EMSvtxedges_nodegenerate |
                 include_onlydominant ? NULL : EMSvtxedges_onlydominant,
                 right_vtx, 0, &num_edges, &edges, &is_rightend), 
                 targetid = toobj, targetos = toos, senderid = fromobj);
      if((1&msg_loc&stat_OM))
       {
	printf("Edgeid		is_rightend\n");
	for(i=0; i<num_edges; i++)
	 printf("%d        %d\n", edges[i], is_rightend[i]);
       }
      if(edges) om$dealloc(ptr = edges);
      if(is_rightend) om$dealloc(ptr = is_rightend);

     }
    break;

    case EMSedge_EMgetsurface_info:
     {
      GRobjid sfid = NULL_OBJID;
      
      stat_OM = om$send (msg = message EMSedge.EMgetsurface_info
                 (&msg_loc, &sfid, NULL),
                 targetid = toobj, targetos = toos, senderid = fromobj);
      if((1&msg_loc&stat_OM))
       printf("Surface id of this edge is %d\n", sfid);
      else printf("ERROR GETTING THE SURFACE ID\n");
     }
    break;
    
    case EMSsurface_EMgetactiveid:
     {
      struct GRid active_id,
                  top_lm_id;
      

      stat_OM = om$send (msg = message EMSsurface.EMgetactiveid
                 (&msg_loc, &active_id, &top_lm_id),
                 targetid = toobj, targetos = toos, senderid = fromobj);
      if((1&msg_loc&stat_OM))
       printf("Active state GRid of surface is id=%d..os=%d\n", active_id.objid,active_id.osnum);
      else printf("ERROR GETTING THE ACTIVE STATE GRid\n");
       
     }
    break;

    case EMSdpr_EFget_roots:
     {
      IGRint   num_roots = 0;
      GRobjid *roots     = NULL;
      IGRint   ii        = 0;
      
      /*
       * get the root nodes for the parent(toos, toobj)
       */
      stat_OM = EFget_roots( &msg_loc,
                              toos,
                              toobj,
                             &num_roots,
                             &roots);
                       
      if((1&msg_loc&stat_OM))
       for(ii=0; ii < num_roots; ii++)
        {
          printf("For parent %d--root nbr %d id=%d..os=%d\n", 
                            toobj, ii, roots[ii], toos);         
        }
      else printf("ERROR GETTING ROOTS FOR THE GIVEN PARENT\n");
     }
    break;

    case EMSdpr_EFget_roots_and_batch:
     {
      struct GRid  loc_GRid;
      
      loc_GRid.osnum = toos;
      loc_GRid.objid = toobj;

      /*
       * get the roots for the given parent(toos,toobj)
       * and put them on the batch.  then the batch will
       * reexecute.  this routine calls EFget_roots().
       */
      stat_OM = EFget_roots_and_batch( &msg_loc,
                                       &loc_GRid);
      if((1&msg_loc&stat_OM))
       printf("EFget_roots_and_batch IS COMPLETE\n");
      else printf("ERROR GETTING THE ROOTS AND BATCHING THEM\n");
       
     }
    break;

    
    case GRgraphics_GRcopy:
      {
      IGRlong stat;
      struct GRmd_env mdenv;
      GRobjid newobj;

      gr$get_module_env (buffer = &mdenv);

      stat = om$send (msg = message GRgraphics.GRcopy (&msg_loc, &mdenv, 
              &mdenv, &newobj), 
              targetid = toobj, targetos = toos, senderid = fromobj);
      
      if (EMSerror (stat & msg_loc))
        fprintf (stderr, "Unsuccessful GRcopy\n");
      else
        {
        fprintf (stderr, "Successful GRcopy\n");
        fprintf (stderr, "New objid = %d\n", newobj);       
        }
      }
      break;

    default:
      printf ("This message aint goin nowhere\n");
    }
  }

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMSloopset.EMdebug_send");
  return (stat_OM);
}

end implementation EMSloopset;
