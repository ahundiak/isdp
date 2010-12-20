#ifndef NFMstruct_h
#define NFMstruct_h

#include "MEMstruct.h"
#include "NFMschema.h"

struct attr_info
{
  char attr_name[80];
  char attr_dtype[80];
  int  data_count;
  char *data_value;
};

struct cat_info
{
  struct attr_info n_itemno;
  struct attr_info n_itemname;
  struct attr_info n_itemrev;
  struct attr_info n_archivestate;
  struct attr_info n_coout;
  struct attr_info n_itemlock;
  struct attr_info n_versionlimit;
  struct attr_info n_pendingflag;   
};

struct fcat_info
{
  struct attr_info n_itemnum;
  struct attr_info n_fileclass;
  struct attr_info n_fileversion;
  struct attr_info n_cifilename;
};

struct NFMitem_info
{
  struct cat_info cat_item;
  struct fcat_info fcat_item;
  long   table_no, ftable_no;
  char cat_name[NFM_CATALOGNAME+1];

};                        /* this is a structure used during the check_in cmd */


struct sto_area_info
{
  int sano;
  char nodename[31], username[15], passwd[51], pathname[51];
  char devicetype[3], machid[11], opsys[11], tcpip[2], xns[2], decnet[2];
};                 /* this is a structure used for check_in FROM storage area */

struct NFMglobal_st
{
  char date_format [50] ;              /* AMERICAN, ITALIAN, SPANISH,
					  FRENCH, GERMAN, BRITISH,
                                          ANSI, USER_DEFINED */
  char time_format [50] ;              /* 24HR, 12HR */
//char NFMversion [NFM_ITEMDESC+1] ;  /* version of environment */
  char NFMversion [44] ;              /* version of environment */
  long NFMuserid ;                    /* userno << 16 | pid */
  long NFMuserno ;                    /* userno */
  char NFMusername [NFM_USERNAME+1] ; /* username */
  char NFMpasswd[60];                 /* decrypted users password */
  long administrator ;                /* 1 if I/NFM administrator else 0 */
  char application [NFM_APPLICATION +1] ; /* NFM, PDM, etc */
  int  fs_debug_on;
  char fs_debug_file[80];
  char NFMsch_name[80];			/* Encrypted schema name */
  char NFMsch_passwd[80];		/* Encrypted schema password */
  long default_wa_no ;                  /* Default Working Area Number */
  long load_item_file; 
  char client_type [10] ;               /* Valid Client type :
                                           blank (default) = UNIX
                                           PC
                                         */
  char environment_name [15];          /* can not be greater than 9 (nfme_) */
  long query_rows ;                    /* Block queries */
  long PUBLIC_userno ;                 /* userno for PUBLIC */
  long do_not_register_PDM; 	       /* 0 to register PDM assem. with DMMGR,
					* else 1 */
};

struct child_info
{
  long level;
  long citno;
  long ccatalogno;          /* child catalog number */
  char cat_name[61];
  long fcat_no;
  long citemno;             /* child item number */
  char type[2];            /* type of the child (P/S) */
  long consecutive;
  struct child_info *next;  /* point to the next child */
};

struct sto_info
{
  struct sto_area_info info;
  struct sto_info *next;
};

struct attr_info1
{
  long table_no, ftable_no;
  char table_name[20];
  char itemno_n[61];	 	char itemno_d[61];
  char itemname_n[61];	 	char itemname_d[61];
  char itemrev_n[61];	 	char itemrev_d[61];
  char archivestate_n[61]; 	char archivestate_d[61];
  char itemlock_n[61]; 		char itemlock_d[61];
  char versionlimit_n[61]; 	char versionlimit_d[61];


  char itemnum_n[61]; 		char itemnum_d[61];
  char fileclass_n[61]; 	char fileclass_d[61];
  char fileversion_n[61]; 	char fileversion_d[61];
  char cifilename_n[61]; 	char cifilename_d[61];
  struct attr_info1 *next;
};

struct set_info1
{
  char itemno_v[10];
  char itemname_v[61];
  char itemrev_v[61];
  char coout_v[3];
  char archivestate_v[2];
  char itemlock_v[2];
  char versionlimit_v[10];
  char fileclass_v[2];
  char fileversion_v[10];
  char cifilename_v[20];
  long table_no;
  long citno;
  char type[2];
  long level;
  long consecutive;
  struct set_info1 *next;
};

struct file_info_struct
{
  int n_itemno ;
  int n_filenum ;
  int n_fileversion ;
  int n_citno ;
  char n_cofilename [NFM_COFILENAME] ;
  char ms_action [2] ;      /* A -add D -drop */
  char lfm_action [2];      /* U -update I -insert */
  char file_action [2];     
  char filetype[NFM_FILETYPE+1];/* 6/2/94, added to handle raster file */
  /*char mem_type[NFM_TYPE+1];  6/1/94, added to handle raster file as a 
                                        primary member, possible values: 
                                        P -- primary member, 
                                        S -- secondary member*/
  struct file_info_struct *ptr ;
  struct NFMset_member *member_ptr ;
} ;

extern MEMptr NFMset_msg;  /*  Set messages buffer */

typedef struct unit_info1
{
  int num_of_rows, num_of_cols ;
  char **data ;
} UNIT_INFO ;
#endif
