#ifndef GMdef_include
#define   GMdef_include
/*
  File dependencies : none
*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*            Internal attributes for objects in a selected graph             */
/*   These attributes define the position of the node (by a binary addition   */
/*    of the following types)                                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define GM_INIT    0x0080 /* Root elements of the graph : the element is in   */
                          /* the p_root list of the gm$get_graph call	      */

#define GM_ROOT    0x0001 /* Root elements of the graph : the element is in   */
                          /* the p_root list of the gm$get_graph call	      */

#define GM_TIP     0x0002 /* Tip elements of the graph  : the element is in   */
                          /* the p_tip list of the gm$get_graph call	      */

#define GM_BODY    0x0004 /* Body elements of the graph : the element has     */
                          /* parents in the selected graph                    */

#define GM_LEAF    0x0008 /* Elements without children                        */

#define GM_EXTERN  0x0010 /* Extern elements of the graph : elements which    */
                          /* are direct ancestors of body elements and are not*/
                          /* successors of the p_root elements. Such objects  */
                          /* can only be obtained if the function get_ancestor*/
                          /* is provided in the gm$get_graph call.            */

#define GM_MINIMAL 0x0020 /* elements which are successor of root, ancestor   */
                          /* of tips                                          */

#define GM_LOOP    0x0040 /* Element belonging to a loop                      */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                    Modes to ask an object from the graph                   */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define GM_FROM_BEGIN 0x00   /* Search begins from the first elmt of the graph*/

#define GM_FROM_END   0x01   /* Search begins from the last elmt of the graph */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                       Modes for the broadcast operation                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define GM_REVERSE 0x00   /* Fct. is sent to children before root "down up"   */

#define GM_ORDER   0x01   /* Fct. is sent to root before children "up down"   */

#define GM_TRIGGER 0x02   /* The trigger system is active during the broadcast*/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                 Possible values for the type of a request                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define GM_REQ_NULL       0x00  /* Null modification                          */
#define GM_REQ_CONNECT    0x01  /* Element connected to the graph             */
#define GM_REQ_DISCONNECT 0x02  /* Element disconnected from the graph        */
#define GM_REQ_DELETE     0x04  /* Element deleted                            */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#endif
