/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* symtab.h -	Declarations for generic symbol table.			*/
/*	     	Works with symtab.c					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 19, 1986							*/
/*									*/
/* October 31, 1986 - modified to work with object oriented symbol table*/
/* December 12, 1986 - object scheme reorganized.			*/
/*									*/
/* This package handles symbol table operations.			*/
/*									*/
/* Assumptions :							*/
/*  All actual symbol records are allocated and deallocated by the	*/
/*  caller.  These symbols are entered, looked up etc. by this module.	*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef SYMTAB_INCLUDED
#define SYMTAB_INCLUDED
#include <stdio.h> /* from stdio import FILE; */

typedef struct symbol *symbol_ptr;

struct symbol
 {
  char	 	*name;		/* name of this field */
  symbol_ptr	next;		/* link to next item in symbol table */
  short		level;		/* declaration level */
  short		hash_value;	/* For enter_prehashed and remove */
 };

struct symtab_class
 {
  void (*delete) (/* symtab_ptr st; void (*dealloc)(symbol_ptr s) */);
#define delete_symbol_table(st, dealloc) ((*st)->delete ((st), (dealloc)))
  void (*process) (/* symtab_ptr st; void (*process)(symbol_ptr s) */);
#define process_symbol_table(st, proc) ((*st)->process ((st),(proc)))
  void (*process_local) (/* st, proc */);
#define process_local_symbols(st, proc) ((*st)->process_local((st),(proc)))

  void (*increment_level) (/*st*/);
#define increment_symbol_level(st) ((*st)->increment_level((st)))
  void (*decrement_level) (/*symtab_ptr st;void (*proc)(symbol_ptr s) */);
#define decrement_symbol_level(st, dealloc)\
	 ((*st)->decrement_level ((st), (dealloc)))

  void (*enter) (/* symtab_ptr st; symbol_ptr s */);
#define enter_symbol(st, s) ((*st)->enter ((st), (s)))
  void (*enter_prehashed) (/* symtab_ptr st; symbol_ptr s */);
#define enter_prehashed_symbol(st, s) ((*st)->enter_prehashed ((st), (s)))

  symbol_ptr (*lookup)(/* symtab_ptr st; char *name */);
#define lookup_symbol(st, name) ((*st)->lookup ((st), (name)))
  symbol_ptr (*lookup_local)(/* symtab_ptr st; char *name */);
#define lookup_local_symbol(st, name) ((*st)->lookup_local ((st), (name)))

  void (*remove) (/* symtab_ptr st; symbol_ptr s */);
#define remove_symbol(st, s) ((*st)->remove ((st), (s)))

  int (*level) (/* symtab_ptr st */);
#define symbol_table_level(st) ((*st)->level (st))
  void (*write_protect) (/* symtab_ptr st */);
#define symtab_write_protect(st) ((*st)->write_protect (st))
  void (*write_enable) (/* symtab_ptr st */);
#define symtab_write_enable(st) ((*st)->write_enable (st))
 }; /* struct symbol_table_class */

typedef struct symtab_class **symtab_ptr;

#endif /* SYMTAB_INCLUDED */
/* End symtab.h */
