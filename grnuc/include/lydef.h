/*#define NUM		76
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
#define LY_ERROR	51
#define OCC_ON		33
#define OCC_OFF		34
#define OCC_IGN		35
#define SAV_EXIT	1
#define LY_EXIT 	4
#define REDISPLAY       72
*/

#define  MAX_LVLDEF  1024

/* GRLayers gadget label defines */

#define  GRLAYERS_FORM      1
#define  EXIT_SAVE          1
#define  EXIT_BUTTON        4
#define  CVT_TO_WINDOW      5
#define  LY_MESSAGE_FIELD  10
#define  ACT_LAYER_TEXT    12
#define  MODE_TOGGLE       14
#define  ACT_LAYER         15
#define  LAYER_FIELD       16
#define  SORT_TOGGLE       21
#define  DELETE_BUTTON     20
#define  ELIG_ROLL         22
#define  OCCUPIED_ROLL     23
#define  SEARCH_BUTTON     27
#define  OCCUPIED_TOGGLE   31
#define  DISPLAY_TEXT      18
#define  ELIG_TEXT         25
#define  DISPLAY_TEXT_ROLL 29
#define  ELIG_TEXT_ROLL    30

/* DEFINES FOR dis_new_3col */
#define IND_LY		1
#define GROUP 		2
#define LY_FIND		4

/*
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
*/

#define L_On_Flag        1
#define L_Off_Flag	 2
#define L_Ign_Flag	 3

/*
 *	This macro will turn the level specified on in the mask.
 *	The mask is assumed to be an array of 32 longs.  Each bit
 *	represents a layer.
 */
 
#define LYset_level_on(level,mask)\
{\
long _or_mask = 0;\
       _or_mask = 1 << (level % 32);\
       mask[level >> 5] |= _or_mask;\
}

/*
 *	This macro will turn the level specified off in the mask.
 *	The mask is assumed to be an array of 32 longs.  Each bit
 *	represents a layer.
 */

#define LYset_level_off(level,mask)\
{\
long _and_mask = 0;\
       _and_mask = 1 << (level % 32);\
       mask[level >> 5] &= ~(_and_mask);\
}


