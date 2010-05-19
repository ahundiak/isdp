#ifndef  vdvvoldef_include
#define  vdvvoldef_include


/*
 *  current state of the form
 */
#define   VD_MNG_VOL_ST   0
#define   VD_CRT_VOL_ST   1
#define   VD_MDF_VOL_ST   2

/*
 * Max lengths
 */

#define  VD_MAX_VOL_NAME_LEN	17
#define  VD_MAX_VOL_DESC_LEN	81

/*
 * form gadgets
 */

#define  VD_VVOL_LIST_FLD	13
#define  VD_VVOL_CRT_FLD	14
#define  VD_VVOL_MDF_FLD	15
#define  VD_VVOL_DLT_FLD	16
#define  VD_VVOL_DIS_FLD	19

#define  VD_VVOL_CRT_TTL	18
#define  VD_VVOL_MDF_TTL	28


#define  VD_VVOL_LOC_SOL	24
#define  VD_VVOL_VOLNAM_FLD	25
#define  VD_VVOL_DESC_FLD	26

#define  VD_VVOL_MNG_GRP	17
#define  VD_VVOL_CRT_MDF_GRP	27

/*
 * return response when user wants to locate solid
 */

#define  VD_LOC_SOLID		500

/*
 * return status when parent solid is deleted
 */

#define  VD_VVOL_SOLID_DELETED  801


#endif
