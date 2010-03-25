#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <utime.h>

/*
 * This routine is used to copy a file from one place to another. A
 * return value of 0 indicates a successful copy.
 */
int	copy_file(infile, outfile, care, flg)
char	*infile, *outfile;
int	care, flg;
{
	int	inf, outf;
	int	rcount;
	struct	utimbuf	times;
	struct tran_s {
		int	*buf;
		int	bufcnt;
		int	iproc;
	}	tran;

	if ((inf = open(infile, O_RDONLY)) < 0) {
		if (care)
			PRINT "Cannot open %s for reading.\n", infile);
		return(1);
	}

	if (fstat(inf, &statbuf)) {
		if (care)
			PRINT "Cannot stat %s.\n", infile);
		return(1);
	}

	if ((outf = creat(outfile, statbuf.st_mode)) < 0) {
		if (care)
			PRINT "Cannot open %s for writing.\n", outfile);
		return(1);
	}

	tran.iproc = decode_slot;
	tran.buf = (int *)malloc(62 * 1024);

	while ((rcount = read(inf, tran.buf, 62 * 1024)) > 0) {
		if (srcmedia == CDROM && flg) {
			tran.bufcnt = rcount;
			syscall(125, SINGRNABDRTRAN, &tran);
		}
		if (write(outf, tran.buf, rcount) != rcount)
			return(-1);
	}

	free(tran.buf);
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

