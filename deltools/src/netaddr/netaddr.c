#ifdef sgi
#include <sys/syssgi.h>
#endif
#ifdef SCO
#include <sys/types.h>
#include <sys/stropts.h>
#include <sys/dlpi.h>
#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include </usr/include/sys/macstat.h>
#include </usr/include/sys/stropts.h>
#endif
#ifdef _AIX
#  include <sys/statfs.h>
#  include <sys/device.h>
#  include <sys/devinfo.h>
#  include <sys/ioctl.h>
#  include <sys/comio.h>
#endif
main()
{
#ifdef SCO
    int                         nfd;
    unsigned char		eaddr[6];
    unsigned char		s_eaddr;
    struct strbuf               ctlbuf;
    struct strbuf               ctldat; 
    dl_attach_req_t          	attach_req;
    dl_info_req_t		info_req;
    union DL_primitives         rcvbuf;
    union DL_primitives         datbuf;
    int				flags;
    short 			i;
    struct strioctl		gea;

    /*
    ** 17 NOV 1994   SCW
    **
    ** New ISMP systems use a different ethernet adapter, and
    ** have a different device name.  Start using the same kind
    ** of "interfaces" file we have adopted for Intel Solaris
    ** to make it easier to handle "legal" interfaces.
    */
    char			*iflist, *c;
    char			netif[80];
    FILE			*lfd;
    static char *interfaces[] = { "/dev/pnt0",
                                  "/dev/i3B0",
                                  "/dev/e3B0",
                                  "" };

    iflist = "/usr/ip32/deltools/interfaces";
    lfd = fopen(iflist, "r");
    if (lfd) {
        nfd = -1;
        while (fgets(netif, 80, lfd)) {

            if (*netif == '#')
                continue;

            /*
            ** Strip off newline
            */
            c = strchr(netif, '\n');
            if (c)
                *c = '\0';

            if ((nfd = open(netif, O_RDWR)) >= 0)
                break;
        }
        fclose(lfd);

        if (nfd < 0)
            return(-1);
    }
    else {
        /*
        ** Couldn't open any "interface" list.
        ** try a small list of known interfaces.
        */
        for (nfd = -1, i = 0; *interfaces[i]; i++) {
            if ((nfd = open(interfaces[i], O_RDWR)) >= 0)
                break;
        }

        /* See if we got a valid file descriptor */
        if (nfd < 0)
            return(-1);
    }

    for (i=0;i<6;++i){
	eaddr[i]=0xff;
    }
    gea.ic_cmd=MACIOC_GETADDR;
    gea.ic_timout=INFTIM;
    gea.ic_len=6;
    gea.ic_dp=eaddr;
    if (( ioctl(nfd,I_STR,&gea)) < 0) {
	perror("ioctl error");
    }
    s_eaddr=eaddr[5];
    printf("Ethernet address: %02x-%02x-%02x-%02x-%02x-%02x\n",
                eaddr[0], eaddr[1], eaddr[2], eaddr[3], eaddr[4], eaddr[5]);
    for (i=0;i<6;++i){
	eaddr[i]=0xff;
    }
    gea.ic_cmd=MACIOC_GETRADDR;
    gea.ic_timout=INFTIM;
    gea.ic_len=6;
    gea.ic_dp=eaddr;
    if (( ioctl(nfd,I_STR,&gea)) < 0) {
	perror("ioctl error");
    }
    printf("Factory address : %02x-%02x-%02x-%02x-%02x-%02x\n",
                eaddr[0], eaddr[1], eaddr[2], eaddr[3], eaddr[4], eaddr[5]);

    exit(1);
#endif

#ifdef SGI
	unsigned char ea[6];
        char sysid[MAXSYSIDSIZE];

        if (syssgi(SGI_SYSID, sysid) < 0)
        {
        printf("syssgi error\n");
            return(-1);
        }
        ea[2] = sysid[0];
        ea[0] = 0x08;
        ea[3] = sysid[1];
        ea[1] = 0x00;
        ea[4] = sysid[2];
        ea[5] = sysid[3];
            printf("Ethernet address: %02x-%02x-%02x-%02x-%02x-%02x\n",ea[0],ea[1],ea[2],ea[3],ea[4],ea[5]);
        exit(1);
#endif
#ifdef _AIX
        {
            int         nfd;
            struct devinfo      di_blk;
	    char        eid[7];

            nfd = open("/dev/ent0", O_RDONLY);

            if (ioctl(nfd, IOCINFO, &di_blk) < 0) {
                perror("Ioctl failed.");
                return(-1);
            }
printf("Hardware address: %02x-%02x-%02x-%02x-%02x-%02x\n",
				di_blk.un.ethernet.haddr[0] & 0xff,
				di_blk.un.ethernet.haddr[1] & 0xff,
				di_blk.un.ethernet.haddr[2] & 0xff,
				di_blk.un.ethernet.haddr[3] & 0xff,
				di_blk.un.ethernet.haddr[4] & 0xff,
				di_blk.un.ethernet.haddr[5] & 0xff);
printf("Network address : %02x-%02x-%02x-%02x-%02x-%02x\n",
				di_blk.un.ethernet.net_addr[0] & 0xff,
				di_blk.un.ethernet.net_addr[1] & 0xff,
				di_blk.un.ethernet.net_addr[2] & 0xff,
				di_blk.un.ethernet.net_addr[3] & 0xff,
				di_blk.un.ethernet.net_addr[4] & 0xff,
				di_blk.un.ethernet.net_addr[5] & 0xff);
        }
#endif
}
