#include <glib.h>
#include <glib/gstdio.h>
#include <glib-object.h>

#include "VDrisc.h"

#include "risapp.h"

void test_query_part();

void test_open_schema()
{
  gint sts;

  sts = VDrisExecuteSilent("default schema isdptst.isdptstpAss");

  g_assert(sts & 1);
}
void test_get_schema()
{
  gchar schema[128];

  *schema = 0;
  RISget_default_schema_name(schema);
  g_assert_cmpstr("isdptst",==,schema);
}
void test_query_nodes()
{
  TVDrisInfo info;

  gchar sql_fmt[] =
    "SELECT n_nodeno,n_nodename,n_machid,n_opsys,n_nfs,n_tcpip,n_xns "
    "FROM nfmnodes WHERE n_nodename = 'willow';";

  gchar sql[128];

  VDrisInitInfo(&info);

  g_sprintf(sql,sql_fmt);

  VDrisQuery(&info,sql);

  g_assert_cmpint(1,==,info.rows);

  g_assert_cmpint(    4413, ==, atoi(info.buf[0])); // n_nodeno
  g_assert_cmpstr("willow", ==,      info.buf[1] ); // n_nodename
  g_assert_cmpstr("UNIX",   ==,      info.buf[2] ); // n_machid
  g_assert_cmpstr("UNIX",   ==,      info.buf[3] ); // n_opsys
  g_assert_cmpint(    'N',  ==,     *info.buf[4] ); // n_nfs
  g_assert_cmpint(    'Y',  ==,     *info.buf[5] ); // n_tcpip
  g_assert_cmpint(    'N',  ==,     *info.buf[6] ); // n_xns

  VDrisFreeInfo(&info);
}
void test_query_storage_areas()
{
  TVDrisInfo info;

  gchar sql_fmt[] =
    "SELECT "
    "  sa.n_sano, sa.n_pathname, sa.n_username, sa.n_passwd, sa.n_nodeno, "
    "  nodex.n_nodename "
    "FROM  nfmstoragearea sa, nfmnodes nodex "
    "WHERE sa.n_nodeno = nodex.n_nodeno AND nodex.n_nodename = 'willow';";

  gchar sql[128];
  gchar **row;

  VDrisInitInfo(&info);

  g_sprintf(sql,sql_fmt);

  VDrisQuery(&info,sql);

  g_assert_cmpint(2,==,info.rows);

  row = &info.buf[0];
  g_assert_cmpint(5016343,                ==, atoi(row[0])); // n_sano
  g_assert_cmpstr("/home/impd/ingr_test", ==,      row[1] ); // n_pathname
  g_assert_cmpstr("impd",                 ==,      row[2] ); // n_username
  g_assert_cmpstr("willow",               ==,      row[5] ); // n_nodename

  row = &info.buf[info.cols];
  g_assert_cmpint(5016347,                ==, atoi(row[0])); // n_sano
  g_assert_cmpstr("/home/impd/test/vds",  ==,      row[1] ); // n_pathname
  g_assert_cmpstr("impd",                 ==,      row[2] ); // n_username
  g_assert_cmpstr("willow",               ==,      row[5] ); // n_nodename

/*
  g_assert_cmpint(    4413, ==, atoi(info.buf[0])); // n_nodeno
  g_assert_cmpstr("willow", ==,      info.buf[1] ); // n_nodename
  g_assert_cmpstr("UNIX",   ==,      info.buf[2] ); // n_machid
  g_assert_cmpstr("UNIX",   ==,      info.buf[3] ); // n_opsys
  g_assert_cmpint(    'N',  ==,     *info.buf[4] ); // n_nfs
  g_assert_cmpint(    'Y',  ==,     *info.buf[5] ); // n_tcpip
  g_assert_cmpint(    'N',  ==,     *info.buf[6] ); // n_xns
*/
  VDrisFreeInfo(&info);
}
void test_nothing()
{
  // Set this to false generates core file
  g_assert(TRUE);
}
int main(int argc, char** argv)
{
  g_type_init();
  g_test_init (&argc, &argv, NULL);

  g_test_add_func("/base/ris nothing", test_nothing);

  g_test_add_func("/base/ris open_schema", test_open_schema);
  g_test_add_func("/base/ris  get_schema", test_get_schema);
//g_test_add_func("/base/ris  query node", test_query_nodes);
  g_test_add_func("/base/ris  query sas ", test_query_storage_areas);
#if 0
  g_test_add_func("/base/ris  query part", test_query_part);
#endif
  return g_test_run();
}

