/* $Id: VSplateUtil.I,v 1.2 2001/03/13 17:16:09 jayadev Exp $ */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsmisc/VSplateUtil.I
 *
 * Description: Utility functions for ASCII process cutout control
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VSplateUtil.I,v $
 *  Revision 1.2  2001/03/13 17:16:09  jayadev
 *  changes for ASCII cutout control
 *
 *  Revision 1.1  2001/03/02 20:20:53  jayadev
 *  *** empty log message ***
 *
 *
 * History:
 *      MM/DD/YY    AUTHOR      DESCRIPTION
 ***************************************************************************/
/*
  I/STRUCT
*/
class implementation VSplate ;

#include <stdlib.h>
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "EMSmsgdef.h"
#include "bsparameters.h"
#include "VDobj.h"
#include "VDgeom.h"
#include "VDexp.h"
#include "VDefp.h"
#include "v_edgemacros.h"
#include "v_edgedef.h"
#include "v_dbgmacros.h"
#include "vsdbgmacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsplatedef.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

#define UNKNOWN 0
#define FACE 1
#define EDGE 2
#define ALL  3

struct macroList{
  GRname exp_name;
  IGRint type;
  IGRint index;
} ;

extern OMuword    OPP_ACconst_class_id, OPP_VSbooPlate_class_id,
                  OPP_VSholPlate_class_id, OPP_VSbooBeam_class_id,
                  OPP_VSplate_class_id, OPP_VSbeam_class_id,
                  OPP_GRcurve_class_id;

extern int VD_get_geometry();
extern void BSlsqptlnpl();
extern void BSmdistcvcv();

from    ACcpx_defn      import ACgive_name ;
from    EMSsubbs        import EMproject_curve_onto_surface;
from    expression      import NDgive_value;

/*
 * This function tells if the macro curve is lying on
 * the edge/face of the plate/beam surface
 */

IGRint VScheckMacroCurveOnEdge(struct GRobj_env   parOE,
			       struct GRobj_env   curve,
			       IGRint             *location) 
{
  IGRint                 retFlag = 0,code;
  IGRlong                sts,msg,numPoles;
  struct GRmd_env        myEnv;
  struct GRvg_construct  cst;
  struct IGRbsp_curve    *curveGeom = NULL,*prjGeom = NULL;
  IGRvector              vector;
  IGRpoint               pt;
  IGRdouble              err;
  BSrc                   rc ;
  struct GRobj_env       prjCurve,testSurf;
  struct IGRbsp_surface  *srfGeom = NULL;
  IGRchar                buf[128];
  IGRboolean             planar = FALSE;
  IGRboolean             want_status_messages,TrimRequired, AppRequired;
  IGRlong                num_crv, EMSretmsg, size;
  GRobjid                *CURVES = NULL;
  struct GRlc_info       curve1,surface1;
  struct IGRplane        cvPlane ; 
  
  gr$get_module_env( buffer = &myEnv );
  
  *location = -1;
  
  vs$fill_cnst_list(      Msg             = &msg,
			  Env_info        = &myEnv,
			  Cnst_list       = cst ) ;

  VD_get_geometry(&msg,&curve.obj_id,&curve.mod_env,(IGRchar **)&curveGeom);
  if((!(msg&1)) || (curveGeom == NULL))
  {
    __DBGpr_obj("VD_get_geometry failed for",curve.obj_id);
    goto wrapup;
  }
  if(!curveGeom->planar){
    __DBGpr_obj("macroCurve is not planar",curve.obj_id);
    goto wrapup;
  }
  testSurf.obj_id.objid = NULL_OBJID;

  if( vs$is_ancestry_valid(object = &parOE.obj_id, 
                           classid = OPP_VSplate_class_id)) 
  {
    __DBGpr_obj("parOE ",parOE.obj_id);
    vdobj$GetFoot(objOE=&parOE,footName = VS_K_plBotSfPath,footOE = &testSurf);
    if (testSurf.obj_id.objid == NULL_OBJID) goto wrapup;

    __DBGpr_obj("plate base surface ",testSurf.obj_id);
    
    vdgeom$Get2(objOE = &testSurf, srf = &srfGeom);
    if (srfGeom == NULL) goto wrapup;
  }
  else if(vs$is_ancestry_valid(object  = &parOE.obj_id,
                               classid = OPP_VSbeam_class_id)) 
  {
    strcpy(buf,"beam:body:web_____r");

    vdobj$GetFoot(objOE = &parOE, footName = buf, footOE = &testSurf);
    if(testSurf.obj_id.objid == NULL_OBJID) goto wrapup;

    vdgeom$Get2(objOE = &testSurf, srf = &srfGeom);
    if (srfGeom == NULL) goto wrapup;
  }
  else 
  {
    __DBGpr_com(" UNknown class ");
    goto wrapup;
  }
  
  want_status_messages = FALSE;
  TrimRequired = TRUE;
  num_crv = 0;
  
  curve1.located_obj = curve.obj_id;
  curve1.module_info = curve.mod_env;
  surface1.located_obj = testSurf.obj_id;
  surface1.module_info = testSurf.mod_env;
  
  prjCurve.obj_id.osnum = cst.env_info->md_id.osnum;
  
  __DBGpr_com("GRvg.GRdetplane");

  cvPlane.normal  = vector;
  cvPlane.point   = pt ;
  
  sts = om$send(  msg     = message GRvg.GRdetplane(
                                          &msg,
                                  	  &curve.mod_env.md_env.matrix_type,
                                          curve.mod_env.md_env.matrix,
                                          &cvPlane ),
		  senderid= curve.obj_id.objid,
		  targetid= curve.obj_id.objid,
		  targetos= curve.obj_id.osnum ) ;
  __CheckRC( sts, msg, "GRvg.GRdetplane", wrapup ) ;
  
  
  __DBGpr_com("EMSsubbs.EMproject_curve_onto_surface");

  code = om$send(msg= message EMSsubbs.EMproject_curve_onto_surface(
                                                &curve1,
                                                &surface1,
                                                &cst,
                                                vector,
                                                want_status_messages,
                                                TrimRequired,
                                                &num_crv,
                                                &CURVES,
                                                &EMSretmsg),
		 
		 senderid = surface1.located_obj.objid ,
		 targetid = surface1.located_obj.objid ,
		 targetos = surface1.located_obj.osnum );
  if ((! (EMSretmsg & code & 1)) || (num_crv == 0) )
  {
    __DBGpr_com("EMSsubbs.EMproject_curve_onto_surface failed ");
    goto wrapup;
  } 
  
  prjCurve.obj_id.objid = CURVES[0];
  prjCurve.mod_env = *cst.env_info;
  
  __DBGpr_obj("Proj Curve EMproject_curve_onto_surface",prjCurve.obj_id);

  VD_get_geometry(&msg,&prjCurve.obj_id,&prjCurve.mod_env,(IGRchar **)&prjGeom);
  if((!(msg&1)) || (prjGeom == NULL))
  {
    __DBGpr_obj("VD_get_geometry failed ",prjCurve.obj_id);
    goto wrapup;
  }
  if(VSfindCurveOnSurface(&testSurf,prjGeom,location))
  {
    if(*location == EDGE){ __DBGpr_com("Macro Curve is on the EDGE");}
    else if(*location == FACE){ __DBGpr_com("Macro Curve is on the FACE");}
    else{ __DBGpr_com("Macro Curve location is not known");}
    
    retFlag = 1;
  }
  
 wrapup:
  
  if(prjCurve.obj_id.objid != NULL_OBJID)
  {
    vs$bulk_delete( count   = 1,
		    grids   = &prjCurve.obj_id,
		    theEnv  = &prjCurve.mod_env ) ;
  }
  
  _FREE(curveGeom);
  _FREE(CURVES);
  _FREE(prjGeom);
  _FREE(srfGeom);
  __DBGpr_int("VScheckMacroCurveOnEdge retFlag ",retFlag);
  return retFlag;
}
/* 
 * This functions reads an ASCII setup file and decides if an input macro 
 * should be considered for processing cutout or not
 */
IGRint VSprocessMacroDecision(struct GRid        macroId, 
			      GRname             macName,
			      struct GRobj_env   macFeet,
			      struct GRobj_env   parOE,
			      struct macroList   *ignoreThese,
			      IGRint             igCount)
{
  IGRlong           sts;
  IGRint            msg,ii;
  GRname            txtString;
  IGRint            processFlag = TRUE,location;
  struct GRobj_env  macOE;
  IGRboolean        expFlag ;
  struct ACrg_coll  expColl;
  
  sts = OM_S_SUCCESS ;
  msg= MSSUCC ;
  
  if((!ignoreThese) || (igCount == 0)) goto wrapup;
  
  macOE.obj_id = macroId;
  macOE.mod_env= macFeet.mod_env;
  
  // check for the macro name from the ASCII file
  for(ii=0;ii<igCount;ii++)
  {
    processFlag = TRUE;
    expFlag = FALSE;
    
    vd$exp_evaluate(flag    = &expFlag,
		    expName = ignoreThese[ii].exp_name,
		    object  = &macOE,
		    rgColl  = &expColl);
    __DBGpr_obj("MACRO ID",macroId); 
    __DBGpr_str("MACRO NAME",macName); 
    __DBGpr_str("EXPRESSION NAME",ignoreThese[ii].exp_name); 
    __DBGpr_int("vd$exp_evaluate expFlag",expFlag); 
    
    if(expFlag)
    { 
      
      if(ignoreThese[ii].type == ALL)
      {
	processFlag = FALSE;
	goto wrapup;
      }
      
      // see if the macro curve lies on the edge of the plate/beam
      msg = VScheckMacroCurveOnEdge(parOE,macFeet,&location); 
      if((msg&1) && (location == ignoreThese[ii].type)){
	processFlag = FALSE; // donot process this macro
	goto wrapup;
      }
      
    }
  }
  
 wrapup:
  __DBGpr_int("processFlag",processFlag); 
  return processFlag;
}
/*----------------------------------------------------------------------------*/
FILE *VSmac_OpenSetupFile()
{
  IGRint i;
  IGRchar buf[DI_PATH_MAX];
  FILE *file ;
  
  // Look in local directory
  file = fopen("macro_setup","rt");
  if (file) return file;
  
  // Look in config directory
  for(i = 0; 1; i++) {
    
    // Product specific loading
    *buf = 0;
    ex$get_path( index = i,
		 path  = buf,
		 len   = sizeof(buf),
		 type  = EX_CONFIG_PATH );
    if (*buf == 0) {
      file = NULL;
      return file;
    }
    
    strcat(buf,"config/process/macro_setup");
    file = fopen(buf,"rt");
    if (file != NULL) return file;
  }
}

IGRint VSreadMacrosFromASCII(struct macroList **list, IGRint *count)
{
  IGRint	retFlag = 0, ii;
  IGRint	ind = 0, nlines = 0, type = UNKNOWN;
  GRname	buf;
  IGRchar	*ptr, name[128];
  FILE		*fileptr;
  
  fileptr = VSmac_OpenSetupFile();
  if(fileptr == NULL) 
  {
    __DBGpr_com(" Could not open macro_setup file for reading");
    goto wrapup;
  }
  
  while(fgets(buf,sizeof(buf), fileptr)) {
    nlines++;
  }
  
  __DBGpr_int("No. of lines in the ASCII input file ",nlines);
  
  if(nlines == 0) goto wrapup;
  nlines += 20;
  *list = _MALLOC(nlines, struct macroList);
  
  // initialize the list; later will be filled with ASCII info
  for(ii=0;ii<nlines;ii++)
  {
    (*list)[ii].exp_name[0]	= '\0';
    (*list)[ii].type		= UNKNOWN;
    (*list)[ii].index		= -1;
  }
  
  rewind(fileptr);
  
  while(fgets(buf,sizeof(buf),fileptr)) {
    
    ptr = buf;
    ptr[strlen(ptr)-1] = '\0';
    
    if (!strncmp(ptr, "%", 1)) {
      ptr++;
      if( !strcmp(ptr, "FACE") ) {
	type = FACE;
      }
      else if( !strcmp(ptr, "EDGE") ) {
	type = EDGE;
      }
      else if( !strcmp(ptr, "ALL") ) {
	type = ALL;
      }
      else {
	type = UNKNOWN;
	continue;
      }
    }
    
    if ( type == UNKNOWN ) continue;
    
    if (!strncmp(ptr, "#", 1)) {
      ptr++;
      if( strlen( ptr ) < 1 ) {
	continue;
      }
      strcpy((*list)[ind].exp_name, ptr);
      (*list)[ind].type = type;
      ind++;
    }
    
    buf[0] = '\0';
  } 
  
  *count = ind;
  
  fclose(fileptr);
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

IGRint VSfilterASCIImacros(	struct GRobj_env        parOE,
				struct GRid		roots[], 
				IGRboolean              flags[],
                                struct GRobj_env        macroCurves[],
                                IGRint                  count
                          ) 
{
  
  int			i,	           /* World's favorite loop index */
                        alloc ,            /* Flags space allocation */
                        retSts,
			retFlag = 0;
  long			sts,sts1 ;         /* OM return code */
  struct GRobj_env	macFeet;           /* Pointer to GO's id & module */
  struct GRid		parentID;
  OMuword       	Classid;           /* Classid of parent macro  */
  struct GRid           macDef ;           /* Macro definition.        */
  GRname                macName ,name;     /* Name of macro (local).   */
  IGRint                processFlag = TRUE;
  struct macroList      *ignoreThese = NULL;
  IGRint                readSts = 0,igCount = 0,ii;
  IGRboolean            cutoutFlag = FALSE;
 
  sts  = OM_S_SUCCESS ;
  alloc= FALSE ;
  
  {
    long            status1;
    GRspacenum      cur_osnum;
    OM_S_OBJID      cur_objid;
    IGRchar         file_name[DI_PATH_MAX],
                    expName[DI_PATH_MAX],
                    cur_dir[DI_PATH_MAX];
    struct GRid     exp_obj;
    
    ex$get_cur_mod( id = &cur_objid, osnum = &cur_osnum );
    
    VDSget_filename(file_name);
    di$pwd(dirname = cur_dir);
    
    strcat( file_name, ":IGENOD" );
    sprintf(expName, "%s:cutoutOption", file_name );
    
    di$cd(dirname = file_name);
    status1 = di$translate(  objname = expName,
			     osnum   = cur_osnum,
			     p_objid = &exp_obj.objid);
    if( status1 == DIR_S_SUCCESS)
    {
      IGRdouble cutout_opt;
      sts = om$send ( msg = message expression.NDgive_value (&cutout_opt),
		      senderid = NULL_OBJID,
		      targetid = exp_obj.objid,
		      targetos = cur_osnum );
      if( cutout_opt == 1.0 )
      {
	__DBGpr_com("cutoutFlag is set - read the ASCII file");
	cutoutFlag = TRUE; // read the ASCII file
      }
    }
    
    di$cd(dirname = cur_dir);
  } 
  __DBGpr_int("cutoutFlag ",cutoutFlag);
  
  /*
   * read the macro info from the ASCII macro_setup file if mentioned
   */
  if(cutoutFlag)
  { 
    readSts = VSreadMacrosFromASCII(&ignoreThese,&igCount);
    if((!readSts) || (igCount == 0)){
      readSts = 0;
      __DBGpr_com("Error reading ASCII file for macros ");
    }
    else{ 
      __DBGpr_int("Macros to be ignored for the cutout processing %d",igCount);
      for(ii=0;ii<igCount;ii++)
      {
	__DBGpr_str("MACRO_EXPRESSION ",ignoreThese[ii].exp_name);
	__DBGpr_int("TYPE ",ignoreThese[ii].type);
      }
    }
  }
  else
    goto wrapup;
  
  if(!readSts) goto wrapup;
  
  for( i = 0 ; i < count ; i++ ) {
    
    processFlag = TRUE;
        
    __DBGpr_int("********processing for macro number*********   ",i);
    
    parentID.objid = NULL_OBJID;
    
    // get the macro parent of the ACpretend
    retSts = VDobjGetPretendParent(&roots[i],&parentID);
    __DBGpr_obj("parentID ",parentID);
    __DBGpr_obj("pretendID ",roots[i]);
    
    if((!retSts) || (parentID.objid == NULL_OBJID)) continue;
    
    sts = om$get_classid(       objid           = parentID.objid,
				osnum           = parentID.osnum,
				p_classid       = &Classid ) ;
    if(!(sts&1)) continue;
	  
    sts1 = om$is_ancestry_valid( superclassid = OPP_ACconst_class_id,
        		         subclassid   = Classid ) ;
	
    macFeet = macroCurves[i];
	  
    if(!(sts1&1) || !( vs$is_ancestry_valid(
                            object  = &macFeet._grid,
                            classid = OPP_GRcurve_class_id ) ))
    	continue;
	  
    name[0] = '\0';
    vdobj$Get(objID   = &parentID,
              macName = name);  
    strcpy   ( macName, name ) ;
	  
    processFlag = VSprocessMacroDecision(
                    parentID,macName,macFeet,parOE,ignoreThese,igCount);

    __DBGpr_obj("MacroID ",parentID);
    __DBGpr_int("processFlag ",processFlag);
	  
    if(!processFlag) // FALSE flag indicates not to process this macro
    {
      flags[i] = FALSE;
    }  
    __DBGpr_com("*******************************************   ");
  }
 
  retFlag = 1; 
  wrapup :
    
  _FREE(ignoreThese);
  return retFlag ;
  
} 
/* 
 * This function attempts to see if a curve is lying on the face or edge 
 * of a surface We get the contour edges of the surface and see if the 
 * min_dist b/w the curve and any of the contour edges is zero;
 */
IGRint VSfindCurveOnSurface(struct GRobj_env      *srf,
			    struct IGRbsp_curve   *prjCurve,
			    IGRint                *location)
{
  IGRint                  ii,retFlag = 0,nContour = 0,num = 0;
  IGRlong                 sts,msg;
  struct GRid             *edges_cont = NULL;
  struct IGRbsp_curve     *edges[VDEFP_NEAT_EDGES_MAX];
  IGRdouble               min_dist = 1.0, chtol = 0.1;
  IGRdouble               *par1 = NULL,*par2 = NULL;
  IGRpoint                *pt1 = NULL,*pt2 = NULL;
  BSrc                    rc ;
  
  BSxtractpar(&msg, BSTOLCHRDHT, &chtol );
  
  for(ii=0;ii<VDEFP_NEAT_EDGES_MAX;ii++) edges[ii] = NULL;
  
  // get the neat edges
  sts = VDefpGetSurfaceEdgeBsps( srf, VDEFP_NEAT_EDGES_MAX, chtol,
				 &nContour, edges );
  __CheckRC( sts, 1, "VDefpGetSurfaceEdgeBsps", wrapup );
  if(nContour == 0) goto wrapup;
  
  for(ii=0;ii<nContour;ii++)
  { 
    num = 0;
    BSmdistcvcv(prjCurve,edges[ii],&num,&par1,&par2,&pt1,&pt2,&min_dist,&rc);
    if (rc != BSSUCC) 
    {
      __DBGpr_com(" BSmdistcvcv function failed");
      continue;
    }
    if(min_dist < chtol) 
    {
      retFlag = 1;
      *location = EDGE;
      __DBGpr_com("curve is on the edge");
      goto wrapup;
    }
  }
  __DBGpr_com("curve is on the face");
  *location = FACE;
  retFlag = 1;
  
 wrapup:
  
  _FREE(edges_cont);
  for(ii=0;ii<nContour;ii++) _FREE(edges[ii]);
  _FREE(par1);
  _FREE(par2);
  _FREE(pt1);
  _FREE(pt2);
  
  return retFlag;
  
}
end implementation VSplate ;

