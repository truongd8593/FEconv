#################################################################
# Makefile created using the tool 'Creamake'
# 
# Creamake is distributed under the GNU GPL license
# Author: Francisco Pena, fran(dot)pena(at)usc(dot)es
# Download page: http://sourceforge.net/projects/creamake/
#################################################################
 
#################################################################
# User-modifiable options
#################################################################
 
# SOURCE AND COMMONS FOLDERS (separated by spaces)
dir_fuentes = source source/basicmod source/basicmod/gfortran \
source/basicmod/args source/basicmod/alloc source/basicmod/vtk \
source/cuthill_mckee source/ansys source/patran source/unv source/mfm \
source/mum source/vtu source/mphtxt source/pmh
 
# OBJECT AND .MOD FOLDER
dir_objetos = object
 
# MAIN SOURCE FILE (include relative path from folder where Makefile is)
condir_principal = source/main.f90
 
# EXECUTABLE NAME 
ejecutable = feconv
 
# NEEDED TO convert ejecutable THE DEFAULT RULE: 
$(ejecutable): $(condir_principal) 
 
# MODULES
modulos = module_compiler_gfortran.f90 module_os_dependant.f90 \
module_report.f90 module_set.f90 module_convers.f90 module_files.f90 \
module_feed.f90 module_args.f90 module_alloc_char_r1.f90 \
module_alloc_int_r1.f90 module_alloc_int_r2.f90 module_alloc_log_r1.f90 \
module_alloc_real64_r1.f90 module_alloc_real64_r2.f90 module_alloc.f90 \
module_system.f90 IR_Precision.f90 Lib_VTK_IO.f90 LIB_VTK_IO_READ.f90 \
module_writevtu.f90 module_ansys.f90 module_ALLOC_int_alloc_r2.f90 \
module_ALLOC_log_r2.f90 module_ALLOC_real_r2.f90 module_desplazamientos.f90 \
module_fuerzas.f90 module_MATH.f90 module_cells.f90 module_dataset.f90 \
module_FE_DB.f90 module_groups.f90 module_patran.f90 module_mesh.f90 \
module_dataset_2467.f90 module_dataset_2412.f90 module_dataset_2411.f90 \
module_manage_unv.f90 module_unv.f90 module_mfm.f90 module_mum.f90 \
module_vtu.f90 module_cuthill_mckee.f90 module_transform.f90 \
module_fe_database_pmh.f90 module_pmh.f90 module_write_mphtxt.f90 \
module_read_mphtxt.f90 module_manage_mphtxt.f90 module_mphtxt.f90 \
module_feconv.f90
 
# MODULE DEPENDENCIES
# if pru1 depends on pru2... pru1.o: pru2.o
module_os_dependant.o: module_compiler_gfortran.o
module_report.o: module_compiler_gfortran.o module_os_dependant.o
module_set.o: module_os_dependant.o module_report.o
module_convers.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o
module_files.o: module_os_dependant.o module_report.o module_convers.o
module_feed.o: module_convers.o
module_args.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_convers.o
module_alloc_char_r1.o: module_os_dependant.o module_report.o
module_alloc_int_r1.o: module_os_dependant.o module_report.o
module_alloc_int_r2.o: module_os_dependant.o module_report.o \
module_alloc_int_r1.o
module_alloc_log_r1.o: module_os_dependant.o module_report.o \
module_alloc_int_r1.o
module_alloc_real64_r1.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_alloc_int_r1.o
module_alloc_real64_r2.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_alloc_real64_r1.o
module_alloc.o: module_alloc_int_r1.o module_alloc_int_r2.o \
module_alloc_real64_r1.o module_alloc_real64_r2.o module_alloc_char_r1.o \
module_alloc_log_r1.o
module_system.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_convers.o module_alloc_char_r1.o module_files.o
IR_Precision.o: module_files.o
Lib_VTK_IO.o: IR_Precision.o
LIB_VTK_IO_READ.o: Lib_VTK_IO.o
module_writevtu.o: Lib_VTK_IO.o
module_ansys.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_convers.o module_alloc_int_r1.o module_set.o
module_ALLOC_int_alloc_r2.o: module_alloc.o
module_ALLOC_log_r2.o: module_report.o
module_ALLOC_real_r2.o: module_report.o
module_desplazamientos.o: module_alloc.o module_ALLOC_int_alloc_r2.o \
module_ALLOC_real_r2.o module_ALLOC_log_r2.o module_convers.o
module_fuerzas.o: module_alloc.o module_ALLOC_int_alloc_r2.o \
module_ALLOC_real_r2.o module_convers.o
module_MATH.o: module_compiler_gfortran.o
module_dataset.o: module_report.o module_convers.o
module_FE_DB.o: module_os_dependant.o
module_groups.o: module_alloc.o
module_patran.o: module_compiler_gfortran.o module_desplazamientos.o \
module_fuerzas.o module_MATH.o module_groups.o
module_mesh.o: module_compiler_gfortran.o module_os_dependant.o module_alloc.o \
module_files.o
module_dataset_2467.o: module_dataset.o module_mesh.o module_cells.o \
module_groups.o
module_dataset_2412.o: module_alloc.o module_dataset.o module_mesh.o \
module_FE_DB.o module_cells.o
module_dataset_2411.o: module_compiler_gfortran.o module_alloc.o \
module_dataset.o module_mesh.o
module_manage_unv.o: module_alloc.o module_files.o module_mesh.o \
module_dataset_2411.o module_dataset_2412.o module_dataset_2467.o
module_unv.o: module_compiler_gfortran.o module_os_dependant.o module_report.o \
module_convers.o module_manage_unv.o module_mesh.o
module_mfm.o: module_compiler_gfortran.o module_os_dependant.o module_report.o \
module_convers.o module_feed.o
module_mum.o: module_compiler_gfortran.o module_os_dependant.o module_report.o \
module_convers.o module_feed.o
module_vtu.o: module_compiler_gfortran.o module_report.o module_convers.o \
module_alloc_int_r1.o module_set.o module_writevtu.o
module_cuthill_mckee.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_vtu.o
module_transform.o: module_os_dependant.o module_report.o \
module_alloc_int_r1.o module_alloc_int_r2.o module_vtu.o \
module_cuthill_mckee.o
module_pmh.o: module_compiler_gfortran.o module_os_dependant.o module_report.o \
module_convers.o module_alloc.o module_args.o module_fe_database_pmh.o
module_write_mphtxt.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_convers.o module_alloc.o module_mesh.o module_pmh.o
module_read_mphtxt.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_convers.o module_alloc.o module_mesh.o module_pmh.o
module_manage_mphtxt.o: module_alloc.o module_files.o module_mesh.o \
module_read_mphtxt.o module_write_mphtxt.o
module_mphtxt.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_convers.o module_manage_mphtxt.o module_mesh.o \
module_pmh.o module_fe_database_pmh.o
module_feconv.o: module_compiler_gfortran.o module_os_dependant.o \
module_report.o module_convers.o module_files.o module_args.o \
module_transform.o module_cuthill_mckee.o module_ansys.o module_unv.o \
module_patran.o module_mfm.o module_mum.o module_vtu.o module_mphtxt.o \
module_pmh.o
 
# INCLUDES
includes = 
 
# COMPILER
FC = gfortran
 
# COMPILER OPTIONS
FFLAGS = -J$(dir_objetos) -Wall -g -fcheck=all -fbacktrace -fall-intrinsics
 
# LINKER OPTIONS
LDFLAGS = 
 
#################################################################
# Non-modifiable part
#################################################################
 
# SOURCE FOLDERS
VPATH =   $(subst ,:,$(strip $(dir_fuentes)))
vpath %.o $(dir_objetos)
 
# SOURCES
fuentes_ = $(filter %.f %.F %.for %.FOR %.f90 %.F90 %.f95 %.F95 %.f03 %.F03,$(shell ls $(dir_fuentes)))
fuentes  = $(filter-out $(notdir $(condir_principal)) $(modulos),$(fuentes_))
 
# OBJECTS
modulos_obj = $(addsuffix .o,$(basename $(modulos)))
fuentes_obj = $(addsuffix .o,$(basename $(fuentes)))
 
# OBJECTS WITH PATH
condir_modulos_obj = $(addprefix $(dir_objetos)/,$(modulos_obj))
condir_fuentes_obj = $(addprefix $(dir_objetos)/,$(fuentes_obj))
 
# COMPILATION OPTIONS
FFLAGS += $(patsubst %,-I%,$(dir_fuentes))
FFLAGS += -I$(dir_objetos)
 
# MAIN RULE
all: $(ejecutable)
 
$(ejecutable): $(includes) $(modulos_obj) $(fuentes_obj)
	$(FC) -o $(ejecutable) $(FFLAGS) $(condir_principal) $(condir_modulos_obj) $(condir_fuentes_obj) $(LDFLAGS)
 
# SOURCES RULE
$(fuentes_obj): $(includes) $(modulos_obj)
 
# RULE PATTERNS
%.o:%.f
	$(FC) -c -o $@ $(FFLAGS) $<
	@mv $@ $(dir_objetos) 
%.o:%.F
	$(FC) -c -o $@ $(FFLAGS) $< 
	@mv $@ $(dir_objetos) 
%.o:%.for
	$(FC) -c -o $@ $(FFLAGS) $< 
	@mv $@ $(dir_objetos) 
%.o:%.FOR
	$(FC) -c -o $@ $(FFLAGS) $< 
	@mv $@ $(dir_objetos) 
%.o:%.f90
	$(FC) -c -o $@ $(FFLAGS) $< 
	@mv $@ $(dir_objetos) 
%.o:%.F90
	$(FC) -c -o $@ $(FFLAGS) $< 
	@mv $@ $(dir_objetos) 
 
.PHONY: clean
clean:
	rm $(dir_objetos)/*.o      
	rm $(dir_objetos)/*.mod    
	rm $(ejecutable)
