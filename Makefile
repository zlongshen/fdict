.SUFFIXES: .f90 .o .a
include ./arch.make

.PHONY: default
default: lib

# The different libraries
OBJS  = var.o iso_var_str.o dictionary.o

LIB  = libvardict.a

.PHONY: lib
lib: $(LIB)

$(LIB): $(OBJS)
	$(AR) $(ARFLAGS) $(LIB) $(OBJS)
	$(RANLIB) $(LIB)

.PHONY: test
test: lib
	(cd test ; $(MAKE))

.PHONY: prep
prep:
	./var.sh
	fpp -P var.F90 | sed -e "s/NEWLINE/\n/g" > tmp.F90 
	fpp -P tmp.F90 var.f90
	./dictionary.sh
	fpp -P dictionary.F90 | sed -e "s/NEWLINE/\n/g" > tmp.F90 
	fpp -P tmp.F90 dictionary.f90

.PHONY: clean
clean:
	-rm -f $(OBJS) $(LIB) *.o *.mod tmp.F90 var.f90 dictionary.f90
	-rm -f dict_funcs.inc dict_interface.inc
	-rm -f var_nullify.inc var_delete.inc var_content.inc var_funcs.inc var_interface.inc

# Dependencies
dictionary.f90: | prep
dictionary.o: var.o | prep
var.f90: | prep
var.o: iso_var_str.o | prep