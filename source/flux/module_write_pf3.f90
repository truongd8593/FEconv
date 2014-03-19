module module_write_pf3

!-----------------------------------------------------------------------
! Module to manage PF3 (Flux) files
!
! Licensing: This code is distributed under the GNU GPL license.
! Author: Victor Sande, victor(dot)sande(at)usc(dot)es
! Last update: 21/02/2014
!
! PUBLIC PROCEDURES:
! write_pf3_header: write PF3 header
! write_pf3_elements: write PF3 elements
! write_pf3_coordinates: write PF3 coordinates
!-----------------------------------------------------------------------

use module_COMPILER_DEPENDANT, only: real64
use module_os_dependant, only: maxpath
use module_report, only:error
use module_set, only:unique
use module_convers
use module_mesh
use module_pmh
use module_utils_pf3

implicit none


contains


!-----------------------------------------------------------------------
! write_pf3_header(iu, pmh): write PF3 header
!-----------------------------------------------------------------------
! iu:  unit number of the PF3 file
! pmh: pmh mesh
!-----------------------------------------------------------------------

subroutine write_pf3_header(iu, pmh)
  integer, intent(in)        :: iu  ! Unit number for PF3 file
  type(pmh_mesh), intent(in) :: pmh
  integer                    :: i, j
  integer                    :: npoints = 0
  integer                    :: nel = 0
  integer                    :: npointel = 0
  integer                    :: nedgeel = 0
  integer                    :: nsurfel = 0
  integer                    :: nvolel = 0
  integer                    :: nregs = 0
  integer                    :: npointregs = 0
  integer                    :: nedgeregs = 0
  integer                    :: nsurfregs = 0
  integer                    :: nvolregs = 0

    if(.not. allocated(pmh%pc)) call error('module_write_pf3/write_header # Piece not allocated')


    ! Count the number of elements and regions of each topological dimension
    do i = 1, size(pmh%pc,1)
      if(.not. allocated(pmh%pc(i)%el)) call error('module_write_pf3/write_header # Element group not allocated')
      do j = 1, size(pmh%pc(i)%el,1)
        nel = nel + pmh%pc(i)%el(j)%nel
        if(FEDB(pmh%pc(i)%el(j)%type)%tdim == 0) then
          npointel = npointel + pmh%pc(i)%el(j)%nel
          npointregs = npointregs + size(unique(pmh%pc(i)%el(j)%ref),1)
        elseif(FEDB(pmh%pc(i)%el(j)%type)%tdim == 1) then
          nedgeel = nedgeel + pmh%pc(i)%el(j)%nel
          nedgeregs = nedgeregs + size(unique(pmh%pc(i)%el(j)%ref),1)
        elseif(FEDB(pmh%pc(i)%el(j)%type)%tdim == 2) then
          nsurfel = nsurfel + pmh%pc(i)%el(j)%nel
          nsurfregs = nsurfregs + size(unique(pmh%pc(i)%el(j)%ref),1)
        elseif(FEDB(pmh%pc(i)%el(j)%type)%tdim == 3) then
          nvolel = nvolel + pmh%pc(i)%el(j)%nel
          nvolregs = nvolregs + size(unique(pmh%pc(i)%el(j)%ref),1)
        endif
      enddo
      nregs = npointregs + nedgeregs + nsurfregs + nvolregs
      if(pmh%pc(i)%nnod /= 0) then 
        npoints = npoints + pmh%pc(i)%nnod
      else 
        npoints = npoints + pmh%pc(i)%nver
      endif
    enddo

    ! Write Flux PF3 header
    call write_line(iu,                                  'File converted with FEconv')
    call write_line(iu,trim(string(pmh%pc(1)%dim))//' '//'NOMBRE DE DIMENSIONS DU DECOUPAGE')
    call write_line(iu,trim(string(nel))          //' '//'NOMBRE  D''ELEMENTS')
    call write_line(iu,trim(string(nvolel))       //' '//'NOMBRE  D''ELEMENTS VOLUMIQUES')
    call write_line(iu,trim(string(nsurfel))      //' '//'NOMBRE  D''ELEMENTS SURFACIQUES')
    call write_line(iu,trim(string(nedgeel))      //' '//'NOMBRE  D''ELEMENTS LINEIQUES')
    call write_line(iu,trim(string(npointel))     //' '//'NOMBRE  D''ELEMENTS PONCTUELS')
    call write_line(iu,trim(string(0))            //' '//'NOMBRE DE MACRO-ELEMENTS')
    call write_line(iu,trim(string(npoints))      //' '//'NOMBRE DE POINTS')
    call write_line(iu,trim(string(nregs))        //' '//'NOMBRE DE REGIONS')
    call write_line(iu,trim(string(nvolregs))     //' '//'NOMBRE DE REGIONS VOLUMIQUES')
    call write_line(iu,trim(string(nsurfregs))    //' '//'NOMBRE DE REGIONS SURFACIQUES')
    call write_line(iu,trim(string(nedgeregs))    //' '//'NOMBRE DE REGIONS LINEIQUES')
    call write_line(iu,trim(string(npointregs))   //' '//'NOMBRE DE REGIONS PONCTUELLES')
    call write_line(iu,trim(string(0))            //' '//'NOMBRE DE REGIONS MACRO-ELEMENTAIRES')
    call write_line(iu,trim(string(20))           //' '//'NOMBRE DE NOEUDS DANS 1 ELEMENT (MAX)')
    call write_line(iu,trim(string(20))           //' '//'NOMBRE DE POINTS D''INTEGRATION / ELEMENT (MAX)')

    ! Write Flux PF3 regions
    call write_line(iu,'NOMS DES REGIONS')

    ! Write Flux PF3 volume region names
    if(nvolregs>0) call write_line(iu, 'REGIONS VOLUMIQUES')
    do i = 1, nvolregs
      call write_line(iu,'REGIONVOLUME_'//string(i))
    enddo

    ! Write Flux PF3 surface region names
    if(nsurfregs>0) call write_line(iu, 'REGIONS SURFACIQUES')
    do i = 1, nsurfregs
      call write_line(iu, 'REGIONFACE_'//string(i))
    enddo

    ! Write Flux PF3 edge region names
    if(nedgeregs>0) call write_line(iu, 'REGIONS LINEIQUES')
    do i = 1, nedgeregs
      call write_line(iu, 'REGIONLINE_'//string(i))
    enddo

    ! Write Flux PF3 point region names
    if(npointregs>0) call write_line(iu, 'REGIONS PONCTUELLES')
    do i = 1, npointregs
      call write_line(iu, 'REGIONPOINT_'//string(i))
    enddo


    ! Write Flux PF3 region descriptors
    do i = 1, nvolregs; 
      call write_line(iu, trim(string(0))//' '//trim(string(4))//' '//trim(string(5)))
    enddo
    do i = 1, nsurfregs
      call write_line(iu, trim(string(0))//' '//trim(string(3))//' '//trim(string(5)))
    enddo
    do i = 1, nedgeregs
      call write_line(iu, trim(string(0))//' '//trim(string(2))//' '//trim(string(5)))
    enddo
    do i = 1, npointregs
      call write_line(iu, trim(string(0))//' '//trim(string(1))//' '//trim(string(5)))
    enddo

end subroutine


!-----------------------------------------------------------------------
! write_pf3_elements(iu, pmh): write PF3 elements
!-----------------------------------------------------------------------
! iu:  unit number of the PF3 file
! pmh: pmh mesh
!-----------------------------------------------------------------------

subroutine write_pf3_elements(iu, pmh)
  integer, intent(in)        :: iu  ! Unit number for PF3 file
  type(pmh_mesh), intent(inout) :: pmh
  integer                    :: i, j, k, ios, desc1, desc2, desc3, ref, tdim, lnn, prevnnod, prevnel

    ! Write Flux PF3 header
    write(unit=iu, fmt='(a)', iostat = ios) 'DESCRIPTEUR DE TOPOLOGIE DES ELEMENTS'
    if (ios /= 0) call error('module_write_pf3/write_elements # write error #'//trim(string(ios)))

    prevnnod = 0
    prevnel = 0

    do i = 1, size(pmh%pc,1)
      do j = 1, size(pmh%pc(i)%el,1)
          desc1 = pf3_get_element_desc1(pmh%pc(i)%el(j)%type)
          desc2 = pf3_get_element_desc2(pmh%pc(i)%el(j)%type)
          desc3 = pf3_get_element_desc3(pmh%pc(i)%el(j)%type)
          tdim = FEDB(pmh%pc(i)%el(j)%type)%tdim
          lnn = FEDB(pmh%pc(i)%el(j)%type)%lnn
        do k = 1, pmh%pc(i)%el(j)%nel
          ref = pmh%pc(i)%el(j)%ref(k)
          write(unit=iu, fmt='(12I10)', iostat = ios) k+prevnel,desc1,desc2,ref,tdim+1,0,desc3,lnn,0,0,0,0
          if(.not. FEDB(pmh%pc(i)%el(j)%type)%nver_eq_nnod .and. allocated(pmh%pc(i)%el(j)%nn)) then
            write(unit=iu, fmt='(a)', iostat = ios) &
              string(pmh2pf3_ordering(pmh%pc(i)%el(j)%nn(:,k), pmh%pc(i)%el(j)%type, prevnnod))
            if (ios /= 0) call error('module_write_pf3/write_elements # write error #'//trim(string(ios)))
          elseif(FEDB(pmh%pc(i)%el(j)%type)%nver_eq_nnod .and. allocated(pmh%pc(i)%el(j)%mm)) then
            write(unit=iu, fmt='(a)', iostat = ios) &
              string(pmh2pf3_ordering(pmh%pc(i)%el(j)%mm(:,k), pmh%pc(i)%el(j)%type, prevnnod))
            if (ios /= 0) call error('module_write_pf3/write_elements # write error #'//trim(string(ios)))
          else
            call error('module_write_pf3/write_elements # connectivity array not allocated')
          endif
        enddo
        prevnel = prevnel + pmh%pc(i)%el(j)%nel
      enddo
      if(pmh%pc(i)%nnod /= 0) then
        prevnnod = prevnnod + pmh%pc(i)%nnod
      else
        prevnnod = prevnnod + pmh%pc(i)%nver
      endif
    enddo

end subroutine


!-----------------------------------------------------------------------
! write_pf3_coordinates(iu, pc, all_P1, znod, prevnnod): write PF3 coordinates
!-----------------------------------------------------------------------
! iu:       unit number of the PF3 file
! pc:       piece structure of the mesh
! all_P1:   logical flag, true if all element groups are Lagrange P1
! znod:     array of node coordinates, necessary if not all element groups are Lagrange P1
! prevnnod: number of nodes writed in previous pieces
!-----------------------------------------------------------------------

subroutine write_pf3_coordinates(iu, pc, all_P1, znod, prevnnod)
  integer, intent(in)           :: iu  ! Unit number for PF3 file
  type(piece), intent(inout)    :: pc
  integer, intent(in)                   ::prevnnod
  logical, intent(in)                   :: all_P1
  real(real64), allocatable, intent(in) :: znod(:,:)
  integer                       :: i, j, ios

!    do i = 1, size(pmh%pc,1)

      if(all_P1) then
        do j = 1, pc%nver
          write(unit=iu, fmt='(a)', iostat = ios) trim(string(j+prevnnod))//' '//trim(string(pc%z(:,j)))
          if (ios /= 0) call error('module_write_pf3/write_coordinates # write error #'//trim(string(ios)))
        enddo
      else
        do j = 1, size(znod,2)
          write(unit=iu, fmt='(a)', iostat = ios) trim(string(j+prevnnod))//' '//trim(string(znod(:,j)))
          if (ios /= 0) call error('module_write_pf3/write_coordinates # write error #'//trim(string(ios)))
        enddo
      endif

!    enddo

end subroutine


end module
