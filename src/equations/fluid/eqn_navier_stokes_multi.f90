module eqn_navier_stokes_multi
#include <messenger.h>
    use type_equation_set,          only: equation_set_t
    use type_equation_builder,      only: equation_builder_t
    use type_fluid_pseudo_timestep, only: fluid_pseudo_timestep_t
    implicit none


    !>
    !!
    !!
    !!
    !--------------------------------------------------------------------------------------------
    type, public, extends(equation_builder_t) :: navier_stokes_multi

    contains

        procedure   :: init
        procedure   :: build

    end type navier_stokes_multi
    !********************************************************************************************




contains


    !>
    !!
    !!  @author Nathan A. Wukie (AFRL)
    !!  @date   8/30/2016
    !!
    !---------------------------------------------------------------------------------------------
    subroutine init(self)
        class(navier_stokes_multi),   intent(inout)  :: self

        call self%set_name('Navier Stokes Multi')

    end subroutine init
    !*********************************************************************************************



    !>
    !!
    !!  @author Nathan A. Wukie (AFRL)
    !!  @date   8/30/2016
    !!
    !!
    !---------------------------------------------------------------------------------------------
    function build(self,blueprint) result(navier_stokes_multi_eqns)
        class(navier_stokes_multi), intent(in)  :: self
        character(*),               intent(in)  :: blueprint

        type(equation_set_t)            :: navier_stokes_multi_eqns
        type(fluid_pseudo_timestep_t)   :: fluid_pseudo_time

        !
        ! Set equation set name
        !
        call navier_stokes_multi_eqns%set_name(self%get_name())
        

        !
        ! Add spatial operators
        !
        select case (trim(blueprint))


            case('default')
                call navier_stokes_multi_eqns%add_operator('Euler Volume Flux')
                call navier_stokes_multi_eqns%add_operator('Euler Boundary Average Flux')
                call navier_stokes_multi_eqns%add_operator('Euler Roe Flux')
                call navier_stokes_multi_eqns%add_operator('Euler BC Flux')
                call navier_stokes_multi_eqns%add_operator('Euler Volume Cylindrical Source')

!                call navier_stokes_multi_eqns%add_operator('Fluid Viscous Volume Operator')
!                call navier_stokes_multi_eqns%add_operator('Fluid Viscous Boundary Average Operator')
!                call navier_stokes_multi_eqns%add_operator('Fluid Viscous BC Operator')
!                call navier_stokes_multi_eqns%add_operator('Fluid Viscous Volume Cylindrical Source')

                call navier_stokes_multi_eqns%add_model('Ideal Gas')
                call navier_stokes_multi_eqns%add_model('Sutherlands Law')
!                call navier_stokes_multi_eqns%add_model('Constant Viscosity')
!                call navier_stokes_multi_eqns%add_model('Stokes Hypothesis')
!                call navier_stokes_multi_eqns%add_model('Reynolds Analogy')
!                call navier_stokes_multi_eqns%add_model('Zero Turbulent Model Fields')





!                call navier_stokes_multi_eqns%add_operator('Spalart-Allmaras Source Operator')
                call navier_stokes_multi_eqns%add_operator('Spalart-Allmaras LaxFriedrichs Operator')
                call navier_stokes_multi_eqns%add_operator('Spalart-Allmaras Volume Advection Operator')
                call navier_stokes_multi_eqns%add_operator('Spalart-Allmaras BC Advection Operator')
!                call navier_stokes_multi_eqns%add_operator('Spalart-Allmaras Boundary Diffusion Operator')
!                call navier_stokes_multi_eqns%add_operator('Spalart-Allmaras Volume Diffusion Operator')
!                call navier_stokes_multi_eqns%add_operator('Spalart-Allmaras BC Diffusion Operator')


                ! Add shear stress after turbulence viscosity models from SA so they are computed first
!                call navier_stokes_multi_eqns%add_model('Shear Stress')
!                call navier_stokes_multi_eqns%add_model('Temperature Gradient')


                call navier_stokes_multi_eqns%add_pseudo_timestep(fluid_pseudo_time)


            case default
                call chidg_signal_one(FATAL, "build_navier_stokes: I didn't recognize the &
                                              construction parameter that was passed to build &
                                              the equation set.", blueprint)

        end select


    end function build
    !**********************************************************************************************






end module eqn_navier_stokes_multi
