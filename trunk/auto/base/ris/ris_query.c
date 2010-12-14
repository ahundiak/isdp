#include "risx.h"

/* RIS_PREP_EXEC_CODE */
/* RIS_PREP_EXEC_DEFERRED_CODE */
typedef struct ris_clisrv_buf_pe
{
  guint  in_data;		/* offset to input data */
  guint  in_sqlvar;	/* offset to input sqlvars */
  guint  query;			/* offset to guery string */
  guint  in_count;	/* # of input sqlvars */
  guint  query_len;	/* length of query string */
  guchar stmt_type;	/* statement type  */
  guchar pad[11];		/* make sure data starts on 32nd byte */
	gchar  data[1];
} ris_clisrv_buf_pe;

int ris_query(gchar *sql)
{
  typedef struct
  {
    ris_clisrv_header hdr;
    ris_clisrv_buf_pe buf;
  } Send;

  Send *send = NULL;

  gint   len;
  gchar *recv;

  len  = sizeof(Send) + strlen(sql) + 1;
  send = g_malloc0(len);

  send->hdr.len = len;
  send->hdr.opcode = RIS_PREP_EXEC_CODE;

  send->buf.in_data    =  0;
  send->buf.in_sqlvar  =  0;
  send->buf.query      =  0;
  send->buf.in_count   =  0;
  send->buf.query_len  =  strlen(sql);
  send->buf.stmt_type  =  0x1A; //  26

  strcpy(send->buf.data,sql);
  
  ris_net_write(send,len,NULL);

  // Not sure if need this or not
  ris_net_read(&len,4,NULL);
  len -= 4;
  recv = g_malloc(len);
  ris_net_read(recv,len,NULL);
  g_free(recv);
  
  ris_query_fetch();

  // Done
  g_free(send);
  return RIS_SUCCESS;
}
/* ===============================================================
 * Fetch some rows
 */
typedef struct ris_clisrv_buf_fetch
{
  guint  out_data;    /* offset to info of blob struct in data */
  guint  file_names;  /* offset to output file_names in data */
  guint  row_count;   /* number of rows expected */
  gshort blob_count;  /* num of blob columns involved  */
  gshort old_stmt_id; /* old statement identifier */
	guint  dbms;			  /* dbms info */
  gchar  pad[12];
  gchar  data[1];
} ris_clisrv_buf_fetch;

int ris_query_fetch()
{
  typedef struct
  {
    ris_clisrv_header    hdr;
    ris_clisrv_buf_fetch buf;
  } Send;

  Send *send = NULL;

  gint  len;
  gchar *recv = NULL;

  len  = sizeof(Send);
  g_assert_cmpint(48,==,len); // Should it be 44?
  
  send = g_malloc0(len);

  send->hdr.len    = len-4;
  send->hdr.opcode = RIS_FETCH_BUF_CODE;
  send->buf.row_count = 0x64;
  send->buf.dbms = 0x3DB7B0;  // Came back from original query
  send->buf.dbms = 0x3DB6C8;  // Came back from original query
  strcpy(send->buf.pad,"PAD   TWELVE");
  strcpy(send->buf.pad,"no,n_catalog");

  ris_net_write(send,len-4,NULL);

  ris_net_read(&len,4,NULL);
  len-= 4;
  recv = g_malloc(len);
  ris_net_read(recv,len,NULL);

  g_free(recv);
  
  g_free(send);
}
/* -------------------------------------------------------------
 * Internally parsed query
 */
/* RIS_PREP_DESC_DECL_OPEN_CODE */
typedef struct ris_clisrv_buf_pddo
{
  guint  in_data;    /* offset to input data */
  guint  in_sqlvar;  /* offset to input sqlvars */
  guint  out_sqlvar; /* offset to output sqlvars */
  guint  query;			 /* offset to query string */
  guint  in_count;   /* # of input sqlvars */
  guint  out_count;  /* # of output sqlvars */
  guint  query_len;  /* len of query string */
  guchar stmt_type;  /* statement type */
  gchar  pad[3];
  gchar  data[1];
} ris_clisrv_buf_pddo;

typedef struct ris_xxx
{
  gint   i1;
  gint   i2;
  gshort type;
  gshort typex;
  gint   data_len;

  gshort name_len1;
  gchar  name1[32];
//gchar  pad1 [ 6];

  gshort s20;
  gshort s21;
  gshort s22;
  gshort s23;

  gshort name_len2;
  gchar  name2[32];

  gchar  pad2 [20];
} ris_xxx;

int ris_query_desc(gchar *sql)
{
  typedef struct
  {
    ris_clisrv_header   hdr;
    ris_clisrv_buf_pddo buf;
  } Send;

  Send  *send = NULL;
  gchar *recv = NULL;

  ris_xxx *xxx;

  gint len;

  g_assert_cmpint( 48,==,sizeof(Send));
//g_assert_cmpint( 56,==,sizeof(ris_xxx));
  g_assert_cmpint(168,==,strlen(sql)+1);
  
  len  = sizeof(Send) + (2 * sizeof(ris_xxx)) + strlen(sql) + 1;
  //g_assert_cmpint(436,==,len);
  send = g_malloc0(len);

  send->hdr.len = len - 4;
  send->hdr.opcode = RIS_PREP_DESC_DECL_OPEN_CODE;

  send->buf.in_data    =  0;
  send->buf.in_sqlvar  =  0;
  send->buf.out_sqlvar =  0;
  send->buf.query      = 224; // 0xE0 Offset, 224
  send->buf.in_count   =  0;
  send->buf.out_count  =  2;
  send->buf.query_len  =  0xA8; // 168
  send->buf.stmt_type  =  0x1A; //  26

  strcpy(send->buf.pad,"PAD");

  xxx = (ris_xxx*)&send->buf.data[0];
  xxx->i1    = 0x04;
  xxx->i2    = 0;
  xxx->type  = 0x04;
  xxx->typex = 0x01;
  xxx->data_len = 4;

  xxx->name_len1 = 11;
  strcpy(xxx->name1,"n_catalogno");
//strcpy(xxx->pad1, "PADSIX");

  xxx->s20 = 0x00;
  xxx->s21 = 0x0A00;
  xxx->s22 = 0x00;
  xxx->s23 = 0x02;
  
  xxx->name_len2 = 11;
  strcpy(xxx->name2,"N_CATALOGNO");
//strcpy(xxx->pad2, "PADDING       TWENTY");

  xxx++;
  xxx->i1    = 0x0C;
  xxx->i2    = 0x08;
  xxx->type  = 0x01;
  xxx->typex = 0x01;
  xxx->data_len = 20; // 0x14

  xxx->name_len1 = 13;
  strcpy(xxx->name1,"n_catalogname");

  xxx->s20 = 0x00;
  xxx->s21 = 0x14;
  xxx->s22 = 0x00;
  xxx->s23 = 0x01;

  xxx->name_len2 = 13;
  strcpy(xxx->name2,"N_CATALOGNAME");
//strcpy(xxx->pad2, "PADDING       TWENTY");

  xxx++;
  strcpy((char*)xxx,sql);
  
  ris_net_write(send,len-4,NULL);

  ris_net_read(&len,4,NULL);
  len-= 4;
  recv = g_malloc(len);
  ris_net_read(recv,len,NULL);

  g_free(recv);

  ris_query_fetch();
  
  g_free(send);
  return RIS_SUCCESS;
}
void test_ris_query()
{
  int sts;

  gchar sql[] =
    "select all NFMADMIN.NFMCATALOGS.N_CATALOGNO, NFMADMIN.NFMCATALOGS.N_CATALOGNAME "
    "from NFMADMIN.NFMCATALOGS "
    "where NFMADMIN.NFMCATALOGS.N_CATALOGNAME = 'elec_eqpt_m_2252'";

  sts = ris_query(sql);
  g_assert_cmpint(RIS_SUCCESS,==,sts);
}
