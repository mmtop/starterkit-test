# Source code
The functions used to compute the multislice algorithms described in this thesis. 
This notebooks is not meant to be ran. 
For more information on the code please visit the abTEM [GitHub](https://github.com/abTEM/abTEM).

```{note} The code has changed somewhat compared to the original paper to meet the requirements of abTEM. The code as it is shown here is the code that is currently in abTEM.
```

(conventional-operator)=
```{code-cell} python
:caption: The realspace conventional multislice step argument including the 2D Laplacian (propagator) and transmission operator. 
def conventional_operator(
    waves: np.ndarray | da.core.Array,
    laplace: Callable,
    transmission_function: np.ndarray,
    wavelength: float,
):
    """
    Split-step real-space multislice operator used in all higher-order expansions.

    Parameters
    ----------
    waves: Waves
        Waves object to apply multislice operator on
    laplace: Callable
        Fast laplace operator stencil function
    transmission_function: np.ndarray,
        Scaled potential slice to multiply incoming waves with
    wavelength: float
        Waves wavelength
    """
    K0 = 1 / wavelength
    return laplace(waves) / (4 * np.pi * K0) + transmission_function * waves
```

(multislice_exponential-series)=
```{code-cell} python
:caption: The multislice exponential series used to calculate the exponent of the 2D Laplacian and transmission operator @multislice-simplified-schrodinger. Might not converge for certain simulation parameters.
def _multislice_exponential_series(
    waves: np.ndarray | da.core.Array,
    transmission_function: np.ndarray,
    laplace: Callable,
    wavelength: float,
    thickness: float,
    tolerance: float = 1e-16,
    max_terms: int = 300,
    order: int = 1,
    fully_corrected: bool = False,
):
    xp = get_array_module(waves)
    initial_amplitude = xp.abs(waves).sum()

    if fully_corrected:
        temp = full_series(
            waves, laplace, transmission_function, order, wavelength, thickness
        )
    else:
        temp = propagator_taylor_series(
            waves,
            order=order,
            laplace=laplace,
            transmission_function=transmission_function,
            wavelength=wavelength,
            thickness=thickness,
        )

    waves += temp

    for i in range(2, max_terms + 1):
        if fully_corrected:
            temp = (
                full_series(
                    temp, laplace, transmission_function, order, wavelength, thickness
                )
                / i
            )
        else:
            temp = (
                propagator_taylor_series(
                    temp,
                    order=order,
                    laplace=laplace,
                    transmission_function=transmission_function,
                    wavelength=wavelength,
                    thickness=thickness,
                )
            ) / i

        waves += temp
        temp_amplitude = xp.abs(temp).sum()
        if temp_amplitude / initial_amplitude <= tolerance:
            break

        if temp_amplitude > initial_amplitude:
            raise DivergedError()
    else:
        raise NotConvergedError(
            f"series did not converge to a tolerance of {tolerance} in {max_terms}terms"
        )
    return waves
```

(propagator-taylor-series)=
```{code-cell} python
:caption: Taylor series of the Propagator Corrected Multislice (PCMS) @propagator_corrected_multislice_taylor_series.
def propagator_taylor_series(
    waves: np.ndarray | da.core.Array,
    order: int,
    laplace: Callable,
    transmission_function: np.ndarray,
    wavelength: float,
    thickness: float,
):
    """
    Taylor series expansion of the propagator term in the MS equation.
    Eq.(8) in Ultramicroscopy 134 (2013) 135-143.
    """
    if order < 1:
        raise ValueError("order must be a positive integer and at least 1")

    if order == 1:
        return (
            conventional_operator(waves, laplace, transmission_function, wavelength)
            * 1.0j
            * thickness
        )

    K0 = 1 / wavelength
    laplace_waves = laplace(waves) / (4 * np.pi * K0)
    series = laplace_waves.copy()
    temp = laplace_waves.copy()

    for i in range(2, order + 1):
        prefactor = (wavelength / (-2.0 * np.pi)) ** (i - 1) * 0.5
        temp = laplace(temp) / (4 * np.pi * K0)
        series += temp * prefactor

    return (series + waves * transmission_function) * 1.0j * thickness
```

(full-series)=
```{code-cell} python
:caption: Taylor series of the Fully Corrected Multislice (FCMS) @fully-corrected-ms-ts. Also used for the backscatter operator.
def full_series(
    waves: np.ndarray | da.core.Array,
    laplace: Callable,
    transmission_function: np.ndarray,
    order: int,
    wavelength: float,
    thickness: float,
    override_prefactor: list[float] = [],
):
    """
    Full Taylor series expansion of the MS Eq.(14) in Ultramicrscopy 134 (2013) 135-143.
    override_prefactor used in backscatter call, Eq. (13) in Micron 190 (2025) 103778.
    """
    series = conventional_operator(waves, laplace, transmission_function, wavelength)
    temp = series.copy()
    for i in range(2, order + 1):
        if override_prefactor:
            prefactor = override_prefactor[
                i - 1
            ]  # Note that the first prefactor always gets skipped and is always 1
        else:
            prefactor = (wavelength / (-2.0 * np.pi)) ** (i - 1) * 0.5
        temp = conventional_operator(temp, laplace, transmission_function, wavelength)
        series += temp * prefactor
    return series * 1.0j * thickness
```

(calculate-backscatter)=
```{code-cell} python
:caption: Part of the full multislice step that calculates the backscattered wave per slice @bs-operator.
# constants and prefactors
K0 = 1 / wavelength

# Eq. 7 in Micron 190 (2025) 103778.
backscatter = (
    1
    / (2 * np.pi * 1.0j * thickness)
    * (
        full_series(
            waves._array,
            laplace_stencil,
            transmission_function_array_next_slice,
            order,
            wavelength,
            thickness,
        )
        - full_series(
            waves._array,
            laplace_stencil,
            transmission_function_array,
            order,
            wavelength,
            thickness,
        )
    )
)

# 1/k series with custom prefactors
prefactors = [1]
for i in range(1, order + 1):
    prefactors.append(prefactors[-1] * (1 - 2 * i) / (2 * i))
for i in range(len(prefactors)):
    prefactors[i] = prefactors[i] / (1.0j * thickness) / (np.pi * K0) ** i

backscatter *= (
    1
    / (2 * K0)
    * (
        1
        + full_series(
            waves._array,
            laplace_stencil,
            transmission_function_array_next_slice,
            order,
            wavelength,
            thickness,
            override_prefactor=prefactors,
        )
    )
)

# Eq.10 in Micron 190 (2025) 103778.
waves._array = waves._array - backscatter
```

(back-propagate_backscattered-waves)=
```{code-cell} python
:caption: Function for reconstructing the full backscatter signal by multislicing all backscattered wave back through the sample and coherently summing all parts @backscatter-formula.
def _back_propagate_backscattered_waves(
    backscattered_waves: Waves,
    potential: BasePotential,
    multislice_step: Callable,
) -> Waves:
    """
    For each slice in the multislice step, a small part of the wave get backscattered.
    This function runs the multislice in reverse for each backscattered wave summing
    them for a final backscattered wave result.
    """

    xp = get_array_module(backscattered_waves.device)
    potential_slices = [
        slice
        for _, config in _generate_potential_configurations(potential)
        for slice in config.generate_slices()
    ]

    effective_slices = _aggregate_slices_by_exit_planes(
        potential_slices, potential.exit_planes
    )

    num_slices = len(effective_slices)
    if len(backscattered_waves) != num_slices + 1:
        raise ValueError("Wrong shapes")

    # zero intensity in incoming wave
    backscattered_waves[0]._array[:] = 0

    # Go through potential in reverse
    for i in range(num_slices - 2, -1, -1):
        contribution_at_slice = backscattered_waves[i + 1].copy()
        contribution_at_slice.array = xp.conj(contribution_at_slice.array)
        contribution_at_slice, _ = multislice_step(
            contribution_at_slice, effective_slices[i + 1], next_slice=None
        )
        backscattered_waves[i].array += xp.conj(contribution_at_slice.array)

    return backscattered_waves
```