#include "VDtypedefc.h"
#include "zlib.h"
#include "glib.h"
#include <sys/types.h>
#include <sys/stat.h>

/* -----------------------------------------------
 * Data structure for compressing a seris of buffers
 * into a single dynamically allocated buffer
 */
typedef struct {
  z_stream stream;
  char    *buf_final;
  char    *buf_work;
  int      len;
  int      inc;
  int      sts;
} TVDzlibDeflateInfo;

typedef struct {
  z_stream stream;
  char    *buf_final;
  char    *buf_work;
  int      len;
  int      inc;
  int      sts;
} TVDzlibStream;

#define VDZLIB_DEFAULT_BUF_IN 10

/* -----------------------------------------------
 * Gets things going to compress to a buffer
 */
void VDzlibInitDeflateInfo(TVDzlibDeflateInfo *info, int inc)
{
  // Reset
  memset(info,0,sizeof(TVDzlibDeflateInfo));
  
  // Get the stream going
  info->sts = deflateInit(&info->stream,Z_BEST_COMPRESSION);
  if (info->sts != Z_OK) {
    printf("*** Probblem initializing compression buffer\n");
    goto wrapup;
  }

  // Default inc value
  if (inc == 0) inc = VDZLIB_DEFAULT_BUF_IN;
  
  info->inc = inc;
  info->buf_work = g_malloc(inc);
  
  info->stream.next_out  = (Byte*)info->buf_work;
  info->stream.avail_out = inc;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Call this when done compressing, it does all the flushing
 * and shutting down
 */
void VDzlibDoneDeflateInfo(TVDzlibDeflateInfo *info)
{
  int sts;
  
  // Make sure everything is ok
  if (info->sts != Z_OK) goto wrapup;
  
  // Always flush
  sts = deflate(&info->stream,Z_FINISH);
  while(sts != Z_STREAM_END) {
    if (sts != Z_OK) {
      printf("*** Error closing compress buffer\n");
      info->sts = sts;
      goto wrapup;
    }

    // Xfer the data
    info->buf_final = g_realloc(info->buf_final,info->len+info->inc);
    memcpy(info->buf_final+info->len,info->buf_work,info->inc);
    info->len += info->inc;
    
    // Reset
    info->stream.next_out  = (Byte*)info->buf_work;
    info->stream.avail_out = info->inc;
    info->stream.total_out = 0;

    // Try again
    sts = deflate(&info->stream,Z_FINISH);
  }
  
  // Save the last little bit
  if (info->stream.total_out) {
    info->buf_final = g_realloc(info->buf_final,info->len+info->stream.total_out);
    memcpy(info->buf_final+info->len,info->buf_work,info->stream.total_out);
    info->len += info->stream.total_out;
  }

  // Close down
  info->sts = deflateEnd(&info->stream);
  g_free(info->buf_work);
  info->buf_work = NULL;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Use this to add data to the stream
 */
void VDzlibAppendDeflateInfo(TVDzlibDeflateInfo *info, char *data, int len)
{
  int sts;
  
  // Make sure everything is ok
  if (info->sts != Z_OK) goto wrapup;
  if (len == 0) goto wrapup;
  
  // Add the data
  info->stream.next_in  = (Byte*)data;
  info->stream.avail_in = len;
  
  // Compress it
  sts = deflate(&info->stream,Z_NO_FLUSH);
  while(sts == Z_OK) {

    // Have any output room left
    if (info->stream.avail_out) goto wrapup;
    
    // Xfer the data
    info->buf_final = g_realloc(info->buf_final,info->len + info->inc);
    memcpy(info->buf_final+info->len,info->buf_work,info->inc);
    info->len += info->inc;
    
    // Reset
    info->stream.next_out  = (Byte*)info->buf_work;
    info->stream.avail_out = info->inc;
    info->stream.total_out = 0;

    // Try again
    sts = deflate(&info->stream,Z_NO_FLUSH);
  }
  
  // Bad status
  info->sts = sts;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Use this to init the inflate process
 */
void VDzlibInitInflating(TVDzlibStream *s, char *deflated_data, int deflated_len, int work_len)
{
}
void VDzlibDoneInflating(TVDzlibStream *s)
{
}
void VDzlibInflateChar(TVDzlibStream *s, char *c)
{
}

/* ------------------------
 */
#define CHECK_ERR(err, msg) { \
    if (err != Z_OK) { \
        fprintf(stderr, "%s error: %d\n", msg, err); \
        exit(1); \
    } \
}

void test_large_deflate()
{
  z_stream c_stream; /* compression stream */
  int err;

  char *decomp_buf = "Compress this please and make is snappy";
  int   decomp_len;
  char    comp_buf[1000];
  int     comp_len = 1000;
    
  FILE *file;

  int i;
  char c;
  
  c_stream.zalloc = (alloc_func)0;
  c_stream.zfree = (free_func)0;
  c_stream.opaque = (voidpf)0;

  err = deflateInit(&c_stream, Z_DEFAULT_COMPRESSION);
  CHECK_ERR(err, "deflateInit");

  
  c_stream.next_out  = (Byte*)comp_buf;
  c_stream.avail_out = comp_len;

  decomp_len = strlen(decomp_buf);
  c_stream.next_in  = (Byte*)decomp_buf;
  c_stream.avail_in = decomp_len;

  err = deflate(&c_stream, Z_FINISH);
#if 0
  CHECK_ERR(err, "deflate");
  if (c_stream.avail_in != 0) {
    fprintf(stderr, "deflate not greedy\n");
    exit(1);
  }
#endif
  printf("Deflate Len %d, %x %x %x %x\n",
	 c_stream.total_out,
	 comp_buf[0],comp_buf[1],
	 comp_buf[2],comp_buf[3]);
#if 0
  for(i = 1; i < c_stream.total_out; i+= 2) {
    c = comp_buf[i-1];
    comp_buf[i-1] = comp_buf[i];
    comp_buf[i] = c;
  }
#endif

  file = fopen("xxx.txt.gz","wb");
  fwrite(comp_buf,c_stream.total_out,1,file);
  fclose(file);
  
  // test_inflate_buf(comp_len,comp_buf);
  
  return;
}

/* -----------------------------------------------
 * Given an uncompressed buffer, compress using compress
 */
int test_inflate_buf(int comp_len, char *comp_buf)
{
  int err;
  z_stream d_stream; /* decompression stream */

  int   decomp_len = 1000000;
  char *decomp_buf = NULL;
  
  int i = 0;
  
  // memset(&d_stream,0,sizeof(z_stream));
  d_stream.zalloc = (alloc_func)0;
  d_stream.zfree = (free_func)0;
  d_stream.opaque = (voidpf)0;
  
  decomp_buf = malloc(decomp_len);
  if (decomp_buf == NULL) goto wrapup;
  
  d_stream.next_in  = (Byte*)comp_buf;
  d_stream.avail_in = comp_len;

  err = inflateInit(&d_stream);
  CHECK_ERR(err, "inflateInit");

  for (;;) {
    d_stream.next_out  = (Byte*)decomp_buf;            /* discard the output */
    d_stream.avail_out = decomp_len;
    err = inflate(&d_stream, Z_NO_FLUSH);
    printf("Inflate Pass %d, Total In %d, Total Out %d\n",i,
	   d_stream.total_in,
	   d_stream.total_out);
    if (d_stream.msg) printf("Message %s\n",d_stream.msg);
    
    i++;
    
    if (err == Z_STREAM_END) break;
    CHECK_ERR(err, "large inflate");
  }

  err = inflateEnd(&d_stream);
  CHECK_ERR(err, "inflateEnd");

 wrapup:
  return 0;
  
}

/* -----------------------------------------------
 * Given an uncompressed buffer, compress using compress
 */
int test_inflate(IGRint argc, IGRchar *argv[])
{
  FILE *file;

  char *comp_buf;
  int   comp_len;
  int sts;
  
  char *fileName = "blob";
  struct stat fileStat;
  
  // Start by loading in compressed file
  stat(fileName,&fileStat);
  comp_len = fileStat.st_size;  
  if (comp_len == 0) goto wrapup;
  comp_buf = malloc(comp_len);
  if (comp_buf == 0) goto wrapup;
  
  // Load it
  file = fopen(fileName,"rb");
  sts = fread(comp_buf,comp_len,1,file);
  fclose(file);
  printf("File read %d %x %x\n",sts,comp_buf[0],comp_buf[1]);
  
  // Expand it
  test_inflate_buf(comp_len,comp_buf);
  
 wrapup:
  return 0;
}

/* -----------------------------------------------
 * Main traffic director
 */
int test_gz(IGRint argc, IGRchar *argv[])
{

  IGRint i;

  FILE *file = NULL;
  IGRchar buf[256];
  const char *p;
  
  // Init system
  p = zlibVersion();
  
  printf("Hello %s %s\n",p,ZLIB_VERSION);
  
  file = gzopen("blob","rb");
  if (file == NULL) {
    printf("Could not gzopen %s for reading\n","blob");
    goto wrapup;
  }
  while(gzgets(file,buf,256)) {
    // fputs(buf,stdout);
  }
  gzclose(file);
  file = NULL;
  
 wrapup:
  if (file) gzclose(file);
  
  return 0;
  
}

/* -----------------------------------------------
 * Main traffic director
 */
main(IGRint argc, IGRchar *argv[])
{
  
  // test_gz(argc,argv);
  // test_inflate(argc,argv);
  test_large_deflate();
  
 wrapup:
  
  return 0;
  
}

