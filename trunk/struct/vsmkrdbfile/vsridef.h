/*
	I/STRUCT
*/
#ifndef vsridef_include
#	define vsridef_include

#define TRUE	1
#define FALSE	0

/*
 * "Select action" form : name and gadget numbers.
 */
#define SEL_FORM	"VSri_Choice.fm"
#define SEL_MAT		15
#define SEL_PRF		16
#define SEL_PLT		17

#define EXIT_CHOICE	0
#define MAT_CHOICE	1
#define PRF_CHOICE	2
#define PLT_CHOICE	3

/*
 * "Add Family/Part" form : name and gadget numbers.
 */
#define FAM_FORM	"VSri_AddFam.fm"
#define FAM		18	/* FAMily		*/
#define NAM		20	/* part NAMe		*/
#define MAT		19	/* MATerial		*/
#define CRE		21	/* CREator		*/
#define TIM		22	/* creation TIMe	*/
#define DAT		23	/* creation DATe	*/
#define LIB		24	/* LIBrary		*/
#define DSC		26	/* DeSCription		*/
#define PAR		27	/* PARameters		*/
#define DIR		31	/* DIRectory		*/
#define FIL		32	/* FILe			*/
#define LIB_TEXT	17
#define FAM_TITLE	35
#define TIME_FMT	36

/*
 * Max sizes of fields.
 */
#define MAX_FAM_LEN		12
#define MAX_NAM_LEN		15
#define MAX_MAT_LEN		15
#define MAX_CRE_LEN		14
#define MAX_DAT_LEN		15
#define MAX_TIM_LEN		15
#define MAX_LIB_LEN		FILENAME_MAX
#define MAX_DSC_LEN		40
#define MAX_PAR_LEN		15
/*
 * Max number of parameters.
 */
#define MAX_PAR_NUM		30

/*
 * "Add Material" form : name and gadget numbers.
 */
#define MAT_FORM		"VSri_AddMat.fm"
#define _MAT		18	/* MATerial		*/
#define _GRD		20	/* GRaDe		*/
#define _DSC		19	/* DeSCription		*/
#define _CRE		21	/* CREator		*/
#define _TIM		22	/* creation TIMe	*/
#define _DAT		23	/* creation DATe	*/
#define _DST		24	/* DeNsiTy		*/
#define _UNI		26	/* density UNIt		*/
#define _DIR		31	/* DIRectory		*/
#define _FIL		32	/* FILe			*/
#define _TIME_FMT	29

/*
 * Group of gadget commaon to "Add material" and "Add part" form.
 */
#define WARNING		39

/*
 * Max sizes of fields.
 */
#define MAX_GRD_LEN	15
#define MAX_UNI_LEN	10

/*
 * Time & date formats : form and gadget labels
 */
#define TIM_FORM	"VSri_TimDat.fm"
#define DAY		13
#define MONTH		14
#define YEAR		15
#define MONTH_FMT	23
#define DAY_FMT		26
#define YEAR_FMT	24
#define DATE_SEP1	16
#define DATE_SEP2	17
#define HOURS		18
#define MINUTES		19
#define SECONDS		20
#define HOUR_FMT	27
#define AM_PM		28
#define TIME_SEP1	21
#define TIME_SEP2	22
#define DATE_FIELD	11
#define TIME_FIELD	25

#define MAX_MATERIALS	50

#define NFM_CATALOGDESC		"n_catalogdesc"
#define NFM_CREATOR		"n_creator"
#define PDU_PARTDESC		"n_itemdesc"
#define PDU_CREATIONDATE	"n_creationdate"
#define PDU_CREATIONTIME	"n_creationtime"

#endif

