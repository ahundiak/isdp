/* operation */
#define	VR_RETRIEVE	0
#define	VR_STORE	1
#define	VR_REPLACE	2
#define	VR_INIT		3
#define	VR_ADD		4
#define	VR_DELETE	5
#define	VR_MODIFY	6

/* update flags */
#define VR_NOUPDATE	0
#define VR_UPDATE	1

/* attribute type */
#define VR_SYSTEM_MODE	0
#define VR_USER_MODE	1
#define VR_NOZZLE_MODE	2

/* Maximum number of ACrg_coll structures from an AClist */
#define VR_MAX_ATTR	100

/* Directory names for attributes */
#define  DIR_NAME_PIPING	":IGENOD:VRattr_piping"
#define  DIR_NAME_HVAC		":IGENOD:VRattr_hvac"
#define  DIR_NAME_RWAY		":IGENOD:VRattr_cabling"
#define  DIR_NAME_EQUIP		":IGENOD:VRattr_equip"
#define  DIR_NAME_ELEC		":IGENOD:VRattr_electrical"
#define  DIR_NAME_FOPTIC	":IGENOD:VRattr_fibre_optic"

/* Directory entries for command objects whilst running */
#define  COMM_NAME_PIPING ":IGENOD:VRpip_comm_id"
#define  COMM_NAME_HVAC   ":IGENOD:VRhvac_comm_id"
#define  COMM_NAME_CABLE  ":IGENOD:VRcable_comm_id"
#define  COMM_NAME_EQUIP  ":IGENOD:VRequip_comm_id"
