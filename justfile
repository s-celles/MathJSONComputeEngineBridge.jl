# Run the example notebook by default.
default: example

# Run a notebook from the notebooks directory (e.g. `just run example.jl`).
run notebook:
    julia --project=. -e 'using Pluto; Pluto.run(notebook=joinpath("notebooks", "{{ notebook }}"))'

# Run the main example notebook.
example:
    just run example.jl
