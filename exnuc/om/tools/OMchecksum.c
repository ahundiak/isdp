#include <exsysdep.h>
#include <stdio.h>
#include <errno.h>

#ifdef BIG_ENDIAN

/* If this utility is built on a big endian system (Sun), then in
 * order to checksum Clipper design files, we'll need to swap the
 * byte order of a few fields in the file header.
 */

int   swapint(dest, src)
char  *dest, *src;
{
   dest[0] = src[3];
   dest[1] = src[2];
   dest[2] = src[1];
   dest[3] = src[0];
   return(*((int*)dest));
}
#endif

main(argc, argv)
int      argc;
char     **argv;
{
   unsigned int   bcount,
                  size,
                  ii,
                  fileloc,
                  main_checksum,
                  hdr_checksum,
                  checksum;
   FILE           *fp;
   char           buffer[8192];
   struct OS_filehdr
   {
      short          magic;
      unsigned short w_major_version;
      unsigned short w_minor_version;
      unsigned short w_num_clusters;
      unsigned int   i_size;
      unsigned int   checksum;            /* Offset 12 */
      char           pad[418];
      char           A_unused[74];        /* Offset 434 */
      unsigned int   hdr_checksum;        /* Offset 508 */
   } hdr;

#ifdef NT
   if (!(fp = (FILE *) fopen(argv[1], "rb")))
#else
   if (!(fp = (FILE *) fopen(argv[1], "r")))
#endif
   {
      perror("open failed");
      exit();
   }
   fseek(fp, 0, 2);
   bcount = ftell(fp) - 512;   /* Bytes to checksum */
   fseek(fp, 0, 0);
   if ((ii = fread(&hdr, 512, 1, fp)) != 1)
   {
      printf("OMchecksum: Could not read file header.\n");
      return(1);
   }
#ifdef BIG_ENDIAN
   if ((hdr.w_major_version != 0x0200) || (hdr.magic != 0x4f4d))
#else
   if ((hdr.w_major_version != 2) || (hdr.magic != 0x4d4f))
#endif
   {
      printf("OMchecksum: This is not a valid 2.0 file.\n");
      return(1);
   }
#ifdef BIG_ENDIAN
   if (!(swapint((char *) &hdr_checksum, (char *) &hdr.hdr_checksum)))
#else
   if (!(hdr_checksum = hdr.hdr_checksum))
#endif
   {
      printf("OMchecksum: This file does not contain a checksum value to check against.\n");
      return(1);
   }
   fseek(fp, 0, 0);
   if ((ii = fread(buffer, 512, 1, fp)) != 1)
   {
      printf("OMchecksum: Could not read file header.\n");
      return(1);
   }
   for (ii=checksum=0; ii<434; ii++)      /* Skip dros fields */
      checksum += (unsigned char) buffer[ii] + ii;
   if (checksum != hdr_checksum)
      printf("OMchecksum: Header checksum (%d) is not valid.  Should be %d.\n",
         hdr_checksum, checksum);
   else
      printf("OMchecksum: The header checksum (%d) is valid.\n", hdr_checksum);


#ifdef BIG_ENDIAN
   swapint((char *) &main_checksum,
      (char *) &((struct OS_filehdr *) buffer)->checksum);
#else
   main_checksum = ((struct OS_filehdr *) buffer)->checksum;
#endif
   checksum = 0;
   fileloc = 512;
   while(bcount)
   {
      if (bcount > 8192)
         size = 8192;
      else
         size = bcount;
      if (fread(buffer, 1, size, fp) != size)
      {
         printf("OMchecksum: Could not read file to verify checksum.\n");
         return(1);
      }
      bcount -= size;
      for (ii=0; ii<size; ii++, fileloc++)
         checksum += (unsigned char) buffer[ii] + fileloc;
   }
   if (checksum != main_checksum)
   {
      printf("OMchecksum: File checksum (%d) is not valid.  Should be %d.\n",
         main_checksum, checksum);
      return(1);
   }
   else
      printf("OMchecksum: The file checksum (%d) is valid.\n", main_checksum);
   return(0);
}
