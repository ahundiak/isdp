/*********************************************************************

Author	:Manyam

Creation:11th August 1993
        25-Jul-1998     LAW     Added tiers for raceway - CR179801144
	
*********************************************************************/

#ifndef	vr_VRRevdef_include

#define vr_VRRevdef_include

#define	NUM_FORMS	2
#define	MAIN_FORM	0
#define	SUB_FORM	1

/*C	form names */
#define	PIPING_FORM_NAME	"VRPpRvPar"
#define	HVAC_FORM_NAME		"VRHvRvPar"
#define	RACEWAY_FORM_NAME	"VRRwRvPar"
#define	ELCABLE_FORM_NAME	"VRElCbRvPar"
#define	SUB_FORM_NAME		"VRUserParam"

/*C sub form titles	*/
#define	ADD_PARAM_TEXT		11
#define	STAT_ATTR_TEXT		15
#define	USER_ATTR_TEXT		16
#define	COND_ATTR_TEXT		17

/*C buttons common to all */
#define	STAT_ATTR_BUTTON	990
#define	USR_ATTR_BUTTON		917
#define	COND_ATTR_BUTTON	920

#define	PREVIOUS		911
#define	NEXT			913

/*C	common to all applications */
#define	CMP_NUMBER			92
#define	CMP_CODE			94
#define	NUM_OF_COMPS			11
#define	LENGTH				102
#define BEND_ANGLE			102
#define	SYMB_LENGTH			101
#define SYMB_BEND_ANGLE			103
#define	LENGTH_IMP_UNIT			802
#define	LENGTH_MET_UNIT			702
#define BEND_ANGLE_UNIT			902
#define MAT_TAKE_OFF			926

/*C	common to HVAC and CABLING	*/
#define WIDTH2				544
#define DEPTH2				554
#define	SHAPE				54
/*C     gadgets specific to RWAY  CR179801144   */
#define N_TIER_RV1			89
#define N_TIER_RV2			24
#define SP_TIER_RV1			97
#define SP_TIER_RV2			14

/*C	gadgets that are HVAC 	specific	*/
#define SURF_AREA			84

/*C	Piping Specific		 */
#define	OPT_CODE			96
#define P_NPD_R				100

/*C	CABLING	specific		*/
#define	CONDUCTOR_GROUP			150
#define	SYMB_CONDUCTOR_CODE		151
#define	CONDUCTOR_CODE			152

#endif
