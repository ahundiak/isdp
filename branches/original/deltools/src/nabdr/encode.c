#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <fcntl.h>

#define SLOT 623691234

int	copy_coded_file(infile, outfile, salt)
char *infile;
char *outfile;
unsigned int	salt;
{
        int     inf, outf;
        int     rcount;
	char	*buf, *bp;
        struct  utimbuf {
                time_t  actime;
                time_t  modtime;
        } times;
	struct stat statbuf;

        if ((inf = open(infile, O_RDONLY)) < 0) {
                return(1);
        }
 
        if (fstat(inf, &statbuf)) {
                close(inf);
                return(1);
        }
 
        if ((outf = creat(outfile, statbuf.st_mode)) < 0) {
                close(inf);
                return(1);
	}
  
	buf = (char *)malloc(62*1024);
	while ((rcount = read(inf, buf, 62*1024)) > 0) {
	    if (salt) {
		for (bp = buf; bp < (buf+rcount); bp += 4)
		    *((unsigned int *)bp) ^= salt;
            }
	    if (write(outf, buf, rcount) != rcount) {
		free(buf);
		close(inf);
		close(outf);
		return(-1);
	    }
	}
	free(buf);
	close(inf);
	close(outf);
        times.actime = statbuf.st_atime;
        times.modtime = statbuf.st_mtime;
        utime(outfile, &times);
        chown(outfile, statbuf.st_uid, statbuf.st_gid);
        if (rcount < 0)
                return(-1);
	return(0);
}


main(argc, argv)
int argc;
char *argv[];
{
    if (argc != 1) {
	/* adding HP here -- MVR 7 May 1994 */
	fprintf(stderr, "Usage: encode.{clip|sun|sco|sgi|ssl|hp}\n");
	exit(1);
    }

    if (strcmp(argv[0], "encode.clip") == 0) 
	copy_coded_file("cmsdr.clip", ".CMSDR.CLIP", SLOT);
    else if (strcmp(argv[0], "encode.sun") == 0)
	copy_coded_file("cmsdr.sun", ".CMSDR.SUN", SLOT);
    else if (strcmp(argv[0], "encode.sgi") == 0)
	copy_coded_file("cmsdr.sgi", ".CMSDR.SGI", SLOT);
    else if (strcmp(argv[0], "encode.sco") == 0)
	copy_coded_file("cmsdr.sco", ".CMSDR.SCO", SLOT);
    else if (strcmp(argv[0], "encode.ssl") == 0)
	copy_coded_file("cmsdr.ssl", ".CMSDR.SSL", SLOT);
    /* Adding HP here -- MVR 7 May 1994  */
    else if (strcmp(argv[0], "encode.hp") == 0)
	copy_coded_file("cmsdr.hp", ".CMSDR.HP", SLOT);
    else {
	fprintf(stderr, "Usage: encode.{clip|sun|sco|sgi|ssl}\n");
	exit(1);
    }

    exit(0);
}

