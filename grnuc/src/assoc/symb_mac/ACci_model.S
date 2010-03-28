/*
/*---------------------------------------------------------------------------
/*  ACci_model.S
/*  ludovic Le Corvec
/*  29_oct_91
/*
/*  Abstract
/*	New class for model of ACci_header macro .
/*
/*
/*  History
/*
/*---------------------------------------------------------------------------*/
class specification ACci_model (0:0) of ACmodel, nci_macro;

from ACmodel inherit	GRlocate_owner;

override	NDsleep,
		NDdelete;

end specification ACci_model;
