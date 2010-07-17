#ifndef VRnozzmacros_include

#define VRnozzmacros_include

/***************************************************************************/

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VREvaluateNozz __((	IGRlong			*p_msg,
				IGRint			Product,
				struct	VRGenInfo	*p_Instance,
				struct	GRid		*p_SysParamsId,
				struct	GRid		*p_UsrParamsId, 
				struct	GRid		*p_MssParamsId,
				struct	GRid		*p_ComponentId,
				IGRint			*p_NbCpts,
				IGRint			*p_NbMissingParams, 
				struct	ACrg_coll	**p_AddrMissings,
				struct	GRmd_env	*p_MdEnv ));

extern	int VRPlaceNozz __(( 	IGRlong			*p_msg,
				struct	GRid		*p_ComponentId,
				struct	VRGenInfo	*p_Instance,
				struct	GRid		*p_RefId,
				struct	GRvg_construct	*p_CnstList,
				struct	GRmd_env	*p_MdEnv ));

#if defined(__cplusplus)
}
#endif
/************************************************************************/
/*									*/
/* Abstract :	Given as input an I/ROUTE nozzle description,   	*/
/*		VR$EvaluateNozz returns this component's geometric	*/
/*		description and creates the object.			*/
/* Arguments :								*/
/*									*/
/* IGRlong     *p_msg		: returns MSFAIL if something went wrong*/
/* I IGRint    Product		: Product of the component(see VRdef.h) */
/* I VRGenInfo *p_Instance	: Generic component description.	*/
/* I GRid      *p_SysParamsId	: Component's system parameters		*/
/* I GRid      *p_UsrParamsId	: Component's user parameters		*/
/* I GRid      *p_MssParamsId	: Component's user parameters		*/
/* O GRid      *p_ComponentId	: Component which has to be modified 	*/
/* O IGRint    *p_NbCpts	: returns the number of connect points	*/
/* O IGRint    *p_NbMissingParams: returns the number of missing	*/
/* O ACrg_coll **p_AddrMissings	:returns the address of a static buffer	*/
/*				 containing the missing parameters descr*/
/* I GRmd_env  *p_MdEnv		: working module env.			*/
/************************************************************************/

#omdef VR$EvaluateNozz
       			( p_msg, 
	 		  Product,
	 		  p_Instance,
	 		  p_SysParamsId,
	 		  p_UsrParamsId,
	 		  p_MssParamsId,
			  p_ComponentId,
	 		  p_NbCpts,
	 		  p_NbMissingParams,
         		  p_AddrMissings     = NULL,
	 		  p_MdEnv)

VREvaluateNozz( p_msg, Product, p_Instance, p_SysParamsId, p_UsrParamsId, 
		p_MssParamsId, p_ComponentId, p_NbCpts,
		p_NbMissingParams, p_AddrMissings, p_MdEnv )


#endomdef

/************************************************************************/
/*									*/
/* Abstract :	Given as input an I/ROUTE component object, previously 	*/
/*		evaluated, and the networks supports objects (segments) */
/*		it places this component's in the network.		*/
/* Arguments :								*/
/*									*/
/* IGRlong     *p_msg		: returns MSFAIL if something went wrong*/
/* I GRid      *p_ComponentId	: Component which has to be placed 	*/
/* I VRGenInfo *p_Instance	: Generic component description.	*/
/* I GRid      *p_RefId		: Referencial for nozzle Id.		*/
/* I GRvg_construct *p_CnstList	: Symbology structure.			*/
/* I GRmd_env  *p_MdEnv		: working module env.			*/
/************************************************************************/

#omdef VR$PlaceNozz (	p_msg,
			p_ComponentId,
			p_Instance,
			p_RefId,
			p_CnstList,
			p_MdEnv)

VRPlaceNozz ( p_msg, p_ComponentId, p_Instance,
	      p_RefId, p_CnstList, p_MdEnv )

#endomdef

#endif

