#include <stdio.h>
#ifdef NT
#include <stdlib.h>
#include <string.h>
#endif
#include <ctype.h>
#include <COBshfn.h>	/* need this for _tok_xxxx #defines	*/
#include <COBint.h>
#include <COBmacros.h>

/**********************************************************/
/*** NOTE: put all these in same file so they can all	***/
/***       reference static functions			***/
#include "eval_str.C"
#include "read_t_attrs.C"
#include "read_t_next.C"
#include "setup_t.C"
