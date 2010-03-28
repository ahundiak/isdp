/*
 * GRaphics include file 
 */


   /*
    *  This include is dependent of the following include files:
    *
    *		igetypdef.h
    *           igrtypdef.h
    */


#ifndef gr_include

#  define gr_include		



   struct GRid				/* object identifier structure	*/
   {
 	GRspacenum osnum;		/* space number of object	*/
	GRobjid	   objid;		/* object id of object		*/
   };

   
   struct GRmdenv_info
   {
	IGRshort	matrix_type;
	IGRmatrix	matrix;
   };

   struct GRmd_env
   {
       struct GRid	 		 md_id;
       struct GRmdenv_info		 md_env;
   };

   struct GRobjid_set
   {
       IGRint		num_ids;
       GRobjid		*objids;
   };

#endif

