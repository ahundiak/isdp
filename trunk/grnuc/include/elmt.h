#ifndef ELMT_H
#define ELMT_H

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*          Definition of the structure of an element for a graph             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct elmt_graph
  {
  unsigned short ind_parent;/* Index of the first parent                      */
  unsigned short nb_parent; /* Number of parents of the element               */
  unsigned short nb_virt_parent; /* Number of VIRTUAL parents		      */
  unsigned short level;     /* Level in the graph                             */
  unsigned short attribute; /* Attribute of the element                       */
};

/*
 Different types for the level :
 -----------------------------
*/

#define  MIN_LEVEL  0       /* Minimum level for a node in the graph          */
#define  UNKNOWN    0xffff  /* Unknown level for a node in the graph          */

/*
 Internal types for the attribute :
 ----------------------------------
*/

#define NULL_ATTR 0x0000    /* Null attribute for an element                  */
#define ND_BROAD  0x2000    /* Elements already broadcasted                   */
#define ND_HEAD   0x4000    /* Inductive head elements of the graph           */
#define ND_LOOP   0x8000    /* Element with a child which is an ancestor      */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                     Definition of the type of the element                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

struct elmt_type
  {
  /*--------------------------------------------------------------------------*/
  unsigned long  int  key;  /* Key to select the element                      */
  /*--------------------------------------------------------------------------*/
  union
    {
    struct elmt_graph elmt; /* Element of a graph                             */
    unsigned long int copy; /* objid of the copy                              */
  }data;
  };

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#endif
