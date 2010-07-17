class implementation VLunwrap;

#include        "AS_status.h"
#include        "grmacros.h"
#include        "bsparameters.h"
#include        "DIdef.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
#include 	"bserr.h"
#include 	"bstypes.h"
#include        "vsplatedef.h"
#include        "asmacros.h"
#include        "ACrg_collect.h"
#include        "igr.h"
#include        "ACattrib.h"
#include        "nddef.h"
#include 	"cotxmacros.h"
#include 	"DItypedef.h"
#include 	"DIglob.h"
#include 	"DIprims.h"
#include 	"DImacros.h"
#include 	"griomacros.h"
#include        "vsmiscmacros.h"
#include        "EMSssprops.h"
#include        "vds.h"
#include        "vlmsg.h"
#include 	"EMSdpb.h"
#include 	"EMSdef.h"
#include 	"growner.h"
#include 	"grdpbdef.h"
#include 	"grdpb.h"
#include 	"grdpbmacros.h"
#include 	"igrdp.h"
#include        "vlstructure.h"
#include        "vlunfold.h"
#include        "vledgeattr.h"
#include        "vluserkey.h"
#include        "vldbgmacros.h"
#include        "vlquerydef.h"
#include 	"godef.h"

from EMSsfimpbnd import EMget_subbs;
from GRgencs import GRgetmatrix;
from ACrg_collect import AClist_attribute;
from ACrg_collect import ACset_list_attribute;
from ACrg_collect import ACadd_list_attribute;
from ACrg_collect import ACmod_list_attribute;
from ACpretend import ACpconnect;
from ci_macro import init;

extern  GRclassid 	OPP_ACpretend_class_id;
extern  GRclassid 	OPP_nci_macro_class_id;
extern  GRclassid 	OPP_EMSgenbs_class_id;
extern  GRclassid 	OPP_GR3dpoint_class_id;
extern  GRclassid 	OPP_ACrg_collect_class_id;
extern  GRclassid       OPP_VSimgFeature_class_id;
extern  GRclassid       OPP_VSplate_class_id;
extern  GRclassid       OPP_VLedge2Datt_class_id;

extern  int             VLgetMacrosAtStep();

/*========================================================================*/
method NDdelete( struct GRmd_env *md_env)
{
IGRlong		stat, OMstat;
struct	GRid	ASobj;
IGRint		i , numObjects; 
struct GRobj_env	mac;
struct GRobj_env *list_obj=NULL;

  /*c retrieve the refrential and send an undisplay , without checking
      that other elements are dependant to it*/

  OMstat = om$send( msg      = message  ACcpx.ACfind_exp_temp_obj(
							(int *)&stat,0,&ASobj),
 	      	    targetid = my_id);
	if(!(OMstat&stat&1)) goto wrapup;
  gr$display_object ( object_id = (struct GRid *)&ASobj,
	     	      mode      = GRbehe);

  mac.obj_id.objid = my_id;
  mac.obj_id.osnum = md_env->md_id.osnum;
  mac.mod_env = *md_env;
  VLbrowseFctInTree( &mac, VL_Q_TOP_SOURCE, NULL,
                     VL_Q_DOWN_DIRECT,
                     VLgetMacrosAtStep,
                     &numObjects, &list_obj );
  VLfilterDef(numObjects,list_obj,&numObjects,"edge2D_att");
  for (i=0;i<numObjects;i++)
  {
    gr$display_object ( object_id = &list_obj[i].obj_id,
	     	        mode      = GRbehe);
  }

wrapup:

  if( list_obj != NULL ) om$dealloc( ptr = list_obj );
  om$send( msg      = message ACncpx.NDdelete(md_env),
           mode = OM_e_wrt_message,
           targetid = my_id);

   return(1);
}
/*==========================================================================*
  This function compute length and width of the flattened plate and
  display them.
 *==========================================================================*/

CreCogText( toMat, Length, Width, TextID, suc )

	IGRdouble	*toMat;
	IGRdouble	Length;
	IGRdouble	Width;
struct  GRid		*TextID;
	IGRlong		*suc;

{

IGRchar			CR[3], txt[81];
IGRdouble		leng,COG[3];
IGRint			i,k,
			i_sts ,
			len,
			four;
IGRdouble		tmp_matrix[16];

	  if( Length > Width )	leng = Length / 20;
	  else			leng = Width / 20;

	  __DBGpr_dbl("leng =", leng );

	  for(i=0;i<3;i=i+1){
		k = 4*i;
		COG[i] = toMat[k+3] + leng * toMat[k] + leng * toMat[k+1];
	  }
        
	CR[0] = 27;
	CR[1] = 10;
	CR[2] = 0;

	/*c Approximate length & width */

	Length = Length * 100.0 + 5;		Width = Width * 100.0 + 5;
	Length = (IGRint) (Length / 10.0);	Width = (IGRint) (Width / 10.0);
	Length = Length / 10.0;			Width = Width / 10.0;

	sprintf ( txt, "%g%s%g", Length, CR, Width);
	len = strlen(txt);
	four = 4;
  	MAinvmx ( suc, &four, toMat, tmp_matrix);
	tmp_matrix[3] = tmp_matrix[7] = tmp_matrix[11] = 0.0;

	i_sts = co$place_text (       msg         = suc,
			      	      text_string = txt,
			      	      text_length = &len,
			      	      rot_matrix  = tmp_matrix,
			      	      origin      = COG,
			      	      flags       = 0,
			      	      buffer      = TextID );

	__CheckRC( i_sts, *suc, "co$place_text", wrapup );

        *suc = MSSUCC;
        return OM_S_SUCCESS;
wrapup:
        *suc = MSFAIL;
	TextID->objid = NULL_OBJID;
	return ( i_sts );
}

/*==========================================================================*
  This function displays the name of the plate. It avoids that the
  name falls in a hole.
 *==========================================================================*/
CrePlateText( RNG, dev,PlateID,MaxOff, cur_env, toMat, mat, trfMat, 
              Length, Width, TextID, suc )

struct GRid		RNG;
struct  mise_a_plat	*dev;
struct	GRid		PlateID;
double			MaxOff;
struct  GRmd_env	*cur_env;
	IGRdouble	*toMat;
	IGRdouble	*mat;
	IGRdouble	*trfMat;
	IGRdouble	Length;
	IGRdouble	Width;
struct	GRid		*TextID;
	IGRlong		*suc;

{
struct  EMparms 	EMParams;
struct	IGRbsp_curve 	*cv;
IGRdouble		COG[4],point[4];
IGRint			i, 
			i_sts ;
IGRint			len;
IGRint			four,one;
IGRdouble		tmp_matrix[16];
IGRchar			name[DI_PATH_MAX];
BSrc			bsrc = BSSUCC;
IGRchar         	text[DI_PATH_MAX];
long			stat;
double                  ptDr[3],vecDr[6];

	if (	toMat == NULL || 
		TextID== NULL ||
		suc   == NULL   ) { i_sts=OM_E_INVARG; goto wrapup; }

        i_sts = VLgetWholeName(&PlateID,"label_setup",'#',DI_PATH_MAX,text);
        if (!(i_sts&1)) text[0] = '\0';

	/*c Retrieve name of the plate */

	i_sts = om$send( msg	= message GRgraphics.GRgetname( suc,
								name ),
	       	       senderid = NULL_OBJID,
	       	       targetid = PlateID.objid,
	       	       targetos = PlateID.osnum ) ;

	if( !( i_sts & 1 & (*suc) ) ) {
		sprintf(name,"elem_%d_%d",PlateID.objid,PlateID.osnum);
	}
	else{
                i_sts = di$split ( pathname = name,
                                   name = name);

	}

        if (text[0] != '\0') strcat(text, name);
        else strcpy(text,name);
	len = strlen(text);
	__DBGpr_str("text =",text);

	four = 4; one = 1;

   // avois holes
    if (dev->developpable) {
      i_sts = VLfindBoxOnSurf(suc,dev,(IGRuint)3,mat,
                              MaxOff+(double)(len*100)+Length,
                              MaxOff+150.+Width,MaxOff+Length,MaxOff+Width,
                              point, NULL ) ;
    }
    else {

      i_sts = VLfindBoxOnSurf(suc,dev,(IGRuint)3,mat,
                              MaxOff+(double)(len*100)+Length,
                              MaxOff+150.+Width,MaxOff+Length,MaxOff+Width,
                              point, &EMParams ) ;
      if (!dev->tesselation_option)
        BSsfeval(dev->devsrf,EMParams.u,EMParams.v,0,point,&bsrc);
      else {
        BSsfevaln(dev->surface,EMParams.u,EMParams.v,1,&i,ptDr,vecDr,&bsrc);
        FAevPtSfFaDr((IGRshort) 3,dev->P,dev->devsrf,dev->def,
                     ptDr, vecDr, EMParams.u,EMParams.v, point,&bsrc);
      }
    }

        if (!(i_sts&(*suc)&1)|| bsrc != BSSUCC) {
          printf("Problems in VLfindBoxOnSurf 2\n");
	  COG[0] = 0.0;
	  COG[1] = 0.0;
	  COG[2] = 0.0;
          cv = NULL;
          i_sts = om$send ( msg      = message GRvg.GRgenabsg (
                                        suc,
                                        &(cur_env->md_env.matrix_type),
                                        cur_env->md_env.matrix,
                                        (IGRchar **)&cv ),
                         senderid = NULL_OBJID,
                         targetid = RNG.objid,
                         targetos = RNG.osnum );

          __CheckRC( i_sts, *suc, "GRvg.GRgenabsg", wrapup );
  
	  for(i=0;i<12;i=i+3){
		  COG[0] = COG[0] + cv->poles[i];
		  COG[1] = COG[1] + cv->poles[i+1];
		  COG[2] = COG[2] + cv->poles[i+2];
	  }
  
	  COG[0] = COG[0] / 4.0;
	  COG[1] = COG[1] / 4.0;
	  COG[2] = COG[2] / 4.0;
        }
        else {
          point[3] = 1;
          MAmulmx(&stat,&four,&four,&one,trfMat,point,COG);
        }
  	MAinvmx ( suc, &four, toMat, tmp_matrix);
	tmp_matrix[3] = tmp_matrix[7] = tmp_matrix[11] = 0.0;
	i_sts = co$place_text (       msg         = suc,
			      	      text_string = text,
			      	      text_length = &len,
			      	      rot_matrix  = tmp_matrix ,
			      	      origin      = COG,
			      	      flags       = 0,
			      	      buffer      = TextID );

	__CheckRC( i_sts, *suc, "co$place_text", wrapup );

        *suc = MSSUCC;
        return OM_S_SUCCESS;
wrapup:
        *suc = MSFAIL;
	TextID->objid = NULL_OBJID;
	return ( i_sts );
}

/*==========================================================================*
  This function computes the feet of the srf_unwrap macro.
 *==========================================================================*/
long constructUnwrap( macro_id,list,cur_env,dev,fcount,feet_list,EdgeList,
                     NumEdges, contour_index,symbology)
struct GRid		macro_id; /* I: the macro's id */
struct GRid             *list;    /* I: list of template */
struct GRmd_env		*cur_env; /* I: current environment */
struct  mise_a_plat	*dev;     /* O: struct to fill */
int			*fcount;  /* O: number of computed feet */
struct GRid		*feet_list;/*O: list of feet */
struct  EdgeMatch       **EdgeList;/*O: list of edge of the plate and the
                                        edge_att macro attached to these
                                        edges (if there is). */
int			*NumEdges; /*O: number of elements in EdgeList */
int			*contour_index;/* O : at this index we find feet
                                              which are the mapping on
 					      the unwrap of the contour
 					      edges of the plate */
                                              
struct  GRsymbology     *symbology;/* O : symbology */
{
long	msg,stat,status;
IGRdouble		ORG[3];
	IGRint		i, k, j;
	IGRint		index;
	IGRdouble	MaxOff,tmp;
	IGRdouble	Length, Width;
       	IGRdouble	toMat[16], fromMat[16];
	IGRdouble	RefMat[16];

struct  IGRpolyline     geom;
	IGRboolean	UnwrapSrfWanted;


        IGRdouble       x_expansion,y_expansion;
        IGRdouble       new_length,new_width;
        int             surf_type,dim;
        int             exp_type;
struct 	GRid	       	obj,cs,line[3];
struct 	ACrg_coll       ACrg;
	IGRchar		*vect_type;
IGRdouble		trfMat[16];
IGRshort		trfMatType;
double			BoxOrigin[4];
IGRdouble		mat[16];
double 			point[4],cs_point[4];
struct  EMparms 	EMParams;
BSrc 			bsrc;
IGRvector		XVec,YVec,ZVec;
IGRchar 		tar_path[DI_PATH_MAX],name[DI_PATH_MAX];
IGRchar                 all_name[DI_PATH_MAX];
OMuword                 img_cl, GoTemp_cl;
int			Cut_index=0;
struct ACrg_coll        list_att[UNFOLD_NB_OPT];
struct  GRvg_construct  cst;
struct GRobj_env	Go3DSrf;
double			vecDr[6];

  msg=MSFAIL;

  *contour_index = 0;
  VLinitDev(dev);
  x_expansion = y_expansion = exp_type = UnwrapSrfWanted = 0;
  *fcount = 0;

  for(i=0;i<UNFOLD_NB_FEET;i=i+1){ 
	feet_list[i].objid = NULL_OBJID;
        feet_list[i].osnum = cur_env->md_id.osnum;
  }
  om$get_classid ( classname = "VSimgFeature", p_classid = &img_cl );
  strcpy(ACrg.name,N_ATT_TYPE);
  ACrg.desc.type = AC_ATTRIB_TEXT;
  vect_type = ACrg.desc.value.att_txt;
  for (i=0; i< ATTR_TXT; i=i+1) vect_type[i] = 0377; 

// find attributes
  status = om$send(msg = message ACrg_collect.AClist_attribute
                                        (&stat,UNFOLD_NB_OPT,list_att,&k),
                       senderid = NULL_OBJID,
                       targetid = list[UNFOLD_IDX_BOX].objid,
                       targetos = list[UNFOLD_IDX_BOX].osnum);
  if (!(status&stat&1)) {
    goto wrapup;
  }
  if ((j=VLseekFields(list_att,k,UNFOLD_ATT_SRFWANTED)) != -1) {
    UnwrapSrfWanted = list_att[j].desc.value.att_exp;
  }
  if ((j=VLseekFields(list_att,k,UNFOLD_ATT_EXPTYPE)) != -1) {
    exp_type = list_att[j].desc.value.att_exp;
  }
  if ((j=VLseekFields(list_att,k,UNFOLD_ATT_SIDE)) != -1) {
    dev->side_of_plate = list_att[j].desc.value.att_exp;
  }
  if ((j=VLseekFields(list_att,k,UNFOLD_ATT_TESSELATION)) != -1) {
    dev->tesselation_option = list_att[j].desc.value.att_exp;
  }
  if ((j=VLseekFields(list_att,k,UNFOLD_ATT_LINES)) != -1) {
    dev->WantedLinesCode = (int) list_att[j].desc.value.att_exp;
  }

  if (exp_type) {
    if ((j=VLseekFields(list_att,k,UNFOLD_ATT_X_EXPANSION)) != -1) {
     x_expansion = list_att[j].desc.value.att_exp;
    }
    if ((j=VLseekFields(list_att,k,UNFOLD_ATT_Y_EXPANSION)) != -1) {
     y_expansion = list_att[j].desc.value.att_exp;
    }
  }
  if ((j=VLseekFields(list_att,k,UNFOLD_ATT_FIB_RATIO)) != -1) {
   dev->fib_ratio = list_att[j].desc.value.att_exp;
  }
  if ((j=VLseekFields(list_att,k,UNFOLD_ATT_WATONPLATE)) != -1) {
   dev->AllWaterLines  = list_att[j].desc.value.att_exp;
  }

  status = VLextractSurf(&list[UNFOLD_IDX_SURF],cur_env,dev,&Go3DSrf);
  if (!(status&1)) goto wrapup;

  /*c retrieve the geometry of the support suface */

  status  = VLgetGeometry(  &dev->surf_id, (IGRboolean) TRUE, NULL_OBJID,
                          (IGRchar ** )&dev->surface, &stat );

  if( ! (status&stat&1)) goto wrapup;

  /*c set up to fold as QUAD */

  dev->type         = 4;
  dev->developpable = 0;

  om$get_classid ( osnum     = Go3DSrf.obj_id.osnum,
                   objid     = Go3DSrf.obj_id.objid,
                   p_classid = &GoTemp_cl ) ;

  /* get cs matrix */
   cs = list[UNFOLD_IDX_CS];
   status = om$send(  msg = message GRgencs.GRgetmatrix( &stat, RefMat ),
                              senderid = NULL_OBJID,
                              targetid = cs.objid,
                              targetos = cs.osnum);
   if (!(status&stat&1)) goto wrapup;

  /*c set up the cst */

   VLinitCnst(&cst);

   /*
   *  evaluate points along normal according opt and the offset value
   */

  j = dev->tesselation_option;
  status  = VLgetPtsNorms( dev, dev->tesselation_option, 0. );
  if (!(status&1)) goto wrapup;
  if (dev->tesselation_option != j) {
    strcpy(list_att[0].name,UNFOLD_ATT_TESSELATION);
    list_att[0].desc.type = AC_ATTRIB_DOUBLE;
    list_att[0].desc.value.att_exp = dev->tesselation_option;
    status = om$send(msg = message ACrg_collect.ACmod_list_attribute
                                        (&stat,1,list_att),
                       senderid = NULL_OBJID,
                       targetid = list[UNFOLD_IDX_BOX].objid,
                       targetos = list[UNFOLD_IDX_BOX].osnum);
    if (!(status&stat&1)) {
      goto wrapup;
    }
  } 

  if (!dev->tesselation_option) {
	geom.num_points = 1;
	ORG[2] = ORG[1] = ORG[0] = 0;
	geom.points = &ORG[0];
  	cst.geometry = (char *)&geom;
        feet_list[UNFOLD_IDX_UVSRF].osnum = cur_env->md_id.osnum;
        status = om$construct( classid = OPP_GR3dpoint_class_id,
                               osnum   = feet_list[UNFOLD_IDX_UVSRF].osnum,
                               p_objid = &feet_list[UNFOLD_IDX_UVSRF].objid );
        if (!(status&1)) goto wrapup;
  	status = om$send(msg      = message GRgraphics.GRaltconstruct(&cst),
	      	       senderid = NULL_OBJID,
	      	       targetid = feet_list[UNFOLD_IDX_UVSRF].objid,
	  	       targetos = feet_list[UNFOLD_IDX_UVSRF].osnum );

	__CheckRC( status, *cst.msg, "GR3dpoint.GRaltconstruct", wrapup );
  }
  else feet_list[UNFOLD_IDX_UVSRF] = dev->uvSrfId;

  #ifdef DEBUG
{
struct	GRmd_env	VLmoduleInfo;
	IGRlong		NumberOfBytes,BytesReceived;
struct  GRobj_env	Srf2D;

	if( dev->developpable != 1 ){
		printf(" original surface is planar\n");
 		NumberOfBytes = sizeof( VLmoduleInfo );
 		gr$get_module_env(
        			        msg = &msg,
        	        		sizbuf = &NumberOfBytes,
                			buffer = &VLmoduleInfo,
                			nret = &BytesReceived	);
 		cst.env_info = &VLmoduleInfo;

   		VLcreOrd2Srf( dev->P, dev->Nb_u, dev->Nb_v, dev->Param_u, 
			      dev->Param_v, 2, &cst, (IGRboolean) TRUE, &Srf2D,
			      NULL, &stat);
 
  		cst.env_info = &MOD_ENV;
	}
}
  #endif

  /*
   * unwrap the facetted surface 
   */

  status  = VLmaplatNDevel (dev);
  __CheckRC( 1, status , "VLmaplatNDevel", wrapup );

  #ifdef DEBUG
	printf("dev->Nb_u = %d, dev->Nb_v = %d\n",dev->Nb_u,dev->Nb_v);
 	cst.env_info = &VLmoduleInfo;
	cst.geometry = (IGRchar *) dev->devsrf;
	Srf2D.obj_id.objid = NULL_OBJID;
	Srf2D.obj_id.osnum = VLmoduleInfo.md_id.osnum;
  	status = om$send(msg      = message EMSgenbs.GRconstruct(&cst),
	      	       senderid = NULL_OBJID,
	      	       targetid = Srf2D.obj_id.objid,
	  	       targetos = Srf2D.obj_id.osnum );
  	cst.env_info		= &MOD_ENV;
  #endif

   // find path and symbology for unwraped plates
    status = VDSget_dir_and_symb( &stat, &(Go3DSrf.obj_id), UNFOLD_KEY, NULL,
                               tar_path, &symbology->level,
                               &symbology->display_attr );
    if( ! (status&stat&1)){ goto wrapup; }

   // find name to give to the unwraped plate
    status = om$send(msg = message GRvg.GRgetname(&stat,name),
	      	   senderid = NULL_OBJID,
                   targetid = Go3DSrf.obj_id.objid,
                   targetos = Go3DSrf.obj_id.osnum);
    if (!(status&stat&1)) {
      strcpy(name,"Defined");
    }
    else {   // just name without path
      status = di$split ( pathname = name,
                          name = name);
    }
    sprintf( all_name,"%s:%s_u",tar_path, name );
    status = om$send ( msg = message GRvg.GRchgname
                                       ( &stat, cur_env, all_name ),
	      	        senderid = NULL_OBJID,
                        targetid = macro_id.objid,
                        targetos = macro_id.osnum );
  /*
   *  general function that retrieves all the edge_attr and all types of
   *  marking lines or traced curves on the plate and maps these curves
   *  on the unfold surface stored in the dev.devsrf structure
   */

  *fcount = 0;
  status = VLgetCutMarkLns(dev,&Go3DSrf,&cst,NumEdges,EdgeList,
                           &feet_list[UNFOLD_IDX_MINREC], fcount,
                           &feet_list[UNFOLD_IDX_EDGE],&Cut_index,
                           contour_index, line,&surf_type, &Length,&Width);
  if (!(status&1)) {
    printf("VLgetCutMarkLns Failed\n");
    goto wrapup;
  }
  *fcount = *fcount + UNFOLD_IDX_EDGE;

  /* at the Cut_index we will find feet which are to be cut.
     feet before this index are to be marked. This is will be coded
     in the rg_collection (vect_type) */
    
  Cut_index = Cut_index + UNFOLD_IDX_EDGE;
  *contour_index = *contour_index + UNFOLD_IDX_EDGE;

  for (i=Cut_index;i< *fcount;i=i+1)
  {
    dim = i/8;
    vect_type[dim] = vect_type[dim] & (~(1<<(i-dim*8)));
  }
  vect_type[ATTR_TXT] = '\0';


  /*c evaluate the fromMat according to the minimum rectangle */ 
  status = VLnewCreFromMat( feet_list[UNFOLD_IDX_MINREC], cur_env, dev, 
                            fromMat, &stat );
  __CheckRC( status , stat, "VLnewCreFromMat", wrapup );

  /*c create the unwraped surface or a point */

  if( UnwrapSrfWanted == FALSE ){
	geom.num_points = 1;
	ORG[0] = fromMat[3];
	ORG[1] = fromMat[7];
	ORG[2] = fromMat[11];
	geom.points = &ORG[0];
  	cst.geometry = (char *)&geom;

        feet_list[UNFOLD_IDX_UNWSRF].osnum = cur_env->md_id.osnum;
        status = om$construct( classid = OPP_GR3dpoint_class_id,
                               osnum   = feet_list[UNFOLD_IDX_UNWSRF].osnum,
                               p_objid = &feet_list[UNFOLD_IDX_UNWSRF].objid );
        if (!(status&1)) goto wrapup;
  	status = om$send(msg      = message GRgraphics.GRaltconstruct(&cst),
	      	       senderid = NULL_OBJID,
	      	       targetid = feet_list[UNFOLD_IDX_UNWSRF].objid,
	  	       targetos = feet_list[UNFOLD_IDX_UNWSRF].osnum );

	__CheckRC( status, *cst.msg, "GR3dpoint.GRaltconstruct", wrapup );
  }
  else{
	cst.geometry = (IGRchar *) dev->devsrf;
        feet_list[UNFOLD_IDX_UNWSRF].osnum = cur_env->md_id.osnum;
        status = om$construct( classid = OPP_EMSgenbs_class_id,
                               osnum   = feet_list[UNFOLD_IDX_UNWSRF].osnum,
                               p_objid = &feet_list[UNFOLD_IDX_UNWSRF].objid );
        if (!(status&1)) goto wrapup;
  	status = om$send(msg      = message GRgraphics.GRconstruct(&cst),
	      	       senderid = NULL_OBJID,
	      	       targetid = feet_list[UNFOLD_IDX_UNWSRF].objid,
	  	       targetos = feet_list[UNFOLD_IDX_UNWSRF].osnum );
	__CheckRC( status, *cst.msg, "GRgraphics.GRconstruct", wrapup );
  }
  new_length = Length;
  new_width = Width;
  for (i=0;i<16;i=i+1) toMat[i] = RefMat[i];
  if (
      ((vs$is_ancestry_valid( object   = &Go3DSrf.obj_id,
                            classid = OPP_VSimgFeature_class_id )
                == TRUE) ||
       (vs$is_ancestry_valid( object   = &Go3DSrf.obj_id,
                            classid = OPP_VSplate_class_id )
                == TRUE)) &&
       (exp_type != 0) && (x_expansion != 0 || y_expansion != 0)
     ) {
    status = VLcompute_expansion_factors (&Go3DSrf,Length,Width,x_expansion,
                                       y_expansion,exp_type,cur_env,
                                       RefMat,&new_length,&new_width);
    if (status != MSSUCC){
      printf("VLcompute_expansion_factors Failed\n");
      goto wrapup;
    }
  }
  /*c apply the transformation matrix */

   obj = feet_list[UNFOLD_IDX_UVSRF]; // we don't want to move this object
   feet_list[UNFOLD_IDX_UVSRF].objid = NULL_OBJID; 
   status = VLapplyTransf( feet_list,*fcount,cur_env,fromMat,RefMat,
			   trfMat, &trfMatType, &stat );

  __CheckRC( status, stat, "VLapplyTransf", wrapup );

   feet_list[UNFOLD_IDX_UVSRF] = obj;

   {
      IGRshort  action, props;

	// Make UVSRF non_locatable & non_displayable.
	// This is to avoid fit problem. ( Fix for TR#179527725 ).

	props = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	action = 0;
	status = om$send ( msg = message GRgraphics.GRchgprops(
						&stat,
						&action,
						&props ),
			   targetid = feet_list[UNFOLD_IDX_UVSRF].objid,
			   targetos = feet_list[UNFOLD_IDX_UVSRF].osnum,
			   senderid = NULL_OBJID );
	if ( !(status&stat&1) )
	  printf("%s[%d] : GRgraphics.GRchgprops failed\n",__FILE__,__LINE__ );
    }
         // find a position outside of holes on the unwraped surface 
         // to place symbols 

    k = 1;
  /* find the maximum of the offset values of edge attributes */
    status = VLretMaxOfVal(*NumEdges,&((*EdgeList)[0]), cur_env, 
                           &MaxOff, &stat);
    if (!(status&stat&1)) MaxOff = 40; 
    
    /* find which measure system do we use. the size of symbols
       (VL_ARROW_SIZE) is good in metric system. For imperial
       system we must scale this size with a factor of 
       25.4/VL_ARROW_SIZE */

    tmp = VL_ARROW_SIZE;
    status =co$unit_database_type( osnum=cur_env->md_id.osnum,
                                   db_type = &i );
    if (!(status&1)) tmp = VL_ARROW_SIZE;
    else {
      if (i == GRIO_UNITS_ARE_ENGLISH) tmp = 26.4;
    }    

    if (dev->developpable) {
  // avoid holes
      status = VLfindBoxOnSurf
                        (&stat,dev,(IGRuint)1,fromMat,
                         (double) (MaxOff+tmp+(new_length-Length)),
                         (double)(MaxOff+tmp)+(new_width-Width),
                         MaxOff+(new_length-Length),MaxOff+(new_width-Width),
                         BoxOrigin, NULL ) ;
      if (!(status&stat&1)) {
        printf("Problems in VLfindBoxOnSurf\n");
        cs_point[0] = 150.;
        cs_point[1] = new_width/2.;
        k=0;
      }
    }
    else {
          // construct a coordinate system on the surface

      BSsfevaln(dev->surface,0.5,0.5,1,&i,point,ZVec,&bsrc);
      if (bsrc != BSSUCC) goto wrapup;

      for( i=0 ; i<3; i=i+1 ) ZVec[i] = - ZVec[i] ;

                // set up initial c.s. based on normal to surface
      BSorthovec( &bsrc, ZVec, XVec ) ;
      if (bsrc != BSSUCC) goto wrapup;
      BScrossp( &bsrc, XVec, ZVec, YVec ) ;
      if (bsrc != BSSUCC) goto wrapup;
      for ( i = 0 ; i < 3 ;  i=i+1 ) {
                mat[ 3 + (4 * i) ]  = point[i] ;
                mat[4*i]            = XVec[i] ;
                mat[1+(4*i)]        = YVec[i] ;
                mat[2+(4*i)]        = ZVec[i] ;
                mat[ i ]            = 0. ;
                mat[ i ]            = 0. ;
        }
  // avoid holes
      status = VLfindBoxOnSurf
                        (&stat,dev,(IGRuint)1,mat,
                         (double) (MaxOff+tmp+(new_length-Length)),
                         (double)(MaxOff+tmp)+(new_width-Width),
                         MaxOff+(new_length-Length),MaxOff+(new_width-Width),
                         BoxOrigin, &EMParams ) ;
      if (!(status&stat&1)) {
        printf("Problems in VLfindBoxOnSurf\n");
        cs_point[0] = 150.;
        cs_point[1] = new_width/2.;
        k=0;
      }
      if (!dev->tesselation_option)
        BSsfeval(dev->devsrf,EMParams.u,EMParams.v,0,BoxOrigin,&bsrc);
      else {
        BSsfevaln(dev->surface,EMParams.u,EMParams.v,1,&i,ORG,vecDr,&bsrc);
        FAevPtSfFaDr((IGRshort) 3,dev->P,dev->devsrf,dev->def,
                     ORG, vecDr, EMParams.u,EMParams.v, BoxOrigin,&bsrc);
      }
      if (bsrc != BSSUCC) {
        printf("Problems in BSsfeval\n");
        cs_point[0] = 150.;
        cs_point[1] = new_width/2.;
        k=0;
      }
    }

    if (k) {
      BoxOrigin[3] = 1;
      index =4; k=1;
      MAmulmx(&stat,&index,&index,&k,trfMat,BoxOrigin,point);
      VLconvert_coord(point,cs_point,&cs);
    }

    status = VLplace_symbols(&dev->surf_id,surf_type,&cs,&cst,cs_point[0],
                            cs_point[1], cs_point[0],cs_point[1],line,
                            new_length,new_width, &feet_list[UNFOLD_IDX_TYPE],
                            &feet_list[UNFOLD_IDX_ORIENTATION]);
    if (!(status&1)) {
      printf("VLplace_symbols Failed\n");
      goto wrapup;
    }

  /*c create the text object */

  status = CreCogText(toMat, new_length, new_width, 
                      &feet_list[UNFOLD_IDX_TEXTSIZE], &stat );
  __CheckRC( status, stat, "CreCogText", wrapup );

  /*c create name of plate as a text object*/
  if (dev->developpable)
    status = CrePlateText(feet_list[UNFOLD_IDX_MINREC],dev,Go3DSrf.obj_id,
                          MaxOff, cur_env, toMat, fromMat, trfMat, 
                          new_length-Length, new_width-Width,
                          &feet_list[UNFOLD_IDX_NAME], &stat );
  else 
    status = CrePlateText(feet_list[UNFOLD_IDX_MINREC],dev,Go3DSrf.obj_id,
                          MaxOff, cur_env, toMat, mat, trfMat, 
                          new_length-Length, new_width-Width, 
                          &feet_list[UNFOLD_IDX_NAME], &stat );

  __CheckRC( status, stat, "CreCrePlateText", wrapup );
  __DBGpr_com("apres transformation");

  feet_list[UNFOLD_IDX_BOX].osnum = cur_env->md_id.osnum;
  status = om$construct(classid = OPP_ACrg_collect_class_id,
                        osnum   = feet_list[UNFOLD_IDX_BOX].osnum,
                        p_objid = &feet_list[UNFOLD_IDX_BOX].objid);
  if (!(status&1)) goto wrapup;
  status = om$send(msg = message ACrg_collect.ACadd_list_attribute
                   (&stat, 1, &ACrg),
	      	   senderid = NULL_OBJID,
                   targetid = feet_list[UNFOLD_IDX_BOX].objid,
                   targetos = feet_list[UNFOLD_IDX_BOX].osnum);
  if (!(status&stat&1)) {
      printf("Problems with ACrg_collection\n");
    goto wrapup;
  }
  status = om$send(msg = message NDnode.NDchg_state( 
						(IGRchar) ND_DONT_MVRT,
						(IGRchar) ND_DONT_MVRT),
	      	   senderid = NULL_OBJID,
                   targetid = feet_list[UNFOLD_IDX_BOX].objid,
                   targetos = feet_list[UNFOLD_IDX_BOX].osnum);


  // put symbology to the UNFOLD_IDX_EDGE first feet
  for (i=0;i<UNFOLD_IDX_EDGE;i=i+1)
  {
    status = om$send( msg      = message GRvg.GRputsymb( &stat,symbology),
	      	         senderid = NULL_OBJID,
                         targetid = feet_list[i].objid,
                         targetos = feet_list[i].osnum);
    if (!(status & stat & 1)) {
          printf("GRvg.GRputsymb Failed\n");
    }
  }

/* 		As per TR#179600923	- Rama Rao 05/07/1996

  // put unwraped surface on level 1022.
  if (UnwrapSrfWanted == TRUE) {
    level = 1022;
    status = om$send(msg = message GRvg.GRchglevel (&stat, &level),
	      	       senderid = NULL_OBJID,
                       targetid = feet_list[UNFOLD_IDX_UNWSRF].objid,
                       targetos = feet_list[UNFOLD_IDX_UNWSRF].osnum);
    if (!(status&stat&1)) {
      printf("GRvg.GRchglevel Failed\n");
    }
  }
*/
  /* change level for all line feet, keep their symbologies*/
  for (i=UNFOLD_IDX_EDGE;i< *contour_index;i=i+1)
  {
    status = om$send(msg = message GRvg.GRchglevel (&stat, &(symbology->level)),
	      	         senderid = NULL_OBJID,
                         targetid = feet_list[i].objid,
                         targetos = feet_list[i].osnum);
    if (!(status&stat&1)) {
      printf("GRvg.GRchglevel Failed\n");
    }
  }
  // put symbology for remainder feet.
  for (i= *contour_index;i< *fcount;i=i+1)
  {
      status = om$send( msg      = message GRvg.GRputsymb( &stat,symbology),
	      	         senderid = NULL_OBJID,
                         targetid = feet_list[i].objid,
                         targetos = feet_list[i].osnum);
      if (!(status & stat & 1)) {
                printf("GRvg.GRputsymb Failed\n");
      }
  }

 // put symbology and name of the cs
  status = om$send ( msg = message GRvg.GRputsymb ( &stat, symbology ),
	      	        senderid = NULL_OBJID,
                        targetid = cs.objid,
                        targetos = cs.osnum );
  if( ! ( stat&1 )) printf(" Warning no symbology %d %d\n",status,stat);

  if (strcmp(name,"Defined")) {
    sprintf( all_name,"%s:%s_cs",tar_path,name);
    status = om$send ( msg = message GRvg.GRchgname
                                          ( &stat, cur_env, all_name ),
	      	          senderid = NULL_OBJID,
                          targetid = cs.objid,
                          targetos = cs.osnum );
  }

  msg = MSSUCC;
wrapup:
        if ( om$is_ancestry_valid( superclassid = img_cl,
                                  subclassid   = GoTemp_cl ) == OM_S_SUCCESS ) {
           om$send(    msg      = message GRgraphics.GRdelete
                                            ( &stat, cur_env ),
	      	            senderid = NULL_OBJID,
                            targetid = dev->surf_id.obj_id.objid,
                            targetos = cur_env->md_id.osnum );
        }
	return ( msg );
}

/* ========================================================================= *
  function to create a VLunwrap object.
 * ========================================================================= */
method create (IGRlong                  *msg;
               struct GRobj_env         *surf;
               struct GRobj_env         *cs;
               double                   *options;
               struct GRmd_env          *cur_env
              )
{
struct GRid     temp[UNFOLD_NB_TEMP];
long            status,loc_msg;
int             ii,loc_msg1;
struct ACrg_coll ACrg[UNFOLD_NB_OPT];

  *msg = MSFAIL;
  ii = 0;
                        /* prepare ACrg collection */
  strcpy(ACrg[ii].name,UNFOLD_ATT_FIB_RATIO);
  ACrg[ii].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[ii].desc.value.att_exp = options[UNFOLD_ATT_IDX_FIB_RATIO];
  ii++;
  strcpy(ACrg[ii].name,UNFOLD_ATT_X_EXPANSION);
  ACrg[ii].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[ii].desc.value.att_exp = options[UNFOLD_ATT_IDX_X_EXPANSION];
  ii++;
  strcpy(ACrg[ii].name,UNFOLD_ATT_Y_EXPANSION);
  ACrg[ii].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[ii].desc.value.att_exp = options[UNFOLD_ATT_IDX_Y_EXPANSION];
  ii++;
  strcpy(ACrg[ii].name,UNFOLD_ATT_SRFWANTED);
  ACrg[ii].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[ii].desc.value.att_exp = options[UNFOLD_ATT_IDX_SRFWANTED];
  ii++;
  strcpy(ACrg[ii].name,UNFOLD_ATT_EXPTYPE);
  ACrg[ii].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[ii].desc.value.att_exp = options[UNFOLD_ATT_IDX_EXPTYPE];
  ii++;
  strcpy(ACrg[ii].name,UNFOLD_ATT_TESSELATION);
  ACrg[ii].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[ii].desc.value.att_exp = options[UNFOLD_ATT_IDX_TESSELATION];
  ii++;

  strcpy(ACrg[ii].name,UNFOLD_ATT_LINES);
  ACrg[ii].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[ii].desc.value.att_exp = options[UNFOLD_ATT_IDX_LINES];
  ii++;

  strcpy(ACrg[ii].name,UNFOLD_ATT_WATONPLATE);
  ACrg[ii].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[ii].desc.value.att_exp = options[UNFOLD_ATT_IDX_WATONPLATE];
  ii++;

  strcpy(ACrg[ii].name,UNFOLD_ATT_SIDE);
  ACrg[ii].desc.type = AC_ATTRIB_DOUBLE;
  ACrg[ii].desc.value.att_exp = options[UNFOLD_ATT_IDX_SIDE];
  ii++;

  temp[UNFOLD_IDX_BOX].objid = NULL_OBJID;
  temp[UNFOLD_IDX_BOX].osnum = cur_env->md_id.osnum;
  status = om$construct(classid = OPP_ACrg_collect_class_id,
                        osnum   = temp[UNFOLD_IDX_BOX].osnum,
                        p_objid = &temp[UNFOLD_IDX_BOX].objid);
  if (!(status&1)) goto quit;

  om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
           targetid = temp[UNFOLD_IDX_BOX].objid,
           targetos = temp[UNFOLD_IDX_BOX].osnum );

  status = om$send(msg = message ACrg_collect.ACadd_list_attribute
                   (&loc_msg, ii, ACrg),
                   targetid = temp[UNFOLD_IDX_BOX].objid,
                   targetos = temp[UNFOLD_IDX_BOX].osnum);
  if(!(status & loc_msg & 1)) {
    goto quit;
  }

  as$make_source( go_grid = surf->obj_id,
                  mod_env = &(surf->mod_env),
                  as_os   = cur_env->md_id.osnum ,
                  as_grid = &temp[UNFOLD_IDX_SURF]);

  as$make_source( go_grid = cs->obj_id,
                  mod_env = &(cs->mod_env),
                  as_os   = cur_env->md_id.osnum ,
                  as_grid = &temp[UNFOLD_IDX_CS]);
  

  status = om$send(  msg  = message ACncpx.ACmplace(
                                          &loc_msg1,
                                          AChdr_noprotect , 0,
                                          MACRO_UNWRAP,
                                          UNFOLD_NB_FTEMP,
                                          temp,
                                          cur_env ),
                          targetid = my_id);
  if (!(status&loc_msg1&1)) {
    goto quit;
  }

  *msg = MSSUCC;
quit :
  return OM_S_SUCCESS;
}

/* ========================================================================= *
  return attributes in the box of the unwrap.
 * ========================================================================= */
method getRoots      (        long		*msg;
                       struct GRmd_env	        *cur_env;
                       struct mise_a_plat	*dev;
                              struct GRobj_env  *plate;
                       	      int		*exp_type;
                       	      double		*x_expansion;
                       	      double		*y_expansion;
                       	      int		*UnwSrfWanted;
                       	      double		*RefMat;
			      struct GRid	*box
                      )
{
struct GRid 		*lchild=NULL;
int	   	 	num,j;
long	    		status,loc_msg;
struct ACrg_coll 	ACrg[UNFOLD_NB_OPT];


  *msg = MSFAIL;

  status = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF | ND_ROOT,
                                                (struct GRid *)NULL,
                                                0,
                                                &lchild,
                                                0,
                                                OM_K_MAXINT,
                                                &num ),
                targetid = my_id);
   if (!(status&1))  {
     goto quit;
   }
   if (num >= UNFOLD_IDX_BOX) {
     status = om$send(msg = message ACrg_collect.AClist_attribute
                                        (&loc_msg,UNFOLD_NB_OPT,ACrg,&num),
                       targetid = lchild[UNFOLD_IDX_BOX].objid,
                       targetos = lchild[UNFOLD_IDX_BOX].osnum);
     if (!(status&loc_msg&1)) {
       goto quit;
     }
   }
   else {
     goto quit;
   }
  if (box) *box = lchild[UNFOLD_IDX_BOX];

  if (UnwSrfWanted) {
    if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_SRFWANTED)) != -1) 
      *UnwSrfWanted = ACrg[j].desc.value.att_exp;
  }
  if (RefMat) {
    status = om$send(  msg = message GRgencs.GRgetmatrix( &loc_msg, RefMat ),
                targetid = lchild[UNFOLD_IDX_CS].objid,
                targetos = lchild[UNFOLD_IDX_CS].osnum ); 
    if (!(status&loc_msg&1)) goto quit;
  }
  if (dev) {
    if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_TESSELATION)) != -1) 
      dev->tesselation_option = ACrg[j].desc.value.att_exp;
    if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_LINES)) != -1) 
      dev->WantedLinesCode = ACrg[j].desc.value.att_exp;
    if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_FIB_RATIO)) != -1) 
      dev->fib_ratio = ACrg[j].desc.value.att_exp;
    if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_WATONPLATE)) != -1) 
      dev->AllWaterLines = ACrg[j].desc.value.att_exp;
    if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_SIDE)) != -1) 
      dev->side_of_plate = ACrg[j].desc.value.att_exp;
    status = VLextractSurf(&lchild[UNFOLD_IDX_SURF],cur_env,dev,plate);
    if (!(status&1)) goto quit;
  }

  if (exp_type) {
    if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_EXPTYPE)) != -1) 
      *exp_type = ACrg[j].desc.value.att_exp;
  }
  if (x_expansion) {
    if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_X_EXPANSION)) != -1) 
    *x_expansion = ACrg[j].desc.value.att_exp;
  }
  if (y_expansion) {
    if ((j=VLseekFields(ACrg,num,UNFOLD_ATT_Y_EXPANSION)) != -1) 
    *y_expansion = ACrg[j].desc.value.att_exp;
  }

  *msg = MSSUCC;
quit :
  return OM_S_SUCCESS;
}
     

method ACconstruct_feet (               IGRlong         *msg;
                                        IGRint          cn_type;
                                        IGRint          count;
                         struct         GRid            list[];
                         struct         GRmd_env        *md_env;
                                        IGRint          *fcount;
                         struct         GRid            *feet_list )
{
long		sts,stat;
struct  EdgeMatch       *EdgeList=NULL;
int			NumEdges;
int			contour_index;
struct GRsymbology	symbology;
struct GRid	Temp[5],MacEdge2D;
OM_S_CHANSELECT         ChannelTo;
OM_S_CHANSELECT         ChannelFr;
IGRint                  i_stat,prop;
short                    mask,action;
IGRint                  i,k,numObjects ;
struct GRobj_env        mac,edge_3d,*list_obj=NULL;
struct GRid		*lchild=NULL;
IGRchar			name[20];
struct  mise_a_plat	dev;
struct GRid		box;
int			num;
struct ACrg_coll        list_att[ATT_NB_ATT];

char			word[DI_PATH_MAX],theword[DI_PATH_MAX];
enum	GRdpmode	dpmode=GRbd;
int                     UnwLnsOptions[UNFOLD_NB_OPTLINE];

  *msg = MSFAIL;
  if (!md_env || !list || !fcount || !feet_list ) goto wrapup;

  mac.obj_id.objid = my_id;
  mac.obj_id.osnum = md_env->md_id.osnum;
  mac.mod_env = *md_env;
  sts = constructUnwrap(mac.obj_id,list,md_env,&dev,fcount,feet_list,&EdgeList,
                        &NumEdges, &contour_index,&symbology);
  if (!(sts&1)) {
    goto wrapup;
  }

  VLdecode(dev.WantedLinesCode,UNFOLD_NB_OPTLINE, UnwLnsOptions);
  if( UnwLnsOptions[UNFOLD_ATT_IDX_DISMIN] )
  {
    sts = om$send(    msg      = message GRgraphics.GRdelete
                                            ( &stat, md_env ),
                            targetid = feet_list[UNFOLD_IDX_MINREC].objid,
                            targetos = feet_list[UNFOLD_IDX_MINREC].osnum );

    sts = om$construct(  classname = "VDsymb_hold",
                             osnum = OM_Gw_current_OS,
                           p_objid = &feet_list[UNFOLD_IDX_MINREC].objid );
    feet_list[UNFOLD_IDX_MINREC].osnum = OM_Gw_current_OS;
    if(sts&1)
    {
       om$send(msg = message NDnode.NDchg_state(ND_SUP_ONLY , ND_SUP_ONLY ),
               targetid = feet_list[UNFOLD_IDX_MINREC].objid,
               targetos = feet_list[UNFOLD_IDX_MINREC].osnum  );
    }
  }

// initialization

  mask = (GRIS_LOCATABLE | GRIS_DISPLAYABLE);
  mac.obj_id.objid = my_id;
  mac.obj_id.osnum = md_env->md_id.osnum;
  mac.mod_env = *md_env;

#if 0
// find edge2D_att attached to the unwrap to kill it.
  VLbrowseFctInTree( &mac, VL_Q_TOP_SOURCE, NULL,
                     VL_Q_DOWN_DIRECT,
                     VLgetMacrosAtStep,
                     &numObjects, &list_obj );
  VLfilterDef(numObjects,list_obj,&numObjects,"edge2D_att");

  for (i=0;i<numObjects;i++)
  {
    sts = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF | ND_ROOT,
                                                (struct GRid *)NULL,
                                                0,
                                                &lchild,
                                                0,
                                                OM_K_MAXINT,
                                                &k ),
                    senderid  = NULL_OBJID,
                    targetid = list_obj[i].obj_id.objid,
                    targetos = list_obj[i].obj_id.osnum);

    if (k>=2) {
// kill the attached pretend
      om$send(msg=message NDnode.NDdelete(&(list_obj[i].mod_env)),
                  targetid = lchild[2].objid,
                  targetos = lchild[2].osnum);
    }

    gr$display_object ( object_id = (struct GRid *)&(list_obj[i].obj_id),
                        mode      = GRbehe);
    om$send(msg=message NDnode.NDdelete(&(list_obj[i].mod_env)),
                targetid = list_obj[i].obj_id.objid,
                targetos = list_obj[i].obj_id.osnum);
  }
#endif

  Temp[1].objid = my_id;
  Temp[1].osnum = md_env->md_id.osnum;

  ChannelTo.type       = OM_e_name;
  ChannelTo.u_sel.name = "father";
  ChannelFr.type       = OM_e_name;
  ChannelFr.u_sel.name = "children";

  for(i=0;i<NumEdges;i=i+1){
    if( EdgeList[i].EdgeMac.objid != NULL_OBJID ){
      prop = AChdr_noprotect;
      action = 1;

// find allowance (offset) attribute
    sts = om$send( msg     = message  ACcpx.ACfind_exp_temp_obj(
                                                         &i_stat,
                                                         ATT_T_IDX_BOX,
                                                         &box ),
                                    targetid = EdgeList[i].EdgeMac.objid,
                                    targetos = EdgeList[i].EdgeMac.osnum );
    if(!(sts&i_stat&1) ) goto wrapup;

    sts = om$send(msg = message ACrg_collect.AClist_attribute
                                        (&stat,ATT_NB_ATT,list_att,&num),
                       targetid = box.objid,
                       targetos = box.osnum);
    if(!(sts&stat&1) ) goto wrapup;

    if (num < ATT_IDX_ALLOWANCE) goto wrapup;

    if (
        (list_att[ATT_IDX_ALLOWANCE].desc.value.att_exp <= 0.00001 &&
        list_att[ATT_IDX_ALLOWANCE].desc.value.att_exp > -0.00001 ) &&
        (list_att[ATT_IDX_X].desc.value.att_exp <= 0.00001 &&
        list_att[ATT_IDX_X].desc.value.att_exp > -0.00001 )&&
        (list_att[ATT_IDX_V].desc.value.att_exp <= 0.00001 &&
        list_att[ATT_IDX_V].desc.value.att_exp > -0.00001 )
       ) {
      prop = prop | AChdr_nodisplay; /* if allowance value is zero, than
                                        don't display edge2D_attr */
       action = 0;
    }

       as$make_source( go_grid = EdgeList[i].EdgeMac,
                       mod_env = &dev.surf_id.mod_env,
                       as_grid = &Temp[0] );

        as$make_source( go_grid = feet_list[(i+contour_index)],
                        mod_env = md_env,
                        as_grid = &Temp[2] );

        Temp[3].objid = NULL_OBJID;
        Temp[3].osnum = md_env->md_id.osnum;
        sprintf(name,"edge%d",i+contour_index - UNFOLD_IDX_EDGE);

                        /*c create a pretend */
       sts = om$construct (classid = OPP_ACpretend_class_id,
                          osnum   = Temp[3].osnum,
                          p_objid = &(Temp[3].objid));
       if( !(sts&1) ) goto wrapup;

        sts = om$send(msg = message ACpretend.ACpconnect(
                                                    0,
                                                    (mac.obj_id),
                                                    name),
                        targetid = Temp[3].objid,
                        targetos = Temp[3].osnum );

       if( !(sts&1) ) goto wrapup;

       sts = om$send (msg = message NDnode.NDchg_state(
                                        (char)~0, (char)0),
                                targetid = Temp[3].objid,
                                targetos = Temp[3].osnum );

      if (!(sts&1)) goto wrapup;

            /*c place the ci_macro edge2D_att to make the link
                with the attributs 3D */

      edge_3d.obj_id  = EdgeList[i].EdgeMac;
      edge_3d.mod_env = dev.surf_id.mod_env;

      // find edge2D_att corresponding to 3-D edge.
      VLbrowseFctInTree( &edge_3d, VL_Q_TOP_SOURCE, NULL,
                     VL_Q_DOWN_DIRECT,
                     VLgetMacrosAtStep,
                     &numObjects, &list_obj );
      VLfilterDef(numObjects,list_obj,&numObjects,"edge2D_att");

      if( !numObjects )
      {
         MacEdge2D.objid  = NULL_OBJID;
         MacEdge2D.osnum  = md_env->md_id.osnum;
         sts = om$construct (classid = OPP_VLedge2Datt_class_id,
                             osnum   = MacEdge2D.osnum,
                             p_objid = &(MacEdge2D.objid));
         if (!(sts&1)) goto wrapup;

         sts = om$send(  msg  = message ACncpx.ACmplace(
                                          &i_stat,
                                          prop, 0,
                                          "edge2D_att",
                                          3,
                                          Temp,
                                          md_env ),
                          targetid = MacEdge2D.objid,
                          targetos = MacEdge2D.osnum);
         if (!(sts&i_stat&1)) {
             goto wrapup;
         }
      }
      else
      {
         IGRint ind;
	 struct GRid old_temp;

	 MacEdge2D = list_obj[0].obj_id;

    	 sts = om$send( msg     = message  ACcpx.ACfind_exp_temp_obj(
                                                         &i_stat,
                                                         2,
                                                         &old_temp ),
                                    targetid = MacEdge2D.objid,
                                    targetos = MacEdge2D.osnum );
         if(!(sts&i_stat&1) ) goto wrapup;

         sts = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF | ND_CHILDREN,
                                                (struct GRid *)NULL,
                                                0,
                                                &lchild,
                                                0,
                                                OM_K_MAXINT,
                                                &k ),
                    senderid  = NULL_OBJID,
                    targetid = old_temp.objid,
                    targetos = old_temp.osnum);

	 for( ind=0; ind<k; ++ind )
         {
	      sts = om$send(  msg  = message NDnode.NDchange_connect(
						1,
						&old_temp,
						&Temp[2]),
                          targetid = lchild[ind].objid,
                          targetos = lchild[ind].osnum);
              if (!(sts&1)) {
            	goto wrapup;
              }
	 }
         sts = om$send(msg=message NDnode.NDdelete(&list_obj[0].mod_env),
                  targetid = old_temp.objid,
                  targetos = old_temp.osnum);

      }

      sts = gr$put_properties (object_id=&MacEdge2D,
                               action=action,
                               properties_mask=mask);

      if(!(VLgetName(&Temp[1],word)))
			strcpy(word,"Defined");
      sprintf(theword,"%s_%d",word,i);

      sts = 	VLsetSymb_Name_Disp(
				     &i_stat,
				     theword,
				     ED_ATT_2D_KEY,
				     &Temp[2],
				     &MacEdge2D,
				     &dpmode,
				     md_env	);

      if(!(sts & i_stat & 1))
			ex$message(msgnumb = VL_E_BadChgName);

      sts = om$send(msg = message NDnode.NDchg_state(
                                     (IGRchar) ND_DONT_MVRT,
                                     (IGRchar) ND_DONT_MVRT),
                      targetid = MacEdge2D.objid,
                      targetos = MacEdge2D.osnum );

           /*c disconnect the make source from the edge2D macro */
      sts = om$send (msg = message Root.disconnect (
                                                     ChannelTo,
                                                     Temp[2].objid,
                                                     Temp[2].osnum,
                                                     ChannelFr),
                                mode = OM_e_wrt_message,
                                targetid = MacEdge2D.objid,
                                targetos = MacEdge2D.osnum );

       if (!(sts&1)) goto wrapup;

       sts = om$send (msg      = message Root.delete (0),
                                       targetid = Temp[2].objid,
                                       targetos = Temp[2].osnum );

       if (!(sts&1)) goto wrapup;

              /*c connect the pretend object instead source */
       sts = om$send (msg = message Root.connect (
                                                   ChannelTo,
                                                   OM_K_MAXINT,
                                                   Temp[3].objid,
                                                   Temp[3].osnum,
                                                   ChannelFr,
                                                   OM_K_MAXINT),
                                mode = OM_e_wrt_message,
                                targetid = MacEdge2D.objid,
                                targetos = MacEdge2D.osnum );

       if (!(sts&1)) goto wrapup;

                 /*c connect the edge att to the ci_macro srf_unwrap */
       sts = om$send (msg = message Root.connect (
                                                   ChannelTo,
                                                   OM_K_MAXINT,
                                                   Temp[0].objid,
                                                   Temp[0].osnum,
                                                   ChannelFr,
                                                   OM_K_MAXINT),
                                        mode = OM_e_wrt_message,
                                        targetid = mac.obj_id.objid,
                                        targetos = mac.obj_id.osnum );
       if (!(sts&1)) goto wrapup;
     }
   }
  *msg = MSSUCC;

  wrapup :
  if (*msg == MSFAIL) {
     for (i=0;i< *fcount; i++)
       om$send(    msg      = message GRgraphics.GRdelete
                                            ( &stat, md_env ),
                            targetid = feet_list[i].objid,
                            targetos = feet_list[i].osnum );
     feet_list[UNFOLD_IDX_UNWSRF].objid = NULL_OBJID;
     *fcount = 0;
  }
  if( list_obj != NULL ) {om$dealloc( ptr = list_obj );list_obj = NULL;}
  if( EdgeList ){om$dealloc(ptr=EdgeList);EdgeList=NULL;}
  VLfreeDev (&dev);
  return *msg;
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_Objunwrap;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLunwrap;

