#include <glib.h>
#include <gio/gio.h>



void test_ums_load_file();
void test_ums_init_msg();
void test_ums_get_by_num();

int main(int argc, char** argv)
{
  g_type_init();
  
  g_test_init (&argc, &argv, NULL);

  g_test_add_func("/base/ums open", test_ums_load_file);
  g_test_add_func("/base/ums init", test_ums_init_msg);
  g_test_add_func("/base/ums get ", test_ums_get_by_num);

  return g_test_run();
}

