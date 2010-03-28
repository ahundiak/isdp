/*
/*---------------------------------------------------------------------------
/*  ACci_header.S
/*  ludovic Le Corvec
/*  15_sept_90
/*
/*  Abstract
/*	New class for occurence of ci symbol macro.
/*
/*
/*  History
/*
/*---------------------------------------------------------------------------*/
class specification ACci_header (0:0) of nci_macro, ACheader;

from nci_macro	inherit init;

override	ACmplace_from_def,
		ci_macro.init;

override	GRdrop;

end specification ACci_header;


