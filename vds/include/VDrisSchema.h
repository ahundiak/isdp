/* =====================================================
 * TAPartItem
 *
 * ris> select column_name,ris_type_string,char_max_length from ris5columns where table_name = 'nfmstoragearea';
 */
typedef struct
{
  int  n_catalogno;  // Link to nfmcatalogs
  int  n_cisano;
  char n_co;
  char n_copy;
  char n_filename[240+1];
  int  n_filenum;    // Link to file table
  int  n_fileversion;
  int  n_itemno;     // Link to part table
  char n_mountpoint[80+1];
  char n_nfs;
  int  n_ref;
  int  n_sano;
} TASaFileItem;

typedef struct
{
  int  n_itemno;             // Link to file table,
  char n_itemname[15+1];     // Part Name
  char n_itemrev [15+1];     // Part Rev

  int  n_catalogno;
  char n_catalogname[20+1];

  char n_itemlock;
  int  n_stateno;             // State, workflow table
  char n_status[2+1];
  char n_updatedate[32];
  char n_updater[14+1];

  char n_cifilename[14+1];
  int  n_cifilesize;
  int  n_cisano;
  char n_ciuser[14+1];
  char n_cidate[32];

  int  n_colevel;
  int  n_cosano;
  char n_cofilename[14+1];
  char n_couser    [14+1];
  char n_codate    [32];

  int  n_conodeno;
  char n_conodename[30+1];
  char n_conodepath[80+1];
  char n_conodeuser[14+1];

  char ippd_team[9+1];
  char lpd17,lpd18,lpd19,lpd20,lpd21,lpd22,lpd23,lpd24,lpd25,lpd26,lpd27,lpd28;
  int  n_aclno;             // ACL table
  char n_archivestate;
  char n_creationdate[32];
  char n_creator[14+1];
  char n_iconname[40+1];
  char n_itemdesc[40+1];
  char n_lgfiletype[40+1];
  char n_pendingflag[2+1];
  int  n_prevstateno;
  char n_setindicator;
  int  n_versionlimit;
  char p_explode;
  char p_incpartrpt;
  int  p_maxlevel;
  char p_mrpbomuom[10+1];
  char p_mrpeffectdate[8+1];
  char p_mrpfieldupd[20+1];
  char p_mrpinvuom[10+1];
  char p_mrppart;
  char p_mrpstruct;
  char p_parttype;
} TAPartItem;

typedef struct
{
  int  n_archiveno;
  char n_cidate[32];
  char n_cifilename[14+1];
  int  n_cifilesize;
  int  n_cisano;
  char n_ciuser   [14+1];
  char n_cocomment[40+1];
  char n_codate[32];
  char n_cofilename[14+1];
  char n_convertind[10+1];
  int  n_cosano;
  char n_couser[14+1];
  char n_fileclass;
  char n_fileco;
  int  n_fileno;
  int  n_filenum;         // Link to nfmsafiles
  char n_filetype[5+1];
  int  n_fileversion;
  int  n_itemnum;         // Link to part table
  char n_restoreflag[2+1];
  char p_filedesc  [40+1];
} TAFileItem;

typedef struct
{
  char n_application[3+1];
  int  n_catalogno;
  char n_emailaddr[60+1];
  char n_group[20+1];
  int  n_itemno;
  char n_passwd[50+1];
  int  n_projectno;
  int  n_sano;
  int  n_searchno;
  int  n_setcatno;
  int  n_setitemno;
  int  n_sortno;
  char n_userdesc[40+1];
  char n_username[14+1];
  int  n_userno;
} TAUserItem;

typedef struct
{
  int  n_catalogno;
  char n_catalogname[20+1];
  char n_catalogdesc[40+1];

  int  n_aclno;
  int  n_archiveno;
  char n_archivestate;
  char n_creationdate[32];
  char n_creator[14+1];
  char n_identifier[20+1];
  char n_pendingflag[2+1];
  int  n_stateno;
  char n_type[3+1];
  char n_updatedate[32];
  char n_updater[14+1];
} TACatalogItem;

typedef struct
{
  char n_majority[2+1];
  int  n_seqno;
  int  n_signoffs;
  char n_statedesc[40+1];
  char n_statename[40+1];
  int  n_stateno;
  int  n_workflowno;
  char n_transfrom;
  char n_transto;
} TAStateItem;

typedef struct
{
  char n_aclname[20+1];
  int  n_aclno;      // Catalog belongs to one acl, Part belongs to one acl
  char n_complete;
  int  n_projectno;
  int  n_workflowno; // ACL belongs to one workflow
} TAAclItem;

typedef struct
{
  char cm_wf_enabled;
  int  n_aclno;
  int  n_stateno;
  char n_workflowdesc[40+1];
  char n_workflowname[20+1];
  int  n_workflowno;
  char n_workflowtype;
} TAWorkflowItem;

typedef struct
{
  int  n_sano;
  char n_pathname[80+1];
  char n_username[14+1];
  char n_passwd  [50+1];
  
  int  n_nodeno;
  char n_nodename[30+1];

  char n_compress;
  char n_devicetype[2+1];
  char n_nfs;
  int  n_owner;
  char n_partition[3+1];
  char n_plattername[16+1];
  char n_saname[14+1];
  char n_type;
} TAStorageAreaItem;

typedef struct
{
  int  n_nodeno;
  char n_nodename[30+1];
  char n_nodedesc[40+1];
  
  char n_nfs;
  char n_machid[10+1];
  char n_opsys [10+1];

  char n_tcpip;
  char n_xns;

  char n_decnet,n_netware;
} TANodeItem;
