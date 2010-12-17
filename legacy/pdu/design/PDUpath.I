class implementation COpdu;

#include  <PDUint.h>
#include  <PDUintdef.h>
#include  <PDUerror.h>
#include  <PDUstorage.h>
#include  <ex.h>
#include  <exmacros.h>
#include  <exdef.h>
#include  <expriv.h>
#include  <ciexecmacros.h>
#include  <string.h>
#include  <grio.h>
#include  <griomacros.h>
#include  <griodef.h>


extern struct PDUstorage *storage;

IGRint PDUprocess_function(filename)

IGRchar *filename;
  {

   IGRint sts;
   IGRint response;
   IGRint length;
   IGRchar *file = NULL;
   GRobjid ppl_objid;
   GRobjid ppl_objid1;
   extern IGRchar *PDU_attr_value;
   extern struct PDUstorage *storage;


   _pdm_debug("storage path name = <%s>", storage->path_name);
   length = strlen(filename) + strlen(storage->path_name) + 5;
   file = (char *)malloc(length);
   memset(file, NULL, length);
   strcpy(file, storage->path_name);
   strcat(file, "/");
   *((char *) strrchr(filename, '.')) = '\0';
   strcat(file, filename);
   _pdm_debug("file = <%s>", file);
   sts = ci$load(file_name = file,
                file_id         = &ppl_objid1,
                sender_id       = NULL_OBJID);

   if( ppl_objid1 == NULL_OBJID )
     {
     _pdm_debug("ci$load FAILED", 0);
      return(0);
     }


   sts = ci$run(file_id = &ppl_objid1,
                sender_id=NULL_OBJID,
                retval = &response );

   sts = ci$load(file_name = "process_val",
                file_id         = &ppl_objid,
                sender_id       = NULL_OBJID);

   if( ppl_objid == NULL_OBJID )
     {
     _pdm_debug("ci$load FAILED", 0);
      return(0);
     }


   sts = ci$run(file_id = &ppl_objid,
                sender_id=NULL_OBJID,
                retval = &response );
   return(PDM_S_SUCCESS);
  }

end implementation COpdu;

