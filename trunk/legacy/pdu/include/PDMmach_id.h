#define PDM_NAME     "PDM"
#define PDM_REV		"2.0.0"
#define PDM_DESC    "PDM VERSION : 2.0.0"
#define DELIM        	"/"

/* APOGEE #ifdef unix APOGEE */
#define DELIM        	"/"
#define PDM_DIR       		"/usr/ip32/pdm/config/initial"
#define PDMNODES_DIR   		"/usr/lib/nodes/owned"
#define PDMSDP_CMD_FILE   	"/usr/ip32/pdm/config/initial/PDMcmd.sdp"
#define PDMSDP_PART_FILE	"/usr/ip32/pdm/config/initial/PDMwf.sdp"
#define GOOD_STATUS			0
#define	BAD_STATUS			1
/* APOGEE #endif APOGEE */
/* APOGEE START 
#ifdef vms
#define DELIM    		 "" 
#define PDM_DIR						"pro_dd_pdm:"
#define PDMNODES_DIR   				"pro_dd_pdm:"
#define PDMSDP_CMD_FILE				"pro_dd_pdm:PDMcmd.sdp"
#define PDMSDP_PART_FILE			"pro_dd_pdm:PDMwf.sdp"
#define GOOD_STATUS					1
#define	BAD_STATUS					0
#endif
      APOGEE END */
