/* $Id: VDsaObj.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsa/VDsaObj.I
 *
 * Description: Object Information
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaObj.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/17  12:59:30  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/16/98  ah      Creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDbt.h"
#include "VDsaProto.h"

#include "VDobj.h"

/* ------------------------------------------------------
 * Give Struct OBJ Interface
 */
IGRstar VDsaGiveStructureOBJ(TGRobj_env  *objOE,
			     IGRchar     *attrName,
			     Tret_struct *attrData)
{
  IGRstat retFlag = 0;

  IGRchar data[1024];

  TGRsymbology symb;

  // Init
  *data = 0;

  // vdobj$Print(objOE = objOE);
  
  // Objid
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_OBJID)) {

    attrData->type = text_type;
    sprintf(attrData->var.text_st.text_string,"%d",objOE->obj_id.objid);

    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // Classname
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_CLASS)) {

    vdobj$Get(objOE = objOE, className = data);
    
    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string,data);

    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // Category
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_CATEGORY)) {

    vdobj$Get(objOE = objOE, category = data);
    
    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string,data);

    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // Object Name
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_NAME)) {

    vdobj$Get(objOE = objOE, objName = data);
    
    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string,data);
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // Object Path
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_PATH)) {

    vdobj$Get(objOE = objOE, objPath = data);
    
    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string,data);

    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // Macro name
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_MAC_NAME)) {

    vdobj$Get(objOE = objOE, macName = data);
    
    attrData->type = text_type;
    strcpy(attrData->var.text_st.text_string,data);
    
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // Object Layer
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_LAYER)) {

    vdobj$Get(objOE = objOE, symb = &symb);
    
    attrData->type = double_type;
    attrData->var.root_pm_st.value = (IGRdouble)symb.level;
    
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // Object Color
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_COLOR)) {

    vdobj$Get(objOE = objOE, symb = &symb);
    
    attrData->type = double_type;
    attrData->var.root_pm_st.value = (IGRdouble)symb.display_attr.color;
    
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // Object Weight
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_WEIGHT)) {

    vdobj$Get(objOE = objOE, symb = &symb);
    
    attrData->type = double_type;
    attrData->var.root_pm_st.value = (IGRdouble)symb.display_attr.weight;
    
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

  // Object Style
  if (!strcmp(attrName,VDSA_KEY_SA_OBJ_STYLE)) {

    vdobj$Get(objOE = objOE, symb = &symb);
    
    attrData->type = double_type;
    attrData->var.root_pm_st.value = (IGRdouble)symb.display_attr.style;
    
    retFlag = OM_S_SUCCESS;
    goto wrapup;
    
  }

wrapup:
  return retFlag;
}

end implementation VDbtBase;





