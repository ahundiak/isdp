/* $Id: VSbevelAttr.I,v 1.1 2001/01/17 00:07:23 ramarao Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vsedge/VSbevelAttr.I
 *
 * Description: Some Misc Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbevelAttr.I,v $
 *      Revision 1.1  2001/01/17 00:07:23  ramarao
 *      *** empty log message ***
 *
# Revision 1.1  2000/05/23  15:04:12  pinnacle
# ylong
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/21/00  ylong   Creation, copied routines from VLunwMisc.I
 ***************************************************************************/

class implementation Root;

#include "VDmaster.h"
#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDsa.h"

#include "VSbevel.h"
#include "vsgeommacros.h"
#include "vdAPImacros.h"

static int traceFlag;

extern VDclassid OPP_VSedge3Datt_class_id;
extern VDclassid OPP_VSplate_class_id ;
extern VDclassid OPP_nci_macro_class_id;

from	ACrg_collect	import	ACget_named_attribute;


/* -----------------------------------------------------
 * Determines the plate thickness for a bevel
 * by navigating up to the plate itself.
 *
 * For some reason, some of the original bevels return
 * 0 for thickness when using the attribute collector
 */
IGRstat VSgetBevelThicknessOld(TGRid *bevelID, IGRdouble *thickness)
{
  IGRstat retFlag = 0;
  
  TGRobj_env plateOE;
  TGRobj_env parentOE;
  
  // Arg check
  if (thickness == NULL) goto wrapup;
  *thickness = NULL;
  if (bevelID == NULL)   goto wrapup;
  
  // Need the parent connected via the ACpretend and not the foot
  vdobj$GetParent(objID     = bevelID,
		  idx       = 0,
		  parentID  = &plateOE.obj_id);
  if (plateOE.obj_id.objid == NULL_OBJID) {
    printf("*** Unable to get plate parent for bevel \n");
    vdobj$Print(objID = bevelID);
    goto wrapup;
  }
  
  // Use the real parent for the matrix
  vdobj$GetTemplate(objID = bevelID,
		    nth   = 0,
		    templateOE = &parentOE);
  plateOE.mod_env = parentOE.mod_env;
  
  // Get the thickness
  vdsa$Get(objOE = &plateOE, name = "plate_thk", dbl = thickness);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Gets a single bevel attribute
 * From the old style bevel object
 */
IGRstat VSgetBevelAttributeOld(   TGRid     *bevelID, 
				  IGRchar   *a_name, 
				  IGRchar   *txt, 
				  IGRdouble *dbl)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRid colID; 
  TACrg_coll col;

  IGRchar name[40];
  IGRchar *p;
  
  IGRdouble delta;
  IGRdouble thickness;
  IGRdouble adj_thickness;
  
  // Init
  if (txt) *txt = 0;
  if (dbl) *dbl = 0.0;
  
  // Arg check
  if (a_name == NULL) goto wrapup;
  if ((bevelID == NULL) || (bevelID->objid == NULL_OBJID)) goto wrapup;

  // Get the collector
  vdchn$Get2(objID  = bevelID, 
             chnIDx = VDCHN_IDX_PARENT, 
             nth    = 2, 
             outID  = &colID);
  if (colID.objid == NULL_OBJID) goto wrapup;

  // name is case sensitive, lower is standard but edges use upper
  strcpy(name,a_name);
  for(p = name; *p; p++) {
    if ((*p >= 'a') && (*p <= 'z')) *p -= 32;
  }
  // Hack for stupid space
  if (!strcmp(name,"SPEC_NUMBER"))   strcpy(name,"SPEC NUMBER");
  if (!strcmp(name,"THICKNESS"))     strcpy(name,"T");
  if (!strcmp(name,"ADJ_THICKNESS")) strcpy(name,"DTHK");
  
  // Override for thickness
  if (!strcmp(name,"T")) {
    VSgetBevelThicknessOld(bevelID,&thickness);
    if (txt) sprintf(txt,"%f",thickness);
    if (dbl) *dbl = thickness;
    retFlag = 1;
    goto wrapup;
  }
  
  // Ask for the attribute
  memset(&col,0,sizeof(col));
  strcpy(col.name,name);

  sts = om$send(msg = message 
          ACrg_collect.ACget_named_attribute(&msg,&col),
          senderid = NULL_OBJID,
          targetid = colID.objid,
          targetos = colID.osnum);
  if (!(sts & msg & 1)) goto wrapup;

  // Extract value
  switch(col.desc.type) {
	   
  case AC_ATTRIB_DOUBLE:
    if (txt) sprintf(txt,"%f",col.desc.value.att_exp);
    if (dbl) *dbl = col.desc.value.att_exp;
    delta = col.desc.value.att_exp;

    //printf("%s '%f'\n",name,col.desc.value.att_exp);
    break;
    
  case AC_ATTRIB_TEXT: 
    if (txt)  strcpy(txt,col.desc.value.att_txt);
    if (dbl) *dbl = atof(col.desc.value.att_txt);

    //printf("%s '%s'\n",name,col.desc.value.att_txt);
    break;
    
  }

  /* --------------------------------------
   * Sometimes thickness is coming out as 0 
   * Ignore for now as the edge objects are
   * being replaced but navigate up to the plate if
   * this becomes a problem
   */
  if (strcmp(name,"DTHK")) {  
    retFlag = 1;
    goto wrapup;
  }
  
  // get the thickness then calculate the adjacent thickness
  VSgetBevelThicknessOld(bevelID,&thickness);
  adj_thickness = thickness - delta;
  
  if (txt) sprintf(txt,"%f",adj_thickness);
  if (dbl) *dbl = adj_thickness;

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------------
 * Gets a single bevel attribute, accepts either old or new
 */
IGRstar VSgetBevelAttribute(   TGRid     *bevelID, 
                               IGRchar   *a_name, 
                               IGRchar   *txt, 
                               IGRdouble *dbl)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  TGRid colID; 
  TACrg_coll col;

  IGRchar macName[40];
  
  IGRchar name[40];
  IGRchar *p;
  
  IGRint flag;
  
  IGRdouble thickx;
  IGRdouble thickness;
  IGRdouble adj_thickness;
  
  TGRobj_env plateOE;
  IGRint i;
  
  // Init
  if (txt) *txt = 0;
  if (dbl) *dbl = 0.0;
  
  // Arg check
  if (a_name == NULL) goto wrapup;
  if ((bevelID == NULL) || (bevelID->objid == NULL_OBJID)) goto wrapup;

  // See if old style
  vdobj$Get(objID = bevelID, macName = macName);
  if (!strcmp(macName,"VSedge3Datt")) {
    return VSgetBevelAttributeOld(bevelID,a_name,txt,dbl);
  }
  
  // Get the collector
  vdchn$Get2(objID  = bevelID, 
             chnIDx = VDCHN_IDX_PARENT, 
             nth    = 0, 
             outID  = &colID);
  if (colID.objid == NULL_OBJID) goto wrapup;

  // name is case sensitive, lower is standard but edges use upper
  strcpy(name,a_name);
  for(p = name; *p; p++) {
    if ((*p >= 'A') && (*p <= 'Z')) *p += 32;
  }
  
  // Map old names to new names
  flag = 0;
  if (!strcmp(name,"spec_number")) {
    strcpy(name,"bevel_type");
    flag = 1;
  }
  if (!strcmp(name,"spec number")) {
    strcpy(name,"bevel_type");
    flag = 1;
  }
  if (!strcmp(name,"process")) {
    strcpy(name,"process_type");
    flag = 1;
  }
  if (!strcmp(name,"allowance")) {
    strcpy(name,"stock_value");
    flag = 1;
  }
  if (!strcmp(name,"adj_thickness")) {
    if (!strcmp(macName,"EJ_Bevel")) {  
      strcpy(name,"adjacent_plate_thickness");
      flag = 1;
    }
  }
  
  // Just an attribute?
  if (flag == 1) {
    
    // Ask for the attribute
    memset(&col,0,sizeof(col));
    strcpy(col.name,name);

    sts = om$send(msg = message 
		  ACrg_collect.ACget_named_attribute(&msg,&col),
		  senderid = NULL_OBJID,
		  targetid = colID.objid,
		  targetos = colID.osnum);
    if (!(sts & msg & 1)) goto wrapup;

    // Extract value
    switch(col.desc.type) {
	   
      case AC_ATTRIB_DOUBLE:
	if (txt) sprintf(txt,"%f",col.desc.value.att_exp);
	if (dbl) *dbl = col.desc.value.att_exp;
	break;
    
      case AC_ATTRIB_TEXT: 
	if (txt)  strcpy(txt,col.desc.value.att_txt);
	if (dbl) *dbl = atof(col.desc.value.att_txt);

	// printf("%s '%s'\n",name,col.desc.value.att_txt);
	
	break;
    
    }
    retFlag = 1;
    goto wrapup;
    
  }
  
  // Must be either thickness of adjacent thickness
  if (strcmp(name,"thickness") && strcmp(name,"adj_thickness")) 
  {
    goto wrapup;
  }
  
  // Not rely on order here, macro is too scary, 
  // just look for two attached plates
  thickness     = 0.0;
  adj_thickness = 0.0;
  for(i = 1; 
      vdobj$GetTemplate(objID = bevelID, nth = i, templateOE = &plateOE);
      i++) {

    sts = vdobj$IsAncestryValid(objOE = &plateOE, superClassName = "VSplate");
    if (sts & 1) {
      vdsa$Get(objOE = &plateOE, name = "plate_thk", dbl = &thickx);
      if (thickness < .01)     thickness = thickx;
      else                 adj_thickness = thickx;
    }
  }

  // Return the desired one
  if (!strcmp(name,"thickness")) thickx = thickness;
  else                           thickx = adj_thickness;

  if (txt) sprintf(txt,"%f",thickx);
  if (dbl) *dbl = thickx;

  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/**************************************************************************
 * Check if a bevel macro already exists 
 */
IGRboolean VScheckExistingBevel( TGRobj_env *crvOE, TGRobj_env *plateOE )
{
	IGRboolean	ret = FALSE ;
	IGRstat		sts ;
	IGRlong		msg ;
	IGRint		i ;
        IGRchar		macName[128], msgStr[128] ;
        GRclassid	classid ;
        IGRint		foundCnt = 0 ;
        TGRid		*foundIDs = NULL ;
        TGRid		srcID ;
	TGRobj_env	objOE ;
	IGRdouble	u1, u2 ;
	IGRchar		
	*str="EJ_Bevel not placed if a bevel already exists at the same edge";

struct  OM_sd_chanselect	chn ;

        macName[0] = '\0' ;
        msgStr[0] = '\0' ;

        // get channel
        sts = om$make_chanselect( channame      = "NDchildren.children" ,
                                  p_chanselect  = &chn ) ;
        if( !(sts & 1) ) {
                __DBGpr_com("om$make_chanselect failed") ;
                goto wrapup;
        }

        // get objs from the channel
        classid = OPP_nci_macro_class_id ;
        sts = VDGetGridsFromChan_of_Class (
                                        &msg,
                                        plateOE->obj_id, //srcID,
                                        &chn,
                                        classid,
                                        &foundCnt,
                                        &foundIDs ) ;

        for( i = 0; i < foundCnt; i = i+1 ) {
                GetMacroName ( foundIDs[i], macName, msgStr ) ;
                if(
                    !strcmp( macName, "Bevel"    ) ||
                    !strcmp( macName, "EJ_Bevel" ) ||
                    !strcmp( macName, "Fab_Stock") ||
                    !strcmp( macName, "VA_Bevel" ) )
			
                {
			objOE.obj_id.objid = NULL_OBJID ;
			sts = vd_$return_foot ( msg     = &msg,
						name	= "curve" ,
						objId   = &foundIDs[i] ,
						footId  = &objOE.obj_id ,
						footEnv	= &objOE.mod_env ) ;
			if( !(sts&msg&1) ) {
				goto wrapup ;
			}

			if( Get2crvsOverlap ( crvOE, &objOE, &u1, &u2 ) ) {
			     UI_status( str ) ;
			     ret = TRUE ;
                             goto wrapup ;
			}
                }
        }

wrapup:
        _FREE( foundIDs ) ;
        return ret ;
}

/*********************************************************************
 * Create an EJ_Bevel macro from information of object VSedge3Datt
 */
IGRlong	VScreateEJ_BevelFromVSedge3Datt( TGRid	*edgeID )
{
	IGRlong		ret = 0,  sts, msg ;
	TGRobj_env	objOEs[20] ;
	TGRobj_env	bvlMacOE, crvOE ;
	TGRid		tempID ;
	TACrg_coll	newAttrs[MAX_ATTR1] ;
	IGRint		i, attrCnt ;
	IGRdouble	thickness ;
	TGRbsp_curve	*bvlCrv = NULL ;
	TGRmd_env	env ;
	IGRdouble	dbl ;
	IGRchar		txt[128] ;

	gr$get_module_env (buffer = &env );

	// Get input plate for EJ_Bevel from edgeID
	objOEs[E_PLATE].obj_id.objid = NULL_OBJID ;
	objOEs[E_PLATE].mod_env = env ;
	vdobj$GetParent(objID     = edgeID,
			idx       = 0,
			parentID  = &objOEs[E_PLATE].obj_id);
	if( objOEs[E_PLATE].obj_id.objid == NULL_OBJID ) {
		printf("Unabel to get plate from edgeID\n") ; 
		goto wrapup ;
	}
	if( !vd_$is_ancestry_valid (	object  = &objOEs[E_PLATE].obj_id,
					classid = OPP_VSplate_class_id ) ) {
		goto wrapup;
	}

	// Get curve from 2nd parent of edgeID, it's an ACpretend
	objOEs[E_CURVE].obj_id.objid = NULL_OBJID ;
	objOEs[E_CURVE].mod_env = env ;
	vdchn$Get2 (	objID  = edgeID, 
			chnIDx = VDCHN_IDX_PARENT, 
			nth    = 1, 
			outID  = &objOEs[E_CURVE].obj_id);
	if (objOEs[E_CURVE].obj_id.objid == NULL_OBJID) goto wrapup;

	// Get curve geometry
	tempID.objid = NULL_OBJID ;
	sts = vd_$return_foot ( msg     = &msg,
				name	= "edge_3d" ,
				objId   = edgeID,
				footId  = &tempID ) ;
	if( !(sts&msg&1) ) {
		printf("Unable to get edge_3d\n") ;
		goto wrapup ;
	}
	vs$get_geometry(msg      = &msg ,
			grobjId  = &tempID ,
			grobjEnv = &env ,
			geometry = &bvlCrv ) ;
	if( !(msg&1) ) {
		goto wrapup ;
	}

	// Check if a bevel macro already exists
	crvOE.obj_id = tempID ;
	crvOE.mod_env = env ;
	if( VScheckExistingBevel( &crvOE, &objOEs[E_PLATE] ) ) {
		goto wrapup ;
	}


	// Get label point
	objOEs[E_POINT].obj_id.objid = NULL_OBJID ;
	sts = GetLabelPoint (   &objOEs[E_PLATE],
				bvlCrv,
				newAttrs[E_offset_value].desc.value.att_exp ,
				&objOEs[E_POINT] ) ;
	if( !sts ) {
		printf("GetLabelPoint failed to get E_POINT\n") ;
		goto wrapup ;
	}

	// Get attributes
	if( !VSgetBevelAttribute(edgeID, "DTHK", NULL, &dbl) ) {
		goto wrapup ;
	}
	if( !VSgetBevelAttribute(edgeID, "T", NULL, &thickness) ) {
		goto wrapup ;
	}
	newAttrs[E_adjacent_plate].desc.type = 2 ;
	strcpy( newAttrs[E_adjacent_plate].name, "adjacent_plate_thickness") ;
	newAttrs[E_adjacent_plate].desc.value.att_exp = thickness - dbl ;

	if( !VSgetBevelAttribute(edgeID, "ALLOWANCE", NULL, &dbl) ) {
		goto wrapup ;
	}
	newAttrs[E_stock_value].desc.type = 2 ;
	strcpy( newAttrs[E_stock_value].name, "stock_value") ;
	newAttrs[E_stock_value].desc.value.att_exp = dbl ;

	if( !VSgetBevelAttribute(edgeID, "SPEC NUMBER", txt, NULL) ) {
		goto wrapup ;
	}
	newAttrs[E_bevel_type].desc.type = 1 ;
	strcpy( newAttrs[E_bevel_type].name, "bevel_type") ;
	strcpy( newAttrs[E_bevel_type].desc.value.att_txt, txt ) ;

	if( !VSgetBevelAttribute(edgeID, "PROCESS", txt, NULL) ) {
		goto wrapup ;
	}
	newAttrs[E_process_type].desc.type = 1 ;
	strcpy( newAttrs[E_process_type].name, "process_type") ;
	strcpy( newAttrs[E_process_type].desc.value.att_txt, txt ) ;

	newAttrs[E_macro_type].desc.type = 1 ;
	strcpy( newAttrs[E_macro_type].name, "macro_type") ;
	strcpy( newAttrs[E_macro_type].desc.value.att_txt,"1 Plate");

	newAttrs[E_label_flag].desc.type = 1 ;
	strcpy( newAttrs[E_label_flag].name, "label_flag") ;
	strcpy( newAttrs[E_label_flag].desc.value.att_txt, "00") ;

	newAttrs[E_offset_value].desc.type = 2 ;
	strcpy( newAttrs[E_offset_value].name, "offset_value") ;
	newAttrs[E_offset_value].desc.value.att_exp = 0.0 ;

	// Create attribute collector
	objOEs[E_ATTR].obj_id.objid = NULL_OBJID ;
	if( !CreateCollector(newAttrs, MAX_ATTR1, "", &objOEs[E_ATTR]) ) {
		goto wrapup ;
	}
	
#ifdef DEBUG
	printf("objOEs[E_PLATE].obj_id: [%d, %d]\n", 
		objOEs[E_PLATE].obj_id.objid, objOEs[E_PLATE].obj_id.osnum ) ;
	printf("objOEs[E_CURVE].obj_id: [%d, %d]\n", 
		objOEs[E_CURVE].obj_id.objid, objOEs[E_CURVE].obj_id.osnum ) ;
	printf("objOEs[E_POINT].obj_id: [%d, %d]\n", 
		objOEs[E_POINT].obj_id.objid, objOEs[E_POINT].obj_id.osnum ) ;
	printf("objOEs[E_ATTR].obj_id: [%d, %d]\n", 
		objOEs[E_ATTR].obj_id.objid, objOEs[E_ATTR].obj_id.osnum ) ;
#endif

	// Create EJ_Bevel macro
	bvlMacOE.obj_id.objid = NULL_OBJID ;
	sts = CreateBevelMacro("EJ_Bevel", objOEs, MAX_TEMP1,"00", &bvlMacOE);
	if( !sts || bvlMacOE.obj_id.objid == NULL_OBJID ) {
                printf("CreateEJ_BevelMacro failed\n");
                goto wrapup ;
        }

	ret = 1 ;
wrapup:
	_FREE( bvlCrv ) ;
	return ret ;
}

/*************************************************************************
 * Get all VSedge3Datt objects and create EJ_Bevel's correspondingly
 */
IGRlong VStransAllEdgesToEJ_Bevel( IGRlong *msg )
{
IGRlong         ret = 0 ;
IGRlong		sts ;
IGRint          i, index, nb_obj = 0 ;
GRspacenum      cur_osnum;
GRclassid       classid ;
GRobjid		*obj_list = NULL  ;
TGRid		edgeID ;

	*msg = 1 ;

	//printf(">> Enter VStransEdgeToEJ_Bevel <<\n");

        ex$get_cur_mod ( osnum = &cur_osnum ) ;

        sts = om$get_classid (	classname = "VSedge3Datt" ,
				p_classid = &classid);
	if( !(sts&1) ) {
		printf("om$get_classid failed\n");
		goto wrapup ;
	}

        sts = VDpms_findall_ancestryobjects (
                                        cur_osnum,
                                        1, 
                                        &classid, 
                                        &nb_obj, 
                                        NULL);
	if( !(sts&1) || !nb_obj ) goto wrapup ;

	if( !(obj_list = _CALLOC( nb_obj, GRobjid )) ) {
		printf("_CALLOC failed for obj_list\n") ;
		goto wrapup ;
	}

	sts = VDpms_findall_ancestryobjects(
					cur_osnum,
					1, 
					&classid, 
					&nb_obj, 
					obj_list);
	if( !(sts&1) || !nb_obj ) goto wrapup ;

	edgeID.osnum = cur_osnum ;
	edgeID.objid = NULL_OBJID ;
	for(i = 0; i < nb_obj; i++ ) {
		edgeID.objid = obj_list[i] ;
		VScreateEJ_BevelFromVSedge3Datt( &edgeID ) ;
	}


	ret = 1 ;
wrapup:
	_FREE( obj_list ) ;
	//printf(">> Exit VStransEdgeToEJ_Bevel <<\n");
	return ret ;
}


end implementation Root;

