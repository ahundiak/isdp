
#include "risx.h"
/* ======================================================
 * Misc globals
 */
int RIS_client_died = 0;
int RIS_mem = 1;
int RIS_net = 1;

/* ======================================================
 */
char RIS_def_schname[RIS_MAX_ID_SIZE];

int RISget_default_schema_name(gchar *schema)
{
  g_assert(schema);

  strcpy(schema,RIS_def_schname);

  return 0;
}
/* ======================================================
 */
int SQLCODE;

int  RISget_sqlcode() { return SQLCODE; }
void RISint_set_sqlcode(int code) { SQLCODE = code; }


int RISint_execute() { return 0; }
int RISint_describe() { return 0; }
int RISint_report_error() { return 0; }
int RISint_fetch() { return 0; }
int RISint_clear() { return 0; }


