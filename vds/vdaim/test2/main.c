#include <stdio.h>
#include <string.h>

#include <glib.h>
#include <gio/gio.h>

extern test_ftp();

#define POSTMAN_MAGICNO 1234567876  /* good buffer identifier prefix */
#define FULL_BUFFER              1  /* needs packing buffer on CLIX */
#define LEAN_BUFFER              2  /* no mfail etc; saves packing space */

#define INIT_REQUEST           100  /* first dummy initialize request from clix */
#define SYNC_REQUEST           101  /* syncing packet while reading/writing */
#define CHUNKSIZE_INFO         102  /* chunksize information, back from server */

/* ------ Header Packet Structure -------- */
typedef struct  header
{
  int magicno;		/* POSTMAN MAGIC NUM - check for valid packets */
  int packettype; /* packet type - see #define constants */
  int bytecount;  /* bytecount of data buffer to follow separately */
} THeader;	      /* header packet is sent by itself, then data */

/* ------ Data Packet Structures -------- */
typedef union  pmdatabuf
{
  union fullbufTag  /* postman buffer format */
  {
    struct pmebufTag  /* dm2 communication */
    {
		  int  dstat;		  /* method function return code */
      int  mfail;		  /* method return code via argument */
      char buf[1];		/* errmsg string (null-term), rest .. */
							        /* nonascii or null-terminated ascii data */
    } pmebuf;

	  struct	postmanTag /* only postman<->clix communication */
    {
		  int  request;	/* see #defines */
			int  info;		/* depends on request */
			char buf[1];  /* not used */
	  } postman;
  } fullbuf;

  union leanbufTag     /* lean buffer - no packing buffer needed */
  {
    struct pmebufTag2  /* DM2 request from CLIX */
    {
      char data[1];   /* nonascii or null-terminated ascii data */
    } pmebuf;
  } leanbuf;
} TPayload;


int main(int argc, char *argv)
{
  GSocketClient  *client;
  GIOStream      *conn;  // GSocketConnection
  GOutputStream  *connOut;
  GInputStream   *connInn;

  const gchar    *clientHostName;

  TPayload *payload;
  THeader   header;

  gchar    *buf;
  gssize    bufLen;
  gssize    count;

  // For gobject
  g_type_init();

  test_ftp();
  if (1) return 0;

  // Connect
  client = g_socket_client_new();
  conn = (GIOStream *)g_socket_client_connect_to_host(client,"avd_aim_test",9083,NULL,NULL);
  g_assert(conn);
  g_tcp_connection_set_graceful_disconnect((GTcpConnection*)conn,TRUE);
  
  // Ask server for chunk info
  clientHostName = g_get_host_name();
  
  bufLen = sizeof(TPayload) + strlen(clientHostName);

  header.magicno    = POSTMAN_MAGICNO;
  header.packettype = FULL_BUFFER;
  header.bytecount  = bufLen;

  buf = g_malloc0(bufLen + 1000);
  payload = (TPayload *)buf;
  payload->fullbuf.postman.request = INIT_REQUEST;

  memcpy(buf+sizeof(TPayload),clientHostName,strlen(clientHostName));

  connOut = g_io_stream_get_output_stream(conn);
  connInn = g_io_stream_get_input_stream (conn);

  count = g_output_stream_write(connOut,&header,sizeof(THeader),NULL,NULL);
  g_assert_cmpint(sizeof(THeader),==,count);

  count = g_output_stream_write(connOut,buf,bufLen,NULL,NULL);
  g_assert_cmpint(bufLen,==,count);

  count = g_input_stream_read(connInn,&header,sizeof(THeader),NULL,NULL);
  g_assert_cmpint(sizeof(THeader),==,count);

  g_assert_cmpint(header.magicno,   ==, POSTMAN_MAGICNO);
  g_assert_cmpint(header.packettype,==, FULL_BUFFER);
  g_assert_cmpint(header.bytecount, ==, 9);

  bufLen = header.bytecount;

  count = g_input_stream_read(connInn,buf,bufLen,NULL,NULL);
  g_assert_cmpint(bufLen,==,count);

  g_assert_cmpint(payload->fullbuf.postman.request,==,CHUNKSIZE_INFO);
  g_assert_cmpint(payload->fullbuf.postman.info,   ==,99995);

  // Not just sure if this is just a hack or not but the serve sends a second message with status code
  count = g_input_stream_read(connInn,&header,sizeof(THeader),NULL,NULL);
  g_assert_cmpint(sizeof(THeader),==,count);

  count = g_input_stream_read(connInn,buf,bufLen,NULL,NULL);
  g_assert_cmpint(bufLen,==,count);
  
  g_assert_cmpint(payload->fullbuf.pmebuf.dstat,==,0);
  g_assert_cmpint(payload->fullbuf.pmebuf.mfail,==,0);

  // Try to read again, it will block, need to figure out how to break out
  // count = g_input_stream_read(connInn,&header,sizeof(THeader),NULL,NULL);

  // Close down
  g_io_stream_close(conn,NULL,NULL);

  // Free it
  g_object_unref(conn);
  g_object_unref(client);

}
