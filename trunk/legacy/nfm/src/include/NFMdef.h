#ifndef NFMdef
#define NFMdef

#define  WILD_CARD   "*"
#define  DELIM       ':'
#define  PROMPT      "Enter "

#define  INIT_CMD     1
#define  FM_CMD       2
#define  EXIT_CMD     3

#define   MAX_INITcmds   4
#define   INIT_help      0
#define   INIT_functions 1
#define   INIT_return    2
#define   INIT_exit      3

#define   MAX_FMcmds     11
#define   FMhelp         0
#define   FMcreate_db    1
#define   FMcreate_cat   2
#define   FMadd_file     3
#define   FMlist_files   4
#define   FMcheck_in     5
#define   FMcheck_out    6
#define   FMmod_attr     7
#define   FMdel_file     8
#define   FMreturn       9
#define   FMexit         10

#define   NFM_DBINFO_TABLE    1
#define   NFM_DBINFOH_TABLE   2
#define   NFM_FILE_TABLE      3
#define   NFM_FILEH_TABLE     4
#define   NFM_NODES_TABLE     5
#define   NFM_USERS_TABLE     6
#define   NFM_USERSH_TABLE    7
#define   NFM_ARCHIVE_TABLE   8
#define   NFM_SYNONYMS_TABLE  9
#define   NFM_VIRTUAL_TABLE   10
#define   NFM_SET_TABLE       11
#define   NFM_LOC_TABLE       12
#define   NFM_LOCH_TABLE      13
#define   NFM_ALL_DBINFO      14
#define   NFM_ALL_FILE        15
#define   NFM_ALL_USERS       16
#define   NFM_ALL_LOC         17

#define   NFM_VALIDATE_PROJECT	50
#define   NFM_VALIDATE_CATALOG	52
#define   NFM_VALIDATE_ITEM	54
#define   NFM_VALIDATE_REVISION 56
#define   NFM_VALIDATE_SEARCH	58
#define   NFM_VALIDATE_SORT	60
#define   NFM_VALIDATE_WK_AREA	62
#define   NFM_VALIDATE_ST_AREA	64
#define   NFM_VALIDATE_SET_ITEM 66
#define   NFM_VALIDATE_SET_REV  68
#define   NFM_VALIDATE_NODE     70
#define   NFM_VALIDATE_WORKFLOW 72
#define   NFM_VALIDATE_ACL      74
#define   NFM_VALIDATE_USER	76

#define   NFM_BUFFER_SIZE     7000
#define   NFM_BUFFER_TERM     '\1'
#define   NFM_VERSION         "1.0"
#define   NFM_DEFAULT_NULL    ""

typedef int NFMfunction;

#endif
