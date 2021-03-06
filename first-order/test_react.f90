program main

  use network
  use bl_types

  implicit none

  !integer, parameter :: NPTS = 8192 ! this is the number of hydro cells
  !integer, parameter :: NPTS = 16384 ! this is the number of hydro cells
  !integer, parameter :: NPTS = 32768 ! this is the number of hydro cells
  integer, parameter :: NPTS = 110592 ! this is the size of a 48**3 grid, a typical grid size on a single node

  real(kind=dp_t) :: Xin(nspec, NPTS), Xout(nspec, NPTS)
  real(kind=dp_t) :: rho(NPTS), temp(NPTS)
  real(kind=dp_t) :: tmax, strt, stp 

  integer :: ic12, io16, ierr

  !Since react() is linked externally, we need an interface to tell the compiler react uses
  !assumed shape arrays
  interface 
     subroutine react(Xin, T, rho, tmax, Xout, ierr) 
        import dp_t
        real(kind=dp_t), intent(in)  :: Xin(:,:), T(:), rho(:), tmax
        real(kind=dp_t), intent(out) :: Xout(:,:)
        integer,          intent(out) :: ierr
     end subroutine
  end interface
  
  ! initialize the network
  call network_init()

  ! setup the composition
  ic12 = network_species_index("carbon-12")
  io16 = network_species_index("oxygen-16")
  Xin(:,:) = 0
  Xin(ic12,:) = 0.5d0
  Xin(io16,:) = 0.5d0

  ! burn
  temp(:) = 8.e8
  rho(:) = 2.6e9
  tmax = 1000.0

  call cpu_time(strt)
  call react(Xin, temp, rho, tmax, Xout, ierr)
  call cpu_time(stp)

  print *, ierr
  print *, Xout(:,1)
  print *, 'runtime: ', stp - strt, ' seconds'
  !print *, Xout(:,224)

end program main
