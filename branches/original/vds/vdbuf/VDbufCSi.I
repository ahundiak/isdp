/* $Id: VDbufCSi.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbuf/VDbufCSi.I
 *
 * Description: CS Buffer Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbufCSi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  2000/03/24  15:38:56  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/17/00  ah      Creation
 ***************************************************************************/

class implementation VDbufCS;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDdir.h"

#include "csdef.h"
#include "grcoordsys.h"

static int traceFlag;

/* ------------------------------------------------------------
 * Creates a directory with a -p option
 * i.e. it makes all the intermediate directories as well
 */
IGRstat VDdirMakeDir(IGRchar *dirPath)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRstat flag;
  
  IGRchar *p,*e;
  IGRchar dirPathx[1024];
  
  // Arg check
  if ((dirPath == NULL) || (*dirPath == 0)) goto wrapup;
  
  // In many cases, works just fine
  sts = di$mkdir(dirname = dirPath);
  switch(sts) {
  case  DIR_S_SUCCESS:
  case  DIR_E_DIR_DUP:
    retFlag = 1;
    goto wrapup;

  case DIR_E_SYNTAX:
  case DIR_E_OVFLOW:
  case DIR_E_ABORT:
    goto wrapup;

  }

  /* sts code is not listed in mkdir but
   * it indicates that missing an intermediate directory
   * start at the end and work up */
  strcpy(dirPathx,dirPath);
  e = dirPathx + strlen(dirPathx);
  flag = 1;
  while(flag) {

    // Drop last directory
    p = strrchr(dirPathx,':');
    if (p == NULL)     goto wrapup;
    if (p == dirPathx) goto wrapup;
    *p = 0;

    // Create
    sts = di$mkdir(dirname = dirPathx);

    switch(sts) {
    case  DIR_S_SUCCESS:
    case  DIR_E_DIR_DUP:
      flag = 0;
    }
  }
  
  // Now chain forward and create the rest
  while(p < e) {
    *p = ':';
    di$mkdir(dirname = dirPathx);
    while(*p) p++;
  }

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------
 * Given the path of a model object, return it
 */
IGRstat VDbufGetModelObjectFromPath(IGRchar *modelPath, TGRobj_env *modelOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  TGRmd_env curEnv;
  IGRchar   curPath[1024];
  IGRchar  *p;
  
  
  // Arg check
  if (modelOE == NULL) goto wrapup;
  modelOE->obj_id.objid = NULL_OBJID;
  if (modelPath == NULL) goto wrapup;

  // Want current stuff
  gr$get_module_env(buffer = &curEnv);
  
  // Might be in current file
  sts = di$translate (objname = modelPath,
                      p_objid = &modelOE->obj_id.objid,
                      p_osnum = &modelOE->obj_id.osnum);

  if (sts != DIR_S_SUCCESS) {
    
    // Check in reference file
    di$give_pathname(osnum = curEnv.md_id.osnum, pathname = curPath);
    DIstrcat(curPath,"ref");
    DIstrcat(curPath,modelPath+1);
    
    sts = di$translate (objname = curPath,
			p_objid = &modelOE->obj_id.objid,
			p_osnum = &modelOE->obj_id.osnum);

    if (sts != DIR_S_SUCCESS) {

      // Give up
      modelOE->obj_id.objid = NULL_OBJID;
      goto wrapup;
      
    }
    
  }
  
  // Fixup enviroment, assume identity matrix
  modelOE->mod_env = curEnv;
  modelOE->mod_env.md_id.osnum = modelOE->obj_id.osnum;
  ex$get_modid(mod_osnum =  modelOE->mod_env.md_id.osnum,
	       mod_id    = &modelOE->mod_env.md_id.objid);
 
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}
  
/* ------------------------------------------------------------
 * Get the attached model object
 */
IGRstat VDbufCSGetModelObject(TGRobj_env *csOE, TGRobj_env *modelOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar    csPath[1024];
  IGRchar modelPath[1024];
  IGRchar *p;
  
  // Arg check
  if (modelOE == NULL) goto wrapup;
  modelOE->obj_id.objid = NULL_OBJID;
  if (csOE == NULL) goto wrapup;

  // Get the model objects path
  *csPath = 0;
  sts = om$send(msg = message GRgraphics.
		GRgetname(&msg,csPath),
		senderid = NULL_OBJID,
		targetid = csOE->obj_id.objid,
		targetos = csOE->obj_id.osnum);
  if (*csPath == 0) goto wrapup;
  
  // Some hardcoding here
  p = strstr(csPath,":usr:");
  if (p == NULL) goto wrapup;
  p += 5;
  p = strchr(p,':');
  if (p == NULL) goto wrapup;
  strcpy(modelPath,p);
  
  p = strrchr(modelPath,':');
  if (p) *p = 0;

  VDbufGetModelObjectFromPath(modelPath,modelOE);
  if (modelOE->obj_id.objid == NULL_OBJID) goto wrapup;
    
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------------------
 * Creates a soft linked object
 */
IGRstat VDbufCSCreateFromModel(TGRobj_env *modelOE, 
			       IGRchar    *csType,
			       TGRobj_env *csOE)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  GRrange range;
  struct IGRlbsys lbsys;
  IGRboolean world = TRUE;
  TGRvg_construct cst;

  struct GRcs_construct cs_args;
  
  IGRint   i;

  TGRsymbology symb1,symb2;
  enum GRdpmode dpmode ;
  TGRid         dispID;
  
  IGRchar pwdPath  [1024];
  IGRchar occPath  [1024];
  IGRchar modelPath[1024];
  IGRchar occName  [32];
  
  IGRchar *p;
  
  // Say hi
  // traceFlag = 1;
  if (traceFlag) printf(">>> VDbufCreateCSFromModel\n");
  
  // Arg check
  if (csOE == NULL) goto wrapup;
  csOE->obj_id.objid = NULL_OBJID;
  if (csType  == NULL) goto wrapup;
  if (modelOE == NULL) goto wrapup;
  
  // Get the objects name
  *modelPath = 0;
  sts = om$send(msg = message GRgraphics.
		GRgetname(&msg,modelPath),
		senderid = NULL_OBJID,
		targetid = modelOE->obj_id.objid,
		targetos = modelOE->obj_id.osnum);
  if (*modelPath == 0) goto wrapup;
  
  // Strip off reference
  p = strstr(modelPath,":ref:");
  if (p) strcpy(modelPath,p+4);
  // printf("modelPath %s\n",modelPath);
  
  // Setup the geometry
  sts = om$send(msg = message GRgraphics.
		GRgetrang(&msg,
			  &modelOE->mod_env.md_env.matrix_type,
			   modelOE->mod_env.md_env.matrix,
			  &world,range),
		senderid = NULL_OBJID,
		targetid = modelOE->obj_id.objid,
		targetos = modelOE->obj_id.osnum);
  if (!(sts & msg & 1)) {
    printf("*** Unable to get range for\n");
    vdobj$Print(objOE = modelOE);
    goto wrapup;
  }
  memset(&lbsys,0,sizeof(lbsys));
  MAidmx(&msg,lbsys.matrix);
  for(i = 0; i < 3; i++) {
    lbsys.diag_pt1[i] =  range[i];
    lbsys.diag_pt2[i] =  range[i+3];
    lbsys.matrix[(i*4)+3] = (range[i] + range[i+3]) * 0.5;
  }

  // Adjust symbology
  VDahGetActiveSymbology(&symb1);
  VDahGetActiveSymbology(&symb2);

  symb2.level = 779;
  symb2.display_attr.color  = 3;
  symb2.display_attr.weight = 0;
  symb2.display_attr.style  = 0;
  VDahSetActiveSymbology(&symb2);

  // Init cst stuff
  VDsupInitCnst(&cst);

  // Current env
  gr$get_module_env(buffer = &csOE->mod_env);
  cst.env_info = &csOE->mod_env;

  // The geometry
  cst.geometry =   (IGRchar *)&lbsys;
  cst.class_attr = (IGRchar *)&cs_args;

  // Additonal info
  memset(&cs_args,0,sizeof(cs_args));
  cs_args.type = RECTANGULAR;
  
  // Current os
  csOE->obj_id.osnum = csOE->mod_env.md_id.osnum;
  
  // Doit
  if (traceFlag) printf("Constructing cs\n");
  sts = om$construct(osnum     = csOE->obj_id.osnum,
		     classname = "VDbufCS",
		     msg       = message GRgraphics.GRconstruct (&cst),
		     p_objid   = &csOE->obj_id.objid);

  // Cleanup
  VDahSetActiveSymbology(&symb1);
  dpmode = GRbd;
  om$send(msg = message GRgraphics.
	  GRdisplay(&msg,
		    &csOE->mod_env.md_env.matrix_type,
		     csOE->mod_env.md_env.matrix,
		    &dpmode,
		    &dispID),
	  senderid = NULL_OBJID,
	  targetid = csOE->obj_id.objid,
	  targetos = csOE->obj_id.osnum);

  // Adjust paths
  di$give_pathname(osnum = csOE->obj_id.osnum, pathname = occPath);
  DIstrcat(occPath,"usr");
  DIstrcat(occPath,csType);
  DIstrcat(occPath,modelPath+1);
  VDdirMakeDir(occPath);

  // Name the object
  di$pwd(dirname = pwdPath);
  di$cd (dirname = occPath);

  p = strrchr(occPath,':');
  if (p) p++;
  else p = csType;
  
  VDahGetNextOccName(p,NULL,occName);
  om$send(msg = message GRgraphics.
          GRputname(&msg,occName),
    senderid = NULL_OBJID,
    targetid = csOE->obj_id.objid,
    targetos = csOE->obj_id.osnum);
  
  di$cd(dirname = pwdPath);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VDbufCreateCSFromModel %d\n",retFlag);
  return retFlag;
  
}

/* ------------------------------------------------------------
 * Allow for prettier status messages
 */
method GRgetobjinfo(IGRlong *msg;
		    struct GRobj_info *info)
{
  IGRstat retFlag = OM_S_SUCCESS;
  
  TGRid   myID;
  IGRchar macName[64];

  // printf(">>> GRgetobjinfo\n");
  
  // Get me
  myID.objid = my_id;
  myID.osnum = OM_Gw_current_OS;

  // Just pass it up
  retFlag = om$send(msg = message GRgencs.
		    GRgetobjinfo(msg,info),
		    mode = OM_e_wrt_message,
		    targetid = myID.objid,
		    targetos = myID.osnum);

  return retFlag;
}

end implementation VDbufCS;









