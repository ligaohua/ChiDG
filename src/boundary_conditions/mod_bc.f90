!>  Boundary condition module
!!      - contains instantiations of all boundary condition for dynamically creating boundary conditions at run-time
!!      
!!
!!  Registering boundary conditions
!!      - To register a boundary condition:
!!          1st: Import it's definition for use in the current module
!!          2nd: Declare an instance of the boundary condition
!!          3rd: Extend 'create_bc' to include a selection criteria for the boundary condition
!!          4th: Under the selection criteria in 'create_bc', include a statement for dynamically allocating the boundary condition
!!
!--------------------------------------------------------
module mod_bc
#include <messenger.h>
    use mod_kinds,      only: rk,ik
    use type_bc,        only: bc_t
    use type_bcvector,  only: bcvector_t

    ! IMPORT BOUNDARY CONDITIONS
!    use bc_periodic,                    only: periodic_t
    use bc_linearadvection_extrapolate, only: linearadvection_extrapolate_t
    use bc_euler_wall,                  only: euler_wall_t
    use bc_euler_totalinlet,            only: euler_totalinlet_t
    use bc_euler_pressureoutlet,        only: euler_pressureoutlet_t
    use bc_euler_extrapolate,           only: euler_extrapolate_t
!    use bc_lineuler_extrapolate,        only: lineuler_extrapolate_t
!    use bc_lineuler_inlet,              only: lineuler_inlet_t
    implicit none


    !
    ! Global vector of registered boundary conditions
    !
    type(bcvector_t)    :: registered_bcs
    logical             :: initialized = .false.

contains


    !>  Register boundary conditions in a module vector.
    !!
    !!  This allows the available boundary conditions to be queried in the same way that they 
    !!  are registered for allocation.
    !!
    !!  @author Nathan A. Wukie
    !!  @date   2/8/2016
    !!
    !!
    !--------------------------------------------------------------------------------------------
    subroutine register_bcs()
        integer :: nbcs, ibc

        !
        ! Instantiate bcs
        !
        type(linearadvection_extrapolate_t) :: LINEARADVECTION_EXTRAPOLATE
        type(euler_wall_t)                  :: EULER_WALL
        type(euler_totalinlet_t)            :: EULER_TOTALINLET
        type(euler_pressureoutlet_t)        :: EULER_PRESSUREOUTLET
        type(euler_extrapolate_t)           :: EULER_EXTRAPOLATE


        if ( .not. initialized ) then
            !
            ! Register in global vector
            !
            call registered_bcs%push_back(LINEARADVECTION_EXTRAPOLATE)
            call registered_bcs%push_back(EULER_WALL)
            call registered_bcs%push_back(EULER_TOTALINLET)
            call registered_bcs%push_back(EULER_PRESSUREOUTLET)
            call registered_bcs%push_back(EULER_EXTRAPOLATE)


            !
            ! Initialize each boundary condition in set. Doesn't need modified.
            !
            nbcs = registered_bcs%size()
            do ibc = 1,nbcs
                call registered_bcs%data(ibc)%bc%add_options()
            end do

            !
            ! Confirm initialization
            !
            initialized = .true.

        end if

    end subroutine register_bcs
    !********************************************************************************************








    !> Boundary condition factory
    !!      - Allocate a concrete boundary condition type based on the incoming string specification.
    !!      - Initialize the allocated boundary condition.
    !!
    !!  @author Nathan A. Wukie
    !!  @date   1/31/2016
    !!
    !!  @param[in]      string  Character string used to select the appropriate boundary condition
    !!  @param[inout]   bc      Allocatable boundary condition
    !!
    !--------------------------------------------------------------
    subroutine create_bc(bcstring,bc)
        character(*),                   intent(in)      :: bcstring
        class(bc_t),    allocatable,    intent(inout)   :: bc

        integer(ik) :: ierr, bcindex


        if ( allocated(bc) ) then
            deallocate(bc)
        end if



        !
        ! Find equation set in 'registered_bcs' vector
        !
        bcindex = registered_bcs%index_by_name(trim(bcstring))



        !
        ! Check equationset was found in 'registered_bcs'
        !
        if (bcindex == 0) call chidg_signal_one(FATAL,"create_bc: boundary condition not recognized", trim(bcstring))



        !
        ! Allocate conrete bc_t instance
        !
        allocate(bc, source=registered_bcs%data(bcindex)%bc, stat=ierr)
        if (ierr /= 0) call chidg_signal(FATAL,"create_bc: error allocating boundary condition from global vector.")



        !
        ! Check boundary condition was allocated
        !
        if ( .not. allocated(bc) ) call chidg_signal(FATAL,"create_bc: error allocating concrete boundary condition.")



    end subroutine create_bc
    !*************************************************************************************







    !>  This is really a utilitity for 'chidg edit' to dynamically list the avalable 
    !!  boundary conditions.
    !!
    !!  @author Nathan A. Wukie
    !!  @date   2/8/2016
    !!
    !--------------------------------------------------------------------------------------
    subroutine list_bcs()
        integer                         :: nbcs, ibc
        character(len=:),   allocatable :: bcname

        nbcs = registered_bcs%size()


        do ibc = 1,nbcs

            bcname = registered_bcs%data(ibc)%bc%get_name()


            call write_line(trim(bcname))
        end do ! ieqn

    end subroutine list_bcs
    !**************************************************************************************









































end module mod_bc
