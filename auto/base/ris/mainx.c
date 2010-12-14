#include <glib.h>
#include <glib/gstdio.h>
#include <glib-object.h>

#include "risx.h"

/* ============================================================================
 */
extern int ris_net_connect();
extern int ris_net_disconnect();
extern int ris_net_get_ris_server_path(char *path);
extern int ris_net_check_arch();
extern int ris_net_get_table_info();
extern int ris_net_open_schema();

void test_nothing()
{
  g_assert(TRUE);
}
void test_ris_net_connect()
{
  int sts;
  char path[256];

  sts = ris_net_connect();
  g_assert_cmpint(RIS_SUCCESS, ==, sts);

  sts = ris_net_get_ris_server_path(path);
  g_assert_cmpint(RIS_SUCCESS, ==, sts);
  g_assert_cmpstr(path,==,"D:\\RIS\\RIS06.00");
  
  sts = ris_net_disconnect();
  g_assert_cmpint(RIS_SUCCESS, ==, sts);

}
void test_ris_net_init()
{
  int sts;

  sts = ris_net_connect();
  g_assert_cmpint(RIS_SUCCESS, ==, sts);

  sts = ris_net_check_arch();
  g_assert_cmpint(RIS_SUCCESS, ==, sts);

  sts = ris_net_open_schema();
  g_assert_cmpint(RIS_SUCCESS, ==, sts);

  sts = ris_net_get_table_info();
  g_assert_cmpint(RIS_SUCCESS, ==, sts);

}
extern void test_ris_query();

int main(int argc, char** argv)
{
  g_type_init();
  g_test_init (&argc, &argv, NULL);

  g_test_add_func("/base/ris nothing", test_nothing);
  g_test_add_func("/base/ris init",    test_ris_net_init);
  g_test_add_func("/base/ris query",   test_ris_query);
//g_test_add_func("/base/ris connect", test_ris_net_connect);

  return g_test_run();
}

