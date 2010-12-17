/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   dbserver.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   dbserver.h -- Database Server Definitions				|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   Copyright 1985, Bentley Systems, Inc.				|
|									|
|   This program may not be copied in part or in whole on any medium,	|
|   either electronic or printed, without the expressed written consent |
|   of Bentley Systems, Inc.						|
|									|
+----------------------------------------------------------------------*/
#ifndef __dbserverH__
#define __dbserverH__

#if defined (ip32) && !defined (unix)
#define	unix 1
#endif

/* MetaWare and MicroSoft compilers don't define msdos */
#if ((defined (pm386) || defined (MSDOS)) && !defined (msdos))
#define msdos
#endif

#ifndef __basedefsH__
#include "basedefs.h"
#endif

#ifndef __dbdefsH__
#include "dbdefs.h"
#endif

#ifndef __dberrsH__
#include "dberrs.h"
#endif

/* software interrupt for use by the database server */
#define RMSVC_INTERRUPT    0x65

/* SQL Statment Types */
#define MALFORMED_STMT	      1
#define UNKNOWN_STMT	      2
#define SELECT_STMT	      3
#define UPDATE_STMT	      4
#define CONNECT_STMT	      5
#define DISCONNECT_STMT	      6
#define SQLFORMS_STMT	      7
#define RELOAD_STMT	      8
#define INSERT_STMT	      9
#define COMMIT_STMT	      10
#define ROLLBACK_STMT	      11

#if !defined (MSDB_LEVEL)						
/* NOTE: database control elements have levels 11-19 reserved */
#define	    MSDB_LEVEL		10	/* dBASE	    */
#define	    MSIX_LEVEL		11	/* Informix	    */
#define	    MSRIS_LEVEL		12	/* RIS		    */
#define	    MSORACLE_LEVEL	13	/* Oracle	    */
#endif
						
/* miscellaneous */
#define APPEND_LINK	      0	    /* add linkage to existing links */
#define REPLACE_LINK	      1	    /* replace linkages with current link */
#define ACTIVATE_FILTER       1	    /* turn on fence  filter */
#define DEACTIVATE_FILTER     2	    /* turn off fence filter */
#define MAX_DB_APPS          12	    /* max number of application tasks */
#define DB_BUFFER_SIZE	   2048	    /* size (bytes) of request buffer */

/* MicroStation command numbers */
#define ATTACH_AE	    239
#define DELETE_LINK	    240
#define REVIEW_SINGLE	    241
#define FENCE_REPORT	    243
#define DEFINE_AE	    246
#define DEFINE_DB	    247
#define EDIT_AE		    248
#define LOCATE_AE	    249
#define SHOW_AE		    250
#define FENCE_ATTACH	    255
#define FENCE_DETACH	    256
#define CREATE_ENTITY	    257
#define ATTACH_DA	    399
#define LOAD_DA		    400
#define FENCE_LOAD	    401
#define GENERATE_DA	    402

/* server message types */
#define FIRST_MESSAGE  	0  /* request for 1st message on queue */
#define DB_USTN_MSG    	1  /* MicroStation request for database services */
#define DB_USTN_ACK     2  /* server response to DB_USTN_MSG */
#define DB_APP_MSG     16  /* application request for database services */
#define DB_APP_ACK     17  /* server response to DB_APP_MSG */

/* MicroStation message fields */
#define NO_MESSAGE     	0
#define NO_FIELD       	0
#define STATUS_FIELD   	1
#define MESSAGE_FIELD  	2
#define COMMAND_FIELD  	3
#define PROMPT_FIELD  	4
#define KEYIN_FIELD    	5
#define ERROR_FIELD    	6
						
/* server load errors */
#define DBERROR_ServerNotFound		1
#define DBERROR_QueueInit		2
#define DBERROR_SpawnError		3
#define DBERROR_NoResponse		4
#define DBERROR_RealMapping		5
#define DBERROR_ReadResourceMap		6
#define DBERROR_InitCommunications	7
#define DBERROR_InitMicroCSL		8
#define DBERROR_RealModeTSR		9
#define DBERROR_InsufficientPMMemory   10
#define DBERROR_InsufficientRealMemory 11
#define DBERROR_ExecProgram	       12
#define DBERROR_NotWarmStarted	       13
		
/*                            SERVER REQUESTS

   These are the possible database server requests.  These are requests for
   database services which originate within MicroStation and are passed to
   the database server through a message queue.  The server fills the request
   and then replies with a message through the same message queue. */

#define DB_STARTUP             1   /* start up and initialize database */
#define DB_TERMINATE	       2   /* terminate database server */
#define DB_ATTACH_AE          10   /* attach the AE to an element */
#define DB_OPEN_REPORT        11   /* inititialize a database fence report */
#define DB_CLOSE_REPORT       12   /* close a database fence report */
#define DB_ELEMENT_REPORT     13   /* process element for fence report */
#define DB_REVIEW_ATTRIBUTES  14   /* review attributes of an element */
#define DB_DETACH_LINK        15   /* remove database linkages from element */
#define DB_SELECT_AE          16   /* select the active entity graphically */
#define DB_DELETE_ELEMENT     18   /* process linkages for deleted element */
#define DB_ELEMENT_FILTER     19   /* filter function for single element op */
#define DB_FENCE_FILTER       20   /* database fence filter function */
#define DB_UCM_READ           21   /* process user command DBREAD operator */
#define DB_UCM_WRITE          22   /* process user command DBWRITE operator */
#define DB_INITIALIZE_TCB     24   /* set up TCB during drawing init */
#define DB_DEFINE_APPL_ELM    25   /* define application element for scan */
#define DB_PROCESS_APPL_ELM   26   /* process application element */
#define DB_SHUTDOWN	      28   /* shut down and close the database */
#define DB_COPY_ELEMENT	      30   /* copy element */
#define DB_LOGIN	      41   /* MicroStation log on message */
#define DB_UCM_ADD            46   /* process user command DBADD operator */
#define DB_UCM_DELETE         47   /* process user command DBDELETE operator*/
#define DB_ATTACH_DA	      48   /* attach linkage to existing text node */
#define DB_LOAD_DA	      49   /* load linkage text to text node */
#define DB_GENERATE_DA	      50   /* create new textnodes with linkage text*/

/* keyin requests */
#define DB_PROCESS_KEYIN       3   /* process a direct database keyin */
#define DB_OPTIONS    	       4   /* database setup tutorial */
#define DB_DEFINE	       5   /* process a DB= keyin */
#define DB_FIND_ENTITY	       6   /* locate a record and setup as AE */
#define DB_EDIT_AE	       7   /* edit the active entity */
#define DB_CREATE_ENTITY       8   /* add a record to the database */
#define DB_SHOW_AE	       9   /* AE=$, display the active entity */
#define DB_DEFINE_SEARCH      17   /* process a DS= fence search keyin */
#define DB_LINKAGE_MODE       23   /* process an ACTIVE LINK <> keyin */
#define DB_DELETE_MODE        27   /* process SET DELETE <> keyin */
#define DB_REVIEW_TABLE       29   /* process RA= keyin */
#define DB_REPORT_SPEC        31   /* process RS= keyin */
#define DB_FORM_COMMAND	      59   /* process FORM keyin */
#define DB_FORM_DISPLAY	      60   /* display form */
#define DB_CONFIRM_MODE	      65   /* confirmation mode */
#define DB_INSERT_AE	      66   /* AE = keyin */
#define DB_AUTOCOMMIT	      67   /* auto commit SQL transactions */
#define DB_RELEASE	      68   /* release resources on disconnect */
#define DB_MDLDIALOGS	      69   /* use MDL dialogs for query */
#define DB_ERRORTEXT	      70   /* retrieve error text */

/* application requests  (originate only from a task) */
#define DB_NULREC	      32   /* create a null record and set up as AE */
#define DB_GETREC             33   /* retrieves a record and sets up as AE */
#define DB_GETFLD             34   /* extracts a field from the AE */
#define DB_EDTFLD             35   /* edits a field of the AE */
#define DB_NEWREC             36   /* writes the AE as a new record */
#define DB_UPDREC             37   /* updates a given record with the AE */
#define DB_SCNENT             38   /* scans for a record */
#define DB_DELREC             39   /* deletes a record from the database */
#define DB_QUEUE              40   /* creates/removes message queues */
#define DB_GETFMT             42   /* retrieve type and length of column */
#define DB_GETMAX             43   /* retrieve number of columns and rows */
#define DB_FLDNAME            44   /* retrieve column names of a table */
#define DB_JNDCOL             45   /* codelist lookup */

/* MDL requests  (originate only from an MDL task) */
#define DB_DECODE_LINK        51   /* decode user data linkage */
#define DB_READ_COLUMN        52   /* read column from table */
#define DB_WRITE_COLUMN       53   /* write column from table */
#define DB_LARGEST_MSLINK     54   /* largest MSLINK key in table */
#define DB_BUILD_LINK	      55   /* construct linkage */
#define DB_DELETE_ROW	      56   /* delete row from table */
#define DB_ADD_ROW	      57   /* add a new row to a table */
#define DB_QUERY	      58   /* query the database */
#define DB_DESCRIBE_TABLE     61   /* describe a database table */
#define	DB_OPEN_CURSOR	      62   /* open cursor for query by mdl */
#define DB_FETCH_ROW	      63   /* fetch row from a table */
#define DB_CLOSE_CURSOR	      64   /* close cursor used by mdl */

/* scan comparison codes */
#define CC_EQ	1
#define CC_LT   2
#define CC_GT   3
#define CC_NE   4
#define CC_LE   5
#define CC_GE   6

#ifdef debug
#define Debug(x) x
#else
#define Debug(x)
#endif

typedef struct
    {
    char    name[64];	    /* server program's name */
    int	    pid;	    /* process id of server */
    int	    active;         /* server task active */
    int	    messagekey;	    /* key for the message path to/from the process */
    int	    msqid;	    /* message queue id */
    } DBServer;

typedef struct db_client
    {
    char    name[60];	/* client program's name */
    int	    pid;	/* process id of client */
    int	    active;     /* client task active */
    int	    messagekey;	/* key for the message path to/from the process */
    int	    msqid;	/* message queue id */
    } Db_client;

typedef struct ucm_arg
    {
    char    *field;	    /* field name */
    char    *value;	    /* field value (DBWRITE only */
#if defined (DBASE)
    short   fieldnum;	    /* index of field in database structure */
    short   fieldoffset;    /* offset of field in record */
#endif
    } Ucm_arg;

typedef struct db_status
    {
    long    code;           /* return code status of request */
    long    msg_fld;        /* message field to output message text */
    char    msg[80];	    /* message text; valid if msg_fld non-zero */
    } Db_status;

typedef struct db_msg_header
    {
    long	type;	        /* type of message */
    long	request;	/* database request type */
    long	length;		/* number of bytes in message */
    long	sendpid;	/* sending task's PID */
    Db_status	status;		/* return status */
    } Db_msg_header;

typedef struct db_message
    {
    Db_msg_header hdr;	    /* message header */
    union		    /* message data */
	{
	char	chardata[DB_BUFFER_SIZE];
	short	shortdata[DB_BUFFER_SIZE / 2];
	} u;
    } Db_message, dbMessage;

typedef short Form_toggle;

typedef struct descriptor_msg
    {
    short   columns;
    short   rows;
    char    data[DB_BUFFER_SIZE - (sizeof(short) * 2)];
    } Descriptor_msg;

typedef struct db_login
    {
    char    taskname[132];		/* process name */
    long    pid;			/* process ID */
    } Db_login;

/* MicroCSL request/acknowledge messages */
typedef struct
    {
    unsigned short  entity;	    /* entity number of table */
    unsigned long   mslink;	    /* MSLINK key of row to delete */
    } Delrec_rqst;

typedef struct
    {
    unsigned short entity;	    /* entity number of table */
    } Nulrec_rqst;

typedef struct
    {
    unsigned short  entity;	    /* entity number of table */
    unsigned long   mslink;	    /* MSLINK key of row to establish as AE */
    } Getrec_rqst;

typedef struct
    {
    unsigned short  entity;	    /* entity number of table */
    unsigned long   mslink;	    /* MSLINK key of record to read */
    unsigned short  fieldno;	    /* field number to read */
    } Getfld_rqst;

typedef struct
    {
    char value[1];              /* value of field requested */
    } Getfld_ack;

typedef struct
    {
    unsigned short  entity;      /* entity number of table */
    unsigned long   mslink;      /* MSLINK key of record to write */
    unsigned short  fieldno;     /* field number to write */
    char value[1];		 /* value of field to write */
    } Edtfld_rqst;

typedef struct
    {
    unsigned long mslink;       /* MSLINK key of row added to database */
    } Newrec_ack;

typedef struct
    {
    unsigned long mslink;       /* MSLINK key of row to update with AE */
    } Updrec_rqst;

typedef struct
    {
    short fieldno;              /* field number to compare */
    short compcode;             /* comparison code */
    union {
        char *value;		/* pointer to field value */
        long offset;		/* offset of field value in buffer */
        } u;
    } Db_Scnfld;

typedef struct
    {
    unsigned short  entity;        /* entity number to scan */
    unsigned long   startrec;      /* starting MSLINK key to begin scan */
    short	    numfields;     /* number of fields to compare */
    Db_Scnfld	    scanlist[1];   /* list of field criteria */
    } Scnent_rqst;

typedef struct
    {
    unsigned long mslink;           /* MSLINK key of record located */
    } Scnent_ack;

typedef struct
    {
    unsigned short entity;          /* entity number of table */
    unsigned short column;          /* column number to retrieve */
    } Getfmt_rqst;

typedef struct
    {
    unsigned short type;            /* data type of column */
    unsigned short length;          /* length of column in bytes */
    } Getfmt_ack;

typedef struct
    {
    unsigned short entity;          /* entity number of table */
    } Getmax_rqst;

typedef struct
    {
    unsigned short  columns;         /* number of columns in the table */
    unsigned long   rows;            /* number of rows in the table  */
    } Getmax_ack;

typedef struct
    {
    unsigned short entity;          /* entity number of table */
    unsigned short width;           /* max width of column names */
    unsigned short number;          /* max number of columns to be returned */
    } Fldname_rqst;

typedef struct
    {
    unsigned short number;          /* number of column names in buffer */
    char names[1];                  /* column names in table */
    } Fldname_ack;

typedef struct
    {
    unsigned short  entity;          /* entity number of table */
    unsigned short  column;          /* column number of codelist value */
    unsigned long   mslink;          /* MSLINK column of row */
    } Jndcol_rqst;

typedef struct
    {
    char value[1];                  /* codelist value */
    } Jndcol_ack;

typedef struct
    {
    long    numlines;
    char    textdata[DB_BUFFER_SIZE - sizeof(long)];
    } Das_text;

/* MDL request/acknowledge messages */
typedef struct
    {
    char	    tableName[64];	/* table name */
    char	    columnName[64];	/* column name to read */
    unsigned long   mslinkKey;		/* MSLINK key of column to read */
    } ColumnReadRqst;

typedef struct
    {
    char value[256];                  /* column value */
    } ColumnReadAck;

typedef struct
    {
    char	    tableName[64];	/* table name */
    char	    columnName[64];	/* column name to write */
    unsigned long   mslinkKey;		/* MSLINK key of column to write */
    char	    columnValue[256];	/* column name to write */
    } ColumnWriteRqst;

typedef struct
    {
    char	    tableName[64];	/* table name */
    unsigned long   mslinkKey;		/* MSLINK key of column to delete */
    } DeleteRowRqst;

typedef struct
    {
    short	    linkType;		/* linkage type (ORACLE, IX) */
    LinkProps	    props;		/* properties of the linkage */
    char	    tableName[64];	/* table name */
    unsigned long   mslinkKey;		/* MSLINK key of column */
    short	    dasType;		/* displayable attribute type */
    } BuildLinkRqst;

typedef	struct
    {
    short   *attributes;	/* new attributes */
    int	    length;		/* length (bytes) of the attribute block */
    int	    mode;		/* APPEND or REPLACE */
    } AttributeMod;

/*----------------------------------------------------------------------+
|                                                                       |
|   Linkage Formats							|
|                                                                       |
+----------------------------------------------------------------------*/
#if !defined (GENERICLINK)						
typedef struct
    {
#if defined (macintosh)
    unsigned info:1;	    /* boolean: informational linkage */
    unsigned remote:1;	    /* boolean: remote linkage */
    unsigned modified:1;    /* boolean: user linkage has been modified */
    unsigned user:1;	    /* boolean: user data linkage */
    unsigned class:4;	    /* linkage family class */
    unsigned words:8;	    /* words to follow in linkage */
#else
    unsigned words:8;	    /* words to follow in linkage */
    unsigned class:4;	    /* linkage family class */
    unsigned user:1;	    /* boolean: user data linkage */
    unsigned modified:1;    /* boolean: user linkage has been modified */
    unsigned remote:1;	    /* boolean: remote linkage */
    unsigned info:1;	    /* boolean: informational linkage */
#endif
    unsigned short primary_id;	    /* User ID number */
    unsigned short secondary_id;    /* Secondary ID number */

    unsigned short  entity;	    /* entity number */
    unsigned long   mslink;	    /* MSLINK field value */
    unsigned char   dastype;	    /* displayable attribute type */
    byte pad[3];		    /* user linkages are a multiple of 4 */
    } Generic_link, GenericLink;
#define GENERICLINK
#endif
						
/*----------------------------------------------------------------------+
|                                                                       |
|   DMRS    								|
|                                                                       |
+----------------------------------------------------------------------*/
#if !defined (DMRSLINK)						
typedef struct
    {
#if defined (macintosh)
    unsigned info:1;	        /* boolean: informational linkage */
    unsigned remote:1;	        /* boolean: remote linkage */
    unsigned modified:1;        /* boolean: user linkage has been modified */
    unsigned user:1;	        /* boolean: user data linkage */
    unsigned class:4;	        /* linkage family class */
    unsigned type:8;	        /* displayable attribute type */
#else
    unsigned type:8;	        /* displayable attribute type */
    unsigned class:4;	        /* linkage family class */
    unsigned user:1;	        /* boolean: user data linkage */
    unsigned modified:1;        /* boolean: user linkage has been modified */
    unsigned remote:1;	        /* boolean: remote linkage */
    unsigned info:1;	        /* boolean: informational linkage */
#endif
    unsigned short  entity;      /* entity number */
    unsigned short  occ_low;     /* low word of the 24 bit occurence number */
    byte	    occ_high;    /* high byte of the occurence number */
    byte	    reuse;       /* reuse counter */
    } DMRS_link, DMRSLink;
#define DMRSLINK
#endif
						
/*----------------------------------------------------------------------+
|                                                                       |
|   Informix Format							|
|                                                                       |
+----------------------------------------------------------------------*/
#if !defined (IXLINKAGE)
typedef Generic_link IX_link, IXLink;
#define IXLINKAGE
#endif

/*----------------------------------------------------------------------+
|									|
|   dBASE Format              						|
|									|
+----------------------------------------------------------------------*/
#if !defined (DBLINKAGE)
typedef Generic_link dB_link, dBASELink;
#define DBLINKAGE
#endif

/*----------------------------------------------------------------------+
|									|
|   Oracle Format                      					|
|									|
+----------------------------------------------------------------------*/
#if !defined (ORACLELINKAGE)
typedef Generic_link Oracle_link, OracleLink;
#define ORACLELINKAGE
#endif
	
/*----------------------------------------------------------------------+
|                                                                       |
|   MDL call back message structure					|
|                                                                       |
+----------------------------------------------------------------------*/
#if !defined (MDLCALLBACK_BUFFER)
#define     MDLCALLBACK_BUFFER	    256
typedef struct
    {
    short    status;
    short    dataLength;
    char     data[MDLCALLBACK_BUFFER];
    } MDLCallBack;
#endif
#endif
