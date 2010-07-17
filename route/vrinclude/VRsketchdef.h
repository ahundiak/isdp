/*************************************************************************


Author	: 		momo

Creation: 		1 - 11 -1989
	
Change History		
                Date     |  Name | Description
                ---------------------------------------------------------------
                19/08/94    MM     Added gadget RW_T_SHAPE for Rway sketch form.
                Feb-06-97   Alwin  Added gadgets HV_THROAT_RADIUS and 
                                   HV_TRAN_LENGTH for Hvac sketch form.
                Dec-22-97   Law    Added new shapes for RWAY (CR179309874)
        	25-Jul-98   LAW     Added tiers for raceway - CR179801144
        	27-Sep-99   Anand  Added corner radius for HVAC and Raceway
				   - CR 179900837
        	09-May-2k   Anand  Modified corner radius text and label gadget
				   ids in HVAC and Raceway forms - TR 179901473

*************************************************************************/

#ifndef VRsketchdef_include
#define VRsketchdef_include

/* form index define */
#define MAIN			0
#define	SUB			1

#define VR_SHARE_PLANES		0x0010

/* needed to place or replace component */
#define	VR_NEW_COMP		1
#define VR_OLD_COMP		2

/* sketch mode */
#define VR_MANUAL               0
#define VR_AUTOMATIQUE          1

/* type of next point */
#define IS_NOT_A_VALID_POINT    0
#define IS_A_VALID_POINT        1  /* 0x0001 */
#define IS_AN_EXTEND            3  /* 0x0003 */

/* change parameters */
#define NO_CHANG                0
#define DIAMETER_CHANG		1  /* 0x0001 */
#define AUTHER_CHANG		2  /* 0x0010 */

/* used by the sketch commnad */
#define MAX_SEG  	       10
#define NO_PREVIOUS_SEG	       50
#define ADDITIONAL_PARAMS      12

/* type of first point */
#define	IS_UNDEFINED		0
#define FREE_SPACE  		1
#define IS_NOZZLE   		2
#define IS_DANGLING 		3
#define IS_PIPE 		4
#define IS_TEE  		5
#define IS_ELBOW 		6
#define IS_OLET 		7
#define IS_CONC_COMP 		8
#define IS_COMP_TO_CONNECT	9
#define IS_ENDLINE_COMP		10
#define IS_REDUCER		11
#define	IS_ECCREDUCER		12
#define IS_VALVE		13
#define IS_OFFSET		14
#define	IS_BRANCH		15
#define	IS_TRANSITION		16
#define	IS_ENDPIPE		17
#define IS_ENDDUCT		18
#define IS_FLANGE		19
#define	IS_INSTRUMENT		20
#define	IS_SPECIALITY		21
#define IS_CONNECTOR		22
#define IS_TERMINATION_DEVICE	23
#define IS_DEVICE		24
#define IS_NO_ORIENT		25
#define IS_DANGLING_TO_CONNECT	26


/* status of dangling */
#define BEGIN_OF_SEG	       -1
#define END_OF_SEG              1

/* HVAC form gadgets */
#define HV_SKEWED   		15
#define HV_LOCATE	 	17
#define HV_TWIST	 	18
#define HV_FITOFIT		20
#define HV_WIDTH		28
#define HV_DEPTH		27
#define HV_D_TXT		30
#define HV_C_SHAPE		16
#define HV_R_SHAPE              19
#define HV_O_SHAPE              23
#define HV_RS_SHAPE             44
#define HV_C_SHAPE2		39
#define HV_R_SHAPE2             40
#define HV_O_SHAPE2             42
#define HV_RS_SHAPE2            45
#define HV_TEXT_SHAPE2		41
#define HV_THROAT_RADIUS        51
#define HV_TRAN_LENGTH          53
/* Add 2 for CR179801061 for duct-wheel on sketch form */
#define SIZE_COMP_METHOD	132
#define MESSAGE			10

/* Below two constants added by Anand for CR 179900837 */
#define CORN_RAD_TXT	118
#define CORN_RAD	117
/* The above two gadget ids have been ensured to hold good for both
 * VRRwaySkParams and VRHVSkParams forms */

/* RWAY form gadgets */
#define RW_SKEWED   		15
#define RW_LOCATE	 	17
#define RW_TWIST	 	18
#define RW_FITOFIT		20
#define RW_WIDTH		28
#define RW_DEPTH		27
#define RW_D_TXT		30
#define RW_C_SHAPE		16	/* Circular Shape */
#define RW_R_SHAPE              19	/* Duct Shape     */
#define RW_O_SHAPE		39      /* Oval Shape     */
#define RW_C_SHAPE2		39
#define RW_RS_SHAPE		40	/* round corner   */
#define RW_R_SHAPE2             40
#define RW_E_SHAPE		41	/* elliptical shape */
#define RW_TEXT_SHAPE2		41
#define RW_T_SHAPE		48	/* Tray Shape     */

/* Piping, hvac and raceway sketch form gadgets */
#define PIPING_OPTION           50
#define PP_SKEWED   		15
#define PP_LOCATE	 	17
#define PP_FITOFIT		20
#define PP_SEQ			26
#define PP_DIAM			19
#define OPTION			27
#define PP_CMP_NB		32
#define PP_LINE_SEQ		26
#define SK_PID_SCALE		33
#define SK_PID_SCALE_LABEL	34

#define SMALL_DIAMETER		35
#define SMALL_HV_WIDTH		32
#define SMALL_HV_DEPTH		34
#define HV_CMP_NB		36
#define SMALL_RW_WIDTH		26
#define SMALL_RW_DEPTH		32
/* Tiers added for CR179801144 */
#define N_TIER_SK1		44
#define N_TIER_SK2		46
#define SP_TIER_SK1		42
#define SP_TIER_SK2		47
#define N_TIER_SK1_TEXT		48
#define N_TIER_SK2_TEXT		50
#define SP_TIER_SK1_TEXT	49
#define SP_TIER_SK2_TEXT	52
#define RW_CMP_NB		33
#define MAINTAIN_SKEW		201

#define HV_SYMB_SCALE		46
#define HV_SYMB_SCALE_LABEL	47

#define VR_SHAPE_R_O 		16
#define VR_SHAPE_R_C 		32
#define VR_SHAPE_O_C 		33

#define VR_DEFAULT_VALUE	0

#define VR_NOT_VALID		-1
#define	VR_SKCPT_MAX		2
#define	VR_ADDED_PARAM		2
#define	VR_NEED_CPT		2

#define VR_BLOCK_LOCATE       999

/* status display piping form */
#define LLP_FLG 	       	299
#define P_TEE_BUTTON        	17
#define P_ELBOW_BUTTON		40
#define P_REDUCER_BUTTON    	14
#define VALVE_BUTTON		22
#define FLANGE_BUTTON		23
#define ENDPIPE_BUTTON		25
#define INSTRUMENT		33
#define CONNECTOR		20
#define SPECIALITY		32
#define P_USER			27

/* status display hvac form */
#define H_TEE_BUTTON        	29
#define H_ELBOW_BUTTON		21
#define H_REDUCER_BUTTON    	15
#define H_OFFSET_BUTTON     	11
#define ENDDUCT_BUTTON    	13
#define TERMINATION		35
#define DEVICE_BUTTON 		16
#define H_USER			31
#define TRANSITION_BUTTON 	12
#define MANUAL_GRP	 	251
#define AUTOMATIQUE_GRP	 	250

/* status display Rway form */
#define R_TEE_BUTTON        	37
#define R_ELBOW_BUTTON		36
#define R_REDUCER_BUTTON    	34
#define R_OFFSET_BUTTON     	26
#define R_USER		 	30

enum	VRSkCompTopo	{ VR_UNDEFINED_TOPO,
			  VR_CLOSURE_TOPO,
			  VR_INLINE_TOPO,
			  VR_2_WAYS_TOPO,
			  VR_3_WAYS_TOPO,
			  VR_OLET_TOPO,
			  VR_4_WAYS_TOPO,
			  VR_ECCENTRIC_TOPO,
			  VR_RETURN_TOPO,
			  VR_OFFSET_TOPO,
			  VR_HELIX_TOPO,
			  VR_SPLIT_TOPO,
			  VR_BEND_SPLIT_TOPO,
			  VR_Y_BRANCH_TOPO,
			  VR_MAXIMUM_TOPO
			 };

/*C define the common ones for all the applications */
#define	LINE_SEQ_NUM		226
#endif
