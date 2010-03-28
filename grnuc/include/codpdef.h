#ifndef codpdef_include

#define codpdef_include

#define  MAX_WINDOW      45
#define  DP_MAX_ALIAS_SIZE 52

/*  INPUT FLAGS  */
/* #defines for get_graphic_gadget flag indicating which instance 
	variable is to be used for storage of graphic gadget id 
	source_id or ggid */
	
#define		SrcGGid		0x00000001
#define		DstGGid		0x00000002

/* #defines for get_graphic_gadget num_wnds */

#define 	OneWnd	 	0x00000001

/* #defines for get_graphic_gadget err_flg indicating the type of gadget you
	wish to find.  If a different type of gadget is located,
	an error is returned in me->ret and an appropriate message is 
	output to the screen's error field. */
	
#define 	ExstGG  	0x00000001 /* existing graphic gadgets */
#define 	NonExstGG  	0x00000002 /* nonexisting graphic gadgets */

 /* arguments for actions in some the displayco actions */
 
#define         FrstPt		0000
#define		ScndPt		0001
#define         ThrdPt		0002
#define         FrthPt		0003
#define         FfthPt		0004
#define         SxthPt		0005

/* RETURN FLAGS */

#define   	SrchFlt		3000  /* search fault */
#define 	InvInp		3004  /* invalid input */
#define         SamGG           3008  /* same graphic gadget */
#define	 	InitFlt		3010  /* fault in init method */
#define         Cnstr		3011  /* used in COviewmnpl.sl for transition
					to construction state */
#define         Descr		3012  /* used in COviewmnpl.sl for transition
					to description state */
#define		FunFail		3013  /* (math) function failed */
#define	        InvTxtKyin      3014  /* invalid text input COviewmnpl.sl */

/*----------------------------*/
/* MODIFY VIEW VOLUME DEFINES */

/* Input states */

#define DYN_COI_PNT     0x00000001
#define DYN_EYE_PNT     0x00000002
#define DYN_ANGLE     	0x00000004
#define DYN_UP		0x00000008
#define DYN_NEAR      	0x00000010
#define DYN_FAR       	0x00000020
#define DYN_VRP		0x00000040
#define DYN_VPN		0x00000080
#define DYN_RADIUS	0x00000100
#define DYN_CLEAR_INPUT	0xFFFF0000

/* Display states */

#define DYN_CLEAR_DISPLAY 	0x0000FFFF
#define DYN_PYRAMID		0x00010000
#define DYN_PY_NO_TRUN		0x00030000
#define DYN_PY_TRUN_NEAR	0x00050000
#define DYN_PY_TRUN_FAR		0x00090000
#define DYN_PY_TRUN_NEAR_FAR	0x000D0000
#define DYN_VIEW_VECTOR		0x00100000
#define DYN_VUP			0x00200000
#define DYN_PROJ_PLANE		0x00400000
#define DYN_NORMAL		0x00800000
#define DYN_PARALLEL_P		0x01000000

/* Error messages */

#define DPOK	 0x00000001
#define DPAng0   0x00000002
#define DPAng180 0x00000004
#define DPNBehIPt  0x00000006
#define DPFBehIPt  0x00000008
#define DPFarEqNear 0x00000010
#define DPErrPyrm   0x00000100
#define DPINIT	    0x00000200

/*---------------------------------------*/

/*----------------------------*/
/* For Layers Form */

#define NUM		76
#define NAME		74
#define ELIG		77
#define OCCUPIED 	40
#define B_OCCUPIED	38
#define S_LAYER		55
#define S_GROUP		56
#define SEARCH		57
#define ELIG_ON		23
#define ELIG_OFF	29
#define ELIG_IGN	32
#define S_NUM		28
#define S_NAME		27
#define MOD_ON		67
#define MOD_OFF		68
#define MODIFY		69
#define MOD_NAME	66
#define ACT_LY		12
#define CDP_ERROR	51
#define OCC_ON		33
#define OCC_OFF		34
#define OCC_IGN		35
#define SAV_EXIT	1
#define CDP_EXIT	4
#define REDISPLAY       72

#define	SEARCH_NDX	0
#define S_GROUP_NDX	1
#define S_LAYER_NDX	3
#define S_NUM_NDX	4
#define S_NAME_NDX	5
#define ELIG_ON_NDX	6
#define ELIG_OFF_NDX	7
#define ELIG_IGN_NDX	8
#define OCC_ON_NDX	9
#define OCC_OFF_NDX	10
#define OCC_IGN_NDX	11
#define MOD_NAME_NDX	12
#define MOD_ON_NDX	13
#define MOD_OFF_NDX	14
#define MODIFY_NDX	15
#define ERROR_NDX	16
#define ACT_LY_NDX	17

#define L_On_Flag        1
#define L_Off_Flag	 2
#define L_Ign_Flag	 3

/* DEFINES FOR dis_new_3col */
#define IND_LY		1
#define GROUP 		2
#define LY_FIND		4

/*------------------------------*/

#endif
