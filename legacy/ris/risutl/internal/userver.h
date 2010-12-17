/* Do not alter this SPC information: $Revision: 1.2.9.1 $ */
/*
**	NAME:							userver.h
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	REVISION HISTORY:
*/
 
#ifdef USERVER_GLOBAL_DEFINE
# define USERVER_EXTERN
# define USERVER_INIT(value) = value
#else
# define USERVER_EXTERN extern
# define USERVER_INIT(value)
#endif

/*
**	INCLUDES
*/

/*
**	DEFINES
*/
#ifdef NO_USV_DBG
#define USV_DBG(s)
#else
#define USV_DBG(s)	if (RISusv_debug) {RIScom_output_debug s;}
#endif

#ifndef STRING
#define STRING(s) ((s)?(s):"NULL")
#endif

#define CHARACTER_BIT   0x0001
#define DECIMAL_BIT     0x0002
#define INTEGER_BIT     0x0004
#define SMALLINT_BIT    0x0008
#define REAL_BIT        0x0010
#define DOUBLE_BIT      0x0020
#define TIMESTAMP_BIT   0x0040
#define UNSUPPORTED_BIT 0x0080
#define RIS_BLOB_BIT 	0x0100
#define RIS_TEXT_BIT 	0x0200
#define DATATYPE_COUNT   10

/*
**	TYPES
*/
typedef struct column_info_s {
	int		modified;
	char	column_name[32];
	long	i_column_name;
	int		position;
	long	i_position;
	int		ris_type;
	long	i_ris_type;
	char	ris_type_string[12];
	long	i_ris_type_string;
	char	dbms_type_string[32];
	long	i_dbms_type_string;
	unsigned int		char_max_length;
	long	i_char_max_length;
	int		prec;
	long	i_prec;
	int		scale;
	long	i_scale;
	char	nullable[4];
	long	i_nullable;
} column_info_s;

/*
**	VARIABLES
*/
USERVER_EXTERN int	RISusv_debug		USERVER_INIT(0);
