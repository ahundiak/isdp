class implementation EMAplane;

#include "OMmacros.h"
#include "REplane.h"

method debug()
{
    IGRlong sts, EMmsg;
    struct EMSconverted_plane *my_info = NULL;
    IGRuint                   type, size;

 sts = om$send(msg = message EMSassoc.EMget_info(&EMmsg, NULL, &type, &size, 
       NULL), targetid = my_id);
 if(!(1&sts&EMmsg)) goto wrapup;
 if( (type != EMS_ASplane_converted_plane) || !size) goto wrapup;

 my_info = (struct EMSconverted_plane *) om$malloc(size = size);
 if(!my_info) goto wrapup;

 sts = om$send(msg = message EMSassoc.EMget_info(&EMmsg, NULL, &type, &size, 
       (IGRchar **) &my_info), targetid = my_id);
 if(!(1&sts&EMmsg)) goto wrapup;

 fprintf(stderr, "EMAplane object = %d\n", my_id);
 fprintf(stderr, "Original type = %d\n", my_info->orig_type);
 fprintf(stderr, "Original info = 0x%x\n", my_info->orig_info);
 fprintf(stderr, "Original info size = %d\n", my_info->orig_info_size);
 fprintf(stderr, "Original classname = %s\n", my_info->orig_classname);

wrapup:
 if(my_info) om$dealloc(ptr = my_info);
 return(om$send(mode = OM_e_wrt_message, msg = message EMSplane.debug(), 
         targetid = my_id));
}

end implementation EMAplane;
