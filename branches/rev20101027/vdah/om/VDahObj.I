/* $Id: VDahObj.I,v 1.3 2001/01/11 16:34:31 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDahObj.I
 *
 * Description:	Object Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDahObj.I,v $
 *      Revision 1.3  2001/01/11 16:34:31  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:58  art
 *      s merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/03/29  14:49:02  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/17  18:45:54  pinnacle
# VDsupEtc
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 * 03/28/00  ah      Raised occurance name limit from 1000 to 10000
 ***************************************************************************/
class implementation ACncpx;

#include "VDmaster.h"

extern GRclassid OPP_ASsource_class_id;
extern GRclassid OPP_ACpretend_class_id;

IGRstat VDahGetObjectEnv (TGRid      *srcID, TGRobj_env *objOE);
IGRstat VDahMakeSource   (TGRobj_env *objOE, TGRid      *srcID);
IGRstat VDahGetObjectDesc(TGRid *objID, IGRchar *desc);
IGRstat	VDahGetNextOccName(
  IGRchar *occPrefix, 
  IGRchar *occPath, 
  IGRchar *occName
);

/* --------------------------------------------
 * Utility for extracting obj_env from source
 */
IGRstat VDahGetObjectEnv(TGRid *objID, TGRobj_env *objOE)
{
  IGRstat   retFlag = 0;
  IGRstat   sts;
  GRclassid classID;

  // Init
  objOE->obj_id.objid = NULL_OBJID;

  /* Filter Nulls */
  if ((objID == NULL) ||
      (objID->objid == 0) || 
      (objID->objid == NULL_OBJID)
  ) goto wrapup;

  /* Check to see if ASsource or ACpretend */
  classID = 0;
  om$get_classid(
    objid = objID->objid,
    osnum = objID->osnum,
    p_classid = &classID
  );
  sts = om$is_ancestry_valid(
    subclassid   = classID,
    superclassid = OPP_ASsource_class_id
  );
  if (sts == OM_S_SUCCESS) goto have_source;
  sts = om$is_ancestry_valid(
    subclassid   = classID,
    superclassid = OPP_ACpretend_class_id
  );
  if (sts == OM_S_SUCCESS) goto have_source;

  // Object is in the same os and needs no translation
  objOE->obj_id = *objID;
  gr$get_module_env(buffer = &objOE->mod_env);
  retFlag = 1;
  goto wrapup;

have_source:

  // Get the object
  sts = om$send(
    msg	= message NDnode.ASreturn_go(
      &objOE->obj_id,
      &objOE->mod_env.md_env.matrix_type,
       objOE->mod_env.md_env.matrix),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum 
  );
  __CheckSTS(sts,"Problem with ASreturn_go",wrapup);

  // Set md_id to the reference file
  objOE->mod_env.md_id.osnum = objOE->obj_id.osnum;
  sts = ex$get_modid(
    mod_osnum =  objOE->mod_env.md_id.osnum, 
    mod_id    = &objOE->mod_env.md_id.objid
  );
  __CheckSTS(sts,"Problem with get_modid",wrapup);
 
  retFlag = 1;
wrapup:
  return retFlag;
}

/* ------------------------------------------
 * Source a graphic object
 * Always creates in active space
 */
IGRstat VDahMakeSource(
  TGRobj_env *objOE,
  TGRid      *srcID
)
{
  IGRstat retFlag = 0;
  TGRid   curID;

  // Init
  if (srcID == NULL) goto wrapup;
  srcID->objid = NULL_OBJID;

  // Arg check
  if ((objOE == NULL) || (objOE->obj_id.objid == NULL_OBJID)) goto wrapup;

  // Active os
  ex$get_cur_mod(id = &curID.objid, osnum = &curID.osnum);

  // Source it
  as$make_source( 
    go_grid =  objOE->obj_id,
    mod_env = &objOE->mod_env,
    as_os   =  curID.osnum,
    as_grid =  srcID
  );
  if (srcID->objid == NULL_OBJID) goto wrapup;
  
  retFlag = 1;
wrapup:
  return retFlag;
}

/* -------------------------------------------------------
 * Object description for the form
 */
IGRstat VDahGetObjectDesc(TGRid *objID, IGRchar *desc)
{
  IGRstat retFlag = 0;
  IGRlong msg;
  IGRchar *pnt;
  TGRid   goID;

  *desc = 0;
  if ((objID == NULL) || 
      (objID->objid == 0) || 
      (objID->objid == NULL_OBJID)
  ) goto wrapup;

  om$send(
    msg = message GRgraphics.GRgetname(&msg,desc),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );
  if (*desc != 0) {
    pnt = strrchr(desc,':');
    if (pnt) strcpy(desc,pnt+1);
    retFlag = 1;
    goto wrapup;
  }

  goID.objid = NULL_OBJID;
  om$send(
    msg = message NDnode.ASreturn_go(&goID,NULL,NULL),
    senderid = NULL_OBJID,
    targetid = objID->objid,
    targetos = objID->osnum
  );

  if (goID.objid != NULL_OBJID) {

    om$send(msg = message GRgraphics.GRgetname(&msg,desc),
      senderid = NULL_OBJID,
      targetid = goID.objid,
      targetos = goID.osnum
    );

    if (*desc != 0) {
      pnt = strrchr(desc,':');
      if (pnt) strcpy(desc,pnt+1);
      retFlag = 1;
      goto wrapup;
    }
  }

  // Last try
  vd$get_name(obj = objID, name = desc);

  // Give up
  if (*desc == 0) strcpy(desc,"Defined");

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Wrapper to get active symbology
 */
IGRstat VDahGetActiveSymbology(TGRsymbology *symb)
{
  gr$get_active_display(buffer = &symb->display_attr);
  gr$get_active_level  (buffer = &symb->level);

  return 1;
}
/* -----------------------------------------------
 * Wrapper to set active symbology
 */
IGRstat VDahSetActiveSymbology(TGRsymbology *symb)
{
  gr$put_active_display(buffer = &symb->display_attr);
  gr$put_active_level  (buffer = &symb->level);

  return 1;
}

/* ---------------------------------------------------
 * Next available occ name
 */
IGRstat	VDahGetNextOccName(
  IGRchar *occPrefix, 
  IGRchar *occPath, 
  IGRchar *occName
)
{
  IGRstat retFlag = 0;

  IGRint  i;
  TGRid   objID;
  IGRchar path[DI_PATH_MAX];
  IGRchar full[DI_PATH_MAX];

  IGRstat sts;

  // Init
  if (occName) *occName = 0;
  if (occPath) *occPath = 0;

  // Use current dir
  di$pwd(dirname = path);

  // Bump from 1000 to 10000 for trouble shooting
  for(i = 1; i < 10000; i++) {

    sprintf(full,"%s:%s_%003d",path,occPrefix,i);

    sts = di$translate ( 
      objname = full,
      p_objid = &objID.objid,
      p_osnum = &objID.osnum 
    );
    if (sts != DIR_S_SUCCESS) {
      if (occPath) strcpy (occPath,full);
      if (occName) sprintf(occName,"%s_%003d",occPrefix,i);
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

end implementation ACncpx;

