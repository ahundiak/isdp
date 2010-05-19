/* $Id: SMSketchVoli.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMSketchVoli.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSketchVoli.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/01/08  16:55:46  pinnacle
# tr179802488
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/02/28  10:55:54  pinnacle
# Replaced: smspace/vol/SMSketchVoli.I for:  by ksundar for vds.240
#
# Revision 1.2  1996/01/24  20:06:16  pinnacle
# Replaced: ./smspace/vol/SMSketchVoli.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/08/99  ah      tr179802488, Added debug statements and better error msgs
 *                   No functionality was actually changed
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 16 Oct 92	  creation date.
/*
/* */

class implementation SMSketchVol;

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
#include "bserr.h"
#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"

#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "AS_status.h"

// #define vdsDEBUG 1
#include "v_dbgmacros.h"

#define AS_DEBUG

from	EMSsfboolean	import	EMboolean;
from	EMSdpr		import	EMmake_primitive1;
from    EMSsurface      import  EMgetactiveid;
from    EMSsubbs        import  EMreduce_range;
from    EMSproject	import	EMplace_surface_of_projection;
from    EMSsfsolid	import	EMcap_thyself;
from    GRcompcurve	import	EMmakecomp;

extern	GRclassid	OPP_EMSproject_class_id;
extern	GRclassid	OPP_EMSsfsolid_class_id;
extern	GRclassid	OPP_EMSslboolean_class_id;
extern	GRclassid	OPP_GR3dpoint_class_id;

#define MAX_SK_CRV	98

/* ****************** MSG ACmplace_from_def () ************************	*/

method ACmplace_from_def(int *rc, prop; 	char rep;char *macro_name;
	       	int num_temp;	struct GRid *temp_list;
		struct GRid *def_occ;
		struct GRmd_env *md_env )

{
	IGRlong status;

	/*
	 * Put the properties to no proptect:
		- Does not create source,
		- Does not verify the number (variable number of templates) 
		- Does not verify the template types
	 */

	prop = prop | AChdr_noprotect | ACcant_place_sym;
	status =
	om$send(msg = message ACncpx.ACmplace_from_def(rc, prop, rep, 
		         macro_name, num_temp, temp_list, def_occ, md_env),
                mode     = OM_e_wrt_message,
                targetid = my_id );

	return	status ;
}


/* *********************** MSG GRgetobjinfo () ************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{

	strcpy(info->type, "Sketch Volume");
	*rc = MSSUCC;
	return	OM_S_SUCCESS;
}


/* ******************* MSG ACconstruct_feet () ************************	*/

method	ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
				IGRint count; struct GRid list[];
				struct GRmd_env *md_env;
				IGRint *fcount; struct GRid *feet_list )
{
 IGRlong 		status, loc_msg;
 IGRlong                sizebuf, nret;
 struct IGRdisplay      display;
 IGRshort               level;
 struct GRobj_env       ProfId, VolId;
 struct GRobj_env       Crv[MAX_SK_CRV];
 struct GRlc_info       CrvInfo[MAX_SK_CRV];
 IGRboolean		world, RevNor;
 IGRdouble		range[6], vz[3], startPoint[3], endPoint[3];
 IGRdouble		delta, cht;
 struct GRid		SurfProj, CpVolId, PrimSol, ProjCv;
 struct GRmd_env	my_env;
 struct	GRvg_construct  cst;
 unsigned short  	option;
 IGRint			i, k;
 char			status_str[80];
 enum EMSbooltype  	bool_type;
 struct GRid 		NewId, tmp_id;
 struct GRid            active_id, top_lm_id;
 GRclassid	 	pjClassid;
 struct IGRplane	Plane;
 struct GRprops     	GRprops;
 struct ret_struct      str;

 __DBGpr_com("SMSketchVol.ACconstruct_feet entering...\n");

 feet_list[0].objid = NULL_OBJID;

 my_env = *md_env;
 my_env.md_id.objid = NULL_OBJID; /* Computation out of RTREE */

 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = &my_env;
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

 /* Get the expression mask */
 status = om$send(msg = message NDnode.NDgive_structure(&loc_msg, &str, NULL),
                        targetid= list[0].objid,
                        targetos= list[0].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;
 if(str.var.root_pm_st.value > 0) RevNor = TRUE;
 else				  RevNor = FALSE;

 status = om$send(msg = message NDnode.ASreturn_go(&VolId.obj_id,
				&VolId.mod_env.md_env.matrix_type, 
				VolId.mod_env.md_env.matrix),
			targetid= list[1].objid,
			targetos= list[1].osnum ) ;
 if(!(status & 1)) goto wrapup ;
 VolId.mod_env.md_id.objid = NULL_OBJID;
 VolId.mod_env.md_id.osnum = VolId.obj_id.osnum;
 

 if((count-2) > MAX_SK_CRV) count = MAX_SK_CRV + 2;
 k = 0;
 for(i=2;i<count;i++)
  {
   status = om$send(msg = message NDnode.ASreturn_go(&Crv[k].obj_id,
				&Crv[k].mod_env.md_env.matrix_type, 
				Crv[k].mod_env.md_env.matrix),
			targetid= list[i].objid,
			targetos= list[i].osnum ) ;
   if(!(status & 1)) goto wrapup ;
   Crv[k].mod_env.md_id.objid = NULL_OBJID;
   Crv[k].mod_env.md_id.osnum = Crv[k].obj_id.osnum;

   /* Need to copy */
   status = om$send(msg = message GRgraphics.GRcopy(&loc_msg, &Crv[k].mod_env,
                                     cst.env_info, &CrvInfo[k].located_obj.objid),
			senderid = NULL_OBJID,
                        targetid = Crv[k].obj_id.objid,
	                targetos = Crv[k].obj_id.osnum);
   if(!(status & loc_msg & 1)) goto wrapup ;
   CrvInfo[k].located_obj.osnum = cst.env_info->md_id.osnum;
   CrvInfo[k].module_info       = *(cst.env_info);
   k++;
  }

 __DBGpr_com("Did the parent stuff\n");
 
 if(count == 3)
  {
   ProfId.obj_id  = CrvInfo[0].located_obj;
   ProfId.mod_env = CrvInfo[0].module_info;
  }
 else
  {
   extern GRclassid	OPP_GRcompcurve_class_id;
   IGRlong		Rotten;

   /* The assumption is that we can make a composite curve */
   __DBGpr_com("Making a profile curve\n");
 
   ProfId.obj_id.osnum = cst.env_info->md_id.osnum;
   status = om$construct(classid = OPP_GRcompcurve_class_id,
                         p_objid = &ProfId.obj_id.objid,
                         osnum   = ProfId.obj_id.osnum);
   if(!(status & 1)) goto wrapup;

   /* Note that the curve has the orient. of the first one (RevNor) */
   status = om$send(msg = message GRcompcurve.EMmakecomp(&loc_msg, cst.env_info, 
   							k, CrvInfo, &Rotten),
				targetid = ProfId.obj_id.objid,
				targetos = ProfId.obj_id.osnum);
   if(!(status & loc_msg & 1) || Rotten != -1) 
    {
     printf("Error, cannot make the composite curve\n");
     goto wrapup;
    }
   ProfId.mod_env = *(cst.env_info);
  }
 __DBGpr_com("Got the profile\n");

 /* Get the range of the volume */
 world = TRUE;
 status = om$send(msg = message GRgraphics.GRgetrang(&loc_msg, 
				&VolId.mod_env.md_env.matrix_type, 
				VolId.mod_env.md_env.matrix,
                        	&world, range),
			targetid = VolId.obj_id.objid,
			targetos = VolId.obj_id.osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;

 __DBGpr_com("Got the volume range\n");

#if vdsDEBUG
 printf("Volume range %.2f,%.2f,%.2f %.2f,%.2f,%.2f\n",
	range[0],range[1],range[2],range[3],range[4],range[5]);
#endif

 /* We concidere for test that high is vz */

 /* Get the projection axis */
 vz[0] = 0;
 vz[1] = 0;
 vz[2] = 1;

 /* Define the start and end point */
 for(i=0;i<3;i++)
  {
   startPoint[i] = 0;
   endPoint[i]   = 0;
  }

 /* Add a small delta ... */
 sizebuf = sizeof(cht);
 gr$get_chord_height_tolerance(msg    = &loc_msg,
                               sizbuf = &sizebuf,
                               buffer = &cht,
                               nret   = &nret);
 delta = 2 * cht;
 if(range[2] > range[5]) 
  {
   startPoint[2] = range[5] - delta;
   endPoint[2]   = range[2] + delta;
  }
 else
  {
   startPoint[2] = range[2] - delta;
   endPoint[2]   = range[5] + delta;
  }

 /* If the curve is not planar */
 /* Find the middle point an create a plane to project the curve on */
 /* This is done because a cap can only be done by planes */
 /* The surface of projection doest not work if it is inside the
 /* start and end point. Making the projection in every case solves
 /* this problem.
 /* */
 Plane.normal = vz;
 Plane.point  = startPoint;

 status = EFproject_any_curve_on_planen(&loc_msg, &cst, &ProfId.obj_id,
					&ProfId.mod_env, &Plane, vz,
					&ProjCv, &pjClassid);
 if(!(status & 1 & loc_msg)) 
  {
   printf("Warnning, Bad curve projection\n");
   goto wrapup;
  }

 __DBGpr_com("Made the curve planar");
 
 /* No longer needs the composite */
 om$send(msg = message GRgraphics.GRdelete(&loc_msg, cst.env_info),
				targetid = ProfId.obj_id.objid,
				targetos = ProfId.obj_id.osnum);

 if(om$is_ancestry_valid(superclassid = OPP_GR3dpoint_class_id,
			 subclassid   = pjClassid ) == OM_S_SUCCESS) 
  {
   om$send(msg = message GRgraphics.GRdelete(&loc_msg, cst.env_info),
				targetid = ProjCv.objid,
				targetos = ProjCv.osnum);
   goto wrapup;
  } 
 
 /* Verify if the curve is close else try to do it */
 status = om$send( msg = message GRvg.GRgeomprops(&loc_msg,
              				&cst.env_info->md_env.matrix_type, 
					cst.env_info->md_env.matrix, 
	      				&GRprops),
                        targetid = ProjCv.objid,
                        targetos = ProjCv.osnum );
 if(!((loc_msg)&status&1))
  {
   printf("Error getting projection curve info (remove it)\n");
   goto wrapup;
  }

 if(!GRprops.planar) 
  {
   printf("Warning projected curve not planar\n");
  }

 if(!GRprops.phy_closed)
  {
   struct GRid 		cv1, cv2;

   __DBGpr_com("Closing the curve");

   /* Close it to the range */
   if(!(SMExtRng(range, 1.5 * delta) & 1))
    {
     printf("Error in SMExtRng\n");
     goto wrapup;
    }
   __DBGpr_com("Closing the curve, SMExtRng ");
   if(!(SMExtToRange(&cst, &ProjCv, cst.env_info, range, vz, delta, &cv1, &cv2) & 1))
    {
     printf("Error in SMExtToRange\n");
     goto wrapup;
    }
   __DBGpr_com("Closing the curve, SMExtToRange ");
   if(cv1.objid == NULL_OBJID && cv2.objid == NULL_OBJID)
    {
     printf("Error in SMExtToRange (2)\n");
     goto wrapup;
    }
   
   if(cv1.objid == NULL_OBJID || cv2.objid == NULL_OBJID)
    {
      om$send(msg = message GRgraphics.GRdelete(&loc_msg, cst.env_info),
	      targetid = ProjCv.objid,
	      targetos = ProjCv.osnum);
      if     (cv1.objid == NULL_OBJID) ProjCv = cv2;
      else   if(cv2.objid == NULL_OBJID) ProjCv = cv1;
   __DBGpr_com("Closing the curve, one is NULL ");
    }
   else
    {
     IGRdouble	u, Pt[3];
     IGRint	Inside;
     static IGRdouble tbu[11] = {0.11,0.73,0.44,0.33 ,0.87,0.51,0.94,
				   0.06,0.22,0.63,0.79};
     int choice = 1; /* Default choose curve 1 */
     int choice1 = 0,choice2 = 0;
     
   __DBGpr_com("Some sort of curve testing");

     /* For at least two value of parameter, find curve to choose */
     /* If two different solutions, test and choose majority */
     i = 0;
     while(i < 11) 
      {
	__DBGpr_int("Some sort of curve testing loop",i);
	u = tbu[i];

	/* 
	 *  Find the good one:
	 *  Get a point on the curve, find the tg, make the cross pt
	 *  place a point and verify that it is inside
	 */
	
	if(!(SMGetInnerPt(&ProjCv, cst.env_info, u, vz, delta, RevNor, Pt) & 1))
	 {
	   printf("Error in SMGetInnerPt");
	   goto wrapup;
	 }
	if(!(SMPtInside(&cv1, cst.env_info, Pt, &Inside) & 1)) goto wrapup;
	if (Inside == 1) choice1++;
	else if(Inside == 0)  
	 {
	   if(!(SMPtInside(&cv2, cst.env_info, Pt, &Inside) & 1))
	     goto wrapup;
	   if(Inside == 1) choice2++;
	 }
#ifdef JJ_DEBUG
	printf("%d iteration choice1 = %d choice2 = %d\n",i+1,choice1,choice2); 
#endif
	if(choice1 + choice2 >= 2) 
	 {
	   if(choice1 > choice2) {choice = 1; break;}
	   else if(choice1 < choice2) {choice = 2; break;}
	 }
	i++;
      }
    
     /* Delete non use curve */
     /* delete the projected curve and non use composite */
     om$send(msg = message GRgraphics.GRdelete(&loc_msg, cst.env_info),
	     targetid = ProjCv.objid,
	     targetos = ProjCv.osnum);
     if(choice == 2)
      {
	om$send(msg = message GRgraphics.GRdelete(&loc_msg, cst.env_info),
		targetid = cv1.objid,
		targetos = cv1.osnum);
	ProjCv = cv2;
      }
     else
      {
	om$send(msg = message GRgraphics.GRdelete(&loc_msg, cst.env_info),
		targetid = cv2.objid,
		targetos = cv2.osnum);
	ProjCv = cv1;
      }
   }
 }
 __DBGpr_com("Got the curve\n");

 /* Create a surface of projection */
 SurfProj.osnum = my_env.md_id.osnum;
 status = om$construct(classid = OPP_EMSproject_class_id,
                       osnum   = SurfProj.osnum,
                       p_objid = &SurfProj.objid);
 if(!(status & 1)) goto wrapup;

 status = om$send(msg = message EMSproject.EMplace_surface_of_projection(
					&cst,
					&ProjCv,
					&my_env,
					NULL,	
					0,
					startPoint,
					endPoint,
					FALSE,
					&SurfProj.objid ),
		targetid = SurfProj.objid,
		targetos = SurfProj.osnum ) ;
 if(!(status & loc_msg & 1)) 
  {
   printf("Error skecth solid when contructing the surf of projection\n");
   goto wrapup ;
  }
 __DBGpr_com("Made the surface\n");

 /* Cap the surface */
 PrimSol.osnum = my_env.md_id.osnum;
 status = om$construct(classid = OPP_EMSsfsolid_class_id,
                       osnum   = PrimSol.osnum,
                       p_objid = &PrimSol.objid);
 if(!(status & 1)) goto wrapup;

 status = om$send(msg = message EMSsfsolid.EMcap_thyself(&loc_msg, &cst, 
							 &SurfProj.objid),
 		targetid = PrimSol.objid,
 		targetos = PrimSol.osnum);
 if(!(status & loc_msg & 1)) 
  {
   printf("Error skecth solid when capping surface\n");
   goto wrapup;
  }

 __DBGpr_com("Capped the surface\n");

 /* Make the boolean operation (Union) */

 /* A copy of the root must be done */
 CpVolId.osnum    = my_env.md_id.osnum;

 status = om$send(msg = message GRgraphics.GRcopy(&loc_msg, &VolId.mod_env,
                                     &my_env, &CpVolId.objid),
                        targetid = VolId.obj_id.objid,
	                targetos = VolId.obj_id.osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;


 feet_list[0].osnum = my_env.md_id.osnum;
 status = om$construct(classid = OPP_EMSslboolean_class_id,
                       osnum   = feet_list[0].osnum,
                       p_objid = &feet_list[0].objid );
 if(!(status & 1)) goto wrapup;

 option = EMSsfbool_opt_noredraw | EMSsfbool_opt_HandleStop;

 bool_type      =  EMSbool_intersect;
 status_str[0]  = '\0';
 cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 status = om$send(msg = message EMSsfboolean.EMboolean(&loc_msg, 
		&my_env.md_env.matrix_type, my_env.md_env.matrix, 
		CpVolId.objid, 1, &PrimSol.objid, &cst,
		bool_type, option, status_str, NULL, NULL, NULL, NULL),
           targetid = feet_list[0].objid,
	   targetos = feet_list[0].osnum  );
 if(!(status & loc_msg & 1))
  {
   printf("Sketch Volume, error making the boolean union\n");
   goto wrapup;
  }
 __DBGpr_com("Did the boolean\n");

 /* To be sure to get the top dpr */
 status = om$send(msg = message EMSsurface.EMgetactiveid(&loc_msg, 
                            &active_id, &top_lm_id),
                        targetid = feet_list[0].objid,
                        targetos = feet_list[0].osnum);
 if(!(status & loc_msg & 1)) 
  { 
   printf("Warning getting the top dpr\n");
   active_id = feet_list[0];
  }

 /* This compress the dpr tree and compress the range box */
 status = om$send(msg = message EMSdpr.EMmake_primitive1(&loc_msg, &my_env,
                                   &tmp_id),
	        targetid = active_id.objid,
		targetos = active_id.osnum);
 if(!(status & loc_msg & 1)) 
  { 
   printf("Error compressing dpr\n");
   goto wrapup;
  }
 feet_list[0] = tmp_id;

 __DBGpr_com("Compressed the boolean\n");

 if(md_env->md_id.objid != NULL_OBJID)
  {
   /* Add the resulting boolean solid in the rtree */
   status = om$send(msg = message GRgraphics.GRaddwrng(&loc_msg, md_env),
                                targetid = feet_list[0].objid,
                                targetos = feet_list[0].osnum);
   if(!(status&1)) 
    {
     printf("Failed adding the resulting boolean solid to the rtree\n");
    }
  }

 /* reduce the range tree */
 /* The returned NewId is a plane !!!!! */
 status = om$send(msg = message EMSsubbs.EMreduce_range(&loc_msg, md_env,
                           &NewId.objid, 0),
                        targetid = feet_list[0].objid,
                        targetos = feet_list[0].osnum);
 if(!(status & loc_msg & 1)) 
  {
   printf("Warning range not reduced\n");
  }
 __DBGpr_com("Reduced the range\n");

 /* delete the projected curve */
 om$send(msg = message GRgraphics.GRdelete(&loc_msg, cst.env_info),
				targetid = ProjCv.objid,
				targetos = ProjCv.osnum);
 /* That's all folk */
 __DBGpr_com("SMSketchVol.ACconstruct_feet worked\n");

 *fcount = 1;
 *rc = MSSUCC;
 return	OM_S_SUCCESS;

 wrapup:

 // TR179802488
 printf("SMSketchVol, %d failed to recompute\n",my_id);
 sprintf(status_str,"SMSketchVol, %d failed to recompute",my_id);
 UI_status(status_str);
 
 *fcount = 0;
 *rc = MSFAIL;
 return	OM_W_ABORT;
}


/*
	----------------------------------------------------------
 */

/*   Modif PL 06-29-93  
	Kluddge waiting that the feet management is correctly done !!!!. */


method ACgive_path(int *suc;struct GRid *go_obj;char *foot_name)
{
        int i,sts;
        struct GRid pied;
        OM_S_CHANSELECT chansel;

        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRcmpowner.to_components";

        /**** must find pied see give_foot ****/
        pied.objid = NULL_OBJID;
        sts = om$get_objid_at_index
                             ( object =         me,
                               p_chanselect =   &chansel,
                               index =          0,
                               objidaddr =      &pied.objid,
                               osnumaddr =      &pied.osnum);

        if( (1&sts) && pied.objid != NULL_OBJID ){
            /*| get the index of the object go_obj*/
            get_index_of_surf(pied, &i, *go_obj );
            if( i != -1 ){
                sprintf(foot_name,"$%d", i );
                /*"ACgivepath, foot_name created: %s\n ",foot_name */
                return ( *suc =OM_S_SUCCESS );
            }
        }

        /*"ACgivepath failed, call normal message \n"*/
        return om$send(msg= message ACncpx.ACgive_path
                                                (suc,go_obj,foot_name),
                        targetid=my_id,
                        mode = OM_e_wrt_message);
}

method ACreturn_foot(long *suc;char *foot_name; struct GRid *foot_GRid;
                     IGRshort *mat_type; IGRdouble *matrix)
{
        int ix;         /* index */
        int sts,loc_msg;
        OM_S_CHANSELECT chansel;
        struct GRid pied;

        *suc = 0;

        if( foot_name[0] != '$' ){
                return om$send( msg = message ACncpx.ACreturn_foot
                                        ( suc, foot_name, foot_GRid,
                                          mat_type, matrix),
                         targetid = my_id,
                         mode = OM_e_wrt_message);
        }
        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRcmpowner.to_components";

        /**** must find real feet
        /**** we assume this is the 1st one on the channel to_component
        /* */
        pied.objid = NULL_OBJID;
        sts = om$get_objid_at_index
                             ( object =         me,
                               p_chanselect =   &chansel,
                               index =          0,
                               objidaddr =      &pied.objid,
                               osnumaddr =      &pied.osnum);
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
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjSketchVol ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMSketchVol;
 

