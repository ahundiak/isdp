/* ==============================================
 * More for grins than anything else, try to
 * rewrite some som code
 */
#include "config.h"
#include <stdlib.h>
#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMspecify.h"
#include "OMrelation.h"
#include "OMextern.h"

/* ======================================
 * Root Instance
 */
struct Root_instance 
{
    OM_S_OBJECTHDR OPPobjecthdr;
};
struct OMISO_instance 
{
    OMuword osnum;              // osnum of external object space
    OMuword w_ISO_flags;
    OMuword w_dcount;
    OMuword w_dummy;
    OM_S_OBJID S_target_iso;    // objid of iso object in external object space

    int i_first;

    struct OM_sd_varlenarr_descr iso_d_descr;
};
struct OMISO_total_instance
{
    struct Root_instance  Root;
    struct OMISO_instance OMISO;
};
struct ISO_data
{
    OMuword      w_flags;
    OM_S_CHANNUM chan;
    union  
    {
        int i_next;
        OM_S_OBJID s_objid; // Object withind os being pointed at
    } iso_u;
};

/*=======================================================================
      function:  som_ISO_fetch

      description:  This function is used to traverse across the ISO
                      zone between two object spaces and fetch information
                      about the object on the other side.

      input args:   OMuword	 OSnum1     Source Object Space number
                    OMuword      index      ISO index
                    OM_S_OBJID   iso_objid  Source ISO object id

      output args:  OMuword      *OSnum2    Destination Object Space number
                    OM_S_OBJID   *objid     Destination object id
                    OM_S_CHANNUM *chan      Destination object's channel number
                    OMuword      *flags     Destination object's flag word

      change history:
=======================================================================*/

#define SOM_TRACEx 1
extern int OM_Gi_OMISO_debug;

/* ==============================================
 * This one seems to have many core dumps
 */
int som_ISO_fetch(
    OMuword       OSnum1,
    OMuword       index,
    OM_S_OBJID    iso_objid,

    OMuword      *OSnum2,
    OM_S_OBJID   *objid,
    OM_p_CHANNUM  chan,
    OMuword      *flags)
{
    OM_S_RIP  iso_rip1, iso_rip2;

    struct    OMISO_instance  *myme, *p_iso2;

    struct    ISO_data *p_iso_data;
    int sts;

    int trace = 1;

    if (trace) 
    {
        printf(">>> som_ISO_fetch: %d,%d index=%d\n",OSnum1,iso_objid,index);
    }

    // Get a pointer to the source iso
    sts = som_get_any_instance(OSnum1, iso_objid, &iso_rip1) ; 
    if (!(sts & 1)) 
    { 
        // This caught a bogus id: 47,1072693248
        if (trace) printf("*** som_ISO_fetch STS Odd: No source ISO instance\n");

        return(sts) ; 
    } 
    myme = &(((struct OMISO_total_instance *) iso_rip1.p_object)->OMISO);
    *OSnum2 = myme->osnum;

    /*  verify that destination OS is active  */
    if ( myme->w_ISO_flags & ISO_no_target )  
    {
        if (trace) printf("*** som_ISO_fetch OM_W_OSNOTACTIVE: ISO inactive\n");

       //om$release_any_instance (osnum = OSnum1, rip = iso_rip1);
        return (OM_W_OSNOTACTIVE);
    }

    /* check for logical disconnection */
  //p_iso_data = &(P(myme->iso_d)[index]);
  // The i_ossfet part is strange unless i_offset is a full address in which cah it should be a pointer?
    p_iso_data = &( ((struct ISO_data *)(myme->iso_d_descr.i_offset))[index] ) ; 

  //p_iso_data = &(P(myme->iso_d)[index]);

/* ===========================================
 * Need some sort of check that index is valid?
 */
    if ( p_iso_data->w_flags & ISO_logical_disconnect ) 
    {
        //om$release_any_instance (osnum=OSnum1, rip=iso_rip1);
        if (trace) printf("### som_ISO_fetch OM_I_LOGICAL_DISCONNECT: Source ISO Channel Object\n");

        return (OM_I_LOGICAL_DISCONNECT);
    }

    /*  get pointer to destination ISO instance  */
    sts = som_get_any_instance(*OSnum2, myme->S_target_iso, &iso_rip2) ; 
    if (!(sts & 1))
    {
      if (trace) printf("*** som_ISO_fetch OM_F_BUGCHECK Target ISO Instance\n");

      //BUGCHECK("som_ISO_fetch: target ISO no instance");
      //om$release_any_instance(osnum = OSnum1, rip = iso_rip1 );
      return (OM_F_BUGCHECK);
    }

    p_iso2 = &(((struct OMISO_total_instance *)iso_rip2.p_object)->OMISO);
    p_iso_data = &(((struct ISO_data *)(p_iso2->iso_d_descr.i_offset))[index]) ; 

    /* check for logical disconnection */
    if ( p_iso_data->w_flags & ISO_logical_disconnect ) {
       //om$release_any_instance (osnum=OSnum1, rip=iso_rip1);
       //om$release_any_instance (osnum=OSnum2, rip=iso_rip2);

        if (trace) printf("### som_ISO_fetch OM_I_LOGICAL_DISCONNECT Target Instance\n");

       return (OM_I_LOGICAL_DISCONNECT);
    }
    if ( p_iso_data->w_flags & ISO_disconnected )
    {
        //BUGCHECK("som_ISO_fetch: one side disconnected");
        //om$release_any_instance(osnum = OSnum1, rip = iso_rip1);
        //om$release_any_instance(osnum = OSnum2, rip = iso_rip2);

        if (trace) printf("*** som_ISO_fetch OM_E_BADSTATE ISO_disconnected\n");

        return (OM_E_BADSTATE);
    }

    *objid = p_iso_data->iso_u.s_objid;
    *chan  = p_iso_data->chan;

    /* ==========================================================
     * Originall comment this out because I didn't have  OM_GA_OSDs defined
     * Still seemed to work okay
     */
   //chan->classid = OM_GA_OSDs[*OSnum2]->FilToAct[chan->classid];
    *flags = 0;

    //om$release_any_instance(osnum = OSnum1, rip = iso_rip1);
    //om$release_any_instance(osnum = OSnum2, rip = iso_rip2);

    if (trace) 
    {
        printf("<<< som_ISO_trace Returned: %d,%d chan=(%d,%d) flags=%#x\n",
	   *OSnum2, *objid, chan->classid, chan->number, *flags);
    } 
    return (OM_S_SUCCESS);
}

