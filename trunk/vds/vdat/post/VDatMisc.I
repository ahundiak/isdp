class implementation VDatBase;

#include "VDris.h"

IGRstar VDatPostGetAttrAt(IGRint i, IGRint *index, IGRchar *name);
IGRstar VDatPostGetAttrIndex(IGRchar *name, IGRint *index);


IGRstar VDatPostDblAttr(
  IGRchar  *name, 
  IGRdouble value, 
  IGRchar  *names, 
  IGRchar  *values
);

IGRstar VDatPostProcAttr(
  IGRchar   *name, 
  VDprcAttr *info, 
  IGRchar   *names, 
  IGRchar   *values
);

/* -----------------------------------------------
 * Test to see if the flds contain an attribute
 * name which requires generating a VDprcAttr
 * 1 - Need it
 * 0 - Don't need
 */
IGRstar VDatPostProcAttrsTest(
  TVDatFld *flds,
  IGRint    fldCNT
)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRint  i;

  // Cycle through looking for a hit
  for(i = 0; i < fldCNT; i++) {
    sts = VDatPostGetAttrIndex(flds[i].name,NULL);
    if (sts & 1) {
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Post the values from VDprcAttr based on
 * having the names defined in the fld list
 * This field list will have been generated from
 * the rdb table itself allow the user to select
 * exactly which attributes to post
 */
IGRstar VDatPostProcAttrs(
  TVDatFld *flds,
  IGRint    fldCNT,
  VDprcAttr *info,
  IGRchar   *names, 
  IGRchar   *values
)
{
  IGRstat retFlag = 0;
  IGRint  i;

  for(i = 0; i < fldCNT; i++) {
    VDatPostProcAttr(flds[i].name,info,names,values);
  }

  retFlag = 1;
  return retFlag;
}

/* -----------------------------------------------
 * Add attribute to names/values buffers
 * 1 - For normal return
 * 3 - Got here but names or values were NULL
 * 0 - Error
 */
IGRstar VDatPostDblAttr(IGRchar *name, IGRdouble value, IGRchar *names, IGRchar *values)
{
  IGRstat retFlag = 0;
  IGRchar buf[128];

  // Error
  retFlag = 0;
  if (name == NULL) goto wrapup;

  // OK
  retFlag = 3;
  if ((names == NULL) || (values == NULL)) goto wrapup;

  // Normal
  strcat(names,name);
  strcat(names,",");

  sprintf(buf,"%f,",value);
  strcat(values,buf);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Filter the given attr name and if it matched
 * a VDprocAttr field then post the field
 */
IGRstar VDatPostProcAttr(
  IGRchar   *name, 
  VDprcAttr *info, 
  IGRchar   *names, 
  IGRchar   *values
)
{
  IGRstat   retFlag = 0;
  IGRstat   sts;

  IGRint    index;
  IGRdouble *dbls;

  // Arg check
  if ((name == NULL) || (info == NULL)) goto wrapup;

  // Pretend the strucutre is an array of doubles
  dbls = (IGRdouble*)info;

  // Get the index
  sts = VDatPostGetAttrIndex(name,&index);
  if (!(sts & 1)) goto wrapup;

  retFlag = VDatPostDblAttr(name,dbls[index],names,values);

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Given an attribute name, returns the
 * index if in the predefined list
 * returns 0 if index not found
 * Can pass a null to test if attr exists
 */
IGRstar VDatPostGetAttrIndex(IGRchar *name, IGRint *index)
{
  IGRstat retFlag = 0;
  IGRint  indexL;
  IGRint  i;
  IGRchar nameL[32];

  // Arg check
  if (index) *index = -1;
  if (name == NULL) goto wrapup;

  // Just check each name
  for(i = 0; VDatPostGetAttrAt(i,&indexL,nameL); i++) {
    if (!(strcmp(name,nameL))) {
      if (index) *index = indexL;
      retFlag = 1;
      goto wrapup;
    }
  } 
wrapup:
  return retFlag;
}

/* --------------------------------------
 * Pretends to be a a global static array
 * mapping rdb column names to indexes
 * in VDprcAttr
 */
IGRstar VDatPostGetAttrAt(IGRint i, IGRint *index, IGRchar *name)
{
  IGRstat retFlag = 1;
  IGRint  indexL;
  IGRchar nameL[32];

  if (index == NULL) index = &indexL;
  if (name  == NULL) name  =  nameL;

  switch(i) {
    case  0: *index =  0; strcpy(name,VD_N_DENSITY_AN);  return retFlag;
    case  1: *index =  1; strcpy(name,VD_N_WEIGHT_DB);   return retFlag;
    case  2: *index =  2; strcpy(name,VD_N_VOLUME_DB);   return retFlag;
    case  3: *index =  3; strcpy(name,VD_N_SURFAREA_AN); return retFlag;
    case  4: *index =  4; strcpy(name,VD_N_COG_X_DB);    return retFlag;
    case  5: *index =  5; strcpy(name,VD_N_COG_Y_DB);    return retFlag;
    case  6: *index =  6; strcpy(name,VD_N_COG_Z_DB);    return retFlag;
    case  7: *index =  7; strcpy(name,VD_N_SIZE_X_DB);   return retFlag;
    case  8: *index =  8; strcpy(name,VD_N_SIZE_Y_DB);   return retFlag;
    case  9: *index =  9; strcpy(name,VD_N_SIZE_Z_DB);   return retFlag;

    case 10: *index = 10; strcpy(name,VD_N_RANGE_X1_DB); return retFlag;
    case 11: *index = 11; strcpy(name,VD_N_RANGE_Y1_DB); return retFlag;
    case 12: *index = 12; strcpy(name,VD_N_RANGE_Z1_DB); return retFlag;
    case 13: *index = 13; strcpy(name,VD_N_RANGE_X2_DB); return retFlag;
    case 14: *index = 14; strcpy(name,VD_N_RANGE_Y2_DB); return retFlag;
    case 15: *index = 15; strcpy(name,VD_N_RANGE_Z2_DB); return retFlag;

    case 16: *index = 16; strcpy(name,VD_N_MOI_X_DB);  return retFlag;
    case 17: *index = 17; strcpy(name,VD_N_MOI_Y_DB);  return retFlag;
    case 18: *index = 18; strcpy(name,VD_N_MOI_Z_DB);  return retFlag;
    case 19: *index = 19; strcpy(name,VD_N_MOI_X2_DB); return retFlag;
    case 20: *index = 20; strcpy(name,VD_N_MOI_Y2_DB); return retFlag;
    case 21: *index = 21; strcpy(name,VD_N_MOI_Z2_DB); return retFlag;

    case 22: *index = 22; strcpy(name,VD_N_LOCATION_X_DB); return retFlag;
    case 23: *index = 23; strcpy(name,VD_N_LOCATION_Y_DB); return retFlag;
    case 24: *index = 24; strcpy(name,VD_N_LOCATION_Z_DB); return retFlag;

    case 25: *index = 25; strcpy(name,VD_N_PRIMARY_AXIS_X_DB);   return retFlag;
    case 26: *index = 26; strcpy(name,VD_N_PRIMARY_AXIS_X_DB);   return retFlag;
    case 27: *index = 27; strcpy(name,VD_N_PRIMARY_AXIS_X_DB);   return retFlag;
    case 28: *index = 28; strcpy(name,VD_N_SECONDARY_AXIS_X_DB); return retFlag;
    case 29: *index = 29; strcpy(name,VD_N_SECONDARY_AXIS_X_DB); return retFlag;
    case 30: *index = 30; strcpy(name,VD_N_SECONDARY_AXIS_X_DB); return retFlag;
    case 31: *index = 31; strcpy(name,VD_N_THIRD_AXIS_X_DB);     return retFlag;
    case 32: *index = 32; strcpy(name,VD_N_THIRD_AXIS_X_DB);     return retFlag;
    case 33: *index = 33; strcpy(name,VD_N_THIRD_AXIS_X_DB);     return retFlag;
  }

  retFlag = 0;
  return retFlag;
}

IGRstar VDatPOSTGetPostAttrAt(IGRint i, IGRchar *name);

/* --------------------------------------
 * Checks to see if name is a predefined
 * post attribute
 */
IGRstar VDatPOSTIsPostAttr(IGRchar *name)
{
  IGRstat retFlag = 0;
  IGRint  i;

  IGRchar nameL[32];

  for(i = 0; VDatPOSTGetPostAttrAt(i,nameL); i++) {
    if (!strcmp(name,nameL)) {
      retFlag = 1;
      goto wrapup;
    }
  }

wrapup:
  return retFlag;
}
 
/* --------------------------------------
 * Pretends to be a a global static array
 * Of predefined columns names
 * used to control posting
 *
 * 09/27/1998 Store comp_path internally, set it to piece path
 * To allow later reconnection
 */
IGRstar VDatPOSTGetPostAttrAt(IGRint i, IGRchar *name)
{
  IGRstat retFlag = 1;
  IGRchar nameL[32];

  if (name  == NULL) name  =  nameL;

  switch(i) {
    case  0: strcpy(name,"file_key");          return retFlag;

    case  1: strcpy(name,"set_key");           return retFlag;
    case  2: strcpy(name,VDAT_ATTR_SET_NAME);  return retFlag;
    case  3: strcpy(name,VDAT_ATTR_SET_TYPE);  return retFlag;

    case  4: strcpy(name,"assembly_cat");      return retFlag;
    case  5: strcpy(name,"assembly_nam");      return retFlag;
    case  6: strcpy(name,"assembly_ver");      return retFlag;
    case  7: strcpy(name,"assembly_key");      return retFlag;

    case  8: strcpy(name,"comp_seqno");        return retFlag;
  //case  9: strcpy(name,"comp_path");         return retFlag;
    case  9: strcpy(name,VDAT_ATTR_COMP_NAME); return retFlag;

    case 10: strcpy(name,"leaf_seqno");     return retFlag;
    case 11: strcpy(name,"leaf_class");     return retFlag;
    case 12: strcpy(name,"leaf_key");       return retFlag;
    case 13: strcpy(name,"leaf_cat");       return retFlag;
    case 14: strcpy(name,"leaf_nam");       return retFlag;
    case 15: strcpy(name,"leaf_ver");       return retFlag;

    case 16: strcpy(name,"node_seqno");     return retFlag;
    case 17: strcpy(name,"node_cat");       return retFlag;
    case 18: strcpy(name,"node_nam");       return retFlag;
    case 19: strcpy(name,"node_ver");       return retFlag;
    case 20: strcpy(name,"node_class");     return retFlag;

    case 21: strcpy(name,VDAT_ATTR_NODE_ORDER);    return retFlag;
    case 22: strcpy(name,"node_qty");              return retFlag;
    case 23: strcpy(name,VDAT_ATTR_NODE_PATH);     return retFlag;
    case 24: strcpy(name,VDAT_ATTR_NODE_TYPE);     return retFlag;

    case 25: strcpy(name,VDAT_ATTR_PARENT_PATH);   return retFlag;
    case 26: strcpy(name,VDAT_ATTR_PARENT_SEQNO);  return retFlag;
   
  }
  retFlag = 0;
  return retFlag;
}

end implementation VDatBase;

