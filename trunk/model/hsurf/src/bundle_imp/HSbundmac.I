
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

class implementation HStable;

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exmacros.h"
#include "msdef.h"

#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"

#include "HSpr_bundle.h"




#if defined(__STDC__) || defined(__cplusplus)
	HSaddbundentry(		IGRlong *msg,
		 struct HSrender_bundle *entry,
	   struct HSextra_render_bundle *app_entry,
				 IGRint *index,
				GRobjid mod_id,
			     GRspacenum mod_osnum )
#else
	HSaddbundentry(msg,entry,app_entry,index,mod_id,mod_osnum)

	IGRlong		*msg;
	struct  HSrender_bundle *entry;
	struct  HSextra_render_bundle *app_entry;
	IGRint		*index;
	GRobjid		mod_id;
	GRspacenum		mod_osnum;
#endif

/*

NAME
    HSaddbundentry

KEYWORD
    Bundle Tables

DESCRIPTION
    This function calls the appropriate functions to do the following
       add the application bundle table entry
       add the shading bundle table entry
       add the texture table entry

PARAMETERS
    msg       (OUT) -
    entry     (IN)  - The shading bundle table entry to be added
    app_entry (IN)  - The application bundle table entry to be added.
    index     (OUT) - The highest level index.
    mod_id    (IN)  - The object id of the module object
    mod_osnum (IN)  - The os number of the module object

GLOBALS USED
    none

RETURN VALUES
    1 success
    0 failure

HISTORY
    --/--/91 Shridar Subramanian

*/
       


 
    
 

    {

	    struct HS_symb_and_app new_entry;
	    IGRint                new_index;


	    memcpy(&new_entry, entry, sizeof(struct HSrender_bundle));
	    new_entry.app_symb_index = -1;

	    if (app_entry)
	    {
		if (!HSappaddsymb(msg,(IGRchar *)app_entry,&new_index,mod_id,mod_osnum))
                    return(0);

		new_entry.app_symb_index = new_index;
	    }
	  
	    if (!HSaddsymbentry(msg,(IGRchar *) &new_entry,index,mod_id,mod_osnum))
                return(0);

            if (new_entry.tex_index !=0)
	        if(!HSadd_texture_ref_ct(new_entry.tex_index, mod_id, mod_osnum))
                     return(0);
	    return(1);

    
    }


#if defined(__STDC__) || defined(__cplusplus)
	HScrebundentry(		IGRlong *msg,
		 struct HSrender_bundle *entry,
	   struct HSextra_render_bundle *app_entry,
				 IGRint *index,
				GRobjid mod_id,
			     GRspacenum mod_osnum )
#else
	HScrebundentry(msg,entry,app_entry,index,mod_id,mod_osnum)
	
	IGRlong		*msg;
	struct HSrender_bundle	*entry;
	struct HSextra_render_bundle *app_entry;
	IGRint		*index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif
/*

NAME
    HScrebundentry

KEYWORD
    Bundle Tables

DESCRIPTION
    This function calls the appropriate functions to do the following
       create the application bundle table entry
       create the shading bundle table entry
       create the texture table entry

PARAMETERS
    msg       (OUT) -
    entry     (IN)  - The shading bundle table entry to be created
    app_entry (IN)  - The application bundle table entry to be created.
    index     (OUT) - The highest level index.
    mod_id    (IN)  - The object id of the module object
    mod_osnum (IN)  - The os number of the module object

GLOBALS USED
    none

RETURN VALUES
    1 success
    0 failure

HISTORY
    --/--/91 Shridar Subramanian

*/
    {

     	IGRint new_index;
     	struct HS_symb_and_app  new_entry;


	     memcpy(&new_entry, entry, sizeof(struct HSrender_bundle));
	     new_entry.app_symb_index = -1;
	     if (app_entry)
	     {
		     if (!HSappcreasymb(msg,(IGRchar * ) app_entry,&new_index,mod_id,mod_osnum))
                          return(0);
		     new_entry.app_symb_index = new_index;
	     }
	     if (!HScresymbentry(msg,(IGRchar *) &new_entry,index,mod_id,mod_osnum))
                  return(0);
	    return(1);

     }


#if defined(__STDC__) || defined(__cplusplus)
	HSretbundentry(		IGRlong *msg,
				 IGRint index,
		 struct HSrender_bundle *entry,
	   struct HSextra_render_bundle *app_entry,
				GRobjid mod_id,
			     GRspacenum mod_osnum )
#else
	HSretbundentry(msg,index,entry,app_entry,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRint		index;
	struct HSrender_bundle	*entry;
	struct HSextra_render_bundle *app_entry;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

/*

NAME
    HSretbundentry

KEYWORD
    Bundle Tables

DESCRIPTION
    This function calls the appropriate functions to do the following
       retrieve the application bundle table entry
       retrieve the shading bundle table entry
       retrieve the texture table entry

PARAMETERS
    msg       (OUT) -
    entry     (OUT) - The shading bundle table entry 
    app_entry (OUT) - The application bundle table entry
    index     (IN)  - The highest level bundle index.
    mod_id    (IN)  - The object id of the module object
    mod_osnum (IN)  - The os number of the module object

GLOBALS USED
    none

RETURN VALUES
    1 success
    0 failure

HISTORY
    --/--/91 Shridar Subramanian

*/
    {


        struct HS_symb_and_app new_entry;

		if (!HSretsymbentry(msg,index, (IGRchar *) &new_entry,mod_id,mod_osnum))
                     return(0);
                memcpy(entry, &new_entry, sizeof(struct HSrender_bundle));
                if (app_entry)
		{       
			if (new_entry.app_symb_index !=-1)
			{
			   if (!HSappretsymb(msg, new_entry.app_symb_index,(IGRchar *) app_entry,
					mod_id,mod_osnum))
                                return(0);
			}
                }
	    return(1);
   } 

        
#if defined(__STDC__) || defined(__cplusplus)
	HSdelbundentry( IGRlong *msg,
			 IGRint index,
			GRobjid mod_id,
		     GRspacenum mod_osnum )
#else
	HSdelbundentry(msg,index,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRint		index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

/*

NAME
    HSdelbundentry

KEYWORD
    Bundle Tables

DESCRIPTION
    This function calls the appropriate functions to do the following
       delete the application bundle table entry
       delete the shading bundle table entry
       delete the texture table entry

PARAMETERS
    msg       (OUT) -
    index     (IN)  - The index of the bundle to be deleted
    mod_id    (IN)  - The object id of the module object
    mod_osnum (IN)  - The os number of the module object

GLOBALS USED
    none

RETURN VALUES
    1 success
    0 failure

HISTORY
    --/--/91 Shridar Subramanian

*/
    {

     struct HS_symb_and_app new_entry;


     if (!HSretsymbentry(msg,index, (IGRchar *) &new_entry,mod_id,mod_osnum))
          return(0);
     if(new_entry.app_symb_index !=-1)
             if (!HSappdelsymb(msg,new_entry.app_symb_index,mod_id,mod_osnum))
                  return(0);
     if (!HSdelsymbentry(msg,index,mod_id,mod_osnum))
          return(0);
     if (new_entry.tex_index !=0)
         if (!HSdel_texture_file(new_entry.tex_index, mod_id, mod_osnum))
              return(0);
     
    return(1);

      
   }

#if defined(__STDC__) || defined(__cplusplus)
	HSchgbundentry( IGRlong *msg,
			 IGRint old_index,
				IGRchar *entry,
			IGRchar *app_entry,
			 IGRint *new_index,
			GRobjid mod_id,
		     GRspacenum mod_osnum )
#else
	HSchgbundentry(msg,old_index,entry,app_entry,new_index,mod_id,mod_osnum)
	
	IGRlong		*msg;
	IGRint		old_index;
	IGRchar		*entry,*app_entry;
	IGRint		*new_index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif
/*

NAME
    HSchgbundentry

KEYWORD
    Bundle Tables

DESCRIPTION
    This function calls the appropriate functions to do the following
       change the application bundle table entry
       change the shading bundle table entry
       change the texture table entry

PARAMETERS
    msg       (OUT) -
    old_index (IN)  - Index of the bundle table entry to be changed
    entry     (IN)  - The new shading bundle entry
    app_entry (IN)  - The new application bundle entry
    new_index (OUT) - The index of the new entry
    mod_id    (IN)  - The object id of the module object
    mod_osnum (IN)  - The os number of the module object

GLOBALS USED
    none

RETURN VALUES
    1 success
    0 failure

HISTORY
    --/--/91 Shridar Subramanian

*/
    {
     struct HS_symb_and_app new_entry;
     IGRint new_app_index;
     IGRshort old_tex_index, new_tex_index;


     if (!HSretsymbentry(msg,old_index, (IGRchar *) &new_entry,mod_id,mod_osnum))
          return(0);
     old_tex_index = new_entry.tex_index;
     if (app_entry)
     {
        if(new_entry.app_symb_index !=-1)
         {
           if (!HSappchgsymb(msg, new_entry.app_symb_index,(IGRchar *) app_entry,
                         &new_app_index,mod_id,mod_osnum))
                             return(0);
           new_entry.app_symb_index = new_app_index;
         }
         else
         {
	   if (!HSappaddsymb(msg,(IGRchar *)app_entry,&new_app_index,mod_id,mod_osnum))
                  return(0);
           new_entry.app_symb_index = new_app_index;
         }  
     }
     memcpy(&new_entry,entry,sizeof (struct HSrender_bundle));
     /*Getting the tex_index after memcpy puts the new index in new_entry*/
     new_tex_index = new_entry.tex_index;
     if (!HSchgsymbentry(msg,old_index,(IGRchar *) &new_entry,new_index,mod_id,mod_osnum))
          return(0);
     if (old_tex_index != new_tex_index)
         HSchg_texture_entry(old_tex_index, new_tex_index, mod_id, mod_osnum);

         /*
          *  Not sure how this can be referenced as a boolean when its
          *  declared a void in HStex_mac.I
                   
         if (!HSchg_texture_entry(old_tex_index, new_tex_index, mod_id, mod_osnum))
              return(0);
              
          */
          
     return(1);
   }




end implementation HStable;
