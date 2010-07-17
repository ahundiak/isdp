#include "gr.h"
#include "go.h"
/***************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern long VRactive_params __((	IGRint		operation,
				IGRint		mode,
				IGRint		update_flag, 
				struct	GRid	*form_to_update,
				IGRint		VRproduct, 
				struct	GRid	*act_param_id  )); 

#if defined(__cplusplus)
}
#endif

/*******************************************************************************

	Filename		VRact_params.h
	Type			C include file
	Dependancy		VRattr_def.h
	Function		Defines om macro VR$active_params
	Use:
	
	VR$active_params(

		operation	IGRchar defining type of operation for active
				parameters.  Default is VR_RETRIEVE, VR_REPLACE
				or VR_STORE.  VR_REPLACE implies the active id
				will be replaced with one given in
				act_param_id.objid.

		mode		IGRchar defining the type of parameters
				required.  Default is VR_SYSTEM_MODE, otherwise
				USER is expected.

		update_flag	IGRchar	set to VR_UPDATE by default, this means
				the form is updated on a store operation.
				Otherwise use VR_NOUPDATE.

                form_to_update  Form to update. ( active form or change
                                attributes one )

		VRproduct	IGRchar set to either VR_PIPING or
				VR_HVAC depending on which sub product
				requires the update of parameters.

		act_param_id	pointer to structure GRid to store id of
				active parameters object and give osnum of
				active parameters object.

		status		return code for operation on active parameters

*******************************************************************************/

#omdef VR$active_params(	operation 	= VR_RETRIEVE,
				mode	  	= VR_SYSTEM_MODE,
				update_flag	= VR_NOUPDATE,
                                form_to_update  = NULL,
				VRproduct	= VR_PIPING,
				act_param_id	= NULL,
				status		)

 ( status ) =  VRactive_params( ( operation ), 
				( mode ), 
				( update_flag), 
				( form_to_update ), 
				( VRproduct ), 
				( act_param_id ) ) 
  
#endomdef
