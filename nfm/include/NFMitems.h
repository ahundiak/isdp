#ifndef NFMITEMS_H
#define NFMITEMS_H	/* MSSP - 3 Jan 94. Added #ifndef wrapper */

#include "NFMschema.h"
struct NFMset_member
{
  long level;
  long citno;
  char type[NFM_TYPE+1];
  long cat_no;
  char cat_name[NFM_CATALOGNAME+1];
  long item_no;
  char file_status[NFM_STATUS+1];
  char archive_state[NFM_ARCHIVESTATE+1];
  char item_name[NFM_ITEMNAME+1];
  char item_rev[NFM_ITEMREV+1];
  char item_desc[NFM_ITEMDESC+1];
  char lock[NFM_ITEMLOCK+1];
  long version_limit;
  char set_indicator[NFM_SETINDICATOR+1];
  char file_class[NFM_FILECLASS+1];
  char file_type[NFM_FILETYPE+1];
  char file_co[NFM_FILECO+1];
  long file_version;
  char pending_flag[NFM_PENDINGFLAG+1];
  long file_size;
  char ci_filename[NFM_CIFILENAME+1];
  long ci_sano;
  long co_sano;
  char co_filename[NFM_COFILENAME+1];
  long filenum;
  long move;
  long flag;  /* NFM_DROPPED_MEMBER */
  struct NFMset_member *next;
};

struct NFMsto_info
{
  long sano;
  char saname[NFM_SANAME+1];
  char nodename[NFM_NODENAME+1];
  char username[NFM_USERNAME+1];
  char passwd[NFM_PASSWD+1];
  char pathname[NFM_PATHNAME+1];
  char devicetype[NFM_DEVICETYPE+1];
  char plattername[NFM_PLATTERNAME+1];
  char partition[NFM_PARTITION+1];
  char nfs[NFM_NFS+1];
  char compress[NFM_COMPRESS+1];
  char machid[NFM_MACHID+1];
  char opsys[NFM_OPSYS+1];
  char tcpip[NFM_TCPIP+1];
  char xns[NFM_XNS+1];
  char decnet[NFM_DECNET+1];
  char netware[NFM_NETWARE+1];
  long option; /* added for DM/MANAGER, could be used if situation arises.  */
  struct NFMsto_info *next;
};

struct NFMlfm_file
{
  char sano[NFM_SANAME+1];
  char item_no[10], cat_no[10], cisano[10],
       filename[NFM_COFILENAME], filenum[10], fileversion[10];
  char type [NFM_TYPE+1];
  char nfs[NFM_NFS+1], mountpoint[NFM_MOUNTPOINT+1];
  char co[NFM_CO+1];
  char copy[NFM_COPY+1];
  long ref;
  long action;        /* add to the table || update the entry in the table */
};

struct NFMmembers /* used for recursive get members */
{
  long cat_no;
  long item_no;
  char type[NFM_TYPE+1];
};

struct NFMsort_cat
{
  long cat_no;
  struct NFMset_member begin;
  struct NFMsort_cat *next;
};

struct NFMactive
{
  long cat_no, fcat_no;
  long item_no;
  char cat_name[NFM_CATALOGNAME+1];
  char item_name[NFM_ITEMNAME+1];
  char item_rev[NFM_ITEMREV+1];
  char file_status[NFM_STATUS+1];
  char archive[NFM_ARCHIVESTATE+1];
  long cosano;
  long command;
};

// TODO: E_NONPORTABLE_BIT_FIELD_TYPE
struct NFMdegree
{
  int transaction:1;
  int status:1;
  int commit:1;
};

struct NFMbuf_format
{
  char attr_name[NFM_NAME+1];
  char data_type[NFM_DATATYPE+1];
};

struct NFMfile_entry
{
  long cisano, cosano;

/* 9/30/92 - KT - There is some conflict with the 'fileno' variable - 
                  changed to 'file_no'.
*/
  long file_no, filenum;
  char cidate[NFM_CIDATE+1], codate[NFM_CODATE+1];
  char cofilename[NFM_COFILENAME+1];
  char cifilename[NFM_COFILENAME+1];
  long fileversion;
  char nfs[NFM_NFS+1];
  long transfer_status;
  char *words;
  char *positions;
  struct NFMfile_entry *next_file;
};

struct NFMitem_entry
{
  char cat_name[NFM_CATALOGNAME+1];
  long cat_no;
  char item_name[NFM_ITEMNAME+1];
  char item_rev[NFM_ITEMREV+1];
  char status [NFM_STATUS+1]; /* n_status */
  long item_no;
  long files; /* number of files associated */
  char member_type[NFM_TYPE+1];
  struct NFMitem_entry *next_item;
  struct NFMfile_entry *next_file;
};
#endif
