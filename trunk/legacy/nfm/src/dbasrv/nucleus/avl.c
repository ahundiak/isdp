/* $Revision: 1.1 $ */
#include "dba.ext"
#include "dmalloc.def"
#include "screrr.def"
#include "script.def"

/*
    Function:	dba_reset_balances (STATIC)
    Author:	Tim A. Thompson
    Date:	30-MAR-92
*/

static void dba_reset_balances (q, t, p)
dba_avl_tree_node *q, *t, *p;
{
  if (t->bal == -1)
    p->bal = 1;
  else
    p->bal = 0;
  if (t->bal == 1)
    q->bal = -1;
  else
    q->bal = 0;
}


/*
    Function:	dba_rotate_right (STATIC)
    Author:	Tim A. Thompson
    Date:	30-MAR-92

    Revisions:
	8-13-92  -- Added code for AVL deletes.
*/

static void dba_rotate_right (t, s, st)
dba_avl_tree_node **t, **st;
genstacktype *s;
{
  dba_avl_tree_node *q;

  q = (*t)->left;
  (*t)->left = q->right;
  q->right = *t;
  *t = q;

  if (s) {
    if (!s->size)
      *st = *t;
    else
    {
      q = (dba_avl_tree_node *) dba_gen_pop (s);
      if (q->right == (*t)->right)
        q->right = *t;
      else
        q->left = *t;
      dba_gen_push (s, q);
    }
  }
}


/*
    Function:	dba_rotate_left (STATIC)
    Author:	Tim A. Thompson
    Date:	30-MAR-92

    Revisions:
	8-13-92  -- Added code for AVL deletes.
*/

static void dba_rotate_left (t, s, st)
dba_avl_tree_node **t, **st;
genstacktype *s;
{
  dba_avl_tree_node *q;

  q = (*t)->right;
  (*t)->right = q->left;
  q->left = *t;
  *t = q;

  if (s) {
    if (!s->size)
      *st = *t;
    else
    {
      q = (dba_avl_tree_node *) dba_gen_pop (s);
      if (q->right == (*t)->left)
        q->right = *t;
      else
        q->left = *t;
      dba_gen_push (s, q);
    }
  }
}


/*
    Function:	dba_double_rotate_right (STATIC)
    Author:	Tim A. Thompson
    Date:	30-MAR-92
*/

static void dba_double_rotate_right (t, s, st)
dba_avl_tree_node **t, **st;
genstacktype *s;
{
  dba_rotate_left (&(*t)->left, s, st);
  dba_rotate_right (t, s, st);
}


/*
    Function:	dba_double_rotate_left (STATIC)
    Author:	Tim A. Thompson
    Date:	30-MAR-92
*/

static void dba_double_rotate_left (t, s, st)
dba_avl_tree_node **t, **st;
genstacktype *s;
{
  dba_rotate_right (&(*t)->right, s, st);
  dba_rotate_left (t, s, st);
}


/*
    Function:	dba_add_avl_balance_tree
    Author:	Tim A. Thompson
    Date:	23-MAR-92
*/

long dba_add_avl_balance_tree (t, newval, inc, rel_lt_func, extra)
dba_avl_tree_node **t;
void *newval;
long *inc;
long (*rel_lt_func)();
void *extra;
{
  long istat;
  dba_avl_tree_node *q;

  if (!*t) {
    *t = (dba_avl_tree_node *) dba_struct_allocate (sizeof(dba_avl_tree_node),
        __FILE__, __LINE__);
    if (!*t)
      return SCRERR_NO_MEMORY;
    (*t)->data = newval;
    *inc = 1;
  }
  else
  {
    if ((*rel_lt_func)(newval, (*t)->data, extra)) {
      istat = dba_add_avl_balance_tree
          (&(*t)->left, newval, inc, rel_lt_func, extra);
      if (istat)
        return istat;
      if (*inc) {
        switch ((*t)->bal) {
          case 0:
            (*t)->bal = -1;
            break;
          case 1:
            (*t)->bal = 0;
            *inc = 0;
            break;
          case -1:
            q = (*t)->left;
            if ((*rel_lt_func)(newval, q->data, extra)) {
              dba_rotate_right (t, (genstacktype *)0, (dba_avl_tree_node **)0);
              (*t)->right->bal = 0;
            }
            else
            {
              dba_double_rotate_right (t, (genstacktype *) 0,
                  (dba_avl_tree_node **) 0);
              dba_reset_balances (q, *t, (*t)->right);
            }
            (*t)->bal = 0;
            *inc = 0;
            break;
        }
      }
    }
    else
    {
      istat = dba_add_avl_balance_tree
          (&(*t)->right, newval, inc, rel_lt_func, extra);
      if (istat)
        return istat;
      if (*inc) {
        switch ((*t)->bal) {
          case 0:
            (*t)->bal = 1;
            break;
          case -1:
            (*t)->bal = 0;
            *inc = 0;
            break;
          case 1:
            q = (*t)->right;
            if ((*rel_lt_func)(q->data, newval, extra)) {
              dba_rotate_left (t, (genstacktype *) 0, (dba_avl_tree_node **) 0);
              (*t)->left->bal = 0;
            }
            else
            {
              dba_double_rotate_left (t, (genstacktype *) 0,
                  (dba_avl_tree_node **) 0);
              dba_reset_balances ((*t)->left, *t, q);
            }
            (*t)->bal = 0;
            *inc = 0;
            break;
        }
      }
    }
  }
  return SCRERR_SUCCESS;
}


/*
    Function:	dba_smm_avl_delitem (STATIC)
    Author:	Tim A. Thompson
    Date:	13-AUG-92
*/

static void dba_smm_avl_delitem (s, t, replace_item, success)
genstacktype *s;
dba_avl_tree_node **t, **replace_item;
long *success;
{
  if (*t) {
    dba_gen_push (s, *t);
    if (!(*t)->right) {
      *replace_item = *t;
      *success = 1;
    }
    else
      dba_smm_avl_delitem (s, &(*t)->right, replace_item, success);
  }
  else
    *success = 0;
}


#ifdef _DOIT_
/*
    Function:	dba_smm_avl_delete (STATIC)
    Author:	Tim A. Thompson
    Date:	13-AUG-92
*/

static void dba_smm_avl_delete (s, t, deldata, lessthan, success, extra,
    data_size)
genstacktype *s;
dba_avl_tree_node **t;
long (*lessthan)(), *success;
void *deldata, *extra;
unsigned long data_size;
{
  dba_avl_tree_node *replace;

  if ((*lessthan)(deldata, (*t)->data, extra)) {
    dba_gen_push (s, *t);
    dba_smm_avl_delete (s, &(*t)->left, deldata, lessthan, success,
        extra, data_size);
  }
  else if ((*lessthan)((*t)->data, deldata, extra)) {
    dba_gen_push (s, *t);
    dba_smm_avl_delete (s, &(*t)->right, deldata, lessthan, success,
        extra, data_size);
  }
  else
  {
    dba_gen_push (s, *t);
    dba_smm_avl_delitem (s, &(*t)->left, &replace, success);
/*
    dba_struct_deallocate ((*t)->data, data_size);
*/
    if ((*t)->left) {
      if (*success) {
        (*t)->data = replace->data;
      }
      else
      {
        while ((*t)->left) {
          (*t)->data = (*t)->left->data;
          *t = (*t)->left;
          dba_gen_push (s, *t);
        }
      }
    }
    else
    {
      while ((*t)->right) {
        (*t)->data = (*t)->right->data;
        *t = (*t)->right;
        dba_gen_push (s, *t);
      }
    }
    *success = 1;
  }
}


/*
    Function:	dba_smm_avl_delete_avl (STATIC)
    Author:	Tim A. Thompson
    Date:	13-AUG-92
*/

static void dba_smm_avl_delete_avl (t, s)
dba_avl_tree_node **t;
genstacktype *s;
{
  dba_avl_tree_node *current, *child, *bereft;
  long balancing, wasleft;
extern functiontype *dba_global_function;
  child = dba_gen_pop (s);
  if (!s->size) {
    *t = 0;
  }
  else
  {
    current = dba_gen_pop (s);
    bereft = current;
    wasleft = child == bereft->left;
    balancing = 1;
    while (balancing) {
      if (!current->bal) {
        if (child == current->left)
          current->bal = 1;
        else
          current->bal = -1;
        balancing = 0;
      }
      else if (current->bal == 1 && child == current->right ||
          current->bal == -1 && child == current->left)
        current->bal = 0;
      else if (current->bal == 1 && child == current->left)
      {
        switch (current->right->bal) {
          case 0:
            dba_rotate_left (&current, s, t);
            current->bal = -1;
            current->left->bal = 1;
            balancing = 0;
            break;
          case 1:
            dba_rotate_left (&current, s, t);
            current->bal = 0;
            current->left->bal = 0;
            break;
          case -1:
            dba_double_rotate_left (&current, s, t);
            switch (current->bal) {
              case 0:
                current->left->bal = 0;
                current->right->bal = 0;
                break;
              case 1:
                current->left->bal = -1;
                current->right->bal = 0;
                break;
              case -1:
                current->left->bal = 0;
                current->right->bal = 1;
                break;
            }
            current->bal = 0;
            break;
        }
      }
      else
      {
        switch (current->left->bal) {
          case 0:
            dba_rotate_right (&current, s, t);
            current->bal = 1;
            current->right->bal = -1;
            balancing = 0;
            break;
          case -1:
            dba_rotate_right (&current, s, t);
            current->bal = 0;
            current->right->bal = 0;
            break;
          case 1:
            dba_double_rotate_right (&current, s, t);
            switch (current->bal) {
              case 0:
                current->left->bal = 0;
                current->right->bal = 0;
                break;
              case -1:
                current->left->bal = 0;
                current->right->bal = 1;
                break;
              case 1:
                current->left->bal = -1;
                current->right->bal = 0;
                break;
            }
            current->bal = 0;
            break;
        }
      }
      if (balancing)
        if (!s->size)
          balancing = 0;
        else
        {
          child = current;
          current = dba_gen_pop (s);
        }
    }
printf ("DISPOSE\n");
printtree (*t, &dba_global_function);
    if (wasleft) {
/*
      dba_struct_deallocate (bereft->left->data, data_size);
*/
      dba_struct_deallocate (bereft->left, sizeof (dba_avl_tree_node));
      bereft->left = (dba_avl_tree_node *) 0;
printf ("DONE1\n");
printtree (*t, &dba_global_function);
    }
    else
    {
/*
      dba_struct_deallocate (bereft->right->data, data_size);
*/
      dba_struct_deallocate (bereft->right, sizeof (dba_avl_tree_node));
      bereft->right = (dba_avl_tree_node *) 0;
printf ("DONE2\n");
printtree (*t, &dba_global_function);
    }
  }
}


/*
    Function:	dba_delete_avl_balance_tree
    Author:	Tim A. Thompson
    Date:	13-AUG-92
*/

long dba_delete_avl_balance_tree (t, deldata, lessthan, extra, data_size)
dba_avl_tree_node **t;
void *deldata;
void *extra;
long (*lessthan)();
unsigned long data_size;
{
  long success;
  genstacktype *s;
extern functiontype *dba_global_function;
  s = (genstacktype *) dba_struct_allocate (sizeof (genstacktype), __FILE__,
      __LINE__);
  dba_smm_avl_delete (s, t, deldata, lessthan, &success, extra, data_size);
printf ("INSIDE\n");
printtree (*t, &dba_global_function);
  dba_smm_avl_delete_avl (t, s);
}
#endif
