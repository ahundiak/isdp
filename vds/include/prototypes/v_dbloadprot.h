/* $Id: v_dbloadprot.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:		include/prototypes/ v_dbloadproto.h
 *
 * Description:
 *	Prototypes for vddb/source directory - VDSloaddata
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_dbloadprot.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/07/16  18:41:00  pinnacle
 * Replaced: include/prototypes/v_dbloadprot.h for: Fix for CR# 179422209 by aprahlad for vds
 *
 * Revision 1.2  1997/07/16  18:28:38  pinnacle
 * fix for CR#179422209
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.3  1996/05/23  23:56:16  pinnacle
 * Replaced: include/prototypes/v_db* for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1996/05/20  03:02:54  pinnacle
 * Replaced: include/prototypes/v_db* for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1996/05/16  21:17:14  pinnacle
 * Created: include/prototypes/v_dbloadprot.h by tlbriggs for vds.240
 *
 * Revision 1.1  1996/04/21  22:33:38  pinnacle
 * Created: include/prototypes/v_dbloadproto.h by v240_int for vds.240
 *
 *
 * History:
 * 	04/18/96  tlb	    Created as v_dbloadproto.h
 *	05/02/96  tlb	    Updated, rewnamed v_dbloadprot.h 
 *	05/19/96  tlb	    Updated error routines
 *	05/22/96  tlb	    Updated 
 *      07/14/97  ap        Changed prototype of VDbinitialize_login_strs()
 *                          and VDBstore_login_strs() to read/write user's
 *                          choice of being warned or not about operations
 *                          that result in data being deleted.
 *
 * -------------------------------------------------------------------*/

#ifndef vdbloadproto_include
#	define vdbloadproto_include 1

#include 	<standards.h>
#include 	<curses.h>		/* defines WINDOW */
#include 	<MEMstruct.h>		/* defines MEMptr	*/
#include	"VDSdbstr.h"		/* defines struct MFlin */
#include 	"VDBload.h"		/* defines struct VDBtable */
#include 	"VDmem.h"		/* defines IGRint */

#include 	"VDdbgFile.h"		/* defines dbg file, debugging*/



/* Globals */
extern	long    VDSuser_id;		/* NFM user id */
extern  char    VDBvds[81];		/* VDS product directory name */

extern	WINDOW  *VDBmsgwin;
extern	char    VDBmsgstrs[8][81]; 
extern	char	VDBtmps[81];		/* User prompt string */
extern	char	VDBbuff[256];
extern	long    VDBerrstat;


/* VDSdbbuf.C */
extern	int VDSascii_to_buffer 	__((char *file_name,
					MEMptr *p_buffer	));
extern	int VDSwrite_in_buffer 	__((MEMptr buffer,
					char *attr_name,
					int n_row,
					char *attr_value	));
extern	int VDSread_in_buffer 	__((MEMptr buffer,
					char *attr_name,
					int n_row,
					char *attr_format,
					char *attr_value	));
extern	int VDSclose_buffers 	__((MEMptr *buffer1,
					MEMptr *buffer2,
					MEMptr *buffer3	));
extern	int VDSfamily_parameters __((MEMptr desc_buffer,
					char *macro_library,
					char *macro_name,
					char *macro_desc	));
extern	int VDSparm_pmpt_user 	__((MEMptr desc_buffer,
					MEMptr *p_parm_buffer,
					MEMptr *p_user_buffer	));
extern	int VDSfill_part_data_buffer 
				__((MEMptr *p_buffer,
					char *partnum,
					char *description,
					char *n_acl_format,
					char *n_acl_value	));
extern	int VDSdefault_buffer 	__((MEMptr *p_loc_attr_def,
					MEMptr *p_loc_data_def,
					MEMptr *p_loc_list_def,
					MEMptr *p_cat_attr_def,
					MEMptr *p_cat_data_def,
					MEMptr *p_cat_list_def	));
extern	int VDScheck_attribute 	__((char line[],
					int *n_stat,
					int *stat_alloc,
					char **stat_attrs[],
					int *n_dyn,
					int *dyn_alloc,
					char **dyn_attrs[]	));
extern	int VDSpdm_parm_buf 	__((MEMptr desc_buffer,
					char *catalog_name,
					char *macro_lib,
					char *macropart,
					char *macrorev,
					MEMptr *param_buf,
					MEMptr *macro_buf	));
extern	int VDSclass_path 	__((MEMptr desc_buffer,
					char *catalog_name,
					MEMptr *class_path	));
extern	int VDSdbcheck_keyword 	__((char *attr_name	));
extern	int VDSsepsyndef 	__((char *string,
					char *synonym,
					char *defstr	));

/* VDSdbdelpart.C */
extern	int VDSDeleteParts 	__((char *catalog_name,
					char *n_itemname,
					char *n_itemrev,
					char *product	));

/* VDSdblink.C */
extern	long VDBAddPart 	__((char (*fam_part_list )[81 ],
					int noparts,
					char listselflag[],
					char schema_name[],
					char schema_passwd[]	));
extern	long VDBcreatcat 	__(( char schema_name[],
					char schema_passwd[],
					char (*fam_part_list )[81 ],
					int nofam,
					char *listselflag	));
extern	long VDBdeleteparts 	__((char catname[],
					char partno[],
					char partrev[]	));
extern	long VDBdeleteCatalog 	__((char *catname	));
extern	long VdbDelCatalogs 	__((char (*CatalogList )[81 ],
					int NumbCat,
					char listselflag[]	));
extern	long VDBexecRisFile 	__((char *pathname,
					char *filename	));
extern	long VDBloadVdsTable 	__((char *pathname,
					char *filename	));
extern	long VDBupdateVdsDbase 	__((void	));
extern	long VDBconvertUnits 	__((char *VdsProjectName,
					char *VdsProjectRevision,
					char *NewUnits	));
extern	void VDBgetyesno 	__((char *prompt_str,
					char *c	));
extern	int VDBGenFamilyorPart 	__((char *catalog_name,
					char familyorpart,
					char *schema_name,
					char *schema_passwd,
					char debug	));
extern	long VDBmanipTable 	__((char *tablename,
					int norecs,
					struct VDBtable *recs,
					int operation	));
extern	long VDBdeleteTableData 	__((char *tablename	));
extern	long VDBInsertRows 	__((char *tablename,
					int norecs,
					struct VDBtable *recs	));

/* VDSdblog.C */
extern	int VDSlogin 		__((char *usr,
					char *passwd,
					char *env	));
extern	int VDSget_user_id 	__((char *user,
					int *uid	));
extern	int VDSget_table_no 	__((char *n_tablename,
					char *n_tabletype,
					int *n_tableno	));
extern	int VDSget_catno 	__((char *n_catalogname,
					int *n_catalogno	));
extern	int VDSverify_pdm_init 	__((void	));
extern	int VDSverify_part 	__((char *catalog,
					char *partnum,
					char *revision	));
extern	int VDSverify_catalog 	__((char *catalog	));
extern	void VDBinitialize_login_strs 	
				__((char usrname[16 ],
					char usrpasswd[16 ],
					char envname[16 ],
					char debug[16 ],
					char warning[16 ] ));
extern	void VDBstore_login_strs 	
				__((char usrname[16 ],
					char envname[16 ],
					char debug[16 ],
					char warning[16 ] ));


/* VDSdbrisload.C */
extern	int VDBris_load 	__((char *ascii_file,
					char *load_path,
					char *del_option	));
extern	int VDBris_insert_data 	__((char *table_name,
					char *load_path,
					char *file_name,
					int *delete	));

/* VDSload.C */
extern	void VDBmem_CheckPtrs 	__((void	));
extern	void VDBmem_Status 	__((char *name	));


/* VDSmenuops.C */
extern	long VDBuser_menu_oper 	__((WINDOW **userwin,
					int maxlen,
					int first_line,
					int first_col,
					int nostr,
					char *outstrs[]	));
extern	long VDBmain_menu_oper 	__((WINDOW **mainwin,
					int maxlen,
					int *selno	));
extern	long VDBtables_menu_oper 	
				__((WINDOW **tablewin,
					int maxlen,
					int *selno	));
extern	long VDBcatalog_menu_oper 	
				__((WINDOW **catalogwin,
					int maxlen,
					int *selno	));
extern	long VDBprod_menu_oper 	__((WINDOW **prodwin,
					int maxlen,
					char *prod_list[VDB_MAX_NO_PROD ],
					char selflag[]	));
extern	long VDBpath_menu_oper 	__((WINDOW **pathwin,
					int maxlen,
					int first_line,
					int first_col,
					int nostr,
					char *path_list[]	));
extern	long VDBlist_menu_oper 	__((WINDOW **listwin,
					int maxlen,
					int first_line,
					int first_col,
					int nofampart,
					int nostrdis,
					char fampartflag,
					char (*fam_part_list )[81 ],
					short bSelectAll,
					char *listselflag	));
extern	long VDBcat2_menu_oper 	__((WINDOW **catwin2,
					int maxlen,
					int *selno	));
extern	long VDBcatname_menu_oper 	
				__((WINDOW **catnamewin,
					int maxlen,
					int first_line,
					int first_col,
					int nostr,
					char *catname[]	));
extern	long VDBdelpart_menu_oper 	
				__((WINDOW **delpartwin,
					int maxlen,
					int first_line,
					int first_col,
					int nostr,
					char *catdata[]	));
extern	long VDButil_menu_oper 	__((WINDOW **utilwin,
					int maxlen,
					int *selno,
					int *state	));
extern	long VDBdyntbl_menu_oper
				__((WINDOW **dyntblwin,
					int maxlen,
					int *selno,
					int *state	));
extern	long VDBvalidateDatatype 	
				__((char *str	));
extern	long VDBvalidateDatavalue 	
				__((struct VDBtable record	));
extern	long VDBvalidateAttribData 	
				__((int *norecs,
					struct VDBtable **recs,
					int startrec,
					char DtypeorValFlg,
					int *filled_norecs	));
extern	long VDBcreatdyntbl_menu_oper 	
				__((WINDOW *dyntblwin,
					int maxlen1,
					int maxlen2,
					int norowsdisp,
					int *norecs,
					struct VDBtable **recs	));
extern	long VDBmodiftbl_menu_oper 	
				__((WINDOW *modiftblwin,
					int maxlen1,
					int maxlen2,
					int norowsdisp,
					char *tablename,
					int *norecs,
					struct VDBtable **recs	));
extern	long VDBcvrt_menu_oper 	__((WINDOW **cvrtunitswin,
					int maxlen,
					int first_line,
					int first_col,
					int nostr,
					char *outstrs[]	));
extern	long VDBregtbl_menu_oper 	
				__((WINDOW **regtblwin,
					int maxlen,
					int *selno,
					int *state	));
extern	long VDBcreatregtbl_menu_oper 	
				__((WINDOW *regtblwin,
					int maxlen1,
					int maxlen2,
					int norowsdisp,
					int *norecs,
					struct VDBtable **recs	));
extern	long VDBgetCatalogName 	__((char NeworOldCat,
					char catname[]	));
extern	int VdbGetCatalogs 	__((char (**CatList )[81 ],
					int *NumbCat	));
extern	long VDBcreatTableOption 	
				__((int *norecs,
					struct VDBtable **recs	));
extern	long VDBadddata_menu_oper 	
				__((WINDOW *adddatawin,
					int maxlen1,
					int maxlen2,
					int norowsdisp,
					char *tablename,
					int *norecs,
					struct VDBtable **recs	));
extern	int VDBgetTableName 	__((char *tablename,
					char NeworOldFlag	));
extern	long VDBgetVdsTableFile	__((char tableoperflag,
					char *pathname,
					char *filename,
					char *filename2	));

/* VDSwindow.C */
extern	long VDBmake_select_win	__(( /* variable length */ 	));
extern	long VDBmake_input_win 	__(( /* variable length */ 	));
extern	long VDBmenu_select_oper
				__((WINDOW **wind,
					int maxlen,
					int nostr,
					char msgstrs[8 ][81 ],
					int *selno	));
extern	long VDBmenu_input_oper __((WINDOW **wind,
					int maxlen,
					int first_line,
					int first_col,
					int nostr,
					int passwdrow,
					char delspaces,
					char msgstrs[8 ][81 ],
					char *outstrs[]	));
extern	long VDBdisplaySelectWin
				__((WINDOW **wind,
					char (*strs )[81 ],
					int topline,
					int nostrdis,
					int first_line,
					int first_col,
					char *selflag	));
extern	long VDBmenu_multi_select_oper 	
				__((WINDOW **wind,
					int maxlen,
					int first_line,
					int first_col,
					int nostr,
					int nostrdis,
					char hilitemode,
					char msgstrs[8 ][81 ],
					char (*strs )[81 ],
					short bSelectAll,
					char *selflag	));
extern	void VDBhilite		__(( WINDOW **wind,
  					int	 line,
  					int    maxlen	));
extern	void VDBdehilite	__(( WINDOW **wind,
  					int	 line,
  					int    maxlen		));
extern	long VDBgetfampartlist 	__((char *path_list[],
					int noprods,
					char selflag[],
					char fampartflag,
					char (**fam_part_list )[81 ],
					int *nofampart	));
extern	long VDBmake_attrib_win	__(( /* variable length */ 	));
extern	long VDBdisplayTable 	__((WINDOW *wind,
					struct VDBtable *recs,
					char tbltype,
					int toprow,
					int norowsdisp,
					int first_line,
					int first_col,
					int maxlen1	));
extern	long VDBattrib_win_oper	__((WINDOW *wind,
					int maxlen1,
					int maxlen2,
					int firstline,
					int firstcol,
					int norowsdisp,
					int editflag,
					int minrow,
					int maxrow,
					int mincol,
					int maxcol,
					int *norecs,
					struct VDBtable **recs,
					char tbltype	));

/* VDSdbdbase.c */
extern	int VDSadd_part 	__((MEMptr desc_buffer	));

extern	int VDSadd_family 	__((MEMptr desc_buffer,
					MEMptr loc_attr_def,
					MEMptr loc_data_def,
					MEMptr loc_list_def,
					MEMptr cat_attr_def,
					MEMptr cat_data_def,
					MEMptr cat_list_def	));
extern	int VDSadd_dynamic_table 	
				__((char *family_name,
					char *vds_product,
					char *vds_dyn_table,
					char *vds_cit_table,
					char *sch_dyn_table,
					char *vds_equip_ppl	));
extern	int VDScreate_catalog_index 	
				__((char *family_name	));

/* VDSbarmanu.c */
extern	void VDBrefrsh_bar_menu __(( void 	));
extern	void VDBdisplay_bar_menu 	
				__((int num_strs,
					char barstrs[8 ][9 ]	));
extern	void VDBmake_bar_win 	__((void	));


/* VDSdbdbg.c */
extern  char *VDBgetErrStr 	__((int sts	));
extern	int   VDSset_debug_on 	__((void	));
extern  void  VDSprintVdsErr	__((char * prefix,
					char 	*func,
					int 	status 	));
extern  void  VDSprintMemErr	__((char * prefix,
					char 	*func,
					int 	MEMstatus,
					int 	VDSstatus 	));
extern  void  VDSprintSqlErr	__((char * prefix,
					char 	*msg,
					char 	*sql,
					int 	status 	));
extern  void  VDSprintNfmErr	__((char * prefix,
					char 	*func,
					int 	status 	));

/* VDSdbdelcat.c */
extern	int VDSdelete_catalog 	__((char *catalog_name	));

/* VDSdbfamcat.c */
extern	int VDScreate_family_catalog 	
				__((char *macro_name,
					MEMptr parm_bufr,
					MEMptr user_bufr,
					MEMptr *p_loc_attr_bufr,
					MEMptr *p_loc_data_bufr,
					MEMptr *p_cat_attr_bufr,
					MEMptr *p_cat_data_bufr,
					MEMptr *p_cat_list_bufr,
					MEMptr loc_attr,
					MEMptr loc_data,
					MEMptr loc_list,
					MEMptr cat_attr,
					MEMptr cat_data,
					MEMptr cat_list,
					MEMptr dyn_attr,
					MEMptr *p_dyn_attr,
					char *dyn_data_row	));

/* VDSdbgettab.c */
extern	int VDSget_table_data 	__((int operation,
					int entity,
					char *catalog,
					MEMptr *attribute_buffer,
					MEMptr *data_buffer,
					MEMptr *list_buffers	));
extern	int VDSget_table_attributes 	
				__((int operation,
					int entity,
					MEMptr *attribute_buffer,
					MEMptr *data_buffer,
					MEMptr *list_buffers	));
extern	int VDScreate_application 	
				__((MEMptr *application	));
extern	int VDSadd_part_ 	__((char *catalog,
					MEMptr attr_list,
					MEMptr data_list	));
extern	int VDSupdate_data_buffer 	
				__((MEMptr *data_buffer,
					MEMptr attr_buffer	));
extern	int VDSfind_attr_in_buffer 	
				__((MEMptr buffer,
					char *attr	));
extern	int VDSfind_col_in_buffer 	
				__((MEMptr buffer,
					char *attr	));
extern	int VDSadd_buffer_string 	
				__((char *buff_string,
					int *position,
					char *char_string	));

/* VDSdbparcat.c */
extern	long VDScreate_parametric_catalog 	
				__((MEMptr cat_data,
					MEMptr attr_list,
					MEMptr data_list,
					MEMptr value_list,
					MEMptr dyn_attr,
					MEMptr dyn_data,
					MEMptr dyn_list,
					char     *dyn_table 	));
extern	int VDScreate_dynamic_table 	
				__((long user_id,
					char *pdc_tbl,
					MEMptr dynamic_attr,
					MEMptr dynamic_data,
					MEMptr dynamic_list	));
extern	int VDSstore_classification 	
				__((MEMptr class_path,
					char *dyn_table	));
extern	int VDSstore_parameters 	
				__((MEMptr parm_bufr	));
extern	int VDSmap_catalog_macro 	
				__((MEMptr macro_bufr	));

/* VDSdbpath.c */
extern	int VDBproductpath 	__((char product_name[],
					char product_path[]	));

/* VDSdbpdm.c */
extern	int VDScreate_catalogs 	__((void 	));


/* VDSdbreadris.c */
extern	int VDSreadrisfile 	__((char *file_name	));



/* VDSdbstring.c */
extern	int VDSsplit_line 	__((char string[],
					struct MFlin *line	));
extern	int VDSconvert 		__((char string[]	));
extern	int VDSdecrypt_string 	__((char *input,
					char *key,
					char *column,
					char *format,
					int *p_num	));
extern	int VDSextract_cofilename 	
				__((char input[],
					char path[],
					char name[]	));
extern	char *VDlogname		__(( void		));
extern	long VDBpadstr 		__((char *str,
					int maxlen,
					char pc	));
extern	void VDBdelTrailSpaces 	__((char *str	));
extern	void VDBdelLeadSpaces 	__((char *str	));

#endif
