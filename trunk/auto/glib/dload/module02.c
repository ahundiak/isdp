#include "config.h"
#include <stdio.h>
#include <glib.h>
#include <gmodule.h>

extern gint public_var;

static gint s_count = 0;

const gchar *g_module_check_init(GModule *module)
{
  g_message("Module Loaded: %s",g_module_name(module));
  return NULL;
}
 void g_module_unload(GModule *module)
{
  // g_message("Module UnLoaded: %s",g_module_name(module));
}
 void module02_hello(gint *result,gint *count)
 {
   *result = 2 * public_var;
   s_count++;
   *count = s_count;
 }

