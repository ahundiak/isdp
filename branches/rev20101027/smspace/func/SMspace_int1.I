/* $Id: SMspace_int1.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMspace_int1.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMspace_int1.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/12/16  15:31:24  pinnacle
# TR_179802025: method SMCrtSfBnd, added variable, lmsg
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/10  14:52:40  pinnacle
# Replaced: smspace/func/SMspace_int1.I for:  by impd for vds
#
# Revision 1.1  1997/10/29  22:29:48  pinnacle
# TR179701957
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/29/97	ah		TR179701987 Ref files not working
 *					Moved SMCrtSfBnd to SMspace_int1.I
 *					Copy support surface to active file
 *	12/15/98	ejm	TR_179802025: Modify Bounded Surface
 *				If command fails, original surface disappears.
 *				Failure error msg not passed back.	
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include <string.h>
%safe
#include <math.h>
%endsafe

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "parametric.h"
#include "asmacros.h"
#include "exmacros.h"

#include "bstypes.h"
#include "bserr.h"
#include "bsconic.h"

#include "emsdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "EMSssprops.h"
#include "EMSmsgdef.h"
#include "EMS.h"
#include "EMSopt.h"
#include "emssfintdef.h"
#include "VDSutil_def.h"
#include "macro.h"
#include "AS_status.h"
#include "SMgraph.h"
#include "SMmsg.h"
#include "VDmem.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"

/* include prototype */

#include "bsprptoncv.h"
#include "bsdistptpt.h"
#include "bspl_pl.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsmdstptcv.h"
#include "bsmdistcvcv.h"
#include "bsmdistptcv.h"
#include "bsmdistptsf.h"
#include "bsptlngen.h"
#include "bscvcv_int.h"
#include "bscveval_b.h"
#include "bscvarrevt.h"
#include "bsprj_cv_pl.h"
#include "bstst_plan.h"
#include "bsavgpts.h"
#include "bscvcoplan.h"
#include "bscollin.h"
#include "bsconstprcv.h"
#include "bsorthovec.h"

/* #define   DEBUG 	1*/

/*#define OFF_DEBUG	1*/ 

#define   AS_DEBUG	1
#define   ORDER	2

#define VD_DEBUG

#include "VDdebug.h"

from GRvg		import	GRgetgeom, GRgetsize, GRdetplane, GRprojpt,
				EMintplane,GRcenter;
from EMSsubbs		import	EMtangent_normal, EMget_props, EMreduce_range,
				EMset_props;
from GRgraphics		import	GRgetrang, GRdelete, GRconstruct, GRcopy, GRdisplay;
from GRowner		import	GRget_number_components,GRget_components,GRdrop ;
from EMSplane		import	EMplane, EMplane_of_curve;
from GRcurve		import	GRrevparm;
from EMSproject		import	EMplace_surface_of_projection;
from EMSsurface		import	EMoffset, EMimpose_boundaries,
				EMgetactiveid, EMputLsIfNotThere;
from EMSsfboolean	import	EMboolean;
from EMSdpr		import	EMmake_primitive1;
from EMSsfstitch	import	EMmake_comp;
from ASnode		import	ASreturn_go;
from EMSsolid		import	EMorient_yourself;
from EMSsfdpr		import	EMgetsolidclass;

extern GRclassid	OPP_EMSplane_class_id, OPP_EMSsurface_class_id,
			OPP_GRcurve_class_id,OPP_EMScompsurf_class_id,
			OPP_EMSsubbs_class_id,OPP_EMSsfimpbnd_class_id,
			OPP_EMSproject_class_id,OPP_GRbcsubbc_class_id,
			OPP_EMSsfboolean_class_id, OPP_GRgrgrp_class_id,
			OPP_EMSsfstitch_class_id;

/*19 ====================== SMCrtSfBnd ==========================

	Function that creates the bounded surface if given the
	templates.

	Call SMSurfBnd.

	return(1) if ok.
	else return(0).

*/

int	SMCrtSfBnd(msg, nb_sf, surfs, infinite,  offset, ordered, rev_sup,
			track_id,md_env,  cst, bnd_id)
long			*msg;       /* (O) completion code */
int			nb_sf;      /* (I) nb input objects */
struct GRid		*surfs;     /* (I) input surfaces */
unsigned int		infinite;   /* (I) infinite info (bit0 for surf0)*/
IGRdouble		offset;	    /* (I) offset */
IGRint			ordered;    /* (I) 1 for ordered input surface */
IGRint			rev_sup;    /* (I) 1 for reverse orient */
struct	GRid		*track_id;  /* (I) the track elt (NULL_OBJID if not) */
struct GRmd_env		*md_env;    /* (I) mod env */
struct GRvg_construct   *cst;	    /* (I) construction list */
struct	GRid		*bnd_id;    /* (O) constructed bounded surface */

/*.SMCrtSfBnd*/

{
  IGRlong		lmsg; /* TR_179802025 */
  IGRint		stat, i,ssize, count;
  struct GRlc_info	*lc_info, track_info;
  struct GRid		*list, obj;
  char			*inf_flag;
  IGRboolean		is_natural_normal;
  IGRshort		option;
  struct GRmd_env	act_env;
  IGRlong		sizebuf, nret;
  GRclassid		sfid_class;

  IGRuchar		props;

  struct GRid     cpyID;
  struct GRmd_env refENV;

  if(msg == NULL || nb_sf == 0 || surfs == NULL || track_id == NULL ||
     md_env == NULL || cst == NULL || bnd_id == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  __enterFunction ( name = "SMCrtSfBnd" );

  *msg = MSSUCC;

  list = NULL;
  lc_info  = NULL;
  inf_flag = NULL;
  track_info.module_info = *md_env;
  track_info.located_obj.objid = NULL_OBJID;
  track_info.located_obj.osnum = md_env->md_id.osnum;

  bnd_id->osnum = md_env->md_id.osnum;
  bnd_id->objid = NULL_OBJID;

  cpyID.objid = NULL_OBJID;

  lc_info = _MALLOC(nb_sf, struct GRlc_info);
  if(lc_info == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    *msg = MSFAIL;
    goto wrapup;
  }
  inf_flag = _MALLOC(nb_sf, char);
  if(inf_flag == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg     = msg,
		    sizbuf  = &sizebuf,
		    buffer  = &act_env,
		    nret    = &nret);

  /* get md_env and matrix of each surface and fill inf_flag */

  for(i=0;i<nb_sf;i++)
  {
    lc_info[i].module_info = *md_env;
    stat = om$send( msg = message ASnode.ASreturn_go(
						     &lc_info[i].located_obj,
						     &lc_info[i].module_info.md_env.matrix_type,
						     lc_info[i].module_info.md_env.matrix),
		    senderid = NULL_OBJID,
		    targetid = surfs[i].objid,
		    targetos = surfs[i].osnum );
    if (!(stat&1)) lc_info[i].located_obj = surfs[i];

  }
  if(track_id->objid != NULL_OBJID)
  {
    stat = om$send( msg = message ASnode.ASreturn_go(
						     &track_info.located_obj,
						     &track_info.module_info.md_env.matrix_type,
						     track_info.module_info.md_env.matrix),
		    senderid = NULL_OBJID,
		    targetid = track_id->objid,
		    targetos = track_id->osnum );
    if (!(stat&1)) track_info.located_obj = *track_id;
  }
  SMGetInfFrmMask(nb_sf, infinite, inf_flag);

#ifdef	DEBUG
  printf("set env_info to 21,2 to be in range tree........\n");
  cst->env_info->md_id.objid = 21;
#endif

/*
 * TR179701957 
 * If the support surface is in a reference file, make a copy of it
 * and feed that to the rest of the mess 
 */
  if (lc_info[0].located_obj.osnum != act_env.md_id.osnum) {

    refENV             = lc_info[0].module_info;
    refENV.md_id.osnum = lc_info[0].located_obj.osnum;

    ex$get_modid(
      mod_osnum =  refENV.md_id.osnum, 
      mod_id    = &refENV.md_id.objid
    );
 
    cpyID.osnum = act_env.md_id.osnum;

    stat = om$send(
      msg = message GRgraphics.GRcopy(
         msg,
	&refENV, 
        &act_env,
	&cpyID.objid
      ),
      senderid = NULL_OBJID,
      targetid = lc_info[0].located_obj.objid,
      targetos = lc_info[0].located_obj.osnum
    );
    as$status(sts=stat);
    if (!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRcopy of support surface to active file\n");
      *msg = MSFAIL;
      goto wrapup;
    }
    lc_info[0].located_obj = cpyID;
    lc_info[0].module_info = act_env;
    // printf("Copied support surface to active os\n");
  }

  stat = SMSurfBnd( msg, nb_sf, &act_env, lc_info, &track_info, inf_flag,
		    ordered, rev_sup, cst, &obj);
  if(!(stat & (*msg )& 1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR SMSurfBnd\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  stat = om$send( msg = message EMSsubbs.EMget_props(msg, &props),
		  senderid = NULL_OBJID,
		  targetid = obj.objid,
		  targetos = obj.osnum );

  as$status(sts=stat);

  if (!((*msg)&stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR in .EMget_props\n");
    *msg = MSFAIL;
    goto wrapup;
  }

  bnd_id->objid = obj.objid; /* in case no offset done */

  if(fabs(offset) > 0.000001)
  {

#ifdef	OFF_DEBUG
    printf("offset = %lf \n",offset);
#endif

    /*
     * test the object offset normal - adz 09/14/94
     */

    {
      if( offset < 0 )
      {
	is_natural_normal = FALSE;
	offset = fabs( offset );
      }
      else	is_natural_normal = TRUE ;

#ifdef	OFF_DEBUG
      printf("is_natural_normal = %d\n",is_natural_normal);
#endif

      if(props & EMSIS_NRML_REVERSED)
      {
	if(is_natural_normal) is_natural_normal = FALSE;
	else		      is_natural_normal = TRUE;
      }

#ifdef	OFF_DEBUG
      printf("props = %d set is_natural_normal = %d\n",props,is_natural_normal);
#endif

    }

    /*
     * offset the bounded surf
     */

    /* PL sept 94 need to set the option otherwise EMoffset does not take*/
    /* the boundaries.							*/

#ifdef	OFF_DEBUG
    printf("call EMoffset with offset = %lf, is_natural_normal = %d\n",offset,is_natural_normal);
    printf("obj to offset: %d, %d  \n", obj.objid, obj.osnum);
#endif

    bnd_id->objid =  NULL_OBJID;
    option = EMS_opt_offsetS_copy_topology ;

    stat = om$send( msg = message EMSsurface.EMoffset(
						      msg,
						      option,
						      &md_env->md_env.matrix_type,
						      md_env->md_env.matrix,
						      cst,
						      is_natural_normal,
						      offset,
			      /** new arguments ..	*/
						      0,
						      NULL,
						      NULL,

						      0,
						      NULL,
						      NULL,
						      &bnd_id->objid,
						      NULL ),
		    senderid = NULL_OBJID,
		    targetid = obj.objid,
		    targetos = obj.osnum );
    as$status(sts=stat);
    if (!(stat & (*msg) & 1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR  EMSsurface.EMoffset \n");
      *msg = MSFAIL;
      goto wrapup;
    }
  }

  if(props & EMSIS_NRML_REVERSED)
  {
    stat = om$send(msg = message EMSsubbs.EMset_props(msg,
						      EMSIS_NRML_REVERSED, EMS_O_ON),
		   senderid = NULL_OBJID,
		   targetid = bnd_id->objid,
		   targetos = bnd_id->osnum);
    as$status(sts = stat);
    if(!((*msg)&stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR in EMSsubbs.EMset_props\n" );
      *msg = MSFAIL;
      goto wrapup;
    }
  }

  /* reverse normal */

  if(rev_sup)
  {
    stat = om$get_classid (objid = bnd_id->objid,
			   osnum = bnd_id->osnum,
			   p_classid = &sfid_class);
    if (!(stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR  om$get_classid \n");
      *msg = MSFAIL;
      goto wrapup;
    }

    stat = om$is_ancestry_valid (subclassid = sfid_class,
				 superclassid = OPP_EMSsubbs_class_id);

    if (stat == OM_S_SUCCESS)
    {
      stat = om$send(msg = message EMSsubbs.EMset_props(msg,
							EMSIS_NRML_REVERSED,
							EMS_O_TOGGLE),
		     senderid = NULL_OBJID,
		     targetid = bnd_id->objid,
		     targetos = bnd_id->osnum);
      as$status(sts=stat);
    }
    else
    {
      stat = om$send( msg = message GRowner.GRget_number_components
		      (msg, &ssize),
		      senderid = NULL_OBJID,
		      targetid =  bnd_id->objid,
		      targetos =  bnd_id->osnum );
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRowner.GRget_number_components\n");
	*msg = MSFAIL;
	goto wrapup;
      }
      list = _MALLOC(ssize, struct GRid);
      if(list == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	*msg = MSFAIL;
	goto wrapup;
      }
      count = 0;
      stat = om$send(msg = message GRowner.GRget_components(
							    msg,
							    &act_env,
							    list,
							    ssize,
							    &count,
							    0,
							    OM_K_MAXINT),
		     senderid = NULL_OBJID,
		     targetid = bnd_id->objid,
		     targetos = bnd_id->osnum);
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in  GRowner.GRget_components \n");
	*msg = MSFAIL;
	goto wrapup;
      }
      for (i=0;i<ssize;i=i+1)
      {
	stat = om$send(msg = message EMSsubbs.EMset_props(msg,
							  EMSIS_NRML_REVERSED,
							  EMS_O_TOGGLE),
		       senderid = NULL_OBJID,
		       targetid = list[i].objid,
		       targetos = list[i].osnum);
	as$status(sts=stat);
      }
    }
  }

  _FREE(list);

  /* don't delete obj if no offset done */

  if(obj.objid != NULL_OBJID && fabs(offset) > 0.000001  )
  {
    stat = om$send(msg      = message GRgraphics.GRdelete(msg,
							  md_env),
		   senderid = NULL_OBJID,
		   targetid = obj.objid,
		   targetos = obj.osnum );
    as$status(sts=stat);
    obj.objid = NULL_OBJID;
  }

wrapup:

  _FREE(list);
  if (!(*msg)&1)
  {
    om$send(msg      = message GRgraphics.GRdelete(&lmsg, &act_env),
	    senderid = NULL_OBJID,
	    targetid = bnd_id->objid,
	    targetos = bnd_id->osnum );
    bnd_id->objid = NULL_OBJID;
  }
  _FREE(lc_info);
  _FREE(inf_flag);

  // Delete copied support surface
  if (cpyID.objid != NULL_OBJID) {
    stat = om$send(
      msg = message GRgraphics.GRdelete(&lmsg, &act_env),
      senderid = NULL_OBJID,
      targetid = cpyID.objid,
      targetos = cpyID.osnum
    );
  }
/*
  if( bnd_id->objid != NULL_OBJID )
  {
    enum   GRdpmode		mode = GRbd;

    gr$get_module_env(msg     = &lmsg,
		      sizbuf  = &sizebuf,
		      buffer  = &act_env,
		      nret    = &nret);

//    stat = dp$display ( msg = msg, mode = GRbd, oids = bnd_id );
    stat = om$send( msg     = message GRgraphics.GRdisplay(
							  &lmsg,
							  &act_env.md_env.matrix_type,
							   act_env.md_env.matrix,
							  &mode,
							  &act_env.md_id ),
		    senderid= NULL_OBJID,
		    targetid= bnd_id->objid,
		    targetos= bnd_id->osnum ) ;
  }
*/
  __exitFunction ( name = "SMCrtSfBnd" );

  return OM_S_SUCCESS;
}

/*3 ======================  SMint_support1 ======================

	like SMint_support but keep only the first intersection cv

	return(1) if ok.
	else return(0).
*/

int	SMint_support1(msg, nb_surf, surf, cst, infinite, nb_inters, inters,
			SMcurve, typesf)
long			*msg;		/* (O) completion code */
int			nb_surf;	/* (I) nb surf to intersect */
struct GRlc_info	*surf;		/* (I) input surfaces */
struct GRvg_construct   *cst;		/* (I) construction list  */
char			*infinite;	/* (I) flag for each surf */
int			*nb_inters;	/* (O) nb intersections returned */
struct SMsfinters	**inters;	/* (O) intersections returned */
struct SMcurve		**SMcurve;	/* (O) only to fill geom */
int			*typesf;	/* (O) return type of surf */
/*.SMint_support1*/
{
  int			i,j,k,l, stat, tnb_inters, tnb_alloc, tmp,nb_sf1,
			type_flag,int_flag, elem_type[2],num_pts, num_inter,
			count, nb_obj, n_pla, i_alloc;
  IGRboolean		world, err_flag;
  struct SMsfinters	*tinters;
  IGRdouble		plane_space[12], fact, range[6], obj_range[6],q[3],
			u[3],v1[3],v2[3], coef, basis_tol;
  struct IGRplane	plane[2];
  struct GRvg_construct tmp_cst;
  BSrc			rc;
  struct IGResbc	curve_specific;
  IGRushort		trim;
  long			nput, nret, size;
  struct GRid		*OBJECT, *GRint, *COMP;
  char			running[DI_PATH_MAX];
  GRclassid		obj_classid;

  GRint = NULL;
  tinters = NULL;
  tnb_inters = 0;
  OBJECT = NULL;
  COMP = NULL;
  fact = 0.;

  if(nb_surf < 2 || surf == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR Invalid argument\n");
    return(0);
  }

  __enterFunction ( name = "SMint_support1" );

  if(msg != NULL) *msg = MSSUCC;
  err_flag = FALSE;
  if(inters != NULL) *inters = NULL;

  plane[0].point  = &plane_space[0];
  plane[0].normal = &plane_space[3];
  plane[1].point  = &plane_space[6];
  plane[1].normal = &plane_space[9];

  nput = sizeof(basis_tol);

  gr$get_basis_tolerance(	msg    = msg,
				sizbuf = &nput,
				buffer = &basis_tol,
				nret   = &nret);

  if(!((*msg)&1))
  {
    if (OM_Gf_verbose_warning) printf("error gr$get_basis_tolerance\n");
    err_flag = TRUE;
    goto wrapup;
  }

  tnb_alloc = 2*nb_surf;
  tinters = _MALLOC (tnb_alloc, struct SMsfinters);
  if(tinters == NULL)
  {
    if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
    err_flag = TRUE;
    goto wrapup;
  }
  for(i_alloc=0;i_alloc<tnb_alloc;i_alloc++) tinters[i_alloc].cv_geom = NULL;

  for(i=0;i<nb_surf;i++)
  {
    if(i==0)
    {
      world = TRUE;
      stat = om$send( msg = message GRgraphics.GRgetrang(msg,
							 &surf[i].module_info.md_env.matrix_type,
							 surf[i].module_info.md_env.matrix,
							 &world, range),
		      senderid = NULL_OBJID,
		      targetid = surf[i].located_obj.objid,
		      targetos = surf[i].located_obj.osnum );

      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang\n" );
	err_flag = TRUE;
	goto wrapup;
      }
    }
    else
    {
      world = TRUE;
      stat = om$send( msg = message GRgraphics.GRgetrang(msg,
							 &surf[i].module_info.md_env.matrix_type,
							 surf[i].module_info.md_env.matrix,
							 &world, obj_range),
		      senderid  = NULL_OBJID,
		      targetid = surf[i].located_obj.objid,
		      targetos = surf[i].located_obj.osnum );
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRgraphics.GRgetrang \n");
	err_flag = TRUE;
	goto wrapup;
      }
      for(k=0;k<3;k++)
      {
	if(range[k]   > obj_range[k]  )
	   range[k]   = obj_range[k];
	if(range[k+3] < obj_range[k+3])
	   range[k+3] = obj_range[k+3];
      }
    }
  } /* end for(i=0 ....) */

  if (infinite[0] != 'y' && infinite[0] != 'Y') type_flag = SURF;
  else						type_flag = PLAN;

  nb_sf1 = 0;
  stat = SMelem_(type_flag, &surf[0].located_obj,
		 surf[0].module_info.md_env.matrix_type,
		 surf[0].module_info.md_env.matrix,
		 &elem_type[0],
		 &plane[0], NULL, NULL, &nb_sf1);
  if (!(stat&1))
  {
    if (OM_Gf_verbose_warning) printf("ERROR fonction SMelem_\n");
    err_flag = TRUE;
    goto wrapup;
  }
  if(typesf != NULL) typesf[0] = elem_type[0];

  if(elem_type[0] == CURV)
  {
    if (OM_Gf_verbose_warning) printf("ERROR: support cannot be a curve\n");
    err_flag = TRUE;
    goto wrapup;
  }
  if(elem_type[0] == PLAN)
  {
    fact = 1.1 * (IGRdouble)BSdistptpt(&rc, range, &(range[3]));
    if(rc != BSSUCC)
    {
      if (OM_Gf_verbose_warning) printf("ERROR BSdistptpt,\n");
      err_flag = TRUE;
      goto wrapup;
    }
  }

  for(k=1;k<nb_surf;k++)
  {
    if (infinite[k] != 'y' && infinite[k] != 'Y') type_flag = SURF;
    else					  type_flag = PLAN;

    nb_sf1 = 0;
    stat = SMelem_(type_flag, &surf[k].located_obj,
		   surf[k].module_info.md_env.matrix_type,
		   surf[k].module_info.md_env.matrix,
		   &elem_type[1],
		   &plane[1], NULL, NULL, &nb_sf1);
    if (!(stat&1))
    {
      if (OM_Gf_verbose_warning) printf("ERROR fonction SMelem_\n");
      err_flag = TRUE;
      goto wrapup;
    }
    if(typesf != NULL) typesf[k] = elem_type[1];
    if(elem_type[1] == CURV)
    {
      if(tnb_inters >= tnb_alloc)
      {
	tmp = tnb_alloc + INCR_ALLOC;
	tinters = _REALLOC (tinters, tmp, struct SMsfinters);
	if(tinters == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	tnb_alloc = tmp;
      }
      tinters[tnb_inters].sf1 = -1;
      tinters[tnb_inters].sf2 = k;
      tinters[tnb_inters].cvint_id =  surf[k].located_obj;
      tinters[tnb_inters].cv_geom = NULL;
      tnb_inters ++;
      continue;
    }

    n_pla = 0;

    sprintf(running,"%s%d","intersect support with surface ",k);
    UI_status(running);

    if(elem_type[0] == PLAN) n_pla = 1;
    if(elem_type[1] == PLAN) n_pla = n_pla + 2;

    if( n_pla == 3 )
    {
      /*|plan/plan intersect */

      if(tnb_inters >= tnb_alloc)
      {
	tmp = tnb_alloc + INCR_ALLOC;
	tinters = _REALLOC (tinters,
			    tmp, struct SMsfinters);
	if(tinters == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	tnb_alloc = tmp;
      }
      tinters[tnb_inters].sf1 = 0;
      tinters[tnb_inters].sf2 = k;
      tinters[tnb_inters].cvint_id.objid = NULL_OBJID;
      tinters[tnb_inters].cv_geom = NULL;
      (void)BSpl_pl(plane[0].point, plane[0].normal,
		    plane[1].point, plane[1].normal,
		    &int_flag, q, u, &rc);
      if(rc != BSSUCC )
      {
	if (OM_Gf_verbose_warning) printf(" ERROR in BSpl_pl\n");
	err_flag = TRUE;
	goto wrapup;
      }
      if (int_flag != BSCINTERSECTING) continue;

      num_pts = 2;
      (void)BSalloccv(ORDER, num_pts, 0, 0,
		      &(tinters[tnb_inters].cv_geom), &rc);
      if(rc != BSSUCC && rc!=BSNULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }
      tinters[tnb_inters].cv_geom->planar = TRUE;
      tinters[tnb_inters].cv_geom->phy_closed = FALSE;
      tinters[tnb_inters].cv_geom->order     = ORDER;
      tinters[tnb_inters].cv_geom->num_poles = num_pts;
      tinters[tnb_inters].cv_geom->num_knots = num_pts + 2 * (ORDER - 1);

      /* Compute the end points of the line to do the intersection */

      (IGRboolean)BSmkvec(&rc, v1, range    , q);
      (IGRboolean)BSmkvec(&rc, v2, &range[3], q);

      if((IGRdouble)BSdotp(&rc,v1,v2) <= 0)
      {
	/*|The point of the infinit line is inside the range*/
      }
      else
      {
	/*|The point of the infinit line is not inside the range*/

	fact = fact + (IGRdouble)BSdistptpt(&rc, q, range);
      }

      for(l=0;l<3;l++)
      {
	tinters[tnb_inters].cv_geom->poles[l]   = q[l] - fact * u[l];
	tinters[tnb_inters].cv_geom->poles[l+3] = q[l] + fact * u[l];
	tinters[tnb_inters].cv_geom->knots[l+1] = (double) l/ (num_pts-1);
      }
      tinters[tnb_inters].cv_geom->knots[0]	    = 0;
      tinters[tnb_inters].cv_geom->knots[num_pts+1] = 1;
      tnb_inters ++;

      continue;
    }
    else if( n_pla == 0 )
    {
      /*===================================================*/
      /* general routine to intersect any type of element  */
      /*===================================================*/
      curve_specific.is_polydis = TRUE;
      curve_specific.is_curvedis = TRUE;
      GRint = NULL;
      tmp_cst = (*cst);
      tmp_cst.class_attr = (IGRchar *) &curve_specific;
      trim = EMSINT_TRIM_HANDLESTOP | NULL; /* trimming option */
      stat = EMintersect_two_element(	&(surf[0]),
					&(surf[k]),
					trim,
					&tmp_cst,
					&num_inter,
					&GRint,
					msg);
      as$status(sts = stat);
      if(!(stat & (*msg) & 1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in EMintersect_two_element\n");
	err_flag = TRUE;
	goto wrapup;
      }
    }
    else if( n_pla == 1 )
    {
      /*=========================================================*/
      /*  the first parent is a plane				 */
      /*=========================================================*/
      GRint = NULL;
      tmp_cst = (*cst);
      stat = om$send( msg      = message GRvg.EMintplane(
							 &tmp_cst,
							 &plane[0],
							 &surf[k],
							 &num_inter,
							 &GRint,
							 (int *)msg ),
		      senderid = NULL_OBJID,
		      targetid = surf[k].located_obj.objid,
		      targetos = surf[k].located_obj.osnum );
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRvg.EMintplane  \n");
	err_flag = TRUE;
	goto wrapup;
      }
    }
    else if( n_pla == 2 )
    {
      /*=========================================================*/
      /*  the second parent is a plane				 */
      /*=========================================================*/

      GRint = NULL;
      tmp_cst = (*cst);
      stat = om$send( msg      = message GRvg.EMintplane(
							 &tmp_cst,
							 &plane[1],
							 &surf[0],
							 &num_inter,
							 &GRint,
							 (int *)msg ),
		      senderid = NULL_OBJID,
		      targetid = surf[0].located_obj.objid,

		      targetos = surf[0].located_obj.osnum );
      as$status(sts=stat);
      if (!((*msg)&stat&1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR in GRvg.EMintplane  \n");
	err_flag = TRUE;
	goto wrapup;
      }
    }

    if(num_inter < 1) continue;
    num_inter = 1;

    for(l=0;l<num_inter;l++)
    {
      stat = om$get_classid(	osnum     = GRint[l].osnum,
				objid     = GRint[l].objid,
				p_classid = &obj_classid);
      if( om$is_ancestry_valid(subclassid   = obj_classid,
			       superclassid = OPP_GRgrgrp_class_id )
	  == OM_S_SUCCESS )
      {
	stat = om$send( msg = message GRowner.GRget_number_components
			(msg, &nb_obj),
			senderid = NULL_OBJID,
			targetid = GRint[l].objid,
			targetos = GRint[l].osnum );
	as$status(sts=stat);
	if (!((*msg)&stat&1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR in GRowner.GRget_number_components\n");
	  err_flag = TRUE;
	  goto wrapup;
	}

	if(nb_obj > 1) nb_obj = 1;
	OBJECT = NULL;
	OBJECT =  _MALLOC(nb_obj, struct GRid);
	if(OBJECT == NULL)
	{
	  if (OM_Gf_verbose_warning) printf("ERROR Bad dynamic allocation\n");
	  err_flag = TRUE;
	  goto wrapup;
	}

	tmp_cst = (*cst);
	stat = om$send( msg = message GRowner.GRget_components
			(msg, tmp_cst.env_info,OBJECT, nb_obj,
			 &count,0,nb_obj),
			senderid = NULL_OBJID,
			targetid = GRint[l].objid,
			targetos = GRint[l].osnum );
	as$status(sts=stat);
	if (!((*msg)&stat&1))
	{
	  if (OM_Gf_verbose_warning) printf("ERROR in GRowner.GRget_components \n");
	  err_flag = TRUE;
	  goto wrapup;
	}
	for(j=0;j<count;j++)
	{
	  if(tnb_inters >= tnb_alloc)
	  {
	    tmp = tnb_alloc + count * num_inter + 1;
	    tinters = _REALLOC (tinters,
				tmp, struct SMsfinters);
	    if(tinters == NULL)
	    {
	      if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	      err_flag = TRUE;
	      goto wrapup;
	    }
	    for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	    tnb_alloc = tmp;
	  }
	  tinters[tnb_inters].sf1 = 0;
	  tinters[tnb_inters].sf2 = k;
	  tinters[tnb_inters].cvint_id = OBJECT[j];
	  tinters[tnb_inters].cv_geom = NULL;
	  tnb_inters ++;
	}
	_FREE(OBJECT);
      }
      else
      {
	if(tnb_inters >= tnb_alloc)
	{
	  tmp = tnb_alloc + num_inter + 1;
	  tinters = _REALLOC ( tinters, tmp, struct SMsfinters);
	  if(tinters == NULL)
	  {
	    if (OM_Gf_verbose_warning) printf("ERROR bad reallocation\n");
	    err_flag = TRUE;
	    goto wrapup;
	  }
	  for(i_alloc=tnb_alloc;i_alloc<tmp;i_alloc++) tinters[i_alloc].cv_geom = NULL;
	  tnb_alloc = tmp;
	}
	tinters[tnb_inters].sf1 = 0;
	tinters[tnb_inters].sf2 = k;
	tinters[tnb_inters].cvint_id = GRint[l];
	tinters[tnb_inters].cv_geom = NULL;
	tnb_inters ++;
      }
    }
    _FREE(GRint);
  }

  for(i=0;i<tnb_inters;i++)
  {
    tinters[i].alloc_flag = TRUE;
    if(tinters[i].cv_geom == NULL)
    {
      tinters[i].alloc_flag = FALSE;

      tmp_cst = (*cst);
      stat = om$send(msg = message GRvg.GRgetsize(msg,
						  &((tmp_cst.env_info)->md_env.matrix_type),
						  (tmp_cst.env_info)->md_env.matrix,
						  &size ),
		     senderid = NULL_OBJID,
		     targetid = tinters[i].cvint_id.objid,
		     targetos = tinters[i].cvint_id.osnum );

      as$status(sts = stat);
      if(!(stat & (*msg) &1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetsize\n");
	err_flag = TRUE;
	goto wrapup;
      }

      tinters[i].cv_geom = (struct IGRbsp_curve *)_MALLOC(size, char);

      if(tinters[i].cv_geom == NULL)
      {
	if (OM_Gf_verbose_warning) printf("ERROR, Bad dynamic allocation \n");
	err_flag = TRUE;
	goto wrapup;
      }

      tmp_cst = (*cst);
      stat = om$send(msg = message GRvg.GRgetgeom(msg,
						  &((tmp_cst.env_info)->md_env.matrix_type),
						  (tmp_cst.env_info)->md_env.matrix,
						  (char *) tinters[i].cv_geom),
		     senderid = NULL_OBJID,
		     targetid = tinters[i].cvint_id.objid,
		     targetos = tinters[i].cvint_id.osnum );
      as$status(sts = stat);
      if(!(stat & (*msg) &1))
      {
	if (OM_Gf_verbose_warning) printf("ERROR GRvg.GRgetgeom\n");
	err_flag = TRUE;
	goto wrapup;
      }
      coef = 0;
      for(k=0;k<3;k=k+1)
	coef = coef + fabs(tinters[i].cv_geom->poles[k] -
			   tinters[i].cv_geom->poles[3*(tinters[i].cv_geom->num_poles-1)+k]);

      if (coef < basis_tol) tinters[i].cv_geom->phy_closed = TRUE;
      else	tinters[i].cv_geom->phy_closed = FALSE;
    }
  }

  if(nb_inters != NULL) *nb_inters = tnb_inters;
  if(inters != NULL && tnb_inters != 0)
  {
    *inters = NULL;
    *inters = _MALLOC(tnb_inters, struct SMsfinters);
    if( (*inters) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<tnb_inters;i++) (*inters)[i].cv_geom = NULL;
    for(i=0;i<tnb_inters;i++)
    {
      (*inters)[i].sf1 = tinters[i].sf1;
      (*inters)[i].sf2 = tinters[i].sf2;
      (*inters)[i].alloc_flag = tinters[i].alloc_flag;
      (*inters)[i].cvint_id = tinters[i].cvint_id;
      (*inters)[i].cv_geom = tinters[i].cv_geom;
    }
  }
  if(SMcurve != NULL && tnb_inters != 0)
  {
    *SMcurve = NULL;
    *SMcurve = _MALLOC(tnb_inters, struct SMcurve);
    if( (*SMcurve) == NULL)
    {
      if (OM_Gf_verbose_warning) printf("ERROR bad allocation\n");
      err_flag = TRUE;
      goto wrapup;
    }
    for(i=0;i<tnb_inters;i++)
    {
      (*SMcurve)[i].nb_intpt = 0;
      (*SMcurve)[i].pt_index = NULL;
      (*SMcurve)[i].cv_geom = tinters[i].cv_geom;
    }
  }

wrapup:

  UI_status("");
  _FREE(GRint);
  _FREE(OBJECT);
  _FREE(COMP);

  if(err_flag == TRUE)
  {
    if(tinters != NULL)
    {
      for(i=0;i<tnb_inters;i++)
      {
	if(tinters[i].cv_geom != NULL)
	{
	  if(tinters[i].alloc_flag == TRUE)
	    (IGRboolean)BSfreecv(&rc, tinters[i].cv_geom);
	  else _FREE(tinters[i].cv_geom);
	  tinters[i].cv_geom = NULL;
	}
      }
      _FREE(tinters);
    }
    if(inters != NULL && (*inters) != NULL)_FREE(*inters);
    __exit_error_Function ( name = "SMint_support1" );
    return(0);
  }
  _FREE(tinters);
  __exitFunction ( name = "SMint_support1" );
  return(1);
}

end implementation Root;
