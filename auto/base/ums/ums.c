#include <glib.h>
#include <gio/gio.h>
#include <string.h>

#include "UMS.h"
#include "UMSx.h"

typedef	struct
{
  char  ums[3];
  char  version;
  short msgBase;
  char  comp[UMS_COMP_LEN];
  long  msgCount;
  long  txtBufLen;
  long  priKeyBufLen;
  long  secKeyBufLen;
} UMSFileHdr;

UMSInfo *ums_load_file(char *fileName)
{
  GFile        *file    = NULL;
  GInputStream *fileInn = NULL;
  GError       *error   = NULL;

  UMSInfo *info = NULL;

  UMSFileHdr    fileHdr;
  gssize        len,lenx;

  glong i,txtOff,keyOff;

  // Open the file
  file    = g_file_new_for_path(fileName);
  fileInn = (GInputStream *)g_file_read(file,NULL,&error);
  g_assert(!error);
  g_assert(fileInn);

  // Loader header
  len = g_input_stream_read(fileInn,&fileHdr,sizeof(UMSFileHdr),NULL,&error);
  g_assert(!error);
  g_assert(len == sizeof(UMSFileHdr));
  g_assert(!strncmp("UMS",fileHdr.ums,3));

  // Xfer to info
  info = g_malloc0(sizeof(UMSInfo) + strlen(fileName));
  strcpy(info->msgFileName,fileName);

  info->msgBase  = fileHdr.msgBase;
  info->msgCount = fileHdr.msgCount;

  strcpy(info->comp,fileHdr.comp);

  // Load in the index pointers
  lenx = fileHdr.msgCount * sizeof(UMSIndex);
  if (lenx)
  {
    info->indexes = g_malloc(lenx);
    len = g_input_stream_read(fileInn,info->indexes,lenx,NULL,&error);
    g_assert(!error);
    g_assert(len == lenx);
  }
  // Load in text buffer
  if (fileHdr.txtBufLen)
  {
    info->txtBuf = g_malloc(fileHdr.txtBufLen);
    len = g_input_stream_read(fileInn,info->txtBuf,fileHdr.txtBufLen,NULL,&error);
    g_assert(!error);
    g_assert(len == fileHdr.txtBufLen);
  }
  // Load in promary key buffer
  if (fileHdr.priKeyBufLen)
  {
    info->priKeyBuf = g_malloc(fileHdr.priKeyBufLen);
    len = g_input_stream_read(fileInn,info->priKeyBuf,fileHdr.priKeyBufLen,NULL,&error);
    g_assert(!error);
    g_assert(len == fileHdr.priKeyBufLen);
  }
  // Load secondary key buffer
  if (fileHdr.secKeyBufLen)
  {
    info->secKeyBuf = g_malloc(fileHdr.secKeyBufLen);
    len = g_input_stream_read(fileInn,info->secKeyBuf ,fileHdr.secKeyBufLen,NULL,&error);
    g_assert(!error);
    g_assert(len == fileHdr.secKeyBufLen);
  }

  // Adjust the offsets
  txtOff = sizeof(UMSFileHdr) + (sizeof(UMSIndex) * fileHdr.msgCount);
  keyOff = txtOff + fileHdr.txtBufLen;

  for(i = 0; i < fileHdr.msgCount; i++)
  {
    if (info->indexes[i].msgNum)
    {
      info->indexes[i].txtPtr -= txtOff;
      info->indexes[i].keyPtr -= keyOff;
    }
    else g_assert(NULL);
  }  
  // Close up
  g_input_stream_close(fileInn,NULL,&error);
  g_assert(!error);

wrapup:
  g_object_unref(fileInn);
  g_object_unref(file);

  return info;
}
void ums_free_info(UMSInfo *info)
{
  if (!info) return;
  g_free(info->secKeyBuf);
  g_free(info->priKeyBuf);
  g_free(info->txtBuf);
  g_free(info->indexes);
  g_free(info);
}
void test_ums_load_file()
{
  UMSInfo *info = NULL;

  glong msgNum,msgBase,msgIndex;

  gshort txtLen,txtPtr;
  gchar  txtData[256];
  gchar  msgFileName[] = "/opt/ingr/ris/ris.msg";

  info = ums_load_file(msgFileName);

  g_assert(info);

  g_assert_cmpstr(msgFileName, ==, info->msgFileName);
  
  g_assert_cmpstr("RIS", ==, info->comp);
  g_assert_cmpint(660,   ==, info->msgBase);
  g_assert_cmpint(2290,  ==, info->msgCount);

  // Lookup a ris error
  msgNum = 177504330;

  msgBase  = ( msgNum >> 16 ) & 0x07ffL;
	msgIndex = ( msgNum >>  3 ) & 0x0fffL;
  msgIndex--;

  g_assert_cmpint(660,==,msgBase);
  g_assert_cmpint(  8,==,msgIndex);  //

  g_assert_cmpint(msgNum,==,info->indexes[msgIndex].msgNum);

  txtPtr = info->indexes[msgIndex].txtPtr;
  g_assert_cmpint(615,==,txtPtr);

  memcpy(&txtLen,&info->txtBuf[txtPtr],2);
  g_assert_cmpint(59,==,txtLen);

  memcpy(txtData,&info->txtBuf[txtPtr+2],txtLen);
  *(txtData + txtLen) = 0;
  g_assert_cmpstr(txtData,==,"Unable to convert data for different hardware architecture.");

  // Key strings are a bit different
  txtLen = info->indexes[msgIndex+1].keyPtr - info->indexes[msgIndex].keyPtr;
  g_assert_cmpint(11,==,txtLen);

  txtPtr = info->indexes[8].keyPtr;

  memcpy(txtData,&info->priKeyBuf[txtPtr],txtLen);
  *(txtData + txtLen) = 0;
  g_assert_cmpstr(txtData,==,"ARCH_ERROR");

  // Done
  ums_free_info(info);
}
/* ===================================================================================
 * Stores information from the message files in a simple linked list
 */
static GSList *infos = NULL;

static gint compare_file_name(gconstpointer a, gconstpointer b)
{
  UMSInfo *info        = (UMSInfo *)a;
  gchar   *msgFileName = (gchar   *)b;

  return strcmp(info->msgFileName,msgFileName);
}
static gint compare_msg_base(gconstpointer a, gconstpointer b)
{
  UMSInfo *info    = (UMSInfo *)a;
  gint     msgBase = GPOINTER_TO_INT(b);

  if (info->msgBase == msgBase) return 0;

  return (info->msgBase > msgBase) ? 1: -1;
}
int UMSInitMsg ( char *msgFileName, int optFlag )
{
  UMSInfo *info;
  GSList  *found;

  // See if already loaded
  found = g_slist_find_custom(infos,msgFileName,compare_file_name);
  if (found) return UMS_S_SUCCESS;

  info = ums_load_file(msgFileName);
  if (!info) return UMS_E_FAIL;

  infos = g_slist_prepend(infos,info);

  return UMS_S_SUCCESS;
}

void test_ums_init_msg()
{
  int sts;

  sts = UMSInitMsg("/opt/ingr/ris/ris.msg",0);
  g_assert(sts == UMS_S_SUCCESS);
  
  sts = UMSInitMsg("/opt/ingr/ris/ris.msg",0);
  g_assert(sts == UMS_S_SUCCESS);

  g_assert_cmpint(1, ==, g_slist_length(infos));
}
/* ==================================================
 * Find for a key
 */
int UMSGetByNum (char msgBuf[], long  msgNum, char *msgFmt, ...)
{
  UMSInfo *info;
  GSList  *found;

  gshort msgBase;
  gint   msgIndex;

  gshort txtLen;
  gint   txtPtr;
  gchar  txtData[256];
  
  // Decode the message number
  msgBase  = ( msgNum >> 16 ) & 0x07ffL;
	msgIndex = ( msgNum >>  3 ) & 0x0fffL;
  msgIndex--;

  // Find the info fo the base
  found = g_slist_find_custom(infos,GINT_TO_POINTER(msgBase),compare_msg_base);
  if (!found) return UMS_E_FAIL;
  info = found->data;

  // Verify valid index
  if ((msgIndex < 0) || (msgIndex >= info->msgCount) || (!info->indexes[msgIndex].msgNum))
  {
    return UMS_E_FAIL;
  }
  txtPtr = info->indexes[msgIndex].txtPtr;

  memcpy(&txtLen,&info->txtBuf[txtPtr],2);

  memcpy(txtData,&info->txtBuf[txtPtr+2],txtLen);
  *(txtData + txtLen) = 0;

  strcpy(msgBuf,txtData);

  return UMS_S_SUCCESS;
}
void test_ums_get_by_num()
{
  int sts;
  char buf[256];
  long msgNum = 177504330;

  sts = UMSInitMsg("/opt/ingr/ris/ris.msg",0);
  g_assert(sts == UMS_S_SUCCESS);

  sts = UMSGetByNum(buf,msgNum,NULL);
  
  g_assert(sts == UMS_S_SUCCESS);
  g_assert_cmpstr(buf,==,"Unable to convert data for different hardware architecture.");

}
