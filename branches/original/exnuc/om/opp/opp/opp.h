
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/
/* opp.h - main function for opp					*/
/*									*/
/* Object PreProcessor - opp						*/
/* Paul L. Hammond							*/
/* March 21, 1986							*/
/*									*/
/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
#ifndef OPP_INCLUDED
#define OPP_INCLUDED

#include <stdio.h>
#include "class.h"
#include "kutil.h"

extern unsigned int opp_version;

extern int opping_for_discos; /* boolean */

extern int keep_mode; /* flag set if incomplete output file is to be kept */
extern int filter_duplicate_includes;
extern int emit_lines;

extern FILE *oppout;
extern int outlines;
extern char oppout_name[256];

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* opp.c */
int different_files __((FILE *f1, FILE *f2));
int discos_get_class __((char *class, int outgen, struct opp_class_def **p_class));

/* functions.c */
void verify_function __((identifier_ptr *f, identifier_ptr *p));
void end_function __((identifier_ptr f));
void declaring_function_parameter __((struct Type_Info type, identifier_ptr dcltr_list));

/* initgen.c */
int find_components __((identifier_ptr cl, carrier_ptr *p_list));
void Ideclare_component_ids __((identifier_ptr cl));
void declare_component_ids __((identifier_ptr cl));
void dump_total_instance __((identifier_ptr cl));
int class_overridden __((carrier_ptr override_list, char *classname));
int dump_and_count_varrays __((identifier_ptr cl));
int count_varrays __((struct opp_class_def *p_classdef));
void generate_class_init __((struct opp_class_def *classdef));

/* keval.c */
int evaluate_ptree_exp __((struct pnode *pe));

/* kgti.c */
struct Type_Info gen_typeinfo __((struct pnode_decl_specifier *pds));
identifier_ptr gen_dcltr_list __((struct pnode_list_init_dcltr *plid));
void distribute_type_info __((struct Type_Info ti, identifier_ptr dl));

/* kpster.c */
void pster_dump_item __((struct pnode *tt));
void pster_dump_ptree __((struct pnode *tt));

/* sizeof.c */
int do_the_sizeof __((struct Type_Info ti));

#if defined(__cplusplus)
}
#endif

#define MAX_INCLUDE_PATHS 64

#endif /* OPP_INCLUDED */
/* End opp.h */
