### A Pluto.jl notebook ###
# v0.20.23

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
	#Pkg.add("PlutoMathInput")
	#Pkg.develop(url="https://github.com/s-celles/Giac.jl")
	Pkg.develop(path="/home/scelles-admin/git/github/s-celles/giac/Giac.jl")
    Pkg.develop(path="/home/scelles-admin/git/github/s-celles/julia/PlutoMathInput.jl")
    Pkg.instantiate()
    using PlutoMathInput
	using MathJSON: MathJSONFormat, parse, generate
	using MathJSON: FunctionExpr, NumberExpr, SymbolExpr
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

# ╔═╡ 2a573271-b01e-4717-93a1-27c2d3112d79
md"""
## 1. Giac <-> MathJSON
"""

# ╔═╡ 9b235b16-e443-478b-a6a9-fce5ee331614
@giac_var x t s

# ╔═╡ 5df2c070-8561-4114-941d-1df3c1be9a08
2/sqrt(x^2-1)

# ╔═╡ abcef206-a381-45e2-8e7e-4d01be910e1e
typeof(2/sqrt(x^2-1))

# ╔═╡ 8a675a42-0a40-43ef-a429-66d1749dd7d2
to_mathjson(2/sqrt(x^2-1))

# ╔═╡ 0fb2f0e6-5087-43cf-9dbd-5e0e89127c05
typeof(to_mathjson(2/sqrt(x^2-1)))

# ╔═╡ 52ef829a-83a3-4d0f-a0ec-c6501acca454
println(to_mathjson(2/sqrt(x^2-1)))

# ╔═╡ 7e8f24e8-7843-4e70-8dce-f0407222ffed
mathjson_expr = FunctionExpr(:Multiply, [NumberExpr(2), FunctionExpr(:Power, [FunctionExpr(:Sqrt, [FunctionExpr(:Add, [FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]), NumberExpr(-1)])]), NumberExpr(-1)])])

# ╔═╡ c36d15e1-5010-4135-a707-5196c55e1506
to_giac(mathjson_expr)

# ╔═╡ 2a3b4c5d-6e7f-8a9b-0c1d-2e3f4a5b6c7d
md"""
## 2. Basic usage

Type a formula below — the MathJSON representation is shown in the next cell.
"""

# ╔═╡ 3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d
@bind formula_basic MathInput(format=:mathjson, icon_position=:left, default="[\"Add\",[\"Power\",[\"Sin\",\"x\"],2],[\"Power\",[\"Cos\",\"x\"],2]]")

# ╔═╡ 4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d
formula_basic  # MathJSON string

# ╔═╡ 74a84a84-424c-42e3-a5de-0e3b6b801a20
simplify(to_giac(parse(MathJSONFormat, formula_basic)))

# ╔═╡ b2d74da0-853b-4bae-bc95-5e8568f45233
md"""
## 3. Derivative

The widget can be pre-filled with a MathJSON expression
"""

# ╔═╡ 42625fdb-c3b9-4a34-85f1-34a86d39137e
@bind formula_mathjson_default MathInput(default="[\"D\", [\"Add\",[\"Power\",\"x\",2],[\"Multiply\",3,\"x\"],-1], \"x\"]", format=:mathjson, canonicalize=false)

# ╔═╡ 70cf1f91-f021-4e18-9a71-b505c6fd4b7e
formula_mathjson_default  # MathJSON string

# ╔═╡ 580a1018-0bee-4dc9-a4ee-be5bc9db8290
evaluate(parse(MathJSONFormat, formula_mathjson_default))

# ╔═╡ e5278697-e78a-4ec6-8c2b-0a5f020f9475
to_giac(evaluate(parse(MathJSONFormat, formula_mathjson_default)))

# ╔═╡ ba29fe53-c93f-46c2-aa7a-4776ab4941aa
md"""
## 4. Integrate

The widget can be pre-filled with a MathJSON expression
"""

# ╔═╡ 1678428b-c8c2-46bf-b34d-5d5ccf128744
@bind formula_mathjson_default2 MathInput(default="[\"Integrate\", [\"Add\",[\"Power\",\"x\",2],[\"Multiply\",-3,\"x\"],-1], \"x\"]", format=:mathjson, canonicalize=false)

# ╔═╡ c21d2db1-3e7e-46b4-8a75-af603c47c03d
evaluate(parse(MathJSONFormat, formula_mathjson_default2))

# ╔═╡ c582cc9c-994c-4b97-a9b7-2db3b71d30a3
# ╠═╡ disabled = true
#=╠═╡
@bind formula_mathjson_default2 MathInput(default="[\"Integrate\", [\"sin\", \"x\"], \"x\"]", format=:mathjson, canonicalize=false)
  ╠═╡ =#

# ╔═╡ c80f902d-c43f-4fcc-ac1b-d389606a2ff4
formula_mathjson_default2

# ╔═╡ 7a53c460-af0d-40ee-a0dd-eceaa30f675e
MathDisplay(default=formula_mathjson_default2)

# ╔═╡ b1904dbe-17c9-4d03-b9a6-c2b48d833970
parse(MathJSONFormat, formula_mathjson_default2)

# ╔═╡ c036c3a1-094e-4672-a4d0-0210565ad194
result = evaluate(parse(MathJSONFormat, formula_mathjson_default2))

# ╔═╡ 79e80527-1f23-49db-b667-a4a9e27e5475
simplify(to_giac(result))

# ╔═╡ f16313a7-4df8-42f3-a346-581eb55ee241
md"""# Testing"""

# ╔═╡ b985baf8-b14c-4b58-9cf5-bca2a22b02c9
@bind formula_mathjson_default3 MathInput(default="[\"Integrate\", [\"Add\",[\"Power\",\"x\",2],[\"Multiply\",-3,\"x\"],-1], \"x\"]", format=:mathjson, canonicalize=false)

# ╔═╡ c39c6001-3a39-4372-9a6a-82015b22bbcb
to_giac(evaluate(parse(MathJSONFormat, formula_mathjson_default3)))

# ╔═╡ eb39386a-a462-4f6f-988e-6a9e4b5ff027
simplify(derive(to_giac(evaluate(parse(MathJSONFormat, formula_mathjson_default3))),x))

# ╔═╡ Cell order:
# ╠═8a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d
# ╠═46f4aefa-8238-428f-bc01-90855e43a10c
# ╟─1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d
# ╟─2a573271-b01e-4717-93a1-27c2d3112d79
# ╠═9b235b16-e443-478b-a6a9-fce5ee331614
# ╠═5df2c070-8561-4114-941d-1df3c1be9a08
# ╠═abcef206-a381-45e2-8e7e-4d01be910e1e
# ╠═8a675a42-0a40-43ef-a429-66d1749dd7d2
# ╠═0fb2f0e6-5087-43cf-9dbd-5e0e89127c05
# ╠═52ef829a-83a3-4d0f-a0ec-c6501acca454
# ╠═7e8f24e8-7843-4e70-8dce-f0407222ffed
# ╠═c36d15e1-5010-4135-a707-5196c55e1506
# ╟─2a3b4c5d-6e7f-8a9b-0c1d-2e3f4a5b6c7d
# ╠═3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d
# ╠═4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d
# ╠═74a84a84-424c-42e3-a5de-0e3b6b801a20
# ╠═b2d74da0-853b-4bae-bc95-5e8568f45233
# ╠═42625fdb-c3b9-4a34-85f1-34a86d39137e
# ╠═70cf1f91-f021-4e18-9a71-b505c6fd4b7e
# ╠═580a1018-0bee-4dc9-a4ee-be5bc9db8290
# ╠═e5278697-e78a-4ec6-8c2b-0a5f020f9475
# ╠═ba29fe53-c93f-46c2-aa7a-4776ab4941aa
# ╠═1678428b-c8c2-46bf-b34d-5d5ccf128744
# ╠═c21d2db1-3e7e-46b4-8a75-af603c47c03d
# ╠═c582cc9c-994c-4b97-a9b7-2db3b71d30a3
# ╠═c80f902d-c43f-4fcc-ac1b-d389606a2ff4
# ╠═7a53c460-af0d-40ee-a0dd-eceaa30f675e
# ╠═b1904dbe-17c9-4d03-b9a6-c2b48d833970
# ╠═c036c3a1-094e-4672-a4d0-0210565ad194
# ╠═79e80527-1f23-49db-b667-a4a9e27e5475
# ╠═f16313a7-4df8-42f3-a346-581eb55ee241
# ╠═b985baf8-b14c-4b58-9cf5-bca2a22b02c9
# ╠═c39c6001-3a39-4372-9a6a-82015b22bbcb
# ╠═eb39386a-a462-4f6f-988e-6a9e4b5ff027
