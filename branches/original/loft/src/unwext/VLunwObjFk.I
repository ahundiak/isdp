/* $Id: VLunwObjFk.I,v 1.5 2001/05/09 13:57:59 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwObjFk.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwObjFk.I,v $
 *      Revision 1.5  2001/05/09 13:57:59  ramarao
 *      Fixed ETL# 8192.
 *
 *      Revision 1.4  2001/03/14 23:49:20  ramarao
 *      Fixed a TR on expansion factors.
 *
 *      Revision 1.3  2001/02/20 01:07:27  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:01:16  ramarao
 *      *** empty log message ***
 *
# Revision 1.10  2000/11/20  21:48:34  pinnacle
# Replaced: loft/src/unwext/VLunwObjFk.I for:  by rchennup for Service Pack
#
# Revision 1.7  2000/08/01  15:10:04  pinnacle
# Replaced: loft/src/unwext/VLunwObjFk.I for:  by rchennup for Service Pack
#
# Revision 1.6  2000/05/21  15:02:22  pinnacle
# Replaced: loft/src/unwext/VLunwObjFk.I for:  by rchennup for Service Pack
#
# Revision 1.5  2000/05/19  15:51:42  pinnacle
# Replaced: loft/src/unwext/VLunwObjFk.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/04/21  21:47:36  pinnacle
# Replaced: loft/src/unwext/VLunwObjFk.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/10  16:38:06  pinnacle
# initial revision
#
# Revision 1.21  2000/03/30  22:36:22  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by impd252 for loft
#
# Revision 1.20  2000/03/01  20:46:22  pinnacle
# Replaced VLunwObjFk.I by jpulapar for Unwrap
#
# Revision 1.19  2000/02/16  19:08:02  pinnacle
# Initialized temp_int to zero.
#
# Revision 1.18  2000/02/11  22:40:08  pinnacle
# (No comment)
#
# Revision 1.17  2000/02/10  21:51:50  pinnacle
# (No comment)
#
# Revision 1.15  2000/01/28  19:44:42  pinnacle
# Stored the skrinkage ratois in the ACrg collector.
#
#
# Revision 1.7  1999/05/21  17:13:02  pinnacle
# Fixed Locate and Duplication problems TR#614 && 615
#
# Revision 1.6  1999/04/09  21:20:54  pinnacle
# Rama Rao SP08
#
# Revision 1.5  1998/11/05  06:22:22  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by smpathak for loft
#
# Revision 1.4  1998/11/05  06:09:48  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by manoj for loft
#
# Revision 1.3  1998/09/04  08:05:56  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by smpathak for loft
#
# Revision 1.2  1998/07/08  15:53:48  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by smpathak for loft
#
# Revision 1.13  1998/04/23  08:45:56  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by rchennup for loft
#
# Revision 1.10  1998/03/05  11:47:36  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by rchennup for loft
#
# Revision 1.8  1998/01/29  19:53:46  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by rchennup for loft
#
# Revision 1.4  1998/01/02  04:15:40  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by rchennup for loft
#
# Revision 1.3  1997/11/01  16:02:36  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by rchennup for loft
#
# Revision 1.2  1997/10/31  21:02:42  pinnacle
# Replaced: src/unwext/VLunwObjFk.I for:  by rchennup for loft
#
# Revision 1.1  1997/10/31  19:24:00  pinnacle
# Created: src/unwext/VLunwObjFk.I by rchennup for loft
#
 *
 * History:
 * MM/DD/YY   AUTHOR       DESCRIPTION
 * 10/31/97   Rama Rao     File Creation
 * 07/08/98   Sandeep      File modification for TR179800946
 * 08/26/98   ah           TR179801074 Dup marking lines
 * 08/27/98   SM PAthak	   File modification for TR179801429
 * 11/05/98   Manoj	   File modification for TR179801431
 * 11/05/98   SM PAthak    File modification for TR179801542
 * 04/09/99   ah           Rama Rao SP08 Fixes
 * 05/21/99   RR	   Added VLqueryLinesOnPlate() to fix locate problem
 * 12/03/99   Jayadev      Memory allocation problem of TR179900949
 * 12/23/99   Jayadev      Call to the shrinkage ppl COshrnk_fact and 
 *                         modifications to use the shrinkage factor
 *  1/28/00   RR	   Stored the skrinkage ratois in the ACrg collector.
 * 02/10/00   RR	   Used VLqueryLinesWithNoLocate() instead of
 *		           VLqueryLinesOnPlate(), which is very costly;	
 *************************************************************************/

class implementation VDSroot;

#include <stdio.h>
#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asmacros.h"
#include "exmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsdotp.h"
#include "bsnorvec.h"
#include "VDobj.h"
#include "v_miscmacros.h"
#include "v_datamacros.h"
#include "v_drw.h"
#include "v_pplslc.h"
#include "vddrwattr.h"
#include "vs.h"
#include "vsdef.h"
#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "vsstfnrdef.h"
#include "vsoptdef.h"
#include "vsattr.h"
#include "vsplate.h"
#include "vsgeommacros.h"
#include "vlunfold.h"
#include "vlmark.h"
#include "vlrolline.h"
#include "vlunwext.h"
#include "vluserkey.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlquerydef.h"
#include "vlstifftpl.h"

#include "VDchn.h"
#include "VDobj.h"
#include "VLunwMisc.h"
#include "vldbgmacros.h"

//#define DEBUG 1

extern  GRclassid       OPP_VLunwFeat_class_id,  OPP_ACpretend_class_id,
                        OPP_VLmrkLine_class_id,  OPP_VLrolLine_class_id,
			OPP_VLbutLine_class_id,  OPP_VLseaLine_class_id,
			OPP_VLwatLine_class_id,  OPP_VLtrace_class_id,
                        OPP_VSimbPlate_class_id, OPP_VSbooPlate_class_id,
			OPP_VSsubPlate_class_id, OPP_VSholPlate_class_id,
                        OPP_VSfeature_class_id, //TR#179801431
                        OPP_VSbeam_class_id ;
extern                  VLgetMacrosAtStep(), VLcheckStiffOnPlate();

from    VSfeature  import  VSgetResultType, VSgetOperationHistory;
from    ACpretend  import  ACfind_parent;
from    VLmrkLine  import  VLplace_mark;
from    VLrolLine  import  VLplaceRollLine;

from	ACmacro_defn    import  ACgive_temp_desc;
from    ACrg_collect	import	AClist_attribute, ACmod_list_attribute;

IGRlong VLgetNamedParent(
	struct  GRobj_env       *Macro,
	IGRchar			*Name,
	struct  GRobj_env       *Template
)
{
        IGRlong         sts=OM_S_SUCCESS;
	struct  GRid    DefId;
	struct  stemp   *stp;
        IGRint          i, num=0;

	stp = NULL;
	Template->_objid = NULL_OBJID;

        sts = _VD_SEND_OBJN( Macro->obj_id, ACcpx.find_macro ( &DefId ) );
	__CheckRC( sts, 1, "ACcpx.find_macro", wrapup );

        sts = _VD_SEND_OBJN( DefId, ACmacro_defn.ACgive_temp_desc(&num, &stp) );
        __CheckRC( sts, 1, "ACmacro_defn.ACgive_temp_desc", wrapup );
	for( i=0; i<num; ++i )
	{
	   if( !strcmp(stp[i].name, Name) )
	   {
	        vdobj$GetTemplate(objOE      = Macro,
                                  nth        = i,
				  templateOE = Template );
		break;
	   }
	}
wrapup:
        return (sts);
}

/*
    This function queries, filters and sorts objects.
    Ouput vertices that are the projection of minimum distance points.
    There are ordered from start to end of Line. 
*/


IGRint VLqueryLinesOnPlate(

	struct	GRobj_env	*Plate,	/*I Surface for range query	*/
		VLquLine	Qline[],/*I Array of class ID for filter*/
	struct	GRmd_env	*Env,	/*I Local environment		*/
		IGRint		*nlin,	/*O Number of lines		*/
	struct	GRobj_env	**Line,	/*O Lines array 		*/
		IGRlong		*msg	/*O Completion code		*/
)
{
/* Beginning of function */

		IGRint		sts=OM_S_SUCCESS, i, ncla=0, nsum=0;
	struct	GRmd_env	loc_env;
		IGRshort	world=TRUE;
		GRrange		range;

	/* Initialize */
	loc_env = *Env;
	ex$get_modid ( mod_osnum = loc_env.md_id.osnum,
                       mod_id    = &loc_env.md_id.objid );
	*nlin = 0;	*Line = NULL;

        sts = _VD_SEND_OBJN( Plate->obj_id, GRgraphics.GRgetrang (
                                  	msg,
					&Plate->_matrix_type,
					Plate->_matrix,
					&world,
					range		) );
	__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup );


	/* Send a (surface) range query */
	VLrLocRef ( range, nlin, Line, &loc_env);

#ifdef TRACE
printf( "VLrLocRef() returns %d objects\n", *nlin);
for( i=0; i<(*nlin); i++ )
	printf("\n Object[ %d ] = %d, %d", i, (*Line)[i]._objid, (*Line)[i]._osnum );
#endif

	/* Filter lines */
	if (*nlin) {
		nsum    = (*nlin);
		(*nlin) = 0;
		for ( i=0; i<IDX_SC_LINE; i++) {
			ncla = 0;
			if (Qline[i].query) {
				VLfilterDef ( nsum, &(*Line)[(*nlin)],
					      &ncla, Qline[i].dname );
#ifdef TRACE
printf( "\tVLfilterDef (%d objects) with <%s> and retains %d ...\n",
	nsum, Qline[i].dname, ncla);
#endif
				nsum    -= ncla;
				(*nlin) += ncla;
			}
		}
	}

wrapup:
	return (sts);
}

IGRlong	VLprocessFeats(	IGRlong			*msg,
			struct GRobj_env	unw_obj   )
{
   BSrc			   rc;
   IGRlong                 sts, loc_msg;
   unsigned long	   type;
   IGRdouble               length, width, new_length=0.0, new_width=0.0, scale, 
			   x_expansion=0.0, y_expansion=0.0, new_expansion=0.0,
			   length_scale=1.0, width_scale=1.0, vect[3],
			   prjPnt[3], prjVec[3], toMat[16], range[6];
   IGRint   		   i, j, k,ii, count, nb_feat=0, nb_roll=0, nb_mark=0,
			   nb_cntr=0, nbline=0, code=0, numObjects=0,
			   feature_count=0, drwExist, temp_int=0,
			   nbAttr=0, drwCount, drwVwCount,nb_stf_ver=0, 
			   nb_stf_hor=0, nb_but_ver=0, nb_but_hor=0, exp_type=0,
			   length_flag, optlines[UNWEXT_NB_OPT],
			   cn_type,b_mod, nb_tilda=0, plan_ind;
   struct GRobj_env        *pInList, modObj, plate, par_plate, footOE;
   struct  GRid            drwObj, *drwList, *drwVwList, list[2], 
			   res_id, root_feat, tmp_obj;
   struct  ACrg_coll       *Attr=NULL, list_att[UNFOLD_NB_OPT];
   struct GRobj_env        *list_obj  = NULL, *buf=NULL,*Qline = NULL, parOE;
   struct GRsymbology      loc_symb;
   struct EdgeMatch  	   *match_list=NULL;
   VDpartAttr              attr ;
   VD_drwMacInfo           *drwMacInfo=NULL ;
   VSopHistory             *history, *h ;
   IGRchar                 MarkName [50], status_msg[128], str_buf[256],
                           loc_path[DI_PATH_MAX];
   enum    GRdpmode        dpmode=GRbd;            // mode for placed mark
   IGRdouble               x_shrinkage=0.0,y_shrinkage=0.0;
   IGRdouble               plt_thickness;
   VSpartAttr            PltAttr ;
   VSplateAttr           PltInfo ;

   SetProc( VLprocessFeats  ); Begin
				 pInList         = NULL ;
   drwMacInfo      = NULL ;        /* Visual support file info     */
   drwCount        = 0 ;           /* Number of created objects    */
   drwList         = NULL ;        /* List of created objects      */
   drwVwCount      = 0 ;           /* Number of to connect objects */
   drwVwList       = NULL ;        /* List of to connect objects   */
   history         = NULL ;
   cn_type    	   = ND_COMP;
 
   prjVec[0] = 0 ;    prjVec[1] = 0 ;    prjVec[2] = 1 ;
   prjPnt[0] = 0 ;    prjPnt[1] = 0 ;    prjPnt[2] = 0 ;
   
   for ( i=0; i<UNFOLD_NB_OPTLINE; i=i+1 ) optlines[i] = 1;
   /*
    * In match_list EdgeId  : Feature Object ( VLunwFeat )
    * 		 EdgeMac : Model Macro ( Like WaterLine, MarkingLine,.
    */
   sts = VLunwGetFeaturesParents(  msg, unw_obj.obj_id, optlines, 
				   &feature_count, &match_list  );
   __CheckRC( sts, *msg, "VLunwGetFeaturesParents", wrapup );
   
   sts = _VD_SEND_OBJN( unw_obj.obj_id, NDnode.NDget_objects( ND_ROOT,
							      list, 2, NULL, 0, 1, &j ));
   __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );
   __DBGpr_obj( " ACrg Collector ", list[0] );
   __DBGpr_obj( " Plate Template ", list[1] );
   
   /* Find attributes */
   sts = _VD_SEND_OBJN( list[0], ACrg_collect.AClist_attribute(
     msg, UNFOLD_NB_OPT, list_att, &k) );
   __CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup );
   
   sts = _VD_SEND_OBJN( list[1], NDmacro.ACreturn_foot(
     msg, "", &plate.obj_id,
     &plate._matrix_type,
     plate._matrix		) );
   __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );
   __DBGpr_obj( " Original Plate in model ", plate.obj_id );
   plate._md_os = plate.obj_id.osnum;
   ex$get_modid(   mod_osnum = plate._md_os,
		   mod_id    = &plate._md_id ) ;
   
   if ((j=VLseekFields(list_att,k,UNFOLD_ATT_LINES)) != -1) {
     code = list_att[j].desc.value.att_exp;
   }
   
   VLdecode( code, UNWEXT_NB_OPT, optlines );

#if 0
   if( optlines[UNWEXT_ATT_IDX_PARENT] &&
       ! vd_$is_ancestry_valid(   object  = &plate.obj_id,
				  classid = OPP_VSsubPlate_class_id ) )
   {
     sts = _VD_SEND_OBJN( plate.obj_id, VSfeature.VSgetResultType(
       msg, &type ) );
     __CheckRC( sts, *msg, "Getting plate type", wrapup ) ;
     
     if( ( type & VS_m_BOO_PLATE ) || ( type & VS_m_IMB_PLATE ) )
     {
       sts = _VD_SEND_OBJN( plate.obj_id, VSfeature.VSgetOperationHistory(
	 msg, &plate.mod_env, &history ) );
       __CheckRC( sts, *msg, "Getting Operation History", wrapup ) ;
       
       for( h = history ; h ; h = h->next ) {
	 res_id.objid = h->resultId;
	 res_id.osnum = h->resultOs;
	 if( vd_$is_ancestry_valid( object  = &res_id,
				    classid  = OPP_VSbooPlate_class_id ) ||
	     vd_$is_ancestry_valid( object  = &res_id,
				    classid  = OPP_VSimbPlate_class_id ) ||
	     vd_$is_ancestry_valid( object  = &res_id,
				    classid  = OPP_VSholPlate_class_id ) )
	   continue;
	 
	 par_plate.obj_id.objid = h->resultId;
	 par_plate.obj_id.osnum = h->resultOs;
	 par_plate.mod_env      = h->resultEnv;
       }
     } else par_plate = plate;
   }
   else par_plate = plate;
#endif

   par_plate = plate;
      
   if( optlines[UNWEXT_ATT_IDX_AUTOMRK] && optlines[UNFOLD_ATT_IDX_ROL] )
   {
     IGRvector        ship_axis;
     struct GRobj_env roll_line;
     
     VLbrowseFctInTree( &plate, VL_Q_TOP_SOURCE, NULL, VL_Q_DOWN_DIRECT,
			VLgetMacrosAtStep, &numObjects, &list_obj );
     VLfilterDef(numObjects,list_obj,&numObjects,"RolLn");
     
     if( !numObjects )
     {
       struct GRobj_env       surfObj;
       struct IGRbsp_surface  *bspSf;   // pointer to Bspline surface
       struct GRparms         param;   // projection parameters
       IGRpoint               ptI,ptTmp ;// projection & calculations
       BSrc                   bsrc;       // Maths return code
       IGRint                 numNormals; // number of normals to surf
       IGRvector              normalI[1], // unit normal
	                      direct1,
	                      direct2;    // possible directions
       IGRdouble              curvature1, // principal curvature in u
	                      curvature2, // principal curvature in v
	                      uI,vI;      // u and v parameters 
       // ( normally 0.5 )
       IGRboolean	       roll_direction;
       
       sts = om$send( msg = message NDmacro.ACreturn_foot(
	 &loc_msg,
	 VS_K_plBotSfPath,
	 &surfObj.obj_id,
	 &surfObj.mod_env.md_env.matrix_type,
	 surfObj.mod_env.md_env.matrix ),
		      senderid = NULL_OBJID,
		      targetid = plate._objid,
		      targetos = plate._osnum  ) ;
       if (!(sts&loc_msg&1)) goto wrapup;
       surfObj.mod_env = plate.mod_env;
       
       sts=om$send ( msg = message GRvg.GRgenabsg(
	 &loc_msg,
	 &surfObj.mod_env.md_env.matrix_type,
	 surfObj.mod_env.md_env.matrix,
	 (IGRchar **) &bspSf ),
		     senderid = NULL_OBJID,
		     targetid = surfObj.obj_id.objid,
		     targetos = surfObj.obj_id.osnum);
       if (!(sts&loc_msg&1)) goto wrapup;
       
       // get the unit normal
       BSsfevaln( bspSf, 0.5, 0.5, 1, &numNormals, ptI, 
		  normalI, &bsrc);
       if (bsrc!=BSSUCC){ printf("BSsfevaln : FAIL \n"); goto wrapup; }
       
       // get the curvatures
       
       uI = 0.5; 	vI = 0.5;
       BSsfarrevmc( bspSf, 1, &uI, 1, &vI, FALSE, FALSE, TRUE, FALSE, 
		    TRUE,FALSE, ptI, NULL,NULL,&curvature1,
		    &curvature2,NULL,direct1, direct2, NULL, &bsrc);
       if (bsrc!=BSSUCC){printf("BSsfarrevmc : FAIL \n"); goto wrapup;}
       
       if ( fabs(curvature1)<fabs(curvature2) ) 
       { v_add(ptI,direct2,ptTmp); }
       else	{ v_add(ptI,direct1,ptTmp); }
       
       sts = om$send (msg = message GRgraphics.GRptproject (
	 &loc_msg,
	 &surfObj.mod_env.md_env.matrix_type,
	 surfObj.mod_env.md_env.matrix,
	 ptTmp,
	 ptI,
	 &param),
		      senderid = NULL_OBJID,
		      targetid = surfObj.obj_id.objid,
		      targetos = surfObj.obj_id.osnum);
       if (!(sts&loc_msg&1)) goto wrapup;
       
       if (fabs(param.u-uI)>=fabs(param.v-vI)) roll_direction=FALSE;
       else   					roll_direction=TRUE;
       
       ship_axis[0]=1.0;
       ship_axis[1]=0.0;
       ship_axis[2]=0.0;
       roll_line.obj_id.osnum = unw_obj._osnum;
       roll_line.mod_env = unw_obj.mod_env;
       
       sts = om$construct( classid    =  OPP_VLrolLine_class_id,
			   osnum      =  roll_line.obj_id.osnum,
			   p_objid    =  &roll_line.obj_id.objid,
			   msg        =  message VLrolLine.VLplaceRollLine(
			     &loc_msg ,
			     VS_K_baOnBotOfPlate,
			     1,
			     roll_direction,
			     ship_axis,
			     1,
			     &plate,
			     &unw_obj.mod_env,
			     NULL,
			     NULL  ) );
       if (!(sts&loc_msg&1)) goto wrapup;
       
       loc_path[0] = '\0';
       
       sts = VDSget_dir_and_symb ( &loc_msg, &roll_line.obj_id,
				   ROLL_KEY, NULL, loc_path, &loc_symb.level, 
				   &loc_symb.display_attr );
       if (!(sts&loc_msg&1)) goto skip;
       
       VLoccNaming1(loc_path, VLMacroRolLn, MarkName, &loc_msg);
       if (!(loc_msg&1)) goto skip;
       
       sts =     VLsetSymb_Name_Disp(
	 &loc_msg,
	 MarkName,
	 ROLL_KEY,
	 &plate.obj_id,
	 &roll_line.obj_id,
	 &dpmode,
	 &roll_line.mod_env  );
       
     skip:
       _FREE( buf );		buf = NULL;
       _FREE( list_obj );    	list_obj = NULL;
       numObjects = 0;
     }
   }
   
   if( vd_$is_ancestry_valid( object  = &par_plate.obj_id,
			      classid = OPP_ACpretend_class_id )){
     sts = _VD_SEND_OBJN(  
       par_plate.obj_id,
       ACpretend.ACfind_parent( 
	 &par_plate.obj_id,
	 &par_plate.mod_env.md_env.matrix_type,
	 par_plate.mod_env.md_env.matrix ) );
   }
   
   VLbrowseFctInTree( &par_plate, VL_Q_TOP_ORIGINAL, NULL,
		      VL_Q_DOWN_DIRECT,
		      VLgetMacrosAtStep,
		      &numObjects,
		      &list_obj );

   
   attr.Iwant = VL_I_toMat ;
   attr.specific = (void *) toMat ;
   sts = _VD_SEND_OBJN( unw_obj.obj_id, GRvg.GRgetattr( 
     msg, (char *)&attr ));
   __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );
   
   if ((j=VLseekFields(list_att,k,UNFOLD_ATT_EXPTYPE)) != -1) {
     exp_type = list_att[j].desc.value.att_exp;
   }
   
   // if (exp_type) {
     if ((j=VLseekFields(list_att,k,UNFOLD_ATT_X_EXPANSION)) != -1) {
       x_expansion = list_att[j].desc.value.att_exp;
     }
     if ((j=VLseekFields(list_att,k,UNFOLD_ATT_Y_EXPANSION)) != -1) {
       y_expansion = list_att[j].desc.value.att_exp;
     }
   //}
   
   if ((j=VLseekFields(list_att,k,UNFOLD_ATT_LINES)) != -1) {
     code = list_att[j].desc.value.att_exp;
   }
   
   vd$ppl_getarg_at_index(  which_info = GLOBAL_INFO,
			    index      = 0,
			    value      = &length   );
   
   vd$ppl_getarg_at_index(  which_info = GLOBAL_INFO,
			    index      = 1,
			    value      = &width   );
   
   vdobj$GetFoot( objOE    = &par_plate,
                  footName = VS_K_plGrCmpName,
                  footOE   = &footOE );

   vs$getRangeOfComposite( msg       = msg,
                           composite = &footOE,
                           range     = range );

   vect[0] = range[3] - range[0];
   vect[1] = range[4] - range[1];
   vect[2] = range[5] - range[2];
   BSnorvec( &rc, vect );

   VLunwGetPlatePlane( msg, &par_plate, &plan_ind );

   if( ( plan_ind == 0 && vect[1] > vect[2] ) ||
       ( plan_ind == 1 && vect[0] > vect[2] ) ||
       ( plan_ind == 2 && vect[0] > vect[1] ) )	length_flag = 1 ;
   else						length_flag = 0 ;

#ifdef DEBUG
     printf("\n Expansion Type = %d", exp_type );
#endif
   
   if ( exp_type == BY_STIFFNERS ) {
     
     sts = VLgetNumHorVerLns( &plate, 1, &unw_obj.mod_env, 
			      &nb_stf_hor, &nb_stf_ver );
     if (sts != MSSUCC) {
       printf("Problems at getting stiffners\n");
       nb_stf_hor = 0;
       nb_stf_ver = 0;
     }
     
#ifdef DEBUG
     printf("\n length_flag = %d length and width [%f,%f] \n",length_flag,length,width);
#endif
     sts = VLgetNumHorVerLns( &plate, 0, &unw_obj.mod_env, 
			      &nb_but_hor, &nb_but_ver );
     if (sts != MSSUCC) {
       nb_but_hor = 0;
       nb_but_ver = 0;
     }
#ifdef DEBUG
     printf("\n No. of Hor,Ver stiff [%d,%d] \n",nb_stf_hor,nb_stf_ver);
#endif
     
     PltAttr.Iwant    = VS_m_Thickness;
     PltAttr.specific = (void *) &PltInfo ;
     
     sts = om$send(  msg     = message GRvg.GRgetattr( msg,
						       (char *)&PltAttr),
		     senderid = NULL_OBJID,
		     targetid = plate.obj_id.objid,
		     targetos = plate.obj_id.osnum );
     if( ! (sts&*msg&1))  {
       //printf(" Going to wrapup at line %d\n",__LINE__);
       goto wrapup;
     }
     plt_thickness = PltInfo.thickness;
#ifdef DEBUG
     printf("\n Plate Thickness : %f \n",plt_thickness);
     printf("\n unw_obj osnum = %d \n",unw_obj.mod_env.md_id.osnum); 
#endif
     
     // if length_flag is true, vertical stiffeners & length are along x_axis
     {
       
       vd$ppl_set_size(  which_info = INPUT_INFO,
			 size  = 7);
       
       vd$ppl_setarg_at_index( which_info = INPUT_INFO,
			       index = 0,
			       type  = VD_double,
			       value = &plt_thickness);
       vd$ppl_setarg_at_index( which_info = INPUT_INFO,
			       index = 1,
			       type  = VD_double,
			       value = &length);
       vd$ppl_setarg_at_index( which_info = INPUT_INFO,
			       index = 2,
			       type  = VD_double,
			       value = &width);
       vd$ppl_setarg_at_index( which_info = INPUT_INFO,
			       index = 3,
			       type  = VD_int,
			       value = &nb_stf_ver);
       vd$ppl_setarg_at_index( which_info = INPUT_INFO,
			       index = 4,
			       type  = VD_int,
			       value = &nb_stf_hor);
       vd$ppl_setarg_at_index( which_info = INPUT_INFO,
			       index = 5,
			       type  = VD_int,
			       value = &length_flag);
       vd$ppl_setarg_at_index( which_info = INPUT_INFO,
			       index = 6,
			       type  = VD_int,
			       value = &unw_obj.mod_env.md_id.osnum);
       vd$ppl_exec(  file_name = "COshrnk_fact",func_name = "main_both");
       
       vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
			       index      = 0,
			       value      = &x_shrinkage);
       vd$ppl_getarg_at_index( which_info = OUTPUT_INFO,
			       index      = 1,
			       value      = &y_shrinkage);
       
       vd$ppl_free_args( which_info = INPUT_INFO );
       vd$ppl_free_args( which_info = OUTPUT_INFO );
       
       // check if something has gone wrong inside the ppl
       if((x_shrinkage ==0.0) && (y_shrinkage == 0.0)) goto no_shrinkage;
       
#ifdef DEBUG
       printf("\n shrinkage factors [x_shrink:%f,y_shrink:%f] \n",x_shrinkage,y_shrinkage);
#endif
       if( length_flag )   // Legth is along X-axis
       {
/*
	 new_width = width + nb_stf_hor*y_shrinkage;
	 new_length =length+ nb_stf_ver*x_shrinkage;
*/
	 new_width = width*y_shrinkage;
	 new_length =length*x_shrinkage;
       }
       else
       {
/*
	 new_width = width + nb_stf_ver*x_shrinkage;
	 new_length =length + nb_stf_hor*y_shrinkage;
*/
	 new_width = width*x_shrinkage;
	 new_length =length*y_shrinkage;
       }
#ifdef DEBUG
       printf("\n Length and width values after shrinkage is applied :\n");
       printf("\n new_length and new_width [%f,%f] \n",new_length, new_width);
       printf("\n length and width [%f,%f] \n",length, width);
#endif
       goto shrink_applied;
     }
     
   no_shrinkage:
#ifdef DEBUG
     printf("\n Shrinkage factor not applied using the chart \n");
#endif
     new_width = width+nb_stf_hor*y_expansion;
     new_length = length+nb_stf_ver*x_expansion;
   }
   else {
     if ( exp_type == GLOBAL_LW_RATIO) {
       new_width = width+width*y_expansion;
       new_length = length+length*x_expansion;
     }
   }
 shrink_applied:
   if( new_length != 0.0 )  length_scale = new_length/length;
   if( new_width  != 0.0 )  width_scale  = new_width/width;
  
#ifdef DEBUG
printf("\n length_scale,width_scale [%f,%f] \n",length_scale,width_scale);
#endif

   if( length_flag ) new_expansion = length_scale - 1.0 ;
   else		     new_expansion = width_scale - 1.0 ;

   #ifdef DEBUG
	printf("\n New X-expansion value = %g, Old Value = %g", new_expansion, x_expansion );
   #endif
   
   if( x_expansion != new_expansion )
   {
           strcpy(list_att[0].name,UNFOLD_ATT_X_EXPANSION);
           list_att[0].desc.type = AC_ATTRIB_DOUBLE;
           list_att[0].desc.value.att_exp = new_expansion;

	   #ifdef DEBUG
		printf("\n Modifying the X Value from %g to %g", x_expansion, new_expansion );
	   #endif

           sts = _VD_SEND_OBJN( list[0], ACrg_collect.ACmod_list_attribute(
                                                msg, 1, list_att ) );
           __CheckRC( sts, *msg, "ACrg_collect.ACmod_list_attribute", wrapup );
   }

   if( length_flag ) new_expansion = width_scale - 1.0 ;
   else              new_expansion = length_scale - 1.0 ;

   #ifdef DEBUG
        printf("\n New Y-expansion value = %g, Old Value = %g", new_expansion, y_expansion );
   #endif

   if( y_expansion != new_expansion )
   {    
           strcpy(list_att[0].name,UNFOLD_ATT_Y_EXPANSION);
           list_att[0].desc.type = AC_ATTRIB_DOUBLE;
           list_att[0].desc.value.att_exp = new_expansion;

           #ifdef DEBUG
                printf("\n Modifying the Y Value from %g to %g", y_expansion, new_expansion );
           #endif

           sts = _VD_SEND_OBJN( list[0], ACrg_collect.ACmod_list_attribute(
                                                msg, 1, list_att ) );
           __CheckRC( sts, *msg, "ACrg_collect.ACmod_list_attribute", wrapup );
   }    
#ifdef DEBUG
printf("\n filling the matrices with length,width_scale [%f,%f] \n",length_scale,width_scale);
#endif
   if( length_flag ) 	scale = length_scale;
   else			scale = width_scale;
   
   toMat[0]  = toMat[0]*scale;
   toMat[4]  = toMat[4]*scale;
   toMat[8]  = toMat[8]*scale;
   toMat[12] = toMat[12]*scale;
   
   if( length_flag )  scale = width_scale;
   else               scale = length_scale;
   
   toMat[1] = toMat[1]*scale;
   toMat[5] = toMat[5]*scale;
   toMat[9] = toMat[9]*scale;
   toMat[13] = toMat[13]*scale;
   
   attr.Iwant = VL_I_toMat ;
   attr.specific = (void *) toMat ;
   sts = _VD_SEND_OBJN( unw_obj.obj_id, GRvg.GRputattr( 
     msg, (char *)&attr ));
   __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );
   
   if( !optlines[UNWEXT_ATT_IDX_ADDFEAT] ) 
   {
     for( i=0; i<feature_count; ++i )
     {
       sts = _VD_SEND_OBJN( match_list[i].EdgeId, GRgraphics.GRdelete(
	 msg, &unw_obj.mod_env ));
       if( !(sts&(*msg)&1)) continue;
     }
     goto wrapup;
   }
   
   if( optlines[UNFOLD_ATT_IDX_ROL] )
   {
     VLfilterDef( numObjects, list_obj, &nb_roll, "RolLn" );
     nb_feat += nb_roll;
   }
   
   //if( optlines[UNFOLD_ATT_IDX_MARK] )
   {
     FILE	   *setup_file=NULL;
     IGRchar test_str[80], macro_name[80];
     
     /* Get the visualization support file */
     attr.Iwant = VD_I_drwVisual ;
     sts = _VD_SEND_OBJN( unw_obj.obj_id, GRvg.GRgetattr(msg,(char *)&attr));
     __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup );
     
     // setup_file = fopen( attr.aString, "r" );

     setup_file = VLunwOpenSetupFilex( attr.aString, NULL );

     if( setup_file == NULL )
     {
       printf("\n Setup file not found: %s", attr.aString );
       goto wrapup;
     }
     
     while( fgets( str_buf, sizeof(str_buf), setup_file ) )
     {
       IGRchar *p=NULL;

       test_str[0]   = '\0' ;
       macro_name[0] = '\0' ;

       sscanf( str_buf, "%s %s",test_str, macro_name );

       temp_int = 0;

       p = strchr( macro_name, ':');
       if( p ) *p = '\0';
       if( !strcmp( test_str, "#SPECIALMACRO"))
       {
	 VLfilterDef( numObjects-nb_feat, &list_obj[nb_feat],
		      &nb_mark, macro_name );

         if( p && nb_mark )
         {
     	    i = nb_feat;
      
     	    do
     	    {
	   	struct GRid model_obj;

	   	sts = VLgetNamedParent( &list_obj[i], p+1, &parOE);
     	   	__CheckRC( sts, 1, "VLgetNamedParent", wrapup );
	   	if( vdobj$GetPretendParent(pretendID = &parOE.obj_id,
                                            parentID = &model_obj ) )
	   	{
	   	    if( model_obj.objid != NULL_OBJID )
	   	    {
		   	parOE.obj_id.objid = model_obj.objid;
		   	parOE.obj_id.osnum = model_obj.osnum;
	   	    }
	     	}

	   	if( !(( parOE.obj_id.objid == plate.obj_id.objid ) &&
	              ( parOE.obj_id.osnum == plate.obj_id.osnum ) ) )
	   	{
	    	    list_obj[i].obj_id.objid = NULL_OBJID;
            	    ++temp_int;
	   	}

	   	++i;
	   	if( i-nb_feat == nb_mark ) 
	   	{
 	    	   nb_mark -= temp_int;
	    	   break;
	   	}
            } while(1);

            j = 0;
            for( i=nb_feat; i<nb_feat+nb_mark+temp_int; ++i )
            { 
	   	if( list_obj[i].obj_id.objid != NULL_OBJID )
	   	{
	    	   list_obj[nb_feat+j] = list_obj[i];
	    	   j++;
	        }
            }  
            nb_feat += nb_mark;
	 }
         else
         {
            nb_feat += nb_mark;
         }
       }
     };
     
     fclose( setup_file );
   }

   temp_int = 0;

   if( optlines[UNFOLD_ATT_IDX_MARK] )
   {
     VLfilterDef( numObjects-nb_feat, &list_obj[nb_feat],&nb_mark,"Mark");

     if( nb_mark )
     {
     	i = nb_feat;
      
     	do
     	{
	   struct GRid model_obj;
  	   vdobj$GetTemplate(objOE      = &list_obj[i],
                 	     nth        = 1,
                	     templateOE = &parOE);
	   if( vdobj$GetPretendParent(pretendID = &parOE.obj_id,
                                       parentID = &model_obj ) )
	   {
	   	if( model_obj.objid != NULL_OBJID )
	   	{
		   parOE.obj_id.objid = model_obj.objid;
		   parOE.obj_id.osnum = model_obj.osnum;
	   	}
	   }

	   if( !(( parOE.obj_id.objid == plate.obj_id.objid ) &&
	         ( parOE.obj_id.osnum == plate.obj_id.osnum ) ) )
	   {
	    	list_obj[i].obj_id.objid = NULL_OBJID;
            	++temp_int;
	   }

	   ++i;
	   if( i-nb_feat == nb_mark ) 
	   {
 	    	nb_mark -= temp_int;
	    	break;
	   }
        } while(1);

        j = 0;
        for( i=nb_feat; i<nb_feat+nb_mark+temp_int; ++i )
        { 
	   if( list_obj[i].obj_id.objid != NULL_OBJID )
	   {
	    	list_obj[nb_feat+j] = list_obj[i];
	    	j++;
	   }
         }  

         nb_feat += nb_mark;
     }

     VLfilterDefAttrName( numObjects-nb_feat, &list_obj[nb_feat],
			  &nb_tilda, "~~marking" );
     nb_feat += nb_tilda;
     
     for( i=0; i<10; ++i )
     {
       nb_tilda = 0;
       sprintf( MarkName,"~~marking%d",i );
       VLfilterDefAttrName( numObjects-nb_feat, &list_obj[nb_feat],
			    &nb_tilda, MarkName );
       nb_feat += nb_tilda;
     }
     
     for( i=0; i<10; ++i )
     {
       nb_tilda = 0;
       sprintf( MarkName,"~~marking0%d",i );
       VLfilterDefAttrName( numObjects-nb_feat, &list_obj[nb_feat],
			    &nb_tilda, MarkName );
       nb_feat += nb_tilda;
     }
   }
   
   if( optlines[UNFOLD_ATT_IDX_CTRL] )
   {
     __DBGpr_com(" .... The control line required  ");
     VLfilterDef( numObjects-nb_feat, &list_obj[nb_feat],
		  &nb_cntr,"platejig_mgr");
     __DBGpr_int(" .. The cntr count = ",nb_cntr);
     __DBGpr_obj(" The list_obj in output",list_obj[nb_feat].obj_id);
     for(ii=0;ii<nb_cntr; ii++)
     {
       vdchn$Get(il_objOE  = & (list_obj[nb_feat+ii]) ,
		 ic_IDX    = VDCHN_IDX_TO_COMPONENTS,
		 ir_objIDX = 0,
		 or_objID  = & tmp_obj);
       
       __DBGpr_obj("The tmp_obj   ",tmp_obj);
       list_obj[nb_feat+ii].obj_id = tmp_obj;
     }
     nb_feat += nb_cntr;
     
   }
  
   if( 	optlines[UNFOLD_ATT_IDX_BUTT]  || optlines[UNFOLD_ATT_IDX_SEAM] ||
	optlines[UNFOLD_ATT_IDX_WATER] || optlines[UNFOLD_ATT_IDX_TRACE]   )	 
   {
	IGRint		nb_class=0;
	GRclassid	classids[4];
   
   	if( optlines[UNFOLD_ATT_IDX_BUTT]  ) classids[nb_class++] = OPP_VLbutLine_class_id;
   	if( optlines[UNFOLD_ATT_IDX_SEAM]  ) classids[nb_class++] = OPP_VLseaLine_class_id;
   	if( optlines[UNFOLD_ATT_IDX_WATER] ) classids[nb_class++] = OPP_VLwatLine_class_id;
   	if( optlines[UNFOLD_ATT_IDX_TRACE] ) classids[nb_class++] = OPP_VLtrace_class_id;

        sts = VLqueryLinesWithNoLocate ( msg, &plate, &unw_obj.mod_env, nb_class,
                classids, &nbline, &Qline );
   	__CheckRC( sts, *msg, "VLqueryLinesOnPlate", wrapup );
   
   	if (nbline) {
     	     if( !( list_obj = _REALLOC( list_obj, 
				 nb_feat+nbline, struct GRobj_env )) )
       	     vd_$mem_fail();
     
     	     for (i=0;i<nbline;i++)  list_obj[i+nb_feat] = Qline[i];
     	     nb_feat += nbline;
   	}
   }
 
   count = nb_feat;
   for( i=0; i<feature_count; ++i )
   {
     for( j=0; j<nb_feat; ++j )
     {
       if( match_list[i].EdgeMac.objid == list_obj[j]._objid &&
	   match_list[i].EdgeMac.osnum == list_obj[j]._osnum	)
       {
	 sts = nd$wait_batch( 	type        = GR_GEOM_POSTED,
			 	nb_obj      = 1,
			 	l_object    = &match_list[i].EdgeId,
			 	l_obj_info  = &cn_type );
	 VLswapObjEnv( list_obj, j, (count-1) );
	 --count;
	 break;
       }
     }
     if( j==nb_feat )
     {
       sts = _VD_SEND_OBJN( match_list[i].EdgeId, GRgraphics.GRdelete( 
	 msg, &unw_obj.mod_env ));
       __CheckRC( sts, *msg, "GRgraphics.GRdelete", wrapup );
     }
   }
   
   nb_feat = count;
   
   if( !nb_feat ) goto wrapup;
   
   i = 0;
   
 check_i:
   if( i<(count-1) )
   {
     j = i+1;
   check_j:
     if( j<(count-1) )
     {
       if( list_obj[i]._objid == list_obj[j]._objid &&
	   list_obj[i]._osnum == list_obj[j]._osnum )
       {
	 VLswapObjEnv( list_obj, i, (count-1) );
	 --count;
	 i=0;
	 goto check_i;
       }
       j += 1;
       goto check_j;
     }
     i += 1;
     goto check_i;
   }   
   
   nb_feat = count;
   pInList = list_obj;
   
   __DBGpr_int( " Final Features ", nb_feat );	
   // nb_feat coming as negative at times - for TR179900949
   if( nb_feat > 0 ) {
     if( !( drwList = _MALLOC( nb_feat, struct GRid )))
       vd_$mem_fail();
     
     if( !( drwVwList = _MALLOC( nb_feat, struct GRid )))
       vd_$mem_fail();
   }
   else goto wrapup;
   
   for( i=0 ; i<nb_feat ; i++ )
   {
     sprintf(status_msg, "Mapping Lines ... %d / %d", i+1, nb_feat );
     UI_status( status_msg );

     sts = _VD_SEND_OBJN(  pInList[i]._grid,
			   NDmacro.ACreturn_foot(
			     msg,
			     "",
			     &modObj._grid,
			     &modObj._matrix_type,
			     modObj._matrix ));
     if( !( sts & *msg & 1 ) ) continue;
     
     modObj._md_os = modObj._osnum;
     
     drwObj.objid = NULL_OBJID;
     drwObj.osnum = unw_obj._md_os;
     
     /***
	 Check if the object has already a "VLunwFeat"
	 objects connected to him
	 
	 sts = VDchk_child_on_class(   msg,
	 &modObj._grid,
	 &(pInList[i]._grid),
	 "VLunwFeat",
	 &drwObj );
     ***/
     
     drwExist = ( drwObj.objid == NULL_OBJID ) ? FALSE : TRUE ;
     
            /* Construct a new object */
     sts = VLunw_ConstructFeat( msg, &drwObj, &unw_obj.mod_env, &modObj);
     CheckRC( sts, *msg );
     
     if( !(sts & *msg & 1)){
       if( drwObj.objid == NULL_OBJID ) continue ;
       sts = vd_$bulk_delete( count   = 1,
			      grids   = &drwObj,
			      theEnv  = &unw_obj.mod_env );
       continue ;
     }
     
     sts = VLunwMgr_ConnectObjectsToVw(  msg, &unw_obj.mod_env, 
					 &unw_obj.obj_id, 1, &drwObj );
     __CheckRC( sts, *msg, "VLunwMgr_ConnectObjectsToVw", wrapup );
     
     /* Add roots to object */
     if( ! drwExist )
     {
       /* Check the parent attributes and set them in the
	  collector. Find the macro definition of parent and
	  check with attribute list from the setup files.    */

       sts = VD_drw_GiveObjAttrList( msg, &modObj, drwMacInfo,
				     &nbAttr, &Attr );
       
       as$make_source( go_grid  = pInList[i]._grid,
		       mod_env  = &pInList[i].mod_env,
		       as_grid  = &root_feat      );
       
       sts = _VD_SEND_OBJN(  drwObj,
			     VDSroot.VDcreate(
			       msg,
			       nbAttr,
			       Attr,
			       "VLunwFeat",
			       //                                                AChdr_nodisplay|AChdr_nocompute,
			       AChdr_nodisplay,
			       1,
			       &root_feat ));
       
       /* Free the memory for the attributes */
       _FREE(  Attr );
       nbAttr = 0 ;
       Attr = NULL ;
       
       if( ! (sts&*msg&1))
       {
	 sts = vd_$bulk_delete( count   = 1,
				grids   = &drwObj,
				theEnv  = &unw_obj.mod_env 	);
	 continue;
       }
       
       sts = _VD_SEND_OBJN( drwObj, GRgraphics.GRdisplay( msg,
							  &unw_obj._matrix_type, unw_obj._matrix,
							  &dpmode, &unw_obj.mod_env.md_id ) );
       __CheckRC( sts, *msg, "GRgraphics.GRdisplay", wrapup ) ;
       
       /* Add in list to connect */
       drwVwList[drwVwCount++] = drwObj ;
     }
     /* Add in list to process */
     drwList[drwCount++] = drwObj;
   }
   
   nd$mod_batch(request     = ND_INQ,
		p_ret_mode  = &b_mod );
   if( b_mod != ND_DEFER ) nd$exec_batch(); 

 wrapup:
   VD_drwFreeExtractMacInfo( drwMacInfo ) ;
   VSfreeOpHistory( history ) ;
   _FREE( list_obj );  
   _FREE( drwList ); 
   _FREE( drwVwList );
   _FREE( match_list );
   _FREE( Qline );
   _FREE( buf );	 End;
   return sts;
}

end implementation VDSroot;
