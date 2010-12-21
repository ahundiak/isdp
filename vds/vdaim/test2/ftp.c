#include <stdio.h>
#include <string.h>

#include <glib.h>
#include <gio/gio.h>

/* ==============================================
 * 09 Dec 2010
 * Well poo, this needs to have gvfs (gnome virtual file server) loaded
 * and I cannot seem to find a package
 * Also need dbus and dbus-glib installed an running
 *
 * Would have been nice
 */
int test_ftp()
{
  gchar uri[1024];
  gchar *fileBaseName = NULL;
  gchar *fileScheme   = NULL;

  gchar *buf = NULL;
  gssize bufSize = 65534;
  gssize bufRead;
  gint   bufCount;

  GFile *file;
  GInputStream *fileInn;
  GError       *err = NULL;

  strcpy(uri,"ftp://impd:impd@dev04/export/home/impd/test/struct.m");

  file = g_file_new_for_uri(uri);
  g_assert(file);

  fileBaseName = g_file_get_basename(file);
  g_assert_cmpstr("struct.m",==,fileBaseName);

  fileScheme = g_file_get_uri_scheme(file);
  g_assert_cmpstr("ftp",==,fileScheme);

  fileInn = (GInputStream *)g_file_read(file,NULL,&err);
  if (err)
  {
    fprintf (stderr, "Unable to read file: %s\n", err->message);
    g_error_free(err);
    goto wrapup;
  }
  g_assert(fileInn);
  
  buf = g_malloc(bufSize);

  for(bufCount = 0, bufRead = bufSize; bufRead == bufSize; bufCount++)
  {
    bufRead = g_input_stream_read(fileInn,buf,bufSize,NULL,NULL);
  }
  g_input_stream_close(fileInn,NULL,NULL);

  g_message("FTP Blocks %d",bufCount);
  
  // Clean up
wrapup:
  g_free(fileBaseName);
  g_free(fileScheme);
  g_free(buf);
  g_object_unref(fileInn);
  g_object_unref(file);

}
