#include <glib.h>
#include <glib/gstdio.h>
#include "risapp.h"

#include "VDrisc.h"
#include "VDrisSchema.h"

int queryStorageArea(TAStorageAreaItem *item, int sano)
{
  TVDrisInfo info;
  gchar    **row;

  gchar sql[1024];
  gchar sql_fmt[] = 
    "SELECT "
    "  sax.n_sano, sax.n_nodeno, sax.n_pathname, sax.n_username, sax.n_passwd, "
    "  nodex.n_nodename "
    "FROM  nfmstoragearea sax, nfmnodes nodex "
    "WHERE sax.n_sano = %d AND sax.n_nodeno = nodex.n_nodeno;";

  // Init
  memset(item,0,sizeof(TAStorageAreaItem));
  if (!sano) return 1;

  VDrisInitInfo(&info);

  g_sprintf(sql,sql_fmt,sano);

  VDrisQuery(&info,sql);

  if (info.rows == 0) return 1;

  row = &info.buf[0];

  item->n_sano   = atoi(row[0]);
  item->n_nodeno = atoi(row[1]);

  strcpy(item->n_pathname,row[2]);
  strcpy(item->n_username,row[3]);
  strcpy(item->n_passwd,  row[4]);
  strcpy(item->n_nodename,row[5]);

  VDrisFreeInfo(&info);

  return 1;
}
int queryPart(TAPartItem *item, gchar *catalog, gchar *part, gchar *rev)
{
  TVDrisInfo info;
  gchar    **row;

  TAStorageAreaItem saItem;

  gchar sql[1024];
  gchar sql_fmt[] =
  "SELECT "
  "  partx.n_itemno,  partx.n_itemname,   partx.n_itemrev, "
  "  partx.n_colevel, partx.n_itemlock,   partx.n_stateno, "
  "  partx.n_status,  partx.n_updatedate, partx.n_updater, "
  ""
  "  filex.n_cofilename, filex.n_cosano, filex.n_couser, filex.n_codate, "
  "  filex.n_cifilename, filex.n_cisano, filex.n_ciuser, filex.n_cidate, filex.n_cifilesize "
  ""
  "FROM %s partx, f_%s filex "
  "WHERE "
  "  partx.n_itemname = '%s' AND partx.n_itemrev = '%s' AND "
  "  partx.n_itemno = filex.n_itemnum AND filex.n_fileversion = "
  ""
  "(SELECT MAX(filex.n_fileversion) FROM f_%s filex WHERE partx.n_itemno = filex.n_itemnum)"
  ";";

  // Init
  memset(item,0,sizeof(TAPartItem));

  VDrisInitInfo(&info);

  g_sprintf(sql,sql_fmt,catalog,catalog,part,rev,catalog);

  VDrisQuery(&info,sql);

  if (info.rows == 0) return 1;

  row = &info.buf[0];

  item->n_itemno = atoi(row[0]);

  strcpy(item->n_itemname,  row[1]);
  strcpy(item->n_itemrev,   row[2]);
  strcpy(item->n_catalogname,catalog);

  item->n_colevel  =              atoi(row[ 3]);
  item->n_itemlock = g_ascii_toupper(*(row[ 4]));
  item->n_stateno  =              atoi(row[ 5]);

  strcpy(item->n_status,    row[ 6]);
  strcpy(item->n_updatedate,row[ 7]);
  strcpy(item->n_updater,   row[ 8]);

  strcpy(item->n_cofilename,row[ 9]);
  item->n_cosano     = atoi(row[10]);
  strcpy(item->n_couser,    row[11]);
  strcpy(item->n_codate,    row[12]);

  strcpy(item->n_cifilename,row[13]);
  item->n_cisano     = atoi(row[14]);
  strcpy(item->n_ciuser,    row[15]);
  strcpy(item->n_cidate,    row[16]);
  item->n_cifilesize = atoi(row[17]);

  queryStorageArea(&saItem,item->n_cosano);

  item->n_conodeno = saItem.n_nodeno;

  strcpy(item->n_conodename,saItem.n_nodename);
  strcpy(item->n_conodepath,saItem.n_pathname);
  strcpy(item->n_conodeuser,saItem.n_username);

  VDrisFreeInfo(&info);

  return 1;

}

/* =========================================
 * The test routine
 */
void test_query_part_checked_out()
{
  gchar catalog[] = "elec_eqpt_m_2552";
  gchar part[]    = "2552168008";
  gchar file[]    = "2552168008.m";
  gchar rev[]     = "014";

  TAPartItem item;

  queryPart(&item,catalog,part,rev);

  g_assert_cmpint(67,      ==, item.n_itemno);
  g_assert_cmpstr(catalog, ==, item.n_catalogname);
  g_assert_cmpstr(part,    ==, item.n_itemname);
  g_assert_cmpstr(rev,     ==, item.n_itemrev);

  g_assert_cmpint(17,      ==, item.n_stateno);
  g_assert_cmpint('N',     ==, item.n_itemlock);


  g_assert_cmpstr("O",                   ==, item.n_status);
  g_assert_cmpstr("0000-00-00:00:00:00", ==, item.n_updatedate); // Empty for release as well
  g_assert_cmpstr("",                    ==, item.n_updater);

  // Check out fields
  g_assert_cmpstr(file,                  ==, item.n_cofilename);
  g_assert_cmpint(0,                     ==, item.n_colevel);
  g_assert_cmpint(5016347,               ==, item.n_cosano);
  g_assert_cmpstr("2010-12-08:17:23:42", ==, item.n_codate);
  g_assert_cmpstr("ahundiak",            ==, item.n_couser);

  g_assert_cmpstr("willow",              ==, item.n_conodename);
  g_assert_cmpstr("/home/impd/test/vds", ==, item.n_conodepath);
  g_assert_cmpstr("impd",                ==, item.n_conodeuser);
  
  // Check in fields
  g_assert_cmpstr("",                    ==, item.n_cifilename); // Always NULL, even in production
  g_assert_cmpint(4405022,               ==, item.n_cisano);
  g_assert_cmpstr("2010-12-08:17:23:42", ==, item.n_cidate);
  g_assert_cmpstr("ahundiak",            ==, item.n_ciuser);

}
void test_query_part_released()
{
  gchar catalog[] = "elec_eqpt_m_2552";
  gchar part[]    = "2552168012";
  gchar file[]    = "2552168012.m";
  gchar rev[]     = "000";

  TAPartItem item;

  queryPart(&item,catalog,part,rev);

  g_assert_cmpint(18,      ==, item.n_itemno);
  g_assert_cmpstr(catalog, ==, item.n_catalogname);
  g_assert_cmpstr(part,    ==, item.n_itemname);
  g_assert_cmpstr(rev,     ==, item.n_itemrev);

  g_assert_cmpint(22,      ==, item.n_stateno);
  g_assert_cmpint('N',     ==, item.n_itemlock);

  g_assert_cmpstr("I",                   ==, item.n_status);
  g_assert_cmpstr("0000-00-00:00:00:00", ==, item.n_updatedate);  // Empty for release as well
  g_assert_cmpstr("",                    ==, item.n_updater);

  // Check out fields
  g_assert_cmpstr(file,                  ==, item.n_cofilename);
  g_assert_cmpint(0,                     ==, item.n_colevel);
  g_assert_cmpint(0,                     ==, item.n_cosano);
  g_assert_cmpstr("0000-00-00:00:00:00", ==, item.n_codate);
  g_assert_cmpstr("",                    ==, item.n_couser);

  // Check in fields
  g_assert_cmpstr("",                    ==, item.n_cifilename); // Always NULL, even in production
  g_assert_cmpint(4405022,               ==, item.n_cisano);
  g_assert_cmpstr("2009-05-28:08:52:49", ==, item.n_cidate);
  g_assert_cmpstr("gallote",             ==, item.n_ciuser);

}
void test_query_part()
{
  test_query_part_released();
  test_query_part_checked_out();
}
