### A Pluto.jl notebook ###
# v1.0.3

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
	Pkg.develop(url="https://github.com/s-celles/Giac.jl")
	#Pkg.develop(path="/home/scelles-admin/git/github/s-celles/giac/Giac.jl")
    #Pkg.develop(path="/home/scelles-admin/git/github/s-celles/julia/PlutoMathInput.jl")
	Pkg.develop(url="https://github.com/s-celles/PlutoMathInput.jl")
    Pkg.instantiate()
    using PlutoMathInput
	using MathJSON: MathJSONFormat, parse, generate
	using MathJSON: FunctionExpr, NumberExpr, SymbolExpr
	using MathJSONComputeEngineBridge: default_backend, evaluate
	using Giac
	using Giac.Commands
	using LinearAlgebra
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
@giac_var x t s a b c d

# ╔═╡ 5df2c070-8561-4114-941d-1df3c1be9a08
f1(x) = 2/sqrt(x^2-1)

# ╔═╡ d51983dd-946b-4e37-8f47-4c73da011483
f1(x)

# ╔═╡ abcef206-a381-45e2-8e7e-4d01be910e1e
typeof(f1(x))

# ╔═╡ 8a675a42-0a40-43ef-a429-66d1749dd7d2
to_mathjson(f1(x))

# ╔═╡ 0fb2f0e6-5087-43cf-9dbd-5e0e89127c05
typeof(to_mathjson(f1(x)))

# ╔═╡ 52ef829a-83a3-4d0f-a0ec-c6501acca454
println(to_mathjson(f1(x)))

# ╔═╡ 7e8f24e8-7843-4e70-8dce-f0407222ffed
mathjson_expr = FunctionExpr(:Multiply, [NumberExpr(2), FunctionExpr(:Power, [FunctionExpr(:Sqrt, [FunctionExpr(:Add, [FunctionExpr(:Power, [SymbolExpr("x"), NumberExpr(2)]), NumberExpr(-1)])]), NumberExpr(-1)])])

# ╔═╡ c36d15e1-5010-4135-a707-5196c55e1506
# to_giac(mathjson_expr)
mathjson_expr |> to_giac

# ╔═╡ 2a3b4c5d-6e7f-8a9b-0c1d-2e3f4a5b6c7d
md"""
## 2. Basic usage

Type a formula below — the MathJSON representation is shown in the next cell.
"""

# ╔═╡ 370bbeb1-bb71-4104-985a-ced1dbbdf905
begin
	PlutoMathInput.MathInput(expr::GiacExpr, args...; kwargs...) = MathInput(format=:mathjson, default=generate(MathJSONFormat, to_mathjson(expr)), args...; kwargs...)

	PlutoMathInput.MathInput(math_json_expr::FunctionExpr, args...; kwargs...) = MathInput(format=:mathjson, default=generate(MathJSONFormat, math_json_expr), args...; kwargs...)
end

# ╔═╡ 184649d4-3002-4f27-859c-8b678fe5a63f
f2(x) = sin(x)^2 + cos(x)^2

# ╔═╡ 3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d
@bind formula_basic MathInput(f2(x))

# ╔═╡ 4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d
formula_basic  # MathJSON string

# ╔═╡ 74a84a84-424c-42e3-a5de-0e3b6b801a20
# simplify(to_giac(parse(MathJSONFormat, formula_basic)))
formula_basic |> x -> parse(MathJSONFormat, x) |> to_giac |> simplify

# ╔═╡ b2d74da0-853b-4bae-bc95-5e8568f45233
md"""
## 3. Derivative

The widget can be pre-filled with a MathJSON expression
"""

# ╔═╡ e084fd23-4e52-48b0-8006-2c6141621cb8
f3(x) = x^2 + 3*x - 3

# ╔═╡ 29533fe6-1873-4ebd-99f6-cd88105d6762
mathjson_expr3 = FunctionExpr(:D, [to_mathjson(f3(x)), SymbolExpr("x")])

# ╔═╡ 42625fdb-c3b9-4a34-85f1-34a86d39137e
@bind formula_mathjson_default MathInput(mathjson_expr3)

# ╔═╡ 70cf1f91-f021-4e18-9a71-b505c6fd4b7e
formula_mathjson_default  # MathJSON string

# ╔═╡ 580a1018-0bee-4dc9-a4ee-be5bc9db8290
# evaluate(parse(MathJSONFormat, formula_mathjson_default))
parse(MathJSONFormat, formula_mathjson_default) |> evaluate

# ╔═╡ e5278697-e78a-4ec6-8c2b-0a5f020f9475
# to_giac(evaluate(parse(MathJSONFormat, formula_mathjson_default)))

parse(MathJSONFormat, formula_mathjson_default) |> evaluate |> to_giac

# ╔═╡ ba29fe53-c93f-46c2-aa7a-4776ab4941aa
md"""
## 4. Integrate

The widget can be pre-filled with a MathJSON expression
"""

# ╔═╡ e0193038-7425-4b46-b12f-5edce6be0f50
f4(x) = x^2 - 3*x - 1

# ╔═╡ f0b2dd65-f12a-4693-b862-2793fac94e81
mathjson_expr4 = FunctionExpr(:Integrate, [to_mathjson(f4(x)), SymbolExpr("x")])

# ╔═╡ 1678428b-c8c2-46bf-b34d-5d5ccf128744
@bind formula_mathjson_default2 MathInput(mathjson_expr4)

# ╔═╡ c21d2db1-3e7e-46b4-8a75-af603c47c03d
# evaluate(parse(MathJSONFormat, formula_mathjson_default2))

parse(MathJSONFormat, formula_mathjson_default2) |> evaluate

# ╔═╡ 272fe2ab-c263-43fb-a372-4e489eab1b2c
f5(x) = sin(x)

# ╔═╡ 0e6db43d-b897-468e-a2f1-3dc3b78b952a
mathjson_expr5 = FunctionExpr(:Integrate, [to_mathjson(f5(x)), SymbolExpr("x")])

# ╔═╡ c582cc9c-994c-4b97-a9b7-2db3b71d30a3
@bind formula_mathjson_default3 MathInput(mathjson_expr5)

# ╔═╡ c80f902d-c43f-4fcc-ac1b-d389606a2ff4
formula_mathjson_default3

# ╔═╡ 7a53c460-af0d-40ee-a0dd-eceaa30f675e
MathDisplay(default=formula_mathjson_default3)

# ╔═╡ b1904dbe-17c9-4d03-b9a6-c2b48d833970
parse(MathJSONFormat, formula_mathjson_default3)

# ╔═╡ c036c3a1-094e-4672-a4d0-0210565ad194
# result = evaluate(parse(MathJSONFormat, formula_mathjson_default2))
result = parse(MathJSONFormat, formula_mathjson_default3) |> evaluate

# ╔═╡ 79e80527-1f23-49db-b667-a4a9e27e5475
result |> to_giac |> simplify

# ╔═╡ 5e07b428-ec33-43f4-8ba8-0bfe6cdbf0cd
md"""
## 5. Matrix

The widget can be pre-filled with a MathJSON expression for matrix
"""

# ╔═╡ 927d637c-f353-4769-9821-34dde2d75413
M = GiacMatrix([a b; c d])

# ╔═╡ a64aed43-a2ff-443f-b6cf-f5f85d3d7266
@bind formula_mathjson_default_mat1 MathInput(default="[\"Matrix\",[\"List\",[\"List\",\"a\",\"b\"],[\"List\",\"c\",\"d\"]]]")

# ╔═╡ adec6b71-4fb4-4489-bd99-31789ccbf52a
parse(MathJSONFormat, formula_mathjson_default_mat1) |> to_giac |> det

# ╔═╡ 6e260fac-74ed-43f3-b25d-c4c6f0297f7f
md"""
## 6. First-order system: step response (Laplace / inverse Laplace)

A first-order system with transfer function

$H(s) = \dfrac{K}{1 + \tau s}$

is driven by a step input $e(t) = E \cdot u(t)$, whose Laplace transform is $E(s) = \dfrac{E}{s}$.

The output in the Laplace domain is $Y(s) = H(s) \cdot E(s)$, and the time response is obtained with the inverse Laplace transform:

$y(t) = K E \left(1 - e^{-t/\tau}\right)$
"""

# ╔═╡ b8b1b7ce-ca96-4880-af8a-9b189287b323
@giac_var K tau E

# ╔═╡ 351c5fc5-9684-429e-9864-e499747b4855
@bind _H MathInput(K / (1 + tau*s), canonicalize=false)  # first-order transfer function

# ╔═╡ bb42c5e1-894f-409f-8756-2016c32ca840
@bind _E_s MathInput(E / s)  # Laplace transform of the step input e(t) = E·u(t)

# ╔═╡ 3d9b735e-6526-478c-9003-3c97f2278f78
H = parse(MathJSONFormat, _H) |> to_giac

# ╔═╡ a5abf419-d8ef-4735-a7ee-eccfcfb4b369
E_s = parse(MathJSONFormat, _E_s) |> to_giac

# ╔═╡ ee076b4e-f906-4625-8561-c3b7f8213e4e
Y_step = H * E_s  # output in the Laplace domain

# ╔═╡ 0c5deda7-081b-45ab-b4eb-918cf875b5be
partfrac(Y_step, s)  # partial fraction decomposition

# ╔═╡ 08315bb5-63bc-4635-8070-18d11f8b13c7
y_step = ilaplace(Y_step, s, t)  # inverse Laplace: time response y(t)

# ╔═╡ a52bf46b-07ae-41dc-9e13-a5c5207f12a5
y_step |> to_mathjson

# ╔═╡ 24686f77-4bcc-43f7-bef2-798a6f3150e5
md"""
**Round trip check**: the Laplace transform of $y(t)$ gives back $Y(s)$.
"""

# ╔═╡ ed269b78-d3b8-405d-a81f-a83c79dfc403
laplace(y_step, t, s) |> simplify |> factor # = K·E / (s(1+τs))

# ╔═╡ 05cc94f0-1ef1-43b3-9d11-c91e06c29f04
md"""
**Initial and final value theorems**:

$y(0^+) = \lim_{s \to \infty} s\,Y(s) \qquad y(\infty) = \lim_{s \to 0} s\,Y(s)$
"""

# ╔═╡ 31a7a282-fc67-4597-8851-c5b2d72afe65
limit(s*Y_step, s, 0)  # final value: y(∞) = K·E

# ╔═╡ c4c4eb72-5004-4887-9698-bf23618aac5f
giac_eval("limit(s * K/(1+tau*s) * E/s, s, inf)")  # initial value: y(0⁺) = 0

# ╔═╡ f16313a7-4df8-42f3-a346-581eb55ee241
md"""# Testing"""

# ╔═╡ b985baf8-b14c-4b58-9cf5-bca2a22b02c9
@bind formula_mathjson_default4 MathInput(default="[\"Integrate\", [\"Add\",[\"Power\",\"x\",2],[\"Multiply\",-3,\"x\"],-1], \"x\"]", format=:mathjson, canonicalize=false)

# ╔═╡ c39c6001-3a39-4372-9a6a-82015b22bbcb
# to_giac(evaluate(parse(MathJSONFormat, formula_mathjson_default4)))
parse(MathJSONFormat, formula_mathjson_default4) |> evaluate |> to_giac

# ╔═╡ eb39386a-a462-4f6f-988e-6a9e4b5ff027
#simplify(derive(to_giac(evaluate(parse(MathJSONFormat, formula_mathjson_default3))),x))

parse(MathJSONFormat, formula_mathjson_default3) |> evaluate |> to_giac |> derive |> simplify

# ╔═╡ 922d66a7-623a-4a8f-9c7f-0c4c67be49c2
@bind formula_mathjson_default5 MathInput(default=
"[\"Power\",[\"Add\",\"a\",\"b\"],2]", format=:mathjson, canonicalize=false, )

# ╔═╡ 07a3fec8-e59f-4a5f-af30-9fbaa146a034
if formula_mathjson_default5 != ""
	# expand(to_giac(parse(MathJSONFormat, formula_mathjson_default5)))
	parse(MathJSONFormat, formula_mathjson_default5) |> to_giac |> expand
end

# ╔═╡ Cell order:
# ╠═8a1b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d
# ╠═46f4aefa-8238-428f-bc01-90855e43a10c
# ╟─1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d
# ╟─2a573271-b01e-4717-93a1-27c2d3112d79
# ╠═9b235b16-e443-478b-a6a9-fce5ee331614
# ╠═5df2c070-8561-4114-941d-1df3c1be9a08
# ╠═d51983dd-946b-4e37-8f47-4c73da011483
# ╠═abcef206-a381-45e2-8e7e-4d01be910e1e
# ╠═8a675a42-0a40-43ef-a429-66d1749dd7d2
# ╠═0fb2f0e6-5087-43cf-9dbd-5e0e89127c05
# ╠═52ef829a-83a3-4d0f-a0ec-c6501acca454
# ╠═7e8f24e8-7843-4e70-8dce-f0407222ffed
# ╠═c36d15e1-5010-4135-a707-5196c55e1506
# ╟─2a3b4c5d-6e7f-8a9b-0c1d-2e3f4a5b6c7d
# ╠═370bbeb1-bb71-4104-985a-ced1dbbdf905
# ╠═184649d4-3002-4f27-859c-8b678fe5a63f
# ╠═3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d
# ╠═4a5b6c7d-8e9f-0a1b-2c3d-4e5f6a7b8c9d
# ╠═74a84a84-424c-42e3-a5de-0e3b6b801a20
# ╟─b2d74da0-853b-4bae-bc95-5e8568f45233
# ╠═e084fd23-4e52-48b0-8006-2c6141621cb8
# ╠═29533fe6-1873-4ebd-99f6-cd88105d6762
# ╠═42625fdb-c3b9-4a34-85f1-34a86d39137e
# ╠═70cf1f91-f021-4e18-9a71-b505c6fd4b7e
# ╠═580a1018-0bee-4dc9-a4ee-be5bc9db8290
# ╠═e5278697-e78a-4ec6-8c2b-0a5f020f9475
# ╟─ba29fe53-c93f-46c2-aa7a-4776ab4941aa
# ╠═e0193038-7425-4b46-b12f-5edce6be0f50
# ╠═f0b2dd65-f12a-4693-b862-2793fac94e81
# ╠═1678428b-c8c2-46bf-b34d-5d5ccf128744
# ╠═c21d2db1-3e7e-46b4-8a75-af603c47c03d
# ╠═272fe2ab-c263-43fb-a372-4e489eab1b2c
# ╠═0e6db43d-b897-468e-a2f1-3dc3b78b952a
# ╠═c582cc9c-994c-4b97-a9b7-2db3b71d30a3
# ╠═c80f902d-c43f-4fcc-ac1b-d389606a2ff4
# ╠═7a53c460-af0d-40ee-a0dd-eceaa30f675e
# ╠═b1904dbe-17c9-4d03-b9a6-c2b48d833970
# ╠═c036c3a1-094e-4672-a4d0-0210565ad194
# ╠═79e80527-1f23-49db-b667-a4a9e27e5475
# ╟─5e07b428-ec33-43f4-8ba8-0bfe6cdbf0cd
# ╠═927d637c-f353-4769-9821-34dde2d75413
# ╠═a64aed43-a2ff-443f-b6cf-f5f85d3d7266
# ╠═adec6b71-4fb4-4489-bd99-31789ccbf52a
# ╟─6e260fac-74ed-43f3-b25d-c4c6f0297f7f
# ╠═b8b1b7ce-ca96-4880-af8a-9b189287b323
# ╠═351c5fc5-9684-429e-9864-e499747b4855
# ╠═bb42c5e1-894f-409f-8756-2016c32ca840
# ╠═3d9b735e-6526-478c-9003-3c97f2278f78
# ╠═a5abf419-d8ef-4735-a7ee-eccfcfb4b369
# ╠═ee076b4e-f906-4625-8561-c3b7f8213e4e
# ╠═0c5deda7-081b-45ab-b4eb-918cf875b5be
# ╠═08315bb5-63bc-4635-8070-18d11f8b13c7
# ╠═a52bf46b-07ae-41dc-9e13-a5c5207f12a5
# ╟─24686f77-4bcc-43f7-bef2-798a6f3150e5
# ╠═ed269b78-d3b8-405d-a81f-a83c79dfc403
# ╟─05cc94f0-1ef1-43b3-9d11-c91e06c29f04
# ╠═31a7a282-fc67-4597-8851-c5b2d72afe65
# ╠═c4c4eb72-5004-4887-9698-bf23618aac5f
# ╠═f16313a7-4df8-42f3-a346-581eb55ee241
# ╠═b985baf8-b14c-4b58-9cf5-bca2a22b02c9
# ╠═c39c6001-3a39-4372-9a6a-82015b22bbcb
# ╠═eb39386a-a462-4f6f-988e-6a9e4b5ff027
# ╠═922d66a7-623a-4a8f-9c7f-0c4c67be49c2
# ╠═07a3fec8-e59f-4a5f-af30-9fbaa146a034
