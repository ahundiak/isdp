/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   dberrs.h  $
|   $Revision: 1.1 $  $Date: 1995/10/17 23:24:04 $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1986-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc.							|
|									|
| Limited permission is hereby granted to reproduce and modify this	|
| copyrighted material provided that the resulting code is used only in	|
| conjunction with Bentley Systems products under the terms of the	|
| license agreement provided therein, and that this notice is retained	|
| in its entirety in any such reproduction or modification.		|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   dberrs.h -- database error return codes				|
|									|
+----------------------------------------------------------------------*/
#ifndef __dberrsH__
#define __dberrsH__
						
#if defined (ORACLE)
/* Database Resource Messages */
#define RETURN_TO_CONT 		5000    /* "Return to Continue" */
#define DB_SUCCESS     		5001	/* normal successful completion */
#define FILTER_STATUS  		5002	/* fence filter status */
#define ROW_DELETED 		5003    /* row deleted in element deletion */
#define LINKAGE_MODE   		5004	/* linkage mode string */
#define ON_STRING       	5005    /* "On" */     
#define OFF_STRING      	5006    /* "Off" */
#define NONE_STRING     	5007    /* "NONE" */
#define DELETE_ENTITY   	5008    /* "Delete Entity: " */
#define KEYIN_PROCESSED 	5009    /* keyin processed */
#define DATABASE_NAME   	5010    /* database name */
#define DATA_RESET      	5011    /* Data to Accept/Reset to Continue */
#define PROCESSING_REQUEST      5012    /* Processing database request */  
#define BUILDING_AE_TABLE       5013    /* Building AE table... */  
#define SUCCESSFUL_CONNECT      5014    /* Connected to database */  
#define DISCONNECTED		5015    /* Disconnected to database */  
#define NULL_MESSAGE		5016    /* empty string */  
#define SQLFORMSMODE		5017    /* SQL*FORMS mode */  
#define	PROCESSING_TABLE	5018    /* Processing table */  
#define	BUILDING_MSFORMS_TABLE	5019    /* Building MSFORMS table ... */  
#define CONFIRMATION_MODE	5020    /* SET CONFIRM mode */  
#define LINKAGE_DETACHED	5021    /* linkage detached from element */  
#define LINKAGE_ATTACHED	5022    /* linkage attached to element */  
#define AUTOCOMMIT_MODE		5023    /* auto commit mode */
#define RELEASE_MODE		5024    /* release resources mode */
#define MDLDIALOGS_MODE		5025    /* MDL query dialog mode */
#define WORK_COMMITTED		5026    /* work committed */
#define WORK_ROLLEDBACK		5027    /* rollback */
						
/* Database Resource Errors */
#define INSUFFICIENT_MEMORY 4000	/* allocate database memory */
#define SYNTAX_ERROR	    4001	/* command line syntax error */
#define NO_AE_DEFINED       4002	/* no active entity defined */
#define NO_WRITE	    4003	/* record not written to database */
#define NO_LINK_DATA	    4004	/* no database linkage present */
#define NO_REPORT	    4005	/* unable to generate report file */
#define NO_ENTITY	    4006	/* no entity specified */
#define NO_MSLINK	    4007	/* no MSLINK column in table */
#define REPORT_BADOPEN	    4008	/* unable to open report file. */
#define ENTITY_BADVALUE	    4009	/* entity number out of bounds */
#define FORMAT_NOTFOUND	    4010	/* screen form file not found. */
#define NULL_LINK_MODE      4011        /* NULL linkage generation mode */
#define FILE_NOT_FOUND      4012        /* file not found */
#define DB_NOT_FOUND        4014        /* unable to locate database */
#define NO_MSCATALOG        4015        /* unable to read MSCATALOG table */
#define NOT_UNIQUE          4016        /* more than 1 row returned by FIND*/
#define NOT_SELECT_REQUEST  4017        /* not a Select statement */
#define DB_NOT_VALID        4018        /* database is not valid */
#define NO_ROWS             4019        /* no rows returned from FIND */
#define NO_MSLINK_COLUMN    4020        /* no MSLINK column in the table */
#define BAD_MSCATALOG       4021        /* illegal format of MSCATALOG */
#define NO_REVIEW           4022        /* unable to review attributes */
#define BAD_REVIEW_TABLE    4023        /* bad review table */
#define NO_MSCATALOG_ENTRY  4024        /* table not present in MSCATALOG */
#define NO_MSCATALOG_UPDATE 4025        /* unable to update MSCATALOG table */
#define BAD_REPORTFILE      4026        /* bad report specification */
#define BAD_MSLINK          4027        /* bad MSLINK key in DBREAD/DBWRITE */
#define DATABASE_NOT_FOUND  4028        /* bad fence filter */
#define BAD_FENCE_FILTER    4029        /* bad fence filter */
#define NO_DB_TASK_SLOTS    4030        /* no more slots for tasks */
#define DB_QUEUE_INIT_ERROR 4031        /* unable to create message queue */
#define BAD_COLUMN          4032        /* column number out of bounds */
#define ILLEGAL_CC_CODE     4033        /* illegal scan comparison code */
#define BAD_LINKTYPE        4034        /* illegal types in MS_LINKTYPE */
#define UNKNOWN_DATATYPE    4035        /* bad data type during DB_GETFMT */
#define BAD_CONNECT	    4036        /* bad CONNECT statement format */
#define MSLINK_NOT_SET      4037        /* error assigning MSLINK */
#define BUILD_AETABLE_ERROR 4038        /* error building "ae" table */
#define LOAD_AETABLE_ERROR  4039        /* error loading "ae" table */
#define NO_ROWS_RETURNED    4040        /* no rows returned by SELECT */
#define RUNFORM_NOT_FOUND   4041        /* RUNFORM program not found */
#define FORM_NOT_FOUND	    4042        /* screen form not found */
#define BAD_FORMS_COMMAND   4043        /* illegal forms command */
#define NO_DAS_TABLE	    4044        /* no DAS table for this entity */
#define ECHO_FILE_NOT_FOUND 4045        /* RUNFORM echo file not found */
#define SQLFORMS_ERROR	    4046        /* error starting SQL*FORMS */
#define NO_SPOOL_FILE	    4047        /* no SQLFORMS output file found */
#define NO_DAS_ENTRY	    4048	/* no entry in DAS table */
#define BAD_FORM_COMMAND    4049	/* invalid form command entered */
#define DESCRIPTOR_ERROR    4050	/* allocation error for descriptor */
#define BAD_RESOURCE_FILE   4051	/* error opening resource file */
#define NOT_LOGGED_IN	    4052	/* not logged in */
#define DESCRIBE_SQL_ERROR  4053	/* SQL error during table describe */
#define DESCR_OVERFLOW	    4054	/* descriptor larger than message  */
#define ROW_OVERFLOW	    4055	/* row larger than message packet */
#define NO_ACTIVE_QUERY	    4056	/* fetch failed, no active query */
#define NO_DAS_FORM	    4057	/* no form defined for DAS type */
#define AE_REQUIRES_INSERT  4058	/* AE= command requires INSERT */
#define NULL_LINKAGE_MODE   4059	/* NULL linkage mode active */
#define ROW_DELETE_ERROR    4060	/* error deleting table row */
#define TABLE_NOT_OPEN	    4061	/* table not open */
#define AE_FOR_NEWLINK	    4062	/* AE command only for NEW mode */
#define USE_ACTUAL_TABLE    4063	/* AE command use actual table */
#endif
						
#if defined (DBASE)
/* Database Resource Messages */
#define RETURN_TO_CONT	    5000    /* "Return to Continue" */
#define DB_SUCCESS	    5001    /* normal successful completion */
#define FILTER_STATUS	    5003    /* fence filter status */
#define ROW_DELETED	    5004    /* record deleted */
#define ENTITY_NO	    5005    /* entity number */
#define CONTROL_FILE	    5006    /* control file prompt */
#define LINKAGE_MODE	    5007    /* linkage mode string */
#define ON_STRING	    5008    /* "On" */
#define OFF_STRING	    5009    /* "Off" */
#define NONE_STRING	    5010    /* "NONE" */
#define DELETE_ENTITY	    5011    /* "Delete Entity: " */
#define KEYIN_PROCESSED	    5012    /* keyin processed */
#define PROCESSING_REQUEST  5013    /* Processing database request */  
#define NULL_MESSAGE	    5014    /* empty string */  
#define CONFIRMATION_MODE   5015    /* SET CONFIRM mode */  
#define LINKAGE_DETACHED    5016    /* linkage detached from element */  
#define LINKAGE_ATTACHED    5017    /* linkage attached to element */  
#define FORMS_ALWAYS_ON	    5018    /* Forms are always ON in dBASE */  
#define AUTOCOMMIT_MODE	    5019    /* auto commit mode */
#define RELEASE_MODE	    5020    /* release resources mode */
#define MDLDIALOGS_MODE	    5021    /* MDL query dialog mode */
						
/* Database Resource Errors */
#define CTRL_OPEN_ERR	    4000 /* open control database */
#define ILLEGAL_CTRL_FILE   4001 /* illegal control file format */
#define INSF_MEM_ERR	    4002 /* allocate database memory */
#define SYNTAX_ERR	    4003 /* command line syntax error */
#define NO_SEARCH	    4004 /* FIND unable to use entity or field name */
#define NO_MATCH	    4005 /* unable to locate record in database */
#define NO_READ		    4006 /* unable to read record from database */
#define NO_AE_DEFINED	    4007 /* no active entity defined */
#define NO_WRITE	    4008 /* record not written to database */
#define NO_KEY		    4010 /* unable to generate key for index file */
#define NO_LINK_DATA	    4011 /* no database linkage present in element */
#define NO_DB		    4012 /* database for entity not currently open */
#define NO_REPORT	    4013 /* unable to generate report file */
#define BAD_FORMAT_FILE     4014 /* no fields identified on edit page */
#define NO_ENTITY	    4015 /* no entity specified */
#define DB_NOTFOUND	    4016 /* Database file not found. */
#define DB_BADOPEN	    4017 /* Unable to open database file.*/
#define DB_NOTVALID	    4018 /* Not a valid database file. */
#define MNDX_NOTFOUND	    4019 /* Unable to locate master index file: %s */
#define MNDX_BADOPEN	    4020 /* Unable to open master index file */
#define MNDX_NOTVALID	    4021 /* Master index is not a valid index file */
#define MNDX_BADKEY	    4022 /* Master index file not keyed to MSLINK */
#define NO_MSLINK	    4023 /* structure does not contain MSLINK */
#define RPT_BADOPEN	    4024 /* Unable to open report file. */
#define ENT_BADVALUE	    4025 /* Entity number out of bounds */
#define BAD_NUMBER	    4026 /* Invalid number. */
#define BAD_CONVERT	    4027 /* Conversion error. */
#define FMT_NOTFOUND	    4028 /* Format file not found. */
#define DB_NOTDEFINED	    4029 /* Database is not valid. */
#define NDX_NOTSIMPLE	    4030 /* Index expression is compound */
#define NO_DBFIELD	    4031 /* Index field is not in the database. */
#define BAD_KEY		    4032 /* Index must be character,numeric,date*/
#define BAD_ENTITY          4034 /* Bad entity number or alias during FIND */
#define BAD_FIELD           4035 /* Bad field number or name during FIND */
#define NOT_LOGGED_IN	    4036 /* Database control file not defined*/
#define NULL_LINK_MODE      4037 /* NULL linkage generation mode */
#define NDX_NOTFOUND        4038 /* filter index file not found */
#define NDX_NOTVALID        4039 /* filter index file not valid */
#define NDX_BADOPEN         4040 /* unable to open filter index file */
#define NDX_MSLINK          4041 /* filter index file key not MSLINK */
#define NO_FILE             4042 /* file not found */
#define ALIAS_NOT_FOUND     4043 /* database or entity # not found */
#define CTRL_READ_ERR	    4044 /* read control database */
#define MSLINK_NOT_SET	    4045 /* unable to assign MSLINK key */
#define NO_MEMOFIELD        4046 /* may not read/write memo fields */
#define CTRL_EMPTY_ERR      4047 /* no records in the control file */
#define DB_LOCK_FAIL        4048 /* unable to lock database file */
#define NDX_LOCK_FAIL       4049 /* unable to lock index file */
#define NO_USER_MSLINK_NDXS 4050 /* no user MSLINK index files */
#define NO_TABLE_NAME		4051 /* no table found in SELECT */
#define NO_FIELD_VALUE		4052 /* no column value found in SELECT */
#define NO_RELATIONAL_OPERATOR	4053 /* =,<,>,>=,<=,<> not found in SELECT */
#define UNBALANCED_QUOTES	4054 /* trailing single quote not found */
#define NO_WHERE_CLAUSE		4055 /* no where clause in SELECT */
#define NO_FIELD_NAME		4056 /* no field in where clause of SELECT */
#define UNKNOWN_STATEMENT	4057 /* statement not recognized */
#define NO_ROWS_RETURNED	4058 /* no rows returned by SELECT */
#define BAD_LINKTYPE		4059 /* illegal types in MS_LINKTYPE */
#define AE_REQUIRES_INSERT	4060 /* AE= command requires INSERT */
#define NULL_LINKAGE_MODE	4061 /* NULL linkage mode active */
#define ROW_DELETE_ERROR	4062	/* error deleting table row */
#define TABLE_NOT_OPEN		4063	/* table not open */
#define AE_NOT_SUPPORTED	4064	/* AE not implemented (yet) */
#define AE_FOR_NEWLINK		4065	/* AE command only for NEW mode */
#define DATABASE_NOT_OPEN	4066	/* database not open */
#define NOT_IMPLEMENTED		4067	/* function not implemented */
#define USE_ACTUAL_TABLE	4068	/* AE command use actual table */
#endif
						
#if defined (INFORMIX)
/* Database Resource Messages */
#define RETURN_TO_CONT	    5000    /* "Return to Continue" */
#define DB_SUCCESS	    5001    /* normal successful completion */
#define FILTER_STATUS	    5002    /* fence filter status */
#define ROW_DELETED	    5003    /* database record deleted */
#define LINKAGE_MODE	    5004    /* linkage mode string */
#define ON_STRING	    5005    /* "On" */     
#define OFF_STRING	    5006    /* "Off" */
#define NONE_STRING	    5007    /* "NONE" */
#define DELETE_ENTITY	    5008    /* "Delete Entity: " */
#define KEYIN_PROCESSED	    5009    /* keyin processed */
#define DATABASE_NAME	    5010    /* database name */
#define DATA_RESET	    5011    /* Data to Accept / Reset to Continue */  
#define LINKAGE_DETACHED    5012    /* linkage detached from element */  
#define LINKAGE_ATTACHED    5013    /* linkage attached to element */  

/* Database Resource Errors */
#define INSUFFICIENT_MEMORY 4000	/* allocate database memory */
#define SYNTAX_ERROR	    4001	/* command line syntax error */
#define NO_AE_DEFINED       4002	/* no active entity defined */
#define NO_WRITE	    4003	/* record not written to database */
#define NO_LINK_DATA	    4004	/* no database linkage present  */
#define NO_REPORT	    4005	/* unable to generate report file */
#define NO_ENTITY	    4006	/* no entity specified */
#define NO_MSLINK	    4007	/* no MSLINK linkage field. */
#define REPORT_BADOPEN	    4008	/* unable to open report file. */
#define ENTITY_BADVALUE	    4009	/* entity # not between 0 and 65535 */
#define FORMAT_NOTFOUND	    4010	/* screen form file not found. */
#define NULL_LINK_MODE      4011        /* NULL linkage generation mode */
#define FILE_NOT_FOUND      4012        /* file not found */
#define SQL_ERROR           4013        /* SQL error code */
#define DB_NOT_FOUND        4014        /* unable to locate database */
#define NO_MSCATALOG        4015        /* unable to read MSCATALOG table  */
#define NOT_UNIQUE          4016        /* more than one row from  FIND*/
#define NOT_SELECT_REQUEST  4017        /* not a Select statement */
#define DB_NOT_VALID        4018        /* database is not valid */
#define NO_ROWS             4019        /* no rows returned from FIND */
#define NO_MSLINK_COLUMN    4020        /* no MSLINK column */
/* ESQL messages 4021 - 4276  */    
#define UNKNOWN_ESQL_ERROR  4277        /* unknown ESQL error message */
#define BAD_MSCATALOG       4278        /* illegal format of MSCATALOG */
#define NO_REVIEW           4279        /* unable to review attributes */
#define BAD_REVIEW_TABLE    4280        /* bad review table */
#define NO_MSCATALOG_ENTRY  4281        /* table not present in MSCATALOG */
#define NO_MSCATALOG_UPDATE 4282        /* unable to update MSCATALOG table */
#define BAD_REPORTFILE      4283        /* bad report specification */
#define BAD_MSLINK          4284        /* bad MSLINK key in DBREAD/DBWRITE */
#define DATABASE_NOT_FOUND  4285        /* database not found */
#define BAD_FENCE_FILTER    4286        /* bad fence filter */
#define NO_DB_TASK_SLOTS    4287        /* no more slots for applications */
#define DB_QUEUE_INIT_ERROR 4288        /* unable to create message queue */
#define BAD_COLUMN          4289        /* column number out of bounds */
#define ILLEGAL_CC_CODE     4290        /* illegal scan comparison code */
#define BAD_LINKTYPE        4291        /* illegal types in MS_LINKTYPE */
#define UNKNOWN_DATATYPE    4292        /* illegal data type in DB_GETFMT */
#define MSLINK_NOT_SET	    4293        /* unable to set MSLINK */
#define ROW_DELETE_ERROR    4294	/* error deleting table row */
#define TABLE_NOT_OPEN	    4295	/* table not open */

#define ESQL_COL_NOT_FOUND  -217        /* column not found in any table */
#endif
#endif 
