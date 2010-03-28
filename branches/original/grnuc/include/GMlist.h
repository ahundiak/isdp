#ifndef GMlist_include
#define   GMlist_include
/*
  File dependencies : none
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    Definition of the list structure                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct GMlist                      /* List Structure                          */
  {
  char           *elmt;            /* List of elements                        */
  int            (*funct)();       /* Equality function for the content       */
  char           *p_fct_info;      /* Pointer to additional function info     */
  unsigned short step_size;        /* Step size for the reallocation of size  */
  unsigned short nb_max_elmt;      /* Number maximum of elements in the list  */
  unsigned short current_ind;      /* current index                           */
  unsigned short nb_elmt;          /* Number of elements in the list          */
  unsigned short elmt_size;        /* Size of an element of the list          */
};
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#endif
