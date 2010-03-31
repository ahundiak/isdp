class implementation EMSsurface;

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSintf.h"
#include "griodef.h"
#include "msdef.h"
#include "msmacros.h"         /* struct MS_sd_msg for ex$message */
#include "emssfintdef.h"
#include "emsbool.h"
#include "emserr.h"
#include "emsmacros.h"
#include "ems_m_inc.h"
#include "EMSdpb.h"
#include "ECmsg.h"

IGRlong EManalyzeInterference(EMmsg,Setinfo1,Ele1,NumEle1,setnum1,
				    Setinfo2,Ele2,NumEle2,setnum2,
				    options,filename,result,num_result)
IGRlong *EMmsg;
struct GRlc_info *Setinfo1, *Ele1;
IGRint NumEle1, setnum1;
struct GRlc_info *Setinfo2, *Ele2;
IGRint NumEle2, setnum2;
IGRushort options;
IGRchar *filename;
struct EMSintf **result;
IGRint *num_result;
{
    struct GRvg_construct konst;
    IGRlong             sts,rc;
    IGRint              bytes_in,bytes_out,i, total_result = 0;
    IGRshort level;
    extern void         EMintf_free();
    IGRboolean          hilted = FALSE;
   struct IGRdisplay  dispbuffer;
   struct GRmd_env md_env;
 
printf("begin of intf\n");
    gr$get_active_level(
               buffer = &level) ;

printf("level %d\n",level);
    bytes_in = sizeof(dispbuffer);
    gr$get_active_display(
               msg = &rc,
               sizbuf = &bytes_in,
               buffer = &dispbuffer,
               nret = &bytes_out);

  
printf("gotbuf\n");
    bytes_in = sizeof(md_env);

    gr$get_module_env(
               msg = &rc,
               sizbuf = &bytes_in,
               buffer = &md_env,
               nret = &bytes_out);

printf("gotenv\n");
    konst.msg        = &rc;
    konst.level = level;
    konst.class_attr = NULL;
    konst.newflag    = FALSE;
    konst.name       = NULL;
    konst.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    konst.geometry   = NULL;
    konst.display = &dispbuffer;
    konst.env_info = &md_env;
 
    *EMmsg=1;
printf("going to analyze\n");
    sts = EManalyzeIntf(
                        EMmsg, 
                        Setinfo1,
                        Ele1,
                        NumEle1,
                        setnum1,
  			Setinfo2,
			Ele2,
			NumEle2,
			setnum2,
                        options,
                        filename,
                        &konst,
                        result,
                        num_result);
  if (EMSerror (rc & sts))
     ex$message(msgnumb = EMS_E_AnalysisFailed)
  else
  if(!num_result)
     ex$message(msgnumb = EMS_I_NoIntfFound)
  else
  {
    ex$message(msgnumb = EMS_I_AnalysisComplete)
    hilted = FALSE;
    if (!(options & EMSintf_NoCurves))
    {
     IGRint i, j;

     for (i=0; i<*num_result && !hilted; i++)
      for(j=0; j<(*result)[i].numintf && !hilted; j++)
         if (!IF_NULL_OBJID (
             (*result)[i].info.qualitative[j].inters.objid))
             hilted = TRUE;
         if (hilted)
           ex$message(msgnumb = EMS_I_AnlCompCvHiLted)
    }
    if (!(options & EMSintf_NoVolElems))
    {
     IGRint i, j;
 
     for (i=0; i<*num_result && !hilted; i++)
      for(j=0; j<(*result)[i].numintf && !hilted; j++)
         if (!IF_NULL_OBJID (
              (*result)[i].info.qualitative[j].volelem.objid))
                  hilted = TRUE;
 
            if (hilted)
              ex$message(msgnumb = EMS_I_AnlCompVolHiLted)

    }
    
    if (*result)
          EMintf_free (*result, *num_result);

   }
}

end implementation EMSsurface;
