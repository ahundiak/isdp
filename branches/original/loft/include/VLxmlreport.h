
#ifndef vlxmlreport_include
#define vlxmlreport_include

#define ALL_LOFT		0
#define STEEL_BAND		1
#define BENDING_LINE		2
#define BALANCEMENT		3
#define PIN_JIG			4
#define TEMPLATE		5
#define KEY_LINE		6

#define SMS_PRS			"SMS_PRS"
#define SMS_PRS_UNIT		"SMS_PRS_UNIT"

#define SMS_STRUCT_INFO		"SMS_STRUCT_INFO"

#define SMS_STEELBANDS		"SMS_STEELBANDS"
#define SMS_STEELBAND		"SMS_STEELBAND"
#define JOB_NUMBER		"JOB_NUMBER"
#define JOB_DESC		"JOB_DESC"
#define XML_DATE		"DATE"
#define XML_TIME		"TIME"
#define SMS_STEELBAND_INFO	"SMS_STEELBAND_INFO"
#define BAND_NUMB		"BAND_NUMB"
#define START_STOCK		"START_STOCK"
#define END_STOCK		"END_STOCK"
#define SMS_STEELBAND_DATA	"SMS_STEELBAND_DATA"
#define XML_INDEX		"INDEX"
#define XML_NAME		"NAME"
#define XML_DISTANCE		"DISTANCE"

#define SMS_BENDLINES		"SMS_BENDLINES"
#define SMS_BENDLINE		"SMS_BENDLINE"
#define	STIF_NAME		"STIF_NAME"
#define WEB_SIDE		"WEB_SIDE"
#define FIB_RATIO		"FIB_RATIO"
#define SMS_STEP_INFO		"SMS_STEP_INFO"
#define SMS_CRV_INFO		"SMS_CRV_INFO"
#define STEP_VALUE		"STEP_VALUE"
#define BEND_HEIGHT		"BEND_HEIGHT"

#define SMS_BALANCEMENTS	"SMS_BALANCEMENTS"
#define SMS_BALANCEMENT		"SMS_BALANCEMENT"
#define NUM_ELEM		"NUM_ELEM"
#define X_ANGLE			"X_ANGLE"
#define Y_ANGLE			"Y_ANGLE"
#define Z_ANGLE                 "Z_ANGLE"
#define SMS_CORNER_INFO		"SMS_CORNER_INFO"
#define CORNER_INDEX		"CORNER_INDEX"
#define SMS_ON_GROUND		"SMS_ON_GROUND"
#define ON_GROUND_X		"ON_GROUND_X"
#define ON_GROUND_Y		"ON_GROUND_Y"
#define ON_GROUND_Z             "ON_GROUND_Z"
#define	IN_SHIP_X		"IN_SHIP_X"
#define IN_SHIP_Y		"IN_SHIP_Y"
#define IN_SHIP_Z		"IN_SHIP_Z"

#define SMS_PINJIGS		"SMS_PINJIGS"
#define SMS_PINJIG		"SMS_PINJIG"
#define SMS_PIN_DATA		"SMS_PIN_DATA"
#define PIN_DATA		"PIN_DATA"
#define COL_NO			"COL_NO"
#define ROW_NO			"ROW_NO"
#define PIN_X_POS		"PIN_X_POS"
#define PIN_Y_POS               "PIN_Y_POS"
#define PIN_Z_POS               "PIN_Z_POS"
#define PIN_HEIGHT		"PIN_HEIGHT"
#define PIN_ANGLE		"PIN_ANGLE"
#define SMS_CORNER_DATA		"SMS_CORNER_DATA"
#define CORNER_DATA		"CORNER_DATA"
#define REF_PIN_NAME		"REF_PIN_NAME"
#define	SMS_PANEL_CORNER_DATA	"SMS_PANEL_CORNER_DATA"

#define SMS_TEMPLATES		"SMS_TEMPLATES"
#define SMS_TEMPLATE_SET	"SMS_TEMPLATE_SET"
#define SMS_TEMPLATE		"SMS_TEMPLATE"
#define TEMP_HEIGHT		"TEMP_HEIGHT"
#define NUM_TEMP		"NUM_TEMP"
#define TEMP_ANGLE		"TEMP_ANGLE"
#define TEMP_LEAN_DIR		"TEMP_LEAN_DIR"
#define SMS_REG_TEMP		"SMS_REG_TEMP"
#define REG_INFO		"REG_INFO"
#define CHT_INFO		"CHT_INFO"
#define FRM_NAME		"FRM_NAME"
#define CHT_HEIGHT		"CHT_HEIGHT"
#define SMS_SPI_TEMP		"SMS_SPI_TEMP"

#define SMS_KEYLINES		"SMS_KEYLINES"
#define SMS_KEYLINE		"SMS_KEYLINE"
#define SMS_TRANS_INFO		"SMS_TRANS_INFO"
#define SMS_LONG_INFO		"SMS_LONG_INFO"
#define SMS_DIAG_INFO		"SMS_DIAG_INFO"
#define SMS_KEYLINE_DATA	"SMS_KEYLINE_DATA"
#define PRO_DATA		"PRO_DATA"
#define MOLD_LINE_NAME		"MOLD_LINE_NAME"
#define LOCATION_NAME		"LOCATION_NAME"
#define SMS_ROW_DATA		"SMS_ROW_DATA"
#define SMS_COL_DATA		"SMS_COL_DATA"
#define SMS_ROW_NAME		"SMS_ROW_NAME"
#define SMS_COL_NAME            "SMS_COL_NAME"

#if defined(__cplusplus)
extern "C" {
#endif

extern IGRlong VLreportLoftObjectsToXml __(( IGRlong             *msg,
                                             IGRint              type,
                                             IGRint              count,
                                             struct GRobj_env    *objOE,
					     IGRchar		 **buffer,
                                             IGRchar             *fileName ));

#omdef vlxml$Report(  msg,
                      type,
                      count = 1,
                      objOE,
		      buffer = NULL ^
                      fileName = NULL )

VLreportLoftObjectsToXml( (msg), (type), (count), (objOE), (buffer), (fileName) )
#endomdef

extern IGRlong VLreportSteelBandsToXml __(( IGRlong 		*msg, 
					    IGRint 		count, 
				    	    struct GRobj_env    *objOE, 
					    IGRchar             **buffer,
					    IGRchar 	        *fileName ));

extern IGRlong VLreportBendingLinesToXml __(( IGRlong           *msg,
					      IGRint		count,
					      struct GRobj_env	*objOE,
					      IGRchar           **buffer,
					      IGRchar		*fileName ));

extern IGRlong VLreportBalancementToXml __(( IGRlong           *msg,
                                             IGRint            count,
                                             struct GRobj_env  *objOE,
					     IGRchar           **buffer,
                                             IGRchar           *fileName ));

extern IGRlong VLreportPinJigsToXml __(( IGRlong           *msg,
                                         IGRint            count,
                                         struct GRobj_env  *objOE,
					 IGRchar           **buffer,
                                         IGRchar           *fileName ));

extern IGRlong VLreportTemplatesToXml __(( IGRlong           *msg,
                                           IGRint            count,
                                           struct GRobj_env  *objOE,
					   IGRchar           **buffer,
                                           IGRchar           *fileName ));

extern IGRlong VLreportKeyLinesToXml __(( IGRlong           *msg,
                                          IGRint            count,
                                          struct GRobj_env  *objOE,
					  IGRchar           **buffer,
                                          IGRchar           *fileName ));

#if defined(__cplusplus)
}
#endif

#endif
