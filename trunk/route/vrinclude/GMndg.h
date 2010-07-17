#eofifdef GMndg_include
#define   GMndg_include
/*
  File dependencies :

  GMhcode.h
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       Definition for a non directed graph                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define DEF_MODULO    97      /* Default modulo for the hash function         */
#define DEF_SIZE      100     /* Default size of the list                     */
#define VRMAX_CONNEX  20      /* Maximum connexions on an element             */

struct  GMndgraph             /* Structure of an non directed graph           */
  {
  struct GMhcode hcode;       /* Pointer to the hcode table of all the nodes  */
  int    (*f_get_connex)();   /* Function to get the connexions               */
  char   *p_connex_info;      /* External information for the function        */
  short  type;                /* Type limiting the graph                      */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

