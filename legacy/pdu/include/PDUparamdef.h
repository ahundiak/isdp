/*********************************************************
 *** Definitions for the PDM/PDU Parametrics Subsystem ***
 *********************************************************/

#ifndef PDUparametrics
#define PDUparametrics	1

/* parameter types for macro parameters */
#define PDM_PARTYPE_DOUBLE	"double"
#define PDM_PARTYPE_TEXT	"text"
#define PDM_PARTYPE_COORDSYS	"referential"
#define PDM_PARTYPE_POINT	"point"
#define PDM_PARTYPE_MACRO	"macro"
#define PDM_PARTYPE_LINE	"line"
#define PDM_PARTYPE_CONIC	"conic"
#define PDM_PARTYPE_CIRCLE	"circle"
#define PDM_PARTYPE_ARC		"arc"
#define PDM_PARTYPE_LBS		"lbs"
#define PDM_PARTYPE_PLANE	"plane"
#define PDM_PARTYPE_CURVE	"curve"

/* I/O types for macro parameters */
#define PDM_IOTYPE_DYNAMIC	"DC"
#define PDM_IOTYPE_LOCATE	"DL"
#define PDM_IOTYPE_STATIC	"SC"
#define PDM_IOTYPE_OUTPUT	"DO"
#define PDM_IOTYPE_USER_DYN	"UD"

/* default data types for macro parameters */
#define PDM_DATATYPE_DOUBLE	"double"
#define PDM_DATATYPE_TEXT	"char(80)"
#define PDM_DATATYPE_COORDSYS	"char(2)"
#define PDM_DATATYPE_POINT	"char(2)"
#define PDM_DATATYPE_MACRO	"char(20)"
#define PDM_DATATYPE_LINE	"char(2)"
#define PDM_DATATYPE_CONIC	"char(2)"
#define PDM_DATATYPE_CIRCLE	"char(2)"
#define PDM_DATATYPE_ARC	"char(2)"
#define PDM_DATATYPE_LBS	"char(2)"
#define PDM_DATATYPE_PLANE	"char(2)"
#define PDM_DATATYPE_CURVE	"char(2)"

struct PDUmacro_definition
  {
   char		*family;
   MEMptr	definition_bufr;
   struct PDUmacro_definition *next;
  };
#endif
