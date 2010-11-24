#include <stdio.h>
#include <stdlib.h>

#include "risapp.h"
#include "risdebug.h"

int main(int argc, char *argv[])
{
  char schema[128];

  RISapp_initialize("english"); // RIScom_default_ris_langname()

  // RIScom_initialize_debug();
  
  RISint_debug = 1;
  
#if 0
  *schema = 0;
  RISget_default_schema_name(schema);

  printf("Default schema is: %s\n",schema);
#endif

  // Prints to /usr/tmp/ris.out
	INT_DBG(("RISget_schema_names(buffer: %s)\n", "Hello from debug"));
  
}
