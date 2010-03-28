#ifndef GM_include
#define   GM_include

#include "GMhcode.h"
#include "GMlist.h"
/*
  File dependencies :

  OMminimum.h
  EXgrid.h
*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       Definition of a graph structure                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct GMbr_info
  {
  int          (*select_fct)();/* Select function                             */
  char          *p_select_arg; /* Arguments of the select function            */
  int           (*broad_fct)();/* broadcast function                          */
  char          *p_broad_arg;  /* Arguments of the broadcast function         */
  char          broad_mode;    /* Broadcast mode                              */
  char          state;         /* State of the broadcast                      */
};

struct GMgraph
  {
  struct GMhcode   *p_hcode;   /* Pointer to the hcode table of all the nodes */
  unsigned short   *l_parent;  /* List of all the parents of the graph        */
  unsigned short   *l_ord_elmt;/* Ordered list of the nodes of the graph      */
  struct GMbr_info *p_broad;   /* Pointer about the current broadcast info.   */
  int           (*f_get_anc)();/* Function to get the ancestors               */
  char             *p_arg_anc; /* Argument for the function f_get_anc         */
  int           (*f_get_suc)();/* Function to get the successors              */
  char             *p_arg_suc; /* Argument for the function f_get_suc         */
  char             *p_grsyst;  /* Pointer to the eventual graph system        */
  int              s_lparent;  /* Number of indexes in l_parent list          */
  unsigned short   nb_root;    /* Number of root elements in the graph        */
  unsigned short   nb_tip;     /* Number of tip elements in the graph         */
  unsigned short   nb_elmt;    /* Number of elements in the ordered list      */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         definition of the graph system                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct GMsyst                   /* Graph system definition                    */
  {
  struct GMlist graphs;         /* List of the graphs of the system           */
  struct GMlist requests;       /* List of the requests of the graphs         */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#endif
