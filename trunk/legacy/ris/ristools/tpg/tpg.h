/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
#define MALLOC(var, type) \
{ \
	(var) = (type *)malloc(sizeof(type)); \
	memset((var), 0, sizeof(type)); \
}
#define ISTOKEN(name)	(!strncmp("RIS_TOK", (name), sizeof("RIS_TOK")-1))
#define VERBOSE(x)	if (verbose) printf x
#define UMS_EXT_MAX		32

#if defined(unix)
#define PATH_CHAR '/'
#endif
#if defined (WIN32) || defined(DOS)
#define PATH_CHAR '\\'
#endif

#if defined(unix)
#define OPEN_TO_READ_MODE	"r"
#define OPEN_TO_WRITE_MODE	"w"
#endif
#if defined(WIN32) || defined(DOS)
#define OPEN_TO_READ_MODE	"rt"
#define OPEN_TO_WRITE_MODE	"wt"
#endif

typedef struct msg_s
{
	char            name[48];
	char            msg[256];
	struct msg_s    *next;
} msg_s;

typedef struct name_s
{
	char			name[256];
	struct name_s	*next;
} name_s;

typedef struct code_s
{
	int				line;
	char			*data;
} code_s;

typedef struct data_s
{
	char			name[32];
	struct code_s	*code;
	struct data_s	*next;
} data_s;

typedef struct rule_s
{
	struct data_s	*data;
	struct data_s	*first;
	struct code_s	*code;
	struct rule_s	*next;
} rule_s;

typedef struct prod_s
{
	char			name[32];
	char			filename[32];
	char			errorname[48];
	char			first_generated;
	char			used;
	char			secondary_call;
	struct name_s	*preprocs;
	struct code_s	*code;
	struct rule_s	*rule;
	struct prod_s	*next;
} prod_s;

#ifdef DEFINE_GLOBALS
#define EXTERN
#define INIT(x)		= x
#else
#define EXTERN	extern
#define INIT(x)
#endif

EXTERN	int		in_line;
EXTERN	char	*in_file;
EXTERN	FILE	*in_fp;

EXTERN	char	verbose					INIT(0);
EXTERN	char	rules_file[256]			INIT("");
EXTERN	char	err_msg_data_file[256]	INIT("");
EXTERN	char	ums_msg_data_file[256]	INIT("");
EXTERN	char	prod_msg_data_file[256]	INIT("");
EXTERN	char	tok_msg_data_file[256]	INIT("");
EXTERN	char	first_file[256]			INIT("");
EXTERN	char	declare_file[256]		INIT("");
EXTERN	char	objects_file[256]		INIT("");
EXTERN	char	keywords_file[256]		INIT("");
EXTERN	name_s	*include_file_list		INIT(NULL);
EXTERN	name_s	*add_keyword_list		INIT(NULL);
EXTERN	name_s	*non_keyword_list		INIT(NULL);
EXTERN	prod_s	*prod_list				INIT(NULL);

