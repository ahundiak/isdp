#ifndef  vdmdlvwdef_include
#define  vdmdlvwdef_include


/*
 *  current state of the form
 */
#define   VD_MNG_MV_ST   0
#define   VD_CRT_MV_ST   1
#define   VD_MDF_MV_ST   2

/*
 * Max lengths
 */

#define  VD_MAX_MV_NAME_LEN	17
#define  VD_MAX_MV_DESC_LEN	81

#define  VD_MAX_QRY_NAME_LEN	17
#define  VD_MAX_QRY_DESC_LEN	81

/*
 * form gadgets
 */

#define  VD_MV_LIST_FLD		13
#define  VD_MV_CRT_FLD		14
#define  VD_MV_MDF_FLD		15
#define  VD_MV_DLT_FLD		16
#define  VD_MV_HLT_FLD		20
#define  VD_MV_DRW_FLD		21

#define  VD_VVOL_CRT_TTL	18
#define  VD_VVOL_MDF_TTL	28

#define  VD_MV_NAME_FLD		16
#define  VD_MV_DESC_FLD		24

#define  VD_MV_CRT_MV_TXT	11
#define  VD_MV_MDF_MV_TXT	15

#define  VD_VV_LIST_FLD		13
#define  VD_SEL_VOL_FROM_LIST	17
#define  VD_LOC_SOL_FLD		18
#define  VD_VV_RMV_FLD		21

#define  VD_QRY_LIST_FLD	26
#define  VD_SEL_QRY_FROM_LIST	20
#define  VD_QRY_RMV_FLD		22

#define  VD_MV_CRT_HLT_FLD	29
#define  VD_MV_CRT_DRW_FLD	19


#define  VD_VVOL_MNG_GRP	17
#define  VD_VVOL_CRT_MDF_GRP	27

/*
 * return response when user wants to locate solid
 */

#define  VD_LOC_SOLID_ST	500

/*
 * return status when parent solid is deleted
 */

#define  VD_MV_FND_LESS_ROOTS   100


#define  VD_VVOL		0
#define  VD_QRY			1


#endif
