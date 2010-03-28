#define AS_DEBUG
#ifndef asdeb_include
#define asdeb_include

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       Definition of the level options                      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define BEG_END               0x01 /* the BEGIN and END statements            */
#define CONTENT               0x02 /* the Content of the src code             */

#define LEVEL_0             FALSE  /* Without debug traces                    */
#define LEVEL_1           BEG_END  /* Only the BEGIN and END statements       */
#define LEVEL_2           CONTENT  /* Only the Comments                       */
#define LEVEL_3   BEG_END|CONTENT  /* BEGIN END + Comments are printed        */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             Key words for the files                        */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define CLASS   "CLASS"            /* Delimiter for classes                   */
#define D_LEVEL "LEVEL"            /* Delimiter for the levels                */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             Default values                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define NULL_INDEX    0xffff /* The null index                                */
#define DEFAULT_NB_CLASS  2  /* Default nb_class to select the key            */
#define DEFAULT_SIZE      1  /* Default size to allocate the methods          */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    Definition of the deb_head structure                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define LENGTH_MAX_STRING 40        /* Maximum length of a string             */

struct d_name                       /* Name of a class or a method            */
  {
  char *reg_name;                   /* Regular expression of a name           */
  char name[LENGTH_MAX_STRING];     /* Definition of the regular expression   */
};

struct list_method                  /* method of the list                     */
  {
  unsigned   short    next;         /* Index of the next method               */
  struct     d_name   method_name;  /* Content of the method                  */
};

struct list_class                   /* class of the list                      */
  {
  unsigned   short    list_method;  /* Index of the next method               */
  char       level;                 /* Level of the debug operation           */
  struct     d_name   class_name;   /* Content of the class                   */
};

struct deb_head                     /* List Header                            */
  {
  char                default_level;/* Default level selected                 */
  unsigned short      nb_max_method;/* Maximum number of methods in the table */
  unsigned short      step_size;    /* Step size to reallocate the table      */
  unsigned short      cur_method;   /* Current method of the table            */
  unsigned short      nb_class;     /* nb_class de la selection du h_code     */
  unsigned short      nb_max_class; /* nb_class maximum de la selection       */
  unsigned short      prev_method;  /* Index of the prev. method in the list  */
  unsigned short      point_method; /* Index of the pointed method            */
  struct  list_class  *a_class;     /* Pointer to the list header             */
  struct  list_method *a_method;    /* Pointer to the list of the methods     */
};

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            GLOBAL VARIABLE                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

extern   struct deb_head Debug_Head; /* Pointer to the debug structure        */

#endif

