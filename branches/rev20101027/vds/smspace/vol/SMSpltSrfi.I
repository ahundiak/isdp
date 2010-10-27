/* $Id: SMSpltSrfi.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMSpltSrfi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSpltSrfi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/03/05  20:47:20  pinnacle
# Replaced: smspace/vol/SMSpltSrfi.I for:  by impd for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.5  1997/03/17  20:33:00  pinnacle
# Replaced: smspace/vol/SMSpltSrfi.I for:  by jwfrosch for vds.241
#
# Revision 1.4  1997/02/13  22:44:26  pinnacle
# Replaced: smspace/vol/SMSpltSrfi.I for:  by jwfrosch for vds.241
#
# Revision 1.3  1997/02/06  20:42:46  pinnacle
# Replaced: smspace/vol/SMSpltSrfi.I for:  by jwfrosch for vds.241
#
# Revision 1.2  1997/01/30  18:48:46  pinnacle
# Replaced: smspace/vol/SMSpltSrfi.I for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/01/24  20:06:26  pinnacle
# Replaced: ./smspace/vol/SMSpltSrfi.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	03/04/98	HF		FIX TR # 179800712 
 *					Crash if Parent is Bulkhead and its parents
 *					are ACpretend's i.s.o. ASsource's
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 16 Oct 92	  creation date.
/*	AZ  : 02 Dec 93	  EMS 3.0 correction on EMSsurface.EMoffset
/* */

class implementation SMSpltSrf;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"
#include "exmacros.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
/* #include "emssfintdef.h" */
#include "EMSopt.h"
#include "EMSssprops.h"

#include "bstypes.h"
#include "bserr.h"
#include "bsinv_mat.h"
#include "bstrfrhommx.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h"
#include "vdsmacros.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "AS_status.h"

#define VD_DEBUG

#include "VDdebug.h"

/*#define DEBUG	1*/

/*#define OFF_DEBUG	1 */

#define AS_DEBUG

from	EMSsfboolean	import	EMboolean;
from	EMSsurface	import	EMoffset;
from	EMSsubbs	import	EMset_props, EMget_props;
from	GRgencs		import	GRgetmatrix;
from	GRcurve		import	GRendpts;

extern GRclassid	OPP_SMLongBk_class_id,
			OPP_SMTransBk_class_id,
			OPP_SMLgCrgtBk_class_id,
			OPP_SMTrCrgtBk_class_id,
			OPP_SMbulkhead_class_id;

/* ****************** MSG ACmplace_from_def () ************************	*/

method ACmplace_from_def (	int		*rc, prop;
				char		 rep;
				char		*macro_name;
				int		 num_temp;
				struct GRid	*temp_list;
				struct GRid	*def_occ;
				struct GRmd_env	*md_env )

{
  IGRlong		status;

  /*
   * Put the properties to no proptect:
   - Does not create source,
   - Does not verify the number (variable number of templates)
   - Does not verify the template types
   */

  prop = prop | AChdr_noprotect | ACcant_place_sym;

  status = om$send (	msg	 = message ACncpx.ACmplace_from_def(rc, prop, rep,
								    macro_name, num_temp,
								    temp_list, def_occ, md_env),
			mode     = OM_e_wrt_message,
			targetid = my_id );

  return status ;
}


/* *********************** MSG GRgetobjinfo () ************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
  IGRlong		status, loc_msg;
  struct GRobj_env	Surf;
  IGRint		Type;

  /* Different printf out if foot is a plane, surface or solid */

  status = om$send (	msg	 = message NDmacro.ACreturn_foot(&loc_msg, "surf",
								 &Surf.obj_id,
								 &Surf.mod_env.md_env.matrix_type,
								  Surf.mod_env.md_env.matrix),
			targetid = my_id);
  if(!(status & loc_msg & 1))
  {
    /* Strange !!! */
    strcpy(info->type, "Split Object");
  }
  else
  {
    if(!(SMGetType(&Surf, &Type, FALSE) & 1))
    {
      strcpy(info->type, "Split Object");
    }
    else
    {
      if     (Type == PLAN)    strcpy(info->type, "Split Plane");
      else if(Type == SURF)    strcpy(info->type, "Split Surface");
      else if(Type == COMP_SF) strcpy(info->type, "Split Comp Surface");
      else if(Type == SOL)     strcpy(info->type, "Split Solid");
      else		       strcpy(info->type, "Split Object");
    }
  }
  *rc = MSSUCC;
  return	OM_S_SUCCESS;
}

/*
 *   Modif PL 06-29-93
 *	Kluddge waiting that the feet management is correctly done !!!!.
 */

method ACgive_path(int *suc;struct GRid *go_obj;char *foot_name)
{
  int			i, sts;
  struct GRid		pied;
  OM_S_CHANSELECT	chansel;

  chansel.type	     = OM_e_name;
  chansel.u_sel.name = "GRcmpowner.to_components";

  /**** must find pied see give_foot ****/
  pied.objid = NULL_OBJID;
  sts = om$get_objid_at_index (
			object		=  me,
			p_chanselect	= &chansel,
			index		=  0,
			objidaddr	= &pied.objid,
			osnumaddr	= &pied.osnum);

  if( (1&sts) && pied.objid != NULL_OBJID )
  {
    /*| get the index of the object go_obj*/
    get_index_of_surf(pied, &i, *go_obj );
    if( i != -1 )
    {
      sprintf(foot_name,"$%d", i );
      /*"ACgivepath, foot_name created: %s\n ",foot_name */
      return ( *suc =OM_S_SUCCESS );
    }
  }

  /*"ACgivepath failed, call normal message \n"*/
  return om$send (	msg	 = message ACncpx.ACgive_path
						(suc,go_obj,foot_name),
			targetid = my_id,
			mode	 = OM_e_wrt_message);
}

method ACreturn_foot (	long		*suc;
			char		*foot_name;
			struct GRid	*foot_GRid;
			IGRshort	*mat_type;
			IGRdouble	*matrix)
{
  int ix;	 /* index */
  int sts,loc_msg;
  OM_S_CHANSELECT chansel;
  struct GRid pied;

  *suc = 0;

  if( foot_name[0] != '$' )
  {
    return om$send (	msg	 = message ACncpx.ACreturn_foot
						( suc, foot_name, foot_GRid,
						  mat_type, matrix),
			targetid = my_id,
			mode	 = OM_e_wrt_message);
  }
  chansel.type = OM_e_name;
  chansel.u_sel.name = "GRcmpowner.to_components";

  /*
   *** must find real feet
   * we assume this is the 1st one on the channel to_component
   */
  pied.objid = NULL_OBJID;
  sts = om$get_objid_at_index(
			object		=  me,
			p_chanselect	= &chansel,
			index		=  0,
			objidaddr	= &pied.objid,
			osnumaddr	= &pied.osnum);
  if(!(1&sts) )
    return sts;
  if( pied.objid == NULL_OBJID )
    return *suc = 0;

  ix = -1;
  sscanf(&foot_name[1],"%d", &ix );
  if( !get_surf_at_index(pied, ix, foot_GRid ) )
    return *suc = 0;

  /*"ci_mac_bib.ACgive_foot, foot:%d %d\n",foot_GRid->objid,
    foot_GRid->osnum */

  if(mat_type) *mat_type = MAIDMX;
  if(matrix) MAidmx(&loc_msg,matrix);

  *suc = 1; /*return real graphic object */

  return(sts);
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef )
{
  long		sts ;	/* OM return code	*/

  /*
   * name.
   */
  myDef->info	= SM_I_ObjSpltSrf ;
  myDef->type	= 0 ;

  sts	= OM_S_SUCCESS ;
  *msg	= MSSUCC ;

  return sts ;

} /* method VDgetObjdDef */

/*----------------------------------------------------------------------------*/

#define MAX_SPLIT_SRF 14

/* ******************* MSG ACconstruct_feet () ************************	*/

method	ACconstruct_feet (	IGRlong		*rc;
				IGRint		 cn_type;
				IGRint		 count;
				struct GRid	 list[];
				struct GRmd_env *md_env;
				IGRint		*fcount;
				struct GRid	*feet_list )
{
  IGRboolean		PlanInf, SurfRev, SfInf, SfExt;
  IGRshort		level;
  IGRlong		status, loc_msg, sizebuf, nret;
  IGRint		i, k, NbSf, MyProps, Rev[MAX_SPLIT_SRF];
  IGRdouble		offset, offsav, fabs();
  IGRpoint		prnt_pnt;
  IGRmatrix		mtrx;
  int			VD_offset_before_intersect = FALSE, blkhead = 0, state = 0;

  struct GRvg_construct	cst;
  struct IGRdisplay	display;
  struct GRobj_env	crd_sys, Support, Sf[MAX_SPLIT_SRF];
  struct GRmd_env	my_env;
  struct ret_struct	str;
  struct GRid		NewSf, blkhd;

#define	OFFSET_MASK	0x1000

  __enterMethod ( name = "ACconstruct_feet" );

  feet_list[0].objid = NULL_OBJID;

  my_env = *md_env;
  my_env.md_id.objid = NULL_OBJID; /* Computation out of RTREE */

  //////////++++++++++
  status = om$send (	msg	 = message ACncpx.ACget_STATE( &state ),
			targetid = my_id );

  VD_offset_before_intersect = FALSE;
  if ( state & OFFSET_MASK )
  {
    VD_offset_before_intersect = TRUE;
  }
  __printf ( "my_id = %d, state = %#x, VD_offset_before_intersect = %d", `my_id, state, VD_offset_before_intersect` );
  //////////----------

  cst.msg	 = &loc_msg;
  cst.newflag	 = FALSE;
  cst.geometry	 = NULL;
  cst.env_info	 = &my_env;
  cst.class_attr = NULL;
  cst.name	 = NULL;
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;

  sizebuf = sizeof(struct IGRdisplay);
  gr$get_active_display(msg     = &loc_msg,
			sizbuf  = &sizebuf,
			buffer  = &display,
			nret    = &nret);

  /*| get the active level */
  sizebuf = sizeof(IGRshort);
  gr$get_active_level(msg     = &loc_msg,
		      sizbuf  = &sizebuf,
		      buffer  = &level,
		      nret    = &nret);
  cst.display    = &display;
  cst.level      = level;

  /* Get the expression mask */
  status = om$send (	msg	 = message NDnode.NDgive_structure(&loc_msg, &str, NULL),
			targetid = list[0].objid,
			targetos = list[0].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;

  MyProps = (IGRint) str.var.root_pm_st.value;
  if(MyProps & 0x8000) PlanInf = TRUE;
  else		       PlanInf = FALSE;

  if(MyProps & 0x4000) SurfRev = TRUE;
  else		       SurfRev = FALSE;

  if(MyProps & 0x10000) SfExt  = TRUE;  /* Splitting surfaces extended */
  else			SfExt  = FALSE;

  /* Get the offset */
  status = om$send (	msg	 = message NDnode.NDgive_structure(&loc_msg, &str, NULL),
			targetid = list[1].objid,
			targetos = list[1].osnum);
  if(!(status & loc_msg & 1)) goto wrapup ;
  offset = str.var.root_pm_st.value;
  offsav = offset;

  status = om$send (	msg	 = message NDnode.ASreturn_go(&Support.obj_id,
						    &Support.mod_env.md_env.matrix_type,
						    Support.mod_env.md_env.matrix),
			targetid = list[2].objid,
			targetos = list[2].osnum);
  if(!(status & 1)) goto wrapup ;
  Support.mod_env.md_id.objid = NULL_OBJID;
  Support.mod_env.md_id.osnum = Support.obj_id.osnum;

  //////////++++++++++ HF: BulkHead related modification
 /*
  * Check the Owner of the Support: If it is a BulkHead, get its 3 parent objects
  *	0) ASsource to active coord. system
  *	1) SMcoll   containing parameters (ignored)
  *	2) ASsource or possibly ACpretend to starting point of macro
  */
  blkhd = NULL_GRID;
  status = om$get_objid_at_index( objid		= Support.obj_id.objid,
				  osnum		= Support.obj_id.osnum,
				  index		= 0,
				  p_chanselect	= &AS_to_owner,
				  objidaddr	= &blkhd.objid,
				  osnumaddr	= &blkhd.osnum);
  if( status & 1 )
  {
    blkhead = (	DMancestry_valid ( blkhd, OPP_SMLongBk_class_id   ) ||
		DMancestry_valid ( blkhd, OPP_SMTransBk_class_id  ) ||
		DMancestry_valid ( blkhd, OPP_SMLgCrgtBk_class_id ) ||
		DMancestry_valid ( blkhd, OPP_SMLgCrgtBk_class_id ) ||
		DMancestry_valid ( blkhd, OPP_SMbulkhead_class_id ) );

    __printf ( ">>>>>blkhd = [%d,%d], blkhead = %d", `blkhd.osnum, blkhd.objid, blkhead` );

    if ( blkhead )
    {
      struct GRobj_env	ModObj;
      struct GRid	obj_lst[3];
      IGRint		count = 0;
      obj_lst[0] = obj_lst[1] = obj_lst[2] = NULL_GRID;

      status = om$send (msg	 = message NDnode.NDget_objects(
								ND_ROOT,
								obj_lst,
								3, NULL,
								0,
								2,
								&count),
			targetid = blkhd.objid,
			targetos = blkhd.osnum);

      if( ( !(status&1) )
	  || ( obj_lst[0].objid == NULL_OBJID )		// ASsource to active coord. system
	  || ( obj_lst[1].objid == NULL_OBJID )		// SMcoll (ignored)
	  || ( obj_lst[2].objid == NULL_OBJID ) )	// ASsource or ACpretend to starting point of macro
      {
	blkhead = FALSE;
	goto err_bulkhd;
      }

      //////////++++++++++ HF: 03/04/98 TR # 179800712 (Crash if Parent is ACpretend i.s.o. ASsource)

      /*
       * Get the Parent's graphics object : should return a "GRgencs"
       */

      status = om$send (msg	 = message NDmacro.ACreturn_foot(
						 &loc_msg,
						 "",
						 &ModObj.obj_id,
						 &ModObj.mod_env.md_env.matrix_type,
						  ModObj.mod_env.md_env.matrix ),
			targetid = obj_lst[0].objid,
			targetos = obj_lst[0].osnum);
      if(!(status & loc_msg & 1))
      {
	goto wrapup ;
      }

      ModObj.mod_env.md_id.osnum = ModObj.obj_id.osnum;

      status = ex$get_modid ( mod_osnum =  ModObj.mod_env.md_id.osnum,
			      mod_id    = &ModObj.mod_env.md_id.objid );

      __printf ( "obj_lst[0] = [%d,%d], ModObj.obj_id = [%d,%d]   CoordinateSys",
		 `obj_lst[0].osnum, obj_lst[0].objid, ModObj.obj_id.osnum, ModObj.obj_id.objid` );

      /*
       * Get the Parent's CoordinateSystem Matrix
       */
      status = om$send (	msg	 = message GRgencs.GRgetmatrix(&loc_msg, mtrx),
				targetid = ModObj.obj_id.objid,
				targetos = ModObj.obj_id.osnum);

      if(!(status & loc_msg & 1))
      {
	blkhead = FALSE;
	goto err_bulkhd;
      }

      __printf ( "	%lg  %lg  %lg  %lg", `mtrx[ 0], mtrx[ 1], mtrx[ 2], mtrx[ 3]` );
      __printf ( "	%lg  %lg  %lg  %lg", `mtrx[ 4], mtrx[ 5], mtrx[ 6], mtrx[ 7]` );
      __printf ( "	%lg  %lg  %lg  %lg", `mtrx[ 8], mtrx[ 9], mtrx[10], mtrx[11]` );
      __printf ( "	%lg  %lg  %lg  %lg", `mtrx[12], mtrx[13], mtrx[14], mtrx[15]` );

      //////////////////////////////////////////////////////////////////

      /*
       * Get the Parent's graphics object : should return a "GR3dpoint"
       */

      status = om$send (msg	 = message NDmacro.ACreturn_foot(
						 &loc_msg,
						 "",
						 &ModObj.obj_id,
						 &ModObj.mod_env.md_env.matrix_type,
						  ModObj.mod_env.md_env.matrix ),
			targetid = obj_lst[2].objid,
			targetos = obj_lst[2].osnum);
      if(!(status & loc_msg & 1))
      {
	goto wrapup ;
      }

      ModObj.mod_env.md_id.osnum = ModObj.obj_id.osnum;

      status = ex$get_modid ( mod_osnum =  ModObj.mod_env.md_id.osnum,
			      mod_id    = &ModObj.mod_env.md_id.objid );

      __printf ( "obj_lst[2] = [%d,%d], ModObj.obj_id = [%d,%d]   ParentPoint",
		 `obj_lst[2].osnum, obj_lst[2].objid, ModObj.obj_id.osnum, ModObj.obj_id.objid` );

      /*
       * Get the Parent's Point Coordinates
       */

      status = om$send (msg	 = message GRcurve.GRendpts(
						    &loc_msg,
						    &ModObj.mod_env.md_env.matrix_type,
						     ModObj.mod_env.md_env.matrix,
						     prnt_pnt,
						     prnt_pnt),
			targetid = ModObj.obj_id.objid,
			targetos = ModObj.obj_id.osnum);

      if(!(status & loc_msg & 1))
      {
	blkhead = FALSE;
	goto err_bulkhd;
      }

      __printf ( "%lg  %lg  %lg   ParentPoint", `prnt_pnt[0], prnt_pnt[1], prnt_pnt[2]` );

      //////////---------- HF: 03/04/98 TR # 179800712 (Crash if Parent is ACpretend i.s.o. ASsource)

      if ( blkhead )
      {
	status = om$send (	msg	 = message NDnode.ASreturn_go(
							&crd_sys.obj_id,
							&crd_sys.mod_env.md_env.matrix_type,
							 crd_sys.mod_env.md_env.matrix),
				targetid = obj_lst[0].objid,
				targetos = obj_lst[0].osnum);
	if(!(status & 1))
	{
	  blkhead = FALSE;
	  goto err_bulkhd;
	}
	crd_sys.mod_env.md_id.objid = NULL_OBJID;
	crd_sys.mod_env.md_id.osnum = crd_sys.obj_id.osnum;

	__printf ( "crd_sys.obj_id = [%d,%d]", `crd_sys.obj_id.osnum, crd_sys.obj_id.objid` );

      }
    }
  }

err_bulkhd:

  //////////----------

  if(count > 17) count = 17;
  k = 0;
  for(i=3;i<count;i++)
  {
    status = om$send (	msg	 = message NDnode.ASreturn_go(&Sf[k].obj_id,
						      &Sf[k].mod_env.md_env.matrix_type,
						      Sf[k].mod_env.md_env.matrix),
			targetid = list[i].objid,
			targetos = list[i].osnum);
    if(!(status & 1)) goto wrapup ;
    Sf[k].mod_env.md_id.objid = NULL_OBJID;
    Sf[k].mod_env.md_id.osnum = Sf[k].obj_id.osnum;

    if((1<<k) & MyProps) Rev[k] = TRUE;
    else		 Rev[k] = FALSE;
    k++;
  }
  SfInf = TRUE;  /* Splitting planar surfaces taken as infinit */

  //////////++++++++++
  if ( VD_offset_before_intersect == FALSE )
  {
    NbSf = count - 3;
    if ( ! ( SMBndS1BySfs (	&cst, &Support, PlanInf,
				NbSf, Sf, Rev, SfInf, SfExt,
				SurfRev, &NewSf) & 1) ) goto wrapup;
  }
  //////////----------

 /*
  * Make the offset if necessary (Don't do it for composite or solid)
  */

  if(fabs(offset) > 0.000001)
  {
    struct GRobj_env	Surf;
    IGRint		type;

    //////////++++++++++
    if ( VD_offset_before_intersect == TRUE )
    {
      NewSf	= Support.obj_id;
    }
    //////////----------

    Surf.obj_id  = NewSf;
    Surf.mod_env = *(cst.env_info);
    if ( ! (SMGetType ( &Surf, &type, TRUE ) & 1 ) ) goto wrapup;

    /*   if(type == PLAN || type == SURF) now it works also for composite */
    {
      IGRushort		option;
      IGRboolean       	is_natural_normal;
      IGRchar		status_str[81];
      GRobjid		OffSf;
      unsigned char	props;

      option = EMS_opt_offsetS_copy_topology;
      is_natural_normal = TRUE;

      status = om$send (	msg	 = message EMSsubbs.EMget_props(&loc_msg, &props),
				targetid = NewSf.objid,
				targetos = NewSf.osnum);

      /*
       * test the object offset normal - adz 09/14/94
       */
      {

#ifdef	OFF_DEBUG
	printf("offset = %lf \n",offset);
#endif

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
	  else			is_natural_normal = TRUE;
	}

#ifdef	OFF_DEBUG
	printf("props = %d set is_natural_normal = %d\n",props,is_natural_normal);
#endif
      }

#ifdef	OFF_DEBUG
      printf("call EMoffset with offset = %lf, is_natural_normal = %d\n",offset,is_natural_normal);
      printf("obj to offset: %d, %d  \n", NewSf.objid, NewSf.osnum);
#endif

      if ( blkhead == FALSE )
      {
	status = om$send (	msg	 = message EMSsurface.EMoffset(
							&loc_msg,
							 option,
							&cst.env_info->md_env.matrix_type,
							 cst.env_info->md_env.matrix,
							&cst,
							 is_natural_normal,
							 offset,
							 0,	/* new in EMS 3.0 */
							 NULL,	/* new in EMS 3.0 */
							 NULL,	/* new in EMS 3.0 */
							 0, NULL, status_str, &OffSf,
							 NULL ), /* new in EMS 3.0 */
				targetid = NewSf.objid,
				targetos = NewSf.osnum);

	__printf ( "EMSsurface.EMoffset: status = %d, msg = %d", `status, loc_msg` );
      }
      else		////////// BulkHeads: EMoffset can create self-intersecting surface, so do GRcptform instead
      {
	IGRdouble	offvct[3], offnew[3], org_pt[3], scale, rotmat[3][3], invmat[3][3];
	IGRvector	trvec;
	BSrc		rc;

	BStrfrhommx ( mtrx, rotmat, trvec, &scale, &rc);
	if (rc != BSSUCC)
	{
	  printf("ERROR BStrfrhommx\n");
	  goto wrapup;
	}
	BSinv_mat ( 3, (IGRdouble *) rotmat, (IGRdouble *) invmat, &rc);
	if (rc != BSSUCC)
	{
	  printf("ERROR BSinv_mat\n");
	  goto wrapup;
	}

	if (		DMancestry_valid ( blkhd, OPP_SMTransBk_class_id  ) ||
			DMancestry_valid ( blkhd, OPP_SMTrCrgtBk_class_id ))
	{
	  offvct[0] = offsav;	// Transverse BulkHeads NOT YET TESTED !?!?!?!?!
	  offvct[1] = 0;
	  offvct[2] = 0;
	}
	else if (	DMancestry_valid ( blkhd, OPP_SMLongBk_class_id   ) ||
			DMancestry_valid ( blkhd, OPP_SMLgCrgtBk_class_id ) ||
			DMancestry_valid ( blkhd, OPP_SMbulkhead_class_id ))
	{
	  offvct[0] = 0;
	  offvct[1] = offsav;
	  offvct[2] = 0;
	}

	memset ( mtrx  , 0 , 16 * sizeof(double) );
	memset ( org_pt, 0 ,  3 * sizeof(double) );
	mtrx[0] = mtrx[5] = mtrx[10] = mtrx[15] = 1.0;

	MatxVect ( invmat, org_pt, offvct, offnew);

	mtrx[ 3] = offnew[0] ;
	mtrx[ 7] = offnew[1] ;
	mtrx[11] = offnew[2] ;

	__printf ( "offsav = %lg, offnew[] = %lg  %lg  %lg", `offsav, offnew[0], offnew[1], offnew[2]` );

	status = om$send (	msg	 = message GRgraphics.GRcptform(
								&loc_msg,
								 cst.env_info,
								 mtrx,
								 cst.env_info,
								&OffSf),
				targetid = NewSf.objid,
				targetos = NewSf.osnum);

	__printf ( "GRgraphics.GRcptform: status = %d, msg = %d", `status, loc_msg` );
      }

      if(!(status & 1))
      {
	printf("Warning offset surface did not work !!!\n");
      }
      else
      {
	NewSf.objid = OffSf;
	NewSf.osnum = OM_Gw_current_OS;
	//////////++++++++++
	if ( VD_offset_before_intersect == TRUE )
	{
	  Support.obj_id = NewSf;
	}
	//////////----------
      }
    }
  }
  //////////++++++++++
  if ( VD_offset_before_intersect == TRUE )
  {
    NbSf = count - 3;
    if ( ! ( SMBndS1BySfs (	&cst, &Support, PlanInf,
				NbSf, Sf, Rev, SfInf, SfExt,
				SurfRev, &NewSf) & 1)) goto wrapup;
  }
  //////////----------

 /*
  * Reverse if necessary.
  * We assume that the created one is wich the same normal orientation.
  */
  if(SurfRev)
  {
    status = om$send (	msg	 = message EMSsubbs.EMset_props(
							&loc_msg,
							(char) EMSIS_NRML_REVERSED,
							EMS_O_TOGGLE),
			targetid = NewSf.objid,
			targetos = NewSf.osnum);
    if(!(status & loc_msg & 1))
    {
      printf("Cannot reverse the surface normal\n");
    }
  }

  *fcount	= 1;
  *rc		= MSSUCC;
  feet_list[0]	= NewSf;

  __exitMethod ( name = "ACconstruct_feet" );

  return	OM_S_SUCCESS;

wrapup:

  __exitMethod ( name = "ACconstruct_feet" );

  *fcount = 0;
  *rc     = MSFAIL;
  return	OM_W_ABORT;
}

end implementation SMSpltSrf;
