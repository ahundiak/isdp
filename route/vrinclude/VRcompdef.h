/*********************************************************************

Author	:	B Demars

Creation:	November 12th, 1990


		This file contains the definition of all
		VRconstants concerning the VR components objects.
		
	
Change History :


	date  |  name |	modification's description
	------+-------+-----------------------------------
	Feb 97	kdd	VR_FLOW_BIDIRECTION, 
        Dec 97  law     Added Elliptical components (CR179309874)
*********************************************************************/

#ifndef	vr_compdef_include
#define vr_compdef_include

/* -- Definition of the component's maximum number of templates -- */

#define		VR_NB_ATTR	3

/* -- Definition of the component's types -- */

#define	VR_SIMPLE_COMPONENT_TYPE 0
#define VR_CONSTR_COMPONENT_TYPE 1

/* -- Definition of the component possible item name (argument of VRplace) -- */

/* the negative values avoid access to the COMMODITY_ITEM_NAME */

#define		VR_EQUIPMENT	-7	/* symbol for crossing lines */

#define		VR_PID_CROSS	-6	/* symbol for crossing lines */

#define		VR_CONC_COMP	-5	/* only returned by VRGetSysType
					   method in case of received by
					   a constrained component object */
#define		VR_NOZZLE	-4	/* only returned by VRGetSysType
					   method in case of received by
					   a nozzle object */
#define		VR_DANGLING	-3	/* component with no need for
					   attributes */
#define		VR_ELBOW	-2	/* must access the bend deflection
					   prior to the commodity item table*/
#define		VR_TEE		-1	/* must access the bend deflection
					   prior to the commodity item table*/
#define		VR_PIPE		1

#define		VR_REDUCER	4

#define		VR_FLGE_BEND	5	/* flange around bend or elbow */

#define		VR_FLGE_COMP	6	/* flange around other component */

#define		VR_TRUE_Y	11	/* TRUE Y */

#define		VR_EQ_CROSS	12	/* equal size cross */

		/* Specific HVAC + Raceway */

#define		VR_TWIST_R_TR	25	/* twisted rectangular transition */

#define		VR_TRANS_R_O	29	/* transition rect -> oval */

#define		VR_TRANS_R_C	30	/* transition rect -> circ */

#define		VR_TRANS_O_C	31	/* transition oval -> circ */

#define		VR_TRANS_R_Co	49	/* transition rect -> Rad corner */

#define		VR_TRANS_O_Co	50	/* transition oval -> Rad corner */

#define		VR_TRANS_C_Co	51	/* transition circ -> Rad corner */

#define		VR_TRANS_E_C    52	/* transition circ -> Elliptical */

#define		VR_TRANS_E_Co   53	/* transition ellip-> Rad Corner */

#define		VR_TRANS_R_E    54      /* transition rect -> Elliptical */

#define		VR_TRANS_O_E    55      /* transition oval -> Elliptical */

/* -- Definition of the component's center justification -- */

#define		VR_CENTER_JUST	-1

/* -- Definition of the component possible status -- */

#define	VR_ERROR	0x0001	/* Component have no model */

#define	VR_DUMB_DEL	0x0002	/* Component won't perform any checks
				   before getting deleted */
#define	VR_SYSTEM	0x0004	/* Component defined by the system */
#define	VR_FORCED	0x0008	/* Component defined by the system and
				   code forced by the user */
#define	VR_BUILT_IN	0x0010	/* Component Model is build in the
				   system */
#define	VR_CORRECTION	0x0020	/* Component is handled by the
				   correction entity */
#define VR_PID_ONLY	0x0040  /* defines components that can only exist in PID */

#define VR_CLONE	0x0080	/* Component resulting of a copy */

#define VR_EVALUATE	0x0100	/* Component has no network topology */

#define VR_OUT_MACRO	0x0400	/* Component out of a macro ( used for the
				/* nozzle )
				/**/

#define VR_XFORM_ONLY	0x0800	/* Compute needs only to perform an xform */

#define VR_INSTRUMENT	0x1000  /* defines instrument components */

#define VR_GR_DEPENDANT	0x2000  /* the representation and scale are extracted
				   from the template (component or equipment)*/

#define VR_AT_DEPENDANT	0x3000  /* Get the system and user attributes from the
				   template */

/* -- path names for storing caches -- */

#define VR_MISC_DIR		"vroute"
#define VR_EQUIP_DIR		"equipdb"
#define VR_PIPING_DIR		"pipingdb"
#define VR_HVAC_DIR		"hvacdb"
#define VR_RWAY_DIR		"rwaydb"
#define VR_ELEC_DIR		"electdb"
#define VR_FIBER_DIR		"foptdb"

#define VR_USER_FOOTNAME	"user"
#define VR_ATTR_FOOTNAME	"attributes"		/* path to get to 
							   the attributes
							   object via the
							   feet system */

/* -- Definition of option values for HVAC or RWAY rotation components -- */

	/* topology */

#define VR_DEPTH_ROT_OPT	0x0000	/* default */

#define VR_WIDTH_ROT_OPT	0x0002

#define VR_TWIST_ROT_OPT	0x0004

	/* dimensions */

#define VR_REDUCING_ROT_OPT	0x0001

#define VR_NONRED_ROT_OPT	0x0000 /* default */

/* -- Definition of the internal components' names( max 6 chars ) -- */

#define 	VR_ERROR_SYMBOL		"?"		/* symbolises an 
							error component*/
#define 	VR_DANGLING_NAME	"dangle"	/* is used as AABBCC
							code when placed */
#define		VR_CHANGE_ATT_NAME	"chgatt"	/* is used as AABBCC
							code when placed */
#define 	VR_SUPPORT_NAME		"suppor"	/* name of the support
							model (6 characters) */

/* -- Definition of the flow direction possible values -- */

#define		VR_FLOW_UNKNOWN		0

#define		VR_FLOW_IN		-1

#define		VR_FLOW_OUT		1

#define		VR_FLOW_BIDIRECTION	3  /*same symbol for -3 VRCorrection.S*/

/* -- Definition of the nozzle attribute templates number -- */

#define         VRPNbNozAttr             7
#define         VRHNbNozAttr             6

#endif
