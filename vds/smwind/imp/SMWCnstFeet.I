/* $Id: SMWCnstFeet.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smwind/imp / SMWCnstFeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMWCnstFeet.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
# Revision 1.2  1996/04/29  09:21:32  pinnacle
# Replaced: smwind/imp/SMWCnstFeet.I for:  by ksundar for vds.240
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
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 15 Jul 92	  creation date.
/*
/* */

class implementation SMwind;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "SMcomp_def.h"
#include "VDmem.h"

#include "AS_status.h"

from	ACrg_collect	import	ACget_named_attribute, ACadd_list_attribute;
from	ACrg_collect	import	ACmod_list_attribute;
from	GRlinear	import	GRgetpolyline, GRputpolyline;
from	GRcoords	import	GRcvt_to_wld_coords;

#define AS_DEBUG

/* ******************* MSG ACconstruct_feet () ************************	*/

method	ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
				IGRint count; struct GRid list[];
				struct GRmd_env *md_env;
				IGRint *fcount; struct GRid *feet_list )
{
 /* Root list:
 /*
 /* Wind area polygon macro definition:
 /*   temp:
 /*		- Wind area polygon dynamic collection.
 /*		- Coordinate system (Active at placement time).
 /*		- N * polygons. /*
 /*   Feet:
 /*		- N * polygons (projected on the corresponding plane.
 /* 
 /* */

 IGRlong 		status, loc_msg;
 IGRint			index, i, nb_plgs;
 IGRchar		tmpchar[81];
 IGRdouble		dpipo, c_coord;
 IGRint			p_type;
 struct IGRlbsys        *p_geom;
 IGRshort		mat_type, mat_type2;
 IGRdouble		matrix[16], matrix2[16], pl_pts[3], pl_n[3];
 struct IGRplane 	plane;
 IGRint			action;
 struct IGRpolyline     polyline;
 struct GRid		cs, plg_id;

 IGRlong                sizebuf, nret;
 struct IGRdisplay      display;
 IGRshort               level;

 struct	GRvg_construct  cst;

 extern GRclassid	OPP_GR3dpolygon_class_id;

 *fcount = 0;
 *rc     = 0;

 plane.point  = pl_pts;
 plane.normal = pl_n;

 /* Number of root line strings */
 nb_plgs = (IGRint) count - 2;

 /* Get the CS info for the plane construction */
 status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "", &cs, 
 						      &mat_type, matrix),
                        targetid = list[1].objid,
                        targetos = list[1].osnum );
 as$status();
 if(!(status & loc_msg & 1))
  {
   printf("ERROR getting cs info\n");
   goto wrapup;
  }

 status = om$send(msg = message GRvg.GRgenabsg(&loc_msg, &mat_type,
                                matrix,  (char **) &p_geom),
                   	targetid = cs.objid,
                   	targetos = cs.osnum );
 as$status();
 if(!(status & loc_msg & 1))
  {
   printf("ERROR getting cs info\n");
   goto wrapup;
  }
 /* Fill the cs matrix */
 for(i=0;i<16;i++) matrix[i] = (* p_geom).matrix[i];

 /* Set the construction list (get the active symb) .
 /* */

 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = md_env;
 cst.class_attr = NULL;
 cst.name       = NULL;
 cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;


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

 
 /* Loop for each root polygon:
 /* Copy the polygon and project it on the good corresponding plane.
 /* */

 *fcount = 0;
 for(index=0; index<nb_plgs; index++)
  { 
   /* Get the corresponding plane */
   sprintf(tmpchar,"p_type_%d", index);
   if(VDSGetAttDbl(&list[0], tmpchar, &dpipo) == 0) 
    {
     printf("Error in Wind area plg, no type defined for plg index: %d\n", index);
     goto wrapup;
    }
   p_type = (IGRint) dpipo;

   sprintf(tmpchar,"c_coord_%d", index);
   if(VDSGetAttDbl(&list[0], tmpchar, &c_coord) == 0) 
    {
     printf("Error in Wind area plg, no const. coord. defined for plg index: %d\n", index);
     goto wrapup;
    }

   for(i=0;i<3;i++) pl_pts[i] =  0;
   if(p_type == 1)
    {
     /* x/z plane */
     for(i=0;i<3;i++) pl_n[i] = matrix[1+4*i];
     pl_pts[1] = c_coord;
    }
   else if(p_type == 2)   
    {
     /* x/y plane */
     for(i=0;i<3;i++) pl_n[i] = matrix[2+4*i];
     pl_pts[2] = c_coord;
    }
   else
    {
     printf("Error bad plane type\n");
     goto wrapup;
    }

   /* The coordinate is given in the local CS => convert it */
   status = om$send(msg = message GRcoords.GRcvt_to_wld_coords(&loc_msg, 
				"rectangular", 1, pl_pts, pl_pts),
                   	targetid = cs.objid,
                   	targetos = cs.osnum );
   as$status();
   if(!(status & loc_msg & 1)) goto wrapup; 

   /* Get the linestring or polygon */
   status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg, "", &plg_id, 
 						      &mat_type2, matrix2),
                        targetid = list[2+index].objid,
                        targetos = list[2+index].osnum);
   as$status();
   if(!(status & loc_msg & 1)) goto wrapup; 

   action = 0;
   status = om$send(msg = message GRlinear.GRgetpolyline(&loc_msg, &mat_type2,
           				matrix2, &action, &polyline),
                        targetid = plg_id.objid,
                        targetos = plg_id.osnum);
   if(!(status & loc_msg & 1))
    {
     printf("error getting polyline info\n");
     goto wrapup;
    }

   if(polyline.num_points < 1) continue;
   polyline.points = _MALLOC( 3 * polyline.num_points, IGRdouble);

   action = 1;
   status = om$send(msg = message GRlinear.GRgetpolyline(&loc_msg, &mat_type2,
           				matrix2, &action, &polyline),
                        targetid = plg_id.objid,
                        targetos = plg_id.osnum);
   if(!(status & loc_msg & 1))
    {
     printf("error getting polyline info\n");
     goto wrapup;
    }

   /* project it on the plane */
   for(i=0;i<polyline.num_points;i++)
    {
     if(MAptplproj(&loc_msg, &polyline.points[3*i], &plane, &polyline.points[3*i]) != TRUE)
      {
       printf("Bad projection ...\n");
       goto wrapup;
      }
    }

   /* create the polygon */
   feet_list[*fcount].osnum = md_env->md_id.osnum;
   status = om$construct(classid = OPP_GR3dpolygon_class_id,
                         osnum   = feet_list[*fcount].osnum,
                         p_objid = &feet_list[*fcount].objid );
   if(!(status & loc_msg & 1))
    {
     printf("ERROR creating the polyline foot\n");
     goto wrapup;
    }

   cst.geometry = (IGRchar *) &polyline;
   status = om$send( msg = message GRgraphics.GRaltconstruct(&cst),
                        targetid = feet_list[*fcount].objid,
                        targetos = feet_list[*fcount].osnum);
   if(!(status & loc_msg & 1))
    {
     printf("error constructing polyline\n");
     goto wrapup;
    }

   (*fcount)++;
   _FREE(polyline.points);
  }
 
 /* Change the state to modify */
 status = om$send(msg = message SMmgr.SMChgState(SM_STATE, SM_MOD),
                  targetid = my_id );
 as$status();

 /* Clear if it was the error state */
 status = om$send(msg = message SMmgr.SMChgState(SM_CAL_ERR, (IGRshort) 0),
                  targetid = my_id );
 as$status();

 *rc = 1;
 return	OM_S_SUCCESS;

wrapup:

 /* Change the state to error */
 status = om$send(msg = message SMmgr.SMChgState(SM_CAL_ERR, SM_CAL_ERR),
                  targetid = my_id );
 as$status();

 *rc = 0;
 return	OM_W_ABORT;

}

end implementation SMwind;
 

