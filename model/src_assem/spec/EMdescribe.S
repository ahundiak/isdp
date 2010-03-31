/*
 * Class :
 *
 *      EMdescribe
 *
 * Abstract :
 *
 *      This class provides way to describe an object with attributes.
 *      Any object which is subclassed from GRnotify may be described by
 *      this class. Attributes that are used to describe the object are
 *      expression objects which may have a type and description associated
 *      with them. In addition to expression objects other objects that
 *      the application deems appropriate to the description.
 *
 * History :
 *
 *      Jay Wallingford     6/16/93  Creation date.
 *      Gang                7/4/94   Added EMupdate_display.
 *
 */
class specification EMdescribe (1:1) of GRlistener, DIrectory;

#include <OMerrordef.h>
#include <gr.h>
#include <assemdef.h>
#include <assem.h>

typedef struct EMmemb_info_st
{
    IGRint  type;
    IGRuint desc_index;
} EMmemb_info;
    
instance EMdescribe
{
    IGRuint                   props;     /* Properties of describe object. */
    variable EMmemb_info      info[];    /* Member description and type. */ 
    variable IGRchar          descs[];   /* Description strings. */
    channel {(many_to_many,
              rel_ordered,
              initial = 0,
              increment = 1)} to_notify; /* Described object. */
};

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMconstruct                                                      |
 |                                                                           |
 | This method constructs the EMdescribe object. The class_attr structure    |
 | for this object is EMdescribe_class_attr defined in assem.h.              |
 |                                                                           |
 | Input:   struct GRmd_env * mod_env    Module environment to construct in. |
 |          IGRchar         * class_attr Class attrs, EMdescribe_class_attr. |
 |                                                                           |
 | Output:  IGRlong         * msg        Return code.                        |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |          ASM_E_DIRCREATE Couldn't create directory.                       |
 |          ASM_E_DIRADD    Error adding object to directory.                |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/17/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMconstruct (IGRlong         * msg; 
                     struct GRmd_env * mod_env;
                     IGRchar         * class_attr);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_props                                                      |
 |                                                                           |
 | This message returns all properties of the describe object.               |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRuint *     props       Properties of object.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_props (IGRlong * msg; IGRuint * props);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMset_props                                                      |
 |                                                                           |
 | This message will set all the properties of the describe object.          |
 |                                                                           |
 | Input :  IGRuint       props       Properties of object                   |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMset_props (IGRlong * msg; IGRuint  props);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_type                                                       |
 |                                                                           |
 | This message returns the type of the describe object. Possible types are  |
 | as follows:                                                               |
 |                                                                           |
 |      EM_DESCRIPTION      - General EMdescribe object.                     |
 |      EM_FILE_PART        - Local part which defines file as part.         |
 |      EM_LOCAL_PART       - Local part which subdivides file part.         |
 |      EM_REFERENCE_PART   - Cached part which is instance of file part.    |
 |      EM_GRAPHIC_PART     - Cached part which defines graphic as part.     |
 |      EM_NONGRAPHIC_PART  - Cahced part which flags presence of part/inst. |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRint  *     type        Type of object.                        |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 | Note: There is no cooresponding EMset_type since it's not possible to     |
 |       transform a part of one type to a part of another type.             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_type (IGRlong * msg; IGRint * type);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_display                                                    |
 |                                                                           |
 | This message will return the default types of elements and element layers |
 | that are being stored for this object, if any at all. If the information  |
 | is not stored a full element mask and layers mask will be returned. The   |
 | EMdescribe object will store the last set element display mask but will   |
 | not store the layers. The element display mask will indicate the          |
 | following:                                                                |
 |                                                                           |
 |  EM_GRAPHIC_DISPLAYED    - Should graphics be displayed?                  |
 |  EM_SOLIDSURF_DISPLAYED  - Should solids and surfaces be displayed?       |
 |  EM_WIREFRAME_DISPLAYED  - Should wireframe geometry be displayed?        |
 |  EM_TEXT_DISPLAYED       - Should text be displayed?                      |
 |  EM_DIMENSION_DISPLAYED  - Should dimensions be displayed?                |
 |  EM_REFPLANE_DISPLAYED   - Should reference planes be displayed?          |
 |  EM_CONSTRAINT_DISPLAYED - Should constraints be displayed?               |
 |  EM_HANDLE_DISPLAYED     - Should handles be displayed?                   |
 |                                                                           |
 | These defines are found in the assemdef.h include file.                   |
 |                                                                           |
 | The layers mask indicate which layers were used to turn the display on/off|
 | for graphics. This mask an array of 32 IGRlongs whose bits represent all  |
 | layers from 1 to 1023.                                                    |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code                          |
 |          IGRint      * display       Display mask.                        |
 |          IGRlong     * layers        Layers, 32 IGRlong.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 | Note: It is questionable whether this message is very useful for          |
 | EMdescribe objects. But it will become more useful with the EMlocalpart   |
 | class which is a subclass of EMdescribe.                                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_display (IGRlong    * msg;
                       IGRint     * display;
                       IGRlong    * layers);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMset_display                                                    |
 |                                                                           |
 | This message will set the display of member graphics according to a bit   |
 | mask which may consist of the following:                                  |
 |                                                                           |
 |  EM_GRAPHIC_DISPLAYED    - Should graphics be displayed?                  |
 |  EM_SOLIDSURF_DISPLAYED  - Should solids and surfaces be displayed?       |
 |  EM_WIREFRAME_DISPLAYED  - Should wireframe geometry be displayed?        |
 |  EM_TEXT_DISPLAYED       - Should text be displayed?                      |
 |  EM_DIMENSION_DISPLAYED  - Should dimensions be displayed?                |
 |  EM_REFPLANE_DISPLAYED   - Should reference planes be displayed?          |
 |  EM_CONSTRAINT_DISPLAYED - Should constraints be displayed?               |
 |  EM_HANDLE_DISPLAYED     - Should handles be displayed?                   |
 |                                                                           |
 | These defines are found in the assemdef.h include file.                   |
 |                                                                           |
 | It also allows the display on/off for graphics to be set by element layer.|
 | This is done using a array of 32 IGRlongs whose bits represent all layers |
 | from 1 to 1024.                                                           |
 |                                                                           |
 | Input:   struct GRmd_env * mod_env   Module environment for the object.   |
 |          IGRint          * display   Display mask, may be NULL.           |
 |          IGRlong         * layers    Layers, may be NULL.                 |
 |          IGRboolean        update    Update the object display?           |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code                          |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 | Note: It is questionable whether this message is very useful for          |
 | EMdescribe objects. But it will become more useful with the EMlocalpart   |
 | class which is a subclass of EMdescribe.                                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMset_display (IGRlong         * msg;
                       struct GRmd_env * mod_env;
                       IGRint          * display;
                       IGRlong         * layers;
                       IGRboolean        update);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_behavior                                                   |
 |                                                                           |
 | This message returns the behavior properties of the describe object. These|
 | properties are as follows:                                                |
 |                                                                           |
 |  EM_DESCRIBE_ACTIVE  - Describe object is active?                         |
 |  EM_FILE_IN_BOM      - Instance in file appear in BOM?                    |
 |  EM_IN_BOM           - This part/instance appears in BOM?                 |
 |  EM_WRITABLE         - Reference file is writable?                        |
 |  EM_BACKGROUND       - Reference file is background?                      |
 |  EM_ATTACHED         - Reference file is attached?                        |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRint  *     behavior    Properties of object.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_behavior (IGRlong * msg; IGRint * behavior);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMset_behavior                                                   |
 |                                                                           |
 | This message sets the behavior properties of the describe object. These   |
 | properties are as follows:                                                |
 |                                                                           |
 |  EM_DESCRIBE_ACTIVE  - Describe object is active?                         |
 |  EM_FILE_IN_BOM      - Instance in file appear in BOM?                    |
 |  EM_IN_BOM           - This part/instance appears in BOM?                 |
 |  EM_WRITABLE         - Reference file is writable?                        |
 |  EM_BACKGROUND       - Reference file is background?                      |
 |  EM_ATTACHED         - Reference file is attached?                        |
 |                                                                           |
 | Input:  IGRint        behavior    Properties of object.                   |
 |                                                                           |
 | Output: IGRlong *     msg         Return code.                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMset_behavior (IGRlong * msg; IGRint behavior);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_application_properties                                     |
 |                                                                           |
 | This message returns the application specific properties of the describe  |
 | object. These properties are defined by the application and consist of    |
 | the 4 high bits in the properties word:                                   |
 |                                                                           |
 |  EM_APPLICATION_PROPS - 0xf0000000                                        |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRuint *     props       Application properties of object.      |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_application_properties (IGRlong * msg; IGRuint * props);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMset_application_properties                                     |
 |                                                                           |
 | This message sets the application specific properties of the describe     |
 | object. These properties are defined by the application and consist of    |
 | the 4 high bits in the properties word:                                   |
 |                                                                           |
 |  EM_APPLICATION_PROPS - 0xf0000000, mask for 4 application bits.          |
 |                                                                           |
 | Input:  IGRuint       props       Properties of object.                   |
 |                                                                           |
 | Output: IGRlong *     msg         Return code.                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMset_application_properties (IGRlong * msg; IGRuint props);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMnum_attrs                                                      |
 |                                                                           |
 | This message returns the total number of attributes which match the type  |
 | mask specified.                                                           |
 |                                                                           |
 | Input:   IGRint      type        Attribute types to consider.             |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |          IGRint  *   num_attrs   Number of attribute of that type.        |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Successful.                                      |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMnum_attrs    ( IGRlong *  msg;
                         IGRint     type;
                         IGRint  *  num_attrs );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_attr                                                       |
 |                                                                           |
 | This message gets an attribute by index or name.                          |
 |                                                                           |
 | Input:   IGRchar     * name        Name of attribute, NULL if by index.   |
 |          IGRint        type        Types to consider, not used with name. |
 |          IGRint        index       Index of the attribute.                |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          EMattr  *     attr        Attribute.                             |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_MEMBNOTFOUND  Member not found.                            |
 |          ASM_E_INVINDEX      Index was invalid for number of members.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_attr     ( IGRlong *  msg;
                         IGRchar *  name;
                         IGRint     type;
                         IGRint     index;
                         EMattr  *  attr );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_attrs                                                      |
 |                                                                           |
 | This message gets attributes of the specified type.                       |
 |                                                                           |
 | Input:   IGRint    type        Attribute types to consider.               |
 |          IGRint    num_attrs   Size of attrs buffer.                      |
 |                                                                           |
 | Output:  IGRlong * msg         Return code                                |
 |          IGRint    num_attrs   Number of attributes returned.             |
 |          EMattr  * attrs       Attributes.                                |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_BUFFTOOSMALL  Buffer too small for all members.            |
 |          ASM_E_MEMBNOTFOUND  Member not found.                            |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 | Notes:                                                                    |
 |                                                                           |
 | If the size of the attribute buffer as specified by num_attrs isn't large |
 | enough attributes will NOT be returned but the real number of attributes  |
 | will be returned in num_attrs argument.                                   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_attrs    ( IGRlong *  msg;
                         IGRint     type;
                         IGRint     num_attrs;
                         EMattr  *  attrs );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMadd_attr                                                       |
 |                                                                           |
 | This message adds an attribute.                                           |
 |                                                                           |
 | Input:   EMattr   *   Attribute to add, expr_id = NULL_OBJID.             |
 |                                                                           |
 | Output:  IGRlong  *   msg     Return code                                 |
 |          EMattr   *   attr    New attribute with expr_id filled in.       |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_MEMBEXISTS    Member already exists with that name.        |
 |          ASM_E_INVSYNTAX     Syntax was not legal.                        |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved attribute.     |
 |          ASM_E_DIRADD        Error adding object to directory.            |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMadd_attr     ( IGRlong *  msg;
                         EMattr  *  attr );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMmod_attr                                                       |
 |                                                                           |
 | This message modifies an attribute.                                       |
 |                                                                           |
 | Input:   IGRchar  *   name       Name of attribute to modify.             |
 |          IGRint   *   type       Type of attribute to modify.             |
 |          IGRint   *   index      Index of attribute to modify.            |
 |          EMattr   *   attr       Attribute info to modifiy                |
 |                                                                           |
 | Output:  IGRlong  *   msg     Return code                                 |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_MEMBNOTFOUND  Member wasn't found.                         |
 |          ASM_E_INVINDEX      Index was invalid for number of members.     |
 |          ASM_E_INVSYNTAX     Syntax was not legal.                        |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved attribute.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMmod_attr     ( IGRlong *  msg;
                         IGRchar *  name;
                         IGRint     type;
                         IGRint     index;
                         EMattr  *  attr );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMrem_attr                                                       |
 |                                                                           |
 | This message removes an attribute by name or index.                       |
 |                                                                           |
 | Input:   IGRchar     * name        Name of attribute, NULL if by index.   |
 |          IGRint        type        Types to consider, not used with name. |
 |          IGRint        index       Index of the attribute.                |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_MEMBNOTFOUND  Member wasn't found.                         |
 |          ASM_E_INVINDEX      Index was invalid for number of members.     |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved attribute.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           | 
 +---------------------------------------------------------------------------*/
message EMrem_attr     ( IGRlong *  msg;
                         IGRchar *  name;
                         IGRint     type;
                         IGRint     index );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMlegal_attr_op                                                 |
 |                                                                           |
 | This message determines whether it's legal to perform the specified       |
 | operation on the attribute.                                               |
 |                                                                           |
 | Input:   IGRint      operation   EM_ADD, EM_MOD, or EM_REM.               |
 |          EMattr      attr        Attribute.                               |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved attribute.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMlegal_attr_op (IGRlong *msg; IGRint operation; EMattr * attr);


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMnum_membs                                                      |
 |                                                                           |
 | This message returns the total number of members which match the type     |
 | mask specified.                                                           |
 |                                                                           |
 | Input:   IGRint      type        Attribute types to consider.             |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |          IGRint  *   num_membs   Number of members of that type.          |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Successful.                                      |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMnum_membs  ( IGRlong *  msg;
                       IGRint     type;
                       IGRint  *  num_membs );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_memb                                                       |
 |                                                                           |
 | This message gets an member by index or name.                             |
 |                                                                           |
 | Input:   IGRchar     * name        Name of member, NULL if by index.      |
 |          IGRint        type        Types to consider, not used with name. |
 |          IGRint        index       Index of the member.                   |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code                            |
 |          EMmemb  *     memb        Member.                                |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_MEMBNOTFOUND  Member not found.                            |
 |          ASM_E_INVINDEX      Index was invalid for number of members.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_memb   ( IGRlong *  msg;
                       IGRchar *  name;
                       IGRint     type;
                       IGRint     index;
                       EMmemb  *  memb );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_membs                                                      |
 |                                                                           |
 | This message gets members of the specified type.                          |
 |                                                                           |
 | Input:   IGRint    type        Member types to consider.                  |
 |          IGRint    num_membs   Size of membs buffer.                      |
 |                                                                           |
 | Output:  IGRlong * msg         Return code                                |
 |          IGRint    num_membs   Number of members returned.                |
 |          EMmemb  * membs       Members.                                   |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_BUFFTOOSMALL  Buffer too small for all members.            |
 |          ASM_E_MEMBNOTFOUND  Member not found.                            |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_membs    ( IGRlong *  msg;
                         IGRint     type;
                         IGRint     num_membs;
                         EMmemb  *  membs );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMadd_memb                                                       |
 |                                                                           |
 | This message adds an member.                                              |
 |                                                                           |
 | Input:   EMmemb   *   Member to add, expr_id = NULL_OBJID.                |
 |                                                                           |
 | Output:  IGRlong  *   msg     Return code                                 |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_MEMBEXISTS    Member already exists with that name.        |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved member.        |
 |          ASM_E_DIRADD        Error adding object to directory.            |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMadd_memb     ( IGRlong *  msg;
                         EMmemb  *  memb );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMmod_memb                                                       |
 |                                                                           |
 | This message modifies an member.                                          |
 |                                                                           |
 | Input:   IGRchar  *   name       Name of member to modify.                |
 |          IGRint   *   type       Type of member to modify.                |
 |          IGRint   *   index      Index of member to modify.               |
 |          EMmemb   *   memb       Member info to modifiy                   |
 |                                                                           |
 | Output:  IGRlong  *   msg     Return code                                 |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_MEMBNOTFOUND  Member wasn't found.                         |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved member.        |
 |          ASM_E_INVINDEX      Index was invalid for number of members.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMmod_memb     ( IGRlong *  msg;
                         IGRchar *  name;
                         IGRint     type;
                         IGRint     index;
                         EMmemb  *  memb );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMrem_memb                                                       |
 |                                                                           |
 | This message removes an member by name or index.                          |
 |                                                                           |
 | Input:   IGRchar     * name        Name of member, NULL if by index.      |
 |          IGRint        type        Types to consider, not used with name. |
 |          IGRint        index       Index of the member.                   |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_MEMBNOTFOUND  Member wasn't found.                         |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved member.        |
 |          ASM_E_INVINDEX      Index was invalid for number of members.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           | 
 +---------------------------------------------------------------------------*/
message EMrem_memb     ( IGRlong *  msg;
                         IGRchar *  name;
                         IGRint     type;
                         IGRint     index );

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMlegal_memb_op                                                 |
 |                                                                           |
 | This message determines whether it's legal to perform the specified       |
 | operation on the member.                                                  |
 |                                                                           |
 | Input:   IGRint      operation   EM_ADD, EM_MOD, or EM_REM.               |
 |          EMmemb      memb        Member.                                  |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved member.        |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMlegal_memb_op (IGRlong *msg; IGRint operation; EMmemb * memb);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMget_memb_type                                                 |
 |                                                                           |
 | This message returns the type of member that this object will be.         |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code.                             |
 |          IGRint  *   type        Type of member.                          |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_memb_type (IGRlong *msg; IGRint * type);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMdefault_memb_type                                             |
 |                                                                           |
 | This message returns a default type for the input member id.              |
 |                                                                           |
 | Input:   struct GRid * memb_id  Id of member.                             |
 |                                                                           |
 | Output:  IGRlong     * msg      Return code.                              |
 |          IGRint      * type     Type of member.                           |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMdefault_memb_type (IGRlong     * msg; 
                             struct GRid * memb_id; 
                             IGRint      * type);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMpass                                                           |
 |                                                                           |
 | This message will call a function on itself and the propogate the pass    |
 | message to each describe object inside the receiving describe object. The |
 | user may also provide a selection function that further narrows the scope |
 | of the pass.                                                              |
 |                                                                           |
 | Input:   struct GRmd_env * mod_env           Module environment.          |
 |          IGRint            depth             Initial depth, 0.            |
 |          IGRlong           (*pass_func)()    Function to call.            |
 |          IGRchar         * pass_func_info    Function information.        |
 |          IGRboolean        (*pass_select)()  Function to select pass objs |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code                              |
 |                                                                           |
 | Prototype: IGRlong      (*pass_func)(IGRlong         * msg,               |
 |                                      struct GRmd_env * mod_env,           |
 |                                      IGRint            depth,             |
 |                                      IGRchar         * pass_func_info,    |
 |                                      struct GRid     * desc_id)           |
 |                                                                           |
 |            IGRboolean   (*pass_select)(struct GRmd_env * mod_env,         |
 |                                        IGRint            depth,           |
 |                                        IGRchar         * pass_func_info,  |
 |                                        struct GRid     * desc_id,         |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMpass (IGRlong         * msg;
                struct GRmd_env * mod_env;
                IGRint            depth;
                IGRlong           (*pass_func)();
                IGRchar         * pass_func_info;
                IGRboolean        (*pass_select)());

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMget_unique_name                                               |
 |                                                                           |
 | This message returns a unique name for an object being added.             |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |          IGRchar *   basename    Base name for the instance.              |
 |          IGRchar *   name        Name for the instance.                   |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_unique_name (IGRlong *msg; IGRchar* basename; IGRchar *name);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMadd_notify                                                     |
 |                                                                           |
 | This message will add a graphic object that is to be described.           |
 |                                                                           |
 | Input:   struct GRid * notify_id     Notify object's id.                  |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code                          |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMadd_notify (IGRlong     * msg;
                      struct GRid * notify_id);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_notify                                                     |
 |                                                                           |
 | This message will return the graphic object that is being described.      |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code                          |
 |          struct GRid * notify_id     Notify object's id.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_notify (IGRlong     * msg;
                      struct GRid * notify_id);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMrem_notify                                                     |
 |                                                                           |
 | This message will remove the graphic object that is being described.      |
 |                                                                           |
 | Output:  IGRlong     * msg           Return code                          |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMrem_notify (IGRlong * msg);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Message: EMadd_memb_info                                          |
 |                                                                           |
 | This message adds member description and type.                            |
 |                                                                           |
 | Input:   EMmemb   *   memb    Member whose info should be added.          |
 |                                                                           |
 | Output:  IGRlong  *   msg     Return code                                 |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMadd_memb_info (IGRlong * msg;
                         EMmemb  * memb);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Message: EMmod_memb_info                                          |
 |                                                                           |
 | This message adds member description and type.                            |
 |                                                                           |
 | Input:   EMmemb   *   memb    Member info to modify.                      |
 |                                                                           |
 | Output:  IGRlong  *   msg     Return code                                 |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_INVINDEX      Index was invalid for number of members.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMmod_memb_info (IGRlong * msg;
                         EMmemb  * memb);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Private Message: EMrem_memb_info                                          |
 |                                                                           |
 | This message adds member description and type.                            |
 |                                                                           |
 | Input:   EMmemb       memb    Member info to remove.                      |
 |                                                                           |
 | Output:  IGRlong  *   msg     Return code.                                |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_INVINDEX      Index was invalid for number of members.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMrem_memb_info (IGRlong * msg;
                         EMmemb  * memb);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMget_active                                                     |
 |                                                                           |
 | This message returns whether the describe is active or not.               |
 |                                                                           |
 | Output:  IGRlong    * msg         Return code.                            |
 |          IGRboolean * active      Part active?                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMget_active (IGRlong * msg; IGRboolean * active);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMset_active                                                     |
 |                                                                           |
 | This message sets whether the describe is active or not. Making a describe|
 | object active simply does a change directory to itself and sets the active|
 | bit. That way any expression objects created with get attached to that    |
 | part. Subclass of describe, like EMlocalpart, will do much more with this |
 | functionality.                                                            |
 |                                                                           |
 | Input:   IGRboolean   active      Make part active?                       |
 |                                                                           |
 | Output:  IGRlong    * msg         Return code.                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMset_active (IGRlong * msg; IGRboolean active);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message: EMdelete                                                         |
 |                                                                           |
 | This message deletes a EMdescribe object. A separate delete is needed in  |
 | order to allow us to use the normal method of removing a directory object |
 | with the di$rmdir macros.                                                 |
 |                                                                           |
 | Output:  IGRlong    * msg         Return code.                            |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMdelete (IGRlong * msg);

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Message:  EMupdate                                                        |
 |                                                                           |
 | This message will cause the describe object to update itself according    |
 | to context in which it finds itself. This is a noop at the EMdescibe      |
 | level but is used by both the instance and part classes.                  |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code.                             |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
message EMupdate (IGRlong *msg);

/*---------------------------------------------------------------------------+
 |									     |
 | Message:  EMupdate_display						     |
 |									     |
 | This message updates the display of the describe object with the display  |
 | properties currently stored in the object.                                |
 |									     |
 | Input:   struct GRmd_env * mod_env Module environment.                    |
 |								             |
 | Output:  IGRlong *  msg      Return code.				     |
 | 									     |
 | Return:  ASM_S_SUCCESS   Successful.				             |
 |          ASM_E_ABORT     Catostrophic error.				     |
 |									     |
 +---------------------------------------------------------------------------*/
message EMupdate_display (IGRlong *msg;
			  struct GRmd_env *mod_env);
			 

/*
 * Root overrides.
 */
override debug,         /* Print out member info. */
         delete;        /* Disconnect described graphics. */

/*
 * Listener Overrides.
 */
override GRnotifylis;   /* Handle delete of described graphics. */

/*
 * Directory Overrides.
 */
override add,           /* Reject synonyms and update member info. */
         remove;        /* Update member info. */

end specification EMdescribe;



