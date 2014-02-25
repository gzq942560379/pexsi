#/usr/bin/bash
PROFILE        =   0
PROF_MPI       =   0
USE_TAU        =   0
USE_AUTO_TAU   =   0

# Different compiling and linking options.
#MODE           = debug
MODE	         = release
PLATFORM       = mn_v0.5.5
SUFFIX         =$(MODE)_${PLATFORM}

ifdef USE_TAU
  ifeq ($(USE_TAU),1)
    SUFFIX=$(MODE)_tau_${PLATFORM}
  endif

  ifeq ($(PROFILE),1)
    SUFFIX=$(MODE)_tau_${PLATFORM}
  endif

  ifeq ($(PROF_MPI),1)
    SUFFIX=$(MODE)_tau_${PLATFORM}
  endif
endif

PEXSI_DIR     = $(HOME)/pexsi
DSUPERLU_DIR  = $(HOME)/Software/SuperLU_DIST_3.2
PARMETIS_DIR  = $(HOME)/Software/parmetis-4.0.2/build/Linux-x86_64
SCOTCH_DIR    = $(HOME)/Software/scotch_6.0.0

# inclues

PEXSI_INCLUDE    = -I${PEXSI_DIR}/include
DSUPERLU_INCLUDE = -I${DSUPERLU_DIR}/SRC
INCLUDES         = ${PEXSI_INCLUDE} ${DSUPERLU_INCLUDE}

ifeq ($(USE_TAU),1)
  INCLUDES += -I${TAUROOTDIR}/include
endif

# Libraries
FORTRAN_LIB      = -lifcore
BLACS_LIB        = -Wl,-rpath,/apps/INTEL/mkl/lib/intel64/ -L/apps/INTEL/mkl/lib/intel64/ -lmkl_blacs_openmpi_lp64
SCALAPACK_LIB    =-Wl,-rpath,/apps/INTEL/mkl/lib/intel64/ -L/apps/INTEL/mkl/lib/intel64/ -lmkl_scalapack_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential
METIS_LIB        = -L${PARMETIS_DIR}/libmetis -lmetis
PARMETIS_LIB     = -L${PARMETIS_DIR}/libparmetis -lparmetis
SCOTCH_LIB       = -L${SCOTCH_DIR}/lib -lptscotchparmetis -lptscotch -lptscotcherr -lscotch
DSUPERLU_LIB     = ${DSUPERLU_DIR}/lib/libsuperlu_dist_3.2.a
PEXSI_LIB        = ${PEXSI_DIR}/src/libpexsi_${SUFFIX}.a


ifdef USE_TAU
  ifeq ($(USE_TAU),1)
TAU_LIB          = -L/opt/cray/mpt/5.5.2/gni/mpich2-pgi/119/lib -L/usr/common/acts/TAU/tau-2.22/craycnl/lib -lTauMpi-papi-mpi-pdt-pgi -lpthread -lrt -lmpichcxx -lmpich -lrt -L/usr/common/acts/TAU/tau-2.22/craycnl/lib -ltau-papi-mpi-pdt-pgi -R/opt/cray/papi/4.3.0.1/perf_events/no-cuda/lib -L/opt/cray/papi/4.3.0.1/perf_events/no-cuda/lib -lpapi -L/usr/common/acts/TAU/tau-2.22/craycnl/binutils-2.20/lib -L/usr/common/acts/TAU/tau-2.22/craycnl/binutils-2.20/lib64 -lbfd -liberty -lz -Wl,--export-dynamic -lrt -L/opt/pgi/12.5.0/linux86-64/12.5/bin/../lib -lstd -lC -lstdc++ -L/usr/common/acts/TAU/tau-2.22/craycnl/lib/static-papi-mpi-pdt-pgi
  endif
endif

LIBS_PARMETIS    = ${PEXSI_LIB} ${DSUPERLU_LIB} ${PARMETIS_LIB} ${METIS_LIB} ${TAU_LIB} ${SCALAPACK_LIB} ${BLACS_LIB} ${FORTRAN_LIB}
LIBS_PTSCOTCH    = ${PEXSI_LIB} ${DSUPERLU_LIB} ${SCOTCH_LIB} ${METIS_LIB} ${TAU_LIB} ${SCALAPACK_LIB} ${BLACS_LIB} ${FORTRAN_LIB}
LIBS             = ${LIBS_PTSCOTCH}

CC           = mpicc
CXX          = mpicxx
FC           = mpif90
LOADER       = mpicxx

ifdef USE_TAU
  ifeq ($(USE_TAU),1)
#  ifeq ($(USE_AUTO_TAU),1)
CC           = tau_cc.sh
CXX          = tau_cxx.sh
FC           = tau_f90.sh
LOADER       = tau_cxx.sh
#  endif
  endif
endif


AR           = ar
ARFLAGS      = rvcu
# For System V based machine without ranlib, like Cray and SGI,
# use touch instead.
#RANLIB      = touch
RANLIB       = ranlib

CP           = cp
RM           = rm
RMFLAGS      = -f

ifeq ($(MODE), debug)
  COMMONDEFS   = -DDEBUG=0 -g -DAdd_ #-DUSE_REDUCE_L -DUSE_BCAST_UL -DPRINT_COMMUNICATOR_STAT #-DUSE_BCAST_UL #-DCOMPARE_LUPDATE #-DUSE_MPI_COLLECTIVES -DBLOCK_REDUCE
  CFLAGS       = -O2 -g -w ${INCLUDES} -DAdd_
  FFLAGS       = -O2 -g -w ${INCLUDES}
  CXXFLAGS     = -O2 -g -w ${INCLUDES} -DAdd_ #-DSANITY_CHECK -DSANITY_PRECISION=1e-5 #-DSELINV_TIMING -DSELINV_MEMORY -DNO_PARMETIS_FIX
        CCDEFS       = ${COMMONDEFS}
        CPPDEFS      = ${COMMONDEFS}
  LOADOPTS     = ${LIBS}
  LOADOPTS_PARMETIS     = ${LIBS_PARMETIS}
  LOADOPTS_PTSCOTCH     = ${LIBS_PTSCOTCH}
  FLOADOPTS    = ${LIBS} -lstdc++
endif

ifeq ($(MODE), release)
  COMMONDEFS   = -DDEBUG=0 -DRELEASE -DAdd_ #-DUSE_REDUCE_L -DUSE_BCAST_UL #-DPRINT_COMMUNICATOR_STAT #-DUSE_BCAST_UL #-DCOMPARE_LUPDATE #-DUSE_MPI_COLLECTIVES
  CFLAGS       = -O3 -g -w ${INCLUDES}
  FFLAGS       = -O3 -g -w ${INCLUDES}
  CXXFLAGS     = -O3 -g -w ${INCLUDES}  #-DNO_PARMETIS_FIX  #-DSANITY_CHECK -DSANITY_PRECISION=1e-5
        CCDEFS       = ${COMMONDEFS}
        CPPDEFS      = ${COMMONDEFS}
  LOADOPTS     = ${LIBS}
  LOADOPTS_PARMETIS     = ${LIBS_PARMETIS}
  LOADOPTS_PTSCOTCH     = ${LIBS_PTSCOTCH}
  FLOADOPTS    = ${LIBS} -lstdc++
endif


# Generate auto-dependencies 
%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -M $(CCDEFS) $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@;\
	rm -f $@.$$$$

%.d: %.cpp
	@set -e; rm -f $@; \
	$(CXX) -M $(CPPDEFS) $(CXXFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@;\
	rm -f $@.$$$$