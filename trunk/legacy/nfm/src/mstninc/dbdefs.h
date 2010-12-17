/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Workfile:   dbdefs.h  $
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
|   dbdefs.h -- database definitions					|
|									|
+----------------------------------------------------------------------*/
#ifndef __dbdefsH__
#define __dbdefsH__
						
/* linkage generation modes */
#define NOLINK	    -1	        /* null linkage mode */
#define NEWLINK	     0	        /* new linkage generation mode */
#define INFOLINK     1	        /* informational linkage mode */ 
#define DUPLINK      2	        /* duplicate linkage mode */
						
/* linkage types recognized by MicroStation database servers */	    
#define	INFORMIX_LINKAGE    1
#define	DMRS_LINKAGE	    2
#define	DBASE_LINKAGE	    4
#define	ORACLE_LINKAGE	    8
#define	RIS_LINKAGE	    16

/* signature words for user data linkages */			
#define INFORMIX_ID   0x3948	/* Informix user data signature */
#define DBASE_ID      0x1971	/* dBase user data signature */
#define RIS_ID	      0x71fb	/* RIS user data signature */
#define ORACLE_ID     0x6091	/* Oracle user data signature */
    
#define PRIMARY_ID    0x1971	/* User ID for dBASE linkage (DB3 radix 50) */
#define SECONDARY_ID  0xf81     /* Secondary ID link (BSI radix 50) */
						
/* masks for the properties high NIBBLE of database linkages */
#define DB_PROP_INFO	    0x8000
#define DB_PROP_REMOTE	    0x4000
#define DB_PROP_MODIFIED    0x2000
#define DB_PROP_USER	    0x1000
#define DB_PROPERTY_MASK    0xf000
						
/* masks for the properties WORD of database linkages */
#define USER_LINKAGE	    0x1000  /* user data linkage */
#define INFO_LINKAGE	    0x8000  /* informational linkage */

/* miscellaneous masks */
#define NULL_MASK	    0x8000 /* null/not null in type descriptor */
#define TYPE_MASK	    0x7fff /* mask type off type descriptor */

/* MicroStation message resource defines */
#define SERVER_INIT         353   /* database server initialized */
#define DBLOAD	       	    354	  /* loading and initializing database */

/* MicroStation error resource defines */
#define DBSERVER_NOT_ACTIVE   2143  /* server not active */
#define SERVER_INIT_ERROR     2157  /* unable to initialize server */  
#define MSG_SEND_ERROR        2158  /* unable to send database request */
#define MSG_RCV_ERROR         2159  /* unable to receive database response */
#define SERVER_STARTUP_ERROR  2160  /* unable to startup database server */
#define DB_NOT_CONFIGURED     2161  /* not configured with the database. */
#define MAX_ADATA	      2162  /* maximum user data size exceeded */
#define DB_NO_DATYPE	      2200  /* no display attribute type specified */
#define SELECT_SOURCE_LINK     601  /* select element to provide linkage */

#define DB_HANDLE_REQUEST	1  /* database request hook for MDL */
#define MCSL_HANDLE_REQUEST	2  /* MicroCSL call back hook for MDL */
    
/* MicroStation database data types */
#define DB_CHAR		    1
#define DB_NUMBER	    2
#define DB_DATE		    3

#define QUERY_NOT_FINISHED  0	/* current query is not finished */
#define QUERY_FINISHED	    1	/* currey query has finished */

#if defined (macintosh)
typedef struct user_link
    {
    unsigned info:1;	    /* boolean: informational linkage */
    unsigned remote:1;	    /* boolean: remote linkage */
    unsigned modified:1;    /* boolean: user linkage has been modified */
    unsigned user:1;	    /* boolean: user data linkage */
    unsigned class:4;	    /* linkage family class */
    unsigned words:8;	    /* words to follow in linkage */
    unsigned short id;	    /* User ID number */
    } UserLink;
#else
typedef struct user_link
    {
    unsigned words:8;	    /* words to follow in linkage */
    unsigned class:4;	    /* linkage family class */
    unsigned user:1;	    /* boolean: user data linkage */
    unsigned modified:1;    /* boolean: user linkage has been modified */
    unsigned remote:1;	    /* boolean: remote linkage */
    unsigned info:1;	    /* boolean: informational linkage */
    unsigned short id;	    /* User ID number */
    } User_Link;
#endif
						
typedef struct	
    {
    unsigned short	information;	/* informational linkage */
    unsigned short	remote;		/* remote linkage */
    unsigned short	modified;	/* user linkage has been modified */
    unsigned short	user;		/* user data linkage */
    unsigned short	class;		/* linkage family class */
    } LinkProps;
						
typedef struct
    {
    unsigned short  linkSize;	    /* total size (bytes) of linkage */
    unsigned short  linkType;	    /* type (ORACLE, DMRS, DBASE...) */
    unsigned short  entity;	    /* entity number */
    char	    tablename[64];  /* database table */
    unsigned long   mslink;	    /* MSLINK key of linkage */
    LinkProps	    props;	    /* properties */
    unsigned short  dasType;	    /* displayable attributes */
    } DatabaseLink;
    
typedef struct 
    {
    short   numColumns;
    char    **name;
    char    **value;
    short   *type;
    short   *length;
    short   *scale;
    short   *prec;
    short   *null;
    } MS_sqlda;
#endif

