/* $Id: SMCmpFn.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMCmpFn.I
 *
 * Description:
 *
 *      This file implements some functions to get info from a compartment.
 *
 * Dependencies:
 *
 *      Root
 *
 * Revision History:
 *	$Log: SMCmpFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/13  15:45:00  pinnacle
# Replaced by A.Gupta
#
# Revision 1.2  1998/02/13  17:27:40  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by rchennup for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.7  1996/05/27  05:05:58  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by apazhani for vds.240
#
# Revision 1.6  1996/04/29  08:47:26  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by ksundar for vds.240
#
# Revision 1.5  1996/03/18  10:54:38  pinnacle
# Replaced: SMCmdSurf.S for:  by ksundar for vds.240
#
# Revision 1.4  1995/10/31  16:20:12  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by sundar for vds.240
#
# Revision 1.3  1995/09/27  19:36:56  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by sundar for vds.240
#
# Revision 1.2  1995/09/26  21:06:44  pinnacle
# Replaced: smcomp/func/SMCmpFn.I for:  by sundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      04/24/93        P. Lacroix      Creation date.
 *	10/31/95	Sundar		Replaced math.h with values.h during 
 *					Solaris Port
 *
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include <math.h>
#include <values.h>
#include <string.h>
#include "OMmacros.h"
#include "OMindex.h"
#include "exmacros.h"
#include "bserr.h"
#include "bstypes.h"

#include "EMSssprops.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "growner.h"
#include "ACattrib.h"
#include "ACrg_collect.h"

#include  "ms.h"
#include  "msdef.h"
#include  "msmacros.h"
#include "nddef.h"

#include "SMmsg.h"
#include "VDmem.h"
#include "SMcomp_def.h"

#include "AS_status.h"

/* Prototypes */
#include "bsmkvec.h"
#include "bscrossp.h"
#include "bstagsort.h"
#include "bsnorvec.h"
#include "bssfevaln.h"
#include "bsdotp.h"

from    EMSsubbs	import	EMget_props;
from    GRvg		import	GRdetplane, GRgenabsg;
from    GRowner		import	GRget_number_components,GRget_components;
from    NDmacro		import	ACreturn_foot;
from    EMSsurface	import	EMget_point_on_surface;
from    GRgraphics	import	GRgetrang;
from    SMmgr		import	SMGetAttTxt;
from	SMcomp		import  SMGetVolInfo;
from    NDnode          import NDget_objects;

extern  GRclassid 	OPP_EMSplane_class_id,OPP_GRowner_class_id, OPP_EMSsurface_class_id;

#define AS_DEBUG

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMGetFloor

  Abstract

 	Given a volume, this function return the faces that can be taken as the 
 	floors (it must have quite the same normal as the Vz of the ship Cs).
 	The returned floors are put in increasing order of the z coord.
 	( The first one is the lower floor)

  	The maximum angle with Vz must be given in degree.
  	floor is allocated by the function and must be deallocated
  	by the user.

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/

int SMGetFloor(volume, mod_env, angle, nb_floor, floor)
struct GRid 		*volume;   /* (I) volume id  	*/
struct GRmd_env		*mod_env;  /* (I) mod env of the volume	*/
IGRdouble		angle;	   /* (I) maximum angle with Vz to be a floor */
IGRint			*nb_floor; /* (O) nb floor found */
struct GRid		**floor;   /* (O) the floor (faces of the volume) */
/*
-fi */
{
int			i,k,stat, nb_comps, count, num_normals, *index;
long			msg;
struct GRid		*comps, *tmp, cs_id, go_cs;
struct GRmd_env		cs_env;
GRclassid		classid;
struct IGRplane		plane;
IGRdouble		dotp, *z_coord, pldef[6], normal[3], base[3], Vz[3];
struct IGRbsp_surface 	*surf;
BSrc			rc;
struct IGRlbsys		*p_geom;
IGRuchar                geom_props;
extern IGRdouble	cos();


if(volume == NULL || mod_env == NULL || nb_floor == NULL || floor == NULL){
	printf("Invalid Argument in  SMGetFloor\n");
	return 0;
}
comps = NULL;
nb_comps = 0;
*floor = NULL;
z_coord = NULL;
*nb_floor = 0;
tmp = NULL;
index = NULL;

angle = angle * M_PI / 180;

 /*
  * Get all the surfaces and the normal (0.5, 0.5 if no planar).
  * Get the Ship CS Vz.  
  * if the surface normal is ~ Vz => that can be a floor.
  * 
  */

/* Get default Cs (ship or EMS cs) */

stat = SMGetDefCs(TRUE,                  /* Take EMS cs if no ship cs */
                  (struct GRid *)NULL,   /* Connected with Glob not needed */
	          (IGRshort *)NULL,      /* State not used */ 
		  &go_cs,                /* Graphic cs */
		  &cs_id,                /* Associative cs  */
		  &cs_env,               /* Mod env */
		 (IGRboolean *)NULL);    /* No flag needed */
 
if(!stat || go_cs.objid == NULL_OBJID) goto wrapup;


stat = om$send(msg = message GRvg.GRgenabsg(&msg, &mod_env->md_env.matrix_type,
 		mod_env->md_env.matrix, (char **) &p_geom),
			senderid = NULL_OBJID,
                        targetid = go_cs.objid,
                        targetos = go_cs.osnum );
if(!(stat & msg & 1)){
	printf("ERROR  GRvg.GRgenabsg of the coord syst.\n");
	goto wrapup;
}
for(i=0;i<3;i++) Vz[i] = p_geom->matrix[4*i+2];
BSnorvec(&rc, Vz);

stat = om$get_classid(	osnum = volume->osnum,
			objid = volume->objid,
			p_classid = &classid);

if( om$is_ancestry_valid( subclassid	= classid,
			  superclassid 	= OPP_GRowner_class_id )
                           	!= OM_S_SUCCESS ){
	if( om$is_ancestry_valid( subclassid	= classid,
			  	  superclassid 	= OPP_EMSsurface_class_id )
                           	== OM_S_SUCCESS ){
		nb_comps = 1;
		comps = _MALLOC(nb_comps, struct GRid);
		if(comps == NULL){
			printf("ERROR Bad dynamic allocation\n");
			goto wrapup;
		}
		comps[0] = *volume;
		goto GET_NORMAL;
	}
	else{
		printf("ERROR Invalid type of object\n");
		goto wrapup;
	}
}

stat = om$send(msg = message GRowner.GRget_number_components(&msg, &nb_comps),
			senderid = NULL_OBJID,
                        targetid = volume->objid,
                        targetos = volume->osnum );
if(!(stat & msg & 1)){
	printf("ERROR  GRowner.GRget_number_components\n");
	goto wrapup;
}
if(nb_comps){

	comps = _MALLOC(nb_comps, struct GRid);
	if(comps == NULL){
		printf("ERROR Bad dynamic allocation\n");
		goto wrapup;
	}
	z_coord = _MALLOC(nb_comps, IGRdouble);
	if(z_coord == NULL){
		printf("ERROR Bad dynamic allocation\n");
		goto wrapup;
	}
	tmp = _MALLOC(nb_comps, struct GRid);
	if(tmp == NULL){
		printf("ERROR Bad dynamic allocation\n");
		goto wrapup;
	}
	stat = om$send(msg = message GRowner.GRget_components(&msg, mod_env, 
			comps, nb_comps, &count, 0,0),
			senderid = NULL_OBJID,
                        targetid = volume->objid,
                        targetos = volume->osnum );
	if(!(stat & msg & 1)){
		printf("ERROR  GRowner.GRget_components\n");
		goto wrapup;
	}
}

GET_NORMAL:

for(i=0;i<nb_comps;i++){

	stat = om$get_classid(	osnum = comps[i].osnum,
				objid = comps[i].objid,
				p_classid = &classid);

	if( om$is_ancestry_valid( 	subclassid	= classid,
				  	superclassid 	= OPP_EMSplane_class_id )
                           	== OM_S_SUCCESS ){
		plane.point  = &pldef[0];
		plane.normal = &pldef[3];
   		stat = om$send (msg = message GRvg.GRdetplane(&msg, 
			&mod_env->md_env.matrix_type, mod_env->md_env.matrix, 
			&plane),
                         senderid = NULL_OBJID,
                         targetid = comps[i].objid,
                         targetos = comps[i].osnum );

		if(!(stat & msg & 1)){
			printf("ERROR  GRvg.GRdetplane\n");
			goto wrapup;
		}
		for(k=0;k<3;k++) normal[k] = plane.normal [k];
		base[2] = plane.point[2];
	}
	else if( om$is_ancestry_valid(	subclassid   = classid,
                                	superclassid = OPP_EMSsurface_class_id )
                                == OM_S_SUCCESS ){
   		stat = om$send (msg = message EMSsubbs.EMget_props(&msg, 
								&geom_props), 
                         senderid = NULL_OBJID,
                         targetid = comps[i].objid,
                         targetos = comps[i].osnum );
		if(!(stat & msg & 1)){
			printf("ERROR  EMSsubbs.EMget_props\n");
			goto wrapup;
		}
   		stat = om$send (msg = message GRvg.GRgenabsg(&msg, 
			&mod_env->md_env.matrix_type, mod_env->md_env.matrix, 
			(IGRchar **) &surf),
                         senderid = NULL_OBJID,
                         targetid = comps[i].objid,
                         targetos = comps[i].osnum );
		if(!(stat & msg & 1)){
			printf("ERROR  GRvg.GRgenabsg\n");
			goto wrapup;
		}
              BSsfevaln(surf, .5, .5, 1, &num_normals, base,( IGRvector *) &normal, &rc);
              if(rc != BSSUCC){
                  printf("ERROR BSsfevaln\n");
               goto wrapup;
              }
              if(geom_props & EMSIS_NRML_REVERSED)
                  for(k=0;k<3;k++) normal[k] = -normal[k];
  	}
 	else{
		printf("ERROR invalid type of object\n");
		goto wrapup;
	}
	
	BSnorvec(&rc, normal);
	dotp = BSdotp(&rc, normal, Vz);

	if(dotp > cos(angle) ){

		/* the surface is a floor */

		z_coord[*nb_floor] = base[2];
		tmp[*nb_floor] = comps[i];
		(*nb_floor) ++;

	}

} 
if(*nb_floor){
	*floor = (struct GRid *)malloc( (*nb_floor)*sizeof(struct GRid));
	if(*floor == NULL){
		printf("ERROR Bad dynamic allocation\n");
		goto wrapup;
	}
	index = _MALLOC( (*nb_floor), int);
	if(index == NULL){
		printf("ERROR Bad dynamic allocation\n");
		goto wrapup;
	}
	BStagsort(&rc, nb_floor, z_coord, index);
	for(i=0;i<*nb_floor;i++) (*floor)[i] = tmp[index[i]];
}

_FREE(tmp) ;
_FREE(index) ;
_FREE(comps) ;
return 1;

wrapup:
 _FREE(index) ;
 _FREE(tmp) ;
 _FREE(comps) ;
 if(floor && (*floor) )_FREE(*floor); 
 *nb_floor = 0;
 return 0;

}

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMGetDeckCmpt

  Abstract

 	Given a Volume, the function returns on what deck it is
 	laying on (NULL_OBJID if not found).

  Algorithm

		1/ determine the floor of the volume.
		2/ take a point on the floor and verify if it belongs
		   to a deck.
		   if the volume is not on a deck info = 0
		   if the volume is on more than one deck info = nb_deck

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/

int SMGetDeckCmpt(volume, mod_env, deck, info)
struct GRid 		*volume;  /* (I) volume id  	*/
struct GRmd_env		*mod_env; /* (I) mod env of the volume	*/
struct GRid		*deck;	  /* (O) the deck on which the volume is laying */
IGRint			*info;    /* (O) Info (warning) Nb of deck found */ 
/*
-fi */
{
int			i, status, nb_surf, nb_floor;
long			msg, nput, nret;
IGRdouble		angle, point[3], cht_tol, tol;
struct GRid		*floor;
struct GRobj_env	*surf;

surf = NULL;
nb_surf = 0;
floor = NULL;
nb_floor = 0;
deck->objid = NULL_OBJID;

nput = sizeof(cht_tol);
gr$get_chord_height_tolerance(	msg    = &msg,
                                sizbuf = &nput,
                                buffer = &cht_tol,
                                nret   = &nret);

if(!(msg&1)){
        printf("error gr$get_chord_height_tolerance\n");
        goto wrapup;
}
tol = 2*cht_tol;

angle = 25.;

status = SMGetFloor(volume, mod_env, angle, &nb_floor, &floor);
if(!(status & 1)){
	printf("ERROR SMGetFloor\n");
	goto wrapup;
}
if(nb_floor == 0 ){
	if(floor){free(floor);floor = NULL;}
	if(surf){free(surf);surf = NULL;}
	return 1;
}
for(i=0;i<nb_floor;i++){
	status = om$send(msg = message EMSsurface.EMget_point_on_surface(&msg,
				mod_env,
				0,
				1,
				point,
				NULL ),
			senderid = NULL_OBJID,
                        targetid = floor[i].objid,
                        targetos = floor[i].osnum );
	if(!(status & 1)){
		as$status();
		continue;
	}
	status = SMGetSurfPtIsOn(point, "deck", tol, &nb_surf, &surf);
	if(!(status & 1)){
		printf("ERROR SMGetSurfPtIsOn\n");
		continue;
	}

	if(info) *info = nb_surf;
	if(nb_surf > 1){
		/* the floor of the volume is laying on more than one deck ????*/
		deck->objid = surf[0].obj_id.objid;
		deck->osnum = surf[0].obj_id.osnum;
		break;
	}
	else if(nb_surf < 1){
		/* the floor of the volume is not laying on a deck ????*/
		continue;
	}
	else{
		deck->objid = surf[0].obj_id.objid;
		deck->osnum = surf[0].obj_id.osnum;
		break;
	}
}

if(floor){free(floor);floor = NULL;}
if(surf){free(surf);surf = NULL;}
return 1;

wrapup:

if(floor){free(floor);floor = NULL;}
if(surf){free(surf);surf = NULL;}
return 0;

}

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMGetCmptSide

  Abstract

 Given a Volume, the function returns on what side of the 
 hull (starboard or portside) it is 
 (1=starboard, 2= portside, 0= center line)

  Algorithm:

		1/ Get the range of the volume (2 pts P1 and P2)
		2/ Get the active ship cs and the SIDE attribute 
			(O, Vx,Vy,Vz, and direction of Vy)
		3/ compute N1 = Vx crossp OP1, N2 = Vx crossp OP2
		4/ if N1.Vz > 0 that means P1 is on SIDE 
		      otherwise P1 is on the other side	
		5/ if P1 and P2 are both on SIDE, side = SIDE
		   if P1 and P2 are both on the other side, side = other side
		   if P1 is on one side and P2 on the other, side = center line

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/


int SMGetCmptSide(volume, mod_env, side)
struct GRid 		*volume;  /* (I) volume id  	*/
struct GRmd_env		*mod_env; /* (I) mod env of the volume	*/
IGRint			*side;	  /* (O) the side of the hull the volume is laying */
/*
-fi */
{
int			i,status, cs_side;
BSrc			rc;
long			msg, nput, nret;
IGRboolean		world, glob_flag;
IGRchar			text[MAX_CHAR];
IGRdouble		origine[3], vect1[3], vect2[3], Vx[3], Vz[3],range[6], 
			N1[3], N2[3], cht_tol, dotp1, dotp2;
struct GRid		go_cs,  global;
struct GRmd_env		cs_env, global_env;
struct IGRlbsys		*p_geom;

world = TRUE;
*side = 0;

nput = sizeof(cht_tol);
gr$get_chord_height_tolerance(	msg    = &msg,
                                sizbuf = &nput,
                                buffer = &cht_tol,
                                nret   = &nret);

if(!(msg&1)){
        printf("error gr$get_chord_height_tolerance\n");
        goto wrapup;
}

status = om$send(msg = message GRgraphics.GRgetrang(&msg, 
				&mod_env->md_env.matrix_type,
				mod_env->md_env.matrix,
				&world,
				range),
			senderid = NULL_OBJID,
                        targetid = volume->objid,
                        targetos = volume->osnum );
if(!(status & 1)){
	as$status();
	printf("ERROR GRgraphics.GRgetrange\n");
	goto wrapup;
}


/* Getting active global data */

if(!SMGetActShipAtt(&global,NULL,&global_env) || global.objid == NULL_OBJID){
	ex$message(msgnumb = SM_E_SfNoGlob);
        goto wrapup;
}
status = om$send(msg = message SMmgr.SMGetAttTxt(&msg, "SIDE", text, 
						(IGRshort *) NULL),
		senderid = NULL_OBJID,
                targetid = global.objid,
		targetos = global.osnum);
as$status();

if(!(status & msg &1) ) {
	printf("ERROR, retrieving the attribute SIDE\n");
        goto wrapup;
}
if (strcmp(text, "starboard") == 0) cs_side = 1;
else cs_side =2;

/* Get the ship Cs geometry */

status = SMGetDefCs(FALSE,                  
                  (struct GRid *)NULL,   
	          (IGRshort *)NULL,      
		  &go_cs,                
		  (struct GRid *)NULL,                
		  &cs_env,           
		  &glob_flag);    
 
if(!status || glob_flag == FALSE || go_cs.objid == NULL_OBJID) {
	printf("ERROR, cannot get the active ship cs \n");
	goto wrapup;
}
status = om$send(msg = message GRvg.GRgenabsg(&msg,
                                        &cs_env.md_env.matrix_type,
                                        cs_env.md_env.matrix,
                                                 (char **)&p_geom ),
                   senderid = NULL_OBJID,
                   targetid = go_cs.objid,
                   targetos = go_cs.osnum );
as$status();
if (!(status & msg & 1)){
        printf("ERROR genabsg\n");
        goto wrapup;
}
for(i=0;i<3;i++) Vx[i] =  (* p_geom).matrix[4*i+0];
for(i=0;i<3;i++) Vz[i] =  (* p_geom).matrix[4*i+2];
for(i=0;i<3;i++) origine[i] =  (* p_geom).matrix[4*i+3];


/* compute the product vectoriel */

BSmkvec(&rc, vect1, origine, &range[0]);
BSmkvec(&rc, vect2, origine, &range[3]);
BScrossp(&rc, Vx, vect1, N1);
BScrossp(&rc, Vx, vect2, N2);

dotp1 = BSdotp(&rc, N1, Vz);
dotp2 = BSdotp(&rc, N2, Vz);


/* ---

  	PL Oct 93 : take into account the fact that the volume can be tangent 
	and all on one side (one point in on y axis => dotp ~ 0)
--- */


if( fabs(dotp1) < cht_tol ) dotp1 = 0;
if( fabs(dotp2) < cht_tol ) dotp2 = 0;


if( dotp1 >= 0 && dotp2 >= 0) *side = cs_side;
else if( dotp1 <= 0 && dotp2 <= 0) *side = 3 - cs_side;
else if( dotp1*dotp2 <= 0) *side = 0;


return 1;

wrapup:

return 0;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMCheckVector

  Abstract
 	This function checks if the given vector is approximately parallel 
	to the ship CS Vz . The allowed deviation is specified by the 
	argument angle.

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/

int SMCheckVector( vec, angle, parallel )
IGRvector		vec;  	   /* (I) vector  	*/
IGRdouble		angle;	   /* (I) maximum angle with Vz to be parallel */
IGRboolean		*parallel; /* (O) TRUE if vector is parallel	*/
/*
-fi */
{
int			i,stat;
long			msg;
struct GRid		cs_id, go_cs;
struct GRmd_env		cs_env;
IGRdouble		dotp, Vz[3];
BSrc			rc;
struct IGRlbsys		*p_geom;
extern IGRdouble	cos();
IGRvector		vec_copy;


angle = angle * M_PI / 180;

 /*
  * Get the Ship CS Vz.
  */

/* Get default Cs (ship or EMS cs) */

stat = SMGetDefCs(TRUE,                  /* Take EMS cs if no ship cs */
                  (struct GRid *)NULL,   /* Connected with Glob not needed */
	          (IGRshort *)NULL,      /* State not used */ 
		  &go_cs,                /* Graphic cs */
		  &cs_id,                /* Associative cs  */
		  &cs_env,               /* Mod env */
		 (IGRboolean *)NULL);    /* No flag needed */
 
if(!stat || go_cs.objid == NULL_OBJID) goto wrapup;


stat = om$send(msg = message GRvg.GRgenabsg
	       (&msg, &cs_env.md_env.matrix_type,
		cs_env.md_env.matrix, (char **) &p_geom),
	       senderid = NULL_OBJID,
	       targetid = go_cs.objid,
	       targetos = go_cs.osnum );
if(!(stat & msg & 1)){
	printf("ERROR  GRvg.GRgenabsg of the coord syst.\n");
	goto wrapup;
}
for(i=0;i<3;i++) Vz[i] = p_geom->matrix[4*i+2];
BSnorvec(&rc, Vz);

for(i=0; i<3; i++) vec_copy[i] = vec[i];
BSnorvec(&rc, vec_copy);
dotp = BSdotp(&rc, vec_copy, Vz);

if(fabs(dotp) > cos(angle) )   /* the vector is parallel */
   *parallel = TRUE;
else
   *parallel = FALSE;

return 1;

wrapup:
 return 0;

}
int SMPmeGetNbVol( comp, nb_vol)
struct GRid	comp;
IGRint		*nb_vol;
{

        IGRshort        *obj_type = NULL;
        int             tt_vol;
        long            status, msg;
        struct GRid     vol_id[SM_MAX_ALLOW_VOL],
                        col_id[SM_MAX_ALLOW_VOL];

	*nb_vol = 0;
        status = om$send( msg = message SMcomp.SMGetVolInfo(&msg,
                                SM_MAX_ALLOW_VOL, nb_vol, &tt_vol,
                                vol_id, col_id, obj_type, NULL),
                        senderid = comp.objid,
                        targetid = comp.objid,
                        targetos = comp.osnum);
	return 1;
}

/* Get arrtibutes for each compartment-volume which are: deck number, area and volume*/ 
int SMPmeGetVolAtt(comp, nb_vol, Coll)
struct GRid     comp;
IGRint          nb_vol;
struct ACrg_coll **Coll;
{
	
        IGRshort        *obj_type = NULL;
        int             num_vol, i, tt_vol;
        long            status, msg;
        struct GRid     vol_id[SM_MAX_ALLOW_VOL],
                        col_id[SM_MAX_ALLOW_VOL];
	char 		*att[4]={"solid","deck",
					"farea","volume"};

        status = om$send( msg = message SMcomp.SMGetVolInfo(&msg,
                                SM_MAX_ALLOW_VOL, &num_vol, &tt_vol,
                                vol_id, col_id, obj_type, NULL),
                        senderid = comp.objid,
                        targetid = comp.objid,
                        targetos = comp.osnum);

	if ( nb_vol >= num_vol )
		return 0;


	*Coll = _MALLOC ( 4, struct ACrg_coll );
	for (i=0; i<4; i++){
		strcpy((*Coll)[i].name,att[i]);
		(*Coll)[i].desc.type = AC_ATTRIB_TEXT;
		VDSGetAttTxt(&col_id[nb_vol],att[i],
					(*Coll)[i].desc.value.att_txt);

	}

	return 1;
}

/* Get Attributes for compartment-volumes: these are the frame side and usage */
int SMPmeGetParentCmpAtt(comp, Coll)
struct GRid     comp;
struct ACrg_coll **Coll;
{

        int              i, count;
        long            status;
        struct GRid     root;
        char            *att[3]={"frame","side","usage"};                      
  
        status = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT,&root,OM_K_MAXINT,NULL,0,0,&count),
                   senderid =  comp.objid,
                   targetid = comp.objid,
                   targetos = comp.osnum );
        if(status != OM_S_SUCCESS) {
                printf ("Could not get roots\n");
        }    
        
        *Coll = _MALLOC ( 3, struct ACrg_coll );
        for (i=0; i<3; i++){
                strcpy((*Coll)[i].name,att[i]);
                (*Coll)[i].desc.type = AC_ATTRIB_TEXT;
                VDSGetAttTxt(&root,att[i],
                                        (*Coll)[i].desc.value.att_txt);

        }

        return 1;
}       

end implementation Root; 

