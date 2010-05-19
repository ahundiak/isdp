/* I/VDS
 *
 * File:        vdpinclude/VDPdef.h
 *
 * Description:  
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/26/98        Shailesh        Added new case for sub systems.
 *      09/03/98        shailesh        Increased mino[]
 *      09/02/98        Shailesh        Added # defines for Enable List
 *                                      and trans List for SIR.
 *      08/07/98        Shailesh        Added few # defines for SIR
 *       9/95           MSM             Creation
 *       Nov 25 98	SSR		Added new constants and a member in
 *       				struct in defdata for CR # 179801371
 *       Mar 31 99	SSR		Increased CntxtName[] and CntxtDesc 
 *       				to 50  CR # MP 101
 *       Aug27 99	SSR		New #defines and structs for CM AIM
 *       				integration.
 */

#ifndef VDPdef_include
#define VDPdef_include

#define VDP_EQUIP       0
#define VDP_PIPING      1
#define VDP_HVAC        2
#define VDP_RWAY        3
#define VDP_BEAM        4
#define VDP_PLATE       5

#define VDP_COMPART     6

#define VDP_EQUIP_CLASS		"PmEquip"
#define	VDP_PIPING_CLASS	"PmPiping"
#define	VDP_HVAC_CLASS		"PmHVAC"
#define VDP_RWAY_CLASS		"PmRway"
#define	VDP_BEAM_CLASS		"PmBeam"
#define	VDP_PLATE_CLASS		"PmPlate"
#define	VDP_COMPART_CLASS	"PmCmpmnt"

#define VDPTSYSTEM		"System"
#define VDPTCOMPARTMENT		"Compartment"
#define VDPTZONE		"Zone"
#define VDPTUSERDEF		"User Defined"
#define VDPTBUDGET		"Budget"

#define VDPTSYSTEM_CODE       	'S'
#define VDPTCOMPARTMENT_CODE  	'C'
#define VDPTZONE_CODE         	'Z'
#define VDPTUSERDEF_CODE      	'U'
#define VDPTBUDGET_CODE      	'B'

#define	VDPSTBWT_CODE		0

#define	VDPNAME_LEN		21	/* 20 + \0 */
#define	VDPOBID_LEN		25	/* 24 + \0 */
#define VDPDESC_LEN		80	/* 79 + \0 */
#define	VDPESWBS_LEN	 	6	/*  5 + \0 */
#define VDPCLASS_NAME_LEN	9	/*  8 + \0 */

#define NB_REQ_DATA_VALUES	18

#define VDP_SHIPNAME		"SHIPNAME"
#define VDP_SHIPDESC		"SHIP_DESC"
#define VDP_SHIPID		"SHIP_ID"
#define VDP_ESWBS		"ESWBS"
#define VDP_ESWBS_DESC		"ESWBS_DESC"
#define VDP_BDGCTX_ID		"BUDGET_CTX_ID"
#define VDP_BDGCTX_TYPE		"BUDGET_CTX_TYPE"
#define VDP_BDGCTX_ST		"BUDGET_CTX_SUBTYPE"
#define VDP_BDGCTX_ST_DESC	"BUDGET_CTX_SUBTYPE_DESC"
#define VDP_BDGCTX_NAME		"BUDGET_CTX_NAME"
#define VDP_BDGCTX_DESC		"BUDGET_CTX_DESC"
#define VDP_PLCTX_ID		"PLACEMENT_CTX_ID"
#define VDP_PLCTX_TYPE		"PLACEMENT_CTX_TYPE"
#define VDP_PLCTX_ST		"PLACEMENT_CTX_SUBTYPE"
#define VDP_PLCTX_ST_DESC	"PLACEMENT_CTX_SUBTYPE_DESC"
#define VDP_PLCTX_NAME		"PLACEMENT_CTX_NAME"
#define VDP_PLCTX_DESC		"PLACEMENT_CTX_DESC"
#define VDP_FILEID		"FILE_ID"

#define PME_GLOBAL_DIR          ":IGENOD:PMEGlobal"
#define PME_REQ_DATA            ":PMReqData"
#define PME_ENABLED_LIST	":PMEEnabledList"
#define PME_TRANS_LIST		":PMETransList"
#define PME_TRANS_LIST_SAV	":PMETransListSav"
#define PME_WRKPKG		":PMEWorkPackage"
#define PME_EQP_LIST		":EqpBuffer"
#define PME_ZONE_LIST		":PMEZoneList"

struct VDPCtxInfo
{
  char		Type;
  int		SubType;
  char		SubTypeDesc[VDPDESC_LEN];
  char		Name[VDPNAME_LEN];
  char		CtxDesc[VDPDESC_LEN];
  char		CtxId[VDPOBID_LEN];
};

struct VDPShipDesc
{
  IGRchar	ShipId[VDPOBID_LEN];
  IGRchar	ShipName[VDPDESC_LEN];
  IGRchar	ShipDesc[VDPDESC_LEN];
};

struct VDPdefdata
{
  struct VDPShipDesc	Ship;
  struct VDPCtxInfo	PlacementCtx;
  struct VDPCtxInfo	BdgWtCtx;
  char			ESWBS[VDPESWBS_LEN];
  char			ESWBS_Desc[VDPDESC_LEN];
  char			File[VDPOBID_LEN];
};

struct VDPwrkPkg
{
  OM_S_OBJID		objid;
  int			NotesIndex;
};

/* This structure is for passing Notes back and forth between Command Object
   and the Workpackage Class */

struct VDPwrkPkg1
{
  OM_S_OBJID		objid;
  char			*Notes;
};

struct VDPEswbs
{
  IGRchar       ESWBS[VDPESWBS_LEN];
  IGRchar       ESWBS_Desc[VDPDESC_LEN];
};

struct VDPPlCtxTST
{
  IGRchar       Type;
  IGRint        SubType;
  IGRchar       SubTypeDesc[VDPDESC_LEN];
  IGRchar       ClassName[VDPCLASS_NAME_LEN];
};

struct VDPNameDesc
{
  IGRchar       CtxId[VDPOBID_LEN];
  IGRchar       CtxName[VDPNAME_LEN];
  IGRchar       CtxDesc[VDPDESC_LEN];
};

/* Additions for SIR */

#define PME                     0
#define SIR                     1

#define SIR_GLOBAL_DIR          ":IGENOD:SIRGlobal"
#define SIR_REQ_DATA            ":SRReqData"
#define SIR_ENABLED_LIST        ":SIREnabledList"
#define SIR_TRANS_LIST          ":SIRTransList"
#define SIR_TRANS_LIST_SAV      ":SIRTransListSav"
#define SIR_DIAG_LST		":SIRDiagramList"

//#define SR_FSI                  "System / SubSystem" CR # 179802020
#define SR_FSI                  "System"
#define SR_SUB_FSI              "Subsystem"
#define SR_ZNSYS                "Zone System "
#define SR_ZONE                 "Zone "
#define SR_UNIT                 "Unit "
 
#define SR_FSI_TYPE             1
#define SR_ZNSYS_TYPE           2
#define SR_ZONE_TYPE            3
#define SR_UNIT_TYPE            4
#define SR_SUB_FSI_TYPE         5 // CR # 179802020

#define VDP_SIR_EQUIP_CLASS     "SrEquip"
#define VDP_SIR_PIPING_CLASS    "SrPiping"
#define VDP_SIR_RWAY_CLASS      "SrRway"
#define VDP_SIR_HVAC_CLASS      "SrHvac"

#define SIR_CFG_NAME            "Configuration Name"
#define SIR_CFG_DESC            "Config. Item Desc."
#define SIR_CFG_ID              "Config. Item Id."
#define SIR_HULL_NAME           "Hull Name"
#define SIR_HULL_DESC           "HULL Desc"
#define SIR_HULL_ID             "HULL Id"
#define SIR_HULL_REV            "HULL Rev"
#define SIR_HULL_EFFTO          "HULL Effective To"
#define SIR_HULL_EFFFROM        "HULL Effective From"
#define SIR_MODCX_ID            "Model Context Id"
#define SIR_CNTX_NAME           "Context Name"
#define SIR_CNTX_TYP            "Context Type"
#define SIR_CNTX_ID             "Context Id"
#define SIR_CNTX_DESC           "Context Desc."
#define SIR_FILE_TYP		"File Type"
#define SIR_SEQ_NO		"Sequence No."
#define SIR_REF_PART		"RefPart"
#define SIR_REF_REV		"RefPartRev"
#define SIR_REF_MDC		"RefPartMdcObid"
#define SIR_REF_SIZE		"SrRefFlSize"

#define VDP_QUERY_CFGITEMS      100
#define VDP_QUERY_HULLS         101
#define VDP_QUERY_CTXS          102
#define VDP_QUERY_MODCX         103
#define VDP_POST_PLACMNT        106
#define VDP_POST_PART           105
#define VDP_DELETE_EBOM_REL     111
#define M_FILE			0
#define D_FILE			1
#define A_FILE			2
#define VDP_GET_CUR_REV		120
#define VDP_BASE_REVISE		124
#define VDP_BASELINE		122
#define VDP_REVISION		123
#define VDP_UPDATE_PLAC_MDC_RELN 125
#define VDP_GET_MDCOBID		126

struct SRPartStat
{
  char  mino[31];
  char  cage[6];
  double   qty;
};

struct VDPCntxt
{
  IGRchar       CntxtId[25];
  IGRchar       CntxtName[50];
  IGRchar       CntxtDesc[50];
};

struct VDPhulls
{
  IGRchar       HullId[25];
  IGRchar       HullName[21];
  IGRchar       HullDesc[151];
  IGRchar       HullRev[16];
  IGRchar       HullEffFrom[31];
  IGRchar       HullEffTo[31];
};

struct VDPCfgItms
{
  IGRchar       CfgId[25];
  IGRchar       CfgName[31];
  IGRchar       CfgDesc[61];
};


struct SRReqDat
{
  struct  VDPCfgItms CfgItm;
  struct  VDPhulls   Hull;
  struct  VDPCntxt   Cntxt;
  char    CntxTyp[20];
  int		FileTyp;
};

struct SRErrMsg
{
int   mfail;
char  errmsg[200];
};

struct SIRRefInfo
{
  char PdmPart[25];
  char PdmRev[5];
  char Mdcobid[25];
  int  UpdFlag;
  char UpdRev[5];
  char UpdMdcobid[25];
};

struct SIRRefPDMInfo
{
  char RefCat[128];
  char RefPart[128];
  char RefRev[128];
  char RefFileName[128];
};

struct SIRuidinfo
{
 int  obid;
 char uid[30];
};

/* nfm table columns for CM mangement */
#define CMENAB  "p_mrppart"
#define ARSEL   "p_mrpstruct"
#define DCCSEL  "p_explode"

/* End Additions for SIR    */

#endif  /* VDPdef_include */
