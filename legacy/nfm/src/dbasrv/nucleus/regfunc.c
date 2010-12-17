/* $Revision: 1.1 $ */
#include "dba.ext"
#include "script.def"
#include "dmalloc.def"

extern char *dba_errtxt;

static dba_avl_tree_node *regfunc_tree;
static reg_func_type *cur_reg_func;
static reg_arg_type *cur_arg;

static long default_verbose_flag;
static long default_verbose_type;
static long default_verbose_val;
static long default_argnum_enforce;
static long (*default_init_env_func)();
static int tree_depth;

/*
    Function:	reg_func_lt (STATIC)
    Author:	Tim A. Thompson
    Date:	03-DEC-92
*/

/* ARGSUSED */

static long reg_func_lt (a, b, extra)
void *a, *b, *extra;
{
  return strcmp (((reg_func_type *)a)->name, ((reg_func_type *)b)->name) < 0;
}


/*
    Function:	dba_is_registered_function
    Author:	Tim A. Thompson
    Date:	18-AUG-92

    Revisions:
	12-3-92  -- Converted to use of avl tree.
*/

long dba_is_registered_function (name, ret_reg)
char *name;
reg_func_type **ret_reg;
{
  dba_avl_tree_node *tree;
  reg_func_type *reg;
  long cmp;

  tree = regfunc_tree;
  while (1) {
    if (!tree)
      return 0;
    reg = (reg_func_type *) tree->data;
    cmp = strcmp (reg->name, name);
    if (!cmp) {
      if (ret_reg)
        *ret_reg = reg;
      return 1;
    }
    if (cmp < 0)
      tree = tree->right;
    else
      tree = tree->left;
  }
}


/*
    Function:	dba_reg_func_end
    Author:	Tim A. Thompson
    Date:	03-DEC-92
*/

long dba_reg_func_end ()
{
  cur_reg_func = (reg_func_type *) 0;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_func_start
    Author:	Tim A. Thompson
    Date:	03-DEC-92

    Revisions:
	3-9-93   -- Was not making the name upper case before searching for
		    previously registered function by the same name.
*/

long dba_reg_func_start (name, func_ptr)
char *name;
void (*func_ptr)();
{
  char *up_name;
  reg_func_type *reg;
  long istat, inc;

  if (cur_reg_func) {
    istat = dba_reg_func_end ();
    if (istat)
      return istat;
  }
  up_name = dba_dstrdup (name, DM_FUNCTION_NAME);
  dba_upper (up_name);
  if (dba_is_registered_function (up_name, (reg_func_type **) 0)) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_FUNC_ALREADY_REG, "%s", 0,
        name, NP));
    dba_dfree (up_name);
    return SCRERR_FAILURE;
  }
  reg = (reg_func_type *) dba_struct_allocate (sizeof (reg_func_type), __FILE__,
      __LINE__);

  reg->name = up_name;
  reg->func_ptr = func_ptr;
  reg->type = SCR_INT;
  reg->ck_args = default_argnum_enforce;
  if (default_verbose_flag) {
    reg->verbose_ck = 1;
    reg->verbose_type = default_verbose_type;
    reg->verbose_val = default_verbose_val;
  }
  reg->init_env_func = default_init_env_func;

  istat = dba_add_avl_balance_tree (&regfunc_tree, (void *) reg, &inc,
    reg_func_lt, NP);
  if (istat) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_ALLOC_MEM, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_reg_func = reg;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_register_function
    Author:	Tim A. Thompson
    Date:	18-AUG-92

    Revisions:
	12-3-92  -- Converted to use of avl tree and moved bulk of code to
		    dba_reg_func_start().
*/

long dba_register_function (name, func_ptr)
char *name;
void (*func_ptr)();
{
  long istat;

  istat = dba_reg_func_start (name, func_ptr);
  if (istat)
    return (istat);
  istat = dba_reg_func_end ();
  return (istat);
}


/*
    Function:	dba_pseudo_reg_func
    Author:	Tim A. Thompson
    Date:	2-22-93
*/

long dba_pseudo_reg_func (name, func_ptr, mode)
char *name;
void (*func_ptr)();
long mode;
{
  long istat;

  istat = dba_reg_func_start (name, func_ptr);
  if (istat)
    return (istat);
  cur_reg_func->pseudo_reg = 1;
  cur_reg_func->pseudo_mode = mode;
  istat = dba_reg_func_end ();
  return (istat);
}


/*
    Function:	dba_pseudo_reg_func_start
    Author:	Tim A. Thompson
    Date:	3-14-94
*/

long dba_pseudo_reg_func_start (name, func_ptr, mode)
char *name;
void (*func_ptr)();
long mode;
{
  int istat;

  istat = dba_reg_func_start (name, func_ptr);
  if (istat)
    return (istat);
  cur_reg_func->pseudo_reg = 1;
  cur_reg_func->pseudo_mode = mode;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_default_verbose_on
    Author:	Tim A. Thompson
    Date:	07-DEC-92
*/

void dba_reg_default_verbose_on (type, val)
long type, val;
{
  default_verbose_type = type;
  default_verbose_val = val;
  default_verbose_flag = 1;
}


/*
    Function:	dba_reg_default_verbose_off
    Author:	Tim A. Thompson
    Date:	07-DEC-92
*/

void dba_reg_default_verbose_off ()
{
  default_verbose_flag = 0;
}


/*
    Function:	dba_reg_default_argnum_enforce_on
    Author:	Tim A. Thompson
    Date:	07-DEC-92
*/

void dba_reg_default_argnum_enforce_on ()
{
  default_argnum_enforce = 1;
}


/*
    Function:	dba_reg_default_argnum_enforce_off
    Author:	Tim A. Thompson
    Date:	07-DEC-92
*/

void dba_reg_default_argnum_enforce_off ()
{
  default_argnum_enforce = 0;
}


/*
    Function:	dba_reg_default_init_env_check
    Author:	Tim A. Thompson
    Date:	09-DEC-92
*/

void dba_reg_default_init_env_check (func)
long (*func)();
{
  default_init_env_func = func;
}


/*
    Function:	dba_reg_set_func_pascal
    Author:	Tim A. Thompson
    Date:	02-APR-93
*/

long dba_reg_set_func_pascal (flag)
long flag;
{
  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_reg_func->is_pascal = flag;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_func_init_env_check
    Author:	Tim A. Thompson
    Date:	09-DEC-92
*/

long dba_reg_set_func_init_env_check (func)
long (*func)();
{
  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_reg_func->init_env_func = func;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_func_ret_override_func
    Author:	Tim A. Thompson
    Date:	16-DEC-92
*/

long dba_reg_set_func_ret_override_func (func)
void (*func)();
{
  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_reg_func->override_func = func;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_func_end_env_check
    Author:	Tim A. Thompson
    Date:	14-DEC-92
*/

long dba_reg_set_func_end_env_check (func)
long (*func)();
{
  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_reg_func->end_env_func = func;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_func_return_mod_func
    Author:	Tim A. Thompson
    Date:	14-DEC-92
*/

long dba_reg_set_func_return_mod_func (func)
void (*func)();
{
  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_reg_func->return_mod_func = func;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_func_attr
    Author:	Tim A. Thompson
    Date:	03-DEC-92
*/

long dba_reg_set_func_attr (type, us, indir, is_real_c)
long type, us, indir, is_real_c;
{
  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_reg_func->type = type;
  cur_reg_func->us = us;
  cur_reg_func->indir = indir;
  cur_reg_func->is_real_c = is_real_c;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_func_argnum_enforce
    Author:	Tim A. Thompson
    Date:	03-DEC-92
*/

long dba_reg_set_func_argnum_enforce (flag)
long flag;
{
  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_reg_func->ck_args = flag;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_func_var_args
    Author:	Tim A. Thompson
    Date:	03-DEC-92
*/

long dba_reg_set_func_var_args (min, max)
long min, max;
{
  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_reg_func->var_args = min != 0 || max != 0;
  cur_reg_func->min_args = min;
  cur_reg_func->max_args = max;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_func_verbose
    Author:	Tim A. Thompson
    Date:	06-DEC-92
*/

long dba_reg_set_func_verbose (type, val)
long type, val;
{
  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  if (type) {
    cur_reg_func->verbose_ck = 1;
    cur_reg_func->verbose_type = type;
    cur_reg_func->verbose_val = val;
  }
  else
    cur_reg_func->verbose_ck = 0;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_func_option
    Author:	Tim A. Thompson
    Date:	20-JAN-93
*/

long dba_reg_set_func_option (func_ptr)
void (*func_ptr)();
{
  reg_func_type *save_func, *reg;
  int istat;

  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  save_func = cur_reg_func;
  istat = dba_reg_func_end();
  if (istat)
    return istat;
  reg = (reg_func_type *) dba_struct_allocate (sizeof (reg_func_type), __FILE__,
      __LINE__);
  reg->name = save_func->name;
  reg->func_ptr = func_ptr;
  reg->type = SCR_INT;
  reg->ck_args = default_argnum_enforce;
  if (default_verbose_flag) {
    reg->verbose_ck = 1;
    reg->verbose_type = default_verbose_type;
    reg->verbose_val = default_verbose_val;
  }
  reg->init_env_func = default_init_env_func;
  save_func->option = cur_reg_func = reg;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_arg_end
    Author:	Tim A. Thompson
    Date:	07-DEC-92
*/

long dba_reg_arg_end ()
{
  cur_arg = (reg_arg_type *) 0;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_arg_start
    Author:	Tim A. Thompson
    Date:	04-DEC-92
*/

long dba_reg_arg_start (name)
char *name;
{
  long istat;
  reg_arg_type *arg;

  if (!cur_reg_func) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_FUNC, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  if (cur_arg) {
    istat = dba_reg_arg_end ();
    if (istat)
      return istat;
  }
  arg = (reg_arg_type *) dba_struct_allocate (sizeof (reg_arg_type), __FILE__,
      __LINE__);

  arg->name = name;
  if (cur_reg_func->alist_head)
    cur_reg_func->alist_tail->next = arg;
  else
    cur_reg_func->alist_head = arg;
  cur_reg_func->alist_tail = arg;
  cur_reg_func->numargs++;
  cur_arg = arg;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_arg_type
    Author:	Tim A. Thompson
    Date:	07-DEC-92
*/

long dba_reg_set_arg_type (type, type_enforce, us, us_enforce, str_convert)
long type, type_enforce, us, us_enforce, str_convert;
{
  if (!cur_arg) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_ARG, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_arg->type_set = 1;
  cur_arg->type = type;
  cur_arg->type_ck = type_enforce;
  cur_arg->us = us;
  cur_arg->us_ck = us_enforce;
  cur_arg->str_conv = str_convert;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_arg_indir
    Author:	Tim A. Thompson
    Date:	07-DEC-92
*/

long dba_reg_set_arg_indir (indir, enforce, nulls_ok)
long indir, enforce, nulls_ok;
{
  if (!cur_arg) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_ARG, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_arg->indir_set = 1;
  cur_arg->indir = indir;
  cur_arg->indir_ck = enforce;
  cur_arg->nulls_ok = nulls_ok;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_arg_output
    Author:	Tim A. Thompson
    Date:	12-JAN-93
*/

long dba_reg_set_arg_output (flag)
long flag;
{
  if (!cur_arg) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_ARG, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_arg->is_output = flag;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_arg_transform
    Author:	Tim A. Thompson
    Date:	11-DEC-92
*/

long dba_reg_set_arg_transform (func, trans_size, trans_type)
long (*func)();
long trans_size, trans_type;
{
  if (!cur_arg) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_ARG, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_arg->transform_func = func;
  cur_arg->trans_size = trans_size;
  cur_arg->trans_type = trans_type;
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_reg_set_arg_expand
    Author:	Tim A. Thompson
    Date:	14-JAN-93
*/

long dba_reg_set_arg_expand (expand_func)
long (*expand_func)();
{
  if (!cur_arg) {
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_ARG, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_arg->expand_function = expand_func;
  return SCRERR_SUCCESS;
}

/*
    Function:	dba_reg_set_arg_buffered_expand
    Author:	Tim A. Thompson
    Date:	18-JAN-93
*/

long dba_reg_set_arg_buffered_expand (size)
unsigned long size;
{
  if (!cur_arg){
    strcpy (dba_errtxt, dba_get_msg (DBA_E_REG_NO_CURRENT_ARG, NP, 0, NP, NP));
    return SCRERR_FAILURE;
  }
  cur_arg->buf_exp_size = size;
  return SCRERR_SUCCESS;
}


/*
    Function:	dump_reg_tree (STATIC)
    Author:	Tim A. Thompson
    Date:	2-22-93
*/

static void dump_reg_tree (tree)
dba_avl_tree_node *tree;
{
  reg_func_type *reg;
  static int curr_depth;

  curr_depth++;
  tree_depth = curr_depth > tree_depth ? curr_depth : tree_depth;
  if (tree->left)
    dump_reg_tree (tree->left);
  reg = (reg_func_type *) tree->data;
  dba_printf ("%s\n", reg->name);
  if (tree->right)
    dump_reg_tree (tree->right);
  curr_depth--;
}


/*
    Function:	_dba_reg_dump_info
    Author:	Tim A. Thompson
    Date:	2-22-93
*/

void _dba_reg_dump_info()
{
  tree_depth = 0;
  dump_reg_tree (regfunc_tree);
  dba_printf ("\nMaximum Tree Depth = %d\n\n", tree_depth);
}


/*
    Function:	dba_reg_arg_simple
    Author:	Tim A. Thompson
    Date:	2-22-94
*/

int dba_reg_arg_simple(char *name, int type, int indir, int output)
{
  int istat;

  istat = dba_reg_arg_start (name);
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type(type, (indir != 0 && type == SCR_CHAR), 0, 0, 0);
  if (istat)
    return istat;
  istat = dba_reg_set_arg_indir(indir, 1, 0);
  if (istat)
    return istat;
  if (output) {
      if (type != SCR_CHAR) {
          istat = dba_reg_set_arg_output(1);
      }
      else {
          dba_reg_set_arg_buffered_expand(1000);
      }
  }
      
  istat = dba_reg_arg_end ();
  return istat;
}


/*
    Function:	dba_reg_trans_arg_simple
    Author:	Tim A. Thompson
    Date:	4-25-94
*/

int dba_reg_trans_arg_simple (func, name)
long (*func)();
char *name;
{
  int istat;

  istat = dba_reg_arg_start (name);
  if (istat)
    return istat;
  istat = dba_reg_set_arg_transform (func, sizeof (char *), SCR_REG_PTR);
  istat = dba_reg_arg_end ();
  return istat;
}


/*
    Function:	dba_reg_delreg (STATIC)
    Author:	Tim A. Thompson
    Date:	4-19-94

    Revisions:
        4-21-94  -- Don't free the argument name, it's not strdup'ed.
*/

static void dba_reg_delreg (reg)
struct reg_func_type *reg;
{
  int first = 1;
  reg_func_type *nreg;
  reg_arg_type *arg, *narg;

  while (reg) {
    nreg = reg->option;
    if (first)
      dba_dfree (reg->name);
    for (arg=reg->alist_head; arg; arg=narg) {
      narg = arg->next;
      dba_dfree (arg);
    }
    dba_dfree (reg);
    reg = nreg;
    first = 0;
  }
}


/*
    Function:	dba_reg_deltree (STATIC)
    Author:	Tim A. Thompson
    Date:	4-19-94
*/

static void dba_reg_deltree (tree)
dba_avl_tree_node *tree;
{
  if (!tree)
    return;
  dba_reg_deltree (tree->left);
  dba_reg_deltree (tree->right);
  dba_reg_delreg ((reg_func_type *)tree->data);
  dba_dfree (tree);
}


/*
    Function:	dba_exit_reg
    Author:	Tim A. Thompson
    Date:	4-19-94
*/

void dba_exit_reg()
{
  dba_reg_deltree (regfunc_tree);
}
