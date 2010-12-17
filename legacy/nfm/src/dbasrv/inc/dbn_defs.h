/* $Revision: 1.1 $ */
/*
Description: This is the main #define include file for the dbn functions
              
Author: T. F. Ezell

Date: 27-Jul-90
*/
#ifndef dba_nfm_defs
#define dba_nfm_defs

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE 
#define TRUE (!FALSE)
#endif

#define MAXNAME 128
#define DBA_NFM_FILE_LENGTH 14
#define DBA_NFM_COLUMN_LENGTH 40
#define DBA_NFM_VALUE_LENGTH 240
#define DBA_NFM_ITEM_LENGTH 128
/*
	Tokens for the NFM control file
*/
#define DBA_NFM_SERVER_NODE 0
#define DBA_NFM_USER 1
#define DBA_NFM_PASSWD 2
#define DBA_NFM_ENVIRONMENT 3
#define DBA_NFM_UNKNOWN_KEYWORD -1
#define DBA_NFM_NUM_KEYWORDS 4

#define DBA_NFM_SUCCESS 0
#define DBA_NFM_NONODE 2001
#define DBA_NFM_NOUSER 2002
#define DBA_NFM_NOPASSWD 2003
#define DBA_NFM_NOENV 2004
#define DBA_NFM_FORFAIL 2005
#define DBA_NFM_LOGINFAIL 20
#define DBA_NFM_INVALID_FILENAME 2007
#define DBA_NFM_INVALID_DATA 2008
#define DBA_NFM_INVALID_STATE 2009
#define DBA_NFM_INVALID_MEMBER 2010
#define DBA_NFM_INVALID_USER 2011
#define DBA_NFM_INVALID_COLUMN 2012
#endif
