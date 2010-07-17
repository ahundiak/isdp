/* $Id: VLunwprjfc.I,v 1.9 2002/05/17 18:24:32 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwprjfc.I
 *
 * Description: Functions related to the projection or mapping of
 *		Featute Objects.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwprjfc.I,v $
 *      Revision 1.9  2002/05/17 18:24:32  ramarao
 *      Fixed TR# 6349.
 *
 *      Revision 1.8  2001/12/03 22:51:06  ramarao
 *      changes for CR# MP 5082
 *
 *      Revision 1.7  2001/10/21 17:36:13  ramarao
 *      Implemented CR# 5082.
 *
 *      Revision 1.6  2001/07/01 16:37:15  ramarao
 *      Fixed CR# 5351.
 *
 *      Revision 1.5  2001/03/07 17:57:45  ramarao
 *      Fixed a crash problem.
 *
 *      Revision 1.4  2001/03/07 16:37:55  ramarao
 *      Fixed a crash problem.
 *
 *      Revision 1.3  2001/02/20 01:07:44  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:01:31  ramarao
 *      *** empty log message ***
 *
# Revision 1.8  2000/12/13  20:19:26  pinnacle
# Replaced: loft/src/unwext/VLunwprjfc.I for:  by jpulapar for Service Pack
#
# Revision 1.7  2000/12/13  16:09:50  pinnacle
# Replaced: loft/src/unwext/VLunwprjfc.I for:  by rchennup for Service Pack
#
# Revision 1.6  2000/10/31  17:01:26  pinnacle
# Replaced: loft/src/unwext/VLunwprjfc.I for:  by rchennup for Service Pack
#
# Revision 1.3  2000/05/15  21:24:54  pinnacle
# Replaced: loft/src/unwext/VLunwprjfc.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/04/25  15:30:04  pinnacle
# Replaced: loft/src/unwext/VLunwprjfc.I for:  by azuurhou for spx
#
# Revision 1.1  2000/04/21  21:53:06  pinnacle
# Created: loft/src/unwext/VLunwprjfc.I by rchennup for Service Pack
#
# Revision 1.11  2000/03/23  20:44:20  pinnacle
# Replaced: src/unwext/VLunwprjfc.I for:  by impd252 for loft
#
# Revision 1.9  2000/03/08  16:09:30  pinnacle
# Modified VLprojectLine routine for boundary mesh option.
#
# Revision 1.8  2000/03/01  18:50:04  pinnacle
# Added mapsource function to map field cuts.
#
# Revision 1.7  2000/02/08  17:15:36  pinnacle
# Added a check in VLprojectLine function to see the projected points constitutes a single point.
#
# Revision 1.6  1999/12/30  12:55:50  pinnacle
# Replaced VLunwprjfc.I for label_loft macro by jpulapar for loft
#
# Revision 1.5  1999/05/21  16:01:56  pinnacle
# (No comment)
#
# Revision 1.4  1999/05/18  15:59:18  pinnacle
# (No comment)
#
# Revision 1.3  1999/04/09  21:20:54  pinnacle
# Rama Rao SP08
#
# Revision 1.2  1998/10/26  11:03:18  pinnacle
# Replaced: src/unwext/VLunwprjfc.I for:  by smpathak for loft
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.6  1998/04/26  14:18:58  pinnacle
# Replaced: src/unwext/VLunwprjfc.I for:  by impd for loft
#
# Revision 1.5  1998/04/23  08:43:06  pinnacle
# Replaced: src/unwext/VLunwprjfc.I for:  by rchennup for loft
#
# Revision 1.4  1998/02/24  15:40:34  pinnacle
# Replaced: src/unwext/VLunwprjfc.I for:  by impd for loft
#
# Revision 1.3  1998/01/28  15:24:58  pinnacle
# Replaced: src/unwext/VLunwprjfc.I for:  by rchennup for loft
#
# Revision 1.2  1997/11/03  21:51:28  pinnacle
# Replaced: src/unwext/VLunwprjfc.I for:  by rchennup for loft
#
# Revision 1.1  1997/10/28  15:31:18  pinnacle
# Created: src/unwext/VLunwprjfc.I by rchennup for loft
#
 *
 * History:
 * MM/DD/YY   AUTHOR    DESCRIPTION
 * 10/28/97   Rama Rao  File Creation
 * 04/26/98   Adz	Only call AddFunctions when unwrap worked
 * 10/26/98   Sandeep	TR179801541
 * 03/17/99   ah        Added checks to prevent allocing 0 bytes
 * 04/09/99   ah        Rama Rao SP08 Fixes
 * 08/30/99   Jayadev   VLgetGraphics_from__text() for label_loft macro 
 * 02/08/00   RR        Added a check in VLprojectLine function to see the
 *			projected points constitutes a single point.
 * 03/01/00   RR	Added mapsource function to map field cuts.
 * 12/13/00   RR/Jaya   VLprocessFieldCut replaces old mapping routine for 
 *			markings - neat plate surface is grabbed 
 * 11/30/01  Jayadev    Error Message for dummy mark point - CR#MP 5082 
 *************************************************************************/

class implementation VDSroot;

#include        <stdio.h>
#include        <string.h>
#include        "bserr.h"
#include 	"bsparameters.h"
#include        "EMSmsgdef.h"
#include        "ACrg_collect.h"
#include        "asmacros.h"
#include        "exdef.h"
#include        "exmacros.h"
#include        "nddef.h"
#include        "v_drwapi.h"
#include        "v_drw.h"
#include        "v_drwmacros.h"
#include        "v_miscmacros.h"
#include        "v_datamacros.h"
#include        "v_pplslc.h"
#include        "vddrwattr.h"
#include        "VDobj.h"
#include        "VDsa.h"
#include        "vsmiscmacros.h"
#include        "vsplatedef.h"
#include        "vsdata.h"
#include        "vlmsg.h"
#include        "vlgrdef.h"
#include        "vlgrmacros.h"
#include        "vlrolline.h"
#include        "vlmark.h"
#include        "vlunfold.h"
#include        "vlunwext.h"
#include        "vlcntrline.h"
#include        "vlstructure.h"
#include        "VLunwMisc.h"
#include        "vldbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

#define USE_NEW_MAPPING_ALGO 1

from   ACrg_collect	import  AClist_attribute;
from   ASindexcv	import	NDplace;
from   ASindexcv	import  ASget_uvwdef;
from   EMSsubbs		import  EMproject_curve_along_surface_normals;
from   VSfeature	import	VSforwardToOriginal, VSfindCollection;
from   VSsharedData	import	VSgetData;

extern GRclassid  OPP_ASindexcv_class_id, OPP_GR3dlinestr_class_id, 
		  OPP_GR3dtext_class_id, OPP_VSbeam_class_id,
                  OPP_GRpoint_class_id, OPP_VSsharedData_class_id;

static struct GRobj_env		loc_min_rect;

IGRlong  VLproject_curve( struct GRobj_env 	 *surf, 
			  struct GRobj_env 	 *curv,
			  struct GRvg_construct  *cst,
			  IGRint		 *nb_inters,
			  OM_S_OBJID		 **inters	)
{
 	long 		 sts, msg, nb_res;
 	struct GRlc_info curv_info,surf_info;

	sts = msg = OM_S_SUCCESS;
	*nb_inters = 0;
	*inters = NULL;

     	curv_info.located_obj = curv->obj_id;
     	curv_info.module_info = curv->mod_env;

     	surf_info.located_obj = surf->obj_id;
     	surf_info.module_info = surf->mod_env;

	__DBGpr_obj(" curv_info ", curv_info.located_obj );
	__DBGpr_mat( " crv mat ", curv_info.module_info.md_env.matrix );

	__DBGpr_obj(" surf_info ", surf_info.located_obj );
	__DBGpr_mat( " surf mat ", surf_info.module_info.md_env.matrix );

    	sts = om$send(msg=message
                                 EMSsubbs.EMproject_curve_along_surface_normals(
                                 &curv_info,
                                 &surf_info,
                                 cst,
                                 FALSE,
                                 TRUE,
                                 &nb_res,
                                 inters,
                                 &msg),
                    senderid = surf_info.located_obj.objid,
                    targetid = surf_info.located_obj.objid,
                    targetos = surf_info.located_obj.osnum);

	if( sts&msg&1 ) *nb_inters = (IGRint) nb_res; 
	return OM_S_SUCCESS;
}

/* ************************************************************************ *
 Given a list of lines (obj), this function  maps it on the surface
 (dev->surface). If the surface is a plane, it just copy the lines.
 Finally, it creates VLjunction object.
 * ************************************************************************ */
long VLprojectLine(dev,nb_obj,obj,ret_opt,cst,numCrvs,Crvs)
struct unw_obj_plat	*dev; /*I: unwrap structure */
int			nb_obj;/*I: number of lines */
int			ret_opt;
struct GRobj_env	*obj;  /*I: lines */
struct  GRvg_construct  *cst;  /*I: contruction list */
int			*numCrvs;/*O: number of output VLjunction objetc */
struct GRid             **Crvs;   /*O: VLjunction objetc */
{
int			ii,j,k,jj;
long			loc_msg,status,msg;
struct GRobj_env        cp_obj,tmp_obj,tmp;
struct  GRsymbology     symbology;
struct  GRas            asso_list;
double			dbl[3], ptDr[3], vecDr[6];
struct  IGRpolyline     str;
IGRint          	count   =       0;
IGRdouble      		*uvw    =       NULL;
IGRlong        		nptSize;
BSrc			rc;
struct GRid		res_id;

     SetProc( VLprojectLine ); Begin
     msg = MSFAIL;
     str.points = NULL;

     as$make_source(go_grid = dev->surf_id.obj_id,
                    mod_env = &dev->surf_id.mod_env,
                    as_os = cst->env_info->md_id.osnum,
                    as_grid = &res_id);

     for (ii=0;ii<nb_obj;ii++)
     {
   	__DBGpr_obj(" obj[] =  ",obj[ii].obj_id);
         /* to do a good NDplace later, we need copy */
       status = om$send(msg = message GRgraphics.GRcopy(
                                                &loc_msg,
                                                &obj[ii].mod_env,
                                                cst->env_info,
                                                &(cp_obj.obj_id.objid) ),
                                senderid = NULL_OBJID,
                                targetid = obj[ii].obj_id.objid,
                                targetos = obj[ii].obj_id.osnum );
        if (!(status&loc_msg&1)) {
          goto wrapup;
        }
	cp_obj.obj_id.osnum=cst->env_info->md_id.osnum;
        cp_obj.mod_env = *(cst->env_info);

//      if (!dev->developpable) {
           asso_list.num_parents = 1;
           asso_list.parents = &res_id;
           dbl[0] = 0.; dbl[1] = 0.; dbl[2] = 0.;
           asso_list.as_attr         = (char *) dbl;
           asso_list.context = NULL;
           asso_list.go_attr = NULL;
           asso_list.go_objid.objid = cp_obj.obj_id.objid;
           asso_list.go_objid.osnum = cst->env_info->md_id.osnum;
           tmp.obj_id.osnum = cst->env_info->md_id.osnum;

           status = om$construct( classid = OPP_ASindexcv_class_id,
                            p_objid = &tmp.obj_id.objid,
                            osnum = tmp.obj_id.osnum);
           if( !(status&1) ){
              goto wrapup;
           }
           cst->geometry = NULL;
           status = om$send(msg = message ASindexcv.NDplace(
                                &asso_list,
                                cst->env_info,
                                (char *) cst),
                        senderid = NULL_OBJID,
                        targetid = tmp.obj_id.objid,
                        targetos = tmp.obj_id.osnum );
    
	   if( *(cst->msg) == EMS_I_Exceeded )
	   {
		int 			ptp, r_cnt=0;
		long 			sts;
		struct GRobj_env 	*pp_obj=NULL;
		struct  proj_line_list  *p_list=NULL;

		/*********  Modification for TR179801541 *****************/

		if(!(p_list = _MALLOC( nb_obj, struct proj_line_list)) ) vd_$mem_fail(msg=&msg);
        	__DBGpr_int(" nb_obj  =  ",nb_obj);

		for(r_cnt=0,ptp=0;ptp<nb_obj;ptp++)
		{
          	   __DBGpr_obj(" obj[] =  ",obj[ptp].obj_id);

	  	   VLproject_curve( &dev->surf_id, &obj[ptp], cst,
			   &(p_list[ptp].cnt), &(p_list[ptp].list));
	  	   r_cnt += p_list[ptp].cnt ;
		}
	
        	__DBGpr_int(" r_cnt  1 =  ",r_cnt);

		if( !(pp_obj = _MALLOC( r_cnt, struct GRobj_env )) ) vd_$mem_fail(msg=&msg);

        	for(j=0,ptp=0;ptp<nb_obj;ptp++)
		{
         	   for(jj=0;jj<p_list[ptp].cnt;jj++)
	 	   {
	   		pp_obj[j].obj_id.objid = p_list[ptp].list[jj] ;
	   		pp_obj[j].obj_id.osnum = cst->env_info->md_id.osnum ;
	   		pp_obj[j].mod_env = *(cst->env_info);

           		__DBGpr_obj(" pp_obj[]=  ",pp_obj[j].obj_id);
	   		j++;
	 	   }
		}
	
        	*Crvs = (struct GRid *) om$realloc ( ptr  = (IGRchar *) *Crvs,
                                                    size = (r_cnt+(*numCrvs)) * sizeof( struct GRid) );

        	__DBGpr_int(" r_cnt 2 =  ",r_cnt);

        	sts = VLprojectLine( dev, r_cnt, pp_obj, 0, cst, 
				numCrvs, Crvs );

		for( j=0; j<r_cnt; ++j )
        	sts = om$send(msg  = message GRgraphics.GRdelete( &msg,
							  cst->env_info ),
			senderid = NULL_OBJID,
                        targetid = pp_obj[j].obj_id.objid,
                        targetos = pp_obj[j].obj_id.osnum );

		if(r_cnt)
		{
	  	   for(j=0;j<nb_obj;j++)
	    		_FREE( p_list[j].list );
		}
		_FREE( p_list );
		_FREE( pp_obj );
//		goto wrapup;
		continue;
	   }

           if( !( status & 1 ) ){
              if( ret_opt )  
	      {   
		  (*Crvs)[*numCrvs]  = cp_obj.obj_id;
		  goto get_copy;
	      }
	      else    continue;//       goto wrapup;
           }
           status = om$send ( msg =  message ASindexcv.ASget_uvwdef(
                                                   NULL,
                                                   0,
                                                   &count ),
                                   targetid       = tmp.obj_id.objid,
                                   targetos       = tmp.obj_id.osnum,
                                   senderid       = NULL_OBJID );
           if( !( status & 1 ) ){
	      continue;
              // goto wrapup;
           }
           str.num_points = count;
           count = 0;

           nptSize = 3 * str.num_points * sizeof(IGRdouble);

           uvw = (IGRdouble * ) om$malloc( size = nptSize );
           if( uvw == NULL ){
              __DBGpr_com("Error malloc uvw");
              goto wrapup;
           }
  
           status = om$send ( msg =  message ASindexcv.ASget_uvwdef(
                                    uvw, str.num_points, &count),
                            targetid        = tmp.obj_id.objid,
                            targetos        = tmp.obj_id.osnum,
                            senderid       = NULL_OBJID );
           __DBGpr_dbl( "uvW", uvw[0] );
 
	   if( (count<2) || !( status & 1 ) ){ 
              continue;
              // goto wrapup;
           }

           if( count == 2 )
           {
             if( fabs(uvw[0]-uvw[3]) < 1e-6 &&
                 fabs(uvw[1]-uvw[4]) < 1e-6 &&
                 fabs(uvw[2]-uvw[5]) < 1e-6 )   continue;
           }

           str.points = (IGRdouble * ) om$malloc( size = nptSize );
           if( str.points == NULL ){
              __DBGpr_com("Error malloc str.points");
              goto wrapup;
           }
           j = 3 * str.num_points;

           for(k=0;k<j;k+=3){
                 if( dev->tesselation_option == PARAMETRIC  ) 
                 {
                     BSsfeval( dev->devsrf, uvw[k], uvw[k+1], 0,
                          &(str.points[k]), &rc );
                     if (rc != BSSUCC) goto wrapup;
                 }
                 else
                 {
                    BSsfevaln( dev->surface,uvw[k],uvw[k+1],1,
                               &jj,ptDr,vecDr,&rc);
                    FAevPtSfFaDr((IGRshort) 3,dev->P,dev->devsrf,dev->def,
                        ptDr, vecDr, uvw[k],uvw[k+1], &(str.points[k]),&rc);
                 }
           }

           status = om$send( msg   = message GRvg.GRgetsymb( 
							&loc_msg,&symbology),
                         senderid = NULL_OBJID,
                         targetid = obj[ii].obj_id.objid,
                         targetos = obj[ii].obj_id.osnum);

 
           tmp_obj.obj_id.objid = NULL_OBJID;
           tmp_obj.obj_id.osnum = cst->env_info->md_id.osnum;

           cst->geometry = (IGRchar *) &str;
           status = om$construct( classid = OPP_GR3dlinestr_class_id,
                             p_objid = &tmp_obj.obj_id.objid,
                             osnum   = tmp_obj.obj_id.osnum,
                             msg     = message GRgraphics.GRaltconstruct(cst));

           if (!(status&(*(cst->msg))&1)) {
              goto wrapup;
           }

	   (*Crvs)[*numCrvs]  = tmp_obj.obj_id;

           if( uvw ){ om$dealloc( ptr = uvw ); uvw = NULL;}
           if( str.points ){ om$dealloc( ptr = str.points );
                                    str.points = NULL;}
           om$send(msg = message GRgraphics.GRdelete
                                                (&loc_msg,cst->env_info),
                             targetid = tmp.obj_id.objid,
                             targetos = tmp.obj_id.osnum,
		             senderid = NULL_OBJID );
/*
        }
        else{
get_copy:
	  Crvs[*numCrvs]  = cp_obj.obj_id;
        }
*/

get_copy:

      symbology.display_attr = *(cst->display) ;
      symbology.level = cst->level;
      status = om$send( msg   = message GRvg.GRputsymb( &loc_msg,&symbology ),
                         senderid = NULL_OBJID,
                         targetid = (*Crvs)[*numCrvs].objid,
                         targetos = (*Crvs)[*numCrvs].osnum );

      *numCrvs += 1;

    }

    msg = MSSUCC;
wrapup :
    if( !(msg&1) )
    {
      if( cp_obj.obj_id.objid != NULL_OBJID )
      {
	status = om$send(msg = message GRgraphics.GRdelete( 
						&loc_msg, cst->env_info ),
                              senderid = NULL_OBJID,
			      targetid = cp_obj.obj_id.objid,
                              targetos = cp_obj.obj_id.osnum  );
      }
    }

    if( uvw ){ om$dealloc( ptr = uvw ); uvw = NULL;}
    if( str.points ){ om$dealloc( ptr = str.points ); str.points = NULL;}

    End ;
    return msg;
}


IGRlong  VLprocessFieldCut(  IGRlong			*msg,
			     struct unw_obj_plat        *dev,
			     VD_drwInputData		*inp,
			     VD_drwExecData             *xData ,
			     IGRchar			*foot_name,
			     struct GRvg_construct	*cst,
			     VD_drwGraphicGroup		*outp    ) 	
{
BSrc			rc;
IGRlong			sts=OM_S_SUCCESS;
IGRint			i, j, k, nb_inters=0, MaxPts, cnt;
IGRshort		trfMatType, world=TRUE;
IGRchar			side[50];
IGRboolean		useCurrent=FALSE;
IGRdouble		fromMat[16], toMat[16], trfMat[16], savedActiveCht,
			*pars=NULL, *uvs=NULL, base[3], mdist, ptDr[3],
			plateOffset, vecDr[6] ;
IGRpoint                *pts=NULL;
GRrange                 minrecRng, crvRng;
VDpartAttr              attr;
VSdataDesc      	list[VS_K_plMAXDATA];
OM_S_OBJID              *inters=NULL;
struct GRobj_env	surface_id, foot_id, temp_obj, par_plate, unwrapOE,
			minrecOE, compOEs[10]; 
struct GRid		inter_crv, myColl;
struct IGRbsp_curve     *cv=NULL;
struct IGRpolyline      lst;

  SetProc( VLprocessFieldCut ); Begin

  lst.points = NULL;

  __DBGpr_obj( "Input Field Cut macro ", *(inp->elmId) );
  __DBGpr_str( "Feet Name", foot_name ); 

  // Get the unwrap object and Non-hole plate parent
  sts = VLgetUnwIdFromSurf(&dev->surf_id, inp, &unwrapOE.obj_id, &par_plate );
  __CheckRC( sts, 1, "VLunwGetUnwrapFromSrf", wrapup );
  __DBGpr_obj( "Parent(Non-Hole) plate ", par_plate.obj_id );
  __DBGpr_obj( "Unwrap Object ", unwrapOE.obj_id );

  unwrapOE.mod_env = *(cst->env_info) ;

  // Get the correct surface from the Non-hole plate parent
  if (	dev->side_of_plate == OFFSET_SIDE ||
        dev->side_of_plate == OFFSET_FLIP    ) 	strcpy(side, VS_K_plTopSfPath);
  else						strcpy(side, VS_K_plBotSfPath);	
  __DBGpr_str("Side to Unwrap ", side );	

  /*
   * Make sure that there is no offset for this plate.
   */

  myColl.objid = NULL_OBJID;
  sts = om$send( msg = message VSfeature.VSfindCollection(
                                msg, VS_K_prPrvAttr, &myColl ),
		 senderid = par_plate._objid,
                 targetid = par_plate._objid,
		 targetos = par_plate._osnum ) ;
  /*
   * Actually a possibility that the wrong object get's returned
   * Happens when a plate loses parents completely
   */
  sts = vdobj$IsAncestryValid( objID = &myColl,
                               superClassID = OPP_VSsharedData_class_id );
  if( sts & 1 ) 
  {
      for( i = 0 ; i < VS_K_plMAXDATA ; i++ ) list[i].index = i ;

      sts = om$send(  msg     = message VSsharedData.VSgetData(
                                             msg, VS_K_plMAXDATA, list ),
		       senderid = myColl.objid,
                       targetid = myColl.objid,
                       targetos = myColl.osnum ) ;
      __CheckRC( sts, *msg, "VSsharedData.VSgetData", wrapup ) ;

      plateOffset = list[VS_K_plOffset].value.d ;

      if( fabs( plateOffset ) > 0.001 )  useCurrent = TRUE;
  }

  if( useCurrent )
  {
     sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                msg, side, &surface_id.obj_id,
                                &surface_id._matrix_type, surface_id._matrix ),
                       senderid = par_plate._objid,
                       targetid = par_plate._objid,
                       targetos = par_plate._osnum ) ;
     __CheckRC( sts, *msg, "NDmacro.ACreturn_foot:Base/Offset", wrapup );
     __DBGpr_obj( "Parent Surface ", surface_id.obj_id );
  }
  else
  {
     /* Get the Surface Of the Original Source Plate */
     sts = om$send( msg      = message VSfeature.VSforwardToOriginal(
                             msg,
                             OM_e_wrt_object,
                             message NDmacro.ACreturn_foot(
                                msg, side, &surface_id.obj_id,
                                &surface_id._matrix_type, surface_id._matrix )),
                       senderid = par_plate._objid,
                       targetid = par_plate._objid,
                       targetos = par_plate._osnum ) ;
     __CheckRC( sts, *msg, "NDmacro.ACreturn_foot:Base/Offset", wrapup );
     __DBGpr_obj( "Parent Surface ", surface_id.obj_id );
  }

  surface_id._md_os = surface_id._osnum;
  ex$get_modid(   mod_osnum = surface_id._md_os,
		  mod_id    = &surface_id._md_id ) ;
  __DBGpr_obj( "Surface Module ID ", surface_id.mod_env.md_id );

  // Get the Field Cut graphics
  sts = _VD_SEND_OBJN( *(inp->elmId), NDmacro.ACreturn_foot( msg, foot_name,
		&foot_id.obj_id, &foot_id._matrix_type, foot_id._matrix ) );
  __CheckRC( sts, *msg, "NDmacro.ACreturn_foot:FieldCut Graphics", wrapup );
  __DBGpr_obj( "Field Cut Graphic ", foot_id.obj_id );

  foot_id._md_os = foot_id._osnum;
  ex$get_modid(   mod_osnum = foot_id._md_os,
                  mod_id    = &foot_id._md_id ) ;
  __DBGpr_obj( "FieldCut Foot Module ID ", foot_id.mod_env.md_id );

  // Project field cut graphics onto the surface
  sts = VLproject_curve( &surface_id, &foot_id, cst, &nb_inters, &inters );
  __CheckRC( sts, 1, "VLproject_curve", wrapup );
  __DBGpr_int( "Number of intersections ", nb_inters );
  if( !nb_inters || !inters ) goto wrapup;

  inter_crv.objid = inters[0];
  inter_crv.osnum = cst->env_info->md_id.osnum;
  __DBGpr_obj( "Intersection Curve ", inter_crv );

  // Copy the intersection graphics, because they will be delted in wrapup
  sts = _VD_SEND_OBJN( inter_crv, GRgraphics.GRcopy( msg, inp->drwInfo.drwEnv,
			             inp->drwInfo.drwEnv, &temp_obj._objid ));
  __CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup );
  temp_obj._osnum  = inter_crv.osnum;
  temp_obj.mod_env = *(inp->drwInfo.drwEnv);
  __DBGpr_obj( "Copied New Curve ", temp_obj.obj_id );

  // Allocate memory for the output graphics and store the curve
  outp->count = 1;
  if( !(outp->list = _MALLOC( 1, struct GRid )) ) vd_$mem_fail();

  // Apply the transformation matrix to the intersection curve
  attr.Iwant = VL_I_fromMat ;
  attr.specific = (void *) fromMat ;
  sts = _VD_SEND_OBJN( unwrapOE.obj_id, GRvg.GRgetattr( msg, (char *)&attr ));
  __CheckRC( sts, *msg, "GRvg.GRgettattr", wrapup );

  attr.Iwant = VL_I_toMat ;
  attr.specific = (void *) toMat ;
  sts = _VD_SEND_OBJN( unwrapOE.obj_id, GRvg.GRgetattr( msg, (char *)&attr ));
  __CheckRC( sts, *msg, "GRvg.GRgettattr", wrapup );

  if( dev->developpable > 0 )
  {
     sts = VLapplyTransf( &temp_obj.obj_id, 1, inp->drwInfo.drwEnv, fromMat, 
			  toMat, trfMat, &trfMatType, msg );
     __CheckRC( sts, *msg, "VLapplyTransf", wrapup );
  }
  else
  {
      sts = VLgetGeometry( &temp_obj, (IGRboolean) FALSE, NULL_OBJID,
                           (IGRchar **)&cv, msg );
      __CheckRC( sts, *msg, "VLgetGeometry", wrapup );

      sts = om$send(msg  = message GRgraphics.GRdelete( msg,
						inp->drwInfo.drwEnv ),
             senderid = NULL_OBJID,
             targetid = temp_obj._objid,
             targetos = temp_obj._osnum );

      BSxtractpar ( &rc, BSTOLCHRDHT, &savedActiveCht );
      BSchangepar ( &rc, BSTOLCHRDHT, 0.01 );

      /* Evaluate the points at the cht value */
      BSchtptstcv( cv, &lst.num_points, &pts, &pars, &rc);
      if( rc != BSSUCC )
      {
          BSchangepar ( &rc, BSTOLCHRDHT, savedActiveCht );
          *msg = MSFAIL;
          goto wrapup;
      }
      __DBGpr_int("BSchtptstcv(Stroking) returns ", lst.num_points );
      /* Set back the cht as it used be */
      BSchangepar ( &rc, BSTOLCHRDHT, savedActiveCht );

      MaxPts = 3 * lst.num_points;
      if( !(lst.points = _MALLOC( MaxPts, IGRdouble ) ) ) vd_$mem_fail();

      __DBGpr_int("Allocating memory[uv] for ", lst.num_points );
      #if vdsDEBUG
           for( j=0; j<lst.num_points; ++j )   __DBGpr_vec("Point ", pts[j] );
      #endif
      if( !( uvs = _MALLOC( 2*lst.num_points, IGRdouble ) ) ) vd_$mem_fail();
      for( j=0; j<lst.num_points; ++j )
      {
          BSmdistptsf( &rc, dev->surface, pts[j], &uvs[2*j],
                       &uvs[2*j+1], base, &mdist );
          if( rc != BSSUCC )
          {
              uvs[2*j]   = uvs[2*(j-1)];
              uvs[2*j+1] = uvs[2*(j-1)+1];
          }
      }
      if (dev->tesselation_option == PARAMETRIC)
      {
         __DBGpr_com("Processing for Natural Mesh");
         for(k=0;k<lst.num_points;k++)
         {
             __DBGpr_dbl("U-parameter ", uvs[2*k]);
             __DBGpr_dbl("V-parameter ", uvs[2*k+1]);
             BSsfeval( dev->devsrf, uvs[2*k], uvs[2*k+1],
                       0, &(lst.points[3*k]), &rc );
             __DBGpr_vec("Point on Unwrap Surface",&(lst.points[3*k]));
         }
      }
      else
      {
          __DBGpr_com("Processing for Boundaries Mesh");
          for(k=0;k<lst.num_points;k++)
          {
              __DBGpr_dbl("U-parameter ", uvs[2*k]);
              __DBGpr_dbl("V-parameter ", uvs[2*k+1]);
              BSsfevaln( dev->surface,uvs[2*k],uvs[2*k+1],1,
                         &j,ptDr,vecDr,&rc);
              FAevPtSfFaDr( (IGRshort) 3,dev->P,dev->devsrf,dev->def,
                            ptDr, vecDr, uvs[2*k],uvs[2*k+1],
                            &(lst.points[3*k]),&rc);
              __DBGpr_vec("Point on Unwrap Surface",&(lst.points[3*k]));
          }
      }

      sts = VLunwRemoveDuplicatePoints( cv->phy_closed,
                            &lst.num_points, &lst.points );

      /* Construct the linestring */

      temp_obj._objid = NULL_OBJID;
      temp_obj._osnum = cst->env_info->md_id.osnum;

      cst->geometry     = (IGRchar *) &lst;

      sts = om$construct( classid = OPP_GR3dlinestr_class_id,
                          p_objid = &temp_obj._objid,
                          osnum   = temp_obj._osnum,
                          msg     = message GRgraphics.GRaltconstruct( cst ) );
      __CheckRC( sts, 1, "GRaltconstruct:GR3dlinestr", wrapup ) ;
      __DBGpr_obj("Create Field Cut Object ", temp_obj.obj_id );
      cst->geometry = NULL ;
  }

  cnt = 0 ;
  VLunwGetComponents( &unwrapOE, VLEXT_TYPE_MIN_REC, 10, &cnt, compOEs ); 
  if( cnt == 0 )	minrecOE = loc_min_rect ;
  else			minrecOE = compOEs[0] ;

  unwrapOE.mod_env = *(cst->env_info) ;

  sts = om$send( msg    = message GRgraphics.GRgetrang(
                                    msg,
                                    &minrecOE._matrix_type,
                                    minrecOE._matrix,
                                    &world,
                                    minrecRng ),
                  senderid = minrecOE._objid,
                  targetid = minrecOE._objid,
                  targetos = minrecOE._osnum ) ;
  __CheckRC( sts, *msg, "GRgraphics.GRgetrang: Minimum Rectangle", wrapup ) ;

  sts = om$send( msg    = message GRgraphics.GRgetrang(
                                    msg,
                                    &temp_obj._matrix_type,
                                    temp_obj._matrix,
                                    &world,
                                    crvRng ),
                  senderid = temp_obj._objid,
                  targetid = temp_obj._objid,
                  targetos = temp_obj._osnum ) ;
  __CheckRC( sts, *msg, "GRgraphics.GRgetrang: Curve", wrapup );

  if( !BSbxint( &rc, &minrecRng[0], &minrecRng[3], &crvRng[0], &crvRng[3] ) )
  {
     sts = om$send( msg = message GRgraphics.GRdelete(
                                    msg, cst->env_info ),
                       senderid = NULL_OBJID,
                       targetid = temp_obj._objid,
                       targetos = temp_obj._osnum  );

     outp->count = 0;
     goto wrapup;
  }

  outp->list[0] = temp_obj.obj_id;

  // Set the curve as anchor curve
  xData->txPosHelper = VD_useAnchorCurve ;
  xData->anchorCurve = temp_obj;

  sts = *msg = MSSUCC;

wrapup:
  for( i=0; i<nb_inters; ++i )
         om$send(msg  = message GRgraphics.GRdelete( msg,inp->drwInfo.drwEnv ),
	     senderid = NULL_OBJID,
	     targetid = inters[i],
	     targetos = inp->drwInfo.drwEnv->md_id.osnum );

  _FREE( inters );
  _FREE( pars );
  _FREE( uvs );
  _FREE( pts );
  _FREE( lst.points );
  _FREE( cv );
  End
  return sts;
}

static IGRlong	VLunwReportMrkError( struct GRid  	*mrkID )
{
IGRchar			platePcmk[100], beamPcmk[100];
struct GRid		parentID;
struct GRobj_env	objOE;

   gr$get_module_env( buffer = &objOE.mod_env );

   vdobj$GetParent( objID    = mrkID, 
		    idx      = 1, 
		    parentID = &parentID );
   objOE.obj_id = parentID;

   vdsa$GetStruct( objOE   = &objOE,
                   name    = "SA_AST:StagingTree:0:pcmk",
                   txt     = platePcmk );
   if( !strlen( platePcmk ) )
        VLGetShortName( &objOE, &objOE.mod_env, platePcmk );

   vdobj$GetParent( objID    = mrkID, 
                    idx      = 2, 
                    parentID = &parentID );
   objOE.obj_id = parentID;

   vdsa$GetStruct( objOE   = &objOE,
                   name    = "SA_AST:StagingTree:0:pcmk",
                   txt     = beamPcmk );
   if( !strlen( beamPcmk ) )
         VLGetShortName( &objOE, &objOE.mod_env, beamPcmk );

   printf("Failed to map the marking line between <%s> and <%s>\n",
                        platePcmk, beamPcmk );

   return 1;
}

IGRlong  VLunwMarkProj( long                     *msg ,
			struct unw_obj_plat      *dev ,
			VD_drwInputData          *inp ,
			VD_drwExecData           *xData ,
			VD_drwGraphicGroup       *outp    ) 
{
        long            	sts;
	IGRint			nb_obj;
	IGRboolean		pr_error=FALSE;
	char                    *names[12];
        IGRdouble               fromMat[16], toMat[16], point[3];
        VDpartAttr              attr;
        struct GRid             unwrap_id;
	struct GRobj_env        obj[VLRolNumFeet];
	struct GRvg_construct   cst;	
	VD_drwGraphicGroup  	loc_outp;
        /*
         * This function extracts the projection of a part.
         */
	SetProc( VLunwMarkProj ); Begin

        /*
         * Initialize data.
         */
        outp->list  = NULL ;
        outp->count = 0 ;

	point[0] = point[1] = point[2] = 0.0 ;

        __DBGpr_obj( "Part to draw", *(inp->elmId) ) ;

        /*
         * Construct construction list
         */
        vs$fill_cnst_list( Msg          = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &xData->overrides.elmDisplay,
                           Cnst_list    = cst ) ;

         sts = VLgetUnwIdFromSurf(&dev->surf_id, inp, &unwrap_id, NULL );
         __CheckRC( sts, 1, "VLunwGetUnwrapFromSrf", wrapup );

         attr.Iwant = VL_I_fromMat ;
         attr.specific = (void *) fromMat ;
         sts = _VD_SEND_OBJN( unwrap_id, GRvg.GRgetattr( msg, (char *)&attr ));
         __CheckRC( sts, *msg, "GRvg.GRgettattr", wrapup );

         attr.Iwant = VL_I_toMat ;
         attr.specific = (void *) toMat ;
         sts = _VD_SEND_OBJN( unwrap_id, GRvg.GRgetattr( msg, (char *)&attr ));
         __CheckRC( sts, *msg, "GRvg.GRgettattr", wrapup );

         names[0] =  VLFirstMrkName; names[1] =  VLSecondMrkName;
         names[2] =  VLThirdMrkName; names[3] =  VLFourthMrkName;
         names[4] =  VLFifthMrkName; names[5] =  VLSixthMrkName;
         names[6] =  VLSeventhMrkName; names[7] =  VLEighthMrkName;
         names[8] =  VLNinethMrkName; names[9] =  VLTenthMrkName;

         if( !(outp->list = _MALLOC( 10, struct GRid )) )
                        vd_$mem_fail();
	 outp->count = 0;
         nb_obj = 0;
         do {
           sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                       msg,
                                       names[nb_obj],
                                       &obj[nb_obj].obj_id,
                                       &obj[nb_obj].mod_env.md_env.matrix_type,
                                       obj[nb_obj].mod_env.md_env.matrix),
                              targetid = inp->elmId->objid,
                              targetos = inp->elmId->osnum,
                              senderid = inp->elmId->objid  ) ;
            obj[nb_obj].mod_env.md_id.osnum = obj[nb_obj].obj_id.osnum;
            if ((sts&(*msg)&1)) 
	    {
		loc_outp.count = 0;
		loc_outp.list = NULL;
		sts = VLprocessFieldCut( msg, dev, inp, xData, names[nb_obj],
                                    &cst, &loc_outp ) ;
		if( (sts&(*msg)&1) && loc_outp.count )
		{
                  if(( vd_$is_ancestry_valid (object  = &loc_outp.list[0],
                                              classid = OPP_GRpoint_class_id)))
                  {
		     VLunwReportMrkError( inp->elmId );
                     printf("\n MAPPED point on unwrap for ");
                     printf("[%s] feet of marking line \n", names[nb_obj]);
                  }
		  outp->list[outp->count] = loc_outp.list[0];
		  (outp->count)++;
		}
		else 
		{
		  if( pr_error == FALSE ) 
		  {
		     VLunwReportMrkError( inp->elmId );
		     pr_error = TRUE;
		  }
		  VLplPt( msg, point, &outp->list[outp->count],
			  inp->drwInfo.drwEnv );
		  (outp->count)++;
		}
		_FREE( loc_outp.list );
		nb_obj++;
		sts = *msg = MSSUCC;
	    }
          } while ((sts&(*msg)&1));
/*
	  #if USE_NEW_MAPPING_ALGO
              sts = VLprojAndMapCrvOntoSrf(  dev, nb_obj, obj, TRUE, &cst,
                             fromMat, toMat, &outp->count, &outp->list );
	  #else
	      if( !(outp->list = _MALLOC( nb_obj, struct GRid )) ) 
			vd_$mem_fail();
	      sts = VLprojectLine( dev, nb_obj, obj, 0, &cst,
			&outp->count, &outp->list );
	  #endif
*/		
wrapup:

	End ;
        return sts;
}

IGRlong  VLunwRollProj(	long                     *msg ,
			struct unw_obj_plat      *dev ,
			VD_drwInputData          *inp ,
			VD_drwExecData           *xData ,
			VD_drwGraphicGroup       *outp    ) 
{
        long            	sts;
	IGRint			cur_line, nb_obj;
	char                    *names[12], *name_line, word[20];
	struct GRobj_env        obj[VLRolNumFeet];
        IGRdouble               fromMat[16], toMat[16];
        VDpartAttr              attr;
        struct GRid             unwrap_id;
	struct GRvg_construct   cst;
	struct IGRdisplay       dspVis;

        /*
         * This function extracts the projection of a part.
         */
	SetProc( VLunwRollProj ); Begin

        /*
         * Initialize data.
         */
        outp->list  = NULL ;
        outp->count = 0 ;

        __DBGpr_obj( "Part to draw", *(inp->elmId) ) ;

        dspVis = xData->overrides.elmDisplay ;

        /*
         * Construct construction list
         */
        vs$fill_cnst_list( Msg          = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &dspVis,
                           Cnst_list    = cst ) ;

         sts = VLgetUnwIdFromSurf(&dev->surf_id, inp, &unwrap_id, NULL );
         __CheckRC( sts, 1, "VLunwGetUnwrapFromSrf", wrapup );

         attr.Iwant = VL_I_fromMat ;
         attr.specific = (void *) fromMat ;
         sts = _VD_SEND_OBJN( unwrap_id, GRvg.GRgetattr( msg, (char *)&attr ));
         __CheckRC( sts, *msg, "GRvg.GRgettattr", wrapup );

         attr.Iwant = VL_I_toMat ;
         attr.specific = (void *) toMat ;
         sts = _VD_SEND_OBJN( unwrap_id, GRvg.GRgetattr( msg, (char *)&attr ));
         __CheckRC( sts, *msg, "GRvg.GRgettattr", wrapup );

         names[0] =   VLFirstRolName; names[1] =   VLSecondRolName;
         names[2] =   VLThirdRolName; names[3] =   VLFourthRolName;
         names[4] =   VLFifthRolName;
         nb_obj = 0; cur_line = 6;
         do {
           if (nb_obj <= 4) name_line = names[nb_obj];
           else {
             sprintf(word, "%.2dth line", cur_line ) ;
             cur_line++;
             name_line = word;
           }
           sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                        msg,
                                        name_line,
                                        &obj[nb_obj].obj_id,
                                        &obj[nb_obj].mod_env.md_env.matrix_type,
                                        obj[nb_obj].mod_env.md_env.matrix),
                            targetid = inp->elmId->objid,
                            targetos = inp->elmId->osnum,
                            senderid = inp->elmId->objid  );

	    obj[nb_obj].mod_env = *inp->drwInfo.drwEnv;
            obj[nb_obj].mod_env.md_id.osnum = obj[nb_obj].obj_id.osnum;
            if ((sts&(*msg)&1)) nb_obj++;
          } while ((sts&(*msg)&1));

#if USE_NEW_MAPPING_ALGO
		sts = VLprojAndMapCrvOntoSrf(  dev, nb_obj, obj, TRUE, &cst,
			fromMat, toMat, &outp->count, &outp->list );
#else
		if( !(outp->list = _MALLOC( nb_obj, struct GRid )) )
			vd_$mem_fail();
		sts = VLprojectLine(dev, nb_obj, obj, 0,
				&cst, &outp->count, &outp->list );
#endif
wrapup:
	End ;
        return sts;
}

IGRlong  VLunwProcessStock(	long                     *msg ,
				struct unw_obj_plat      *dev ,
				VD_drwInputData          *inp ,
				VD_drwExecData           *xData ,
				VD_drwGraphicGroup       *outp    ) 
{
        long            	sts;
	struct GRobj_env        obj;
	struct GRvg_construct   cst;
	struct IGRdisplay       dspVis;

        /*
         * This function extracts the projection of a part.
         */
	SetProc( VLunwProcessStock ); Begin

        /*
         * Initialize data.
         */
        outp->list  = NULL ;
        outp->count = 0 ;

        dspVis = xData->overrides.elmDisplay ;

        /*
         * Construct construction list
         */
        vs$fill_cnst_list( Msg          = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &dspVis,
                           Cnst_list    = cst ) ;

	if( !(outp->list = _MALLOC( 1, struct GRid )) ) vd_$mem_fail();

	obj.obj_id  = *(inp->elmId);
	obj.mod_env = *(inp->drwInfo.drwEnv);

        sts = VLprojectLine(dev, 1, &obj, 1, &cst, &outp->count, &outp->list);

wrapup:
	End ;
        return sts;
}

IGRlong  VLunwProcessUnwrap( long                     *msg ,
			     struct GRid	      *UnwObj,
			     struct unw_obj_plat      *dev ,
			     VD_drwInputData          *inp ,
			     VD_drwExecData           *xData ,
			     VD_drwGraphicGroup       *outp    ) 
{
	IGRlong			sts ;
	IGRint            	i, j, k, locNumEdges, surf_type,
				NumBound,*LoopIndex=NULL,NumOldCrvs=0;
	IGRdouble		Length, Width, fromMat[16];
	struct EdgeMatch  	*locEdgeList=NULL;
	struct GRid             min_rec, line[3], att_box;
	struct GRmd_env         mdEnv;
	struct IGRdisplay       dis_att;
	struct GRvg_construct   cst;
	struct GRsymbology      symbology;
	VDpartAttr              attr;
	GRname			fl_name;
	struct GRobj_env        *Bound=NULL;
	struct GRid             *OldCrvs=NULL, *OutPutLst=NULL;
	struct GRobj_env        OldCrvObjEnv;
	struct  ACrg_coll       list_att[UNFOLD_NB_OPT];
	IGRint			code = 0, optlines[UNWEXT_NB_OPT];
	struct edge_match_list  match_lst;

	SetProc( VLunwProcessUnwrap ); Begin

       	/*
       	 * Initialize data.
       	 */
       	outp->list  = NULL ;
       	outp->count = 0 ;

        sts = _VD_SEND_OBJN( *UnwObj, NDnode.NDget_objects( ND_ROOT,
                                &att_box, 1, NULL, 0, 0, &i ));
        __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );

	/* Find attributes */
	sts = _VD_SEND_OBJN( att_box, ACrg_collect.AClist_attribute(
				msg, UNFOLD_NB_OPT, list_att, &k) );
        __CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );

  	if ((j=VLseekFields(list_att,k,UNFOLD_ATT_LINES)) != -1) {
    	    code = list_att[j].desc.value.att_exp;
  	}

	mdEnv   = *(inp->drwInfo.drwEnv);
	dis_att = xData->overrides.elmDisplay;

       	vs$fill_cnst_list( Msg          = msg,
                       	   Env_info     = &mdEnv,
                       	   Level        = xData->overrides.elmLevel,
                       	   Display      = &dis_att,
                       	   Cnst_list    = cst ) ;

	VLdecode( code, UNWEXT_NB_OPT, optlines );

        /* Get the visualization support file */
        attr.Iwant = VD_I_drwVisual ;
        sts = _VD_SEND_OBJN( *UnwObj, GRvg.GRgetattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );
        strcpy( fl_name, attr.aString );

	sts  = VLunwCreateProdBoundWithOff( msg, dev, &cst, fl_name,
			optlines[UNWEXT_ATT_IDX_ADDSTOK], &NumBound, &Bound,
			&locNumEdges, &locEdgeList, &NumOldCrvs, &OldCrvs );
	if( !(sts&1&(*msg) ) )
	{
	   _FREE( Bound ); _FREE( locEdgeList ); _FREE( OldCrvs );
	   sts  = VL_unw_creBoundWithOff( dev, &cst, (IGRboolean)FALSE,
			  optlines[UNWEXT_ATT_IDX_ADDSTOK], &NumBound,
			  &Bound, &LoopIndex, &locNumEdges, &locEdgeList,
			  &surf_type, line, &NumOldCrvs, &OldCrvs, msg );
	}
  	__CheckRC( sts, *msg, "VLunwCreateBoundaryWithOff", wrapup );

	match_lst.Count    = locNumEdges;
	match_lst.EdgeList = locEdgeList;

        attr.Iwant = VL_I_edgeMatch ;
        attr.specific = (void *) &match_lst;
        sts = _VD_SEND_OBJN(  *UnwObj, GRvg.GRputattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	/* ================================================
	 * Add check
	 */
	if (NumBound < 1) {
	  printf(">>> In VLunwProcessUnwrap, NumBound < 1\n");
	  vdobj$Print(objID = UnwObj);
	  goto wrapup;
	}
	
	if( !( outp->list = _MALLOC( NumBound, struct GRid )) ) vd_$mem_fail();

	outp->count = NumBound ;
	for( i=0; i<NumBound; ++i ) 
	{
	    outp->list[i] = Bound[i].obj_id ;
            symbology.display_attr = dis_att ;
      	    symbology.level        = cst.level ;
      	    sts = _VD_SEND_OBJN( outp->list[i], GRvg.GRputsymb( 
						msg, &symbology ) );
	    __CheckRC( sts, *msg, "GRvg.GRputsymb", wrapup );
	}

	vd$ppl_set_size( which_info = GLOBAL_INFO,
			 size       = 5 + NumOldCrvs   );


	vd$ppl_setarg_at_index( which_info = GLOBAL_INFO,
       	                        index      = 4,
               	                type       = VD_int,
                       	        value      = &NumOldCrvs    );

	if( NumOldCrvs )
	{
	   for( i=0; i<NumOldCrvs; ++i )
	   {
		OldCrvObjEnv.obj_id  = OldCrvs[i];
		OldCrvObjEnv.mod_env = *cst.env_info ;

		vd$ppl_setarg_at_index( which_info = GLOBAL_INFO,
        	                        index      = 5+i,
                	                type       = VD_object,
                        	        value      = &OldCrvObjEnv     );
	   }
	}

  	/*  Evaluate the minimal rectangle */

        cst.geometry = NULL;
        sts  = vl$minrect ( curve   = &(Bound[0].obj_id),
                            environ = cst.env_info,
                            cst     = &cst,
                            length  = &Length,
                            width   = &Width,
                            frame   = &min_rec,
                            msg     = msg );
        __CheckRC( sts, *msg, "vl$minrect", wrapup );

	OldCrvObjEnv.obj_id  = min_rec;
	OldCrvObjEnv.mod_env = *cst.env_info ;

	loc_min_rect = OldCrvObjEnv;

	vd$ppl_setarg_at_index( which_info = GLOBAL_INFO,
       	                        index      = 3,
               	                type       = VD_object,
                       	        value      = &OldCrvObjEnv     );

	sts  = VL_unw_newCreFromMat( min_rec, cst.env_info, dev, fromMat, msg );
        __CheckRC( sts, *msg, "VL_unw_newCreFromMat", wrapup );

        attr.Iwant = VL_I_fromMat ;
        attr.specific = (void *) fromMat ;
        sts = _VD_SEND_OBJN(  *UnwObj, GRvg.GRputattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRputattr", wrapup );

	vd$ppl_setarg_at_index( which_info = GLOBAL_INFO,
                                index      = 0,
                                type       = VD_double,
                                value      = &Length     );

	vd$ppl_setarg_at_index( which_info = GLOBAL_INFO,
                                index      = 1,
                                type       = VD_double,
                                value      = &Width     );

wrapup:
	if( sts & *msg & 1 ){
		/* Add Keywork for remainder process */
//		VD_drwExecConfigAddFunctions();
	}
	_FREE( LoopIndex );
	_FREE( locEdgeList );
	_FREE( Bound );
	_FREE( OldCrvs );
	_FREE( OutPutLst );
	End ;
	return sts ;
}


IGRlong  VLunwLineProj(	long                     *msg ,
			struct unw_obj_plat      *dev ,
			VD_drwInputData          *inp ,
			VD_drwExecData           *xData ,
                        const VD_drwArgLst       *argl,
                        int                      argc,
			VD_drwGraphicGroup       *outp    ) 
{
        IGRlong            	sts=OM_S_SUCCESS;
	IGRint			i, j, nb_obj=0, nb_inters=0, txtFlag=0;
	IGRboolean		test_flag=FALSE;
	struct GRobj_env        obj[20];
	struct GRvg_construct   cst;
	struct IGRdisplay       dspVis;
	struct GRobj_env        graphic_group;
  	OM_S_OBJID		*inters = NULL;
        IGRdouble               fromMat[16], toMat[16];
        VDpartAttr              attr;
        struct GRid             unwrap_id;
	char			attr_name[30], feet_name[30];
        const char      	*type = xData->parsedElmDesc ;

	/*
         * This function extracts the projection of a part.
         */
	SetProc( VLunwLineProj ); Begin

        /*
         * Initialize data.
         */
        outp->list  = NULL ;
        outp->count = 0 ;

        __DBGpr_obj( "Part to draw", *(inp->elmId) ) ;

        dspVis = xData->overrides.elmDisplay ;

        /*
         * Construct construction list
         */
        vs$fill_cnst_list( Msg          = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &dspVis,
                           Cnst_list    = cst ) ;

        sts = VLgetUnwIdFromSurf(&dev->surf_id, inp, &unwrap_id, NULL );
        __CheckRC( sts, 1, "VLunwGetUnwrapFromSrf", wrapup );

        attr.Iwant = VL_I_fromMat ;
        attr.specific = (void *) fromMat ;
        sts = _VD_SEND_OBJN( unwrap_id, GRvg.GRgetattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRgettattr", wrapup );

        attr.Iwant = VL_I_toMat ;
        attr.specific = (void *) toMat ;
        sts = _VD_SEND_OBJN( unwrap_id, GRvg.GRgetattr( msg, (char *)&attr ));
        __CheckRC( sts, *msg, "GRvg.GRgettattr", wrapup );

	if( !strcmp( type, "macro" ) )
	{
	  if( argc == 1 )
	  {
		VSdrwStrVal( &argl->arg, feet_name );
	        test_flag = TRUE;
	  }
	  else
	  {
	  	strcpy( attr_name, "~~marking");
		if( 1 & VLgetOperName("", inp->elmId, attr_name,feet_name) )
		   test_flag = TRUE;
	  }

	  if( test_flag )
	  {
              sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                        msg,
                                        feet_name,
                                        &obj[nb_obj].obj_id,
                                        &obj[nb_obj].mod_env.md_env.matrix_type,
                                        obj[nb_obj].mod_env.md_env.matrix),
                            targetid = inp->elmId->objid,
                            targetos = inp->elmId->osnum,
                            senderid = inp->elmId->objid  );
	      if( sts & *msg & 1 )
	      {
		IGRchar		macName[128];

	        obj[nb_obj].mod_env._MD_OS = obj[nb_obj].obj_id.osnum;
        	sts = ex$get_modid(
				mod_osnum = obj[nb_obj].mod_env._MD_OS,
                                mod_id    = &obj[nb_obj].mod_env._MD_ID );

		vdobj$Get( objID   = inp->elmId,
			   macName = macName );
		if((!strcmp( macName, "Bevel" )  || 
		    !strcmp( macName, "EJ_Bevel" ) )&&
		    !strcmp( feet_name, "curve" ) )
		{
		    struct  GRsymbology     symbology;

		    symbology.display_attr = dspVis ;
      		    symbology.level = xData->overrides.elmLevel ;

		    outp->count = 1;
		    if( !( outp->list = _MALLOC( 1, struct GRid ) ) ) 
			vd_$mem_fail();
		    VLunwBevelMap( msg, dev, &obj[nb_obj].obj_id,
				   &cst, fromMat, toMat, &outp->list[0] );

		    om$send( msg   = message GRvg.GRputsymb( msg, &symbology ),
				senderid = NULL_OBJID,
				targetid = outp->list[0].objid,
				targetos = outp->list[0].osnum );
		    goto wrapup;
		}

		if(( vd_$is_ancestry_valid (object  = &obj[nb_obj].obj_id,
				  classid = OPP_GR3dtext_class_id)))
		{
		     txtFlag = VLgetGraphics_from__text(&obj[nb_obj],&graphic_group.obj_id);
		     if(txtFlag ==1 && graphic_group.obj_id.objid !=NULL_OBJID)
		     {
			graphic_group.mod_env = obj[nb_obj].mod_env; 
			obj[nb_obj].obj_id.objid = graphic_group.obj_id.objid;
			obj[nb_obj].obj_id.osnum = graphic_group.obj_id.osnum;
		     }
		}

		VLproject_curve( &dev->surf_id, &obj[nb_obj], &cst,
					&nb_inters, &inters );
		if( nb_inters && nb_inters > 1 )
		{
		  for( j=0; j<nb_inters; ++j )
		  {
		     obj[nb_obj].obj_id.objid = inters[j];
		     obj[nb_obj].obj_id.osnum = inp->drwInfo.drwEnv->md_id.osnum;
                     obj[nb_obj].mod_env = *inp->drwInfo.drwEnv;
                     nb_obj++;
		  }
		}
		else
		{
        	  obj[nb_obj].mod_env = *inp->drwInfo.drwEnv;
        	  obj[nb_obj].mod_env.md_id.osnum = obj[nb_obj].obj_id.osnum;
		  nb_obj++;
		}
	      }
	   }
	   for( i=0; i<10; ++i )
	   {
	      sprintf( attr_name, "~~marking%d", i );
	      if( VLgetOperName("", inp->elmId, attr_name,feet_name) & 1)
	      {
                 sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                        msg,
                                        feet_name,
                                        &obj[nb_obj].obj_id,
                                        &obj[nb_obj].mod_env.md_env.matrix_type,
                                        obj[nb_obj].mod_env.md_env.matrix),
                            targetid = inp->elmId->objid,
                            targetos = inp->elmId->osnum,
                            senderid = inp->elmId->objid  );
	         if( sts & *msg & 1 )
	         {
        	    obj[nb_obj].mod_env = *inp->drwInfo.drwEnv;
        	    obj[nb_obj].mod_env.md_id.osnum = obj[nb_obj].obj_id.osnum;
		    nb_obj++;
	         }
	      }
	   }
	   for( i=0; i<10; ++i )
	   {
	      sprintf( attr_name, "~~marking0%d", i );
	      if( VLgetOperName("", inp->elmId, attr_name,feet_name) & 1)
	      {
                 sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                        msg,
                                        feet_name,
                                        &obj[nb_obj].obj_id,
                                        &obj[nb_obj].mod_env.md_env.matrix_type,
                                        obj[nb_obj].mod_env.md_env.matrix),
                            targetid = inp->elmId->objid,
                            targetos = inp->elmId->osnum,
                            senderid = inp->elmId->objid  );
	         if( sts & *msg & 1 )
	         {
        	    obj[nb_obj].mod_env = *inp->drwInfo.drwEnv;
        	    obj[nb_obj].mod_env.md_id.osnum = obj[nb_obj].obj_id.osnum;
		    nb_obj++;
	         }
	      }
	   }
	}
	else
	{      
	   if(!strcmp( type, "control-line" )) strcpy( feet_name, NAM_CL_CV );
	   else 			       strcpy( feet_name, MAN_GR_FEET );

           __DBGpr_str("   feet_name  = ",feet_name);

           sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                        msg,
                                        feet_name,
                                        &obj[0].obj_id,
                                        &obj[0].mod_env.md_env.matrix_type,
                                        obj[0].mod_env.md_env.matrix),
                            targetid = inp->elmId->objid,
                            targetos = inp->elmId->osnum,
                            senderid = inp->elmId->objid  );
           __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );

   	   obj[0].mod_env = *inp->drwInfo.drwEnv;
           obj[0].mod_env.md_id.osnum = obj[0].obj_id.osnum;
	   nb_obj=1;
	}

	/* ========================================
	 * Sometimes get all the way here without any objects at all
	 */
	if (nb_obj < 1) {
	  //printf(">>> In VLunwLineProj, nb_obj is 0 for\n");
	  //vdobj$Print(objID = inp->elmId);	  
	  goto wrapup;
	}

	#if USE_NEW_MAPPING_ALGO
	    sts = VLprojAndMapCrvOntoSrf(  dev, nb_obj, obj, TRUE, &cst,
			fromMat, toMat, &outp->count, &outp->list );
	#else
	    if( !(outp->list = _MALLOC( 50, struct GRid )) )
			vd_$mem_fail();
	    sts = VLprojectLine( dev, nb_obj, obj, 0, &cst,
			&outp->count, &outp->list );
	#endif

        __DBGpr_int(" outp->count  = ",outp->count);
	__DBGpr_objlist("  outp->list --> ",outp->count,outp->list);

	for( j=0; j<nb_inters; ++j )
        sts = om$send(msg  = message GRgraphics.GRdelete( msg,
							  inp->drwInfo.drwEnv ),
			senderid = NULL_OBJID,
                        targetid = inters[j],
                        targetos = inp->drwInfo.drwEnv->md_id.osnum );

wrapup:
	_FREE( inters );
	if(txtFlag)
	{ 
	    //delete the graphic group 
            sts = om$send(msg  = message GRgraphics.GRdelete( msg,
						  &graphic_group.mod_env),
			senderid = NULL_OBJID,
                        targetid = graphic_group.obj_id.objid,
                        targetos = graphic_group.obj_id.osnum );
	}

	End ;
        return sts;
}

end implementation VDSroot;
 
