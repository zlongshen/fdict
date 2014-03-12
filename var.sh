#!/bin/bash

source settings.sh

# The different settings used in this
vars=(a s d c z b i l)

# Print out to the mod file
{
for sub in assign associate associatd ; do
args="get set"
[ "$sub" == "associatd" ] && args="l r"
_psnl "interface $sub"
for v in ${vars[@]} ; do
    for d in `seq 0 ${N[$v]}` ; do
	modproc $sub $v $d $args
    done
done
modproc $sub v 0
_psnl "end interface $sub"
_psnl "public :: $sub"
done
if [ 1 -eq 0 ]; then
for sub in eq ne lt gt ge le ; do
_psnl "interface operator(.$sub.)"
for v in ${vars[@]} ; do
    for d in `seq 0 ${N[$v]}` ; do
	modproc $sub $v $d l r
    done
done
modproc $sub v 0
_psnl "end interface operator(.$sub.)"
_psnl "public :: operator(.$sub.)"
done
fi
} > var_interface.inc

{
for v in ${vars[@]} ; do
    for d in `seq 0 ${N[$v]}` ; do
	_psnl "nullify(this%$v$d)"
    done
done
} > var_nullify.inc

{
for v in ${vars[@]} ; do
    for d in `seq 0 ${N[$v]}` ; do
	_psnl "if (associated(this%$v$d)) deallocate(this%$v$d)"
    done
done
} > var_delete.inc

{
for v in v ${vars[@]} ; do
    _ps "${name[$v]}, pointer :: "
    for d in `seq 0 ${N[$v]}` ; do
	_ps "$v$d$(dim_to_size $d)=>null()"
	if [ $d -lt ${N[$v]} ]; then
	    _ps ", "
	else
	    _psnl ""
	fi
    done
done
} > var_content.inc

{
_psnl "#include 'settings.inc'"
_psnl "#undef VAR_PREC"
for v in ${vars[@]} ; do
    _psnl "#define VAR_TYPE ${name[$v]}"
    for d in `seq 0 ${N[$v]}` ; do
	if [ $d -eq 0 ]; then
	    _psnl "#define DIMS"
	else
	    _psnl "#define DIMS , dimension$(dim_to_size $d)"
	fi
	_psnl "#define VAR $v$d"
	_psnl "#define DIM $d"
	_psnl "#include 'var_funcs_inc.inc'"
	_psnl "#undef VAR"
	_psnl "#undef DIM"
	_psnl "#undef DIMS"
    done
    _psnl "#undef VAR_TYPE"
done
} > var_funcs.inc