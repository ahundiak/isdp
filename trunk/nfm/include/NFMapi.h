#ifndef NFM_API_H
#define NFM_API_H

#include "NFMschema.h"     /* Character array size definitions. */
 
/*  This group of definitions is used for the NFMget_file_information and
    NFMdefine_file_information functions. These function are used to associate
    files to items, disassociate files from items, and to change item file
    information. */
 
#define NFM_ADD_FILE_TO_ITEM            1    /* Associate file to item. */
#define NFM_DELETE_FILE_FROM_ITEM       2    /* Disassociate file from item. */
#define NFM_CHANGE_FILE_INFORMATION     3    /* Change file information. */
 
 
/*  The WORKFLOW definitions are used with the NFMwf_info structure. They
    specify whether or not to use the item's workflow to validate user access
    for the command and to move the item/set to the next state in its workflow
    during checkin, checkout, and copy file operations. */
 
#define NFM_NO_WORKFLOW          0    /* Don't validate user access or move
                                         the item to the next state in its
                                         workflow. */
#define NFM_WORKFLOW             1    /* Use the item's workflow to validate
                                         user access and move the item to the
                                         next state in its workflow. */
 
/*  The NFMwf_info structure is an argument to NFMcheckin_item,
    NFMcheckout_item, NFMcopy_item_files, NFMcheckin_set, NFMcheckout_set, and
    NFMcopy_set_files. It is used to specify whether or not to use an item's
    workflow during checkin, checkout and copy file operations. The workflow
    may be used to validate user access to the command and to move an item to
    the next state in its workflow. */
 
struct NFMwf_info
    {
    short workflow;          /* Whether or not to use workflow. Possible
                                values:
                                NFM_NO_WORKFLOW;
                                NFM_WORKFLOW. */
 
    /* If workflow = NFM_WORKFLOW, command, workflow_name, project_name, and
       app_name have the information needed to call validate_user_access and
       set_to_state. */
 
    char  command [NFM_COMMANDNAME+1];           /* Command to execute. */
    char  workflow_name [NFM_WORKFLOWNAME+1];    /* Workflow the item is
                                                    following. */
    char  project_name [NFM_PROJECTNAME+1];      /* Project to which item
                                                    belongs. */
    char  app_name [NFM_APPLICATION+1];          /* Application name. */
    };
 
 
/*  This group of definitions is used for the NFMoperation structure. The
    NFMoperation structure is an argument to NFMcheckin_item,
    NFMcheckout_item, NFMcopy_item_files, NFMcheckin_set, NFMcheckout_set, and
    NFMcopy_set_files. */
 
/*  The TRANSFER definitions are used for the NFMoperation structure to
    specify how to transfer files during checkin, checkout, and copy file
    operations. */
 
#define NFM_NO_TRANSFER             0 /* Don't transfer the files (checkin/out
                                         in place). */
#define NFM_CONDITIONAL_TRANSFER    1 /* Transfer files only if no files are
                                         overwritten (use local file manager).*/
#define NFM_TRANSFER                2 /* Transfer files. */
 
/*  The DELETE definitions are used in the NFMoperation structure to specify
    how to delete local files after a checkin operation. */
 
#define NFM_NO_DELETE               0 /* Don't delete local files after
                                         checkin. */
#define NFM_CONDITIONAL_DELETE      1 /* Delete local files after checkin only
                                         if nobody has them copied (use local
                                         file manager). */
#define NFM_DELETE_FILES            2 /* Delete local files. */
 
/*  The PURGE definitions are used to tell whether or not to purge the checkin
    file versions and their records in the f_<catalog> table. */
 
#define NFM_NO_PURGE                0 /* Don't purge files and records. */
#define NFM_PURGE                   1 /* Purge files and records. */
 
/*  The NFMoperation structure is an argument to NFMcheckin_item,
    NFMcheckout_item, NFMcopy_item_files, NFMcheckin_set, NFMcheckout_set, and
    NFMcopy_set_files. Unsigned integer fields are used to specify modes of 
    file transfer, deletion, and purging. */
 
struct NFMoperation
    {
    unsigned int transfer:2;    /* Mode of file transfer. Possible values:
                                   NFM_NO_TRANSFER;
                                   NFM_CONDITIONAL_TRANSFER;
                                   NFM_TRANSFER. */
    unsigned int delete:2;      /* Mode of file deletion (after checkin).
                                   Possible values:
                                   NFM_NO_DELETE;
                                   NFM_CONDITIONAL_DELETE;
                                   NFM_DELETE_FILES. */
    unsigned int purge:1;       /* Whether or not to purge files and records.
                                   Possible values:
                                   NFM_NO_PURGE;
                                   NFM_PURGE. */
 
    /* The following fields may be used ONLY with set member file transfers.
       An application may choose different modes of transfer, deletion, and or
       purging for each set member. These fields are ignored for item
       operations or if all set members are to be treated the same (see the
       member_operations argument to the set transfer functions). */
 
    char  catalog [NFM_CATALOGNAME+1];   /* Catalog to which set member
                                            belongs. */
    long  catalog_no;                    /* Optional. If known, n_catalogno
                                            will optimize processing. */
    char  item_name [NFM_ITEMNAME+1];    /* Set member item name. */
    char  item_rev [NFM_ITEMREV+1];      /* Set member item revision. */
    };
 
/*  This group of definitions is used for the NFMcheckin_set, NFMcheckout_set,
    and NFMcopy_set_files functions. They may be used to specify how to treat
    individual set members. */
 
#define NFM_SAME_OPERATION          0 /* Perform the same operations defined
                                         in the NFMoperation structure for
                                         every set member. */
#define NFM_MEMBER_OPERATIONS       1 /* An NFMoperation structure will be
                                         defined for each set member so that
                                         different modes of operation may
                                         apply for each member. */
 
/*  This group of definitions is used for the NFMmember_info structure. The
    NFMmember_info structure is an argument to NFMdefine_set_information that
    is used to add a set member, drop a set member, or change the information
    about a set member. */
 
#define NFM_ADD_MEMBER              1 /* Add a member to a set. */
#define NFM_DROP_MEMBER             2 /* Drop a member from a set. */
#define NFM_CHANGE_MEMBER           3 /* Change information about a set
                                         member. */
 
 
struct NFMmember_info
    {
    short operation;      /* Type of set operation to perform. Possible
                             values:
                             NFM_ADD_MEMBER;
                             NFM_DROP_MEMBER;
                             NFM_CHANGE_MEMBER. */
    long  citno;          /* Optional. If known, n_citno will optimize
                             processing.
                             If operation = NFM_ADD_MEMBER, -1;
                             If operation = NFM_DROP_MEMBER, value of n_citno
                             from nfmsetcit table;
                             If operation = NFM_CHANGE_MEMBER, value of
                             n_citno from nfmsetcit table. */
    char  catalog_name [NFM_CATALOGNAME+1];  /* Member's catalog. */
    long  catalog_no;                        /* Optional. If known,
                                                n_catalogno will optimize
                                                processing; if not known, -1. */
    char  item_name [NFM_ITEMNAME+1];        /* Member's item name. */
    char  item_rev [NFM_ITEMREV+1];          /* Member's revision. */
    long  item_no;                           /* Optional. If known, n_itemno
                                                will optimize processing; if
                                                not known, -1. */
    char  type [NFM_TYPE+1];                 /* Member type ("P"rimary or
                                                "S"econdary). */
    };

/* 
Notes:
 
    For NFM_DROP_MEMBER and NFM_CHANGE_MEMBER, the citno is not always
    available from the calling function; therefore, citno is not required
    input. However, if this value is passed in by the calling function, the
    NFMdefine_set_information function will be more efficient.
 
    If the catalog_no and item_no are known, they may be passed to speed-
    up/optimize processing.
*/
 
/*  The following definitions are used for the NFMdefine_set_information
    function. They may be used to specify whether or not to check the set
    status (n_status) before modifying the set definition. */
 
#define NFM_NO_FILE_STATUS_CHECK     0   /* Modify the set definition
                                            regardless of the file status of
                                            the set. */
 
#define NFM_FILE_STATUS_CHECK        1   /* Check the file status of the set
                                            before allowing modification of
                                            the set definition. */
 
 
/*  The following definitions are used for the I/NFM display functions. They
    are used to specify a full display (all attribute information) or a short
    display (index and name only). */
 
#define NFM_FULL_DISPLAY            0 /* Display the values for ALL
                                         attributes. */
#define NFM_SHORT_DISPLAY           1 /* Display the index and name values
                                         ONLY. */
 
 
/*  The following definitions are used for the I/NFM LFM (Local File Manager)
    functions. They are used to specify how to query or update the local file
    manager table (nfmsafiles). */
 
#define NFM_QUERY_LFM_BY_SANO       0 /* Query the local file manager table
                                         for entries about a specific storage
                                         area. */
#define NFM_QUERY_LFM_ALL           1 /* Query the local file manager table
                                         for ALL storage area entries. */
#define NFM_LFM_INSERT              0 /* Add an entry to the local file
                                         manager table. */
#define NFM_LFM_DELETE              1 /* Delete an entry from the local file
                                         manager table. */
#define NFM_LFM_CHANGE              2 /* Change an entry in the local file
                                         manager table. */
 
 
/*  The following definitions are used for the I/NFM query definition function
    NFMdefine_query. They are used to specify what type of query to define. */
 
#define NFM_WHERE_CLAUSE         0    /* Define a WHERE clause only. */
#define NFM_ORDER_BY_CLAUSE      1    /* Define an ORDER BY clause only. */
#define NFM_SIMPLE_QUERY         2    /* Define a simple query. */
#define NFM_EXPERT_QUERY         3    /* Define an EXPERT query. */
#define NFM_FTR_QUERY		 4    /* Define an FTR query. */
#define NFM_ADV_QUERY		 5    /* Define an Advanced query. */
 
/*  The NFMquery_info structure is an argument to NFMdefine_query. It is used
    to define the parts of a query. */
 
struct NFMquery_info
    {
    char   *select_clause;   /* The "select" clause needed for the query. Only
                                valid for a query type of NFM_SIMPLE_QUERY or
                                NFM_EXPERT_QUERY. */
    char   *from_clause;     /* The "from" clause needed for the query. Only
                                valid for a query type of NFM_SIMPLE_QUERY or
                                NFM_EXPERT_QUERY. */
    char   *where_clause;    /* The "where" clause needed for the query. Only
                                valid for a query type of NFM_WHERE_CLAUSE,
                                NFM_SIMPLE_QUERY, or NFM_EXPERT_QUERY. */
    char   *order_by_clause; /* The "order by" clause needed for the query.
                                Only valid for a query type of
                                NFM_ORDER_BY_CLAUSE, NFM_SIMPLE_QUERY, or
                                NFM_EXPERT_QUERY. */
    char   *prompts;         /* The prompts needed for the user interface to
                                define an EXPERT query. Only valid for a query
                                type of NFM_EXPERT_QUERY. */
    };
 
 
/*  The NFMquery_ftr_info structure is an argument to NFMdefine_query.
    It is used to define the parts of an ftr/advanced query. */
 
struct NFMquery_ftr_info
    {
    char   *select_clause;   /* The "select" clause needed for the query. Only
                                valid for a query type of NFM_SIMPLE_QUERY or
                                NFM_EXPERT_QUERY. */
    char   *from_clause;     /* The "from" clause needed for the query. Only
                                valid for a query type of NFM_SIMPLE_QUERY or
                                NFM_EXPERT_QUERY. */
    char   *where_clause;    /* The "where" clause needed for the query. Only
                                valid for a query type of NFM_WHERE_CLAUSE,
                                NFM_SIMPLE_QUERY, or NFM_EXPERT_QUERY. */
    char   *order_by_clause; /* The "order by" clause needed for the query.
                                Only valid for a query type of
                                NFM_ORDER_BY_CLAUSE, NFM_SIMPLE_QUERY, or
                                NFM_EXPERT_QUERY. */
    char   *prompts;         /* The prompts needed for the user interface to
                                define an EXPERT query. Only valid for a query
                                type of NFM_EXPERT_QUERY. */
    char   *ftr;             /* The query to be used in conjunction with
				the FTR engine. */
    char   *aqs;	     /* Advanced query SEARCH clause. */
    char   *aqf;	     /* Advanced query FROM clause. */
    char   *aqw;	     /* Advanced query WHERE clause. */
    };
 
 
#endif
