class implementation Root;

#include "OMerrordef.h"
#include "APerrmac.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"
#include "vsdef.h"
#include "gr.h"
#include "growner.h"
#include "FElimits.h"

from   NDmacro import ACgive_structure;

extern IGRchar FE_DBG_MP;

/* *****************************H H H H H******************************* */
/* Doc: SFget_prop_name

   Abstract: Given a plate/stiffener, this macro will create corresponding
	     element property and will return its name.

   Arguments:
        IGRlong          *msg;   	 O   message return code
	struct GRobj_env *struct_elem;   I   Plate or Stiffener
	IGRchar		 *prop_name;     O   Property Name
	IGRchar		 *new_property;  O   = TRUE,  if it is a new property.
					     = FALSE, if property alreay exists.
   Return Status:
	OM_S_SUCCESS	Success
	OM_E_INVARG     Invalid arguments sent
*/
/* *****************************H H H H H******************************* */

IGRlong SFget_prop_name(    
		IGRlong          *msg,
                struct GRobj_env *struct_elem,
                IGRchar          *prop_name,
                IGRchar          *new_property )
{
  IGRlong     sts;
  GRclassid   cid;
  IGRchar     lcl_prop_name[FE_MAX_MPNAME_SIZE], newflag, VERBOSE=FE_DBG_MP;

  if( !msg || !struct_elem )
  {  
      printf("Error in Input Arguments");
      sts = OM_E_INVARG;
      goto quit;
  }

  sts  = OM_S_SUCCESS;
  *msg = MSSUCC;

  sts = om$get_classid (  osnum     = struct_elem->obj_id.osnum,
                          objid     = struct_elem->obj_id.objid,
                          p_classid = &cid);
  AP_ERR_HNDLR("om$get_classid",sts,1,VERBOSE, quit);

  if ( om$is_ancestry_valid(superclassname = "VSplate",
                            subclassid     = cid        ) == OM_S_SUCCESS )
  {
      /* Generate Plate property using the data from Database */
      sts = SFgenPlateProperty ( msg, struct_elem->obj_id, 
			&struct_elem->mod_env, lcl_prop_name, &newflag );
      AP_ERR_HNDLR("SFgenPlateProperty",sts,*msg,VERBOSE, quit);

  }
  else if ( om$is_ancestry_valid(superclassname = "VSbeam",
                                 subclassid     = cid        ) == OM_S_SUCCESS )
  {
      /* Generate Beam property using the data from Database */
      sts = SFgenBeamProperty ( msg, struct_elem->obj_id, 
					lcl_prop_name, &newflag );
      AP_ERR_HNDLR("SFgenBeamProperty",sts,*msg,VERBOSE, quit);

  }
  else
  {  
      printf("Error in Input Arguments for ");
      sts = OM_E_INVARG;
      goto quit;
  }

  if( prop_name    ) strcpy( prop_name, lcl_prop_name );
  if( new_property ) *new_property = newflag;

quit:
  return sts; 
}

/* *****************************H H H H H******************************* */
/* Doc: SFget_mat_name

   Abstract: Given a plate/stiffener, this function will create corresponding
	     material property and will return its name.

   Arguments:
        IGRlong          *msg;   	 O   message return code
	struct GRobj_env *struct_elem;   I   Plate or Stiffener
	IGRchar		 *mat_name;      O   Material Name
	IGRchar		 *new_material;  O   = TRUE,  if it is a new material.
					     = FALSE, if material alreay exists.
   Return Status:
	OM_S_SUCCESS	Success
	OM_E_INVARG     Invalid arguments sent
*/
/* *****************************H H H H H******************************* */

IGRlong SFget_mat_name(    
		IGRlong          *msg,
                struct GRobj_env *struct_elem,
                IGRchar          *mat_name,
                IGRchar          *new_material )
{
  IGRint      suc, index=-1;
  IGRlong     sts;
  GRclassid   cid;
  IGRchar     newflag, MatType[80], MatGrade[80], 
	      lcl_mat_name[FE_MAX_MPNAME_SIZE], VERBOSE=FE_DBG_MP;
  struct ret_struct     rs;

  if( !msg || !struct_elem )
  {  
      printf("Error in Input Arguments");
      sts = OM_E_INVARG;
      goto quit;
  }

  sts  = OM_S_SUCCESS;
  *msg = MSSUCC;

  sts = om$get_classid (  osnum     = struct_elem->obj_id.osnum,
                          objid     = struct_elem->obj_id.objid,
                          p_classid = &cid);
  AP_ERR_HNDLR("om$get_classid",sts,1,VERBOSE, quit);

  if ( ( om$is_ancestry_valid(superclassname = "VSplate",
                              subclassid     = cid        ) == OM_S_SUCCESS)
    || ( om$is_ancestry_valid(superclassname = "VSbeam",
                              subclassid     = cid        ) == OM_S_SUCCESS) )
  {
      /* get the material type */
      sts = om$send( msg = message NDmacro.ACgive_structure(
                                        &suc, &index, VS_K_prMatTypAttr, &rs,
                                        &struct_elem->mod_env ),
			senderid = NULL_OBJID,
                        targetid = struct_elem->obj_id.objid,
                        targetos = struct_elem->obj_id.osnum );
      AP_ERR_HNDLR("NDmacro.ACgive_structure",sts,suc,VERBOSE, quit);
      strcpy( MatType, rs.var.text_st.text_string );

      /* get the material grade */
      sts = om$send( msg = message NDmacro.ACgive_structure(
                                        &suc, &index, VS_K_prMatGrdAttr, &rs,
                                        &struct_elem->mod_env ),
			senderid = NULL_OBJID,
                        targetid = struct_elem->obj_id.objid,
                        targetos = struct_elem->obj_id.osnum );
      AP_ERR_HNDLR("NDmacro.ACgive_structure",sts,suc,VERBOSE, quit);
      strcpy( MatGrade, rs.var.text_st.text_string );

      sts = SFgetMatName( msg, MatType, MatGrade, lcl_mat_name, &newflag);
      AP_ERR_HNDLR("SFgetMatName",sts,*msg,VERBOSE, quit);
  }
  else
  {  
      printf("Error in Input Arguments for ");
      sts = OM_E_INVARG;
      goto quit;
  }

  if( mat_name     ) strcpy( mat_name, lcl_mat_name );
  if( new_material ) *new_material = newflag;

quit:
  return sts; 
}

end implementation Root;
