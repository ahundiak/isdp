
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

VRco.h
Include file of component insertion commands.

Creation : O.N (isdc Paris)            



CHANGE HISTORY:

		Date     |  Name | Description
		---------------------------------------------------------------
		19/08/94    MM	   Added strings and codes for open tray shape.
		10/24/94  Lori     CR#179422038 added spec to HVAC
                01/04/96    HV     TR#179528608 blocked non-existing pocketmenus
                12/22/97    Law    CR#179309874 New RWAY shapes
                07/25/98    LAW    Added tiers for raceway - CR179801144
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#ifndef VRco_include

#define VRco_include

/* PIPING */
#define VR_VALVE_INSERTION		0
#define VR_REDUCER_INSERTION		1
#define VR_PIPEENDS_INSERTION		2
#define VR_MISC_INSERTION		3
#define VR_FLANGE_INSERTION		4
#define VR_CONNECTOR_INSERTION		5
#define VR_SPECIALTY_INSERTION		6
#define VR_INSTRUMENT_INSERTION		7
#define VR_ECCRED_INSERTION		8
#define VR_NOZZLE_INSERTION		9
#define VR_BEND_INSERTION		10
#define VR_BRANCH_INSERTION		11

/* HVAC */
#define VR_HVACTRANSITION_INSERTION	20
#define VR_HVACREDUCER_INSERTION	21
#define VR_HVACENDS_INSERTION		22
#define VR_HVACMISC_INSERTION		23
#define VR_HVACTERMDEV_INSERTION	24
#define VR_HVACDEV_INSERTION		25
#define VR_HVACOFFSET_INSERTION		26
#define VR_HVACSPLIT_INSERTION		27
#define VR_HVACBEND_INSERTION		28
#define VR_HVACBRANCH_INSERTION		29
#define VR_HVACORITRANS_INSERTION	30

/* RWAY */
#define VR_RWAYREDUCER_INSERTION	40
#define VR_RWAYMISC_INSERTION		41
#define VR_RWAYOFFSET_INSERTION		42
#define VR_RWAYSPLIT_INSERTION		43
#define VR_RWAYPULLBOX_INSERTION	44

/* As this define value is greater than EX_MAX_RESPONSE	*/
/* this is not handled by COB.				*/
#define EX_FORM_ERASE		34


#define	BAD_ORIEN	12
#define DYNCOMPONENT	1000
#define DYNHANGER	1001
#define DYNTEE 		1002
#define VRUSERPARAM	1103
#define	VRLOC_CMP	1104
#define VRALL_OK	1105
#define VRNOT_OK	1106
#define VRFORMDISP	1107
#define VRFORMUNDISP	1108
#define VRREDUCER	1109

#define VR_CMD_ABORT	1110


/* Take care of this defined value */
#define VRMAXHVACFIELDS		15
#define VRMAXRWAYFIELDS		14
#define VRMAXPIPINGFIELDS	10

/* Define piping field form */
/* Those are kept for MOMO titi 
#define	VALID		1
#define REFRESH		3
#define ANULE		4
#define	CMP_NB		13
#define	OPTION		22
#define	DIA_NOM		36
#define	DIA_RED		37
#define CODE		15
#define PMC		31
#define INSUL_TYP	30
#define	HEAT_TRAC	18
#define CONST_STS	33
#define INSUL_THICK	32
#define	LOAD_FROM	34
#define SHAPE           19
#define WIDTH_G         18
#define DEPTH_G         17
#define WIDTH_R         31
#define DEPTH_R         35
#define TRANS_L         38
#define EQUI_DIA        40
#define AIR_FLOW        41
#define THROAT_RAD      42
*/

/* Piping form field */
#define	PCMP_NB		13
#define	POPTION		22
#define	PDIA_NOM	36
#define	PDIA_RED	37
#define PCODE		15
#define PPMC		31
#define	PHEAT_TRAC	18
#define PCONST_STS	33
#define	PLOAD_FROM	34
#define PLOAD_USER	40
#define	PNOTES		41
#define	PMTOFLAG	38
#define	PPID		29
#define	PPID_TXT	30

/* Hvac form field */
#define	HCMP_NB		13
#define HCODE		15
#define HVMC		73
#define HCONST_STS	33
#define	HLOAD_FROM	34
#define HSHAPE          19
#define HWIDTH_G        18
#define HDEPTH_G        17
#define HWIDTH_R        31
#define HDEPTH_R        35
#define HTRANS_L        38
#define HEQUI_DIA       40
#define HAIR_FLOW       41
#define HTHROAT_RAD     42
#define	HNOTES		51
#define	HMTOFLAG	39
#define HLOAD_USER	48
#define HCORNER_RAD     65
#define HCORNER_RAD_LBL 66
#define HVSYM_SCALE	69
#define	HVSYM_SCALE_TXT	70

/* Rway form field */
#define	RCMP_NB		13
#define RCODE		15
#define RCONST_STS	33
#define	RLOAD_FROM	34
#define RSHAPE          19
#define RWIDTH_G        18
#define RDEPTH_G        17
#define RCORNRAD	117
#define RCORNRAD_LBL	32
#define RWIDTH_R        31
#define RDEPTH_R        35
/* Tier added for CR179801144 */
#define RN_TIER_CM1     54
#define RN_TIER_CM2     55
#define RN_TIER_CMTEXT	56
#define RSP_TIER_CM1    58
#define RSP_TIER_CM2    59
#define RSP_TIER_CMTEXT 57
#define RTRANS_L        38
#define REQUI_DIA       40
#define RAIR_FLOW       41
#define RTHROAT_RAD     42
#define	RNOTES		51
#define	RMTOFLAG	39
#define RLOAD_USER	48

/* Added 2 lines DR179603404 delete AIR_FLOW & EQUIVALENT DIAMETER for RWAY */
#define LABREQUI_DIA    20
#define LABRAIR_FLOW    46

#define CATALOG_FORM	67
#define SEARCH_FORM	68



/* Fields of "insert piping component" form */
enum PIPINGINSERTFORMFIELDS 	{
			eCMP_NB, 
			eOPTION,
			eDIA_NOM,
			eDIA_RED,
			eCODE,
			ePMC,
			eHEAT_TRAC,
			eCONST_STS,
			eNOTES,
			eMTOFLAG
			};

enum HVACINSERTFORMFIELDS 	{
			eHCMP_NB, 
			eHCODE,
			eHCONST_STS,
			eHTRANS_L,
			eHAIR_FLOW,
			eHTHROAT_RAD,
			eHEQUI_DIA,
			eHSHAPE,
			eHWIDTH_G,
			eHDEPTH_G,
			eHWIDTH_R,
			eHDEPTH_R,
			eHNOTES,
			eHMTOFLAG,
                        eHCORNER_RAD
			};


enum RWAYINSERTFORMFIELDS 	{
			eRCMP_NB, 
			eRCODE,
			eRCONST_STS,
			eRTRANS_L,
			eRAIR_FLOW,
			eRTHROAT_RAD,
			eREQUI_DIA,
			eRSHAPE,
			eRWIDTH_G,
			eRDEPTH_G,
			eRWIDTH_R,
			eRDEPTH_R,
			eRNOTES,
			eRMTOFLAG
			};


#define POCKETPATH	"config/english/menus/"

/* options sent in putqueue following those put in Codes tables */
#define STANDARDFLAG	0x0000		/* Just an aabbcc code entered	*/
#define REDUCERFLAG	0x1000		/* ,R entered			*/
#define OFFSETFLAG	0x2000		/* ,O entered			*/
#define SHAPEFLAG	0x4000		/* ,S=xxxx entered		*/
#define SPLITFLAG	0x8000		/* ,s entered    		*/
#define RECTFLAG	0x0000		/* Rectangular shape		*/
#define	OVALFLAG	0x0001		/* Oval shape			*/
#define	CIRCFLAG	0x0002		/* Circular shape		*/
#define	RECTOVALFLAG	0x0010		/* Rectang to oval shape	*/
#define	RECTCIRCFLAG	0x0020		/* Rectang to circle shape	*/
#define	OVALCIRCFLAG	0x0021		/* Oval to circle shape		*/
#define	SUCCESSFLAG	0x0100		/* Success flag of return fct.	*/
#define OLETSTRING	",W"
#define REDUCERSTRING	",R"
#define SHAPESTRING	",S="
#define OFFSETSTRING	",O"
#define SPLITSTRING	",s"

/* Default pocket Menu */
#define	DEFAULTPKTMNU		"POCKET_MENU"

/* String of Shape for Hvac components */
#define HRECTANGSTRING	"Rectangular"
#define HOVALSTRING	"Oval"
#define HCIRCLESTRING	"Circular"
#define HCORNRRADSTRING "Corner Radi"
#define HELLIPSTRING "Elliptical"
#define HRECTOVALSTRING	"Rect-Oval"
#define HRECTCIRSTRING	"Rect-Circ"
#define HRECTCORNSTRING "Rect-Corn"
#define HOVALCIRSTRING	"Oval-Circ"
#define HOVALCORNSTRING "Oval-Corn"
#define HCIRCORNSTRING  "Circ-Corn"
#define HELLPCIRCSTRING "Ellp-Circ"
#define HELLPCORNSTRING "Ellp-Corn"
#define HELLPRECTSTRING "Ellp-Rect"
#define HELLPOVALSTRING "Ellp-Oval"


#define HRECTANGCODE	0
#define HOVALCODE	1
#define HCIRCLECODE	2
#define HCORNRADCODE    3
#define HELLIPCODE	4
#define HRECTOVALCODE	16
#define HRECTCIRCODE	32
#define HOVALCIRCODE	33
#define HELLPCIRCODE    35
#define HRECTCORNCODE   48
#define HOVALCORNCODE   49
#define HCIRCCORNCODE   50
#define HELLPCORNCODE   51
#define HRECTELLPCODE   64
#define HOVALELLPCODE   65

#define UNDEFAABBCC	"undef."
#define NOTDEFPKTMNU	"NOTDEF"
#define VR_UNDEFINED_CODE	100

/* Piping pocket Menus types and names */

#define PPIPEPKTCODE		0
#define PELBOWPKTCODE		1
#define	PBRANCHPKTCODE		2	
#define	PREDUCERPKTCODE		3
#define PVALVEPKTCODE		4
#define	PFLANGEPKTCODE		5
#define	PPIPEENDSPKTCODE	6
#define	PMISCPKTCODE		7
#define	PBOLTPKTCODE		8
#define	PSPECIALPKTCODE		9	
#define	PINSTRUPKTCODE		10
#define	PSUPPORTPKTCODE		11	
#define	PBENDPKTCODE		12	
#define	PNOZZLEPKTCODE		13	
#define	PECCREDPKTCODE		14	
#define	PCONNECPKTCODE		15	

#define	PPIPEPKTMNU		NOTDEFPKTMNU
#define	PBRANCHPKTMNU		NOTDEFPKTMNU
#define	PREDUCERPKTMNU		"VRPRDPKT_MENU"
#define	PVALVEPKTMNU		"VRPVLPKT_MENU"
#define	PFLANGEPKTMNU		"VRPFLPKT_MENU"
#define	PPIPEENDSPKTMNU		"VRPPEPKT_MENU"
#define	PMISCPKTMNU		"VRPUSPKT_MENU"
#define	PBOLTPKTMNU		NOTDEFPKTMNU
#define	PSPECIALPKTMNU		"VRPSPPKT_MENU"
#define	PINSTRUPKTMNU		"VRPINPKT_MENU"	
#define	PSUPPORTPKTMNU		NOTDEFPKTMNU
#define	PBENDPKTMNU		NOTDEFPKTMNU
#define	PNOZZLEPKTMNU		NOTDEFPKTMNU
/*
#define	PECCREDPKTMNU		"VRPERPKT_MENU" 
*/
#define	PECCREDPKTMNU		NOTDEFPKTMNU

#define	PCONNECPKTMNU		"VRPCOPKT_MENU"	
#define	PELBOWPKTMNU		"VRPELPKT_MENU"	
#define	PTEEPKTMNU		"VRPTEPKT_MENU"	


/* Hvac pocket Menus types and names */
#define	HDUCTPKTCODE		0	
#define	HBENDPKTCODE		1	
#define	HBRANCHPKTCODE		2	
#define	HREDUCERPKTCODE		3
#define	HOFFSETPKTCODE		4
#define	HTRANSITPKTCODE		5
#define	HDUCTENDSPKTCODE	6
#define	HSPLITPKTCODE		7
#define	HORITRANSPKTCODE	8
#define	HMISCPKTCODE		9
#define	HSUPPORTPKTCODE		10
#define	HTDEVICEPKTCODE		11
#define	HDEVICEPKTCODE		12
#define	HYBRANCHPKTCODE		13

#define	HDUCTPKTMNU		NOTDEFPKTMNU
#define	HBENDPKTMNU		NOTDEFPKTMNU
#define	HREDUCERPKTMNU		"VRHRDPKT_MENU"
#define	HOFFSETPKTMNU		"VRHOFPKT_MENU"
#define	HTRANSITPKTMNU		"VRHTRPKT_MENU"
#define	HDUCTENDSPKTMNU		"VRHDEPKT_MENU"
#define	HORITRANSPKTMNU		NOTDEFPKTMNU
/*
#define	HMISCPKTMNU		"VRHUSPKT_MENU"
*/
#define	HMISCPKTMNU		NOTDEFPKTMNU

#define	HSUPPORTPKTMNU		NOTDEFPKTMNU
#define	HTDEVICEPKTMNU		"VRHTDPKT_MENU"
#define	HDEVICEPKTMNU		"VRHDVPKT_MENU"
#define	HELBOWPKTMNU		"VRHELPKT_MENU"
#define	HTEEPKTMNU		"VRHTEPKT_MENU"

/* Race Way pocket Menus types and names */
#define	RTRAYPKTCODE		0
#define	RELBOWPKTCODE		1
#define	RBRANCHPKTCODE		2
#define	RREDUCERPKTCODE		3
#define	RWYEPKTCODE		4
#define	RCROSSPKTCODE		5
#define	RMISCPKTCODE		6
#define	RSUPPORTPKTCODE		7

#define	RTRAYPKTMNU		NOTDEFPKTMNU
#define	RELBOWPKTMNU		NOTDEFPKTMNU
#define	RBRANCHPKTMNU		"VRHSPPKT_MENU"
#define	RREDUCERPKTMNU		"VRHRDPKT_MENU"
#define	RWYEPKTMNU		"VRHOFPKT_MENU"
#define	RCROSSPKTMNU		NOTDEFPKTMNU
#define	RMISCPKTMNU		NOTDEFPKTMNU
#define	RSUPPORTPKTMNU		NOTDEFPKTMNU

/* sketch (short) form implementation    */

#define VRSKF_DOIT              770    /*   switch to mini-parform   */
#define VRSKF_FLAB                0    /*   form label for mini_parform  */

/* structure describing component and supports behaviour */

struct	tagSegDesc
		{
		IGRint		SegType; /* BEGIN_OF_SEG, END_OF_SEG */
		IGRint		Fitting; /* TRUE, FALSE, UNKNOWN */
		IGRboolean	bChangeLength; /* TRUE of FALSE */
		struct GRid	SegId;
		};

struct tagCompSegDesc
		{
		IGRint		NbSeg;
		struct tagSegDesc	SegDesc [VR_MAX_CPTS];
		};

#define	TEE_TO_OLET	0x0002
#define	OLET_TO_TEE	0x0004

#ifndef USER_ATTR_FLD
#define USER_ATTR_FLD	12
#endif
#define	VR_TOGGLE	28
#ifndef VR_ADD
#define VR_ADD	2
#endif

#endif



