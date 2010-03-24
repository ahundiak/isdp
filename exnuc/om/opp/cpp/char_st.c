#include <stdio.h>
#include <malloc.h>
#include "char_st.h"

#define CACHING_CHAR_STACKS 1

#if CACHING_CHAR_STACKS
static struct char_stack *free_char_stack = 0;
#endif

static struct char_stack *new_char_stack ()
 {
  struct char_stack *tt;

  if (free_char_stack)
   {
    tt = free_char_stack;
    free_char_stack = free_char_stack->next;
   }
  else
   {
    tt = (struct char_stack *)malloc(sizeof(struct char_stack));
   }
  tt->stack_posit = 0;
  tt->next = 0;
  return (tt);
 }


static void dispose_char_stack (cs)
struct char_stack *cs;
 {
#if CACHING_CHAR_STACKS
  cs->next = free_char_stack;
  free_char_stack = cs;
#else
  free(cs);
#endif
 }


static int pushit (c,cs)
struct char_data c;
struct char_stack *cs;
 {
  if (cs->stack_posit < CHAR_STACK_LEN)
   {
    cs->chars[(cs->stack_posit)++]=c;
    return (1);
   }
  return (0);
 }


static popit(c,cs)
struct char_data *c;
struct char_stack *cs;
 {
  *c = cs->chars[--(cs->stack_posit)];
  if (cs->stack_posit == 0) return (1);
  return (0);
 }


/*doctor on*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
void push_char (c,cs)
struct char_data c;
struct char_stack **cs;
/*
    `push_char' pushes the character c onto the stack cs.
    NULL characters are ignored.
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*doctor off*/
 {
  struct char_stack *tt;

  if (c.ch)
   {
    if (*cs)
     {
      if (!pushit(c,*cs))
       {
        tt = new_char_stack ();
        tt->next = *cs;
        *cs = tt;
        pushit(c,*cs);
       }
     }
    else
     {
      *cs = new_char_stack ();
      pushit(c,*cs);
     }
   }
 }


/*doctor on*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
void push_string (s,cs,fname,ln,pl)
char *s;
struct char_stack **cs;
char *fname;
int ln;
int pl;
/*
    `push_string' pushes the string pointed to by `s' onto the stack cs.
    NULL characters are ignored.
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*doctor off*/
 {
  int i;
  struct char_data cd;

  i = strlen(s);
  cd.filename = fname;
  cd.line_no = ln;
  cd.pol = pl;
  while (i>=0)
   {
    cd.ch = s[i--];
    push_char (cd,cs);
   }
 }


/*doctor on*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
struct char_data pop_char (cs)
struct char_stack **cs;
/*
   `pop_char' returns the top character from the stack `cs'.
    0 is returned on an empty stack.
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*doctor off*/
 {
  struct char_data c;
  struct char_stack *tt;

  if (*cs)
   {
    if (popit(&c,*cs))
     {
      tt = *cs;
      *cs = tt->next;
      dispose_char_stack (tt);
     }
    return (c);
   }
  else
   {
    c.ch = 0;
    return (c);
   }
 }


/*doctor on*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
void char_stack_end ()
/*
   `char_stack_end' is called at the end of the program to free up
   the memory on the free_char_stack.
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*doctor off*/
 {
  struct char_stack *tt;
  struct char_stack *tn;

  tt = free_char_stack;
  free_char_stack = 0;
  while (tt)
   {
    tn = tt->next;
    free (tt);
    tt = tn;
   }
 }


/*doctor on*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
void close_char_stack (cs)
struct char_stack **cs;
/*
   `close_char_stack' emptys the char_stack `cs'.
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*doctor off*/
 {
  struct char_stack *tt;
  struct char_stack *tn;

  tt = *cs;
  *cs = 0;
  while (tt)
   {
    tn = tt->next;
    dispose_char_stack(tt);
    tt = tn;
   }
 }


/*doctor on*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
void dump_stack (cs)
struct char_stack *cs;
/*
   `dump_stack' is a debug routine which dumps out the entire contents
   of the character stack.
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*doctor off*/
 {
  int i;

  printf ("<bos>\n");
  while (cs)
   {
    for (i = cs->stack_posit - 1; i >= 0; i--)
      printf("%c",cs->chars[i].ch);
    cs = cs->next;
   }
  printf ("<eos>\n");
 }
