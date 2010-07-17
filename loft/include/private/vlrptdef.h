#ifndef	vlrpt_include
#define	vlrpt_include

/* Keywords for <VLbalance> states */
#define	VL_S_BAL_STA	"vl-rp-pb-Start"
#define	VL_S_BAL_RPT	"vl-rp-pb-Report"
#define	VL_S_BAL_BAS	"vl-rp-pb-BasePoints"
#define	VL_S_BAL_END	"vl-rp-pb-End"

/* Keywords for <VLbalance> functions */
#define	VL_F_BAL_IDX	"vl-rp-pb-Index"
#define	VL_F_BAL_NAM	"vl-rp-pb-Name"
#define	VL_F_BAL_XAN	"vl-rp-pb-Xangle"
#define	VL_F_BAL_YAN	"vl-rp-pb-Yangle"
#define	VL_F_BAL_ZAN	"vl-rp-pb-Zangle"
#define	VL_F_BAL_NUM	"vl-rp-pb-Number"
#define	VL_F_BAL_BBX	"vl-rp-pb-Xbalance"
#define	VL_F_BAL_BBY	"vl-rp-pb-Ybalance"
#define	VL_F_BAL_BBZ	"vl-rp-pb-Zbalance"
#define	VL_F_BAL_BSX	"vl-rp-pb-Xinship"
#define	VL_F_BAL_BSY	"vl-rp-pb-Yinship"
#define	VL_F_BAL_BSZ	"vl-rp-pb-Zinship"

/* Keywords for <VLpinjig> states */
#define	VL_S_PIN_STA	"vl-rp-pp-Start"
#define	VL_S_PIN_TIT	"vl-rp-pp-pin-Title"
#define	VL_S_PIN_RPT	"vl-rp-pp-pin-Report"
#define	VL_S_CRN_TIT	"vl-rp-pp-crn-Title"
#define	VL_S_CRN_RPT	"vl-rp-pp-crn-Report"
#define	VL_S_PNL_TIT	"vl-rp-pp-pnl-Title"
#define	VL_S_PNL_RPT	"vl-rp-pp-pnl-Report"
#define	VL_S_PIN_END	"vl-rp-pp-End"

/* Keywords for <VLpinjig> functions */
#define	VL_F_PIN_OCC	"vl-rp-pp-Name"
#define	VL_F_PIN_PIN	"vl-rp-pp-PinNumber"
#define	VL_F_PIN_CRN	"vl-rp-pp-CornerNumber"
#define	VL_F_CRN_NAM	"vl-rp-pp-crn-Name"
#define	VL_F_CRN_XPT	"vl-rp-pp-crn-Xposition"
#define	VL_F_CRN_YPT	"vl-rp-pp-crn-Yposition"
#define	VL_F_CRN_HEI	"vl-rp-pp-crn-Height"
#define	VL_F_CRN_PIN	"vl-rp-pp-crn-PinName"
#define	VL_F_PIN_COL	"vl-rp-pp-pin-Column"
#define	VL_F_PIN_LIN	"vl-rp-pp-pin-Line"
#define	VL_F_PIN_XPT	"vl-rp-pp-pin-Xposition"
#define	VL_F_PIN_YPT	"vl-rp-pp-pin-Yposition"
#define	VL_F_PIN_ZPT	"vl-rp-pp-pin-Zposition"
#define	VL_F_PIN_HEI	"vl-rp-pp-pin-Height"
#define	VL_F_PIN_ANG	"vl-rp-pp-pin-Angle"
#define	VL_F_PIN_IDX	"vl-rp-pp-pin-Index"
#define	VL_F_PIN_NAM	"vl-rp-pp-pin-Name"

/* Keywords for <VLtplMgr> states */
#define	VL_S_CHT_TPL_STA	"vl-rp-tc-reg-Start"
#define	VL_S_CHT_TPL_TIT	"vl-rp-tc-reg-Report"
#define	VL_S_CHT_TPL_RPT	"vl-rp-tc-reg-End"
#define	VL_S_CHT_SPI_TIT	"vl-rp-tc-spi-Title"
#define	VL_S_CHT_SPI_RPT	"vl-rp-tc-spi-Report"
#define	VL_S_CHT_TPL_END	"vl-rp-tc-spi-End"

#define	VL_S_HEI_TPL_STA	"vl-rp-th-Start"
#define	VL_S_HEI_TPL_TIT	"vl-rp-th-Title"
#define	VL_S_HEI_TPL_RPT	"vl-rp-th-Report"
#define	VL_S_HEI_TPL_END	"vl-rp-th-End"

/* Keywords for <VLtplMgr> height functions */
#define	VL_F_HEI_TPL_SET_STP	"vl-rp-th-SetStep"
#define	VL_F_HEI_TPL_GET_OCC	"vl-rp-th-ManagerName"
#define	VL_F_HEI_TPL_GET_SUB	"vl-rp-th-TemplateName"
#define	VL_F_HEI_TPL_GET_STP	"vl-rp-th-GetStep"
#define	VL_F_HEI_TPL_GET_HEI	"vl-rp-th-Height"

/* Keywords for <VLtplMgr> CHT functions */
#define	VL_F_CHT_TPL_NAM	"vl-rp-tc-reg-Name"
#define	VL_F_CHT_TPL_CHT	"vl-rp-tc-reg-ChordHeight"
#define	VL_F_CHT_TPL_ANG	"vl-rp-tc-reg-Angle"
#define	VL_F_CHT_TPL_HEI	"vl-rp-tc-reg-Height"
#define	VL_F_CHT_TPL_LEA	"vl-rp-tc-reg-LeanDirection"
#define	VL_F_CHT_SPI_NAM	"vl-rp-tc-spi-Name"
#define	VL_F_CHT_SPI_FRA	"vl-rp-tc-spi-Frame"
#define	VL_F_CHT_SPI_CHT	"vl-rp-tc-spi-ChordHeight"
#define	VL_F_CHT_SPI_HEI	"vl-rp-tc-spi-Height"

/* Keywords for <VLstifBend> states */
#define	VL_S_HEI_BST_STA	"vl-rp-ih-Start"
#define	VL_S_HEI_BST_TIT	"vl-rp-ih-Title"
#define	VL_S_HEI_BST_RPT	"vl-rp-ih-Report"
#define	VL_S_HEI_BST_END	"vl-rp-ih-End"

/* Keywords for <VLstifBend> height functions */
#define	VL_F_HEI_BST_SET_STP	"vl-rp-ih-SetStep"
#define	VL_F_HEI_BST_GET_OCC	"vl-rp-ih-MacroName"
#define	VL_F_HEI_BST_GET_SUB	"vl-rp-ih-CurveName"
#define	VL_F_HEI_BST_GET_STP	"vl-rp-ih-GetStep"
#define	VL_F_HEI_BST_GET_HEI	"vl-rp-ih-Height"

/* Keywords for <Stretch Values> states */
#define	VL_STR_VAL_TIT   	"vl-rp-str-Title"
#define	VL_STR_VAL_RPT		"vl-rp-str-Report"
#define	VL_STR_VAL_END		"vl-rp-str-End"

/* Keywords for <Stretch Values> functions */
#define	VL_STR_VAL_PlNa		"vl-rp-str-PlateName"
#define	VL_STR_VAL_GetU		"vl-rp-str-GetUQuadran"
#define	VL_STR_VAL_GetV		"vl-rp-str-GetVQuadran"
#define	VL_STR_VAL_GetVl	"vl-rp-str-GetValue"

/* Keywords for <Steel Band> states */
#define	VL_STE_BND_STA   	"vl-rp-sb-Start"
#define	VL_STE_BND_TIT   	"vl-rp-sb-Title"
#define	VL_STE_BND_RPT		"vl-rp-sb-Report"
#define	VL_STE_BND_END		"vl-rp-sb-End"

/* Keywords for <Steel Band> functions */
#define	VL_STE_BND_BND		"vl-rp-sb-BandNumber"
#define	VL_STE_BND_UNI		"vl-rp-sb-UnitNumber"
#define	VL_STE_BND_DES		"vl-rp-sb-Description"
#define	VL_STE_BND_JOB		"vl-rp-sb-JobNumber"
#define	VL_STE_BND_NUM		"vl-rp-sb-PointNumber"
#define	VL_STE_BND_IDX		"vl-rp-sb-PointIndex"
#define	VL_STE_BND_NAM		"vl-rp-sb-LocationName"
#define	VL_STE_BND_DST		"vl-rp-sb-StartDistance"
#define VL_STE_BND_STK		"vl-rp-sb-Stock"
#define VL_STE_BND_ETK          "vl-rp-sb-EndStock"

/* Keywords for <Key Line> states */
#define	VL_KEY_LIN_STA   	"vl-rp-kl-Start"
#define	VL_KEY_LIN_TIT   	"vl-rp-kl-Title"
#define	VL_KEY_LIN_T_H   	"vl-rp-kl-TransverseHeader"
#define	VL_KEY_LIN_T_R   	"vl-rp-kl-TransverseReport"
#define	VL_KEY_LIN_L_H   	"vl-rp-kl-LongitudinalHeader"
#define	VL_KEY_LIN_L_R   	"vl-rp-kl-LongitudinalReport"
#define	VL_KEY_LIN_D_H   	"vl-rp-kl-DiagonalHeader"
#define	VL_KEY_LIN_D_R   	"vl-rp-kl-DiagonalReport"
#define	VL_KEY_LIN_END   	"vl-rp-kl-End"

/* Keywords for <Key Line> functions */
#define	VL_KEY_LIN_UNI		"vl-rp-kl-UnitNumber"
#define	VL_KEY_LIN_JOB		"vl-rp-kl-JobNumber"
#define	VL_KEY_LIN_PRO		"vl-rp-kl-ProcessName"
#define	VL_KEY_LIN_LIN		"vl-rp-kl-MoldedLine"
#define	VL_KEY_LIN_NAM		"vl-rp-kl-LocationName"
#define	VL_KEY_LIN_DST		"vl-rp-kl-Distance"


/* ACrg_coll names */
#define	VLRPT_HEIGHT_STEP	"height-step"

#endif
