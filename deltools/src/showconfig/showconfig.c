#include	<stdlib.h>
#include <sys/types.h>
#include <sys/sysmacros.h>
#ifdef SVR3
#include <ctype.h>
#endif
#include <fcntl.h>
#include <stdio.h>
    
#define MAX_VALID_SLOTS		16
#define MAX_FEATURES		64
    
/*
 *  Define network board hit list. Used with the -n option.
 */
    
char netboards[64][16];

struct {
    u_char	board[8];
    u_char	eco[8];
    u_char	feature[8];
    u_char	reserved[2];
    u_short	family;
    u_char	footprint[3];
    u_char	chksum;
} id;

struct {
    char	name[64];
    char	eco[64][64];
} board;

struct {
    int	type;
    int	value;
    u_char	mask[8];
    char	name[64];
} feature[MAX_FEATURES];


int	debug, ecoflg, featflg, netflg;
FILE	*datfd;
char	*progname;
extern	char *optarg;
extern	int optind, opterr;

main(argc, argv)
char *argv[];
int argc;
{
    register i;
    int datflg, errflg;
    char datfile[256];
    char datstr[256];
    char *dsp;
    
    progname = argv[0];
    opterr = 0;
    datflg = errflg = 0;
    while ((i = getopt(argc, argv, "xefnd:")) != EOF) {
	switch (i)  {
	case 'x':
	    debug++;
	    break;
	    
	case 'e':
	    ecoflg++;
	    break;
	    
	case 'f':
	    featflg++;
	    break;
	    
	case 'n':
	    netflg++;
	    break;
	    
	case 'd':
	    datflg++;
	    strcpy(datfile, optarg);
	    break;			
	    
	case '?':
	    errflg++;
	    break;
	}
    }
    
    /*
     * Check for any errors and open device
     */
    if (errflg || (datflg > 1) || (optind != argc))  {
	fprintf(stderr,	"usage: %s [-e] [-n] [-f] [-d datfile]\n", argv[0]);
	fprintf(stderr, "\t\t-e  print ECO information\n");
	fprintf(stderr, "\t\t-n  print NETWORK I/F information\n");
	fprintf(stderr, "\t\t-f  print FEATURE information\n");
	fprintf(stderr, "\t\t-d  use specified configuration file\n");
	exit(1);
    }
    
    /* Get information on network boards */
    if ((datfd = fopen("/etc/netboards", "r")) == 0) {
	if (netflg) {
	    fprintf(stderr, "%s: can't open network board adapter table\n", argv[0]);
	    perror("/etc/netboards");
	    exit(1);
	}
    }
    else {
	i = 0;
	while (fgets(datstr, 256, datfd)) {
	    /* Skip comment lines and blank lines */
	    if (datstr[0] == '#' || datstr[0] == '\n' || datstr[0] == '\0')
		continue;
	    else {
		/* Copy only up to first whitespace (skip trailing comments) */

		dsp = datstr;
		while (*dsp != ' ' && *dsp != '\t' && *dsp != '\n' &&
				*dsp != '#' && *dsp != '\0')
		    dsp++;
		*dsp = '\0'; 

		strcpy(netboards[i], datstr);
		i++;
	    }
	}
	netboards[i][0] = '\0';
	fclose(datfd);
    }


    if (datflg == 0)
	strcpy(datfile, "/etc/showconfig.dat");
    
    if ((datfd = fopen(datfile, "r")) == 0) {
	fprintf(stderr, "%s: Can't open data file %s\n",
		argv[0], datfile);
	perror(datfile);
	exit(1);
    }
    if (!netflg) {
	print_slot(254);
	print_slot(255);
    }
    for (i = 0; i <	MAX_VALID_SLOTS; i++)
	print_slot(i);
}


print_slot(slot)
register slot;
{
    char dev[20];
    register fd, i, j, eco, value;
    register u_char *up, cs;
    int print_family=0;
    
    if (slot == 254)
	strcpy(dev, "/dev/unix_id");
    else if (slot == 255)
	strcpy(dev, "/dev/iop_id");
    else
	sprintf(dev, "/dev/sr%02d", slot);
    
    if ((fd = open(dev, O_RDONLY)) < 0)
	return;
    if (read(fd, &id, sizeof(id)) != sizeof(id)) {
	close(fd);
	return;
    }
    close(fd);
    if ((id.footprint[0] != 0x55) && (id.footprint[1] != 0xaa) &&
	(id.footprint[2] != 0x55))
	return;
    
    up = (u_char *) &id;
    cs = 0;
    for (i = 0; i < (sizeof(id) - 1); i++)
	cs -= *up++;
    
    if ( netflg && ! network_board(id.board) )
	return;
    
    find_board(id.board);
    
    if (netflg && find_family(id.family)) {
	for (j = 0; j < MAX_FEATURES; j++) {
	    if (feature[j].type == 0)
		break;
	    value = getvalue(id.feature, feature[j].mask);

	    /*
	     *  Look for specific values associated with networking boards:
	     *    0x00 = IBM Serial Comm I/F
	     *    0x07 = Token Ring Network Interface
	     *    0x08 = X.25 Network Interface
	     *    0x0d = Dual T1 X.25 Controller
	     *
	     */
	    if ((value == 0x07 || value == 0x08 || value == 0x0d ||
		 ( value == 0x00 && feature[j].mask[0]==0xff ) ) &&
		( value == feature[j].value ) && feature[j].type==1 ) {
		print_family++;
		fprintf(stdout, "%3d:",slot);
		if (slot < 254 && cs != id.chksum)
		    fprintf(stdout, "      ** ID prom checksum error\n");
		fprintf(stdout, "\t%s\n",feature[j].name);
	    }
	}
    }
    if (netflg) {
	if (!print_family) {
	    fprintf(stdout, "%3d:",slot);
	    if (board.name[0])
		fprintf(stdout, "\t%s\n", board.name);
	    else
		fprintf(stdout, "Unknown Board\n");
	    
	    if (slot < 254 && cs != id.chksum)
		fprintf(stdout, "      ** ID prom checksum error\n");
	}
    }
    else {
	if (id.feature[3] & 0x80)
	    fprintf(stdout, "    Slot %3d: MPCB", slot);
	else
	    fprintf(stdout, "    Slot %3d: MSMT", slot);

	for (i = 0; i < 7; i++) {
	    if (id.board[i])
		fprintf(stdout, "%c", id.board[i]);
	}
	fprintf(stdout, ", rev %c, ", id.board[7]);
	
	for (eco = 64; eco > 0; eco--) {
	    if ( ! (id.eco[(eco - 1) / 8] & (1 << ((eco - 1) % 8))) )
		break;
	}
	
	fprintf(stdout, "eco %2d -- ", eco);
	if (board.name[0])
	    fprintf(stdout, "%s\n", board.name);
	else
	    fprintf(stdout, "Unknown Board\n");
	if (slot < 254 && cs != id.chksum)
	    fprintf(stdout, "      ** ID prom checksum error\n");
	
	if (ecoflg) {
	    for (i = 0; i < eco; i++) {
		if (*board.eco[i])
		    fprintf(stdout, "      -- ECO %2d: %s\n",
			    i + 1, board.eco[i]);
	    }
	}
	
	if (featflg && find_family(id.family)) {
	    for (i = 0; i < MAX_FEATURES; i++) {
		if (feature[i].type == 0)
		    break;
		value = getvalue(id.feature, feature[i].mask);
		
		switch (feature[i].type) {
		case 1:
		    if (value == feature[i].value)
			fprintf(stdout, "      -- %s\n",
				feature[i].name);
		    break;
		    
		case 2:
		    fprintf(stdout, "      -- ");
		    fprintf(stdout, feature[i].name, value);
		    fprintf(stdout, "\n");
		}
	    }
	}
    }
}

find_board(b)
char b[];
{
    char buf[256], *bp, *bn;
    register i, len, state;
    int eco;
    char board_number[9];
    
    /*
     * Make the board name into a string
     */
    for (i = 0; i < 7; i++)
	if (b[i])
	    break;
    for (len = 0; i < 7; i++, len++)
	board_number[len] = toupper(b[i]);
    board_number[len] = '\0';
    board.name[0] = '\0';
    
    /*
     * Seek back to beginning of file and start the search
     */
    fseek(datfd, 0, 0);
    state = 0;
    while (bp = fgets(buf, sizeof(buf), datfd)) {
	switch (state) {
	case 0:
	    if (strncmp(bp, "BOARD TABLE", 11) == 0)
		state = 1;
	    break;
	    
	case 1:
	    bp += strspn(bp, " \t");
	    if (len != strspn(bp, "0123456789ABCDEFabcdef/"))
		break;
            for (bn = bp; bn <= (bp + len); bn++)
		*bn = toupper(*bn);
	    if (strncmp(bp, board_number, len))
		break;
	    if (checkchar(bp[len]))
		break;
	    
	    /*
	     * Found line, filling in structure
	     */
	    for (i = 0; i < 64; i++)
		board.eco[i][0] = '\0';
	    bp += len;
	    if ((len = getstring(bp, board.name,
				 sizeof(board.name))) == 0)
		error(buf);
	    bp += len;
	    state = 2;
	    
	    /* fall into ECO processing */			
	    
	case 2:
	    if ((len = getnum(bp, &eco)) == 0)
		return (1);
	    bp += len;
	    if (eco < 1 || eco > 64) {
		error(buf);
		break;
	    }
	    eco--;
	    if ((len = getstring(bp, board.eco[eco],
				 sizeof(board.eco[0]))) == 0) {
		error(buf);
		break;
	    }
	    break;
	}
    }
    if (debug && state == 0)
	fprintf(stderr,
		"%s: Bad configuration file - no BOARD TABLE\n",
		progname);
    return (0);
}


find_family(family)
register family;
{
    char buf[256], *bp;
    register i, len, state, index=0;
    int type, f;
    
    /*
     * Seek back to beginning of file and start the search
     */
    fseek(datfd, 0, 0);
    state = 0;
    while (bp = fgets(buf, sizeof(buf), datfd)) {
	switch (state) {
	case 0:
	    if (strncmp(bp, "FAMILY TABLE", 11) == 0)
		state = 1;
	    break;
	    
	case 1:
	    bp += strspn(bp, " \t");
	    if (*bp == '\n' || *bp == '#')
		break;
	    if ((len = getnum(bp, &f)) == 0)
		break;
	    if (family != f)
		break;
	    bp += len;
	    
	    /*
	     * Found line, filling in structure
	     */
	    for (i = 0; i < 64; i++)
		feature[i].type = 0;
	    index = 0;
	    state = 2;
	    
	    /* fall into feature processing */			
	    
	case 2:
	    bp += strspn(bp, " \t");
	    if (*bp == '\n')
		return (index);
	    if (bp[0] != '0' || bp[1] != 'x') {
		error(buf);
		break;
	    }
	    bp += 2;
	    len = strspn(bp, "0123456789abcdef");
	    if (len != 16) {
		error(buf);
		break;
	    }
	    if (checkchar(bp[len])) {
		error(buf);
		break;
	    }
	    f = 0;
	    for (i = 7; i >= 0; i--) {
		feature[index].mask[i] = tonum(*bp++) * 16;
		feature[index].mask[i] += tonum(*bp++);
		if (feature[index].mask[i])
		    f++;
	    }
	    if (f == 0) {
		error(buf);
		break;
	    }
	    if ((len = getnum(bp, &type)) == 0) {
		error(buf);
		break;
	    }
	    bp += len;
	    if ((len = getnum(bp, &feature[index].value)) == 0) {
		error(buf);
		break;
	    }
	    bp += len;
	    if ((len = getstring(bp, feature[index].name,
				 sizeof(feature[index].name))) == 0) {
		error(buf);
		break;
	    }
	    feature[index++].type = type;
	    if (index == MAX_FEATURES) {
		fprintf(stderr,
			"%s: Feature table overflow\n",
			progname);
		return(index);
	    }
	    break;
	}
    }
    if (debug && state == 0)
	fprintf(stderr,
		"%s: Bad configuration file - no FAMILY TABLE\n",
		progname);
    return (index);
}


getvalue(data, mask)
char data[8];
char mask[8];
{
    register base, index;
    register value;
    
    base = 0;
    value = 0;
    while ((mask[base / 8] & (1 << (base % 8))) == 0)
	base++;
    index = 0;
    while (base < 64) {
	if (mask[base / 8] & (1 << (base % 8)))
	    if (data[base / 8] & (1 << (base % 8)))
		value |= (1 << index);
	base++;
	index++;
    }
    return (value);
}


getstring(p, s, len)
char *p;
register char *s;
register len;
{
    register char *bp;
    register i;
    
    bp = p;
    bp += strspn(bp, " \t");
    if (*bp == '\0')
	return (0);
    
    i = 0;
    if (*bp == '"') {
	bp++;
	while (*bp && *bp != '"' && *bp != '\n') {
	    if (i < (len - 1))
		*s++ = *bp;
	    bp++;
	}
	if (*bp == '"')
	    bp++;
    } else {
	while (*bp && *bp != ' ' && *bp != '\t' && *bp != '\n') {
	    if (i < (len - 1))
		*s++ = *bp;
	    bp++;
	}
    }
    *s = '\0';
    return (bp - p);
}


getnum(p, value)
char *p;
int *value;
{
    register len, v;
    register char *bp;
    
    bp = p;
    bp += strspn(bp, " \t");
    if (*bp == '\0')
	return (0);
    if (bp[0] == '0' && bp[1] == 'x') {
	bp += 2;
	len = strspn(bp, "0123456789abcdef");
	if (len == 0)
	    return (0);
	if (checkchar(bp[len]))
	    return (0);
	v = 0;
	while (len--)
	    v = (v * 16) + tonum(*bp++);
	*value = v;
	return (bp - p);
    } else {
	len = strspn(bp, "0123456789");
	if (len == 0)
	    return (0);
	if (checkchar(bp[len]))
	    return (0);
	v = 0;
	while (len--)
	    v = (v * 10) + tonum(*bp++);
	*value = v;
	return (bp - p);
    }
}

tonum(c)
{
    if (c > '9')
	return (c - 'a' + 10);
    else
	return (c - '0');
}

checkchar(c)
register c;
{
    if (c != ' ' && c != '\t' && c != '\0' && c != '\n')
	return (1);
    return (0);
}

error(s)
char *s;
{
    if (debug)
	fprintf(stderr, "%s: Bad configuration file line\n%s",
		progname, s);
}

network_board(devboardname)
char devboardname[];
{
    register i, len;
    char board_number[9];
    
    
    for (i = 0; i < 7; i++)
	if (devboardname[i])
	    break;
    for (len = 0; i < 7; i++, len++)
	board_number[len] = devboardname[i];
    board_number[len] = '\0';
    
    /*for ( i = 0; i < (sizeof(netboards) / sizeof (char *)); i++)*/
    for ( i = 0; netboards[i][0] != '\0'; i++)
	if (!strcmp(board_number,netboards[i]))
	    return(1);
    return(0);
}




