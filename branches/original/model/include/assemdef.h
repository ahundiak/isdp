#ifndef ASSEMDEF_H
#define ASSEMDEF_H

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Include File: assemdef.h                                                  |
 |                                                                           |
 | The file contains all constant definitions for the assembly modeling      |
 | system.                                                                   |
 |                                                                           |
 | Dependencies:                                                             |
 |                                                                           |
 | OMerrordef.h                                                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Assembly Limits                                                  |
 |                                                                           |
 | The following defines place limits on the lengths of different assembly   |
 | information.                                                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define MAX_NAME    40      /* Maximum length for attribute name */
#define MAX_DESC    256     /* Maximum length for attribute description */
#define MAX_SYNTAX  256     /* Maximum length for attribute syntax string */
#define MAX_VALUE   256     /* Maximum length for attribute value string */
#define MAX_PATH    1024    /* Maximum length for a file path */


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Describe/Part/Instance Properties                                |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Describe Types                                                   |
 |                                                                           |
 | The following define the description types which are integrated with the  |
 | properties word.                                                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_DESCRIBE_TYPES       0x000000ff
#define EM_PART_TYPES           0x000000ff

#define EM_DESCRIPTION          0x00000001  /* Default is describe object. */
#define EM_FILE_PART            0x00000002  /* Definition of file as a part. */
#define EM_LOCAL_PART           0x00000004  /* Subdivision of file into part.*/
#define EM_REFERENCE_PART       0x00000008  /* Reffile defined as part.      */
#define EM_GRAPHIC_PART         0x00000010  /* Graphic defined as part.      */
#define EM_NONGRAPHIC_PART      0x00000020  /* Nongraphic part.              */

#define EM_CACHED_PART          (EM_REFERENCE_PART  | EM_GRAPHIC_PART | \
                                 EM_NONGRAPHIC_PART)

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Describe Display Properties                                      |
 |                                                                           |
 | The following define general display properties for all describe objects. |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_DISPLAY_PROPS        0x000fff00
#define EM_DISPLAY_TYPES        0x0000fe00
#define EM_GRAPHIC_DISPLAYED    0x00000100  /* Graphics displayed?          */
#define EM_HANDLE_DISPLAYED     0x00000200  /* Handles displayed?           */
#define EM_SOLIDSURF_DISPLAYED  0x00000400  /* Solid/surf displayed?        */
#define EM_WIREFRAME_DISPLAYED  0x00000800  /* Wireframe displayed?         */
#define EM_TEXT_DISPLAYED       0x00001000  /* Text displayed?              */
#define EM_DIMENSION_DISPLAYED  0x00002000  /* Dimensions displayed?        */
#define EM_REFPLANE_DISPLAYED   0x00004000  /* Ref planes displayed?        */
#define EM_CONSTRAINT_DISPLAYED 0x00008000  /* Constraints displayed?       */

#define EM_DEFAULT_DISPLAY (EM_DISPLAY_PROPS & ~EM_REFPLANE_DISPLAYED)

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Describe Behavior Properties                                     |
 |                                                                           |
 | The following define behavior properties for descriptions, parts and      |
 | instances.                                                                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_BEHAVIOR_PROPS       0x0ff00000
#define EM_PART_INSTANCE_PROPS  0x0ff00000  
#define EM_DESCRIBE_ACTIVE      0x00100000  /* Is describe object active?   */
#define EM_FILE_IN_BOM          0x00200000  /* Instances in reffile in BOM? */
#define EM_IN_BOM               0x00400000  /* Part or instance in BOM?     */
#define EM_READONLY             0x00800000  /* Reference file read only?    */
#define EM_BACKGROUND           0x01000000  /* Reference file background?   */
#define EM_DETACHED             0x02000000  /* Reference file detached?     */

#define EM_DEFAULT_BEHAVIOR  (EM_FILE_IN_BOM | EM_IN_BOM)

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Describe Application Properties                                  |
 |                                                                           |
 | The following define general application properties for all describe      |
 | objects. They are to be used by applications and are not recognized by    |
 | EMdescribe objects, use them as you wish.                                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_APPLICATION_PROPS    0xf0000000

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Macros: Describe/Part/Instance Properties Macros                          |
 |                                                                           |
 | The following define macros which extract information about part/instance |
 | properties.                                                               |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_IS_DESCRIBE_ACTIVE(p)       ((p&EM_DESCRIBE_ACTIVE) ? TRUE : FALSE)
#define EM_IS_FILE_PART(p)             ((p&EM_FILE_PART) ? TRUE : FALSE)
#define EM_IS_LOCAL_PART(p)            ((p&EM_LOCAL_PART)? TRUE : FALSE)
#define EM_IS_CACHED_PART(p)           ((p&EM_CACHED_PART)? TRUE : FALSE)
#define EM_IS_REFERENCE_PART(p)        ((p&EM_REFERENCE_PART)? TRUE : FALSE)
#define EM_IS_GRAPHIC_PART(p)          ((p&EM_GRAPHIC_PART) ? TRUE : FALSE)
#define EM_IS_NONGRAPHIC_PART(p)       ((p&EM_NONGRAPHIC_PART) ? TRUE : FALSE)
#define EM_IS_FILE_IN_BOM(p)           ((p&EM_FILE_IN_BOM) ? TRUE : FALSE)
#define EM_IS_IN_BOM(p)                ((p&EM_IN_BOM) ? TRUE : FALSE)
#define EM_IS_BACKGROUND(p)            ((p&EM_BACKGROUND) ? TRUE : FALSE)
#define EM_IS_DETACHED(p)              ((p&EM_DETACHED) ? TRUE : FALSE)
#define EM_IS_READONLY(p)              ((p&EM_READONLY) ? TRUE : FALSE)
#define EM_IS_GRAPHIC_DISPLAYED(p)     ((p&EM_GRAPHIC_DISPLAYED) ? TRUE : FALSE)
#define EM_IS_SOLIDSURF_DISPLAYED(p)   ((p&EM_SOLIDSURF_DISPLAYED) ? TRUE : FALSE)
#define EM_IS_WIREFRAME_DISPLAYED(p)   ((p&EM_WIREFRAME_DISPLAYED) ? TRUE : FALSE)
#define EM_IS_TEXT_DISPLAYED(p)        ((p&EM_TEXT_DISPLAYED) ? TRUE : FALSE)
#define EM_IS_DIMENSION_DISPLAYED(p)   ((p&EM_DIMENSION_DISPLAYED) ? TRUE : FALSE)
#define EM_IS_REFPLANE_DISPLAYED(p)    ((p&EM_REFPLANE_DISPLAYED) ? TRUE : FALSE)
#define EM_IS_CONSTRAINT_DISPLAYED(p)  ((p&EM_CONSTRAINT_DISPLAYED) ? TRUE : FALSE)
#define EM_IS_HANDLE_DISPLAYED(p)      ((p&EM_HANDLE_DISPLAYED) ? TRUE : FALSE)

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Member Type Information                                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Member Types                                                     |
 |                                                                           |
 | The following define types of objects that may be added to a part or      |
 | an instance.                                                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_MEMBER_TYPES         0x000fffff
#define EM_DESCRIBE             0x00000001
#define EM_PART                 0x00000002
#define EM_HANDLE               0x00000004
#define EM_GRAPHIC              0x00000008
#define EM_INSTANCE             0x00000010
#define EM_ATTRIBUTE            0x00000020
#define EM_PART_ATTR            0x00000040
#define EM_INSTANCE_ATTR        0x00000080
#define EM_COMMON_ATTR          0x00000100
#define EM_LINK_ATTR            0x00000200

#define EM_DESCRIBE_MEMBERS     (EM_DESCRIBE | EM_PART | EM_INSTANCE)
#define EM_ATTRIBUTE_MEMBERS    (EM_ATTRIBUTE | EM_PART_ATTR | \
                                 EM_INSTANCE_ATTR | EM_COMMON_ATTR | \
                                 EM_LINK_ATTR)

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Application Member Subtypes                                      |
 |                                                                           |
 | The following define bits that may be used by applications when           |
 | setting member types. These bits may be used to give subproperties to the |
 | members in addition to their member type. These bits are not considered   |
 | by the EMdescribe classes, use them as you wish.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_MEMBER_SUBTYPES      0xfff00000

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Attribute Value Types                                            |
 |                                                                           |
 | The following define value types which are used when adding, modifying or |
 | getting an attribute type. On addition and modification the value type is |
 | set in the EMattr structure to indicate how the attribute should be added |
 | if possible. When getting an attribute the type will indicate the real    |
 | type of the attribute which may be EM_DOUBLE, EM_INTEGER or EM_STRING.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_CALCULATED           0x0001  /* Determined by expression */
#define EM_DOUBLE               0x0002  /* Double attribute */
#define EM_INTEGER              0x0004  /* Integer attribute */
#define EM_STRING               0x0008  /* String attribute */

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Member Operations Flags                                          |
 |                                                                           |
 | The following define types of operations which may be performed on        |
 | members.                                                                  |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_ADD  1
#define EM_MOD  2
#define EM_REM  3
#define EM_RNM  4

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Bom Operations Flags                                             |
 |                                                                           |
 | The following define types of operations which may be affect the on line  |
 | bill-of-materials form.                                                   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define BOM_ADD_ENTRY    1
#define BOM_REM_ENTRY    2
#define BOM_MOD_ATTRS    3
#define BOM_MOD_PROPS    4
#define BOM_MOD_LAYERS   5
#define BOM_MOD_ENTRY    6

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Assembly Constraint Types                                        |
 |                                                                           |
 | The following define the types of assembly constraints that may be placed |
 | in the assembly modeling system.                                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define EM_GROUND   1
#define EM_MATE     2
#define EM_ALIGN    3
#define EM_INSERT   4
#define EM_TANGENCY 5

/*---------------------------------------------------------------------------+
 | Defines for the required info from the assembly tree.                     |
 +---------------------------------------------------------------------------*/
#define INQ_GRIDS               0x0001
#define INQ_MAX_DEPTH           0x0002
#define INQ_PROPS               0x0004
#define INQ_PRT_WITH_INC_CNSTR  0x0008
#define INQ_PRT_WITH_OUT_CNSTR  0x0010
#define INQ_ALL_PRT_WITH_CNSTR  INQ_PRT_WITH_INC_CNSTR |\
                                INQ_PRT_WITH_OUT_CNSTR 

/*---------------------------------------------------------------------------+
 | Mask for constraint attributes for special cases of constraints           |
 +---------------------------------------------------------------------------*/

#define EM_ALIGN_REVERSE 0x00000001
#define EM_MATE_ALIGNED  0x00000002

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Error Messages for the Assembly Modeling System.                 |
 |                                                                           |
 | The following define the error messages that are return in the "msg"      |
 | argument in the macros.                                                   |
 |                                                                           |
 +---------------------------------------------------------------------------*/
#define ASM_UNIQUE              (0x55500000)

#define ASM_ERRO                (ASM_UNIQUE | ERRO)
#define ASM_WARN                (ASM_UNIQUE | WARN)
#define ASM_SUCC                (ASM_UNIQUE | SUCC)

#define ASM_S_SUCCESS           (0x00000000 | ASM_SUCC)

#define ASM_E_ABORT             (0x00000000 | ASM_ERRO)
#define ASM_E_INVARGS           (0x00000010 | ASM_ERRO) 
#define ASM_E_MEMBNOTFOUND      (0x00000020 | ASM_ERRO)
#define ASM_E_MEMBEXISTS        (0x00000030 | ASM_ERRO)
#define ASM_E_OVERCONSTRAINED   (0x00000040 | ASM_ERRO)
#define ASM_E_NOTSUPPORTED      (0x00000050 | ASM_ERRO)
#define ASM_E_PARTDEFINED       (0x00000060 | ASM_ERRO)
#define ASM_E_INVINDEX          (0x00000070 | ASM_ERRO)
#define ASM_E_BUFFTOOSMALL      (0x00000080 | ASM_ERRO)
#define ASM_E_INVSYNTAX         (0x00000090 | ASM_ERRO)
#define ASM_E_ILLEGALOP         (0x000000a0 | ASM_ERRO)
#define ASM_E_DIRCREATE         (0x000000b0 | ASM_ERRO)
#define ASM_E_DIRADD            (0x000000c0 | ASM_ERRO)
#define ASM_E_INVLAYERS         (0x000000e0 | ASM_ERRO)
#define ASM_E_NODESCRIPTION     (0x000000f0 | ASM_ERRO)
#define ASM_E_DESCRIPTIONEXISTS (0x00000100 | ASM_ERRO)
#define ASM_E_STRONGCOMP        (0x00000200 | ASM_ERRO)


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Defines: Error Messages for the Assembly MATH routines                    |
 |                                                                           |
 | The following define the error messages that are returned from the        |
 | Assembly Math Routines(EMassemmath.C)                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/

#define	ASM_MATH_SUCC			 (0x00000001 | SUCC) 

#define ASM_MABS_FAIL 			 (0x00000300 | ERRO)
#define ASM_MATE_SUCC 			 (0x00000400 | ERRO)
#define ASM_ALIGN_SUCC 			 (0x00000500 | ERRO)
#define ASM_FST_ALIGN_SUCC 		 (0x00000600 | ERRO)
#define ASM_SEC_ALIGN_SUCC 		 (0x00000700 | ERRO)
#define ASM_ALIGN_PART_SUCC 		 (0x00000800 | ERRO)
#define ASM_INVALID_INPUT 		 (0x00000900 | ERRO)


/* Manage Assembly command definitions */

#define BOM_ACTIVE      0x0001
#define BOM_DISPLAY     0x0002
#define BOM_EDIT        0x0004
#define BOM_EVENT       0x0008
#define BOM_BACKGROUND  0x0010
#define BOM_WRITE       0x0020
#define BOM_CONSTRAINT  0x0040
#define BOM_HIGHLIGHT   0x0080
#define BOM_DELETE      0x0100
#define BOM_SETDISPLAY  0x0200

#define BOM_FIRSTLEVEL  (BOM_BACKGROUND | BOM_EDIT | BOM_DELETE | BOM_CONSTRAINT)

#endif
