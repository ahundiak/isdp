/* $Id: VRcablei.I,v 1.2 2001/02/20 01:11:49 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcable / VRcablei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcablei.I,v $
 *	Revision 1.2  2001/02/20 01:11:49  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/03  23:35:02  pinnacle
# Replaced: vrcable/VRcablei.I for:  by msmanem for route240
#
# Revision 1.3  1996/01/16  20:05:20  pinnacle
# Replaced: vrcable/VRcablei.I for:  by r240_int for route240
#
 *
 * 	History:
 *
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *	04/03/96    msm		replaced malloc & free with _MALLOC & _FREE 
 *
 *************************************************************************/
class implementation VRcable;

#define vdsDEBUG
#define vdserrDEBUG

#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "bsparameters.h"
#include "parametric.h"
#include "bs_values.h"
#include "bserr.h"
#include "bstypes.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "bsdotp.h"
#include "bsdistptpt.h"

#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"

#define AS_DEBUG 	1
#define EPSILON		1.0E-12

from	EMSgenbs	import 	EMplctbesrf;
from	expression	import	NDgive_value;

extern GRclassid OPP_GR3dlinestr_class_id;
extern GRclassid OPP_EMSgenbs_class_id;

extern		  som_vla_set_dimension();

/* ----------------------------------------------------------------------
  recompute the cable ============< A REVOIR 
------------------------------------------------------------------------ */
method ACconstruct_feet(  IGRlong *msg; 
			  IGRint cn_type;
			  IGRint count;
			  struct GRid list []; 
                          struct GRmd_env *md_env;
			  int *fcount; 
			  struct GRid  *feet_list )
{
IGRint 			new_npts,action,i,status, nb_brad, max_brad;
struct GRid  		my_grid, FeetList[2];
GRobjid			new_objid;
unsigned char 		rep;
IGRchar			*ptr1=NULL,*ptr2=NULL;
IGRdouble		*new_pts, value;
IGRdouble		sect_rad;
struct GRvg_construct	cnst_lis;
struct ret_struct	ref_st1, ref_st2;
struct IGRpolyline	get_geom, put_geom;

  /* ---------------------------------------------------------------------
	the list[] has to contain the following objects:
		[0] : start referential
		[1] : end referntial
		[2] : section radius
		[3] : bend radius
		[4] : env thickness
  --------------------------------------------------------------------- */
  my_grid.objid     = my_id;
  my_grid.osnum     = OM_Gw_current_OS;
  FeetList[0].objid = NULL_OBJID;
  FeetList[0].osnum = OM_Gw_current_OS;
  FeetList[1].objid = NULL_OBJID;
  FeetList[1].osnum = OM_Gw_current_OS;
 
  /*------------------------------------------------------------------------
		retrieve the radius expression
  ------------------------------------------------------------------------*/
  status = om$send( msg = message expression.NDgive_value(&value),
                    targetid = list[2].objid,
                    targetos = list[2].osnum );

  me->sect_radius = fabs(value);
  if(  me->sect_radius <= EPSILON  ) goto wrapup; 

  status = om$send( msg = message expression.NDgive_value(&value),
                    targetid = list[3].objid,
                    targetos = list[3].osnum );

  me->bend_radius = fabs(value);
  if( me->bend_radius <= EPSILON  ) goto wrapup; 

  /*^
    IGRint j;
    printf(" sect_rad : %f\n", me->sect_radius );
    printf(" bend_rad : %f\n", me->bend_radius );
    j = om$dimension_of( varray = me->bend_table );
    printf(" number btable : %d \n", j );
    for( i=0; i<j; i++ )
	printf(" btab[%d] : %f \n", i, me->bend_table[i] );
    for( i=0; i<count; i++ )
	printf(" list[%d] : [%d,%d]\n", i,list[i].objid, list[i].osnum );
    printf(" fcount : %d \n", *fcount );
    for( i=0; i<*fcount; i++ )
	printf(" feet[%d] : [%d,%d]\n", i,feet_list[i].objid,feet_list[i].osnum );

   */

  /* ---------------------------------------------------------------------
  	get the start referential 
  --------------------------------------------------------------------- */
  status = om$send(msg = message NDnode.NDgive_structure(msg,&ref_st1,md_env),
		   targetid = list[0].objid,
		   targetos = list[0].osnum);
  as$status(action = RET_STATUS);

  /* --------------------------------------------------------------------
	 get the end referential 
  --------------------------------------------------------------------- */
  status = om$send(msg = message NDnode.NDgive_structure(msg,&ref_st2,md_env) ,
		   targetid = list[1].objid,
		   targetos = list[1].osnum);
  as$status(action = RET_STATUS);

  /* --------------------------------------------------------------------
	 get the cable linestring 
  --------------------------------------------------------------------- */
  status = om$get_objid_at_index(objid = my_id,
				p_chanselect = &AS_to_comp,
				index = 0,
				objidaddr = &FeetList[0].objid,
				osnumaddr = &FeetList[0].osnum );
  as$status(action = GOTO_VALUE, value = wrapup );

  /* --------------------------------------------------------------------
	 get the polyline geometry size (action=0)
  --------------------------------------------------------------------- */
  action = 0;
  status = om$send(msg = message GRlinear.GRgetpolyline(
					msg,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&action,
					&get_geom),
		   targetid = FeetList[0].objid,
                   targetos = FeetList[0].osnum );
  as$status(action = GOTO_VALUE, value = wrapup);
  as$status(sts = *msg, action = GOTO_VALUE, value = wrapup);
  /* --------------------------------------------------------------------
	 get the polyline geometry (action=1)
  --------------------------------------------------------------------- */
  action = 1;

 /*  ptr1 = om$malloc( size = (3 * get_geom.num_points * (sizeof (IGRdouble))));
  */

  ptr1 = _MALLOC ((3 * get_geom.num_points * (sizeof (IGRdouble))), IGRchar );

  get_geom.points = (IGRdouble *)ptr1;  
  status = om$send(msg = message GRlinear.GRgetpolyline(
					msg,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&action,
					&get_geom),
		   targetid = FeetList[0].objid,
                   targetos = FeetList[0].osnum );
  as$status(action = GOTO_VALUE, value = wrapup );
  as$status(sts = *msg, action = GOTO_VALUE, value = wrapup);

  /* --------------------------------------------------------------------
	 control the cable linestring
  --------------------------------------------------------------------- */
  new_npts = get_geom.num_points;
  if( new_npts < 4) new_npts = 4;
  /*" new_npts : %d\n", new_npts */

  /*  ptr2 = om$malloc( size = (3 * new_npts * (sizeof (IGRdouble))));
   */
  ptr2 = _MALLOC ( (3 * new_npts * (sizeof (IGRdouble))), IGRchar );

  new_pts = (IGRdouble *)ptr2;
  inspect_line( msg, get_geom.points, get_geom.num_points, new_pts,
		me->bend_radius, ref_st1, ref_st2 );

  put_geom.num_points = new_npts;
  put_geom.points     = new_pts;
  /*^IGRint j;
     printf(" AFTER MODIFICATIONS \n");
     for(j=0;j<put_geom.num_points;j++)
	printf("pt[%d]= %f,%f,%f\n",j, put_geom.points[3*j],
		put_geom.points[3*j+1], put_geom.points[3*j+2]);
  */

  /*----------------------------------------------------------------------*/
  /*| control the bend_radius table */
  /*----------------------------------------------------------------------*/
  nb_brad = om$dimension_of( varray = me->bend_table );
  if( nb_brad < (put_geom.num_points - 2) ){
    /*| the line is modified after delvertex */
    max_brad = put_geom.num_points - 2;
    status = om$vla_set_dimension( varray = me->bend_table,
			  	   size   = max_brad );
    as$status(action = GOTO_VALUE, value = wrapup );
    for( i=nb_brad; i<max_brad; i++) me->bend_table[i] = me->bend_radius;
  }
  else max_brad = nb_brad;

  /*----------------------------------------------------------------------*/
  /* KLUDGE: control the bend_radius table against null values */
  /*----------------------------------------------------------------------*/
  for( i=0; i<max_brad; i++ ){
    if( me->bend_table[i] < me->bend_radius ){
      /*^ printf(" Kludge Error : bend_table[%d] : %f -> %f\n", 
			i, me->bend_table[i], me->bend_radius );
       */
      me->bend_table[i] = me->bend_radius;
    }
  }

  /*----------------------------------------------------------------------*/
  /*| construct the construction list body */
  /*----------------------------------------------------------------------*/
  cnst_lis.msg		= msg;
  cnst_lis.env_info	= md_env;
  cnst_lis.newflag	= FALSE;
  cnst_lis.level	= me->level; 
  cnst_lis.properties	= GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cnst_lis.geometry	= NULL; 
  cnst_lis.display	= &(me->display_attr);
  cnst_lis.class_attr	= NULL; 
  cnst_lis.name		= NULL;
 
  /*----------------------------------------------------------------------*/
  /*| construct the polyline */
  /*----------------------------------------------------------------------*/
  cnst_lis.geometry = (IGRchar *)&put_geom;

  status = om$construct(classid = OPP_GR3dlinestr_class_id,
		  	p_objid = &new_objid,
			msg     = message GRgraphics.GRaltconstruct(
				 (struct GRvg_construct *)&cnst_lis)); 
  as$status(action = GOTO_VALUE, value = wrapup );

  *fcount = 1;
  FeetList[0].objid = new_objid;
  /*" new_objid = %d\n", FeetList[0].objid */

  status = om$send(msg = message ACncpx.ACget_NV_rep(&rep),
		   targetid = my_id);

  if( rep&AC_3D_REP || rep&AC_ENV_REP ){

    /*--------------------------------------------------------------------*/
    /*| compute the tube */
    /*--------------------------------------------------------------------*/
    sect_rad = me->sect_radius;

    /*| determine the enveloppe thickness */
    if( rep&AC_ENV_REP ){
      status = om$send( msg = message expression.NDgive_value(&value),
			targetid = list[4].objid,
			targetos = list[4].osnum );
      as$status(action = RET_STATUS);

      sect_rad += value;
      /*" env_sect_rad : %f; env_thichness : %f\n", sect_rad, value */
    }

    /*--------------------------------------------------------------------*/
    /*| construct the cable tabular surface */
    /*--------------------------------------------------------------------*/
    /*^ IGRint j;
	printf("sect_rad : %f\n", sect_rad );
	printf("linestr  : [%d,%d]\n", FeetList[0].objid, FeetList[0].osnum );
	j = om$dimension_of( varray = me->bend_table );
	printf(" number btable : %d \n", j );
	for( i=0; i<j; i++ )
	  printf(" btab[%d] : %f \n", i, me->bend_table[i] );
     */

    status = om$construct(classid = OPP_EMSgenbs_class_id,
			  p_objid = &FeetList[1].objid,
			  msg     = message EMSgenbs.EMplctbesrf
					( msg,
					  md_env,
					  FeetList[0],
					  sect_rad,
					  me->bend_table, 
					  &cnst_lis ) );
    if( !(status&1) || !(*msg&1) ){
      /*| delete the tube object */
      om$send( 	msg	 = message Root.delete(1),
		targetid = FeetList[1].objid,
		senderid = NULL_OBJID );
      FeetList[1].objid = NULL_OBJID;

	{	/* -- Display error -- */

		UI_status("Error : Radius too large");

	} /* end display error */
    }
    else {
      (*fcount) ++;
      UI_status(" ");
    }
  }

  *fcount = 2;
  /*| fill in the feet_list */
  feet_list[0] = FeetList[0];
  feet_list[1] = FeetList[1];

  /*^
    printf("feet[0]: %d,%d \n", feet_list[0].objid, feet_list[0].osnum );
    printf("feet[1]: %d,%d \n", feet_list[1].objid, feet_list[1].osnum );
   */

  /* if( ptr1 )	om$dealloc( ptr = ptr1 );
   * if( ptr2 )	om$dealloc( ptr = ptr2 );
   */

  _FREE( ptr1 );
  _FREE( ptr2 );

  *msg=MSSUCC;
  return(OM_S_SUCCESS);

wrapup:

  /*| delete the linestring object */
  if( FeetList[0].objid != NULL_OBJID ){
    om$send(	msg	 = message Root.delete(1),
		targetid = FeetList[0].objid,
		senderid = NULL_OBJID );
    FeetList[0].objid = NULL_OBJID;
  }

  /*| delete the tube object */
  if( FeetList[1].objid != NULL_OBJID ){
    om$send(	msg	 = message Root.delete(1),
		targetid = FeetList[1].objid,
		senderid = NULL_OBJID );
    FeetList[1].objid = NULL_OBJID;
  }
   
  /* if( ptr1 )	om$dealloc( ptr = ptr1 );
   * if( ptr2 )	om$dealloc( ptr = ptr2 );
   */
  _FREE( ptr1 );
  _FREE( ptr2 );

  return(status);

}

/*--------------------------------------------------------------------------*/
/* method  VRcable.ACcontext_compute_feet				    */
/*--------------------------------------------------------------------------*/

method ACcontext_compute_feet(int count;
			struct GRid 	context_obj;
			struct GRid 	*feet_list;
			struct GRmd_env *md_env )
{
/* context of children is managed in construct feet */
  return (  OM_S_SUCCESS );
}


/*--------------------------------------------------------------------------*/
/* method  VRcable.place						    */
/* this method does a non-interactive place				    */
/*--------------------------------------------------------------------------*/
method NDplace(struct GRas *asso_lis; struct GRmd_env *md_env;
		IGRchar *go_cnst_lis)
{
IGRlong 	msg;
IGRint		i, size, status, new_npts;
IGRdouble 	*new_pts, value;
IGRdouble	sect_rad;
struct GRid 	my_grid;
unsigned char 	rep;
IGRchar		*ptr=NULL;
struct IGRpolyline 	put_line, *get_line;
struct ret_struct 	ref_st1, ref_st2;
struct GRid		FeetList[2];

  /* ---------------------------------------------------------------------
	the asso_lis[] has to contain the following objects:
		[0] : start referential
		[1] : end referntial
		[2] : section radius
		[3] : bend radius
		[4] : env thickness
  --------------------------------------------------------------------- */
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /* copy the active IGrdisplay values into the parent instance */
  me->display_attr.color     = ((struct GRvg_construct *)go_cnst_lis)->display->color;
  me->display_attr.weight    = ((struct GRvg_construct *)go_cnst_lis)->display->weight;
  me->display_attr.style     = ((struct GRvg_construct *)go_cnst_lis)->display->style;
  me->level = ((struct GRvg_construct *)go_cnst_lis)->level;

  /*----------------------------------------------------------------------*/
  /* Initialise list of constructed graphic object */
  /*----------------------------------------------------------------------*/
  FeetList[0].objid = NULL_OBJID; FeetList[0].osnum = OM_Gw_current_OS;
  FeetList[1].objid = NULL_OBJID; FeetList[1].osnum = OM_Gw_current_OS;

  /*----------------------------------------------------------------------*/
  /*| ---  Store macro def id --- */
  /*----------------------------------------------------------------------*/
  status = om$send(msg = message ACcpx.ACattach ((IGRint *)&msg,"VRcable"),
                   targetid = my_id );
  as$status(action = RET_STATUS);

  /*^ for(i=0;i<5;i++){
	printf(" parent[%d] : (%d,%d)\n", i, asso_lis->parents[i].objid,
					  asso_lis->parents[i].osnum );
    }
   */

  /*----------------------------------------------------------------------*/
  /*	get the start referential 					  */
  /*----------------------------------------------------------------------*/

  status = om$send( msg = message NDnode.NDgive_structure(&msg,&ref_st1,md_env),
		    targetid = asso_lis->parents[0].objid,
		    targetos = asso_lis->parents[0].osnum);
  as$status(action = RET_STATUS);

  if( !( ref_st1.type & ref_generic )){
    	/*^ printf("VRlinestr.place point1 : invalid type\n"); */
    	return(OM_W_ABORT);
  }

  /*----------------------------------------------------------------------*/
  /*	get the end referential 					  */
  /*----------------------------------------------------------------------*/
  status = om$send(msg = message NDnode.NDgive_structure(&msg,&ref_st2,md_env),
		   targetid = asso_lis->parents[1].objid,
		   targetos = asso_lis->parents[1].osnum);
  as$status(action = RET_STATUS);

  if (!(ref_st2.type & ref_generic)){
    	/*^ printf("VRlinestr.place second point invalid type\n"); */
    	return(OM_W_ABORT);
  }

  /*----------------------------------------------------------------------*/
  /*	retrieve the radius expression					  */
  /*----------------------------------------------------------------------*/
  status = om$send( msg = message expression.NDgive_value(&value),
                    targetid = asso_lis->parents[2].objid,
                    targetos = asso_lis->parents[2].osnum );

  me->sect_radius = fabs(value);
  if(  me->sect_radius <= EPSILON  ) return OM_W_ABORT; 

  /*----------------------------------------------------------------------*/
  /*	retrieve the bend radius expression				  */
  /*----------------------------------------------------------------------*/
  status = om$send( msg = message expression.NDgive_value(&value),
                    targetid = asso_lis->parents[3].objid,
                    targetos = asso_lis->parents[3].osnum );

  me->bend_radius = fabs(value);
  if( me->bend_radius <= EPSILON  ) return OM_W_ABORT;

  /*" sect_rad : %f\n", me->sect_radius */
  /*" bend_rad : %f\n", me->bend_radius */

  /*----------------------------------------------------------------------*/
  /*	make the start and end segment of the linestring respectively 	  */
  /*	colinear to the x axis of the start and end referential		  */
  /*----------------------------------------------------------------------*/
  get_line = ( struct IGRpolyline * )
	       ( ( struct GRvg_construct * ) go_cnst_lis)->geometry;

  new_npts = get_line->num_points;
  if( new_npts < 4) new_npts = 4;
  /*" new_npts : %d\n", new_npts */

  /* ptr = om$malloc( size = (3 * new_npts * (sizeof (IGRdouble))));
   */

  ptr = _MALLOC ( (3 * new_npts * (sizeof (IGRdouble))), IGRchar );

  new_pts = (IGRdouble *)ptr;
  inspect_line( &msg, get_line->points, get_line->num_points, new_pts,
		me->bend_radius, ref_st1, ref_st2 );

  put_line.num_points = new_npts;
  put_line.points     = new_pts;
  /*^
     IGRint j;
     printf(" AFTER MODIFICATIONS \n");
     for(j=0;j<put_line.num_points;j++)
	printf("pt[%d]=, %f,%f,%f\n",j, put_line.points[3*j],
		put_line.points[3*j+1], put_line.points[3*j+2]);
  */

  ((struct GRvg_construct *) go_cnst_lis)->geometry = (IGRchar *)&put_line;

  status = om$construct(	classid = OPP_GR3dlinestr_class_id,
			  	p_objid = &FeetList[0].objid,
				msg     = message GRgraphics.GRaltconstruct(
					 (struct GRvg_construct *)go_cnst_lis)); 
  as$status(action = GOTO_VALUE, value = wrapup );

  /*----------------------------------------------------------------------*/
  /*	set up the bend table						  */
  /*----------------------------------------------------------------------*/
  if( me->bend_radius < me->sect_radius ){
	printf("bend radius(%f) must be >= section radius(%f)\n",
		me->bend_radius, me->sect_radius );
	me->bend_radius = 1.001 * me->sect_radius;
  }
  new_npts = put_line.num_points - 2;

  size = om$dimension_of( varray = me->bend_table );
  if( size != new_npts ){
      /*" create new bend_table[%d].\n", new_npts */
      status = om$vla_set_dimension( varray = me->bend_table,
				     size   = new_npts );
      as$status(action = GOTO_VALUE, value = wrapup );

  }

  for(i=0;i<new_npts;i++) me->bend_table[i] = me->bend_radius;
  /*^ for(i=0;i<new_npts;i++)
	printf(" btable[%d] : %f\n",i, me->bend_table[i] ); 
   */

  rep    = *((unsigned char *) asso_lis->as_attr);
  status = om$send(msg = message ACncpx.ACput_NV_rep(rep),
		   targetid = my_id);
  as$status(action = GOTO_VALUE, value = wrapup );

  if( rep&AC_3D_REP || rep&AC_ENV_REP ){

    /*--------------------------------------------------------------------*/
    /*| compute the tube */
    /*--------------------------------------------------------------------*/
    sect_rad = me->sect_radius;

    if( rep&AC_ENV_REP ){

      /*| get the enveloppe thickness */
      status = om$send( msg = message expression.NDgive_value(&value),
			targetid = asso_lis->parents[4].objid,
			targetos = asso_lis->parents[4].osnum );
      as$status(action = RET_STATUS);

      sect_rad += value;
      /*" env_sect_rad : %f; env_thichness : %f\n", sect_rad, value */
    }

    /* ------------------------------------------------------------------- */
    /*| construct the cable tube */
    /* ------------------------------------------------------------------- */
    /*^ IGRint j;
	printf("sect_rad : %f\n", sect_rad );
	printf("linestr  : [%d,%d]\n", FeetList[0].objid, FeetList[0].osnum );
	j = om$dimension_of( varray = me->bend_table );
	printf(" number btable : %d \n", j );
	for( i=0; i<j; i++ )
	  printf(" btab[%d] : %f \n", i, me->bend_table[i] );
     */
    status = om$construct(classid = OPP_EMSgenbs_class_id,
			  p_objid = &FeetList[1].objid,
			  msg     = message EMSgenbs.EMplctbesrf
				( &msg,
				  md_env,
				  FeetList[0],
				  sect_rad,
				  me->bend_table, 
				  (struct GRvg_construct *)go_cnst_lis ) );

    /* ********  test modified *************** */
    /* as$status(action = GOTO_VALUE, value = wrapup ); 		*/
    /* as$status(sts = msg, action = GOTO_VALUE, value = wrapup );	*/
    /* ************************ */
    if( !(status&1) || !(msg&1) ){
      /*| delete the tube object */
      om$send( 	msg	 = message Root.delete(1),
		targetid = FeetList[1].objid,
		senderid = NULL_OBJID );
      FeetList[1].objid = NULL_OBJID;

	{	/* -- Display error -- */

		UI_status("Error : Radius too large");

	} /* end display error */
    }
    else	UI_status(" ");
    
    /* -------------------------------------------------------------------- */
    /*" created the tube(%d,%d)\n",FeetList[1].objid,FeetList[1].osnum */
    /* -------------------------------------------------------------------- */
  }

  /* ---------------------------------------------------------------------- */
  /*| Connect myself to the parents */
  /* ---------------------------------------------------------------------- */
  status = om$send(msg = message NDnode.NDconnect(asso_lis->num_parents,
						  asso_lis->parents,
						  NULL_GRID, ND_NEW),
		     targetid = my_id);
  as$status(action = GOTO_VALUE, value = wrapup );

  /* ---------------------------------------------------------------------- */
  /*| Connect my feet to myself */
  /* ---------------------------------------------------------------------- */

  status = om$send( msg     = message ACncpx.ACchange_feet( 2, FeetList, md_env ),
		   targetid = my_id );
  as$status(action = GOTO_VALUE, value = wrapup );

  /* if( ptr ) om$dealloc( ptr = ptr );
   */

  _FREE( ptr );

  return(OM_S_SUCCESS);

wrapup:
      
  /*| delete the linestring object */
  if( FeetList[0].objid != NULL_OBJID ){
    om$send( 	msg	 = message Root.delete(1),
		targetid = FeetList[0].objid,
		senderid = NULL_OBJID );
    FeetList[0].objid = NULL_OBJID;
  }

  /*| delete the tube object */
  if( FeetList[1].objid != NULL_OBJID ){
    om$send( 	msg	 = message Root.delete(1),
		targetid = FeetList[1].objid,
		senderid = NULL_OBJID );
    FeetList[1].objid = NULL_OBJID;
  }

  /* if( ptr ) om$dealloc( ptr = ptr );
   */

  _FREE( ptr );

  return(OM_W_ABORT);

} /* end of NDplace */


/*=========================================================================*/
/*   function to evaluate the structure of the linestring		   */
/*									   */
int inspect_line( msg, iline, npts, oline, brad, ref_st1, ref_st2 )
/* 		  O  , I    , I   , O    , I   , I      , I   		   */
/*=========================================================================*/
IGRlong		*msg;
IGRdouble	*iline;
IGRint		npts;
IGRdouble	*oline;
IGRdouble	brad;
struct ret_struct	ref_st1;
struct ret_struct	ref_st2;
/*.inspect_line*/
{
BSrc		rc;
IGRint		i, j;
IGRdouble	dVX1[3], dVX2[3];
IGRdouble	spnt[3], epnt[3];
IGRdouble	pos_spnt[3], neg_spnt[3];
IGRdouble	pos_epnt[3], neg_epnt[3];

  for(j=0;j<3;j++) {

	/* -- Init vectors -- */
  	dVX1[j] = ref_st1.var.ref_st.t[j*4];	/* matrix x-vec */
	dVX2[j] = ref_st2.var.ref_st.t[j*4];	/* index  0,4,8 */

	/* -- Init points -- */
  	spnt[j] = ref_st1.var.ref_st.t[j*4+3];	/* matrix  pnt  */
	epnt[j] = ref_st2.var.ref_st.t[j*4+3];	/* index 3,7,11 */
  }

  /* " VX1 : %f %f %f \n", dVX1[0], dVX1[1], dVX1[2] */
  /* " VX2 : %f %f %f \n", dVX2[0], dVX2[1], dVX2[2] */

  /*^
     printf(" BEFORE inspection \n");
     printf("spnt= %f,%f,%f\n", spnt[0], spnt[1], spnt[2]);
     printf("epnt= %f,%f,%f\n", epnt[0], epnt[1], epnt[2]);
     printf("npts= %d\n", npts );
     for(j=0;j<npts;j++)
	printf("pt[%d]= %f,%f,%f\n",j, iline[3*j], iline[3*j+1], iline[3*j+2]);
  */


  /* look if the equipment are moved */

  /* -- If necessary, move the first two vertices -- */
  if( BSdistptpt( &rc, &(iline[0]), spnt ) > BSBASISVAL ){
    /*| start point is moved */
    for(i=0;i<3;i++){
	iline[i+3] = iline[i+3] + ( spnt[i] - iline[i]);
	iline[i]   = spnt[i];
    }
  }

  /* -- If necessary, move the last two vertices -- */
  j = 3 * (npts - 1);
  if( BSdistptpt( &rc, &(iline[j]), epnt ) > BSBASISVAL ){
    /*| end point is moved */
    for(i=0;i<3;i++){
	iline[j+i-3] = iline[j+i-3] + ( epnt[i] - iline[j+i]);
	iline[j+i] = epnt[i];
    }
  }


  /*| find support start point */
  for(i=0;i<3;i++){	neg_spnt[i] = spnt[i] - brad * dVX1[i];
			pos_spnt[i] = spnt[i] + brad * dVX1[i];
  }

  /*| find support end point */
  for(i=0;i<3;i++){	neg_epnt[i] = epnt[i] - brad * dVX2[i];
			pos_epnt[i] = epnt[i] + brad * dVX2[i];
  }

  if( npts < 4 ){

    /*| define support start point */
    /* KLUDGE : Wait for additional arguments to specify the orientation */
/*    if( BSdistptpt( &rc, neg_spnt, epnt ) < BSdistptpt( &rc, pos_spnt, epnt ))
		for(i=0;i<3;i++) oline[i+3] = neg_spnt[i];
    else */
    /* Take the +X orientation from the starting equipment */
	for(i=0;i<3;i++) oline[i+3] = pos_spnt[i];

    /* Take the shortest orientation for the ending equipment */
    /*| define support end point */
    if( BSdistptpt( &rc, neg_epnt, spnt ) < BSdistptpt( &rc, pos_epnt, spnt ))
		for(i=0;i<3;i++) oline[i+6] = neg_epnt[i];
    else	for(i=0;i<3;i++) oline[i+6] = pos_epnt[i];

    /*| fill in end points */
    for(i=0;i<3;i++){
	oline[i]   = spnt[i];
        oline[i+9] = epnt[i];
    }
  }/* end if npts < 4 */
  else{

    IGRdouble dLength, dVect[3];

    /*|  for four or more points */
    j = npts * 3;
    for(i=0;i<j;i++) oline[i] = iline[i];

    /* -- Force the second vertex to be aligned with the X axes -- */
    /* -- with a minimum distance of bend radius -- */

    for(i=0;i<3;i++) dVect[i] = oline[i+3] - oline[i];

    dLength = BSdotp ( &rc, dVect, dVX1);

    if ( fabs(dLength) < brad )
       if ( dLength != 0 ) dLength = brad * dLength / fabs(dLength);
       else		   dLength = brad;

    for(i=0;i<3;i++) oline[i+3] = oline[i] + dLength * dVX1[i];

    /* -- Force the for last vertex to be aligned with the X axes -- */
    /* -- with a minimum distance of bend radius -- */

    for(i=0;i<3;i++) dVect[i] = oline[j-6+i] - oline[j-3+i];

    dLength = BSdotp ( &rc, dVect, dVX2);

    if ( fabs(dLength) < brad )
       if ( dLength != 0 ) dLength = brad * dLength / fabs(dLength);
       else		   dLength = brad;

    for(i=0;i<3;i++) oline[j-6+i] = oline[j-3+i] + dLength * dVX2[i];

  }

  /*^
     printf(" AFTER inspection \n");
     for(j=0;j<npts||j<4;j++)
	printf("pt[%d]=, %f,%f,%f\n",j, oline[3*j], oline[3*j+1], oline[3*j+2]);
  */

  *msg = MSSUCC;
  return(OM_S_SUCCESS);

}

/*--------------------------------------------------------------------------*/
/* end of file								    */
/*--------------------------------------------------------------------------*/
end implementation VRcable;
