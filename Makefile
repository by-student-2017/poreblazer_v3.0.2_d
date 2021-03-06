# Use this Makefile with gmake

# Executable name 
CMD = poreblazer.exe

# -------- description of DFLAGS --------------- 
# DNAGCOMPILER - some nag ocmpiler specific parts especially for using
# system calls
# DSITE_HACK - some hacks in post code, which can be integrated to
#regular code with some work
# DBENT_GCMC - some special adjustments in rigidmoves for dealing with
# molecules whose COM might fall outside the tabulated area. This code
# is in test stage (2-12-03). Too dangerous to mix with regular code.
# DIDEAL_GAS - to prevent molecules  flying away from origin during
# ideal gas simulations


# -------- Define environmental variable FORTRAN_COMPILER -----------
# Make sure it is defined
#          ifeq ($(strip$(FORTRAN_COMPILER)),)
# Otherwise you can define it here also by uncommenting next line
FORTRAN_COMPILER= gfortran
ifeq ($(FORTRAN_COMPILER),)
 FC = defaultCompiler
else
 FC= $(FORTRAN_COMPILER)
endif

# commented out for now !!
#define the general flags, used for all extension types
GEN_FLAGS =  -cpp 
#GEN_FLAGS =  -non_shared
#define the F77 compiler flags
F77FLAGS = 


### ----------- define flags for default compiler --------------------- 
###
###
ifeq ($(FC),defaultCompiler)
 F90FLAGS = 
 DEBUG_FLAGS = 
 DFLAGS = 
 OFLAGS =  
 LINKERFLAGS = 
endif


### ------------ define flags for ifc, intel-linux-compiler by INTEL ---------
###
###
ifeq ($(FC),ifort)
F90FLAGS = 
DEBUG_FLAGS = 
OFLAGS = -O2
#LINKERFLAGS = -unsharedf95 # for not using runtime libraries
endif

### ------------ define flags for ifc, intel-linux-compiler by INTEL ---------
###
###
ifeq ($(FC),gfortran)
F90FLAGS = 
DEBUG_FLAGS = 
OFLAGS = -O2
LINKERFLAGS = 
endif

### ------------ define flags for nagf95, intel-linux compiler by NAG ---------
###
###
ifeq ($(FC),nagf95)
F90FLAGS = -w=unused #-useful for NAG compiler
#DEBUG_FLAGS = -g -C -gline #debug flags for NAG compiler
DFLAGS = -DNAGCOMPILER #-Define the cpp flags to be used
OFLAGS =  -O4 # optimization
#OFLAGS = -Wc,-mcpu=pentium -O4 # OR ,-mcpu=pentium4, athlon etc..
#LINKERFLAGS = -L/usr/local/lib/NAGWare/ -lf96 # maybe needed for NAG compiler
#LINKERFLAGS = -unsharedf95 # for not using runtime libraries
endif


### ----------- define flags for Old DEC/Compaq, alpha-linux ---------------
###
###
ifeq ($(FC),f90)
F90FLAGS = -u -std95  #-useful for DEC/Compaq compilers
DEBUG_FLAGS = -g -C -ladebug -warn unused -check underflow -check overflow -align records -check bounds #-debugging flags
#OFLAGS =  -fast # optimization
endif



### ---------- define flags for intel-linux lahey compiler -------------- 
### This compiler does not work for music code
###
ifeq ($(FC),lf95)
F90FLAGS = --f95 #-useful for the Lahey compiler
DEBUG_FLAGS = -g --ap --chkglobal --lst --psa --sav --trace --info --xref #-useful for the Lahey compiler
endif


### ---------- define flags for Absoft compiler ------------------------ 
###
###
ifeq ($(FC),AbSf95)
#DEBUG_FLAGS = -g -Rb -Rc -Rp -Rs #for Absoft compiler  (-Rb doesn't work)
DEBUG_FLAGS = -s -g -B111 -B80 -Rc -Rp -Rs #for Absoft compiler
LINKERFLAGS = -lU77  #needed for Absoft compiler, accesses UNIX commands
endif



# Targets and rules
#
#
#
#
# Implicit rules for handling src files
#  ( uses static pattern rules, see info for make )
%.o : %.f90 
	$(FC) $(GEN_FLAGS) $(DEBUG_FLAGS) $(F90FLAGS) $(OFLAGS) $(DFLAGS) -c $<
%.o : %.f
	$(FC) $(GEN_FLAGS) $(DEBUG_FLAGS) $(F77FLAGS) $(OFLAGS) -c $<

OBJECTS = defaults.o percolation.o utils.o matrixops.o random.o vector.o \
fundcell.o matrix.o poreblazer.o 

$(CMD) : $(OBJECTS)
	$(FC) $(DEBUG_FLAGS) $(OFLAGS) $(LINKERFLAGS) $(OBJECTS)  -o $(CMD)

dec : $(OBJECTS)
	$(FC) $(DEBUG_FLAGS) $(OFLAGS) $(OBJECTS) -o $(CMD)

clean:
	/bin/rm -f *.o *.i *.mod a.out make.log

cleano:
	rm -f *.o *.i 


depend : 
	makemake *.f90 *.F 

defaults.o                :
percolation.o             :
utils.o                   : defaults.o
matrixops.o               : defaults.o
random.o                  : defaults.o
vector.o                  : defaults.o utils.o
fundcell.o                : defaults.o utils.o vector.o matrix.o
matrix.o                  : defaults.o utils.o vector.o matrixops.o random.o
poreblazer.o              : fundcell.o defaults.o random.o vector.o percolation.o
