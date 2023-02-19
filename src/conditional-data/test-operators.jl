export EQ, GT, LT, GEQ, LEQ,
        test_operator_inverse,
        existential_aggregator, aggregator_bottom,
        evaluate_thresh_decision, aggregator_to_binary, dual_test_operator,
        Aggregator, TestOperatorFun

using SoleLogics: TruthValue

############################################################################################

const Aggregator = Function

const TestOperatorFun = Function

# struct TestOperator{T<:TruthValue,U,F<:TestOperatorFun}
#     fw::FunctionWrapper{T,Tuple{U,U}}

#     function TestOperator{T,U}(f::TestOperatorFun) where {T<:TruthValue,U}
#         new{T,U,typeof(f)}(FunctionWrapper{T,Tuple{U,U}}(f))
#     end
# end

# function (op::TestOperator{T,U})(args...)::T where {T<:TruthValue,U}
#     op.fw(args...)
# end

# function Base.show(io::IO, op::TestOperator{T,U,F}) where {T,U,F}
#     s = string(F)
#     if !isnothing(match(r"^typeof\((.+)\)$", s))
#         println(io, chop(s, head = length("typeof("), tail = length(")")))
#     elseif !isnothing(match(r"^Val{typeof\((.+)\)}$", s))
#         println(io, chop(s, head = length("Val{typeof("), tail = length(")}")))
#     elseif !isnothing(match(r"^Val{(.+)}$", s))
#         println(io, chop(s, head = length("Val{"), tail = length("}")))
#     else
#         println(io, s)
#     end
# end

# test_operator_inverse(::TestOperator{T,U,F}) where {T,U,F} = test_operator_inverse(F)
# test_operator_inverse(::Type{typeof(≥)})  = ...(<)
# test_operator_inverse(::Type{typeof(≤)})  = ...(>)
# test_operator_inverse(::Type{typeof(>)})  = ...(≤)
# test_operator_inverse(::Type{typeof(<)})  = ...(≥)
# test_operator_inverse(::Type{typeof(==)}) = ...(!=)
# test_operator_inverse(::Type{typeof(!=)}) = ...(==)


# existential_aggregator(::TestOperator{T,U,F}) where {T,U,F} = existential_aggregator(F)
# existential_aggregator(::Type{typeof(≥)})  = maximum
# existential_aggregator(::Type{typeof(≤)})  = minimum
# existential_aggregator(::Type{typeof(>)})  = maximum
# existential_aggregator(::Type{typeof(<)})  = minimum
# existential_aggregator(::Type{typeof(!=)}) = ∪

# dual_test_operator(::TestOperator{T,U,F}) where {T,U,F} = dual_test_operator(F)
# dual_test_operator(::Type{typeof(≥)})  = ...(≤)
# dual_test_operator(::Type{typeof(≤)})  = ...(≥)


# evaluate_thresh_decision(operator::TestOperator{T,U,F}), gamma::U, a::U) where {T,U,F} = evaluate_thresh_decision(F, gamma, a)
# evaluate_thresh_decision(opf::TestOperatorFun, gamma::U, a::U) where {U} = ???????

############################################################################################

# crisp operators

evaluate_thresh_decision(operator::TestOperatorFun, gamma::T, a::T) where {T} = operator(gamma, a)

test_operator_inverse(::typeof(≥))  = <
test_operator_inverse(::typeof(≤))  = >
test_operator_inverse(::typeof(<))  = ≥
test_operator_inverse(::typeof(>))  = ≤
test_operator_inverse(::typeof(==)) = !=
test_operator_inverse(::typeof(!=)) = ==

existential_aggregator(::typeof(==)) = ∪
existential_aggregator(::typeof(>))  = maximum
existential_aggregator(::typeof(<))  = minimum
existential_aggregator(::typeof(≥))  = maximum
existential_aggregator(::typeof(≤))  = minimum

universal_aggregator(::typeof(==)) = ∩
universal_aggregator(::typeof(>))  = minimum
universal_aggregator(::typeof(<))  = maximum
universal_aggregator(::typeof(≥))  = minimum
universal_aggregator(::typeof(≤))  = maximum

aggregator_bottom(::typeof(maximum), T::Type) = typemin(T)
aggregator_bottom(::typeof(minimum), T::Type) = typemax(T)

aggregator_to_binary(::typeof(maximum)) = max
aggregator_to_binary(::typeof(minimum)) = min

dual_test_operator(::typeof(≥)) = ≤
dual_test_operator(::typeof(≤)) = ≥

############################################################################################

# equality_operator(x::S,  y::S)       where {S} = ==(x,y)  # =
# greater_than_operator(x::S,  y::S)   where {S} =  >(x,y)  # >
# lesser_than_operator(x::S,  y::S)    where {S} =  <(x,y)  # <
# greater_eq_than_operator(x::S, y::S) where {S} =  ≥(x,y)  # ≥
# lesser_eq_than_operator(x::S, y::S)  where {S} =  ≤(x,y)  # ≤

# existential_aggregator(::typeof(equality_operator))        = ∪
# existential_aggregator(::typeof(greater_than_operator))    = maximum
# existential_aggregator(::typeof(lesser_than_operator))     = minimum
# existential_aggregator(::typeof(greater_eq_than_operator)) = maximum
# existential_aggregator(::typeof(lesser_eq_than_operator))  = minimum

# const EQ  = equality_operator
# const GT  = greater_than_operator
# const LT  = lesser_than_operator
# const GEQ = greater_eq_than_operator
# const LEQ = lesser_eq_than_operator


# const OrderingTestOperator = Union{
#     typeof(GT),
#     typeof(LT),
#     typeof(GEQ),
#     typeof(LEQ),
# }

# # fuzzy operators

# # =ₕ
# function get_fuzzy_linear_eq(h::T, fuzzy_type::Type{<:Real} = Float64) where {T}
#   fun = function (x::S, y::S) where {S}
#     Δ = y-x
#     if abs(Δ) ≥ h
#       zero(fuzzy_type)
#     else
#       fuzzy_type(1-(abs(Δ)/h))
#     end
#   end
#   @eval global existential_aggregator(::typeof($fun)) = ∪
#   fun
# end


# # >ₕ
# function get_fuzzy_linear_gt(h::T, fuzzy_type::Type{<:Real} = Float64) where {T}
#   fun = function (x::S, y::S) where {S}
#     Δ = y-x
#     if Δ ≥ 0
#       zero(fuzzy_type)
#     elseif Δ ≤ -h
#       one(fuzzy_type)
#     else
#       fuzzy_type(Δ/h)
#     end
#   end
#   @eval global existential_aggregator(::typeof($fun)) = maximum
#   fun
# end

# # <ₕ
# function get_fuzzy_linear_lt(h::T, fuzzy_type::Type{<:Real} = Float64) where {T}
#   fun = function (x::S, y::S) where {S}
#     Δ = y-x
#     if Δ ≥ h
#       one(fuzzy_type)
#     elseif Δ ≤ 0
#       zero(fuzzy_type)
#     else
#       fuzzy_type(Δ/h)
#     end
#   end
#   @eval global existential_aggregator(::typeof($fun)) = minimum
#   fun
# end


# # ≧ₕ
# function get_fuzzy_linear_geq(h::T, fuzzy_type::Type{<:Real} = Float64) where {T}
#   fun = function (x::S, y::S) where {S}
#     Δ = y-x
#     if Δ ≤ 0
#       one(fuzzy_type)
#     elseif Δ ≥ h
#       zero(fuzzy_type)
#     else
#       fuzzy_type(1-Δ/h)
#     end
#   end
#   @eval global existential_aggregator(::typeof($fun)) = maximum
#   fun
# end


# # ≦ₕ
# function get_fuzzy_linear_leq(h::T, fuzzy_type::Type{<:Real} = Float64) where {T}
#   fun = function (x::S, y::S) where {S}
#     Δ = x-y
#     if Δ ≤ 0
#       one(fuzzy_type)
#     elseif Δ ≥ h
#       zero(fuzzy_type)
#     else
#       fuzzy_type(1-Δ/h)
#     end
#   end
#   @eval global existential_aggregator(::typeof($fun)) = minimum
#   fun
# end

# # ≥ₕ
# function get_fuzzy_linear_geqt(h::T, fuzzy_type::Type{<:Real} = Float64) where {T}
#   h_2 = h/2
#   fun = function (x::S, y::S) where {S}
#     Δ = y-x
#     if Δ ≥ h_2
#       zero(fuzzy_type)
#     elseif Δ ≤ -h_2
#       one(fuzzy_type)
#     else
#       fuzzy_type((h_2-Δ)/h)
#     end
#   end
#   @eval global existential_aggregator(::typeof($fun)) = maximum
#   fun
# end

# # ≤ₕ
# function get_fuzzy_linear_leqt(h::T, fuzzy_type::Type{<:Real} = Float64) where {T}
#   h_2 = h/2
#   fun = function (x::S, y::S) where {S}
#     Δ = y-x
#     if Δ ≥ h_2
#       one(fuzzy_type)
#     elseif Δ ≤ -h_2
#       zero(fuzzy_type)
#     else
#       fuzzy_type((Δ+h_2)/h)
#     end
#   end
#   @eval global existential_aggregator(::typeof($fun)) = minimum
#   fun
# end

# h = 4
# v1 = 0
# v2 = -4:4

# op_fuzzy_eq = get_fuzzy_linear_eq(h)
# op_fuzzy_gt = get_fuzzy_linear_gt(h)
# op_fuzzy_lt = get_fuzzy_linear_lt(h)
# op_fuzzy_geqt = get_fuzzy_linear_geqt(h)
# op_fuzzy_leqt = get_fuzzy_linear_leqt(h)
# op_fuzzy_geq = get_fuzzy_linear_geq(h)
# op_fuzzy_leq = get_fuzzy_linear_leq(h)

# zip(v2, eq.(v1, v2)) |> collect
# zip(v2, gt.(v1, v2)) |> collect
# zip(v2, lt.(v1, v2)) |> collect
# zip(v2, geq.(v1, v2)) |> collect
# zip(v2, leq.(v1, v2)) |> collect
# zip(v2, op_fuzzy_eq.(v1, v2)) |> collect
# zip(v2, op_fuzzy_gt.(v1, v2)) |> collect
# zip(v2, op_fuzzy_lt.(v1, v2)) |> collect
# zip(v2, op_fuzzy_geqt.(v1, v2)) |> collect
# zip(v2, op_fuzzy_leqt.(v1, v2)) |> collect
# zip(v2, op_fuzzy_geq.(v1, v2)) |> collect
# zip(v2, op_fuzzy_leq.(v1, v2)) |> collect

################################################################################
################################################################################

export MixedFeature, CanonicalFeature, canonical_geq, canonical_leq

abstract type CanonicalFeature end

preserves_type(::CanonicalFeature) = true

# ⪴ and ⪳, that is, "*all* of the values on this world are at least, or at most ..."
struct CanonicalFeatureGeq <: CanonicalFeature end; const canonical_geq  = CanonicalFeatureGeq();
struct CanonicalFeatureLeq <: CanonicalFeature end; const canonical_leq  = CanonicalFeatureLeq();

export canonical_geq_95, canonical_geq_90, canonical_geq_85, canonical_geq_80, canonical_geq_75, canonical_geq_70, canonical_geq_60,
       canonical_leq_95, canonical_leq_90, canonical_leq_85, canonical_leq_80, canonical_leq_75, canonical_leq_70, canonical_leq_60

# ⪴_α and ⪳_α, that is, "*at least α⋅100 percent* of the values on this world are at least, or at most ..."

struct CanonicalFeatureGeqSoft  <: CanonicalFeature
  alpha :: AbstractFloat
  CanonicalFeatureGeqSoft(a::T) where {T<:Real} = (a > 0 && a < 1) ? new(a) : throw_n_log("Invalid instantiation for test operator: CanonicalFeatureGeqSoft($(a))")
end;
struct CanonicalFeatureLeqSoft  <: CanonicalFeature
  alpha :: AbstractFloat
  CanonicalFeatureLeqSoft(a::T) where {T<:Real} = (a > 0 && a < 1) ? new(a) : throw_n_log("Invalid instantiation for test operator: CanonicalFeatureLeqSoft($(a))")
end;

const canonical_geq_95  = CanonicalFeatureGeqSoft((Rational(95,100)));
const canonical_geq_90  = CanonicalFeatureGeqSoft((Rational(90,100)));
const canonical_geq_85  = CanonicalFeatureGeqSoft((Rational(85,100)));
const canonical_geq_80  = CanonicalFeatureGeqSoft((Rational(80,100)));
const canonical_geq_75  = CanonicalFeatureGeqSoft((Rational(75,100)));
const canonical_geq_70  = CanonicalFeatureGeqSoft((Rational(70,100)));
const canonical_geq_60  = CanonicalFeatureGeqSoft((Rational(60,100)));

const canonical_leq_95  = CanonicalFeatureLeqSoft((Rational(95,100)));
const canonical_leq_90  = CanonicalFeatureLeqSoft((Rational(90,100)));
const canonical_leq_85  = CanonicalFeatureLeqSoft((Rational(85,100)));
const canonical_leq_80  = CanonicalFeatureLeqSoft((Rational(80,100)));
const canonical_leq_75  = CanonicalFeatureLeqSoft((Rational(75,100)));
const canonical_leq_70  = CanonicalFeatureLeqSoft((Rational(70,100)));
const canonical_leq_60  = CanonicalFeatureLeqSoft((Rational(60,100)));


const MixedFeature = Union{AbstractFeature,CanonicalFeature,Function,Tuple{TestOperatorFun,Function},Tuple{TestOperatorFun,AbstractFeature}}

############################################################################################









# (Rational(60,100))

# # TODO improved version for Rational numbers
# # TODO check
# @inline test_op_partialsort!(test_op::CanonicalFeatureGeqSoft, vals::Vector{T}) where {T} =
#   partialsort!(vals,ceil(Int, alpha(test_op)*length(vals)); rev=true)
# @inline test_op_partialsort!(test_op::CanonicalFeatureLeqSoft, vals::Vector{T}) where {T} =
#   partialsort!(vals,ceil(Int, alpha(test_op)*length(vals)))

# @inline computePropositionalThreshold(test_op::Union{CanonicalFeatureGeqSoft,CanonicalFeatureLeqSoft}, w::AbstractWorld, channel::DimensionalChannel{T,N}) where {T,N} = begin
#   vals = vec(ch_readWorld(w,channel))
#   test_op_partialsort!(test_op,vals)
# end
# @inline computePropositionalThresholdMany(test_ops::Vector{<:TestOperator}, w::AbstractWorld, channel::DimensionalChannel{T,N}) where {T,N} = begin
#   vals = vec(ch_readWorld(w,channel))
#   (test_op_partialsort!(test_op,vals) for test_op in test_ops)
# end

# @inline test_decisioaoeu(test_operator::CanonicalFeatureGeqSoft, w::AbstractWorld, channel::DimensionalChannel{T,N}, threshold::Real) where {T,N} = begin
#   ys = 0
#   # TODO write with reduce, and optimize it (e.g. by stopping early if the decision is reached already)
#   vals = ch_readWorld(w,channel)
#   for x in vals
#     if x >= threshold
#       ys+=1
#     end
#   end
#   (ys/length(vals)) >= test_operator.alpha
# end

# @inline test_decisioaoeu(test_operator::CanonicalFeatureLeqSoft, w::AbstractWorld, channel::DimensionalChannel{T,N}, threshold::Real) where {T,N} = begin
#   ys = 0
#   # TODO write with reduce, and optimize it (e.g. by stopping early if the decision is reached already)
#   vals = ch_readWorld(w,channel)
#   for x in vals
#     if x <= threshold
#       ys+=1
#     end
#   end
#   (ys/length(vals)) >= test_operator.alpha
# end

# const all_lowlevel_test_operators = [
#     canonical_geq, canonical_leq,
#     SoftenedOperators...
#   ]

# const all_ordered_test_operators = [
#     canonical_geq, canonical_leq,
#     SoftenedOperators...
#   ]
# const all_test_operators_order = [
#     canonical_geq, canonical_leq,
#     SoftenedOperators...
#   ]
# sort_test_operators!(x::Vector{TO}) where {TO<:TestOperator} = begin
#   intersect(all_test_operators_order, x)
# end
