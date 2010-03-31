#ifndef _PWattrib_include
#define _PWattrib_include

/*
 * Structure which holds a user defined attribute. Many attributes can be held
 * within this structure, as this defines a singly-linked list. Typically,
 * other data-structures will have a pointer to such a list and the
 * management of it (creation, access, etc) is done strictly through
 * functions associated with this data-structure.
 */

enum PWattribtype 
{
  PWattrib_unknown,
  PWattrib_integer, 
  PWattrib_double, 
  PWattrib_pointer
}; 

union PWattribdata                
{
  int int_attrib;                  /*
                                    * The attribute is an int value. This can
                                    * be used to store things like ids, indices
                                    */

  double double_attrib;            /*
                                    * The attribute is a double value. This can
                                    * be used to store things like distances,
                                    * etc
                                    */

  struct 
  {
    char *p_attrib;
    void (*free_attrib)(char *);
    char *(*copy_attrib)(char *);
  } gen_attrib;                    /*
                                    * Stores a pointer to memory that can
                                    * point to a user-defined type. At 
                                    * creation time, the caller must also
                                    * provide a function to free the data (can
                                    * be NULL in which case no freeing is
                                    * attempted), and a function to copy the
                                    * data (can be NULL in which case only the
                                    * pointer is copied and not it's contents).
                                    * Both the functions will be called with a
                                    * single argument - the p_attrib pointer.
                                    * The latter returns the pointer to the 
                                    * new memory that contains the copy.
                                    */
};
  
struct PWattrib
{
  unsigned int ident;              /*
                                    * An identifier that uniquely identifies
                                    * this attribute to the user. Using this
                                    * the user can locate the attribute in this
                                    * list. 
                                    */

  enum PWattribtype attribtype;    /*
                                    * An enumerator tells the type of data
                                    * that is stored within this attribute.
                                    */

  union PWattribdata attrib;       /*
                                    * The actual attribute. This could be one
                                    * of 3 kinds - integer, double and a 
                                    * pointer to arbitrary data. The type is
                                    * dictated by the enum above.
                                    */

  struct PWattrib *p_next;         /*
                                    * Pointer to the next attribute in the 
                                    * list. Being adjacent or next has no
                                    * semantic meaning.
                                    */
};


/*------------ PROTOTYPES OF FUNCTIONS OPERATING ON THESE STRUCTURES --------*/

#ifndef _attrib_proto_h
#include "PWapi/attrib.h"
#endif

#endif
