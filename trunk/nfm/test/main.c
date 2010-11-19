#include <stdio.h>
#include <glib.h>

#include "DEBUG.h";

int traces()
{
  g_message("And the message is");
  g_warning("A warning");
  g_critical("Very bad");

  // Not defined
  // g_debug("Some debug stuff");

  // Does indeed cause an abort
  //g_error("An error resulting in abort?");

}
int check(char *arg)
{
  // Critical warning with file/line if passed a null pointer
  g_return_val_if_fail(arg,0);
}
int main(int argc, char *argv[])
{
  traces();

  g_assert(1);

  check("Hello");
  
  // Instant abot with file name and line number
  // g_assert(0);
  _MEMdebug(("Some file","Some message %s\n","at last"));
}