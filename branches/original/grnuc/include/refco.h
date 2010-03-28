/*
Name
        refco.h

Description
        This file contains definitions and structures used by the reference
        file commands.

History
        mrm     07/15/92    creation
                08/19/92    added flags to GRrevasm_data
*/

#ifndef refco_include
#define refco_include

#include "OMminimum.h"
#include "listref.h"

/*
        Definitions and structures used to convey reference file information.
        Used with the listref family of utilities.
*/

#define FileNamePresent         0x00000001
#define OSNamePresent           0x00000002
#define CantReadFile            0x00000004
#define NoAttachmentsFound      0x00000008
#define CantExeFile             0x00000010
#define NotDesignFile           0x00000020
#define SelfAttachedFile        0x00000040
#define HasSelfAttachedFile     0x00000080
#define HasCyclicAttachments    0x00000100
#define CantFindEXNUC           0x00000200

typedef struct _GRreffiledata
{
    /* flags regarding this structure */
    int flags;

    /* internal osname of the file */
    char intosname[OM_K_MAXINTOSNAME_LEN];

    /* pointer to filename or osname, depending on which is found on disk */
    char *name;

    /* from GRgraphics */
    short properties;
    short level;

    /* from GRvg */
    struct IGRdisplay display_attr;

    /* from GRreffile */
    char filename[MAXPATHLEN];
    char osname[MAXPATHLEN];
    char saved_view[MAXPATHLEN];
    char description[MAXPATHLEN];
    char scale_factor[MAXPATHLEN];
    unsigned long ref_properties;
    int dp_levels[32];
    double range[6];
    double vw_volume[6];
    double vw_rotation[16];
    double vw_origin[3];
    double master_to_ref_matrix[16];
    double ref_to_master_matrix[16];
}   GRreffiledata;

#define CopyOperation           0x00000001
#define ReplaceOperation        0x00000002
#define OverWriteOperation      0x00000004
#define NoChangeOperation       0x00000008
#define NoOperation             0x00000010
#define EditOperation           0x00000020

typedef struct _GRreffilelist
{
    struct _GRreffilelist *parent;  /* file to which this is attached */
    struct _GRreffilelist *next;    /* next file in the list, as seen on */
                                    /* the Revise Assembly form */
    struct _GRreffilelist *child;   /* file attached to this one */
    struct _GRreffilelist *sibling; /* next file attached to the parent */
                                    /* of this file */
    int flags;                      /* misc info (operation type) */
    int depth;                      /* nesting depth in the ref tree */
    GRreffiledata instance;         /* attachment specifics */
}   GRreffilelist;

/*
        Definitions and structures used by the Revise Assembly form.
*/

#define FileNameField           12
#define ClearAllButton          17
#define SetAllButton            16
#define PreservePathToggle      19
#define PathField               20
#define AutoNamingToggle        23
#define SuffixField             24

#define NestLevelColumn         0
#define CurrentNameColumn       1
#define OperationColumn         2
#define NewNameColumn           3

#define CopyAssemblyFormLabel   92263
#define IndentWidth             2

#define ChangeRefAttachments    0x00000001

typedef struct _GRrevasm_data
{
    int flags;
    int total_file_count;
    char suffix[16];
    OMuword command_os;
    OM_S_OBJID command_id;
    GRreffilelist **list;
}   GRrevasm_data;

/*
        The following definitions are used with the GRlist_ref_attachment
        function's "flag" argument.
*/
#define GRDefaultAttachInfo     0x00000000
#define GRMultipleAttachments   0x00000001
#define GRNestedInfo            0x00000002

#endif
