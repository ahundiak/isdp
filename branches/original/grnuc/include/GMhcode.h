#ifndef GMhcode_include
#define   GMhcode_include
/*
  File dependencies : none
*/
#ifndef TRUE
#define TRUE  1
#endif

#ifndef FALSE
#define FALSE 0
#endif
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             Default values                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define GMH_NULL_INDEX  0xffff /* The null index                              */
#define GMH_DEF_MODULO      97 /* Default modulo to select the key            */
#define GMH_DEF_SIZE       100 /* Default size to allocate the elements       */
#define GMH_DEF_KEY_SIZE sizeof(short) /* Default size of a key               */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    Definition of the hcode structure                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct GMhcode                 /* List Header                                 */
  {
  unsigned short *a_head;      /* Pointer to the list header                  */
  char   *l_key;               /* List of keys                                */
  unsigned short *l_next;      /* List of link (next element)                 */
  char   *l_content;           /* content of the element                      */
  int    (*f_cmp_key)();       /* function to compare the keys                */
  char   *p_fct_info;          /* additional information for the fct          */
  int    (*f_hash)();          /* function to hash the element                */
  unsigned short nb_max_elmt;  /* Maximum number of elements in the table     */
  unsigned short content_size; /* Size of the element                         */
  unsigned short key_size;     /* Size of the key                             */
  unsigned short step_size;    /* Step size to reallocate the table           */
  unsigned short cur_elmt;     /* Current element of the table                */
  unsigned short modulo;       /* Modulo of hcode's selection                 */
  unsigned short prev_elmt;    /* Index of the prev. element in the list      */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#endif
