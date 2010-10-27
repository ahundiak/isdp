/* VDSreports key management */
#define	KEY_FILE	"/tmp/VDSrpt_key"
#define	KEY_LEN		20

/* VDSreports products keys */
#define	KEY_BEAM	"BM"	/*	I/STRUCT beams			*/
#define	KEY_EQUP	"EQ"	/*	I/VDS    equipments		*/
#define	KEY_HVAC	"HV"	/*	I/ROUTE  hvac			*/
#define	KEY_NOZZ	"NZ"	/*	I/ROUTE  piping nozzles		*/
#define	KEY_OVER	"OV"    /*	         overall report		*/
#define	KEY_PLAT	"PL"	/*	I/STRUCT plates			*/
#define	KEY_PIPE	"PP"	/*	I/ROUTE  piping			*/
#define	KEY_RWAY	"RW"	/*	I/ROUTE  raceway		*/
#define	KEY_STBP	"BP"	/*	I/STRUCT beams & plates		*/
#define	KEY_VDSP	"VD"	/*	VDS user interface		*/
#define KEY_COMP	"CM"	/*	I/SMAN   compartments		*/

/* VDSreports products codes */
/* KEY value : */
#define	COD_BEAM	0
#define	COD_EQUP	1
#define	COD_HVAC	2
#define	COD_NOZZ	3
#define	COD_OVER	4
#define	COD_PLAT	5
#define	COD_PIPE	6
#define	COD_RWAY	7
#define	COD_STBP	8
#define	COD_VDSP	9
#define	COD_COMP	10

/* VDSreports types keys */
#define KEY_BOM		'B'	/*	Bill Of Material		*/
#define KEY_DAT		'D'	/*	Data report (PP only)		*/
#define KEY_DWG		'G'	/*	Drawing report 			*/
#define KEY_ERR		'E'	/*	Error report			*/
#define KEY_NST		'N'	/*	Nsts type report		*/
#define	KEY_REF		'R'	/*	Reference data (PP only)	*/
#define	KEY_VDS		'S'	/*	VDS user interface 		*/
#define KEY_VLV		'V'	/*	Valve report (PP only)		*/
#define KEY_WGT		'W'	/*	Weight report			*/
#define KEY_TRK		'T'	/*	Tracking report			*/
#define KEY_SPC		'C'	/*	Space Class			*/

/* VDSreports types codes */
#define COD_BOM		0
#define COD_DAT		1
#define COD_DWG		6
#define COD_ERR		2
#define COD_NST		3
#define	COD_REF		7
#define	COD_VDS		8
#define COD_VLV		4
#define COD_WGT		5
#define COD_TRK		9
#define COD_SPC		10
