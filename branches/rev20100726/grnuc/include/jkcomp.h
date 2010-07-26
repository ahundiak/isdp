

// Function library - for composite curves

// created by:   J.H.Kidd  I(UK) 

// functions are used by including this file in the start of a ppl program




// functions added for creating composites and merged curves
// based on files received from    in Paris

//  27 apr 1989

//extra include files

//#include "cieveryone.h"
#include "cigetargs.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "maerr.h"
#include "exmacros.h"

/*------------------FUNCTIONS FOR MAKING COMP CURVES----------------

the following is needed in the main program: (28 apr 89)


// Use this one for a merge
   status( "Merging curves ..." ) ;
   merge_curves( env->mod, obj1, cnt, &merge ) ;

// ... and this one for a composite
   status( "Making composite curve ..." ) ;
   make_composite_curve( env->mod, obj1, cnt, &composite ) ;

where 	cnt = number of entries
	obj1 = array of objects to link
	composite = returned id of composite
	merge = returned id of merged curve
*/

// EXTERNAL DECLARATIONS:

extern GRdpb_get();

/*-BUILD-CONSTRUCTION-LIST--------------------------------------------*/

build_construction_list( rc, construct, display, modenv )

	struct GRvg_construct *construct ;
	struct IGRdisplay	*display ;
	struct GRmd_env		*modenv	 ;
	int			*rc	 ; 
{
	int size, dummy_1, dummy_2 ;

	size = sizeof *display ;
	gr$get_active_display(	msg	= &dummy_1,	/* Unused */
				sizbuf	= &size,
				buffer	= display,
				nret	= &dummy_2 ) ;	/* Unused */

	size = sizeof construct->level ;
	gr$get_active_level(	msg	= &dummy_1,	/* Unused */
				sizbuf	= &size,
				buffer	= &construct->level,
				nret	= &dummy_2 ) ;	/* Unused */

	construct->env_info 	= modenv ;
	construct->display  	= display;
	construct->msg		= rc	;
	construct->properties	=   GRIS_LOCATABLE
				  | GRIS_NEW
				  | GRIS_DISPLAYABLE ;
	construct->name		= construct->class_attr
				= construct->geometry	= NULL ;
	construct->newflag	= FALSE;
}

/*-MERGE-CURVE--------------------------------------------------------*/

merge_curves( obj1, count, merge )

	GRobj			*obj1;      /* IN : input objects	 */
	int			count	 ;  /* IN : Number of curves	*/ 
	GRobj			*merge;     /* OUT: Id of final curve */
{

/*
 * Merges a set of curves.
 */

	GRobj			merge2;		/* Id of final curve	 */
	int			rc, msg, i ;	/* Completion code	 */
	struct	GRvg_construct	cst ;		/* Construction params	 */
	struct	IGRdisplay	dis ;		/* Display params	 */
	struct GRlc_info	entries[20];	/* structure for curves	 */
	struct GRmd_env 	modenv;
	char			*Msg ;

	ci$get_module_info(md_env = &modenv);

   for( i = 0 ; i < count ; i = i + 1 ) {
        entries[i].located_obj.objid = obj1[i] ;
   	entries[i].located_obj.osnum	= modenv.md_id.osnum ;
   	entries[i].module_info		= modenv ;
   }

	if( !count || obj1 == NULL ) return TRUE ;

//	Retrieve color, level, etc. and fill construction list
	build_construction_list( &rc, &cst, &dis, &modenv ) ;

	cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE ;
	ci$send(	msg = message GRbcsubbc.EMmerge_curves(
						 count, entries, &cst, &msg ),
		verbose	 = TRUE,
		construct= TRUE,
		targetid = merge2,
		targetos = modenv.md_id.osnum ) ;
	switch( msg ) {
		case MSSUCC 	: Msg = "Merge-curve complete"	; break ;
		case MSFAIL	: Msg = "Merge-curves failed"	; break ;
		case MSINARG	: Msg = "Bad curve in list"	; break ;
		case MANOMEMORY : Msg = "Not enough memory"	; break ;
		default		: Msg = "Unknown code"		; break ;
	} 
	status( Msg ) ;

	*merge = merge2;
	return rc & 1 ;
}

/*-MAKE-COMPOSITE-CURVE-----------------------------------------------*/

make_composite_curve( obj1, count, composite )

	GRobj			*obj1;      /* IN : input objects	 */
	int			count	 ;  /* IN : Number of curves	*/ 
	GRobj			*composite; /* OUT: Id of composite curve */
{
	int			rc, i ;		/* Completion code	 */
	struct	GRvg_construct	cst ;		/* Construction params	 */
	struct	IGRdisplay	dis ;		/* Display params	 */
	struct GRlc_info	entries[20];	/* structure for curves	 */
	struct GRmd_env 	modenv;
	GRobj			composite2;     /* Id of composite curve */
	int			rotten_one ;	/* Index of bad entry	 */

	ci$get_module_info(md_env = &modenv);

   for( i = 0 ; i < count ; i = i + 1 ) {
        entries[i].located_obj.objid = obj1[i] ;
   	entries[i].located_obj.osnum	= modenv.md_id.osnum ;
   	entries[i].module_info		= modenv ;
   }

	if( !count || obj1 == NULL ) return TRUE ;

//	Retrieve color, level, etc. and fill construction list
	build_construction_list( &rc, &cst, &dis, &modenv ) ;

//	Construct composite curve object.
	ci$send(	msg	 = message GRcompcurve.GRconstruct( &cst ),
			targetid = composite2,
			verbose  = TRUE,
			targetos = modenv.md_id.osnum,
			construct= TRUE ) ;

//	Init composite curve with parts.

	ci$send(	msg	= message GRcompcurve.EMmakecomp( &rc, 
								  &modenv,
								  count,
								  entries,
								  &rotten_one ),
			verbose = TRUE,
			targetid= composite2,
			targetos= modenv.md_id.osnum ) ;

	if( !( rc & 1 ) || rotten_one != -1 ) {
		status( "Make-composite-curve failed" ) ;
		rc = FALSE ;
	} else rc = TRUE ;

	*composite = composite2;
	return rc ;
}

//*****************************************************************************

// declaration of functions to place orphan cells and groups

// place_orphan
//
// Function to create an orphan cell in the current design file
//
// The function returns the objid of the cell
//
// Arguments:
//		objp	- *GRobj	- pointer to array of member objects
//		numobj	- double	- number of members
//		name	- *char		- name of orphan cell
//		r1	- double[3]	- 1st point of range box
//		r2	- double[3]	- 2nd point of range box
//
// Example call:
//		cell_obj = place_orphan( objarray , 10 , "head" , r1 , r2 );
//
//

GRobj	place_orphan(objp,numobj,name,r1,r2)
GRobj	*objp;	// array of graphic objects for cell creation
int	numobj;	// number of objects for cell
char	*name;	// cell name 
double	*r1;	// 1st range box point
double	*r2;	// 2nd range box point
{

	struct	GRid	cell_grid;
	struct 	GRmd_env mod_env1;
	struct	GRvg_construct	cst;
	struct	IGRsymboldef	range;
	int 	i, msg, gridx, maxchansz;

	if( numobj <=0 )
	{
		write( "no cell defined - no objects passed to function\n");
		return NULL_OBJID;
	}

	ci$get_module_info(md_env = &mod_env1);

write( " r1 = ",r1[0],r1[1],r1[2],"\n");
	range.diag_pt1[0] = r1[0];
	range.diag_pt1[1] = r1[1];
	range.diag_pt1[2] = r1[2];
	range.diag_pt2[0] = r2[0];
	range.diag_pt2[1] = r2[1];
	range.diag_pt2[2] = r2[2];
write( " range.diag_pt1 = ",range.diag_pt1[0],range.diag_pt1[1],range.diag_pt1[2],"\n");

	cst.msg 	= &msg;
	cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE | GRIS_PLANAR;
	cst.class_attr = &name[0];
	cst.geometry	= (char *)&range;
write( cst.geometry , "\n" );
	cst.env_info   = &mod_env1;
	cst.name 	= 0;

	cell_grid.objid = NULL_OBJID;

	if ( ! ci$send (msg = message GRclhdr.GRconstruct(&cst),
		      targetid= cell_grid.objid,
		      targetos = mod_env1.md_id.osnum,
	              construct = TRUE))
	{
		cell_grid.objid = NULL_OBJID;
		write("error to create orpahn cell \n");
		return NULL_OBJID;
	}
	 cell_grid.osnum = mod_env1.md_id.osnum;

	for( i=0 ; i<numobj ; i=i+1 )
	{
 		if ( ! ci$send (msg = message GRconnector.GRflexconn(
					&msg,
					(int)1,
					&cell_grid,
					&maxchansz,
					&gridx),
		      		targetid= objp[i],
		      		targetos = mod_env1.md_id.osnum) )
		{
			write("error to create orpahn cell \n");
			return NULL_OBJID;
		}
	}
	return cell_grid.objid;
}

//*****************************************************************************
// place_group
//
// Function to create a group in the current design file
//
// The function returns the objid of the cell
//
// Arguments:
//		objp	- *GRobj	- pointer to array of member objects
//		numobj	- double	- number of members
//
// Example call:
//		group = place_group( objarray , 10 );
//
//

GRobj	place_group(objp,numobj)
GRobj	*objp;	// array of graphic objects for group creation
int	numobj;	// number of objects for group
{

	struct	GRid	group_grid;
	struct 	GRmd_env mod_env1;
	struct	GRvg_construct	cst;
	int 	i, msg, gridx, maxchansz;

	if( numobj <=0 )
	{
		write( "no group defined - no objects passed to function\n");
		return NULL_OBJID;
	}

	ci$get_module_info(md_env = &mod_env1);

	cst.msg 	= &msg;
	cst.properties = GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
	cst.name 	= 0;

	group_grid.objid = NULL_OBJID;

	if ( ! ci$send (msg = message GRgrgrp.GRconstruct(&cst),
		      targetid= group_grid.objid,
		      targetos = mod_env1.md_id.osnum ) )
	{
		group_grid.objid = NULL_OBJID;
		write("error in create group \n");
		return NULL_OBJID;
	}
	 group_grid.osnum = mod_env1.md_id.osnum;

	for( i=0 ; i<numobj ; i=i+1 )
	{
 		if ( ! ci$send (msg = message GRconnector.GRrigidconn(
					&msg,
					&group_grid,
					&maxchansz),
		      		targetid= objp[i],
		      		targetos = mod_env1.md_id.osnum) )
		{
			write("error to create orphan group \n");
			return NULL_OBJID;
		}
	}
	return group_grid.objid;
}
//*****************************************************************************
// place_group_temp

// this is used in place of plcae_group until I can get it returning a GRgrgrp
// instead of a GRsvset!

GRobj	place_group_temp( obj , numobj )
GRobj	*obj;
int	numobj;
{
int	i,msg;
double	p1[3];
GRobj	group_obj,member_obj;
char	classname[40];

	begincmd(" create / add to graphic group" );
	for( i=0 ; i<numobj ; i=i+1 )
	{
		ci$put( obj = obj[i] );
	}
	p1[1] = 12345;
	ci$put( point = p1 );
	ci$put( response = TERMINATE );
	endcmd();

	msg = om$get_classname ( osnum = 2,
				objid = obj[0],
				classname = classname );

	if( strcmp(classname,"GRgrgrp")==0 )
	{
		member_obj = get_group_member( obj[0] , 0 );
		group_obj = get_group_id( member_obj );
		return group_obj;
	}
	else
	{
		group_obj = get_group_id( obj[0] );
		return group_obj;
	}

}
//*****************************************************************************
