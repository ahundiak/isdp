/* General purpose structure for names and numbers */
typedef struct list 
{
    char   *name;
    int    no;
    struct list *next;
} *UTIlist;

struct gen
{
    char  name[80];
    int   val;
};

/* File storage structure */
struct fs
{
    char  node_name[20];
    char  user_name[14];
    char  passwd[30];
    char  path[50];
    char  co_file_name[20];
    char  op_sys[6]; 			/* "VMS"  -> VMS 
					   "CLIX" -> Clipper 
					   "VM/SP -> IBM
					*/	
    int   protocol;			/* bit 0 - set for XNS
					   bit 1 - set for TCPIP
					   bit 2 - set for DECnet 
					   remaining bits clear (0)
					*/
    char  mach_id[10];			/* machine id */
    char  device_type[5];		/* device_type */
    long  sano;				/* storage area number */
};

struct restore
{
    int	   archive_no;			/* archive file belongs to */
    int    storage_no;			/* storage # for restore */
    int	   restore_no;			/* used in updating database */
};

/* Selected pending files' details linked list */
typedef struct pending_files
{
    struct restore rstr;		/* restore information */
    struct gen node;			/* node values for restore */
    char   *label;			/* archive label file is in */
    char   *saveset;			/* archive saveset file is in */
    char   *ci_file_name;			/* local filename */
    struct gen cat;			/* catalog information */
    struct gen item;			/* item information */
    struct fs  home;			/* file storage location */
    char   *rev;			/* revision in <catalog> */
    int	   ver;				/* version in <f_catalog> */
    int    file_no;			/* file number */
    int    state;			/* state pertinent to UTILITIES */
    int    flow_state;			/* state pertinent to workflow */
    int	   size;			/* file size */
    struct gen type;			/* file information */
    char   *set_indicator;		/* set indicator flag ( Y or N ) */
    struct gen format;			/* old filename format */
    int    project_no;			/* project number */
    struct pending_files *next;
} *UTIpending;

/* Database entry for NFMarchives table */
typedef struct nfmarchives
{
    int  archive_no;			/* archive number */
    char *label;			/* label holding archive */
    char *saveset;			/* saveset in label */
    int  storageno;			/* chosen archive storage device */
    char *archive_path;			/* path in storage device */
    char *archive_date;			/* date of archive */
    char *archive_time;			/* time of archive */
    char *archive_method;		/* "S"- ANSI ; "I"- scpio */
    int  archive_copies;		/* pointer to original archive */
    int  archive_size;			/* size in bytes of archive */
    int  no_vol;			/* number of volumes for archive */
} *NFMarch;

/* Database entry for NFMsavesets table */
typedef struct nfmsavesets
{
    int  archive_no;			/* archive number */
    struct list cat;			/* catalog information */
    struct list item;			/* item information */
    char *rev;				/* item revision */
    int  ver;				/* file version */
    char *state;			/* "A"- currently archived
					   "I"- has been restored
					*/
    char *restore_date;			/* date restored */
    int  restore_no;			/* restore group number */
    struct nfmsavesets *next;
} *NFMsave;

/* Global 'convenience' structure combining NFMnodes and NFMstoragearea
 * information concerning the selected archive location 
 */
typedef struct archive_loc
{
    char *label;
    char *saveset;
    struct gen node;
    char *user_name;
    char *password;
    char *path_name;
    char *device_type;
    char *device_name;
    char *op_sys;			/* either "VMS", "CLIX", "VM/SP" */
    int  protocol;			/* bit 0 - XNS
					   bit 1 - TCP/IP
					   bit 2 - DECnet */
} *UTIarch;

/* Linked list structure for user request ( Display purposes )*/
typedef struct file_spec
{
    char *cat;
    char *file;
    char *rev;
    int  *ver;
    struct file_spec *next;
} *UTIfiles;
