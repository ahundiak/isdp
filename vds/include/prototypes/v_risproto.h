/* $Id: v_risproto.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:		include/prototypes/ v_risproto.h
 *
 * Description:
 *	Prototypes for vdris/imp and vdris/ris
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_risproto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1996/04/21  22:33:28  pinnacle
 * Created: include/prototypes/v_risproto.h by v240_int for vds.240
 *
 *
 * History:
 * 	04/18/96  tlb	    Created
 *
 * -------------------------------------------------------------------*/
#ifndef vdrisproto_include
#	define vdrisproto_include 1

#include <standards.h>
#include "FI.h"			/* defines Form */
#include "VDSris_siz.h"		/* defines MAXWORD for VDSload.h*/
#include "VDSload.h"		/* defines struct MFload */


/* VDS_project.C */
extern int VDSget_projectno 	__((int *prj_no	));

/* VDSval_user.C */
extern int VDSvalid_user 	__((char username[],
					char password[],
					char ret_msg[80 ]	));

/* VDSver_cat.C */
extern int VDSverify_catalog 	__((char catalog[]	));

/* VDSver_login.C */
extern int VDSverify_login 	__((void	));

/* VDSver_part.C */
extern int VDSverify_part 	__((char catalog[],
					char part_id[],
					char revision[]	));

/* VdsExec.C */
extern int VdsExtractDecodedString 
				__((char key[],
					char decode[]	));

/* VdsFun.C */
extern int VdsLeadingTrash 	__((char *string,
					char trash,
					int all	));
extern int VdsTrailingTrash 	__((char *string,
					char trash,
					int all	));
extern int VdsCleanString 	__((char *string	));
extern int VdsNormalize 	__((char *string	));
extern int VdsTwoString 	__((char *string,
					char *before,
					char *after	));
extern int VdsSplitString 	__((char *string,
					int charnum,
					char *before,
					char *after	));
extern int VdsZeroForNull 	__((char *string	));
extern int VdsRetrieveLoadData 	__((char *ascii,
					struct MFload *p_load	));
extern int VdsStaticDatatype 	__((char *table_name,
					char *load_path,
					int *datatype,
					int *p_number,
					char *ddl_file	));
extern int VdsEvaluateDatatype 	__((char *datatype	));
extern int VdsNetdecode 	__((char encode[],
					char decode[]	));
extern int VdsJoker 		__((char *string,
					int number	));
extern int VdsSqlAscii 		__((char *tab_nam,
					int col_num,
					int *col_typ,
					char **col_val,
					FILE *fp	));
extern int VdsConvertDatatype 	__((int inttype,
					char *chartype	));

/* VdsLoad.C */
extern int VdsExtractDecodedString 	
				__((char key[],
					char decode[]	));

/* VdsRis.C */
extern int VdsDeleteRows 	__((char *key,
					char *table_name,
					char *catalog,
					char *partnum,
					char *partrev	));
extern int VdsInsertRows 	__((char table_name[],
					int number,
					char *chartype[],
					int inttype[],
					char row[],
					int *p_delete,
					int *p_print,
					int to_sql,
					FILE *sqlfile	));
extern int VdsReadCompNo 	__((int *p_comp_no	));
extern int VdsWriteCompNo 	__((int comp_no	));
extern int VdsGetCatId 		__((char catalog[],
					int *p_catalog_id	));
extern int VdsGetPartId 	__((char catalog[],
					char partnum[],
					char revision[],
					int *p_part_id	));
extern int VdsGetIdentifier 	__((char catalog[],
					char partnum[],
					char revision[],
					int *p_catalog_id,
					int *p_part_id	));

/* VdsRisConn.C */
extern int VdsRisConnect 	__((char *env_name	));
extern int VdsReset_ris_env 	__((void	));

/* VdsRisLogin.C */
extern int VdsLoginNotif 	__((int f_label,
					int g_label,
					double value,
					Form fp	));
extern int VDSRislogin 		__((void	));
extern int VDSget_login_defaults 	
				__((char username[],
					char environ[],
					char project[]	));
extern int VDSset_login_defaults 	
				__((char username[],
					char environ[],
					char project[]	));
extern int VdsPtrStrcpy 	__((char **outstring,
					char *string	));
extern int VDScheck_environ 	__((char environment[]	));

/* VdsRisSql.C */
extern int VdsRisSelect 	__((char select[],
					char table[],
					char where[],
					char order[],
					char group[],
					char having[],
					int nbatt,
					int *p_nbocc,
					char **p_buffer[]	));
extern int VdsRisFreeBuffer 	__((char **buffer,
					int n	));
extern int VdsRisExtractValue 	__((int nbocc,
					int nbatt,
					char **buffer,
					int occ,
					int att,
					char value[]	));
extern int VdsRisDelete 	__((char table[],
					char where[]	));
extern int VdsRisInsert 	__((char table[],
					char columns[],
					char values[],
					char select[]	));
extern int VdsRisUpdate 	__((char table[],
					char set[],
					char where[]	));
extern int VdsRisAttach 	__((void	));
extern int VdsRisDetach 	__((void	));
extern int VdsSqlInsert 	__((char *tab_nam,
					int col_num,
					int *col_typ,
					char **col_val	));
extern int VdsClearStmt 	__((void	));
extern int VdsRisEnquireOpenSchema 	
				__((void	));
extern int VdsRisGetPartCount 	__((char *table,
					char *where,
					int *count	));
extern int VdsRetrieveAttribute	__((char dyn_tabname[],
					int *p_num,
					char **p_attr[],
					char **p_type[]	));

/* VdsRisTbl.C */
extern void VdsDelTrailBlanks 	__((char *str	));
extern int VdsManipTables 	__((char *vds_table_name,
					int operation,
					int nbcols,
					char **columns,
					char **coltypes	));
extern int VdsInsertRowsinTable	__((char *vds_table_name,
					int nbcols,
					char **columns,
					int *coltypes,
					char **colvalues	));
extern int VdsVerifyRisTable 	__((char *table_name	));


/* ris/VdsRisLib.rc */
extern int VDSopen_ris_schema 	__((char *schema_name	));
extern int VDSclose_ris_schema 	__((char *schema_name	));
extern int VDSsql_query 	__((char *select_stmt,
					int *ncols, 
					int *nrows, 
					char **result[]	));
extern int VDSexecute_sql_stmt 	__((char *statement	));
extern int VDSsql_query1 	__((char *select_stmt1,
					int *ncols, 
					int *nrows, 
					char **result[], 
					char **columns[], 
					int **coltype	));

#endif
