/* $Id: VDrisc.h,v 1.7 2002/06/14 13:59:59 ahundiak Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:  include/VDrisc.h
 *
 * Description: C Friendly ris interface
 *              Used to be called VDris2.h
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrisc.h,v $
 *	Revision 1.7  2002/06/14 13:59:59  ahundiak
 *	ah
 *	
 *	Revision 1.6  2002/05/31 19:22:51  jdsauby
 *	Changed Tinfo to TVDrisCacheInfo.  JDS
 *	
 *	Revision 1.5  2002/05/31 16:12:27  jdsauby
 *	Added ci=COz_risCache for debug tool for VDrisCache.c, JDS
 *	
 *	Revision 1.4  2002/05/24 17:50:08  jdsauby
 *	Added VDRIS_CACHE_ROUTE 4, per TR5586
 *	
 *	Revision 1.3  2002/05/09 17:45:45  ahundiak
 *	ah
 *	
 *	Revision 1.2  2001/02/17 14:06:12  ahundiak
 *	ah
 *	
 *	Revision 1.1  2001/02/11 17:30:41  ahundiak
 *	ah
 *	
 *	Revision 1.3  2001/02/01 21:24:40  ahundiak
 *	ah
 *	
 *	Revision 1.2  2001/01/10 16:11:30  art
 *	sp merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *
 * Revision 1.7  2000/10/15  12:49:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/21/99  ah      Created
 * 08/15/00  ah      Add Set Default Schema capability
 * 08/25/00  ah      Add Get column Name Query
 * 09/26/00  ah      c Friendly
 * 01/10/01  ah      sp merge
 * 02/11/01  ah      Renamed to VDrisc.h
 * 05/09/02  ah      Added cache
 * -------------------------------------------------------------------*/
#ifndef VDrisc_include
#define VDrisc_include

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#ifndef VDctx_include
#include "VDctx.h"
#endif

/* ------------------------------------------
 * Usual bs
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * Existing routines
 * Prototype them here because the official prototypes
 * cannot be included by ppls
 *
 * Not sure why IGR typedefs not used
 * Will find out first time its recompilied
 */
extern int VDSverify_login  __(());

extern int VdsRisFreeBuffer __((char **buffer, int n));

extern int VDSsql_query     __((
  char *select_stmt,
  int  *ncols, 
  int  *nrows, 
  char **result[]));

extern int VDSexecute_sql_stmt __((char *sql_stmt));

extern int VDSopen_ris_schema  __((char *schema));

/* -----------------------------------------------
 * Standard query data structure
 */
typedef struct {
  int  rows,cols;
  int  i,j;
  char sql[256];
  char **buf;
} TVDrisInfoOld;

typedef struct {
  int  rows,cols;
  int  row, col;
  int  rec;
  int  i,j;
  char sql[256];
  char **buf;
} TVDrisInfo;

/* -----------------------------------------------
 * Standard interfaces
 */
extern int VDrisIsLoggedIn __((int warn, int *flag));
#ifndef c_ONLY
#omdef vdris$IsLoggedIn(warn = 0, flag = NULL)
VDrisIsLoggedIn((warn),(flag))
#endomdef
#endif

extern int VDrisIsSchemaOpen __(());
#ifndef c_ONLY
#omdef vdris$IsSchemaOpen()
VDrisIsSchemaOpen()
#endomdef
#endif

// NULL will use env var ISDP_SCHEMA
extern int VDrisOpenSchema __((IGRchar *schema));
#ifndef c_ONLY
#omdef vdris$OpenSchema(schema = NULL)
VDrisOpenSchema((schema))
#endomdef
#endif

extern int VDrisGetOpenSchema __((IGRchar *schema));
#ifndef c_ONLY
#omdef vdris$GetOpenSchema(schema = NULL)
VDrisGetOpenSchema((schema))
#endomdef
#endif

extern int VDrisGetLazySchema __((IGRchar *schema));
#ifndef c_ONLY
#omdef vdris$GetLazySchema(schema = NULL)
VDrisGetLazySchema((schema))
#endomdef
#endif

extern int VDrisCloseSchema __(());
#ifndef c_ONLY
#omdef vdris$CloseSchema(sql)
VDrisCloseSchema(())
#endomdef
#endif

extern int VDrisInitInfo __((TVDrisInfo *info));
#ifndef c_ONLY
#omdef vdris$InitInfo(info)
VDrisInitInfo((info))
#endomdef
#endif

extern int VDrisFreeInfo __((TVDrisInfo *info));
#ifndef c_ONLY
#omdef vdris$FreeInfo(info)
VDrisFreeInfo((info))
#endomdef
#endif

extern int VDrisQuery __((TVDrisInfo *info, char *qry));
#ifndef c_ONLY
#omdef vdris$Query(info, qry = NULL)
VDrisQuery((info),(qry))
#endomdef
#endif

extern int VDrisExecute __((char *sql));
#ifndef c_ONLY
#omdef vdris$Execute(sql)
VDrisExecute((sql))
#endomdef
#endif

extern int VDrisExecuteSilent __((char *sql));
#ifndef c_ONLY
#omdef vdris$ExecuteSilent(sql)
VDrisExecuteSilent((sql))
#endomdef
#endif

extern int VDrisValidateUser  __((IGRchar *name, IGRchar *pass, IGRint *no));
 
extern int VDrisDomQuery __((IGRchar *qry, TGRid *domID));
 
/* ---------------------------------------------------
 * Always wanted to get columns in a clean fashion
 * set schema compatibility
 * gives length as well as names and types
 */

/* -----------------------------------------------
 * Basically, copied and renamed from VDSris_def
 */
#define VDRIS_TBLN_COLUMNS       "ris5columns"
#define VDRIS_COLN_COLUMNS_NAME  "column_name"
#define VDRIS_COLN_COLUMNS_TYPE  "ris_type"
#define VDRIS_COLN_COLUMNS_TYPES "ris_type_string"
#define VDRIS_COLN_COLUMNS_LEN   "char_max_length"
#define VDRIS_COLN_COLUMNS_POS   "position"
#define VDRIS_COLN_COLUMNS_TABLE "table_name"

#define VDRIS_COLI_COLUMNS_NAME  0
#define VDRIS_COLI_COLUMNS_TYPE  1
#define VDRIS_COLI_COLUMNS_TYPES 2
#define VDRIS_COLI_COLUMNS_LEN   3
#define VDRIS_COLI_COLUMNS_POS   4
#define VDRIS_COLI_COLUMNS_TABLE 5

extern IGRstat VDrisQryTableColumns __((TVDrisInfo *ris, IGRchar *table_name));
#ifndef c_ONLY
#omdef vdris$QryTableColumns(info, name)
VDrisQryTableColumns((info),(name))
#endomdef
#endif

extern IGRstat VDrisListTableColumns __((IGRchar *table_name));

/* ----------------------------------------------------
 * VDrisBlob.rc
 */
#define VDRIS_TBLN_BLOBS      "isdp_blobs"
#define VDRIS_FLDN_BLOBS_KEY  "blob_key"
#define VDRIS_FLDN_BLOBS_SORT "blob_sort"
#define VDRIS_FLDN_BLOBS_DATA "blob_data"

extern IGRstat VDrisInsertBlobRecord __((IGRint   key, 
					 IGRchar *fileName,
                                         IGRint   compress,
					 void (*showStatus)(IGRchar *buf)));

extern IGRstat VDrisSelectBlobRecord __((IGRint   key, 
					 IGRchar *fileName, 
					 IGRint   compressed,
					 IGRint   cached,
					 void (*showStatus)(IGRchar *buf)));

extern IGRstat VDrisDeleteBlobRecord __((IGRint key,                  
					 void (*showStatus)(IGRchar *buf)));

extern IGRstat VDrisTestInsertSelectBlobRecord __(());

/* ----------------------------------------------------
 * VDrisBlob.c
 */

/* Blob Index Interface */
#define VDRIS_TBLN_BLOBI           "vdat_blobs"
#define VDRIS_RECN_BLOBI           "vdat_blob"

#define VDRIS_COLN_BLOBI_FILE_KEY  "file_key"
#define VDRIS_COLN_BLOBI_PURPOSE   "purpose"
#define VDRIS_COLN_BLOBI_HULL      "hull"
#define VDRIS_COLN_BLOBI_SET_TYPE  "set_type"
#define VDRIS_COLN_BLOBI_SET_NAME  "set_name"
#define VDRIS_COLN_BLOBI_SET_VER   "set_ver"
#define VDRIS_COLN_BLOBI_SET_CUR   "set_cur"
#define VDRIS_COLN_BLOBI_POST_DATE "post_date"
#define VDRIS_COLN_BLOBI_BLOB_KEY  "blob_key"

#define VDRIS_COLI_BLOBI_FILE_KEY  0
#define VDRIS_COLI_BLOBI_PURPOSE   1
#define VDRIS_COLI_BLOBI_HULL      2
#define VDRIS_COLI_BLOBI_SET_TYPE  3
#define VDRIS_COLI_BLOBI_SET_NAME  4
#define VDRIS_COLI_BLOBI_SET_VER   5
#define VDRIS_COLI_BLOBI_SET_CUR   6
#define VDRIS_COLI_BLOBI_POST_DATE 7
#define VDRIS_COLI_BLOBI_BLOB_KEY  8

typedef struct 
{
  IGRint  file_key;
  IGRchar purpose [20];
  IGRchar hull    [20];
  IGRchar set_type[20];
  IGRchar set_name[20];
  IGRint  set_ver;
  IGRint  set_cur;
  IGRchar post_date[20];  
  IGRint  blob_key;
} TVDblobiRecord;

extern IGRstat VDrisQryBlobIndex         __((TVDrisInfo *info));
extern IGRstat VDrisBlobIndexBufToRecord __((IGRchar *buf[], TVDblobiRecord *record));

/* ----------------------------------------------------
 * VDrisKey.rc
 */
extern int VDrisGetNextKey    __((char *key_name, int *key));  
extern int VDrisGetCurrentKey __((char *key_name, int *key));

/* -----------------------------------------------------
 * This is actually private stuff here
 * Used during the query data translation
 */
typedef struct {
  int num;
  int max;
  int inc;
  char **data;
} TVDrisBuf;

extern int VDrisAddData           __((char *data, TVDrisBuf *buf));
//tern int VDrisGetDataFromSqlvar __((sqlvar *var, char *data));

extern int VDrisSqlDblToStr       __((double val,          char *buf));
extern int VDrisSqlIntToStr       __((int    val,          char *buf));
extern int VDrisSqlStrToStr       __((char  *val, int len, char *buf));
extern int VDrisSqlDateTimeToStr  __((char  *val, int len, char *buf));

/* ----------------------------------------------
 * Caching stuff VDrisCache.c
 */

typedef struct 
{
  TGRid           findID;
  TGRid           queryIDs;
  TVDctxNodeList  queryList;
} TVDrisCacheInfo;

typedef struct
{
  IGRint cnt;
  TVDrisCacheInfo *infos;
} TVDrisCacheInfos;

extern void VDrisQueryCache    __((IGRint cacheNum, TVDrisInfo *ris, IGRchar *qry));

extern void VDrisDomQueryCache __((IGRint cacheNum, IGRchar *qry, TGRid *recordsID));

extern void VDrisOldQueryCache __((IGRint cacheNum, IGRchar *qry, 
                                   IGRint *ncols, 
                                   IGRint *nrows, 
                                   IGRchar **results[]));

extern void VDrisDumpCache     __((IGRint cacheNum, IGRchar *fileName));

extern IGRstat VDrisLoadCacheFromXmlFile __((IGRchar *fileName));

extern IGRstat VDrisGetCacheInfos        __((TVDrisCacheInfos **infos));

extern void VDrisDeleteCache __(());



#define VDRIS_CACHE_VDS 3
#define VDRIS_CACHE_ROUTE 4

//Cleanup
#if defined(__cplusplus)
}
#endif

#endif

