#ifndef HCODE_H
#define HCODE_H
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             STATUS Variables                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define ELMT_A_EXIST     2   /* The element already exist in the list         */
#define FALSE            0   /* The response of the function is FALSE         */
#define TRUE             1   /* The response of the function is TRUE          */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             Default values                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define NULL_INDEX  0xffff   /* The null index                                */
#define DEFAULT_MODULO  97   /* Default modulo to select the key              */
#define DEFAULT_SIZE   100   /* Default size to allocate the elements         */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    Definition of the hcode structure                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct list_elmt                    /* element of the list                    */
  {
  struct elmt_type  contain;        /* Contain of the element                 */
  unsigned   short  next;           /* Index of the next element              */
};

struct hcode_head                   /* List Header                            */
  {
  struct   list_elmt  *a_elmt;      /* Pointer to the list of the elements    */
  unsigned short      nb_max_elmt;  /* Maximum number of elements in the table*/
  unsigned short      step_size;    /* Step size to reallocate the table      */
  unsigned short      cur_elmt;     /* Current element of the table           */
  unsigned short      modulo;       /* Modulo de la selection du h_code       */
  unsigned short      prev_elmt;    /* Index of the prev. element in the list */
  unsigned short      point_elmt;   /* Index of the pointed element           */
  unsigned short      *a_head;      /* Pointer to the list header             */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#endif
