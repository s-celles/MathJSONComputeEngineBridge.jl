### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 8a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d
begin
    import Pkg
    Pkg.activate(joinpath(@__DIR__, ".."))
    Pkg.develop(path="/home/scelles-admin/git/github/s-celles/julia/PlutoMathInput.jl")
    Pkg.instantiate()
    using PlutoMathInput
	using MathJSON: MathJSONFormat, parse, generate 
	using MathJSONComputeEngineBridge: default_backend, evaluate
	using Giac
	using Giac.Commands
	#using Symbolics
end

# ╔═╡ 46f4aefa-8238-428f-bc01-90855e43a10c
backend = default_backend()

# ╔═╡ 1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d
md"""
# MathJSONComputeEngineBridge.jl — Example Notebook

This notebook demonstrates the **MathJSONComputeEngineBridge with $(backend)**.
"""

# ╔═╡ 2a3b4c5d-6e7f-8a9b-0c1d-2e3f4a5b6c7d
md"""
## 1. Basic usage

Type a formula below — the MathJSON representation is shown in the next cell.
"""

# ╔═╡ 3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d
@bind formula_basic MathInput(format=:mathjson)

# ╔═╡ 4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d
formula_basic  # MathJSON string

# ╔═╡ b2d74da0-853b-4bae-bc95-5e8568f45233
md"""
## 2. Derivative

The widget can be pre-filled with a MathJSON expression
"""

# ╔═╡ 42625fdb-c3b9-4a34-85f1-34a86d39137e
@bind formula_mathjson_default MathInput(default="[\"D\", [\"Sin\", \"x\"], \"x\"]", format=:mathjson, canonicalize=false)

# ╔═╡ 70cf1f91-f021-4e18-9a71-b505c6fd4b7e
formula_mathjson_default  # MathJSON string

# ╔═╡ 580a1018-0bee-4dc9-a4ee-be5bc9db8290
evaluate(parse(MathJSONFormat, formula_mathjson_default))

# ╔═╡ e5278697-e78a-4ec6-8c2b-0a5f020f9475
to_giac(evaluate(parse(MathJSONFormat, formula_mathjson_default)))

# ╔═╡ ba29fe53-c93f-46c2-aa7a-4776ab4941aa
md"""
## 3. Integrate

The widget can be pre-filled with a MathJSON expression
"""

# ╔═╡ 2f9e4094-02c6-48f1-9a3c-4ddeecfbe03a
begin
	@giac_var x t s
	to_mathjson(sin(x))
end

# ╔═╡ b30fcde2-8b2e-4b08-8351-d1af33e387be


# ╔═╡ 6e09fd4a-fc17-455f-9b4e-2ac07cda7735
display_cmd(:integrate, x)

# ╔═╡ 01bcc632-9bc3-4db0-a5a9-940ff4a08ef2
display_cmd(:laplace, t, s)

# ╔═╡ c582cc9c-994c-4b97-a9b7-2db3b71d30a3
@bind formula_mathjson_default2 MathInput(default="[\"Integrate\", [\"sin\", \"x\"], \"x\"]", format=:mathjson, canonicalize=false)

# ╔═╡ c80f902d-c43f-4fcc-ac1b-d389606a2ff4
formula_mathjson_default2

# ╔═╡ 7a53c460-af0d-40ee-a0dd-eceaa30f675e
MathDisplay(default=formula_mathjson_default2)

# ╔═╡ b1904dbe-17c9-4d03-b9a6-c2b48d833970
parse(MathJSONFormat, formula_mathjson_default2)

# ╔═╡ c036c3a1-094e-4672-a4d0-0210565ad194
begin
	result = evaluate(parse(MathJSONFormat, formula_mathjson_default2))
	simplify(to_giac(result))
end

# ╔═╡ Cell order:
# ╠═8a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d
# ╠═46f4aefa-8238-428f-bc01-90855e43a10c
# ╟─1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d
# ╟─2a3b4c5d-6e7f-8a9b-0c1d-2e3f4a5b6c7d
# ╠═3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d
# ╠═4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d
# ╟─b2d74da0-853b-4bae-bc95-5e8568f45233
# ╠═42625fdb-c3b9-4a34-85f1-34a86d39137e
# ╠═70cf1f91-f021-4e18-9a71-b505c6fd4b7e
# ╠═580a1018-0bee-4dc9-a4ee-be5bc9db8290
# ╠═e5278697-e78a-4ec6-8c2b-0a5f020f9475
# ╟─ba29fe53-c93f-46c2-aa7a-4776ab4941aa
# ╠═2f9e4094-02c6-48f1-9a3c-4ddeecfbe03a
# ╠═b30fcde2-8b2e-4b08-8351-d1af33e387be
# ╠═6e09fd4a-fc17-455f-9b4e-2ac07cda7735
# ╠═01bcc632-9bc3-4db0-a5a9-940ff4a08ef2
# ╠═c582cc9c-994c-4b97-a9b7-2db3b71d30a3
# ╠═c80f902d-c43f-4fcc-ac1b-d389606a2ff4
# ╠═7a53c460-af0d-40ee-a0dd-eceaa30f675e
# ╠═b1904dbe-17c9-4d03-b9a6-c2b48d833970
# ╠═c036c3a1-094e-4672-a4d0-0210565ad194
