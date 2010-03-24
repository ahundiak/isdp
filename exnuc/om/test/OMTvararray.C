#include "OMobjectcomm.h"

#define MAXA 3

main()
{
   int                  sts, i, zero=0, one=1, five=5, ten=10;
   OM_S_OBJID           a_objid[MAXA];
   OMuword              count, siz;
   OM_S_MESSAGE	        asgndbl, asgnlg, asgnsh, asgnch, asgnstr, showdbl,
		        showlg, showsh, showch, showstr;
   OMuword	        OSnum;
   

   sts = om$runtime_init();
   if (!(sts&1))
   {
      printf (" error in om$runtine_init\n");
      om$report_error(sts = sts);
      exit();
   }

   OSnum = OM_Gw_TransOSnum_0;
   
   for ( i=0; i<MAXA; i++ )
   {
      sts = om$construct(osnum = OM_Gw_current_OS,
                         classname = "A",
                         p_objid = &a_objid[i],
                         neighbor = OM_GS_NULL_NEIGHBOR);
      if (!(sts&1))
      {
         printf (" error in om$construct for A : %x \n", sts );
         om$report_error(sts = sts);
         printf (" iteration : %d \n", i );
         exit();
      }
   }

   sts = om$make_message(classname = "A",
                         methodname = "var_assign_dbl",
                         size = 4,
                         p_arglist = &ten,
                         p_msg = &asgndbl);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_assign_dbl: %x \n", sts);
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &asgndbl,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send msg= var_assign_dbl: %x \n", sts);
	om$report_error(sts = sts);
	exit();
   }
}

   sts = om$make_message(classname = "A",
                         methodname = "var_assign_long",
                         size = 4,
                         p_arglist = &ten,
                         p_msg = &asgnlg);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_assign_long\n");
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &asgnlg,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send for var_assign_long\n");
	om$report_error(sts = sts);
	exit();
   }
}

   sts = om$make_message(classname = "A",
                         methodname = "var_assign_short",
                         size = 1,
                         p_arglist = &one,
                         p_msg = &asgnsh);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_assign_short\n");
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &asgnsh,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send for var_assign_short\n");
	om$report_error(sts = sts);
	exit();
   }
}

   sts = om$make_message(classname = "A",
                         methodname = "var_assign_char",
                         size = 4,
                         p_arglist = &ten,
                         p_msg = &asgnch);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_assign_char\n");
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &asgnch,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send for var_assign_char\n");
	om$report_error(sts = sts);
	exit();
   }
}

   sts = om$make_message(classname = "A",
                         methodname = "var_assign_struct",
                         size = 1,
                         p_arglist = &one,
                         p_msg = &asgnstr);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_assign_struct\n");
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &asgnstr,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send for var_assign_struct\n");
	om$report_error(sts = sts);
	exit();
   }
}

   sts = om$make_message(classname = "A",
                         methodname = "var_show_dbl",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &showdbl);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_show_dbl\n");
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showdbl,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send for var_show_dbl\n");
	om$report_error(sts = sts);
	exit();
   }
}

   sts = om$make_message(classname = "A",
                         methodname = "var_show_long",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &showlg);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_show_long\n");
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showlg,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send for var_show_long\n");
	om$report_error(sts = sts);
	exit();
   }
}

   sts = om$make_message(classname = "A",
                         methodname = "var_show_short",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &showsh);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_show_short\n");
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showsh,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send for var_show_short\n");
	om$report_error(sts = sts);
	exit();
   }
}

   sts = om$make_message(classname = "A",
                         methodname = "var_show_char",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &showch);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_show_char\n");
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showch,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send for var_show_char\n");
	om$report_error(sts = sts);
	exit();
   }
}

   sts = om$make_message(classname = "A",
                         methodname = "var_show_struct",
                         size = 0,
                         p_arglist = 0,
                         p_msg = &showstr);
   if(!(sts&1))
   {
	printf("error in om$make_message for var_show_struct\n");
	om$report_error(sts = sts);
	exit();
   }
for ( i=0; i<MAXA; i++ )
{
   sts = om$send(mode = OM_e_wrt_object,
                 msg = &showstr,
                 senderid = a_objid[i],
                 targetid = a_objid[i]);
   if(!(sts&1))
   {
	printf("error in om$send for var_show_struct\n");
	om$report_error(sts = sts);
	exit();
   }
}

return(OM_S_SUCCESS);
}  /* main */
