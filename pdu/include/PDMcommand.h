/*  Workflow commands  */

#define PDM_VALIDATE_ACCESS        101
#define PDM_SET_TO_STATE           102
#define PDM_MAKE_TRANSITION	   103
#define PDM_SHOW_ACLS		   104
#define PDM_VALID_ACLS		   105
#define PDM_GET_STATE		   106
#define PDM_GET_TO_STATES	   107
#define PDM_MOVE_TO_STATE	   108
#define PDM_CATALOG_ACLS	   109

/*  User commands  */

#define PDM_USER_LOGIN             201
#define PDM_ADD_USER               202
#define PDM_MODIFY_USER            203
#define PDM_CHANGE_USER_PASSWORD   204
#define PDM_DELETE_USERS           205

/*  Attribute commands  */

#define PDM_GET_TABLE_ATTR         	301
#define PDM_GET_TABLE_DATA         	302
#define PDM_GET_TABLE_TEMPLATE     	303
#define PDM_DEF_CAT_USER_ATTR      	304
#define PDM_QUERY_TEMPLATE_INFO   	305
#define PDM_QUERY_TABLE_DEFINITION      306
#define PDM_GET_DYNAMIC_ATTR         	307
#define PDM_GET_DYNAMIC_BUFFER         	308
#define PDM_FAST_TABLE_DEFINITION       309
#define PDM_QUERY_ITEM_ATTR_INFO        310
#define PDM_GET_DYNAMIC_INFO          311

/*  Project and Catalog commands  */

#define PDM_CREATE_CATALOG         401
#define PDM_COPY_CATALOG           402
#define PDM_MODIFY_CATALOG         403
#define PDM_DELETE_CATALOG         404
#define PDM_SEARCH_ACROSS_CATS     405
#define PDM_DEF_CAT_SECURITY       406
#define PDM_VERIFY_CATALOG         407
#define PDM_VERIFY_PROJECT         408
#define PDM_CATALOG_LIST           409
#define PDM_PROJ_OF_CAT_LIST       410
#define PDM_CAT_OF_PROJ_LIST       411
#define PDM_LIST_OF_PROJ           412
#define PDM_LIST_OF_CAT            413


/*  Part commands  */

#define PDM_ADD_PART                  501
#define PDM_PREPARE_MODIFY_PART       502
#define PDM_MODIFY_PART               503
#define PDM_DELETE_PART               504
#define PDM_GET_PART                  505
#define PDM_VERIFY_PART               507
#define PDM_CANCEL_MODIFY_PART        508
#define PDM_QUERY_PART_TYPE           509
#define PDM_CHANGE_PART_TYPE          510
#define PDM_CHECK_DELETE_PART         511
#define PDM_QUERY_PART_STATUS         512
#define PDM_PART_IN_PROJ              513
#define PDM_PART_FROM_DESC            514
#define PDM_CHECK_PARTNUM             515
#define PDM_GET_REVS                  516
#define PDM_GET_DESC                  517
#define PDM_VERIFY_PARTNUM            518
#define PDM_LIST_OF_PARTS             519
#define PDM_SEARCH_PARTS_IN_PROJECT   520
#define PDM_SEARCH_PARTS_IN_PROJECT2  521
#define PDM_SEARCH_PARTS_IN_CATALOG   522
#define PDM_PARTS_IN_CATALOG          523
#define PDM_GET_FILENAMES             524
#define PDM_GET_EMS_FILES             525
#define PDM_GET_PT_DESC               526
#define PDM_DELETE_FILE_PART          527
#define PDM_GET_CATNO_PARTNO          528

/*  Bill of Material commands  */

#define PDM_UPDATE_BOM                 601
#define PDM_CREATE_BOM                 602
#define PDM_DEFINE_ASSEMBLY            603
#define PDM_DELETE_BOM                 604
#define PDM_LIST_ALL_BOMS              605
#define PDM_GET_BOM_CONTENT_USER       606
#define PDM_DELETE_BOM_CONTENT         607
#define PDM_LIST_BOM_ACTIVE            608
#define PDM_LIST_BOM_REVIEW            609
#define PDM_MODIFY_BOM_CONTENT         610
#define PDM_GET_BOM_CONTENT            611
#define PDM_MODIFY_BOM_MAPPING         612
#define PDM_GET_BOM_MAPPING            613
#define PDM_GET_BOM_MAP_BUFFER         614
#define PDM_GET_ASSEMBLY               615
#define PDM_FIND_BOMNAME               616
#define PDM_SHOW_BOMS	               617
#define PDM_GEN_BOM_PARTS_LIST         618
#define PDM_GEN_SUMMARY_BOM	       619
#define PDM_WHERE_USED_IMM	       620
#define PDM_WHERE_USED_TOP	       621

/*  File transfer commands  */

#define PDM_CHECKIN_PART           701
#define PDM_CHECKOUT_PART          702
#define PDM_COPY_PART              703
#define PDM_COPY_FILE              704
#define PDM_COPY_MACRO_FILE        706 
#define PDM_COPY_ATTACH            705
#define PDM_CANCEL_CHECKOUT_PART   707
#define PDM_DETACH_PART            709
#define PDM_DELETE_FILES           710

/*  Format commands  */

#define PDM_DEF_CAT_LIST_FORMAT    801
#define PDM_GET_CAT_LIST_FORMAT    802
#define PDM_DEF_BOM_LIST_FORMAT    803
#define PDM_GET_BOM_LIST_FORMAT    804
#define PDM_DEF_BOM_PRINT_FORMAT   805
#define PDM_GET_BOM_PRINT_FORMAT   806
#define PDM_CHECK_CAT_DATE         807
#define PDM_CHECK_BOM_DATE         808

/* Reports Commands */

#define PDM_CREATE_REPORT_BUFFERS  820
#define PDM_VALIDATE_REPORT_NAME   821
#define PDM_READ_REPORT_FORMAT	   822
#define PDM_ADD_REPORT   	   823
#define PDM_ADD_CRITERIA	   824
#define PDM_REPORT_FROM_BUFRS0	   825
#define PDM_DISPLAY_LOC	           826
#define PDM_DISPLAY_PARTS	   827
#define PDM_REPORT_FROM_FILE0	   828
#define PDM_REPORT_FROM_FILE1	   829
#define PDM_REPORT_FROM_FILE2	   830
#define PDM_LIST_CATALOGS          831
#define PDM_LIST_USERS             832
#define PDM_READ_CRITERIA	   833
#define PDM_LIST_REPORTS	   834
#define PDM_LIST_PARTS		   835
#define PDM_DELETE_REPORT	   836
#define PDM_LIST_QUERYS	           837
#define PDM_VALIDATE_QUERYS         838

/*  MRP commands  */

#define PDM_SET_MRP_PART           901
#define PDM_SET_MRP_STRUCT         902

/*  Part approval commands  */

#define PDM_USER_APPROVED         1001
#define PDM_ADMIN_APPROVED        1002
#define PDM_ADMIN_REJECTED        1003

/*  User environment commands  */

#define PDM_EXPORT_ENVIRON        1101
#define PDM_IMPORT_ENVIRON        1102

/*  Misc. commands  */

#define PDM_DEBUG_ON_OFF          	1201
#define PDM_SHOW_SAVED_VIEWS      	1202
#define PDM_SHOW_PARTS		      	1203
#define PDM_SHOW_CATALOGS	      	1204
#define PDM_GET_CHILDREN          	1205
#define PDM_TERMINATE             	1206
#define PDM_VERIFY_INIT           	1207
#define PDM_PREPARE_ITEM_CHECKIN  	1208
#define PDM_PREPARE_ITEM_CHECKOUT 	1209
#define PDM_COMPLETE_ITEM_CHECKIN 	1210
#define PDM_COMPLETE_ITEM_CHECKOUT 	1211
#define PDM_CANCEL_ITEM_CHECKIN 	1212
#define PDM_CANCEL_ITEM_CHECKOUT 	1213
#define PDM_QUERY_TABLE			1214
#define PDM_DROP_TABLE			1215
#define PDM_VERIFY_VIEW  	        1216
#define PDM_CHECK_ITEM  	        1217
#define PDM_GENERATE_FILENAME           1218  
#define PDM_QUERY_DISTINCT_TABLE	1219
#define PDM_GET_SAVED_VIEWS      	1220

/* Flag Commands */

#define PDM_FLAG_ARCHIVE          1301
#define PDM_FLAG_BACKUP           1302
#define PDM_FLAG_DELETE           1303
#define PDM_FLAG_RESTORE          1304
#define PDM_UNFLAG_ARCHIVE	  1305
#define PDM_UNFLAG_BACKUP         1306
#define PDM_UNFLAG_DELETE         1307
#define PDM_UNFLAG_RESTORE        1308

/* Parametric Commands  */

#define PDM_GET_FAMILIES		  1401
#define PDM_ADD_FAMILY 			  1402
#define PDM_DELETE_FAMILY 		  1403
#define PDM_CHECK_MACROS 		  1404
#define PDM_GET_PPART_DATA 		  1405
#define PDM_GET_MACRO_FORMAT     	  1406

/* Projects Commands  */

#define PDM_SHOW_PROJECTS        1501
#define PDM_ADD_PART_TO_PROJECT  1502

/* File Mgr Commands  */

#define PDM_LIST_LOCAL_FILES	          1601
#define PDM_DELETE_LOCAL_FILES   	  1602
#define PDM_LIST_DELETE_LOCAL_FILES	  1603
#define PDM_LIST_CHKOUT_FILES	          1604
#define PDM_CHKIN_FILES_OF_USER	          1605
#define PDM_PREPARE_FILE_INFO             1606
#define PDM_ADD_FILE_BUFR               1607

/* Login commands */
#define PDM_LIST_SERVERS                1701
#define PDM_LIST_ENVS                   1702


/* Drawing Commands */
#define PDM_GET_DWG_ATTRS               1801
#define PDM_VERIFY_DRAWING              1802
#define PDM_GET_DWG_CATALOGS            1803
#define PDM_ADD_DRAWING                 1804
#define PDM_DELETE_DRAWING              1805
#define PDM_MODIFY_DRAWING              1806
#define PDM_CREATE_DWG_CATALOG          1807
#define PDM_DELETE_DWG_CATALOG          1808
#define PDM_MODIFY_DWG_CATALOG          1809
#define PDM_VERIFY_DWG_CATALOG          1810
#define PDM_VERIFY_DWG_SHEET_FILE       1811
#define PDM_VERIFY_DWG_SEED_FILE        1812
#define PDM_GET_SHEET_NUMBERS           1813
#define PDM_GET_SHEET_FILENAMES         1814
#define PDM_GET_SEED_FILENAMES          1815
#define PDM_ADD_DWG_SHEET               1816
#define PDM_DELETE_DWG_SHEET            1817
#define PDM_ADD_SEED_FILES              1818
#define PDM_GET_DR_TABLE_TEMPLATE       1819
#define PDM_QUERY_DR_TABLE_DEFINITION   1820
#define PDM_FAST_DR_TABLE_DEFINITION    1821
#define PDM_QUERY_DR_TABLE              1822
#define PDM_DROP_DR_TABLE               1823
#define PDM_QUERY_DISTINCT_DR_TABLE     1824
#define PDM_QUERY_DR_TEMPLATE_INFO      1825
#define PDM_GET_DWG_DESC                1826
#define PDM_GET_DRAWING_REVS            1827
#define PDM_PREPARE_MODIFY_DWG          1828
#define PDM_CANCEL_MODIFY_DRAW          1829
#define PDM_QUERY_DRAW_STATUS           1830
#define PDM_CHECK_DRAWNUM               1831
#define PDM_DRAW_IN_PROJ                1832
#define PDM_DRAW_FROM_DESC              1833
#define PDM_PROJ_OF_DWG_CAT_LIST        1834
#define PDM_LIST_OF_DRAWINGS            1835
#define PDM_SEARCH_DRAWINGS_IN_PROJECT  1836
#define PDM_SEARCH_DRAWINGS_IN_CATALOG  1837
#define PDM_CHECK_DELETE_DRAW           1838
#define PDM_DRAWINGS_IN_CATALOG         1839
