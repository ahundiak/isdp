#ifndef GRAPH_H
#define GRAPH_H
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                 Types for the broadcast state of the graph                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define  G_NOT_BROAD    0x00   /* The graph is not broadcasted                */
#define  G_BROADCAST    0x01   /* A message is actually broadcasted           */
#define  G_ABORT_BROAD  0x02   /* The broadcast of the message must abort     */

/* 
 Definition of the graph :
 -----------------------
*/

struct broad_info
  {
  OM_S_MESSAGE   *msg;      /* Broacasted message                             */
  int            acc_type;  /* Accepted type of the list to broadcast         */
  int            rej_type;  /* Rejected type of the list to broadcast         */
  OM_E_WRT_FLAG  mode;      /* Mode to send the message                       */
  unsigned short current;   /* Index of the current object                    */
  char           ex_acc;    /* Exclusive accept. for the accept type          */
  char           ex_rej;    /* Exclusive accept. for the reject type          */
  char           state;     /* State of the broadcast                         */
};

struct graph
  {
  struct hcode_head *p_hcode;/* Pointer to the hcode table of all the nodes   */
  unsigned short *l_parent;  /* List of all the parents of the graph          */
  unsigned short *l_ord_elmt;/* Ordered list of the nodes of the graph        */

  struct broad_info *p_broad;/* Pointer about the current broadcast info.     */

  struct NDcp_list *list_copy; /* List of all the copied objects             */
  unsigned short copy_osnum; /* Object number of the graph                    */

  unsigned short nb_root;    /* Number of root elements in the graph          */
  unsigned short nb_tip;     /* Number of tip elements in the graph           */
  unsigned short nb_ext;     /* Number of extern elements in the graph        */
  unsigned short nb_elmt;    /* Number of elements in the ordered list        */
  unsigned short attribute;  /* Attribute of the requested graph              */
  unsigned short osnum;      /* Object number of the graph                    */

  char     req_clear;        /* flag = TRUE if the graph must be clear        */
};

  
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#endif
