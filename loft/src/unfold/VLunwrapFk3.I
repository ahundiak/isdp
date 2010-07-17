/* $Id: VLunwrapFk3.I,v 1.3 2001/02/20 01:07:06 build Exp $  */

/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loftdp/src/unfold/VLunwrapFk3.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwrapFk3.I,v $
 *      Revision 1.3  2001/02/20 01:07:06  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/02/14 20:39:21  ramarao
 *      Modification related to __DBGpr_obj() macro.
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:42  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/03/30  22:40:16  pinnacle
# Replaced: src/unfold/VLunwrapFk3.I for:  by impd252 for loft
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.7  1997/04/02  05:43:30  pinnacle
# Replaced: src/unfold/VLunwrapFk3.I for:  by rchennup for loft
#
# Revision 1.6  1997/02/23  22:48:20  pinnacle
# Replaced: src/unfold/VLunwrapFk3.I for:  by rchennup for loft
#
# Revision 1.5  1997/01/29  20:35:28  pinnacle
# Replaced: src/unfold/VLunwrapFk3.I for:  by rchennup for loft
#
# Revision 1.4  1996/11/01  06:03:18  pinnacle
# Replaced: src/unfold/VLunwrapFk3.I for:  by rchennup for loft
#
# Revision 1.3  1996/05/01  06:57:46  pinnacle
# Replaced: src/unfold/VLunwrapFk3.I for:  by rchennup for loft
#
# Revision 1.2  1996/01/31  09:10:00  pinnacle
# Replaced: src/unfold/VLunwrapFk3.I for:  by svkadamb for loft
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/


class implementation VLabstract;

#include <stdio.h>
#include <math.h>
#include "vlprototype.h"

#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "madef.h"
#include "gr.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "bserr.h"
#include "bstypes.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "EMSopt.h"
#include "grmacros.h"
#include "dpezmac.h"
#include "igr.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "nddef.h"
#include "asmacros.h"
#include "parametric.h"
#include "csdef.h"
#include "values.h"
#include "asmacros.h"
#include "bsicmpcvoff.h"
#include "vsmiscmacros.h"
#include "vlcntrline.h"
#include "vlmark.h"
#include "vlrolline.h"
#include "bsvalues.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vlglinedef.h"
#include "vlstructure.h"
#include "expmacros.h"
#include "expression.h"
#include "vsplatedef.h"
#include "griomacros.h"
#include "vlgrmacros.h"
#include "vlgrdef.h"
#include "vsgeommacros.h"
#include "vsstfnrdef.h"
#include "grdpbmacros.h"
#include "vlquerydef.h"
#include "vsbmaxisdef.h"
#include "vltemplate.h"
#include "vlunfold.h"
#include "exmacros.h"
#include "exproto.h"
#include "DIprims.h"
#include "vlforkmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vlstifftpl.h"
#include "vluserkey.h"
#include "vldbgmacros.h"

from    GRbcsubbc       import	EMcurve_by_poles;
from    ACrg_collect    import	AClist_attribute;
from    VLmrkLine       import	WhichSide, VLplace_mark;
from    VLjunction      import  VLreturn_graphic;
from    VLrolLine	import	VLplaceRollLine;

extern GRclassid	OPP_ACpretend_class_id;
extern GRclassid        OPP_VSplate_class_id;
extern GRclassid        OPP_VSbeam_class_id;
extern GRclassid        OPP_VLctrLine_class_id;
extern GRclassid        OPP_VLmrkLine_class_id;
extern GRclassid        OPP_VLrolLine_class_id;
extern GRclassid        OPP_VLbutLine_class_id;
extern GRclassid        OPP_VLwatLine_class_id;
extern GRclassid        OPP_VLseaLine_class_id;
extern GRclassid        OPP_VLtrace_class_id;

extern 			BSchtptstsf();
extern 			BSchtptstso();
extern 			BSsfarrevn();
extern 			BSkts_f_fit();
extern 			BSkts_f_app();
extern 			BSrev_cv();
extern			GRdpb_get();
extern			GRdpb_put();
extern	IGRdouble	BSdistptpt();
extern	IGRboolean	BScrossp();
extern	IGRdouble	BSdotp();
extern	IGRdouble	BSlenvec();
extern  IGRboolean	BSnorvec();
extern  void		BSchtptstcv();
extern	void		BSalloccv(), BSallocsf();
extern	IGRboolean	BSfreecv(), BSfreesf();
extern  IGRchar		*memcpy();
extern  void		BSsfeval();
extern			GRdisplay_object();
extern  IGRdouble	sqrt();
extern	IGRdouble	cos(),fabs();
extern			ASmake_source_from_env();
extern IGRint 		MAinvmx();
extern IGRint 		MAmulmx();
extern IGRboolean	MAtypemx();
extern IGRint 		BSsfevaln();
extern 			VLbrowseFctInTree();
extern 			VLfilterClass();
extern  int             VLgetMacrosAtStep();
extern  void            FAevPtSfFaDr();
extern  long            VLcheckStiffOnPlate();
extern struct GRid      NULL_GRID;

/*===========================================================================*
  This function retrieve the ND_CHILDREN objects attach on a surface.
    To use this function you need to make a first call to malloc the size
    of the Crvs buffer with opt = 0, then the caller malloc the space  all this function a second time to get the children. In fact
    the children are suppose to be in 2D space so we construct their
    representation in 3D space.

 23/october/92 JLL creation date 
 *===========================================================================*/
 
IGRlong VLgetCrvsConToSrf( dev, plate, cst, opt, contour_index, numChild,
                           numCrvs, Crvs, NumOldCrvs, OldCrvs, sts )
struct 	mise_a_plat	*dev;  /*I: unwrapping structure */
struct  GRobj_env       *plate;/*I: plate */
struct 	GRvg_construct	*cst;  /*I: construction list */
	IGRint		opt;   /*I: option : 0-->return just number of child 
                                             1-->return projected lines
                                             2-->return just waterLines
                                             which are received in Crvs
                               */
	IGRint		*contour_index;/*O: index when we will put
                                            the projection of the contour
					    edge of the plate */
	IGRint		*numChild;     /*O: if opt==0 numChild will contain
					    the number of children to allocate
				            if opt==1 numChild will contain
					    the index when we will put
					    the edge to be cuted */

        IGRint          *numCrvs;      /*IO: input : number of waterlines to
                                                     project.
                                             output : number ofprojected 
                                                      lines */

struct	GRobj_env	*Crvs;         /*IO: 
                                             input : contains waterlines to
                                                     project.
                                             output : projected lines */
	IGRint		NumOldCrvs;
	struct GRid     *OldCrvs;
	IGRlong		*sts;        

{
struct  GRobj_env	tmp;
	int		j,i, k,nb=0;
        int		ii,msg;
        int		side,which_side;
        long		status;
struct  GRobj_env	*vect_id = NULL;
	IGRlong		stat,loc_msg = MSSUCC;
        GRclassid	cid;
IGRint			nbline,nb_obj,nb_mac,nb_mark, dim = 4;
struct GRid             *Buffer;
struct GRobj_env	obj[VLRolNumFeet];
char			*names[12];
struct GRobj_env	GObj, gr_junction;
OMuword                 acpretend_cl,TEMP_cl;
int			top,bot,cur_line;
char			word[20],*name_line;
struct ACrg_coll 	ACrg[10];
int			nb_att=0;
struct GRobj_env	tmp_obj;
IGRuchar                style;
int                     UnwLnsOptions[UNFOLD_NB_OPTLINE];
VLquLine                Query[IDX_SC_SIZE];
IGRdouble               RangTol,ChtTol;
struct GRobj_env        *buf=NULL;
IGRchar         	MarkName [50],         // name of the mark placed
			loc_path[DI_PATH_MAX];
enum    GRdpmode        dpmode=GRbd;            // mode for placed mark
struct  GRsymbology     loc_symb;

  SetProc( VLgetCrvsConToSrf ) ;        Begin

  *sts = MSFAIL;
  nb_mark = 0;

  *numChild = 0;
  VLdecode(dev->WantedLinesCode,UNFOLD_NB_OPTLINE, UnwLnsOptions);
  if ( vs$is_ancestry_valid( object   = &plate->obj_id,
                              classid = OPP_VSplate_class_id ) == FALSE )
  goto get_lines;

  if( UnwLnsOptions[UNFOLD_ATT_IDX_MARK] )
  {
       BSxtractpar ( &loc_msg, BSTOLCHRDHT, &ChtTol);
       RangTol = 5 * ChtTol;

       VLqLineStfTpl (Query);
       for ( i=0; i<IDX_SC_SIZE; i++)  Query[i].query = 0;
       Query[IDX_SC_MACR].query = 1;

       status = VLquery1 ( &loc_msg, plate, cst->env_info, OPP_VSbeam_class_id,
                           VLcheckStiffOnPlate, &nb_mac, &buf );
       if (!(status&loc_msg&1)) goto wrapup;

       nb_mark = 0;
       for( i=0; i<nb_mac; ++i )
       {
          IGRint           numObjects=0;
	  struct GRid	   stiff_obj;
          struct GRobj_env *list_obj=NULL, templates[2];

          VLbrowseFctInTree( &buf[i], VL_Q_TOP_SOURCE, NULL, VL_Q_DOWN_DIRECT,
                             VLgetMacrosAtStep, &numObjects, &list_obj );
          VLfilterDef(numObjects,list_obj,&numObjects,"Mark");

          for( ii=0; ii<numObjects; ++ii ) 
	  {
	    status = om$send(  msg     = message ACcpx.ACfind_exp_temp_obj(
						&msg, 1, &stiff_obj ),
				senderid = NULL_OBJID,
				targetid = list_obj[ii].obj_id.objid,
				targetos = list_obj[ii].obj_id.osnum  );

	    if( stiff_obj.objid == plate->obj_id.objid &&
		stiff_obj.osnum == plate->obj_id.osnum    ) break;
          }
	  
	  if( numObjects && ii<numObjects ) continue;

	  templates[0] = *plate;
	  templates[1] = buf[i];
	  buf[nb_mark].obj_id.osnum = cst->env_info->md_id.osnum;
	  buf[nb_mark].mod_env = *cst->env_info;

          status = om$construct(classid    =  OPP_VLmrkLine_class_id,
                                osnum      =  buf[nb_mark].obj_id.osnum,
                                p_objid    =  &buf[nb_mark].obj_id.objid,
                                msg        =  message VLmrkLine.VLplace_mark( 
						 &loc_msg ,
                                                 VS_K_stOnBotOfPlate,
                                                 VS_K_baOnBotOfPlate,
                                                 2,
                                                 templates    ,
                                                 cst->env_info  ) );
          if (!(status&loc_msg&1)) continue;

	  loc_path[0] = '\0';
          status = VDSget_dir_and_symb ( &loc_msg, &buf[nb_mark].obj_id,
	   MARK_KEY, NULL, loc_path, &loc_symb.level, &loc_symb.display_attr );
          if (!(status&loc_msg&1)) goto wrapup;

	  VLoccNaming1 ( loc_path, VLMarkName, MarkName, &loc_msg);
          if (!(status&loc_msg&1)) goto wrapup;

          status =     VLsetSymb_Name_Disp(
                                     &stat,
                                     MarkName,
                                     MARK_KEY,
                                     &templates[0].obj_id,
                                     &buf[nb_mark].obj_id,
                                     &dpmode,
                                     &buf[nb_mark].mod_env  );
	  ++nb_mark;
	  _FREE( list_obj );
       }
  }

  if( UnwLnsOptions[UNFOLD_ATT_IDX_ROL] )
  {
      IGRint           numObjects=0;
      IGRvector        ship_axis;
      struct GRobj_env roll_line, *list_obj=NULL;

      VLbrowseFctInTree( plate, VL_Q_TOP_SOURCE, NULL, VL_Q_DOWN_DIRECT,
                         VLgetMacrosAtStep, &numObjects, &list_obj );
      VLfilterDef(numObjects,list_obj,&numObjects,"RolLn");

      if( !numObjects )
      {
	struct GRobj_env       surfObj;
 	struct IGRbsp_surface  *bspSf;         // pointer to Bspline surface
 	struct GRparms         param;          // projection parameters
 	IGRpoint               ptI,ptTmp ;     // projection & calculation points
 	BSrc                   bsrc;           // Maths return code
 	IGRint                 numNormals;     // number of normals to surface
 	IGRvector              normalI[1],     // unit normal
       	                       direct1,
                               direct2;        // possible directions
 	IGRdouble              curvature1,     // principal curvature in u
                               curvature2,     // principal curvature in v
                               uI,vI;          // u and v parameters 
					       // ( normally 0.5 )
	IGRboolean	       roll_direction;

        status = om$send( msg = message NDmacro.ACreturn_foot(
                                        &loc_msg,
                                        VS_K_plBotSfPath,
                                        &surfObj.obj_id,
                                        &surfObj.mod_env.md_env.matrix_type,
                                        surfObj.mod_env.md_env.matrix ),
                   	senderid = NULL_OBJID,
                   	targetid = plate->obj_id.objid,
                   	targetos = plate->obj_id.osnum  ) ;
        if (!(status&loc_msg&1)) goto wrapup;
	surfObj.mod_env = plate->mod_env;

        status=om$send ( msg = message GRvg.GRgenabsg(
					&loc_msg,
                                        &surfObj.mod_env.md_env.matrix_type,
                                        surfObj.mod_env.md_env.matrix,
                                        (IGRchar **) &bspSf ),
                   	senderid = NULL_OBJID,
         		targetid = surfObj.obj_id.objid,
         		targetos = surfObj.obj_id.osnum);
        if (!(status&loc_msg&1)) goto wrapup;

  	// get the unit normal
 	BSsfevaln( bspSf, 0.5, 0.5, 1, &numNormals, ptI, normalI, &bsrc);
        if (bsrc!=BSSUCC) { printf("BSsfevaln : FAIL \n"); goto wrapup; }

  	// get the curvatures

 	uI = 0.5; 	vI = 0.5;
 	BSsfarrevmc( bspSf, 1, &uI, 1, &vI, FALSE, FALSE, TRUE, FALSE, TRUE,
                     FALSE, ptI, NULL,NULL,&curvature1,&curvature2,NULL,
		     direct1, direct2, NULL, &bsrc);
        if (bsrc!=BSSUCC) { printf("BSsfarrevmc : FAIL \n"); goto wrapup; }

	if ( fabs(curvature1)<fabs(curvature2) ) { v_add(ptI,direct2,ptTmp); }
        else					 { v_add(ptI,direct1,ptTmp); }

  	status = om$send (msg = message GRgraphics.GRptproject (
				&loc_msg,
                                &surfObj.mod_env.md_env.matrix_type,
                                surfObj.mod_env.md_env.matrix,
                                ptTmp,
                                ptI,
                                &param),
                   	senderid = NULL_OBJID,
        		targetid = surfObj.obj_id.objid,
        		targetos = surfObj.obj_id.osnum);
        if (!(status&loc_msg&1)) goto wrapup;

 	if (fabs(param.u-uI)>=fabs(param.v-vI)) roll_direction=FALSE;
 	else   					roll_direction=TRUE;

        ship_axis[0]=1.0;
        ship_axis[1]=0.0;
        ship_axis[2]=0.0;
        roll_line.obj_id.osnum = cst->env_info->md_id.osnum;
	roll_line.mod_env = *cst->env_info;
        status = om$construct( classid    =  OPP_VLrolLine_class_id,
                               osnum      =  roll_line.obj_id.osnum,
                               p_objid    =  &roll_line.obj_id.objid,
                               msg        =  message VLrolLine.VLplaceRollLine(
						&loc_msg ,
                                                VS_K_baOnBotOfPlate,
						1,
						roll_direction,
                                                ship_axis,
                                                1,
						plate,
                                                cst->env_info,
						NULL,
						NULL  ) );
        if (!(status&loc_msg&1)) goto wrapup;

	loc_path[0] = '\0';
        status = VDSget_dir_and_symb ( &loc_msg, &roll_line.obj_id,
	   ROLL_KEY, NULL, loc_path, &loc_symb.level, &loc_symb.display_attr );
      	if (!(status&loc_msg&1)) goto wrapup;

  	VLoccNaming1 ( loc_path, VLMacroRolLn, MarkName, &loc_msg);
        if (!(status&loc_msg&1)) goto wrapup;

        status =     VLsetSymb_Name_Disp(
                                     &stat,
                                     MarkName,
                                     ROLL_KEY,
                                     &plate->obj_id,
                                     &roll_line.obj_id,
                                     &dpmode,
                                     &roll_line.mod_env  );
	_FREE( list_obj );
      }
  }

get_lines:
  if( opt == 0 ){
     status = VLget_lines(dev, plate, opt, cst->env_info, numChild, &vect_id);
     if( NumOldCrvs ) *numChild += NumOldCrvs;
     if( nb_mark ) *numChild += nb_mark;
     if (!(status&1)) {goto wrapup;}
     *sts = MSSUCC;
     goto wrapup; 
   }

  *contour_index = 0;
  nbline = *numCrvs;
  *numCrvs = 0;

  if (opt != 2) {
    status = VLget_lines(dev, plate, opt, cst->env_info, &nb, &vect_id);
    if (!(status&1)) {goto wrapup;}
  }

  if (UnwLnsOptions[UNFOLD_ATT_IDX_WATER] && dev->AllWaterLines) {
     for (i=0;i< nbline;i++)
     {
       for (k=0;k<nb;k++)
       {
         if (Crvs[i].obj_id.objid == vect_id[k].obj_id.objid) {
           Crvs[i].obj_id.objid = NULL_OBJID;
           break;
         }
       }
     }
     for (i=0; i<nbline;i++) 
     {
       if (Crvs[i].obj_id.objid == NULL_OBJID) continue;
       status = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_msg,
                                          MAN_GR_FEET,
                                          &obj[0].obj_id,
                                          &obj[0].mod_env.md_env.matrix_type,
                                          obj[0].mod_env.md_env.matrix),
                                targetid = Crvs[i].obj_id.objid,
                                targetos = Crvs[i].obj_id.osnum,
                                senderid = NULL_OBJID ) ;
       if (!(status & loc_msg &1)) {
          continue;
       }
       if (Crvs[i].mod_env.md_env.matrix_type != MAIDMX) {
         MAmulmx(&loc_msg,&dim,&dim,&dim,Crvs[i].mod_env.md_env.matrix,
                 obj[0].mod_env.md_env.matrix,obj[0].mod_env.md_env.matrix);
         MAtypemx( &loc_msg, obj[0].mod_env.md_env.matrix,
                   &obj[0].mod_env.md_env.matrix_type);
       }
       obj[0].mod_env.md_id.osnum = obj[0].obj_id.osnum;
       strcpy(ACrg[0].name,"name_of_line");
       ACrg[0].desc.type = AC_ATTRIB_TEXT;
       if (!(VLgetName(&(Crvs[i].obj_id),
                         ACrg[0].desc.value.att_txt)))
       strcpy(ACrg[0].desc.value.att_txt,
              "No Named Water Line");
       ii = dev->developpable; 
       dev->developpable = 0; /* for this water lines, we dont want to do
                                 a copy in the VLprojectParLine function
                                 because this lines are not limited
                                 by the plate area */
       status = VLprojectParLine(dev,1,obj,ACrg,1,cst,numCrvs,Crvs);
       if (!(status&1)) continue; 
       dev->developpable = ii;
     }
   }

  if (opt != 2) {
  /* find if "dev->surf_id" is the plate's Base or Bottom face */

    if (dev->side_of_plate == MAX_MARK) {
      top = bot =0;
      for (i=0; i<nb; i++)
      {
        om$get_classid(osnum = vect_id[i].obj_id.osnum,
                       objid = vect_id[i].obj_id.objid,
                       p_classid = &cid);
        if( om$is_ancestry_valid( superclassid = OPP_VLmrkLine_class_id,
                                subclassid   = cid ) == OM_S_SUCCESS) {
          status = om$send( msg  = message VLmrkLine.WhichSide (&which_side),
                                    targetid = vect_id[i].obj_id.objid,
                                  targetos = vect_id[i].obj_id.osnum,
                                  senderid = NULL_OBJID ) ;
          if (!(status&1)) goto wrapup;
          if (which_side == VS_K_stOnTopOfPlate) top++;
          else bot++;
        }
       }
      if (top > bot) side = VS_K_stOnTopOfPlate;
      else side = VS_K_stOnBotOfPlate;
    }
    else if (dev->side_of_plate == OFFSET_SIDE) side = VS_K_stOnTopOfPlate;
         else side = VS_K_stOnBotOfPlate;

  for (i=0; i<nb; i++)
  {
    nb_att = 0;
    om$get_classid(osnum = vect_id[i].obj_id.osnum,
                   objid = vect_id[i].obj_id.objid,
                   p_classid = &cid);
    if( om$is_ancestry_valid( superclassid = OPP_VLctrLine_class_id,
                            subclassid   = cid ) == OM_S_SUCCESS) {
      if (!UnwLnsOptions[UNFOLD_ATT_IDX_CTRL]) continue;
      status = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_msg,
                                          NAM_CL_CV,
                                          &obj[0].obj_id,
                                          &obj[0].mod_env.md_env.matrix_type,
                                          obj[0].mod_env.md_env.matrix),
                         targetid = vect_id[i].obj_id.objid,
                         targetos = vect_id[i].obj_id.osnum,
                         senderid = NULL_OBJID ) ;
       if (!(status & loc_msg &1)) {
         continue;
       }
       obj[0].mod_env.md_id.osnum = obj[0].obj_id.osnum;
       nb_obj = 1;
      strcpy(ACrg[nb_att].name,"name_of_line");
      ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
      if (!(VLgetName(&(vect_id[i].obj_id),ACrg[nb_att].desc.value.att_txt)))
        strcpy(ACrg[nb_att].desc.value.att_txt,"No Named Control Line");
      nb_att++;
     }
     else {
       if( om$is_ancestry_valid( superclassid = OPP_VLrolLine_class_id,
                            subclassid   = cid ) == OM_S_SUCCESS) {
         if (!UnwLnsOptions[UNFOLD_ATT_IDX_ROL]) continue;
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
           status = om$send( msg      = message NDmacro.ACreturn_foot(
                                        &loc_msg,
                                        name_line,
                                        &obj[nb_obj].obj_id,
                                        &obj[nb_obj].mod_env.md_env.matrix_type,
                                        obj[nb_obj].mod_env.md_env.matrix),
                            targetid = vect_id[i].obj_id.objid,
                            targetos = vect_id[i].obj_id.osnum,
                            senderid = NULL_OBJID ) ;
            obj[nb_obj].mod_env.md_id.osnum = obj[nb_obj].obj_id.osnum;
            if ((status&loc_msg&1)) nb_obj++;
         } while ((status&loc_msg&1)); 
         if (nb_obj == 0) continue;
         strcpy(ACrg[nb_att].name,"name_of_line");
         ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
         if (!(VLgetName(&(vect_id[i].obj_id),ACrg[nb_att].desc.value.att_txt)))
           strcpy(ACrg[nb_att].desc.value.att_txt,"No Named Roll Line");
         nb_att++;
       }
       else {
         if( om$is_ancestry_valid( superclassid = OPP_VLmrkLine_class_id,
                            subclassid   = cid ) == OM_S_SUCCESS) {
         if (!UnwLnsOptions[UNFOLD_ATT_IDX_MARK]) continue;
         status = om$send( msg      = message VLmrkLine.WhichSide (&which_side),
                              targetid = vect_id[i].obj_id.objid,
                              targetos = vect_id[i].obj_id.osnum,
                              senderid = NULL_OBJID ) ;
         if (!(status&1)) goto wrapup;
         if (which_side != side && !UnwLnsOptions[UNFOLD_ATT_IDX_FAR] ) continue;
         status = om$send( msg      = message ACcpx.ACfind_temp_obj(
                                                     &msg,
                                                      VLMrkPlateName,
                                                     &tmp.obj_id),
                              targetid = vect_id[i].obj_id.objid,
                              targetos = vect_id[i].obj_id.osnum,
                              senderid = NULL_OBJID ) ;
         if (!((status)&msg&1)) {
           goto wrapup; 
         }
         om$get_classid(  classname = "ACpretend",  p_classid = &acpretend_cl);
         om$get_classid(osnum      = tmp.obj_id.osnum,
                        objid      = tmp.obj_id.objid,
                        p_classid  = &TEMP_cl) ;
         if ( om$is_ancestry_valid( superclassid  = acpretend_cl,
                                subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {
           status = om$send( msg      = message NDmacro.ACreturn_foot(
                                        &loc_msg ,
                                        "",
                                        &tmp_obj.obj_id,
                                        &tmp_obj.mod_env.md_env.matrix_type,
                                        tmp_obj.mod_env.md_env.matrix ),
                 senderid = NULL_OBJID,
                 targetid = tmp.obj_id.objid,
                 targetos = tmp.obj_id.osnum );
            if (!(status&loc_msg&1)) goto wrapup;
            tmp = tmp_obj;
         }
         if (tmp.obj_id.objid != plate->obj_id.objid || 
             tmp.obj_id.osnum != plate->obj_id.osnum) {
           continue;
         }
         names[0] =  VLFirstMrkName; names[1] =  VLSecondMrkName;
         names[2] =  VLThirdMrkName; names[3] =  VLFourthMrkName;
         names[4] =  VLFifthMrkName; names[5] =  VLSixthMrkName;
         names[6] =  VLSeventhMrkName; names[7] =  VLEighthMrkName;
         names[8] =  VLNinethMrkName; names[9] =  VLTenthMrkName;
                       
         nb_obj = 0;
         do {
           stat = om$send( msg      = message NDmacro.ACreturn_foot(
                                       &loc_msg,
                                       names[nb_obj],
                                       &obj[nb_obj].obj_id,
                                       &obj[nb_obj].mod_env.md_env.matrix_type,
                                       obj[nb_obj].mod_env.md_env.matrix),
                              targetid = vect_id[i].obj_id.objid,
                              targetos = vect_id[i].obj_id.osnum,
                              senderid = NULL_OBJID ) ;
            obj[nb_obj].mod_env.md_id.osnum = obj[nb_obj].obj_id.osnum;
            if ((stat&loc_msg&1)) nb_obj++;
          } while ((stat&loc_msg&1));
            if (nb_obj == 0) continue;

            strcpy(ACrg[nb_att].name,"plate_or_beam");
            ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
             status= om$send ( msg =  message NDnode.NDget_objects( 
                        ND_IN_BUF |ND_ROOT,
                        (struct GRid *)NULL,
                        0,
                        &Buffer,
                        0,
                        OM_K_MAXINT,
                        &j),
                senderid        = NULL_OBJID,
                targetid        = vect_id[i].obj_id.objid,
                targetos        = vect_id[i].obj_id.osnum);
             if (status&1 && j>=2) {
              om$get_classid(osnum = Buffer[2].osnum,
                             objid = Buffer[2].objid,
                             p_classid = &cid);
             
              if (om$is_ancestry_valid(
                    subclassid     = cid,
                    superclassid = OPP_ACpretend_class_id )  == OM_S_SUCCESS) {
                GObj.obj_id.objid = NULL_OBJID;
                status = om$send( msg  = message NDnode.ASreturn_go(
                                      &GObj.obj_id,
                                      &GObj.mod_env.md_env.matrix_type,
                                      GObj.mod_env.md_env.matrix ),
                        senderid        = NULL_OBJID,
                        targetid = Buffer[2].objid,
                        targetos = Buffer[2].osnum );
                if( !( 1 & (status) ) ) GObj.obj_id=Buffer[2];
                om$get_classid(osnum = GObj.obj_id.osnum,
                               objid = GObj.obj_id.objid,
                               p_classid = &cid);
              }
              else GObj.obj_id = Buffer[2];
              if (om$is_ancestry_valid(subclassid     = cid,
                      superclassid = OPP_VSplate_class_id ) == OM_S_SUCCESS ||
                  om$is_ancestry_valid(subclassid     = cid,
                           superclassid = OPP_VSbeam_class_id )== OM_S_SUCCESS)
              {
                if (om$is_ancestry_valid(subclassid     = cid,
                          superclassid = OPP_VSplate_class_id )== OM_S_SUCCESS)
                  strcpy(ACrg[nb_att].desc.value.att_txt,"PLATE :");
                else strcpy(ACrg[nb_att].desc.value.att_txt,"BEAM :"); 
                if (!(VLgetName(&(GObj.obj_id), word)))
                  strcpy(word,"No Named");
                strcat(ACrg[nb_att].desc.value.att_txt, word);
                nb_att++;
              }
              strcpy(ACrg[nb_att].name,"name_of_Plate_or_Beam");
              ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
              ACrg[nb_att].desc.value.att_txt[0] = '\0';
              status = VLgetWholeName(&(GObj.obj_id),"unfold_setup",'%',
                                   ATTR_NAME,ACrg[nb_att].desc.value.att_txt);
              if (!((status)&1)) ACrg[nb_att].desc.value.att_txt[0] = '\0';
              if (strlen(ACrg[nb_att].desc.value.att_txt) + strlen(word) + 1
                   < ATTR_NAME)
                strcat(ACrg[nb_att].desc.value.att_txt, word);
              nb_att++;
            }
         }
         else {
           if(
               (om$is_ancestry_valid( superclassid = OPP_VLbutLine_class_id,
                                   subclassid   = cid ) == OM_S_SUCCESS)  ||
               (om$is_ancestry_valid( superclassid = OPP_VLseaLine_class_id,
                                   subclassid   = cid ) == OM_S_SUCCESS)
             )
            {
             if (!UnwLnsOptions[UNFOLD_ATT_IDX_BUTT] &&
                 (om$is_ancestry_valid( superclassid = OPP_VLbutLine_class_id,
                                   subclassid   = cid ) == OM_S_SUCCESS))
                continue;
             if (!UnwLnsOptions[UNFOLD_ATT_IDX_SEAM] &&
                 (om$is_ancestry_valid( superclassid = OPP_VLseaLine_class_id,
                                   subclassid   = cid ) == OM_S_SUCCESS))
                continue;
             status = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_msg,
                                          MAN_GR_FEET,
                                          &obj[0].obj_id,
                                          &obj[0].mod_env.md_env.matrix_type,
                                          obj[0].mod_env.md_env.matrix),
                                targetid = vect_id[i].obj_id.objid,
                                targetos = vect_id[i].obj_id.osnum,
                                senderid = NULL_OBJID ) ;
              if (!(status & loc_msg &1)) {
                continue;
              }
              obj[0].mod_env.md_id.osnum = obj[0].obj_id.osnum;
              nb_obj = 1;
              if (*numChild == 0) *numChild = *numCrvs;
              strcpy(ACrg[nb_att].name,"name_of_line");
              ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
              if (!(VLgetName(&(vect_id[i].obj_id),
                              ACrg[nb_att].desc.value.att_txt))) {
               if (om$is_ancestry_valid( superclassid = OPP_VLbutLine_class_id,
                                   subclassid   = cid ) == OM_S_SUCCESS)
                strcpy(ACrg[nb_att].desc.value.att_txt,"No Named Butt Line");
                else 
                strcpy(ACrg[nb_att].desc.value.att_txt,"No Named Seam Line");
             }
             nb_att++;
            }
            else {
              if( om$is_ancestry_valid( superclassid = OPP_VLtrace_class_id,
                                      subclassid   = cid ) == OM_S_SUCCESS) {
              if (!UnwLnsOptions[UNFOLD_ATT_IDX_TRACE]) continue;
                status = om$send( msg      = message NDmacro.ACreturn_foot(
                                            &loc_msg,
                                            MAN_GR_FEET,
                                            &obj[0].obj_id,
                                            &obj[0].mod_env.md_env.matrix_type,
                                            obj[0].mod_env.md_env.matrix),
                                   targetid = vect_id[i].obj_id.objid,
                                   targetos = vect_id[i].obj_id.osnum,
                                   senderid = NULL_OBJID ) ;
                 if (!(status & loc_msg &1)) {
                   continue;
                 }
                 obj[0].mod_env.md_id.osnum = obj[0].obj_id.osnum;
                 nb_obj = 1;
                 strcpy(ACrg[nb_att].name,"name_of_line");
                 ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
                 if (!(VLgetName(&(vect_id[i].obj_id),
                                   ACrg[nb_att].desc.value.att_txt)))
                  strcpy(ACrg[nb_att].desc.value.att_txt,"No Named Trace Line");
                 nb_att++;
               }
               else {
                 if(om$is_ancestry_valid(superclassid = OPP_VLwatLine_class_id,
                                      subclassid   = cid ) == OM_S_SUCCESS) {
                   if (!UnwLnsOptions[UNFOLD_ATT_IDX_WATER]) continue;
                   status = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_msg,
                                          MAN_GR_FEET,
                                          &obj[0].obj_id,
                                          &obj[0].mod_env.md_env.matrix_type,
                                          obj[0].mod_env.md_env.matrix),
                                targetid = vect_id[i].obj_id.objid,
                                targetos = vect_id[i].obj_id.osnum,
                                senderid = NULL_OBJID ) ;
                   if (!(status & loc_msg &1)) {
                     continue;
                   }
                   obj[0].mod_env.md_id.osnum = obj[0].obj_id.osnum;
                   nb_obj = 1;
                   strcpy(ACrg[nb_att].name,"name_of_line");
                   ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
                   if (!(VLgetName(&(vect_id[i].obj_id),
                                     ACrg[nb_att].desc.value.att_txt)))
                   strcpy(ACrg[nb_att].desc.value.att_txt,
                          "No Named Water Line");
                   nb_att++;
                 }
                 else{
                   status = om$send( msg  = message NDnode.ASreturn_go(
                                      &obj[0].obj_id,
                                      &obj[0].mod_env.md_env.matrix_type,
                                      obj[0].mod_env.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = vect_id[i].obj_id.objid,
                        targetos = vect_id[i].obj_id.osnum );
		   if( !(status&1) ) continue;

                   obj[0].mod_env.md_id.osnum = obj[0].obj_id.osnum;
                   nb_obj = 1;
                   strcpy(ACrg[nb_att].name,"name_of_line");
                   ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
                   strcpy(ACrg[nb_att].desc.value.att_txt,"Marked Plate");
                   nb_att++;
		}
              }
            }
         }
       }
     }
     for (ii=0;ii<nb_obj;ii++)
     {
       if (vect_id[i].mod_env.md_env.matrix_type != MAIDMX) {
         MAmulmx(&loc_msg,&dim,&dim,&dim,vect_id[i].mod_env.md_env.matrix,
                 obj[ii].mod_env.md_env.matrix,obj[ii].mod_env.md_env.matrix);
         MAtypemx( &loc_msg, obj[ii].mod_env.md_env.matrix,
                   &obj[ii].mod_env.md_env.matrix_type);
       }
     }
     status = VLprojectParLine(dev,nb_obj,obj,ACrg,nb_att,cst,numCrvs,Crvs);
     if (!(status&1)) continue; 
     if (which_side != side && UnwLnsOptions[UNFOLD_ATT_IDX_FAR] )
     {
       for(ii=(*numCrvs-1); ii>(*numCrvs-nb_obj-1); --ii )
       {
          style = 2;
          status = om$send(  msg      = message VLjunction.VLreturn_graphic(
                                               &loc_msg,
                                               NULL,
                                               &gr_junction ),
                       senderid = NULL_OBJID,
                       targetid = Crvs[ii].obj_id.objid,
                       targetos = Crvs[ii].obj_id.osnum  );

          status = om$send(  msg      = message GRvg.GRchgstyle(
                                              &loc_msg,
                                              (IGRuchar *)&style  ),
                                 senderid = NULL_OBJID,
                                 targetid = gr_junction.obj_id.objid,
                                 targetos = gr_junction.obj_id.osnum );
       }
     }
   }

   for( i=0; i<NumOldCrvs; ++i )
   {
       style=1;
       obj[0].obj_id  = OldCrvs[i];
       obj[0].mod_env = *cst->env_info;
       status = om$send(  msg      = message GRvg.GRchgstyle(
                                             &loc_msg,
                                             (IGRuchar *)&style  ),
                                senderid = NULL_OBJID,
                                targetid = OldCrvs[i].objid,
                                targetos = OldCrvs[i].osnum );
       nb_obj = 1;
       nb_att = 0;
       strcpy(ACrg[nb_att].name,"name_of_line");
       ACrg[nb_att].desc.type = AC_ATTRIB_TEXT;
       sprintf(ACrg[nb_att].desc.value.att_txt,"Limit %d", i );
       nb_att++;

       status = VLprojectParLine(dev,nb_obj,obj,ACrg,nb_att,cst,numCrvs,Crvs);
       if (!(status&1)) continue;
   }
 }


   *contour_index = *numCrvs;
   if (*numChild == 0) *numChild = *contour_index;
   *sts = OM_S_SUCCESS;

   for( i=0; i<NumOldCrvs; ++i )
   {
      om$send(    msg      = message GRgraphics.GRdelete
                                        ( &stat, cst->env_info ),
                            senderid = NULL_OBJID,
                            targetid = OldCrvs[i].objid,
                            targetos = OldCrvs[i].osnum );
      OldCrvs[i].objid = NULL_OBJID;
   }

wrapup:
	End
	cst->geometry	= NULL;
        if (vect_id){free(vect_id);vect_id = NULL;}

	return(*sts); 
}

end implementation VLabstract;
