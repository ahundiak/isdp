class implementation sym;

/*  Test routine for symbolic connections. */

#include "OMobjectcomm.h"
#include "OMintprims.h"
#include "OMmacros.h"

#define NUMCHANS 6
#define NUMOS 7
#define NUMOBJS 1

#define STAT(sts) \
(((sts)==OM_I_NOMATCH)?"OM_I_NOMATCH":(((sts)==OM_I_UNABLE_TO_CONNECT)?"OM_I_UNABLE_TO_CONNECT":(((sts)==OM_S_SUCCESS)?"OM_S_SUCCESS":"UNKNOWN")))

#define CONNECTED 1
#define NOTCONNECTED 0

from OMObjSpace import make_symconnect,remove_symconnect, translate_symconnect,
get_symconnect_name;

from OMSymCon import purge;

/*----------------*/
/* Error handler. */
/*----------------*/

static void err(sts,rem)
int  sts;  /* caused the error */
char *rem; /* remark to print */
{
   printf("\nERROR !!!\n%s\n",rem);
   om$report_error(sts=sts);
   exit(0);
}

/*------------------------------------------------------------------------*/
/* Main function constructs OSO's, test objects an kicks off the test(s). */
/*------------------------------------------------------------------------*/

maini(count,args)
int  count;   /* number of args on command line */
char *args[]; /* pointers to args */
{
   int               sts;             
   OM_S_OBJID        objid[NUMOS][NUMOBJS];
   OM_S_OBJID        os_objid[NUMOS];
   OMuword           osnum[NUMOS];
   static char       *osname[NUMOS] = 
                            { "os0","os1","os2","os3","os4","os5","os6" };
   OMuword           classid;
   static char       *name[NUMCHANS] = {"A","B","C","D","E","F"};
   static char       *channame[NUMCHANS] = 
                          {"sym.chan0", "sym.chan1", "sym.chan2", "sym.chan3",
                           "sym.chan4", "sym.chan5" };
   int               ii,jj,kk;
   int               index;
   int               stat;
   OM_S_CHANSELECT   sym_sel;
   OM_S_CHANSELECT   c_sel;

   printf("\nSymbolic Connection Tests:\n\n");

   printf("runtime initialization ...\n");
   sts = om$runtime_init();
   if (!(1&sts)) err(sts,"runtime_init");
   printf(" complete.\n\n");

   printf("Constructing object spaces.\n");

   for (ii=0; ii < NUMOS; ++ii)
   {
      sts = om$construct_os(classname="OMFiledOS",
                            p_objid=&os_objid[ii],
                            osnum=&osnum[ii],
                            osname=osname[ii]);
      if (!(1&sts))
         err(sts,"om$construct_os");
      printf("\tosnum[%d] = %d, os_objid[%d] = %d\n",
             ii,osnum[ii],ii,os_objid[ii]);
   }

   printf("Constructing test objects.\n");

   for (ii=0; ii < NUMOS; ++ii)
      for (jj=0; jj < NUMOBJS; ++jj)
      {
         sts = om$construct(classname="sym",
                            p_objid=&objid[ii][jj],
                            osnum=osnum[ii]);
         if (!(1&sts))
            err(sts,"om$construct");
         printf("\tobjid[%d][%d] = %d\n",ii,jj,objid[ii][jj]);  
      }
 
   sts = om$get_classid(classname = "sym",
                        p_classid = &classid);
   if (!(1&sts))
      err(sts,"get classid maini.");

#ifndef DEBUG
   sym_sel.type = OM_e_num;
   sym_sel.u_sel.number.classid = classid;

   sts = om$send(msg = message sym.makecon1(name),
                 senderid = NULL_OBJID,
                 targetos = osnum[0],
                 targetid = objid[0][0]);
   if (!(1&sts))
      err(sts,"Send for makecon1");
   
   c_sel.type = OM_e_name;
   c_sel.u_sel.name = "OMObjSpace.to_NamObjDir";

   /*-------------------------------*/
   /*  First phase of connections.  */
   /*-------------------------------*/

   for (ii=0; ii < NUMCHANS; ++ii)
   {
      /*-------------------------*/
      /*  Make the connections.  */
      /*-------------------------*/

      printf("\n\n\n\n");

      for (jj=0; jj < NUMCHANS; ++jj)
      {
         index = jj - ii;

         if (index >= 0)
         {
            /*------------------------------------------*/
            /*  Make a symbolic connect of channel jj,  */
            /*  using connect name[index].              */
            /*------------------------------------------*/
      
            sts = om$send(msg = message sym.makecon2(name[index],jj),
                          senderid = NULL_OBJID,
                          targetid = objid[1][0],
                          targetos = osnum[1]);

            if (!(1&sts))
            {
               printf("Error in iteration %d\n",jj);
               err(sts,"send to make connect phase1.");
            }
      
            /*------------------------*/
            /*  Test the connection.  */
            /*------------------------*/

            stat = NOTCONNECTED;
            sym_sel.u_sel.number.number = jj;

            sts = om$send(msg = message sym.test(&stat),
                          p_chanselect = &sym_sel,
                          senderid = objid[1][0],
                          targetos = osnum[1]);

            if (!(1&sts))
               err(sts,"send to test make phase1.");

            if (stat != CONNECTED)
               err(sts,"send to test make phase1, NOTCONNECTED");             
         }
      }         

      /*--------------------------*/
      /*  Dump the symbol table.  */
      /*--------------------------*/

      sts = om$send( msg = message OMSymCon.debug(),
                     senderid = os_objid[1],
                     targetos = osnum[1],
                     p_chanselect = &c_sel);

      if (!(1&sts))
         err(sts,"debug error phase1");

      /*---------------------------*/
      /*  Remove the connections.  */
      /*---------------------------*/

      for (jj=0; jj < NUMCHANS; ++jj)
      {
         index = jj - ii;

         if (index >= 0)
         {
            /*----------------------------------------*/
            /*  Remove the connection on channel jj,  */
            /*  using connect name[index].            */
            /*----------------------------------------*/
      
            sts = om$send(msg = message sym.removecon(name[index],jj),
                          targetid = objid[1][0],
                          senderid = NULL_OBJID,
                          targetos = osnum[1]);

            if (!(1&sts))
            {
               printf("Error in iteration %d\n",jj);
               err(sts,"send to remove connection phase1.");
            }
      
            /*-------------------------------------*/
            /*  Make sure the connection is gone.  */
            /*-------------------------------------*/

            stat = NOTCONNECTED;
            sym_sel.u_sel.number.number = jj;

            sts = om$send(msg = message sym.test(&stat),
                          p_chanselect = &sym_sel,
                          senderid = objid[1][0],
                          targetos = osnum[1]);

            if (!(1&sts))
               err(sts,"send to test remove phase1.");

            if (stat != NOTCONNECTED)
               err(sts,"send to test remove phase1, NOTCONNECTED");
         }
      }         

   }

   /*--------------------------------*/
   /*  Second phase of connections.  */
   /*--------------------------------*/

   for (ii=0; ii < NUMCHANS; ++ii)
   {
      /*-------------------------*/
      /*  Make the connections.  */
      /*-------------------------*/

      printf("\n\n\n\n");

      for (jj=0; jj < NUMCHANS; ++jj)
      {
         index = jj + ii;

         if (index < NUMCHANS)
         {
            /*------------------------------------------*/
            /*  Make a symbolic connect of channel jj,  */
            /*  using connect name[index].              */
            /*------------------------------------------*/

            sts = om$send (msg = message sym.makecon2(name[index],jj),
                           targetid = objid[1][0],
                           senderid = NULL_OBJID,
                           targetos = osnum[1]);
            if (!(1&sts))
            {
               printf("Error in iteration %d\n",jj);
               err(sts,"send to make connect phase2.");
            }
      
            /*------------------------*/
            /*  Test the connection.  */
            /*------------------------*/

            stat = NOTCONNECTED;
            sym_sel.u_sel.number.number = jj;

            sts = om$send(msg = message sym.test(&stat),
                          p_chanselect = &sym_sel,
                          senderid = objid[1][0],
                          targetos = osnum[1]);

            if (!(1&sts))
               err(sts,"send to test make phase2.");

            if (stat != CONNECTED)
               err(sts,"send to test make phase2, NOTCONNECTED");             
         }
      }         

      /*--------------------------*/
      /*  Dump the symbol table.  */
      /*--------------------------*/

      sts = om$send( msg = message OMSymCon.debug(),
                     senderid = os_objid[1],
                     targetos = osnum[1],
                     p_chanselect = &c_sel);

      if (!(1&sts))
         err(sts,"debug error phase2");

      /*---------------------------*/
      /*  Remove the connections.  */
      /*---------------------------*/

      for (jj=0; jj < NUMCHANS; ++jj)
      {
         index = jj + ii;

         if (index < NUMCHANS)
         {
            /*----------------------------------------*/
            /*  Remove the connection on channel jj,  */
            /*  using connect name[index].            */
            /*----------------------------------------*/
      
            sts = om$send(msg = message sym.removecon(name[index],jj),
                          targetid = objid[1][0],
                          senderid = NULL_OBJID,
                          targetos = osnum[1]);

            if (!(1&sts))
            {
               printf("Error in iteration %d\n",jj);
               err(sts,"send to remove connection phase2.");
            }
      
            /*-------------------------------------*/
            /*  Make sure the connection is gone.  */
            /*-------------------------------------*/

            stat = NOTCONNECTED;
            sym_sel.u_sel.number.number = jj;

            sts = om$send(msg = message sym.test(&stat),
                          p_chanselect = &sym_sel,
                          senderid = objid[1][0],
                          targetos = osnum[1]);

            if (!(1&sts))
               err(sts,"send to test remove phase2.");

            if (stat != NOTCONNECTED)
               err(sts,"send to test remove phase2, NOTCONNECTED");
         }
      }         

   }

   /*-------------------------------*/
   /*  Multiple Object Space test.  */
   /*-------------------------------*/

   for (ii=4; ii < NUMCHANS; ++ii)
   {
      /*------------------------------------------*/
      /*  Make symbolic connection in osnum[kk],  */
      /*  objid[kk][0].  Use name[jj], channel    */
      /*  number ii.                              */
      /*------------------------------------------*/

      for (jj=4; jj < NUMCHANS; ++jj)
      {
         printf("\n\n");
         for (kk=1; kk < NUMOS; ++kk)
         {
            sts = om$send (msg = message sym.makecon2(name[jj],ii),
                           targetid = objid[kk][0],
                           senderid = NULL_OBJID,
                           targetos = osnum[kk]);
            if (!(1&sts))
            {
               printf("Error in iteration %d\n",kk);
               err(sts,"send to make connect in multiple object spaces.");
            }
         }

         /*-------------------------------*/
         /*  Dump channel ii, in all os.  */
         /*-------------------------------*/

         for (kk=1; kk < NUMOS; ++kk)
            OMT_dump_relation(osnum[kk],objid[kk][0],channame[ii]);

         /*--------------------------------------------*/
         /*  Remove symbolic connection in osnum[kk],  */
         /*  objid[kk][0].  Use name[jj], channel      */
         /*  number ii.                                */
         /*--------------------------------------------*/

         printf("\n\n\n");
         for (kk=1; kk < NUMOS; ++kk)
         {
            sts = om$send (msg = message sym.removecon(name[jj],ii),
                           targetid = objid[kk][0],
                           senderid = NULL_OBJID,
                           targetos = osnum[kk]);
            if (!(1&sts))
            {
               printf("Error in iteration %d\n",kk);
               err(sts,"send to remove connect in multiple object spaces.");
            }
         }
      }
   }

#endif

   /*-------------------*/
   /*  Translate test.  */
   /*-------------------*/

   printf("\n\n\n\ntranslate test ... \n\n");

   for (jj=0; jj < NUMCHANS; ++jj)
   {
      sts = om$send(msg = message sym.makecon2(name[jj],jj),
                    senderid = NULL_OBJID,
                    targetid = objid[1][0],
                    targetos = osnum[1]);

      if (!(1&sts))
      {
         printf("Error in iteration %d\n",jj);
         err(sts,"send to make connect translate test.");
      }
   }         

   for (jj=0; jj < NUMCHANS; ++jj)
   {
      OM_S_SYMENTRY symbol;
         
      strncpy(symbol.name,name[jj],OM_K_MAXCONNAME_LEN);
      symbol.channum.number = 0;
      symbol.channum.classid = 0;

      sts = om$send(msg=message OMObjSpace.translate_symconnect(&symbol),
                    targetid = os_objid[1],
                    senderid = os_objid[1],
                    targetos = osnum[1]);

      if (!(1&sts))
         err (sts,"translate send.");
   
      if ((symbol.channum.classid != classid) || 
          (symbol.channum.number != jj) || 
          (! IF_EQ_OBJID(symbol.objid,objid[1][0])))
            err (0,"translate matching failed.");

   }
 
   printf("\ntranslate test completed.\n");

   /*--------------------*/
   /*   Get name test.   */
   /*--------------------*/

#ifdef DEBUG
{
   int sts;
   om$send(msg= message sym.test(&sts),
           targetid = objid[1][0],
           targetos = osnum[1],
           senderid = NULL_OBJID);
}
#endif

   printf("\nget name test ... \n");

   for (jj=0; jj < NUMCHANS; ++jj)
   {
      char *list;
      int  size;
      int count;
      OM_S_CHANNUM channum;

      channum.number = jj;
      channum.classid = classid;

      list = (char *)malloc(OM_K_MAXCONNAME_LEN+1);
      size = 1;
         
      sts = om$send(msg=message 
                      OMObjSpace.get_symconnect_name
                         (objid[1][0],
                          channum,
                          list,
                          size,
                          &count),
                    targetid = os_objid[1],
                    senderid = os_objid[1],
                    targetos = osnum[1]);

      if (sts != OM_S_SUCCESS)
      {
         printf("iteration: %d\n",jj);
         err (sts,"get name send.");
      }
   
      if (strcmp(list,name[jj]))
      {
         printf("iteration: %d\n",jj);
         err (0,"get name comparison failed.");
      }

   }
 
   printf("get name test completed.\n");

   return (OM_S_SUCCESS);
}

method makecon1(char **name)
{
   int               sts;
   int               ii;
   OM_S_SYMENTRY     symbol;
   OMuword           sym_classid;

   printf("\nMaking symbolic connection(s), os=%d, objid=%d\n",
          OM_Gw_current_OS, my_id);   

   sts = om$get_classid(classname = "sym", p_classid=&sym_classid);
   if (!(1&sts)) err(sts,"get_classid");

   for (ii=0; ii < NUMCHANS; ++ii)
   {
      strcpy(symbol.name,name[ii]);
      symbol.objid = my_id;
      symbol.channum.classid = sym_classid;
      symbol.channum.number = ii;

      sts = om$send ( msg = message 
                            OMObjSpace.make_symconnect(&symbol,ii),
                      targetid = OM_GO_current_OS_objid);

      printf("symbol = %s.%d.%d.%d   status = %s\n",symbol.name, symbol.objid,
              symbol.channum.classid,symbol.channum.number,STAT(sts));

      if ((!(1&sts)) && (sts != OM_E_BADCHAN_TYPE))
         err(sts,"makecon1 send");
   }

   printf("\n");

   return (OM_S_SUCCESS);
}   

method makecon2(char *name; OMuword cnum)
{
   int               sts;
   int               ii;
   OM_S_SYMENTRY     symbol;
   OMuword           sym_classid;

   printf("make connect:");

   sts = om$get_classid(classname = "sym", p_classid=&sym_classid);
   if (!(1&sts)) err(sts,"get_classid");

   strcpy(symbol.name,name);
   symbol.objid = my_id;
   symbol.channum.classid = sym_classid;
   symbol.channum.number = cnum;

   sts = om$send ( msg = message 
                         OMObjSpace.make_symconnect(&symbol,cnum),
                   targetid = OM_GO_current_OS_objid);

   printf("symbol = %s.%d.%d.%d, os = %d, sts = %s\n",symbol.name,symbol.objid,
          symbol.channum.classid,symbol.channum.number,OM_Gw_current_OS,
          STAT(sts));

   return (sts);
}   

method removecon(char *name; OMuword cnum)
{
   int               sts;
   int               ii;
   OM_S_SYMENTRY     symbol;
   OMuword           sym_classid;

   printf("remove connect:");

   sts = om$get_classid(classname = "sym", p_classid=&sym_classid);
   if (!(1&sts)) err(sts,"get_classid");

   strcpy(symbol.name,name);
   symbol.objid = my_id;
   symbol.channum.classid = sym_classid;
   symbol.channum.number = cnum;

   sts = om$send ( msg = message 
                         OMObjSpace.remove_symconnect(&symbol),
                   targetid = OM_GO_current_OS_objid);

   printf("symbol = %s.%d.%d.%d, os = %d, sts = %s\n",symbol.name,symbol.objid,
          symbol.channum.classid,symbol.channum.number,OM_Gw_current_OS,
          STAT(sts));

   return (sts);
}

method test(int *p_sts)
{
  *p_sts = CONNECTED;
  return (OM_S_SUCCESS);
}

end implementation sym;
