#include <stdio.h>
#include <FI.h>
#include <FIdyn.h>
#include "MRPgadlabs.h"
#include "MRPmessage.h"
#include "MRPstr.h"
#include "PDUstr.h"
#include "PDUproto.h"


void MRPdyn_gadget_init( dyn_std_var )
struct standard_st *dyn_std_var;
{
	dyn_std_var->xlo = 0;
	dyn_std_var->ylo = 0;
	dyn_std_var->xhi = 100;
	dyn_std_var->yhi = 100;
	dyn_std_var->attr_mask = FI_TEXT_GADGET;
	dyn_std_var->value = 0.0;
	dyn_std_var->bodysize = 18.0;
	dyn_std_var->text = NULL;
	dyn_std_var->help_topic = NULL;
	dyn_std_var->command = NULL;
	dyn_std_var->fontname = NULL;
	dyn_std_var->user_pointer = NULL;
	dyn_std_var->off_color = FI_BLACK;
	dyn_std_var->on_color = FI_BLACK;
	dyn_std_var->off_color2 = FI_BLACK;
	dyn_std_var->on_color2 = FI_BLACK;
	dyn_std_var->symbol_index = 0;
	dyn_std_var->symbol_index2 = 0;
	dyn_std_var->next_in_seq = 0;
}
