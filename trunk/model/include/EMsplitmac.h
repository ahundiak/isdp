#ifndef splitmacros_include
#define splitmacros_include

/*

       This file contains the APIs for Save Element to File and SplitPart.

   History

       Gang   08/04/93    Creation date.

*/

/*

   Description

       This macro is used to save the list of objects to a given file.
       It will copy the objects supplied in the objects list and all 
       their parents to the given filename and maintains the associativity. 
       If seedfile is not supplied default seedfile will be used. There
       is an option of deleting the copied objects from the original
       file. It will not delete the objects which are having dependents
       in the original file even if the delete flag is TRUE.

  Arguments

       IGRlong           *msg       (O)  Completion code
       struct GRmd_env   *mod_env   (I)  Module environment
       struct GRid       *objects   (I)  List of objects
       IGRlong           *num_obj   (I)  Number of objects
       IGRchar           *filename  (I)  Filename
       IGRchar           *seedfile  (I)  Seedfile name
       IGRboolean        *delete    (I)  Delete flag (TRUE/FALSE)

*/

#omdef asm$save_element(msg,
                        mod_env = NULL,
                        objects,
                        num_obj,
                        filename,
                        seedfile = NULL,
                        delete = FALSE)

       ASMSplitPart(msg,mod_env,objects,num_obj,filename,seedfile,delete);

#endomdef

#endif
