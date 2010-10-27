/* $Id: SMCompMass.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMCompMass.I
 *
 * Description:
 *
 *      This file implements functions related to the mass properties
 *	of a compartment.
 *
 * Dependencies:
 *
 *      SMcomp
 *
 * Revision History:
 *	$Log: SMCompMass.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/29  08:52:32  pinnacle
# Replaced: smcomp/imp/SMCompMass.I for:  by ksundar for vds.240
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
 *      04/24/92        Ch. Heraud      Creation date.
 *
 * -------------------------------------------------------------------------
 */
class implementation SMcomp;

#include "OMmacros.h"
#include "OMindex.h"
#include "exmacros.h"
#include "emsmass.h"
#include "EMSssprops.h"
#include "bserr.h"
#include "bstypes.h"

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "VDmem.h"

/* Prototypes */
#include "bsdistptpt.h"
#include "bssfevaln.h"
#include "bsnorvec.h"
#include "bsdotp.h"

#include "AS_status.h"

from 	EMSmassprop	import	EMset_density, EMinitialize, EMset_type, EMmpdelete;
from    EMSsurface	import	EMmassprop, EMareaprop;
from    EMSsubbs	import	EMget_props;

extern  GRclassid 	OPP_EMSplane_class_id, OPP_EMSsurface_class_id, 
			OPP_EMSmassprop_class_id;

#define AS_DEBUG


/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMCompMassProp

  Abstract

	This function computes the mass properties of the given volume.
  Returns
         
         OM_S_SUCCESS if success
         OM_E_ABORT   if fails

 -------------------------------------------------------------------------
*/
int SMCompMassProp(volume, op_type, mod_env, density, cht_fact, props)
struct GRid 		*volume;	/* volume id to evaluate 	(I) */
IGRint			op_type;	/* MASS_PROPERTIES, AREA_PROPERTIES (I) */
struct GRmdenv_info	*mod_env;	/* mod env of the object	(I) */
IGRdouble		density;	/* volume density		(I) */	
IGRdouble		cht_fact;	/* cht accurancy factor		(I) */
IGRdouble		*props;		/* the mass properties		(O) */
/*
-fi */

{
 IGRlong		loc_msg, status;
 struct GRid 		go, massprop;
 IGRshort		mat_type;
 IGRdouble		matrix[16], cur_cht;
 IGRint			i, nb_surf;
 OM_S_CHANSELECT 	to_object;
 IGRboolean     	my_cht;
 IGRint 		sizbuf, nret;
 struct GRmd_env 	mp_env, obj_env;
 extern OM_S_CHANSELECT AS_notification;

 
 status = om$send(msg = message NDnode.ASreturn_go(&go,&mat_type,matrix),
			senderid = NULL_OBJID,
			targetid = volume->objid,
			targetos = volume->osnum);
 if(!(status & 1))
  {
   go      	  = *volume; 
   obj_env.md_env = *mod_env;
  }
 else
  {
   obj_env.md_env.matrix_type 		      = mat_type;
   for(i=0;i<16;i++) obj_env.md_env.matrix[i] = matrix[i];
  }
 obj_env.md_id.objid = NULL_OBJID;
 obj_env.md_id.osnum = go.osnum;

 /*" go: %d, %d\n", go.objid, go.osnum */

 if(cht_fact < 0.00001)
  {
   /*" the cht factor: %lf is to small => no computation\n",cht_fact */
   return 0;
  }

 my_cht = FALSE;
 if(cht_fact < 0.999)
  {
   /*| Get the active cht */
   sizbuf = sizeof(IGRdouble);
   gr$get_chord_height_tolerance(msg = &loc_msg, 
 			         sizbuf = &sizbuf,
			         buffer = &cur_cht,
				 nret   = &nret);
   my_cht = TRUE;
   /*" current cht: %lf, used cht: %lf\n", cur_cht, cur_cht / cht_fact */
  }

 /*| Look if a EMSmassprop object already exist and if not, create one */
 massprop.objid = NULL_OBJID;
 
 /* There is some problems with the massprop object so it is recreated
 /* at each time and delete at the end
 /* */

#ifdef OLD_VERSION
  count = 0;
  status = om$get_channel_count(objid        = go.objid,
  	 		       osnum        = go.osnum,
     			       p_chanselect = &AS_notification,
  			       count        = &count);
  as$status();
  if(!(status&1) || count < 1)
   {
    /* No object on notify channel, so no EMSmassprop object */
   }
  else 
   {
    obj_id = _MALLOC(count, OM_S_OBJECT_LINKAGE);
    if(obj_id == NULL)
     {
      printf("Error, no dynamic space available\n");
      return 0;
     }
  
    i     = count;
    count = 0;
    status = om$get_channel_objects(objid        = go.objid,
  			           osnum        = go.osnum,
     			           p_chanselect = &AS_notification,
   				   list		= obj_id,
   				   size		= i,
   			           count        = &count);
      as$status();
   
      if(!(status&1) || count < 1)
       {
        printf("Strange error\n");
        _FREE(obj_id);
        return 0;
       }
      
       /* test if the object exist */
      for(i=0;i<count;i++)
       {
        om$get_classid(osnum     = obj_id[i].osnum,
                      objid     = obj_id[i].S_objid,
                      p_classid = &obj_class);
   
       if(om$is_ancestry_valid(subclassid = obj_class ,
                           superclassid = OPP_EMSmassprop_class_id ) == OM_S_SUCCESS)
        {   
          | This is the good one */
        massprop.objid = obj_id[i].S_objid;
         massprop.osnum = obj_id[i].osnum;
         break;
       }
      }
       Free the space */
     _FREE(obj_id);
    }
#endif   

 if(massprop.objid == NULL_OBJID)
  {
   struct GRvg_construct cst;

   /*| Create the massprop object */

   cst.msg        = &loc_msg;
   cst.newflag    = TRUE;
   cst.geometry   = NULL;
   cst.env_info   = &mp_env;
   cst.class_attr = NULL;
   cst.name       = NULL;
   cst.display    = NULL;
   cst.properties = 0;

   mp_env.md_id.osnum = go.osnum;
   status =ex$get_modid(mod_osnum = mp_env.md_id.osnum,
                        mod_id = &mp_env.md_id.objid);
   if(status != 1) 
    {
     printf("Error get mod_id\n");
     return 0;
    }
    
   mp_env.md_env.matrix_type = obj_env.md_env.matrix_type; 
   for(i=0;i<16;i++) mp_env.md_env.matrix[i] = obj_env.md_env.matrix[i];
   
   massprop.osnum = mp_env.md_id.osnum;

   status = om$construct(classid = OPP_EMSmassprop_class_id,
			 osnum   = massprop.osnum,
			 p_objid = &massprop.objid,
			 msg     = message GRvg.GRconstruct(&cst));
   as$status(action = RET_STATUS);
   /*" Massprop object construct: %d, %d\n", massprop.objid, massprop.osnum */

   /*| Connect the  masssprop object to the volume */
   status = om$make_chanselect(channame = "EMSmassprop.to_object",
			     p_chanselect = &to_object);
   as$status(action = RET_STATUS);

   status = om$send( msg = message Root.connect(to_object, 
						GRDGNLIMITS_MAX_I,
   						go.objid,
   						go.osnum,
						AS_notification,
						0),
			senderid = NULL_OBJID,
			targetid = massprop.objid,
			targetos = massprop.osnum);
   as$status(action = RET_STATUS);

   /*| Initialize the massprop object */
   status = om$send( msg = message EMSmassprop.EMinitialize(&loc_msg),
			senderid = NULL_OBJID,
			targetid = massprop.objid,
			targetos = massprop.osnum);
   as$status(action = RET_STATUS);
  }

 /*" Set the density to: %lf\n", density */
 status = om$send( msg = message EMSmassprop.EMset_density(&loc_msg, density),
			senderid = NULL_OBJID,
			targetid = massprop.objid,
			targetos = massprop.osnum);
 as$status(action = RET_STATUS);

 /*" Set the operation type: %d\n", op_type */
 status = om$send( msg = message EMSmassprop.EMset_type(&loc_msg, op_type),
			senderid = NULL_OBJID,
			targetid = massprop.objid,
			targetos = massprop.osnum);
 as$status(action = RET_STATUS);
 
 /*| Get the number of surfaces */
 status = om$send( msg = message GRowner.GRget_number_components(&loc_msg, 
 								 &nb_surf),
			senderid = NULL_OBJID,
			targetid = go.objid,
			targetos = go.osnum);
 if(!(status & 1 & loc_msg)) nb_surf = 0;

 if(my_cht)
  {
   IGRdouble cht;

   cht = cur_cht / cht_fact;
   sizbuf = sizeof(IGRdouble);
   gr$put_chord_height_tolerance(msg = &loc_msg, 
 			         sizbuf = &sizbuf,
			         buffer = &cht);
  }

 switch(op_type)
  {
   IGRdouble 	diagonal, center[3];
   GRrange	range;
   IGRboolean	world;
   BSrc		rc;

   case MASS_PROPERTIES:

    /*| Case MASS_PROPERTIES, get the range */
    world = TRUE;

     
    status = om$send( msg = message GRgraphics.GRgetrang(&loc_msg, 
 							 &obj_env.md_env.matrix_type,
							 obj_env.md_env.matrix,
							 &world,
							 range),
			senderid = NULL_OBJID,
			targetid = go.objid,
			targetos = go.osnum);
    as$status(action = RET_STATUS);
    /*"range: %lf, %lf,%lf\n",range[0],range[1],range[2]*/
    /*"range: %lf, %lf,%lf\n",range[3],range[4],range[5]*/
    diagonal = BSdistptpt(&rc, range, &range[3]);
    /*" diagonal range: %lf, nb surfaces: %d\n", diagonal, nb_surf */
    
    for(i=0;i<3;i++) center[i] = 0;
    status = om$send( msg = message EMSsurface.EMmassprop(&loc_msg, 
 							  nb_surf,
							  diagonal,
							  &obj_env,
							  1.,
							  center,
							  &density,
							  props),
			senderid = NULL_OBJID,
			targetid = go.objid,
			targetos = go.osnum);
    break;

   case AREA_PROPERTIES:

    for(i=0;i<3;i++) center[i] = 0;
    status = om$send( msg = message EMSsurface.EMareaprop(&loc_msg, 
 							  FALSE,
							  nb_surf,
							  &obj_env,
							  1.,
							  center,
							  props),
			senderid = NULL_OBJID,
			targetid = go.objid,
			targetos = go.osnum);
    break;
     

   default:
    printf("Bad operation type\n");
    if(my_cht)
     {
      sizbuf = sizeof(IGRdouble);
      gr$put_chord_height_tolerance(msg = &loc_msg, 
 			         sizbuf = &sizbuf,
			         buffer = &cur_cht);
     }
    return 0;
   }

 if(my_cht)
  {
   /*" Restore the cht to: %lf\n", cur_cht */
   sizbuf = sizeof(IGRdouble);
   gr$put_chord_height_tolerance(msg    = &loc_msg, 
 			         sizbuf = &sizbuf,
			         buffer = &cur_cht);
  }
 as$status(action = RET_STATUS);

 /* Delete the mass prop object because of some trouble */
 status = om$send( msg = message EMSmassprop.EMmpdelete(&loc_msg, &mp_env),
 			senderid = NULL_OBJID,
 			targetid = massprop.objid,
 			targetos = massprop.osnum);
 as$status();

 /*^
 for(i=0;i<NUMB_PROPS;i++) printf("mass props(%d): %g\n", i, props[i]);
 */
 return 1;
}



/*+fi
 -------------------------------------------------------------------------
  Internal Function SMCompFloorProp

  Abstract

 Given a volume, return the floor area. The Vz Ship Cs is used to 
 determine which surface can be considered as floor 

 If a surface is not planar the normal vector is taken at 0.5, 0.5. This
 can give strange result but work well for almost all the cases we have.

  Returns
         
         OM_S_SUCCESS if success
         OM_E_ABORT   if fails

 -------------------------------------------------------------------------
*/

int SMCompFloorProp(volume, mod_env, density, cht_fact, props)
struct GRid 		*volume;	/* volume id to evaluate 	(I) */
struct GRmd_env		*mod_env;	/* mod env of the object	(I) */
IGRdouble		density;	/* volume density		(I) */	
IGRdouble		cht_fact;	/* cht accurancy factor		(I) */
IGRdouble		*props;		/* properties			(O) */
/*
-fi */
{
int			i,k,stat, nb_comps, count, num_normals;
long			msg;
struct GRid		*comps, cs_id, go_cs;
struct GRmd_env		cs_env;
GRclassid		classid;
struct IGRplane		plane;
IGRdouble		dotp, pldef[6], normal[3], base[3], Vz[3], sf_props[20];
struct IGRbsp_surface 	*surf;
BSrc			rc;
struct IGRlbsys		*p_geom;
IGRuchar		geom_props;


comps = NULL;
nb_comps = 0;
props[11] = 0.;

 /*
  * Get all the surfaces and the normal (0.5, 0.5 if no planar).
  * Get the Ship CS Vz.  
  * if the surface normal is ~ Vz => belong to the floor area.
  * call SMCompMassProp() with the interesting surface.
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
	       {
		 /* Jean: Change for 2.2. Before pass normal in BSsfevaln */
		 /* But prototypes is incorrect                           */
		 IGRvector vect_norm[1]; 
		 
		 BSsfevaln(surf, .5, .5, 1, &num_normals, base, vect_norm,&rc);
		 if(rc != BSSUCC){
		   printf("ERROR BSsfevaln\n");
		   goto wrapup;
		 }
		 if(geom_props & EMSIS_NRML_REVERSED) 
		   for(k=0;k<3;k++) normal[k] = -vect_norm[0][k];
		 else
		   for(k=0;k<3;k++) normal[k] = vect_norm[0][k];
	       }
		
  	}
 	else{
		printf("ERROR invalid type of object\n");
		goto wrapup;
	}
	
	BSnorvec(&rc, normal);
	dotp = BSdotp(&rc, normal, Vz);
	if(dotp > .9){
		/* the surface is a floor */
		if( SMCompMassProp(&comps[i], AREA_PROPERTIES, &mod_env->md_env,
			density, cht_fact, sf_props) !=1){
				printf("ERROR  SMCompMassProp\n");
				goto wrapup;
			}
		props[11] = props[11] + sf_props[11];
	}

} 

 _FREE(comps) ;
 return 1;

wrapup:
 _FREE(comps) ;
 return 0;

}

end implementation SMcomp;

