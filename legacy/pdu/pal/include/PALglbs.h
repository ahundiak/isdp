
#define MAX_CATALOGS 2000
#define TBL_LEN      20

#define MAX_LEVELS   25

#define SELECT_PART  1
#define PLACE_PART   2

#define COMM_ATTRIBS 3
#define CATALOG_SELECTED 2
#define SUCCESS 1 

#define SPpart_F        100
#define SPpart_SUB_F    111
#define MAX_ROWS_RTVD	50

/* Columns on the Select Part form */
#define ATTR_COL	0
#define DATA_COL	1
#define OPER_COL	2
#define SEARCH_COL	3
#define CATALOG        39
#define MAX_ROWS_RTVD   50

#define MAX_DYN         10

#define EXP_MAX_LEN     128

#define PLCMNT_STD_INTF 0
#define PLCMNT_MAC_INTF 1
#define PLCMNT_MOD_PART 2

#define MemCheck(ptr) \
	if (ptr == NULL ) { \
		_pdm_debug("Memory allocation failed",0); \
		return(0);\
	}

#define MyFree(ptr) \
	if( ptr != NULL ) { \
		free( (char *)ptr) ; \
		ptr = NULL ; \
	}
