module module_alloc_log_r1_bmod
!! License: GNU GPLv2 license.
!! Author: Francisco Pena, fran.pena(at)usc.es
!! Date: 31/12/2017
!!
!! Module for memory allocation of logical rank 1 allocatable arrays.  
!!
!! @note Procedures `set` and `insert` allocate or extend the array when it is necessary.  
! 
! PUBLIC PROCEDURES:
!   dealloc: dealloc memory
!   alloc: alloc memory
!   extend: extend the extension of an array
!   set: set a scalar or a vector in the array
!   insert: insert a scalar in the array
!   reduce: reduce the array
!   find_first: funtion to find the first occurrence of a value in an array
!   find: funtion to find all the occurrences of a value in an array
!     Private functions under 'find' are:
!     find_sca: find a scalar value in an array
!   sfind: subrutine for find
!-----------------------------------------------------------------------
use module_os_dependant_bmod, only: maxpath
use module_report_bmod, only: error, info
use module_alloc_common_bmod, only: DEFAULT_ALLOC, csize, search_multiple
use module_alloc_int_r1_bmod, only: alloc
implicit none

!Constants
private :: DEFAULT_ALLOC

!Private procedures
private :: dealloc_prv, alloc_prv, extend_prv, reduce_prv
private :: set_scalar_prv, set_vector_prv
private :: insert_prv
private :: find_first_prv, find_sca_prv, sfind_sca_prv
private :: search_multiple

!Interfaces
interface dealloc
  !! Deallocates an array.  
  !!
  !! @note The advantages of using this procedure intead the intrinsic procedure `deallocate` are:  
  !!  - Testing the previous deallocation of `v` is automatically done.  
  !!  - Deallocation is called with error catching arguments and every error is shown.  
  module procedure dealloc_prv
end interface

interface alloc
  !! Allocates an array.  
  !!
  !! @note If `v` is allocated and its extension is `d`, allocation is not carried out; 
  !! otherwise, `v` is deallocated before allocation. 
  !! If there is not any error, `v` is set to `.false.`.  
  module procedure alloc_prv
end interface

interface extend
  !! Extends the array to contain position `d`.  
  !!
  !! @note If `v` is not allocated and  
  !! -`fit` is present and `.false.`, `v` will be allocated with extension `2^n DEFAULT_ALLOC`, where `n` is 
  !! the smallest exponent such that `2^n DEFAULT_ALLOC > d` (`DEFAULT_ALLOC` is a private parameter with value 1000).  
  !! - Otherwise, `v` is allocated with extension `d`.  
  !!
  !! @note If `v` is already allocated and  
  !! - `d` is larger than `size(v)`, `fit` is present and `.false.`, `v` will be reallocated with extension `2^n size(v)`, 
  !! where `n` is the smallest exponent such that `2^n size(v) > d`.  
  !! - Otherwise, `v` is reallocated with extension `d`.  
  !!
  !! @note Argument `fit` is `.true.` by default.  
  !!
  !! @note New positions created in the extension are set to `.false.`.  
  module procedure extend_prv
end interface

interface reduce
  !! Reduces the extension of an array.  
  !!
  !! @note If `v` is not allocated or `d` is larger that its size, the procedure sends an info and returns. 
  !! If `v` is allocated and its extension is `d`, the procedure returns. 
  !! Otherwise, the procedure reduces the extension of `v` to `d`.  
  module procedure reduce_prv
end interface

interface set
  !! Sets a scalar o vector value in an array.  
  !!
  !! @note In the scalar case the function `extends` is initially called: `call extend(v,d,fit)`. Then `val` 
  !! is assigned to `v(d)`. 
  !! In the vector case the function `extends` is initially called: `call extend(v, maxval(d), fit)`. Then 
  !! `val` is assigned to `v(d)`.  
  !!
  !! @warning When `val` and `d` are arrays, they must have the same shape. This check is not done due to performance reasons.  
  module procedure set_scalar_prv
  module procedure set_vector_prv
end interface

interface insert
  !! Inserts a scalar value in an array.  
  !!
  !! @note If `used` is present, `v` is extended until `max(used+1,d)`; otherwise, it is extended until 
  !! `max(size(v,1)+1, d)`. 
  !! Then `v(d:size(v)-1)` are shifted one position to the right and `val` is assigned to `v(d)`.  
  !!
  !! @warning Note that when `used` is not present, __the array is effectively extended in every call__.  
  module procedure insert_prv
end interface

interface find_first
  !! Finds the first occurrence of a scalar value in an array.
  module procedure find_first_prv
end interface

interface sfind
  !! Finds all the occurrences of a scalar value in an array (subrutine version).
  module procedure sfind_sca_prv
end interface

interface find
  !! Finds all the occurrences of a scalar value in an array (function version).  
  !!
  !! @warning The Fortran 2003 standard implements the clause `source` to allocate an array (included in ifort since version 13.0).
  !! Thus, if `find` returns an array, this code is correct:  
  !! `logical, allocatable :: x(:)`  
  !! `allocate(x, source=find(...))`  
  !! GFortran 4.9 and below does not support this clause and implements an alternative non-standard way:  
  !! `logical, allocatable :: x(:)`  
  !! `x = find(...)`  
  !! If you use GFortran 4.9 or below, we do not recommend the latter non-standard code; use instead the subroutine version, 
  !! `sfind`.  
  module procedure find_sca_prv
end interface

contains

!-----------------------------------------------------------------------
! dealloc_prv (dealloc)
!-----------------------------------------------------------------------
subroutine dealloc_prv(v)
!! Deallocates an logical array.  
!! __Example:__  
!! `program test`  
!! `use basicmod, only: dealloc`  
!! `implicit none`  
!! `logical, allocatable :: v(:)`  
!! `call dealloc(v)`  
!! `end program`  
logical, allocatable :: v(:) !! Array to deallocate.
integer :: res
character(maxpath) :: cad

if (.not. allocated(v)) return
deallocate(v, stat = res, errmsg = cad)
if (res /= 0) call error('(module_alloc_log_r1/dealloc) Unable to deallocate variable: '//trim(cad))
end subroutine

!-----------------------------------------------------------------------
! alloc_prv (alloc)
!-----------------------------------------------------------------------
subroutine alloc_prv(v, d)
!! Allocates an logical array.  
!! __Example__  
!! `program test`  
!! `use basicmod, only: alloc`  
!! `implicit none`  
!! `logical, allocatable :: v(:)`  
!! `call alloc(v, 20)`  
!! `end program`  
logical, allocatable      :: v(:) !! Array to allocate.
integer, intent(in)       :: d    !! Array extension.
integer :: res
character(maxpath) :: cad

if (allocated(v)) then
  if (size(v,1) == d) then; v = .false.; return; end if
  call dealloc(v)
end if
allocate(v(d), stat = res, errmsg = cad)
if (res /= 0) call error('(module_alloc_log_r1/alloc) unable to allocate variable: '//trim(cad))
v = .false.
end subroutine

!-----------------------------------------------------------------------
! extend_prv (extend)
!-----------------------------------------------------------------------
subroutine extend_prv(v, d, fit)
!! Extends the array to contain position `d`.  
!! __Example:__  
!! `program test`  
!! `use basicmod, only: extend`  
!! `implicit none`  
!! `logical, allocatable :: v(:)`  
!! `call extend(v, 40)`  
!! `end program`  
logical, allocatable          :: v(:)    !! Array.
integer, intent(in)           :: d       !! Position to be included in the extension.
logical, intent(in), optional :: fit     !! Whether to fit the array extension to the maximum position; by default, `.true.`
logical, allocatable :: temp(:)
integer :: res, s, ns
character(maxpath) :: cad

if (.not. allocated(v)) then
  !DIMENSIONS
  if (present(fit)) then
    if (fit) then; ns = d                        !we must fit to dimension given as argument
    else; ns = search_multiple(DEFAULT_ALLOC, d) !a multiple of DEFAULT_ALLOC must be taken as new dimension
    end if
  else; ns = d                                   !fit is not present, the same as if it where .true.
  end if
  !ALLOCATION
  allocate(v(ns), stat = res, errmsg = cad)
  if (res /= 0) call error('(module_alloc_log_r1/extend) unable to allocate variable v: '//trim(cad))
  v = .false.
else !v is already allocated
  s = size(v,1)
  if (d > s) then !reallocation is mandatory
    !DIMENSIONS
    if (present(fit)) then
      if (fit) then; ns = d            !we must fit to dimension given as argument, if necessary
      else; ns = search_multiple(s, d) !a multiple of the current size must be taken as new dimension
      end if
    else; ns = d                       !fit is not present, the same as if it where .true.
    end if
    !REALLOCATION
    allocate(temp(ns), stat = res, errmsg = cad)
    if (res /= 0) call error('(module_alloc_log_r1/extend) unable to allocate variable temp: '//trim(cad))
    temp(1:s)    = v
    temp(s+1:ns) = .false.
    call move_alloc(from=temp, to=v)
  end if
end if
end subroutine

!-----------------------------------------------------------------------
! reduce_prv (reduce)
!-----------------------------------------------------------------------
subroutine reduce_prv(v, d)
!! Reduces the extension of an array.  
!! __Example:__  
!! `program test`  
!! `use basicmod, only: alloc, reduce`  
!! `implicit none`  
!! `logical, allocatable :: v(:)`  
!! `call alloc(v, 40)`  
!! `call reduce(v, 20)`  
!! `end program`  
logical, allocatable      :: v(:)   !! Array.
integer, intent(in)       :: d      !! Array extension.
logical, allocatable :: temp(:)

!if (d == 0) then
!  call info('(module_alloc_log_r1/reduce) Given dimension is zero, variable will be deallocated')
!  call dealloc(v)
!else
if (.not. allocated(v)) then
  call info('(module_alloc_log_r1/reduce) Variable not allocated'); return
end if
if (size(v,1) == d) return !v has the right size
if (size(v,1) <  d) then   !d is too large
  call info('(module_alloc_log_r1/reduce) Given dimension is too large to reduce'); return
end if
call alloc(temp, d)
temp = v(1:d)
call move_alloc(from=temp, to=v)
end subroutine

!-----------------------------------------------------------------------
! set_scalar_prv (set)
!-----------------------------------------------------------------------
subroutine set_scalar_prv(v, val, d, fit)
!! Sets a scalar in the array.  
!! __Example:__  
!! `program test`  
!! `use basicmod, only: set`  
!! `implicit none`  
!! `logical, allocatable :: v(:)`  
!! `call set(v, .true., 10, fit=.false.)`  
!! `end program`
logical, allocatable          :: v(:) !! Array.
logical,           intent(in) :: val  !! Value.
integer,           intent(in) :: d    !! Position.
logical, optional, intent(in) :: fit  !! Whether to fit the array extension to the maximum position; by default, `.true.`

call extend(v, d, fit)
v(d) = val
end subroutine

!-----------------------------------------------------------------------
! set_vector_prv (set)
!-----------------------------------------------------------------------
subroutine set_vector_prv(v, val, d, fit)
!! Sets a vector in the array.  
!! __Example:__  
!! `program test`  
!! `use basicmod, only: set`  
!! `implicit none`  
!! `logical, allocatable :: v(:)`  
!! `call set(v, [.true., .false.], [10,13], fit=.false.)`  
!! `end program`  
logical, allocatable          :: v(:)   !! Array.
logical, intent(in)           :: val(:) !! Value.
integer, intent(in)           :: d(:)   !! Position.
logical, intent(in), optional :: fit    !! Whether to fit the array extension to the maximum position; by default, `.true.`

call extend(v, maxval(d), fit)
v(d) = val
end subroutine

!-----------------------------------------------------------------------
! insert_prv (insert)
!-----------------------------------------------------------------------
subroutine insert_prv(v, val, d, used, fit)
!! Inserts a scalar in the array.  
!! __Example:__  
!! `program test`  
!! `use basicmod, only: insert`  
!! `implicit none`  
!! `logical, allocatable :: v(:)`  
!! `call insert(v, .true., 10, used=7, fit=.false.)`  
!! `end program`  
logical, allocatable          :: v(:) !! Array.
logical, intent(in)           :: val  !! Value.
integer, intent(in)           :: d    !! Position.
integer, intent(in), optional :: used !! Number of rows actually used in vector.
logical, intent(in), optional :: fit  !! Whether to fit the array extension to the maximum position; by default, `.true.`
integer :: s

if (present(used)) then; s = max(used+1, d)
else; s = max(size(v,1)+1, d)
end if

call extend(v, s, fit)
v(d+1:size(v,1)) = v(d:size(v,1)-1)
v(d) = val
end subroutine

!-----------------------------------------------------------------------
! find_first_prv (find_first)
!-----------------------------------------------------------------------
function find_first_prv(v, val) result(res)
!! Finds the first occurrence of a scalar value in an array.  
!! __Example:__  
!! `program test`  
!! `use basicmod, only: alloc, find_first`  
!! `implicit none`  
!! `logical, allocatable :: v(:)`  
!! `call alloc(v, 6)`  
!! `v = [.true., .true., .false., .true., .true., .false.]`  
!! `print*, find_first(v, .false.)`  
!! `end program`  
logical,             intent(in) :: v(:) !! Array.
logical,             intent(in) :: val  !! Value to search.
integer                         :: res  !! Position of the first occurrence; return 0 if nothing was found.
integer :: i

res = 0
if (csize(log1=v, d=1) <= 0) return
do i = 1, size(v,1)
  if (v(i) .eqv. val) then
    res = i
    return
  end if
end do
end function

!-----------------------------------------------------------------------
! sfind_sca_prv (sfind)
!-----------------------------------------------------------------------
subroutine sfind_sca_prv(v, val, res)
!! Finds all the occurrences of scalar value in an array (subrutine version).  
!! __Example:__  
!! `program test`  
!! `use basicmod, only: alloc, sfind`  
!! `implicit none`  
!! `logical, allocatable :: v(:), pos(:)`  
!! `call alloc(v, 6)`  
!! `v = [.true., .true., .false., .true., .true., .false.]`  
!! `call sfind(v, .false., pos)`  
!! `end program`  
logical,              intent(in)  :: v(:)   !! Array.
logical,              intent(in)  :: val    !! Value to search.
integer, allocatable, intent(out) :: res(:) !! Array of positions; returns a zero size array if nothing was found.
integer :: i, n, p

! allocate res
if (csize(log1=v, d=1) <= 0) return
n = size(pack(v, v .eqv. val), 1)
call alloc(res, n)
if (n <= 0) return
! find positions
p = 1
do i = 1, size(v,1)
  if (v(i) .eqv. val) then
    res(p) = i
    p = p+1
  end if
  if (p > n) return
end do
end subroutine

!-----------------------------------------------------------------------
! find_sca_prv (find)
!-----------------------------------------------------------------------
function find_sca_prv(v, val) result(res)
!! Finds all the occurrences of scalar value in an array (function version).  
!! __Example:__  
!! `program test`  
!! `use basicmod, only: alloc, find`  
!! `implicit none`  
!! `logical, allocatable :: v(:)`  
!! `integer, allocatable :: pos(:)`  
!! `call alloc(v, 6)`  
!! `v = [.true., .true., .false., .true., .true., .false.]`  
!! `allocate(pos, source=find(v, .false.))`  
!! `! the latter is not valid in Gfortan 4.9 and below; write the following code or use sfind instead:`  
!! `! pos = find(v, .false.)`  
!! `end program`  
logical,             intent(in) :: v(:)   !! Array.
logical,             intent(in) :: val    !! Value to search.
integer, allocatable            :: res(:) !!! Array of positions; a zero-sized array if nothing was found.

call sfind(v, val, res)
end function
end module
