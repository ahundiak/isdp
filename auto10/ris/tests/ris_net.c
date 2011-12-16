#include "risx.h"
#include <glib-object.h>
#include <gio/gio.h>

static GSocketClient  *client = NULL;
static GIOStream      *conn;  // GSocketConnection
static GOutputStream  *connOut;
static GInputStream   *connInn;

typedef struct ris_ora_info
{
  char  osuser[32];
  char  ospass[38];
  char  dir[241];
} ris_ora_info;

typedef struct ris_ifx_info
{
  char  dir[241];
  char  sqlexec[241];
  char  dbtemp[241];
  char  tbconfig[241];
} ris_ifx_info;

typedef struct ris_db_info
{
  unsigned short  dbid;
  unsigned char   dtype;
  char            dbname[241];
  struct
  {
    unsigned char   protocol;
    char            netaddr[29];
  } pathways[4];
  union
  {
    ris_ifx_info ifx;
    ris_ora_info ora;
  } info;
  unsigned char       ostype;
  char                pad[3];
  struct ris_db_info *next;
} ris_db_info;

typedef struct ris_sch_intern_info
{
  char            schname  [32];
  char            schowner [32];
  char            passwd   [38];
  char            login    [32];
  char            dictowner[32];
  unsigned short  schtype;
  unsigned short  dbid;
  short           major;
  short           feature;
  char            pad[2];
  struct  ris_sch_intern_info *next;
} ris_sch_intern_info;

typedef struct ris_clisrv_buf
{
  ris_clisrv_header hdr;

	union
	{
    struct ris_clisrv_buf_get_tab
    {
      char tabuser[RIS_MAX_ID_SIZE];      /* table owner */
      char tabname[RIS_MAX_ID_SIZE];      /* table name */
    } get_tab;

    // Based on snoop
    struct ris_clisrv_buf_get_tabx
    {
      guint    max_rows;
      guint    max_buf_size;
      guint    debug;
      guchar   maj;
      guchar   min;
      guchar   rel;
      guchar   lang;
      char schname[RIS_MAX_ID_SIZE_16];
      char tabname[RIS_MAX_ID_SIZE_16];
      char tabuser[RIS_MAX_ID_SIZE_16];
    } get_tabx;

    struct ris_clisrv_buf_schema_db
    {
      /************* INIT ******/
      guint    max_rows;
      guint    max_buf_size;
      guint    debug;
      guchar   maj;
      guchar   min;
      guchar   rel;
      guchar   lang;

      /**************************/
      ris_sch_intern_info schema;         /* schema info */
      ris_db_info         db;             /* db info */
      gchar               schpass  [RIS_MAX_PASSWD_SIZE];
      gchar               newpasswd[RIS_MAX_PASSWD_SIZE]; /* for db2 */
      guchar              autocommit_flag;/* autocommit ON/OFF */
      guchar              blankstrip_flag;/* blankstrip ON/OFF */
      guchar              pad[2];
    } schema_db;
  } buf;
} ris_clisrv_buf;

typedef struct ris_srvcli_buf
{
  ris_srvcli_header hdr;
	union
	{
    struct ris_srvcli_buf_open_schema
    {
      int     pid;
      char    warning;
      char    xns_addr [RIS_MAX_NODE_SIZE];
      char    tcp_addr [RIS_MAX_NODE_SIZE];
      char    dnp_addr [RIS_MAX_NODE_SIZE];
      char    lu62_addr[RIS_MAX_NODE_SIZE];
      char    schpass  [RIS_MAX_PASSWD_SIZE];
      /* DB_user for login */
      char    dict_dbusr  [RIS_MAX_ID_SIZE];
      char    schown_dbusr[RIS_MAX_ID_SIZE];
      char    login_dbusr [RIS_MAX_ID_SIZE];
      char    privilege;      /*  version 5--for returning privilege */
    } open_schema;

    struct ris_srvcli_buf_get_tab
    {
      guint   count;          /* # of attr structures */
      gint    tabid;
      gchar   tabname [32];
      gchar   tabowner[32];      /* table owner */
      guchar  pad[16];        /* future usage , 8 byte aligned */
      guchar  data[1];
    } get_tab;
	} buf;
} ris_srvcli_buf;

int ris_net_open_schema()
{
  ris_clisrv_buf send;
  ris_srvcli_buf recv;

  gint len;

  if (!client) return RIS_E_FAIL;

  memset(&send,0,sizeof(send));
  
  send.hdr.len = sizeof(send.hdr) + sizeof(send.buf.schema_db);
  g_assert_cmpint(1624,==,send.hdr.len);

  send.hdr.opcode = RIS_OPEN_SCHEMA_CODE;

  g_assert_cmpint(1624,==,send.hdr.len);

  send.buf.schema_db.max_rows     = 100;   // params
  send.buf.schema_db.max_buf_size = 66552; // params
  send.buf.schema_db.debug        = 0;
  send.buf.schema_db.maj          = 0x05;
  send.buf.schema_db.min          = 0x04;
  send.buf.schema_db.rel          = 0x00;
  send.buf.schema_db.lang         = 0x00;

  strcpy(send.buf.schema_db.schema.schname,  "isdptst");
  strcpy(send.buf.schema_db.schema.schowner, "NFMADMIN");
  strcpy(send.buf.schema_db.schema.passwd,   "h/XH7vJl-hXGU(|=:*uwXNmu)eT>B\":LK(x[;"); // schemas
  strcpy(send.buf.schema_db.schema.login,    "NFMADMIN");
  strcpy(send.buf.schema_db.schema.dictowner,"NFMADMIN");

  send.buf.schema_db.schema.schtype = 0;
  send.buf.schema_db.schema.dbid    = 4; // schemas
  send.buf.schema_db.schema.major   = 0xFFFF;
  send.buf.schema_db.schema.feature = 0xFFFF;
  send.buf.schema_db.schema.pad[0]  = 0x00;
  send.buf.schema_db.schema.pad[1]  = 0x00;

  send.buf.schema_db.db.dbid        =  4;  // schemas
  send.buf.schema_db.db.dtype       = 'O'; // schemas
  strcpy(send.buf.schema_db.db.dbname,"@isdptest");
  
  send.buf.schema_db.db.pathways[0].protocol = 'T'; // schemas
  strcpy(send.buf.schema_db.db.pathways[0].netaddr,"172.31.16.158");

  strcpy(send.buf.schema_db.db.info.ora.osuser,"nfmadmin");
  strcpy(send.buf.schema_db.db.info.ora.ospass,"~p.s?(<*m`Gq;Z\\AL3S]FH-7*|R(1gD3n@(&l");
  strcpy(send.buf.schema_db.db.info.ora.dir,   "DBMS_NET");

  send.buf.schema_db.db.ostype       = 'N'; // schemas

  ris_net_write(&send,send.hdr.len,NULL);
  
  len = sizeof(recv.hdr) + sizeof(recv.buf.open_schema);
  g_assert_cmpint(264,==,len);

  ris_net_read(&len,4,NULL);
  g_assert_cmpint(268, ==, len);

  ris_net_read(&recv,len-4,NULL);

//g_assert_cmpint(recv.buf.open_schema.pid,         ==, 1581280); // Changes eash login
  g_assert_cmpint(recv.buf.open_schema.warning,     ==, 0x00);
  g_assert_cmpstr(recv.buf.open_schema.tcp_addr,    ==, "172.31.16.158");
  g_assert_cmpstr(recv.buf.open_schema.dict_dbusr,  ==, "NFMADMIN");
  g_assert_cmpstr(recv.buf.open_schema.schown_dbusr,==, "NFMADMIN");
  g_assert_cmpstr(recv.buf.open_schema.login_dbusr, ==, "NFMADMIN");
  g_assert_cmpint(recv.buf.open_schema.privilege,   ==, 'D');

  return RIS_SUCCESS;
}

int ris_net_get_table_info()
{
  ris_clisrv_buf  send;
  ris_srvcli_buf *recv = NULL;

  typedef struct
  {
    gchar colname [32];
    gchar colnamex[32];
    gchar pad[16];
  } Column;

  Column *columns;

  gint len;

  if (!client) return RIS_E_FAIL;

  memset(&send,0,sizeof(send));

  send.hdr.len = sizeof(send.hdr) + sizeof(send.buf.get_tabx);
  g_assert_cmpint(76,==,send.hdr.len);

  send.hdr.opcode = RIS_GET_TABLE_CODE;

  strcpy(send.buf.get_tabx.schname,"isdptst");
  strcpy(send.buf.get_tabx.tabname,"nfmcatalogs");
  strcpy(send.buf.get_tabx.tabuser,"NFMADMIN");

  ris_net_write(&send,send.hdr.len,NULL);
 
  ris_net_read(&len,4,NULL);
  g_assert_cmpint(1220, ==, len);
  len -= 4;

  recv = g_malloc0(len);
  ris_net_read(recv,len,NULL);

  g_assert_cmpint(14,           ==, recv->buf.get_tab.count);
  g_assert_cmpstr("NFMCATALOGS",==, recv->buf.get_tab.tabname );
  g_assert_cmpstr("NFMADMIN",   ==, recv->buf.get_tab.tabowner);

  columns = (Column*)&recv->buf.get_tab.data[0];

  g_assert_cmpstr("n_catalogno",==,columns[0].colname );
  g_assert_cmpstr("N_CATALOGNO",==,columns[0].colnamex);
  
  g_assert_cmpstr("n_catalogname",==,columns[1].colname);
  g_assert_cmpstr("n_creator", ==,columns[7].colname);

  g_free(recv);
  
  return RIS_SUCCESS;
  
}
int ris_net_check_arch()
{
  gint  bufLen;

  gchar buf[256];

  if (!client) return RIS_E_FAIL;

  // 0000 0005 4f05 0400
  buf[0] = 0x00;
  buf[1] = 0x00;
  buf[2] = 0x00;
  buf[3] = 0x05; // ???
  buf[4] = 0x4F; // Command
  buf[5] = 0x05; // Think RIS 5.4
  buf[6] = 0x04;
  buf[7] = 0x00;

  // No response expected, none gotten
  bufLen = 8;
  ris_net_write(buf,bufLen,NULL);

  // Think check the actual arch
  buf[0] = 0x09;
  buf[1] = 0x0C;
  bufLen = 2;
  ris_net_write(buf,bufLen,NULL);

  bufLen = 2;
  ris_net_read(buf,bufLen,NULL);

  g_assert_cmpint(0x09,==,buf[0]);
  g_assert_cmpint(0x0C,==,buf[1]);

  return RIS_SUCCESS;
}
/* ===============================================================
 * This basically asks a NT box, where the heck does the schema file live?
 * See riscli/file/filglob.c
 */
int ris_net_get_ris_server_path(char *path)
{
  gint  count;
  gint  bufLen;

  gchar buf[256];

  g_assert(path); *path = 0;
  
  if (!client) return RIS_E_FAIL;

  // Majic for now
  // 0000 0005 5a05 0400
  buf[0] = 0x00;
  buf[1] = 0x00;
  buf[2] = 0x00;
  buf[3] = 0x05; // MATCH_COMPATIBLE
  buf[4] = 0x5A; // Z
  buf[5] = 0x05; // RIS_version_maj
  buf[6] = 0x04; // RIS_version_min;
  buf[7] = 0x00;
  
  bufLen = 8;
  count = ris_net_write(buf,bufLen,NULL);
  g_assert_cmpint(bufLen,==,count);

  bufLen = 241;
  count = ris_net_read(buf,bufLen,NULL);
  g_assert_cmpint(bufLen,==,count);

  strcpy(path,buf);

  return RIS_SUCCESS;

}
int ris_net_connect()
{
  gchar server[] = "pink"; // avd_isdp_test

  if (client) return RIS_SUCCESS;

  client = g_socket_client_new();

  conn = (GIOStream *)g_socket_client_connect_to_host(client,server,180,NULL,NULL);
  g_assert(conn);

  g_tcp_connection_set_graceful_disconnect((GTcpConnection*)conn,TRUE);

  connOut = g_io_stream_get_output_stream(conn);
  connInn = g_io_stream_get_input_stream (conn);

  g_assert(connOut);
  g_assert(connInn);

  return RIS_SUCCESS;
}
int ris_net_disconnect()
{
  if (!client) return RIS_SUCCESS;

  g_assert(conn);

  g_io_stream_close(conn,NULL,NULL);

  // Free it
//g_object_unref(connInn); // Dos say do not free
//g_object_unref(connOut);
  
  g_object_unref(conn);
  g_object_unref(client);

  connInn = NULL;
  connOut = NULL;
  conn    = NULL;
  client  = NULL;

  return RIS_SUCCESS;
}
gint ris_net_read (gpointer buf, gint bufLen, GError **error)
{
  gint count;

  if (!client) return -1;
  g_assert(connInn);

  if (bufLen == 0) return 0;
  g_assert(buf);

  count = g_input_stream_read(connInn,buf,bufLen,NULL,error);
  g_assert_cmpint(bufLen,==,count);

  return count;
}
gint ris_net_write (gpointer buf, gint bufLen, GError **error)
{
  gint count;

  if (!client) return -1;
  g_assert(connOut);

  if (bufLen == 0) return 0;
  g_assert(buf);

  count = g_output_stream_write(connOut,buf,bufLen,NULL,error);
  g_assert_cmpint(bufLen,==,count);

  return count;
}
