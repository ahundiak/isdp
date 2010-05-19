/* $Id: VDhttp.C,v 1.3 2001/08/24 20:17:23 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDhttp.C
 *
 * Description:	HTTP Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDhttp.C,v $
 *      Revision 1.3  2001/08/24 20:17:23  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/11 21:30:18  art
 *      sp merge
 *
 * Revision 1.1  2000/04/25  16:20:48  pinnacle
 * ah
 *
 * Revision 1.2  2000/03/07  14:42:00  pinnacle
 * ah
 *
 * Revision 1.1  2000/03/07  14:18:46  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/06/00  ah      Creation
 ***************************************************************************/

#include "sys/types.h"
#include "sys/socket.h"
#include "netinet/in.h"
#include "string.h"
#include "netdb.h"
#include "stdio.h"

#include "VDtypedef.h"
#include "VDhttp.h"

// Hardcode to usual port for now
#define PORT_NUMBER 80

static int traceFlag;

/* -----------------------------------------------
 * Scans the buffer, returns index into beginning
 * of the content by locating a CRLFCRLF combination
 *
 * Assume that all the headers get sent on one recv buffer
 *
 * In many cases, content will actually begin in the next
 * recv buffer but still should get the combo in this one
 */
static IGRint VDhttpGetContentBeg(IGRchar *buf)
{
  IGRchar *p = NULL;
  IGRchar *q;
  IGRint  flag = 0;
  
  // Arg check
  if (buf == NULL) goto wrapup;
  
  // Cycle through, kind of messy but it works
  for(p = buf; *p; p++) {
    q = p;
    if (*q == 0) goto wrapup;
    if (*q == 0x0d) {
      q++;
      if (*q == 0) goto wrapup;
      if (*q == 0x0a) {
	q++;
	if (*q == 0) goto wrapup;
	if (*q == 0x0d) {
	  q++;
	  if (*q == 0x0a) {
	    q++;
	    p = q;
	    flag = 1;    // Got it
	    goto wrapup;
	  }
	}
      }
    }
  }
  
wrapup:
  if (flag) return (p - buf);
  return -1;
}

/* -----------------------------------------------
 * Find Content-Length: and convert to integer
 * If not found (chunked data) return -1
 */
static IGRint VDhttpGetContentLength(IGRchar *buf)
{
  IGRchar *p;
  
  p = strstr(buf,"Content-Length: ");
  if (p) return atoi(p+16);
  
  return -1;
}

/* -----------------------------------------------
 * Returns the code in the first line of an http
 * response
 */
static IGRint VDhttpGetCode(char *buf)
{
  IGRint code = -1;
  IGRchar *p;
  
  // Arg check
  if (buf == 0) goto wrapup;
  
  // Should start with http
  p = strstr(buf,"HTTP");
  if (p != buf) goto wrapup;
  
  // Find first space
  for(p = buf; *p > ' '; p++);
  if (*p != ' ') goto wrapup;
  
  // Get it
  code = atoi(p);
  
wrapup:
  return code;
}

/* -----------------------------------------------
 * Takes an open socket connection and reads the 
 * input, handles chunked data
 *
 * Output is always null terminated
 *
 * Should we collapse CRLF to just line feeds?
 *
 * Not written really cleanly but works so far
 */
static IGRint VDhttpGetContent(int s, int bufLen, char *buf)
{
  IGRint  retFlag = 0;
  IGRint  bufPnt;

  IGRchar data[4096],*p;
  IGRint  dataLen;
  IGRint  dataPnt;
  
  IGRint  contentLen;
  IGRint  contentBeg;
  
  IGRint  chunkLen;
  IGRint  code;
  
  // Arg check
  if (buf == 0)    goto wrapup;
  if (bufLen <= 0) goto wrapup;
  *buf = 0;
  bufPnt = 0;
  
  // Get the first buffer of data
  dataLen = recv(s,data,sizeof(data)-2,0);
  if (dataLen <= 0) goto wrapup;
  *(data + dataLen) = 0;
  
  // Check for error
  code = VDhttpGetCode(data);
  if ((code < 200) || (code > 299)) {
    printf("*** Bad http return code %d\n",code);
    goto wrapup;
  }
  // printf("Http Code %d\n",code);
  
  // Get the content Length
  contentLen = VDhttpGetContentLength(data);
  
  // Get the beginning of the content
  contentBeg = VDhttpGetContentBeg(data);
  if (contentBeg < 0) {
    printf("*** Problem finding content begginging\n");
    goto wrapup;
  }

  // If have a contentLen then 
  if (contentLen >= 0) {
    while(1) {

      // Xfer data from socket buffer to output buffer
      //contentBeg = 0;
      for(dataPnt = contentBeg; dataPnt < dataLen; dataPnt++) {
	buf[bufPnt++] = data[dataPnt];
	if (bufPnt >= bufLen) {
	  bufPnt--;
	  buf[bufPnt] = 0;
	  goto wrapup;
	}
      }
      buf[bufPnt] = 0;

      // Have more content?
      if (bufPnt >= contentLen) {
	retFlag = 1;
	goto wrapup;
      }
      
      // Get it, for now assume headers always in the first buffer
      dataLen = recv(s,data,sizeof(data)-2,0);
      if (dataLen <= 0) {
	retFlag = 1;
	goto wrapup;
      }
      *(data + dataLen) = 0;
      contentBeg = 0;
      
    }
  }
  
  // Implies a chunked connection
  // printf("Content %d %d %d\n",dataLen,contentLen,contentBeg);
  p = strstr(data,"Transfer-Encoding: chunked");
  if (p == NULL) {
    printf("Not content length, no chunked???\n%s\n",data);
    goto wrapup;
  }
  //printf("Chunked data\n");
  dataPnt = contentBeg;
  
  while(1) {

    // See if need more data, assume all chunks on buffer boundary
    if (dataPnt >= dataLen) {
      dataLen = recv(s,data,sizeof(data)-2,0);
      if (dataLen <= 0) {
	retFlag = 1;
	goto wrapup;
      }
      *(data + dataLen) = 0;
      dataPnt = 0;
      //printf("Read new data buffer %d\n",dataLen);
      
    }
  
    // Get the next chunk
    p = strchr(&data[dataPnt],0x0a);
    if (p == NULL) goto wrapup;

    chunkLen = (int)strtol(&data[dataPnt],NULL,16);

    // printf("Chunk Length %d\n",chunkLen);

    // See if done
    if (chunkLen <= 0) {
      retFlag = 1;
      goto wrapup;
    }

    dataPnt = (p - data + 1);
    
    // Transfer any data in this chunk
    if ((dataPnt + chunkLen) > dataLen) {
      chunkLen = dataLen - dataPnt;
    }
    
    for(p = &data[dataPnt]; chunkLen; chunkLen--) {
      buf[bufPnt++] = *p++;
      
      if (bufPnt >= bufLen) {
	bufPnt--;
	buf[bufPnt] = 0;
	goto wrapup;
      }
    }
    buf[bufPnt] = 0;
    dataPnt = p - data + 2; // Skip extra CRLF at end of chunk
    
  }
  
  // Done
  // retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get from the host
 */
IGRstat VDhttpDoGet(IGRchar *hostName, 
		    IGRint   port, 
		    IGRchar *getStr, 
		    IGRint   bufLen, 
		    IGRchar *buf)
{
  IGRint sts;

  struct hostent    *hp;
  struct sockaddr_in name;

  IGRint s = -1;  // Socket

  IGRint  sockLen;
  IGRint  sendLen;
  IGRchar sendBuf[1024];
  
  // Say Hi
  // printf("---- HTTP Get Test %s %s----\n",hostName,getStr);
  if (buf == NULL) goto wrapup;
  *buf = 0;
  
  // Adjust port
  if (port <= 0) port = PORT_NUMBER;
  
  // get the network address
  hp = gethostbyname(hostName);
  if ((hp == NULL) || (hp->h_name == NULL)) {
    // printf("Unable to get host network address for %s\n",hostName);
    goto wrapup;
  }
  //if (hp->h_name) printf("Official name %s\n",hp->h_name);
  
  // Create internet socket
  s = socket(AF_INET,SOCK_STREAM,0);
  if (s < 0) {
    printf("Socket creation failed\n");
    goto wrapup;
  }
  //printf("Socket %d\n",s);
  
  // Create address of the server
  memset(&name,0,sizeof(struct sockaddr_in));
  name.sin_family = AF_INET;
  name.sin_port = htons(port);
  memcpy(&name.sin_addr,hp->h_addr_list[0],hp->h_length);
  sockLen = sizeof(struct sockaddr_in);
  
  // Connect
  /* ---------------------------------------------
   * Not that if for some reason the machine is alive but the web server
   * is not running then this will hang for quite some time.  Need to figure
   * out how to set the delay or how to test or something
   */
  sts = connect(s,(struct sockaddr*)&name,sockLen);
  if (sts < 0) {
    printf("Unable to connect to host %s\n",hostName);
    goto wrapup;
  }
  //printf("Connected\n");

  // Data to send
  sprintf(sendBuf,
	 "GET %s HTTP/1.1\n"
         "Host: %s\n"
         "\n",
	  getStr,hp->h_name);

  /*"Connection: Keep-Alive\n\n");*/
  sendLen = strlen(sendBuf);

  // Send the data
  sts = send(s,sendBuf,sendLen,0);
  if (sts < 0) {
    printf("Problem sending buffer to host\n");
    goto wrapup;
  }
  // printf("Message sent\n");
  
  // Get the response
  VDhttpGetContent(s,bufLen,buf);
  
  // Done
wrapup:

  if (s > 0) close(s);
  
  return 1;
  
}
#if 0
/* -----------------------------------------------
 * Main traffic director
 * For standalone program
 */
int main(int argc, char *argv[])
{
  char hostName[128];
  char getStr  [128];
  char buf    [8192];
  
  // Arg check
  if (argc != 3) {
    printf("Usage - %s host get\n",argv[0]);
    return 1;
  }
  strcpy(hostName,argv[1]);
  strcpy(getStr,  argv[2]);

  printf("---- HTTP Get Test %s %s----\n",hostName,getStr);
  VDhttpDoGet(hostName, -1, getStr, sizeof(buf), buf);
  printf("### Data ###\n%s\n",buf);
  
  // Done
  return 0;
}
#endif
#if 0
/* -----------------------------------------------
 * Main traffic director
 * 07 Mar 2000 - Original Code
 */
main()
{
  int sts;
  int len;
  int contentLen,countLen;
  
  char   buf[8192];
  char   hostName[64];
  struct hostent *hp;
  struct sockaddr_in name;

  int s = -1;  // Socket
  int i;
  int flag;
  char c;
  
  // Say Hi
  printf("---- Socket Test ----\n");

  // Get local host name
  *hostName = 0;
  gethostname(hostName,sizeof(hostName));
  if (*hostName == 0) {
    printf("Unable to get local host name\n");
    goto wrapup;
  }
  strcpy(hostName,"redwood2");
  strcpy(hostName,"129.135.170.108");
  strcpy(hostName,"solimpd");
  
  //strcpy(hostName,"www.microsoft.com");
  printf("Host Name %s\n",hostName);
  
  // get the network address
  hp = gethostbyname(hostName);
  if (hp == NULL) {
    printf("Unable to get host network address for %s\n",hostName);
    goto wrapup;
  }
  if (hp->h_name) printf("Official name %s\n",hp->h_name);
  
  // Create internet socket
  s = socket(AF_INET,SOCK_STREAM,0);
  if (s < 0) {
    printf("Socket creation failed\n");
    goto wrapup;
  }
  printf("Socket %d\n",s);
  
  // Create address of the server
  memset(&name,0,sizeof(struct sockaddr_in));
  name.sin_family = AF_INET;
  name.sin_port = htons(PORT_NUMBER);
  memcpy(&name.sin_addr,hp->h_addr_list[0],hp->h_length);
  len = sizeof(struct sockaddr_in);
  
  // Connect
  sts = connect(s,(struct sockaddr*)&name,len);
  if (sts < 0) {
    printf("Unable to connect to host %s\n",hostName);
    goto wrapup;
  }
  printf("Connected\n");

  // Data to send
  sprintf(buf,
	 "GET /ops/minos.asp?mino=m1 HTTP/1.1\n"
	  // "GET /test.html HTTP/1.1\n"
         "Host: %s\n"
         "\n",
	 hp->h_name);

  /*"Connection: Keep-Alive\n\n");*/
  len = strlen(buf);

  // Send the data
  sts = send(s,buf,len,0);
  if (sts < 0) {
    printf("Problem sending buffer to host\n");
    goto wrapup;
  }
  printf("Message sent\n");
  
  // And get the reply
  /* This loop works but there is a pause after receiveing the last buffer
   * Could parse out Content-Length and control by that
   * Or is there in fact a EOF 
   *
   * Checking for 1460 works but is it universal???
   * Or always constant for a given site???
   * Nope and nope.
   *
   * Using content length seems to be work ok however
   * so far the 2 individual lengths from redwood2 do not
   * add up exactly to the content_length,
   */
  flag = 1;
  contentLen = -1;
  countLen = 0;
  
  while (flag) 
  {
    len = recv(s,buf,sizeof(buf)-2,0);
    *(buf+len+1) = 0;
    
    printf("\n*** Buffer Length %d\n",len);  
    //write(1,buf,len);

    if (contentLen < 0) {
      contentLen = httpGetContentLength(buf);
    }
    countLen += len;
    if (countLen >= contentLen) flag = 0;
    if (len < 1) flag = 0;
    
    for(i = 0; i < len; i++) {
      c = buf[i];
      if (c < ' ') c = '#';
      printf("%4d %4x %c\n",i,buf[i],c);
    }
  }
  printf("\n");
  
  if (1) goto wrapup;
#if 0
  // Need some sort of loop here to get multiple buffers???
  len = recv(s,buf,sizeof(buf),0);
  if (len <= 0) {
    printf("No reply\n");
    goto wrapup;
  }
  *(buf+len) = 0;
  printf("######  Received buffer %d\n%s\n",len,buf);


  // Need some sort of loop here to get multiple buffers???
  // Content-Length: 1617
  len = recv(s,buf,sizeof(buf),0);
  if (len <= 0) {
    printf("No reply\n");
    goto wrapup;
  }
  *(buf+len) = 0;
  printf("######  Received buffer %d\n%s\n",len,buf);
#endif

  // Done
wrapup:

  if (s > 0) close(s);
  
  return 1;
  
}
#endif

#if 0
struct	hostent {
	char	*h_name;	/* official name of host */
	char	**h_aliases;	/* alias list */
	int	h_addrtype;	/* host address type */
	int	h_length;	/* length of address */
	char	**h_addr_list;	/* list of addresses from name server */
#define	h_addr	h_addr_list[0]	/* address, for backward compatiblity */
};
#endif


